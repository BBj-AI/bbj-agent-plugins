---
phase: 13-windows-hook-fixes
verified: 2026-10-15T20:29:30Z
status: passed
score: 4/4 must-haves verified
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
covered_digest: "v3:sha256:322874824b7e001b13dbbe64969190f0d6f7dde643762635053e3dd52bf20f7c"
behavior_unverified: 0
overrides_applied: 0
decision_coverage:
  honored: 21
  total: 21
  not_honored: []
human_verification: []
---

# Phase 13: Windows hook fixes Verification Report

**Phase Goal:** The hook on Windows never fails silently because of where Git for Windows is installed, never runs past the 30 s hook timeout on a large patch with no check route, and the backslash path gate guards what it claims to.
**Verified:** 2026-10-15T20:29:30Z
**Status:** passed
**Re-verification:** No (initial verification)

Windows behaviour is judged from the owner run record `13-WINDOWS-RUN.md` (CI has no Windows).
Everything else was checked against the code and by runs made during this verification.

## Goal Achievement

### Observable Truths (ROADMAP Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (FIX-01): a Codex user on Windows whose Git is not at `C:\Program Files\Git` gets a hook that checks the file, or a visible message naming the missing `sh.exe`, never a silent no-op; owner-confirmed on real Windows; `layout_hook_command_windows` pins the new `commandWindows`; `claude plugin validate --strict` passes | VERIFIED | `plugins/bbj/hooks/hooks.json` `commandWindows` is 1183 chars, sha256 `ae8707fb...7d51`, equal to the plan 13-02 pin (computed here). The lookup order is ProgramFiles, ProgramFiles(x86), `LOCALAPPDATA\Programs`, `sh` on PATH, then `bin` next to `git` on PATH. In the not-found branch, `findstr /n /r "^"` reads stdin; the hook exits 0 only when every line is read in full and none names `.bbj/.src/.bbx`, and otherwise prints three stderr lines through `cmd` and exits 2. The 8.3 short name is gone. Run record (Windows 10 19045, Git 2.52.0, PS 5.1, Codex 0.162.1): 15 launcher cases as expected, 0 differ (pf86, localappdata, sh_on_path, git_on_path, none_*, clm_*). In Codex, c2-bad (Git folder renamed) was "Blocked by hook" with the not-found text, and c1/c3 gave bbjcpl feedback. Round 2 re-ran harness fixes H1-H4 at 81f1b5c with the hook string unchanged. Verdict line: `- FIX-01: met`. `layout_hook_command_windows ok`; `ci_validate_root/plugins_bbj/plugins_bbj_local ok`. |
| 2 | SC2 (FIX-02): a gate on fakes runs one hook call over a many-file Codex `apply_patch` with no route on the Windows path (5 s connect timeout): tier 2 tried once, other files skip it, run well under 30 s; when `bbj-ls` answers every file is checked; restoring the per-file connect makes the gate fail | VERIFIED | `bbj-check.sh:254` `case "$NR_T2" in refused\|nocurl\|badurl\|noconn) return 1 ;; esac # t2-cache`. `NR_T2` is reset once per process in `main` (:680), and `note_noroute` still counts and lists the files it skips. Gates: `tier2_once_windows_refused ok` (12 files, 1 curl call, `--connect-timeout 5`, notice "and 7 more"), `tier2_once_windows_connect_timeout ok` (1 call, "(connect timed out)"), `tier2_transfer_timeout_not_cached ok` (12 calls), `tier2_every_file_when_answering ok` (12 requests, real curl against the fake server). Independent mutation here: deleting the `# t2-cache` line makes both once-gates FAIL with 12 curl calls (the copied test exits 1). Kept in the suite as `hookmut_t2_cache ok`. The time bound holds by construction: one call, capped by `--connect-timeout 5` and `-m 12`; no clock is asserted, because the fake does not sleep. |
| 3 | SC3 (FIX-03): a mutation that removes the backslash conversion makes `windows_codex_backslash_dotdot_skipped` fail, the unmutated tree passes, the mutation case is kept in the suite | VERIFIED | The bait file `sub\..\..\x.bbj` is created inside the workspace (`tests/test_discovery.sh`). Unmutated: `windows_codex_backslash_dotdot_skipped ok`. Independent mutation here, dropping `\| tr '\\' '/'` from `wpath_norm`: the gate FAILs ("calls 1"), and `windows_codex_backslash_dot_control` and `_relative` FAIL too (exit 1). The kept case `tests/test_hook_mutation.sh` reports `hookmut_backslash_conversion ok`, `hookmut_dotdot_check ok` and the controls `hookmut_discovery_control ok`. It is discovered by `tests/run.sh`. |
| 4 | SC4: exit contract and safety gates hold: exit 0/2 with empty stdout, `-N` on every compiler call, loopback-only `curl` with `--noproxy '*'` and `--proto =http`, never the hosted check; `sh tests/ci.sh` passes | VERIFIED | The curl call is still one line, with `-q -sS -g --noproxy '*' --proto =http --connect-timeout "$_ct" -m 12 -w ...` and no redirect flag. `static_compiler_call ok`, `static_url_hosts ok`, `static_curl_call ok`, `static_notice_single_writer ok`, `static_timeout_command ok`, every `contract_{dash,bash,busybox}_*` ok, and the never-execute gates ok. Run here: `sh tests/run.sh` gave `SUMMARY: ok=786 fail=0 skip=0` with exit 0, and `sh tests/ci.sh` gave `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0` with exit 0. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

Plan-level must-haves (43 truths across 13-01..13-06) were checked as detail under the four criteria. Points worth naming:

- 13-01, D-12: the `noconn` classification (exit 28, write-out time_connect all zeros, empty remote_ip) was spot-checked against **real** curl 8.18.0 here. A connect to a blackhole address with `--connect-timeout 1` printed `\n0.000000 ` and exited 28, which is exactly the shape the hook matches. An exit 28 without write-out stays silent (`notice_curl_exit_28_silent ok`).
- 13-01, D-11/D-13: the remaining limit (a `bbj-ls` that accepts the connection and never answers costs up to `-m 12` per file) is stated in three places: the hook header (lines 44-46), the Codex page `## Windows` timeout paragraph, and the run record's FIX-02 scope line.
- 13-02, D-05/D-07: `layout_hook_windows_safe ok` (none of 7 forbidden constructs) and `layout_hook_windows_parts ok` (10 parts, passthrough last). Six `layout_mutation_hook_windows_*` cases are ok. `plugin_route_command_windows ok` closes IN-02.
- 13-04: the launcher has `refuse`, `safe_out`, `BASE=$HOME/.cache/bbj-phase13`, and a non-recursive junction `rmdir` before `rm -rf` in `do_clean`. The bundle exists outside the repository. The artifact check flags the skeleton line `- FIX-01: awaiting the owner run` as missing. That is expected: plan 13-05 replaced it with `- FIX-01: met`.
- 13-05: the record has the ten headings in order, dated rounds 1 and 2, `<home>/<checkout>/<work>` placeholders and no user path or OAuth values. The per-user section names `Method: junction under a throwaway LOCALAPPDATA`.
- 13-06: the Codex page and README sentences match `## For the install page` of the run record. No 8.3 short-name path remains. `09-REVIEW-DISPOSITION.md` marks WR-01, WR-02, WR-03 and IN-02 fixed with commits and `open: 2`. ROADMAP Phase 15 carries the D-21 note.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/scripts/bbj-check.sh` | per-run tier-2 cache, `-w` write-out parse, `noconn` state and notice | VERIFIED | cache line :254, split :293-298, noconn :306-310, notice arm :205; wired from `check_file` (:525, :572) |
| `plugins/bbj/hooks/hooks.json` | new `commandWindows`; `command`, matcher, timeout unchanged | VERIFIED | sha256 equals the pin; `command` is still `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`, timeout 30 |
| `tests/fake-bin/curl` | `FAKE_CURL_WRITEOUT` seam | VERIFIED | prints `\n<value>` only when set |
| `tests/test_tier2_fake.sh` | NMANY, MANYPAYLOAD, oncegate, SC2 gates | VERIFIED | 4 gates ok; fail under mutation |
| `tests/test_layout.py` | exact pin, safe/parts guards, 6 mutation cases | VERIFIED | all ok |
| `tests/test_codex_patch.sh` | `plugin_route_command_windows` tightened | VERIFIED | ok |
| `tests/test_discovery.sh` | bait file, dot control | VERIFIED | ok; fail under mutation |
| `tests/test_hook_mutation.sh` | kept mutation cases (prefix `hookmut_`) | VERIFIED | 5 gates ok |
| `.planning/phases/13-windows-hook-fixes/windows-run/launcher.sh`, `runbook.md` | Windows harness | VERIFIED | H1-H4 fixed in faf5008, re-run round 2 met |
| `.planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md` | run record, install-page sentences, FIX-01 verdict | VERIFIED | `- FIX-01: met` |
| `docs/install-codex.md`, `README.md`, `tests/test_install_pages.sh` | lookup, message, remaining tier-2 limit, page pins | VERIFIED | `codex_has__LOCALAPPDATA__Programs_Git ok`, `codex_has_Git_for_Windows_sh_exe_not_found ok` |

### Key Link Verification

`gsd-tools verify.key-links` cannot resolve these plans' prose `from:` fields, so every link was checked by hand with its declared pattern.

| From | To | Via | Status |
|------|----|-----|--------|
| `no_tier1_route` cache line | `main` `NR_T2=` reset | global `NR_T2` | WIRED (`^  NR_T2=$` 1 hit) |
| curl `-w` write-out | noconn classification | `_out` split at its last newline | WIRED (`%{time_connect} %{remote_ip}` 1 hit) |
| `notice` | `NR_T2=noconn` | case arm | WIRED (`noconn) _why2=` 1 hit) |
| `hooks.json` commandWindows | `test_layout.py` HOOK_COMMAND_WINDOWS | exact equality | WIRED (gate ok) |
| `hooks.json` commandWindows | `test_codex_patch.sh` ROUTE_CMD_WIN | python3 -I reader | WIRED (7 hits, gate ok) |
| `hooks.json` commandWindows | `windows-run/launcher.sh` | extract_cmd + sha256 | WIRED (owner block cmd_sha256 equals pin) |
| `test_hook_mutation.sh` fresh_tree | copied `tests/lib.sh` | `cp -R "$REPO/tests"` | WIRED |
| `mutant` | nested gate output | `^gate $_g FAIL ` | WIRED |
| hookmut_t2_cache sed | `# t2-cache` marker | `/# t2-cache$/d` | WIRED (independent mutation confirms) |
| runbook reply template | run record | `launcher-block:` key | WIRED |
| run record `## For the install page` | `docs/install-codex.md`, README | verbatim sentences | WIRED |
| `test_install_pages.sh` need list | Codex page | grep -qF | WIRED (lines 225-226) |

### Data-Flow Trace (Level 4)

Not applicable: no rendered dynamic data. The equivalent flow is NR_T2 → notice text, and it is exercised end to end by the oncegate notice assertions.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Real curl gives the noconn write-out shape on a connect timeout | `curl ... --connect-timeout 1 -m 12 -w '\n%{time_connect} %{remote_ip}' http://10.255.255.1:5009/mcp` | `\n0.000000 `, rc=28, 1.0 s | PASS |
| Restoring per-file connect fails the SC2 gate | scratch copy with `/# t2-cache$/d`, run copied `test_tier2_fake.sh` | both once-gates FAIL, 12 calls, rc=1 | PASS |
| Removing backslash conversion fails the FIX-03 gate | scratch copy without `\| tr '\\' '/'` in `wpath_norm`, run copied `test_discovery.sh` | dotdot gate FAIL (calls 1), rc=1 | PASS |
| commandWindows matches the pin | python3 json + hashlib over hooks.json | 1183 chars, `ae8707fb...7d51` | PASS |
| Full suite | `sh tests/run.sh` | ok=786 fail=0 skip=0, exit 0 | PASS |
| CI entry point | `sh tests/ci.sh` | ok=6 fail=0 skip=0 run_sh_exit=0, exit 0 | PASS |

### Probe Execution

No `scripts/*/tests/probe-*.sh` exist, and no plan declares a probe. Step 7c: not applicable.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| FIX-01 | 13-02, 13-04, 13-05, 13-06 | Git outside `C:\Program Files\Git` gets a working hook or a visible message, never a silent no-op (WR-01) | SATISFIED | SC1 above; run record verdict `met` |
| FIX-02 | 13-01, 13-03, 13-06 | many-file `apply_patch` with no route stays within 30 s: connect paid once per run (WR-02) | SATISFIED | SC2 above |
| FIX-03 | 13-03, 13-06 | backslash gate fails when the conversion is removed, shown by a mutation run (WR-03) | SATISFIED | SC3 above |

No orphaned requirements: REQUIREMENTS.md maps only FIX-01..03 to Phase 13, and all three are claimed by plans.

### Decision Coverage

All trackable CONTEXT.md decisions are honored by shipped artifacts (21/21, `check.decision-coverage-verify`). D-17 named the control `sub\..\sub\f.bbj`; the plan used `sub\.\f.bbj`, a research correction documented in 13-03 (codex_patch skips every `..` path, so the original control could never give a call).

### Test Quality Audit

| Test File | Linked Req | Active | Skipped | Circular | Assertion Level | Verdict |
|-----------|-----------|--------|---------|----------|-----------------|---------|
| `tests/test_tier2_fake.sh` (once/transfer/every gates) | FIX-02 | 4 | 0 | no | Behavioral (call count, connect-timeout value, notice text, exit, stdout/stderr) | OK |
| `tests/test_discovery.sh` (bait, dot control) | FIX-03 | 2 | 0 | no | Behavioral (compiler call count and target) | OK |
| `tests/test_hook_mutation.sh` | FIX-02, FIX-03 | 5 | 0 | no | Behavioral (nested gate FAIL + exit 1; control must pass; no-op mutation FAILs) | OK |
| `tests/test_layout.py` (hook_windows_*) | FIX-01 | 4 + 6 mutation | 0 | no | Value (exact string pin, parts/forbidden lists) | OK |
| `tests/test_codex_patch.sh` (plugin_route_command_windows) | FIX-01 | 1 | 0 | no | Value | OK |

Disabled tests on requirements: 0. Circular patterns: 0 (expected values are fixed literals, not captured from the hook). Insufficient assertions: 0. Skip handling: a file system that cannot hold a backslash name gives skip, and FAIL under `CI=true`. That never happened in this run (skip=0).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `plugins/bbj/scripts/bbj-check.sh` | 333 | `\uXXXX` | Info | Escape notation in a comment, not a debt marker |
| `tests/test_codex_patch.sh` | 106 | `\uXXXX` | Info | Same |
| `.planning/phases/13-windows-hook-fixes/13-RESEARCH.md` | 171 | local checkout path `/home/coder/...` | Info | Planning doc, not shipped; the 13-04 "no host home path" rule covers only the launcher, runbook and record, which are clean |

No TBD/FIXME/TODO/HACK/placeholder markers in any file changed by the phase.

### Residual risks (Info, not gaps)

1. **Git for Windows curl and `noconn`.** The write-out shape was verified on Linux curl 7.58-8.18 (research) and 8.18.0 (here), not on Git for Windows' curl (RESEARCH A7). If that curl printed a remote_ip after a connect timeout, the hook would fall back to the safe silent "route gave no verdict" outcome. That outcome is not cached, so a loopback firewall that drops packets (the only case that times out instead of refusing) would pay 5 s per file. SC2 asks for proof on fakes, and that proof is met. A closed port on Windows is refused (exit 7) and cached either way.
2. **Per-user lookup under Codex.** c3 could not show which lookup found Git, because Codex hands the hook the machine's PATH and ProgramFiles (O1). The per-user lookup is proven by launcher case `localappdata_bad` through Windows PowerShell 5.1 with the hook's flags. The record, the Codex page and the README list "a real per-user Git for Windows install" under Not run.
3. **A non-Git-for-Windows `sh` found on PATH without `cygpath`** (for example busybox-w32) would run the hook with `WIN=0`, and the Codex branch would exit 0 on a drive-letter `cwd`. This is outside FIX-01, which is about where Git for Windows is installed; noted for completeness.

### Human Verification Required

None outstanding. SC1's owner run on real Windows is already recorded in `13-WINDOWS-RUN.md` (round 1 on 2026-10-15, round 2 re-run of H1-H4) with verdict `FIX-01: met`. No plan defers a `<human-check>`.

### Gaps Summary

No gaps. All four roadmap success criteria and the three requirements are met:

- **FIX-01:** the code looks up `sh.exe` in five places and blocks a BBj write with the not-found message otherwise. The owner's Windows run confirmed this, including a BBj write blocked in Codex with Git hidden.
- **FIX-02:** a nothing-reached tier-2 outcome is cached for the rest of the hook run.
- **FIX-03:** the backslash gate is armed by a bait file.

The FIX-02 and FIX-03 gates fail under the mutation they guard against, which was shown both by the kept `hookmut_` cases and by the independent mutations run here. `sh tests/run.sh` and `sh tests/ci.sh` are green.

---

_Verified: 2026-10-15T20:29:30Z_
_Verifier: Claude (gsd-verifier)_
