# Project Conventions

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `commands/` | 6 workflow entry points (`/explore` merged into its skill) |
| `skills/` | 29 reusable skill packages (also user-invocable) |
| `agents/review/` | 16 review agent definitions |
| `agents/research/` | 4 research agent definitions |
| `agents/team/` | 3 team role definitions (Lead, Implementer, Analyst) |
| `agents/product/` | 1 product agent definition (Product Owner) |
| `docs/solutions/` | Knowledge compounding — captured solved problems |
| `docs/brainstorms/` | Brainstorm session records |
| `.todos/` | File-based todo tracking (committed to git) |
| `.claude/loop-context.md` | Autonomous loop state (status, counts, timing, task commits) |
| `.claude/loop-notes.md` | Inter-task knowledge passing for `/loop` workers |
| `docs/plans/` | Plans (Minimal, Standard, Comprehensive) |
| `docs/roadmaps/` | Product roadmaps (Minimal, Standard) |
| `docs/backlogs/` | Product backlogs (epics, user stories) |

## Status Indicators

Use in responses:
- `READY_FOR_REVIEW` - Phase complete, awaiting feedback
- `APPROVED_NEXT_PHASE` - Cleared to continue
- `HALT_PENDING_DECISION` - Blocked on decision
- `SECURITY_SENSITIVE` - Requires security review
- `RECOVERY_MODE` - Implementation failed, evaluating options

## Confidence Levels

- `HIGH_CONFIDENCE` - Well-understood, low-risk
- `MEDIUM_CONFIDENCE` - Some uncertainty, may need iteration
- `LOW_CONFIDENCE` - Significant unknowns, discuss before proceeding

## Risk Flags

- `BREAKING_CHANGE` - May affect existing functionality
- `SECURITY_SENSITIVE` - Touches auth, data, or external APIs
- `PERFORMANCE_IMPACT` - May affect latency or resources
- `DEPENDENCY_CHANGE` - Adds/removes/upgrades dependencies

## Extended Thinking

Users can request deeper reasoning:
- "think" - standard reasoning for moderate complexity
- "think hard" - multi-step problems, security architecture, debugging
- "ultrathink" - critical architecture decisions, major refactors

Claude should suggest extended thinking for security-sensitive or high-risk changes.

## Code Style Defaults

- Write tests for new code
- Use type hints (Python) or TypeScript
- Follow existing project conventions
- Conventional commits (feat:, fix:, docs:, refactor:)

## Reference Files

| File | Purpose |
|------|---------|
| `AI_CODING_AGENT_GODMODE.md` | Full protocol documentation |
| `QUICK_START.md` | Entry points and command reference |
| `commands/*.md` | 7 workflow commands |
| `skills/*/SKILL.md` | 29 reusable skill packages |
| `agents/review/*.md` | 16 review agent definitions |
| `agents/research/*.md` | 4 research agent definitions |
| `agents/team/*.md` | 3 team role definitions (Lead, Implementer, Analyst) |
| `agents/product/*.md` | 1 product agent definition (Product Owner) |
| `checklists/AI_CODE_SECURITY_REVIEW.md` | OWASP security checklist |
| `guides/FRESH_EYES_REVIEW.md` | Smart selection review process |
| `guides/AGENT_TEAMS_GUIDE.md` | Agent Teams formation patterns and best practices |
| `guides/FAILURE_RECOVERY.md` | Recovery procedures |
| `templates/*.md` | 11 reusable templates |
