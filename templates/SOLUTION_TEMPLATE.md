# Solution Template

Use this template when running `/learn` to capture solved problems as searchable, reusable solution docs.

**Compatible with:** compound-engineering plugin `compound-docs` skill (shared `docs/solutions/` directory and YAML frontmatter schema).

---

## YAML Frontmatter Schema

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `module` | string | Module/area of the project (e.g., "Authentication", "API", "Database") |
| `date` | string | Date solved (YYYY-MM-DD) |
| `problem_type` | enum | Primary category — determines subdirectory |
| `component` | enum | Technical component involved |
| `symptoms` | array | 1-5 specific observable symptoms |
| `root_cause` | enum | Fundamental cause of the problem |
| `resolution_type` | enum | Type of fix applied |
| `severity` | enum | Impact severity |
| `tags` | array | Searchable keywords (lowercase, hyphen-separated) |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `language` | string | Language (e.g., "typescript", "python", "ruby") |
| `framework` | string | Framework (e.g., "express", "django", "rails") |
| `framework_version` | string | Framework version in X.Y.Z format |
| `issue_ref` | string | GitHub issue reference (e.g., "#145") |
| `related_solutions` | array | Paths to related solution docs |

### Enum Values

**problem_type** (determines subdirectory):
- `build_error` → `docs/solutions/build-errors/`
- `test_failure` → `docs/solutions/test-failures/`
- `runtime_error` → `docs/solutions/runtime-errors/`
- `performance_issue` → `docs/solutions/performance-issues/`
- `database_issue` → `docs/solutions/database-issues/`
- `security_issue` → `docs/solutions/security-issues/`
- `ui_bug` → `docs/solutions/ui-bugs/`
- `integration_issue` → `docs/solutions/integration-issues/`
- `logic_error` → `docs/solutions/logic-errors/`
- `developer_experience` → `docs/solutions/developer-experience/`
- `workflow_issue` → `docs/solutions/workflow-issues/`
- `best_practice` → `docs/solutions/best-practices/`
- `documentation_gap` → `docs/solutions/documentation-gaps/`

**component:**
- `model` — Data models, ORM, ActiveRecord, SQLAlchemy, Prisma
- `controller` — Request handlers, routes, endpoints
- `view` — Templates, components, UI rendering
- `service` — Service objects, business logic modules
- `background_job` — Async workers, queues, cron jobs
- `database` — Migrations, queries, schema, indexes
- `frontend` — Client-side JS, Stimulus, React, Vue
- `realtime` — WebSockets, SSE, Turbo Streams, live updates
- `api_client` — External API integrations, HTTP clients
- `auth` — Authentication, authorization, sessions
- `payments` — Billing, subscriptions, payment processing
- `config` — Environment, settings, deployment config
- `testing` — Test setup, fixtures, mocks, test utilities
- `tooling` — Scripts, generators, CLI tools, dev tooling
- `documentation` — Docs, README, inline comments

**root_cause:**
- `missing_association` — Incorrect model relationships
- `missing_eager_load` — N+1 queries, missing includes/joins
- `missing_index` — Database performance from missing indexes
- `wrong_api` — Using deprecated or incorrect API
- `scope_error` — Incorrect query scope or filtering
- `race_condition` — Concurrency, thread safety issues
- `async_timing` — Async/background job timing problems
- `memory_issue` — Memory leaks or excessive allocation
- `config_error` — Configuration or environment misconfiguration
- `logic_error` — Algorithm or business logic bug
- `test_isolation` — Test pollution, fixture issues
- `missing_validation` — Missing input or model validation
- `missing_permission` — Authorization check missing
- `type_error` — Type mismatch, missing type guards
- `encoding_error` — Character encoding, unicode issues
- `dependency_issue` — Dependency version conflict or bug

**resolution_type:**
- `code_fix` — Fixed by changing source code
- `migration` — Fixed by database migration
- `config_change` — Fixed by changing configuration
- `test_fix` — Fixed by correcting tests
- `dependency_update` — Fixed by updating dependency
- `environment_setup` — Fixed by environment configuration
- `workflow_improvement` — Improved development process
- `documentation_update` — Added or updated documentation
- `tooling_addition` — Added helper script or automation

**severity:**
- `critical` — Blocks production or development
- `high` — Impairs core functionality
- `medium` — Affects specific feature
- `low` — Minor issue or edge case

---

## Document Template

```markdown
---
module: [Module name or project area]
date: [YYYY-MM-DD]
problem_type: [enum value]
component: [enum value]
symptoms:
  - [Observable symptom 1 — specific error message or behavior]
  - [Observable symptom 2 — what was actually seen/experienced]
root_cause: [enum value]
resolution_type: [enum value]
severity: [critical|high|medium|low]
tags: [keyword1, keyword2, keyword3]
language: [optional — e.g., typescript]
framework: [optional — e.g., express]
issue_ref: [optional — e.g., "#145"]
---

# Troubleshooting: [Clear Problem Title]

## Problem
[1-2 sentence clear description of the issue]

## Environment
- Module: [Name or project area]
- Language/Framework: [e.g., TypeScript / Express]
- Affected Component: [e.g., "Auth service", "User model", "API endpoint"]
- Date: [YYYY-MM-DD]

## Symptoms
- [Observable symptom 1 — what was seen/experienced]
- [Observable symptom 2 — error messages, visual issues]

## What Didn't Work

**Attempted Solution 1:** [Description]
- **Why it failed:** [Technical reason]

**Attempted Solution 2:** [Description]
- **Why it failed:** [Technical reason]

[If first attempt worked:]
**Direct solution:** The problem was identified and fixed on the first attempt.

## Solution

[The actual fix — specific details]

**Code changes** (if applicable):
```
# Before (broken):
[Problematic code]

# After (fixed):
[Corrected code with explanation]
```

## Why This Works

1. What was the ROOT CAUSE?
2. Why does the solution address this root cause?
3. What was the underlying issue?

## Prevention

- [Specific practice or pattern to follow]
- [What to watch out for]
- [How to catch this early]

## Related Issues

- See also: [related-issue.md](../category/related-issue.md)
```

---

**File naming:** `docs/solutions/{problem_type-directory}/{slug}-{YYYYMMDD}.md`

**Examples:**
- `docs/solutions/performance-issues/n-plus-one-user-dashboard-20260203.md`
- `docs/solutions/security-issues/jwt-refresh-token-race-condition-20260203.md`
- `docs/solutions/runtime-errors/bcrypt-compare-missing-await-20260203.md`
- `docs/solutions/logic-errors/payment-rounding-precision-20260203.md`
