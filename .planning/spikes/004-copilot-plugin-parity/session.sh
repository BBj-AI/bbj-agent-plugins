#!/bin/sh
# spike 004b: one offline Copilot session against spike 001's fake Responses server
# (BYOK, COPILOT_OFFLINE=true: no GitHub auth, no billing). Throwaway HOME, fake compiler.
# Usage: sh session.sh OUTDIR [REPOCOPY]   (FAKE_TOOL=<tool name> makes turn 1 call that tool)
SPIKE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$SPIKE/../../.." && pwd)
OUT=$1; SRC=${2:-$REPO}
CP=/home/coder/.cache/bbj-spike/copilot-npm/node_modules/.bin/copilot
rm -rf "$OUT"; mkdir -p "$OUT/home" "$OUT/proj" "$OUT/bbj/bin"
cp "$REPO/tests/fake-bin/bbjcpl" "$OUT/bbj/bin/bbjcpl"; chmod 755 "$OUT/bbj/bin/bbjcpl"
printf 'bad.bbj: error at line 1 (1): PRINT x   rem missing semicolon\n' > "$OUT/cpl-err.txt"
export HOME="$OUT/home" XDG_CONFIG_HOME="$OUT/home/.config"
unset COPILOT_HOME COPILOT_CONFIG_DIR
"$CP" plugin marketplace add "$SRC" > "$OUT/setup.txt" 2>&1
"$CP" plugin install bbj@basis-bbj >> "$OUT/setup.txt" 2>&1
PORT=18767
python3 -I "$SPIKE/fake_copilot.py" "$PORT" "$OUT/requests.jsonl" &
SRV=$!; trap 'kill $SRV 2>/dev/null' EXIT; sleep 1
export BBJ_HOME="$OUT/bbj" FAKE_LOG="$OUT/bbjcpl.log" FAKE_OUT="$OUT/cpl-err.txt"
# NOROUTE=1: no compiler and no bbj-ls, to see how the no-route notice arrives
if [ "${NOROUTE:-}" = 1 ]; then mkdir -p "$OUT/empty"; export BBJ_HOME="$OUT/empty" BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp; fi
export BBJ_CHECK_DEFAULT_HOMES= COPILOT_OFFLINE=true COPILOT_AUTO_UPDATE=false
export COPILOT_PROVIDER_BASE_URL="http://127.0.0.1:$PORT/v1" COPILOT_PROVIDER_WIRE_API=responses
export COPILOT_MODEL=gpt-5.5 COPILOT_PROVIDER_API_KEY=x
cd "$OUT/proj" && git init -q . && timeout 120 "$CP" -p "add bad.bbj" --allow-all-tools --no-auto-update \
  --log-level debug --log-dir "$OUT/logs" < /dev/null > "$OUT/out.txt" 2> "$OUT/err.txt"
echo "rc=$?"
