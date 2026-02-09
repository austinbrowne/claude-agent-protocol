---
title: Complete GitHub Issue Lifecycle Transitions
tier: standard
status: READY_FOR_REVIEW
date: 2026-02-06
risk_flags: []
---

# Complete GitHub Issue Lifecycle Transitions

## Problem

When completing the workflow on a GitHub issue (`/start-issue` → implement → `/review` → `/ship`), the issue's status labels are never updated. The label system is fully defined in `guides/GITHUB_PROJECT_INTEGRATION.md` but the skill files never execute the transitions. Issues stay labeled `ready_for_dev` from start to finish, then close implicitly via PR merge with no completion summary.

## Goals

1. Issues move through `ready_for_dev` → `in-progress` → `review` → closed with correct labels at each stage
2. Explicit close with completion summary (not just implicit via PR merge)
3. Zero manual label management required — the workflow handles it

## Solution

Add `gh issue edit` commands at the correct points in 3 skill files, and add explicit `gh issue close` to finalize.

## Technical Approach

Use the existing label schema from `guides/GITHUB_PROJECT_INTEGRATION.md`:
- `status: in-progress` — set when starting work
- `status: review` — set when PR is created
- Closed with summary comment — set at finalize/merge

All transitions use `gh issue edit` to swap labels. No new labels needed — the schema already defines them.

## Implementation Steps

### Step 1: `skills/start-issue/SKILL.md` — Add `in-progress` transition

After branch creation and assignment (current Step 4-6 area):
- Add: `gh issue edit NNN --remove-label "ready_for_dev" --add-label "status: in-progress"`
- Goes alongside the existing `gh issue edit NNN --add-assignee @me`

### Step 2: `skills/commit-and-pr/SKILL.md` — Add `review` transition

After PR creation:
- Add: `gh issue edit NNN --remove-label "status: in-progress" --add-label "status: review"`
- The PR already includes `Closes #NNN` for eventual auto-close

### Step 3: `skills/finalize/SKILL.md` — Add explicit close with summary

After merge verification:
- Add: `gh issue close NNN --comment "Merged to [branch]. All acceptance criteria met. Tests passing."`
- Provides explicit completion record even though GitHub auto-closes via PR

### Step 4: Update `guides/GITHUB_PROJECT_INTEGRATION.md` — Document transitions

- Add a "Lifecycle Transitions by Skill" section mapping each skill to its label change
- Clarify that transitions are now automated, not manual

## Affected Files

| File | Change |
|------|--------|
| `skills/start-issue/SKILL.md` | Add `in-progress` label transition after assignment |
| `skills/commit-and-pr/SKILL.md` | Add `review` label transition after PR creation |
| `skills/finalize/SKILL.md` | Add explicit `gh issue close` with summary comment |
| `guides/GITHUB_PROJECT_INTEGRATION.md` | Document automated transitions |

## Acceptance Criteria

- [ ] `/start-issue` adds `status: in-progress` and removes `ready_for_dev`
- [ ] `/commit-and-pr` adds `status: review` and removes `status: in-progress`
- [ ] `/finalize` explicitly closes the issue with a completion summary comment
- [ ] Guide documents which skill triggers which transition
- [ ] No label is set that wasn't already defined in the existing schema

## Test Strategy

- Manual walkthrough: run full lifecycle on a test issue and verify labels at each stage
- Verify `gh issue view NNN` shows correct labels after each skill runs

## Security Review

No security concerns — only adding label management to existing `gh` CLI calls. No new permissions, no data exposure.

## Risks

| Risk | Mitigation |
|------|-----------|
| Issue number not available in context | `start-issue` already tracks issue number; `commit-and-pr` extracts from branch name or commit messages |
| Label doesn't exist on repo | `gh issue edit` with nonexistent labels fails gracefully — user just needs to create labels once |
| Duplicate label transitions (re-running a skill) | `gh` CLI is idempotent for label adds — adding an existing label is a no-op |
