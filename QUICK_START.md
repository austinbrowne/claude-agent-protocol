# GODMODE Quick Start Guide

## 7 Workflow Commands

Use these as entry points. Each workflow offers sub-step selection and chains to the next workflow after completion.

| Command | Purpose | Sub-steps |
|---------|---------|-----------|
| `/explore` | Reconnaissance & ideation | Codebase exploration, brainstorming |
| `/plan` | Planning & requirements | Generate plan, deepen plan, review plan, create issues, ADR |
| `/implement` | Implementation | Start issue, team implementation, triage issues, generate tests, validation, security review, recovery |
| `/review` | Code review | Fresh eyes review (full/lite), protocol compliance |
| `/learn` | Knowledge capture | Save solved problems as reusable solution docs |
| `/ship` | Ship | Commit/PR, finalize, refactor |
| `/loop` | Autonomous loop | Plan, implement each task, review — all with Task subagent context rotation |

---

## Common Workflow Recipes

### Full Feature
```
/explore → /plan → /implement → /review → /learn → /ship
```

### Bug Fix
```
/explore → /implement → /review → /learn → /ship
```

### Quick Fix
```
/implement → /review → /ship
```

### Just Review
```
/review → /ship
```

### Autonomous
```
/loop <description>            Plan, implement each task, review, commit (all local)
/loop --plan <path>            Iterate tasks from an existing plan
/loop --issue 42               Enhance if needed, plan, implement, review
```

Cancel: Ctrl+C (re-run with `--plan` to resume)

---

## Two Entry Points

### Entry Point A: New Feature (Start from Scratch)

```bash
1. /explore                    # Understand the codebase
2. /plan                       # Generate plan → select "Generate plan"
3. /plan                       # Review plan → select "Review plan"
4. /plan                       # Create issues → select "Create GitHub issues"
5. /implement                  # Start issue → select "Start issue"
6. [Implement code]
7. /implement                  # Generate tests → select "Generate tests"
8. /implement                  # Run validation → select "Run validation"
9. /review                     # Fresh eyes review (full)
10. /learn                     # Capture any learnings
11. /ship                      # Commit and create PR
```

### Entry Point B: Pick Existing Issue

```bash
# List ready issues
gh project item-list PROJECT_NUM --owner OWNER

# Pick one
/implement                     # Select "Start issue" → enter issue number
# [Implement code]
/implement                     # Run validation
/review                        # Fresh eyes review
/ship                          # Commit and create PR
```

---

## Individual Skills

Each workflow loads skills from `skills/*/SKILL.md`. All skills are also directly invocable as slash commands with the `godmode:` prefix.

### Planning Skills
| Skill | Purpose |
|-------|---------|
| `explore` | Multi-agent codebase exploration (4 parallel research agents) |
| `brainstorm` | Structured divergent thinking with comparison matrices |
| `generate-plan` | Create plan (Minimal/Standard/Comprehensive) with integrated research and spec-flow analysis |
| `deepen-plan` | Enrich plan with massive parallel research (10-20+ agents) |
| `review-plan` | Multi-agent plan review with adversarial validation |
| `create-adr` | Document architecture decisions |
| `create-issues` | Generate GitHub issues from approved plan |

### Issue Skills
| Skill | Purpose |
|-------|---------|
| `file-issues` | Rapid-fire issue filing with sparse templates |
| `file-issue` | File a single GitHub issue from a description |
| `enhance-issue` | Refine sparse issues with exploration and planning |

### Execution Skills
| Skill | Purpose |
|-------|---------|
| `start-issue` | Begin work with living plan and past learnings |
| `team-implement` | Team-based implementation with defined roles (Lead, Analyst, Implementers) |
| `triage-issues` | Batch-triage and plan open GitHub issues — get them ready_for_dev |
| `generate-tests` | Generate comprehensive test suites |
| `run-validation` | Tests + coverage + lint + security checks |
| `security-review` | OWASP security checklist review |
| `recovery` | Handle failed implementations (Continue/Rollback/Abandon) |
| `refactor` | Guided refactoring with incremental test verification |

### Review Skills
| Skill | Purpose |
|-------|---------|
| `fresh-eyes-review` | 14-agent smart selection review with adversarial validation |
| `review-protocol` | Protocol compliance check and status report |
| `document-review` | Document quality review for plans, brainstorms, ADRs (clarity, completeness, specificity, YAGNI) |

### Shipping Skills
| Skill | Purpose |
|-------|---------|
| `commit-and-pr` | Commit and create PR with mandatory review gate |
| `finalize` | Final documentation updates and validation |

### Knowledge Skills
| Skill | Purpose |
|-------|---------|
| `learn` | Capture solved problems as searchable solution docs |

### Configuration Skills
| Skill | Purpose |
|-------|---------|
| `setup` | Per-project review configuration — auto-detects stack, selects review agents, writes godmode.local.md |

---

## GitHub Projects Setup

**One-time setup:**
```bash
# 1. Install gh CLI
brew install gh

# 2. Authenticate
gh auth login
gh auth refresh -s project --hostname github.com

# 3. Create project (or use existing)
gh project create --owner OWNER --title "My Dev Board"

# 4. Find your project number
gh project list --owner OWNER
```

---

## Common Commands

```bash
# List projects
gh project list --owner OWNER

# List ready issues
gh project item-list 3 --owner OWNER

# View issue
gh issue view 45

# List plans
ls docs/plans/

# Create issue manually
gh issue create --title "..." --body-file issue.md --label "type: feature"
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
- Skip exploration (understand codebase first)
- Skip security review when flagged
- Skip edge case testing
- Hardcode secrets
- Use string concatenation in SQL

**ALWAYS do:**
- Test edge cases (null, empty, boundaries, errors)
- Wrap external calls in try/catch
- Validate user input
- Pause for human feedback
- Run `/review` before `/ship`

---

## What If Implementation Fails?

Use the recovery skill within `/implement`:

1. **Can fix quickly?** → Continue (iterate)
2. **Approach fundamentally flawed?** → Abandon + partial save, return to `/plan`
3. **Fixable with different approach?** → Rollback & retry

**Read:** `guides/FAILURE_RECOVERY.md` for full recovery procedures.

---

## Files Reference

| File | Purpose |
|------|---------|
| `AI_CODING_AGENT_GODMODE.md` | Main protocol (start here) |
| `commands/*.md` | **7 workflow commands** (explore, plan, implement, review, learn, ship, loop) |
| `skills/*/SKILL.md` | **29 reusable skill packages** |
| `agents/review/*.md` | **16 review agents** |
| `agents/research/*.md` | **4 research agents** |
| `agents/team/*.md` | **3 team role definitions** (Lead, Implementer, Analyst) |
| `agents/product/*.md` | **1 product agent** (Product Owner) |
| `checklists/AI_CODE_SECURITY_REVIEW.md` | Security checklist (OWASP Top 10) |
| `checklists/AI_CODE_REVIEW.md` | Code review checklist |
| `guides/FAILURE_RECOVERY.md` | Recovery procedures |
| `guides/FRESH_EYES_REVIEW.md` | Smart selection review process |
| `guides/AGENT_TEAMS_GUIDE.md` | Agent Teams patterns and best practices |
| `templates/*.md` | 11 reusable templates |
| `docs/solutions/` | Knowledge compounding storage |
| `docs/brainstorms/` | Brainstorm session records |
| `.todos/` | File-based todo tracking |

---

## Status Indicators

- `READY_FOR_REVIEW` - Phase complete, awaiting feedback
- `SECURITY_SENSITIVE` - Requires security review
- `APPROVED_NEXT_PHASE` - Cleared to continue
- `HALT_PENDING_DECISION` - Blocked on decision
- `RECOVERY_MODE` - Implementation failed, evaluating options

---

**Version:** 5.4.0-experimental
**Last Updated:** February 2026
**Full docs:** See `README.md`
