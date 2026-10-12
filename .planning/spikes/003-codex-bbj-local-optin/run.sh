#!/bin/sh
# spike 003: is bbj-local opt-in on the Codex plugin route, and how does a stopped bbj-ls
# show? Throwaway CODEX_HOME; nothing listens on 5009 here. Never touches ~/.codex.
# Usage: sh run.sh OUTDIR
SPIKE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$SPIKE/../../.." && pwd)
OUT=$1
rm -rf "$OUT"; mkdir -p "$OUT/home"
export CODEX_HOME="$OUT/home"
codex plugin marketplace add "$REPO" > "$OUT/setup.txt" 2>&1
echo "== after marketplace add"; codex plugin list 2>/dev/null | grep basis-bbj; codex mcp list 2>/dev/null
codex plugin add bbj-local@basis-bbj >> "$OUT/setup.txt" 2>&1
echo "== after plugin add bbj-local"; codex plugin list 2>/dev/null | grep basis-bbj; codex mcp list 2>/dev/null
echo "== config.toml"; cat "$OUT/home/config.toml"
