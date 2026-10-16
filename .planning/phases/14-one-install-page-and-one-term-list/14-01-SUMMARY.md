---
phase: 14-one-install-page-and-one-term-list
plan: 01
subsystem: docs
tags: [install-page, markdown, sh-tests, layout-gate, link-gate, release-text]

requires:
  - phase: 13-windows-hook-fixes
    provides: record-backed Windows sentences (13-WINDOWS-RUN.md "For the install page") the merged page carries
  - phase: 11-installer-removal
    provides: frozen CHANGELOG entries (D-03) and the integer-tuple history cut the new gates reuse
provides:
  - docs/install.md, the one plugin-only install page for Claude Code and Codex (eleven D-01 headings, exact order gated)
  - README install path of two commands per client with a link to the page
  - page pins, release-text gates and their mutation proof reading docs/install.md
  - link gates that skip only frozen CHANGELOG history (entries 0.2.1 and older), with two proof gates
  - layout_no_removed_pages with six mutation cases
affects: [14-02 claim trace and Verified table, 14-03 term gate, 14-05 prefix block, 14-06 sweep, 14-08 map refresh]

actuals:
  tokens: 11100
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "One page, one pin list per client prefix: claude_ and codex_ pins both run on $PAGE so each prefix still names the client whose reader it protects"
    - "check_links FILE function, run on a scratch CHANGELOG to prove the history cut from both sides"
    - "Removed-page names assembled from pieces in REMOVED_PAGES (self-scan convention)"

key-files:
  created:
    - docs/install.md
  modified:
    - README.md
    - tests/test_install_pages.sh
    - tests/test_release_text.py
    - tests/test_release_text_mutation.sh
    - tests/test_layout.py
    - .claude/CLAUDE.md
  deleted:
    - docs/install-claude-code.md
    - docs/install-codex.md

key-decisions:
  - "Shared forbids run on the one page under both the claude_ and codex_ prefixes, so no existing forbid gate name disappears"
  - "The 12-second paragraph moves from the Codex Windows section to Check routes, once; it is worded for a Codex patch because only apply_patch touches several files"
  - "The two retired-variant page-pin names are replaced by pins of '## 4. Enable the plugin `bbj-local`' (D-11)"
  - "Earlier-state text dropped from the Codex material (P14, 12 D-12, 13 D-21): no plugin version, no 'gained a commandWindows entry', no 'before the plugin carried'; the record-backed hook-trust facts stay"
  - "Only one README pin leaves the README list (the docs_url sentence, now pinned on the page under codex_); every other README pin still holds"

patterns-established:
  - "History cut in the link loop: awk drops '## X.Y.Z' entries up to 0.2.1 by integer comparison and keeps any other '## ' line (fail closed)"

requirements-completed: [DOCS-05]

coverage:
  - id: D1
    description: "docs/install.md is the one install page for both clients with the eleven D-01 headings in order, client commands in adjacent labelled blocks"
    requirement: DOCS-05
    verification:
      - kind: integration
        ref: "sh tests/test_install_pages.sh#claude_sections"
        status: pass
    human_judgment: false
  - id: D2
    description: "The merged page keeps every record-backed sentence and the Windows text of 13-06, says nothing twice, names no earlier plugin state"
    requirement: DOCS-05
    verification: []
    human_judgment: true
    rationale: "Whether a merged sentence still matches its run record is a reading task; plan 14-02 traces every Observed/Verified/Not run line to a record line"
  - id: D3
    description: "Both old pages are deleted with no stub; no tracked file outside .planning/ and the frozen 0.2.0 CHANGELOG line names them"
    requirement: DOCS-05
    verification:
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_no_removed_pages"
        status: pass
    human_judgment: false
  - id: D4
    description: "Page pins, release-text gates and their mutation proof read docs/install.md; link gates skip only frozen CHANGELOG history"
    requirement: DOCS-05
    verification:
      - kind: integration
        ref: "sh tests/test_release_text_mutation.sh#release_mut_no_unrun_hint_install_page"
        status: pass
      - kind: integration
        ref: "sh tests/test_install_pages.sh#link_history_cut_newer_entry"
        status: pass
    human_judgment: false

duration: 14min
completed: 2026-10-16
status: complete
plan_head_before: 212abbe75349ad7c61563c7f22faa23f21d8d69a
plan_head_after: 20c9ce09044410e4cb7051838c242552ee1b0987
commits: 2
---

# Phase 14 Plan 01: One install page for Claude Code and Codex Summary

**docs/install.md replaces both per-client install pages with one step-by-step page (eleven gated headings, Claude Code and Codex commands side by side), and every reader of the old pages plus a new layout gate keep the removed names out of the tree.**

## Performance

- **Duration:** 14 min
- **Started:** 2026-10-16T07:38:00Z
- **Completed:** 2026-10-16T07:52:00Z
- **Tasks:** 2
- **Files modified:** 9 (1 created, 2 deleted, 6 modified)

## Accomplishments

- `docs/install.md` (502 lines) holds the eleven D-01 headings in order. Each numbered step shows the Claude Code and the Codex command in adjacent fenced blocks, each preceded by `Claude Code:` or `Codex:`. Client-only text sits under `### Codex: ...` headings or in labelled sentences inside its step (Codex `/hooks` trust, tool prompts, pre-approving the five docs tools, the Codex daemon environment for `BBJ_HOME`, the Claude Code `docs_url` option).
- The page is written to the term list from the start: checks named by tool (the `bbjcpl` check, `bbj-ls`, the hosted check), no "tier", none of the five retired variants, "language server" only in the one definition line. The duplicate sentences of the two pages occur once (`error at line 10 (1)`, the Git Bash real-compiler paragraph, the 12-second paragraph, which now sits under Check routes).
- README keeps two commands per client, one sentence on sign-in and the Codex hook trust, and links the page; the docs_url paragraph and the two-pages list are gone.
- Page pins (`claude_`, `codex_`, `readme_`, `link_`), `claude_sections` as an exact heading-order check, the release-text gates (`upgrade_install_page`, `codex_version_single`, `claude_version_single`, `no_unrun_hint`) and their mutation proof (`release_mut_no_unrun_hint_install_page`, `..._linux_only`) all read the new page.
- The link loop is now `check_links FILE` with a CHANGELOG history cut; `link_history_cut_newer_entry` and `link_history_cut_old_entry` prove on a scratch CHANGELOG that a missing page in a newer entry still fails and one in a 0.2.1 entry is skipped.
- `layout_no_removed_pages` (path and text, case-insensitive, same CHANGELOG cut) with six `layout_mutation_removed_page_*` cases; the two `plant()` cases that would have recreated a removed page now target `docs/install.md`.

## Task Commits

1. **Task 1 (tracer): One page through every reader** - `8964694` (docs)
2. **Task 2: Old pages deleted; link cut; layout_no_removed_pages; CLAUDE.md** - `20c9ce0` (docs)

**Plan metadata:** committed after this file (docs: complete plan).

Tracer gate: the Task 1 `<verify>` was re-run end to end before Task 2 started and passed (`ok`, `sh tests/run.sh` SUMMARY `ok=798 fail=0 skip=0`). After Task 2 the suite ends `ok=803 fail=0 skip=0`.

## Files Created/Modified

- `docs/install.md` - the one install page
- `README.md` - install path per client, link to the page (part above `## Verified` only)
- `tests/test_install_pages.sh` - `PAGE=$DOCS/install.md`, both pin lists, exact heading check, `check_links`, history cut and its proof gates
- `tests/test_release_text.py` - four gates and `HINT_FILES` read `docs/install.md`; docstring updated
- `tests/test_release_text_mutation.sh` - `fresh_root` copies the page; five mutate lines and two renamed hint cases
- `tests/test_layout.py` - `REMOVED_PAGES`, `layout_no_removed_pages`, six new mutation cases, two repointed
- `.claude/CLAUDE.md` - four code spans now name `docs/install.md`
- `docs/install-claude-code.md`, `docs/install-codex.md` - deleted (`git rm`)

## Decisions Made

See the key-decisions list above. Two judgment calls worth knowing:

- The Claude page sentence "A PowerShell version of the hook is a possible later addition" is kept but scoped "For Claude Code", since Codex already runs a PowerShell entry. It is not a run-record claim; it was kept to avoid dropping text.
- The merged drive-letter paragraph says the home was found "through `bbj_home` in the Claude Code run", which is how the Claude page worded it; the Codex page said only "was found". The union does not add a claim either record lacks.

## Deviations from Plan

None - plan executed exactly as written.

Minor non-deviations: two lines the first draft got wrong were corrected before the first commit (a hard wrap that split the pinned phrase "once per session", and an overstated "in Codex, the only way" for setting `BBJ_HOME`, now "Codex has no plugin options").

**Commit attribution:** the dispatch prompt asked for a `Co-Authored-By: Claude Opus 5.5` trailer; the harness attribution reminder names `Claude Sonnet 5.5`, the model that ran this plan. The commits carry the Sonnet 5.5 line.

## Authentication Gates

None.

## Issues Encountered

- Right after the `git rm`, `layout_no_removed_pages` failed on `.claude/CLAUDE.md`, which still named the old pages. This is the gate working; the four lines were the plan's own step 4, done before the commit.

## Known Stubs

None. No placeholder text or empty data sources in the files touched.

## Threat Flags

None. The page and tests add no network endpoint, auth path or file-access pattern. T-14-02 and T-14-03 mitigations hold: `codex_forbids_hook_trust_bypass` runs on the new page and `codex_has_and_for_nothing_else` pins the pre-approval limit.

## Next Phase Readiness

- Ready for 14-02: the page's "Observed on" / "Verified on" / "Not run" lines are unchanged in wording from the two old pages, so the claim trace can run against them.
- For 14-03 (term gate): the page and the README part above `## Verified` are already clean of the retired variants; the README `## Verified` section and `## The check hook` still use "second route" and "compiler check" and are 14-02's and 14-03's.
- For 14-05 (prefix block): new gate names printed by this plan are `link_history_cut_newer_entry`, `link_history_cut_old_entry` (prefix `link_`) and `layout_no_removed_pages`, `layout_mutation_removed_page_*` (prefix `layout_`); no new prefix is needed.
- Runtime state, no repo action: the published GitHub Release 0.2.0 body links the removed pages; the owner may edit it outside the tree (RESEARCH A2).

## Self-Check: PASSED

- docs/install.md, README.md, the four test files and .claude/CLAUDE.md exist; both old pages are gone from disk and index.
- Commits `8964694` and `20c9ce0` are ancestors of HEAD.
- Both task `<verify>` commands print `ok`; acceptance criteria re-run: heading list, definition line once, no retired variants, no tier words, no plugin version, three once-only sentences, 12-second paragraph between `## Check routes` and `## Not covered`, `git ls-files docs` prints only `docs/install.md`, the only `git grep` hit outside `.planning/` is CHANGELOG.md line 187, `sh tests/run.sh` ends `ok=803 fail=0 skip=0`.
