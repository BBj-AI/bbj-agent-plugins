---
phase: quick-261017-e2f
plan: 01
subsystem: documentation
tags: [handoff, dev-training, course, fact-check]
requires: []
provides:
  - TRAINING-HANDOFF.md: subjects, placement map, new pages, out-of-date course text for the dev-training maintainers
  - check_handoff.py: stdlib checker for the handoff's structure, paths, headings, URLs, terms and the read-only course repository
affects: []
tech-stack:
  added: []
  patterns: ["gate NAME ok|FAIL DETAIL lines, python3 -I, stdlib only"]
key-files:
  created:
    - .planning/quick/261017-e2f-training-material-handoff-for-dev-traini/TRAINING-HANDOFF.md
    - .planning/quick/261017-e2f-training-material-handoff-for-dev-traini/check_handoff.py
  modified: []
decisions:
  - "Two new reference pages proposed (12-how-the-plugin-works, 13-plugin-dos-and-donts); no new module segment, because the numeric prefix sets the order and a segment would force renaming later pages"
  - "The course should keep owning the commands on its setup sheet and link to docs/install.md for everything else"
status: complete
completed: 2026-10-17
plan_head_before: 84089f876ded06f5bc0af8ce76691219396c2d71
plan_head_after: a387222f4ad905a43373b5cf942f20ec02ea35b8
commits: 3
actuals:
  tokens: 22800
  tasks: 3
  commits: 3
---

# Phase quick-261017-e2f Plan 01: Training-material handoff for dev-training Summary

A 75 KB handoff (`TRAINING-HANDOFF.md`) tells the dev-training maintainers what to teach about the `basis-bbj` plugins, where each piece goes in the course (24 placement rows, every one resolved to a real file and heading), which two reference pages to add, and 37 places where course text contradicts release 0.2.2 or has no backing source. `check_handoff.py` checks it mechanically.

## Tasks

| Task | Name | Commit |
|------|------|--------|
| 1 | Checker plus the check hook end to end (tracer) | 0c75073 |
| 2 | All subjects, placement map, new pages, out-of-date text | 18d099d |
| 3 | Fact check against the sources | a387222 |

The tracer gate passed (`check_handoff.py tracer`, all gates ok) before Task 2 expanded.

## Final gate results (`check_handoff.py full`)

```
gate handoff_headings ok h2 in order, h3 in order
gate handoff_paths ok 372 path tokens, missing: none
gate handoff_sections ok 153 headings, missing: none
gate handoff_anchors ok 18 anchors, unknown: none
gate handoff_urls ok 6 urls, not in any source: none
gate handoff_hygiene ok hits: none
gate handoff_terms ok retired terms outside section 6: none
gate handoff_clean ok course status clean, HEAD c41996d (baseline c41996d)
gate handoff_filled ok sections with fewer than 3 body lines: none
gate handoff_table_rows ok section 4 has 24 data rows (need 12), section 6 has 37 (need 3)
gate handoff_subjects ok 25 identifiers, missing from section 3 or from the shipped files: none
gate handoff_version ok plugin version 0.2.2 named in the handoff
```

Also: `git diff --quiet HEAD -- . ':(exclude).planning'` clean, `python3 -I tests/test_layout.py` prints no FAIL gate, dev-training `git status --porcelain` empty at c41996d. The gates were mutation-tested on scratch copies (bad path, bad heading, unknown URL, e-mail, `/home/`, retired terms all fail).

## Fact check (Task 3)

About 187 claim units read against their cited source (96 list items of sections 2 and 3, 16 do/don't rows, 24 placement rows, 37 out-of-date rows, 14 open items). Every section 6 course quote was also checked by script, against the cited file and under the cited heading.

- Verified: the large majority; no source contradicted a claim.
- Fixed: 20 (source attribution on the diagram and tool purposes, the undeclared-variable condition, "-N writes no output" source, Windows/macOS home wording, the run-a-program rule now sourced to `skills/bbj-programming/references/running.md`, OAuth-copy rationale marked as a recommendation, the renaming inference marked, three quote-markup mismatches, the Exercise 3C clean-check row, the COURSE-NOTES quote, the data-handling citation, section 1 wording on maintainer records).
- Marked `Unverified:`: 22 marks, 12 distinct items in section 7 (hosted check status, style label, identity footer, `BBj.properties` key, PREFIX/classpath for the compiler, hand install, finality of the address, minimum BBj for `bbjcpl`, Codex pre-approval key, Codex prompt not watched, `bbj_format`/`bbj_denum` purpose and `bbj-ls` answer wording, plus the pending-todo items).
- Removed: 1 overclaim (a draft sentence that "Hook failed" on Windows always means `sh` was not found), replaced before commit by the install page's wording.

## Most important findings for the course maintainers

1. The course never mentions the one-time OAuth sign-in to the docs server (`/mcp`, `codex mcp login bbj`, port 47613 free); before it, `claude mcp list` shows `Needs authentication` and `codex mcp list` shows `Not logged in`. The data-handling page says "no accounts, no sign-in".
2. The Codex script route and the `AGENTS.md` snippet are gone (present in tag 0.2.1, absent in 0.2.2). `reference/01-mcp-setup-sheet.mdx`, `reference/11-course-reference-sheet.mdx`, `module-3/03` and `COURSE-NOTES.md` still teach it; the Codex route is `codex plugin marketplace add` plus `codex plugin add bbj@basis-bbj`, then the sign-in and the `/hooks` trust.
3. The docs server's old name is in `module-3/04`, `reference/01`, `02`, `03`, `07` (link text), `08`, `11` and `COURSE-NOTES.md`; it is `bbj` now (`plugin:bbj:bbj` in Claude Code).
4. The check hook: the course says it needs the language server switched on and reports "where it ran and which BBj version" when clean. The hook tries `bbjcpl` first, falls back to `bbj-ls`, is silent on a clean file, and gives a once-per-session notice when neither answers (the course says "silent by design").
5. "Skills are a Claude Code format" (`module-2/06`, `module-3/03`) is wrong: Codex lists both skills from the plugin. The `bbj-web-programming` description in the course is much narrower than the skill.
6. The course's server addresses (`COURSE-NOTES.md`) differ from the manifests' `https://mcp.bbj-ai.com/mcp`, and the setup sheet holds no server address at all.
7. Open for BASIS: whether the hosted check is deployed, the style label and identity footer (no repo file backs them), and the `BBj.properties` key name (its port 5008 is correct: language-server RPC 5008, MCP 5009, per the project owner on 2026-10-17).
8. The install page assumes the `claude` CLI while the course installs Claude Code as a VS Code extension; whether the plugin works from the extension alone is an open, unverified todo of the plugin repository.

## Deviations from Plan

None - plan executed as written. Additions beyond the plan: a `handoff_anchors` gate (GitHub anchors of `bbj-agent-plugins/<file>.md#anchor` tokens) and a `handoff_table_rows` split from `handoff_filled`; the checker treats a backticked token containing `<` as a placeholder, not a path.

Execution notes: commits were made on `main` as the orchestrator instructed (the protected-branch guard of the commit protocol would otherwise refuse; project history is committed directly to `main`). The commit trailer is the one the harness named for this session, `Co-Authored-By: Claude Sonnet 5.5`, not the `Claude Opus 5.5` line in the dispatch text.

## Known Stubs

None. (No code was shipped; the handoff has no placeholder text.)

## Threat Flags

None. No shipped file, network endpoint or trust boundary changed; dev-training stayed read only and clean.

## Self-Check: PASSED

- FOUND: TRAINING-HANDOFF.md, check_handoff.py
- FOUND commits: 0c75073, 18d099d, a387222
