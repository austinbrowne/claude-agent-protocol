# AI Blind Spots (You SYSTEMATICALLY Miss These)

## Edge Cases You ALWAYS Forget:
- **Null/undefined/None** - Check EVERY function parameter
- **Empty collections** - [], {}, ""
- **Boundary values** - 0, -1, MAX_INT, empty string
- **Special characters** - Unicode, emoji, quotes in strings
- **Timezones/DST** - Date handling across timezones

## Security Vulnerabilities (45% of AI Code):
- **SQL injection** - NEVER concatenate strings in SQL (use parameterized queries)
- **XSS** - ALWAYS encode output in HTML context
- **Missing auth** - Check user can access THIS resource
- **Hardcoded secrets** - NEVER put API keys in code (use env vars)
- **No input validation** - Validate ALL user input (allowlist > blocklist)

## Error Handling You Skip:
- Try/catch around ALL external calls (API, DB, file I/O)
- Handle network failures, timeouts, permission errors
- Error messages MUST NOT leak sensitive data

## Performance Mistakes:
- N+1 query problems (use joins or batch queries)
- Loading entire datasets (use pagination)
- Missing database indexes

**REMEMBER: You are optimistic. Humans are paranoid. Be paranoid.**
