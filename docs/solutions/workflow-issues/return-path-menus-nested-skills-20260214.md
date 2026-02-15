---
module: Workflow Commands
date: 2026-02-14
problem_type: workflow_issue
component: tooling
symptoms:
  - "After document-review completes from /plan, user loses workflow menu"
  - "User gets dumped into freeform conversation instead of structured options"
  - "Nested skill says 'proceed to next workflow step' but calling command has no handler"
root_cause: logic_error
resolution_type: workflow_improvement
severity: high
tags: [workflow, routing, nested-skill, return-path, menu, askuserquestion, document-review]
related_solutions:
  - docs/solutions/workflow-issues/direct-workflow-routing-20260206.md
  - docs/solutions/workflow-issues/state-aware-menu-transitions-20260209.md
---

# Troubleshooting: Nested Skill Invocations Need Return-Path Menus

## Problem
When a workflow command routes to a skill (e.g., `/plan` → `document-review`), and the skill completes with "Proceed to next workflow step," the calling command had no explicit instruction for what happens after the skill returns. The user lost the workflow menu.

## Environment
- Module: Workflow Commands (commands/plan.md, commands/explore.md)
- Affected Component: Post-skill routing in workflow commands
- Date: 2026-02-14

## Symptoms
- User selects "Review document quality" from `/plan`'s post-generate menu
- `document-review` skill runs, completes with "Proceed to next workflow step"
- Neither `plan.md` nor `explore.md` defined an "After document-review" section
- LLM improvises next steps instead of presenting structured AskUserQuestion menu
- Same pattern for "Review brainstorm" from `/explore`

## What Didn't Work

**Direct solution:** Caught by edge-case reviewer. No failed attempts.

## Solution

Added explicit return-path routing to calling commands:

```markdown
**If "Review document quality":** Load and follow `skills/document-review/SKILL.md`.
After document-review completes, re-present the "After Generate plan" AskUserQuestion above.
```

The pattern: every routing entry that invokes a skill must define what happens when the skill returns. This is the "after" instruction.

## Why This Works

1. **ROOT CAUSE:** The routing table defined where to GO but not where to RETURN. Skills end with generic "Proceed to next workflow step" but only the calling command knows what its own menu looks like.
2. The fix makes the calling command responsible for its own return path, not the skill.
3. Re-presenting the same AskUserQuestion menu is the natural choice — the user completed one sub-step and should see the full menu again.

## Prevention

- Every routing entry that invokes a nested skill MUST include an "After X completes" instruction
- The return instruction should re-present the calling command's own AskUserQuestion menu
- Skills should NOT try to define what happens after they complete in another command's context — that's the calling command's responsibility
- When adding new skills to command menus, always add the return-path routing alongside the invocation routing
- Pattern: "Load and follow `skills/X/SKILL.md`. After X completes, re-present the [menu name] AskUserQuestion above."
