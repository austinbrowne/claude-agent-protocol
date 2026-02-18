---
name: create-adr
description: "Architecture Decision Record creation methodology"
---

# ADR Creation Skill

Methodology for documenting architectural decisions using the ADR template.

---

## When to Apply

- Making a significant architectural decision (database, framework, cloud provider)
- Decision involves tradeoffs between alternatives
- Decision is hard to reverse
- Decision will be questioned later ("Why didn't we use X?")

---

## Process

### 1. Determine Next ADR Number

List existing ADR files to find the next sequential number:

```bash
ls docs/adr/ | grep -E '^[0-9]{4}-' | sort | tail -1
```

> Note: Adjust commands for PowerShell on Windows (e.g., `ls` -> `Get-ChildItem`, `grep` -> `Select-String`). For GitLab repositories, use `glab` instead of `gh`.

Zero-padded to 4 digits (0001, 0002, etc.).

### 2. Load ADR Template

**Read template:** `templates/ADR_TEMPLATE.md`

**Sections:** Title (ADR-NNNN), Metadata, Context, Decision, Consequences, Alternatives Considered, Implementation Notes, Success Metrics, References, Notes.

### 3. Guide Through ADR Sections

For interactive mode, ask questions for each section:

**Metadata:**
- Date, Status (Proposed/Accepted), Deciders, Technical Story

**WAIT** for user response before continuing.

**Context:**
- Problem, forces, constraints, current state

**WAIT** for user response before continuing.

**Decision:**
- Clear statement in active voice

**WAIT** for user response before continuing.

**Consequences:**
- Positive, Negative, Neutral

**WAIT** for user response before continuing.

**Alternatives:**
- Options with pros/cons/why rejected (always include "Do Nothing")

**WAIT** for user response before continuing.

**Implementation Notes:**
- Migration plan, rollout, effort, training

**WAIT** for user response before continuing.

**Success Metrics:**
- Metrics with baselines, targets, review dates

**WAIT** for user response before continuing.

### 4. Generate ADR File

**Filename:** `docs/adr/NNNN-title-in-kebab-case.md`

Create the `docs/adr` directory if it does not exist:

```bash
mkdir -p docs/adr
```

> Note: Adjust commands for PowerShell on Windows (e.g., `mkdir -p` -> `New-Item -ItemType Directory -Force`).

Write the completed ADR file with all sections populated from user input.

---

## Notes

- **Never delete ADRs** -- they are historical record; update status only
- **Status progression**: Proposed -> Accepted -> (Deprecated or Superseded)
- **Alternatives section is critical** -- always document "Why not X?"
- **Review dates**: Set 3-12 month review dates

---

## Integration Points

- **Input**: Decision title and context from user
- **Output**: ADR file in `docs/adr/`
- **Template**: `templates/ADR_TEMPLATE.md`
- **Consumed by**: `/generate-plan` workflow
