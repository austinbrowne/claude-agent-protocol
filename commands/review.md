---
name: workflows:review
description: "Code review — fresh eyes multi-agent review and protocol compliance check"
---

# /review — Code Review

**Workflow command.** Hub for code review activities: comprehensive multi-agent review and protocol compliance checking.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Run `git diff --stat HEAD` and `git diff --staged --stat`** — are there code changes to review?
2. **Run `git log --oneline -5`** — are there recent commits that could be reviewed?

**If no changes AND no recent commits:** Inform the user: "No code changes detected. Run `/implement` first, or specify a commit range to review." End workflow.

**If changes exist:** Proceed to Step 1.

---

## Step 1: Select Review Scope

```
AskUserQuestion:
  question: "What kind of review would you like to run?"
  header: "Review"
  options:
    - label: "Fresh eyes review (full)"
      description: "11-agent smart selection review with adversarial validation"
    - label: "Fresh eyes review (lite)"
      description: "Quick 3-agent review (Security + Edge Case + Supervisor)"
    - label: "Review protocol compliance"
      description: "Check protocol compliance and generate status report"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Fresh eyes review (full)"** → Invoke `Skill(skill="godmode:fresh-eyes-review", args="full mode")`
- **"Fresh eyes review (lite)"** → Invoke `Skill(skill="godmode:fresh-eyes-review", args="lite mode — Security + Edge Case + Supervisor only")`
- **"Review protocol compliance"** → Invoke `Skill(skill="godmode:review-protocol")`

---

## Step 3: Next Steps — MANDATORY GATE

**CRITICAL: After EVERY skill completes, you MUST present the appropriate AskUserQuestion below. NEVER ask "what would you like to do next?" in plain text. NEVER skip this step. NEVER collapse it into the skill's output.**

**Context-aware menu:** Check the fresh-eyes-review outcome before presenting options. The menu varies based on what happened inside the skill.

**If fixes were already applied inside the skill (user fixed findings AND skipped or completed re-review):**
```
AskUserQuestion:
  question: "Review complete — findings addressed. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Ship it (Recommended)"
      description: "Move to /ship to commit and create PR"
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Re-run full review"
      description: "Run another fresh-eyes-review pass on the current state"
    - label: "Done"
      description: "End workflow"
```

**If verdict was APPROVED (no findings):**
```
AskUserQuestion:
  question: "Review complete — no issues found. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Ship it (Recommended)"
      description: "Move to /ship to commit and create PR"
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Done"
      description: "End workflow"
```

**If findings were dismissed or review-protocol was run:**
```
AskUserQuestion:
  question: "Review complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Fix findings"
      description: "Address CRITICAL/HIGH findings, then re-run review"
    - label: "Ship it"
      description: "Move to /ship to commit and create PR"
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Done"
      description: "End workflow — address findings manually"
```

**Routing:**
- **"Fix findings":** Help fix issues, then re-run Fresh Eyes Review.
- **"Capture learnings":** Load `commands/learn.md` and execute starting from Step 0. Do NOT skip any steps. Follow the command file exactly.
- **"Ship it":** Invoke `Skill(skill="godmode:ship")`. Execute from Step 0. Do NOT skip any steps.
- **"Re-run full review":** Return to Step 2 and execute fresh-eyes-review again.
- **"Done":** End workflow.
