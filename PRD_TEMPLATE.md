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

**Estimated Effort:** [X hours]

**Risks:** [Key risk, if any]

**Status:** READY_FOR_REVIEW
```

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

## 6. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk] | High/Med/Low | High/Med/Low | [Strategy] |

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

## Approval

**Status:** `READY_FOR_REVIEW`

**Respond with:**
- `APPROVED_NEXT_PHASE` — Proceed to implementation
- `REVISION_REQUESTED` — Specify changes needed
- `HALT_PENDING_DECISION` — Blocked on [item]
