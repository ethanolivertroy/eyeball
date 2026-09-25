#!/usr/bin/env bash
# Runs the setup script that ships inside the Cursor plugin directory.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILL_IN_REPO="$ROOT/.cursor/skills/eyeball"
SKILL_IN_PLUGIN="$ROOT/plugins/eyeball/skills/eyeball"
if [ -d "$SKILL_IN_REPO" ] && [ -d "$SKILL_IN_PLUGIN" ]; then
  if ! diff -rq "$SKILL_IN_REPO" "$SKILL_IN_PLUGIN" --exclude __pycache__ --exclude '*.pyc'; then
    echo "ERROR: .cursor/skills/eyeball and plugins/eyeball/skills/eyeball differ." >&2
    echo "Cursor's skill scan skips a directory symlink, so both copies are real files and must match." >&2
    exit 1
  fi
fi
exec bash "$ROOT/plugins/eyeball/setup.sh"
