---
description: "Code review — fresh eyes multi-agent review and protocol compliance check"
---

# /review — Code Review

**Workflow command.** Hub for code review activities: comprehensive multi-agent review and protocol compliance checking.

---

## Step 1: Select Review Scope

```
AskUserQuestion:
  question: "What kind of review would you like to run?"
  header: "Review"
  options:
    - label: "Fresh eyes review (full)"
      description: "13-agent smart selection review with adversarial validation"
    - label: "Fresh eyes review (lite)"
      description: "Quick 3-agent review (Security + Edge Case + Supervisor)"
    - label: "Review protocol compliance"
      description: "Check protocol compliance and generate status report"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Fresh eyes review (full)"** → Load and follow `skills/fresh-eyes-review/SKILL.md` (full mode)
- **"Fresh eyes review (lite)"** → Load and follow `skills/fresh-eyes-review/SKILL.md` (lite mode — Security + Edge Case + Supervisor only)
- **"Review protocol compliance"** → Load and follow `skills/review-protocol/SKILL.md`

---

## Step 3: Next Steps

```
AskUserQuestion:
  question: "Review complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Fix findings"
      description: "Address CRITICAL/HIGH findings, then re-run review"
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Ship it"
      description: "Move to /ship to commit and create PR"
    - label: "Done"
      description: "End workflow — address findings manually"
```

**If "Fix findings":** Help fix issues, then re-run Fresh Eyes Review.
**If "Capture learnings":** Suggest user invoke `/learn`.
**If "Ship it":** Suggest user invoke `/ship`.
**If "Done":** End workflow.
