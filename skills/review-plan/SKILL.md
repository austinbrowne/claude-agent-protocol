---
name: review-plan
version: "2.0"
description: Multi-agent plan review methodology with adversarial validation and optional Agent Teams mode
referenced_by:
  - commands/plan.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Plan Review Skill

5-agent review process for validating plans before implementation.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has a mandatory AskUserQuestion gate. You MUST hit it. NEVER skip it. NEVER replace it with a plain text question.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Post-Review Actions** | After presenting review report | Accept findings / Research / Dismiss / Discuss | User loses control of next steps — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- After generating a plan (via generate-plan skill) and optionally deepening it
- Before creating issues and starting implementation
- As a formal approval gate between planning and execution

---

## Prerequisites

- Plan file exists
- Plan should be in `READY_FOR_REVIEW` or `DEEPENED_READY_FOR_REVIEW` status

---

## Step 0: Detect Execution Mode

**CRITICAL: Check your tool list RIGHT NOW.** Do NOT rely on what you did earlier in this conversation. Each skill invocation must re-evaluate independently — conversation history is not a valid signal for tool availability.

Check if the `TeamCreate` tool is available in your tool list.

- **Available** → follow `[TEAM MODE]` instructions throughout this skill
- **Not available** → follow `[SUBAGENT MODE]` instructions (existing Task tool behavior)

See `guides/AGENT_TEAMS_GUIDE.md` for full team formation patterns and best practices (Pattern A: Review Team).

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

### Step 1: Load Plan

**If path provided:**
- Read specified plan file

**If no path:**
- Check conversation for most recent plan reference
- If not found, list available plans: `ls docs/plans/*.md`
- Ask user to select

**Read the full plan content** for use in all reviewer prompts.

### Step 2: Launch Specialist Reviews

#### `[TEAM MODE]` — Agent Teams Execution

Form a Plan Review Team. You (the Lead) act as Coordinator and Adversarial Validator.

1. Spawn 4 specialist teammates — one per reviewer domain
2. Each teammate receives a spawn prompt containing:
   - Zero conversation context (only the plan content)
   - Their agent definition file reference
   - Agent-specific evaluation criteria
3. Create a shared task list with one review task per specialist
4. Teammates can message each other about trade-offs: "Architecture Reviewer, your scalability concern at Phase 3 conflicts with my simplicity finding — can we discuss?"
5. Teammates broadcast CRITICAL findings immediately

**Teammate spawn prompt template:**
```
You are a [specialist type]. Read your review process from [agent definition file].

Review this plan:
[full plan content]

Evaluate: [agent-specific criteria]

Instructions:
- Post findings to the task list with severity (CRITICAL/HIGH/MEDIUM/LOW)
- If you find a CRITICAL issue, broadcast it to the team immediately
- If your finding relates to another reviewer's domain, message them
- When the Lead asks a question, respond with specific reasoning
- Format findings as: VERDICT, FINDINGS list, SUMMARY

Mark your task as done when complete.
```

#### `[SUBAGENT MODE]` — Task Tool Execution (Fallback)

**CRITICAL: Launch ALL 4 agents in a SINGLE message with multiple Task calls.**

Each reviewer receives ONLY the plan content (zero conversation context).

**Reviewer prompt template:**
```
You are a [specialist type]. Reference [agent definition file].

Review this plan:
[full plan content]

Evaluate: [agent-specific criteria]

Return:
VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
FINDINGS:
- [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding]
SUMMARY: [1-2 sentence assessment]
```

#### Agent-specific evaluation criteria (both modes):

- **Architecture:** Component decomposition, data flow, dependency management, scalability, consistency, separation of concerns
- **Simplicity:** Over-engineering, YAGNI, abstraction level, phase simplification, technology choices, cognitive load
- **Spec-Flow:** Acceptance criteria testability, phase ordering, dependencies, success metrics, completeness, edge cases, user flow
- **Security:** Authentication/authorization design, data protection, input validation, injection prevention, secrets management, transport security, error handling, logging

### Step 3: Adversarial Validation

#### `[TEAM MODE]`

After all 4 specialist teammates complete, the Lead performs adversarial validation directly:

1. Read all specialist findings from the task list and messages
2. For ambiguous findings, message the specialist: "What evidence supports [finding]?"
3. Specialists respond with reasoning or concede the finding
4. Challenge plan claims — assumptions validated? Estimates realistic? Hidden dependencies?
5. Challenge reviewer findings — false positives? False negatives? Contradictions between reviewers?
6. Identify systemic blind spots — what is nobody thinking about?
7. Shut down specialist teammates and clean up the team

#### `[SUBAGENT MODE]`

Launch Adversarial Validator as a Task tool call after all 4 specialists complete.

**Adversarial Validator receives:**
- Full plan content
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

## Post-Review Actions — MANDATORY GATE

**STOP. You MUST use AskUserQuestion here. Do NOT ask in plain text. Do NOT skip this step.**

After presenting the review report, ask the user how to proceed:

```
AskUserQuestion:
  question: "How would you like to address the review findings?"
  header: "Next action"
  options:
    - label: "Accept findings and update plan"
      description: "I'll make the suggested changes myself"
    - label: "Run additional research first"
      description: "Research the flagged areas before updating"
    - label: "Dismiss findings and proceed"
      description: "I disagree with the findings — continue anyway"
    - label: "Discuss findings"
      description: "I have questions about specific findings"
```

**If "Accept findings and update plan":**
1. Ask: "Which findings would you like me to address? (list numbers, or 'all')"
2. Wait for user response
3. Update the plan with ONLY the specified changes
4. Present updated plan for acceptance
5. Offer to re-run review on updated plan

**If "Run additional research first":**
1. Ask: "What specific areas need more research?" (pre-populate with reviewer suggestions if any)
2. Wait for user response
3. **ACTUALLY RUN THE RESEARCH** — launch appropriate research agents:
   - Codebase research: `subagent_type: "Explore"`
   - Best practices: `subagent_type: "general-purpose"` with web search
   - Framework docs: `subagent_type: "general-purpose"` with Context7 MCP
4. Present research findings to user
5. Ask: "Based on this research, what changes should I make to the plan?"
6. Wait for user response
7. Update the plan with research-informed changes
8. Offer to re-run review

**If "Dismiss findings and proceed":**
1. Confirm: "Are you sure? The following CRITICAL/HIGH findings will be unaddressed: [list]"
2. If confirmed, mark plan as `APPROVED_WITH_EXCEPTIONS` and note dismissed findings
3. Proceed to next workflow step

**If "Discuss findings":**
1. Ask which findings they want to discuss
2. Provide clarification
3. Return to post-review action selection

---

## Revision Workflow

If user chooses to revise after review:
1. Make ONLY the changes explicitly requested by user
2. Re-run plan review (all 5 agents run fresh)
3. Each run is independent — no memory of previous reviews

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
- **Zero conversation context:** Each reviewer sees only the plan content, not conversation history
- **Re-runnable:** If REVISION_REQUESTED, fix the plan and re-run. Each run is independent
- **Pairs with deepen-plan:** Run deepen first for research enrichment, then review for formal approval
- **Not a replacement for human review:** AI review supplements, doesn't replace
- **Verdict escalation:** A single CRITICAL finding from any source results in REVISION_REQUESTED

---

## Integration Points

- **Input**: Plan file from generate-plan or deepen-plan skills
- **Output**: Review verdict + findings
- **Agent definitions**: `agents/review/*.md`
- **Consumed by**: `/plan` workflow command
