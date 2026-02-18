---
alwaysApply: false
description: "Solution: Label definition vs usage mismatch — config/setup scripts defining labels that don't match what workflow code actually uses"
module: GitHub Integration
date: 2026-02-06
problem_type: logic_error
component: config
symptoms:
  - "Label creation script defines status: ready but no workflow code uses it"
  - "All workflow skills use ready_for_dev which is not in the setup script"
  - "Users following setup guide get labels that don't match workflow expectations"
root_cause: config_error
resolution_type: config_change
severity: high
tags: [github, labels, lifecycle, ready_for_dev, status-ready, mismatch, config, setup]
---

# Troubleshooting: Label Definition vs Usage Mismatch

## Problem
The GitHub label creation script in the setup guide defined `status: ready` but every workflow skill used `ready_for_dev` instead. The two label names evolved independently with no cross-validation, causing silent failures for users who followed the setup guide.

## Environment
- Module: GitHub Integration
- Affected Component: Label creation script, all issue lifecycle skills
- Date: 2026-02-06

## Symptoms
- Label creation script creates `status: ready` — never referenced by any skill
- Workflow skills reference `ready_for_dev` — never created by the setup script
- `gh issue edit --remove-label "ready_for_dev"` silently does nothing if the label doesn't exist
- Users setting up a new repo get a non-functional label and miss a required one

## What Didn't Work

**Direct solution:** The problem was identified during a review when formalizing the issue lifecycle state machine into a transitions table. The mismatch was invisible in the individual files but obvious when all transitions were listed together.

## Solution

Updated the label creation script to match what the workflow code actually uses:

**Before (broken):**
```bash
gh label create "status: ready" --description "Ready for development" --color "0e8a16"
```

**After (fixed):**
```bash
gh label create "needs_refinement" --description "Needs exploration and planning before implementation" --color "d93f0b"
gh label create "ready_for_dev" --description "Ready for development" --color "0e8a16"
```

## Why This Works

1. **ROOT CAUSE:** Label definitions and label usage evolved independently. The setup script was written with one naming convention (`status: X` prefix), but the skills that actually use labels adopted a different convention (`ready_for_dev`, `needs_refinement`) over time. Nobody validated them against each other.
2. **The fix aligns definition with usage.** Rather than changing all workflow code to match the setup script, we changed the setup script to match the code — because the code is what actually runs.
3. **The inconsistency was only visible in aggregate.** Each individual skill file looked fine in isolation. The mismatch only became obvious when all lifecycle transitions were documented in a single table.

## Prevention

- When formalizing or documenting implicit workflows, always cross-reference definitions against actual usage
- Build a transitions table (state A -> state B, triggered by skill X) as a single source of truth — inconsistencies become immediately visible
- Don't assume setup/config scripts stay in sync with the code that uses them — validate periodically
- The `gh` CLI's silent handling of nonexistent labels masks these mismatches — test label workflows end-to-end on a fresh repo
