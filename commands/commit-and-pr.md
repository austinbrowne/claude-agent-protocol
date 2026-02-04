---
description: Commit changes and create pull request with finding verification gate
---

# /commit-and-pr

**Description:** Commit changes and create pull request

**When to use:**
- After Fresh Eyes Review APPROVED
- Ready to commit and create PR for review
- Following GODMODE Phase 1 Step 8 (final step before merge)

**Prerequisites:**
- Fresh Eyes Review APPROVED
- All CRITICAL and HIGH findings resolved (file-based todos and/or GitHub issues)
- Tests passing (`/run-validation` PASS)
- Changes staged (`git add` completed)

---

## Invocation

**Interactive mode:**
User types `/commit-and-pr` with no arguments. Claude asks for confirmation and base branch.

**Direct mode:**
User types `/commit-and-pr --base experimental` to specify base branch.

---

## Arguments

- `--base [branch]` - Target branch for PR (main, experimental, develop, etc.)
- `--message "[message]"` - Custom commit message (optional, auto-generated if not provided)

---

## Execution Steps

### Step 1: Verify prerequisites (MANDATORY GATE)

**CRITICAL: This step is a MANDATORY gate. Do NOT skip even if context was summarized.**

**Check 1: Fresh Eyes Review status**
- Look for Fresh Eyes verdict in conversation history
- Verify: APPROVED or APPROVED_WITH_NOTES
- **If not found or not approved, you MUST run it now:**
  ```
  STOP: Fresh Eyes Review Required

  Fresh Eyes Review not completed or not approved.
  This is a MANDATORY checkpoint - not optional.

  Running Fresh Eyes Review now...
  ```

  **Then automatically run:** `/fresh-eyes-review`

  **Do NOT offer bypass.** The review must complete before proceeding.

  **Only after APPROVED verdict:** Continue to next check.

**Check 2: Verify all CRITICAL and HIGH findings resolved**

**File-based mode (check `.todos/`):**
```
Glob: .todos/*-pending-critical-*.md
Glob: .todos/*-pending-high-*.md
If any found → BLOCK commit
```

**GitHub mode (check issues):**
```bash
gh issue list --label "review-finding" --label "priority:p1" --state open
gh issue list --label "review-finding" --label "priority:p2" --state open
If any found → BLOCK commit
```

**Both mode:** Check both sources.

**If unresolved findings found:**
```
BLOCK: Unresolved review findings

CRITICAL findings still pending:
  - .todos/123-pending-critical-sql-injection-users-endpoint.md

HIGH findings still pending:
  - .todos/123-pending-high-missing-null-check-auth-service.md

Resolve these findings before committing.
Re-run: `/fresh-eyes-review` after fixes.
```

**Check 3: Tests passing**
- Look for validation status in conversation history
- Verify: VALIDATION_PASSED
- If not found:
  ```
  Validation not completed!

  Run validation first: `/run-validation`

  Bypass and commit anyway? (yes/no): _____
  ```

**Check 4: Staged changes**
```bash
git diff --staged --name-only
```

**If no staged changes:**
```
No staged changes found!

Stage your changes:
  git add .

Then run: `/commit-and-pr`
```

### Step 2: Present summary and ask for confirmation

```
📦 Commit & Create PR

Summary:
- Files changed: 5
  - src/auth/AuthService.ts
  - src/middleware/auth.ts
  - src/auth/AuthService.test.ts
  - src/middleware/auth.test.ts
  - docs/prds/123-2025-12-01-oauth-auth.md

- Tests: 24 passing, 87% coverage
- Security: SECURITY_APPROVED
- Fresh Eyes: APPROVED

Ready to commit? (yes/no): _____
```

### Step 3: Generate commit message (or use provided)

**If --message provided:**
- Use custom message

**If no --message (auto-generate):**

**Extract context:**
- Current branch name (issue-123-oauth-provider)
- Issue number from branch (123)
- Issue title via `gh issue view 123 --json title`
- Changes summary from git diff

**Generate conventional commit message:**

**Format:**
```
<type>: <subject> (Closes #<issue>)

<body>

<footer>
```

**Type detection:**
- New feature: `feat:`
- Bug fix: `fix:`
- Refactoring: `refactor:`
- Documentation: `docs:`
- Tests: `test:`
- Performance: `perf:`

**Example generated message:**
```
feat: add OAuth provider integration (Closes #123)

Implemented Google and GitHub OAuth providers with token exchange.

Changes:
- Added AuthService.authenticate() for OAuth flow
- Added middleware for token validation
- Comprehensive test coverage (24 tests, 87%)
- Security review completed

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Show message to user:**
```
Commit message:

feat: add OAuth provider integration (Closes #123)

[... full message ...]

Use this message? (yes/no/edit): _____
```

**If edit:**
```
Edit commit message: _____
```

### Step 4: Execute git commit

```bash
git commit -m "$(cat <<'EOF'
feat: add OAuth provider integration (Closes #123)

Implemented Google and GitHub OAuth providers with token exchange.

Changes:
- Added AuthService.authenticate() for OAuth flow
- Added middleware for token validation
- Comprehensive test coverage (24 tests, 87%)
- Security review completed

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Capture commit hash:**
```bash
git rev-parse HEAD
```

**Verify commit:**
```bash
git log -1 --oneline
git status
```

### Step 5: Push branch to remote

```bash
git push
# or if not yet pushed
git push -u origin issue-123-oauth-provider
```

### Step 6: Ask for base branch

**CRITICAL: ALWAYS ask for base branch confirmation, even if a default exists. Do NOT assume `main`.**

**If --base provided:**
- Use specified base branch (still confirm with user)

**If no --base (ask user):**
```
Which branch should this PR target?

Common base branches:
1. main (production/stable branch)
2. experimental (testing/development branch)
3. develop (development branch)
4. other (specify)

Your choice [1]: _____
```

**Get base branch:**
- Option 1: `main`
- Option 2: `experimental`
- Option 3: `develop`
- Option 4: Ask for custom branch name

### Step 7: Generate PR body

**Extract information:**
- Issue number from branch or commit message
- Issue details via `gh issue view 123 --json title,body,labels`
- Changes summary from commit
- Test results from validation
- Security review status
- PRD reference (from issue)

**Generate PR body:**
```markdown
## Summary

Implements OAuth provider integration for Google and GitHub.

Closes #123

## Changes

- ✅ Added AuthService.authenticate() for OAuth flow
- ✅ Added middleware for token validation
- ✅ Comprehensive test coverage (24 tests, 87%)
- ✅ Security review completed (APPROVED)

## Test Plan

- [x] Unit tests passing (24/24)
- [x] Integration tests passing
- [x] Security review completed
- [x] Fresh Eyes Review: APPROVED

## Testing

```bash
npm test
# 24 tests passing, 87% coverage
```

## Security

Security review completed:
- ✅ No SQL injection risks
- ✅ Secure token storage
- ✅ Input validation on all endpoints
- ✅ OWASP Top 10 compliance

Status: SECURITY_APPROVED

## PRD Reference

**Source PRD:** `docs/prds/123-2025-12-01-oauth-auth.md`

## Fresh Eyes Review

- Verdict: APPROVED
- Tier: Standard
- Issues: 0 CRITICAL, 0 HIGH, 1 MEDIUM, 2 LOW

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Step 8: Create PR using gh CLI

```bash
gh pr create \
  --title "feat: OAuth provider integration (Closes #123)" \
  --body "$(cat <<'EOF'
[PR body from Step 7]
EOF
)" \
  --base experimental
```

**Capture PR URL and number:**
```bash
# gh pr create returns PR URL
```

### Step 9: Report success and next steps

```
✅ Commit and PR created successfully!

Commit: abc1234 - feat: add OAuth provider integration
Branch: issue-123-oauth-provider
PR: #150 - https://github.com/org/repo/pull/150
Base branch: experimental

Next steps:
1. Review PR on GitHub: https://github.com/org/repo/pull/150
2. Wait for approval (or self-merge if authorized)
3. After merge, issue #123 will auto-close
4. Capture learnings: `/compound` (if you solved something tricky)
5. Pick next issue: `gh issue list`
   Or start next issue: `/start-issue [number]`
```

---

## Output

**Created:**
- Git commit with conventional commit message
- PR on GitHub targeting specified base branch

**Reported:**
- Commit hash
- PR number and URL
- Base branch
- Summary of changes

**Status:** `PR_CREATED`

**Suggested next steps:**
- "Review PR on GitHub and merge when approved"
- "Pick next issue: `/start-issue [number]`"

---

## References

- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 1 Step 8 for commit/PR process
- See: `~/.claude/QUICK_START.md` for git workflow
- See: [Conventional Commits](https://www.conventionalcommits.org/) for commit message format

---

## Example Usage

**Example 1: Interactive mode**
```
User: /commit-and-pr

Claude: 📦 Commit & Create PR

Summary:
- 5 files changed
- Tests: 24 passing, 87%
- Fresh Eyes: APPROVED

Ready? yes

Commit message:
feat: add OAuth provider integration (Closes #123)
[...]

Use this? yes

[Commits]

Base branch:
1. main
2. experimental

Your choice: 2

[Creates PR to experimental]

✅ Success!

Commit: abc1234
PR: #150 - https://github.com/org/repo/pull/150

Review and merge when ready.
```

**Example 2: Direct mode**
```
User: /commit-and-pr --base experimental

Claude: [Immediately commits and creates PR]

✅ Success!

Commit: abc1234
PR: #150

Review: https://github.com/org/repo/pull/150
```

**Example 3: Custom commit message**
```
User: /commit-and-pr --base main --message "feat: add OAuth support

Implemented Google and GitHub providers with comprehensive security."

Claude: [Uses custom message]

✅ Success!

Commit: abc1234
PR: #150
```

---

## Notes

- **Conventional commits:** Uses conventional commit format (feat:, fix:, etc.)
- **Auto-close issue:** "Closes #123" in message auto-closes issue on PR merge
- **Co-authored:** Includes Claude co-author tag
- **PR body comprehensive:** Includes summary, changes, tests, security, PRD reference
- **Base branch confirmation:** Always asks which branch to target (prevents wrong-branch merges)
- **Prerequisites checked:** Verifies Fresh Eyes APPROVED and tests passing
- **HEREDOC for messages:** Ensures proper formatting of multi-line messages
- **Issue auto-link:** PR automatically linked to issue via "Closes #123"
