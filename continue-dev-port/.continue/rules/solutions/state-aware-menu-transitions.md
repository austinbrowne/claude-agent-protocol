---
alwaysApply: false
description: "Solution: State-aware menu transitions — detect state from files before presenting workflow menus, never show options with unmet preconditions"
title: State-Aware Menu Transitions in Workflow Commands
category: workflow-issues
severity: high
tags: [workflow, menus, state-detection, compound-engineering, UX]
date: 2026-02-09
---

# State-Aware Menu Transitions in Workflow Commands

## Problem

Workflow command menus were **static** — showing all options regardless of current state. This caused broken transitions:

- Plan commands showed "Deepen plan", "Review plan", "Create issues" even when **no plan existed**
- Implement commands showed "Swarm plan" when no plan existed, "Start issue" when no issues existed
- Review commands offered review options when there were **no code changes** to review
- Ship commands showed "Refactor first" but the post-refactor menu had no path back to review
- Implement commands always showed "Recovery" even when nothing had failed

Users coming from one workflow to the next would see irrelevant options whose preconditions weren't met, creating confusion and wasted turns.

## Root Cause

Workflow commands were designed as **static menus** — every interaction listed all possible options unconditionally. No state detection ran before menu presentation. The assumption was that skills would handle missing preconditions internally, but by then the user had already made a selection that couldn't work.

## Solution

Add **Step 0: State Detection** to every workflow command. Before presenting any menu, check disk state and only show options whose preconditions are met.

### Pattern

```markdown
## Step 0: State Detection

Before presenting the menu, detect what exists:

1. Search for relevant files (plans, issues, changes)
2. Run git commands to check for changes
3. Check tool availability

Use these signals to build the menu dynamically.
```

### What Each Command Checks

| Command | State Checks | Effect |
|---------|-------------|--------|
| Plan | `docs/plans/*.md` existence | No plans -> only "Generate plan". Plans exist -> all options |
| Implement | Plans, issue list, `git diff`, tool availability | Only shows options with met preconditions |
| Review | `git diff --stat`, recent commits | No changes -> warns and ends |
| Ship | `git diff --stat`, review completion | No changes -> warns and ends |

### Conditional Next-Step Menus

Post-completion menus also became state-aware:
- Implement: "Recovery" only shown when the skill actually failed
- Ship: After "Refactor first", menu prioritizes "Review code" to maintain refactor->review->ship flow
- "Another step" options loop back to Step 0 (re-detect state) not Step 1

## Key Insight — Compound Engineering Pattern

**Detect state from files, not from conversation context.** Each workflow invocation checks what exists on disk (plans, issues, git status) and builds the menu accordingly. No context needs to be "passed" between workflows because each one looks at the ground truth. This makes transitions seamless even after context compaction — the state is in the filesystem, not the conversation.

## Prevention

When adding new workflow commands or menu options:
1. Always add a Step 0 state detection phase
2. Every menu option must have documented preconditions
3. Only show options whose preconditions are met at runtime
4. Post-completion menus should be context-aware (success vs failure)
5. "Loop back" options should re-run Step 0, not skip to Step 1
