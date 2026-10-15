#!/bin/sh
# tests/test_discovery.sh -- plan 19-01 Task 3: where the check script finds BBj, and which
# -P list it builds. Every home holds a fake compiler whose logged ARG0 names the home that
# ran; nothing is compiled or run.
# Phase 9 (plan 09-01, PLAT-02, D-12): drive-letter, backslash and space paths through the fake
# cygpath seam FAKE_CYGDRIVE_ROOT.
# Phase 13 (FIX-03, D-16, D-17) arms the backslash gate with a bait file and adds a control.
. "$(dirname "$0")/lib.sh"
mkwork

BASEPATH=/usr/bin:/bin
FAKE_LOG=$WORK/calls.log
export FAKE_LOG
unset FAKE_OUT FAKE_STDOUT FAKE_EXIT

# mkhome NAME [COMPILER-NAME]: $WORK/NAME/bin/<compiler> is a copy of the fake compiler
mkhome() {
  mkdir -p "$WORK/$1/bin"
  cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/$1/bin/${2:-bbjcpl}"
  chmod 755 "$WORK/$1/bin/${2:-bbjcpl}"
}
for h in A B C D E; do mkhome $h; done
mkdir -p "$WORK/emptyhome/bin" "$WORK/proj/sub"
: > "$WORK/proj/sub/f.bbj"
PHYS=$(cd "$WORK" && pwd -P)

# ran EXPECTED NAME: the last logged ARG0 equals EXPECTED
ran() {
  _got=$(sed -n 's/^ARG0 //p' "$FAKE_LOG" | tail -n 1)
  if [ "$_got" = "$1" ]; then gate "$2" ok "ran $1"; else gate "$2" FAIL "ran '$_got', want '$1'"; fi
}
go() {
  : > "$FAKE_LOG"
  run_check "$(claude_payload Write "$WORK/proj/sub/f.bbj" "$WORK/proj")"
}

# order: option > BBJ_HOME > BBJHOME > PATH > default homes
PATH=$WORK/D/bin:$BASEPATH
BBJ_CHECK_DEFAULT_HOMES=$WORK/E
CLAUDE_PLUGIN_OPTION_BBJ_HOME=$WORK/A
BBJ_HOME=$WORK/B
BBJHOME=$WORK/C
export PATH BBJ_CHECK_DEFAULT_HOMES CLAUDE_PLUGIN_OPTION_BBJ_HOME BBJ_HOME BBJHOME
go; ran "$WORK/A/bin/bbjcpl" order_option_first
unset CLAUDE_PLUGIN_OPTION_BBJ_HOME
go; ran "$WORK/B/bin/bbjcpl" order_bbj_home_before_bbjhome
unset BBJ_HOME
go; ran "$WORK/C/bin/bbjcpl" order_bbjhome_before_path
unset BBJHOME
go; ran "$WORK/D/bin/bbjcpl" order_path_before_defaults
PATH=$BASEPATH
export PATH
go; ran "$WORK/E/bin/bbjcpl" order_defaults_last

# a home without a compiler falls through to the next step
CLAUDE_PLUGIN_OPTION_BBJ_HOME=$WORK/emptyhome
BBJ_HOME=$WORK/B
export CLAUDE_PLUGIN_OPTION_BBJ_HOME BBJ_HOME
go; ran "$WORK/B/bin/bbjcpl" empty_home_falls_through
unset CLAUDE_PLUGIN_OPTION_BBJ_HOME BBJ_HOME

# a home given as its own bin directory
BBJ_HOME=$WORK/B/bin
export BBJ_HOME
go; ran "$WORK/B/bin/bbjcpl" home_given_as_bin_dir
unset BBJ_HOME

# a symlink on PATH (absolute and relative target) runs the real path
mkdir -p "$WORK/linkbin" "$WORK/linkbin2"
ln -s "$WORK/C/bin/bbjcpl" "$WORK/linkbin/bbjcpl"
ln -s ../C/bin/bbjcpl "$WORK/linkbin2/bbjcpl"
PATH=$WORK/linkbin:$BASEPATH
export PATH
go; ran "$PHYS/C/bin/bbjcpl" symlink_absolute_resolved
PATH=$WORK/linkbin2:$BASEPATH
export PATH
go; ran "$PHYS/C/bin/bbjcpl" symlink_relative_resolved
PATH=$BASEPATH
export PATH

# a home holding only bbjcplw uses bbjcplw
mkhome W bbjcplw
BBJ_HOME=$WORK/W
export BBJ_HOME
go; ran "$WORK/W/bin/bbjcplw" bbjcplw_only
unset BBJ_HOME

# no route at all: the first call of a session is the no-route notice (exit 0, stderr empty,
# no compiler call), the second call is silent (plan 02-01, D-01)
BBJ_CHECK_DEFAULT_HOMES=
export BBJ_CHECK_DEFAULT_HOMES
fresh_state
go
_ntext=$(notice_text "$WORK/stdout")
_nrc=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ ! -s "$FAKE_LOG" ] && [ "$_nrc" = 0 ] \
  && printf '%s' "$_ntext" | grep -F 'no bbjcpl found' > /dev/null \
  && printf '%s' "$_ntext" | grep -F 'no bbj-ls answering on 127.0.0.1:9' > /dev/null; then
  go
  if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] && [ ! -s "$FAKE_LOG" ]; then
    gate no_route_notice_then_silent ok "first call notice, second call silent"
  else
    gate no_route_notice_then_silent FAIL "second call not silent: exit $RC"
  fi
else
  gate no_route_notice_then_silent FAIL "exit $RC, notice_text $_nrc: $(head -c 160 "$WORK/stdout")"
fi

# an unusable compiler is no verdict: output without a compiler-format line, a crash. With no
# tier-2 route (the closed port) the first call of a session is the no-route notice, reading
# "bbjcpl found but gave no result"; the second call is silent (plan 02-02, D-02, HOOK-03).
# notice_then_silent NAME: run go twice and check exit 0, empty stderr, the notice, then silence
notice_then_silent() {
  fresh_state
  go
  _ntext=$(notice_text "$WORK/stdout")
  _nrc=$?
  if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nrc" = 0 ] \
    && printf '%s' "$_ntext" | grep -F 'bbjcpl found but gave no result' > /dev/null; then
    go
    if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
      gate "$1" ok "first call notice, second call silent"
    else
      gate "$1" FAIL "second call not silent: exit $RC"
    fi
  else
    gate "$1" FAIL "exit $RC, notice_text $_nrc: $(head -c 160 "$WORK/stdout")"
  fi
}
BBJ_HOME=$WORK/A
export BBJ_HOME
printf 'Error: could not find java\n' > "$WORK/javaerr"
FAKE_OUT=$WORK/javaerr
export FAKE_OUT
notice_then_silent unusable_output_notice_then_silent
unset FAKE_OUT
FAKE_EXIT=139
export FAKE_EXIT
notice_then_silent crash_notice_then_silent
unset FAKE_EXIT

# -P list: the file's directory, CLAUDE_PROJECT_DIR and the cwd, deduplicated
pl() {
  # pl NAME EXPECTED-LIST
  _got=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
  if [ "$_got" = "-P$2" ]; then gate "$1" ok "$_got"; else gate "$1" FAIL "got '$_got', want '-P$2'"; fi
}
CLAUDE_PROJECT_DIR=$WORK/proj
export CLAUDE_PROJECT_DIR
go; pl p_list_dedup "$WORK/proj/sub:$WORK/proj"
: > "$FAKE_LOG"
run_check "$(claude_payload Write "$WORK/proj/sub/f.bbj" "$WORK/elsewhere")"
pl p_list_three "$WORK/proj/sub:$WORK/proj:$WORK/elsewhere"
: > "$FAKE_LOG"
run_check "$(claude_payload Write "$WORK/proj/sub/f.bbj" "/odd:dir")"
pl p_list_drops_separator "$WORK/proj/sub:$WORK/proj"
unset CLAUDE_PROJECT_DIR

# Windows branch: a fake cygpath on PATH; -P joined with ";" and every path converted
mkdir -p "$WORK/winbin"
cp "$REPO/tests/fake-bin/cygpath" "$WORK/winbin/cygpath"
chmod 755 "$WORK/winbin/cygpath"
PATH=$WORK/winbin:$BASEPATH
CLAUDE_PROJECT_DIR=$WORK/proj
export PATH CLAUDE_PROJECT_DIR
go
_p=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
_t=$(awk '/^CALL$/ { na = 0; next } /^ARG0 / { print a[na]; next } { a[++na] = $0 }' "$FAKE_LOG" | tail -n 1)
case "$_p" in
  "-PW:$WORK/proj/sub;W:$WORK/proj") gate windows_p_list ok "$_p" ;;
  *) gate windows_p_list FAIL "$_p" ;;
esac
case "$_t" in
  "W:$WORK/proj/sub/f.bbj") gate windows_target ok "$_t" ;;
  *) gate windows_target FAIL "$_t" ;;
esac

# Windows branch with drive-letter input (phase 9, plan 09-01, PLAT-02, D-04, D-12): the fake
# cygpath maps C:\... below $WORK/drive (FAKE_CYGDRIVE_ROOT)
mkdir -p "$WORK/drive/bbx/bin" "$WORK/drive/Users/x/bbj test/sub"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/drive/bbx/bin/bbjcpl.exe"
chmod 755 "$WORK/drive/bbx/bin/bbjcpl.exe"
: > "$WORK/drive/Users/x/bbj test/sub/f.bbj"
unset CLAUDE_PROJECT_DIR
FAKE_CYGDRIVE_ROOT=$WORK/drive
export FAKE_CYGDRIVE_ROOT
CLAUDE_PLUGIN_OPTION_BBJ_HOME='C:\bbx'
export CLAUDE_PLUGIN_OPTION_BBJ_HOME

# wcall FILE CWD: a Claude Code Write of FILE with payload cwd CWD, fresh call log
wcall() {
  : > "$FAKE_LOG"
  run_check "$(claude_payload Write "$1" "$2")"
}
# wtarget: the file argument (last argument) of the last logged compiler call
wtarget() {
  awk '/^CALL$/ { na = 0; next } /^ARG0 / { print a[na]; next } { a[++na] = $0 }' "$FAKE_LOG" | tail -n 1
}
WANT_T="W:$WORK/drive/Users/x/bbj test/sub/f.bbj"
WANT_P="-PW:$WORK/drive/Users/x/bbj test/sub;W:$WORK/drive/Users/x/bbj test"

wcall 'C:\Users\x\bbj test\sub\f.bbj' 'C:\Users\x\bbj test'
ran "$WORK/drive/bbx/bin/bbjcpl.exe" windows_drive_home
_t=$(wtarget)
_n=$(grep -c '^CALL$' "$FAKE_LOG")
if [ "$_t" = "$WANT_T" ] && [ "$_n" = 1 ]; then
  gate windows_drive_file ok "$_t"
else
  gate windows_drive_file FAIL "target '$_t', want '$WANT_T'; calls $_n, want 1"
fi
_n=$(grep -c '^-P' "$FAKE_LOG")
_p=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
if [ "$_n" = 1 ] && [ "$_p" = "$WANT_P" ]; then
  gate windows_space_p_list ok "$_p"
else
  gate windows_space_p_list FAIL "got $_n line(s), last '$_p', want '$WANT_P'"
fi

# forward-slash drive paths give the same compiler call
wcall 'C:/Users/x/bbj test/sub/f.bbj' 'C:/Users/x/bbj test'
_t=$(wtarget)
_n=$(grep -c '^CALL$' "$FAKE_LOG")
_p=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
if [ "$_n" = 1 ] && [ "$_t" = "$WANT_T" ] && [ "$_p" = "$WANT_P" ]; then
  gate windows_forward_slash_file ok "$_t"
else
  gate windows_forward_slash_file FAIL "calls $_n, target '$_t', -P '$_p'; want '$WANT_T', '$WANT_P'"
fi

# -P edges: empty entries are skipped (an exported empty project directory, an empty cwd)
CLAUDE_PROJECT_DIR=
export CLAUDE_PROJECT_DIR
wcall 'C:\Users\x\bbj test\sub\f.bbj' ''
_p=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
if [ "$_p" = "-PW:$WORK/drive/Users/x/bbj test/sub" ]; then
  gate windows_p_list_empty_entries ok "$_p"
else
  gate windows_p_list_empty_entries FAIL "got '$_p', want '-PW:$WORK/drive/Users/x/bbj test/sub'"
fi

# -P edges: the same directory in two forms (forward slashes, then backslashes) appears once
CLAUDE_PROJECT_DIR='C:/Users/x/bbj test'
export CLAUDE_PROJECT_DIR
wcall 'C:\Users\x\bbj test\sub\f.bbj' 'C:\Users\x\bbj test'
_p=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
if [ "$_p" = "$WANT_P" ]; then
  gate windows_p_list_dedup_mixed ok "$_p"
else
  gate windows_p_list_dedup_mixed FAIL "got '$_p', want '$WANT_P'"
fi

# -P edges: order is the file's directory, the project directory, the cwd
CLAUDE_PROJECT_DIR='C:\Users\x\bbj test'
export CLAUDE_PROJECT_DIR
wcall 'C:\Users\x\bbj test\sub\f.bbj' 'C:\Users\x\other'
_p=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
_want="-PW:$WORK/drive/Users/x/bbj test/sub;W:$WORK/drive/Users/x/bbj test;W:$WORK/drive/Users/x/other"
if [ "$_p" = "$_want" ]; then
  gate windows_p_list_order ok "$_p"
else
  gate windows_p_list_order FAIL "got '$_p', want '$_want'"
fi

# Codex discovery source (D-04): BBJ_HOME, no plugin option; relative and absolute patch headers
unset CLAUDE_PLUGIN_OPTION_BBJ_HOME CLAUDE_PROJECT_DIR
BBJ_HOME='C:\bbx'
export BBJ_HOME
# wpatch CWD HEADER-PATH: an apply_patch Add File of HEADER-PATH with payload cwd CWD
wpatch() {
  : > "$FAKE_LOG"
  _pt=$(printf '%s\n' '*** Begin Patch' "*** Add File: $2" '+print "a"' '*** End Patch')
  run_check "$(codex_payload "$1" "$_pt")"
}
# wpatch_gate NAME CWD HEADER-PATH: one call, the drive-letter-home compiler, the converted file
wpatch_gate() {
  wpatch "$2" "$3"
  _n=$(grep -c '^CALL$' "$FAKE_LOG")
  _a=$(sed -n 's/^ARG0 //p' "$FAKE_LOG" | tail -n 1)
  _t=$(wtarget)
  if [ "$_n" = 1 ] && [ "$_a" = "$WORK/drive/bbx/bin/bbjcpl.exe" ] && [ "$_t" = "$WANT_T" ]; then
    gate "$1" ok "$_t"
  else
    gate "$1" FAIL "calls $_n, ARG0 '$_a', target '$_t'; want 1, '$WORK/drive/bbx/bin/bbjcpl.exe', '$WANT_T'"
  fi
}
wpatch_gate windows_codex_relative 'C:\Users\x\bbj test' 'sub/f.bbj'
wpatch_gate windows_codex_absolute 'C:\Users\x\bbj test' 'C:\Users\x\bbj test\sub\f.bbj'
# Phase 9, W-3 (D-12, RESEARCH Pitfall 2): Codex on Windows may send a relative header with
# backslashes and the verbatim prefix. Both must give the one call the plain forms give; a ".."
# segment that only a backslash hides must still leave the workspace and be skipped.
wpatch_gate windows_codex_backslash_relative 'C:\Users\x\bbj test' 'sub\f.bbj'
wpatch_gate windows_codex_verbatim_prefix '\\?\C:\Users\x\bbj test' '\\?\C:\Users\x\bbj test\sub\f.bbj'
# Phase 13 (FIX-03, D-16; review WR-03 of phase 9): a real file inside the workspace carries the
# literal name sub\..\..\x.bbj. Without the backslash conversion the hook would find that file and
# compile it, so the gate fails; with the ".." check gone the converted path resolves to the
# outside file x.bbj, which is compiled, so the gate fails then too. The old gate passed with the
# conversion removed because the unconverted name did not exist.
BAIT=$WORK'/drive/Users/x/bbj test/sub\..\..\x.bbj'
: > "$WORK/drive/Users/x/x.bbj"
if ( : > "$BAIT" ) 2> /dev/null && [ -f "$BAIT" ]; then
  wpatch 'C:\Users\x\bbj test' 'sub\..\..\x.bbj'
  _n=$(grep -c '^CALL$' "$FAKE_LOG")
  if [ "$_n" = 0 ] && [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
    gate windows_codex_backslash_dotdot_skipped ok "the bait sub\\..\\..\\x.bbj inside the workspace and x.bbj outside are both left alone: no compiler call, exit 0, silent"
  else
    gate windows_codex_backslash_dotdot_skipped FAIL "calls $_n, exit $RC, stdout $(wc -c < "$WORK/stdout") byte(s), stderr $(wc -c < "$WORK/stderr") byte(s)"
  fi
elif [ "${CI:-}" = true ]; then
  gate windows_codex_backslash_dotdot_skipped FAIL "this file system cannot hold a file name with a backslash"
else
  gate windows_codex_backslash_dotdot_skipped skip "this file system cannot hold a file name with a backslash"
fi
unset BBJ_HOME

unset FAKE_CYGDRIVE_ROOT CLAUDE_PLUGIN_OPTION_BBJ_HOME BBJ_HOME CLAUDE_PROJECT_DIR
PATH=$BASEPATH
export PATH

finish
