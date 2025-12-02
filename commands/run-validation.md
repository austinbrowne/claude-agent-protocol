# /run-validation

**Description:** Run all validation checks (tests, coverage, lint, security scan)

**When to use:**
- After implementing code and writing tests
- Before Fresh Eyes Review
- Want comprehensive validation (tests + coverage + lint + security)
- GODMODE Phase 1 Step 5 (after tests, before Fresh Eyes)

**Prerequisites:**
- Code implementation exists
- Tests written (`/generate-tests` completed)
- Project has test/lint configuration

---

## Invocation

**Interactive mode:**
User types `/run-validation` with no arguments. Claude runs all checks.

**Direct mode:**
Same as interactive (auto-runs all checks).

---

## Arguments

None - command automatically runs all validation checks.

---

## Execution Steps

### Step 1: Detect project type and tools

**Scan for package files:**
- `package.json` → Node.js/JavaScript (npm, yarn, pnpm)
- `requirements.txt` or `pyproject.toml` → Python (pip, pytest)
- `Cargo.toml` → Rust (cargo)
- `go.mod` → Go (go test)
- `pom.xml` or `build.gradle` → Java (maven, gradle)

**Detect test framework:**
- JavaScript: jest, vitest, mocha, tap
- Python: pytest, unittest
- Rust: cargo test
- Go: go test

**Detect linter:**
- JavaScript: eslint, tsc (TypeScript)
- Python: flake8, pylint, black, ruff
- Rust: cargo clippy
- Go: golint, go vet

**Detect security scanner:**
- JavaScript: npm audit, snyk
- Python: pip-audit, bandit, safety
- Rust: cargo audit
- Go: gosec

### Step 2: Run test suite

**Execute tests:**

**JavaScript:**
```bash
npm test
# or
yarn test
# or
pnpm test
```

**Python:**
```bash
pytest --verbose
# or
python -m unittest discover
```

**Rust:**
```bash
cargo test
```

**Capture output:**
- Tests passing / failing
- Test count (N passed, N failed)
- Duration

**If tests fail:**
```
❌ Tests failed!

Failed tests:
- src/auth/AuthService.test.ts:45 - test_login_with_invalid_email
- src/api/users.test.ts:23 - test_create_user_without_email

Fix failing tests before proceeding.

Next steps:
- Fix tests and re-run: `/run-validation`
- Or investigate failures and update implementation
```

### Step 3: Check test coverage

**Execute coverage:**

**JavaScript:**
```bash
npm test -- --coverage
# or
vitest run --coverage
```

**Python:**
```bash
pytest --cov=src --cov-report=term
```

**Rust:**
```bash
cargo tarpaulin
# or
cargo llvm-cov
```

**Parse coverage output:**
- Line coverage %
- Branch coverage %
- Uncovered files/lines

**Coverage thresholds:**
- ✅ ≥80% line coverage - PASS
- ⚠️  70-79% - WARNING (should improve)
- ❌ <70% - FAIL (insufficient coverage)

**If coverage below threshold:**
```
⚠️  Test coverage below target!

Coverage: 72% (target: ≥80%)

Uncovered areas:
- src/auth/AuthService.ts lines 45-52 (error handling)
- src/utils/validation.ts lines 23-30 (edge cases)

Recommendation: Add tests for uncovered code

Next steps:
- Generate more tests: `/generate-tests`
- Or proceed with caution (coverage warning noted)
```

### Step 4: Run linter

**Execute linter:**

**JavaScript:**
```bash
npm run lint
# or
eslint src/
# or (TypeScript)
tsc --noEmit
```

**Python:**
```bash
flake8 src/
# or
ruff check src/
```

**Rust:**
```bash
cargo clippy -- -D warnings
```

**Capture lint issues:**
- Error count
- Warning count
- Specific issues (file:line)

**If lint errors:**
```
❌ Linter found errors!

Errors (4):
- src/auth/AuthService.ts:23 - Unused variable 'oldToken'
- src/api/users.ts:45 - Missing type annotation
- src/utils/format.ts:12 - Unreachable code after return

Warnings (2):
- src/config.ts:5 - Prefer const over let

Fix linter errors before proceeding.

Next steps:
- Fix errors and re-run: `/run-validation`
- Auto-fix if possible: `npm run lint -- --fix`
```

### Step 5: Run security scan

**Execute security scanner:**

**JavaScript:**
```bash
npm audit
# or
yarn audit
# or
pnpm audit
```

**Python:**
```bash
pip-audit
# or
bandit -r src/
```

**Rust:**
```bash
cargo audit
```

**Parse security findings:**
- Vulnerability count by severity (Critical, High, Medium, Low)
- Affected packages
- CVE numbers

**If vulnerabilities found:**
```
⚠️  Security vulnerabilities detected!

Critical: 0
High: 1
  - lodash@4.17.15 (CVE-2020-8203: Prototype Pollution)
    Fix: Upgrade to lodash@4.17.21
Medium: 2
  - axios@0.21.0 (CVE-2021-3749: SSRF)
    Fix: Upgrade to axios@0.21.4
Low: 3

Recommendation: Fix High/Critical vulnerabilities

Next steps:
- Run: `npm audit fix`
- Or manually upgrade vulnerable packages
- Re-run: `/run-validation`
```

### Step 6: Aggregate results and generate report

**Overall verdict:**
- **PASS**: All checks passed (tests ✅, coverage ✅, lint ✅, security ✅)
- **PASS_WITH_WARNINGS**: Tests pass but warnings exist (coverage <80%, Low security issues)
- **FAIL**: Tests failing, lint errors, or High/Critical security vulnerabilities

**Generate summary report:**
```
✅ Validation Results

=== TESTS ===
✅ 24 tests passing
⏱️  Duration: 3.2s

=== COVERAGE ===
✅ Line coverage: 87% (target: ≥80%)
✅ Branch coverage: 81%

=== LINTER ===
✅ No lint errors
⚠️  2 warnings (non-blocking)

=== SECURITY ===
✅ No Critical/High vulnerabilities
⚠️  2 Medium, 3 Low vulnerabilities (can proceed)

Overall: PASS ✅

Next steps:
- Fresh Eyes Review: `/fresh-eyes-review`
- Or commit directly: `/commit-and-pr`
```

### Step 7: Set validation status

**Status flags:**
- `VALIDATION_PASSED` - All checks passed
- `VALIDATION_WARNINGS` - Passed with warnings (coverage, Low vulns)
- `VALIDATION_FAILED` - Critical failures (tests, lint, High vulns)

### Step 8: Suggest next steps

**If PASS:**
```
Next steps:
- Fresh Eyes Review: `/fresh-eyes-review`
- Or skip review and commit: `/commit-and-pr`
```

**If PASS_WITH_WARNINGS:**
```
Next steps:
- Address warnings if possible
- Proceed to Fresh Eyes Review: `/fresh-eyes-review`
```

**If FAIL:**
```
Next steps:
- Fix failing tests
- Fix lint errors
- Upgrade vulnerable packages
- Re-run: `/run-validation`
- If unfixable, consider: `/recovery`
```

---

## Output

**Validation report:**
- Tests: N passing, N failing, duration
- Coverage: Line %, branch %, uncovered areas
- Linter: Errors, warnings
- Security: Vulnerabilities by severity

**Overall verdict:** PASS | PASS_WITH_WARNINGS | FAIL

**Status flag:** `VALIDATION_PASSED`, `VALIDATION_WARNINGS`, or `VALIDATION_FAILED`

**Suggested next steps:**
- If PASS: "Run `/fresh-eyes-review`"
- If FAIL: "Fix issues and re-run `/run-validation`"

---

## References

- See: `~/.claude/templates/TEST_STRATEGY.md` for test requirements
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 1 Step 5 for validation guidance

---

## Example Usage

**Example 1: All checks pass**
```
User: /run-validation

Claude: Running validation checks...

✅ Validation Results

=== TESTS ===
✅ 24/24 tests passing
⏱️  3.2s

=== COVERAGE ===
✅ Line: 87% (≥80%)
✅ Branch: 81%

=== LINTER ===
✅ No errors
⚠️  2 warnings

=== SECURITY ===
✅ No vulnerabilities

Overall: PASS ✅

Next steps:
- Fresh Eyes Review: `/fresh-eyes-review`
```

**Example 2: Tests failing**
```
User: /run-validation

Claude: Running validation checks...

❌ Validation Results

=== TESTS ===
❌ 22/24 passing, 2 FAILED
  - test_login_invalid_email FAILED
  - test_create_user_no_email FAILED

Overall: FAIL ❌

Fix failing tests before proceeding.

Next steps:
- Fix tests
- Re-run: `/run-validation`
```

**Example 3: Coverage warning**
```
User: /run-validation

Claude: Running validation checks...

⚠️  Validation Results

=== TESTS ===
✅ 24/24 passing

=== COVERAGE ===
⚠️  Line: 72% (target: ≥80%)
Uncovered: src/auth/AuthService.ts:45-52

=== LINTER ===
✅ No errors

=== SECURITY ===
✅ No vulnerabilities

Overall: PASS_WITH_WARNINGS ⚠️

Recommendation: Add tests for uncovered code

Next steps:
- Add tests: `/generate-tests`
- Or proceed: `/fresh-eyes-review`
```

---

## Notes

- **Comprehensive validation:** Runs tests, coverage, lint, security in one command
- **Project detection:** Auto-detects language and tools
- **Thresholds:** 80% coverage target, zero High/Critical vulnerabilities
- **Warnings vs errors:** Low severity issues are warnings, don't block progress
- **Re-runnable:** Can re-run after fixing issues
- **Exit codes:** Returns non-zero exit code if validation fails (for CI/CD)
