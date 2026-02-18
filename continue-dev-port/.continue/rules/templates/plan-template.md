---
alwaysApply: false
description: "Plan template (minimal/standard/comprehensive tiers) — referenced by /generate-plan"
globs:
---

# Plan Template

Use this template when generating plans via `/generate-plan`. Select the appropriate tier based on task complexity.

---

## Tier Selection Guide

| Tier | When to Use | Indicators |
|------|-------------|------------|
| **Minimal** | Simple bugs, single-file changes, clear cause | <4 hours, single file, clear requirements |
| **Standard** | Multi-file features, moderate complexity | 4-16 hours, multiple files, some unknowns |
| **Comprehensive** | Architectural changes, high-risk, breaking changes | >16 hours, architectural decisions, security-sensitive |

---

## Minimal Plan

```markdown
---
type: minimal
title: "[Brief title]"
date: YYYY-MM-DD
status: draft | ready_for_review | approved | in_progress | complete
security_sensitive: true | false
---

# Plan: [Title]

## Problem
[What's broken or missing? Include reproduction steps for bugs.]

## Solution
[Concrete fix or change. Be specific about what changes and where.]

## Affected Files
- `path/to/file.ext` -- [What changes]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] Tests passing with required coverage

## Test Strategy
- [ ] [Specific test case -- happy path]
- [ ] [Specific test case -- edge case]
- [ ] [Specific test case -- error condition]

## Risks
- [Risk 1 -- mitigation]
```

---

## Standard Plan

```markdown
---
type: standard
title: "[Feature/change title]"
date: YYYY-MM-DD
status: draft | ready_for_review | approved | in_progress | complete
security_sensitive: true | false
priority: critical | high | medium | low
---

# Plan: [Title]

## Problem
[What problem does this solve? Who is affected? What's the impact?]

## Goals
- [Goal 1 -- measurable outcome]
- [Goal 2 -- measurable outcome]

## Solution
[High-level approach. What changes and why this approach was chosen.]

## Technical Approach
[Architecture patterns, key decisions, data flow. Reference existing codebase patterns.]

## Implementation Steps
1. [Step 1 -- specific action with affected files]
2. [Step 2 -- specific action with affected files]
3. [Step N -- specific action with affected files]

## Affected Files
- `path/to/file.ext` -- [What changes]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] Tests passing with required coverage
- [ ] Security review completed (if applicable)

## Test Strategy
- **Unit tests:** [Specific test cases]
- **Integration tests:** [Specific test cases]
- **Edge cases:** [null, empty, boundaries, errors]

## Security Review
- [ ] Authentication/authorization checked
- [ ] Input validation present
- [ ] No hardcoded secrets
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output encoding)
- [ ] N/A -- not security-sensitive

## Past Learnings Applied
[Relevant solutions from `docs/solutions/` found during research]
- [Solution 1]: [How it applies]
- (None found -- if no relevant learnings exist)

## Risks
- [Risk 1 -- likelihood, impact, mitigation]
- [Risk 2 -- likelihood, impact, mitigation]
```

---

## Comprehensive Plan

```markdown
---
type: comprehensive
title: "[Major feature/architectural change title]"
date: YYYY-MM-DD
status: draft | ready_for_review | approved | in_progress | complete
security_sensitive: true | false
priority: critical | high | medium | low
breaking_change: true | false
---

# Plan: [Title]

## Document Info
- **Author:** [Name/AI]
- **Date:** YYYY-MM-DD
- **Status:** draft | ready_for_review | approved
- **Reviewers:** [Names]

## Problem
[Detailed problem statement. Who is affected? What's the business impact? Include data/metrics if available.]

## Goals
- [Goal 1 -- measurable outcome]
- [Goal 2 -- measurable outcome]
- [Goal 3 -- measurable outcome]

## Non-Goals
- [Explicitly out of scope item 1]
- [Explicitly out of scope item 2]

## Solution
[Detailed solution description. Architecture overview, component interactions, data flow.]

## Technical Approach
[In-depth technical design. Reference existing codebase patterns. Include diagrams if helpful.]

### Architecture
[Component relationships, dependency direction, module boundaries.]

### Data Flow
[How data moves through the system. Input -> processing -> output.]

### API Design
[New or modified APIs. Request/response formats, status codes, versioning.]

## Implementation Steps
1. [Step 1 -- specific action with affected files and dependencies]
2. [Step 2 -- specific action with affected files and dependencies]
3. [Step N -- specific action with affected files and dependencies]

## Affected Files
- `path/to/file.ext` -- [What changes and why]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] Tests passing with >80% coverage
- [ ] Security review completed
- [ ] Performance benchmarks met
- [ ] Documentation updated

## Test Strategy
- **Unit tests:** [Specific test cases with expected inputs/outputs]
- **Integration tests:** [Specific test cases]
- **Edge cases:** [null, empty, boundaries, special characters, errors]
- **Performance tests:** [Benchmarks, load tests if applicable]
- **Security tests:** [Auth bypass attempts, injection tests if applicable]

## Security Review
- [ ] Authentication/authorization checked
- [ ] Input validation present (allowlist > blocklist)
- [ ] No hardcoded secrets
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output encoding)
- [ ] CSRF protection present
- [ ] Rate limiting considered
- [ ] PII/sensitive data handling reviewed
- [ ] External API calls secured

## Spec-Flow Analysis
[Enumerate all user flows from the Solution section]

### Primary Flow
1. [Step] -> Success: [outcome] | Error: [handling] | Empty: [state]
2. [Step] -> Success: [outcome] | Error: [handling] | Empty: [state]

### Alternative Flows
- [Alternative flow 1]
- [Alternative flow 2]

### Edge States
- [Permission denied state]
- [Loading/transition state]
- [First-use/onboarding state]
- [Concurrent access state]

## Alternatives Considered
| Approach | Pros | Cons | Why Not |
|----------|------|------|---------|
| [Alternative 1] | [Pros] | [Cons] | [Reason rejected] |
| [Alternative 2] | [Pros] | [Cons] | [Reason rejected] |

## Past Learnings Applied
[Relevant solutions from `docs/solutions/` found during research]
- [Solution 1]: [How it applies]
- [Solution 2]: [How it applies]
- (None found -- if no relevant learnings exist)

## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Mitigation strategy] |
| [Risk 2] | Low/Med/High | Low/Med/High | [Mitigation strategy] |

## Rollback Plan
[How to revert if the change causes problems in production]
1. [Rollback step 1]
2. [Rollback step 2]
3. [Verification after rollback]

## Dependencies
- [Internal dependency 1]
- [External dependency 1]
- [Blocking/blocked-by relationships]
```

---

**Filename convention:** `docs/plans/YYYY-MM-DD-type-name-plan.md`

**Examples:**
- `docs/plans/2026-02-04-minimal-fix-login-bug-plan.md`
- `docs/plans/2026-02-04-standard-user-auth-plan.md`
- `docs/plans/2026-02-04-comprehensive-api-redesign-plan.md`

**After GitHub issue creation:**
- Rename to prepend issue number: `NNN-YYYY-MM-DD-type-name-plan.md`
- Example: `docs/plans/123-2026-02-04-standard-user-auth-plan.md`
