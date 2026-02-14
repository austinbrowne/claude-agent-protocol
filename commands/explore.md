---
name: workflows:explore
description: "Reconnaissance & ideation — explore the codebase and brainstorm approaches"
---

# /explore — Reconnaissance & Ideation

**Workflow command.** Entry point for understanding a codebase before planning or implementing.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Step 1: Determine Exploration Scope

```
AskUserQuestion:
  question: "What would you like to explore?"
  header: "Explore"
  options:
    - label: "Full codebase overview"
      description: "Multi-agent exploration of the entire codebase structure and patterns"
    - label: "Specific area"
      description: "Focused exploration of a particular module, feature, or concern"
```

**If "Full codebase overview":** Proceed with broad exploration.
**If "Specific area":** Ask user to describe the target area, then proceed with focused exploration.

---

## Step 2: Run Exploration

**Load and follow:** `skills/explore/SKILL.md`

Execute the multi-agent exploration process:
- Launch 4 research agents in parallel (codebase-mapper, pattern-analyzer, docs-researcher, learnings-researcher)
- Consolidate findings into a unified summary
- Generate codebase map if full overview

---

## Step 3: Next Steps

```
AskUserQuestion:
  question: "Exploration complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Brainstorm approaches"
      description: "Structured divergent thinking to compare solution strategies"
    - label: "Start planning"
      description: "Move to /plan to create a plan and prepare for implementation"
    - label: "Done"
      description: "End workflow — exploration findings available in conversation"
```

**If "Brainstorm approaches":** Load and follow `skills/brainstorm/SKILL.md`.
**If "Start planning":** Load and follow `commands/plan.md`.
**If "Done":** End workflow.
