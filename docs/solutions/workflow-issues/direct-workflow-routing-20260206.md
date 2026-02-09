---
module: Workflow Commands
date: 2026-02-06
problem_type: workflow_issue
component: tooling
symptoms:
  - "Claude enters EnterPlanMode when user says 'implement' after plan review"
  - "Workflow chain breaks between commands (e.g., /plan to /implement)"
  - "User loses structured workflow navigation between workflow stages"
root_cause: logic_error
resolution_type: workflow_improvement
severity: high
tags: [workflow, routing, chaining, enterplanmode, suggest-invoke, workflow-commands]
related_solutions:
  - docs/solutions/askuserquestion-gate-enforcement.md
  - docs/solutions/agent-teams-context-pollution.md
---

# Troubleshooting: Workflow Routing Must Be Direct, Not Suggestive

## Problem
Cross-workflow routing in all 6 workflow commands used "Suggest user invoke /X" instead of directly loading the next workflow. This caused Claude to treat the user's freeform response as a new task request, triggering EnterPlanMode instead of continuing the workflow chain.

## Environment
- Module: Workflow Commands (commands/*.md)
- Affected Component: All 6 workflow commands + enhance-issue skill
- Date: 2026-02-06

## Symptoms
- User completes plan review, selects "implement", Claude enters plan mode instead of loading /implement
- Workflow chain breaks — user must manually invoke the next command
- Claude interprets workflow navigation words ("implement", "review", "ship") as freeform task requests

## What Didn't Work

**Attempted Solution 1:** "Suggest user invoke /implement"
- **Why it failed:** The agent either skips the AskUserQuestion gate entirely (see askuserquestion-gate-enforcement.md) or presents it but then tells the user to type a command. When the user types "implement" as freeform text, Claude's base behavior treats it as a new task and calls EnterPlanMode.

## Solution

Replace all "Suggest user invoke /X" routing with "Load and follow commands/X.md" — the same pattern already used for intra-workflow routing.

**Before (broken):**
```
**If "Start implementing":** Suggest user invoke `/implement`
```

**After (fixed):**
```
**If "Start implementing":** Load and follow `commands/implement.md`
```

Applied to all 7 occurrences:
- `commands/plan.md` — "Start implementing" → `commands/implement.md`
- `commands/explore.md` — "Start planning" → `commands/plan.md`
- `commands/implement.md` — "Review code" → `commands/review.md`
- `commands/review.md` — "Capture learnings" → `commands/learn.md`, "Ship it" → `commands/ship.md`
- `commands/learn.md` — "Ship it" → `commands/ship.md`
- `commands/ship.md` — "Capture learnings" → `commands/learn.md`
- `skills/enhance-issue/SKILL.md` — "Start implementing" → `commands/implement.md`

## Why This Works

1. **ROOT CAUSE:** The routing was suggestive, not directive. "Suggest user invoke" introduces a gap where the agent must compose a prose response, and the user must type a new command. Both steps can go wrong.
2. **Direct loading eliminates the gap.** "Load and follow commands/X.md" is the same pattern used for intra-workflow routing (e.g., "Load and follow skills/deepen-plan/SKILL.md") which already works reliably.
3. **Consistency matters.** Every other routing option in every workflow loaded skills directly. "Suggest user invoke" was the only inconsistent pattern — and it was broken in all 7 places it appeared.

## Prevention

- When adding cross-workflow routing, always use "Load and follow `commands/X.md`" — never "Suggest user invoke"
- Routing instructions must be imperative ("Load and follow"), not advisory ("Suggest")
- Test the full workflow chain end-to-end: /explore → /plan → /implement → /review → /learn → /ship
- This is part of a pattern: LLMs treat advisory language as optional. Use directive language for required actions.

## Related Issues

- See also: [AskUserQuestion Gate Enforcement](../askuserquestion-gate-enforcement.md) — the AskUserQuestion gate being skipped compounds this problem
- See also: [Agent Teams Context Pollution](../agent-teams-context-pollution.md) — same root pattern of LLMs shortcutting past explicit instructions
