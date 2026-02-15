---
type: standard
title: "Unified Implementation Team with Autodetection"
date: 2026-02-15
status: complete
security_sensitive: false
priority: high
---

# Plan: Unified Implementation Team with Autodetection

## Problem

The `/implement` workflow presents a flat menu where users manually choose between `start-issue`, `swarm-plan`, and `triage-issues`. There's no intelligent routing — the user must understand when each path is appropriate. `swarm-plan` is the only team-based execution path, and it only handles multi-task plans with ad-hoc implementer prompts. There's no team path for single complex issues, and no formal agent role definitions that skills can compose.

The result: teams are underutilized. Most users default to `start-issue` (single-agent) even when their task would benefit from parallel work with an analyst researching while the implementer codes.

## Goals

- Define reusable implementation team agent roles in `agents/team/` that any skill can reference
- Replace `swarm-plan` with a unified `team-implement` skill that handles both plans and issues, composing the right team based on assessment
- Make `/implement` autodetect and recommend the best execution path instead of presenting a flat menu
- Preserve all existing swarm-plan functionality (swarmability assessment, parallel implementers, monitoring)

## Solution

Three-part change:

1. **Agent role definitions** (`agents/team/`): Formal role files following the same pattern as `agents/review/*.md`. Three roles: Lead, Implementer, Analyst. These are reusable building blocks — any skill can reference them.

2. **Unified `team-implement` skill**: Replaces `swarm-plan`. Accepts a plan OR an issue. Assesses complexity and composes the right team: Lead + Analyst + Implementer for complex single issues, Lead + N Implementers for independent plan tasks, or Lead + Analyst + N Implementers for complex plan tasks. Contains all swarmability assessment logic from the current swarm-plan.

3. **Updated `/implement` command**: Step 0 runs an enhanced assessment that scores the situation and recommends the best path. The menu still exists but the recommended option is first with "(Recommended)" suffix. No more flat menu where every option looks equal.

## Technical Approach

### Agent Role Pattern

Follow the existing convention from `agents/review/*.md` and `agents/research/*.md`:

```yaml
---
name: team-lead  # or team-implementer, team-analyst
model: inherit
description: One-line description
---
```

Sections: Philosophy, When to Invoke, Process, Output Format, Examples. Each role definition is a prompt fragment — skills compose them into spawn prompts.

### Team Composition Logic

The skill determines composition based on:

| Input | Signals | Composition |
|-------|---------|-------------|
| Issue, SMALL (1-2 files, clear criteria) | Low complexity | Recommend start-issue (no team) |
| Issue, MEDIUM (3-5 files, some unknowns) | Moderate complexity | Lead + Analyst + Implementer |
| Issue, LARGE (6+ files, architectural) | High complexity | Lead + Analyst + 2 Implementers (split by module) |
| Plan, high swarmability (70%+) | Independent tasks | Lead + N Implementers |
| Plan, moderate swarmability (40-69%) | Mixed independence | Lead + Analyst + N Implementers |
| Plan, low swarmability (<40%) | Highly coupled | Recommend start-issue (sequential) |

### Autodetection in /implement

Step 0 gathers signals:
- Plan existence + task count + swarmability quick-scan
- Issue complexity from body length, acceptance criteria count, estimated file count, labels
- TeamCreate availability

Step 1 uses signals to set the recommended option first in the AskUserQuestion. If TeamCreate isn't available, team-implement is omitted entirely (existing fallback behavior).

### Analyst Role Value

The analyst runs in parallel with implementers. Their job:
1. Search `docs/solutions/` for past learnings relevant to each task
2. Explore codebase for patterns the implementer should follow
3. Broadcast findings to implementers as discovered (not after completion)
4. Validate that implementation direction matches requirements

This is the key team advantage over subagents: mid-task information exchange. The analyst discovers "there's an existing utility at `src/utils/validate.ts` that does exactly this" and the implementer adjusts before building a duplicate.

## Implementation Steps

### Step 1: Create agent role definitions

Create `agents/team/` directory with three role files following the established agent definition pattern.

**Files created:**
- `agents/team/lead.md` — Coordination, monitoring, conflict resolution, task assignment, result synthesis. References the Lead patterns from AGENT_TEAMS_GUIDE.md Patterns A/B/C.
- `agents/team/implementer.md` — Code + tests + validation within file ownership boundaries. Full protocol pipeline per task. Based on the swarm-plan implementer prompt but formalized.
- `agents/team/analyst.md` — Parallel research support: codebase patterns, past learnings, impact analysis, requirements validation. Broadcasts findings to teammates in real-time.

### Step 2: Create `skills/team-implement/SKILL.md`

The unified team-based implementation skill. Absorbs all swarm-plan functionality plus:
- Accepts both plan files and issue numbers as input
- Assessment logic that determines team composition
- Uses defined roles from `agents/team/` in spawn prompts
- Mandatory AskUserQuestion gate for team composition approval

**File created:**
- `skills/team-implement/SKILL.md`

**Key sections:**
- Step 0: Detect Execution Mode (TeamCreate check — mandatory, from AGENT_TEAMS_GUIDE)
- Step 1: Load Input (plan path or issue number)
- Step 2: Assessment (swarmability for plans, complexity for issues)
- Step 3: Present Recommendation — MANDATORY GATE (AskUserQuestion with team composition, sequential, or adjust)
- Step 4: Spawn Team (using role definitions from `agents/team/`)
- Step 5: Monitor Progress (from swarm-plan Step 5)
- Step 6: Completion Summary

### Step 3: Delete `skills/swarm-plan/SKILL.md`

Remove the old skill. All its functionality is now in `team-implement`.

**File deleted:**
- `skills/swarm-plan/SKILL.md` (entire directory)

### Step 4: Update `commands/implement.md`

Enhance Step 0 with assessment logic. Replace flat menu with recommendation-based menu. Replace "Swarm plan" option with "Team implementation".

**File modified:**
- `commands/implement.md`
  - Step 0: Add complexity/swarmability assessment
  - Step 1: Recommended option first with "(Recommended)" suffix
  - Step 2: Route "Team implementation" to `skills/team-implement/SKILL.md`

### Step 5: Update `guides/AGENT_TEAMS_GUIDE.md`

- Add Pattern D: Issue Implementation Team (Lead + Analyst + Implementer)
- Update Pattern C to reference `team-implement` instead of `swarm-plan`
- Update skill assignments table (replace `swarm-plan` row with `team-implement`)
- Add "Team Role Definitions" section referencing `agents/team/*.md`

**File modified:**
- `guides/AGENT_TEAMS_GUIDE.md`

### Step 6: Update documentation and config

Update all references from `swarm-plan` to `team-implement` across:

**Files modified:**
- `CLAUDE.md` — Update skill lists, agent counts (21 -> 24: 17 review + 4 research + 3 team), skill name
- `QUICK_START.md` — Replace swarm-plan references with team-implement, update counts
- `AI_CODING_AGENT_GODMODE.md` — Update swarm-plan references
- `.claude-plugin/plugin.json` — Bump version to 5.4.0-experimental, update description with "24 agents (17 review + 4 research + 3 team)"
- `.claude-plugin/marketplace.json` — Bump version
- `README.md` — Update swarm-plan references
- `skills/triage-issues/SKILL.md` — Update "Followed by" reference
- `skills/generate-plan/SKILL.md` — Update any swarm-plan references
- `docs/solutions/workflow-issues/forward-only-status-transitions-20260214.md` — Update swarm-plan references

## Affected Files

**Created:**
- `agents/team/lead.md` — Team Lead role definition
- `agents/team/implementer.md` — Implementer role definition
- `agents/team/analyst.md` — Analyst role definition
- `skills/team-implement/SKILL.md` — Unified team implementation skill

**Deleted:**
- `skills/swarm-plan/SKILL.md` — Replaced by team-implement

**Modified:**
- `commands/implement.md` — Autodetection + recommendation menu
- `guides/AGENT_TEAMS_GUIDE.md` — New pattern, updated references
- `CLAUDE.md` — Updated counts and skill lists
- `QUICK_START.md` — Updated references and counts
- `AI_CODING_AGENT_GODMODE.md` — Updated references
- `.claude-plugin/plugin.json` — Version bump, updated description
- `.claude-plugin/marketplace.json` — Version bump
- `README.md` — Updated references
- `skills/triage-issues/SKILL.md` — Updated integration points
- `skills/generate-plan/SKILL.md` — Updated references (if any)
- `docs/solutions/workflow-issues/forward-only-status-transitions-20260214.md` — Updated references

## Acceptance Criteria

- [ ] Three agent role files exist in `agents/team/` following established pattern (frontmatter, philosophy, process, output format, examples)
- [ ] `team-implement` skill handles plan input (reproduces all swarm-plan behavior: swarmability assessment, parallel implementers, monitoring)
- [ ] `team-implement` skill handles issue input (complexity assessment, analyst + implementer composition)
- [ ] `team-implement` has mandatory AskUserQuestion gate for team composition approval
- [ ] `team-implement` has Step 0 with fresh TeamCreate detection (context pollution prevention)
- [ ] `team-implement` falls back to [SUBAGENT MODE] when TeamCreate unavailable
- [ ] `/implement` Step 0 runs assessment and recommends best path
- [ ] `/implement` Step 1 shows recommended option first with "(Recommended)" suffix
- [ ] All `swarm-plan` references replaced with `team-implement` across codebase
- [ ] `skills/swarm-plan/` directory removed
- [ ] Agent counts updated: 24 agents (17 review + 4 research + 3 team)
- [ ] Plugin version bumped to 5.4.0-experimental
- [ ] AGENT_TEAMS_GUIDE has Pattern D and updated skill assignments table

## Test Strategy

- **Manual flow test:** Run `/implement` and verify the recommendation logic produces correct suggestions for:
  - Simple issue -> recommends "Start issue"
  - Complex issue with TeamCreate -> recommends "Team implementation"
  - Plan with high swarmability + TeamCreate -> recommends "Team implementation"
  - No TeamCreate available -> "Team implementation" option absent
- **Reference integrity:** Grep for any remaining `swarm-plan` references after update
- **Skill invocation:** Verify `team-implement` is directly invocable as `/team-implement`
- **Edge cases:** `/implement` with no plans, no issues, no changes -> still shows triage-issues

## Security Review

- [ ] N/A — not security-sensitive (no auth, no user data, no external APIs)

## Past Learnings Applied

- **Context pollution (agent-teams-context-pollution.md):** Step 0 must check TeamCreate fresh every invocation. Conversation history is never a valid signal. Applied to team-implement Step 0.
- **AskUserQuestion gates (askuserquestion-gate-enforcement.md):** Team composition approval is a mandatory gate. Three-layer enforcement applied.
- **State-aware menus (state-aware-menu-transitions-20260209.md):** /implement Step 0 detects state from disk (plans, issues, git status, TeamCreate). Menu built dynamically. Applied to enhanced Step 0.
- **Direct workflow routing (direct-workflow-routing-20260206.md):** Routing to team-implement uses "Load and follow" not "Suggest user invoke." Applied to implement.md Step 2.
- **Forward-only status transitions (forward-only-status-transitions-20260214.md):** team-implement inherits the plan status guards from swarm-plan. Only updates to in_progress from approved/ready_for_review.

## Risks

- **Swarm-plan removal blast radius** — Medium likelihood, Medium impact. 12 files reference swarm-plan. Mitigation: systematic find-and-replace with grep verification after.
- **Team-implement complexity** — Low likelihood, High impact. The unified skill is more complex than swarm-plan alone since it handles both plans and issues. Mitigation: clear branching in the skill file (plan path vs issue path), each path is well-defined.
- **Autodetection accuracy** — Medium likelihood, Low impact. Complexity scoring heuristics may misjudge. Mitigation: it's a recommendation, not a gate. User can always override via "Other" or by selecting a different option.
