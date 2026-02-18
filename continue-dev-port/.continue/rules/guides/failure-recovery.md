---
name: Failure Recovery
description: Procedures for handling implementation failures and recovering gracefully. Use when implementation encounters critical issues, tests won't pass, or the approach is fundamentally flawed.
alwaysApply: false
---

# Failure Recovery Framework

**Purpose:** Procedures for handling implementation failures and recovering gracefully
**When to Use:** When implementation encounters critical issues that can't be quickly resolved

---

## When to Use This Guide

- Implementation is failing (tests won't pass, security unfixable, etc.)
- You've spent >30 minutes on an issue with no progress
- Code review found CRITICAL issues you can't resolve
- Implementation approach is fundamentally flawed
- You're unsure whether to continue, rollback, or abandon

---

## Decision Tree: Continue, Rollback, or Abandon?

```
Implementation Issue Detected
            |
            v
  Can be fixed in <30 minutes?
       |              |
      YES             NO
       |              |
       v              v
   CONTINUE    Is approach fundamentally
   (iterate)   flawed? (architectural dead-end,
               requirements conflict, impossible perf)
                    |           |
                   YES         NO
                    |           |
                    v           v
                ABANDON     ROLLBACK
               + Partial    & RETRY
                 Save       (different approach)
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
3. Continue to review or commit

---

## Path 2: Rollback & Retry (Wrong Approach, Not Fatal)

**When to use:**
- Implementation approach isn't working but problem is solvable
- Need to try different technical approach
- Spent >30 minutes with no progress on current approach
- Code review suggests major refactor

### Rollback Options

#### Option A: Soft Reset (Preserve Changes as Uncommitted)

```bash
# Soft reset to last good commit (preserves changes as uncommitted)
git reset --soft COMMIT_HASH

# Stash changes for reference
git stash save "First attempt - description of approach"

# Start fresh (can view stash later with: git stash show -p stash@{0})
```

#### Option B: Hard Reset (Discard All Changes)

```bash
# WARNING: This is destructive
git diff  # See what will be lost first
git reset --hard COMMIT_HASH
```

#### Option C: Stash (Temporary Parking)

```bash
git stash save "Attempt 1: Description of approach"
# Work on alternative...
# If new approach works: git stash drop stash@{0}
# If new approach fails: git stash pop stash@{0}
```

### After Rollback

1. **Document what didn't work** and why
2. **Plan alternative approach** — what will be different this time?
3. **Implement alternative** — avoid repeating same mistakes
4. **Set time budget** — give new approach max 2 hours. If still failing, consider Abandon.

---

## Path 3: Abandon + Partial Save (Fundamental Failure)

**When to use:**
- Approach is fundamentally flawed (can't be fixed with refactor)
- Requirements were misunderstood
- Architectural dead-end
- Spent >4 hours with no viable path forward
- Security requirements can't be met with current approach

### Partial Save Procedure

**Save if:** Tests for edge cases, research/discoveries, partial implementations that work, documentation of what doesn't work.

**Don't save:** Broken core logic, failed architectural decisions, dead-end code paths.

```bash
# Stage only the useful parts
git add tests/edge-cases.test.js
git add docs/api-research.md

# Commit with discovery prefix
git commit -m "discovery: [What was learned and why approach was abandoned]"
```

### After Abandon

1. Create recovery report documenting the failure
2. Return to planning phase to revise approach
3. Preserve learnings so next attempt doesn't repeat discovery

---

## Failure Type Classification

### Technical Failures
- Bug in implementation, edge cases not handled, algorithm wrong
- **Recovery:** Continue (fix bugs) or Rollback & Retry (different approach)

### Architectural Failures
- Wrong abstraction/pattern, code getting messy, design doesn't scale
- **Recovery:** Rollback & Retry

### Requirements Failures
- Requirements conflict, requirement impossible, misunderstood
- **Recovery:** Abandon (return to planning)

### Performance Failures
- Too slow, too much memory, query too expensive
- **Recovery:** Continue (simple optimization), Rollback (algorithm change), Abandon (impossible requirement)

### Security Failures
- Vulnerability found, auth/authz missing, data exposure
- **Recovery:** Continue (quick fixes) or Rollback & Retry (architectural security flaw)

### External Failures
- Third-party limitation, API doesn't support feature, browser constraint
- **Recovery:** Abandon (if fundamental) or Rollback & Retry (if workaround exists)

---

## Recovery Report Template

```markdown
# Recovery Report: [Feature Name]

**Date:** YYYY-MM-DD
**Recovery Action:** Rollback & Retry | Abandon

## What Went Wrong
[1-2 sentences describing the failure]

## Root Cause
- Technical: [e.g., Wrong algorithm choice]
- Architectural: [e.g., Abstraction doesn't fit requirements]
- Requirements: [e.g., Misunderstood requirement]

## What We Tried
1. [First approach and why it failed]
2. [Second approach and why it failed]

## What We Learned
- [Key insight 1]
- [Key insight 2]

## Artifacts Preserved
- [File/commit with useful work]

## Recommended Next Steps
1. [What to do differently next time]
2. [Whether to revise requirements]
```

---

## Best Practices

**Do:**
- Decide quickly — don't waste time on dead ends
- Preserve learnings — document what didn't work
- Use git liberally — commit checkpoints as you go
- Time-box attempts — give each approach maximum 2 hours

**Don't:**
- Keep iterating indefinitely — know when to cut losses
- Hard reset without backup — use stash or check reflog first
- Abandon without preserving learnings — future you will thank you
- Skip recovery report — document failures for learning

---

## Git Safety Net

Git keeps deleted commits for ~30 days in reflog:

```bash
git reflog                              # View all operations
git reflog | grep "commit message"      # Find lost commit
git reset --hard [COMMIT_FROM_REFLOG]   # Restore lost work
```

**This means hard resets are (mostly) reversible if you act quickly.**
