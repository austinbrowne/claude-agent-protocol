---
alwaysApply: false
description: "Solution: Fresh-eyes review agents must read diff from file, not receive it inlined — prevents orchestrator context blowup with 8+ agents"
title: Fresh-eyes review agents must read diff from file, not receive it inlined
category: performance
tags: [fresh-eyes-review, context-window, token-optimization, subagent, diff]
date: 2026-02-18
severity: critical
---

# Fresh-Eyes Review: Orchestrator Context Blowup with 8+ Agents

## Problem

Fresh-eyes review crashes with "Context limit reached" when running 8+ specialist agents. The orchestrator hits context limits before the Supervisor phase can run, making the entire review pipeline fail.

## Root Cause

Two compounding issues:

1. **Diff inlined into every agent prompt.** The orchestrator inlined the full diff into each agent's prompt. Prompt parameters are stored in the orchestrator's context. With 8 agents, that's 8 copies of the diff in the main context window — plus the orchestrator's own copy from reading it.

2. **Hunk extraction parsed the diff in the orchestrator.** The orchestrator read the full diff, parsed it into per-file hunks, searched each hunk against trigger patterns, and wrote per-agent filtered diffs. All this work happened in the orchestrator's context, adding further bloat.

## Fix

Three changes:

1. **Agents read the diff themselves.** Agent prompts now contain a file path (`.review/review-diff.txt`) instead of the inlined diff content. Each agent reads the diff into its own context window — the orchestrator never holds the diff content.

2. **Removed hunk extraction entirely.** All agents read the same full diff and focus on their own domain. The per-agent filtering added orchestrator-side complexity and context usage for marginal benefit.

3. **Project-relative path, not `/tmp/`.** Sandboxed agents may lack permission to read `/tmp/` (outside project directory). Diff files go to `.review/` (gitignored) within the project root.

## Gotchas

- **`/tmp/` may be off-limits to agents.** Sandboxed file access may be restricted to the project directory. Always use project-relative paths for files that sub-agents need to read.
- **Prompt parameters live in the caller's context.** Anything you put in a sub-agent's prompt parameter is stored in the orchestrator's context window, not just the sub-agent's. Large inlined content multiplied by N agents = context explosion.
- **Agent definition files are still inlined.** These are small (~80 lines each) so the overhead is acceptable. Only the diff (which can be thousands of lines) needed to be externalized.

## Verification

Run a multi-agent review on a large diff (8+ agents triggered). The orchestrator should complete all phases without hitting context limits.
