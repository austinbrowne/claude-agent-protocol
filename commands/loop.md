---
name: workflows:loop
description: "Autonomous development loop with context rotation via Task subagents"
argument-hint: "<description | --plan PATH | --issue N> [--max-iterations N]"
---

# /loop — Autonomous Development Loop

**Workflow command.** Autonomous plan-and-implement loop using Task subagents for context rotation. Each worker gets fresh context and reads files for state. No external plugin dependencies.

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
  ├── Spawn Review worker (lite: Security + Edge Case + Supervisor)
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
review_done: false
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

When Level 0 sees `status: review`:

1. Read `start_commit` from loop-context.md
2. Spawn a `general-purpose` Task subagent (mode: bypassPermissions) with instructions:
   - Generate diff: `git diff {start_commit}..HEAD`
   - Run lite fresh-eyes-review: Security + Edge Case reviewers (sequential)
   - Auto-fix CRITICAL and HIGH findings
   - Commit fixes if any
3. Update loop-context.md: `review_done: true`, `status: complete`

---

## Step 5: Completion

Read loop-context.md and output:

```
Loop Complete
━━━━━━━━━━━━
Tasks: {completed}/{total} completed, {blocked} blocked
Commits: (git log --oneline {start_commit}..HEAD)
Review: {review_done ? "Lite review passed" : "Skipped"}

{if blocked > 0}
Blocked tasks (manual attention needed):
  - [!] task description
  ...
{/if}

Next: /review for full fresh-eyes review, then /ship to commit and PR.
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
- Lite code review (Security + Edge Case + Supervisor)
- Auto-fix of CRITICAL and HIGH findings
- Local git commits

**NOT autonomous (still requires human):**
- `git push` / PR creation
- Merging
- Full 14-agent review (user runs `/review` after loop)
- Deleting files or branches
