---
description: Begin work on a GitHub issue (Entry Point B workflow)
---

# /start-issue

**Description:** Begin work on a GitHub issue (Entry Point B workflow)

**When to use:**
- Have GitHub issues ready and want to start implementation
- Picking issue from backlog to work on
- Following Entry Point B in GODMODE (existing issue → implementation)
- GODMODE Phase 1 Step 1

**Prerequisites:**
- **GitHub issue exists** (created via `/create-issues` or manually)
- Issue is ready (not blocked, has acceptance criteria)
- GitHub CLI (`gh`) installed and authenticated
- Git repository initialized

**Note:** This command requires an existing GitHub issue. If you don't have one yet, either:
- Run `/create-issues` to generate issues from a PRD
- Create an issue manually on GitHub first
- Or use Entry Point A workflow (explore → generate-prd → create-issues → start-issue)

---

## Invocation

**Interactive mode:**
User types `/start-issue` with no arguments. Claude lists available issues.

**Direct mode:**
User types `/start-issue 123` where 123 is the issue number.

---

## Arguments

- `[issue_number]` - GitHub issue number to start (e.g., `123`)
- `--pipeline` - Run full workflow: start → implement → test → validate → fresh-eyes → commit/PR

---

## Execution Steps

### Step 1: Get issue number

**If direct mode (issue number provided):**
- Use specified issue number
- Example: `/start-issue 123`

**If interactive mode (no arguments):**
- List available issues from repository:
  ```bash
  gh issue list --state open --limit 20
  ```
- Display to user:
  ```
  🚀 Start Issue

  Available issues:
    #123 - Phase 1: OAuth provider integration (Ready, 8 hours)
    #124 - Phase 2: Token management (Ready, 4 hours)
    #125 - Phase 3: Frontend OAuth flow (Blocked by #123)

  Select issue number: _____
  ```

### Step 2: Load issue details via gh CLI

```bash
gh issue view 123 --json title,body,labels,assignees,state
```

**Extract:**
- Title
- Description
- Acceptance criteria
- Labels (security-sensitive, performance-critical, etc.)
- Current assignees
- PRD reference (from issue body)
- Dependencies (Blocked by, Depends on)

### Step 3: Verify issue is ready

**Check for blockers:**
- Label: `status: blocked`
- Body contains: "Blocked by #XXX" or "Depends on #XXX"
- Dependency issues still open

**If blocked:**
```
⚠️ Issue #123 is blocked!

Blocked by: #120 (still open)

Options:
1. Wait for #120 to be completed
2. Select different issue
3. Override and start anyway (risky)

Your choice: _____
```

**If not ready (missing acceptance criteria or description):**
```
⚠️ Issue #123 is missing critical information!

Missing:
- Acceptance criteria
- Technical requirements

Please update the issue before starting implementation.
```

### Step 4: Assign issue to @me (if not already assigned)

```bash
gh issue edit 123 --add-assignee @me
```

### Step 5: Create feature branch

**Branch naming convention:** `issue-NNN-brief-description`

**Extract brief description:**
- Take first 3-5 words from issue title
- Convert to kebab-case
- Example: "Phase 1: OAuth provider integration" → `issue-123-oauth-provider-integration`

**Create and checkout branch:**
```bash
git checkout -b issue-123-oauth-provider-integration
```

### Step 6: Push branch to remote with -u flag

```bash
git push -u origin issue-123-oauth-provider-integration
```

**Why -u flag:**
- Sets upstream tracking
- Future `git push` and `git pull` work without specifying remote
- Required for PR creation later

### Step 7: Update issue with start comment

```bash
gh issue comment 123 --body "🚧 Starting implementation on branch \`issue-123-oauth-provider-integration\`"
```

### Step 8: Display issue context and workflow to user

**If --pipeline flag is set:**

Display the full workflow as a todo list that Claude MUST add to its todos immediately:

```
✅ Issue #123 started with PIPELINE mode!

Title: Phase 1: OAuth provider integration

Acceptance Criteria:
- [ ] Google OAuth provider configured
- [ ] GitHub OAuth provider configured
- [ ] Token exchange implemented
- [ ] Tests passing with >80% coverage

PRD Reference: docs/prds/123-2025-12-01-oauth-auth.md
Labels: type: feature, priority: high, security-sensitive
Branch: issue-123-oauth-provider-integration

⚠️ SECURITY_SENSITIVE: Security review required

📋 PIPELINE WORKFLOW (add ALL to todos now):
1. [ ] Read PRD: docs/prds/123-2025-12-01-oauth-auth.md ← MANDATORY
2. [ ] Implement code per acceptance criteria
3. [ ] Generate tests: /generate-tests
4. [ ] Run validation: /run-validation
5. [ ] Fresh eyes review: /fresh-eyes-review ← MANDATORY
6. [ ] Commit and PR: /commit-and-pr

Starting Step 1: Reading PRD...
```

**CRITICAL:** When --pipeline is used, Claude MUST:
1. Immediately add ALL 6 steps to the todo list using TodoWrite
2. Mark step 1 as in_progress
3. Automatically proceed through all steps without waiting for user prompts
4. Only pause for user input on errors or decisions

**If --pipeline flag is NOT set (default):**

```
✅ Issue #123 started!

Title: Phase 1: OAuth provider integration

Description:
[Issue description from GitHub]

Acceptance Criteria:
- [ ] Google OAuth provider configured
- [ ] GitHub OAuth provider configured
- [ ] Token exchange implemented
- [ ] Tests passing with >80% coverage

PRD Reference: docs/prds/123-2025-12-01-oauth-auth.md
Labels: type: feature, priority: high, security-sensitive

Branch: issue-123-oauth-provider-integration
Assigned to: @me

⚠️ SECURITY_SENSITIVE: Review ~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md before implementation

Next steps:
1. Review PRD if needed: cat docs/prds/123-2025-12-01-oauth-auth.md
2. Implement code
3. Generate tests: `/generate-tests`
```

### Step 9: If PRD reference exists, optionally load PRD summary

**If issue contains PRD reference:**
- Parse PRD path from issue body
- Offer to show PRD summary

```
PRD available: docs/prds/123-2025-12-01-oauth-auth.md

Show PRD summary? (yes/no) _____
```

**If yes:**
- Read PRD file
- Display: Problem, Goals, Solution overview, Key technical approach
- Don't display full PRD (too long), just summary

---

## Output

**Status:**
- Issue assigned to @me
- Branch created and checked out: `issue-NNN-brief-description`
- Branch pushed to remote with upstream tracking
- Issue updated with start comment

**Context displayed:**
- Issue title
- Issue description
- Acceptance criteria
- PRD reference (if exists)
- Labels (especially security-sensitive, performance-critical)
- Estimated effort

**Status:** `ISSUE_STARTED`

**Suggested next steps:**
- "Implement code, then run `/generate-tests` when ready"
- Or: "Review PRD for context: cat docs/prds/NNN-*.md"

---

## References

- See: `~/.claude/QUICK_START.md` Entry Point B for issue-first workflow
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 1 Step 1 for starting issues
- See: `~/.claude/guides/GITHUB_PROJECT_INTEGRATION.md` for GitHub workflow

---

## Example Usage

**Example 1: Interactive mode**
```
User: /start-issue

Claude: 🚀 Start Issue

Available issues:
  #123 - Phase 1: OAuth provider integration (Ready, 8 hours)
  #124 - Phase 2: Token management (Ready, 4 hours)
  #125 - Phase 3: Frontend OAuth flow (Blocked by #123)

Select issue number: _____

User: 123

Claude: [Loads issue #123]

✅ Issue #123 started!

Title: Phase 1: OAuth provider integration

Acceptance Criteria:
- [ ] Google OAuth provider configured
- [ ] GitHub OAuth provider configured
- [ ] Token exchange implemented
- [ ] Tests passing with >80% coverage

PRD Reference: docs/prds/123-2025-12-01-oauth-auth.md
Labels: type: feature, priority: high, security-sensitive

Branch: issue-123-oauth-provider-integration
Assigned to: @me

⚠️ SECURITY_SENSITIVE: Review ~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md

Next steps:
1. Implement code
2. Generate tests: `/generate-tests`
```

**Example 2: Direct mode**
```
User: /start-issue 123

Claude: [Immediately loads issue #123 and creates branch]

✅ Issue #123 started!

[Same output as above]
```

**Example 3: Blocked issue**
```
User: /start-issue 125

Claude: ⚠️ Issue #125 is blocked!

Blocked by: #123 (still open)

Options:
1. Wait for #123 to be completed
2. Select different issue: /start-issue [number]
3. Override and start anyway (risky)

Your choice: _____

User: 2

Claude: Available issues:
  #123 - Phase 1: OAuth provider integration (Ready, 8 hours)
  #124 - Phase 2: Token management (Ready, 4 hours)

Select issue number: _____

User: 123

Claude: [Starts #123 instead]
```

**Example 4: With PRD context**
```
User: /start-issue 123

Claude: ✅ Issue #123 started!

[Issue context displayed]

PRD available: docs/prds/123-2025-12-01-oauth-auth.md

Show PRD summary? (yes/no) _____

User: yes

Claude: **PRD Summary:**

Problem:
Users want to sign in with OAuth providers (Google, GitHub) instead of creating passwords.

Solution:
Implement OAuth 2.0 authentication flow supporting multiple providers.

Technical Approach:
- Use Passport.js for OAuth strategy
- Store tokens encrypted in database
- Implement token refresh logic

[Summary displayed, not full PRD]

Next steps:
1. Implement OAuth strategies
2. Generate tests: `/generate-tests`
```

**Example 5: Pipeline mode (full automated workflow)**
```
User: /start-issue 123 --pipeline

Claude: ✅ Issue #123 started with PIPELINE mode!

Title: Phase 1: OAuth provider integration

📋 PIPELINE WORKFLOW (adding to todos now):
1. [ ] Read PRD ← MANDATORY
2. [ ] Implement code
3. [ ] Generate tests
4. [ ] Run validation
5. [ ] Fresh eyes review ← MANDATORY
6. [ ] Commit and PR

[Claude adds all 6 steps to TodoWrite]

Starting Step 1: Reading PRD...

[Claude automatically proceeds through entire workflow]
[Only pauses for errors or decisions]
[Completes with PR creation]
```

---

## Notes

- **Branch naming**: `issue-NNN-brief-description` (consistent convention)
- **Upstream tracking**: `-u` flag on first push enables easy future pushes
- **Issue assignment**: Auto-assigns to @me if not already assigned
- **Blocker detection**: Warns if issue is blocked by other issues
- **PRD context**: Optionally loads PRD summary if referenced in issue
- **Security flags**: Highlights security-sensitive issues with warning
- **Entry Point B**: This command implements Entry Point B workflow from QUICK_START.md
- **Comment on issue**: Adds GitHub comment marking start of implementation
- **Branch protection**: Working on feature branch, not main
- **Pipeline mode**: `--pipeline` runs full workflow automatically with mandatory checkpoints
