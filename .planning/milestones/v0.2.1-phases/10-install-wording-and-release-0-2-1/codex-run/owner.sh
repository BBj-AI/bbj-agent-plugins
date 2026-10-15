#!/bin/sh
# .planning/phases/10-install-wording-and-release-0-2-1/codex-run/owner.sh -- plan 10-04 Task 2, the
# owner pass on Linux (D-16 sign-ins, D-22 before trust). Never CI.
# One-word wrappers around real Claude Code and real Codex in the throwaway homes that run.sh
# prepared (a re-based copy of the Phase 8 owner.sh).
#
#   sh owner.sh claude          Claude Code in the ccsignin configuration (bbj and bbj-local from the
#                               checkout): type /mcp, pick bbj-docs, authenticate in the browser
#   sh owner.sh login           codex mcp login bbj-docs in the signin home (plugin as it ships)
#   sh owner.sh list            codex mcp list in the signin home
#   sh owner.sh trust-upgrade   the Codex TUI in the gitupgrade home's project: /hooks, trust the
#                               BBj hook of the 0.2.0 plugin installed from GitHub, quit
# Extra arguments after login/list go to codex, e.g. `sh owner.sh login --no-browser` (prints the
# URL and accepts the callback URL pasted back, for a browser on another machine).
#
# HOME, CODEX_HOME and CLAUDE_CONFIG_DIR point into the throwaway home, so the real ~/.codex,
# ~/.agents and ~/.claude are not touched. The gitupgrade home's config.toml names a loopback fake
# model provider: do not send a prompt, no model is reachable and none is billed. Claude Code in the
# ccsignin configuration has no login of its own: if it asks you to log in, that login belongs to
# this throwaway configuration only; do not send a prompt either. Never paste an authorization URL,
# a code or a token anywhere. Never runs BBj.
# Exit codes: 0 the client ran and exited, 2 usage error or a home that was not prepared.

BASE=$HOME/.cache/bbj-phase10

case ${1:-} in
  claude) NAME=ccsignin ;;
  login | list) NAME=signin ;;
  trust-upgrade) NAME=gitupgrade ;;
  *)
    echo "usage: sh owner.sh claude | login | list | trust-upgrade" >&2
    exit 2 ;;
esac

DIR=$BASE/$NAME
if [ ! -d "$DIR/home" ] || [ ! -f "$DIR/result.txt" ]; then
  echo "owner.sh: $DIR was not prepared (run.sh ccprep / prepare-signin / gitupgrade-before first)" >&2
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
    echo "In Claude Code: type /mcp, pick bbj-docs, authenticate; do not send a prompt."
    echo "If it asks for a login first, that login is for this throwaway configuration only."
    claude ;;
  login)
    codex mcp login "$@" bbj-docs ;;
  list)
    codex mcp list "$@" ;;
  trust-upgrade)
    cd "$DIR/proj" || exit 2
    echo "In Codex: type /hooks, copy the line of the BBj hook as shown, trust it, then quit. Do not send a prompt."
    codex ;;
esac
