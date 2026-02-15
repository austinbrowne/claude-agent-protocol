# GODMODE - AI Coding Agent Protocol

**Version:** 5.3.0-experimental
**Status:** Experimental (Agent Teams integration)

A Claude Code plugin for AI-assisted software development. 7 workflow commands, 26 skill packages, 21 specialized agents (17 review + 4 research), Agent Teams integration for parallel reviews and implementation swarms, knowledge compounding, and structured phases for planning, execution, and finalization.

---

## Installation

```bash
/plugin marketplace add https://github.com/austinbrowne/claude-agent-protocol
/plugin install godmode
```

**Update to latest:**
```bash
/plugin update godmode
```

**Requirements:**
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- GitHub CLI (`gh`) for issue/PR workflows (optional)

---

## Workflow

```
Explore → Plan → Implement → Review → Learn → Ship
```

| Command | Purpose |
|---------|---------|
| `/explore` | Reconnaissance & ideation — codebase exploration + brainstorming |
| `/plan` | Planning & requirements — plan generation, deepen, review, issues, ADR |
| `/implement` | Implementation — start issue, swarm plan, triage issues, tests, validation, security, recovery |
| `/review` | Code review — fresh eyes (full/lite), protocol compliance |
| `/learn` | Knowledge capture — save solved problems as reusable docs |
| `/ship` | Ship — commit/PR, finalize, refactor |
| `/loop` | Autonomous loop — iterates plan tasks with Task subagent context rotation |

Each workflow offers sub-step selection and chains to the next workflow after completion. Skip, reorder, or exit at any point.

---

## Example Flows

### New Feature (Full Cycle)

```
You: /explore
  → Claude explores the codebase, identifies relevant files and patterns
  → Brainstorms approaches with comparison matrix
  → "Ready to plan?"

You: /plan
  → Generates a plan (Minimal, Standard, or Comprehensive)
  → Deepens the plan with parallel research agents
  → Multi-agent plan review with adversarial validation
  → Creates GitHub issues from approved plan
  → "Ready to implement?"

You: /implement
  → Picks an issue, creates a branch
  → Implements with living plan tracking
  → Generates tests, runs validation
  → Security review on auth/data/API changes
  → "Ready for review?"

You: /review
  → Fresh Eyes Review: 14 agents review code with zero context (no confirmation bias)
  → Smart agent selection — core agents always run, conditional agents triggered by diff
  → Adversarial validator challenges findings
  → "Ready to ship?"

You: /ship
  → /commit-and-pr creates commit and pull request
  → Final documentation and validation
  → "Capture learnings?"
```

### Autonomous

```
You: /loop "add user authentication to the API"
  → Generates plan automatically
  → Implements each task in separate context-rotated iterations
  → Runs lite review and auto-fixes CRITICAL/HIGH findings
  → Commits locally after each task
  → All local — no push, no PR
```

### Bug Fix

```
You: /explore
  → Investigate the bug, identify root cause and affected files

You: /implement
  → Fix the bug, generate regression tests, run validation

You: /review
  → Fresh Eyes Review (lite mode for smaller changes)

You: /ship
  → Commit and PR
```

### Quick Fix (Root Cause Known)

```
You: /implement
  → Apply the fix, run tests

You: /review
  → Quick review pass

You: /ship
  → Commit and PR
```

### Just Review Existing Changes

```
You: /review
  → 14-agent review on staged/committed changes

You: /ship
  → Commit and PR with review findings addressed
```

### Individual Skills (Direct Invocation)

Every sub-step is also directly invocable as a slash command:

```
You: /brainstorm "authentication approaches for the API"
  → Structured divergent thinking with comparison matrix

You: /fresh-eyes-review
  → Full 14-agent code review on current changes

You: /security-review
  → OWASP Top 10 2025 security checklist on current changes

You: /generate-tests
  → Comprehensive test generation for implemented code

You: /commit-and-pr
  → Commit with finding verification gate and PR creation

You: /learn
  → Capture what you just solved as a reusable solution doc
```

---

## What's Included

### Workflow Commands (7)
Top-level orchestrators with sub-step selection via `AskUserQuestion`.

### Skills (26)
Reusable methodology packages, each directly invocable:

| Skill | Purpose |
|-------|---------|
| `/explore` | Multi-agent codebase exploration |
| `/brainstorm` | Structured divergent thinking |
| `/generate-plan` | Plan creation (3 tiers) with integrated research and spec-flow |
| `/deepen-plan` | Plan enrichment with parallel research (Agent Teams mode available) |
| `/review-plan` | Multi-agent plan review with adversarial validation (Agent Teams mode available) |
| `/create-issues` | GitHub issue generation from plan |
| `/create-adr` | Architecture Decision Records |
| `/file-issues` | Rapid-fire issue filing with sparse templates |
| `/file-issue` | File a single GitHub issue from a description |
| `/enhance-issue` | Refine sparse issues with exploration and planning |
| `/start-issue` | Issue startup with living plan |
| `/swarm-plan` | Parallel implementation of plan tasks using Agent Teams |
| `/triage-issues` | Batch-triage and plan open GitHub issues — get them ready_for_dev |
| `/generate-tests` | Comprehensive test generation |
| `/run-validation` | Tests + coverage + lint + security |
| `/security-review` | OWASP security methodology |
| `/recovery` | Failure recovery decision tree |
| `/refactor` | Guided refactoring |
| `/fresh-eyes-review` | 14-agent smart selection review (Agent Teams mode available) |
| `/review-protocol` | Protocol compliance review |
| `/document-review` | Document quality review (plans, brainstorms, ADRs) |
| `/commit-and-pr` | Commit and PR with finding verification |
| `/finalize` | Final documentation + validation |
| `/learn` | Knowledge compounding |
| `/todos` | File-based todo tracking |
| `/setup` | Per-project review agent configuration |

### Agents (21)
- **17 review agents** — security, code quality, edge case, supervisor, adversarial validator, performance, API contract, concurrency, error handling, data validation, dependency, testing adequacy, config/secrets, documentation, architecture, simplicity, spec-flow
- **4 research agents** — codebase researcher, learnings researcher, best practices researcher, framework docs researcher

### Also Included
- **Checklists** — OWASP Top 10 2025 security checklist, AI code review criteria
- **Templates** — Plan (3-tier), test strategy, ADR, brainstorm, solution doc, todo, living plan, GitHub issue, bug issue, recovery report
- **Guides** — Fresh Eyes Review, Agent Teams guide, failure recovery, context optimization, multi-agent patterns, GitHub Projects integration

---

## Key Concepts

### Security-First
45% of AI code has vulnerabilities. The protocol enforces mandatory security review for auth, PII, and external APIs. OWASP Top 10 2025 checklist built in.

### Knowledge Compounding
Capture solved problems as searchable docs via `/learn`. Past learnings are surfaced automatically during planning and implementation. Your knowledge base grows with every solved problem.

### Zero-Context Review
Fresh Eyes Review gives agents zero conversation context — they review the diff cold. This eliminates confirmation bias that accumulates during implementation.

### Smart Agent Selection
Core review agents always run. Conditional agents (security, concurrency, API contract, etc.) trigger only when the diff content matches their expertise. Per-project configuration via `/setup`.

### Human in the Loop
Every phase transition pauses for human approval. Skip, reorder, or exit at any point. The protocol never merges, deploys, or finalizes without explicit consent.

### Autonomous Mode
`/loop` enables autonomous development with context rotation. Each task runs in a fresh context window, preventing pollution. Plan checkboxes track progress across iterations. Cancel anytime.

---

## Directory Structure

```
.claude-plugin/
├── plugin.json                        # Plugin metadata
└── marketplace.json                   # Marketplace listing

commands/                              # 7 workflow entry points
├── explore.md
├── plan.md
├── implement.md
├── review.md
├── learn.md
├── ship.md
└── loop.md

skills/                                # 26 reusable skill packages
├── brainstorm/SKILL.md
├── explore/SKILL.md
├── generate-plan/SKILL.md
├── deepen-plan/SKILL.md
├── review-plan/SKILL.md
├── create-issues/SKILL.md
├── create-adr/SKILL.md
├── file-issues/SKILL.md
├── file-issue/SKILL.md
├── enhance-issue/SKILL.md
├── start-issue/SKILL.md
├── swarm-plan/SKILL.md               # Agent Teams — parallel plan implementation
├── triage-issues/SKILL.md            # Batch issue triage and planning
├── generate-tests/SKILL.md
├── run-validation/SKILL.md
├── security-review/SKILL.md
├── recovery/SKILL.md
├── refactor/SKILL.md
├── fresh-eyes-review/SKILL.md
├── review-protocol/SKILL.md
├── document-review/SKILL.md           # Document quality review
├── commit-and-pr/SKILL.md
├── finalize/SKILL.md
├── learn/SKILL.md
├── todos/SKILL.md
└── setup/SKILL.md                     # Per-project review configuration

agents/
├── review/                            # 17 review agent definitions
└── research/                          # 4 research agent definitions

checklists/                            # Security + code review checklists
templates/                             # 10 reusable templates
guides/                                # Process guides

docs/
├── solutions/                         # Knowledge compounding storage
├── brainstorms/                       # Brainstorm session records
└── plans/                             # Plans (Minimal, Standard, Comprehensive)
```

---

## Version History

**v5.2.0-experimental (February 2026)** - Current (experimental-agent-teams branch)
- Compound engineering integration — setup skill, document-review skill
- Plan lifecycle management with forward-only status transition guards
- Per-project review configuration via `godmode.local.md` (`/setup`)
- Document quality review skill with 4-dimension scoring (`/document-review`)
- Cross-workflow routing enforcement language strengthened across all commands
- 5-layer security model for per-project config (gitignore, prompt injection, minimum agents, validation, precedence)
- 26 skill packages, 7 workflow commands

**v5.1.x-experimental (February 2026)**
- `/loop` command — autonomous development loop with Task subagent context rotation
- State-aware menu transitions across all workflow commands
- EnterPlanMode prohibition added to all 7 workflow commands

**v5.0.0-experimental (February 2026)**
- Agent Teams integration — tiered strategy with implementation swarms
- `fresh-eyes-review`, `review-plan`, `deepen-plan` support team mode (inter-agent discussion, live cross-validation)
- New `/swarm-plan` skill — parallel plan implementation with swarmability assessment
- New `/triage-issues` skill — batch GitHub issue triage and planning
- Agent Teams guide (`guides/AGENT_TEAMS_GUIDE.md`) — formation patterns, detection, fallback
- Automatic fallback to subagent mode when Agent Teams is disabled
- 24 skill packages (added `swarm-plan`, `triage-issues`)

**v4.2.0 (February 2026)**
- Renamed "PRD" to "Plan" throughout — clearer terminology
- 3-tier plan system: Minimal, Standard, Comprehensive (replaces Lite/Full)
- `/generate-plan` skill is self-sufficient — runs its own 4-agent research (no prior `/explore` required)
- Moved `docs/prds/` to `docs/plans/`, renamed `generate-prd` to `generate-plan`
- New `PLAN_TEMPLATE.md` with structured templates for all 3 tiers
- 22 skill packages (added `/file-issues`, `/file-issue`, `/enhance-issue`)

**v4.1.x (February 2026)**
- `/file-issues` and `/file-issue` skills for rapid issue filing with sparse templates
- `/enhance-issue` skill to refine `needs_refinement` issues with exploration and planning
- Bug issue template (`templates/BUG_ISSUE_TEMPLATE.md`)
- Plugin marketplace installation support

**v4.1.0 (February 2026)**
- 6 workflow commands replacing 21 individual commands
- 19 reusable skill packages extracted into `skills/`
- Renamed `/compound` to `/learn`
- Two-layer architecture: skills (knowledge + user-facing) → agents (expert personas)

**v4.0 (February 2026)**
- 17 modular slash commands
- 21 specialized agents (17 review + 4 research) with smart selection
- Knowledge compounding (`docs/solutions/`)
- 13-agent Fresh Eyes Review with smart selection
- Adversarial validator
- Structured brainstorming, plan deepening, spec-flow analysis

**v3.x (November-December 2025)**
- Optimized protocol for LLM attention budget
- Mandatory STOP checkpoints
- OWASP Top 10 2025 security checklist

---

**Built with research from:** Anthropic, Microsoft, Google, OWASP, DX Research, Veracode, and real-world usage.
