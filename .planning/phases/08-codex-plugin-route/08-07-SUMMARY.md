---
phase: 08-codex-plugin-route
plan: 07
subsystem: codex-install-docs
tags: [codex, plugin-route, docs, install-codex, switch, remove, pins, gate-prefix]

requires:
  - phase: 08-codex-plugin-route
    provides: "08-LINUX-RUN.md (install, hook trust, sign-in, upgrade trust, double install, bbj-local opt-in, marketplace shorthand), 08-08 scope decisions (signin add-block, route d07-holds, trust yes), 08-03/08-04 install-codex.sh --remove, plugin_route_ gates of 08-01"
provides:
  - "docs/install-codex.md leading with '## Install with the Codex plugin (recommended)', the switch section, the optional plugin-scoped pre-approval (untried), and '## Fallback: the installer script' at 122 lines"
  - "README.md naming the Codex plugin route and bbj-local through codex plugin add"
  - "tests/test_install_pages.sh pins for the plugin route, switch, fallback, twelve quoted installer messages and the hook_trust_bypass forbid on the Codex page and README"
  - "gate-prefix block with plugin_route_ and remove_, byte-identical in .claude/CLAUDE.md and .planning/codebase/CONVENTIONS.md"
  - "phase gate: sh tests/ci.sh ends SUMMARY ok=898 fail=0 skip=0 and CI SUMMARY ok=6 fail=0 run_sh_exit=0"
affects: [phase-09-platform-runs, phase-10-release-wording, CODEX-05, CODEX-06]

actuals:
  tokens: 7996
  tasks: 3
  commits: 3
plan_head_before: 4d07d33bb0615814d5b96b8adfb07d771a6c3bb1
plan_head_after: 973cb686a5f76e4dece4009eaef8abf4333d1eb1

tech-stack:
  added: []
  patterns:
    - "Every Codex-side fact on the page is either copied from 08-LINUX-RUN.md (the upgrade sentence verbatim, checked by a verify command) or labelled not run / not tried / not determined"
    - "The hook-trust bypass flag of codex exec is named in the test file by its stem only and forbidden on the Codex page and README"

key-files:
  created:
    - .planning/phases/08-codex-plugin-route/08-07-SUMMARY.md
  modified:
    - docs/install-codex.md
    - README.md
    - tests/test_install_pages.sh
    - .claude/CLAUDE.md
    - .planning/codebase/CONVENTIONS.md

key-decisions:
  - "The double-install paragraph says the installer's registration and the plugin's server share the name, that an earlier trial showed a config.toml table replacing the plugin's server, and that which definition Codex used in the double-install run was NOT determined (the record says so); the plan text said 'replacing' outright"
  - "First-use tool prompts are stated as what follows from the plugin shipping no approvals, with the plain note that the recorded Linux runs did not call a bbj-docs tool, so the prompt was not watched"
  - "The sign-in section follows signin add-block: the plugin carries the pre-registered client; the --no-browser paste-back and port 47613 on the Codex machine are stated as observed on a scratch copy; the sign-in on the plugin exactly as it ships is stated as not repeated"
  - "Windows section adds only that the plugin route is not yet run there and hooks/hooks.json has no commandWindows entry (Phase 9 runs it); no Windows or macOS wording was otherwise changed (Phase 10 rewrites it)"
  - "Commit attribution follows the harness reminder (Claude Sonnet 5.5); the dispatch text named Fable 5.1, so the three commit messages were rewritten (message only) before the SUMMARY, same as 08-06"

patterns-established:
  - "Gate-prefix block mirrored byte for byte in two files, checked with the awk compare of Phase 07"

requirements-completed: [CODEX-05, CODEX-06]

coverage:
  - id: D1
    description: "docs/install-codex.md leads with the plugin route: both install commands, local-checkout form, /hooks trust, sign-in, first-use prompts, BBJ_HOME, bbj-local opt-in, upgrade-trust sentence copied from the record, and its own 'Verified on Linux with Codex CLI 0.162.1 on 2026-10-13' line"
    requirement: "CODEX-05"
    verification:
      - kind: integration
        ref: "sh tests/test_install_pages.sh (codex_has_* pins incl. codex_has_codex_plugin_add_bbj_basis_bbj; codex_forbids_codex_verified_claim)"
        status: pass
      - kind: integration
        ref: "python3 -I tests/test_release_text.py (release_codex_version_single: one version, 0.162.1)"
        status: pass
      - kind: other
        ref: "grep -F of the upgrade sentence of 08-LINUX-RUN.md on the squashed page: count 1"
        status: pass
    human_judgment: false
  - id: D2
    description: "The switch is documented: sh codex/install-codex.sh --remove with its options, exit codes, left-in-place cases, what stays, the observed result after the two plugin commands, the observed double install, and the untried plugin-scoped pre-approval key"
    requirement: "CODEX-06"
    verification:
      - kind: integration
        ref: "sh tests/test_install_pages.sh (codex_quoted_messages_in_installer: twelve fragments on the page and on non-comment installer lines)"
        status: pass
    human_judgment: true
    rationale: "Whether the prose reads clearly to an installer user, and that every sentence matches the record, is a reading check; the gates pin phrases, not meaning"
  - id: D3
    description: "Installer section shortened to 122 lines (limit 140) with options table incl. --remove, exit codes incl. remove mode, and every pinned 0.2.0 phrase kept; banner byte for byte"
    requirement: "CODEX-05"
    verification:
      - kind: other
        ref: "awk '/^## Fallback: the installer script$/{f=1;print;next} f&&/^## /{exit} f' docs/install-codex.md | wc -l -> 122; BANNER_KEPT against 707d881"
        status: pass
    human_judgment: false
  - id: D4
    description: "Neither the Codex page nor README recommends the hook-trust bypass; README names codex plugin add bbj@basis-bbj and bbj-local@basis-bbj and keeps the version line and 'not yet run on Windows or macOS'"
    requirement: "CODEX-05"
    verification:
      - kind: integration
        ref: "sh tests/test_install_pages.sh (codex_forbids_hook_trust_bypass, readme_forbids_hook_trust_bypass, readme_has_codex_plugin_add_bbj_basis_bbj); python3 -I tests/test_release_text.py (release_readme_version)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Gate-prefix block lists plugin_route_ (test_codex_patch.sh) and remove_ (test_install_codex.sh) identically in both files; phase gate green"
    verification:
      - kind: other
        ref: "awk compare of the block in .claude/CLAUDE.md and .planning/codebase/CONVENTIONS.md: equal; sh tests/ci.sh: SUMMARY ok=898 fail=0 skip=0, CI SUMMARY run_sh_exit=0, plugin_route_ 6 ok, remove_ 27 ok, strict validation of root and both plugins ok, shellcheck ok"
        status: pass
    human_judgment: false

duration: 36min
completed: 2026-10-13
status: complete
---

# Phase 8 Plan 07: Codex install page rewrite Summary

**The Codex page now opens with the plugin route (two commands, /hooks trust, sign-in with the shipped OAuth client, first-use prompts, BBJ_HOME, bbj-local opt-in, observed upgrade trust), documents the `--remove` switch and the observed double install, and keeps the installer as a 122-line fallback with every 0.2.0 pin intact.**

## Performance

- **Duration:** about 36 min
- **Started:** 2026-10-13T15:17Z (approximate; the commit ledger was created at 15:48 on the first commit)
- **Completed:** 2026-10-13T15:55Z
- **Tasks:** 3
- **Files modified:** 5 (301 insertions, 143 deletions)

## Accomplishments

- `docs/install-codex.md` is restructured: Requirements, plugin route (marketplace and plugin, hook trust, sign-in, first-use prompts, `BBJ_HOME`, bbj-local, upgrading, switch, optional pre-approval), AGENTS.md snippet (both routes), shortened installer fallback, Check routes, Not covered, Windows. The title and banner are byte for byte the 707d881 text.
- Facts come from `08-LINUX-RUN.md`: the upgrade sentence is copied verbatim (verified by the plan's grep), the verified line carries the run date 2026-10-13, the shorthand `BBj-AI/bbj-agent-plugins` is documented as resolving but cloning a default branch with no Codex files until the release is merged, and the two `--remove` outcome sentences and the double-install symptoms are the recorded ones.
- Things no run showed are written as such: tool prompts not watched, plugin-scoped approval key "from the Codex documentation, not tried here", Git-marketplace upgrade and hook-definition upgrade "not run", which `bbj-docs` definition won in the double install "not determined", Windows and macOS "not yet run".
- `tests/test_install_pages.sh` gains the plugin-route pins, the switch, fallback and AGENTS headings, `sh codex/install-codex.sh --remove`, the plugin-scoped key, the README pins, four more quoted installer messages (twelve in all, each on the page and on a non-comment installer line) and `hook_trust_bypass` forbids on the Codex page and README.
- `README.md` names the Codex plugin route, `codex plugin add bbj-local@basis-bbj`, the sign-in outcome, and keeps its version line.
- The gate-prefix block lists `plugin_route_` and `remove_` and is byte-identical in the two files.

## Task Commits

1. **Task 1: plugin-route section and its pins** - `9d3a2dd` (docs). This commit holds the whole page rewrite, so it also carries the Task 2 page content (switch, fallback, check-route and Windows lines) that was written in one pass.
2. **Task 2: README, remaining pins, bypass forbid** - `0b6f00b` (docs)
3. **Task 3: gate-prefix block in both files** - `973cb68` (docs)

**Plan metadata:** committed separately with this SUMMARY, STATE.md and ROADMAP.md.

## Files Created/Modified

- `docs/install-codex.md` - plugin route first, switch section, shortened installer fallback
- `README.md` - Codex plugin route lines and sign-in outcome
- `tests/test_install_pages.sh` - new pins, twelve quoted messages, bypass forbid, header comment
- `.claude/CLAUDE.md`, `.planning/codebase/CONVENTIONS.md` - prefix block with `plugin_route_` and `remove_`

## Decisions Made

See `key-decisions` above. The two worth repeating: the double-install paragraph states the not-determined fact instead of asserting a replacement, and the sign-in section stops at what the owner's scratch-copy sign-in and the fresh-install `Not logged in` reading show.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Accuracy] Double-install wording**
- **Found during:** Task 2 (switch section)
- **Issue:** the plan said the double install shows "the installer's bbj-docs table replacing the plugin's server", but `08-LINUX-RUN.md` records that which definition Codex used was not determined; asserting it would break the page's own rule (state only what a run showed).
- **Fix:** the page says the registrations share a name, mentions the earlier trial where a `config.toml` table replaced the plugin's server, and says the double-install run did not determine which definition was used.
- **Files modified:** docs/install-codex.md
- **Committed in:** 9d3a2dd

**2. [Plan defect] Task 3 first verify counts lines**
- **Found during:** Task 3
- **Issue:** `grep -c 'plugin_route_\|remove_'` counts matching lines. The plan puts both prefixes on the one "Shell tests" line, so the count is 1 and the `fails_when` "less than 2" would trip although both prefixes are present.
- **Fix:** none to the files; checked with `grep -o ... | wc -l`, which prints 2; the mirror compare printed neither BLOCK_MISSING nor MIRROR_DIFFERS.
- **Committed in:** 973cb68 (no content change needed)

**3. [Process] Page content of Task 2 landed in the Task 1 commit**
- The page was rewritten in one pass because the sections cross-reference each other and the page gates only pass on the whole; the Task 2 commit holds the README and the remaining pins.

**4. [Process] Commit attribution**
- The dispatch asked for `Claude Fable 5.1`; the harness attribution reminder says `Claude Sonnet 5.5`. The three commit messages were first written with the dispatch text, then rewritten (message only, local unpushed commits, no tree change) to the harness line, as plan 08-06 did.

---

**Total deviations:** 1 accuracy fix, 1 plan defect, 2 process notes
**Impact on plan:** none on scope; the page is slightly more careful than the plan text where the record is silent.

## Issues Encountered

- The phrase pin `PREFIX, classpath and config` failed once because a line wrap split it; the sentence was re-wrapped (phrase pins are per line).
- `sh tests/ci.sh` runs longer than two minutes; it was run in the background and read from its output file.

## Authentication Gates

None.

## Known Stubs

None. No placeholder text, empty data flows or TODO markers in the changed files.

## Threat Flags

None. Docs, tests and planning files only; no new endpoint, auth path or file access.

## Self-Check: PASSED

- docs/install-codex.md, README.md, tests/test_install_pages.sh, .claude/CLAUDE.md, .planning/codebase/CONVENTIONS.md present and changed in 9d3a2dd, 0b6f00b, 973cb68 (all three are ancestors of HEAD).
- Plan acceptance: banner kept; plugin heading line 26 before fallback heading line 201; one switch heading; README version line and `not yet run on Windows or macOS` present; fallback 122 lines; `Upgrading from an earlier install` and `self-registration` count 0; `dangerously-bypass` count 0 on page and README, 1 in the test; `release_readme_version` ok and `release_codex_version_single` ok.
- Scope record: signin=add-block (`B: signed in` present), route=d07-holds (`## Route marker` present), trust=yes (`trusted: yes` present).
- No Claude Code file or version changed: `git diff --quiet 707d881 -- plugins/bbj/.claude-plugin/plugin.json plugins/bbj/.mcp.json plugins/bbj/hooks/hooks.json` exits 0; no `0.2.1` under plugins, .claude-plugin or tests/test_layout.py.
- Phase gate: `sh tests/ci.sh` exit 0, SUMMARY ok=898 fail=0 skip=0, CI SUMMARY ok=6 fail=0 run_sh_exit=0.

## Next Phase Readiness

Phase 8 has no further plan. Phase 9 follows this page on Windows and macOS; Phase 10 rewrites the platform wording once from the recorded runs. Open facts the page states as not run: hook-definition upgrade, Git-marketplace upgrade, tool prompt appearance, the sign-in on a fresh install of the plugin as it ships, and which `bbj-docs` definition wins in a double install.

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*
