---
description: Evaluate Continue/Rollback/Abandon for failed implementations
---

# /recovery

**Description:** Evaluate Continue/Rollback/Abandon decision for failed implementations

**When to use:**
- Fresh Eyes Review found unfixable issues
- Implementation failing despite multiple fix attempts
- Tests won't pass after reasonable effort (<30 min)
- Approach fundamentally flawed
- GODMODE Phase 1 Step 6.5 (Recovery Decision Point)

**Prerequisites:**
- Implementation attempted but encountering problems
- Issues identified (from validation, Fresh Eyes, or manual testing)

---

## Invocation

**Interactive mode:**
User types `/recovery` with no arguments. Claude guides through decision tree.

**Direct mode:**
User types `/recovery --rollback` or `/recovery --abandon` to jump to specific action.

---

## Arguments

- `--rollback` - Skip decision tree, go directly to rollback procedures
- `--abandon` - Skip decision tree, go directly to abandon procedures

---

## Execution Steps

### Step 1: Load recovery framework

**Read:** `~/.claude/guides/FAILURE_RECOVERY.md`

**Recovery decision tree:**
```
┌─ Implementation Issue Detected ─┐
│                                  │
├─ Can be fixed in <30min? ───────┼─ YES → Continue Phase 1 (iterate)
│                                  │
├─ NO                              │
│                                  │
├─ Is approach fundamentally flawed? ─┬─ YES → Abandon + Partial Save
│                                      │        → Return to Phase 0
│                                      │
├─ NO (fixable with different tactic) │
│                                      │
└─ Rollback to last checkpoint ───────┴─ Try alternative approach
   → Phase 1 restart with new strategy
```

### Step 2: Guide user through decision tree (Interactive)

**If direct mode (--rollback or --abandon):**
- Skip to Step 3 with chosen action

**If interactive mode:**

**Question 1: Can issues be fixed in <30 minutes?**
```
🔄 Recovery Decision

Current status:
- Fresh Eyes Review: FIX_BEFORE_COMMIT
- Issues: 1 CRITICAL, 2 HIGH
- Attempts: [Number of fix attempts so far]

Can all issues be fixed in <30 minutes? (yes/no): _____
```

**If yes → Continue (iterate in Phase 1)**
```
Recommendation: CONTINUE

Continue fixing issues in current Phase 1 implementation.

Next steps:
- Fix the issues
- Re-run validation: `/run-validation`
- Re-run review: `/fresh-eyes-review`
```

**If no → Question 2**

**Question 2: Is the approach fundamentally flawed?**
```
Is the current approach fundamentally flawed? (yes/no): _____

Examples of fundamental flaws:
- Architecture doesn't support requirements
- Technology choice can't achieve performance goals
- Security requirements impossible with current design
- Requirements contradictory or impossible
```

**If yes → Abandon**
```
Recommendation: ABANDON + PARTIAL SAVE

The approach is fundamentally flawed.
Save useful artifacts, create recovery report, return to Phase 0.

Proceed with abandon? (yes/no): _____
```

**If no → Rollback & Retry**
```
Recommendation: ROLLBACK & RETRY

The approach is fixable with a different implementation strategy.
Rollback to last good state, retry with alternative approach.

Proceed with rollback? (yes/no): _____
```

### Step 3: Execute chosen recovery action

### Action: CONTINUE (iterate)

```
✅ Continuing with current implementation

Next steps:
1. Fix identified issues
2. Run validation: `/run-validation`
3. Run review: `/fresh-eyes-review`
4. If still failing, re-run: `/recovery`
```

### Action: ROLLBACK & RETRY

**Present rollback options:**
```
🔄 Rollback Options

1. Soft reset (preserve changes for reference)
   - Keeps changes as uncommitted files
   - Use: Want to reference old code while rewriting

2. Hard reset (discard all changes)
   - Completely discards changes
   - Use: Clean slate, start fresh

3. Stash (temporary parking)
   - Parks changes for later retrieval
   - Use: Might need this approach later

Your choice: _____
```

**Execute rollback:**

**1. Soft reset:**
```bash
# Find last good commit (before implementation)
git log --oneline -10

# Soft reset to commit (preserves changes as uncommitted)
# Replace COMMIT_HASH with actual commit (e.g., abc1234)
git reset --soft COMMIT_HASH

# Verify
git status  # Should show all changes as uncommitted
```

**2. Hard reset:**
```bash
# Hard reset to specific commit (DISCARDS all changes)
# Replace COMMIT_HASH with actual commit
git reset --hard COMMIT_HASH

# Or reset to beginning of branch (main)
git reset --hard origin/main

# Verify
git status  # Should show clean working tree
```

**3. Stash:**
```bash
# Stash changes with descriptive message
git stash push -m "Attempted OAuth implementation - SQL injection issues"

# Verify
git stash list  # Should show stashed changes
git status      # Should show clean working tree
```

**After rollback:**
```
✅ Rollback complete!

Action: Soft reset to commit abc1234
Status: Changes preserved as uncommitted files

Next steps:
1. Review what didn't work (reference old code)
2. Plan alternative approach
3. Reimplement with new strategy
4. Generate tests: `/generate-tests`
```

### Action: ABANDON + PARTIAL SAVE

**1. Identify useful artifacts:**
```
Identifying artifacts to save...

Useful artifacts found:
- Tests written (can be reused)
- Database migration (schema design still valid)
- API spec (requirements still applicable)

Save these artifacts? (yes/no): _____
```

**2. If yes, commit useful artifacts:**
```bash
# Stage only useful artifacts
git add tests/auth/*.test.ts
git add migrations/001_add_users_table.sql
git add docs/api-spec.yaml

# Commit with message
git commit -m "chore: save useful artifacts from abandoned OAuth implementation

Tests and schema still valid for future implementation.

Abandoned due to: SQL injection risks in current approach

See recovery report: docs/recovery/2025-12-01-oauth-implementation.md"
```

**3. Generate recovery report:**

**Load template:** `~/.claude/templates/RECOVERY_REPORT.md`

**Populate report:**
```markdown
# Recovery Report: OAuth Implementation

**Date:** 2025-12-01
**Issue:** #123
**Status:** ABANDONED

## What Was Attempted
[Description of implementation approach]

## Why It Failed
- Root cause: SQL injection risks in token storage
- Unfixable because: Architecture requires raw SQL queries
- Attempts made: 3 fix attempts over 2 hours

## Artifacts Preserved
- tests/auth/*.test.ts - Test suite (valid for future impl)
- migrations/001_add_users_table.sql - Database schema
- docs/api-spec.yaml - API specification

Artifacts commit: abc1234

## Lessons Learned
- Need ORM instead of raw SQL for secure token storage
- Should have reviewed security requirements before implementation

## Recommended Next Steps
1. Return to Phase 0 (Planning)
2. Revise PRD with ORM requirement
3. Update ADR with SQL security decision
4. Create new implementation issue with revised approach
```

**Save report:**
```bash
mkdir -p docs/recovery
# Save report to docs/recovery/2025-12-01-oauth-implementation.md
```

**4. Discard remaining code:**
```bash
# Hard reset to discard failed implementation
git reset --hard origin/main
```

**5. Update issue:**
```bash
gh issue comment 123 --body "⚠️ Implementation abandoned due to fundamental security issues.

See recovery report: docs/recovery/2025-12-01-oauth-implementation.md

Useful artifacts saved in commit abc1234.

Next steps:
- Revise PRD with ORM requirement
- Create new implementation issue"

# Remove assignment
gh issue edit 123 --remove-assignee @me

# Add label
gh issue edit 123 --add-label "needs-replanning"
```

**After abandon:**
```
✅ Abandon complete!

Recovery report: docs/recovery/2025-12-01-oauth-implementation.md
Artifacts saved: commit abc1234
Issue updated: #123

Status: RECOVERY_MODE

Next steps:
1. Review recovery report
2. Return to Phase 0: Revise PRD
3. Update ADR with lessons learned
4. Create new implementation issue when ready
```

### Step 4: Set recovery status

**Status flags:**
- `RECOVERY_MODE` - Currently in recovery
- `ROLLBACK_COMPLETE` - Rolled back, ready to retry
- `ABANDONED` - Implementation abandoned, return to planning

---

## Output

**Recovery decision:** CONTINUE | ROLLBACK | ABANDON

**If ROLLBACK:**
- Rollback method used (soft reset, hard reset, stash)
- Git status after rollback
- Suggested next steps

**If ABANDON:**
- Recovery report created
- Artifacts saved (commit hash)
- Issue updated
- Suggested return to Phase 0

---

## References

- See: `~/.claude/guides/FAILURE_RECOVERY.md` for full recovery procedures
- See: `~/.claude/templates/RECOVERY_REPORT.md` for report template
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Step 6.5 for recovery decision point

---

## Example Usage

**Example 1: Continue (fixable quickly)**
```
User: /recovery

Claude: 🔄 Recovery Decision

Issues: 1 CRITICAL, 2 HIGH

Can fix in <30 min? yes

Recommendation: CONTINUE

Next steps:
- Fix issues
- Re-run: `/fresh-eyes-review`
```

**Example 2: Rollback (different approach needed)**
```
User: /recovery

Claude: Can fix in <30 min? no
Approach fundamentally flawed? no

Recommendation: ROLLBACK & RETRY

Rollback options:
1. Soft reset
2. Hard reset
3. Stash

Your choice: 1

[Executes soft reset]

✅ Rollback complete!

Next steps:
- Reimplement with new approach
```

**Example 3: Abandon (fundamentally flawed)**
```
User: /recovery --abandon

Claude: [Skips decision tree]

Identifying artifacts...

Artifacts:
- tests/auth/*.test.ts
- migrations/001_users.sql

Save? yes

[Commits artifacts]
[Generates recovery report]
[Updates issue]

✅ Abandon complete!

Report: docs/recovery/2025-12-01-oauth.md

Return to Phase 0.
```

---

## Notes

- **Decision tree is critical:** Helps avoid wasted effort
- **<30 min threshold:** Rule of thumb for when to stop iterating
- **Fundamental flaw:** Architecture, technology, or requirements impossible
- **Partial save:** Always preserve useful artifacts (tests, specs, migrations)
- **Recovery report:** Documents what was tried and why it failed
- **Lessons learned:** Feed back into process improvement
- **Not failure:** Recovery is learning, improves future implementations
- **Re-enter workflow:** After rollback/abandon, return to appropriate phase
