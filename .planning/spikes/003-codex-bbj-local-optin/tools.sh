#!/bin/sh
# spike 003b: which bbj-local tools does the model see, and what does a stopped server do?
# Reuses spike 001's fake Responses server. Usage: sh tools.sh OUTDIR [PORT_OVERRIDE]
SPIKE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$SPIKE/../../.." && pwd)
OUT=$1; LPORT=${2:-}
rm -rf "$OUT"; mkdir -p "$OUT/home" "$OUT/proj" "$OUT/repo"
cp -R "$REPO/.claude-plugin" "$REPO/plugins" "$OUT/repo/"
[ -n "$LPORT" ] && sed -i "s/5009/$LPORT/" "$OUT/repo/plugins/bbj-local/.mcp.json"
export CODEX_HOME="$OUT/home"
codex plugin marketplace add "$OUT/repo" > "$OUT/setup.txt" 2>&1
codex plugin add bbj-local@basis-bbj >> "$OUT/setup.txt" 2>&1
python3 -I "$REPO/.planning/spikes/001-codex-plugin-hooks/fake_responses.py" 18766 "$OUT/requests.jsonl" &
SRV=$!; trap 'kill $SRV 2>/dev/null' EXIT; sleep 1
cd "$OUT/proj" && timeout 120 codex exec --skip-git-repo-check --json -c model_provider=fake -c model=gpt-5.5 \
  -c 'model_providers.fake.name="fake"' -c 'model_providers.fake.base_url="http://127.0.0.1:18766/v1"' \
  -c 'model_providers.fake.wire_api="responses"' -c 'model_providers.fake.requires_openai_auth=false' \
  --sandbox danger-full-access "hi" < /dev/null > "$OUT/exec.jsonl" 2> "$OUT/exec.err"
python3 -I -c "
import json
b=json.loads(open('$OUT/requests.jsonl').readline())['body']
def walk(ts,pre=''):
    for t in ts:
        if t.get('type')=='namespace': walk(t.get('tools',[]), t.get('name','')+'.')
        elif 'bbj' in json.dumps(t).lower(): print('tool:', pre+str(t.get('name')))
walk(b.get('tools',[]))
"
grep -i -E "bbj-local|5009|$LPORT|mcp" "$OUT/exec.err" | grep -v WARNING | head -5
grep -o '"type":"error","message":"[^"]*"' "$OUT/exec.jsonl" | head -3
