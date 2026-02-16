# Product Requirements Document: GitHub Action Integration

## Document Info

| Field | Value |
|-------|-------|
| **Title** | GitHub Action Integration (Phase 2) |
| **Author** | Claude (AI Coding Agent) |
| **Date** | 2025-11-30 |
| **Status** | `READY_FOR_REVIEW` |
| **Priority** | `Low` |
| **Type** | `Enhancement` |

---

## 1. Problem

**What's the problem?**

Fresh Eyes Review currently runs locally in Claude Code during Phase 1, Step 6. While this provides immediate feedback, it lacks: (1) Fresh perspective for PRs created by local review, (2) Public team learning from review comments, (3) Consistency enforcement across all PRs, (4) Review for external contributors who don't use GODMODE locally.

**Who's affected?**
- Teams wanting PR-level reviews (public learning)
- External contributors (don't have local GODMODE)
- Projects requiring automated PR checks

**Evidence:**
- Comprehensive review recommended GitHub Action as Phase 2 enhancement
- Local review works well; GitHub Action complements (doesn't replace)
- Provides second pair of eyes on PRs

---

## 2. Goals

**Goals:**
1. Create GitHub Action that runs Fresh Eyes review on PR creation
2. Post review findings as PR comments (public, visible to team)
3. Reference review protocols from this repository (centralized)
4. Complement local review (catches what local review missed)
5. Enable consistent reviews across all PRs

**Non-Goals:**
1. Replacing local review (both work together)
2. Blocking PRs (comments only, human decides)
3. Complex ML-based analysis (use existing checklists)

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| Issues caught in PR review | Unknown | +10-20% vs local only |
| Team learning from public comments | Low | High (visible patterns) |
| External contributor code quality | Unknown | Meets standards |

---

## 3. Solution

Create GitHub Action (`austinbrowne/claude-agent-protocol/actions/code-review@main`) that runs Fresh Eyes review on PR creation. Action loads review protocols from this repository, analyzes PR diff, posts structured comments with findings. Complements local review by providing fresh perspective after code complete.

**Key Features:**

| Feature | Description | Priority |
|---------|-------------|----------|
| GitHub Action Workflow | Triggers on PR creation/update | Must Have |
| Protocol Reference | Loads checklists from this repo (centralized) | Must Have |
| PR Comment Integration | Posts findings as structured comments | Must Have |
| Severity Filtering | Only comment on CRITICAL/HIGH (reduce noise) | Should Have |

---

## 4. Technical Approach

**New Files:**
- `.github/workflows/code-review.yml` - GitHub Action workflow
- `actions/code-review/action.yml` - Reusable action definition
- `actions/code-review/review.js` (or .py) - Review logic

**Dependencies:**
- GitHub Actions (built-in)
- Claude API or similar (for agent execution)
- This repository (for protocol reference)

**Architecture:**
```
PR Created/Updated
    ↓
GitHub Action Triggers
    ↓
Load Review Protocols (from this repo)
    ↓
Analyze PR Diff
    ↓
Run Security + Code Quality Reviews
    ↓
Post Findings as PR Comments
```

---

## 5. Implementation Plan

### Phase 1: Action Definition — 4-6 hours

**Deliverables:**
- GitHub Action workflow
- Protocol loading logic

**Acceptance Criteria:**
- [ ] Action triggers on PR create/update
- [ ] Loads `AI_CODE_SECURITY_REVIEW.md` and `AI_CODE_REVIEW.md` from this repo
- [ ] Analyzes PR diff for review

### Phase 2: Review & Comment — 5-7 hours

**Deliverables:**
- Review execution
- PR comment posting

**Acceptance Criteria:**
- [ ] Runs security and code quality checks
- [ ] Posts findings as structured comments
- [ ] Comments link to specific lines in PR
- [ ] Only posts CRITICAL/HIGH severity (reduce noise)

---

**Total Effort:** 9-13 hours

---

## 6. Test Strategy

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Integration** | Action runs on PR | Test repo | Successful execution |
| **Output** | Comments are helpful | 3 PRs | Clear, actionable |

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| API costs for external PRs | Medium | Medium | Rate limit; require approval for external contributors |
| Comment noise (too many findings) | Medium | Medium | Filter to CRITICAL/HIGH only; consolidate similar findings |
| Action maintenance burden | Low | Medium | Version action with protocol; quarterly review |

---

## 8. Future Considerations

- Integration with Learning Loop (track PR review patterns)
- Auto-fix suggestions (not just comments)
- Custom review rules per repository

---

**Status:** `READY_FOR_REVIEW`
