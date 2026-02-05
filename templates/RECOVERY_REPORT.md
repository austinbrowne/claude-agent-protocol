# Recovery Report: [Feature Name]

**Date:** YYYY-MM-DD
**Issue:** #NNN
**Phase:** Phase 1, Step X
**Recovery Action:** `Rollback & Retry` | `Abandon`
**Time Spent:** X hours total

---

## Summary

[1-2 sentence summary of what failed and what action was taken]

---

## What Went Wrong

[Detailed description of the implementation failure. What was the critical issue that triggered recovery?]

**Symptoms:**
- [Observable problem 1: e.g., Tests failing on X]
- [Observable problem 2: e.g., Performance 10x too slow]
- [Observable problem 3: e.g., Security vulnerability unfixable]

---

## Root Cause Analysis

### Category
**Select one:**
- [ ] **Technical** - Wrong algorithm, data structure, library choice
- [ ] **Architectural** - Abstraction doesn't fit, wrong pattern
- [ ] **Requirements** - Misunderstood requirement, impossible constraint
- [ ] **Performance** - Can't meet performance requirement with approach
- [ ] **Security** - Can't meet security requirement with approach
- [ ] **External** - Third-party API limitation, browser limitation, framework limitation

### Root Cause
[Detailed explanation of the fundamental issue. Why did the approach fail?]

**Example:**
```
Root cause: Real-time synchronization requirement cannot be met with
current third-party API. API has 100 requests/min rate limit (discovered
during implementation), which is insufficient for real-time updates across
500+ users. Requirement assumed unlimited API calls.
```

---

## What We Tried

### Attempt 1: [Approach Name]
**Duration:** X hours
**What we did:** [Description of first approach]
**Why it failed:** [Specific reason for failure]

### Attempt 2: [Approach Name]
**Duration:** X hours
**What we did:** [Description of second approach]
**Why it failed:** [Specific reason for failure]

### Attempt 3: [Approach Name] (if applicable)
**Duration:** X hours
**What we did:** [Description of third approach]
**Why it failed:** [Specific reason for failure]

---

## What We Learned

### Technical Insights
- [Key technical insight 1]
- [Key technical insight 2]
- [Performance characteristic discovered]
- [API limitation discovered]

### Process Insights
- [What we should have done differently]
- [What we should have checked earlier]
- [What we should have questioned in Phase 0]

### Domain Knowledge Gained
- [Business rule learned]
- [User behavior insight]
- [Edge case discovered]

---

## Artifacts Preserved

### Reusable Code
- **File:** `path/to/file.js` (commit: `abc123`)
  - **What:** [Description of what this code does]
  - **Why preserved:** [Why it's useful for next attempt]

### Tests
- **File:** `path/to/test.js` (commit: `abc123`)
  - **Coverage:** [What these tests cover]
  - **Reusability:** [How these can be reused]

### Documentation
- **File:** `path/to/doc.md` (commit: `abc123`)
  - **Content:** [What's documented]
  - **Value:** [Why this is useful]

### Research/Discoveries
- **File:** `path/to/research.md` (commit: `abc123`)
  - **Findings:** [What was discovered]
  - **Implications:** [What this means for next attempt]

---

## Decision Rationale

### Why This Recovery Action?

**Decision:** [Rollback & Retry | Abandon]

**Rationale:**
[Explain why you chose this recovery action over alternatives]

**Example (Rollback & Retry):**
```
Chose Rollback & Retry because:
- Problem is solvable with different approach (use ORM instead of raw SQL)
- Requirements are clear and correct
- ~60% of code is reusable (data models, tests)
- Estimated 4 hours to reimplement with new approach
```

**Example (Abandon):**
```
Chose Abandon because:
- Real-time requirement fundamentally conflicts with API limitations
- No technical solution exists without changing requirements
- Spent 8 hours on 3 different approaches, all hit same limitation
- Need stakeholder to approve near-real-time (5-min delay) as acceptable
```

---

## Recommended Next Steps

### Immediate Actions
1. [Action 1: e.g., Return to Phase 0 to revise requirements]
2. [Action 2: e.g., Consult with stakeholder about API limitations]
3. [Action 3: e.g., Research alternative APIs/approaches]

### For Next Attempt
1. [What to do differently: e.g., Validate API rate limits in Phase 0]
2. [What to avoid: e.g., Don't assume unlimited API calls]
3. [What to verify early: e.g., Test performance with realistic data volume]

### Alternative Approaches to Explore
1. **Option A:** [Alternative approach 1]
   - **Pros:** [Benefits]
   - **Cons:** [Drawbacks]
   - **Effort:** [Estimated hours]

2. **Option B:** [Alternative approach 2]
   - **Pros:** [Benefits]
   - **Cons:** [Drawbacks]
   - **Effort:** [Estimated hours]

3. **Option C:** [Alternative approach 3]
   - **Pros:** [Benefits]
   - **Cons:** [Drawbacks]
   - **Effort:** [Estimated hours]

---

## Time Breakdown

| Phase | Time Spent | Notes |
|-------|------------|-------|
| Exploration (Phase 0) | X hours | [Notes on exploration phase] |
| First Attempt | X hours | [What was tried] |
| Second Attempt | X hours | [What was tried] |
| Third Attempt | X hours | [What was tried] |
| Recovery Documentation | X hours | [Time spent on this report] |
| **Total** | **X hours** | |

**Time Lost:** X hours (time that yielded no reusable artifacts)
**Time Saved for Next Attempt:** X hours (time saved by preserved artifacts)

---

## Checklist Before Closing

- [ ] Root cause clearly identified
- [ ] All attempts documented
- [ ] Learnings captured
- [ ] Useful artifacts preserved (committed to git)
- [ ] Alternative approaches identified
- [ ] Next steps clear
- [ ] Issue updated with recovery status
- [ ] Stakeholders notified (if applicable)

---

## Git References

**Branch:** `issue-NNN-feature-name`
**Partial Save Commit:** `[commit hash]`
**Recovery Report Commit:** `[commit hash]`

**Recovery commands executed:**
```bash
[Paste actual git commands used for recovery]
```

---

## Links

- **Original Issue:** #NNN
- **Original Plan:** `docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md`
- **Related Issues:** [List any related issues]

---

**Report Author:** [Your name or AI agent]
**Status:** `RECOVERY_MODE` → `RETURNED_TO_PHASE_0` | `RETRYING_PHASE_1`
