---
name: workflows:plan
description: "Planning & requirements — PRD generation, deepening, review, issues, and ADR"
---

# /plan — Planning & Requirements

**Workflow command.** Hub for all planning activities: PRD creation, plan enrichment, plan review, issue creation, and architecture decision records.

---

## Step 1: Select Planning Activity

```
AskUserQuestion:
  question: "Which planning step would you like to run?"
  header: "Plan"
  options:
    - label: "Generate PRD"
      description: "Create a Product Requirements Document (Lite or Full)"
    - label: "Deepen existing plan"
      description: "Enrich a PRD with parallel research and review agents"
    - label: "Review plan"
      description: "Multi-agent plan review with adversarial validation"
    - label: "Create GitHub issues"
      description: "Generate GitHub issues from an approved PRD"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Generate PRD"** → Load and follow `skills/generate-prd/SKILL.md`
- **"Deepen existing plan"** → Load and follow `skills/deepen-plan/SKILL.md`
- **"Review plan"** → Load and follow `skills/review-plan/SKILL.md`
- **"Create GitHub issues"** → Load and follow `skills/create-issues/SKILL.md`

---

## Step 3: Next Steps

```
AskUserQuestion:
  question: "Planning step complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Another planning step"
      description: "Run another planning activity (deepen, review, issues, ADR)"
    - label: "Brainstorm approaches"
      description: "Structured divergent thinking before committing to a solution"
    - label: "Start implementing"
      description: "Move to /implement to begin coding"
    - label: "Done"
      description: "End workflow"
```

**If "Another planning step":** Return to Step 1.
**If "Brainstorm approaches":** Load and follow `skills/brainstorm/SKILL.md`.
**If "Start implementing":** Suggest user invoke `/implement`.
**If "Done":** End workflow.

---

## Additional Skills Available

These can also be invoked within the planning workflow:

- **Create ADR** — `skills/create-adr/SKILL.md` — Document architecture decisions
- **Brainstorm** — `skills/brainstorm/SKILL.md` — Structured divergent thinking

If the user mentions architecture decisions or brainstorming, offer these skills as options.
