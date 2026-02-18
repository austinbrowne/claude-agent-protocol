---
name: setup
description: "Per-project review configuration -- auto-detects stack, selects review agents, writes config file"
---

# Project Setup Skill

Per-project review configuration that auto-detects your tech stack, selects appropriate review agents, and writes a `godmode.local.md` config file to your project root.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory interaction gates. You MUST pause at each gate and WAIT for user input. NEVER skip them. NEVER proceed without user response.**

| Gate | Location | Options | What Happens If Skipped |
|------|----------|---------|------------------------|
| **Configuration Mode** | After stack detection | Auto-configure / Customize | User loses control of review config -- UNACCEPTABLE |
| **Agent Selection** | Customize path only | Pick review agents, plan agents, depth | User gets wrong agents -- UNACCEPTABLE |
| **Confirm & Write** | Before writing config | Confirm / Edit / Cancel | Config written without consent -- UNACCEPTABLE |

---

## When to Apply

- First time using the protocol on a project (no `godmode.local.md` exists)
- Changing review agent selection for a project
- Switching review depth (fast/thorough/comprehensive)
- After major tech stack changes (new language, framework migration)

## When to Skip

- `godmode.local.md` already exists and user hasn't asked to reconfigure
- Running a one-off review where project-level config is unnecessary

---

## Stack Detection

Auto-detect the project's tech stack by checking for file markers in the project root:

| File Marker | Detected Stack |
|-------------|---------------|
| `package.json` | JavaScript / TypeScript |
| `tsconfig.json` | TypeScript (confirms TS over JS) |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python |
| `Gemfile`, `Rakefile` | Ruby |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle` | Java |
| `*.csproj`, `*.sln` | C# / .NET |
| `mix.exs` | Elixir |
| `Package.swift` | Swift |
| `Dockerfile`, `docker-compose.yml` | Docker (supplementary) |
| `.github/workflows/` | CI/CD (supplementary) |

**Secondary detection** (refine recommendations):
- `next.config.*`, `nuxt.config.*`, `vite.config.*` -- frontend framework
- `prisma/`, `drizzle.config.*` -- ORM/database layer
- `openapi.yaml`, `swagger.json` -- API definitions
- `terraform/`, `*.tf` -- infrastructure-as-code

---

## Recommended Agent Presets

Based on detected stack, recommend these review agent sets:

### Default (all projects)

**Review agents:** `security-reviewer`, `code-quality-reviewer`, `edge-case-reviewer`
**Plan review agents:** `architecture-reviewer`, `simplicity-reviewer`
**Review depth:** `thorough`

### Web Backend (JS/TS/Python/Ruby/Go/Rust/Java/C#/Elixir with API patterns)

Add: `api-contract-reviewer`, `error-handling-reviewer`

### Frontend (React/Vue/Angular/Svelte detected)

Add: `testing-adequacy-reviewer`, `performance-reviewer`

### Database-Heavy (ORM/migration files detected)

Add: `performance-reviewer`

### Concurrency-Heavy (Go/Rust/Elixir or async patterns)

Add: `concurrency-reviewer`

### Infrastructure/DevOps (Docker/Terraform/CI detected)

Add: `dependency-reviewer`

---

## Process

### Step 1: Check for Existing Config

Check if `godmode.local.md` already exists in the project root.

- **If exists:** Read it, present current config, ask if user wants to reconfigure or cancel.
- **If not exists:** Proceed to Step 2.

### Step 2: Auto-Detect Stack

Scan project root for file markers listed in the Stack Detection table.

Present findings:

```
Project Stack Detection
----------------------

Primary stack: TypeScript (package.json + tsconfig.json)
Framework: Next.js (next.config.mjs)
Database: Prisma (prisma/ directory)
Infrastructure: Docker (Dockerfile + docker-compose.yml)
CI/CD: GitHub Actions (.github/workflows/)

Recommended preset: Web Backend + Database-Heavy
```

### Step 3: Configuration Mode -- MANDATORY GATE

Present options:

1. **Auto-configure (Recommended)** -- Use recommended agents for detected stack: {preset_name}
2. **Customize** -- Manually select review agents, plan agents, and review depth

**WAIT** for user response before continuing.

**If "Auto-configure":** Use recommended preset agents. Skip to Step 5.

**If "Customize":** Proceed to Step 4.

### Step 4: Custom Agent Selection -- MANDATORY GATE (Customize path only)

Present all available agents organized by category. Let user select.

**Review Agent Selection** -- Select review agents for code reviews (recommended defaults pre-selected):

1. **Security Reviewer** -- OWASP Top 10, injection, auth, secrets
2. **Code Quality Reviewer** -- Naming, structure, SOLID, complexity
3. **Edge Case Reviewer** -- Null/empty/boundary -- biggest AI blind spot
4. **Performance Reviewer** -- N+1 queries, memory leaks, pagination
5. **API Contract Reviewer** -- Route definitions, schema validation, versioning
6. **Concurrency Reviewer** -- Race conditions, deadlocks, async patterns
7. **Error Handling Reviewer** -- Try/catch coverage, external call resilience
8. **Data Validation Reviewer** -- Input validation, parsing, sanitization
9. **Dependency Reviewer** -- Package updates, supply chain, license compliance
10. **Config & Secrets Reviewer** -- Env vars, hardcoded secrets, config hygiene
11. **Testing Adequacy Reviewer** -- Test coverage, test quality, missing tests
12. **Documentation Reviewer** -- Public API docs, magic numbers, code clarity

**WAIT** for user response before continuing.

After agent selection, present plan review agents:

**Plan Review Agents** -- Select agents for plan reviews (used during /plan workflow):

1. **Architecture Reviewer** -- System design, component boundaries, scalability
2. **Simplicity Reviewer** -- Over-engineering detection, YAGNI enforcement
3. **Security Reviewer** -- Security implications in planned architecture
4. **Performance Reviewer** -- Performance implications in planned approach

**WAIT** for user response before continuing.

After plan agent selection, present review depth options:

**Review Depth** -- Select review depth (affects number of conditional agents triggered):

1. **Fast** -- Core agents only (security, code quality, edge cases) -- quickest reviews
2. **Thorough (Recommended)** -- Core + conditionally triggered agents based on diff content
3. **Comprehensive** -- All selected agents run on every review -- most thorough but slowest

**WAIT** for user response before continuing.

### Step 5: Confirm & Write -- MANDATORY GATE

Present the final configuration for user approval before writing.

```
Review Configuration Summary
----------------------------

Review agents: security-reviewer, code-quality-reviewer, edge-case-reviewer,
               api-contract-reviewer, error-handling-reviewer
Plan review agents: architecture-reviewer, simplicity-reviewer
Review depth: thorough

Config file: godmode.local.md (project root)
```

Present options:

1. **Confirm** -- Write godmode.local.md with the above configuration
2. **Edit** -- Go back and adjust agent selection or depth
3. **Cancel** -- Exit without writing config

**WAIT** for user response before continuing.

**If "Confirm":** Proceed to Step 6.
**If "Edit":** Return to Step 4 directly (with current agents pre-selected), regardless of whether the user initially chose auto-configure or customize. The user wants to edit the result, not re-decide the mode.
**If "Cancel":** Exit skill, no file written.

### Step 6: Write Config File

**Gitignore check:** Before writing, check if `godmode.local.md` is in the project's `.gitignore`. If not, add it. This file contains project-specific review context that should not be committed to shared repositories.

Write `godmode.local.md` to the project root with YAML frontmatter:

```markdown
---
review_agents: [security-reviewer, code-quality-reviewer, edge-case-reviewer, api-contract-reviewer, error-handling-reviewer]
plan_review_agents: [architecture-reviewer, simplicity-reviewer]
review_depth: thorough  # fast | thorough | comprehensive
---

## Project Review Context

Detected stack: TypeScript, Next.js, Prisma, Docker
Configuration date: YYYY-MM-DD

Add any additional context for review agents below this line.
Review agents will receive this context alongside their zero-context diff review.
```

After writing, confirm:

```
Setup complete.

Written: godmode.local.md
Review agents: 6 selected
Plan review agents: 2 selected
Review depth: thorough

The fresh-eyes-review skill will now use this configuration
to select agents for code reviews in this project.

To reconfigure later, run /setup again.
```

Note: Adjust commands for PowerShell on Windows (e.g., `cat` -> `Get-Content`, `grep` -> `Select-String`).

---

## Available Review Agents Reference

All agents are defined in `agents/review/`:

| Agent | File | Focus |
|-------|------|-------|
| Security Reviewer | `agents/review/security-reviewer.md` | OWASP Top 10, injection, auth, secrets |
| Code Quality Reviewer | `agents/review/code-quality-reviewer.md` | Naming, structure, SOLID, complexity |
| Edge Case Reviewer | `agents/review/edge-case-reviewer.md` | Null/empty/boundary values |
| Performance Reviewer | `agents/review/performance-reviewer.md` | N+1 queries, memory, pagination |
| API Contract Reviewer | `agents/review/api-contract-reviewer.md` | Routes, schemas, versioning |
| Concurrency Reviewer | `agents/review/concurrency-reviewer.md` | Race conditions, deadlocks, async |
| Error Handling Reviewer | `agents/review/error-handling-reviewer.md` | Try/catch, external call resilience |
| Dependency Reviewer | `agents/review/dependency-reviewer.md` | Package updates, supply chain |
| Testing Adequacy Reviewer | `agents/review/testing-adequacy-reviewer.md` | Coverage, test quality |
| Documentation Reviewer | `agents/review/documentation-reviewer.md` | API docs, code clarity |
| Architecture Reviewer | `agents/review/architecture-reviewer.md` | System design, boundaries |
| Simplicity Reviewer | `agents/review/simplicity-reviewer.md` | Over-engineering, YAGNI |
| Supervisor | `agents/review/supervisor.md` | Consolidation, deduplication |
| Adversarial Validator | `agents/review/adversarial-validator.md` | Falsification, evidence demands |
| Spec Flow Reviewer | `agents/review/spec-flow-reviewer.md` | Specification compliance |

---

## Notes

- **godmode.local.md is gitignored by default** -- each developer can have their own review preferences
- **Stack detection is best-effort** -- user can always override via Customize
- **Presets are additive** -- they add agents to the default set, not replace
- **fresh-eyes-review reads this config** -- the review skill checks for `godmode.local.md` to determine which agents to run
- **Supervisor and Adversarial Validator are always included** -- they are post-processing agents, not configurable per-project

---

## Integration Points

- **Input**: Project root file markers (package.json, go.mod, etc.)
- **Output**: `godmode.local.md` config file in project root
- **Consumed by**: `fresh-eyes-review` skill (agent selection), `review-plan` skill (plan review agents)
- **Agent definitions**: `agents/review/*.md`
