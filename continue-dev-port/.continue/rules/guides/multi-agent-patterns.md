---
name: Multi-Step Workflow Patterns
description: Patterns for coordinating complex multi-step tasks including specialist decomposition, research-then-execute, review chains, parallel execution, and iterative refinement.
alwaysApply: false
---

# Multi-Step Workflow Patterns

**Purpose:** Coordinate complex tasks using structured workflow patterns.

**Key Insight:** Complex tasks benefit from structured decomposition and specialized perspectives, rather than trying to do everything in a single pass.

---

## When to Use Structured Workflows

**Use structured workflows when:**
- Task requires >15 hours of work
- Multiple domains involved (frontend + backend + database + DevOps)
- Parallel workstreams possible (independent modules)
- Research + implementation phases clearly separated

**Don't use when:**
- Simple tasks (<2 hours)
- Single domain (just frontend or just backend)
- Sequential dependencies (can't decompose)

---

## Pattern 1: Specialist Decomposition

**Concept:** Different phases for different domains, executed sequentially.

**Structure:**
```
Task: Build full-stack feature
  1. Architecture phase -> Design contracts, schema, component hierarchy
  2. Backend phase -> API endpoints, business logic
  3. Frontend phase -> React components, UI logic
  4. Database phase -> Schema design, migrations
  5. Integration phase -> Connect pieces, fix integration issues
  6. Review phase -> Security, performance, code quality
```

**Benefits:**
- Specialized context per phase (frontend work doesn't need backend context)
- Clear separation of concerns
- Each phase builds on prior phases' output

---

## Pattern 2: Research + Execute

**Concept:** Exploration phase researches, execution phase implements.

**Structure:**
```
Complex Task
  1. Explore phase -> Research codebase, gather context
  2. Plan phase -> Create detailed plan with all context gathered
  3. Execute phase -> Implement based on plan (doesn't re-explore)
```

**Benefits:**
- Separation of exploration and implementation
- Execute phase has clean, focused context (no exploration noise)
- Can retry execution without re-exploring

---

## Pattern 3: Review Chain

**Concept:** Multiple review perspectives applied sequentially.

**Structure:**
```
Implementation
  1. Security Review -> OWASP Top 10, input validation
  2. Performance Review -> Query optimization, bundle size
  3. Code Quality Review -> Readability, maintainability
  4. Test Coverage Review -> Are tests sufficient?
  5. Consolidation -> Aggregate feedback, prioritize
  6. Fix -> Address findings
  7. Re-review if needed
```

**Benefits:**
- Thorough review from multiple angles
- Specialized review context per perspective
- Automated quality gates

---

## Pattern 4: Parallel-Then-Merge

**Concept:** Independent tasks executed in sequence (conceptually parallel), then merged.

**Structure:**
```
Large Feature
  1. Execute Module A (independent)
  2. Execute Module B (independent)
  3. Execute Module C (independent)
  4. Integration pass -> Combine modules, resolve conflicts
```

**Use case:** Large refactoring, multi-module features

**Benefits:**
- Reduced context per task (each sees only their module)
- Clear ownership boundaries
- Scalable decomposition

---

## Pattern 5: Iterative Refinement

**Concept:** Feedback loop between implementation and review.

**Structure:**
```
  Draft -> Review -> Revision -> Review -> ...
  (repeat until quality threshold met)
```

**Benefits:**
- Continuous improvement
- Clear quality threshold
- Each iteration addresses specific feedback

---

## Orchestration Strategies

### Sequential Orchestration
```
Step 1 -> Step 2 -> Step 3 -> Done
```
Use when: Dependencies between steps (Step 2 needs Step 1's output)

### Phase-Based Orchestration
```
       Phase 1: Research
       Phase 2: Implement (multiple tasks)
       Phase 3: Review
       Phase 4: Fix
       Done
```
Use when: Clear phase boundaries with multiple tasks per phase

### Hub-and-Spoke
```
  Coordinator decomposes work
    -> Task A
    -> Task B
    -> Task C
  Coordinator merges results
```
Use when: Central coordination distributes work, aggregates results

---

## Communication Protocols

### Shared Context Store

Use files to share context between workflow phases:

```
.workflow/
  context.json        # Shared context
  exploration.md      # Exploration findings
  plan.md            # Implementation plan
  integration-log.md  # Integration notes
```

### Handoff Documents

Each phase produces a handoff document for the next:

```markdown
# Phase Handoff: [Phase Name]

## Completed
- [What was done]

## Outputs
- [Files created/modified]
- [Contracts defined]

## For Next Phase
- [What to build on]
- [Constraints to respect]
- [Open questions]
```

---

## Best Practices

### 1. Clear Phase Responsibilities

| Phase | Responsibility | Outputs |
|-------|----------------|---------|
| Explore | Understand codebase | Exploration summary |
| Plan | Create plan | Plan document |
| Execute | Implement code | Code, tests |
| Review | Security/quality review | Approval or feedback |

### 2. Minimize Inter-Phase Dependencies

Prefer loose coupling between phases. Each phase should have well-defined inputs and outputs.

### 3. Use Handoff Documents

Each phase produces structured output for the next phase to consume.

### 4. Specialize Perspectives

Don't create generic review passes. Specialize: Security Review (OWASP checklist), Performance Review (benchmarks), etc.

---

## Anti-Patterns

### 1. Too Many Phases
Coordination overhead exceeds benefit for simple tasks.

### 2. Duplicate Work
Multiple phases re-exploring the same codebase. Explore once, share context via handoff docs.

### 3. Integration Hell
Phases produce incompatible code. Solution: Define contracts upfront, use types, integrate early.

### 4. No Error Handling
One phase fails, entire workflow breaks. Solution: Retry logic, fallback strategies, clear error messages.
