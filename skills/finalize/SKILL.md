---
name: finalize
version: "1.0"
description: Final documentation and validation methodology before merge
referenced_by:
  - commands/ship.md
---

# Finalization Skill

Methodology for final documentation updates and validation before merge.

---

## When to Apply

- After PR created and code review complete
- Before final merge to main/production
- Want comprehensive final checks

---

## Process

### 1. Check Documentation Needs

Scan changes for triggers:
- **README**: Public API changed, CLI commands added, config changed, new dependencies
- **CHANGELOG**: Any user-facing changes, bug fixes, features, breaking changes
- **API docs**: OpenAPI/Swagger spec exists, endpoints modified

### 2. Update README (if needed)

Identify sections to update (Installation, Usage, API Reference, Configuration). Show diff, get confirmation.

### 3. Generate CHANGELOG Entry (if needed)

**Keep a Changelog format:**
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added / Changed / Security / Fixed
```

### 4. Update API Docs (if needed)

Update OpenAPI/Swagger spec with new/modified endpoints.

### 5. Add WHY Comments (if needed)

For complex logic (cyclomatic complexity >5, non-obvious algorithms, workarounds):
```typescript
// WHY: [explanation of rationale, not what the code does]
```

### 6. Run Final Test Suite

Execute: unit tests, integration tests, linter, type check, build.

### 7. Commit Documentation Updates

Separate commit for documentation changes.

### 8. Close Issue with Completion Summary

**If working on a GitHub issue (issue number available from branch name or commit messages):**

```bash
# Post completion summary (works regardless of issue state)
gh issue comment NNN --body "$(cat <<'EOF'
Implementation complete. All acceptance criteria met.

- Tests: passing
- Security review: completed
- Fresh Eyes review: APPROVED
- Documentation: updated (if applicable)
EOF
)"

# Close if still open (may already be closed via PR merge "Closes #NNN")
gh issue close NNN 2>/dev/null || true
```

**Label transition:** `status: review` → closed. The comment is posted separately from the close so it succeeds even if the issue was already auto-closed by PR merge.

**If no issue number can be determined** from the branch name (pattern `issue-NNN-*`) or commit messages (`#NNN`, `Closes #NNN`), **skip this step entirely.**

---

## Status

- `READY_TO_MERGE` — All finalization complete

---

## Integration Points

- **Input**: PR with code changes
- **Output**: Updated docs, passing final tests
- **Consumed by**: `/ship` workflow command
