#!/usr/bin/env bash
# uninstall.sh — removes claude-tdd-cleancode-plugin from the local Claude Code installation
set -euo pipefail

PLUGIN_NAME="claude-tdd-cleancode-plugin"
MARKETPLACE="local"
CLAUDE_DIR="${HOME}/.claude"
CACHE_DIR="${CLAUDE_DIR}/plugins/cache/${MARKETPLACE}/${PLUGIN_NAME}"
MARKETPLACE_DIR="${CLAUDE_DIR}/plugins/marketplaces/${MARKETPLACE}"
INSTALLED_PLUGINS="${CLAUDE_DIR}/plugins/installed_plugins.json"

echo "Uninstalling ${PLUGIN_NAME}..."
echo ""

# ── Remove plugin cache ────────────────────────────────────────────────────────

if [[ -d "${CACHE_DIR}" ]]; then
  rm -rf "${CACHE_DIR}"
  echo "  Removed plugin cache at ${CACHE_DIR}"
else
  echo "  Plugin cache not found — skipping."
fi

# ── Remove local marketplace directory ────────────────────────────────────────

if [[ -d "${MARKETPLACE_DIR}" ]]; then
  rm -rf "${MARKETPLACE_DIR}"
  echo "  Removed local marketplace at ${MARKETPLACE_DIR}"
fi

# ── Remove local marketplace from known_marketplaces.json ─────────────────────

KNOWN_MARKETPLACES="${CLAUDE_DIR}/plugins/known_marketplaces.json"
if [[ -f "${KNOWN_MARKETPLACES}" ]]; then
  python3 - <<PYEOF
import json

with open('${KNOWN_MARKETPLACES}', 'r') as f:
    data = json.load(f)

if '${MARKETPLACE}' in data:
    del data['${MARKETPLACE}']
    with open('${KNOWN_MARKETPLACES}', 'w') as f:
        json.dump(data, f, indent=2)
    print('  Removed local marketplace from known_marketplaces.json.')
else:
    print('  Local marketplace was not registered — skipping.')
PYEOF
fi

# ── Remove from installed_plugins.json ────────────────────────────────────────

if [[ -f "${INSTALLED_PLUGINS}" ]]; then
  python3 - <<PYEOF
import json

with open('${INSTALLED_PLUGINS}', 'r') as f:
    data = json.load(f)

key = '${PLUGIN_NAME}@${MARKETPLACE}'
if key in data.get('plugins', {}):
    del data['plugins'][key]
    print(f'  Removed plugin registration for {key}.')
else:
    print('  Plugin was not registered — skipping.')

with open('${INSTALLED_PLUGINS}', 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
fi

# ── Remove from plugin-catalog-cache.json ─────────────────────────────────────

CATALOG_JSON="${CLAUDE_DIR}/plugins/plugin-catalog-cache.json"
if [[ -f "${CATALOG_JSON}" ]]; then
  python3 - <<PYEOF
import json

with open('${CATALOG_JSON}', 'r') as f:
    data = json.load(f)

key = '${PLUGIN_NAME}@${MARKETPLACE}'
if key in data.get('catalog', {}).get('plugins', {}):
    del data['catalog']['plugins'][key]
    with open('${CATALOG_JSON}', 'w') as f:
        json.dump(data, f, indent=2)
    print('  Removed plugin catalog entry.')
else:
    print('  Plugin catalog entry not found — skipping.')
PYEOF
fi

# ── Remove from enabledPlugins in settings.json ───────────────────────────────

SETTINGS_JSON="${CLAUDE_DIR}/settings.json"
if [[ -f "${SETTINGS_JSON}" ]]; then
  python3 - <<PYEOF
import json

with open('${SETTINGS_JSON}', 'r') as f:
    settings = json.load(f)

key = '${PLUGIN_NAME}@${MARKETPLACE}'
enabled = settings.get('enabledPlugins', {})
if key in enabled:
    del enabled[key]
    with open('${SETTINGS_JSON}', 'w') as f:
        json.dump(settings, f, indent=2)
    print('  Removed plugin from enabledPlugins in settings.json.')
else:
    print('  Plugin was not in enabledPlugins — skipping.')
PYEOF
fi

echo ""
echo "  ${PLUGIN_NAME} uninstalled."
echo "  Note: the Commit/Push Gate hook in ~/.claude/settings.json is preserved."
echo "        Remove it manually if no longer needed."
echo ""
echo "  Restart Claude Code to apply."
echo ""
