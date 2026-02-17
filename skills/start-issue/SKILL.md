---
name: start-issue
version: "2.0"
description: End-to-end issue implementation — research, complexity assessment, single-agent or team execution, tests, and validation
referenced_by:
  - commands/implement.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Start Issue Skill

Full implementation lifecycle for a GitHub issue. Loads the issue, researches the codebase and past learnings, assesses complexity, and implements — either as a single agent or by spawning a team for complex work. Handles everything from branch creation through test validation.

**This is THE entry point for issue-based implementation.** For plan-based implementation, use `team-implement`.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has a mandatory AskUserQuestion gate. You MUST hit it. NEVER skip it. NEVER replace it with a plain text question.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Implementation Approach** | Step 3 | Single-agent / Team / Needs plan | Team spawned or plan skipped without consent — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- Have a GitHub issue ready for implementation (ideally `ready_for_dev`)
- Starting from an issue rather than a plan
- Any complexity — this skill handles simple through complex issues internally

---

## Plan vs Enhanced Issue

An **enhanced issue** tells you **what** to build — requirements, acceptance criteria, scope. It's sufficient for implementation when the approach is obvious.

A **plan** tells you **how** to build it — technical approach, architecture decisions, tradeoffs, decomposition. Only needed when multiple valid approaches exist, architectural implications need review, or the work needs formal decomposition.

If the "how" is obvious from the "what," you don't need a plan. Most work falls here.

---

## Process

### Step 1: Load Issue Details

**If issue number provided:**
```bash
gh issue view NNN --json title,body,labels,assignees,state
```

**If no issue number:**
1. List recent `ready_for_dev` issues:
   ```bash
   gh issue list --label "ready_for_dev" --json number,title,labels --limit 10
   ```
2. If found, present list and ask user to pick
3. If none found, list all open issues:
   ```bash
   gh issue list --limit 10 --json number,title,labels --state open
   ```
4. If still none, inform user: "No issues found. Run `/file-issue` to create one."

Extract: Title, Description, Acceptance criteria, Labels, Estimated files, Plan reference (if any).

### Step 2: Research

Launch research agents in parallel via Task tool:

1. **Learnings Research Agent** (`subagent_type: "godmode:research:learnings-researcher"`): Search `docs/solutions/` for past solutions relevant to this issue. Use multi-pass Grep strategy: tags → category → keywords → full-text.

2. **Codebase Research Agent** (`subagent_type: "Explore"`): Explore the areas of the codebase that this issue affects. Identify existing patterns, utilities, conventions, dependencies, and potential gotchas.

Present findings to the user before proceeding.

### Step 3: Complexity Assessment — MANDATORY GATE

**STOP. You MUST present the assessment and get explicit approval via AskUserQuestion. NEVER start implementation without user consent.**

Assess the issue:

| Signal | Score |
|--------|-------|
| Body length < 200 chars | SMALL (+0) |
| Body length 200-1000 chars | MEDIUM (+1) |
| Body length > 1000 chars | LARGE (+2) |
| Acceptance criteria count < 3 | SMALL (+0) |
| Acceptance criteria count 3-6 | MEDIUM (+1) |
| Acceptance criteria count > 6 | LARGE (+2) |
| Estimated files: 1-2 | SMALL (+0) |
| Estimated files: 3-5 | MEDIUM (+1) |
| Estimated files: 6+ | LARGE (+2) |
| Labels include `complexity: high` or `type: architectural` | LARGE (+2) |

**Total score → complexity:**
- 0-2: SMALL
- 3-4: MEDIUM
- 5+: LARGE

Present assessment:

```
Start Issue — Assessment
━━━━━━━━━━━━━━━━━━━━━━━

Issue: #NNN — [title]
Complexity: [SMALL/MEDIUM/LARGE]
Estimated files: [N]
Acceptance criteria: [N]
Relevant learnings: [N found]
```

```
AskUserQuestion:
  question: "How would you like to implement this issue?"
  header: "Approach"
  options:
    - label: "Single-agent"
      description: "Direct implementation with tests and validation"
    - label: "Team"
      description: "Spawn implementation team (Lead + Analyst + Implementers)"
    - label: "Needs a plan first"
      description: "This issue needs design work — route to /plan"
```

**Recommendation thresholds:**
- SMALL → Add "(Recommended)" to Single-agent label
- MEDIUM → Neutral (no recommendation suffix)
- LARGE + TeamCreate available → Add "(Recommended)" to Team label
- LARGE + TeamCreate NOT available → Add "(Recommended)" to Single-agent label

**If TeamCreate is NOT available:** Do not show the "Team" option.

**If "Single-agent":** Proceed to Step 4.
**If "Team":** Proceed to Step 5.
**If "Needs a plan first":** Inform user: "Routing to /plan with this issue as context." Invoke `Skill(skill="godmode:plan")`. End this skill.

### Step 4: Single-Agent Implementation

#### 4a. Setup

1. Assign issue and update labels:
   ```bash
   gh issue edit NNN --add-assignee @me --remove-label "ready_for_dev" --add-label "status: in-progress"
   ```

2. Create branch:
   ```bash
   git checkout -b issue-NNN-brief-description
   git push -u origin issue-NNN-brief-description
   ```

3. **Plan status update:** Search the issue body for a path matching `docs/plans/YYYY-MM-DD-*.md` (bare path or markdown link). If multiple matches, use the first. If the matched path is a directory (no `.md` extension), skip. If the referenced plan file does not exist, log a warning and continue. If the plan file exists, read its YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only — do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

4. Create living plan: `.todos/{issue_id}-plan.md` using `templates/LIVING_PLAN_TEMPLATE.md`. Populate with: issue ID/title, branch name, acceptance criteria, past learnings from Step 2, implementation steps, progress log with start timestamp.

5. Comment on issue:
   ```bash
   gh issue comment NNN --body "Starting implementation on branch \`issue-NNN-brief-description\`"
   ```

#### 4b. Implement

Work through the acceptance criteria. For each criterion:
1. Write code that satisfies the criterion
2. Follow existing codebase patterns and conventions (use research findings from Step 2)
3. Apply relevant past learnings
4. Update the living plan after each significant change

#### 4c. Test

Generate tests for all changed code:
- Happy path tests for each acceptance criterion
- Edge case tests (null, empty, boundaries)
- Error condition tests

Run tests and ensure they pass. If tests fail, fix them (up to 3 attempts before flagging to user).

#### 4d. Validate

Run validation on changed code:
- Lint check
- Type check (if applicable)
- Run full test suite to ensure no regressions

#### 4e. Commit

Stage and commit changes:
- Intermediate commits during implementation: `Part of #NNN`
- Final commit: `Closes #NNN`
- Update living plan with completion status

Proceed to Step 6.

### Step 5: Team Implementation

**Requires TeamCreate tool.** If not available, this path should not have been offered in Step 3.

#### 5a. Setup

1. Assign issue and update labels (same as Step 4a.1)
2. Create branch (same as Step 4a.2)
3. Plan status update (same as Step 4a.3)

#### 5b. Read Role Definitions

Read the following files and inline their content into the Team Lead's spawn prompt:
- `agents/team/lead.md`
- `agents/team/implementer.md`
- `agents/team/analyst.md`

#### 5c. Spawn Team Lead

Launch a single `godmode:team:team-lead` agent via the Task tool. The Team Lead creates the team, spawns teammates, monitors progress, and returns consolidated results. The main agent waits for the result.

```
Task(
  subagent_type="godmode:team:team-lead",
  prompt="""You are the Team Lead for an issue implementation team.

YOUR ROLE DEFINITION:
[inline content from agents/team/lead.md]

IMPLEMENTER ROLE DEFINITION (include in every implementer spawn prompt):
[inline content from agents/team/implementer.md]

ANALYST ROLE DEFINITION (include in analyst spawn prompt):
[inline content from agents/team/analyst.md]

== CONTEXT ==

Issue: #NNN — [title]
[issue body]

Branch: issue-NNN-brief-description

Research findings:
[learnings and codebase research from Step 2]

== ASSESSMENT RESULTS ==

Complexity: [SMALL/MEDIUM/LARGE]
Estimated files: [N]
Acceptance criteria: [N]

== INSTRUCTIONS ==

1. Create a team via TeamCreate
2. Create the shared task list — decompose the issue into implementation tasks with file ownership boundaries
3. Spawn Analyst as a teammate — include their role definition, issue context, and affected areas
4. Spawn Implementer(s) as teammates — one per task group. Include in each spawn prompt: their role definition, task description, owned files (EXCLUSIVE), and issue reference
5. Monitor progress: watch task list, handle blockers, resolve file conflicts, relay analyst findings
6. When all tasks complete: shut down all teammates, clean up the team
7. Return a consolidated summary in your output format

Rules:
- Each Implementer follows the FULL protocol pipeline: read CLAUDE.md, search docs/solutions/, create living plan, implement, test, validate
- File ownership is EXCLUSIVE — no overlaps between implementers
- If a teammate needs a file outside their boundary, they message you first
- 2-4 teammates maximum
- Broadcast sparingly — prefer direct messages
- Commits should reference: Part of #NNN or Closes #NNN
""")
```

Proceed to Step 6.

### Step 6: Present Results

**For single-agent (Step 4):**

```
Start Issue — Complete
━━━━━━━━━━━━━━━━━━━━━━

Issue: #NNN — [title]
Branch: issue-NNN-brief-description
Approach: Single-agent

Files changed:
  - [file]: [what changed]

Tests: [N passing, 0 failing]
Validation: [clean]
Commits: [list]

Next step: Run /review for fresh-eyes review of all changes.
```

**For team (Step 5):**

Present the Team Lead's consolidated summary, then:

```
Next step: Run /review for fresh-eyes review of all changes.
```

Suggest the user proceed to `/review`.

---

## Notes

- **End-to-end skill.** This skill handles the full lifecycle from issue loading through validated implementation. Not just setup — actual coding, testing, and validation.
- **Complexity assessment drives approach.** Simple issues get single-agent (fast, focused). Complex issues get a team (parallel, coordinated). The user always makes the final call.
- **Research before implementation.** Learnings search and codebase exploration happen BEFORE any code is written. Past mistakes inform the approach.
- **Team path uses dedicated Team Lead.** The main agent does not act as Team Lead — a spawned agent handles all coordination. See `guides/AGENT_TEAMS_GUIDE.md`.
- **Plan path is an escape hatch.** If the issue needs design work ("how" is unclear), the user can route to /plan instead of implementing directly.
- **Enhanced issue = ready to implement.** An enhanced issue has acceptance criteria, affected files, and technical notes. That's sufficient for start-issue. A plan is only needed when the approach itself needs design.

---

## Integration Points

- **Input**: GitHub issue number or `ready_for_dev` label query
- **Research agents**: `agents/research/learnings-researcher.md`, `agents/research/codebase-researcher.md`
- **Team role definitions**: `agents/team/lead.md`, `agents/team/implementer.md`, `agents/team/analyst.md`
- **Living plan template**: `templates/LIVING_PLAN_TEMPLATE.md`
- **Output**: Implemented code with tests on feature branch, ready for `/review`
- **Consumed by**: `/implement` workflow command
- **Followed by**: `/review` (fresh-eyes-review on changes)
