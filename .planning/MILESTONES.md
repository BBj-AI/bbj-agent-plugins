# Milestones

## v0.2.2 Plugin-only cleanup (Shipped: 2026-10-17)

**Delivered:** The plugin is the only install route for Claude Code and Codex. The docs server
is named `bbj` everywhere, the Windows hook fixes left over from Phase 9 are in, and one install
page and one term list replace the per-client pages and the mixed wording. Released as plugin
0.2.2 (annotated tag `0.2.2` on merge commit 0e9b3c0, GitHub Release published).

**Phases completed:** 5 phases (11-15), 34 plans, 66 tasks

**Key accomplishments:**

- Codex installer route removed: `install-codex.sh`, `AGENTS-snippet.md`, their tests, gates,
  fakes and the hook's installer branch are gone, and `layout_no_retired_route` keeps them out,
  proven by nine mutation cases (Phase 11).
- Docs server renamed `bbj-docs` → `bbj` in both MCP configs, both skills, the hook notice and
  the docs. The sign-in labels in the docs (`plugin:bbj:bbj`, `codex mcp login bbj`) are the ones
  real Claude Code and Codex showed on Linux, and `layout_no_old_server_name` keeps the old name
  out (Phase 12).
- Phase 9 review WR-01..WR-03 closed: `commandWindows` finds `sh.exe` outside the default Git
  location or says so loudly, one tier-2 connect timeout per hook run instead of per file, and a
  backslash gate that catches a regression. Confirmed on a real Windows 10 machine (Phase 13).
- One install page `docs/install.md` for both clients, every README Verified cell traced to a
  run record and pinned by gates, one term list enforced by `layout_no_retired_terms`, and a
  gate-prefix block that `tests/run.sh` checks against every gate name (Phase 14).
- Release 0.2.2: CI pinned to `@anthropic-ai/claude-code` 2.1.301, release suite
  `ok=864 fail=0 skip=0` with live gates, fresh installs and sign-in under `bbj` in real Claude
  Code 2.1.301 and Codex 0.162.1, PR #4 merged, tag `0.2.2` and GitHub Release published
  (Phase 15).

**Stats:**

- Timeline: 2026-10-15 → 2026-10-17 (3 days), 378 commits (e1a4ff5 → 3758cac)
- Shipped files (outside `.planning/`, `0.2.1..0.2.2`): 49 changed, +2,895 / −6,219 lines
- Requirements: 18/18; audit status `tech_debt` (no gaps)

**Closeout:** override_closeout. All five phase verifications passed; phases 11-14 were marked
stale only because later summaries are newer than their VERIFICATION.md (the milestone audit of
2026-10-17 covers all five phases).
Known verification overrides: 3 newly acknowledged, 4 carried forward from a prior close (see
STATE.md Deferred Items). The three new ones are the 2026-10-16 todos: refuse untested client
versions, the VS Code extension install route, and the social sign-in help text.

**Tech debt carried forward** (details in `milestones/v0.2.2-MILESTONE-AUDIT.md`):

- Phase 15 review WR-01 (`docs/install.md` names Claude Code 2.1.299 for Linux next to the
  2.1.301 banner; `release_claude_version_single` misses that word order), IN-01 (README "Not
  run" paragraph is an ungated subset of the CHANGELOG list), IN-02 (CLI version in the `ci.yml`
  comment is unguarded), IN-03 (`.claude/CLAUDE.md` project overview stops at 0.2.1)
- Phase 14 review IN-10: an unterminated GSD region makes `run_prefix_block` fail closed without
  naming the cause; IN-09: `live_blackhole_connect_timeout` skips unless `BBJ_LS_BLACKHOLE_URL` is
  set
- Integration F4: the Claude Code no-route notice does not name the `/plugin` enable step;
  F5: `.codex-mcp.json` hard-codes the hosted docs URL (Codex has no `docs_url`); F1:
  `commandWindows` on real Windows only through owner runs
- Local `main` is at f15c257 (0.2.0) while `origin/main` and tag `0.2.2` are at 0e9b3c0

---

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
