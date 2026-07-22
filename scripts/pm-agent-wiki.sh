#!/usr/bin/env bash
# Commits and pushes whatever is already written to the wiki working tree,
# authenticated as the pm-agent-chordattack bot account, so wiki edits are
# attributable to the agent rather than the founder or main assistant.
#
# Deliberately narrow: no arbitrary git passthrough (no --force, no reset,
# no branch switching) - just add everything currently on disk, commit with
# the given message, push. Fails safely (non-fast-forward) rather than
# clobbering anything on conflict.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_DIR="$(cd "$SCRIPT_DIR/../../ChordAttack.wiki" && pwd)"
TOKEN_FILE="$SCRIPT_DIR/../.secrets/pm-bot-token.txt"
BOT_NAME="pm-agent-chordattack"
BOT_EMAIL="pm.chordattack@gmail.com"

if [ -z "${1:-}" ]; then
  echo "pm-agent-wiki.sh: usage: pm-agent-wiki.sh \"<commit message>\"" >&2
  exit 1
fi

if [ ! -f "$TOKEN_FILE" ]; then
  echo "pm-agent-wiki.sh: token file not found at $TOKEN_FILE" >&2
  exit 1
fi

GH_TOKEN="$(cat "$TOKEN_FILE")"

cd "$WIKI_DIR"
git add -A

if git diff --cached --quiet; then
  echo "pm-agent-wiki.sh: nothing to commit, wiki working tree unchanged"
  exit 0
fi

git -c user.name="$BOT_NAME" -c user.email="$BOT_EMAIL" commit -m "$1"
git push "https://${GH_TOKEN}@github.com/SunandanKadekar/ChordAttack.wiki.git" HEAD:master
