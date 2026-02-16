---
name: workflows:ship
description: "Ship — commit, PR creation, and finalization"
---

# /ship — Ship

**Workflow command.** Hub for shipping activities: committing code, creating PRs, and final documentation.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Step 0: State Detection

Before presenting the menu, gather signals and assess the shipping state:

**Signals to gather:**
1. **`git diff --stat HEAD` + `git diff --staged --stat`** — uncommitted or unstaged changes?
2. **`git log --oneline @{upstream}..HEAD 2>/dev/null`** — unpushed local commits?
3. **`gh pr list --head $(git branch --show-current) --json number,state,url --limit 1 2>/dev/null`** — does a PR already exist for this branch? What state (open, merged, closed)?
4. **Check `.todos/review-verdict.md`** — was Fresh Eyes Review completed? What verdict? If the file doesn't exist or is stale (timestamp older than the branch's latest commit), fall back to checking conversation context for review verdict keywords (APPROVED, BLOCK, etc.).

**Assess recommendation (first matching row wins):**

| State | Recommendation |
|-------|---------------|
| No uncommitted changes + no unpushed commits + no PR | Halt: "Nothing to ship. Run `/implement` first." End workflow. |
| Uncommitted changes + PR exists (open) | Recommend "Commit and update PR" |
| Uncommitted changes + review APPROVED | Recommend "Commit and create PR" |
| Uncommitted changes + no review detected (or REVISION_REQUESTED) | Recommend "Commit and create PR" — note in description: "no review detected, commit-and-pr will auto-trigger if needed" |
| No uncommitted changes + unpushed commits + no PR | Recommend "Push and create PR" |
| No uncommitted changes + unpushed commits + PR exists (open) | Recommend "Finalize" — PR already up to date |
| PR exists, open, everything pushed | Recommend "Finalize" |
| PR exists, merged | Recommend "Capture learnings" or end |

**Error handling:** If `gh` is not installed or not authenticated, treat PR signals as unknown (no PR detected). If `git log @{upstream}..HEAD` fails (no upstream configured), treat as "no unpushed commits detected."

---

## Step 1: Select Shipping Activity — MANDATORY GATE

**Build the menu dynamically based on Step 0 assessment.** Recommended option appears first with "(Recommended)" suffix. Only show options whose preconditions are met.

**If uncommitted changes exist + review APPROVED:**
```
AskUserQuestion:
  question: "Changes ready to ship. What would you like to do?"
  header: "Ship"
  options:
    - label: "Commit and create PR (Recommended)"
      description: "Commit changes, push, and create a pull request"
    - label: "Finalize first"
      description: "Run final documentation and validation before committing"
```

**If uncommitted changes exist + no review detected:**
```
AskUserQuestion:
  question: "Changes ready to ship (no review detected — commit-and-pr will auto-trigger if needed)."
  header: "Ship"
  options:
    - label: "Commit and create PR (Recommended)"
      description: "Commit changes, push, and create PR — will auto-trigger Fresh Eyes review"
    - label: "Run review first"
      description: "Move to /review before committing"
```

**If uncommitted changes + PR exists (open):**
```
AskUserQuestion:
  question: "PR #{number} exists. You have additional uncommitted changes."
  header: "Ship"
  options:
    - label: "Commit and update PR (Recommended)"
      description: "Commit new changes and push to the existing PR"
    - label: "Finalize"
      description: "Run final documentation and validation"
```

**If no uncommitted changes + unpushed commits + no PR:**
```
AskUserQuestion:
  question: "Local commits ready to push. No PR exists yet."
  header: "Ship"
  options:
    - label: "Push and create PR (Recommended)"
      description: "Push commits and create a pull request"
    - label: "Finalize first"
      description: "Run final documentation and validation before pushing"
```

**If PR exists (open) + everything pushed:**
```
AskUserQuestion:
  question: "PR #{number} is open and up to date."
  header: "Ship"
  options:
    - label: "Finalize (Recommended)"
      description: "Final documentation, validation, close issue, update plan status"
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Done"
      description: "End workflow"
```

**If PR exists, merged:**
```
AskUserQuestion:
  question: "PR #{number} has been merged."
  header: "Ship"
  options:
    - label: "Capture learnings (Recommended)"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Done"
      description: "End workflow"
```

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Commit and create PR"** or **"Commit and update PR"** or **"Push and create PR"** → Load and follow `skills/commit-and-pr/SKILL.md`
  - This skill enforces the Fresh Eyes Review gate — if not yet run, it will trigger automatically
- **"Finalize"** or **"Finalize first"** → Load and follow `skills/finalize/SKILL.md`
- **"Run review first"** → Load `commands/review.md` and execute starting from Step 0. Do NOT skip any steps. Follow the command file exactly. After review completes, return to Step 0 of this command (re-detect state).
- **"Capture learnings"** → Load `commands/learn.md` and execute starting from Step 0. Do NOT skip any steps. Follow the command file exactly.
- **"Done"** → End workflow.

---

## Step 3: Next Steps — MANDATORY GATE

**CRITICAL: After EVERY skill completes, you MUST present the appropriate AskUserQuestion below. NEVER ask "what would you like to do next?" in plain text. NEVER skip this step. NEVER collapse it into the skill's output.**

**Context-aware menu:** Check what happened in the conversation during skill execution.

**After commit-and-pr succeeded** (commit hash and/or PR URL in conversation):
```
AskUserQuestion:
  question: "Changes shipped. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Finalize (Recommended)"
      description: "Final documentation, close issue, update plan status"
    - label: "Capture learnings"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Done"
      description: "End workflow"
```

**After finalize completed:**
```
AskUserQuestion:
  question: "Finalization complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Capture learnings (Recommended)"
      description: "Move to /learn to capture knowledge from this session"
    - label: "Done"
      description: "End workflow"
```

**After skill failed** (error occurred during execution):
```
AskUserQuestion:
  question: "Shipping step failed. How would you like to proceed?"
  header: "Next step"
  options:
    - label: "Retry"
      description: "Re-run the same shipping step"
    - label: "Run review"
      description: "Move to /review to check code before retrying"
    - label: "Done"
      description: "End workflow — address the issue manually"
```

**Routing:**
- **"Finalize":** Load and follow `skills/finalize/SKILL.md`. After finalize completes, return to Step 3.
- **"Capture learnings":** Load `commands/learn.md` and execute starting from Step 0. Do NOT skip any steps. Follow the command file exactly.
- **"Retry":** Return to Step 2 and re-execute the same skill.
- **"Run review":** Load `commands/review.md` and execute starting from Step 0. Do NOT skip any steps. Follow the command file exactly. After review completes, return to Step 0 of this command (re-detect state).
- **"Done":** End workflow.
