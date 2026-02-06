---
name: workflows:implement
description: "Implementation — start issues, swarm plan, swarm issues, generate tests, run validation, security review, and recovery"
---

# /implement — Implementation

**Workflow command.** Hub for all implementation activities: starting work on issues, parallel swarm execution, generating tests, running validation, security review, and recovery from failures.

---

## Step 1: Select Implementation Activity

```
AskUserQuestion:
  question: "Which implementation step would you like to run?"
  header: "Implement"
  options:
    - label: "Start issue"
      description: "Begin work on a GitHub issue with living plan and past learnings"
    - label: "Swarm plan"
      description: "Parallel implementation of plan tasks using Agent Teams"
    - label: "Swarm issues"
      description: "Batch-implement multiple GitHub issues in parallel using Agent Teams"
    - label: "Generate tests"
      description: "Generate comprehensive test suites for your code"
```

**Additional options available (show if user selects "Other"):**
- Run validation — Execute tests + coverage + lint + security checks
- Security review — Run OWASP security checklist on code changes

**Direct entry supported:** `/implement start-issue 123` or `/implement swarm-plan` skips the menu and goes directly to the selected skill.

**Note:** Swarm plan and swarm issues require Agent Teams to be enabled. If TeammateTool is not available, inform the user and suggest standard `start-issue` instead.

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Start issue"** → Load and follow `skills/start-issue/SKILL.md`
- **"Swarm plan"** → Load and follow `skills/swarm-plan/SKILL.md`
- **"Swarm issues"** → Load and follow `skills/swarm-issues/SKILL.md`
- **"Generate tests"** → Load and follow `skills/generate-tests/SKILL.md`
- **"Run validation"** → Load and follow `skills/run-validation/SKILL.md`
- **"Security review"** → Load and follow `skills/security-review/SKILL.md`

---

## Step 3: Next Steps

```
AskUserQuestion:
  question: "Implementation step complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Another implementation step"
      description: "Run another implementation activity (tests, validation, security)"
    - label: "Review code"
      description: "Move to /review for multi-agent code review"
    - label: "Recovery"
      description: "Handle failed implementation — Continue/Rollback/Abandon"
    - label: "Done"
      description: "End workflow"
```

**If "Another implementation step":** Return to Step 1.
**If "Review code":** Suggest user invoke `/review`.
**If "Recovery":** Load and follow `skills/recovery/SKILL.md`.
**If "Done":** End workflow.
