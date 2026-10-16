---
phase: 13-windows-hook-fixes
verified: 2026-10-16T04:42:51Z
status: gaps_found
score: 6/7 must-haves verified
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
covered_digest: "v3:sha256:6a0ad52f07723ee74354d556aa5f8ce29a11bac22ce8f2f85a08fac437f3c5bd"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 4/4
  previous_commit: 4417405
  reason: "stale after the code review fixes (4f1d31c..a60fb85), round 3 of the Windows run (3aa3f40) and the Codex page update (101c171)"
  gaps_closed: []
  gaps_remaining: []
  regressions: []
gaps:
  - truth: "DOCS-06 (plan 13-06 truth 2): every Windows claim on docs/install-codex.md traces to a round 1 or round 3 result block or a 'For the install page' sentence of 13-WINDOWS-RUN.md"
    status: failed
    reason: "The lookup-coverage sentence added in 101c171 says a test run found Git for Windows under '%ProgramFiles% (also from a 32-bit PowerShell)'. No run backs this. The only 32-bit case, wow64_w6432_bad, uses layout w6432. That layout sets ProgramFiles and ProgramFiles(x86) to the empty folder and offers Git only through ProgramW6432 (launcher.sh layout_set; runbook.md:172 'as w6432_bad, in the 32-bit Windows PowerShell of SysWOW64'; w6432_bad is 'only ProgramW6432 holds Git'). So the 32-bit host found Git under %ProgramW6432%, not %ProgramFiles%. In a real 32-bit host, %ProgramFiles% is the (x86) folder, and no case ran that."
    artifacts:
      - path: "docs/install-codex.md"
        issue: "lines 76-77: '(also from a 32-bit PowerShell)' is attached to %ProgramFiles%; the round 3 record (wow64_w6432_bad, IN-03) supports it only for %ProgramW6432%"
    missing:
      - "Move the qualifier to the right variable, for example: 'under `%ProgramW6432%` (also from a 32-bit PowerShell), `%ProgramFiles%`, `%ProgramFiles(x86)%`, ...'. Note that %ProgramFiles% as the place that found Git is backed only by round 1 (default_bad, the earlier string). With the shipped string, ProgramW6432 comes first and holds the same folder in a 64-bit host, and no round 3 layout offers Git through ProgramFiles alone."
      - "In the same edit, optionally bring the README 'Not run, so not claimed' Windows list in line with the round 3 'Not run' sentence, which adds 'under Codex, a plugin folder whose path holds a `$` or a backtick' (warning W1 below)"
---

# Phase 13: Windows hook fixes Verification Report

**Phase Goal:** The hook on Windows never fails silently because of where Git for Windows is installed, never runs past the 30 s hook timeout on a large patch with no check route, and the backslash path gate guards what it claims to.
**Verified:** 2026-10-16T04:42:51Z
**Status:** gaps_found
**Re-verification:** Yes. The previous report (4417405, `passed`, 4/4) went stale: after it came the code review fixes (4f1d31c..a60fb85, a new `commandWindows`), round 3 of the Windows run (3aa3f40) and the Codex page update (101c171). It had no `gaps:`, so every must-have was verified again from scratch.

The hook behaviour on Windows was judged from the owner's run record `13-WINDOWS-RUN.md`, because CI has no Windows. Everything else was checked against the code, and by runs made during this verification.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (FIX-01): a Codex user on Windows whose Git is not at `C:\Program Files\Git` gets a hook that checks the file, or a visible message naming the missing `sh.exe`, never a silent no-op. This is owner-confirmed on real Windows. `layout_hook_command_windows` pins the new `commandWindows`, and `claude plugin validate --strict` passes | VERIFIED | The shipped `commandWindows` is 1817 chars with sha256 `812f6bbf...3c51` (computed here with python3 json+hashlib). It has no backslash directly before a double quote. `git diff 1199d82 HEAD -- plugins tests windows-run/launcher.sh` is empty, so the string the owner ran in round 3 is the string that ships. Round 3 (Windows 10 19045.6466, Git 2.52.0, PS 5.1, Codex 0.162.1, checkout 1199d82) gave `cmd_sha256` equal to the pin: 27 as expected, 0 differ, 2 not run (pwsh absent). The cases include `othersh_none_bbj`: a non-Git `sh` alone on PATH gives rc=2 with the message, not silence (the WR-01 silent no-op is gone). They also include `lad_unset_driveroot_bbj` (the message, not the drive-root `sh.exe`) and `none_web_src` (silent) / `none_update_src` (message). Under Codex, c1-bad gave bbjcpl feedback with a new trust prompt, and c2-bad (Git folder renamed) was "Blocked by hook" with the not-found text, no trailing spaces. c2-notes and c2-websrc were silent. Verdict line: `- FIX-01: met`, re-judged for the shipped sha256. Gates `layout_hook_command_windows ok`, `layout_hook_windows_safe ok` (9 forbidden constructs), `layout_hook_windows_parts ok` (14 parts), and `ci_validate_root/plugins_bbj/plugins_bbj_local ok` |
| 2 | SC2 (FIX-02): a gate on fakes runs one hook call over a many-file Codex `apply_patch` with no route on the Windows path (5 s connect timeout). Tier 2 is tried once, the other files skip it, and the run ends well under 30 s. When `bbj-ls` answers, every file is checked. Restoring the per-file connect makes the gate fail | VERIFIED | `bbj-check.sh:254` `case "$NR_T2" in refused\|nocurl\|badurl\|noconn) return 1 ;; esac # t2-cache`, reset at `:681`. The noconn test is at `:307-308`. Since 4417405, bbj-check.sh changed in comments only (non-comment diff empty). Gates: `tier2_once_windows_refused ok` and `tier2_once_windows_connect_timeout ok` (12 files, 1 curl call, `--connect-timeout 5`), `tier2_transfer_timeout_not_cached ok` (12 calls), `tier2_every_file_when_answering ok` (12 requests). I ran an independent mutation here: a scratch copy with `/# t2-cache$/d` makes both once-gates FAIL with 12 calls, and the copied test exits rc=1. The kept case `hookmut_t2_cache ok`. The time bound holds by construction: one call, capped by `--connect-timeout 5 -m 12`. |
| 3 | SC3 (FIX-03): a mutation that removes the backslash conversion makes `windows_codex_backslash_dotdot_skipped` fail, the unmutated tree passes, and the mutation case is kept in the suite | VERIFIED | Unmutated: `windows_codex_backslash_dotdot_skipped ok` (the bait `sub\..\..\x.bbj` lies inside the workspace), `windows_codex_backslash_dot_control ok`. Kept cases: `hookmut_backslash_conversion ok`, `hookmut_dotdot_check ok`, controls `hookmut_discovery_control ok` and `hookmut_tier2_control ok`. Each `mutant` refuses a no-op mutation (`cmp -s`). test_discovery.sh changed only in a comment since 4417405 (IN-06). |
| 4 | SC4: the exit contract and the safety gates hold: exit 0/2 with empty stdout, `-N` on every compiler call, loopback-only `curl` with `--noproxy '*'` and `--proto =http`, never the hosted check; `sh tests/ci.sh` passes | VERIFIED | All 62 `contract_*` gates are ok. Also ok: `static_compiler_call`, `static_url_hosts`, `static_curl_call`, `static_notice_single_writer`, `static_timeout_command`, and the never-execute gates. Run here: `sh tests/run.sh` gave `SUMMARY: ok=797 fail=0 skip=0`, exit 0. `CI=true sh tests/ci.sh` gave `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, exit 0. |
| 5 | Every WR/IN fix in 13-REVIEW-FIX.md is in the code, with a mutation gate wherever one is claimed | VERIFIED | Per finding, see "Review fix audit" below. 11 of 11 are present. Each of the 8 claimed layout mutation cases and the 2 claimed `hookmut_` cases exists and prints ok. The `mutation_case` helper fails a mutation that changes nothing, so no gate is vacuous. |
| 6 | The launcher `PIN_SHA` equals the shipped `commandWindows` sha256 | VERIFIED | `launcher.sh:42` is `PIN_SHA=812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51`, equal to the computed sha256 of the shipped string. `sh launcher.sh selftest` gives `selftest ok` (it checks the pin through `extract_cmd`). `shellcheck -s sh launcher.sh` is clean. The round 3 launcher block reads `cmd_sha256: 812f6bbf...3c51 (equals the launcher pin)`. In the Codex home, the installed hooks.json has the same SHA256 as the clone's (owner note 5). |
| 7 | DOCS-06 (plan 13-06 truth 2): every Windows claim on `docs/install-codex.md` traces to a round 1 or round 3 result block or a "For the install page" sentence of 13-WINDOWS-RUN.md | FAILED | One observation claim has no run behind it: "A test run on Windows found Git for Windows under ... `%ProgramFiles%` (also from a 32-bit PowerShell)". The 32-bit case found Git through `%ProgramW6432%` (see gaps). Every other Phase 13 claim traces; see "DOCS-06 trace" below. Two warnings remain open for an owner decision (W1, W2). |

**Score:** 6/7 truths verified (0 present, behavior-unverified)

### Review fix audit (13-REVIEW-FIX.md)

| Finding | In the code | Gate (claimed → found) | Status |
|---------|-------------|------------------------|--------|
| WR-01 any `sh` on PATH | Statement 3 loops over `Get-Command sh` and accepts an `sh` only when `$q\usr\bin\cygpath.exe` or `$q\bin\cygpath.exe` exists | `layout_mutation_hook_windows_any_sh ok`; launcher `usrbin_on_path_bad`, `othersh_none_bbj`, `othersh_then_git_bad` as expected in round 3 | VERIFIED |
| WR-02 LOCALAPPDATA guard | `$(if ($env:LOCALAPPDATA) {...} elseif ($env:USERPROFILE) {...})`; `WINDOWS_FORBIDDEN` refuses the unconditional item | `layout_mutation_hook_windows_localappdata ok`; `lad_unset_profile_bad`, `lad_unset_driveroot_bbj` (subst W:) as expected | VERIFIED |
| WR-03 filter matched content | Name-anchored regex over `*** Add/Update/Delete File:` / `*** Move to:` / `"file_path"`, ending before `\n`/`\r` or `"` | `layout_mutation_hook_windows_any_mention ok`; `none_web_src` silent, `none_update_src` message; Codex c2-websrc silent. Spot-check here (python re, case-insensitive, as `-match` is) over 9 JSON payloads: Add/Update(`.SRC`)/Delete/Move/`file_path` match; `img.src` content, `x.bbj.md`, `notes.md` do not; 0 differ | VERIFIED |
| WR-04 plugin root expanded by PowerShell | `$b = "$env:CLAUDE_PLUGIN_ROOT/..."`, substituted text only when the variable is unset; `& $s $b` | `layout_mutation_hook_windows_root_text ok`; `rootvar_unset_bad`, `dollar_root_bad` as expected | VERIFIED |
| IN-01 noconn halves ungated | Hook unchanged; two oncegate cases added | `tier2_noconn_needs_no_ip ok`, `tier2_noconn_needs_zero_time ok`, `hookmut_noconn_ip ok`, `hookmut_noconn_time ok` | VERIFIED |
| IN-02 git-derived path for mingw64\bin | `if ($q -and ((Split-Path -Leaf $q) -match '^(mingw\|clang\|ucrt)')) { $q = Split-Path -Parent $q }; if ($q) {` | `layout_mutation_hook_windows_git_cmd_only ok`; `git_mingw_on_path_bad` as expected | VERIFIED |
| IN-03 32-bit host | `$env:ProgramW6432` first in the list | `layout_mutation_hook_windows_no_w6432 ok`; `w6432_bad`, `wow64_w6432_bad` as expected | VERIFIED |
| IN-04 trailing space | `(echo ...)1>&2` ×3; `" 1>&2"` forbidden | `layout_mutation_hook_windows_trailing_space ok`; launcher verdict checks `_trail`; round 3 shows no trailing space | VERIFIED |
| IN-05 stale comments | bbj-check.sh header :38-40, doc comment :245-248, in-function :299-301 | comments only (none claimed); non-comment diff empty | VERIFIED |
| IN-06 control comment | test_discovery.sh comment reworded | comment only (none claimed) | VERIFIED |
| IN-07 accepted limits | Disposition recorded in 13-REVIEW.md. (d) has since been done by 80ad46f: `.claude/CLAUDE.md` lists `hookmut_` and the `tier2_*` free-form names. `.planning/codebase/CONVENTIONS.md` still lacks them; MAINT-09 (Phase 14) covers that file | none claimed | VERIFIED |

### DOCS-06 trace (Windows claims added to `docs/install-codex.md` in Phase 13)

Scope: the lines added in `git diff 87214d9..HEAD`. The older Windows lines (the header dates 2026-10-13/14, "Hook failed" before `commandWindows`, the Git Bash compiler run, `bbj-local` on Windows) come from the Phase 9/10 run records. This phase did not touch them.

| Claim | Source in 13-WINDOWS-RUN.md | Status |
|-------|-----------------------------|--------|
| Ordered lookup list, items 1-5 | Install-page sentence 1 (ordered places); code pinned by `layout_hook_command_windows` | traced |
| Found under `%ProgramW6432%` | round 3 `w6432_bad` | traced |
| Found under `%ProgramFiles%` | round 1 `default_bad` (earlier string; with the shipped string ProgramW6432 precedes it) | traced (round 1 only) |
| "(also from a 32-bit PowerShell)" attached to `%ProgramFiles%` | `wow64_w6432_bad` offers Git only through ProgramW6432 | **NOT traced (gap)** |
| `%ProgramFiles(x86)%`, `%LOCALAPPDATA%\Programs`, `%USERPROFILE%` form | `pf86_bad`, `localappdata_bad`, `lad_unset_profile_bad` | traced |
| `bin`, `usr\bin`, `cmd` on PATH; `mingw64\bin` git; past a non-Git `sh` | `sh_on_path_bad`, `usrbin_on_path_bad`, `git_on_path_bad` (GITCMD_P = `cmd`), `git_mingw_on_path_bad`, `othersh_then_git_bad` | traced |
| Blocked with the not-found message, places looked, fix | Install-page sentence 2; c2-bad round 3 | traced |
| Only a change that names a BBj file, in any case; text does not count, `img.src` | Install-page sentence 3; `none_update_src` (`x.SRC`), `none_web_src`, c2-websrc | traced. Delete File / Move to: see W2 |
| About 8 KB or longer gets the message | `none_long_notes` (over 8192 bytes), rounds 1 and 3 | traced |
| Codex starts the hook with the settings PATH | Install-page sentence 5; O1 | traced |
| Ends in `exit $LASTEXITCODE` so exit 2 reaches Codex | c1-bad "Blocked by hook" | traced |
| Plugin folder from `CLAUDE_PLUGIN_ROOT` "that Codex sets for the hook"; `$`/backtick reaches `sh` | `dollar_root_bad` (outside Codex). Under Codex the record says the run "cannot tell whether the script path came from CLAUDE_PLUGIN_ROOT" | partly traced; see W2 |
| Not-run list | Install-page sentence 7 (verbatim) plus the round 3 note on `dollar_root_bad` | traced |
| Observed paragraph, 2026-10-16 | Round 3 launcher and Codex "Sentence for the docs (round 3)", BBJ_HOME `C:\bbx` | traced |
| Timeout paragraph | The 13-06 exception: it describes the code, says "not observed in a run", and is backed by the FIX-02 gates | traced (allowed exception) |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/hooks/hooks.json` | review-fix `commandWindows`; `command`, matcher, timeout unchanged | VERIFIED | sha256 equals the pin and the round 3 reading; `layout_hook_command ok`, `layout_hook_timeout ok` |
| `plugins/bbj/scripts/bbj-check.sh` | tier-2 cache, noconn, comments in line with FIX-02 | VERIFIED | code unchanged since 4417405; comments fixed (IN-05) |
| `tests/test_layout.py` | 10-statement pin, forbidden/parts guards, 14 Windows mutation cases | VERIFIED | all ok |
| `tests/test_tier2_fake.sh`, `tests/test_hook_mutation.sh` | once/noconn gates, 7 `hookmut_` gates | VERIFIED | all ok |
| `tests/test_discovery.sh` | bait and control | VERIFIED | ok |
| `windows-run/launcher.sh`, `runbook.md` | round 3 cases, PIN_SHA, H5 runbook fix | VERIFIED | selftest ok, shellcheck clean, 27 cases run by the owner |
| `13-WINDOWS-RUN.md` | round 3 readings, install-page sentences, verdict | VERIFIED | `- FIX-01: met`, re-judged for sha256 `812f6bbf...` |
| `docs/install-codex.md` | the shipped lookup, the message, and the claims, each backed by the record | PARTIAL | one claim without a run behind it (gap) |
| `README.md` | not-run sentence from the record | VERIFIED (warning W1) | unchanged since 4417405; it lacks the round 3 not-run item |

### Key Link Verification

| From | To | Via | Status |
|------|----|-----|--------|
| `hooks.json` commandWindows | `test_layout.py` HOOK_COMMAND_WINDOWS | exact equality | WIRED (gate ok) |
| `hooks.json` commandWindows | `launcher.sh` PIN_SHA | extract_cmd + sha256 | WIRED (selftest ok; owner block equals pin) |
| `hooks.json` commandWindows | `test_codex_patch.sh` | python3 -I reader | WIRED (`plugin_route_command_windows ok`) |
| `test_hook_mutation.sh` mutants | `bbj-check.sh` lines | sed + `cmp -s` no-op guard | WIRED (all 7 ok) |
| `no_tier1_route` cache line | `main` `NR_T2=` reset | global | WIRED (:254, :681) |
| run record "For the install page" | `docs/install-codex.md` | copied sentences | PARTIAL (gap: 32-bit attribution) |
| `test_install_pages.sh` need list | Codex page | grep -qF | WIRED (`codex_has__LOCALAPPDATA__Programs_Git ok`, `codex_has_Git_for_Windows_sh_exe_not_found ok`) |

### Data-Flow Trace (Level 4)

Not applicable: the phase renders no dynamic data. The equivalent flow, NR_T2 to the notice text, is exercised by the oncegate notice assertions.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Shipped string equals pin | python3 -I json + hashlib over hooks.json | 1817 chars, `812f6bbf...3c51`, no `\"` | PASS |
| PIN_SHA equals shipped | `grep PIN_SHA launcher.sh`; `sh launcher.sh selftest` | equal; `selftest ok` | PASS |
| Round 3 string still ships | `git diff --stat 1199d82 HEAD -- . ':!.planning'` | only docs/install-codex.md | PASS |
| Restoring per-file connect fails SC2 | scratch copy `/# t2-cache$/d`, copied test_tier2_fake.sh | both once-gates FAIL, 12 calls, rc=1 | PASS |
| WR-03 filter semantics | python re (IGNORECASE) over 9 JSON payloads | 0 differ from the page's rule | PASS |
| bbj-check.sh / test_discovery.sh code unchanged | non-comment diff 4417405..HEAD | empty | PASS |
| Full suite | `sh tests/run.sh` | ok=797 fail=0 skip=0, exit 0 | PASS |
| CI entry point | `CI=true sh tests/ci.sh` | ok=6 fail=0 skip=0 run_sh_exit=0, exit 0 | PASS |

### Probe Execution

No `scripts/*/tests/probe-*.sh` exist, and no plan declares a probe. Step 7c: not applicable.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| FIX-01 | 13-02, 13-04, 13-05, 13-06 | Git outside `C:\Program Files\Git` gets a working hook or a visible message, never a silent no-op | SATISFIED | Truth 1; round 3 verdict `met` on the shipped sha256 |
| FIX-02 | 13-01, 13-03, 13-06 | many-file `apply_patch` with no route stays within 30 s | SATISFIED | Truth 2 |
| FIX-03 | 13-03, 13-06 | backslash gate fails when the conversion is removed | SATISFIED | Truth 3 |
| DOCS-06 (Phase 11, rule applied by 13-06) | 13-06 | per-platform claims backed by a run record | BLOCKED (one claim) | Truth 7 |

No orphaned requirements: REQUIREMENTS.md maps only FIX-01..03 to Phase 13.

### Decision Coverage

All trackable CONTEXT.md decisions are honored by shipped artifacts: 21/21 (`check.decision-coverage-verify`, exit 0).

### Test Quality Audit

| Test File | Linked Req | Active | Skipped | Circular | Assertion Level | Verdict |
|-----------|-----------|--------|---------|----------|-----------------|---------|
| `tests/test_tier2_fake.sh` (once/noconn/transfer/every) | FIX-02 | 6 | 0 | no | Behavioral (call count, connect timeout, notice text, exit, stdout) | OK |
| `tests/test_discovery.sh` (bait, control) | FIX-03 | 2 | 0 | no | Behavioral (compiler call count and target) | OK |
| `tests/test_hook_mutation.sh` | FIX-02, FIX-03 | 7 | 0 | no | Behavioral (nested FAIL + rc 1; controls pass; no-op mutation FAILs) | OK |
| `tests/test_layout.py` (hook_windows_*) | FIX-01 | 4 + 14 mutation | 0 | no | Value (exact pin; forbidden/parts lists). Pins text; behaviour is the owner run | OK |
| `tests/test_codex_patch.sh` (plugin_route_command_windows) | FIX-01 | 1 | 0 | no | Value | OK |

Disabled tests: 0. Circular patterns: 0. Insufficient assertions: 0.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `plugins/bbj/scripts/bbj-check.sh` | 334 | `\uXXXX` | Info | escape notation in a comment, not a debt marker |
| `.planning/phases/13-windows-hook-fixes/13-REVIEW-FIX.md` | "Not done" | stale | Info | says IN-07(d) was not done; 80ad46f did it afterwards |

No TBD/FIXME/TODO/HACK/placeholder markers in any file changed by the phase.

### Advisory (New Scope, Unevidenced)

None.

### Warnings (owner decision)

- **W1, README not-run sentence (UNCERTAIN).** README.md:66-69 is a copy of the round 1 "Not run" list. Round 3 added "under Codex, a plugin folder whose path holds a `$` or a backtick". The README makes no claim about such paths, so nothing it says is false. Plan 13-06 truth 2 does tie the README not-run sentence to the record's sentence, though. Fix it with the gap, or accept it as is.
- **W2, code descriptions on the Codex page beyond the one allowed exception (UNCERTAIN).** The 13-06 rule exempts only the timeout paragraph. Two newer sentences describe the pinned code or the Codex source, not a run:
  - the `*** Delete File:` and `*** Move to:` headers of the filter rule. No Windows case used them. The regex is pinned and, here, spot-checked against JSON payloads.
  - "the `CLAUDE_PLUGIN_ROOT` variable that Codex sets for the hook". This comes from reading the Codex source (13-REVIEW-FIX WR-04). The record says the Codex run "cannot tell" which path was used. The page's Not-run list does disclose that the `$`/backtick case was not run under Codex.

  Either accept these as descriptions of the code, as for the timeout paragraph, or mark them the same way ("follows from the hook's code; not observed in a run").

### Residual Risks (Info, not gaps)

1. The `noconn` write-out shape of Git for Windows' curl is unmeasured (RESEARCH A7), as before. Its failure mode is safe: silent and not cached.
2. Codex setting `CLAUDE_PLUGIN_ROOT` on Windows is read from the source, not observed. If it is unset, `rootvar_unset_bad` proves the fallback works, but the fallback keeps the old `$`/backtick exposure (recorded in 13-REVIEW IN-07).
3. pwsh and a real per-user install remain not run, as the record, the page and the README say.

The previous report's risk 3 (a non-Git `sh` on PATH) is closed by WR-01 and round 3 `othersh_none_bbj`.

### Human Verification Required

None beyond the owner decisions on W1 and W2. The Windows proof for the shipped string is already recorded (round 3, 2026-10-16).

### Gaps Summary

The phase goal holds in the code and on real Windows:

- **FIX-01:** the review-fix `commandWindows` that ships is the one round 3 ran (sha256 `812f6bbf...`, equal to `PIN_SHA`). It never goes silent for a BBj write: a non-Git `sh`, an unset `LOCALAPPDATA` and the drive-root probe all end in the loud message.
- **FIX-02 and FIX-03:** both gates fail under the mutation they guard against.
- **Review fixes:** all 11 WR/IN fixes are in the code, each with the gate claimed for it.
- **Suites:** both are green.

One gap remains, in the docs (DOCS-06). In 101c171 the Codex page says a test run found Git under `%ProgramFiles%` "also from a 32-bit PowerShell". The 32-bit case (`wow64_w6432_bad`) found it under `%ProgramW6432%`, with ProgramFiles pointing at an empty folder. It is a one-line wording fix in `docs/install-codex.md`. No code change and no new Windows run is needed. Phase 14 carries this page's wording forward rather than re-auditing it, so the gap is not deferred.

---

_Verified: 2026-10-16T04:42:51Z_
_Verifier: Claude (gsd-verifier)_
