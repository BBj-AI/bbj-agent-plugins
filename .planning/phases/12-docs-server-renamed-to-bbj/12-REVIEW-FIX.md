---
phase: 12-docs-server-renamed-to-bbj
fixed_at: 2026-10-16T00:00:00Z
review_path: .planning/phases/12-docs-server-renamed-to-bbj/12-REVIEW.md
iteration: 1
findings_in_scope: 7
fixed: 4
skipped: 3
status: partial
---

# Phase 12: Code Review Fix Report

**Fixed at:** 2026-10-16
**Source review:** .planning/phases/12-docs-server-renamed-to-bbj/12-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 7 (fix_scope: all)
- Fixed: 4
- Skipped: 3

**Verification:** run in the main checkout on branch `gsd/planning-setup` (no worktree). Each edited
shell file passed `shellcheck -s sh`; the touched test files were run on their own after each fix; then the full
suite ran once at the end: `sh tests/run.sh` printed `SUMMARY: ok=859 fail=0 skip=1`.
The one skip is the new gate `live_blackhole_connect_timeout`, which needs `BBJ_LS_BLACKHOLE_URL` (see WR-03).
Before the fixes the same suite printed `SUMMARY: ok=857 fail=0 skip=0`.

## Fixed Issues

### WR-01: `FAKE_CURL_WRITEOUT` leaks into tests that assume the fake prints no write-out

**Files modified:** `tests/lib.sh`, `tests/test_hook_review_fixes.sh`
**Commit:** b6050d1
**Applied fix:** `tests/lib.sh` now unsets `FAKE_CURL_EXIT`, `FAKE_CURL_WRITEOUT` and `FAKE_CURL_LOG` next to the
other seams, with a comment naming the reason. New gate `reviewfix_curl_seams_cleared` (prefix `reviewfix_`) sources
`lib.sh` in a child shell with the three variables exported and requires all three to be unset. The reproduction
from the review (`FAKE_CURL_WRITEOUT='0.000000 ' sh tests/test_noroute_notice.sh`) now prints no FAIL gate.
The review asked for a gate that runs a hermetic test with the variable exported; the gate checks the cause
(the three seams after sourcing `lib.sh`) instead, which costs milliseconds and not the seven seconds of the full
notice test.

### WR-03: Sibling gates do not prove the exit-28 write-out contract against a real curl

**Files modified:** `tests/test_tier2_live.sh`
**Commit:** 6918104
**Applied fix:** New gate `live_blackhole_connect_timeout` (prefix `live_`) runs the real curl once with the hook's
`-w '\n%{time_connect} %{remote_ip}'` option against `$BBJ_LS_BLACKHOLE_URL` and requires exit 28, a zero
`time_connect` and an empty `remote_ip`. It reports `skip` when the variable is unset or curl is missing. It lives
in `tests/` only; the shipped hook is unchanged and still contacts loopback. Checked by hand on this machine:
a non-routable address gave `ok` (exit 28, `0.000000`, empty `remote_ip`) and a closed loopback port gave `FAIL`
(exit 7), so the gate can fail. The maintainer still has to run it once with a real blackhole address; the docs
page was not changed.
**Status:** fixed (the gate is test-only; it needs a maintainer-supplied address to run).

### IN-02: Stale comment about the prefix list

**Files modified:** `tests/test_hook_mutation.sh`
**Commit:** 6a83027
**Applied fix:** The header now says the prefix `hookmut_` is "listed in the gate-prefix block of
`.claude/CLAUDE.md`" instead of "Phase 14 adds the prefix to the prefix list".

### IN-04: `FAKE_CURL_WRITEOUT` cannot express "set but empty" through `oncegate`

**Files modified:** `tests/test_tier2_fake.sh`
**Commit:** 2c6f549
**Applied fix:** `oncegate` accepts the word `@empty` as WRITEOUT and exports `FAKE_CURL_WRITEOUT` set but empty.
New gate `tier2_noconn_empty_writeout` (prefix `tier2_`) expects 12 curl calls and silence for exit 28 with an
empty write-out.

## Skipped Issues

### WR-02: The test runner and a layout gate read their rules from `.claude/CLAUDE.md`, a tool-managed instructions file

**File:** `tests/run.sh:80-95`, `tests/test_layout.py` (`TERM_LIST_FILE`, gate `term_list`)
**Reason:** skipped: needs a design decision. The main fix moves the gate-prefix block and the term list out of
`.claude/CLAUDE.md` into test-owned files (`tests/PREFIXES.txt`, `tests/TERMS.txt`), which changes where the project
rules live and rewrites the gates and their mutation tests. The alternative (fail when
`.planning/codebase/CONVENTIONS.md` is absent under `CI=true`) contradicts the recorded behavior of
`run_prefix_block` ("ok also under CI=true", pinned by `run_prefix_*` gates in `tests/test_ci_gates.sh`). Neither
could be chosen safely without the maintainer.
**Original issue:** `run_prefix_block` and `layout_term_list` use `.claude/CLAUDE.md`, an agent-instructions file
that tooling can regenerate, as the source of truth, so a regeneration can change CI results and the absent
`CONVENTIONS.md` copy is compared silently.

### IN-01: The tier-2 feedback header names the plugin `bbj-local`, but the hook does not use the plugin

**File:** `plugins/bbj/scripts/bbj-check.sh` (`report bbj-local ...`), `docs/install.md:271-272`
**Reason:** skipped: changes the user-visible feedback header grammar (`bbj-local reported N error(s) in <file>:`),
which many tests and "Observed" lines pin; the review itself calls it a release decision for a later phase.
**Original issue:** The header names the plugin `bbj-local` although the hook asks `bbj-ls` directly and works
without the plugin.

### IN-03: One hook run can still outlast its 30-second timeout when `bbj-ls` accepts but never answers

**File:** `plugins/bbj/scripts/bbj-check.sh:285-290`, `docs/install.md:281-287`
**Reason:** skipped: the review marks the fix as conditional ("if it becomes a problem"), and the limit is a
documented decision (D-11, D-13) that was not observed in practice. A time budget or a stop-after-first-timeout
rule changes the shipped hook's behavior and exit contract, which is not safe to guess.
**Original issue:** A reached-but-silent `bbj-ls` costs up to `-m 12` per BBj file of a Codex patch, so three
files can pass the 30-second hook timeout and drop errors collected earlier.

---

_Fixed: 2026-10-16_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
