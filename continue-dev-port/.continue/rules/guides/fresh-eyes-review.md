---
name: Fresh Eyes Code Review
description: Unbiased code review process using specialized review perspectives with zero conversation context. Mandatory for all code changes before commit.
alwaysApply: false
---

# Fresh Eyes Code Review

**Status:** MANDATORY for ALL code changes
**Purpose:** Unbiased code review using specialized review perspectives with zero conversation context
**When:** After implementation and testing, before commit

---

## CRITICAL: This Step is MANDATORY

**CHECKPOINT: You CANNOT proceed to commit/PR without completing this review.**

**Why this matters:**
- Eliminates confirmation bias (review doesn't know your implementation reasoning)
- Catches security vulnerabilities (45% of AI code has security issues)
- Validates edge case handling (null, empty, boundaries)
- Prevents bugs from reaching production
- Adversarial validation challenges claims with evidence, not assertions

---

## Review Perspectives

### Core Reviews (Always Run)

| # | Perspective | Focus |
|---|------------|-------|
| 1 | Security Review | OWASP Top 10, injection, auth, secrets, input validation |
| 2 | Code Quality Review | Naming, structure, complexity, SOLID, error handling |
| 3 | Edge Case Review | Null/empty/boundary/unicode/off-by-one (dedicated — biggest AI blind spot) |
| 4 | Supervisor Consolidation | Validate findings, remove false positives, deduplicate, prioritize |
| 5 | Adversarial Validation | Falsification over confirmation. Challenges claims AND findings. |

### Conditional Reviews (Triggered by Diff Analysis)

| # | Perspective | Trigger Patterns |
|---|------------|-----------------|
| 6 | Performance Review | DB/ORM patterns, nested loops, LOC > 200, model/service/api file paths |
| 7 | API Contract Review | Route/endpoint definitions, controller/handler paths, API schema files |
| 8 | Concurrency Review | Promise.all/race/allSettled, Lock/Mutex/Semaphore, goroutine/channel, Thread/spawn/actor |
| 9 | Error Handling Review | External HTTP/fs calls, try/catch patterns, LOC > 300 |
| 10 | Dependency Review | Modified dependency files, >3 new imports |
| 11 | Testing Adequacy Review | Test files changed, OR implementation without tests, >50 LOC non-test |
| 12 | Documentation Review | Public API changes, magic numbers, LOC > 300, README/docs changes |

---

## Review Process

### Step 1: Generate Diff

```bash
mkdir -p .review
git diff --staged -U5 > .review/review-diff.txt
git diff --staged --name-only > .review/review-files.txt
```

### Step 2: Trigger Detection

For each conditional review perspective, scan the diff content AND file list for trigger patterns. Only include reviews that match.

### Step 3: LOC Gate & Mode

Calculate LOC added (non-test files only):

```bash
git diff --staged --numstat | grep -v -E 'test|spec|__tests__' | awk '{ sum += $1 } END { print sum }'
```

| Condition | Mode |
|-----------|------|
| LOC_added <= 50 AND no security-sensitive patterns | **Lite** (Core reviews only) |
| LOC_added <= 50 AND security-sensitive patterns detected | **Full** |
| LOC_added > 50 | **Full** (Core + triggered conditional reviews) |

### Step 4: Execute Reviews Sequentially

For each review perspective in the roster:

1. **Start fresh** — approach the diff with zero knowledge of implementation reasoning
2. **Read the diff** from `.review/review-diff.txt`
3. **Apply the perspective's checklist** rigorously
4. **Document findings** with severity (CRITICAL/HIGH/MEDIUM/LOW)
5. **Move to next perspective**

After all specialist reviews:
6. **Supervisor pass:** Consolidate findings, remove false positives, deduplicate, prioritize
7. **Adversarial pass:** Challenge claims and findings, verify against actual code

---

## Verdict Determination

| Verdict | Condition | Action |
|---------|-----------|--------|
| **BLOCK** | 1+ CRITICAL issues OR disproved claims | Fix immediately, re-run review |
| **FIX_BEFORE_COMMIT** | 1+ HIGH issues | Fix issues, re-run review |
| **APPROVED_WITH_NOTES** | MEDIUM/LOW only | Proceed, address notes later |
| **APPROVED** | No issues | Proceed to commit |

### Post-Verdict: Persist Results

After determining the verdict:
1. Write verdict to `.todos/review-verdict.md`
2. Write full report to `.todos/review-report.md` — includes findings with severity and recommendations

---

## Lite Review

For quick reviews of small changes, run only:
- Security Review
- Code Quality Review
- Edge Case Review
- Supervisor Consolidation

Skip: Adversarial Validation, all conditional reviews.

---

## Why Fresh Eyes Review Works

**Eliminates Confirmation Bias:**
- Review perspectives have zero conversation context
- They don't know your implementation reasoning
- They only see: code diff + checklist

**Catches What You Miss:**
- Edge cases (null, empty, boundaries) — dedicated review
- Security vulnerabilities (you forgot input validation)
- Performance issues (N+1 queries you didn't notice)
- Adversarial validation challenges your assumptions

---

## Common Pitfalls

### Skipping Review for "Small" Changes

One-line changes can introduce critical bugs: missing null check -> production crash, hardcoded credential -> security breach, off-by-one -> data corruption.

**Solution:** Use Lite Review for small changes.

### Ignoring MEDIUM/LOW Findings

MEDIUM issues compound into technical debt. LOW issues flag patterns.

**Solution:** Track as todos, address in next iteration.

### Not Re-Running After Major Fixes

Fixes may introduce new issues.

**Solution:** Re-run review if >3 issues fixed or if fixes touch multiple areas.
