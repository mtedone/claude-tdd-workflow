#!/usr/bin/env bash
# install.sh — installs claude-tdd-cleancode-plugin into the local Claude Code installation
set -euo pipefail

PLUGIN_NAME="claude-tdd-cleancode-plugin"
PLUGIN_VERSION="1.0.0"
MARKETPLACE="local"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CACHE_DIR="${CLAUDE_DIR}/plugins/cache/${MARKETPLACE}/${PLUGIN_NAME}/${PLUGIN_VERSION}"
INSTALLED_PLUGINS="${CLAUDE_DIR}/plugins/installed_plugins.json"

# ── Prerequisites ──────────────────────────────────────────────────────────────

if [[ ! -d "${CLAUDE_DIR}" ]]; then
  echo "Error: Claude Code config directory not found at ${CLAUDE_DIR}"
  echo "       Please install Claude Code first: https://claude.ai/code"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required for plugin registration but was not found."
  exit 1
fi

# ── Create cache directories ───────────────────────────────────────────────────

echo "Installing ${PLUGIN_NAME} v${PLUGIN_VERSION}..."
echo ""

mkdir -p "${CACHE_DIR}/agents"
mkdir -p "${CACHE_DIR}/skills/tdd-clean-code-workflow"
mkdir -p "${CACHE_DIR}/skills/analyse-code-base-for-tdd"

# ── Copy plugin source files ───────────────────────────────────────────────────

cp "${SCRIPT_DIR}/agents/"*.md              "${CACHE_DIR}/agents/"
cp "${SCRIPT_DIR}/skills/tdd-clean-code-workflow/SKILL.md"   "${CACHE_DIR}/skills/tdd-clean-code-workflow/"
cp "${SCRIPT_DIR}/skills/analyse-code-base-for-tdd/SKILL.md" "${CACHE_DIR}/skills/analyse-code-base-for-tdd/"
cp "${SCRIPT_DIR}/CLAUDE.md"                "${CACHE_DIR}/"
cp "${SCRIPT_DIR}/README.md"                "${CACHE_DIR}/"

AGENT_COUNT=$(ls "${CACHE_DIR}/agents/" | wc -l | tr -d ' ')

# ── Register in installed_plugins.json ────────────────────────────────────────

if [[ ! -f "${INSTALLED_PLUGINS}" ]]; then
  echo '{"version": 2, "plugins": {}}' > "${INSTALLED_PLUGINS}"
fi

INSTALL_DATE=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

python3 - <<PYEOF
import json

with open('${INSTALLED_PLUGINS}', 'r') as f:
    data = json.load(f)

key = '${PLUGIN_NAME}@${MARKETPLACE}'
data['plugins'][key] = [{
    'scope': 'user',
    'installPath': '${CACHE_DIR}',
    'version': '${PLUGIN_VERSION}',
    'installedAt': '${INSTALL_DATE}',
    'lastUpdated': '${INSTALL_DATE}'
}]

with open('${INSTALLED_PLUGINS}', 'w') as f:
    json.dump(data, f, indent=2)
PYEOF

# ── Commit/Push Gate hook ──────────────────────────────────────────────────────

SETTINGS_JSON="${CLAUDE_DIR}/settings.json"

python3 - <<PYEOF
import json, os

path = '${SETTINGS_JSON}'
if os.path.exists(path):
    with open(path, 'r') as f:
        settings = json.load(f)
else:
    settings = {}

hook_command = (
    'cmd=\$(jq -r \'.tool_input.command // ""\' 2>/dev/null); '
    'if echo "\$cmd" | grep -qE \'\\\\bgit\\\\s+(commit|push)\\\\b\'; then '
    'echo \'{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask",'
    '"permissionDecisionReason":"Commit/Push Gate — Claude needs your explicit permission '
    'before committing or pushing. Confirm in the chat to proceed."}}\'; fi'
)

new_hook = {
    'matcher': 'Bash',
    'hooks': [{
        'type': 'command',
        'if': 'Bash(git *)',
        'command': hook_command,
        'timeout': 10,
        'statusMessage': 'Checking commit/push gate...'
    }]
}

hooks = settings.setdefault('hooks', {})
pre = hooks.setdefault('PreToolUse', [])

already = any(
    any(h.get('if') == 'Bash(git *)' for h in entry.get('hooks', []))
    for entry in pre
    if entry.get('matcher') == 'Bash'
)

if not already:
    pre.append(new_hook)
    with open(path, 'w') as f:
        json.dump(settings, f, indent=2)
    print('Commit/Push Gate hook registered in settings.json.')
else:
    print('Commit/Push Gate hook already present — skipped.')
PYEOF

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "  ${PLUGIN_NAME} v${PLUGIN_VERSION} installed."
echo ""
echo "  Agents  : ${AGENT_COUNT} agents installed"
echo "  Skills  : /tdd-clean-code-workflow, /analyse-code-base-for-tdd"
echo "  Gate 9  : Commit/Push Gate hook active in ~/.claude/settings.json"
echo ""
echo "  Restart Claude Code to activate the plugin."
echo ""
