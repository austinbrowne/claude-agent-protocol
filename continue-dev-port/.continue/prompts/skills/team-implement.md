---
name: team-implement
description: "Plan-based sequential implementation -- swarmability assessment, task decomposition, and persona-based execution for approved plans"
---

# Team Implement Skill

Assess an approved plan for implementation, decompose into task groups, and execute sequentially with persona-based processing. For issue-based implementation (any complexity), use `/start-issue` instead.

> **Note on parallel execution:** The original Claude Code version of this skill uses Agent Teams for parallel teammate spawning. In continue.dev, this is adapted to sequential persona-based processing -- each task group is executed one at a time with the appropriate persona context (Lead, Analyst, Implementer). The swarmability assessment is still performed to inform task grouping and ordering.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has a mandatory interaction gate. You MUST hit it. NEVER skip it. NEVER replace it with prose or skip ahead.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Implementation Mode** | Step 3 | Sequential / Adjust | Implementation started without consent -- UNACCEPTABLE |

**If you find yourself asking the user what to do next without presenting numbered options, STOP. You are violating the protocol.**

---

## When to Apply

- After a plan is approved and ready for implementation
- Plan has multiple implementation tasks
- User wants structured, decomposed execution

---

## Prerequisites

- Plan file with status `approved` or `ready_for_review`

---

## Process

### Step 1: Load Plan

**If plan path provided or referenced in conversation:**
- Read the specified plan file
- Extract: Implementation Steps, Affected Files per step, Dependencies between steps

**If no plan path:**
1. Check conversation for most recent plan reference
2. If not found, search for plan files in `docs/plans/` -- read YAML frontmatter and filter out `status: complete` plans. Only show active (non-complete) plans.
3. Ask user to specify

### Step 2: Swarmability Assessment

Analyze all implementation tasks for independence. This assessment informs task grouping and execution order even in sequential mode.

**For each pair of tasks (i, j), check:**

| Check | Result |
|-------|--------|
| Do they modify the same files? | File overlap -> partial dependency |
| Does task j depend on task i's output? | Output dependency -> must serialize |
| Do they modify the same data structures, configs, or shared types? | Shared state -> partial dependency |
| Are they in different modules/directories? | Module isolation -> likely independent |

**Score each task:**
- No overlap with any other task -> fully independent (1.0)
- Shares files with 1+ tasks -> partially dependent (0.5)
- Depends on another task's output -> blocked (0.0)

**Calculate swarmability score:**
```
Swarmability = sum(task_scores) / total_tasks x 100
```

**Group tasks:**
- Fully independent -> each gets its own execution pass
- Partially dependent (shared files) -> group into same execution pass
- Blocked -> serialize after dependency completes

**Determine composition:**

| Swarmability | Composition |
|-------------|-------------|
| 70%+ | N independent task groups (pure sequential, any order) |
| 40-69% | N task groups + Analyst pass first (analyst researches before implementers) |
| <40% | Strictly ordered sequential execution |

### Step 3: Present Assessment -- MANDATORY GATE

**STOP. You MUST present the assessment and get explicit approval. NEVER begin implementation without user consent.**

```
Team Implement -- Assessment
==============================

Plan: [filename]
Total implementation tasks: [N]
Swarmability score: [X]%

Task Groups:
  Group 1: [task descriptions] -- files: [list]
  Group 2: [task descriptions] -- files: [list]
  Group 3 (after Group 1): [task descriptions] -- files: [list]

Analyst pass: [Yes -- mixed independence / No -- pure independent]
Independent groups: [N] (can run in any order)
Serialized tasks: [N] (must wait for dependencies)
```

Present the following options:

1. **Sequential implementation** -- Execute task groups one at a time in optimal order
2. **Adjust composition** -- I want to change the task grouping

**WAIT** for user response before continuing.

**Recommendation thresholds:**
- Swarmability 70%+ -> Note: "Task groups are independent; order is flexible"
- 40-69% -> Note: "Some dependencies exist; analyst pass recommended first"
- <40% -> Note: "Heavy dependencies; strict ordering required"

**If "Sequential implementation":** Proceed to Step 4.
**If "Adjust composition":** Ask what changes. Update composition. Re-present Step 3.

### Step 4: Execute Implementation

#### 4a. Status Updates

**Plan status update:** Read the plan file's YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only -- do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

**Issue status update:** If issue input:
```bash
gh issue edit NNN --add-assignee @me --remove-label "ready_for_dev" --add-label "status: in-progress"
```

> Note: Use `glab` for GitLab repositories.
> Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

#### 4b. Analyst Pass (if composition includes Analyst)

Adopt the **Analyst persona** and perform research across all task groups:

- Read project conventions and configuration
- Search `docs/solutions/` for relevant past learnings
- Identify cross-cutting concerns, shared types, and integration points
- Document findings that each task group will need

Present analyst findings before proceeding to implementation.

#### 4c. Execute Task Groups

For each task group (in dependency order):

Adopt the **Implementer persona** for this group. For each task group, follow the FULL protocol pipeline:

1. **Read conventions** -- Check project conventions and configuration
2. **Search learnings** -- Search `docs/solutions/` for relevant past solutions
3. **Create living plan** -- `.todos/{task-group}-plan.md` using `templates/LIVING_PLAN_TEMPLATE.md`
4. **Implement** -- Write code following existing patterns and conventions. Respect file ownership boundaries from the assessment.
5. **Test** -- Generate and run tests:
   - Happy path tests for each acceptance criterion
   - Edge case tests (null, empty, boundaries)
   - Error condition tests
6. **Validate** -- Run linter, type checker, and full test suite

Commit after each task group completes:
- Intermediate groups: `Part of #NNN` (if issue-linked)
- Final group: `Closes #NNN` (if issue-linked)

**For serialized tasks:** Only begin after their dependency group completes.

### Step 5: Present Results

```
Team Implement -- Complete
============================

Input: [plan file or issue #NNN]
Tasks completed: [N/N]
Task groups executed: [N]

Summary:
  - Group 1: Completed [task descriptions]. Files: [list]
  - Group 2: Completed [task descriptions]. Files: [list]
  - Analyst: Research findings applied to [N] groups.

Tests: [all passing / N failures]
Validation: [clean / N issues]

Next step: Run /review for fresh-eyes review of all changes.
```

Suggest the user proceed to `/review` for fresh-eyes review of the combined diff.

---

## Notes

- **Full protocol per task group.** Each task group gets learnings search, living plan, tests, and validation. No shortcuts.
- **Analyst is optional.** Pure independent plans (70%+ swarmability) skip the analyst -- task groups are independent. Complex or mixed plans get an analyst pass.
- **Branch strategy.** All task groups work on the same branch. Assessment ensures minimal file overlap.
- **Fresh-eyes review happens AFTER.** Individual task groups validate their own work. Holistic review happens at `/review` on the combined diff.
- **Sequential persona-based processing.** In continue.dev, this replaces Claude Code's parallel Agent Teams. The swarmability assessment still determines optimal task ordering and grouping.
- **Max task groups.** For very large plans, consider breaking into phases rather than running all groups in one session.

---

## Integration Points

- **Input**: Approved plan file from `docs/plans/`
- **Output**: Implemented code with tests, ready for `/review`
- **Followed by**: `/review` (fresh-eyes-review on combined diff)
