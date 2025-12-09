# Test Strategy Matrix

**Purpose:** Provide clear, specific guidance on what tests to write for different types of changes.

**Problem:** "Write tests" is vague. This matrix tells AI agents exactly what tests are required for each scenario.

---

## Test Strategy Matrix

| Test Type | When Required | Coverage Target | Min Test Cases | Tools | Priority |
|-----------|--------------|-----------------|----------------|-------|----------|
| **Unit Tests** | Always for new functions | >80% line coverage | Happy path + 2 error cases + 2 edge cases | pytest, jest, vitest, mocha | Critical |
| **Integration Tests** | API changes, DB schema changes, service-to-service | Critical paths | All endpoints, all CRUD ops | pytest-integration, supertest | Critical |
| **E2E Tests** | User-facing features | Happy path + critical error cases | Primary user flow + 2 error scenarios | Playwright, Cypress, Selenium | High |
| **Performance Tests** | Endpoints, heavy compute, DB queries | Baseline + 20% buffer | P95 latency, throughput | Locust, k6, JMeter, autocannon | Medium |
| **Security Tests** | Auth, data handling, external APIs | OWASP Top 10 coverage | All attack vectors | Bandit, npm audit, OWASP ZAP | Critical |
| **Contract Tests** | API changes (breaking) | All endpoints | Request/response schemas | Pact, Postman | High |
| **Smoke Tests** | Before every deploy | Critical user flows | Login, core feature, checkout | Custom scripts | Critical |
| **Load Tests** | Before major launches | Expected peak load + 50% | Sustained load for 10 min | k6, Locust, Gatling | Medium |
| **Regression Tests** | Bug fixes | Cover the bug scenario | Original bug + variants | Same as unit tests | High |
| **Visual Regression** | UI changes | Critical pages | Screenshots match baseline | Percy, Chromatic, BackstopJS | Medium |

---

## Test Type Details

### 1. Unit Tests

**When:** Every new function, class, or module

**Coverage Targets:**
- **Minimum:** 80% line coverage
- **Ideal:** 90%+ line coverage, 80%+ branch coverage
- **Critical Code:** 100% coverage (auth, payments, data processing)

**Required Test Cases:**
1. **Happy path:** Normal input, expected output
2. **Edge case 1:** Empty/null/zero input
3. **Edge case 2:** Maximum/boundary values
4. **Error case 1:** Invalid input type
5. **Error case 2:** Business rule violation

**Example Test Structure (Python):**
```python
def test_calculate_discount_happy_path():
    """Test discount calculation with valid input"""
    result = calculate_discount(price=100, discount_percent=10)
    assert result == 90

def test_calculate_discount_zero_price():
    """Test with zero price (edge case)"""
    result = calculate_discount(price=0, discount_percent=10)
    assert result == 0

def test_calculate_discount_negative_discount():
    """Test with negative discount (error case)"""
    with pytest.raises(ValueError):
        calculate_discount(price=100, discount_percent=-10)

def test_calculate_discount_exceeds_100_percent():
    """Test with discount > 100% (edge case)"""
    with pytest.raises(ValueError):
        calculate_discount(price=100, discount_percent=150)
```

**Example Test Structure (JavaScript):**
```javascript
describe('calculateDiscount', () => {
  it('calculates discount correctly with valid input', () => {
    expect(calculateDiscount(100, 10)).toBe(90)
  })

  it('handles zero price', () => {
    expect(calculateDiscount(0, 10)).toBe(0)
  })

  it('throws error for negative discount', () => {
    expect(() => calculateDiscount(100, -10)).toThrow(ValueError)
  })

  it('throws error for discount > 100%', () => {
    expect(() => calculateDiscount(100, 150)).toThrow(ValueError)
  })
})
```

---

### 2. Integration Tests

**When:**
- New API endpoints
- Database schema changes
- Third-party service integration
- Microservice communication

**Coverage Targets:**
- All CRUD operations (Create, Read, Update, Delete)
- All authentication flows
- All error responses (4xx, 5xx)

**Required Test Cases:**
1. **Successful operations:** All happy paths
2. **Authentication failures:** Invalid token, expired token, no token
3. **Authorization failures:** Insufficient permissions
4. **Validation failures:** Invalid input, missing required fields
5. **Database constraints:** Unique violation, foreign key violation
6. **External service failures:** Timeout, 500 error, connection refused

**Example (API Integration Test):**
```python
def test_create_user_success():
    response = client.post('/api/users', json={
        'email': 'test@example.com',
        'password': 'SecurePass123!'
    })
    assert response.status_code == 201
    assert 'id' in response.json()

def test_create_user_duplicate_email():
    # Create first user
    client.post('/api/users', json={'email': 'test@example.com', 'password': 'Pass123!'})

    # Try to create duplicate
    response = client.post('/api/users', json={'email': 'test@example.com', 'password': 'Pass123!'})
    assert response.status_code == 409  # Conflict
    assert 'email already exists' in response.json()['error']

def test_create_user_missing_required_field():
    response = client.post('/api/users', json={'email': 'test@example.com'})
    assert response.status_code == 400
    assert 'password' in response.json()['errors']
```

---

### 3. End-to-End (E2E) Tests

**When:**
- User-facing features (UI changes)
- Critical user flows (signup, checkout, etc.)
- Cross-browser compatibility needed

**Coverage Targets:**
- Primary user flow (happy path)
- 2-3 most common error scenarios
- Critical edge cases (mobile, different browsers)

**Required Test Cases:**
1. **Happy path:** User completes primary flow successfully
2. **Authentication required:** User must log in to access
3. **Error handling:** Form validation, network errors
4. **Mobile responsive:** Works on mobile viewport

**Example (Playwright):**
```javascript
test('user can complete checkout flow', async ({ page }) => {
  // Login
  await page.goto('/login')
  await page.fill('[name=email]', 'test@example.com')
  await page.fill('[name=password]', 'password123')
  await page.click('[type=submit]')

  // Add item to cart
  await page.goto('/products/123')
  await page.click('button:has-text("Add to Cart")')

  // Checkout
  await page.goto('/checkout')
  await page.fill('[name=address]', '123 Main St')
  await page.fill('[name=card]', '4111111111111111')
  await page.click('button:has-text("Place Order")')

  // Verify success
  await expect(page.locator('.order-confirmation')).toBeVisible()
  await expect(page.locator('.order-number')).toHaveText(/ORD-\d+/)
})

test('checkout requires authentication', async ({ page }) => {
  await page.goto('/checkout')
  // Should redirect to login
  await expect(page).toHaveURL('/login?redirect=/checkout')
})
```

---

### 4. Performance Tests

**When:**
- New API endpoints
- Database queries (especially with joins)
- Heavy computation (image processing, data aggregation)
- Before major launches

**Coverage Targets:**
- **Latency:** P95 < 200ms for APIs, P95 < 2s for page loads
- **Throughput:** Target RPS (requests per second) based on expected load
- **Resource usage:** CPU < 70%, Memory < 80%

**Required Test Cases:**
1. **Baseline:** Current performance metrics
2. **Expected load:** Typical traffic (e.g., 100 RPS)
3. **Peak load:** Expected peak + 50% buffer (e.g., 150 RPS)
4. **Sustained load:** Can handle load for 10+ minutes without degradation

**Example (k6):**
```javascript
import http from 'k6/http'
import { check, sleep } from 'k6'

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up to 100 users
    { duration: '5m', target: 100 },   // Sustain 100 users
    { duration: '2m', target: 200 },   // Spike to 200 users
    { duration: '5m', target: 200 },   // Sustain spike
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'],  // 95% of requests < 200ms
    http_req_failed: ['rate<0.01'],    // Error rate < 1%
  },
}

export default function () {
  const res = http.get('https://api.example.com/users')
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  })
  sleep(1)
}
```

---

### 5. Security Tests

**When:**
- Authentication/authorization changes
- Data handling (PII, financial)
- External API integration
- File uploads
- User input processing

**Coverage Targets:**
- OWASP Top 10 vulnerabilities tested
- All auth flows tested with invalid credentials
- All inputs tested for injection

**Required Test Cases:**
1. **SQL Injection:** Test with `' OR '1'='1`
2. **XSS:** Test with `<script>alert('xss')</script>`
3. **Authentication:** Invalid token, expired token, no token
4. **Authorization:** Access other users' data
5. **CSRF:** State-changing operations without CSRF token
6. **Rate limiting:** Verify rate limits enforced

**Example (Python - Security Test):**
```python
def test_sql_injection_prevented():
    """Ensure SQL injection is prevented"""
    malicious_input = "'; DROP TABLE users; --"
    response = client.get(f'/api/users/search?name={malicious_input}')

    # Should not crash, should return safe results
    assert response.status_code in [200, 400]

    # Verify users table still exists
    users = db.query('SELECT COUNT(*) FROM users').scalar()
    assert users >= 0

def test_unauthorized_access_prevented():
    """Ensure users can't access other users' data"""
    # Login as user 1
    token1 = login('user1@example.com', 'password')

    # Try to access user 2's data
    response = client.get('/api/users/2/orders', headers={'Authorization': f'Bearer {token1}'})
    assert response.status_code == 403  # Forbidden
```

---

### 6. Contract Tests

**When:**
- API changes (especially breaking changes)
- Microservice communication
- Third-party API integration

**Coverage Targets:**
- All endpoints have contract definitions
- Request/response schemas validated

**Example (Pact):**
```javascript
const { Pact } = require('@pact-foundation/pact')

const provider = new Pact({
  consumer: 'FrontendApp',
  provider: 'UserService',
})

describe('User API Contract', () => {
  it('returns user by ID', async () => {
    await provider.addInteraction({
      state: 'user 123 exists',
      uponReceiving: 'a request for user 123',
      withRequest: {
        method: 'GET',
        path: '/api/users/123',
      },
      willRespondWith: {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
        body: {
          id: 123,
          email: 'user@example.com',
          name: 'Test User',
        },
      },
    })

    const response = await userService.getUser(123)
    expect(response.id).toBe(123)
  })
})
```

---

### 7. Smoke Tests

**When:**
- Before every deployment (production, staging)
- After infrastructure changes
- After dependency updates

**Coverage Targets:**
- All critical user flows work
- All critical integrations responding

**Required Test Cases:**
1. **Health check:** Service is up (`/health` endpoint returns 200)
2. **Database connection:** Can read/write to database
3. **Critical user flow:** Login, view dashboard, perform core action
4. **External services:** APIs, payment gateway, email service responding

**Example (Smoke Test Script):**
```bash
#!/bin/bash
set -e

echo "Running smoke tests..."

# Health check
curl -f https://api.example.com/health || exit 1

# Database check
curl -f https://api.example.com/api/users/1 || exit 1

# Critical user flow
TOKEN=$(curl -X POST https://api.example.com/auth/login \
  -d '{"email":"test@example.com","password":"test123"}' | jq -r .token)

curl -f -H "Authorization: Bearer $TOKEN" https://api.example.com/api/dashboard || exit 1

echo "All smoke tests passed!"
```

---

## Test Selection Guide for AI Agents

Use this decision tree:

```
Is this a new function/class?
├─ YES → Write unit tests (min 5 test cases)
└─ NO → Continue

Is this an API endpoint change?
├─ YES → Write integration tests + contract tests
└─ NO → Continue

Is this user-facing UI?
├─ YES → Write E2E test for happy path
└─ NO → Continue

Does this involve auth/payments/PII?
├─ YES → Write security tests (MANDATORY)
└─ NO → Continue

Does this involve DB queries or heavy compute?
├─ YES → Write performance tests
└─ NO → Continue

Is this a bug fix?
├─ YES → Write regression test that reproduces the bug
└─ NO → Continue
```

---

## Test Coverage Requirements by Risk Level

| Risk Level | Unit Coverage | Integration Tests | E2E Tests | Security Tests | Performance Tests |
|------------|---------------|-------------------|-----------|----------------|-------------------|
| **Critical** (Auth, Payments, PII) | 100% | All paths | All flows | OWASP Top 10 | Required |
| **High** (Core Features) | >90% | Critical paths | Happy path | Input validation | If applicable |
| **Medium** (Standard Features) | >80% | Main paths | Optional | Basic | Optional |
| **Low** (Internal Tools, Utils) | >70% | If public API | No | No | No |

---

## Test Automation Commands

Add these to your project:

```json
{
  "scripts": {
    "test": "npm run test:unit && npm run test:integration",
    "test:unit": "jest --coverage",
    "test:integration": "jest --config jest.integration.config.js",
    "test:e2e": "playwright test",
    "test:security": "npm audit && npm run lint:security",
    "test:performance": "k6 run performance-tests/load-test.js",
    "test:smoke": "./scripts/smoke-test.sh",
    "test:all": "npm test && npm run test:e2e && npm run test:security"
  }
}
```

---

## Adding Test Strategy to PRD

**In PRD Section 5 (Implementation Plan), add for each phase:**

### Phase X: [Name]

**Test Strategy:**
| Test Type | What to Test | Acceptance Criteria |
|-----------|--------------|---------------------|
| Unit | `calculateDiscount()`, `validateUser()` | >80% coverage, all edge cases |
| Integration | `POST /api/orders` | Success, auth failure, validation failure |
| E2E | Checkout flow | User can complete purchase |
| Security | Input validation on order form | XSS, SQL injection prevented |
| Performance | `/api/orders` endpoint | P95 < 200ms |

---

## Test Data Management

**Guidelines:**
- Use factories/fixtures for test data (FactoryBot, faker.js)
- Seed database with consistent test data
- Clean up after tests (transaction rollback or teardown)
- Don't share state between tests
- Use realistic data (not "test test test")

**Example:**
```python
import factory
from faker import Faker

fake = Faker()

class UserFactory(factory.Factory):
    class Meta:
        model = User

    email = factory.LazyFunction(lambda: fake.email())
    name = factory.LazyFunction(lambda: fake.name())
    created_at = factory.LazyFunction(lambda: fake.date_time_this_year())

# Usage in tests
def test_create_order():
    user = UserFactory()  # Creates user with realistic data
    order = Order.create(user_id=user.id, total=99.99)
    assert order.id is not None
```

---

## When to Skip Tests (Rare)

**Only skip tests if:**
- Prototyping/spike (must add tests before merging to main)
- Trivial changes (typo fixes, comment updates)
- Generated code (migrations, API clients) that's already tested upstream

**Never skip tests for:**
- Security-sensitive code
- Public APIs
- Critical user flows
- Bug fixes

---

**Last Updated:** November 2025
**See Also:** `/checklists/AI_CODE_SECURITY_REVIEW.md`, `/checklists/AI_CODE_REVIEW.md`
