# Phase 8: Codex plugin route - Research

**Researched:** 2026-10-13
**Domain:** Codex CLI native plugin distribution of an existing Claude Code plugin (manifest overlay, plugin hook, installer removal path, POSIX sh / Python 3 stdlib test gates, docs)
**Confidence:** MEDIUM overall. HIGH for every in-repo structure and gate (all files read this session). MEDIUM for Codex behaviour (spike evidence plus official docs). LOW for three items no session has exercised: sign-in on the plugin route, the exported `CLAUDE_PLUGIN_ROOT` in the hook process, and the upgrade-trust outcome. Those three are the first things the Linux run must settle.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Locked before this discussion (spikes 001-005, roadmap, Phase 7)**
- Overlay variant A of spike 002: `.codex-plugin/plugin.json` beside `.claude-plugin/`, pointing
  at a literal-URL MCP file. A root `mcp.json` does not override `.mcp.json`.
- The plugin route ships no tool approvals; every tool prompts on first use. The installer's
  `tools/list` probe has no plugin counterpart; docs and the notice replace it.
- `install-codex.sh` stays one release as the fallback route. Removing it is a later decision.
- Real Codex checks run in throwaway homes under `~/.cache` or similar, never the real
  `~/.codex` and not under `/tmp` (Codex refuses its helper binaries there). Billed real-model
  runs only with the owner's approval for each run.
- Phase 7 D-08: the `home_snapshot` allowlist in `tests/lib.sh` gets the plugin-route paths
  added in this phase.

**Switching from the installer (CODEX-06)**
- **D-01:** The switch is an installer option (name is the planner's; `--remove` is the working
  name) that undoes exactly what `install-codex.sh` wrote and nothing else. After it, the user
  runs the two `codex plugin` commands by hand; the installer does not call `codex plugin`.
  Reversibility: reversible - a rerun of the installer without the option puts everything back.
- **D-02:** The `[mcp_servers.bbj-docs]` table and its five `tools.*` tables are removed when
  they are in the forms the installer writes (step 1 of the installer header). The result is one
  `bbj-docs` server, the plugin's. The docs name the plugin-scoped key
  `plugins."bbj@basis-bbj".mcp_servers.bbj-docs` (from the Codex build page, not observed in
  the spikes) for a user who wants the docs-tool pre-approvals back, as a documented option, not
  something the installer writes.
- **D-03:** The managed `bbj-local` block between its markers is removed. A hand-written
  `bbj-local` form is left and reported (exit 3), as today. Skill directories under the skills
  directory are removed only when byte-identical to the shipped copies; a differing directory
  is left and reported (exit 3). `<codex home>/bbj/` (the copied check script) is removed.
- **D-04:** `hooks.json` is deleted only when byte-identical to the block the installer writes;
  otherwise it is left, the entry to remove is printed, exit 3. `config.toml.bbj-backup` is left
  (it is the user's backup). Codex's own `hooks.state.*` trust entries in `config.toml` are left;
  the docs say a stale trust entry is harmless.
- **D-05:** Proof: a test in `tests/test_install_codex.sh` (prefix `installer_`/`existing_` as
  fits) installs with the fake `codex` into a throwaway home, runs the removal, and asserts with
  `home_snapshot`/`home_diff` that the home is back to its pre-install state; plus the foreign
  forms (exit 3, nothing touched). One real Linux run in a throwaway Codex home: installer
  install, removal, then the two plugin commands; recorded in the phase.
- **D-06:** A double install (installer and plugin at once) is handled by the docs only: the
  switch section says what it looks like (two checks, two feedbacks) and points at the removal
  option. The hook does not look for a sibling hook.

**No-route notice on Codex (CODEX-03)**
- **D-07:** Route detection in `bbj-check.sh`: `tool_name` `apply_patch` with `CLAUDE_PLUGIN_ROOT`
  non-empty is the plugin route (Codex sets it to the cache path
  `.../plugins/cache/basis-bbj/bbj/<version>`); `apply_patch` with it unset is the installer route
  (its `hooks.json` runs `sh "<codex home>/bbj/bbj-check.sh"` and sets no variable). No new
  marker; the installer's `hooks.json` block stays byte-identical.
- **D-08:** One command per route. Plugin route: the enable step names
  `codex plugin add bbj-local@basis-bbj`. Installer route: the current text
  (`rerun install-codex.sh --with-local`) stays. The `BBJ_HOME` / `bbjcpl` on `PATH` advice stays
  on both. The Claude Code wording (`enable the bbj-local@basis-bbj plugin`) is unchanged.
- **D-09:** `tests/test_noroute_notice.sh` gains gates (prefix `notice_`) for `apply_patch` with
  and without `CLAUDE_PLUGIN_ROOT`, next to the existing Claude Code gate, each asserting the
  exact command string inside `additionalContext`. Three variants, three gates.

**Codex manifest files and gates (CODEX-01, CODEX-04)**
- **D-10:** `plugins/bbj/.codex-plugin/plugin.json` mirrors `plugins/bbj/.claude-plugin/plugin.json`:
  `name`, `version`, `description`, `author`, `homepage`, `license`, `keywords` identical,
  `userConfig` omitted, plus `"mcpServers": "./.codex-mcp.json"`. A gate keeps the shared fields
  identical.
- **D-11:** The literal-URL file is `plugins/bbj/.codex-mcp.json` (the layout spike 002
  validated: Codex copies it into its cache, Claude ignores it). `bbj-local` gets no overlay; its
  `.mcp.json` has no `userConfig` and spike 003 showed it works as is.
- **D-12:** The marketplace stays the single `.claude-plugin/marketplace.json`, which Codex reads
  as the legacy-compatible path. No `.agents/plugins/marketplace.json`.
- **D-13:** The gates extend `tests/test_layout.py` (prefix `layout_`): the overlay joins the
  version set (both plugins, both marketplace entries, the overlay: one version);
  `.codex-mcp.json` joins the files allowed to name the hosted host (today only
  `plugins/bbj/.claude-plugin/plugin.json`); a new gate requires the URL in `.codex-mcp.json` to
  equal the `docs_url` default. No new test file.
- **D-14:** The CODEX-02 CI gate runs the hook through the exact command string of
  `plugins/bbj/hooks/hooks.json` (parsed from the file, so a change to it is caught) with
  `CLAUDE_PLUGIN_ROOT` set to a fake cache path `.../plugins/cache/basis-bbj/bbj/<version>/` holding
  a copy of the plugin, and the captured `apply_patch` payload: a bad file gives exit 2 with
  `bbjcpl` feedback, a clean file exit 0 with empty stdout. Fakes only, no Codex.

**Docs layout and the Linux proof (CODEX-05)**
- **D-15:** `docs/install-codex.md` stays one page. The plugin route comes first: the two install
  commands, the `/hooks` trust step, first-use tool prompts, the `BBJ_HOME` note, the
  `bbj-local` opt-in command, the upgrade-trust observation, and the switch section (D-01 to
  D-06). The installer keeps a shortened "Fallback: the installer script" section with its
  options table and exit codes.
- **D-16:** The pinned 0.2.0 lines stay verbatim: the "Tested on Linux only" banner, the
  "not yet been run on Windows or macOS" lines, the installer's `STATUS_LINE`, and the quoted
  strings in `tests/test_release_text.py` and `tests/test_install_pages.sh`. Phase 7 D-06 holds.
  The plugin-route section carries its own line saying it was verified on Linux with the Codex
  version and date of this phase's run. Phase 10 rewrites and re-pins all platform wording once.
- **D-17:** The Linux runs reuse spike 001's fake Responses server and `run.sh` pattern
  (`.planning/spikes/001-codex-plugin-hooks/`) in a throwaway home: marketplace add from the
  local checkout, `codex plugin add bbj@basis-bbj`, `--dangerously-bypass-hook-trust` for the
  scripted runs, a bad and a clean `.bbj` through `apply_patch`, and a no-route run for the
  notice text. One manual pass trusts the hook for real in the `/hooks` TUI, recorded by the
  owner. No billed runs. The spike scripts are not CI.
- **D-18:** Upgrade-trust observation: install 0.2.0 from the checkout and trust the hook in
  `/hooks`; point the marketplace at a scratch copy of the checkout with the version set to a
  test value (for example `0.2.0-test`) in every manifest; upgrade; record whether `/hooks`
  lists the hook as untrusted again. The result goes into the docs as observed on Linux. No
  version in the repository changes.

### Claude's Discretion
- The name of the removal option and its output lines; keep the installer's exit-code contract
  (0 done, 2 refusal before any write, 3 something left by hand) and document the option in
  the script header and the docs options table.
- The exact `home_snapshot` paths for the plugin route (D-08 of Phase 7): the Codex plugin cache
  and `[marketplaces]`/`[plugins]` tables are Codex-written, not installer-written, so the
  planner decides whether they belong in the installer-home allowlist or only in the
  throwaway-home checks.
- How the no-route notice text is assembled in `bbj-check.sh` (D-07, D-08) within the one
  stdout JSON object; the hook's exit contract and its never-execute rule are unchanged.
- Gate names, within the per-file prefix convention; which `test_install_codex.sh` prefix the
  removal cases take.
- How the real Linux runs are recorded (a `08-LINUX-RUN.md` or the SUMMARY) with Codex version,
  date, route and outcome, as PLAT-06 asks for the Phase 9 runs.

### Deferred Ideas (OUT OF SCOPE)
- Writing docs-tool pre-approvals for the plugin route (`plugins."bbj@basis-bbj".mcp_servers.
  bbj-docs`) from the installer or a helper: documented as a manual option only (D-02). Revisit
  if users ask.
- A Codex-native `.agents/plugins/marketplace.json`: only if Codex drops the legacy path (D-12).
- Editing a merged `hooks.json` in place during removal: out; the installer never edits JSON it
  did not write (D-04).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CODEX-01 | `codex plugin marketplace add` + `codex plugin add bbj@basis-bbj`; `bbj-docs` at a literal URL via `.codex-plugin/plugin.json` overlay; both skills load; Claude `userConfig` and `claude plugin validate --strict` unchanged | Overlay layout proven in spike 002; exact file contents in "Code Examples"; the OAuth gap in `.codex-mcp.json` is the main open risk (Open Question 1) |
| CODEX-02 | Unchanged `hooks/hooks.json` checks every BBj file an `apply_patch` writes after `/hooks` trust; CI gate on fakes with a plugin-route payload | D-14 recipe built from `test_claude_plugin.sh` section 4 and `codex_payload`/`run_check`; fake cache path layout below |
| CODEX-03 | `bbj-local` opt-in via `codex plugin add bbj-local@basis-bbj`; notice names the command that fits the route | `_how` case in `bbj-check.sh:216-219`; route detection on `CLAUDE_PLUGIN_ROOT`; three `notice_` gates; env-export caveat (Pitfall 2) |
| CODEX-04 | Gates: docs URL identical in `docs_url` default and `.codex-mcp.json`; one version across 5 manifests; hosted-host rule correct for the new file | `tests/test_layout.py` structure documented; exact edits listed |
| CODEX-05 | `docs/install-codex.md` leads with the plugin route; installer documented as fallback | Pinned strings and forbidden patterns the rewrite must respect; docs outline |
| CODEX-06 | Installer user switches to the plugin route with exactly one hook, one copy of skills, one `bbj-docs` server; verified once on Linux | Installer write-set inventory, removal algorithm, edge cases (OAuth table, pre-0.2.0 skills, custom `--docs-url`), test matrix |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Source: `<home>/repos/bbj-agent-plugins/.claude/CLAUDE.md` (project) and `~/.claude-shared/dot-claude/CLAUDE.md` (global; contains only a self-test fact, nothing that constrains this phase).

- POSIX `sh` plus Python 3 stdlib only for scripts and tests; no new runtime dependencies.
- BBj code is never executed; `tests/test_never_execute.sh` enforces it. Every compiler call carries `-N`.
- The hook never calls the hosted check; every URL literal in a shipped script is loopback; every `curl` carries `--noproxy '*'` and `--proto =http` and no redirect flag.
- The hook exits only 0 or 2 and writes stdout only for the one no-route notice (`tests/test_exit_contract.sh`, `tests/test_static_guards.sh` single-writer gate).
- `bbj-local` stays opt-in in both Claude Code and Codex.
- Skill names and plugin names unchanged. Versions identical across both plugin manifests and both marketplace entries (and now the overlay).
- Shell style: `#!/bin/sh`, `[ ]` not `[[ ]]`, `$(...)`, `printf` for user data, no `local`, no `set -e` in shipped scripts, `command -v` not `which`, underscore-prefixed temporaries, redirections written `> /dev/null` with a space.
- Installers: exit 0 done, 2 usage/refusal (nothing written), 3 something left by hand; validate every option and destination before the first write; one-time backup before changing a user file; never overwrite a file the user owns.
- Test gates print `gate NAME ok|FAIL|skip DETAIL`; a new gate name must not start with a prefix an existing gate already uses; the gate-prefix block in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` is kept byte-identical by hand (Phase 7 plans 07-05 and 07-06).
- Strings a static scan would match against itself are assembled from pieces.
- Commit prefixes: `feat(08-NN):`, `test(08-NN):`, `docs(08-NN):`. GSD workflow enforcement: file changes go through a GSD command.

## Summary

The plugin route is mostly assembly of validated parts. Spikes 001 to 005 proved on Codex CLI 0.162.1 that the plugin's unchanged `hooks/hooks.json` fires after `apply_patch` once trusted, that a `.codex-plugin/plugin.json` overlay with `"mcpServers": "./.codex-mcp.json"` gives `bbj-docs` a literal URL while Claude Code ignores both new files, and that `bbj-local` works unchanged and stays opt-in. Phase 8 therefore adds two small JSON files, one `case` branch in the hook, an installer removal option, gates in four existing test files, and a docs rewrite, then proves it once on Linux in throwaway homes.

Three things changed or were not seen since the spikes and the CONTEXT.md decisions were written, and the planner must handle them. (1) The quick task 261013-cpn (2026-10-13, after the spikes) added an OAuth client to `plugins/bbj/.mcp.json` and made the installer write `[mcp_servers.bbj-docs.oauth]`. The CONTEXT.md removal decision (D-02) lists only the table and the five `tools.*` tables, so it would leave the installer's OAuth table behind; and the spike-002 literal file has no OAuth block, so a plugin-route user of the hosted (sign-in required) docs server has no pre-registered client. Codex's own MCP page says a plugin-bundled HTTP server can carry `oauth.clientId`, `callbackUrl`, `callbackPort` in its MCP JSON, and the 0.162.1 binary contains those keys, but no session has exercised it. (2) The route detection of D-07 depends on Codex exporting `CLAUDE_PLUGIN_ROOT` into the hook process; the hooks page says it does, spike 001 only saw it expanded in the command string. (3) The common "installed with the installer" user may hold a skills directory that differs from the shipped copy (pre-0.2.0 installs), which makes D-03's byte-identical rule leave a second copy of the skills and exit 3.

**Primary recommendation:** Implement D-01 to D-18 as written, with these additions: the removal option also removes the installer's `[mcp_servers.bbj-docs.oauth]` table when it is exactly the installer's form; `.codex-mcp.json` carries the same pre-registered OAuth client as `.mcp.json` (camelCase keys) behind a layout gate, subject to the Linux check and an owner decision; `--remove --force` deletes differing skill directories (same meaning `--force` has today); the first real-Codex step of the Linux run is a scratch-copy environment probe that proves `CLAUDE_PLUGIN_ROOT` reaches the hook process; the docs finish only after the run has produced the observed facts (sign-in, env var, upgrade trust).

## Architectural Responsibility Map

This is not a web application. The tiers below are the components of this repository and its hosts.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Plugin discovery, install, cache path, `CLAUDE_PLUGIN_ROOT` export | Codex host (plugin loader) | - | Codex reads `.claude-plugin/marketplace.json`, copies the plugin into `plugins/cache/<marketplace>/<plugin>/<version>/`; the repo cannot change this |
| Literal docs URL and OAuth client for Codex | `plugins/bbj/.codex-mcp.json` named by `.codex-plugin/plugin.json` | Layout gates | Codex does not substitute `${user_config.docs_url}`; the file must hold literals |
| Claude `docs_url` option | `plugins/bbj/.claude-plugin/plugin.json` + `.mcp.json` | - | Unchanged; the single source of the default URL |
| Compile check after `apply_patch` | `plugins/bbj/scripts/bbj-check.sh` via unchanged `hooks/hooks.json` | Codex `/hooks` trust | Same script and command string on all routes |
| Route-specific notice wording | `bbj-check.sh` `notice()` | `tests/test_noroute_notice.sh` | Only the hook sees tool name and environment |
| Undo of the installer | `codex/install-codex.sh` (new option) | `tests/test_install_codex.sh`, `tests/lib.sh` snapshots | The installer owns the knowledge of what it wrote |
| Consistency of URL, OAuth client, version, hosted-host rule | `tests/test_layout.py` | `tests/test_install_codex.sh` `default_url_equals_plugin` | Existing single place for manifest pins |
| User-facing steps and observed facts | `docs/install-codex.md`, `README.md` | `tests/test_install_pages.sh`, `tests/test_release_text.py` pins | Docs are test-pinned; observed Linux facts come from the run record |
| Real-Codex proof | Human/owner-approved Linux run in a throwaway home | Spike 001 scripts (not CI) | CI has no Codex |

## Standard Stack

No external package is installed in this phase. Everything is files in this repository and tools already present.

### Core
| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| POSIX `sh` + `awk`/`sed`/`grep`/`cmp`/`diff`/`mktemp` | system (dash, bash 5.3.9, mawk 1.3.4 on this host) | Hook, installer, shell tests | Project constraint; every existing test runs under `sh` |
| Python 3 stdlib, run as `python3 -I` | 3.14.4 here; `tomllib` available | JSON reads in `tests/test_layout.py`, `tomllib` summaries in installer tests, the fake Responses server | Project constraint |
| Codex CLI | 0.162.1 installed globally (npm `@openai/codex`), the version named in the installer `STATUS_LINE` and the docs | Real-Codex Linux run only (never CI) | The only tested Codex version; `release_codex_version_single` requires one version string across installer and page |
| Claude Code CLI | 2.1.296 installed | `claude plugin validate --strict` after adding the overlay | CI runs it through `tests/ci.sh` |
| ShellCheck | present | `tests/ci.sh` lints `codex/*.sh`, `plugins/bbj/scripts/*.sh`, `tests/*.sh` with `-s sh` | CI gate `ci_shellcheck` |

### Supporting
| Component | Purpose | When to Use |
|-----------|---------|-------------|
| `tests/fake-bin/bbjcpl`, `tests/fake-bin/codex` | Fake compiler (logs argv to `$FAKE_LOG`, prints `$FAKE_OUT` on stderr) and fake codex (`mcp add NAME --url URL` appends `[mcp_servers.NAME]` + `url`, honours `FAKE_CODEX_EXIT`) | D-14 gate, D-05 removal tests |
| `.planning/spikes/001-codex-plugin-hooks/fake_responses.py` + `run.sh` | Scripted real-Codex run against a loopback fake model (model slug `gpt-5.5`, `< /dev/null`, `--sandbox danger-full-access`) | D-17/D-18 Linux runs only |
| `codex app-server` (`hooks/list`) and `codex app-server generate-json-schema` | Read plugin hook key, `trustStatus`, `currentHash`; discover the request shape | D-18 upgrade-trust observation. The spikes did not save a driver script; the executor writes a small throwaway Python one |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Env var `CLAUDE_PLUGIN_ROOT` as the route marker (D-07, locked) | Location of the running script (`$0` under a directory holding `.codex-plugin/plugin.json`) | Works even if Codex does not export the variable and needs no env, but adds a filesystem probe to the hook. Keep only as the pre-designed fallback if the Linux env probe fails |
| New test file for D-14 | Add gates to `tests/test_codex_patch.sh` | The latter already has `mkwork`, the fake compiler home and the captured payload; one new gate prefix (`plugin_route_`) is needed either way |

**Installation:** none. **Version verification:** `codex` 0.162.1 confirmed from `npm ls -g` (`@openai/codex@0.162.1`); `claude` 2.1.296; no package is added, so the legitimacy gate does not apply.

## Package Legitimacy Audit

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| none | - | - | - | - | - | This phase installs no external package (POSIX sh and Python stdlib only; Codex and Claude CLIs are existing tools, not dependencies of the repository) |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
                     one repository, one plugin directory plugins/bbj/
                     ------------------------------------------------
 Claude Code ----> .claude-plugin/plugin.json (userConfig docs_url, bbj_home)
                   .mcp.json  (url ${user_config.docs_url} + oauth clientId/callbackPort)
                   hooks/hooks.json  (Write|Edit -> sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh")

 Codex plugin ---> .codex-plugin/plugin.json (NEW overlay, same identity fields, no userConfig,
 route               "mcpServers": "./.codex-mcp.json")
                   .codex-mcp.json (NEW: literal docs URL [+ oauth block, see Open Question 1])
                   hooks/hooks.json (UNCHANGED; Codex matches Write|Edit against apply_patch)
                   skills/ (found by default)         scripts/bbj-check.sh (UNCHANGED path)

 codex plugin marketplace add <checkout | BBj-AI/bbj-agent-plugins>   reads .claude-plugin/marketplace.json
 codex plugin add bbj@basis-bbj         -> copies plugin into $CODEX_HOME/plugins/cache/basis-bbj/bbj/<version>/
 /hooks (user)                          -> trust recorded as hooks.state.<key>.trusted_hash in config.toml
                                           key = bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0

 model --apply_patch--> Codex --PostToolUse payload (stdin JSON)--> sh "$CLAUDE_PLUGIN_ROOT/scripts/bbj-check.sh"
                                                                    |
                         tool_name == apply_patch ---------> codex_patch: each *** Add/Update File / Move to
                                                                    |  .bbj/.src/.bbx --> bbjcpl -t -N -X   (tier 1)
                                                                    |  none           --> bbj-ls 127.0.0.1:5009 (tier 2)
                                                                    v
                    exit 2 + stderr feedback  |  exit 0 silent  |  exit 0 + ONE stdout JSON (no-route notice)
                                                                    |
                                    notice text: apply_patch AND CLAUDE_PLUGIN_ROOT non-empty -> "codex plugin add bbj-local@basis-bbj"
                                                 apply_patch AND CLAUDE_PLUGIN_ROOT empty     -> "install-codex.sh --with-local"
                                                 Write|Edit (Claude Code)                      -> "enable the bbj-local@basis-bbj plugin"

 Switch (CODEX-06):  install-codex.sh --remove   (installer-written things only)
     config.toml: [mcp_servers.bbj-docs] + oauth + 5 tools.* ; managed bbj-local block
     ~/.agents/skills/{bbj-programming,bbj-web-programming}   <codex home>/bbj/   <codex home>/hooks.json
   then by hand: codex plugin marketplace add ...; codex plugin add bbj@basis-bbj; /hooks trust
```

### Recommended Project Structure
```
plugins/bbj/
  .claude-plugin/plugin.json      # unchanged
  .codex-plugin/plugin.json       # NEW (D-10)
  .codex-mcp.json                 # NEW (D-11)
  .mcp.json                       # unchanged
  hooks/hooks.json                # unchanged
  scripts/bbj-check.sh            # one case branch in notice()
codex/install-codex.sh            # new removal option (+ header, usage, closing notes)
docs/install-codex.md             # plugin route first, installer as fallback
tests/test_layout.py              # +overlay/mcp gates, host rule, URL equality
tests/test_noroute_notice.sh      # +2 gates (plugin route, installer route)
tests/test_codex_patch.sh         # +D-14 gates (new prefix plugin_route_)
tests/test_install_codex.sh       # +removal matrix (new prefix remove_)
tests/test_install_pages.sh       # +pins for the plugin-route sections
tests/lib.sh                      # unset CLAUDE_PLUGIN_ROOT; comment update at home_snapshot
.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md   # recorded real runs
```

### Pattern 1: Overlay manifest (D-10)
**What:** `.codex-plugin/plugin.json` repeats the Claude identity fields byte-for-value and adds one key. Codex's discovery order in the 0.162.1 binary lists `.codex-plugin/plugin.json`, then `.claude-plugin/plugin.json`, then `.cursor-plugin/plugin.json` (binary strings, MEDIUM). Spike 002 observed the overlay winning. [CITED: .planning/spikes/002-codex-plugin-manifest/README.md]
**Example:** (see Code Examples)

### Pattern 2: Hook route text by tool and environment (D-07, D-08)
**What:** `notice()` already receives the tool name as `$1` and chooses `_how` by `case`. The `apply_patch)` arm splits on `${CLAUDE_PLUGIN_ROOT:-}`. The variable is only tested for presence, never printed or interpolated. [VERIFIED: plugins/bbj/scripts/bbj-check.sh:216-219]
```sh
  case "$1" in
    apply_patch) _how='To enable a check, set BBJ_HOME to the BBj installation directory or put bbjcpl on PATH, or rerun install-codex.sh --with-local (BBjServices 26.03+ running on this machine).' ;;
    *) _how='To enable a check, set the plugin option bbj_home to the BBj installation directory (for bbjcpl), or enable the bbj-local@basis-bbj plugin (BBjServices 26.03+ running on this machine).' ;;
  esac
```
(quoted verbatim from lines 216-219; the existing gate `notice_codex_text` asserts `'BBJ_HOME' 'bbjcpl on PATH' 'install-codex.sh --with-local' 'BBjServices 26.03' 'bbj_check_syntax' 'no bbjcpl found'` and `holds_none ... 'bbj_home' 'bbj-local@basis-bbj'` [VERIFIED: tests/test_noroute_notice.sh:167-173]). The plugin-route text must therefore contain `BBJ_HOME`, `bbjcpl on PATH`, `codex plugin add bbj-local@basis-bbj`, `BBjServices 26.03`, and must not contain `install-codex.sh`, `bbj_home` or the Claude wording `enable the bbj-local@basis-bbj plugin`. Note `bbj-local@basis-bbj` is a substring of the new Codex command, so the existing `holds_none ... 'bbj-local@basis-bbj'` stays valid only for the installer-route text; the new gates must assert exact command strings per variant.

### Pattern 3: D-14 plugin-route gate (modelled on `tests/test_claude_plugin.sh` section 4)
**What:** Parse the command from `hooks.json` with `python3 -I`, copy `plugins/bbj` to a fake Codex cache path (including one with a space), set `CLAUDE_PLUGIN_ROOT` to it, feed `codex_payload`, run `sh -c "$cmd"`, with the fake `bbjcpl` in a fake `BBJ_HOME`. [VERIFIED: tests/test_claude_plugin.sh:143-158 for the Claude version; tests/lib.sh:139-151 for `codex_payload`/`run_check`]
```sh
cmd=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$REPO/plugins/bbj/hooks/hooks.json")
CACHE=$WORK/home dir/plugins/cache/basis-bbj/bbj/0.2.0        # path with a space on purpose
mkdir -p "$CACHE" && cp -R "$REPO/plugins/bbj/." "$CACHE/"
codex_payload "$PROJ" "$(patch '*** Add File: bad.bbj' '+print "a"')" > "$WORK/p.json"
CLAUDE_PLUGIN_ROOT=$CACHE BBJ_HOME=$WORK/home FAKE_OUT=$WORK/canned FAKE_LOG=$WORK/calls.log \
  sh -c "$cmd" < "$WORK/p.json" > "$WORK/out" 2> "$WORK/err"
```
Expect exit 2, first stderr line `bbjcpl reported 1 error(s) in <abs>/bad.bbj:`, stdout empty, one fake-compiler call carrying `-N`; with `FAKE_OUT` unset a clean file exits 0 with empty stdout and stderr.

### Pattern 4: Installer removal as a mirror image (D-01 to D-04)
**What:** Reuse `analyze`/`state`/`use_docs`/`use_local` (globals `srv*`) to decide, then run one awk deletion pass per server and plain `rm`/`cmp`/`diff` for files. Decisions per object (all-or-nothing per server, so the result is never a half-removed server):

| Object | Remove when | Otherwise |
|--------|-------------|-----------|
| `[mcp_servers.bbj-docs]` table, its url | `main=1`, `foreign=0`, `tools_foreign=0`, `dstate` is `none` or `ours`, and the `url` equals the `--docs-url` in effect (default `https://mcp.bbj-ai.com/mcp`) | leave, print the tables that remain, `pending=1` (exit 3) |
| `[mcp_servers.bbj-docs.tools.NAME]` for the five `DOCS_TOOLS` | `tool.NAME` is `approve` (exactly `approval_mode = "approve"`) | any `other:VALUE` or `nokey` makes the whole server "left and reported" |
| `[mcp_servers.bbj-docs.oauth]` | `oauth=ours` (analyze already computes this; CONTEXT D-02 does not list it) | `oauth=other` (user's own settings) is left, named in one line, like the install side |
| managed block markers `MARK_BEGIN`/`MARK_END` | everything between them is one of the objects above | left and reported |
| `bbj-local` managed block (`LOCAL_MARK_BEGIN`..`LOCAL_MARK_END`) | `main=1`, `foreign=0`, `tools_foreign=0`, url exactly `LOCAL_URL`, tools only the three `LOCAL_TOOLS` with `approve` | hand-written form: leave, print, exit 3 (D-03). A lone end marker (what `codex mcp remove bbj-local` leaves) stays as a comment |
| skill dirs `$skills_dir/bbj-programming`, `bbj-web-programming` | `diff -r` against `$src_skills/<name>` is clean, and the path is a real directory (not a symlink) | leave, report, exit 3; with `--force` also remove a differing directory (recommendation, see Pitfall 5) |
| `$script_dir` (`<codex home>/bbj`) | always the installer's own directory (D-03): remove the file `bbj-check.sh`, then `rmdir` the directory only if empty; anything else in it is left and reported | - |
| `<codex home>/hooks.json` | `cmp -s` with the freshly rendered block (same renderer as step 4, including the `cygpath` branch) | leave, print the entry to remove, exit 3 (D-04) |
| `config.toml.bbj-backup`, `hooks.state.*`, parent dirs, AGENTS.md | never touched | - |

### Anti-Patterns to Avoid
- **Calling `codex` from the removal** (D-01): no `codex plugin`, no `codex mcp remove`. The fake codex log must stay empty during a removal; assert it.
- **Creating directories in remove mode.** Today lines 221, 232, 233 run `mkdir -p` on the Codex home, skills dir and `<codex home>/bbj` before anything else. Remove mode needs its own pre-flight that checks writability without creating, otherwise `home_snapshot` `H` lines and the `bbj/` entry change.
- **Writing the literal path `$codex_home/bbj"`** in the installer. `tests/test_static_guards.sh` scans the non-comment lines of `codex/*.sh` for `/bbj([[:space:]"']|$)`; use the existing `$script_dir` variable (`edaee0a` made the installer clear of this guard).
- **Printing or interpolating `CLAUDE_PLUGIN_ROOT`** in the notice. Test only for non-empty.
- **Adding Codex-written paths to `home_snapshot`.** See "Don't Hand-Roll" and Open Question 4.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Classifying `config.toml` forms for removal | A second parser | `analyze()` + `state()` + the `srv_*` globals in `codex/install-codex.sh:241-447` | They already encode "ours" vs "foreign" (including `oauth=ours|other`, `tool.NAME`, `dstate`, `managed`, `url`) |
| Rendering the expected `hooks.json` | A copy of the printf | Factor lines 848-861 into a function used by step 4 and by removal; `cmp -s` stays the identity test | Byte-identity includes the `cygpath` branch and JSON escaping |
| Skill identity | Checksums | `diff -r "$src" "$dst" > /dev/null 2>&1` as at line 823 | Same test the install side uses |
| Snapshot/compare of a Codex home | New walkers | `home_snapshot`, `home_diff`, `home_incomplete` (`tests/lib.sh:251-350`) | Content-based (cksum), already tested by `test_home_guard.sh` |
| Payload/compiler fakes | New fakes | `codex_payload`, `run_check`, `tests/fake-bin/bbjcpl`, `tests/fake-bin/codex`, `notice_text`, `no_compiler_path`, `no_compiler_env` | Captured Codex 0.162.1 payload shape |
| Reading hook command and manifests | grep/sed on JSON | `python3 -I -c 'import json...'` as already done in `test_claude_plugin.sh` and `test_layout.py` | Project allows Python in tests; the shipped hook stays pure sh |
| Loopback fake model for Codex | A new server | `.planning/spikes/001-codex-plugin-hooks/fake_responses.py` | Handles `custom_tool_call` vs `function_call` `apply_patch` and logs every request |
| Hook trust automation | Editing `hooks.state` by hand or shipping the bypass flag to users | `/hooks` in the TUI (once, by the owner); `--dangerously-bypass-hook-trust` only in scripted throwaway runs | Trust is a Codex security control; the docs must not recommend the bypass |

**Key insight:** every behaviour this phase needs already exists in the repo as a tested helper; the risk is in the seams (new files and options must not trip the pinned strings, static scans and snapshot rules), not in new algorithms.

## Runtime State Inventory

This phase is a migration (installer route to plugin route), so the five categories are answered explicitly.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | `<codex home>/config.toml`: `[mcp_servers.bbj-docs]` (+ `.oauth`, five `.tools.*`), optionally the managed `bbj-local` block, optionally old `default_tools_approval_mode = "approve"`. `config.toml.bbj-backup` (user's backup, left). `hooks.state.<key>.trusted_hash` entries written by Codex (left; harmless per D-04). Stored MCP sign-in tokens in Codex's credential store (keyring or encrypted file; strings seen in the binary) are not touched | Data migration by the removal option (delete exactly the installer's tables). Whether the stored sign-in carries over to the plugin's `bbj-docs` is unknown (binary has "stored credentials belong to a different client; reauthorization required"); record it in the Linux run |
| Live service config | None in this repo. The hosted docs server requires OAuth with the pre-registered client; a plugin-route user signs in separately from the installer route unless credentials are keyed identically | Docs say "sign in again if asked"; observe in the Linux run |
| OS-registered state | None. The installer registers nothing with the OS. Codex's own `[marketplaces]`/`[plugins]` tables and `plugins/cache/` are written by Codex | None |
| Secrets/env vars | `BBJ_HOME`, `BBJHOME`, `BBJ_LOCAL_MCP_URL`, `BBJ_CHECK_*` are read by the hook on both routes unchanged. `CLAUDE_PLUGIN_ROOT` is new as a route marker (read-only). No secret is involved; the OAuth client id is public | Add `CLAUDE_PLUGIN_ROOT` to the `unset` list in `tests/lib.sh` |
| Build artifacts / installed packages | `~/.agents/skills/bbj-programming`, `~/.agents/skills/bbj-web-programming` (copies; identical to `plugins/bbj/skills` for 0.2.0 installs, differing for pre-0.2.0 installs: `git diff 0.2.0 HEAD -- codex plugins` touches only `codex/install-codex.sh` and `plugins/bbj/.mcp.json`, so skills and script are unchanged since the tag [VERIFIED: git diff --stat 0.2.0 HEAD]); `<codex home>/bbj/bbj-check.sh`; `<codex home>/hooks.json`. The tag `0.2.0` is the only local tag | Removal deletes them under the rules in Pattern 4; docs tell a pre-0.2.0 user to use `--remove --force` |

## Common Pitfalls

### Pitfall 1: The installer leaves its OAuth table behind
**What goes wrong:** CONTEXT D-02 removes "the table and its five `tools.*` tables". Since quick 261013-cpn the installer also writes `[mcp_servers.bbj-docs.oauth]` (`install-codex.sh:257-261`, `:469-477`). Left behind without its parent table, it is an orphan sub-table (`mention=1`, `main=0` is exactly the "foreign" state the installer refuses to touch on the next install).
**Why it happens:** the discussion predates or overlooked the quick task.
**How to avoid:** remove it when `oauth=ours`; test both with and without it (a custom `--docs-url` run writes no OAuth table). Add the removal line to the docs ("removed [mcp_servers.bbj-docs.oauth]").
**Warning signs:** `home_diff` after remove shows a config.toml delta of four lines.

### Pitfall 2: `CLAUDE_PLUGIN_ROOT` might not reach the hook process
**What goes wrong:** D-07 falls back to "installer route" wording on the plugin route, which sends users to a script that does not apply.
**Why it happens:** Spike 001 saw the path already expanded in the command string (`hooks/list`), which could be Codex-side substitution. The hooks page says "Plugin hook commands receive these environment variables ... Codex also sets CLAUDE_PLUGIN_ROOT and CLAUDE_PLUGIN_DATA" [CITED: https://learn.chatgpt.com/docs/hooks]. The unchanged command `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"` works either way, so the spike could not tell.
**How to avoid:** prove it in the first real-Codex step: a scratch copy of the checkout whose `hooks.json` command is prefixed with `env > "$OUT/hook-env.txt";` (the repository file is not edited), then check the file for `CLAUDE_PLUGIN_ROOT=`. Then the NOBBJ run shows which notice wording arrived. If the variable is absent, switch detection to "the directory above `scripts/` holds `.codex-plugin/plugin.json`" (path of `$0`); this still needs no marker in the installer's `hooks.json`.
**Warning signs:** the no-route developer message on a plugin install names `install-codex.sh`.

### Pitfall 3: `holds_none 'bbj-local@basis-bbj'` and the new Codex command overlap
**What goes wrong:** the Codex plugin-route text `codex plugin add bbj-local@basis-bbj` contains the Claude-route fragment. A lazy copy of `notice_codex_text_no_claude_steps` fails or, worse, passes on the wrong text.
**How to avoid:** three variants, each asserting its full command string and that the other two commands are absent: Claude `enable the bbj-local@basis-bbj plugin`; installer `rerun install-codex.sh --with-local`; plugin `codex plugin add bbj-local@basis-bbj` (D-09). The existing installer-route gate must run with `CLAUDE_PLUGIN_ROOT` unset (add it to the `unset` at `tests/lib.sh:50`).

### Pitfall 4: Shell assignment before a function call persists in dash
**What goes wrong:** `CLAUDE_PLUGIN_ROOT=x run_check "$p"` may leave the variable set after the call under dash and POSIX-mode shells, silently turning the next installer-route gate into a plugin-route one. `tests/test_codex_patch.sh:137,150` already uses `BBJ_HOME=... run_check` but on an exported variable.
**How to avoid:** set, export, call, `unset` explicitly; or run `env CLAUDE_PLUGIN_ROOT=... sh "$SCRIPT"` inside the gate. Keep `unset CLAUDE_PLUGIN_ROOT` at the top of `lib.sh`.

### Pitfall 5: Pre-0.2.0 installs have differing skills and the byte-identical rule leaves a second copy
**What goes wrong:** Success criterion 6 names installs by 0.1.0 or 0.2.0. Skills were rewritten in 0.2.0, so a 0.1.0 install differs from the shipped copy; D-03 then leaves both skill directories, exits 3, and the user ends with two copies of the skills (installer dir and plugin cache), the very duplicate CODEX-06 forbids.
**How to avoid:** `--remove --force` deletes a differing skill directory (the same meaning `--force` has today: act on a directory that differs; the docs already warn to copy local edits out first). Plain `--remove` still leaves and reports. Test: a differing skill dir is left without `--force` (exit 3) and removed with it (exit 0).

### Pitfall 6: Removal of a custom-URL registration
**What goes wrong:** A user who installed with `--docs-url http://127.0.0.1:7777/mcp` has a `[mcp_servers.bbj-docs]` table that is also the documented Codex counterpart of Claude's `docs_url` option (spike 002 step 5: such a table replaces the plugin's server). Removing it silently loses their setting.
**How to avoid:** remove the table only when its `url` equals the `--docs-url` in effect (default `https://mcp.bbj-ai.com/mcp`); the user repeats `--docs-url` to remove a custom registration. Print the url that was removed. This is a recommendation; D-02 says "in the forms the installer writes", which is silent on the url.

### Pitfall 7: Static guard and header comment
**What goes wrong:** New installer lines containing a bare word `bbj`, `bbjcpl`, `python`, `node`, `jq`, `eval`, or `/bbj"` in non-comment code (messages and the usage heredoc count) fail `static_*_install-codex.sh`.
**How to avoid:** phrase messages with `bbj-docs`, `bbj-local`, `bbj@basis-bbj`; use `$script_dir`; run `sh tests/test_static_guards.sh` after every installer edit. [VERIFIED: tests/test_static_guards.sh:150-166 for the codex scan list]

### Pitfall 8: Pinned docs strings and the "verified" regex
**What goes wrong:** `tests/test_install_pages.sh:215` forbids `(was|has been|is) (verified|tested) (on|with) (a )?Codex` on the Codex page. The D-16 line "verified on Linux with the Codex version and date of this run" is fine as "Verified on Linux with Codex CLI 0.162.1 on <date>" but fails as "was tested with Codex ...". `release_codex_version_single` requires that all `Codex CLI N.N.N` strings in the installer and the page name one version. The page also must keep all 38 `need` phrases (list in "Docs rewrite constraints") and must not contain `says nothing`, `missing compiler is silent`, or `(preferred|better) (than|over) bbjcpl`.
**How to avoid:** restructure by adding the plugin sections above the existing ones; keep the existing headings (`## 2. Enable the local check ...`, `## Check routes`, `## Not covered`, `## Windows`) and fence blocks; add new pins in the same plan.

### Pitfall 9: Byte-identical restoration of `config.toml` has limits
**What goes wrong:** D-05 asserts the home is back to its pre-install state. The installer appends a blank line before a managed block, one blank line before each tool/oauth table, and (no-codex path) creates `config.toml` when absent; the fake `codex` appends with no blank line; the real Codex formats its own table. A removal that deletes only headers and bodies leaves stray blank lines; an install that created `config.toml` leaves an empty file where there was none.
**How to avoid:** the awk deletion pass buffers blank lines and drops exactly the one blank line that precedes each removed header; never delete `config.toml` itself. In the round-trip test, start from a pre-existing `config.toml` with user content and pre-created Codex home and skills directory (their `H`/`D` lines are outside what the installer undoes). Assert exact equality for installer-written layouts (managed block, fake-codex form); for the real-Codex run assert TOML equivalence (`tomllib` summary) and record any residual blank line.

### Pitfall 10: Docs sign-in step contradicts the plugin file if the OAuth block is missing
**What goes wrong:** The docs server asks for OAuth (README lines 27-29). On the plugin route nothing writes the pre-registered client unless `.codex-mcp.json` carries it, so `codex mcp login bbj-docs` would try dynamic registration, which the server refuses (installer comment, `install-codex.sh:526-527`).
**How to avoid:** see Open Question 1; do not write docs sentences about plugin-route sign-in until the Linux run has observed it.

### Pitfall 11: `layout_docs_host_single_source` compares an unsorted list
**What goes wrong:** `hits == ["plugins/bbj/.claude-plugin/plugin.json"]` uses `os.walk` order. With two allowed files the equality must compare `sorted(hits)` to a sorted expected list.
**How to avoid:** change the expectation to the two paths and sort both sides.

## Code Examples

### `plugins/bbj/.codex-plugin/plugin.json` (D-10)
Identity fields copied from [VERIFIED: plugins/bbj/.claude-plugin/plugin.json, whole file read]; `userConfig` omitted; `mcpServers` added as in spike 002 [CITED: .planning/spikes/002-codex-plugin-manifest/run.sh].
```json
{
  "name": "bbj",
  "version": "0.2.0",
  "description": "The hosted BBj docs MCP server, the two BBj skills (bbj-programming, bbj-web-programming), and a compile-only check of every BBj file the agent writes (bbjcpl -N; BBj code is never run).",
  "author": {
    "name": "BASIS International Ltd."
  },
  "homepage": "https://github.com/BBj-AI/bbj-agent-plugins",
  "license": "Apache-2.0",
  "keywords": ["bbj", "basis", "mcp", "skills", "compile-check"],
  "mcpServers": "./.codex-mcp.json"
}
```
The spike tested only `name`, `version`, `description`, `mcpServers`; `author`, `homepage`, `license`, `keywords` are listed fields of the plugin manifest in the official build page [CITED: https://developers.openai.com/plugins/build/plugins] but were not exercised on 0.162.1 (Assumption A4).

### `plugins/bbj/.codex-mcp.json` (D-11) - minimum and recommended
Minimum (what spike 002 validated, `type` and `url` only):
```json
{
  "mcpServers": {
    "bbj-docs": {
      "type": "http",
      "url": "https://mcp.bbj-ai.com/mcp"
    }
  }
}
```
Recommended addition, subject to Open Question 1 (camelCase keys per the Codex MCP page [CITED: https://learn.chatgpt.com/docs/extend/mcp?surface=cli]; values are those of `plugins/bbj/.mcp.json` [VERIFIED: plugins/bbj/.mcp.json, whole file read: `"clientId": "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"`, `"callbackPort": 47613`] and of the installer [VERIFIED: codex/install-codex.sh:102 `OAUTH_CALLBACK_URL=http://localhost:47613/callback`]):
```json
{
  "mcpServers": {
    "bbj-docs": {
      "type": "http",
      "url": "https://mcp.bbj-ai.com/mcp",
      "oauth": {
        "clientId": "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t",
        "callbackUrl": "http://localhost:47613/callback",
        "callbackPort": 47613
      }
    }
  }
}
```
Codex logs `ignoring invalid plugin MCP server` for a malformed entry (binary string), so a wrong shape could drop `bbj-docs` silently; check with `codex mcp list` (shows the server, its URL and an Auth column; the 0.2.0 record shows `Auth: Unsupported` for the installer route [CITED: .planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/codex/checks.txt]) after adding the block.

### Layout gate edits (D-13) against the real structure
Current facts [VERIFIED: tests/test_layout.py:22,53-60,71-73,167-180] (quoted):
```python
VERSION = "0.2.0"
...
versions = [bbj.get("version"), local.get("version"),
            entries.get("bbj", {}).get("version"), entries.get("bbj-local", {}).get("version")]
gate("versions", all(v == VERSION for v in versions), "versions=%r want all %s" % (versions, VERSION))
...
gate("docs_host_single_source", hits == ["plugins/bbj/.claude-plugin/plugin.json"],
     "files naming %s: %r" % (DOCS_HOST, sorted(hits)))
```
Edits: load `plugins/bbj/.codex-plugin/plugin.json` and `plugins/bbj/.codex-mcp.json` with the existing `load()`; append the overlay version to the `versions` list (keep gate name `versions`); change the host rule to `sorted(hits) == ["plugins/bbj/.claude-plugin/plugin.json", "plugins/bbj/.codex-mcp.json"]`; add new gates named without clashing prefixes (all start `layout_`): `codex_overlay_fields` (shared fields equal the Claude manifest, no `userConfig`, `mcpServers == "./.codex-mcp.json"` and the file exists), `codex_mcp` (exact dict as `bbj_mcp` does), `codex_url_equals_default` (`.codex-mcp.json` url equals `uc["docs_url"]["default"]`; the Claude `.mcp.json` url stays `${user_config.docs_url}`), and if the OAuth block is adopted, extend `oauth_codex_matches_plugin` so the Codex file's `clientId`/`callbackPort` equal the Claude file's. Add the overlay to the `texts` list of the wording scan (`layout_no_vendoring_wording`). Keep the line `VERSION = "0.2.0"` unchanged in shape: `tests/test_release_text.py` and `tests/test_release_text_mutation.sh` read it with the regex `^VERSION = "([0-9]+\.[0-9]+\.[0-9]+)"$`.

### Plugin-route and installer-route notice gates (D-09)
Pattern to copy [VERIFIED: tests/test_noroute_notice.sh:163-175 and `notice_text` in tests/lib.sh:91-111]: `fresh_state`, `run_check "$(codex_payload "$CPROJ" "$(patch '*** Add File: a.bbj' '+print "a"')")"`, `CTEXT=$(notice_text "$WORK/stdout")`, then `holds_all`/`holds_none`. For the plugin variant export `CLAUDE_PLUGIN_ROOT=$WORK/plugins/cache/basis-bbj/bbj/0.2.0` before the call and unset after.

### Release-text and page pins that the docs rewrite must keep
- `tests/test_install_pages.sh:159-201` requires on the Codex page, verbatim: `Tested on Linux only`, `install-codex.sh`, `--docs-url`, `--skills-dir`, `--codex-home`, `default_tools_approval_mode`, the five `[mcp_servers.bbj-docs.tools.bbj_*]` headers, `approval_mode = "approve"`, `bbj_check_syntax`, `~/.agents/skills`, `~/.codex/skills`, `/hooks`, `apply_patch`, `## Check routes`, `## Not covered`, `## Windows`, `Git for Windows`, `commandWindows`, `guardrail`, `--with-local`, `recommended where BBjServices 26.03`, `preferred over the hosted check`, `PREFIX, classpath and config`, `## 2. Enable the local check`, `[mcp_servers.bbj-local]` and its three tool headers, `http://127.0.0.1:5009/mcp`, `codex mcp remove bbj-local`, `BBJ_LOCAL_MCP_URL`, `tools/list`, `once per session`, `not compile-checked`, `[mcp_servers.bbj-docs.oauth]`, `callback_port = 47613`, `http://localhost:47613/callback`, `codex mcp login bbj-docs`, plus `client_id = "<OAUTH_CLIENT_ID>"` read from the installer. The `bbj-local` tool-table list on the page must equal `LOCAL_TOOLS` of the installer, and eight installer messages must be quoted on the page and printed on non-comment installer lines (`a bbj-ls answers at`, `no bbj-ls answered at`, `not probed: curl not found`, `is not a loopback http URL`, `registering it anyway`, `already registered in`, `added the OAuth client to`, `OAuth settings of its own`).
- README must keep the line starting `The \`basis-bbj\` marketplace` with `, version 0.2.0,` and the phrases `recommended where BBjServices 26.03`, `preferred over the hosted check`, `PREFIX, classpath and config`, `--with-local`, `## Skills`, `once per session` (tests/test_install_pages.sh:253-262; tests/test_release_text.py readme gate). The README Codex lines to update are 14-15 (bbj-local sentence), 27-29 (OAuth sentence) and 35-36 (page description).
- Installer lines quoted by `release_upgrade_quotes` must stay on non-comment installer lines: `rerun with --force to replace it`, `every update of it makes Codex ask for the /hooks review again`, `open /hooks, and approve the BBj check hook` [VERIFIED: tests/test_release_text.py:41-45].

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `install-codex.sh` copies skills, script, `hooks.json`, writes `config.toml` tables | `codex plugin marketplace add` + `codex plugin add name@marketplace` reading the legacy `.claude-plugin/marketplace.json` | Codex 0.121+ marketplace CLI; observed on 0.162.1 in spikes | Installer kept one release as fallback |
| Root `mcp.json` portable MCP file (documented primary form) | `.codex-plugin/plugin.json` overlay with `mcpServers` (documented fallback) | Observed 2026-10-12 (spike 002): root `mcp.json` did not override `.mcp.json` | Keep the overlay; re-check if Codex changes precedence |
| Installer pre-approves five docs tools by name | Plugin route: all tools prompt on first use; optional `plugins."bbj@basis-bbj".mcp_servers.bbj-docs.tools.NAME` approvals | Spike 005 decision | Documented option, not written by tooling (D-02) |
| Hook trust hash covers the installer's script path | Plugin trust is per hook definition; the cache path embeds the version | Unknown for upgrades | Observe in D-18 |

**Deprecated/outdated:** `codex marketplace add` (early blogs) is now `codex plugin marketplace add`. The official page says "marketplace refresh" is `codex plugin marketplace upgrade [name]` and documents no plugin remove command, while the 0.162.1 binary contains help text `plugin remove sample@debug` (binary strings, not run). Use only commands the Linux run has executed in the docs.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | A plugin MCP file may carry `oauth.clientId`, `callbackUrl`, `callbackPort` (camelCase) in Codex 0.162.1. Basis: official MCP page says so; the binary holds those key strings and `AgentPluginMcpServer::StreamableHttp`. Never exercised | Code Examples, Open Question 1 | Block ignored or server dropped ("ignoring invalid plugin MCP server"); plugin-route docs server unusable against the signed-in host |
| A2 | With a `clientId` and a provider without issuer-bound callbacks, Codex may ignore the plugin's `callbackUrl` and use `mcp_oauth_callback_url` or `http://127.0.0.1/callback` plus a callback id (official page wording). The hosted server accepts only the registered callbacks (localhost:47613/callback, 127.0.0.1:47613/callback, claude.ai) per the pending todo | Open Question 1 | Sign-in redirect refused by the auth server; needs the todo's tried shape (top-level `mcp_oauth_callback_port`) in user config |
| A3 | `CLAUDE_PLUGIN_ROOT` is exported to the plugin hook process (hooks docs: "Plugin hook commands receive these environment variables") | Pitfall 2, D-07 | Plugin route shows installer wording; fall back to script-location detection |
| A4 | Codex accepts `author`, `homepage`, `license`, `keywords` in `.codex-plugin/plugin.json` (listed in the build page for the root manifest) | Code Examples | Plugin fails to load or fields ignored; reduce the overlay to the four spike-tested fields and relax the D-10 gate accordingly |
| A5 | `codex plugin marketplace add BBj-AI/bbj-agent-plugins` (owner/repo shorthand) works for this public repo after release (official docs per search result; spikes used a local path) | Docs | Wrong first command in the docs; confirm after the PR merges (Phase 10 timing) or use the full URL |
| A6 | `codex plugin remove <name>@<marketplace>` exists in 0.162.1 (help text in binary strings only) | Docs "undo" wording | Do not document it unless the Linux run executes it |
| A7 | `plugins."bbj@basis-bbj".mcp_servers.bbj-docs.tools.<tool>` with `approval_mode = "approve"` restores docs-tool pre-approval (official example uses `sample@test`) | D-02 docs text | Docs option does nothing; label as "from the Codex page, not tried here" until run |
| A8 | A plugin upgrade changes the hook hash (versioned cache path) and asks for trust again | Docs, D-18 | If it does not, an upgrade could run an untrusted-looking hook silently or keep trusting; the observation settles it |
| A9 | Real `codex mcp add` writes `[mcp_servers.bbj-docs]` + `url` in a layout the same awk pass can remove byte-cleanly | Pitfall 9 | Residual blank line or extra keys; check in the real D-05 run |
| A10 | `--remove --force` should delete differing skill directories | Pitfall 5 | Owner may prefer a separate flag or docs-only `rm -rf`; planner decides |
| A11 | Removal deletes the `bbj-docs` table only when its url equals the `--docs-url` in effect | Pitfall 6 | A custom-url user must repeat the flag; otherwise their override survives and is reported |
| A12 | Static evidence for A1/A6 from `strings` on the installed `codex` binary is a faithful sign of the shipped behaviour | A1, A6 | Dead code strings give false comfort; only the run proves it |

## Open Questions

1. **Does the plugin route sign in to the hosted docs server, and should `.codex-mcp.json` carry the OAuth client?**
   - What we know: the hosted server requires sign-in with only the pre-registered client (README lines 27-29; installer comments `install-codex.sh:95-99`); Claude's `.mcp.json` carries it; the installer writes it for the installer route; the pending todo `.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md` targets Phase 08 and lists the shapes tried by the server owner (Codex: top-level `mcp_oauth_callback_port = 47613`, `[mcp_servers.<name>.oauth] client_id`, `callback_url = "http://127.0.0.1:47613/callback"`; the installer's per-server `callback_port` with `localhost` was "not tried in a session"). The Codex page documents plugin-side `clientId`, `callbackUrl`, `callbackPort`. None of this was exercised on a plugin-supplied server.
   - What's unclear: whether 0.162.1 accepts those keys in a plugin file, honours `callbackUrl`, and whether `codex mcp login bbj-docs` works for a plugin-supplied server (the page says plugin servers follow the same callback rules; it does not state `login` support).
   - Recommendation: include the OAuth block in `.codex-mcp.json` (same client id and port as `.mcp.json`, gated by `layout_`), and make the Linux run print the authorization URL of `codex mcp login bbj-docs` against a throwaway home (network call to the hosted pre-production login, no billing; the owner may complete or abort the browser step) and inspect `redirect_uri`. Record the outcome in `08-LINUX-RUN.md`. If it fails, document the user-config fallback from the todo and keep the claim out of CODEX-01's verification text. This needs the owner's decision because CONTEXT.md did not cover it.

2. **Does the removal option need to honour `--docs-url` and `--skills-dir`/`--codex-home`?** Yes in practice: it must find the same paths. Recommendation: accept the same options as the installer; refuse `--remove` together with `--with-local` (exit 2, nothing written).

3. **Does a plugin upgrade ask for trust again?** Unknown (Spike 001, STATE blocker). Recommendation: D-18 as written; automate the read side with `codex app-server` `hooks/list` (key `bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0`, `trustStatus`, `currentHash`), have the owner trust once in the `/hooks` TUI, then change the scratch copy's versions, run `codex plugin marketplace upgrade basis-bbj` and re-read `hooks/list`; if the cache path does not change, run `codex plugin add bbj@basis-bbj` again and record which command refreshed the cache.

4. **Should `home_snapshot` watch plugin-route paths?** Recommendation: no. `$CODEX_HOME/plugins/`, `[marketplaces]` and `[plugins]` in `config.toml` are Codex-written, change whenever the owner uses Codex for real (same false-FAIL class as the daemon files MAINT-07 fixed), and no suite test touches the real home. `real_home_untouched` already watches `config.toml`, `hooks.json`, `bbj/` and the two skill dirs, which is the installer's whole write set, so the removal test needs nothing more. Update the stale comment `# D-08: ... Phase 8 adds its plugin-route paths here` at `tests/lib.sh:254` to say that none were added and why. For the throwaway-home real run, take a before/after snapshot of the throwaway home with `find`/`cksum` in the run script, not in CI.

5. **Gate prefixes.** New prefixes: `remove_` (`test_install_codex.sh`), `plugin_route_` (`test_codex_patch.sh`), `notice_` / `layout_` / `codex_` reuse existing ones. Update the prefix block in both `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` together (Phase 7 07-05/07-06 precedent: byte-identical copy, no sync gate).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| POSIX `sh` (dash), `bash` | all tests | yes | bash 5.3.9; dash present | - |
| Python 3 + `tomllib` | layout, installer tests | yes | 3.14.4 | tests skip tomllib gates without it |
| ShellCheck | `tests/ci.sh` lint | yes | installed | skip locally, FAIL in CI |
| Claude CLI | `claude plugin validate --strict`, `test_claude_plugin.sh` | yes | 2.1.296 | skip locally, FAIL in CI |
| Codex CLI | Linux real runs only (D-05, D-17, D-18) | yes | 0.162.1 (`<home>/.npm-global/bin/codex`) | none needed for CI |
| Throwaway Codex home outside `/tmp` | Linux runs | yes | `~/.cache` has 346 GB free; `~/.cache/bbj-spike/` exists from the spikes | use `~/.cache/bbj-phase8/<run>` |
| Loopback ports 18765/18766 | fake Responses server | assumed free | - | set `PORT` |
| BBj (`bbjcpl`) | not needed | no compiler on `PATH` | - | fakes only; BBj is never run |
| Network to `mcp.bbj-ai.com` / login host | only the optional sign-in URL check (Open Question 1) | not probed | - | skip; record as not run |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** BBj (fakes), network sign-in check (optional, owner-approved).

The Linux runs must never touch the real `~/.codex` or `~/.agents`, must not run under `/tmp`, and must not start billed model runs; the researcher did not run Codex or BBj in this session (evidence from the installed binary came from `strings`/`grep` only).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Project-local sh and Python gates printing `gate NAME ok|FAIL|skip DETAIL`; runner `tests/run.sh`, CI entry `tests/ci.sh` |
| Config file | `.shellcheckrc` (shell=sh); no other config |
| Quick run command | per file: `sh tests/test_noroute_notice.sh`, `sh tests/test_codex_patch.sh`, `sh tests/test_install_codex.sh`, `sh tests/test_install_pages.sh`, `sh tests/test_static_guards.sh`, `python3 -I tests/test_layout.py`, `python3 -I tests/test_release_text.py` |
| Full suite command | `sh tests/run.sh` (add `CI=true` for the strict behaviour); `sh tests/ci.sh` adds `claude plugin validate --strict` and ShellCheck. Run with `codex` removed from `PATH` (or `BBJ_TEST_CODEX` unset and `codex` not on `PATH`) if you do not want `tests/test_install_codex.sh` to run the optional real-Codex gates (`real_codex_install`, `real_codex_parses_configs`, which use temp homes only) |

Baseline in this session: `python3 -I tests/test_layout.py` and `python3 -I tests/test_release_text.py` all gates ok at 0.2.0.

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CODEX-01 | overlay present with shared identity fields, `userConfig` absent, `mcpServers` points at an existing file; `.codex-mcp.json` shape and literal URL; Claude `docs_url` and `.mcp.json` unchanged (`layout_bbj_mcp`, `layout_user_config_*`); `claude plugin validate --strict` passes | unit / validate | `python3 -I tests/test_layout.py`; `sh tests/ci.sh` (gates `ci_validate_*`, `validate_*` in `test_claude_plugin.sh`) | partly; new `layout_codex_overlay_fields`, `layout_codex_mcp` are Wave 0 |
| CODEX-01 (real) | `codex mcp list` shows `bbj-docs` at the literal URL; `codex debug prompt-input` lists both skills in a throwaway home | manual real run | spike 001/002 scripts adapted; record in `08-LINUX-RUN.md` | no (manual) |
| CODEX-02 | hooks.json command string run with a Codex plugin-route payload: bad file exit 2 + `bbjcpl reported 1 error(s)`, clean file exit 0 empty stdout/stderr, `-N` on the call, root path with a space | integration on fakes | `sh tests/test_codex_patch.sh` (gates `plugin_route_*`) | no, Wave 0 |
| CODEX-03 | three notice variants with exact command strings; env restored; Claude gate unchanged | unit on fakes | `sh tests/test_noroute_notice.sh` (gates `notice_*`) | partly; two new gates Wave 0 |
| CODEX-04 | one version across both plugin.json, both marketplace entries and the overlay; URL equality `.codex-mcp.json` vs `docs_url` default; hosted host only in the two allowed files | unit | `python3 -I tests/test_layout.py` (gates `layout_versions`, `layout_codex_url_equals_default`, `layout_docs_host_single_source`) | partly; edits plus new gates Wave 0. Add a mutation spot check (point argv[1] at a temp copy with one wrong version) as the existing release mutation harness does |
| CODEX-05 | the page leads with the two commands, `/hooks` trust, first-use prompts, `BBJ_HOME`, `bbj-local` command, upgrade-trust sentence, switch section; pinned 0.2.0 lines survive; links resolve | text gates | `sh tests/test_install_pages.sh` (`codex_*`, `link_*`), `python3 -I tests/test_release_text.py` (`release_codex_version_single`, `release_upgrade_quotes`) | partly; new `need` pins Wave 0 |
| CODEX-06 | `--remove`: round trip equals the pre-install home (`home_snapshot`/`home_diff`); install, remove, install equals first install; foreign/differing/hand-written forms: exit 3 and nothing touched; second removal is a no-op; no `codex` call; refusal before any write (exit 2); static guards pass | integration on fakes | `sh tests/test_install_codex.sh` (gates `remove_*`), `sh tests/test_static_guards.sh` | no, Wave 0 |
| CODEX-06 (real) | one hook, one skill copy, one `bbj-docs` server after installer install, removal, two plugin commands | manual real run | `codex mcp list`, `codex debug prompt-input`, `hooks/list` in a throwaway home | no (manual) |

### Sampling Rate
- **Per task commit:** the quick command of the file the task touched, plus `sh tests/test_static_guards.sh` when `bbj-check.sh` or `install-codex.sh` changed.
- **Per wave merge:** `sh tests/run.sh` with `CI=true`.
- **Phase gate:** `sh tests/ci.sh` green (claude validate + ShellCheck), `skip` counts reviewed, and `08-LINUX-RUN.md` present with Codex version, date, route and outcome for each run.

### Wave 0 Gaps
- [ ] `plugins/bbj/.codex-plugin/plugin.json`, `plugins/bbj/.codex-mcp.json` (files under test)
- [ ] `tests/test_layout.py` new gates and the host-rule edit
- [ ] `tests/test_noroute_notice.sh` two new gates; `tests/lib.sh` `unset CLAUDE_PLUGIN_ROOT`
- [ ] `tests/test_codex_patch.sh` `plugin_route_*` gates
- [ ] `tests/test_install_codex.sh` `remove_*` matrix (with a helper to render a pre-install snapshot); installer `--remove`
- [ ] `tests/test_install_pages.sh` new `need` pins and quoted-message pins for the removal output
- [ ] prefix block update in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md`
- [ ] Framework install: none

## Security Domain

`security_enforcement` is enabled in `.planning/config.json` (ASVS level 1, block on high).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes (hosted docs sign-in; not implemented here) | Pre-registered public OAuth client only; no secret in any file (`clientSecret` is a recognised plugin key and must never be added) |
| V3 Session Management | no | - |
| V4 Access Control | yes | Plugin hook runs only after the user trusts it in `/hooks`; never recommend `--dangerously-bypass-hook-trust` to users; real-Codex runs only in throwaway homes |
| V5 Input Validation | yes | Installer options validated before the first write (existing `case` guards on `--docs-url`, `--codex-home`, newline checks); removal reuses them; hook never interpolates env/file content into commands |
| V6 Cryptography | no | - |
| V12 Files and Resources | yes | Removal deletes only named children (two skill dirs, the check script, `hooks.json` when byte-identical); never `rm -rf` a variable that may be empty or a parent dir; symlinked skill dir, `config.toml` or `hooks.json` is skipped/kept-in-place per existing convention |
| V14 Configuration | yes | `config.toml` edited in place via temp file in the Codex home (keeps symlink and mode), one-time backup before the first change, refuse foreign forms |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| `rm -rf` on a wrong or empty path in removal | Tampering / Denial of service | Guard `[ -n "$dst" ]`, compute paths from validated options, remove only `$skills_dir/<fixed name>` and `$script_dir/<fixed file>`, `rmdir` not `rm -rf` for `$script_dir`, test with hostile option values (spaces, newline refused by existing checks) |
| Symlink swap of a skill dir or `config.toml` | Tampering | Do not follow: leave a symlinked skill dir and report; write `config.toml` in place (`cat "$tmp" > "$config"`) as the install side does |
| Hook command injection through `CLAUDE_PLUGIN_ROOT` or paths | Elevation of privilege | Unchanged quoting `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`; the script only tests the variable for non-empty and never evals; D-14 gate includes a root with a space |
| Plugin hook running without review | Elevation of privilege | Codex skips plugin hooks until trusted; docs explain the trust step and that an upgrade may need it again (as observed) |
| Silent override of the plugin's docs server by a stale user table | Spoofing | Removal deletes the installer's `[mcp_servers.bbj-docs]`; a user-owned table is reported (a user override is the documented way to change the URL) |
| OAuth callback port squatting / wrong redirect | Spoofing | Pre-registered callbacks only; callback port 47613 must be free during sign-in (existing docs sentence) |
| Exposure of the OAuth client id | Information disclosure | Public client by design (tenant note in the pending todo); never add a secret; layout gate pins the exact dict so an extra key fails |

## Sources

### Primary (HIGH confidence) - files read this session
- `<home>/repos/bbj-agent-plugins/.planning/phases/08-codex-plugin-route/08-CONTEXT.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/config.json`, `.planning/phases/07-test-hardening-and-release-prep/07-CONTEXT.md`
- `.planning/spikes/` README files of 001, 002, 003, 005, `run.sh`/`fake_responses.py`/`tools.sh`, `CONVENTIONS.md`, `MANIFEST.md`
- `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj/.mcp.json`, `plugins/bbj/hooks/hooks.json`, `plugins/bbj-local/.claude-plugin/plugin.json`, `plugins/bbj-local/.mcp.json`, `.claude-plugin/marketplace.json`
- `plugins/bbj/scripts/bbj-check.sh` (header, `notice()`, `main`), `codex/install-codex.sh` (whole file), `codex/AGENTS-snippet.md`, `docs/install-codex.md`, `README.md`, `CHANGELOG.md` (head)
- `tests/lib.sh`, `tests/test_layout.py`, `tests/test_noroute_notice.sh` (lines 1-240), `tests/test_codex_patch.sh`, `tests/test_install_codex.sh` (head, first-run and tail sections), `tests/test_install_pages.sh`, `tests/test_release_text.py`, `tests/test_claude_plugin.sh`, `tests/test_static_guards.sh`, `tests/test_home_guard.sh` (head), `tests/test_check_order.py` (client-neutral gate), `tests/run.sh`, `tests/ci.sh`, `tests/fake-bin/{codex,bbjcpl}`
- `.planning/quick/261013-cpn-*/261013-cpn-SUMMARY.md`, `.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md`, `.planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/codex/{install-output,checks}.txt`
- `git diff --stat 0.2.0 HEAD -- codex plugins`, `git tag`

### Secondary (MEDIUM confidence)
- Codex MCP page (plugin-bundled servers, OAuth keys, callback rules, `plugins.<plugin>.mcp_servers`): https://learn.chatgpt.com/docs/extend/mcp?surface=cli (redirect of developers.openai.com/codex/mcp), read through a summarising fetch tool
- Codex hooks page (plugin hook environment variables, trust against the hook hash): https://learn.chatgpt.com/docs/hooks
- Plugin build page (manifest fields, `extensions.com.openai`, no documented remove command, `marketplace upgrade`): https://developers.openai.com/plugins/build/plugins
- Search results on `codex plugin marketplace add owner/repo`: https://developers.openai.com/codex/plugins/build.md and third-party guides (codex.danielvaughan.com)

### Tertiary (LOW confidence, marked for validation)
- `strings`/`grep` over the installed Codex 0.162.1 binary (`<home>/.npm-global/lib/node_modules/@openai/codex/node_modules/@openai/codex-linux-x64/vendor/x86_64-unknown-linux-musl/bin/codex`): keys `callbackUrl`, `callbackPort`, `clientSecret` in `codex-mcp/src/plugin_config.rs`, `AgentPluginMcpServer::StreamableHttp`, "ignoring invalid plugin MCP server", discovery order of `.codex-plugin`/`.claude-plugin`/`.cursor-plugin` manifests, `plugin remove sample@debug`, `marketplace upgrade`, `app-server generate-json-schema`, `hooks/list`, `trusted_hash`, `--dangerously-bypass-hook-trust`. The binary was not executed.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new dependencies; versions read from the host
- Architecture: HIGH for repo structure and gate wiring (all files read); MEDIUM for Codex behaviour (spikes plus docs)
- Pitfalls: HIGH for the repo-internal ones (static guard, pinned strings, version-string gate, dash assignment, orphan OAuth table); MEDIUM for Codex-side ones (env export, OAuth keys, upgrade trust)

**Research date:** 2026-10-13
**Valid until:** 2026-10-20 for Codex-side claims (the Codex plugin surface changes quickly: the build page differs from the spike-time text); repo-side findings stay valid until files change.
