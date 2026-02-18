---
name: GODMODE Protocol Reference
description: Comprehensive AI coding agent protocol -- phase-by-phase workflow for safe, effective AI-assisted development. Load when working through full implementation lifecycle, picking up issues, or needing detailed phase guidance.
alwaysApply: false
---

# AI Coding Agent Standard Operating Protocol (SOP)

**Version:** 1.0.0 (continue.dev port)
**Purpose:** Safe, effective AI-assisted software development

**Current:** 6 workflow commands (/explore, /plan, /implement, /review, /learn, /ship), invocable skill prompts, and natural workflow chaining via numbered option menus.

---

## Document Role

This is the **comprehensive reference document** for the GODMODE protocol.

**For guided workflows, use the 6 workflow commands:**
- /explore -- Reconnaissance & ideation: codebase exploration + brainstorming
- /plan -- Planning & requirements: plan generation, deepen, review, issues, ADR
- /implement -- Implementation: start issue, tests, validation, security, recovery
- /review -- Code review: fresh eyes (full/lite), protocol compliance
- /learn -- Knowledge capture: save solved problems as reusable docs
- /ship -- Ship: commit/PR, finalize, refactor

**Use this document when:**
- Learning the full protocol for the first time
- Need detailed phase-by-phase guidance
- Want comprehensive entry point documentation
- Reference for architectural decisions

---

# CRITICAL SAFETY RULES - READ FIRST

## Core Principles (You MUST Follow)

| Rule | What It Means |
|------|---------------|
| **EXPLORE FIRST** | NEVER guess. Search file contents to find patterns. Read relevant files BEFORE proposing solutions. |
| **HUMAN IN LOOP** | NEVER merge, deploy, or finalize without explicit human approval. ALWAYS pause for feedback. |
| **SECURITY FIRST** | 45% of AI code has vulnerabilities. ALWAYS run security checklist for auth/data/APIs. |
| **TEST EVERYTHING** | Every function MUST have tests. ALWAYS test: happy path + null + boundaries + errors. |
| **EDGE CASES MATTER** | AI forgets null, empty, boundaries. ALWAYS check these explicitly. |
| **SIMPLE > CLEVER** | Prefer clear, maintainable code. Avoid over-engineering. |
| **FLAG UNCERTAINTY** | If unsure, ask. Don't hallucinate APIs or make assumptions. |

---

## AI Blind Spots (You SYSTEMATICALLY Miss These)

### Edge Cases You ALWAYS Forget:
- **Null/undefined/None** - Check EVERY function parameter
- **Empty collections** - [], {}, ""
- **Boundary values** - 0, -1, MAX_INT, empty string
- **Special characters** - Unicode, emoji, quotes in strings
- **Timezones/DST** - Date handling across timezones

### Security Vulnerabilities (45% of AI Code):
- **SQL injection** - NEVER concatenate strings in SQL (use parameterized queries)
- **XSS** - ALWAYS encode output in HTML context
- **Missing auth** - Check user can access THIS resource
- **Hardcoded secrets** - NEVER put API keys in code (use env vars)
- **No input validation** - Validate ALL user input (allowlist > blocklist)

### Error Handling You Skip:
- Try/catch around ALL external calls (API, DB, file I/O)
- Handle network failures, timeouts, permission errors
- Error messages MUST NOT leak sensitive data

### Performance Mistakes:
- N+1 query problems (use joins or batch queries)
- Loading entire datasets (use pagination)
- Missing database indexes

**REMEMBER: You are optimistic. Humans are paranoid. Be paranoid.**

---

# Workflow Lifecycle

## Task Complexity Guide

| Complexity | Indicators | Approach |
|------------|-----------|----------|
| **Small** | <4 hours, single file, clear requirements | Minimal plan -> Implement -> Test -> Security check |
| **Medium** | 4-16 hours, multiple files, some unknowns | Standard plan -> Phased implementation |
| **Complex** | >16 hours, architectural decisions, high risk | Comprehensive plan + ADR -> Multi-phase -> Reviews |

---

## Workflow Entry Points

### Entry Point A: New Feature (Start at Phase 0)
**Use when:** Starting a new feature from scratch
- Proceed to **Phase 0: Exploration & Planning** (below)
- Complete plan, create issues (optional), then execute

### Entry Point B: Pick Existing Issue from Backlog (Start at Phase 1)
**Use when:** Picking up a pre-planned issue from GitHub/GitLab Projects backlog

**Required actions:**

1. **Load the issue:**
   ```
   # View issue details (adjust for PowerShell on Windows)
   gh issue view ISSUE_NUMBER    # GitHub
   glab issue view ISSUE_NUMBER  # GitLab
   ```

2. **Extract context from issue:**
   - **Description**: Understand what needs to be built and why
   - **Acceptance Criteria**: Know what "done" looks like
   - **Technical Requirements**: Architecture, technologies, patterns
   - **Testing Notes**: What tests are required
   - **Security Considerations**: Check for `flag: security-sensitive` label
   - **Performance Considerations**: Check for `flag: performance-critical` label
   - **Related Issues**: Check dependencies (must be unblocked)
   - **Plan Reference**: Note the linked plan file path

3. **Verify issue is ready:**
   - Not blocked by dependencies
   - Has clear acceptance criteria
   - Technical requirements are understood
   - All context needed is in issue

4. **Restate the task:**
   - In your own words, summarize what needs to be built
   - Confirm with user if anything is unclear

5. **Skip to Phase 1, Step 1** (below)

---

## Phase 0: Exploration & Planning

**Use Entry Point A (above) to start here.**

### Step 1: Explore (NEVER Skip This)

**REQUIRED ACTIONS:**
1. **Search, don't guess:** Search file contents for relevant patterns
2. **Read specific files:** Target specific line ranges, not entire directories
3. **Check for codebase map:** Read `.claude/CODEBASE_MAP.md` or project README if they exist
4. **Ask clarifying questions:** Don't assume requirements

**Context Optimization (Critical for Cost):**
- BAD: "Read all files in src/"
- GOOD: "Search for UserAuth, then read src/auth/UserAuth.ts lines 45-120"
- For files >500 lines, request summary FIRST

### Step 1.5: Brainstorm (Optional but Recommended for Complex Features)

**Use:** /brainstorm command

When multiple valid approaches exist, brainstorm before committing to a solution:
1. Search `docs/solutions/` for relevant past learnings
2. Generate 2-3 approaches with pros/cons/complexity/risk
3. Present comparison matrix, get user decision
4. Save to `docs/brainstorms/YYYY-MM-DD-{slug}-brainstorm.md`

**Skip for:** Clear bug fixes, small tasks, when approach is obvious.

### Step 2: Plan with Extended Thinking

**Users can request deeper reasoning with these triggers:**
- `"think"` - Standard reasoning for moderate complexity
- `"think hard"` - Multi-step problems, security architecture, debugging complex issues
- `"ultrathink"` - Critical architecture decisions, major refactors, high-risk changes

### Step 3: Generate Plan

**Minimal plan (small tasks):** Problem + Solution + Affected Files + Tests + Risks
**Standard plan (moderate):** Adds Goals, Technical Approach, Implementation Steps, Security Review, Past Learnings
**Comprehensive plan (complex):** Full template + Spec-Flow Analysis, Alternatives Considered, Rollback Plan

**MUST include:**
- Test strategy (specific test cases, not just "write tests")
- Security review section (is this security-sensitive?)

### Step 3a: Save Plan to File

**MANDATORY: Always save plan to local file**

**File location:** `docs/plans/YYYY-MM-DD-type-feature-name-plan.md`

**Naming convention:**
- Date format: `YYYY-MM-DD`
- Type: `minimal`, `standard`, or `comprehensive`
- Feature name: lowercase-with-hyphens
- Examples:
  - `docs/plans/2026-02-04-minimal-fix-login-bug-plan.md`
  - `docs/plans/2026-02-04-standard-user-authentication-plan.md`
  - `docs/plans/2026-02-04-comprehensive-api-redesign-plan.md`

**After issue creation (Step 6):**
- Rename plan to prepend issue number: `NNN-YYYY-MM-DD-type-feature-name-plan.md`

### Step 3b: Deepen Plan (Optional)

**Use:** /deepen-plan command

Enrich the plan with research:
1. Parse plan into sections
2. Research each section (codebase patterns, best practices, past learnings)
3. Update plan in-place with `[DEEPENED]` annotations

### Step 3c: Review Plan (Optional)

**Use:** /review-plan command

Multi-perspective plan review before implementation:
1. Review from 4 perspectives: Architecture, Simplicity, Spec-Flow, Security
2. Run adversarial validation after reviews (challenges plan AND findings)
3. Consolidate report with verdict: APPROVED / REVISION_REQUESTED / APPROVED_WITH_NOTES

### Step 4: Check for Architectural Decision

**STOP: Do you need an ADR?**

Create ADR if:
- Major architectural choice (database, framework, cloud provider)
- Decision is hard to reverse
- Significant tradeoffs between alternatives
- Pattern will be reused across codebase

**If YES:**
1. Create `docs/adr/NNNN-title.md`
2. Document: Context, Decision, Consequences, Alternatives

### Step 5: Pause for Human Approval

**Status:** `READY_FOR_REVIEW (confidence_level, risk_flags)`

**Wait for:** `APPROVED_NEXT_PHASE` before proceeding

---

### Step 6: Create Issues (Optional)

**DECISION POINT: Immediate Execution or Backlog Mode?**

**If using GitHub/GitLab Projects workflow:**

1. **Generate issues from approved plan:**
   - Use: /create-issues with the plan path

2. **Create first issue and rename plan:**
   ```
   # GitHub (adjust for PowerShell on Windows)
   gh issue create --title "..." --body "..."

   # GitLab
   glab issue create --title "..." --description "..."
   ```

3. **Commit and push plan to repository** (so it's available to anyone picking up the issue)

4. **Choose execution mode:**

   **FORK A: Immediate Execution**
   - Assign to current session
   - Pick first issue and proceed to Phase 1

   **FORK B: Backlog Mode**
   - Create issues without assignee
   - Add to project board "Ready" column
   - Exit workflow

**If NOT using issue tracking:** Skip to Phase 1 directly.

---

## Phase 1: Execution Loop

**Entry paths:**
- **From Phase 0**: After plan approval and optional issue creation
- **From Entry Point B**: Picked existing issue from backlog (skipped Phase 0)

### Step 1: Restate & Checkpoint

- Restate phase goals (from plan or from issue context)
- Ensure git checkpoint exists (can rollback if needed)
- **Search `docs/solutions/` for relevant past learnings**
- Create living plan in `.todos/{issue_id}-plan.md` for progress tracking

**If working from issue:**

1. **Assign issue:**
   ```
   gh issue edit ISSUE_NUM --add-assignee @me     # GitHub
   glab issue update ISSUE_NUM --assignee @me      # GitLab
   ```

2. **Create issue-specific branch:**
   ```
   git checkout -b issue-ISSUE_NUM-feature-name
   git push -u origin issue-ISSUE_NUM-feature-name
   ```

### Step 2: Implement Code

**Code Standards:**
- Follow existing project patterns (read similar files)
- Keep functions small (<50 lines ideal, <100 max)
- Use descriptive names (not `x`, `temp`, `data`)
- DRY: Extract reusable logic
- Simple > Clever

**Before writing EVERY function, ask:**
1. What if input is null?
2. What if input is empty?
3. What if input is at boundary (0, -1, max)?
4. What error conditions exist?
5. Does this need try/catch?

---

### Step 3: Generate Tests (MANDATORY)

**MANDATORY ACTIONS:**
1. Identify code type (API? Auth? Business logic?)
2. Follow test requirements for that type

**MINIMUM test cases (ALWAYS include):**
1. Happy path (normal input -> expected output)
2. Null/empty input
3. Boundary values (0, max, min)
4. Invalid input (wrong type, malformed)
5. Error conditions (network failure, timeout)

**Test naming:**
```
test_function_name_happy_path()
test_function_name_null_input()
test_function_name_boundary_values()
test_function_name_invalid_input_raises_error()
```

**Coverage requirement:** >80% for new code

---

### Step 4: Security Review (If Triggered)

**Triggers (if ANY apply, MUST review):**
- Authentication or authorization code
- User input processing
- Database queries
- File uploads
- External API calls
- PII or sensitive data handling
- Admin/privileged operations

**IF ANY BOX CHECKED:**

1. **STOP implementation immediately**
2. **Load:** the "Security Review Checklist" rule
3. **COMPLETE:** All applicable checklist items
4. **FLAG:** `SECURITY_SENSITIVE` in status
5. **CONFIRM:** "Security review completed - [items passed/items failed]"

**ONLY proceed after explicit human approval on security-sensitive code.**

---

### Step 5: Run Tests & Validation

```
# Run full test suite (adjust for your project)
npm test          # or: pytest, cargo test, go test ./...
npm test -- --coverage
npm audit         # or: pip-audit, cargo audit
npm run lint
```

**Adjust these commands for PowerShell on Windows if needed.**

**ALL must pass before proceeding.**

---

### Step 6: Fresh Eyes Code Review

**MANDATORY CHECKPOINT - CANNOT PROCEED WITHOUT COMPLETING THIS STEP**

Load the "Fresh Eyes Review" guide and follow its process.

This is a specialized review system that provides unbiased code review by analyzing the diff with ZERO conversation context.

**Choose your review tier based on change size:**
- **Lite Review** (<4 hours, <100 LOC): Code Quality review only, 5-10 min
- **Standard Review** (4-15 hours, 100-500 LOC): Security + Code Quality + Supervisor, 10-15 min
- **Full Review** (>15 hours, >500 LOC): Security + Code Quality + Performance + Supervisor, 15-20 min

**CRITICAL - You CANNOT skip this step:**
- This is a MANDATORY protocol step for ALL code changes
- Skipping this step is a protocol violation
- Review with zero conversation history eliminates confirmation bias
- Catches security vulnerabilities (45% of AI code has security issues)
- Must fix all CRITICAL/HIGH issues before proceeding to commit

---

**After completing Fresh Eyes Review, verify checkpoint:**
- Fresh Eyes Review completed
- All CRITICAL findings addressed
- All HIGH findings addressed or documented why skipped
- Ready to proceed to Step 6.5 (Recovery Decision Point)

---

### Step 6.5: Recovery Decision Point

**CHECKPOINT: Implementation Working or Needs Recovery?**

If Fresh Eyes Review found issues that cannot be quickly fixed (<30 minutes), or implementation is fundamentally flawed, you may need to recover.

Load the "Failure Recovery" guide for detailed procedures.

**Quick decision tree:**
```
Can all issues be fixed in <30 minutes? -> YES -> Continue to Step 7
                                        -> NO
Is approach fundamentally flawed? -> YES -> ABANDON (Partial Save -> Phase 0)
                                  -> NO
                            ROLLBACK & RETRY (Different approach)
```

---

### Step 7: Report & Pause

**Report format:**
```
Phase [N] complete.

Deliverables:
- [Item 1]
- [Item 2]

Tests: [N] tests, [X]% coverage, all passing
Security: [Review completed | Not applicable]
Linting: Passed

Edge cases covered:
- Null handling: [details]
- Boundary values: [details]
- Error conditions: [details]

Status: READY_FOR_REVIEW (confidence_level)
Risk flags: [SECURITY_SENSITIVE | PERFORMANCE_IMPACT | etc.]

Next: Awaiting approval for Phase [N+1]
```

**WAIT for human feedback. DO NOT proceed automatically.**

---

### Step 8: Commit Changes & Create PR

**If working from issue:**

1. **Commit all changes:**
   ```
   git add .
   git commit -m "feat: Implement [feature description]

   - [Key change 1]
   - [Key change 2]
   - [Key change 3]

   Closes #ISSUE_NUM"

   git push origin issue-ISSUE_NUM-feature-name
   ```

2. **Ask for PR creation approval** by presenting a summary and numbered options.

3. **If approved, ask for base branch:**
   ```
   Which branch should this PR target?
   1. main (production/stable branch)
   2. experimental (testing/development branch)
   3. other (specify)
   ```

4. **Create PR:**
   ```
   # GitHub (adjust for PowerShell on Windows)
   gh pr create --title "feat: [Brief description] (Closes #ISSUE_NUM)" --body "..."

   # GitLab
   glab mr create --title "feat: [Brief description] (Closes #ISSUE_NUM)" --description "..."
   ```

---

## Phase 2: Finalization

### Step 1: Refactor
- Remove duplication
- Extract magic numbers to constants
- Simplify complex conditionals
- Ensure functions are focused (Single Responsibility)

### Step 2: Documentation
- Update README if public API changed
- Add comments explaining WHY (not what)
- Update OpenAPI spec if API changes
- Create/update ADR for architectural decisions

### Step 3: Final Validation
- Full test suite passes
- No security vulnerabilities
- Performance acceptable
- All edge cases covered

### Step 4: Change Log
- What changed and why
- Breaking changes (if any)
- Migration steps (if needed)

### Step 5: Final Human Sign-Off

**Status:** `READY_FOR_MERGE (HIGH_CONFIDENCE)`

**Wait for explicit approval before considering task complete.**

---

## Phase 3: Compound (After Merge)

### Step 1: Capture Learnings

**Use:** /learn command

After completing a feature or fixing a tricky bug:
1. Identify key learnings, gotchas, and insights from the implementation
2. Check if similar solutions already exist in `docs/solutions/`
3. Create solution doc with metadata
4. Save to `docs/solutions/{problem_type-directory}/{slug}-{YYYYMMDD}.md`

**Auto-trigger phrases (suggest /learn when these appear):**
- "the trick was", "the fix was", "root cause was"
- "I learned that", "next time we should"
- "key insight", "important gotcha"

**Why compound:**
- Future /explore and /start-issue runs search `docs/solutions/`
- Prevents repeating the same mistakes
- Builds institutional knowledge that survives across sessions

---

# Communication Protocol

## Status Indicators

| Status | Meaning |
|--------|---------|
| `READY_FOR_REVIEW` | Phase complete, awaiting feedback |
| `SECURITY_SENSITIVE` | Requires mandatory security review |
| `REVISION_REQUESTED` | Human requested changes, paused |
| `APPROVED_NEXT_PHASE` | Cleared to continue |
| `HALT_PENDING_DECISION` | Blocked on ambiguity |
| `RECOVERY_MODE` | Implementation failed, evaluating rollback/abandon |

## Confidence Levels

| Level | When to Use |
|-------|-------------|
| `HIGH_CONFIDENCE` | Well-understood, low risk, all tests pass, edge cases covered |
| `MEDIUM_CONFIDENCE` | Some uncertainty, may need iteration |
| `LOW_CONFIDENCE` | Significant unknowns, recommend discussion |

## Risk Flags (Use When Applicable)

- `BREAKING_CHANGE` - May affect existing functionality
- `SECURITY_SENSITIVE` - Auth, data, APIs
- `PERFORMANCE_IMPACT` - Latency or resource concerns
- `DEPENDENCY_CHANGE` - New/updated dependencies

---

# Context Optimization (Critical for Cost/Quality)

## Core Rules

1. **Be Surgical:** Read specific line ranges, not entire files
2. **Search First:** Find exact locations before reading
3. **Summarize Large Files:** Request summary for files >500 lines
4. **Use Codebase Maps:** Create `.claude/CODEBASE_MAP.md` (saves 50%+ tokens)
5. **Clear Between Tasks:** Start new conversation when switching topics
6. **Batch Questions:** Ask related questions together

## Token Budgets

| Task Type | Target | Max | Strategy |
|-----------|--------|-----|----------|
| Bug fix | <10k | 20k | Read affected file only |
| Small feature | <30k | 50k | Codebase map + targeted files |
| Large feature | <80k | 120k | Explore first, then implement |

**If exceeding budget:** You're reading too much. Be more surgical.

---

# Workflow Variants

## Test-Driven Development (TDD)
1. Write failing tests FIRST
2. Implement until tests pass
3. Refactor
4. Commit

## Bug Fix Workflow
1. **Reproduce bug** - Follow exact steps
2. **Write failing test** - Captures the bug
3. **Fix minimally**
4. **Verify test passes**
5. **Ask:** What caused this? How prevent similar bugs?

---

# Final Verification (Before Completion)

**MANDATORY - Complete Before Marking Task Done**

- All tests pass (unit + integration + security)
- Test coverage >80%
- Security review completed (if triggered)
- No vulnerabilities (audit clean)
- Edge cases tested (null, empty, boundaries)
- Error handling present (try/catch around externals)
- No performance issues (N+1 queries, missing indexes)
- Code readable and maintainable
- Documentation updated
- ADR created (if architectural decision)
- Human review approved

**If ANY item unchecked: Task is NOT complete.**

---

# Remember These Throughout

## NEVER Do These:
- Skip exploration (always understand codebase first)
- Skip security review when triggered
- Skip edge case testing (null, empty, boundaries)
- Proceed without human approval
- Hardcode secrets in code
- Use string concatenation in SQL
- Trust user input without validation
- Read entire directories (be surgical)

## ALWAYS Do These:
- Ask when uncertain (don't hallucinate)
- Test edge cases explicitly
- Wrap external calls in try/catch
- Validate user input
- Encode output (prevent XSS)
- Use parameterized SQL queries
- Pause for human feedback
- Flag security-sensitive code
