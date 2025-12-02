# /finalize

**Description:** Final documentation and validation before merge

**When to use:**
- After PR created and code review complete
- Before final merge to main/production
- Want comprehensive final checks
- GODMODE Phase 2 Step 2 (final step)

**Prerequisites:**
- PR created (`/commit-and-pr` completed)
- Code review approved (or self-reviewing before merge)

---

## Invocation

**Interactive mode:**
User types `/finalize` with no arguments. Claude asks which finalization steps to run.

**Direct mode:**
User types `/finalize --all` to run all finalization steps.

---

## Arguments

- `--all` - Run all finalization steps (README, CHANGELOG, API docs, comments, final test)

---

## Execution Steps

### Step 1: Check if documentation updates needed

**Scan changes for documentation triggers:**

**README update needed if:**
- Public API changed (new functions exported)
- CLI commands added/changed
- Configuration options changed
- Installation steps changed
- New dependencies added

**CHANGELOG update needed if:**
- Any user-facing changes
- Bug fixes
- New features
- Breaking changes

**API docs update needed if:**
- OpenAPI/Swagger spec exists
- API endpoints added/modified/removed

**Ask user which to update:**
```
✨ Finalization

Documentation updates needed:

1. Update README? (Public API changed)
2. Generate CHANGELOG entry? (New feature added)
3. Update API docs (OpenAPI spec)? (Endpoints modified)
4. Add WHY comments to complex code? (Some complex logic found)
5. Run final test suite? (Always recommended)

Select steps (1,2,3,4,5 or 'all'): _____
```

### Step 2: Update README (if selected)

**If README update needed:**

**Read current README:**
```bash
cat README.md
```

**Identify sections to update:**
- Installation (if new dependencies)
- Usage (if new commands/APIs)
- API Reference (if public API changed)
- Configuration (if config changed)

**Generate updated sections:**
```markdown
## Installation

```bash
npm install
# New dependency added:
npm install passport passport-google-oauth20
```

## Usage

```javascript
// New API
import { AuthService } from './auth/AuthService'

const auth = new AuthService()
await auth.loginWithGoogle(code)
```
```

**Show diff and ask for confirmation:**
```
README.md updates:

+ Added OAuth authentication to Usage section
+ Added passport dependencies to Installation

Apply updates? (yes/no): _____
```

**If yes, apply updates:**
- Edit README.md with new content

### Step 3: Generate CHANGELOG entry (if selected)

**If CHANGELOG update needed:**

**Read current CHANGELOG:**
```bash
cat CHANGELOG.md
# or
cat CHANGELOG
```

**Generate entry from commit messages and PR:**
- Version: Detect from package.json or ask user
- Date: Today's date
- Changes: From commit messages and PR description

**CHANGELOG format (Keep a Changelog):**
```markdown
## [1.2.0] - 2025-12-01

### Added
- OAuth 2.0 authentication support for Google and GitHub providers
- Token refresh mechanism for expired access tokens

### Changed
- Updated AuthService to use new OAuth flow

### Security
- Implemented secure token storage with encryption
- Added rate limiting for authentication endpoints

### Fixed
- None
```

**Show entry and ask for confirmation:**
```
CHANGELOG entry:

## [1.2.0] - 2025-12-01

### Added
- OAuth 2.0 authentication support

[... full entry ...]

Add this entry? (yes/no): _____
```

**If yes:**
- Prepend entry to CHANGELOG.md (new entries at top)

### Step 4: Update API docs (if selected)

**If OpenAPI spec exists:**

**Detect OpenAPI file:**
```bash
find . -name "openapi.yaml" -o -name "swagger.yaml" -o -name "api-spec.yaml"
```

**If API endpoints changed:**
- Update OpenAPI spec with new/modified endpoints
- Update request/response schemas
- Update authentication schemes if changed

**Example update:**
```yaml
paths:
  /auth/google:
    post:
      summary: Authenticate with Google OAuth
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                code:
                  type: string
                  description: Google OAuth authorization code
      responses:
        '200':
          description: Authentication successful
          content:
            application/json:
              schema:
                type: object
                properties:
                  token:
                    type: string
                  user:
                    $ref: '#/components/schemas/User'
```

**Show changes:**
```
API docs updates:

+ Added /auth/google endpoint
+ Added /auth/github endpoint

Apply? (yes/no): _____
```

### Step 5: Add WHY comments to complex code (if selected)

**Scan code for complex logic:**
- Functions with cyclomatic complexity >5
- Non-obvious algorithms
- Workarounds or hacks
- Performance optimizations

**For each complex section, add WHY comment:**

**Before:**
```typescript
// Complex token refresh logic
if (token.expiresAt < Date.now() && refreshToken) {
  const newToken = await this.refreshAccessToken(refreshToken)
  token = newToken
}
```

**After:**
```typescript
// WHY: Access tokens expire after 15min for security. We automatically
// refresh using the refresh token to maintain user session without
// requiring re-authentication. Refresh tokens are valid for 30 days.
if (token.expiresAt < Date.now() && refreshToken) {
  const newToken = await this.refreshAccessToken(refreshToken)
  token = newToken
}
```

**Show proposed comments:**
```
WHY comments to add:

1. src/auth/AuthService.ts:67 - Token refresh logic
2. src/middleware/rateLimit.ts:23 - Sliding window rate limiting

Add these comments? (yes/no): _____
```

### Step 6: Run final test suite

**Execute comprehensive test suite:**
```bash
npm test
npm run test:integration  # if exists
npm run test:e2e         # if exists
```

**Also run:**
- Linter: `npm run lint`
- Type check: `tsc --noEmit` (if TypeScript)
- Build: `npm run build` (verify build succeeds)

**Report results:**
```
Final Test Suite Results:

Unit Tests: 24/24 passing ✅
Integration Tests: 8/8 passing ✅
Linter: No errors ✅
Type Check: No errors ✅
Build: Successful ✅

All checks passed!
```

**If any failures:**
```
❌ Final tests failed!

Failed:
- Integration test: test_oauth_flow_end_to_end

Fix failures before merging.
```

### Step 7: Generate finalization report

```
✨ Finalization Complete!

Documentation updated:
✅ README.md - Added OAuth usage section
✅ CHANGELOG.md - Added v1.2.0 entry
✅ openapi.yaml - Added OAuth endpoints
✅ WHY comments - Added 2 explanatory comments

Final validation:
✅ Unit tests: 24/24 passing
✅ Integration tests: 8/8 passing
✅ Linter: Clean
✅ Build: Successful

Status: READY_TO_MERGE

Next steps:
1. Commit documentation updates (if any)
2. Merge PR on GitHub
3. Issue #123 will auto-close on merge
4. Deploy to production (if applicable)
```

### Step 8: Commit documentation updates (if any)

**If documentation was updated:**
```bash
git add README.md CHANGELOG.md openapi.yaml src/**/*.ts
git commit -m "docs: update documentation for OAuth feature

- Updated README with OAuth usage
- Added CHANGELOG entry for v1.2.0
- Updated OpenAPI spec with OAuth endpoints
- Added WHY comments to complex token refresh logic

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push
```

---

## Output

**Documentation updates:**
- README.md (if updated)
- CHANGELOG.md (if updated)
- API docs (if updated)
- WHY comments added

**Final validation results:**
- All tests passing
- Linter clean
- Build successful

**Status:** `READY_TO_MERGE`

**Suggested next steps:**
- "Merge PR on GitHub"
- "Deploy to production"

---

## References

- See: [Keep a Changelog](https://keepachangelog.com/) for CHANGELOG format
- See: [README best practices](https://www.makeareadme.com/)
- See: [OpenAPI Specification](https://swagger.io/specification/)

---

## Example Usage

**Example 1: Full finalization**
```
User: /finalize --all

Claude: Running all finalization steps...

✅ README updated
✅ CHANGELOG entry added
✅ API docs updated
✅ WHY comments added (2)
✅ Final tests passing

Status: READY_TO_MERGE

Committing documentation updates...

Done! Merge PR when ready.
```

**Example 2: Selective finalization**
```
User: /finalize

Claude: Select steps:
1. README
2. CHANGELOG
3. API docs
4. WHY comments
5. Final tests

Your choice: 2,5

[Updates CHANGELOG and runs final tests]

✅ Finalization complete!
```

**Example 3: No updates needed**
```
User: /finalize

Claude: ✨ Finalization

No documentation updates needed.

Running final tests...

✅ All tests passing

Status: READY_TO_MERGE

Merge PR when ready!
```

---

## Notes

- **README updates:** Only if public API or usage changed
- **CHANGELOG:** Follow Keep a Changelog format
- **API docs:** Update OpenAPI/Swagger spec if exists
- **WHY comments:** Explain complex/non-obvious code
- **Final tests:** Comprehensive check before merge
- **Commit docs separately:** Documentation updates in separate commit
- **Optional step:** Finalization is optional but recommended
- **Ready to merge:** After finalization, code is ready for production
