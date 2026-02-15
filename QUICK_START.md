# GODMODE Quick Start Guide

## Two Ways to Use GODMODE

### 🆕 Entry Point A: New Feature (Phase 0 → Phase 1)

**Start here when:** Building something new from scratch

```bash
1. "Let's build user authentication"
2. Claude explores codebase
3. Claude generates PRD
4. Claude saves PRD to docs/prds/YYYY-MM-DD-feature-name.md
5. You approve PRD
6. [OPTIONAL] Create issues (/create-issues)
   a. Creates first issue #123
   b. Renames PRD: docs/prds/123-YYYY-MM-DD-feature-name.md
   c. Updates issue to reference renamed PRD
   d. **Commits and pushes PRD to git** (critical for team/later access)
   → Fork A: Start working immediately
   → Fork B: Park in backlog, work later
7. Claude implements Phase 1
```

**PRD file naming:**
- Initially: `docs/prds/YYYY-MM-DD-feature-name.md`
- After first issue: `docs/prds/NNN-YYYY-MM-DD-feature-name.md`
- Example: `docs/prds/123-2025-11-29-user-authentication.md`
  - `123` = Issue number
  - `2025-11-29` = Date created
  - `user-authentication` = Feature name
- Creates direct link between PRD and implementation

**⚠️ Critical:** PRD is committed and pushed to git after issue creation
- Ensures PRD is available to other developers
- Ensures PRD is available in future sessions/machines
- Required for team collaboration on backlog
- Without this, PRD only exists locally

---

### 📋 Entry Point B: Pick Existing Issue (Jump to Phase 1)

**Start here when:** 10 issues waiting in backlog, pick one to implement

```bash
# List ready issues (use platform CLI - see platforms/ for syntax)
# GitHub: gh project item-list PROJECT_NUM --owner OWNER
# GitLab: glab issue list --label "status::ready"

# Pick one
"Let's work on issue #45"

# Claude:
1. Detects platform (GitHub/GitLab) from git remote
2. Loads issue context (including PRD reference)
3. Checks dependencies
4. Restates the task
5. Assigns issue to you
6. Creates branch: issue-45-feature-name
7. Jumps to Phase 1 implementation
8. References PRD if needed for broader context
9. Commits changes to branch
10. Asks: "Create PR/MR?"
11. If yes: Creates PR/MR (auto-links to issue)
12. You review & merge on your platform
13. Issue auto-closes on merge
14. Pick next issue
```

**Git branching workflow:**
- Branch naming: `issue-NNN-brief-description`
- Example: `issue-45-password-hashing`
- All work happens on feature branch
- PR created for review before merge
- Issue auto-closes when PR merged

**PRD reference:**
- Each issue includes path to source PRD
- Reference if issue context unclear
- Reference for architectural rationale
- Reference to check alignment with requirements

---

## Common Commands

### List Projects / Ready Issues

**GitHub:**
```bash
gh project list --owner OWNER
gh project item-list 3 --owner OWNER
gh issue view 45
```

**GitLab:**
```bash
glab issue list --label "status::ready"
glab issue view 45
```

See `~/.claude/platforms/` for full CLI reference.

### Check PRD Files
```bash
# List all PRDs
ls docs/prds/

# View a specific PRD (with issue number prefix)
cat docs/prds/123-2025-11-29-user-authentication.md

# Create PRD directory (done automatically by GODMODE)
mkdir -p docs/prds
```

### Create Issue

**GitHub:**
```bash
gh issue create \
  --title "Implement feature" \
  --body-file issue.md \
  --label "type: feature,priority: high" \
  --project "Claude Agent Protocol"
```

**GitLab:**
```bash
glab issue create \
  --title "Implement feature" \
  --description "$(cat issue.md)" \
  --label "type::feature,priority::high"
```

### Close Issue

**GitHub:** `gh issue close 45 --comment "✅ Complete!"`
**GitLab:** `glab issue close 45`

---

## Modular Commands

**13 reusable slash commands** for flexible workflows. Use individually or compose custom workflows.

### Token Usage Estimates

| Command | Tokens | Cost Est. | Notes |
|---------|--------|-----------|-------|
| `/explore` | 5-15k | $0.05-0.15 | Spawns subagent, preserves main context |
| `/generate-prd` | 2-5k | $0.02-0.05 | Lite ~2k, Full ~5k |
| `/create-issues` | 3-8k | $0.03-0.08 | Depends on PRD size |
| `/fresh-eyes-review` | 5-20k | $0.05-0.30 | Lite ~5k, Standard ~10k, Full ~20k |
| `/security-review` | 3-5k | $0.03-0.05 | Single checklist pass |
| Other commands | 1-3k | $0.01-0.03 | Minimal overhead |

*Estimates based on Claude Sonnet pricing. Actual costs vary by codebase size.*

### Phase 0: Planning (4 commands)

| Command | Description | Example |
|---------|-------------|---------|
| `/explore` | Codebase exploration | `/explore authentication patterns` |
| `/generate-prd` | Create PRD | `/generate-prd --full "OAuth support"` |
| `/create-adr` | Document architecture decision | `/create-adr "Use PostgreSQL"` |
| `/create-issues` | Generate issues from PRD | `/create-issues docs/prds/2025-12-01-oauth.md --immediate` |

### Phase 1: Execution (7 commands)

| Command | Description | Example |
|---------|-------------|---------|
| `/start-issue` | Begin work on issue | `/start-issue 123` |
| `/generate-tests` | Generate comprehensive tests | `/generate-tests --path src/auth/AuthService.ts` |
| `/security-review` | Run security checklist | `/security-review` |
| `/run-validation` | Run tests + coverage + lint + security | `/run-validation` |
| `/fresh-eyes-review` | Multi-agent unbiased code review | `/fresh-eyes-review --standard` |
| `/recovery` | Handle failed implementations | `/recovery` |
| `/commit-and-pr` | Commit and create PR | `/commit-and-pr --base experimental` |

### Phase 2: Finalization (2 commands)

| Command | Description | Example |
|---------|-------------|---------|
| `/refactor` | Guided refactoring | `/refactor` |
| `/finalize` | Update docs and final checks | `/finalize --all` |

### Example Workflows with Commands

**Full GODMODE workflow:**
```bash
/explore authentication
/generate-prd --full "OAuth 2.0 authentication"
# Creates: docs/prds/2025-12-01-oauth-auth.md

/create-issues docs/prds/2025-12-01-oauth-auth.md --immediate
# Creates issue #123, renames PRD to: docs/prds/123-2025-12-01-oauth-auth.md

/start-issue 123
# [Implement code]
/generate-tests
/security-review
/run-validation
/fresh-eyes-review
/commit-and-pr --base experimental
/refactor
/finalize --all
```

**Quick Bug Fix workflow:**
```bash
# Assumes issue #456 already exists (created manually or via /create-issues)
/start-issue 456
# [Fix bug]
/generate-tests --path src/auth/bugfix.ts
/fresh-eyes-review --lite
/commit-and-pr --base main
```

**Just Review Existing Changes workflow:**
```bash
# [Already have code changes staged]
/fresh-eyes-review --standard
# [Fix issues found]
/commit-and-pr --base experimental
```

**Mid-Workflow Entry (Have PRD, Skip Explore):**
```bash
# Assumes PRD already exists: docs/prds/2025-11-28-existing-feature.md
/create-issues docs/prds/2025-11-28-existing-feature.md --immediate
# Creates issue #789, renames PRD to: docs/prds/789-2025-11-28-existing-feature.md

/start-issue 789
# [Implement]
/generate-tests
/run-validation
/fresh-eyes-review
/commit-and-pr
```

### Command Invocation Patterns

All commands support **hybrid invocation**:

**Interactive mode** (command asks questions):
```bash
/explore
# Claude: What would you like to explore? _____
```

**Direct mode** (command executes immediately):
```bash
/explore authentication patterns
# Claude: [Immediately explores authentication patterns]
```

### Command Help

For details on any command:
```bash
cat ~/.claude/commands/explore.md
cat ~/.claude/commands/generate-prd.md
# etc.
```

---

## Platform Setup

**Platform is auto-detected** from your git remote URL. See `~/.claude/platforms/detect.md`.

### GitHub Setup
```bash
brew install gh
gh auth login
gh auth refresh -s project --hostname github.com
gh project create --owner OWNER --title "My Dev Board"
gh project list --owner OWNER
```

### GitLab Setup
```bash
brew install glab  # or see https://gitlab.com/gitlab-org/cli/-/releases
glab auth login
# For self-hosted: glab auth login --hostname gitlab.example.com
```

See `~/.claude/guides/PROJECT_INTEGRATION.md` for full setup guides.

---

## Typical Workflows

### Workflow 1: Plan Big Feature, Execute in Chunks
```
Session 1 (Planning):
→ Entry Point A (Phase 0)
→ Generate PRD
→ /create-issues
→ Fork B: Create 10 issues in backlog
→ Exit

Session 2-11 (Implementation):
→ Entry Point B
→ "Let's work on issue #45"
→ Implement → Close → Next
```

### Workflow 2: Plan and Execute Immediately
```
Single Session:
→ Entry Point A (Phase 0)
→ Generate PRD
→ /create-issues
→ Fork A: Create issues with --assignee @me
→ Work through all issues sequentially
```

### Workflow 3: No Project Board (Direct Execution)
```
Single Session:
→ Entry Point A (Phase 0)
→ Generate PRD
→ Skip issue creation
→ Phase 1: Implement directly from PRD
```

---

## Critical Safety Reminders

**ALWAYS check before coding:**
- [ ] Null/undefined/empty inputs?
- [ ] Boundary values (0, -1, MAX)?
- [ ] Error conditions?
- [ ] Security-sensitive? (Run security checklist)
- [ ] Performance-critical? (Check requirements)

**NEVER do:**
- ❌ Skip exploration (understand codebase first)
- ❌ Skip security review when flagged
- ❌ Skip edge case testing
- ❌ Hardcode secrets
- ❌ Use string concatenation in SQL

**ALWAYS do:**
- ✅ Test edge cases (null, empty, boundaries, errors)
- ✅ Wrap external calls in try/catch
- ✅ Validate user input
- ✅ Pause for human feedback

---

## What If Implementation Fails?

**Q: What if Phase 1 implementation isn't working?**

**A:** Use the Failure Recovery Framework

**Read:** `~/.claude/guides/FAILURE_RECOVERY.md`

**Quick decision tree:**
1. **Can fix in <30 min?** → Continue (iterate normally)
2. **Approach fundamentally flawed?** → Abandon (partial save, return to Phase 0)
3. **Fixable with different approach?** → Rollback & Retry

**Common scenarios:**

### Tests Keep Failing
- **Minor edge cases:** Fix and continue
- **Major logic issues:** Rollback and refactor
- **Architecture wrong:** Abandon, revise PRD

### Fresh Eyes Review Found Critical Issues
- **Can fix quickly:** Fix and re-review
- **Requires major refactor:** Rollback & retry with different approach
- **Impossible to fix:** Abandon, return to Phase 0

### Performance Too Slow
- **Simple optimization:** Add index, fix N+1 queries, continue
- **Algorithm needs changing:** Rollback, use different algorithm
- **Requirement impossible:** Abandon, discuss requirements with stakeholder

### Security Unfixable
- **Missing validation:** Add validation, continue
- **Architecture insecure:** Rollback & retry with secure architecture
- **Requirement conflicts with security:** Abandon, revise requirements

**Recovery procedures available:**
- Soft reset (preserve changes for reference)
- Hard reset (clean slate)
- Stash (temporary parking)
- Partial save (commit useful artifacts before abandoning)

**Status indicator:** `RECOVERY_MODE`

---

## Files Reference

| File | Purpose |
|------|---------|
| `AI_CODING_AGENT_GODMODE.md` | Main protocol (start here) |
| `commands/*.md` | **13 modular slash commands** (explore, generate-prd, create-adr, create-issues, start-issue, generate-tests, security-review, run-validation, fresh-eyes-review, recovery, commit-and-pr, refactor, finalize) |
| `checklists/AI_CODE_SECURITY_REVIEW.md` | OWASP security checklist |
| `checklists/AI_CODE_REVIEW.md` | Code review checklist |
| `guides/FAILURE_RECOVERY.md` | Recovery procedures (rollback, abandon) |
| `guides/FRESH_EYES_REVIEW.md` | Mandatory code review process |
| `guides/PROJECT_INTEGRATION.md` | Platform project integration (GitHub/GitLab) |
| `guides/CONTEXT_OPTIMIZATION.md` | Token reduction |
| `guides/MULTI_AGENT_PATTERNS.md` | Multi-agent workflows |
| `templates/TEST_STRATEGY.md` | Testing guidance |
| `templates/ADR_TEMPLATE.md` | Architecture decisions |
| `templates/ISSUE_TEMPLATE.md` | Issue structure |
| `platforms/*.md` | Platform CLI references (GitHub, GitLab) |
| `templates/RECOVERY_REPORT.md` | Document implementation failures |

---

## Status Indicators

Use in responses:
- `READY_FOR_REVIEW` - Phase complete, awaiting feedback
- `SECURITY_SENSITIVE` - Requires security review
- `APPROVED_NEXT_PHASE` - Cleared to continue
- `HALT_PENDING_DECISION` - Blocked on decision

## Confidence Levels

- `HIGH_CONFIDENCE` - Well-understood, low risk
- `MEDIUM_CONFIDENCE` - Some uncertainty
- `LOW_CONFIDENCE` - Significant unknowns

## Risk Flags

- `BREAKING_CHANGE` - May affect existing functionality
- `SECURITY_SENSITIVE` - Auth, data, APIs
- `PERFORMANCE_IMPACT` - Latency or resource concerns
- `DEPENDENCY_CHANGE` - New/updated dependencies

---

**Version:** 3.2
**Last Updated:** December 2025
**Full docs:** See `README.md`
