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

# ---- WR-05: a large patch is read in linear time; the failing file after it is still reported ----
: > "$WORK/proj/zz_after_big.bbj"
: > "$FAKE_LOG"
awk 'BEGIN { print "*** Begin Patch"; print "*** Add File: big.txt"; for (i = 0; i < 40000; i++) print "+this is line " i " of a large text file with some padding to make it long"; print "*** Add File: zz_after_big.bbj"; print "+print \"a\""; print "*** End Patch" }' > "$WORK/bigpatch"
bigbytes=$(wc -c < "$WORK/bigpatch")
codex_payload "$WORK/proj" "$(cat "$WORK/bigpatch")" > "$WORK/bigpayload"
t0=$(date +%s)
run_check "$(cat "$WORK/bigpayload")"
t1=$(date +%s)
if [ "$RC" = 2 ] && grep -F "zz_after_big.bbj" "$WORK/stderr" > /dev/null && [ $((t1 - t0)) -lt 10 ]; then
  gate big_patch_linear ok "a $bigbytes byte patch: header after the bulk found, exit 2 in $((t1 - t0)) s"
else
  gate big_patch_linear FAIL "exit $RC after $((t1 - t0)) s: $(head -c 120 "$WORK/stderr")"
fi

# ---- a "+" content line holding a backslash-n text never forges a header ----
: > "$WORK/proj/evil.bbj"
: > "$FAKE_LOG"
codex_payload "$WORK/proj" "$(printf '%s\n' '*** Begin Patch' '*** Add File: n.txt' '+x\n*** Add File: evil.bbj' '+y\\n*** Add File: evil.bbj' '*** End Patch')" > "$WORK/forge"
run_check "$(cat "$WORK/forge")"
if [ "$RC" = 0 ] && ! grep -F 'evil.bbj' "$FAKE_LOG" > /dev/null; then
  gate patch_content_cannot_forge_header ok "backslash-n inside a content line is not a line break"
else
  gate patch_content_cannot_forge_header FAIL "exit $RC, log: $(head -c 200 "$FAKE_LOG")"
fi

finish
