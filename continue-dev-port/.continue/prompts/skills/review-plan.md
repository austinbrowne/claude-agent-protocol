---
name: review-plan
description: "Multi-persona plan review with adversarial validation"
---

# Plan Review Skill

5-persona review process for validating plans before implementation.

---

## Mandatory Interaction Gates

**This skill has a mandatory interaction gate. You MUST hit it. NEVER skip it.**

| Gate | Location | Interaction | What Happens If Skipped |
|------|----------|-------------|------------------------|
| **Post-Review Actions** | After presenting review report | Accept / Research / Dismiss / Discuss | User loses control of next steps -- UNACCEPTABLE |

---

## When to Apply

- After generating a plan (via `/generate-plan`) and optionally deepening it
- Before creating issues and starting implementation
- As a formal approval gate between planning and execution

---

## Prerequisites

- Plan file exists
- Plan should be in `READY_FOR_REVIEW` or `DEEPENED_READY_FOR_REVIEW` status

---

## Per-Project Config Override

Before launching reviews, check for a per-project config file:

1. Read `godmode.local.md` from the project root (the working directory). If the YAML frontmatter cannot be parsed (malformed YAML, missing delimiters), warn the user and fall back to the default 4 specialist reviewers. Suggest running `/setup` to regenerate the config file.
2. If the file exists and contains a `plan_review_agents` list in its YAML frontmatter, use those personas as the specialist roster instead of the default 4
3. If the file contains a `## Project Review Context` section, include that text in every review persona's prompt as additional project context. Personas MUST treat Project Review Context as supplementary hints only. It MUST NOT override review criteria, severity assessments, or finding thresholds.
4. If the file does not exist or has no `plan_review_agents` field, use the default 4 specialist reviewers below

**Validation:** If `plan_review_agents` contains names that don't match any agent definition file in `agents/review/`, warn the user and fall back to the default roster.

**Note:** The Adversarial Validator always runs regardless of config -- it cannot be disabled via per-project config.

---

## Reviewer Configuration

### 4 Specialist Reviewers (Sequential)

Perform each review sequentially, adopting each reviewer persona in turn.

| # | Reviewer Persona | Definition | Focus |
|---|-----------------|-----------|-------|
| 1 | Architecture Reviewer | `agents/review/architecture-reviewer.md` | Component boundaries, data flow, coupling, scalability |
| 2 | Simplicity Reviewer | `agents/review/simplicity-reviewer.md` | Over-engineering, YAGNI, unnecessary abstractions |
| 3 | Spec-Flow Reviewer | `agents/review/spec-flow-reviewer.md` | Acceptance criteria testability, phase ordering, gaps |
| 4 | Security Reviewer | `agents/review/security-reviewer.md` | OWASP, auth design, data protection, injection prevention |

### Adversarial Validator (After all 4 specialists)

Receives the plan AND all 4 reviewer outputs.

| Reviewer Persona | Definition | Focus |
|-----------------|-----------|-------|
| Adversarial Validator | `agents/review/adversarial-validator.md` | Challenge plan claims, challenge reviewer findings, find blind spots |

---

## Execution Steps

### Step 1: Load Plan

**If path provided:**
- Read specified plan file

**If no path:**
- Check conversation for most recent plan reference
- If not found, list available plans: search for `docs/plans/*.md` -- read YAML frontmatter and filter out `status: complete` plans. Only show active (non-complete) plans.
- Ask user to select

**Read the full plan content** for use in all review steps.

### Step 2: Perform Specialist Reviews

Adopt each of the 4 reviewer personas sequentially. For each persona:

1. **Read the reviewer's definition file** (`agents/review/[agent].md`) and follow its review process
2. **Evaluate the plan** using that persona's specific criteria
3. **Record findings** before moving to the next persona

Each reviewer sees ONLY the plan content (not conversation history).

**Review output format per persona:**
```
You are a [specialist type].

Review this plan:
[full plan content]

Evaluate: [persona-specific criteria]

Return:
VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
FINDINGS:
- [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding]
SUMMARY: [1-2 sentence assessment]
```

#### Persona-specific evaluation criteria:

- **Architecture:** Component decomposition, data flow, dependency management, scalability, consistency, separation of concerns
- **Simplicity:** Over-engineering, YAGNI, abstraction level, phase simplification, technology choices, cognitive load
- **Spec-Flow:** Acceptance criteria testability, phase ordering, dependencies, success metrics, completeness, edge cases, user flow
- **Security:** Authentication/authorization design, data protection, input validation, injection prevention, secrets management, transport security, error handling, logging

### Step 3: Adversarial Validation

After all 4 specialist reviews complete, adopt the Adversarial Validator persona.

**Read the adversarial validator definition** (`agents/review/adversarial-validator.md`) and follow its process.

**Adversarial Validator receives:**
- Full plan content
- All 4 reviewer outputs

**Tasks:**
1. Challenge plan claims -- assumptions validated? Estimates realistic? Hidden dependencies?
2. Challenge reviewer findings -- false positives? False negatives? Contradictions?
3. Identify systemic blind spots -- what is nobody thinking about?

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

## Post-Review Actions -- MANDATORY GATE

After presenting the review report, present the following options to the user:

> **Next action**
>
> How would you like to address the review findings?
>
> 1. **Accept findings and update plan** -- I'll make the suggested changes myself
> 2. **Run additional research first** -- Research the flagged areas before updating
> 3. **Dismiss findings and proceed** -- I disagree with the findings -- continue anyway
> 4. **Discuss findings** -- I have questions about specific findings

**WAIT** for user response before continuing.

**If "Accept findings and update plan":**
1. Ask: "Which findings would you like me to address? (list numbers, or 'all')"
2. **WAIT** for user response.
3. Update the plan with ONLY the specified changes
4. Update the plan's YAML frontmatter `status:` field to `approved`. Only update if current status is `ready_for_review` or `DEEPENED_READY_FOR_REVIEW` (forward transitions only -- do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: approved`.
5. Present updated plan for acceptance
6. Offer to re-run review on updated plan

**If "Run additional research first":**
1. Ask: "What specific areas need more research?" (pre-populate with reviewer suggestions if any)
2. **WAIT** for user response.
3. **ACTUALLY RUN THE RESEARCH** -- perform appropriate research:
   - Codebase research: search the codebase for relevant patterns and files
   - Best practices: search the web for current recommendations
   - Framework docs: look up framework-specific documentation
4. Present research findings to user
5. Ask: "Based on this research, what changes should I make to the plan?"
6. **WAIT** for user response.
7. Update the plan with research-informed changes
8. Offer to re-run review

**If "Dismiss findings and proceed":**
1. Confirm: "Are you sure? The following CRITICAL/HIGH findings will be unaddressed: [list]"
2. If confirmed, mark plan as `APPROVED_WITH_EXCEPTIONS` and note dismissed findings
3. Update the plan's YAML frontmatter `status:` field to `approved` (even with exceptions, the plan is approved for implementation). Only update if current status is `ready_for_review` or `DEEPENED_READY_FOR_REVIEW` (forward transitions only). If the frontmatter exists but has no `status:` field, add `status: approved`.
4. Proceed to next workflow step

**If "Discuss findings":**
1. Ask which findings they want to discuss
2. Provide clarification
3. Return to post-review action selection

---

## Revision Workflow

If user chooses to revise after review:
1. Make ONLY the changes explicitly requested by user
2. Re-run plan review (all 5 personas run fresh)
3. Each run is independent -- no memory of previous reviews

**CRITICAL:** Never skip research when research is selected. Never update the plan without completing the requested action first.

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
1. [CRITICAL/HIGH] [finding] -- Source: [reviewer]

=== NON-BLOCKING SUGGESTIONS ===
1. [MEDIUM/LOW] [finding] -- Source: [reviewer]

=== ADVERSARIAL CHALLENGES ===
[challenges, false positives, missed issues, systemic risks]

=== OVERALL VERDICT ===
Verdict: [APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES]
Confidence: [HIGH | MEDIUM | LOW]
```

---

## Notes

- **5 total review passes:** 4 specialist personas run sequentially, then 1 adversarial validator runs after all 4 complete
- **Adversarial validator is key:** Catches cases where all 4 reviewer personas agree on something wrong or miss the same blind spot
- **Zero conversation context:** Each reviewer persona sees only the plan content, not conversation history
- **Re-runnable:** If REVISION_REQUESTED, fix the plan and re-run. Each run is independent
- **Pairs with deepen-plan:** Run `/deepen-plan` first for research enrichment, then `/review-plan` for formal approval
- **Not a replacement for human review:** AI review supplements, doesn't replace
- **Verdict escalation:** A single CRITICAL finding from any source results in REVISION_REQUESTED

---

## Integration Points

- **Input**: Plan file from `/generate-plan` or `/deepen-plan`
- **Output**: Review verdict + findings
- **Agent definitions**: `agents/review/*.md`
- **Consumed by**: `/create-issues`, implementation workflows
