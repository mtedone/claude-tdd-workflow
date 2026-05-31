# claude-tdd-cleancode-plugin

A Claude Code plugin that enforces a disciplined, audit-driven engineering lifecycle for every software change. It combines Test-Driven Development, Clean Code, Security Engineering, and Operational Readiness into a single orchestrated workflow.

---

## Overview

This plugin installs a complete set of specialised subagents and a master skill (`tdd-clean-code-workflow`) that guides Claude Code through a mandatory, gate-controlled sequence before any code is written, merged, or deployed.

The core philosophy is:

> **Plan → Architect → Test → Secure → Implement → Refactor → Validate → Operate → Audit**

No phase may be skipped. Every agent invocation is visible to the developer. Every decision is recorded in a persistent audit log inside `CLAUDE.md`.

---

## Installation

### 1. Copy the plugin into your project

```bash
cp -r claude-tdd-cleancode-plugin/.claude/agents  <your-project>/.claude/agents
cp -r claude-tdd-cleancode-plugin/skills          <your-project>/skills
cp    claude-tdd-cleancode-plugin/CLAUDE.md       <your-project>/CLAUDE.md
```

If your project already has a `CLAUDE.md`, append the contents of this plugin's `CLAUDE.md` to your existing file.

### 2. Verify agent files are present

```bash
ls .claude/agents/
```

Expected output:

```
audit-agent.md
architect-agent.md
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
```

### 3. Start Claude Code

```bash
claude
```

---

## Usage

### Starting a new feature

Type in Claude Code:

```
/tdd-clean-code-workflow
```

Claude will ask:

```
Would you like to enter Plan Mode?
```

Answer `yes` to engage full planning, or `no` to proceed directly to architecture review.

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

1. Create `.claude/agents/<your-agent>.md` following the frontmatter format used by existing agents.
2. Assign a unique emoji label.
3. Register the agent in `CLAUDE.md` under the `## Plugin Agents` section.
4. Invoke `audit-agent` after the first use to record the addition.

### Adding a new quality gate

1. Define the gate in `CLAUDE.md` under `## Quality Gates`.
2. Add the gate check to `skills/tdd-clean-code-workflow/SKILL.md`.
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

## Licence

MIT — free to use, modify, and distribute. Attribution appreciated.
