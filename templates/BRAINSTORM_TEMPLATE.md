# Brainstorm Template

Use this template when running `/brainstorm` to capture divergent thinking before committing to a solution.

---

```markdown
---
title: "[Descriptive Title]"
date: YYYY-MM-DD
status: decided | open | abandoned
chosen_approach: "[Name of chosen approach, if decided]"
tags: [keyword1, keyword2, keyword3]
related_solutions: []
feeds_into: "[PRD reference, e.g., docs/prds/YYYY-MM-DD-feature-name.md]"
---

# Brainstorm: [Title]

## Problem Space

**Context:**
[What problem are we solving? What constraints exist?]

**Exploration findings:**
[Summary from `/explore` if run, or codebase context]

**Past learnings:**
[Relevant solutions from `docs/solutions/`, if any]

---

## Approach 1: [Name]

**Description:**
[How this approach works]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Complexity:** Low | Medium | High
**Risk:** Low | Medium | High
**Effort estimate:** [X hours/days]

---

## Approach 2: [Name]

**Description:**
[How this approach works]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Complexity:** Low | Medium | High
**Risk:** Low | Medium | High
**Effort estimate:** [X hours/days]

---

## Approach 3: [Name] (optional)

**Description:**
[How this approach works]

**Pros:**
- [Advantage 1]

**Cons:**
- [Disadvantage 1]

**Complexity:** Low | Medium | High
**Risk:** Low | Medium | High
**Effort estimate:** [X hours/days]

---

## Comparison Matrix

| Criteria | Approach 1 | Approach 2 | Approach 3 |
|----------|-----------|-----------|-----------|
| Complexity | | | |
| Risk | | | |
| Effort | | | |
| Maintainability | | | |
| Security | | | |
| Performance | | | |

---

## Decision

**Chosen approach:** [Name]

**Rationale:**
[Why this approach was selected over alternatives]

**Rejected alternatives rationale:**
- [Approach X]: [Why rejected]

---

## Next Steps

- [ ] Generate PRD: `/generate-prd`
- [ ] Create ADR if architectural decision: `/create-adr`
```

---

**Filename convention:** `docs/brainstorms/YYYY-MM-DD-{slug}-brainstorm.md`

**Examples:**
- `docs/brainstorms/2025-12-15-auth-strategy-brainstorm.md`
- `docs/brainstorms/2025-12-20-caching-approach-brainstorm.md`
