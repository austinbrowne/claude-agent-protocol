---
name: implement
description: "Implementation hub — start issues, plan implementation, triage, tests, validation, security review, and recovery"
invokable: true
---

# /implement — Implementation

Hub for all implementation activities: starting work on issues, sequential plan implementation, triaging issue backlogs, generating tests, running validation, security review, and recovery from failures.

{{{ input }}}

---

## Step 0: State Detection and Assessment

Before presenting the menu, detect what exists and assess the best approach:

### 0a. Gather Signals

1. **Glob `docs/plans/*.md`** — do any approved plan files exist? Read YAML frontmatter, note plans with `status: approved`.
2. **Check issue tracker** — Use `gh` (GitHub) or `glab` (GitLab) depending on the platform. Run the equivalent of `gh issue list --limit 5 --json number,title,state,labels,body 2>/dev/null`. Note `ready_for_dev` vs `needs_refinement` labels. If the CLI is unavailable or not authenticated, skip this signal.
3. **Run `git diff --stat HEAD` in the terminal** — are there uncommitted code changes? Adjust command syntax for PowerShell on Windows.

### 0b. Assess Recommendation

Based on the signals, determine the recommended implementation path:

**If an approved plan exists:**
- Recommend "Implement plan" (sequential plan implementation — process each task in order)

**If `ready_for_dev` issues exist:**
- Recommend "Start issue" (assess complexity, implement, test)

**If no plan and no issues:**
- Recommend "Triage issues"

Store the recommendation for Step 1.

**Direct entry supported:** If the user provides arguments like `start-issue 123` or `team-implement`, skip state detection and go directly to the selected skill.

---

## Step 1: Select Implementation Activity

Build the menu dynamically based on Step 0 findings. Place the recommended option first with "(Recommended)" suffix. Include only options whose preconditions are satisfied:

| Option | Precondition | Always show? |
|--------|-------------|--------------|
| Start issue | Issues exist in tracker | Only if issues found |
| Implement plan | Approved plan exists | Only if plan found |
| Triage issues | Always available | Yes |
| Generate tests | Code changes exist | Only if changes found |

Present the following options and WAIT for the user's response before proceeding:

1. **Start issue (Recommended if issues exist)** — Full implementation from an issue — research, assess complexity, implement, test, validate
2. **Implement plan (Recommended if approved plan exists)** — Sequential plan implementation — process each task in order, test, commit
3. **Triage issues** — Batch-triage and plan open issues — get them ready_for_dev
4. **Generate tests** — Generate comprehensive test suites for changed code

**Additional options (mention these as available if the user asks):**
- **Run validation** — Execute tests + coverage + lint + security checks
- **Security review** — Run OWASP security checklist on code changes

Do NOT proceed until the user selects an option.

**If no preconditions are met** (no plans, no issues, no changes): Show "Triage issues" and inform the user: "No plans or issues found. Run `/plan` to create a plan, or create an issue to capture work."

---

## Step 2: Execute Selected Activity

Based on selection, execute the corresponding command:

- **"Start issue"** — Execute the `/start-issue` command
- **"Implement plan"** — Execute the `/team-implement` command (runs sequentially — process each plan task in order: implement, test, commit, then move to the next task)
- **"Triage issues"** — Execute the `/triage-issues` command
- **"Generate tests"** — Execute the `/generate-tests` command
- **"Run validation"** — Execute the `/run-validation` command
- **"Security review"** — Execute the `/security-review` command

---

## Step 3: Next Steps

After the selected activity completes, present the appropriate menu.

**If the activity completed successfully:**

Present the following options and WAIT for the user's response before proceeding:

1. **Generate tests** — Generate test suites for the code you just wrote
2. **Review code** — Move to `/review` for code review
3. **Another implementation step** — Run another implementation activity
4. **Done** — End workflow

Do NOT proceed until the user selects an option.

**If the activity failed or tests failed:**

Present the following options and WAIT for the user's response before proceeding:

1. **Recovery** — Handle failed implementation — Continue/Rollback/Abandon
2. **Another implementation step** — Try a different approach
3. **Done** — End workflow — address issues manually

Do NOT proceed until the user selects an option.

**Routing:**
- **"Generate tests"** — Execute the `/generate-tests` command.
- **"Review code"** — Execute the `/review` command from Step 0. Do NOT skip any steps.
- **"Another implementation step"** — Return to Step 0 (re-detect state, then Step 1).
- **"Recovery"** — Execute the `/recovery` command.
- **"Done"** — End workflow.
