---
name: review
description: "Code review — fresh eyes review and protocol compliance check"
invokable: true
---

# /review — Code Review

Hub for code review activities: comprehensive review with multiple reviewer personas and protocol compliance checking.

{{{ input }}}

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Run `git diff --stat HEAD` and `git diff --staged --stat` in the terminal** — are there code changes to review? Adjust command syntax for PowerShell on Windows.
2. **Run `git log --oneline -5` in the terminal** — are there recent commits that could be reviewed?

**If no changes AND no recent commits:** Inform the user: "No code changes detected. Run `/implement` first, or specify a commit range to review." End workflow.

**If changes exist:** Proceed to Step 1.

---

## Step 1: Select Review Scope

Present the following options and WAIT for the user's response before proceeding:

1. **Smart review (Recommended)** — Assess diff and recommend appropriate depth — lite, standard, or full
2. **Fresh eyes review (full)** — Comprehensive review using 11 sequential reviewer personas with adversarial validation
3. **Fresh eyes review (lite)** — Quick 4-persona review (Security + Code Quality + Edge Case + Supervisor)
4. **Review protocol compliance** — Check protocol compliance and generate status report

Do NOT proceed until the user selects an option.

---

## Step 2: Execute Selected Activity

Based on selection, execute the review. For fresh eyes reviews, adopt each reviewer persona sequentially (rather than in parallel), applying its specific checklist to the code changes:

- **"Smart review"** — Execute the `/fresh-eyes-review` command in smart mode (assess diff and recommend depth)
- **"Fresh eyes review (full)"** — Execute the `/fresh-eyes-review` command in full mode. Review the diff through each of 11 specialist personas sequentially: Security, Code Quality, Edge Case, Performance, API Contract, Concurrency, Error Handling, Data Validation, Dependency, Testing Adequacy, Config & Secrets. Then consolidate and validate findings.
- **"Fresh eyes review (lite)"** — Execute the `/fresh-eyes-review` command in lite mode (Security + Code Quality + Edge Case + Supervisor personas only)
- **"Review protocol compliance"** — Execute the `/review-protocol` command

---

## Step 3: Next Steps

After the review completes, present the appropriate context-aware menu. Check the review outcome before presenting options.

**If fixes were already applied (user fixed findings during the review):**

Present the following options and WAIT for the user's response before proceeding:

1. **Ship it (Recommended)** — Move to `/ship` to commit and create PR
2. **Capture learnings** — Move to `/learn` to capture knowledge from this session
3. **Re-run full review** — Run another fresh-eyes-review pass on the current state
4. **Done** — End workflow

Do NOT proceed until the user selects an option.

**If verdict was APPROVED (no findings):**

Present the following options and WAIT for the user's response before proceeding:

1. **Ship it (Recommended)** — Move to `/ship` to commit and create PR
2. **Capture learnings** — Move to `/learn` to capture knowledge from this session
3. **Done** — End workflow

Do NOT proceed until the user selects an option.

**If findings were dismissed or review-protocol was run:**

Present the following options and WAIT for the user's response before proceeding:

1. **Fix findings** — Address CRITICAL/HIGH findings, then re-run review
2. **Ship it** — Move to `/ship` to commit and create PR
3. **Capture learnings** — Move to `/learn` to capture knowledge from this session
4. **Done** — End workflow — address findings manually

Do NOT proceed until the user selects an option.

**Routing:**
- **"Fix findings"** — Help fix issues, then re-run fresh eyes review.
- **"Capture learnings"** — Execute the `/learn` command from Step 0. Do NOT skip any steps.
- **"Ship it"** — Execute the `/ship` command from Step 0. Do NOT skip any steps.
- **"Re-run full review"** — Return to Step 2 and execute fresh-eyes-review again.
- **"Done"** — End workflow.
