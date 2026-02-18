---
alwaysApply: false
description: "Solution: State machine exhaustive branch coverage — natural-language state machines need explicit handlers for every possible state, including catch-all else clauses"
module: Autonomous Loop
date: 2026-02-09
problem_type: logic_error
component: tooling
symptoms:
  - "State machine has no handler for [!] blocked marker"
  - "When all remaining tasks are [!], agent has no matching instruction branch"
  - "Loop runs until max-iterations exhausted doing nothing productive"
root_cause: logic_error
resolution_type: code_fix
severity: high
tags: [state-machine, exhaustive-branches, autonomous-loop, blocked-state, infinite-loop, markers]
---

# Troubleshooting: State Machine Exhaustive Branch Coverage for Autonomous Loops

## Problem
A natural-language state machine in an autonomous loop command only handled two task states (`[ ]` unchecked and `[x]` checked) but a third state (`[!]` blocked) was introduced in the Rules section. When all remaining tasks were `[!]`, the agent had no matching branch and looped indefinitely.

## Environment
- Module: Autonomous Loop
- Affected Component: State machine prompt, task detection phase
- Date: 2026-02-09

## Symptoms
- The task detection phase checks for "unchecked task (marked with `[ ]`)" and "all tasks are checked `[x]`"
- A `[!]` item matches neither condition
- If all remaining tasks are `[!]`, the phase finds no `[ ]` tasks but "all checked `[x]`" is also false
- No else clause exists — agent has no instruction for this state
- Loop runs until max iterations is exhausted, doing nothing each iteration

## What Didn't Work

**Direct solution:** The problem was caught during a review (Edge Case Reviewer) before any runtime failure occurred. The infinite loop was identified through static analysis of the state machine branches.

## Solution

Two changes to the state machine prompt:

**1. Updated termination condition:**

```markdown
# Before (broken):
- If all tasks are checked [x]:
  -> Continue to next phase.

# After (fixed):
- If no [ ] tasks remain (all are [x] or [!]):
  -> Continue to next phase.
```

**2. Added explicit rule for blocked task handling:**

```markdown
- Skip [!] (blocked) tasks -- they are not [ ] (unchecked). When no [ ] tasks remain, proceed to the next phase regardless of [!] count.
```

**Secondary fix:** Added file modification constraints to prevent the autonomous agent from modifying its own control files:

```markdown
- Do NOT modify: configuration directories, CI/CD configuration, deployment scripts, command definitions, or agent definitions.
```

## Why This Works

1. **ROOT CAUSE:** The state machine defined three possible task markers (`[ ]`, `[x]`, `[!]`) but only wrote conditional branches for two of them. Natural-language state machines lack compiler enforcement of exhaustive pattern matching, so the missing branch was invisible until review.
2. **The fix explicitly enumerates the third state.** By changing the condition to "no `[ ]` tasks remain" (rather than "all are `[x]`"), blocked tasks are naturally included in the termination condition.
3. **The redundant rule reinforces the semantics.** Since each loop iteration starts with zero memory, the agent needs explicit instructions — it cannot infer that `[!]` should be skipped from context.

## Prevention

- **Enumerate ALL possible states before writing branches.** For any marker/flag system, list every possible value and verify each has a handler. If you introduce a new marker in one section (e.g., Rules), check every conditional that touches the same field.
- **Natural-language state machines need explicit else clauses.** Unlike code, there is no compiler to warn about missing branches. Always add a catch-all: "If none of the above conditions match, HALT with error."
- **Autonomous agents need explicit constraints.** Without file modification boundaries, an autonomous agent could modify its own control files, disable safety checks, or alter CI/CD configuration. List what the agent must NOT touch.
- **Review custom markers end-to-end.** When introducing a non-standard marker (`[!]`, `[?]`, etc.), search for every conditional that checks standard markers (`[ ]`, `[x]`) and verify the new marker is handled.
