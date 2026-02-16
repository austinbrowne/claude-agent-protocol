---
name: start-issue
version: "1.1"
description: Issue startup methodology with living plan, past learnings, and branch management
referenced_by:
  - commands/implement.md
---

# Start Issue Skill

Methodology for beginning work on an issue with context loading, past learnings, living plan creation, and branch management.

> **Platform:** Commands below use GitHub (`gh`) syntax. For GitLab (`glab`) equivalents, see `platforms/gitlab.md`. Run `platforms/detect.md` once per session to determine your platform.

---

## When to Apply

- Have issues ready and want to start implementation
- Picking issue from backlog to work on

---

## Skills Referenced

- `skills/learn/SKILL.md` — For searching `docs/solutions/` to surface relevant past learnings
- `skills/todos/SKILL.md` — For creating living plans in `.todos/` and tracking progress

---

## Process

### 1. Load Issue Details

```bash
# GitHub:
gh issue view NNN --json title,body,labels,assignees,state
# GitLab:
glab issue view NNN
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

### 4. Assign Issue and Create Branch

```bash
# GitHub:
gh issue edit NNN --add-assignee @me
# GitLab:
glab issue update NNN --assignee @me

git checkout -b issue-NNN-brief-description
git push -u origin issue-NNN-brief-description
```

**Branch naming:** `issue-NNN-brief-description` (kebab-case from title).

### 5. Create Living Plan

**File:** `.todos/{issue_id}-plan.md`
**Template:** `templates/LIVING_PLAN_TEMPLATE.md`

Populate with: Issue ID/title, branch name, acceptance criteria, past learnings, implementation steps, progress log with start timestamp.

### 6. Update Issue

```bash
# GitHub:
gh issue comment NNN --body "Starting implementation on branch \`issue-NNN-brief-description\`"
# GitLab:
glab issue note NNN --message "Starting implementation on branch \`issue-NNN-brief-description\`"
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

- **Input**: Issue number
- **Output**: Branch created, living plan in `.todos/`, past learnings surfaced
- **Learnings search**: `agents/research/learnings-researcher.md`
- **Living plan template**: `templates/LIVING_PLAN_TEMPLATE.md`
- **Consumed by**: `/implement` workflow command
