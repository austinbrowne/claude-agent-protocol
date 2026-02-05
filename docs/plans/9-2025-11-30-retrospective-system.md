# Product Requirements Document: Retrospective System

## Document Info

| Field | Value |
|-------|-------|
| **Title** | Retrospective System |
| **Author** | Claude (AI Coding Agent) |
| **Date** | 2025-11-30 |
| **Status** | `READY_FOR_REVIEW` |
| **Priority** | `Medium` |
| **Type** | `Enhancement` |

---

## 1. Problem

**What's the problem?**

GODMODE protocol lacks a structured mechanism to capture learnings after implementation. When Phase 2 completes, useful insights (what went well, what went wrong, time variance, unexpected challenges) are lost. This prevents continuous improvement and pattern recognition across multiple features.

**Who's affected?**
- Developers using GODMODE (can't improve from experience)
- Teams (no shared learning across projects)

**Evidence:**
- Comprehensive review identified retrospectives as medium-priority enhancement
- Integrates with Learning Loop (#6) for data-driven improvements

---

## 2. Goals

**Goals:**
1. Capture post-implementation learnings at Phase 2 completion
2. Track time analysis (estimated vs actual)
3. Identify what went well and what could improve
4. Feed insights into Learning Loop for pattern detection
5. Create searchable repository of retrospective insights

**Non-Goals:**
1. Team-wide retrospective meetings (individual focus for v1)
2. Automated retrospective generation without human input
3. Cross-project aggregation (single project focus)

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| Retrospectives completed | 0% of features | >80% |
| Actionable improvements captured | 0 | 3-5 per retrospective |
| Pattern detection enabled | No | Yes (via Learning Loop) |

---

## 3. Solution

Implement a Retrospective System integrated into Phase 2, Step 5 that captures: (1) What went well, (2) What went wrong, (3) Time variance analysis, (4) Bug analysis (caught in review vs production), (5) Actionable improvements. Data feeds into Learning Loop for pattern detection.

**Key Features:**

| Feature | Description | Priority |
|---------|-------------|----------|
| Retrospective Template | Structured prompts for post-implementation reflection | Must Have |
| Time Analysis Integration | Pull data from Complexity & Time Budgets (#5) | Should Have |
| Bug Analysis | Reference Learning Loop (#6) bug escape data | Should Have |
| Searchable Repository | Store in `docs/retrospectives/` with metadata | Should Have |

---

## 4. Technical Approach

**New Files:**
- `templates/RETROSPECTIVE_TEMPLATE.md` - Structured reflection prompts
- `docs/retrospectives/YYYY-MM-DD-feature-name.md` - Individual retrospectives

**Modified Files:**
- `AI_CODING_AGENT_GODMODE.md` - Add retrospective prompt at Phase 2, Step 5

**Dependencies:**
- Integrates with Complexity & Time Budgets (#5) for time data
- Integrates with Learning Loop (#6) for bug data

---

## 5. Implementation Plan

### Phase 1: Template & Integration — 3-4 hours

**Deliverables:**
- Retrospective template with prompts
- Integration into Phase 2, Step 5

**Acceptance Criteria:**
- [ ] Template includes: What went well, What went wrong, Time variance, Bug analysis, Improvements
- [ ] GODMODE Phase 2, Step 5 prompts for retrospective
- [ ] Retrospective saved to `docs/retrospectives/` with date + feature name

### Phase 2: Analysis & Patterns — 2-3 hours

**Deliverables:**
- Searchable metadata format
- Integration with Learning Loop data

**Acceptance Criteria:**
- [ ] Retrospectives include structured metadata (tags, time variance, bug count)
- [ ] Can grep/search across retrospectives for patterns
- [ ] Data format compatible with Learning Loop analysis

---

**Total Effort:** 5-7 hours

---

## 6. Test Strategy

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Usability** | Users complete retrospectives | 3 users | Clear prompts, easy to complete |
| **Integration** | Data flows to Learning Loop | All fields | Metadata compatible |

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Users skip retrospectives (not mandatory) | Medium | Medium | Keep template short (<10 min); show value (patterns over time) |
| Retrospectives become busywork | Low | Medium | Focus on actionable insights only |

---

**Status:** `READY_FOR_REVIEW`
