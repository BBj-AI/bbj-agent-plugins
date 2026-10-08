#!/bin/sh
# tests/ci.sh -- the one entry point the GitHub workflow calls (and the one to run locally).
#
# Needs no secret and no BBj: the real-compiler and live tests skip without BBj, every other
# test uses a fake compiler. Nothing here executes BBj code.
#
# Steps, each reported as a "gate NAME ok|FAIL|skip DETAIL" line:
#   1. sh tests/run.sh   every self-contained test (fake compiler, never-execute, static,
#                        discovery, exit contract, tier-2 fake, Codex parsing, installer,
#                        layout, skills hash, install pages, CI guards)
#   2. claude plugin validate --strict on the marketplace root, plugins/bbj, plugins/bbj-local
#   3. shellcheck -s sh over the shipped and test shell scripts (skip when shellcheck is absent)
#
# CI=true makes a missing claude CLI a failure: public CI must not go green without the
# strict validation. Outside CI the same case is a skip.
# Exit 1 when run.sh failed or any gate here failed. Ends with a "CI SUMMARY:" line.

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
cd "$ROOT" || exit 1

FAILED=0
OK=0
SKIPPED=0

gate() {
  # gate NAME STATUS DETAIL
  case "$2" in
    ok) OK=$((OK + 1)); echo "gate $1 ok $3" ;;
    skip) SKIPPED=$((SKIPPED + 1)); echo "gate $1 skip $3" ;;
    *) FAILED=$((FAILED + 1)); echo "gate $1 FAIL $3" ;;
  esac
}

if command -v claude > /dev/null 2>&1; then
  echo "claude: $(claude --version 2>&1 | head -n 1)"
fi
if command -v node > /dev/null 2>&1; then
  echo "node: $(node --version 2>&1 | head -n 1)"
fi

# ---- 1. every self-contained test ---------------------------------------------------
sh "$ROOT/tests/run.sh"
RUN_RC=$?
if [ "$RUN_RC" = 0 ]; then
  gate run_sh ok "tests/run.sh exited 0"
else
  gate run_sh FAIL "tests/run.sh exited $RUN_RC"
fi

# ---- 2. strict validation -----------------------------------------------------------
if command -v claude > /dev/null 2>&1; then
  CFG=$(mktemp -d "${TMPDIR:-/tmp}/bbjplug-ci.XXXXXX") || { gate ci_tmpdir FAIL "cannot create a temp dir"; CFG=; }
  if [ -n "$CFG" ]; then
    trap 'rm -rf "$CFG"' EXIT
    trap 'exit 1' INT TERM HUP
    gate ci_claude_present ok "claude CLI found"
    for p in . plugins/bbj plugins/bbj-local; do
      tag=$(printf "%s" "$p" | tr -c "A-Za-z0-9" "_"); [ "$p" = . ] && tag=root
      if [ ! -e "$ROOT/$p" ]; then
        gate "ci_validate_$tag" FAIL "$p does not exist"
        continue
      fi
      out=$(CLAUDE_CONFIG_DIR=$CFG claude plugin validate --strict "$p" 2>&1)
      rc=$?
      if [ "$rc" = 0 ] && ! printf '%s\n' "$out" | grep -i -E 'warning|error' > /dev/null; then
        gate "ci_validate_$tag" ok "claude plugin validate --strict $p"
      else
        gate "ci_validate_$tag" FAIL "exit $rc: $(printf '%s' "$out" | head -n 3 | tr '\n' ' ')"
      fi
    done
  fi
elif [ "${CI:-}" = true ]; then
  gate ci_claude_present FAIL "claude CLI missing; strict validation is mandatory in CI"
else
  gate ci_claude_present skip "claude CLI missing; strict validation skipped outside CI"
fi

# ---- 3. shellcheck ------------------------------------------------------------------
if command -v shellcheck > /dev/null 2>&1; then
  # shellcheck disable=SC2046  # file names here contain no whitespace
  if shellcheck -s sh $(ls plugins/bbj/scripts/*.sh codex/*.sh tests/*.sh 2> /dev/null); then
    gate ci_shellcheck ok "shellcheck -s sh over plugins/bbj/scripts, codex and tests"
  else
    gate ci_shellcheck FAIL "shellcheck reported findings"
  fi
else
  gate ci_shellcheck skip "shellcheck is not installed on this host"
fi

echo "CI SUMMARY: ok=$OK fail=$FAILED skip=$SKIPPED run_sh_exit=$RUN_RC"
if [ "$RUN_RC" != 0 ] || [ "$FAILED" != 0 ]; then
  exit 1
fi
exit 0
