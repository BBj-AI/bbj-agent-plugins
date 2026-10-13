#!/bin/sh
# .planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh -- plan 09-02 smoke driver.
# Feeds the shipped hook (plugins/bbj/scripts/bbj-check.sh) the payloads Claude Code and Codex send,
# against whatever BBj compiler the machine has, and prints one result block per case as key: value
# lines the owner pastes back into the phase record. Run by the owner on Windows (Git Bash) and on
# macOS (/bin/sh). Evidence for the record, never CI: CI has no BBj, and nothing here is a gate.
#
# Decisions: D-01 (one driver, one block per case, the compiler call read from a second run of the
# unmodified hook under sh -x), D-04 (the discovery source differs by client and is named in the
# header), D-06 (the header shows whether an installed copy is the checkout's), D-07 (every printed
# line is scrubbed), D-14 (tier 2 over loopback), D-16 (the no-route notice and its claim file).
#
# Safety rules (PLAT-01, PLAT-02, threats T-09-04 to T-09-08):
#   - never runs BBj: a compiler is reached only through the shipped hook, which passes -N on every
#     call; this file has no compiler, bbj or curl command of its own;
#   - not CI: nothing here is a test and nothing in tests/ runs it;
#   - writes only under its own temp directory (removed on exit);
#   - every printed line goes through scrub: the home directory, the checkout and the temp directory
#     are replaced in their POSIX, backslash and forward-slash forms; paths reach awk through the
#     environment, never through a command-line variable, which would read the backslash sequences
#     of C:\Users as escapes.
#
# Usage: sh smoke.sh claude | codex | tier2 | noroute | emit DIR
#   claude    Claude Code Write and Edit payloads in the client's path form, a project path with a
#             space, and the hooks.json command string run with the plugin root in each form
#             (PLAT-01, PLAT-02); discovery source: the bbj_home option (D-04)
#   codex     Codex apply_patch payloads in the path forms Codex might send (PLAT-03, PLAT-05);
#             discovery source: BBJ_HOME, or PATH when no home is given (D-04)
#   tier2     every compiler route off, loopback bbj-ls as the only route: outcome feedback, silent,
#             notice or other for a bad and a clean file (PLAT-04, D-14)
#   noroute   every route off: the once-per-session notice, its claim file, and that a second call
#             stays silent (D-16)
#   emit DIR  writes claude-bad.json, claude-clean.json and codex-bad.json (and the files they name)
#             into DIR for the PowerShell probes of the Windows runbook; refuses a DIR that exists
#             and is not empty
#
# Inputs (environment):
#   SMOKE_BBJ_HOME   BBj installation directory given to the hook (default: the plugin option
#                    CLAUDE_PLUGIN_OPTION_BBJ_HOME, then BBJ_HOME of the caller, else PATH)
#   SMOKE_ROOT       plugin root whose scripts/bbj-check.sh is run (default: the checkout's
#                    plugins/bbj; point it at the Codex plugin cache to test the installed copy)
#   SMOKE_LOCAL_URL  loopback bbj-ls URL for tier2 (default http://127.0.0.1:5009/mcp)
#   SHELL_UNDER_TEST the shell that runs the hook (default sh), as for tests/lib.sh
#
# Exit codes: 0 the subcommand ran (whatever the hook returned), 1 no hook script at the plugin
# root, 2 usage error.

CHECKOUT=$(cd "$(dirname "$0")/../../../.." && pwd)

# tests/lib.sh clears the caller's BBj variables when it is sourced: read them first (D-04).
KEEP_HOME=${SMOKE_BBJ_HOME:-${CLAUDE_PLUGIN_OPTION_BBJ_HOME:-${BBJ_HOME:-}}}
if [ -n "${SMOKE_BBJ_HOME:-}" ]; then
  DISC_SRC=SMOKE_BBJ_HOME
elif [ -n "${CLAUDE_PLUGIN_OPTION_BBJ_HOME:-}" ]; then
  DISC_SRC='bbj_home option'
elif [ -n "${BBJ_HOME:-}" ]; then
  DISC_SRC=BBJ_HOME
else
  DISC_SRC=PATH
fi

ROOT=${SMOKE_ROOT:-$CHECKOUT/plugins/bbj}
SCRIPT=$ROOT/scripts/bbj-check.sh
if [ ! -f "$SCRIPT" ]; then
  printf 'smoke.sh: no hook script at %s\n' "$SCRIPT" >&2
  exit 1
fi

. "$CHECKOUT/tests/lib.sh"
mkwork

WIN=0
if command -v cygpath > /dev/null 2>&1; then WIN=1; fi

# w PATH: the client form (backslashes under Git for Windows); m PATH: the C:/ form.
w() {
  if [ "$WIN" = 1 ]; then cygpath -w "$1"; else printf '%s' "$1"; fi
}
m() {
  if [ "$WIN" = 1 ]; then cygpath -m "$1"; else printf '%s' "$1"; fi
}

# kv KEY VALUE
kv() {
  printf '%s: %s\n' "$1" "$2"
}

# The version string of the shell that runs the hook ("unknown" when it is not bash). Dash prints
# its xtrace arguments unquoted, so the derived keys are cut only when this is not "unknown".
HSV=$($SHELL_UNDER_TEST -c 'printf "%s" "${BASH_VERSION:-unknown}"' 2> /dev/null)
[ -n "$HSV" ] || HSV=unknown

# The path forms scrub needs, computed once. HOME in all three forms; the BBj home is protected
# from scrubbing unless it lies under HOME (then its home part must go: D-07).
SC_H1=$HOME
SC_H2=$(w "$HOME")
SC_H3=$(m "$HOME")
SC_C1=$CHECKOUT
SC_C2=$(w "$CHECKOUT")
SC_C3=$(m "$CHECKOUT")
SC_W1=$WORK
SC_W2=$(w "$WORK")
SC_W3=$(m "$WORK")
SC_KEEP=$KEEP_HOME
if [ -n "$KEEP_HOME" ]; then
  case "$KEEP_HOME" in
    "$SC_H1"*|"$SC_H2"*|"$SC_H3"*) SC_KEEP= ;;
  esac
fi

# scrub: stdin to stdout. A literal-substring replace (index and substr, no regex), in this order:
# the protected BBj home to a sentinel, the checkout, the temp directory, the home directory, then
# the sentinel back to the BBj home. An empty or one-character form (a HOME of "/") is skipped.
scrub() {
  S_H1=$SC_H1 S_H2=$SC_H2 S_H3=$SC_H3 S_C1=$SC_C1 S_C2=$SC_C2 S_C3=$SC_C3 \
  S_W1=$SC_W1 S_W2=$SC_W2 S_W3=$SC_W3 S_KEEP=$SC_KEEP \
  awk '
    function rep(s, from, to,    i, out) {
      if (length(from) < 2) return s
      out = ""
      while ((i = index(s, from)) > 0) {
        out = out substr(s, 1, i - 1) to
        s = substr(s, i + length(from))
      }
      return out s
    }
    {
      l = $0
      l = rep(l, ENVIRON["S_KEEP"], "@@KEEP@@")
      l = rep(l, ENVIRON["S_C1"], "<checkout>")
      l = rep(l, ENVIRON["S_C2"], "<checkout>")
      l = rep(l, ENVIRON["S_C3"], "<checkout>")
      l = rep(l, ENVIRON["S_W1"], "<work>")
      l = rep(l, ENVIRON["S_W2"], "<work>")
      l = rep(l, ENVIRON["S_W3"], "<work>")
      l = rep(l, ENVIRON["S_H1"], "<home>")
      l = rep(l, ENVIRON["S_H2"], "<home>")
      l = rep(l, ENVIRON["S_H3"], "<home>")
      l = rep(l, "@@KEEP@@", ENVIRON["S_KEEP"])
      print l
    }'
}

# hook_cmd: the command string of $ROOT/hooks/hooks.json (the line whose key is exactly "command",
# not commandWindows), with each \" turned back into ". Prints nothing when the file is absent.
hook_cmd() {
  [ -f "$ROOT/hooks/hooks.json" ] || return 0
  sed -n -e 's/^[[:space:]]*"command"[[:space:]]*:[[:space:]]*"\(.*\)"[[:space:]]*,\{0,1\}[[:space:]]*$/\1/p' \
    "$ROOT/hooks/hooks.json" | head -n 1 | sed -e 's/\\"/"/g'
}

# header NAME: the keys that say what was run and on what, then a blank line (D-04, D-06, D-07).
header() {
  _cmt=$(git -C "$CHECKOUT" rev-parse --short HEAD 2> /dev/null)
  [ -n "$_cmt" ] || _cmt=unknown
  if [ "$WIN" = 1 ]; then _cyg=yes; else _cyg=no; fi
  _ck=$(cksum < "$SCRIPT" | awk '{ print $1 }')
  if cmp -s "$SCRIPT" "$CHECKOUT/plugins/bbj/scripts/bbj-check.sh"; then _same=yes; else _same=no; fi
  if [ ! -f "$ROOT/hooks/hooks.json" ]; then
    _hsame=absent
  elif cmp -s "$ROOT/hooks/hooks.json" "$CHECKOUT/plugins/bbj/hooks/hooks.json"; then
    _hsame=yes
  else
    _hsame=no
  fi
  {
    kv smoke "$1"
    kv date "$(date +%Y-%m-%d)"
    kv platform "$(uname -sr)"
    kv shell "${BASH_VERSION:-unknown}"
    kv hook_shell_version "$HSV"
    kv cygpath "$_cyg"
    kv checkout_commit "$_cmt"
    kv hook_script "$SCRIPT"
    kv hook_script_cksum "$_ck"
    kv script_identical_to_checkout "$_same"
    kv hooks_json_identical_to_checkout "$_hsame"
    kv hooks_json_command "$(hook_cmd)"
    kv bbj_home "${KEEP_HOME:-none}"
    kv discovery_source "$DISC_SRC"
    echo
  } | scrub
}

# The two fixtures of tests/test_real_compiler.sh: the real compiler reports "error at line 10 (1)"
# for the first and nothing for the second.
BAD_LINE='print "a"   rem same line'
CLEAN_LINE='print "a"; rem ok'

# mkproj DIR: DIR/sub/bad.bbj and DIR/sub/clean.bbj
mkproj() {
  mkdir -p "$1/sub" || return 1
  printf '%s\n' "$BAD_LINE" > "$1/sub/bad.bbj"
  printf '%s\n' "$CLEAN_LINE" > "$1/sub/clean.bbj"
}

# ptext HEADER-PATH [CONTENT]: an apply_patch text that adds HEADER-PATH with one line of CONTENT
# (default the bad line); lines joined by newlines, no trailing newline.
ptext() {
  printf '*** Begin Patch\n*** Add File: %s\n+%s\n*** End Patch' "$1" "${2-$BAD_LINE}"
}

# tokens: stdin is one xtrace line; prints one argument per line. Single quotes group (and are
# dropped), a backslash outside quotes takes the next character literally.
tokens() {
  awk '
    {
      line = $0; n = length(line); tok = ""; has = 0; q = 0
      for (i = 1; i <= n; i++) {
        c = substr(line, i, 1)
        if (q) { if (c == "\047") q = 0; else tok = tok c; continue }
        if (c == "\047") { q = 1; has = 1; continue }
        if (c == "\\") { i++; tok = tok substr(line, i, 1); has = 1; continue }
        if (c == " ") { if (has) { print tok; tok = ""; has = 0 }; continue }
        tok = tok c; has = 1
      }
      if (has) print tok
    }'
}

# CASE_NOTE (a note line for the next block) and WANT_OUTCOME (1 adds the tier-2 outcome key) are
# globals of case_run; case_run resets CASE_NOTE after it prints it.
CASE_NOTE=
WANT_OUTCOME=0

# case_run NAME FILE-AS-SENT CWD-AS-SENT PAYLOAD: one result block (D-01). The first run gives the
# verdict (exit code, stdout, stderr). The second run of the same unmodified hook under sh -x only
# reads the compiler call from the trace, so the compiler path is the real discovery result.
case_run() {
  run_check "$4"
  _first=$(head -n 1 "$WORK/stderr" | tr -d '\r')
  PS4='+TRACE ' $SHELL_UNDER_TEST -x "$SCRIPT" < "$WORK/payload" > /dev/null 2> "$WORK/trace"
  _call=$(grep -e ' -t -N -X' "$WORK/trace" | tail -n 1 | sed -e 's/^+*TRACE //')
  case "$_call" in
    *' -N '*) _dn=yes ;;
    *) _dn=no ;;
  esac
  _bytes=$(wc -c < "$WORK/stdout" | tr -d ' ')
  _ebytes=$(wc -c < "$WORK/stderr" | tr -d ' ')
  if [ "$RC" = 2 ] && [ "${_first#bbj-local reported}" != "$_first" ]; then
    _out=feedback
  elif [ "$RC" = 0 ] && [ "$_bytes" = 0 ] && [ "$_ebytes" = 0 ]; then
    _out=silent
  elif [ "$RC" = 0 ] && [ "$_bytes" != 0 ]; then
    _out=notice
  else
    _out=other
  fi
  {
    kv case "$1"
    kv file_as_sent "$2"
    kv cwd_as_sent "$3"
    kv compiler_call "${_call:-none}"
    if [ -z "$_call" ]; then
      kv derived 'none (no compiler call)'
    elif [ "$HSV" = unknown ]; then
      kv derived 'none (unquoted trace)'
    else
      printf '%s\n' "$_call" | tokens > "$WORK/tok"
      if [ "$(sed -n '2p' "$WORK/tok")" = -t ] && [ "$(sed -n '3p' "$WORK/tok")" = -N ] \
        && [ "$(sed -n '4p' "$WORK/tok")" = -X ]; then
        kv compiler "$(sed -n '1p' "$WORK/tok")"
        _t5=$(sed -n '5p' "$WORK/tok")
        case "$_t5" in
          -P*)
            kv p_list "${_t5#-P}"
            kv target "$(sed -n '6p' "$WORK/tok")"
            ;;
          *) kv target "$_t5" ;;
        esac
      else
        kv derived 'none (unquoted trace)'
      fi
    fi
    kv dash_n "$_dn"
    kv exit "$RC"
    kv stdout_bytes "$_bytes"
    kv first_feedback_line "${_first:-none}"
    if [ "$WANT_OUTCOME" = 1 ]; then kv outcome "$_out"; fi
    if [ -n "$CASE_NOTE" ]; then kv note "$CASE_NOTE"; fi
    echo
  } | scrub
  CASE_NOTE=
  cp "$WORK/payload" "$WORK/payload.$1"
}

# root_form NAME ROOT-AS-SET: runs the hooks.json command string itself with CLAUDE_PLUGIN_ROOT set
# to ROOT-AS-SET, on the payload of claude_write_bad (does sh accept this form of the root?).
root_form() {
  _cmd=$(hook_cmd)
  CLAUDE_PLUGIN_ROOT=$2 sh -c "$_cmd" < "$WORK/payload.claude_write_bad" > "$WORK/rf_out" 2> "$WORK/rf_err"
  _rc=$?
  {
    kv case "$1"
    kv root_as_set "$2"
    kv exit "$_rc"
    _rf=$(head -n 1 "$WORK/rf_err" | tr -d '\r')
    kv first_feedback_line "${_rf:-none}"
    echo
  } | scrub
}

# claude: Claude Code Write and Edit payloads in the client's path form (PLAT-01, PLAT-02).
sub_claude() {
  header claude
  mkproj "$WORK/proj" || return 1
  mkproj "$WORK/bbj test" || return 1
  # Claude Code's discovery source is the bbj_home option (D-04)
  if [ -n "$KEEP_HOME" ]; then
    CLAUDE_PLUGIN_OPTION_BBJ_HOME=$KEEP_HOME
    export CLAUDE_PLUGIN_OPTION_BBJ_HOME
  fi
  # Claude Code substitutes the plugin root with forward slashes on Windows
  CLAUDE_PLUGIN_ROOT=$(m "$ROOT")
  export CLAUDE_PLUGIN_ROOT
  unset CLAUDE_PROJECT_DIR

  _p=$WORK/proj
  _wf=$(w "$_p/sub/bad.bbj")
  _wc=$(w "$_p")
  case_run claude_write_bad "$_wf" "$_wc" "$(claude_payload Write "$_wf" "$_wc")"
  case_run claude_edit_bad "$_wf" "$_wc" "$(claude_payload Edit "$_wf" "$_wc")"
  _wf=$(w "$_p/sub/clean.bbj")
  case_run claude_write_clean "$_wf" "$_wc" "$(claude_payload Write "$_wf" "$_wc")"

  _p="$WORK/bbj test"
  _wc=$(w "$_p")
  _wf=$(w "$_p/sub/bad.bbj")
  case_run claude_space_write_bad "$_wf" "$_wc" "$(claude_payload Write "$_wf" "$_wc")"
  _wf=$(w "$_p/sub/clean.bbj")
  case_run claude_space_write_clean "$_wf" "$_wc" "$(claude_payload Write "$_wf" "$_wc")"

  if [ "$WIN" = 1 ]; then
    _p=$WORK/proj
    _mf=$(m "$_p/sub/bad.bbj")
    _mc=$(m "$_p")
    case_run claude_write_bad_fwd "$_mf" "$_mc" "$(claude_payload Write "$_mf" "$_mc")"
  fi

  # the hooks.json command string itself, with the root in each form
  if [ -z "$(hook_cmd)" ]; then
    echo 'root_forms: not run (no hooks.json beside the script)'
    echo
  else
    root_form root_form_forward "$(m "$ROOT")"
    if [ "$WIN" = 1 ]; then root_form root_form_backslash "$(w "$ROOT")"; fi
  fi
}

# codex: Codex apply_patch payloads (PLAT-03, PLAT-05). What Codex sends on Windows is undocumented
# (RESEARCH Pitfall 2), so every plausible path form is tried and the hook's answer is shown.
sub_codex() {
  header codex
  mkproj "$WORK/cx" || return 1
  unset CLAUDE_PLUGIN_OPTION_BBJ_HOME
  # Codex's discovery source is BBJ_HOME, or PATH when no home is given (D-04)
  if [ -n "$KEEP_HOME" ]; then
    BBJ_HOME=$KEEP_HOME
    export BBJ_HOME
  fi
  # the Codex plugin route sets CLAUDE_PLUGIN_ROOT for its hook
  CLAUDE_PLUGIN_ROOT=$ROOT
  export CLAUDE_PLUGIN_ROOT
  unset CLAUDE_PROJECT_DIR

  _cx=$WORK/cx
  if [ "$WIN" = 1 ]; then
    _hp=$(w "$_cx/sub/bad.bbj")
    _wc=$(w "$_cx")
    case_run codex_abs_backslash "$_hp" "$_wc" "$(codex_payload "$_wc" "$(ptext "$_hp")")"
    _hp=$(m "$_cx/sub/bad.bbj")
    _mc=$(m "$_cx")
    case_run codex_abs_fwd "$_hp" "$_mc" "$(codex_payload "$_mc" "$(ptext "$_hp")")"
    _hp='sub/bad.bbj'
    case_run codex_rel_fwd "$_hp" "$_wc" "$(codex_payload "$_wc" "$(ptext "$_hp")")"
    _hp='sub\bad.bbj'
    case_run codex_rel_backslash "$_hp" "$_wc" "$(codex_payload "$_wc" "$(ptext "$_hp")")"
    _vc='\\?\'$_wc
    _hp='\\?\'$(w "$_cx/sub/bad.bbj")
    CASE_NOTE='informational (RESEARCH Pitfall 2)'
    case_run codex_verbatim "$_hp" "$_vc" "$(codex_payload "$_vc" "$(ptext "$_hp")")"
    _hp='sub/clean.bbj'
    case_run codex_clean "$_hp" "$_wc" "$(codex_payload "$_wc" "$(ptext "$_hp" "$CLEAN_LINE")")"
  else
    _hp=$_cx/sub/bad.bbj
    case_run codex_abs "$_hp" "$_cx" "$(codex_payload "$_cx" "$(ptext "$_hp")")"
    _hp='sub/bad.bbj'
    case_run codex_rel "$_hp" "$_cx" "$(codex_payload "$_cx" "$(ptext "$_hp")")"
    _hp='sub/clean.bbj'
    case_run codex_clean "$_hp" "$_cx" "$(codex_payload "$_cx" "$(ptext "$_hp" "$CLEAN_LINE")")"
  fi
}

# no_route_setup NAME: the set-up tier2 and noroute share. Every compiler route off: the caller's
# BBj variables are cleared, the PATH loses every directory that holds a compiler (a farm of links,
# RESEARCH Pitfall 8). Returns 1 after printing a "not run" line when the farm cannot be built (an
# empty PATH would make the run meaningless) or a compiler is still found.
no_route_setup() {
  no_compiler_env
  _np=$(no_compiler_path 2> "$WORK/np_err")
  if [ $? -ne 0 ]; then
    printf '%s: not run (cannot build the PATH farm: %s)\n' "$1" "$(head -n 1 "$WORK/np_err")" | scrub
    return 1
  fi
  PATH=$_np
  export PATH
  if command -v bbjcpl > /dev/null 2>&1 || command -v bbjcplw > /dev/null 2>&1; then
    printf '%s: not run (a compiler is still on PATH)\n' "$1"
    return 1
  fi
  CLAUDE_PLUGIN_ROOT=$(m "$ROOT")
  export CLAUDE_PLUGIN_ROOT
  unset CLAUDE_PROJECT_DIR
  kv bbj_home_used 'none (every compiler route is off for this subcommand)' | scrub
  return 0
}

# tier2: the loopback bbj-ls check as the only route (D-14, PLAT-04).
sub_tier2() {
  header tier2
  no_route_setup tier2 || return 0
  BBJ_LOCAL_MCP_URL=${SMOKE_LOCAL_URL:-http://127.0.0.1:5009/mcp}
  export BBJ_LOCAL_MCP_URL
  {
    kv curl "$(command -v curl 2> /dev/null || echo none)"
    kv bbj_local_url "$BBJ_LOCAL_MCP_URL"
    echo
  } | scrub
  mkproj "$WORK/t2" || return 1
  WANT_OUTCOME=1
  _wc=$(w "$WORK/t2")
  _wf=$(w "$WORK/t2/sub/bad.bbj")
  fresh_state
  case_run tier2_bad "$_wf" "$_wc" "$(claude_payload Write "$_wf" "$_wc")"
  _wf=$(w "$WORK/t2/sub/clean.bbj")
  fresh_state
  case_run tier2_clean "$_wf" "$_wc" "$(claude_payload Write "$_wf" "$_wc")"
  WANT_OUTCOME=0
}

# noroute: no route at all; the notice appears on the first call of a session only, and leaves
# a claim file under the state directory (D-16).
sub_noroute() {
  header noroute
  no_route_setup noroute || return 0
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
  export BBJ_LOCAL_MCP_URL
  fresh_state
  mkproj "$WORK/nr" || return 1
  _wc=$(w "$WORK/nr")
  _wf=$(w "$WORK/nr/sub/bad.bbj")
  _pl=$(claude_payload Write "$_wf" "$_wc")
  _pfx='{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"'
  {
    kv state_dir "$(w "$BBJ_CHECK_STATE_DIR")"
    run_check "$_pl"
    kv exit_first "$RC"
    _line=$(head -n 1 "$WORK/stdout")
    _nl=$(wc -l < "$WORK/stdout" | tr -d ' ')
    if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nl" = 1 ] && [ "${_line#"$_pfx"}" != "$_line" ]; then
      kv notice_first present
    else
      kv notice_first absent
    fi
    _ctx=${_line#"$_pfx"}
    kv notice_excerpt "$(printf '%s' "$_ctx" | head -c 160)"
    _claim=absent
    for _c in "$BBJ_CHECK_STATE_DIR"/bbj-check-noroute-*/claim; do
      if [ -f "$_c" ]; then _claim=present; fi
    done
    kv claim_file "$_claim"
    run_check "$_pl"
    kv exit_second "$RC"
    if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
      kv notice_second absent
    else
      kv notice_second present
    fi
    echo
  } | scrub
}

# emit DIR: payload files for the PowerShell probes (input of the Windows runbook).
sub_emit() {
  if [ -z "${1:-}" ]; then usage; fi
  if [ -e "$1" ] && { [ ! -d "$1" ] || [ -n "$(ls -A "$1" 2> /dev/null)" ]; }; then
    printf 'emit: refused (%s is not empty)\n' "$1" | scrub >&2
    exit 2
  fi
  mkdir -p "$1" || exit 2
  _d=$(cd "$1" && pwd)
  mkproj "$_d/proj" || return 1
  header emit
  _wc=$(w "$_d/proj")
  _wf=$(w "$_d/proj/sub/bad.bbj")
  claude_payload Write "$_wf" "$_wc" > "$_d/claude-bad.json"
  _wf=$(w "$_d/proj/sub/clean.bbj")
  claude_payload Write "$_wf" "$_wc" > "$_d/claude-clean.json"
  codex_payload "$_wc" "$(ptext 'sub/bad.bbj')" > "$_d/codex-bad.json"
  {
    kv emit_dir "$(w "$_d")"
    kv emit_file claude-bad.json
    kv emit_file claude-clean.json
    kv emit_file codex-bad.json
    kv probe_script_forward "$(m "$SCRIPT")"
    kv probe_script_backslash "$(w "$SCRIPT")"
    echo
  } | scrub
}

usage() {
  echo 'usage: sh smoke.sh claude | codex | tier2 | noroute | emit DIR' >&2
  exit 2
}

[ $# -ge 1 ] || usage
case "$1" in
  claude) sub_claude ;;
  codex) sub_codex ;;
  tier2) sub_tier2 ;;
  noroute) sub_noroute ;;
  emit) sub_emit "${2:-}" ;;
  *) usage ;;
esac
exit 0
