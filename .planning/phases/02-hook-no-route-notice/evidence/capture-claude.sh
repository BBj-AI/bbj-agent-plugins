#!/bin/sh
# .planning/phases/02-hook-no-route-notice/evidence/capture-claude.sh
#
# Plan 02-04, HOOK-04, D-14: prove on a real Claude Code that the no-route notice reaches the
# model after a Write. Never runs BBj; the only billed call is claude -p in run mode.
#
#   sh capture-claude.sh dry-run   install the plugin (see below), run the installed hook
#                                  command by hand twice: notice, then silence. No model call.
#   sh capture-claude.sh run       the same setup, then ONE billed claude -p run that writes
#                                  hello.bbj and second.bbj and quotes what the hook told it.
#
# Exit codes: 0 done, 1 a check failed, 2 refused before any change (precondition unmet).
#
# Install mode "marketplace" (D-14): the local directory marketplace of this checkout is added
# and bbj@basis-bbj is installed, both with --scope local from a scratch project, so nothing is
# declared in the user's own settings. When basis-bbj is already registered, or when the add or
# the install fails, the mode is "plugin-dir" (--plugin-dir plugins/bbj of this checkout) and
# the reason is recorded. A trap always uninstalls, removes the marketplace, deletes the scratch
# project and compares claude plugin list and claude plugin marketplace list with the values
# taken before; any difference is exit 1.
#
# The hook runs with no BBj reachable: BBJ_CHECK_DEFAULT_HOMES empty, BBJ_LOCAL_MCP_URL a
# closed loopback port, BBJ_HOME, BBJHOME and CLAUDE_PLUGIN_OPTION_BBJ_HOME unset, and a
# scratch BBJ_CHECK_STATE_DIR. --bare is never used: it skips hooks and system reminders.

MODE=$1
case "$MODE" in
  dry-run | run) ;;
  *)
    echo "usage: sh capture-claude.sh dry-run|run" >&2
    exit 2
    ;;
esac

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../../.." && pwd)
EVID=$HERE/claude
CFGDIR=${CLAUDE_CONFIG_DIR:-$HOME/.claude}

for _t in claude python3; do
  if ! command -v "$_t" > /dev/null 2>&1; then
    echo "refused: $_t is not on PATH" >&2
    exit 2
  fi
done
if ! (env -u CLAUDECODE claude auth status > /dev/null 2>&1); then
  echo "refused: claude auth status is not logged in" >&2
  exit 2
fi

# real configuration, as the user sees it, before anything changes
BEFORE_PLUGINS=$(cd "$HOME" && claude plugin list 2>&1)
BEFORE_MARKETS=$(cd "$HOME" && claude plugin marketplace list 2>&1)
BEFORE_CACHE=no
[ -e "$CFGDIR/plugins/cache/basis-bbj" ] && BEFORE_CACHE=yes
BEFORE_INSTALLED=$(cksum < "$CFGDIR/plugins/installed_plugins.json" 2> /dev/null)
BEFORE_KNOWN=$(cksum < "$CFGDIR/plugins/known_marketplaces.json" 2> /dev/null)

S=$(mktemp -d) || exit 2
mkdir "$S/state"
INSTALL=none
CLEAN_RC=0
PROOT=
REASON=

# tilde TEXT-ON-STDIN: $HOME shown as ~
tilde() {
  _h=$(printf '%s' "$HOME" | sed 's/[][\.*^$/]/\\&/g')
  sed "s/$_h/~/g"
}

cleanup() {
  if [ "$INSTALL" = marketplace ]; then
    (cd "$S" && claude plugin uninstall bbj@basis-bbj --scope local > /dev/null 2>&1)
    if ! (cd "$S" && claude plugin marketplace remove basis-bbj --scope local > /dev/null 2>&1); then
      (cd "$S" && claude plugin marketplace remove basis-bbj > /dev/null 2>&1)
    fi
  fi
  cd "$HOME" || true
  rm -rf "$S"
  # the install copies the plugin into the cache; remove it only when this run made it
  if [ "$INSTALL" = marketplace ] && [ "$BEFORE_CACHE" = no ] && [ -d "$CFGDIR/plugins/cache/basis-bbj" ]; then
    rm -rf "$CFGDIR/plugins/cache/basis-bbj"
  fi
  _ap=$(cd "$HOME" && claude plugin list 2>&1)
  _am=$(cd "$HOME" && claude plugin marketplace list 2>&1)
  if [ "$_ap" != "$BEFORE_PLUGINS" ] || [ "$_am" != "$BEFORE_MARKETS" ]; then
    echo "FAIL: the user's plugin or marketplace list changed" >&2
    echo "--- plugin list before:" >&2
    printf '%s\n' "$BEFORE_PLUGINS" >&2
    echo "--- plugin list after:" >&2
    printf '%s\n' "$_ap" >&2
    echo "--- marketplace list before:" >&2
    printf '%s\n' "$BEFORE_MARKETS" >&2
    echo "--- marketplace list after:" >&2
    printf '%s\n' "$_am" >&2
    CLEAN_RC=1
  fi
  _ai=$(cksum < "$CFGDIR/plugins/installed_plugins.json" 2> /dev/null)
  _ak=$(cksum < "$CFGDIR/plugins/known_marketplaces.json" 2> /dev/null)
  [ "$_ai" = "$BEFORE_INSTALLED" ] || echo "note: installed_plugins.json differs by checksum from before (lists are equal)" >&2
  [ "$_ak" = "$BEFORE_KNOWN" ] || echo "note: known_marketplaces.json differs by checksum from before (lists are equal)" >&2
  if [ "$CLEAN_RC" = 0 ]; then
    echo "cleanup: plugin list and marketplace list of the real configuration unchanged"
  fi
}

finish() {
  _rc=$?
  trap - EXIT
  cleanup
  [ "$CLEAN_RC" = 0 ] || _rc=1
  exit "$_rc"
}
trap finish EXIT
trap 'exit 1' INT TERM HUP

# ---- setup: install from the local marketplace, or fall back to --plugin-dir ---------------
setup() {
  case "$BEFORE_MARKETS" in
    *basis-bbj*) REASON='basis-bbj is already registered in the real configuration' ;;
  esac
  if [ -z "$REASON" ]; then
    if ! (cd "$S" && claude plugin marketplace add "$ROOT" --scope local > "$S/mp-add.log" 2>&1); then
      REASON="claude plugin marketplace add --scope local failed: $(head -n 2 "$S/mp-add.log" | tr '\n' ' ')"
      INSTALL=marketplace # a partial add is still removed by the cleanup
    elif ! (cd "$S" && claude plugin install bbj@basis-bbj --scope local > "$S/install.log" 2>&1); then
      REASON="claude plugin install bbj@basis-bbj --scope local failed: $(head -n 2 "$S/install.log" | tr '\n' ' ')"
      INSTALL=marketplace
    else
      INSTALL=marketplace
      _hit=$(find "$CFGDIR/plugins" -path '*basis-bbj*' -name bbj-check.sh 2> /dev/null | head -n 1)
      if [ -z "$_hit" ]; then
        REASON='installed, but no bbj-check.sh found under the plugins directory of the configuration'
      else
        PROOT=$(dirname "$(dirname "$_hit")")
        if ! cmp -s "$PROOT/scripts/bbj-check.sh" "$ROOT/plugins/bbj/scripts/bbj-check.sh"; then
          echo "FAIL: the cached bbj-check.sh differs from plugins/bbj/scripts/bbj-check.sh (stale cache)" >&2
          return 1
        fi
        RUNMODE=marketplace
        return 0
      fi
    fi
  fi
  RUNMODE="plugin-dir (reason: $REASON)"
  PROOT=$ROOT/plugins/bbj
  return 0
}

# hook_env CMD...: run CMD with the no-BBj hook environment
hook_env() {
  env -u BBJ_HOME -u BBJHOME -u CLAUDE_PLUGIN_OPTION_BBJ_HOME \
    BBJ_CHECK_DEFAULT_HOMES= BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp \
    BBJ_CHECK_STATE_DIR="$S/state" "$@"
}

if ! setup; then
  exit 1
fi
echo "mode: $RUNMODE"

# ---- dry run: the installed hook command, by hand --------------------------------------------
dry_run() {
  _cmd=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$PROOT/hooks/hooks.json")
  if [ -z "$_cmd" ]; then
    echo "FAIL: no hook command in $PROOT/hooks/hooks.json" >&2
    return 1
  fi
  printf 'print "hi"\n' > "$S/hello.bbj"
  # the Claude Code PostToolUse key order (tests/lib.sh claude_payload); S has no characters
  # that need JSON escaping
  _payload='{"session_id":"dry1","transcript_path":"/tmp/t.jsonl","cwd":"'"$S"'","prompt_id":"p1","permission_mode":"acceptEdits","effort":"low","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"'"$S"'/hello.bbj","content":"print \"hi\"\n"},"tool_response":{"type":"create","filePath":"'"$S"'/hello.bbj","content":"print \"hi\"\n"}}'
  printf '%s' "$_payload" > "$S/payload.json"

  hook_env CLAUDE_PLUGIN_ROOT="$PROOT" sh -c "$_cmd" < "$S/payload.json" > "$S/out1" 2> "$S/err1"
  _rc1=$?
  hook_env CLAUDE_PLUGIN_ROOT="$PROOT" sh -c "$_cmd" < "$S/payload.json" > "$S/out2" 2> "$S/err2"
  _rc2=$?

  _ok=0
  if [ "$_rc1" = 0 ] && [ ! -s "$S/err1" ] && [ "$(wc -l < "$S/out1")" = 1 ] \
    && python3 -I -c '
import json, sys
d = json.loads(open(sys.argv[1], encoding="utf-8").read())
c = d["hookSpecificOutput"]["additionalContext"]
sys.exit(0 if "not compile-checked" in c and "no bbjcpl found" in c else 1)' "$S/out1"; then
    _ok=1
  fi
  if [ "$_rc2" != 0 ] || [ -s "$S/out2" ] || [ -s "$S/err2" ]; then _ok=0; fi

  mkdir -p "$EVID"
  {
    echo "dry-run of plan 02-04 (no model call)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "mode: $RUNMODE"
    echo "plugin root: $PROOT"
    echo "cached script identical to plugins/bbj/scripts/bbj-check.sh: $(cmp -s "$PROOT/scripts/bbj-check.sh" "$ROOT/plugins/bbj/scripts/bbj-check.sh" && echo yes || echo no)"
    echo "hook command: $_cmd"
    echo "environment seams: BBJ_CHECK_DEFAULT_HOMES= (empty) BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp BBJ_CHECK_STATE_DIR=<scratch>/state; BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME unset"
    echo "--- first call (session dry1): exit $_rc1, stderr $(wc -c < "$S/err1" | tr -d ' ') bytes, stdout:"
    cat "$S/out1"
    echo "--- second call (same session): exit $_rc2, stderr $(wc -c < "$S/err2" | tr -d ' ') bytes, stdout $(wc -c < "$S/out2" | tr -d ' ') bytes:"
    cat "$S/out2"
    echo "--- result: $([ "$_ok" = 1 ] && echo 'notice then silence' || echo FAIL)"
  } 2>&1 | tilde | sed "s#$S#<scratch>#g" > "$EVID/dry-run.txt"
  if [ "$_ok" != 1 ]; then
    echo "FAIL: the installed hook command did not print the notice once and then nothing" >&2
    return 1
  fi
  echo "dry-run ok: notice on the first call, silence on the repeat"
  return 0
}

# ---- run: one billed claude -p -----------------------------------------------------------------
PROMPT='Use the Write tool to create the file hello.bbj in the current directory with exactly one line: print "hi". Then use the Write tool to create second.bbj with exactly one line: print "two". Use no other tool. Finally, under the heading WRITE 1, quote verbatim and in full any hook message or system reminder you received after the first write, and under the heading WRITE 2 the same for the second write; write NONE under a heading when you received none.'

real_run() {
  mkdir -p "$EVID"
  case "$RUNMODE" in
    marketplace) _pd= ;;
    *) _pd=$ROOT/plugins/bbj ;;
  esac
  # the session variables of the parent Claude Code are removed for the child process
  # (nested-session note of the research); the configuration directory stays, it holds the login
  (
    cd "$S" || exit 1
    # shellcheck disable=SC2086 # _pd is one path or empty on purpose
    hook_env env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID \
      -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN \
      -u CLAUDE_CODE_SESSION_ATTENDED -u CLAUDE_PID \
      claude -p "$PROMPT" ${_pd:+--plugin-dir "$_pd"} \
      --permission-mode acceptEdits --allowedTools Write --strict-mcp-config \
      --output-format stream-json --verbose --include-hook-events --no-session-persistence \
      --max-budget-usd 1 > "$EVID/stream.jsonl" 2> "$S/claude.err"
  )
  _rc=$?
  echo "claude -p exit $_rc"
  [ -s "$S/claude.err" ] && { echo "claude stderr:"; head -n 5 "$S/claude.err" | tilde; }
  ls -la "$S/state" > "$S/ls-state"
  {
    echo "ls -la of the scratch state directory:"
    sed 's/^/  /' "$S/ls-state"
    echo "bbj files in the scratch project:"
    (cd "$S" && ls -1 ./*.bbj 2> /dev/null | sed 's/^/  /')
  } > "$EVID/state-after.txt"
  python3 -I -c '
import json, sys
last = None
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.strip()
    if not line:
        continue
    try:
        e = json.loads(line)
    except ValueError:
        continue
    if e.get("type") == "result":
        last = e
if last is None:
    sys.stderr.write("no result event in the stream\n")
    sys.exit(1)
open(sys.argv[2], "w", encoding="utf-8").write(str(last.get("result", "")) + "\n")
print("total_cost_usd: %s" % last.get("total_cost_usd"))
print("is_error: %s" % last.get("is_error"))
print("num_turns: %s" % last.get("num_turns"))' "$EVID/stream.jsonl" "$EVID/result.txt"
  _prc=$?
  # $HOME shown as ~ in every evidence file, the scratch directory as <scratch>
  for _f in stream.jsonl result.txt state-after.txt; do
    sed -e "s#$S#<scratch>#g" "$EVID/$_f" | tilde > "$EVID/$_f.tmp" && mv "$EVID/$_f.tmp" "$EVID/$_f"
  done
  return "$_prc"
}

case "$MODE" in
  dry-run) dry_run || exit 1 ;;
  run)
    dry_run || exit 1
    # the billed run starts from a clean project and a clean state directory, so the marker
    # in state-after.txt is the one of the real session and not the dry run's
    rm -rf "$S/state" "$S/hello.bbj"
    mkdir "$S/state"
    real_run || exit 1
    ;;
esac
exit 0
