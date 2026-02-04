---
name: commit-and-pr
version: "1.0"
description: Commit and PR creation methodology with finding verification gate
referenced_by:
  - commands/ship.md
---

# Commit and PR Skill

Methodology for committing changes and creating pull requests with mandatory prerequisite verification.

---

## When to Apply

- After Fresh Eyes Review APPROVED
- Ready to commit and create PR
- All CRITICAL and HIGH findings resolved

---

## Skills Referenced

- `skills/todos/SKILL.md` — For verifying todo completion status before commit

---

## Process

### 1. Verify Prerequisites (MANDATORY GATE)

**CRITICAL: Do NOT skip even if context was summarized.**

**Check 1: Fresh Eyes Review status**
- Verify APPROVED or APPROVED_WITH_NOTES in conversation
- If not found: **automatically run fresh-eyes-review** — do NOT offer bypass

**Check 2: Verify all CRITICAL and HIGH findings resolved**
- File-based: `Glob: .todos/*-pending-critical-*.md` and `*-pending-high-*.md`
- GitHub: `gh issue list --label "review-finding" --label "priority:p1" --state open`
- If unresolved: BLOCK commit

**Check 3: Tests passing** — verify VALIDATION_PASSED

**Check 4: Staged changes** — `git diff --staged --name-only`

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

Use HEREDOC for message formatting. Capture commit hash. Verify with `git log -1`.

### 4. Push and Create PR

**ALWAYS ask for base branch confirmation.**

```bash
git push
gh pr create --title "..." --body "..." --base [branch]
```

**PR body includes:** Summary, Changes, Test Plan, Security status, PRD reference, Fresh Eyes verdict.

---

## Notes

- **Fresh Eyes Review is mandatory** — enforced as a gate
- **Base branch always confirmed** — prevents wrong-branch merges
- **HEREDOC for messages** — ensures proper formatting

---

## Integration Points

- **Input**: Staged changes, review verdict, validation status
- **Output**: Git commit, PR on GitHub
- **Consumed by**: `/ship` workflow command
