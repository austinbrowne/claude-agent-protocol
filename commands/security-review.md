---
description: Run security checklist review on code changes
---

# /security-review

**Description:** Run security checklist review on code changes

**When to use:**
- Code involves authentication, authorization, or user input
- Handling sensitive data (PII, passwords, tokens, API keys)
- Database queries with user input
- External API calls
- File uploads
- Issue or PRD flagged as `SECURITY_SENSITIVE`
- GODMODE Phase 1 Step 4 (after implementation, before validation)

**Prerequisites:**
- Code changes exist (git diff shows modifications)

---

## Invocation

**Interactive mode:**
User types `/security-review` with no arguments. Claude auto-detects security triggers.

**Direct mode:**
Same as interactive (no arguments needed - automatically analyzes diff).

---

## Arguments

None - command auto-detects security-sensitive code from git diff.

---

## Execution Steps

### Step 1: Analyze git diff for security triggers

**Get code changes:**
```bash
git diff HEAD
git diff --staged
```

**Scan for security triggers:**
- **Auth/authz keywords:** authenticate, authorize, login, logout, token, jwt, session, password, credentials
- **Data handling:** encrypt, decrypt, hash, bcrypt, pbkdf2, PII, SSN, credit_card
- **Database:** query, execute, raw SQL, WHERE, INSERT, UPDATE, DELETE
- **User input:** req.body, req.query, req.params, input, form, POST, PUT
- **File operations:** upload, fs.write, file_put_contents, save_file
- **External APIs:** fetch, axios, http.request, api_call
- **Sensitive env:** process.env, API_KEY, SECRET, PASSWORD

**If NO triggers found:**
```
ℹ️  No security-sensitive code detected in changes.

Security review not required for these changes.

Next steps:
- Run validation: `/run-validation`
```

**If triggers found:**
```
🔒 Security-sensitive code detected!

Triggers found:
✅ Authentication code (src/auth/AuthService.ts)
✅ User input processing (src/api/users.ts)
✅ Database queries (src/models/User.ts)

Running security review checklist...
```

### Step 2: Load security checklist

**Read:** `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md`

**Checklist categories:**
1. **Authentication & Authorization (OWASP A01)**
2. **Cryptographic Failures (OWASP A02)**
3. **Injection (OWASP A03)**
4. **Insecure Design (OWASP A04)**
5. **Security Misconfiguration (OWASP A05)**
6. **Vulnerable Components (OWASP A06)**
7. **Identification & Authentication Failures (OWASP A07)**
8. **Software & Data Integrity Failures (OWASP A08)**
9. **Logging & Monitoring Failures (OWASP A09)**
10. **Server-Side Request Forgery (OWASP A10)**

### Step 3: Run applicable checklist items

**For each triggered category:**

**Example: Authentication code triggers A01 + A07**

**A01: Authentication & Authorization:**
- [ ] Password hashing uses bcrypt/argon2 (NOT md5/sha1)
- [ ] Password minimum length enforced (≥12 chars)
- [ ] Rate limiting on login attempts
- [ ] Session tokens cryptographically random
- [ ] Auth bypass impossible (all routes protected)

**A07: Identification & Authentication Failures:**
- [ ] No hardcoded credentials
- [ ] Passwords never logged or exposed in errors
- [ ] Multi-factor authentication available for sensitive actions
- [ ] Session invalidation on logout

**Example: Database queries trigger A03 (Injection)**

**A03: Injection:**
- [ ] All queries use parameterized statements (NOT string concatenation)
- [ ] No raw SQL with user input
- [ ] Input validation before database operations
- [ ] ORM used correctly (no .raw() with user input)
- [ ] NoSQL injection prevented (sanitize MongoDB queries)

**Example: User input processing triggers A03 + A04**

**A03: Injection (XSS, Command Injection):**
- [ ] User input sanitized/escaped before output
- [ ] No eval() or exec() with user input
- [ ] No shell commands with user input
- [ ] HTML entities escaped in templates

**A04: Insecure Design:**
- [ ] Input validation on server side (never trust client)
- [ ] Whitelist validation (NOT blacklist)
- [ ] Business logic checks prevent abuse

### Step 4: Check each item against code

**For each checklist item:**
- Grep code for relevant patterns
- Example: Search for `SELECT.*${` to find SQL injection risks
- Example: Search for `password.*=.*'` to find hardcoded passwords
- Example: Search for `bcrypt|argon2` to verify password hashing

**Mark each item:**
- ✅ PASS - Requirement met
- ❌ FAIL - Vulnerability found
- ⚠️  WARNING - Potential issue, needs review
- ➖ N/A - Not applicable to this code

### Step 5: Generate security findings report

**Findings format:**

```
🔒 Security Review Results

=== CRITICAL ISSUES (must fix) ===
❌ [A03] SQL Injection risk in src/api/users.ts:45
   Found: `db.query(\`SELECT * FROM users WHERE id = ${userId}\`)`
   Fix: Use parameterized query: `db.query('SELECT * FROM users WHERE id = ?', [userId])`

=== HIGH PRIORITY ISSUES ===
⚠️  [A02] Weak password hashing in src/auth/AuthService.ts:23
   Found: SHA256 used for password hashing
   Fix: Replace with bcrypt or argon2

=== MEDIUM PRIORITY ISSUES ===
⚠️  [A05] API key in source code in src/config/api.ts:12
   Found: `const API_KEY = 'hardcoded-key-123'`
   Fix: Move to environment variable

=== LOW PRIORITY / WARNINGS ===
⚠️  [A09] No audit logging for failed login attempts
   Recommendation: Add logging for security events

=== PASSED CHECKS ===
✅ [A01] Authentication uses secure token generation
✅ [A03] Database queries use parameterized statements (3/4 queries)
✅ [A04] Input validation present on all endpoints
✅ [A07] No hardcoded passwords found
```

### Step 6: Set SECURITY_SENSITIVE flag if needed

**If CRITICAL or HIGH issues found:**
- Set flag: `SECURITY_SENSITIVE`
- Recommendation: "Fix CRITICAL/HIGH issues before proceeding"

**If only MEDIUM/LOW issues:**
- Flag: `SECURITY_REVIEWED`
- Recommendation: "Address issues, but can proceed with caution"

**If all checks pass:**
- Flag: `SECURITY_APPROVED`
- Recommendation: "Security review passed, proceed to validation"

### Step 7: Suggest next steps

```
Next steps:
- Fix CRITICAL/HIGH issues immediately
- Re-run security review: `/security-review`
- After fixes, run validation: `/run-validation`
- If unfixable, consider recovery: `/recovery`
```

---

## Output

**Security findings report:**
- CRITICAL issues (must fix)
- HIGH priority issues
- MEDIUM priority issues
- LOW priority/warnings
- Passed checks

**Severity breakdown:**
- N CRITICAL, N HIGH, N MEDIUM, N LOW

**Security flag:**
- `SECURITY_SENSITIVE` - Has unfixed issues
- `SECURITY_REVIEWED` - Issues noted, can proceed
- `SECURITY_APPROVED` - All checks passed

**Suggested next steps:**
- "Fix CRITICAL/HIGH issues, then run `/run-validation`"
- Or: "Security review passed, proceed to `/run-validation`"

---

## References

- See: `~/.claude/checklists/AI_CODE_SECURITY_REVIEW.md` for full security checklist
- See: [OWASP Top 10 2025](https://owasp.org/www-project-top-ten/)
- See: `~/.claude/AI_CODING_AGENT_GODMODE.md` Phase 1 Step 4 for security review process

---

## Example Usage

**Example 1: Security issues found**
```
User: /security-review

Claude: 🔒 Security-sensitive code detected!

Triggers:
✅ Authentication code (src/auth/AuthService.ts)
✅ Database queries (src/models/User.ts)

Running security checklist...

🔒 Security Review Results

=== CRITICAL ISSUES ===
❌ [A03] SQL Injection in src/models/User.ts:45
   Found: db.query(\`SELECT * FROM users WHERE id = ${id}\`)
   Fix: Use parameterized query

=== HIGH PRIORITY ===
⚠️  [A02] Weak password hashing in src/auth/AuthService.ts:23
   Found: SHA256
   Fix: Use bcrypt or argon2

=== PASSED ===
✅ [A01] Secure token generation
✅ [A07] No hardcoded credentials

Severity: 1 CRITICAL, 1 HIGH, 0 MEDIUM, 0 LOW

Flag: SECURITY_SENSITIVE

Next steps:
- Fix CRITICAL/HIGH issues immediately
- Re-run: `/security-review`
```

**Example 2: All checks passed**
```
User: /security-review

Claude: 🔒 Security-sensitive code detected!

Triggers:
✅ Authentication code (src/auth/AuthService.ts)

Running security checklist...

🔒 Security Review Results

=== PASSED ===
✅ [A01] Bcrypt password hashing
✅ [A03] Parameterized queries
✅ [A04] Input validation
✅ [A07] No hardcoded credentials
✅ [A05] Secrets in environment variables

Severity: 0 CRITICAL, 0 HIGH, 0 MEDIUM, 0 LOW

Flag: SECURITY_APPROVED

✅ Security review passed!

Next steps:
- Run validation: `/run-validation`
```

**Example 3: No security-sensitive code**
```
User: /security-review

Claude: ℹ️  No security-sensitive code detected.

Changes:
- src/utils/formatDate.ts (utility function)
- src/components/Button.tsx (UI component)

Security review not required.

Next steps:
- Run validation: `/run-validation`
```

---

## Notes

- **Auto-detection:** Scans git diff for security keywords and patterns
- **OWASP Top 10 2025:** Checklist based on latest OWASP recommendations
- **Severity levels:** CRITICAL (must fix), HIGH (should fix), MEDIUM (address soon), LOW (consider)
- **Automated checks:** Grep patterns for common vulnerabilities
- **Manual review needed:** Some items require human judgment
- **Re-run after fixes:** Run `/security-review` again after fixing issues
- **Not a replacement for pentest:** This is code review, not penetration testing
- **False positives possible:** Review warnings carefully, may not all be real issues
