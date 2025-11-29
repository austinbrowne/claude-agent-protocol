# Multi-Agent Workflow Patterns

**Purpose:** Coordinate multiple AI agents for complex tasks.

**Status:** Emerging best practice (Microsoft Agent Framework, Google ADK, OpenAI Swarm - 2025)

**Key Insight:** Complex tasks benefit from specialized agents working together, rather than one agent doing everything.

---

## When to Use Multi-Agent Workflows

**Use multi-agent when:**
- Task requires >15 hours of work
- Multiple domains involved (frontend + backend + database + DevOps)
- Parallel workstreams possible (independent modules)
- Research + implementation phases clearly separated
- Cross-cutting concerns (security review + performance review + code review)

**Don't use multi-agent when:**
- Simple tasks (<2 hours)
- Single domain (just frontend or just backend)
- Sequential dependencies (can't parallelize)

---

## Multi-Agent Patterns

### Pattern 1: Specialist Pattern

**Concept:** Different agents for different domains.

**Structure:**
```
Task: Build full-stack feature
├── Frontend Agent → React components, UI logic
├── Backend Agent → API endpoints, business logic
├── Database Agent → Schema design, migrations
└── Test Agent → Integration tests, E2E tests
```

**Workflow:**
1. **Architecture agent** creates design
2. Agents work in parallel on their domains
3. **Integration agent** connects pieces
4. **Review agent** validates final result

**Example:**
```
User: "Build a user profile editing feature"

Architecture Agent:
- Designs API contract (OpenAPI spec)
- Defines database schema changes
- Creates component hierarchy

[Hands off to specialists]

Frontend Agent (parallel):
- Builds ProfileEdit component
- Adds form validation
- Connects to API

Backend Agent (parallel):
- Creates PUT /api/users/:id endpoint
- Validates input
- Updates database

Database Agent (parallel):
- Creates migration to add profile fields
- Updates Prisma schema

Test Agent (parallel):
- Writes E2E test for profile editing flow
- Writes API integration tests

Integration Agent:
- Runs all code together
- Fixes integration issues
- Ensures tests pass

Review Agent:
- Security review (input validation, auth)
- Performance review (N+1 queries?)
- Code quality review
```

**Benefits:**
- Parallelization (4x speedup)
- Specialized context (frontend agent doesn't need backend context)
- Clear separation of concerns

---

### Pattern 2: Research + Execute

**Concept:** Exploration agent researches, execution agent implements.

**Structure:**
```
Complex Task
├── 1. Explore Agent → Research codebase, gather context
├── 2. Plan Agent → Create detailed PRD
└── 3. Execute Agent → Implement based on PRD
```

**Workflow:**
1. **Explore agent** uses Explore agent to understand codebase
2. **Plan agent** creates PRD with all context gathered
3. **Execute agent** implements feature using PRD (doesn't re-explore)

**Benefits:**
- Separation of exploration and implementation
- Execute agent has clean, focused context (no exploration noise)
- Can retry execution without re-exploring

**Example:**
```
User: "Add OAuth login support"

Explore Agent:
- Searches codebase for existing auth patterns
- Identifies auth middleware, JWT handling
- Finds database schema for users
- Documents findings in exploration summary

Plan Agent:
- Reads exploration summary
- Generates PRD with:
  - Current authentication approach
  - Proposed OAuth integration
  - Database changes needed
  - Security considerations

Execute Agent:
- Reads PRD only (doesn't re-explore)
- Implements OAuth provider integration
- Updates database schema
- Adds tests
```

---

### Pattern 3: Review Chain

**Concept:** Multiple agents review code from different perspectives.

**Structure:**
```
Implementation
├── Security Review Agent → OWASP Top 10, input validation
├── Performance Review Agent → Query optimization, bundle size
├── Code Quality Review Agent → Readability, maintainability
└── Test Coverage Review Agent → Are tests sufficient?
```

**Workflow:**
1. **Implementation agent** writes code
2. **Review agents** run in parallel, each focused on their domain
3. **Integration agent** aggregates feedback
4. **Implementation agent** fixes issues
5. Repeat until all reviews pass

**Benefits:**
- Thorough review from multiple angles
- Specialized review context (security agent has OWASP checklist)
- Automated quality gates

**Example:**
```
Implementation Agent:
- Implements payment processing endpoint

[Hands to review chain]

Security Review Agent:
- Checks: SQL injection, XSS, auth, rate limiting
- Flags: Missing rate limiting
- Verdict: REVISION_REQUESTED

Performance Review Agent:
- Checks: Database queries, caching, response time
- Flags: N+1 query issue in order fetching
- Verdict: REVISION_REQUESTED

Code Quality Review Agent:
- Checks: Readability, duplication, naming
- Flags: 150-line function should be split
- Verdict: APPROVED_WITH_SUGGESTIONS

Test Coverage Review Agent:
- Checks: Unit tests, edge cases, error cases
- Flags: Missing test for refund edge case
- Verdict: REVISION_REQUESTED

Integration Agent:
- Aggregates: 3 required fixes, 1 suggestion
- Returns to implementation agent

Implementation Agent:
- Fixes issues
- Re-submits for review

[All reviews pass]
```

---

### Pattern 4: Parallel Execution

**Concept:** Independent tasks executed by different agents simultaneously.

**Structure:**
```
Large Feature
├── Agent 1 → Module A (independent)
├── Agent 2 → Module B (independent)
├── Agent 3 → Module C (independent)
└── Integration Agent → Combine modules
```

**Use case:** Large refactoring, multi-module features, parallel bug fixes

**Example:**
```
User: "Migrate all API endpoints to TypeScript"

Coordinator Agent:
- Identifies 15 endpoints across 5 route files
- Assigns to 5 agents (3 endpoints each)

Agents 1-5 (parallel):
- Each migrates their assigned endpoints
- Adds TypeScript types
- Updates tests

Integration Agent:
- Merges all changes
- Resolves conflicts
- Runs full test suite
```

**Benefits:**
- 5x speedup (5 agents in parallel)
- Reduced context per agent (each sees only their endpoints)
- Scalable (add more agents for more parallelization)

---

### Pattern 5: Iterative Refinement

**Concept:** Feedback loop between agents.

**Structure:**
```
Draft Agent → Review Agent → Revision Agent
     ↑                              ↓
     └──────────── Loop ────────────┘
```

**Workflow:**
1. **Draft agent** creates initial implementation
2. **Review agent** provides feedback
3. **Revision agent** improves based on feedback
4. Repeat until quality threshold met

**Example:**
```
User: "Optimize the dashboard query"

Draft Agent:
- Rewrites query with join optimization

Review Agent:
- Benchmarks: P95 latency = 450ms (target: <200ms)
- Feedback: "Still slow. Try adding index on user_id."

Revision Agent:
- Adds index
- Re-runs query

Review Agent:
- Benchmarks: P95 latency = 120ms ✅
- Feedback: "Meets performance budget. Approved."
```

---

## Multi-Agent Communication Protocols

### Agent2Agent Protocol (A2A)

**Standard:** Google's A2A protocol (2025)

**Concept:** Agents communicate via standardized messages.

**Message format:**
```json
{
  "from": "frontend-agent",
  "to": "backend-agent",
  "task": "get_api_contract",
  "payload": {
    "endpoint": "/api/users",
    "method": "GET"
  }
}
```

**Response:**
```json
{
  "from": "backend-agent",
  "to": "frontend-agent",
  "result": {
    "endpoint": "/api/users",
    "method": "GET",
    "response_schema": { "type": "object", "properties": {...} }
  }
}
```

**See:** [Google A2A Announcement](https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/)

---

### Shared Context Store

**Pattern:** Agents share context via common store.

**Implementation:**
```
.agents/
├── context.json        # Shared context
├── frontend-state.json # Frontend agent state
├── backend-state.json  # Backend agent state
└── integration-log.md  # Integration notes
```

**Example context.json:**
```json
{
  "project": "acme-web-app",
  "tech_stack": {
    "frontend": "React 18, TypeScript",
    "backend": "Node.js, Express, PostgreSQL"
  },
  "current_task": "Add user profile editing",
  "api_contract": {
    "endpoint": "/api/users/:id",
    "method": "PATCH",
    "request_schema": {...},
    "response_schema": {...}
  }
}
```

**Agents read from context.json** to understand what other agents have done.

---

## Orchestration Strategies

### 1. Sequential Orchestration

```
Agent 1 → Agent 2 → Agent 3 → Done
```

**Use when:** Dependencies between agents (Agent 2 needs Agent 1's output)

**Example:** Explore → Plan → Execute

---

### 2. Parallel Orchestration

```
       ┌─ Agent 1 ─┐
Start ─┼─ Agent 2 ─┼─ Merge → Done
       └─ Agent 3 ─┘
```

**Use when:** Independent tasks

**Example:** Frontend + Backend + Database agents working simultaneously

---

### 3. Hub-and-Spoke Orchestration

```
        Agent 1
           ↓
Coordinator
    ↓    ↓    ↓
  Ag2  Ag3  Ag4
    ↓    ↓    ↓
Coordinator
    ↓
  Result
```

**Use when:** Central coordinator distributes work, aggregates results

**Example:** Coordinator assigns modules to agents, then merges

---

### 4. Hierarchical Orchestration

```
         Manager Agent
         ↓           ↓
  Team Lead 1   Team Lead 2
   ↓      ↓      ↓      ↓
  W1    W2     W3    W4
```

**Use when:** Very large tasks requiring management layers

**Example:** Feature → Modules → Components → Functions

---

## Implementing Multi-Agent Workflows

### Option 1: Manual Coordination (Current)

**In Claude Code, manually orchestrate:**

```
1. User: "Explore the codebase for authentication patterns"
   [Task tool with subagent_type=Explore]

2. User: "Based on exploration, create a PRD for OAuth integration"
   [Task tool with subagent_type=Plan]

3. User: "Implement the OAuth integration per the PRD"
   [Standard execution]
```

**Pros:** Full control, works today
**Cons:** Manual coordination required

---

### Option 2: Automated Orchestration (Future)

**Using frameworks like Microsoft Agent Framework:**

```python
from agent_framework import Agent, Orchestrator

explore_agent = Agent("explore", tools=[grep, read, glob])
plan_agent = Agent("plan", tools=[write])
execute_agent = Agent("execute", tools=[write, edit, bash])

orchestrator = Orchestrator()
orchestrator.add_workflow([
    explore_agent.task("Explore codebase for auth patterns"),
    plan_agent.task("Generate PRD based on exploration"),
    execute_agent.task("Implement per PRD")
])

result = orchestrator.run()
```

**Pros:** Automated, scalable
**Cons:** Not yet available in Claude Code (coming 2025)

---

## Best Practices

### 1. Clear Agent Responsibilities

**Define what each agent does:**

| Agent | Responsibility | Tools | Outputs |
|-------|----------------|-------|---------|
| Explore | Understand codebase | Grep, Read, Glob | Exploration summary |
| Plan | Create PRD | Read, Write | PRD document |
| Execute | Implement code | Write, Edit, Bash | Code, tests |
| Review | Security/quality review | Read | Approval or feedback |

---

### 2. Minimize Inter-Agent Dependencies

**❌ Bad (tight coupling):**
```
Agent 1 → produces X
Agent 2 → needs X to produce Y
Agent 3 → needs Y to produce Z
```
→ Sequential bottleneck

**✅ Good (loose coupling):**
```
Agent 1 → produces X
Agent 2 → produces Y (independent of X)
Agent 3 → produces Z (independent of X and Y)
Merge Agent → combines X, Y, Z
```
→ Parallel execution

---

### 3. Use Handoff Documents

**Each agent produces a handoff document for the next:**

```markdown
# Frontend Agent Handoff

## Completed
- UserProfile component (src/components/UserProfile.tsx)
- Form validation
- API integration

## API Contract Used
- PUT /api/users/:id
- Request: { name: string, email: string }
- Response: { id: number, name: string, email: string }

## For Backend Agent
- Please implement PUT /api/users/:id per contract above
- Validate email format server-side
- Return 409 if email already exists

## For Test Agent
- E2E test should verify profile editing flow
- Test edge case: duplicate email
```

---

### 4. Agent Specialization

**Don't create generic agents. Specialize:**

- **Good:** Security Review Agent (OWASP checklist, CVE database)
- **Good:** Performance Review Agent (benchmarks, profiling)
- **Bad:** General Review Agent (too broad, lacks depth)

---

## Multi-Agent Anti-Patterns

### 1. Too Many Agents

**Problem:** 10 agents for a simple feature → coordination overhead > benefit

**Solution:** Use multi-agent only for complex tasks (>15 hours)

---

### 2. Duplicate Work

**Problem:** Multiple agents re-explore the same codebase

**Solution:** Explore once, share context via context store or handoff docs

---

### 3. Integration Hell

**Problem:** 5 agents produce incompatible code

**Solution:**
- Define API contracts upfront
- Use TypeScript/types for contracts
- Integration agent validates early

---

### 4. No Error Handling

**Problem:** One agent fails, entire workflow breaks

**Solution:**
- Retry logic for transient failures
- Fallback strategies
- Clear error messages

---

## Future: Agentic Frameworks (2025+)

**Watch these spaces:**

| Framework | Company | Status |
|-----------|---------|--------|
| **Microsoft Agent Framework** | Microsoft | GA (2025) |
| **Google ADK** | Google | Beta (2025) |
| **AutoGen 2.0** | Microsoft Research | GA (2025) |
| **CrewAI** | CrewAI | Open source |
| **LangGraph** | LangChain | Open source |

**Features coming:**
- Automated orchestration
- Agent-to-agent communication (A2A protocol)
- Persistent agent memory
- Multi-modal agents (code + vision + audio)

---

**Last Updated:** November 2025
**See Also:**
- [Microsoft Agent Framework](https://learn.microsoft.com/en-us/agent-framework/)
- [Google Agent Development Kit](https://developers.googleblog.com/en/agent-development-kit-easy-to-build-multi-agent-applications/)
- [A2A Protocol](https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/)
