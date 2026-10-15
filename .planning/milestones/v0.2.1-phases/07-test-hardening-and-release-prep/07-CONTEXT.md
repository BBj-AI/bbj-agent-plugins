# Phase 7: Test hardening and release prep - Context

**Gathered:** 2026-10-12
**Status:** Ready for planning

<domain>
## Phase Boundary

A maintainer gets a green `sh tests/run.sh` on a machine that has `bbjcpl`/`bbjcplw` on `PATH`
(MAINT-06) or a running Codex daemon (MAINT-07). The gate-prefix list in the project notes
matches what the suite prints (MAINT-08). The four 0.2.0 review-fix commits are in the tree that
becomes 0.2.1 (REL-05), and the CONTENT_VERSION policy of `tests/test_release_text.py` is
decided, implemented and recorded (REL-06). No version bump, no CHANGELOG 0.2.1 entry, no
Codex plugin work: those belong to Phases 8 and 10. Tests use fakes only; nothing runs BBj.

</domain>

<decisions>
## Implementation Decisions

### Release tree (REL-05)
- **D-01:** The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` stay where
  they are, on `gsd/planning-setup`. Phases 7–10 build on top of them, and the Phase 10
  `/gsd-pr-branch` PR carries them to `main` with everything else. This is one PR, like 0.2.0
  (0.2.0 D-01/D-02). There's no early hotfix PR and no separate release branch.
- **D-02:** Fast-forward the local `main` to `origin/main`. Local `main` is at `3c75f4f`, and
  `origin/main` holds the 0.2.0 merge `f15c257`. This is local only and nothing is pushed.
- **D-03:** REL-05 is proven in phase verification, not by a repo gate: `git merge-base
  --is-ancestor <sha> HEAD` for each of the four SHAs, plus a full suite run. An ancestry gate
  would be flaky on CI's shallow checkout, and the gates those fixes added
  (`test_release_text.py`, `test_release_text_mutation.sh`) already pin their content.

### CONTENT_VERSION policy (REL-06)
- **D-04:** The release-text content gates are split into two kinds:
  - **Generic gates run for every version.** `upgrade_addressed` checks the addressee
    "If you installed from `main` before {VERSION}" and the two Claude Code update commands. It
    no longer depends on CONTENT_VERSION.
  - **Fact gates stay pinned to CONTENT_VERSION.** These are `upgrade_quotes` (installer lines
    quoted byte for byte) and `not_run` (the exact Not run lines). Phase 10 re-pins them to
    0.2.1 with that release's facts.
- **D-05:** When `VERSION != CONTENT_VERSION`, the pinned fact gates FAIL with a message that
  says to re-pin the facts. They no longer print `skip`. A version bump therefore can't leave
  stale facts behind or leave a skip that blocks Phase 10's skip=0. This reverses the "skip" half
  of WR-02 (`3a42ebf`) on purpose. WR-02's real goal, letting the next release pass, still holds:
  the next release passes once it has written its own facts.
- **D-06:** Phase 7 changes the shape of the gates and records the policy. The values stay at
  0.2.0: `CONTENT_VERSION = "0.2.0"`, the current `UPGRADE_QUOTES` and `NOT_RUN_LINES`. The suite
  stays green through Phases 7–9 because VERSION is still 0.2.0. Phase 10 writes the 0.2.1 facts
  from the recorded runs. Phase 7 adds no placeholder slot.
- **D-07:** The policy and its reason go in two places:
  - the module docstring of `tests/test_release_text.py`, where a maintainer bumping the
    version will look;
  - a Key Decisions row in `.planning/PROJECT.md`.

  `tests/test_release_text_mutation.sh` gains cases proving that a version mismatch FAILs the
  pinned gates and that the generic `upgrade_addressed` still FAILs on a missing addressee or
  command at a non-CONTENT version.

### Codex home rule (MAINT-07)
- **D-08:** `real_home_untouched` uses an allowlist. It watches only the paths the installer can
  write in the real homes:
  - `~/.codex/config.toml` and `config.toml.bbj-backup`
  - `~/.codex/hooks.json`
  - `~/.codex/bbj/` (recursively)
  - `~/.agents/skills/bbj-programming/` and `~/.agents/skills/bbj-web-programming/` (recursively)

  Everything else is ignored, including daemon files (`*.sqlite*`, `history.jsonl`,
  `sessions/`, `log/`, `tmp/`, ...). A future Codex that adds runtime files can't break the gate.
  Phase 8 adds its plugin-route paths to the same list.
- **D-09:** The gate compares content, not mtime. It takes a snapshot before and after, with the
  path list, the existence of each path, and a `cksum` of each file, then compares the two. A
  watched path that appears, disappears or changes content FAILs. A touch with no content change
  does not. This uses POSIX tools only.
- **D-10:** The snapshot and compare logic becomes a helper that can be pointed at any home.
  A new mutation-style test points it at a throwaway fake home and checks both directions:
  - writing `logs_2.sqlite`/`-wal` and other daemon files → ok;
  - editing `config.toml`, creating `hooks.json`, and changing a file in a skill dir → each
    FAILs.

  It runs in CI without Codex. The cases go in a separate test, not inside the 1500+-line
  `test_install_codex.sh`, which only switches to the helper.

### PATH scrub (MAINT-06)
- **D-11:** `tests/lib.sh` gets a helper (name is up to the planner, e.g. `no_compiler_path`).
  It prints `PATH` with every directory that holds `bbjcpl` or `bbjcplw` removed. Other tools
  (`sh`, `awk`, `curl`, `python3`, `busybox`) stay where they are. The same helper or a sibling
  also clears `BBJ_HOME`, `BBJHOME` and `CLAUDE_PLUGIN_OPTION_BBJ_HOME` and sets
  `BBJ_CHECK_DEFAULT_HOMES` to empty, so none of the other discovery sources finds a compiler.
  The fixed `/usr/bin:/bin` approach was rejected because it breaks when `bbjcpl` is linked into
  `/usr/bin` and drops tools installed elsewhere.
- **D-12:** The scrub applies only where "no compiler anywhere" is required: the no-route gates
  in `tests/test_noroute_notice.sh` and `tests/test_exit_contract.sh`, plus any other no-route
  case the planner finds. Tests that put a fake on `PATH` on purpose (`test_discovery.sh`) or
  opt into a real compiler (`test_real_compiler.sh`) are left alone, and `mkwork` stays as it is.
- **D-13:** A CI gate puts `tests/fake-bin`'s `bbjcpl` (and a `bbjcplw`) at the front of `PATH`,
  runs the no-route tests, and expects them green. A mutation step stubs the helper to a no-op
  and expects them to FAIL. This proves that removing the scrub is caught without a real BBj.

### Claude's Discretion
- MAINT-08: how to rebuild the gate-prefix list. Collect the prefixes `sh tests/run.sh` actually
  prints and update `.planning/codebase/CONVENTIONS.md` first, then `.claude/CLAUDE.md`, which is
  generated from it. `skills_` stays. Whether to add a gate that keeps the list in sync is up to
  the planner. It's optional and must not make CI depend on running the whole suite twice.
- The helper names, file names of the new tests, and the gate names (keep the existing
  per-file prefix convention).
- The exact snapshot format for D-09.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` §Phase 7 — goal, success criteria 1–5, notes
- `.planning/REQUIREMENTS.md` — MAINT-06, MAINT-07, MAINT-08, REL-05, REL-06
- `.planning/PROJECT.md` — Key Decisions table (D-07 adds a row)

### Prior decisions
- `.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-CONTEXT.md` — 0.2.0 release path
  (D-01–D-05), D-15 Not run lines, D-17 skip=0 meaning, D-18 (deferred `real_home_untouched`
  hardening, picked up here)

### Code under change
- `tests/lib.sh` — shared helpers; home of the PATH scrub helper (D-11)
- `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh` — no-route gates (D-12)
- `tests/test_install_codex.sh` (≈line 1519, `real_home_untouched`) — current `find -newer` gate (D-08–D-10)
- `tests/test_release_text.py` — CONTENT_VERSION, `UPGRADE_QUOTES`, `NOT_RUN_LINES`, the pinned gates (D-04–D-07)
- `tests/test_release_text_mutation.sh` — mutation proof for the release gates (D-07)
- `tests/fake-bin/bbjcpl` — fake compiler for the D-13 gate
- `plugins/bbj/scripts/bbj-check.sh` (≈line 119, discovery order) — the sources the scrub must neutralise
- `codex/install-codex.sh` — authoritative list of paths the installer writes (D-08 allowlist)
- `.planning/codebase/CONVENTIONS.md`, `.claude/CLAUDE.md` — gate-prefix list (MAINT-08)

### Review-fix commits (REL-05)
- `b0a4c62` (WR-01 install page), `3a42ebf` (WR-02 content gates pinned to 0.2.0),
  `b600ac4` (IN-01 Claude Code tested-with gate), `172e6a5` (IN-02 `--force` wording)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/lib.sh`: `gate`, `mkwork`, `fresh_state`, `run_check`, `notice_text`. New helpers go here.
- `tests/fake-bin/`: fake `bbjcpl`, `bbj`, `codex`, `curl`, `cygpath`.
- `tests/test_release_text_mutation.sh`: the pattern for "prove each gate can fail" (copy the
  tree, mutate, expect FAIL). Reuse it for D-07 and as the model for D-10/D-13.
- `tests/test_tier2_fake.sh` (SYSPATH/ORIGPATH/CURLPATH): an existing PATH-swap idiom, with
  restore of the saved PATH.

### Established Patterns
- Gates print `gate <prefix>_<name> ok|FAIL|skip <detail>`. Under `CI=true` a missing
  prerequisite is a FAIL, not a skip.
- POSIX `sh` and Python 3 stdlib only, with `python3 -I`. No `local`, underscore-prefixed temps,
  and any global a test changes is restored.
- Strings a static scan would match against itself are assembled from pieces.

### Integration Points
- `tests/run.sh` discovers `test_*` files by glob, so new tests are picked up automatically.
- `tests/ci.sh` runs shellcheck over test scripts, so new shell tests must be clean.

</code_context>

<specifics>
## Specific Ideas

- The owner's Windows and Mac machines (Phase 9) have `bbjcpl` on `PATH`. That's the concrete
  failure MAINT-06 prevents.
- The owner's real `~/.codex` holds `logs_2.sqlite`, `state_5.sqlite`, `history.jsonl`,
  `sessions/` and more. Use these names in the D-10 fake-home cases.

</specifics>

<deferred>
## Deferred Ideas

None. The discussion stayed within the phase scope.

</deferred>

---

*Phase: 07-test-hardening-and-release-prep*
*Context gathered: 2026-10-12*
