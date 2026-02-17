---
name: team-implement
version: "1.0"
description: Plan-based team implementation — swarmability assessment, team composition, and parallel execution for approved plans
referenced_by:
  - commands/implement.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Team Implement Skill

Assess an approved plan for team-based implementation, compose the right team from defined roles (Lead, Analyst, Implementer), and execute with coordination. For issue-based implementation (any complexity), use `start-issue` instead.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has a mandatory AskUserQuestion gate. You MUST hit it. NEVER skip it. NEVER replace it with a plain text question.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Team Composition** | Step 3 | Team mode / Sequential / Adjust | Team spawned without consent — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- After a plan is approved and ready for implementation
- Plan has multiple implementation tasks that benefit from parallelism
- Agent Teams is enabled (`TeamCreate` tool available)

---

## Prerequisites

- Plan file with status `approved` or `ready_for_review`
- Agent Teams is available (`TeamCreate` tool in tool list)
- If `TeamCreate` tool is NOT available, inform user: "Agent Teams is not enabled. Use `/implement` → `start-issue` for issue-based implementation, or enable Agent Teams with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`."

---

## Process

### Step 0: Detect Execution Mode

**CRITICAL: Check your tool list RIGHT NOW. Do NOT use conversation history to decide. Each skill invocation re-evaluates independently.**

Check if the `TeamCreate` tool is available in your tool list.
- Available: Continue with this skill
- Not available: HALT. Inform user that Agent Teams is required for this skill. Suggest `/implement` → `start-issue` instead.

### Step 1: Load Plan

**If plan path provided or referenced in conversation:**
- Read specified plan file
- Extract: Implementation Steps, Affected Files per step, Dependencies between steps

**If no plan path:**
1. Check conversation for most recent plan reference
2. If not found, check for plans: `Glob docs/plans/*.md` — read YAML frontmatter and filter out `status: complete` plans. Only show active (non-complete) plans.
3. Ask user to specify

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
- Fully independent → each gets its own Implementer teammate
- Partially dependent (shared files) → group into same Implementer
- Blocked → serialize after dependency completes

**Determine composition:**

| Swarmability | Composition |
|-------------|-------------|
| 70%+ | Lead + N Implementers (pure parallel) |
| 40-69% | Lead + Analyst + N Implementers (analyst supports complex tasks) |
| <40% | Recommend sequential implementation instead |

### Step 3: Present Assessment — MANDATORY GATE

**STOP. You MUST present the assessment and get explicit approval via AskUserQuestion. NEVER spawn a team without user consent.**

```
Team Implement — Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━

Plan: [filename]
Total implementation tasks: [N]
Swarmability score: [X]%

Task Groups:
  Group 1 (implementer-1): [task descriptions] — files: [list]
  Group 2 (implementer-2): [task descriptions] — files: [list]
  Group 3 (serialized after Group 1): [task descriptions] — files: [list]

Analyst: [Yes — mixed independence / No — pure parallel]
Independent groups: [N] (can run in parallel)
Serialized tasks: [N] (must wait for dependencies)
```

```
AskUserQuestion:
  question: "Assessment complete. How would you like to implement?"
  header: "Team mode"
  options:
    - label: "Team mode"
      description: "[composition summary: N teammates, analyst yes/no]"
    - label: "Sequential"
      description: "Implement tasks one at a time without a team"
    - label: "Adjust composition"
      description: "I want to change the team makeup"
```

**Recommendation thresholds:**
- Swarmability 70%+ → Add "(Recommended)" to Team mode label
- 40-69% → Neutral
- <40% → Add "(Recommended)" to Sequential label

**If "Team mode":** Proceed to Step 4.
**If "Sequential":** Inform user the plan tasks will be implemented one at a time. Iterate through each task group sequentially — for each, follow the same protocol pipeline (CLAUDE.md, learnings, living plan, code, tests, validate). End skill after all tasks complete.
**If "Adjust composition":** Ask what changes. Update composition. Re-present Step 3.

### Step 4: Spawn Team Lead

**CRITICAL: The main agent does NOT act as Team Lead. Spawn a dedicated Team Lead agent via the Task tool. This preserves the main agent's context window for user interaction — team coordination overhead stays in the Lead's context.**

**4a. Status updates (before spawning Lead):**

**Plan status update:** Read the plan file's YAML frontmatter `status:` field (if plan input). Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only — do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

**Issue status update:** If issue input:
```bash
gh issue edit NNN --add-assignee @me --remove-label "ready_for_dev" --add-label "status: in-progress"
```

**4b. Read role definitions:**

Read the following files and inline their content into the Team Lead's spawn prompt:
- `agents/team/lead.md`
- `agents/team/implementer.md`
- `agents/team/analyst.md` (if composition includes an Analyst)

**4c. Spawn Team Lead:**

Launch a single `godmode:team:team-lead` agent via the Task tool. The Team Lead creates the team, spawns teammates, monitors progress, and returns consolidated results. The main agent waits for the result.

```
Task(
  subagent_type="godmode:team:team-lead",
  model="opus",
  prompt="""You are the Team Lead for an implementation team.

YOUR ROLE DEFINITION:
[inline content from agents/team/lead.md]

IMPLEMENTER ROLE DEFINITION (include in every implementer spawn prompt):
[inline content from agents/team/implementer.md]

[If analyst included:]
ANALYST ROLE DEFINITION (include in analyst spawn prompt):
[inline content from agents/team/analyst.md]

== CONTEXT ==

[For plan input:]
Plan file: [path]
Plan content:
[full plan content]

[For issue input:]
Issue: #NNN — [title]
[issue body]

== ASSESSMENT RESULTS ==

Team composition: [from Step 3]
Task groups:
  Group 1 (implementer-1): [tasks] — files: [list]
  Group 2 (implementer-2): [tasks] — files: [list]
  [...]
Analyst: [Yes/No]
Independent groups: [N]
Serialized tasks: [N]

== INSTRUCTIONS ==

1. Create a team via TeamCreate
2. Create the shared task list (independent groups start unblocked, serialized tasks blocked by dependencies)
3. Spawn Analyst (if included) as a teammate (model: "sonnet") — include their role definition, plan/issue context, and affected areas in the spawn prompt
4. Spawn Implementer(s) as teammates (model: "sonnet") — one per task group. Include in each spawn prompt: their role definition, task description, owned files (EXCLUSIVE), and plan/issue reference
5. Monitor progress: watch task list, handle blockers, resolve file conflicts, relay analyst findings
6. For serialized tasks: when dependencies complete, either assign to an idle teammate or spawn a new implementer
7. When all tasks complete: shut down all teammates, clean up the team
8. Return a consolidated summary in your output format

Rules:
- Each Implementer follows the FULL protocol pipeline: read CLAUDE.md, search docs/solutions/, create living plan, implement, test, validate
- File ownership is EXCLUSIVE — no overlaps between implementers
- If a teammate needs a file outside their boundary, they message you first
- 2-4 teammates maximum. For larger plans, run in waves.
- Broadcast sparingly — prefer direct messages
- Model tiers for teammate spawns: Implementers = sonnet, Analyst = sonnet
""")
```

### Step 5: Present Results

The Team Lead returns a consolidated summary. Present it to the user:

```
Team Implement — Complete
━━━━━━━━━━━━━━━━━━━━━━━━

Input: [plan file or issue #NNN]
Tasks completed: [N/N]
Teammates used: [N] ([N] implementers, [0-1] analyst)

Summary:
  - [implementer-1]: Completed [task descriptions]. Files: [list]
  - [implementer-2]: Completed [task descriptions]. Files: [list]
  - [analyst]: Research broadcasts: [N]. On-demand requests: [N].

Tests: [all passing / N failures]
Validation: [clean / N issues]

Next step: Run /review for fresh-eyes review of all changes.
```

Suggest the user proceed to `/review` for fresh-eyes review of the combined diff.

---

## Notes

- **Full protocol per teammate.** Each Implementer searches learnings, creates a living plan, writes tests, and runs validation. No shortcuts.
- **Analyst is optional.** Pure parallel plans (70%+ swarmability) skip the analyst — implementers are independent. Complex or mixed plans get an analyst.
- **Branch strategy.** All teammates work on the same branch. Assessment ensures minimal file overlap.
- **Fresh-eyes review happens AFTER.** Individual teammates validate their own work. Holistic review happens at `/review` on the combined diff.
- **Dedicated Team Lead.** The main agent never acts as Team Lead. A spawned `godmode:team:team-lead` agent handles all coordination — team creation, teammate spawning, monitoring, conflict resolution, and result synthesis. This preserves the main agent's context window for user interaction and subsequent workflow steps.
- **Token cost.** Each teammate is a full Claude Code instance. Cost scales with team size. Only recommend teams when parallelism or communication adds genuine value.
- **Replaces swarm-plan.** This skill absorbs all former swarm-plan functionality. The swarmability assessment algorithm is identical.
- **Max teammates.** Recommend 2-4 teammates. For larger plans, run in waves rather than spawning more.

---

## Integration Points

- **Input**: Approved plan file from `docs/plans/`
- **Role definitions**: `agents/team/lead.md`, `agents/team/implementer.md`, `agents/team/analyst.md`
- **Output**: Implemented code with tests, ready for `/review`
- **Guide**: `guides/AGENT_TEAMS_GUIDE.md` (Patterns C and D)
- **Consumed by**: `/implement` workflow command
- **Followed by**: `/review` (fresh-eyes-review on combined diff)
