# Product Requirements Document: Complexity & Time Budgets

## Document Info

| Field | Value |
|-------|-------|
| **Title** | Complexity & Time Budgets |
| **Author** | Claude (AI Coding Agent) |
| **Date** | 2025-11-30 |
| **Status** | `READY_FOR_REVIEW` |
| **Priority** | `High` |
| **Type** | `Enhancement` |

---

## 0. Exploration Summary

**Files Reviewed:**
- `/Users/austin/.claude/AI_CODING_AGENT_GODMODE.md` - Task complexity guide (lines 56-64)
- `/Users/austin/.claude/PRD_TEMPLATE.md` - Estimated effort field
- `/Users/austin/.claude/QUICK_START.md` - Workflow examples
- Comprehensive review output - Identified "no time budgets" as critical gap

**Existing Patterns:**
- **Task Complexity Guide** exists (Small <4hr, Medium 4-16hr, Complex >16hr)
- **Estimated Effort** field in PRD template
- **Phase structure** provides natural checkpoints
- No enforcement or tracking of estimates

**Constraints Found:**
- No mechanism to detect runaway execution
- No warnings when exceeding estimates
- No auto-suggest for decomposition
- Time tracking left to humans (if at all)

**Open Questions:**
- Should time tracking be automatic or manual?
- What threshold triggers "consider breaking this down"?
- How to estimate complexity for truly novel tasks?

---

## 1. Problem

**What's the problem?**

The GODMODE protocol provides task complexity classifications (Small, Medium, Complex) but lacks enforcement mechanisms and active guidance. When implementations exceed estimated time budgets, agents have no system to detect this, warn users, or suggest decomposition. This leads to:
- **Runaway execution**: Spending 20 hours on a "4-hour task" without realizing
- **No decomposition triggers**: Missing opportunities to break complex work into manageable pieces
- **Poor planning**: Future estimates don't improve from past actuals
- **Resource waste**: Continuing approaches that should be re-scoped

**Who's affected?**
- **Primary**: AI agents executing tasks without time awareness
- **Secondary**: Users managing time-boxed work (sprints, projects)
- **Tertiary**: Teams relying on predictable delivery times

**Evidence:**
- Comprehensive review identified "no time/complexity budgets" as primary gap (#2 priority)
- Existing complexity guide (lines 56-64) provides classification but no tracking
- PRD template includes "Estimated Effort" but no actual vs. estimate comparison
- *Assumption*: Without time awareness, agents optimize for completeness over efficiency

---

## 2. Goals

**Goals:**
1. Provide automated complexity scoring for tasks based on code analysis
2. Implement time budget warnings when implementations exceed estimates by 50%
3. Auto-suggest decomposition when complexity score exceeds threshold
4. Track estimated vs actual time for continuous improvement
5. Reduce time waste on over-scoped tasks by 30%

**Non-Goals (out of scope):**
1. Precise time predictions (estimates remain estimates)
2. Automatic task decomposition (human judgment required)
3. Enforcement of time limits (warnings only, not hard stops)
4. Billing or time tracking for business purposes

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| Tasks completing within 2x estimate | Unknown | >70% |
| Complex tasks decomposed before starting | 0% (no trigger) | >50% |
| User awareness of time overruns | Low (manual tracking) | High (automated warnings) |
| Estimate accuracy improvement over time | N/A | 20% improvement after 10 tasks |

---

## 3. Solution

**Overview:**

Implement a Complexity & Time Budget system that provides upfront complexity analysis, tracks time during execution, warns when budgets are exceeded, and suggests decomposition for over-scoped work. The system operates at three stages: (1) Pre-implementation complexity scoring, (2) In-progress time tracking with warnings, and (3) Post-implementation actual vs. estimate analysis.

**Key Features:**

| Feature | Description | Priority |
|---------|-------------|----------|
| Complexity Scoring | Automated analysis of task complexity (LOC estimate, files touched, dependencies) | Must Have |
| Time Budget Warnings | Alert when Phase 1 exceeds 150% of estimate | Must Have |
| Decomposition Suggestions | Recommend breaking task into subtasks when score >threshold | Must Have |
| Actual vs Estimate Tracking | Record actual time spent, compare to estimate | Should Have |
| Complexity Calculator | Interactive tool to score tasks during Phase 0 | Should Have |
| Budget Templates | Pre-defined budgets for common task types | Nice to Have |

**User Flow:**

**Stage 1: Pre-Implementation (Phase 0)**
1. User/agent describes task in PRD
2. Agent invokes complexity calculator:
   - Files to modify: 5
   - New dependencies: 2
   - Estimated LOC: 300
   - Security-sensitive: Yes
   - → **Complexity Score: 7/10 (Medium-High)**
3. Agent suggests estimate: "Based on complexity score, estimate 8-12 hours"
4. If score >8: "⚠️ High complexity. Consider breaking into smaller tasks?"
5. Estimate recorded in PRD

**Stage 2: During Implementation (Phase 1)**
6. Agent tracks time spent (or prompts user for checkpoint updates)
7. At Phase 1, Step 3 (after tests): Check time budget
   - Spent: 6 hours
   - Estimate: 8 hours
   - → ✅ Within budget
8. At Phase 1, Step 6 (code review): Check again
   - Spent: 13 hours
   - Estimate: 8 hours (162% over budget)
   - → ⚠️ **WARNING: Exceeded time budget by 62%. Consider:**
     - Simplify approach
     - Defer nice-to-have features
     - Break remaining work into new issue

**Stage 3: Post-Implementation**
9. Agent records actual time: 14 hours (vs 8 hour estimate)
10. Variance: +75% over estimate
11. Agent prompts: "Why did this take longer? [Architecture complexity / Requirements changed / Underestimated testing / Other]"
12. Learning captured for future estimates

**Mockups:**

```
COMPLEXITY CALCULATOR OUTPUT:

Task: "Implement OAuth login support"

Input Factors:
- Files to modify/create: 8 files
- New dependencies: 3 (passport, passport-google, express-session)
- Estimated LOC: 450
- Security-sensitive: YES
- External integrations: YES (Google OAuth API)
- Database changes: YES (add oauth_tokens table)

Complexity Score: 8.5/10 (High)

Suggested Estimate: 12-16 hours

⚠️ Recommendation: HIGH COMPLEXITY DETECTED
Consider breaking into phases:
  Phase 1: OAuth provider setup + basic login (6-8hr)
  Phase 2: Token refresh + logout (4-6hr)
  Phase 3: Link existing accounts (2-3hr)
```

---

## 4. Technical Approach

**Architecture:**

```
Phase 0: PRD Generation
    │
    ├─ Complexity Calculator (NEW)
    │  ├─ Analyze: files, LOC, dependencies, risk flags
    │  └─ Output: Score (1-10), Estimate (hours), Decomposition suggestion
    │
    └─ Record estimate in PRD

Phase 1: Implementation
    │
    ├─ Time Tracker (NEW)
    │  ├─ Start timestamp
    │  ├─ Checkpoints at Steps 3, 6, 7
    │  └─ Compare: actual vs budget
    │
    ├─ Budget Warning System (NEW)
    │  └─ If >150% budget: Warn + suggest actions
    │
    └─ Continue or adjust scope

Phase 2: Finalization
    │
    └─ Record actual time, variance, learnings
```

**Key Decisions:**

- **Complexity scoring algorithm**: Weighted factors (files × 2, LOC × 1, deps × 3, risk flags × 5)
  - *Rationale*: Dependencies and risk have disproportionate time impact
- **Warning threshold**: 150% of estimate (not 100%)
  - *Rationale*: Some variance is normal; 150% indicates significant overrun
- **Manual time tracking** (v1): Agent prompts for time updates at checkpoints
  - *Rationale*: Automatic tracking requires session state management (complex)
  - *Future*: Could integrate with actual execution time
- **Storage**: `docs/metrics/time-tracking.json` for historical data
  - *Rationale*: Simple JSON file, no database needed

**New/Modified Files:**

| File | Type | Description |
|------|------|-------------|
| `guides/COMPLEXITY_BUDGETS.md` | New | Complexity calculator, budget guidance |
| `AI_CODING_AGENT_GODMODE.md` | Modified | Add time checkpoints at Steps 3, 6, 7 |
| `templates/COMPLEXITY_CALCULATOR.md` | New | Interactive complexity scoring template |
| `docs/metrics/time-tracking.json` | New | Historical actual vs estimate data |
| `PRD_TEMPLATE.md` | Modified | Add complexity score field |

**Dependencies:**
- None (pure logic, no external tools)

---

## 5. Implementation Plan

### Phase 1: Complexity Calculator — 4-6 hours

**Deliverables:**
- Complexity scoring algorithm documented
- Interactive calculator template
- Integration with Phase 0 (PRD generation)

**Acceptance Criteria:**
- [ ] Scoring algorithm considers: files, LOC, dependencies, security, external APIs, DB changes
- [ ] Output includes: score (1-10), estimate range (hours), decomposition suggestion
- [ ] Threshold: score >8 triggers "consider breaking down" recommendation
- [ ] Calculator template has clear examples
- [ ] PRD template includes complexity score field

---

### Phase 2: Time Tracking & Warnings — 5-7 hours

**Deliverables:**
- Time checkpoints added to Phase 1 (Steps 3, 6, 7)
- Budget warning system
- Suggested actions when over budget

**Acceptance Criteria:**
- [ ] Agent prompts for time update at 3 checkpoints
- [ ] Comparison: actual vs estimated time
- [ ] Warning triggers at 150% of budget
- [ ] Warning includes: variance percentage, suggested actions (simplify, defer, decompose)
- [ ] User can acknowledge warning and continue or adjust scope

---

### Phase 3: Post-Implementation Analysis — 3-4 hours

**Deliverables:**
- Actual time recording
- Variance calculation
- Learning capture template
- Historical tracking in JSON file

**Acceptance Criteria:**
- [ ] Final actual time recorded at Phase 2 completion
- [ ] Variance calculated: (actual - estimate) / estimate × 100%
- [ ] Agent prompts: "Why variance?" with common reasons
- [ ] Data stored in `docs/metrics/time-tracking.json`
- [ ] Format: `{task, estimate, actual, variance, reason, date}`

---

**Total Effort:** 12-17 hours

---

## 6. Test Strategy

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Unit** | Complexity scoring algorithm | All factors | Correct scores for test cases |
| **Integration** | Calculator → PRD workflow | Critical path | Smooth Phase 0 integration |
| **Usability** | Developers can use calculator | User testing | 3 users score tasks correctly |
| **Data** | Time tracking JSON storage | All writes | Data persists correctly |

**Test Scenarios:**
1. **Simple task** (2 files, no deps): Score 2-3, estimate 2-4hr
2. **Medium task** (5 files, 1 dep, security): Score 5-6, estimate 6-10hr
3. **Complex task** (10 files, 3 deps, security, API): Score 8-9, estimate 12-20hr, decompose
4. **Budget warning**: Task estimated 8hr, actual 13hr → warning at 12hr (150%)

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Inaccurate complexity scoring | High | Medium | Iterative refinement based on actuals; user can override |
| Users ignore warnings | Medium | Medium | Make warnings actionable (specific suggestions); track ignore rate |
| Manual time tracking is burdensome | Medium | Low | Keep checkpoints minimal (3 per Phase 1); auto-track in future |
| Discourages ambitious projects | Low | High | Emphasize decomposition ≠ abandonment; large projects ok if scoped |

---

## 8. Performance Budget

**Not performance-critical** - Scoring happens once per task, negligible compute time.

---

## 9. Security Review

**Not security-sensitive** - This feature is analytical/procedural, doesn't handle code execution or data.

- [ ] Authentication or authorization
- [ ] Handling PII or sensitive data
- [ ] External API integrations
- [ ] User input processing
- [ ] File uploads
- [ ] Database queries with user input

---

## 10. Open Questions

| Question | Owner | Status |
|----------|-------|--------|
| Should time tracking be automatic (session-based) or manual? | Implementation | Resolved (manual v1, auto v2) |
| What's the right warning threshold (150% vs 200%)? | Human reviewer | Open |
| Should we track partial task completion (% done)? | Non-goal for v1 | Resolved |
| Integrate with Learning Loop (once implemented)? | Future | Open |

---

## 11. Future Considerations

*Out of scope for this version, but worth noting:*
- **Automatic time tracking**: Measure actual execution time without manual input
- **AI-powered estimation**: Learn from historical data to improve estimates
- **Partial completion tracking**: "This is 60% done" for better scope management
- **Integration with retrospectives**: Feed time data into retrospective analysis
- **Team-wide metrics**: Aggregate data across multiple developers/agents
- **Complexity trends**: Track if codebase complexity increasing over time

---

## 12. Implementation Phases for GitHub Issues

**Recommended issue breakdown:**

1. **Issue #1**: Complexity Calculator (Phase 1) - 4-6 hours
2. **Issue #2**: Time Tracking & Warnings (Phase 2) - 5-7 hours
3. **Issue #3**: Post-Implementation Analysis (Phase 3) - 3-4 hours

**Or single issue**: Complexity & Time Budgets (12-17 hours total)

**Recommendation**: Single issue for cohesive implementation, can create sub-tasks in issue description.

---

**Status:** `READY_FOR_REVIEW`

**Next Steps:**
1. Human review and approval
2. Create GitHub issue with this PRD
3. Proceed to implementation (Phase 1 of this PRD)
