---
name: refactor
description: "Guided refactoring methodology for improving code quality"
---

# Refactoring

Methodology for analyzing and applying guided refactoring to improve code quality.

---

## When to Apply

- After PR merged and feature complete
- Want to improve code quality (reduce duplication, complexity)

---

## Process

### 1. Analyze Code for Refactoring Opportunities

Scan for common code smells:

1. **Code duplication** -- identical/similar blocks >5 lines
2. **Magic numbers** -- hardcoded numbers without explanation
3. **Complex conditionals** -- cyclomatic complexity >5, nested ifs >3 levels
4. **God objects** -- classes >300 LOC or >10 methods
5. **Long functions** -- functions >50 LOC or >3 responsibilities
6. **Poor naming** -- single-letter variables, abbreviations, non-descriptive names

### 2. Present Findings

Show each opportunity with:
- Category and location (file:line)
- Specific suggestion
- Before/after code preview

Present the following:

> Found {N} refactoring opportunities. Which would you like to address?
>
> 1. **All** -- Apply all {N} refactorings incrementally
> 2. **None** -- Skip refactoring for now
> 3. **Let me choose** -- I will specify which items to address

**WAIT** for user response before continuing.

### 3. Apply Refactorings Incrementally

For each accepted refactoring:
1. Show before/after diff
2. Get user confirmation
3. Apply changes
4. **Run tests immediately** -- refactoring must not change behavior
5. If tests fail: rollback and skip this refactoring

> Note: Adjust test runner commands for your project (e.g., `npm test`, `pytest`, `cargo test`, `go test ./...`). Adjust commands for PowerShell on Windows where shell syntax differs.

### 4. Report Results

Summary of applied/skipped refactorings, lines reduced, complexity improvements.

```
=== REFACTORING REPORT ===

Applied: [N] of [M] opportunities

  [applied] #1 Code duplication -- extracted shared helper in utils.ts
  [applied] #2 Magic numbers -- replaced with named constants
  [skipped] #3 Complex conditional -- tests failed after simplification (rolled back)
  [applied] #4 Long function -- split into 3 focused functions

Lines reduced: [N]
Tests: All passing after applied refactorings
```

---

## Notes

- **Tests must pass** after each refactoring
- **Rollback on failure** -- if tests fail, undo changes
- **Incremental** -- one refactoring at a time, test after each

---

## Integration Points

- **Input**: Codebase with committed code
- **Output**: Refactored code, passing tests
- **Consumed by**: Ship workflow
