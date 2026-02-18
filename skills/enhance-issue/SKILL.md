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

Invoke `Skill(skill="godmode:explore")` scoped to the issue:

- Identify affected files and modules
- Understand current behavior and patterns
- For bugs: form root cause hypothesis
- For features: identify integration points and existing patterns

Present findings to the user before proceeding.

### 4. Synthesize Findings into Issue

Update the GitHub issue with enriched content based on exploration:

Use `--body` with a heredoc — do NOT write to `/tmp`:

```bash
gh issue edit NNN --body "$(cat <<'EOF'
[enhanced issue content]
EOF
)"
```

**For bugs**, fill in all TBD sections:
- Root Cause Hypothesis (from exploration)
- Affected Files (from exploration)
- Acceptance Criteria (what "fixed" looks like — from exploration context)
- Technical Notes (patterns to follow, existing code to reference — from exploration)
- Testing Notes / Edge Cases (from exploration)
- Security Considerations (if applicable)

**For features**, fill in all template sections:
- Acceptance Criteria (what "done" looks like — concrete, testable)
- Affected Files (from exploration)
- Technical Notes (patterns to follow, utilities to use — from exploration)
- Testing Notes (edge cases to cover)
- Developer Notes (from exploration)
- Performance / Security Considerations (if applicable)

### 5. Swap Labels

```bash
gh issue edit NNN --remove-label "needs_refinement" --add-label "ready_for_dev"
```

### 6. Next Steps

```
AskUserQuestion:
  question: "Issue #NNN enhanced and marked ready_for_dev. What's next?"
  header: "Next"
  options:
    - label: "Start implementing this issue"
      description: "Move to /implement with issue #NNN"
    - label: "Create a plan first"
      description: "This issue needs design work before implementation — route to /plan"
    - label: "Enhance another issue"
      description: "Pick another needs_refinement issue to refine"
    - label: "Done"
      description: "End workflow"
```

**If "Start implementing":** Invoke `Skill(skill="godmode:implement")`. Execute from Step 0. Do NOT skip any steps.
**If "Create a plan first":** Invoke `Skill(skill="godmode:plan")`. End this skill.
**If "Enhance another":** Return to Step 1.
**If "Done":** End workflow.

---

## Notes

- **Preserve user's original description.** Don't overwrite what they wrote — enrich around it.
- **Root cause is a hypothesis.** Mark it clearly as such until implementation confirms it.
- **Enhanced issue = "what" to build.** Fill in requirements, acceptance criteria, affected files, technical notes. This is sufficient for implementation when the approach is obvious.
- **Planning is separate.** If the issue needs design work ("how" is unclear), the user routes to `/plan` via the next-steps gate. Don't force planning on every issue.
- **Exploration drives enrichment.** The codebase exploration in Step 3 provides all the context needed to fill in acceptance criteria, affected files, and technical notes.

---

## Integration Points

- **Input**: GitHub issue number or `needs_refinement` label query
- **Exploration**: `skills/explore/SKILL.md`
- **Templates**: `templates/BUG_ISSUE_TEMPLATE.md`, `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Output**: Enriched GitHub issue with `ready_for_dev` label
- **Next step**: `/implement` or another `/enhance-issue`
