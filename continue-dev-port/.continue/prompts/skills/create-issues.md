---
name: create-issues
description: "GitHub/GitLab issue generation from approved plan with auto-linking and git commit"
---

# Issue Creation Skill

Methodology for generating issues from an approved plan, with auto-linking, plan renaming, and git commit.

---

## When to Apply

- After plan has been reviewed and approved
- Ready to break plan into implementation tasks
- Want to create backlog of work or start immediately

---

## Process

### 1. Parse Plan and Extract Implementation Tasks

- Load plan content
- Identify Implementation Steps section (or infer from Minimal plan)
- Each phase -> one issue; Minimal plan -> single issue

### 2. Generate Issues

**Load issue template:** `templates/GITHUB_ISSUE_TEMPLATE.md`

**For each phase/task, create an issue using the CLI:**

```bash
gh issue create \
  --title "Phase N: [Phase name]" \
  --body "$(cat <<'EOF'
[filled issue template content]
EOF
)" \
  --label "type: feature,priority: high"
```

> Note: Use `glab` for GitLab repositories. Adjust commands for PowerShell on Windows (e.g., heredoc syntax differs -- use a variable or temp file for the body content on Windows).

**Auto-detect labels from plan:** Type (Feature/Bug Fix/Enhancement), Priority, Status, Flags (security-sensitive, performance-critical, breaking-change).

**Execution modes:**
- `--immediate`: Add `--assignee @me`
- `--backlog`: No assignee

### 3. Rename Plan with First Issue Number

**Before renaming:** Read the plan file's YAML frontmatter `status:` field. Only proceed with the rename if the current status is `approved` (forward transitions only -- do not rename `in_progress` or `complete` plans). If the frontmatter exists but has no `status:` field, proceed with the rename.

**Current:** `docs/plans/YYYY-MM-DD-type-feature-name-plan.md`
**New:** `docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md`

### 4. Update First Issue with Plan Reference

```bash
gh issue edit NNN --body "$(gh issue view NNN --json body -q .body)

## Plan Reference
**Source plan:** \`docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md\`"
```

> Note: Use `glab` for GitLab repositories.

### 5. Commit Plan to Git and Push

```bash
git add docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md
git commit -m "docs: add plan for [feature] (Issue #NNN)"
git push
```

> Note: Adjust commands for PowerShell on Windows if needed (git commands are cross-platform).

---

## Notes

- **Plan renaming** creates direct link between plan and implementation
- **Git commit is mandatory** -- ensures plan is available to team and in future sessions
- **Phases -> Issues**: Each implementation phase becomes one issue
- **Related issues**: Dependencies linked with "Depends on" / "Blocks"

---

## Integration Points

- **Input**: Approved plan file
- **Output**: GitHub/GitLab issues, renamed plan, git commit
- **Template**: `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Consumed by**: Implementation workflows
