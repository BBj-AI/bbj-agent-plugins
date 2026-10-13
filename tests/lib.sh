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
#   home_snapshot CODEXHOME SKILLSDIR   prints a sorted content snapshot of the paths the Codex
#                       installer can write, with its temp files and parent dirs (MAINT-07, D-08,
#                       D-09): one line per entry, a kind and a path, never a time
#   home_diff BEFORE AFTER   returns 0 when two snapshot files are identical; otherwise prints at
#                       most three changed lines and returns 1 (MAINT-07, D-10)
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
# Always call it in a command substitution; only no-route tests use it (MAINT-06, D-11, D-12). If a
# farm cannot be built (cd, mktemp or ln -s fails) it prints why on stderr, prints nothing on
# stdout and returns 1, so the caller must check: _np=$(no_compiler_path) || { gate ... FAIL; finish; }
# and only then PATH=$_np. An empty PATH would otherwise make a no-route gate pass on a dead hook.
no_compiler_path() {
  _ncp_in=${1-$PATH}
  # an unset IFS stays unset: it is restored by unset, not by an assignment of the default value
  if [ "${IFS+set}" = set ]; then
    _ncp_ifs=$IFS
    _ncp_ifs_was_set=1
  else
    _ncp_ifs=$(printf ' \t\nx')
    _ncp_ifs=${_ncp_ifs%x}
    _ncp_ifs_was_set=0
  fi
  case "$-" in *f*) _ncp_noglob=1 ;; *) _ncp_noglob=0 ;; esac
  _ncp_out=
  _ncp_rc=0
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
    # a farm that cannot be built must not turn into a PATH without sh, awk or curl: no-route
    # gates that assert silence would pass on a hook that cannot run at all. Fail loudly instead.
    _ncp_abs=$(cd "$_ncp_d" 2> /dev/null && pwd) || { _ncp_rc=1; break; }
    _ncp_farm=$(mktemp -d "$WORK/pathfarm.XXXXXX" 2> /dev/null) || { _ncp_rc=1; break; }
    IFS=$_ncp_ifs
    set +f
    for _ncp_e in "$_ncp_abs"/* "$_ncp_abs"/.[!.]* "$_ncp_abs"/..?*; do
      [ -e "$_ncp_e" ] || [ -L "$_ncp_e" ] || continue
      ln -s "$_ncp_e" "$_ncp_farm/${_ncp_e##*/}" 2> /dev/null || { _ncp_rc=1; break; }
    done
    set -f
    IFS=:
    [ "$_ncp_rc" = 0 ] || break
    rm -f "$_ncp_farm/bbjcpl" "$_ncp_farm/bbjcpl.exe" "$_ncp_farm/bbjcplw" "$_ncp_farm/bbjcplw.exe"
    _ncp_out=${_ncp_out:+$_ncp_out:}$_ncp_farm
  done
  IFS=$_ncp_ifs
  [ "$_ncp_ifs_was_set" = 1 ] || unset IFS
  [ "$_ncp_noglob" = 1 ] || set +f
  if [ "$_ncp_rc" != 0 ]; then
    printf 'no_compiler_path: cannot build a tool farm for %s under %s (cd, mktemp or ln -s failed)\n' \
      "$_ncp_d" "${WORK:-}" >&2
    return 1
  fi
  printf '%s' "$_ncp_out"
}

# no_compiler_env: the other discovery sources of the hook, cleared for a no-route test (MAINT-06,
# D-11). Call it directly, never inside a command substitution: a subshell loses the change.
no_compiler_env() {
  unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME
  BBJ_CHECK_DEFAULT_HOMES=
  export BBJ_CHECK_DEFAULT_HOMES
}

# home_snapshot CODEXHOME SKILLSDIR: one line per entry under the paths the Codex installer can
# write, sorted with LC_ALL=C (MAINT-07, D-08, D-09, D-10):
#   F <mode> <crc> <size> <path>   regular file (permission string and cksum of the content, never a time)
#   T <crc> <size> <path>   content behind a symlink to a regular file (WR-01: a write through the link)
#   D <path>   directory    L <path> -> <target>   symlink    U <path>   unreadable file
#   O <path>   other (FIFO, socket, device; never opened)    - <path>   absent
#   E <path>   find failed below this watched path (an unreadable directory); the walk is incomplete
#   H <path> present|absent   the Codex home and the skills dir themselves (the installer mkdir -p's both)
# Content, never mtime (D-09): a touch changes nothing, an edited, added or removed file does. Only
# the paths below are read, so daemon files (logs_*.sqlite*, state_*.sqlite, history.jsonl,
# sessions/, log/, tmp/) and credential files (auth.json) are never opened. The watched set is the
# installer's whole write set: config.toml, config.toml.bbj-backup, hooks.json, bbj/, the two skill
# directories, the mktemp files the installer leaves in the Codex home when it dies between
# mktemp and mv (config.toml.XXXXXX, hooks.json.XXXXXX), and the two parent directories. A glob
# that matches nothing stays literal and prints as an absent path. A symlink is recorded with its
# target; a watched top-level symlink to a directory is also followed (find -H), so retargeting it
# and writing through it both show, and a symlink to a regular file also gets a T line with the
# cksum of what it points at, so a write through that link shows too. File content is never
# printed, only its cksum values. Pass the real homes or fake ones; this helper only reads.
# Accepted residual risk: Codex itself rewrites config.toml when a session trusts a new project or
# changes a TUI option. That is a real content change and fails real_home_untouched by design, so do
# not open Codex in a new project during a suite run (0.2.0 D-18 advice, narrowed).
home_snapshot() {
  _hs_c=$1
  _hs_s=$2
  # D-08: the paths codex/install-codex.sh can write; Phase 8 adds its plugin-route paths here
  {
    for _hs_d in "$_hs_c" "$_hs_s"; do
      if [ -d "$_hs_d" ]; then printf 'H %s present\n' "$_hs_d"; else printf 'H %s absent\n' "$_hs_d"; fi
    done
    for _hs_p in "$_hs_c/config.toml" "$_hs_c/config.toml.bbj-backup" "$_hs_c/hooks.json" \
      "$_hs_c"/config.toml.?????? "$_hs_c"/hooks.json.?????? \
      "$_hs_c/bbj" "$_hs_s/bbj-programming" "$_hs_s/bbj-web-programming"; do
      if [ -e "$_hs_p" ] || [ -L "$_hs_p" ]; then
        # -H: a watched top-level path that is a symlink to a directory is followed, so a write
        # through the link is seen; links below it are recorded with their target, not followed
        # names reach the classifier as arguments, never through a line-oriented read (a newline
        # in a name cannot split an entry), and only a regular file is ever opened (a FIFO would
        # block cksum forever); a find that fails, for an unreadable directory, adds an E line
        find -H "$_hs_p" -exec sh -c '
          for _f; do
            if [ -L "$_f" ]; then
              printf "L %s -> %s\n" "$_f" "$(readlink "$_f")"
              # the content behind a file link: a write through the link changes this and nothing else
              if [ -f "$_f" ] && [ -r "$_f" ]; then
                printf "T %s %s\n" "$(cksum < "$_f")" "$_f"
              fi
            elif [ -d "$_f" ]; then
              printf "D %s\n" "$_f"
            elif [ -f "$_f" ] && [ -r "$_f" ]; then
              printf "F %s %s %s\n" "$(ls -ld "$_f" | awk "{ print \$1 }")" "$(cksum < "$_f")" "$_f"
            elif [ -f "$_f" ]; then
              printf "U %s\n" "$_f"
            else
              printf "O %s\n" "$_f"
            fi
          done' sh {} + 2> /dev/null || printf 'E %s\n' "$_hs_p"
      else
        printf -- '- %s\n' "$_hs_p"
      fi
    done
  } | LC_ALL=C sort
}

# home_diff BEFORE AFTER: returns 0 and prints nothing when the two snapshot files are identical;
# otherwise prints the first three changed lines ("<" before, ">" after) and returns 1. A missing
# or unreadable snapshot file, or a diff that fails, prints "home_diff: cannot compare ..." and
# returns 1, so the caller never reports an empty "changed:" (IN-05).
home_diff() {
  cmp -s "$1" "$2" && return 0
  if [ ! -r "$1" ] || [ ! -r "$2" ]; then
    printf 'home_diff: cannot compare %s and %s (missing or unreadable snapshot)\n' "$1" "$2"
    return 1
  fi
  _hd_out=$(diff "$1" "$2")
  _hd_rc=$?
  if [ "$_hd_rc" -gt 1 ]; then
    printf 'home_diff: cannot compare %s and %s (diff exit %s)\n' "$1" "$2" "$_hd_rc"
    return 1
  fi
  printf '%s\n' "$_hd_out" | grep -e '^<' -e '^>' | head -n 3
  return 1
}

# home_incomplete BEFORE AFTER: returns 0 and prints the reason when a comparison of the two
# snapshot files would prove nothing, 1 and nothing when both are complete (WR-02). A snapshot is
# incomplete when it is missing, empty (every real one holds the two H lines, so empty means the walk
# produced nothing, for example a PATH without sort) or holds an E line (a find failure: everything
# below that path was skipped on both sides, so an identical pair is no evidence).
home_incomplete() {
  for _hi_f in "$1" "$2"; do
    if [ ! -s "$_hi_f" ]; then
      printf 'the snapshot %s is missing or empty' "$_hi_f"
      return 0
    fi
  done
  _hi_e=$(grep -h '^E ' "$1" "$2" | LC_ALL=C sort -u | head -n 3 | tr '\n' ' ')
  if [ -n "$_hi_e" ]; then
    printf 'the walk could not read: %s' "$_hi_e"
    return 0
  fi
  return 1
}

# home_incomplete_status: the gate status for an incomplete snapshot. An unreadable directory is an
# environment fact, so it is skip; under CI=true a prerequisite that is missing is a FAIL (the
# project rule for tests/run.sh and tests/ci.sh).
home_incomplete_status() {
  if [ "${CI:-}" = true ]; then echo FAIL; else echo skip; fi
}
