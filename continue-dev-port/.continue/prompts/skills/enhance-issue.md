---
name: enhance-issue
description: "Refine needs_refinement issues with exploration, planning, and enriched details -- then mark ready_for_dev"
---

# Enhance Issue Skill

Takes a sparse `needs_refinement` issue, explores the codebase, runs through planning, enriches the issue with full details, and marks it `ready_for_dev`.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST hit them. NEVER skip them. NEVER replace them with prose or skip ahead.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Issue Selection** | Step 1 | Dynamically generated from issue list | Wrong issue enhanced -- UNACCEPTABLE |
| **Next Steps** | Step 6 | Start implementing / Create plan / Enhance another / Done | User loses control of workflow -- UNACCEPTABLE |

**If you find yourself asking the user what to do next without presenting numbered options, STOP. You are violating the protocol.**

---

## When to Apply

- After a `/file-issues` session to refine captured issues
- When picking up a rough issue from the backlog
- Any issue labeled `needs_refinement` that needs detail before implementation

---

## Skills Referenced

- `/explore` -- Codebase exploration to understand the problem

---

## Process

### 1. Select Issue

**Option A:** User provides issue number directly (`#123`).

**Option B:** List issues labeled `needs_refinement`:

```bash
gh issue list --label "needs_refinement" --json number,title,labels --limit 20
```

> Note: Use `glab` for GitLab repositories.
> Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

Display the list and present numbered options for the user to pick (up to 4 shown).

**WAIT** for user response before continuing.

### 2. Load Issue Context

```bash
gh issue view NNN --json title,body,labels,assignees,comments
```

> Note: Use `glab` for GitLab repositories.

Read the issue body. Identify what's already filled vs TBD.

**For bugs:** Note any steps to reproduce, expected/actual behavior, severity.
**For features:** Note any description, user story hints.

### 3. Explore the Codebase

Run a focused exploration scoped to the issue using `/explore`:

- Identify affected files and modules
- Understand current behavior and patterns
- For bugs: form root cause hypothesis
- For features: identify integration points and existing patterns

Present findings to the user before proceeding.

### 4. Synthesize Findings into Issue

Update the GitHub issue with enriched content based on exploration:

Use `--body` with a heredoc -- do NOT write to temporary files:

```bash
gh issue edit NNN --body "$(cat <<'EOF'
[enhanced issue content]
EOF
)"
```

> Note: Use `glab` for GitLab repositories.
> Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

**For bugs**, fill in all TBD sections:
- Root Cause Hypothesis (from exploration)
- Affected Files (from exploration)
- Acceptance Criteria (what "fixed" looks like -- from exploration context)
- Technical Notes (patterns to follow, existing code to reference -- from exploration)
- Testing Notes / Edge Cases (from exploration)
- Security Considerations (if applicable)

**For features**, fill in all template sections:
- Acceptance Criteria (what "done" looks like -- concrete, testable)
- Affected Files (from exploration)
- Technical Notes (patterns to follow, utilities to use -- from exploration)
- Testing Notes (edge cases to cover)
- Developer Notes (from exploration)
- Performance / Security Considerations (if applicable)

### 5. Swap Labels

```bash
gh issue edit NNN --remove-label "needs_refinement" --add-label "ready_for_dev"
```

> Note: Use `glab` for GitLab repositories.

### 6. Next Steps

Present the following options:

1. **Start implementing this issue** -- Move to `/implement` with issue #NNN
2. **Create a plan first** -- This issue needs design work before implementation -- route to `/plan`
3. **Enhance another issue** -- Pick another needs_refinement issue to refine
4. **Done** -- End workflow

**WAIT** for user response before continuing.

**If "Start implementing":** Proceed with `/implement`. Execute from Step 0. Do NOT skip any steps.
**If "Create a plan first":** Proceed with `/plan`. End this skill.
**If "Enhance another":** Return to Step 1.
**If "Done":** End workflow.

---

## Notes

- **Preserve user's original description.** Don't overwrite what they wrote -- enrich around it.
- **Root cause is a hypothesis.** Mark it clearly as such until implementation confirms it.
- **Enhanced issue = "what" to build.** Fill in requirements, acceptance criteria, affected files, technical notes. This is sufficient for implementation when the approach is obvious.
- **Planning is separate.** If the issue needs design work ("how" is unclear), the user routes to `/plan` via the next-steps gate. Don't force planning on every issue.
- **Exploration drives enrichment.** The codebase exploration in Step 3 provides all the context needed to fill in acceptance criteria, affected files, and technical notes.

---

## Integration Points

- **Input**: GitHub issue number or `needs_refinement` label query
- **Exploration**: `/explore` skill
- **Templates**: `templates/BUG_ISSUE_TEMPLATE.md`, `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Output**: Enriched GitHub issue with `ready_for_dev` label
- **Next step**: `/implement` or another `/enhance-issue`
