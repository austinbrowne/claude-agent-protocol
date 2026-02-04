# Product Requirements Document (PRD)

---

## Quick Start: Lite PRD

**Use this format for small-to-medium tasks. For complex features, use the full template below.**

```markdown
### [Feature Name]

**Problem:** [1-2 sentences describing the user problem]

**Solution:** [1-2 sentences describing the proposed fix]

**Success Metric:** [How we'll know it worked]

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Test Strategy:**
- Unit tests: [What to test]
- Integration tests: [What to test]
- (See `~/.claude/templates/TEST_STRATEGY.md` for details)

**Security Review:** [Required? Y/N]
- If yes, use `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md`

**Estimated Effort:** [X hours]

**Risks:** [Key risk, if any]

**Status:** READY_FOR_REVIEW
```

**See also:**
- Full PRD Template (below) for complex features
- `~/.claude/templates/TEST_STRATEGY.md` - Test guidance
- `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` - Security checklist
- `~/.claude/templates/ADR_TEMPLATE.md` - Architecture decisions

---

# Full PRD Template

## Document Info

| Field | Value |
|-------|-------|
| **Title** | [Feature Name] |
| **Author** | [Name] |
| **Date** | [YYYY-MM-DD] |
| **Status** | `DRAFT` / `READY_FOR_REVIEW` / `APPROVED` / `IN_PROGRESS` |
| **Priority** | `Critical` / `High` / `Medium` / `Low` |
| **Type** | `Feature` / `Bug Fix` / `Enhancement` / `Tech Debt` |

---

## 0. Exploration Summary

*Complete BEFORE proposing a solution.*

**Files Reviewed:**
- [Key files examined]

**Existing Patterns:**
- [How similar features are implemented]

**Constraints Found:**
- [Technical or business limitations]

**Open Questions:**
- [Uncertainties affecting the approach]

---

## 1. Problem

**What's the problem?**
[2-3 sentences. Be specific - cite data or observed behavior.]

**Who's affected?**
[Primary user/persona]

**Evidence:**
- [Link to user feedback, tickets, analytics, or competitor analysis]
- *If no evidence: explicitly label as assumption*

---

## 2. Goals

**Goals:**
1. [Specific, measurable outcome]
2. [Specific, measurable outcome]

**Non-Goals (out of scope):**
1. [What this will NOT do]

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| [Metric] | [Current] | [Goal] |

---

## 3. Solution

**Overview:**
[1 paragraph describing the solution and user experience]

**Key Features:**
| Feature | Description | Priority |
|---------|-------------|----------|
| [Feature] | [Brief description] | `Must Have` / `Should Have` / `Nice to Have` |

**User Flow:**
1. User does X
2. System responds with Y
3. User sees Z

**Mockups:** [Link to designs if available]

---

## 3a. Spec-Flow Analysis

*Systematic analysis of user flows for completeness.*

**User Flows Identified:**

| Flow | Type | Status |
|------|------|--------|
| [Primary flow] | Happy path | Complete / Gaps found |
| [Alternative flow] | Alternative | Complete / Gaps found |
| [Error flow] | Error | Complete / Gaps found |

**Flow Map:**
```
Flow 1: [Primary user flow]
Step 1: User does X → Success: Y | Error: Z | Empty: W
Step 2: System responds → Success: Y | Timeout: Z | Invalid: W
...
```

**States Checked Per Flow:**
- [ ] Happy path: fully specified
- [ ] Error states: failure handling at each step
- [ ] Empty states: no-data experience
- [ ] Edge states: unusual but valid inputs
- [ ] Permission states: unauthorized access handling
- [ ] Loading/transition states: async operation UX

**Gaps Found:**
- [Gap 1]: [No handling for X at Step Y]
- [Gap 2]: [Missing error state for Z]

---

## 4. Technical Approach

**Architecture:**
```
[Simple diagram or description]
```

**Key Decisions:**
- [Decision]: [Rationale]

**New/Modified Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/...` | [Description] |

**Dependencies:**
- [Library/service]: [Why needed]

---

## 5. Implementation Plan

### Phase 1: [Name] — [X hours]

**Deliverables:**
- [Deliverable 1]
- [Deliverable 2]

**Acceptance Criteria:**
- [ ] [Testable criterion]
- [ ] [Testable criterion]

---

### Phase 2: [Name] — [X hours]

**Deliverables:**
- [Deliverable 1]

**Acceptance Criteria:**
- [ ] [Testable criterion]

---

**Total Effort:** [X hours/days]

---

### Test Strategy

**See:** `~/.claude/templates/TEST_STRATEGY.md` for detailed guidance.

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Unit** | [Functions/classes] | >80% | [Criterion] |
| **Integration** | [API endpoints] | Critical paths | [Criterion] |
| **E2E** | [User flows] | Happy path + errors | [Criterion] |
| **Security** | [Auth, validation] | OWASP Top 10 | [Criterion] |
| **Performance** | [Endpoints, queries] | P95 < [X]ms | [Criterion] |

---

## 6. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk] | High/Med/Low | High/Med/Low | [Strategy] |

---

### Performance Budget

**See:** `~/.claude/templates/PERFORMANCE_BUDGET.md` for detailed guidance.

**Only include if performance-critical. Otherwise, skip this section.**

| Metric | Budget | Measurement | Risk if Exceeded |
|--------|--------|-------------|------------------|
| [Metric] | [Target] | [Tool] | `PERFORMANCE_IMPACT` / High / Medium |

**Example:**
- API response time (P95): <200ms (load testing)
- Bundle size increase: <50 KB (webpack-bundle-analyzer)
- Database query time (P95): <50ms (query logs)

---

### Security Review

**See:** `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` for detailed checklist.

**Include if this feature involves:**
- [ ] Authentication or authorization
- [ ] Handling PII or sensitive data
- [ ] External API integrations
- [ ] User input processing
- [ ] File uploads
- [ ] Database queries with user input

**If any boxes checked above:**
- Security review is MANDATORY before deployment
- Use AI_CODE_SECURITY_REVIEW.md checklist
- Flag as `SECURITY_SENSITIVE`

---

## 7. Open Questions

| Question | Owner | Status |
|----------|-------|--------|
| [Question] | [Who] | `Open` / `Resolved` |

---

## 8. Future Considerations

*Out of scope for this version, but worth noting:*
- [Future idea 1]
- [Future idea 2]

---

## 9. Architecture Decision Record (ADR)

**See:** `~/.claude/templates/ADR_TEMPLATE.md`

**Create an ADR if this feature involves:**
- [ ] Major architectural decision (database choice, framework, cloud provider)
- [ ] Significant tradeoffs between alternatives
- [ ] Decision that's hard to reverse
- [ ] Pattern that will be reused across codebase

**If creating ADR:**
- Document in `docs/adr/NNNN-title.md`
- Link ADR here: [Link to ADR]
- Include: Context, Decision, Consequences, Alternatives Considered

---

## 10. Rollback Plan

**See:** `~/.claude/procedures/ROLLBACK.md`

**Rollback strategy if deployment fails:**

**Code rollback:**
- [ ] `git revert [commit]` (preferred)
- [ ] Deploy previous tag `v[X.Y.Z]`
- [ ] Disable feature flag `FEATURE_NAME=false`

**Database rollback (if migrations):**
- [ ] Migration down script exists: `[migration file]`
- [ ] Database backup taken before deploy: [backup location]
- [ ] Rollback command: `[command]`

**Verification after rollback:**
- [ ] [Verification step 1]
- [ ] [Verification step 2]
- [ ] Monitor [key metric] for 30 minutes

**Communication:**
- Notify: [team channel, stakeholders]
- Incident lead: [name]

---

## Approval

**Status:** `READY_FOR_REVIEW`

**Respond with:**
- `APPROVED_NEXT_PHASE` — Proceed to implementation
- `REVISION_REQUESTED` — Specify changes needed
- `HALT_PENDING_DECISION` — Blocked on [item]
