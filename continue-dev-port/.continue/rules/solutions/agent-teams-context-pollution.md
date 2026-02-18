---
alwaysApply: false
description: "Solution: Agent teams execution mode must be re-evaluated on every skill invocation — conversation history is not a valid signal for tool availability"
title: Agent Teams execution mode must be re-evaluated on every skill invocation
category: agent-teams
tags: [agent-teams, execution-mode, context-pollution, team-mode, subagent-mode]
date: 2026-02-06
severity: high
---

# Agent Teams: Context Pollution in Execution Mode Detection

## Problem

When running skills with dual execution paths (team mode vs sequential mode), the agent may carry forward an earlier execution mode decision from conversation history instead of re-checking tool availability at the start of each invocation.

**Example:** Agent ran a review in sequential mode earlier in the conversation (team tools weren't available or weren't used). Later, team tools become available, but the agent "remembers" using sequential mode and continues with that — skipping team mode entirely.

## Root Cause

LLMs follow patterns established in conversation context. If the agent previously chose sequential mode, that decision becomes part of the conversation history and biases subsequent invocations toward the same choice.

## Solution

1. **Each skill invocation must forcefully re-check.** Use explicit "CRITICAL: Check your available tools RIGHT NOW" language with explicit instruction to ignore conversation history.

2. **Global rule.** A project-wide rule prohibits using conversation history to determine execution mode.

3. **Guide reinforcement.** Documentation explicitly states "Re-evaluate every time."

## Key Insight

Conversation history is not a valid signal for tool availability. Tool availability can change between invocations (user enables/disables features mid-session). Every invocation must check fresh.
