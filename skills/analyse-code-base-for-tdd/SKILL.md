---
name: analyse-code-base-for-tdd
description: Analyses an existing codebase against the TDD and Clean Code workflow, scores compliance across 12 dimensions, and produces a prioritised remediation plan with sprint-sized tasks mapped to /tdd-clean-code-workflow gates.
---

# Skill: analyse-code-base-for-tdd

## Purpose

This skill performs a retrospective audit of an existing codebase to assess how far it deviates from the Red-Green-Refactor TDD lifecycle and the Clean Code principles enforced by `tdd-clean-code-workflow`. Where `tdd-clean-code-workflow` is prospective — it governs new work by orchestrating agents through planning, testing, implementation, and refactoring in strict sequence before a single line of production code is written — `analyse-code-base-for-tdd` is retrospective. It examines code that already exists and has never passed through that lifecycle. It does not build anything. It reads, evaluates, and reports.

The skill produces a prioritised, actionable remediation plan structured into discrete work items. Each work item maps a specific violation or gap to the corrective action needed, the agent responsible for that action, and a suggested priority. The output is designed to be consumed directly by `tdd-clean-code-workflow`: once the remediation plan is accepted by the user, individual work items can be fed into the prospective workflow one at a time to bring each area of the codebase into compliance incrementally. This makes the two skills complementary halves of a complete quality lifecycle — one for greenfield work, one for legacy rehabilitation.

The skill matters because most real codebases predate any formal TDD or Clean Code discipline. Without a structured audit, teams accumulate technical debt silently: untested code paths, functions that violate the 6-line constraint, framework dependencies leaking into domain models, security surfaces with no test coverage, and architectural boundaries that exist only in documentation. By surfacing these gaps explicitly, with severity ratings and a clear remediation sequence, this skill gives teams a realistic path from their current state to full compliance — without requiring a disruptive rewrite.

---

## Trigger

Invoked when the user types:

```
/analyse-code-base-for-tdd
```

This skill is appropriate in the following situations:

- A team is adopting the `tdd-clean-code-workflow` skill for the first time and wants to understand the compliance gap in their existing codebase before applying the prospective workflow to new work.
- A codebase has grown without enforced TDD and now requires a structured remediation backlog.
- A code review or audit has surfaced quality concerns but no systematic inventory of violations exists.
- A team wants to prioritise technical debt reduction and needs an evidence-based, agent-assessed starting point.
- A new engineer or architect joins a project and needs a rapid, structured assessment of the codebase's TDD and Clean Code health.

This skill does NOT trigger automatically. It must be explicitly invoked by the user. It does not run as part of `tdd-clean-code-workflow` and does not share any quality gates with it.

---

## Prerequisites

Before invoking `/analyse-code-base-for-tdd`, the user should provide or confirm the following. Claude will prompt for any missing items before beginning the analysis.

### 1. Repository or scope path

Provide an absolute path to the codebase root, a subdirectory, or a named module to scope the analysis. Without a defined scope, the skill will analyse the entire working directory.

```
Example: /Users/marcotedone/dev/my-project/src
```

If the repository has multiple modules (e.g. a monorepo), specify which modules are in scope. Analysing all modules at once is supported but produces a larger, slower report.

### 2. Primary language and framework

Specify the primary implementation language and framework so that agents apply the correct idioms, test framework conventions, and architectural boundary rules.

Supported combinations include (but are not limited to):

| Language   | Framework                                     |
|------------|-----------------------------------------------|
| Java       | Spring Boot, Spring Framework, Jakarta EE     |
| TypeScript | Angular, Node.js, NestJS                      |
| Python     | FastAPI, Django, Flask                        |
| JavaScript | React, Vue, Express                           |

Mixed-language codebases are supported. List all languages present.

### 3. Test framework in use (if any)

Specify the test framework currently in use, or state that no tests exist. This allows `🟩 testing-automation-agent` to assess existing tests against the correct conventions and identify gaps accurately.

```
Examples: JUnit 5 + Mockito, Jasmine, pytest, none
```

### 4. Analysis scope (required — choose one or more)

Tell the skill what dimensions of compliance to analyse. Leaving all options active is the default and produces the most complete report, but narrowing scope reduces analysis time for large codebases.

| Scope Option            | What is assessed                                                                  |
|-------------------------|-----------------------------------------------------------------------------------|
| `test-coverage`         | Presence and quality of tests; RED/GREEN alignment; missing acceptance criteria   |
| `clean-code`            | Function length, argument count, boolean flags, dead code, naming conventions     |
| `architecture`          | Layer separation, domain/infrastructure boundary, circular dependencies           |
| `security`              | Missing security tests, unvalidated inputs, auth/authz gaps, OWASP Top 10        |
| `tdd-lifecycle`         | Whether existing tests were plausibly written before or after implementation      |
| `operational-readiness` | Presence of observability hooks, deployment config, rollback strategy             |
| `documentation`         | ADR presence, API documentation, runbook coverage                                 |

### 5. Severity threshold for reporting (optional)

Specify the minimum severity level to include in the output. Defaults to `LOW` (all findings reported).

```
Options: CRITICAL | HIGH | MEDIUM | LOW
```

Setting `HIGH` suppresses LOW and MEDIUM findings and produces a shorter, more focused report when the team only wants to address blockers.

### 6. Output format preference (optional)

Specify how the remediation plan should be structured.

| Format    | Description                                                                                        |
|-----------|----------------------------------------------------------------------------------------------------|
| `backlog` | Each finding formatted as a work item with priority, owner agent, and effort estimate (default)    |
| `report`  | Narrative findings report with a summary table, suitable for stakeholder review                    |
| `both`    | Produces both formats in sequence                                                                  |

### What the user does NOT need to provide

- Implementation code or tests do not need to be written before invoking this skill.
- No architecture diagrams or design documents are required — the skill will infer architecture from the codebase itself, assisted by `🟪 architect-agent`.
- No prior knowledge of the plugin or its agents is assumed — Claude will explain findings in plain language.

---

## Analysis Dimensions

The skill analyses the codebase across twelve dimensions. Each dimension is assessed by one or more designated agents, produces a scored finding (COMPLIANT / PARTIAL / NON-COMPLIANT), and feeds directly into the prioritised remediation plan.

---

### Dimension 1 — Test Existence

**Agent:** 🟩 testing-automation-agent

**What it measures:**
Whether tests exist at all, and the ratio of test code to production code across the repository.

**How it is measured:**

- 🟩 testing-automation-agent scans the repository tree for test directories and files using language-specific conventions:
  - Java: `src/test/java/**/*Test.java`, `**/*Tests.java`, `**/*Spec.java`
  - TypeScript/Angular: `**/*.spec.ts`, `**/*.test.ts`, `cypress/`, `e2e/`
  - Python: `tests/`, `test_*.py`, `*_test.py`
- Counts production source files and test source files separately, then computes the test-to-production file ratio.
- Detects entirely untested packages or modules (directories with production classes but zero corresponding test files).
- Reports the ratio as a numeric score and flags packages below threshold.

**Evidence of compliance:**

- Test-to-production file ratio of 1:1 or greater across all packages.
- Every production class or module has at least one corresponding test file.
- No package or module directory contains production code without an accompanying test directory or test file.

**Evidence of non-compliance:**

- Test-to-production file ratio below 0.5 (fewer than one test file per two production files).
- Entire packages, layers, or modules with zero test files.
- A `src/test` or equivalent directory that is empty or absent.
- Test files that exist in the repository root but cover only a fraction of production classes.

---

### Dimension 2 — TDD Discipline

**Agent:** 🟩 testing-automation-agent, 🟢 audit-agent

**What it measures:**
Whether the codebase was developed test-first, by inspecting git history for evidence of the Red-Green-Refactor sequence: test files created before or alongside their corresponding source files.

**How it is measured:**

- 🟢 audit-agent executes `git log --diff-filter=A --name-only --pretty=format:"%H %ai %s"` to recover the creation timestamp and commit SHA for every file.
- For each production class, it locates the corresponding test file and compares the commit timestamps of initial file creation.
- 🟩 testing-automation-agent reviews whether test files pre-date or co-date their source counterparts (same commit or earlier commit) vs. post-date them.
- Identifies features where test files were added in a commit that also contains implementation, which may indicate test-after discipline.
- Detects production files that have never had a test file created at any point in git history.

**Evidence of compliance:**

- Test file for a given production class is created in the same commit as or an earlier commit than the production class itself.
- The git log shows a pattern of small commits alternating between test additions and minimal implementation additions.
- No production files exist that were committed without a corresponding test file being introduced within the same or prior commit.

**Evidence of non-compliance:**

- Production files created multiple commits or days before their corresponding test files.
- Test files introduced in a single large "add tests" commit long after the production code was written.
- Production files that have never had a test file created in git history.
- Large implementation classes introduced in a single commit with no accompanying tests.

---

### Dimension 3 — Test Types Coverage

**Agent:** 🟩 testing-automation-agent

**What it measures:**
The breadth of test types present in the codebase — unit, integration, contract, BDD/Gherkin, API, security, and performance — and whether each type covers the corresponding layer or concern.

**How it is measured:**

- 🟩 testing-automation-agent scans the codebase for framework-specific markers:
  - **Unit tests:** `@Test` (JUnit), `describe`/`it` (Jasmine/Jest), `def test_` (pytest)
  - **Integration tests:** `@SpringBootTest`, `@DataJpaTest`, `@WebMvcTest`, `TestContainers` annotations, `@IntegrationTest` markers
  - **Contract tests:** Pact files (`*.json` in `pacts/`), `@PactVerification`, `@PactTestFor`, WireMock stubs
  - **BDD/Gherkin:** `*.feature` files, `@Given`/`@When`/`@Then` step definitions (Cucumber Java, Playwright-Cucumber)
  - **API tests:** Rest-Assured, Supertest, requests-based test classes; files in `api-tests/` or `e2e/`
  - **Security tests:** test names or method names containing `injection`, `xss`, `csrf`, `auth`, `unauthorised`, `forbidden`, `boundary`; OWASP-aligned test classes
  - **Performance/load tests:** Locust, Gatling, JMeter `.jmx` files, k6 scripts
- Maps each test type to the architectural layers identified by 🟪 architect-agent.

**Evidence of compliance:**

- Unit tests covering all domain logic classes.
- Integration tests covering all infrastructure adapters (repositories, external service clients, messaging).
- Contract tests present for every external API consumer or provider relationship.
- At least one `*.feature` file per user-facing acceptance criterion where BDD was specified.
- API tests for every REST or GraphQL endpoint.
- Security boundary tests for every input-accepting endpoint.
- Performance tests for any endpoint or operation with a defined SLO.

**Evidence of non-compliance:**

- No integration tests despite the presence of database repositories, HTTP clients, or message brokers.
- No contract tests despite multiple external API dependencies.
- No `*.feature` files despite planning artefacts describing user stories in Given/When/Then form.
- No API tests for REST endpoints.
- Complete absence of any security-focused tests.
- No performance tests despite SLO requirements stated in planning or operational readiness artefacts.

---

### Dimension 4 — Test Quality

**Agent:** 🟩 testing-automation-agent, 🟨 clean-code-agent

**What it measures:**
The internal quality of individual tests: naming conventions, single-assertion focus, absence of shared mutable state, and determinism.

**How it is measured:**

- 🟩 testing-automation-agent reads every test method and evaluates:
  - **Naming:** Whether each test method name follows `should_<expectedBehaviour>_when_<condition>`. Methods named `test1`, `myTest`, `checkSomething`, or without a condition clause are flagged.
  - **Single assertion focus:** Whether each test method contains more than one logical assertion (multiple unrelated `assert*`, `expect`, or `verify` calls that test different behaviours in one method).
  - **Shared mutable state:** Whether test classes declare instance-level mutable fields that are written to in one test and read in another without a proper `@BeforeEach`/`setUp` reset. Presence of `static` mutable fields shared across tests is a hard flag.
  - **Determinism:** Whether tests call `Math.random()`, `UUID.randomUUID()` without a controlled seed, `new Date()` or `LocalDateTime.now()` without a fixed clock, or depend on environment variables without defaults.
- 🟨 clean-code-agent reviews test readability: tests with more than 6 non-assertion executable lines in the arrange phase are flagged as overly complex.

**Evidence of compliance:**

- All test method names follow `should_<expectedBehaviour>_when_<condition>` or a documented project-level variant.
- Each test method contains exactly one logical assertion cluster (one behaviour verified per test).
- No mutable static state. Instance fields reset in `@BeforeEach` or equivalent.
- All random or time-dependent values are controlled via injected clocks, seeded random, or fixed test data builders.

**Evidence of non-compliance:**

- Test methods named `test1`, `testHappyPath`, `verifyAll`, or without a condition clause.
- Test methods with five or more unrelated `assert*` calls verifying different logical outcomes.
- `static List<...>` or `static Map<...>` fields accumulating state across test executions.
- Calls to `Math.random()`, `new Date()`, `LocalDateTime.now()` without clock injection or fixed seeds.
- Tests that fail intermittently when run in isolation vs. in suite (order-sensitive).

---

### Dimension 5 — Test Independence

**Agent:** 🟩 testing-automation-agent

**What it measures:**
Whether tests are isolated from each other — specifically, whether execution order affects outcomes and whether tests share state that causes cross-test contamination.

**How it is measured:**

- 🟩 testing-automation-agent analyses:
  - Presence of `@TestMethodOrder` (JUnit) or equivalent ordering annotations without documented justification.
  - Presence of `@BeforeAll` or `setupClass`-style methods that mutate shared objects and are not counterbalanced by a `@AfterAll` teardown.
  - Database tests that do not roll back or reset between tests (`@Transactional` missing on integration test classes, `@DirtiesContext` absent when context state is mutated).
  - In-memory collections or singletons populated in one test and consumed in another.
  - Tests with hard-coded sequential identifiers (e.g., auto-increment primary keys assumed to start at a specific value) that break when test order changes.
- Recommends running the test suite in random order and comparing results, using `@TestMethodOrder(MethodOrderer.Random.class)` in JUnit 5 or `--randomly-seed` in pytest.

**Evidence of compliance:**

- No `@TestMethodOrder` annotations imposing a fixed sequence.
- All `@BeforeAll` setup is read-only (creates immutable fixtures only).
- Database integration tests use `@Transactional` or a `TRUNCATE`/rollback mechanism per test.
- Tests pass when run in isolation (each test class runnable independently) and when run as a full suite in any order.

**Evidence of non-compliance:**

- `@TestMethodOrder(MethodOrderer.OrderAnnotation.class)` with `@Order(n)` annotations on test methods, indicating a required execution sequence.
- Tests that fail when run individually but pass when run as a suite (indicating dependency on prior test side effects).
- Tests that fail when run in a randomised order.
- Shared in-memory state (e.g., a singleton repository populated by one test and expected by another).
- Integration tests that assume a specific auto-increment ID value, which breaks when prior tests are added or removed.

---

### Dimension 6 — Mock Discipline

**Agent:** 🟩 testing-automation-agent, 🟨 clean-code-agent

**What it measures:**
Whether mocks are used correctly — only at infrastructure and external-system boundaries — and not applied to domain logic, which constitutes a test validity violation.

**How it is measured:**

- 🟩 testing-automation-agent identifies all mock usage by scanning for:
  - Java: `@Mock`, `@MockBean`, `Mockito.mock(...)`, `when(...).thenReturn(...)`, `verify(...)`
  - TypeScript: `jest.mock(...)`, `spyOn(...)`, Jasmine `createSpy`, `createSpyObj`
  - Python: `unittest.mock.patch`, `MagicMock`, `mocker.patch`
- For each mocked class or interface, 🟨 clean-code-agent classifies it as:
  - **Infrastructure (correct):** Repository interfaces, HTTP clients, email services, message producers, file system adapters, external API clients, clock/time providers
  - **Domain (violation):** Domain services, domain entities, value objects, domain event publishers that contain business rules
- Reports every instance where a domain class is mocked instead of used directly with test data.
- Also flags excessive mocking: if a unit test mocks more than 3 collaborators, it is flagged as a design smell suggesting the class under test has too many dependencies.

**Evidence of compliance:**

- Only infrastructure adapters, repositories, external API clients, and framework services are mocked.
- Domain services, entities, and value objects are instantiated directly in tests using test data builders or object mothers.
- No `@MockBean` applied to domain service classes in unit tests.
- Each unit test mocks 2 or fewer collaborators.

**Evidence of non-compliance:**

- Domain service classes appear as `@Mock` or `@MockBean` targets in other domain service tests.
- Entity or value object classes are mocked via `Mockito.mock(DomainEntity.class)`.
- A unit test mocks 4 or more collaborators (indicating a God class or excessive coupling).
- Integration tests mock the repository layer they are supposed to exercise (nullifying the integration test's value).

---

### Dimension 7 — Clean Code Compliance

**Agent:** 🟨 clean-code-agent

**What it measures:**
Adherence to the Clean Code hard constraints enforced by the plugin: function length, argument count, boolean arguments, dead code, circular dependencies, and framework leakage into the domain.

**How it is measured:**

- 🟨 clean-code-agent performs static analysis on every production source file:
  - **Function/method length:** Counts executable lines (variable declarations, assignments, method calls, return statements, conditionals). Blank lines, closing braces, and comments are excluded. Flags any function exceeding 6 executable lines.
  - **Argument count:** Flags any function or constructor with more than 2 parameters.
  - **Boolean arguments:** Scans method signatures for `boolean`, `Boolean`, `bool` parameter types. Flags every occurrence.
  - **Dead code:** Identifies private methods never called within the class, local variables assigned but never read, unreachable branches after unconditional `return`/`throw`, and unused imports.
  - **Commented-out code:** Scans for multi-line comment blocks containing syntactically valid code statements (lines starting with `//` that parse as statements).
  - **Circular dependencies:** Constructs a package/module dependency graph and identifies cycles using depth-first search.
  - **Framework leakage into domain:** Scans domain layer packages for imports from framework namespaces: `org.springframework.*`, `jakarta.*`, `javax.*`, `angular/core`, `@nestjs/*`, `fastapi`, `django.db`. Exceptions: framework-agnostic annotations such as `@Value` from non-Spring packages are evaluated case by case.

**Evidence of compliance:**

- All production functions contain 6 or fewer executable lines.
- All functions and constructors accept 2 or fewer parameters.
- No `boolean`/`bool` parameters appear in any method signature.
- No private methods exist that are never called; no unreachable code blocks.
- No commented-out code blocks.
- Dependency graph is acyclic.
- Domain layer packages contain zero imports from framework namespaces.

**Evidence of non-compliance:**

- Any method exceeding 6 executable lines (each occurrence reported with file path, line range, and actual line count).
- Any constructor or method with 3 or more parameters.
- Any method signature with a `boolean` or `Boolean` parameter.
- Unreferenced private methods or unread local variables.
- Comment blocks containing commented-out code.
- Cyclic import detected between packages (reported as cycle path: `A → B → C → A`).
- Domain entity or domain service imports `org.springframework.stereotype.Service`, `javax.persistence.Entity`, or equivalent framework annotation in the domain layer.

---

### Dimension 8 — Architecture Boundary Integrity

**Agent:** 🟪 architect-agent, 🟨 clean-code-agent

**What it measures:**
Whether the dependency direction between architectural layers is correct — specifically, that the domain layer is free from infrastructure dependencies, and that higher-level layers depend on abstractions rather than concretions.

**How it is measured:**

- 🟪 architect-agent first reconstructs the intended architecture from any existing Architecture Summary, ADR files, or README documentation. If none exist, it infers the intended layer structure from directory naming conventions (`domain`, `application`, `infrastructure`, `adapter`, `web`, `persistence`, `service`, `repository`).
- 🟨 clean-code-agent then performs import analysis on every source file:
  - Builds a directed graph of import dependencies at the package level.
  - Checks the direction of every edge against the intended layer order: `domain ← application ← infrastructure ← adapter/web`.
  - Flags any edge where a lower-level layer imports from a higher-level layer (e.g., domain imports from infrastructure, or application layer imports from web adapter).
  - Identifies framework annotations in domain classes (covered also by Dimension 7 but evaluated here from the architectural perspective).
  - Checks whether domain interfaces are defined in the domain layer and implemented in infrastructure (Dependency Inversion Principle), vs. infrastructure interfaces leaked into the domain.

**Evidence of compliance:**

- Domain layer has zero imports from infrastructure, adapter, web, or persistence packages.
- Application layer imports domain only; it does not import infrastructure concretions directly.
- Infrastructure implements domain-defined interfaces (ports); domain does not reference infrastructure classes.
- Dependency graph arrows point inward toward the domain; no outward arrows from domain to outer layers.
- All external framework integrations (JPA, Spring, Angular services) are confined to infrastructure or adapter layers.

**Evidence of non-compliance:**

- Domain entity class imports a JPA `@Entity` annotation from `jakarta.persistence` or equivalent (domain awareness of persistence mechanism).
- Domain service directly imports a Spring `@Repository` implementation class rather than its domain interface.
- Application service layer imports from web adapter layer (e.g., imports a controller DTO class into a service).
- Infrastructure class is referenced directly from domain without an intervening port interface.
- A circular dependency between domain and infrastructure packages exists.

---

### Dimension 9 — Security Test Coverage

**Agent:** 🟥 security-agent

**What it measures:**
Whether the existing test suite covers the OWASP Top 10 attack surfaces, injection scenarios, authentication and authorisation boundaries, and input validation edge cases.

**How it is measured:**

- 🟥 security-agent audits the test suite for coverage of the following attack categories, searching by test method name, annotation, and assertion content:

  | OWASP Category | What is looked for in tests |
  |---|---|
  | A01 Broken Access Control | Tests asserting 403/401 responses when accessing resources without required roles; tests for horizontal privilege escalation |
  | A02 Cryptographic Failures | Tests verifying passwords are not stored in plain text; tests for HTTPS enforcement |
  | A03 Injection | Tests submitting SQL injection payloads (`' OR 1=1`, `; DROP TABLE`); XSS payloads (`<script>`); command injection payloads |
  | A04 Insecure Design | Tests for business logic abuse (negative quantities, price manipulation, skipped workflow steps) |
  | A05 Security Misconfiguration | Tests verifying default credentials are rejected; tests for exposed debug endpoints returning 404 in production profile |
  | A06 Vulnerable Components | Dependency scanning evidence (OWASP Dependency Check, Snyk) in CI logs or build configuration |
  | A07 Auth and Session | Tests for expired token rejection; tests for session fixation; tests for logout invalidation |
  | A08 Integrity Failures | Tests verifying serialised data is not blindly trusted; tests for CSRF token validation |
  | A09 Logging/Monitoring | Tests asserting security events are logged; tests verifying sensitive fields are masked in logs |
  | A10 SSRF | Tests submitting internal IP addresses or `localhost` URLs to URL-accepting fields and asserting rejection |

- Assigns a severity weight to each missing category: CRITICAL (A01, A03, A07), HIGH (A02, A04, A08, A10), MEDIUM (A05, A09), LOW (A06 if dependency scanning is present in CI).

**Evidence of compliance:**

- At least one test explicitly covering each OWASP Top 10 category relevant to the application's surface area.
- Injection tests present for every endpoint that accepts user-supplied string input.
- Auth tests present for every protected resource, verifying 401 when unauthenticated and 403 when authenticated but unauthorised.
- Input boundary validation tests verifying rejection of null, empty, overlong, and special-character inputs.

**Evidence of non-compliance:**

- No tests asserting 401/403 responses for protected endpoints.
- No injection payload tests for any input-accepting endpoint.
- No tests for expired or tampered authentication tokens.
- No CSRF or integrity validation tests for state-changing operations.
- No tests verifying that internal URLs or localhost addresses are rejected in URL-accepting fields.
- No OWASP Dependency Check, Snyk, or equivalent tool configured in the build.

---

### Dimension 10 — Coverage Metrics

**Agent:** 🟩 testing-automation-agent, 🟢 audit-agent

**What it measures:**
Quantitative code coverage at the line, branch, and — where tooling permits — mutation level, and whether coverage thresholds are enforced in the build.

**How it is measured:**

- 🟢 audit-agent inspects build configuration files for coverage tool configuration:
  - Java: JaCoCo in `pom.xml` or `build.gradle`; Pitest for mutation coverage
  - TypeScript/Angular: Istanbul/nyc via `angular.json` `codeCoverageExclude` and `coverageThreshold`; Stryker for mutation
  - Python: coverage.py via `.coveragerc` or `pyproject.toml`; mutmut or cosmic-ray for mutation
- Reads existing coverage reports if present (`target/site/jacoco/`, `coverage/`, `.nyc_output/`).
- 🟩 testing-automation-agent evaluates:
  - Whether line coverage is configured and at what threshold.
  - Whether branch coverage is configured and at what threshold.
  - Whether coverage enforcement (build failure below threshold) is active.
  - Whether mutation coverage tooling is present (optional but scored as best-practice compliance).
- Reports the coverage percentages found, or flags their absence if no reports exist.

**Evidence of compliance:**

- Line coverage threshold of 80% or above configured and enforced in the build.
- Branch coverage threshold configured (even if lower than line coverage threshold).
- Build fails when coverage drops below configured thresholds.
- Coverage reports are generated as build artefacts.
- Mutation coverage tooling present with a configured survived-mutant threshold (optional; scored as advanced compliance).

**Evidence of non-compliance:**

- No coverage tool configured in the build.
- Coverage tool present but no threshold configured (coverage is reported but not enforced).
- Coverage threshold set below 60% for line coverage.
- No branch coverage threshold configured despite conditional logic in production code.
- Coverage reports absent or excluded from CI artefacts.
- Mutation testing entirely absent despite a codebase older than 6 months with stable APIs.

---

### Dimension 11 — Documentation Alignment

**Agent:** 🔷 technical-documentation-agent, 🟩 testing-automation-agent

**What it measures:**
Whether tests map to stated acceptance criteria and documented requirements, and whether orphan tests exist (tests with no corresponding documented requirement or user story).

**How it is measured:**

- 🔷 technical-documentation-agent reads all available planning artefacts: `*.feature` files, `CLAUDE.md`, README sections, ADR files, OpenAPI/Swagger specs, user story documents.
- 🟩 testing-automation-agent reads all test files and extracts test names and descriptions.
- Cross-references test names against acceptance criteria:
  - BDD step definitions are cross-referenced against `*.feature` files.
  - Unit test method names are cross-referenced against user story acceptance criteria (matching on key terms).
  - API tests are cross-referenced against OpenAPI `operationId` or endpoint paths.
- Identifies:
  - **Orphan tests:** Tests with no traceable requirement in any planning artefact.
  - **Uncovered criteria:** Acceptance criteria from planning artefacts with no corresponding test.
  - **Stale tests:** Tests referencing functionality that no longer exists in production code (dead test code).

**Evidence of compliance:**

- Every test method name or BDD scenario title maps to at least one acceptance criterion in planning documents or feature files.
- Every acceptance criterion stated in planning artefacts has at least one corresponding test.
- No test methods exist that reference classes, methods, or behaviours absent from production code.
- `*.feature` files exist for all user-facing behaviours described in user stories.

**Evidence of non-compliance:**

- Tests with names like `testLegacyBehaviour`, `oldFlowTest`, or `checkDeprecatedEndpoint` that reference removed functionality.
- Acceptance criteria stated in planning artefacts or feature files with zero corresponding test methods.
- Test classes covering behaviours not described in any planning artefact (unexplained test coverage with no business rationale).
- BDD step definitions that have no matching `*.feature` file scenario (orphaned step definitions).

---

### Dimension 12 — CI/CD Integration

**Agent:** ⚫ devops-agent

**What it measures:**
Whether tests are executed in the CI/CD pipeline, whether the pipeline fails when tests fail, and whether the quality gates enforced by this plugin are represented in the pipeline configuration.

**How it is measured:**

- ⚫ devops-agent reads all pipeline configuration files:
  - GitHub Actions: `.github/workflows/*.yml`
  - GitLab CI: `.gitlab-ci.yml`
  - Jenkins: `Jenkinsfile`
  - CircleCI: `.circleci/config.yml`
  - Azure Pipelines: `azure-pipelines.yml`
  - Bitbucket Pipelines: `bitbucket-pipelines.yml`
- For each pipeline, it checks:
  - Whether a test execution step is present (`mvn test`, `ng test --watch=false`, `pytest`, `npm test`, `./gradlew test`).
  - Whether the pipeline step is configured to fail the build on test failure (non-zero exit code propagation).
  - Whether coverage reporting is present as a pipeline step.
  - Whether coverage threshold enforcement is present (pipeline step that fails if coverage drops).
  - Whether security scanning (OWASP Dependency Check, Snyk, Trivy) is present as a pipeline step.
  - Whether the pipeline runs on every pull request (not only on merge to main).
  - Whether any step is configured with `continue-on-error: true` or equivalent that would allow the pipeline to pass despite test failures.

**Evidence of compliance:**

- At least one pipeline configuration file exists.
- A test execution step is present and runs before any deployment step.
- The pipeline fails (non-zero exit) when tests fail — no `continue-on-error` or `ignoreTestFailure=true` on the test step.
- Coverage reporting step generates artefacts stored in the pipeline run.
- Pipeline runs on every pull request, not only on merge.
- Security dependency scanning is present as a pipeline step.
- No deployment step can execute unless all test and coverage steps have passed.

**Evidence of non-compliance:**

- No pipeline configuration file detected in the repository.
- Pipeline configuration exists but contains no test execution step.
- Test execution step present but marked `continue-on-error: true` or `allow_failure: true`.
- `ignoreTestFailure=true` set on a Maven Surefire or Gradle test task.
- Coverage step present but thresholds not enforced (only reporting, no build failure on drop).
- Pipeline only triggers on push to `main` or `master`, not on pull request branches.
- Deployment steps appear before test steps in pipeline stage ordering.
- No security scanning step present despite third-party dependencies in the build.

---

## Agent Orchestration Map

The analysis is a read-only, fan-in/fan-out pipeline. No agent writes code or tests. Every agent feeds its findings upstream into a central synthesis step performed by `🟢 audit-agent`, which produces the final scorecard and remediation plan.

```
/analyse-code-base-for-tdd invoked
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1 — INVENTORY  (parallel fan-out, read-only)         │
│                                                             │
│  🟤 research-agent ──────────────────────────────────────┐  │
│    Discovers tech stack, build tools, frameworks,        │  │
│    language versions, external dependencies.             │  │
│                                                          │  │
│  🟩 testing-automation-agent ────────────────────────────┤  │
│    Catalogues all test files, frameworks, test types,    │  │
│    test-to-source ratios, naming conventions, assertion  │  │
│    styles, and failing/missing test coverage.            │  │
│                                                          │  │
│  🟨 clean-code-agent ────────────────────────────────────┤  │
│    Scans for Clean Code violations: function length,     │  │
│    argument counts, boolean args, dead code, commented   │  │
│    code, naming quality, circular deps, framework        │  │
│    leakage into domain.                                  │  │
│                                                          │  │
│  🟥 security-agent ──────────────────────────────────────┤  │
│    Identifies missing security test coverage (auth,      │  │
│    input validation, injection, OWASP gaps) and flags    │  │
│    any obvious implementation-level security smells.     │  │
│                                                          │  │
│  🟪 architect-agent ─────────────────────────────────────┤  │
│    Assesses architectural fitness: layer separation,     │  │
│    boundary integrity, dependency direction, ADR         │  │
│    existence, domain isolation.                          │  │
│                                                          │  │
│  ⚫ devops-agent ────────────────────────────────────────┤  │
│    Inspects CI/CD pipelines for test execution,          │  │
│    coverage enforcement, quality gates, and automated    │  │
│    build verification.                                   │  │
│                                                          │  │
│  🟧 integration-agent ───────────────────────────────────┘  │
│    Checks integration and contract test coverage for     │  │
│    APIs, events, and external system boundaries.         │  │
└──────────────────────────────┬──────────────────────────────┘
                               │  all findings
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  PHASE 2 — SYNTHESIS  (sequential)                          │
│                                                             │
│  🟢 audit-agent                                             │
│    Aggregates all findings from Phase 1.                    │
│    Calculates TDD Compliance Score across all dimensions.   │
│    Produces the ranked remediation plan.                    │
│    Assigns severity (CRITICAL / HIGH / MEDIUM / LOW) to    │
│    each gap.                                                │
│    Maps gaps to remediation sprints.                        │
└──────────────────────────────┬──────────────────────────────┘
                               │  scorecard + plan
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  PHASE 3 — REMEDIATION PLANNING  (sequential)               │
│                                                             │
│  🟦 planning-agent                                          │
│    Consumes the audit-agent synthesis.                      │
│    Produces sprint-by-sprint remediation plan:              │
│    - Sprint goal (which gap(s) to close)                    │
│    - Acceptance criteria per sprint                         │
│    - /tdd-clean-code-workflow invocation per sprint         │
│    - Priority order (CRITICAL gaps first)                   │
│    - Dependencies between sprints                           │
└─────────────────────────────────────────────────────────────┘
```

**Feed summary:**

| From | To | What is fed |
|------|----|-------------|
| 🟤 research-agent | 🟢 audit-agent | Tech stack inventory, framework versions |
| 🟩 testing-automation-agent | 🟢 audit-agent | Test catalogue, test gaps, TDD discipline findings |
| 🟨 clean-code-agent | 🟢 audit-agent | Clean Code violations per file/function |
| 🟥 security-agent | 🟢 audit-agent | Missing security test coverage, implementation smells |
| 🟪 architect-agent | 🟢 audit-agent | Architectural fitness findings, ADR gaps |
| ⚫ devops-agent | 🟢 audit-agent | CI/CD pipeline gaps |
| 🟧 integration-agent | 🟢 audit-agent | Integration and contract test gaps |
| 🟢 audit-agent | 🟦 planning-agent | Scored findings, ranked gap list |
| 🟦 planning-agent | user | Sprint-by-sprint remediation plan |

---

## Workflow

This skill executes in three sequential phases. No phase may begin before the preceding phase is complete. Every agent invocation must display its label before producing output.

---

### Phase 1 — Discovery

**Purpose:** Establish the scope of the analysis, understand the intended architecture, and produce a complete test coverage matrix that maps every production class and function to its test — or records its absence.

---

#### Step 1.1 — Scope Elicitation

Claude asks the following questions in sequence. Wait for the user's answer to each before proceeding.

```
Question 1:
Which directory or repository would you like me to analyse?
Please provide the absolute path or repository URL.

Question 2:
What is the primary language and framework used in this codebase?
Examples: Java / Spring Boot, TypeScript / Angular, Python / FastAPI, JavaScript / Node.js

Question 3:
What is the scope of this analysis?
  (a) Full codebase — analyse every module and package
  (b) Specific module or package — I will provide the path or name
  (c) A subset of layers — for example, domain layer only, or service layer only

If you chose (b) or (c), please specify which module, package, or layer.

Question 4:
Are there any existing documentation artefacts I should read first?
Examples: README.md, ARCHITECTURE.md, ADRs, API specs, OpenAPI definitions, design docs.
If yes, please provide the paths or URLs.

Question 5:
Are there any known problem areas or suspected gaps you would like me to prioritise?
If yes, please describe them. If no, I will treat all dimensions equally.
```

Record all answers as the **Analysis Scope Document** before proceeding to Step 1.2.

---

#### Step 1.2 — Architecture Understanding

**Agent:** `🟪 architect-agent`

`architect-agent` reads all available documentation artefacts identified in Step 1.1, then performs a structural scan of the codebase to derive the intended architecture.

`architect-agent` produces the **Architecture Baseline Report**:

```
## 🟪 architect-agent — Architecture Baseline Report

### Intended Architecture
<Derived architecture style: Layered, Hexagonal, Clean Architecture, CQRS, etc.>

### Package and Layer Structure
<Map of packages/modules to their architectural role: domain, application, infrastructure, presentation, etc.>

### Key Boundaries
<Which packages should not depend on which other packages.>

### Patterns Identified
<Architectural patterns in use: Repository, Factory, Strategy, Command, Event, etc.>

### External Dependencies
<Third-party libraries, frameworks, databases, message brokers, APIs.>

### Architecture Documentation Quality
<Assessment of whether README, ADRs, and docs accurately describe the actual codebase.>

### Deviations Observed
<Any places where the code structure deviates from documented intent.>
```

---

#### Step 1.3 — Test File Mapping

**Agent:** `🟩 testing-automation-agent`

`testing-automation-agent` scans the codebase to locate all test files and map them to their corresponding production files.

The scan must:
- Identify all test files by convention (e.g. `*Test.java`, `*.spec.ts`, `test_*.py`, `*_test.go`)
- Identify test type for each file (unit, integration, contract, BDD, E2E)
- Map each test file to the production file or class it covers
- Identify production files that have no corresponding test file
- Identify production files that have partial test coverage (tests exist but acceptance criteria are incomplete)

`testing-automation-agent` produces the **Test Coverage Matrix**:

```
## 🟩 testing-automation-agent — Test Coverage Matrix

### Summary
Total production files: N
Files with tests: N
Files without tests: N
Test coverage ratio: N%

### Coverage Matrix

| Production File / Class | Test File | Test Type | Status |
|------------------------|-----------|-----------|--------|
| src/domain/Order.java  | OrderTest.java | Unit | COVERED |
| src/domain/Payment.java | — | — | NO TEST |
| src/service/OrderService.java | OrderServiceTest.java | Unit | PARTIAL |
| ... | ... | ... | ... |

Status values:
- COVERED — test file exists and maps to all public methods
- PARTIAL — test file exists but does not cover all public methods or acceptance criteria
- NO TEST — no test file found for this production file
- TEST ONLY — test file exists but no corresponding production file (orphaned test)

### Files Without Any Test Coverage
<List of every production file with status NO TEST.>

### Files With Partial Coverage
<List of every production file with status PARTIAL, noting which methods or criteria are untested.>

### Orphaned Tests
<List of test files that do not map to any known production file.>
```

**Gate — Phase 1 Complete:** Architecture Baseline Report produced. Test Coverage Matrix produced. Do not begin Phase 2 until both outputs exist.

---

### Phase 2 — Analysis

**Purpose:** Evaluate the codebase across 12 compliance dimensions. All 12 dimensions are analysed concurrently. Each dimension produces a structured finding set.

Claude announces the start of parallel analysis:

```
Phase 2 — Analysis is now running. All 12 dimensions are being evaluated in parallel.
This may take a moment. Results will be presented dimension by dimension as they complete.
```

---

#### Dimension Assignment

| Dimension | Agent |
|-----------|-------|
| 1. Test Existence | 🟩 testing-automation-agent |
| 2. TDD Discipline | 🟩 testing-automation-agent |
| 3. Test Types | 🟩 testing-automation-agent |
| 4. Test Quality | 🟩 testing-automation-agent |
| 5. Test Independence | 🟩 testing-automation-agent |
| 6. Mock Discipline | 🟩 testing-automation-agent |
| 7. Coverage Metrics | 🟩 testing-automation-agent |
| 8. Documentation Alignment | 🟩 testing-automation-agent |
| 9. Clean Code Compliance | 🟨 clean-code-agent |
| 10. Architecture Boundary Integrity | 🟨 clean-code-agent |
| 11. Security Test Coverage | 🟥 security-agent |
| 12. CI/CD Integration | ⚫ devops-agent |

---

#### Dimension 1 — Test Existence

**Agent:** `🟩 testing-automation-agent`

Using the Test Coverage Matrix from Phase 1, classify the entire production codebase by test existence.

Finding format:

```
### Dimension 1 — Test Existence

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: ≥ 90% of production files have at least one test file
- PARTIAL: 60–89% of production files have at least one test file
- NON-COMPLIANT: < 60% of production files have at least one test file

Findings:
| File | Package | Layer | Status | Priority |
|------|---------|-------|--------|----------|
| ... | ... | ... | NO TEST / PARTIAL / COVERED | HIGH / MEDIUM / LOW |

Priority assignment:
- HIGH: domain logic, business rules, service layer
- MEDIUM: infrastructure adapters, repositories
- LOW: configuration, DTOs, value objects with no logic
```

---

#### Dimension 2 — TDD Discipline

**Agent:** `🟩 testing-automation-agent`

Assess whether tests were written before implementation or after. Evidence is gathered from:
- Git commit history (if accessible): test commits before implementation commits
- Test content: tests that test implementation details rather than behaviour indicate post-hoc test writing
- Trivial tests: tests that merely verify getters/setters indicate retrofitted tests
- Missing negative cases: production code with no failure-path tests indicates implementation-first development

Finding format:

```
### Dimension 2 — TDD Discipline

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: Evidence of test-first development across majority of codebase; tests describe behaviour
- PARTIAL: Mixed evidence; some modules show test-first, others show retrofitted tests
- NON-COMPLIANT: Tests predominantly describe implementation detail; negative paths absent; trivial getter tests dominate

Evidence Summary:
| Indicator | Count | Assessment |
|-----------|-------|-----------|
| Tests describing behaviour (should_X_when_Y naming) | N | Positive |
| Tests testing implementation detail | N | Negative |
| Classes with only happy-path tests | N | Negative |
| Classes with no failure/exception tests | N | Negative |
| Trivial getter/setter tests | N | Negative |

Findings:
<List of specific files or test classes that show clear implementation-first patterns, with explanation.>
```

---

#### Dimension 3 — Test Types

**Agent:** `🟩 testing-automation-agent`

Assess whether the test suite covers all required test types for the architecture identified in Phase 1.

Finding format:

```
### Dimension 3 — Test Types

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: Unit, integration, and at least one higher-order type (contract, BDD, API) present
- PARTIAL: Unit tests present; integration tests missing or minimal; no higher-order types
- NON-COMPLIANT: Only unit tests or only integration tests; no diversity

Test Type Inventory:
| Test Type | Present | File Count | Notes |
|-----------|---------|-----------|-------|
| Unit | Yes / No | N | ... |
| Integration | Yes / No | N | ... |
| Contract | Yes / No | N | ... |
| BDD / Cucumber | Yes / No | N | ... |
| API / REST-Assured | Yes / No | N | ... |
| Performance | Yes / No | N | ... |
| Security | Yes / No | N | ... |
| E2E | Yes / No | N | ... |

Gaps:
<List of test types that are absent but required given the architecture.>
```

---

#### Dimension 4 — Test Quality

**Agent:** `🟩 testing-automation-agent`

Assess the quality of existing tests against the plugin's test quality standards.

Quality criteria assessed:
- Tests use the `should_<expectedBehaviour>_when_<condition>` naming convention (or equivalent)
- Each test expresses a single behaviour (one assertion per test)
- Tests use realistic but non-production data
- Tests are deterministic (no random data, no uncontrolled time dependencies)
- Tests fail for the right reason (assertion failure, not setup failure)
- Tests describe behaviour, not implementation

Finding format:

```
### Dimension 4 — Test Quality

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: ≥ 85% of tests meet all quality criteria
- PARTIAL: 60–84% of tests meet quality criteria; identifiable pattern of failure
- NON-COMPLIANT: < 60% of tests meet quality criteria

Quality Findings:
| Quality Issue | Affected Tests | Count | Example |
|--------------|---------------|-------|---------|
| Non-behaviour-describing name | ... | N | ... |
| Multiple assertions per test | ... | N | ... |
| Non-deterministic data | ... | N | ... |
| Setup failure masking assertion failure | ... | N | ... |
| Tests testing implementation detail | ... | N | ... |
```

---

#### Dimension 5 — Test Independence

**Agent:** `🟩 testing-automation-agent`

Assess whether tests are properly isolated and do not depend on execution order or shared mutable state.

Evidence gathered from:
- Shared static fields used as test state
- Tests that call each other or depend on test execution order
- Missing `@BeforeEach` / `beforeEach` / `setUp` teardown between tests
- Database or file system state leaking between tests

Finding format:

```
### Dimension 5 — Test Independence

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: No shared mutable state; tests are fully isolated
- PARTIAL: Minor shared state; tests generally independent but ordering risk exists
- NON-COMPLIANT: Tests depend on execution order; shared mutable state detected

Findings:
| File | Issue | Severity |
|------|-------|---------|
| ... | Shared static mutable field used across tests | HIGH |
| ... | No teardown between tests that write to database | MEDIUM |
| ... | Test method names suggest ordering dependency | LOW |
```

---

#### Dimension 6 — Mock Discipline

**Agent:** `🟩 testing-automation-agent`

Assess whether mocks are used appropriately — only at architectural boundaries — and whether domain logic is incorrectly mocked.

Finding format:

```
### Dimension 6 — Mock Discipline

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: Mocks used only at infrastructure and external-service boundaries; no domain logic mocked
- PARTIAL: Mostly correct; some unnecessary mocking of domain internals
- NON-COMPLIANT: Domain logic mocked; tests verify mock invocations rather than behaviour

Findings:
| File | Mocked Class | Is This a Domain Class? | Assessment |
|------|-------------|------------------------|-----------|
| ... | PaymentRepository | No (infrastructure) | CORRECT |
| ... | OrderDomainService | Yes (domain) | VIOLATION |
| ... | ExternalPaymentGateway | No (external) | CORRECT |

Violations:
<List every instance of domain logic being mocked, with file and line reference.>
```

---

#### Dimension 7 — Coverage Metrics

**Agent:** `🟩 testing-automation-agent`

If a coverage report is available (JaCoCo, Istanbul, pytest-cov, etc.) or can be generated, report coverage at class, method, and line level. If no coverage tooling is configured, note this as a finding.

Finding format:

```
### Dimension 7 — Coverage Metrics

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: Line coverage ≥ 80%; branch coverage ≥ 70%; all domain classes ≥ 90%
- PARTIAL: Line coverage 60–79%; domain classes partially covered
- NON-COMPLIANT: Line coverage < 60%; coverage tooling absent; domain classes uncovered

Coverage Report:
| Layer | Line Coverage | Branch Coverage | Method Coverage |
|-------|-------------|----------------|----------------|
| Domain | N% | N% | N% |
| Application / Service | N% | N% | N% |
| Infrastructure | N% | N% | N% |
| Presentation | N% | N% | N% |
| Overall | N% | N% | N% |

Coverage Tooling Status: CONFIGURED | NOT CONFIGURED | MISCONFIGURED

Lowest Coverage Classes:
<List the 10 production classes with the lowest coverage, sorted ascending.>
```

---

#### Dimension 8 — Documentation Alignment

**Agent:** `🟩 testing-automation-agent`

Assess whether test names, test scenarios, and test coverage align with documented acceptance criteria, user stories, and API specifications.

Finding format:

```
### Dimension 8 — Documentation Alignment

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: Every documented acceptance criterion has a corresponding test; test names reference business behaviour
- PARTIAL: Most documented criteria are covered; some gaps; test names partially describe business context
- NON-COMPLIANT: Tests do not reference acceptance criteria; tests describe only technical operations

Findings:
| Documented Criterion / Feature | Corresponding Test | Status |
|-------------------------------|-------------------|--------|
| ... | ... | COVERED / MISSING / PARTIAL |

Documentation Artefacts Assessed:
<List of docs reviewed: README, OpenAPI spec, ADRs, feature files, etc.>

Undocumented Production Code:
<Production classes or endpoints that have no corresponding documentation or acceptance criteria.>
```

---

#### Dimension 9 — Clean Code Compliance

**Agent:** `🟨 clean-code-agent`

Assess the production codebase against all Clean Code hard constraints and principles defined in the plugin.

Finding format:

```
### Dimension 9 — Clean Code Compliance

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: All hard constraints met across ≥ 90% of production functions
- PARTIAL: Hard constraints met in most places; isolated violations; refactoring feasible
- NON-COMPLIANT: Systematic violations of hard constraints across codebase

Hard Constraint Assessment:
| Constraint | Violation Count | Most Affected Files | Severity |
|------------|----------------|-------------------|---------|
| Max 6 executable lines per function | N | ... | HIGH if N > 20 |
| Max 2 arguments per function | N | ... | HIGH if N > 10 |
| Boolean arguments present | N | ... | MEDIUM |
| Commented-out code | N | ... | LOW |
| Dead code | N | ... | MEDIUM |
| Circular dependencies | N | ... | HIGH |
| Framework leakage into domain | N | ... | HIGH |

Principle Violations:
| Principle | Observation | Files Affected |
|-----------|------------|---------------|
| SRP | Classes with multiple reasons to change | ... |
| DRY | Duplicated logic blocks detected | ... |
| Tell Don't Ask | Data extraction patterns in service layer | ... |
| Primitive Obsession | Domain concepts represented as primitives | ... |
| God Classes | Classes exceeding cohesion threshold | ... |

Top 10 Functions Requiring Immediate Refactoring:
<List function name, file, line count, argument count, and primary violation.>
```

---

#### Dimension 10 — Architecture Boundary Integrity

**Agent:** `🟨 clean-code-agent`

Using the Architecture Baseline Report from Phase 1, assess whether the codebase respects the identified architectural boundaries.

Finding format:

```
### Dimension 10 — Architecture Boundary Integrity

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: Domain layer has no imports from infrastructure or framework packages; all boundaries respected
- PARTIAL: Minor boundary leakage in isolated files; boundaries largely intact
- NON-COMPLIANT: Systematic framework leakage into domain; layers coupled in multiple directions

Boundary Violation Assessment:
| From Layer | To Layer | Violation Count | Example Import | Assessment |
|-----------|---------|----------------|----------------|-----------|
| Domain | Infrastructure | N | import org.springframework.data... | VIOLATION |
| Domain | Presentation | N | import org.springframework.web... | VIOLATION |
| Application | Domain | N | import ... | CORRECT |
| Infrastructure | Domain | N | import ... | CORRECT |

Circular Dependency Detection:
| Cycle | Files Involved | Severity |
|-------|--------------|---------|
| Package A → Package B → Package A | ... | HIGH |

Framework Leakage in Domain:
<List every domain class that imports a framework annotation or type.>
```

---

#### Dimension 11 — Security Test Coverage

**Agent:** `🟥 security-agent`

Assess whether the test suite covers the security threat surface implied by the architecture and technology stack.

Finding format:

```
### Dimension 11 — Security Test Coverage

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: All major threat categories covered by tests; input validation, auth, and injection tested
- PARTIAL: Some security tests present; key threat categories uncovered
- NON-COMPLIANT: No security tests detected; input validation untested; no auth boundary tests

Threat Surface Assessment:
| Threat Category | Test Present | Test File | Gap Description |
|----------------|-------------|-----------|----------------|
| Input Validation | Yes / No | ... | ... |
| SQL / NoSQL Injection | Yes / No | ... | ... |
| Authentication Bypass | Yes / No | ... | ... |
| Authorisation / RBAC | Yes / No | ... | ... |
| XSS | Yes / No | ... | ... |
| CSRF | Yes / No | ... | ... |
| SSRF | Yes / No | ... | ... |
| Data Exposure | Yes / No | ... | ... |
| Insecure Deserialisation | Yes / No | ... | ... |
| Rate Limiting | Yes / No | ... | ... |

Critical Security Test Gaps:
<List every HIGH or CRITICAL threat category for which no test exists.>

Security Debt Assessment:
<Overall assessment of the security test posture — how exposed is this codebase if these gaps persist?>
```

---

#### Dimension 12 — CI/CD Integration

**Agent:** `⚫ devops-agent`

Assess whether the CI/CD pipeline integrates tests, coverage gates, and security scanning as required by the plugin standards.

Finding format:

```
### Dimension 12 — CI/CD Integration

Score: COMPLIANT | PARTIAL | NON-COMPLIANT

Criteria:
- COMPLIANT: Pipeline runs all test types; coverage gate configured; security scanning integrated; deployment gated on test pass
- PARTIAL: Pipeline runs tests; coverage or security scanning absent; deployment gate present but incomplete
- NON-COMPLIANT: No CI/CD detected; tests not part of pipeline; deployment not gated on tests

Pipeline Assessment:
| Check | Status | Tool / Step | Notes |
|-------|--------|------------|-------|
| Unit tests in pipeline | Yes / No | ... | ... |
| Integration tests in pipeline | Yes / No | ... | ... |
| Coverage reporting | Yes / No | ... | ... |
| Coverage gate (build fails if below threshold) | Yes / No | ... | ... |
| SAST integration | Yes / No | ... | ... |
| Dependency vulnerability scan | Yes / No | ... | ... |
| Container image scan | Yes / No | ... | ... |
| Deployment blocked on test failure | Yes / No | ... | ... |
| Test results published as artefacts | Yes / No | ... | ... |

Pipeline Files Located:
<List of CI/CD config files found: .github/workflows/*.yml, Jenkinsfile, .gitlab-ci.yml, cloudbuild.yaml, etc.>

Missing Pipeline Stages:
<List every required stage that is absent.>
```

---

**Gate — Phase 2 Complete:** All 12 dimension reports produced. Do not begin Phase 3 until all dimension findings exist.

---

### Phase 3 — Synthesis and Reporting

**Purpose:** Aggregate all findings into a unified compliance scorecard, produce a prioritised remediation plan, and generate an audit summary.

---

#### Step 3.1 — Compliance Scorecard

Claude aggregates all 12 dimension scores into a single scorecard:

```
## Compliance Scorecard

| # | Dimension | Agent | Score |
|---|-----------|-------|-------|
| 1 | Test Existence | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 2 | TDD Discipline | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 3 | Test Types | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 4 | Test Quality | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 5 | Test Independence | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 6 | Mock Discipline | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 7 | Coverage Metrics | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 8 | Documentation Alignment | 🟩 testing-automation-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 9 | Clean Code Compliance | 🟨 clean-code-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 10 | Architecture Boundary Integrity | 🟨 clean-code-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 11 | Security Test Coverage | 🟥 security-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |
| 12 | CI/CD Integration | ⚫ devops-agent | COMPLIANT / PARTIAL / NON-COMPLIANT |

Overall Score:
- COMPLIANT: 10–12 dimensions COMPLIANT
- PARTIAL: 6–9 dimensions COMPLIANT or PARTIAL; no NON-COMPLIANT in dimensions 1, 9, 11
- NON-COMPLIANT: < 6 dimensions COMPLIANT, or any NON-COMPLIANT in dimensions 1, 9, or 11
```

---

#### Step 3.2 — Prioritised Remediation Plan

**Agent:** `🟦 planning-agent`

`planning-agent` reads all 12 dimension finding sets and the Compliance Scorecard, then produces a prioritised remediation plan.

Priority assignment rules:
- **P0 — Immediate (this sprint):** NON-COMPLIANT scores in security, test existence, or architecture boundary dimensions; CRITICAL or HIGH security test gaps
- **P1 — High (next sprint):** NON-COMPLIANT scores in other dimensions; PARTIAL scores in security or test existence
- **P2 — Medium (this quarter):** PARTIAL scores in quality, independence, mock discipline, or clean code dimensions
- **P3 — Low (backlog):** PARTIAL scores in documentation alignment, CI/CD integration, or coverage metrics where threshold is close

Output format:

```
## 🟦 planning-agent — Prioritised Remediation Plan

### Executive Summary
<Two to three sentences summarising the overall TDD and Clean Code posture of the codebase.>

### Remediation Items

#### P0 — Immediate Action Required

| ID | Dimension | Finding | Recommended Action | Estimated Effort |
|----|-----------|---------|-------------------|-----------------|
| REM-001 | Security Test Coverage | No input validation tests for OrderController | Add security boundary tests for all controller inputs | S (< 1 day) |
| REM-002 | Architecture Boundary | Domain imports Spring @Repository | Extract repository interface to domain; move implementation to infrastructure | M (1–3 days) |

#### P1 — High Priority

| ID | Dimension | Finding | Recommended Action | Estimated Effort |
|----|-----------|---------|-------------------|-----------------|
| REM-003 | Test Existence | 12 domain classes have no test | Write unit tests for each uncovered domain class following Red-Green-Refactor | L (3–5 days) |

#### P2 — Medium Priority

| ID | Dimension | Finding | Recommended Action | Estimated Effort |
|----|-----------|---------|-------------------|-----------------|
| REM-004 | Clean Code | 8 functions exceed 6-line limit | Refactor using Extract Method; confirm tests still pass | M (1–3 days) |

#### P3 — Backlog

| ID | Dimension | Finding | Recommended Action | Estimated Effort |
|----|-----------|---------|-------------------|-----------------|
| REM-005 | CI/CD Integration | Coverage gate not configured | Add JaCoCo / Istanbul coverage gate to pipeline at 80% threshold | S (< 1 day) |

### Suggested Sprint Breakdown

Sprint 1 (P0 items): <list remediation IDs>
Sprint 2 (P1 items): <list remediation IDs>
Sprint 3+ (P2 and P3 items): <list remediation IDs>

### TDD Re-Entry Point

Once P0 and P1 items are complete, this codebase is ready to adopt the /tdd-clean-code-workflow
skill for all new features. The following areas still require TDD retrofitting before they can
be safely modified:
<list of modules or classes requiring retrofitting>
```

---

#### Step 3.3 — Audit Summary

**Agent:** `🟢 audit-agent`

`audit-agent` is always the final agent invoked. It reads all Phase 2 findings, the Compliance Scorecard, and the Remediation Plan, then produces the Audit Summary and updates CLAUDE.md.

```
## 🟢 audit-agent — Audit Summary

### Codebase Analysed
Repository / Path: <path or URL>
Language / Framework: <language and framework>
Analysis Scope: <full codebase / specific module>
Analysis Date: <YYYY-MM-DD>

### Agents Invoked

| Order | Agent | Dimension(s) | Outcome |
|-------|-------|-------------|---------|
| 1 | 🟪 architect-agent | Architecture Baseline | Completed |
| 2 | 🟩 testing-automation-agent | 1, 2, 3, 4, 5, 6, 7, 8 | Completed |
| 3 | 🟨 clean-code-agent | 9, 10 | Completed |
| 4 | 🟥 security-agent | 11 | Completed |
| 5 | ⚫ devops-agent | 12 | Completed |
| 6 | 🟦 planning-agent | Remediation Plan | Completed |
| 7 | 🟢 audit-agent | Audit Summary | — |

### Compliance Scorecard (Summary)
<Reproduce the scorecard table from Step 3.1.>

Overall TDD and Clean Code Posture: COMPLIANT | PARTIAL | NON-COMPLIANT

### Top 3 Risks if Remediation is Deferred
1. <Highest-risk finding and consequence of inaction>
2. <Second-highest-risk finding>
3. <Third-highest-risk finding>

### Remediation Plan Reference
Total remediation items: N
P0 items: N
P1 items: N
P2 items: N
P3 items: N

### Lessons Learned
<Reusable insights from this analysis applicable to future analyses or feature work.>

1. <Lesson> — Applicable when: <condition>
2. <Lesson> — Applicable when: <condition>

### CLAUDE.md Update
```

`audit-agent` appends the following entry to CLAUDE.md:

```markdown
### YYYY-MM-DD — Codebase Analysis: <repository or module name>

Decision: TDD and Clean Code compliance analysis completed.
Reason: Baseline assessment before adopting /tdd-clean-code-workflow for new development.
Agents: architect-agent, testing-automation-agent, clean-code-agent, security-agent, devops-agent, planning-agent, audit-agent.
Overall Score: COMPLIANT | PARTIAL | NON-COMPLIANT
P0 Items: N
P1 Items: N
Reusable Learning: <one or two sentences applicable to future sessions>
Rule Changes: None | <any new rules added>
Follow-Up: Re-run /analyse-code-base-for-tdd after P0 and P1 items are resolved.
```

---

### Phase Transition Summary

| Phase | Trigger | Completion Condition |
|-------|---------|---------------------|
| Phase 1 — Discovery | User invokes `/analyse-code-base-for-tdd` and answers all five scoping questions | Architecture Baseline Report and Test Coverage Matrix both produced |
| Phase 2 — Analysis | Phase 1 complete | All 12 dimension finding sets produced |
| Phase 3 — Synthesis | Phase 2 complete | Compliance Scorecard, Remediation Plan, and Audit Summary all produced; CLAUDE.md updated |

---

### Orchestration Rules

1. Phase 1 must be complete before Phase 2 begins.
2. All 12 Phase 2 dimensions run concurrently within Phase 2.
3. Phase 3 must wait for all 12 dimension findings to exist before beginning.
4. `🟢 audit-agent` is always the final agent invoked.
5. Every agent invocation must display its label before producing output.
6. Secrets, credentials, and personal data must not appear in any finding or report.
7. Claude must not write remediation code during this skill. The skill produces analysis only. Remediation is executed using `/tdd-clean-code-workflow`.

---

## Scoring Model

### Dimension Weights

The TDD Compliance Score is a weighted aggregate across nine dimensions, each scored 0–100 before weighting.

| # | Dimension | Weight | What is measured |
|---|-----------|--------|-----------------|
| 1 | Test existence | 20% | Proportion of production source files that have at least one corresponding test file. Zero tests = 0. Full coverage of files = 100. |
| 2 | TDD discipline | 15% | Evidence that tests were written before or alongside implementation (commit history patterns, test-to-implementation commit ordering, absence of tests committed after implementation in bulk). |
| 3 | Test types | 15% | Presence of unit, integration, contract, and security test types. Missing entire categories reduce this score proportionally. |
| 4 | Test quality | 10% | Tests are readable, behaviour-describing, isolated, deterministic, and free of logic. Scores based on proportion of tests failing these criteria. |
| 5 | Clean code | 10% | Proportion of functions/classes with zero Clean Code violations against the seven hard constraints defined in CLAUDE.md. |
| 6 | Architecture | 10% | Layer separation intact, no framework leakage into domain, dependency direction correct, ADRs present for significant decisions. |
| 7 | Security tests | 10% | Coverage of OWASP Top 10 categories with dedicated tests. Each category not covered reduces this dimension score. |
| 8 | CI/CD | 5% | Tests execute automatically in the pipeline; coverage thresholds enforced; pipeline fails on test failure; no manual bypass in place. |
| 9 | Coverage | 5% | Reported line/branch coverage as a percentage, normalised to 0–100. |

**Formula:**

```
TDD Compliance Score =
  (test_existence_score × 0.20) +
  (tdd_discipline_score  × 0.15) +
  (test_types_score      × 0.15) +
  (test_quality_score    × 0.10) +
  (clean_code_score      × 0.10) +
  (architecture_score    × 0.10) +
  (security_tests_score  × 0.10) +
  (cicd_score            × 0.05) +
  (coverage_score        × 0.05)
```

All dimension scores are integers 0–100. The final score is rounded to the nearest integer.

---

### Score Thresholds

| Score | Band | Meaning | Remediation Urgency |
|-------|------|---------|---------------------|
| 90–100 | EXCELLENT | The codebase follows TDD and Clean Code disciplines comprehensively. Tests exist for all production code, are well-structured, and the CI/CD pipeline enforces quality automatically. Minor gaps may exist in fringe coverage areas or documentation. | Low — schedule maintenance improvements in normal sprint cadence. No emergency action required. |
| 75–89 | GOOD | TDD practices are largely in place. Isolated gaps exist in test types, security coverage, or clean code compliance, but the discipline is evident and systematic. | Moderate — address gaps within the current or next sprint. Prioritise missing security tests and any architecture violations before new features are added. |
| 50–74 | PARTIAL | TDD practices are inconsistently applied. Some modules are well-tested; others have little or no test coverage. Clean code constraints are partially met. CI/CD may run tests but does not enforce coverage or quality gates. | High — pause new feature development until the highest-severity gaps are closed. Begin remediation sprints immediately, starting with CRITICAL and HIGH findings. |
| 25–49 | POOR | Tests are sparse, low quality, or exist only for trivial code paths. TDD discipline is absent or was never established. Significant Clean Code and architecture violations are present. Security test coverage is minimal. | Urgent — treat as a technical debt emergency. Dedicate dedicated remediation sprints before any feature work proceeds. Escalate to engineering leadership. |
| 0–24 | CRITICAL | The codebase has effectively no meaningful test coverage, no TDD discipline, and widespread code quality violations. Security test coverage is absent. The CI/CD pipeline either does not run tests or does not enforce any gates. | Immediate — halt all feature development. Run a codebase stabilisation programme using the remediation plan produced by this skill. All new code written during remediation must follow the full /tdd-clean-code-workflow lifecycle. |

---

### Scorecard Output Format

`🟢 audit-agent` presents the scorecard before any other finding:

```
## TDD Compliance Scorecard — <Project Name>  (<Date>)

| Dimension          | Raw Score | Weight | Weighted Score |
|--------------------|-----------|--------|----------------|
| Test existence     |    /100   |  20%   |      /20       |
| TDD discipline     |    /100   |  15%   |      /15       |
| Test types         |    /100   |  15%   |      /15       |
| Test quality       |    /100   |  10%   |      /10       |
| Clean code         |    /100   |  10%   |      /10       |
| Architecture       |    /100   |  10%   |      /10       |
| Security tests     |    /100   |  10%   |      /10       |
| CI/CD              |    /100   |   5%   |       /5       |
| Coverage           |    /100   |   5%   |       /5       |
| **TOTAL**          |           |        |    **/100**    |

**Band:** EXCELLENT / GOOD / PARTIAL / POOR / CRITICAL
**Remediation Urgency:** Low / Moderate / High / Urgent / Immediate
```

The scorecard is always the first thing presented to the user. Nothing else is shown until the scorecard is complete.

---

## Output Format

This section defines every artefact that `/analyse-code-base-for-tdd` produces. There are two primary outputs: the **Analysis Report** (produced after Phase 2) and the **Remediation Plan** (produced after Phase 3). A third lightweight artefact, the **Finding**, is the atomic unit of evidence that appears inside the Analysis Report.

All outputs must be delivered in the exact templates defined below. Do not abbreviate, omit, or reorder sections. Agents must display their label before producing any section of output.

---

### Analysis Report Template

```markdown
# TDD Codebase Analysis Report

**Project:** <project name>
**Date:** <YYYY-MM-DD>
**Analysed by:** 🟢 audit-agent (orchestrating 🟩 testing-automation-agent, 🟨 clean-code-agent, 🟪 architect-agent, 🟥 security-agent, ⚫ devops-agent)
**Scope:** <directories / modules analysed>
**Excluded:** <directories / files excluded and reason>

---

## Executive Summary

<Sentence 1: State the Overall TDD Compliance Score, the band it falls in, and the single most critical structural problem found.>
<Sentence 2: Identify the two or three dimensions with the lowest scores and summarise what that means in practical terms for the team.>
<Sentence 3: State the immediate risk if the top-priority findings are left unaddressed, and whether the codebase is safe to continue adding new features to.>

---

## Dimension Scorecard

| Dimension | Status | Score (0–100) | Critical Findings |
|---|---|---|---|
| Test Existence & Coverage | COMPLIANT / AT RISK / NON-COMPLIANT / CRITICAL | 0–100 | <count> |
| TDD Sequence Integrity | COMPLIANT / AT RISK / NON-COMPLIANT / CRITICAL | 0–100 | <count> |
| Clean Code Compliance | COMPLIANT / AT RISK / NON-COMPLIANT / CRITICAL | 0–100 | <count> |
| Architecture Boundary Integrity | COMPLIANT / AT RISK / NON-COMPLIANT / CRITICAL | 0–100 | <count> |
| Security Test Coverage | COMPLIANT / AT RISK / NON-COMPLIANT / CRITICAL | 0–100 | <count> |
| **Overall TDD Compliance Score** | **COMPLIANT / AT RISK / NON-COMPLIANT / CRITICAL** | **0–100** | **<total>** |

> Score formula: (TestExistence × 0.30) + (TDDSequence × 0.25) + (CleanCode × 0.20) + (ArchBoundary × 0.15) + (SecurityTest × 0.10)

---

## Per-Dimension Detail

### Dimension 1 — Test Existence & Coverage

**Score:** <0–100> | **Status:** <band>

**Findings:**

<Repeat the Finding block for every finding in this dimension, ordered CRITICAL → HIGH → MEDIUM → LOW.>

---

### Dimension 2 — TDD Sequence Integrity

**Score:** <0–100> | **Status:** <band>

**Findings:**

<Repeat the Finding block for every finding in this dimension.>

---

### Dimension 3 — Clean Code Compliance

**Score:** <0–100> | **Status:** <band>

**Findings:**

<Repeat the Finding block for every finding in this dimension.>

---

### Dimension 4 — Architecture Boundary Integrity

**Score:** <0–100> | **Status:** <band>

**Findings:**

<Repeat the Finding block for every finding in this dimension.>

---

### Dimension 5 — Security Test Coverage

**Score:** <0–100> | **Status:** <band>

**Findings:**

<Repeat the Finding block for every finding in this dimension.>

---

## Overall TDD Compliance Score

| | |
|---|---|
| **Score** | **<0–100>** |
| **Band** | **COMPLIANT / AT RISK / NON-COMPLIANT / CRITICAL** |
| **Total Findings** | <total count> |
| **CRITICAL Findings** | <count> |
| **HIGH Findings** | <count> |
| **MEDIUM Findings** | <count> |
| **LOW Findings** | <count> |

---

## Risk Assessment

### If CRITICAL findings are not resolved

<Describe the immediate technical and process risks. Be specific: name which gates in `/tdd-clean-code-workflow` cannot be reached, which parts of the codebase are dangerous to change, and what regressions or security exposures exist today.>

### If HIGH findings are not resolved

<Describe the medium-term risks. Name which future features will be blocked or degraded, which team practices will remain inconsistent, and what the likely failure modes are under normal development velocity.>

### If MEDIUM findings are not resolved

<Describe the accumulation risk. Explain how MEDIUM findings compound over time and what the codebase will look like in three to six months if these are not addressed.>

### If LOW findings are not resolved

<Describe the quality and maintainability drift. These findings rarely cause outages but consistently increase onboarding time and code review friction.>

---

## Appendix — Finding Index

| ID | Dimension | Severity | Location | Summary |
|---|---|---|---|---|
| F-001 | <dimension> | CRITICAL / HIGH / MEDIUM / LOW | <file:line> | <one-line summary> |
| F-002 | ... | ... | ... | ... |
```

---

### Finding Format

A Finding is the atomic unit of evidence. Every finding in the Analysis Report must be rendered in the following block. Findings are numbered sequentially across the entire report (`F-001`, `F-002`, …) so they can be referenced by the Remediation Plan.

```markdown
---

**Finding F-<NNN>**

| Field | Value |
|---|---|
| **Dimension** | Test Existence & Coverage / TDD Sequence Integrity / Clean Code Compliance / Architecture Boundary Integrity / Security Test Coverage |
| **Severity** | CRITICAL / HIGH / MEDIUM / LOW |
| **Location** | `<relative/file/path.ext>:<line number>` (omit line number when finding is structural, e.g. a missing file) |
| **Description** | <One or two sentences stating what is wrong and why it violates the TDD or Clean Code lifecycle.> |
| **Evidence** | <Exact code snippet, commit reference, or structural observation that proves the finding. Use a fenced code block for code. For missing files, state the production class that lacks a test file. For git sequence violations, cite the relevant commit SHAs.> |
| **Recommended Fix** | <A specific, actionable instruction. Name the agent that should carry it out. Reference the `/tdd-clean-code-workflow` gate this fix unlocks or protects.> |
```

**Severity definitions:**

| Severity | Definition |
|---|---|
| CRITICAL | Directly violates a mandatory `/tdd-clean-code-workflow` gate. The gate cannot pass until this is resolved. Examples: no tests for a production class, implementation committed before tests. |
| HIGH | Materially undermines lifecycle integrity or introduces exploitable security exposure. Must be resolved before the next feature is started. |
| MEDIUM | Degrades code quality or consistency in ways that accumulate technical debt. Must be included in the next remediation sprint. |
| LOW | Minor style or naming deviation. Should be batched into a scheduled clean-up. |

---

### Remediation Plan Template

Produced by `🟦 planning-agent` at the conclusion of Phase 3.

```markdown
# TDD Compliance Remediation Plan

**Project:** <project name>
**Date:** <YYYY-MM-DD>
**Based on Analysis Report dated:** <YYYY-MM-DD>
**Overall TDD Compliance Score at analysis:** <0–100> (<band>)
**Target score after remediation:** <0–100> (COMPLIANT)

---

## Quick Wins

> Fixes estimated at under 30 minutes each. Apply immediately without sprint planning.

| ID | Finding(s) | Action | Agent | Estimated Effort | Gate Unlocked |
|---|---|---|---|---|---|
| QW-001 | F-<NNN> | <specific action> | <agent label> | <minutes> | Gate <N> — <name> |

**To apply quick wins:** Invoke `/tdd-clean-code-workflow` for each item. Each quick win constitutes its own minimal Red-Green-Refactor cycle even if the change is small.

---

## Structural Changes

> Fixes that require architecture decisions, cross-cutting refactors, or team alignment before implementation begins.

| ID | Finding(s) | Decision Required | Recommended Owner | Estimated Effort | Gate Dependency |
|---|---|---|---|---|---|
| SC-001 | F-<NNN> | <the architectural or structural decision that must be made first> | 🟪 architect-agent | <days> | Gate <N> — <name> |

**Structural changes must not begin until the relevant Decision Required item has been resolved and recorded as an ADR by `🟪 architect-agent`.**

---

## Remediation Sprints

### Sprint 1 — <Theme>

**Goal:** <One sentence describing what lifecycle compliance state this sprint achieves.>

**Findings addressed:** F-<NNN>, F-<NNN>, ...

**Acceptance Criteria:**

- [ ] <Specific, verifiable criterion 1. Must be testable — either a test passes or a gate clears.>
- [ ] <Specific, verifiable criterion 2.>
- [ ] <Specific, verifiable criterion 3.>

**Estimated Effort:** <hours or days>

**Agents to invoke:**

| Step | Agent | Action |
|---|---|---|
| 1 | 🟪 architect-agent | <What architect-agent must do before testing begins in this sprint.> |
| 2 | 🟩 testing-automation-agent | <What tests must be written or retrofitted.> |
| 3 | 🟥 security-agent | <Security review scope for this sprint.> |
| 4 | 🟨 clean-code-agent | <Implementation or refactoring scope.> |
| 5 | 🟢 audit-agent | <What the audit must record for this sprint.> |

**`/tdd-clean-code-workflow` gates this sprint unlocks:**

| Gate | Name | Condition Satisfied by This Sprint |
|---|---|---|
| Gate <N> | <gate name> | <exactly what condition this sprint's completion satisfies> |

**Definition of Done:** All acceptance criteria checked. All targeted findings resolved. Audit log entry produced by `🟢 audit-agent`. No new CRITICAL or HIGH findings introduced.

---

### Sprint N — <Theme>

<Repeat for as many sprints as the finding set requires.>

---

## Projected Score Trajectory

| After Sprint | Dimension Scores (T / S / C / A / Sec) | Projected Overall Score | Projected Band |
|---|---|---|---|
| Baseline | <T> / <S> / <C> / <A> / <Sec> | <score> | <band> |
| After Sprint 1 | <T> / <S> / <C> / <A> / <Sec> | <score> | <band> |
| After All Sprints | <T> / <S> / <C> / <A> / <Sec> | <score> | COMPLIANT |

> Column key: T = Test Existence & Coverage, S = TDD Sequence Integrity, C = Clean Code Compliance, A = Architecture Boundary Integrity, Sec = Security Test Coverage

---

## Remediation Complete Criteria

The codebase is considered remediated when all of the following are true:

- [ ] Overall TDD Compliance Score is 85 or above (COMPLIANT band).
- [ ] Zero CRITICAL findings remain open.
- [ ] Zero HIGH findings remain open.
- [ ] All `/tdd-clean-code-workflow` gates from Gate 0 to Gate 8 can be passed for at least one representative feature without manual exceptions.
- [ ] `🟢 audit-agent` has produced a closing audit log entry confirming the above.
- [ ] CLAUDE.md has been updated with lessons learned from the remediation programme.
```

---

## Remediation Plan Generation

The `🟦 planning-agent` drives this section. Once the analysis findings have been collected, `🟦 planning-agent` consolidates them into a single, executable remediation plan. The plan is deterministic: the same findings always produce the same ordering and sprint structure.

---

### Prioritisation Rules

Findings are ranked in six tiers. No tier-N item may be scheduled before all tier-(N−1) items are resolved. Within a tier, items are ranked by blast radius (number of classes or modules affected, descending).

| Tier | Category | Rationale |
|------|----------|-----------|
| 1 — CRITICAL | Security gaps (missing auth, injection surfaces, secret leakage, broken access control) | A codebase that is insecure cannot safely be tested or refactored. Security fixes are pre-conditions for all other work. |
| 2 — HIGH | Missing tests for core domain logic (entities, value objects, domain services, use cases) | Without a safety net over the domain, no structural change is safe. Domain tests must exist before any refactoring begins. |
| 3 — MEDIUM | Coverage gaps in application and infrastructure layers (controllers, repositories, adapters, event handlers) | Once the domain is covered, outer-layer coverage closes the remaining blast radius. |
| 4 — LOW | Clean Code violations (functions >6 lines, >2 arguments, boolean flags, primitive obsession, dead code, circular dependencies, framework leakage) | Violations are addressed only after tests exist to catch regressions introduced during cleanup. |
| 5 — LOW | CI/CD gaps (no pipeline, no coverage enforcement gate, no security scan step, no quality gate) | Pipeline hardening locks in the improvements made in tiers 1–4 so they cannot regress. |
| 6 — INFORMATIONAL | Documentation gaps, naming inconsistencies, minor style issues | Addressed last; never blocks a sprint. |

**Override rule:** If a security finding is directly caused by a structural problem (e.g., framework leakage into domain means authentication logic is scattered across layers), that structural problem is promoted to Tier 1 and must be resolved before the security finding is closed.

---

### Sprint Structure

Each sprint contains work from at most two adjacent tiers. Cross-tier work is permitted only when a tier-2 item directly enables a tier-1 fix.

**Sprint sizing heuristic:**

- `🟦 planning-agent` estimates each finding as S (half-day), M (one day), or L (two days) based on the number of files affected and the depth of the change.
- A sprint holds a maximum of 10 story points (S=1, M=2, L=4).
- If a single finding exceeds one sprint (e.g., a large characterisation-test sweep), it is split into vertical slices by module or bounded context.

---

### TDD Gate Mapping

Every remediation action maps to one or more gates in `/tdd-clean-code-workflow`. When `🟦 planning-agent` emits a remediation item, it must declare which gate that item satisfies.

| Remediation Action | Gate Satisfied | Notes |
|-------------------|----------------|-------|
| Define or enforce architecture boundaries | Gate 0 — Architecture Gate | Must complete before any new tests are written for the affected layer. |
| Write characterisation tests for untested existing code | Gate 2 — Test Gate (partial) | Characterisation tests are RED-phase stand-ins. They are replaced by proper behaviour tests after refactoring. |
| Add missing security boundary tests | Gate 3 — Security Test Gate | Required before any implementation change in the affected class. |
| Fix security vulnerabilities (Tier 1 findings) | Gate 6 — Final Security Gate | `🟥 security-agent` re-validates after fix. |
| Add missing unit/integration tests for domain and application layers | Gate 2 — Test Gate | Full RED compliance. Tests must fail before implementation is touched. |
| Implement minimum code to satisfy a failing test | Gate 4 — Implementation Gate | `🟨 clean-code-agent` GREEN phase. |
| Refactor to meet Clean Code hard constraints | Gate 5 — Refactor Gate | Tests must pass before and after. |
| Add CI/CD pipeline with coverage and security scan gates | Gate 7 — Operational Readiness Gate | `⚫ devops-agent` + `🟣 operational-readiness-agent`. |
| Produce or update architectural decision records | Gate 0 — Architecture Gate | `🟪 architect-agent` owns ADRs. |
| Final audit log entry and CLAUDE.md update | Gate 8 — Audit Gate | `🟢 audit-agent` closes the sprint. |

---

### Dependency Ordering

Some remediation actions are hard blockers for others. `🟦 planning-agent` enforces the following dependency graph before scheduling work into sprints.

```
[Security fixes — Tier 1]
    └── Unblocks: any refactoring of the affected class

[Architecture boundary definition]
    └── Unblocks: writing unit tests that respect those boundaries
    └── Unblocks: framework leakage removal (cannot remove leakage until the boundary is drawn)

[Characterisation tests written]
    └── Unblocks: any structural refactoring of the characterised class
    └── Unblocks: Clean Code violation fixes in that class

[Untestable code made testable (static → injected, global state → constructor-injected)]
    └── Unblocks: characterisation tests for that code
    └── Unblocks: unit tests for that code

[Core domain unit tests passing]
    └── Unblocks: application-layer test coverage
    └── Unblocks: integration test coverage

[All Tier 2–3 tests passing]
    └── Unblocks: Clean Code refactoring (Tier 4)

[All Tier 1–4 complete]
    └── Unblocks: CI/CD hardening (Tier 5)
```

**Practical rule:** `🟦 planning-agent` will refuse to schedule a Clean Code refactoring item for any class that does not yet have at least one test. If no test exists, the test item is scheduled first, even if that pushes the Clean Code item to a later sprint.

---

### Incremental Approach — Adding Tests to an Existing Codebase Without Breaking It

Existing code cannot be safely refactored without tests, but writing proper TDD tests against untested code is circular — the tests would couple themselves to bad structure. The skill uses a three-phase incremental approach to break this deadlock.

#### Phase A: Characterisation Tests (Lock-in the current behaviour)

`🟩 testing-automation-agent` writes characterisation tests. These tests do not describe desired behaviour — they describe current (possibly wrong) behaviour. Their purpose is to give the team a regression net so that structural changes do not silently break the codebase.

Characterisation tests:
- Cover every public method of an untested class.
- Assert the actual current return values and side effects, even if those values are wrong.
- Are annotated `@Characterisation` or tagged `[characterisation]` to distinguish them from proper TDD tests.
- Are never committed as permanent tests — they are scaffolding.

```java
// Example characterisation test (Java / JUnit 5)
@Tag("characterisation")
class OrderProcessorCharacterisationTest {

    @Test
    void should_returnNullDiscount_when_orderHasNoItems() {
        // Characterises current (broken) behaviour — null is not the desired value
        // but this test locks in the current behaviour so refactoring does not silently change it
        var processor = new OrderProcessor(new StaticTaxCalculator(), new GlobalDiscountTable());
        var result = processor.calculateDiscount(Order.empty());
        assertThat(result).isNull(); // characterises current behaviour, not desired behaviour
    }
}
```

#### Phase B: Refactor to Clean Architecture

With characterisation tests providing a safety net, `🟨 clean-code-agent` applies structural refactoring:
- Extract domain logic from service classes into proper domain objects.
- Enforce architecture boundaries (move infrastructure code out of the domain).
- Break static method chains into injectable dependencies.
- Remove global state by introducing constructor injection.
- Split God Classes using the Extract Class refactoring.

Characterisation tests are run after every change. Any failure during refactoring is investigated before continuing.

#### Phase C: Replace Characterisation Tests with Proper TDD Tests

Once the structure is clean, `🟩 testing-automation-agent` writes proper behaviour-describing tests for the refactored code. These tests:
- Describe desired behaviour, not current behaviour.
- Follow the `should_<expectedBehaviour>_when_<condition>` naming convention.
- Cover all acceptance criteria from the original requirements (or, if requirements do not exist, from the behaviour discovered during characterisation).
- Are written RED (failing), then made GREEN by `🟨 clean-code-agent`.

Characterisation tests are deleted once proper tests cover the same behaviour.

---

### The Strangler Fig Approach for Legacy Code

For large legacy classes or modules that cannot be incrementally refactored within a single sprint, the skill applies the Strangler Fig pattern. `🟪 architect-agent` defines the strangler boundary before any code is touched.

**Steps:**

1. **Wrap:** `🟪 architect-agent` introduces a thin facade (interface + adapter) in front of the legacy class. The facade has the clean API the new code will use. The legacy class is hidden behind the facade and treated as opaque.

2. **Test the facade:** `🟩 testing-automation-agent` writes full tests against the facade. These tests are RED. The facade delegates to the legacy class, so they may pass — but they define the contract the replacement must honour.

3. **Replace incrementally:** `🟨 clean-code-agent` implements each facade method cleanly, redirecting calls away from the legacy class one method at a time. After each method is replaced, all facade tests must still pass.

4. **Delete the legacy class:** When all facade methods have been redirected, the legacy class is unreachable. It is deleted, and the characterisation tests (if any) for it are deleted with it.

5. **Remove the facade (optional):** Once the new implementation is stable and the team is confident, the facade may be inlined if it adds no meaningful abstraction value. `🟨 clean-code-agent` makes this call during the REFACTOR phase.

```
Legacy: OrderProcessorLegacy (2,400 lines, untestable, static dependencies)
    ↓
Facade: OrderProcessor (interface + adapter delegating to legacy)
    ↓
Tests: full suite against OrderProcessor interface (RED, then GREEN via legacy)
    ↓
Replacement: OrderProcessorImpl (clean, injected, TDD-driven) — replaces legacy method by method
    ↓
Delete: OrderProcessorLegacy removed when all methods are replaced
```

`🟢 audit-agent` records the legacy class name, the ADR authorising the Strangler Fig approach, and the sprint in which deletion occurred.

---

### Handling Untestable Code

The analysis phase surfaces untestable code patterns. `🟦 planning-agent` translates each pattern into a specific remediation action and schedules it before the corresponding test item.

| Untestable Pattern | What the Analysis Surfaces | What the Plan Recommends | Agent |
|-------------------|---------------------------|--------------------------|-------|
| Static method chains (utility classes, `ServiceLocator`, `getInstance()`) | Class names, call sites, call depth | Extract interface; inject via constructor; replace static call with dependency call | `🟨 clean-code-agent` |
| Global mutable state (`static` fields, `ThreadLocal`, Singletons) | Field names, classes that read or write the state | Introduce a state holder interface; inject it; scope appropriately (request, session, application) | `🟪 architect-agent` + `🟨 clean-code-agent` |
| Hidden dependencies (hardcoded `new`, hardcoded configuration values, hardcoded URLs) | Instantiation sites, configuration reads | Introduce constructor injection; externalise configuration to environment or config class | `🟨 clean-code-agent` |
| Framework types in domain models (`@Entity`, `HttpServletRequest`, `ApplicationContext` in domain) | Class names and field/method signatures | Extract domain interface; move framework type to adapter; domain depends on interface only | `🟪 architect-agent` + `🟨 clean-code-agent` |
| Hardcoded time (`new Date()`, `LocalDateTime.now()` in production code) | Call sites | Introduce a `Clock` interface; inject it; use `Clock.now()` in tests | `🟨 clean-code-agent` |
| Hardcoded randomness (`Math.random()`, `UUID.randomUUID()` in domain) | Call sites | Introduce a `TokenGenerator` or `IdGenerator` interface; inject and stub in tests | `🟨 clean-code-agent` |

---

## Integration with tdd-clean-code-workflow

This skill is the analysis companion to `/tdd-clean-code-workflow`. It does not replace that skill; it provides the structured input that makes each invocation of that skill precise and targeted.

### How findings become workflow input

After `🟢 audit-agent` produces the scorecard and gap list, and `🟦 planning-agent` produces the remediation plan, each identified gap is expressed as a problem statement that becomes the direct input to `/tdd-clean-code-workflow`:

```
Gap identified by /analyse-code-base-for-tdd:
  "PaymentService has no unit tests. Three public methods are untested.
   OrderController calls PaymentService directly, violating layer boundaries."

Becomes the input to /tdd-clean-code-workflow:
  "Add unit tests for PaymentService and correct the layering violation
   in OrderController."
```

### Remediation sprints map to workflow invocations

`🟦 planning-agent` organises findings into remediation sprints. Each sprint maps to exactly one invocation of `/tdd-clean-code-workflow`. Sprint size is constrained so that each workflow run remains focussed on a single coherent unit of change.

```
Remediation Sprint 1  →  /tdd-clean-code-workflow  (closes Gap A, Gap B)
Remediation Sprint 2  →  /tdd-clean-code-workflow  (closes Gap C)
Remediation Sprint 3  →  /tdd-clean-code-workflow  (closes Gap D, Gap E)
```

Sprint priority follows finding severity:

| Severity | Sprint priority |
|----------|----------------|
| CRITICAL | Sprint 1 (immediate) |
| HIGH     | Sprint 2–3 |
| MEDIUM   | Sprint 4–6 |
| LOW      | Sprint 7+ or maintenance backlog |

### Each sprint runs the full Gate 0–9 lifecycle

When `/tdd-clean-code-workflow` is invoked for a remediation sprint, it runs the complete lifecycle without abbreviation. The remediation sprint plan produced by `🟦 planning-agent` satisfies Gate 1 (Plan Gate). All other gates follow in sequence as normal.

### Re-scoring after remediation

After all remediation sprints complete, `/analyse-code-base-for-tdd` should be re-invoked to produce an updated scorecard. The delta between the original score and the post-remediation score is the primary measure of improvement. `🟢 audit-agent` records this delta in the CLAUDE.md audit log.

---

## Limitations

This skill performs static analysis of the codebase as it exists at the time of invocation. The following categories of defect and risk are outside its detection capability.

### What this skill cannot detect

| Category | Specific limitation | Recommended mitigation |
|----------|--------------------|-----------------------|
| Dynamic behaviour | Logic that manifests only at runtime (race conditions, memory leaks, concurrency bugs, event ordering issues) cannot be detected by reading source and test files. | Run the application under load. Use profiling tools and race detectors appropriate to the language. |
| Runtime-only bugs | Bugs that require specific data states, environmental conditions, or sequences of events that only occur in production or staging are invisible to static analysis. | Instrument production observability (traces, structured logs, error rates). Use chaos engineering to surface hidden failure modes. |
| External system behaviour | Whether third-party APIs, databases, message brokers, or cloud services behave as tests assume cannot be verified by this skill. | Run contract tests against real or sandbox external systems in a pre-production environment. Use consumer-driven contract testing tools (e.g., Pact). |
| Test effectiveness | This skill detects the presence and structural quality of tests. It cannot determine whether tests actually prevent the bugs they claim to. | Mutation testing (e.g., PIT for Java, Stryker for TypeScript) reveals whether tests genuinely exercise the code they cover. |
| Security at runtime | Dynamic vulnerabilities such as timing attacks, session fixation under load, and injection via indirect data paths may not be visible in test code. | Run DAST tools (OWASP ZAP, Burp Suite) against the running application in addition to reviewing test coverage. |
| Performance and SLA compliance | Test existence and quality are assessed; whether the system meets response time or throughput SLAs under realistic conditions is not evaluated. | Run load and performance tests (e.g., Gatling, k6, JMeter) in a staging environment that mirrors production topology. |
| Infrastructure and environment drift | Whether the CI/CD pipeline configuration accurately reflects what actually executes in production is assumed but not verified. | Run a full pipeline execution in a clean environment and compare results against the pipeline configuration analysed. |
| Dependency vulnerabilities | Known CVEs in third-party dependencies are not assessed by this skill. | Run a software composition analysis tool (e.g., OWASP Dependency-Check, Snyk, Dependabot) separately. |

### What to do about it

1. Treat the scorecard as a floor, not a ceiling. A GOOD score does not mean the system is production-safe — it means the engineering discipline around TDD and Clean Code is in good shape.
2. Complement this skill with runtime observability, DAST scanning, mutation testing, and performance testing before concluding that a codebase is fully production-ready.
3. Record known limitations in the CLAUDE.md audit log so future sessions carry that context forward.

---

## Rules

### What Claude MUST do

1. **Show the scorecard first.** The TDD Compliance Scorecard is always the first output presented to the user. No findings, no gaps, no plan — nothing — before the scorecard is complete and visible.

2. **Present findings before the plan.** After the scorecard, findings from all Phase 1 agents are presented in full. The remediation plan from `🟦 planning-agent` is presented only after all findings have been shown.

3. **Label every agent invocation.** Each agent must display its coloured label before producing any output.

4. **Run Phase 1 agents across the full codebase.** Analysis must not be limited to recently changed files or a sample. Every source file and every test file is in scope unless the user explicitly narrows the scope before invocation.

5. **Assign severity to every finding.** Every gap identified must carry a severity label: CRITICAL, HIGH, MEDIUM, or LOW. Unseveritised findings must not appear in the output.

6. **State confidence explicitly when evidence is ambiguous.** If a finding is inferred rather than directly observed, Claude must state the confidence level and the reason for uncertainty.

7. **Remain in analysis mode for the entire skill run.** No implementation, no test writing, no refactoring, no code generation of any kind occurs during this skill. All code-producing work belongs to subsequent `/tdd-clean-code-workflow` invocations.

8. **Invoke `🟢 audit-agent` as the final Phase 2 step.** Synthesis, scoring, and gap-ranking are `audit-agent` responsibilities. Claude does not score or rank findings directly.

9. **Invoke `🟦 planning-agent` to produce the remediation plan.** Claude does not write the remediation plan directly. It delegates to `planning-agent`, which consumes the audit-agent synthesis.

10. **Update CLAUDE.md with the analysis audit entry.** `🟢 audit-agent` appends an entry to the CLAUDE.md audit log recording the score, the top findings, and the recommended first remediation sprint.

### What Claude MUST NOT do

1. **Must not write any implementation code** during this skill. Analysis is read-only.

2. **Must not write any test code** during this skill. Test writing belongs to `🟩 testing-automation-agent` inside a `/tdd-clean-code-workflow` invocation.

3. **Must not begin the remediation plan before presenting all findings.** Jumping to the plan before findings are complete skips the review step that allows the user to challenge or correct individual findings.

4. **Must not present findings before the scorecard.** The scorecard is always first.

5. **Must not score the codebase without invoking all relevant Phase 1 agents.** A partial scan produces a misleading score. If a Phase 1 agent cannot execute (e.g., no CI/CD configuration exists), its dimension score is recorded as 0 with an explanatory note — it is not omitted.

6. **Must not make architectural decisions, propose technology changes, or recommend specific libraries** during the analysis phase. Recommendations are limited to identifying gaps against the TDD and Clean Code standard; technology choices belong to `🟪 architect-agent` inside a subsequent workflow invocation.

7. **Must not skip the `🟢 audit-agent` synthesis step.** Scores calculated without audit-agent produce output that cannot be linked to the CLAUDE.md audit log and cannot feed cleanly into `/tdd-clean-code-workflow`.

8. **Must not commit or push anything** as a result of running this skill. This skill produces a report and a plan. It does not change the codebase.

9. **Must not record secrets, credentials, or personal data** in findings, the scorecard, or the audit log entry.

10. **Must not fabricate findings.** If evidence for a finding is absent, the finding is not reported. Inference is permitted only when confidence is stated explicitly and the basis for the inference is shown.
