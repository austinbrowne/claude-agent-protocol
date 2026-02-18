---
name: deepen-plan
description: "Plan enrichment with sequential research, multi-persona review, and past learnings"
---

# Plan Deepening Skill

Methodology for enriching a plan with research, multi-persona review, and past learnings integration.

---

## When to Apply

- After generating a plan and before implementation
- Complex features where shallow planning leads to rework
- High-risk features (security, performance, breaking changes) that benefit from multi-perspective scrutiny

---

## Process

### Phase 1: Parse and Analyze Plan

1. **Load plan file** and parse into sections (problem, goals, solution, technical approach, phases, tests, security, risks, open questions)
2. **Classify each section by research needs** -- codebase research, framework docs, security deep-dive, performance analysis, open questions

### Phase 2: Research Layer

Perform the following research steps sequentially. For each step, gather findings before proceeding to the next.

**Before starting:** Read each relevant research process definition and follow its methodology.

| Step | Research Type | Condition | Reference |
|------|--------------|-----------|-----------|
| 1 | Codebase Research (1 per section needing codebase context) | Sections needing codebase context | `agents/research/codebase-researcher.md` |
| 2 | Learnings Research | Always (1 for entire plan) | `agents/research/learnings-researcher.md` |
| 3 | Framework Docs Research | If framework detected | `agents/research/framework-docs-researcher.md` |
| 4 | Web Research | High-risk or novel sections | `agents/research/best-practices-researcher.md` |

### Phase 3: Review Layer

After research is complete, perform sequential reviews adopting each of the following reviewer personas. For each persona, review the plan content along with all accumulated research findings.

**For each reviewer:** Read the reviewer's definition file and follow its process. The reviewer should evaluate the plan content and research findings without needing to access any additional files.

| # | Reviewer Persona | Definition | Focus |
|---|-----------------|-----------|-------|
| 1 | Architecture Reviewer | `agents/review/architecture-reviewer.md` | Component boundaries, data flow, coupling, scalability |
| 2 | Simplicity Reviewer | `agents/review/simplicity-reviewer.md` | Over-engineering, YAGNI, unnecessary abstractions |
| 3 | Security Reviewer | `agents/review/security-reviewer.md` | OWASP, auth design, data protection, injection prevention |
| 4 | Performance Reviewer | `agents/review/performance-reviewer.md` | Latency, resource usage, N+1 queries, caching |
| 5 | Edge Case Reviewer | `agents/review/edge-case-reviewer.md` | Null handling, boundaries, empty states, race conditions |
| 6 | Spec-Flow Reviewer | `agents/review/spec-flow-reviewer.md` | Acceptance criteria testability, phase ordering, gaps |

**Review output format per persona:**
```
Return findings with severity (CRITICAL/HIGH/MEDIUM/LOW) and your overall assessment.
```

### Phase 4: Learnings Deep-Dive

For each HIGH RELEVANCE solution found in Phase 2 (Learnings Research), perform a detailed applicability assessment:
- How does this past solution apply to the current plan?
- What specific recommendations should be incorporated?
- What gotchas were documented that apply here?

### Phase 5: Consolidate and Enhance

1. **Merge all outputs** from research, review, and learnings phases
2. **Deduplicate findings** -- if 3+ reviewer personas flag the same issue, mark HIGH PRIORITY
3. **Update plan in-place** with `[DEEPENED]` annotations per section
4. **Add Enhancement Summary** at end of plan with counts, priority fixes, suggestions, learnings applied
5. **Save updated plan** -- status: `DEEPENED_READY_FOR_REVIEW`

---

## Notes

- **Thorough process:** Multiple research and review passes. Use on complex plans where the investment pays off.
- **In-place updates:** `[DEEPENED]` annotations make it easy to identify added content.
- **Phase 2 completes before Phase 3 starts.** Phase 4 depends on Phase 2 learnings results.

---

## Integration Points

- **Input**: Plan file from `/generate-plan`
- **Output**: Enriched plan with `[DEEPENED]` annotations
- **Agent definitions**: `agents/research/*.md`, `agents/review/*.md`
- **Consumed by**: `/review-plan`
