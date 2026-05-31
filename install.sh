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
INSTALL_DATE=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

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

# ── Create cache and marketplace directories ───────────────────────────────────

echo "Installing ${PLUGIN_NAME} v${PLUGIN_VERSION}..."
echo ""

mkdir -p "${CACHE_DIR}/.claude-plugin"
mkdir -p "${CACHE_DIR}/agents"
mkdir -p "${CACHE_DIR}/skills/tdd-clean-code-workflow"
mkdir -p "${CACHE_DIR}/skills/analyse-code-base-for-tdd"

MARKETPLACE_DIR="${CLAUDE_DIR}/plugins/marketplaces/${MARKETPLACE}/.claude-plugin"
mkdir -p "${MARKETPLACE_DIR}"

# ── Write plugin manifest ──────────────────────────────────────────────────────

cat > "${CACHE_DIR}/.claude-plugin/plugin.json" <<PLUGIN_JSON
{
  "name": "${PLUGIN_NAME}",
  "description": "TDD and Clean Code engineering lifecycle with quality gates, 15 specialised agents, and audit trail.",
  "author": {
    "name": "Marco Tedone",
    "email": "marco.tedone@gmail.com"
  }
}
PLUGIN_JSON

# ── Register local marketplace in known_marketplaces.json ─────────────────────

KNOWN_MARKETPLACES="${CLAUDE_DIR}/plugins/known_marketplaces.json"
MARKETPLACE_INSTALL_DIR="${CLAUDE_DIR}/plugins/marketplaces/${MARKETPLACE}"

python3 - <<PYEOF
import json, os

path = '${KNOWN_MARKETPLACES}'
if not os.path.exists(path):
    data = {}
else:
    with open(path, 'r') as f:
        data = json.load(f)

if '${MARKETPLACE}' not in data:
    data['${MARKETPLACE}'] = {
        'source': {
            'source': 'local',
            'path': '${MARKETPLACE_INSTALL_DIR}'
        },
        'installLocation': '${MARKETPLACE_INSTALL_DIR}',
        'lastUpdated': '${INSTALL_DATE}'
    }
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
    print('Local marketplace registered in known_marketplaces.json.')
else:
    print('Local marketplace already registered — skipped.')
PYEOF

# ── Write marketplace manifest ─────────────────────────────────────────────────

cat > "${MARKETPLACE_DIR}/marketplace.json" <<MKTJSON
{
  "\$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "${MARKETPLACE}",
  "description": "Local marketplace for user-installed Claude Code plugins",
  "owner": {
    "name": "Local",
    "email": "local"
  },
  "plugins": [
    {
      "name": "${PLUGIN_NAME}",
      "description": "TDD and Clean Code engineering lifecycle with quality gates, 15 specialised agents, and audit trail.",
      "author": {
        "name": "Marco Tedone",
        "email": "marco.tedone@gmail.com"
      },
      "category": "development",
      "source": "${CACHE_DIR}"
    }
  ]
}
MKTJSON

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

# ── Register in plugin-catalog-cache.json ─────────────────────────────────────

CATALOG_JSON="${CLAUDE_DIR}/plugins/plugin-catalog-cache.json"
SKILL1_CHARS=$(wc -c < "${CACHE_DIR}/skills/tdd-clean-code-workflow/SKILL.md" | tr -d ' ')
SKILL2_CHARS=$(wc -c < "${CACHE_DIR}/skills/analyse-code-base-for-tdd/SKILL.md" | tr -d ' ')

python3 - <<PYEOF
import json, os, re

path = '${CATALOG_JSON}'
if not os.path.exists(path):
    print('plugin-catalog-cache.json not found — skipping catalog registration.')
else:
    with open(path, 'r') as f:
        data = json.load(f)

    def frontmatter_chars(skill_path):
        with open(skill_path) as f:
            content = f.read()
        m = re.search(r'^---\n.*?\n---', content, re.DOTALL)
        return len(m.group(0)) if m else 0

    s1_always = frontmatter_chars('${CACHE_DIR}/skills/tdd-clean-code-workflow/SKILL.md')
    s2_always = frontmatter_chars('${CACHE_DIR}/skills/analyse-code-base-for-tdd/SKILL.md')
    s1_full   = int('${SKILL1_CHARS}')
    s2_full   = int('${SKILL2_CHARS}')

    key = '${PLUGIN_NAME}@${MARKETPLACE}'
    data['catalog']['plugins'][key] = {
        'plugin': '${PLUGIN_NAME}',
        'tokens': {
            'claude-opus-4-7':   {'always_on': 120, 'on_invoke': 2800},
            'claude-sonnet-4-6': {'always_on': 90,  'on_invoke': 2100}
        },
        'components': {
            'commands': [], 'agents': [],
            'skills': [
                {'name': 'tdd-clean-code-workflow',    'chars': {'always_on': s1_always, 'on_invoke': s1_full}},
                {'name': 'analyse-code-base-for-tdd',  'chars': {'always_on': s2_always, 'on_invoke': s2_full}}
            ],
            'hooks': [], 'mcpServers': [], 'lspServers': []
        },
        'unique_installs': 1,
        'last_updated': '${INSTALL_DATE}',
        'marketplace_entry': {
            'name': '${PLUGIN_NAME}',
            'description': 'TDD and Clean Code engineering lifecycle with quality gates, 15 specialised agents, and audit trail.',
            'author': {'name': 'Marco Tedone'},
            'source': 'local',
            'category': 'development'
        },
        'source': key,
        'sha': None,
        'source_sha': None
    }

    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
    print('Plugin catalog entry registered.')
PYEOF

# ── Enable plugin in settings.json ────────────────────────────────────────────

SETTINGS_JSON="${CLAUDE_DIR}/settings.json"

python3 - <<PYEOF
import json, os

path = '${SETTINGS_JSON}'
if os.path.exists(path):
    with open(path, 'r') as f:
        settings = json.load(f)
else:
    settings = {}

key = '${PLUGIN_NAME}@${MARKETPLACE}'
enabled = settings.setdefault('enabledPlugins', {})
if not enabled.get(key):
    enabled[key] = True
    with open(path, 'w') as f:
        json.dump(settings, f, indent=2)
    print('Plugin enabled in settings.json.')
else:
    print('Plugin already enabled in settings.json — skipped.')
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
