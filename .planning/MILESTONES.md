# Milestones

## v0.2.1 Platform verification and release hygiene (Shipped: 2026-10-15)

**Delivered:** Codex got its native plugin route, and the Claude Code plugin and the Codex
plugin route were run on real Windows and macOS machines. The install wording now states, per
client, platform and check route, only what the recorded runs show. Released as plugin 0.2.1
(annotated tag `0.2.1` on merge commit 4234e76, GitHub Release published).

**Phases completed:** 4 phases (7-10), 39 plans, 66 tasks

**Key accomplishments:**

- Suite green on a maintainer machine: `tests/lib.sh` scrubs `PATH` for the no-route gates
  (a machine with `bbjcpl` on `PATH` passes), and `real_home_untouched` compares content
  snapshots, so a running Codex daemon no longer breaks it. Release-text gates FAIL with a re-pin
  message instead of skipping at a new version; the 0.2.0 review fixes are in the release tree
  (Phase 7).
- Codex native plugin route: `codex plugin add bbj@basis-bbj` through a `.codex-plugin` overlay
  and a literal-URL `.codex-mcp.json` that ships the hosted server's public OAuth client. The
  unchanged hook checks `apply_patch` writes after `/hooks` trust, and `install-codex.sh --remove`
  is the documented switch. Proven on real Codex 0.162.1 (Linux), gated in CI on fakes (Phase 8).
- Real Windows and macOS runs: Windows found three defects (Codex hook through PowerShell,
  tier-2 connect timeout, verbatim and backslash paths), all fixed with 8 gates written red first
  and confirmed by a re-run. macOS gave tier-1 `bbjcpl` feedback in both clients with no defect
  (Phase 9).
- Windows installer route met in round 2: `commandWindows` names the Git for Windows launcher
  `<Git root>\bin\sh.exe` from `cygpath -w /`, `--sh-exe` is written as given, and `usr\bin` is
  refused, after round 1 was a recorded negative (Phase 10).
- Per-platform, per-route install wording in the README table, both install pages, the
  installer `STATUS_LINE` and the CHANGELOG, with gates and mutation cases that stop the old
  "not yet run" hints from returning (Phase 10).
- Release 0.2.1: suite `ok=979 fail=0 skip=0` with live gates, PR #2 and PR #3 merged, tag
  `0.2.1` and GitHub Release published. A Git-marketplace upgrade 0.2.0 to 0.2.1 on Codex kept the
  hook hash and trust (Phase 10).

**Stats:**

- Timeline: 2026-10-12 → 2026-10-15 (4 days), 416 commits (1073a80 → 02293bc)
- Shipped files (outside `.planning/`): 31 changed, +4,432 / −343 lines
- Requirements: 23/23; audit status `tech_debt` (no gaps)

**Closeout:** override_closeout. All phase verifications passed; phases 7-9 were marked stale
only because later summaries are newer than their VERIFICATION.md (the milestone audit of
2026-10-15 covers all four phases).
Known verification overrides: 1 newly acknowledged, 4 carried forward from a prior close (see
STATE.md Deferred Items). The new one is the OAuth hand-off todo: `offline_access` shipped in
0.2.1; the client id as a setting and the `bbj-docs` → `bbj` rename are still open.

**Tech debt carried forward** (details in `milestones/v0.2.1-MILESTONE-AUDIT.md`):

- Phase 10 review WR-01 (`usr\bin` refusal bypassable by a non-canonical path), WR-02
  (`--remove` keeps `hooks.json` when the recorded sh.exe is gone), WR-03 (two gates assert exit
  code only); IN-01..IN-04
- Phase 9 review WR-01 (plugin `commandWindows` hardcodes `C:\PROGRA~1\Git\bin\sh.exe`; stated
  as a known gap), WR-02 (5 s tier-2 connect timeout paid per file), WR-03
  (`windows_codex_backslash_dotdot_skipped` does not catch a regression)
- MAINT-08 drift: the gate-prefix block lacks `windows_`, `command_windows_` and
  `tier2_connect_timeout_`
- REL-05 evidence: the review-fix commits reach tag `0.2.1` as patch-equal cherry-picks, not as
  ancestors
- Phase 8 SC3 wording vs. WR-05 notice rewording (amend or record an override); the
  `apply_patch` → `Write|Edit` alias has no gate or doc sentence
- README Claude Code / macOS cell lacks the "(hook run directly)" qualifier or date
- CI ShellCheck version (0.9.0) not pinned or recorded

---

## v0.2.0 Skills makeover and local-first check (Shipped: 2026-10-12)

**Delivered:** This repository became the home of the two BBj skills. Both skills were rewritten
so that every claim is cited or reproduced on BBj 26.03, and the local `bbj-ls` became the
preferred check route over the hosted one. Released as plugin 0.2.0 (tag `0.2.0` on f15c257,
GitHub Release published).

**Phases completed:** 6 phases (1-6), 43 plans, 77 tasks

**Key accomplishments:**

- Vendoring retired: the skills are plain repository files under the layout tests, and one
  check-order block (bbjcpl, then local bbj-ls, then hosted with disclosure) is pinned
  byte-identical in the Codex snippet and both skills. Codex `--with-local` registers bbj-local
  with a loopback probe (Phase 1).
- The hook tells the agent once per session, via `additionalContext` and exit 0, that a BBj file
  was written but not checked. Delivery was confirmed on real Claude Code 2.1.296 and on
  codex-cli 0.162.1 (Phase 2).
- A stdlib-only skill example gate (fence grammar, structure lints, `nocheck` ratchet at 0) runs
  every `bbj` block on `bbjcpl -t -N -X` and a loopback `bbj-ls`. Its BBj 26.03 baseline became
  the makeover to-do list (Phase 3).
- `bbj-programming` rebuilt from a 150-row claim ledger (DOC, COMPILE, RUNTIME, OWNER): a short,
  check-first SKILL.md where every block passes both routes (Phase 4).
- `bbj-web-programming` rebuilt from a 242-row ledger: a trigger-first description, DWC DOM/CSS
  claims kept only with a docs URL or one of nine owner grants, and the references folded from
  seven to four (Phase 5).
- Release 0.2.0: suite `ok=738 fail=0 skip=0` with live gates, PR #1 merged, installs confirmed
  on Claude Code and Codex (Linux and macOS), tag and GitHub Release published (Phase 6).

**Stats:**

- Timeline: 2026-10-09 → 2026-10-12 (4 days), 435 commits (0fb0a17 → c83cfd3)
- Shipped files (outside `.planning/`): 48 changed, +6,479 / −2,650 lines
- Requirements: 33/33; audit status `tech_debt` (no gaps)

**Closeout:** override_closeout. All phase verifications passed; phases 2-4 were marked stale only
because later commits touched them.
Known verification overrides: 4 newly acknowledged, 0 carried forward from a prior close (see
STATE.md Deferred Items). Three of the four were already resolved in code (dialog-flag-modality,
SEED-001, D-1); D-2 is still open.

**Tech debt carried forward** (details in `milestones/v0.2.0-MILESTONE-AUDIT.md`):

- Phase 2 review WR-01 (tests/lib.sh does not scrub PATH), WR-02 (`\uXXXX` path skipped), IN-01..05;
  disposition never set
- D-2: `real_home_untouched` gate races a local Codex daemon
- Phase 6: four review-fix commits (wording, release-text gates) are not in tag `0.2.0`; they ship
  with the next release. The CONTENT_VERSION gate policy needs a human look.
- 04/05-DOCS-PROPOSAL.md not yet sent to the BASIS documentation owners
- Installer and docs still say "not yet run on macOS" although UAT ran it there
- The gate-prefix list in `.claude/CLAUDE.md` is incomplete (the audit called `skills_` stale, but it is still emitted)

---
