# Phase 9: Windows and macOS verification - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-13
**Phase:** 9-Windows and macOS verification
**Areas discussed:** Run method and install source, Evidence record shape, Defect and known-gap policy, bbj-local and tier 2 on Windows

---

## Todos matched to the phase

| Option | Description | Selected |
|--------|-------------|----------|
| Pre-production wording (partial) | Fold only the `commandWindows` outcome and the "not yet run" platform facts; leave the docs-server wording for Phase 10 | ✓ |
| OAuth client handoff | Phase 8 shipped the block; this phase only records whether sign-in works on Windows and macOS | ✓ |
| Neither | Review both, fold none | |

**User's choice:** both folded, in the partial forms described.

---

## Run method and install source

### How should the owner perform the runs?

| Option | Description | Selected |
|--------|-------------|----------|
| Hybrid: scripted hook smoke, hand client runs | A small POSIX script feeds the hook captured payloads against the real bbjcpl and prints a result block; client steps are a hand runbook | ✓ |
| Hand runbook only | A checklist per platform, Phase 6 UAT style; cygpath facts read by hand | |
| Port linux-run/run.sh | Adapt the Phase 8 runner (fake model, fake compiler) to Git Bash and macOS | |

### Which model usage for the Write, Edit and apply_patch steps?

| Option | Description | Selected |
|--------|-------------|----------|
| Real model, minimal prompts | The owner's own clients and accounts; one bad write, one edit, one clean write per client and platform | ✓ |
| No model for the hook, real model once | Smoke covers bad/clean/edit; one real write per client and platform | |
| Fake model throughout | Loopback fake for Codex; no Claude Code run (PLAT-01 unmet) | |

### Where do the machines install from?

| Option | Description | Selected |
|--------|-------------|----------|
| Local clone of gsd/planning-setup | Clone and check out the branch; marketplace add <path> in both clients | ✓ |
| Push a throwaway branch, git marketplace | Short-lived public branch; closer to the release path | |
| Claude Code from main, Codex from clone | Two sources, two commits to record | |

### Which compiler discovery sources on Windows?

| Option | Description | Selected |
|--------|-------------|----------|
| bbj_home option and PATH | Claude Code: bbj_home with a drive-letter path; Codex: PATH or BBJ_HOME | ✓ |
| All four sources | bbj_home, BBJ_HOME, PATH and /c/bbx, each its own run | |
| PATH only | One run per client; compiler-path conversion not shown | |

**User's choice:** the recommended option in all four questions.
**Notes:** none.

---

## Evidence record shape

### How are the runs recorded?

| Option | Description | Selected |
|--------|-------------|----------|
| One record per platform | 09-WINDOWS-RUN.md and 09-MACOS-RUN.md in the 08-LINUX-RUN.md shape | ✓ |
| One 09-RUNS.md with a table | A run matrix plus short sections | |
| Only in the UAT file | Notes in 09-UAT.md tests, Phase 6 style | |

### What raw output goes into the repository?

| Option | Description | Selected |
|--------|-------------|----------|
| Result blocks and short excerpts only | Result block, compiler lines, feedback text, mcp/hooks list lines; nothing else | ✓ |
| Commit an evidence/ directory | Phase 6 style: output files and transcript excerpts | |
| Nothing raw, prose only | Observations rewritten as prose | |

### How are machine-specific paths handled?

| Option | Description | Selected |
|--------|-------------|----------|
| Placeholders, like Phase 8 | <home>, <checkout>; BBj home kept; space in the project path kept | ✓ |
| Keep paths verbatim | Owner's user name lands in the repository | |
| Scrub everything but drive letters | Loses the space-in-path proof | |

### How does each outcome tie back to the requirement?

| Option | Description | Selected |
|--------|-------------|----------|
| Per-route verdict line naming PLAT ids | "PLAT-01: met", "PLAT-04: not run (reason)" at the end of each route section | ✓ |
| A coverage table at the top | One table per record, no verdict lines | |
| Leave it to VERIFICATION.md | Records stay observational | |

**User's choice:** the recommended option in all four questions.
**Notes:** none.

---

## Defect and known-gap policy

### How is a defect worked?

| Option | Description | Selected |
|--------|-------------|----------|
| Fix, gate, re-run that route | Fix plus fake-based gate, owner re-runs the affected route, second dated reading | ✓ |
| Collect all, fix once, full re-run | Run everything, batch the fixes, re-run everything | |
| Record only, fix in Phase 10 | Phase 9 observes; Phase 10 fixes and re-runs | |

### What qualifies as a known gap?

| Option | Description | Selected |
|--------|-------------|----------|
| Owner decides at the checkpoint | Candidates: Windows-only behaviour no fake models, contract or safety-gate change, host bug | ✓ |
| Host bugs only | Everything in this repo must be fixed, extending fakes if needed | |
| Anything without a fake is a gap | Narrowest fix scope | |

### If Codex on Windows does not run sh "...", what ships?

| Option | Description | Selected |
|--------|-------------|----------|
| Try commandWindows in the plugin hooks.json first | Add the entry, re-run; fall back to a documented config.toml step and a recorded gap | ✓ |
| Document a user-side config.toml step only | Never change hooks.json | |
| Record as a known gap, no fix | Codex plugin route on Windows waits for a later release | |

### What CI gate pins a Windows-branch fix?

| Option | Description | Selected |
|--------|-------------|----------|
| Extend test_discovery.sh with the fake cygpath | Drive-letter file, space in path, ;-joined -P list; a test_layout.py gate if commandWindows ships | ✓ |
| New test_windows_branch.sh | Dedicated file and prefix | |
| Mutation-style proof per fix | Copy-mutate-expect-FAIL for each fix | |

**User's choice:** the recommended option in all four questions.
**Notes:** none.

---

## bbj-local and tier 2 on Windows

### What reading proves bbj-local connects?

| Option | Description | Selected |
|--------|-------------|----------|
| Listed as connected plus one tool call | /mcp or codex mcp list line plus one bbj_check_syntax call in each client | ✓ |
| Listed as connected only | The list line only | |
| Tool call only | The tool result only | |

### Does the Windows run exercise the hook's tier-2 route?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, one smoke-script run with bbjcpl hidden | BBJ_HOME empty, bbjcpl off PATH, BBjServices running; expect "bbj-local reported N error(s)" | ✓ |
| No, PLAT-04 is the MCP connection only | Tier 2 under Git for Windows stays not run | |
| Yes, through a real client write | Hide bbjcpl and let Claude Code write a bad file | |

### If BBjServices cannot run on Windows?

| Option | Description | Selected |
|--------|-------------|----------|
| Record not run, keep the opt-in proof | "PLAT-04: not run (reason)"; opt-in half still shown; Phase 10 keeps a not-run line | ✓ |
| Fall back to macOS for PLAT-04 | Run the connection on the Mac instead | |
| Block the phase until it runs | PLAT-04 required | |

### Does the Windows run check the no-route notice?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, in the smoke script | Every route off: exit 0, the notice JSON, the claim file on a Windows path | ✓ |
| No, Linux covers it | Keep the Windows run to the two check routes | |

**User's choice:** the recommended option in all four questions.
**Notes:** none.

---

## Claude's Discretion

- Smoke script name, home directory, result-block keys, and how it points at the hook.
- Runbook order per platform and the bad and clean `.bbj` contents.
- How the owner hands readings back (pasted blocks in the checkpoint reply).
- Which existing `test_discovery.sh` cases cover a fix; gate names.
- Side readings: docs-server sign-in on each platform, client versions.

## Deferred Ideas

- Porting `linux-run/run.sh` to Git Bash and macOS.
- Running the full test suite under Git Bash on Windows (already a future requirement).
