#!/bin/sh
# tests/test_path_scrub.sh -- plan 07-02 (MAINT-06; decisions D-11 to D-13 of phase 7): proves the
# PATH scrub of the no-route tests is load-bearing. With a fake bbjcpl and bbjcplw first on PATH,
# tests/test_noroute_notice.sh and tests/test_exit_contract.sh must stay green (the scrub hides the
# compiler from the hook); the same two files run from a copy of tests/ whose no_compiler_path is
# a no-op must go red (removing the scrub is caught). The helper's own properties are unit gates.
# Nested runs keep their output under $WORK, so every stdout line here is a gate line (prefix
# pathscrub_) and tests/run.sh counts nothing else.
# Nothing here runs BBj: the compilers on PATH are copies of tests/fake-bin/bbjcpl, a logger that
# compiles and runs nothing. tests/fake-bin itself is never put on PATH.
. "$(dirname "$0")/lib.sh"
mkwork

unset FAKE_LOG FAKE_OUT FAKE_STDOUT FAKE_EXIT FAKE_CURL_EXIT

# two copies of the fake compiler, named as the hook looks for them
mkdir "$WORK/cplbin"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/cplbin/bbjcpl"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/cplbin/bbjcplw"
chmod 755 "$WORK/cplbin/bbjcpl" "$WORK/cplbin/bbjcplw"

# the fake compilers are found first: otherwise the green gates below would prove nothing
_found=$(PATH=$WORK/cplbin:$PATH sh -c 'command -v bbjcpl; command -v bbjcplw')
if [ "$_found" = "$WORK/cplbin/bbjcpl
$WORK/cplbin/bbjcplw" ]; then
  gate pathscrub_fake_on_path ok "bbjcpl and bbjcplw resolve to $WORK/cplbin"
else
  gate pathscrub_fake_on_path FAIL "resolved to: $_found"
fi

# green TAG FILE PROOF_REGEX: FILE runs nested with the fake compiler first on PATH; it must exit
# 0, print no FAIL gate, and print at least one line that matches PROOF_REGEX.
green() {
  PATH=$WORK/cplbin:$PATH sh "$REPO/tests/$2" > "$WORK/green.$1.out" 2>&1
  _grc=$?
  _gfail=$(grep -c '^gate [^ ]* FAIL ' "$WORK/green.$1.out")
  if [ "$_grc" = 0 ] && [ "$_gfail" = 0 ] && grep -q "$3" "$WORK/green.$1.out"; then
    gate "pathscrub_green_$1" ok "$2 is green with a compiler first on PATH"
  else
    gate "pathscrub_green_$1" FAIL "rc $_grc, $_gfail FAIL gates, first: $(grep -m 1 '^gate [^ ]* FAIL ' "$WORK/green.$1.out")"
  fi
}

green noroute_notice test_noroute_notice.sh '^gate notice_text_claude ok '
green exit_contract test_exit_contract.sh '^gate contract_[a-z]*_no_route ok '

# a copy of tests/ whose no_compiler_path does nothing: removing the scrub must be caught. The
# copy's REPO is $WORK/mut (fake-bin and fake_mcp.py are found inside it); it has no plugins/,
# so SCRIPT points at the real hook. A later definition wins in POSIX sh.
mkdir -p "$WORK/mut"
cp -R "$REPO/tests" "$WORK/mut/tests"
printf '%s\n' 'no_compiler_path() { printf '"'"'%s'"'"' "${1-$PATH}"; }' >> "$WORK/mut/tests/lib.sh"

# mutant TAG FILE PROOF_REGEX: FILE runs nested from the mutated copy with the fake compiler first
# on PATH; it must exit 1 and print a line that matches PROOF_REGEX.
mutant() {
  if cmp -s "$WORK/mut/tests/lib.sh" "$REPO/tests/lib.sh"; then
    gate "pathscrub_mutation_$1" FAIL "the mutation changed nothing"
    return
  fi
  SCRIPT="$REPO/plugins/bbj/scripts/bbj-check.sh" PATH=$WORK/cplbin:$PATH sh "$WORK/mut/tests/$2" > "$WORK/mut.$1.out" 2>&1
  _mrc=$?
  if [ "$_mrc" = 1 ] && grep -q "$3" "$WORK/mut.$1.out"; then
    gate "pathscrub_mutation_$1" ok "$2 goes red when the scrub is a no-op"
  else
    gate "pathscrub_mutation_$1" FAIL "rc $_mrc, no $3 line: removing the scrub was not caught"
  fi
}

mutant noroute_notice test_noroute_notice.sh '^gate notice_text_claude FAIL '
mutant exit_contract test_exit_contract.sh '^gate contract_[a-z]*_no_route FAIL '

# no_compiler_env clears every other discovery source, in the calling shell
_env=$(
  BBJ_HOME=/x; BBJHOME=/y; CLAUDE_PLUGIN_OPTION_BBJ_HOME=/z; BBJ_CHECK_DEFAULT_HOMES=/opt/bbx
  export BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME BBJ_CHECK_DEFAULT_HOMES
  no_compiler_env
  sh -c 'printf "%s|%s|%s|%s" "${BBJ_HOME-unset}" "${BBJHOME-unset}" "${CLAUDE_PLUGIN_OPTION_BBJ_HOME-unset}" "${BBJ_CHECK_DEFAULT_HOMES+set}${BBJ_CHECK_DEFAULT_HOMES}"'
)
if [ "$_env" = "unset|unset|unset|set" ]; then
  gate pathscrub_env_cleared ok "BBJ_HOME, BBJHOME and the plugin option are unset; the default homes are empty"
else
  gate pathscrub_env_cleared FAIL "child saw: $_env"
fi

finish
