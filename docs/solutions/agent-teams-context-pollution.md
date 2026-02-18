---
title: Agent Teams execution mode must be re-evaluated on every skill invocation
category: agent-teams
tags: [agent-teams, execution-mode, context-pollution, team-mode, subagent-mode]
date: 2026-02-06
severity: high
---

# Agent Teams: Context Pollution in Execution Mode Detection

## Problem

When running skills with `[TEAM MODE]` / `[SUBAGENT MODE]` dual paths, the agent may carry forward an earlier execution mode decision from conversation history instead of re-checking tool availability at Step 0.

**Example:** Agent ran `/fresh-eyes-review` in subagent mode earlier in the conversation (`TeamCreate` tool wasn't available or wasn't used). Later, `TeamCreate` tool becomes available, but the agent "remembers" using subagent mode and continues with that — skipping team mode entirely.

## Root Cause

LLMs follow patterns established in conversation context. If the agent previously chose subagent mode, that decision becomes part of the conversation history and biases subsequent invocations toward the same choice.

## Solution

1. **Step 0 must be forceful.** Each skill's Step 0 uses explicit "CRITICAL: Check your tool list RIGHT NOW" language with explicit instruction to ignore conversation history.

2. **CLAUDE.md "Do NOT" rule.** A global rule prohibits using conversation history to determine execution mode.

3. **Guide reinforcement.** `AGENT_TEAMS_GUIDE.md` Detection Mechanism section explicitly states "Re-evaluate every time."

## Key Insight

Conversation history is not a valid signal for tool availability. Tool availability can change between invocations (user enables/disables Agent Teams mid-session). Every invocation must check fresh.
