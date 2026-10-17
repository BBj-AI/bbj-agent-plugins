#!/bin/sh
# spike 004: what does GitHub Copilot CLI 1.0.96 make of the basis-bbj marketplace?
# Copilot runs from a scratch npm prefix with a throwaway HOME, so ~/.copilot is never
# touched. Runs no BBj. Usage: sh run.sh OUTDIR [REPOCOPY]
SPIKE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$SPIKE/../../.." && pwd)
OUT=$1; SRC=${2:-$REPO}
CP=$HOME/.cache/bbj-spike/copilot-npm/node_modules/.bin/copilot
rm -rf "$OUT"; mkdir -p "$OUT/home"
export HOME="$OUT/home" XDG_CONFIG_HOME="$OUT/home/.config"
unset COPILOT_HOME COPILOT_CONFIG_DIR
echo "== marketplace add"; timeout 60 "$CP" plugin marketplace add "$SRC" 2>&1 | tail -4
echo "== marketplace list"; timeout 60 "$CP" plugin marketplace list 2>&1 | tail -6
echo "== browse"; timeout 60 "$CP" plugin marketplace browse basis-bbj 2>&1 | tail -8
echo "== install bbj"; timeout 60 "$CP" plugin install bbj@basis-bbj 2>&1 | tail -6
echo "== list"; timeout 60 "$CP" plugin list 2>&1 | tail -6
echo "== files written under HOME"; find "$OUT/home" -type f | sed "s|$OUT/home|~|" | grep -v -E '/logs?/' | head -40
