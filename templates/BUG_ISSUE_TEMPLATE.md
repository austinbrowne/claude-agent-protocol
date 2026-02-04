# Bug Issue Template

This template is used by `/file-issues` for bug reports. Filed sparse initially, enriched later via `/enhance-issue`.

---

## Issue Title
[Short description of the bug in imperative mood, e.g. "Fix crash when submitting empty form"]

## Bug Description
[What is happening? Brief description of the incorrect behavior.]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens — include error messages, stack traces, screenshots if available]

## Environment
- **OS/Browser:** [e.g. macOS 15, Chrome 130]
- **Version/Branch:** [e.g. v2.3.1, main]
- **Other context:** [e.g. only happens with large datasets]

## Severity
[critical | high | medium | low]

- **Critical:** System down, data loss, security breach
- **High:** Major feature broken, no workaround
- **Medium:** Feature impaired, workaround exists
- **Low:** Cosmetic, minor inconvenience

## Affected Area
[frontend | backend | infrastructure | API | database | auth | other]

## Root Cause Hypothesis
[TBD — filled during /enhance-issue]

## Affected Files
[TBD — filled during /enhance-issue]

## Acceptance Criteria
- [ ] Bug no longer reproducible following steps above
- [ ] Regression test added covering this scenario
- [ ] [Additional criteria — filled during /enhance-issue]

## Technical Requirements
[TBD — filled during /enhance-issue]

## Testing Notes
**Regression Test:**
[Test that reproduces the bug before fix, passes after]

**Edge Cases:**
[Related edge cases to verify — filled during /enhance-issue]

## Security Considerations
[N/A unless bug involves auth, data exposure, or injection — filled during /enhance-issue]

## Related Issues
- Related: #[issue number]

## Labels
**Type:** bug
**Priority:** [critical | high | medium | low]
**Status:** needs_refinement
**Area:** [frontend | backend | infrastructure | API | database | auth]

## Definition of Done
- [ ] Bug fixed and no longer reproducible
- [ ] Regression test written and passing
- [ ] Edge cases handled
- [ ] Security review completed (if applicable)
- [ ] No new vulnerabilities introduced
