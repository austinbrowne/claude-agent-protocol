---
name: setup
version: "1.0"
description: Per-project review configuration — auto-detects stack, selects review agents, writes godmode.local.md
referenced_by:
  - skills/fresh-eyes-review/SKILL.md
  - skills/review-plan/SKILL.md
---

# Project Setup Skill

Per-project review configuration that auto-detects your tech stack, selects appropriate review agents, and writes a `godmode.local.md` config file to your project root.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Configuration Mode** | After stack detection | Auto-configure (Recommended) / Customize | User loses control of review config — UNACCEPTABLE |
| **Agent Selection** | Customize path only | Pick review agents, plan agents, depth | User gets wrong agents — UNACCEPTABLE |
| **Confirm & Write** | Before writing config | Confirm / Edit / Cancel | Config written without consent — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

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
- `next.config.*`, `nuxt.config.*`, `vite.config.*` — frontend framework
- `prisma/`, `drizzle.config.*` — ORM/database layer
- `openapi.yaml`, `swagger.json` — API definitions
- `terraform/`, `*.tf` — infrastructure-as-code

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
━━━━━━━━━━━━━━━━━━━━━━

Primary stack: TypeScript (package.json + tsconfig.json)
Framework: Next.js (next.config.mjs)
Database: Prisma (prisma/ directory)
Infrastructure: Docker (Dockerfile + docker-compose.yml)
CI/CD: GitHub Actions (.github/workflows/)

Recommended preset: Web Backend + Database-Heavy
```

### Step 3: Configuration Mode — MANDATORY GATE

```
AskUserQuestion:
  question: "How would you like to configure review agents for this project?"
  header: "Review Configuration"
  options:
    - label: "Auto-configure (Recommended)"
      description: "Use recommended agents for detected stack: {preset_name}"
    - label: "Customize"
      description: "Manually select review agents, plan agents, and review depth"
```

**If "Auto-configure":** Use recommended preset agents. Skip to Step 5.

**If "Customize":** Proceed to Step 4.

### Step 4: Custom Agent Selection — MANDATORY GATE (Customize path only)

Present all available agents organized by category. Let user select.

```
AskUserQuestion:
  question: "Select review agents for code reviews (recommended defaults pre-selected):"
  header: "Review Agent Selection"
  options:
    - label: "Security Reviewer"
      description: "OWASP Top 10, injection, auth, secrets"
    - label: "Code Quality Reviewer"
      description: "Naming, structure, SOLID, complexity"
    - label: "Edge Case Reviewer"
      description: "Null/empty/boundary — biggest AI blind spot"
    - label: "Performance Reviewer"
      description: "N+1 queries, memory leaks, pagination"
    - label: "API Contract Reviewer"
      description: "Route definitions, schema validation, versioning"
    - label: "Concurrency Reviewer"
      description: "Race conditions, deadlocks, async patterns"
    - label: "Error Handling Reviewer"
      description: "Try/catch coverage, external call resilience"
    - label: "Data Validation Reviewer"
      description: "Input validation, parsing, sanitization"
    - label: "Dependency Reviewer"
      description: "Package updates, supply chain, license compliance"
    - label: "Config & Secrets Reviewer"
      description: "Env vars, hardcoded secrets, config hygiene"
    - label: "Testing Adequacy Reviewer"
      description: "Test coverage, test quality, missing tests"
    - label: "Documentation Reviewer"
      description: "Public API docs, magic numbers, code clarity"
```

After agent selection, ask for plan review agents:

```
AskUserQuestion:
  question: "Select agents for plan reviews (used during /plan workflow):"
  header: "Plan Review Agents"
  options:
    - label: "Architecture Reviewer"
      description: "System design, component boundaries, scalability"
    - label: "Simplicity Reviewer"
      description: "Over-engineering detection, YAGNI enforcement"
    - label: "Security Reviewer"
      description: "Security implications in planned architecture"
    - label: "Performance Reviewer"
      description: "Performance implications in planned approach"
```

After plan agent selection, ask for review depth:

```
AskUserQuestion:
  question: "Select review depth (affects number of conditional agents triggered):"
  header: "Review Depth"
  options:
    - label: "Fast"
      description: "Core agents only (security, code quality, edge cases) — quickest reviews"
    - label: "Thorough (Recommended)"
      description: "Core + conditionally triggered agents based on diff content"
    - label: "Comprehensive"
      description: "All selected agents run on every review — most thorough but slowest"
```

### Step 5: Confirm & Write — MANDATORY GATE

Present the final configuration for user approval before writing.

```
Review Configuration Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Review agents: security-reviewer, code-quality-reviewer, edge-case-reviewer,
               api-contract-reviewer, error-handling-reviewer
Plan review agents: architecture-reviewer, simplicity-reviewer
Review depth: thorough

Config file: godmode.local.md (project root)
```

```
AskUserQuestion:
  question: "Write this configuration to godmode.local.md?"
  header: "Confirm Configuration"
  options:
    - label: "Confirm"
      description: "Write godmode.local.md with the above configuration"
    - label: "Edit"
      description: "Go back and adjust agent selection or depth"
    - label: "Cancel"
      description: "Exit without writing config"
```

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

- **godmode.local.md is gitignored by default** — each developer can have their own review preferences
- **Stack detection is best-effort** — user can always override via Customize
- **Presets are additive** — they add agents to the default set, not replace
- **fresh-eyes-review reads this config** — the review skill checks for `godmode.local.md` to determine which agents to run
- **Supervisor and Adversarial Validator are always included** — they are post-processing agents, not configurable per-project

---

## Integration Points

- **Input**: Project root file markers (package.json, go.mod, etc.)
- **Output**: `godmode.local.md` config file in project root
- **Consumed by**: `skills/fresh-eyes-review/SKILL.md` (agent selection), `skills/review-plan/SKILL.md` (plan review agents)
- **Agent definitions**: `agents/review/*.md`
