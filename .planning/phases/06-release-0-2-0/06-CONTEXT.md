# Phase 6: Release 0.2.0 - Context

**Gathered:** 2026-10-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Ship 0.2.0: the four version fields at 0.2.0 in one commit (REL-01), a CHANGELOG 0.2.0 entry with
upgrade notes and a "Tested against" section written from the actual release run (REL-02), the
full suite green with no skipped gate on a real BBj plus an install from the git marketplace
source (REL-03), and the annotated tag `0.2.0` (REL-04). Settling the four open Phase 4 review
findings is in scope because STATE.md makes it a release precondition. No new features, no
skill content beyond what the finding triage requires.

</domain>

<decisions>
## Implementation Decisions

### Merge and tag path
- **D-01:** The work reaches `main` through a PR whose branch is built with `/gsd-pr-branch`, so
  `.planning/` commits are filtered out and `main` carries no planning artifacts. CI on the PR
  must be green before merging. `main` is currently 271 commits behind `gsd/planning-setup` and
  still has `skills.lock.json`. The merge removes it.
- **D-02:** Merge style is a merge commit, not a squash or rebase. This keeps the per-plan
  conventional commits (with decision IDs in scopes) traceable on `main`.
- **D-03:** The tag `0.2.0` (no `v`, per the STATE.md concern) points at the merge commit on
  `main`, not at a commit on the release branch. — **Reversibility:** one-way — a pushed tag is
  a published contract that marketplace users and the GitHub Release refer to; moving it
  rewrites what users already fetched.
- **D-04:** The tag is annotated (`git tag -a 0.2.0`). A GitHub Release is created for it, and
  its body is the CHANGELOG 0.2.0 entry.
- **D-05:** Order: merge PR → install from the git marketplace source (`main`) into a throwaway
  config → tag and Release only if that install passes. The tag push and the Release are
  outward-facing, so the owner confirms right before them.

### CHANGELOG
- **D-06:** The `## 0.1.0 (unreleased)` entry is folded into 0.2.0. 0.1.0 was never tagged, so
  0.2.0 becomes the first release and its entry describes the whole marketplace: two plugins,
  docs server, both skills, hook, Codex installer, plus everything from Phases 1–5 (skills
  maintained here, local-first check order, `--with-local`, no-route notice, example gate, both
  skill makeovers).
- **D-07:** The 0.1.0 "Next" paragraph (docs server v1.2.0, "Phase 21 of the project plan") is
  removed.
- **D-08:** The entry keeps the 0.1.0 shape: short summary, bullet list of user-visible content,
  an Upgrading section, Tested against, Not run. It does not use Keep a Changelog subsections.
- **D-09:** The Upgrading section is addressed to "If you installed from main before 0.2.0". It
  names no 0.1.0 release. It covers Codex (rerun the installer with `--force` to replace the
  skills, re-approve the changed hook in `/hooks`) and Claude Code (one line: update the
  marketplace and the plugin). The Codex wording must match what `codex/install-codex.sh`
  already prints (lines ~727, ~739, ~780).

### Tested against
- **D-10:** Every "Tested against" line comes from a run on the 0.2.0 release candidate. Lines
  from 0.1.0 that were not re-run are dropped. They are not carried over with old dates.
- **D-11:** Real Codex: a fresh install only, with the current codex CLI on Linux: the installer
  (including `--with-local`), skills in `~/.agents/skills`, `/hooks` approval, and the hook's
  feedback after `apply_patch`. Record the codex-cli version and date.
- **D-12:** The Codex upgrade path (installing over an earlier install with `--force` and
  re-approving in `/hooks`) is not run on a real Codex, and the changelog does not mention that
  either way. The Upgrading notes rest on the installer output and `tests/test_install_codex.sh`.
- **D-13:** Real Claude Code: from `main` after the merge, run `claude plugin marketplace add
  BBj-AI/bbj-agent-plugins` and `claude plugin install bbj@basis-bbj` into a throwaway config.
  Then Write and Edit a bad `.bbj` file (compiler feedback appears) and a clean one (silent), and
  enable `bbj-local`. Record the Claude Code version and date. This run satisfies REL-03's
  git-source install.
- **D-14:** Record the docs server version the run saw: the `serverInfo` field of its
  `server/discover` answer, plus the instance URL. Do not bump the CI Claude CLI pin
  (`.github/ci-tools`, 2.1.293).
- **D-15:** Windows and macOS stay under "Not run" with the same two lines as before.

### Pre-release loose ends
- **D-16:** Triage the Phase 4 open findings WR-01, IN-01, IN-02 and WR-08 one by one against the
  current skill text. A finding that still holds is fixed, and the fixed block passes the example
  gate (`bbjcpl -t` and `bbj-ls`) under the claim-ledger rules. A finding that no longer holds is
  set to `skipped` or `deferred` with its reason in the Source cell. The end state of
  `04-REVIEW-DISPOSITION.md` is `open: 0`. This happens before the version bump.
- **D-17:** "skip=0" means the whole suite, not only the live gates: `BBJ_LS_LIVE=1`,
  `BBJ_SKILLS_LIVE=1`, `busybox` installed so the busybox-sh contract gate runs, and a real Codex
  through `BBJ_TEST_CODEX`. Also run `CI=true sh tests/ci.sh`. The counts from these runs go into
  "Tested against".
- **D-18:** Run the release suite with no Codex daemon running, so `real_home_untouched` cannot
  race it. The gate itself is not changed. Hardening it stays deferred.
- **D-19:** The release run happens on this machine (BBj 26.03, `bbj-ls` on `127.0.0.1:5009`, as
  in Phases 3–5). The owner starts BBjServices if it is not running.

### Claude's Discretion
- How the work splits into plans, the wording of the changelog bullets, and the annotated tag
  message.
- REL-01's single version commit (four manifest fields plus `tests/test_layout.py` `VERSION`)
  can land together with the CHANGELOG or on its own, as long as the version fields change in
  exactly one commit.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements and roadmap
- `.planning/REQUIREMENTS.md` — REL-01..REL-04 (Release section)
- `.planning/ROADMAP.md` — Phase 6 success criteria
- `.planning/STATE.md` — Blockers/Concerns: tag form `0.2.0`, upgrade traps, real_home_untouched flake, Phase 4 open findings

### Release targets
- `CHANGELOG.md` — current 0.1.0 entry to fold; its shape is the template for 0.2.0
- `.claude-plugin/marketplace.json`, `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj-local/.claude-plugin/plugin.json` — version fields
- `tests/test_layout.py` — `VERSION` constant and the `versions` gate
- `codex/install-codex.sh` — the `--force` and `/hooks` messages the Upgrading notes must match

### Open findings
- `.planning/phases/04-bbj-programming-makeover/04-REVIEW-DISPOSITION.md` — WR-01, IN-01, IN-02, WR-08 at `open`
- `.planning/phases/04-bbj-programming-makeover/04-REVIEW.md` — finding text
- `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md` — claim-ledger rules for any skill fix (checked by `ledger_check.py` in the same directory)

### Test gates
- `tests/run.sh`, `tests/ci.sh` — suite entry points and skip/FAIL rules
- `tests/test_exit_contract.sh` — busybox-sh gate (line ~158)
- `tests/test_install_codex.sh` — `real_home_untouched` (line ~1521), `BBJ_TEST_CODEX`
- `tests/test_tier2_live.sh`, `tests/test_skill_examples.py`, `tests/skills_baseline.json` — live gates (`BBJ_LS_LIVE`, `BBJ_SKILLS_LIVE`)
- `docs/install-claude-code.md`, `docs/install-codex.md` — install steps used for the real runs

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `/gsd-pr-branch`: builds the PR branch with `.planning/` filtered out (D-01).
- The installer already prints both upgrade traps. The CHANGELOG only has to repeat them.
- `tests/skills_baseline.json` already has `pending: {}` and `nocheck: 0`, so both skills are out of pending.

### Established Patterns
- `tests/test_layout.py` enforces the same version in all four manifest fields plus `VERSION`. Change them together.
- The 0.1.0 "Tested against" style: each line names the tool version, the instance, what was exercised, and the date.
- Review dispositions are edited in the YAML header and the table of `*-REVIEW-DISPOSITION.md`. The values are `fixed`, `skipped` and `deferred`, with the reason in the Source cell.

### Integration Points
- GitHub `BBj-AI/bbj-agent-plugins`: PR, CI, tag, Release. The marketplace's git source reads the default branch `main`.
- `.planning/config.json` has `git.create_tag: true`. The tag must follow D-03/D-04, not a tool default.

</code_context>

<specifics>
## Specific Ideas

- The GitHub Release body is the CHANGELOG 0.2.0 entry verbatim.
- Tag only after the git-source install from `main` passes.

</specifics>

<deferred>
## Deferred Ideas

- Hardening `real_home_untouched` against a running Codex daemon (later phase or milestone).
- Bumping the CI Claude CLI pin in `.github/ci-tools`.
- A real-Codex run of the upgrade path (`--force` over an earlier install plus `/hooks` re-approval).
- Windows and macOS runs of the hook.

</deferred>

---

*Phase: 06-release-0-2-0*
*Context gathered: 2026-10-12*
