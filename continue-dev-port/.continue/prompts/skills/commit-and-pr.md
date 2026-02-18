---
name: commit-and-pr
description: "Commit and PR creation with finding verification gate"
---

# Commit and PR

Methodology for committing changes and creating pull requests with mandatory prerequisite verification.

---

## When to Apply

- After Fresh Eyes Review APPROVED
- Ready to commit and create PR
- All CRITICAL and HIGH findings resolved

---

## Process

### 1. Verify Prerequisites (MANDATORY GATE)

**CRITICAL: Do NOT skip even if context was lost or summarized.**

**Check 1: Fresh Eyes Review status**
- Verify APPROVED or APPROVED_WITH_NOTES in conversation or in `.todos/review-verdict.md`
- If not found: **automatically run `/fresh-eyes-review`** -- do NOT offer bypass

**Check 2: Verify all CRITICAL and HIGH findings resolved**
- File-based: search for `.todos/*-pending-critical-*.md` and `*-pending-high-*.md`
- GitHub: run `gh issue list --label "review-finding" --label "priority:p1" --state open`
- GitLab: use `glab` for GitLab repositories
- If unresolved: BLOCK commit

**Check 3: Tests passing** -- verify validation passed

**Check 4: Staged changes** -- run `git diff --staged --name-only`

> Note: Adjust commands for PowerShell on Windows (e.g., `git diff --staged --name-only` works the same, but piped commands may differ).

### 2. Generate Commit Message

Extract context from branch name, issue number, changes summary.

**Conventional commit format:**
```
<type>: <subject> (Closes #<issue>)

<body with changes summary>

Co-Authored-By: Claude <noreply@anthropic.com>
```

Type detection: feat, fix, refactor, docs, test, perf.

### 3. Execute Git Commit

Use HEREDOC for message formatting (or equivalent multi-line commit message approach). Capture commit hash. Verify with `git log -1`.

### 4. Push and Create PR

**ALWAYS ask for base branch confirmation before creating the PR.**

Present the following:

> What base branch should this PR target?
>
> Detected: `[branch name]`
>
> Confirm or specify a different branch.

**WAIT** for user response before continuing.

Then run:

```bash
git push
gh pr create --title "..." --body "..." --base [branch]
```

> Note: Use `glab` for GitLab repositories.

**PR body includes:** Summary, Changes, Test Plan, Security status, Plan reference, Fresh Eyes verdict.

### 5. Update Issue Status to Review

**If working on a GitHub issue (issue number available from branch name pattern `issue-NNN-*` or commit messages `#NNN` / `Closes #NNN`):**

```bash
gh issue edit NNN --remove-label "status: in-progress" --add-label "status: review"
```

> Note: Use `glab` for GitLab repositories.

**Label transition:** `status: in-progress` -> `status: review`. This marks the issue as having a PR open for review.

**If no issue number can be determined, skip this step entirely.**

---

## Notes

- **Fresh Eyes Review is mandatory** -- enforced as a gate
- **Base branch always confirmed** -- prevents wrong-branch merges
- **HEREDOC for messages** -- ensures proper formatting

---

## Integration Points

- **Input**: Staged changes, review verdict, validation status
- **Output**: Git commit, PR on GitHub/GitLab
- **Consumed by**: Ship workflow
