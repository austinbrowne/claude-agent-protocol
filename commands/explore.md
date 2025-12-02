---
description: Codebase exploration and context gathering
---

# /explore

**Description:** Codebase exploration and context gathering

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
  🔍 Codebase Exploration

  What would you like to explore?
  1. Feature area (e.g., "authentication")
  2. Specific path (e.g., "src/auth/")
  3. Pattern/concept (e.g., "error handling")
  4. Full codebase overview

  Your choice: _____
  ```

### Step 2: Execute exploration using Task tool with subagent_type=Explore

**CRITICAL:** Use the Task tool with `subagent_type=Explore` for codebase exploration. This is the recommended approach per GODMODE protocol for non-needle queries.

**Example Task invocation:**
```
Task tool with:
- subagent_type: "Explore"
- description: "Explore [target] in codebase"
- prompt: "Explore the [target] in this codebase. Identify:
  1. Key files and their purposes
  2. Architecture patterns used
  3. Important functions/classes
  4. Dependencies and relationships
  5. Potential areas of concern

  Provide a structured summary suitable for planning new work."
```

**Thoroughness level:**
- Simple queries (single file/class): "quick"
- Feature areas: "medium"
- Full codebase: "very thorough"

### Step 3: Generate exploration summary

From the Explore agent output, create structured summary containing:

1. **Architecture Overview**
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

4. **Dependencies**
   - Internal dependencies
   - External libraries used
   - Coupling points

5. **Areas of Concern** (if any)
   - Technical debt
   - Security vulnerabilities
   - Performance bottlenecks
   - Missing tests

### Step 4: Optionally create/update codebase map

If exploration is "full" codebase overview:
- Create or update `.claude/CODEBASE_MAP.md`
- Store high-level architecture for future reference
- Include directory structure and component purposes

### Step 5: Report findings and suggest next step

Output the structured summary and suggest:
```
✅ Exploration complete!

Next steps:
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
- Dependencies
- Areas of concern (if any)

**Status:** `EXPLORATION_COMPLETE`

**Confidence level:**
- `HIGH_CONFIDENCE` - Clear patterns, well-documented code
- `MEDIUM_CONFIDENCE` - Some unclear areas, moderate documentation
- `LOW_CONFIDENCE` - Complex/undocumented codebase, needs deeper investigation

**Suggested next step:**
- "Ready to generate PRD? Run `/generate-prd`"
- Or: "Need deeper investigation? Run `/explore [specific-area]`"

---

## References

- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 0 Step 1 for exploration best practices
- See: `~/.claude/guides/CONTEXT_OPTIMIZATION.md` for token-efficient exploration techniques

---

## Example Usage

**Example 1: Interactive mode**
```
User: /explore

Claude: 🔍 Codebase Exploration

What would you like to explore?
1. Feature area (e.g., "authentication")
2. Specific path (e.g., "src/auth/")
3. Pattern/concept (e.g., "error handling")
4. Full codebase overview

Your choice: 1

Claude: What feature area? _____

User: authentication

Claude: [Launches Explore agent, generates summary]

✅ Exploration complete!

Architecture Overview:
- JWT-based authentication with refresh tokens
- AuthService handles token generation/validation
- Middleware protects routes

Key Files:
1. src/auth/AuthService.ts - Core authentication logic
2. src/middleware/auth.ts - Route protection
3. src/models/User.ts - User model with password hashing

Patterns Found:
- bcrypt for password hashing
- JWT tokens with 15min expiry
- Refresh tokens stored in httpOnly cookies

Dependencies:
- jsonwebtoken (^9.0.0)
- bcrypt (^5.1.0)

Next steps:
- Generate PRD: `/generate-prd`
```

**Example 2: Direct mode**
```
User: /explore authentication patterns

Claude: [Immediately launches Explore agent for "authentication patterns"]

✅ Exploration complete!

[Same structured output as above]

Next steps:
- Generate PRD: `/generate-prd`
```

**Example 3: Full codebase**
```
User: /explore full

Claude: [Launches very thorough exploration]

✅ Exploration complete!

Architecture Overview:
- Monorepo structure (apps/, packages/, libs/)
- Next.js frontend + Express backend
- PostgreSQL database with Prisma ORM
- Microservices architecture with API gateway

[Full directory structure and component purposes]

Created: .claude/CODEBASE_MAP.md

Next steps:
- Generate PRD: `/generate-prd`
```

---

## Notes

- **Token optimization**: Use Explore agent with appropriate thoroughness level to avoid excessive token usage
- **Incremental exploration**: For large codebases, explore incrementally (feature by feature) rather than all at once
- **Codebase map**: Store findings in `.claude/CODEBASE_MAP.md` for future sessions
- **No prerequisites**: This is an entry point command - can be run anytime
