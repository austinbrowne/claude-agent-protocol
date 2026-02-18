---
alwaysApply: false
description: "Solution: Interaction gate enforcement — ensuring AI agents hit mandatory user interaction points instead of skipping them with plain text"
title: Interaction Gate Enforcement
category: protocol-pattern
tags: [interaction-gates, workflow-control, agent-behavior]
date: 2026-02-06
severity: high
---

# Interaction Gate Enforcement

## Problem

Skills and workflow commands define mandatory interaction points (e.g., plan acceptance, post-review actions, next-step routing). Agents sometimes skip these gates and ask the equivalent question in plain text instead, which:
- Removes structured options from the user
- Breaks workflow routing (the next step never fires)
- Makes the interaction feel uncontrolled and ad-hoc

## Root Cause

LLMs treat structured interaction instructions as suggestions, not requirements. When generating a response, the model may find it "easier" to ask a plain text follow-up than to present numbered options and wait for user selection.

## Solution

Three-layer enforcement:

### Layer 1: Mandatory Interaction Gates section (per skill)
Add a `## Mandatory Interaction Gates` section near the top of each skill file that lists every required interaction point with consequences of skipping:

```markdown
## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Step | Options | What Happens If Skipped |
|------|------|---------|------------------------|
| **Plan Acceptance** | Step 6 | 1. Accept / 2. Request Changes / 3. Reject | Plan saved without approval — UNACCEPTABLE |
```

### Layer 2: MANDATORY GATE labels (per section)
Label each interaction section with `— MANDATORY GATE` in the heading and add a STOP instruction:

```markdown
## Post-Review Actions — MANDATORY GATE

**STOP. You MUST present numbered options and WAIT for user selection here. Do NOT ask in plain text.**
```

### Layer 3: Global "Do NOT" rule (project-wide)
Add to the project rules:
```
- **Replace interaction gates with plain text** - skills and workflow commands define mandatory interaction points. ALWAYS present the numbered options defined in the skill file and WAIT for user selection.
```

## Skills With Mandatory Gates

| Skill | Gates |
|-------|-------|
| `generate-plan` | Plan acceptance (Step 6) |
| `review-plan` | Post-review actions |
| `fresh-eyes-review` | Post-review actions, re-review offer |
| All workflow commands | Next-step routing |

## Key Insight

The pattern is identical to the context pollution fix (see `agent-teams-context-pollution.md`): LLMs shortcut past explicit instructions when they seem "optional." The fix is the same — make the instruction impossible to misinterpret by using CRITICAL/STOP/MANDATORY language and stating consequences.
