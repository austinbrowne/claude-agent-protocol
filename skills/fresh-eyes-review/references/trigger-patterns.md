---
name: trigger-patterns
version: "1.0"
description: Detailed trigger patterns for conditional Fresh Eyes Review agents
parent: skills/fresh-eyes-review/SKILL.md
---

# Agent Trigger Patterns

Grep patterns used to determine which conditional agents should participate in a review.

---

## Performance Reviewer

**Diff content patterns:**
- `SELECT|INSERT|UPDATE|DELETE|\.find|\.where|\.query|ORM|prisma|sequelize|knex|typeorm`
- Nested loops: `for|while|\.map.*\.map|\.forEach.*\.forEach`

**LOC threshold:** > 200 lines changed

**File path patterns:** `model|service|api|repository`

---

## API Contract Reviewer

**Diff content patterns:**
- `router\.|app\.(get|post|put|delete|patch)|@Controller|@Route|@Get|@Post|endpoint|handler`
- `openapi|swagger|schema\.json|\.graphql`

**File path patterns:** `route|controller|handler|endpoint|api`

---

## Concurrency Reviewer

**Diff content patterns:**
- `async|await|Promise|Thread|Lock|Mutex|goroutine|channel|atomic|volatile|Semaphore|\.lock\(\)|synchronized|actor|spawn`

---

## Error Handling Reviewer

**Diff content patterns:**
- External calls: `fetch\(|axios\.|http\.|request\(|\.get\(|\.post\(|fs\.|readFile|writeFile|open\(`
- Error patterns: `try|catch|except|rescue|recover`

**LOC threshold:** > 300 lines changed

---

## Data Validation Reviewer

**Diff content patterns:**
- `req\.body|req\.params|req\.query|request\.form|request\.data|params\[|FormData|multipart|upload|parse|decode|JSON\.parse|parseInt|parseFloat`

---

## Dependency Reviewer

**File path patterns (modified files):**
- `package\.json|Cargo\.toml|go\.mod|go\.sum|requirements\.txt|Gemfile|pom\.xml|build\.gradle|pyproject\.toml`

**Diff content threshold:** > 3 new `import|require|from|use` statements

---

## Testing Adequacy Reviewer

**File path patterns:** `test|spec|__tests__`

**OR condition:** > 50 LOC of non-test code with NO test file changes

---

## Config & Secrets Reviewer

**Diff content patterns (non-test files only):**
- `env|secret|key|token|password|credential|api_key|API_KEY`

**File path patterns:**
- `\.env|config\.|settings\.|\.config\.|\.yaml|\.yml|\.toml`

---

## Documentation Reviewer

**Diff content patterns:**
- Public API: `export|public|module\.exports|__all__`
- Magic numbers: bare numeric literals > 1

**LOC threshold:** > 300 lines changed

**File path patterns:** `README|docs|\.md`

---

## Usage

For each conditional agent:
1. Grep `/tmp/review-diff.txt` for diff content patterns
2. Grep `/tmp/review-files.txt` for file path patterns
3. Check LOC thresholds where applicable
4. If any pattern matches, add agent to roster
