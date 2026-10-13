#!/bin/sh
# tests/test_codex_patch.sh -- plan 19-05 Task 1 (PLUG-04, D-15): the Codex apply_patch
# branch of the check script. The payload (codex_payload in tests/lib.sh) follows the top-level
# key order captured from Codex CLI codex-cli 0.162.1 (plan 02-05); the raw payloads below
# also cover other orders. Parsing assertions use a fake compiler and its argv
# log; when a real compiler exists one end-to-end gate also runs it (bbjcpl -t -N -X,
# compile-only). Phase 8 (CODEX-02, D-14) adds the plugin-route gates, prefix plugin_route_: the
# command string of plugins/bbj/hooks/hooks.json runs with CLAUDE_PLUGIN_ROOT set to a fake Codex
# plugin-cache path. Nothing here runs BBj.
. "$(dirname "$0")/lib.sh"
mkwork

BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}
NL='
'
PROJ=$WORK/proj
mkdir -p "$PROJ/src" "$PROJ/moved" "$WORK/outside"

# a fake compiler that logs argv (tests/fake-bin/bbjcpl) and prints a canned compiler-format line
mkdir -p "$WORK/home/bin"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/home/bin/bbjcpl"
chmod 755 "$WORK/home/bin/bbjcpl"
printf '/x/f.bbj: error at line 10 (1): print "a"   rem same line\n' > "$WORK/canned.txt"
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
FAKE_OUT=$WORK/canned.txt
export BBJ_HOME FAKE_LOG FAKE_OUT

# calls_list: the file argument (last argument) of every compiler call in the log
calls_list() {
  awk '/^CALL$/ { inb = 1; last = ""; next } /^ARG0 / { if (inb) print last; inb = 0; next } inb { last = $0 }' "$FAKE_LOG"
}

# patch LINES...: the patch text, one argument per line
patch() {
  printf '%s\n' '*** Begin Patch' "$@" '*** End Patch'
}

BADLINE='+print "a"   rem same line'

# ---- add of a bad file with a space in its name ----
printf 'print "a"   rem same line\n' > "$PROJ/src/new one.bbj"
: > "$FAKE_LOG"
run_check "$(codex_payload "$PROJ" "$(patch '*** Add File: src/new one.bbj' "$BADLINE")")"
[ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $PROJ/src/new one.bbj:" ] \
  && gate add_bad ok "exit 2, header names the file resolved against cwd" \
  || gate add_bad FAIL "exit $RC, first line: $(head -n 1 "$WORK/stderr")"
[ "$(calls_list)" = "$PROJ/src/new one.bbj" ] \
  && gate add_bad_argv ok "one compiler call with the absolute file" || gate add_bad_argv FAIL "calls: $(calls_list)"
if grep -x -e '-N' "$FAKE_LOG" > /dev/null; then gate add_bad_dash_n ok "compiler call carries -N"; else gate add_bad_dash_n FAIL "no -N in the call"; fi
[ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ] && [ ! -s "$WORK/stdout" ] \
  && gate add_bad_trailer ok "trailer last, stdout empty" || gate add_bad_trailer FAIL "tail: $(tail -n 1 "$WORK/stderr")"

# ---- update plus move: the destination is checked, the source only when it still exists ----
: > "$PROJ/moved/old2.src"
: > "$FAKE_LOG"
run_check "$(codex_payload "$PROJ" "$(patch '*** Update File: old.src' '*** Move to: moved/old2.src' '@@' '-a' '+b')")"
[ "$RC" = 2 ] && [ "$(calls_list)" = "$PROJ/moved/old2.src" ] \
  && gate move_destination_only ok "moved/old2.src checked, vanished old.src not" \
  || gate move_destination_only FAIL "exit $RC, calls: $(calls_list)"
: > "$PROJ/old.src"
: > "$FAKE_LOG"
run_check "$(codex_payload "$PROJ" "$(patch '*** Update File: old.src' '*** Move to: moved/old2.src')")"
[ "$(calls_list)" = "$PROJ/old.src${NL}$PROJ/moved/old2.src" ] \
  && gate move_source_when_present ok "old.src checked while it exists" || gate move_source_when_present FAIL "calls: $(calls_list)"

# ---- what must never reach the compiler ----
for f in gone.bbj fake.bbj notes.md; do : > "$PROJ/$f"; done
: > "$WORK/escape.bbj"
: > "$WORK/outside/out.bbj"
: > "$FAKE_LOG"
run_check "$(codex_payload "$PROJ" "$(patch '*** Delete File: gone.bbj' '*** Add File: notes.md' '+*** Add File: fake.bbj' '*** Update File: notes.md' '*** Add File: ../escape.bbj' "*** Add File: $WORK/outside/out.bbj" '*** Update File: a/../../escape.bbj')")"
if [ "$RC" = 0 ] && [ -z "$(calls_list)" ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
  gate skipped_never_compiled ok "Delete, content line, non-BBj, .. and outside-cwd paths: no call, silent"
else
  gate skipped_never_compiled FAIL "exit $RC, calls: $(calls_list)"
fi

# ---- an absolute path inside cwd is accepted ----
: > "$PROJ/abs.bbj"
: > "$FAKE_LOG"
run_check "$(codex_payload "$PROJ" "$(patch "*** Add File: $PROJ/abs.bbj" "$BADLINE")")"
[ "$RC" = 2 ] && [ "$(calls_list)" = "$PROJ/abs.bbj" ] \
  && gate absolute_inside_cwd ok "accepted" || gate absolute_inside_cwd FAIL "exit $RC, calls: $(calls_list)"

# ---- a header past byte 8192 is still found ----
: > "$PROJ/early.bbj"
: > "$PROJ/late.bbj"
FILL=$(awk 'BEGIN { for (i = 0; i < 400; i++) print "+xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" }')
BIG=$(patch '*** Add File: early.bbj' "$FILL" '*** Add File: late.bbj' '+print "b"')
PAYLOAD=$(codex_payload "$PROJ" "$BIG")
: > "$FAKE_LOG"
run_check "$PAYLOAD"
late_at=$(printf '%s' "$PAYLOAD" | awk 'BEGIN { RS = "\001" } { print index($0, "late.bbj") }')
[ "$late_at" -gt 8192 ] && [ "$(calls_list)" = "$PROJ/early.bbj${NL}$PROJ/late.bbj" ] \
  && gate header_past_8192 ok "late.bbj header at byte $late_at is checked" \
  || gate header_past_8192 FAIL "late at $late_at, calls: $(calls_list)"

# ---- tool_name and cwd after a long tool_input ----
RAW='{"tool_input":{"command":"*** Begin Patch\n*** Add File: late.bbj\n+x\n*** End Patch"},"tool_name":"apply_patch","cwd":"'$PROJ'"}'
: > "$FAKE_LOG"
run_check "$RAW"
[ "$RC" = 2 ] && [ "$(calls_list)" = "$PROJ/late.bbj" ] \
  && gate keys_after_tool_input ok "tool_name and cwd found after tool_input" || gate keys_after_tool_input FAIL "exit $RC, calls: $(calls_list)"

# ---- a \uXXXX escape in a content line does not hide the headers ----
RAW='{"cwd":"'$PROJ'","tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Add File: early.bbj\n+café\n*** End Patch"}}'
: > "$FAKE_LOG"
run_check "$RAW"
[ "$RC" = 2 ] && [ "$(calls_list)" = "$PROJ/early.bbj" ] \
  && gate unicode_escape_in_content ok "header found" || gate unicode_escape_in_content FAIL "exit $RC, calls: $(calls_list)"

# ---- other tools and broken payloads stay silent ----
for p in '{"cwd":"/tmp","tool_name":"Bash","tool_input":{"command":"*** Add File: early.bbj"}}' \
         '{"tool_name":"apply_patch","tool_input":{"command":"*** Add File: early.bbj"}}' \
         '{"cwd":"/tmp","tool_name":"apply_patch","tool_input":{"cmd":"*** Add File: early.bbj"}}' \
         '{"cwd":"relative/dir","tool_name":"apply_patch","tool_input":{"command":"*** Add File: early.bbj"}}'; do
  : > "$FAKE_LOG"
  run_check "$p"
  [ "$RC" = 0 ] && [ -z "$(calls_list)" ] && [ ! -s "$WORK/stderr" ] || { gate silent_cases FAIL "exit $RC for $p"; SILENT_BAD=1; }
done
[ "${SILENT_BAD:-0}" = 1 ] || gate silent_cases ok "Bash tool, no cwd, no command key, relative cwd: exit 0 and silent"

# ---- two failing files: two blocks, each with its own N, one bbj_lookup line at the end ----
mkdir -p "$WORK/home2/bin"
cat > "$WORK/home2/bin/bbjcpl" <<'FAKE'
#!/bin/sh
# per-file fake: e1.bbj reports one error line, e2.bbj two; logs nothing
for a in "$@"; do last=$a; done
case "$last" in
  */e1.bbj) echo "$last: error at line 10 (1): one" >&2 ;;
  */e2.bbj) echo "$last: error at line 10 (1): one" >&2; echo "$last: error at line 11 (1): two" >&2 ;;
esac
exit 0
FAKE
chmod 755 "$WORK/home2/bin/bbjcpl"
: > "$PROJ/e1.bbj"
: > "$PROJ/e2.bbj"
BBJ_HOME=$WORK/home2 run_check "$(codex_payload "$PROJ" "$(patch '*** Add File: e1.bbj' '*** Add File: e2.bbj')")"
heads=$(grep -c '^bbjcpl reported ' "$WORK/stderr")
looks=$(grep -c '^bbj_lookup gives exact syntax for a named symbol\.$' "$WORK/stderr")
if [ "$RC" = 2 ] && [ "$heads" = 2 ] && [ "$looks" = 1 ] \
  && [ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ] \
  && grep -Fx "bbjcpl reported 1 error(s) in $PROJ/e1.bbj:" "$WORK/stderr" > /dev/null \
  && grep -Fx "bbjcpl reported 2 error(s) in $PROJ/e2.bbj:" "$WORK/stderr" > /dev/null; then
  gate two_failing_files ok "two headers (N=1, N=2), one bbj_lookup line, last"
else
  gate two_failing_files FAIL "exit $RC, headers $heads, lookup lines $looks"
fi
# one failing and one clean file: exactly one block
: > "$PROJ/clean.bbj"
BBJ_HOME=$WORK/home2 run_check "$(codex_payload "$PROJ" "$(patch '*** Add File: clean.bbj' '*** Add File: e1.bbj')")"
[ "$RC" = 2 ] && [ "$(grep -c '^bbjcpl reported ' "$WORK/stderr")" = 1 ] \
  && gate one_failing_one_clean ok "one block" || gate one_failing_one_clean FAIL "exit $RC"

# ---- the same file named twice is checked once ----
: > "$FAKE_LOG"
run_check "$(codex_payload "$PROJ" "$(patch '*** Update File: early.bbj' '*** Update File: ./early.bbj' '*** Update File: early.bbj')")"
[ "$(calls_list)" = "$PROJ/early.bbj" ] \
  && gate duplicates_once ok "early.bbj, ./early.bbj and early.bbj give one call" || gate duplicates_once FAIL "calls: $(calls_list)"

# ---- the plugin route (CODEX-02, D-14): hooks.json command under a fake Codex cache path ----
# Codex runs the hook command of the plugin with CLAUDE_PLUGIN_ROOT set to its plugin cache,
# $CODEX_HOME/plugins/cache/basis-bbj/bbj/<version>/ (spike 001 saw this shape in hooks/list). The
# parent directory name holds a space on purpose, and the trailing slash is D-14's: the command then
# expands to .../<version>//scripts/bbj-check.sh, a double slash that a real path resolves. The copy
# lives under mkwork ($TMPDIR); the rule that keeps throwaway Codex homes out of /tmp is about homes
# where real Codex runs. No Codex runs here: only sh and the fake bbjcpl read the copy.
# The earlier block that sets BBJ_HOME as a prefix on run_check can persist under dash (Pitfall 4),
# so the three variables are set and exported again.
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
FAKE_OUT=$WORK/canned.txt
export BBJ_HOME FAKE_LOG FAKE_OUT
if ! command -v python3 > /dev/null 2>&1; then
  if [ "${CI:-}" = true ]; then
    gate plugin_route_command FAIL "python3 missing under CI=true"
  else
    gate plugin_route_command skip "no python3 to read hooks.json and the overlay version"
  fi
else
  ROUTE_CMD=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$REPO/plugins/bbj/hooks/hooks.json" 2> /dev/null)
  ROUTE_VER=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$REPO/plugins/bbj/.codex-plugin/plugin.json" 2> /dev/null)
  if [ -z "$ROUTE_CMD" ] || [ -z "$ROUTE_VER" ]; then
    gate plugin_route_command FAIL "no command in hooks.json or no version in the overlay (command='$ROUTE_CMD' version='$ROUTE_VER')"
  else
    CACHE="$WORK/codex home/plugins/cache/basis-bbj/bbj/$ROUTE_VER/"
    mkdir -p "$CACHE" "$PROJ/route"
    cp -R "$REPO/plugins/bbj/." "$CACHE"
    : > "$WORK/empty.txt"
    _missing=
    for _f in .codex-plugin/plugin.json .codex-mcp.json hooks/hooks.json scripts/bbj-check.sh; do
      [ -f "$CACHE$_f" ] || _missing="$_missing $_f"
    done
    [ -z "$_missing" ] \
      && gate plugin_route_cache_layout ok "the cache copy holds the overlay, .codex-mcp.json, hooks.json and the script" \
      || gate plugin_route_cache_layout FAIL "missing in the copy:$_missing"

    # a bad file: exit 2, header names the absolute file, one compiler call that carries -N
    printf 'print "a"   rem same line\n' > "$PROJ/route/bad.bbj"
    codex_payload "$PROJ" "$(patch '*** Add File: route/bad.bbj' "$BADLINE")" > "$WORK/route_bad.json"
    : > "$FAKE_LOG"
    CLAUDE_PLUGIN_ROOT="$CACHE" sh -c "$ROUTE_CMD" < "$WORK/route_bad.json" > "$WORK/route_out" 2> "$WORK/route_err"
    _rc=$?
    [ "$_rc" = 2 ] && [ "$(head -n 1 "$WORK/route_err")" = "bbjcpl reported 1 error(s) in $PROJ/route/bad.bbj:" ] && [ ! -s "$WORK/route_out" ] \
      && gate plugin_route_bad ok "exit 2, header names the file, stdout empty, root holds a space and a trailing slash" \
      || gate plugin_route_bad FAIL "exit $_rc, first line: $(head -n 1 "$WORK/route_err"), stdout bytes: $(wc -c < "$WORK/route_out")"
    if [ "$(calls_list)" = "$PROJ/route/bad.bbj" ] && grep -x -e '-N' "$FAKE_LOG" > /dev/null; then
      gate plugin_route_dash_n ok "one compiler call with the absolute file, and -N"
    else
      gate plugin_route_dash_n FAIL "calls: $(calls_list); -N present: $(grep -cx -e '-N' "$FAKE_LOG")"
    fi

    # a clean file: the compiler prints nothing, so exit 0 and silence
    printf 'print "a"; rem ok\n' > "$PROJ/route/clean.bbj"
    codex_payload "$PROJ" "$(patch '*** Add File: route/clean.bbj' '+print "a"; rem ok')" > "$WORK/route_clean.json"
    : > "$FAKE_LOG"
    FAKE_OUT="$WORK/empty.txt" CLAUDE_PLUGIN_ROOT="$CACHE" sh -c "$ROUTE_CMD" < "$WORK/route_clean.json" > "$WORK/route_out" 2> "$WORK/route_err"
    _rc=$?
    _calls=$(grep -c '^CALL$' "$FAKE_LOG")
    [ "$_rc" = 0 ] && [ ! -s "$WORK/route_out" ] && [ ! -s "$WORK/route_err" ] && [ "$_calls" = 1 ] \
      && gate plugin_route_clean ok "exit 0, stdout and stderr empty, one compiler call" \
      || gate plugin_route_clean FAIL "exit $_rc, compiler calls $_calls, stderr: $(head -n 1 "$WORK/route_err")"

    # a patch that names no BBj file: silent, no compiler call
    printf 'notes\n' > "$PROJ/route/notes.md"
    codex_payload "$PROJ" "$(patch '*** Add File: route/notes.md' '+notes')" > "$WORK/route_notes.json"
    : > "$FAKE_LOG"
    CLAUDE_PLUGIN_ROOT="$CACHE" sh -c "$ROUTE_CMD" < "$WORK/route_notes.json" > "$WORK/route_out" 2> "$WORK/route_err"
    _rc=$?
    _calls=$(grep -c '^CALL$' "$FAKE_LOG")
    [ "$_rc" = 0 ] && [ "$_calls" = 0 ] && [ ! -s "$WORK/route_out" ] && [ ! -s "$WORK/route_err" ] \
      && gate plugin_route_no_bbj_silent ok "no .bbj, .src or .bbx file in the patch: exit 0, silent, no compiler call" \
      || gate plugin_route_no_bbj_silent FAIL "exit $_rc, compiler calls $_calls, stderr: $(head -n 1 "$WORK/route_err")"

    # D-11 of phase 9: a Windows override of the hook command may exist, but the gates above run
    # 'command' (the Codex plugin route on Linux and macOS). The override must name the same script
    # and must differ from 'command'; the invariant is that the two strings reach one script.
    ROUTE_CMD_WIN=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["hooks"]["PostToolUse"][0]["hooks"][0].get("commandWindows", ""))' "$REPO/plugins/bbj/hooks/hooks.json" 2> /dev/null)
    case "$ROUTE_CMD_WIN" in
      *'${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh'*)
        case "$ROUTE_CMD" in
          *'${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh'*)
            [ "$ROUTE_CMD_WIN" != "$ROUTE_CMD" ] \
              && gate plugin_route_command_windows ok "commandWindows names the same script as command and differs from it; the gates above still run command" \
              || gate plugin_route_command_windows FAIL "commandWindows equals command"
            ;;
          *) gate plugin_route_command_windows FAIL "command does not name the script: $ROUTE_CMD" ;;
        esac
        ;;
      *) gate plugin_route_command_windows FAIL "no commandWindows naming the script in hooks.json (found: '$ROUTE_CMD_WIN')" ;;
    esac
  fi
fi

# ---- the real compiler, when there is one ----
if [ -x "$BBJ_TEST_HOME/bin/bbjcpl" ]; then
  unset FAKE_OUT FAKE_LOG
  BBJ_HOME=$BBJ_TEST_HOME
  export BBJ_HOME
  run_check "$(codex_payload "$PROJ" "$(patch '*** Add File: src/new one.bbj' "$BADLINE")")"
  if [ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $PROJ/src/new one.bbj:" ] \
    && grep -F 'error at line 10 (1)' "$WORK/stderr" > /dev/null; then
    gate real_compiler_add_bad ok "exit 2, header and the compiler's own line"
  else
    gate real_compiler_add_bad FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
  fi
  printf 'print "a"; rem ok\n' > "$PROJ/real_clean.bbj"
  run_check "$(codex_payload "$PROJ" "$(patch '*** Add File: real_clean.bbj' '+print "a"; rem ok')")"
  [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && gate real_compiler_clean ok "silent" || gate real_compiler_clean FAIL "exit $RC"
else
  gate real_compiler skip "no executable $BBJ_TEST_HOME/bin/bbjcpl on this host"
fi

finish
