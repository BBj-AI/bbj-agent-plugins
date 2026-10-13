---
phase: 07-test-hardening-and-release-prep
fixed_at: 2026-10-13T04:02:19Z
review: .planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md
review_path: /home/coder/repos/bbj-agent-plugins/.planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md
fix_scope: all
iteration: 1
findings_in_scope: 10
fixed: 10
skipped: 0
status: all_fixed
---

# Phase 7: Code Review Fix Report

**Fixed at:** 2026-10-13T04:02:19Z
**Source review:** `.planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md`
**Iteration:** 1

**Summary:**
- Findings in scope: 10 (WR-01..WR-05, IN-01..IN-05)
- Fixed: 10
- Skipped: 0

## IMPORTANT: the fix commits are NOT yet on `gsd/planning-setup`

The fast-forward of `gsd/planning-setup` to the fix branch failed (exit 128, "Not possible to
fast-forward"): while the fixer ran, another session committed `6246a6b` and `717e6e0`
(`docs(08): capture phase context`, `docs(state): record phase 08 context session`) on
`gsd/planning-setup`. Those two commits touch only `.planning/STATE.md` and
`.planning/phases/08-codex-plugin-route/*`, so there is no file overlap with the fixes.

The ten fix commits therefore live on the temp branch **`gsd-reviewfix/07-2624046`** (tip
`f475d95`, based on `59a764d`). The worktree and the recovery sentinel were removed. To land the
fixes: `git merge gsd-reviewfix/07-2624046` (no conflicts expected) or
`git rebase gsd/planning-setup gsd-reviewfix/07-2624046` followed by a fast-forward. The commit
hashes below are those on the temp branch (a rebase will change them).

Process note: my cleanup command chained the branch delete after a failed fast-forward and
deleted the temp branch once; I recreated it at `f475d95` immediately and checked that it holds all
ten commits. No work was lost.

## Verification

- **Where it ran:** the isolated git worktree
  `.claude/worktrees/rf-07-2624046-1791863129` (now removed), on branch `gsd-reviewfix/07-2624046`.
  Nothing needs `node_modules`, so the results are reproducible from a normal checkout of that branch.
- `shellcheck -s sh tests/*.sh` (repo `.shellcheckrc`): clean.
- `sh tests/test_home_guard.sh` also under dash, bash and busybox sh: all gates ok.
- `sh tests/test_path_scrub.sh` also under dash, bash and busybox sh: all gates ok.
- `sh tests/test_install_codex.sh`, `test_noroute_notice.sh`, `test_exit_contract.sh`,
  `test_tier2_fake.sh`, `test_release_text_mutation.sh`: 0 FAIL.
- `sh tests/run.sh` at the final commit: `SUMMARY: ok=803 fail=0 skip=0`.
- The new gates were checked against the previous helper where that is meaningful: the four
  WR-01 gates, the two WR-02 gates and the FIFO gate (WR-03) fail (the FIFO case hangs the
  suite) against the old `home_snapshot`; dropping the `.exe` removals from `no_compiler_path`
  turns the two WR-05 gates red; removing the scrub turns `test_tier2_fake.sh` red (IN-02).
- Nothing wrote to the real `~/.codex` or `~/.agents`; all new fixtures live under `$WORK`.

## Fixed Issues

### WR-01: `home_snapshot` does not watch everything the installer writes

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`, `tests/test_install_codex.sh`
**Commit:** a2c2b64
**Applied fix:** The watch list now also holds `config.toml.??????` and `hooks.json.??????` (the
installer's mktemp leftovers; a glob with no match stays literal and prints as an absent path).
`H <path> present|absent` lines record the existence of the Codex home and the skills dir. File
lines carry the permission string (`F <mode> <crc> <size> <path>`, mode from `ls -ld`), so a
`chmod` shows. The `real_home_untouched` gate message and the helper header no longer overstate
the list. New gates: `homeguard_temp_config_leaked_detected`, `homeguard_temp_hooks_leaked_detected`,
`homeguard_config_chmod_detected`, `homeguard_homes_created_detected`.

### WR-02: Symlinks are recorded without their target

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`
**Commit:** 15369c6
**Applied fix:** A symlink is printed as `L <path> -> <target>` (via `readlink`), and a watched
top-level path is walked with `find -H`, so a symlink to a skill directory is descended into.
Retargeting the link and editing a file through it both change the snapshot. New gates:
`homeguard_link_retarget_detected`, `homeguard_link_write_through_detected`,
`homeguard_link_untouched_same`.

### WR-03: `home_snapshot` swallows errors and misreads special names

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`
**Commit:** d46f7e8
**Applied fix:** The `find | while read` loop is replaced by `find -H ... -exec sh -c '...' sh {} +`,
so names arrive as arguments and a newline in a name cannot split an entry. Only regular files
are opened (`[ -f ]`); FIFOs, sockets and devices print as `O <path>` (a FIFO used to block
`cksum` forever, which I reproduced as a hung suite). A non-zero `find` exit adds `E <path>`
instead of being discarded. New gates: `homeguard_newline_name_detected`,
`homeguard_fifo_not_opened` (background run with a 5 s watchdog), `homeguard_unreadable_dir_reported`
(skips when run as root, where `chmod 000` hides nothing).

### WR-04: `no_compiler_path` fails silently

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_path_scrub.sh`, `tests/test_noroute_notice.sh`,
`tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh`
**Commit:** ab30fb5
**Applied fix:** A failed `cd`, `mktemp -d` or `ln -s` now makes the helper print a reason on
stderr, print nothing on stdout and return 1. (I did not use the "farm must be non-empty / hold sh"
check from the review: a directory that only holds the compilers legitimately yields an empty
farm, so the failing step itself is the correct signal.) The four call sites check the status
(`_np=$(no_compiler_path) || { gate ... FAIL; finish; }` and then `PATH=$_np`) so a failure can
no longer leave an empty PATH. New gate: `pathscrub_farm_failure_loud` (mktemp failure and a
shadowed `ln`).

### WR-05: `pathscrub_shared_dir_keeps_tools` and `pathscrub_exe_names` cannot detect a missing `.exe` removal

**Disposition:** fixed
**Files modified:** `tests/test_path_scrub.sh`
**Commit:** a8a4dc0
**Applied fix:** The `.exe` fixtures are `chmod 755`, the shared directory now holds all four
compiler names, and a `farm_holds DIR` helper makes both gates assert directly that the farm
directory contains no file or link named `bbjcpl`, `bbjcpl.exe`, `bbjcplw` or `bbjcplw.exe`
(first PATH entry of the output), besides the `command -v` checks. Mutation check done as above.

### IN-01: `no_compiler_path` turns an unset `IFS` into an empty `IFS`, and skips `..`-prefixed names

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_path_scrub.sh`
**Commit:** 7ba025a
**Applied fix:** The helper records `${IFS+set}`, works with the default IFS value when it was
unset, and runs `unset IFS` at the end. The farm glob gains `"$_ncp_abs"/..?*`. New gates:
`pathscrub_unset_ifs_restored`, `pathscrub_dotdot_name_linked`.

### IN-02: The PATH scrub of `test_tier2_fake.sh` has no load-bearing proof

**Disposition:** fixed
**Files modified:** `tests/test_path_scrub.sh`, `tests/test_tier2_fake.sh`
**Commit:** 8be3be0
**Applied fix:** The reviewer's plain `green`/`mutant` lines would not have worked: the file
scrubs a hard-coded `/usr/bin:/bin`, which the fake compiler directory is not part of, so the
mutant stayed green (I tried it). `test_tier2_fake.sh` now reads `TIER2_TEST_SYSPATH` (default
`/usr/bin:/bin`); `test_path_scrub.sh` sets it to `$WORK/cplbin:/usr/bin:/bin` for the nested
runs. New gates: `pathscrub_green_tier2_fake` and `pathscrub_mutation_tier2_fake` (the mutant
turns `url_refused_remote_http` and others red).

### IN-03: The hard-coded gate count `11` in `release_mut_later_repinned` is brittle

**Disposition:** fixed
**Files modified:** `tests/test_release_text_mutation.sh`
**Commit:** e10b5fb
**Applied fix:** The count of `^gate release_` lines of the unchanged copy is stored as
`_nclean`; the re-pinned case requires `_nall = _nclean` (and `_nclean > 0`). The message prints
the actual count.

### IN-04: The gate-prefix list in `.claude/CLAUDE.md` contradicts its own rule

**Disposition:** fixed
**Files modified:** `.claude/CLAUDE.md`
**Commit:** e39b4bc
**Applied fix:** The "one new prefix of its own" promise is replaced by the facts (`installer_`
is printed by two files; `ci_` and `release_` are string prefixes of `ci_guard_` and
`release_mut_`) and the advice to pick a prefix no existing gate name starts with.
`tier2_syntax_only` is added to the `test_tier2_live.sh` entry, and `test_discovery.sh` is listed
once (`order_` plus free-form names). The same sentence still exists in the generated
`.planning/codebase/CONVENTIONS.md`; I left that analysis file alone.

### IN-05: `home_diff` returns 1 with no output when `diff` itself fails

**Disposition:** fixed
**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`
**Commit:** f475d95
**Applied fix:** `home_diff` prints `home_diff: cannot compare A and B (...)` and returns 1 when
a snapshot file is missing or unreadable or `diff` exits above 1. New gate:
`homeguard_diff_missing_file`.

## Skipped Issues

None.

---

_Fixed: 2026-10-13T04:02:19Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
