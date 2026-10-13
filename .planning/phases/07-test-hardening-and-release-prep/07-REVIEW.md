---
phase: 07-test-hardening-and-release-prep
reviewed: 2026-10-13T00:00:00Z
depth: standard
files_reviewed: 5
files_reviewed_list:
  - tests/lib.sh
  - tests/run.sh
  - tests/test_home_guard.sh
  - tests/test_install_codex.sh
  - tests/test_path_scrub.sh
findings:
  critical: 0
  warning: 1
  info: 4
  total: 5
status: issues_found
---

# Phase 7: Code Review Report (incremental re-review after the review-fix commits)

**Reviewed:** 2026-10-13
**Depth:** standard
**Files Reviewed:** 5
**Status:** issues_found

## Summary

I re-reviewed the five files changed since `0804e12` (`git diff 0804e12 HEAD`). `shellcheck -s sh` is clean on all five. `sh tests/run.sh` gives `ok=809 fail=1 skip=0`. The one FAIL is `mcp_docs_connected` ("Needs authentication" from the hosted docs server). It is an environment and network fact unrelated to these files. Every `homeguard_*`, `pathscrub_*` and `real_home_untouched` gate is `ok`.

### Prior findings, now resolved

| Prior | Status | Evidence |
|---|---|---|
| WR-01 (symlink to a regular file recorded by target only) | Resolved | `lib.sh:276-279` adds a `T <crc> <size> <path>` line for a link that resolves to a readable regular file. The gates `homeguard_filelink_write_through_detected` (differ) and `homeguard_filelink_untouched_same` (same) cover it. I confirmed in a scratch home that the T line appears. |
| WR-02 (an `E` line or an empty snapshot compared equal to itself) | Resolved | `home_incomplete` and `home_incomplete_status` (`lib.sh:323-343`). `test_install_codex.sh:1522-1524` checks completeness before the diff, so the gate is `skip` locally and `FAIL` under `CI=true`. The gates `homeguard_incomplete_snapshot` and `homeguard_incomplete_status` cover it. The wiring in `test_install_codex.sh` itself is not gated (see WR-01 below). |
| IN-01 (temp-file globs depend on ambient `set -f`) | Resolved | `lib.sh:254-255` lifts noglob inside the block. `homeguard_noglob_temp_detected` proves the glob expands under `set -f`. The gate's "set -f is still on afterwards" half is vacuous (IN-02 below). |
| IN-02 (directory modes not recorded, `readlink` not POSIX) | Resolved | The `D` line carries the mode (`lib.sh:281`). `readlink` is optional, with an `ls -ld | sed` fallback (`lib.sh:271-274`). `homeguard_dir_chmod_detected` covers the mode. |
| IN-03 (`TIER2_TEST_SYSPATH` read from the ambient environment) | Resolved | `run.sh:12` unsets it, and `test_path_scrub.sh:15` unsets it at the top. Running `test_tier2_fake.sh` directly from a shell that exports the variable is still affected; that is the accepted residual. |
| IN-04 (FIFO orphans, root skip) | Resolved | The FIFO is released by a read-write open before the kill (`test_home_guard.sh:251`). `homeguard_find_failure_reported` covers the `E` line without `chmod`, so it also runs as root. |

I checked the rest of `no_compiler_path` again (the break paths, the `..?*` glob arm, IFS and noglob restoration, loud failure) and found no defect. The security-relevant classes for `home_snapshot` are clean. All writes go under `$WORK` (mode 0700). Names reach the classifier as arguments, so a newline in a name cannot split an entry, and no name is interpolated into a command. Only regular files are opened, so a FIFO cannot block. Only `cksum` values are printed, never content. Credential files are not in the watched set. There is no blocker.

## Warnings

### WR-01: The `home_incomplete` branch in the consumer is not guarded by any gate

**File:** `tests/test_install_codex.sh:1522-1524`; `tests/test_home_guard.sh:331-340`
**Issue:** The WR-02 fix works only if `test_install_codex.sh` calls `home_incomplete` before `home_diff`. The helpers are unit-tested, but the wiring is not. `homeguard_install_codex_uses_helper` counts `home_snapshot` calls and rejects `-newer`, and nothing else looks at the consumer. If someone reverts the consumer to the old `if _changed=$(home_diff ...)` form, or drops the `elif`, every gate stays green and `real_home_untouched` again reports `ok` on an identical pair of incomplete snapshots. That is the exact hole the fix closed. The earlier round of this phase showed that this kind of consumer-side regression is the likely one.
**Fix:** Extend the static gate in `test_home_guard.sh` so that it also requires `home_incomplete "$WORK/home.before" "$WORK/home.after"` in the non-comment code of `test_install_codex.sh`, and that the line comes before the `home_diff` call:
```sh
_hi=$(printf '%s\n' "$_code" | grep -nF 'home_incomplete "$WORK/home.before" "$WORK/home.after"' | head -n 1 | cut -d: -f1)
_hd=$(printf '%s\n' "$_code" | grep -nF 'home_diff "$WORK/home.before" "$WORK/home.after"' | head -n 1 | cut -d: -f1)
# gate ok only when both are present and _hi -lt _hd
```

## Info

### IN-01: `home_snapshot` reads files outside the watched set through symlinks, and misses an unreadable link target

**File:** `tests/lib.sh:273-279` (header claim at `lib.sh:233-235`)
**Issue:** The classifier runs on every entry `find` visits, so a symlink anywhere below a watched directory that points at a regular file gets a `T` line with the `cksum` of its target. I confirmed it in a scratch home: a link `bbj-programming/link -> auth.json` printed `T 2420728404 6 .../link`. The header says credential files such as `auth.json` "are never opened"; that holds only while no watched tree links to one. The leak is only a CRC, and it lands in the 0700 `$WORK` and in the FAIL detail of a changed line, so the risk is small. The reverse blind spot is a link to a regular file that is unreadable: it gets an `L` line but neither a `T` nor a `U` line, so a write behind it is silent.
**Fix:** Say in the header that a symlink target is read. Emit `T` only when the link is a top-level watched path (compare `$_f` to the argument) or when the target lies under one of the two watched roots. Print `U <path>` for a link to a regular file that is not readable.

### IN-02: `homeguard_noglob_temp_detected` asserts that noglob is still on, which cannot fail

**File:** `tests/test_home_guard.sh:175-190`
**Issue:** `home_snapshot` is the left side of a pipeline (`{ ...; } | LC_ALL=C sort`), so its `set +f` and `set -f` run in a subshell. The caller's noglob state is unaffected whatever the function does, and `_ng_kept=1` is always true. The part of the gate that proves a leaked temp file shows under `set -f` is real; the "set -f is still on afterwards" claim in the detail text is not evidence of anything.
**Fix:** Drop `_ng_kept` and the claim from the detail text, or leave a comment that it holds by construction. Keep the `grep -q '^F .*/config\.toml\.AbC123$'` check.

### IN-03: `run.sh` leaves its temp files behind when the run is interrupted (pre-existing)

**File:** `tests/run.sh:15-16, 25, 50`
**Issue:** The `EXIT` trap removes only `$OUT`. `$OUT.gates` is removed only on the normal path at the end, and there is no `INT`, `TERM` or `HUP` trap, so a Ctrl-C leaves both files in `$TMPDIR`. `mkwork` in `lib.sh` does install such a trap. This is not new in this diff and the files are small.
**Fix:**
```sh
trap 'rm -f "$OUT" "$OUT.gates"' EXIT
trap 'exit 1' INT TERM HUP
```

### IN-04: The temp-file globs are exactly six characters wide and also match user files; the gate text says `config.toml.*`

**File:** `tests/lib.sh:259-260`; `tests/test_install_codex.sh:1526`
**Issue:** `config.toml.??????` and `hooks.json.??????` match `mktemp` suffixes, which is the intent. They also match any user file with a six-character suffix, such as `config.toml.backup` or `config.toml.old123`. A user who edits or creates such a file while the suite runs gets a false `FAIL` on `real_home_untouched`. The `ok` message says "the installer temp files config.toml.* and hooks.json.*", which overstates what is watched: `config.toml.bak` or a seven-character suffix is not.
**Fix:** Word the message as "six-character temp suffixes (config.toml.XXXXXX, hooks.json.XXXXXX)". The false positive is acceptable if it is noted next to the "accepted residual risk" paragraph in the `home_snapshot` header.

---

_Reviewed: 2026-10-13_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
