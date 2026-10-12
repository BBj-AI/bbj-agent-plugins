#!/bin/sh
# spike 001: does the bbj plugin's hook fire in Codex after apply_patch, installed via
# `codex plugin add`, and does its feedback reach the model? Throwaway CODEX_HOME, fake
# model server on loopback, fake compiler. Never touches ~/.codex, never runs BBj.
# Usage: sh run.sh OUTDIR [extra codex exec flags...]
SPIKE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$SPIKE/../../.." && pwd)
OUT=$1; shift
rm -rf "$OUT"; mkdir -p "$OUT/home" "$OUT/proj" "$OUT/bbj/bin"
cp "$REPO/tests/fake-bin/bbjcpl" "$OUT/bbj/bin/bbjcpl"; chmod 755 "$OUT/bbj/bin/bbjcpl"
if [ "${CLEAN:-}" = 1 ]; then : > "$OUT/cpl-err.txt"; else printf 'bad.bbj: error at line 1 (1): PRINT x   rem missing semicolon\n' > "$OUT/cpl-err.txt"; fi
PORT=${PORT:-18765}
python3 -I "$SPIKE/fake_responses.py" "$PORT" "$OUT/requests.jsonl" &
SRV=$!
trap 'kill $SRV 2>/dev/null' EXIT
sleep 1
if [ "${NOBBJ:-}" = 1 ]; then rm -rf "$OUT/bbj"; mkdir -p "$OUT/bbj"; fi
export BBJ_CHECK_DEFAULT_HOMES= BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
export CODEX_HOME="$OUT/home" BBJ_HOME="$OUT/bbj" FAKE_LOG="$OUT/bbjcpl.log" FAKE_OUT="$OUT/cpl-err.txt" FAKE_EXIT=0
codex plugin marketplace add "$REPO" > "$OUT/setup.txt" 2>&1
codex plugin add bbj@basis-bbj >> "$OUT/setup.txt" 2>&1
cd "$OUT/proj" && git init -q .
timeout 120 codex exec --skip-git-repo-check --json \
  -c model_provider=fake -c model=${MODEL:-gpt-5.5} \
  -c 'model_providers.fake.name="fake"' \
  -c "model_providers.fake.base_url=\"http://127.0.0.1:$PORT/v1\"" \
  -c 'model_providers.fake.wire_api="responses"' \
  -c 'model_providers.fake.requires_openai_auth=false' \
  --sandbox ${SANDBOX:-danger-full-access} "$@" "add bad.bbj" < /dev/null > "$OUT/exec.jsonl" 2> "$OUT/exec.err"
echo "exec rc=$?"
