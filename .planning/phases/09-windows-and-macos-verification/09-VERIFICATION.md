---
phase: 09-windows-and-macos-verification
verified: 2026-10-13T23:30:00Z
status: passed
score: 5/5 must-haves verified
covered_files:
  - ".planning/phases/09-windows-and-macos-verification/09-01-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-01-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-02-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-02-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-03-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-03-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-04-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-04-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-05-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-05-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-06-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-06-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-07-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-07-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-08-PLAN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-08-SUMMARY.md"
  - ".planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md"
  - ".planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md"
  - ".planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh"
  - ".planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh"
  - "plugins/bbj/hooks/hooks.json"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "tests/fake-bin/cygpath"
  - "tests/test_codex_patch.sh"
  - "tests/test_discovery.sh"
  - "tests/test_layout.py"
  - "tests/test_tier2_fake.sh"
covered_digest: "v3:sha256:59692b7d2cff2d12003b548db71172ef0dc3cc5cd0c1bc60d9f497c42e66063e"
behavior_unverified: 0
overrides_applied: 0
---

# Phase 9: Windows and macOS verification: Verification Report

**Phase Goal:** The Claude Code plugin and the Codex plugin route work on real Windows and macOS machines on the compile-only `bbjcpl` route, and `bbj-local` connects on Windows where BBjServices runs. Every defect a run finds is fixed with a CI gate on fakes or recorded as a known gap, and every run is on record.
**Verified:** 2026-10-13
**Status:** passed (3 non-blocking warnings, listed below)
**Re-verification:** No, initial verification

## Goal Achievement

The evidence for the real-machine claims is the owner-recorded readings in `09-WINDOWS-RUN.md` and `09-MACOS-RUN.md`. A real Windows or macOS machine cannot be reached from CI or from this Linux verifier. I did not accept the SUMMARY claims. I read the raw result blocks and reply keys in both records, ran the record checker, re-derived the fix code and gates from the tree, and re-ran the whole suite.

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Windows, Claude Code: `bbjcpl` feedback after Write and Edit of a bad `.bbj`, silence for a clean one; `cygpath` branch shown on real paths (compiler path, `;`-joined `-P`, drive-letter files, project path with a space) (PLAT-01, PLAT-02) | VERIFIED | `09-WINDOWS-RUN.md` `## Claude Code: bbjcpl route`, rounds 1 (2026-10-13) and 2 (2026-10-14): `cc-edit-bad` and the Write rerun give `bbjcpl reported 1 error(s)` (a real `PostToolUse:Write/Edit hook returned blocking error`), `cc-write-clean` is silent, and the `bbj test` space path gives feedback. The smoke `claude` block shows `compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\proj\sub;<work>\proj' '<work>\proj\sub\bad.bbj'`, i.e. a drive-letter home, `;` list, and a kept space; `dash_n: yes`; exit 2 for bad, 0 for clean. Both root forms (`/` and `\`) exit 2. The exact P1 prompt went through Bash twice, so no hook ran. The record labels that as client behaviour and uses the forced Write rerun as the reading. That is consistent with the `Write|Edit` matcher, not a defect. Fakes: 9+ `windows_*` gates in `tests/test_discovery.sh`, all pass in my run. |
| 2 | Windows, Codex plugin route: runs the hook with `commandWindows` or another fix; `bbjcpl` feedback after `apply_patch` for bad, silence for clean; the three spike 005 unknowns settled (PLAT-03) | VERIFIED | Round 1: `Hook failed / hook exited with code 1` on all three cases. The cause was reproduced outside Codex (`ps-sh: missing`, `ps-wrapped-exit 1`, `ps-wrapped-keep-exit 2`). Round 2 at d598854, after the fix: `cx-retrust-asked: yes`, `cx-hook-command: C:\PROGRA~1\Git\bin\sh.exe "<cache>/scripts/bbj-check.sh"; exit $LASTEXITCODE`, `cx-add-bad` and `cx-update-bad` are `Blocked by hook` with `bbjcpl reported 1 error(s)`, and `cx-add-clean` is silent. The unknowns are answered in `## Codex on Windows: spike 005 unknowns`: sh no, `commandWindows` honoured, plugin root accepted by sh yes. `plugins/bbj/hooks/hooks.json` carries the exact `commandWindows` string (grepped). Gates `layout_hook_command_windows`, `layout_mutation_hook_command_windows` and `plugin_route_command_windows` pass. |
| 3 | Windows with BBjServices running: `bbj-local` connects in Claude Code once enabled and in Codex after `codex plugin add bbj-local@basis-bbj`; off unless the user opts in (PLAT-04) | VERIFIED | `## bbj-local: Claude Code`: before is absent, after is `plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - Connected`, and the install printed "disabled by default". `bbj_check_syntax` returned one SyntaxError diagnostic (BBj 26.03). `## bbj-local: Codex`: absent before, `enabled` after. The round 2 `claude mcp list` also shows it Connected. The tier 2 smoke (`curl` from Git Bash to 127.0.0.1:5009) gives feedback and silence. The BBjServices-not-running attempt is recorded openly, with an amendment. |
| 4 | macOS with BBj installed: Claude Code hook and Codex plugin-route hook each give tier-1 `bbjcpl` feedback for bad and silence for clean (PLAT-05) | VERIFIED | `09-MACOS-RUN.md`, 2026-10-14 at d598854, macOS 27.0.1, `/bin/sh` bash 3.2.57. Claude Code 2.1.296: Write and Edit give feedback, the clean file is silent, and the first line is `bbjcpl reported`, not `bbj-local reported`, so the hook did not fall back to tier 2. Codex 0.162.1: `cx-trusted: yes`, add and update give feedback, clean is silent, and the first line is `bbjcpl reported`. The first Codex runs fell back to tier 2 because the app-server daemon lacked `BBJ_HOME`. They were honestly not counted and are recorded as side-1 and side-2. The BBj home `<home>/bbx` is outside the default list, which the record states plainly. |
| 5 | Every run recorded (OS, client and version, BBj version, route, outcome); every defect fixed with a CI gate on fakes or recorded as a known gap; Linux suite stays green (PLAT-06) | VERIFIED | Both records have a filled Run environment table and dated readings. `check-records.sh windows final` and `macos final` exit 0 (re-run by me, all 12 and 13 checks `ok`, `fixed_commits_exist ok`), and `selftest` is ok. Windows found 3 defects, W-1 `commandWindows`, W-2 tier-2 connect timeout and W-3 path forms, each fixed with red-first test commits (a93928d, fb4bc81, 2745ab8) before the fix commits (2197273, 950d8bf, 16c863b); all six commits exist. The re-run on the real machine (round 2, d598854) met each. macOS found 0 defects and 0 gaps, which is plausible given the tier-1 readings. `sh tests/run.sh` re-run on HEAD 3226217: `SUMMARY: ok=921 fail=0 skip=0`, rc=0. |

**Score:** 5/5 truths verified (0 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/hooks/hooks.json` | `command` unchanged plus `commandWindows` | VERIFIED | The string is exactly the layout-gate constant. `command` is byte-identical to before. |
| `plugins/bbj/scripts/bbj-check.sh` | `wpath_norm` (W-3) and `_ct` 5 s under `WIN=1` (W-2) | VERIFIED | `wpath_norm` is applied to the cwd (line 579) and to each header path (line 615). `curl` keeps `--noproxy '*'`, `--proto =http`, `-m 12`, and no redirect flag. |
| `tests/fake-bin/cygpath` | `FAKE_CYGDRIVE_ROOT` seam | VERIFIED | The seam is present and off by default. |
| `tests/test_discovery.sh`, `test_codex_patch.sh`, `test_layout.py`, `test_tier2_fake.sh` | Gates for PLAT-02, 03 and W-1 to W-3 | VERIFIED | All named gates appear as `ok` in the suite output. |
| `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md` | Final records | VERIFIED | Substantive, with pasted result blocks, not skeletons. |
| `platform-run/smoke.sh`, `check-records.sh`, runbooks | Owner tooling | VERIFIED | Wired: the records quote smoke output with `script_identical_to_checkout: yes`. The checker passes its selftest. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `commandWindows` | Codex on Windows PowerShell launcher | Real run | WIRED | Round 2 `/hooks` shows the string expanded, and feedback arrives with exit 2 preserved. |
| `wpath_norm` | `codex_patch` containment, `..` and drive checks | Lines 579 and 615 | WIRED | Gates `windows_codex_*` exercise it on fakes. The real machine gave a compiler call for the verbatim form. |
| `_ct=5` | tier-2 `curl` | Line 281 | WIRED | `tier2_connect_timeout_*` pin the argument. The real machine shows the notice printed in round 2. |
| Records | `check-records.sh final` | Checker | WIRED | Both exit 0. |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite | `sh tests/run.sh` | `SUMMARY: ok=921 fail=0 skip=0` | PASS |
| Records final | `sh platform-run/check-records.sh windows final` / `macos final` / `selftest` | rc=0 / rc=0 / ok | PASS |
| Layout gates | `python3 -I tests/test_layout.py` | `layout_hook_command_windows ok`, `layout_mutation_hook_command_windows ok` | PASS |
| Mutation: drop the backslash conversion | Run `test_discovery.sh` against a copy without `tr '\\' '/'` | `windows_codex_backslash_relative` FAIL, as designed | PASS (see WR-03) |

### Probe Execution

SKIPPED. The phase declares no `probe-*.sh` files. The owner-run `smoke.sh` is the real-machine tool and is covered under Truths 1 to 5.

### Phase Boundary and Safety Invariants

- `docs/`, `README.md`, `CHANGELOG.md`, `codex/`, `tests/test_release_text.py`, `tests/test_install_pages.sh` and `tests/test_install_codex.sh` have an empty `git diff 2524dff HEAD`, so the boundary rule holds.
- Outside `.planning`, only these files changed since 2524dff: `hooks.json`, `bbj-check.sh`, `tests/fake-bin/cygpath` and four test files. `git diff d598854 HEAD -- plugins tests codex` is empty, so the code the owner ran on both machines equals the shipped code.
- The static and never-execute gates (`test_never_execute.sh`, `test_static_guards.sh`, `test_exit_contract.sh`) pass inside the suite. Every compiler call still carries `-N`.

### Requirements Coverage

| Requirement | Source Plans | Status | Evidence |
|-------------|--------------|--------|----------|
| PLAT-01 | 09-02, 03, 04, 05, 06 | SATISFIED | Truth 1, owner readings on real Windows. |
| PLAT-02 | 09-01, 02, 03, 04, 05, 06 | SATISFIED | Truth 1, smoke blocks plus the `windows_*` gates. |
| PLAT-03 | 09-02, 03, 04, 05, 06 | SATISFIED | Truth 2, fix W-1, re-run met. |
| PLAT-04 | 09-02, 03, 04, 05, 06 | SATISFIED | Truth 3, with the W-2 fix and re-run. |
| PLAT-05 | 09-02, 03, 06, 07, 08 | SATISFIED | Truth 4, owner readings on real macOS. |
| PLAT-06 | 09-01, 03, 04, 05, 06, 07, 08 | SATISFIED | Truth 5. |

All six IDs appear in plan frontmatter and in `REQUIREMENTS.md` (checked `[x]` and "Complete" in the traceability table). No ORPHANED requirements: REQUIREMENTS.md maps exactly PLAT-01 to PLAT-06 to Phase 9, and every one is claimed by at least one plan.

### Anti-Patterns Found

None blocking. I did not find an unreferenced `TBD`, `FIXME` or `XXX` marker in the changed implementation files. The suite's static scanners pass.

### Warnings (non-blocking; advisory for Phase 10 or a follow-up)

These do not falsify a success criterion. They are the limits of what the evidence proves. The code-review dispositions for them are all still `open` (untriaged) in `09-REVIEW-DISPOSITION.md`.

1. **WR-01, `commandWindows` is tied to `C:\PROGRA~1\Git\bin\sh.exe`.** PLAT-03 is proved on one machine with a default Git install. A per-user, 32-bit, custom-prefix or no-8.3-name install fails, and by the review's expectation silently (the Codex hook becomes a no-op). The record states this as "Limit for Phase 10". Phase 10's user-facing wording must name this limit, or a follow-up must make the wrapper fail loudly or resolve `sh.exe` instead.
2. **WR-02, the 5 s connect timeout is paid per file.** A multi-file `apply_patch` on Windows with neither a compiler nor `bbj-ls` can exceed the 30 s hook timeout. The single-file case was proved on the machine. The record is honest that the gate pins the argument, not the effect, and that the connect-timing hypothesis stays a hypothesis.
3. **WR-03, `windows_codex_backslash_dotdot_skipped` is not an independent guard.** I confirmed this with a mutation. With the backslash conversion removed, `windows_codex_backslash_relative` fails, but the dotdot gate still reports `ok`, because the unresolved path simply does not exist. The 09-05 SUMMARY already admits the gate is "not a red test". The security-relevant property that a backslash-hidden `..` leaves the workspace and is skipped therefore has no test that fails if the conversion regresses. It is also not read on the machine (the W-3 re-run line says "covered by the Linux gate only"). The code path itself is correct on reading: normalization runs before the containment and `..` checks.

Recorded for Phase 10, not defects here: Codex hooks run in an app-server daemon, so `BBJ_HOME` must be in that daemon's environment (macOS side-1); a stale installer `hooks.json` double-fires (side-2); Claude Code ignores `commandWindows`; Codex asks for hook trust again after the upgrade; the installer's own `commandWindows` form is a PowerShell parse error (recorded, deliberately not changed in this phase).

### Human Verification Required

None outstanding. PLAT-01 and PLAT-05 can only be proved by a person on a real machine. That has been done and is on record as dated owner readings, and the record checker's rules were met. The code-review dispositions are workflow triage and do not gate the phase goal.

### Gaps Summary

No gaps. The phase goal is achieved: both platforms have owner-run readings on the `bbjcpl` route for both clients, `bbj-local` is shown connecting on Windows, the three Windows defects were fixed with gates, and a real-machine re-run met each of them. macOS had no defects. Both run records are in final mode and the Linux suite is green (921/921). The three warnings above bound how far the evidence reaches. They are for Phase 10 and are not blockers.

---

_Verified: 2026-10-13_
_Verifier: Claude (gsd-verifier)_
