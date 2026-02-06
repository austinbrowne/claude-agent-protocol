---
name: swarm-issues
version: "1.0"
description: Batch-implement multiple GitHub issues in parallel using Agent Teams
referenced_by:
  - commands/implement.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Swarm Issues Skill

Triage open GitHub issues for swarm-readiness, present candidates for user approval, and dispatch Agent Teams teammates to implement multiple issues in parallel — each following the full protocol pipeline.

---

## When to Apply

- Multiple open GitHub issues need implementation
- Issues are well-defined and largely independent
- Agent Teams is enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)
- User wants to accelerate backlog execution

---

## Prerequisites

- Agent Teams is available (TeammateTool in tool list)
- GitHub CLI (`gh`) is configured and authenticated
- Repository has open issues to triage
- If TeammateTool is NOT available, inform user and suggest standard `/implement` → `start-issue` for sequential execution

---

## Process

### Step 1: Fetch Open Issues

```bash
gh issue list --state open --json number,title,labels,body,assignees --limit 50
```

If no issues found: inform user and end skill.

### Step 2: Triage for Swarm-Readiness

Evaluate each issue against these criteria:

| Criterion | Check | Disqualifies If |
|-----------|-------|-----------------|
| **Clear acceptance criteria** | Body contains checkboxes, numbered criteria, or clear "done when" | No criteria or vague description |
| **Unassigned** | `assignees` is empty | Already assigned to someone |
| **Not blocked** | Labels don't include `blocked`, `needs-design`, `question`, `wontfix` | Has blocking label |
| **Implementation-sized** | Not an epic or meta-issue (no sub-issue checklist with 5+ items) | Too large for single teammate |
| **Independent** | Estimated affected files don't overlap significantly with other candidates | High file overlap with another candidate |

**For each issue, assess:**
- Readiness: READY / NOT_READY (with reason)
- Estimated affected files (inferred from title + body)
- Estimated complexity: SMALL / MEDIUM / LARGE

### Step 3: Detect File Overlap

For READY issues, compare estimated affected files:
- No overlap → fully independent
- Partial overlap → flag for user (can still swarm if user accepts risk)
- Heavy overlap → recommend sequential or same-teammate grouping

### Step 4: Present Candidates

```
Swarm Issues — Triage Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: [owner/repo]
Open issues scanned: [N]
Swarm-ready: [N]

Candidates:
  ✅ #123 — Add user avatar upload (SMALL, independent)
  ✅ #125 — Fix date formatting in reports (SMALL, independent)
  ✅ #128 — Add CSV export to dashboard (MEDIUM, independent)
  ⚠️ #130 — Update auth middleware (MEDIUM, overlaps with #132)
  ✅ #132 — Add rate limiting (MEDIUM, overlaps with #130)

Not ready:
  ❌ #124 — Redesign database schema (blocked label)
  ❌ #126 — Improve performance (no acceptance criteria)
  ❌ #129 — Epic: User management overhaul (too large)

Recommended batch: #123, #125, #128 (3 independent, no overlap)
With overlap risk: add #130 or #132 (not both)
```

```
AskUserQuestion:
  question: "Which issues should the swarm tackle?"
  header: "Issue batch"
  options:
    - label: "Recommended batch"
      description: "{N} independent issues with no file overlap"
    - label: "Custom selection"
      description: "I'll specify which issues to include"
    - label: "Cancel"
      description: "Don't swarm — I'll handle these sequentially"
```

**If "Recommended batch":** Proceed to Step 5 with recommended issues.
**If "Custom selection":** Ask user to list issue numbers. Validate selection (warn about overlaps). Proceed to Step 5.
**If "Cancel":** End skill.

### Step 5: Spawn Issue Implementation Team

1. Create a shared task list with one task per approved issue

2. Spawn one teammate per issue:

**Issue implementer teammate spawn prompt:**
```
You are implementing GitHub issue #{number}. Follow the FULL protocol pipeline — do not skip any step.

Issue: #{number} — {title}
Body:
{body}

Acceptance criteria:
{extracted criteria or "See issue body above"}

Labels: {labels}

Protocol pipeline (follow ALL steps in order):
1. Create and switch to branch: feat/issue-{number}-{slug}
2. Search docs/solutions/ for past learnings relevant to this issue
3. Create a living plan at .todos/{number}-plan.md with:
   - Issue reference
   - Acceptance criteria
   - Implementation steps
   - Progress tracking
4. Implement the solution
5. Generate tests (happy path + edge cases + error conditions)
6. Run validation: lint, type-check, all tests pass

Rules:
- Stay on YOUR branch — do not touch other branches
- Do NOT modify files that other teammates are working on
- If you discover a blocker, message the Lead immediately
- If the issue is unclear, message the Lead for clarification — don't guess
- When done, mark your task complete and message the Lead with:
  - Branch name
  - Files changed (list)
  - Summary of changes
  - Test results (pass/fail count)

Project context:
- Read CLAUDE.md for project conventions and coding standards
- Check docs/solutions/ for past learnings BEFORE writing code
- Follow existing patterns in the codebase
```

### Step 6: Monitor Progress

While teammates work:

1. **Watch the shared task list** for completion updates
2. **Handle questions:** Teammates may ask for clarification on issue requirements — provide context or escalate to user
3. **Handle blockers:** If a teammate can't proceed:
   - Try to unblock (provide missing context, suggest workaround)
   - If unresolvable, message user
4. **Handle file conflicts:** If detected despite triage:
   - Determine priority
   - One teammate waits for the other
5. **Track overall progress:** Message teammates for status if tasks seem stalled

### Step 7: Completion

When all issues are implemented:

1. Shut down all teammates and clean up the team
2. Present a summary:

```
Swarm Issues — Complete
━━━━━━━━━━━━━━━━━━━━━━

Issues implemented: [N/N]
Teammates used: [N]

Results:
  ✅ #123 — Add user avatar upload
     Branch: feat/issue-123-avatar-upload
     Files: 4 changed | Tests: 8 passing
  ✅ #125 — Fix date formatting in reports
     Branch: feat/issue-125-date-formatting
     Files: 2 changed | Tests: 5 passing
  ✅ #128 — Add CSV export to dashboard
     Branch: feat/issue-128-csv-export
     Files: 6 changed | Tests: 12 passing

Branches ready for review:
  - feat/issue-123-avatar-upload
  - feat/issue-125-date-formatting
  - feat/issue-128-csv-export

Next step: Run /review on each branch for fresh-eyes review.
```

3. Suggest user proceed to `/review` for each branch.

---

## Notes

- **Full protocol per teammate:** Each teammate searches learnings, creates a living plan, writes tests, and runs validation. No shortcuts.
- **Branch strategy:** Each teammate on their own branch (`feat/issue-{number}-{slug}`). No merge conflicts between teammates.
- **Fresh-eyes review is separate:** Individual teammates validate their own code, but holistic review happens at the `/review` step per branch.
- **Batch size:** Recommend max ~5 teammates at a time for manageability. For larger backlogs, run multiple swarm batches.
- **Token cost:** Each teammate is a full Claude Code instance. Cost scales with batch size. Worthwhile for independent, well-defined issues.
- **Requires Agent Teams:** This skill requires the TeammateTool. Without it, use `/implement` → `start-issue` for sequential execution.
- **Issue quality matters:** Poorly defined issues waste teammate effort. The triage step filters aggressively for quality.

---

## Integration Points

- **Input**: Open GitHub issues fetched via `gh` CLI
- **Output**: Implemented branches with tests, ready for `/review`
- **Guide**: `guides/AGENT_TEAMS_GUIDE.md` (Pattern D: Issue Swarm)
- **Consumed by**: `/implement` workflow command
- **Followed by**: `/review` (fresh-eyes-review per branch)
