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

# ---- unit gates of the helper on a synthetic PATH ----
U=$WORK/u
_sh=$(command -v sh)  # the synthetic PATHs below hold no sh, so it is called by absolute path
mkdir -p "$U/cpl" "$U/sh ared" "$U/win" "$U/clean" "$U/clean2"
cp "$WORK/cplbin/bbjcpl" "$WORK/cplbin/bbjcplw" "$U/cpl/"
cp "$WORK/cplbin/bbjcpl" "$U/sh ared/bbjcpl"
: > "$U/sh ared/bbjcplw.exe"
printf '#!/bin/sh\necho "mytool ran"\n' > "$U/sh ared/mytool"
: > "$U/win/bbjcpl.exe"
printf '#!/bin/sh\nexit 0\n' > "$U/clean/tool1"
printf '#!/bin/sh\nexit 0\n' > "$U/clean2/tool2"
chmod 755 "$U/cpl/bbjcpl" "$U/cpl/bbjcplw" "$U/sh ared/bbjcpl" "$U/sh ared/mytool" "$U/clean/tool1" "$U/clean2/tool2"

# a directory that only holds the compiler is gone
_out=$(no_compiler_path "$U/cpl:$U/clean")
_f=$(PATH=$_out "$_sh" -c 'command -v bbjcpl; command -v bbjcplw')
if [ -z "$_f" ]; then
  gate pathscrub_compiler_only_dir ok "no compiler name resolves on $_out"
else
  gate pathscrub_compiler_only_dir FAIL "still found: $_f"
fi

# a shared directory (with a space in its name) keeps its other tools through the farm
_out=$(no_compiler_path "$U/sh ared:$U/clean")
_ran=$(PATH=$_out "$_sh" -c 'mytool')
_f=$(PATH=$_out "$_sh" -c 'command -v bbjcpl; command -v bbjcplw.exe')
case "$_out" in "$WORK"/pathfarm.*) _first=1 ;; *) _first=0 ;; esac
if [ "$_ran" = "mytool ran" ] && [ -z "$_f" ] && [ "$_first" = 1 ]; then
  gate pathscrub_shared_dir_keeps_tools ok "mytool still runs, the compiler names are gone"
else
  gate pathscrub_shared_dir_keeps_tools FAIL "ran '$_ran', found '$_f', output $_out"
fi

# the .exe names count
_out=$(no_compiler_path "$U/win:$U/clean")
case ":$_out:" in
  *":$U/win:"*) gate pathscrub_exe_names FAIL "kept $U/win: $_out" ;;
  *) gate pathscrub_exe_names ok "a directory with only bbjcpl.exe is replaced" ;;
esac

# clean directories keep their place and text
_out=$(no_compiler_path "$U/clean:$U/clean2")
if [ "$_out" = "$U/clean:$U/clean2" ]; then
  gate pathscrub_clean_unchanged ok "clean directories are printed as given"
else
  gate pathscrub_clean_unchanged FAIL "got $_out"
fi

# empty entries are dropped
_out=$(no_compiler_path ":$U/clean::$U/clean2:")
if [ "$_out" = "$U/clean:$U/clean2" ]; then
  gate pathscrub_empty_entries_dropped ok "empty entries are gone"
else
  gate pathscrub_empty_entries_dropped FAIL "got $_out"
fi

# order is kept: clean, farm, clean2
_out=$(no_compiler_path "$U/clean:$U/cpl:$U/clean2")
_n=$(printf '%s' "$_out" | awk -F: '{ print NF }')
_e1=$(printf '%s' "$_out" | awk -F: '{ print $1 }')
_e2=$(printf '%s' "$_out" | awk -F: '{ print $2 }')
_e3=$(printf '%s' "$_out" | awk -F: '{ print $3 }')
case "$_e2" in "$WORK"/pathfarm.*) _farm=1 ;; *) _farm=0 ;; esac
if [ "$_n" = 3 ] && [ "$_e1" = "$U/clean" ] && [ "$_farm" = 1 ] && [ "$_e3" = "$U/clean2" ]; then
  gate pathscrub_order_kept ok "clean, farm, clean2"
else
  gate pathscrub_order_kept FAIL "got $_out"
fi

# without WORK the compiler directory is dropped
_out=$(unset WORK; no_compiler_path "$U/cpl:$U/clean")
if [ "$_out" = "$U/clean" ]; then
  gate pathscrub_no_work_drops_dir ok "dropped, nothing created"
else
  gate pathscrub_no_work_drops_dir FAIL "got $_out"
fi

# a farm that cannot be built fails loudly: nothing on stdout, a reason on stderr, return 1 (a PATH
# without sh or awk would let the no-route gates pass on a hook that cannot run). Two causes: no
# mktemp dir (WORK points nowhere) and a ln that fails (shadowed by a function, as a filesystem
# without symlinks would behave).
_out=$(WORK=$WORK/missing_dir no_compiler_path "$U/cpl:$U/clean" 2> "$WORK/farm1.err")
_rc1=$?
_out2=$(
  # shellcheck disable=SC2329 # no_compiler_path calls this shadow of ln; shellcheck cannot see that
  ln() { return 1; }
  no_compiler_path "$U/sh ared:$U/clean" 2> "$WORK/farm2.err"
)
_rc2=$?
if [ "$_rc1" = 1 ] && [ -z "$_out" ] && [ -s "$WORK/farm1.err" ] \
  && [ "$_rc2" = 1 ] && [ -z "$_out2" ] && [ -s "$WORK/farm2.err" ]; then
  gate pathscrub_farm_failure_loud ok "mktemp failure and ln failure: rc 1, empty stdout, a message on stderr"
else
  gate pathscrub_farm_failure_loud FAIL "mktemp: rc $_rc1 out '$_out'; ln: rc $_rc2 out '$_out2'"
fi

# the caller's IFS and noglob state survive a direct (non-substitution) call
_ifs=$IFS
no_compiler_path "$U/cpl:$U/clean" > "$WORK/state.out"
_ifs_ok=0
[ "$IFS" = "$_ifs" ] && _ifs_ok=1
case "$-" in *f*) _glob_off=0 ;; *) _glob_off=1 ;; esac
set -f
no_compiler_path "$U/cpl:$U/clean" > "$WORK/state.out"
case "$-" in *f*) _glob_kept=1 ;; *) _glob_kept=0 ;; esac
set +f
if [ "$_ifs_ok" = 1 ] && [ "$_glob_off" = 1 ] && [ "$_glob_kept" = 1 ]; then
  gate pathscrub_shell_state_restored ok "IFS and noglob are the caller's"
else
  gate pathscrub_shell_state_restored FAIL "ifs_ok=$_ifs_ok globbing_on=$_glob_off noglob_kept=$_glob_kept"
fi

finish
