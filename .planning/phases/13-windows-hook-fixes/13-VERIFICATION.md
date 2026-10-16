---
phase: 13-windows-hook-fixes
verified: 2026-10-16T04:51:40Z
status: passed
score: 7/7 must-haves verified
covered_files:
  - .planning/phases/13-windows-hook-fixes/13-01-PLAN.md
  - .planning/phases/13-windows-hook-fixes/13-01-SUMMARY.md
  - .planning/phases/13-windows-hook-fixes/13-02-PLAN.md
  - .planning/phases/13-windows-hook-fixes/13-02-SUMMARY.md
  - .planning/phases/13-windows-hook-fixes/13-03-PLAN.md
  - .planning/phases/13-windows-hook-fixes/13-03-SUMMARY.md
  - .planning/phases/13-windows-hook-fixes/13-04-PLAN.md
  - .planning/phases/13-windows-hook-fixes/13-04-SUMMARY.md
  - .planning/phases/13-windows-hook-fixes/13-05-PLAN.md
  - .planning/phases/13-windows-hook-fixes/13-05-SUMMARY.md
  - .planning/phases/13-windows-hook-fixes/13-06-PLAN.md
  - .planning/phases/13-windows-hook-fixes/13-06-SUMMARY.md
  - .planning/phases/13-windows-hook-fixes/13-REVIEW-FIX.md
  - .planning/phases/13-windows-hook-fixes/13-REVIEW.md
  - .planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md
  - .planning/phases/13-windows-hook-fixes/windows-run/launcher.sh
  - .planning/phases/13-windows-hook-fixes/windows-run/runbook.md
  - README.md
  - docs/install-codex.md
  - plugins/bbj/hooks/hooks.json
  - plugins/bbj/scripts/bbj-check.sh
  - tests/fake-bin/curl
  - tests/test_codex_patch.sh
  - tests/test_discovery.sh
  - tests/test_hook_mutation.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_noroute_notice.sh
  - tests/test_tier2_fake.sh
covered_digest: "v3:sha256:635b1d4a83b41e166743b614bde547b428c8806e550a21804a8a02a0dd4b4f34"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 6/7
  previous_commit: 11594e4
  closing_commit: 2affe32
  gaps_closed:
    - "DOCS-06 (plan 13-06 truth 2): every Windows claim on docs/install-codex.md traces to a round 1 or round 3 result block or a 'For the install page' sentence of 13-WINDOWS-RUN.md"
  warnings_closed:
    - "W1: README 'Not run, so not claimed' Windows list now carries the round 3 item (plugin folder whose path holds a $ or a backtick)"
    - "W2: Delete File / Move to filter lines and the 'Codex sets CLAUDE_PLUGIN_ROOT' sentence are now marked as hook-code / Codex-source descriptions, not run observations"
  gaps_remaining: []
  regressions: []
---

# Phase 13: Windows hook fixes Verification Report

**Phase Goal:** The hook on Windows never fails silently because of where Git for Windows is installed, never runs past the 30 s hook timeout on a large patch with no check route, and the backslash path gate guards what it claims to.
**Verified:** 2026-10-16T04:51:40Z
**Status:** passed
**Re-verification:** Yes, after gap closure. The previous report (11594e4, `gaps_found`, 6/7) had one gap (DOCS-06) and two warnings (W1, W2). Commit 2affe32 addresses all three. The failed truth got a full check against the result blocks of 13-WINDOWS-RUN.md. The six truths that passed got a regression check.

The hook behaviour on Windows was judged from the owner's run record `13-WINDOWS-RUN.md`, because CI has no Windows. Everything else was checked against the code and by runs made during this verification.

## What 2affe32 changed

`git diff --stat 11594e4 HEAD` lists four files, all docs or planning: `README.md` (+3/-2), `docs/install-codex.md` (+7/-6), `13-WINDOWS-RUN.md` (one "For the install page" sentence) and `13-REVIEW-FIX.md` (an "Update:" note under "Not done"). No change touches `plugins/`, `tests/` or `windows-run/`. In 13-WINDOWS-RUN.md, no result block, reading or verdict line changed. Only the derived install-page sentence 1 at line 473 changed, and its new qualifier matches the result blocks (see the DOCS-06 trace).

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (FIX-01): a Codex user on Windows whose Git is not at `C:\Program Files\Git` gets a hook that checks the file, or a visible message naming the missing `sh.exe`, never a silent no-op. This is owner-confirmed on real Windows. `layout_hook_command_windows` pins the new `commandWindows`, and `claude plugin validate --strict` passes | VERIFIED (regression check) | The code has not changed since 11594e4. A fresh python3 -I json+hashlib reading of the shipped `commandWindows` gives 1817 chars and sha256 `812f6bbf...3c51`. That equals `launcher.sh:42` `PIN_SHA` and the round 3 `cmd_sha256` (27 as expected, 0 differ, 2 not run, pwsh absent). `sh launcher.sh selftest` gives `selftest ok`. The run here gave `layout_hook_command_windows`, `layout_hook_windows_safe` and `layout_hook_windows_parts` ok, and `ci_validate_root`, `ci_validate_plugins_bbj` and `ci_validate_plugins_bbj_local` ok. Owner evidence: Codex c1-bad was blocked with bbjcpl feedback; c2-bad (Git folder renamed) was "Blocked by hook" with the not-found text; `othersh_none_bbj` and `lad_unset_driveroot_bbj` gave the message rather than silence. Verdict `- FIX-01: met`. All of this is unchanged from the previous report |
| 2 | SC2 (FIX-02): a gate on fakes runs one hook call over a many-file Codex `apply_patch` with no route on the Windows path (5 s connect timeout). Tier 2 is tried once, the other files skip it, and the run ends well under 30 s. When `bbj-ls` answers, every file is checked. Restoring the per-file connect makes the gate fail | VERIFIED (regression check) | `bbj-check.sh` is unchanged since 11594e4: the `# t2-cache` line, the `NR_T2=` reset in `main`, and noconn. The run here gave `tier2_once_windows_refused`, `tier2_once_windows_connect_timeout`, `tier2_transfer_timeout_not_cached`, `tier2_every_file_when_answering` and `hookmut_t2_cache` ok. The previous report's independent mutation (`/# t2-cache$/d` makes both once-gates FAIL with 12 calls) still applies, because neither the script nor the test has changed |
| 3 | SC3 (FIX-03): a mutation that removes the backslash conversion makes `windows_codex_backslash_dotdot_skipped` fail, the unmutated tree passes, and the mutation case is kept in the suite | VERIFIED (regression check) | The run here gave `windows_codex_backslash_dotdot_skipped`, `windows_codex_backslash_dot_control`, `hookmut_backslash_conversion`, `hookmut_dotdot_check`, `hookmut_discovery_control` and `hookmut_tier2_control` ok. The tests are unchanged since 11594e4 |
| 4 | SC4: the exit contract and the safety gates hold: exit 0/2 with empty stdout, `-N` on every compiler call, loopback-only `curl` with `--noproxy '*'` and `--proto =http`, never the hosted check; `sh tests/ci.sh` passes | VERIFIED | Run here: `sh tests/run.sh` gave `SUMMARY: ok=797 fail=0 skip=0`, exit 0. All five lines containing "FAIL" are `ok` gates that describe a nested FAIL. `CI=true sh tests/ci.sh` gave `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, exit 0, with strict validation of all three manifests and shellcheck ok. The `contract_*`, `static_*` and never-execute gates are all ok |
| 5 | Every WR/IN fix in 13-REVIEW-FIX.md is in the code, with a mutation gate wherever one is claimed | VERIFIED (regression check) | The code is unchanged, so the previous audit holds (11/11; the table is carried forward below). The run here gave the 8 `layout_mutation_hook_windows_*` cases and the 2 `hookmut_noconn_*` cases ok. 2affe32 adds only an "Update:" note to 13-REVIEW-FIX.md "Not done": IN-07(d) was later done by 80ad46f. That closes the previous report's Info item about a stale paragraph |
| 6 | The launcher `PIN_SHA` equals the shipped `commandWindows` sha256 | VERIFIED (regression check) | Both are `812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51`, recomputed here. `selftest ok` |
| 7 | DOCS-06 (plan 13-06 truth 2): every Windows claim on `docs/install-codex.md` traces to a round 1 or round 3 result block or a "For the install page" sentence of 13-WINDOWS-RUN.md | VERIFIED (gap closed) | The false qualifier is gone. docs/install-codex.md:76-77 now reads "found Git for Windows under `%ProgramW6432%` (also from a 32-bit PowerShell), `%ProgramFiles(x86)%`, ...". That is backed by `w6432_bad` and `wow64_w6432_bad`. Both use layout `w6432` (launcher.sh `layout_set`: only `ProgramW6432` holds Git; ProgramFiles and ProgramFiles(x86) are the empty folder). The second runs on host `powershell32`. `%ProgramFiles%` was removed from the found-list, which is more conservative than the fix the previous report suggested. It stays in the ordered lookup list, which describes the pinned code (install-page sentence 1). Both warnings are closed too (W1, W2 below). Every Windows claim the phase added to the page and the README now traces, or is marked as a code or source description; see "DOCS-06 trace" |

**Score:** 7/7 truths verified (0 present, behavior-unverified)

### DOCS-06 trace (Windows claims added in Phase 13, as of 2affe32)

Scope: the Windows lines added to `docs/install-codex.md` and `README.md` in `git diff 87214d9..HEAD`. The older Windows lines come from the Phase 9/10 run records, and this phase did not touch them: the header dates, "Hook failed" before `commandWindows`, the Git Bash compiler run, `bbj-local` on Windows, and the README Verified table.

| Claim | Source in 13-WINDOWS-RUN.md / code | Status |
|-------|------------------------------------|--------|
| Ordered lookup list, items 1-5 (`%ProgramW6432%` first, the same folder as `%ProgramFiles%` unless PowerShell is 32-bit) | Install-page sentence 1; code pinned by `layout_hook_command_windows`; hooks.json `foreach ($r in $env:ProgramW6432, $env:ProgramFiles, ...)` | traced (code description) |
| Found under `%ProgramW6432%` | round 3 `w6432_bad` | traced |
| "(also from a 32-bit PowerShell)", now attached to `%ProgramW6432%` | round 3 `wow64_w6432_bad` (host `powershell32`, layout `w6432`) | **traced (gap closed)** |
| Found under `%ProgramFiles%` | removed from the found-list in 2affe32 | no claim made |
| `%ProgramFiles(x86)%`, `%LOCALAPPDATA%\Programs`, the `%USERPROFILE%` form | `pf86_bad`, `localappdata_bad`, `lad_unset_profile_bad` | traced |
| `bin`, `usr\bin`, `cmd` on `PATH`; `mingw64\bin` git; past a non-Git `sh` | `sh_on_path_bad` (GITBIN_P), `usrbin_on_path_bad` (GITUSR_P), `git_on_path_bad` (GITCMD_P), `git_mingw_on_path_bad`, `othersh_then_git_bad` | traced |
| Blocked with the not-found message, the places looked, the fix | Install-page sentence 2; c2-bad round 3 | traced |
| The rule names `Add File`, `Update File`, `Delete File`, `Move to`, in any case | The run used Add File (`p_bad`, launcher.sh:199-201; Codex "Added ...") and Update File (`p_updsrc`, launcher.sh:629, `x.SRC`; Codex c2-websrc "Edited page.html"). The page now says so: "(the test run used `Add File` and `Update File` lines; the other two follow the same rule in the hook)". hooks.json regex: `(Add File\|Update File\|Delete File\|Move to): ` | **traced (W2 closed)** |
| The text of the change does not count; `img.src` | Install-page sentence 3; `none_web_src`, c2-websrc | traced |
| About 8 KB or longer gets the message | `none_long_notes` (payload over 8192 bytes), rounds 1 and 3 | traced |
| Codex starts the hook with the settings `PATH` | Install-page sentence 5; O1 | traced |
| Ends in `exit $LASTEXITCODE` so exit 2 reaches Codex | c1-bad "Blocked by hook" | traced |
| Plugin folder from `CLAUDE_PLUGIN_ROOT` when set; a `$` or a backtick reaches `sh` as written | `dollar_root_bad` (CLAUDE_PLUGIN_ROOT set to a root holding `$` and a backtick: rc=2, bbjcpl) | traced |
| "Codex's source sets that variable for hooks, which a test run has not observed on Windows" | 13-REVIEW-FIX WR-04 (source reading); round 3 c1 note "cannot tell whether the script path came from CLAUDE_PLUGIN_ROOT" | **marked not observed (W2 closed)** |
| Codex page Not-run list | Install-page sentence 7 (verbatim) | traced |
| README "Not run, so not claimed" Windows list, now ending "and with a plugin folder whose path holds a `$` or a backtick" | Install-page sentence 7; the README list sits under "on Windows the Codex plugin route", which carries the record's "under Codex" | **traced (W1 closed)** |
| Observed paragraph, 2026-10-16 | Round 3 "Sentence for the docs (round 3)" for the launcher and for Codex cases 1 and 2; BBJ_HOME `C:\bbx` | traced (see Info 1) |
| Timeout paragraph | The 13-06 exception: it describes the code, says "not observed in a run", and the FIX-02 gates back it | traced (allowed exception) |

The edited install-page sentence 1 (13-WINDOWS-RUN.md:473) now adds "(round 3; `%ProgramFiles%` on its own in round 1, since with the shipped string `%ProgramW6432%`, the same folder for a 64-bit PowerShell, is looked at first)". This matches the record. Round 1's string started with `$env:ProgramFiles` (round 1 c1-hooks, line 360), and round 1 `default_bad` ran with the real environment. Round 3 `default_bad` also ran with the real environment (`asis`), where `ProgramW6432` comes first. No round 3 layout offers Git through ProgramFiles alone (launcher.sh `layout_set`).

### Review fix audit (13-REVIEW-FIX.md), carried forward. The code is unchanged since 11594e4

| Finding | In the code | Gate (claimed, then found) | Status |
|---------|-------------|----------------------------|--------|
| WR-01 any `sh` on PATH | Statement 3 accepts an `sh` only when `$q\usr\bin\cygpath.exe` or `$q\bin\cygpath.exe` exists | `layout_mutation_hook_windows_any_sh ok`; round 3 `usrbin_on_path_bad`, `othersh_none_bbj`, `othersh_then_git_bad` | VERIFIED |
| WR-02 LOCALAPPDATA guard | `$(if ($env:LOCALAPPDATA) {...} elseif ($env:USERPROFILE) {...})` | `layout_mutation_hook_windows_localappdata ok`; `lad_unset_profile_bad`, `lad_unset_driveroot_bbj` | VERIFIED |
| WR-03 filter matched content | Name-anchored regex over the patch headers and `"file_path"` | `layout_mutation_hook_windows_any_mention ok`; `none_web_src`, `none_update_src`, c2-websrc | VERIFIED |
| WR-04 plugin root expanded by PowerShell | `$b = "$env:CLAUDE_PLUGIN_ROOT/..."`, with the substituted text only when the variable is unset | `layout_mutation_hook_windows_root_text ok`; `rootvar_unset_bad`, `dollar_root_bad` | VERIFIED |
| IN-01 noconn halves ungated | Two oncegate cases | `tier2_noconn_needs_no_ip`, `tier2_noconn_needs_zero_time`, `hookmut_noconn_ip`, `hookmut_noconn_time` ok | VERIFIED |
| IN-02 git-derived path for mingw64\bin | `(Split-Path -Leaf $q) -match '^(mingw\|clang\|ucrt)'` | `layout_mutation_hook_windows_git_cmd_only ok`; `git_mingw_on_path_bad` | VERIFIED |
| IN-03 32-bit host | `$env:ProgramW6432` first | `layout_mutation_hook_windows_no_w6432 ok`; `w6432_bad`, `wow64_w6432_bad` | VERIFIED |
| IN-04 trailing space | `(echo ...)1>&2` x3 | `layout_mutation_hook_windows_trailing_space ok`; round 3 shows no trailing space | VERIFIED |
| IN-05 stale comments | bbj-check.sh comments | comments only | VERIFIED |
| IN-06 control comment | test_discovery.sh comment | comment only | VERIFIED |
| IN-07 accepted limits | Disposition in 13-REVIEW.md; (d) done by 80ad46f, now also noted in 13-REVIEW-FIX.md (2affe32) | none claimed | VERIFIED |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/hooks/hooks.json` | the review-fix `commandWindows`; `command`, matcher and timeout unchanged | VERIFIED | sha256 equals the pin and the round 3 reading; unchanged since 11594e4 |
| `plugins/bbj/scripts/bbj-check.sh` | the tier-2 cache, noconn, comments in line with FIX-02 | VERIFIED | unchanged since 11594e4 |
| `tests/test_layout.py` | the 10-statement pin, the forbidden and parts guards, 14 Windows mutation cases | VERIFIED | all ok in the run here |
| `tests/test_tier2_fake.sh`, `tests/test_hook_mutation.sh` | the once and noconn gates, 7 `hookmut_` gates | VERIFIED | all ok |
| `tests/test_discovery.sh` | the bait and the control | VERIFIED | ok |
| `windows-run/launcher.sh`, `runbook.md` | the round 3 cases, PIN_SHA, the H5 runbook fix | VERIFIED | `selftest ok`; unchanged |
| `13-WINDOWS-RUN.md` | the round 3 readings, the install-page sentences, the verdict | VERIFIED | `- FIX-01: met`. 2affe32 changed only install-page sentence 1, in line with the result blocks |
| `docs/install-codex.md` | the shipped lookup, the message, and the claims, each backed by the record | VERIFIED | the gap is closed; W2 is closed |
| `README.md` | the not-run sentence from the record | VERIFIED | W1 is closed |

### Key Link Verification

| From | To | Via | Status |
|------|----|-----|--------|
| `hooks.json` commandWindows | `test_layout.py` HOOK_COMMAND_WINDOWS | exact equality | WIRED (gate ok) |
| `hooks.json` commandWindows | `launcher.sh` PIN_SHA | extract_cmd + sha256 | WIRED (selftest ok; sha recomputed here) |
| `hooks.json` commandWindows | `test_codex_patch.sh` | python3 -I reader | WIRED (`plugin_route_command_windows ok`) |
| `test_hook_mutation.sh` mutants | `bbj-check.sh` lines | sed + `cmp -s` no-op guard | WIRED (all 7 ok) |
| `no_tier1_route` cache line | the `NR_T2=` reset in `main` | global | WIRED |
| run record result blocks / "For the install page" | `docs/install-codex.md`, `README.md` | copied sentences | WIRED (was PARTIAL; the 32-bit attribution is fixed) |
| `test_install_pages.sh` need list | the Codex page | grep -qF | WIRED (`codex_*`, `readme_*`, `link_*` gates ok) |

### Data-Flow Trace (Level 4)

Not applicable: the phase renders no dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| The gap-closure commit changes only docs | `git diff --stat 11594e4 HEAD` | 4 files: README.md, docs/install-codex.md, 13-WINDOWS-RUN.md, 13-REVIEW-FIX.md | PASS |
| The shipped string equals the pin | python3 -I json + hashlib over hooks.json | 1817 chars, `812f6bbf...3c51` | PASS |
| PIN_SHA equals the shipped string; the launcher self-test | `grep PIN_SHA= launcher.sh`; `sh launcher.sh selftest` | equal; `selftest ok` | PASS |
| The 32-bit case offers Git only via ProgramW6432 | read launcher.sh `layout_set` w6432 and `runcase wow64_w6432_bad powershell32 w6432` | LW64 set; LPF and LPF86 = `\lay\empty` | PASS (backs the new qualifier) |
| The run used Add File and Update File | launcher.sh:199-201 (`payload`), :629 (`p_updsrc`) | Add File, Update File | PASS (backs the W2 wording) |
| No debt markers in the changed files | `grep -n -E 'TBD\|FIXME\|XXX'` over the 4 changed files | none (exit 1) | PASS |
| Full suite | `sh tests/run.sh` | ok=797 fail=0 skip=0, exit 0 | PASS |
| CI entry point | `CI=true sh tests/ci.sh` | ok=6 fail=0 skip=0 run_sh_exit=0, exit 0 | PASS |

### Probe Execution

No `scripts/*/tests/probe-*.sh` exist, and no plan declares a probe. Step 7c: not applicable.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| FIX-01 | 13-02, 13-04, 13-05, 13-06 | Git outside `C:\Program Files\Git` gets a working hook or a visible message, never a silent no-op | SATISFIED | Truth 1; the round 3 verdict is `met` on the shipped sha256 |
| FIX-02 | 13-01, 13-03, 13-06 | a many-file `apply_patch` with no route stays within 30 s | SATISFIED | Truth 2 |
| FIX-03 | 13-03, 13-06 | the backslash gate fails when the conversion is removed | SATISFIED | Truth 3 |
| DOCS-06 (Phase 11, the rule applied by 13-06) | 13-06 | per-platform claims backed by a run record | SATISFIED (was BLOCKED) | Truth 7 |

No orphaned requirements: REQUIREMENTS.md maps only FIX-01..03 to Phase 13.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `plugins/bbj/scripts/bbj-check.sh` | 334 | `\uXXXX` | Info | escape notation in a comment, not a debt marker (carried forward) |
| `README.md` | 69-70 | short wrapped line ("backtick. The CHANGELOG lists what each release was tested") | Info | cosmetic only; the Markdown renders the same |

There are no TBD, FIXME or XXX markers in any file changed by 2affe32. The previous Info item (13-REVIEW-FIX.md "Not done" was stale) is resolved by the "Update:" note.

### Advisory (New Scope, Unevidenced)

None.

### Warnings (previous report)

- **W1, the README not-run sentence: closed.** README.md:66-70 now ends the Windows list with "and with a plugin folder whose path holds a `$` or a backtick". That matches the round 3 "Not run" install-page sentence. The README list sits under "on Windows the Codex plugin route", which carries the record's "under Codex".
- **W2, code descriptions on the Codex page: closed.** The filter sentence now says the run used `Add File` and `Update File` lines and that "the other two follow the same rule in the hook". The `CLAUDE_PLUGIN_ROOT` sentence now says the hook takes the variable "when that is set". That part is backed by `dollar_root_bad`. The page adds "Codex's source sets that variable for hooks, which a test run has not observed on Windows."

### Info (not gaps)

1. The Observed paragraph says the hook "compile-checked a BBj file with Git for Windows in each of the places it looks". It is the round 3 docs sentence of the record, copied verbatim, and it is literally true: in round 3 `default_bad` (real environment), Git sat in `%ProgramFiles%\Git\bin`. The hook reached that folder through the `%ProgramW6432%` entry, which names the same folder in a 64-bit PowerShell. The page no longer claims that `%ProgramFiles%` on its own found Git.
2. The residual risks carry forward unchanged. The `noconn` write-out shape of Git for Windows' curl is unmeasured (RESEARCH A7), but it fails safe. Codex setting `CLAUDE_PLUGIN_ROOT` on Windows is now marked on the page as not observed. pwsh and a real per-user install remain not run, as the record, the page and the README all say.

### Human Verification Required

None. The Windows proof for the shipped string is already recorded (round 3, 2026-10-16), and the owner decisions on W1 and W2 were resolved by 2affe32.

### Gaps Summary

There are no gaps. The single gap of the previous report is closed. DOCS-06: the Codex page attached "(also from a 32-bit PowerShell)" to `%ProgramFiles%`. 2affe32 now attaches it to `%ProgramW6432%`, which is what `wow64_w6432_bad` exercised, and drops the unbacked `%ProgramFiles%` found-claim. Warnings W1 and W2 are closed in the same commit. The commit changes only docs and planning text. The code, the tests, the launcher and the result blocks are unchanged, and both suites are green (`ok=797 fail=0 skip=0`; `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`). FIX-01, FIX-02 and FIX-03 remain satisfied as in the previous report. The phase goal is achieved.

---

_Verified: 2026-10-16T04:51:40Z_
_Verifier: Claude (gsd-verifier)_
