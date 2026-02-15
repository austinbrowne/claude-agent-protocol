---
name: enhance-issue
version: "1.0"
description: Refine needs_refinement issues with exploration, planning, and enriched details — then mark ready_for_dev
referenced_by:
  - skills/triage-issues/SKILL.md
  - skills/start-issue/SKILL.md
---

# Enhance Issue Skill

Takes a sparse `needs_refinement` issue, explores the codebase, runs through planning, enriches the issue with full details, and marks it `ready_for_dev`.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Issue Selection** | Step 1 | Dynamically generated from issue list | Wrong issue enhanced — UNACCEPTABLE |
| **Next Steps** | Step 7 | Enhance another / Start implementing / Done | User loses control of workflow — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- After a `/file-issues` session to refine captured issues
- When picking up a rough issue from the backlog
- Any issue labeled `needs_refinement` that needs detail before implementation

---

## Skills Referenced

- `skills/explore/SKILL.md` — Codebase exploration to understand the problem
- `commands/plan.md` — Full planning workflow (plan generation, deepen, review, create sub-issues)

---

## Process

### 1. Select Issue

**Option A:** User provides issue number directly (`#123`).

**Option B:** List issues labeled `needs_refinement`:

```bash
gh issue list --label "needs_refinement" --json number,title,labels --limit 20
```

Display the list and ask user to pick:

```
AskUserQuestion:
  question: "Which issue would you like to enhance?"
  header: "Issue"
  options:
    [dynamically generated from issue list, up to 4 shown]
```

### 2. Load Issue Context

```bash
gh issue view NNN --json title,body,labels,assignees,comments
```

Read the issue body. Identify what's already filled vs TBD.

**For bugs:** Note any steps to reproduce, expected/actual behavior, severity.
**For features:** Note any description, user story hints.

### 3. Explore the Codebase

Load and follow `skills/explore/SKILL.md` scoped to the issue:

- Identify affected files and modules
- Understand current behavior and patterns
- For bugs: form root cause hypothesis
- For features: identify integration points and existing patterns

Present findings to the user before proceeding.

### 4. Run Planning Workflow

Chain into `/plan` with the issue as context:

- **For bugs:** Generate a Minimal plan covering the fix approach, affected areas, and testing strategy
- **For features:** Generate a Minimal, Standard, or Comprehensive plan depending on scope
- Deepen the plan if needed (user's choice via workflow)
- Review the plan if needed (user's choice via workflow)

The planning workflow handles sub-step selection internally.

### 5. Update the Issue

After planning is complete, update the GitHub issue with enriched content:

```bash
gh issue edit NNN --body-file /tmp/enhanced-issue-body.md
```

**For bugs**, fill in all TBD sections:
- Root Cause Hypothesis (from exploration)
- Affected Files (from exploration)
- Acceptance Criteria (from plan)
- Technical Requirements (from plan)
- Testing Notes / Edge Cases (from plan)
- Security Considerations (if applicable)

**For features**, fill in all template sections:
- Acceptance Criteria (from plan)
- Technical Requirements (from plan)
- Testing Notes (from plan)
- Developer Notes (from exploration)
- Performance / Security Considerations (from plan)

### 6. Swap Labels

```bash
gh issue edit NNN --remove-label "needs_refinement" --add-label "ready_for_dev"
```

### 7. Next Steps

```
AskUserQuestion:
  question: "Issue #NNN enhanced and marked ready_for_dev. What's next?"
  header: "Next"
  options:
    - label: "Enhance another issue"
      description: "Pick another needs_refinement issue to refine"
    - label: "Start implementing this issue"
      description: "Move to /implement with issue #NNN"
    - label: "Done"
      description: "End workflow"
```

**If "Enhance another":** Return to Step 1.
**If "Start implementing":** Load and follow `commands/implement.md`.
**If "Done":** End workflow.

---

## Notes

- **Preserve user's original description.** Don't overwrite what they wrote — enrich around it.
- **Root cause is a hypothesis.** Mark it clearly as such until implementation confirms it.
- **Planning depth scales with issue complexity.** Small bugs get Minimal plan. Large features may get Comprehensive plan + deepen.
- **The user controls planning depth** via `/plan` sub-step selection. Don't force full planning on a trivial bug.

---

## Integration Points

- **Input**: GitHub issue number or `needs_refinement` label query
- **Exploration**: `skills/explore/SKILL.md`
- **Planning**: `commands/plan.md` (full workflow with sub-step selection)
- **Templates**: `templates/BUG_ISSUE_TEMPLATE.md`, `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Output**: Enriched GitHub issue with `ready_for_dev` label
- **Next step**: `/implement` or another `/enhance-issue`
