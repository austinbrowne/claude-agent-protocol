---
description: Multi-agent plan review before implementation
---

# /review-plan

**Description:** Multi-agent plan review before implementation

**When to use:**
- After generating a PRD (via `/generate-prd`) and optionally deepening it (via `/deepen-plan`)
- Before creating issues and starting implementation
- As a formal approval gate between planning and execution
- When you want independent reviewers to validate the plan

**Prerequisites:**
- PRD/plan file exists (from `/generate-prd` or `/deepen-plan`)
- Plan should be in `READY_FOR_REVIEW` or `DEEPENED_READY_FOR_REVIEW` status

---

## Invocation

**Interactive mode:**
User types `/review-plan` with no arguments. Claude locates the most recent PRD from conversation context or lists available PRDs.

**Direct mode:**
User types `/review-plan docs/prds/YYYY-MM-DD-feature-name.md` with explicit path.

---

## Arguments

- `[plan_path]` - Path to the PRD/plan file to review (e.g., `docs/prds/2026-01-15-oauth-auth.md`)
- If omitted, Claude uses the most recent PRD from conversation context or prompts the user

---

## Skills

**Load before execution:** Read and follow `skills/review-plan/SKILL.md` for the 5-agent review process (Architecture, Simplicity, Spec-Flow, Security + Adversarial Validator), parallel-then-sequential execution pattern, verdict consolidation, and revision workflow.

---

## Execution Steps

### Step 1: Load PRD/plan

**If direct mode (path provided):**
- Read specified PRD file
- Validate file exists

**If interactive mode (no path):**
- Check conversation for most recent PRD reference
- If not found, list available PRDs:
  ```bash
  ls docs/prds/*.md
  ```
- Ask user to select:
  ```
  Available PRDs:
  1. docs/prds/2026-01-15-oauth-auth.md
  2. docs/prds/2026-01-10-notification-system.md

  Which plan to review? _____
  ```

**Read the full PRD content** for use in all reviewer prompts.

### Step 2: Launch 4 review agents IN PARALLEL

> **Implementation Note:** Claude uses its internal Task tool to spawn all 4 review subagents simultaneously in a single message. Users do not need to do anything — just invoke `/review-plan` and Claude handles this automatically.

**CRITICAL: Launch ALL 4 agents in a SINGLE message with multiple Task calls. They run simultaneously.**

**Agent 1: Architecture Reviewer**
```
Task tool with:
- description: "Architecture review of plan"
- prompt: "You are an Architecture Reviewer. Reference agents/review/architecture-reviewer.md.

  Review this plan for architectural soundness:

  [full PRD content]

  Evaluate:
  1. Component decomposition — are boundaries clean and well-defined?
  2. Data flow — is it clear, efficient, and consistent?
  3. Dependency management — is coupling minimized?
  4. Scalability — does the design handle expected growth?
  5. Consistency — does this fit the existing architecture?
  6. Separation of concerns — are responsibilities properly divided?

  Return your response in this exact format:
  VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
  FINDINGS:
  - [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding description]
  SUMMARY: [1-2 sentence summary of your assessment]"
```

**Agent 2: Simplicity Reviewer**
```
Task tool with:
- description: "Simplicity review of plan"
- prompt: "You are a Simplicity Reviewer. Reference agents/review/simplicity-reviewer.md.

  Review this plan for unnecessary complexity:

  [full PRD content]

  Evaluate:
  1. Over-engineering — is any part more complex than needed?
  2. YAGNI — are features planned that are not needed yet?
  3. Abstraction level — are there unnecessary layers?
  4. Implementation phases — could they be simplified or merged?
  5. Technology choices — is there a simpler tool for the job?
  6. Cognitive load — can a new developer understand this easily?

  Return your response in this exact format:
  VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
  FINDINGS:
  - [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding description]
  SUMMARY: [1-2 sentence summary of your assessment]"
```

**Agent 3: Spec-Flow Reviewer**
```
Task tool with:
- description: "Spec-flow review of plan"
- prompt: "You are a Spec-Flow Reviewer. Reference agents/review/spec-flow-reviewer.md.

  Review this plan for specification completeness and logical flow:

  [full PRD content]

  Evaluate:
  1. Acceptance criteria — are they all testable and unambiguous?
  2. Phase ordering — do implementation phases flow logically?
  3. Dependencies — are inter-phase dependencies explicit?
  4. Success metrics — are they measurable and realistic?
  5. Completeness — are there gaps between problem and solution?
  6. Edge cases — does the spec address failure scenarios?
  7. User flow — is the end-to-end user experience coherent?

  Return your response in this exact format:
  VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
  FINDINGS:
  - [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding description]
  SUMMARY: [1-2 sentence summary of your assessment]"
```

**Agent 4: Security Reviewer**
```
Task tool with:
- description: "Security review of plan"
- prompt: "You are a Security Reviewer. Reference agents/review/security-reviewer.md.

  Review this plan for security concerns:

  [full PRD content]

  Evaluate against OWASP Top 10 and security best practices:
  1. Authentication/authorization design — is it sound?
  2. Data protection — is sensitive data handled correctly?
  3. Input validation — is all user input validated?
  4. Injection prevention — are parameterized queries planned?
  5. Secrets management — are API keys/tokens handled securely?
  6. Transport security — is data encrypted in transit?
  7. Error handling — do errors leak sensitive information?
  8. Logging — are security events audited?

  Return your response in this exact format:
  VERDICT: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES
  FINDINGS:
  - [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding description]
  SUMMARY: [1-2 sentence summary of your assessment]"
```

### Step 3: Wait for all 4 reviewers to complete

Collect all 4 verdicts and findings. Parse each agent's output into structured format:
- Verdict (APPROVED / REVISION_REQUESTED / APPROVED_WITH_NOTES)
- Findings list with severity ratings
- Summary

### Step 4: Launch Adversarial Validator

**AFTER all 4 reviewers complete**, launch the Adversarial Validator. This agent receives the plan AND all 4 reviewer outputs.

```
Task tool with:
- description: "Adversarial validation of plan and reviews"
- prompt: "You are an Adversarial Validator. Reference agents/review/adversarial-validator.md.

  Your job is to challenge both the plan AND the reviewers' findings.
  You are deliberately skeptical — your goal is to catch what everyone else missed.

  THE PLAN:
  [full PRD content]

  REVIEWER FINDINGS:

  Architecture Reviewer:
  [Agent 1 full output]

  Simplicity Reviewer:
  [Agent 2 full output]

  Spec-Flow Reviewer:
  [Agent 3 full output]

  Security Reviewer:
  [Agent 4 full output]

  YOUR TASK:
  1. Challenge the plan's claims:
     - Are assumptions validated or just stated?
     - Are effort estimates realistic?
     - Are there hidden dependencies not mentioned?
     - What could go wrong that nobody mentioned?

  2. Challenge the reviewers' findings:
     - Are there false positives (issues that are not actually issues)?
     - Are there false negatives (critical issues ALL reviewers missed)?
     - Did reviewers agree too easily on something questionable?
     - Did any reviewer contradict another without it being flagged?

  3. Identify systemic blind spots:
     - What category of risk is nobody thinking about?
     - Is there a single point of failure?
     - What happens if a key assumption turns out to be wrong?

  Return your response in this format:
  CHALLENGES TO PLAN:
  - [challenge description]

  CHALLENGES TO REVIEWERS:
  - [reviewer name]: [challenge to their finding]

  FALSE POSITIVES (reviewer issues that are NOT real):
  - [finding that should be dismissed and why]

  MISSED ISSUES (things nobody caught):
  - [severity: CRITICAL|HIGH|MEDIUM|LOW] [finding description]

  SYSTEMIC RISKS:
  - [risk description]

  OVERALL ASSESSMENT: [1-3 sentences]"
```

### Step 5: Consolidate into review report

**Merge all outputs into a structured report:**

```
=== PLAN REVIEW REPORT ===

Plan: [PRD filename]
Date: YYYY-MM-DD
Reviewers: Architecture, Simplicity, Spec-Flow, Security + Adversarial Validator

=== REVIEWER VERDICTS ===

| Reviewer       | Verdict              |
|----------------|----------------------|
| Architecture   | APPROVED_WITH_NOTES  |
| Simplicity     | REVISION_REQUESTED   |
| Spec-Flow      | APPROVED             |
| Security       | APPROVED_WITH_NOTES  |

=== PRIORITY FIXES (must address before implementation) ===

1. [CRITICAL/HIGH] [finding] — Source: [reviewer]
2. [HIGH] [finding] — Source: [reviewer]

=== NON-BLOCKING SUGGESTIONS ===

1. [MEDIUM] [finding] — Source: [reviewer]
2. [LOW] [finding] — Source: [reviewer]

=== ADVERSARIAL CHALLENGES ===

Challenges to plan:
- [challenge]

Challenges to reviewers:
- [challenge]

False positives identified:
- [finding that should be dismissed]

Missed issues:
- [finding nobody else caught]

Systemic risks:
- [risk]

=== OVERALL VERDICT ===

Verdict: APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES

Rationale: [Why this verdict was reached]

Confidence: HIGH_CONFIDENCE | MEDIUM_CONFIDENCE | LOW_CONFIDENCE
```

### Step 6: Determine overall verdict

**Verdict logic:**

| Condition | Overall Verdict |
|-----------|----------------|
| Any reviewer returns REVISION_REQUESTED with CRITICAL findings | REVISION_REQUESTED |
| Any adversarial MISSED ISSUE is CRITICAL | REVISION_REQUESTED |
| 2+ reviewers return REVISION_REQUESTED | REVISION_REQUESTED |
| 1 reviewer returns REVISION_REQUESTED (non-critical) | APPROVED_WITH_NOTES |
| All reviewers APPROVED, adversarial finds LOW/MEDIUM issues | APPROVED_WITH_NOTES |
| All reviewers APPROVED, no adversarial concerns | APPROVED |

### Step 7: Report findings and suggest next steps

**If REVISION_REQUESTED:**
```
Plan Review: REVISION_REQUESTED

N priority fixes must be addressed before implementation.

Priority fixes:
1. [fix]
2. [fix]

Next steps:
- Fix priority issues in PRD
- Re-run review: `/review-plan`
- Or discuss specific findings with team
```

**If APPROVED or APPROVED_WITH_NOTES:**
```
Plan Review: APPROVED_WITH_NOTES

Plan is sound. N non-blocking suggestions noted.

Next steps:
- Create issues from plan: `/create-issues`
- Address non-blocking suggestions during implementation
- Start work: `/start-issue`
```

**If user wants to fix and re-review:**
- User updates PRD
- Re-run: `/review-plan [same path]`
- All 4 reviewers + adversarial run again fresh

---

## Output

**Review report containing:**
- 4 reviewer verdicts with findings
- Adversarial validator challenges
- Priority fixes (blocking)
- Non-blocking suggestions
- Overall verdict

**Verdict:** APPROVED | REVISION_REQUESTED | APPROVED_WITH_NOTES

**Metadata:**
- Reviewers involved (4 + adversarial)
- Total findings count by severity
- Confidence level

**Suggested next steps:**
- If REVISION_REQUESTED: "Fix issues in PRD, re-run `/review-plan`"
- If APPROVED: "Create issues: `/create-issues`"

---

## References

- See: `agents/review/architecture-reviewer.md` for architecture review criteria
- See: `agents/review/simplicity-reviewer.md` for simplicity review criteria
- See: `agents/review/spec-flow-reviewer.md` for spec-flow review criteria
- See: `agents/review/security-reviewer.md` for security review criteria
- See: `agents/review/adversarial-validator.md` for adversarial validation process
- See: `AI_CODING_AGENT_GODMODE.md` Phase 0 for planning workflow

---

## Example Usage

**Example 1: Direct mode**
```
User: /review-plan docs/prds/2026-01-15-oauth-auth.md

Claude: Loading plan: docs/prds/2026-01-15-oauth-auth.md

Launching 4 review agents in parallel...
- Architecture Reviewer
- Simplicity Reviewer
- Spec-Flow Reviewer
- Security Reviewer

[All 4 complete]

Launching Adversarial Validator with plan + all findings...

[Adversarial Validator complete]

=== PLAN REVIEW REPORT ===

| Reviewer       | Verdict              |
|----------------|----------------------|
| Architecture   | APPROVED_WITH_NOTES  |
| Simplicity     | REVISION_REQUESTED   |
| Spec-Flow      | APPROVED             |
| Security       | APPROVED_WITH_NOTES  |

Priority fixes:
1. [HIGH] Phase 3 (admin dashboard) adds scope without justification
   — Simplicity: defer to v2
2. [MEDIUM] Missing rate limiting on OAuth callback endpoint
   — Security

Adversarial challenges:
- Effort estimate of 12 hours seems low given 3 OAuth providers
- Simplicity reviewer missed that Phase 2 token management is also deferrable

Overall Verdict: REVISION_REQUESTED

Next steps:
- Address Phase 3 deferral
- Add rate limiting to OAuth callback spec
- Re-run: `/review-plan`
```

**Example 2: Interactive mode with approval**
```
User: /review-plan

Claude: Available PRDs:
1. docs/prds/2026-01-15-oauth-auth.md

Which plan to review? 1

Claude: [Launches 4 reviewers + adversarial]

=== PLAN REVIEW REPORT ===

| Reviewer       | Verdict   |
|----------------|-----------|
| Architecture   | APPROVED  |
| Simplicity     | APPROVED  |
| Spec-Flow      | APPROVED  |
| Security       | APPROVED  |

Adversarial challenges:
- No critical concerns. Plan assumptions are well-supported.

Overall Verdict: APPROVED

Confidence: HIGH_CONFIDENCE

Next steps:
- Create issues: `/create-issues docs/prds/2026-01-15-oauth-auth.md`
- Start implementation: `/start-issue`
```

---

## Notes

- **5 total agents:** 4 specialist reviewers run in parallel, then 1 adversarial validator runs sequentially after all 4 complete (it needs their output).
- **Adversarial validator is key:** The 4 reviewers may agree on something wrong, or miss the same blind spot. The adversarial validator's job is to catch exactly these cases.
- **Zero conversation context:** Each reviewer sees only the PRD content, not conversation history. This ensures unbiased assessment.
- **Re-runnable:** If REVISION_REQUESTED, fix the plan and re-run. Each run is independent.
- **Pairs with /deepen-plan:** Run `/deepen-plan` first for research enrichment, then `/review-plan` for formal approval. They serve different purposes — deepening adds information, reviewing validates quality.
- **Not a replacement for human review:** This is AI review. Humans should still review the plan, especially for business logic and product decisions.
- **Token cost:** 5 subagents each processing the full PRD. Cost scales with PRD size. Lite PRDs are cheaper to review than Full PRDs.
- **Verdict escalation:** A single CRITICAL finding from any source (reviewer or adversarial) results in REVISION_REQUESTED. This is intentionally conservative.

---

## Post-Completion Flow

After completing the plan review, present next options using `AskUserQuestion`:

```
AskUserQuestion:
  question: "Plan review complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Run /create-issues"
      description: "Generate GitHub issues from the approved plan"
    - label: "Revise and re-review"
      description: "Fix priority findings in PRD, then re-run /review-plan"
    - label: "Done"
      description: "End workflow — review report available in conversation"
```

Based on user's selection, invoke the chosen command. If "Revise and re-review", guide user through fixing priority issues then re-run `/review-plan`.
