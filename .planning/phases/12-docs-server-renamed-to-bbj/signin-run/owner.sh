#!/bin/sh
# .planning/phases/12-docs-server-renamed-to-bbj/signin-run/owner.sh -- plan 12-02 Task 2, the owner
# pass on Linux (NAME-02, SC4; D-08 to D-11). Never CI.
# One-word wrappers around real Claude Code and real Codex in the throwaway homes that run.sh
# prepared (a re-based copy of the Phase 10 owner.sh).
#
#   sh owner.sh claude          Claude Code in the throwaway configuration (the plugin from the
#                               checkout): type /mcp, read the label of the docs server, pick it,
#                               authenticate in the browser, open the tools and read the name of bbj_search
#   sh owner.sh login [ARGS]    codex mcp login ARGS <name> in the Codex home; <name> is the server
#                               name the scripted run read from codex mcp list (cx_server_name)
#   sh owner.sh list [ARGS]     codex mcp list ARGS in the Codex home
#   sh owner.sh codex ARGS...   any codex command in that home (D-11: when Codex refuses the login
#                               command, find the form it accepts and sign in with it)
# Extra arguments after login go to codex, e.g. `sh owner.sh login --no-browser` (prints the URL and
# accepts the callback URL pasted back, for a browser on another machine).
#
# HOME, CODEX_HOME and CLAUDE_CONFIG_DIR point into the throwaway home, so the real ~/.codex, ~/.agents
# and ~/.claude are not touched. Claude Code in the throwaway configuration has no login of its own: if
# it asks you to log in, that login belongs to this throwaway configuration only; do not send a prompt.
# Never paste an authorization URL, a code or a token anywhere. Never runs BBj.
# Exit codes: 0 the client ran and exited, 2 usage error or a home that was not prepared.

BASE=$HOME/.cache/bbj-phase12

case ${1:-} in
  claude) NAME=claude ;;
  login | list | codex) NAME=codex ;;
  *)
    echo "usage: sh owner.sh claude | login [ARGS] | list [ARGS] | codex ARGS..." >&2
    exit 2 ;;
esac

DIR=$BASE/$NAME
if [ ! -d "$DIR/home" ] || [ ! -f "$DIR/result.txt" ]; then
  echo "owner.sh: $DIR was not prepared (run.sh codex / claude first)" >&2
  exit 2
fi

HOME=$DIR/home
CODEX_HOME=$DIR/home/.codex
export HOME CODEX_HOME
unset CLAUDE_PLUGIN_ROOT PLUGIN_ROOT CLAUDE_PLUGIN_DATA

echo "owner.sh: throwaway home $NAME ($DIR); the real ~/.codex, ~/.agents and ~/.claude are not used"

MODE=$1
shift
case $MODE in
  claude)
    CLAUDE_CONFIG_DIR=$DIR/cfg
    export CLAUDE_CONFIG_DIR
    unset CLAUDECODE CLAUDE_CODE_CHILD_SESSION CLAUDE_CODE_SESSION_ID
    cd "$DIR/proj" || exit 2
    echo "In Claude Code:"
    echo "  1. type /mcp and copy the label it shows for the docs server exactly as shown"
    echo "  2. pick the docs server and sign in in the browser that opens"
    echo "  3. back in /mcp, open the server's tools, open bbj_search and copy its full tool name if one is shown"
    echo "  4. quit without sending a prompt"
    echo "If it asks for a login first, that login is for this throwaway configuration only."
    claude ;;
  login)
    SERVER=$(sed -n 's/^cx_server_name: //p' "$DIR/result.txt" | head -n 1)
    if [ -z "$SERVER" ] || [ "$SERVER" = dropped ]; then
      echo "owner.sh: cx_server_name is missing in $DIR/result.txt" >&2
      exit 2
    fi
    echo "owner.sh: running: codex mcp login $* $SERVER"
    codex mcp login "$@" "$SERVER" ;;
  list)
    codex mcp list "$@" ;;
  codex)
    codex "$@" ;;
esac
