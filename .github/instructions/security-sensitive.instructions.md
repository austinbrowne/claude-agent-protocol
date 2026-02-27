---
applyTo: "**/auth/**,**/middleware/**,**/config/**,**/*auth*,**/*permission*,**/*session*,**/*token*,**/*crypt*,**/.env*"
---

# Security-Sensitive Code — Additional Rules

This file is working with authentication, authorization, secrets, or security-critical paths. Apply heightened scrutiny.

## Mandatory Checks

### Injection Prevention
- [ ] SQL: Parameterized queries or ORM — NEVER string concatenation
- [ ] NoSQL: Input sanitized for MongoDB/DynamoDB queries
- [ ] Command injection: No shell commands with user input (or strict allowlist)
- [ ] Template injection: Engine auto-escapes, user input not in template strings

### Authentication & Authorization
- [ ] Every protected endpoint has auth check
- [ ] Horizontal privilege escalation prevented (user can't access other user's data)
- [ ] Vertical privilege escalation prevented (regular user can't do admin actions)
- [ ] Session tokens: HttpOnly, Secure, SameSite
- [ ] Default deny: access denied unless explicitly permitted
- [ ] Rate limiting on login/auth endpoints

### Secrets Management
- [ ] No hardcoded API keys, passwords, tokens, connection strings
- [ ] Secrets from env vars or secret manager (not code)
- [ ] .env files in .gitignore
- [ ] No secrets in logs, URLs, or error messages
- [ ] .env.example uses placeholder values only

### Input Validation
- [ ] All user input validated (body, params, headers, query)
- [ ] Allowlist over blocklist
- [ ] Length, type, range limits enforced
- [ ] File uploads: type (MIME + magic bytes), size, filename sanitization

### Output Encoding
- [ ] HTML context: user data encoded before rendering
- [ ] Content-Type headers correct
- [ ] Framework auto-escaping enabled and not bypassed

### Error Handling
- [ ] Errors don't leak stack traces, file paths, or schema details
- [ ] Failed auth logged without leaking credentials
- [ ] Custom error handlers override framework defaults

## Risk Assessment

| Level | Action |
|-------|--------|
| CRITICAL | Block deployment, fix immediately |
| HIGH | Must fix before merge |
| MEDIUM | Fix within sprint |
| LOW | Add to backlog |

Flag as `SECURITY_SENSITIVE` and request human review before proceeding.
