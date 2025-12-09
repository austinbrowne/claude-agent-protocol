# Product Requirements Document: Failure Recovery Framework

## Document Info

| Field | Value |
|-------|-------|
| **Title** | Failure Recovery Framework |
| **Author** | Claude (AI Coding Agent) |
| **Date** | 2025-11-30 |
| **Status** | `READY_FOR_REVIEW` |
| **Priority** | `High` |
| **Type** | `Enhancement` |

---

## 0. Exploration Summary

**Files Reviewed:**
- `/Users/austin/.claude/AI_CODING_AGENT_GODMODE.md` - Main protocol (Phase 1 workflow)
- `/Users/austin/.claude/guides/MULTI_AGENT_PATTERNS.md` - Multi-agent coordination
- `/Users/austin/.claude/QUICK_START.md` - Entry points and workflows
- `/Users/austin/.claude/README.md` - Overall protocol structure

**Existing Patterns:**
- GODMODE has clear "happy path" workflows (Phase 0 → Phase 1 → Phase 2)
- Human approval gates exist at phase boundaries
- Git workflow integration present (branches, commits, PRs)
- Status indicators exist (READY_FOR_REVIEW, SECURITY_SENSITIVE, etc.)

**Constraints Found:**
- No explicit procedures for abandoning failed implementations
- No rollback guidance when Phase 1 fails
- No decision framework for "iterate vs abandon"
- No partial save/checkpoint restore mechanisms
- Git integration exists but recovery procedures not documented

**Open Questions:**
- How many retry attempts before suggesting abandon?
- Should rollback be automatic or require human approval?
- What constitutes a "failed" implementation vs "needs iteration"?

---

## 1. Problem

**What's the problem?**

The AI Coding Agent Protocol (GODMODE v3.1) provides comprehensive guidance for successful implementation workflows but lacks explicit procedures for handling failures. When implementations encounter critical issues (failing tests, unresolvable security vulnerabilities, architectural dead-ends), agents and users have no documented path for recovery, rollback, or graceful abandonment. This gap leads to:
- Time wasted on unrecoverable approaches
- Uncertainty about when to cut losses vs continue iterating
- No standardized rollback procedures
- Lost work when needing to backtrack

**Who's affected?**

- **Primary**: AI agents executing GODMODE protocol (stuck without recovery guidance)
- **Secondary**: Human developers using protocol (unclear decisions on abandon vs iterate)
- **Tertiary**: Teams relying on consistent outcomes (unpredictable failure handling)

**Evidence:**
- Comprehensive review identified "No failure recovery" as primary gap (missing from all 3 phases)
- Protocol provides 4 approval gates but zero abandon/rollback gates
- Git workflow integration exists (branches, commits) but recovery not documented
- *Assumption*: Users currently improvise recovery, leading to inconsistent outcomes

---

## 2. Goals

**Goals:**
1. Provide explicit rollback procedures for failed implementations (git commands, state restoration)
2. Create decision framework for "abandon vs iterate" with clear criteria
3. Enable checkpoint restore to return to last known good state
4. Support partial saves for work-in-progress that can't complete full phase
5. Reduce time wasted on unrecoverable approaches by 50%

**Non-Goals (out of scope):**
1. Automated failure detection (human judgment still required)
2. Preventing all failures (failures are normal, recovery is the goal)
3. Rollback of committed/merged code (only pre-merge recovery)
4. Undo/redo for individual file edits (git handles this)

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| Time from "this isn't working" to recovery decision | Unknown (improvised) | <5 minutes (documented procedure) |
| Abandoned implementations with reusable artifacts | 0% (lost work) | >70% (partial saves) |
| User confidence in failure handling | Low (no guidance) | High (clear procedures) |

---

## 3. Solution

**Overview:**

Implement a comprehensive Failure Recovery Framework integrated into GODMODE protocol that provides clear, actionable procedures when implementations fail. The framework includes: (1) Rollback procedures leveraging git commands, (2) Decision tree for abandon vs iterate decisions, (3) Checkpoint restore mechanisms returning to last known good state, and (4) Partial save strategies preserving useful work before abandoning.

**Key Features:**

| Feature | Description | Priority |
|---------|-------------|----------|
| Rollback Procedures | Step-by-step git commands to undo failed Phase 1 work | Must Have |
| Abandon vs Iterate Decision Tree | Visual decision framework with clear criteria for each path | Must Have |
| Checkpoint Restore | Return to Phase 0 approved state or last commit | Must Have |
| Partial Save Protocol | Commit useful discoveries/tests before abandoning approach | Should Have |
| Failure Classification | Categorize failures (technical, architectural, requirements) | Should Have |
| Recovery Templates | Pre-written git command sequences for common scenarios | Nice to Have |

**User Flow:**

**Scenario: Phase 1 implementation encounters critical issue**

1. Agent/user recognizes implementation is failing (tests won't pass, security unfixable, etc.)
2. Agent reads `~/.claude/guides/FAILURE_RECOVERY.md` (new file)
3. Agent evaluates failure using decision tree:
   - **Minor issue** (edge case, small bug): → Iterate (continue Phase 1)
   - **Moderate issue** (wrong approach, needs refactor): → Rollback to checkpoint, try different approach
   - **Critical issue** (architectural dead-end, requirements conflict): → Abandon, partial save, return to Phase 0
4. Agent executes appropriate recovery procedure:
   - **Rollback**: `git reset --hard HEAD` or `git reset --soft [checkpoint]`
   - **Partial save**: Commit useful artifacts (tests, discoveries) to branch
   - **Abandon**: Document learnings, close issue with explanation
5. Agent reports to user: "Implementation failed due to [reason]. Recovery: [action taken]. Next: [recommendation]."
6. System returns to appropriate state (Phase 0, Phase 1 start, or different approach)

**Mockups:**

```
DECISION TREE (text-based for now):

┌─ Implementation Issue Detected ─┐
│                                  │
├─ Can be fixed in <30min? ───────┼─ YES → Continue Phase 1 (iterate)
│                                  │
├─ NO                              │
│                                  │
├─ Is approach fundamentally flawed? ─┬─ YES → Abandon + Partial Save
│                                      │        → Return to Phase 0
│                                      │
├─ NO (fixable with different tactic) │
│                                      │
└─ Rollback to last checkpoint ───────┴─ Try alternative approach
   → Phase 1 restart with new strategy
```

---

## 4. Technical Approach

**Architecture:**

```
GODMODE Phase 1
    │
    ├─ Step 6: Fresh Eyes Review ── [Finds critical issues]
    │                                        │
    │                                        ↓
    │                              [NEW: Recovery Decision Point]
    │                                        │
    │                                        ├─ Minor → Continue
    │                                        ├─ Moderate → Rollback & Retry
    │                                        └─ Critical → Abandon + Partial Save
    │
    └─ [Recovery exits Phase 1]
                ↓
       Return to Phase 0 or retry Phase 1
```

**Key Decisions:**

- **Git-based recovery**: Leverage existing git infrastructure (no new state management)
  - *Rationale*: Already using git branches per issue, minimal new tooling
- **Human approval for abandon**: Require explicit approval before abandoning
  - *Rationale*: Prevents agents from giving up prematurely
- **Partial save via commits**: Use git commits with special prefix (`wip:`, `discovery:`)
  - *Rationale*: Preserves work even if full implementation abandoned
- **Decision tree in guide file**: Not embedded in GODMODE (attention budget)
  - *Rationale*: Consistent with v3.1 architecture (just-in-time loading)

**New/Modified Files:**

| File | Type | Description |
|------|------|-------------|
| `guides/FAILURE_RECOVERY.md` | New | Complete recovery procedures, decision tree |
| `AI_CODING_AGENT_GODMODE.md` | Modified | Add recovery decision point after Step 6 |
| `QUICK_START.md` | Modified | Add "What if implementation fails?" section |
| `templates/RECOVERY_REPORT.md` | New | Template for documenting failures |

**Dependencies:**
- Git (already required)
- gh CLI (already required for GitHub workflow)

---

## 5. Implementation Plan

### Phase 1: Core Recovery Procedures — 6-8 hours

**Deliverables:**
- `guides/FAILURE_RECOVERY.md` with rollback procedures
- Git command sequences for common scenarios
- Decision tree (text-based diagram)
- Recovery report template

**Acceptance Criteria:**
- [ ] Rollback procedure documented with git commands (hard reset, soft reset, stash)
- [ ] Partial save procedure with commit message convention
- [ ] Decision tree with 3 paths: Continue, Rollback & Retry, Abandon
- [ ] Each path has clear entry criteria (time thresholds, issue types)
- [ ] Recovery report template captures failure type, learnings, recommendations

---

### Phase 2: GODMODE Integration — 3-4 hours

**Deliverables:**
- Recovery decision point added to Phase 1 workflow
- STOP checkpoint for recovery evaluation
- Status indicator updates (add `RECOVERY_MODE`)

**Acceptance Criteria:**
- [ ] Phase 1, Step 6 includes recovery checkpoint (after Fresh Eyes Review)
- [ ] GODMODE references `guides/FAILURE_RECOVERY.md` at checkpoint
- [ ] New status: `RECOVERY_MODE` for implementations under evaluation
- [ ] QUICK_START.md includes "What if implementation fails?" FAQ

---

### Phase 3: Templates & Examples — 2-3 hours

**Deliverables:**
- Pre-written git command templates for 5 common scenarios
- 3 example recovery scenarios with step-by-step walkthroughs
- Failure classification guide (technical, architectural, requirements)

**Acceptance Criteria:**
- [ ] Templates for: failed tests, security issues, architectural mismatch, performance failure, requirements conflict
- [ ] Each template includes: git commands, decision rationale, next steps
- [ ] Example walkthroughs demonstrate decision tree usage
- [ ] Classification guide helps identify failure type

---

**Total Effort:** 11-15 hours

---

## 6. Test Strategy

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Documentation** | All procedures clearly written | 100% scenarios | Each procedure has example |
| **Integration** | Recovery fits into GODMODE flow | Critical paths | No workflow conflicts |
| **Usability** | Developers can execute recovery | User testing | 3 users successfully recover |
| **Git Commands** | All git sequences work correctly | All templates | Commands tested in sandbox |

**Test Scenarios:**
1. **Failed security review**: Execute abandon + partial save, verify artifacts preserved
2. **Performance failure**: Execute rollback & retry, verify clean state
3. **Minor bug**: Execute continue path, verify no unnecessary rollback
4. **Requirements conflict**: Execute abandon, verify proper documentation

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Users abandon too early (give up when should iterate) | Medium | Medium | Require human approval for abandon; decision tree emphasizes iteration |
| Git commands destructive if misused | Low | High | Clear warnings before destructive commands; suggest `git reflog` safety net |
| Complexity adds friction to workflow | Medium | Medium | Keep decision tree simple (3 paths max); integrate at natural checkpoint |
| Partial saves clutter git history | Low | Low | Use clear naming convention; document cleanup procedures |

---

## 8. Performance Budget

**Not performance-critical** - This is procedural documentation, no runtime impact.

---

## 9. Security Review

**Not security-sensitive** - This feature is procedural guidance, doesn't handle code, data, or auth.

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
| Should git stash be recommended vs hard reset? | Implementation | Open |
| How many retry attempts before suggesting abandon? | Human reviewer | Open |
| Should recovery report be auto-generated from git log? | Future enhancement | Open |
| Do we need automated failure detection hooks? | Non-goal for v1 | Resolved |

---

## 11. Future Considerations

*Out of scope for this version, but worth noting:*
- **Automated failure detection**: Hooks that trigger recovery evaluation
- **Learning from failures**: Track common failure types, suggest prevention
- **Recovery metrics dashboard**: Visualize recovery patterns over time
- **Pre-commit hooks** for validating partial saves
- **Integration with retrospective system** (capture learnings)

---

## 12. Implementation Phases for GitHub Issues

**Recommended issue breakdown:**

1. **Issue #1**: Core Recovery Procedures (Phase 1) - 6-8 hours
2. **Issue #2**: GODMODE Integration (Phase 2) - 3-4 hours
3. **Issue #3**: Templates & Examples (Phase 3) - 2-3 hours

**Or single issue**: Failure Recovery Framework (11-15 hours total)

**Recommendation**: Single issue for cohesive implementation, can create sub-tasks in issue description.

---

**Status:** `READY_FOR_REVIEW`

**Next Steps:**
1. Human review and approval
2. Create GitHub issue with this PRD
3. Proceed to implementation (Phase 1 of this PRD)
