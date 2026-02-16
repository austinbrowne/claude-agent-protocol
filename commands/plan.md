---
name: workflows:plan
description: "Planning & requirements — plan generation, deepening, review, issues, and ADR"
---

# /plan — Planning & Requirements

**Workflow command.** Hub for all planning activities: plan creation, plan enrichment, plan review, issue creation, and architecture decision records.

---

## Step 1: Select Planning Activity

```
AskUserQuestion:
  question: "Which planning step would you like to run?"
  header: "Plan"
  options:
    - label: "Generate plan"
      description: "Create a plan (Minimal, Standard, or Comprehensive) with integrated research"
    - label: "Deepen existing plan"
      description: "Enrich a plan with parallel research and review agents"
    - label: "Review plan"
      description: "Multi-agent plan review with adversarial validation"
    - label: "Create issues"
      description: "Generate issues from an approved plan"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Generate plan"** → Load and follow `skills/generate-plan/SKILL.md`
- **"Deepen existing plan"** → Load and follow `skills/deepen-plan/SKILL.md`
- **"Review plan"** → Load and follow `skills/review-plan/SKILL.md`
- **"Create issues"** → Load and follow `skills/create-issues/SKILL.md`

---

## Step 3: Next Steps (Context-Dependent)

**After "Generate plan":**
```
AskUserQuestion:
  question: "Plan generated. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Deepen this plan"
      description: "Enrich with parallel research and review agents"
    - label: "Review this plan"
      description: "Multi-agent review with adversarial validation"
    - label: "Create issues"
      description: "Generate issues from plan"
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
    - label: "Create issues"
      description: "Generate issues from plan"
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
    - label: "Create issues"
      description: "Generate issues from approved plan"
    - label: "Start implementing"
      description: "Move to /implement to begin coding"
    - label: "Revise the plan"
      description: "Go back and modify based on review feedback"
    - label: "Done"
      description: "End workflow"
```

**After "Create issues":**
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
- **"Deepen this plan"** → Load `skills/deepen-plan/SKILL.md`
- **"Review this plan"** → Load `skills/review-plan/SKILL.md`
- **"Create issues"** → Load `skills/create-issues/SKILL.md`
- **"Start implementing"** → Suggest user invoke `/implement`
- **"Revise the plan"** → Return to Step 1 with "Generate plan" pre-selected
- **"Create another plan"** → Return to Step 1
- **"Done"** → End workflow

---

## Additional Skills Available

These can be invoked before planning or when explicitly requested:

- **Create ADR** — `skills/create-adr/SKILL.md` — Document architecture decisions
- **Brainstorm** — `skills/brainstorm/SKILL.md` — Structured divergent thinking (use BEFORE generating a plan, not after)

If the user mentions architecture decisions, offer ADR. If they want to explore approaches before committing, offer brainstorm.
