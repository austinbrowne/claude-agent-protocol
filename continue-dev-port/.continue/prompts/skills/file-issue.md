---
name: file-issue
description: "File a single GitHub issue from a description -- asks bug or feature, confirms details, then creates with needs_refinement label"
---

# File Issue Skill

File a single GitHub issue quickly. Accepts a description as an argument, asks for type and any additional details, then creates the issue.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST hit them. NEVER skip them. NEVER replace them with prose or skip ahead.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Issue Type** | Step 2 | Bug / Feature | Wrong template used -- UNACCEPTABLE |
| **Confirm Before Creating** | Step 4 | Looks good / Add more details | Issue created without consent -- UNACCEPTABLE |

**If you find yourself asking the user what to do next without presenting numbered options, STOP. You are violating the protocol.**

---

## When to Apply

- Filing a single bug or feature request
- Quick capture of one issue with a known description
- Invoked as `/file-issue <description>`

---

## Process

### 1. Parse Argument

If the user provided a description argument, use it as the initial issue description. If no argument, ask the user to describe the issue.

### 2. Ask Issue Type

Present the following options to the user:

1. **Bug** -- Something is broken or behaving incorrectly
2. **Feature / Enhancement** -- New functionality or improvement to existing behavior

**WAIT** for user response before continuing.

### 3. Extract Details from Description

**For bugs**, extract what's available:
- Title (imperative mood, e.g. "Fix crash when submitting empty form")
- Bug description (what's happening)
- Steps to reproduce (if provided)
- Expected vs actual behavior (if provided)
- Severity (infer from context, default to `medium`)

**For features/enhancements**, extract:
- Title (imperative mood, e.g. "Add dark mode toggle to settings")
- Description (what needs to be built and why)
- User story (if obvious from context)

### 4. Confirm Before Creating

Present a summary of what will be filed, then ask:

1. **Looks good, create it** -- File the issue as shown
2. **Add more details** -- Let me add more context before filing

**WAIT** for user response before continuing.

**If "Add more details":** Ask the user for additional context. Incorporate it into the issue, then present the updated summary and ask again.
**If "Looks good":** Proceed to Step 5.

### 5. Create GitHub Issue

**For bugs** -- load `templates/BUG_ISSUE_TEMPLATE.md` and fill sparsely. Use `--body` with a heredoc -- do NOT write to temporary files:

```bash
gh issue create \
  --title "[Bug title]" \
  --body "$(cat <<'EOF'
[filled bug template content]
EOF
)" \
  --label "type: bug,needs_refinement"
```

> Note: Use `glab` for GitLab repositories.
> Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

Fill only: Title, Bug Description, Steps to Reproduce (if provided), Expected/Actual (if provided), Severity. Leave all other sections as TBD or template defaults.

**For features** -- load `templates/GITHUB_ISSUE_TEMPLATE.md` and fill sparsely. Use `--body` with a heredoc -- do NOT write to temporary files:

```bash
gh issue create \
  --title "[Feature title]" \
  --body "$(cat <<'EOF'
[filled feature template content]
EOF
)" \
  --label "type: feature,needs_refinement"
```

> Note: Use `glab` for GitLab repositories.
> Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

Fill only: Title, Description. Leave Acceptance Criteria, Technical Requirements, Testing Notes, and all other sections as template defaults.

### 6. Confirm

Print the created issue number and URL.

Suggest next steps: `/enhance-issue #NNN` to add details, or `/implement` to start working on it.

---

## Integration Points

- **Templates**: `templates/BUG_ISSUE_TEMPLATE.md`, `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Output**: Single GitHub issue with `needs_refinement` label
- **Next step**: `/enhance-issue` to refine, or `/implement` to start working
