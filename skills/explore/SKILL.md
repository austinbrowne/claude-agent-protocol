---
name: explore
version: "1.1"
description: "Reconnaissance & ideation — codebase exploration, context gathering, and brainstorming"
---

# Codebase Exploration

Workflow entry point for understanding a codebase before planning or implementing. Multi-agent exploration with optional brainstorming.

> **CRITICAL:** Do NOT call `EnterPlanMode`. Execute this command directly. The protocol handles its own planning.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Exploration Scope** | Step 1 | Full codebase overview / Specific area | Wrong scope explored — UNACCEPTABLE |
| **Next Steps** | Step 5 | Brainstorm / Start planning / Done | User loses control of workflow — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- Starting new feature and need to understand existing architecture
- Investigating specific area of codebase (e.g., "authentication patterns")
- Need to identify key files before making changes
- First step in any development workflow

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Check if `CODEBASE_MAP.md` exists** — has the codebase already been explored?
2. **Glob `docs/brainstorms/*.md`** — do any brainstorm docs exist?

Use these signals to inform Step 1. If a codebase map already exists, note it in the exploration step (update rather than create from scratch).

---

## Step 1: Determine Exploration Scope

```
AskUserQuestion:
  question: "What would you like to explore?"
  header: "Explore"
  options:
    - label: "Full codebase overview"
      description: "Multi-agent exploration of the entire codebase structure and patterns"
    - label: "Specific area"
      description: "Focused exploration of a particular module, feature, or concern"
```

**If "Full codebase overview":** Proceed with broad exploration.
**If "Specific area":** Ask user to describe the target area, then proceed with focused exploration.

---

## Step 2: Launch Research Agents in Parallel

<!-- Research agent config — canonical source: agents/research/DISPATCH_TABLE.md -->

**CRITICAL:** Launch all applicable research agents simultaneously via Task tool in a single message.

**Smart research decision (for agents 3 & 4):**
- High-risk topics (security, payments, external APIs) → always research
- Strong local context (good patterns, CLAUDE.md has guidance) → skip external
- Uncertainty or unfamiliar territory → research

| # | Agent | Condition | Model | Task Tool Config |
|---|-------|-----------|-------|-----------------|
| 1 | **Codebase Research Agent** | Always runs | (built-in) | `subagent_type: "Explore"`, reads `agents/research/codebase-researcher.md` for process |
| 2 | **Learnings Research Agent** | Always runs (if `docs/solutions/` has files) | haiku | `subagent_type: "general-purpose"`, `model: "haiku"`, searches `docs/solutions/` per `agents/research/learnings-researcher.md` |
| 3 | **Best Practices Research Agent** | Conditional: unfamiliar technology, external APIs, or user explicitly asks | haiku | `subagent_type: "general-purpose"`, `model: "haiku"`, web search per `agents/research/best-practices-researcher.md` |
| 4 | **Framework Docs Research Agent** | Conditional: known framework detected in package.json/Gemfile/requirements.txt/go.mod/Cargo.toml | haiku | `subagent_type: "general-purpose"`, `model: "haiku"`, queries Context7 MCP per `agents/research/framework-docs-researcher.md` |

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

---

## Step 3: Generate Consolidated Exploration Summary

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

---

## Step 4: Optionally Create/Update Codebase Map

If exploration is "full" codebase overview:
- Create or update `.claude/CODEBASE_MAP.md`
- Store high-level architecture for future reference
- Include directory structure and component purposes

---

## Step 5: Next Steps — MANDATORY GATE

**CRITICAL: You MUST present the AskUserQuestion below. NEVER ask "what would you like to do next?" in plain text. NEVER skip this step.**

```
AskUserQuestion:
  question: "Exploration complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Brainstorm approaches"
      description: "Structured divergent thinking to compare solution strategies"
    - label: "Start planning"
      description: "Move to /plan to create a plan and prepare for implementation"
    - label: "Done"
      description: "End workflow — exploration findings available in conversation"
```

**If "Brainstorm approaches":** Invoke `Skill(skill="godmode:brainstorm")`. After brainstorm completes, present the post-brainstorm menu below.
**If "Start planning":** Invoke `Skill(skill="godmode:plan")`. Execute from Step 0. Do NOT skip any steps.
**If "Done":** End workflow.

---

### After Brainstorm Completes

```
AskUserQuestion:
  question: "Brainstorm complete. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Review brainstorm"
      description: "Run structured quality review on the brainstorm output"
    - label: "Start planning"
      description: "Move to /plan to create a plan from brainstorm insights"
    - label: "Done"
      description: "End workflow — brainstorm findings available in conversation"
```

**If "Review brainstorm":** Invoke `Skill(skill="godmode:document-review")`. After document-review completes, re-present the "After Brainstorm Completes" AskUserQuestion above.
**If "Start planning":** Invoke `Skill(skill="godmode:plan")`. Execute from Step 0. Do NOT skip any steps.
**If "Done":** End workflow.

---

## Integration Points

- **Input from user**: Target area, path, pattern, or "full"
- **Output**: Structured exploration summary
- **Agent definitions**: `agents/research/*.md`
- **Feeds into**: Brainstorming, plan generation, issue creation
