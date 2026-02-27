---
title: "/loop Command Improvements"
tier: Standard
status: complete
created: 2026-02-26
estimated_effort: 4-8h
risk_level: medium
affected_files:
  - commands/loop.md
  - hooks/protect-protocol-files.sh
  - hooks/session-start.sh
  - guides/PROJECT_CONVENTIONS.md
  - docs/solutions/ (new learnings)
tags: [loop, autonomous, reliability, observability, safety]
---

# /loop Command Improvements Plan

## Context

The `/loop` autonomous development loop has two confirmed bugs, several brittleness risks, and missing capabilities that reduce reliability and observability. This plan addresses all 15 identified issues organized into 6 implementation phases with explicit dependencies.

**Baseline:** `commands/loop.md` (416 lines), `hooks/protect-protocol-files.sh` (47 lines), latest main at commit `f7658d9`.

---

## Phase 1: Bug Fixes (High Priority, No Dependencies)

### Task 1.1: Fix hook path extraction for Write tool
**File:** `hooks/protect-protocol-files.sh` (line 18)
**Bug:** The jq fallback `.tool_input.content` grabs file *content* instead of file *path* for Write tool calls. If `file_path` were absent, the hook would match against content text, not the target path — silently bypassing protection.
**Fix:** Remove the `.tool_input.content` fallback. The Write tool schema always has `file_path`.
```bash
# Before:
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.content // empty' 2>/dev/null)

# After:
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
```
**Risk:** None — `.tool_input.content` was never the correct field.

- [ ] Fix jq path extraction in protect-protocol-files.sh
- [ ] Add comment explaining why only file_path is checked

### Task 1.2: Add unknown-status catch-all to thin shell loop
**File:** `commands/loop.md` (Step 3, lines 131-137)
**Bug:** If `loop-context.md` has an unexpected `status:` value (corruption, typo, empty), no conditional matches. The loop spawns workers indefinitely with no exit condition.
**Fix:** Add an explicit else clause after the status checks:
```
→ status not in ["running", "complete", "review"]  → HALT with error:
  "Unexpected loop status: '{status}'. loop-context.md may be corrupted.
   Fix the status field or delete the file and restart."
```
**Risk:** None — adds safety where none exists.

- [ ] Add catch-all else clause for unexpected status values in Step 3

---

## Phase 2: Reliability Hardening (Depends on Phase 1)

### Task 2.1: Add dirty working tree detection on startup
**File:** `commands/loop.md` (Step 2, Setup Phase)
**Problem:** If a previous worker crashed after writing code but before committing, uncommitted changes sit in the working tree. The next worker for the same task starts fresh and may conflict.
**Fix:** Add to Setup Phase before spawning any workers:
```
### Dirty Working Tree Detection

Before entering the loop, check for uncommitted changes:
1. Run `git status --porcelain`
2. If output is non-empty, AskUserQuestion:
   "Uncommitted changes detected in working tree. These may be from a crashed loop worker.
   Options: [Stash and continue] [Commit and continue] [Abort]"
   - Stash: `git stash push -m "loop-recovery-{timestamp}"`
   - Commit: `git add -A && git commit -m "chore: recover uncommitted loop worker changes"`
   - Abort: halt
```
**Risk:** Low — new AskUserQuestion gate only fires when there's a real problem.

- [ ] Add dirty working tree detection to Step 2 Setup Phase

### Task 2.2: Add per-task commit tracking to loop-context.md
**File:** `commands/loop.md` (loop-context.md format, Worker Prompt)
**Problem:** No per-task commit tracking. If task 5 breaks something working after task 4, there's no way to identify or revert just task 5.
**Fix:** Extend loop-context.md format with a `task_commits` list:
```yaml
task_commits:
  - task: "Add user model"
    commit: "abc1234"
    status: done
  - task: "Add auth middleware"
    commit: "def5678"
    status: done
```
Update Worker Prompt step 4.h to append the commit SHA after committing:
```
h. Update `.claude/loop-context.md`:
   - Increment tasks_completed by 1
   - Append to task_commits: {task: "<task text>", commit: "<SHA>", status: "done"}
```
Update blocked path (step 5) similarly with `status: "blocked"`.
Add to Completion output: list task commits with SHAs for selective revert capability.
**Risk:** Low — additive change to YAML format. Existing loop-context.md files without this field are unaffected (workers create new ones on setup).

- [ ] Add task_commits field to loop-context.md format
- [ ] Update Worker Prompt to record commit SHA per task
- [ ] Update blocked path to record blocked tasks in task_commits
- [ ] Update Completion output to list per-task commits

### Task 2.3: Add review worker fallback when Agent Teams unavailable
**File:** `commands/loop.md` (Review Worker Prompt, lines 237-320)
**Problem:** Review worker assumes Agent Teams (`TeamCreate`, `TeamDelete`, `SendMessage`). If the experimental flag `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is off, the review worker fails with no fallback.
**Fix:** Add a capability detection preamble to the Review Worker Prompt:
```
## Phase 0: Capability Detection

1. Check if TeamCreate tool is available in your tool list.
2. If YES: proceed with Phase 1-5 as written (Agent Teams mode).
3. If NO: use SUBAGENT FALLBACK MODE:
   - Instead of creating a team, spawn each specialist as a parallel
     `general-purpose` Task subagent (NOT a teammate).
   - Each subagent runs the same review prompt and returns findings.
   - Skip Phase 3-4 teammate messaging (collect findings from subagent
     return values instead).
   - Skip Phase 5 team cleanup (no team to clean up).
   - Proceed directly to consolidation and adversarial validation
     using your own context (you are the supervisor and validator).
```
**Risk:** Low — adds a fallback path that mirrors the existing subagent-based review in `/review`.

- [ ] Add Phase 0 capability detection to Review Worker Prompt
- [ ] Add subagent fallback mode instructions

---

## Phase 3: Observability (No Dependencies on Phase 2)

### Task 3.1: Add cost and timing tracking to loop-context.md
**File:** `commands/loop.md` (loop-context.md format, Worker Prompt, Completion)
**Problem:** No visibility into token cost or time per task. A 50-iteration loop with 3 review rounds can be expensive with zero cost awareness.
**Fix:** Extend loop-context.md:
```yaml
timing:
  loop_started: "<ISO timestamp>"
  last_task_started: "<ISO timestamp>"
  last_task_duration_s: 0
  total_elapsed_s: 0
```
Update thin shell loop (Step 3, item 4) to track timing:
```
→ Record task start time before spawning worker
→ Record task end time after worker returns
→ Update timing.last_task_duration_s and timing.total_elapsed_s
→ Print: "Task {completed}/{total} complete ({blocked} blocked) — {duration}s — elapsed {total}s"
```
Update Completion output to include total elapsed time.
**Risk:** None — purely additive observability.

- [ ] Add timing fields to loop-context.md format
- [ ] Update thin shell loop to record timing per task
- [ ] Update progress output to show duration
- [ ] Update Completion output to show total elapsed time

### Task 3.2: Add worker activity logging
**File:** `commands/loop.md` (Worker Prompt, thin shell loop)
**Problem:** During a long task (5-10 min), there's no visibility into what the worker is doing. Level 0 only prints after completion.
**Fix:** Add a `worker_log` field to loop-context.md that the worker updates as it progresses:
```yaml
worker_log: ""  # Overwritten each iteration
```
Worker Prompt addition (after step 4.a):
```
   a2. Write a one-line status to `.claude/loop-context.md` worker_log field:
       "Reading codebase for task: <task name>"
   ... (similar updates at steps 4.c, 4.d, 4.e, 4.f)
```
This is lightweight — Level 0 doesn't poll it, but if the user checks the file manually or if a future version adds polling, the data is there.
**Risk:** Minimal — adds a few Edit calls per worker. Worth it for debuggability.

- [ ] Add worker_log field to loop-context.md format
- [ ] Add status update instructions to Worker Prompt at key steps

---

## Phase 4: Intelligence (Depends on Phase 2.2 for commit tracking)

### Task 4.1: Add inter-task context file for knowledge passing
**File:** `commands/loop.md` (Worker Prompt, loop-context.md format)
**Problem:** Each worker starts with zero context. Worker 5 might need to know what Worker 3 built (e.g., an API endpoint). Currently each worker re-discovers by reading code — wasteful and error-prone.
**Fix:** Introduce `.claude/loop-notes.md` — a shared scratchpad:
```
Worker Prompt addition (after step 4.f, before commit):
   f2. Append a 2-3 line note to `.claude/loop-notes.md`:
       ## Task: <task name>
       - Created/modified: <key files>
       - Key decisions: <any non-obvious choices made>
       - Dependencies exposed: <any new APIs, types, or interfaces other tasks may need>

Worker Prompt addition (after step 4.a, before implementation):
   a2. Read `.claude/loop-notes.md` if it exists — this contains notes from
       previous workers about what they built and key decisions they made.
```
Add `loop-notes.md` to the cleanup in Completion (or leave for human reference).
Add `loop_notes_path: ".claude/loop-notes.md"` to loop-context.md format.
**Risk:** Low — additive. Workers that don't find the file skip it. Notes are append-only (no edit conflicts).

- [ ] Add loop-notes.md concept to loop-context.md format
- [ ] Update Worker Prompt to read loop-notes.md before implementation
- [ ] Update Worker Prompt to append notes after committing
- [ ] Add loop-notes.md cleanup/preservation to Completion step

### Task 4.2: Add task dependency awareness
**File:** `commands/loop.md` (Worker Prompt, Step 3)
**Problem:** Tasks are picked up in linear order (first `[ ]`). If task 7 depends on task 3's output, this works only by accident of plan ordering. No dependency graph.
**Fix:** Support optional dependency markers in plan task format:
```markdown
- [ ] Add user model (models/user.py)
- [ ] Add auth middleware (depends: "Add user model")
- [ ] Add login endpoint (depends: "Add auth middleware")
- [ ] Add user profile page (depends: "Add user model")
```
Worker Prompt addition (step 3):
```
3. Find the FIRST unchecked task (marked with `[ ]`). Skip `[x]` and `[!]`.
   - If the task line contains `(depends: "...")`, check if the named dependency
     task is `[x]` (completed). If the dependency is still `[ ]` or `[!]`,
     SKIP this task and try the next `[ ]` task.
   - If ALL remaining `[ ]` tasks have unmet dependencies, mark ALL of them
     as `[!]` (blocked) with reason "unmet dependency" and update counts.
```
This is backward compatible — tasks without `(depends: ...)` work exactly as before.
**Risk:** Low — additive syntax. Existing plans are unaffected.

- [ ] Document optional dependency syntax in loop command
- [ ] Update Worker Prompt step 3 to check dependency markers
- [ ] Add dependency cycle detection (all remaining tasks blocked on each other)

---

## Phase 5: Review Improvements (Depends on Phase 2.3)

### Task 5.1: Add incremental review diffing
**File:** `commands/loop.md` (Review Worker Prompt, Step 4)
**Problem:** Review round 2 re-reviews the entire diff from `start_commit..HEAD`, including code already reviewed and fixed in round 1. Wasteful.
**Fix:** Track the last reviewed commit in loop-context.md:
```yaml
last_reviewed_commit: "<SHA>"  # Updated after each review round
```
Review Worker Prompt update (Phase 1, step 2):
```
2. Generate the diff:
   - If this is round 1 (or last_reviewed_commit is empty):
     run `git diff {start_commit}..HEAD`
   - If this is round 2+:
     run `git diff {last_reviewed_commit}..HEAD` (only review new changes since last review)
     ALSO run `git diff {start_commit}..HEAD` but only for files touched in the incremental diff
     (to maintain full-file context for the changed areas)
```
Update Step 4 (after review round completes):
```
5. Update loop-context.md: increment review_round, set last_reviewed_commit to current HEAD
```
**Risk:** Low-medium — changes review scope. Could miss issues introduced by the interaction of old and new code. Mitigated by reading full file context for changed files.

- [ ] Add last_reviewed_commit field to loop-context.md
- [ ] Update Review Worker Prompt to use incremental diff on round 2+
- [ ] Update review round tracking to record last_reviewed_commit

---

## Phase 6: Documentation & Learning (Depends on All Above)

### Task 6.1: Update PROJECT_CONVENTIONS.md and QUICK_START.md
**File:** `guides/PROJECT_CONVENTIONS.md`, `QUICK_START.md`
**Fix:** Update any references to loop-context.md format or /loop behavior to reflect new fields and capabilities.

- [ ] Update PROJECT_CONVENTIONS.md with new loop-context.md fields
- [ ] Update QUICK_START.md if it references /loop

### Task 6.2: Capture learning from the [!] infinite loop bug pattern
**File:** `docs/solutions/` (new or update existing)
**Fix:** The existing solution doc covers the symptom but this plan generalizes the pattern. Add a note about the catch-all status handler as a second instance of the same meta-pattern.

- [ ] Update existing state-machine-exhaustive-branch-coverage solution doc with catch-all status handler as related fix

---

## Dependency Graph

```
Phase 1 (Bug Fixes)
  ├── 1.1 Hook path fix          ── no deps ──►  can start immediately
  └── 1.2 Unknown status handler  ── no deps ──►  can start immediately

Phase 2 (Reliability)
  ├── 2.1 Dirty tree detection    ── no deps ──►  can start immediately
  ├── 2.2 Per-task commit tracking ── no deps ──►  can start immediately
  └── 2.3 Review fallback         ── no deps ──►  can start immediately

Phase 3 (Observability)
  ├── 3.1 Cost/timing tracking    ── no deps ──►  can start immediately
  └── 3.2 Worker activity logging ── no deps ──►  can start immediately

Phase 4 (Intelligence)
  ├── 4.1 Inter-task notes        ── no deps ──►  can start immediately
  └── 4.2 Task dependencies       ── no deps ──►  can start immediately

Phase 5 (Review)
  └── 5.1 Incremental review      ── depends on 2.3 (needs fallback-aware review)

Phase 6 (Documentation)
  └── 6.1-6.2                     ── depends on all above (documents final state)
```

**Parallelizable:** Phases 1-4 have no cross-dependencies. All 9 tasks across those phases can be worked in order within each phase, but phases themselves can run concurrently.

**Sequential requirement:** Phase 5 after 2.3. Phase 6 after everything.

---

## Implementation Order (Recommended)

Single-agent sequential execution (most likely for `/loop` itself to execute):

1. **1.1** — Hook fix (5 min, surgical)
2. **1.2** — Status catch-all (5 min, surgical)
3. **2.1** — Dirty tree detection (15 min)
4. **2.2** — Per-task commit tracking (20 min, touches loop-context format + worker prompt + completion)
5. **2.3** — Review fallback (20 min, touches review worker prompt)
6. **3.1** — Timing tracking (15 min)
7. **3.2** — Worker activity logging (10 min)
8. **4.1** — Inter-task notes (15 min)
9. **4.2** — Task dependencies (20 min)
10. **5.1** — Incremental review (15 min)
11. **6.1** — Convention docs update (10 min)
12. **6.2** — Learning capture (5 min)

**Total: ~12 tasks, estimated 2.5-3h of implementation time.**

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Loop-context.md format changes break existing loops | Forward-compatible: new fields have defaults. Workers that don't find a field skip it. |
| Worker prompt gets too long (currently ~40 lines) | New instructions add ~15 lines. Still well under context budget. Monitor. |
| Dependency syntax adds complexity to plan format | Fully optional — no `(depends: ...)` = linear execution as before. |
| Incremental review misses cross-interaction bugs | Mitigated by full-file context reads for changed files. |
| Review fallback (subagent mode) is lower quality than Agent Teams | Acceptable tradeoff — working review > no review. |

## Out of Scope (Deferred)

- **Concurrent task execution** — Requires fundamental architecture change (file locking, merge conflict resolution, worktree-per-worker). Separate plan.
- **Token budget limits** — Requires API-level token counting not available in prompt-driven architecture. Would need a hook or external tool.
- **Streaming progress from workers** — Requires background task monitoring infrastructure. The worker_log field is a pragmatic approximation.
