# GODMODE Protocol for continue.dev

A comprehensive AI coding agent protocol ported from [Claude Code CLI](https://docs.anthropic.com/en/docs/build-with-claude/claude-code) to [continue.dev](https://continue.dev) (VS Code/JetBrains extension). Provides structured workflows, multi-persona code review, knowledge compounding, and autonomous development capabilities -- with 100% feature parity from the original.

---

## Features

- **6 workflow commands** -- `/explore`, `/plan`, `/implement`, `/review`, `/learn`, `/ship` (plus `/loop` for autonomous development)
- **27 invokable skill prompts** -- planning, implementation, review, shipping, and knowledge capture
- **22 agent persona rules** -- 15 review agents, 4 research agents, 3 team roles (Lead, Implementer, Analyst)
- **6 guides** -- cross-platform shell, fresh eyes review, failure recovery, context optimization, multi-agent patterns, agent teams
- **2 checklists** -- OWASP security review, code review
- **Cross-platform** -- bash and PowerShell command support with automatic detection
- **Platform-agnostic** -- works with GitHub (`gh`) and GitLab (`glab`) CLIs
- **Knowledge compounding** -- solved problems are saved as solution docs and searched in future sessions

---

## Installation

### 1. Copy the `.continue/` directory

**Per-project (recommended):**
```bash
# From your project root
cp -r /path/to/continue-dev-port/.continue .continue/
```

**Global (applies to all projects):**
```bash
cp -r /path/to/continue-dev-port/.continue ~/.continue/
```

### 2. Configure your model

Edit `.continue/config.yaml` and uncomment/add your model provider:

```yaml
models:
  - name: Claude
    provider: anthropic
    model: claude-sonnet-4-20250514
```

Any model supported by continue.dev works. Claude Sonnet 4 or Opus 4 is recommended for the best results with the protocol's multi-step workflows.

### 3. Verify

Open VS Code with the continue.dev extension. Type `/` in the continue.dev chat panel -- you should see the workflow commands (`implement`, `plan`, `review`, `ship`, `learn`, `loop`) in the slash command list.

---

## Directory Structure

```
.continue/
  config.yaml                          # continue.dev configuration
  prompts/
    workflows/                         # 6 workflow entry points (slash commands)
      implement.md                     #   /implement — start issues, tests, validation
      plan.md                          #   /plan — generate, deepen, review plans
      review.md                        #   /review — fresh eyes review, protocol check
      ship.md                          #   /ship — commit, PR, finalize, refactor
      learn.md                         #   /learn — capture solved problems
      loop.md                          #   /loop — autonomous development loop
    skills/                            # 27 invokable skill prompts
      explore.md                       #   Codebase exploration
      brainstorm.md                    #   Structured ideation
      generate-plan.md                 #   Plan creation (Minimal/Standard/Comprehensive)
      deepen-plan.md                   #   Plan enrichment with research
      review-plan.md                   #   Multi-perspective plan review
      create-adr.md                    #   Architecture Decision Records
      create-issues.md                 #   Issue generation from plans
      file-issues.md                   #   Rapid-fire issue filing
      file-issue.md                    #   Single issue filing
      enhance-issue.md                 #   Issue refinement
      start-issue.md                   #   Full issue implementation lifecycle
      team-implement.md                #   Sequential plan implementation
      triage-issues.md                 #   Batch issue triage
      generate-tests.md                #   Test suite generation
      run-validation.md                #   Tests + coverage + lint + security
      security-review.md               #   OWASP security checklist
      recovery.md                      #   Failed implementation recovery
      refactor.md                      #   Guided refactoring
      fresh-eyes-review.md             #   Multi-persona code review
      review-protocol.md               #   Protocol compliance check
      document-review.md               #   Document quality review
      commit-and-pr.md                 #   Commit and create PR
      finalize.md                      #   Final docs and validation
      bump-version.md                  #   Version bump
      learn.md                         #   Knowledge capture
      setup.md                         #   Per-project review config
      todos.md                         #   File-based todo tracking
    templates/                         # Reusable templates (plans, issues, ADRs, etc.)
  rules/
    00-core-protocol.md                # Safety rules, communication style (always active)
    01-ai-blind-spots.md               # Edge cases, security pitfalls (always active)
    02-workflow-reference.md            # Workflow command reference (always active)
    03-project-conventions.md           # Directory structure, status codes (always active)
    04-godmode-protocol.md             # Full protocol SOP (load on demand)
    guides/
      cross-platform-shell.md          # Bash/PowerShell command translation
      fresh-eyes-review.md             # Smart selection review process
      failure-recovery.md              # Recovery procedures
      context-optimization.md          # Token budget management
      multi-agent-patterns.md          # Sequential agent coordination
      agent-teams.md                   # Team formation patterns
    agents/
      review/                          # 15 review agent personas
        security-reviewer.md
        code-quality-reviewer.md
        architecture-reviewer.md
        performance-reviewer.md
        edge-case-reviewer.md
        error-handling-reviewer.md
        testing-adequacy-reviewer.md
        api-contract-reviewer.md
        concurrency-reviewer.md
        dependency-reviewer.md
        documentation-reviewer.md
        simplicity-reviewer.md
        spec-flow-reviewer.md
        adversarial-validator.md
        supervisor.md
      research/                        # 4 research agent personas
        codebase-researcher.md
        framework-docs-researcher.md
        best-practices-researcher.md
        learnings-researcher.md
      team/                            # 3 team role definitions
        lead.md
        implementer.md
        analyst.md
    checklists/
      security-review.md               # OWASP Top 10 checklist
      code-review.md                   # Code review checklist
    solutions/                         # Knowledge compounding storage (populated over time)
```

---

## Usage

### Workflow Commands

Type `/` in the continue.dev chat panel to see available commands. Workflows present numbered option menus and wait for your selection before proceeding.

| Command | What it does |
|---------|-------------|
| `/implement` | Start issues, sequential plan implementation, triage, tests, validation, security review |
| `/plan` | Generate plans, deepen with research, review from multiple perspectives, create issues |
| `/review` | Fresh eyes multi-persona code review, protocol compliance check |
| `/ship` | Commit changes, create PRs, finalize, refactor |
| `/learn` | Capture solved problems as searchable solution docs |
| `/loop` | Autonomous development -- iterates plan tasks with review cycles |

### Common Workflow Recipes

**Full feature:**
```
/plan -> /implement -> /review -> /learn -> /ship
```

**Bug fix:**
/explore skill -> `/implement` -> `/review` -> `/learn` -> `/ship`

**Quick fix:**
`/implement` -> `/review` -> `/ship`

**Just review:**
`/review` -> `/ship`

**Autonomous:**
```
/loop add user authentication         # Feature mode — plan + implement + review
/loop --plan docs/plans/my-plan.md    # Plan mode — iterate existing plan tasks
/loop --issue 42                      # Issue mode — enhance if needed, plan, implement
```

### Invoking Skills Directly

Skills are also available as slash commands. Type `/` and select the skill name:

```
/start-issue 42          # Implement issue #42
/fresh-eyes-review       # Run multi-persona code review
/generate-tests          # Generate test suites for changed code
/security-review         # Run OWASP security checklist
/explore                 # Codebase exploration
/brainstorm              # Structured ideation session
```

### How Rules Auto-Load

Rules in `.continue/rules/` with `alwaysApply: true` in their frontmatter are loaded into every conversation automatically. These include the core protocol, AI blind spots, workflow reference, and project conventions. Other rules (like the full GODMODE protocol reference) are loaded on demand when their context is relevant.

---

## Differences from the Claude Code Version

This port maintains 100% feature parity in capabilities, but adapts to continue.dev's architecture in several ways:

| Aspect | Claude Code CLI | continue.dev Port |
|--------|----------------|-------------------|
| **Agent execution** | Parallel subagents via `Task` tool | Sequential agent simulation (one persona at a time) |
| **Interaction gates** | `AskUserQuestion` tool with defined options | Numbered option menus in chat (user types a number) |
| **Slash commands** | `Skill()` tool invocation | Native continue.dev slash commands via `prompts/` |
| **Context rotation** | `/loop` spawns subagents with fresh context per task | Single context window; no rotation (watch for context growth on large plans) |
| **Rules loading** | `CLAUDE.md` + `@file` imports | `config.yaml` rules array + frontmatter `alwaysApply` flag |
| **Tool references** | Claude Code-specific (`Grep`, `Glob`, `Read`, `Edit`) | Platform-agnostic (continue.dev provides its own tool layer) |
| **Shell commands** | Assumes bash | Detects shell; supports both bash and PowerShell |
| **Issue tracker** | Assumes GitHub (`gh`) | Supports GitHub (`gh`) and GitLab (`glab`) |

### Key Adaptation Notes

- **No subagent context rotation:** The Claude Code version's `/loop` command rotates fresh context windows per task to prevent context overflow. The continue.dev version runs in a single conversation. For large plans, consider breaking them into smaller batches or starting a new chat between major tasks.

- **Sequential agent simulation:** Review and research "agents" are not separate processes. They are persona prompts that the model adopts sequentially within the same conversation, producing the same analysis but without parallelism.

- **Numbered options replace tool-based gates:** Where Claude Code uses `AskUserQuestion` as a blocking tool call, the port presents numbered options in chat text. The protocol instructs the model to WAIT for user response before continuing.

---

## Requirements

| Requirement | Purpose |
|-------------|---------|
| **[continue.dev](https://continue.dev)** VS Code or JetBrains extension | Runtime environment |
| **A supported LLM provider** | Claude (Anthropic), GPT (OpenAI), or any continue.dev-compatible model |
| **git** | Version control, branching, diffing |
| **`gh` CLI** (GitHub) or **`glab` CLI** (GitLab) | Issue tracking, PR/MR creation, project board management |

### Optional

| Requirement | Purpose |
|-------------|---------|
| Project-specific test runner (npm, pytest, cargo, etc.) | Validation workflows |
| Linter/formatter for your language | Code quality checks |

---

## Project Layout for Knowledge Compounding

The protocol creates and reads from these directories in your project root:

```
docs/
  plans/           # Generated plans (Minimal/Standard/Comprehensive)
  brainstorms/     # Brainstorm session records
  solutions/       # Captured learnings — searched by future sessions
  adr/             # Architecture Decision Records
.todos/            # File-based progress tracking
```

These directories are created as needed. Solution docs accumulate over time and are automatically searched during `/implement` and `/explore` workflows, building institutional knowledge that persists across sessions.

---

## Version

- **Protocol version:** 1.0.0 (continue.dev port)
- **Based on:** GODMODE Protocol v5.14.0-experimental (Claude Code)
- **Last updated:** February 2026
