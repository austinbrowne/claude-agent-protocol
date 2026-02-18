---
name: triage-issues
description: "Batch-triage and plan open GitHub issues -- categorize by readiness, plan sparse ones, stop when all are ready_for_dev"
---

# Triage Issues Skill

Fetch open GitHub issues, categorize by readiness, and sequentially plan any sparse issues. Stops when all selected issues are `ready_for_dev` -- implementation is handled separately via `/implement` per issue.

> **Note on parallel execution:** The original Claude Code version of this skill launches parallel subagents for planning multiple sparse issues simultaneously. In continue.dev, planning is done sequentially -- one issue at a time. The workflow logic and output formats are identical.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST hit them. NEVER skip them. NEVER replace them with prose or skip ahead.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Handling Sparse Issues** | Step 3 | Plan all / Custom / Skip / Cancel | Planning launched without consent -- UNACCEPTABLE |
| **Plan Review** | Step 4 | Approve all / Revise some / Cancel | Plans accepted without review -- UNACCEPTABLE |

**If you find yourself asking the user what to do next without presenting numbered options, STOP. You are violating the protocol.**

---

## When to Apply

- Multiple open GitHub issues need triage before implementation
- Issues may be a mix of well-defined (`ready_for_dev`) and sparse (`needs_refinement`)
- User wants to get a batch of issues implementation-ready in one pass

---

## Prerequisites

- GitHub CLI (`gh`) is configured and authenticated
- Repository has open issues to triage

---

## Process

### Step 1: Fetch Open Issues

```bash
gh issue list --state open --json number,title,labels,body,assignees --limit 50
```

> Note: Use `glab` for GitLab repositories.
> Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

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

### Step 3: Present Triage Results

```
Triage Issues -- Results
==========================

Repository: [owner/repo]
Open issues scanned: [N]

Ready for implementation:
  [check] #123 -- Add user avatar upload (SMALL)
  [check] #125 -- Fix date formatting in reports (SMALL)
  [check] #128 -- Add CSV export to dashboard (MEDIUM)

Needs planning first:
  [plan] #135 -- Add webhook support (MEDIUM, sparse -- needs_refinement)
  [plan] #137 -- Refactor auth module (MEDIUM, sparse -- no acceptance criteria)
  [plan] #140 -- Support dark mode (SMALL, sparse -- needs_refinement)
  [plan] #142 -- Add email notifications (LARGE, sparse -- needs_refinement)

Not eligible:
  [skip] #124 -- Redesign database schema (blocked label)
  [skip] #126 -- Improve performance (assigned to @dev)
  [skip] #129 -- Epic: User management overhaul (too large)

Summary: 3 issues ready now, 4 need planning first.
```

Present the following options:

1. **Plan all sparse issues** -- Sequentially enhance all {N} sparse issues
2. **Custom selection** -- I'll specify which sparse issues to plan
3. **Skip planning** -- Only the {N} ready issues matter -- skip the sparse ones
4. **Cancel** -- Don't do anything right now

**WAIT** for user response before continuing.

**If "Plan all sparse issues":** Proceed to Step 4 with all NEEDS_PLANNING issues.
**If "Custom selection":** Ask user to list issue numbers. Proceed to Step 4 with selected issues.
**If "Skip planning":** Skip to Step 5 (summary of ready issues only).
**If "Cancel":** End skill.

### Step 4: Planning Phase (for NEEDS_PLANNING issues)

Process each sparse issue sequentially. For each NEEDS_PLANNING issue, run a streamlined enhance-issue process:

**For each issue:**

1. **Explore the codebase** to understand the problem area:
   - Search for affected files and modules
   - Understand current behavior and patterns
   - For bugs: form a root cause hypothesis
   - For features: identify integration points
2. **Search `docs/solutions/`** for relevant past learnings
3. **Generate a plan** for this issue:
   - For bugs: a minimal plan (root cause, fix approach, affected files, test strategy)
   - For features: a minimal or standard plan (approach, affected files, acceptance criteria, test strategy)
4. **Update the GitHub issue** with enriched content:
   - Acceptance criteria (specific, testable)
   - Affected files
   - Technical approach summary
   - Testing notes and edge cases
   - Swap labels: remove needs_refinement, add ready_for_dev

   ```bash
   gh issue edit {number} --body "$(cat <<'EOF'
   [enhanced issue content]
   EOF
   )"
   gh issue edit {number} --remove-label "needs_refinement" --add-label "ready_for_dev"
   ```

   > Note: Use `glab` for GitLab repositories.
   > Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, heredoc syntax differs).

5. **Record plan summary:**
   - Issue title
   - Proposed approach (2-3 sentences)
   - Affected files
   - Acceptance criteria
   - Estimated complexity
   - Any concerns or risks
   - If the issue is too vague to even plan, explain why
   - If you discover the issue is actually an epic (too large), flag it

**Rules:**
- Do NOT start implementing -- only plan and enhance
- Check project conventions
- Check `docs/solutions/` for past learnings

**After all planning completes, collect plan summaries and present to the user:**

```
Triage Issues -- Planning Complete
=====================================

Plans generated: [N/N]

#135 -- Add webhook support
  Approach: Add webhook registry with event subscription model. New WebhookService
  class handles dispatch. DB table for registered endpoints.
  Files: 5 | Complexity: MEDIUM | Criteria: 4 acceptance items

#137 -- Refactor auth module
  Approach: Extract token validation into middleware. Replace scattered auth checks
  with centralized AuthGuard pattern matching existing codebase conventions.
  Files: 8 | Complexity: MEDIUM | Criteria: 5 acceptance items

#140 -- Support dark mode
  Approach: CSS custom properties for theme tokens. ThemeProvider context.
  localStorage persistence. System preference detection.
  Files: 3 | Complexity: SMALL | Criteria: 3 acceptance items

#142 -- Add email notifications
  WARNING: scope may be too large for single implementation.
  Suggest splitting into sub-issues or implementing core only.
```

Present the following options:

1. **Approve all** -- All plans look good -- issues are now ready_for_dev
2. **Revise some** -- I have feedback on specific plans before approving
3. **Cancel** -- Stop here -- planning work is preserved on GitHub

**WAIT** for user response before continuing.

**If "Approve all":** Proceed to Step 5.
**If "Revise some":** Ask which plans need changes and what to change. Re-process those issues with feedback. Re-collect and re-present.
**If "Cancel":** Planning work is preserved (issues already updated on GitHub). End skill.

### Step 5: Summary

Present the final state of all triaged issues:

```
Triage Issues -- Complete
===========================

Issues ready for implementation: [N]
  [check] #123 -- Add user avatar upload (SMALL) -- was already ready
  [check] #125 -- Fix date formatting in reports (SMALL) -- was already ready
  [check] #128 -- Add CSV export to dashboard (MEDIUM) -- was already ready
  [check] #135 -- Add webhook support (MEDIUM) -- planned and enhanced
  [check] #137 -- Refactor auth module (MEDIUM) -- planned and enhanced
  [check] #140 -- Support dark mode (SMALL) -- planned and enhanced

Flagged:
  [warning] #142 -- Add email notifications -- may need splitting

Not eligible (unchanged):
  [skip] #124, #126, #129

Next step: Run /implement for each issue.
  - For simple issues: /implement -> start-issue
  - For complex issues: /implement -> team-implement (decomposes into tasks)
```

---

## Notes

- **Triage only -- no implementation.** This skill gets issues ready for dev. Implementation happens separately via `/implement` -> `/start-issue` or `/team-implement`, one issue at a time.
- **Sequential processing.** Each planner works on a separate issue independently, processed one at a time in continue.dev.
- **Planning work persists.** Even if the user cancels, GitHub issues are already updated with enriched content and `ready_for_dev` labels. That work isn't lost.
- **Batch size:** Recommend max ~5 issues at a time. For larger backlogs, run multiple batches.
- **Implementation strategy:** After triage, the user runs `/implement` for each issue. Complex issues benefit from `/team-implement` which decomposes tasks. Simple issues go through `/start-issue`.
- **Pairs with existing skills:** This is essentially batch `/enhance-issue`. Where `/enhance-issue` handles one issue, `/triage-issues` handles many sequentially.

---

## Integration Points

- **Input**: Open GitHub issues fetched via `gh` CLI (or `glab` for GitLab)
- **Planning**: Sequential enhancement -- streamlined version of `/enhance-issue`
- **Output**: All selected issues are `ready_for_dev` on GitHub
- **Followed by**: `/implement` -> `/start-issue` or `/team-implement` per issue
