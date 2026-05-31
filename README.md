# claude-tdd-cleancode-plugin

A Claude Code plugin that enforces a disciplined, audit-driven engineering lifecycle for every software change. It combines Test-Driven Development, Clean Code, Security Engineering, and Operational Readiness into a single orchestrated workflow.

---

## Overview

This plugin installs a complete set of specialised subagents and a master skill (`tdd-clean-code-workflow`) that guides Claude Code through a mandatory, gate-controlled sequence before any code is written, merged, or deployed.

The core philosophy is:

> **Plan → Architect → Test → Secure → Implement → Refactor → Validate → Operate → Audit**

No phase may be skipped. Every agent invocation is visible to the developer. Every decision is recorded in a persistent audit log inside `CLAUDE.md`.

---

## Repository Structure

This is the source repository for the plugin. Clone it, run `install.sh`, and the plugin is live in Claude Code.

```
agents/                              ← 15 specialised subagent definitions
  architect-agent.md
  audit-agent.md
  business-documentation-agent.md
  clean-code-agent.md
  cloud-agent.md
  devops-agent.md
  integration-agent.md
  mcp-agent.md
  operational-readiness-agent.md
  planning-agent.md
  research-agent.md
  security-agent.md
  technical-documentation-agent.md
  testing-automation-agent.md
  ui-ux-agent.md
skills/
  tdd-clean-code-workflow/
    SKILL.md                         ← /tdd-clean-code-workflow skill
  analyse-code-base-for-tdd/
    SKILL.md                         ← /analyse-code-base-for-tdd skill
CLAUDE.md                           ← plugin governance rules (copied into Claude on install)
install.sh                          ← one-command installer
uninstall.sh                        ← one-command uninstaller
README.md
```

---

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) installed and configured (`~/.claude/` directory exists)
- `python3` available on your `PATH` (used for plugin registration)

### Install

```bash
git clone https://github.com/mtedone/claude-tdd-workflow-java.git
cd claude-tdd-workflow-java
./install.sh
```

That's it. The installer:

1. Copies all 15 agents to `~/.claude/plugins/cache/local/claude-tdd-cleancode-plugin/1.0.0/agents/`
2. Copies both skills to the same plugin cache
3. Registers the plugin in `~/.claude/plugins/installed_plugins.json`
4. Installs the **Commit/Push Gate hook** in `~/.claude/settings.json` (Gate 9 — requires your explicit permission before any `git commit` or `git push`)

Restart Claude Code to activate.

### Uninstall

```bash
./uninstall.sh
```

Removes the plugin cache and its registration. The Commit/Push Gate hook in `~/.claude/settings.json` is intentionally preserved — remove it manually if no longer needed.

### Verify

After restarting Claude Code, confirm both skills are available:

```
/tdd-clean-code-workflow
/analyse-code-base-for-tdd
```

---

## Usage

### Greenfield work — starting a new feature

Type in Claude Code:

```
/tdd-clean-code-workflow
```

Claude will ask:

```
Would you like to enter Plan Mode?
```

Answer `yes` to engage full planning, or `no` to proceed directly to architecture review.

### Brownfield work — auditing an existing codebase

Type in Claude Code:

```
/analyse-code-base-for-tdd
```

Claude will ask five scoping questions (directory, language, framework, scope, known problem areas), then run all 12 analysis dimensions in parallel and produce a scored compliance report and prioritised remediation plan.

### Manual agent invocation

You may also invoke individual agents at any time:

```
Use planning-agent to break down this requirement.
Use security-agent to review this implementation.
Use audit-agent to produce a final report.
```

---

## Workflow

```
┌─────────────────────────────────────────────────────┐
│                   GATE 1 – Plan Gate                │
│  🟦 planning-agent  →  🟤 research-agent (optional) │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│               GATE 0 – Architecture Gate            │
│               🟪 architect-agent                    │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                GATE 2 – Test Gate                   │
│           🟩 testing-automation-agent               │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│            GATE 3 – Security Test Gate              │
│                🟥 security-agent                    │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│            GATE 4 – Implementation Gate             │
│               🟨 clean-code-agent                   │
│   (+ 🟧 integration-agent / 🔵 ui-ux-agent / 🟫 mcp-agent as needed) │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│              GATE 5 – Refactor Gate                 │
│               🟨 clean-code-agent                   │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│           GATE 6 – Final Security Gate              │
│                🟥 security-agent                    │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│         GATE 7 – Operational Readiness Gate         │
│          🟣 operational-readiness-agent             │
│   (+ ⚫ devops-agent / ⚪ cloud-agent as needed)    │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│               GATE 8 – Audit Gate                   │
│                 🟢 audit-agent                      │
│   (+ 🔷 technical-documentation-agent / 🔶 business-documentation-agent) │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│           GATE 9 – Commit/Push Gate                 │
│     Explicit user permission required               │
│     Enforced by PreToolUse hook in settings.json    │
└─────────────────────────────────────────────────────┘
```

---

## Agent Descriptions

| Label | Agent | Responsibility |
|-------|-------|----------------|
| 🟦 | planning-agent | Breaks requirements into user stories, acceptance criteria, and sprint tasks |
| 🟤 | research-agent | Investigates best practices, alternatives, and standards |
| 🟪 | architect-agent | Defines architecture style, patterns, bounded contexts, and ADRs |
| 🟩 | testing-automation-agent | Creates failing tests (unit, integration, contract, BDD) |
| 🟥 | security-agent | Reviews tests and implementation against OWASP Top 10 and advanced threat models |
| 🟨 | clean-code-agent | Implements minimum code to pass tests, then refactors |
| 🟧 | integration-agent | Designs APIs, events, messaging contracts and adapters |
| 🟫 | mcp-agent | Designs MCP servers, clients, tools, resources, and prompts |
| 🔵 | ui-ux-agent | Defines UX, accessibility, and UI structure |
| ⚫ | devops-agent | Designs CI/CD pipelines, Docker, Kubernetes, and deployment strategies |
| ⚪ | cloud-agent | Evaluates cloud architecture across GCP, AWS, and Azure |
| 🟣 | operational-readiness-agent | Validates monitoring, alerting, runbooks, DR, and go-live readiness |
| 🔷 | technical-documentation-agent | Produces ADRs, API docs, runbooks, and developer guides |
| 🔶 | business-documentation-agent | Produces release notes, user guides, and stakeholder summaries |
| 🟢 | audit-agent | Records all decisions, lessons learned, and updates CLAUDE.md |

---

## Quality Gates

| Gate | Name | Condition |
|------|------|-----------|
| Gate 0 | Architecture Gate | Architecture approved before tests are written |
| Gate 1 | Plan Gate | Plan produced before architecture review |
| Gate 2 | Test Gate | Failing tests created before implementation begins |
| Gate 3 | Security Test Gate | Security review completed before implementation |
| Gate 4 | Implementation Gate | Code written only to satisfy tests |
| Gate 5 | Refactor Gate | Refactoring completed and all tests still pass |
| Gate 6 | Final Security Gate | Implementation validated against full security checklist |
| Gate 7 | Operational Readiness Gate | Deployment readiness confirmed |
| Gate 8 | Audit Gate | Full audit report produced and CLAUDE.md updated |
| Gate 9 | Commit/Push Gate | Explicit user permission obtained before committing or pushing |

---

## Clean Code Hard Constraints

These are absolute limits enforced by `clean-code-agent`. No exceptions without documented justification.

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

## Commit/Push Gate

Claude must never commit or push code without explicit user permission. Before running any
`git commit` or `git push`, Claude must:

1. Show a summary: files changed, proposed commit message, target remote and branch.
2. Ask: **"Do you want me to proceed with this commit/push?"**
3. Wait for explicit confirmation.

This gate is enforced at two levels:
- **Harness hook** — a `PreToolUse` hook in `~/.claude/settings.json` fires a permission
  prompt on every `git commit` and `git push` command, including those inside chained
  commands (e.g. `git add . && git commit -m "..." && git push`).
- **CLAUDE.md rule** — Claude is instructed to present a summary before attempting to act.


## Extension Model

### Adding a new agent

1. Create `agents/<your-agent>.md` following the frontmatter format used by existing agents.
2. Assign a unique emoji label.
3. Register the agent in `CLAUDE.md` under the `## Plugin Agents` section.
4. Invoke `audit-agent` after the first use to record the addition.

### Adding a new skill

1. Create `skills/<your-skill>/SKILL.md` with the required frontmatter (`name`, `description`).
2. Document the skill in this README under `## Skills Reference`.
3. Record the change via `audit-agent`.

### Adding a new quality gate

1. Define the gate in `CLAUDE.md` under `## Quality Gates`.
2. Add the gate check to the relevant skill's `SKILL.md`.
3. Record the change via `audit-agent`.

---

## Contribution Guidelines

- All contributions must follow the TDD lifecycle defined in this plugin.
- Every agent definition must include: description, capabilities, responsibilities, forbidden actions, and output format.
- Agent definitions must be technology-agnostic where possible.
- No implementation code may be placed inside agent definition files.
- All changes must be recorded in the audit log.
- Security implications must be assessed for every change.

---

## Skills Reference

This plugin provides two complementary skills. Use them together: run `/analyse-code-base-for-tdd` first on any existing codebase, then apply `/tdd-clean-code-workflow` to each remediation sprint and all future features.

---

### /tdd-clean-code-workflow

**File:** `skills/tdd-clean-code-workflow/SKILL.md`

**Purpose:** Enforces the complete Red-Green-Refactor TDD and Clean Code engineering lifecycle for every software change. This is the primary skill — it governs all new development and all intentional changes to existing code.

**When to use:**
- Starting any new feature, bug fix, or refactoring task
- Any time code is being written or modified
- After `/analyse-code-base-for-tdd` identifies a remediation item to address

**How to invoke:**

```
/tdd-clean-code-workflow
```

Claude asks whether to enter Plan Mode, then orchestrates all 15 agents through the mandatory gate sequence.

**Gate sequence enforced:**

| Gate | Name |
|------|------|
| Gate 0 | Architecture Gate — architect-agent approves before tests |
| Gate 1 | Plan Gate — plan produced before architecture |
| Gate 2 | Test Gate — failing tests created before implementation |
| Gate 3 | Security Test Gate — security-agent reviews tests |
| Gate 4 | Implementation Gate — code written only to pass tests |
| Gate 5 | Refactor Gate — clean-code-agent refactors; tests still pass |
| Gate 6 | Final Security Gate — security-agent validates implementation |
| Gate 7 | Operational Readiness Gate — deployment readiness confirmed |
| Gate 8 | Audit Gate — audit-agent records decisions; CLAUDE.md updated |
| Gate 9 | Commit/Push Gate — explicit user permission required |

**Agents orchestrated:** All 15 plugin agents, invoked in sequence with visible labels.

---

### /analyse-code-base-for-tdd

**File:** `skills/analyse-code-base-for-tdd/SKILL.md`

**Purpose:** Retrospective audit of an existing codebase. Scores compliance across 12 dimensions against the TDD and Clean Code lifecycle, then produces a prioritised remediation plan with sprint-sized tasks mapped directly to `/tdd-clean-code-workflow` gates. This skill is read-only — it analyses and plans; it never writes code.

**When to use:**
- Before adopting this plugin on a codebase that was not built test-first
- When onboarding an existing project and needing a baseline compliance score
- When planning a refactoring or technical-debt sprint
- After a period of rapid feature delivery to assess quality drift
- When evaluating whether a codebase is safe to extend without structural remediation

**How to invoke:**

```
/analyse-code-base-for-tdd
```

Claude asks five scoping questions before analysis begins:

1. Which directory or repository to analyse
2. Primary language and framework
3. Analysis scope (full codebase, specific module, or specific layers)
4. Existing documentation artefacts to read first
5. Known problem areas to prioritise

**12 analysis dimensions (run in parallel):**

| # | Dimension | Agent |
|---|-----------|-------|
| 1 | Test Existence | 🟩 testing-automation-agent |
| 2 | TDD Discipline | 🟩 testing-automation-agent |
| 3 | Test Types Coverage | 🟩 testing-automation-agent |
| 4 | Test Quality | 🟩 testing-automation-agent |
| 5 | Test Independence | 🟩 testing-automation-agent |
| 6 | Mock Discipline | 🟩 testing-automation-agent |
| 7 | Coverage Metrics | 🟩 testing-automation-agent |
| 8 | Documentation Alignment | 🟩 testing-automation-agent |
| 9 | Clean Code Compliance | 🟨 clean-code-agent |
| 10 | Architecture Boundary Integrity | 🟨 clean-code-agent |
| 11 | Security Test Coverage | 🟥 security-agent |
| 12 | CI/CD Integration | ⚫ devops-agent |

**Outputs produced:**

| Output | Description |
|--------|-------------|
| TDD Compliance Scorecard | Weighted score (0–100) across all dimensions with band: EXCELLENT / GOOD / PARTIAL / POOR / CRITICAL |
| Analysis Report | Per-dimension findings, each with Severity, Location, Description, Evidence, and Recommended Fix |
| Remediation Plan | Sprint-by-sprint action plan, prioritised by severity, with effort estimates and gate mappings |
| Audit Log Entry | `🟢 audit-agent` appends the score and top findings to CLAUDE.md |

**Scoring model:**

| Dimension | Weight |
|-----------|--------|
| Test Existence | 20% |
| TDD Discipline | 15% |
| Test Types | 15% |
| Test Quality | 10% |
| Clean Code | 10% |
| Architecture | 10% |
| Security Tests | 10% |
| CI/CD | 5% |
| Coverage | 5% |

| Score | Band | Urgency |
|-------|------|---------|
| 90–100 | EXCELLENT | Schedule maintenance in normal cadence |
| 75–89 | GOOD | Address gaps this sprint |
| 50–74 | PARTIAL | Pause new features; start remediation |
| 25–49 | POOR | Dedicate remediation sprints immediately |
| 0–24 | CRITICAL | Halt feature work; run stabilisation programme |

**Relationship to /tdd-clean-code-workflow:**

`/analyse-code-base-for-tdd` is the recommended precursor to `/tdd-clean-code-workflow` on brownfield projects. Each item in the remediation plan becomes the input to one `/tdd-clean-code-workflow` invocation, which runs the full Gate 0–9 lifecycle for that specific gap. On greenfield projects, skip the analysis skill and go directly to `/tdd-clean-code-workflow`.

---

## Licence

MIT — free to use, modify, and distribute. Attribution appreciated.
