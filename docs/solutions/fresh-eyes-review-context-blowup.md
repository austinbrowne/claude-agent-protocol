---
title: Fresh-eyes review agents must read diff from file, not receive it inlined
category: performance
tags: [fresh-eyes-review, context-window, token-optimization, subagent, diff]
date: 2026-02-18
severity: critical
---

# Fresh-Eyes Review: Orchestrator Context Blowup with 8+ Agents

## Problem

Fresh-eyes review crashes with "Context limit reached" when running 8+ specialist agents. The orchestrator hits context limits before Phase 2 (Supervisor) can run, making the entire review pipeline fail.

## Root Cause

Two compounding issues:

1. **Diff inlined into every agent prompt.** The orchestrator inlined the full diff into each agent's Task tool prompt. Task call parameters are stored in the orchestrator's context. With 8 agents, that's 8 copies of the diff in the main context window — plus the orchestrator's own copy from reading it.

2. **Hunk extraction (Step 2.6) parsed the diff in the orchestrator.** The orchestrator read the full diff, parsed it into per-file hunks, grepped each hunk against trigger patterns, and wrote per-agent filtered diffs. All this work happened in the orchestrator's context, adding further bloat.

## Fix

Three changes (v5.12.0–5.14.0):

1. **Agents read the diff themselves.** Agent prompts now contain a file path (`.review/review-diff.txt`) instead of the inlined diff content. Each agent uses the Read tool to load the diff into its own context window — the orchestrator never holds the diff content.

2. **Removed hunk extraction entirely.** All agents read the same full diff and focus on their own domain. The per-agent filtering added orchestrator-side complexity and context usage for marginal benefit.

3. **Project-relative path, not `/tmp/`.** Claude Code agents lack permission to read `/tmp/` (outside project directory). Diff files go to `.review/` (gitignored) within the project root.

## Key Files Changed

- `skills/fresh-eyes-review/SKILL.md` — Agent prompt templates, execution pattern, removed Step 2.6
- `guides/FRESH_EYES_REVIEW.md` — Phase 1 description, removed hunk extraction section
- `agents/review/supervisor.md` — Step 3 updated to validate against specialist evidence (not the diff)
- `skills/fresh-eyes-review/references/trigger-patterns.md` — Removed hunk extraction section
- `.gitignore` — Added `.review/` directory

## Gotchas

- **`/tmp/` is off-limits to agents.** Claude Code sandboxes file access to the project directory. Always use project-relative paths for files that subagents need to read.
- **Task tool prompts live in the caller's context.** Anything you put in a Task tool's `prompt` parameter is stored in the orchestrator's context window, not just the subagent's. Large inlined content multiplied by N agents = context explosion.
- **Agent definition files are still inlined.** These are small (~80 lines each) so the overhead is acceptable. Only the diff (which can be thousands of lines) needed to be externalized.

## Verification

Run `/fresh-eyes-review` on a large diff (8+ agents triggered). The orchestrator should complete all three phases (Specialist → Supervisor → AV) without hitting context limits.
