---
name: create-issues
version: "1.1"
description: Issue generation from approved plan with auto-linking and git commit
referenced_by:
  - commands/plan.md
---

# Issue Creation Skill

Methodology for generating issues from an approved plan, with auto-linking, plan renaming, and git commit.

> **Platform:** Commands below use GitHub (`gh`) syntax. For GitLab (`glab`) equivalents, see `platforms/gitlab.md`. Run `platforms/detect.md` once per session to determine your platform.

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
- Each phase → one issue; Minimal plan → single issue

### 2. Generate Issues

**Load issue template:** `templates/ISSUE_TEMPLATE.md`

**For each phase/task:**
```bash
# GitHub:
gh issue create \
  --title "Phase N: [Phase name]" \
  --body-file /tmp/issue-body.md \
  --label "type: feature,priority: high"
# GitLab:
glab issue create \
  --title "Phase N: [Phase name]" \
  --description "$(cat /tmp/issue-body.md)" \
  --label "type::feature,priority::high"
```

**Auto-detect labels from plan:** Type (Feature/Bug Fix/Enhancement), Priority, Status, Flags (security-sensitive, performance-critical, breaking-change).

**Execution modes:**
- `--immediate`: Add `--assignee @me`
- `--backlog`: No assignee

### 3. Rename Plan with First Issue Number

**Current:** `docs/plans/YYYY-MM-DD-type-feature-name-plan.md`
**New:** `docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md`

### 4. Update First Issue with Plan Reference

```bash
# GitHub:
gh issue edit NNN --add-body "## Plan Reference\n**Source plan:** \`docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md\`"
# GitLab:
glab issue note NNN --message "## Plan Reference\n**Source plan:** \`docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md\`"
```

### 5. Commit Plan to Git and Push

```bash
git add docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md
git commit -m "docs: add plan for [feature] (Issue #NNN)"
git push
```

---

## Notes

- **Plan renaming** creates direct link between plan and implementation
- **Git commit is mandatory** — ensures plan is available to team and in future sessions
- **Phases → Issues**: Each implementation phase becomes one issue
- **Related issues**: Dependencies linked with "Depends on" / "Blocks"

---

## Integration Points

- **Input**: Approved plan file
- **Output**: Issues, renamed plan, git commit
- **Template**: `templates/ISSUE_TEMPLATE.md`
- **Consumed by**: `/plan` workflow command
