---
name: generate-tests
description: "Test generation methodology with comprehensive coverage patterns"
---

# Test Generation Skill

Methodology for generating comprehensive tests covering happy path, edge cases, and error conditions.

---

## When to Apply

- After implementing code and ready to test
- Need comprehensive test coverage (unit, integration, edge cases)
- Before running validation checks

---

## Process

### 1. Identify Files to Test

Detect modified files via git:
```bash
git diff --name-only HEAD
git diff --staged --name-only
```

> Note: Adjust commands for PowerShell on Windows (e.g., `git diff --name-only HEAD` works the same, but shell piping differs).

Filter to source files (exclude tests, configs, docs).

### 2. Load Test Strategy

**Read:** `templates/TEST_STRATEGY.md`

**Required test types based on code:**
- **All code:** Unit tests (happy path, null/empty, boundaries, errors)
- **API endpoints:** Integration tests (CRUD, auth, errors)
- **Auth/security code:** Security tests (OWASP Top 10)
- **Database code:** Integration tests (transactions, rollback)
- **UI components:** Component tests (render, interactions)
- **Performance-critical:** Performance tests (if flagged)

### 3. Analyze Code

For each file, identify: public functions/methods, exported classes, API endpoints, database queries, input validation logic, error handling.

### 4. Generate Tests

**Required test cases per function:**

1. **Happy path** -- Normal input, expected output
2. **Null/empty inputs** -- Edge case (null, undefined, "", [], {})
3. **Boundary values** -- Min/max values, off-by-one
4. **Invalid inputs** -- Wrong types, malformed data
5. **Error conditions** -- DB failures, network errors, timeouts

### 5. Determine Test File Location

Follow project's existing convention:
- Same directory (e.g., `AuthService.test.ts`)
- Parallel tests/ directory (e.g., `tests/auth/AuthService.test.ts`)

### 6. Estimate Coverage

Count functions, test cases, estimate line coverage. Target: >80% line, >70% branch.

---

## Integration Points

- **Input**: Modified source files
- **Output**: Test files with comprehensive coverage
- **Template**: `templates/TEST_STRATEGY.md`
