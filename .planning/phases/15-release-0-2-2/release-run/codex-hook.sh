#!/bin/sh
# .planning/phases/15-release-0-2-2/release-run/codex-hook.sh -- plan 15-02 (REL-10; D-07, D-10): the
# Codex hook reading of the release run, taken from a tree or from the GitHub source, in a throwaway
# Codex home. Scenarios and helpers are copied from the Phase 10 Codex harness (.planning/milestones/
# v0.2.1-phases/10-install-wording-and-release-0-2-1/codex-run/run.sh, scenario realcompiler) at the
# phase-directory depth; nothing that read a file Phase 11 removed is copied. Evidence for the phase
# record, never CI: CI has no Codex, and nothing here is a gate.
#
# Safety rules (threats T-15-03, T-15-04 and T-15-30):
#   - never runs BBj: the compiler is reached only through the installed hook, which calls bbjcpl
#     with -N (compile-only); the real compiler is BBJ_HOME=${REAL_BBJ_HOME:-/opt/bbx}, refused
#     (exit 2) when its bin/bbjcpl is not executable; BBJ_LOCAL_MCP_URL stays on the closed port 9, so
#     only the bbjcpl route can answer;
#   - never touches the real ~/.codex, ~/.agents or ~/.claude: safe_out refuses any OUTDIR outside
#     $HOME/.cache/bbj-phase15/ (and anything under /tmp, the real ~/.codex, ~/.agents or ~/.claude, a
#     path with .., or a relative path); setup_env points HOME and CODEX_HOME into OUTDIR;
#   - never under /tmp (Codex refuses its helper binaries there);
#   - no billed model: the exec uses spike 001's loopback fake Responses server
#     (model_provider=fake, requires_openai_auth=false, model slug gpt-5.5);
#   - the trust bypass flag appears in the throwaway home only: codex exec shows no /hooks prompt, so
#     these readings skip the /hooks trust step and claim nothing about it; every result says so with
#     hk_trust: bypassed;
#   - every value that reaches result.txt goes through scrub (the run directory, a tree SOURCE and the
#     home become <out>, <tree> and <home>); no authorization URL, state, PKCE value or token is read.
#
# Usage: sh codex-hook.sh SCENARIO [SOURCE OUTDIR]
#   selftest              prove safe_out refuses /tmp, ~/.codex, ~/.agents, ~/.claude, ~/elsewhere,
#                         <base>/../x and a relative path
#   hook SOURCE OUTDIR    fresh Codex home; the plugin from SOURCE (an absolute tree path, or the GitHub
#                         source BBj-AI/bbj-agent-plugins); the docs server as Codex lists it; the fake
#                         model adds a bad .bbj through apply_patch and the real hook gets bbjcpl
#                         feedback; a clean payload run directly is silent
# Output: OUTDIR/result.txt (key: value lines, keys hk_*) and raw files beside it; not committed.
# Exit codes: 0 the scenario ran to the end, 1 a Codex command failed (its last line is in
# result.txt), 2 a refused OUTDIR or SOURCE, a missing compiler or a usage error.

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
SPIKE001=$REPO/.planning/spikes/001-codex-plugin-hooks
REALHOME=$HOME
BASE=$REALHOME/.cache/bbj-phase15
PORT=${PORT:-18765}
SOURCE=
OUT=
SRV=

# refuse DIR WHY: exit 2 with the fixed message
refuse() {
  echo "codex-hook.sh: refused $1 ($2)" >&2
  exit 2
}

# safe_out DIR: the absolute path must be below $HOME/.cache/bbj-phase15/; then it is recreated.
# The rm -rf runs after every check, inside the approved prefix only.
safe_out() {
  case $1 in
    /*) ;;
    *) refuse "OUTDIR $1" "not an absolute path" ;;
  esac
  case $1 in
    /tmp | /tmp/*) refuse "OUTDIR $1" "under /tmp" ;;
    "$REALHOME"/.codex | "$REALHOME"/.codex/*) refuse "OUTDIR $1" "under the real ~/.codex" ;;
    "$REALHOME"/.agents | "$REALHOME"/.agents/*) refuse "OUTDIR $1" "under the real ~/.agents" ;;
    "$REALHOME"/.claude | "$REALHOME"/.claude/*) refuse "OUTDIR $1" "under the real ~/.claude" ;;
    */.. | */../*) refuse "OUTDIR $1" "contains .." ;;
  esac
  case $1 in
    "$BASE"/?*) ;;
    *) refuse "OUTDIR $1" "outside $BASE/" ;;
  esac
  rm -rf "$1" && mkdir -p "$1"
}

# scrub TEXT: print TEXT with the run directory, a tree SOURCE and the home directory replaced by
# <out>, <tree> and <home> (in that order, as fixed strings: index/substr, never a regex)
scrub() {
  S_TEXT=$1 S_OUT=$OUT S_TREE=$SOURCE_TREE S_HOME=$REALHOME awk '
    function rep(s, from, to,    done, i) {
      if (from == "") return s
      done = ""
      while ((i = index(s, from)) > 0) {
        done = done substr(s, 1, i - 1) to
        s = substr(s, i + length(from))
      }
      return done s
    }
    BEGIN {
      t = ENVIRON["S_TEXT"]
      t = rep(t, ENVIRON["S_OUT"], "<out>")
      t = rep(t, ENVIRON["S_TREE"], "<tree>")
      t = rep(t, ENVIRON["S_HOME"], "<home>")
      print t
    }'
}

# res KEY VALUE: one evidence line in OUT/result.txt; the value is scrubbed and kept on one line
res() {
  _v=$(scrub "$2" | tr '\n' ' ' | sed 's/ *$//')
  printf '%s: %s\n' "$1" "$_v" >> "$OUT/result.txt"
}

# stamp: UTC time for the result lines
stamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# setup_env OUT: throwaway HOME and CODEX_HOME, the real compiler and the hermetic hook environment
setup_env() {
  mkdir -p "$1/home/.codex" "$1/proj" "$1/state"
  HOME=$1/home
  CODEX_HOME=$1/home/.codex
  export HOME CODEX_HOME
  BBJ_HOME=$REAL_HOME_BBJ
  BBJ_CHECK_DEFAULT_HOMES=
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
  BBJ_CHECK_STATE_DIR=$1/state
  export BBJ_HOME BBJ_CHECK_DEFAULT_HOMES BBJ_LOCAL_MCP_URL BBJ_CHECK_STATE_DIR
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
    set -- exec --skip-git-repo-check --json \
      -c model_provider=fake -c model=gpt-5.5 \
      -c 'model_providers.fake.name="fake"' \
      -c "model_providers.fake.base_url=\"http://127.0.0.1:$PORT/v1\"" \
      -c 'model_providers.fake.wire_api="responses"' \
      -c 'model_providers.fake.requires_openai_auth=false' \
      --sandbox danger-full-access "$@" "add bad.bbj"
    timeout 120 codex "$@" < /dev/null > "$_o/exec.jsonl" 2> "$_o/exec.err"
    echo "$?" > "$_o/exec.rc"
  )
  res hk_exec_rc "$(cat "$_o/exec.rc" 2> /dev/null)"
}

# must LABEL CMD...: run a Codex command; on failure record its last output line and exit 1
must() {
  _l=$1
  shift
  if "$@" >> "$OUT/setup.txt" 2>&1 < /dev/null; then
    return 0
  fi
  res "${_l}_error" "$(tail -n 1 "$OUT/setup.txt")"
  res status "failed at $_l"
  exit 1
}

# mcp_line NAME: the whole `codex mcp list` line for server NAME with runs of spaces squeezed
mcp_line() {
  codex mcp list 2> /dev/null | awk -v n="$1" '$1 == n { $1 = $1; print; exit }'
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

# analyze_requests OUT PREFIX: evidence lines from the fake server's request log, keys prefixed
# with PREFIX. Only POST bodies after the first are searched: hook feedback reaches the model in a
# later request.
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
' "$1/requests.jsonl" "$2" >> "$1/result.txt"
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
' "$OUT" "$1")
  scrub "$_h"
}

# installed_hook_root: the cache directory of the installed bbj plugin (the version Codex cached)
installed_hook_root() {
  find "$CODEX_HOME/plugins/cache/basis-bbj/bbj" -mindepth 1 -maxdepth 1 -type d 2> /dev/null | sort | tail -n 1
}

# clean_check KEY: the installed hook command, run directly with a clean apply_patch payload; records
# "exit 0, silent" or what happened
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
    res "$1" "exit $_rc, stdout $(wc -c < "$OUT/clean.out" | tr -d ' ') bytes, stderr: $(head -n 1 "$OUT/clean.err")"
  fi
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

# check_source SOURCE: an absolute tree path (not under /tmp, holding .claude-plugin/marketplace.json)
# or the GitHub source BBj-AI/bbj-agent-plugins; anything else is refused with exit 2. Sets SOURCE_TREE
# to the path for a tree and to nothing for the GitHub source.
check_source() {
  SOURCE_TREE=
  case $1 in
    '') refuse "SOURCE" "empty" ;;
    BBj-AI/bbj-agent-plugins) return 0 ;;
    /tmp | /tmp/*) refuse "SOURCE $1" "under /tmp" ;;
    */.. | */../*) refuse "SOURCE $1" "contains .." ;;
    /*)
      [ -f "$1/.claude-plugin/marketplace.json" ] || refuse "SOURCE $1" "no .claude-plugin/marketplace.json"
      git -C "$1" rev-parse --is-inside-work-tree > /dev/null 2>&1 || refuse "SOURCE $1" "not a git work tree"
      SOURCE_TREE=$1 ;;
    *) refuse "SOURCE $1" "neither an absolute tree path nor BBj-AI/bbj-agent-plugins" ;;
  esac
}

scenario_selftest() {
  _n=0
  (safe_out /tmp/bbj-phase15-selftest) 2> /dev/null && _n=1
  (safe_out "$REALHOME/.codex/x") 2> /dev/null && _n=1
  (safe_out "$REALHOME/.agents/x") 2> /dev/null && _n=1
  (safe_out "$REALHOME/.claude/x") 2> /dev/null && _n=1
  (safe_out "$REALHOME/elsewhere") 2> /dev/null && _n=1
  (safe_out "$BASE/../x") 2> /dev/null && _n=1
  (safe_out "relative") 2> /dev/null && _n=1
  (check_source "/tmp/x") 2> /dev/null && _n=1
  (check_source "relative/tree") 2> /dev/null && _n=1
  (check_source "") 2> /dev/null && _n=1
  if [ "$_n" = 0 ]; then
    echo "selftest ok"
    return 0
  fi
  echo "selftest FAIL: a refused path was accepted" >&2
  return 1
}

scenario_hook() {
  SOURCE=$1
  check_source "$SOURCE"
  REAL_HOME_BBJ=${REAL_BBJ_HOME:-/opt/bbx}
  if [ ! -x "$REAL_HOME_BBJ/bin/bbjcpl" ]; then
    echo "codex-hook.sh: no executable $REAL_HOME_BBJ/bin/bbjcpl (REAL_BBJ_HOME)" >&2
    exit 2
  fi
  begin "$2"
  GIT_TERMINAL_PROMPT=0
  export GIT_TERMINAL_PROMPT
  res hk_run "$(stamp)"
  res hk_source "$SOURCE"
  res hk_codex_version "$(codex --version)"
  if [ -n "$SOURCE_TREE" ]; then
    res hk_tree_head "$(git -C "$SOURCE_TREE" rev-parse HEAD)"
    res hk_tree "$(git -C "$SOURCE_TREE" rev-parse 'HEAD^{tree}')"
  fi
  start_fake "$OUT" || { res status "fake server did not start"; exit 1; }
  must marketplace_add timeout 90 codex plugin marketplace add "$SOURCE"
  if [ -z "$SOURCE_TREE" ]; then
    res hk_served_version "$(served_version)"
    res hk_clone_sha "$(clone_sha)"
  fi
  must plugin_add codex plugin add bbj@basis-bbj
  res hk_plugin_version "$(basename "$(installed_hook_root)")"
  _line=$(mcp_line bbj)
  res hk_mcp_docs "${_line:-dropped}"
  res hk_skills "$(skill_names)"
  # the one place a hook runs without the owner's trust: codex exec in this throwaway home
  run_exec "$OUT" --dangerously-bypass-hook-trust
  res hk_trust "bypassed (codex exec --dangerously-bypass-hook-trust, throwaway home)"
  analyze_requests "$OUT" hk_
  _hdr=$(feedback_header bbjcpl)
  if [ "$_hdr" = none ]; then
    res hk_bad_feedback no
  else
    res hk_bad_feedback yes
  fi
  res hk_header "$_hdr"
  if [ -f "$OUT/proj/bad.bbj" ]; then
    res hk_bad_file_written yes
  else
    res hk_bad_file_written no
  fi
  clean_check hk_clean
  res hk_done yes
}

SOURCE_TREE=
REAL_HOME_BBJ=
case ${1:-} in
  selftest) scenario_selftest ;;
  hook)
    [ -n "${2:-}" ] && [ -n "${3:-}" ] || { echo "codex-hook.sh: hook needs SOURCE and OUTDIR" >&2; exit 2; }
    scenario_hook "$2" "$3" ;;
  *)
    echo "usage: sh codex-hook.sh selftest | hook SOURCE OUTDIR" >&2
    exit 2 ;;
esac
