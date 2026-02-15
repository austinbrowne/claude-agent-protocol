# Project Integration Guide

This is a router file. Read the guide that matches your detected platform.

## Platform Detection

If you haven't detected the platform yet, see `~/.claude/platforms/detect.md`.

## Platform-Specific Guides

| Platform | Guide |
|----------|-------|
| **GitHub** | `~/.claude/guides/GITHUB_PROJECT_INTEGRATION.md` |
| **GitLab** | `~/.claude/guides/GITLAB_PROJECT_INTEGRATION.md` |

## Common Concepts (All Platforms)

Regardless of platform, the project workflow follows the same pattern:

1. **Set up labels** — Consistent label system for type, priority, status, area, flags
2. **Create project board** — Kanban-style board with columns: Backlog → Ready → In Progress → Review → Done
3. **Create issues from PRD** — Each implementation phase becomes one issue
4. **Track progress** — Move issues across board columns as work progresses
5. **Link PRs/MRs to issues** — Use "Closes #NNN" syntax for auto-close on merge

## Label Convention

Both platforms support labels. Use consistent naming:

| Category | GitHub Format | GitLab Format (scoped) |
|----------|--------------|----------------------|
| Type | `type: feature` | `type::feature` |
| Priority | `priority: high` | `priority::high` |
| Status | `status: ready` | `status::ready` |
| Area | `area: backend` | `area::backend` |
| Flags | `security-sensitive` | `security-sensitive` |

**Note:** GitLab scoped labels (using `::`) automatically enforce mutual exclusivity — assigning `priority::low` removes `priority::high`.
