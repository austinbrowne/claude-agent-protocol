# Product Requirements Document: Learning Loop & Metrics

## Document Info

| Field | Value |
|-------|-------|
| **Title** | Learning Loop & Metrics |
| **Author** | Claude (AI Coding Agent) |
| **Date** | 2025-11-30 |
| **Status** | `READY_FOR_REVIEW` |
| **Priority** | `High` |
| **Type** | `Enhancement` |

---

## 0. Exploration Summary

**Files Reviewed:**
- `/Users/austin/.claude/AI_CODING_AGENT_GODMODE.md` - Main protocol
- `/Users/austin/.claude/guides/MULTI_AGENT_PATTERNS.md` - Fresh Eyes Review system
- `/Users/austin/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` - Security checklist (183 items)
- `/Users/austin/.claude/checklists/AI_CODE_REVIEW.md` - Code quality checklist (12 sections)
- Comprehensive review output - Identified "no learning loop" as primary weakness

**Existing Patterns:**
- **Fresh Eyes Review**: Multi-agent review with specialist findings
- **Supervisor Agent**: Consolidates findings, filters false positives
- **Checklists**: Comprehensive security and quality checklists
- **No feedback mechanism**: System doesn't learn from review patterns

**Constraints Found:**
- No tracking of what review agents find most often
- No measurement of false positive rates
- No mechanism to improve checklists over time
- Time/estimate tracking depends on Complexity & Time Budgets feature (PRD #2)

**Open Questions:**
- Should metrics be stored locally (JSON) or require database?
- How to measure "bug escape" (bugs found in production)?
- What's the minimum viable metric set for v1?

---

## 1. Problem

**What's the problem?**

The GODMODE protocol implements comprehensive review mechanisms (Fresh Eyes multi-agent review, OWASP Top 10 security checklist, 12-section code quality checklist) but operates as a static system without learning capability. When reviews find issues repeatedly (e.g., "missing null checks" flagged in 80% of reviews), the system doesn't adapt to emphasize these patterns. Similarly, when false positives occur, checklists aren't refined to reduce noise. This leads to:
- **Missed improvement opportunities**: No data on which checks catch the most bugs
- **False positive fatigue**: No tracking or reduction of incorrect findings
- **Static checklists**: Don't evolve based on actual issue patterns
- **Unknown effectiveness**: No metrics on review system value

**Who's affected?**
- **Primary**: Protocol maintainers (can't improve without data)
- **Secondary**: AI agents (repeat same mistakes without learning)
- **Tertiary**: Users (experience preventable issues)

**Evidence:**
- Comprehensive review identified "no learning loop" as critical weakness (#3 priority)
- Fresh Eyes Review (Pattern 6) generates findings but doesn't track patterns
- Supervisor agent filters false positives but doesn't record for analysis
- *Assumption*: Without metrics, protocol improvements are based on intuition, not data

---

## 2. Goals

**Goals:**
1. Track review effectiveness: What issues do Fresh Eyes reviews catch most frequently?
2. Measure false positive rate and improve review accuracy over time
3. Capture time-to-completion metrics to refine estimates (integrates with PRD #2)
4. Track bug escapes (issues found in production that reviews missed)
5. Auto-generate checklist improvement suggestions based on data
6. Reduce false positive rate by 30% within 20 reviews

**Non-Goals (out of scope):**
1. Real-time dashboards (simple reports sufficient for v1)
2. Machine learning models for predictions (rule-based improvements first)
3. Cross-project aggregation (single project focus for v1)
4. Automated checklist updates (suggestions only, human approval required)

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| Issues caught in review vs production | Unknown | 90% caught in review |
| False positive rate | Unknown | <10% of findings |
| Checklist improvements implemented | 0/quarter | 3-5/quarter |
| Review pattern visibility | None | Clear top 10 issues |

---

## 3. Solution

**Overview:**

Implement a Learning Loop & Metrics system that captures review findings, tracks patterns over time, measures effectiveness, and suggests improvements. The system operates in three layers: (1) Data capture during Fresh Eyes reviews, (2) Analysis and pattern detection, and (3) Feedback to improve checklists and procedures.

**Key Features:**

| Feature | Description | Priority |
|---------|-------------|----------|
| Review Findings Tracker | Capture all Fresh Eyes review findings with metadata | Must Have |
| False Positive Logging | Record when findings are marked as false positive | Must Have |
| Pattern Detection | Identify most common issue types (e.g., "null checks") | Must Have |
| Bug Escape Tracking | Log production issues that reviews missed | Should Have |
| Improvement Suggestions | Auto-generate checklist refinements from patterns | Should Have |
| Metrics Reports | Monthly summary of review effectiveness | Nice to Have |

**User Flow:**

**Stage 1: Data Capture (During Fresh Eyes Review)**
1. Fresh Eyes Review executes (Security Agent + Code Quality Agent + Supervisor)
2. Supervisor consolidates findings: 3 CRITICAL, 2 HIGH, 4 MEDIUM
3. **NEW**: Findings logged to `docs/metrics/review-findings.json`:
   ```json
   {
     "date": "2025-11-30",
     "issue": "#45",
     "findings": [
       {"severity": "CRITICAL", "type": "null-check-missing", "file": "auth.ts:67", "agent": "code-quality"},
       {"severity": "HIGH", "type": "sql-injection", "file": "users.ts:123", "agent": "security"}
     ]
   }
   ```
4. Agent implements fixes
5. **NEW**: User/agent marks if any findings were false positives:
   - "Finding #3 (magic-string) was false positive - constant was justified"

**Stage 2: Pattern Analysis (Weekly/Monthly)**
6. Analysis script (or manual review) processes `review-findings.json`
7. Generates pattern report:
   ```
   TOP ISSUES FOUND (Last 30 days):
   1. Missing null checks: 12 occurrences (35% of findings)
   2. SQL injection risk: 8 occurrences (24%)
   3. Missing error handling: 6 occurrences (18%)
   4. God Object: 4 occurrences (12%)
   5. Deep inheritance: 3 occurrences (9%)

   FALSE POSITIVE RATE: 8% (3 of 33 findings)
   - Magic strings: 2 false positives
   - Over-engineering: 1 false positive

   SUGGESTIONS:
   - Add null check emphasis to AI_CODE_REVIEW.md Section 3
   - Clarify magic string guidance (when constants are justified)
   ```

**Stage 3: Continuous Improvement**
8. Protocol maintainer reviews suggestions
9. Updates checklists based on data:
   - Emphasize null checks (most common issue)
   - Clarify magic string guidance (reduce false positives)
10. Track improvement: Did null check findings decrease after emphasis?

**Mockups:**

```
MONTHLY METRICS REPORT
Period: 2025-11-01 to 2025-11-30

REVIEWS CONDUCTED: 15 tasks

FINDINGS BY SEVERITY:
- CRITICAL: 8 (53% fixed before commit)
- HIGH: 12 (100% fixed before commit)
- MEDIUM: 18 (67% fixed)
- LOW: 14 (21% addressed)

TOP ISSUE TYPES:
1. null-check-missing (12 occurrences)
2. sql-injection (8)
3. error-handling-missing (6)
4. god-object (4)
5. deep-inheritance (3)

FALSE POSITIVES: 3 of 52 findings (5.8%)
- magic-string: 2
- over-engineering: 1

BUG ESCAPES (found in production): 2
- Off-by-one error (not caught in edge case tests)
- Race condition (not tested)

SUGGESTED IMPROVEMENTS:
✅ ACTIONABLE:
  1. Add null check reminder to GODMODE critical rules
  2. Clarify when magic strings are justified (domain constants ok)
  3. Add race condition testing to TEST_STRATEGY.md

📊 TRENDS:
  - Review effectiveness improving (bug escapes: 3 last month → 2 this month)
  - False positive rate stable (~6%)
  - Most common issue still null checks (educational opportunity)
```

---

## 4. Technical Approach

**Architecture:**

```
Fresh Eyes Review (Step 6)
    │
    ├─ Security Agent → Findings
    ├─ Code Quality Agent → Findings
    └─ Supervisor Agent → Consolidated Report
            │
            ├─ [NEW] Log to review-findings.json
            │
            └─ Present to user

Metrics Analysis (Weekly/Monthly)
    │
    ├─ Read review-findings.json
    ├─ Aggregate patterns
    ├─ Calculate metrics (top issues, false positive rate, trends)
    └─ Generate report + suggestions

Continuous Improvement Loop
    │
    ├─ Human reviews suggestions
    ├─ Updates checklists/GODMODE
    └─ Monitor: Did changes improve outcomes?
```

**Key Decisions:**

- **JSON storage** for simplicity (no database required)
  - *Rationale*: Easy to inspect, version control, migrate later if needed
- **Manual analysis** (v1), not automated dashboard
  - *Rationale*: Start simple, understand patterns before building tooling
- **Finding types taxonomy**: Predefined list (null-check, sql-injection, etc.)
  - *Rationale*: Enables aggregation; agents map findings to types
- **False positive marking**: Manual (user indicates which findings incorrect)
  - *Rationale*: Human judgment required; simple boolean flag

**New/Modified Files:**

| File | Type | Description |
|------|------|-------------|
| `docs/metrics/review-findings.json` | New | All review findings with metadata |
| `docs/metrics/bug-escapes.json` | New | Production bugs that reviews missed |
| `guides/LEARNING_LOOP.md` | New | How to use metrics, analysis procedures |
| `scripts/analyze-metrics.js` (or .py) | New | Generate pattern reports from JSON |
| `MULTI_AGENT_PATTERNS.md` | Modified | Add logging step to Pattern 6 (Fresh Eyes) |

**Dependencies:**
- Node.js or Python (for analysis script)
- JSON parsing (native to both)

---

## 5. Implementation Plan

### Phase 1: Data Capture — 4-6 hours

**Deliverables:**
- JSON schema for review findings
- Logging integration into Fresh Eyes Review (Pattern 6)
- False positive marking mechanism

**Acceptance Criteria:**
- [ ] `review-findings.json` schema defined with fields: date, issue, findings array, false_positives
- [ ] Each finding has: severity, type, file:line, agent, description
- [ ] Supervisor agent logs findings after consolidation
- [ ] User can mark findings as false positive (simple prompt)
- [ ] JSON file appends (doesn't overwrite)

---

### Phase 2: Pattern Analysis — 5-7 hours

**Deliverables:**
- Analysis script (Node.js or Python)
- Pattern detection logic
- Monthly report template

**Acceptance Criteria:**
- [ ] Script reads `review-findings.json`
- [ ] Calculates: top issue types, severity distribution, false positive rate
- [ ] Identifies trends (comparing time periods)
- [ ] Generates markdown report
- [ ] Report includes: metrics summary, top issues, false positives, suggestions

---

### Phase 3: Improvement Feedback Loop — 3-5 hours

**Deliverables:**
- Suggestion generation logic
- Integration guide for updating checklists
- Bug escape tracking

**Acceptance Criteria:**
- [ ] Script generates actionable suggestions (e.g., "Emphasize null checks in Section 3")
- [ ] Suggestions link to specific checklist sections
- [ ] Bug escape schema defined: date, issue, bug type, why missed
- [ ] Guide documents: How to use metrics → Update checklists → Measure impact
- [ ] Example improvement cycle documented

---

**Total Effort:** 12-18 hours

---

## 6. Test Strategy

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Data** | JSON logging works correctly | All writes | Data persists, no corruption |
| **Analysis** | Script correctly aggregates patterns | All calculations | Accurate counts, percentages |
| **Integration** | Logging doesn't disrupt review flow | Critical path | Reviews complete normally |
| **Usability** | Reports are actionable | User testing | 3 users can identify improvements |

**Test Scenarios:**
1. **10 reviews logged**: Verify JSON structure, pattern detection works
2. **False positive marking**: Mark 2 findings as FP, verify report shows 10% FP rate
3. **Bug escape**: Log production bug, verify appears in report
4. **Suggestion generation**: Run analysis, verify actionable suggestions produced

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Data privacy (sensitive code patterns logged) | Low | High | Log issue types only, not actual code; add .gitignore guidance |
| Manual false positive marking is burdensome | Medium | Medium | Keep simple (yes/no per finding); automate in v2 if needed |
| Metrics not actionable (unclear next steps) | Medium | High | Focus on top 5 issues; link suggestions to specific checklist sections |
| JSON becomes unwieldy with many reviews | Low | Medium | Implement rotation/archival after 100 reviews |

---

## 8. Performance Budget

**Not performance-critical** - Analysis runs offline (weekly/monthly), not during reviews.

---

## 9. Security Review

**Moderate security consideration** - Logs contain file paths and issue types.

- [ ] Authentication or authorization
- [x] Handling PII or sensitive data - *File paths and code patterns (low sensitivity)*
- [ ] External API integrations
- [ ] User input processing
- [ ] File uploads
- [ ] Database queries with user input

**Mitigation:**
- Don't log actual code snippets, only types and file:line references
- Add to `.gitignore` if storing sensitive project data
- Document privacy considerations in LEARNING_LOOP.md

---

## 10. Open Questions

| Question | Owner | Status |
|----------|-------|--------|
| Should we log actual code snippets for context? | Implementation | Resolved (No - privacy) |
| Weekly or monthly analysis cadence? | Human reviewer | Open |
| Integrate with GitHub Issues API to auto-detect bug escapes? | Future enhancement | Open |
| JSON vs SQLite for storage? | Implementation | Resolved (JSON v1, can migrate) |

---

## 11. Future Considerations

*Out of scope for this version, but worth noting:*
- **Real-time dashboard**: Web UI showing current metrics
- **ML-powered predictions**: "This code likely has null check issues" before review
- **Cross-project aggregation**: Learn from multiple codebases
- **Automated checklist updates**: AI suggests and applies checklist edits
- **Integration with Complexity Budgets**: Correlate complexity scores with issue frequency
- **GitHub API integration**: Auto-detect bug escapes from production issues

---

## 12. Implementation Phases for GitHub Issues

**Recommended issue breakdown:**

1. **Issue #1**: Data Capture (Phase 1) - 4-6 hours
2. **Issue #2**: Pattern Analysis (Phase 2) - 5-7 hours
3. **Issue #3**: Improvement Feedback Loop (Phase 3) - 3-5 hours

**Or single issue**: Learning Loop & Metrics (12-18 hours total)

**Recommendation**: Single issue for cohesive implementation, can create sub-tasks in issue description.

---

**Status:** `READY_FOR_REVIEW`

**Next Steps:**
1. Human review and approval
2. Create GitHub issue with this PRD
3. Proceed to implementation (Phase 1 of this PRD)

**Dependencies:**
- None for v1 (stands alone)
- *Recommended*: Implement after Complexity & Time Budgets (PRD #2) to capture time metrics
