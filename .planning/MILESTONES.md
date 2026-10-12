# Milestones

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
- `.claude/CLAUDE.md` still lists the removed `skills_` gate prefix

---
