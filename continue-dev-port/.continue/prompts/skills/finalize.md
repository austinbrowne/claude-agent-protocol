---
name: finalize
description: "Final documentation and validation before merge"
---

# Finalization

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

> Note: Adjust commands for PowerShell on Windows (e.g., `npm test` and `npm run build` work cross-platform, but shell-specific commands may differ).

### 7. Commit Documentation Updates

Separate commit for documentation changes.

### 8. Close Issue and Update Plan Status

**Plan status update:** Search the issue body for a path matching `docs/plans/YYYY-MM-DD-*.md` (bare path or markdown link), or check `.todos/` for a plan reference. If the referenced plan file does not exist, log a warning and continue without blocking. If the plan file exists, read its YAML frontmatter `status:` field. Only update to `complete` if the current status is `in_progress` (forward transitions only -- do not regress `complete` plans that were already finalized). If the frontmatter exists but has no `status:` field, add `status: complete`. This marks the plan lifecycle as finished.

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

> Note: Use `glab` for GitLab repositories. Adjust commands for PowerShell on Windows (e.g., HEREDOC syntax differs -- use `@" ... "@` for multi-line strings).

**Label transition:** `status: review` -> closed. The comment is posted separately from the close so it succeeds even if the issue was already auto-closed by PR merge.

**If no issue number can be determined** from the branch name (pattern `issue-NNN-*`) or commit messages (`#NNN`, `Closes #NNN`), **skip this step entirely.**

---

## Status

- `READY_TO_MERGE` -- All finalization complete

---

## Integration Points

- **Input**: PR with code changes
- **Output**: Updated docs, passing final tests
- **Consumed by**: Ship workflow
