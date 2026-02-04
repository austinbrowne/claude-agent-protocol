---
name: brainstorm
version: "1.1"
description: Structured divergent thinking methodology for exploring solution approaches
referenced_by:
  - commands/plan.md
---

# Brainstorming Skill

Reusable methodology for structured divergent thinking before committing to a solution.

---

## When to Apply

- Multiple valid approaches exist for a problem
- Architecture or strategy decision with significant tradeoffs
- Team cannot agree on an approach
- Problem space is ambiguous or underexplored

## When to Skip

- Clear bug fixes with a single obvious solution
- Small tasks where the approach is dictated by existing patterns
- Direct instructions that leave no ambiguity

---

## Process

### 1. Assess Whether Brainstorming Adds Value

**Auto-skip criteria:**
- Clear bug fixes with a single obvious solution
- Tasks where the approach is dictated by existing patterns
- Direct instructions from user that leave no ambiguity

**If unclear whether brainstorming is worthwhile:**
- Ask the user whether to brainstorm or skip directly to PRD generation

### 2. Search Past Learnings

Before brainstorming, search `docs/solutions/` for relevant past decisions:

**Launch Learnings Research Agent via Task tool:**
```
subagent_type: "general-purpose"
description: "Search past learnings for brainstorm on [topic]"
prompt: "Follow agents/research/learnings-researcher.md.
  Search docs/solutions/ for past solutions relevant to: [topic]
  Run multi-pass Grep: tags → category → keywords → full-text.
  Return findings with relevance assessment."
```

If no results: note "No past learnings found" and continue.

### 3. Define Problem Space

Gather context from:
- `/explore` output (if available in conversation)
- User's topic description
- Codebase patterns (quick Grep for relevant keywords)
- Past learnings from step 2

Define:
1. **Core problem** — what are we trying to solve?
2. **Constraints** — hard limits (performance, security, compatibility)
3. **Preferences** — soft preferences (simplicity, extensibility)
4. **Context** — what the existing codebase already does
5. **Past learnings** — relevant findings from `docs/solutions/`

Present to user for validation before proceeding.

### 4. Generate 2-3 Approaches

For each approach, provide:

| Field | Description |
|-------|-------------|
| **Name** | Short, descriptive label |
| **Description** | How the approach works (2-4 sentences) |
| **Pros** | 2-4 concrete advantages |
| **Cons** | 2-4 concrete disadvantages |
| **Complexity** | Low / Medium / High |
| **Risk** | Low / Medium / High |
| **Effort** | Rough hours/days |
| **Fits existing patterns** | Yes / Partially / No |

**Guidelines:**
- At least one approach should be the "simplest thing that works"
- At least one approach should optimize for extensibility
- If a past learning applies, at least one approach should incorporate it
- Approaches should be genuinely different, not minor variations
- Be honest about tradeoffs — do not present a clear winner as if it were a tough choice

### 5. Comparison Matrix

```
| Criteria        | Approach 1 | Approach 2 | Approach 3 |
|-----------------|-----------|-----------|-----------|
| Complexity      |           |           |           |
| Risk            |           |           |           |
| Effort          |           |           |           |
| Maintainability |           |           |           |
| Security        |           |           |           |
| Performance     |           |           |           |
| Fits codebase   |           |           |           |

Recommendation: [Approach N] — [1-sentence rationale]
```

Present matrix and ask user for decision.

### 6. Capture to Document

After user decides:

**Directory:** `docs/brainstorms/`
**Filename:** `YYYY-MM-DD-{slug}-brainstorm.md`
**Template:** `templates/BRAINSTORM_TEMPLATE.md`

Populate with:
- Problem space
- All approaches with analysis
- Comparison matrix
- Chosen approach and rationale
- Past learnings referenced

**YAML frontmatter schema:**
```yaml
title: "Descriptive Title"
date: YYYY-MM-DD
status: decided | open | abandoned
chosen_approach: "Name of chosen approach"
tags: [keyword1, keyword2, keyword3]
related_solutions: []
feeds_into: "docs/prds/YYYY-MM-DD-feature-name.md"
```

---

## Notes

- **Not always needed:** Skip for clear bug fixes, small tasks, or when the approach is obvious
- **Past learnings integration:** Searches `docs/solutions/` to avoid repeating past mistakes
- **Human decides:** Claude recommends but the human always makes the final call
- **Captured for posterity:** Brainstorm doc records rejected alternatives and rationale
- **Pairs with ADR creation:** For major architectural decisions, create an ADR after brainstorming
- **Token efficiency:** Learnings research uses a subagent to avoid polluting main conversation context
- **2-3 approaches is the sweet spot:** More than 3 causes analysis paralysis; fewer than 2 is not really brainstorming

---

## Integration Points

- **Input from `/explore`**: Exploration findings inform the problem space
- **Input from `docs/solutions/`**: Past learnings prevent repeating mistakes
- **Output to PRD generation**: Chosen approach becomes the technical direction
- **Output to ADR creation**: Major decisions may warrant an ADR
- **Template**: `templates/BRAINSTORM_TEMPLATE.md`
