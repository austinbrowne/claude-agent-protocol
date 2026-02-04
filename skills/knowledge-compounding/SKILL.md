---
name: knowledge-compounding
version: "1.0"
description: Methodology for capturing solved problems as searchable, reusable solution docs
referenced_by:
  - commands/compound.md
  - commands/workflows/godmode.md
  - commands/start-issue.md
---

# Knowledge Compounding Skill

Methodology for capturing solved problems and making them discoverable for future sessions.

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

1. **Title/summary match** — keywords from extracted title and problem
2. **Category match** — same category (e.g., `category: auth`)
3. **Tag overlap** — matching tags (e.g., `tags:.*jwt|tags:.*token`)

### Duplicate Handling

If potential duplicate found, offer:
1. **Update existing** — merge new gotchas/details into existing doc
2. **Create new** — this is a different enough problem (add cross-reference)
3. **Skip** — existing solution already covers this

---

## Solution Document Schema

### YAML Frontmatter

```yaml
title: "Descriptive problem/solution title"
category: auth | api | database | testing | security | performance | error-handling | architecture | devops | refactoring | debugging
tags: [keyword1, keyword2, keyword3]
language: agnostic | python | javascript | typescript | go | rust | ruby | java
framework: agnostic | django | express | nextjs | rails | spring
complexity: simple | moderate | complex
confidence: high | medium | low
discovered: YYYY-MM-DD
issue_ref: "#NNN"
problem_summary: "One-line problem description"
solution_summary: "One-line solution description"
status: validated | draft | deprecated
related_solutions: []
```

### Document Sections

1. **Problem** — what happened, context, root cause
2. **Solution** — the fix, key code/config, why it works
3. **Gotchas** — tricky aspects, edge cases to watch for
4. **Prevention** — how to avoid in the future, related patterns
5. **Applicability** — when to use this solution, when NOT to use it

### File Naming

- Format: `docs/solutions/{category}-{description-slug}.md`
- Slug: kebab-case, 3-6 words from title
- Example: `docs/solutions/auth-jwt-refresh-token-race-condition.md`

### Category Taxonomy (Fixed)

Use only these categories for consistent search:
`auth`, `api`, `database`, `testing`, `security`, `performance`, `error-handling`, `architecture`, `devops`, `refactoring`, `debugging`

---

## Searchability

Solutions are discovered by the `learnings-researcher` agent using multi-pass Grep:

| Pass | Field | Example Grep |
|------|-------|-------------|
| 1 | Tags | `tags:.*jwt\|tags:.*token` |
| 2 | Category | `category: auth` |
| 3 | Problem summary | `refresh.*token\|race.*condition` |
| 4 | Full-text | Domain-specific keywords |

Commands that auto-search past solutions:
- `/brainstorm` — explores relevant approaches
- `/deepen-plan` — enriches plan with past learnings
- `/start-issue` — surfaces relevant gotchas before implementation
- `/explore` — finds past solutions for the explored area

---

## Integration Points

- **Input from conversation**: Trigger detection and context extraction
- **Output to `docs/solutions/`**: Persisted solution document
- **Consumed by**: learnings-researcher agent, `/brainstorm`, `/deepen-plan`, `/start-issue`, `/explore`
- **Template**: `templates/SOLUTION_TEMPLATE.md`
