---
name: workflows:plan
description: "Planning & requirements — plan generation, deepening, review, issues, and ADR"
---

# /plan — Planning & Requirements

**Workflow command.** Hub for all planning activities: plan creation, plan enrichment, plan review, issue creation, and architecture decision records.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning via `generate-plan`, not Claude Code's native plan mode.

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Glob `docs/plans/*.md`** — do any plan files exist?
2. **Filter by status** — read the YAML frontmatter of each plan file. Only plans with `status:` other than `complete` count as active. Completed plans are historical records, not actionable. If ALL plans are `complete`, treat this as "no active plans."
3. If a plan was just generated in this conversation, note its path as the "active plan"

Use these signals to build the menu in Step 1. **Only show options whose preconditions are met.**

---

## Step 1: Select Planning Activity

**If NO active plans exist** (first time, all complete, or plans directory empty):
```
AskUserQuestion:
  question: "No active plans found. Let's create one."
  header: "Plan"
  options:
    - label: "Generate plan"
      description: "Create a plan (Minimal, Standard, or Comprehensive) with integrated research"
    - label: "Create ADR"
      description: "Document an architecture decision record"
```

**If active plans exist** (any plan with status other than `complete`):
```
AskUserQuestion:
  question: "Which planning step would you like to run?"
  header: "Plan"
  options:
    - label: "Generate plan"
      description: "Create a new plan (Minimal, Standard, or Comprehensive) with integrated research"
    - label: "Deepen existing plan"
      description: "Enrich a plan with parallel research and review agents"
    - label: "Review plan"
      description: "Multi-agent plan review with adversarial validation"
    - label: "Create GitHub issues"
      description: "Generate GitHub issues from an approved plan"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Generate plan"** → Invoke `Skill(skill="godmode:generate-plan")` with the task description as arguments
- **"Deepen existing plan"** → Invoke `Skill(skill="godmode:deepen-plan")` with the plan path as arguments
- **"Review plan"** → Invoke `Skill(skill="godmode:review-plan")` with the plan path as arguments
- **"Create GitHub issues"** → Invoke `Skill(skill="godmode:create-issues")` with the plan path as arguments

---

## Step 3: Next Steps — MANDATORY GATE

**CRITICAL: After EVERY skill completes, you MUST present the appropriate AskUserQuestion below. NEVER ask "what would you like to do next?" in plain text. NEVER skip this step. NEVER collapse it into the skill's output.**

**After "Generate plan":**
```
AskUserQuestion:
  question: "Plan generated. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Review document quality"
      description: "Run structured quality review on the generated plan"
    - label: "Deepen this plan"
      description: "Enrich with parallel research and review agents"
    - label: "Review this plan"
      description: "Multi-agent review with adversarial validation"
    - label: "Create GitHub issues"
      description: "Generate issues from this plan"
    - label: "Start implementing"
      description: "Move to /implement to begin coding"
```

**After "Deepen existing plan":**
```
AskUserQuestion:
  question: "Plan deepened. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Review this plan"
      description: "Multi-agent review with adversarial validation"
    - label: "Create GitHub issues"
      description: "Generate issues from this plan"
    - label: "Start implementing"
      description: "Move to /implement to begin coding"
    - label: "Done"
      description: "End workflow"
```

**After "Review plan":**
```
AskUserQuestion:
  question: "Plan reviewed. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Create GitHub issues"
      description: "Generate issues from the approved plan"
    - label: "Start implementing"
      description: "Move to /implement to begin coding"
    - label: "Revise the plan"
      description: "Go back and modify based on review feedback"
    - label: "Done"
      description: "End workflow"
```

**After "Create GitHub issues":**
```
AskUserQuestion:
  question: "Issues created. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Start implementing"
      description: "Move to /implement to begin coding"
    - label: "Create another plan"
      description: "Start a new planning activity"
    - label: "Done"
      description: "End workflow"
```

**Routing:**
- **"Review document quality"** → Invoke `Skill(skill="godmode:document-review")` with the plan path as arguments. After document-review completes, re-present the "After Generate plan" AskUserQuestion above.
- **"Deepen this plan"** → Invoke `Skill(skill="godmode:deepen-plan")` with the plan path as arguments
- **"Review this plan"** → Invoke `Skill(skill="godmode:review-plan")` with the plan path as arguments
- **"Create GitHub issues"** → Invoke `Skill(skill="godmode:create-issues")` with the plan path as arguments
- **"Start implementing"** → Invoke `Skill(skill="godmode:implement")`. Execute from Step 0. Do NOT skip any steps.
- **"Revise the plan"** → Return to Step 1 with "Generate plan" pre-selected
- **"Create another plan"** → Return to Step 1
- **"Done"** → End workflow

---

## Additional Skills Available

These can be invoked before planning or when explicitly requested:

- **Create ADR** — `skills/create-adr/SKILL.md` — Document architecture decisions
- **Brainstorm** — `skills/brainstorm/SKILL.md` — Structured divergent thinking (use BEFORE generating a plan, not after)

If the user mentions architecture decisions, offer ADR. If they want to explore approaches before committing, offer brainstorm.
