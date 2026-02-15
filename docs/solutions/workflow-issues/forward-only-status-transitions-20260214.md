---
module: Skills
date: 2026-02-14
problem_type: workflow_issue
component: tooling
symptoms:
  - "Running review-plan on an in_progress plan regresses status to approved"
  - "Running start-issue on a complete plan regresses status to in_progress"
  - "Re-running /loop on a finished plan silently reopens it"
root_cause: missing_validation
resolution_type: workflow_improvement
severity: medium
tags: [status, lifecycle, forward-only, plan-status, state-machine, regression, transitions]
related_solutions: []
---

# Troubleshooting: Status Lifecycle Transitions Must Be Forward-Only

## Problem
Plan status lifecycle (`ready_for_review` → `approved` → `in_progress` → `complete`) had no guard against backward transitions. Each skill blindly set its target status without checking the current value, allowing accidental regression.

## Environment
- Module: Skills (generate-plan, review-plan, start-issue, swarm-plan, finalize, loop)
- Affected Component: Plan YAML frontmatter `status:` field
- Date: 2026-02-14

## Symptoms
- Re-running `review-plan` on an `in_progress` plan would set status back to `approved`
- Running `start-issue` or `/loop` on a `complete` plan would reopen it as `in_progress`
- No warning when attempting backward transitions

## What Didn't Work

**Direct solution:** Caught by edge-case reviewer during lite fresh-eyes review. No failed attempts.

## Solution

Added a forward-only guard to every transition point:

```
Read the plan file's YAML frontmatter status: field.
Only update to [target] if the current status precedes [target] in the lifecycle
(ready_for_review → approved → in_progress → complete).
If the current status is at or past the target, do not overwrite.
```

Each skill checks its position in the lifecycle:
- `generate-plan` → always sets `ready_for_review` (starting state, no guard needed)
- `review-plan` → only sets `approved` if current is `ready_for_review`
- `start-issue`, `swarm-plan`, `loop` → only set `in_progress` if current is `approved` or `ready_for_review`
- `finalize` → only sets `complete` if current is `in_progress`

## Why This Works

1. **ROOT CAUSE:** Status field was treated as a write-only value, not a state machine. Each skill set its target without reading the current state.
2. The fix treats it as a proper state machine with forward-only transitions. This is the standard pattern for workflow status fields.
3. The guard prevents accidental regression while still allowing the natural lifecycle to proceed.

## Prevention

- When adding status/lifecycle fields to documents, always define the state machine explicitly with allowed transitions
- Each transition point should read current state before writing
- Forward-only is the default assumption — backward transitions should require explicit user confirmation
- Also handle the case where the status field doesn't exist yet (add it with the target value)
