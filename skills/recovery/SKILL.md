---
name: recovery
version: "1.0"
description: Failure recovery methodology — Continue/Rollback/Abandon decision tree
referenced_by:
  - commands/implement.md
---

# Recovery Skill

Decision tree and procedures for handling failed implementations.

---

## When to Apply

- Fresh Eyes Review found unfixable issues
- Implementation failing despite multiple fix attempts
- Approach fundamentally flawed

---

## Decision Tree

```
┌─ Implementation Issue Detected ─┐
│                                  │
├─ Can be fixed quickly? ─────────┼─ YES → Continue (iterate)
│                                  │
├─ NO                              │
│                                  │
├─ Approach fundamentally flawed? ─┬─ YES → Abandon + Partial Save
│                                   │        → Return to planning
│                                   │
├─ NO (fixable with different tactic)│
│                                   │
└─ Rollback to last checkpoint ────┴─ Try alternative approach
```

---

## Recovery Actions

### CONTINUE (iterate)

Fix identified issues. Re-run validation and review.

### ROLLBACK & RETRY

**Rollback options:**
1. **Soft reset** — `git reset --soft COMMIT_HASH` (preserves changes as uncommitted)
2. **Hard reset** — `git reset --hard COMMIT_HASH` (discards all changes)
3. **Stash** — `git stash push -m "description"` (parks changes for later)

### ABANDON + PARTIAL SAVE

1. Identify useful artifacts (tests, migrations, specs)
2. Commit useful artifacts separately
3. Generate recovery report using `templates/RECOVERY_REPORT.md`
4. Save to `docs/recovery/YYYY-MM-DD-feature.md`
5. Hard reset remaining code
6. Update GitHub issue with abandon comment

---

## Status Flags

- `RECOVERY_MODE` — Currently in recovery
- `ROLLBACK_COMPLETE` — Rolled back, ready to retry
- `ABANDONED` — Implementation abandoned, return to planning

---

## Integration Points

- **Input**: Failed implementation context
- **Output**: Recovery action completed, report generated
- **Template**: `templates/RECOVERY_REPORT.md`
- **Guide**: `guides/FAILURE_RECOVERY.md`
- **Consumed by**: `/implement` workflow command
