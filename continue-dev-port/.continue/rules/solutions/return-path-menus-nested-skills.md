---
alwaysApply: false
description: "Solution: Nested skill invocations need return-path menus — callers must define what happens when a sub-skill completes"
module: Workflow Commands
date: 2026-02-14
problem_type: workflow_issue
component: tooling
symptoms:
  - "After a sub-skill completes, user loses the workflow menu"
  - "User gets dumped into freeform conversation instead of structured options"
  - "Nested skill says 'proceed to next workflow step' but calling command has no handler"
root_cause: logic_error
resolution_type: workflow_improvement
severity: high
tags: [workflow, routing, nested-skill, return-path, menu, interaction-gates]
---

# Troubleshooting: Nested Skill Invocations Need Return-Path Menus

## Problem
When a workflow command routes to a sub-skill (e.g., `/plan` -> `document-review`), and the skill completes with "Proceed to next workflow step," the calling command had no explicit instruction for what happens after the skill returns. The user lost the workflow menu.

## Environment
- Module: Workflow Commands
- Affected Component: Post-skill routing in workflow commands
- Date: 2026-02-14

## Symptoms
- User selects a sub-skill option from a workflow menu
- Sub-skill runs, completes with "Proceed to next workflow step"
- The calling command had no "After sub-skill" section defined
- LLM improvises next steps instead of presenting structured options
- Same pattern for any workflow command that delegates to a sub-skill

## What Didn't Work

**Direct solution:** Caught by edge-case reviewer. No failed attempts.

## Solution

Added explicit return-path routing to calling commands:

```markdown
**If "Review document quality":** Load and follow the document-review skill.
After document-review completes, re-present the workflow menu above.
```

The pattern: every routing entry that invokes a sub-skill must define what happens when the skill returns. This is the "after" instruction.

## Why This Works

1. **ROOT CAUSE:** The routing table defined where to GO but not where to RETURN. Skills end with generic "Proceed to next workflow step" but only the calling command knows what its own menu looks like.
2. The fix makes the calling command responsible for its own return path, not the skill.
3. Re-presenting the same menu is the natural choice — the user completed one sub-step and should see the full menu again.

## Prevention

- Every routing entry that invokes a nested skill MUST include an "After X completes" instruction
- The return instruction should re-present the calling command's own menu
- Skills should NOT try to define what happens after they complete in another command's context — that's the calling command's responsibility
- When adding new skills to command menus, always add the return-path routing alongside the invocation routing
- Pattern: "Load and follow the X skill. After X completes, re-present the [menu name] options above."
