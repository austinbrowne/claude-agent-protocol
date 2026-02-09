---
type: comprehensive
title: "Agent Teams Integration — Tiered Strategy with Implementation Swarms"
date: 2026-02-05
status: ready_for_review
security_sensitive: false
priority: high
breaking_change: true
---

# Plan: Agent Teams Integration — Tiered Strategy with Implementation Swarms

## Document Info
- **Author:** AI + Austin
- **Date:** 2026-02-05
- **Status:** draft
- **Reviewers:** Austin
- **Branch:** `experimental/agent-teams` (all work on experimental branch)

## Problem

The protocol currently uses parallel subagents (Task tool) for all multi-agent work. Subagents are fire-and-forget: they run independently, produce output, and return results to the caller. There is **zero inter-agent communication**.

This creates four concrete problems:

1. **No cross-validation during reviews.** In `fresh-eyes-review`, 5-14 specialist reviewers analyze the same diff independently. They can't discuss overlapping findings. The Supervisor consolidates after the fact without the ability to ask clarifications.

2. **Research agents can't coordinate.** In `generate-plan` and `deepen-plan`, research agents work in isolation. The Codebase Researcher might discover an auth pattern that the Learnings Researcher should search for — but they never communicate.

3. **Adversarial Validators can't interrogate.** The Adversarial Validator sees static findings text. It can challenge claims but can't ask specialists for evidence or reasoning.

4. **Implementation is strictly sequential.** Plans with 6-10 independent implementation tasks are executed one at a time. There's no mechanism to parallelize implementation work while maintaining protocol quality (learnings, tests, validation).

Claude Code now ships Agent Teams as an experimental feature that solves all four problems: teammates have independent context windows, message each other directly, share a task list, and self-coordinate.

## Goals
- Upgrade `fresh-eyes-review`, `review-plan`, and `deepen-plan` to use Agent Teams for inter-agent discussion and live cross-validation
- Add swarm plan assessment to `/implement` workflow — analyze plan tasks for parallelizability, let user choose team or standard execution, teammates follow full protocol pipeline
- Add `/triage-issues` as standalone command — batch-triage open GitHub issues, parallel-plan sparse ones via subagents, get all issues to `ready_for_dev`
- Keep subagent-based execution as fallback when Agent Teams is disabled
- Keep `generate-plan`, `explore`, `start-issue` on subagents (fire-and-forget research doesn't justify team coordination overhead)
- Maintain backward compatibility — protocol works identically without Agent Teams enabled

## Non-Goals
- Full v5.0 rewrite of the entire protocol around teams
- Upgrading simple single-agent skills (brainstorm, learn, commit-and-pr)
- Building custom team orchestration infrastructure — we use Claude Code's built-in `TeamCreate` tool
- Optimizing token costs — teams are inherently more expensive; we accept this
- Changing agent definition files (`agents/review/*.md`, `agents/research/*.md`) — their prompts stay the same
- Automated merging or deployment — human in the loop at every gate

## Solution

Three capability tiers, all gated behind Agent Teams availability with subagent fallback:

### Tier 1: Review & Research Teams (Quality Improvement)

Upgrade existing multi-agent skills to use teams where inter-agent discussion adds value:

| Skill | Current | With Teams | Value |
|-------|---------|------------|-------|
| `fresh-eyes-review` | 5-14 parallel subagents → Supervisor → Adversarial | Review Team: specialists discuss findings, Lead asks clarifications, Lead challenges live | Fewer false positives, richer findings |
| `review-plan` | 4 parallel subagents → Adversarial | Plan Review Team: reviewers coordinate coverage, Lead interrogates | Better coverage, live debate |
| `deepen-plan` | 3-8 research + 6 review subagents (no cross-talk) | Research Team + Review Team with cross-communication | Reviews informed by research in real-time |

### Tier 2: Swarm Plan (Parallel Implementation)

New step integrated into the `/implement` workflow:

```
Plan approved → /implement → Swarmability Assessment
  → "6 tasks, 4 independent. Swarmability: 67%. Recommend: team mode."
  → User chooses: Team mode | Standard mode
  → If team: spawn teammates, each runs FULL protocol pipeline per task
  → If standard: existing sequential implementation (unchanged)
```

Each teammate runs the complete implementation protocol:
1. Load task context + plan reference
2. Search `docs/solutions/` for relevant learnings
3. Create living plan for their task
4. Write implementation code
5. Generate tests
6. Run validation (lint, type-check, tests)
7. Mark task complete

Fresh-eyes review does NOT happen per-teammate — it happens at the `/review` step on the **combined diff of all teammates' work**, catching integration issues holistically.

### Tier 3: Triage Issues (Batch Issue Readiness)

Standalone command for batch issue triage and planning (no implementation):

```
User has 10 open issues → /triage-issues
  → Triage: categorize as READY, NEEDS_PLANNING, or NOT_ELIGIBLE
  → Present categorized candidates
  → User selects which sparse issues to plan
  → Launch parallel subagents (Task tool) to enhance sparse issues
  → Collect plans, present for user approval
  → All issues now ready_for_dev on GitHub
  → User implements each issue separately: /implement → start-issue or swarm-plan
```

## Technical Approach

### Architecture

```
User invokes skill/workflow
    │
    ├─ Check: `TeamCreate` tool available in tool list?
    │   │
    │   ├─ YES → Team Mode
    │   │   ├─ Form team with named roles
    │   │   ├─ Shared task list for coordination
    │   │   ├─ Inter-agent messaging for discussion
    │   │   └─ Lead synthesizes and presents results
    │   │
    │   └─ NO  → Subagent Mode (existing behavior, unchanged)
    │
    └─ Output format identical regardless of execution path
```

### Detection Mechanism

Prompt-level detection — no code, no config files:

```
Check if the `TeamCreate` tool is available in your tool list.
  → Available: use [TEAM MODE] instructions
  → Not available: use [SUBAGENT MODE] instructions (existing behavior)
```

### Team Formation Patterns

**Pattern A: Review Team (fresh-eyes-review, review-plan)**
```
Lead = Coordinator + Supervisor + Adversarial Validator
Teammates = Specialist reviewers (one per domain)

Flow:
1. Lead spawns specialist teammates with review prompts
2. Specialists review independently, message each other about overlaps
3. Specialists broadcast CRITICAL findings immediately
4. Lead reads findings, asks specialists clarifying questions
5. Lead challenges findings (adversarial role)
6. Specialists respond with evidence or retract
7. Lead consolidates into final report
```

**Pattern B: Research + Review Team (deepen-plan)**
```
Lead = Coordinator + Consolidator
Research Teammates = Codebase, Learnings, Best Practices, Framework Docs
Review Teammates = Architecture, Simplicity, Security, Performance, Edge Case, Spec-Flow

Flow:
1. Lead spawns all teammates
2. Research teammates broadcast findings as discovered
3. Review teammates consume research findings, adjust their focus
4. Review teammates can request deeper research via messages
5. Lead synthesizes all findings into plan annotations
```

**Pattern C: Implementation Swarm (swarm-plan)**
```
Lead = Coordinator + Monitor
Teammates = Implementers (one per independent task group)

Flow:
1. Lead analyzes plan tasks for independence (file overlap, shared state, dependencies)
2. Lead presents swarmability assessment to user
3. User approves team formation
4. Lead spawns teammates, each assigned a task group
5. Each teammate runs full protocol: learnings → code → tests → validate
6. Teammates message each other about minor conflicts
7. Lead monitors progress, handles blockers
8. All teammates complete → user proceeds to /review
```

**Triage Issues (subagent-only, no Agent Teams)**
```
Lead = Coordinator + Triager
Subagents = Planners (one per sparse issue, via Task tool)

Flow:
1. Lead fetches open issues from GitHub via gh CLI
2. Lead triages into: READY (has plan/criteria), NEEDS_PLANNING (sparse), NOT_ELIGIBLE
3. Lead presents categorized candidates to user
4. User chooses: "Plan all sparse" / "Custom selection" / "Skip planning" / "Cancel"
5. Launch parallel planning subagents (Task tool) for sparse issues
   - Each explores codebase, generates plan, enriches issue, swaps to ready_for_dev
   - Subagents used because planners work independently — no inter-agent communication needed
6. Lead collects plan summaries, presents for user approval
7. All issues now ready_for_dev — triage complete
8. User implements each issue separately: /implement → start-issue or swarm-plan per issue
```

### Swarmability Assessment Algorithm

For Swarm Plan, the lead analyzes the plan's implementation steps:

```
For each pair of implementation tasks:
  1. Check file overlap — do they modify the same files?
  2. Check dependency — does task B depend on task A's output?
  3. Check shared state — do they modify the same data structures/configs?

Independence score per task:
  - No overlap with any other task → fully independent
  - Shares files with 1 task → partially dependent (serialize those two)
  - Depends on another task's output → blocked (must wait)

Swarmability score = (fully independent tasks / total tasks) × 100

Recommendation:
  - 70%+ → "Recommend team mode"
  - 40-69% → "Mixed — some tasks can parallelize, some must serialize"
  - <40% → "Recommend standard sequential mode"
```

The user always makes the final call.

### Branch Strategy

**Swarm Plan:** All teammates work on the **same feature branch**. Tasks are assigned to minimize file overlap (the whole point of swarmability assessment). If two tasks share a file, they're assigned to the same teammate or serialized. This keeps the branch model simple — one branch, one combined diff for review.

**Per-Issue Implementation (after triage):** Each issue gets its own branch via `start-issue` or `swarm-plan`: `feat/issue-{number}-{slug}`. One branch, one PR per issue. Each issue is implemented and reviewed independently.

### Data Flow

**Review teams (Tier 1):**
```
Current:  Specialists → [static outputs] → Supervisor → [static output] → Adversarial
Teams:    Specialists ↔ [live messaging] ↔ each other
          Specialists ↔ [clarifications] ↔ Lead (Supervisor + Adversarial role)
          Lead → [final report] → User
```

**Implementation swarms (Tier 2 & 3):**
```
Lead → [task assignments] → Teammates
Teammates → [progress updates, blockers] → Lead
Teammates ↔ [conflict resolution] ↔ each other
Teammates → [completion signals] → Lead → [summary] → User
User → /review → fresh-eyes-review on combined diff
```

## Implementation Steps

### Phase 1: Foundation — Reference guide + experimental branch

**Files:**
- NEW: `guides/AGENT_TEAMS_GUIDE.md`

**What:**
- Create experimental branch: `experimental/agent-teams`
- Write reference guide containing: detection mechanism, all 4 team formation patterns (A-D), teammate spawn prompt templates, shared task list patterns, swarmability assessment algorithm, fallback instructions, branch strategy, best practices
- All upgraded skills reference this guide instead of duplicating team instructions

### Phase 2: Upgrade `fresh-eyes-review` to team mode

**Files:**
- EDIT: `skills/fresh-eyes-review/SKILL.md`

**Changes:**
1. Add Step 0: Detect Execution Mode (`TeamCreate` tool check)
2. Add `[TEAM MODE]` Phase 1: Spawn specialist teammates (5 core + conditional based on smart selection). Each gets diff + agent definition reference. Teammates message each other about overlapping findings. Broadcast CRITICAL findings immediately.
3. Add `[TEAM MODE]` Phase 2: Lead acts as Supervisor — reads specialist findings from task list + messages, asks clarifying questions via direct messages, deduplicates and prioritizes.
4. Add `[TEAM MODE]` Phase 3: Lead acts as Adversarial Validator — challenges findings by messaging specialists for evidence. Specialists respond or retract. Lead produces final verdict.
5. Existing subagent path preserved as `[SUBAGENT MODE]` — zero changes to current behavior.
6. Output format (review report) identical for both modes.

**Key insight:** Supervisor and Adversarial Validator become Lead roles, not separate agents. The Lead can message specialists for live clarification — something separate subagents can't do. This reduces total agent count while improving quality.

### Phase 3: Upgrade `review-plan` to team mode

**Files:**
- EDIT: `skills/review-plan/SKILL.md`

**Changes:**
1. Add Step 0: Detect Execution Mode
2. Add `[TEAM MODE]` for Step 2: Spawn 4 specialist teammates (Architecture, Simplicity, Spec-Flow, Security). Teammates message each other about trade-offs. Lead monitors via task list.
3. Add `[TEAM MODE]` for Step 3: Lead acts as Adversarial Validator — challenges findings via direct messages, specialists defend or concede.
4. Existing subagent path preserved as `[SUBAGENT MODE]`.
5. Post-Review Actions section unchanged.

### Phase 4: Upgrade `deepen-plan` to team mode

**Files:**
- EDIT: `skills/deepen-plan/SKILL.md`

**Changes:**
1. Add Step 0: Detect Execution Mode
2. Add `[TEAM MODE]` Phase 2: Spawn research teammates (Codebase, Learnings, conditional Best Practices, conditional Framework Docs). Research teammates broadcast findings as discovered. Others pivot based on broadcasts.
3. Add `[TEAM MODE]` Phase 3: Spawn review teammates (Architecture, Simplicity, Security, Performance, Edge Case, Spec-Flow). Review teammates receive research findings accumulated so far. Can message research teammates for deeper dives. Cross-team communication enabled.
4. Add `[TEAM MODE]` Phase 4: Lead asks learnings researcher for detailed analysis via message (no additional subagent needed — teammate still active).
5. Existing subagent path preserved as `[SUBAGENT MODE]`.

### Phase 5: Swarm Plan — integrate into `/implement` workflow

**Files:**
- NEW: `skills/swarm-plan/SKILL.md`
- EDIT: `commands/implement.md`

**New skill `swarm-plan`:**
1. Load the approved plan
2. Extract implementation tasks with affected files
3. Run swarmability assessment: file overlap, dependencies, shared state
4. Present assessment to user via AskUserQuestion:
   - Swarmability score, task groupings, independence map
   - Options: "Use team mode (recommended)" / "Use standard sequential mode" / "Adjust task groupings"
5. If team mode:
   - Spawn implementation teammates (one per independent task group)
   - Each teammate's spawn prompt includes: their task description, affected files, plan reference, instruction to follow full protocol pipeline (search learnings, create living plan, write code, generate tests, run validation)
   - Lead monitors progress via shared task list
   - Teammates message Lead about blockers, message each other about minor file conflicts
   - Lead tracks completion, handles reassignment if a teammate gets stuck
6. If standard mode: proceed to existing `start-issue` skill (unchanged)
7. When all tasks complete: Lead presents summary, suggests user proceed to `/review`

**Changes to `commands/implement.md`:**
- Add "Swarm plan implementation" as an option in Step 1 (alongside existing "Start an issue", "Generate tests", etc.)
- Route to `skills/swarm-plan/SKILL.md`
- Only available when a plan exists and Agent Teams is enabled

### Phase 6: Triage Issues — batch triage and planning (no implementation)

**Files:**
- NEW: `skills/triage-issues/SKILL.md`
- EDIT: `commands/implement.md` (add as option)

**New skill `triage-issues` (subagent-only, no Agent Teams required):**
1. Fetch open issues from GitHub: `gh issue list --state open --json number,title,labels,body,assignees`
2. Triage and categorize each issue:
   - **READY**: Has `ready_for_dev` label or clear acceptance criteria, unassigned, unblocked, implementation-sized
   - **NEEDS_PLANNING**: Has `needs_refinement` label or sparse body, unassigned, unblocked, implementation-sized
   - **NOT_ELIGIBLE**: Assigned, blocked, too large, or insufficient info
3. Present categorized candidates to user via AskUserQuestion:
   - Show READY and NEEDS_PLANNING separately with counts
   - Options: "Plan all sparse issues" / "Custom selection" / "Skip planning" / "Cancel"
4. **Planning Phase (if NEEDS_PLANNING issues selected):**
   - Launch parallel planning subagents via Task tool (one per sparse issue)
   - Subagents used because planners work independently on separate issues — no inter-agent communication needed
   - Each explores codebase, searches learnings, generates plan, enriches GitHub issue, swaps label to `ready_for_dev`
   - Planning subagents do NOT implement — only plan and enhance
   - Lead collects plan summaries, presents for user approval
5. Present summary of all ready issues, suggest next steps

**Implementation is separate.** After triage, the user runs `/implement` for each issue — either sequentially or in parallel Claude Code tabs. Complex issues use `swarm-plan` for task decomposition; simple issues use `start-issue`.

**Key design: planning work persists.** Even if user cancels, the GitHub issues are already updated with enriched content and `ready_for_dev` labels. That work isn't lost.

### Phase 7: Documentation updates

**Files:**
- EDIT: `AI_CODING_AGENT_GODMODE.md` — Add Agent Teams section: tiered strategy, swarm capabilities, experimental status
- EDIT: `CLAUDE.md` — Add Agent Teams to reference files, mention swarm-plan and triage-issues skills
- EDIT: `README.md` — Add Agent Teams integration to features, new skills to skill table
- EDIT: `QUICK_START.md` — Note team mode availability, new swarm commands
- EDIT: `guides/MULTI_AGENT_PATTERNS.md` — Add team patterns alongside existing subagent patterns

### Phase 8: Version bump

**Files:**
- EDIT: `.claude-plugin/plugin.json` — Bump to 5.0.0-experimental
- EDIT: `.claude-plugin/marketplace.json` — Bump to 5.0.0-experimental, update description

**Why 5.0.0-experimental:** This is a paradigm shift (implementation swarms, inter-agent communication). Experimental tag signals instability. Stays on experimental branch until proven.

## Affected Files

**New files:**
- `guides/AGENT_TEAMS_GUIDE.md` — Team formation reference guide
- `skills/swarm-plan/SKILL.md` — Swarmability assessment + implementation swarm
- `skills/triage-issues/SKILL.md` — Batch issue triage and planning (subagent-only)

**Edited files:**
- `skills/fresh-eyes-review/SKILL.md` — Add team mode path
- `skills/review-plan/SKILL.md` — Add team mode path
- `skills/deepen-plan/SKILL.md` — Add team mode path
- `commands/implement.md` — Add swarm-plan and triage-issues options
- `AI_CODING_AGENT_GODMODE.md` — Agent Teams documentation
- `CLAUDE.md` — Reference updates, new skills listed
- `README.md` — Feature documentation, skill table
- `QUICK_START.md` — Quick reference updates
- `guides/MULTI_AGENT_PATTERNS.md` — New team patterns
- `.claude-plugin/plugin.json` — Version bump
- `.claude-plugin/marketplace.json` — Version bump

**Files NOT changed (intentionally):**
- `agents/review/*.md` — Agent definitions work as teammate prompts without modification
- `agents/research/*.md` — Same
- `skills/generate-plan/SKILL.md` — Stays on subagents (fire-and-forget research)
- `skills/explore/SKILL.md` — Stays on subagents
- `skills/start-issue/SKILL.md` — Stays on subagents (but IS used by swarm teammates internally)
- All other skills — No multi-agent orchestration to upgrade

## Acceptance Criteria

**Tier 1: Review & Research Teams**
- [ ] `fresh-eyes-review` uses team mode when `TeamCreate` tool is available, subagent fallback when not
- [ ] `review-plan` uses team mode when available, subagent fallback when not
- [ ] `deepen-plan` uses team mode when available, subagent fallback when not
- [ ] Review report output format identical regardless of execution mode
- [ ] Lead performs Supervisor + Adversarial roles in team mode (no separate agents needed)

**Tier 2: Swarm Plan**
- [ ] Swarmability assessment correctly identifies file overlap, dependencies, shared state
- [ ] User sees swarmability score and chooses team or standard mode
- [ ] Each teammate runs full protocol pipeline: learnings → living plan → code → tests → validate
- [ ] Teammates work on same branch with minimal file conflicts
- [ ] Fresh-eyes review happens at `/review` step on combined diff, not per-teammate
- [ ] Standard sequential mode (fallback) is identical to current behavior

**Tier 3: Triage Issues**
- [ ] GitHub issues fetched and triaged correctly via `gh` CLI
- [ ] Issues categorized: READY, NEEDS_PLANNING, NOT_ELIGIBLE
- [ ] User selects which sparse issues to plan
- [ ] Parallel subagents enhance sparse issues and swap labels to `ready_for_dev`
- [ ] Planning work persists on GitHub even if user cancels
- [ ] Summary presented with ready issues and implementation recommendations

**Infrastructure**
- [ ] `AGENT_TEAMS_GUIDE.md` exists and is referenced by all upgraded skills
- [ ] All work on `experimental/agent-teams` branch
- [ ] Documentation updated across reference files
- [ ] Version bumped to 5.0.0-experimental

## Test Strategy

**Tier 1 — Review Teams:**
- Manual: Enable Agent Teams, run `/fresh-eyes-review` on staged diff, verify teammates spawn and communicate
- Manual: Disable Agent Teams, run `/fresh-eyes-review`, verify identical v4.2 behavior
- Manual: Run `/review-plan` in team mode, verify specialist teammates form and lead performs adversarial validation
- Manual: Run `/deepen-plan` in team mode, verify research-review cross-communication
- Edge case: Empty diff → graceful handling in both modes
- Edge case: `TeamCreate` tool available but team formation fails → fallback to subagent mode

**Tier 2 — Swarm Plan:**
- Manual: Plan with 6 independent tasks → swarmability score ~100%, team mode recommended
- Manual: Plan with 3 highly coupled tasks → swarmability score <40%, standard mode recommended
- Manual: Mixed plan → partial independence, user sees accurate groupings
- Manual: Approve team mode → verify each teammate searches learnings, writes tests, runs validation
- Manual: Choose standard mode → verify existing sequential behavior unchanged
- Edge case: Teammate gets stuck → lead detects and handles (reassign or escalate)
- Edge case: File conflict between teammates → message exchange resolves it

**Tier 3 — Triage Issues:**
- Manual: Repo with 10 open issues, varying readiness → triage correctly categorizes
- Manual: Select sparse issues → subagents enhance and swap labels
- Manual: Planning summaries collected and presented for approval
- Edge case: No eligible issues found → clear message, skill ends
- Edge case: Issue too vague to even plan → subagent reports why
- Edge case: Issue is actually an epic → subagent flags it

## Security Review

- [x] N/A for most — no auth, no user data, no external APIs in review/research teams
- [x] `triage-issues` uses `gh` CLI which requires GitHub auth — inherits user's existing auth, no new credentials
- [x] No hardcoded secrets — team config uses Claude Code's built-in storage
- [x] No new dependencies — uses Claude Code's built-in Agent Teams feature
- [x] Permissions inherit from lead session — documented in guide
- [ ] Teammates should not be able to push to remote without user approval — verify permission inheritance

## Spec-Flow Analysis

### Primary Flow: Swarm Plan

1. User invokes `/implement` → Success: show options | Error: n/a
2. User selects "Swarm plan implementation" → Success: load plan | Error: no plan found, prompt user
3. Swarmability assessment runs → Success: score + groupings displayed | Error: assessment fails, recommend standard mode
4. User chooses team mode → Success: teammates spawn | Error: team formation fails, fallback to standard | Empty: user chose standard mode
5. Teammates execute protocol pipeline → Success: tasks complete | Error: teammate stuck, lead handles | Empty: n/a
6. Teammates message about conflicts → Success: resolved | Error: unresolvable, lead escalates to user
7. All complete → Success: summary presented | Error: partial completion, user informed
8. User proceeds to `/review` → Combined diff reviewed

### Primary Flow: Triage Issues

1. User invokes `/triage-issues` → Success: fetch issues | Error: `gh` CLI not configured
2. Triage issues → Success: candidates categorized | Error: no issues found | Empty: no eligible issues
3. User selects sparse issues to plan → Success: subagents launched | Empty: skip planning, show ready issues only
4. Subagents enhance and plan sparse issues → Success: plans collected | Error: subagent fails for one issue
5. User approves plans → Success: all issues ready_for_dev | Revise: re-launch subagents with feedback
6. Summary presented → User implements each issue via `/implement` per issue

### Alternative Flows

- **Fallback (all tiers):** `TeamCreate` tool not available → subagent mode, behavior identical to v4.2
- **Partial swarm:** User selects only 3 of 5 recommended issues → teammates spawn for 3 only
- **Mid-swarm abort:** User wants to stop → lead sends shutdown to all teammates, preserves completed work
- **CRITICAL finding in review team:** Teammate broadcasts CRITICAL → lead fast-tracks to adversarial validation

### Edge States

- **Agent Teams instability:** Feature is experimental — teammates may hang or fail to message. Skills handle gracefully with fallback.
- **Token exhaustion:** Teams use significantly more tokens. If teammate hits limits, lead synthesizes available findings and notes incomplete work.
- **Git conflicts (swarm-plan):** Minimized by swarmability assessment. If conflicts occur, teammates message each other to resolve. Unresolvable conflicts escalate to lead → user.
- **Git conflicts (triage-issues):** N/A — triage-issues only plans, does not create branches or write code.
- **Stale task status:** Known Agent Teams limitation. Lead nudges teammates if tasks appear stuck.

## Alternatives Considered

| Approach | Pros | Cons | Why Not |
|----------|------|------|---------|
| Approach 1: Teams for review only | Simplest, lowest risk | Misses implementation parallelization — the highest-value use case | Too conservative |
| Approach 3: Full v5.0 rewrite | Maximum coordination, cleanest architecture | Massive scope, breaks everything, experimental foundation | Over-engineering |
| Separate skill files (team vs subagent) | Clean separation | File duplication, maintenance burden, divergence risk | Single file with mode paths is simpler |
| Always use teams (no fallback) | Simpler code paths | Breaks for users without Agent Teams enabled | Feature is experimental — fallback mandatory |
| Each swarm teammate runs fresh-eyes-review | Maximum per-task quality | Massive token waste, review should be holistic on combined diff | Review at `/review` step is the right level |

## Past Learnings Applied

- (None found — agent teams is a new capability with no prior solutions in `docs/solutions/`)

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Agent Teams API changes (experimental) | High | High | Fallback always available; `AGENT_TEAMS_GUIDE.md` centralizes patterns for single-point updates |
| Token cost increase surprises users | Medium | Medium | Document costs in guide; teams only activate when user explicitly enables + approves |
| Swarm teammates create merge conflicts | Medium | High | Swarmability assessment minimizes overlap; same-branch strategy for swarm-plan |
| Skill files become complex with dual paths | Medium | Medium | Guide absorbs shared logic; skills only add mode-specific steps |
| Teammates skip protocol steps | Medium | High | Spawn prompts explicitly list every step; living plan tracks progress |
| Implementation quality drops with parallelism | Low | High | Each teammate runs full pipeline (learnings + tests + validation); `/review` catches integration issues |
| Stale task list blocks progress | Medium | Low | Known limitation; lead monitors and nudges |
| Team formation latency | Low | Medium | Teammates spawn quickly; parallel work compensates |

## Rollback Plan

1. Switch back to `main` branch — `experimental/agent-teams` changes are isolated
2. If partially merged: revert skill file changes to pre-team versions
3. Delete new files: `guides/AGENT_TEAMS_GUIDE.md`, `skills/swarm-plan/SKILL.md`, `skills/triage-issues/SKILL.md`
4. Revert documentation changes
5. Revert version bump
6. Verify all skills work in subagent-only mode (they should — fallback paths are the original behavior)

## Dependencies

- **Claude Code Agent Teams** — experimental feature, must be enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- **`TeamCreate` tool availability** — detection is prompt-based, no code dependency
- **`gh` CLI** — required for triage-issues (GitHub issue fetching). Already used by existing skills.
- **No new external dependencies**
