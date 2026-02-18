---
name: file-issues
description: "Rapid-fire issue filing -- bugs and features with sparse templates and needs_refinement label"
---

# File Issues Skill

Rapid-fire issue filing for capturing bugs and feature requests quickly. Uses sparse templates -- details are added later via `/enhance-issue`.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST hit them. NEVER skip them. NEVER replace them with prose or skip ahead.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Issue Type** | Step 1 | Bug / Feature | Wrong template used -- UNACCEPTABLE |
| **Confirm Before Creating** | Step 3 | Looks good / Add more details | Issue created without consent -- UNACCEPTABLE |
| **Loop or Done** | Step 5 | File another bug / File another feature / Done | User loses control of filing loop -- UNACCEPTABLE |

**If you find yourself asking the user what to do next without presenting numbered options, STOP. You are violating the protocol.**

---

## When to Apply

- Brain-dumping multiple bugs or feature ideas
- Triaging after a testing session
- Capturing issues during code review or exploration
- Any time you want to file fast without full planning

---

## Process

### 1. Ask Issue Type

Present the following options to the user:

1. **Bug** -- Something is broken or behaving incorrectly
2. **Feature / Enhancement** -- New functionality or improvement to existing behavior

**WAIT** for user response before continuing.

### 2. Capture Issue Details

**Ask the user to describe the issue.** Keep it conversational -- extract what you can from their description.

**For bugs**, extract from the description:
- Title (imperative mood, e.g. "Fix crash when submitting empty form")
- Bug description (what's happening)
- Steps to reproduce (if provided)
- Expected vs actual behavior (if provided)
- Severity (ask if not obvious)

**For features/enhancements**, extract:
- Title (imperative mood, e.g. "Add dark mode toggle to settings")
- Description (what needs to be built and why)
- User story (if obvious from context)

### 3. Confirm Before Creating

Present a summary of the extracted title and details, then ask:

1. **Looks good, create it** -- File the issue as shown
2. **Add more details** -- Let me add more context before filing

**WAIT** for user response before continuing.

**If "Add more details":** Ask the user for additional context. Incorporate it, then present the updated summary and ask again.
**If "Looks good":** Proceed to Step 4.

### 4. Create GitHub Issue

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

### 5. Confirm and Loop

Print the created issue number and URL.

Present the following options:

1. **File another bug** -- Capture another bug report
2. **File another feature** -- Capture another feature request
3. **Done filing** -- Print summary and exit

**WAIT** for user response before continuing.

**If filing another:** Return to Step 2 with the selected type (skip Step 1).
**If done:** Continue to Step 6.

### 6. Print Summary

Display all filed issues:

```
Issues filed this session:
  #123 [bug]     Fix crash when submitting empty form
  #124 [feature] Add dark mode toggle to settings
  #125 [bug]     API returns 500 on expired tokens

All labeled needs_refinement. Run /enhance-issue to add details and mark ready_for_dev.
```

---

## Notes

- **Speed over completeness.** The point is fast capture. Details come later.
- **Don't ask for fields the user hasn't mentioned.** If they didn't provide reproduction steps, leave TBD -- `/enhance-issue` will fill them.
- **Severity for bugs:** Only ask if it's not obvious from context. Default to `medium` if unclear.
- **Labels are auto-applied:** `type: bug` or `type: feature` plus `needs_refinement` on every issue.

---

## Integration Points

- **Templates**: `templates/BUG_ISSUE_TEMPLATE.md`, `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Output**: GitHub issues with `needs_refinement` label
- **Next step**: `/enhance-issue` to refine, or `/plan` for full planning
