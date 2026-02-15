---
type: standard
title: "Compound Engineering Pattern Integration"
date: 2026-02-14
status: complete
security_sensitive: false
---

# Plan: Compound Engineering Pattern Integration

## Problem

Four patterns from compound-engineering would improve our plugin:
1. Plan files don't track lifecycle status after creation
2. Subagents in orchestration skills can write intermediary files, polluting the workspace
3. Fresh-eyes-review agent roster is hardcoded — no per-project customization
4. No skill exists for reviewing plan/brainstorm document quality

## Goals

- Plans track their full lifecycle: draft → approved → in_progress → complete
- Subagents are explicitly prohibited from writing files in all orchestration skills
- Users can configure which review agents run per project
- A document-review skill enables structured quality review of plans and brainstorms

## Solution

### Task 1: Plan Status Lifecycle Transitions

Add status updates to the skills that operate on plans:

| Transition | Where | Command |
|-----------|-------|---------|
| `draft` → `ready_for_review` | `skills/generate-plan/SKILL.md` Step 7 | Set when saving plan |
| `ready_for_review` → `approved` | `skills/review-plan/SKILL.md` post-review | Set when user accepts review |
| `approved` → `in_progress` | `skills/start-issue/SKILL.md` Step 4 | Set when implementation begins |
| `approved` → `in_progress` | `skills/swarm-plan/SKILL.md` Step 4 | Set when swarm begins |
| `approved` → `in_progress` | `commands/loop.md` Phase 2 | Set when loop starts implementing |
| `in_progress` → `complete` | `skills/finalize/SKILL.md` Step 8 | Set when finalize completes |

**Files:** generate-plan, review-plan, start-issue, swarm-plan, loop command, finalize SKILL.md files (6 files). Also update `commands/implement.md` Step 0 state detection to grep for `status: approved` or `status: in_progress` plans.

### Task 2: Subagent File-Write Prohibition

Add an explicit rule to all skills that spawn subagents for research or review. The prohibition goes into the subagent prompt, not the skill body — subagents are the ones who need to see it.

**Pattern to add to subagent prompts:**
```
CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.
```

**Files to update (subagent prompt sections):**
- `skills/fresh-eyes-review/SKILL.md` — review agent prompts
- `skills/deepen-plan/SKILL.md` — research agent prompts
- `skills/review-plan/SKILL.md` — review agent prompts
- `skills/explore/SKILL.md` — research agent prompts
- `skills/generate-plan/SKILL.md` — research agent prompts

### Task 3: Per-Project Review Config

Add a `godmode.local.md` config file mechanism. When fresh-eyes-review runs, it checks for this file first. If present, it uses the configured agents. If missing, it uses the default smart-selection algorithm.

**Config file:** `godmode.local.md` (project root, gitignored)

```markdown
---
review_agents: [security-reviewer, edge-case-reviewer, performance-reviewer]
plan_review_agents: [architecture-reviewer, simplicity-reviewer]
review_depth: thorough  # fast | thorough | comprehensive
---

## Project Review Context
Additional context for review agents (e.g., "This is a Rails API, focus on N+1 queries")
```

**New skill:** `skills/setup/SKILL.md` — Interactive setup that:
1. Auto-detects project type from file markers (package.json → JS/TS, Gemfile → Ruby, etc.)
2. Offers auto-configure (recommended agents for detected stack) or customize
3. Writes `godmode.local.md`

**Files to update:**
- `skills/fresh-eyes-review/SKILL.md` — Read `godmode.local.md` before Step 2 trigger detection. If config exists, use configured agents instead of smart-selection.
- `skills/review-plan/SKILL.md` — Read `plan_review_agents` from config if present.
- `.gitignore` (or instruct users to add) — `godmode.local.md` since it's project-local

### Task 4: Document Review Skill

New skill for structured quality review of plan and brainstorm documents.

**New file:** `skills/document-review/SKILL.md`

Process:
1. **Get document** — user provides path or skill auto-detects most recent plan/brainstorm
2. **Assess** — Reflective questions: What is unclear? What is unnecessary? What decision is being avoided? What assumption is untested?
3. **Score** — Rate on 4 dimensions: clarity, completeness, specificity, YAGNI compliance (1-5 each)
4. **Identify critical improvement** — Single most impactful change
5. **Apply changes** — Auto-fix minor issues (formatting, clarity). AskUserQuestion for substantive changes.
6. **Offer next action** — Refine again / Review complete

**Integration points:**
- `commands/plan.md` Step 3 — Add "Review document quality" option after generating a plan
- `commands/explore.md` — Add "Review brainstorm" option after brainstorming

### Task 5: Strengthen Cross-Workflow Routing

When one workflow command routes to another (e.g., `/plan` Step 3 → "Start implementing" → `/implement`), the LLM reads `commands/implement.md` but then freestyles past the AskUserQuestion gates. The "Load and follow" instruction is too weak.

**Fix:** Strengthen all cross-workflow routing instructions in all 7 command files:

```
"Start implementing" → Load commands/implement.md and execute starting from Step 0.
  Do NOT skip any steps. Do NOT implement directly. Follow the command file exactly.
```

**Files:** All 7 `commands/*.md` files — every routing entry that references another command.

## Implementation Steps

- [ ] Task 1: Plan status lifecycle — add status transitions to 6 skill files + implement.md state detection
- [ ] Task 2: Subagent file-write prohibition — add prohibition to subagent prompts in 5 skills
- [ ] Task 3a: Create `skills/setup/SKILL.md` for per-project config
- [ ] Task 3b: Update fresh-eyes-review and review-plan to read `godmode.local.md`
- [ ] Task 4a: Create `skills/document-review/SKILL.md`
- [ ] Task 4b: Integrate document-review into plan and explore commands
- [ ] Task 5: Strengthen cross-workflow routing to prevent gate-skipping

## Affected Files

| File | Changes |
|------|---------|
| `skills/generate-plan/SKILL.md` | Set status, add subagent prohibition |
| `skills/review-plan/SKILL.md` | Set status, add subagent prohibition, read config |
| `skills/start-issue/SKILL.md` | Set status to in_progress |
| `skills/swarm-plan/SKILL.md` | Set status to in_progress |
| `skills/finalize/SKILL.md` | Set status to complete |
| `skills/fresh-eyes-review/SKILL.md` | Add subagent prohibition, read config |
| `skills/deepen-plan/SKILL.md` | Add subagent prohibition |
| `skills/explore/SKILL.md` | Add subagent prohibition |
| `commands/implement.md` | State detection for plan status |
| `commands/plan.md` | Add document-review option |
| `commands/loop.md` | Set status transitions |
| `skills/setup/SKILL.md` | **NEW** — per-project config |
| `skills/document-review/SKILL.md` | **NEW** — document quality review |
| `CLAUDE.md` | Update skill count (26), add setup and document-review |
| `QUICK_START.md` | Add new skills to table |
| `.claude-plugin/plugin.json` | Version bump, update description |
| `.claude-plugin/marketplace.json` | Version bump, update description |

## Acceptance Criteria

- [ ] Plans created via generate-plan have `status: ready_for_review`
- [ ] Plans approved via review-plan transition to `status: approved`
- [ ] Plans being implemented transition to `status: in_progress`
- [ ] Finalized plans transition to `status: complete`
- [ ] implement.md state detection shows active/in-progress plans
- [ ] Subagent prompts in all 5 orchestration skills include file-write prohibition
- [ ] `godmode.local.md` is read by fresh-eyes-review when present
- [ ] `/setup` creates a valid config file with auto-detected project type
- [ ] `/document-review` scores and improves plan documents
- [ ] Both new skills appear in QUICK_START.md and CLAUDE.md

## Test Strategy

- Manual: Run `/plan` → generate → verify status is `ready_for_review`
- Manual: Run `/review` on a plan → verify status transitions
- Manual: Create `godmode.local.md` with 2 agents → run `/review` → verify only those agents run
- Manual: Run `/document-review` on an existing plan → verify scoring and improvement flow
- Grep validation: `grep -r "Do NOT write any files" skills/` should match 5 files

## Risks

- **Config file divergence** (MEDIUM): `godmode.local.md` agent names must match actual agent file names. Mitigated by setup skill validating against available agents.
- **Status field inconsistency** (LOW): Different plans use different status casing (`READY_FOR_REVIEW` vs `ready_for_review`). Normalize to lowercase snake_case.
