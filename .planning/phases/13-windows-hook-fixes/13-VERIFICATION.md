---
phase: 13-windows-hook-fixes
verified: 2026-10-16T09:30:00Z
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
  - .planning/phases/13-windows-hook-fixes/13-REVIEW-DISPOSITION.md
  - .planning/phases/13-windows-hook-fixes/13-REVIEW-FIX.md
  - .planning/phases/13-windows-hook-fixes/13-REVIEW.md
  - .planning/phases/13-windows-hook-fixes/13-SECURITY.md
  - .planning/phases/13-windows-hook-fixes/13-VALIDATION.md
  - .planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md
  - .planning/phases/13-windows-hook-fixes/windows-run/launcher.sh
  - .planning/phases/13-windows-hook-fixes/windows-run/runbook.md
  - README.md
  - docs/install.md
  - plugins/bbj/hooks/hooks.json
  - plugins/bbj/scripts/bbj-check.sh
  - tests/fake-bin/curl
  - tests/lib.sh
  - tests/test_codex_patch.sh
  - tests/test_discovery.sh
  - tests/test_hook_mutation.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_noroute_notice.sh
  - tests/test_tier2_fake.sh
covered_digest: "v3:sha256:0f92d4a3fba683208c4cca5bebd106e64f34e559dd8d548c4b45a01d335ef39a"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 7/7
  previous_verified: 2026-10-16T04:51:40Z
  previous_commit: 693e3ad
  reason: "the previous report went stale because later phases (11, 12, 14) changed files it covered, not because phase 13 work changed"
  gaps_closed: []
  gaps_remaining: []
  regressions: []
---

# Phase 13: Windows hook fixes Verification Report

**Phase Goal:** The hook on Windows never fails silently because of where Git for Windows is installed, never runs past the 30 s hook timeout on a large patch with no check route, and the backslash path gate guards what it claims to.
**Verified:** 2026-10-16T09:30:00Z
**Status:** passed
**Re-verification:** Yes. The previous report (693e3ad, `passed`, 7/7) covered files that later phases changed. This run re-checks every truth against the tree as it is now.

## What changed since the previous report

`git diff 693e3ad HEAD` over the covered files shows only changes made by other phases:

- **Phase 14 (DOCS-05):** `docs/install-codex.md` and `docs/install-claude-code.md` are folded into `docs/install.md`. The Windows section of the old Codex page (ordered lookup, observed-run sentences, not-found message, filter rule, `PATH` and `exit $LASTEXITCODE` notes, Not-run list, tier-2 timeout paragraph) is now at `docs/install.md:331-430` and `:281-287`. I compared it with the old text. The claims moved and none was added or widened. A deleted page is not a gap.
- **Phase 14 (MAINT-09):** gate names carry file prefixes. `windows_codex_backslash_dotdot_skipped` is now `discovery_windows_codex_backslash_dotdot_skipped`, and `windows_codex_backslash_dot_control` is now `discovery_windows_codex_backslash_dot_control`. `tests/test_hook_mutation.sh` names the new gates, and the mutation cases still run. The `tier2_*` gate renames are cosmetic.
- **Phase 12 review fixes:** `tests/lib.sh` unsets the `FAKE_CURL_*` seams. A set-but-empty write-out gate `tier2_noconn_empty_writeout` was added. Both only tighten the gates.
- **Unchanged since the previous run:** `plugins/bbj/scripts/bbj-check.sh` and `plugins/bbj/hooks/hooks.json` have no diff against 11594e4. The windows-run harness has no diff either. `13-WINDOWS-RUN.md` differs by one line, the install-page sentence 1 edit from 2affe32, which the previous report already judged.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (FIX-01): a Codex user on Windows whose Git is not at `C:\Program Files\Git` gets a hook that checks the file, or a visible message naming the missing `sh.exe`, never a silent no-op. This is owner-confirmed on a real Windows machine. `layout_hook_command_windows` pins the new `commandWindows`, and `claude plugin validate --strict` passes | VERIFIED | A fresh `python3 -I` reading of `hooks.json` gives a `commandWindows` of 1817 characters with sha256 `812f6bbf...3c51`. That equals `launcher.sh:42` `PIN_SHA`, and `sh launcher.sh selftest` prints `selftest ok`. Run here: `layout_hook_command_windows`, `layout_hook_windows_safe`, `layout_hook_windows_parts` and `plugin_route_command_windows` ok; `ci_validate_root`, `ci_validate_plugins_bbj` and `ci_validate_plugins_bbj_local` ok. The owner's Windows run is recorded in `13-WINDOWS-RUN.md`, line 483: `- FIX-01: met`. The shipped string and the record have not changed since the previous report |
| 2 | SC2 (FIX-02): a gate on fakes runs one hook call over a many-file Codex `apply_patch` with no route on the Windows path (5 s connect timeout). Tier 2 is tried once, the other files skip it, and the run ends well under 30 s. When `bbj-ls` answers, every file is checked. Restoring the per-file connect makes the gate fail | VERIFIED | Run here: `tier2_once_windows_refused`, `tier2_once_windows_connect_timeout`, `tier2_transfer_timeout_not_cached`, `tier2_noconn_needs_no_ip`, `tier2_noconn_needs_zero_time`, `tier2_noconn_empty_writeout`, `tier2_every_file_when_answering` and `hookmut_t2_cache` ok. **Own mutation, made in a scratch copy:** I deleted the one line ending `# t2-cache` from the copy of `bbj-check.sh`. `tier2_once_windows_refused` and `tier2_once_windows_connect_timeout` then print FAIL with `12 curl call(s) want 1, connect timeout '5'`, while `tier2_every_file_when_answering` stays ok. The real hook was not touched |
| 3 | SC3 (FIX-03): a mutation that removes the backslash conversion makes `discovery_windows_codex_backslash_dotdot_skipped` fail, the unmutated tree passes it, and the mutation case is kept in the suite | VERIFIED | **Own mutation, in a scratch copy:** I replaced the `tr '\\' '/'` of `wpath_norm` (`bbj-check.sh:596`) with `cat`. In the copy, `discovery_windows_codex_backslash_dotdot_skipped` prints `FAIL calls 1, exit 0` (the bait is compiled), and `discovery_windows_codex_backslash_relative` and `discovery_windows_codex_backslash_dot_control` also FAIL. The unmutated tree prints ok for all three. The mutation cases stay in the suite: `hookmut_backslash_conversion`, `hookmut_dotdot_check` and `hookmut_discovery_control` are ok, and `test_hook_mutation.sh` names the renamed gates |
| 4 | SC4: the exit contract and the safety gates hold: exit 0/2 with empty stdout, `-N` on every compiler call, loopback-only `curl` with `--noproxy '*'` and `--proto =http`, never the hosted check; `sh tests/ci.sh` passes | VERIFIED | Run here: `sh tests/run.sh` gives `SUMMARY: ok=859 fail=0 skip=1`, exit 0. The one skip is the opt-in `live_blackhole_connect_timeout`. `CI=true sh tests/ci.sh` gives `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, exit 0, with strict validation of the root and both plugins and shellcheck ok. `run_prefix_block ok`: 21 files, 33 prefixes |
| 5 | Every WR/IN fix in `13-REVIEW-FIX.md` is in the code, with a mutation gate wherever one is claimed | VERIFIED | The code is unchanged since 11594e4, and the 13 `layout_mutation_hook_windows_*` cases and the `hookmut_noconn_*` cases are ok in this run. `13-REVIEW-DISPOSITION.md` records 11 findings, open 0 |
| 6 | The launcher `PIN_SHA` equals the shipped `commandWindows` sha256 | VERIFIED | Both are `812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51`, recomputed here. `selftest ok` |
| 7 | DOCS-06 (plan 13-06 truth 2): every Windows claim on the install page and in the README traces to a result block or "For the install page" sentence of `13-WINDOWS-RUN.md`, or is marked as a code or source description | VERIFIED | The claims now sit in `docs/install.md:331-430`. The text is the old Codex-page Windows section moved without widening. Lines 349-352: "found Git for Windows under `%ProgramW6432%` (also from a 32-bit PowerShell) ... `%LOCALAPPDATA%\Programs` ..." (backed by `w6432_bad`, `wow64_w6432_bad`, `pf86_bad`, `localappdata_bad`, `lad_unset_profile_bad`, and the PATH cases). Lines 367-375 say the run used `Add File` and `Update File` lines and mark the `CLAUDE_PLUGIN_ROOT` point as not observed on Windows. Lines 377-381 hold the Not-run list. `README.md:54-58` ends its Windows not-run list with the `$` or backtick plugin folder. The timeout paragraph at `install.md:281-287` states what the hook code does, says "was not observed in a run", and the FIX-02 gates back it. No sentence names the 8.3 short-name path (`grep PROGRA~` over README, docs, plugins and tests finds none outside the planner-allow comments in plan files) |

**Score:** 7/7 truths verified (0 present, behavior-unverified)

### Deferred Items

None.

### Advisory (New Scope, Unevidenced)

None.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/hooks/hooks.json` | the review-fix `commandWindows`; `command`, matcher and timeout unchanged | VERIFIED | sha256 equals the pin; no diff against 11594e4 |
| `plugins/bbj/scripts/bbj-check.sh` | the tier-2 cache (`# t2-cache`), the noconn classification, `wpath_norm` | VERIFIED | no diff against 11594e4; both mutations above bite |
| `tests/test_layout.py` | the 10-statement pin, the safe and parts guards, the Windows mutation cases | VERIFIED | all `layout_*` Windows gates ok |
| `tests/test_tier2_fake.sh`, `tests/test_hook_mutation.sh` | the once and noconn gates, the `hookmut_` gates | VERIFIED | all ok; renamed gate names match |
| `tests/test_discovery.sh` | the bait and the control gates | VERIFIED | ok under the `discovery_` names |
| `tests/fake-bin/curl`, `tests/lib.sh` | the write-out seam; the seams cleared per test | VERIFIED | used by the passing `tier2_*` gates; Phase 12 only tightened |
| `windows-run/launcher.sh`, `runbook.md` | the round 3 cases, PIN_SHA | VERIFIED | `selftest ok` |
| `13-WINDOWS-RUN.md` | the readings, the install-page sentences, the verdict | VERIFIED | `- FIX-01: met` at line 483 |
| `docs/install.md`, `README.md` | the shipped lookup, the message, the claims, each backed by the record | VERIFIED | see truth 7; `codex_*`, `claude_*`, `readme_*`, `link_*` gates ok |

### Key Link Verification

| From | To | Via | Status |
|------|----|-----|--------|
| `hooks.json` commandWindows | `test_layout.py` HOOK_COMMAND_WINDOWS | exact equality | WIRED (gate ok) |
| `hooks.json` commandWindows | `launcher.sh` PIN_SHA | extract_cmd and sha256 | WIRED (equal; selftest ok) |
| `hooks.json` commandWindows | `test_codex_patch.sh` | python3 -I reader | WIRED (`plugin_route_command_windows` ok) |
| `test_hook_mutation.sh` mutants | `bbj-check.sh` lines and the renamed `discovery_` gates | sed and `cmp -s` no-op guard | WIRED (all 7 ok; my own two mutations give the same FAILs) |
| `no_tier1_route` cache line | the `NR_T2=` reset in `main` | global | WIRED |
| result blocks of `13-WINDOWS-RUN.md` | `docs/install.md`, `README.md` | copied sentences | WIRED |
| `test_install_pages.sh` need list | `docs/install.md` | grep -qF | WIRED (gates ok) |

### Data-Flow Trace (Level 4)

Not applicable: the phase renders no dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite | `sh tests/run.sh` | ok=859 fail=0 skip=1, exit 0 | PASS |
| CI entry point | `CI=true sh tests/ci.sh` | ok=6 fail=0 skip=0 run_sh_exit=0 | PASS |
| Shipped string equals the pin | python3 -I json and hashlib over `hooks.json`; `grep PIN_SHA= launcher.sh` | 1817 chars; both `812f6bbf...3c51` | PASS |
| Launcher self-test | `sh launcher.sh selftest` | `selftest ok` | PASS |
| t2-cache mutation (scratch copy) | delete the `# t2-cache` line; run `test_tier2_fake.sh` | both once-gates FAIL with 12 curl calls | PASS |
| Backslash-conversion mutation (scratch copy) | replace `tr '\\' '/'` with `cat`; run `test_discovery.sh` | the dotdot_skipped, relative and dot_control gates FAIL | PASS |
| Code unchanged since the last code verification | `git diff 11594e4 HEAD -- bbj-check.sh hooks.json windows-run` | no diff | PASS |
| No debt markers | `grep -E 'TBD\|FIXME\|XXX'` over bbj-check.sh, hooks.json, install.md, README.md, test_hook_mutation.sh | one hit: the `\uXXXX` escape notation in a comment at `bbj-check.sh:334`, not a marker | PASS |

### Probe Execution

No `scripts/*/tests/probe-*.sh` exist, and no plan declares a probe. Step 7c: not applicable.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| FIX-01 | 13-02, 13-04, 13-05, 13-06 | Git outside `C:\Program Files\Git` gets a working hook or a visible message, never a silent no-op | SATISFIED | Truth 1; the owner's round 3 verdict is `met` on the shipped sha256 |
| FIX-02 | 13-01, 13-03, 13-06 | a many-file `apply_patch` with no route stays within 30 s | SATISFIED | Truth 2, with my own mutation |
| FIX-03 | 13-03, 13-06 | the backslash gate fails when the conversion is removed | SATISFIED | Truth 3, with my own mutation |
| DOCS-06 (Phase 11, the rule applied by 13-06) | 13-06 | per-platform claims backed by a run record | SATISFIED | Truth 7 |

All three IDs appear in the PLAN frontmatter `requirements` and in the SUMMARY `requirements-completed` fields. REQUIREMENTS.md marks FIX-01, FIX-02 and FIX-03 Complete and maps only those three to Phase 13. There are no orphaned requirements.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `plugins/bbj/scripts/bbj-check.sh` | 334 | `\uXXXX` | Info | escape notation in a comment, not a debt marker |

### Human Verification Required

None. The Windows proof for the shipped string is recorded in `13-WINDOWS-RUN.md` (round 3, 2026-10-16). Items the record lists as not run (Git on another drive or custom folder, a real per-user install, `pwsh`, system-wide ConstrainedLanguage, a `$` or backtick plugin folder under Codex) are stated as not run on `docs/install.md` and in the README, so no claim rests on them.

### Gaps Summary

There are no gaps. Phase 14 moved the Windows install claims into `docs/install.md` without widening them, and renamed the gates. Both changes leave the three FIX truths intact, and the two mutations I made reproduce the FAILs. The hook code and `hooks.json` are byte-identical to the state the earlier report verified. The phase goal is achieved.

---

_Verified: 2026-10-16T09:30:00Z_
_Verifier: Claude (gsd-verifier)_
