---
name: deepen-plan
version: "2.0"
description: Plan enrichment methodology with parallel research, review agents, and past learnings
referenced_by:
  - commands/plan.md
---

# Plan Deepening Skill

Methodology for enriching a plan with parallel research, multi-agent review, and past learnings integration.

---

## When to Apply

- After generating a plan and before implementation
- Complex features where shallow planning leads to rework
- High-risk features (security, performance, breaking changes) that benefit from multi-agent scrutiny

---

## Process

### Phase 1: Parse and Analyze Plan

1. **Load plan file** and parse into sections (problem, goals, solution, technical approach, phases, tests, security, risks, open questions)
2. **Classify each section by research needs** — codebase research, framework docs, security deep-dive, performance analysis, open questions

### Phase 2: Research Layer

<!-- Research agent config — canonical source: agents/research/DISPATCH_TABLE.md -->

**CRITICAL: Launch ALL research agents IN PARALLEL.**

**Before launching:** The orchestrator reads each agent's definition file and inlines the content into the prompt. Research agents still need file access (Grep, Read, Glob) to explore the codebase — that's their job. But they should NOT need to read their own definition file.

| Agent | Condition | Model | Reference |
|-------|-----------|-------|-----------|
| Codebase Research (1 per section) | Sections needing codebase context | (built-in) | `agents/research/codebase-researcher.md` |
| Learnings Research | Always (1 for entire plan) | haiku | `agents/research/learnings-researcher.md` |
| Framework Docs Research | If framework detected | haiku | `agents/research/framework-docs-researcher.md` |
| Web Research | High-risk or novel sections | haiku | `agents/research/best-practices-researcher.md` |

**Total agents:** 3-8+ depending on plan size.

### Phase 3: Review Layer

**CRITICAL: Launch ALL 6 review agents IN PARALLEL.**

**Before launching:** The orchestrator reads each reviewer's definition file and inlines the content. Review agents should NOT need to read any files — they get plan content, research findings, and their definition all inline.

**Model selection:** When spawning each agent via Task tool, pass the `model` parameter matching the agent's tier from the tables above and in Phase 2. For research agents using `subagent_type: "general-purpose"`, pass `model: "haiku"`. The `Explore` subagent type manages its own model internally. For review agents, pass the model from the table (opus for Architecture/Security, sonnet for others).

| Agent | Definition | Model |
|-------|-----------|-------|
| Architecture Reviewer | `agents/review/architecture-reviewer.md` | opus |
| Simplicity Reviewer | `agents/review/simplicity-reviewer.md` | sonnet |
| Security Reviewer | `agents/review/security-reviewer.md` | opus |
| Performance Reviewer | `agents/review/performance-reviewer.md` | sonnet |
| Edge Case Reviewer | `agents/review/edge-case-reviewer.md` | sonnet |
| Spec-Flow Reviewer | `agents/review/spec-flow-reviewer.md` | sonnet |

**Review agent prompt template:**
```
You are a [reviewer type] reviewing a plan for quality and correctness.

YOUR REVIEW PROCESS:
[inline content from agents/review/[agent].md]

Plan to review:
[plan content]

Research findings:
[accumulated findings from Phase 2 research agents]

CRITICAL RULES:
- Do NOT use Bash, Grep, Glob, Read, Write, or Edit tools. ZERO tool calls to access files.
- Everything you need is in this prompt. Do NOT read additional files for "context."
- Return ALL findings as text in your response. Do NOT write findings to files.
- No /tmp files, no intermediary files, no analysis documents. Text response ONLY.

Return findings with severity (CRITICAL/HIGH/MEDIUM/LOW) and your overall assessment.
```

### Phase 4: Learnings Deep-Dive

For each HIGH RELEVANCE solution found in Phase 2, launch a subagent to extract detailed applicability assessment.

### Phase 5: Consolidate and Enhance

1. **Merge all outputs** from research, review, and learnings phases
2. **Deduplicate findings** — if 3+ agents flag same issue, mark HIGH PRIORITY
3. **Update plan in-place** with `[DEEPENED]` annotations per section
4. **Add Enhancement Summary** at end of plan with counts, priority fixes, suggestions, learnings applied
5. **Save updated plan** — status: `DEEPENED_READY_FOR_REVIEW`

---

## Notes

- **Token cost:** 10-20+ agents. Use on complex plans where the investment pays off.
- **In-place updates:** `[DEEPENED]` annotations make it easy to identify added content.
- **Phase 2 and Phase 3 run in parallel.** Phase 4 depends on Phase 2 learnings results.

---

## Integration Points

- **Input**: Plan file from generate-plan skill
- **Output**: Enriched plan with `[DEEPENED]` annotations
- **Agent definitions**: `agents/research/*.md`, `agents/review/*.md`
- **Consumed by**: `/plan` workflow command
