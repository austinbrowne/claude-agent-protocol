---
name: commit-and-pr
version: "1.1"
description: Commit and PR/MR creation methodology with finding verification gate
referenced_by:
  - commands/ship.md
---

# Commit and PR/MR Skill

Methodology for committing changes and creating pull requests (GitHub) or merge requests (GitLab) with mandatory prerequisite verification.

> **Platform:** Commands below use GitHub (`gh`) syntax. For GitLab (`glab`) equivalents, see `platforms/gitlab.md`. Run `platforms/detect.md` once per session to determine your platform.

---

## When to Apply

- After Fresh Eyes Review APPROVED
- Ready to commit and create PR/MR
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
- GitLab: `glab issue list --label "review-finding" --label "priority::p1"`
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

### 4. Push and Create PR/MR

**ALWAYS ask for base branch confirmation.**

```bash
git push
# GitHub:
gh pr create --title "..." --body "..." --base [branch]
# GitLab:
glab mr create --title "..." --description "..." --target-branch [branch]
```

**PR/MR body includes:** Summary, Changes, Test Plan, Security status, Plan reference, Fresh Eyes verdict.

---

## Notes

- **Fresh Eyes Review is mandatory** — enforced as a gate
- **Base branch always confirmed** — prevents wrong-branch merges
- **HEREDOC for messages** — ensures proper formatting
- **Platform-aware** — uses `gh` or `glab` based on detected platform

---

## Integration Points

- **Input**: Staged changes, review verdict, validation status
- **Output**: Git commit, PR/MR on platform
- **Consumed by**: `/ship` workflow command
- **Platform reference**: `platforms/detect.md`, `platforms/github.md`, `platforms/gitlab.md`
