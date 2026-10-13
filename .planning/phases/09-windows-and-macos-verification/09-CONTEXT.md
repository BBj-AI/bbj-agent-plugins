# Phase 9: Windows and macOS verification - Context

**Gathered:** 2026-10-13
**Status:** Ready for planning

<domain>
## Phase Boundary

The owner runs the Claude Code plugin and the Codex plugin route on a real Windows machine (Git
for Windows, BBj with `bbjcpl`, Claude Code, Codex CLI) and a real Mac (BBj with `bbjcpl`
installed first), on the compile-only `bbjcpl` route: after Write and after Edit (Claude Code)
and after `apply_patch` (Codex) a bad `.bbj` gets `bbjcpl` feedback and a clean one gets
silence. On Windows the hook's `cygpath` branch is shown working on real paths (compiler path,
`-P` list joined with `;`, drive-letter file paths, a project path with a space), and
`bbj-local` is shown connecting in both clients where BBjServices runs, opt-in only. The run
settles spike 005's three Windows unknowns for the Codex plugin route. Each run is recorded
(OS, client and version, BBj version, route, outcome). Every defect found is fixed in the shipped
hook, plugin files or installer with a regression gate that runs in CI on fakes, or recorded as
a known gap with the owner's say-so. The Linux suite stays green (PLAT-01 to PLAT-06).

Not in this phase: the install wording, the version bump and the CHANGELOG (Phase 10 rewrites
and re-pins all platform text from these records; the pinned 0.2.0 lines stay verbatim, Phase 7
D-06 and Phase 8 D-16); a native Windows hook without Git for Windows; a Windows or macOS CI
runner; running the full suite under Git Bash. The hook's exit contract (exit 0 or 2, empty
stdout except the one notice JSON) and the static safety gates (`-N` on every compiler call,
loopback-only `curl` with `--noproxy '*'` and `--proto =http`, never the hosted check) are
untouchable. BBj code is never executed; the machines are the owner's own.

</domain>

<decisions>
## Implementation Decisions

### Locked before this discussion (roadmap, Phases 7 and 8, spikes)
- Evidence is recorded in the way of the v0.2.0 Phase 6 UAT and the Phase 8 Linux run record
  (`08-LINUX-RUN.md`); the owner runs the steps by hand on their own machines.
- Phase 8 D-07: a non-empty `CLAUDE_PLUGIN_ROOT` in the hook process marks the Codex plugin
  route. Confirmed on Linux; Windows has to show the value is a path `sh` accepts.
- Phase 8 D-17: real Codex runs use throwaway homes, never under `/tmp`; billed real-model runs
  only with the owner's approval. On the owner's own Windows and Mac machines the real client
  homes are the point of the phase (a user install), so the throwaway-home rule applies only
  where a scripted step would otherwise write into the real home.
- STATE blockers: the Mac needs BBj with `bbjcpl` before PLAT-05 can run; if BBjServices cannot
  run on Windows, PLAT-04 is a recorded gap and the docs keep a "not run" line.
- Scout fact: the GitHub default branch (`f15c257`) has no `.codex-plugin` overlay, so
  `codex plugin marketplace add BBj-AI/bbj-agent-plugins` would install the plugin without it
  (08-LINUX-RUN.md, "Marketplace shorthand"). The runs must not use the shorthand.

### Run method and install source (PLAT-01, PLAT-02, PLAT-03, PLAT-05)
- **D-01:** Hybrid run method. A small POSIX `sh` smoke script, runnable under Git Bash and
  macOS `sh`, feeds the shipped hook captured Claude Code `Write`/`Edit` and Codex `apply_patch`
  payloads against the real `bbjcpl` on that machine and prints one result block (`key: value`
  lines: compiler path as discovered, the `-P` list as passed, the file path as passed, exit
  code, first feedback line, `-N` present). The client steps (install, trust, the real writes)
  are a numbered runbook the owner follows by hand, with the exact lines to paste back. The
  script reuses the payload builders of `tests/lib.sh` where they fit and never runs BBj.
- **D-02:** Client runs use the real model with minimal prompts: in each client on each
  platform, one Write of a bad `.bbj`, one Edit that keeps it bad, one Write of a clean file (on
  Codex, the matching `apply_patch` calls). The owner's normal accounts; a handful of billed
  turns is accepted as the real user path. No fake model on Windows or macOS.
- **D-03:** Install source is a local clone of `gsd/planning-setup` on each machine:
  `git clone`, check out the branch, then `claude plugin marketplace add <path>` and
  `codex plugin marketplace add <path>` followed by the plugin add commands. The record names
  the checkout commit. Nothing is pushed for the runs. The shorthand `BBj-AI/bbj-agent-plugins`
  is not used (see the scout fact above).
  - D-03 amended 2026-10-13 by the owner (plan 09-04 Task 2): the owner chose `transfer: push`.
    `gsd/planning-setup` is pushed to `origin` before each run round of Phase 9, so the Windows
    machine and the Mac clone or pull `-b gsd/planning-setup` from GitHub. Only that branch is
    pushed: `main` and tags are not touched and no push is forced. The release pushes stay
    Phase 10's, each with its own owner confirmation.
- **D-04:** Windows compiler discovery is exercised through the two sources a user sets: in
  Claude Code the plugin option `bbj_home` set to a drive-letter path (for example `C:\bbx`),
  which the hook converts with `cygpath`; in Codex `bbjcpl` on `PATH` or `BBJ_HOME`, the only
  sources Codex offers. The default home `/c/bbx` and the remaining variables are not run
  separately. PLAT-02's four path facts (compiler path, `;`-joined `-P` list, drive-letter file
  path, project path with a space) come from the smoke script's result block plus one client
  write inside a project directory whose path contains a space.

### Evidence record shape (PLAT-06)
- **D-05:** One record per platform: `09-WINDOWS-RUN.md` and `09-MACOS-RUN.md` in the phase
  directory, in the `08-LINUX-RUN.md` shape: a Run environment table (OS and version, Git for
  Windows version where it applies, Claude Code version, Codex CLI version, BBj version,
  checkout commit, date), then one section per route (Claude Code `bbjcpl`, Codex plugin
  `bbjcpl`, `bbj-local` in each client, tier 2, no-route notice) with the result block, the
  client's feedback lines and a "Sentence for the docs". Phase 10 reads these two files.
- **D-06:** Only result blocks and short excerpts go into the repository: the smoke script's
  result block, the compiler lines, the client's hook feedback text, and the `mcp` and `hooks`
  list lines. No transcripts, logs or an `evidence/` directory; raw outputs stay on the owner's
  machines.
- **D-07:** Placeholders as in Phase 8: `C:\Users\<name>` and `/Users/<name>` become `<home>`,
  the clone path becomes `<checkout>`; the BBj home stays as written (`C:\bbx`,
  `/Applications/bbx` or whatever the machine has) because it is part of what PLAT-02 proves,
  and the space-in-path project keeps its space in the placeholder form. The smoke script
  scrubs its own output; the runbook tells the owner what to replace in pasted lines.
- **D-08:** Each route section ends with a verdict line naming the requirement: `PLAT-01: met`,
  `PLAT-04: not run (reason)`, `PLAT-03: defect, fixed in <commit>, re-run met`, or
  `PLAT-03: known gap (reason)`. `09-VERIFICATION.md` and Phase 10 quote those lines.

### Defect and known-gap policy (PLAT-06)
- **D-09:** A defect found by a run is fixed in the same phase: fix, then a CI gate on fakes,
  then the owner re-runs only the affected route and the record gets a second dated reading
  under the same section. The plan carries one checkpoint per platform for this loop; the
  Linux suite (`sh tests/run.sh`) must be green after each fix before the re-run is asked for.
- **D-10:** What counts as a known gap instead of a fix is the owner's call at the per-platform
  checkpoint. The candidates for a gap: the fix needs a Windows-only behaviour no fake can
  model, the fix would change the hook's exit contract or a static safety gate, or the defect
  sits in the host (Claude Code or Codex) rather than in this repository. The record carries
  the reason in the verdict line.
- **D-11:** If Codex on Windows does not run the plugin hook's `sh "${CLAUDE_PLUGIN_ROOT}/..."`
  command, the first answer is a `commandWindows` entry in `plugins/bbj/hooks/hooks.json` (same
  `sh` invocation, with the quoting Codex on Windows expects; the entry passes
  `claude plugin validate --strict`, spike 005), followed by a re-run. If Codex ignores it
  (`hooks/list` showed `commandWindows: None` on Linux), the fallback is a documented
  `command_windows` step in the user's `config.toml` and a recorded gap. The three spike 005
  unknowns are each answered with a line in the Windows record. — **Reversibility:** costly —
  a `commandWindows` entry changes the hook definition Codex hashes, so every existing Codex
  plugin install asks for trust again after the upgrade; Phase 10 must say so if it ships.
- **D-12:** A Windows-branch fix is pinned by extending `tests/test_discovery.sh` with the
  existing fake `cygpath` (`-u` echoes, `-w` prefixes `W:`): cases for a drive-letter file path,
  a space in the project path, and the `;`-joined `-P` list, as the fix needs. If
  `commandWindows` ships, a `tests/test_layout.py` gate pins the `hooks.json` entry and the D-14
  plugin-route gate of Phase 8 keeps parsing the file. No new fake binaries and no new test
  file unless the planner finds the cases do not fit `test_discovery.sh`.

### bbj-local and tier 2 on Windows (PLAT-04)
- **D-13:** "Connects" is proven by two readings in each client: the server listed as connected
  (Claude Code `/mcp` after enabling the `bbj-local@basis-bbj` plugin; Codex `codex mcp list`
  showing `bbj-local` at `http://127.0.0.1:5009/mcp` after `codex plugin add bbj-local@basis-bbj`)
  and one `bbj_check_syntax` call on a bad snippet returning the syntax error. The opt-in half is
  recorded too: `bbj-local` absent before the enable step in both clients.
- **D-14:** The Windows smoke script also runs the hook's tier-2 route once: `BBJ_HOME` empty,
  `bbjcpl` off `PATH`, `BBJ_CHECK_DEFAULT_HOMES` empty, BBjServices running; expected
  `bbj-local reported N error(s)` for the bad file, silence for the clean one. This proves
  `curl`, `--noproxy '*'` and the loopback URL under Git for Windows without a client run.
- **D-15:** If BBjServices cannot run on the owner's Windows machine, the record says
  `PLAT-04: not run (reason)` and still shows the opt-in half (absent until enabled). Tier 2
  (D-14) is then not run either. Phase 10 keeps a "not run" line for that route. The phase does
  not block and does not move PLAT-04 to macOS.
- **D-16:** The Windows smoke script also runs the no-route case once (every route off): expect
  exit 0, the one JSON notice on stdout, and the claim file created under
  `BBJ_CHECK_STATE_DIR` on a Windows path. This covers the `mkdir` and `set -C` claim logic on
  NTFS. On macOS the same two extra smoke runs (tier 2 with BBjServices if it runs there, and
  no-route) are optional readings, not requirements.

### Claude's Discretion
- The smoke script's name and home (a `09-runs/` or `windows-run/` directory beside the
  records, like `08-codex-plugin-route/linux-run/`), its result-block keys, and how it finds
  the hook (`CLAUDE_PLUGIN_ROOT` pointed at the local clone's `plugins/bbj`, and at the client's
  plugin cache for the installed-copy reading). It is not CI and never runs BBj.
- The runbook's order on each platform (Claude Code first, then Codex, then `bbj-local`), and
  the exact bad and clean `.bbj` contents (reuse the fixtures the Linux tests use).
- How the owner hands readings back (pasted blocks in the checkpoint reply, as in Phase 8).
- Which `tests/test_discovery.sh` cases already cover a given Windows-branch fix, and the gate
  names within the `order_` prefix or a free-form name of that file.
- The side readings: whether the hosted docs server sign-in (`codex mcp login bbj-docs`,
  Claude Code `/mcp` authenticate) completes on each platform with the shipped OAuth block, and
  the Claude Code and Codex versions observed. Recorded if seen; not a requirement.

### Folded Todos
- **Remove pre-production and not-final wording from the plugin's shipped texts**
  (`.planning/todos/pending/2026-10-13-no-pre-production-wording-from-bbjlangmcp.md`), folded
  in part. The installer line `commandWindows in hooks.json is not yet tried on Windows` (around
  `codex/install-codex.sh:1287`) and the "not yet run on Windows or macOS" facts in README,
  `docs/install-codex.md` §Windows and `docs/install-claude-code.md` §Windows are what this
  phase's runs decide. The Windows record states the `commandWindows` outcome for both the
  installer's `hooks.json` (if the owner also tries the installer route) and the plugin route,
  so Phase 10 can replace each line with a tested fact. The pre-production and go-live wording
  about the docs server stays with Phase 10 and the todo.
- **Configure the bbj plugin and the Codex installer for the hosted docs server's OAuth client**
  (`.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md`), folded as a
  side reading only. Phase 8 plan 08-08 and quick task 261013-cpn shipped the OAuth block in
  `plugins/bbj/.mcp.json` and `plugins/bbj/.codex-mcp.json`; this phase records whether the
  sign-in completes on Windows and macOS when the owner tries it. No change to the block is
  planned here.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` §Phase 9 — goal, success criteria 1-5, notes (evidence shape, the
  untouchable contract and gates, out of scope)
- `.planning/REQUIREMENTS.md` — PLAT-01 to PLAT-06; DOCS-01 to DOCS-04 and REL-07 (what Phase
  10 will build from these records); Out of Scope table
- `.planning/PROJECT.md` — Key Decisions table; Constraints
- `.planning/STATE.md` — Blockers/Concerns: the Mac `bbjcpl` prerequisite, the BBjServices on
  Windows condition, the three Windows unknowns of spike 005, the upgrade-trust observation
  limits

### Evidence models (the records of this phase copy their shape)
- `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` — Run environment table, per-route
  sections with result blocks, "Sentence for the docs", placeholders `<home>` and `<checkout>`
- `.planning/phases/08-codex-plugin-route/linux-run/run.sh`, `hooks_list.py`, `owner.sh` — the
  scripted runner and the owner hand-off pattern (not ported; the smoke script is smaller)
- `.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-UAT.md` — tests 5 and 6: the 0.2.0
  macOS readings (tier-2 route only, no `bbjcpl` on that Mac then)

### Spikes (the Windows unknowns and the Codex hook facts)
- `.planning/spikes/005-codex-installer-residue/README.md` — "Unknowns that only a real Windows
  run can settle"; `commandWindows` passes strict validation, `hooks/list` showed
  `commandWindows: None`
- `.planning/spikes/001-codex-plugin-hooks/README.md` — hook trust by content hash; the
  `commandWindows` note; `CLAUDE_PLUGIN_ROOT` expansion
- `.planning/spikes/CONVENTIONS.md` — throwaway-home and never-execute rules for scripted runs

### Prior decisions
- `.planning/phases/08-codex-plugin-route/08-CONTEXT.md` — D-07 (route marker), D-14 (the
  plugin-route CI gate that parses `hooks.json`), D-16 (pinned 0.2.0 wording stays), D-17 and
  D-18 (run conventions, upgrade-trust observation)
- `.planning/phases/07-test-hardening-and-release-prep/07-CONTEXT.md` — D-04 to D-07
  (CONTENT_VERSION policy: Phase 10 re-pins), D-11 to D-13 (PATH scrub helper the smoke
  script's no-route run can reuse)

### Code under test and possibly under change
- `plugins/bbj/scripts/bbj-check.sh` — `WIN` detection (line 638), `check_file` (lines
  456-553: drive-letter conversion, `-P` list joined with `;`, `cygpath -w` for the file),
  `discover` (lines 426-451: `bbj_home` option, `BBJ_HOME`, `PATH`, default homes incl.
  `/c/bbx`), the `cwd` and patch-path conversions (lines 562, 597), the notice claim logic
  (lines 177-190)
- `plugins/bbj/hooks/hooks.json` — the one command string; a `commandWindows` entry is the D-11
  candidate change
- `plugins/bbj/.codex-plugin/plugin.json`, `plugins/bbj/.codex-mcp.json` — what the Codex plugin
  route installs on Windows and macOS
- `codex/install-codex.sh` — lines 310-322 (`commandWindows` rendering with `cygpath -w`),
  line 1287 (the "not yet tried" note), `STATUS_LINE`
- `tests/test_discovery.sh`, `tests/fake-bin/cygpath` — the Windows-branch cases and the fake
  that a fix extends (D-12)
- `tests/lib.sh` — `claude_payload`, `codex_payload`, `run_check`, `no_compiler_path` for the
  smoke script and the gates
- `tests/test_layout.py` — home of a `hooks.json` gate if `commandWindows` ships (D-12)
- `tests/test_codex_patch.sh` — the captured codex-cli 0.162.1 `apply_patch` payload shape

### Docs lines the records will replace (Phase 10 does the edit)
- `docs/install-claude-code.md` §Windows (lines 154-160), `docs/install-codex.md` §Windows
  (lines 366-372), `README.md` lines 45-50, `CHANGELOG.md` lines 93-94

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/lib.sh`: `claude_payload TOOL FILE CWD` and `codex_payload` build the hook inputs the
  smoke script feeds; `run_check` runs the hook and captures exit code, stdout and stderr;
  `no_compiler_path` scrubs `PATH` and the home variables for the no-route and tier-2 runs.
- `tests/fake-bin/cygpath`: the fake for the Windows branch in CI (`-u` echoes, `-w` prefixes
  `W:`); `tests/test_discovery.sh` already has Windows-branch cases to extend.
- `.planning/phases/08-codex-plugin-route/linux-run/`: the result-block idiom (`key: value`),
  the placeholder scrubbing, and `hooks_list.py` (reads Codex `hooks/list` through the app
  server; useful on Windows to read `trustStatus` and the expanded command).
- Bad and clean `.bbj` fixtures used by the Linux tests and the Phase 8 runner.

### Established Patterns
- POSIX `sh` only, no `local`, underscore-prefixed temps, `printf` over `echo`; the smoke
  script must pass ShellCheck if it lives under `tests/` (it is not CI, so it may live beside
  the records instead, like `linux-run/`).
- Gates print `gate <prefix>_<name> ok|FAIL|skip`; `test_discovery.sh` uses `order_` and
  free-form names.
- The hook writes stdout only for the notice JSON and exits 0 or 2; `tests/test_exit_contract.sh`
  enforces it and must stay green after any fix.
- The hosted host may be named only where `tests/test_layout.py` allows; every `curl` call is
  loopback-only with `--noproxy '*'` and `--proto =http`; every compiler call carries `-N`
  (`tests/test_static_guards.sh`, `tests/test_never_execute.sh`).

### Integration Points
- Claude Code finds `sh` through Git Bash on Windows and sets `CLAUDE_PLUGIN_ROOT` to the plugin
  cache path; the hook converts drive-letter paths with `cygpath` when it is on `PATH`.
- Codex expands the plugin hook command to the cache path
  `<codex home>/plugins/cache/basis-bbj/bbj/<version>/scripts/bbj-check.sh` and exports
  `CLAUDE_PLUGIN_ROOT`; on Windows the shape of that path (drive letter versus `/c/...`) is the
  third spike 005 unknown.
- `bbj-local` is `http://127.0.0.1:5009/mcp` in both clients; BBjServices 26.03+ serves it.

</code_context>

<specifics>
## Specific Ideas

- The Windows record answers the three spike 005 unknowns with one line each: whether Codex runs
  `sh "..."` through Git for Windows' `sh`; whether `commandWindows` in a plugin `hooks.json` is
  honoured (only tried if the plain command fails, D-11); what `CLAUDE_PLUGIN_ROOT` holds in the
  hook process on Windows (drive letter or `/c/...`) and whether `sh` accepted it.
- The space-in-path project directory is a real client write, not only a smoke run: for example
  `C:\Users\<name>\bbj test\` with the bad file written there, so the `-P` entry carries the
  space through `cygpath -w` and the compiler still finds the file.
- The 0.2.0 Phase 6 UAT already showed the tier-2 route on the owner's Mac (no `bbjcpl` then);
  this phase's macOS record is about `bbjcpl` (tier 1) for both clients, as PLAT-05 asks.
- Phase 8's upgrade-trust sentence covers Linux only; if the owner upgrades the plugin on
  Windows or macOS during the defect loop (D-09), the re-trust behaviour observed there is
  worth one line in the record for Phase 10.

</specifics>

<deferred>
## Deferred Ideas

- Porting `linux-run/run.sh` (fake Responses server, throwaway homes) to Git Bash and macOS:
  not needed for this phase; a later milestone with a Windows or macOS CI runner could pick it
  up.
- Running the full test suite under Git Bash on Windows: listed as a future requirement in
  REQUIREMENTS.md; the smoke script is deliberately smaller than the suite.

### Reviewed Todos (not folded)
- None: both matched todos were folded in part (see Folded Todos). Their remaining items (the
  pre-production and go-live wording about the docs server) stay pending for Phase 10.

</deferred>

---

*Phase: 09-windows-and-macos-verification*
*Context gathered: 2026-10-13*
