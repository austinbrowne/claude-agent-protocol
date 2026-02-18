---
name: plan
description: "Planning & requirements — plan generation, deepening, review, issues, and ADR"
invokable: true
---

# /plan — Planning & Requirements

Hub for all planning activities: plan creation, plan enrichment, plan review, issue creation, and architecture decision records.

{{{ input }}}

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Glob `docs/plans/*.md`** — do any plan files exist?
2. **Filter by status** — read the YAML frontmatter of each plan file. Only plans with `status:` other than `complete` count as active. Completed plans are historical records, not actionable. If ALL plans are `complete`, treat this as "no active plans."
3. If a plan was just generated in this conversation, note its path as the "active plan."

Use these signals to build the menu in Step 1. Only show options whose preconditions are met.

---

## Step 1: Select Planning Activity

**If NO active plans exist** (first time, all complete, or plans directory empty):

Present the following options and WAIT for the user's response before proceeding:

1. **Generate plan** — Create a plan (Minimal, Standard, or Comprehensive) with integrated research
2. **Create ADR** — Document an architecture decision record

Do NOT proceed until the user selects an option.

**If active plans exist** (any plan with status other than `complete`):

Present the following options and WAIT for the user's response before proceeding:

1. **Generate plan** — Create a new plan (Minimal, Standard, or Comprehensive) with integrated research
2. **Deepen existing plan** — Enrich a plan with research and review
3. **Review plan** — Plan review with adversarial validation
4. **Create issues** — Generate issues from an approved plan

Do NOT proceed until the user selects an option.

---

## Step 2: Execute Selected Activity

Based on selection, execute the corresponding command:

- **"Generate plan"** — Execute the `/generate-plan` command with the task description as arguments
- **"Deepen existing plan"** — Execute the `/deepen-plan` command with the plan path as arguments
- **"Review plan"** — Execute the `/review-plan` command with the plan path as arguments
- **"Create issues"** — Execute the `/create-issues` command with the plan path as arguments

---

## Step 3: Next Steps

After the selected activity completes, present the appropriate context-aware menu.

**After "Generate plan":**

Present the following options and WAIT for the user's response before proceeding:

1. **Review document quality** — Run structured quality review on the generated plan
2. **Deepen this plan** — Enrich with research and review
3. **Review this plan** — Plan review with adversarial validation
4. **Create issues** — Generate issues from this plan
5. **Start implementing** — Move to `/implement` to begin coding

Do NOT proceed until the user selects an option.

**After "Deepen existing plan":**

Present the following options and WAIT for the user's response before proceeding:

1. **Review this plan** — Plan review with adversarial validation
2. **Create issues** — Generate issues from this plan
3. **Start implementing** — Move to `/implement` to begin coding
4. **Done** — End workflow

Do NOT proceed until the user selects an option.

**After "Review plan":**

Present the following options and WAIT for the user's response before proceeding:

1. **Create issues** — Generate issues from the approved plan
2. **Start implementing** — Move to `/implement` to begin coding
3. **Revise the plan** — Go back and modify based on review feedback
4. **Done** — End workflow

Do NOT proceed until the user selects an option.

**After "Create issues":**

Present the following options and WAIT for the user's response before proceeding:

1. **Start implementing** — Move to `/implement` to begin coding
2. **Create another plan** — Start a new planning activity
3. **Done** — End workflow

Do NOT proceed until the user selects an option.

**Routing:**
- **"Review document quality"** — Execute the `/document-review` command with the plan path. After it completes, re-present the "After Generate plan" menu above.
- **"Deepen this plan"** — Execute the `/deepen-plan` command with the plan path.
- **"Review this plan"** — Execute the `/review-plan` command with the plan path.
- **"Create issues"** — Execute the `/create-issues` command with the plan path.
- **"Start implementing"** — Execute the `/implement` command from Step 0. Do NOT skip any steps.
- **"Revise the plan"** — Return to Step 1 with "Generate plan" pre-selected.
- **"Create another plan"** — Return to Step 1.
- **"Done"** — End workflow.

---

## Additional Skills Available

These can be invoked before planning or when explicitly requested:

- **Create ADR** — Document architecture decisions
- **Brainstorm** — Structured divergent thinking (use BEFORE generating a plan, not after)

If the user mentions architecture decisions, offer ADR. If they want to explore approaches before committing, offer brainstorm.
