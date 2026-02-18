---
name: explore
description: "Reconnaissance & ideation — codebase exploration, context gathering, and brainstorming"
---

# Codebase Exploration

Workflow entry point for understanding a codebase before planning or implementing. Multi-step exploration with optional brainstorming.

---

## Mandatory Interaction Gates

**This skill has mandatory interaction gates. You MUST hit them. NEVER skip them.**

| Gate | Location | Interaction | What Happens If Skipped |
|------|----------|-------------|------------------------|
| **Exploration Scope** | Step 1 | Full codebase overview / Specific area | Wrong scope explored -- UNACCEPTABLE |
| **Next Steps** | Step 5 | Brainstorm / Start planning / Done | User loses control of workflow -- UNACCEPTABLE |

---

## When to Apply

- Starting new feature and need to understand existing architecture
- Investigating specific area of codebase (e.g., "authentication patterns")
- Need to identify key files before making changes
- First step in any development workflow

---

## Step 0: State Detection

Before presenting the menu, detect what exists:

1. **Check if `CODEBASE_MAP.md` exists** -- has the codebase already been explored?
2. **Search for `docs/brainstorms/*.md`** -- do any brainstorm docs exist?

Use these signals to inform Step 1. If a codebase map already exists, note it in the exploration step (update rather than create from scratch).

---

## Step 1: Determine Exploration Scope

Present the following options to the user:

> **Explore**
>
> What would you like to explore?
>
> 1. **Full codebase overview** -- Multi-agent exploration of the entire codebase structure and patterns
> 2. **Specific area** -- Focused exploration of a particular module, feature, or concern

**WAIT** for user response before continuing.

**If "Full codebase overview":** Proceed with broad exploration.
**If "Specific area":** Ask user to describe the target area, then proceed with focused exploration.

---

## Step 2: Conduct Research (Sequential)

Perform the following research steps sequentially. For each step, gather findings before proceeding to the next.

**Smart research decision (for steps 3 & 4):**
- High-risk topics (security, payments, external APIs) -> always research
- Strong local context (good patterns, project docs have guidance) -> skip external
- Uncertainty or unfamiliar territory -> research

### Research Step 1: Codebase Research (Always)

Explore the target area in the codebase. Identify:
1. Key files and their purposes
2. Architecture patterns used
3. Important functions/classes
4. Dependencies and relationships
5. Potential areas of concern

Search the project structure, read key files, and build a structured understanding suitable for planning new work.

**Thoroughness level:**
- Simple queries (single file/class): quick scan
- Feature areas: medium depth
- Full codebase: very thorough

### Research Step 2: Learnings Research (Always, if `docs/solutions/` has files)

Search `docs/solutions/` for past solutions relevant to the target area.
Use multi-pass search strategy: tags -> category -> keywords -> full-text.
Record relevant findings with applicability assessment.

### Research Step 3: Best Practices Research (Conditional)

**Condition:** Unfamiliar technology, external APIs, or user explicitly asks.

Search the web for current best practices, common mistakes to avoid, and industry recommendations for the relevant technology or pattern.

### Research Step 4: Framework Docs Research (Conditional)

**Condition:** Known framework detected in package.json/Gemfile/requirements.txt/go.mod/Cargo.toml.

Look up framework-specific conventions, version-specific notes, and relevant API documentation.

---

## Step 3: Generate Consolidated Exploration Summary

From all research outputs, create a structured summary containing:

1. **Architecture Overview** (from Codebase Research)
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

4. **Past Solutions Found** (from Learnings Research)
   - Relevant solutions from `docs/solutions/`
   - Applicable gotchas and recommendations
   - *(If no solutions directory or no matches: "No past solutions found for this area")*

5. **Best Practices** (from Best Practices Research, if triggered)
   - Current industry recommendations
   - Common mistakes to avoid
   - Source references

6. **Framework Documentation** (from Framework Docs Research, if triggered)
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

## Step 5: Next Steps -- MANDATORY GATE

Present the following options to the user:

> **Next step**
>
> Exploration complete. What would you like to do next?
>
> 1. **Brainstorm approaches** -- Structured divergent thinking to compare solution strategies
> 2. **Start planning** -- Move to `/generate-plan` to create a plan and prepare for implementation
> 3. **Done** -- End workflow -- exploration findings available in conversation

**WAIT** for user response before continuing.

**If "Brainstorm approaches":** Run `/brainstorm`. After brainstorm completes, present the post-brainstorm menu below.
**If "Start planning":** Run `/generate-plan`. Execute from Step 0. Do NOT skip any steps.
**If "Done":** End workflow.

---

### After Brainstorm Completes

Present the following options to the user:

> **Next step**
>
> Brainstorm complete. What would you like to do next?
>
> 1. **Review brainstorm** -- Run structured quality review on the brainstorm output
> 2. **Start planning** -- Move to `/generate-plan` to create a plan from brainstorm insights
> 3. **Done** -- End workflow -- brainstorm findings available in conversation

**WAIT** for user response before continuing.

**If "Review brainstorm":** Run a structured document review on the brainstorm output. After document review completes, re-present this menu.
**If "Start planning":** Run `/generate-plan`. Execute from Step 0. Do NOT skip any steps.
**If "Done":** End workflow.

---

## Integration Points

- **Input from user**: Target area, path, pattern, or "full"
- **Output**: Structured exploration summary
- **Feeds into**: Brainstorming, plan generation, issue creation
