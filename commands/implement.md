---
name: workflows:implement
description: "Implementation — start issues, team implementation, triage issues, generate tests, run validation, security review, and recovery"
---

# /implement — Implementation

**Workflow command.** Hub for all implementation activities: starting work on issues, team-based parallel implementation, triaging issue backlogs, generating tests, running validation, security review, and recovery from failures.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Step 0: State Detection and Assessment

Before presenting the menu, detect what exists and assess the best approach:

### 0a. Gather Signals

1. **Glob `docs/plans/*.md`** — do any approved plan files exist? Read YAML frontmatter, note plans with status `approved`.
2. **Run `gh issue list --limit 5 --json number,title,state,labels,body 2>/dev/null`** — are there open issues? Note `ready_for_dev` vs `needs_refinement` labels.
3. **Run `git diff --stat HEAD`** — are there uncommitted code changes?
4. **Check if `TeamCreate` tool is available** — is Agent Teams enabled?

### 0b. Assess Recommendation

Based on the signals, determine the recommended implementation path:

**If an approved plan exists AND TeamCreate is available:**
- Recommend "Implement plan" (team-implement handles swarmability internally)

**If `ready_for_dev` issues exist:**
- Recommend "Start issue" (start-issue handles complexity assessment internally — single-agent or team)

**If no plan and no issues:**
- Recommend "Triage issues"

Store the recommendation for Step 1.

**Direct entry supported:** `/implement start-issue 123` or `/implement team-implement` skips state detection and goes directly to the selected skill.

---

## Step 1: Select Implementation Activity

Build the AskUserQuestion dynamically based on Step 0 findings. **Place the recommended option first with "(Recommended)" suffix.** Include only options whose preconditions are satisfied:

| Option | Precondition | Always show? |
|--------|-------------|--------------|
| Start issue | GitHub issues exist | Only if issues found |
| Implement plan | Approved plan exists AND TeamCreate available | Only if preconditions met |
| Triage issues | Always available | Yes |
| Generate tests | Code changes exist | Only if changes found |

```
AskUserQuestion:
  question: "Which implementation step would you like to run?"
  header: "Implement"
  options:
    # Place the recommended option FIRST with "(Recommended)" in the label.
    # Include only options whose preconditions are met from Step 0.
    # Descriptions below are for reference:
    - label: "Start issue (Recommended)"  # or without (Recommended) if not the top pick
      description: "Full implementation from a GitHub issue — research, assess complexity, implement (single-agent or team), test, validate"
    - label: "Implement plan"
      description: "Team-based plan implementation — swarmability assessment with parallel execution"
    - label: "Triage issues"
      description: "Batch-triage and plan open GitHub issues — get them ready_for_dev"
    - label: "Generate tests"
      description: "Generate comprehensive test suites for changed code"
```

**Additional options available (show if user selects "Other"):**
- Run validation — Execute tests + coverage + lint + security checks
- Security review — Run OWASP security checklist on code changes

**If no preconditions are met** (no plans, no issues, no changes): Show "Triage issues" and inform the user: "No plans or issues found. Run `/plan` to create a plan, or `/file-issue` to capture work."

---

## Step 2: Execute Selected Skill

**Based on selection:**

- **"Start issue"** → Invoke `Skill(skill="godmode:start-issue")`
- **"Implement plan"** → Invoke `Skill(skill="godmode:team-implement")`
- **"Triage issues"** → Invoke `Skill(skill="godmode:triage-issues")`
- **"Generate tests"** → Invoke `Skill(skill="godmode:generate-tests")`
- **"Run validation"** → Invoke `Skill(skill="godmode:run-validation")`
- **"Security review"** → Invoke `Skill(skill="godmode:security-review")`

---

## Step 3: Next Steps — MANDATORY GATE

**CRITICAL: After EVERY skill completes, you MUST present the appropriate AskUserQuestion below. NEVER ask "what would you like to do next?" in plain text. NEVER skip this step. NEVER collapse it into the skill's output.**

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

**If "Generate tests":** Invoke `Skill(skill="godmode:generate-tests")`.
**If "Review code":** Invoke `Skill(skill="godmode:review")`. Execute from Step 0. Do NOT skip any steps.
**If "Another implementation step":** Return to Step 0 (re-detect state, then Step 1).
**If "Recovery":** Invoke `Skill(skill="godmode:recovery")`.
**If "Done":** End workflow.
