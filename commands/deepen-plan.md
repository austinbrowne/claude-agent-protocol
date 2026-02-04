---
description: Enrich a PRD/plan with parallel research, review agents, and past learnings
---

# /deepen-plan

**Description:** Enrich a PRD/plan with parallel research, review agents, and past learnings

**When to use:**
- After generating a PRD (via `/generate-prd`) and before implementation
- When the plan needs more detail, research, or validation
- Complex features where shallow planning leads to rework
- High-risk features (security, performance, breaking changes) that benefit from multi-agent scrutiny

**Prerequisites:**
- PRD file exists (from `/generate-prd`)
- PRD has been reviewed and is at `READY_FOR_REVIEW` or `APPROVED` status

---

## Invocation

**Interactive mode:**
User types `/deepen-plan` with no arguments. Claude locates the most recent PRD from conversation context or lists available PRDs.

**Direct mode:**
User types `/deepen-plan docs/prds/YYYY-MM-DD-feature-name.md` with explicit path.

---

## Arguments

- `[prd_path]` - Path to the PRD file to deepen (e.g., `docs/prds/2026-01-15-oauth-auth.md`)
- If omitted, Claude uses the most recent PRD from conversation context or prompts the user

---

## Execution Steps

### Phase 1: Parse and Analyze Plan

**Step 1.1: Load PRD file**

**If direct mode (path provided):**
- Read specified PRD file
- Validate file exists and is a valid PRD

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

  Which PRD to deepen? _____
  ```

**Step 1.2: Parse PRD into sections**

Extract and create a section manifest:
- Problem statement
- Goals and non-goals
- Solution overview
- Technical approach / architecture
- Implementation phases
- Test strategy
- Security considerations
- Risks
- Open questions

**Step 1.3: Classify each section by research needs**

For each section, determine:
- **Needs codebase research?** (existing patterns, dependencies, integration points)
- **Needs framework/library docs?** (API references, best practices, version-specific behavior)
- **Needs security deep-dive?** (auth, data handling, external APIs)
- **Needs performance analysis?** (scalability, bottlenecks, caching)
- **Has open questions?** (unknowns that need investigation)

---

### Phase 2: Parallel Research Layer

> **Implementation Note:** Claude uses its internal Task tool to launch multiple research subagents in parallel. Users do not need to do anything — just invoke `/deepen-plan` and Claude handles all orchestration automatically.

**CRITICAL: Launch ALL research subagents IN PARALLEL (single message with multiple Task calls).**

**Agent 2.1: Codebase Research Agents (1 per section that needs it)**

For each section flagged as needing codebase research, launch a subagent:
```
Task tool with:
- description: "Codebase research for [section name]"
- prompt: "You are a Codebase Research Agent. Follow agents/research/codebase-researcher.md.

  Research the codebase for information relevant to this PRD section:
  [section content]

  Specifically find:
  1. Existing patterns that apply
  2. Files that will be modified or affected
  3. Integration points with existing code
  4. Potential conflicts or constraints

  Return structured findings."
```

**Agent 2.2: Learnings Research Agent**

Launch one learnings researcher for the entire plan:
```
Task tool with:
- description: "Past learnings research for [PRD title]"
- prompt: "You are a Learnings Research Agent. Follow agents/research/learnings-researcher.md.

  Search docs/solutions/ for past solutions relevant to this plan:
  [PRD summary — problem, solution, technical approach]

  Run all 4 Grep passes. Return findings with relevance scores."
```

**Agent 2.3: Framework/Library Docs Researcher (if framework detected)**

If the PRD references a specific framework or library:
```
Task tool with:
- description: "Framework docs research for [framework name]"
- prompt: "You are a Framework Docs Research Agent. Follow agents/research/framework-docs-researcher.md.

  Research [framework] documentation relevant to:
  [technical approach section]

  Use Context7 MCP (mcp__plugin_compound-engineering_context7__resolve-library-id
  then mcp__plugin_compound-engineering_context7__query-docs) to query official docs.

  Return: relevant API references, best practices, version-specific gotchas."
```

**Agent 2.4: Web Research Agent (for high-risk or novel sections)**

For sections flagged as high-risk, novel, or with open questions:
```
Task tool with:
- description: "Web research for [topic]"
- prompt: "Research current best practices and known pitfalls for:
  [high-risk section or open question]

  Use WebSearch to find relevant information.
  Return: findings, recommendations, links to sources."
```

**Total agents in Phase 2:** 3-8+ depending on plan size and complexity.

---

### Phase 3: Parallel Review Layer

**CRITICAL: Launch ALL 6 review agents IN PARALLEL (single message with multiple Task calls).**

Each agent receives the FULL PRD content and returns structured findings.

**Agent 3.1: Architecture Reviewer**
```
Task tool with:
- description: "Architecture review of PRD"
- prompt: "You are an Architecture Reviewer. Reference agents/review/architecture-reviewer.md.

  Review this PRD for architectural soundness:
  [full PRD content]

  Evaluate:
  1. Component decomposition — clean boundaries?
  2. Data flow — clear and efficient?
  3. Dependency management — minimal coupling?
  4. Scalability — handles growth?
  5. Consistency with existing architecture

  Return: verdict (APPROVED / REVISION_REQUESTED / APPROVED_WITH_NOTES) + findings."
```

**Agent 3.2: Simplicity Reviewer**
```
Task tool with:
- description: "Simplicity review of PRD"
- prompt: "You are a Simplicity Reviewer. Reference agents/review/simplicity-reviewer.md.

  Review this PRD for unnecessary complexity:
  [full PRD content]

  Evaluate:
  1. Is any part over-engineered for current needs?
  2. Could a simpler solution achieve the same goals?
  3. Are there unnecessary abstractions?
  4. YAGNI violations — features planned that aren't needed yet?
  5. Could implementation phases be simplified?

  Return: verdict + findings."
```

**Agent 3.3: Security Reviewer**
```
Task tool with:
- description: "Security review of PRD"
- prompt: "You are a Security Reviewer. Reference agents/review/security-reviewer.md.

  Review this PRD for security concerns:
  [full PRD content]

  Evaluate against OWASP Top 10:
  1. Authentication/authorization design
  2. Data protection approach
  3. Input validation strategy
  4. Injection prevention
  5. Secrets management

  Return: verdict + findings with severity ratings."
```

**Agent 3.4: Performance Reviewer**
```
Task tool with:
- description: "Performance review of PRD"
- prompt: "You are a Performance Reviewer. Reference agents/review/performance-reviewer.md.

  Review this PRD for performance concerns:
  [full PRD content]

  Evaluate:
  1. N+1 query risks
  2. Missing pagination or batching
  3. Memory-intensive operations
  4. Missing caching opportunities
  5. Scalability bottlenecks

  Return: verdict + findings."
```

**Agent 3.5: Edge Case Reviewer**
```
Task tool with:
- description: "Edge case review of PRD"
- prompt: "You are an Edge Case Reviewer. Reference agents/review/edge-case-reviewer.md.

  Review this PRD for missing edge cases:
  [full PRD content]

  Check for:
  1. Null/undefined/empty inputs
  2. Boundary values (0, -1, MAX_INT)
  3. Concurrent access / race conditions
  4. Network failures / timeouts
  5. Partial failures / rollback scenarios
  6. Unicode, special characters, long strings

  Return: verdict + list of missing edge cases."
```

**Agent 3.6: Spec-Flow Reviewer**
```
Task tool with:
- description: "Spec-flow review of PRD"
- prompt: "You are a Spec-Flow Reviewer. Reference agents/review/spec-flow-reviewer.md.

  Review this PRD for specification completeness and logical flow:
  [full PRD content]

  Evaluate:
  1. Are all acceptance criteria testable?
  2. Do implementation phases flow logically?
  3. Are dependencies between phases clear?
  4. Are success metrics measurable?
  5. Are there gaps between problem statement and solution?

  Return: verdict + findings."
```

**Total agents in Phase 3:** 6 agents, all launched in a single parallel batch.

---

### Phase 4: Parallel Learnings Layer

**After Phase 2 Learnings Research Agent returns findings:**

For each HIGH RELEVANCE solution found, launch a subagent to extract detailed applicability:

```
Task tool with (one per relevant solution):
- description: "Analyze applicability of [solution filename]"
- prompt: "Read docs/solutions/[filename] in full.

  Compare against this plan:
  [PRD summary]

  Determine:
  1. Which specific parts of the plan does this learning apply to?
  2. What gotchas should we watch for?
  3. Does this learning change our recommended approach?
  4. Confidence that this applies: HIGH / MEDIUM / LOW

  Return: applicability assessment with specific recommendations."
```

**Total agents in Phase 4:** 1-5 depending on how many relevant solutions were found.

---

### Phase 5: Consolidate and Enhance

**Step 5.1: Merge all outputs**

Collect findings from:
- Phase 2: Research findings (codebase, learnings, framework docs, web)
- Phase 3: Review verdicts and findings (6 reviewers)
- Phase 4: Learnings applicability assessments

**Step 5.2: Deduplicate findings**

- Multiple agents may flag the same concern — consolidate into single finding
- If 3+ agents flag the same issue, mark it as HIGH PRIORITY
- Preserve unique perspectives even if they overlap

**Step 5.3: Update PRD in-place with `[DEEPENED]` annotations**

For each section of the PRD, add research findings inline:

```markdown
## Technical Approach

[Original content unchanged]

### [DEEPENED] Research Findings
- Existing pattern found: src/services/BaseService.ts uses repository pattern
- Framework docs confirm: Express 5.x requires async error middleware
- Past learning: auth-jwt-refresh-token-race-condition.md — implement token rotation

### [DEEPENED] Review Findings
- Architecture: APPROVED_WITH_NOTES — consider separating read/write services
- Simplicity: REVISION_REQUESTED — Phase 3 can be deferred to v2
- Security: APPROVED — token handling approach is sound
- Performance: APPROVED_WITH_NOTES — add index on user_id column
- Edge Cases: Missing null check on OAuth callback state parameter
- Spec-Flow: Acceptance criteria #3 is not testable as written
```

**Step 5.4: Add Enhancement Summary at end of PRD**

```markdown
---

## [DEEPENED] Enhancement Summary

**Deepened on:** YYYY-MM-DD
**Research agents launched:** N
**Review agents launched:** 6
**Past learnings referenced:** N

### Priority Fixes (from reviewers)
1. [CRITICAL] [finding]
2. [HIGH] [finding]

### Non-Blocking Suggestions
1. [finding]
2. [finding]

### Learnings Applied
1. [solution filename] — [how it was applied]

### Open Questions Resolved
1. [question] — [answer from research]

### Remaining Open Questions
1. [question still unresolved]

**Overall Confidence:** HIGH_CONFIDENCE | MEDIUM_CONFIDENCE | LOW_CONFIDENCE
**Status:** DEEPENED_READY_FOR_REVIEW
```

**Step 5.5: Save updated PRD**

Write the updated content back to the same PRD file.

### Step 6: Report results

```
Plan deepened successfully!

File: docs/prds/YYYY-MM-DD-feature-name.md
Status: DEEPENED_READY_FOR_REVIEW
Agents launched: N total (N research + 6 review + N learnings)
Sections enriched: N of M

Priority fixes: N items
Suggestions: N items
Learnings applied: N

Next steps:
- Review deepened plan (look for [DEEPENED] annotations)
- Run plan review for formal approval: `/review-plan`
- Create issues from plan: `/create-issues`
```

---

## Output

**PRD file updated in-place:**
- Location: same PRD file path
- Sections annotated with `[DEEPENED]` markers
- Enhancement summary appended
- Status: `DEEPENED_READY_FOR_REVIEW`

**Metadata:**
- Total agents launched
- Research findings count
- Review verdicts summary
- Learnings applied count

**Suggested next steps:**
- "Review the deepened plan, then run `/review-plan` for formal approval"
- Or: "Create issues directly: `/create-issues`"

---

## References

- See: `agents/research/codebase-researcher.md` for codebase research process
- See: `agents/research/learnings-researcher.md` for past learnings research
- See: `agents/research/framework-docs-researcher.md` for framework docs research
- See: `agents/research/best-practices-researcher.md` for best practices research
- See: `agents/review/architecture-reviewer.md` for architecture review criteria
- See: `agents/review/simplicity-reviewer.md` for simplicity review criteria
- See: `agents/review/security-reviewer.md` for security review criteria
- See: `agents/review/performance-reviewer.md` for performance review criteria
- See: `agents/review/edge-case-reviewer.md` for edge case review criteria
- See: `agents/review/spec-flow-reviewer.md` for spec-flow review criteria
- See: `AI_CODING_AGENT_GODMODE.md` Phase 0 for planning workflow

---

## Example Usage

**Example 1: Direct mode**
```
User: /deepen-plan docs/prds/2026-01-15-oauth-auth.md

Claude: Loading PRD: docs/prds/2026-01-15-oauth-auth.md

Parsing sections... 8 sections found.
Classifying research needs...

Launching parallel research agents:
- Codebase research (3 sections)
- Learnings research (full plan)
- Framework docs research (Passport.js)
- Web research (OAuth security best practices)

Launching parallel review agents:
- Architecture Reviewer
- Simplicity Reviewer
- Security Reviewer
- Performance Reviewer
- Edge Case Reviewer
- Spec-Flow Reviewer

Total agents: 12

[All agents complete]

Analyzing 2 relevant past learnings...

Consolidating findings...

Plan deepened successfully!

File: docs/prds/2026-01-15-oauth-auth.md
Status: DEEPENED_READY_FOR_REVIEW
Agents launched: 14 total
Sections enriched: 6 of 8

Priority fixes: 2 items
- [HIGH] Missing CSRF protection on OAuth callback
- [HIGH] Token storage should use httpOnly cookies, not localStorage

Suggestions: 5 items
Learnings applied: 2

Next steps:
- Review deepened plan
- Run formal review: `/review-plan`
```

**Example 2: Interactive mode**
```
User: /deepen-plan

Claude: Available PRDs:
1. docs/prds/2026-01-15-oauth-auth.md
2. docs/prds/2026-01-10-notification-system.md

Which PRD to deepen? 1

Claude: [Same flow as Example 1]
```

---

## Notes

- **Token cost:** This command launches 10-20+ subagents. Each agent consumes tokens for its research and analysis. Use on complex plans where the investment pays off — not on simple bug-fix PRDs.
- **In-place updates:** The PRD file is modified in-place. `[DEEPENED]` annotations make it easy to identify what was added by this command vs. the original content.
- **Idempotent (mostly):** Running `/deepen-plan` twice on the same PRD will add a second round of annotations. This is acceptable for iterating but may get noisy — consider cleaning up annotations between rounds.
- **Review agents have no conversation context:** Each reviewer sees only the PRD content, giving unbiased assessment.
- **Phase 2 and Phase 3 run in parallel:** Research and review agents launch at the same time for maximum throughput. Phase 4 (learnings deep-dive) depends on Phase 2 learnings results.
- **Framework detection:** If the PRD mentions a specific framework (Express, Next.js, Django, etc.), the framework docs researcher activates automatically.
- **Pairs with /review-plan:** After deepening, run `/review-plan` for a formal approval gate before creating issues.

---

## Post-Completion Flow

After deepening the plan, present next options using `AskUserQuestion`:

```
AskUserQuestion:
  question: "Plan deepened. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Run /review-plan"
      description: "Run multi-agent plan review for formal approval"
    - label: "Run /create-issues"
      description: "Generate GitHub issues from the deepened plan"
    - label: "Done"
      description: "End workflow — review the [DEEPENED] annotations manually"
```

Based on user's selection, invoke the chosen command with the PRD file path.
