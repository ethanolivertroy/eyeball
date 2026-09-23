#!/usr/bin/env bash
# Runs the setup script that ships inside the Cursor plugin directory.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
exec bash "$ROOT/plugins/eyeball/setup.sh"
