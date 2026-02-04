# GODMODE - AI Coding Agent Protocol

**Version:** 4.1.1
**Status:** Production-ready

A Claude Code plugin for AI-assisted software development. 6 workflow commands, 19 skill packages, 21 specialized agents (17 review + 4 research), knowledge compounding, and structured phases for planning, execution, and finalization.

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
| `/workflows:explore` | Reconnaissance & ideation — codebase exploration + brainstorming |
| `/workflows:plan` | Planning & requirements — PRD, deepen, review, issues, ADR |
| `/workflows:implement` | Implementation — start issue, tests, validation, security, recovery |
| `/workflows:review` | Code review — fresh eyes (full/lite), protocol compliance |
| `/workflows:learn` | Knowledge capture — save solved problems as reusable docs |
| `/workflows:ship` | Ship — commit/PR, finalize, refactor |

Each workflow offers sub-step selection and chains to the next workflow after completion. Skip, reorder, or exit at any point.

---

## Example Flows

### New Feature (Full Cycle)

```
You: /workflows:explore
  → Claude explores the codebase, identifies relevant files and patterns
  → Brainstorms approaches with comparison matrix
  → "Ready to plan? → /workflows:plan"

You: /workflows:plan
  → Generates a PRD (Lite or Full)
  → Deepens the plan with parallel research agents
  → Multi-agent plan review with adversarial validation
  → Creates GitHub issues from approved PRD
  → "Ready to implement? → /workflows:implement"

You: /workflows:implement
  → Picks an issue, creates a branch
  → Implements with living plan tracking
  → Generates tests, runs validation
  → Security review on auth/data/API changes
  → "Ready for review? → /workflows:review"

You: /workflows:review
  → Fresh Eyes Review: 13 agents review code with zero context (no confirmation bias)
  → Smart agent selection — core agents always run, conditional agents triggered by diff
  → Adversarial validator challenges findings
  → "Ready to ship? → /workflows:ship"

You: /workflows:ship
  → /commit-and-pr creates commit and pull request
  → Final documentation and validation
  → "Capture learnings? → /workflows:learn"
```

### Bug Fix

```
You: /workflows:explore
  → Investigate the bug, identify root cause and affected files

You: /workflows:implement
  → Fix the bug, generate regression tests, run validation

You: /workflows:review
  → Fresh Eyes Review (lite mode for smaller changes)

You: /workflows:ship
  → Commit and PR
```

### Quick Fix (Root Cause Known)

```
You: /workflows:implement
  → Apply the fix, run tests

You: /workflows:review
  → Quick review pass

You: /workflows:ship
  → Commit and PR
```

### Just Review Existing Changes

```
You: /workflows:review
  → 13-agent review on staged/committed changes

You: /workflows:ship
  → Commit and PR with review findings addressed
```

### Individual Skills (Direct Invocation)

Every sub-step is also directly invocable as a slash command:

```
You: /brainstorm "authentication approaches for the API"
  → Structured divergent thinking with comparison matrix

You: /fresh-eyes-review
  → Full 13-agent code review on current changes

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

### Workflow Commands (6)
Top-level orchestrators with sub-step selection via `AskUserQuestion`.

### Skills (19)
Reusable methodology packages, each directly invocable:

| Skill | Purpose |
|-------|---------|
| `/explore` | Multi-agent codebase exploration |
| `/brainstorm` | Structured divergent thinking |
| `/generate-prd` | PRD creation with research and spec-flow |
| `/deepen-plan` | Plan enrichment with parallel research |
| `/review-plan` | Multi-agent plan review with adversarial validation |
| `/create-issues` | GitHub issue generation from PRD |
| `/create-adr` | Architecture Decision Records |
| `/start-issue` | Issue startup with living plan |
| `/generate-tests` | Comprehensive test generation |
| `/run-validation` | Tests + coverage + lint + security |
| `/security-review` | OWASP security methodology |
| `/recovery` | Failure recovery decision tree |
| `/refactor` | Guided refactoring |
| `/fresh-eyes-review` | 13-agent smart selection review |
| `/review-protocol` | Protocol compliance review |
| `/commit-and-pr` | Commit and PR with finding verification |
| `/finalize` | Final documentation + validation |
| `/learn` | Knowledge compounding |
| `/todos` | File-based todo tracking |

### Agents (21)
- **17 review agents** — security, code quality, edge case, supervisor, adversarial validator, performance, API contract, concurrency, error handling, data validation, dependency, testing adequacy, config/secrets, documentation, architecture, simplicity, spec-flow
- **4 research agents** — codebase researcher, learnings researcher, best practices researcher, framework docs researcher

### Also Included
- **Checklists** — OWASP Top 10 2025 security checklist, AI code review criteria
- **Templates** — PRD, test strategy, ADR, brainstorm, solution doc, todo, living plan, GitHub issue
- **Guides** — Fresh Eyes Review, failure recovery, context optimization, multi-agent patterns, GitHub Projects integration

---

## Key Concepts

### Security-First
45% of AI code has vulnerabilities. The protocol enforces mandatory security review for auth, PII, and external APIs. OWASP Top 10 2025 checklist built in.

### Knowledge Compounding
Capture solved problems as searchable docs via `/learn`. Past learnings are surfaced automatically during planning and implementation. Your knowledge base grows with every solved problem.

### Zero-Context Review
Fresh Eyes Review gives agents zero conversation context — they review the diff cold. This eliminates confirmation bias that accumulates during implementation.

### Smart Agent Selection
Core review agents always run. Conditional agents (security, concurrency, API contract, etc.) trigger only when the diff content matches their expertise.

### Human in the Loop
Every phase transition pauses for human approval. Skip, reorder, or exit at any point. The protocol never merges, deploys, or finalizes without explicit consent.

---

## Directory Structure

```
.claude-plugin/
├── plugin.json                        # Plugin metadata
└── marketplace.json                   # Marketplace listing

commands/                              # 6 workflow entry points
├── explore.md
├── plan.md
├── implement.md
├── review.md
├── learn.md
└── ship.md

skills/                                # 19 reusable skill packages
├── brainstorm/SKILL.md
├── explore/SKILL.md
├── generate-prd/SKILL.md
├── deepen-plan/SKILL.md
├── review-plan/SKILL.md
├── create-issues/SKILL.md
├── create-adr/SKILL.md
├── start-issue/SKILL.md
├── generate-tests/SKILL.md
├── run-validation/SKILL.md
├── security-review/SKILL.md
├── recovery/SKILL.md
├── refactor/SKILL.md
├── fresh-eyes-review/SKILL.md
├── review-protocol/SKILL.md
├── commit-and-pr/SKILL.md
├── finalize/SKILL.md
├── learn/SKILL.md
└── todos/SKILL.md

agents/
├── review/                            # 17 review agent definitions
└── research/                          # 4 research agent definitions

checklists/                            # Security + code review checklists
templates/                             # 8 reusable templates
guides/                                # Process guides

docs/
├── solutions/                         # Knowledge compounding storage
├── brainstorms/                       # Brainstorm session records
└── prds/                              # Product Requirements Documents
```

---

## Version History

**v4.1.1 (February 2026)** - Current
- Fix workflow command namespacing (`/workflows:explore` instead of `/godmode:explore`)
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
