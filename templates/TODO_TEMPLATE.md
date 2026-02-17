# Todo Template

Use this template for file-based tracking in `.todos/` directory.

---

```markdown
---
issue_id: "NNN"
status: pending | ready | complete
priority: critical | high | medium | low
title: "Brief description of finding or task"
source: fresh-eyes-review | review-plan | deepen-plan | manual
agent: security-reviewer | code-quality-reviewer | edge-case-reviewer | performance-reviewer | api-contract-reviewer | concurrency-reviewer | error-handling-reviewer | dependency-reviewer | testing-adequacy-reviewer | documentation-reviewer | supervisor | adversarial-validator
file: "path/to/affected/file.ts"
line: NNN
finding: "Description of the issue found"
action: "Specific action to take to resolve"
created: YYYY-MM-DD
resolved: YYYY-MM-DD
resolution_note: "What was done to fix it"
---

# [Title]

## Finding

**Agent:** [Which review agent found this]
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**File:** `[file:line]`

**Description:**
[Detailed description of the issue]

## Required Action

[Specific steps to fix the issue]

## Resolution

**Status:** Pending | Complete
**Date resolved:** [YYYY-MM-DD]
**What was done:**
[Description of the fix applied]
```

---

**Filename convention:** `.todos/{issue_id}-{status}-{priority}-{description-slug}.md`

**Status transitions:** `pending` → `ready` → `complete`

When a todo is resolved:
1. Update the `status` field in frontmatter to `complete`
2. Fill in `resolved` date and `resolution_note`
3. Rename file to reflect new status: `{issue_id}-complete-{priority}-{slug}.md`

**Examples:**
- `.todos/123-pending-critical-sql-injection-users-endpoint.md`
- `.todos/123-ready-high-missing-null-check-auth-service.md`
- `.todos/123-complete-medium-extract-magic-number.md`
