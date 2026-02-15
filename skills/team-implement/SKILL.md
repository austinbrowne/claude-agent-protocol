---
name: team-implement
version: "1.0"
description: Unified team-based implementation — composes Lead, Analyst, and Implementer roles based on complexity assessment for plans and issues
referenced_by:
  - commands/implement.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Team Implement Skill

Assess a plan or issue for team-based implementation, compose the right team from defined roles (Lead, Analyst, Implementer), and execute with coordination. Handles everything from single complex issues to multi-task plan swarms.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has a mandatory AskUserQuestion gate. You MUST hit it. NEVER skip it. NEVER replace it with a plain text question.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Team Composition** | Step 3 | Team mode / Sequential / Adjust | Team spawned without consent — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- After a plan is approved and ready for implementation (replaces former swarm-plan)
- Complex issue that would benefit from parallel research + implementation
- Agent Teams is enabled (`TeamCreate` tool available)
- User wants team-based execution instead of single-agent start-issue

---

## Prerequisites

- Plan file with status `approved` or `ready_for_review`, OR a GitHub issue number
- Agent Teams is available (`TeamCreate` tool in tool list)
- If `TeamCreate` tool is NOT available, inform user: "Agent Teams is not enabled. Use `/implement` → `start-issue` for single-agent implementation, or enable Agent Teams with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`."

---

## Process

### Step 0: Detect Execution Mode

**CRITICAL: Check your tool list RIGHT NOW. Do NOT use conversation history to decide. Each skill invocation re-evaluates independently.**

Check if the `TeamCreate` tool is available in your tool list.
- Available: Continue with this skill
- Not available: HALT. Inform user that Agent Teams is required for this skill. Suggest `/implement` → `start-issue` instead.

### Step 1: Load Input

**If plan path provided or referenced in conversation:**
- Read specified plan file
- Extract: Implementation Steps, Affected Files per step, Dependencies between steps

**If issue number provided:**
- Fetch issue: `gh issue view NNN --json title,body,labels,assignees,state`
- Extract: Title, Body, Acceptance criteria, Labels, Estimated complexity

**If neither:**
1. Check conversation for most recent plan or issue reference
2. If not found, check for plans: `Glob docs/plans/*.md` — read YAML frontmatter and filter out `status: complete` plans. Only show active (non-complete) plans.
3. Check for issues: `gh issue list --limit 10 --json number,title,labels --state open`
4. Ask user to specify

### Step 2: Assessment

#### For Plan Input: Swarmability Assessment

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
| <40% | Recommend sequential `/implement` → `start-issue` instead |

#### For Issue Input: Complexity Assessment

Estimate complexity from the issue:

| Signal | Score |
|--------|-------|
| Body length < 200 chars | SMALL (+0) |
| Body length 200-1000 chars | MEDIUM (+1) |
| Body length > 1000 chars | LARGE (+2) |
| Acceptance criteria count < 3 | SMALL (+0) |
| Acceptance criteria count 3-6 | MEDIUM (+1) |
| Acceptance criteria count > 6 | LARGE (+2) |
| Estimated files mentioned: 1-2 | SMALL (+0) |
| Estimated files mentioned: 3-5 | MEDIUM (+1) |
| Estimated files mentioned: 6+ | LARGE (+2) |
| Labels include `complexity: high` or `type: architectural` | LARGE (+2) |

**Total score → complexity:**
- 0-1: SMALL → Recommend `/implement` → `start-issue`
- 2-3: MEDIUM → Lead + Analyst + Implementer
- 4+: LARGE → Lead + Analyst + 2 Implementers (split by module)

### Step 3: Present Assessment — MANDATORY GATE

**STOP. You MUST present the assessment and get explicit approval via AskUserQuestion. NEVER spawn a team without user consent.**

#### For Plan Input:

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

#### For Issue Input:

```
Team Implement — Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━

Issue: #NNN — [title]
Complexity: [SMALL/MEDIUM/LARGE]
Estimated files: [N]
Acceptance criteria: [N]

Recommended composition:
  Lead (you) — coordination and monitoring
  Analyst — codebase research, past learnings, requirements validation
  Implementer(s) — [N] implementer(s) with file ownership: [module split if >1]
```

```
AskUserQuestion:
  question: "Assessment complete. How would you like to implement?"
  header: "Team mode"
  options:
    - label: "Team mode"
      description: "[composition summary: N teammates, analyst yes/no]"
    - label: "Sequential"
      description: "Single-agent implementation via start-issue"
    - label: "Adjust composition"
      description: "I want to change the team makeup"
```

**Recommendation thresholds (plans):**
- Swarmability 70%+ → Add "(Recommended)" to Team mode label
- 40-69% → Neutral
- <40% → Add "(Recommended)" to Sequential label

**Recommendation thresholds (issues):**
- LARGE → Add "(Recommended)" to Team mode label
- MEDIUM → Neutral
- SMALL → Add "(Recommended)" to Sequential label

**If "Team mode":** Proceed to Step 4.
**If "Sequential":** Inform user to use `/implement` → `start-issue`. End skill.
**If "Adjust composition":** Ask what changes. Update composition. Re-present Step 3.

### Step 4: Spawn Implementation Team

**Plan status update:** Before spawning any teammates, read the plan file's YAML frontmatter `status:` field (if plan input). Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only — do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

**Issue status update:** If issue input:
```bash
gh issue edit NNN --add-assignee @me --remove-label "ready_for_dev" --add-label "status: in-progress"
```

**4a. Create shared task list:**

Create tasks for each group. Independent groups start unblocked. Serialized tasks blocked by their dependencies.

**4b. Spawn Analyst (if composition includes one):**

Read `agents/team/analyst.md` for the full role definition. Spawn prompt:

```
You are the Analyst on an implementation team. Read `agents/team/analyst.md` for your full role and process.

[For plan input:]
Plan: [plan file path]
Tasks being implemented:
[list of all tasks with descriptions]

[For issue input:]
Issue: #NNN — [title]
[issue body]

Affected areas:
[list of directories/files from assessment]

Your job:
1. Search docs/solutions/ for past learnings relevant to these tasks
2. Explore the codebase areas being modified — identify patterns, utilities, conventions
3. Broadcast findings to implementers as you discover them (don't wait)
4. Respond to any research requests from implementers or the Lead
5. Cross-reference implementation direction against requirements

Rules:
- Read CLAUDE.md for project conventions
- Broadcast relevant findings immediately — implementers are working NOW
- Prioritize on-demand research requests over background research
- Mark your research task complete when initial sweep is done
```

**4c. Spawn Implementer(s):**

Read `agents/team/implementer.md` for the full role definition. One spawn per task group.

```
You are an Implementer on an implementation team. Read `agents/team/implementer.md` for your full role and process.

Your assigned tasks:
[task descriptions for this group]

Owned files:
[file list for this group — EXCLUSIVE ownership]

[For plan input:]
Plan reference: [plan file path]

[For issue input:]
Issue: #NNN — [title]
Acceptance criteria:
[criteria from issue]

Protocol pipeline (follow ALL steps):
1. Read CLAUDE.md for project conventions
2. Search docs/solutions/ for past learnings relevant to your tasks
3. Create a living plan at .todos/[task-id]-plan.md
4. Implement the code changes
5. Generate tests (happy path + edge cases + error conditions)
6. Run validation: lint, type-check, tests pass
7. Mark task complete and message the Lead with summary

Rules:
- Do NOT modify files outside your owned list unless you get Lead approval
- If you need to modify a shared file, message the Lead FIRST and wait
- If you discover a blocker, message the Lead immediately
- If the Analyst broadcasts a finding relevant to your work, adjust accordingly
- If you finish early, check the task list for unblocked tasks to claim
```

**4d. For serialized tasks:** Monitor the task list. When a dependency completes, the blocked task becomes unblocked. Either an existing idle teammate claims it, or spawn a new Implementer.

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
5. **Relay analyst findings:** If the analyst discovers something critical that affects the overall plan, broadcast it or message the specific implementer

### Step 6: Completion

When all tasks are complete:

1. Shut down all teammates and clean up the team
2. Present summary using the Lead's output format (see `agents/team/lead.md`):

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

3. Suggest the user proceed to `/review` for fresh-eyes review of the combined diff.

---

## Notes

- **Full protocol per teammate.** Each Implementer searches learnings, creates a living plan, writes tests, and runs validation. No shortcuts.
- **Analyst is optional.** Pure parallel plans (70%+ swarmability) skip the analyst — implementers are independent. Complex or mixed plans get an analyst.
- **Branch strategy.** All teammates work on the same branch. Assessment ensures minimal file overlap.
- **Fresh-eyes review happens AFTER.** Individual teammates validate their own work. Holistic review happens at `/review` on the combined diff.
- **Token cost.** Each teammate is a full Claude Code instance. Cost scales with team size. Only recommend teams when parallelism or communication adds genuine value.
- **Replaces swarm-plan.** This skill absorbs all former swarm-plan functionality. The swarmability assessment algorithm is identical.
- **Max teammates.** Recommend 2-4 teammates. For larger plans, run in waves rather than spawning more.

---

## Integration Points

- **Input**: Approved plan file from `docs/plans/` OR GitHub issue number
- **Role definitions**: `agents/team/lead.md`, `agents/team/implementer.md`, `agents/team/analyst.md`
- **Output**: Implemented code with tests, ready for `/review`
- **Guide**: `guides/AGENT_TEAMS_GUIDE.md` (Patterns C and D)
- **Consumed by**: `/implement` workflow command
- **Followed by**: `/review` (fresh-eyes-review on combined diff)
