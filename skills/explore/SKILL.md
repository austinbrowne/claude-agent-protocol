---
name: explore
version: "1.0"
description: Multi-agent codebase exploration and context gathering methodology
referenced_by:
  - commands/explore.md
---

# Codebase Exploration Skill

Multi-agent exploration methodology for gathering comprehensive codebase context.

---

## When to Apply

- Starting new feature and need to understand existing architecture
- Investigating specific area of codebase (e.g., "authentication patterns")
- Need to identify key files before making changes
- First step in any development workflow

---

## Process

### 1. Launch Research Agents in Parallel

**CRITICAL:** Launch all applicable research agents simultaneously via Task tool in a single message.

**Smart research decision (for agents 3 & 4):**
- High-risk topics (security, payments, external APIs) → always research
- Strong local context (good patterns, CLAUDE.md has guidance) → skip external
- Uncertainty or unfamiliar territory → research

| # | Agent | Condition | Task Tool Config |
|---|-------|-----------|-----------------|
| 1 | **Codebase Research Agent** | Always runs | `subagent_type: "Explore"`, reads `agents/research/codebase-researcher.md` for process |
| 2 | **Learnings Research Agent** | Always runs (if `docs/solutions/` has files) | `subagent_type: "general-purpose"`, searches `docs/solutions/` per `agents/research/learnings-researcher.md` |
| 3 | **Best Practices Research Agent** | Conditional: unfamiliar technology, external APIs, or user explicitly asks | `subagent_type: "general-purpose"`, web search per `agents/research/best-practices-researcher.md` |
| 4 | **Framework Docs Research Agent** | Conditional: known framework detected in package.json/Gemfile/requirements.txt/go.mod/Cargo.toml | `subagent_type: "general-purpose"`, queries Context7 MCP per `agents/research/framework-docs-researcher.md` |

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

**Thoroughness level for Codebase Research Agent:**
- Simple queries (single file/class): "quick"
- Feature areas: "medium"
- Full codebase: "very thorough"

### 2. Generate Consolidated Exploration Summary

From all agent outputs, create structured summary containing:

1. **Architecture Overview** (from Codebase Research Agent)
   - Key design patterns identified
   - Component relationships
   - Data flow

2. **Key Files** (Top 5-10 most relevant)
   - File path
   - Purpose
   - Important functions/classes

3. **Patterns Found**
   - Coding conventions
   - Error handling approach
   - Testing patterns
   - Security patterns

4. **Past Solutions Found** (from Learnings Research Agent)
   - Relevant solutions from `docs/solutions/`
   - Applicable gotchas and recommendations
   - *(If no solutions directory or no matches: "No past solutions found for this area")*

5. **Best Practices** (from Best Practices Research Agent, if triggered)
   - Current industry recommendations
   - Common mistakes to avoid
   - Source references

6. **Framework Documentation** (from Framework Docs Research Agent, if triggered)
   - Framework-specific conventions
   - Version-specific notes
   - Relevant API documentation

7. **Dependencies**
   - Internal dependencies
   - External libraries used
   - Coupling points

8. **Areas of Concern** (if any)
   - Technical debt
   - Security vulnerabilities
   - Performance bottlenecks
   - Missing tests

### 3. Optionally Create/Update Codebase Map

If exploration is "full" codebase overview:
- Create or update `.claude/CODEBASE_MAP.md`
- Store high-level architecture for future reference
- Include directory structure and component purposes

---

## Integration Points

- **Input from user**: Target area, path, pattern, or "full"
- **Output**: Structured exploration summary
- **Agent definitions**: `agents/research/*.md`
- **Consumed by**: `/explore` workflow command, `/plan` workflow
- **Feeds into**: Brainstorming, plan generation, issue creation
