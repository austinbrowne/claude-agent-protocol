---
description: "Generate tests with edge case coverage — happy path, null, empty, boundary, and error cases"
agent: implementer
tools: ['readFile', 'editFiles', 'codebase', 'runTests', 'textSearch']
argument-hint: "file or function to test"
---

Generate comprehensive tests for the specified code. Cover:

1. **Happy path** — normal expected behavior
2. **Null/undefined inputs** — missing or null parameters
3. **Empty collections** — [], {}, ""
4. **Boundary values** — 0, -1, MAX_INT, single element, empty string
5. **Error cases** — network failures, invalid input, permission errors
6. **Domain-specific edge cases** — based on the function's purpose

Follow existing test conventions in the project. Run tests after generating to verify they pass.
