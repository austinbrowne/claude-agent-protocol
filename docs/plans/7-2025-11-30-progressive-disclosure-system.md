# Product Requirements Document: Progressive Disclosure System

## Document Info

| Field | Value |
|-------|-------|
| **Title** | Progressive Disclosure System |
| **Author** | Claude (AI Coding Agent) |
| **Date** | 2025-11-30 |
| **Status** | `READY_FOR_REVIEW` |
| **Priority** | `High` |
| **Type** | `Enhancement` |

---

## 0. Exploration Summary

**Files Reviewed:**
- `/Users/austin/.claude/README.md` - Entry point documentation
- `/Users/austin/.claude/QUICK_START.md` - Quick reference guide
- `/Users/austin/.claude/AI_CODING_AGENT_GODMODE.md` - Main protocol (438 lines)
- All 15 protocol files - Full ecosystem
- Comprehensive review output - Identified "steep learning curve" as adoption barrier

**Existing Patterns:**
- **QUICK_START.md** provides accessible entry point
- **Two entry points** (A and B) offer workflow flexibility
- **15 files** comprehensive but potentially overwhelming
- **Clear decision points** exist but require protocol knowledge

**Constraints Found:**
- New users must understand 15 files to use protocol effectively
- No guided first-run experience
- Expert users forced through same verbose workflow
- No interactive tutorials or wizards
- Assumes protocol familiarity from first use

**Open Questions:**
- Should beginner mode be default or opt-in?
- How much guidance before it becomes patronizing?
- Can expert mode coexist without fragmenting documentation?

---

## 1. Problem

**What's the problem?**

The AI Coding Agent Protocol provides comprehensive, production-ready guidance across 15 files totaling ~10,000 lines of documentation. While this depth is valuable for complex features, it creates a steep learning curve for new users and unnecessary friction for experienced users. First-time users must understand Phase structure, entry points, STOP checkpoints, status indicators, and file relationships before executing their first task. Expert users wade through verbose guidance they've internalized. This leads to:
- **High time-to-first-value**: 30-60 minutes reading before first task
- **Cognitive overload**: Too much information upfront
- **Expert friction**: Repetitive guidance slows experienced users
- **Adoption barriers**: Teams abandon protocol before seeing benefits

**Who's affected?**
- **Primary**: First-time users (steep learning curve)
- **Secondary**: Expert users (verbose workflow friction)
- **Tertiary**: Teams evaluating protocol (poor first impression)

**Evidence:**
- Comprehensive review identified "steep learning curve" as primary adoption barrier
- README notes "15 files to understand" for full protocol usage
- No "Quick Start in 5 Minutes" for simple tasks
- *Assumption*: Users abandon protocol after initial complexity exposure, never seeing advanced features

---

## 2. Goals

**Goals:**
1. Enable first-time users to complete a simple task in <10 minutes (vs current 30-60 min)
2. Provide guided first-run tutorial walking through Phase 0 → Phase 1 → Phase 2
3. Implement beginner mode with tooltips, explanations, and guardrails
4. Implement expert mode with streamlined workflow (minimal guidance)
5. Create visual decision trees for complex choices (ADR needed? Which PRD template?)
6. Reduce adoption abandonment rate by 50%

**Non-Goals (out of scope):**
1. Replacing existing documentation (modes augment, don't replace)
2. Automated mode switching (user chooses mode explicitly)
3. Web-based UI (CLI/markdown focus for v1)
4. Video tutorials (text-based for v1)

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| Time to first completed task (new users) | 30-60 min | <10 min |
| Tutorial completion rate | 0% (doesn't exist) | >70% |
| Expert user satisfaction | Unknown | >80% ("streamlined") |
| Protocol adoption rate (teams) | Unknown | +50% |

---

## 3. Solution

**Overview:**

Implement a Progressive Disclosure System that adapts protocol guidance to user experience level. The system provides three layers: (1) Beginner Mode with extensive guidance, tooltips, and interactive tutorials; (2) Expert Mode with streamlined workflows and minimal explanations; (3) Guided First-Run tutorial demonstrating complete Phase 0 → Phase 1 → Phase 2 cycle. Users explicitly choose their mode, with the option to switch at any time.

**Key Features:**

| Feature | Description | Priority |
|---------|-------------|----------|
| Beginner Mode | Tooltips on every step, explanations, examples, decision trees | Must Have |
| Expert Mode | Minimal guidance, assumes protocol knowledge, faster workflow | Must Have |
| Guided First-Run Tutorial | Interactive walkthrough of complete feature implementation | Must Have |
| Visual Decision Trees | When to use ADR? Lite vs Full PRD? Complexity scoring? | Should Have |
| Mode Switcher | Easy toggle between Beginner/Expert modes | Should Have |
| Quick Start for Simple Tasks | "5-Minute Quick Start" for trivial changes | Nice to Have |

**User Flow:**

**First-Time User Experience:**

1. User reads `/Users/austin/.claude/README.md`
2. README detects first run (checks for `~/.claude/.godmode-config.json`)
3. Prompts: "First time using GODMODE? [Start Tutorial] [Beginner Mode] [Expert Mode] [Learn More]"
4. User selects **[Start Tutorial]**

**Guided Tutorial (30-minute walkthrough):**
5. Tutorial: "Let's implement a complete feature together. We'll go through Phase 0 (Planning), Phase 1 (Execution), Phase 2 (Finalization)."
6. **Phase 0 Tutorial**:
   - "First, we explore the codebase. Let's add a simple feature: user logout button."
   - Guides through: Exploration → PRD generation → Human approval
   - Shows: "This is a Lite PRD because it's <4 hours. For complex features, use Full PRD."
7. **Phase 1 Tutorial**:
   - "Now we implement. We'll write code, generate tests, run security review, and create a PR."
   - Guides through each step with explanations
   - Shows: Fresh Eyes Review in action (explains multi-agent pattern)
8. **Phase 2 Tutorial**:
   - "Finally, we finalize: refactor, document, validate."
   - Guides through final steps
9. Tutorial complete: "🎉 You've completed your first GODMODE feature! Choose your mode: [Beginner] [Expert]"

**Beginner Mode (Ongoing):**
10. Every step includes:
    - ✨ **Tooltip**: "This step ensures security review happens before commit"
    - 📖 **Learn more**: Link to detailed guide
    - ✅ **Example**: "For auth code, security review is mandatory"
11. Decision points show visual trees:
    ```
    ┌─ Do I need an ADR? ─┐
    │                     │
    ├─ Major architectural decision? ──── YES → Create ADR
    ├─ Hard to reverse? ──────────────── YES → Create ADR
    ├─ Database/framework choice? ──────── YES → Create ADR
    └─ Simple enhancement? ──────────────── NO → Skip ADR
    ```

**Expert Mode:**
12. Streamlined workflow:
    - No tooltips
    - Minimal explanations
    - Assumes protocol knowledge
    - Direct to action (no "Why we do this" explanations)

**Example Comparison:**

**Beginner Mode (Phase 1, Step 6):**
```
### Step 6: Fresh Eyes Code Review

⚠️ STOP - MANDATORY CHECKPOINT

✨ What this does: Launches specialized review agents with NO conversation
   context for unbiased code review.

📖 Learn more: This uses the "Fresh Eyes" multi-agent pattern (Pattern 6)
   which eliminates confirmation bias by using agents that only see your
   code changes, not the implementation reasoning.

✅ Why it matters: Research shows AI often agrees with its own decisions.
   Fresh eyes catch issues you might miss.

You MUST read and execute:
`~/.claude/guides/MULTI_AGENT_PATTERNS.md` - Section "Pattern 6: Fresh Eyes Code Review"

[Continue] [Learn More About Multi-Agent Patterns] [Skip (Not Recommended)]
```

**Expert Mode (Phase 1, Step 6):**
```
### Step 6: Fresh Eyes Code Review

⚠️ STOP - MANDATORY CHECKPOINT

Read: `~/.claude/guides/MULTI_AGENT_PATTERNS.md` - Pattern 6

[Continue]
```

---

## 4. Technical Approach

**Architecture:**

```
User Entry Point (README.md)
    │
    ├─ Check: ~/.claude/.godmode-config.json exists?
    │   │
    │   ├─ NO → First-time flow
    │   │   ├─ Prompt: Tutorial / Beginner / Expert / Learn More
    │   │   └─ Save choice to config.json
    │   │
    │   └─ YES → Load mode from config
    │
    ├─ Beginner Mode
    │   ├─ Load: guides/BEGINNER_MODE.md (tooltips, examples)
    │   └─ Decision trees: templates/DECISION_TREES.md
    │
    ├─ Expert Mode
    │   └─ Load: Streamlined GODMODE (minimal guidance)
    │
    └─ Tutorial Mode
        └─ Load: guides/TUTORIAL.md (interactive walkthrough)
```

**Key Decisions:**

- **Config file for mode persistence**: `~/.claude/.godmode-config.json`
  - *Rationale*: Remember user preference across sessions
- **Separate beginner guidance files**: Not embedded in GODMODE
  - *Rationale*: Maintains attention budget optimization; loads just-in-time
- **Text-based tutorial** (not interactive CLI tool)
  - *Rationale*: Markdown-based for simplicity; can upgrade to interactive later
- **Decision trees in ASCII art**: Visual but text-compatible
  - *Rationale*: Works in any terminal, no special rendering needed

**New/Modified Files:**

| File | Type | Description |
|------|------|-------------|
| `guides/TUTORIAL.md` | New | Complete first-run tutorial (Phase 0 → 1 → 2) |
| `guides/BEGINNER_MODE.md` | New | Tooltips, explanations for all steps |
| `guides/EXPERT_MODE.md` | New | Streamlined workflow reference |
| `templates/DECISION_TREES.md` | New | Visual decision trees (ADR, PRD type, etc.) |
| `.godmode-config.json` | New | User preferences (mode, tutorial completed) |
| `README.md` | Modified | First-run detection and mode selection |
| `QUICK_START.md` | Modified | Add "5-Minute Quick Start" section |

**Dependencies:**
- None (pure documentation/markdown)

---

## 5. Implementation Plan

### Phase 1: Beginner Mode & Tutorial — 8-10 hours

**Deliverables:**
- Guided tutorial (Phase 0 → 1 → 2 walkthrough)
- Beginner mode guidance with tooltips
- Decision trees (ADR, PRD template, complexity)

**Acceptance Criteria:**
- [ ] `guides/TUTORIAL.md` complete with step-by-step simple feature implementation
- [ ] Tutorial uses concrete example (e.g., "add logout button")
- [ ] `guides/BEGINNER_MODE.md` provides tooltips for all Phase 1 steps
- [ ] Tooltips include: What, Why, Example for each step
- [ ] Decision trees created for: ADR needed? Lite vs Full PRD? Security review required?
- [ ] Trees use ASCII art (text-based)

---

### Phase 2: Expert Mode & Mode Switcher — 4-6 hours

**Deliverables:**
- Expert mode streamlined guidance
- Config file for mode persistence
- README integration for first-run detection

**Acceptance Criteria:**
- [ ] `guides/EXPERT_MODE.md` provides minimal guidance (assumes knowledge)
- [ ] `.godmode-config.json` schema: `{mode: "beginner"|"expert", tutorialCompleted: boolean, dateCreated}`
- [ ] README checks for config file on load
- [ ] First-run prompts: Tutorial / Beginner / Expert / Learn More
- [ ] Mode switching documented (edit config or re-run selection)

---

### Phase 3: Quick Start for Simple Tasks — 3-4 hours

**Deliverables:**
- "5-Minute Quick Start" guide
- Lite workflow for trivial changes
- Examples: typo fixes, comment additions, simple refactors

**Acceptance Criteria:**
- [ ] QUICK_START.md includes "Ultra-Quick Start (5 minutes)" section
- [ ] Workflow: Identify change → Make edit → Test → Commit (skip Phase 0)
- [ ] Clear scope: "Use this for changes <30 minutes, no architecture impact"
- [ ] Examples: typo fixes, adding comments, renaming variables
- [ ] When NOT to use: anything touching auth, data, external APIs

---

**Total Effort:** 15-20 hours

---

## 6. Test Strategy

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Usability** | New users complete tutorial | 5 users | >70% complete without getting stuck |
| **Content** | Tutorials are accurate | All steps | Each step tested manually |
| **Decision Trees** | Trees cover common scenarios | All decisions | 3 users validate tree logic |
| **Integration** | Mode switching works smoothly | All transitions | Config persists, modes load correctly |

**Test Scenarios:**
1. **First-time user**: No config exists → Prompted for mode → Tutorial completes → Mode set
2. **Beginner mode**: Tooltips present, decision trees accessible
3. **Expert mode**: Minimal guidance, no tooltips
4. **Mode switching**: Edit config → Reload → Correct mode active

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Beginner mode feels patronizing to experienced users | Medium | Medium | Make mode selection explicit; expert mode removes all tooltips |
| Tutorial becomes outdated as protocol evolves | High | Medium | Version tutorial with protocol (v3.1, v3.2, etc.); review quarterly |
| Fragmented documentation (beginner/expert splits) | Medium | Medium | Keep single source of truth (GODMODE); modes are views, not duplicates |
| Users skip tutorial, miss important concepts | Medium | High | Emphasize value ("learn in 30 min vs 3 hours trial-and-error") |

---

## 8. Performance Budget

**Not performance-critical** - Documentation loading has negligible impact.

---

## 9. Security Review

**Not security-sensitive** - This feature is educational documentation, no code/data handling.

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
| Should tutorial be optional or mandatory for first run? | Human reviewer | Open |
| Beginner mode default or expert mode default? | Human reviewer | Open (suggest beginner) |
| Video tutorial in addition to text? | Non-goal for v1 | Resolved |
| Interactive CLI wizard vs markdown tutorial? | Implementation | Resolved (markdown v1) |

---

## 11. Future Considerations

*Out of scope for this version, but worth noting:*
- **Interactive CLI wizard**: Run `godmode init` for guided setup
- **Video tutorials**: Screen recordings of protocol in action
- **Adaptive learning**: System detects user proficiency, suggests mode switch
- **Context-sensitive help**: `godmode help [command]` for inline assistance
- **Web-based UI**: Browser interface for protocol (future v4.0)
- **Community templates**: User-contributed decision trees, tutorials

---

## 12. Implementation Phases for GitHub Issues

**Recommended issue breakdown:**

1. **Issue #1**: Beginner Mode & Tutorial (Phase 1) - 8-10 hours
2. **Issue #2**: Expert Mode & Mode Switcher (Phase 2) - 4-6 hours
3. **Issue #3**: Quick Start for Simple Tasks (Phase 3) - 3-4 hours

**Or single issue**: Progressive Disclosure System (15-20 hours total)

**Recommendation**: Single issue for cohesive implementation, can create sub-tasks in issue description.

---

**Status:** `READY_FOR_REVIEW`

**Next Steps:**
1. Human review and approval
2. Create GitHub issue with this PRD
3. Proceed to implementation (Phase 1 of this PRD)

**Dependencies:**
- None (stands alone)
- *Synergy*: Decision trees complement Complexity Budgets (PRD #2) by helping users decide when to use scoring
