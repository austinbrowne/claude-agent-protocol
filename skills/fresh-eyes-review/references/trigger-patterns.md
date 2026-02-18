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
- Nested iterations: `\.find\(.*\.find\(|\.filter\(.*\.filter\(|\.map\(.*\.map\(|\.forEach\(.*\.forEach\(`

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
- `Promise\.all|Promise\.race|Promise\.allSettled|new Promise|\.lock\(|\.unlock\(|Mutex|Semaphore|goroutine|channel|atomic\.|volatile |synchronized |Thread\(|spawn\(|actor |worker_threads|SharedArrayBuffer|Atomics\.|concurrent\.|parallelStream`

---

## Error Handling Reviewer

**Diff content patterns:**
- External calls: `fetch\(|axios\.|http\.(get|post|put|delete)|request\(|fs\.(readFile|writeFile|access|mkdir|unlink|stat)|open\(.*O_|createReadStream|createWriteStream`
- Error patterns: `try|catch|except|rescue|recover`

**LOC threshold:** > 300 lines changed

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

## Documentation Reviewer

**Diff content patterns:**
- Public API: `export (default |function |class |const |interface |type )|module\.exports\s*=|__all__\s*=`
- Magic numbers: bare numeric literals > 1

**LOC threshold:** > 300 lines changed

**File path patterns:** `README|docs|\.md`

---

## LOC Gate Patterns

Used by Step 2.5 (LOC Gate & Mode Recommendation) to decide Full vs Lite review.

**LOC threshold:** <= 50 lines added (non-test files) recommends Lite review.

**Test file exclusion patterns (excluded from LOC count):**
- `test|spec|__tests__`

**Security-sensitive content overrides (grep diff content, non-test files):**
- `process\.env|os\.environ|API_KEY|SECRET_KEY|password|credential`

If any content override matches, the LOC gate recommends Full even for small changesets.

**Security-sensitive file path overrides (grep file list):**
- `\.env|config\.|settings\.|auth|middleware|permission`

**Dependency file overrides (grep file list):**
- `package\.json|Cargo\.toml|go\.mod|requirements\.txt|Gemfile|pyproject\.toml`

Any file path or dependency override also forces Full recommendation.

---

## Usage: Triggering and Filtering

The patterns defined above serve two purposes in the review pipeline:

### 1. Trigger Detection (Step 2)

Patterns determine **whether an agent should run** — a binary yes/no decision.

- Grep the entire staged diff (`.review/review-diff.txt`) for **diff content patterns**
- Grep the changed file list (`.review/review-files.txt`) for **file path patterns**
- Check **LOC thresholds** where applicable
- If any pattern matches, add the agent to the roster

All agents read the full diff (`.review/review-diff.txt`). Each agent focuses on its own domain — no per-agent diff filtering is performed.
