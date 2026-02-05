---
name: refactor
version: "1.0"
description: Guided refactoring methodology for improving code quality
referenced_by:
  - commands/ship.md
---

# Refactoring Skill

Methodology for analyzing and applying guided refactoring to improve code quality.

---

## When to Apply

- After PR merged and feature complete
- Want to improve code quality (reduce duplication, complexity)

---

## Process

### 1. Analyze Code for Refactoring Opportunities

Scan for common code smells:

1. **Code duplication** — identical/similar blocks >5 lines
2. **Magic numbers** — hardcoded numbers without explanation
3. **Complex conditionals** — cyclomatic complexity >5, nested ifs >3 levels
4. **God objects** — classes >300 LOC or >10 methods
5. **Long functions** — functions >50 LOC or >3 responsibilities
6. **Poor naming** — single-letter variables, abbreviations, non-descriptive names

### 2. Present Findings

Show each opportunity with:
- Category and location (file:line)
- Specific suggestion
- Before/after code preview

Allow user to select which to address (all, none, or specific items).

### 3. Apply Refactorings Incrementally

For each accepted refactoring:
1. Show before/after diff
2. Get user confirmation
3. Apply changes using Edit tool
4. **Run tests immediately** — refactoring must not change behavior
5. If tests fail: rollback and skip this refactoring

### 4. Report Results

Summary of applied/skipped refactorings, lines reduced, complexity improvements.

---

## Notes

- **Tests must pass** after each refactoring
- **Rollback on failure** — if tests fail, undo changes
- **Incremental** — one refactoring at a time, test after each

---

## Integration Points

- **Input**: Codebase with committed code
- **Output**: Refactored code, passing tests
- **Consumed by**: `/ship` workflow command
