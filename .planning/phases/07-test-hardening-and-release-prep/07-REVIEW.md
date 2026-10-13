---
phase: 07-test-hardening-and-release-prep
reviewed: 2026-10-13T00:00:00Z
depth: standard
files_reviewed: 9
files_reviewed_list:
  - .claude/CLAUDE.md
  - tests/lib.sh
  - tests/test_exit_contract.sh
  - tests/test_home_guard.sh
  - tests/test_install_codex.sh
  - tests/test_noroute_notice.sh
  - tests/test_path_scrub.sh
  - tests/test_release_text_mutation.sh
  - tests/test_tier2_fake.sh
findings:
  critical: 0
  warning: 2
  info: 4
  total: 6
status: issues_found
---

# Phase 7: Code Review Report (re-review after the ten fix(07) commits)

**Reviewed:** 2026-10-13
**Depth:** standard
**Files Reviewed:** 9
**Status:** issues_found

## Summary

I re-reviewed the nine files as they stand at HEAD, against the ten `fix(07):` commits made after 2b8cc19. `shellcheck -s sh` is clean on all eight shell files. `sh tests/run.sh` is green: `SUMMARY: ok=803 fail=0 skip=0`. `test_home_guard.sh` also passes under bash.

I checked each of the ten earlier findings against the code and found them fixed as described. Specifically:
- `no_compiler_path` now fails loudly (rc 1, nothing on stdout, a reason on stderr) and all three callers check it.
- An unset `IFS` stays unset, and `..`-prefixed names reach the farm.
- The `.exe` fixtures are executable and `farm_holds` inspects the farm directly.
- `home_snapshot` now watches the temp-file globs, both parent directories, modes, and symlink targets. It reads names as arguments, so a newline in a name cannot split an entry. A FIFO is not opened.
- `home_diff` explains itself when it cannot compare.
- The gate-prefix list in `.claude/CLAUDE.md` matches the prefixes `tests/run.sh` prints. I cross-checked this against the run output.

The fixes did not introduce a regression in the suite. I found no blocker. Two warnings remain in `home_snapshot`: both leave `real_home_untouched` able to report `ok` while a write goes unseen. I reproduced both in scratch homes under the scratchpad directory. The four info items are minor.

## Warnings

### WR-01: A watched path that is a symlink to a regular file is recorded by target only, so a write through it goes undetected

**File:** `tests/lib.sh:261-274` (classifier in `home_snapshot`); the claim is made at `tests/lib.sh:238-240`
**Issue:** The `-H` fix for the earlier WR-02 follows a watched top-level symlink only when it points to a directory. `find -H` descends into such a link, so its children print as `F` lines. When the top-level path is a symlink to a regular file, `find` visits exactly one entry. The classifier tests `[ -L "$_f" ]` first, prints `L <path> -> <target>`, and never reads the content.

A dotfile-managed `~/.codex/config.toml` or `hooks.json` that is a symlink into a dotfiles checkout is common. The installer writes through such a link with `cat "$tmp" > "$config"` (installer lines 506 and 614). I reproduced it: with `config.toml` linked to a file elsewhere, I rewrote the target's content (`model="a"` to `model="b"`) through the link. `home_diff` returned rc 0 and the snapshot held only the unchanged `L` line. The gate would print `ok` after the installer had modified the real file, so the guard has a hole exactly where a maintainer with symlinked config is most exposed.

**Fix:** For a symlink, also print the content of what it resolves to when that is a regular file. In the classifier:
```sh
if [ -L "$_f" ]; then
  printf "L %s -> %s\n" "$_f" "$(readlink "$_f")"
  # the content behind a file link: a write through the link changes this and nothing else
  if [ -f "$_f" ] && [ -r "$_f" ]; then
    printf "T %s %s\n" "$(cksum < "$_f")" "$_f"
  fi
elif [ -d "$_f" ]; then
```
Add a `homeguard_` gate: link `config.toml` to a file under `$WORK`, rewrite the target, and expect `differ`. Add a second gate that touches the target and expects `same`.

### WR-02: An incomplete snapshot compares equal to itself, so `real_home_untouched` reports `ok` when part of the home could not be read

**File:** `tests/lib.sh:274, 279`; consumer `tests/test_install_codex.sh:1522-1527`
**Issue:** The `E <path>` line (a `find` failure for an unreadable directory) exists so a hole is visible, but nothing acts on it. The same `E` line appears in the `before` and `after` snapshots, so `home_diff` sees no difference and the gate prints `ok`, even though everything below that path was skipped on both sides. A change inside an unreadable subtree of `~/.codex/bbj` or a skill directory therefore passes.

The same blindness applies if the walk produces nothing at all. With `PATH=/nonexistent` I ran `home_snapshot` and got `sort: not found` on stderr and an empty file. Two empty snapshots are identical. In `test_install_codex.sh` PATH is not narrowed at either call site today, so this is a latent failure rather than a live one. The gate message still claims the full watched set was compared.

**Fix:** Make the consumer fail closed on an incomplete snapshot. In `test_install_codex.sh`, before comparing:
```sh
if [ ! -s "$WORK/home.after" ] || grep -q '^E ' "$WORK/home.before" "$WORK/home.after"; then
  gate real_home_untouched skip "the snapshot of the real home is empty or incomplete: $(grep -h '^E ' "$WORK/home.after" | head -n 3 | tr '\n' ' ')"
elif _changed=$(home_diff ...); then
```
`skip` suits an unreadable directory (this is an environment fact, not a regression). Use `FAIL` instead if `CI=true`, as the project rule for missing prerequisites says. Add a `homeguard_` gate that puts an `E` line in both snapshots and checks that the consumer logic does not report `ok`.

## Info

### IN-01: The temp-file globs in `home_snapshot` silently stop expanding when the caller has `set -f`

**File:** `tests/lib.sh:252-254`
**Issue:** `config.toml.??????` and `hooks.json.??????` are expanded by the shell. A caller that has noglob on gets the literal pattern, which prints as `- <path>/config.toml.??????`. Leaked temp files then go unwatched with no signal. I reproduced it with `set -f` before the call: the output shows only the literal-pattern lines. No caller sets `-f` today. `no_compiler_path` also toggles `-f`, but it restores it, so there is no live path to this. The helper still depends on ambient shell state.
**Fix:** Save and restore it locally in the same way as `no_compiler_path`: `case "$-" in *f*) _hs_nf=1 ;; *) _hs_nf=0 ;; esac; set +f` at the top and `[ "$_hs_nf" = 0 ] || set -f` at the end. Or use `find "$_hs_c" -maxdepth 1 -name 'config.toml.??????'` (`-maxdepth` is not POSIX, so a `-path` test with `-prune` is the portable form).

### IN-02: Directory modes are not recorded, and `readlink` is outside the POSIX tool list

**File:** `tests/lib.sh:265-266, 224-228, 264`
**Issue:** `D <path>` lines carry no mode, while `F` lines do. The header says "never a time" and claims a mode change is seen. This holds for files only: a `chmod` on `~/.codex/bbj` or a skill directory is invisible. The installer's `chmod` effects on directories are not a current concern, but the file-only coverage is not stated. Separately, `readlink` is not POSIX. `CLAUDE.md` lists the tools the shipped hook uses; these are test-only helpers, so this is a note, not a rule violation. If `readlink` is missing, the `L` line prints an empty target and silently loses the retarget detection that `homeguard_link_retarget_detected` proves.
**Fix:** Print the mode for directories (`"$(ls -ld "$_f" | awk "{ print \$1 }")"`) in the `D` line. Say in the header that only file modes are covered if you leave it as is. Check `command -v readlink` once and fall back to `ls -l | sed 's/.* -> //'`.

### IN-03: `TIER2_TEST_SYSPATH` is read from the ambient environment

**File:** `tests/test_tier2_fake.sh:26`; `tests/test_path_scrub.sh:50-52, 82-84`
**Issue:** The seam is read with `${TIER2_TEST_SYSPATH:-/usr/bin:/bin}` and set by `test_path_scrub.sh`, which unsets it right after each use. If a developer's shell exports it, a plain `sh tests/run.sh` runs `test_tier2_fake.sh` against a PATH that is not `/usr/bin:/bin`, with no hint in the gate output. `test_path_scrub.sh` unsets `FAKE_LOG` and its relatives at the top but not this variable, so a stale value there would also change the first two nested runs (they do not read it, so only the tier2 nested run is affected). The risk is small; it only affects local runs.
**Fix:** Add `TIER2_TEST_SYSPATH` to the `unset` line at the top of `tests/test_path_scrub.sh`. Optionally make `tests/run.sh` unset it before each test file.

### IN-04: `homeguard_fifo_not_opened` leaves orphans on failure, and `homeguard_unreadable_dir_reported` skips as root

**File:** `tests/test_home_guard.sh:176-190, 196-206`
**Issue:** On the failure path the test does `kill "$_pid"`, which ends the background subshell but not the `find` and `cksum` children blocked on the FIFO. They stay alive until the run exits. That only happens when the guard is already broken, so it is cosmetic. The unreadable-directory gate reports `skip` when the suite runs as root. A containerised CI run as root would skip without the `CI=true` failure that the project rule applies to a missing prerequisite. The GitHub-hosted runner is not root, so this is not a live gap.
**Fix:** For the FIFO, `kill -- -"$_pid"` is not portable. Put the snapshot in its own `sh -c` and `pkill -P` its children, or accept the leak and say so in a comment. For the root skip, make it `FAIL` when `CI=true` and the user is root, or use a technique that works as root (a directory whose permission cannot be bypassed, such as a path component that is a file) so the gate still runs.

---

_Reviewed: 2026-10-13_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
