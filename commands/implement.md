---
name: workflows:implement
description: "Implementation — start issues, triage issues, swarm plan, generate tests, run validation, security review, and recovery"
---

# /implement — Implementation

**Workflow command.** Hub for all implementation activities: starting work on issues, triaging issue backlogs, parallel swarm execution, generating tests, running validation, security review, and recovery from failures.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Glob `docs/plans/*.md`** — do any plan files exist? Note the most recent one.
2. **Run `gh issue list --limit 5 --json number,title,state 2>/dev/null`** — are there open issues?
3. **Run `git diff --stat HEAD`** — are there uncommitted code changes?
4. **Check if `TeamCreate` tool is available** — is Agent Teams enabled?

Use these signals to build the menu in Step 1. **Only show options whose preconditions are met.**

**Direct entry supported:** `/implement start-issue 123` or `/implement swarm-plan` skips state detection and goes directly to the selected skill.

---

## Step 1: Select Implementation Activity

Build the AskUserQuestion dynamically based on Step 0 findings. Include only options whose preconditions are satisfied:

| Option | Precondition | Always show? |
|--------|-------------|--------------|
| Start issue | GitHub issues exist | Only if issues found |
| Swarm plan | Plan exists AND TeamCreate available | Only if both met |
| Triage issues | Always available | Yes |
| Generate tests | Code changes exist | Only if changes found |

```
AskUserQuestion:
  question: "Which implementation step would you like to run?"
  header: "Implement"
  options:
    # Include only options whose preconditions are met from Step 0.
    # If Start issue precondition not met, omit it.
    # If Swarm plan precondition not met, omit it.
    # If Generate tests precondition not met, omit it.
    # Always include Triage issues.
    # Descriptions below are for reference:
    - label: "Start issue"
      description: "Begin work on a GitHub issue with living plan and past learnings"
    - label: "Swarm plan"
      description: "Parallel implementation of plan tasks using Agent Teams"
    - label: "Triage issues"
      description: "Batch-triage and plan open GitHub issues — get them ready_for_dev"
    - label: "Generate tests"
      description: "Generate comprehensive test suites for changed code"
```

**Additional options available (show if user selects "Other"):**
- Run validation — Execute tests + coverage + lint + security checks
- Security review — Run OWASP security checklist on code changes

**If no preconditions are met** (no plans, no issues, no changes): Show "Triage issues" and inform the user: "No plans or issues found. Run `/plan` to create a plan, or triage existing issues."

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Start issue"** → Load and follow `skills/start-issue/SKILL.md`
- **"Swarm plan"** → Load and follow `skills/swarm-plan/SKILL.md`
- **"Triage issues"** → Load and follow `skills/triage-issues/SKILL.md`
- **"Generate tests"** → Load and follow `skills/generate-tests/SKILL.md`
- **"Run validation"** → Load and follow `skills/run-validation/SKILL.md`
- **"Security review"** → Load and follow `skills/security-review/SKILL.md`

---

## Step 3: Next Steps

Build the next-step menu based on what just happened:

**If the skill completed successfully:**
```
AskUserQuestion:
  question: "Implementation step complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Generate tests"
      description: "Generate test suites for the code you just wrote"
    - label: "Review code"
      description: "Move to /review for multi-agent code review"
    - label: "Another implementation step"
      description: "Run another implementation activity"
    - label: "Done"
      description: "End workflow"
```

**If the skill failed or tests failed:**
```
AskUserQuestion:
  question: "Implementation encountered issues. How would you like to proceed?"
  header: "Next step"
  options:
    - label: "Recovery"
      description: "Handle failed implementation — Continue/Rollback/Abandon"
    - label: "Another implementation step"
      description: "Try a different approach"
    - label: "Done"
      description: "End workflow — address issues manually"
```

**If "Generate tests":** Load and follow `skills/generate-tests/SKILL.md`.
**If "Review code":** Load `commands/review.md` and execute starting from Step 0. Do NOT skip any steps. Do NOT implement directly. Follow the command file exactly.
**If "Another implementation step":** Return to Step 0 (re-detect state, then Step 1).
**If "Recovery":** Load and follow `skills/recovery/SKILL.md`.
**If "Done":** End workflow.
