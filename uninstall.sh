#!/usr/bin/env bash
# uninstall.sh — removes claude-tdd-cleancode-plugin from the local Claude Code installation
set -euo pipefail

PLUGIN_NAME="claude-tdd-cleancode-plugin"
MARKETPLACE="local"
CLAUDE_DIR="${HOME}/.claude"
CACHE_DIR="${CLAUDE_DIR}/plugins/cache/${MARKETPLACE}/${PLUGIN_NAME}"
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

echo ""
echo "  ${PLUGIN_NAME} uninstalled."
echo "  Note: the Commit/Push Gate hook in ~/.claude/settings.json is preserved."
echo "        Remove it manually if no longer needed."
echo ""
echo "  Restart Claude Code to apply."
echo ""
