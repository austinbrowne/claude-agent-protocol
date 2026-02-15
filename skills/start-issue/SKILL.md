---
name: start-issue
version: "1.0"
description: Issue startup methodology with living plan, past learnings, and branch management
referenced_by:
  - commands/implement.md
---

# Start Issue Skill

Methodology for beginning work on a GitHub issue with context loading, past learnings, living plan creation, and branch management.

---

## When to Apply

- Have GitHub issues ready and want to start implementation
- Picking issue from backlog to work on

---

## Skills Referenced

- `skills/learn/SKILL.md` — For searching `docs/solutions/` to surface relevant past learnings
- `skills/todos/SKILL.md` — For creating living plans in `.todos/` and tracking progress

---

## Process

### 1. Load Issue Details

```bash
gh issue view NNN --json title,body,labels,assignees,state
```

Extract: Title, Description, Acceptance criteria, Labels, Plan reference, Dependencies.

### 2. Search Past Solutions

Launch Learnings Research Agent (reference: `agents/research/learnings-researcher.md`):
- Search by issue tags/labels
- Search by keywords from issue title and description
- Search by category matching issue type

Display relevant past solutions alongside issue context.

### 3. Verify Issue is Ready

Check for blockers (label `status: blocked`, dependency issues still open). Warn if missing acceptance criteria.

### 4. Assign Issue, Update Status, and Create Branch

```bash
gh issue edit NNN --add-assignee @me --remove-label "ready_for_dev" --add-label "status: in-progress"
git checkout -b issue-NNN-brief-description
git push -u origin issue-NNN-brief-description
```

**Label transition:** `ready_for_dev` → `status: in-progress`. This marks the issue as actively being worked on.

**Branch naming:** `issue-NNN-brief-description` (kebab-case from title).

**Plan status update:** Search the issue body for a path matching `docs/plans/YYYY-MM-DD-*.md` (bare path or markdown link). If multiple matches, use the first. If the matched path is a directory (no `.md` extension), skip. If the referenced plan file does not exist, log a warning ("Plan file {path} not found, skipping status update") and continue without blocking. If the plan file exists, read its YAML frontmatter `status:` field. Only update to `in_progress` if the current status is `approved` or `ready_for_review` (forward transitions only — do not regress `in_progress` or `complete`). If the frontmatter exists but has no `status:` field, add `status: in_progress`.

### 5. Create Living Plan

**File:** `.todos/{issue_id}-plan.md`
**Template:** `templates/LIVING_PLAN_TEMPLATE.md`

Populate with: Issue ID/title, branch name, acceptance criteria, past learnings, implementation steps, progress log with start timestamp.

### 6. Update Issue

```bash
gh issue comment NNN --body "Starting implementation on branch \`issue-NNN-brief-description\`"
```

### 7. Incremental Commit Guidance

During implementation:
- Intermediate commits: `Part of #NNN`
- Final commit: `Closes #NNN`
- Update living plan after each commit

---

## Pipeline Mode

When `--pipeline` is used:
1. Add ALL steps to todo list (implement → tests → validation → review → commit)
2. Automatically proceed through all steps
3. Only pause for errors or decisions

---

## Integration Points

- **Input**: GitHub issue number
- **Output**: Branch created, living plan in `.todos/`, past learnings surfaced
- **Learnings search**: `agents/research/learnings-researcher.md`
- **Living plan template**: `templates/LIVING_PLAN_TEMPLATE.md`
- **Consumed by**: `/implement` workflow command
