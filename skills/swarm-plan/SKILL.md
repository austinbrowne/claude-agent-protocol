---
name: swarm-plan
version: "1.0"
description: Parallel implementation of plan tasks using Agent Teams with swarmability assessment
referenced_by:
  - commands/implement.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Swarm Plan Skill

Analyze a plan's implementation tasks for parallelizability, form an implementation team, and execute independent tasks in parallel — each teammate following the full protocol pipeline.

---

## When to Apply

- After a plan is approved and ready for implementation
- Plan has multiple implementation steps that may be independent
- Agent Teams is enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)
- User wants to explore parallel execution vs standard sequential

---

## Prerequisites

- Plan file exists with status `approved` or `ready_for_review`
- Agent Teams is available (TeammateTool in tool list)
- If TeammateTool is NOT available, inform user and suggest standard `/implement` → `start-issue` instead

---

## Process

### Step 1: Load Plan

**If path provided:**
- Read specified plan file

**If no path:**
- Check conversation for most recent plan reference
- If not found, list available plans: `ls docs/plans/*.md`
- Ask user to select

**Extract from plan:**
- Implementation Steps (numbered list)
- Affected Files (per step if available, otherwise from Affected Files section)
- Dependencies between steps (explicit "after step N" or implicit from file overlap)

### Step 2: Swarmability Assessment

Analyze all implementation tasks for independence.

**For each pair of tasks (i, j), check:**

| Check | Result |
|-------|--------|
| Do they modify the same files? | File overlap → partial dependency |
| Does task j depend on task i's output? | Output dependency → must serialize |
| Do they modify the same data structures, configs, or shared types? | Shared state → partial dependency |
| Are they in different modules/directories? | Module isolation → likely independent |

**Score each task:**
- No overlap with any other task → fully independent (1.0)
- Shares files with 1+ tasks → partially dependent (0.5)
- Depends on another task's output → blocked (0.0)

**Calculate swarmability score:**
```
Swarmability = sum(task_scores) / total_tasks × 100
```

**Group tasks:**
- Fully independent tasks → each gets its own teammate
- Partially dependent tasks (shared files) → group into same teammate
- Blocked tasks → serialize after their dependency completes

### Step 3: Present Assessment

```
Swarm Plan Assessment
━━━━━━━━━━━━━━━━━━━━

Plan: [filename]
Total implementation tasks: [N]
Swarmability score: [X]%

Task Groups:
  Group 1 (teammate-1): [task descriptions] — files: [list]
  Group 2 (teammate-2): [task descriptions] — files: [list]
  Group 3 (serialized after Group 1): [task descriptions] — files: [list]

Independent groups: [N] (can run in parallel)
Serialized tasks: [N] (must wait for dependencies)
```

```
AskUserQuestion:
  question: "Swarmability assessment complete. How would you like to implement?"
  header: "Swarm mode"
  options:
    - label: "Team mode"
      description: "Score: {X}%. {N} teammates for {Y} independent groups, {Z} serialized"
    - label: "Standard sequential"
      description: "Execute all tasks one at a time (current behavior)"
    - label: "Adjust groupings"
      description: "I want to change which tasks are grouped together"
```

**Recommendation thresholds:**
- 70%+ → Add "(Recommended)" to Team mode label
- 40-69% → Neutral — present both options equally
- <40% → Add "(Recommended)" to Standard sequential label

**If "Team mode":** Proceed to Step 4.
**If "Standard sequential":** Inform user to use `/implement` → `start-issue` for each task. End skill.
**If "Adjust groupings":** Ask user which tasks to regroup, update groupings, re-present Step 3.

### Step 4: Spawn Implementation Team

1. Create a shared task list with all task groups:
   - Independent groups: unblocked, ready for claiming
   - Serialized tasks: blocked by their dependencies

2. Spawn one teammate per independent task group:

**Implementer teammate spawn prompt:**
```
You are implementing a task group from an approved plan. Follow the FULL protocol pipeline — do not skip any step.

Your assigned tasks:
[task descriptions for this group]

Affected files:
[file list for this group]

Plan reference: [plan file path]

Protocol pipeline (follow ALL steps in order):
1. Search docs/solutions/ for past learnings relevant to your tasks
2. Create a living plan at .todos/[group-id]-plan.md tracking your tasks
3. Implement the code changes for each task in your group
4. Generate tests for your changes (happy path + edge cases + error conditions)
5. Run validation: lint, type-check, all tests pass
6. When ALL tasks in your group are done, mark them complete in the task list

Rules:
- Do NOT modify files outside your assigned list unless absolutely necessary
- If you need to modify a shared file, message the Lead FIRST and wait for approval
- If you discover a blocker, message the Lead immediately — don't try to work around it
- If you finish early, check the task list for unblocked tasks to claim
- Message other teammates only for conflict resolution, not general chat

Project context:
- Read CLAUDE.md for project conventions and coding standards
- Check docs/solutions/ for past learnings BEFORE writing code
- Follow existing patterns in the codebase — don't invent new conventions
```

3. For serialized tasks: Lead monitors the task list. When a dependency completes, the blocked task becomes unblocked. Either an existing idle teammate claims it, or the Lead spawns a new teammate.

### Step 5: Monitor Progress

While teammates work:

1. **Watch the shared task list** for completion updates
2. **Handle blockers:** If a teammate messages about a blocker:
   - Try to resolve it (provide context, suggest approach)
   - If unresolvable, escalate to user
3. **Handle file conflicts:** If two teammates need the same file:
   - Determine which change should go first
   - Message the second teammate to wait
   - After the first completes, message the second to proceed
4. **Handle stuck teammates:** If a task hasn't progressed:
   - Message the teammate: "Status update on [task]?"
   - If no response, consider spawning a replacement

### Step 6: Completion

When all tasks are complete:

1. Shut down all teammates and clean up the team
2. Present a summary:

```
Swarm Plan — Complete
━━━━━━━━━━━━━━━━━━━━

Plan: [filename]
Tasks completed: [N/N]
Teammates used: [N]

Summary:
  - [teammate-1]: Completed [task descriptions]. Files: [list]
  - [teammate-2]: Completed [task descriptions]. Files: [list]

Tests: [all passing / N failures]
Validation: [clean / N issues]

Next step: Run /review for fresh-eyes review of all changes.
```

3. Suggest the user proceed to `/review` for fresh-eyes review of the combined diff.

---

## Notes

- **Full protocol per teammate:** Each teammate searches learnings, creates a living plan, writes tests, and runs validation. No shortcuts.
- **Branch strategy:** All teammates work on the same branch. Swarmability assessment ensures minimal file overlap.
- **Fresh-eyes review happens AFTER:** Individual teammates do their own validation, but the holistic code review happens at the `/review` step on the combined diff.
- **Token cost:** Each teammate is a full Claude Code instance. Cost scales with team size. This is worthwhile for plans with high parallelism.
- **Requires Agent Teams:** This skill requires the TeammateTool. Without it, use standard `/implement` → `start-issue` for sequential execution.

---

## Integration Points

- **Input**: Approved plan file from `docs/plans/`
- **Output**: Implemented code with tests, ready for `/review`
- **Guide**: `guides/AGENT_TEAMS_GUIDE.md` (Pattern C: Implementation Swarm)
- **Consumed by**: `/implement` workflow command
- **Followed by**: `/review` (fresh-eyes-review on combined diff)
