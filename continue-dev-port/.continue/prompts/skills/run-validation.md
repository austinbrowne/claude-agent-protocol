---
name: run-validation
description: "Comprehensive validation methodology -- tests, coverage, lint, security scan"
---

# Validation Skill

Methodology for running comprehensive validation checks: tests, coverage, linting, and security scanning.

---

## When to Apply

- After implementing code and writing tests
- Before Fresh Eyes Review
- Want comprehensive validation in one pass

---

## Process

### 1. Detect Project Type and Tools

Scan for: `package.json` (Node.js), `requirements.txt`/`pyproject.toml` (Python), `Cargo.toml` (Rust), `go.mod` (Go), `pom.xml`/`build.gradle` (Java).

Auto-detect: test framework, linter, security scanner.

### 2. Run Test Suite

Execute tests for detected language. Capture: pass/fail count, duration.

> Note: Adjust commands for PowerShell on Windows (e.g., `npm test` works the same, but `pytest` may need `python -m pytest` depending on environment).

**If tests fail:** Report failures with file:line references. Block further checks.

### 3. Check Test Coverage

Execute coverage tool. Parse: line %, branch %, uncovered files/lines.

**Thresholds:**
- >=80% line coverage -> PASS
- 70-79% -> WARNING
- <70% -> FAIL

### 4. Run Linter

Execute appropriate linter. Capture: error count, warning count, specific issues.

### 5. Run Security Scan

Execute security scanner (`npm audit`, `pip-audit`, `cargo audit`, etc.). Parse: vulnerability count by severity, affected packages, CVEs.

### 6. Aggregate Results

**Overall verdict:**
- **PASS**: All checks passed
- **PASS_WITH_WARNINGS**: Tests pass but warnings exist
- **FAIL**: Tests failing, lint errors, or High/Critical vulnerabilities

**Status flags:** `VALIDATION_PASSED`, `VALIDATION_WARNINGS`, `VALIDATION_FAILED`

---

## Integration Points

- **Input**: Project with code and tests
- **Output**: Validation report with verdict
- **Template**: `templates/TEST_STRATEGY.md`
