#!/bin/sh
# tests/test_hook_review_fixes.sh -- regression tests for the phase 19 code review findings
# on plugins/bbj/scripts/bbj-check.sh (WR-04 symlinks, WR-05 large patches, IN-01 compiler
# name). The compiler is a fake that only logs; nothing here runs BBj.
. "$(dirname "$0")/lib.sh"
mkwork

mkdir -p "$WORK/home/bin" "$WORK/proj" "$WORK/outside"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/home/bin/bbjcpl"
chmod 755 "$WORK/home/bin/bbjcpl"
printf '/x/f.bbj: error at line 10 (1): print\n' > "$WORK/canned"
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
FAKE_OUT=$WORK/canned
export BBJ_HOME FAKE_LOG FAKE_OUT
: > "$FAKE_LOG"

# ---- WR-04: a *.bbj symlink to another file is not checked ----
printf 'secret line\n' > "$WORK/outside/secret.txt"
ln -s "$WORK/outside/secret.txt" "$WORK/proj/s.bbj"
run_check "$(claude_payload Edit "$WORK/proj/s.bbj" "$WORK/proj")"
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ ! -s "$FAKE_LOG" ]; then
  gate symlink_not_checked ok "a .bbj link to another file: exit 0, silent, compiler not called"
else
  gate symlink_not_checked FAIL "exit $RC, stderr $(head -c 120 "$WORK/stderr"), calls $(wc -c < "$FAKE_LOG")"
fi
: > "$WORK/proj/real.bbj"
run_check "$(claude_payload Edit "$WORK/proj/real.bbj" "$WORK/proj")"
if [ "$RC" = 2 ] && [ -s "$FAKE_LOG" ]; then
  gate regular_file_still_checked ok "a regular file next to the link is still compiled"
else
  gate regular_file_still_checked FAIL "exit $RC"
fi
: > "$FAKE_LOG"
ln -s "$WORK/proj/real.bbj" "$WORK/proj/viaCodex.bbj"
run_check "$(codex_payload "$WORK/proj" "$(printf '%s\n' '*** Begin Patch' '*** Update File: viaCodex.bbj' '*** End Patch')")"
if [ "$RC" = 0 ] && [ ! -s "$FAKE_LOG" ]; then
  gate symlink_not_checked_patch ok "a patch naming a link: exit 0, compiler not called"
else
  gate symlink_not_checked_patch FAIL "exit $RC"
fi

finish
