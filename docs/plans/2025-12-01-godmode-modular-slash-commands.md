---
title: "GODMODE Modular Slash Commands"
date: 2025-12-01
status: complete
---

# Product Requirements Document: GODMODE Modular Slash Commands

## Document Info

| Field | Value |
|-------|-------|
| **Title** | GODMODE Modular Slash Commands |
| **Author** | Claude (AI Coding Agent) |
| **Date** | 2025-12-01 |
| **Status** | `READY_FOR_REVIEW` |
| **Priority** | `High` |
| **Type** | `Enhancement` |

---

## 0. Exploration Summary

**Files Reviewed:**
- `/Users/austin/.claude/AI_CODING_AGENT_GODMODE.md` - Main protocol (complete workflow)
- `/Users/austin/.claude/QUICK_START.md` - Entry points and common commands
- `/Users/austin/.claude/guides/FRESH_EYES_REVIEW.md` - Fresh Eyes review process
- `/Users/austin/.claude/guides/FAILURE_RECOVERY.md` - Recovery procedures
- `/Users/austin/.claude/guides/GITHUB_PROJECT_INTEGRATION.md` - GitHub workflow

**Existing Patterns:**
- GODMODE has clear linear workflow: Phase 0 (Planning) → Phase 1 (Execution) → Phase 2 (Finalization)
- Each phase has discrete steps (Explore, Generate PRD, Implement, Test, Review, Commit, etc.)
- Steps reference external guides (FRESH_EYES_REVIEW.md, TEST_STRATEGY.md, etc.)
- Workflow is monolithic - must follow entire sequence
- No way to run individual steps in isolation
- Mentions `/create-issue-from-prd` command but no other modular commands exist

**Constraints Found:**
- Cannot run single workflow steps independently (e.g., just run Fresh Eyes Review on existing code)
- Cannot skip steps without breaking workflow (e.g., already have PRD, want to jump to implementation)
- Cannot compose custom workflows (e.g., Quick Fix workflow: start-issue → implement → review → commit)
- Manual mode requires user to remember all steps and procedures
- No `.claude/commands/` directory structure exists

**Open Questions:**
- Should commands be conversational (ask questions) or automated (execute immediately)?
- Should commands validate prerequisites (e.g., `/commit-and-pr` checks that tests pass)?
- How to handle command failures (retry? rollback? guide user to recovery?)
- Should commands be chainable (e.g., `/explore && /generate-prd`)?

---

## 1. Problem

**What's the problem?**

GODMODE v3.1 is a powerful but monolithic workflow protocol. Users must execute the entire Phase 0 → Phase 1 → Phase 2 sequence linearly, even when they only need specific steps. This creates friction in several scenarios:

**Scenario 1: Mid-workflow entry**
- User already has a PRD, wants to skip Phase 0
- Current: No way to jump directly to Phase 1 implementation
- Result: User manually follows GODMODE.md, may skip critical steps (tests, Fresh Eyes Review)

**Scenario 2: One-off operations**
- User wants to run Fresh Eyes Review on existing uncommitted changes
- Current: Fresh Eyes is embedded in Phase 1 Step 6, requires context of full workflow
- Result: User must manually launch agents, risks missing steps from FRESH_EYES_REVIEW.md

**Scenario 3: Custom workflows**
- User has a "quick bug fix" workflow: pick issue → implement → test → review → commit
- Current: Must mentally map this to GODMODE phases, manually skip irrelevant steps
- Result: Cognitive overhead, inconsistent execution, missed quality gates

**Scenario 4: Learning curve**
- New users overwhelmed by 15+ page GODMODE.md document
- Current: Must read entire protocol to understand which step they need
- Result: Steep learning curve, protocol underutilization

**Who's affected?**
- **Primary**: Users wanting flexibility (skip/reorder steps based on context)
- **Secondary**: New users needing gradual adoption (learn one command at a time)
- **Tertiary**: Advanced users wanting custom workflows (compose commands)

**Evidence:**
- User request: "I'd like to break out each logical step into reusable slash commands"
- Existing `/create-issue-from-prd` command shows demand for modular operations
- GODMODE.md references external guides (FRESH_EYES_REVIEW.md) suggesting steps are conceptually modular
- User workflow variation: experimental vs main branch targeting shows need for flexible workflows

---

## 2. Goals

**Goals:**
1. Create 13 modular slash commands mapping to GODMODE workflow steps
2. Support **hybrid invocation**: Interactive (command asks questions) AND direct (command with args)
3. Enable **standalone execution**: Each command works independently, no workflow context required
4. Maintain **workflow integrity**: Commands validate prerequisites and guide users to next logical step
5. Preserve **existing workflows**: Full GODMODE flow still works, commands are additive
6. Reduce **learning curve**: Users can adopt one command at a time vs. entire protocol

**Non-Goals:**
1. Replacing GODMODE linear workflow (both modes coexist)
2. Automating decision-making (commands guide but require human approval)
3. Cross-command state management (each command is stateless, uses git/filesystem for state)
4. Command chaining/scripting (v1 is single-command invocation, chaining is future consideration)

**Success Metric:**
| Metric | Baseline | Target |
|--------|----------|--------|
| Workflow flexibility | 1 way (linear GODMODE) | 3+ custom workflows possible |
| Step reusability | 0% (embedded in phases) | 100% (all steps callable standalone) |
| Learning curve | 15+ pages to read | Start with 1 command, learn incrementally |
| Command adoption | 1 command (/create-issue-from-prd) | 13 commands available |
| User satisfaction | Unknown | "Commands make GODMODE more flexible" (qualitative) |

---

## 3. Solution

**Overview:**

Create a modular command system with 13 slash commands that decompose the GODMODE workflow into reusable, standalone operations. Each command:
- Supports **hybrid invocation** (interactive if no args, direct if args provided)
- References existing guides/templates/checklists (no duplication of content)
- Validates prerequisites and suggests next logical step
- Works independently (no coupling to full GODMODE workflow)
- Provides clear output and status

**Key Features:**

| Feature | Description | Priority |
|---------|-------------|----------|
| **13 Modular Commands** | Phase 0 (4 commands), Phase 1 (7 commands), Phase 2 (2 commands) | Must Have |
| **Hybrid Invocation** | Interactive mode (asks questions) + Direct mode (args provided) | Must Have |
| **Command Discovery** | List available commands, show help, command descriptions | Must Have |
| **Prerequisite Validation** | Commands check prerequisites, guide user if missing | Should Have |
| **Next Step Suggestions** | After execution, suggest logical next command | Should Have |
| **Status Reporting** | Commands report what they did, what's next, confidence level | Must Have |

---

## 4. Command Specifications

### Phase 0 Commands: Planning

#### Command 1: `/explore`

**Purpose:** Codebase exploration and context gathering

**Interactive Mode:**
```
User: /explore

Claude: 🔍 Codebase Exploration

What would you like to explore?
1. Feature area (e.g., "authentication")
2. Specific path (e.g., "src/auth/")
3. Pattern/concept (e.g., "error handling")
4. Full codebase overview

Your choice: _____

User: authentication

Claude: [Executes exploration, generates summary]
```

**Direct Mode:**
```
User: /explore authentication patterns

Claude: [Immediately executes exploration based on "authentication patterns"]
```

**Execution:**
1. Parse exploration target (feature area, path, pattern, or full)
2. Execute grep searches for relevant patterns
3. Identify key files (limit to top 5-10)
4. Read identified files (with token optimization - summaries for >500 LOC)
5. Generate structured exploration summary
6. Optionally create/update `.claude/CODEBASE_MAP.md`

**Output:**
- Exploration summary (architecture, key files, patterns found)
- Suggestion: "Ready to generate PRD? Run `/generate-prd`"

**Prerequisites:** None (entry point command)

---

#### Command 2: `/generate-prd`

**Purpose:** Create PRD from exploration or user description

**Interactive Mode:**
```
User: /generate-prd

Claude: 📄 PRD Generation

Feature description: _____
Complexity: [1] Lite (<4 hours) [2] Full (>4 hours)

User: User authentication with OAuth
User: 2

Claude: [Generates Full PRD, saves to docs/prds/YYYY-MM-DD-user-authentication.md]
```

**Direct Mode:**
```
User: /generate-prd --full "User authentication with OAuth"

Claude: [Immediately generates Full PRD]
```

**Execution:**
1. Get feature description (from args or ask user)
2. Determine PRD type (--lite, --full, or ask user)
3. Generate PRD using appropriate template structure
4. Save to `docs/prds/YYYY-MM-DD-feature-name.md`
5. Report file location

**Output:**
- PRD file created with path
- Suggestion: "Review PRD, then run `/create-issues` to generate GitHub issues"

**Prerequisites:** Recommended but not required: `/explore` output (can generate from description alone)

---

#### Command 3: `/create-adr`

**Purpose:** Document architectural decisions

**Interactive Mode:**
```
User: /create-adr

Claude: 📐 Architectural Decision Record

Decision title: _____
Context: _____
Options considered: _____

[Guides user through ADR template]
```

**Direct Mode:**
```
User: /create-adr "Use PostgreSQL for primary database"

Claude: [Generates ADR template, asks for details]
```

**Execution:**
1. Get decision title
2. Load ADR_TEMPLATE.md
3. Guide user through sections (Context, Decision, Consequences, Alternatives)
4. Determine next ADR number (NNNN)
5. Save to `docs/adr/NNNN-title.md`

**Output:**
- ADR file created
- Suggestion: "Document other major decisions or proceed to `/create-issues`"

**Prerequisites:** Approved PRD (recommended)

---

#### Command 4: `/create-issues`

**Purpose:** Generate GitHub issues from approved PRD

**Interactive Mode:**
```
User: /create-issues

Claude: 📋 Issue Generation

PRD file: _____ (or press Enter to list available PRDs)
Execution mode: [1] Immediate (assign to me) [2] Backlog (park for later)

User: docs/prds/2025-12-01-feature-name.md
User: 1

Claude: [Generates issues, assigns to user, renames PRD, commits PRD to git]
```

**Direct Mode:**
```
User: /create-issues docs/prds/2025-12-01-feature-name.md --immediate

Claude: [Immediately creates issues and assigns]
```

**Execution:**
1. Parse PRD file (from args or ask user, or list available PRDs)
2. Extract implementation phases/tasks from PRD
3. Generate GitHub issues using gh CLI
4. Label issues (type, priority, area flags)
5. If --immediate: Assign to @me
6. Rename PRD with first issue number (NNN-YYYY-MM-DD-feature-name.md)
7. Update issue to reference renamed PRD
8. Commit PRD to git with message
9. Push PRD to remote

**Output:**
- List of created issues (#123, #124, #125)
- Renamed PRD file path
- Git commit hash
- Suggestion: "Run `/start-issue <number>` to begin implementation"

**Prerequisites:** Approved PRD file exists

---

### Phase 1 Commands: Execution

#### Command 5: `/start-issue`

**Purpose:** Begin work on a GitHub issue

**Interactive Mode:**
```
User: /start-issue

Claude: 🚀 Start Issue

Available issues:
  #123 - Implement user authentication (Ready)
  #124 - Add OAuth provider support (Ready)
  #125 - Create login UI (Blocked by #123)

Select issue number: _____

User: 123

Claude: [Assigns issue, creates branch, updates status]
```

**Direct Mode:**
```
User: /start-issue 123

Claude: [Immediately starts work on issue #123]
```

**Execution:**
1. Get issue number (from args or show available issues)
2. Load issue details via `gh issue view`
3. Verify issue is ready (not blocked, has acceptance criteria)
4. Assign issue to @me
5. Create branch `issue-NNN-brief-description`
6. Push branch to remote with -u flag
7. Update issue with comment "🚧 Starting implementation on branch X"
8. Display issue context (description, acceptance criteria, PRD reference)

**Output:**
- Issue assigned
- Branch created and checked out
- Issue context displayed
- Suggestion: "Implement code, then run `/generate-tests` when ready"

**Prerequisites:** GitHub issue exists and is ready

---

#### Command 6: `/generate-tests`

**Purpose:** Generate tests for implemented code

**Interactive Mode:**
```
User: /generate-tests

Claude: 🧪 Test Generation

Files to test:
  1. src/auth/AuthService.ts (modified)
  2. src/middleware/auth.ts (modified)
  3. All modified files

Select: _____

User: 3

Claude: [Generates tests for all modified files]
```

**Direct Mode:**
```
User: /generate-tests --path src/auth/AuthService.ts

Claude: [Immediately generates tests for specified file]
```

**Execution:**
1. Identify files to test (from args, or detect modified files via git diff)
2. Read TEST_STRATEGY.md for test requirements
3. Analyze code type (API, auth, business logic, etc.)
4. Generate tests covering:
   - Happy path
   - Null/empty inputs
   - Boundary values
   - Invalid inputs (type errors, malformed data)
   - Error conditions (network failure, timeout)
5. Save tests to appropriate test files (parallel structure or same directory)
6. Report test coverage estimate

**Output:**
- Test files created
- Coverage estimate
- Suggestion: "Run `/run-validation` to execute tests and checks"

**Prerequisites:** Code implementation exists (git diff shows changes)

---

#### Command 7: `/security-review`

**Purpose:** Run security checklist review

**Interactive Mode:**
```
User: /security-review

Claude: 🔒 Security Review

Analyzing changes for security triggers...

Found:
- ✅ Authentication code (src/auth/AuthService.ts)
- ✅ User input processing (src/api/users.ts)
- ✅ Database queries (src/models/User.ts)

This code is SECURITY_SENSITIVE. Running full security checklist...

[Loads AI_CODE_SECURITY_REVIEW.md, checks all applicable items]
```

**Direct Mode:**
```
User: /security-review

Claude: [Auto-detects security-sensitive code, runs checklist]
```

**Execution:**
1. Analyze git diff for security triggers:
   - Auth/authz code
   - User input processing
   - Database queries
   - File uploads
   - External API calls
   - PII/sensitive data handling
2. If triggers found: Load checklists/AI_CODE_SECURITY_REVIEW.md
3. Run applicable checklist items
4. Generate security findings (CRITICAL, HIGH, MEDIUM, LOW)
5. Set SECURITY_SENSITIVE flag if needed

**Output:**
- Security findings report
- Severity breakdown
- Flag: SECURITY_SENSITIVE if applicable
- Suggestion: "Address CRITICAL/HIGH findings, then run `/run-validation`"

**Prerequisites:** Code changes exist (git diff)

---

#### Command 8: `/run-validation`

**Purpose:** Run all validation checks (tests, coverage, lint, security scan)

**Interactive Mode:**
```
User: /run-validation

Claude: ✅ Running Validation

Executing:
1. Test suite...
2. Coverage check...
3. Linter...
4. Security scan (npm audit)...

[Runs all checks, reports results]
```

**Direct Mode:**
```
User: /run-validation

Claude: [Immediately runs all checks]
```

**Execution:**
1. Detect project type (package.json → npm, requirements.txt → pip, Cargo.toml → cargo)
2. Run test suite (npm test, pytest, cargo test)
3. Check coverage (npm test --coverage, pytest --cov)
4. Run linter (npm run lint, flake8, cargo clippy)
5. Run security scan (npm audit, pip-audit, cargo audit)
6. Aggregate results

**Output:**
- Test results (N passing, coverage %)
- Lint results (pass/fail, issue count)
- Security scan results (vulnerabilities found)
- Overall verdict: PASS | FAIL_WITH_ISSUES
- Suggestion: "If passing, run `/fresh-eyes-review`. If failing, fix issues and re-run."

**Prerequisites:** Code and tests exist

---

#### Command 9: `/fresh-eyes-review`

**Purpose:** Multi-agent unbiased code review

**Interactive Mode:**
```
User: /fresh-eyes-review

Claude: 👀 Fresh Eyes Code Review

Analyzing changes...
- 234 lines changed
- Recommendation: Standard Review (Security + Code Quality + Supervisor)

Proceed with Standard Review? (yes/no/change tier)

User: yes

Claude: [Launches review agents, consolidates findings]
```

**Direct Mode:**
```
User: /fresh-eyes-review --standard

Claude: [Immediately runs Standard review tier]
```

**Execution:**
1. Create diff file: `git diff --staged > /tmp/review-diff.txt`
2. Count LOC changed
3. Auto-select review tier:
   - <100 LOC → Lite
   - 100-500 LOC → Standard
   - >500 LOC → Full
4. If interactive and auto-selected: Confirm with user
5. Execute FRESH_EYES_REVIEW.md workflow:
   - Launch specialist agents (Security, Code Quality, Performance if Full)
   - Each agent reviews diff with zero conversation context
   - Supervisor consolidates findings
6. Present consolidated report

**Output:**
- Review tier used
- Consolidated findings (CRITICAL, HIGH, MEDIUM, LOW)
- Verdict: BLOCK | FIX_BEFORE_COMMIT | APPROVED
- Suggestion: "Fix CRITICAL/HIGH issues and re-run, or run `/recovery` if unfixable"

**Prerequisites:** Staged git changes exist

---

#### Command 10: `/recovery`

**Purpose:** Evaluate Continue/Rollback/Abandon decision

**Interactive Mode:**
```
User: /recovery

Claude: 🔄 Recovery Decision

Fresh Eyes Review found issues. Let's evaluate options.

Can all issues be fixed in <30 minutes? (yes/no)

User: no

Is the approach fundamentally flawed? (yes/no)

User: no

Recommendation: ROLLBACK & RETRY (try different approach)

Options:
1. Soft reset (preserve changes for reference)
2. Hard reset (discard all changes)
3. Stash (temporary parking)

Your choice: _____
```

**Direct Mode:**
```
User: /recovery --rollback

Claude: [Guides through rollback procedures]
```

**Execution:**
1. Present decision tree from FAILURE_RECOVERY.md
2. Guide user through questions:
   - Can fix in <30 min? → Continue
   - Approach fundamentally flawed? → Abandon
   - Else → Rollback & Retry
3. Execute chosen recovery action:
   - Continue: Return to Phase 1 (fix issues)
   - Rollback: Guide through git reset/stash procedures
   - Abandon: Guide through partial save, create recovery report
4. Set status to RECOVERY_MODE
5. If Abandon: Optionally generate recovery report from RECOVERY_REPORT.md template

**Output:**
- Recovery action taken
- Git commands executed
- Recovery report (if Abandon)
- Suggestion: "If Rollback: Reimplement with new approach. If Abandon: Return to Phase 0."

**Prerequisites:** Fresh Eyes Review found unfixable issues or implementation failing

---

#### Command 11: `/commit-and-pr`

**Purpose:** Commit changes and create pull request

**Interactive Mode:**
```
User: /commit-and-pr

Claude: 📦 Commit & Create PR

Summary:
- Files changed: 5
- Tests: 12 passing, 85% coverage
- Security: Review completed, no CRITICAL issues
- Fresh Eyes: APPROVED

Ready to commit? (yes/no)

User: yes

Commit message: _____ (or press Enter for auto-generated)

User: [Enter]

Branch to target:
1. main (production)
2. experimental (development)

Your choice: _____

User: 2

Claude: [Commits, pushes, creates PR to experimental]
```

**Direct Mode:**
```
User: /commit-and-pr --base experimental

Claude: [Auto-generates commit message, creates PR to experimental]
```

**Execution:**
1. Verify prerequisites:
   - Tests passing (from /run-validation output)
   - Fresh Eyes APPROVED (from /fresh-eyes-review output)
   - Changes staged (git diff --staged)
2. Generate commit message (from issue title + changes, or user input)
3. Execute git commit with message + Closes #ISSUE_NUM + co-author tag
4. Push branch to remote
5. Ask for base branch (main, experimental, or other)
6. Generate PR body (summary, changes, testing, acceptance criteria, PRD reference)
7. Execute gh pr create --base <branch>
8. Report PR URL

**Output:**
- Commit hash
- PR URL
- Suggestion: "Review PR on GitHub. After approval, proceed to `/finalize` or merge directly."

**Prerequisites:**
- Tests passing
- Fresh Eyes Review APPROVED
- Changes staged

---

### Phase 2 Commands: Finalization

#### Command 12: `/refactor`

**Purpose:** Guided refactoring pass

**Interactive Mode:**
```
User: /refactor

Claude: 🔧 Refactoring Analysis

Analyzing code for refactoring opportunities...

Found:
1. Duplication in src/auth/AuthService.ts (lines 45-67 and 89-111)
2. Magic number in src/config.ts (token expiry = 86400)
3. Complex conditional in src/middleware/auth.ts (cyclomatic complexity = 8)

Address these? (yes/no/select)

User: yes

Claude: [Executes refactoring, shows diffs]
```

**Direct Mode:**
```
User: /refactor

Claude: [Auto-detects and suggests refactorings]
```

**Execution:**
1. Analyze code for refactoring opportunities:
   - Duplication (similar code blocks)
   - Magic numbers (extract to constants)
   - Complex conditionals (cyclomatic complexity >5)
   - God objects (classes >300 LOC)
   - Long functions (>50 LOC)
2. Present findings to user
3. For each accepted refactoring:
   - Show before/after diff
   - Make changes
   - Verify tests still pass
4. Re-run tests after refactoring

**Output:**
- Refactorings applied
- Tests passing confirmation
- Suggestion: "Refactoring complete. Run `/finalize` for final checks."

**Prerequisites:** Code committed or staged

---

#### Command 13: `/finalize`

**Purpose:** Final documentation and validation

**Interactive Mode:**
```
User: /finalize

Claude: ✨ Finalization

Final checks:
1. Update README? (yes/no)
2. Generate CHANGELOG entry? (yes/no)
3. Update API docs (OpenAPI spec)? (yes/no)

[Guides through each step]
```

**Direct Mode:**
```
User: /finalize --all

Claude: [Runs all finalization steps]
```

**Execution:**
1. Check if README needs update (public API changed?)
2. Generate CHANGELOG entry (from PR description + commit history)
3. Update OpenAPI spec if API changes detected
4. Add WHY comments to complex code (explain rationale)
5. Final test suite run
6. Final validation report

**Output:**
- Documentation updated (README, CHANGELOG, API docs)
- Comments added
- Final test results
- Suggestion: "Ready to merge PR. All finalization complete."

**Prerequisites:** PR created, code review approved

---

## 5. Technical Approach

**Architecture:**

```
.claude/
├── commands/
│   ├── explore.md                 # Command 1: Exploration
│   ├── generate-prd.md           # Command 2: PRD generation
│   ├── create-adr.md             # Command 3: ADR creation
│   ├── create-issues.md          # Command 4: Issue generation
│   ├── start-issue.md            # Command 5: Begin issue work
│   ├── generate-tests.md         # Command 6: Test generation
│   ├── security-review.md        # Command 7: Security check
│   ├── run-validation.md         # Command 8: All validations
│   ├── fresh-eyes-review.md      # Command 9: Multi-agent review
│   ├── recovery.md               # Command 10: Recovery decision
│   ├── commit-and-pr.md          # Command 11: Commit & PR
│   ├── refactor.md               # Command 12: Refactoring
│   └── finalize.md               # Command 13: Final checks
```

**Command File Structure:**

Each `.md` file contains:

```markdown
# /command-name

**Description:** [What this command does]

**When to use:** [Scenarios where this command is useful]

**Prerequisites:** [What must exist before running this command]

---

## Invocation

**Interactive mode:**
User types `/command-name` with no arguments.

**Direct mode:**
User types `/command-name [args]`

---

## Arguments

- `--arg1` - Description
- `--arg2` - Description

---

## Execution Steps

1. [Step 1]
2. [Step 2]
...

---

## Output

- [What gets produced]
- [Status/confidence level]
- [Suggested next step]

---

## References

- See: `~/.claude/guides/GUIDE_NAME.md` for [purpose]
- See: `~/.claude/templates/TEMPLATE_NAME.md` for [purpose]
```

**Key Decisions:**

- **Hybrid invocation via argument detection**: Command checks if arguments provided; if yes → direct mode, if no → interactive mode
  - *Rationale*: Supports both novice (guided) and expert (fast) users

- **Stateless commands using git/filesystem**: No in-memory state between commands; all state persisted to git or files
  - *Rationale*: Commands can be run in any order, no dependency on previous session

- **Reference existing guides**: Commands don't duplicate content from guides/templates/checklists; they reference them
  - *Rationale*: Single source of truth, reduces maintenance burden

- **Prerequisite validation with suggestions**: Commands check prerequisites and suggest what to do if missing
  - *Rationale*: Guides users through workflow even when starting mid-stream

- **Next step suggestions**: Each command suggests logical next command after execution
  - *Rationale*: Helps users learn workflow, reduces need to memorize sequence

**Modified Files:**

| File | Type | Description |
|------|------|-------------|
| `.claude/commands/*.md` | New | 13 command definition files |
| `QUICK_START.md` | Modified | Add command usage section, list all commands |
| `README.md` | Modified | Add "Modular Commands" section |
| `AI_CODING_AGENT_GODMODE.md` | Modified | Add pointers to commands as alternative to linear workflow |

**Dependencies:**
- Existing: Git, gh CLI, GODMODE guides/templates/checklists
- New: None (commands use existing infrastructure)

---

## 6. Implementation Plan

### Phase 1: Core Commands (Phase 0 Planning) — 6-8 hours

**Deliverables:**
- 4 command files (explore, generate-prd, create-adr, create-issues)
- Command invocation pattern (detect interactive vs direct mode)
- Prerequisite validation logic

**Acceptance Criteria:**
- [ ] `/explore` supports interactive (asks target) and direct (target in args) modes
- [ ] `/explore` generates exploration summary, suggests `/generate-prd`
- [ ] `/generate-prd` supports --lite and --full flags
- [ ] `/generate-prd` saves PRD to docs/prds/YYYY-MM-DD-name.md
- [ ] `/create-adr` loads ADR_TEMPLATE.md and guides user through sections
- [ ] `/create-issues` parses PRD, creates GitHub issues, renames PRD, commits to git
- [ ] All commands report status and suggest next step

---

### Phase 2: Execution Commands (Phase 1 Workflow) — 10-12 hours

**Deliverables:**
- 7 command files (start-issue, generate-tests, security-review, run-validation, fresh-eyes-review, recovery, commit-and-pr)
- Integration with existing guides (FRESH_EYES_REVIEW.md, FAILURE_RECOVERY.md, TEST_STRATEGY.md)
- Prerequisite validation for each command

**Acceptance Criteria:**
- [ ] `/start-issue` assigns issue, creates branch, displays context
- [ ] `/generate-tests` detects modified files, generates tests per TEST_STRATEGY.md
- [ ] `/security-review` detects triggers, loads checklist, generates findings
- [ ] `/run-validation` executes tests, coverage, lint, security scan
- [ ] `/fresh-eyes-review` auto-selects tier, launches agents per FRESH_EYES_REVIEW.md
- [ ] `/recovery` presents decision tree from FAILURE_RECOVERY.md, guides git procedures
- [ ] `/commit-and-pr` asks for base branch, generates commit message, creates PR
- [ ] All commands validate prerequisites and suggest next step

---

### Phase 3: Finalization & Documentation — 4-5 hours

**Deliverables:**
- 2 command files (refactor, finalize)
- Updated QUICK_START.md with command reference
- Updated README.md with commands overview
- Integration notes in AI_CODING_AGENT_GODMODE.md

**Acceptance Criteria:**
- [ ] `/refactor` detects refactoring opportunities, applies changes, re-runs tests
- [ ] `/finalize` updates README, CHANGELOG, API docs as needed
- [ ] QUICK_START.md lists all 13 commands with descriptions
- [ ] QUICK_START.md shows example workflows (Full GODMODE, Quick Fix, Just Review)
- [ ] README.md has "Modular Commands" section explaining command system
- [ ] AI_CODING_AGENT_GODMODE.md references commands as alternative execution mode

---

**Total Effort:** 20-25 hours

---

## 7. Test Strategy

| Test Type | What to Test | Coverage Target | Acceptance Criteria |
|-----------|--------------|-----------------|---------------------|
| **Interactive Mode** | Each command without args asks appropriate questions | All 13 commands | User can complete workflow via interactive prompts |
| **Direct Mode** | Each command with args executes immediately | All 13 commands | No prompts, immediate execution |
| **Prerequisite Validation** | Commands detect missing prerequisites and suggest remedy | Commands with prerequisites | Clear error messages, helpful suggestions |
| **Workflow Flexibility** | Custom workflows work (Quick Fix, Just Review, etc.) | 3-5 workflows | Users can compose commands for their use case |
| **Integration** | Commands reference existing guides correctly | All guide references | No broken links, content stays in sync |

**Test Scenarios:**

1. **Full GODMODE via commands:** Execute all 13 commands in sequence, verify same output as linear GODMODE
2. **Quick Fix workflow:** `/start-issue → [implement] → /fresh-eyes-review → /commit-and-pr` works without errors
3. **Just Review:** `/fresh-eyes-review` on existing staged changes works standalone
4. **Mid-workflow entry:** Start at `/generate-prd` (skip explore), workflow completes successfully
5. **Recovery scenario:** `/recovery` correctly guides through rollback procedures

---

## 8. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Commands diverge from GODMODE workflow (out of sync) | Medium | High | Commands reference guides, don't duplicate. Update guides updates commands. |
| Users skip critical steps (e.g., skip Fresh Eyes) | Medium | Medium | Prerequisite validation warns users. Next step suggestions guide workflow. |
| Command files become too complex (logic duplicated) | Low | Medium | Keep commands thin - delegate to existing guides/checklists. |
| Interactive mode too verbose (slows users down) | Low | Low | Direct mode available for speed. Users choose mode. |
| Hybrid detection broken (args not recognized) | Low | Medium | Test argument parsing thoroughly. Document arg format clearly. |

---

## 9. Performance Budget

**Not performance-critical** - Commands execute sequentially, similar to manual GODMODE execution.

**Token usage consideration:**
- Commands reference guides (no duplication) → Minimal token overhead
- Fresh Eyes Review already optimized with agent context constraints
- Commands don't load unnecessary context (only what's needed for that step)

---

## 10. Security Review

**Not security-sensitive** - Commands are operational tools, don't handle code, data, or auth differently than manual GODMODE execution.

- [ ] Authentication or authorization
- [ ] Handling PII or sensitive data
- [ ] External API integrations
- [ ] User input processing
- [ ] File uploads
- [ ] Database queries with user input

**Note:** `/security-review` command itself executes security checks, but doesn't introduce new security concerns.

---

## 11. Open Questions

| Question | Owner | Status |
|----------|-------|--------|
| Should commands be chainable (e.g., `/explore && /generate-prd`)? | User feedback | Open (future consideration) |
| Should commands maintain execution history (log of what was run)? | Implementation | Open (v2 enhancement) |
| Should `/fresh-eyes-review` always require human confirmation before launch? | User preference | Open (depends on workflow) |
| Should commands have --dry-run mode (show what would happen)? | Implementation | Open (nice-to-have) |

---

## 12. Future Considerations

*Out of scope for this version, but worth noting:*

- **Command chaining**: `/explore && /generate-prd --full` (run multiple commands in sequence)
- **Command history**: Log of commands executed, replay previous workflows
- **Custom workflows**: Save named workflows (e.g., `quick-fix.workflow` = start-issue → implement → review → commit)
- **Command aliases**: Short names (e.g., `/fe` for `/fresh-eyes-review`)
- **Dry-run mode**: `--dry-run` flag shows what command would do without executing
- **Command auto-complete**: Shell auto-completion for command names and args
- **Command dependencies**: Automatically run prerequisite commands if missing (e.g., `/commit-and-pr` auto-runs `/run-validation` if not done)
- **State tracking**: Track which commands have been run, suggest next logical step automatically

---

## 13. Example Workflows

### Workflow 1: Full GODMODE (All Commands)

```bash
/explore "authentication system"
/generate-prd --full "OAuth 2.0 authentication"
# [Review and approve PRD]
/create-issues docs/prds/2025-12-01-oauth-auth.md --immediate
/start-issue 123
# [Implement code]
/generate-tests
/security-review
/run-validation
/fresh-eyes-review
/commit-and-pr --base experimental
/refactor
/finalize --all
```

---

### Workflow 2: Quick Bug Fix

```bash
/start-issue 456
# [Fix bug]
/generate-tests --path src/auth/bugfix.ts
/fresh-eyes-review --lite
/commit-and-pr --base main
```

---

### Workflow 3: Just Review Existing Changes

```bash
# [Already have code changes staged]
/fresh-eyes-review --standard
# [Fix issues found]
/commit-and-pr --base experimental
```

---

### Workflow 4: Mid-Workflow Entry (Have PRD, Skip Explore)

```bash
# [PRD already exists]
/create-issues docs/prds/existing-prd.md --immediate
/start-issue 789
# [Implement]
/generate-tests
/run-validation
/fresh-eyes-review
/commit-and-pr
```

---

## 14. Implementation Phases for GitHub Issues

**Recommended issue breakdown:**

1. **Issue #1**: Phase 0 Commands (explore, generate-prd, create-adr, create-issues) - 6-8 hours
2. **Issue #2**: Phase 1 Commands Part 1 (start-issue, generate-tests, security-review, run-validation) - 5-6 hours
3. **Issue #3**: Phase 1 Commands Part 2 (fresh-eyes-review, recovery, commit-and-pr) - 5-6 hours
4. **Issue #4**: Phase 2 Commands + Documentation (refactor, finalize, docs updates) - 4-5 hours

**Or single issue**: GODMODE Modular Slash Commands (20-25 hours total)

**Recommendation**: Break into 4 issues for incremental delivery and testing.

---

**Status:** `READY_FOR_REVIEW`

**Next Steps:**
1. Human review and approval of this PRD
2. Create GitHub issue(s) with this PRD
3. Proceed to implementation (Phase 1: Core Commands)

**Dependencies:**
- Existing GODMODE guides/templates/checklists (already in place)
- Git, gh CLI (already required)

**Estimated Total Effort:** 20-25 hours
