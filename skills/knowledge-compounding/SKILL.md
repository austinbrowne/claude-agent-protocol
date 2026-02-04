---
name: knowledge-compounding
version: "1.1"
description: Methodology for capturing solved problems as searchable, reusable solution docs — compatible with compound-engineering plugin
referenced_by:
  - commands/compound.md
  - commands/workflows/godmode.md
  - commands/start-issue.md
---

# Knowledge Compounding Skill

Methodology for capturing solved problems and making them discoverable for future sessions. Uses enum-validated YAML frontmatter and nested category directories compatible with the compound-engineering plugin's `compound-docs` skill.

---

## Auto-Trigger Detection

Claude should proactively suggest `/compound` when detecting these phrases in conversation:

- "the trick was"
- "the fix was"
- "root cause was"
- "I learned that"
- "next time we should"
- "key insight"
- "important gotcha"
- "the issue turned out to be"
- "what actually happened was"
- "the real problem was"
- "that worked"
- "it's fixed"
- "working now"

**Suggestion format:**
```
It sounds like you found an important insight:
"[relevant quote from user]"

Want to capture this as a reusable solution doc?
Run `/compound` to capture, or ignore to skip.
```

---

## Extraction Process

### From Conversation Context

Scan conversation for:
1. **Problem** — error messages, unexpected behavior, symptoms
2. **Root cause** — the underlying issue, not just the symptom
3. **Solution** — code changes, config changes, approach that fixed it
4. **Gotchas** — tricky or non-obvious aspects, things easy to get wrong
5. **What didn't work** — failed attempts and why they failed

Present extracted learning for user confirmation before saving.

### Manual Input (Standalone)

If no conversation context, prompt:
- What was the problem?
- What was the root cause?
- What was the fix?
- Any gotchas or things to watch for?

---

## Deduplication

### Multi-Pass Grep Search

Before creating a new solution, search `docs/solutions/` with:

1. **Tag match** — `tags:.*(keyword1|keyword2)`
2. **Module match** — `module:.*ModuleName`
3. **Problem type match** — `problem_type: performance_issue`
4. **Symptom match** — keywords from observed symptoms
5. **Full-text** — domain-specific keywords in body content

### Duplicate Handling

If potential duplicate found, offer:
1. **Update existing** — merge new gotchas/details into existing doc
2. **Create new** — this is a different enough problem (add cross-reference)
3. **Skip** — existing solution already covers this

---

## Solution Document Schema

### YAML Frontmatter (Enum-Validated)

```yaml
# Required fields
module: "Authentication"              # Module/area of the project
date: 2026-02-03                      # Date solved (YYYY-MM-DD)
problem_type: security_issue          # Enum — determines subdirectory
component: auth                       # Enum — technical component
symptoms:                             # Array of 1-5 observable symptoms
  - "JWT refresh token race condition"
  - "Sessions lost on concurrent requests"
root_cause: race_condition            # Enum — fundamental cause
resolution_type: code_fix             # Enum — type of fix
severity: high                        # Enum — impact level
tags: [jwt, refresh-token, race-condition, concurrency]

# Optional fields
language: typescript
framework: express
framework_version: 4.18.2
issue_ref: "#145"
related_solutions: []
```

### Enum Values

**problem_type** (determines `docs/solutions/` subdirectory):
`build_error`, `test_failure`, `runtime_error`, `performance_issue`, `database_issue`, `security_issue`, `ui_bug`, `integration_issue`, `logic_error`, `developer_experience`, `workflow_issue`, `best_practice`, `documentation_gap`

**component:**
`model`, `controller`, `view`, `service`, `background_job`, `database`, `frontend`, `realtime`, `api_client`, `auth`, `payments`, `config`, `testing`, `tooling`, `documentation`

**root_cause:**
`missing_association`, `missing_eager_load`, `missing_index`, `wrong_api`, `scope_error`, `race_condition`, `async_timing`, `memory_issue`, `config_error`, `logic_error`, `test_isolation`, `missing_validation`, `missing_permission`, `type_error`, `encoding_error`, `dependency_issue`

**resolution_type:**
`code_fix`, `migration`, `config_change`, `test_fix`, `dependency_update`, `environment_setup`, `workflow_improvement`, `documentation_update`, `tooling_addition`

**severity:**
`critical`, `high`, `medium`, `low`

### Category Directory Mapping

| problem_type | Directory |
|-------------|-----------|
| `build_error` | `docs/solutions/build-errors/` |
| `test_failure` | `docs/solutions/test-failures/` |
| `runtime_error` | `docs/solutions/runtime-errors/` |
| `performance_issue` | `docs/solutions/performance-issues/` |
| `database_issue` | `docs/solutions/database-issues/` |
| `security_issue` | `docs/solutions/security-issues/` |
| `ui_bug` | `docs/solutions/ui-bugs/` |
| `integration_issue` | `docs/solutions/integration-issues/` |
| `logic_error` | `docs/solutions/logic-errors/` |
| `developer_experience` | `docs/solutions/developer-experience/` |
| `workflow_issue` | `docs/solutions/workflow-issues/` |
| `best_practice` | `docs/solutions/best-practices/` |
| `documentation_gap` | `docs/solutions/documentation-gaps/` |

### File Naming

- Format: `docs/solutions/{category-directory}/{slug}-{YYYYMMDD}.md`
- Slug: kebab-case, 3-6 words from title
- Example: `docs/solutions/security-issues/jwt-refresh-token-race-condition-20260203.md`

---

## Searchability

Solutions are discovered by the `learnings-researcher` agent using multi-pass Grep:

| Pass | Field | Example Grep |
|------|-------|-------------|
| 1 | Tags | `tags:.*(jwt\|token)` |
| 2 | Module | `module:.*Authentication` |
| 3 | Problem type | `problem_type: security_issue` |
| 4 | Symptoms | `symptoms:.*race condition` |
| 5 | Full-text | Domain-specific keywords |

Category-based narrowing: search `docs/solutions/security-issues/` directly when problem type is clear.

Commands that auto-search past solutions:
- `/brainstorm` — explores relevant approaches
- `/deepen-plan` — enriches plan with past learnings
- `/start-issue` — surfaces relevant gotchas before implementation
- `/explore` — finds past solutions for the explored area

---

## Compatibility

This schema is compatible with the compound-engineering plugin's `compound-docs` skill:
- Same `docs/solutions/` root directory
- Same nested category subdirectories
- Same YAML frontmatter fields (`module`, `problem_type`, `component`, `symptoms`, `root_cause`, `severity`, `tags`)
- Same `learnings-researcher` agent search patterns

Docs created by either system are searchable by both.

---

## Integration Points

- **Input from conversation**: Trigger detection and context extraction
- **Output to `docs/solutions/{category}/`**: Persisted solution document
- **Consumed by**: learnings-researcher agent, `/brainstorm`, `/deepen-plan`, `/start-issue`, `/explore`
- **Template**: `templates/SOLUTION_TEMPLATE.md`
