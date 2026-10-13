---
phase: "09"
slug: "windows-and-macos-verification"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-13"
---

# Phase 09 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| CI to tools on PATH | the test decides which `cygpath` and which compiler the hook can find | owner readings, repository files, plugin cache copies |
| Codex and Claude Code to the hook command | the host chooses the shell and expands the command string; `commandWindows` changes what a Windows host runs | owner readings, repository files, plugin cache copies |
| executor to origin | a push publishes the planning branch (only after the owner chose it) | owner readings, repository files, plugin cache copies |
| hook to the Mac's file system | discovery reads BBj homes and the compiler path | owner readings, repository files, plugin cache copies |
| owner answers to shipped files | a fix changes what every user installs | owner readings, repository files, plugin cache copies |
| owner answers to shipped files | a macOS fix changes what every user installs, on every platform | owner readings, repository files, plugin cache copies |
| owner replies to the repository | readings from two personal machines become committed text | owner readings, repository files, plugin cache copies |
| owner reply to the repository | pasted readings become committed records | owner readings, repository files, plugin cache copies |
| owner reply to the repository | pasted readings from a personal machine become committed text | owner readings, repository files, plugin cache copies |
| patch text to the file system | header paths from an apply_patch payload decide which file the hook reads and hands to the compiler | owner readings, repository files, plugin cache copies |
| payload paths to awk and sh | Windows paths hold backslashes and spaces | owner readings, repository files, plugin cache copies |
| records to Phase 10 | the install wording may claim only what the verdict lines say | owner readings, repository files, plugin cache copies |
| runbook to the owner's real client homes | the owner follows these steps in their real Claude Code and Codex homes (a user install) | owner readings, repository files, plugin cache copies |
| smoke output to the repository | pasted blocks become committed records | owner readings, repository files, plugin cache copies |
| smoke script to the owner's machine | runs on the owner's real Windows and Mac with a real BBj install and real client homes nearby | owner readings, repository files, plugin cache copies |
| test shell to hook process | test-chosen payload paths and environment reach the hook, as a host's would | owner readings, repository files, plugin cache copies |
| this checkout to the owner's machines | the commit travels by bundle, network clone or GitHub | owner readings, repository files, plugin cache copies |
| updated plugin to the owner's clients | the re-run must test the fixed files | owner readings, repository files, plugin cache copies |
| updated plugin to the owner's clients | the re-run must test the fixed files, not a stale cache copy | owner readings, repository files, plugin cache copies |

---

## Threat Register

Register authored at plan time (33 threats across plans 09-01 to 09-08, all disposition `mitigate`). Verified 2026-10-13 by gsd-security-auditor at ASVS level 1 (block_on: high) on tree 3226217.

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-09-01 | Tampering | tests/fake-bin/cygpath seam | low | mitigate | The seam is active only when FAKE_CYGDRIVE_ROOT is non-empty; Task 1 verifies `command_windows_cygpath` (installer test) and the existing `windows_p_list`, `windows_target` gates stay ok; the block unsets the variable before `finish` | closed |
| T-09-02 | Elevation of Privilege | the new gates running a compiler | medium | mitigate | PATH is `$WORK/winbin:/usr/bin:/bin`, every home is under $WORK, the only compiler is a copy of the logging fake; `tests/test_never_execute.sh` and `tests/test_static_guards.sh` run in the full suite of Task 2 | closed |
| T-09-03 | Repudiation | gates that pass on a broken branch | low | mitigate | Mutation check in Task 1: a temp copy of the hook that skips drive-letter files makes `windows_drive_file` FAIL; the checkout is never edited by the check | closed |
| T-09-04 | Elevation of Privilege | smoke.sh running BBj | high | mitigate | The compiler is reached only through the shipped hook (its static gate requires `-N` on every call); the smoke has no compiler, bbj or curl command of its own, proven by the grep in both verify blocks; fixtures are two one-line programs | closed |
| T-09-05 | Information Disclosure | result blocks carrying the user name or home path | high | mitigate | `scrub` replaces HOME, the checkout and WORK in POSIX, backslash and forward-slash forms; a BBj home under HOME is scrubbed too; the Linux verify checks that no block holds the real home path | closed |
| T-09-06 | Tampering | Windows paths read as awk escapes or split by the shell | medium | mitigate | Paths reach awk only through ENVIRON with an index/substr replace (no regex, no `awk -v`, checked by grep); every path is one quoted argument | closed |
| T-09-07 | Tampering | writes outside the temp directory | medium | mitigate | Everything goes under `mkwork` (removed by its trap) except `emit DIR`, which refuses an existing non-empty DIR (verified: second emit exits 2) | closed |
| T-09-08 | Denial of Service | tier2 or noroute run with an empty PATH | low | mitigate | The return code of `no_compiler_path` is checked; on failure the block says `not run` and the hook is not called | closed |
| T-09-09 | Elevation of Privilege | a runbook step that skips hook review | high | mitigate | Trust is given only in `/hooks`; the verify greps both runbooks for the bypass flag's name stem and requires 0 | closed |
| T-09-10 | Information Disclosure | OAuth URLs, tokens or user names pasted into records | high | mitigate | The runbooks ask only for "signed in" or the error text and the Auth column; the placeholder rule (D-07) is stated in "Before you start"; `check-records.sh` filled mode fails on a Users or /home path with a real name (selftest proves it) | closed |
| T-09-11 | Tampering | the optional installer step writing into the real `~/.codex` next to the plugin | medium | mitigate | W11 uses a throwaway CODEX_HOME and skills dir only and is deleted after; the runbook says not to run the installer against the real home while the plugin is installed | closed |
| T-09-12 | Repudiation | a record claiming more than was observed | medium | mitigate | `check-records.sh` enforces the verdict grammar, readings per section, no empty `met`, and the re-run reading order; Phase 10 quotes only verdict lines | closed |
| T-09-13 | Tampering | the commit the owner runs differs from the one recorded | medium | mitigate | `git bundle verify`; the owner checks `rev-parse --short HEAD` in W1; the verification compares `checkout-commit` with the transferred sha and asks again on a mismatch | closed |
| T-09-14 | Information Disclosure | push publishing planning content | medium | mitigate | Push happens only on the owner's explicit choice in a blocking checkpoint with no auto_select; only `gsd/planning-setup`, never main or a tag, never forced; the amendment is recorded in 09-CONTEXT.md | closed |
| T-09-15 | Information Disclosure | user name or home path in the pasted reply | high | mitigate | The instructions require placeholders; the verification scrubs every Users path segment and the clone path before writing; `check-records.sh windows filled` must print `check no_home_leak ok` | closed |
| T-09-16 | Elevation of Privilege | a run that executes BBj | high | mitigate | The owner's steps reach a compiler only through the hook (`-N`); smoke.sh has no compiler call of its own (plan 09-02 gate); the dry run used the fake compiler only | closed |
| T-09-17 | Tampering | `commandWindows` changing the trusted hook definition | high | mitigate | Only the owner's exact string ships (Task 2, no auto_select); `layout_hook_command_windows` pins it and its mutation case proves the pin; `command` stays pinned by `layout_hook_command`; the re-trust consequence is recorded for Phase 10 (D-11 costly) | closed |
| T-09-18 | Tampering | backslash conversion opening a path outside the workspace | high | mitigate | Conversion happens before the containment and `..` checks, WIN=1 only; `windows_codex_backslash_dotdot_skipped` proves a `sub\..\..\x.bbj` header gives no compiler call; path-traversal canon otherwise goes to /gsd-secure-phase | closed |
| T-09-19 | Elevation of Privilege | a hook fix that drops `-N` or adds a non-loopback call | high | mitigate | `tests/test_static_guards.sh`, `tests/test_never_execute.sh` and `tests/test_exit_contract.sh` must print no FAIL; `sh tests/ci.sh` must exit 0 before any re-run is requested (D-09) | closed |
| T-09-20 | Repudiation | a fix or gap the owner did not choose | medium | mitigate | Task 2 is blocking-human with no auto_select; Task 3 records the owner's answers verbatim before building anything | closed |
| T-09-21 | Information Disclosure | a capture step leaking a payload or path | medium | mitigate | A capture writes only into a directory the owner names, is removed after, and only scrubbed excerpts reach the record (D-06, D-07) | closed |
| T-09-22 | Tampering | a re-run on a stale Codex cache copy | medium | mitigate | The runbook's re-run step compares the cache with the checkout through the smoke header (`script_identical_to_checkout`, `hooks_json_identical_to_checkout`); `cache-identical` is a required reply key; `checkout-commit` must equal the transferred sha | closed |
| T-09-23 | Information Disclosure | user names or home paths in round-2 and macOS replies | high | mitigate | Scrub on intake; `check-records.sh macos filled` must print `check no_home_leak ok`; the Windows final check includes the same rule | closed |
| T-09-24 | Repudiation | a fix written as confirmed without a second reading | medium | mitigate | `check-records.sh windows final` requires two dated readings in order for every `fixed in` verdict and an existing commit | closed |
| T-09-25 | Elevation of Privilege | a run that executes BBj | high | mitigate | All owner steps reach a compiler only through the hook (`-N`, static gate); the preflight uses the fake compiler only | closed |
| T-09-26 | Elevation of Privilege | a macOS fix that drops `-N` or adds a non-loopback call | high | mitigate | The contract tests and `sh tests/ci.sh` must pass before any re-run; `tests/test_static_guards.sh` rejects a compiler call without `-N` and a curl call without `--noproxy`/`--proto =http` | closed |
| T-09-27 | Repudiation | a fix or gap the owner did not choose | medium | mitigate | Task 2 is blocking-human with no auto_select; answers are recorded verbatim before any build | closed |
| T-09-28 | Tampering | a macOS fix silently changing the Windows branch | medium | mitigate | A fix touching the Windows branch or hooks.json lists the Windows routes under `re-run needed:` and is re-run in plan 09-08; the Windows gates of plan 09-01 run in the CI gate | closed |
| T-09-29 | Information Disclosure | user names in the macOS record | high | mitigate | `check-records.sh macos filled` (no_home_leak) after every record write | closed |
| T-09-30 | Repudiation | a verdict line without a reading behind it | medium | mitigate | `check-records.sh` final for both records (dated readings in order, no empty met, no interim values, existing fix commits) is the closing condition | closed |
| T-09-31 | Information Disclosure | user names in the final records | high | mitigate | final mode includes `no_home_leak` for both records; replies are scrubbed on intake | closed |
| T-09-32 | Tampering | a re-run against a stale plugin copy | medium | mitigate | `cache-identical` and `checkout-commit` are required reply keys; the preflight transfers only a CI-green commit | closed |
| T-09-33 | Tampering | Phase 9 changing the pinned 0.2.0 wording | low | mitigate | `git diff --quiet 2524dff` over docs, README, CHANGELOG, codex and the pinned-text tests, plus the STATUS_LINE byte check | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Audit Evidence

Abbreviations: WR = 09-WINDOWS-RUN.md, MR = 09-MACOS-RUN.md, WB/MB = the Windows and macOS runbooks under platform-run/. "Live" means the auditor ran it. Six threats (T-09-21, 26, 27, 28, 32 and the capture half of T-09-21) sat on paths that never ran; they are closed on the guard that exists, and the evidence says so.

| Threat ID | Evidence |
|-----------|----------|
| T-09-01 | `tests/fake-bin/cygpath:12` uses the seam only when `FAKE_CYGDRIVE_ROOT` is non-empty; `-w` unchanged; `tests/test_discovery.sh:302` unsets it before `finish`; `test_install_codex.sh` unchanged since 2524dff |
| T-09-02 | `test_discovery.sh:10,161` PATH is `$WORK/winbin:/usr/bin:/bin`; homes and the fake `bbjcpl.exe` copy under `$WORK`; `tests/lib.sh:50` empties the default homes; live never-execute and static guards rc 0 |
| T-09-03 | Mutation target `bbj-check.sh:479` exists and the plan's sed still changes it (scratch copy); 09-01-SUMMARY records `windows_drive_file FAIL` count 1 on the mutant |
| T-09-04 | smoke.sh has 0 compiler/bbj/curl command lines outside comments; it only runs the hook (:232) and the hooks.json command (:291); live `static_compiler_call_bbj-check.sh ok` |
| T-09-05 | `scrub` (smoke.sh:114-142) replaces HOME, checkout and WORK in three forms; BBj home under HOME scrubbed too; live `smoke.sh claude` and `emit`: 0 `$HOME` hits |
| T-09-06 | awk reads paths from ENVIRON with index/substr replace (smoke.sh:115-139); `awk -v` outside comments: 0 |
| T-09-07 | `mkwork` (smoke.sh:70; lib.sh:72-78 EXIT trap, state dir under `$WORK`); emit refusal at smoke.sh:486-489; live second `emit` exited 2 refused |
| T-09-08 | smoke.sh:400-404 checks the `no_compiler_path` status and prints `not run`; callers return before any hook call (:421, :445) |
| T-09-09 | windows-runbook.md:29 and macos-runbook.md:28: trust only in `/hooks`; grep for the bypass-flag stems finds 0 in both runbooks |
| T-09-10 | Runbooks require placeholders and forbid URLs/tokens; OAuth reply values are signed in / error / not tried; check-records.sh `no_home_leak` (:76-77,108-111,215); selftest `mut_home_path`; live `selftest ok` |
| T-09-11 | windows-runbook.md:286-299 (W11): throwaway `CODEX_HOME` and `--skills-dir`, removed afterwards; never against the real ~/.codex |
| T-09-12 | check-records.sh verdict grammar :57-69, `verdict_lines` :179-196, `readings_dated` :198-202, `empty_section_met` :204-213, `readings_in_order` :263-280; live `windows final` and `macos final` rc 0 |
| T-09-13 | Owner chose push, so `git bundle verify` covered the dry runs (WR:64); W1 checks rev-parse; `checkout-commit` 977135c and d598854 equal the pushed tips |
| T-09-14 | D-03 amendment at 09-CONTEXT.md:66-70; the only phase-9 pushes are 977135c and d598854, both fast-forward to `gsd/planning-setup`; origin/main and tag 0.2.0 hold no phase-9 commit |
| T-09-15 | Live `windows final`: `no_home_leak ok`; scan of all 20 committed versions of both records and 09-CONTEXT.md plus the two pushed tips: 0 user paths, 0 `$HOME`, 0 user/git name, 0 token-like strings |
| T-09-16 | The hook is the only way to a compiler (`bbj-check.sh:537` `-t -N -X`, live static gate ok); smoke.sh grep 0; the dry run used the fake compiler (WR:64) |
| T-09-17 | `hooks.json:10` `commandWindows` is byte-equal to the owner-accepted W-1 candidate (WR:691-699); pinned by `test_layout.py:39`, gate :181-184 and mutation case :400-416; `command` byte-identical since 2524dff; re-trust consequence recorded (WR:461,701,711) |
| T-09-18 | `wpath_norm` at `bbj-check.sh:579`/:615 runs under WIN=1 only, before cygpath (:616-618), containment (:619-628) and the `..` skip (:637-639); gate `test_discovery.sh:288-296`; scratch probe: removing the `..` skip or reordering gives 1 compiler call, so the gate FAILs |
| T-09-19 | Live: `test_static_guards.sh` rc 0 (compiler call, curl call, url hosts ok), `test_never_execute.sh` rc 0, `test_exit_contract.sh` rc 0 (86 ok); `-N` at :537, `--noproxy '*' --proto =http` at :281; `ci.sh` exit 0 in the 09-05 and 09-08 summaries |
| T-09-20 | WR:694-699 quotes the owner's words before the normalized answers; the answers commit 4014dcb precedes every test and fix commit (a93928d to 16c863b) |
| T-09-21 | Not exercised: every answer was `fix`, no capture step exists. The scrubbed-excerpt half is enforced by `no_home_leak` (live ok); the owner-named-directory half exists as a rule in 09-05-PLAN.md |
| T-09-22 | windows-runbook.md:364-397: SMOKE_ROOT header check and required `cache-identical`; smoke.sh:158-165 compares the files; round 2 reads `cache-identical: yes` (WR:1061) and `checkout-commit: d598854` (WR:1058) |
| T-09-23 | Live `macos final` and `windows final` both print `no_home_leak ok`; history scan 0 hits |
| T-09-24 | check-records.sh:274-279 requires two readings for a fixed verdict; :286-298 runs `git cat-file -e`; PLAT-03 fixed in 2197273 and PLAT-04 in 950d8bf, both checks ok live |
| T-09-25 | As T-09-16; the macOS dry run used the fake compiler (MR:67) |
| T-09-26 | Not exercised: no macOS fix (`git diff 6e2f63c HEAD -- plugins tests codex` empty); the guard exists in `test_static_guards.sh` (:72-83 `-N`, :22-50 curl flags, :85-100 loopback), live rc 0 |
| T-09-27 | Not exercised: no M-N line; MR:386 `decisions: none needed`, MR:387 `fixes: none`; no shipped change |
| T-09-28 | Not exercised: no macOS fix; MR:388 `re-run: none needed`; the Windows gates stay in `tests/test_discovery.sh`, run by `tests/run.sh` |
| T-09-29 | Live `macos final` prints `no_home_leak ok`; every committed version of MR scanned: 0 hits |
| T-09-30 | Live `check-records.sh windows final` and `macos final` both exit 0 with every check ok |
| T-09-31 | check-records.sh:215 runs `no_home_leak` before the filled-mode exit (:229), so final mode includes it; ok on both records live |
| T-09-32 | Not exercised: no re-run in 09-08, origin still at d598854; the required keys exist in both re-run templates (WB:392,395; MB:263,266) |
| T-09-33 | Live `git diff --quiet 2524dff -- docs README.md CHANGELOG.md codex` plus the three pinned-text tests exits 0; STATUS_LINE `grep -cxF` count 1; manifests unchanged |

Not counted toward the verdict, tracked elsewhere: WR-03 and WR-02 are open rows in 09-REVIEW-DISPOSITION.md (the dotdot gate also passes without the backslash conversion; the Windows connect timeout is paid per file). smoke.sh:65 prints its "no hook script" error line before scrub is set up; it is an error line, not a result block, and the intake scrub plus `no_home_leak` would catch it in a record.

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|

No accepted risks.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-13 | 33 | 33 | 0 | gsd-security-auditor (opus), dispatched by execute-phase verify:post |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-13 (14 high, 15 medium, 4 low; all closed)
