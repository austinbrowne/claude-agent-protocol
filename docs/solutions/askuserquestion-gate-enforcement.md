---
title: AskUserQuestion Gate Enforcement
category: protocol-pattern
tags: [askuserquestion, interaction-gates, workflow-control, agent-behavior]
date: 2026-02-06
severity: high
---

# AskUserQuestion Gate Enforcement

## Problem

Skills and workflow commands define mandatory `AskUserQuestion` interaction points (e.g., plan acceptance, post-review actions, next-step routing). Agents sometimes skip these gates and ask the equivalent question in plain text instead, which:
- Removes structured options from the user
- Breaks workflow routing (the workflow command's Step 3 never fires)
- Makes the interaction feel uncontrolled and ad-hoc

## Root Cause

LLMs treat `AskUserQuestion` instructions as suggestions, not requirements. When generating a response, the model may find it "easier" to ask a plain text follow-up than to invoke the AskUserQuestion tool with the exact options defined in the skill file.

## Solution

Three-layer enforcement:

### Layer 1: Mandatory Interaction Gates section (per skill)
Add a `## Mandatory Interaction Gates` section near the top of each skill file that lists every required AskUserQuestion gate with consequences of skipping:

```markdown
## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Step | AskUserQuestion | What Happens If Skipped |
|------|------|-----------------|------------------------|
| **Plan Acceptance** | Step 6 | Accept / Request Changes / Reject | Plan saved without approval — UNACCEPTABLE |
```

### Layer 2: MANDATORY GATE labels (per section)
Label each AskUserQuestion section with `— MANDATORY GATE` in the heading and add a STOP instruction:

```markdown
## Post-Review Actions — MANDATORY GATE

**STOP. You MUST use AskUserQuestion here. Do NOT ask in plain text.**
```

### Layer 3: CLAUDE.md Do NOT rule (project-wide)
Add to the Do NOT section:
```
- **Replace AskUserQuestion gates with plain text** - skills and workflow commands define mandatory `AskUserQuestion` interaction points. ALWAYS use the AskUserQuestion tool with the exact options defined in the skill file.
```

## Skills With Mandatory Gates

| Skill | Gates |
|-------|-------|
| `generate-plan` | Plan acceptance (Step 6) |
| `review-plan` | Post-review actions |
| `fresh-eyes-review` | Post-review actions, re-review offer |
| All workflow commands | Next-step routing (Step 3 / equivalent) |

## Key Insight

The pattern is identical to the context pollution fix (see `agent-teams-context-pollution.md`): LLMs shortcut past explicit instructions when they seem "optional." The fix is the same — make the instruction impossible to misinterpret by using CRITICAL/STOP/MANDATORY language and stating consequences.
