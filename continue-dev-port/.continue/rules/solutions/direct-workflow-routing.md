---
alwaysApply: false
description: "Solution: Workflow routing must be direct, not suggestive — 'load and follow' instead of 'suggest user invoke' to prevent broken workflow chains"
module: Workflow Commands
date: 2026-02-06
problem_type: workflow_issue
component: tooling
symptoms:
  - "AI enters plan mode when user says 'implement' after plan review"
  - "Workflow chain breaks between commands"
  - "User loses structured workflow navigation between workflow stages"
root_cause: logic_error
resolution_type: workflow_improvement
severity: high
tags: [workflow, routing, chaining, suggest-invoke, workflow-commands]
---

# Troubleshooting: Workflow Routing Must Be Direct, Not Suggestive

## Problem
Cross-workflow routing used "Suggest user invoke /X" instead of directly loading the next workflow. This caused the AI to treat the user's freeform response as a new task request, triggering plan mode instead of continuing the workflow chain.

## Environment
- Module: Workflow Commands
- Affected Component: All workflow commands + enhance-issue skill
- Date: 2026-02-06

## Symptoms
- User completes plan review, selects "implement", AI enters plan mode instead of loading the implement workflow
- Workflow chain breaks — user must manually invoke the next command
- AI interprets workflow navigation words ("implement", "review", "ship") as freeform task requests

## What Didn't Work

**Attempted Solution 1:** "Suggest user invoke /implement"
- **Why it failed:** The agent either skips the interaction gate entirely or presents it but then tells the user to type a command. When the user types "implement" as freeform text, the AI's base behavior treats it as a new task and enters planning mode.

## Solution

Replace all "Suggest user invoke /X" routing with "Load and follow commands/X" — the same pattern already used for intra-workflow routing.

**Before (broken):**
```
**If "Start implementing":** Suggest user invoke `/implement`
```

**After (fixed):**
```
**If "Start implementing":** Load and follow `commands/implement.md`
```

Applied to all cross-workflow routing points across all workflow commands.

## Why This Works

1. **ROOT CAUSE:** The routing was suggestive, not directive. "Suggest user invoke" introduces a gap where the agent must compose a prose response, and the user must type a new command. Both steps can go wrong.
2. **Direct loading eliminates the gap.** "Load and follow commands/X" is the same pattern used for intra-workflow routing which already works reliably.
3. **Consistency matters.** Every other routing option loaded skills directly. "Suggest user invoke" was the only inconsistent pattern — and it was broken everywhere it appeared.

## Update: Enforcement Language

Even after fixing "Suggest user invoke" to "Load and follow", the LLM still skipped interaction gates in the loaded command. The phrase "Load and follow" was not strong enough. Strengthened to:

```
Load commands/X.md and execute starting from Step 0.
Do NOT skip any steps. Do NOT implement directly. Follow the command file exactly.
```

The additional enforcement language ("Do NOT skip", "Follow exactly") was needed because the LLM optimized for speed by jumping to implementation rather than presenting menus. This is the same pattern as interaction gate enforcement — LLMs treat permissive language as optional.

## Prevention

- When adding cross-workflow routing, use the full enforcement pattern: "Load commands/X.md and execute starting from Step 0. Do NOT skip any steps. Do NOT implement directly. Follow the command file exactly."
- Routing instructions must be imperative ("Load and follow"), not advisory ("Suggest")
- Include explicit prohibitions ("Do NOT skip") — LLMs need to be told what NOT to do, not just what TO do
- Test the full workflow chain end-to-end
- This is part of a pattern: LLMs treat advisory language as optional. Use directive language for required actions.
