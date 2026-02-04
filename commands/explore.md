---
description: Multi-agent codebase exploration and context gathering
---

# /explore

**Description:** Multi-agent codebase exploration and context gathering

**When to use:**
- Starting new feature and need to understand existing architecture
- Investigating specific area of codebase (e.g., "authentication patterns")
- Need to identify key files before making changes
- First step in GODMODE Phase 0 (Planning)

**Prerequisites:** None (entry point command)

---

## Invocation

**Interactive mode:**
User types `/explore` with no arguments. Claude asks what to explore.

**Direct mode:**
User types `/explore [target]` where target is:
- Feature area (e.g., "authentication")
- Specific path (e.g., "src/auth/")
- Pattern/concept (e.g., "error handling")
- "full" for complete codebase overview

---

## Arguments

- `[target]` - What to explore (feature area, path, pattern, or "full")
- No flags required - target can be natural language

---

## Execution Steps

### Step 1: Determine exploration target

**If direct mode (arguments provided):**
- Parse target from user input
- Example: `/explore authentication` → target = "authentication"

**If interactive mode (no arguments):**
- Ask user:
  ```
  Codebase Exploration

  What would you like to explore?
  1. Feature area (e.g., "authentication")
  2. Specific path (e.g., "src/auth/")
  3. Pattern/concept (e.g., "error handling")
  4. Full codebase overview

  Your choice: _____
  ```

### Step 1.5: Launch 4 Research Agents in Parallel

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

Provide a structured summary suitable for planning new work.
```

**Learnings Research Agent prompt:**
```
Search docs/solutions/ for past solutions relevant to [target].
Use multi-pass Grep strategy: tags → category → keywords → full-text.
Return relevant findings with applicability assessment.
```

**Thoroughness level for Codebase Research Agent:**
- Simple queries (single file/class): "quick"
- Feature areas: "medium"
- Full codebase: "very thorough"

### Step 2: Generate consolidated exploration summary

From all agent outputs, create structured summary containing:

1. **Architecture Overview** (from Codebase Research Agent)
   - Key design patterns identified
   - Component relationships
   - Data flow

2. **Key Files** (from Codebase Research Agent, Top 5-10 most relevant)
   - File path
   - Purpose
   - Important functions/classes

3. **Patterns Found** (from Codebase Research Agent)
   - Coding conventions
   - Error handling approach
   - Testing patterns
   - Security patterns

4. **Past Solutions Found** (from Learnings Research Agent) — NEW
   - Relevant solutions from `docs/solutions/`
   - Applicable gotchas and recommendations
   - *(If no solutions directory or no matches: "No past solutions found for this area")*

5. **Best Practices** (from Best Practices Research Agent, if triggered) — NEW
   - Current industry recommendations
   - Common mistakes to avoid
   - Source references

6. **Framework Documentation** (from Framework Docs Research Agent, if triggered) — NEW
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

### Step 3: Optionally create/update codebase map

If exploration is "full" codebase overview:
- Create or update `.claude/CODEBASE_MAP.md`
- Store high-level architecture for future reference
- Include directory structure and component purposes

### Step 4: Report findings and suggest next step

Output the structured summary and suggest:
```
Exploration complete!

Research agents used: Codebase + Learnings [+ Best Practices] [+ Framework Docs]
Past solutions found: N relevant learnings

Next steps:
- Brainstorm approaches: `/brainstorm`
- Generate PRD: `/generate-prd`
- Explore another area: `/explore [different-target]`
- Create ADR for architecture decision: `/create-adr`
```

---

## Output

**Structured exploration summary containing:**
- Architecture overview
- Key files (top 5-10 with purposes)
- Patterns identified
- Past solutions found (from `docs/solutions/`)
- Best practices (if researched)
- Framework documentation (if researched)
- Dependencies
- Areas of concern (if any)

**Status:** `EXPLORATION_COMPLETE`

**Confidence level:**
- `HIGH_CONFIDENCE` - Clear patterns, well-documented code
- `MEDIUM_CONFIDENCE` - Some unclear areas, moderate documentation
- `LOW_CONFIDENCE` - Complex/undocumented codebase, needs deeper investigation

**Suggested next step:**
- "Ready to brainstorm approaches? Run `/brainstorm`"
- "Ready to generate PRD? Run `/generate-prd`"
- Or: "Need deeper investigation? Run `/explore [specific-area]`"

---

## References

- See: `agents/research/codebase-researcher.md` for codebase exploration process
- See: `agents/research/learnings-researcher.md` for past solutions search
- See: `agents/research/best-practices-researcher.md` for web research
- See: `agents/research/framework-docs-researcher.md` for framework docs
- See: `AI_CODING_AGENT_GODMODE.md` Phase 0 Step 1 for exploration best practices
- See: `guides/CONTEXT_OPTIMIZATION.md` for token-efficient exploration techniques

---

## Example Usage

**Example 1: Interactive mode**
```
User: /explore

Claude: Codebase Exploration

What would you like to explore?
1. Feature area
2. Specific path
3. Pattern/concept
4. Full codebase overview

Your choice: 1

Claude: What feature area? _____

User: authentication

Claude: [Launches 4 research agents in parallel]
  - Codebase Research Agent: exploring authentication patterns
  - Learnings Research Agent: searching docs/solutions/ for auth learnings
  - Framework Docs Research Agent: querying Next.js auth docs (detected in package.json)
  - Best Practices Research Agent: skipped (strong local patterns exist)

Exploration complete!

Architecture Overview:
- JWT-based authentication with refresh tokens
- AuthService handles token generation/validation
- Middleware protects routes

Key Files:
1. src/auth/AuthService.ts - Core authentication logic
2. src/middleware/auth.ts - Route protection
3. src/models/User.ts - User model with password hashing

Past Solutions Found:
- auth-jwt-refresh-token-race-condition.md
  Gotcha: Concurrent refresh requests can invalidate tokens
  Recommendation: Implement token rotation with grace period

Framework Documentation:
- NextAuth.js v5: Use server-side session validation
- Middleware: Edge Runtime compatible auth checks only

Next steps:
- Brainstorm approaches: `/brainstorm`
- Generate PRD: `/generate-prd`
```

**Example 2: Direct mode**
```
User: /explore authentication patterns

Claude: [Immediately launches research agents for "authentication patterns"]

Exploration complete!
[Same structured output as above]

Next steps:
- Brainstorm approaches: `/brainstorm`
- Generate PRD: `/generate-prd`
```

**Example 3: Full codebase**
```
User: /explore full

Claude: [Launches very thorough exploration with all 4 agents]

Exploration complete!

Architecture Overview:
- Monorepo structure (apps/, packages/, libs/)
- Next.js frontend + Express backend
- PostgreSQL database with Prisma ORM

Past Solutions Found: 3 relevant learnings
Best Practices: Current React Server Components patterns researched
Framework Documentation: Next.js 14 app router conventions loaded

Created: .claude/CODEBASE_MAP.md

Next steps:
- Brainstorm approaches: `/brainstorm`
- Generate PRD: `/generate-prd`
```

---

## Notes

- **Multi-agent exploration**: Up to 4 research agents run in parallel for comprehensive context
- **Token optimization**: Use appropriate thoroughness level to avoid excessive token usage
- **Incremental exploration**: For large codebases, explore incrementally (feature by feature)
- **Codebase map**: Store findings in `.claude/CODEBASE_MAP.md` for future sessions
- **Learnings integration**: Past solutions surface relevant gotchas before you encounter them again
- **Conditional research**: Best Practices and Framework Docs agents only trigger when valuable
- **No prerequisites**: This is an entry point command - can be run anytime
