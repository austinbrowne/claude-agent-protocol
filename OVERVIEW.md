# AI Coding Agent Protocol — Overview

**Version:** 5.14.0-experimental | **Status:** Production-ready | **Platforms:** GitHub, GitLab

---

## What This Is

A Claude Code plugin that turns AI-assisted coding from ad-hoc prompting into a structured, repeatable engineering process. 7 workflow commands, 27 skill packages, 22 specialized agents, knowledge compounding, and mandatory safety gates — covering the full lifecycle from exploration to shipping.

**The problem it solves:** Without structure, AI coding assistants produce code that contains security vulnerabilities 45% of the time (Veracode), systematically misses edge cases, skips tests, and confirms its own biases during self-review. This protocol provides specific, enforceable countermeasures for each of those failure modes.

---

## How It Works

### Architecture

The protocol is a collection of markdown files that Claude Code reads as instructions. They're organized in two layers:

```
CLAUDE.md                        Always loaded — safety rules, AI blind spots, workflow overview
AI_CODING_AGENT_GODMODE.md       Full SOP — phase-by-phase protocol (loaded on demand)

commands/          7 workflow entry points (explore, plan, implement, review, learn, ship, loop)
skills/            27 reusable skill packages — the building blocks
agents/review/     15 review agent definitions (zero-context specialists)
agents/research/   4 research agent definitions (codebase, learnings, best practices, framework docs)
agents/team/       3 team role definitions (Lead, Implementer, Analyst)

checklists/        OWASP Top 10 2025 security review, code quality criteria
guides/            Deep references loaded just-in-time at checkpoints
templates/         10 reusable templates (plans, issues, ADRs, test strategies, etc.)

docs/solutions/    Knowledge compounding — captured solved problems
docs/plans/        Plans (Minimal, Standard, Comprehensive)
.todos/            File-based todo tracking (committed to git)
```

**Key design principle:** LLMs have limited attention. Critical safety rules load first (CLAUDE.md). Detailed checklists and agent definitions load just-in-time at checkpoints — not upfront where they'd dilute attention.

### Two-Layer Command System

**Workflows** are the top-level entry points. Each one presents a menu of sub-steps and chains to the next workflow when done:

| Command | Purpose |
|---------|---------|
| `/explore` | Reconnaissance and ideation — codebase exploration + brainstorming |
| `/plan` | Planning and requirements — plan generation, deepening, review, issues, ADR |
| `/implement` | Execution — start issue, generate tests, run validation, security review |
| `/review` | Code review — Fresh Eyes review (full/lite), protocol compliance |
| `/learn` | Knowledge capture — save solved problems as reusable solution docs |
| `/ship` | Ship — commit and create PR/MR, finalize, refactor |
| `/loop` | Autonomous development — iterates plan tasks with context rotation |

**Skills** are the building blocks inside workflows. Each skill is also directly invocable as a slash command:

| Category | Skills |
|----------|--------|
| Planning | `explore`, `brainstorm`, `generate-plan`, `deepen-plan`, `review-plan`, `create-adr`, `create-issues` |
| Issues | `file-issues`, `file-issue`, `enhance-issue`, `triage-issues` |
| Execution | `start-issue`, `team-implement`, `generate-tests`, `run-validation`, `security-review`, `recovery`, `refactor` |
| Review | `fresh-eyes-review`, `review-protocol`, `document-review` |
| Shipping | `commit-and-pr`, `finalize`, `bump-version` |
| Knowledge | `learn`, `todos` |
| Config | `setup` |

### Common Workflows

**Full feature:**
```
/explore → /plan → /implement → /review → /learn → /ship
```

**Bug fix:**
```
/explore → /implement → /review → /learn → /ship
```

**Quick fix (root cause known):**
```
/implement → /review → /ship
```

**Just review existing changes:**
```
/review → /ship
```

**Autonomous:**
```
/loop add user authentication         # Plan + implement + review from description
/loop --plan docs/plans/my-plan.md    # Iterate tasks from existing plan
/loop --issue 42                      # Enhance issue, plan, implement, review
```

**Direct skill invocation (skip the workflow menu):**
```
/fresh-eyes-review          Run 15-agent code review directly
/security-review            Run OWASP Top 10 checklist directly
/brainstorm "auth approaches"   Structured divergent thinking
```

### Mandatory Gates

These checkpoints cannot be bypassed:

| Gate | What It Enforces | Why |
|------|-----------------|-----|
| **Fresh Eyes Review** | Multi-agent review where reviewers have zero conversation context | Eliminates confirmation bias — AI won't approve its own work uncritically |
| **Security Review** | OWASP Top 10 2025 checklist, auto-triggered for auth/data/API code | 45% of AI code has vulnerabilities without explicit checking |
| **Test Generation** | Happy path + null + empty + boundaries + error cases | AI systematically skips edge cases and error handling |
| **Human Approval** | Pause before merge, deploy, or finalize | AI should assist decisions, not make them autonomously |

### 22-Agent Architecture

The protocol uses specialized agents for three purposes:

**Review agents (15)** — Spawned during `/fresh-eyes-review`. Each receives zero conversation context — only the code diff and their review checklist. This eliminates confirmation bias.

- **Core (always run):** Security, Code Quality, Edge Case, Supervisor, Adversarial Validator
- **Conditional (triggered by diff content):** Performance, API Contract, Concurrency, Error Handling, Dependency, Testing Adequacy, Documentation, Architecture, Simplicity, Spec-Flow

A supervisor consolidates findings and removes false positives. An adversarial validator challenges claims and demands evidence.

**Research agents (4)** — Spawned during `/explore` and `/deepen-plan`. Each investigates a different dimension of the problem:
- Codebase Researcher — maps existing patterns and architecture
- Learnings Researcher — searches `docs/solutions/` for relevant past solutions
- Best Practices Researcher — finds industry patterns for the problem type
- Framework Docs Researcher — looks up framework-specific APIs and patterns

**Team agents (3)** — Used during `/team-implement` for complex, multi-file work:
- Team Lead — decomposes work into parallel tasks with file ownership boundaries, coordinates teammates
- Implementer — builds features within strict file ownership boundaries following the full protocol pipeline
- Analyst — explores the codebase, surfaces past learnings, and broadcasts findings to implementers

### Knowledge Compounding

The `/learn` skill captures solved problems as searchable docs in `docs/solutions/`. Past learnings are surfaced automatically during `/start-issue` and `/generate-plan`. Your knowledge base grows with every solved problem — each session is smarter than the last.

### Platform Support

The protocol auto-detects GitHub or GitLab from `git remote get-url origin`. All platform-dependent commands (issue management, PR/MR creation, project boards) use the correct CLI syntax automatically.

| Feature | GitHub | GitLab |
|---------|--------|--------|
| CLI tool | `gh` | `glab` |
| Code review unit | Pull Request (PR) | Merge Request (MR) |
| Project boards | GitHub Projects | GitLab Boards (label-driven) |
| Scoped labels | Manual convention (`type: bug`) | Native (`type::bug`) |
| Auto-close syntax | `Closes #123` | `Closes #123` |

See `guides/GITHUB_PROJECT_INTEGRATION.md` for the GitHub/GitLab project board integration guide.

---

## Benefits

### For Individual Engineers

- **Faster delivery with fewer bugs.** Quality checks are front-loaded into the workflow, not discovered in code review or production. Less rework.
- **Consistent workflow.** Every feature follows the same explore, plan, implement, test, review, ship pattern regardless of who's building it.
- **Built-in knowledge.** Security checklists, test strategies, and edge case reminders are baked into the workflow. The protocol remembers what you'd forget.
- **Knowledge compounds.** Every tricky problem you solve becomes a searchable doc that gets surfaced automatically in future sessions.
- **Reduced context switching.** Workflow commands handle the ceremony — branch creation, issue management, PR/MR formatting — so you stay focused on the problem.

### For Engineering Managers

- **Predictable quality.** Mandatory gates mean code can't ship without tests, security review, and independent code review. Quality is systemic, not dependent on individual discipline.
- **Visibility into progress.** Issues with clear acceptance criteria. Project boards show what's in progress, blocked, or done.
- **Reduced review burden.** Fresh Eyes Review catches issues before human reviewers see the code. Human reviews focus on architecture and business logic, not missing null checks.
- **Onboarding acceleration.** New engineers and AI agents follow the same documented protocol. The workflow is explicit, not tribal knowledge.
- **Audit trail.** Plans, ADRs, issues, PR/MR descriptions, and recovery reports create a complete record of what was built, why, and what alternatives were considered.

### For Engineering Leadership / Executives

- **Risk reduction.** 45% of AI-generated code contains security vulnerabilities (Veracode). This protocol catches them systematically before production. Mandatory OWASP Top 10 2025 reviews, automated security scanning, and multi-agent review create defense in depth.
- **Faster time to market.** AI-assisted development with this protocol delivers features roughly twice as fast as manual development (DX Research, 2024: 25-50% time savings), while maintaining quality standards that would otherwise slow down AI-assisted work.
- **Scalable AI adoption.** The protocol standardizes how AI is used across teams. Not "each engineer uses AI differently" — a repeatable, auditable process that works the same way every time.
- **Platform flexibility.** Works with both GitHub and GitLab. No vendor lock-in.
- **Measurable quality metrics.** Every PR/MR includes test coverage, security review status, and Fresh Eyes Review verdict. Quality is measurable, not aspirational.
- **Institutional knowledge preservation.** ADRs capture why decisions were made. Plans document requirements. Solution docs capture solved problems. Recovery reports document what failed and why. This knowledge persists beyond any individual's tenure.

### Compared to Unstructured AI Coding

| Without Protocol | With Protocol |
|-----------------|---------------|
| AI skips edge cases (null, empty, boundaries) | Explicit edge case checklist at every checkpoint |
| 45% of code has security vulnerabilities | Mandatory OWASP Top 10 2025 review |
| AI approves its own work (confirmation bias) | Fresh Eyes agents review with zero prior context |
| No tests or minimal tests | Enforced test generation covering happy path + edge cases + errors |
| Ad-hoc workflow varies by engineer | Consistent explore, plan, build, test, review, ship |
| No documentation of decisions | Plans, ADRs, solution docs, recovery reports — full audit trail |
| Solved problems are forgotten next session | Knowledge compounding — past solutions surfaced automatically |
| Errors caught in production | Errors caught at mandatory gates before merge |

---

## What's Included

| Category | Count | Contents |
|----------|-------|----------|
| Workflow commands | 7 | explore, plan, implement, review, learn, ship, loop |
| Skill packages | 27 | Planning, issue management, execution, review, shipping, knowledge, config |
| Review agents | 15 | Security, code quality, edge case, performance, API contract, concurrency, error handling, dependency, testing adequacy, documentation, architecture, simplicity, spec-flow, supervisor, adversarial validator |
| Research agents | 4 | Codebase, learnings, best practices, framework docs |
| Team agents | 3 | Lead, Implementer, Analyst |
| Checklists | 2 | OWASP Top 10 2025 security review, AI code review criteria |
| Templates | 10 | Plan (3-tier), test strategy, ADR, brainstorm, solution doc, todo, living plan, issue, bug issue, recovery report |
| Guides | 6 | Fresh Eyes Review, failure recovery, context optimization, multi-agent patterns, agent teams, GitHub/GitLab project integration |

---

## Presentation Prompt

Use the following prompt with Claude or any LLM to generate a slide deck tailored to your audience. Copy and paste it, then customize the bracketed sections.

---

```
Create a presentation slide deck for the AI Coding Agent Protocol. The audience
is [CHOOSE: engineering executives / engineering managers / individual engineers /
a mixed audience of all three].

Context about the protocol:
- It's a Claude Code plugin (v5.14.0-experimental, production-ready) for structured
  AI-assisted software development
- 7 workflow commands and 27 directly-invokable skills covering the full dev
  lifecycle: explore → plan → implement → review → learn → ship → loop
- Two-layer architecture: workflows (orchestrators) → skills (building blocks) →
  agents (expert personas)
- 22 specialized agents: 15 review agents (zero-context, eliminate confirmation
  bias) + 4 research agents (parallel codebase/learnings/best-practices/docs)
  + 3 team agents (Lead, Implementer, Analyst for parallel implementation)
- Mandatory safety gates: Fresh Eyes multi-agent review (zero-context agents),
  OWASP Top 10 2025 security review, enforced test generation, human approval
  before merge
- Knowledge compounding: solved problems captured as searchable docs via /learn,
  automatically surfaced in future planning and implementation
- Addresses core problem: 45% of AI-generated code contains security
  vulnerabilities (Veracode study), AI systematically misses edge cases
- Supports both GitHub and GitLab (auto-detected from git remote)
- Research-backed: DX Research shows 25-50% time savings with AI coding
  assistants; this protocol maintains those gains while adding quality controls
- Creates full audit trail: plans, ADRs, issues, PR/MR descriptions, solution
  docs, recovery reports

Tailor the deck to the audience:

FOR EXECUTIVES — Focus on:
- Risk reduction (security vulnerabilities in AI code, audit trail)
- Time to market (25-50% faster delivery)
- Scalable AI adoption (repeatable process, not ad-hoc)
- Measurable quality (coverage, security status, review verdicts on every PR/MR)
- Platform flexibility (GitHub + GitLab, no vendor lock-in)
- 3-5 slides, high-level, minimal technical detail

FOR MANAGERS — Focus on:
- Predictable quality (mandatory gates, consistent workflow)
- Team visibility (project boards, issue tracking, progress metrics)
- Reduced review burden (AI catches issues before human review)
- Onboarding (documented workflow, not tribal knowledge)
- Knowledge compounding (team gets smarter with every solved problem)
- Risk flags (BREAKING_CHANGE, SECURITY_SENSITIVE, PERFORMANCE_IMPACT)
- 5-8 slides, mix of process and light technical detail

FOR ENGINEERS — Focus on:
- How the 7 workflow commands and 27 skills work (with examples)
- The two-layer architecture (workflows → skills → agents)
- Fresh Eyes Review: 15 agents, smart selection, zero-context methodology
- Security checklist (OWASP Top 10 2025 specifics)
- Knowledge compounding (/learn captures, /start-issue surfaces)
- Platform support (GitHub/GitLab auto-detection)
- How to customize (add skills, modify checklists, add review agents)
- 8-12 slides, technical detail welcome

FOR MIXED AUDIENCE — Structure as:
- Slides 1-3: Why this matters (exec-friendly)
- Slides 4-6: How it works at a process level (manager-friendly)
- Slides 7-10: Technical deep dive (engineer-friendly)
- Slide 11: Adoption plan / next steps (everyone)

Additional context about our organization: [ADD YOUR SPECIFICS — e.g.,
"50-person startup using GitLab, shipping a B2B SaaS product, currently
have no formal AI coding standards"]

Output format: Markdown slides using --- as slide separators. Include speaker
notes under each slide. Keep slides scannable — bullet points, not paragraphs.
Include 1-2 data points per slide maximum.
```

---

## Quick Reference

**Install:**
```bash
/plugin marketplace add https://github.com/austinbrowne/claude-agent-protocol
/plugin install godmode
```

**Try it:**
```bash
/explore              # Explore any codebase
/plan                 # Plan a feature (generate, review, create issues)
/implement            # Start issue, write tests, run validation
/review               # 15-agent independent code review
/learn                # Capture what you just solved
/ship                 # Commit and create PR/MR
/loop                 # Autonomous plan-implement-review loop
```

**Learn more:**
- `QUICK_START.md` — Entry points and command reference
- `AI_CODING_AGENT_GODMODE.md` — Full protocol SOP
- `commands/*.md` — 7 workflow commands
- `skills/*/SKILL.md` — 27 skill packages
