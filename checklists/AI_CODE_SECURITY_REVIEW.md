# AI-Generated Code Security Review Checklist

**Purpose:** Ensure AI-generated code meets security standards and doesn't introduce vulnerabilities.

**Context:** Research shows **45% of AI-generated code contains OWASP Top-10 flaws**. This checklist provides mandatory security gates for all AI-generated code.

**When to Use:** Phase 1.5 of execution loop (after implementation, before validation)

---

## OWASP Top 10 2025 Coverage

### A01: Broken Access Control
- [ ] **Authorization checks present:** Every protected resource has authorization logic
- [ ] **Horizontal privilege escalation prevented:** Users can't access other users' data
- [ ] **Vertical privilege escalation prevented:** Regular users can't perform admin actions
- [ ] **Direct object references are indirect:** IDs are mapped through user session, not directly accessible
- [ ] **CORS configured correctly:** Only whitelisted origins allowed
- [ ] **Default deny:** Access denied unless explicitly permitted

### A02: Cryptographic Failures
- [ ] **No hardcoded secrets:** No API keys, passwords, tokens in code
- [ ] **Sensitive data encrypted at rest:** Database fields with PII/financial data encrypted
- [ ] **Sensitive data encrypted in transit:** HTTPS enforced, no HTTP fallback
- [ ] **Strong encryption algorithms:** AES-256, RSA-2048+, no MD5/SHA1
- [ ] **Secrets management used:** Environment variables or secret manager (AWS Secrets Manager, Vault)
- [ ] **No sensitive data in logs:** Passwords, tokens, credit cards not logged
- [ ] **No sensitive data in URLs:** Query params don't contain secrets

### A03: Software Supply Chain Failures ⚡ NEW 2025
- [ ] **All dependencies scanned:** `npm audit`, `pip-audit`, or equivalent run
- [ ] **No critical vulnerabilities:** Zero high/critical CVEs in dependencies
- [ ] **Dependency provenance verified:** Using lockfiles (package-lock.json, poetry.lock)
- [ ] **Minimal dependencies:** Only necessary packages added
- [ ] **Dependencies are maintained:** Last update within 12 months
- [ ] **License compliance checked:** Compatible licenses (MIT, Apache, BSD)
- [ ] **Dependency review approved:** Human reviewed all new/updated dependencies

### A04: Injection
- [ ] **SQL injection prevented:** Parameterized queries or ORM used, no string concatenation
- [ ] **NoSQL injection prevented:** Input sanitized for MongoDB, etc.
- [ ] **Command injection prevented:** No shell commands with user input, or sanitized via allowlist
- [ ] **LDAP injection prevented:** Input escaped if using LDAP
- [ ] **XPath/XML injection prevented:** XML parser configured securely
- [ ] **Template injection prevented:** Template engine auto-escapes, user input not in templates

### A05: Security Misconfiguration
- [ ] **No default credentials:** All default passwords changed
- [ ] **Error messages don't leak info:** Stack traces not shown to users
- [ ] **Security headers configured:** CSP, X-Frame-Options, X-Content-Type-Options set
- [ ] **Unnecessary features disabled:** Debug mode off, unused endpoints removed
- [ ] **Framework security features enabled:** Helmet.js, Django security middleware, etc.
- [ ] **Cloud security groups configured:** Minimal ports open, IP restrictions

### A06: Vulnerable and Outdated Components
- [ ] **Components up to date:** Dependencies at latest stable versions
- [ ] **EOL components replaced:** No end-of-life software (Python 2, Node 12, etc.)
- [ ] **Vulnerability monitoring enabled:** Dependabot, Snyk, or equivalent

### A07: Identification and Authentication Failures
- [ ] **Weak passwords rejected:** Minimum 12 chars, complexity requirements
- [ ] **Multi-factor authentication supported:** MFA available for sensitive accounts
- [ ] **Session tokens secure:** HttpOnly, Secure, SameSite cookies
- [ ] **Session timeout configured:** Idle timeout enforced
- [ ] **Credential stuffing prevention:** Rate limiting on login endpoints
- [ ] **Password recovery secure:** Tokens expire, sent over secure channel
- [ ] **No credentials in code/repos:** `.env` files in `.gitignore`

### A08: Software and Data Integrity Failures
- [ ] **Code integrity verified:** Subresource Integrity (SRI) for CDN resources
- [ ] **Deserialization safe:** No `pickle.loads()` on untrusted data, use JSON
- [ ] **CI/CD pipeline secured:** No secrets in build logs, signed commits
- [ ] **Auto-update mechanism secure:** Updates signed and verified

### A09: Security Logging and Monitoring Failures
- [ ] **Authentication events logged:** Login success/failure, password changes
- [ ] **Authorization failures logged:** Access denied events
- [ ] **Input validation failures logged:** Malformed requests tracked
- [ ] **Logs are tamper-proof:** Centralized logging (CloudWatch, Datadog, Splunk)
- [ ] **Alerting configured:** Critical events trigger alerts
- [ ] **No sensitive data in logs:** See A02 above

### A10: Mishandling of Exceptional Conditions ⚡ NEW 2025
- [ ] **All exceptions caught:** Try/catch blocks around risky operations
- [ ] **Graceful degradation:** Errors don't crash the app
- [ ] **Error messages are safe:** No stack traces, file paths, or DB schemas exposed
- [ ] **Retry logic has limits:** Exponential backoff, max retries
- [ ] **Resource exhaustion prevented:** Timeouts on external calls, connection pools limited
- [ ] **Default error handlers override framework defaults:** Custom 404, 500 pages

---

## Additional AI-Specific Checks

### Input Validation (AI often misses edge cases)
- [ ] **Allowlist validation:** Prefer allowlist over blocklist
- [ ] **Length limits enforced:** Max length on strings, array sizes
- [ ] **Type validation:** Numbers are numbers, emails are emails
- [ ] **Range validation:** Dates, numbers within expected ranges
- [ ] **Format validation:** Regex for phone numbers, postal codes, etc.
- [ ] **File upload validation:** Type, size, content checks (magic bytes)
- [ ] **Null/undefined handled:** No `Cannot read property of undefined` crashes

### Output Encoding (XSS vulnerabilities)
- [ ] **HTML context encoded:** `<script>` becomes `&lt;script&gt;`
- [ ] **JavaScript context encoded:** User input in JS strings escaped
- [ ] **URL context encoded:** `encodeURIComponent()` used
- [ ] **CSS context validated:** User input not in style attributes
- [ ] **JSON responses safe:** `Content-Type: application/json` header set
- [ ] **Framework auto-escaping enabled:** React, Vue, Angular escape by default

### Authentication & Authorization (High-risk, requires human review)
- [ ] **Human reviewed all auth code:** AI-generated auth code must be reviewed by senior dev
- [ ] **Principle of least privilege:** Users/services have minimum necessary permissions
- [ ] **Defense in depth:** Multiple layers of security (WAF, app-level, DB-level)

### External API Integration
- [ ] **API keys in environment variables:** Never in code
- [ ] **Rate limiting implemented:** Prevent abuse of our API
- [ ] **Rate limiting respected:** Don't hammer external APIs
- [ ] **Timeouts configured:** External calls fail fast (5-30s max)
- [ ] **Circuit breaker pattern:** Degraded gracefully when external service down
- [ ] **Input from external APIs validated:** Don't trust external data

### Data Handling
- [ ] **PII identified:** Personal Identifiable Information documented
- [ ] **PII minimization:** Only collect what's necessary
- [ ] **Data retention policy:** Delete old data per policy
- [ ] **GDPR/CCPA compliance:** Right to be forgotten implemented if applicable
- [ ] **Database migrations reversible:** Down migrations exist

---

## Risk Assessment

| Risk Level | Action Required |
|------------|-----------------|
| **CRITICAL** | Block deployment, fix immediately |
| **HIGH** | Must fix before merge to main |
| **MEDIUM** | Fix within 1 sprint |
| **LOW** | Add to backlog |

**If any checkbox above is unchecked and applies to the code:**
- Mark as `SECURITY_SENSITIVE` flag
- Request human review before proceeding
- Document findings in ADR if architectural

---

## Automated Tools (Run These)

```bash
# JavaScript/TypeScript
npm audit --audit-level=moderate
npm run lint:security  # eslint-plugin-security
npx snyk test

# Python
pip-audit
bandit -r src/
safety check

# General
git secrets --scan  # Scan for secrets
trivy filesystem .   # Container vulnerability scanning
```

---

## False Positives

AI may over-engineer security. Review these:
- [ ] Is the added complexity worth the security benefit?
- [ ] Does it impact performance significantly?
- [ ] Is there a simpler approach that's equally secure?

---

**Status:** Mark as `SECURITY_REVIEW_PASSED` only when ALL applicable items checked and human has reviewed.

**Last Updated:** November 2025
**Based on:** OWASP Top 10 2025, Veracode AI Code Security Study
