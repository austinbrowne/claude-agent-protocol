# /refactor

**Description:** Guided refactoring pass to improve code quality

**When to use:**
- After PR merged and feature complete
- Want to improve code quality (reduce duplication, complexity)
- GODMODE Phase 2 Step 1 (optional finalization step)

**Prerequisites:**
- Code committed (PR merged or close to merge)
- Tests passing

---

## Invocation

**Interactive mode:**
User types `/refactor` with no arguments. Claude analyzes code for refactoring opportunities.

**Direct mode:**
Same as interactive (auto-analyzes all code).

---

## Arguments

None - command automatically analyzes code for refactoring opportunities.

---

## Execution Steps

### Step 1: Analyze code for refactoring opportunities

**Scan codebase for common code smells:**

**1. Code duplication:**
```bash
# Search for similar code blocks
# Use AST analysis or pattern matching
```

**Detect:**
- Identical or nearly-identical code blocks (>5 lines)
- Repeated logic in multiple functions
- Copy-pasted code with minor variations

**2. Magic numbers:**
```bash
grep -r "[^a-zA-Z_][0-9]{2,}" src/
```

**Detect:**
- Hardcoded numbers without explanation (e.g., 86400, 1024, 3600)
- Exclude common values (0, 1, -1, 100, etc.)

**3. Complex conditionals:**
- Cyclomatic complexity >5
- Nested if statements >3 levels
- Long boolean expressions

**4. God objects:**
- Classes >300 LOC
- Classes with >10 methods
- Classes doing too many things

**5. Long functions:**
- Functions >50 LOC
- Functions with >3 responsibilities

**6. Poor naming:**
- Single-letter variable names (except loop counters)
- Abbreviations (usr, ctx, cfg)
- Non-descriptive names (data, temp, result)

### Step 2: Present findings to user

```
🔧 Refactoring Analysis

Opportunities found:

=== CODE DUPLICATION ===
1. Similar code in src/auth/AuthService.ts lines 45-67 and 89-111 (23 lines)
   Suggestion: Extract to validateCredentials() helper function

2. Repeated error handling in src/api/*.ts (5 files)
   Suggestion: Create error handling middleware

=== MAGIC NUMBERS ===
3. Token expiry = 86400 in src/config.ts:15
   Suggestion: const SECONDS_PER_DAY = 86400 or const TOKEN_EXPIRY_SECONDS = 86400

4. Rate limit = 100 in src/middleware/rateLimit.ts:23
   Suggestion: const MAX_REQUESTS_PER_MINUTE = 100

=== COMPLEX CONDITIONALS ===
5. src/middleware/auth.ts:34 - Cyclomatic complexity = 8
   Suggestion: Extract to helper functions (checkTokenExpiry, validateScopes)

=== LONG FUNCTIONS ===
6. src/api/users.ts:createUser() - 85 LOC
   Suggestion: Extract validation and database logic to separate functions

Address these refactorings? (yes/no/select): _____
```

**Options:**
- `yes` - Address all
- `no` - Skip refactoring
- `select` - Choose which to address

### Step 3: For each accepted refactoring, execute changes

**If select mode:**
```
Which refactorings to address? (1,2,3 or 1-6): _____
```

**For each refactoring:**

**Show before/after diff:**
```
Refactoring #1: Extract validateCredentials() helper

BEFORE:
```typescript
// src/auth/AuthService.ts:45-67
async login(email: string, password: string) {
  if (!email || !email.includes('@')) {
    throw new Error('Invalid email')
  }
  if (!password || password.length < 8) {
    throw new Error('Password too short')
  }
  // ... rest of logic
}

async register(email: string, password: string) {
  if (!email || !email.includes('@')) {
    throw new Error('Invalid email')
  }
  if (!password || password.length < 8) {
    throw new Error('Password too short')
  }
  // ... rest of logic
}
```

AFTER:
```typescript
// src/auth/AuthService.ts:45-52
private validateCredentials(email: string, password: string) {
  if (!email || !email.includes('@')) {
    throw new Error('Invalid email')
  }
  if (!password || password.length < 8) {
    throw new Error('Password too short')
  }
}

async login(email: string, password: string) {
  this.validateCredentials(email, password)
  // ... rest of logic
}

async register(email: string, password: string) {
  this.validateCredentials(email, password)
  // ... rest of logic
}
```

Apply this refactoring? (yes/no): _____
```

**If yes, make changes:**
- Edit files using Edit tool
- Preserve functionality (refactoring should not change behavior)

### Step 4: Re-run tests after each refactoring

**After applying refactoring:**
```bash
npm test
# or appropriate test command
```

**Verify tests still pass:**
```
✅ Refactoring #1 applied

Tests: 24/24 passing ✅

Next refactoring? (yes/no): _____
```

**If tests fail:**
```
❌ Refactoring #1 caused test failures!

Failed tests:
- test_login_invalid_email FAILED

Rolling back refactoring...

[Undo changes via git]

Skipping this refactoring.
```

### Step 5: Report refactorings completed

```
✅ Refactoring complete!

Refactorings applied:
1. ✅ Extracted validateCredentials() helper (reduced duplication: 23 lines → 8 lines)
2. ✅ Created error handling middleware (5 files simplified)
3. ✅ Extracted SECONDS_PER_DAY constant
4. ✅ Extracted MAX_REQUESTS_PER_MINUTE constant
5. ⏭️  Skipped (complex conditional - needs architectural change)
6. ⏭️  Skipped (long function - tests failed after refactoring)

Summary:
- Code duplication reduced: 46 lines
- Magic numbers eliminated: 2
- Tests: 24/24 passing ✅

Next steps:
- Run validation: `/run-validation`
- Or finalize: `/finalize`
```

---

## Output

**Refactoring opportunities:**
- Code duplication instances
- Magic numbers to extract
- Complex conditionals to simplify
- Long functions to split
- Poor naming to improve

**Refactorings applied:**
- List of applied refactorings
- Lines of code reduced
- Complexity reduced

**Tests status:** All tests still passing (or rollback if failed)

**Suggested next steps:**
- "Run `/run-validation` to verify changes"
- Or: "Proceed to `/finalize`"

---

## References

- See: [Refactoring by Martin Fowler](https://refactoring.com/)
- See: [Code Smells](https://refactoring.guru/refactoring/smells)

---

## Example Usage

**Example 1: Interactive refactoring**
```
User: /refactor

Claude: 🔧 Refactoring Analysis

Opportunities:
1. Duplication in AuthService (23 lines)
2. Magic number: 86400

Address? yes

Refactoring #1: Extract validateCredentials()

[Shows before/after]

Apply? yes

[Applies refactoring]

Tests: 24/24 passing ✅

Refactoring #2: Extract SECONDS_PER_DAY

[Shows before/after]

Apply? yes

[Applies refactoring]

Tests: 24/24 passing ✅

✅ Refactoring complete!

Applied: 2
Duplication reduced: 23 lines
```

**Example 2: Selective refactoring**
```
User: /refactor

Claude: Opportunities:
1. Duplication
2. Magic number
3. Complex conditional

Address? select

Which? 1,2

[Only applies refactorings #1 and #2, skips #3]
```

**Example 3: No refactoring needed**
```
User: /refactor

Claude: 🔧 Refactoring Analysis

No significant refactoring opportunities found!

Code quality looks good.

Next steps:
- Finalize: `/finalize`
```

---

## Notes

- **Tests must pass:** Refactoring should not change behavior, tests verify this
- **Rollback on failure:** If tests fail after refactoring, rollback changes
- **Selective application:** Can choose which refactorings to apply
- **Incremental:** Apply one refactoring at a time, test after each
- **Code smells:** Focuses on common code smells (duplication, magic numbers, complexity)
- **Not always applicable:** Some refactorings may require architectural changes
- **Optional step:** Refactoring is optional in GODMODE workflow (Phase 2)
