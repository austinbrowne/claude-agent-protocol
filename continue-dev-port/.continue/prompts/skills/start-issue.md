---
name: start-issue
description: "End-to-end issue implementation -- research, complexity assessment, implementation, tests, and validation"
---

# Start Issue Skill

Full implementation lifecycle for a GitHub issue. Loads the issue, researches the codebase and past learnings, assesses complexity, and implements. Handles everything from branch creation through test validation.

**This is THE entry point for issue-based implementation.** For plan-based implementation, use `/team-implement`.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has a mandatory interaction gate. You MUST hit it. NEVER skip it. NEVER replace it with prose or skip ahead.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Implementation Approach** | Step 3 | Single-pass / Needs plan | Implementation started without consent -- UNACCEPTABLE |

**If you find yourself asking the user what to do next without presenting numbered options, STOP. You are violating the protocol.**

---

## When to Apply

- Have a GitHub issue ready for implementation (ideally `ready_for_dev`)
- Starting from an issue rather than a plan
- Any complexity -- this skill handles simple through complex issues

---

## Plan vs Enhanced Issue

An **enhanced issue** tells you **what** to build -- requirements, acceptance criteria, scope. It's sufficient for implementation when the approach is obvious.

A **plan** tells you **how** to build it -- technical approach, architecture decisions, tradeoffs, decomposition. Only needed when multiple valid approaches exist, architectural implications need review, or the work needs formal decomposition.

If the "how" is obvious from the "what," you don't need a plan. Most work falls here.

---

## Process

### Step 1: Load Issue Details

**If issue number provided:**
```bash
gh issue view NNN --json title,body,labels,assignees,state
```

> Note: Use `glab` for GitLab repositories.

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

> Note: Use `glab` for GitLab repositories.
> Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

Extract: Title, Description, Acceptance criteria, Labels, Estimated files, Plan reference (if any).

### Step 2: Research

Perform the following research steps sequentially:

**Step 2a -- Learnings Research:** Search `docs/solutions/` for past solutions relevant to this issue. Use multi-pass search strategy: tags, then category, then keywords, then full-text.

**Step 2b -- Codebase Research:** Explore the areas of the codebase that this issue affects. Identify existing patterns, utilities, conventions, dependencies, and potential gotchas.

Present findings to the user before proceeding.

### Step 3: Complexity Assessment -- MANDATORY GATE

**STOP. You MUST present the assessment and get explicit approval. NEVER start implementation without user consent.**

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

**Total score -> complexity:**
- 0-2: SMALL
- 3-4: MEDIUM
- 5+: LARGE

Present assessment:

```
Start Issue -- Assessment
===========================

Issue: #NNN -- [title]
Complexity: [SMALL/MEDIUM/LARGE]
Estimated files: [N]
Acceptance criteria: [N]
Relevant learnings: [N found]
```

Present the following options:

1. **Single-pass implementation** -- Direct implementation with tests and validation
2. **Needs a plan first** -- This issue needs design work -- route to `/plan`

**WAIT** for user response before continuing.

**Recommendation thresholds:**
- SMALL -> Add "(Recommended)" to Single-pass label
- MEDIUM -> Neutral (no recommendation suffix)
- LARGE -> Add "(Recommended)" to Single-pass label (note: for complex work, consider breaking into sub-issues)

**If "Single-pass":** Proceed to Step 4.
**If "Needs a plan first":** Inform user: "Routing to `/plan` with this issue as context." Invoke `/plan`. End this skill.

### Step 4: Implementation

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

   > Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

3. **Plan status update:** Search the issue body for a path matching `docs/plans/YYYY-MM-DD-*.md` (bare path or markdown link). If multiple matches, use the first. If the matched path is a directory (no `.md` extension), skip. If the referenced plan file does not exist, log a warning and continue. If the plan file exists, read its YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only -- do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

4. Create living plan: `.todos/{issue_id}-plan.md` using `templates/LIVING_PLAN_TEMPLATE.md`. Populate with: issue ID/title, branch name, acceptance criteria, past learnings from Step 2, implementation steps, progress log with start timestamp.

5. Comment on issue:
   ```bash
   gh issue comment NNN --body "Starting implementation on branch \`issue-NNN-brief-description\`"
   ```

   > Note: Use `glab` for GitLab repositories.

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

Proceed to Step 5.

### Step 5: Present Results

```
Start Issue -- Complete
=========================

Issue: #NNN -- [title]
Branch: issue-NNN-brief-description
Approach: Single-pass

Files changed:
  - [file]: [what changed]

Tests: [N passing, 0 failing]
Validation: [clean]
Commits: [list]

Next step: Run /review for fresh-eyes review of all changes.
```

Suggest the user proceed to `/review`.

---

## Notes

- **End-to-end skill.** This skill handles the full lifecycle from issue loading through validated implementation. Not just setup -- actual coding, testing, and validation.
- **Complexity assessment drives approach.** Simple issues get single-pass (fast, focused). The user always makes the final call.
- **Research before implementation.** Learnings search and codebase exploration happen BEFORE any code is written. Past mistakes inform the approach.
- **Plan path is an escape hatch.** If the issue needs design work ("how" is unclear), the user can route to `/plan` instead of implementing directly.
- **Enhanced issue = ready to implement.** An enhanced issue has acceptance criteria, affected files, and technical notes. That's sufficient for start-issue. A plan is only needed when the approach itself needs design.

---

## Integration Points

- **Input**: GitHub issue number or `ready_for_dev` label query
- **Research**: Search `docs/solutions/` for learnings, explore affected codebase areas
- **Living plan template**: `templates/LIVING_PLAN_TEMPLATE.md`
- **Output**: Implemented code with tests on feature branch, ready for `/review`
- **Followed by**: `/review` (fresh-eyes-review on changes)
