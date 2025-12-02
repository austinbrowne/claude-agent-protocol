---
description: Generate tests for implemented code
---

# /generate-tests

**Description:** Generate tests for implemented code

**When to use:**
- After implementing code and ready to test
- Need comprehensive test coverage (unit, integration, edge cases)
- Following GODMODE Phase 1 Step 3 (after implementation)
- Before running validation checks

**Prerequisites:**
- Code implementation exists (modified files in git diff)
- Test framework configured in project

---

## Invocation

**Interactive mode:**
User types `/generate-tests` with no arguments. Claude detects modified files and asks which to test.

**Direct mode:**
User types `/generate-tests --path src/auth/AuthService.ts` to test specific file.

---

## Arguments

- `--path [file_path]` - Specific file to generate tests for
- `--all` - Generate tests for all modified files (default if no args)

---

## Execution Steps

### Step 1: Identify files to test

**If direct mode (--path provided):**
- Test specified file

**If interactive mode (no arguments) or --all:**
- Detect modified files via git:
  ```bash
  git diff --name-only HEAD
  git diff --staged --name-only
  ```
- Filter to source files (exclude tests, configs, docs)
- Display to user:
  ```
  🧪 Test Generation

  Modified files:
  1. src/auth/AuthService.ts (230 lines)
  2. src/middleware/auth.ts (45 lines)
  3. All modified files

  Select files to test: _____
  ```

### Step 2: Load test strategy and requirements

**Read:** `~/.claude/templates/TEST_STRATEGY.md`

**Determine required test types based on code:**
- **All code:** Unit tests (happy path, null/empty, boundaries, errors)
- **API endpoints:** Integration tests (CRUD, auth, errors)
- **Auth/security code:** Security tests (OWASP Top 10)
- **Database code:** Integration tests (transactions, rollback)
- **UI components:** Component tests (render, interactions, edge cases)
- **Performance-critical:** Performance tests (if flagged in issue/PRD)

### Step 3: Analyze code to test

**For each file:**
- Read file contents
- Identify:
  - Public functions/methods (test interfaces, not internals)
  - Exported classes
  - API endpoints
  - Database queries
  - Input validation logic
  - Error handling

### Step 4: Generate tests following TEST_STRATEGY.md

**Required test cases per function:**

**1. Happy path** - Normal input, expected output
```typescript
it('authenticates user with valid credentials', async () => {
  const result = await authService.login('user@test.com', 'password123')
  expect(result.token).toBeDefined()
  expect(result.user.email).toBe('user@test.com')
})
```

**2. Null/empty inputs** - Edge case
```typescript
it('rejects null email', async () => {
  await expect(authService.login(null, 'password'))
    .rejects.toThrow('Email is required')
})

it('rejects empty password', async () => {
  await expect(authService.login('user@test.com', ''))
    .rejects.toThrow('Password is required')
})
```

**3. Boundary values** - Edge case
```typescript
it('accepts maximum length password (128 chars)', async () => {
  const longPassword = 'a'.repeat(128)
  const result = await authService.login('user@test.com', longPassword)
  expect(result).toBeDefined()
})

it('rejects password exceeding max length', async () => {
  const tooLongPassword = 'a'.repeat(129)
  await expect(authService.login('user@test.com', tooLongPassword))
    .rejects.toThrow('Password too long')
})
```

**4. Invalid inputs** - Error case
```typescript
it('rejects invalid email format', async () => {
  await expect(authService.login('not-an-email', 'password'))
    .rejects.toThrow('Invalid email format')
})

it('rejects wrong data type for password', async () => {
  await expect(authService.login('user@test.com', 12345))
    .rejects.toThrow('Password must be string')
})
```

**5. Error conditions** - Error case
```typescript
it('handles database connection failure', async () => {
  // Mock database failure
  jest.spyOn(db, 'query').mockRejectedValue(new Error('Connection failed'))

  await expect(authService.login('user@test.com', 'password'))
    .rejects.toThrow('Authentication service unavailable')
})

it('handles incorrect password', async () => {
  await expect(authService.login('user@test.com', 'wrong-password'))
    .rejects.toThrow('Invalid credentials')
})
```

### Step 5: Determine test file location and create tests

**Test file naming conventions:**

**JavaScript/TypeScript:**
- Source: `src/auth/AuthService.ts`
- Tests: `src/auth/AuthService.test.ts` (same directory)
- Or: `tests/auth/AuthService.test.ts` (parallel structure)

**Python:**
- Source: `src/auth/auth_service.py`
- Tests: `tests/test_auth_service.py` (tests/ directory)

**Detect project convention:**
- Check existing test files for pattern
- Use same pattern

**Generate test file:**
- Import necessary testing libraries (jest, vitest, pytest, etc.)
- Import code under test
- Write all required test cases
- Include setup/teardown if needed (database, mocks)

### Step 6: Estimate coverage and report

**Calculate estimated coverage:**
- Count functions/methods in source file
- Count test cases generated
- Estimate line coverage (rough estimate, actual coverage from running tests)

**Report:**
```
✅ Tests generated!

Files:
- src/auth/AuthService.test.ts (12 test cases)
  - Happy path: 2 tests
  - Edge cases: 4 tests (null/empty, boundaries)
  - Error cases: 6 tests (invalid input, error conditions)
  - Estimated coverage: ~85%

- src/middleware/auth.test.ts (8 test cases)
  - Happy path: 1 test
  - Edge cases: 3 tests
  - Error cases: 4 tests
  - Estimated coverage: ~90%

Total test cases: 20
Estimated overall coverage: ~87%

Next steps:
- Run tests: `/run-validation`
- Add integration tests if needed
- Security review: `/security-review` (code is SECURITY_SENSITIVE)
```

---

## Output

**Test files created:**
- Test files with comprehensive coverage
- Following project's testing framework and conventions
- Covering happy path, edge cases, and error conditions

**Test breakdown:**
- Happy path tests
- Edge case tests (null/empty, boundaries)
- Error case tests (invalid input, error conditions)
- Security tests (if SECURITY_SENSITIVE)

**Coverage estimate:** ~80-90% (actual coverage from running tests)

**Suggested next steps:**
- "Run `/run-validation` to execute tests and check coverage"
- Or: "Add integration tests if needed"

---

## References

- See: `~/.claude/templates/TEST_STRATEGY.md` for test requirements
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 1 Step 3 for testing guidance

---

## Example Usage

**Example 1: Interactive mode**
```
User: /generate-tests

Claude: 🧪 Test Generation

Modified files:
1. src/auth/AuthService.ts (230 lines)
2. src/middleware/auth.ts (45 lines)
3. All modified files

Select: _____

User: 3

Claude: [Analyzes all files, generates tests]

✅ Tests generated!

Files:
- src/auth/AuthService.test.ts (12 tests, ~85% coverage)
- src/middleware/auth.test.ts (8 tests, ~90% coverage)

Total: 20 test cases, ~87% coverage

Next steps:
- Run tests: `/run-validation`
```

**Example 2: Direct mode**
```
User: /generate-tests --path src/auth/AuthService.ts

Claude: [Immediately generates tests for AuthService]

✅ Tests generated!

File: src/auth/AuthService.test.ts (12 tests)
- Happy path: 2 tests
- Edge cases: 4 tests
- Error cases: 6 tests
- Estimated coverage: ~85%

Next steps:
- Run tests: `/run-validation`
```

---

## Notes

- **Test structure:** Follow project's existing test framework (jest, vitest, pytest, etc.)
- **Mocking:** Auto-generate mocks for external dependencies (database, APIs)
- **Coverage target:** Aim for >80% line coverage, >70% branch coverage
- **Security-sensitive code:** Generate additional security-specific tests
- **Edge cases critical:** Null, empty, boundaries, type errors
- **Error handling:** Test all error paths and exception handling
- **Test file location:** Follow project convention (same directory or parallel tests/ directory)
