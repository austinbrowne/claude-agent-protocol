---
name: review-plan
version: "1.1"
description: Multi-agent plan review methodology with adversarial validation
referenced_by:
  - commands/plan.md
---

# Plan Review Skill

5-agent review process for validating plans before implementation.

---

## When to Apply

- After generating a PRD (via generate-prd skill) and optionally deepening it
- Before creating issues and starting implementation
- As a formal approval gate between planning and execution

---

## Prerequisites

- PRD/plan file exists
- Plan should be in `READY_FOR_REVIEW` or `DEEPENED_READY_FOR_REVIEW` status

---

## Agent Configuration

### 4 Specialist Reviewers (Parallel)

All 4 launch simultaneously in a single message with multiple Task calls.

| Agent | Definition | Focus |
|-------|-----------|-------|
| Architecture Reviewer | `agents/review/architecture-reviewer.md` | Component boundaries, data flow, coupling, scalability |
| Simplicity Reviewer | `agents/review/simplicity-reviewer.md` | Over-engineering, YAGNI, unnecessary abstractions |
| Spec-Flow Reviewer | `agents/review/spec-flow-reviewer.md` | Acceptance criteria testability, phase ordering, gaps |
| Security Reviewer | `agents/review/security-reviewer.md` | OWASP, auth design, data protection, injection prevention |

### Adversarial Validator (Sequential, after 4 specialists)

Receives the plan AND all 4 reviewer outputs.

| Agent | Definition | Focus |
|-------|-----------|-------|
| Adversarial Validator | `agents/review/adversarial-validator.md` | Challenge plan claims, challenge reviewer findings, find blind spots |

---

## Execution Steps

### Step 1: Load PRD/plan

**If path provided:**
- Read specified PRD file

**If no path:**
- Check conversation for most recent PRD reference
- If not found, list available PRDs: `ls docs/prds/*.md`
- Ask user to select

**Read the full PRD content** for use in all reviewer prompts.

### Step 2: Launch 4 review agents IN PARALLEL

**CRITICAL: Launch ALL 4 agents in a SINGLE message with multiple Task calls.**

Each reviewer receives ONLY the PRD content (zero conversation context).

**Reviewer prompt template:**
```
You are a [specialist type]. Reference [agent definition file].

Review this plan:
[full PRD content]

Evaluate: [agent-specific criteria]

Return:
VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
FINDINGS:
- [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding]
SUMMARY: [1-2 sentence assessment]
```

**Agent-specific evaluation criteria:**

- **Architecture:** Component decomposition, data flow, dependency management, scalability, consistency, separation of concerns
- **Simplicity:** Over-engineering, YAGNI, abstraction level, phase simplification, technology choices, cognitive load
- **Spec-Flow:** Acceptance criteria testability, phase ordering, dependencies, success metrics, completeness, edge cases, user flow
- **Security:** Authentication/authorization design, data protection, input validation, injection prevention, secrets management, transport security, error handling, logging

### Step 3: Launch Adversarial Validator AFTER all 4 complete

**Adversarial Validator receives:**
- Full PRD content
- All 4 reviewer outputs

**Tasks:**
1. Challenge plan claims — assumptions validated? Estimates realistic? Hidden dependencies?
2. Challenge reviewer findings — false positives? False negatives? Contradictions?
3. Identify systemic blind spots — what is nobody thinking about?

---

## Verdict Consolidation

### Individual Verdicts to Overall Verdict

| Condition | Overall Verdict |
|-----------|----------------|
| Any CRITICAL finding from reviewer or adversarial | REVISION_REQUESTED |
| 2+ reviewers return REVISION_REQUESTED | REVISION_REQUESTED |
| 1 reviewer REVISION_REQUESTED (non-critical) | APPROVED_WITH_NOTES |
| All APPROVED, adversarial finds LOW/MEDIUM | APPROVED_WITH_NOTES |
| All APPROVED, no adversarial concerns | APPROVED |

---

## Revision Workflow

If REVISION_REQUESTED:
1. User updates PRD with priority fixes
2. Re-run plan review (all 5 agents run fresh)
3. Each run is independent — no memory of previous reviews

---

## Report Format

```
=== PLAN REVIEW REPORT ===

Plan: [filename]
Date: YYYY-MM-DD
Reviewers: Architecture, Simplicity, Spec-Flow, Security + Adversarial Validator

=== REVIEWER VERDICTS ===
| Reviewer     | Verdict             |
|--------------|---------------------|
| Architecture | [verdict]           |
| Simplicity   | [verdict]           |
| Spec-Flow    | [verdict]           |
| Security     | [verdict]           |

=== PRIORITY FIXES ===
1. [CRITICAL/HIGH] [finding] — Source: [reviewer]

=== NON-BLOCKING SUGGESTIONS ===
1. [MEDIUM/LOW] [finding] — Source: [reviewer]

=== ADVERSARIAL CHALLENGES ===
[challenges, false positives, missed issues, systemic risks]

=== OVERALL VERDICT ===
Verdict: [APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES]
Confidence: [HIGH | MEDIUM | LOW]
```

---

## Notes

- **5 total agents:** 4 specialist reviewers run in parallel, then 1 adversarial validator runs sequentially after all 4 complete
- **Adversarial validator is key:** Catches cases where all 4 reviewers agree on something wrong or miss the same blind spot
- **Zero conversation context:** Each reviewer sees only the PRD content, not conversation history
- **Re-runnable:** If REVISION_REQUESTED, fix the plan and re-run. Each run is independent
- **Pairs with deepen-plan:** Run deepen first for research enrichment, then review for formal approval
- **Not a replacement for human review:** AI review supplements, doesn't replace
- **Verdict escalation:** A single CRITICAL finding from any source results in REVISION_REQUESTED

---

## Integration Points

- **Input**: PRD file from generate-prd or deepen-plan skills
- **Output**: Review verdict + findings
- **Agent definitions**: `agents/review/*.md`
- **Consumed by**: `/plan` workflow command
