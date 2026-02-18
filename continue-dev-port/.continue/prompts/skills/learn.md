---
name: learn
description: "Capture solved problems as searchable, reusable solution docs for knowledge compounding"
---

# Knowledge Compounding Skill

Methodology for capturing solved problems and making them discoverable for future sessions. Uses enum-validated YAML frontmatter and nested category directories compatible with the compound-engineering plugin's `compound-docs` skill.

---

## When to Apply

- After solving a tricky bug or unexpected behavior
- When discovering a gotcha that others will hit
- When a debugging session reveals a non-obvious root cause
- When you learn something important about a library, framework, or pattern
- Anytime knowledge would be lost if not written down

---

## Auto-Trigger Detection

You should proactively suggest capturing a learning when detecting these phrases in conversation:

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
Run /learn to capture, or ignore to skip.
```

---

## Extraction Process

### From Conversation Context

Scan conversation for:
1. **Problem** -- error messages, unexpected behavior, symptoms
2. **Root cause** -- the underlying issue, not just the symptom
3. **Solution** -- code changes, config changes, approach that fixed it
4. **Gotchas** -- tricky or non-obvious aspects, things easy to get wrong
5. **What didn't work** -- failed attempts and why they failed

Present extracted learning for user confirmation before saving.

### Manual Input (Standalone)

If no conversation context, prompt:
- What was the problem?
- What was the root cause?
- What was the fix?
- Any gotchas or things to watch for?

---

## Deduplication

### Multi-Pass Search

Before creating a new solution, search `docs/solutions/` with:

1. **Tag match** -- search for `tags:.*(keyword1|keyword2)` in `docs/solutions/`
2. **Module match** -- search for `module:.*ModuleName` in `docs/solutions/`
3. **Problem type match** -- search for `problem_type: performance_issue` in `docs/solutions/`
4. **Symptom match** -- keywords from observed symptoms
5. **Full-text** -- domain-specific keywords in body content

### Duplicate Handling

If potential duplicate found, present options:

1. **Update existing** -- merge new gotchas/details into existing doc
2. **Create new** -- this is a different enough problem (add cross-reference)
3. **Skip** -- existing solution already covers this

**WAIT** for user response before continuing.

---

## Solution Document Schema

### YAML Frontmatter (Enum-Validated)

```yaml
# Required fields
module: "Authentication"              # Module/area of the project
date: 2026-02-03                      # Date solved (YYYY-MM-DD)
problem_type: security_issue          # Enum -- determines subdirectory
component: auth                       # Enum -- technical component
symptoms:                             # Array of 1-5 observable symptoms
  - "JWT refresh token race condition"
  - "Sessions lost on concurrent requests"
root_cause: race_condition            # Enum -- fundamental cause
resolution_type: code_fix             # Enum -- type of fix
severity: high                        # Enum -- impact level
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

## Execution Steps

### Step 1: Detect or invoke

**If auto-suggest (trigger phrase detected):**
- Detect a trigger phrase in the user's message
- Suggest capturing the learning (see suggestion format above)
- Wait for user to invoke or decline

**If manual invoke:**
- Proceed directly to Step 2

**If direct mode (with explicit title):**
- Use provided title, proceed to Step 2

### Step 2: Extract the learning from context

**If conversation contains a recently solved problem:**

Scan conversation for:
1. **Problem:** What went wrong? (error messages, unexpected behavior, symptoms)
2. **Root cause:** What was actually wrong? (the underlying issue)
3. **Solution:** What fixed it? (code changes, config changes, approach)
4. **Gotchas:** What was tricky or non-obvious? (things easy to get wrong)

**Present extracted learning for confirmation:**
```
Extracted learning:

Title: [auto-generated or from explicit title]
Module: [detected module/area]
Problem type: [enum value]
Symptoms:
- [symptom 1]
- [symptom 2]
Root cause: [enum value] -- [explanation]
Solution: [extracted fix]
Gotchas:
- [gotcha 1]
- [gotcha 2]
```

Then ask:
1. **Yes** -- this is accurate, proceed
2. **Edit** -- let me correct some details
3. **Start over** -- re-extract from scratch

**WAIT** for user response before continuing.

**If no conversation context available (standalone invoke):**
- Prompt for manual input: problem, root cause, fix, gotchas

### Step 3: Check for existing duplicates

Search `docs/solutions/` using multi-pass search:

1. **Category narrowing:** If `problem_type` is known, search the specific subdirectory first
2. **Tag match:** Search for `tags:.*(keyword1|keyword2)` in `docs/solutions/`
3. **Module match:** Search for `module:.*ModuleName` in `docs/solutions/`
4. **Problem type match:** Search for `problem_type: enum_value` in `docs/solutions/`
5. **Symptom match:** Keywords from observed symptoms
6. **Full-text search:** Domain-specific keywords in body content

**If duplicate detected:**

Present options:
1. **Update existing** -- merge new gotchas/details into existing doc
2. **Create new** -- this is a different enough problem (add cross-reference)
3. **Skip** -- existing solution already covers this

**WAIT** for user response before continuing.

### Step 4: Generate solution document

**Determine metadata using enum-validated fields** (module, problem_type, component, symptoms, root_cause, resolution_type, severity, tags, language, framework, issue_ref).

**Load template from:** `templates/SOLUTION_TEMPLATE.md`

**Generate solution with full YAML frontmatter and structured content** (Problem, Environment, Symptoms, What Didn't Work, Solution, Why This Works, Prevention, Related Issues).

### Step 5: Save solution file

1. Create category subdirectory if needed (e.g., run `mkdir -p docs/solutions/{category-directory}`)
2. Generate filename: `{slug}-{YYYYMMDD}.md`
3. Check for collisions (append number if needed)
4. Save file

Note: Adjust commands for PowerShell on Windows (e.g., `mkdir -p` -> `New-Item -ItemType Directory -Force`).

### Step 6: Confirm with searchability note

Report: file location, searchable fields (module, problem_type, component, tags, symptoms, root_cause), and which commands will auto-discover this solution.

---

## Searchability

Solutions are discovered by the `learnings-researcher` agent using multi-pass search:

| Pass | Field | Example Search |
|------|-------|---------------|
| 1 | Tags | `tags:.*(jwt\|token)` |
| 2 | Module | `module:.*Authentication` |
| 3 | Problem type | `problem_type: security_issue` |
| 4 | Symptoms | `symptoms:.*race condition` |
| 5 | Full-text | Domain-specific keywords |

Category-based narrowing: search `docs/solutions/security-issues/` directly when problem type is clear.

Commands that auto-search past solutions:
- `/explore` -- finds past solutions for the explored area
- `/plan` (brainstorm) -- explores relevant approaches
- `/plan` (deepen) -- enriches plan with past learnings
- `/implement` (start-issue) -- surfaces relevant gotchas before implementation

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
- **Consumed by**: learnings-researcher agent, `/explore`, `/plan`, `/implement`
- **Template**: `templates/SOLUTION_TEMPLATE.md`
