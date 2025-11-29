# AI Coding Agent Standard Operating Protocol (SOP)

**Version:** 3.1
**Last Updated:** November 2025
**Purpose:** Safe, effective AI-assisted software development

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

## Phase 0: Exploration & Planning

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

**Use thinking triggers:**
- `"think"` - Moderate complexity
- `"think hard"` - Multi-step problems, security architecture
- `"ultrathink"` - Critical decisions, major refactors

### Step 3: Generate PRD

**Use:** `PRD_TEMPLATE.md`

**Lite PRD (small tasks):** Problem + Solution + Tests + Security check
**Full PRD (complex):** All sections

**MUST include:**
- Test strategy (specific test cases, not just "write tests")
- Security review section (is this security-sensitive?)

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

## Phase 1: Execution Loop

### Step 1: Restate & Checkpoint

- Restate phase goals
- Ensure git checkpoint exists (can rollback if needed)

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

### Step 6: Code Review Focus

⚠️ **STOP: Review Your Own Code**

**READ:** `checklists/AI_CODE_REVIEW.md` for full checklist.

**Quick self-review (MANDATORY):**
1. **Edge cases:** Did I test null, empty, boundaries?
2. **Error handling:** Try/catch around external calls?
3. **Security:** Input validated? Output encoded? No secrets in code?
4. **Performance:** Any N+1 queries? Missing indexes?
5. **Readability:** Can a human understand this in 6 months?

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
