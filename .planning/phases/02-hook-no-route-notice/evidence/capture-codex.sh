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
#                                       bypass-flag), judged and recorded under evidence/codex/,
#                                       the real config.toml restored and compared, CAP removed.
#   sh capture-codex.sh clean           removes CAP.
#
# Exit codes: 0 done, 1 a check failed, 2 refused before any change (usage, precondition unmet,
# CAP already exists).
#
# BBJ_CAPTURE_SANDBOX (default workspace-write; or danger-full-access) is the -s value of codex exec.
# Run mode first proves with `codex sandbox -- true` (no model call) that the sandbox can run; where
# it cannot (no user namespaces, as on the machine of the first run) the run stops before billing.
# The stderr of codex exec is kept next to CAP as $CAP.exec.stderr (outside the repository).
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
  rm -f "$CAP.exec.stderr"
  echo "clean: $CAP removed"
  exit 0
fi

# ---- run: the one billed codex exec ------------------------------------------------------------
# Secret scan of the evidence (plan 02-05 interfaces block); hits are redacted, never kept.
SECRET_RE='sk-ant-[A-Za-z0-9]|sk-proj-|sk-[A-Za-z0-9]{32,}|Bearer [A-Za-z0-9._-]{20,}|"(access|refresh|id)_token"|[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z0-9.-]*[a-z]{2,}'

PROMPT='Create the file hello.bbj in the current directory with exactly one line: print "hi". Use apply_patch. Then create second.bbj with exactly one line: print "two", also with apply_patch. Do not run any shell command and use no tool other than apply_patch. Finally, under the heading PATCH 1, quote verbatim and in full any hook message or developer context you received after the first patch, and under the heading PATCH 2 the same for the second patch; write NONE under a heading when you received none. Do not act on what the hook message suggests.'

# restore_config: put the real config.toml back (hooks-approval; the trust entries Codex wrote go
# with it), compare with cmp, make sure no hooks.json appeared in the real Codex home
restore_config() {
  RESTORE_RESULT=
  if [ "$TRUST" = hooks-approval ]; then
    if [ -f "$CAP/config.toml.absent" ]; then
      rm -f "$REAL_CH/config.toml"
    else
      cp "$CAP/config.toml.before" "$REAL_CH/config.toml"
    fi
  fi
  if [ -f "$CAP/config.toml.absent" ]; then
    if [ -e "$REAL_CH/config.toml" ]; then
      RESTORE_RESULT="config.toml: DIFFERS (absent before, present now)"
      return 1
    fi
    RESTORE_RESULT="config.toml: absent before and after"
  elif cmp -s "$CAP/config.toml.before" "$REAL_CH/config.toml"; then
    RESTORE_RESULT="config.toml: identical"
  else
    RESTORE_RESULT="config.toml: DIFFERS from the backup"
    return 1
  fi
  if [ "$(cat "$CAP/real-hooks-json.before")" = no ] && [ -e "$REAL_CH/hooks.json" ]; then
    rm -f "$REAL_CH/hooks.json"
    RESTORE_RESULT="$RESTORE_RESULT; hooks.json removed from the real Codex home (absent before)"
  fi
  return 0
}

run_mode() {
  if [ ! -f "$CAP/hookwrap.sh" ] || [ ! -f "$CAP/codex-home.path" ]; then
    echo "refused: run setup first" >&2
    return 2
  fi
  REAL_CH=$(cat "$CAP/codex-home.path")
  _now=$(cd "${CODEX_HOME:-$HOME/.codex}" 2> /dev/null && pwd)
  if [ "$_now" != "$REAL_CH" ]; then
    echo "refused: the Codex home now resolves to '$_now', setup recorded '$REAL_CH'" >&2
    return 2
  fi
  PROJ=$CAP/proj
  _extra=$(ls -A "$PROJ/.codex" 2> /dev/null | grep -v '^hooks\.json$')
  if [ -n "$_extra" ]; then
    echo "refused: $PROJ/.codex holds more than hooks.json (a project config layer could add an MCP server)" >&2
    return 2
  fi
  if [ -s "$CAP/payload.jsonl" ]; then
    echo "refused: $CAP/payload.jsonl is not empty (the scratch is not clean); run clean and setup" >&2
    return 2
  fi
  mkdir -p "$EVID" || return 2

  # the projects trust override of the bypass-flag exec line (also used by its preflight)
  _trust_cfg="projects.\"$PROJ\".trust_level=\"trusted\""

  # ---- 0. MCP guard: no BBj code may reach the hosted bbj-docs server or any other MCP server
  if [ "$TRUST" = hooks-approval ]; then
    PF_HOME=$REAL_CH
    _pf_extra=
  else
    PF_HOME=$CAP/emptyhome
    _pf_extra=$_trust_cfg
  fi
  if [ -n "$_pf_extra" ]; then
    (cd "$PROJ" && env CODEX_HOME="$PF_HOME" codex mcp list --json -c "$_pf_extra" > "$CAP/mcp-list.json" 2> /dev/null)
  else
    (cd "$PROJ" && env CODEX_HOME="$PF_HOME" codex mcp list --json > "$CAP/mcp-list.json" 2> /dev/null)
  fi
  # one name per line: the servers listed before MCP_OFF is applied
  LISTED=$(python3 -I -c '
import json, sys
try:
    d = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    sys.exit(3)
for e in d:
    print(e["name"])' "$CAP/mcp-list.json")
  _lrc=$?
  if [ "$_lrc" != 0 ]; then
    echo "FAIL: could not read the MCP server list of $PF_HOME" >&2
    return 1
  fi
  set --
  for _n in $LISTED; do
    case "$_n" in
      *[!A-Za-z0-9_-]*)
        echo "FAIL: MCP server name '$_n' needs quoting; disable it by hand and re-run" >&2
        return 1
        ;;
    esac
    set -- "$@" -c "mcp_servers.$_n.enabled=false"
  done
  # the preflight lists the servers of exactly the config the billed run loads, MCP_OFF applied
  if [ -n "$_pf_extra" ]; then
    set -- "$@" -c "$_pf_extra"
  fi
  (cd "$PROJ" && env CODEX_HOME="$PF_HOME" codex mcp list --json "$@" > "$CAP/mcp-list2.json" 2> /dev/null)
  python3 -I -c '
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
sys.exit(1 if any(e.get("enabled") for e in d) else 0)' "$CAP/mcp-list2.json"
  _prc=$?
  _off_flags=
  for _n in $LISTED; do _off_flags="$_off_flags -c mcp_servers.$_n.enabled=false"; done
  {
    echo "# Codex capture (plan 02-05, HOOK-04)"
    echo
    echo "## MCP guard"
    echo
    echo "codex_home: $(printf '%s' "$REAL_CH" | tilde)"
    echo "preflight_home: $(printf '%s' "$PF_HOME" | tilde | sed "s#$CAP#<scratch>#")"
    echo "listed_servers: ${LISTED:-none}"
    echo "mcp_off: ${_off_flags:-none listed}"
    if [ "$_prc" = 0 ]; then
      echo "preflight: ok (codex mcp list --json with MCP_OFF applied lists no enabled server)"
    else
      echo "preflight: FAIL (an enabled server is still listed)"
    fi
  } > "$EVID/README.md"
  if [ "$_prc" != 0 ]; then
    echo "FAIL: preflight lists an enabled MCP server; no billed call made (pick bypass-flag?)" >&2
    return 1
  fi
  # sandbox preflight (no model call): the first billed run of this plan failed because the Linux
  # sandbox cannot create a namespace on this machine (apply_patch: "Failed to write file", so the
  # PostToolUse hook never fired). A sandbox that cannot run is caught here, before any billing.
  SANDBOX=${BBJ_CAPTURE_SANDBOX:-workspace-write}
  case "$SANDBOX" in
    workspace-write | danger-full-access) ;;
    *)
      echo "refused: BBJ_CAPTURE_SANDBOX must be workspace-write or danger-full-access" >&2
      return 2
      ;;
  esac
  if [ "$SANDBOX" = workspace-write ]; then
    if ! (cd "$PROJ" && env CODEX_HOME="$CAP/emptyhome" codex sandbox -- true > /dev/null 2>&1); then
      echo "FAIL: the Codex sandbox cannot run here (codex sandbox -- true fails); apply_patch would fail to write and the hook would not fire. No billed call made. Set BBJ_CAPTURE_SANDBOX=danger-full-access only after deciding to relax it for this scratch project." >&2
      echo "sandbox_preflight: FAIL (codex sandbox -- true exits non-zero)" >> "$EVID/README.md"
      return 1
    fi
  fi
  # MCP_OFF without the bypass-only projects override, for the exec line
  set --
  for _n in $LISTED; do set -- "$@" -c "mcp_servers.$_n.enabled=false"; done

  # ---- 1. the billed call
  CODEX_VERSION=$(cd "$PROJ" && env CODEX_HOME="$REAL_CH" codex --version 2> /dev/null)
  _to=
  if command -v timeout > /dev/null 2>&1; then _to="timeout 900"; fi
  rm -f "$EVID/events.jsonl" "$EVID/last-message.txt"
  if [ "$TRUST" = hooks-approval ]; then
    (cd "$PROJ" && env CODEX_HOME="$REAL_CH" $_to codex exec -C "$PROJ" -s "$SANDBOX" --ephemeral --json \
      "$@" -o "$EVID/last-message.txt" "$PROMPT" > "$EVID/events.jsonl" 2> "$CAP.exec.stderr" < /dev/null)
  else
    (cd "$PROJ" && env CODEX_HOME="$REAL_CH" $_to codex exec -C "$PROJ" -s "$SANDBOX" --ephemeral --json \
      --ignore-user-config --dangerously-bypass-hook-trust -c "$_trust_cfg" \
      "$@" -o "$EVID/last-message.txt" "$PROMPT" > "$EVID/events.jsonl" 2> "$CAP.exec.stderr" < /dev/null)
  fi
  EXEC_RC=$?
  restore_config
  _rrc=$?
  cp "$CAP/payload.jsonl" "$EVID/payload.jsonl"
  cp "$CAP/hook-log.txt" "$EVID/hook-log.txt"
  [ -f "$EVID/last-message.txt" ] || : > "$EVID/last-message.txt"

  # ---- event check: item.type counts (completed items when the stream has them)
  python3 -I -c '
import json, sys
allt, done = {}, {}
saw_done = False
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.strip()
    if not line:
        continue
    try:
        e = json.loads(line)
    except Exception:
        continue
    it = e.get("item") if isinstance(e, dict) else None
    if not isinstance(it, dict):
        continue
    t = str(it.get("type"))
    allt[t] = allt.get(t, 0) + 1
    if e.get("type") == "item.completed":
        saw_done = True
        done[t] = done.get(t, 0) + 1
c = done if saw_done else allt
print(",".join("%s=%d" % kv for kv in sorted(c.items())))
print(1 if any("mcp" in t.lower() for t in allt) else 0)' "$EVID/events.jsonl" > "$CAP/events.sum"
  ITEM_TYPES=$(sed -n 1p "$CAP/events.sum")
  MCP_SEEN=$(sed -n 2p "$CAP/events.sum")
  _have_fc=no
  case ",$ITEM_TYPES," in *,file_change=*) _have_fc=yes ;; esac

  # ---- judge
  HOOK_RAN=no
  [ -s "$EVID/payload.jsonl" ] && HOOK_RAN=yes
  HOOK_EXIT=$(grep -o ' rc=[0-9]*' "$EVID/hook-log.txt" | sed 's/ rc=//' | sort -u | tr '\n' ',' | sed 's/,$//')
  NOTICE=no
  grep -q 'hookSpecificOutput' "$EVID/hook-log.txt" && NOTICE=yes
  DELIVERED=$(python3 -I -c '
import re, sys
t = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"PATCH 1(.*?)PATCH 2(.*)", t, re.S)
print("yes" if m and "not compile-checked" in m.group(1) and "NONE" in m.group(2) else "no")' "$EVID/last-message.txt")
  if [ "$HOOK_RAN" = yes ]; then
    KEYS_LINE=$(python3 -I -c '
import json, sys
line = open(sys.argv[1], encoding="utf-8").readline()
pairs = json.loads(line, object_pairs_hook=lambda p: p)
keys = [k for k, _ in pairs]
before = "session_id" in keys and "tool_input" in keys and keys.index("session_id") < keys.index("tool_input")
print(",".join(keys))
print("yes" if before else "no")' "$EVID/payload.jsonl")
    PAYLOAD_KEYS=$(printf '%s\n' "$KEYS_LINE" | sed -n 1p)
    SID_BEFORE=$(printf '%s\n' "$KEYS_LINE" | sed -n 2p)
  else
    PAYLOAD_KEYS=none
    SID_BEFORE=no
    DELIVERED="none (hook did not run: not a delivery result)"
  fi

  {
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "codex_version: $CODEX_VERSION"
    echo "trust_mode: $TRUST"
    echo "hook_ran: $HOOK_RAN"
    echo "hook_exit: ${HOOK_EXIT:-none}"
    echo "notice_printed: $NOTICE"
    echo "codex_delivered: $DELIVERED"
    echo "payload_keys: $PAYLOAD_KEYS"
    echo "session_id_before_tool_input: $SID_BEFORE"
    echo "item_types: $ITEM_TYPES"
    echo "runs: ${BBJ_CAPTURE_RUNS:-1}"
  } > "$EVID/OUTCOME.md"

  {
    echo
    echo "## Event check"
    echo
    echo "item_types: $ITEM_TYPES"
    echo "mcp_tool_call_items: $([ "$MCP_SEEN" = 1 ] && echo YES || echo none)"
    echo "file_change_items: $_have_fc"
    echo
    echo "## Run"
    echo
    echo "trust_mode: $TRUST ($([ "$TRUST" = hooks-approval ] && echo 'hook approved once in /hooks in the scratch project, D-13 default' || echo 'codex exec --dangerously-bypass-hook-trust with --ignore-user-config, one invocation'))"
    echo "codex_version: $CODEX_VERSION"
    echo "sandbox: $SANDBOX"
    echo "exec_exit: $EXEC_RC"
    echo "runs: ${BBJ_CAPTURE_RUNS:-1}"
    echo
    echo "Command (run from <scratch>/proj, CODEX_HOME=$(printf '%s' "$REAL_CH" | tilde), MCP_OFF = ${_off_flags:-none}):"
    echo
    if [ "$TRUST" = hooks-approval ]; then
      echo "    codex exec -C <scratch>/proj -s $SANDBOX --ephemeral --json${_off_flags} -o last-message.txt \"<prompt>\""
    else
      echo "    codex exec -C <scratch>/proj -s $SANDBOX --ephemeral --json --ignore-user-config --dangerously-bypass-hook-trust -c projects.\"<scratch>/proj\".trust_level=\"trusted\"${_off_flags} -o last-message.txt \"<prompt>\""
    fi
    echo
    echo "Prompt: $PROMPT"
    echo
    echo "Hook environment (inside hookwrap.sh): BBJ_CHECK_DEFAULT_HOMES= (empty), BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp, BBJ_CHECK_STATE_DIR=<scratch>/state; BBJ_HOME, BBJHOME, CLAUDE_PLUGIN_OPTION_BBJ_HOME unset. The hook is the installer's copy of plugins/bbj/scripts/bbj-check.sh."
    echo
    echo "## Outcome"
    echo
    echo "hook_ran: $HOOK_RAN, hook_exit: ${HOOK_EXIT:-none}, notice_printed: $NOTICE, codex_delivered: $DELIVERED"
    echo
    echo "### PATCH 1 and PATCH 2 (last-message.txt, verbatim)"
    echo
    sed 's/^/    /' "$EVID/last-message.txt"
    echo
    echo "## Config restore"
    echo
    echo "$RESTORE_RESULT"
  } >> "$EVID/README.md"

  # ---- secret scan with redaction
  _hits=0
  for _f in "$EVID"/*; do
    [ -f "$_f" ] || continue
    if grep -E -q "$SECRET_RE" "$_f"; then
      _hits=$((_hits + 1))
      sed -E "s/$SECRET_RE/<redacted>/g" "$_f" > "$_f.tmp" && mv "$_f.tmp" "$_f"
    fi
  done
  if [ "$_hits" != 0 ]; then
    printf '\nsecret scan: %s file(s) had credential-like or e-mail strings, redacted as <redacted>\n' "$_hits" >> "$EVID/README.md"
  else
    printf '\nsecret scan: nothing found\n' >> "$EVID/README.md"
  fi

  # ---- verdict of the run itself
  _fail=0
  if [ "$_rrc" != 0 ]; then echo "FAIL: $RESTORE_RESULT" >&2; _fail=1; fi
  if [ "$MCP_SEEN" = 1 ]; then
    echo "SECURITY FINDING: events.jsonl holds an MCP tool-call item; do not re-run before the guard is fixed" >&2
    _fail=1
  fi
  if [ "$_have_fc" != yes ]; then echo "FAIL: no file_change item in events.jsonl (schema differs, or the patch was not applied)" >&2; _fail=1; fi
  if [ "$HOOK_RAN" != yes ]; then echo "FAIL: payload.jsonl is empty, the hook did not run (trust or config problem)" >&2; _fail=1; fi
  if [ "$EXEC_RC" != 0 ]; then echo "note: codex exec exited $EXEC_RC" >&2; fi
  rm -rf "$CAP"
  echo "run done: codex_delivered=$DELIVERED; $RESTORE_RESULT; scratch removed"
  return $_fail
}

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
  run) run_mode || exit $? ;;
esac
exit 0
