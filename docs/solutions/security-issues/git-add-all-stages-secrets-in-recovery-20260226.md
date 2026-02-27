---
module: Autonomous Loop
date: 2026-02-26
problem_type: security_issue
component: tooling
symptoms:
  - "Automated recovery commit stages untracked files including .credentials.json and .env"
  - "git add -A in autonomous agent paths commits secrets to git history"
root_cause: logic_error
resolution_type: code_fix
severity: high
tags: [git-add, staging, secrets, recovery, autonomous-loop, git-add-A, git-add-u, untracked-files]
related_solutions:
  - docs/solutions/logic-errors/state-machine-exhaustive-branch-coverage-20260209.md
---

# Troubleshooting: `git add -A` in Autonomous Recovery Paths Stages Secrets

## Problem
The `/loop` command's dirty working tree recovery path used `git add -A` for its "Commit and continue" option. This stages ALL files including untracked secrets (`.credentials.json`, `.env`, API keys) into the recovery commit, potentially exposing them in git history.

## Environment
- Module: Autonomous Loop (commands/loop.md)
- Affected Component: Dirty working tree detection, recovery commit path
- Date: 2026-02-26

## Symptoms
- Recovery commit includes files that should never be committed (`.credentials.json`, `.env`)
- `git log --stat` shows untracked secret files in recovery commits
- Secret files appear in git history even after adding to `.gitignore`

## What Didn't Work

**Direct solution:** The problem was caught during fresh-eyes-review (Security Reviewer + Edge Case Reviewer + Code Quality Reviewer all flagged it independently) before any runtime exposure occurred.

## Solution

Replace `git add -A` with `git add -u` in all automated/recovery commit paths.

```bash
# Before (dangerous):
git add -A && git commit -m "chore: recover uncommitted loop worker changes"

# After (safe):
git add -u && git commit -m "chore: recover uncommitted loop worker changes"
```

**Key difference:**
- `git add -A` — stages ALL changes: modified tracked files + untracked files + deletions
- `git add -u` — stages ONLY tracked file changes: modifications + deletions (never untracked)

## Why This Works

1. **ROOT CAUSE:** `git add -A` includes untracked files in the staging area. In an autonomous agent context, the working directory may contain secrets, credentials, or large binaries that should never be committed.
2. **`git add -u` restricts staging to files git already knows about.** Untracked files (which are untracked for a reason — often because they're in `.gitignore` or haven't been deliberately added) are never touched.
3. **The user confirmation gate is insufficient protection.** The AskUserQuestion prompt says "Commit and continue" but doesn't list what will be staged. Users may not realize `-A` includes untracked files.

## Prevention

- **Never use `git add -A` or `git add .` in automated commit paths.** Always use `git add -u` (tracked only) or explicit file lists.
- **Audit all `git add` commands in autonomous agent prompts.** Any agent that commits code on behalf of the user should be restricted to tracked files.
- **Pair `.gitignore` additions with file verification.** Adding a file to `.gitignore` prevents future tracking but doesn't protect against explicit `git add -A`.
- **Fresh-eyes review catches what single-reviewer misses.** Three independent reviewers all flagged this — the pattern of convergence signals a real issue.

## Related Issues

- See also: [State Machine Exhaustive Branch Coverage](../logic-errors/state-machine-exhaustive-branch-coverage-20260209.md) — same autonomous loop, different class of bug
