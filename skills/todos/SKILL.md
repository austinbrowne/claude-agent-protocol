---
name: todos
version: "1.0"
description: File-based todo tracking system using .todos/ directory
referenced_by:
  - skills/fresh-eyes-review/SKILL.md
  - skills/commit-and-pr/SKILL.md
  - skills/start-issue/SKILL.md
  - commands/start-issue.md
---

# File-Based Todo Tracking Skill

System for tracking review findings and tasks using committed markdown files.

---

## Directory Convention

All todo files live in `.todos/` at the project root. This directory is committed to git for persistence across sessions.

---

## File Naming Convention

```
.todos/{issue_id}-{status}-{priority}-{description-slug}.md
```

**Components:**
- `{issue_id}` — GitHub issue number or task identifier
- `{status}` — `pending` | `ready` | `complete`
- `{priority}` — `critical` | `high` | `medium` | `low`
- `{description-slug}` — kebab-case brief description (3-6 words)

**Examples:**
- `.todos/123-pending-critical-sql-injection-users-endpoint.md`
- `.todos/123-ready-high-missing-null-check-auth-service.md`
- `.todos/123-complete-medium-extract-magic-number.md`

---

## YAML Frontmatter Schema

```yaml
issue_id: "NNN"
status: pending | ready | complete
priority: critical | high | medium | low
title: "Brief description of finding or task"
source: fresh-eyes-review | review-plan | deepen-plan | manual
agent: security-reviewer | edge-case-reviewer | etc.
file: "path/to/affected/file.ts"
line: NNN
finding: "Description of the issue found"
action: "Specific action to take to resolve"
created: YYYY-MM-DD
resolved: YYYY-MM-DD
resolution_note: "What was done to fix it"
```

---

## Status Workflow

```
pending → ready → complete
```

- **pending** — Finding identified, not yet started
- **ready** — Acknowledged, ready to fix
- **complete** — Fixed and verified

When resolving a todo:
1. Update `status` field to `complete`
2. Fill in `resolved` date and `resolution_note`
3. Rename file to reflect new status

---

## Tracking Mode Selection

When creating findings, offer the user three modes:

| Mode | Storage | Best For |
|------|---------|----------|
| **File-based** | `.todos/` directory | Solo work, offline access |
| **GitHub issues** | `gh issue create` | Team collaboration |
| **Both** | `.todos/` + GitHub issues | Full traceability |

If a project's CLAUDE.md specifies a default tracking mode, use that without asking.

---

## Living Plans

The `.todos/` directory also stores living implementation plans:

**Filename:** `.todos/{issue_id}-plan.md`
**Template:** `templates/LIVING_PLAN_TEMPLATE.md`

Living plans track:
- Issue ID and title
- Branch name
- Acceptance criteria (checkboxes)
- Implementation steps (checkboxes)
- Past learnings applied
- Progress log with timestamps

---

## Template

See `templates/TODO_TEMPLATE.md` for the complete todo file structure.

---

## Integration Points

- **Created by**: `/fresh-eyes-review` (review findings), `/start-issue` (living plans)
- **Checked by**: `/commit-and-pr` (blocks on unresolved CRITICAL/HIGH)
- **Glob patterns for checking**:
  - `.todos/*-pending-critical-*.md` — unresolved critical findings
  - `.todos/*-pending-high-*.md` — unresolved high findings
