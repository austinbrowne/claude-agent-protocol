---
name: deepen-plan
version: "1.0"
description: Plan enrichment methodology with parallel research, review agents, and past learnings
referenced_by:
  - commands/plan.md
---

# Plan Deepening Skill

Methodology for enriching a PRD/plan with parallel research, multi-agent review, and past learnings integration.

---

## When to Apply

- After generating a PRD and before implementation
- Complex features where shallow planning leads to rework
- High-risk features (security, performance, breaking changes) that benefit from multi-agent scrutiny

---

## Process

### Phase 1: Parse and Analyze Plan

1. **Load PRD file** and parse into sections (problem, goals, solution, technical approach, phases, tests, security, risks, open questions)
2. **Classify each section by research needs** — codebase research, framework docs, security deep-dive, performance analysis, open questions

### Phase 2: Parallel Research Layer

**CRITICAL: Launch ALL research subagents IN PARALLEL.**

| Agent | Condition | Reference |
|-------|-----------|-----------|
| Codebase Research (1 per section) | Sections needing codebase context | `agents/research/codebase-researcher.md` |
| Learnings Research | Always (1 for entire plan) | `agents/research/learnings-researcher.md` |
| Framework Docs Research | If framework detected | `agents/research/framework-docs-researcher.md` |
| Web Research | High-risk or novel sections | `agents/research/best-practices-researcher.md` |

**Total agents:** 3-8+ depending on plan size.

### Phase 3: Parallel Review Layer

**CRITICAL: Launch ALL 6 review agents IN PARALLEL.**

| Agent | Reference |
|-------|-----------|
| Architecture Reviewer | `agents/review/architecture-reviewer.md` |
| Simplicity Reviewer | `agents/review/simplicity-reviewer.md` |
| Security Reviewer | `agents/review/security-reviewer.md` |
| Performance Reviewer | `agents/review/performance-reviewer.md` |
| Edge Case Reviewer | `agents/review/edge-case-reviewer.md` |
| Spec-Flow Reviewer | `agents/review/spec-flow-reviewer.md` |

### Phase 4: Learnings Deep-Dive

For each HIGH RELEVANCE solution found in Phase 2, launch a subagent to extract detailed applicability assessment.

### Phase 5: Consolidate and Enhance

1. **Merge all outputs** from research, review, and learnings phases
2. **Deduplicate findings** — if 3+ agents flag same issue, mark HIGH PRIORITY
3. **Update PRD in-place** with `[DEEPENED]` annotations per section
4. **Add Enhancement Summary** at end of PRD with counts, priority fixes, suggestions, learnings applied
5. **Save updated PRD** — status: `DEEPENED_READY_FOR_REVIEW`

---

## Notes

- **Token cost:** 10-20+ subagents. Use on complex plans where the investment pays off.
- **In-place updates:** `[DEEPENED]` annotations make it easy to identify added content.
- **Phase 2 and Phase 3 run in parallel.** Phase 4 depends on Phase 2 learnings results.

---

## Integration Points

- **Input**: PRD file from generate-prd skill
- **Output**: Enriched PRD with `[DEEPENED]` annotations
- **Agent definitions**: `agents/research/*.md`, `agents/review/*.md`
- **Consumed by**: `/plan` workflow command
