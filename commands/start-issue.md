---
description: Begin work on a GitHub issue with living plan and past learnings (Entry Point B workflow)
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

## Skills

**Load before execution:**
- `skills/knowledge-compounding/SKILL.md` — For searching `docs/solutions/` to surface relevant past learnings
- `skills/file-todos/SKILL.md` — For creating living plans in `.todos/` and tracking implementation progress

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
  Start Issue

  Available issues:
    #123 - Phase 1: OAuth provider integration (Ready)
    #124 - Phase 2: Token management (Ready)
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

### Step 2.5: Search Past Solutions

**Before implementation, search `docs/solutions/` for relevant learnings:**

Launch Learnings Research Agent (reference: `agents/research/learnings-researcher.md`):
- Search by issue tags/labels
- Search by keywords from issue title and description
- Search by category matching issue type

**Display relevant past solutions alongside issue context:**
```
Past solutions found:

1. auth-jwt-refresh-token-race-condition.md (HIGH relevance)
   Gotcha: Concurrent refresh requests can invalidate tokens
   Recommendation: Implement token rotation with grace period

2. testing-mock-external-api-timeout.md (MEDIUM relevance)
   Gotcha: Mock timeout behavior, not just success/failure
   Recommendation: Test with delayed responses, not just instant mocks
```

### Step 3: Verify issue is ready

**Check for blockers:**
- Label: `status: blocked`
- Body contains: "Blocked by #XXX" or "Depends on #XXX"
- Dependency issues still open

**If blocked:**
```
Issue #123 is blocked!

Blocked by: #120 (still open)

Options:
1. Wait for #120 to be completed
2. Select different issue
3. Override and start anyway (risky)

Your choice: _____
```

**If not ready (missing acceptance criteria or description):**
```
Issue #123 is missing critical information!

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

### Step 7: Create Living Plan

**Create implementation tracking file:** `.todos/{issue_id}-plan.md`

**Use template from:** `templates/LIVING_PLAN_TEMPLATE.md`

**Populate with:**
- Issue ID and title from Step 2
- Branch name from Step 5
- Acceptance criteria from issue body
- Past learnings from Step 2.5
- Implementation steps (derived from acceptance criteria)
- Progress log with start timestamp

**Example:**
```markdown
---
issue_id: "123"
title: "Phase 1: OAuth provider integration"
branch: "issue-123-oauth-provider-integration"
started: 2025-12-15
last_updated: 2025-12-15
status: in_progress
---

# Living Plan: Issue #123 — Phase 1: OAuth provider integration

## Acceptance Criteria
- [ ] Google OAuth provider configured
- [ ] GitHub OAuth provider configured
- [ ] Token exchange implemented
- [ ] Tests passing with >80% coverage

## Implementation Steps
- [ ] Step 1: Set up OAuth configuration
- [ ] Step 2: Implement Google provider
- [ ] Step 3: Implement GitHub provider
- [ ] Step 4: Implement token exchange
- [ ] Step 5: Generate tests
- [ ] Step 6: Run validation
- [ ] Step 7: Fresh Eyes Review
- [ ] Step 8: Commit and PR

## Past Learnings Applied
- auth-jwt-refresh-token-race-condition.md: Implement token rotation with grace period

## Progress Log
### 2025-12-15 — Started
- Branch created: issue-123-oauth-provider-integration
- Issue assigned to @me
```

### Step 8: Update issue with start comment

```bash
gh issue comment 123 --body "Starting implementation on branch \`issue-123-oauth-provider-integration\`"
```

### Step 9: Display issue context and workflow to user

**If --pipeline flag is set:**

Display the full workflow as a todo list that Claude MUST add to its todos immediately:

```
Issue #123 started with PIPELINE mode!

Title: Phase 1: OAuth provider integration

Acceptance Criteria:
- [ ] Google OAuth provider configured
- [ ] GitHub OAuth provider configured
- [ ] Token exchange implemented
- [ ] Tests passing with >80% coverage

Past Learnings Applied:
- Token rotation with grace period (from past solution)

Living Plan: .todos/123-plan.md

PIPELINE WORKFLOW (add ALL to todos now):
1. [ ] Read PRD (if referenced) — MANDATORY
2. [ ] Implement code per acceptance criteria
3. [ ] Generate tests: /generate-tests
4. [ ] Run validation: /run-validation
5. [ ] Fresh eyes review: /fresh-eyes-review — MANDATORY
6. [ ] Commit and PR: /commit-and-pr

Starting Step 1...
```

**CRITICAL:** When --pipeline is used, Claude MUST:
1. Immediately add ALL steps to the todo list
2. Mark step 1 as in_progress
3. Automatically proceed through all steps without waiting for user prompts
4. Only pause for user input on errors or decisions

**If --pipeline flag is NOT set (default):**

```
Issue #123 started!

Title: Phase 1: OAuth provider integration

Description:
[Issue description from GitHub]

Acceptance Criteria:
- [ ] Google OAuth provider configured
- [ ] GitHub OAuth provider configured
- [ ] Token exchange implemented
- [ ] Tests passing with >80% coverage

Past Learnings Applied:
- auth-jwt-refresh-token-race-condition.md: Implement token rotation with grace period

PRD Reference: docs/prds/123-2025-12-01-oauth-auth.md
Labels: type: feature, priority: high, security-sensitive
Branch: issue-123-oauth-provider-integration
Living Plan: .todos/123-plan.md

SECURITY_SENSITIVE: Review checklists/AI_CODE_SECURITY_REVIEW.md before implementation

Next steps:
1. Review PRD if needed: cat docs/prds/123-2025-12-01-oauth-auth.md
2. Implement code
3. Generate tests: `/generate-tests`
```

### Step 10: Incremental Commit Guidance

**During implementation, after each logical unit of work:**
- Suggest commit with `Part of #NNN` (not `Closes`)
- Only final commit uses `Closes #NNN`
- Each intermediate commit should be independently buildable
- Update living plan progress log after each commit

**Example intermediate commit:**
```bash
git commit -m "$(cat <<'EOF'
feat: add Google OAuth provider configuration

Part of #123

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Update living plan:**
- Check off completed implementation steps
- Add progress log entry with commit hash
- Update `last_updated` date in frontmatter

---

## Output

**Status:**
- Issue assigned to @me
- Branch created and checked out: `issue-NNN-brief-description`
- Branch pushed to remote with upstream tracking
- Issue updated with start comment
- Living plan created: `.todos/{issue_id}-plan.md`
- Past solutions surfaced

**Context displayed:**
- Issue title and description
- Acceptance criteria
- Past learnings (from `docs/solutions/`)
- PRD reference (if exists)
- Labels (especially security-sensitive, performance-critical)

**Status:** `ISSUE_STARTED`

**Suggested next steps:**
- "Implement code, then run `/generate-tests` when ready"
- Or: "Review PRD for context: cat docs/prds/NNN-*.md"

---

## References

- See: `QUICK_START.md` Entry Point B for issue-first workflow
- See: `AI_CODING_AGENT_GODMODE.md` Phase 1 Step 1 for starting issues
- See: `guides/GITHUB_PROJECT_INTEGRATION.md` for GitHub workflow
- See: `agents/research/learnings-researcher.md` for past solutions search
- See: `templates/LIVING_PLAN_TEMPLATE.md` for living plan format

---

## Example Usage

**Example 1: Interactive mode**
```
User: /start-issue

Claude: Start Issue

Available issues:
  #123 - Phase 1: OAuth provider integration (Ready)
  #124 - Phase 2: Token management (Ready)
  #125 - Phase 3: Frontend OAuth flow (Blocked by #123)

Select issue number: 123

Claude: [Loads issue, searches past solutions, creates living plan]

Issue #123 started!

Past Learnings Applied:
- Token rotation with grace period

Living Plan: .todos/123-plan.md
Branch: issue-123-oauth-provider-integration

Next steps:
1. Implement code
2. Generate tests: `/generate-tests`
```

**Example 2: Pipeline mode**
```
User: /start-issue 123 --pipeline

Claude: Issue #123 started with PIPELINE mode!

[Creates living plan, adds all steps to todos]
[Automatically proceeds through entire workflow]
[Pauses only for errors or decisions]
[Completes with PR creation]
```

**Example 3: With past solutions**
```
User: /start-issue 123

Claude: Issue #123 started!

Past solutions found:
1. auth-jwt-refresh-token-race-condition.md (HIGH)
   Gotcha: Concurrent refresh requests invalidate tokens
   Applied: Implementing token rotation with grace period

Living Plan: .todos/123-plan.md

Next steps:
1. Implement code (applying past learnings)
2. Generate tests: `/generate-tests`
```

---

## Notes

- **Living plan**: Implementation tracking file created automatically in `.todos/`
- **Past solutions**: Relevant learnings surfaced before implementation begins
- **Incremental commits**: Use `Part of #NNN` for intermediate, `Closes #NNN` for final
- **Branch naming**: `issue-NNN-brief-description` (consistent convention)
- **Upstream tracking**: `-u` flag on first push enables easy future pushes
- **Issue assignment**: Auto-assigns to @me if not already assigned
- **Blocker detection**: Warns if issue is blocked by other issues
- **PRD context**: Optionally loads PRD summary if referenced in issue
- **Security flags**: Highlights security-sensitive issues with warning
- **Pipeline mode**: `--pipeline` runs full workflow automatically with mandatory checkpoints

---

## Post-Completion Flow

After starting the issue (non-pipeline mode), present next options using `AskUserQuestion`:

```
AskUserQuestion:
  question: "Issue started. After implementing, what would you like to do?"
  header: "Next step"
  options:
    - label: "Run /generate-tests"
      description: "Generate tests for the implemented code"
    - label: "Run /security-review"
      description: "Run security checklist on the changes"
    - label: "Run /fresh-eyes-review"
      description: "Jump straight to multi-agent code review"
    - label: "Done"
      description: "Continue implementing — run commands manually later"
```

Based on user's selection, invoke the chosen command. Note: This flow triggers after implementation is complete, not immediately after `/start-issue`.
