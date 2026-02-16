---
name: workflows:explore
description: "Reconnaissance & ideation — explore the codebase and brainstorm approaches"
---

# /explore — Reconnaissance & Ideation

**Workflow command.** Entry point for understanding a codebase before planning or implementing.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Check if `CODEBASE_MAP.md` exists** — has the codebase already been explored?
2. **Glob `docs/brainstorms/*.md`** — do any brainstorm docs exist?

Use these signals to inform Step 1. If a codebase map already exists, note it in the exploration step (update rather than create from scratch).

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

## Step 3: Next Steps — MANDATORY GATE

**CRITICAL: After EVERY skill completes, you MUST present the appropriate AskUserQuestion below. NEVER ask "what would you like to do next?" in plain text. NEVER skip this step. NEVER collapse it into the skill's output.**

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

**If "Brainstorm approaches":** Invoke `Skill(skill="godmode:brainstorm")`. After brainstorm completes, present the post-brainstorm menu below.
**If "Start planning":** Invoke `Skill(skill="godmode:plan")`. Execute from Step 0. Do NOT skip any steps.
**If "Done":** End workflow.

---

### After Brainstorm Completes

```
AskUserQuestion:
  question: "Brainstorm complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Review brainstorm"
      description: "Run structured quality review on the brainstorm output"
    - label: "Start planning"
      description: "Move to /plan to create a plan from brainstorm insights"
    - label: "Done"
      description: "End workflow — brainstorm findings available in conversation"
```

**If "Review brainstorm":** Invoke `Skill(skill="godmode:document-review")`. After document-review completes, re-present the "After Brainstorm Completes" AskUserQuestion above.
**If "Start planning":** Invoke `Skill(skill="godmode:plan")`. Execute from Step 0. Do NOT skip any steps.
**If "Done":** End workflow.
