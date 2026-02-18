---
name: ship
description: "Ship — commit, PR creation, and finalization"
invokable: true
---

# /ship — Ship

Hub for shipping activities: committing code, creating PRs, and final documentation.

{{{ input }}}

---

## Step 0: State Detection

Before presenting the menu, gather signals and assess the shipping state:

**Signals to gather:**
1. **`git diff --stat HEAD` + `git diff --staged --stat`** — uncommitted or unstaged changes? Run in the terminal. Adjust command syntax for PowerShell on Windows.
2. **`git log --oneline @{upstream}..HEAD 2>/dev/null`** — unpushed local commits? Adjust command syntax for PowerShell on Windows.
3. **Check for existing PR** — Use `gh` (GitHub) or `glab` (GitLab) depending on the platform. Run the equivalent of `gh pr list --head $(git branch --show-current) --json number,state,url --limit 1 2>/dev/null`. If the CLI is unavailable or not authenticated, treat PR signals as unknown (no PR detected).
4. **Check `.todos/review-verdict.md`** — was Fresh Eyes Review completed? What verdict? If the file doesn't exist or is stale (timestamp older than the branch's latest commit), fall back to checking conversation context for review verdict keywords (APPROVED, BLOCK, etc.).

**Assess recommendation (first matching row wins):**

| State | Recommendation |
|-------|---------------|
| No uncommitted changes + no unpushed commits + no PR | Halt: "Nothing to ship. Run `/implement` first." End workflow. |
| Uncommitted changes + PR exists (open) | Recommend "Commit and update PR" |
| Uncommitted changes + review APPROVED | Recommend "Commit and create PR" |
| Uncommitted changes + no review detected (or REVISION_REQUESTED) | Recommend "Commit and create PR" — note: "no review detected, commit-and-pr will auto-trigger if needed" |
| No uncommitted changes + unpushed commits + no PR | Recommend "Push and create PR" |
| No uncommitted changes + unpushed commits + PR exists (open) | Recommend "Finalize" — PR already up to date |
| PR exists, open, everything pushed | Recommend "Finalize" |
| PR exists, merged | Recommend "Capture learnings" or end |

**Error handling:** If the issue tracker CLI is not installed or not authenticated, treat PR signals as unknown. If `git log @{upstream}..HEAD` fails (no upstream configured), treat as "no unpushed commits detected."

---

## Step 1: Select Shipping Activity

Build the menu dynamically based on Step 0 assessment. Recommended option appears first with "(Recommended)" suffix. Only show options whose preconditions are met.

**If uncommitted changes exist + review APPROVED:**

Present the following options and WAIT for the user's response before proceeding:

1. **Commit and create PR (Recommended)** — Commit changes, push, and create a pull request
2. **Finalize first** — Run final documentation and validation before committing

Do NOT proceed until the user selects an option.

**If uncommitted changes exist + no review detected:**

Present the following options and WAIT for the user's response before proceeding:

1. **Commit and create PR (Recommended)** — Commit changes, push, and create PR — will auto-trigger Fresh Eyes review
2. **Run review first** — Move to `/review` before committing

Do NOT proceed until the user selects an option.

**If uncommitted changes + PR exists (open):**

Present the following options and WAIT for the user's response before proceeding:

1. **Commit and update PR (Recommended)** — Commit new changes and push to the existing PR
2. **Finalize** — Run final documentation and validation

Do NOT proceed until the user selects an option.

**If no uncommitted changes + unpushed commits + no PR:**

Present the following options and WAIT for the user's response before proceeding:

1. **Push and create PR (Recommended)** — Push commits and create a pull request
2. **Finalize first** — Run final documentation and validation before pushing

Do NOT proceed until the user selects an option.

**If PR exists (open) + everything pushed:**

Present the following options and WAIT for the user's response before proceeding:

1. **Finalize (Recommended)** — Final documentation, validation, close issue, update plan status
2. **Capture learnings** — Move to `/learn` to capture knowledge from this session
3. **Done** — End workflow

Do NOT proceed until the user selects an option.

**If PR exists, merged:**

Present the following options and WAIT for the user's response before proceeding:

1. **Capture learnings (Recommended)** — Move to `/learn` to capture knowledge from this session
2. **Done** — End workflow

Do NOT proceed until the user selects an option.

---

## Step 2: Execute Selected Activity

Based on selection, execute the corresponding command:

- **"Commit and create PR"** or **"Commit and update PR"** or **"Push and create PR"** — Execute the `/commit-and-pr` command. This enforces the Fresh Eyes Review gate — if not yet run, it will trigger automatically.
- **"Finalize"** or **"Finalize first"** — Execute the `/finalize` command.
- **"Run review first"** — Execute the `/review` command from Step 0. Do NOT skip any steps. After review completes, return to Step 0 of this command (re-detect state).
- **"Capture learnings"** — Execute the `/learn` command from Step 0. Do NOT skip any steps.
- **"Done"** — End workflow.

---

## Step 3: Next Steps

After the selected activity completes, present the appropriate context-aware menu.

**After commit-and-pr succeeded** (commit hash and/or PR URL visible):

Present the following options and WAIT for the user's response before proceeding:

1. **Finalize (Recommended)** — Final documentation, close issue, update plan status
2. **Bump version** — Bump version on feature branch + marketplace on main
3. **Capture learnings** — Move to `/learn` to capture knowledge from this session
4. **Done** — End workflow

Do NOT proceed until the user selects an option.

**After finalize completed:**

Present the following options and WAIT for the user's response before proceeding:

1. **Bump version (Recommended)** — Bump version on feature branch + marketplace on main
2. **Capture learnings** — Move to `/learn` to capture knowledge from this session
3. **Done** — End workflow

Do NOT proceed until the user selects an option.

**After activity failed** (error occurred during execution):

Present the following options and WAIT for the user's response before proceeding:

1. **Retry** — Re-run the same shipping step
2. **Run review** — Move to `/review` to check code before retrying
3. **Done** — End workflow — address the issue manually

Do NOT proceed until the user selects an option.

**Routing:**
- **"Finalize"** — Execute the `/finalize` command. After it completes, return to Step 3.
- **"Bump version"** — Execute the `/bump-version` command. After it completes, return to Step 3.
- **"Capture learnings"** — Execute the `/learn` command from Step 0. Do NOT skip any steps.
- **"Retry"** — Return to Step 2 and re-execute the same activity.
- **"Run review"** — Execute the `/review` command from Step 0. Do NOT skip any steps. After review completes, return to Step 0 of this command (re-detect state).
- **"Done"** — End workflow.
