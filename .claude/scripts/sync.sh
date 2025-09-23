#!/bin/bash

# ABOUTME: GitHub sync - implementation for sync command
# Manual GitHub synchronization when auto-sync fails or immediate update needed

set -euo pipefail

# Delegate to existing github-sync.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/github-sync.sh" "$@"