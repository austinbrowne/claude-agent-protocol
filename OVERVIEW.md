# AI Coding Agent Protocol — Full Overview

**Version:** 3.2 | **Status:** Production-ready | **Platforms:** GitHub, GitLab

---

## What This Is

The AI Coding Agent Protocol is a structured framework that turns Claude Code from a general-purpose AI assistant into a disciplined software engineering partner. It provides 13 slash commands, mandatory safety checkpoints, and multi-agent review processes that enforce quality standards throughout the entire development lifecycle.

Without this protocol, AI coding assistants produce code that:
- Contains security vulnerabilities 45% of the time (Veracode study)
- Systematically misses edge cases (null, empty, boundary values)
- Skips tests, error handling, and input validation
- Confirms its own biases during self-review

The protocol fixes each of these failure modes with specific, enforceable countermeasures.

---

## How It Works

### The Core Idea

The protocol is a collection of markdown files that Claude Code reads as instructions. These files define:
1. **What commands are available** (13 slash commands like `/explore`, `/start-issue`, `/commit-and-pr`)
2. **What safety rules to follow** (security review, mandatory testing, edge case checks)
3. **What workflow to execute** (explore → plan → implement → test → review → ship)
4. **When to stop and check** (mandatory gates that cannot be bypassed)

### Architecture

```
CLAUDE.md                    Always loaded — safety rules, AI blind spots, workflow overview
AI_CODING_AGENT_GODMODE.md   Full SOP — phase-by-phase protocol (loaded on demand)
commands/*.md                13 slash commands — the user-facing interface
platforms/*.md               Platform detection + CLI references (GitHub/GitLab)
checklists/*.md              Security review (OWASP 2025), code quality criteria
guides/*.md                  Deep references loaded just-in-time at checkpoints
templates/*.md               PRD, ADR, test strategy, issue templates
```

**Key design principle:** LLMs have limited attention. Critical safety rules go first. Detailed checklists load just-in-time at checkpoints — not upfront where they'd dilute attention.

### The Two Entry Points

**Entry Point A — New Feature (Full Lifecycle)**
```
/explore          Understand the existing codebase
/generate-prd     Define requirements (Lite or Full PRD)
/create-adr       Document architectural decisions (optional)
/create-issues    Break PRD into trackable issues
/start-issue      Begin implementation on a feature branch
[write code]      Implement against acceptance criteria
/generate-tests   Write tests (happy path + edge cases + errors)
/security-review  Run OWASP Top 10 2025 checklist
/run-validation   Tests + coverage + lint + security scan
/fresh-eyes-review  Multi-agent review with zero prior context
/commit-and-pr    Commit and create PR/MR
/refactor         Polish code quality (optional)
/finalize         Update docs and close out (optional)
```

**Entry Point B — Existing Issue (Jump to Implementation)**
```
/start-issue 123  Load issue context, create branch, begin work
[write code]      Implement
/generate-tests   Test
/fresh-eyes-review  Review
/commit-and-pr    Ship
```

### Mandatory Gates

These checkpoints cannot be skipped:

| Gate | What It Enforces | Why |
|------|-----------------|-----|
| **Fresh Eyes Review** | Multi-agent review where reviewers have zero conversation context | Eliminates confirmation bias — AI won't approve its own work uncritically |
| **Security Review** | OWASP Top 10 2025 checklist, auto-triggered for auth/data/API code | 45% of AI code has vulnerabilities without explicit checking |
| **Test Generation** | Happy path + null + empty + boundaries + error cases, >80% coverage | AI systematically skips edge cases and error handling |
| **Human Approval** | Pause before merge, deploy, or finalize | AI should assist decisions, not make them autonomously |

### Multi-Agent Architecture

The `/fresh-eyes-review` command is the protocol's most important safety mechanism. It spawns **parallel specialist agents** that review code with **zero conversation history**:

- **Security Agent** — Checks for vulnerabilities, injection, auth gaps
- **Code Quality Agent** — Checks for edge cases, error handling, maintainability
- **Performance Agent** — Checks for N+1 queries, missing indexes, memory leaks

A supervisor agent consolidates findings. Because these agents have no prior context, they can't be influenced by the main conversation's assumptions or biases.

### Platform Support

The protocol auto-detects whether you're on GitHub or GitLab by checking `git remote get-url origin`. All platform-dependent commands (issue management, PR/MR creation, project boards) use the correct CLI automatically:

| Feature | GitHub | GitLab |
|---------|--------|--------|
| CLI tool | `gh` | `glab` |
| Code review | Pull Request | Merge Request |
| Project boards | GitHub Projects | GitLab Boards (label-driven) |
| Auto-close syntax | `Closes #123` | `Closes #123` |

---

## Benefits

### For Individual Engineers

- **Faster delivery with fewer bugs.** The protocol front-loads quality checks that would otherwise surface in code review or production. Engineers spend less time on rework.
- **Consistent workflow.** Every feature follows the same explore → plan → implement → test → review → ship pattern, regardless of who's building it.
- **Built-in knowledge.** Security checklists, test strategies, and edge case reminders are baked into the workflow. Engineers don't need to remember everything — the protocol remembers for them.
- **Reduced context switching.** Slash commands handle the ceremony (branch creation, issue management, PR formatting) so engineers stay focused on the problem.

### For Engineering Managers

- **Predictable quality.** Mandatory gates mean code can't ship without tests, security review, and independent code review. Quality is systemic, not dependent on individual discipline.
- **Visibility into progress.** Issues created from PRDs with clear acceptance criteria. Kanban boards show what's in progress, what's blocked, what's done.
- **Reduced review burden.** Fresh Eyes Review catches issues before human reviewers see the code. Human reviews focus on architecture and business logic, not missing null checks.
- **Onboarding acceleration.** New engineers (and AI agents) follow the same protocol. The workflow is documented, not tribal knowledge.
- **Audit trail.** PRDs, ADRs, issues, and PR descriptions create a complete record of what was built, why, and what alternatives were considered.

### For Engineering Leadership / Executives

- **Risk reduction.** 45% of AI-generated code contains security vulnerabilities (Veracode). This protocol systematically catches them before they reach production. Mandatory OWASP Top 10 2025 reviews, automated security scanning, and multi-agent review create defense in depth.
- **Faster time to market.** AI-assisted development with this protocol delivers features in roughly half the time of manual development (DX Research, 2024: 25-50% time savings), while maintaining quality standards that would otherwise slow down AI-assisted work.
- **Scalable AI adoption.** The protocol standardizes how AI is used across teams. It's not "each engineer uses AI differently" — it's a repeatable, auditable process that works the same way every time.
- **Platform flexibility.** Works with both GitHub and GitLab. No vendor lock-in on the development platform.
- **Measurable quality metrics.** Every PR includes test coverage, security review status, and Fresh Eyes Review verdict. Quality is measurable, not aspirational.
- **Institutional knowledge preservation.** ADRs capture why decisions were made. PRDs document requirements. Recovery reports document what failed and why. This knowledge persists beyond any individual's tenure.

### Compared to Unstructured AI Coding

| Without Protocol | With Protocol |
|-----------------|---------------|
| AI skips edge cases (null, empty, boundaries) | Explicit edge case checklist at every checkpoint |
| 45% of code has security vulnerabilities | Mandatory OWASP Top 10 2025 review |
| AI approves its own work (confirmation bias) | Fresh Eyes agents review with zero prior context |
| No tests or minimal tests | >80% coverage target, specific test strategy per scenario |
| Ad-hoc workflow varies by engineer | Consistent explore → plan → build → test → review → ship |
| No documentation of decisions | ADRs, PRDs, recovery reports create full audit trail |
| Errors caught in production | Errors caught at mandatory gates before merge |

---

## What's in the Box

### 13 Slash Commands

| Phase | Command | What It Does |
|-------|---------|-------------|
| Planning | `/explore` | Maps codebase architecture, identifies patterns |
| Planning | `/generate-prd` | Creates requirements doc (Lite: 1 page, Full: 5+ pages) |
| Planning | `/create-adr` | Documents architectural decisions with rationale |
| Planning | `/create-issues` | Breaks PRD into trackable issues with acceptance criteria |
| Execution | `/start-issue` | Loads issue context, creates branch, assigns to you |
| Execution | `/generate-tests` | Writes tests: happy path + edge cases + error cases |
| Execution | `/security-review` | Runs OWASP Top 10 2025 checklist |
| Execution | `/run-validation` | Runs tests + coverage + lint + security scan |
| Execution | `/fresh-eyes-review` | Multi-agent review with zero conversation context |
| Execution | `/recovery` | Decision tree for failed implementations (continue/rollback/abandon) |
| Execution | `/commit-and-pr` | Commits with conventional format, creates PR/MR |
| Finalization | `/refactor` | Guided refactoring pass |
| Finalization | `/finalize` | Updates docs, runs final validation |

### Safety Checklists

- **OWASP Top 10 2025 Security Review** — Injection, broken access control, cryptographic failures, supply chain, SSRF, and more
- **AI Code Review Criteria** — Edge cases, error handling, hallucinated APIs, performance anti-patterns

### Templates

- **PRD Template** — Lite (quick features) and Full (complex features) variants
- **Test Strategy** — What tests to write for every scenario type
- **ADR Template** — Architecture Decision Records
- **Issue Template** — Structured issues with acceptance criteria

### Guides

- **Fresh Eyes Review** — How the multi-agent unbiased review works
- **Failure Recovery** — Decision tree: continue vs rollback vs abandon
- **Context Optimization** — Reduce token usage by 30-50%
- **Multi-Agent Patterns** — Coordinate specialized agents
- **GitHub/GitLab Project Integration** — Full platform workflow guides

---

## Presentation Prompt

Use the following prompt with Claude or any LLM to generate a slide deck tailored to your audience. Copy and paste it, then customize the bracketed sections.

---

```
Create a presentation slide deck for the AI Coding Agent Protocol. The audience
is [CHOOSE ONE OR COMBINE: engineering executives / engineering managers /
individual engineers / a mixed audience of all three].

Context about the protocol:
- It's a structured framework (v3.2, production-ready) for AI-assisted software
  development using Claude Code
- Provides 13 slash commands covering the full dev lifecycle: explore → plan →
  implement → test → review → ship
- Key innovation: mandatory safety gates that can't be bypassed — security review
  (OWASP Top 10 2025), Fresh Eyes multi-agent review (zero-context agents that
  eliminate confirmation bias), and enforced test coverage (>80% target)
- Addresses the core problem: 45% of AI-generated code contains security
  vulnerabilities (Veracode study), and AI systematically misses edge cases
- Multi-agent architecture: Fresh Eyes Review spawns parallel specialist agents
  (Security, Code Quality, Performance) with zero conversation history to
  provide unbiased review
- Supports both GitHub and GitLab (auto-detected from git remote)
- Research-backed: DX Research shows 25-50% time savings with AI coding
  assistants; this protocol maintains those gains while adding quality controls
- Two entry points: new feature (full lifecycle) or existing issue (jump to
  implementation)
- Creates full audit trail: PRDs, ADRs, issues, PR descriptions, recovery
  reports

Tailor the deck to the audience:

FOR EXECUTIVES — Focus on:
- Risk reduction (security vulnerabilities in AI code, audit trail)
- Time to market (25-50% faster delivery)
- Scalable AI adoption (repeatable process, not ad-hoc)
- Measurable quality (coverage, security status, review verdicts on every PR)
- Platform flexibility (no vendor lock-in)
- 3-5 slides, high-level, minimal technical detail

FOR MANAGERS — Focus on:
- Predictable quality (mandatory gates, consistent workflow)
- Team visibility (kanban boards, issue tracking, progress metrics)
- Reduced review burden (AI catches issues before human review)
- Onboarding (documented workflow, not tribal knowledge)
- Risk flags (BREAKING_CHANGE, SECURITY_SENSITIVE, PERFORMANCE_IMPACT)
- 5-8 slides, mix of process and light technical detail

FOR ENGINEERS — Focus on:
- How the commands work (with examples)
- The workflow (explore → plan → build → test → review → ship)
- Fresh Eyes Review architecture (why zero-context matters)
- Security checklist (OWASP Top 10 2025 specifics)
- Platform support (GitHub/GitLab auto-detection)
- How to customize (add commands, modify checklists)
- 8-12 slides, technical detail welcome

FOR MIXED AUDIENCE — Structure as:
- Slides 1-3: Why this matters (exec-friendly)
- Slides 4-6: How it works at a process level (manager-friendly)
- Slides 7-10: Technical deep dive (engineer-friendly)
- Slide 11: Adoption plan / next steps (everyone)

Additional context about our organization: [ADD YOUR SPECIFICS HERE — e.g.,
"We're a 50-person startup using GitLab, shipping a B2B SaaS product, currently
have no formal AI coding standards"]

Output format: Markdown slides using --- as slide separators. Include speaker
notes under each slide. Keep slides scannable — use bullet points, not
paragraphs. Include 1-2 data points per slide maximum.
```

---

## Quick Reference

**Install:**
```bash
git clone https://github.com/austinbrowne/claude-agent-protocol.git
# Copy files to ~/.claude/ (commands, checklists, guides, templates, platforms)
```

**Try it:**
```bash
/explore              # Explore any codebase
/generate-prd         # Plan a feature
/start-issue 123      # Begin work on an issue
/fresh-eyes-review    # Independent multi-agent code review
/commit-and-pr        # Ship it
```

**Learn more:**
- `QUICK_START.md` — Entry points and command reference
- `AI_CODING_AGENT_GODMODE.md` — Full protocol SOP
- `commands/*.md` — Individual command documentation
