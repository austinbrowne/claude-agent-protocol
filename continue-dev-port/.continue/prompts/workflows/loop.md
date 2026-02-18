---
name: loop
description: "Autonomous development loop — iterates plan tasks sequentially with review cycles"
invokable: true
---

# /loop — Autonomous Development Loop

Autonomous plan-and-implement loop. Each task is implemented sequentially within the current context. State is tracked via plan checkboxes and `loop-context.md`.

> **Limitation:** Unlike the Claude Code version, this runs in a single context window without context rotation. For large plans, context may grow significantly. Consider breaking large plans into smaller batches.

{{{ input }}}

---

## Step 1: Parse Arguments

Parse the user's input:

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

Cancel: Stop the loop at any time. Re-run with --plan to resume from where you left off.
```

Extract `--max-iterations` if provided (default: 50).

---

## Step 2: Setup Phase

Runs ONCE before entering the implementation loop.

### Stale Loop Detection

If `.claude/loop-context.md` exists with `status: running`:
- `started_at` < 30 minutes ago — Ask the user: "A loop appears to be running (started {time}). Override and start fresh?" Wait for confirmation before proceeding.
- `started_at` > 30 minutes ago — treat as stale, overwrite

### Mode-Specific Setup

**Feature mode:**
1. Create `.claude/loop-context.md` (see format below)
2. Generate a plan (Standard tier, using `/generate-plan` methodology). Auto-accept — user opted into autonomous mode.
3. Verify the generated plan has at least one `[ ]` checkbox task. If not, halt with error.
4. Count `[ ]` tasks, update loop-context.md: set `plan_path`, `tasks_total`, `status: running`
5. Read the plan file's YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

**Plan mode:**
1. Verify plan file exists. If not, halt with error.
2. Count `[ ]` tasks. If zero: "Nothing to do — plan already complete" or "All tasks blocked."
3. Create `.claude/loop-context.md` with `plan_path`, task counts, `status: running`
4. Read the plan file's YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

**Issue mode:**
1. Fetch issue: Use `gh` (GitHub) or `glab` (GitLab) depending on the platform. Run the equivalent of `gh issue view N --json title,body,labels`. If it fails, halt with error. Adjust command syntax for PowerShell on Windows.
2. If `needs_refinement` label: enhance the issue, re-fetch
3. Generate a plan from the issue body
4. Verify plan has `[ ]` tasks, create loop-context.md
5. Read the plan file's YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

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

## Step 3: Sequential Implementation Loop

This is the core loop. Process each task one at a time within the current context.

```
stall_count = 0
iteration = 0

WHILE true:
  1. Read .claude/loop-context.md
     - status == "complete"  -> break to Step 5 (Completion)
     - status == "review"    -> break to Step 4 (Review)
     - (tasks_completed + tasks_blocked) >= tasks_total -> set status "review", break
     - iteration >= max_iterations -> set status "complete", break

  2. Read the plan file at plan_path
     Find the FIRST unchecked task (marked with [ ]). Skip [x] and [!].

  3. Implement that ONE task:
     a. Search docs/solutions/ for relevant past learnings
     b. Write the code changes
     c. Write/update tests for changed code
     d. Run tests in the terminal. If tests fail, fix them (up to 3 attempts).
        Adjust command syntax for PowerShell on Windows.
     e. If tests pass: stage specific files and commit:
        git add <specific files changed>
        git commit -m "feat: <concise task summary>"
     f. ONLY AFTER commit succeeds: check off the task [x] in the plan file
     g. Update .claude/loop-context.md: increment tasks_completed by 1

  4. If stuck after 3 test-fix attempts:
     a. Mark the task [!] (blocked) in the plan file
     b. Update .claude/loop-context.md: increment tasks_blocked by 1

  5. Print progress: "Task {completed}/{total} complete ({blocked} blocked)"
     increment iteration
     Continue loop
```

### Rules for Each Task
- ONE task only per iteration. Do not implement multiple tasks at once.
- Commit BEFORE checking [x] — if commit fails, leave task as [ ].
- Do NOT push to remote. Local commits only.
- Do NOT create PRs or modify CI/CD configs.
- Read files BEFORE editing. Follow existing codebase patterns.

---

## Step 4: Review Phase

Sequential review cycle. Review the full diff, fix findings, re-review until clean or max rounds reached.

```
WHILE review_round < review_max_rounds:
  1. Read .claude/loop-context.md
     - review_clean == true -> break (already clean)

  2. Run a full review of all changes since start_commit:
     Generate the diff: git diff {start_commit}..HEAD
     Review through each specialist persona sequentially:
     - Core (always): Security, Code Quality, Edge Case
     - Conditional (only if triggered by diff content): Performance, API Contract,
       Concurrency, Error Handling, Data Validation, Dependency, Testing Adequacy,
       Config & Secrets, Documentation

     For each persona, check the diff against that persona's specific concerns.
     Output findings in format: [{SEVERITY}] {ID}: {description} ({file}:{line})

  3. Consolidate findings:
     - Remove duplicates (same file:line, same issue)
     - Validate CRITICAL and HIGH findings — is this exploitable or theoretical?
     - Drop false positives

  4. If no CRITICAL/HIGH findings:
     Update loop-context.md: review_clean: true, status: complete
     Break

  5. If CRITICAL or HIGH findings exist:
     Print: "Review round {round}: {N} findings to fix"
     Fix each CRITICAL finding first, then each HIGH finding:
       a. Read the referenced file
       b. Implement the fix following existing codebase patterns
       c. Write/update tests if the fix changes behavior
     Run tests. If tests fail, fix them (up to 3 attempts).
     Stage and commit: git commit -m "fix: address review findings — {brief summary}"

  6. Update loop-context.md: increment review_round
     Print: "Review round {round} fixes committed. Re-reviewing..."
     Continue loop

IF review_round >= review_max_rounds AND NOT review_clean:
  Print: "Review reached max rounds ({review_max_rounds}). Some findings may remain."
  Update loop-context.md: status: complete
```

---

## Step 5: Completion

Read loop-context.md and output:

```
Loop Complete
---
Tasks: {completed}/{total} completed, {blocked} blocked
Review: {review_round} round(s) — {review_clean ? "All clear" : "Max rounds reached, some findings may remain"}
Commits: (run: git log --oneline {start_commit}..HEAD)

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

- **Cancel:** Stop the loop at any time. loop-context.md stays with `status: running`.
- **Resume:** `/loop --plan <path>` picks up from the first unchecked `[ ]` task. Plan checkboxes are the source of truth.
- **Feature mode** always creates a fresh plan. Use `--plan` to resume a cancelled loop.

---

## Safety Model

`/loop` bypasses interactive confirmation gates because the user explicitly opted into autonomous execution.

**Autonomous (no human needed):**
- Plan generation and acceptance
- Issue enhancement (if `needs_refinement`)
- Task implementation (one per iteration)
- Test running and fixing
- Full review with sequential specialist personas
- Multi-round review-fix cycles (up to 3 rounds)
- Auto-fix of CRITICAL and HIGH findings
- Local git commits

**NOT autonomous (still requires human):**
- `git push` / PR creation
- Merging
- Deleting files or branches
