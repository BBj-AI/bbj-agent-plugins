# tests/lib.sh -- shared helpers, sourced (". tests/lib.sh") by every sh test.
#
# Plan 19-01 conventions. Nothing in tests/ executes BBj code: the real-compiler test
# calls bbjcpl with -N (a compile-only check), every other test uses fake binaries.
#
# Provides:
#   REPO, SCRIPT        repo root (from the sourcing test's own location) and the hook script
#   gate NAME ok|FAIL|skip DETAIL   prints "gate NAME STATUS DETAIL", records failures
#   finish              exits 1 when any gate failed, else 0
#   mkwork              creates WORK (a temp dir) and removes it on exit
#   claude_payload TOOL FILE CWD    prints a Claude Code PostToolUse payload in the verified
#                                   key order, with JSON-escaped values
#   codex_payload CWD PATCH_TEXT    prints a Codex PostToolUse payload for apply_patch in the
#                                   top-level key order captured from Codex CLI codex-cli 0.162.1
#                                   (plan 02-05, evidence/codex/payload.jsonl): tool_input.command
#                                   holds the patch text, transcript_path is null, tool_response is
#                                   a plain string; turn_id, model, permission_mode and tool_use_id
#                                   carry synthetic values
#   run_check PAYLOAD   runs the hook script with PAYLOAD on stdin; sets RC, and the files
#                       $WORK/stdout and $WORK/stderr (SHELL_UNDER_TEST, default sh)
#   fresh_state         points BBJ_CHECK_STATE_DIR at a new empty directory (phase 2, plan 02-01),
#                       so the next no-route call is the first of its session again
#   notice_text FILE    prints the additionalContext of the no-route notice held in FILE and
#                       returns 0 only when FILE is exactly the one-line object
#                       {"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":..}}
#                       (1 otherwise, 2 without python3)
#   SESSION_ID          the session_id of both payload builders (default s1)
#   no_compiler_path [PATHVALUE]   prints PATHVALUE (default PATH) without any directory that
#                       holds a BBj compiler (MAINT-06, D-11); only for no-route tests
#   no_compiler_env     unsets BBJ_HOME, BBJHOME and CLAUDE_PLUGIN_OPTION_BBJ_HOME and sets
#                       BBJ_CHECK_DEFAULT_HOMES empty, in the calling shell (MAINT-06, D-11)
#
# Hermetic defaults (exported here): the built-in default homes are replaced by an empty
# list, no BBj environment variable is set, and the loopback check URL is a closed port,
# so no test reaches a real BBj or a real bbj-ls unless it opts in explicitly. mkwork also
# points BBJ_CHECK_STATE_DIR at $WORK/state (HOOK-02, D-18), so the once-per-session marker
# of the no-route notice never reaches the real temp directory.

REPO=$(cd "$(dirname "$0")/.." && pwd)
SCRIPT=${SCRIPT:-$REPO/plugins/bbj/scripts/bbj-check.sh}
SHELL_UNDER_TEST=${SHELL_UNDER_TEST:-sh}

BBJ_CHECK_DEFAULT_HOMES=
export BBJ_CHECK_DEFAULT_HOMES
unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME CLAUDE_PROJECT_DIR
BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
export BBJ_LOCAL_MCP_URL

LIB_FAILED=0

gate() {
  # gate NAME STATUS DETAIL
  case "$2" in
    ok) echo "gate $1 ok $3" ;;
    skip) echo "gate $1 skip $3" ;;
    *) echo "gate $1 FAIL $3"; LIB_FAILED=1 ;;
  esac
}

finish() {
  [ "$LIB_FAILED" = 0 ] && exit 0
  exit 1
}

mkwork() {
  WORK=$(mktemp -d "${TMPDIR:-/tmp}/bbjplug.XXXXXX") || { echo "gate mkwork FAIL cannot create a temp dir"; exit 1; }
  trap 'rm -rf "$WORK"' EXIT
  trap 'exit 1' INT TERM HUP
  BBJ_CHECK_STATE_DIR=$WORK/state
  mkdir "$BBJ_CHECK_STATE_DIR" || { echo "gate mkwork FAIL cannot create the state dir"; exit 1; }
  export BBJ_CHECK_STATE_DIR
}

# fresh_state: BBJ_CHECK_STATE_DIR becomes a new empty directory ($WORK/state.N).
STATE_N=0
fresh_state() {
  STATE_N=$((STATE_N + 1))
  BBJ_CHECK_STATE_DIR=$WORK/state.$STATE_N
  mkdir "$BBJ_CHECK_STATE_DIR" || { echo "gate fresh_state FAIL cannot create $BBJ_CHECK_STATE_DIR"; exit 1; }
  export BBJ_CHECK_STATE_DIR
}

# notice_text FILE: prints the additionalContext when FILE is exactly one newline-terminated
# line holding the no-route object (keys and their order as the hosts' schemas expect them,
# valid UTF-8, valid JSON); returns 0 then, 1 for anything else, 2 without python3.
notice_text() {
  command -v python3 > /dev/null 2>&1 || return 2
  python3 -I -c '
import json, sys
data = open(sys.argv[1], "rb").read()
if not data.endswith(b"\n") or data.count(b"\n") != 1:
    sys.exit(1)
try:
    obj = json.loads(data[:-1].decode("utf-8"))
except ValueError:
    sys.exit(1)
if not isinstance(obj, dict) or list(obj) != ["hookSpecificOutput"]:
    sys.exit(1)
inner = obj["hookSpecificOutput"]
if not isinstance(inner, dict) or list(inner) != ["hookEventName", "additionalContext"]:
    sys.exit(1)
if inner["hookEventName"] != "PostToolUse" or not isinstance(inner["additionalContext"], str):
    sys.exit(1)
sys.stdout.write(inner["additionalContext"] + "\n")
' "$1"
}

# json_escape VALUE: the JSON string body for VALUE (backslash, quote, tab, CR, newline).
json_escape() {
  _tab=$(printf '\t')
  _cr=$(printf '\r')
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$_tab/\\\\t/g" -e "s/$_cr/\\\\r/g" \
    | awk 'NR > 1 { printf "\\n" } { printf "%s", $0 }'
}

claude_payload() {
  # claude_payload TOOL FILE CWD  (key order as captured from Claude Code 2.1.294)
  _tool=$1
  _file=$(json_escape "$2")
  _cwd=$(json_escape "$3")
  case "$_tool" in
    Edit)
      _input='{"file_path":"'"$_file"'","old_string":"a","new_string":"b","replace_all":false}'
      _resp='{"filePath":"'"$_file"'","oldString":"a","newString":"b"}'
      ;;
    *)
      _input='{"file_path":"'"$_file"'","content":"print \"a\"\n"}'
      _resp='{"type":"create","filePath":"'"$_file"'","content":"print \"a\"\n"}'
      ;;
  esac
  printf '%s' '{"session_id":"'"$(json_escape "${SESSION_ID:-s1}")"'","transcript_path":"/tmp/t.jsonl","cwd":"'"$_cwd"'","prompt_id":"p1","permission_mode":"acceptEdits","effort":"low","hook_event_name":"PostToolUse","tool_name":"'"$_tool"'","tool_input":'"$_input"',"tool_response":'"$_resp"'}'
}

codex_payload() {
  # codex_payload CWD PATCH_TEXT  (key order as captured from Codex CLI codex-cli 0.162.1, plan 02-05)
  _cwd=$(json_escape "$1")
  _patch=$(json_escape "$2")
  printf '%s' '{"session_id":"'"$(json_escape "${SESSION_ID:-s1}")"'","turn_id":"t1","transcript_path":null,"cwd":"'"$_cwd"'","hook_event_name":"PostToolUse","model":"m1","permission_mode":"bypassPermissions","tool_name":"apply_patch","tool_input":{"command":"'"$_patch"'"},"tool_response":"Exit code: 0\nWall time: 0 seconds\nOutput:\nSuccess. Updated the following files:\n","tool_use_id":"u1"}'
}

run_check() {
  printf '%s' "$1" > "$WORK/payload"
  $SHELL_UNDER_TEST "$SCRIPT" < "$WORK/payload" > "$WORK/stdout" 2> "$WORK/stderr"
  # shellcheck disable=SC2034  # RC is read by the test that sourced this file
  RC=$?
}

# no_compiler_path [PATHVALUE]: prints PATHVALUE (default PATH) with every directory that holds
# bbjcpl, bbjcpl.exe, bbjcplw or bbjcplw.exe (the names the hook can find) replaced by a symlink
# farm under $WORK that links all of that directory's other entries, so sh, awk, curl and the
# like stay reachable. Without WORK the directory is dropped. Clean directories keep their place
# and text, empty entries are dropped, and the caller's IFS and noglob state are unchanged.
# Always call it as PATH=$(no_compiler_path ...); only no-route tests use it (MAINT-06, D-11, D-12).
no_compiler_path() {
  _ncp_in=${1-$PATH}
  _ncp_ifs=$IFS
  case "$-" in *f*) _ncp_noglob=1 ;; *) _ncp_noglob=0 ;; esac
  _ncp_out=
  set -f
  IFS=:
  for _ncp_d in $_ncp_in; do
    [ -n "$_ncp_d" ] || continue
    _ncp_has=0
    for _ncp_n in bbjcpl bbjcpl.exe bbjcplw bbjcplw.exe; do
      if [ -e "$_ncp_d/$_ncp_n" ] || [ -L "$_ncp_d/$_ncp_n" ]; then _ncp_has=1; fi
    done
    if [ "$_ncp_has" = 0 ]; then
      _ncp_out=${_ncp_out:+$_ncp_out:}$_ncp_d
      continue
    fi
    [ -n "${WORK:-}" ] || continue
    _ncp_abs=$(cd "$_ncp_d" 2> /dev/null && pwd) || continue
    _ncp_farm=$(mktemp -d "$WORK/pathfarm.XXXXXX" 2> /dev/null) || continue
    IFS=$_ncp_ifs
    set +f
    for _ncp_e in "$_ncp_abs"/* "$_ncp_abs"/.[!.]*; do
      [ -e "$_ncp_e" ] || [ -L "$_ncp_e" ] || continue
      ln -s "$_ncp_e" "$_ncp_farm/${_ncp_e##*/}" 2> /dev/null
    done
    set -f
    IFS=:
    rm -f "$_ncp_farm/bbjcpl" "$_ncp_farm/bbjcpl.exe" "$_ncp_farm/bbjcplw" "$_ncp_farm/bbjcplw.exe"
    _ncp_out=${_ncp_out:+$_ncp_out:}$_ncp_farm
  done
  IFS=$_ncp_ifs
  [ "$_ncp_noglob" = 1 ] || set +f
  printf '%s' "$_ncp_out"
}

# no_compiler_env: the other discovery sources of the hook, cleared for a no-route test (MAINT-06,
# D-11). Call it directly, never inside a command substitution: a subshell loses the change.
no_compiler_env() {
  unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME
  BBJ_CHECK_DEFAULT_HOMES=
  export BBJ_CHECK_DEFAULT_HOMES
}
