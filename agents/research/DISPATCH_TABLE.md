<!-- CANONICAL SOURCE for research agent configuration -->
<!-- CONSUMERS: skills/explore/SKILL.md, skills/generate-plan/SKILL.md, skills/deepen-plan/SKILL.md -->
<!-- When updating this file, sync all consumers. Consumers inline this content. -->

# Research Agent Dispatch Table

Standard configuration for the 4-agent parallel research pattern used across explore, generate-plan, and deepen-plan skills.

---

## Launch Rules

**CRITICAL:** Launch all applicable research agents simultaneously via Task tool in a single message.

**Smart research decision (for agents 3 & 4):**
- High-risk topics (security, payments, external APIs) → always research
- Strong local context (good patterns, CLAUDE.md has guidance) → skip external
- Uncertainty or unfamiliar territory → research

## Agent Table

| # | Agent | Condition | Model | Task Tool Config |
|---|-------|-----------|-------|-----------------|
| 1 | **Codebase Research Agent** | Always runs | (built-in) | `subagent_type: "Explore"`, reads `agents/research/codebase-researcher.md` for process |
| 2 | **Learnings Research Agent** | Always runs (if `docs/solutions/` has files) | haiku | `subagent_type: "general-purpose"`, `model: "haiku"`, searches `docs/solutions/` per `agents/research/learnings-researcher.md` |
| 3 | **Best Practices Research Agent** | Conditional: unfamiliar technology, external APIs, or user explicitly asks | haiku | `subagent_type: "general-purpose"`, `model: "haiku"`, web search per `agents/research/best-practices-researcher.md` |
| 4 | **Framework Docs Research Agent** | Conditional: known framework detected in package.json/Gemfile/requirements.txt/go.mod/Cargo.toml | haiku | `subagent_type: "general-purpose"`, `model: "haiku"`, queries Context7 MCP per `agents/research/framework-docs-researcher.md` |

## Prompt Templates

**Codebase Research Agent prompt:**
```
Explore the [target] in this codebase. Identify:
1. Key files and their purposes
2. Architecture patterns used
3. Important functions/classes
4. Dependencies and relationships
5. Potential areas of concern

CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.

Provide a structured summary suitable for planning new work.
```

**Learnings Research Agent prompt:**
```
Search docs/solutions/ for past solutions relevant to [target].
Use multi-pass Grep strategy: tags → category → keywords → full-text.
Return relevant findings with applicability assessment.

CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.
```

## Thoroughness Levels

**Thoroughness level for Codebase Research Agent:**
- Simple queries (single file/class): "quick"
- Feature areas: "medium"
- Full codebase: "very thorough"

## Incorporating Findings

**Incorporate findings into:**
- Technical Approach section (use patterns found in codebase)
- Risks section (apply gotchas from past solutions)
- Test Strategy (past testing approaches for similar features)

## Deepen-Plan Variant

When used in deepen-plan, the pattern differs slightly:
- Codebase Research spawns **1 agent per plan section** needing codebase context (not 1 total)
- Learnings Research runs once for the entire plan
- The orchestrator reads each agent's definition file and inlines the content into the prompt
- Research agents still need file access (Grep, Read, Glob) — they should NOT need to read their own definition file
