# Solution Template

Use this template when running `/compound` to capture solved problems as searchable, reusable solution docs.

---

```markdown
---
title: "Descriptive Title"
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
---

# [Title]

## Problem

**What happened:**
[Describe the problem clearly — what was the symptom, error, or unexpected behavior]

**Context:**
[What were you building/fixing when this came up?]

**Root cause:**
[What was actually wrong — the underlying issue, not just the symptom]

---

## Solution

**The fix:**
[Describe what you did to solve it — be specific enough that someone could reproduce]

**Key code/config:**
```
[Relevant code snippet, config change, or command — keep it minimal]
```

**Why it works:**
[Brief explanation of why this solution addresses the root cause]

---

## Gotchas

- [Thing that was tricky or easy to get wrong]
- [Edge case to watch for]
- [Common mistake when applying this solution]

---

## Prevention

**How to avoid this in the future:**
- [Specific practice, check, or pattern to adopt]

**Related patterns:**
- [Link to related solutions or documentation]

---

## Applicability

**Use this solution when:**
- [Condition 1]
- [Condition 2]

**Do NOT use when:**
- [Condition where this doesn't apply]
```

---

**Filename convention:** `docs/solutions/{category}-{description-slug}.md`

**Examples:**
- `docs/solutions/auth-jwt-refresh-token-race-condition.md`
- `docs/solutions/database-n-plus-one-eager-loading.md`
- `docs/solutions/testing-mock-external-api-timeout.md`
- `docs/solutions/security-xss-sanitize-user-html.md`
