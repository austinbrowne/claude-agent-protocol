---
name: deepen-plan
version: "2.0"
description: Plan enrichment methodology with parallel research, review agents, past learnings, and optional Agent Teams mode
referenced_by:
  - commands/plan.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Plan Deepening Skill

Methodology for enriching a plan with parallel research, multi-agent review, and past learnings integration.

---

## When to Apply

- After generating a plan and before implementation
- Complex features where shallow planning leads to rework
- High-risk features (security, performance, breaking changes) that benefit from multi-agent scrutiny

---

## Step 0: Detect Execution Mode

**CRITICAL: Check your tool list RIGHT NOW.** Do NOT rely on what you did earlier in this conversation. Each skill invocation must re-evaluate independently — conversation history is not a valid signal for tool availability.

Check if the `TeamCreate` tool is available in your tool list.

- **Available** → follow `[TEAM MODE]` instructions throughout this skill
- **Not available** → follow `[SUBAGENT MODE]` instructions (existing Task tool behavior)

See `guides/AGENT_TEAMS_GUIDE.md` for full team formation patterns and best practices (Pattern B: Research + Review Team).

---

## Process

### Phase 1: Parse and Analyze Plan

1. **Load plan file** and parse into sections (problem, goals, solution, technical approach, phases, tests, security, risks, open questions)
2. **Classify each section by research needs** — codebase research, framework docs, security deep-dive, performance analysis, open questions

### Phase 2: Research Layer

#### `[TEAM MODE]`

Form a Research + Review Team. You (the Lead) act as Coordinator and Consolidator.

**Spawn research teammates:**

| Teammate | Condition | Reference |
|----------|-----------|-----------|
| Codebase Researcher (1 per section needing context) | Sections needing codebase context | `agents/research/codebase-researcher.md` |
| Learnings Researcher | Always (1 for entire plan) | `agents/research/learnings-researcher.md` |
| Framework Docs Researcher | If framework detected | `agents/research/framework-docs-researcher.md` |
| Best Practices Researcher | High-risk or novel sections | `agents/research/best-practices-researcher.md` |

**Research teammate spawn prompt template:**
```
You are a [research type] researching the codebase to support plan enrichment.
Read your research process from [agent definition file].

Research target:
[plan content / assigned sections]

CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.

Instructions:
- As you discover relevant findings, broadcast them to the team immediately
- Don't wait until you're done — share findings as you go
- If a reviewer asks for deeper research on a topic, prioritize that
- Post your final summary to the task list when complete
- Mark your task as done when finished
```

**Key difference from subagent mode:** Research teammates broadcast findings in real-time. Review teammates (spawned in Phase 3) can consume these findings as they arrive and adjust their focus accordingly.

#### `[SUBAGENT MODE]`

**CRITICAL: Launch ALL research subagents IN PARALLEL.**

| Agent | Condition | Reference |
|-------|-----------|-----------|
| Codebase Research (1 per section) | Sections needing codebase context | `agents/research/codebase-researcher.md` |
| Learnings Research | Always (1 for entire plan) | `agents/research/learnings-researcher.md` |
| Framework Docs Research | If framework detected | `agents/research/framework-docs-researcher.md` |
| Web Research | High-risk or novel sections | `agents/research/best-practices-researcher.md` |

**Total agents:** 3-8+ depending on plan size.

### Phase 3: Review Layer

#### `[TEAM MODE]`

**Spawn review teammates** (in the same team as research teammates — cross-communication enabled):

| Teammate | Reference |
|----------|-----------|
| Architecture Reviewer | `agents/review/architecture-reviewer.md` |
| Simplicity Reviewer | `agents/review/simplicity-reviewer.md` |
| Security Reviewer | `agents/review/security-reviewer.md` |
| Performance Reviewer | `agents/review/performance-reviewer.md` |
| Edge Case Reviewer | `agents/review/edge-case-reviewer.md` |
| Spec-Flow Reviewer | `agents/review/spec-flow-reviewer.md` |

**Review teammate spawn prompt template:**
```
You are a [reviewer type] reviewing a plan for quality and correctness.
Read your review process from [agent definition file].

Plan to review:
[plan content]

Research findings so far (from research teammates):
[accumulated findings broadcast by research teammates]

CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.

Instructions:
- Review the plan against your domain criteria
- If you need deeper research on a specific area, message a research teammate directly
  Example: "Learnings Researcher, do we have past solutions for rate limiting?"
- Message other reviewers about overlapping concerns
- Post findings with severity (CRITICAL/HIGH/MEDIUM/LOW) to the task list
- Mark your task as done when complete
```

**Cross-team communication:** Review teammates can message research teammates for deeper dives. Research teammates can broadcast findings that influence reviewers' focus.

#### `[SUBAGENT MODE]`

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

#### `[TEAM MODE]`

Check if the Learnings Researcher teammate found HIGH RELEVANCE solutions:
- If yes, message them directly: "Can you provide a detailed applicability assessment for [solution name]?"
- The teammate is still active and can respond without spawning a new agent
- For multiple solutions, send individual messages for each

#### `[SUBAGENT MODE]`

For each HIGH RELEVANCE solution found in Phase 2, launch a subagent to extract detailed applicability assessment.

### Phase 5: Consolidate and Enhance

1. **Merge all outputs** from research, review, and learnings phases
2. **Deduplicate findings** — if 3+ agents flag same issue, mark HIGH PRIORITY
3. **Update plan in-place** with `[DEEPENED]` annotations per section
4. **Add Enhancement Summary** at end of plan with counts, priority fixes, suggestions, learnings applied
5. **Save updated plan** — status: `DEEPENED_READY_FOR_REVIEW`

**`[TEAM MODE]` only:** After consolidation, shut down all teammates and clean up the team.

---

## Notes

- **Token cost:** 10-20+ agents. Use on complex plans where the investment pays off. Team mode uses more tokens but produces better-coordinated results.
- **In-place updates:** `[DEEPENED]` annotations make it easy to identify added content.
- **Phase 2 and Phase 3 run in parallel.** Phase 4 depends on Phase 2 learnings results.
- **Team mode advantage:** Research and review teammates communicate in real-time — reviewers can request deeper research, researchers can alert reviewers to important patterns.

---

## Integration Points

- **Input**: Plan file from generate-plan skill
- **Output**: Enriched plan with `[DEEPENED]` annotations
- **Agent definitions**: `agents/research/*.md`, `agents/review/*.md`
- **Consumed by**: `/plan` workflow command
