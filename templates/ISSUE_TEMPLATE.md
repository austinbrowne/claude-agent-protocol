# Issue Template

This template is used by `/create-issues` to generate well-structured issues for AI-assisted development.

---

## Issue Title
[Clear, descriptive title in imperative mood, 5-10 words]

## Description
[Thorough description of what needs to be built/changed and why. Include context from the plan, user needs being addressed, and how this fits into the larger system.]

## User Story
As a [type of user]
I want [goal/desire]
So that [benefit/value]

## Acceptance Criteria
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]
[Continue as needed - be comprehensive]

## Technical Requirements
[Detailed technical specifications, architecture decisions, technologies to use, patterns to follow]

## Testing Notes
**Unit Tests:**
[What needs unit test coverage]

**Integration Tests:**
[What integration scenarios to test]

**Edge Cases:**
[Specific edge cases to handle and test - null, empty, boundaries, error conditions]

**Security Tests:**
[If applicable - auth, input validation, XSS, SQL injection, etc.]

## Developer Notes
[Important implementation details, gotchas, related code locations, dependencies, suggested approach]

## Performance Considerations
[Performance requirements, scalability concerns, optimization opportunities, or "N/A" if not performance-critical]

## Security Considerations
[Security implications, authentication/authorization needs, data protection requirements, or "N/A" if not security-sensitive]

**If security-sensitive, must complete:**
- [ ] Review `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` before implementation
- [ ] Complete OWASP Top 10 2025 checklist items

## Plan Reference

**Source plan:** `docs/plans/NNN-YYYY-MM-DD-type-feature-name-plan.md`

**Example:** `docs/plans/123-2026-02-04-standard-user-authentication-plan.md`
- `123` = This issue number
- `2026-02-04` = Date plan was created
- `standard` = Plan tier (minimal/standard/comprehensive)
- `user-authentication` = Feature name

**Purpose:**
- Reference for broader context if needed during implementation
- Historical record linking issue to original requirements
- Source of tradeoffs and architectural decisions
- Issue number in filename creates direct link to implementation

**When to reference:**
- Issue context unclear
- Need architectural rationale
- Checking alignment with requirements
- Understanding why certain approaches were chosen

## Related Issues
[Links to dependent or related issues]
- Depends on: #[issue number]
- Blocks: #[issue number]
- Related: #[issue number]

## Labels
**Type:** [bug | feature | enhancement | docs | refactor | test | infrastructure]
**Priority:** [critical | high | medium | low]
**Status:** [ready | blocked]
**Area:** [frontend | backend | infrastructure | security | testing]
**Flags:** [security-sensitive | performance-critical | breaking-change] (if applicable)

## Estimated Effort
[X hours/days based on complexity]

## Claude Code Assignment
**Option 1 - Immediate:** Tag @claude in issue comments to assign
**Option 2 - Manual:** Pick from project board and reference issue number in Claude Code session

## Definition of Done
- [ ] Code implemented following existing patterns
- [ ] All acceptance criteria met
- [ ] Tests written and passing (unit + integration + edge cases)
- [ ] Security review completed (if applicable)
- [ ] Performance requirements met (if applicable)
- [ ] Code reviewed (self-review using `~/.claude/checklists/AI_CODE_REVIEW.md`)
- [ ] Documentation updated (README, API docs, ADR if architectural)
- [ ] No vulnerabilities introduced (`npm audit` or equivalent clean)
- [ ] Edge cases handled (null, empty, boundaries, errors)
