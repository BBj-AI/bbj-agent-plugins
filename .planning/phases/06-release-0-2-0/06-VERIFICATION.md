---
phase: 06-release-0-2-0
verified: 2026-10-12T19:30:00Z
status: passed
score: 4/4 must-haves verified
covered_files: [".claude-plugin/marketplace.json", ".planning/phases/06-release-0-2-0/06-01-PLAN.md", ".planning/phases/06-release-0-2-0/06-01-SUMMARY.md", ".planning/phases/06-release-0-2-0/06-02-PLAN.md", ".planning/phases/06-release-0-2-0/06-02-SUMMARY.md", ".planning/phases/06-release-0-2-0/06-03-PLAN.md", ".planning/phases/06-release-0-2-0/06-03-SUMMARY.md", ".planning/phases/06-release-0-2-0/06-04-PLAN.md", ".planning/phases/06-release-0-2-0/06-04-SUMMARY.md", ".planning/phases/06-release-0-2-0/06-05-PLAN.md", ".planning/phases/06-release-0-2-0/06-05-SUMMARY.md", ".planning/phases/06-release-0-2-0/06-06-PLAN.md", ".planning/phases/06-release-0-2-0/06-06-SUMMARY.md", ".planning/phases/06-release-0-2-0/06-07-PLAN.md", ".planning/phases/06-release-0-2-0/06-07-SUMMARY.md", ".planning/phases/06-release-0-2-0/06-08-PLAN.md", ".planning/phases/06-release-0-2-0/06-08-SUMMARY.md", "CHANGELOG.md", "README.md", "docs/install-claude-code.md", "docs/install-codex.md", "plugins/bbj-local/.claude-plugin/plugin.json", "plugins/bbj/.claude-plugin/plugin.json", "tests/test_layout.py", "tests/test_release_text.py", "tests/test_release_text_mutation.sh"]
covered_digest: "v3:sha256:c34dbaf883426b6f65760b89fa805834354fdb98d6be1f7560c139cd60eea6a8"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 4/4
  gaps_closed: []
  gaps_remaining: []
  regressions: []
---

# Phase 6: Release 0.2.0 Verification Report

**Phase Goal:** 0.2.0 is shipped: versions, changelog with upgrade notes, a green full suite on a real BBj, and the tag
**Verified:** 2026-10-12
**Status:** passed
**Re-verification:** Yes. The earlier report was stale: the code-review fixes `b0a4c62`, `3a42ebf`, `b600ac4` and `172e6a5` changed covered files (`CHANGELOG.md`, `docs/*.md`, `tests/test_release_text*.{py,sh}`) after it was written. The fingerprint above is recomputed over the current tree.

All items below were checked against the codebase and against origin after `git fetch origin`, not taken from the SUMMARY files.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `plugins/bbj`, `plugins/bbj-local`, both marketplace entries and `tests/test_layout.py` `VERSION` read 0.2.0, changed in one commit, and `claude plugin validate --strict` passes | VERIFIED | Current tree: `plugins/bbj/.claude-plugin/plugin.json:3`, `plugins/bbj-local/.claude-plugin/plugin.json:3`, `.claude-plugin/marketplace.json:13,19`, `tests/test_layout.py:20` all `0.2.0`. One commit `011d08e` ("chore(06-02): version 0.2.0 ... (REL-01)") touches exactly those four files plus `README.md`. `claude plugin validate --strict .` run here: "Validation passed". `tests/test_layout.py` run here: 0 FAIL. |
| 2 | CHANGELOG has a 0.2.0 entry with the Codex upgrade notes (`--force`, `/hooks` re-approval) and a "Tested against" section rewritten from the actual run | VERIFIED | `CHANGELOG.md` has a single `## 0.2.0` heading with `### Upgrading`, `### Tested against`, `### Not run`. Upgrading names `sh codex/install-codex.sh --force`, the "rerun with --force to replace it" exit 3 behaviour, and the `/hooks` re-approval ("every update of it makes Codex ask for the /hooks review again"), plus the Claude Code `marketplace update` / `plugin update` commands. The same content is in the version at the tag (`git show 0.2.0:CHANGELOG.md`). Tested-against values match `evidence/tested-against.txt`, `rc-facts.md`, `claude/result.txt`, `codex/result.txt` (docs server 1.2.0, Claude Code 2.1.296, Codex CLI 0.162.1, BBj 26.03, `ok=738 fail=0 skip=0`). `python3 -I tests/test_release_text.py` run here: 11 gates, all ok (including `release_upgrade_quotes`, `release_codex_version_single`, `release_claude_version_single`, `release_not_run`). |
| 3 | The full suite passes with `skip=0` on the live gates, and an install from the git marketplace source passes | VERIFIED | `evidence/final-suite.txt` (live run on a real BBj, `BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1`): `SUMMARY: ok=738 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0`. Re-run here on the current tree (no live BBj in this environment): `sh tests/run.sh` gives `SUMMARY: ok=757 fail=0 skip=0`; the 19 extra gates are the review-fix mutation cases in `tests/test_release_text*.{py,sh}`. Install from git source: `evidence/install-gate-main.txt` shows marketplace add from `BBj-AI/bbj-agent-plugins`, `bbj@basis-bbj` 0.2.0 enabled, `bbj-local` installed disabled, bad file exit 2, clean file silent, real config untouched. Real Claude Code and real Codex runs: `verdict: pass`. UAT (`06-UAT.md`) complete, 23/23 passed, including the owner's hand install of Claude Code 0.2.0 and a fresh macOS Codex install whose hook flagged a bad `.bbj` and stayed silent on a clean one. |
| 4 | The release is tagged `0.2.0` | VERIFIED | `git ls-remote --tags origin`: `refs/tags/0.2.0` = tag object `1df5552...`, peeled `0.2.0^{}` = `f15c257...` = `origin/main`. `git cat-file -t 0.2.0` = `tag` (annotated). `gh release view 0.2.0`: published, not draft, not prerelease, target `main`. `gh pr view 1`: MERGED, merge commit `f15c257`. `git ls-tree -r 0.2.0` contains no `.planning/` path. |

**Score:** 4/4 truths verified (0 behavior-unverified)

### Release content versus planning branch (informational, not a gap)

The four review-fix commits (`b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5`) are on the planning branch only. `git merge-base --is-ancestor 172e6a5 origin/main` is false, and `git diff origin/main HEAD` outside `.planning/` shows six changed files (`CHANGELOG.md`, `docs/install-claude-code.md`, `docs/install-codex.md`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `.claude/CLAUDE.md`). That is consistent with the plan ("the 0.2.0 tag was not moved, nothing was pushed"): the tag still points at the tested tree, and every criterion holds on the tag. The wording refinements (which skill directories `--force` deletes, the single-source version gates) ship with the next release or a follow-up. If the maintainers want them in the 0.2.0 text, that needs a new decision; it does not affect REL-01 to REL-04.

### Requirements Coverage

Plan frontmatter IDs: 06-01 REL-03; 06-02 REL-01, REL-02; 06-03, 06-04, 06-05, 06-07 REL-03; 06-06 REL-02, REL-03; 06-08 REL-04. REQUIREMENTS.md maps exactly REL-01 to REL-04 to Phase 6, all marked complete; no ID is orphaned.

| Requirement | Source Plan(s) | Description | Status | Evidence |
|-------------|----------------|-------------|--------|----------|
| REL-01 | 06-02 | Versions 0.2.0 in one commit, strict validation | SATISFIED | Truth 1 |
| REL-02 | 06-02, 06-06 | CHANGELOG 0.2.0 with upgrade notes and Tested against | SATISFIED | Truth 2 |
| REL-03 | 06-01, 03, 04, 05, 06, 07 | Full suite skip=0 live; install from git source | SATISFIED | Truth 3 |
| REL-04 | 06-08 | Tagged 0.2.0 | SATISFIED | Truth 4 |

### Anti-Patterns Found

`grep -E "TBD|FIXME|XXX"` over `CHANGELOG.md`, `docs/install-*.md`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`: no matches. No stubs; the release-text gate is a real gate and its mutation test proves each gate can fail.

### Post-release code review

`06-REVIEW-DISPOSITION.md`: 6 findings, all `fixed`, `open: 0`. The previous report's WR-02 (install page lacks the marketplace refresh and `bbj-local`) and WR-03 (single-entry changelog assumption) are closed by the fix commits; fixes are in the planning branch tree verified here (gates pass, suite 757/0/0). `06-REVIEW-FIX.md` flags WR-02 (`CONTENT_VERSION` gate policy) as wanting a human look at the next release; it is a test-policy choice, not a must-have.

`06-SECURITY.md`: status verified, `threats_open: 0`.

### Human Verification Required

None. The steps that need a person (Codex `/hooks` approval, push, merge, tag, Release, hand installs) were performed by the owner and recorded in `06-UAT.md` and the evidence files.

### Gaps Summary

No gaps. All four ROADMAP success criteria hold on origin and in the local tree.

Administrative note: the ROADMAP Phase 6 checkbox is already `[x]` and REQUIREMENTS REL-01 to REL-04 are `[x]`.

---

_Verified: 2026-10-12_
_Verifier: Claude (gsd-verifier)_
