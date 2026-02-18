---
name: Coordinated Implementation Guide
description: Reference guide for coordinated multi-task implementation. Covers team role definitions, work decomposition, swarmability assessment, file ownership, and sequential coordination patterns.
alwaysApply: false
---

# Coordinated Implementation Guide

**Purpose:** Reference guide for coordinated multi-task implementation. When a plan has multiple independent tasks, this guide provides patterns for structured decomposition and execution.

---

## When to Use Coordinated Implementation

| Factor | Use Coordinated | Use Standard Sequential |
|--------|----------------|------------------------|
| 3+ independent implementation tasks | Yes | -- |
| Multiple domains (frontend + backend + DB) | Yes | -- |
| Clear file ownership boundaries possible | Yes | -- |
| Simple single-file change | -- | Yes |
| Sequential dependencies throughout | -- | Yes |
| Quick bug fix | -- | Yes |

---

## Roles

### Lead Role
Coordination, monitoring, conflict resolution, task assignment, result synthesis. The Lead decomposes work, defines file ownership boundaries, plans execution order, and tracks progress. See `agents/team/lead.md` for full role definition.

### Implementer Role
Code + tests + validation within file ownership boundaries. Each implementer executes the full pipeline: learnings research, living plan, implementation, tests, validation. See `agents/team/implementer.md` for full role definition.

### Analyst Role
Research support: codebase patterns, past learnings, findings documentation. The Analyst researches the codebase and past learnings proactively, providing context before and during implementation. See `agents/team/analyst.md` for full role definition.

---

## Execution Pattern: Sequential Role-Playing

Since continue.dev operates as a single agent, coordinated implementation means playing each role in turn:

1. **Lead hat:** Decompose work into task groups with exclusive file ownership
2. **Analyst hat:** Research codebase patterns, past learnings, surface findings
3. **Implementer hat (task 1):** Execute first task group following full pipeline
4. **Implementer hat (task 2):** Execute second task group
5. ... (repeat for each task group)
6. **Lead hat:** Verify all tasks complete, synthesize results

---

## Swarmability Assessment Algorithm

Used to determine whether a plan's tasks can be effectively decomposed.

### Step 1: Extract Tasks
Parse the plan's implementation steps. Extract: step description, affected files, dependencies.

### Step 2: Build Independence Matrix

For each pair of tasks (i, j):

| Check | Result |
|-------|--------|
| Do they modify the same files? | File overlap -> partial dependency |
| Does task j depend on task i's output? | Output dependency -> must serialize |
| Do they modify the same data structures/configs/shared types? | Shared state -> partial dependency |
| Are they in different modules/directories? | Module isolation -> likely independent |

### Step 3: Score

```
For each task:
  - No overlap with any other task -> fully independent (score: 1.0)
  - Shares files with 1+ tasks -> partially dependent (score: 0.5)
  - Depends on another task's output -> blocked (score: 0.0)

Swarmability score = sum(task scores) / total tasks x 100
```

### Step 4: Group Tasks

- Fully independent tasks -> each gets its own execution slot
- Partially dependent tasks (shared files) -> group into same execution slot
- Blocked tasks -> serialize after their dependency completes

### Recommendation Thresholds

| Score | Recommendation |
|-------|---------------|
| 70%+ | Recommend coordinated mode |
| 40-69% | Mixed — note which tasks can be independent, which must serialize |
| <40% | Recommend standard sequential mode |

---

## File Ownership Protocol

| Rule | Detail |
|------|--------|
| One owner per file | Each file is assigned to exactly one task group |
| Never modify unowned files | If you need a file outside your boundary, resolve the conflict first |
| New files within boundary only | Create new files only in your assigned directories |
| Interface contracts are immutable | Don't change agreed interfaces without explicit approval |
| When in doubt, stop and resolve | A brief delay beats an integration conflict |

---

## Branch Strategy

All task groups work on the **same feature branch**. The swarmability assessment ensures minimal file overlap — tasks assigned to different groups touch different files.

If two tasks share a file, they're either:
1. Assigned to the same task group (serialized within that group)
2. Serialized across groups (group B waits for group A)

---

## Best Practices

### 1. Size Tasks Appropriately
- Too small: coordination overhead exceeds benefit
- Too large: tasks run too long without verification
- Right size: self-contained units that produce a clear deliverable

### 2. Avoid File Conflicts
- Swarmability assessment identifies overlap before execution
- When conflict occurs: stop, resolve, then continue
- Unresolvable conflicts escalate to user

### 3. Give Each Task Full Context
- Task description includes owned files, acceptance criteria, interface contracts
- Check `docs/solutions/` for past learnings before implementing
- Follow project conventions documentation

### 4. Verify Between Task Groups
- After completing each task group, verify interface contracts are satisfied
- Run tests for completed groups before starting the next
- If a task group fails, decide: fix, rollback, or reassign

### 5. Token Cost Awareness
- Coordinated implementation uses more context than simple sequential work
- The decomposition and verification passes add overhead
- Only use coordinated mode when the complexity justifies it

---

## Output Format

```
Coordinated Implementation — Complete
---

Input: [plan file or issue number]
Tasks completed: [N/N]
Task groups executed: [N]

Summary:
  - [Task group 1]: Completed [task descriptions]. Files: [list]
  - [Task group 2]: Completed [task descriptions]. Files: [list]

Tests: [all passing / N failures]
Validation: [clean / N issues]

Next step: Run code review for all changes.
```
