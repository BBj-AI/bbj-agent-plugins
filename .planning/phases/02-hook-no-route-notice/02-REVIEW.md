---
phase: 02-hook-no-route-notice
reviewed: 2026-10-10T00:00:00Z
depth: standard
files_reviewed: 15
files_reviewed_list:
  - README.md
  - codex/install-codex.sh
  - docs/install-claude-code.md
  - docs/install-codex.md
  - plugins/bbj/scripts/bbj-check.sh
  - tests/fake-bin/curl
  - tests/fake_mcp.py
  - tests/lib.sh
  - tests/test_codex_patch.sh
  - tests/test_discovery.sh
  - tests/test_exit_contract.sh
  - tests/test_install_pages.sh
  - tests/test_noroute_notice.sh
  - tests/test_static_guards.sh
  - tests/test_tier2_fake.sh
findings:
  critical: 0
  warning: 2
  info: 5
  total: 7
status: issues_found
---

# Phase 2: Code Review Report

**Reviewed:** 2026-10-10
**Depth:** standard
**Files Reviewed:** 15
**Status:** issues_found

## Summary

The hook change (`notice`, `note_noroute`, `json_body`, the `no_tier1_route` return split, the
`check_file` / `main` wiring) was traced against D-01..D-19. The exit contract (0 or 2, stdout
only for the notice), D-03 route-failed classification (only curl exit 7 is no route), D-04 mixed
results, D-05 early skips, the claim-file test-and-set and the JSON escaping all behave as the
decisions require. `sh tests/run.sh` passes (ok=525 fail=0 skip=2). Hostile names, session ids
and squatted markers were probed and hold. No security vulnerability and no data-loss risk was
found. The defects are in test hermeticity and in how the notice renders some file names.

ShellCheck is not installed on this machine, so the shellcheck gates were not exercised.

Note for the reproduction below: the review shell has `BBJ_HOME=/opt/bbx` exported. `tests/lib.sh`
unsets it, so the suite is unaffected, but any manual run of the hook must use `env -u BBJ_HOME`.

## Warnings

### WR-01: New no-route tests are not hermetic against a `bbjcpl` on PATH

**File:** `tests/lib.sh:37-41` (affects `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh:91-106`, `tests/test_discovery.sh`)
**Issue:** `lib.sh` documents that no test reaches a real BBj unless it opts in, but it only
unsets the BBj environment variables and empties `BBJ_CHECK_DEFAULT_HOMES`. The hook also
discovers the compiler through `find_cpl_on_path` (`bbj-check.sh:398-411`), and the lib never
scrubs `PATH`. Before this phase that did not matter (the "no route" tests accepted any silent
outcome). Every new test that expects "no bbjcpl found" now fails on a machine that has
`bbjcpl` or `bbjcplw` on `PATH`, which is the normal state of the developers this plugin
targets. Reproduced with a stub `bbjcpl` first on PATH: `test_noroute_notice.sh` prints 35 FAIL
gates and `test_exit_contract.sh` fails `contract_{dash,bash}_no_route` and
`contract_{dash,bash}_codex_no_route`. On a machine with a real compiler on PATH the suite would
also call it, which the "hermetic" header says never happens.
**Fix:** Make the seam complete in `lib.sh`: after the `unset` line, build a PATH that cannot
hold a compiler, for example a directory of symlinks to the system tools the hook needs
(`sh awk sed grep head tr cat dirname basename mkdir curl`), as `tests/test_tier2_fake.sh` already
does for its `nocurl` farm, or at minimum strip any `PATH` entry that contains `bbjcpl`/`bbjcplw`
and have tests that want a compiler add their own bin directory.

### WR-02: The notice mangles non-ASCII file names, and a `\u`-escaped name is dropped with no notice

**File:** `plugins/bbj/scripts/bbj-check.sh:159-161` (`json_body`), `:203-205`; skip at `:333-337` / `check_file`
**Issue:** `json_body` replaces every byte outside printable ASCII with `?`, per byte, so
`.../Müller/a.bbj` is announced as `.../M??ller/a.bbj` (reproduced). The notice is the only
message the agent gets about this file, and a path that does not exist on disk makes the
"tell the user which file was not checked" instruction inaccurate. Separately, a path that the
host serialises with a `\uXXXX` escape is skipped by `jget` (no `uni`), so the file is never
counted as "no route" and the user gets silence for a file that was written and not checked,
which is exactly the state D-11 says must not look clean. The first problem is a deliberate
trade-off (valid JSON over fidelity); the cost is not documented as a limitation and not tested.
**Fix:** Keep valid UTF-8 instead of blanking it: escape only `"`, `\` and the C0 controls and
pass bytes >= 0x80 through after validating UTF-8 (for example check with `LC_ALL=C` and a
well-formedness regexp, falling back to `?` only for an invalid sequence). For the `\u` path
case, decode with `-v uni=1` for the file name (as `PATHS_AWK` already does for Codex) or count
it as no route. At minimum, add a gate that pins the current `?` behaviour and state it in the
header.

## Info

### IN-01: Stale comment about a Codex fallback that was decided against

**File:** `tests/test_exit_contract.sh:91-92`
**Issue:** "Plan 02-06 flips the codex case to a fallback expectation only if Codex does not
deliver additionalContext (D-15)". Plan 02-06 is complete, `evidence/codex/OUTCOME.md` records
`d15_fallback: not-needed`, so the comment describes a future that did not happen.
**Fix:** Replace with "Codex delivers additionalContext (plan 02-06, d15_fallback not-needed);
no fallback expectation".

### IN-02: Misleading enable advice when a compiler was found but gave no result

**File:** `plugins/bbj/scripts/bbj-check.sh:189-193`, `:216-219`
**Issue:** For `NR_COMPILER=noresult` the reason reads "bbjcpl found but gave no result", but
the enable step is still "set the plugin option bbj_home ... or put bbjcpl on PATH". The user
already has a compiler; the likely fix is its launcher or Java setup. D-06 fixes only the
client split, so wording for this case is within discretion. Also the `none)` and `*)` arms of
the `case` at `:189-193` are identical (dead distinction).
**Fix:** For `noresult`, add one clause such as "check that the compiler starts (Java / BBj
launcher)" before the enable steps, and merge `none)` into `*)`.

### IN-03: Garbled, over-long header sentence

**File:** `plugins/bbj/scripts/bbj-check.sh:78-80`
**Issue:** Line 79 is a run-on of about 200 characters that ends mid-thought
("... the clause would be false (D-17 does not say so;") and continues on line 80. Hard to read
and out of line with the rest of the header.
**Fix:** Reflow into two sentences: the clause is printed only when this call made the claim;
on D-16 and D-17 tell-anyway paths it is omitted because the next call tells again.

### IN-04: Marker in a shared temp directory trusts any real directory with a regular `claim` file

**File:** `plugins/bbj/scripts/bbj-check.sh:175-186`
**Issue:** With the default `${TMPDIR:-/tmp}` on a multi-user host, another local user who knows
a session id can pre-create `bbj-check-noroute-<id>/claim` and silence the notice for that
session; the code checks for a symlink but not ownership. Session ids are UUIDs, so exploitation
is unlikely and the impact is only a suppressed advisory (the failure is toward silence, against
D-17's "fail toward telling" intent for foreign objects). Two ids that differ only in removed
characters, or after the 64-byte cut, share one marker.
**Fix:** Optional hardening: require the marker directory to be owned by the current user
(`[ -O "$_m" ]` is not strictly POSIX; `find "$_m" -user` or `ls -ld` are alternatives) before
trusting its claim, or include `$(id -u)` in the marker name.

### IN-05: File names reach the model verbatim in a trusted-looking channel

**File:** `plugins/bbj/scripts/bbj-check.sh:203-205`, `:220`
**Issue:** The path list is interpolated unquoted into the sentence of `additionalContext`. A
file name can hold up to 200 printable characters of prose (for example a name that reads like
an instruction), which then appears inside hook context. The agent chose the name itself, so the
exposure is small, but a delimiter costs nothing.
**Fix:** Wrap each path in backticks or quotes (names holding the delimiter are already
escaped or can be mapped to `?`), e.g. `` `/p/a.bbj` was written ... ``. Update the
`notice_two_files` and `notice_path_cap` gates that match the current un-delimited form.

---

_Reviewed: 2026-10-10_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
