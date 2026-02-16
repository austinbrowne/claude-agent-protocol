---
name: workflows:ship
description: "Ship — commit, PR/MR creation, refactoring, and finalization"
---

# /ship — Ship

**Workflow command.** Hub for shipping activities: committing code, creating PRs/MRs, refactoring, and final documentation.

---

## Step 1: Select Shipping Activity

```
AskUserQuestion:
  question: "What would you like to do?"
  header: "Ship"
  options:
    - label: "Commit and create PR/MR"
      description: "Commit changes and create a pull request/merge request (requires Fresh Eyes review)"
    - label: "Finalize project"
      description: "Final documentation updates, validation, and merge preparation"
    - label: "Refactor first"
      description: "Guided refactoring to improve code quality before shipping"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Commit and create PR/MR"** → Load and follow `skills/commit-and-pr/SKILL.md`
  - This skill enforces the Fresh Eyes Review gate — if not yet run, it will trigger automatically
- **"Finalize project"** → Load and follow `skills/finalize/SKILL.md`
- **"Refactor first"** → Load and follow `skills/refactor/SKILL.md`

---

## Step 3: Next Steps

```
AskUserQuestion:
  question: "Shipping step complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Another shipping step"
      description: "Run another shipping activity (finalize, refactor)"
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Done"
      description: "End workflow"
```

**If "Another shipping step":** Return to Step 1.
**If "Capture learnings":** Suggest user invoke `/learn`.
**If "Done":** End workflow.
