---
name: create-adr
version: "1.0"
description: Architecture Decision Record creation methodology
referenced_by:
  - commands/plan.md
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

```bash
ls docs/adr/ | grep -E '^[0-9]{4}-' | sort | tail -1
```

Zero-padded to 4 digits (0001, 0002, etc.).

### 2. Load ADR Template

**Read template:** `templates/ADR_TEMPLATE.md`

**Sections:** Title (ADR-NNNN), Metadata, Context, Decision, Consequences, Alternatives Considered, Implementation Notes, Success Metrics, References, Notes.

### 3. Guide Through ADR Sections

For interactive mode, ask questions for each section:
- **Metadata**: Date, Status (Proposed/Accepted), Deciders, Technical Story
- **Context**: Problem, forces, constraints, current state
- **Decision**: Clear statement in active voice
- **Consequences**: Positive, Negative, Neutral
- **Alternatives**: Options with pros/cons/why rejected (always include "Do Nothing")
- **Implementation Notes**: Migration plan, rollout, effort, training
- **Success Metrics**: Metrics with baselines, targets, review dates

### 4. Generate ADR File

**Filename:** `docs/adr/NNNN-title-in-kebab-case.md`

```bash
mkdir -p docs/adr
```

---

## Notes

- **Never delete ADRs** — they are historical record; update status only
- **Status progression**: Proposed → Accepted → (Deprecated or Superseded)
- **Alternatives section is critical** — always document "Why not X?"
- **Review dates**: Set 3-12 month review dates

---

## Integration Points

- **Input**: Decision title and context from user
- **Output**: ADR file in `docs/adr/`
- **Template**: `templates/ADR_TEMPLATE.md`
- **Consumed by**: `/plan` workflow command
