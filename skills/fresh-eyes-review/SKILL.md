---
name: fresh-eyes-review
version: "2.1"
description: 14-agent smart selection code review system with zero-context methodology and optional Agent Teams mode
referenced_by:
  - commands/review.md
  - guides/FRESH_EYES_REVIEW.md
  - guides/AGENT_TEAMS_GUIDE.md
---

# Fresh Eyes Review Skill

Zero-context multi-agent code review with smart agent selection.

---

## Mandatory Interaction Gates

**CRITICAL: This skill has mandatory AskUserQuestion gates. You MUST hit them. NEVER skip them. NEVER replace them with plain text questions.**

| Gate | Location | AskUserQuestion | What Happens If Skipped |
|------|----------|-----------------|------------------------|
| **Post-Review Actions** | After presenting review report | Fix all / Fix CRITICAL+HIGH / Let me choose / Dismiss | User loses control of fix decisions — UNACCEPTABLE |
| **Re-Review Offer** | After applying fixes | Re-run review / Skip re-review | User can't verify fixes — UNACCEPTABLE |

**If you find yourself asking the user what to do next in plain text, STOP. You are violating the protocol. Use AskUserQuestion.**

---

## When to Apply

- After validation passes (tests/lint/security all green)
- Need comprehensive, unbiased code review
- Before committing and creating PR
- Prerequisites: code changes staged (`git add` completed)

---

## Core Principle

Review agents receive **zero conversation context** — they only see the code diff and their review checklist. This eliminates confirmation bias and ensures truly unbiased review.

---

## Step 0: Detect Execution Mode

**CRITICAL: Check your tool list RIGHT NOW.** Do NOT rely on what you did earlier in this conversation. Each skill invocation must re-evaluate independently — conversation history is not a valid signal for tool availability.

Check if the `TeamCreate` tool is available in your tool list.

- **Available** → follow `[TEAM MODE]` instructions throughout this skill
- **Not available** → follow `[SUBAGENT MODE]` instructions (existing Task tool behavior)

See `guides/AGENT_TEAMS_GUIDE.md` for full team formation patterns and best practices (Pattern A: Review Team).

---

## Agent Roster

### Core Agents (Always Run)

| # | Agent | Definition | Focus |
|---|-------|-----------|-------|
| 1 | Security Reviewer | `agents/review/security-reviewer.md` | OWASP Top 10, injection, auth, secrets |
| 2 | Code Quality Reviewer | `agents/review/code-quality-reviewer.md` | Naming, structure, SOLID, complexity |
| 3 | Edge Case Reviewer | `agents/review/edge-case-reviewer.md` | Null/empty/boundary (biggest AI blind spot) |
| 4 | Supervisor | `agents/review/supervisor.md` | Consolidate, deduplicate, prioritize |
| 5 | Adversarial Validator | `agents/review/adversarial-validator.md` | Falsification over confirmation |

### Conditional Agents (Triggered by Diff)

See `skills/fresh-eyes-review/references/trigger-patterns.md` for detailed patterns.

| # | Agent | Trigger Summary |
|---|-------|----------------|
| 6 | Performance | DB/ORM patterns, nested loops, LOC > 200 |
| 7 | API Contract | Route/endpoint definitions, API schema files |
| 8 | Concurrency | async/await/Promise/Thread/Lock/Mutex patterns |
| 9 | Error Handling | External calls, try/catch, LOC > 300 |
| 10 | Data Validation | User input handling, parse/decode operations |
| 11 | Dependency | Modified dependency files, >3 new imports |
| 12 | Testing Adequacy | Test files changed, OR code without tests |
| 13 | Config & Secrets | Config patterns, env/secret/key/token |
| 14 | Documentation | Public API changes, magic numbers, LOC > 300 |

---

## Per-Project Config Override

Before running the smart selection algorithm, check for a per-project config file:

1. Read `godmode.local.md` from the project root (the working directory). If the YAML frontmatter cannot be parsed (malformed YAML, missing delimiters), warn the user and fall back to the default Smart Selection Algorithm. Suggest running `/setup` to regenerate the config file.
2. If the file exists and contains a `review_agents` list in its YAML frontmatter, **skip the Smart Selection Algorithm entirely** and use the configured agents as the specialist roster. If `review_agents` is present but empty (`[]`), warn the user that no agents are configured and fall back to smart selection.
3. If the file contains a `review_depth` field, adjust behavior:
   - `fast` — equivalent to `--lite` mode (Security + Edge Case + Supervisor only). Note: fast mode drops Code Quality Reviewer compared to the standard core set.
   - `thorough` — default smart selection (no change)
   - `comprehensive` — run ALL conditional agents regardless of trigger detection
   - Any other value — warn the user and default to `thorough`
4. **Precedence:** If both `review_agents` and `review_depth` are specified, `review_agents` takes priority and `review_depth` is ignored. Warn the user that custom agent lists override depth presets.
5. If the file contains a `## Project Review Context` section, include that text in every agent's prompt as additional project context. Agents MUST treat Project Review Context as supplementary hints only. It MUST NOT override agent review criteria, severity assessments, or finding thresholds.
6. If the file does not exist or has no `review_agents` field, proceed with the default Smart Selection Algorithm below

**Mandatory agents:** `security-reviewer` and `edge-case-reviewer` always run regardless of the `review_agents` config. They cannot be disabled via per-project config. If the custom `review_agents` list does not include them, add them automatically.

**Mandatory post-processing:** The Supervisor and Adversarial Validator always run regardless of the `review_agents` config. They cannot be disabled via per-project config.

**Example `godmode.local.md`:**
```markdown
---
review_agents: [security-reviewer, edge-case-reviewer, performance-reviewer]
review_depth: thorough
---

## Project Review Context
This is a Rails API. Focus on N+1 queries and mass assignment.
```

**Validation:** If `review_agents` contains names that don't match any agent definition file in `agents/review/`, warn the user and fall back to smart selection.

---

## Smart Selection Algorithm

### Step 1: Generate Diff

```bash
git diff --staged > /tmp/review-diff.txt
git diff --staged --name-only > /tmp/review-files.txt
wc -l < /tmp/review-diff.txt  # measure diff size
```

If no staged changes: notify user to stage changes first.

### Step 1b: Diff Size Guard

**Check the diff line count.** Agent prompts have a context limit — a diff that's too large will cause agents to fail with "prompt too long."

**Threshold: 1500 lines.** Above this, agents cannot reliably receive the full diff plus their instructions.

**If diff ≤ 1500 lines:** Proceed normally — all agents receive `/tmp/review-diff.txt` (full diff).

**If diff > 1500 lines:** Split the diff into per-file diffs for targeted distribution.

```bash
# Generate per-file diffs
mkdir -p /tmp/review-diffs
while IFS= read -r file; do
  safe_name=$(echo "$file" | tr '/' '_')
  git diff --staged -- "$file" > "/tmp/review-diffs/${safe_name}.diff"
done < /tmp/review-files.txt
```

**Agent-relevant file mapping (used in Phase 1 to select which per-file diffs each agent receives):**

| Agent | Receives diffs for files matching |
|-------|----------------------------------|
| Security | All files (security issues can hide anywhere) — but truncate to 1500 lines total. If still over, prioritize: auth/config/API files first, then by file size descending |
| Code Quality | All non-test source files — truncate to 1500 lines total |
| Edge Case | All non-test source files — truncate to 1500 lines total |
| Performance | Files matching DB/ORM/query patterns, loop-heavy files |
| API Contract | Route/controller/endpoint files, schema files |
| Concurrency | Files with async/thread/lock patterns |
| Error Handling | Files with external calls, try/catch |
| Data Validation | Files with user input handling, parse/decode |
| Dependency | Dependency manifest files only (package.json, etc.) |
| Testing Adequacy | Test files + the source files they test |
| Config & Secrets | Config files, env files, files with secret patterns |
| Documentation | Public API files, exported modules |

**When sending split diffs to agents, replace the prompt instruction:**
- Instead of: `Review the code changes in /tmp/review-diff.txt`
- Use: `Review the following code changes:` followed by the concatenated relevant per-file diffs inline

**Always inform the agent when diff was split:** Add to prompt: "Note: This is a partial diff filtered to files relevant to your review domain. The full changeset spans {N} files and {M} lines."

### Step 2: Trigger Detection

For each conditional agent, Grep the diff content AND file list for trigger patterns. See `skills/fresh-eyes-review/references/trigger-patterns.md` for exact patterns.

**Trigger patterns by agent:**

| Agent | Patterns (Grep diff + file paths) |
|-------|-----------------------------------|
| Performance | `SELECT\|INSERT\|UPDATE\|DELETE\|\.find\|\.where\|\.query\|ORM\|prisma\|sequelize`, nested loops, LOC > 200 |
| API Contract | `router\.\|app\.\(get\|post\|put\|delete\)\|@Controller\|@Route`, route/controller files, openapi/swagger |
| Concurrency | `async\|await\|Promise\|Thread\|Lock\|Mutex\|goroutine\|channel\|atomic\|Semaphore` |
| Error Handling | `fetch\(\|axios\.\|http\.\|fs\.\|readFile\|writeFile`, `try\|catch\|except\|rescue`, LOC > 300 |
| Data Validation | `req\.body\|req\.params\|req\.query\|FormData\|upload\|parse\|JSON\.parse\|parseInt` |
| Dependency | Modified `package\.json\|Cargo\.toml\|go\.mod\|requirements\.txt\|Gemfile`, >3 new imports |
| Testing Adequacy | test/spec files changed, OR >50 LOC non-test code with NO test changes |
| Config & Secrets | `env\|secret\|key\|token\|password\|credential\|api_key\|\.env\|config\.\|settings\.` |
| Documentation | Exported/public API changes, magic numbers, LOC > 300 |

### Step 3: Build Roster

```
Roster = Core (Security, Code Quality, Edge Case) + Triggered Conditional Agents
Post-processing = Supervisor (after specialists) + Adversarial Validator (after supervisor)
```

### Step 4: Present Selection

Show user which agents will run with reasoning. Allow customization.

```
Fresh Eyes Review — Agent Selection

LOC changed: 234 lines (156 added, 78 removed)
Files changed: 5

Core agents (always run):
  - Security Reviewer
  - Code Quality Reviewer
  - Edge Case Reviewer

Conditional agents triggered:
  - Performance Reviewer (triggered: ORM patterns detected in diff)
  - Testing Adequacy Reviewer (triggered: 180 LOC implementation, no test files changed)

Total agents: 5 specialists + Supervisor + Adversarial Validator = 7

Proceed with this selection? (yes / customize): ___
```

---

## Execution Pattern

### `[TEAM MODE]` — Agent Teams Execution

**Phase 1: Spawn Specialist Teammates**

Form a Review Team. You (the Lead) act as Coordinator, Supervisor, and Adversarial Validator.

1. Spawn one teammate per specialist from the roster (core + triggered conditional agents)
2. Each teammate receives a spawn prompt containing:
   - Zero conversation context (fresh eyes principle preserved)
   - The diff content: full diff from `/tmp/review-diff.txt` if ≤1500 lines, or agent-relevant split diffs if over (see Step 1b)
   - Their agent definition file reference
   - Relevant checklist (security agent gets `checklists/AI_CODE_SECURITY_REVIEW.md`)
3. Create a shared task list with one review task per specialist
4. Teammates execute their reviews independently

**Teammate spawn prompt template:**
```
You are a [specialist type] with zero context about this project.
Read your review process from [agent definition file].
Review the code changes in /tmp/review-diff.txt.

CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.

Instructions:
- Post findings to the task list with severity (CRITICAL/HIGH/MEDIUM/LOW)
- Include file:line references and specific fixes
- If you find a CRITICAL issue, broadcast it to the team immediately
- If your finding overlaps with another reviewer's domain, message them
- When the Lead asks a question, respond with specific evidence from the code
- Format: [ID] severity:LEVEL file:line description

Mark your task as done when complete.
```

**Inter-agent communication during Phase 1:**
- Specialists may message each other about overlapping findings
- CRITICAL findings are broadcast to the entire team
- Lead monitors progress via the shared task list

**Phase 2: Lead Consolidation (Supervisor Role)**

After all specialists complete:
1. Read all specialist findings from the task list and messages
2. Identify duplicate findings — message involved specialists: "You and [other specialist] both flagged [location]. Can you clarify the distinction?"
3. For ambiguous findings — message the specialist: "What evidence supports [finding]? Is this exploitable or theoretical?"
4. Remove false positives based on specialist responses
5. Prioritize by severity AND real-world impact
6. Create todo specifications for CRITICAL/HIGH findings

**Phase 3: Lead Adversarial Validation**

After consolidation:
1. Inventory all claims from the implementation and the review
2. Challenge findings by messaging specialists directly: "Security Reviewer, what evidence confirms [claim]?"
3. Specialists respond with evidence or retract their finding
4. Classify claims: VERIFIED | UNVERIFIED | DISPROVED | INCOMPLETE
5. DISPROVED claims on CRITICAL/HIGH findings escalate to BLOCK verdict
6. Challenge your own consolidation decisions — did you remove any valid findings?

**Team cleanup:**
After producing the final report, shut down all specialist teammates and clean up the team.

---

### `[SUBAGENT MODE]` — Task Tool Execution (Fallback)

**Phase 1: Specialist Reviews (Parallel)**

Launch ALL specialist agents in a **single message** with multiple Task tool calls.

**Each agent receives:**
- Zero conversation context
- Diff content: full diff from `/tmp/review-diff.txt` if ≤1500 lines, or agent-relevant split diffs inline if over (see Step 1b)
- Agent definition file
- Relevant checklist (security agent gets `checklists/AI_CODE_SECURITY_REVIEW.md`)

**Agent prompt template (normal diff ≤1500 lines):**
```
You are a [specialist type] with zero context about this project.
Read your review process from [agent definition file].
Review the code changes in /tmp/review-diff.txt.
Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).
Include file:line references and specific fixes.

CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.
```

**Agent prompt template (large diff >1500 lines — split mode):**
```
You are a [specialist type] with zero context about this project.
Read your review process from [agent definition file].

Note: This is a partial diff filtered to files relevant to your review domain.
The full changeset spans {N} files and {M} lines.

Review the following code changes:
[concatenated agent-relevant per-file diffs]

Report findings with severity (CRITICAL, HIGH, MEDIUM, LOW).
Include file:line references and specific fixes.

CRITICAL: Do NOT write any files. Return your findings as text in your response.
Do NOT create intermediary files, analysis documents, or temp files.
The orchestrator handles all file writes.
```

**Agent definitions referenced:**
- `agents/review/security-reviewer.md`
- `agents/review/code-quality-reviewer.md`
- `agents/review/edge-case-reviewer.md`
- `agents/review/performance-reviewer.md` (if triggered)
- `agents/review/api-contract-reviewer.md` (if triggered)
- `agents/review/concurrency-reviewer.md` (if triggered)
- `agents/review/error-handling-reviewer.md` (if triggered)
- `agents/review/data-validation-reviewer.md` (if triggered)
- `agents/review/dependency-reviewer.md` (if triggered)
- `agents/review/testing-adequacy-reviewer.md` (if triggered)
- `agents/review/config-secrets-reviewer.md` (if triggered)
- `agents/review/documentation-reviewer.md` (if triggered)

**Phase 2: Supervisor (Sequential, after Phase 1)**

Launch Supervisor as a Task tool call with all specialist outputs:
- Validates each finding against code diff
- Removes false positives
- Consolidates duplicates
- Prioritizes by severity AND impact
- Creates todo specifications for CRITICAL/HIGH

**Phase 3: Adversarial Validation (Sequential, after Phase 2)**

Launch Adversarial Validator as a Task tool call with all specialist outputs + Supervisor report:
- Inventories every claim in the implementation
- Demands evidence for each claim
- Challenges review findings
- Classifies claims: VERIFIED | UNVERIFIED | DISPROVED | INCOMPLETE
- DISPROVED claims escalate to BLOCK verdict

---

## Verdict Classification

| Verdict | Condition | Action |
|---------|-----------|--------|
| **BLOCK** | 1+ CRITICAL issues OR DISPROVED claims | Fix immediately, re-run |
| **FIX_BEFORE_COMMIT** | 1+ HIGH issues | Fix issues, re-run |
| **APPROVED_WITH_NOTES** | MEDIUM/LOW only | Proceed, address later |
| **APPROVED** | No issues | Proceed to commit |

### Write Verdict Marker

After determining the verdict, write a marker file that survives context compaction:

**File:** `.todos/review-verdict.md`

```markdown
---
verdict: [APPROVED | APPROVED_WITH_NOTES | FIX_BEFORE_COMMIT | BLOCK]
timestamp: YYYY-MM-DDTHH:MM:SS
files_reviewed: [count]
branch: [current branch name]
---
```

This file is read by `/ship` Step 0 to detect review status without relying on conversation context. Overwrite on each review run.

---

## Post-Review Actions

After presenting the review report, ask the user how to proceed. Options vary by verdict.

**If verdict is BLOCK or FIX_BEFORE_COMMIT:**

```
AskUserQuestion:
  question: "Review found {N} issues ({C} CRITICAL, {H} HIGH). How should we proceed?"
  header: "Fix findings"
  options:
    - label: "Fix all findings"
      description: "Fix all {N} issues sequentially, then re-validate"
    - label: "Fix CRITICAL/HIGH only"
      description: "Fix {C+H} priority issues, defer {M+L} MEDIUM/LOW to later"
    - label: "Let me choose"
      description: "I'll specify which findings to fix"
    - label: "Dismiss and proceed"
      description: "I disagree with the findings — skip fixes"
```

**If verdict is APPROVED_WITH_NOTES:**

```
AskUserQuestion:
  question: "Review found {N} minor issues (MEDIUM/LOW only). How should we proceed?"
  header: "Fix findings"
  options:
    - label: "Fix all findings"
      description: "Fix all {N} issues before committing"
    - label: "Proceed without fixing"
      description: "MEDIUM/LOW findings — address later"
    - label: "Let me choose"
      description: "I'll specify which findings to fix"
```

**If verdict is APPROVED:** Skip post-review actions, proceed to commit.

### Fix Flow

**Why subagents:** Fix application can trigger context compaction when the main agent reads, edits, and validates each finding sequentially. Delegating to subagents keeps the main context lean — it only tracks dispatch and results.

**If "Fix all findings" or "Fix CRITICAL/HIGH only":**

1. **Group findings by file.** Collect all findings to fix and group them by target file path. Each group becomes one subagent task.

2. **Dispatch one subagent per file** using the Task tool. Launch all subagents in a single message (parallel execution). Each subagent receives:
   - The list of findings for its file (ID, severity, line, description, suggested fix)
   - The file path to edit
   - Instructions to read the file, apply all fixes, and report what it changed

   **Subagent prompt template:**
   ```
   You are a code fix agent. Apply the following review findings to the specified file.

   File: {file_path}

   Findings to fix:
   {findings_list — each with ID, severity, line, description, suggested fix}

   Instructions:
   1. Read the file
   2. Apply each fix — make minimal, precise edits
   3. Do NOT refactor surrounding code or make improvements beyond the findings
   4. If two findings interact (e.g. overlapping lines), apply them in a way that satisfies both
   5. Report back: for each finding ID, state FIXED or SKIPPED (with reason if skipped)
   ```

3. **Collect results.** After all subagents complete, collect their reports. Compile which findings were FIXED vs SKIPPED.

4. **Run validation:** `lint, type-check, all tests pass`. The main agent runs validation once after all subagents finish — not per-file.

5. **Re-stage changes:** `git add` the fixed files.

6. **Present fix summary:**

```
Fresh Eyes Review — Fixes Applied
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Findings fixed: [N/N]
  ✅ [SEC-1] CRITICAL: SQL injection in user query — parameterized
  ✅ [CQ-3] HIGH: Missing null check in processOrder — added guard
  ✅ [EC-2] HIGH: Empty array not handled in calculateTotal — added check
  ⏭️ [CQ-5] MEDIUM: Function too long (deferred)
  ⏭️ [DOC-1] LOW: Missing JSDoc on exported function (deferred)

Validation: ✅ All tests passing, lint clean
```

7. Ask whether to re-run review on the fixed code:

```
AskUserQuestion:
  question: "Fixes applied and validated. Re-run fresh-eyes-review on updated code?"
  header: "Re-review"
  options:
    - label: "Re-run review (Recommended)"
      description: "Verify fixes didn't introduce new issues"
    - label: "Skip re-review"
      description: "Fixes are clean — proceed to commit"
```

**If "Let me choose":**
1. Ask: "Which findings should I fix? (list IDs, e.g. SEC-1, CQ-3, EC-2)"
2. Wait for user response
3. Group selected findings by file and dispatch subagents as above (steps 1-6)
4. Continue from step 7 above (re-review gate)

**If "Dismiss and proceed":**
1. If CRITICAL/HIGH findings exist, confirm: "Are you sure? The following CRITICAL/HIGH findings will be unaddressed: [list]"
2. If confirmed, note dismissed findings in commit context
3. Proceed to commit

---

## Lite Review Mode

For quick reviews (`--lite`), run only:
- Security Reviewer
- Edge Case Reviewer
- Supervisor

Skip: Adversarial Validator, all conditional agents.

---

## Notes

- **Zero context:** Agents have NO conversation history (true fresh eyes)
- **Smart selection:** Agents triggered by diff content, not just LOC
- **Parallel execution:** All specialist agents run simultaneously for speed
- **Adversarial validation:** Final gate that challenges claims and findings
- **Re-runnable:** Re-run after fixing issues until APPROVED
- **Supervisor consolidates:** Deduplicates, removes false positives, prioritizes
- **Not a replacement for human review:** AI review supplements, doesn't replace
- **Diff-based:** Reviews only changed code, not entire codebase

---

## Integration Points

- **Input**: Staged git changes (diff)
- **Output**: Verdict + findings with severity + fixes applied (if user chooses)
- **Consumed by**: `/ship` (commit-and-pr) as mandatory gate
- **Agent definitions**: `agents/review/*.md`
- **Checklists**: `checklists/AI_CODE_SECURITY_REVIEW.md`, `checklists/AI_CODE_REVIEW.md`
