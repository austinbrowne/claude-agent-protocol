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

**Plan mode:**
1. Verify plan file exists. If not, halt with error.
2. Count `[ ]` tasks. If zero: "Nothing to do — plan already complete" or "All tasks blocked."
3. Create `.claude/loop-context.md` with `plan_path`, task counts, `status: running`

**Issue mode:**
1. Fetch issue: `gh issue view N --json title,body,labels`. If fails, halt with error.
2. If `needs_refinement` label: spawn subagent to enhance issue, re-fetch
3. Spawn subagent to generate plan from issue body
4. Verify plan has `[ ]` tasks, create loop-context.md

### loop-context.md Format

```yaml
---
mode: feature | plan | issue
task: "<description>"
plan_path: "<path>"
tasks_total: 0
tasks_completed: 0
tasks_blocked: 0
max_iterations: 50
review_round: 0
review_max_rounds: 3
review_clean: false
status: running
started_at: "<ISO timestamp>"
start_commit: "<current HEAD sha>"
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
     → (tasks_completed + tasks_blocked) >= tasks_total  → set status "review", break
     → iterations >= max_iterations  → set status "complete", break

  2. Spawn Worker subagent (general-purpose, mode: bypassPermissions)
     with the WORKER PROMPT below

  3. On error/timeout:
     → Read loop-context.md to check if worker made partial progress
     → If no progress: stall_count++
     → If stall_count >= 3: set status "complete", break
     → Continue loop

  4. Read loop-context.md for updated counts
     → Print: "Task {completed}/{total} complete ({blocked} blocked)"
     → Reset stall_count to 0
     → Continue loop
```

### Worker Prompt

Each worker is a `general-purpose` Task subagent spawned with `mode: bypassPermissions`. The prompt:

```
You are implementing ONE task from a development plan. You have ZERO memory
of previous work — read files for ALL context.

## Instructions

1. Read `.claude/loop-context.md` for plan_path
2. Read the plan file at that path
3. Find the FIRST unchecked task (marked with `[ ]`). Skip `[x]` and `[!]`.
4. Implement ONLY that one task:
   a. Read CLAUDE.md for project conventions
   b. Search docs/solutions/ for relevant past learnings
   c. Write the code changes
   d. Write/update tests for changed code
   e. Run tests. If tests fail, fix them (up to 3 attempts).
   f. If tests pass: stage specific files and commit:
      git add <specific files changed>
      git commit -m "feat: <concise task summary>"
   g. ONLY AFTER commit succeeds: check off the task [x] in the plan file
      (Use Edit tool: old_string="- [ ] <full task text>" new_string="- [x] <full task text>")
   h. Update `.claude/loop-context.md`: increment tasks_completed by 1
5. If stuck after 3 test-fix attempts:
   a. Mark the task [!] (blocked) in the plan file
   b. Update `.claude/loop-context.md`: increment tasks_blocked by 1
6. Output a ONE-LINE summary: "DONE: <task>" or "BLOCKED: <task> — <reason>"

## Rules
- ONE task only. Do not implement multiple tasks.
- Commit BEFORE checking [x] — if commit fails, leave task as [ ].
- Do NOT push to remote. Local commits only.
- Do NOT create PRs or modify CI/CD configs.
- Do NOT modify .claude/ directory except loop-context.md.
- Do NOT modify commands/*.md or agents/*.md.
- Use the FULL task line text in Edit old_string to avoid "not unique" errors.
- Read files BEFORE editing. Follow existing codebase patterns.
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

  5. Update loop-context.md: increment review_round
     Print: "Review round {round} fixes committed. Re-reviewing..."
     Continue loop

IF review_round >= review_max_rounds AND NOT review_clean:
  Print: "Review reached max rounds ({review_max_rounds}). Some findings may remain."
  Update loop-context.md: status: complete
```

### Review Worker Prompt

Each review worker is a `general-purpose` Task subagent spawned with `mode: bypassPermissions`. It acts as team lead, spawning review agents as parallel teammates via Agent Teams.

```
You are running a FULL fresh-eyes code review using Agent Teams for parallel
execution. You have ZERO memory of previous work — read files for ALL context.
You are the TEAM LEAD — you coordinate specialists, consolidate, and validate.

## Phase 1: Setup

1. Read `.claude/loop-context.md` for start_commit
2. Generate the diff: run `git diff {start_commit}..HEAD` and save to /tmp/review-diff.txt
3. Generate the file list: run `git diff --name-only {start_commit}..HEAD`
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
- Do NOT modify .claude/ directory except loop-context.md.
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
Review: {review_round} round(s) — {review_clean ? "All clear" : "Max rounds reached, some findings may remain"}
Commits: (git log --oneline {start_commit}..HEAD)

{if blocked > 0}
Blocked tasks (manual attention needed):
  - [!] task description
  ...
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
