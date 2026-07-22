#!/usr/bin/env bash
# Runs `gh issue` authenticated as the pm-agent-chordattack bot account, using its
# own token, so GitHub attributes the action to the agent instead of the builder.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_FILE="$SCRIPT_DIR/../.secrets/pm-bot-token.txt"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "pm-agent-gh.sh: token file not found at $TOKEN_FILE" >&2
  exit 1
fi

GH_TOKEN="$(cat "$TOKEN_FILE")" exec gh issue "$@"
