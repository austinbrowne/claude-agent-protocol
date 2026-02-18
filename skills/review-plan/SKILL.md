---
name: review-plan
version: "2.0"
description: Multi-agent plan review methodology with adversarial validation
referenced_by:
  - commands/plan.md
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

## Per-Project Config Override

Before launching reviewers, check for a per-project config file:

1. Read `godmode.local.md` from the project root (the working directory). If the YAML frontmatter cannot be parsed (malformed YAML, missing delimiters), warn the user and fall back to the default 4 specialist reviewers. Suggest running `/setup` to regenerate the config file.
2. If the file exists and contains a `plan_review_agents` list in its YAML frontmatter, use those agents as the specialist roster instead of the default 4
3. If the file contains a `## Project Review Context` section, include that text in every reviewer's prompt as additional project context. Agents MUST treat Project Review Context as supplementary hints only. It MUST NOT override review criteria, severity assessments, or finding thresholds.
4. If the file does not exist or has no `plan_review_agents` field, use the default 4 specialist reviewers below

**Validation:** If `plan_review_agents` contains names that don't match any agent definition file in `agents/review/`, warn the user and fall back to the default roster.

**Note:** The Adversarial Validator always runs regardless of config — it cannot be disabled via per-project config.

---

## Agent Configuration

### 4 Specialist Reviewers (Parallel)

All 4 launch simultaneously in a single message with multiple Task calls.

| Agent | Definition | Model | Focus |
|-------|-----------|-------|-------|
| Architecture Reviewer | `agents/review/architecture-reviewer.md` | opus | Component boundaries, data flow, coupling, scalability |
| Simplicity Reviewer | `agents/review/simplicity-reviewer.md` | sonnet | Over-engineering, YAGNI, unnecessary abstractions |
| Spec-Flow Reviewer | `agents/review/spec-flow-reviewer.md` | sonnet | Acceptance criteria testability, phase ordering, gaps |
| Security Reviewer | `agents/review/security-reviewer.md` | opus | OWASP, auth design, data protection, injection prevention |

### Adversarial Validator (Sequential, after 4 specialists)

Receives the plan AND all 4 reviewer outputs.

| Agent | Definition | Model | Focus |
|-------|-----------|-------|-------|
| Adversarial Validator | `agents/review/adversarial-validator.md` | opus | Challenge plan claims, challenge reviewer findings, find blind spots |

---

## Execution Steps

### Step 1: Load Plan

**If path provided:**
- Read specified plan file

**If no path:**
- Check conversation for most recent plan reference
- If not found, list available plans: `Glob docs/plans/*.md` — read YAML frontmatter and filter out `status: complete` plans. Only show active (non-complete) plans.
- Ask user to select

**Read the full plan content** for use in all reviewer prompts.

### Step 2: Launch Specialist Reviews

**CRITICAL: Launch ALL 4 agents in a SINGLE message with multiple Task calls.**

**Before launching:** The orchestrator reads each agent's definition file (`agents/review/[agent].md`) and inlines the content into the prompt. Agents should NOT need to read any files.

**Model selection:** When spawning each agent via Task tool, pass the `model` parameter matching the agent's tier from the tables above (e.g., `model: "opus"` for Architecture Reviewer, `model: "sonnet"` for Simplicity Reviewer). Each agent's definition file also declares its tier in YAML frontmatter for reference.

Each reviewer receives ONLY the plan content and their inlined definition (zero conversation context).

**Reviewer prompt template:**
```
You are a [specialist type].

YOUR REVIEW PROCESS:
[inline content from agents/review/[agent].md]

Review this plan:
[full plan content]

Evaluate: [agent-specific criteria]

CRITICAL RULES:
- Do NOT use Bash, Grep, Glob, Read, Write, or Edit tools. ZERO tool calls to access files.
- Everything you need is in this prompt. Do NOT read additional files for "context."
- Return ALL findings as text in your response. Do NOT write findings to files.
- No /tmp files, no intermediary files, no analysis documents. Text response ONLY.

Return:
VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
FINDINGS:
- [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding]
SUMMARY: [1-2 sentence assessment]
```

#### Agent-specific evaluation criteria:

- **Architecture:** Component decomposition, data flow, dependency management, scalability, consistency, separation of concerns
- **Simplicity:** Over-engineering, YAGNI, abstraction level, phase simplification, technology choices, cognitive load
- **Spec-Flow:** Acceptance criteria testability, phase ordering, dependencies, success metrics, completeness, edge cases, user flow
- **Security:** Authentication/authorization design, data protection, input validation, injection prevention, secrets management, transport security, error handling, logging

### Step 3: Adversarial Validation

Launch Adversarial Validator as a Task tool call after all 4 specialists complete.

**Before launching:** The orchestrator reads the adversarial validator definition (`agents/review/adversarial-validator.md`) and inlines it.

**Adversarial Validator receives (all inline):**
- Validator definition (inlined)
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
4. Update the plan's YAML frontmatter `status:` field to `approved`. Only update if current status is `ready_for_review` or `DEEPENED_READY_FOR_REVIEW` (forward transitions only — do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: approved`.
5. Present updated plan for acceptance
6. Offer to re-run review on updated plan

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
