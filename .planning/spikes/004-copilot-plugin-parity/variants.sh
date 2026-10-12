#!/bin/sh
# spike 004c: which extra manifest gives Copilot (and Codex) a literal bbj-docs URL while
# Claude Code keeps userConfig? Builds a repo copy per variant, runs one offline Copilot
# session (fake model, throwaway HOME), checks Codex in a throwaway CODEX_HOME, and runs
# claude plugin validate --strict. Usage: sh variants.sh VARIANT OUTDIR   (VARIANT: c1 | c2)
SPIKE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$SPIKE/../../.." && pwd)
V=$1; OUT=$2
rm -rf "$OUT"; mkdir -p "$OUT/repo"
cp -R "$REPO/.claude-plugin" "$REPO/plugins" "$OUT/repo/"
P="$OUT/repo/plugins/bbj"
LIT='"mcpServers": {
    "bbj-docs": {
      "type": "http",
      "url": "https://mcp.bbj-ai.com/mcp"
    }
  }'
case $V in
  c1)
    printf '{\n  %s\n}\n' "$LIT" > "$P/.codex-mcp.json"
    mkdir -p "$P/.codex-plugin" "$P/.github/plugin"
    printf '{\n  "name": "bbj",\n  "version": "0.2.0",\n  "description": "spike",\n  "mcpServers": "./.codex-mcp.json"\n}\n' > "$P/.codex-plugin/plugin.json"
    cp "$P/.codex-plugin/plugin.json" "$P/.github/plugin/plugin.json" ;;
  c2)
    printf '{\n  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",\n  "name": "bbj",\n  "version": "0.2.0",\n  "description": "spike"\n}\n' > "$P/plugin.json"
    printf '{\n  "$schema": "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json",\n  %s\n}\n' "$LIT" > "$P/mcp.json" ;;
esac
echo "== $V copilot"
FAKE_TOOL= sh "$SPIKE/session.sh" "$OUT/copilot" "$OUT/repo" > /dev/null 2>&1
grep -h -i -E "invalid mcp|bbj-docs|mcp\.bbj-ai|plugin\.json|schema" "$OUT/copilot/logs/"*.log | cut -c1-260 | sort -u | head -8
F=$(find "$OUT/copilot/home/.copilot" -name events.jsonl | head -1)
grep -o '"skill[^"]*":"bbj[^"]*"' "$F" 2>/dev/null | sort -u | head -3
echo "== $V codex"
export CODEX_HOME="$OUT/codex"; mkdir -p "$CODEX_HOME"
codex plugin marketplace add "$OUT/repo" > /dev/null 2>&1; codex plugin add bbj@basis-bbj > /dev/null 2>&1
codex mcp list 2>/dev/null
echo "== $V claude strict"
(cd "$OUT/repo" && claude plugin validate --strict . 2>&1 | tail -1; claude plugin validate --strict plugins/bbj 2>&1 | tail -1)
