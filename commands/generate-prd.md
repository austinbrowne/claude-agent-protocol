---
description: Create PRD from exploration or user description with parallel research and spec-flow analysis
---

# /generate-prd

**Description:** Create PRD (Product Requirements Document) from exploration or user description

**When to use:**
- After exploring codebase and ready to formalize requirements
- Have clear feature description and want structured planning
- Need to document requirements before implementation
- Phase 0 Step 2 in GODMODE workflow

**Prerequisites:**
- Recommended (not required): `/explore` output for context
- Can generate from feature description alone

---

## Invocation

**Interactive mode:**
User types `/generate-prd` with no arguments. Claude asks for feature description and PRD type.

**Direct mode:**
User types `/generate-prd --lite "feature description"` or `/generate-prd --full "feature description"`

---

## Arguments

- `--lite` - Generate Lite PRD (small-to-medium tasks)
- `--full` - Generate Full PRD (complex features)
- `"description"` - Feature description (required)

---

## Execution Steps

### Step 1: Get feature description

**If direct mode (arguments provided):**
- Parse feature description from quoted string
- Example: `/generate-prd --full "OAuth 2.0 authentication"`

**If interactive mode (no arguments):**
- Ask user:
  ```
  PRD Generation

  What feature would you like to document?

  Feature description: _____
  ```

### Step 1.5: Parallel Local Research

**Before generating PRD content, launch 2 research agents in parallel (single message with multiple Task calls):**

**Agent 1: Learnings Researcher**
- Search `docs/solutions/` for relevant past solutions matching feature keywords
- Use multi-pass Grep: tags → category → content matching
- Reference: `agents/research/learnings-researcher.md`

**Agent 2: Codebase Pattern Researcher**
- Search codebase for existing patterns related to the feature
- Find similar implementations and identify conventions to follow
- Reference: `agents/research/codebase-researcher.md`

**Incorporate findings into:**
- Technical Approach section (use patterns found in codebase)
- Risks section (apply gotchas from past solutions)
- Test Strategy (past testing approaches for similar features)

### Step 2: Determine PRD type (Lite or Full)

**Auto-detection criteria:**
- Lite PRD:
  - Small bug fixes
  - Minor feature additions
  - Simple refactoring
  - Single-file changes

- Full PRD:
  - New major features
  - Multi-component changes
  - Architectural changes
  - Security-sensitive features
  - Breaking changes

**If direct mode with flag:**
- Use specified flag (`--lite` or `--full`)

**If interactive mode:**
- Show auto-detected recommendation
- Ask user to confirm or override:
  ```
  Based on description, recommending: Full PRD

  PRD type:
  1. Lite — Quick format
  2. Full — Comprehensive format

  Your choice [2]: _____
  ```

### Step 2.5: Check for Recent Brainstorms

**Search for relevant brainstorm documents:**
```
Glob: docs/brainstorms/*.md
```

**Filter for:**
- YAML frontmatter `status: decided`
- Matching tags (overlap with feature keywords)
- Date within 14 days

**If found:**
```
Recent brainstorm found: docs/brainstorms/2025-12-15-auth-strategy-brainstorm.md
  Chosen approach: "OAuth 2.0 with PKCE"
  Tags: authentication, oauth, security

Incorporate chosen approach into Technical Approach section? (yes/no): ___
```

**If yes:**
- Use chosen approach as basis for Technical Approach section
- Rejected alternatives become "Alternatives Considered" section in PRD

### Step 3: Generate PRD using appropriate template

**Load template:**
- Read `PRD_TEMPLATE.md`
- Use Lite format or Full format based on Step 2

**Generate PRD content:**

**For Lite PRD:**
```markdown
### [Feature Name]

**Problem:** [1-2 sentences from exploration and user description]

**Solution:** [1-2 sentences describing proposed fix]

**Success Metric:** [How we'll know it worked]

**Acceptance Criteria:**
- [ ] [Generated from requirements]
- [ ] [Generated from requirements]
- [ ] Tests passing with >80% coverage
- [ ] Security review completed (if SECURITY_SENSITIVE)

**Test Strategy:**
- Unit tests: [What to test]
- Integration tests: [What to test]
- (See `templates/TEST_STRATEGY.md` for details)

**Security Review:** [Y/N based on security triggers]
- If yes, use `checklists/AI_CODE_SECURITY_REVIEW.md`

**Past Learnings Applied:**
- [Relevant solution from docs/solutions/, if any]

**Risks:** [Key risk, if any]

**Status:** READY_FOR_REVIEW
```

**For Full PRD:**
- Complete all sections from template (Document Info through Rollback Plan)
- Auto-populate exploration data if `/explore` was run
- Include past learnings in Technical Approach and Risks
- Include brainstorm approach in Technical Approach (if found)

**Auto-detect security sensitivity:**
Check if feature involves: authentication/authorization, PII/sensitive data, external APIs, user input processing, file uploads, database queries with user input

If yes: Flag as `SECURITY_SENSITIVE` and mark security review as MANDATORY

### Step 3.5: Spec-Flow Analysis

**After generating initial PRD content, analyze user flows:**

1. **Enumerate all user flows** from the Solution section:
   - Primary flow (happy path)
   - Alternative flows (valid variations)
   - Error flows (what goes wrong)

2. **For each flow, check for:**
   - Happy path: fully specified?
   - Error states: what happens on failure at each step?
   - Empty states: what does the user see with no data?
   - Edge states: unusual but valid inputs?
   - Permission states: what if user lacks access?
   - Loading/transition states: what during async operations?

3. **Generate flow map:**
   ```
   Flow 1: [Primary user flow]
   Step 1: User does X → Success: Y | Error: Z | Empty: W
   Step 2: System responds → Success: Y | Timeout: Z | Invalid: W
   ...
   ```

4. **Identify gaps:**
   ```
   SPEC-FLOW GAPS:
   - No handling for: [scenario] at Step [N]
   - Missing error state for: [condition]
   - Empty state undefined for: [view/component]
   ```

5. **Offer to add gaps to Acceptance Criteria:**
   ```
   Spec-Flow analysis found 3 gaps. Add to Acceptance Criteria? (yes/no)
   ```

6. **Add Spec-Flow Analysis section to PRD output**

### Step 4: Generate filename and save PRD

**Filename format:** `docs/prds/YYYY-MM-DD-feature-name.md`

**Create directory if needed:**
```bash
mkdir -p docs/prds
```

**Save file:**
- Write PRD content to file
- Set status to `READY_FOR_REVIEW`

**Important:** This filename format is temporary. When `/create-issues` creates GitHub issues from this PRD, the file will be renamed to include the first issue number as a prefix.

### Step 5: Report file location and suggest next step

```
PRD generated successfully!

File: docs/prds/2025-12-01-oauth-authentication.md
Type: Full PRD
Status: READY_FOR_REVIEW
Priority: High
Security Sensitive: Yes
Past learnings applied: 2
Spec-flow gaps found: 3 (added to acceptance criteria)

Next steps:
- Review PRD and approve
- Deepen plan with research: `/deepen-plan docs/prds/2025-12-01-oauth-authentication.md`
- Review plan before implementation: `/review-plan docs/prds/2025-12-01-oauth-authentication.md`
- Create ADR for major decisions: `/create-adr`
- Generate GitHub issues: `/create-issues docs/prds/2025-12-01-oauth-authentication.md`
```

---

## Output

**PRD file created:**
- Location: `docs/prds/YYYY-MM-DD-feature-name.md`
- Type: Lite or Full
- Status: `READY_FOR_REVIEW`

**Metadata:**
- Priority: Auto-detected (Critical/High/Medium/Low)
- Security Sensitive: Yes/No
- Past learnings applied: count
- Spec-flow gaps found: count

**Suggested next steps:**
- "Deepen plan: `/deepen-plan`"
- "Review plan: `/review-plan`"
- "Create issues: `/create-issues`"

---

## References

- See: `PRD_TEMPLATE.md` for PRD template structure
- See: `templates/TEST_STRATEGY.md` for test planning
- See: `checklists/AI_CODE_SECURITY_REVIEW.md` for security review
- See: `templates/ADR_TEMPLATE.md` for architecture decisions
- See: `agents/research/learnings-researcher.md` for past solutions search
- See: `agents/research/codebase-researcher.md` for codebase pattern research
- See: `agents/review/spec-flow-reviewer.md` for spec-flow analysis
- See: `AI_CODING_AGENT_GODMODE.md` Phase 0 Step 2 for PRD best practices

---

## Example Usage

**Example 1: Interactive mode with research**
```
User: /generate-prd

Claude: PRD Generation

What feature would you like to document?

Feature description: Add password reset functionality via email

Claude: [Launches 2 research agents in parallel]
  - Learnings Researcher: found auth-email-token-expiry.md
  - Codebase Pattern Researcher: found existing email service patterns

Based on description, recommending: Full PRD
(Security-sensitive: email handling, password reset tokens)

PRD type: Full

Checking for recent brainstorms... none found.

[Generates Full PRD with all sections]
[Runs Spec-Flow Analysis: 2 gaps found]

PRD generated successfully!

File: docs/prds/2025-12-01-password-reset.md
Past learnings applied: 1 (token expiry gotcha)
Spec-flow gaps: 2 (added to acceptance criteria)

Next steps:
- Deepen plan: `/deepen-plan docs/prds/2025-12-01-password-reset.md`
- Create issues: `/create-issues docs/prds/2025-12-01-password-reset.md`
```

**Example 2: Direct mode with brainstorm integration**
```
User: /generate-prd --full "OAuth 2.0 support (Google, GitHub providers)"

Claude: [Research agents find relevant learnings]

Recent brainstorm found: docs/brainstorms/2025-12-15-auth-strategy-brainstorm.md
  Chosen approach: "OAuth 2.0 with PKCE flow"

Incorporate into Technical Approach? yes

[Generates Full PRD incorporating brainstorm decision]
[Rejected approaches added to Alternatives Considered section]

PRD generated successfully!
File: docs/prds/2025-12-01-oauth-support.md
```

**Example 3: Lite PRD**
```
User: /generate-prd --lite "Fix bug where logout button doesn't clear session cookie"

Claude: [Quick research, generates Lite PRD]

PRD generated successfully!
File: docs/prds/2025-12-01-fix-logout-cookie.md
Type: Lite PRD
Security Sensitive: Yes (session handling)

Next steps:
- Create issues: `/create-issues docs/prds/2025-12-01-fix-logout-cookie.md --immediate`
```

---

## Notes

- **Parallel research:** Learnings + codebase patterns researched before generating content
- **Brainstorm integration:** Recent brainstorm decisions auto-incorporated if found
- **Spec-flow analysis:** Systematic gap detection for user flows, error states, and edge cases
- **Lite vs Full**: Use Lite for small tasks, Full for complex features
- **Security auto-detection**: PRD automatically flags security-sensitive features
- **Exploration integration**: Uses `/explore` output if available in conversation
- **Filename convention**: Date prefix allows chronological sorting
- **Status starts as READY_FOR_REVIEW**: Human approval required before implementation

---

## Post-Completion Flow

After generating the PRD, present next options using `AskUserQuestion`:

```
AskUserQuestion:
  question: "PRD generated. What would you like to do next?"
  header: "Next step"
  options:
    - label: "Run /deepen-plan"
      description: "Enrich the PRD with parallel research agents (10-20+)"
    - label: "Run /review-plan"
      description: "Run multi-agent plan review with adversarial validation"
    - label: "Run /create-issues"
      description: "Generate GitHub issues directly from this PRD"
    - label: "Done"
      description: "End workflow — PRD saved for later use"
```

Based on user's selection, invoke the chosen command with the PRD file path.
