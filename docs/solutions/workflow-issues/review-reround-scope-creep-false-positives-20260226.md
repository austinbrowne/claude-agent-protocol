---
module: Fresh Eyes Review
date: 2026-02-26
problem_type: workflow_issue
component: tooling
symptoms:
  - "Round 2 re-review Supervisor escalates to BLOCK on findings that weren't issues in round 1"
  - "Review agents flag pre-existing behavior as new regressions on re-review"
  - "YAML template placeholder values (e.g. tasks_total: 0) flagged as runtime initialization bugs"
  - "Alternative implementation suggestions classified as 'underspecified' findings"
root_cause: logic_error
resolution_type: workflow_improvement
severity: medium
tags: [fresh-eyes-review, re-review, scope-creep, false-positive, adversarial-validator, review-escalation, yaml-template, supervisor]
related_solutions:
  - docs/solutions/security-issues/git-add-all-stages-secrets-in-recovery-20260226.md
---

# Troubleshooting: Fresh-Eyes Re-Review Round Scope Creep and False Positives

## Problem
When running a second round of fresh-eyes-review after fixing findings from round 1, specialist agents tend to over-flag issues. The Supervisor consolidates these into a BLOCK verdict that the Adversarial Validator must override. This wastes a full AV cycle and can mislead users into thinking their fixes introduced problems.

## Environment
- Module: Fresh Eyes Review (skills/fresh-eyes-review)
- Affected Component: Specialist agents + Supervisor on re-review rounds
- Date: 2026-02-26

## Symptoms
- Round 2 Supervisor issues BLOCK on 3 HIGH findings, all disproved by AV
- Pre-existing issues (`.credentials.json` on disk) treated as regressions from this diff
- YAML format template values (`tasks_total: 0`) flagged as "premature termination bug" despite being placeholders overwritten at setup
- Explicit specifications called "underspecified" when reviewer prefers a different implementation approach

## What Didn't Work

**Direct solution:** The Adversarial Validator caught all 3 false escalations. Without AV, the changeset would have been incorrectly blocked.

## Solution

The Adversarial Validator is the critical safety net. Its specific disproval reasoning:

1. **Pre-existing vs. regression:** `.credentials.json` existing on disk is not introduced by this diff. The diff actually MITIGATES it by adding a `.gitignore` entry. Penalizing the diff for a pre-existing issue is incorrect.

2. **Template vs. runtime values:** `tasks_total: 0` appears in the YAML format template block, not in runtime initialization code. The Setup Phase populates the real count from the plan before the loop starts. Confusing schema documentation with runtime state is a category error.

3. **Alternative approach != underspecified:** The circular dependency handler explicitly says "If ALL remaining `[ ]` tasks have unmet dependencies, mark ALL of them `[!]`." A reviewer proposing a `skipped_in_row` counter is suggesting an alternative implementation — the existing spec is complete and handles the case.

## Why This Works

1. **ROOT CAUSE:** Zero-context review agents (by design) lack the context to distinguish pre-existing behavior from new changes, or format templates from runtime code. On round 2, they see the full cumulative diff and re-flag things that round 1 found acceptable.
2. **The AV's falsification approach demands evidence.** Instead of accepting claims at face value, it reads the actual diff and verifies each claim against code. This catches the three failure modes above.
3. **The multi-phase pipeline (specialists → supervisor → AV) is resilient.** Even when 2 of 3 phases produce false positives, the final phase corrects them.

## Prevention

- **Always run the Adversarial Validator on re-review rounds.** Never skip AV to save time — re-reviews have higher false-positive rates than initial reviews.
- **Weight AV verdicts heavily on round 2+.** If AV disproves a Supervisor BLOCK, trust the AV unless there's specific counter-evidence.
- **Distinguish "pre-existing" from "regression" in Supervisor prompts.** Consider adding context to the Supervisor prompt about which changes are new vs. pre-existing when running re-reviews.
- **Beware "template value as runtime bug" pattern.** When reviewing YAML/config format definitions, verify whether values are documentation defaults or actual initialization. Look for the Setup Phase that populates real values.

## Related Issues

- See also: [git add -A Stages Secrets](../security-issues/git-add-all-stages-secrets-in-recovery-20260226.md) — the HIGH finding correctly caught in round 1 that triggered this re-review
