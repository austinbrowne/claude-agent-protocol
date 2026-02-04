---
name: create-issues
version: "1.0"
description: GitHub issue generation from approved PRD with auto-linking and git commit
referenced_by:
  - commands/plan.md
---

# Issue Creation Skill

Methodology for generating GitHub issues from an approved PRD, with auto-linking, PRD renaming, and git commit.

---

## When to Apply

- After PRD has been reviewed and approved
- Ready to break PRD into implementation tasks
- Want to create backlog of work or start immediately

---

## Process

### 1. Parse PRD and Extract Implementation Tasks

- Load PRD content
- Identify Implementation Plan section (Section 5 in Full PRD, or infer from Lite PRD)
- Each phase → one GitHub issue; Lite PRD → single issue

### 2. Generate GitHub Issues

**Load issue template:** `templates/GITHUB_ISSUE_TEMPLATE.md`

**For each phase/task:**
```bash
gh issue create \
  --title "Phase N: [Phase name]" \
  --body-file /tmp/issue-body.md \
  --label "type: feature,priority: high"
```

**Auto-detect labels from PRD:** Type (Feature/Bug Fix/Enhancement), Priority, Status, Flags (security-sensitive, performance-critical, breaking-change).

**Execution modes:**
- `--immediate`: Add `--assignee @me`
- `--backlog`: No assignee

### 3. Rename PRD with First Issue Number

**Current:** `docs/prds/YYYY-MM-DD-feature-name.md`
**New:** `docs/prds/NNN-YYYY-MM-DD-feature-name.md`

### 4. Update First Issue with PRD Reference

```bash
gh issue edit NNN --add-body "## PRD Reference\n**Source PRD:** \`docs/prds/NNN-YYYY-MM-DD-feature-name.md\`"
```

### 5. Commit PRD to Git and Push

```bash
git add docs/prds/NNN-YYYY-MM-DD-feature-name.md
git commit -m "docs: add PRD for [feature] (Issue #NNN)"
git push
```

---

## Notes

- **PRD renaming** creates direct link between PRD and implementation
- **Git commit is mandatory** — ensures PRD is available to team and in future sessions
- **Phases → Issues**: Each implementation phase becomes one GitHub issue
- **Related issues**: Dependencies linked with "Depends on" / "Blocks"

---

## Integration Points

- **Input**: Approved PRD file
- **Output**: GitHub issues, renamed PRD, git commit
- **Template**: `templates/GITHUB_ISSUE_TEMPLATE.md`
- **Consumed by**: `/plan` workflow command
