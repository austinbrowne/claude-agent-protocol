---
description: Structured divergent thinking before committing to a solution
---

# /brainstorm

**Description:** Structured divergent thinking before committing to a solution

**When to use:**
- Before generating PRD for complex features with multiple valid approaches
- When the "right" solution is not obvious
- Exploring tradeoffs between fundamentally different architectures
- Team cannot agree on an approach and needs structured comparison
- Phase 0 ideation step — before `/generate-prd`

**Prerequisites:** None (entry point command)
- Benefits from `/explore` output if available (provides codebase context)
- No hard prerequisites — can be invoked at any time

---

## Invocation

**Interactive mode:**
User types `/brainstorm` with no arguments. Claude asks what topic to brainstorm.

**Direct mode:**
User types `/brainstorm [topic]` where topic is a natural-language description of the decision space.

---

## Arguments

- `[topic]` - What to brainstorm (feature approach, architecture decision, strategy, etc.)
- `--skip` - Skip brainstorming entirely (for clear tasks where the approach is obvious)
- No other flags required — topic can be natural language

---

## Execution Steps

### Step 1: Assess whether brainstorming adds value

**Auto-skip criteria (suggest `--skip`):**
- Clear bug fixes with a single obvious solution
- Small tasks with <2 hours estimated effort
- Tasks where the approach is dictated by existing patterns
- Direct instructions from user that leave no ambiguity

**If unclear whether brainstorming is worthwhile:**
- Ask the user:
  ```
  This task looks relatively straightforward. Brainstorming is most valuable
  when multiple valid approaches exist.

  Options:
  1. Run brainstorm (explore alternatives)
  2. Skip brainstorm (proceed directly to /generate-prd)

  Your choice: _____
  ```

**If `--skip` flag provided:**
```
Brainstorm skipped.

Next steps:
- Generate PRD: `/generate-prd`
- Explore codebase first: `/explore`
```

### Step 2: Search for relevant past learnings

> **Implementation Note:** Claude uses its internal Task tool to spawn a Learnings Research Agent. Users do not need to do anything — just invoke `/brainstorm` and Claude handles this automatically.

**Launch Learnings Research Agent via Task tool:**
```
Task tool with:
- description: "Search past learnings for brainstorm on [topic]"
- prompt: "You are a Learnings Research Agent. Follow the process in
  agents/research/learnings-researcher.md.

  Search docs/solutions/ for any past solutions, gotchas, or patterns
  relevant to: [topic]

  Run multi-pass Grep:
  1. Tag matching for [relevant keywords]
  2. Category matching for [relevant categories]
  3. Problem summary keyword matching
  4. Full-text domain search

  Return findings in the standard output format."
```

**If no `docs/solutions/` directory exists or no results found:**
- Note: "No past learnings found for this topic."
- Continue to Step 3 (learnings are informational, not blocking)

### Step 3: Understand the problem space

**Gather context:**
- If `/explore` was run previously in conversation, use those findings
- If not, identify key constraints from:
  - User's topic description
  - Codebase patterns (quick Grep for relevant keywords)
  - Past learnings from Step 2

**Define the problem space:**
1. **Core problem:** What are we trying to solve?
2. **Constraints:** What are the hard limits (performance, security, compatibility)?
3. **Preferences:** What are the soft preferences (simplicity, extensibility)?
4. **Context:** What does the existing codebase already do in this area?
5. **Past learnings:** What have we learned from similar decisions?

**Present to user for validation:**
```
Problem Space:

Core problem: [description]

Constraints:
- [Hard constraint 1]
- [Hard constraint 2]

Preferences:
- [Soft preference 1]

Existing context:
- [What the codebase already does]

Past learnings:
- [Relevant learnings from docs/solutions/, if any]

Does this capture the problem correctly? (yes/adjust): _____
```

### Step 4: Generate 2-3 approaches with analysis

**For each approach, provide:**

1. **Name** — short, descriptive label
2. **Description** — how the approach works (2-4 sentences)
3. **Pros** — concrete advantages (2-4 items)
4. **Cons** — concrete disadvantages (2-4 items)
5. **Complexity** — Low / Medium / High
6. **Risk** — Low / Medium / High (consider security, breaking changes, unknowns)
7. **Effort estimate** — rough hours/days
8. **Fits existing patterns** — Yes / Partially / No

**Guidelines for generating approaches:**
- At least one approach should be the "simplest thing that works"
- At least one approach should optimize for future extensibility
- If a past learning applies, at least one approach should incorporate it
- Approaches should be genuinely different, not minor variations
- Be honest about tradeoffs — do not present a clear winner as if it were a tough choice

### Step 5: Present comparison matrix and get decision

**Comparison matrix format:**

```
Comparison Matrix:

| Criteria          | Approach 1: [Name] | Approach 2: [Name] | Approach 3: [Name] |
|-------------------|---------------------|---------------------|---------------------|
| Complexity        | Low                 | Medium              | High                |
| Risk              | Low                 | Medium              | Low                 |
| Effort            | 4 hours             | 8 hours             | 12 hours            |
| Maintainability   | High                | Medium              | High                |
| Security          | Medium              | High                | High                |
| Performance       | High                | Medium              | High                |
| Fits codebase     | Yes                 | Partially           | No                  |

Recommendation: [Approach N] — [1-sentence rationale]

Which approach do you prefer? (1/2/3/discuss): _____
```

**If user says "discuss":**
- Engage in back-and-forth to clarify tradeoffs
- Answer specific questions about approaches
- Adjust analysis based on user input
- Re-present matrix if significant changes

### Step 6: Capture brainstorm to document

**After user decides:**

**Create directory if needed:**
```bash
mkdir -p docs/brainstorms
```

**Generate filename:**
- Format: `docs/brainstorms/YYYY-MM-DD-{slug}-brainstorm.md`
- Slug: kebab-case from topic (first 3-5 words)
- Example: `docs/brainstorms/2026-02-03-auth-strategy-brainstorm.md`

**Load template from:** `templates/BRAINSTORM_TEMPLATE.md`

**Populate template with:**
- Problem space from Step 3
- All approaches from Step 4
- Comparison matrix from Step 5
- Chosen approach and rationale
- Past learnings referenced
- Set `status: decided` and `chosen_approach: [name]`

**Save file.**

### Step 7: Handoff to next step

```
Brainstorm captured!

File: docs/brainstorms/YYYY-MM-DD-{slug}-brainstorm.md
Status: BRAINSTORM_COMPLETE
Chosen approach: [Name]

Next steps:
- Generate PRD from chosen approach: `/generate-prd`
- Create ADR for this decision: `/create-adr`
- Explore codebase for implementation details: `/explore [related area]`
```

---

## Output

**Brainstorm document saved:**
- Location: `docs/brainstorms/YYYY-MM-DD-{slug}-brainstorm.md`
- Status: `BRAINSTORM_COMPLETE`
- Chosen approach recorded with rationale

**Metadata:**
- Number of approaches evaluated
- Past learnings referenced (if any)
- Confidence level in chosen approach

**Suggested next steps:**
- "Ready to formalize? Run `/generate-prd`"
- Or: "Need architectural decision record? Run `/create-adr`"

---

## References

- See: `templates/BRAINSTORM_TEMPLATE.md` for brainstorm document structure
- See: `agents/research/learnings-researcher.md` for past learnings research process
- See: `AI_CODING_AGENT_GODMODE.md` Phase 0 for planning best practices

---

## Example Usage

**Example 1: Interactive mode**
```
User: /brainstorm

Claude: What topic would you like to brainstorm?

User: How to implement real-time notifications

Claude: [Searches docs/solutions/ for learnings]
[Defines problem space]

Problem Space:

Core problem: Users need real-time notifications for events
Constraints:
- Must support 10K concurrent users
- Must work across tabs
Preferences:
- Prefer simple infrastructure
Existing context:
- No real-time features currently exist
Past learnings:
- No relevant solutions found

Does this capture the problem correctly? yes

Claude: [Generates 3 approaches]

Approach 1: WebSocket Server
Approach 2: Server-Sent Events (SSE)
Approach 3: Polling with Long-Poll Fallback

Comparison Matrix:
| Criteria       | WebSocket      | SSE            | Polling         |
|---------------|----------------|----------------|-----------------|
| Complexity    | Medium         | Low            | Low             |
| Risk          | Medium         | Low            | Low             |
| Effort        | 12 hours       | 6 hours        | 4 hours         |
| Bidirectional | Yes            | No             | No              |
| Scalability   | High           | High           | Medium          |

Recommendation: SSE — simplest solution that meets requirements

Which approach? 2

Claude: Brainstorm captured!

File: docs/brainstorms/2026-02-03-realtime-notifications-brainstorm.md
Status: BRAINSTORM_COMPLETE

Next steps:
- Generate PRD: `/generate-prd`
```

**Example 2: Direct mode**
```
User: /brainstorm caching strategy for API responses

Claude: [Immediately starts brainstorming "caching strategy for API responses"]

[Searches past learnings]
[Defines problem space from topic]
[Generates approaches: Redis, In-Memory LRU, HTTP Cache Headers]
[Presents comparison matrix]

Which approach? 1

Claude: Brainstorm captured!

File: docs/brainstorms/2026-02-03-caching-strategy-brainstorm.md
Status: BRAINSTORM_COMPLETE

Next steps:
- Generate PRD: `/generate-prd`
```

**Example 3: Skip mode**
```
User: /brainstorm --skip

Claude: Brainstorm skipped.

Next steps:
- Generate PRD: `/generate-prd`
- Explore codebase first: `/explore`
```

---

## Notes

- **Not always needed:** Skip for clear bug fixes, small tasks, or when the approach is obvious
- **Past learnings integration:** Searches `docs/solutions/` to avoid repeating past mistakes
- **Human decides:** Claude recommends but the human always makes the final call
- **Captured for posterity:** Brainstorm doc records rejected alternatives and rationale — valuable context for future developers
- **Pairs with /create-adr:** For major architectural decisions, create an ADR after brainstorming
- **Token efficiency:** Learnings research uses a subagent to avoid polluting main conversation context
- **2-3 approaches is the sweet spot:** More than 3 causes analysis paralysis; fewer than 2 is not really brainstorming
