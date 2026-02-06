---
name: swarm-issues
version: "1.1"
description: Batch-implement multiple GitHub issues in parallel using Agent Teams with two-phase planning and implementation
referenced_by:
  - commands/implement.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Swarm Issues Skill

Triage open GitHub issues, categorize by readiness, run a planning phase for sparse issues, then dispatch Agent Teams teammates to implement in parallel — each following the full protocol pipeline.

---

## When to Apply

- Multiple open GitHub issues need implementation
- Issues may be a mix of well-defined (`ready_for_dev`) and sparse (`needs_refinement`)
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

### Step 2: Triage and Categorize

Evaluate each issue and assign to one of three categories:

#### Category: READY

Issue is implementation-ready. Has clear acceptance criteria and a plan or enough detail to implement.

| Check | Passes If |
|-------|-----------|
| Labels include `ready_for_dev` | OR body has clear acceptance criteria (checkboxes, numbered criteria, "done when") |
| Unassigned | `assignees` is empty |
| Not blocked | Labels don't include `blocked`, `needs-design`, `question`, `wontfix` |
| Implementation-sized | Not an epic (no sub-issue checklist with 5+ items) |

#### Category: NEEDS_PLANNING

Issue exists but is too sparse to implement directly. Needs exploration and planning first.

| Check | Matches If |
|-------|-----------|
| Labels include `needs_refinement` | OR body is sparse (< 3 lines, no acceptance criteria, contains "TBD") |
| Unassigned | `assignees` is empty |
| Not blocked | No blocking labels |
| Implementation-sized | Not an epic |

#### Category: NOT_ELIGIBLE

| Reason | Examples |
|--------|---------|
| Already assigned | Someone is working on it |
| Blocked | Has `blocked`, `needs-design`, `question` label |
| Too large | Epic or meta-issue with 5+ sub-items |
| Insufficient info | Can't determine scope even for planning (single-line title, no body) |

**For each eligible issue (READY or NEEDS_PLANNING), also assess:**
- Estimated affected files (inferred from title + body)
- Estimated complexity: SMALL / MEDIUM / LARGE

### Step 3: Detect File Overlap

For all eligible issues (both READY and NEEDS_PLANNING), compare estimated affected files:
- No overlap → fully independent
- Partial overlap → flag for user (can still swarm if user accepts risk)
- Heavy overlap → recommend sequential or same-teammate grouping

### Step 4: Present Candidates

```
Swarm Issues — Triage Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: [owner/repo]
Open issues scanned: [N]

Ready for implementation:
  ✅ #123 — Add user avatar upload (SMALL, independent)
  ✅ #125 — Fix date formatting in reports (SMALL, independent)
  ✅ #128 — Add CSV export to dashboard (MEDIUM, independent)

Needs planning first:
  📋 #135 — Add webhook support (MEDIUM, sparse — needs_refinement)
  📋 #137 — Refactor auth module (MEDIUM, sparse — no acceptance criteria)
  📋 #140 — Support dark mode (SMALL, sparse — needs_refinement)
  📋 #142 — Add email notifications (LARGE, sparse — needs_refinement)

Not eligible:
  ❌ #124 — Redesign database schema (blocked label)
  ❌ #126 — Improve performance (assigned to @dev)
  ❌ #129 — Epic: User management overhaul (too large)

Recommendation: 3 issues ready to implement now, 4 need planning first.
```

```
AskUserQuestion:
  question: "How should the swarm handle these issues?"
  header: "Swarm mode"
  options:
    - label: "Plan and implement all"
      description: "Phase 1: plan the sparse issues. Phase 2: implement everything."
    - label: "Only implement ready ones"
      description: "Skip sparse issues — only swarm the {N} that are ready"
    - label: "Custom selection"
      description: "I'll specify which issues to include"
    - label: "Cancel"
      description: "Don't swarm — I'll handle these sequentially"
```

**If "Plan and implement all":** Proceed to Step 5 (Planning Phase) with NEEDS_PLANNING issues, then Step 6 (Implementation Phase) with all issues.
**If "Only implement ready ones":** Skip to Step 6 with READY issues only.
**If "Custom selection":** Ask user to list issue numbers. Categorize each. Proceed accordingly.
**If "Cancel":** End skill.

### Step 5: Planning Phase (for NEEDS_PLANNING issues)

Spawn planning teammates to enhance sparse issues before implementation.

**5a. Spawn planning teammates:**

One teammate per NEEDS_PLANNING issue. Each runs a streamlined enhance-issue process.

**Planning teammate spawn prompt:**
```
You are enhancing GitHub issue #{number} so it's ready for implementation. This issue is sparse and needs exploration and planning before anyone can build it.

Issue: #{number} — {title}
Body:
{body}

Labels: {labels}

Your job (follow ALL steps in order):
1. Explore the codebase to understand the problem area:
   - Search for affected files and modules
   - Understand current behavior and patterns
   - For bugs: form a root cause hypothesis
   - For features: identify integration points
2. Search docs/solutions/ for relevant past learnings
3. Generate a plan for this issue:
   - For bugs: a minimal plan (root cause, fix approach, affected files, test strategy)
   - For features: a minimal or standard plan (approach, affected files, acceptance criteria, test strategy)
4. Update the GitHub issue with enriched content:
   - Acceptance criteria (specific, testable)
   - Affected files
   - Technical approach summary
   - Testing notes and edge cases
   - Swap labels: remove needs_refinement, add ready_for_dev
   Command: gh issue edit {number} --body-file /tmp/enhanced-{number}.md
   Command: gh issue edit {number} --remove-label "needs_refinement" --add-label "ready_for_dev"
5. Message the Lead with your plan summary:
   - Issue title
   - Proposed approach (2-3 sentences)
   - Affected files
   - Acceptance criteria
   - Estimated complexity
   - Any concerns or risks

Mark your task as done when complete.

Rules:
- Do NOT start implementing — only plan and enhance
- If the issue is too vague to even plan, message the Lead explaining why
- If you discover the issue is actually an epic (too large), message the Lead
- Read CLAUDE.md for project conventions
- Check docs/solutions/ for past learnings
```

**5b. Collect and present plans for approval:**

After all planning teammates complete, collect their plan summaries and present to the user:

```
Swarm Issues — Planning Phase Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plans generated: [N/N]

#135 — Add webhook support
  Approach: Add webhook registry with event subscription model. New WebhookService
  class handles dispatch. DB table for registered endpoints.
  Files: 5 | Complexity: MEDIUM | Criteria: 4 acceptance items

#137 — Refactor auth module
  Approach: Extract token validation into middleware. Replace scattered auth checks
  with centralized AuthGuard pattern matching existing codebase conventions.
  Files: 8 | Complexity: MEDIUM | Criteria: 5 acceptance items

#140 — Support dark mode
  Approach: CSS custom properties for theme tokens. ThemeProvider context.
  localStorage persistence. System preference detection.
  Files: 3 | Complexity: SMALL | Criteria: 3 acceptance items

#142 — Add email notifications
  ⚠️ Teammate flagged: scope may be too large for single teammate.
  Suggest splitting into sub-issues or implementing core only.
```

```
AskUserQuestion:
  question: "Review the plans above. Proceed to implementation?"
  header: "Plan review"
  options:
    - label: "Approve all and implement"
      description: "All plans look good — proceed to implementation phase"
    - label: "Approve some, drop others"
      description: "I'll specify which planned issues to include"
    - label: "Revise plans"
      description: "I have feedback on specific plans before proceeding"
    - label: "Cancel implementation"
      description: "Stop here — planning is done but don't implement yet"
```

**If "Approve all and implement":** Shut down planning teammates. Proceed to Step 6 with ALL issues (READY + newly planned).
**If "Approve some, drop others":** Ask which to include. Shut down planning teammates. Proceed to Step 6 with selected issues.
**If "Revise plans":** Ask which plans need changes and what to change. Message relevant planning teammates with feedback. Re-collect and re-present.
**If "Cancel implementation":** Shut down planning teammates. Planning work is preserved (issues updated on GitHub). End skill.

### Step 6: Implementation Phase

Spawn implementation teammates for all approved issues.

**6a. Create shared task list** with one implementation task per approved issue.

**6b. Spawn one teammate per issue:**

**Implementation teammate spawn prompt:**
```
You are implementing GitHub issue #{number}. Follow the FULL protocol pipeline — do not skip any step.

Issue: #{number} — {title}
Body:
{body}

Acceptance criteria:
{extracted criteria}

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

### Step 7: Monitor Progress

While implementation teammates work:

1. **Watch the shared task list** for completion updates
2. **Handle questions:** Teammates may ask for clarification on issue requirements — provide context or escalate to user
3. **Handle blockers:** If a teammate can't proceed:
   - Try to unblock (provide missing context, suggest workaround)
   - If unresolvable, message user
4. **Handle file conflicts:** If detected despite triage:
   - Determine priority
   - One teammate waits for the other
5. **Track overall progress:** Message teammates for status if tasks seem stalled

### Step 8: Completion

When all issues are implemented:

1. Shut down all teammates and clean up the team
2. Present a summary:

```
Swarm Issues — Complete
━━━━━━━━━━━━━━━━━━━━━━

Issues implemented: [N/N]
Planning phase: [N] issues enhanced from sparse → ready_for_dev
Implementation phase: [N] issues implemented

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
  ✅ #135 — Add webhook support (planned + implemented)
     Branch: feat/issue-135-webhook-support
     Files: 5 changed | Tests: 10 passing
  ✅ #137 — Refactor auth module (planned + implemented)
     Branch: feat/issue-137-auth-refactor
     Files: 8 changed | Tests: 15 passing

Branches ready for review:
  - feat/issue-123-avatar-upload
  - feat/issue-125-date-formatting
  - feat/issue-128-csv-export
  - feat/issue-135-webhook-support
  - feat/issue-137-auth-refactor

Next step: Run /review on each branch for fresh-eyes review.
```

3. Suggest user proceed to `/review` for each branch.

---

## Notes

- **Two-phase approach:** Sparse issues get planned before anyone writes code. User approves plans before implementation starts. This preserves the protocol's quality gates.
- **Planning teammates only plan.** They explore, generate a plan, update the GitHub issue, and stop. They do NOT implement. This keeps the planning/implementation boundary clean.
- **Implementation teammates only implement.** They pick up well-defined issues (either originally READY or freshly planned) and follow the full protocol pipeline.
- **Full protocol per implementation teammate:** Each searches learnings, creates a living plan, writes tests, and runs validation. No shortcuts.
- **Branch strategy:** Each implementation teammate on their own branch (`feat/issue-{number}-{slug}`). No merge conflicts between teammates.
- **Fresh-eyes review is separate:** Individual teammates validate their own code, but holistic review happens at the `/review` step per branch.
- **Batch size:** Recommend max ~5 teammates at a time per phase. For larger backlogs, run multiple swarm batches.
- **Token cost:** Two-phase swarms use more tokens (planning + implementation). Worthwhile when sparse issues would otherwise waste implementation effort.
- **Requires Agent Teams:** This skill requires the TeammateTool. Without it, use `/enhance-issue` + `/implement` → `start-issue` for sequential execution.
- **Planning work persists:** Even if the user cancels after the planning phase, the GitHub issues are already updated with enriched content and `ready_for_dev` labels. That work isn't lost.

---

## Integration Points

- **Input**: Open GitHub issues fetched via `gh` CLI
- **Planning phase**: Streamlined version of `skills/enhance-issue/SKILL.md` (explore → plan → update issue)
- **Implementation phase**: Full protocol pipeline per teammate
- **Output**: Implemented branches with tests, ready for `/review`
- **Guide**: `guides/AGENT_TEAMS_GUIDE.md` (Pattern D: Issue Swarm)
- **Consumed by**: `/implement` workflow command
- **Followed by**: `/review` (fresh-eyes-review per branch)
