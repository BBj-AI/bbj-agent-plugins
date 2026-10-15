#!/bin/sh
# .planning/phases/10-install-wording-and-release-0-2-1/codex-run/run.sh -- plan 10-04 real-Codex and
# real-Claude-Code runs (D-16 sign-in homes, D-19 tooling, D-22 Git-marketplace upgrade readings).
# A re-based copy of the Phase 8 harness (.planning/phases/08-codex-plugin-route/linux-run/run.sh):
# scenarios against codex-cli and claude in throwaway homes. Evidence for the phase record, never CI:
# CI has no Codex, and nothing here is a gate.
#
# Safety rules (REL-08, threats T-10-10 and T-10-11, from CODEX-05 / T-08-17 to T-08-20):
#   - never runs BBj: the only compilers are tests/fake-bin/bbjcpl, a stub that compiles nothing, and
#     (realcompiler only) the real bbjcpl, which the hook calls with -N (compile-only);
#   - never touches ~/.codex, ~/.agents or ~/.claude: safe_out refuses any OUTDIR outside
#     $HOME/.cache/bbj-phase10/ (and anything under /tmp, ~/.codex or ~/.agents), setup_env points
#     HOME and CODEX_HOME into OUTDIR, and ccprep gives claude a CLAUDE_CONFIG_DIR inside OUTDIR;
#   - never under /tmp (Codex refuses its helper binaries there);
#   - no billed model: every exec uses spike 001's loopback fake Responses server
#     (model_provider=fake, requires_openai_auth=false, model slug gpt-5.5);
#   - the trust bypass of codex exec (see run_exec callers) appears in scripted throwaway runs
#     only; the trust the record reports is the owner's own, given in /hooks (owner.sh trust-upgrade).
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
#   posttrust OUTDIR          plan 08-06: the owner-trusted home (owner-H) in place; apply_patch of a
#                             bad .bbj with NO bypass flag; trustStatus before and after
#   upgrade OUTDIR            plan 08-06 (D-18): owner-H in place; the scratch copy moves to a test
#                             version (UPGRADE_VERSION, default 0.2.0-test), Codex refreshes the
#                             plugin, then trustStatus, hash and whether the hook still runs
#   switch OUTDIR             plan 08-06 (D-05, D-06): the real installer, its --remove and the two
#                             plugin commands in a fresh throwaway home; ORDER=a (install, remove,
#                             plugin; default) or ORDER=b (install, plugin = double install, remove)
# Plan 10-04 scenarios:
#   realcompiler OUTDIR       the plugin route from the checkout with the real compiler
#                             (REAL_BBJ_HOME, default /opt/bbx): bad apply_patch gives bbjcpl feedback,
#                             a clean payload is silent. TIER2=1: no compiler route, the hook asks the
#                             live bbj-ls on 127.0.0.1:5009 (bbj-local reported)
#   gitupgrade-before OUTDIR  D-22 before half: fresh home, GitHub marketplace (BBj-AI/bbj-agent-plugins),
#                             bbj@basis-bbj, a project folder for the owner's /hooks trust step
#   gitupgrade-after OUTDIR   D-22 after half (plan 10-11, keep mode): marketplace upgrade, plugin add,
#                             then what Codex lists and the hook trust state
#   gitupgrade-posttrust OUTDIR   plan 10-11 (keep mode): fake-model exec with no bypass flag
#   fromgit OUTDIR            plan 10-11 (D-19): fresh home, shorthand marketplace add from GitHub,
#                             plugin add, one fake-model exec with the bypass and the fake compiler
#   ccprep OUTDIR             throwaway Claude Code configuration (OUTDIR/cfg) with bbj and bbj-local
#                             installed from the checkout; the owner signs in to bbj-docs there
# posttrust and upgrade work on an existing prepared home: safe_out keeps it (same prefix checks, no
# delete, the directory must exist). Every other scenario recreates its OUTDIR.
# Output: OUTDIR/result.txt (key: value lines) and raw files beside it; not committed.
# Exit codes: 0 the scenario ran to the end, 1 a Codex command failed (its last line is in
# result.txt), 2 a refused OUTDIR or a usage error.

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
SPIKE001=$REPO/.planning/spikes/001-codex-plugin-hooks
REALHOME=$HOME
BASE=$REALHOME/.cache/bbj-phase10
PORT=${PORT:-18765}
OUT=
SRV=

# refuse DIR WHY: exit 2 with the fixed message
refuse() {
  echo "run.sh: refused OUTDIR $1 ($2)" >&2
  exit 2
}

# safe_out DIR [keep]: the absolute path must be below $HOME/.cache/bbj-phase10/; then it is recreated.
# With keep (plan 08-06) the same checks run, nothing is deleted and DIR must already exist.
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
  if [ "${2:-}" = keep ]; then
    [ -d "$1" ] || refuse "$1" "keep mode needs an existing directory"
    return 0
  fi
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

# begin DIR [keep]: safe_out, then OUT and the environment
begin() {
  safe_out "$1" "${2:-}" || exit 2
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

# run_exec OUT [flags]: spike 001's codex exec, verbatim provider keys, in OUT/proj.
# EXEC_LABEL (plan 08-06) names the run: the argument line goes to OUT/exec-LABEL.cmd, the result
# key is LABEL_exec_rc, and exec.jsonl / exec.err are kept as exec-LABEL.jsonl / exec-LABEL.err.
run_exec() {
  _o=$1
  shift
  (
    cd "$_o/proj" || exit 1
    git init -q . 2> /dev/null
    set -- exec --skip-git-repo-check --json \
      -c model_provider=fake -c model=gpt-5.5 \
      -c 'model_providers.fake.name="fake"' \
      -c "model_providers.fake.base_url=\"http://127.0.0.1:$PORT/v1\"" \
      -c 'model_providers.fake.wire_api="responses"' \
      -c 'model_providers.fake.requires_openai_auth=false' \
      --sandbox danger-full-access "$@" "add bad.bbj"
    if [ -n "${EXEC_LABEL:-}" ]; then
      printf 'codex' > "$_o/exec-$EXEC_LABEL.cmd"
      for _a in "$@"; do printf ' %s' "$_a" >> "$_o/exec-$EXEC_LABEL.cmd"; done
      echo >> "$_o/exec-$EXEC_LABEL.cmd"
    fi
    timeout 120 codex "$@" < /dev/null > "$_o/exec.jsonl" 2> "$_o/exec.err"
    echo "$?" > "$_o/exec.rc"
  )
  if [ -n "${EXEC_LABEL:-}" ]; then
    cp "$_o/exec.jsonl" "$_o/exec-$EXEC_LABEL.jsonl" 2> /dev/null
    cp "$_o/exec.err" "$_o/exec-$EXEC_LABEL.err" 2> /dev/null
    res "${EXEC_LABEL}_exec_rc" "$(cat "$_o/exec.rc" 2> /dev/null)"
  else
    res exec_rc "$(cat "$_o/exec.rc" 2> /dev/null)"
  fi
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

# skill_names: the names of the two BBj skills as codex debug prompt-input lists them (one per entry)
skill_names() {
  codex debug prompt-input "x" 2> /dev/null | python3 -I -c '
import json, re, sys
names = []
for message in json.load(sys.stdin):
    for part in message.get("content") or []:
        text = part.get("text", "") if isinstance(part, dict) else ""
        for line in text.split("\n"):
            found = re.match(r"- ((?:bbj:)?bbj-(?:web-)?programming): ", line)
            if found:
                names.append(found.group(1))
print(" ".join(names))
' || echo error
}

# compiler_calls: how many times the fake compiler ran
compiler_calls() {
  if [ -f "$OUT/bbjcpl.log" ]; then
    grep -c '^CALL$' "$OUT/bbjcpl.log"
  else
    echo 0
  fi
}

# analyze_requests OUT [PREFIX]: evidence lines from the fake server's request log, keys prefixed
# with PREFIX (plan 08-06). Only POST bodies after the first are searched: hook feedback and the
# notice reach the model in a later request.
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
prefix = sys.argv[2]
print(prefix + "requests_posted: %d" % len(posts))
print(prefix + "feedback_reached_model: " + has("bbjcpl reported 1 error(s) in"))
print(prefix + "notice_plugin_command: " + has("codex plugin add bbj-local@basis-bbj"))
print(prefix + "notice_installer_command: " + has("install-codex.sh --with-local"))
' "$1/requests.jsonl" "${2:-}" >> "$1/result.txt"
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
  (safe_out /tmp/bbj-phase10-selftest) 2> /dev/null && _n=1
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
        # the requested scope is a plain word list, not a secret; state and PKCE values are never printed
        print("login_scope: " + query.get("scope", ["<none>"])[0])
        sys.exit(0)
lines = [l.strip() for l in text.splitlines() if l.strip()]
print("login_error: " + (lines[0] if lines else "no output"))
' "$OUT/login.txt" >> "$OUT/result.txt"
}

# ---- plan 08-06: after the real trust, the upgrade (D-18) and the switch (D-05, D-06) ----

# stamp: UTC time for the result lines
stamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# hooks_read LABEL: hooks_list.py on the throwaway CODEX_HOME (it needs the real HOME to accept the
# path); records hooks_count_LABEL, source_LABEL, trust_LABEL and hash_LABEL (values in order,
# comma-joined) and keeps the raw lines in OUT/hooks-LABEL.txt
hooks_read() {
  _f=$OUT/hooks-$1.txt
  HOME=$REALHOME python3 -I "$HERE/hooks_list.py" "$CODEX_HOME" > "$_f" 2> "$OUT/hooks-$1.err"
  res "hooks_list_rc_$1" "$?"
  res "hooks_count_$1" "$(grep -c '^key=' "$_f")"
  res "source_$1" "$(sed -n 's/^key=[^ ]* source=\([^ ]*\) .*/\1/p' "$_f" | tr '\n' ',' | sed 's/,$//')"
  res "trust_$1" "$(sed -n 's/.* trustStatus=\([^ ]*\) .*/\1/p' "$_f" | tr '\n' ',' | sed 's/,$//')"
  res "hash_$1" "$(sed -n 's/.* currentHash=\([^ ]*\) .*/\1/p' "$_f" | tr '\n' ',' | sed 's/,$//')"
}

# last_value KEY: the last value of KEY in OUT/result.txt
last_value() {
  sed -n "s/^$1: //p" "$OUT/result.txt" | tail -n 1
}

# dash_n_result: dash_n yes|no from the fake compiler's argv log
dash_n_result() {
  if [ -f "$OUT/bbjcpl.log" ] && grep -qx -e '-N' "$OUT/bbjcpl.log"; then
    res "$1" yes
  else
    res "$1" no
  fi
}

# feedback_count OUT: how many times the bbjcpl feedback header is in the last request body
feedback_count() {
  python3 -I -c '
import json, sys
last = ""
try:
    for line in open(sys.argv[1]):
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        if entry.get("method") == "POST":
            last = json.dumps(entry.get("body"))
except OSError:
    pass
print(last.count("bbjcpl reported 1 error(s) in"))
' "$1/requests.jsonl"
}

# in_place_home: owner-H style home that exists and was prepared (result.txt present)
in_place_home() {
  begin "$1" keep
  [ -f "$OUT/result.txt" ] || { echo "run.sh: $OUT is not a prepared home (no result.txt)" >&2; exit 2; }
  rm -f "$OUT/proj/bad.bbj" "$OUT/bbjcpl.log" "$OUT/requests.jsonl"
}

scenario_posttrust() {
  in_place_home "$1"
  res posttrust_run "$(stamp)"
  hooks_read posttrust_before
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  # no bypass flag: the hook runs only because the owner trusted it in /hooks
  EXEC_LABEL=posttrust run_exec "$OUT"
  res compiler_calls "$(compiler_calls)"
  dash_n_result dash_n
  analyze_requests "$OUT"
  res feedback_occurrences "$(feedback_count "$OUT")"
  res bypass_flag_in_cmd "$(grep -c 'dangerously-bypass-hook-trust' "$OUT/exec-posttrust.cmd")"
  hooks_read posttrust_after
  cp "$OUT/requests.jsonl" "$OUT/requests-posttrust.jsonl" 2> /dev/null
  cp "$OUT/bbjcpl.log" "$OUT/bbjcpl-posttrust.log" 2> /dev/null
}

# set_test_version SRC VERSION: VERSION in the five places of the scratch copy, nowhere else
set_test_version() {
  python3 -I -c '
import json, sys
src, version = sys.argv[1], sys.argv[2]
files = [
    "plugins/bbj/.claude-plugin/plugin.json",
    "plugins/bbj/.codex-plugin/plugin.json",
    "plugins/bbj-local/.claude-plugin/plugin.json",
]
n = 0
for rel in files:
    path = src + "/" + rel
    data = json.load(open(path))
    data["version"] = version
    json.dump(data, open(path, "w"), indent=2)
    n += 1
path = src + "/.claude-plugin/marketplace.json"
data = json.load(open(path))
for entry in data["plugins"]:
    entry["version"] = version
    n += 1
json.dump(data, open(path, "w"), indent=2)
print(n)
' "$1" "$2"
}

# trusted_hashes: the hooks.state trusted_hash lines of the throwaway config.toml
trusted_hashes() {
  grep -E '^(\[hooks\.state\.|trusted_hash)' "$CODEX_HOME/config.toml" 2> /dev/null | tr '\n' ' '
}

scenario_upgrade() {
  in_place_home "$1"
  _v=${UPGRADE_VERSION:-0.2.0-test}
  _cache=$CODEX_HOME/plugins/cache/basis-bbj/bbj
  res upgrade_run "$(stamp)"
  res upgrade_test_version "$_v"
  res cache_versions_before "$(ls "$_cache" 2> /dev/null | tr '\n' ' ')"
  hooks_read before_upgrade
  res config_trust_before_upgrade "$(trusted_hashes)"
  res versions_set "$(set_test_version "$OUT/src" "$_v")"
  _cmd="none (the cache did not change)"
  codex plugin marketplace upgrade basis-bbj > "$OUT/upgrade-marketplace.txt" 2>&1 < /dev/null
  res upgrade_marketplace_rc "$?"
  res upgrade_marketplace_first "$(grep -m 2 -v '^[[:space:]]*$' "$OUT/upgrade-marketplace.txt" | tr '\n' '|')"
  if [ -d "$_cache/$_v" ]; then
    _cmd="codex plugin marketplace upgrade basis-bbj"
  else
    codex plugin add bbj@basis-bbj > "$OUT/upgrade-add.txt" 2>&1 < /dev/null
    res upgrade_add_rc "$?"
    res upgrade_add_first "$(grep -m 2 -v '^[[:space:]]*$' "$OUT/upgrade-add.txt" | tr '\n' '|')"
    if [ -d "$_cache/$_v" ]; then
      _cmd="codex plugin add bbj@basis-bbj (after codex plugin marketplace upgrade basis-bbj left the cache unchanged)"
    fi
  fi
  res upgrade_refresh_command "$_cmd"
  res cache_versions "$(ls "$_cache" 2> /dev/null | tr '\n' ' ')"
  hooks_read after_upgrade
  res config_trust_after_upgrade "$(trusted_hashes)"
  if [ "$(last_value hash_before_upgrade)" = "$(last_value hash_after_upgrade)" ]; then
    res hash_changed no
  else
    res hash_changed yes
  fi
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  # no bypass flag: whether the hook runs depends on the trust state alone
  EXEC_LABEL=upgrade run_exec "$OUT"
  res upgrade_compiler_calls "$(compiler_calls)"
  dash_n_result upgrade_dash_n
  analyze_requests "$OUT" upgrade_
  res upgrade_bypass_flag_in_cmd "$(grep -c 'dangerously-bypass-hook-trust' "$OUT/exec-upgrade.cmd")"
  if [ "$(last_value upgrade_compiler_calls)" = 1 ]; then
    res hook_runs_after_upgrade yes
  else
    res hook_runs_after_upgrade no
  fi
  _n=$(last_value hooks_count_after_upgrade)
  _bad=$(last_value trust_after_upgrade | tr ',' '\n' | grep -cvx trusted)
  if [ "${_n:-0}" = 0 ] || [ "$_bad" != 0 ] || [ "$(last_value hook_runs_after_upgrade)" != yes ]; then
    res upgrade_asks_trust_again yes
  else
    res upgrade_asks_trust_again no
  fi
  cp "$OUT/requests.jsonl" "$OUT/requests-upgrade.jsonl" 2> /dev/null
  cp "$OUT/bbjcpl.log" "$OUT/bbjcpl-upgrade.log" 2> /dev/null
}

# snap_state LABEL: hook entries, skill entries and bbj-docs servers as Codex lists them now
snap_state() {
  hooks_read "$1"
  res "skills_programming_$1" "$(skill_count bbj-programming)"
  res "skills_web_$1" "$(skill_count bbj-web-programming)"
  res "skill_names_$1" "$(skill_names)"
  res "docs_servers_$1" "$(codex mcp list 2> /dev/null | awk '$1 == "bbj-docs"' | wc -l | tr -d ' ')"
  res "docs_url_$1" "$(codex mcp list 2> /dev/null | awk '$1 == "bbj-docs" { printf "%s ", $2 }' | sed 's/ *$//')"
  res "mcp_list_$1" "$(codex mcp list 2> /dev/null | awk 'NF { $1 = $1; printf "%s | ", $0 }')"
  res "skill_dirs_$1" "$(ls "$HOME/.agents/skills" 2> /dev/null | tr '\n' ' ')"
}

# run_installer LABEL [args]: the real installer in the throwaway home; stdout and stderr to OUT/LABEL.txt
run_installer() {
  _lab=$1
  shift
  sh "$REPO/codex/install-codex.sh" "$@" > "$OUT/$_lab.txt" 2>&1 < /dev/null
  _rc=$?
  res "${_lab}_rc" "$_rc"
  return 0
}

# config_residue LABEL: what the config.toml says about the two servers, and the lines left
config_residue() {
  python3 -I -c '
import sys, tomllib
try:
    d = tomllib.load(open(sys.argv[1], "rb"))
except Exception as exc:
    print("unparsable (%s)" % exc)
    sys.exit(0)
servers = d.get("mcp_servers", {})
print("mcp_servers=%s bbj-docs=%s bbj-local=%s" % (sorted(servers), "bbj-docs" in servers, "bbj-local" in servers))
' "$CODEX_HOME/config.toml" > "$OUT/config-residue-$1.txt" 2>&1
  res "config_after_$1" "$(cat "$OUT/config-residue-$1.txt")"
  res "config_nonblank_lines_$1" "$(awk 'NF' "$CODEX_HOME/config.toml" 2> /dev/null | wc -l | tr -d ' ')"
  res "config_total_lines_$1" "$(awk 'END { print NR }' "$CODEX_HOME/config.toml" 2> /dev/null)"
  cp "$CODEX_HOME/config.toml" "$OUT/config-$1.toml" 2> /dev/null
}

scenario_switch() {
  _order=${ORDER:-a}
  case $_order in
    a | b) ;;
    *) echo "run.sh: ORDER must be a or b" >&2; exit 2 ;;
  esac
  begin "$1"
  res switch_order "$_order"
  res switch_run "$(stamp)"
  res codex_version "$(codex --version)"
  run_installer install
  snap_state installer
  if [ "$_order" = a ]; then
    run_installer remove --remove
    res remove_lines "$(grep -E 'removed|left in place|nothing to remove' "$OUT/remove.txt" | tr '\n' '|')"
    config_residue remove
    snap_state after_remove
    must marketplace_add codex plugin marketplace add "$REPO"
    must plugin_add codex plugin add bbj@basis-bbj
    snap_state plugin
  else
    must marketplace_add codex plugin marketplace add "$REPO"
    must plugin_add codex plugin add bbj@basis-bbj
    snap_state double
    start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
    EXEC_LABEL=double run_exec "$OUT" --dangerously-bypass-hook-trust
    res double_compiler_calls "$(compiler_calls)"
    dash_n_result double_dash_n
    analyze_requests "$OUT" double_
    res double_feedback_occurrences "$(feedback_count "$OUT")"
    run_installer remove --remove
    res remove_lines "$(grep -E 'removed|left in place|nothing to remove' "$OUT/remove.txt" | tr '\n' '|')"
    config_residue remove
    snap_state after_remove
  fi
}

# ---- plan 10-04: real compiler, tier 2, the Git-marketplace upgrade (D-22), Claude Code prep ----

# scrub: stdin to stdout with the throwaway path written <out> and the real home written <home>
scrub() {
  sed -e "s#$OUT#<out>#g" -e "s#$REALHOME#<home>#g"
}

# feedback_header NAME: the first "NAME reported N error(s) in PATH:" line the model received (request
# log) or Codex printed (exec.jsonl), scrubbed; "none" when there is none
feedback_header() {
  _h=$(python3 -I -c '
import re, sys
out, name = sys.argv[1], sys.argv[2]
pat = re.compile(re.escape(name) + r" reported \d+ error\(s\) in [^\s\"\\]+?:")
for fname in ("requests.jsonl", "exec.jsonl"):
    try:
        text = open(out + "/" + fname, errors="replace").read()
    except OSError:
        continue
    found = pat.search(text)
    if found:
        print(found.group(0))
        sys.exit(0)
print("none")
' "$OUT" "$1" | scrub)
  printf '%s\n' "$_h"
}

# installed_hook_root: the cache directory of the installed bbj plugin (the version Codex cached)
installed_hook_root() {
  find "$CODEX_HOME/plugins/cache/basis-bbj/bbj" -mindepth 1 -maxdepth 1 -type d 2> /dev/null | sort | tail -n 1
}

# clean_check KEY: the installed hook command, run directly with a clean apply_patch payload (as the
# Phase 6 evidence did); records "exit 0, silent" or what happened
clean_check() {
  _root=$(installed_hook_root)
  if [ -z "$_root" ] || [ ! -f "$_root/hooks/hooks.json" ]; then
    res "$1" "no installed hook under the plugin cache"
    return 0
  fi
  _cmd=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$_root/hooks/hooks.json" 2> /dev/null)
  if [ -z "$_cmd" ]; then
    res "$1" "no hook command in the installed hooks.json"
    return 0
  fi
  printf 'print "a"; rem ok\n' > "$OUT/proj/clean.bbj"
  # lib.sh resets BBJ_HOME and friends: it runs in a subshell and only prints the payload
  (
    . "$REPO/tests/lib.sh"
    codex_payload "$OUT/proj" "$(printf '%s\n' '*** Begin Patch' '*** Add File: clean.bbj' '+print "a"; rem ok' '*** End Patch')"
  ) > "$OUT/clean-payload.json"
  CLAUDE_PLUGIN_ROOT=$_root sh -c "$_cmd" < "$OUT/clean-payload.json" > "$OUT/clean.out" 2> "$OUT/clean.err"
  _rc=$?
  if [ "$_rc" = 0 ] && [ ! -s "$OUT/clean.out" ] && [ ! -s "$OUT/clean.err" ]; then
    res "$1" "exit 0, silent"
  else
    res "$1" "exit $_rc, stdout $(wc -c < "$OUT/clean.out" | tr -d ' ') bytes, stderr: $(head -n 1 "$OUT/clean.err" | scrub)"
  fi
}

scenario_realcompiler() {
  begin "$1"
  if [ "${TIER2:-}" = 1 ]; then
    # no compiler route at all: the hook asks the live bbj-ls (default URL 127.0.0.1:5009)
    if command -v bbjcpl > /dev/null 2>&1 || command -v bbjcplw > /dev/null 2>&1; then
      echo "run.sh: a BBj compiler is on PATH; the tier 2 run would not be a tier 2 run" >&2
      exit 2
    fi
    unset BBJ_HOME BBJ_LOCAL_MCP_URL
    BBJ_CHECK_DEFAULT_HOMES=
    export BBJ_CHECK_DEFAULT_HOMES
    _name=bbj-local
    _pre=tier2
    _fb=tier2_feedback
  else
    _bh=${REAL_BBJ_HOME:-/opt/bbx}
    if [ ! -x "$_bh/bin/bbjcpl" ]; then
      echo "run.sh: no executable $_bh/bin/bbjcpl (REAL_BBJ_HOME)" >&2
      exit 2
    fi
    BBJ_HOME=$_bh
    export BBJ_HOME
    _name=bbjcpl
    _pre=realcpl
    _fb=realcpl_bad_feedback
  fi
  res route "$_pre"
  res codex_version "$(codex --version)"
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  must marketplace_add codex plugin marketplace add "$REPO"
  must plugin_add codex plugin add bbj@basis-bbj
  res "${_pre}_plugin_version" "$(basename "$(installed_hook_root)")"
  run_exec "$OUT" --dangerously-bypass-hook-trust
  analyze_requests "$OUT"
  _hdr=$(feedback_header "$_name")
  if [ "$_hdr" = none ]; then
    res "$_fb" no
  else
    res "$_fb" yes
  fi
  res "${_pre}_header" "$_hdr"
  if [ -f "$OUT/proj/bad.bbj" ]; then
    res "${_pre}_bad_file_written" yes
  else
    res "${_pre}_bad_file_written" no
  fi
  clean_check "${_pre}_clean"
}

# repo_main_sha: the sha the GitHub main branch points at now (read-only; the real HOME for ssh/https)
repo_main_sha() {
  HOME=$REALHOME GIT_TERMINAL_PROMPT=0 git -C "$REPO" ls-remote origin refs/heads/main 2> /dev/null | awk '{ print $1; exit }'
}

# marketplace_clone: the directory Codex cloned the basis-bbj marketplace into (holds marketplace.json)
marketplace_clone() {
  for _m in $(find "$CODEX_HOME" -path '*/plugins/cache' -prune -o -name marketplace.json -print 2> /dev/null | sort); do
    case $_m in
      */.claude-plugin/marketplace.json) dirname "$(dirname "$_m")"; return 0 ;;
    esac
  done
  return 0
}

# served_version: the version in the cloned marketplace's plugins/bbj/.claude-plugin/plugin.json
served_version() {
  _c=$(marketplace_clone)
  if [ -n "$_c" ] && [ -f "$_c/plugins/bbj/.claude-plugin/plugin.json" ]; then
    python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get("version","?"))' "$_c/plugins/bbj/.claude-plugin/plugin.json"
  else
    echo "no clone found"
  fi
}

# clone_sha: HEAD of the clone Codex made, when it is a git clone
clone_sha() {
  _c=$(marketplace_clone)
  if [ -n "$_c" ] && git -C "$_c" rev-parse HEAD > /dev/null 2>&1; then
    git -C "$_c" rev-parse HEAD
  else
    echo "not a git clone"
  fi
}

# hooks_line: the hooks_list lines of the throwaway CODEX_HOME squeezed into one value
hooks_line() {
  HOME=$REALHOME python3 -I "$HERE/hooks_list.py" "$CODEX_HOME" 2> /dev/null | scrub | tr '\n' '|' | sed 's/|$//'
}

scenario_gitupgrade_before() {
  begin "$1"
  GIT_TERMINAL_PROMPT=0
  export GIT_TERMINAL_PROMPT
  write_fake_config
  git init -q "$OUT/proj"
  res gitupgrade_before_run "$(stamp)"
  res codex_version "$(codex --version)"
  res gu_main_sha "$(repo_main_sha)"
  timeout 90 codex plugin marketplace add BBj-AI/bbj-agent-plugins > "$OUT/mp-add.txt" 2>&1 < /dev/null
  res gu_marketplace_add_rc "$?"
  res gu_marketplace_add_line "$(grep -m 1 -v '^[[:space:]]*$' "$OUT/mp-add.txt" | scrub)"
  res gu_served_version "$(served_version)"
  res gu_clone_sha "$(clone_sha)"
  codex plugin add bbj@basis-bbj > "$OUT/plugin-add.txt" 2>&1 < /dev/null
  res gu_plugin_add_rc "$?"
  res gu_cache_versions "$(ls "$CODEX_HOME/plugins/cache/basis-bbj/bbj" 2> /dev/null | tr '\n' ' ')"
  res gu_mcp_docs "$(mcp_line bbj-docs)"
  res gu_skills "$(skill_names)"
  res gu_hooks "$(hooks_line)"
  hooks_read before
}

# the after half runs in plan 10-11, in the home the owner trusted in; keep mode, nothing is deleted
scenario_gitupgrade_after() {
  in_place_home "$1"
  GIT_TERMINAL_PROMPT=0
  export GIT_TERMINAL_PROMPT
  res gitupgrade_after_run "$(stamp)"
  res gu_after_main_sha "$(repo_main_sha)"
  res gu_before_cache_versions "$(ls "$CODEX_HOME/plugins/cache/basis-bbj/bbj" 2> /dev/null | tr '\n' ' ')"
  hooks_read gu_before_upgrade
  timeout 90 codex plugin marketplace upgrade basis-bbj > "$OUT/gu-upgrade.txt" 2>&1 < /dev/null
  res gu_after_upgrade_rc "$?"
  res gu_after_upgrade_line "$(grep -m 1 -v '^[[:space:]]*$' "$OUT/gu-upgrade.txt" | scrub)"
  res gu_after_served_version "$(served_version)"
  res gu_after_clone_sha "$(clone_sha)"
  res gu_after_upgrade_cache_versions "$(ls "$CODEX_HOME/plugins/cache/basis-bbj/bbj" 2> /dev/null | tr '\n' ' ')"
  codex plugin add bbj@basis-bbj > "$OUT/gu-add.txt" 2>&1 < /dev/null
  res gu_after_add_rc "$?"
  res gu_after_add_line "$(grep -m 1 -v '^[[:space:]]*$' "$OUT/gu-add.txt" | scrub)"
  res gu_after_cache_versions "$(ls "$CODEX_HOME/plugins/cache/basis-bbj/bbj" 2> /dev/null | tr '\n' ' ')"
  res gu_after_mcp_docs "$(mcp_line bbj-docs)"
  res gu_after_skills "$(skill_names)"
  res gu_after_hooks "$(hooks_line)"
  hooks_read gu_after
}

scenario_gitupgrade_posttrust() {
  in_place_home "$1"
  res gu_posttrust_run "$(stamp)"
  hooks_read gu_posttrust_before
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  # no bypass flag: the hook runs only if the trust state allows it
  EXEC_LABEL=gu_posttrust run_exec "$OUT"
  res gu_posttrust_compiler_calls "$(compiler_calls)"
  analyze_requests "$OUT" gu_posttrust_
  _hdr=$(feedback_header bbjcpl)
  if [ "$_hdr" = none ]; then
    res gu_posttrust_feedback no
  else
    res gu_posttrust_feedback yes
  fi
  res gu_posttrust_header "$_hdr"
  res gu_posttrust_bypass_flag_in_cmd "$(grep -c 'dangerously-bypass-hook-trust' "$OUT/exec-gu_posttrust.cmd")"
  res gu_posttrust_hooks "$(hooks_line)"
  hooks_read gu_posttrust_after
}

scenario_fromgit() {
  begin "$1"
  GIT_TERMINAL_PROMPT=0
  export GIT_TERMINAL_PROMPT
  res fromgit_run "$(stamp)"
  res codex_version "$(codex --version)"
  res fg_main_sha "$(repo_main_sha)"
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  timeout 90 codex plugin marketplace add BBj-AI/bbj-agent-plugins > "$OUT/mp-add.txt" 2>&1 < /dev/null
  res fg_marketplace_add_rc "$?"
  res fg_served_version "$(served_version)"
  res fg_clone_sha "$(clone_sha)"
  must plugin_add codex plugin add bbj@basis-bbj
  res fg_mcp_docs "$(mcp_line bbj-docs)"
  res fg_skills "$(skill_names)"
  res fg_hooks "$(hooks_line)"
  run_exec "$OUT" --dangerously-bypass-hook-trust
  res fg_compiler_calls "$(compiler_calls)"
  _hdr=$(feedback_header bbjcpl)
  if [ "$_hdr" = none ]; then
    res fg_bad_feedback no
  else
    res fg_bad_feedback yes
  fi
  res fg_header "$_hdr"
}

# cc ARGS...: claude with the throwaway configuration directory, for this call only. The session
# variables of a parent Claude Code are removed so the child behaves as a fresh CLI.
cc() {
  env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID \
    CLAUDE_CONFIG_DIR="$OUT/cfg" CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1 claude "$@"
}

# cc_plugin_state NAME: "enabled" or "disabled" for NAME@basis-bbj in `claude plugin list`
cc_plugin_state() {
  cc plugin list 2> /dev/null | awk -v n="$1@basis-bbj" '
    index($0, n) { found = 1; next }
    found && /enabled|disabled/ { if ($0 ~ /disabled/) print "disabled"; else print "enabled"; exit }
    found && /@/ { exit }'
}

scenario_ccprep() {
  begin "$1"
  mkdir -p "$OUT/cfg"
  git init -q "$OUT/proj"
  res cc_run "$(stamp)"
  res cc_version "$(claude --version)"
  must cc_marketplace_add cc plugin marketplace add "$REPO"
  must cc_install_bbj cc plugin install bbj@basis-bbj
  must cc_install_bbj_local cc plugin install bbj-local@basis-bbj
  res cc_bbj "$(cc_plugin_state bbj)"
  res cc_bbj_local "$(cc_plugin_state bbj-local)"
}

case ${1:-} in
  selftest) scenario_selftest ;;
  realhome) scenario_realhome "${2:-}" ;;
  envprobe | plugin | local | shorthand | prepare-trust | prepare-signin | posttrust | upgrade | switch | realcompiler | gitupgrade-before | gitupgrade-after | gitupgrade-posttrust | fromgit | ccprep)
    [ -n "${2:-}" ] || { echo "run.sh: $1 needs an OUTDIR" >&2; exit 2; }
    case $1 in
      envprobe) scenario_envprobe "$2" ;;
      plugin) scenario_plugin "$2" ;;
      local) scenario_local "$2" ;;
      shorthand) scenario_shorthand "$2" ;;
      prepare-trust) scenario_prepare_trust "$2" ;;
      prepare-signin) scenario_prepare_signin "$2" ;;
      posttrust) scenario_posttrust "$2" ;;
      upgrade) scenario_upgrade "$2" ;;
      switch) scenario_switch "$2" ;;
      realcompiler) scenario_realcompiler "$2" ;;
      gitupgrade-before) scenario_gitupgrade_before "$2" ;;
      gitupgrade-after) scenario_gitupgrade_after "$2" ;;
      gitupgrade-posttrust) scenario_gitupgrade_posttrust "$2" ;;
      fromgit) scenario_fromgit "$2" ;;
      ccprep) scenario_ccprep "$2" ;;
    esac ;;
  *)
    echo "usage: sh run.sh selftest | realhome FILE | envprobe|plugin|local|shorthand|prepare-trust|prepare-signin|posttrust|upgrade|switch|realcompiler|gitupgrade-before|gitupgrade-after|gitupgrade-posttrust|fromgit|ccprep OUTDIR" >&2
    exit 2 ;;
esac
