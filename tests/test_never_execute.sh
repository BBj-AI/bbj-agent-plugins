#!/bin/sh
# tests/test_never_execute.sh -- plan 19-01 Task 2: the never-execute proof (PLUG-01).
# A fake home holds a fake compiler and a fake BBj interpreter, a second fake interpreter
# is first on PATH. After Write/Edit payloads for .bbj, .src, .BBX, a missing file and a
# .md file: the interpreter's sentinel file never appears, and every logged compiler call
# has -t, -N and -X as their own arguments, the absolute target path last, and no other
# argument without a leading "-". Nothing here runs BBj; the fakes only log.
. "$(dirname "$0")/lib.sh"
mkwork

mkdir -p "$WORK/home/bin" "$WORK/pathbin" "$WORK/proj"
cp "$REPO/tests/fake-bin/bbjcpl" "$REPO/tests/fake-bin/bbj" "$WORK/home/bin/"
cp "$REPO/tests/fake-bin/bbj" "$WORK/pathbin/bbj"
chmod 755 "$WORK/home/bin/bbjcpl" "$WORK/home/bin/bbj" "$WORK/pathbin/bbj"
PATH=$WORK/pathbin:$PATH
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
FAKE_SENTINEL=$WORK/sentinel
export PATH BBJ_HOME FAKE_LOG FAKE_SENTINEL
unset FAKE_OUT FAKE_STDOUT FAKE_EXIT

: > "$WORK/proj/bad.bbj"
: > "$WORK/proj/x.src"
: > "$WORK/proj/y.BBX"
: > "$WORK/proj/notes.md"

run_check "$(claude_payload Write "$WORK/proj/bad.bbj" "$WORK/proj")"
run_check "$(claude_payload Edit "$WORK/proj/x.src" "$WORK/proj")"
run_check "$(claude_payload Write "$WORK/proj/y.BBX" "$WORK/proj")"
run_check "$(claude_payload Write "$WORK/proj/missing.bbj" "$WORK/proj")"
run_check "$(claude_payload Write "$WORK/proj/notes.md" "$WORK/proj")"

[ ! -e "$WORK/sentinel" ] && gate sentinel ok "the fake interpreter never ran" || gate sentinel FAIL "the fake interpreter ran"

# One verdict line per logged call: argument checks.
awk '
/^CALL$/ { na = 0; next }
/^ARG0 / {
  n++; hasN = 0; hasT = 0; hasX = 0
  for (i = 1; i <= na; i++) { if (a[i] == "-N") hasN = 1; if (a[i] == "-t") hasT = 1; if (a[i] == "-X") hasX = 1 }
  if (!hasN) noN++
  if (!hasT || !hasX) noTX++
  if (na < 1 || substr(a[na], 1, 1) != "/") badTarget++
  for (i = 1; i < na; i++) if (substr(a[i], 1, 1) != "-") stray++
  next
}
{ a[++na] = $0 }
END { printf "calls=%d noN=%d noTX=%d badTarget=%d stray=%d\n", n, noN, noTX, badTarget, stray }
' "$FAKE_LOG" > "$WORK/verdict"
V=$(cat "$WORK/verdict")
case "$V" in "calls=3 "*) gate call_count ok "$V" ;; *) gate call_count FAIL "$V (want 3 calls: bad.bbj, x.src, y.BBX; none for the missing and .md files)" ;; esac
case "$V" in *"noN=0 "*) gate dash_N ok "-N is its own argument on every call" ;; *) gate dash_N FAIL "$V" ;; esac
case "$V" in *"noTX=0 "*) gate dash_t_X ok "-t and -X on every call" ;; *) gate dash_t_X FAIL "$V" ;; esac
case "$V" in *"badTarget=0 "*) gate target_last_absolute ok "the target is last and absolute" ;; *) gate target_last_absolute FAIL "$V" ;; esac
case "$V" in *"stray=0") gate no_stray_argument ok "every other argument starts with -" ;; *) gate no_stray_argument FAIL "$V" ;; esac

# Canned compiler error -> exit 2 with the line in stderr; no output -> exit 0 silent.
printf 'bad.bbj: error at line 10 (1): print "a"   rem same line\n' > "$WORK/canned"
FAKE_OUT=$WORK/canned
export FAKE_OUT
run_check "$(claude_payload Write "$WORK/proj/bad.bbj" "$WORK/proj")"
if [ "$RC" = 2 ] && grep -F 'error at line 10 (1)' "$WORK/stderr" > /dev/null && [ ! -s "$WORK/stdout" ]; then
  gate canned_error ok "exit 2, canned line in stderr, stdout empty"
else
  gate canned_error FAIL "exit $RC"
fi
unset FAKE_OUT
run_check "$(claude_payload Write "$WORK/proj/bad.bbj" "$WORK/proj")"
if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
  gate canned_clean ok "exit 0, no output"
else
  gate canned_clean FAIL "exit $RC"
fi
[ ! -e "$WORK/sentinel" ] && gate sentinel_final ok "still never ran" || gate sentinel_final FAIL "the fake interpreter ran"

finish
