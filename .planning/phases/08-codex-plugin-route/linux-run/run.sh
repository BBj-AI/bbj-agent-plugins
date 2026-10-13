#!/bin/sh
# .planning/phases/08-codex-plugin-route/linux-run/run.sh -- plan 08-05 (and 08-06) real-Codex runs.
# Scripted scenarios against codex-cli 0.162.1 in throwaway homes. Evidence for the phase record,
# never CI: CI has no Codex, and nothing here is a gate.
#
# Safety rules (CODEX-05, threats T-08-17 to T-08-20):
#   - never runs BBj: the only compiler is tests/fake-bin/bbjcpl, a stub that compiles nothing;
#   - never touches ~/.codex or ~/.agents: safe_out refuses any OUTDIR outside
#     $HOME/.cache/bbj-phase8/ (and anything under /tmp, ~/.codex or ~/.agents), and setup_env
#     points HOME and CODEX_HOME into OUTDIR;
#   - never under /tmp (Codex refuses its helper binaries there);
#   - no billed model: every exec uses spike 001's loopback fake Responses server
#     (model_provider=fake, requires_openai_auth=false, model slug gpt-5.5);
#   - the trust bypass of codex exec (see run_exec callers) appears in scripted throwaway runs
#     only; the owner pass trusts the hook the real way, in /hooks.
#
# Usage: sh run.sh SCENARIO [OUTDIR]
#   selftest                  prove safe_out refuses /tmp, ~/.codex and anything outside the base
#   realhome FILE             write a home_snapshot of the real ~/.codex and ~/.agents/skills to FILE
#   envprobe OUTDIR           what environment the plugin hook process gets (D-07 premise, A3)
#   plugin OUTDIR             install from the checkout, docs URL, skills, hook after apply_patch
#                             (CLEAN=1: clean file; NOBBJ=1: no compiler route, the notice)
#   local OUTDIR              bbj-local opt-in
#   shorthand OUTDIR          codex plugin marketplace add BBj-AI/bbj-agent-plugins (A5)
#   prepare-trust OUTDIR      throwaway home for the owner's /hooks trust step
#   prepare-signin OUTDIR     throwaway home for the owner's codex mcp login (VARIANT=plain|oauth)
# Output: OUTDIR/result.txt (key: value lines) and raw files beside it; not committed.
# Exit codes: 0 the scenario ran to the end, 1 a Codex command failed (its last line is in
# result.txt), 2 a refused OUTDIR or a usage error.

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
SPIKE001=$REPO/.planning/spikes/001-codex-plugin-hooks
REALHOME=$HOME
BASE=$REALHOME/.cache/bbj-phase8
PORT=${PORT:-18765}
OUT=
SRV=

# refuse DIR WHY: exit 2 with the fixed message
refuse() {
  echo "run.sh: refused OUTDIR $1 ($2)" >&2
  exit 2
}

# safe_out DIR: the absolute path must be below $HOME/.cache/bbj-phase8/; then it is recreated.
# The rm -rf runs after every check, inside the approved prefix only.
safe_out() {
  case $1 in
    /*) ;;
    *) refuse "$1" "not an absolute path" ;;
  esac
  case $1 in
    /tmp | /tmp/*) refuse "$1" "under /tmp" ;;
    "$REALHOME"/.codex | "$REALHOME"/.codex/*) refuse "$1" "under the real ~/.codex" ;;
    "$REALHOME"/.agents | "$REALHOME"/.agents/*) refuse "$1" "under the real ~/.agents" ;;
    */.. | */../*) refuse "$1" "contains .." ;;
  esac
  case $1 in
    "$BASE"/?*) ;;
    *) refuse "$1" "outside $BASE/" ;;
  esac
  rm -rf "$1" && mkdir -p "$1"
}

# res KEY VALUE: one evidence line in OUT/result.txt
res() {
  printf '%s: %s\n' "$1" "$2" >> "$OUT/result.txt"
}

# setup_env OUT: throwaway HOME and CODEX_HOME, fake compiler and the hermetic hook environment
setup_env() {
  mkdir -p "$1/home/.codex" "$1/proj" "$1/bbj/bin" "$1/state"
  HOME=$1/home
  CODEX_HOME=$1/home/.codex
  export HOME CODEX_HOME
  cp "$REPO/tests/fake-bin/bbjcpl" "$1/bbj/bin/bbjcpl"
  chmod 755 "$1/bbj/bin/bbjcpl"
  if [ "${CLEAN:-}" = 1 ]; then
    : > "$1/cpl-err.txt"
  else
    printf 'bad.bbj: error at line 1 (1): PRINT x   rem missing semicolon\n' > "$1/cpl-err.txt"
  fi
  if [ "${NOBBJ:-}" = 1 ]; then
    rm -rf "$1/bbj"
    mkdir -p "$1/bbj"
    if command -v bbjcpl > /dev/null 2>&1 || command -v bbjcplw > /dev/null 2>&1; then
      echo "run.sh: a BBj compiler is on PATH; the no-route run would not be a no-route run" >&2
      exit 2
    fi
  fi
  BBJ_HOME=$1/bbj
  FAKE_LOG=$1/bbjcpl.log
  FAKE_OUT=$1/cpl-err.txt
  FAKE_EXIT=0
  BBJ_CHECK_DEFAULT_HOMES=
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
  BBJ_CHECK_STATE_DIR=$1/state
  export BBJ_HOME FAKE_LOG FAKE_OUT FAKE_EXIT BBJ_CHECK_DEFAULT_HOMES BBJ_LOCAL_MCP_URL BBJ_CHECK_STATE_DIR
  # a value inherited from the caller must not stand in for what Codex sets for the hook
  unset CLAUDE_PLUGIN_ROOT PLUGIN_ROOT CLAUDE_PLUGIN_DATA BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME CLAUDE_PROJECT_DIR
}

# begin DIR: safe_out, then OUT and the environment
begin() {
  safe_out "$1" || exit 2
  OUT=$1
  setup_env "$OUT"
}

# start_fake OUT: spike 001's loopback fake Responses server; killed when this script exits
start_fake() {
  python3 -I "$SPIKE001/fake_responses.py" "$PORT" "$1/requests.jsonl" &
  SRV=$!
  trap 'kill $SRV 2> /dev/null' EXIT
  trap 'exit 1' INT TERM HUP
  _i=0
  while [ "$_i" -lt 30 ]; do
    if ! kill -0 "$SRV" 2> /dev/null; then
      return 1
    fi
    if python3 -I -c 'import socket, sys
s = socket.socket()
s.settimeout(0.5)
sys.exit(0 if s.connect_ex(("127.0.0.1", int(sys.argv[1]))) == 0 else 1)' "$PORT"; then
      return 0
    fi
    _i=$((_i + 1))
    sleep 0.5
  done
  return 1
}

# run_exec OUT [flags]: spike 001's codex exec, verbatim provider keys, in OUT/proj
run_exec() {
  _o=$1
  shift
  (
    cd "$_o/proj" || exit 1
    git init -q . 2> /dev/null
    timeout 120 codex exec --skip-git-repo-check --json \
      -c model_provider=fake -c model=gpt-5.5 \
      -c 'model_providers.fake.name="fake"' \
      -c "model_providers.fake.base_url=\"http://127.0.0.1:$PORT/v1\"" \
      -c 'model_providers.fake.wire_api="responses"' \
      -c 'model_providers.fake.requires_openai_auth=false' \
      --sandbox danger-full-access "$@" "add bad.bbj" < /dev/null > "$_o/exec.jsonl" 2> "$_o/exec.err"
    echo "$?" > "$_o/exec.rc"
  )
  res exec_rc "$(cat "$_o/exec.rc" 2> /dev/null)"
}

# scratch_copy OUT: copy .claude-plugin and plugins of the checkout into OUT/src
scratch_copy() {
  mkdir -p "$1/src"
  cp -R "$REPO/.claude-plugin" "$REPO/plugins" "$1/src/"
}

# must LABEL CMD...: run a Codex command; on failure record its last output line and exit 1
must() {
  _l=$1
  shift
  if "$@" >> "$OUT/setup.txt" 2>&1; then
    return 0
  fi
  res "${_l}_error" "$(tail -n 1 "$OUT/setup.txt")"
  res status "failed at $_l"
  exit 1
}

# mcp_field NAME COLUMN: a column of the `codex mcp list` line for server NAME, or empty
mcp_field() {
  codex mcp list 2> /dev/null | awk -v n="$1" -v c="$2" '$1 == n { print $c; exit }'
}

# mcp_line NAME: the whole `codex mcp list` line for server NAME with runs of spaces squeezed
mcp_line() {
  codex mcp list 2> /dev/null | awk -v n="$1" '$1 == n { $1 = $1; print; exit }'
}

# skill_count NAME: how many entries NAME has in the skills list of codex debug prompt-input
skill_count() {
  codex debug prompt-input "x" 2> /dev/null | python3 -I -c '
import json, re, sys
name = sys.argv[1]
count = 0
for message in json.load(sys.stdin):
    for part in message.get("content") or []:
        text = part.get("text", "") if isinstance(part, dict) else ""
        for line in text.split("\n"):
            if re.match(r"- (bbj:)?" + re.escape(name) + r": ", line):
                count += 1
print(count)
' "$1" || echo error
}

# compiler_calls: how many times the fake compiler ran
compiler_calls() {
  if [ -f "$OUT/bbjcpl.log" ]; then
    grep -c '^CALL$' "$OUT/bbjcpl.log"
  else
    echo 0
  fi
}

# analyze_requests OUT: evidence lines from the fake server's request log. Only POST bodies after
# the first are searched: hook feedback and the notice reach the model in a later request.
analyze_requests() {
  python3 -I -c '
import json, sys
posts = []
try:
    for line in open(sys.argv[1]):
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        if entry.get("method") == "POST":
            posts.append(json.dumps(entry.get("body")))
except OSError:
    pass
later = posts[1:]
def has(text):
    return "yes" if any(text in post for post in later) else "no"
print("requests_posted: %d" % len(posts))
print("feedback_reached_model: " + has("bbjcpl reported 1 error(s) in"))
print("notice_plugin_command: " + has("codex plugin add bbj-local@basis-bbj"))
print("notice_installer_command: " + has("install-codex.sh --with-local"))
' "$1/requests.jsonl" >> "$1/result.txt"
}

# scenario_realhome FILE: snapshot of the real homes into FILE; a subshell, because lib.sh sets globals
scenario_realhome() {
  [ -n "$1" ] || { echo "run.sh: realhome needs a FILE" >&2; exit 2; }
  (
    . "$REPO/tests/lib.sh"
    home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills" > "$1"
  )
  echo "run.sh: wrote $1 ($(wc -l < "$1") lines)"
}

scenario_selftest() {
  _n=0
  (safe_out /tmp/bbj-phase8-selftest) 2> /dev/null && _n=1
  (safe_out "$REALHOME/.codex/x") 2> /dev/null && _n=1
  (safe_out "$REALHOME/elsewhere") 2> /dev/null && _n=1
  (safe_out "$BASE/../x") 2> /dev/null && _n=1
  (safe_out "relative") 2> /dev/null && _n=1
  if [ "$_n" = 0 ]; then
    echo "selftest ok"
    return 0
  fi
  echo "selftest FAIL: a refused path was accepted" >&2
  return 1
}

scenario_envprobe() {
  begin "$1"
  scratch_copy "$OUT"
  _p=$OUT/src/plugins/bbj
  # the probe writes exactly three named variables, never the environment (T-08-18)
  cat > "$_p/scripts/env-probe.sh" << EOF
#!/bin/sh
# plan 08-05 environment probe: three named variables, nothing else, no stdin
{
  printf 'CLAUDE_PLUGIN_ROOT=%s\n' "\${CLAUDE_PLUGIN_ROOT-<unset>}"
  printf 'PLUGIN_ROOT=%s\n' "\${PLUGIN_ROOT-<unset>}"
  printf 'CLAUDE_PLUGIN_DATA=%s\n' "\${CLAUDE_PLUGIN_DATA-<unset>}"
} > '$OUT/hook-env.txt'
EOF
  python3 -I -c '
import json, sys
path = sys.argv[1]
data = json.load(open(path))
for group in data["hooks"]["PostToolUse"]:
    for hook in group["hooks"]:
        hook["command"] = "sh \"${CLAUDE_PLUGIN_ROOT}/scripts/env-probe.sh\"; " + hook["command"]
json.dump(data, open(path, "w"), indent=2)
' "$_p/hooks/hooks.json"
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  must marketplace_add codex plugin marketplace add "$OUT/src"
  must plugin_add codex plugin add bbj@basis-bbj
  run_exec "$OUT" --dangerously-bypass-hook-trust
  res codex_version "$(codex --version)"
  if [ -f "$OUT/hook-env.txt" ]; then
    while IFS= read -r _line; do res probe "$_line"; done < "$OUT/hook-env.txt"
  else
    res probe "hook-env.txt not written (the probe did not run)"
  fi
  res compiler_calls "$(compiler_calls)"
}

scenario_plugin() {
  begin "$1"
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  res codex_version "$(codex --version)"
  must marketplace_add codex plugin marketplace add "$REPO"
  must plugin_add codex plugin add bbj@basis-bbj
  res mcp_bbj_docs_url "$(mcp_field bbj-docs 2)"
  _l=$(mcp_field bbj-local 2)
  res mcp_bbj_local "${_l:-absent}"
  res skills_programming "$(skill_count bbj-programming)"
  res skills_web "$(skill_count bbj-web-programming)"
  run_exec "$OUT" --dangerously-bypass-hook-trust
  res compiler_calls "$(compiler_calls)"
  if [ -f "$OUT/bbjcpl.log" ] && grep -qx -e '-N' "$OUT/bbjcpl.log"; then
    res dash_n yes
  else
    res dash_n no
  fi
  analyze_requests "$OUT"
}

scenario_local() {
  begin "$1"
  must marketplace_add codex plugin marketplace add "$REPO"
  must plugin_add codex plugin add bbj@basis-bbj
  _b=$(mcp_field bbj-local 2)
  res local_before "${_b:-absent}"
  must local_add codex plugin add bbj-local@basis-bbj
  _a=$(mcp_field bbj-local 2)
  res local_after "${_a:-absent}"
  res mcp_list_after "$(codex mcp list 2> /dev/null | awk '{ $1 = $1; printf "%s | ", $0 }')"
}

scenario_shorthand() {
  begin "$1"
  GIT_TERMINAL_PROMPT=0
  export GIT_TERMINAL_PROMPT
  timeout 90 codex plugin marketplace add BBj-AI/bbj-agent-plugins > "$OUT/shorthand.txt" 2>&1 < /dev/null
  _rc=$?
  res shorthand_rc "$_rc"
  if [ "$_rc" = 0 ]; then
    res shorthand "$(head -n 1 "$OUT/shorthand.txt")"
    res shorthand_list "$(codex plugin marketplace list 2> /dev/null | awk 'NF { $1 = $1; printf "%s | ", $0 }')"
  else
    res shorthand "not run ($(grep -m 1 -v '^[[:space:]]*$' "$OUT/shorthand.txt"))"
  fi
}

# fake provider config for a TUI home: nothing can reach a billed model (T-08-20)
write_fake_config() {
  cat > "$CODEX_HOME/config.toml" << EOF
model_provider = "fake"
model = "gpt-5.5"

[model_providers.fake]
name = "fake"
base_url = "http://127.0.0.1:18765/v1"
wire_api = "responses"
requires_openai_auth = false

[projects."$OUT/proj"]
trust_level = "trusted"
EOF
}

scenario_prepare_trust() {
  begin "$1"
  scratch_copy "$OUT"
  write_fake_config
  git init -q "$OUT/proj"
  must marketplace_add codex plugin marketplace add "$OUT/src"
  must plugin_add codex plugin add bbj@basis-bbj
  res codex_version "$(codex --version)"
  # hooks_list.py checks CODEX_HOME against the real home's base, so it gets the real HOME
  HOME=$REALHOME python3 -I "$HERE/hooks_list.py" "$CODEX_HOME" > "$OUT/hooks_list.txt" 2>&1
  res hooks_list_rc "$?"
  while IFS= read -r _line; do res hooks_list "$_line"; done < "$OUT/hooks_list.txt"
}

scenario_prepare_signin() {
  begin "$1"
  _variant=${VARIANT:-plain}
  scratch_copy "$OUT"
  if [ "$_variant" = oauth ]; then
    _id=$(sed -n 's/^OAUTH_CLIENT_ID=//p' "$REPO/codex/install-codex.sh")
    python3 -I -c '
import json, sys
path, client_id = sys.argv[1], sys.argv[2]
data = json.load(open(path))
data["mcpServers"]["bbj-docs"]["oauth"] = {
    "clientId": client_id,
    "callbackUrl": "http://localhost:47613/callback",
    "callbackPort": 47613,
}
json.dump(data, open(path, "w"), indent=2)
' "$OUT/src/plugins/bbj/.codex-mcp.json" "$_id"
  fi
  res variant "$_variant"
  must marketplace_add codex plugin marketplace add "$OUT/src"
  must plugin_add codex plugin add bbj@basis-bbj
  _line=$(mcp_line bbj-docs)
  res mcp_bbj_docs "${_line:-dropped}"
  # never completes a sign-in: the login waits for a browser callback and is killed after 25 s
  timeout 25 codex mcp login bbj-docs > "$OUT/login.txt" 2>&1 < /dev/null
  res login_rc "$?"
  python3 -I -c '
import re, sys
from urllib.parse import parse_qs, urlparse
text = open(sys.argv[1], errors="replace").read()
for url in re.findall(r"https?://[^\s\"<>]+", text):
    query = parse_qs(urlparse(url).query)
    if "client_id" in query:
        print("login_client_id: " + query["client_id"][0])
        print("login_redirect_uri: " + query.get("redirect_uri", ["<none>"])[0])
        sys.exit(0)
lines = [l.strip() for l in text.splitlines() if l.strip()]
print("login_error: " + (lines[0] if lines else "no output"))
' "$OUT/login.txt" >> "$OUT/result.txt"
}

case ${1:-} in
  selftest) scenario_selftest ;;
  realhome) scenario_realhome "${2:-}" ;;
  envprobe | plugin | local | shorthand | prepare-trust | prepare-signin)
    [ -n "${2:-}" ] || { echo "run.sh: $1 needs an OUTDIR" >&2; exit 2; }
    case $1 in
      envprobe) scenario_envprobe "$2" ;;
      plugin) scenario_plugin "$2" ;;
      local) scenario_local "$2" ;;
      shorthand) scenario_shorthand "$2" ;;
      prepare-trust) scenario_prepare_trust "$2" ;;
      prepare-signin) scenario_prepare_signin "$2" ;;
    esac ;;
  *)
    echo "usage: sh run.sh selftest | realhome FILE | envprobe|plugin|local|shorthand|prepare-trust|prepare-signin OUTDIR" >&2
    exit 2 ;;
esac
