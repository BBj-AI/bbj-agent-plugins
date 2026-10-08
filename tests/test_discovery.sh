#!/bin/sh
# tests/test_discovery.sh -- plan 19-01 Task 3: where the check script finds BBj, and which
# -P list it builds. Every home holds a fake compiler whose logged ARG0 names the home that
# ran; nothing is compiled or run.
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

# no route at all: exit 0, no output, no compiler call
BBJ_CHECK_DEFAULT_HOMES=
export BBJ_CHECK_DEFAULT_HOMES
go
if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] && [ ! -s "$FAKE_LOG" ]; then
  gate no_route_silent ok "exit 0, no output"
else
  gate no_route_silent FAIL "exit $RC"
fi

# an unusable compiler is no verdict: output without a compiler-format line, a crash
BBJ_HOME=$WORK/A
export BBJ_HOME
printf 'Error: could not find java\n' > "$WORK/javaerr"
FAKE_OUT=$WORK/javaerr
export FAKE_OUT
go
if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
  gate unusable_output_silent ok "exit 0, no output"
else
  gate unusable_output_silent FAIL "exit $RC"
fi
unset FAKE_OUT
FAKE_EXIT=139
export FAKE_EXIT
go
if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
  gate crash_silent ok "exit 0, no output"
else
  gate crash_silent FAIL "exit $RC"
fi
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

finish
