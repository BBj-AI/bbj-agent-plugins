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
#   codex_payload CWD PATCH_TEXT    prints a Codex PostToolUse payload for apply_patch (shape from
#                                   the Codex hooks documentation, not yet captured on a Codex
#                                   machine: tool_input.command holds the patch text)
#   run_check PAYLOAD   runs the hook script with PAYLOAD on stdin; sets RC, and the files
#                       $WORK/stdout and $WORK/stderr (SHELL_UNDER_TEST, default sh)
#
# Hermetic defaults (exported here): the built-in default homes are replaced by an empty
# list, no BBj environment variable is set, and the loopback check URL is a closed port,
# so no test reaches a real BBj or a real bbj-ls unless it opts in explicitly.

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
  printf '%s' '{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"'"$_cwd"'","prompt_id":"p1","permission_mode":"acceptEdits","effort":"low","hook_event_name":"PostToolUse","tool_name":"'"$_tool"'","tool_input":'"$_input"',"tool_response":'"$_resp"'}'
}

codex_payload() {
  # codex_payload CWD PATCH_TEXT
  _cwd=$(json_escape "$1")
  _patch=$(json_escape "$2")
  printf '%s' '{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"'"$_cwd"'","hook_event_name":"PostToolUse","tool_name":"apply_patch","tool_input":{"command":"'"$_patch"'"},"tool_response":"Success"}'
}

run_check() {
  printf '%s' "$1" > "$WORK/payload"
  $SHELL_UNDER_TEST "$SCRIPT" < "$WORK/payload" > "$WORK/stdout" 2> "$WORK/stderr"
  # shellcheck disable=SC2034  # RC is read by the test that sourced this file
  RC=$?
}
