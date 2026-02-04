---
name: security-review
version: "1.1"
description: OWASP-based security review methodology for AI code review
referenced_by:
  - commands/implement.md
  - skills/fresh-eyes-review/SKILL.md
---

# Security Review Skill

OWASP Top 10 adapted for AI code review with common AI blind spot detection.

---

## When to Apply

- Code involves authentication, authorization, or user input
- Handling sensitive data (PII, passwords, tokens, API keys)
- Database queries with user input
- External API calls
- File uploads
- Issue or PRD flagged as `SECURITY_SENSITIVE`

---

## OWASP Top 10 Checklist Categories

| # | Category | Key Checks |
|---|----------|-----------|
| A01 | Broken Access Control | Auth bypass, privilege escalation, IDOR, missing route protection |
| A02 | Cryptographic Failures | Weak hashing (md5/sha1), plaintext secrets, weak encryption |
| A03 | Injection | SQL injection, XSS, command injection, NoSQL injection |
| A04 | Insecure Design | Client-side trust, missing server validation, business logic abuse |
| A05 | Security Misconfiguration | Debug mode in prod, default credentials, verbose errors |
| A06 | Vulnerable Components | Known CVEs, outdated deps, supply chain risks |
| A07 | Auth Failures | Hardcoded credentials, weak passwords, missing session invalidation |
| A08 | Data Integrity Failures | Unsigned tokens, missing integrity checks |
| A09 | Logging Failures | Missing audit logs, PII in logs, no failed login tracking |
| A10 | SSRF | Unvalidated URLs, internal network access |

---

## AI-Specific Blind Spots

AI code generators systematically miss these security patterns:

### Always Check
- **SQL injection** — String concatenation in queries (use parameterized queries)
- **Missing await on crypto** — `bcrypt.compare()` without await returns truthy Promise
- **Hardcoded secrets** — API keys, tokens, passwords in source code
- **Missing input validation** — Trusting client-side validation alone
- **XSS in templates** — Unescaped user input in HTML output
- **Missing auth on routes** — New endpoints without middleware protection
- **Error message leakage** — Stack traces, internal paths in error responses

### Common AI Mistakes
- Using MD5/SHA1 for password hashing (should be bcrypt/argon2)
- Storing tokens in localStorage (should be httpOnly cookies)
- Missing CSRF protection on state-changing endpoints
- Not validating redirect URLs (open redirect)
- Using `eval()` or `exec()` with any user-influenced input

---

## Security Trigger Detection

Scan git diff for these patterns to determine if security review is needed:

**Auth/authz:** `authenticate|authorize|login|logout|token|jwt|session|password|credentials`
**Data handling:** `encrypt|decrypt|hash|bcrypt|pbkdf2|PII|SSN|credit_card`
**Database:** `query|execute|raw SQL|WHERE|INSERT|UPDATE|DELETE`
**User input:** `req.body|req.query|req.params|input|form|POST|PUT`
**File operations:** `upload|fs.write|file_put_contents|save_file`
**External APIs:** `fetch|axios|http.request|api_call`
**Sensitive env:** `process.env|API_KEY|SECRET|PASSWORD`

If NO triggers found: "No security-sensitive code detected. Security review not required."

---

## Execution Steps

### Step 1: Analyze git diff for security triggers

```bash
git diff HEAD
git diff --staged
```

Scan for trigger patterns listed above. If no triggers found, report no security-sensitive code detected.

### Step 2: Load security checklist

Read `checklists/AI_CODE_SECURITY_REVIEW.md` for the full OWASP checklist.

### Step 3: Run applicable checklist items

For each triggered category, run the relevant checklist items against the code:

- **Auth code triggers:** A01 (Access Control) + A07 (Auth Failures)
- **Database queries trigger:** A03 (Injection)
- **User input triggers:** A03 (Injection/XSS) + A04 (Insecure Design)
- **External APIs trigger:** A10 (SSRF) + A08 (Data Integrity)

### Step 4: Check each item against code

For each checklist item:
- Grep code for relevant patterns
- Mark each item: PASS / FAIL / WARNING / N/A

### Step 5: Generate security findings report

Report format with CRITICAL / HIGH / MEDIUM / LOW severity sections, plus passed checks.

### Step 6: Set security status flag

- `SECURITY_SENSITIVE` — Has unfixed CRITICAL/HIGH issues
- `SECURITY_REVIEWED` — Issues noted, can proceed with caution
- `SECURITY_APPROVED` — All checks passed

---

## Severity Classification

| Severity | Description | Action |
|----------|-------------|--------|
| CRITICAL | Exploitable vulnerability (injection, auth bypass) | Fix immediately |
| HIGH | Significant risk (weak crypto, missing validation) | Fix before commit |
| MEDIUM | Moderate risk (verbose errors, missing logging) | Address soon |
| LOW | Minor concern (code style, defense-in-depth) | Consider fixing |

---

## Integration Points

- **Checklist reference**: `checklists/AI_CODE_SECURITY_REVIEW.md`
- **Agent reference**: `agents/review/security-reviewer.md`
- **Consumed by**: `/implement` workflow command, Fresh Eyes Review security agent
- **Triggers**: Git diff content analysis
