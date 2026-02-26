---
name: roadmap
version: "1.0"
description: Generate structured product roadmaps from vision and goals
referenced_by:
  - commands/plan.md
---

# Roadmap Generation Skill

Generate a structured product roadmap from a vision statement, personas, and goals. Invokes the Product Owner agent to produce a tiered roadmap with themes, epics, milestones, and success metrics.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has THREE mandatory AskUserQuestion gates. You MUST hit all three. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Step | AskUserQuestion | What Happens If Skipped |
|------|------|-----------------|------------------------|
| **Context Gathering** | Step 1 | Vision, personas, horizon, constraints | Roadmap generated without user requirements — GARBAGE |
| **Roadmap Acceptance** | Step 5 | Accept / Request Changes / Reject | Roadmap saved without user approval — UNACCEPTABLE |
| **Next Steps** | Handled by `commands/plan.md` Step 3 (enforced by calling command) | Backlog / Return to plan / Done | User loses control of workflow — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- Have a product vision, set of goals, or strategic themes to structure
- Want to create a Now/Next/Later roadmap for stakeholder alignment
- Starting product planning before backlog decomposition

## When to Skip

- Already have a roadmap and want to decompose it — use `/backlog` instead
- Need a technical implementation plan — use `/plan` → "Generate plan"
- Pure bug fixes or tactical work — no roadmap needed

---

## Skills Referenced

- **Product Owner Agent** — `agents/product/PRODUCT_OWNER.md` — Invoked via Task tool for roadmap generation
- **Roadmap Template** — `templates/ROADMAP_TEMPLATE.md` — Structure for output document

---

## Process

### Step 1: Gather Context — MANDATORY GATE

**STOP. You MUST gather context via AskUserQuestion before proceeding. NEVER generate a roadmap without user input.**

```
AskUserQuestion:
  question: "Let's build your product roadmap. Please provide the following context."
  header: "Roadmap"
  options:
    - label: "Ready to provide context"
      description: "I'll answer questions about vision, personas, horizon, and constraints"
    - label: "Start from existing material"
      description: "I have a document or notes to use as input"
```

**If "Ready to provide context":**

Ask the user to provide (in a single follow-up message or iteratively):
1. **Product name** — What is the product called?
2. **Vision** — One-sentence vision statement (minimum 10 characters)
3. **Personas** — Who are the primary user personas?
4. **Time horizon** — How far out? (e.g., "3 months", "1 year", "4 quarters")
5. **Constraints** — Any known constraints or non-negotiables?
6. **Existing features** — Any initiatives already in progress to incorporate?

**If "Start from existing material":**

Ask user to paste or provide a file path. Read the material and extract the context fields above.

**Input validation:**
- **Vision:** Must be non-empty, minimum 10 characters. If too short, re-prompt: "Please provide a more detailed vision statement."
- **Time horizon:** Must match one of: `N months` (1-36), `N years` (1-5), `Q[1-4] YYYY`, `H[1-2] YYYY`, `YYYY`. N must be a positive integer (≥ 1). Reject 0 months, 0 years, or negative values. If input does not match after 2 re-prompts, halt with: "Unable to parse time horizon. Please provide a duration such as 6 months, 1 year, or Q1 2026."
- **Product name:** Sanitize for filename use — strip characters outside `[a-zA-Z0-9-_ ]`, replace spaces with hyphens, lowercase, truncate to 50 chars. Store as `sanitized_name`. If `sanitized_name` is empty after sanitization, set `sanitized_name` to `'product'`. *(This sanitization applies to filename construction only. Display strings (e.g., YAML `title` field) use the original unsanitized product name.)*

### Step 2: Determine Roadmap Tier

**Auto-detect based on context:**

| Tier | Indicators |
|------|------------|
| **Minimal** | Horizon ≤ 3 months, early-stage product, quick alignment needed |
| **Standard** | Horizon 3-12 months, growing product, team alignment needed, strategic themes present |

Load the appropriate tier from `templates/ROADMAP_TEMPLATE.md`.

### Step 3: Run Product Owner Agent

Invoke the Product Owner agent via Task tool:

Note: The `model` parameter in the Task tool call is authoritative; the agent definition's YAML `model` field is for reference only.

```
Task(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""You are a Product Owner agent.

YOUR ROLE DEFINITION:
[inline content from agents/product/PRODUCT_OWNER.md]

TEMPLATE TO FOLLOW:
[inline content from templates/ROADMAP_TEMPLATE.md — selected tier]

CONTEXT:
- Product: [product name]
- Vision: [vision]
- Personas: [personas]
- Horizon: [time horizon]
- Constraints: [constraints]
- Existing features: [existing features or "none"]

INSTRUCTIONS:
1. Identify 3-5 strategic themes that ladder up to the vision
2. Map each theme to a roadmap horizon (Now / Next / Later)
3. Define epics under each theme with problem statements and success metrics
4. Assign MoSCoW priority (Must Have / Should Have / Could Have / Won't Have)
5. Flag risks, dependencies, and open questions

OUTPUT FORMAT:
Generate a complete roadmap document following the template structure exactly.
Include YAML frontmatter with type: roadmap, product name, date, and tier.

CRITICAL: Return the complete roadmap as text. Do NOT write any files.
""")
```

### Step 4: Validate Agent Output

Before presenting to the user, verify the agent's output contains:
- At least one `##` heading
- Presence of horizon sections (`## Now`, `## Next`, `## Later` or quarterly headings matching `## Q[1-4] YYYY` or `## H[1-2] YYYY`)
- At least one epic entry with a problem statement

**If validation fails:** Surface a warning to the user: "Agent output appears incomplete. Would you like to regenerate or proceed with what we have?"

### Step 5: Present and Review — MANDATORY GATE

**STOP. Present the generated roadmap to the user. Do NOT save to disk yet. You MUST get explicit acceptance.**

Display the roadmap content, then:

```
AskUserQuestion:
  question: "Here's the generated roadmap. Do you accept it?"
  header: "Review"
  options:
    - label: "Accept roadmap"
      description: "Looks good — save it and continue"
    - label: "Request changes"
      description: "I have specific changes I'd like to make"
    - label: "Reject"
      description: "This approach isn't right — discard and return to plan menu"
```

**If "Accept roadmap":** Proceed to Step 6.

**If "Request changes":**
1. Ask: "What specific changes would you like?" Wait for user response.
2. Re-invoke the Product Owner agent with original context + change notes.
3. Present the updated roadmap. Return to this AskUserQuestion.
4. **Cap at 3 revision rounds.** (**Note:** This revision protocol is shared with `skills/backlog/SKILL.md` Step 5. Changes here must be mirrored there.) Initialize revision counter to 0 before the first AskUserQuestion gate. Increment on each "Request changes" selection. Reset to 0 if the user accepts. After the 3rd round, present:
   ```
   AskUserQuestion:
     question: "We've done 3 revision rounds. How would you like to proceed?"
     header: "Revisions"
     options:
       - label: "Accept current version"
         description: "Save what we have"
       - label: "Save as draft for manual editing"
         description: "Save the file so you can edit it by hand"
       - label: "Discard"
         description: "Throw it away and return to plan menu"
   ```

**If "Reject":**
- Do NOT save anything to disk.
- Inform: "Roadmap discarded. Returning to plan menu."
- End this skill. Control returns to `commands/plan.md`.

### Step 6: Save Roadmap

**Filename:** `docs/roadmaps/YYYY-MM-DD-roadmap-[sanitized_name].md`

**Before saving:**
1. Create `docs/roadmaps/` directory if it does not exist.
2. Check if filename already exists. If so, append counter suffix (`-v2`, `-v3`, ...). Cap at `-v99`. If `-v99` already exists, halt with error: "Too many versions of this roadmap exist. Please archive or remove older files and retry." Never silently overwrite.

**Ensure YAML frontmatter includes:**
```yaml
---
type: roadmap
title: "[Product Name] Roadmap"
date: YYYY-MM-DD
status: active
product: "[sanitized-name]"
tier: minimal | standard
---
```

Save the file. Confirm to user: "Roadmap saved to `[path]`."

### Step 7: Hand Off

Control returns to `commands/plan.md` Step 3, which presents the post-skill AskUserQuestion gate. This skill does NOT present its own next-steps menu.

---

## Integration Points

- **Input from**: User-provided vision, personas, constraints (via AskUserQuestion)
- **Agent**: `agents/product/PRODUCT_OWNER.md` (invoked via Task tool, model: sonnet)
- **Template**: `templates/ROADMAP_TEMPLATE.md`
- **Output**: Roadmap file in `docs/roadmaps/`
- **Consumed by**: `/plan` workflow command, `/backlog` skill (reads roadmap as input)
