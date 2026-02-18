---
name: review-protocol
description: "Protocol compliance review and status reporting"
---

# Protocol Review

Methodology for reviewing AI Coding Agent Protocol compliance and generating status reports.

---

## When to Apply

- Mid-workflow to check protocol compliance
- After context loss or summarization to re-establish phase awareness
- When unsure about current workflow state

---

## Process

### 1. Read Protocol

Read and internalize the project's coding agent protocol documentation (e.g., `AI_CODING_AGENT_GODMODE.md` or equivalent workflow reference).

### 2. Generate Status Report

1. **Current Phase:** What phase of work are we in? (Planning, Execution, Finalization)
2. **Protocol Compliance:**
   - Exploring before proposing solutions?
   - Using extended thinking for complex decisions?
   - Providing confidence indicators?
   - Flagging risks appropriately?
   - Being direct and not deferential?
3. **Next Action:** What approval or input is needed to proceed?
4. **Blockers:** Any `HALT_PENDING_DECISION` items?

### 3. Confirm and Continue

Confirm protocol compliance, then continue with current task.

---

## Integration Points

- **Input**: Current conversation context
- **Output**: Status report with compliance assessment
- **Reference**: Project protocol documentation
- **Consumed by**: `/review-protocol` invocation or mid-workflow compliance checks
