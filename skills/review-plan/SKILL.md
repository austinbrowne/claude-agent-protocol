---
name: review-plan
version: "1.0"
description: Multi-agent plan review methodology with adversarial validation
referenced_by:
  - commands/review-plan.md
  - commands/workflows/godmode.md
---

# Plan Review Skill

5-agent review process for validating plans before implementation.

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

## Execution Pattern

### Phase 1: Parallel Review

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

### Phase 2: Adversarial Validation

After all 4 reviewers complete:

```
You are an Adversarial Validator. Reference agents/review/adversarial-validator.md.

Challenge both the plan AND the reviewers:

1. Plan claims — assumptions validated? Estimates realistic? Hidden dependencies?
2. Reviewer findings — false positives? False negatives? Contradictions?
3. Systemic blind spots — what is nobody thinking about?

Return:
CHALLENGES TO PLAN: [...]
CHALLENGES TO REVIEWERS: [...]
FALSE POSITIVES: [findings that should be dismissed]
MISSED ISSUES: [things nobody caught]
SYSTEMIC RISKS: [category-level concerns]
```

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
2. Re-run `/review-plan` (all 5 agents run fresh)
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

## Integration Points

- **Input**: PRD file from `/generate-prd` or `/deepen-plan`
- **Output**: Review verdict + findings
- **Agent definitions**: `agents/review/*.md`
- **Consumed by**: `/review-plan` command, `/godmode` workflow
