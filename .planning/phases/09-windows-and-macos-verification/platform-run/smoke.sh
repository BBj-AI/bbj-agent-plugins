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
# Usage: sh smoke.sh claude
#   claude is the only subcommand so far; the others are added by Task 2 of the plan.
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

# mkproj DIR: DIR/sub/bad.bbj (the real compiler reports "error at line 10 (1)") and
# DIR/sub/clean.bbj; the two fixtures of tests/test_real_compiler.sh.
mkproj() {
  mkdir -p "$1/sub" || return 1
  printf '%s\n' 'print "a"   rem same line' > "$1/sub/bad.bbj"
  printf '%s\n' 'print "a"; rem ok' > "$1/sub/clean.bbj"
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
    echo
  } | scrub
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

usage() {
  echo 'usage: sh smoke.sh claude' >&2
  exit 2
}

[ $# -ge 1 ] || usage
case "$1" in
  claude) sub_claude ;;
  *) usage ;;
esac
exit 0
