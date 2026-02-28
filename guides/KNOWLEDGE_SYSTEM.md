# Unified Knowledge System

Two-tier knowledge architecture combining Anthropic's built-in auto memory with the structured `/learn` solution library. Each tier serves a distinct purpose; together they form a complete knowledge system that captures everything from quick preferences to deep debugging insights.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   UNIFIED KNOWLEDGE SYSTEM                  │
├──────────────────────────┬──────────────────────────────────┤
│    TIER 1: Auto Memory   │    TIER 2: Solution Library      │
│    (Quick Capture)       │    (Deep Capture)                │
├──────────────────────────┼──────────────────────────────────┤
│ Effort:    Automatic     │ Effort:    Explicit `/learn`     │
│ Format:    Freeform MD   │ Format:    YAML frontmatter +    │
│                          │            structured MD          │
│ Storage:   ~/.claude/    │ Storage:   docs/solutions/       │
│            projects/     │            {category}/           │
│            <proj>/       │                                  │
│            memory/       │                                  │
│                          │                                  │
│ Loaded:    200 lines at  │ Loaded:    On demand via         │
│            session start │            learnings-researcher  │
│                          │                                  │
│ Shared:    Per-user only │ Shared:    Git-tracked, team-    │
│                          │            wide                  │
│                          │                                  │
│ Searched:  Linear scan   │ Searched:  7-pass multi-Grep     │
│            of MEMORY.md  │            with relevance        │
│                          │            scoring               │
├──────────────────────────┴──────────────────────────────────┤
│                     BRIDGE LAYER                            │
│  • /learn writes summary reference to auto memory           │
│  • learnings-researcher searches both tiers                 │
│  • Promote: auto memory note → full structured solution     │
│  • Auto memory cross-references docs/solutions/ entries     │
└─────────────────────────────────────────────────────────────┘
```

---

## Tier 1: Auto Memory (Quick Capture)

### What It Is

Anthropic's built-in persistent memory. Claude automatically writes notes to `~/.claude/projects/<project>/memory/` as it works. Zero-friction — no explicit action required.

### What Goes Here

| Category | Examples |
|----------|----------|
| **Project patterns** | Build commands, test conventions, code style |
| **Preferences** | "Use pnpm not npm", "Prefer vitest", "Always use strict mode" |
| **Key files** | Important paths, module relationships, entry points |
| **Quick insights** | "The CI needs Node 20+", "Redis required for test suite" |
| **Solution index** | One-line references to deep solutions in Tier 2 |

### Structure

```
~/.claude/projects/<project>/memory/
├── MEMORY.md              # Index file — first 200 lines loaded at session start
├── debugging.md           # Debugging patterns and gotchas
├── architecture.md        # Key architectural decisions
├── conventions.md         # Code conventions and preferences
├── solutions-index.md     # Cross-references to docs/solutions/ entries
└── ...                    # Any other topic files
```

### How It Works

1. **MEMORY.md** (first 200 lines) loads into system prompt at every session start
2. **Topic files** are read on demand when Claude needs the information
3. Claude reads and writes memory files during sessions using standard file tools
4. Toggle on/off via `/memory` command or `settings.json`

### Best Practices

- Keep MEMORY.md under 200 lines — move details to topic files
- Use bullet points, not prose
- Group related items under markdown headings
- Reference topic files from MEMORY.md so Claude knows what exists
- Tell Claude directly: "remember that..." for explicit captures

### Configuration

```json
// Disable for all projects: ~/.claude/settings.json
{ "autoMemoryEnabled": false }

// Disable for one project: .claude/settings.json
{ "autoMemoryEnabled": false }

// Environment variable override (takes precedence):
// CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
```

---

## Tier 2: Solution Library (Deep Capture)

### What It Is

Structured knowledge base for solved problems. Invoked explicitly via `/learn`. Each solution is a git-tracked markdown file with enum-validated YAML frontmatter in `docs/solutions/`.

### What Goes Here

| Category | Examples |
|----------|----------|
| **Bug fixes** | Root cause analysis, failed attempts, working solution |
| **Debugging insights** | Non-obvious causes, tricky symptoms, misleading errors |
| **Security gotchas** | Auth bypass patterns, injection vectors found |
| **Performance fixes** | N+1 queries, missing indexes, memory leaks |
| **Integration issues** | API quirks, version incompatibilities, config traps |
| **Best practices** | Patterns that prevented recurring problems |

### Structure

```
docs/solutions/
├── build-errors/
├── test-failures/
├── runtime-errors/
├── performance-issues/
├── database-issues/
├── security-issues/
├── ui-bugs/
├── integration-issues/
├── logic-errors/
├── developer-experience/
├── workflow-issues/
├── best-practices/
└── documentation-gaps/
```

Each file: `{category}/{slug}-{YYYYMMDD}.md`

### YAML Frontmatter Schema

```yaml
# Required
module: "Authentication"              # Project area
date: 2026-02-26                      # Date solved
problem_type: security_issue          # Enum → determines subdirectory
component: auth                       # Enum → technical component
symptoms:                             # 1-5 observable symptoms
  - "JWT refresh token race condition"
root_cause: race_condition            # Enum → fundamental cause
resolution_type: code_fix             # Enum → type of fix
severity: high                        # critical|high|medium|low
tags: [jwt, refresh-token, concurrency]

# Optional
language: typescript
framework: express
framework_version: 4.18.2
issue_ref: "#145"
related_solutions: []
```

### Document Body Structure

1. **Problem** — 1-2 sentence description
2. **Environment** — Module, language/framework, component, date
3. **Symptoms** — Observable indicators
4. **What Didn't Work** — Failed attempts with explanations
5. **Solution** — Specific fix with before/after code
6. **Why This Works** — Root cause analysis
7. **Prevention** — Practices to avoid recurrence
8. **Related Issues** — Cross-references

### Enum Values

**problem_type** (13): `build_error`, `test_failure`, `runtime_error`, `performance_issue`, `database_issue`, `security_issue`, `ui_bug`, `integration_issue`, `logic_error`, `developer_experience`, `workflow_issue`, `best_practice`, `documentation_gap`

**component** (15): `model`, `controller`, `view`, `service`, `background_job`, `database`, `frontend`, `realtime`, `api_client`, `auth`, `payments`, `config`, `testing`, `tooling`, `documentation`

**root_cause** (16): `missing_association`, `missing_eager_load`, `missing_index`, `wrong_api`, `scope_error`, `race_condition`, `async_timing`, `memory_issue`, `config_error`, `logic_error`, `test_isolation`, `missing_validation`, `missing_permission`, `type_error`, `encoding_error`, `dependency_issue`

**resolution_type** (9): `code_fix`, `migration`, `config_change`, `test_fix`, `dependency_update`, `environment_setup`, `workflow_improvement`, `documentation_update`, `tooling_addition`

**severity** (4): `critical`, `high`, `medium`, `low`

### Retrieval: 7-Pass Multi-Grep

The `learnings-researcher` agent searches solutions using:

| Pass | Field | Example |
|------|-------|---------|
| 1 | Tags | `tags:.*(jwt\|token)` |
| 2 | Module | `module:.*Authentication` |
| 3 | Problem type | `problem_type: security_issue` |
| 4 | Component | `component: auth` |
| 5 | Symptoms | `symptoms:.*race condition` |
| 6 | Root cause | `root_cause: race_condition` |
| 7 | Full-text | Domain-specific body keywords |

Results are deduplicated and scored: HIGH / MEDIUM / LOW relevance.

### Auto-Discovery Points

Solutions are automatically surfaced during:
- `/explore` — Find learnings for exploration target
- `/plan` (brainstorm) — Past solutions inform approach selection
- `/plan` (deepen) — Per-section learnings lookup
- `/implement` (start-issue) — Gotchas surfaced before coding begins

---

## Bridge Layer

The bridge layer connects both tiers so knowledge flows between them.

### 1. `/learn` Writes to Both Tiers

When `/learn` captures a solution:

1. **Primary**: Write full structured doc to `docs/solutions/{category}/`
2. **Secondary**: Append a one-line reference to auto memory's `solutions-index.md`:
   ```
   - [2026-02-26] JWT refresh race condition → docs/solutions/security-issues/jwt-refresh-race-20260226.md (tags: jwt, concurrency)
   ```
3. This ensures auto memory's session-start context knows about deep solutions

### 2. Learnings Researcher Searches Both Tiers

The learnings-researcher agent expands its search to include:

1. **Primary**: `docs/solutions/` — full 7-pass multi-Grep (structured)
2. **Secondary**: `memory/*.md` topic files — keyword Grep (unstructured)

This catches insights that were captured informally in auto memory but never promoted to a full solution.

### 3. Promote: Auto Memory → Solution Library

When an auto memory note proves valuable enough to formalize:

```
User: "That debugging insight about the WebSocket reconnect — can we make that a proper solution?"
Claude: Runs /learn, pre-populates from the auto memory note, generates full structured doc
```

Promotion flow:
1. Read the relevant auto memory topic file
2. Extract problem/root-cause/solution details
3. Run normal `/learn` pipeline (dedup, validate, generate, save)
4. Optionally clean up the promoted note from auto memory

### 4. Auto Memory Cross-References Solutions

When Claude encounters a problem area where a Tier 2 solution exists, auto memory's `solutions-index.md` provides fast lookup without running the full 7-pass search.

---

## When to Use Which Tier

| Situation | Tier | Why |
|-----------|------|-----|
| "Use pnpm not npm" | Tier 1 (auto memory) | Preference, not a problem/solution |
| "Build needs Node 20" | Tier 1 (auto memory) | Quick fact, no root cause analysis needed |
| "The auth token refresh had a race condition that caused session loss" | Tier 2 (`/learn`) | Deep problem with root cause worth preserving |
| "Remember to always run migrations before tests" | Tier 1 (auto memory) | Workflow reminder |
| "The N+1 query in user dashboard was caused by missing eager load on posts association" | Tier 2 (`/learn`) | Debugging insight with solution and prevention |
| "Prefer tabs over spaces" | Tier 1 (auto memory) | Style preference |
| "The CI pipeline breaks when you use node:alpine because bcrypt needs glibc" | Tier 2 (`/learn`) | Integration gotcha others will hit |

### Decision Heuristic

Ask: **"Would someone else on the team benefit from the full story (symptoms, failed attempts, root cause, prevention)?"**

- **Yes** → Tier 2 (`/learn`)
- **No, just a quick note** → Tier 1 (auto memory)

---

## Comparison: Strengths and Tradeoffs

| Dimension | Tier 1: Auto Memory | Tier 2: Solution Library |
|-----------|-------------------|------------------------|
| **Capture effort** | Zero — automatic | Explicit — requires `/learn` |
| **Capture depth** | Shallow — bullet points | Deep — full root cause analysis |
| **Structure** | Freeform markdown | Enum-validated YAML schema |
| **Searchability at scale** | Degrades (200-line cap, linear scan) | Scales well (7-pass Grep, category dirs) |
| **Team sharing** | Per-user only | Git-tracked, team-wide |
| **Session startup cost** | 200 lines always loaded | Zero — loaded on demand |
| **Retrieval precision** | Low — relies on keyword proximity | High — structured field matching |
| **Best for** | Preferences, quick facts, workflow notes | Bug fixes, debugging insights, gotchas |
| **Risk of loss** | Not git-tracked, user-local | Git-tracked, survives machine changes |
| **Discoverability** | Only if Claude remembers to check topic files | Auto-surfaced during explore/plan/implement |

### What Auto Memory Can't Do

- Share knowledge across team members
- Survive machine migration without manual backup
- Scale past hundreds of notes with precision retrieval
- Provide structured root cause analysis for recurring problems
- Auto-surface relevant learnings during specific workflow phases

### What `/learn` Can't Do

- Capture knowledge with zero friction (requires explicit invocation)
- Store preferences and quick workflow notes efficiently
- Load context at session start (always on-demand)
- Adapt to implicit patterns Claude observes during work

### Together They Cover Everything

Auto memory handles the **continuous background signal** — preferences, patterns, quick observations. The solution library handles the **deliberate deep captures** — problems solved, root causes found, gotchas documented. The bridge ensures neither tier operates in isolation.

---

## File Reference

| File | Purpose |
|------|---------|
| `skills/learn/SKILL.md` | Learn skill definition (capture-learning) |
| `commands/learn.md` | `/learn` workflow command entry point |
| `agents/research/learnings-researcher.md` | Multi-pass Grep search agent |
| `templates/SOLUTION_TEMPLATE.md` | Solution document template |
| `docs/solutions/` | Solution library root (13 category dirs) |
| `~/.claude/projects/<project>/memory/` | Auto memory root (per-project) |
| `~/.claude/projects/<project>/memory/MEMORY.md` | Auto memory index (200 lines at startup) |

---

## Implementation Checklist

Changes needed to fully implement the bridge layer:

- [ ] **Update `/learn` skill** — After saving to `docs/solutions/`, also append a one-line reference to `memory/solutions-index.md`
- [ ] **Update learnings-researcher** — Add secondary search pass against `memory/*.md` topic files after the primary `docs/solutions/` search
- [ ] **Create solutions-index.md template** — Standardize the cross-reference format in auto memory
- [ ] **Add "promote" guidance** — Document in the learn skill how to promote auto memory notes to full solutions
- [ ] **Bootstrap auto memory** — Create `memory/MEMORY.md` with initial structure and links to topic files

---

## Anthropic Auto Memory Reference

Official documentation: [Manage Claude's memory](https://code.claude.com/docs/en/memory)

Key details:
- Enabled by default, toggle via `/memory`
- Each project gets its own memory directory derived from git root
- MEMORY.md first 200 lines loaded into system prompt
- Topic files read on demand
- Git worktrees get separate memory directories
- Disable via `settings.json` (`autoMemoryEnabled: false`) or env var (`CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`)
