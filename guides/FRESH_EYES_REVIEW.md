# Fresh Eyes Code Review

**Status:** MANDATORY for ALL code changes
**Purpose:** Unbiased code review using specialized agents with zero conversation context
**When:** Phase 1, Step 6 - After implementation and testing, before commit

---

## ⚠️ CRITICAL: This Step is MANDATORY

🚫 **CHECKPOINT: You CANNOT proceed to commit/PR without completing this review.**

**Why this matters:**
- Eliminates confirmation bias (review agents don't know your implementation reasoning)
- Catches security vulnerabilities (45% of AI code has security issues)
- Validates edge case handling (null, empty, boundaries)
- Prevents bugs from reaching production

**If you find yourself skipping this step:**
- STOP immediately
- Ask yourself: Why am I skipping mandatory review?
- This is a protocol violation

---

## Review Tier Selection

Choose the appropriate review tier based on change size:

### Lite Review (Small Changes: <4 hours, <100 LOC)

**When to use:**
- Bug fixes
- Small refactors
- Documentation updates
- Minor feature additions

**Process:**
- Single agent: Code Quality Review only
- Time: 5-10 minutes
- No supervisor needed (direct to main context)

**Example:** Fixing a null check, updating validation logic, refactoring a function

---

### Standard Review (Medium Changes: 4-15 hours, 100-500 LOC)

**When to use:**
- New features
- API endpoint additions
- Database schema changes
- Authentication/authorization changes

**Process:**
- Two agents: Security + Code Quality
- Supervisor consolidates findings
- Time: 10-15 minutes

**Example:** Adding user profile editing, implementing password reset, creating new API routes

---

### Full Review (Large Changes: >15 hours, >500 LOC)

**When to use:**
- Major features
- Architectural changes
- Payment/financial logic
- Multi-system integrations

**Process:**
- Three+ agents: Security + Code Quality + Performance (+ Accessibility if UI)
- Supervisor consolidates findings
- Time: 15-20 minutes

**Example:** Implementing payment processing, major refactor, new subsystem

---

## Review Workflow

### Step 1: Get Staged Changes

```bash
# Get diff of all changes to review
git diff --staged > /tmp/review-diff.txt

# Or if not yet staged
git diff > /tmp/review-diff.txt
```

---

### Step 2: Launch Review Agents

Use the Task tool with `subagent_type: "general-purpose"` for each review agent.

**CRITICAL:** Review agents have ZERO conversation history. They only see:
- ✅ The code diff file
- ✅ The checklist file
- ✅ The prompt you give them
- ❌ NOT your conversation history
- ❌ NOT the PRD context
- ❌ NOT your implementation reasoning

This ensures truly **fresh eyes** on the code.

---

#### Agent 1: Security Review Agent (Standard & Full Reviews)

**Input:**
- File: `/tmp/review-diff.txt` (the code diff)
- Checklist: `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md`

**Prompt:**
```
You are a security review specialist with NO knowledge of why this code was written.

Review this code diff for OWASP Top 10 2025 security violations.

Read the security checklist at ~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md

Check for:
- SQL injection
- XSS vulnerabilities
- Authentication/authorization issues
- Input validation
- Hardcoded secrets
- Insecure dependencies

Return findings in this format:

SECURITY REVIEW FINDINGS:

CRITICAL:
- [Finding with file:line reference]

HIGH:
- [Finding with file:line reference]

MEDIUM:
- [Finding with file:line reference]

LOW:
- [Finding with file:line reference]

PASSED:
- [List of checks that passed]

Total issues: N
Recommendation: BLOCK | FIX_BEFORE_COMMIT | APPROVED
```

---

#### Agent 2: Code Quality Review Agent (ALL Reviews)

**Input:**
- File: `/tmp/review-diff.txt` (the code diff)
- Checklist: `~/.claude/checklists/AI_CODE_REVIEW.md`

**Prompt:**
```
You are a code quality review specialist with NO knowledge of why this code was written.

Review this code diff for code quality issues.

Read the code review checklist at ~/.claude/checklists/AI_CODE_REVIEW.md

Check for:
- Edge cases (null, empty, boundaries)
- Error handling (try/catch around external calls)
- Code clarity and maintainability
- Performance concerns (N+1 queries, missing indexes)
- Design patterns and architecture (SOLID, anti-patterns, separation of concerns)
- Test coverage

Return findings in this format:

CODE QUALITY REVIEW FINDINGS:

CRITICAL:
- [Finding with file:line reference]

HIGH:
- [Finding with file:line reference]

MEDIUM:
- [Finding with file:line reference]

LOW:
- [Finding with file:line reference]

PASSED:
- [List of checks that passed]

Total issues: N
Recommendation: BLOCK | FIX_BEFORE_COMMIT | APPROVED
```

---

#### Agent 3: Performance Review Agent (Full Reviews Only)

**Input:**
- File: `/tmp/review-diff.txt` (the code diff)

**Prompt:**
```
You are a performance review specialist with NO knowledge of why this code was written.

Review this code diff for performance issues.

Check for:
- N+1 query problems
- Missing database indexes
- Inefficient algorithms (O(n²) when O(n log n) possible)
- Unnecessary data loading (load full dataset vs pagination)
- Bundle size concerns (large dependencies)
- Memory leaks

Return findings in this format:

PERFORMANCE REVIEW FINDINGS:

CRITICAL:
- [Finding with file:line reference]

HIGH:
- [Finding with file:line reference]

MEDIUM:
- [Finding with file:line reference]

LOW:
- [Finding with file:line reference]

PASSED:
- [List of checks that passed]

Total issues: N
Recommendation: BLOCK | FIX_BEFORE_COMMIT | APPROVED
```

---

### Step 3: Launch Supervisor Agent (Standard & Full Reviews)

**Skip for Lite Reviews** - Proceed directly with Code Quality findings.

**For Standard/Full Reviews**, once all review agents return their findings:

**Agent: Review Supervisor**

**Input:**
- Security review findings (if applicable)
- Code quality review findings
- Performance review findings (if applicable)
- Original diff file: `/tmp/review-diff.txt`

**Prompt:**
```
You are a senior technical reviewer and supervisor.

You have received findings from specialized review agents:

SECURITY REVIEW FINDINGS:
[Paste security agent findings]

CODE QUALITY REVIEW FINDINGS:
[Paste code quality agent findings]

PERFORMANCE REVIEW FINDINGS:
[Paste performance agent findings if applicable]

Your job is to:
1. Validate each finding against the code diff
2. Remove false positives (findings that don't apply)
3. Consolidate duplicate findings
4. Prioritize by severity AND impact
5. Create single coherent action plan

Return a consolidated report in this format:

CONSOLIDATED CODE REVIEW REPORT:

MUST FIX (CRITICAL/HIGH - blocking):
1. [Issue description with file:line]
   - Severity: CRITICAL | HIGH
   - Impact: [Why this matters]
   - Fix: [Specific action to take]

SHOULD FIX (MEDIUM - recommended):
1. [Issue description with file:line]
   - Severity: MEDIUM
   - Impact: [Why this matters]
   - Fix: [Specific action to take]

CONSIDER (LOW - optional):
1. [Issue description with file:line]
   - Severity: LOW
   - Impact: [Why this matters]
   - Fix: [Specific action to take]

PASSED CHECKS:
- [List of all checks that passed]

FALSE POSITIVES REMOVED:
- [Any findings that were invalid]

OVERALL VERDICT: BLOCK | FIX_CRITICAL_HIGH | APPROVED

ACTION PLAN:
1. [First priority fix]
2. [Second priority fix]
...

CONFIDENCE: HIGH | MEDIUM | LOW
```

---

### Step 4: Present Final Report to Main Context

Main agent receives the consolidated report (or direct Code Quality findings for Lite reviews) and:

**1. Show report to user:**

```
Fresh Eyes Code Review Complete:

[Display consolidated report or direct findings]

Found N CRITICAL/HIGH issues that MUST be fixed before commit.
Found M MEDIUM issues recommended to fix.
Found P LOW issues to consider.
```

**2. Implement CRITICAL/HIGH fixes immediately:**
- Address each MUST FIX item
- Make code changes
- Re-stage changes

**3. Discuss MEDIUM/LOW with user:**

```
MEDIUM priority items:
1. [Issue 1] - Fix now? (yes/no)
2. [Issue 2] - Fix now? (yes/no)

LOW priority items logged for future consideration.
```

**4. Re-run review if significant changes made:**
- If fixed >3 critical issues, re-run entire review
- If only 1-2 minor fixes, proceed

---

### Step 5: Checkpoint Verification

🚫 **MANDATORY CHECKPOINT - Cannot proceed without ALL boxes checked:**

- [ ] Fresh Eyes Review completed for this change
- [ ] All CRITICAL findings addressed
- [ ] All HIGH findings addressed or documented why skipped
- [ ] Review findings logged to `~/.claude/review-data/review-findings.jsonl` (if Learning Loop implemented)

**You CANNOT proceed to Step 7 (Commit) without completing this checkpoint.**

---

## Example Workflow

```
Main Agent (Phase 1, Step 6):

1. Determine review tier: Medium change (6 hours, 250 LOC) → Standard Review

2. Get staged changes:
   git diff --staged > /tmp/review-diff.txt

3. Launch Security Agent (Task tool):
   → Reviews diff against OWASP checklist
   → Returns: 1 CRITICAL (hardcoded API key), 2 HIGH issues

4. Launch Code Quality Agent (Task tool):
   → Reviews diff against code quality checklist
   → Returns: 1 HIGH (missing null check), 3 MEDIUM issues

5. Launch Supervisor Agent (Task tool):
   → Receives both reports
   → Validates findings
   → Removes 1 false positive
   → Consolidates duplicate finding
   → Returns: MUST FIX: 3 items, SHOULD FIX: 2 items

6. Main Agent presents to user:
   "Code review found 3 critical issues that must be fixed:
    1. Hardcoded API key in config.ts:45
    2. SQL injection risk in users.ts:123
    3. Missing null check in auth.ts:67"

7. Main Agent fixes all 3 critical issues

8. Main Agent re-runs review:
   → All critical issues resolved
   → Verdict: APPROVED

9. ✅ Checkpoint verified, proceed to Step 7
```

---

## Why Fresh Eyes Review Works

**Eliminates Confirmation Bias:**
- Review agents have zero conversation context
- They don't know your implementation reasoning
- They don't know what you were trying to accomplish
- They only see: code diff + checklist

**Catches What You Miss:**
- Edge cases (null, empty, boundaries)
- Security vulnerabilities (you forgot input validation)
- Performance issues (N+1 queries you didn't notice)
- Error handling gaps (no try/catch)

**Validated by Supervisor:**
- Filters false positives
- Consolidates duplicates
- Prioritizes by severity and impact
- Single actionable plan

---

## Cost Optimization

**Lite Review:**
- ~$0.05-0.10 per review
- Single agent with minimal context

**Standard Review:**
- ~$0.10-0.20 per review
- Two agents + supervisor

**Full Review:**
- ~$0.20-0.30 per review
- Three+ agents + supervisor

**ROI:** Prevents costly production bugs, security vulnerabilities, and technical debt.

---

## Common Pitfalls

### ❌ Skipping Review for "Small" Changes

**Problem:** "It's just a one-line change, I don't need review"

**Reality:** One-line changes can introduce critical bugs:
- Missing null check → production crash
- Hardcoded credential → security breach
- Off-by-one error → data corruption

**Solution:** Use Lite Review (5-10 min) for small changes.

---

### ❌ Ignoring MEDIUM/LOW Findings

**Problem:** "Only fixed CRITICAL, ignored rest"

**Reality:** MEDIUM issues compound into technical debt. LOW issues flag patterns.

**Solution:** Fix MEDIUM if time permits. Log LOW for future reference.

---

### ❌ Not Re-Running After Major Fixes

**Problem:** Fixed 5 critical issues, didn't re-review

**Reality:** Your fixes may have introduced new issues

**Solution:** Re-run review if >3 issues fixed or if fixes touch multiple areas

---

## Integration with Learning Loop

If PRD #6 (Learning Loop & Metrics) is implemented:

**After Fresh Eyes Review completes**, log findings to `~/.claude/review-data/review-findings.jsonl`:

```jsonl
{"date":"2025-11-30","project":"my-app","issue":"#45","review_tier":"standard","findings":[{"severity":"CRITICAL","type":"hardcoded-secret","file":"config.ts:45","agent":"security"},{"severity":"HIGH","type":"null-check-missing","file":"auth.ts:67","agent":"code-quality"}],"false_positives":[],"time_minutes":12}
```

This enables continuous protocol improvement from real-world review data.

---

## Troubleshooting

### Review Agent Returns Empty Findings

**Cause:** No diff to review (nothing staged)

**Fix:** Ensure you have staged changes: `git diff --staged` should show output

---

### Supervisor Marks Everything as False Positive

**Cause:** Review agents misunderstood context or checklist too strict

**Fix:** Review supervisor reasoning. If legitimate, update checklist to clarify.

---

### Review Takes Too Long (>20 min)

**Cause:** Too many changes in one review

**Fix:** Break into smaller commits. Review incrementally (per feature, not entire phase).

---

**Last Updated:** November 2025
**See Also:**
- `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` - Security checklist
- `~/.claude/checklists/AI_CODE_REVIEW.md` - Code quality checklist
- `~/.claude/guides/MULTI_AGENT_PATTERNS.md` - Other multi-agent patterns (optional tactical patterns)
