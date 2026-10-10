#!/bin/sh
# .planning/phases/02-hook-no-route-notice/evidence/capture-codex.sh
#
# Plan 02-05, HOOK-04, D-13, D-15: prove on a real Codex that the no-route notice reaches the
# model after apply_patch. Never runs BBj; the only billed call is codex exec in run mode.
#
#   sh capture-codex.sh setup           scratch root CAP: the installer run into a scratch Codex
#                                       home (fake codex first on PATH, the real config is not
#                                       written), a wrapper around the installed bbj-check.sh,
#                                       a scratch project with a project-local .codex/hooks.json.
#                                       Prints the trust command (Task 2 of the plan).
#   sh capture-codex.sh dry-run         the hooks.json command fed an apply_patch payload: the
#                                       notice once, silence on the repeat. No model call.
#   sh capture-codex.sh run TRUST       ONE billed codex exec (TRUST = hooks-approval or
#                                       bypass-flag); completed by Task 3 of the plan.
#   sh capture-codex.sh clean           removes CAP.
#
# Exit codes: 0 done, 1 a check failed, 2 refused before any change (usage, precondition unmet,
# CAP already exists).
#
# CAP = ${BBJ_CAPTURE_DIR:-${TMPDIR:-/tmp}/bbj-capture-codex}, persistent between the modes (the
# user approves the hook in /hooks between setup and run); only clean removes it.
#
# The hook runs with no BBj reachable (hookwrap.sh): BBJ_CHECK_DEFAULT_HOMES empty,
# BBJ_LOCAL_MCP_URL a closed loopback port, BBJ_HOME, BBJHOME and CLAUDE_PLUGIN_OPTION_BBJ_HOME
# unset, BBJ_CHECK_STATE_DIR under CAP. The installer's own Codex home under CAP is only the
# source of the script copy and the hooks.json template: no real codex call points CODEX_HOME at
# it. The real Codex login is used in place by the real calls and is never read or copied here.

MODE=$1
TRUST=$2
case "$MODE" in
  setup | dry-run | clean) ;;
  run)
    case "$TRUST" in
      hooks-approval | bypass-flag) ;;
      *)
        echo "usage: sh capture-codex.sh run hooks-approval|bypass-flag" >&2
        exit 2
        ;;
    esac
    ;;
  *)
    echo "usage: sh capture-codex.sh setup|dry-run|run TRUST|clean" >&2
    exit 2
    ;;
esac

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../../.." && pwd)
EVID=$HERE/codex
CAP=${BBJ_CAPTURE_DIR:-${TMPDIR:-/tmp}/bbj-capture-codex}

# CAP ends up inside a JSON string, a sh command and a sed expression: keep it plain
case "$CAP" in
  /*) ;;
  *)
    echo "refused: BBJ_CAPTURE_DIR must be an absolute path" >&2
    exit 2
    ;;
esac
case "$CAP" in
  *[!A-Za-z0-9._/-]*)
    echo "refused: the capture directory may only hold letters, digits and . _ / -" >&2
    exit 2
    ;;
esac

# tilde: $HOME shown as ~ on stdin to stdout
tilde() {
  _h=$(printf '%s' "$HOME" | sed 's/[][\.*^$/]/\\&/g')
  sed "s/$_h/~/g"
}

# ---- clean --------------------------------------------------------------------------------------
if [ "$MODE" = clean ]; then
  rm -rf "$CAP"
  echo "clean: $CAP removed"
  exit 0
fi

# ---- run (Task 3) -------------------------------------------------------------------------------
if [ "$MODE" = run ]; then
  echo "refused: run mode is completed by Task 3 of plan 02-05" >&2
  exit 2
fi

# ---- setup --------------------------------------------------------------------------------------
setup() {
  if [ -e "$CAP" ]; then
    echo "refused: $CAP already exists; run: sh capture-codex.sh clean" >&2
    return 2
  fi
  for _t in codex python3 git; do
    if ! command -v "$_t" > /dev/null 2>&1; then
      echo "refused: $_t is not on PATH" >&2
      return 2
    fi
  done
  _rch=${CODEX_HOME:-$HOME/.codex}
  if [ ! -d "$_rch" ]; then
    echo "refused: the Codex home $_rch does not exist" >&2
    return 2
  fi
  REAL_CH=$(cd "$_rch" && pwd)
  # the login is checked in place, with no model call; its output (a masked key) is discarded
  if ! (cd "$ROOT" && env CODEX_HOME="$REAL_CH" codex login status > /dev/null 2>&1); then
    echo "refused: codex login status is not logged in" >&2
    return 2
  fi

  mkdir -p "$CAP/home" "$CAP/codexhome" "$CAP/fbcodex" "$CAP/proj" "$CAP/state" "$CAP/emptyhome" || return 2
  printf '%s\n' "$REAL_CH" > "$CAP/codex-home.path"
  # what the real Codex home looked like before, for the restore check of run mode
  if [ -f "$REAL_CH/config.toml" ]; then
    cp "$REAL_CH/config.toml" "$CAP/config.toml.before" || return 2
  else
    echo "config.toml did not exist before" > "$CAP/config.toml.before"
    : > "$CAP/config.toml.absent"
  fi
  if [ -e "$REAL_CH/hooks.json" ]; then
    echo yes > "$CAP/real-hooks-json.before"
  else
    echo no > "$CAP/real-hooks-json.before"
  fi

  # the installer into the scratch Codex home; the fake codex keeps the real config untouched
  cp "$ROOT/tests/fake-bin/codex" "$CAP/fbcodex/codex" || return 2
  chmod 755 "$CAP/fbcodex/codex"
  env HOME="$CAP/home" CODEX_HOME="$CAP/codexhome" PATH="$CAP/fbcodex:/usr/bin:/bin" \
    BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp FAKE_CODEX_LOG="$CAP/fake-codex.log" \
    sh "$ROOT/codex/install-codex.sh" --codex-home "$CAP/codexhome" --skills-dir "$CAP/home/skills" \
    > "$CAP/installer.log" 2>&1
  _irc=$?
  if [ "$_irc" != 0 ]; then
    echo "FAIL: install-codex.sh exited $_irc (see $CAP/installer.log)" >&2
    return 1
  fi
  if ! cmp -s "$CAP/codexhome/bbj/bbj-check.sh" "$ROOT/plugins/bbj/scripts/bbj-check.sh"; then
    echo "FAIL: the installed bbj-check.sh differs from plugins/bbj/scripts/bbj-check.sh" >&2
    return 1
  fi
  if [ ! -f "$CAP/codexhome/hooks.json" ]; then
    echo "FAIL: the installer wrote no hooks.json" >&2
    return 1
  fi

  # the wrapper: records the real payload, runs the installed script under the no-BBj seams,
  # logs rc, stdout and stderr, replays both unchanged and exits with the script's own status
  _wrap=$CAP/hookwrap.sh
  cat > "$_wrap" << 'WRAP'
#!/bin/sh
CAP='@CAP@'
T=$(mktemp "$CAP/in.XXXXXX") || exit 1
cat > "$T"
printf '%s\n' "$(cat "$T")" >> "$CAP/payload.jsonl"
env -u BBJ_HOME -u BBJHOME -u CLAUDE_PLUGIN_OPTION_BBJ_HOME \
  BBJ_CHECK_DEFAULT_HOMES= BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp \
  BBJ_CHECK_STATE_DIR="$CAP/state" \
  sh "$CAP/codexhome/bbj/bbj-check.sh" < "$T" > "$CAP/out.$$" 2> "$CAP/err.$$"
RC=$?
{
  printf '%s rc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$RC"
  echo '--- stdout:'
  cat "$CAP/out.$$"
  echo '--- stderr:'
  cat "$CAP/err.$$"
  echo '---'
} >> "$CAP/hook-log.txt"
cat "$CAP/out.$$"
cat "$CAP/err.$$" >&2
rm -f "$T" "$CAP/out.$$" "$CAP/err.$$"
exit "$RC"
WRAP
  sed "s#@CAP@#$CAP#" "$_wrap" > "$_wrap.tmp" && mv "$_wrap.tmp" "$_wrap" || return 2
  : > "$CAP/payload.jsonl"
  : > "$CAP/hook-log.txt"

  # the scratch project and its project-local hooks.json: the installer's entry, with the
  # command replaced by the wrapper (matcher and timeout kept)
  (cd "$CAP/proj" && git init -q .) || return 2
  mkdir -p "$CAP/proj/.codex"
  python3 -I -c '
import json, sys
src, dst, cmd = sys.argv[1], sys.argv[2], sys.argv[3]
d = json.load(open(src, encoding="utf-8"))
for group in d["hooks"]["PostToolUse"]:
    for h in group["hooks"]:
        h["command"] = cmd
        if "commandWindows" in h:
            h["commandWindows"] = cmd
with open(dst, "w", encoding="utf-8") as f:
    json.dump(d, f, indent=2)
    f.write("\n")' "$CAP/codexhome/hooks.json" "$CAP/proj/.codex/hooks.json" "sh \"$CAP/hookwrap.sh\"" || {
    echo "FAIL: could not write the project hooks.json" >&2
    return 1
  }

  echo "setup ok: $CAP"
  echo "real Codex home (login used in place, never copied): $REAL_CH"
  echo "scratch project: $CAP/proj"
  echo "trust command (hooks-approval): cd $CAP/proj && CODEX_HOME=$REAL_CH codex"
  return 0
}

# ---- dry run: the hooks.json command, by hand ---------------------------------------------------
dry_run() {
  if [ ! -f "$CAP/proj/.codex/hooks.json" ] || [ ! -f "$CAP/hookwrap.sh" ]; then
    echo "refused: run setup first" >&2
    return 2
  fi
  PROJ=$CAP/proj
  _cmd=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$PROJ/.codex/hooks.json")
  if [ -z "$_cmd" ]; then
    echo "FAIL: no hook command in $PROJ/.codex/hooks.json" >&2
    return 1
  fi
  printf 'print "hi"\n' > "$PROJ/hello.bbj"
  # Codex PostToolUse for apply_patch, in the shape of tests/lib.sh codex_payload (synthetic:
  # the real key order is what the billed run records); PROJ has no characters that need escaping
  _payload='{"session_id":"dry1","transcript_path":"/tmp/t.jsonl","cwd":"'"$PROJ"'","hook_event_name":"PostToolUse","tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Add File: hello.bbj\n+print \"hi\"\n*** End Patch\n"},"tool_response":"Success"}'
  printf '%s' "$_payload" > "$CAP/dry-payload.json"

  (cd "$PROJ" && sh -c "$_cmd" < "$CAP/dry-payload.json" > "$CAP/out1" 2> "$CAP/err1")
  _rc1=$?
  (cd "$PROJ" && sh -c "$_cmd" < "$CAP/dry-payload.json" > "$CAP/out2" 2> "$CAP/err2")
  _rc2=$?

  _ok=0
  if [ "$_rc1" = 0 ] && [ ! -s "$CAP/err1" ] && [ "$(wc -l < "$CAP/out1" | tr -d ' ')" = 1 ] \
    && python3 -I -c '
import json, sys
d = json.loads(open(sys.argv[1], encoding="utf-8").read())
o = d["hookSpecificOutput"]
c = o["additionalContext"]
ok = o["hookEventName"] == "PostToolUse"
for need in ("not compile-checked", "no bbjcpl found", "install-codex.sh --with-local"):
    ok = ok and need in c
sys.exit(0 if ok else 1)' "$CAP/out1"; then
    _ok=1
  fi
  if [ "$_rc2" != 0 ] || [ -s "$CAP/out2" ] || [ -s "$CAP/err2" ]; then _ok=0; fi
  # the wrapper recorded both calls
  _np=$(wc -l < "$CAP/payload.jsonl" | tr -d ' ')
  if [ "$_np" != 2 ]; then _ok=0; fi

  mkdir -p "$EVID"
  {
    echo "dry-run of plan 02-05 (no model call)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "codex_version: $(codex --version 2> /dev/null)"
    echo "installer: install-codex.sh into a scratch Codex home with the fake codex first on PATH"
    echo "installed script identical to plugins/bbj/scripts/bbj-check.sh: $(cmp -s "$CAP/codexhome/bbj/bbj-check.sh" "$ROOT/plugins/bbj/scripts/bbj-check.sh" && echo yes || echo no)"
    echo "project hooks.json matcher/timeout: $(python3 -I -c 'import json,sys; h=json.load(open(sys.argv[1]))["hooks"]["PostToolUse"][0]; print(h["matcher"], h["hooks"][0]["timeout"])' "$PROJ/.codex/hooks.json")"
    echo "hook command: $_cmd"
    echo "environment seams (inside the wrapper): BBJ_CHECK_DEFAULT_HOMES= (empty) BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp BBJ_CHECK_STATE_DIR=<scratch>/state; BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME unset"
    echo "--- first call (session dry1): exit $_rc1, stderr $(wc -c < "$CAP/err1" | tr -d ' ') bytes, stdout:"
    cat "$CAP/out1"
    echo "--- second call (same session): exit $_rc2, stderr $(wc -c < "$CAP/err2" | tr -d ' ') bytes, stdout $(wc -c < "$CAP/out2" | tr -d ' ') bytes:"
    cat "$CAP/out2"
    echo "--- wrapper recorded $_np payload line(s)"
    echo "--- result: $([ "$_ok" = 1 ] && echo 'notice then silence' || echo FAIL)"
  } 2>&1 | sed "s#$CAP#<scratch>#g" | tilde > "$EVID/dry-run.txt"

  # the real run starts clean: no records, no marker, no stray file
  rm -f "$CAP/out1" "$CAP/out2" "$CAP/err1" "$CAP/err2" "$CAP/dry-payload.json" "$PROJ/hello.bbj"
  rm -rf "$CAP/state"
  mkdir "$CAP/state"
  : > "$CAP/payload.jsonl"
  : > "$CAP/hook-log.txt"

  if [ "$_ok" != 1 ]; then
    echo "FAIL: the hooks.json command did not print the Codex notice once and then nothing" >&2
    return 1
  fi
  echo "dry-run ok: notice on the first call, silence on the repeat"
  return 0
}

case "$MODE" in
  setup) setup || exit $? ;;
  dry-run) dry_run || exit $? ;;
esac
exit 0
