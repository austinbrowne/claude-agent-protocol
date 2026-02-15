---
name: workflows:ship
description: "Ship — commit, PR creation, refactoring, and finalization"
---

# /ship — Ship

**Workflow command.** Hub for shipping activities: committing code, creating PRs, refactoring, and final documentation.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Run `git diff --stat HEAD` and `git diff --staged --stat`** — are there code changes to ship?
2. **Check conversation context** — was a Fresh Eyes Review already completed in this session?

**If no changes exist:** Inform the user: "No code changes to ship. Run `/implement` first." End workflow.

**If changes exist:** Proceed to Step 1.

---

## Step 1: Select Shipping Activity

```
AskUserQuestion:
  question: "What would you like to do?"
  header: "Ship"
  options:
    - label: "Commit and create PR"
      description: "Commit changes and create a pull request (requires Fresh Eyes review)"
    - label: "Finalize project"
      description: "Final documentation updates, validation, and merge preparation"
    - label: "Refactor first"
      description: "Guided refactoring to improve code quality before shipping"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Commit and create PR"** → Load and follow `skills/commit-and-pr/SKILL.md`
  - This skill enforces the Fresh Eyes Review gate — if not yet run, it will trigger automatically
- **"Finalize project"** → Load and follow `skills/finalize/SKILL.md`
- **"Refactor first"** → Load and follow `skills/refactor/SKILL.md`

---

## Step 3: Next Steps — MANDATORY GATE

**CRITICAL: After EVERY skill completes, you MUST present the appropriate AskUserQuestion below. NEVER ask "what would you like to do next?" in plain text. NEVER skip this step. NEVER collapse it into the skill's output.**

Build the next-step menu based on what just happened:

**After "Refactor first"** (refactored code needs review before shipping):
```
AskUserQuestion:
  question: "Refactoring complete. Refactored code should be reviewed before shipping."
  header: "Next step"
  options:
    - label: "Review code"
      description: "Move to /review to review the refactored code"
    - label: "Commit and create PR"
      description: "Ship directly (will auto-trigger Fresh Eyes review)"
    - label: "Done"
      description: "End workflow"
```

**After "Commit and create PR" or "Finalize project":**
```
AskUserQuestion:
  question: "Shipping step complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Another shipping step"
      description: "Run another shipping activity (finalize, refactor)"
    - label: "Done"
      description: "End workflow"
```

**If "Review code":** Load `commands/review.md` and execute starting from Step 0. Do NOT skip any steps. Do NOT implement directly. Follow the command file exactly.
**If "Commit and create PR":** Load and follow `skills/commit-and-pr/SKILL.md`.
**If "Another shipping step":** Return to Step 0 (re-detect state, then Step 1).
**If "Capture learnings":** Load `commands/learn.md` and execute starting from Step 0. Do NOT skip any steps. Do NOT implement directly. Follow the command file exactly.
**If "Done":** End workflow.
