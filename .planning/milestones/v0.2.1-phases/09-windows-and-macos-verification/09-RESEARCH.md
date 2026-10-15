# Phase 9: Windows and macOS verification - Research

**Researched:** 2026-10-13
**Domain:** Platform verification of a POSIX-`sh` hook (Git for Windows, macOS `/bin/sh`), Claude Code and Codex CLI plugin routes, evidence records, CI regression gates on fakes
**Confidence:** MEDIUM (repo facts HIGH; Windows client behaviour rests on docs plus third-party issue reports, and the phase exists to settle it)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Locked before this discussion (roadmap, Phases 7 and 8, spikes)**
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

**Run method and install source (PLAT-01, PLAT-02, PLAT-03, PLAT-05)**
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
- **D-04:** Windows compiler discovery is exercised through the two sources a user sets: in
  Claude Code the plugin option `bbj_home` set to a drive-letter path (for example `C:\bbx`),
  which the hook converts with `cygpath`; in Codex `bbjcpl` on `PATH` or `BBJ_HOME`, the only
  sources Codex offers. The default home `/c/bbx` and the remaining variables are not run
  separately. PLAT-02's four path facts (compiler path, `;`-joined `-P` list, drive-letter file
  path, project path with a space) come from the smoke script's result block plus one client
  write inside a project directory whose path contains a space.

**Evidence record shape (PLAT-06)**
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

**Defect and known-gap policy (PLAT-06)**
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

**bbj-local and tier 2 on Windows (PLAT-04)**
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

### Deferred Ideas (OUT OF SCOPE)
- Porting `linux-run/run.sh` (fake Responses server, throwaway homes) to Git Bash and macOS:
  not needed for this phase; a later milestone with a Windows or macOS CI runner could pick it
  up.
- Running the full test suite under Git Bash on Windows: listed as a future requirement in
  REQUIREMENTS.md; the smoke script is deliberately smaller than the suite.

(Reviewed todos: both matched todos were folded in part: the installer line `commandWindows in
hooks.json is not yet tried on Windows` and the "not yet run" facts are decided by this phase's
runs and replaced by Phase 10; the pre-production wording and the OAuth block stay with Phase 10
and the todos. Phase 9 does NOT edit README, `docs/install-*.md`, CHANGELOG or the installer text.)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PLAT-01 | Windows, Git for Windows, Claude Code: after Write and after Edit a bad `.bbj` gets `bbjcpl` feedback, a clean one silence | Claude Code sends `file_path` with backslashes and runs hooks through Git Bash (Pitfall 1, Q2); smoke `claude` cases plus runbook steps W3-W5 |
| PLAT-02 | `cygpath` branch on real paths: compiler path, `-P` joined with `;`, drive-letter file path, project path with a space | Fake-verified that the current hook passes all four (Q5); CI gates `windows_drive_home`, `windows_drive_file`, `windows_space_p_list`, `windows_forward_slash_file`; real readings from the xtrace capture of the compiler call (Q1) |
| PLAT-03 | Codex plugin route on Windows: hook runs through Git for Windows' `sh` (`commandWindows` or other fix); feedback for bad, nothing for clean | Codex runs hook commands through PowerShell (cmd fallback), not Git Bash (Q3, Risk R1); decision table for D-11; the three spike 005 unknowns each map to one reading |
| PLAT-04 | Windows, BBjServices running: `bbj-local` connects in Claude Code (enabled) and in Codex (`codex plugin add`), opt-in only | Commands and expected `mcp` lines (Q2, Q3); smoke `tier2` case (D-14) |
| PLAT-05 | macOS with BBj: Claude Code hook and Codex plugin-route hook give tier-1 `bbjcpl` feedback | `/bin/sh` is bash 3.2 in POSIX mode, `WIN=0`, default home `/Applications/bbx` (Q4) |
| PLAT-06 | Defects fixed with a CI gate on fakes or recorded as known gaps; every run recorded; Linux suite green | Record shape (Q6), checkpoint shape (Q7), Validation Architecture (Q8), baseline `SUMMARY: ok=904 fail=0 skip=0` |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Source: `/home/coder/repos/bbj-agent-plugins/.claude/CLAUDE.md` (read this session). Treated as locked.

- Stack: POSIX `sh` plus Python 3 stdlib only for scripts and tests; no new runtime dependencies. Python tests run as `python3 -I`.
- BBj code is never executed. The hook never calls the hosted check. Enforced by `tests/test_never_execute.sh` and `tests/test_static_guards.sh`.
- Every compiler call carries `-N`. Every `curl` call carries `--noproxy '*'` and `--proto =http`, follows no redirect, and every URL literal in a shipped script is loopback.
- No `set -e` in shipped scripts. `[ ... ]` never `[[ ... ]]`, `$(...)` never backticks, `printf` over `echo` for data, `command -v` never `which`. No `local`.
- Hook exit contract: exit 0 with empty stdout, or exit 2 with feedback on stderr; the only stdout write is the one-line notice JSON (`tests/test_exit_contract.sh`).
- The static guard scans `plugins/bbj/scripts/*.sh` (comment lines removed) and rejects, among others, the tokens `eval`, `jq`, `python`/`node`, `timeout`, `[[ `, `sed -i`, `readlink -f`, `grep -P` (`tests/test_static_guards.sh:59-70`). A hook fix must not introduce them.
- Test conventions: `. "$(dirname "$0")/lib.sh"` first line; gates print `gate NAME ok|FAIL|skip DETAIL`; a gate-name prefix must be one no existing gate starts with (the `windows_` prefix is already used inside `tests/test_discovery.sh`, so new gates there extend that family).
- Pinned 0.2.0 text stays verbatim in Phase 9 (`tests/test_release_text.py:55` pins the CHANGELOG "Not run" lines; `tests/test_install_pages.sh:193` pins the literal `commandWindows` in the Codex page). Phase 9 edits none of README, docs, CHANGELOG.
- GSD workflow: repo edits go through a GSD command; commits use conventional prefixes with the phase scope (`test(09-01): ...`, `docs(09-02): ...`, `fix(09-03): ...`).

## Summary

The hook already contains a Windows branch (`WIN=1` when `cygpath` is on `PATH`, `plugins/bbj/scripts/bbj-check.sh:637-638`). Nothing in CI has ever fed it a drive-letter path, a backslash path, a space in the project path, or a drive-letter `bbj_home`: the fake `cygpath -u` echoes its argument, so every existing Windows gate (`windows_p_list`, `windows_target`) starts from a Unix-form path. In this session a prototype with a small extension of the fake (`-u` maps a drive-letter path below an env-chosen root) showed that the current hook handles all four PLAT-02 facts correctly (compiler found from `C:\bbx`, backslash file and cwd, a space in the project path, `-P` joined with `;`). So the PLAT-02 CI gates are regression gates that will be green when first written, and the real Windows run decides whether the real `cygpath`, the MSYS argument conversion and the real compiler agree with the fake.

The riskiest unknown is not the hook but how Codex starts it. Community reports against Codex 0.155-0.158 say Codex runs hook commands on Windows through the session shell, PowerShell (`pwsh -NoProfile -Command "<command>"`, `cmd.exe` as fallback), and not through Git Bash. Three consequences follow: (1) `sh` is found only if Git's `bin` or `usr\bin` directory is on the Windows `PATH`, which the common Git for Windows install choice does not do [ASSUMED]; (2) `pwsh -Command "<string>"` converts a final native exit code other than 0 or 1 into 1 (Microsoft documents this), so the hook's feedback exit code 2 may reach Codex as 1 and the model gets no feedback even though `bbjcpl` ran; (3) the installer's `commandWindows` renders `"<sh.exe>" "<script>"`, a quoted program token that PowerShell treats as a string expression and `cmd /c` mangles, so it is a likely defect of the installer route. D-11's `commandWindows` answer therefore has to be chosen from a small decision table (below) after three cheap PowerShell readings, not guessed.

Claude Code on Windows is better documented: hook commands go through Git Bash, `tool_input.file_path` arrives with backslashes (`C:\\project\\src\\index.ts`, `cwd` format not stated), substituted `${CLAUDE_PLUGIN_ROOT}` uses forward slashes, and `claude plugin marketplace add` accepts `C:\` paths. A marketplace added from a local path loads the plugin in place, so on Claude Code `CLAUDE_PLUGIN_ROOT` is `<checkout>\plugins\bbj`, not a cache copy; that matters for what the record may claim.

**Primary recommendation:** Do the work in this order: (1) CI first: extend `tests/fake-bin/cygpath` with a `FAKE_CYGDRIVE_ROOT` seam and add four to five `windows_*` gates to `tests/test_discovery.sh`; (2) write one POSIX `smoke.sh` beside the records that runs the hook under `sh -x` once to capture the exact compiler call, scrubs its own output, and emits payload files for PowerShell probes; (3) one `checkpoint:human-action` per platform with a fixed reply format, then one `checkpoint:decision` per platform for fix-versus-gap; (4) write the two records with the same section skeleton as `08-LINUX-RUN.md`.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Start the hook command (shell choice, PATH lookup of `sh`) | Host client (Claude Code, Codex CLI) | `hooks.json` command strings | The host picks the shell; the repo can only change the command string (`command`, `commandWindows`) |
| Path conversion (drive letter to POSIX and back) | Hook script (`WIN=1` branch, `cygpath`) | Git for Windows runtime | `check_file`, `codex_patch`, `find_cpl_in_home` call `cygpath -u/-w` |
| Compiler call (`bbjcpl -t -N -X -P<list> <file>`) | Hook script | BBj install (native Windows program) | Hook builds the argv; the native launcher finds its own home |
| Verdict hand-back (exit 0 or 2, stderr text) | Hook script | Host (exit-code handling) | PowerShell `-Command` can rewrite exit 2 to 1 (Risk R1) |
| Tier 2 (`curl` to loopback `bbj-ls`) | Hook script | BBjServices | Loopback only, `--noproxy '*'`, `--proto =http` |
| No-route notice claim (`mkdir` + `set -C`) | Hook script | Filesystem (NTFS, APFS) | Atomic create decides once per session |
| Plugin/MCP registration, `bbj-local` opt-in | Host client plugin system | Marketplace manifests | `defaultEnabled: false`; Codex `plugin add` |
| Run evidence (result blocks, verdicts) | Records in the phase directory | Smoke script (scrubbing) | Phase 10 and `09-VERIFICATION.md` read the records |
| Regression gates for Windows branch | CI on fakes (`tests/test_discovery.sh`, `tests/test_layout.py`) | Owner's real run | No Windows runner exists or is wanted |

## Standard Stack

No external package is installed by this phase. The "stack" is what is already in the repo and on the owner's machines.

### Core
| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| POSIX `sh` (Git Bash `sh` = bash in POSIX mode; macOS `/bin/sh` = bash 3.2 in POSIX mode) | n/a | Smoke script and hook | Project constraint; the hook already runs there |
| `tests/lib.sh` helpers | repo | `claude_payload`, `codex_payload`, `run_check`, `no_compiler_path`, `no_compiler_env`, `mkwork`, `fresh_state` | Locked by D-01 (reuse where they fit) |
| `tests/fake-bin/cygpath`, `tests/fake-bin/bbjcpl` | repo | CI Windows branch on Linux | D-12 |
| `cygpath` (Git for Windows) | per install | Real path conversion | The hook's own dependency |
| Python 3 stdlib (`python3 -I`) | repo CI only | `tests/test_layout.py` | Not needed on the owner's machines |

### Supporting
| Component | Purpose | When to Use |
|-----------|---------|-------------|
| `claude plugin marketplace add`, `claude plugin install/enable`, `claude mcp list`, `/mcp` | Claude Code runbook | Windows and macOS runbooks |
| `codex plugin marketplace add`, `codex plugin add`, `codex mcp list`, `/hooks` TUI | Codex runbook | Windows and macOS runbooks |
| `sh -x` with `PS4='+TRACE '` | Capture the exact compiler argv | Smoke script (prototyped, Pattern 2) |
| PowerShell probes (`Get-Command sh`, `pwsh -NoProfile -Command ...`, `$LASTEXITCODE`) | Reproduce Codex's launch path without Codex | Windows runbook step W6 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `sh -x` trace to read the compiler call | A recording shim `bbjcpl` in a temp home | A shim changes which home discovery finds, defeating "compiler path as discovered"; rejected |
| Reading hook state with `hooks_list.py` on Windows | `/hooks` TUI | `hooks_list.py` uses `select.select` on pipes (`.planning/phases/08-codex-plugin-route/linux-run/hooks_list.py`), which does not work on Windows pipes and needs Python; use the TUI (or port with a reader thread, optional) |
| Sourcing `tests/lib.sh` | Copying `json_escape`, `claude_payload`, `codex_payload` into the smoke script | Sourcing keeps one source of truth but clears the machine's BBj variables at source time; read them first (Pattern 2) |

**Installation:** none.

**Version verification:** not applicable (no package). Client versions are read on the owner's machines: `claude --version`, `codex --version`, `git --version`. Repo notes record Claude Code 2.1.296 and codex-cli 0.162.1 as the last tested pair (`08-LINUX-RUN.md`, `06-UAT.md` evidence).

## Package Legitimacy Audit

This phase installs no external package, so the Package Legitimacy Gate does not apply.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| none | n/a | n/a | n/a | n/a | n/a | n/a |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
 owner on Windows / macOS
   |
   | (A) smoke.sh  --------------------------------------------------------------+
   |      builds payloads with tests/lib.sh (claude_payload / codex_payload)     |
   |      paths: cygpath -w  (backslash, as Claude Code sends)  | cygpath -m    |
   |                                                                             v
   |                                   sh bbj-check.sh  (twice: plain = verdict; sh -x = compiler argv)
   |                                          |
   |                       WIN=1 (cygpath on PATH)?  -- no --> POSIX paths (macOS, Linux)
   |                                          | yes
   |                    drive-letter paths: cygpath -u   (file, cwd, CLAUDE_PROJECT_DIR, bbj_home)
   |                                          |
   |                            discover(): option > BBJ_HOME > BBJHOME > PATH > default homes
   |                                          |
   |            found --> bbjcpl -t -N -X -P<w1;w2> <W:\file>  --> stderr lines --> exit 2 / exit 0
   |            not found / no verdict --> tier 2: curl 127.0.0.1:5009 --> exit 2 / 0 / no-route notice
   |                                          v
   |                    result block (key: value), scrubbed: <home> <checkout>, BBj home kept
   |
   | (B) client runbook (real model, D-02)
   |      Claude Code --(Git Bash)--> sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"  --> feedback to model
   |      Codex CLI   --(PowerShell? cmd?)--> sh "<expanded root>/scripts/bbj-check.sh" --> feedback to model
   |                       ^ Risk R1: sh not on PATH; exit 2 rewritten to 1 by pwsh -Command
   v
 paste-back reply (checkpoint) --> 09-WINDOWS-RUN.md / 09-MACOS-RUN.md --> Phase 10 docs
```

### Recommended Project Structure
```
.planning/phases/09-windows-and-macos-verification/
├── 09-WINDOWS-RUN.md          # record (D-05)
├── 09-MACOS-RUN.md            # record (D-05)
└── platform-run/              # beside the records, like 08's linux-run/ (not CI, not shellchecked)
    └── smoke.sh               # one POSIX sh file; subcommands claude | codex | tier2 | noroute | emit DIR
tests/
├── fake-bin/cygpath           # extended: FAKE_CYGDRIVE_ROOT seam for -u (and -d only if an installer fix needs it)
└── test_discovery.sh          # new windows_* gates (D-12)
tests/test_layout.py           # new hook_command_windows gate ONLY if commandWindows ships
```
`tests/ci.sh` runs ShellCheck on `plugins/bbj/scripts/*.sh codex/*.sh tests/*.sh` only (`tests/ci.sh:81-83`), so `platform-run/smoke.sh` is outside ShellCheck and outside every static scan; keep it POSIX anyway (it must run under bash 3.2 in POSIX mode and Git Bash).

### Pattern 1: CI-first Windows gates (extend the fake, not the suite)
**What:** Add a backward-compatible seam to `tests/fake-bin/cygpath` so `-u` can turn a drive-letter argument into a real path under a test directory. Without the env var the fake behaves exactly as today.
**When to use:** Before any client run, so the owner's run is the second line of defence.
**Verified prototype (this session, scratch copy; the hook unchanged):**
```sh
#!/bin/sh
# Fake cygpath for the Windows-branch test: "-u ARG" prints ARG unchanged (a drive-letter ARG maps
# below $FAKE_CYGDRIVE_ROOT when that is set), "-w ARG" prints "W:" followed by ARG.
case "$1" in
  -u)
    case "$2" in
      [A-Za-z]:[\\/]*)
        if [ -n "${FAKE_CYGDRIVE_ROOT:-}" ]; then
          _r=$(printf '%s' "${2#?:}" | tr '\\' '/')
          printf '%s%s\n' "$FAKE_CYGDRIVE_ROOT" "$_r"
          exit 0
        fi
        ;;
    esac
    printf '%s\n' "$2" ;;
  -w) printf 'W:%s\n' "$2" ;;
  *) exit 1 ;;
esac
```
With `PATH=$WORK/winbin:...`, `FAKE_CYGDRIVE_ROOT=$WORK/drive`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME='C:\bbx'` and a copy of the fake compiler at `$WORK/drive/bbx/bin/bbjcpl.exe`, the payload `claude_payload Write 'C:\Users\x\bbj test\sub\f.bbj' 'C:\Users\x\bbj test'` produced exactly this compiler log (one arg per line): `-t`, `-N`, `-X`, `-PW:<root>/drive/Users/x/bbj test/sub;W:<root>/drive/Users/x/bbj test`, `W:<root>/drive/Users/x/bbj test/sub/f.bbj`, and `ARG0 <root>/drive/bbx/bin/bbjcpl.exe` [VERIFIED: prototype run in this session]. The space survives as one argument, the list is `;`-joined, the compiler comes from a drive-letter home and is found as `bbjcpl.exe`.
`tests/test_install_codex.sh` copies the same fake (`:47`) and only asserts `-w` output (`"W:` prefix, `:546`), so the seam is safe there [VERIFIED: grep this session].

### Pattern 2: smoke.sh core (skeleton, tested under dash and `bash --posix` on Linux)
**What:** Source `tests/lib.sh` for the builders, read the machine's real BBj variables first, run the hook plainly for the verdict, run it again under `sh -x` only to read the compiler call, scrub, print `key: value`.
**Why two runs:** `sh -x` writes trace lines to stderr, mixed with the feedback and with multi-line values; the plain run keeps stderr clean. The compiler is compile-only both times (`-N` is in the hook).
```sh
CHECKOUT=$(cd "$(dirname "$0")/../../../.." && pwd)   # platform-run/ -> phase -> phases -> .planning -> repo
KEEP_HOME=${CLAUDE_PLUGIN_OPTION_BBJ_HOME:-${BBJ_HOME:-}}   # lib.sh unsets these, read them first
SCRIPT=${SMOKE_ROOT:-$CHECKOUT/plugins/bbj}/scripts/bbj-check.sh   # lib.sh keeps a preset SCRIPT
. "$CHECKOUT/tests/lib.sh"      # its REPO= line is wrong for this location and is not used
mkwork                          # $WORK, $WORK/state as BBJ_CHECK_STATE_DIR, trap cleanup
WIN=0; if command -v cygpath > /dev/null 2>&1; then WIN=1; fi
w() { if [ "$WIN" = 1 ]; then cygpath -w "$1"; else printf '%s' "$1"; fi; }   # client form
m() { if [ "$WIN" = 1 ]; then cygpath -m "$1"; else printf '%s' "$1"; fi; }   # C:/ form

# Paths go through the environment, never awk -v (awk -v would read \x or \U in C:\Users as escapes).
scrub() {
  S_HOME1=$HOME S_HOME2=$(w "$HOME") S_HOME3=$(m "$HOME") \
  S_CO1=$CHECKOUT S_CO2=$(w "$CHECKOUT") S_CO3=$(m "$CHECKOUT") S_KEEP=$KEEP_HOME \
  awk '
    function rep(s, from, to,    i, out) {
      if (from == "") return s
      out = ""
      while ((i = index(s, from)) > 0) { out = out substr(s, 1, i - 1) to; s = substr(s, i + length(from)) }
      return out s
    }
    { l = $0
      if (ENVIRON["S_KEEP"] != "") l = rep(l, ENVIRON["S_KEEP"], "@@KEEP@@")
      l = rep(l, ENVIRON["S_CO1"], "<checkout>"); l = rep(l, ENVIRON["S_CO2"], "<checkout>"); l = rep(l, ENVIRON["S_CO3"], "<checkout>")
      l = rep(l, ENVIRON["S_HOME1"], "<home>"); l = rep(l, ENVIRON["S_HOME2"], "<home>"); l = rep(l, ENVIRON["S_HOME3"], "<home>")
      if (ENVIRON["S_KEEP"] != "") l = rep(l, "@@KEEP@@", ENVIRON["S_KEEP"])
      print l }'
}
kv() { printf '%s: %s\n' "$1" "$2"; }

# case_run NAME PAYLOAD
case_run() {
  run_check "$2"                                             # RC, $WORK/stdout, $WORK/stderr, $WORK/payload
  _first=$(head -n 1 "$WORK/stderr" | tr -d '\r')
  PS4='+TRACE ' $SHELL_UNDER_TEST -x "$SCRIPT" < "$WORK/payload" > /dev/null 2> "$WORK/trace"
  _call=$(grep -e ' -t -N -X' "$WORK/trace" | tail -n 1 | sed 's/^+*TRACE //')
  case "$_call" in *' -t -N -X'*) _n=yes ;; *) _n=no ;; esac
  { kv case "$1"; kv compiler_call "${_call:-none}"; kv dash_n "$_n"; kv exit "$RC"
    kv stdout_bytes "$(wc -c < "$WORK/stdout" | tr -d ' ')"; kv first_feedback_line "${_first:-none}"; echo
  } | scrub
}
```
Facts behind the choices, all checked this session:
- Under `bash --posix -x` the compiler line is `++TRACE <cpl> -t -N -X '-P<w1>;<w2>' '<W:file>'`, arguments with spaces or backslashes single-quoted; under `dash -x` the arguments print unquoted (ambiguous with a space). Both Git Bash `sh` and macOS `/bin/sh` are bash, so the quoted form is the one the owner sees; the skeleton prints the whole line as `compiler_call:` and does not parse it.
- Derived keys `compiler:`, `p_list:`, `target:` (D-01 wants them) can be cut from that one line with a single-quote-aware awk splitter; if the line has no single quotes, print `raw` and leave them out rather than guess.
- Sourcing `tests/lib.sh` from another directory works only because `SCRIPT` is preset (`tests/lib.sh` keeps `${SCRIPT:-...}`); `REPO` is overwritten with a wrong but unused value; `lib.sh` also unsets `BBJ_HOME`, `BBJHOME`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME`, `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, empties `BBJ_CHECK_DEFAULT_HOMES` and points `BBJ_LOCAL_MCP_URL` at the closed port 9 (`tests/lib.sh:46-53`). The smoke script must therefore set every variable it wants per case after sourcing (and set `BBJ_LOCAL_MCP_URL=http://127.0.0.1:5009/mcp` explicitly for `tier2`).
- The fixtures reuse `tests/test_real_compiler.sh`: bad = `print "a"   rem same line`, clean = `print "a"; rem ok`; the real compiler prints `error at line 10 (1)` for the bad one (`tests/test_real_compiler.sh:17-18,27`).
- A fake compiler line must contain `: error` to count as a compiler-format line (`grep -E ': (type check )?error'`, `bbj-check.sh:532`); otherwise the hook treats the output as "no verdict" and prints the no-route notice (hit while prototyping, relevant only to fakes).

### Pattern 3: Smoke case list (what `smoke.sh` runs)
| Subcommand | Cases | Why |
|------------|-------|-----|
| `claude` | `claude_write_bad`, `claude_edit_bad`, `claude_write_clean` with backslash `file_path` and `cwd` (primary); `claude_write_bad_fwd` with `C:/...`; `root_forms`: run the hooks.json command string via `sh -c` with `CLAUDE_PLUGIN_ROOT` set in backslash form and in forward-slash form | PLAT-01/02; answers "does `sh` accept both root forms" in Git Bash |
| `claude` (space) | the same three with the project under `$WORK/bbj test` | PLAT-02 fact 4 at smoke level (the real client write in `C:\Users\<name>\bbj test\` is separate, D-04) |
| `codex` | `codex_abs_backslash`, `codex_abs_fwd`, `codex_rel_fwd` (`sub/f.bbj`), `codex_rel_backslash` (`sub\f.bbj`), `codex_verbatim` (`\\?\C:\...` cwd and path, informational) | Codex's Windows payload shape is undocumented; Pitfall 2 |
| `tier2` | `BBJ_HOME` empty, `no_compiler_env`, PATH from `no_compiler_path` (see Pitfall 8), `BBJ_LOCAL_MCP_URL=http://127.0.0.1:5009/mcp`, bad and clean | D-14 |
| `noroute` | all routes off, `BBJ_CHECK_STATE_DIR` under `$WORK` (printed with `cygpath -w`), first call then second call; print `notice_text`-style check and `claim_file: present|absent` | D-16 |
| `emit DIR` | write `claude-bad.json`, `codex-bad.json`, `claude-clean.json` payload files (Windows-form paths) to DIR | Input for the PowerShell probes in the runbook |
| every subcommand | header block: `platform` (`uname -sr`), `shell` (`${BASH_VERSION:-unknown}`), `cygpath` (yes/no), `hook_script_cksum` (`cksum` of `$SCRIPT`), `hook_command_matches_hooks_json` (grep -F the escaped command in `hooks/hooks.json`), `script_identical_to_checkout` (cmp with `$CHECKOUT` copy when `SMOKE_ROOT` is a cache path) | Installed-copy reading (Discretion item) |

### Pattern 4: Windows record and runbook order (one checkpoint per platform)
Order inside the Windows checkpoint (D-02 and the Discretion item): W0 readings, W1 clone, W2 smoke `claude`, W3 Claude Code install and three client writes (plus the space-dir write), W4 smoke `codex` and `emit`, W5 PowerShell probes (R1 readings), W6 Codex install, trust, three `apply_patch` writes, W7 `bbj-local` in both clients plus smoke `tier2`, W8 smoke `noroute`, W9 side readings (OAuth sign-in outcome only, never an authorization URL). macOS drops the PowerShell probes and `cygpath` cases.

### Anti-Patterns to Avoid
- **A recording shim compiler:** it changes `discover()`'s result and proves nothing about the real home.
- **`awk -v` with Windows paths:** `C:\Users\x` contains `\U` and `\x` escapes; pass paths through `ENVIRON`.
- **Parsing the xtrace line under dash:** unquoted spaces make it ambiguous; print the raw line.
- **Editing the owner's clone for a probe:** use a scratch copy; Codex trust hashes the hook definition (D-11 reversibility note).
- **Pasting `codex mcp login` output:** it prints an authorization URL with state and challenge; paste only the `Auth` column.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Drive-letter to POSIX and back | A sed/awk path converter | `cygpath -u/-w/-m` (the hook already does) | Mount points, case, UNC and `\\?\` rules differ; the smoke script must use the same tool as the hook |
| Hook payload JSON | Hand-written JSON strings | `claude_payload`, `codex_payload`, `json_escape` of `tests/lib.sh` | They carry the captured key order and escape backslashes correctly (`tests/lib.sh:116-146` (`json_escape` 116, `claude_payload` 123, `codex_payload` 141)) |
| Seeing the compiler argv | A shim or a patched hook | `sh -x` with `PS4` on a second run | Hook stays unmodified; discovery stays real |
| Hiding `bbjcpl` for tier-2 and no-route runs | Editing `PATH` by hand | `no_compiler_path` + `no_compiler_env` (Phase 7 helpers) | Keeps `sh`, `awk`, `curl` reachable while dropping every directory that holds a compiler (`tests/lib.sh:156-222`) |
| Reading Codex hook trust and the expanded command | A new app-server client for Windows | The `/hooks` TUI, pasted by the owner | `hooks_list.py` depends on `select` on pipes and on Python |
| Temp directories | Fixed `/tmp` names | `mkwork` / `mktemp -d "${TMPDIR:-/tmp}/name.XXXXXX"` | Works in Git Bash and BSD `mktemp`; note Pitfall 6 |

**Key insight:** Nearly everything the smoke script needs already exists in `tests/lib.sh` and the hook. The new code is a driver (about 150 lines) and a scrubber; the new CI value is the fake-seam plus four gates.

## Runtime State Inventory

Not a rename, refactor or migration phase. Omitted. (One state note for the planner: the owner's real Claude Code and Codex homes are used on purpose; D-17's throwaway-home rule applies only to scripted steps that would otherwise write there. The smoke script writes only under its own `mkwork` directory.)

## Common Pitfalls

### Pitfall 1 (R1, HIGH impact): Codex on Windows does not start hooks through Git Bash
**What goes wrong:** The plugin command `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"` is expanded by Codex textually (spike 001 saw the expanded command in `hooks/list`) and then handed to the session shell. Reports say that shell is PowerShell: `pwsh -NoProfile -Command "<command>"` (Codex 0.157.1, process-list observation [CITED: github.com/cfaysal/kherep/issues/68]); `get_powershell_shell()` prefers `pwsh`, falls back to Windows PowerShell; `cmd.exe /C` is a fallback [CITED: github.com/openai/codex/issues/47810, /49716]. The official hooks page names no shell [CITED: learn.chatgpt.com/docs/hooks, "The page doesn't say which shell"]. Two separate failures follow:
1. `sh` not found: Git for Windows' installer option "Git from the command line and also from 3rd-party software" is the usual choice and adds `Git\cmd` (git.exe), not the directory holding `sh.exe` [ASSUMED; third-party release notes say a Codex adapter had to locate `sh.exe` through `git.exe` because "Git's `usr\bin` isn't on PATH", newreleases.io/project/github/OthmanAdi/planning-with-files/release/v3.4.1].
2. Exit code rewrite: for `pwsh -Command "<string>"` "If the last command is an external program ... that explicitly sets an exit code other than `0` or `1`, that exit code is converted to `1` for process exit code ... To preserve the specific exit code, add `exit $LASTEXITCODE` to your command string" [CITED: learn.microsoft.com about_Pwsh, -Command]. The hook signals feedback with exit 2. If Codex sees 1, it reports a failed hook and the model gets no `bbjcpl` text, although the compiler ran.
**How to avoid / settle:** three PowerShell readings in the runbook (W5) before any `commandWindows` is written:
- `Get-Command sh -ErrorAction SilentlyContinue` and `where.exe sh` (is `sh` on the PATH of a PowerShell started the way Codex starts it);
- `Get-Content <emit>\claude-bad.json | sh "<root>/scripts/bbj-check.sh"; "direct=$LASTEXITCODE"` (should print 2);
- `pwsh -NoProfile -Command 'sh "<root>/scripts/bbj-check.sh"' < ...; "wrapped=$LASTEXITCODE"` (prints 1 if the rewrite happens), and the same once with `; exit $LASTEXITCODE` appended.
**Warning signs:** Codex shows a failed hook with no feedback text for a bad file; or the hook never ran (compare to the smoke result, which proves the script itself works).

**D-11 decision table (what the planner should encode as the Task after the owner's reply):**

| Reading | Meaning | Action |
|---------|---------|--------|
| Plain command gives feedback for bad, silence for clean | Codex found `sh`, exit code kept | No `commandWindows`; spike 005 unknown 2 recorded as "not tried, not needed" |
| `sh` not found in PowerShell | R1.1 | `commandWindows` with an explicit `sh.exe` path whose program token is unquoted and space-free so it parses in PowerShell and cmd: candidate `C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"` (8.3 short name; hard-codes the default Git location) [ASSUMED; quoting rule from github.com/openai/codex/issues/46454: a quoted program token never launches, leave the token unquoted] |
| `sh` found, wrapped exit 1 versus direct 2 | R1.2 | `commandWindows`: `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE` (PowerShell: `;` separates, exit preserved; in `cmd` the `;` acts as an argument separator so `sh` still runs and returns its own code, extra arguments ignored by the hook) [ASSUMED, to be shown by the re-run] |
| Both | R1.1 and R1.2 | Combine the two candidates in one string |
| Codex ignores `commandWindows` (re-run shows the same failure) | Host limitation | Documented `command_windows` (TOML accepts `command_windows` or `commandWindows` [CITED: learn.chatgpt.com/docs/hooks]) in the user's `config.toml`, verdict `PLAT-03: known gap (...)` per D-11 |
Any shipped `commandWindows` changes the hook hash (re-trust), is read by Claude Code too (strict validation passes per spike 005, but runtime effect on Windows Claude Code is untested), so the re-run must cover Claude Code on Windows as well as Codex.

### Pitfall 2 (R2): Windows path forms the hook silently skips
**What goes wrong:** In a prototype with the extended fake, these Codex payloads produced no compiler call, no stderr and no notice (exit 0, empty stdout): a relative patch path with a backslash (`*** Add File: sub\f.bbj`; the path becomes `<cwd>/sub\f.bbj`, a file that does not exist) and a cwd plus path with the verbatim prefix (`\\?\C:\Users\...`; the `[A-Za-z]:*` case does not match, so `codex_patch` exits 0 at `case "$cwd" in /*)` ). Forward-slash drive paths, backslash absolute paths and relative forward-slash paths worked (one compiler call each) [VERIFIED: prototype run in this session against `plugins/bbj/scripts/bbj-check.sh` lines 562-566, 597-605].
**Why it matters:** What Codex really sends on Windows is undocumented (the Linux capture shows absolute paths, `bbj-check.sh` header). Claude Code's format is documented (backslashes).
**How to avoid:** `smoke.sh codex` prints all five forms so the owner sees which the hook handles before the client run; if the real Codex run is silent for a bad file while smoke is not, the next step is a payload capture (Open Question 3). If a fix is needed: convert backslashes to `/` in `codex_patch` before the `..` and containment checks (converting afterwards would let `sub\..\..\x.bbj` slip past the `*/..|*/../*` rule), strip a leading `\\?\`, gate both on the extended fake.

### Pitfall 3 (R3): The installer's `commandWindows` is a quoted program token
**What goes wrong:** `codex/install-codex.sh:312-316` renders `"<cygpath -w sh>" "<cygpath -w script>"`. A line that starts with a quoted string is an expression in PowerShell (prints the string) and breaks `cmd /c` quote handling [CITED: github.com/openai/codex/issues/46454; github.com/cfaysal/kherep/issues/68 fixed the same shape with a leading `&`]. Only matters if the owner also tries the installer route (CONTEXT folded todo).
**How to avoid:** record the outcome; if it fails, the fix that parses in both shells is an unquoted short program token (`cygpath -d` for `sh.exe`) with only the script path quoted. `tests/test_install_codex.sh:542-546` currently asserts `startswith("\"W:")` and `count("\"") == 4`; such a fix changes that gate and needs `-d` in the fake. The "not yet tried" installer line (`codex/install-codex.sh:1287`) and the docs are Phase 10's.

### Pitfall 4 (R4): Windows compiler file name unverified
`find_cpl_in_home` accepts `bbjcpl`, `bbjcpl.exe`, `bbjcplw.exe`, `bbjcplw` (`bbj-check.sh:393-407`). BASIS documents `bbjcplw` as "the same as the bbjcpl utility, but does not create a console window" and the `-P` separator as "semicolons on Windows environments" [CITED: documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm], but names no file extension or directory. If the install ships `bbjcpl.bat` or `.cmd`, discovery finds nothing. **Reading:** runbook W0 lists `dir C:\bbx\bin\bbjcpl*`; a GUI-subsystem `bbjcplw.exe` may also not return captured stderr (order in `discover` prefers `bbjcpl*` first).

### Pitfall 5 (R5): MSYS argument conversion and the native tools
Git Bash converts "arguments that look like Unix paths" and path lists when it starts a native Windows program; the exclusion variables are `MSYS2_ARG_CONV_EXCL` (a `*` or `;`-separated prefix list) [CITED: msys2.org/docs/filesystem-paths]. The hook passes `-P<drive-letter list with ;>` and a drive-letter file path, which should not look Unix-like [ASSUMED]; tier 2's `curl --url http://127.0.0.1:5009/mcp -H 'Mcp-Method: tools/call'` has slashes inside header text [ASSUMED fine]. The smoke run (compiler, tier 2) decides. If conversion bites, the fix is `MSYS2_ARG_CONV_EXCL='*'` exported in the `WIN=1` branch only; the static guard does not forbid it.
The hook also invokes the compiler by its POSIX path (`"$CPL"` = `/c/bbx/bin/bbjcpl.exe`, `bbj-check.sh:530`) although its header says "the compiler and -P get Windows paths" (`:130-131`); a launcher that derives its BBj home from `argv[0]` instead of the module path would break. Only the real compiler shows it [VERIFIED: code reading; prototype log `ARG0` is the POSIX path].

### Pitfall 6: Git Bash `/tmp` and temp paths
`mktemp -d` returns `/tmp/...` under Git Bash, a Windows temp directory underneath; the hook gets Windows-form paths from `cygpath -w` (fine), but anything the smoke script hands to a native Windows program must be converted too. Scrub temp paths (they contain the user name): the `<home>` rule catches `C:\Users\<name>\AppData\Local\Temp\...`; also scrub `$WORK` to `<work>` for readability.

### Pitfall 7: Local-path marketplace means in-place plugin on Claude Code
A marketplace added from a local path loads relative-path plugins in place: "The plugin's hook processes and MCP and LSP servers receive a `CLAUDE_PLUGIN_ROOT` that points at the source directory" [CITED: code.claude.com/docs/en/plugins/loading, "In-place and copied plugins"]. D-03 makes Claude Code run `<checkout>\plugins\bbj` directly, not a cache copy; the record's sentence for the docs must say "from a local clone". Codex copies into `<codex home>/plugins/cache/basis-bbj/bbj/<version>` (Linux observation, `08-LINUX-RUN.md` "Env probe"); the installed-copy reading therefore exists on Codex only.

### Pitfall 8: `no_compiler_path` uses `ln -s`
The farm builder symlinks every other entry of a compiler directory (`tests/lib.sh:196-203`). Under Git for Windows `ln -s` makes copies unless native symlinks are enabled [ASSUMED]. A BBj `bin` directory is small, so copies are tolerable, but a failure returns 1 with a message and prints nothing; the smoke script must check the return and print `tier2: not run (cannot build PATH farm)` rather than run with an empty PATH. Fallback for the owner: start a shell with `PATH` lacking the BBj `bin` directory.

### Pitfall 9: The checkout commit is not on the remote
`origin/gsd/planning-setup` is at `08a94f8`; the local branch is at `53c4ca3` with later commits (`git rev-parse --short HEAD`, `git log origin/gsd/planning-setup`, this session). The smoke script and any fix are new local commits. D-03 says "nothing is pushed for the runs", but the owner's `git clone` can only see pushed commits. The plan needs an explicit owner step: push the planning branch (not main, no release), or transfer a `git bundle`; every fix-and-re-run round repeats it, and the record names the commit that was actually run.

### Pitfall 10: CRLF and encoding
Native Windows tools may print CRLF; the hook greps `: error` and passes lines on, so `\r` can reach stderr. The skeleton strips `\r` from the first feedback line. The repo forces LF on checkout (`.gitattributes`: `* text=auto eol=lf`), so the shell scripts are safe regardless of `core.autocrlf`. The tracked tree is clone-safe on Windows: no invalid characters, longest path 110, no symlinks, no case collisions (`git ls-files` checks this session).

## Code Examples

### Claude Code payload as Windows sends it (documented)
```
"A `Write` call on Windows delivers: ... "file_path": "C:\\project\\src\\index.ts""
"File-tool `tool_input` paths arrive in the same format as for PreToolUse: always absolute, with the platform's native separators, so backslashes on Windows."
```
[CITED: code.claude.com/docs/en/hooks, PreToolUse/PostToolUse input]. Feed it with `claude_payload Write 'C:\Users\x\bbj test\bad.bbj' 'C:\Users\x\bbj test'` (`json_escape` doubles the backslashes, `tests/lib.sh:116-121`). The `cwd` format on Windows is not stated; the smoke script tries backslash and forward-slash forms.

### The gates to add to `tests/test_discovery.sh` (D-12), shapes only
```sh
# Windows branch with drive-letter input: FAKE_CYGDRIVE_ROOT maps C:\... below $WORK/drive (Pattern 1)
mkdir -p "$WORK/drive/bbx/bin" "$WORK/drive/Users/x/bbj test/sub"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/drive/bbx/bin/bbjcpl.exe"; chmod 755 "$WORK/drive/bbx/bin/bbjcpl.exe"
: > "$WORK/drive/Users/x/bbj test/sub/f.bbj"
FAKE_CYGDRIVE_ROOT=$WORK/drive; export FAKE_CYGDRIVE_ROOT
CLAUDE_PLUGIN_OPTION_BBJ_HOME='C:\bbx'; export CLAUDE_PLUGIN_OPTION_BBJ_HOME
: > "$FAKE_LOG"
run_check "$(claude_payload Write 'C:\Users\x\bbj test\sub\f.bbj' 'C:\Users\x\bbj test')"
# windows_drive_home      ARG0 == $WORK/drive/bbx/bin/bbjcpl.exe
# windows_drive_file      last argument == W:$WORK/drive/Users/x/bbj test/sub/f.bbj
# windows_space_p_list    the -P line == -PW:$WORK/drive/Users/x/bbj test/sub;W:$WORK/drive/Users/x/bbj test  and exactly one -P line
# windows_forward_slash_file  same call with 'C:/Users/x/bbj test/sub/f.bbj'
# windows_codex_drive     codex_payload 'C:\Users\x\bbj test' with 'sub/f.bbj' and with the absolute backslash form: one compiler call each
```
Existing gates for comparison (kept): `windows_p_list`, `windows_target` (`tests/test_discovery.sh:167,171`). Reuse the existing helpers `ran`, `pl`, and the `awk` target extractor from `:162-163`. Expected first-write result: all `ok` (prototype). Run them as `sh tests/test_discovery.sh`; pass signal `gate windows_drive_home ok ...` etc., no `FAIL`.

### `tests/test_layout.py` gate if `commandWindows` ships
```python
HOOK_COMMAND_WINDOWS = '...'   # the exact string chosen from the D-11 table, kept next to HOOK_COMMAND (line 33)
gate("hook_command_windows",
     len(hook_list) == 1 and hook_list[0].get("commandWindows") == HOOK_COMMAND_WINDOWS
     and hook_list[0].get("command") == HOOK_COMMAND,
     "hooks=%r" % (hook_list,))
```
`tests/test_layout.py` parses the file at line 68 (`hooks = load("plugins/bbj/hooks/hooks.json")`) and pins matcher/command/timeout at lines 166-179; the existing `hook_command` gate compares only `command`, so it stays green. The Phase 8 D-14 gate in `tests/test_codex_patch.sh:182` reads only `["hooks"][0]["command"]` and also stays green; an optional `plugin_route_command_windows` gate there can assert the string contains `${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh`. PowerShell cannot be run in CI, so the gate pins text, not behaviour; say so in the gate comment.

### Record result block (house style of `08-LINUX-RUN.md`)
Indented eight spaces, `key: value`, then the client feedback lines, then:
`Sentence for the docs:` followed by one sentence starting `Observed on Windows 11 with Git for Windows <v>, Claude Code <v> and BBj <v>, ...`.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Shell-form hook command | Claude Code docs: "Prefer exec form for any hook that references a path placeholder" | current docs | Exec form needs a real `.exe` on Windows; the shipped command is already double-quoted per the docs rule. Not adopted here; the layout gate pins the string |
| Backslash plugin root in hook commands (issues 21878, 25832 against 2.1.23 and 2.1.42) | "On Windows, the substituted paths use forward slashes so a shell doesn't read backslashes as escapes" | documented now | The shipped command is quoted, so both forms work in Git Bash; the smoke `root_forms` case shows it |
| Installer `commandWindows` with two quoted parts | Unquoted program token or `&` call operator for PowerShell | Codex issue reports 2026 | Pitfall 3 |

**Deprecated/outdated:** nothing in the shipped files; the spike statement that Git Bash runs Codex hooks is the assumption this phase tests.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Codex on Windows starts hook commands through PowerShell (`pwsh -NoProfile -Command`) with `cmd.exe` as fallback; sources disagree and the official page is silent | Pitfall 1 | If Codex used Git Bash the plain command would work and the D-11 table collapses to its first row |
| A2 | With the common Git for Windows PATH option, `sh.exe` is not on the Windows PATH | Pitfall 1 | If it is, R1.1 does not occur; W5 `Get-Command sh` settles it |
| A3 | `pwsh -Command` rewrites the hook's exit 2 to 1 when Codex uses that form | Pitfall 1 | Feedback would work without `; exit $LASTEXITCODE`; W5 wrapped-versus-direct reading settles it |
| A4 | MSYS argument conversion leaves `-P<drive list;...>`, drive-letter paths and the tier-2 `curl` arguments alone | Pitfall 5 | Compiler gets mangled arguments; fix via `MSYS2_ARG_CONV_EXCL` |
| A5 | The Windows BBj compiler is `bin\bbjcpl.exe` or `bbjcplw.exe` | Pitfall 4 | Discovery misses `.bat` or `.cmd`; fix is a name list change gated on fakes |
| A6 | Codex accepts `codex plugin marketplace add C:\path\to\clone` and plugin add on Windows as on Linux | Pattern 4 | Runbook needs the forward-slash or relative form |
| A7 | Codex's Windows `apply_patch` payload uses `C:\...` or `C:/...` absolute paths and a drive-letter `cwd` (not `\\?\`, not relative with backslashes) | Pitfall 2 | Hook silently skips; fix in `codex_patch`, gated on fakes |
| A8 | `/hooks` TUI shows the expanded command line and trust state | Pattern 4 | Needs the optional app-server reader (threads instead of `select`) |
| A9 | 8.3 short names exist on the owner's system volume | D-11 table | Candidate `C:\PROGRA~1\Git\bin\sh.exe` fails; use the real short path from `cmd /c dir /x` |
| A10 | In Git Bash `command -v bbjcpl` returns the path without `.exe` and `[ -f ]`, `[ -x ]` accept it | Pitfall 4 | `find_cpl_on_path` misses a PATH-only compiler (the Codex source D-04 depends on) |
| A11 | macOS BBj puts the launcher at `/Applications/bbx/bin/bbjcpl` and BBjServices serves `bbj-ls` on 5009 | Q4 | Optional macOS tier-2 reading differs; PLAT-05 unaffected if `BBJ_HOME` is set |
| A12 | `claude plugin install bbj@basis-bbj --config bbj_home=C:\bbx` exists on the owner's Claude Code version | Q2 | Fall back to the `/plugin` configure dialog |
| A13 | Compiler output on Windows may carry CRLF | Pitfall 10 | Cosmetic; scrub in the result block |

## Open Questions

1. **How does the owner get the checkout commit onto the machines?**
   - What we know: the branch on GitHub is behind local HEAD (Pitfall 9); D-03 says nothing is pushed.
   - What's unclear: whether "nothing is pushed" forbids pushing the planning branch.
   - Recommendation: the first checkpoint asks the owner to choose "push gsd/planning-setup" or "git bundle"; the planner writes both variants.
2. **Windows compiler file name and whether `bbjcplw.exe` returns stderr when captured** (Pitfall 4). Settled by W0 reading; no research source found.
3. **What payload does Codex send on Windows?** If the real run is silent while smoke is not, a capture is needed. A capture needs a hook that tees stdin, installed on a throwaway Codex home (needs its own login); design it only if needed, as a contingent task.
4. **Does Claude Code at runtime ignore a `commandWindows` key?** Strict validation passes (spike 005); runtime unknown. Covered by re-running Claude Code on Windows after any `commandWindows` change.
5. **`cmd` versus PowerShell for the `; exit $LASTEXITCODE` form** is argued from cmd's argument-separator rules (A3-related); the Windows re-run is the only test.
6. **BBj version source.** No documented command found; record the version the owner reads from the installer or BBjServices admin tooling as free text, `owner-reported`.

## Environment Availability

Research host (Linux): dash, bash, busybox, ShellCheck 0.x and python3 present (`command -v` output and a green `sh tests/run.sh` this session). The Windows and macOS machines are the owner's and could not be probed; the table lists what the runbook must confirm in step W0 / M0.

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Git for Windows (`sh`, `cygpath`, `curl`, `mktemp`, `awk`) | Hook on Windows, smoke script | owner-confirm | owner-confirm | none (native Windows hook is out of scope) |
| BBj with `bbjcpl` (Windows, macOS) | PLAT-01, 02, 03, 05 | owner-confirm | owner-confirm (26.03+ for tier 2) | none; Mac must install BBj first (STATE blocker) |
| BBjServices running (`bbj-ls` on 127.0.0.1:5009) | PLAT-04, tier-2 smoke | owner-confirm | 26.03+ | `PLAT-04: not run (reason)` (D-15) |
| Claude Code, Codex CLI with plugin commands | Client runs | owner-confirm | last tested 2.1.296 and 0.162.1 | none |
| PowerShell (`pwsh` or `powershell`) | W5 probes | present on Windows 11 | owner-confirm | skip probes; Codex run alone then decides |
| `python3` on owner machines | Nothing required | not needed | n/a | n/a (`hooks_list.py` is not used on Windows) |

**Missing dependencies with no fallback:** BBj with `bbjcpl` on the Mac (blocks PLAT-05 only).
**Missing dependencies with fallback:** BBjServices on Windows (record `not run`).

## Validation Architecture

`workflow.nyquist_validation` is `true` in `.planning/config.json`, so this section applies.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Custom POSIX-`sh` and `python3 -I` gate harness (no third-party framework) |
| Config file | none; discovery by glob `tests/test_*.sh` and `tests/test_*.py` in `tests/run.sh` |
| Quick run command | `sh tests/test_discovery.sh` |
| Full suite command | `sh tests/run.sh` (takes more than 2 minutes here; run with a 600 s limit or in the background) |
| Baseline | `SUMMARY: ok=904 fail=0 skip=0` on this host before any Phase 9 change [VERIFIED: run this session] |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PLAT-01 | Hook feedback after Write/Edit, silence for clean (Windows) | human (real Windows) | smoke `claude` + runbook W2-W3 | record only |
| PLAT-02 | compiler path from drive-letter home | unit on fakes | `sh tests/test_discovery.sh` expect `gate windows_drive_home ok` | Wave 0 (new gate) |
| PLAT-02 | drive-letter and backslash file path, `cwd` | unit on fakes | same file, `windows_drive_file`, `windows_forward_slash_file` | Wave 0 |
| PLAT-02 | `-P` joined with `;`, space in path stays one argument | unit on fakes | `windows_p_list` (exists), `windows_space_p_list` | partly exists; new gate Wave 0 |
| PLAT-02 | same four facts on real paths | human | smoke `compiler_call:` line + the space-dir client write | record only |
| PLAT-03 | Codex plugin route on Windows; three spike 005 readings | human | runbook W4-W6; `commandWindows` text pinned by `python3 -I tests/test_layout.py` expect `gate layout_hook_command_windows ok` only if it ships | gate Wave 0 conditional |
| PLAT-03 | Codex Windows payload forms | unit on fakes (if a fix ships) | `sh tests/test_discovery.sh` / `sh tests/test_codex_patch.sh` | conditional |
| PLAT-04 | `bbj-local` opt-in and connected (Windows) | human | runbook W7; tier-2 smoke | record only |
| PLAT-05 | macOS Claude Code and Codex tier 1 | human | runbook M2-M3, smoke on macOS | record only |
| PLAT-06 | Linux suite green after each fix | full suite | `sh tests/run.sh` expect `SUMMARY: ok=<>=904> fail=0 skip=0` | exists |
| PLAT-06 | Exit contract and static safety gates untouched | unit | `sh tests/test_exit_contract.sh`, `sh tests/test_static_guards.sh`, `sh tests/test_never_execute.sh` (all lines `ok`, no `FAIL`) | exists |
| PLAT-06 | Records complete | doc check (not CI) | `grep -c '^PLAT-0[1-6]: ' .planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` is 6; macOS file carries PLAT-05 and PLAT-06 lines | Wave 0 (records) |

### Sampling Rate
- **Per task commit:** `sh tests/test_discovery.sh` (about seconds) plus the one test file the task touched.
- **Per wave merge:** `sh tests/run.sh` with `SUMMARY: ok=N fail=0 skip=0` and N not lower than the baseline.
- **Phase gate:** full suite green and, after any hook, `hooks.json` or installer fix, the three contract tests above, before the owner is asked for the re-run (D-09).
- Human-only (cannot run in CI, listed as such): every client run, trust in `/hooks`, `bbj-local` connection, OAuth side reading, the PowerShell probes, the real-compiler argument handling under Git Bash.

### Wave 0 Gaps
- [ ] `tests/fake-bin/cygpath` - add the `FAKE_CYGDRIVE_ROOT` seam (and `-d` only if an installer fix needs it)
- [ ] `tests/test_discovery.sh` - `windows_drive_home`, `windows_drive_file`, `windows_space_p_list`, `windows_forward_slash_file`, `windows_codex_drive` (names are proposals; keep the `windows_` family)
- [ ] `.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh` - not CI
- [ ] record skeletons `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`
- [ ] No new test file; no new fake binary (D-12)

## Security Domain

`security_enforcement` is enabled (absent or true), ASVS level 1, block on high.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (OAuth sign-in is a side reading only) | host clients own it; never paste authorization URLs |
| V3 Session Management | no | n/a |
| V4 Access Control | yes (what the hook may read) | symlink skip and cwd containment already in `check_file` / `codex_patch`; keep them in any fix |
| V5 Input Validation | yes | payload fields parsed by `jget`; paths reach the compiler as one quoted argument, never evaluated; `case` guards on `*`, `?`, `[` and newline in names |
| V6 Cryptography | no | n/a |
| V12 Files and Resources | yes | path containment; `..` segments skipped; no write outside `BBJ_CHECK_STATE_DIR` |
| V14 Configuration | yes | no secrets in records (`.mcp.json` carries only the public OAuth client id); loopback-only `curl` with `--noproxy '*'` and `--proto =http` |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Path traversal through a converted separator (`sub\..\..\x.bbj`) | Tampering | Convert backslashes before the `..` and containment checks, never after (Pitfall 2) |
| Command injection through a file name (`$(...)`, backticks, `;`) | Elevation of Privilege | Unchanged: names go to the compiler as one quoted argument; `tests/test_exit_contract.sh` hostile names must stay green |
| Hosted check called from the hook | Information Disclosure | Never; `tests/test_static_guards.sh` and `tests/test_never_execute.sh` |
| BBj code executed | Elevation of Privilege | Compile-only `-N` on every call; the smoke script reaches the compiler only through the hook; no direct `bbjcpl` call |
| Username, tokens or OAuth state in committed records | Information Disclosure | Smoke scrubbing (`<home>`, `<checkout>`), pasting only list lines and compiler lines (D-06), never `codex mcp login` URLs |
| Writes into the owner's real Codex or Claude home by scripted steps | Tampering | The smoke script writes only under its `mkwork` directory; client installs are the owner's manual steps (D-17 reading) |
| Hostile loopback URL | Spoofing | `BBJ_LOCAL_MCP_URL` validation in `no_tier1_route` (loopback `http` only) stays untouched |

## Research Question Index (answers, with where to find them)

| # | Question | Answer in |
|---|----------|-----------|
| 1 | Smoke script design | Patterns 2 and 3, Pitfalls 5, 6, 8; Don't Hand-Roll |
| 2 | Claude Code on Windows | Q2 block below |
| 3 | Codex on Windows | Pitfall 1, Q3 block below |
| 4 | macOS | Q4 block below |
| 5 | Regression gates on fakes | Pattern 1, Code Examples, Validation Architecture |
| 6 | Record files | Q6 block below |
| 7 | Owner checkpoints | Q7 block below |
| 8 | Validation Architecture | section above |

### Q2: Claude Code on Windows (cited facts and the commands to use)
- Shell: "The `command` string is passed to a shell: `sh -c` on macOS and Linux, Git Bash on Windows, or PowerShell when Git Bash isn't installed"; `shell` defaults to `bash`, or `powershell` on Windows when Git Bash isn't installed [CITED: code.claude.com/docs/en/hooks]. The docs hold no sentence about `sh` lookup beyond that; Git Bash's own PATH has `sh`.
- Paths: `tool_input.file_path` is absolute with backslashes on Windows, "even when your hook runs under Git Bash where `$PWD` looks like `/c/project`" [CITED: hooks page]. `cwd`: "Current working directory when the hook is invoked", format not stated.
- `CLAUDE_PLUGIN_ROOT`: substituted inline in `command`; also exported to the hook process with `CLAUDE_PLUGIN_DATA`, `CLAUDE_PROJECT_DIR` and `CLAUDE_PLUGIN_OPTION_<KEY>`; "On Windows, the substituted paths use forward slashes" [CITED: code.claude.com/docs/en/plugins/manifest-reference, Environment variables]. The format of the exported variable is not documented; the hook only tests non-empty.
- `bbj_home` reaches the hook as `CLAUDE_PLUGIN_OPTION_BBJ_HOME` (uppercased key) [CITED: same page, "Reference a saved value"]; the repo hook reads exactly that name (`bbj-check.sh:428`, header). Set with `claude plugin install bbj@basis-bbj --config bbj_home=C:\bbx` (`--config <key=value>`, [CITED: plugins/cli-reference]; exact version tag not read, A12) or the `/plugin` configure dialog.
- Local marketplace: `claude plugin marketplace add <path>`; "On Windows, `.\`, `..\`, and `C:\` forms also work" [CITED: plugins/cli-reference]; relative-path plugins load in place (Pitfall 7).
- Enable `bbj-local`: `claude plugin install bbj-local@basis-bbj` then `claude plugin enable bbj-local@basis-bbj`; `claude plugin list` shows `✘ disabled` first [VERIFIED: `.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-04-SUMMARY.md:114`]. Connected reading: `claude mcp list` line `plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected` [VERIFIED: `.../06-release-0-2-0/evidence/claude/plugins.txt:61`, quoted verbatim]. `/mcp` shows the same server in a session. The tool name the model calls is `bbj_check_syntax`.
- Strict validation warns when a placeholder is outside double quotes in shell form (the shipped command is quoted).

### Q3: Codex on Windows
- Hook shell: undocumented officially; PowerShell per issue reports (Pitfall 1). No config option chooses it (`[windows]` has only `sandbox`, [CITED: github.com/openai/codex/issues/49716]).
- `commandWindows`: "an optional Windows-only command override"; "In TOML, use `command_windows` or `commandWindows`"; plugin hooks need trust: "Codex skips plugin-bundled hooks until you review and trust the current hook definition" and "records trust against the hook's current hash"; `PLUGIN_ROOT` and `CLAUDE_PLUGIN_ROOT` are both set [CITED: learn.chatgpt.com/docs/hooks (redirect of developers.openai.com/codex/hooks), also spike 001 README].
- Local marketplace: `codex plugin marketplace add <path-to-marketplace-root>` [CITED via plugin-creator skill mirrors, third-party; Linux use verified in `08-LINUX-RUN.md`]; Windows path form A6.
- `codex mcp list` format: `Name  Url  Bearer Token Env Var  Status  Auth`; `bbj-local` absent until `codex plugin add bbj-local@basis-bbj`, then `http://127.0.0.1:5009/mcp  -  enabled  Unsupported` [VERIFIED: `08-LINUX-RUN.md` "bbj-local opt-in"]. Codex home on Windows: `C:\Users\<name>\.codex` [CITED: learn.chatgpt.com/docs/windows/windows-sandbox example].
- The three spike 005 unknowns, each one reading:

| Spike 005 unknown | The one reading the Windows record takes |
|-------------------|------------------------------------------|
| Does Codex run `sh "..."` through Git for Windows' `sh`? | Result of the plain command: client feedback present (yes) or absent; plus W5 `Get-Command sh` output and the wrapped/direct exit codes; the record line says which shell evidence supports it |
| Is `commandWindows` in a plugin `hooks.json` honoured? | Only tried if the plain command fails: the re-run result after the shipped entry (feedback appears or not); otherwise `not tried (plain command worked)` |
| What does `CLAUDE_PLUGIN_ROOT` expand to, and did `sh` accept it? | The `command=` text from `/hooks` (expanded root: drive letter or `/c/...`, slash style) and the hook running; the Codex no-route notice wording (plugin wording names `codex plugin add bbj-local@basis-bbj`) shows the variable was non-empty in the process |

### Q4: macOS
- `/bin/sh` is a copy of bash 3.2 that enters POSIX mode when invoked as `sh` [CITED: bash manual "invoked as sh enters POSIX mode"; O'Reilly Mac OS X book; Apple's build is a patched 3.2 per a Ghostty commit note]. No bash 4 features: the smoke skeleton uses none (no arrays, `[[`, `${v//}`, `local`). Whether `/bin/sh` can be switched to dash on a given Mac is unverified. The smoke prints `${BASH_VERSION:-unknown}`.
- `cygpath` is absent, so `WIN=0`: no path conversion; the Claude Code payload carries POSIX paths. The 0.2.0 UAT already ran the hook on the owner's Mac (tier 2, no `bbjcpl` then) [VERIFIED: `06-UAT.md` tests 5 and 6].
- Default BBj home: "As of BBj 19.12, the default installation directories are as follows: Windows: C:\bbx, macOS: /Applications/bbx, Other operating systems: /usr/local/bbx" [CITED: documentation.basis.cloud/.../installing_bbj10x_gui.htm]. `discover()` lists `/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx` (`bbj-check.sh:436`), and checks `<home>/bin` then `<home>` for `bbjcpl bbjcpl.exe bbjcplw.exe bbjcplw` (`:393-407`). Launcher location on a Mac: A11.
- Run with `BBJ_HOME` or `PATH` for Codex (no plugin options), plugin option `bbj_home` for Claude Code, the same sources as Windows (D-04).

### Q6: Record skeletons (copy `08-LINUX-RUN.md`: Run environment table first, `## ` per route, result block indented eight spaces, `Sentence for the docs:`)
`09-WINDOWS-RUN.md`: header paragraph (who ran, placeholders `<home>` `<checkout>`, BBj home kept, no transcripts) then
1. `## Run environment` table rows: OS (`ver` or `[Environment]::OSVersion`; Git Bash `uname -sr`), Git for Windows (`git --version`), Git Bash shell (`sh -c 'echo $BASH_VERSION'`), PowerShell version, Claude Code (`claude --version`), Codex CLI (`codex --version`), BBj version (owner-reported), BBj home and compiler file (`dir <home>\bin\bbjcpl*`), BBjServices (running yes/no), checkout commit (`git rev-parse --short HEAD`), install source (local clone; no shorthand), smoke script `cksum`, date.
2. `## Smoke run` with the three or four result blocks (header block, claude cases, codex cases) and the PLAT-02 four facts read off `compiler_call:` (compiler path, `-P` list `;`-joined, drive-letter file, space).
3. `## Claude Code bbjcpl route` (steps taken, Write bad, Edit bad, Write clean, space-dir write, feedback lines, Sentence for the docs, `PLAT-01: ...`, `PLAT-02: ...`).
4. `## Codex plugin bbjcpl route` (install lines, `/hooks` trust and `command=` line, W5 PowerShell readings, three spike 005 lines, feedback, Sentence, `PLAT-03: ...`).
5. `## bbj-local in Claude Code`, `## bbj-local in Codex` (absent before, listed/connected after, `bbj_check_syntax` result; `PLAT-04: ...`).
6. `## Tier 2 smoke` (D-14), `## No-route notice smoke` (D-16).
7. `## Installer route (optional)` (the `commandWindows` outcome for `install-codex.sh`, folded todo).
8. `## Side readings` (versions, OAuth sign-in outcome as `Auth` column only).
9. `## Defects and re-runs` (each: what failed, fix commit, new gate, second dated reading under the original section).
10. `## Verdicts` (six lines `PLAT-0N: met | not run (reason) | defect, fixed in <commit>, re-run met | known gap (reason)`; `PLAT-06` summarises defects and Linux suite result).
`09-MACOS-RUN.md`: the same skeleton without PowerShell probes, `cygpath` cases, Windows install source specifics; routes: Claude Code tier 1, Codex plugin tier 1 (`PLAT-05`), optional tier-2 and no-route readings, `PLAT-06` line for the Mac.
Shape note: Phase 8 headings used `## Plugin route: hook after apply_patch` style; keep the route name in each heading so `09-VERIFICATION.md` can quote by heading.

### Q7: Owner checkpoint shape (from Phase 8)
Phase 8 used `<task type="checkpoint:human-action" gate="blocking-human">` for hands-on runs (08-05 Task 3: `<action>`, `<instructions>` numbered steps, `<verification>` listing what Claude reads after the reply, `<resume-signal>` giving the exact reply grammar, `<acceptance_criteria>` as greps on the record) and `<task type="checkpoint:decision" gate="blocking-human">` with `<decision>`, `<context>`, `<options>` (each with `<pros>` and `<cons>` stating the consequence) and `<resume-signal>` for choices (08-05-PLAN.md:378-420, 08-08-PLAN.md:168-230). Phase 9 per platform:
- Task A `checkpoint:human-action` "Run the Windows pass" (instructions W0-W9 above; `<resume-signal>`: `claude: write-bad=feedback|silent; edit-bad=...; clean=silent|feedback; space-dir=...; codex: trusted=yes|no; ps-sh=found|missing; direct-exit=N; wrapped-exit=N; bad=feedback|failed|silent; clean=silent|...; local: claude-before=absent|present; claude-after=connected|failed; codex-before=...; codex-after=...; check-syntax=<error text>|none; tier2=ok|n/a; noroute=ok|n/a` plus "paste the smoke result blocks and the `/hooks` command line"). Include the explicit text "replace `C:\Users\<name>` with `<home>` and the clone path with `<checkout>` in anything you paste".
- Task B `checkpoint:decision` "Defects found": lists the defects Claude derived from the reply with the evidence, options `fix` (consequence: fix, new gate, `sh tests/run.sh` green, owner re-runs route X, second reading) or `gap` (consequence: verdict line `known gap (reason)`, no code change); the owner's call per D-10; `blocking-human`, no `auto_select`. Skipped (recorded `no defects`) when the reply shows none.
- Task C `checkpoint:human-action` "Re-run route X" only if Task B chose `fix`.
- macOS: Tasks A (M0-M3) and B only; `<resume-signal>` has `claude:` and `codex:` parts and the optional `tier2:` and `noroute:` readings.

## Sources

### Primary (HIGH confidence)
- Repository files read this session: `plugins/bbj/scripts/bbj-check.sh` (header, `discover`, `check_file`, `codex_patch`, `main`), `plugins/bbj/hooks/hooks.json`, `tests/lib.sh`, `tests/test_discovery.sh`, `tests/fake-bin/cygpath`, `tests/fake-bin/bbjcpl`, `tests/test_layout.py` (lines 1-75, 155-200), `tests/test_codex_patch.sh` (160-215), `tests/test_install_codex.sh` (525-555), `tests/ci.sh`, `tests/test_static_guards.sh`, `codex/install-codex.sh` (300-330, 1275-1295), `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md`, `linux-run/hooks_list.py`, `linux-run/run.sh` (envprobe), 08-05 and 08-08 PLAN checkpoints, spikes 001 and 005, `06-UAT.md` and its evidence.
- Prototype runs (scratch copy, not committed): extended fake `cygpath` with the unchanged hook; `bash --posix -x` and `dash -x` traces; smoke skeleton under dash and `bash --posix`; `sh tests/run.sh` baseline.
- https://code.claude.com/docs/en/hooks (shell, Windows path format, PostToolUse input, env variables)
- https://code.claude.com/docs/en/plugins/manifest-reference (CLAUDE_PLUGIN_ROOT forward slashes on Windows, CLAUDE_PLUGIN_OPTION_<KEY>, quoting)
- https://code.claude.com/docs/en/plugins/cli-reference (marketplace add forms incl. `C:\`, install `--config`, enable/disable)
- https://code.claude.com/docs/en/plugins/loading (in-place loading for local-path marketplaces)
- https://learn.chatgpt.com/docs/hooks (formerly developers.openai.com/codex/hooks): `commandWindows`, `command_windows`, plugin hook trust, `PLUGIN_ROOT`
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pwsh (exit code conversion for `-Command`)
- https://www.msys2.org/docs/filesystem-paths/ (argument and environment conversion, `MSYS2_ARG_CONV_EXCL`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm (syntax, `-P` separator, `bbjcplw`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/sysadmin/install/bbj/installing_bbj10x_gui.htm (default install directories)

### Secondary (MEDIUM confidence)
- https://github.com/openai/codex/issues/46454, /47810, /49716 (Codex Windows hook launch: cmd versus PowerShell, quoted program token, no shell option); https://github.com/cfaysal/kherep/issues/68 (`pwsh.exe -NoProfile -Command` observation, `&` fix); https://github.com/max-sixty/worktrunk/pull/4241 (session shell, not tested on an installed Codex)
- https://claudeissues.com/issue/25832-... and /21878-... (Claude Code Windows backslash plugin root, versions 2.1.23 and 2.1.42, closed)

### Tertiary (LOW confidence, marked [ASSUMED] where used)
- https://newreleases.io/project/github/OthmanAdi/planning-with-files/release/v3.4.1 (Git `usr\bin` not on PATH; Codex runs hook strings through the native interpreter)
- Bash manual and O'Reilly mirror for `/bin/sh` on macOS; plugin-creator mirrors for `codex plugin marketplace add`

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH, nothing new; every helper read in this session
- Architecture / smoke design: HIGH for the xtrace capture, scrubbing and fake seam (prototyped); MEDIUM for Git Bash behaviours (A4, A10)
- Pitfalls: MEDIUM, R1 to R3 rest on third-party reports of Codex 0.155-0.158 and a Microsoft doc, and the Windows run is what settles them

**Research date:** 2026-10-13
**Valid until:** 2026-10-20 for the Codex Windows hook-shell findings (fast-moving, issues were opened in September 2026); 30 days for the repo and Claude Code facts
