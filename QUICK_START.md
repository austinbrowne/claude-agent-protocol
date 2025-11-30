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
6. [OPTIONAL] Create GitHub issues (/create-issue-from-prd)
   a. Creates first issue #123
   b. Renames PRD: docs/prds/123-YYYY-MM-DD-feature-name.md
   c. Updates issue to reference renamed PRD
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
4. Jumps to Phase 1 implementation
5. References PRD if needed for broader context
6. Closes issue when done
7. Pick next issue
```

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
→ /create-issue-from-prd
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
→ /create-issue-from-prd
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

## Files Reference

| File | Purpose |
|------|---------|
| `AI_CODING_AGENT_GODMODE.md` | Main protocol (start here) |
| `checklists/AI_CODE_SECURITY_REVIEW.md` | OWASP security checklist |
| `checklists/AI_CODE_REVIEW.md` | Code review checklist |
| `templates/TEST_STRATEGY.md` | Testing guidance |
| `templates/ADR_TEMPLATE.md` | Architecture decisions |
| `templates/GITHUB_ISSUE_TEMPLATE.md` | Issue structure |
| `guides/GITHUB_PROJECT_INTEGRATION.md` | Full gh CLI guide |
| `guides/CONTEXT_OPTIMIZATION.md` | Token reduction |
| `guides/MULTI_AGENT_PATTERNS.md` | Multi-agent workflows |

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

**Version:** 3.1
**Last Updated:** November 2025
**Full docs:** See `README.md`
