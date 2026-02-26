---
name: backlog
version: "1.0"
description: Decompose roadmaps into groomed backlogs with epics, user stories, and MoSCoW prioritization
referenced_by:
  - commands/plan.md
---

# Backlog Generation Skill

Decompose an approved product roadmap into a fully groomed backlog of epics, user stories, and acceptance criteria — ready for sprint planning or GitHub issue creation.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has TWO mandatory AskUserQuestion gates (plus a conditional gate). You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Step | AskUserQuestion | What Happens If Skipped |
|------|------|-----------------|------------------------|
| **Roadmap Selection** | Step 1 | Select roadmap (if multiple) or provide input (if none) | Backlog generated from wrong/missing context — GARBAGE |
| **Backlog Acceptance** | Step 5 | Accept / Request Changes / Reject | Backlog saved without user approval — UNACCEPTABLE |
| **Next Steps** (enforced by calling command) | Handled by `commands/plan.md` Step 3 | Create Issues / Return to plan / Done | User loses control of workflow — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- Have an approved roadmap and want to decompose it into actionable stories
- Want to create a prioritized backlog for sprint planning
- Need structured epic cards and user stories with acceptance criteria

## When to Skip

- No roadmap or product vision exists — use `/roadmap` first
- Need a technical implementation plan — use `/plan` → "Generate plan"
- Single bug fix or tactical work — no backlog decomposition needed

---

## Skills Referenced

- **Product Owner Agent** — `agents/product/PRODUCT_OWNER.md` — Invoked via Task tool for backlog generation
- **Roadmap Skill** — `skills/roadmap/SKILL.md` — Produces the roadmap this skill consumes

---

## Process

### Step 1: Load Roadmap Context

**Roadmap discovery with guards:**

1. **Glob `docs/roadmaps/*.md`**

2. **If 0 matches — STOP:**
   ```
   AskUserQuestion:
     question: "No roadmap files found. How would you like to provide context?"
     header: "Backlog input"
     options:
       - label: "Run /roadmap first"
         description: "Generate a roadmap, then come back to create the backlog"
       - label: "Paste roadmap content"
         description: "I'll paste or describe the roadmap themes and epics"
       - label: "Describe goals directly"
         description: "I'll describe goals and let the agent structure them"
   ```
   - **"Run /roadmap first":** Inform user: "Routing to /roadmap." Invoke `Skill(skill="godmode:roadmap")`. End this skill.
   - **"Paste roadmap content":** Collect freetext from user. Validate input is non-empty (trim whitespace). If empty, re-prompt once: "Please provide content to proceed." If still empty after re-prompt, return to the AskUserQuestion gate. Proceed to Step 2.
   - **"Describe goals directly":** Collect freetext from user. Validate input is non-empty (trim whitespace). If empty, re-prompt once: "Please provide content to proceed." If still empty after re-prompt, return to the AskUserQuestion gate. Proceed to Step 2.

3. **If 1 match:** Load that file automatically. Inform user which file was loaded.

4. **If 2-3 matches:** Present selection:
   ```
   AskUserQuestion:
     question: "Multiple roadmaps found. Which one should the backlog be based on?"
     header: "Select roadmap"
     options:
       # Dynamically generated from glob results, sorted by date descending
       - label: "[filename-1]"
         description: "[product name from YAML] — [date]"
       - label: "[filename-2]"
         description: "[product name from YAML] — [date]"
       # ... up to 3 options
       - label: "None of these"
         description: "Enter a filename manually or provide roadmap content"
   ```

5. **If 4+ matches:** Show 3 most recent as options + manual entry (Display the 3 most recent roadmaps as options, reserving one AskUserQuestion slot for 'Enter filename manually'. The 2-3 branch uses up to 3 option slots for roadmap files plus one escape hatch — users with 2-3 roadmaps see all of them plus the escape hatch):
   ```
   AskUserQuestion:
     question: "Many roadmaps found. Select one or enter a filename."
     header: "Select roadmap"
     options:
       - label: "[most-recent-1]"
         description: "[product] — [date]"
       - label: "[most-recent-2]"
         description: "[product] — [date]"
       - label: "[most-recent-3]"
         description: "[product] — [date]"
       - label: "Enter filename manually"
         description: "I'll type the path to the roadmap file"
   ```

**After loading roadmap file:**
- **YAML validation:** Parse frontmatter. If malformed, surface warning: "Roadmap file has invalid YAML frontmatter. Proceeding with content only." If all matched files are skipped due to malformed YAML (0 usable files after validation), fall back to the 0-matches branch and present its AskUserQuestion gate.
- **Contract validation:** Verify roadmap contains expected structure — horizon headings (`## Now`, `## Next`, `## Later` or quarterly), and at least one epic-level entry with `**Problem:**` field. If missing, warn user: "Roadmap structure doesn't match expected format. The backlog quality may be affected."

  **Roadmap-Backlog Contract:** For the backlog skill to process a roadmap, the roadmap must contain: (1) At least one horizon section heading (`## Now`, `## Next`, `## Later`, or quarterly headings `## Q[1-4] YYYY`), and (2) Epic entries with `**Problem:**` fields under each horizon.

### Step 2: Run Product Owner Agent

Invoke the Product Owner agent via Task tool. **If the roadmap was loaded from a file**, pass the file path — the agent reads it itself (keeps roadmap content out of the orchestrator's context). **If the user pasted/described content directly**, inline it in the prompt (no file exists to read).

**Template (roadmap from file):**
```
Task(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""You are a Product Owner agent.

YOUR ROLE DEFINITION:
[inline content from agents/product/PRODUCT_OWNER.md]

STEP 1 — Read the roadmap:
Use the Read tool to read: [path to roadmap file, e.g. docs/roadmaps/2026-02-25-roadmap-taskflow.md]

STEP 2 — Generate the backlog using the instructions below.

INSTRUCTIONS:
```

**Template (user-provided text, no file):**
```
Task(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""You are a Product Owner agent.

YOUR ROLE DEFINITION:
[inline content from agents/product/PRODUCT_OWNER.md]

ROADMAP CONTEXT:
[user-provided text — inlined because no file exists]

INSTRUCTIONS:
For each Epic in the roadmap, generate:

**Epic Card:**
## Epic: [Epic Name]
**Theme:** [parent theme]
**Problem Statement:** [what problem this solves]
**Hypothesis:** If we [action], then [persona] will [outcome], evidenced by [metric]
**Success Metric:** [measurable outcome]
**Priority:** Must Have / Should Have / Could Have
**Estimated Effort:** S / M / L / XL

**User Stories (3-6 per epic):**
### Story: [Story Title]
**As a** [persona],
**I want** [goal],
**So that** [outcome].
**Acceptance Criteria:**
- Given [context], When [action], Then [result]
- Given [context], When [action], Then [result]
**Story Points:** [1 / 2 / 3 / 5 / 8 / 13]
**Priority:** Must Have / Should Have / Could Have
**Dependencies:** [none / list]

After generating all epics and stories, produce a PRIORITIZED BACKLOG TABLE:
| # | Story | Priority | Points | Epic |
|---|-------|----------|--------|------|
| 1 | ...   | Must Have | 3     | ... |
| 2 | ...   | Should Have | 5   | ... |

Sort by: Must Have first, then Should Have, then Could Have.
Within each tier, sort by story points ascending (quick wins first).

CRITICAL: Return the complete backlog as text. Do NOT write any files.
""")
```

### Step 3: Validate Agent Output

Before presenting to the user, verify the agent's output contains:
- At least one `## Epic:` heading
- At least one `### Story:` entry with acceptance criteria
- A prioritized backlog table

**If validation fails:** Surface a warning: "Agent output appears incomplete. Would you like to regenerate or proceed with what we have?"

### Step 4: Present to User

Display the generated backlog content inline. Include a summary header:

```
Backlog Summary
━━━━━━━━━━━━━━
Epics: [N]
Stories: [N]
Total story points: [N]
Must Have: [N stories] | Should Have: [N stories] | Could Have: [N stories]
```

### Step 5: Review — MANDATORY GATE

**STOP. You MUST get explicit acceptance via AskUserQuestion. NEVER save without approval.**

```
AskUserQuestion:
  question: "Here's the generated backlog. Do you accept it?"
  header: "Review"
  options:
    - label: "Accept backlog"
      description: "Looks good — save it and continue"
    - label: "Request changes"
      description: "I have specific changes I'd like to make"
    - label: "Reject"
      description: "This approach isn't right — discard and return to plan menu"
```

**If "Accept backlog":** Proceed to Step 6.

**If "Request changes":**
1. Ask: "What specific changes would you like?" Wait for user response.
2. Re-invoke the Product Owner agent with original context + change notes.
3. Present the updated backlog. Return to this AskUserQuestion.
4. Initialize revision counter to 0 before the first review gate. Increment on each 'Request changes' selection. Reset to 0 if the user accepts. **Cap at 3 revision rounds.** **Note:** This revision protocol is shared with `skills/roadmap/SKILL.md` Step 5. Changes here must be mirrored there. After the 3rd round, present:
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
- Inform: "Backlog discarded. Returning to plan menu."
- End this skill. Control returns to `commands/plan.md`.

### Step 6: Save Backlog

**Filename:** `docs/backlogs/YYYY-MM-DD-backlog-[sanitized_name].md`

Where `sanitized_name` is derived from the product name in the roadmap. Apply the canonical sanitization rules defined in `skills/roadmap/SKILL.md` Step 1 (Input Validation): strip characters outside `[a-zA-Z0-9-_ ]`, replace spaces with hyphens, lowercase, truncate to 50 chars. If empty after sanitization, fallback to `'backlog'`.

**Before saving:**
1. Create `docs/backlogs/` directory if it does not exist.
2. Check if filename already exists. If so, append counter suffix (`-v2`, `-v3`). Cap at `-v99`. If `-v99` already exists, halt with error: "Too many versions of this backlog exist. Please archive or remove older files and retry." Never silently overwrite.

**Ensure YAML frontmatter includes:**
```yaml
---
type: backlog
title: "[Product Name] Backlog"
date: YYYY-MM-DD
status: active
product: "[sanitized-name]"
source_roadmap: "[path to source roadmap, if applicable]"
---
```

Save the file. Confirm to user: "Backlog saved to `[path]`."

### Step 7: Hand Off

Control returns to `commands/plan.md` Step 3, which presents the post-skill AskUserQuestion gate. This skill does NOT present its own next-steps menu.

---

## Integration Points

- **Input from**: Roadmap file in `docs/roadmaps/` or user-provided text
- **Agent**: `agents/product/PRODUCT_OWNER.md` (invoked via Task tool, model: sonnet)
- **Output**: Backlog file in `docs/backlogs/`
- **Consumed by**: `/plan` workflow command
- **Chains to**: `/create-issues` (via `commands/plan.md` post-skill gate) or manual `gh issue create`
