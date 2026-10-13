---
phase: 08-codex-plugin-route
verified: 2026-10-13T16:30:00Z
status: passed
score: 6/6 must-haves verified
covered_files:
  - ".planning/phases/08-codex-plugin-route/08-01-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-01-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-02-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-02-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-03-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-03-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-04-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-04-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-05-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-05-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-06-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-06-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-07-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-07-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-08-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-08-SUMMARY.md"
  - "README.md"
  - "codex/install-codex.sh"
  - "docs/install-codex.md"
  - "plugins/bbj/.codex-mcp.json"
  - "plugins/bbj/.codex-plugin/plugin.json"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "tests/lib.sh"
  - "tests/test_codex_patch.sh"
  - "tests/test_install_codex.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_noroute_notice.sh"
covered_digest: "v3:sha256:6685af2cd5ad9a45cf898a1405b86a9d179d46860666ad1b2802b7be04e056f4"
behavior_unverified: 0
overrides_applied: 0
---

# Phase 8: Codex plugin route Verification Report

**Phase Goal:** A Codex user installs `bbj`, and opts into `bbj-local`, from the `basis-bbj` marketplace with Codex's own plugin commands. They get a working `bbj-docs` server, both skills, and the unchanged compile-check hook once they trust it. Claude Code is unchanged, the route is proven on Linux and gated in CI on fakes, and `install-codex.sh` remains a documented fallback.
**Verified:** 2026-10-13T16:30:00Z
**Status:** passed
**Re-verification:** No, initial verification

## Method

The SUMMARY claims were not taken as evidence. I read the shipped files, re-ran the whole suite
(`sh tests/run.sh`, which wraps the CI gates on fakes: `SUMMARY: ok=898 fail=0 skip=0`, matching the
reported CI figure), and read the real-Codex record `08-LINUX-RUN.md` as the only evidence for
facts that CI cannot reach (Codex itself, the `/hooks` trust, the browser sign-in). Codex and BBj
were not run, and no repository file other than this report was changed. The owner-only facts rest
on the verbatim owner replies in the `## Owner pass` and `## Scope decisions` sections of that
record, corroborated by the `hooks_list.py` readings (`trustStatus=trusted`, hash unchanged) and
by `codex mcp list` (Auth `OAuth` on owner-B).

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | CODEX-01: On Linux, `codex plugin marketplace add` and `codex plugin add bbj@basis-bbj` register `bbj-docs` at the literal URL through a `.codex-plugin/plugin.json` overlay pointing at a literal-URL MCP file; both skills load; Claude's `docs_url` option and `claude plugin validate --strict` unchanged | VERIFIED | `plugins/bbj/.codex-plugin/plugin.json` has the 8 allowed keys, the 7 shared fields equal the Claude manifest, `mcpServers` is `./.codex-mcp.json`, no `userConfig`. `plugins/bbj/.codex-mcp.json` holds one `bbj-docs` server, `type http`, `url https://mcp.bbj-ai.com/mcp`, plus the public pre-registered OAuth object (no secret). Real Linux run (`08-LINUX-RUN.md`, "Plugin route: install, docs URL, skills"): `codex mcp list` shows `bbj-docs https://mcp.bbj-ai.com/mcp`, no `bbj-local`; `codex debug prompt-input` lists `bbj:bbj-programming` and `bbj:bbj-web-programming` once each. `git diff 707d881 HEAD` over `plugins/bbj/.claude-plugin`, `plugins/bbj/.mcp.json`, `plugins/bbj/hooks`, `plugins/bbj-local`, `.claude-plugin` is empty (Claude surface unchanged by this phase); the `docs_url` default is still the pre-production URL. Gates `layout_codex_overlay_fields`, `layout_codex_mcp`, `validate_root`, `validate_plugins_bbj`, `validate_plugins_bbj_local` all ok in my run. |
| 2 | CODEX-02: After the `/hooks` trust, the unchanged `hooks/hooks.json` checks every BBj file an `apply_patch` writes: bbjcpl feedback for a bad file, silence for a clean one; a CI gate proves both on fakes | VERIFIED | CI: `plugin_route_cache_layout`, `plugin_route_bad` (exit 2, header names the file, empty stdout, CLAUDE_PLUGIN_ROOT with a space and trailing slash), `plugin_route_dash_n`, `plugin_route_clean` (exit 0, silent), `plugin_route_no_bbj_silent`, `plugin_route_env_clean`, all ok. Real: `## After trust` runs `codex exec` with no bypass flag (`bypass_flag_in_cmd: 0`) in the home the owner trusted (`trustStatus=trusted`, owner reply `trusted: yes`): fake compiler ran once with `-t -N -X -P...`, feedback reached the model once. Bad file with bypass in the scripted run, clean file silent (`feedback_reached_model: no`). |
| 3 | CODEX-03: `bbj-local` stays off until `codex plugin add bbj-local@basis-bbj`; the no-route notice names that command on a plugin-route install, `install-codex.sh --with-local` on an installer install, and keeps its Claude Code wording; gates on fakes cover all three | VERIFIED | `bbj-check.sh` lines 223-226 branch on `[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]` for `apply_patch`: plugin wording `run codex plugin add bbj-local@basis-bbj`, else `rerun install-codex.sh --with-local`. Gates `notice_codex_plugin_route`, `notice_codex_plugin_route_no_other_steps`, `notice_codex_installer_route`, `notice_claude_route_command`, `notice_codex_empty_root`, `notice_codex_plugin_root_not_printed`, `notice_plugin_root_restored`, `notice_codex_text*` all ok. Real: `## Env probe` shows `CLAUDE_PLUGIN_ROOT` set in the hook process (D-07 holds, route marker recorded); no-route run delivered the plugin wording to the model as a developer message; `bbj-local` absent from `codex mcp list` before and present at `http://127.0.0.1:5009/mcp` after `codex plugin add bbj-local@basis-bbj`. `plugins/bbj-local` is unchanged and `defaultEnabled: false` stays in the marketplace entry. |
| 4 | CODEX-04: A gate fails if the Claude `docs_url` default and the Codex literal MCP URL differ, if any manifest (both plugins, both marketplace entries, the overlay) differs in version, or if the hosted host appears in a file other than the two | VERIFIED | `layout_versions` ok (five versions, all 0.2.0), `layout_codex_url_equals_default` ok (exact string equality), `layout_docs_host_single_source` ok (sorted list is exactly `plugins/bbj/.claude-plugin/plugin.json` and `plugins/bbj/.codex-mcp.json`). Self-mutation proofs: 8 `layout_mutation_*` gates ok (trailing slash on either URL, overlay version, extra overlay key, secret in the MCP file, missing MCP file, host in a third file, plus the unchanged control). |
| 5 | CODEX-05: `docs/install-codex.md` leads with the plugin route and keeps `install-codex.sh` as a documented fallback; covers the two commands, the `/hooks` trust step, first-use tool prompts, the `BBJ_HOME` note, and whether an upgrade asks for trust again, as observed | VERIFIED | Headings of `docs/install-codex.md`: `## Install with the Codex plugin (recommended)` at line 26 (before everything else but Requirements), then "Add the marketplace and the plugin", "Trust the hook in /hooks", "Sign in to the docs server", "Tool prompts on first use", "Where the hook finds BBj", "Enable the local check (bbj-local)", "Upgrading the plugin", "Switch from the installer script", and `## Fallback: the installer script` at line 201. The upgrade sentence quotes the 08-LINUX-RUN observation (hash unchanged, no new trust, version-only change) and says what was not run. README names `codex plugin add bbj@basis-bbj` and `bbj-local@basis-bbj`. The trust-bypass flag does not appear in the page or the README (grep for `dangerously` empty). `test_install_pages.sh` gates (`claude_`, `codex_`, `link_`, `readme_`, `installer_`) all ok. |
| 6 | CODEX-06: A user of `install-codex.sh` switches to the plugin route by documented steps or an installer option and ends with exactly one hook entry, one copy of the skills and one `bbj-docs` server, with the installer's `[mcp_servers.bbj-docs]` table no longer overriding the plugin's; verified once on Linux in a throwaway home | VERIFIED | `codex/install-codex.sh --remove` exists (header section R, usage, option parse). 27 `remove_*` gates ok in my run (round trip for every installer-written form, refusals with exit 2, left-in-place matrix with exit 3, idempotent second run). Real: `## Switch from the installer`, order a (install, `--remove` rc 0, plugin commands): 1 hook entry (source plugin), each skill once, one `bbj-docs` at `https://mcp.bbj-ai.com/mcp`, empty `config.toml`. Order b (double install, then `--remove`) shows the failure being fixed (2 hooks, compiler run twice, feedback twice) and then 1 hook, 1 copy of each skill, 1 server with no `mcp_servers` table left behind. Both orders ran twice with the same numbers. Home snapshots before and after confirm the real `~/.codex` and `~/.agents/skills` were untouched. |

**Score:** 6/6 truths verified (0 present, behavior-unverified)

All behavior-dependent truths (the notice branch on `CLAUDE_PLUGIN_ROOT`, the hook outcome per
payload, the `--remove` round trip) have an executed behavioral gate that passed in my own run, plus
a real-Codex observation in the Linux record.

### Deferred Items

None.

### Advisory (carried facts, non-blocking)

These are disclosed in the docs and in `08-LINUX-RUN.md`. They narrow what is claimed; none falsifies a success criterion.

| # | Finding | Why it does not block |
|---|---------|-----------------------|
| 1 | The first-use tool prompt was not watched (the recorded runs called no `bbj-docs` tool); `docs/install-codex.md` says so in the "Tool prompts on first use" section. | SC5 asks that the page cover the prompts; it does, and states the observation limit. The prompt is the accepted trade-off named in ROADMAP Notes. |
| 2 | The shipped `.codex-mcp.json` was not itself signed in on a fresh install; the sign-in succeeded on owner-B with a scratch copy whose parsed JSON equals the shipped file. The page says the sign-in was not repeated on a fresh install. | Same object, recorded `Auth OAuth`, and the fresh install listed `bbj-docs` with the object present. |
| 3 | `codex plugin marketplace add BBj-AI/bbj-agent-plugins` resolves, but the GitHub default branch (`f15c257` on the run date) has no overlay yet, so the shorthand works only after the Phase 8 files are merged there. The page says so and gives the local-checkout form. | Release order belongs to Phase 10 (merge, tag, publish). The route is proven from a local checkout, as SC1 allows ("from a local checkout before release"). |
| 4 | Not run on real Codex: a Git-marketplace upgrade, an upgrade that changes `hooks/hooks.json`, a switch with the hook already trusted, `--remove --docs-url` at another URL (the last is covered by CI gates `remove_custom_url_*`). Windows and macOS are Phase 9. | Disclosed on the page and in the record; the SC6 requirement is "once on Linux in a throwaway home", which was met in two orders. |
| 5 | Order b did not determine which definition (installer table or plugin file) Codex used for the single `bbj-docs` line while both existed. | After `--remove` the installer table is gone and the plugin's is the only definition, which is what SC6 asks. |
| 6 | `plugins/bbj/.mcp.json` changed during the day (quick task 261013-cpn, commit `23f47a1`, adds the Claude OAuth client). It predates the `707d881` baseline of the phase plans and no Phase 8 plan touched it; `claude plugin validate --strict` passes. | Outside Phase 8 scope; Claude Code behavior is unchanged by this phase. |

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `plugins/bbj/.codex-plugin/plugin.json` | Overlay manifest | VERIFIED | Exists, substantive, version 0.2.0, `mcpServers` points at an existing file; read by the real Codex install |
| `plugins/bbj/.codex-mcp.json` | Literal-URL MCP file with the OAuth object | VERIFIED | One server, literal URL, public client id and loopback callback only; installed copy in the Codex cache holds the same content (record) |
| `plugins/bbj/scripts/bbj-check.sh` | Route-aware notice, hook unchanged otherwise | VERIFIED | Branch at lines 223-226; exit contract and static gates ok |
| `codex/install-codex.sh` | `--remove` plus the fallback install | VERIFIED | Option, header docs, usage; 27 remove gates and the existing installer gates ok |
| `docs/install-codex.md`, `README.md` | Plugin route first, fallback kept | VERIFIED | See truth 5 |
| `tests/test_layout.py`, `tests/test_codex_patch.sh`, `tests/test_noroute_notice.sh`, `tests/test_install_codex.sh`, `tests/test_install_pages.sh`, `tests/lib.sh` | Gates | VERIFIED | Executed in my run; gates named above are ok; no test skipped |
| `08-LINUX-RUN.md` and `linux-run/*` | Real-Codex evidence | VERIFIED | Sections present: Env probe, plugin route, notice, bbj-local, shorthand, Owner pass, Scope decisions, OAuth outcome, Route marker, After trust, Upgrade trust, Switch |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| `.codex-plugin/plugin.json` | `.codex-mcp.json` | `mcpServers: "./.codex-mcp.json"` | WIRED | Gate checks existence; real install registered the server from it |
| `.codex-mcp.json` url | Claude `docs_url` default | exact string equality | WIRED | `layout_codex_url_equals_default` ok and mutation-proven |
| `bbj-check.sh` notice | route (`CLAUDE_PLUGIN_ROOT`) | non-empty test | WIRED | Real probe confirmed the variable reaches the hook |
| plugin `hooks/hooks.json` | `bbj-check.sh` in the Codex cache | `${CLAUDE_PLUGIN_ROOT}` | WIRED | Real runs executed it from `plugins/cache/basis-bbj/bbj/0.2.0` |
| `install-codex.sh --remove` | docs "Switch" section | documented command and exit codes | WIRED | Page pins four removal messages that are printed on non-comment installer lines |

### Data-Flow Trace (Level 4)

Not applicable: no rendered dynamic data. The only values that flow are the hook's compiler lines
to stderr, traced end to end by the real run (compiler argv, then the feedback in the next request).

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Full suite on fakes | `sh tests/run.sh` | `SUMMARY: ok=898 fail=0 skip=0` | PASS |
| Phase gate families | grep of the run transcript | layout_codex 3/3, layout_mutation 8/8, plugin_route 6/6, notice_* all, remove_ 27/27, validate_ 3/3 | PASS |
| Claude surface unchanged | `git diff 707d881 HEAD -- plugins/bbj/.claude-plugin plugins/bbj/.mcp.json plugins/bbj/hooks plugins/bbj-local .claude-plugin` | empty | PASS |
| SUMMARY commit hashes exist | `git cat-file -e` over every 7-hex id in the eight SUMMARY files | all are commits | PASS |

### Probe Execution

No `probe-*.sh` files are declared or exist for this phase. SKIPPED. (The hook's own scripted real-Codex runs are recorded in `08-LINUX-RUN.md`; `linux-run/run.sh` selftest refusals are part of that record.)

### Requirements Coverage

Plan frontmatter `requirements:` across the eight plans: 08-01 [CODEX-01, 02, 04]; 08-02 [CODEX-03]; 08-03 and 08-04 [CODEX-06]; 08-05 [CODEX-01, 02, 03, 05]; 08-06 [CODEX-02, 05, 06]; 08-07 [CODEX-05, 06]; 08-08 [CODEX-01, 02, 03]. Union equals CODEX-01 to CODEX-06. REQUIREMENTS.md maps exactly these six IDs to Phase 8; no orphaned requirement.

| Requirement | Source Plans | Description | Status | Evidence |
| ----------- | ------------ | ----------- | ------ | -------- |
| CODEX-01 | 08-01, 08-05, 08-08 | Plugin install registers `bbj-docs` at a working URL, skills load, Claude unchanged | SATISFIED | Truth 1 |
| CODEX-02 | 08-01, 08-05, 08-06, 08-08 | Hook after `/hooks` trust checks `apply_patch` files, proven on fakes in CI | SATISFIED | Truth 2 |
| CODEX-03 | 08-02, 08-05, 08-08 | `bbj-local` opt-in; notice names the right command per route | SATISFIED | Truth 3 |
| CODEX-04 | 08-01 | URL, version and hosted-host gates | SATISFIED | Truth 4 |
| CODEX-05 | 08-05, 08-06, 08-07 | Install page leads with plugin route, fallback kept, observed facts | SATISFIED | Truth 5 |
| CODEX-06 | 08-03, 08-04, 08-06, 08-07 | Switch from installer, one hook, one skill copy, one server, verified on Linux | SATISFIED | Truth 6 |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| (all files changed by the phase) | - | `TBD`, `FIXME`, `XXX` in added lines | none found | No debt markers |
| `.codex-mcp.json`, `plugin.json` | - | placeholders or empty data | none found | Files hold real values |

### Human Verification Required

None. The two owner-only facts, the `/hooks` trust and the browser sign-in, are covered by the
owner's verbatim replies in `## Owner pass` (`trusted: yes`, `B: signed in`) and `## Scope
decisions` (`signin: add-block`), and by the `hooks_list.py` and `codex mcp list` readings that
follow them. The record does not leave a must-have open. The optional end-of-phase look at the
`/hooks` TUI named in `## Upgrade trust` reads the same data that `hooks_list.py` already reported
and is not a gate.

### Gaps Summary

No gaps. Each of the six success criteria holds in the code, in the CI gates (re-run here, 898 ok,
0 fail, 0 skip), and, for the facts CI cannot see, in a dated real-Codex record that discloses its own limits. The
open items listed under Advisory are scope notes the documentation already states, and the
remaining platform and release work belongs to Phases 9 and 10.

---

_Verified: 2026-10-13T16:30:00Z_
_Verifier: Claude (gsd-verifier)_
