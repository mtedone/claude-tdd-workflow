# claude-tdd-cleancode-plugin — CLAUDE.md

This file governs Claude Code behaviour for every project that installs this plugin. All instructions below are mandatory and override Claude's default behaviour.

---

## Mandatory Behaviour

### Plan Mode

Before starting any software change, Claude MUST ask:

```
Would you like to enter Plan Mode?
```

If yes, Claude must ask:

```
What would you like to achieve?
```

Then invoke:
1. `🟦 planning-agent`
2. `🟤 research-agent` (if unknowns exist)
3. `🟪 architect-agent`

If no, Claude must still invoke `🟪 architect-agent` before any test or implementation work begins.

**No implementation may start before architecture review is complete.**

---

## Mandatory Agent Execution Order

Every software change must follow this sequence:

```
🟦 planning-agent
      ↓
🟤 research-agent  (if required)
      ↓
🟪 architect-agent
      ↓
🟩 testing-automation-agent
      ↓
🟥 security-agent  (review tests)
      ↓
🟨 clean-code-agent  (implement)
      ↓
🟨 clean-code-agent  (refactor)
      ↓
🟥 security-agent  (validate implementation)
      ↓
🟣 operational-readiness-agent  (if deployment implications exist)
      ↓
🟢 audit-agent
```

Supporting agents (`🟧 integration-agent`, `🟫 mcp-agent`, `🔵 ui-ux-agent`, `⚫ devops-agent`, `⚪ cloud-agent`, `🔷 technical-documentation-agent`, `🔶 business-documentation-agent`) are invoked when their domain is relevant.

---

## Agent Visibility

Every agent invocation MUST display its label before producing output.

Label format:

```
🟦 planning-agent
🟤 research-agent
🟪 architect-agent
🟩 testing-automation-agent
🟥 security-agent
🟨 clean-code-agent
🟧 integration-agent
🟫 mcp-agent
🔵 ui-ux-agent
⚫ devops-agent
⚪ cloud-agent
🟣 operational-readiness-agent
🔷 technical-documentation-agent
🔶 business-documentation-agent
🟢 audit-agent
```

---

## Quality Gates

Claude must enforce all quality gates before advancing to the next phase.

| Gate | Name | Condition |
|------|------|-----------|
| Gate 0 | Architecture Gate | Architecture approved before tests |
| Gate 1 | Plan Gate | Plan produced before architecture |
| Gate 2 | Test Gate | Failing tests created before implementation |
| Gate 3 | Security Test Gate | Security review before implementation |
| Gate 4 | Implementation Gate | Code written only to satisfy tests |
| Gate 5 | Refactor Gate | Refactoring done, tests still pass |
| Gate 6 | Final Security Gate | Implementation validated against OWASP |
| Gate 7 | Operational Readiness Gate | Deployment readiness confirmed |
| Gate 8 | Audit Gate | Audit produced and CLAUDE.md updated |
| Gate 9 | Commit/Push Gate | Explicit user permission obtained before committing or pushing |

---

## Commit and Push Gate (MANDATORY)

Claude must NEVER commit or push code without explicit user permission.

Before running any `git commit` or `git push` command, Claude MUST:

1. Summarise what will be committed (files, proposed message, remote/branch).
2. Ask explicitly: **"Do you want me to proceed with this commit/push?"**
3. Wait for an affirmative response before running the git command.

The harness enforces this via a PreToolUse hook — a permission prompt fires on every `git commit` and `git push`. Claude must not attempt to bypass it.

**Gate 9 condition:** Explicit user confirmation received before `git commit` or `git push`.

---

## TDD Rules

- Tests must be written before implementation code.
- Tests must fail before any implementation is written.
- Implementation must be the minimum necessary to make tests pass.
- Refactoring must follow after tests pass.
- Tests must pass again after refactoring.
- `testing-automation-agent` creates all tests.
- `clean-code-agent` writes all implementation.

**Writing implementation before tests is FORBIDDEN.**
**Writing tests after implementation is FORBIDDEN.**

---

## Clean Code Hard Constraints

These are absolute limits. Any exception must be documented in the audit log.

| Constraint | Limit |
|------------|-------|
| Maximum function length | 6 executable lines |
| Maximum function arguments | 2 |
| Boolean arguments | FORBIDDEN |
| Commented-out code | FORBIDDEN |
| Dead code | FORBIDDEN |
| Circular dependencies | FORBIDDEN |
| Framework leakage into domain | FORBIDDEN |

---

## Security Rules

- `security-agent` must review tests before implementation.
- `security-agent` must review implementation before merge.
- All findings must include: Severity, Risk, Attack Scenario, Affected Area, Recommended Test, Recommended Fix.
- No code with an unresolved HIGH or CRITICAL finding may be merged.

---

## Architecture Rules

- `architect-agent` must produce an Architecture Summary before any test is written.
- Architecture must identify: Business Goal, Architecture Style, Patterns Used, Key Decisions, Boundaries, Dependencies, Trade-Offs, Risks, Testing Implications, Security Implications, Operational Implications.
- Domain boundaries must be respected by all implementation.
- Framework leakage into domain models is FORBIDDEN.

---

## Audit Rules

- `audit-agent` must be invoked at the end of every feature or change.
- All key decisions must be recorded.
- All invoked agents must be listed.
- All quality gates passed must be listed.
- Lessons learned must be extracted.
- CLAUDE.md must be updated after every audit.
- Secrets, credentials, and personal data must never appear in audit logs.

---

## Plugin Agents

| Label | Agent File | Domain |
|-------|-----------|--------|
| 🟦 | .claude/agents/planning-agent.md | Planning |
| 🟤 | .claude/agents/research-agent.md | Research |
| 🟪 | .claude/agents/architect-agent.md | Architecture |
| 🟩 | .claude/agents/testing-automation-agent.md | Testing |
| 🟥 | .claude/agents/security-agent.md | Security |
| 🟨 | .claude/agents/clean-code-agent.md | Implementation & Refactoring |
| 🟧 | .claude/agents/integration-agent.md | Integration |
| 🟫 | .claude/agents/mcp-agent.md | MCP |
| 🔵 | .claude/agents/ui-ux-agent.md | UI/UX |
| ⚫ | .claude/agents/devops-agent.md | DevOps & CI/CD |
| ⚪ | .claude/agents/cloud-agent.md | Cloud |
| 🟣 | .claude/agents/operational-readiness-agent.md | Operations |
| 🔷 | .claude/agents/technical-documentation-agent.md | Technical Docs |
| 🔶 | .claude/agents/business-documentation-agent.md | Business Docs |
| 🟢 | .claude/agents/audit-agent.md | Audit |

---

## Continuous Improvement

Claude must:
- Learn from every audit report.
- Update CLAUDE.md with new reusable rules.
- Carry forward all lessons learned to future sessions.
- Surface recurring patterns in the audit log.

---

## Plugin Audit Log

### 2026-05-31

Decision: Plugin initialised with full agent suite and quality gate framework.
Reason: Establish a disciplined, audit-driven engineering lifecycle across all projects.
Agents: planning-agent, research-agent, architect-agent, testing-automation-agent, security-agent, clean-code-agent, integration-agent, mcp-agent, ui-ux-agent, devops-agent, cloud-agent, operational-readiness-agent, technical-documentation-agent, business-documentation-agent, audit-agent.
Quality Gates: Gate 0 through Gate 8 defined and active.
Reusable Learning: Always invoke architect-agent before any test is written. Security must be reviewed twice — before and after implementation.
Rule Changes: None — initial installation.
Follow-Up: Validate gate enforcement on first feature implementation.

## /analyse-code-base-for-tdd Skill Rules

**Invoke this skill when:**
- The user asks about TDD compliance, test coverage, or test readiness of an existing codebase
- The user wants to introduce TDD into an existing project that lacks tests
- The user asks Claude to assess, audit, or analyse code before writing tests
- The user asks questions like "where do I start with TDD?", "what needs tests?", or "is this codebase TDD-ready?"

**During this skill, Claude MUST NOT:**
- Write any implementation code
- Write any tests or test stubs
- Modify any existing source files
- Make any assumptions about how tests should be implemented — analysis and planning only

**What this skill produces:**
- A structured inventory of untested classes, methods, and modules
- A prioritised list of candidates for TDD adoption (ordered by business risk, complexity, or coupling)
- Identification of design issues (e.g. tight coupling, missing interfaces, static dependencies) that must be resolved before tests can be written
- A recommended sequence for applying TDD incrementally

**How findings feed into /tdd-clean-code-workflow:**
The output of this skill serves as the direct input to `/tdd-clean-code-workflow`. The prioritised candidate list defines which unit of code to target first, the identified design issues inform any refactoring needed before the RED phase begins, and the recommended sequence sets the order of TDD iterations. Do not start `/tdd-clean-code-workflow` without first running this skill on an existing codebase that lacks tests.
