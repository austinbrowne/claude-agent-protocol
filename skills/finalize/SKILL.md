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

---

## Status

- `READY_TO_MERGE` — All finalization complete

---

## Integration Points

- **Input**: PR with code changes
- **Output**: Updated docs, passing final tests
- **Consumed by**: `/ship` workflow command
