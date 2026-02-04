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
6. [OPTIONAL] Create GitHub issues (/create-issues)
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
# List ready issues
gh project item-list PROJECT_NUM --owner OWNER

# Pick one
"Let's work on issue #45"

# Claude:
1. Loads issue context (including PRD reference)
2. Checks dependencies
3. Restates the task
4. Assigns issue to you
5. Creates branch: issue-45-feature-name
6. Jumps to Phase 1 implementation
7. References PRD if needed for broader context
8. Commits changes to branch
9. Asks: "Create Pull Request?"
10. If yes: Creates PR (auto-links to issue)
11. You review & merge PR on GitHub
12. Issue auto-closes on merge
13. Pick next issue
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

### List Projects
```bash
gh project list --owner OWNER
# Output: 3  Claude Agent Protocol  open  PVT_kwHOBGF6h84BJbD_
```

### List Ready Issues
```bash
gh project item-list 3 --owner OWNER
```

### View Issue
```bash
gh issue view 45
```

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
```bash
gh issue create \
  --title "Implement feature" \
  --body-file issue.md \
  --label "type: feature,priority: high" \
  --project "Claude Agent Protocol"
```

### Close Issue
```bash
gh issue close 45 --comment "✅ Complete! All tests passing."
```

---

## Modular Commands

**17 reusable slash commands** for flexible workflows. Use individually or compose custom workflows.

### Token Usage Estimates

| Command | Tokens | Cost Est. | Notes |
|---------|--------|-----------|-------|
| `/explore` | 10-25k | $0.10-0.25 | Up to 4 parallel research agents |
| `/brainstorm` | 3-8k | $0.03-0.08 | Includes learnings search |
| `/generate-prd` | 5-10k | $0.05-0.10 | Includes research + spec-flow analysis |
| `/deepen-plan` | 20-50k | $0.20-0.50 | 10-20+ parallel agents |
| `/review-plan` | 10-20k | $0.10-0.20 | 5 agents (4 parallel + adversarial) |
| `/create-issues` | 3-8k | $0.03-0.08 | Depends on PRD size |
| `/fresh-eyes-review` | 10-40k | $0.10-0.50 | Lite ~10k, Smart selection ~20-40k |
| `/compound` | 2-5k | $0.02-0.05 | Solution capture |
| `/security-review` | 3-5k | $0.03-0.05 | Single checklist pass |
| Other commands | 1-3k | $0.01-0.03 | Minimal overhead |

*Estimates based on Claude Sonnet pricing. Actual costs vary by codebase size.*

### Phase 0: Planning (7 commands)

| Command | Description | Example |
|---------|-------------|---------|
| `/explore` | Multi-agent codebase exploration | `/explore authentication patterns` |
| `/brainstorm` | Structured divergent thinking | `/brainstorm "auth approach"` |
| `/generate-prd` | Create PRD with research + spec-flow | `/generate-prd --full "OAuth support"` |
| `/deepen-plan` | Enrich PRD with parallel research | `/deepen-plan docs/prds/2025-12-01-oauth.md` |
| `/review-plan` | Multi-agent plan review | `/review-plan docs/prds/2025-12-01-oauth.md` |
| `/create-adr` | Document architecture decision | `/create-adr "Use PostgreSQL"` |
| `/create-issues` | Generate GitHub issues from PRD | `/create-issues docs/prds/2025-12-01-oauth.md --immediate` |

### Phase 1: Execution (8 commands)

| Command | Description | Example |
|---------|-------------|---------|
| `/start-issue` | Begin work with living plan | `/start-issue 123` |
| `/generate-tests` | Generate comprehensive tests | `/generate-tests --path src/auth/AuthService.ts` |
| `/security-review` | Run security checklist | `/security-review` |
| `/run-validation` | Run tests + coverage + lint + security | `/run-validation` |
| `/fresh-eyes-review` | 13-agent smart selection review | `/fresh-eyes-review` |
| `/recovery` | Handle failed implementations | `/recovery` |
| `/commit-and-pr` | Commit and create PR | `/commit-and-pr --base experimental` |
| `/compound` | Capture solved problems | `/compound` |

### Phase 2: Finalization (2 commands)

| Command | Description | Example |
|---------|-------------|---------|
| `/refactor` | Guided refactoring | `/refactor` |
| `/finalize` | Update docs and final checks | `/finalize --all` |

### Example Workflows with Commands

**Full GODMODE workflow (v4.0):**
```bash
/explore authentication
/brainstorm "auth approach"
/generate-prd --full "OAuth 2.0 authentication"
/deepen-plan docs/prds/2025-12-01-oauth-auth.md
/review-plan docs/prds/2025-12-01-oauth-auth.md
# Creates: docs/prds/2025-12-01-oauth-auth.md

/create-issues docs/prds/2025-12-01-oauth-auth.md --immediate
# Creates issue #123, renames PRD to: docs/prds/123-2025-12-01-oauth-auth.md

/start-issue 123
# [Implement code — past learnings surfaced, living plan created]
/generate-tests
/security-review
/run-validation
/fresh-eyes-review
# [Fix any findings]
/compound
/commit-and-pr --base experimental
/refactor
/finalize --all
```

**Quick Bug Fix workflow:**
```bash
# Assumes issue #456 already exists (created manually or via /create-issues)
/start-issue 456
# [Fix bug — past solutions searched automatically]
/generate-tests --path src/auth/bugfix.ts
/fresh-eyes-review --lite
/compound
/commit-and-pr --base main
```

**Just Review Existing Changes workflow:**
```bash
# [Already have code changes staged]
/fresh-eyes-review
# [Fix issues found]
/commit-and-pr --base experimental
```

**Mid-Workflow Entry (Have PRD, Skip Explore):**
```bash
# Assumes PRD already exists: docs/prds/2025-11-28-existing-feature.md
/deepen-plan docs/prds/2025-11-28-existing-feature.md
/review-plan docs/prds/2025-11-28-existing-feature.md

/create-issues docs/prds/2025-11-28-existing-feature.md --immediate
# Creates issue #789, renames PRD to: docs/prds/789-2025-11-28-existing-feature.md

/start-issue 789
# [Implement]
/generate-tests
/run-validation
/fresh-eyes-review
/compound
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

## GitHub Projects Setup

**One-time setup:**
```bash
# 1. Install gh CLI (already done if you're reading this!)
brew install gh

# 2. Authenticate
gh auth login
gh auth refresh -s project --hostname github.com

# 3. Create project (or use existing)
gh project create --owner OWNER --title "My Dev Board"

# 4. Find your project number
gh project list --owner OWNER
# Note the number in first column
```

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

### Workflow 3: No GitHub Projects (Direct Execution)
```
Single Session:
→ Entry Point A (Phase 0)
→ Generate PRD
→ Skip GitHub issues
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
| `commands/*.md` | **17 modular slash commands** (explore, brainstorm, generate-prd, deepen-plan, review-plan, create-adr, create-issues, start-issue, generate-tests, security-review, run-validation, fresh-eyes-review, recovery, commit-and-pr, compound, refactor, finalize) |
| `agents/review/*.md` | **17 review agents** (security, code-quality, edge-case, supervisor, adversarial-validator, performance, api-contract, concurrency, error-handling, data-validation, dependency, testing-adequacy, config-secrets, documentation, architecture, simplicity, spec-flow) |
| `agents/research/*.md` | **4 research agents** (codebase, learnings, best-practices, framework-docs) |
| `checklists/AI_CODE_SECURITY_REVIEW.md` | OWASP security checklist |
| `checklists/AI_CODE_REVIEW.md` | Code review checklist |
| `guides/FAILURE_RECOVERY.md` | Recovery procedures (rollback, abandon) |
| `guides/FRESH_EYES_REVIEW.md` | Smart selection review process (13 agents) |
| `guides/GITHUB_PROJECT_INTEGRATION.md` | Full gh CLI guide |
| `guides/CONTEXT_OPTIMIZATION.md` | Token reduction |
| `guides/MULTI_AGENT_PATTERNS.md` | Multi-agent workflows |
| `templates/TEST_STRATEGY.md` | Testing guidance |
| `templates/ADR_TEMPLATE.md` | Architecture decisions |
| `templates/GITHUB_ISSUE_TEMPLATE.md` | Issue structure |
| `templates/RECOVERY_REPORT.md` | Document implementation failures |
| `templates/BRAINSTORM_TEMPLATE.md` | Brainstorm session output |
| `templates/SOLUTION_TEMPLATE.md` | Knowledge compound docs |
| `templates/TODO_TEMPLATE.md` | File-based todo tracking |
| `templates/LIVING_PLAN_TEMPLATE.md` | Implementation tracking |
| `docs/solutions/` | Knowledge compounding storage |
| `docs/brainstorms/` | Brainstorm session records |
| `.todos/` | File-based todo tracking |

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

**Version:** 4.0
**Last Updated:** February 2026
**Full docs:** See `README.md`
