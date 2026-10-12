#!/bin/sh
# spike 002: which manifest/MCP layout gives Codex a literal bbj-docs URL while Claude Code
# keeps ${user_config.docs_url}? Builds one variant of the bbj plugin in a copy of this repo,
# installs it into a throwaway CODEX_HOME, prints `codex mcp list`, and runs
# `claude plugin validate --strict` on the copy. Never touches ~/.codex; runs no BBj.
# Usage: sh run.sh VARIANT OUTDIR   (VARIANT: base | overlay | rootmcp | both)
SPIKE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$SPIKE/../../.." && pwd)
V=$1; OUT=$2
rm -rf "$OUT"; mkdir -p "$OUT/home" "$OUT/repo"
cp -R "$REPO/.claude-plugin" "$REPO/plugins" "$OUT/repo/"
P="$OUT/repo/plugins/bbj"
LIT='{
  "mcpServers": {
    "bbj-docs": {
      "type": "http",
      "url": "https://mcp.bbj-ai.com/mcp"
    }
  }
}'
case $V in
  overlay|both)
    mkdir -p "$P/.codex-plugin"
    printf '%s\n' "$LIT" > "$P/.codex-mcp.json"
    printf '{\n  "name": "bbj",\n  "version": "0.2.0",\n  "description": "spike overlay",\n  "mcpServers": "./.codex-mcp.json"\n}\n' > "$P/.codex-plugin/plugin.json" ;;
esac
case $V in
  rootmcp|both) printf '%s\n' "$LIT" > "$P/mcp.json" ;;
esac
export CODEX_HOME="$OUT/home"
codex plugin marketplace add "$OUT/repo" > "$OUT/setup.txt" 2>&1
codex plugin add bbj@basis-bbj >> "$OUT/setup.txt" 2>&1
echo "== $V: codex mcp list"
codex mcp list 2>/dev/null
echo "== $V: cache files"
(cd "$OUT/home/plugins/cache/basis-bbj/bbj"/* && find . -maxdepth 2 -name '*.json' | sort)
echo "== $V: claude plugin validate --strict"
(cd "$OUT/repo" && claude plugin validate --strict . 2>&1 | tail -3; claude plugin validate --strict plugins/bbj 2>&1 | tail -3)
