---
name: workflows:loop
description: "Autonomous development loop — iterates plan tasks with Ralph Wiggum context rotation"
argument-hint: "<description | --plan PATH | --issue N> [--max-iterations N]"
---

# /loop — Autonomous Development Loop

**Workflow command.** Autonomous plan-and-implement loop using Ralph Wiggum for context rotation. Each iteration gets fresh context and reads plan file checkboxes for state.

**Requires:** `ralph-wiggum` plugin (`/install ralph-wiggum`)

---

## Prerequisites

### Check 1: Ralph Wiggum Plugin

Verify `/ralph-wiggum:ralph-loop` is available in your skill/tool list.

**If NOT available**, halt immediately:

```
HALT_PENDING_DECISION

The `/loop` command requires the `ralph-wiggum` plugin for context rotation.

Install it:
  /install ralph-wiggum

Then re-run your `/loop` command.
```

### Check 2: Arguments

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

Cancel anytime: /ralph-wiggum:cancel-ralph
```

Extract `--max-iterations` if provided (default: 50).

---

## Setup Phase (Before Ralph Loop)

### Create Loop Context File

Create `.claude/loop-context.md` based on input mode:

**Feature mode:**
```markdown
---
mode: feature
task: "<user's description>"
plan_path: null
issue_number: null
review_done: false
started_at: "<ISO timestamp>"
---

<user's full task description>
```

**Plan mode:**
```markdown
---
mode: plan
task: "Iterate tasks from existing plan"
plan_path: "<provided path>"
issue_number: null
review_done: false
started_at: "<ISO timestamp>"
---

Iterating tasks from: <provided path>
```

**Issue mode:**
```markdown
---
mode: issue
task: "<issue title>"
plan_path: null
issue_number: <N>
review_done: false
started_at: "<ISO timestamp>"
---

<issue body fetched via gh issue view N>
```

### Issue Mode: Enhance If Needed

For issue mode only — before starting the Ralph loop:

1. Check if the issue has the `needs_refinement` label: `gh issue view N --json labels`
2. If yes, run `skills/enhance-issue/SKILL.md` inline with auto-accept decisions to flesh out the issue
3. Re-fetch the issue body and update `.claude/loop-context.md`

This runs BEFORE the loop to get full context for enhancement.

---

## Start Ralph Loop

Invoke the ralph-wiggum plugin:

```
/ralph-wiggum:ralph-loop "<state-machine-prompt>" --completion-promise "LOOP_COMPLETE" --max-iterations {N}
```

The state machine prompt below is what Ralph re-injects each iteration. The agent has **zero memory** of previous iterations — it reads files for all state.

---

## State Machine Prompt

```
You are running an autonomous development loop. Read .claude/loop-context.md for the task.

## State Machine — Follow in Order

### Phase 1: Plan
Read .claude/loop-context.md for plan_path.
- If plan_path is null or the file doesn't exist:
  → Generate a plan using skills/generate-plan/SKILL.md methodology (Standard tier).
  → AUTO-ACCEPT the plan (skip the AskUserQuestion gate).
  → Save to docs/plans/YYYY-MM-DD-standard-{slug}-plan.md
  → Update .claude/loop-context.md with plan_path.
  → STOP HERE for this iteration. Do not continue to Phase 2.

### Phase 2: Implement Next Task
Read the plan file. Find the FIRST unchecked task (marked with [ ]).
- If unchecked tasks exist:
  → Implement ONLY the first unchecked task.
  → Follow existing codebase patterns. Write/update tests for changed code.
  → Run tests for the affected code. If tests fail, fix them (up to 3 attempts).
  → If tests pass: check off the task [x] in the plan file.
  → Stage and commit: git add <specific files> && git commit -m "feat: <task summary>"
  → STOP HERE for this iteration. Do not continue to Phase 3.
- If no [ ] tasks remain (all are [x] or [!]):
  → Continue to Phase 3.

### Phase 3: Review
Read .claude/loop-context.md for review_done.
- If review_done is false:
  → Run lite fresh-eyes-review (Security + Edge Case + Supervisor only).
  → Auto-fix CRITICAL and HIGH findings. Defer MEDIUM/LOW.
  → Commit fixes if any.
  → Update .claude/loop-context.md: review_done: true
  → STOP HERE for this iteration.
- If review_done is true:
  → Continue to Phase 4.

### Phase 4: Complete
Output a summary of all work done, then output:
<promise>LOOP_COMPLETE</promise>

## Rules
- ONE task per iteration. Do not implement multiple tasks in one pass.
- Commit after EACH task. Small, atomic commits.
- Do NOT push to remote. Local commits only.
- Do NOT create PRs.
- Do NOT modify: .claude/ directory (except loop-context.md and plan files), CI/CD configuration, deployment scripts, commands/*.md, or agents/*.md.
- If stuck on a task after 3 test-fix attempts, mark it [!] (blocked) and move to the next task.
- Skip [!] (blocked) tasks — they are not [ ] (unchecked). When no [ ] tasks remain, proceed to Phase 3 regardless of [!] count.
- Read .claude/loop-context.md and the plan file FIRST every iteration.
```

---

## Safety Model

`/loop` deliberately bypasses AskUserQuestion gates because the user explicitly opted into autonomous execution by invoking this command.

### Autonomous (no human needed)

- Plan generation and acceptance
- Issue enhancement (if `needs_refinement`)
- Task implementation (one per iteration)
- Test running and fixing
- Lite code review (3 agents: Security, Edge Case, Supervisor)
- Auto-fix of CRITICAL and HIGH findings
- Local git commits

### NOT Autonomous (still requires human)

- `git push` / PR creation
- Merging
- Full 14-agent review (user runs `/review` after loop)
- Deleting files or branches

### Cancel Anytime

```
/ralph-wiggum:cancel-ralph
```

Re-running `/loop` after cancellation picks up where it left off — it reads plan file checkboxes and `.claude/loop-context.md` for state.

---

## Key Design Decisions

1. **One task per iteration.** Each task gets its own clean context window. Prevents context pollution. A 14-task plan = 14+ iterations, each with fresh context.

2. **Plan file as state tracker.** Checkboxes (`[ ]` / `[x]`) track progress. No separate state database. Human-readable at all times.

3. **Loop context file.** `.claude/loop-context.md` stores mode, plan path, and review status. Survives context rotation.

4. **Issue enhancement before loop.** Runs BEFORE Ralph starts so it gets full context for the enhancement conversation.

5. **Lite review only.** 3 agents (Security, Edge Case, Supervisor) not 14. Keeps autonomous loops fast. User runs full `/review` after if desired.

6. **Blocked task marker.** `[!]` for tasks that fail after 3 attempts. Loop skips them and continues. User handles blocked tasks manually after.
