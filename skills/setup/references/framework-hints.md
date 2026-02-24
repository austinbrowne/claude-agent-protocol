---
name: framework-hints
version: "1.0"
description: Framework-specific review hints auto-composed into Project Review Context by setup skill
parent: skills/setup/SKILL.md
---

# Framework Review Hints

Hints in this file are composed into the `## Project Review Context` section of `godmode.local.md`
based on the detected stack. Each framework section contains 3-5 actionable patterns that generic
review agents would otherwise miss.

**Format:** `- [agent-tag] hint text`
Agent tags: `[security]`, `[edge-case]`, `[performance]`, `[code-quality]`, `[ui]`, `[api]`, `[error-handling]`

**Budget:** Keep each framework to 3-5 hints. A typical 3-framework stack should produce ~12-15 hint lines.
If total hints for a project exceed 25 lines, the setup skill truncates by priority: `[security]` and
`[edge-case]` first, then `[performance]`, then others.

---

## Next.js (App Router)

**Detection:** `next.config.*` AND (`app/layout.tsx` OR `app/page.tsx` OR `app/layout.js` OR `app/page.js`)

- [security] Flag `"use server"` functions that accept unsanitized user input — Server Actions execute on the server with full DB/filesystem access. Treat every parameter as untrusted.
- [performance] Flag client components (`"use client"`) that could be Server Components — unnecessary client bundles inflate JS payload. Check if the component actually uses hooks, event handlers, or browser APIs.
- [edge-case] Flag `generateStaticParams` without fallback handling — missing params at runtime cause 404 without graceful degradation.
- [code-quality] Flag data fetching in client components that should use Server Components or Route Handlers — avoid `useEffect` fetch waterfalls when server-side fetch is available.
- [security] Flag exported functions in `route.ts` files without authentication checks — App Router route handlers bypass middleware by default when accessed directly.

---

## Next.js (Pages Router)

**Detection:** `next.config.*` AND (`pages/_app.tsx` OR `pages/_document.tsx` OR `pages/_app.js`)

- [security] Flag `getServerSideProps` returning unsanitized database objects — serialized props are exposed in the page HTML source. Strip sensitive fields before return.
- [performance] Flag `getServerSideProps` on pages that could use `getStaticProps` with ISR — unnecessary server computation on every request.
- [edge-case] Flag API routes in `pages/api/` without explicit HTTP method checks — default export handles all methods. Unguarded DELETE on a GET-intended endpoint.
- [code-quality] Flag `getInitialProps` usage — prevents automatic static optimization and runs on both server and client with different behavior.

---

## React (Generic)

**Detection:** `package.json` contains `"react"` as dependency (and no Next.js/Remix/Gatsby detected)

- [performance] Flag `useEffect` with missing or incorrect dependency arrays — stale closures cause subtle bugs, empty arrays skip necessary re-runs.
- [edge-case] Flag `useState` initial values derived from props without sync mechanism — initial value is captured once, prop changes after mount are ignored.
- [security] Flag `dangerouslySetInnerHTML` usage — XSS vector. Verify the source is sanitized (DOMPurify or equivalent) before rendering.
- [code-quality] Flag `useEffect` used for derived state — calculations that depend only on props/state should use `useMemo`, not effect + setState cycles.

---

## Vue

**Detection:** `package.json` contains `"vue"` as dependency (and no Nuxt detected)

- [edge-case] Flag direct mutation of reactive objects returned from `setup()` or `<script setup>` without `ref()`/`reactive()` — changes will not trigger reactivity.
- [security] Flag `v-html` directive — XSS vector. Verify content is sanitized before binding.
- [performance] Flag computed properties with side effects or expensive operations without caching strategy — `computed` re-evaluates on dependency change.
- [code-quality] Flag `watch` with `immediate: true` that could be replaced by a `computed` — watchers that just derive state are a code smell.

---

## Nuxt

**Detection:** `nuxt.config.*`

- [security] Flag `useFetch`/`$fetch` to external APIs without error handling — unhandled errors in SSR crash the entire request, not just the component.
- [performance] Flag `useFetch` without `key` parameter in components rendered in lists — causes duplicate requests and hydration mismatches.
- [edge-case] Flag `useState` composable used without considering SSR/client hydration mismatch — initial value must be serializable and consistent across server/client.
- [api] Flag server routes in `server/api/` without input validation — Nuxt server routes receive raw event objects; `readBody()` returns unvalidated data.

---

## Svelte / SvelteKit

**Detection:** `svelte.config.*` OR `package.json` contains `"svelte"`; SvelteKit confirmed by `src/routes/` or `+page.svelte`

- [security] Flag `load` functions in `+page.server.ts` returning sensitive data — data is serialized into the HTML. Strip secrets before return.
- [edge-case] Flag reactive declarations (`$:`) depending on object identity — Svelte tracks assignment, not deep mutation. `array.push()` does not trigger reactivity without reassignment.
- [code-quality] Flag SvelteKit form actions without progressive enhancement — `use:enhance` required for JS-disabled form submission.
- [performance] Flag `+page.ts` `load` functions making sequential awaits that could be parallelized with `Promise.all`.

---

## Express

**Detection:** `package.json` contains `"express"` as dependency

- [security] Flag routes without input validation middleware — Express does not validate request bodies by default. Verify Zod/Joi/express-validator on every route that reads `req.body` or `req.params`.
- [error-handling] Flag async route handlers without try/catch or express-async-errors — unhandled promise rejections crash the process in Express 4.
- [api] Flag middleware ordering: verify `helmet()`, CORS, and body-parser are applied before route handlers, not after.
- [edge-case] Flag `req.query` values used as numbers without parsing — Express query params are always strings. `req.query.page * 2` produces `NaN` or string concatenation.

---

## Rails

**Detection:** `Gemfile` AND (`app/controllers/` OR `config/routes.rb`)

- [security] Flag `params.permit` with nested hashes or arrays — mass assignment bypasses are common when permitting complex structures. Verify every permitted key is intentional.
- [performance] Flag ActiveRecord queries inside loops (`.each`, `.map`) — N+1 queries. Use `.includes()`, `.preload()`, or `.eager_load()`.
- [edge-case] Flag `find` vs `find_by` — `find` raises `RecordNotFound` on miss (returning 404), `find_by` returns nil (potential `NoMethodError` on nil).
- [security] Flag `raw` or `html_safe` in views — XSS vector. Verify content is trusted or sanitized.

---

## Django

**Detection:** (`pyproject.toml` OR `requirements.txt`) containing `django`, OR `manage.py` exists

- [security] Flag `|safe` template filter and `mark_safe()` — XSS vector. Verify content origin.
- [security] Flag views without `@login_required` or `LoginRequiredMixin` accessing user data — Django views are public by default.
- [performance] Flag QuerySet evaluation inside loops — Django QuerySets are lazy. Accessing `.all()` in a loop triggers N+1. Use `select_related()`/`prefetch_related()`.
- [edge-case] Flag `Model.objects.get()` without try/except for `DoesNotExist` and `MultipleObjectsReturned` — both are common in production data.

---

## FastAPI

**Detection:** (`pyproject.toml` OR `requirements.txt`) containing `fastapi`

- [security] Flag endpoints with `Depends()` chains that skip auth for specific paths — FastAPI dependency injection is per-endpoint. Verify auth dependency is applied to every protected route.
- [edge-case] Flag Pydantic models with `Optional` fields that lack server-side defaults — `None` propagates into business logic unless handled.
- [error-handling] Flag background tasks (`BackgroundTasks`) without error handling — failures in background tasks are silently swallowed by default.
- [api] Flag response models that expose internal fields — `response_model` should be a separate schema from the DB model. Verify sensitive fields are excluded.

---

## Go (Standard Library)

**Detection:** `go.mod` exists

- [error-handling] Flag `err` variables that are checked but not all error returns are handled — Go convention requires checking every returned error. Ignored `err` is a silent failure.
- [security] Flag `http.ListenAndServe` without timeouts — default Go HTTP server has no read/write timeout, enabling slowloris attacks. Use `http.Server` with explicit timeouts.
- [edge-case] Flag goroutines without WaitGroup or context cancellation — leaked goroutines accumulate memory and connections.
- [performance] Flag `defer` inside loops — each iteration allocates a deferred call. Move defer outside the loop or use explicit cleanup.

---

## Prisma

**Detection:** `prisma/` directory OR `prisma` in `package.json` dependencies

- [performance] Flag sequential Prisma queries that could use `$transaction` or batch operations — multiple `await prisma.x.create()` in sequence should be `prisma.$transaction()`.
- [edge-case] Flag `findUnique`/`findFirst` result used without null check — returns `null` when no record matches. Direct property access throws.
- [security] Flag `prisma.$queryRaw` or `prisma.$executeRaw` with template literals — SQL injection. Use `Prisma.sql` tagged template for parameterized raw queries.
- [performance] Flag nested `include` deeper than 2 levels — deep eager loading causes large JOIN queries. Consider separate queries or `select` to limit fields.

---

## Drizzle

**Detection:** `drizzle.config.*` OR `drizzle` in `package.json` dependencies

- [security] Flag `sql` template tag with string interpolation instead of `sql.placeholder()` — SQL injection in raw queries.
- [edge-case] Flag `.get()` vs `.all()` result handling — `.get()` returns undefined on no match. Verify null check before property access.
- [performance] Flag multiple sequential `.insert()` calls that could use batch insert — Drizzle supports `db.insert(table).values([...])` for bulk operations.

---

## Tailwind CSS

**Detection:** `tailwind.config.*` OR `tailwindcss` in `package.json` dependencies

- [ui] Flag hardcoded color hex values or pixel spacing in components using Tailwind — use Tailwind utility classes or `theme()` references. Raw values bypass the design system.
- [ui] Flag `@apply` in CSS files combining many utilities — extract to a component instead. `@apply` with 5+ utilities indicates a component extraction opportunity.
- [performance] Flag Tailwind `content` config that scans `node_modules` or overly broad globs — inflates build time and CSS output. Restrict to source directories.
