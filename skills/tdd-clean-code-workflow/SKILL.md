---
name: tdd-clean-code-workflow
description: Enforces a complete TDD and Clean Code engineering lifecycle with mandatory quality gates. Orchestrates 15 specialised agents across planning, architecture, testing, security, implementation, refactoring, operational readiness, and audit phases. Invoke for any new feature, bug fix, or significant change.
---

# Skill: tdd-clean-code-workflow

## Purpose

Orchestrates the complete TDD and Clean Code engineering lifecycle for every software change. Ensures that planning, architecture, testing, security, implementation, refactoring, operational readiness, and audit phases are executed in strict sequence with visible quality gates between each phase.

This skill is the master orchestrator. It delegates domain-specific work to specialised subagents and enforces gate conditions before permitting phase transitions.

---

## Trigger

Invoked when the user types:

```
/tdd-clean-code-workflow
```

Or when Claude detects that a new feature, bug fix, refactor, or integration change is about to begin.

---

## Workflow

### Step 0 — Entry Point

Claude asks:

```
Would you like to enter Plan Mode?
```

**If yes:** proceed to Step 1.
**If no:** skip to Step 3 (architecture is still mandatory).

---

### Step 1 — Planning Phase `[GATE 1]`

**Agent:** `🟦 planning-agent`

Claude asks:

```
What would you like to achieve?
```

`planning-agent` produces:
- Problem statement
- User stories (Given / When / Then)
- Acceptance criteria
- Out-of-scope items
- Open questions

**Gate 1 condition:** Planning document produced and reviewed.

---

### Step 2 — Research Phase (conditional)

**Agent:** `🟤 research-agent`

Invoked when:
- Unknown technologies are involved
- Architecture choices need validation
- Best practices are unclear
- Standards compliance is required

`research-agent` produces:
- Facts (confirmed)
- Assumptions (stated explicitly)
- Recommendations (ranked)

Research output feeds into the architecture phase.

---

### Step 3 — Architecture Phase `[GATE 0]`

**Agent:** `🟪 architect-agent`

Mandatory. Cannot be skipped.

`architect-agent` produces the Architecture Summary:

```
Business Goal
Architecture Style
Patterns Used
Key Decisions
Boundaries
Dependencies
Trade-Offs
Risks
Testing Implications
Security Implications
Operational Implications
```

Includes ADRs for all significant decisions.

**Gate 0 condition:** Architecture Summary approved before any test is written.

---

### Step 4 — Testing Phase `[GATE 2]`

**Agent:** `🟩 testing-automation-agent`

`testing-automation-agent` creates:
- Failing unit tests
- Failing integration tests (if applicable)
- Failing contract tests (if applicable)
- BDD scenarios (if applicable)
- API tests (if applicable)

Tests must:
- Be readable
- Describe behaviour, not implementation
- Fail before any implementation is written
- Cover all acceptance criteria from the plan

Implementation is FORBIDDEN in this phase.

**Gate 2 condition:** All tests written and confirmed to fail (RED).

---

### Step 5 — Security Test Review Phase `[GATE 3]`

**Agent:** `🟥 security-agent`

`security-agent` reviews the tests for:
- Missing security test coverage
- Inadequate boundary validation tests
- Missing authentication / authorisation tests
- Missing injection attack tests
- Missing data exposure tests

Each finding includes:
```
Severity
Risk
Attack Scenario
Affected Area
Recommended Test
Recommended Fix
```

Tests are improved based on security findings before implementation begins.

**Gate 3 condition:** Security review complete. All HIGH/CRITICAL gaps addressed in tests.

---

### Step 6 — Implementation Phase `[GATE 4]`

**Agent:** `🟨 clean-code-agent`

Supporting agents invoked as needed:
- `🟧 integration-agent` — for API, event, or messaging implementation
- `🔵 ui-ux-agent` — for UI component implementation
- `🟫 mcp-agent` — for MCP tool/resource implementation
- `⚫ devops-agent` — for pipeline or infrastructure implementation
- `⚪ cloud-agent` — for cloud resource implementation

`clean-code-agent` writes the minimum code necessary to make tests pass.

Hard constraints:
- Maximum 6 executable lines per function
- Maximum 2 arguments per function
- Boolean arguments FORBIDDEN
- Commented-out code FORBIDDEN
- Dead code FORBIDDEN
- Circular dependencies FORBIDDEN
- Framework leakage into domain FORBIDDEN

All tests must pass (GREEN) before advancing.

**Gate 4 condition:** All tests pass. No constraint violations.

---

### Step 7 — Refactoring Phase `[GATE 5]`

**Agent:** `🟨 clean-code-agent`

`clean-code-agent` refactors the implementation:
- Remove duplication
- Improve naming
- Extract methods
- Simplify dependencies
- Align with architecture boundaries
- Apply SOLID, DRY, KISS, Tell Don't Ask

Tests must pass after refactoring.

**Gate 5 condition:** All tests pass after refactoring. Code meets all Clean Code rules.

---

### Step 8 — Final Security Validation `[GATE 6]`

**Agent:** `🟥 security-agent`

`security-agent` reviews the final implementation against:
- OWASP Top 10
- XSS, CSRF, SSRF
- SQL Injection, NoSQL Injection, Command Injection
- Path Traversal
- Broken Access Control
- Authentication Bypass
- Insecure Deserialization
- Dependency Vulnerabilities
- Secret Leakage
- Weak Cryptography
- Replay Attacks
- Rate Limiting
- Data Exposure
- Logging Risks
- CORS Risks
- Supply Chain Risks

**Gate 6 condition:** No unresolved HIGH or CRITICAL findings.

---

### Step 9 — Operational Readiness Phase `[GATE 7]`

**Agent:** `🟣 operational-readiness-agent`

Invoked when the change has deployment implications.

Supporting agents invoked as needed:
- `⚫ devops-agent` — for pipeline and deployment strategy
- `⚪ cloud-agent` — for cloud configuration

`operational-readiness-agent` verifies:
- Deployment readiness
- Rollback strategy
- Monitoring and alerting coverage
- Runbook availability
- SLO/SLA impact
- DR/BCP implications

**Gate 7 condition:** All operational readiness checks passed.

---

### Step 10 — Documentation Phase

**Agents:** `🔷 technical-documentation-agent`, `🔶 business-documentation-agent`

Invoked based on audience:
- Technical docs: ADRs, API docs, runbooks, developer guides
- Business docs: release notes, user guides, stakeholder summaries

---

### Step 11 — Audit Phase `[GATE 8]`

**Agent:** `🟢 audit-agent`

`audit-agent` produces the Final Report and updates CLAUDE.md:

```
## Plugin Audit Log

### YYYY-MM-DD

Decision:
Reason:
Agents:
Quality Gates:
Reusable Learning:
Rule Changes:
Follow-Up:
```

**Gate 8 condition:** Audit report produced. CLAUDE.md updated.

---

## Orchestration Rules

1. No phase may begin before its preceding gate is passed.
2. Every agent invocation must display its label before producing output.
3. The user must explicitly acknowledge gate passage before advancing (in interactive mode).
4. Agents may be re-invoked within a phase if findings require iteration.
5. Security agent may block phase transition if unresolved HIGH/CRITICAL findings exist.
6. Audit agent is always the final invocation.

---

## Agent Interaction Map

```
planning-agent
    └── feeds → architect-agent
research-agent
    └── feeds → architect-agent
architect-agent
    └── feeds → testing-automation-agent
              └── feeds → security-agent (Gate 3)
                          └── feeds → clean-code-agent (Gate 4)
                                      └── feeds → clean-code-agent (refactor, Gate 5)
                                                  └── feeds → security-agent (Gate 6)
                                                              └── feeds → operational-readiness-agent (Gate 7)
                                                                          └── feeds → audit-agent (Gate 8)
```

---

## Final Report Format

Produced by `audit-agent` at the conclusion of every workflow run:

```
# TDD Clean Code Workflow — Final Report

## Summary
<one-paragraph description of what was built>

## Agents Invoked
<list of agents with their phase>

## Quality Gates
<list of gates with PASSED / SKIPPED / FAILED>

## Architecture Decisions
<ADRs recorded>

## Security Findings
<findings with resolution status>

## Test Coverage
<types of tests written>

## Clean Code Compliance
<constraint violations, if any, with justification>

## Operational Readiness
<readiness status>

## Lessons Learned
<reusable insights for future work>

## CLAUDE.md Updates
<new rules or patterns added>
```

---

## Quality Gates Summary

| Gate | Phase | Condition |
|------|-------|-----------|
| Gate 0 | Architecture | Architecture Summary approved |
| Gate 1 | Planning | Plan produced |
| Gate 2 | Testing | Failing tests created |
| Gate 3 | Security Test Review | Security gaps addressed in tests |
| Gate 4 | Implementation | All tests pass (GREEN) |
| Gate 5 | Refactoring | Tests pass after refactoring |
| Gate 6 | Final Security | No unresolved HIGH/CRITICAL findings |
| Gate 7 | Operational Readiness | All readiness checks passed |
| Gate 8 | Audit | Report produced, CLAUDE.md updated |
