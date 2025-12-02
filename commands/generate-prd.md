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

- `--lite` - Generate Lite PRD (small-to-medium tasks, <4 hours)
- `--full` - Generate Full PRD (complex features, >4 hours)
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
  📄 PRD Generation

  What feature would you like to document?

  Feature description: _____
  ```

### Step 2: Determine PRD type (Lite or Full)

**Auto-detection criteria:**
- Lite PRD (<4 hours):
  - Small bug fixes
  - Minor feature additions
  - Simple refactoring
  - Single-file changes

- Full PRD (>4 hours):
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
  1. Lite (<4 hours) - Quick format
  2. Full (>4 hours) - Comprehensive format

  Your choice [2]: _____
  ```

### Step 3: Generate PRD using appropriate template

**Load template:**
- Read `~/.claude/PRD_TEMPLATE.md`
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
- (See `~/.claude/templates/TEST_STRATEGY.md` for details)

**Security Review:** [Y/N based on security triggers]
- If yes, use `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md`

**Estimated Effort:** [X hours]

**Risks:** [Key risk, if any]

**Status:** READY_FOR_REVIEW
```

**For Full PRD:**
- Complete all 10 sections from template:
  - Document Info (Title, Author, Date, Status, Priority, Type)
  - Exploration Summary (use `/explore` output if available)
  - Problem (what, who, evidence)
  - Goals (goals, non-goals, success metrics)
  - Solution (overview, key features, user flow)
  - Technical Approach (architecture, decisions, dependencies)
  - Implementation Plan (phases with deliverables and acceptance criteria)
  - Test Strategy (unit, integration, E2E, security, performance)
  - Risks (likelihood, impact, mitigation)
  - Security Review (if applicable)
  - Open Questions
  - Future Considerations

**Auto-populate exploration data:**
- If `/explore` was run previously in conversation, use findings
- Otherwise, mark Exploration Summary as "To be completed"

**Auto-detect security sensitivity:**
Check if feature involves:
- Authentication/authorization
- PII/sensitive data
- External APIs
- User input processing
- File uploads
- Database queries with user input

If yes: Flag as `SECURITY_SENSITIVE` and mark security review as MANDATORY

### Step 4: Generate filename and save PRD

**Filename format:** `docs/prds/YYYY-MM-DD-feature-name.md`
- YYYY-MM-DD: Current date
- feature-name: Slugified version of feature title (lowercase, hyphens)

**Example:**
- Feature: "OAuth 2.0 Authentication"
- Date: 2025-12-01
- Filename: `docs/prds/2025-12-01-oauth-authentication.md`

**Important:** This filename format is temporary. When `/create-issues` creates GitHub issues from this PRD, the file will be renamed to include the first issue number as a prefix (e.g., `123-2025-12-01-oauth-authentication.md`). See `/create-issues` documentation for details.

**Create directory if needed:**
```bash
mkdir -p docs/prds
```

**Save file:**
- Write PRD content to file
- Set status to `READY_FOR_REVIEW`

### Step 5: Report file location and suggest next step

```
✅ PRD generated successfully!

File: docs/prds/2025-12-01-oauth-authentication.md
Type: Full PRD
Status: READY_FOR_REVIEW
Priority: High
Security Sensitive: Yes

Next steps:
- Review PRD and approve
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
- Estimated Effort: X hours

**Suggested next steps:**
- "Review PRD, then run `/create-issues` to generate GitHub issues"
- Or: "Create ADR for architectural decisions: `/create-adr`"

---

## References

- See: `~/.claude/PRD_TEMPLATE.md` for PRD template structure
- See: `~/.claude/templates/TEST_STRATEGY.md` for test planning
- See: `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` for security review
- See: `~/.claude/templates/ADR_TEMPLATE.md` for architecture decisions
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 0 Step 2 for PRD best practices

---

## Example Usage

**Example 1: Interactive mode**
```
User: /generate-prd

Claude: 📄 PRD Generation

What feature would you like to document?

Feature description: _____

User: Add password reset functionality via email

Claude: Based on description, recommending: Full PRD
(Security-sensitive: email handling, password reset tokens)

PRD type:
1. Lite (<4 hours) - Quick format
2. Full (>4 hours) - Comprehensive format

Your choice [2]: _____

User: 2

Claude: [Generates Full PRD with all 10 sections]

✅ PRD generated successfully!

File: docs/prds/2025-12-01-password-reset.md
Type: Full PRD
Status: READY_FOR_REVIEW
Priority: High
Security Sensitive: Yes (email tokens, password handling)

Next steps:
- Review PRD and approve
- Create GitHub issues: `/create-issues docs/prds/2025-12-01-password-reset.md`
```

**Example 2: Direct mode (Lite)**
```
User: /generate-prd --lite "Fix bug where logout button doesn't clear session cookie"

Claude: [Immediately generates Lite PRD]

✅ PRD generated successfully!

File: docs/prds/2025-12-01-fix-logout-cookie.md
Type: Lite PRD
Status: READY_FOR_REVIEW
Priority: Medium
Estimated Effort: 2 hours
Security Sensitive: Yes (session handling)

Next steps:
- Review PRD and approve
- Create GitHub issues: `/create-issues docs/prds/2025-12-01-fix-logout-cookie.md --immediate`
```

**Example 3: Direct mode (Full) with exploration context**
```
# Assumes /explore was run previously
User: /explore authentication system

Claude: [Exploration completed with findings]

User: /generate-prd --full "Add OAuth 2.0 support (Google, GitHub providers)"

Claude: [Generates Full PRD, auto-populates Exploration Summary with findings from /explore]

✅ PRD generated successfully!

File: docs/prds/2025-12-01-oauth-support.md
Type: Full PRD
Status: READY_FOR_REVIEW
Priority: High
Security Sensitive: Yes (OAuth flow, token handling)
Estimated Effort: 12-16 hours

Exploration Summary: ✅ Auto-populated from /explore output

Next steps:
- Review PRD and approve
- Create ADR for OAuth provider selection: `/create-adr`
- Create GitHub issues: `/create-issues docs/prds/2025-12-01-oauth-support.md`
```

---

## Notes

- **Lite vs Full**: Use Lite for <4 hour tasks, Full for complex features
- **Security auto-detection**: PRD automatically flags security-sensitive features
- **Exploration integration**: Uses `/explore` output if available in conversation
- **Filename convention**: Date prefix allows chronological sorting
- **Status starts as READY_FOR_REVIEW**: Human approval required before implementation
- **PRD versioning**: After first GitHub issue is created, PRD will be renamed to include issue number (e.g., `123-2025-12-01-feature-name.md`)
