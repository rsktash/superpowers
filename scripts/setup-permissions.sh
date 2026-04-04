#!/usr/bin/env bash
# Auto-configure read/write bd permissions in the project's .claude/settings.json.
# Idempotent — skips if permissions already exist.
# Only bd delete and bd init require user approval.

set -uo pipefail

PROJECT_DIR="${1:-$(pwd)}"
SETTINGS_DIR="${PROJECT_DIR}/.claude"
SETTINGS_FILE="${SETTINGS_DIR}/settings.json"

# Skip if no .claude directory
if [ ! -d "$SETTINGS_DIR" ]; then
  exit 0
fi

# Check if bd permissions already configured
if [ -f "$SETTINGS_FILE" ] && grep -q '"Bash(bd show \*)' "$SETTINGS_FILE" 2>/dev/null; then
  echo "bd permissions already configured in ${SETTINGS_FILE}"
  exit 0
fi

# Permissions to add — all non-destructive bd commands
BD_PERMISSIONS=(
  'Bash(bd show *)'
  'Bash(bd list *)'
  'Bash(bd ready *)'
  'Bash(bd children *)'
  'Bash(bd query *)'
  'Bash(bd search *)'
  'Bash(bd comments *)'
  'Bash(bd count *)'
  'Bash(bd diff *)'
  'Bash(bd history *)'
  'Bash(bd prime*)'
  'Bash(bd --version*)'
  'Bash(bd --help*)'
  'Bash(which bd*)'
  'Bash(bd create *)'
  'Bash(bd update *)'
  'Bash(bd close *)'
  'Bash(bd dep add *)'
  'Bash(bd comment *)'
  'Bash(bd note *)'
  'Bash(bd assign *)'
  'Bash(bd label *)'
  'Bash(bd tag *)'
  'Bash(bd link *)'
  'Bash(bd reopen *)'
  'Bash(bd blocked *)'
  'Bash(bd orphans *)'
  'Bash(bd dolt *)'
  'Bash(cat *| bd create *)'
  'Bash(echo *| bd create *)'
  'Bash(cat *| bd update *)'
  'Bash(echo *| bd update *)'
)

# Build JSON array of permissions
perm_json="["
first=true
for perm in "${BD_PERMISSIONS[@]}"; do
  if [ "$first" = true ]; then
    first=false
  else
    perm_json+=","
  fi
  perm_json+="\"${perm}\""
done
perm_json+="]"

# If settings file doesn't exist, create it with just permissions
if [ ! -f "$SETTINGS_FILE" ]; then
  cat > "$SETTINGS_FILE" <<SETTINGSJSON
{
  "permissions": {
    "allow": ${perm_json}
  }
}
SETTINGSJSON
  echo "Created ${SETTINGS_FILE} with bd permissions"
  exit 0
fi

# Merge permissions into existing settings using node (available if npm is)
if command -v node >/dev/null 2>&1; then
  node -e "
    const fs = require('fs');
    const settingsFile = '${SETTINGS_FILE}';
    const newPerms = ${perm_json};

    let settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
    if (!settings.permissions) settings.permissions = {};
    if (!settings.permissions.allow) settings.permissions.allow = [];

    const existing = new Set(settings.permissions.allow);
    for (const p of newPerms) {
      if (!existing.has(p)) {
        settings.permissions.allow.push(p);
      }
    }

    fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + '\n');
  "
  echo "Added bd permissions to ${SETTINGS_FILE}"
else
  echo "WARN: node not available, cannot merge permissions into ${SETTINGS_FILE}" >&2
fi

exit 0
