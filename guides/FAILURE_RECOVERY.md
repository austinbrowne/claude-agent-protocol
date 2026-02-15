# Failure Recovery Framework

**Purpose:** Procedures for handling implementation failures and recovering gracefully
**When to Use:** When Phase 1 implementation encounters critical issues that can't be quickly resolved
**Status:** Core protocol procedure

---

## When to Use This Guide

**You should read this guide when:**
- Phase 1 implementation is failing (tests won't pass, security unfixable, etc.)
- You've spent >30 minutes on an issue with no progress
- Fresh Eyes Review found CRITICAL issues you can't resolve
- Implementation approach is fundamentally flawed
- You're unsure whether to continue, rollback, or abandon

**This guide helps you:**
- Decide whether to continue iterating, rollback and retry, or abandon
- Execute rollback procedures safely
- Preserve useful work before abandoning
- Document learnings for future attempts

---

## Decision Tree: Continue, Rollback, or Abandon?

```
┌─────────────────────────────────────────────────────────┐
│         Implementation Issue Detected                   │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────────┐
         │  Can be fixed in <30 minutes?     │
         └───────────────────────────────────┘
                  │                │
                 YES              NO
                  │                │
                  ▼                ▼
         ┌──────────────┐  ┌─────────────────────────────┐
         │   CONTINUE   │  │ Is approach fundamentally   │
         │  Phase 1     │  │ flawed? (architectural      │
         │  (iterate)   │  │ dead-end, requirements      │
         └──────────────┘  │ conflict, impossible perf)  │
                           └─────────────────────────────┘
                                    │           │
                                   YES         NO
                                    │           │
                                    ▼           ▼
                           ┌─────────────┐  ┌──────────────┐
                           │   ABANDON   │  │   ROLLBACK   │
                           │ + Partial   │  │  & RETRY     │
                           │   Save      │  │  (different  │
                           │ → Phase 0   │  │   approach)  │
                           └─────────────┘  └──────────────┘
```

---

## Path 1: Continue (Minor Issues)

**When to use:**
- Bug can be fixed in <30 minutes
- Clear fix is obvious
- Tests are failing on edge cases (not fundamental logic)
- Minor security issues (missing null check, easy validation)

**Procedure:**
1. Fix the issue
2. Re-run tests
3. Continue to Step 6 (Fresh Eyes Review) or Step 7 (Commit)

**No special actions needed** - this is normal iteration.

---

## Path 2: Rollback & Retry (Wrong Approach, Not Fatal)

**When to use:**
- Implementation approach isn't working but problem is solvable
- Need to try different technical approach
- Spent >30 minutes with no progress on current approach
- Fresh Eyes Review suggests major refactor
- Code is getting too complex/messy (needs fresh start)

**Examples:**
- Tried imperative approach, should use declarative
- Chose wrong library/framework
- Architecture needs restructuring but requirements are clear
- N+1 query problem requires different data model

### Rollback Procedures

#### Option A: Soft Reset (Preserve Changes as Uncommitted)

**Use when:** You want to keep the code to reference while rewriting

```bash
# Show current commits on this branch
git log --oneline

# Soft reset to last good commit (preserves changes as uncommitted)
# Replace COMMIT_HASH with actual commit (e.g., abc1234)
git reset --soft COMMIT_HASH

# Example: Reset to 3 commits ago, keeping all changes
git reset --soft HEAD~3

# Your changes are now uncommitted - review what you had
git diff

# Stash changes for reference
git stash save "First attempt - imperative approach, didn't work"

# Start fresh with new approach
# (can view stash later with: git stash show -p stash@{0})
```

**Result:** Clean working directory, old code preserved in stash for reference

---

#### Option B: Hard Reset (Discard All Changes)

**Use when:** Old code has no value, want completely clean slate

```bash
# ⚠️ WARNING: This is destructive - changes are LOST
# Make sure you're certain before running this

# Show what will be lost
git diff

# Hard reset to specific commit (DISCARDS all changes)
# Replace COMMIT_HASH with actual commit (e.g., abc1234)
git reset --hard COMMIT_HASH

# Examples:
# Reset to 3 commits ago
git reset --hard HEAD~3

# Reset to beginning of branch (main)
git reset --hard origin/main
```

**Safety net:** Git keeps deleted commits in reflog for ~30 days

```bash
# If you regret hard reset, find lost commits
git reflog

# Restore lost commit
git reset --hard [COMMIT_HASH_FROM_REFLOG]
```

---

#### Option C: Stash (Temporary Parking)

**Use when:** Want to try alternative quickly, might come back to current approach

```bash
# Stash all uncommitted changes
git stash save "Attempt 1: Using REST API approach"

# Work on alternative approach
# ... code new approach ...

# If new approach works: Drop stash
git stash drop stash@{0}

# If new approach fails: Restore stash
git stash pop stash@{0}

# List all stashes
git stash list
```

---

### After Rollback: Retry with New Approach

1. **Document what didn't work:**
   ```bash
   # Optional: Create recovery report
   # See templates/RECOVERY_REPORT.md
   ```

2. **Plan alternative approach:**
   - What was wrong with first approach?
   - What will be different this time?
   - Do you need to return to Phase 0 (re-plan)?

3. **Implement alternative:**
   - Start fresh with new approach
   - Avoid repeating same mistakes
   - Consider consulting external resources/docs

4. **Set time budget:**
   - Give new approach maximum 2 hours
   - If still failing after 2 hours → Consider Abandon path

---

## Path 3: Abandon + Partial Save (Fundamental Failure)

**When to use:**
- Approach is fundamentally flawed (can't be fixed with refactor)
- Requirements were misunderstood (need to return to Phase 0)
- Architectural dead-end (wrong abstraction, can't meet performance requirements)
- Spent >4 hours with no viable path forward
- Security requirements can't be met with current approach

**Examples:**
- Requirement: "Real-time sync" but architecture is batch-only
- Performance requirement: <100ms but fundamental approach is O(n²)
- Security requirement can't be met without major system changes
- Third-party API doesn't support required functionality
- Technical constraint discovered (browser limitation, framework limitation)

---

### Partial Save Procedure

**Goal:** Preserve useful artifacts before abandoning (tests, discoveries, partial implementations)

#### Step 1: Identify What's Worth Saving

**Save if:**
- Tests for edge cases (useful for next attempt)
- Research/discoveries (API limits, performance characteristics)
- Partial implementations that work (utility functions, helpers)
- Documentation (what doesn't work, what to avoid)

**Don't save:**
- Broken core logic
- Failed architectural decisions
- Dead-end code paths

---

#### Step 2: Commit Useful Artifacts

```bash
# Stage only the useful parts
git add tests/edge-cases.test.js
git add docs/api-research.md
git add utils/helpers.js

# Commit with special prefix: "discovery:" or "wip:"
git commit -m "$(cat <<'EOF'
discovery: Performance characteristics and edge cases for user-sync feature

What we learned:
- API has 100 req/min rate limit (not documented)
- Batch endpoint supports max 50 items
- Real-time sync not feasible with current API limitations

Artifacts preserved:
- tests/edge-cases.test.js - Edge case tests (reusable)
- docs/api-research.md - API limits documentation
- utils/batch-helpers.js - Batching logic (works correctly)

Why implementation abandoned:
- Real-time sync requirement cannot be met with API constraints
- Need to return to Phase 0 to revise requirements

Next steps:
- Discuss relaxing real-time requirement (near-real-time acceptable?)
- Or explore alternative API/architecture
EOF
)"
```

---

#### Step 3: Create Recovery Report

```bash
# Create recovery report documenting the failure
# See templates/RECOVERY_REPORT.md for template
```

---

#### Step 4: Clean Up and Return to Phase 0

```bash
# Push partial save to remote (preserves learnings)
git push origin issue-4-feature-name

# Update issue with findings (use platform CLI - see ~/.claude/platforms/)
# GitHub: gh issue comment 4 --body "message"
# GitLab: glab issue note 4 --message "message"

# Return to main branch
git checkout main

# Delete local feature branch (preserved on remote)
git branch -D issue-4-feature-name
```

**Result:**
- Useful work preserved in git history
- Learnings documented for next attempt
- Clean state to restart from Phase 0

---

## Recovery Report Template

When abandoning or experiencing significant rollbacks, document the failure:

**See:** `templates/RECOVERY_REPORT.md`

**Quick template:**

```markdown
# Recovery Report: [Feature Name]

**Date:** YYYY-MM-DD
**Issue:** #NNN
**Phase:** Phase 1, Step X
**Recovery Action:** Rollback & Retry | Abandon

## What Went Wrong

[1-2 sentences describing the failure]

## Root Cause

- Technical: [e.g., Wrong algorithm choice, N+1 query problem]
- Architectural: [e.g., Abstraction doesn't fit requirements]
- Requirements: [e.g., Misunderstood requirement, impossible constraint]

## What We Tried

1. [First approach and why it failed]
2. [Second approach and why it failed]
3. [Third approach and why it failed]

## What We Learned

- [Key insight 1]
- [Key insight 2]
- [Technical constraint discovered]

## Artifacts Preserved

- [File/commit with useful work]
- [Tests that are reusable]
- [Documentation created]

## Recommended Next Steps

1. [What to do differently next time]
2. [Whether to revise requirements]
3. [Alternative approaches to explore]

## Time Spent

- Exploration: X hours
- Implementation: X hours
- Total: X hours
```

---

## Recovery Status Indicator

When in recovery mode, use this status:

**`RECOVERY_MODE`**

**Usage:**
```
Status: RECOVERY_MODE
Reason: [Brief description]
Evaluating: Continue | Rollback | Abandon
```

**Example:**
```
Status: RECOVERY_MODE
Reason: Fresh Eyes Review found critical SQL injection issues that require architectural refactor
Evaluating: Rollback & Retry (switch to ORM instead of raw SQL)
```

---

## Common Recovery Scenarios

### Scenario 1: Failed Tests (Edge Cases)

**Situation:** Tests failing on null/empty/boundary cases

**Decision:** **Continue** (Path 1)
- Fix edge case handling
- Add null checks, validation
- Continue Phase 1

---

### Scenario 2: Security Issues from Fresh Eyes Review

**Situation:** Fresh Eyes Review found CRITICAL security issues

**Decision path:**
- **Can fix in <30 min?** → **Continue** (add input validation, fix SQL injection)
- **Requires refactor** (e.g., entire auth approach wrong)? → **Rollback & Retry** (Path 2)
- **Fundamental architectural issue?** → **Abandon** (Path 3)

---

### Scenario 3: Performance Failure

**Situation:** Code works but is 10x too slow

**Decision path:**
- **Minor optimization needed?** → **Continue** (add index, use join instead of N+1)
- **Algorithm needs changing?** → **Rollback & Retry** (use different data structure)
- **Requirement impossible with architecture?** → **Abandon** (return to Phase 0)

---

### Scenario 4: Architectural Mismatch

**Situation:** Halfway through implementation, realized abstraction doesn't fit

**Decision:** **Rollback & Retry** (Path 2)
- Soft reset to beginning of branch
- Stash current code for reference
- Redesign abstraction
- Re-implement with better architecture

**Git commands:**
```bash
git stash save "First attempt - wrong abstraction"
git reset --soft [FIRST_COMMIT_ON_BRANCH]
# Re-implement with new architecture
```

---

### Scenario 5: Requirements Conflict

**Situation:** Discovered requirement A conflicts with requirement B

**Decision:** **Abandon** (Path 3)
- Document the conflict
- Create recovery report
- Return to Phase 0 to resolve requirements with stakeholder

---

## Best Practices

### ✅ Do:
- **Decide quickly** - Don't waste time on dead ends
- **Preserve learnings** - Document what didn't work
- **Use git liberally** - Commit checkpoints as you go
- **Ask for help** - Consult docs, Stack Overflow, colleagues
- **Time-box attempts** - Give each approach maximum 2 hours

### ❌ Don't:
- **Keep iterating indefinitely** - Know when to cut losses
- **Hard reset without backup** - Use stash or check reflog first
- **Abandon without preserving learnings** - Future you will thank you
- **Skip recovery report** - Document failures for Learning Loop
- **Blame yourself** - Failures are learning opportunities

---

## Integration with GODMODE

**This guide is referenced at:**
- **Phase 1, Step 6.5** (new checkpoint after Fresh Eyes Review)

**Workflow:**
1. Fresh Eyes Review completes
2. If CRITICAL/HIGH issues found that can't be quickly fixed:
   - Read this guide
   - Use decision tree
   - Execute appropriate recovery path
3. Update status (`RECOVERY_MODE`)
4. Execute recovery procedure
5. Report outcome to user

---

## Safety Notes

### Git Reflog (Your Safety Net)

Git keeps deleted commits for ~30 days in reflog:

```bash
# View reflog (shows ALL operations)
git reflog

# Find lost commit
git reflog | grep "commit message"

# Restore lost work
git reset --hard [COMMIT_HASH_FROM_REFLOG]
```

**This means hard resets are (mostly) reversible if you act quickly.**

---

### Destructive Commands

**These commands lose uncommitted changes:**
- `git reset --hard` - Discards all uncommitted changes
- `git checkout -- <file>` - Discards changes to specific file
- `git clean -fd` - Deletes untracked files

**Always run `git diff` first to see what will be lost**

---

---

## Detailed Recovery Scenario Templates

### Template 1: Failed Tests (Edge Cases)

**Scenario:** Tests failing on null/empty/boundary inputs

**Classification:** Technical failure (code quality)

**Decision:** **Continue** (Path 1) - if fixable in <30 min

**Git Commands:**
```bash
# No rollback needed - just fix the issues

# Check which tests are failing
npm test  # or pytest, or cargo test, etc.

# Fix edge case handling in code
# (add null checks, validation, boundary handling)

# Re-run tests
npm test

# Once passing, continue to Fresh Eyes Review
```

**Decision Rationale:**
- Edge case bugs are normal and expected
- Fixes are typically quick (add validation, null checks)
- No fundamental architectural issues

**Next Steps:**
1. Add null checks / input validation
2. Update tests to cover new edge cases
3. Re-run test suite
4. Continue to Step 6 (Fresh Eyes Review)

---

### Template 2: Security Issues (Critical Vulnerabilities)

**Scenario:** Fresh Eyes Review found CRITICAL security issues (SQL injection, XSS, missing auth)

**Classification:** Security failure

**Decision:** Depends on severity and fix complexity

**Case A: Simple Security Fix (<30 min)**

**Decision:** **Continue** (Path 1)

```bash
# No rollback needed

# Fix the security issues:
# - Add parameterized queries instead of string concatenation
# - Add input validation/sanitization
# - Add authentication checks

# Re-run Fresh Eyes Review
# (repeat Step 6 with fresh security review)

# Once approved, continue to Step 7
```

**Case B: Architectural Security Flaw (requires refactor)**

**Decision:** **Rollback & Retry** (Path 2)

```bash
# Stash current implementation for reference
git stash save "First attempt - insecure raw SQL, switching to ORM"

# Reset to beginning of branch
# Replace FIRST_COMMIT with the first commit hash on your branch
git reset --soft FIRST_COMMIT

# Re-implement using secure approach:
# - Use ORM with parameterized queries
# - Use security library for auth
# - Follow secure architecture patterns

# Once reimplemented, run Fresh Eyes Review again
```

**Decision Rationale:**
- Security cannot be compromised
- Quick fixes acceptable if fundamentally secure
- Architectural security flaws require rewrite

**Next Steps:**
1. Evaluate if security flaw is quick-fixable or architectural
2. If quick: Fix and re-review
3. If architectural: Rollback & retry with secure architecture
4. Never proceed with unfixed CRITICAL security issues

---

### Template 3: Architectural Mismatch

**Scenario:** Halfway through implementation, realized abstraction doesn't fit requirements

**Classification:** Architectural failure

**Decision:** **Rollback & Retry** (Path 2)

**Git Commands:**
```bash
# Save current attempt for reference
git stash save "Attempt 1 - tried Factory pattern, doesn't fit"

# Soft reset to beginning of branch (preserves changes)
# Replace FIRST_COMMIT with the first commit hash on your branch
git reset --soft FIRST_COMMIT

# Review what we had
git stash show -p stash@{0}

# Re-architect with better abstraction
# (Strategy pattern instead of Factory, or Service layer instead of direct DB access, etc.)

# Implement new architecture
# ... code ...

# Tests pass with new architecture
npm test

# Continue to Fresh Eyes Review
```

**Decision Rationale:**
- Wrong abstraction = ongoing pain, not quick fix
- Better to restart with correct architecture than accumulate technical debt
- ~60-70% of code may be reusable (data models, tests)

**Next Steps:**
1. Identify what abstraction would work better
2. Soft reset to preserve work for reference
3. Re-implement with correct architecture
4. Reuse test cases and data models where applicable

---

### Template 4: Performance Failure

**Scenario:** Implementation works but is 10x too slow (requirement: <200ms, actual: 2000ms)

**Classification:** Performance failure

**Decision:** Depends on root cause

**Case A: Simple Optimization (<30 min)**

**Decision:** **Continue** (Path 1)

```bash
# No rollback needed

# Add database index
# Example (SQL):
CREATE INDEX idx_user_email ON users(email);

# Or fix N+1 query with join
# Before: Loop calling DB
# After: Single query with JOIN

# Run performance test
npm run bench

# If now meets requirement (<200ms), continue
```

**Case B: Algorithm Needs Changing**

**Decision:** **Rollback & Retry** (Path 2)

```bash
# Current algorithm: O(n²) nested loops
# Need: O(n log n) with sorting + binary search

# Stash current implementation
git stash save "Attempt 1 - O(n²) algorithm, too slow"

# Reset to beginning
git reset --soft [FIRST_COMMIT]

# Implement with better algorithm
# ... use hash map, or sorting + binary search, or caching ...

# Benchmark
npm run bench

# If meets requirement, continue
```

**Case C: Requirement Impossible with Current Architecture**

**Decision:** **Abandon** (Path 3)

```bash
# Example: Need <100ms but architecture requires 3 sequential API calls (min 300ms)

# Partial save: Preserve tests and research
git add tests/performance.test.js
git add docs/performance-research.md

git commit -m "$(cat <<'EOF'
discovery: Performance requirement infeasible with current architecture

Requirement: <100ms response time
Reality: 3 sequential API calls = 300ms minimum (network latency)

Approaches tried:
1. Caching: Reduces to 250ms (still not enough)
2. Parallel calls: Not possible (call 2 depends on call 1 result)
3. Different API: No alternative API exists

Conclusion: Need to relax requirement to <500ms or redesign system architecture

Next steps: Return to Phase 0, discuss with stakeholder
EOF
)"

# Return to Phase 0
git checkout main
```

**Decision Rationale:**
- Simple optimizations (index, fix N+1): Continue
- Algorithm change: Rollback & retry
- Impossible requirement: Abandon, revise requirements

**Next Steps:**
1. Profile to identify bottleneck
2. Determine if fixable with optimization, algorithm change, or impossible
3. Execute appropriate recovery path

---

### Template 5: Requirements Conflict

**Scenario:** Discovered Requirement A conflicts with Requirement B during implementation

**Classification:** Requirements failure

**Decision:** **Abandon** (Path 3)

**Example:**
- Requirement A: "Real-time sync (updates in <1 second)"
- Requirement B: "Use third-party API X"
- Conflict: API X has 100 requests/min rate limit = max 1 update per 600ms for 100 users

**Git Commands:**
```bash
# Partial save: Preserve API research and rate limit findings
git add docs/api-rate-limits.md
git add tests/api-integration.test.js

git commit -m "$(cat <<'EOF'
discovery: Requirements conflict - real-time sync incompatible with API rate limits

Requirement A: Real-time sync (<1s updates)
Requirement B: Use third-party API X
Conflict: API X rate limit = 100 req/min = insufficient for real-time with >100 users

Findings:
- API X: 100 requests/minute hard limit
- Real-time sync for 500 users = 500 requests/minute needed
- No alternative real-time API available

Options:
1. Relax "real-time" to "near-real-time" (5-minute polling acceptable?)
2. Switch to different API (requires vendor change approval)
3. Build custom sync infrastructure (months of work)

Recommendation: Option 1 - Discuss with stakeholder about 5-min polling

Next steps: Return to Phase 0 for requirements clarification
EOF
)"

# Create recovery report
# (use templates/RECOVERY_REPORT.md)

# Return to Phase 0
git checkout main
```

**Decision Rationale:**
- Requirements conflicts cannot be solved with code
- Need stakeholder decision on which requirement to relax
- Preserve research so next attempt doesn't repeat discovery

**Next Steps:**
1. Document the conflict clearly
2. Provide options with pros/cons
3. Recommend preferred option
4. Return to Phase 0 for stakeholder decision

---

## Example Walkthrough: Decision Tree in Action

### Walkthrough 1: Edge Case Failure → Continue

**Situation:**
```
Phase 1, Step 5: Tests failing
Error: "Cannot read property 'name' of undefined"
Test: user-service.test.js line 45
```

**Decision Process:**
```
Q: Can be fixed in <30 minutes?
A: YES - just need to add null check

Decision: CONTINUE (Path 1)
```

**Actions:**
```javascript
// Before:
function getUserName(user) {
  return user.name;
}

// After (fixed):
function getUserName(user) {
  if (!user) {
    throw new Error('User is required');
  }
  return user.name;
}
```

**Result:** Tests pass, continue to Step 6 (Fresh Eyes Review)

---

### Walkthrough 2: Architectural Flaw → Rollback & Retry

**Situation:**
```
Phase 1, Step 4: Implementation 60% complete
Realization: Using Factory pattern, but Strategy pattern is better fit
Code is getting messy, lots of conditional logic
```

**Decision Process:**
```
Q: Can be fixed in <30 minutes?
A: NO - requires architectural refactor

Q: Is approach fundamentally flawed?
A: NO - Strategy pattern will work, just wrong pattern chosen

Decision: ROLLBACK & RETRY (Path 2)
```

**Actions:**
```bash
# Stash current work
git stash save "Factory pattern attempt - switching to Strategy"

# Soft reset to beginning
git reset --soft HEAD~10

# Review old code for reference
git stash show -p

# Re-implement with Strategy pattern
# ... 3 hours later ...

# Tests pass with cleaner architecture
npm test  # ✓ All tests passing

# Continue to Fresh Eyes Review
```

**Result:** Cleaner architecture, 3 hours to reimplement, worth it vs accumulating technical debt

---

### Walkthrough 3: API Limitation → Abandon

**Situation:**
```
Phase 1, Step 3: Implementation 40% complete
Discovery: Third-party API has 100 req/min rate limit (wasn't in docs)
Requirement: Real-time sync for 500 users = 500 req/min needed
Math: Impossible with this API
```

**Decision Process:**
```
Q: Can be fixed in <30 minutes?
A: NO - this is a fundamental limitation

Q: Is approach fundamentally flawed?
A: YES - API cannot meet requirement

Decision: ABANDON (Path 3)
```

**Actions:**
```bash
# Partial save: Keep API research
git add docs/api-rate-limit-findings.md
git add tests/api-test.js

git commit -m "discovery: API rate limit prevents real-time sync (100 req/min insufficient)"

# Create recovery report
# Document: What we learned, options, recommendation

# Update issue (use platform CLI - see ~/.claude/platforms/)
# GitHub: gh issue comment 45 --body "message"
# GitLab: glab issue note 45 --message "message"

# Return to main
git checkout main
```

**Result:** Saved 10+ hours by abandoning early, stakeholder approves 5-minute polling, restart with realistic requirements

---

## Failure Type Classification Guide

Use this guide to quickly classify failures and choose appropriate recovery path.

### Technical Failures
**Characteristics:**
- Bug in implementation
- Edge cases not handled
- Algorithm wrong/inefficient
- Code quality issues

**Typical Recovery:** Continue (fix bugs) or Rollback & Retry (different approach)

**Examples:**
- Null pointer errors
- Off-by-one errors
- N+1 query problems
- Memory leaks

---

### Architectural Failures
**Characteristics:**
- Wrong abstraction/pattern
- Code getting messy/complex
- Design doesn't scale
- Coupling too tight

**Typical Recovery:** Rollback & Retry

**Examples:**
- Wrong design pattern (Factory vs Strategy)
- Missing layer of abstraction
- God object emerging
- Tight coupling between modules

---

### Requirements Failures
**Characteristics:**
- Requirements conflict
- Requirement impossible
- Requirement misunderstood
- Missing requirement discovered

**Typical Recovery:** Abandon (return to Phase 0)

**Examples:**
- "Real-time" conflicts with "batch processing"
- Performance requirement impossible with architecture
- Security requirement conflicts with usability
- Discovered hidden requirement mid-implementation

---

### Performance Failures
**Characteristics:**
- Too slow
- Too much memory
- Bundle too large
- Query too expensive

**Typical Recovery:** Depends on cause (Continue for simple optimization, Rollback for algorithm change, Abandon if impossible)

**Examples:**
- O(n²) algorithm when O(n log n) needed
- Missing database index
- Loading entire dataset instead of paginating
- Heavy library bloating bundle

---

### Security Failures
**Characteristics:**
- Vulnerability found
- Auth/authz missing
- Input validation missing
- Data exposure

**Typical Recovery:** Continue (quick fixes) or Rollback & Retry (architectural security flaw)

**Examples:**
- SQL injection (parameterize queries → Continue)
- XSS (sanitize input → Continue)
- No authentication on endpoint (add middleware → Continue)
- Entire auth approach insecure (rewrite → Rollback & Retry)

---

### External Failures
**Characteristics:**
- Third-party limitation
- API doesn't support feature
- Browser/framework constraint
- Dependency issue

**Typical Recovery:** Abandon (if fundamental) or Rollback & Retry (if workaround exists)

**Examples:**
- API rate limit too restrictive
- Browser doesn't support required feature
- Library doesn't support use case
- Dependency has breaking bug

---

## Related Documentation

- **GODMODE Protocol:** `AI_CODING_AGENT_GODMODE.md` (Phase 1 workflow)
- **Recovery Report Template:** `templates/RECOVERY_REPORT.md`
- **Learning Loop:** (PRD #6 - tracks failure patterns for protocol improvement)
- **Complexity & Time Budgets:** (PRD #5 - helps detect when to trigger recovery)

---

**Last Updated:** December 2025
**Status:** Core protocol procedure
**Version:** 1.0
