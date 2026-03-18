---
name: triage-issues
version: "2.0"
description: Batch-triage and plan open GitHub issues — categorize by readiness, parallel-plan sparse ones, stop when all are ready_for_dev
referenced_by:
  - commands/implement.md
---

# Triage Issues Skill

Fetch open GitHub issues, categorize by readiness, and run parallel subagents to plan any sparse issues. Stops when all selected issues are `ready_for_dev` — implementation is handled separately via `/implement` per issue.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Handling Sparse Issues** | Step 3 | Plan all / Custom / Skip / Cancel | Subagents launched without consent — UNACCEPTABLE |
| **Plan Review** | Step 4 | Approve all / Revise some / Cancel | Plans accepted without review — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- Multiple open GitHub issues need triage before implementation
- Issues may be a mix of well-defined (`ready_for_dev`) and sparse (`needs_refinement`)
- User wants to get a batch of issues implementation-ready in one pass

---

## Prerequisites

- GitHub CLI (`gh`) is configured and authenticated
- Repository has open issues to triage
- No Agent Teams required — this skill uses subagents (Agent tool) only

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

### Step 3: Present Triage Results

```
Triage Issues — Results
━━━━━━━━━━━━━━━━━━━━━━

Repository: [owner/repo]
Open issues scanned: [N]

Ready for implementation:
  ✅ #123 — Add user avatar upload (SMALL)
  ✅ #125 — Fix date formatting in reports (SMALL)
  ✅ #128 — Add CSV export to dashboard (MEDIUM)

Needs planning first:
  📋 #135 — Add webhook support (MEDIUM, sparse — needs_refinement)
  📋 #137 — Refactor auth module (MEDIUM, sparse — no acceptance criteria)
  📋 #140 — Support dark mode (SMALL, sparse — needs_refinement)
  📋 #142 — Add email notifications (LARGE, sparse — needs_refinement)

Not eligible:
  ❌ #124 — Redesign database schema (blocked label)
  ❌ #126 — Improve performance (assigned to @dev)
  ❌ #129 — Epic: User management overhaul (too large)

Summary: 3 issues ready now, 4 need planning first.
```

```
AskUserQuestion:
  question: "How should we handle the sparse issues?"
  header: "Triage"
  options:
    - label: "Plan all sparse issues"
      description: "Launch parallel subagents to enhance all {N} sparse issues"
    - label: "Custom selection"
      description: "I'll specify which sparse issues to plan"
    - label: "Skip planning"
      description: "Only the {N} ready issues matter — skip the sparse ones"
    - label: "Cancel"
      description: "Don't do anything right now"
```

**If "Plan all sparse issues":** Proceed to Step 4 with all NEEDS_PLANNING issues.
**If "Custom selection":** Ask user to list issue numbers. Proceed to Step 4 with selected issues.
**If "Skip planning":** Skip to Step 5 (summary of ready issues only).
**If "Cancel":** End skill.

### Step 4: Planning Phase (for NEEDS_PLANNING issues)

Launch parallel subagents to enhance sparse issues. Subagents are used because each planner works on a separate issue independently — no inter-agent communication needed.

**CRITICAL: Launch ALL planning subagents in a SINGLE message with multiple Task calls.**

One `subagent_type: "general-purpose"` Task call per NEEDS_PLANNING issue. Each runs a streamlined enhance-issue process.

**Planning subagent prompt:**
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
   Command: gh issue edit {number} --body "$(cat <<'EOF'
[enhanced issue content]
EOF
)" (use heredoc — do NOT write to /tmp)
   Command: gh issue edit {number} --remove-label "needs_refinement" --add-label "ready_for_dev"

Return your plan summary:
- Issue title
- Proposed approach (2-3 sentences)
- Affected files
- Acceptance criteria
- Estimated complexity
- Any concerns or risks
- If the issue is too vague to even plan, explain why
- If you discover the issue is actually an epic (too large), flag it

Rules:
- Do NOT start implementing — only plan and enhance
- Read CLAUDE.md for project conventions
- Check docs/solutions/ for past learnings
```

**Collect and present plans for approval:**

After all planning subagents complete, collect their plan summaries and present to the user:

```
Triage Issues — Planning Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
  ⚠️ Subagent flagged: scope may be too large for single implementation.
  Suggest splitting into sub-issues or implementing core only.
```

```
AskUserQuestion:
  question: "Review the plans above. Are they ready?"
  header: "Plan review"
  options:
    - label: "Approve all"
      description: "All plans look good — issues are now ready_for_dev"
    - label: "Revise some"
      description: "I have feedback on specific plans before approving"
    - label: "Cancel"
      description: "Stop here — planning work is preserved on GitHub"
```

**If "Approve all":** Proceed to Step 5.
**If "Revise some":** Ask which plans need changes and what to change. Re-launch subagents for those issues with feedback. Re-collect and re-present.
**If "Cancel":** Planning work is preserved (issues already updated on GitHub). End skill.

### Step 5: Summary

Present the final state of all triaged issues:

```
Triage Issues — Complete
━━━━━━━━━━━━━━━━━━━━━━━

Issues ready for implementation: [N]
  ✅ #123 — Add user avatar upload (SMALL) — was already ready
  ✅ #125 — Fix date formatting in reports (SMALL) — was already ready
  ✅ #128 — Add CSV export to dashboard (MEDIUM) — was already ready
  ✅ #135 — Add webhook support (MEDIUM) — planned and enhanced
  ✅ #137 — Refactor auth module (MEDIUM) — planned and enhanced
  ✅ #140 — Support dark mode (SMALL) — planned and enhanced

Flagged:
  ⚠️ #142 — Add email notifications — may need splitting

Not eligible (unchanged):
  ❌ #124, #126, #129

Next step: Run /implement for each issue.
  - For simple issues: /implement → start-issue
  - For complex issues: /implement → team-implement (decomposes into parallel tasks)
  - Each issue in its own Claude Code tab for parallel execution
```

---

## Notes

- **Triage only — no implementation.** This skill gets issues ready for dev. Implementation happens separately via `/implement` → `start-issue` or `team-implement`, one issue at a time.
- **Subagents only — no Agent Teams required.** Each planner works on a separate issue independently. No inter-agent communication needed. Simple, cheap, effective.
- **Planning work persists.** Even if the user cancels, GitHub issues are already updated with enriched content and `ready_for_dev` labels. That work isn't lost.
- **Batch size:** Recommend max ~5 subagents at a time. For larger backlogs, run multiple batches.
- **Implementation strategy:** After triage, the user runs `/implement` for each issue — either sequentially or in parallel Claude Code tabs. Complex issues benefit from `team-implement` which decomposes tasks and parallelizes with Agent Teams. Simple issues go through `start-issue`.
- **Pairs with existing skills:** This is essentially batch `enhance-issue`. Where `enhance-issue` handles one issue, `triage-issues` handles many in parallel.

---

## Integration Points

- **Input**: Open GitHub issues fetched via `gh` CLI
- **Planning**: Parallel subagents (Agent tool) — streamlined version of `skills/enhance-issue/SKILL.md`
- **Output**: All selected issues are `ready_for_dev` on GitHub
- **Consumed by**: `/implement` workflow command
- **Followed by**: `/implement` → `start-issue` or `team-implement` per issue
