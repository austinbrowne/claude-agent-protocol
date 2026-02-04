---
description: Document architectural decisions using ADR template
---

# /create-adr

**Description:** Document architectural decisions using ADR (Architecture Decision Record) template

**When to use:**
- Making a significant architectural decision (database, framework, cloud provider)
- Decision involves tradeoffs between alternatives
- Decision is hard to reverse
- Decision will be questioned later ("Why didn't we use X?")
- After PRD approval, before implementation (Phase 0)

**Prerequisites:**
- Recommended: Approved PRD that requires architectural decisions
- Understanding of alternatives considered

---

## Invocation

**Interactive mode:**
User types `/create-adr` with no arguments. Claude guides through ADR template.

**Direct mode:**
User types `/create-adr "Decision title"` - Claude creates ADR template with title and asks for details.

---

## Arguments

- `"title"` - Decision title in quotes (e.g., "Use PostgreSQL for primary database")

---

## Execution Steps

### Step 1: Get decision title

**If direct mode (arguments provided):**
- Parse decision title from quoted string
- Example: `/create-adr "Use PostgreSQL for primary database"`

**If interactive mode (no arguments):**
- Ask user:
  ```
  📐 Architectural Decision Record

  What decision are you documenting?

  Decision title: _____
  ```

### Step 2: Determine next ADR number

**Find existing ADRs:**
```bash
ls docs/adr/ | grep -E '^[0-9]{4}-' | sort | tail -1
```

**Calculate next number:**
- If no ADRs exist: `0001`
- If `docs/adr/0003-existing.md` exists: Next is `0004`
- Pad with zeros to 4 digits

### Step 3: Load ADR template

**Read template:** `~/.claude/templates/ADR_TEMPLATE.md`

**Template sections:**
1. Title (ADR-NNNN: [Decision Title])
2. Metadata (Date, Status, Deciders, Technical Story)
3. Context (Problem, forces, constraints, current state)
4. Decision (What we're doing)
5. Consequences (Positive, Negative, Neutral)
6. Alternatives Considered (Options 1-3+ with pros/cons/why rejected)
7. Implementation Notes (Migration plan, rollout, effort)
8. Success Metrics (How to measure success)
9. References (Links to docs, research, benchmarks)
10. Notes (Additional context)

### Step 4: Guide user through ADR sections (Interactive)

**For interactive mode, ask questions for each section:**

**Metadata:**
```
Date: [Auto-fill with today's date]
Status: Proposed / Accepted / Deprecated
Deciders: [Who is involved in this decision?]
Technical Story: [Link to GitHub issue/PRD if applicable]
```

**Context:**
```
What problem are you solving?
- What forces are at play (technical, political, business)?
- Why is this decision necessary now?
- What constraints exist (time, resources, existing systems)?
- What's the current state?
```

**Decision:**
```
What are you doing? (State clearly in active voice)
Example: "We will use PostgreSQL as our primary database"

Your decision: _____
```

**Consequences:**
```
What are the POSITIVE consequences? (Benefits)
1. _____
2. _____
3. _____

What are the NEGATIVE consequences? (Tradeoffs, risks)
1. _____
2. _____

What are the NEUTRAL consequences? (Impacts)
1. _____
```

**Alternatives Considered:**
```
What alternatives did you consider?

Alternative 1: _____
Pros: _____
Cons: _____
Why rejected: _____

Alternative 2: _____
Pros: _____
Cons: _____
Why rejected: _____

Alternative 3: Do Nothing
Why rejected: _____
```

**Implementation Notes:**
```
Migration plan (if applicable): _____
Rollout strategy: _____
Estimated effort: _____
Team training needed: _____
```

**Success Metrics:**
```
How will you measure success?

Metric 1: _____
Baseline: _____
Target: _____
Measurement: _____

Review Date (when to re-evaluate): _____
```

**References:**
```
Any links to related docs, research, benchmarks?
1. _____
2. _____
```

### Step 5: Generate ADR file

**Filename format:** `docs/adr/NNNN-title-in-kebab-case.md`
- NNNN: Zero-padded number (e.g., 0001, 0042)
- title-in-kebab-case: Slugified decision title

**Example:**
- Title: "Use PostgreSQL for Primary Database"
- Number: 0001
- Filename: `docs/adr/0001-use-postgresql-for-primary-database.md`

**Create directory if needed:**
```bash
mkdir -p docs/adr
```

**Populate template:**
- Fill in all sections from user responses
- Set Date to today's date
- Set Status based on user choice (default: "Proposed")

**Save file:**
- Write ADR content to file
- Use proper markdown formatting from template

### Step 6: Report file location and suggest next step

```
✅ ADR created successfully!

File: docs/adr/0001-use-postgresql-for-primary-database.md
Status: Proposed
Review with team and update status to "Accepted" when decision is final.

Next steps:
- Share ADR with team for review
- Update status to "Accepted" once decision is final
- Document other major decisions: `/create-adr`
- Proceed to issue creation: `/create-issues`
```

---

## Output

**ADR file created:**
- Location: `docs/adr/NNNN-title.md`
- Status: Proposed (default) or Accepted
- All template sections populated

**Suggested next steps:**
- "Document other major decisions or proceed to `/create-issues`"
- "Link this ADR in your PRD's 'Architecture Decision Record' section"

---

## References

- See: `~/.claude/templates/ADR_TEMPLATE.md` for full template and examples
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 0 Step 3 for ADR guidance
- See: [ADR GitHub Organization](https://adr.github.io) for ADR best practices

---

## Example Usage

**Example 1: Interactive mode**
```
User: /create-adr

Claude: 📐 Architectural Decision Record

What decision are you documenting?

Decision title: _____

User: Use PostgreSQL for primary database

Claude: Date: 2025-12-01
Status: [1] Proposed [2] Accepted
Your choice: _____

User: 1

Claude: Deciders (who is involved in this decision): _____

User: Engineering Team, CTO

Claude: Technical Story (link to issue/PRD if applicable): _____

User: https://github.com/org/repo/issues/123

Claude: What problem are you solving?
- What forces are at play?
- Why is this decision necessary now?
- What constraints exist?

Your context: _____

User: [Provides context about database selection for SaaS app...]

Claude: [Continues through all sections...]

✅ ADR created successfully!

File: docs/adr/0001-use-postgresql-for-primary-database.md
Status: Proposed

Next steps:
- Share ADR with team for review
- Update status to "Accepted" when final
- Proceed to issue creation: `/create-issues`
```

**Example 2: Direct mode**
```
User: /create-adr "Use React with TypeScript for frontend"

Claude: Creating ADR-0002: Use React with TypeScript for frontend

Status: [1] Proposed [2] Accepted
Your choice [1]: _____

User: 2

Claude: Deciders: _____

User: Frontend Team Lead, Engineering Manager

Claude: [Continues through sections in interactive mode...]

✅ ADR created successfully!

File: docs/adr/0002-use-react-with-typescript-for-frontend.md
Status: Accepted
```

**Example 3: Quick ADR with minimal prompting**
```
User: /create-adr "Use Redis for caching layer"

Claude: Creating ADR-0003: Use Redis for caching layer

[Guides through minimal questions for small decision]

Context: _____
Decision rationale: _____
Main alternative considered: _____
Why rejected: _____

✅ ADR created successfully!

File: docs/adr/0003-use-redis-for-caching-layer.md
Status: Proposed

Note: This ADR is abbreviated for a smaller decision.
For major decisions, consider using the full template.
```

---

## Notes

- **ADR numbering**: Sequential, zero-padded to 4 digits (0001, 0002, etc.)
- **Status progression**: Proposed → Accepted → (Eventually: Deprecated or Superseded)
- **Never delete ADRs**: They are historical record - update status only
- **Link ADRs in PRD**: Reference ADR in PRD's "Architecture Decision Record" section
- **When to create ADR**:
  - ✅ Database choice, frontend framework, cloud provider
  - ✅ Decisions with significant tradeoffs
  - ✅ Decisions hard to reverse
  - ❌ Trivial choices (icon library, CSS framework)
  - ❌ Easily reversible implementation details
- **Alternatives section is critical**: Always document "Why not X?" to prevent future debates
- **Review dates**: Set review dates (3-12 months) to re-evaluate decision

---

## Post-Completion Flow

After creating the ADR, present next options using `AskUserQuestion`:

```
AskUserQuestion:
  question: "ADR created. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Run /generate-prd"
      description: "Generate a PRD that references this architectural decision"
    - label: "Done"
      description: "End workflow — ADR saved for team review"
```

Based on user's selection, invoke the chosen command.
