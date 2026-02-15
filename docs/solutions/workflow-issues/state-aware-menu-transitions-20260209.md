---
title: State-Aware Menu Transitions in Workflow Commands
category: workflow-issues
severity: high
tags: [workflow, menus, state-detection, compound-engineering, UX]
date: 2026-02-09
---

# State-Aware Menu Transitions in Workflow Commands

## Problem

Workflow command menus were **static** — showing all options regardless of current state. This caused broken transitions:

- `/plan` showed "Deepen plan", "Review plan", "Create issues" even when **no plan existed**
- `/implement` showed "Swarm plan" when no plan existed, "Start issue" when no issues existed
- `/review` offered review options when there were **no code changes** to review
- `/ship` showed "Refactor first" but the post-refactor menu had no path back to review
- `/implement` always showed "Recovery" even when nothing had failed

Users coming from one workflow to the next (e.g., brainstorm → plan) would see irrelevant options whose preconditions weren't met, creating confusion and wasted turns.

## Root Cause

Workflow commands were designed as **static menus** — every AskUserQuestion listed all possible options unconditionally. No state detection ran before menu presentation. The assumption was that skills would handle missing preconditions internally, but by then the user had already made a selection that couldn't work.

## Solution

Add **Step 0: State Detection** to every workflow command. Before presenting any menu, check disk state and only show options whose preconditions are met.

### Pattern

```markdown
## Step 0: State Detection

Before presenting the menu, detect what exists:

1. Glob for relevant files (plans, issues, changes)
2. Run git commands to check for changes
3. Check tool availability (e.g., TeamCreate for Agent Teams)

Use these signals to build the menu dynamically.
```

### What Each Command Checks

| Command | State Checks | Effect |
|---------|-------------|--------|
| `/plan` | `docs/plans/*.md` existence | No plans → only "Generate plan". Plans exist → all options |
| `/implement` | Plans, `gh issue list`, `git diff`, TeamCreate tool | Only shows options with met preconditions |
| `/review` | `git diff --stat`, recent commits | No changes → warns and ends |
| `/ship` | `git diff --stat`, review completion | No changes → warns and ends |

### Conditional Next-Step Menus

Post-completion menus also became state-aware:
- `/implement` Step 3: "Recovery" only shown when the skill actually failed
- `/ship` Step 3: After "Refactor first", menu prioritizes "Review code" to maintain refactor→review→ship flow
- "Another step" options loop back to Step 0 (re-detect state) not Step 1

## Key Insight — Compound Engineering Pattern

**Detect state from files, not from conversation context.** Each workflow invocation checks what exists on disk (plans, issues, git status) and builds the menu accordingly. No context needs to be "passed" between workflows because each one looks at the ground truth. This makes transitions seamless even after context compaction — the state is in the filesystem, not the conversation.

This is why `EnterPlanMode` is also prohibited — the protocol's planning state lives in plan files, not in Claude's native plan mode.

## Files Changed

- `commands/plan.md` — Step 0 added, conditional Step 1 menu
- `commands/implement.md` — Step 0 added, conditional menus, failure-aware Step 3
- `commands/review.md` — Step 0 added, change detection gate
- `commands/ship.md` — Step 0 added, refactor→review loop fix
- `commands/explore.md` — Transition note clarifying plan auto-detection

## Prevention

When adding new workflow commands or menu options:
1. Always add a Step 0 state detection phase
2. Every menu option must have documented preconditions
3. Only show options whose preconditions are met at runtime
4. Post-completion menus should be context-aware (success vs failure)
5. "Loop back" options should re-run Step 0, not skip to Step 1
