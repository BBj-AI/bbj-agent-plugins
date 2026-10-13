---
phase: 07-test-hardening-and-release-prep
fixed_at: 2026-10-13T06:40:25Z
review: re-review after the ten fix(07) commits
review_path: .planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md
fix_scope: all
iteration: 1
findings_in_scope: 6
fixed: 6
skipped: 0
status: all_fixed
---

# Phase 7: Code Review Fix Report (re-review round)

**Fixed at:** 2026-10-13T06:40:25Z
**Source review:** `.planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md`
**Iteration:** 1 (this report replaces the one for the earlier round of ten findings, which stay fixed)

**Summary:**
- Findings in scope: 6 (WR-01, WR-02, IN-01 to IN-04)
- Fixed: 6
- Skipped: 0

None of the six is classified as a logic error that needs human sign-off beyond the new gates. Each new
gate was shown to fail without its fix (WR-01, IN-01) or was exercised by hand (IN-02 fallback, IN-04
orphan release).

## Fixed Issues

### WR-01: A watched path that is a symlink to a regular file was recorded by target only

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`
**Commit:** 764c4c7
**Applied fix:** The `home_snapshot` classifier now prints, after the `L <path> -> <target>` line, a
`T <crc> <size> <path>` line with the cksum of what the link resolves to when that is a readable regular
file. A write through a dotfiles-style `config.toml` link now changes the snapshot. The header comment
documents the `T` line. New gates `homeguard_filelink_write_through_detected` (expects `differ`) and
`homeguard_filelink_untouched_same` (touch on link and target, expects `same`). With `tests/lib.sh`
stashed to the old version the write-through gate fails, so the gate is load-bearing.

### WR-02: An incomplete snapshot compared equal to itself, so `real_home_untouched` reported `ok`

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_install_codex.sh`, `tests/test_home_guard.sh`
**Commit:** fe03ce6
**Applied fix:** Two new helpers in `tests/lib.sh`. `home_incomplete BEFORE AFTER` returns 0 and prints a
reason when either snapshot is missing or empty, or holds an `E` line. `home_incomplete_status` returns
`skip`, or `FAIL` when `CI=true`. `tests/test_install_codex.sh` now checks `home_incomplete` before
`home_diff` and gates `real_home_untouched` with that status instead of `ok`. The two `home_snapshot`
calls on the real homes are unchanged, so `homeguard_install_codex_uses_helper` still holds. New gates
`homeguard_incomplete_snapshot` (an `E` line in both snapshots, an empty pair, a missing file, and a
complete pair) and `homeguard_incomplete_status` (skip locally, FAIL under `CI=true`).

### IN-01: The temp-file globs silently stopped expanding under `set -f`

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`
**Commit:** 873973d
**Applied fix:** `home_snapshot` records whether noglob was set, runs `set +f` inside its block, and puts
`set -f` back at the end, the same idiom `no_compiler_path` uses. New gate
`homeguard_noglob_temp_detected` takes both snapshots under `set -f`, leaks a `config.toml.AbC123`, expects
`differ` with an `F` line for it, and checks that `set -f` is still on afterwards. It fails on the old
`home_snapshot`.

### IN-02: Directory modes were not recorded; `readlink` is outside POSIX

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`
**Commit:** 48a9d8e
**Applied fix:** The `D` line is now `D <mode> <path>`, with the permission string from `ls -ld`, and the
header says so. The classifier checks `command -v readlink` once and otherwise cuts the target from the
`ls -ld` line with `sed "s/.* -> //"`, so retarget detection survives a missing `readlink`. New gate
`homeguard_dir_chmod_detected` (755 to 700 on `bbj/`). The fallback was checked by hand with a PATH that
holds only symlinks to `find`, `sh`, `sort`, `ls`, `awk`, `sed`, `cksum`, `cat`, `grep`, `head`, `tr`: the
two retargeted snapshots printed different `L` lines.

### IN-03: `TIER2_TEST_SYSPATH` was read from the ambient environment

**Disposition:** fixed
**Files modified:** `tests/test_path_scrub.sh`, `tests/run.sh`
**Commit:** fc2a435
**Applied fix:** Added `TIER2_TEST_SYSPATH` to the `unset` line at the top of `tests/test_path_scrub.sh`
and an `unset TIER2_TEST_SYSPATH` at the top of `tests/run.sh` (with a comment), so a variable exported in
the developer's shell reaches neither the nested runs nor `tests/test_tier2_fake.sh` under the runner.
Checked by running `test_path_scrub.sh` with `TIER2_TEST_SYSPATH=/nonexistent` exported: all 19 gates ok.

### IN-04: `homeguard_fifo_not_opened` left orphans on failure; `homeguard_unreadable_dir_reported` skipped as root

**Disposition:** fixed
**Files modified:** `tests/test_home_guard.sh`
**Commit:** 2d23bf9
**Applied fix:** Chose from the review's alternatives:
- FIFO: on the failure path the test now opens the FIFO read-write once in a subshell
  (`( exec 3<> "$H_C/bbj/pipe" )`), which does not block and releases a reader waiting in `open()` with an
  EOF, then kills the background subshell. Checked by hand on a mutated copy of `lib.sh` that opens every
  non-directory: the gate failed as designed and no `cksum` or `find` process was left behind.
- Root: a second technique that works as root. New gate `homeguard_find_failure_reported` puts a fake
  `find` that exits 1 first on PATH and requires an `E` line for each existing watched path. The
  `chmod 000` gate keeps its `skip` as root, with a message pointing to the new gate, because the same
  `E` contract is now covered there and a CI FAIL for being root would be a false alarm.

## Verification

Run in the main checkout (`/home/coder/repos/bbj-agent-plugins`, `workflow.use_worktrees` was off, no
worktree). The numbers are reproducible from this tree.

Per fix, before each commit:
- `shellcheck -s sh tests/lib.sh tests/test_home_guard.sh` (plus `tests/test_install_codex.sh` for WR-02,
  `tests/run.sh tests/test_path_scrub.sh` for IN-03): clean.
- `sh`, `dash`, `bash` and `busybox sh` each ran `tests/test_home_guard.sh` after every fix touching it:
  no failing gate.
- `sh`, `dash`, `bash` and `busybox sh` each ran `tests/test_install_codex.sh` after WR-02: exit 0,
  `real_home_untouched` ok.
- `dash`, `bash` and `busybox sh` ran `tests/test_path_scrub.sh` after IN-03: no failing gate.

After the last fix:
- `shellcheck -s sh tests/*.sh tests/fake-bin/*`: no output.
- `sh tests/run.sh`:

```
SUMMARY: ok=810 fail=0 skip=0
```

(803 before this round; 7 new `homeguard_` gates: `filelink_write_through_detected`,
`filelink_untouched_same`, `incomplete_snapshot`, `incomplete_status`, `noglob_temp_detected`,
`dir_chmod_detected`, `find_failure_reported`. No new gate prefix.)

Nothing here ran BBj or touched the real `~/.codex` or `~/.agents`; every fixture lives under `$WORK` or
the scratchpad. `.planning/config.json` and `.planning/state.json` were left alone and unstaged.

---

_Fixed: 2026-10-13T06:40:25Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
