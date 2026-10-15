#!/bin/sh
# tests/test_hook_mutation.sh -- phase 13, plan 13-03 (FIX-02, FIX-03; decisions D-16 to D-18):
# proves that gates of the hook tests can fail.
#
# The test copies tests/ and the hook (plugins/bbj/scripts/bbj-check.sh) into scratch trees, so the
# copied tests/lib.sh resolves REPO and SCRIPT to the scratch tree. Per case it applies one sed
# mutation to the copy of bbj-check.sh, runs a nested test file from the copy, and requires the
# named gates to print FAIL and the nested test to exit 1. An unchanged copy must pass (the
# control), and a mutation that changes nothing is a FAIL. The real hook is never written.
#
# Gates: hookmut_discovery_control, hookmut_tier2_control (the unchanged copies pass), then
# hookmut_backslash_conversion, hookmut_dotdot_check and hookmut_t2_cache (one mutation each), and
# hookmut_noconn_ip and hookmut_noconn_time (review IN-01: each half of the connect-timeout test).
# Nested output stays under $WORK, so every stdout line of this file is a gate line with prefix
# hookmut_ (Phase 14 adds the prefix to the prefix list).
#
# Pitfall 12: a gate that needs a file name with a backslash reports skip on a file system that
# cannot hold one, and FAIL under CI=true; never a false ok.
# Nothing here runs BBj; the compiler and curl are the logging fakes of tests/fake-bin.
. "$(dirname "$0")/lib.sh"
mkwork

unset FAKE_LOG FAKE_OUT FAKE_STDOUT FAKE_EXIT FAKE_CURL_EXIT FAKE_CURL_WRITEOUT FAKE_CURL_LOG TIER2_TEST_SYSPATH

HOOK=$REPO/plugins/bbj/scripts/bbj-check.sh

# fresh_tree DIR: a copy of tests/ and the hook, laid out as in the repository
fresh_tree() {
  mkdir -p "$1/plugins/bbj/scripts" || return 1
  cp -R "$REPO/tests" "$1/tests" || return 1
  cp "$HOOK" "$1/plugins/bbj/scripts/bbj-check.sh" || return 1
}

# nested TREE FILE OUT: runs TREE/tests/FILE in a subshell without the seams of this shell; the
# exit code lands in NRC
nested() {
  (
    unset SCRIPT FAKE_LOG FAKE_OUT FAKE_STDOUT FAKE_EXIT FAKE_CURL_EXIT FAKE_CURL_WRITEOUT FAKE_CURL_LOG TIER2_TEST_SYSPATH
    sh "$1/tests/$2" > "$3" 2>&1
  )
  NRC=$?
}

# missing_prereq NAME DETAIL: a gate that cannot run is FAIL under CI=true, else skip
missing_prereq() {
  if [ "${CI:-}" = true ]; then
    gate "$1" FAIL "$2"
  else
    gate "$1" skip "$2"
  fi
}

# any_skip OUT GATES: succeeds when one of GATES printed skip in OUT
any_skip() {
  # shellcheck disable=SC2086 # GATES is a space-separated list, split on purpose
  for _g in $2; do
    grep -q "^gate $_g skip " "$1" && return 0
  done
  return 1
}

# control CASE FILE GATES: the unchanged copy passes; every gate of GATES prints ok
control() {
  _tree=$WORK/tree-$1-clean
  _out=$WORK/out-$1-clean
  fresh_tree "$_tree" || { gate "hookmut_$1_control" FAIL "cannot copy the tree"; return; }
  nested "$_tree" "$2" "$_out"
  if any_skip "$_out" "$3"; then
    missing_prereq "hookmut_$1_control" "a gate of $2 skipped here, so the mutation proof cannot run"
    return
  fi
  _bad=
  # shellcheck disable=SC2086 # GATES is a space-separated list, split on purpose
  for _g in $3; do
    grep -q "^gate $_g ok " "$_out" || { _bad=$_g; break; }
  done
  if [ "$NRC" = 0 ] && [ -z "$_bad" ]; then
    gate "hookmut_$1_control" ok "the unchanged copy passes $2"
  else
    gate "hookmut_$1_control" FAIL "rc=$NRC, no ok line for ${_bad:-any gate}"
  fi
}

# mutant CASE FILE GATES SEDPROGRAM: SEDPROGRAM changes the copied hook; every gate of GATES must
# print FAIL and FILE must exit 1
mutant() {
  _tree=$WORK/tree-$1-mut
  _out=$WORK/out-$1-mut
  fresh_tree "$_tree" || { gate "hookmut_$1" FAIL "cannot copy the tree"; return; }
  _h=$_tree/plugins/bbj/scripts/bbj-check.sh
  sed "$4" "$_h" > "$_h.new" && mv "$_h.new" "$_h"
  if cmp -s "$_h" "$HOOK"; then
    gate "hookmut_$1" FAIL "the mutation changed nothing in bbj-check.sh"
    return
  fi
  nested "$_tree" "$2" "$_out"
  if any_skip "$_out" "$3"; then
    missing_prereq "hookmut_$1" "a gate of $2 skipped here, so the mutation cannot be judged"
    return
  fi
  _bad=
  # shellcheck disable=SC2086 # GATES is a space-separated list, split on purpose
  for _g in $3; do
    grep -q "^gate $_g FAIL " "$_out" || { _bad=$_g; break; }
  done
  if [ "$NRC" = 1 ] && [ -z "$_bad" ]; then
    gate "hookmut_$1" ok "$3 fails on the mutated hook"
  else
    gate "hookmut_$1" FAIL "rc=$NRC, gate ${_bad:-?} did not fail: the mutation was not caught"
  fi
}

control discovery test_discovery.sh 'windows_codex_backslash_dotdot_skipped windows_codex_backslash_dot_control'
control tier2 test_tier2_fake.sh 'tier2_once_windows_refused tier2_once_windows_connect_timeout tier2_noconn_needs_no_ip tier2_noconn_needs_zero_time'

# FIX-03, SC3: wpath_norm no longer turns backslashes into slashes; the bait is compiled, and the
# control sub\.\f.bbj finds no file (D-17: the conversion runs before the ".." check)
mutant backslash_conversion test_discovery.sh 'windows_codex_backslash_dotdot_skipped windows_codex_backslash_dot_control' \
  's/^\(  printf .%s. "\$1"\) | tr .*$/\1/'

# D-16, second sentence: codex_patch no longer skips ".." segments; the outside file x.bbj is
# compiled
mutant dotdot_check test_discovery.sh 'windows_codex_backslash_dotdot_skipped' \
  's#^      \*/\.\.|\*/\.\./\*) continue ;;$#      NEVER) continue ;;#'

# D-18 case b (FIX-02): the t2-cache line of plan 13-01 is deleted, so every file of a many-file
# patch pays the tier-2 connect again
mutant t2_cache test_tier2_fake.sh 'tier2_once_windows_refused tier2_once_windows_connect_timeout' \
  '/# t2-cache$/d'

# review IN-01: the "no remote_ip" half of the connect-timeout test is dropped, so a write-out with a
# connect time of 0 and a remote address counts as no route and is cached
mutant noconn_ip test_tier2_fake.sh 'tier2_noconn_needs_no_ip' \
  's/ && \[ -z "\${_wo#\* }" \]//'

# review IN-01: the "time_connect is 0" half is dropped, so a write-out with a connect time above 0 and
# no remote address counts as no route and is cached
mutant noconn_time test_tier2_fake.sh 'tier2_noconn_needs_zero_time' \
  's/^    && \[ -z "\$(printf .%s. "\${_wo%% \*}" | tr -d .0\.,.)" \]; then$/    ; then/'

finish
