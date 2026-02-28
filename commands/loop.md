---
name: workflows:loop
description: "Autonomous development loop with context rotation via Task subagents"
argument-hint: "<description | --plan PATH | --issue N> [--max-iterations N]"
---

# /loop — Autonomous Development Loop

**Workflow command.** Autonomous plan-and-implement loop using Task subagents for context rotation. Each worker gets fresh context and reads files for state. No external plugin dependencies.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

```
Level 0: Thin Shell (this conversation — stays small, resists compaction)
  │  Reads ONLY loop-context.md per cycle (~500 tokens)
  │
  ├── Spawn Worker (general-purpose Task, mode: bypassPermissions)
  │   → reads plan, implements 1 task, tests, commits, checks [x], updates counts
  │   → returns one-line summary
  │
  ├── Read loop-context.md → print progress → spawn next worker
  │
  ├── ...repeat until done or max_iterations...
  │
  ├── REVIEW CYCLE (max 3 rounds):
  │   ├── Spawn Review worker → full fresh-eyes-review (smart selection)
  │   │   → outputs structured findings with severity
  │   ├── If no CRITICAL/HIGH findings → done
  │   ├── Spawn Fix worker → fixes all CRITICAL+HIGH findings, commits
  │   └── Loop back to Review worker (re-review from scratch)
  │
  └── Print completion summary
```

Sequential. One worker at a time. Zero concurrency risks.

---

## Step 1: Parse Arguments

Parse `$ARGUMENTS`:

| Pattern | Mode | Example |
|---------|------|---------|
| `--issue N` or `#N` or bare number | Issue mode | `/loop --issue 42`, `/loop #42` |
| `--plan <path>` | Plan mode | `/loop --plan docs/plans/my-plan.md` |
| Any other text | Feature mode | `/loop add user authentication` |
| Empty | Error | Halt with usage message |

**If no arguments**, halt:

```
HALT_PENDING_DECISION

Usage:
  /loop <feature description>        Generate plan, then implement each task
  /loop --plan <path>                Iterate tasks from an existing plan
  /loop --issue <number>             Enhance issue if needed, plan, then implement

Options:
  --max-iterations N                 Maximum iterations (default: 50)

Cancel: Ctrl+C (re-run with --plan to resume)
```

Extract `--max-iterations` if provided (default: 50).

---

## Step 2: Setup Phase

Runs ONCE before entering the thin shell loop.

### Dirty Working Tree Detection

Before anything else, check for uncommitted changes from a possibly crashed worker:
1. Run `git status --porcelain` (excluding untracked files in `.claude/`)
2. If output is non-empty, AskUserQuestion:
   "Uncommitted changes detected in working tree. These may be from a crashed loop worker."
   Options:
   - **Stash and continue** → `git stash push -m "loop-recovery-$(date -u +%Y%m%dT%H%M%SZ)"`
   - **Commit and continue** → `git add -u && git commit -m "chore: recover uncommitted loop worker changes"`
   - **Abort** → halt with message "Clean up working tree before running /loop."

### Stale Loop Detection

If `.claude/loop-context.md` exists with `status: running`:
- `started_at` < 30 minutes ago → AskUserQuestion: "A loop appears to be running (started {time}). Override and start fresh?" (**only gate in the entire command**)
- `started_at` > 30 minutes ago → treat as stale, overwrite

### Mode-Specific Setup

**Feature mode:**
1. Create `.claude/loop-context.md` (see format below)
2. Spawn `general-purpose` Task subagent to generate plan (Standard tier, `skills/generate-plan/SKILL.md` methodology). Auto-accept — user opted into autonomous mode.
3. Verify generated plan has at least one `[ ]` checkbox task. If not, halt with error.
4. Count `[ ]` tasks, update loop-context.md: set `plan_path`, `tasks_total`, `status: running`
5. Read the plan file's YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

**Plan mode:**
1. Verify plan file exists. If not, halt with error.
2. Count `[ ]` tasks. If zero: "Nothing to do — plan already complete" or "All tasks blocked."
3. Create `.claude/loop-context.md` with `plan_path`, task counts, `status: running`
4. Read the plan file's YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

**Issue mode:**
1. Fetch issue: `gh issue view N --json title,body,labels`. If fails, halt with error.
2. If `needs_refinement` label: spawn subagent to enhance issue, re-fetch
3. Spawn subagent to generate plan from issue body
4. Verify plan has `[ ]` tasks, create loop-context.md
5. Read the plan file's YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

### loop-context.md Format

```yaml
---
mode: feature | plan | issue
task: "<description>"
plan_path: "<path>"
loop_notes_path: ".claude/loop-notes.md"
tasks_total: 0
tasks_completed: 0
tasks_blocked: 0
max_iterations: 50
review_round: 0
review_max_rounds: 3
review_clean: false
last_reviewed_commit: ""
status: running
started_at: "<ISO timestamp>"
start_commit: "<current HEAD sha>"
worker_log: ""  # Overwritten (not appended) at each worker status update
timing:
  loop_started: "<ISO timestamp>"
  last_task_started: ""
  last_task_duration_s: 0
  total_elapsed_s: 0
task_commits: []
# task_commits entries:
#   - task: "<task text>"
#     commit: "<short SHA>"
#     status: done | blocked
---
```

---

## Step 3: Thin Shell Loop

**This is the critical section.** Level 0 reads ONLY `loop-context.md` — never the plan file. Workers update task counts in loop-context.md after each task, so Level 0 always has current progress.

```
stall_count = 0

WHILE true:
  1. Read .claude/loop-context.md (ONLY this file)
     → status == "complete"  → break to Step 5 (Completion)
     → status == "review"    → break to Step 4 (Review)
     → status == "running"   → continue to step 2
     → status is anything else → HALT with error:
       "Unexpected loop status: '{status}'. loop-context.md may be corrupted.
        Fix the status field to 'running', 'review', or 'complete', or delete
        the file and restart."
     → (tasks_completed + tasks_blocked) >= tasks_total  → set status "review", break
     → iterations >= max_iterations  → set status "complete", break

  2. Record task start time. Update loop-context.md: timing.last_task_started = now
     Spawn Worker subagent (general-purpose, mode: bypassPermissions)
     (bypassPermissions is required because the worker needs to run git, edit files, and execute tests without per-tool approval gates that would stall the autonomous loop)
     with the WORKER PROMPT below
     Set env: CLAUDE_LOOP_WORKER=1 (enables protocol file protection hook)

  3. On error/timeout:
     → Read loop-context.md to check if worker made partial progress
     → If no progress: stall_count++
     → If stall_count >= 3: set status "complete", break
     → Continue loop

  4. Record task end time. Calculate duration_s = end - start.
     Read loop-context.md for updated counts
     Update: timing.last_task_duration_s = duration_s
     Update: timing.total_elapsed_s = (now - timing.loop_started) in seconds  # Absolute calculation, idempotent on crash recovery
     → Print: "Task {completed}/{total} complete ({blocked} blocked) — {duration_s}s — elapsed {total_elapsed_s}s"
     → Reset stall_count to 0
     → Continue loop
```

### Worker Prompt

Each worker is a `general-purpose` Task subagent spawned with `mode: bypassPermissions`. The prompt:

```
You are implementing ONE task from a development plan. You have ZERO memory
of previous work — read files for ALL context.

## Instructions

1. Read `.claude/loop-context.md` for plan_path and loop_notes_path
2. Read the plan file at that path
3. If loop_notes_path exists, read it — it contains notes from previous workers
   about what they built, key files created, and decisions made. Use this context.
4. Find the FIRST eligible unchecked task (marked with `[ ]`). Skip `[x]` and `[!]`.
   - If a task line contains `(depends: "...")`, check the plan for the named
     dependency. If that dependency task is still `[ ]` or `[!]`, this task is
     NOT eligible — skip it and try the next `[ ]` task.
   - If ALL remaining `[ ]` tasks have unmet dependencies (circular or all
     depend on blocked tasks), mark ALL of them `[!]` with reason
     "unmet dependency", update tasks_blocked count, and output
     "BLOCKED: all remaining tasks have unmet dependencies".
5. Implement ONLY that one task:
   a. Update `.claude/loop-context.md` worker_log: "Starting: <task name>"
      Read CLAUDE.md for project conventions
   b. Search docs/solutions/ for relevant past learnings
   c. Update worker_log: "Implementing: <task name>"
      Write the code changes
   d. Update worker_log: "Testing: <task name>"
      Write/update tests for changed code
   e. Run tests. If tests fail, fix them (up to 3 attempts).
   f. If tests pass: stage specific files and commit:
      git add <specific files changed>
      git commit -m "feat: <concise task summary>"
   g. Capture the commit SHA: run `git rev-parse --short HEAD`
   h. ONLY AFTER commit succeeds: check off the task [x] in the plan file
      (Use Edit tool: old_string="- [ ] <full task text>" new_string="- [x] <full task text>")
   i. Update `.claude/loop-context.md`:
      - Increment tasks_completed by 1
      - Append to task_commits: `- task: "<task text>"\n    commit: "<SHA>"\n    status: done`
   j. Append a brief note to `.claude/loop-notes.md` (create if missing):
      ```
      ## Task: <task name>
      - Files: <key files created or modified>
      - Decisions: <any non-obvious choices or patterns used>
      - Exposes: <any new APIs, types, or interfaces other tasks may need>
      ```
6. If stuck after 3 test-fix attempts:
   a. Mark the task [!] (blocked) in the plan file
   b. Update `.claude/loop-context.md`:
      - Increment tasks_blocked by 1
      - Append to task_commits: `- task: "<task text>"\n    commit: ""\n    status: blocked`
   c. Append a note to `.claude/loop-notes.md`: "## Task: <task> — BLOCKED: <reason>"
7. Output a ONE-LINE summary: "DONE: <task> (<SHA>)" or "BLOCKED: <task> — <reason>"

## Environment
- CLAUDE_LOOP_WORKER=1 (set by the loop orchestrator — enables protocol file protection hook)

## Rules
- ONE task only. Do not implement multiple tasks.
- Commit BEFORE checking [x] — if commit fails, leave task as [ ].
- Do NOT push to remote. Local commits only.
- Do NOT create PRs or modify CI/CD configs.
- Do NOT modify .claude/ directory except loop-context.md and loop-notes.md.
- Do NOT modify commands/*.md, agents/*.md, skills/*.md, guides/*.md, templates/*.md, checklists/*.md, or hooks/*.md.
- Do NOT modify AI_CODING_AGENT_GODMODE.md, CLAUDE.md, QUICK_START.md, or settings.json.
- Use the FULL task line text in Edit old_string to avoid "not unique" errors.
- Read files BEFORE editing. Follow existing codebase patterns.
- Tasks may have optional dependencies: `- [ ] Do X (depends: "Do Y")`.
  Only implement a task if its dependency is `[x]` (completed).
```

---

## Step 4: Review Phase

**Multi-round review loop.** Level 0 orchestrates review → fix → re-review cycles until the code is clean or max rounds reached. Each round uses a FULL fresh-eyes-review with smart agent selection — not lite.

```
WHILE review_round < review_max_rounds:
  1. Read .claude/loop-context.md
     → review_clean == true  → break (already clean)

  2. Spawn REVIEW WORKER (general-purpose, mode: bypassPermissions)
     with the REVIEW WORKER PROMPT below
     → Returns: structured findings or "CLEAN"

  3. Parse review result:
     → "CLEAN" or no CRITICAL/HIGH findings:
        Update loop-context.md: review_clean: true, status: complete
        Break

     → Has CRITICAL or HIGH findings:
        Print: "Review round {round}: {N} findings to fix"

  4. Spawn FIX WORKER (general-purpose, mode: bypassPermissions)
     with the FIX WORKER PROMPT below (includes the findings)
     → Returns: summary of fixes applied

  5. Update loop-context.md: increment review_round, set last_reviewed_commit to current HEAD
     Print: "Review round {round} fixes committed. Re-reviewing..."
     Continue loop

IF review_round >= review_max_rounds AND NOT review_clean:
  Print: "Review reached max rounds ({review_max_rounds}). Some findings may remain."
  Update loop-context.md: status: complete
```

### Review Worker Prompt

Each review worker is a `general-purpose` Task subagent spawned with `mode: bypassPermissions`. It acts as team lead, spawning review agents as parallel teammates via Agent Teams.

```
You are running a FULL fresh-eyes code review. You have ZERO memory of
previous work — read files for ALL context. You coordinate specialists,
consolidate findings, and validate.

## Phase 0: Capability Detection

1. Check if TeamCreate tool is available in your tool list.
2. If YES → use AGENT TEAMS MODE (Phases 1-5 below as written).
3. If NO → use SUBAGENT FALLBACK MODE:
   - In Phase 2, spawn each specialist as a parallel `general-purpose` Task
     subagent (NOT a teammate). Each subagent runs the same review prompt
     and returns findings as its result.
   - Skip Phase 3-4 teammate messaging — collect findings from subagent
     return values instead.
   - Skip Phase 5 team cleanup (no team to clean up).
   - After collecting all subagent results, proceed directly to consolidation
     and adversarial validation using your own context (you are the
     supervisor and validator).
   - Output in the same REVIEW_FINDINGS format.

## Phase 1: Setup

1. Read `.claude/loop-context.md` for start_commit, review_round, and last_reviewed_commit
2. Generate the diff:
   - Validate that start_commit and last_reviewed_commit match `[a-f0-9]{7,40}` before using in commands. If invalid, fall back to full diff from start_commit.
   - If review_round == 0 OR last_reviewed_commit is empty:
     Full diff: `git diff {start_commit}..HEAD` → save to .review/review-diff.txt
   - If review_round > 0 AND last_reviewed_commit is set:
     Incremental diff: `git diff {last_reviewed_commit}..HEAD` → save to .review/review-diff.txt
     (Only review changes since last review round — fixes applied in previous rounds)
     Also generate file list from incremental diff for smart selection
3. Generate the file list: `git diff --name-only {start_commit}..HEAD` (always full for context)
4. Read `guides/FRESH_EYES_REVIEW.md` for the smart selection algorithm
5. Run SMART SELECTION: check trigger patterns against diff content and file list
   - Core agents (always): Security, Code Quality, Edge Case
   - Conditional agents (only if triggered): Performance, API Contract, Concurrency,
     Error Handling, Data Validation, Dependency, Testing Adequacy, Config & Secrets,
     Documentation

## Phase 2: Spawn Review Team (Parallel)

1. Create a team with TeamCreate
2. For EACH selected specialist, spawn a teammate (general-purpose Task, mode: bypassPermissions)
   with this prompt template:

   You are a {specialist type} reviewer with ZERO context about this project.
   Read your review process from {agent definition file path from agents/review/*.md}.
   Review the code changes by running: git diff {start_commit}..HEAD

   Instructions:
   - Output findings in this exact format, one per line:
     [{SEVERITY}] {ID}: {description} ({file}:{line})
     Where SEVERITY is CRITICAL, HIGH, MEDIUM, or LOW
   - Include specific file:line references for every finding
   - If you find a CRITICAL issue, mention it prominently at the top
   - Do NOT fix any code. Review ONLY.
   - Do NOT modify any files or commit anything.

3. Create one task per specialist in the shared task list
4. Assign tasks to teammates. Wait for all to complete.

## Phase 3: Consolidation (You Are Supervisor)

After all specialists complete and send their findings:
1. Collect all findings from teammate messages
2. Remove duplicate findings (same file:line, same issue)
3. For ambiguous findings, message the specialist: "What evidence supports this?"
4. Remove false positives based on specialist responses
5. Prioritize by severity AND real-world impact

## Phase 4: Adversarial Validation (You Are Validator)

1. Challenge each CRITICAL and HIGH finding: Is this exploitable or theoretical?
2. Message specialists for evidence if claims are unsupported
3. Classify: VERIFIED | UNVERIFIED | DISPROVED
4. Drop DISPROVED findings from the final list

## Phase 5: Cleanup and Output

1. Shut down all specialist teammates (SendMessage type: shutdown_request)
2. Delete the team (TeamDelete)
3. Output the FINAL consolidated findings in this exact format:

REVIEW_FINDINGS:
- [CRITICAL] ID: description (file:line)
- [HIGH] ID: description (file:line)
- [MEDIUM] ID: description (file:line)
- [LOW] ID: description (file:line)
CRITICAL_COUNT: N
HIGH_COUNT: N
TOTAL_FINDINGS: N

If there are NO findings at any severity, output exactly:
CLEAN

## Rules
- Do NOT fix any code. Review ONLY.
- Do NOT modify any files (except /tmp/ for the diff).
- Do NOT commit anything.
- Read the FULL diff — do not skip files or truncate.
- Every finding MUST have a specific file and line reference.
- Be thorough. This is the last line of defense before merge.
- ALWAYS clean up the team before returning results.
```

### Fix Worker Prompt

Each fix worker is a `general-purpose` Task subagent spawned with `mode: bypassPermissions`. The prompt includes the findings from the review worker:

```
You are fixing code review findings. You have ZERO memory of previous work —
read files for ALL context.

## Findings to Fix

{paste CRITICAL and HIGH findings from review worker output}

## Instructions

1. Read `.claude/loop-context.md` for context
2. Read CLAUDE.md for project conventions
3. For EACH finding listed above (CRITICAL first, then HIGH):
   a. Read the referenced file
   b. Understand the issue
   c. Implement the fix following existing codebase patterns
   d. Write/update tests if the fix changes behavior
4. Run tests for all affected code. If tests fail, fix them (up to 3 attempts).
5. Stage all changed files and commit:
   git add <specific files changed>
   git commit -m "fix: address review findings — {brief summary}"
6. Output a summary: "FIXED: {N} findings addressed" with a one-line description of each fix.

## Rules
- Fix ALL CRITICAL findings. Fix ALL HIGH findings.
- Do NOT fix MEDIUM or LOW findings (defer to human review).
- Do NOT push to remote. Local commits only.
- Do NOT create PRs.
- Do NOT modify .claude/ directory except loop-context.md and loop-notes.md.
- Do NOT modify commands/*.md or agents/*.md.
- Read files BEFORE editing. Follow existing codebase patterns.
- If a finding is a false positive, skip it and note: "SKIPPED: {ID} — false positive: {reason}"
```

---

## Step 5: Completion

Read loop-context.md and output:

```
Loop Complete
━━━━━━━━━━━━
Tasks: {completed}/{total} completed, {blocked} blocked
Elapsed: {timing.total_elapsed_s}s
Review: {review_round} round(s) — {review_clean ? "All clear" : "Max rounds reached, some findings may remain"}

Task Commits:
{for each entry in task_commits}
  {entry.status == "done" ? "✓" : "✗"} {entry.commit || "---"} {entry.task}
{/for}

Full diff: git log --oneline {start_commit}..HEAD

{if blocked > 0}
Blocked tasks (manual attention needed):
  - [!] task description
  ...

To revert a specific task: git revert <SHA>
{/if}

{if review_clean}
Ready to ship. Run /ship to commit and create PR.
{else}
Run /review for manual follow-up, then /ship.
{/if}
```

Set `status: complete` in loop-context.md.

---

## Cancel & Resume

- **Cancel:** Ctrl+C. loop-context.md stays with `status: running`.
- **Resume:** `/loop --plan <path>` picks up from first unchecked `[ ]` task. Plan checkboxes are the source of truth.
- **Feature mode** always creates a fresh plan. Use `--plan` to resume a cancelled loop.

---

## Safety Model

`/loop` bypasses AskUserQuestion gates because the user explicitly opted into autonomous execution.

**Autonomous (no human needed):**
- Plan generation and acceptance
- Issue enhancement (if `needs_refinement`)
- Task implementation (one per iteration)
- Test running and fixing
- Full fresh-eyes-review with smart agent selection (up to 14 agents)
- Multi-round review-fix cycles (up to 3 rounds)
- Auto-fix of CRITICAL and HIGH findings
- Local git commits

**NOT autonomous (still requires human):**
- `git push` / PR creation
- Merging
- Deleting files or branches
