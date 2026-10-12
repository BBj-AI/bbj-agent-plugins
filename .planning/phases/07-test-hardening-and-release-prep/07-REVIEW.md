---
phase: 07-test-hardening-and-release-prep
reviewed: 2026-10-12T00:00:00Z
depth: standard
files_reviewed: 10
files_reviewed_list:
  - .claude/CLAUDE.md
  - tests/lib.sh
  - tests/test_exit_contract.sh
  - tests/test_home_guard.sh
  - tests/test_install_codex.sh
  - tests/test_noroute_notice.sh
  - tests/test_path_scrub.sh
  - tests/test_release_text_mutation.sh
  - tests/test_release_text.py
  - tests/test_tier2_fake.sh
findings:
  critical: 0
  warning: 5
  info: 5
  total: 10
status: issues_found
---

# Phase 7: Code Review Report

**Reviewed:** 2026-10-12
**Depth:** standard
**Files Reviewed:** 10
**Status:** issues_found

## Summary

I reviewed the ten files against the diff base. All touched shell files are shellcheck-clean under `-s sh`. Every shell and Python test passes when run one by one. Nothing in the diff can write to the real `~/.codex` or `~/.agents`: `home_snapshot` only calls `find`, `test` and `cksum`, and never opens the auth, session or log files. The PATH-scrub restore logic is correct, and I found no IFS or noglob leak when `no_compiler_path` is called as `PATH=$(...)`. I found no blockers.

The defects sit in two places. `home_snapshot` is a weaker guard than the whole-tree `find -newer` check it replaced, and it fails in ways I reproduced in scratch homes. One `test_path_scrub.sh` gate cannot fail for the thing it claims to prove (also reproduced). The rest is robustness and documentation drift.

## Warnings

### WR-01: `home_snapshot` does not watch everything the installer writes, so leaked temp files and stray directories pass `real_home_untouched`

**File:** `tests/lib.sh:214-236` (watch list at 217-219); consumer `tests/test_install_codex.sh:30,1520-1528`
**Issue:** The old gate ran `find ~/.codex ~/.agents -newer marker`, which covers the whole tree. The new gate covers six paths only. `codex/install-codex.sh` also writes:
- `mktemp "$codex_home/config.toml.XXXXXX"` (installer lines 486 and 561) and `mktemp "$codex_home/hooks.json.XXXXXX"` (line 756). These are temp files in the Codex home. Any run that dies between `mktemp` and `mv` leaves one behind.
- `mkdir -p "$codex_home"` and `mkdir -p "$skills_dir"` (lines 206 and 217). A refusal after these leaves an empty directory.

None of these is one of the six watched paths. I reproduced it: adding `config.toml.AbC123` and a new `newdir` under the Codex home gave `home_diff` rc 0 (no change). A mode change on `config.toml` (`chmod 755`) is also invisible, because the snapshot records only the cksum and size.
The gate message says "nothing under the real ~/.codex or ~/.agents changed". The CLAUDE.md comment says "the six paths the Codex installer can write". Both overstate what is checked. The watched list is also not the installer's full write set (D-08 intends it to be).
**Fix:** Add the temp-file globs and the two parent directories to the snapshot, and record the mode. A sketch for the loop in `home_snapshot`:
```sh
for _hs_p in "$_hs_c/config.toml" "$_hs_c/config.toml.bbj-backup" "$_hs_c/hooks.json" \
  "$_hs_c"/config.toml.?????? "$_hs_c"/hooks.json.?????? \
  "$_hs_c/bbj" "$_hs_s/bbj-programming" "$_hs_s/bbj-web-programming"; do
```
This is safe: a glob that matches nothing stays literal and falls into the `- path` branch. Also print the codex-home and skills-dir existence (`[ -d ]`) as lines. Add a `homeguard_` gate for each (temp file leaked, new dir, chmod).

### WR-02: Symlinks are recorded without their target, so retargeting or writing through a symlinked skill goes undetected

**File:** `tests/lib.sh:220-221, 224-225`
**Issue:** A symlink is printed as `L <path>` and not followed. A maintainer of this repository, which is the home of the two skills, plausibly has `~/.agents/skills/bbj-programming` as a symlink to a checkout. I reproduced this with `bbj-web-programming` as a symlink:
- Retargeting it to another directory gave `home_diff` rc 0.
- Editing a file in the target also gave rc 0.

A real installer run would do exactly this: `cp -R` or `rm -rf` through the link at installer lines 716-723, or replacing the link. The gate then reports `ok`.
**Fix:** Record the target, `printf 'L %s -> %s\n' "$_hs_f" "$(readlink "$_hs_f")"`. If a watched top-level path is a symlink to a directory, also descend into it (`find -H "$_hs_p"`). Add a `homeguard_` gate for a retargeted link.

### WR-03: `home_snapshot` swallows errors and misreads special names, so it can hang or silently omit entries

**File:** `tests/lib.sh:223-232`
**Issue:** Three separate problems in the same loop:
1. `find ... 2> /dev/null` hides permission errors. An unreadable subdirectory is simply not listed, and if it is unreadable at both snapshots, changes inside it never show. I confirmed the `U`/omission behaviour for a `chmod 000` directory.
2. The loop is line-oriented. A filename containing a newline becomes two bogus `U` lines, and the content of that file is never checksummed. I reproduced it: rewriting `bbj/new<LF>line` gave rc 0.
3. `[ -r "$_hs_f" ]` is true for a FIFO, and `cksum < fifo` then blocks forever, which hangs the whole suite. Sockets and devices are not handled either.

These are unlikely inside a skills directory, but the helper reads the maintainer's real home and the gate has no timeout.
**Fix:** Use `find "$_hs_p" -type f -exec cksum {} +` for files, `-type d` for directories and `-type l` for links, with `-print0`-free output (or `-exec printf`). That removes the newline hazard and the FIFO read. Do not discard the `find` errors: print an `E <path>` line when `find` exits non-zero, so a before/after pair cannot both be silently empty.

### WR-04: `no_compiler_path` fails silently, so it can emit a PATH with no `sh` or `awk`

**File:** `tests/lib.sh:175-189`
**Issue:** Every failure in the farm build is ignored. `ln -s ... 2> /dev/null` (line 183) is unchecked, and `mktemp ... || continue` and `cd ... || continue` just drop the directory. If symlinks cannot be created under `$WORK` (a filesystem without symlinks, or MSYS without `winsymlinks`), the helper returns an empty farm for `/usr/bin` and the caller sets `PATH` to a directory with nothing in it. Then `sh`, `awk`, `tr` and `curl` all vanish. In the no-route tests many gates assert silence or "no request", so a hook that cannot run at all can satisfy several of them (`never`, `no_marker`). A wrong PATH should fail loudly, not turn into a test that proves nothing.
**Fix:** After building a farm, check that it is non-empty and holds the tool `sh`, and if not, print a message to stderr and return non-zero. Callers then use `PATH=$(no_compiler_path) || { gate ... FAIL; finish; }`. Or `ls -A "$_ncp_farm" | grep -q .` as a minimum.

### WR-05: `pathscrub_shared_dir_keeps_tools` and `pathscrub_exe_names` cannot detect a missing `.exe` removal

**File:** `tests/test_path_scrub.sh:92, 108-124`; helper line `tests/lib.sh:187`
**Issue:** `bbjcplw.exe` and `bbjcpl.exe` are created with `: >`, so they are not executable. `command -v` only reports executable files. A farm that still contains those two names passes both gates. I confirmed it by mutation: removing `"$_ncp_farm/bbjcpl.exe"` and `"$_ncp_farm/bbjcplw.exe"` from the `rm -f` in a copy of `lib.sh` left every `pathscrub_*` unit gate green. `pathscrub_exe_names` only checks that the directory text is not kept as is, not what the farm holds. On Git for Windows, where `command -v bbjcpl` resolves `bbjcpl.exe`, this is the removal that matters, and it has no test. The shared-dir gate message "the compiler names are gone" is therefore not backed by an assertion for the `.exe` names.
**Fix:** `chmod 755` the `.exe` fixtures, and assert on the farm directory directly:
```sh
for _n in bbjcpl bbjcpl.exe bbjcplw bbjcplw.exe; do
  [ -e "$_out_farm/$_n" ] || [ -L "$_out_farm/$_n" ] && _bad="$_bad $_n"
done
```
using the first PATH entry of `$_out` as `_out_farm`.

## Info

### IN-01: `no_compiler_path` turns an unset `IFS` into an empty `IFS`, and skips `..`-prefixed names

**File:** `tests/lib.sh:161,179,190` and `181`
**Issue:** The header says the caller's IFS is unchanged. `_ncp_ifs=$IFS` followed by `IFS=$_ncp_ifs` turns an unset `IFS` into a set but empty one. I reproduced it: after `unset IFS`, a direct call leaves `${IFS+set}` = `set`. The `PATH=$(...)` form never leaks (it runs in a subshell), but the path_scrub state gate is the only check, and it only tests a set IFS. The glob `.[!.]*` also skips entries whose name starts with `..` (for example `..foo`); I saw `..dd` missing from the farm.
**Fix:** Save with `${IFS+x}` (`if [ "${IFS+set}" = set ]; then _ncp_ifs=$IFS; _ncp_had=1; fi`) and `unset IFS` at the end when it was unset. Add `"$_ncp_abs"/..?*` to the glob list.

### IN-02: The PATH scrub of `test_tier2_fake.sh` has no load-bearing proof

**File:** `tests/test_path_scrub.sh:44-45, 70-71`; `tests/test_tier2_fake.sh:23-24`
**Issue:** The plan's claim is that removing the scrub is caught. The green and mutant gates cover `test_noroute_notice.sh` and `test_exit_contract.sh` only. The third consumer, `SYSPATH` in `test_tier2_fake.sh`, is unproven: nothing shows that a compiler on `/usr/bin` turns its gates red. A later edit that reverts that line would pass.
**Fix:** Add `green tier2_fake test_tier2_fake.sh '^gate url_refused'` and a matching `mutant`, or add a note saying why it is excluded.

### IN-03: The hard-coded gate count `11` in `release_mut_later_repinned` is brittle

**File:** `tests/test_release_text_mutation.sh:118-119`
**Issue:** `[ "$_nall" = 11 ]` couples the mutation test to the number of gates in `test_release_text.py`. Adding or removing a gate there makes this case fail with a message ("11 gates ... for the re-pinned copy") that does not point at the cause. The checks already include "no FAIL and no skip", which is the real property.
**Fix:** Drop the count, or compare against the gate count of the unmutated run (`grep -c '^gate release_' "$WORK/out.clean"` taken earlier in the same file).

### IN-04: The gate-prefix list in `.claude/CLAUDE.md` contradicts its own rule and is not exact

**File:** `.claude/CLAUDE.md:183-186`
**Issue:** The new text says "a new test file takes one new prefix of its own", but:
- `installer_` is listed for both `test_install_codex.sh` and `test_install_pages.sh`.
- `ci_` (`test_ci_gates.sh`) is a string prefix of `ci_guard_` (`test_ci_guards.py`), and `release_` is a prefix of `release_mut_`, so prefix-matching cannot tell the files apart.
- `test_tier2_live.sh` is listed as `live_` only, but it also prints the free-form `tier2_syntax_only` (seen in a run).
- `test_discovery.sh` appears in the prefixed list and again in the free-form list.

**Fix:** Say "the prefixes `sh tests/run.sh` prints" without the "of its own" promise, or fix the overlaps. Add `tier2_syntax_only` to the `test_tier2_live.sh` entry.

### IN-05: `home_diff` returns 1 with no output when `diff` itself fails

**File:** `tests/lib.sh:242-246`
**Issue:** If a snapshot file is missing or unreadable, `cmp -s` fails, `diff` writes an error to stderr, `grep` finds no `<`/`>` lines, and the function returns 1 with empty stdout. The caller prints `changed: ` with nothing after it, which is a FAIL with no explanation.
**Fix:** `diff "$1" "$2" > "$WORK/..."` is not needed; instead capture the `diff` status, and when it is greater than 1 print `home_diff: cannot compare $1 and $2`.

---

_Reviewed: 2026-10-12_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
