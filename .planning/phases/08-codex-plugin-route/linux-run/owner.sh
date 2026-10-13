#!/bin/sh
# .planning/phases/08-codex-plugin-route/linux-run/owner.sh -- plan 08-05 Task 3, the owner pass.
# One-word wrappers around real Codex in the throwaway homes that run.sh prepared. Never CI.
#
#   sh owner.sh trust     open the Codex TUI in owner-H's project; trust the bbj plugin hook in /hooks
#   sh owner.sh login-a   codex mcp login bbj-docs in owner-A (plugin as shipped, no OAuth block)
#   sh owner.sh login-b   codex mcp login bbj-docs in owner-B (scratch copy with an OAuth block)
#
# HOME and CODEX_HOME point into the throwaway home, so the real ~/.codex and ~/.agents are not
# touched. owner-H's config.toml names a loopback fake model provider: do not send a prompt, no
# model is reachable and none is billed. Never runs BBj.
# Exit codes: 0 Codex ran and exited, 2 usage error or a home that was not prepared.

BASE=$HOME/.cache/bbj-phase8

case ${1:-} in
  trust) NAME=owner-H ;;
  login-a) NAME=owner-A ;;
  login-b) NAME=owner-B ;;
  *)
    echo "usage: sh owner.sh trust | login-a | login-b" >&2
    exit 2 ;;
esac

DIR=$BASE/$NAME
if [ ! -d "$DIR/home/.codex" ] || [ ! -f "$DIR/result.txt" ]; then
  echo "owner.sh: $DIR was not prepared (run.sh prepare-trust / prepare-signin first)" >&2
  exit 2
fi

HOME=$DIR/home
CODEX_HOME=$DIR/home/.codex
export HOME CODEX_HOME
unset CLAUDE_PLUGIN_ROOT PLUGIN_ROOT CLAUDE_PLUGIN_DATA

echo "owner.sh: throwaway home $NAME ($CODEX_HOME); the real ~/.codex is not used"

case $1 in
  trust)
    cd "$DIR/proj" || exit 2
    echo "In Codex: type /hooks, pick 'BBj compile-only check', trust it, then quit. Do not send a prompt."
    codex ;;
  login-a | login-b)
    codex mcp login bbj-docs ;;
esac
