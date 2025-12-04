# AI Coding Agent Standard Operating Protocol (SOP)

**Version:** 3.2
**Last Updated:** December 2025
**Purpose:** Safe, effective AI-assisted software development

**NEW:** 13 modular slash commands available for flexible workflows - see `~/.claude/commands/*.md` and `QUICK_START.md`

---

## Document Role

This is the **comprehensive reference document** for the GODMODE protocol.

**For quick access:**
- Critical safety rules → `~/.claude/CLAUDE.md` (auto-loaded with highest priority)
- Modular commands → `~/.claude/commands/*.md` (13 commands)
- Quick reference → `~/.claude/QUICK_START.md`

**Use this document when:**
- Learning the full protocol for the first time
- Need detailed phase-by-phase guidance
- Want comprehensive entry point documentation
- Reference for architectural decisions

**Note:** Critical safety rules and AI blind spots are duplicated in CLAUDE.md to ensure they're always loaded with system priority.

---

# ⚠️ CRITICAL SAFETY RULES - READ FIRST

## Core Principles (You MUST Follow)

| Rule | What It Means |
|------|---------------|
| **EXPLORE FIRST** | NEVER guess. Use Grep to find patterns. Read relevant files BEFORE proposing solutions. |
| **HUMAN IN LOOP** | NEVER merge, deploy, or finalize without explicit human approval. ALWAYS pause for feedback. |
| **SECURITY FIRST** | 45% of AI code has vulnerabilities. ALWAYS run security checklist for auth/data/APIs. |
| **TEST EVERYTHING** | Every function MUST have tests. ALWAYS test: happy path + null + boundaries + errors. |
| **EDGE CASES MATTER** | AI forgets null, empty, boundaries. ALWAYS check these explicitly. |
| **SIMPLE > CLEVER** | Prefer clear, maintainable code. Avoid over-engineering. |
| **FLAG UNCERTAINTY** | If unsure, ask. Don't hallucinate APIs or make assumptions. |

---

## AI Blind Spots (You SYSTEMATICALLY Miss These)

### ⚠️ Edge Cases You ALWAYS Forget:
- **Null/undefined/None** - Check EVERY function parameter
- **Empty collections** - [], {}, ""
- **Boundary values** - 0, -1, MAX_INT, empty string
- **Special characters** - Unicode, emoji, quotes in strings
- **Timezones/DST** - Date handling across timezones

### ⚠️ Security Vulnerabilities (45% of AI Code):
- **SQL injection** - NEVER concatenate strings in SQL (use parameterized queries)
- **XSS** - ALWAYS encode output in HTML context
- **Missing auth** - Check user can access THIS resource
- **Hardcoded secrets** - NEVER put API keys in code (use env vars)
- **No input validation** - Validate ALL user input (allowlist > blocklist)

### ⚠️ Error Handling You Skip:
- Try/catch around ALL external calls (API, DB, file I/O)
- Handle network failures, timeouts, permission errors
- Error messages MUST NOT leak sensitive data

### ⚠️ Performance Mistakes:
- N+1 query problems (use joins or batch queries)
- Loading entire datasets (use pagination)
- Missing database indexes

**REMEMBER: You are optimistic. Humans are paranoid. Be paranoid.**

---

# Workflow Lifecycle

## Task Complexity Guide

| Complexity | Indicators | Approach |
|------------|-----------|----------|
| **Small** | <4 hours, single file, clear requirements | Lite PRD → Implement → Test → Security check |
| **Medium** | 4-16 hours, multiple files, some unknowns | Abbreviated PRD → Phased implementation |
| **Complex** | >16 hours, architectural decisions, high risk | Full PRD + ADR → Multi-phase → Reviews |

---

## Workflow Entry Points

⚠️ **DECISION: New Feature or Existing Issue?**

### Entry Point A: New Feature (Start at Phase 0)
**Use when:** Starting a new feature from scratch
- Proceed to **Phase 0: Exploration & Planning** (below)
- Complete PRD, create issues (optional), then execute

### Entry Point B: Pick Existing Issue from Backlog (Start at Phase 1)
**Use when:** Picking up a pre-planned issue from GitHub Projects backlog

**Required actions:**

1. **Load the issue:**
   ```bash
   # View issue details
   gh issue view ISSUE_NUMBER

   # Or list ready issues
   gh project item-list PROJECT_NUM --owner OWNER
   ```

2. **Extract context from issue:**
   - **Description**: Understand what needs to be built and why
   - **Acceptance Criteria**: Know what "done" looks like
   - **Technical Requirements**: Architecture, technologies, patterns
   - **Testing Notes**: What tests are required
   - **Security Considerations**: Check for `flag: security-sensitive` label
   - **Performance Considerations**: Check for `flag: performance-critical` label
   - **Related Issues**: Check dependencies (must be unblocked)
   - **PRD Reference**: Note the linked PRD file path (e.g., `docs/prds/123-2025-11-29-user-auth.md`)

3. **Verify issue is ready:**
   - [ ] Not blocked by dependencies
   - [ ] Has clear acceptance criteria
   - [ ] Technical requirements are understood
   - [ ] All context needed is in issue (no need to reference original PRD)

4. **Restate the task:**
   - In your own words, summarize what needs to be built
   - Confirm with user if anything is unclear

5. **Skip to Phase 1, Step 1** (below)

**Example:**
```
User: "Let's work on issue #45"

AI: [Loads issue via gh issue view 45]

AI: "I'll implement issue #45: Implement password hashing

Summary:
- Build bcrypt-based password hashing service
- Hash passwords on user registration
- Verify passwords on login
- Must use bcrypt rounds = 12
- Security-sensitive (will run security checklist)

Acceptance criteria:
✓ hashPassword(plaintext) returns bcrypt hash
✓ verifyPassword(plaintext, hash) returns boolean
✓ Minimum 12 rounds
✓ All edge cases tested (null, empty, unicode)

Dependencies: None (issue #44 already complete)

Ready to proceed to Phase 1 implementation?"
```

---

## Phase 0: Exploration & Planning

**Use Entry Point A (above) to start here.**

### Step 1: Explore (NEVER Skip This)

**REQUIRED ACTIONS:**
1. **Use Grep, not guessing:** `grep "auth" src/` to find patterns
2. **Read specific files:** `@file:line-range`, not entire directories
3. **Check for codebase map:** Read `.claude/CODEBASE_MAP.md` if exists
4. **Ask clarifying questions:** Don't assume requirements

**Context Optimization (Critical for Cost):**
- ❌ BAD: "Read all files in src/"
- ✅ GOOD: "Grep for UserAuth, then read src/auth/UserAuth.ts:45-120"
- Create `.claude/CODEBASE_MAP.md` for reusable architecture context
- For files >500 lines, request summary FIRST

### Step 2: Plan with Extended Thinking

**Users can request deeper reasoning with these triggers:**
- `"think"` - Standard reasoning for moderate complexity
- `"think hard"` - Multi-step problems, security architecture, debugging complex issues
- `"ultrathink"` - Critical architecture decisions, major refactors, high-risk changes

**When Claude should suggest extended thinking:**
- Security-sensitive changes → Suggest "think hard"
- Architecture decisions with multiple valid approaches → Suggest "ultrathink"
- Debugging that requires tracing through multiple systems → Suggest "think hard"

### Step 3: Generate PRD

**Use:** `PRD_TEMPLATE.md`

**Lite PRD (small tasks):** Problem + Solution + Tests + Security check
**Full PRD (complex):** All sections

**MUST include:**
- Test strategy (specific test cases, not just "write tests")
- Security review section (is this security-sensitive?)

### Step 3a: Save PRD to File

⚠️ **MANDATORY: Always save PRD to local file**

**Initial file location:** `docs/prds/YYYY-MM-DD-feature-name.md`

**Example:**
```bash
# Check for existing PRDs
ls docs/prds/

# Create directory if needed
mkdir -p docs/prds

# Save PRD with date + descriptive name
# Example: docs/prds/2025-11-29-user-authentication.md
```

**Naming convention:**
- Date format: `YYYY-MM-DD`
- Feature name: lowercase-with-hyphens
- Examples:
  - `docs/prds/2025-11-29-user-authentication.md`
  - `docs/prds/2025-11-29-api-rate-limiting.md`
  - `docs/prds/2025-11-29-password-reset-flow.md`

**After GitHub issue creation (Step 6):**
- Rename PRD to prepend issue number: `NNN-YYYY-MM-DD-feature-name.md`
- Example: Issue #123 created → Rename to `docs/prds/123-2025-11-29-user-authentication.md`
- Update issue to reference renamed file

**Why save PRD:**
- Reference during implementation (Phase 1)
- Link from GitHub issues
- Historical record of decisions
- Context for future developers
- Issue number creates direct link between PRD and implementation

### Step 4: Check for Architectural Decision

⚠️ **STOP: Do you need an ADR?**

Create ADR if:
- [ ] Major architectural choice (database, framework, cloud provider)
- [ ] Decision is hard to reverse
- [ ] Significant tradeoffs between alternatives
- [ ] Pattern will be reused across codebase

**If YES:**
1. READ: `templates/ADR_TEMPLATE.md`
2. CREATE: `docs/adr/NNNN-title.md`
3. Document: Context, Decision, Consequences, Alternatives

### Step 5: Pause for Human Approval

**Status:** `READY_FOR_REVIEW (confidence_level, risk_flags)`

**Wait for:** `APPROVED_NEXT_PHASE` before proceeding

---

### Step 6: Create GitHub Issues (Optional)

⚠️ **DECISION POINT: Immediate Execution or Backlog Mode?**

**If using GitHub Projects workflow:**

1. **Generate issues from approved PRD:**
   - Use: `/create-issues docs/prds/2025-11-29-feature-name.md`
   - See: `guides/GITHUB_PROJECT_INTEGRATION.md` for full workflow

2. **Create first issue and rename PRD:**
   - Create first GitHub issue with `gh issue create`
   - Note the issue number returned (e.g., #123)
   - Rename PRD file to prepend issue number:
     ```bash
     # Example: Issue #123 created
     mv docs/prds/2025-11-29-user-authentication.md \
        docs/prds/123-2025-11-29-user-authentication.md
     ```
   - Update issue body to reference renamed PRD

3. **Commit and push PRD to repository:**
   ```bash
   # CRITICAL: Push PRD to git so it's available to anyone picking up the issue
   git add docs/prds/123-2025-11-29-user-authentication.md
   git commit -m "docs: Add PRD for user authentication (Issue #123)

   Generated PRD for user authentication feature.
   Linked to issue #123.

   🤖 Generated with Claude Code"

   git push origin main  # or current branch
   ```

   **Why this is critical:**
   - PRD must be in repository for other developers
   - PRD must be available if you pick up issue later in different session
   - Issue references PRD file path - must exist in repo
   - Enables team collaboration on backlog

4. **Choose execution mode:**

   **FORK A: Immediate Execution**
   - Create issues with labels (see standard label system in guide)
   - Assign to current session (`--assignee @me`)
   - Pick first issue and proceed to Phase 1
   - Work through issues sequentially in current session

   **FORK B: Backlog Mode**
   - Create issues without assignee
   - Add to GitHub Project "Ready" column
   - Exit GODMODE workflow
   - Issues remain in backlog for later pickup (via @claude tag or manual selection)

3. **Label each issue** using standard system:
   - `type:` - bug | feature | enhancement | docs | refactor | test | infrastructure
   - `priority:` - critical | high | medium | low
   - `area:` - frontend | backend | infrastructure | security | testing
   - `flag:` (if applicable) - security-sensitive | performance-critical | breaking-change

**If NOT using GitHub Projects:** Skip to Phase 1 directly.

**See:** `guides/GITHUB_PROJECT_INTEGRATION.md` for:
- GitHub CLI commands (`gh issue create`, `gh project item-list`)
- Standard label system setup
- Project board workflow
- Assigning issues to Claude Code

---

## Phase 1: Execution Loop

**Entry paths:**
- **From Phase 0**: After PRD approval and optional issue creation
- **From Entry Point B**: Picked existing issue from backlog (skipped Phase 0)

### Step 1: Restate & Checkpoint

- Restate phase goals (from PRD or from issue context)
- Ensure git checkpoint exists (can rollback if needed)

**If working from GitHub issue:**

1. **Assign issue to user:**
   ```bash
   # Assign to yourself (the prompter)
   gh issue edit ISSUE_NUM --add-assignee @me
   ```

2. **Create issue-specific branch:**
   ```bash
   # Branch naming: issue-NNN-brief-description
   # Example: issue-123-user-authentication
   git checkout -b issue-ISSUE_NUM-feature-name

   # Push branch to remote
   git push -u origin issue-ISSUE_NUM-feature-name
   ```

3. **Update issue status** (if using GitHub Projects):
   ```bash
   gh issue comment ISSUE_NUM --body "🚧 Starting implementation on branch \`issue-ISSUE_NUM-feature-name\`"
   ```

**Branch naming convention:**
- Format: `issue-NNN-brief-description`
- Examples:
  - `issue-123-user-authentication`
  - `issue-456-api-rate-limiting`
  - `issue-789-password-reset`
- Lowercase with hyphens
- Keep brief but descriptive

### Step 2: Implement Code

**Reference PRD if needed:**
- If from Phase 0: PRD context is fresh in memory
- If from Entry Point B: PRD file path is in issue (e.g., `docs/prds/123-2025-11-29-user-auth.md`)
- Read PRD if:
  - Issue context is unclear
  - Need broader architectural context
  - Want to understand tradeoffs considered
  - Checking if change aligns with original requirements

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

⚠️ **STOP: Test Strategy Checkpoint**

**MANDATORY ACTIONS:**
1. READ: `templates/TEST_STRATEGY.md`
2. Identify code type (API? Auth? Business logic?)
3. Follow test requirements for that type

**MINIMUM test cases (ALWAYS include):**
1. ✅ Happy path (normal input → expected output)
2. ✅ Null/empty input
3. ✅ Boundary values (0, max, min)
4. ✅ Invalid input (wrong type, malformed)
5. ✅ Error conditions (network failure, timeout)

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

⚠️ **STOP: Security Checkpoint**

**Triggers (if ANY apply, MUST review):**
- [ ] Authentication or authorization code
- [ ] User input processing
- [ ] Database queries
- [ ] File uploads
- [ ] External API calls
- [ ] PII or sensitive data handling
- [ ] Admin/privileged operations

**IF ANY BOX CHECKED:**

1. **STOP implementation immediately**
2. **READ:** `checklists/AI_CODE_SECURITY_REVIEW.md`
3. **COMPLETE:** All applicable checklist items
4. **FLAG:** `SECURITY_SENSITIVE` in status
5. **CONFIRM:** "Security review completed - [items passed/items failed]"

**ONLY proceed after explicit human approval on security-sensitive code.**

---

### Step 5: Run Tests & Validation

```bash
# Run full test suite
npm test  # or: pytest, cargo test, etc.

# Check coverage
npm test -- --coverage

# Security scan
npm audit  # or: pip-audit, cargo audit

# Linter
npm run lint
```

**ALL must pass before proceeding.**

---

### Step 6: Fresh Eyes Code Review

🚫 **MANDATORY CHECKPOINT - CANNOT PROCEED WITHOUT COMPLETING THIS STEP**

**You MUST read and execute:**

**`~/.claude/guides/FRESH_EYES_REVIEW.md`**

This document contains the complete Fresh Eyes Review process - a specialized multi-agent review system that provides unbiased code review using agents with **ZERO conversation context**.

**Choose your review tier based on change size:**
- **Lite Review** (<4 hours, <100 LOC): Code Quality agent only, 5-10 min
- **Standard Review** (4-15 hours, 100-500 LOC): Security + Code Quality + Supervisor, 10-15 min
- **Full Review** (>15 hours, >500 LOC): Security + Code Quality + Performance + Supervisor, 15-20 min

**CRITICAL - You CANNOT skip this step:**
- This is a MANDATORY protocol step for ALL code changes
- Skipping this step is a protocol violation
- Review agents have zero conversation history (eliminates confirmation bias)
- Catches security vulnerabilities (45% of AI code has security issues)
- Must fix all CRITICAL/HIGH issues before proceeding to commit

**Read the file now and follow the review process exactly.**

---

**After completing Fresh Eyes Review, verify checkpoint:**
- [ ] Fresh Eyes Review completed
- [ ] All CRITICAL findings addressed
- [ ] All HIGH findings addressed or documented why skipped
- [ ] Ready to proceed to Step 6.5 (Recovery Decision Point)

---

### Step 6.5: Recovery Decision Point

⚠️ **CHECKPOINT: Implementation Working or Needs Recovery?**

If Fresh Eyes Review found issues that cannot be quickly fixed (<30 minutes), or implementation is fundamentally flawed, you may need to recover.

**Evaluate using the decision tree:**

**Read:** `~/.claude/guides/FAILURE_RECOVERY.md`

**Quick decision tree:**
```
Can all issues be fixed in <30 minutes? → YES → Continue to Step 7
                                        ↓ NO
Is approach fundamentally flawed? → YES → ABANDON (Partial Save → Phase 0)
                                  ↓ NO
                            ROLLBACK & RETRY (Different approach)
```

**Recovery actions:**
- **Continue:** Proceed to Step 7 (normal flow)
- **Rollback & Retry:** Use git to rollback, try different approach, restart Phase 1
- **Abandon:** Partial save useful artifacts, document learnings, return to Phase 0

**Status indicator when in recovery:**
- Set status to: `RECOVERY_MODE`
- Document recovery action taken
- Follow procedures in FAILURE_RECOVERY.md

**After recovery decision:**
- [ ] Decision made: Continue | Rollback | Abandon
- [ ] Recovery procedure executed (if applicable)
- [ ] Recovery report created (if Rollback or Abandon)
- [ ] Ready to proceed to Step 7 (if Continue) or exit Phase 1 (if Rollback/Abandon)

---

### Step 7: Report & Pause

**Report format:**
```
Phase [N] complete.

✅ Deliverables:
- [Item 1]
- [Item 2]

✅ Tests: [N] tests, [X]% coverage, all passing
✅ Security: [Review completed | Not applicable]
✅ Linting: Passed

⚠️ Edge cases covered:
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

⚠️ **CHECKPOINT: Implementation Complete**

**If working from GitHub issue:**

1. **Commit all changes:**
   ```bash
   # Stage all changes
   git add .

   # Commit with descriptive message linking to issue
   git commit -m "$(cat <<'EOF'
   feat: Implement [feature description]

   - [Key change 1]
   - [Key change 2]
   - [Key change 3]

   Closes #ISSUE_NUM

   🤖 Generated with Claude Code (https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"

   # Push to remote branch
   git push origin issue-ISSUE_NUM-feature-name
   ```

2. **Ask for PR creation approval:**
   ```
   ✅ All changes committed to branch `issue-ISSUE_NUM-feature-name`

   Summary:
   - [What was implemented]
   - Tests: [N] passing, [X]% coverage
   - Security: [Review status]
   - Edge cases: Covered

   Ready to create Pull Request?
   - PR will link to issue #ISSUE_NUM (auto-closes on merge)
   - Reviewable on GitHub before merging
   - Can be merged when approved

   Proceed with PR creation? (yes/no)
   ```

3. **If approved, ask for base branch:**
   ```
   Which branch should this PR target?
   - main (production/stable branch)
   - experimental (testing/development branch)
   - other (specify)

   Target branch: _____
   ```

4. **Create PR with specified base branch:**
   ```bash
   # Replace BASE_BRANCH with user's choice (main, experimental, etc.)
   gh pr create \
     --title "feat: [Brief description] (Closes #ISSUE_NUM)" \
     --body "$(cat <<'EOF'
   ## Summary
   [Brief description of what was implemented]

   ## Changes
   - [Key change 1]
   - [Key change 2]
   - [Key change 3]

   ## Testing
   - ✅ Unit tests: [N] tests, [X]% coverage
   - ✅ Integration tests: [Status]
   - ✅ Edge cases: Null, empty, boundaries, errors
   - ✅ Security review: [Completed | Not applicable]

   ## Acceptance Criteria
   - [x] [Criterion 1]
   - [x] [Criterion 2]
   - [x] [Criterion 3]

   ## PRD Reference
   Source: `docs/prds/ISSUE_NUM-YYYY-MM-DD-feature-name.md`

   Closes #ISSUE_NUM

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )" \
     --base BASE_BRANCH
   ```

   **Common base branches:**
   - `--base main` - For production-ready changes
   - `--base experimental` - For testing/development changes
   - `--base develop` - If using GitFlow workflow

5. **Report PR creation:**
   ```
   ✅ Pull Request created: https://github.com/owner/repo/pull/XXX

   Next steps:
   1. Review PR on GitHub
   2. Approve and merge when ready
   3. Issue #ISSUE_NUM will auto-close on merge
   4. Branch issue-ISSUE_NUM-feature-name can be deleted after merge
   ```

**If NOT using GitHub issues:**
- Commit changes with standard commit message
- Push to feature branch
- Create PR manually or skip to Phase 2 for direct merge

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

1. **Be Surgical:** Read `@file:45-120`, not entire files
2. **Grep First:** Find exact locations before reading
3. **Summarize Large Files:** Request summary for files >500 lines
4. **Use Codebase Maps:** Create `.claude/CODEBASE_MAP.md` (saves 50%+ tokens)
5. **Clear Between Tasks:** Use `/clear` when switching topics
6. **Batch Questions:** Ask related questions together

## Token Budgets

| Task Type | Target | Max | Strategy |
|-----------|--------|-----|----------|
| Bug fix | <10k | 20k | Read affected file only |
| Small feature | <30k | 50k | Codebase map + targeted files |
| Large feature | <80k | 120k | Explore agent first |

**If exceeding budget:** You're reading too much. Be more surgical.

---

# Multi-Agent Patterns (For Complex Tasks)

**Use when:** >15 hours, multiple domains, parallel work possible

**Patterns:**
1. **Research → Execute:** Explore agent gathers context, Execute agent implements
2. **Specialists:** Frontend agent + Backend agent + Test agent work in parallel
3. **Review Chain:** Security agent + Performance agent + Quality agent review

**Coordinate manually:** Run agents in sequence, share context via handoff docs

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

⚠️ **MANDATORY - Complete Before Marking Task Done**

- [ ] All tests pass (unit + integration + security)
- [ ] Test coverage >80%
- [ ] Security review completed (if triggered)
- [ ] No vulnerabilities (`npm audit` clean)
- [ ] Edge cases tested (null, empty, boundaries)
- [ ] Error handling present (try/catch around externals)
- [ ] No performance issues (N+1 queries, missing indexes)
- [ ] Code readable and maintainable
- [ ] Documentation updated
- [ ] ADR created (if architectural decision)
- [ ] Human review approved

**If ANY item unchecked: Task is NOT complete.**

---

# Remember These Throughout

## NEVER Do These:
- ❌ Skip exploration (always understand codebase first)
- ❌ Skip security review when triggered
- ❌ Skip edge case testing (null, empty, boundaries)
- ❌ Proceed without human approval
- ❌ Hardcode secrets in code
- ❌ Use string concatenation in SQL
- ❌ Trust user input without validation
- ❌ Read entire directories (be surgical)

## ALWAYS Do These:
- ✅ Ask when uncertain (don't hallucinate)
- ✅ Test edge cases explicitly
- ✅ Wrap external calls in try/catch
- ✅ Validate user input
- ✅ Encode output (prevent XSS)
- ✅ Use parameterized SQL queries
- ✅ Pause for human feedback
- ✅ Flag security-sensitive code

---

**This protocol is your core workflow. Detailed checklists in:**
- `checklists/AI_CODE_SECURITY_REVIEW.md` - OWASP Top 10 2025
- `checklists/AI_CODE_REVIEW.md` - Code quality review
- `templates/TEST_STRATEGY.md` - Comprehensive testing guide
- `templates/ADR_TEMPLATE.md` - Architecture decisions
- `guides/CONTEXT_OPTIMIZATION.md` - Advanced context techniques
- `guides/MULTI_AGENT_PATTERNS.md` - Complex coordination

**Reference these at the marked checkpoints. They are MANDATORY, not optional.**

---

*Last Updated: November 2025 | Version: 3.1 | Next Review: Quarterly*
