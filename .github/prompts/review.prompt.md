---
description: "Multi-perspective fresh-eyes code review — parallel subagent reviewers for security, edge cases, and quality"
agent: reviewer
argument-hint: "scope to review (blank for all staged changes)"
---

Run a multi-perspective fresh-eyes code review on staged changes. Dispatch parallel subagent reviewers for:
- **Security** — OWASP Top 10, injection, auth, secrets
- **Edge cases** — null, empty, boundary, type coercion
- **Code quality** — naming, structure, complexity, SOLID, DRY

Consolidate findings, classify verdict (BLOCK / FIX_BEFORE_COMMIT / APPROVED_WITH_NOTES / APPROVED), and present actionable report.
