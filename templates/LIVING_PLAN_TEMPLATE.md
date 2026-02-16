# Living Plan Template

Use this template when running `/start-issue` to create a living implementation plan that tracks progress.

---

```markdown
---
issue_id: "NNN"
title: "Issue title"
branch: "issue-NNN-brief-description"
started: YYYY-MM-DD
last_updated: YYYY-MM-DD
status: in_progress | blocked | complete
---

# Living Plan: Issue #NNN — [Title]

## Acceptance Criteria

- [ ] [Criterion 1 from issue]
- [ ] [Criterion 2 from issue]
- [ ] [Criterion 3 from issue]
- [ ] Tests passing with required coverage
- [ ] Security review completed (if applicable)

## Implementation Steps

- [ ] Step 1: [Description]
- [ ] Step 2: [Description]
- [ ] Step 3: [Description]
- [ ] Step 4: Generate tests
- [ ] Step 5: Run validation
- [ ] Step 6: Fresh Eyes Review
- [ ] Step 7: Commit and PR

## Past Learnings Applied

[Relevant solutions from `docs/solutions/` found during `/start-issue`]

- [Solution 1]: [How it applies]
- [Solution 2]: [How it applies]

(None found — if no relevant learnings exist)

## Progress Log

### [YYYY-MM-DD HH:MM] — Started
- Branch created: `issue-NNN-brief-description`
- Issue assigned to @me
- Implementation plan created

### [YYYY-MM-DD HH:MM] — [Milestone]
- [What was accomplished]
- [Commit: `abc1234` — "Part of #NNN"]

### [YYYY-MM-DD HH:MM] — [Milestone]
- [What was accomplished]
- [Commit: `def5678` — "Part of #NNN"]

## Commits

| Hash | Message | Scope |
|------|---------|-------|
| `abc1234` | Part of #NNN: [description] | [files] |

## Blockers / Notes

- [Any blockers encountered]
- [Decisions made during implementation]
```

---

**Filename convention:** `.todos/{issue_id}-plan.md`

**Examples:**
- `.todos/123-plan.md`
- `.todos/456-plan.md`

**Usage:**
- Created automatically by `/start-issue`
- Updated as implementation progresses (checkboxes, progress log)
- Serves as session resume point if conversation is interrupted
- Referenced by `/commit-and-pr` for change summary
