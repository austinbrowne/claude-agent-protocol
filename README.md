# AI Coding Agent Protocol

**Version:** 4.2
**Last Updated:** February 2026
**Status:** Production-ready

Core protocol and templates for AI-assisted software development with Claude Code. 6 workflow commands, 19 reusable skill packages, 21 specialized agents (17 review + 4 research), knowledge compounding, and structured phases for planning, execution, and finalization.

---

## Installation

**Quick install:**
```bash
git clone https://github.com/austinbrowne/claude-agent-protocol.git ~/.claude
```

**Pin to specific version:**
```bash
git clone --branch v4.0 https://github.com/austinbrowne/claude-agent-protocol.git ~/.claude
```

**Update to latest:**
```bash
cd ~/.claude && git pull
```

**Requirements:**
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- GitHub CLI (`gh`) for issue/PR workflows (optional)

---

## What's Included

### Core Protocol
- **AI_CODING_AGENT_GODMODE.md** - Standard Operating Procedure (SOP) for AI agents
- **QUICK_START.md** - Quick reference for entry points and common commands
- **CLAUDE.md** - Global user instructions and communication style
- **PRD_TEMPLATE.md** - Product Requirements Document template (Lite + Full) with spec-flow analysis

### Workflow Commands (6)
- **`/explore`** - Reconnaissance & ideation: codebase exploration + brainstorming
- **`/plan`** - Planning & requirements: PRD, deepen, review, issues, ADR
- **`/implement`** - Implementation: start issue, tests, validation, security, recovery
- **`/review`** - Code review: fresh eyes (full/lite), protocol compliance
- **`/learn`** - Knowledge capture: save solved problems as reusable docs
- **`/ship`** - Ship: commit/PR, finalize, refactor

### Skills (19)
- **Brainstorm** (`skills/brainstorm/`) - Structured divergent thinking methodology
- **Explore** (`skills/explore/`) - Multi-agent codebase exploration
- **Generate PRD** (`skills/generate-prd/`) - PRD creation with research and spec-flow
- **Deepen Plan** (`skills/deepen-plan/`) - Plan enrichment with parallel research
- **Review Plan** (`skills/review-plan/`) - Multi-agent plan review with adversarial validation
- **Create Issues** (`skills/create-issues/`) - GitHub issue generation from PRD
- **Create ADR** (`skills/create-adr/`) - Architecture Decision Records
- **Start Issue** (`skills/start-issue/`) - Issue startup with living plan
- **Generate Tests** (`skills/generate-tests/`) - Comprehensive test generation
- **Run Validation** (`skills/run-validation/`) - Tests + coverage + lint + security
- **Security Review** (`skills/security-review/`) - OWASP security review methodology
- **Recovery** (`skills/recovery/`) - Failure recovery decision tree
- **Refactor** (`skills/refactor/`) - Guided refactoring methodology
- **Fresh Eyes Review** (`skills/fresh-eyes-review/`) - 13-agent smart selection review
- **Review Protocol** (`skills/review-protocol/`) - Protocol compliance review
- **Commit and PR** (`skills/commit-and-pr/`) - Commit and PR creation with gates
- **Finalize** (`skills/finalize/`) - Final documentation and validation
- **Learn** (`skills/learn/`) - Knowledge compounding (capture solved problems)
- **File Todos** (`skills/todos/`) - File-based todo tracking conventions

### Checklists
- **AI_CODE_SECURITY_REVIEW.md** - OWASP Top 10 2025 security checklist (45% of AI code has vulnerabilities!)
- **AI_CODE_REVIEW.md** - AI-specific code review criteria (edge cases, hallucinations, etc.)

### Templates (8)
- **TEST_STRATEGY.md** - Comprehensive test strategy matrix (unit, integration, E2E, security, performance)
- **ADR_TEMPLATE.md** - Architecture Decision Records (prevent "why did we do this?" 6 months later)
- **GITHUB_ISSUE_TEMPLATE.md** - Standard issue structure for AI-assisted development
- **BRAINSTORM_TEMPLATE.md** - Brainstorm session output with YAML frontmatter
- **SOLUTION_TEMPLATE.md** - Knowledge compound docs with searchable metadata
- **TODO_TEMPLATE.md** - File-based todo tracking with status transitions
- **LIVING_PLAN_TEMPLATE.md** - Implementation tracking with progress logs

### Guides
- **FRESH_EYES_REVIEW.md** - 13-agent smart selection code review process
- **FAILURE_RECOVERY.md** - Recovery procedures for failed implementations
- **CONTEXT_OPTIMIZATION.md** - Reduce token usage by 30-50%
- **MULTI_AGENT_PATTERNS.md** - Coordinate multiple agents for complex tasks
- **GITHUB_PROJECT_INTEGRATION.md** - GitHub Projects workflow with gh CLI

### Agents (21)
- **17 review agents** (`agents/review/`) - Security, code quality, edge case, supervisor, adversarial validator, performance, API contract, concurrency, error handling, data validation, dependency, testing adequacy, config/secrets, documentation, architecture, simplicity, spec-flow
- **4 research agents** (`agents/research/`) - Codebase researcher, learnings researcher, best practices researcher, framework docs researcher

### Workflow Commands
- **6 workflow entry points** - Top-level orchestrators with AskUserQuestion sub-step selection (see below)

---

## Directory Structure

```
~/.claude/
├── README.md                           # This file
├── AI_CODING_AGENT_GODMODE.md         # Main SOP (v4.2)
├── QUICK_START.md                      # Quick reference guide
├── CLAUDE.md                           # Global instructions
├── PRD_TEMPLATE.md                     # PRD template (with spec-flow analysis)
│
├── commands/                           # 6 workflow entry points
│   ├── explore.md                     # Reconnaissance & ideation
│   ├── plan.md                        # Planning & requirements
│   ├── implement.md                   # Implementation
│   ├── review.md                      # Code review
│   ├── learn.md                       # Knowledge capture
│   └── ship.md                        # Commit, PR & finalize
│
├── skills/                             # 19 reusable skill packages
│   ├── brainstorm/SKILL.md            # Structured divergent thinking
│   ├── explore/SKILL.md               # Multi-agent codebase exploration
│   ├── generate-prd/SKILL.md          # PRD creation with research
│   ├── deepen-plan/SKILL.md           # Plan enrichment with parallel research
│   ├── review-plan/SKILL.md           # Multi-agent plan review
│   ├── create-issues/SKILL.md         # GitHub issue generation
│   ├── create-adr/SKILL.md            # Architecture Decision Records
│   ├── start-issue/SKILL.md           # Issue startup with living plan
│   ├── generate-tests/SKILL.md        # Comprehensive test generation
│   ├── run-validation/SKILL.md        # Tests + coverage + lint + security
│   ├── security-review/SKILL.md       # OWASP security methodology
│   ├── recovery/SKILL.md              # Failure recovery decision tree
│   ├── refactor/SKILL.md              # Guided refactoring
│   ├── fresh-eyes-review/             # Smart selection review system
│   │   ├── SKILL.md                   # 13-agent review methodology
│   │   └── references/trigger-patterns.md # Agent trigger patterns
│   ├── review-protocol/SKILL.md       # Protocol compliance review
│   ├── commit-and-pr/SKILL.md         # Commit and PR creation
│   ├── finalize/SKILL.md              # Final documentation + validation
│   ├── learn/SKILL.md                 # Knowledge compounding
│   └── todos/SKILL.md                 # File-based todo tracking
│
├── agents/
│   ├── review/                        # 17 review agent definitions
│   │   ├── security-reviewer.md
│   │   ├── code-quality-reviewer.md
│   │   ├── edge-case-reviewer.md
│   │   ├── supervisor.md
│   │   ├── adversarial-validator.md
│   │   ├── performance-reviewer.md
│   │   ├── api-contract-reviewer.md
│   │   ├── concurrency-reviewer.md
│   │   ├── error-handling-reviewer.md
│   │   ├── data-validation-reviewer.md
│   │   ├── dependency-reviewer.md
│   │   ├── testing-adequacy-reviewer.md
│   │   ├── config-secrets-reviewer.md
│   │   ├── documentation-reviewer.md
│   │   ├── architecture-reviewer.md
│   │   ├── simplicity-reviewer.md
│   │   └── spec-flow-reviewer.md
│   └── research/                      # 4 research agent definitions
│       ├── codebase-researcher.md
│       ├── learnings-researcher.md
│       ├── best-practices-researcher.md
│       └── framework-docs-researcher.md
│
├── checklists/
│   ├── AI_CODE_SECURITY_REVIEW.md     # Security checklist (OWASP Top 10 2025)
│   └── AI_CODE_REVIEW.md              # Code review criteria
│
├── templates/
│   ├── TEST_STRATEGY.md               # Test strategy matrix
│   ├── ADR_TEMPLATE.md                # Architecture decisions
│   ├── GITHUB_ISSUE_TEMPLATE.md       # GitHub issue structure
│   ├── BRAINSTORM_TEMPLATE.md         # Brainstorm session output
│   ├── SOLUTION_TEMPLATE.md           # Knowledge compound docs
│   ├── TODO_TEMPLATE.md               # File-based todo tracking
│   └── LIVING_PLAN_TEMPLATE.md        # Implementation tracking
│
├── guides/
│   ├── FRESH_EYES_REVIEW.md           # 13-agent smart selection review
│   ├── FAILURE_RECOVERY.md            # Recovery procedures
│   ├── CONTEXT_OPTIMIZATION.md        # Reduce token usage
│   ├── MULTI_AGENT_PATTERNS.md        # Multi-agent coordination
│   └── GITHUB_PROJECT_INTEGRATION.md  # GitHub Projects workflow
│
├── docs/
│   ├── solutions/                     # Knowledge compounding storage
│   ├── brainstorms/                   # Brainstorm session records
│   └── prds/                          # Product Requirements Documents
│
└── .todos/                            # File-based todo tracking
```

---

## How It Works

**GODMODE Protocol** (`AI_CODING_AGENT_GODMODE.md`) is optimized for LLM attention budget:
- **~350 lines** with critical safety rules FIRST (not buried in middle)
- **Mandatory STOP checkpoints** at decision points that force file reads
- **References detailed files just-in-time** (not embedded - preserves attention for current task)
- **Strong imperative language** (NEVER/ALWAYS/MUST) with repeated safety reminders

**Detailed files are REQUIRED at checkpoints** (not optional reference material):
- **Security Review**: Loaded when code touches auth/data/APIs
- **Test Strategy**: Loaded when generating tests
- **Fresh Eyes Code Review**: Loaded at Phase 1, Step 6 (multi-agent review with no conversation context)
- **ADR Template**: Loaded for architectural decisions
- **Context Optimization**: Loaded when starting complex tasks
- **Multi-Agent Patterns**: Loaded for coordinating specialized agents (includes Fresh Eyes Review pattern)
- **GitHub Project Integration**: Loaded when creating issues from PRD (Phase 0, Step 6)

**Why this structure?**
- Research shows LLMs have limited "attention budget" - every token depletes attention
- Critical info in the middle gets less attention than beginning/end
- Just-in-time loading preserves attention for current decision
- Mandatory checkpoints ensure agents don't skip safety reviews

This ensures agents pay full attention to critical safety rules while accessing detailed checklists exactly when needed.

---

## Workflow Commands

6 workflow entry points. Each workflow offers sub-step selection via `AskUserQuestion` and chains to the next workflow after completion. Individual skills are also directly invocable as slash commands.

### The 6 Workflows

| Command | Purpose | Sub-steps |
|---------|---------|-----------|
| `/explore` | Reconnaissance & ideation | Codebase exploration, brainstorming |
| `/plan` | Planning & requirements | Generate PRD, deepen plan, review plan, create issues, ADR |
| `/implement` | Implementation | Start issue, generate tests, run validation, security review, recovery |
| `/review` | Code review | Fresh eyes review (full/lite), protocol compliance |
| `/learn` | Knowledge capture | Save solved problems as reusable solution docs |
| `/ship` | Ship | Commit/PR, finalize, refactor |

### Example Workflows

**Full feature:**
```
/explore → /plan → /implement → /review → /learn → /ship
```

**Bug fix:**
```
/explore → /implement → /review → /learn → /ship
```

**Quick fix:**
```
/implement → /review → /ship
```

**Just review:**
```
/review → /ship
```

**See:** `QUICK_START.md` for full command reference and more example workflows.

---

## Quick Start

### 0. Quick Reference

**See `QUICK_START.md`** for:
- Two entry points (new feature vs existing issue)
- Common gh CLI commands
- Typical workflows
- Critical safety reminders

### 1. Review the Core Documents

**Start here:**
1. Read `QUICK_START.md` - Understand the two entry points
2. Read `AI_CODING_AGENT_GODMODE.md` - Full workflow details
3. Review `CLAUDE.md` - Communication guidelines
4. Familiarize yourself with `PRD_TEMPLATE.md` - Lite vs Full PRD

### 2. Use the Checklists

**Before merging any AI-generated code:**
- Run through `AI_CODE_SECURITY_REVIEW.md` (especially for auth, data handling, APIs)
- Use `AI_CODE_REVIEW.md` for general code quality

### 3. Start Small

**First task: Try a small feature**
1. Generate a Lite PRD
2. Implement with AI
3. Run tests (use TEST_STRATEGY.md for guidance)
4. Security review checklist
5. Deploy

**Then scale up to complex features** using the full protocol.

---

## Key Features

### 6 Workflow Commands
- Six workflow entry points: `/explore`, `/plan`, `/implement`, `/review`, `/learn`, `/ship`
- `AskUserQuestion` chaining — each workflow offers sub-step selection and next-workflow suggestions
- Human-in-loop at every phase transition — skip, reorder, or exit at any point
- All flat `godmode:` namespace (no sub-prefixes)

### 19 Reusable Skill Packages
- 19 skill packages provide methodology for each sub-step
- Skills loaded by workflow commands at execution time (just-in-time, not embedded)
- All skills also user-invocable as slash commands
- Two-layer architecture: skills (knowledge + user-facing) → agents (expert personas)

### Security-First
- OWASP Top 10 2025 coverage (including new A03: Supply Chain, A10: Exceptional Conditions)
- 45% of AI code has vulnerabilities - our checklist catches them
- Mandatory security review for auth, PII, external APIs
- Adversarial validation challenges claims with evidence, not assertions

### Knowledge Compounding
- Capture solved problems as searchable, reusable solution docs (`/learn`)
- Past learnings surfaced automatically during planning and implementation
- Multi-pass Grep search across `docs/solutions/` (tags, category, full-text)
- Knowledge grows over time — each captured solution makes future planning smarter

### 21 Specialized Agents
- **17 review agents** with smart selection (core always run, conditional triggered by diff)
- **4 research agents** for parallel codebase, learnings, best practices, and framework docs research
- Adversarial validator challenges both implementation claims AND reviewer findings
- Zero-context review (fresh eyes) eliminates confirmation bias

### Structured Planning
- Brainstorm with comparison matrices before committing to a solution
- Plan deepening with massive parallel research (10-20+ agents per plan)
- Multi-agent plan review with adversarial validation
- Spec-flow analysis for user flow completeness (error/empty/edge/permission states)

### Test-Driven
- Specific guidance: not just "write tests" but exactly what tests for each scenario
- Coverage targets: Unit >80%, Integration (critical paths), E2E (happy path + errors)
- Security, performance, regression testing built-in

### Architecture-Aware
- ADRs prevent forgotten context (70% of tech debt comes from this!)
- Document major decisions with clear rationale
- Track alternatives considered

### Context Optimized
- Reduce token usage by 30-50%
- Codebase maps and targeted file reading
- MCP integration strategies

### Dual Tracking
- File-based todos (`.todos/` directory) for solo work
- GitHub issues for team collaboration
- Both modes supported per-project

---

## Workflow at a Glance

### For Simple Features (<1 day)

```
1. Create Lite PRD (5 min)
2. Implement with AI (1-2 hours)
3. Generate tests (30 min)
4. Security review checklist (15 min)
5. Deploy (15 min)

Total: ~3 hours (vs 6-8 hours manual)
```

### For Complex Features (>1 day)

```
Phase 0: Explore & Plan
1. Explore codebase (use Explore agent)
2. Generate Full PRD
3. Human review & approval

Phase 1: Execute
1. Implement Phase 1
2. Run tests
3. Security review
4. Human feedback
5. Iterate

Repeat for each phase...

Phase 2: Finalize
1. Refactor
2. Documentation
3. Final review
4. Deploy
```

### For GitHub Projects Workflow

**Two entry points:**

**Entry Point A: New Feature (Start at Phase 0)**
```
Phase 0: Explore & Plan
1. Explore codebase
2. Generate Full PRD
3. Save PRD to docs/prds/YYYY-MM-DD-feature-name.md
4. Human review & approval
5. Create GitHub issues (/create-issues docs/prds/...)
   a. Create first issue, note issue number (e.g., #123)
   b. Rename PRD to docs/prds/123-YYYY-MM-DD-feature-name.md
   c. Update issue to reference renamed PRD
   - Each issue includes renamed PRD file reference
   - Fork A: Immediate execution (assign & start Phase 1)
   - Fork B: Backlog mode (park in "Ready" column, exit)

If Fork A: Continue to Phase 1 with first issue
If Fork B: Exit (pick up later via Entry Point B)
```

**Entry Point B: Pick Existing Issue (Start at Phase 1)**
```
Starting Point: 10 issues waiting in backlog

1. List ready issues (gh project item-list)
2. Pick an issue ("Let's work on issue #45")
3. Load issue context (description, acceptance criteria, technical requirements, PRD reference)
4. Verify dependencies and readiness
5. Assign issue + create branch (issue-45-feature-name)
6. Jump directly to Phase 1 implementation
7. Reference PRD if needed for broader context (file path in issue)
8. Commit changes to branch
9. Ask: "Create Pull Request?"
10. If yes: Create PR (auto-links to issue)
11. User reviews & merges PR on GitHub
12. Issue auto-closes on merge
13. Pick next issue from backlog
14. Repeat

Benefits:
- Skip planning for pre-planned work
- Quick context switch between issues
- All context in issue (self-contained)
- Feature branch per issue
- PR review before merge
- PRD available if broader context needed
- Visual kanban board for tracking
- Can work through backlog systematically
```

**Overall Benefits:**
- Visual kanban board for tracking
- Issues persist between sessions
- Clear acceptance criteria for each unit of work
- Can @claude tag for assignment
- Full audit trail of decisions
- Two workflows: plan-then-execute OR pick-from-backlog
```

---

## When to Use What

### Use Lite PRD when:
- Feature is <1 day of work
- Requirements are clear
- Low complexity, low risk

### Use Full PRD when:
- Feature is >1 day of work
- Significant architectural decisions
- High risk (security, performance, breaking changes)
- Multiple stakeholders

### Use ADR when:
- Major architectural decision (database, framework, cloud provider)
- Significant tradeoffs between alternatives
- Decision is hard to reverse
- Pattern will be reused across codebase

### Use Security Checklist when:
- ANY code touching auth, data handling, or external APIs
- User input processing
- File uploads
- Database queries with user input

### Use GitHub Projects workflow when:
- Multi-phase PRD with multiple work units
- Want persistent issue tracking between sessions
- Working with team (issues can be assigned to different developers/agents)
- Need visual board for stakeholder visibility
- Building backlog for future work
- Want audit trail of implementation decisions

---

## Best Practices

### 1. Start Every Task with Exploration
Don't guess. Use the Explore agent or read relevant files first.

### 2. Security is Non-Negotiable
45% of AI code has vulnerabilities. Always use the security checklist.

### 3. Test Everything
AI forgets edge cases. Use the test strategy matrix for comprehensive coverage.

### 4. Document Decisions
Use ADRs for major decisions. Your future self will thank you.

### 5. Optimize Context
Use the context optimization guide. 30-50% cost savings possible.

---

## Common Pitfalls to Avoid

❌ **Don't:** Skip security review ("it's just a small change")
✅ **Do:** Always run security checklist for auth, data, APIs

❌ **Don't:** Accept AI code without reviewing edge cases
✅ **Do:** Use AI_CODE_REVIEW.md checklist

❌ **Don't:** Paste entire directories into context
✅ **Do:** Use Grep to find specific files, read targeted sections

❌ **Don't:** Add dependencies without vetting
✅ **Do:** Vet security, licenses, bundle size

❌ **Don't:** Forget to document architectural decisions
✅ **Do:** Create ADRs for major choices

---

## Resources & References

### Industry Standards
- **OWASP Top 10 2025** - [https://owasp.org/Top10/](https://owasp.org/Top10/)
- **Model Context Protocol (MCP)** - [https://spec.modelcontextprotocol.io](https://spec.modelcontextprotocol.io)
- **Microsoft Agent Framework** - [https://learn.microsoft.com/en-us/agent-framework/](https://learn.microsoft.com/en-us/agent-framework/)

### Research
- DX Research (2024): AI coding assistants save 25-50% time
- Veracode Study: 45% of AI code has OWASP Top 10 flaws
- Microsoft Research: TypeScript reduces bugs by 45%

### Books
- "Coding With AI All the Time" - Ken Kocienda (2025)
- "Clean Code" - Robert C. Martin
- "Refactoring" - Martin Fowler

---

## Version History

**v4.2 (February 2026)** - Current
- **MAJOR**: Restructured to 6 workflow commands (`/explore`, `/plan`, `/implement`, `/review`, `/learn`, `/ship`)
- **MAJOR**: 19 reusable skill packages (`skills/`) — all skills user-invocable as slash commands
- **MAJOR**: Flat `godmode:` namespace — no sub-prefixes, clean command discovery
- Removed orchestrator workflows (godmode, bugfix, quickfix) — replaced by 6 workflow commands with natural chaining
- Renamed `/compound` to `/learn` for clarity
- Two-layer architecture: skills (knowledge + user-facing) → agents (expert personas)

**v4.1 (February 2026)**
- 3 orchestrator workflows (`/godmode`, `/bugfix`, `/quickfix`) for guided development
- 6 reusable skill packages (`skills/`) — extracted methodology into knowledge layer
- Programmatic flow chaining — every command offers next-step options via `AskUserQuestion`
- Three-layer architecture: skills (knowledge) → commands (user-facing) → agents (expert personas)
- Smart entry point detection in orchestrators (skips completed phases)

**v4.0 (February 2026)**
- **MAJOR**: 17 modular slash commands (added `/brainstorm`, `/deepen-plan`, `/review-plan`, `/compound`)
- **MAJOR**: 21 specialized agents (17 review + 4 research) with smart selection
- **MAJOR**: Knowledge compounding — capture and reuse solved problems (`docs/solutions/`)
- 13-agent smart selection Fresh Eyes Review (core always run, conditional triggered by diff content)
- Adversarial validator — falsification over confirmation, challenges claims AND findings
- Structured brainstorming with comparison matrices
- Plan deepening with massive parallel research (10-20+ agents)
- Multi-agent plan review with adversarial validation
- Spec-flow analysis for user flow completeness
- Dual tracking: file-based `.todos/` AND GitHub issues
- Living implementation plans with progress tracking
- Incremental commit guidance (`Part of #NNN` for intermediate)

**v3.2 (December 2025)**
- Added `--pipeline` flag to `/start-issue` for full automated workflow
- Enforced Fresh Eyes Review as mandatory gate in `/commit-and-pr`

**v3.1 (November 2025)**
- Optimized GODMODE protocol from 672 lines to ~438 lines
- Restructured with critical safety rules FIRST (LLM attention budget optimization)
- Added mandatory STOP checkpoints that force file reads at decision points
- Changed from embedded content to just-in-time file references
- Strengthened language (NEVER/ALWAYS/MUST) with repeated safety reminders

**v3.0 (November 2025)**
- Added OWASP Top 10 2025 security checklist
- Added AI-specific code review criteria
- Added test strategy matrix
- Added ADR template
- Added context optimization guide
- Added multi-agent workflow patterns
- Updated PRD template with test strategy and security sections

**v2.0 (Referenced in AI_CODING_AGENT_GODMODE.md)**
- Original protocol with Phase 0-2 workflow
- PRD template
- Basic status indicators

---

## Contributing

This protocol is a living document. Update it as workflows evolve.

**To update:**
1. Make changes to relevant files
2. Test in real projects
3. Document what worked/didn't work
4. Update this README if structure changes

---

**Built with research from:** Anthropic, Microsoft, Google, OWASP, DX Research, Veracode, and real-world usage.

**Status:** Production-ready

**Last Review:** February 2026
