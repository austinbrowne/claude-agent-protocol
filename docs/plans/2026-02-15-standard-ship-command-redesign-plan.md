---
title: "Redesign /ship Command for Context-Aware Shipping"
type: standard
status: complete
security_sensitive: false
date: 2026-02-15
---

# Standard Plan: Redesign /ship for Context-Aware Shipping

## Problem

The `/ship` command has a static menu that shows the same 3 options regardless of git state, review status, or what happened in prior workflow steps. This leads to irrelevant options being offered (e.g., "Refactor first" when refactoring is an implementation activity, generic next-step menus that don't reflect what just happened). Users hit context-irrelevant choices at every turn.

## Goals

1. Detect shipping state comprehensively (git state, review status, PR existence)
2. Build dynamic menus that only show relevant options with recommendations
3. Remove "Refactor first" from the ship menu (it's a pre-ship implementation activity)
4. Make Step 3 context-aware based on what happened inside the executed skill

## Technical Approach

Follow the patterns established in `/implement` (state detection with recommendation) and `/review` (context-aware Step 3 menus based on skill outcome). Apply learnings from `state-aware-menu-transitions`, `direct-workflow-routing`, `return-path-menus-nested-skills`, and `exhaustive-branch-coverage`.

## Review Decisions (from plan review)

| Finding | Decision |
|---------|----------|
| Failure detection mechanism | Conversation context — Claude knows what just happened |
| Review status after compaction | File-based marker — `.todos/review-verdict.md` written by fresh-eyes-review, read by ship Step 0 |
| Overlapping state precedence | Compound states as explicit rows in recommendation table |
| Skip review override | Soft suggestion — note "no review detected" in description, don't block |
| Abstract Step 3 menus | Write full AskUserQuestion blocks during implementation |
| 0a/0b split | Collapse to single-phase Step 0 |
| Committed but unpushed state | Separate "Push and create PR" menu option |
| Main/master detection | Drop entirely — not ship's job to enforce branching strategy |

## Implementation Steps

### Step 1: Rewrite `commands/ship.md` Step 0 — Single-Phase State Detection

Gather signals and assess in one pass (no 0a/0b split):

**Signals to gather:**
1. `git diff --stat HEAD` + `git diff --staged --stat` — uncommitted/unstaged changes?
2. `git log --oneline @{upstream}..HEAD 2>/dev/null` — unpushed commits?
3. `gh pr list --head $(git branch --show-current) --json number,state,url --limit 1` — PR already exists?
4. Check `.todos/review-verdict.md` — was Fresh Eyes Review completed? What verdict? (Falls back to conversation context if marker missing)

**Recommendation table (compound states, first match wins):**

| State | Recommendation |
|-------|---------------|
| No changes + no unpushed commits + no PR | Halt: "Nothing to ship. Run `/implement` first." |
| Uncommitted changes + PR exists (open) | "Commit and update PR" — additional changes to existing PR |
| Uncommitted changes + review APPROVED | "Commit and create PR" |
| Uncommitted changes + no review (or REVISION_REQUESTED) | "Commit and create PR" with note: "No review detected — commit-and-pr will auto-trigger if needed" |
| No uncommitted changes + unpushed commits + no PR | "Push and create PR" |
| No uncommitted changes + unpushed commits + PR exists | "Finalize" — PR already up to date |
| PR exists, open, all pushed | "Finalize" |
| PR exists, merged | "Capture learnings" or end |

### Step 2: Rewrite `commands/ship.md` Step 1 — Dynamic Menu

Remove static 3-option menu. Build menu based on detected state — recommended option first with "(Recommended)" suffix. Only show options whose preconditions are met. Write full AskUserQuestion blocks for each state variant.

### Step 3: Rewrite `commands/ship.md` Step 3 — Context-Aware Next Steps

Vary menu based on what happened in the conversation during skill execution:

- **Commit+PR succeeded** (commit hash and PR URL in conversation) → Finalize (Recommended), Capture learnings, Done
- **Push+PR succeeded** → Finalize (Recommended), Capture learnings, Done
- **Finalize completed** → Capture learnings (Recommended), Done
- **Skill failed** (error in conversation) → Retry, Run review, Done

### Step 4: Remove "Refactor first" from ship menu

Refactoring is an implementation activity. Users can invoke `/refactor` directly.

### Step 5: Add review verdict marker to `skills/fresh-eyes-review/SKILL.md`

After verdict is determined, write `.todos/review-verdict.md` with:
- Verdict (APPROVED / APPROVED_WITH_NOTES / FIX_BEFORE_COMMIT / BLOCK)
- Timestamp
- Files reviewed count

This marker survives context compaction and is read by `/ship` Step 0.

## Affected Files

| File | Change |
|------|--------|
| `commands/ship.md` | Major rewrite — Steps 0, 1, 2, 3 |
| `skills/fresh-eyes-review/SKILL.md` | Add review verdict marker file write after verdict |

## Acceptance Criteria

- [ ] Step 0 gathers git state, PR existence, and review status (file-based + conversation fallback)
- [ ] Recommendation table handles compound states with explicit rows
- [ ] Step 1 menu varies based on detected state with full AskUserQuestion blocks
- [ ] Recommended option appears first with "(Recommended)" suffix
- [ ] Options with unmet preconditions are hidden
- [ ] "Refactor first" removed from menu
- [ ] "Push and create PR" option exists for committed-but-unpushed state
- [ ] Step 3 varies based on skill outcome (success vs failure)
- [ ] All cross-workflow routing uses "Load `commands/X.md` and execute starting from Step 0. Do NOT skip any steps."
- [ ] Mandatory AskUserQuestion gates preserved
- [ ] fresh-eyes-review writes `.todos/review-verdict.md` after verdict
- [ ] Ship Step 0 reads verdict marker with conversation context fallback

## Risks

- LOW: Edge cases in git state detection (detached HEAD, no upstream). Mitigate with `2>/dev/null` fallbacks and explicit else clauses.
- LOW: `.todos/review-verdict.md` from a previous session could be stale. Mitigate by checking timestamp against current branch's latest commit.

## Past Learnings Applied

- State detection from filesystem/git, not conversation context (`state-aware-menu-transitions`)
- Direct routing enforcement language (`direct-workflow-routing`)
- Return-path menus for nested skills (`return-path-menus-nested-skills`)
- Exhaustive branch coverage for state machines (`state-machine-exhaustive-branch-coverage`)
