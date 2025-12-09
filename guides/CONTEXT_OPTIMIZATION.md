# Context Optimization Guide

**Purpose:** Reduce token usage and improve AI response quality through efficient context management.

**Impact:** Proper context management can reduce costs by 30-50% while improving response accuracy.

---

## Core Principles

1. **Be surgical, not exhaustive** - Reference specific files/lines, not entire directories
2. **Summarize first** - For large files, request summaries before full reads
3. **Use MCP servers** - Offload data queries to reduce context
4. **Clear between tasks** - Don't carry irrelevant context across tasks
5. **Document architecture** - Create high-level maps to avoid repeated exploration

---

## Context Budgets

| Task Type | Target Tokens | Max Tokens | Strategy |
|-----------|---------------|------------|----------|
| **Simple bug fix** | <10k | 20k | Read only affected file |
| **Feature (small)** | <30k | 50k | Read relevant files + architecture doc |
| **Feature (large)** | <80k | 120k | Use exploration agent, then implement |
| **Refactoring** | <50k | 100k | Read target files + tests |
| **Architecture review** | <60k | 100k | Use codebase map + selective reads |

---

## Strategies to Reduce Context Usage

### 1. Use Specific File References

**❌ Bad (wasteful):**
```
Read all files in src/components/
```
→ Reads 50 files, 100k tokens

**✅ Good (targeted):**
```
Read src/components/UserProfile.tsx lines 45-120
```
→ Reads 75 lines, 2k tokens

**How to implement:**
- Use `@filename:start-end` syntax
- Use Grep to find exact locations first
- Only read full files if necessary

---

### 2. Create Codebase Maps

**Create `.claude/CODEBASE_MAP.md`:**

```markdown
# Project Architecture

## Tech Stack
- **Frontend:** React 18, TypeScript, Tailwind
- **Backend:** Node.js, Express, PostgreSQL
- **Testing:** Vitest, Playwright
- **Deployment:** AWS (ECS, RDS, S3)

## Directory Structure

```
src/
├── components/       # React components (presentational)
│   ├── common/       # Reusable UI (Button, Input, Modal)
│   └── features/     # Feature-specific components
├── services/         # Business logic, API clients
│   ├── api/          # Backend API calls
│   ├── auth/         # Authentication logic
│   └── payments/     # Stripe integration
├── hooks/            # Custom React hooks
├── utils/            # Helper functions (formatting, validation)
├── types/            # TypeScript type definitions
└── pages/            # Next.js pages (routing)
```

## Key Patterns

**Authentication:**
- JWT tokens (see `src/services/auth/jwt.ts`)
- Middleware: `src/middleware/auth.ts`
- Protected routes use `withAuth()` HOC

**Database Access:**
- ORM: Prisma (see `prisma/schema.prisma`)
- All queries in `src/services/db/`
- Migrations: `prisma migrate`

**API Design:**
- RESTful (see `src/routes/api/`)
- JSON:API format
- OpenAPI spec: `docs/openapi.yaml`

**Error Handling:**
- Custom error classes: `src/utils/errors.ts`
- Error middleware: `src/middleware/error-handler.ts`
- Format: `{ error: string, message: string, details?: array }`

## Common Tasks

**Add new API endpoint:**
1. Define route in `src/routes/api/`
2. Add controller in `src/controllers/`
3. Add service logic in `src/services/`
4. Update OpenAPI spec
5. Add tests in `tests/integration/`

**Add new component:**
1. Create in `src/components/features/[feature-name]/`
2. Add types in `src/types/`
3. Add tests in `[component-name].test.tsx`
4. Add to Storybook (if applicable)
```

**Usage:**
- Reference in prompts: "See .claude/CODEBASE_MAP.md for architecture"
- Update as architecture evolves
- Saves 5-10k tokens per task by avoiding repeated explanations

---

### 3. Use Directory READMEs

**Create `README.md` in each major directory:**

```markdown
# src/services/payments/

Stripe integration for payment processing.

## Files

- `stripe-client.ts` - Stripe SDK wrapper
- `payment-methods.ts` - Credit card, ACH handling
- `subscriptions.ts` - Subscription management
- `webhooks.ts` - Stripe webhook handlers

## Key Functions

- `createPaymentIntent(amount, currency)` - Create Stripe PaymentIntent
- `processRefund(paymentId, amount)` - Refund payment
- `handleWebhook(event)` - Process Stripe webhooks

## Patterns

- All Stripe calls wrapped in try/catch
- Use idempotency keys for POST requests
- Webhook signatures verified via `stripe.webhooks.constructEvent()`

## Testing

- Unit tests: `tests/unit/payments/`
- Integration tests: Use Stripe test mode
- Test credit card: 4242 4242 4242 4242
```

**Benefit:** AI can read directory README (1k tokens) instead of all files (10k tokens)

---

### 4. Summarize Large Files First

**For files >500 lines:**

**Step 1: Request summary**
```
Summarize src/services/user-service.ts:
- What does this file do?
- What are the main functions/classes?
- What are the dependencies?
- Any important patterns or gotchas?

Keep it under 200 words.
```

**Step 2: Read specific sections**
```
Now read lines 120-180 of src/services/user-service.ts (getUserProfile function)
```

**Savings:** Summary = 500 tokens, full file = 5k tokens

---

### 5. Use MCP Servers for Data Queries

**❌ Bad (paste data into context):**
```
User: "Show me all users created this week"
Assistant: "Can you run this query and paste results?"
User: [pastes 500 lines of JSON]
```
→ 10k tokens

**✅ Good (MCP server):**
```
User: "Show me all users created this week"
Assistant: [Uses MCP PostgreSQL server to query directly]
Assistant: "Found 47 users. Top 5 by activity: ..."
```
→ 2k tokens

---

### 6. Clear Context Between Unrelated Tasks

**Use `/clear` when switching tasks:**

```
[Finish working on authentication feature]

/clear

[Start working on payment processing - unrelated]
```

**Why:** Auth context (10k tokens) not needed for payment work. Clears working memory.

**When to clear:**
- Switching to unrelated feature
- Starting new day/session
- After major task completion
- When context feels "polluted" with irrelevant info

---

### 7. Use Glob/Grep Before Reading

**❌ Bad:**
```
Read all TypeScript files to find the User interface
```

**✅ Good:**
```
Grep for "interface User" in src/types/
→ Found in src/types/user.ts:12

Read src/types/user.ts lines 12-35
```

**Savings:** 90% reduction in tokens

---

### 8. Batch Related Questions

**❌ Bad (multiple round trips):**
```
1. "Where is authentication handled?" [reads 5 files]
2. "How do we hash passwords?" [reads same files again]
3. "What's the JWT expiration time?" [reads config file]
```
→ 3 separate reads, overlapping context

**✅ Good (single comprehensive query):**
```
"I need to understand our authentication system:
1. Where is authentication handled?
2. How do we hash passwords?
3. What's the JWT expiration time?

Use Grep to find these, then read the relevant sections."
```
→ 1 targeted read

---

### 9. Use Checkpoints Before Major Reads

**Before reading many files, create checkpoint:**

```
Git commit current state

[Now safe to explore 20 files to understand architecture]
```

**Why:** If exploration leads nowhere, rollback without wasting context on implementation.

---

### 10. Prefer Type Definitions Over Full Files

**For TypeScript/Python projects:**

**❌ Read full implementation (200 lines):**
```typescript
// user-service.ts
export class UserService {
  async getUser(id: number): Promise<User> {
    // 50 lines of implementation
  }

  async createUser(data: CreateUserDto): Promise<User> {
    // 50 lines of implementation
  }

  // ... 100 more lines
}
```

**✅ Read type definition (20 lines):**
```typescript
// user-service.d.ts
export declare class UserService {
  getUser(id: number): Promise<User>
  createUser(data: CreateUserDto): Promise<User>
  updateUser(id: number, data: UpdateUserDto): Promise<User>
  deleteUser(id: number): Promise<void>
}
```

**Benefit:** Understand API surface without reading implementation details.

---

## Context Optimization Checklist

Before each task:

- [ ] Do I need to read full files, or can I target specific lines?
- [ ] Should I summarize large files first?
- [ ] Can I use Grep/Glob to find exact locations?
- [ ] Is there a CODEBASE_MAP or directory README?
- [ ] Can I use an MCP server instead of pasting data?
- [ ] Should I clear context from previous unrelated task?
- [ ] Am I batching related questions?
- [ ] For exploration, should I use the Explore agent?

---

## Measuring Context Usage

**Check token usage:**
- Claude Code shows token count in status bar
- Aim for <50k tokens per task
- If >100k tokens, you're doing something inefficient

**Track over time:**
- Average tokens per task type
- Identify patterns (which tasks use most context?)
- Optimize high-token tasks first

---

## Example: Efficient Task Execution

### Task: "Add email verification to signup flow"

**❌ Inefficient approach (80k tokens):**
```
1. Read entire src/ directory to understand project
2. Read all authentication files
3. Read all email service files
4. Read all database models
5. Implement feature
6. Read all test files
```

**✅ Efficient approach (25k tokens):**
```
1. Read CODEBASE_MAP.md (1k tokens)
2. Grep for "signup" and "email" (500 tokens)
3. Read src/services/auth/signup.ts lines 20-80 (2k tokens)
4. Read src/services/email/email-client.ts summary (500 tokens)
5. Read src/services/email/email-client.ts lines 45-90 (2k tokens)
6. Implement feature with targeted context (15k tokens)
7. Generate tests (3k tokens)
```

**Savings:** 55k tokens (69% reduction)

---

## Context Anti-Patterns

### 1. Reading Entire Directories

```
❌ Read src/components/*.tsx
→ Reads 50 files, 80k tokens

✅ Grep "UserProfile" in src/components/, then read specific file
→ Reads 1 file, 2k tokens
```

### 2. Re-reading Same Files

```
❌ Read file A for question 1
   Read file A again for question 2
   Read file A again for question 3

✅ Read file A once, ask all questions together
```

### 3. Pasting Large Outputs

```
❌ User pastes 1000-line database dump

✅ Use MCP server to query database, return summary
```

### 4. Not Using Summaries

```
❌ Read 2000-line file to understand what it does

✅ Request summary first, then read specific sections
```

### 5. Carrying Dead Context

```
❌ Keep reading auth files while working on unrelated payment feature

✅ Use /clear to remove irrelevant context
```

---

## Advanced: Caching Strategies

### 1. Cache Common Queries in Docs

**Create `docs/FAQ.md`:**

```markdown
## How do we handle authentication?
JWT tokens (see src/services/auth/jwt.ts)
- Access token: 15 min expiration
- Refresh token: 7 day expiration
- Stored in httpOnly cookies

## How do we structure database queries?
Prisma ORM (see prisma/schema.prisma)
- All queries in src/services/db/
- Transactions: use prisma.$transaction()

## What's our error handling pattern?
Custom errors (see src/utils/errors.ts)
- Extend BaseError class
- Caught by error middleware
- Logged to CloudWatch
```

**Usage:** "See docs/FAQ.md for common patterns" → 1k tokens instead of re-exploring

---

### 2. Use AI-Generated Architecture Docs

**After exploration, have AI create summary:**

```
"Based on the files you've read, create an architecture document for the authentication system. Include:
- Key files and their purposes
- Main functions and their signatures
- Data flow (login, logout, token refresh)
- Save to docs/arch/authentication.md"
```

**Next time:** Read docs/arch/authentication.md (2k tokens) instead of re-exploring (20k tokens)

---

## ROI Calculation

**Example project:**
- **Before optimization:** 65k tokens/task avg
- **After optimization:** 30k tokens/task avg
- **Tasks per month:** 40
- **Token savings:** (65k - 30k) × 40 = 1.4M tokens/month
- **Cost savings:** 1.4M tokens × $0.003/1k = ~$4.20/month per developer

**At scale (10 developers):** $42/month savings
**Plus:** Faster responses, better quality (more focused context)

---

**Last Updated:** December 2025
**See Also:** `AI_CODING_AGENT_GODMODE.md` (Section 11)
