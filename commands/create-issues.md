---
description: Generate issues from approved PRD
---

# /create-issues

**Description:** Generate issues from approved PRD

**When to use:**
- After PRD has been reviewed and approved
- Ready to break PRD into implementation tasks
- Want to create backlog of work or start immediately
- Phase 0 Step 5 in GODMODE workflow (optional but recommended)

**Prerequisites:**
- Approved PRD file exists in `docs/prds/YYYY-MM-DD-feature-name.md`
- **Platform CLI installed and authenticated** (see `~/.claude/platforms/detect.md`)
- Git repository initialized

---

## Invocation

**Interactive mode:**
User types `/create-issues` with no arguments. Claude lists available PRDs and asks which to use.

**Direct mode:**
User types `/create-issues docs/prds/YYYY-MM-DD-feature-name.md --immediate` or `--backlog`

---

## Arguments

- `[prd_path]` - Path to PRD file (e.g., `docs/prds/2025-12-01-feature.md`)
- `--immediate` - Create issues and assign to @me (start work now)
- `--backlog` - Create issues without assignment (park for later)

---

## Execution Steps

### Step 1: Select PRD file

**If direct mode (PRD path provided):**
- Use specified PRD file path
- Validate file exists

**If interactive mode (no arguments):**
- List available PRD files:
  ```bash
  ls docs/prds/ | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}-.*\.md$'
  ```
- Display to user:
  ```
  📋 Issue Generation

  Available PRDs:
  1. docs/prds/2025-12-01-oauth-authentication.md
  2. docs/prds/2025-11-30-password-reset.md

  Select PRD (number or path): _____
  ```

### Step 2: Determine execution mode (immediate vs backlog)

**If direct mode (flag provided):**
- Use `--immediate` or `--backlog` flag

**If interactive mode (no flag):**
- Ask user:
  ```
  Execution mode:
  1. Immediate (assign to @me, start work now)
  2. Backlog (create issues, work later)

  Your choice [1]: _____
  ```

### Step 3: Parse PRD and extract implementation tasks

**Read PRD file:**
- Load PRD content
- Identify Implementation Plan section (Section 5 in Full PRD, or infer from Lite PRD)

**Extract phases and deliverables:**

**For Full PRD:**
- Parse each Phase (Phase 1, Phase 2, etc.)
- Extract deliverables and acceptance criteria for each phase
- Each phase → One issue

**For Lite PRD:**
- Single issue with all acceptance criteria

**Issue structure per phase:**
```markdown
Title: [Phase name from PRD]

Description: [From PRD context]

Acceptance Criteria:
- [ ] [Criterion from PRD]
- [ ] [Criterion from PRD]
- [ ] Tests written and passing
- [ ] Security review completed (if SECURITY_SENSITIVE)

[Use ISSUE_TEMPLATE.md structure]
```

### Step 4: Generate issues using platform CLI

**Detect platform if not already done** (see `~/.claude/platforms/detect.md`).

**Load issue template:**
- Read `~/.claude/templates/ISSUE_TEMPLATE.md`

**For each phase/task, create issue:**

**GitHub:**
```bash
gh issue create \
  --title "Phase N: [Phase name]" \
  --body-file /tmp/issue-body.md \
  --label "type: feature,priority: high" \
  --project "Project Name"
```

**GitLab:**
```bash
glab issue create \
  --title "Phase N: [Phase name]" \
  --description "$(cat /tmp/issue-body.md)" \
  --label "type::feature,priority::high"
```

**Auto-detect labels from PRD:**
- **Type**: Feature (default), Bug Fix, Enhancement, Tech Debt
- **Priority**: Critical, High, Medium, Low (from PRD priority)
- **Status**: ready (default)
- **Flags**:
  - `security-sensitive` if PRD flagged SECURITY_SENSITIVE
  - `performance-critical` if performance budget exists
  - `breaking-change` if noted in PRD

**If --immediate mode:**
- Add `--assignee @me` to issue create command

**If --backlog mode:**
- No assignee, just create issue

**Capture issue numbers:**
- Store first issue number (e.g., #123)
- Store all created issue numbers

### Step 5: Rename PRD with first issue number

**Current PRD filename:** `docs/prds/YYYY-MM-DD-feature-name.md`
**New PRD filename:** `docs/prds/NNN-YYYY-MM-DD-feature-name.md`

Where NNN = first issue number (e.g., 123)

**Rename file:**
```bash
mv docs/prds/2025-12-01-oauth-auth.md \
   docs/prds/123-2025-12-01-oauth-auth.md
```

### Step 6: Update first issue to reference renamed PRD

**Update issue #123 description:**

**GitHub:**
```bash
gh issue edit 123 --add-body "

## PRD Reference

**Source PRD:** \`docs/prds/123-2025-12-01-oauth-auth.md\`
"
```

**GitLab:**
```bash
glab issue note 123 --message "## PRD Reference

**Source PRD:** \`docs/prds/123-2025-12-01-oauth-auth.md\`"
```

### Step 7: Commit PRD to git and push to remote

**This is CRITICAL for team collaboration and future access.**

```bash
# Add renamed PRD
git add docs/prds/123-2025-12-01-oauth-auth.md

# Commit with message
git commit -m "docs: add PRD for OAuth authentication (Issue #123)

PRD created for feature implementation.
Created issues: #123, #124, #125

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to remote (current branch)
git push
```

**Why this is critical:**
- Ensures PRD is available to other developers
- Ensures PRD is available in future sessions/machines
- Required for team collaboration on backlog
- Creates historical record linked to implementation

### Step 8: Report created issues and next steps

```
✅ Issues created successfully!

Issues:
- #123: Phase 1: OAuth provider integration (8 hours)
- #124: Phase 2: Token management (4 hours)
- #125: Phase 3: Frontend OAuth flow (6 hours)

PRD renamed: docs/prds/123-2025-12-01-oauth-auth.md
PRD updated in issue: #123
Git commit: abc1234
Pushed to: origin/main

Execution mode: Immediate
Assigned to: @me

Next steps:
- Start first issue: `/start-issue 123`
- Or list all issues (use platform CLI)
```

---

## Output

**Created:**
- N issues (one per phase/task)
- Renamed PRD file with issue number prefix
- Updated first issue with PRD reference
- Git commit with PRD

**Reported:**
- List of created issues with numbers, titles, estimates
- Renamed PRD file path
- Git commit hash
- Push confirmation

**Status:** `ISSUES_CREATED`

**Suggested next steps:**
- If `--immediate`: "Run `/start-issue <number>` to begin implementation"
- If `--backlog`: "Issues parked in backlog. View with platform issue list command"

---

## References

- See: `~/.claude/templates/ISSUE_TEMPLATE.md` for issue structure
- See: `~/.claude/guides/PROJECT_INTEGRATION.md` for platform-specific project workflow
- See: `~/.claude/QUICK_START.md` Entry Point A for PRD → Issue workflow
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 0 Step 5 for issue creation

---

## Example Usage

**Example 1: Interactive mode - Immediate execution**
```
User: /create-issues

Claude: 📋 Issue Generation

Available PRDs:
1. docs/prds/2025-12-01-oauth-auth.md
2. docs/prds/2025-11-30-password-reset.md

Select PRD: _____

User: 1

Claude: Execution mode:
1. Immediate (assign to @me, start work now)
2. Backlog (create issues, work later)

Your choice [1]: _____

User: 1

Claude: [Parsing PRD...]
[Creating issues...]

✅ Issues created successfully!

Issues:
- #123: Phase 1: OAuth provider integration (8 hours)
- #124: Phase 2: Token management (4 hours)
- #125: Phase 3: Frontend OAuth flow (6 hours)

PRD renamed: docs/prds/123-2025-12-01-oauth-auth.md
PRD updated in issue: #123
Git commit: abc1234
Pushed to: origin/main

All issues assigned to: @me

Next steps:
- Start first issue: `/start-issue 123`
```

**Example 2: Direct mode - Backlog**
```
User: /create-issues docs/prds/2025-12-01-oauth-auth.md --backlog

Claude: [Immediately creates issues in backlog mode]

✅ Issues created successfully!

Issues:
- #126: Phase 1: OAuth provider integration (8 hours)
- #127: Phase 2: Token management (4 hours)
- #128: Phase 3: Frontend OAuth flow (6 hours)

PRD renamed: docs/prds/126-2025-12-01-oauth-auth.md
PRD updated in issue: #126
Git commit: def5678
Pushed to: origin/main

Issues parked in backlog (not assigned).

Next steps:
- View backlog (use platform CLI to list issues)
- Start when ready: `/start-issue 126`
```

**Example 3: Lite PRD (single issue)**
```
User: /create-issues docs/prds/2025-12-01-fix-logout-bug.md --immediate

Claude: [Creates single issue from Lite PRD]

✅ Issue created successfully!

Issue:
- #129: Fix logout button not clearing session cookie (2 hours)

PRD renamed: docs/prds/129-2025-12-01-fix-logout-bug.md
PRD updated in issue: #129
Git commit: ghi9012
Pushed to: origin/main

Assigned to: @me

Next steps:
- Start issue: `/start-issue 129`
```

---

## Notes

- **PRD renaming**: First issue number is prepended (e.g., `123-2025-12-01-feature.md`)
  - Creates direct link between PRD and implementation
  - Allows easy lookup: "What was the PRD for issue #123?" → Look for `123-*.md`
- **Git commit is mandatory**: Ensures PRD is available to team and in future sessions
- **Issue labels auto-detected**: Based on PRD metadata (priority, security flags, etc.)
- **Issue template used**: All issues follow ISSUE_TEMPLATE.md structure
- **Phases → Issues**: Each implementation phase becomes one issue
- **Lite PRD → Single issue**: Lite PRDs generate one issue with all criteria
- **Assignee behavior**:
  - `--immediate`: Issues assigned to @me (ready to work)
  - `--backlog`: No assignee (park for later)
- **Project association**: Issues can be associated with project board if configured (see platform guide)
- **Related issues**: If phases have dependencies, issues linked with "Depends on" / "Blocks"
