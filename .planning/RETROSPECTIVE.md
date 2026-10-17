# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v0.2.0 — Skills makeover and local-first check

**Shipped:** 2026-10-12
**Phases:** 6 | **Plans:** 43 | **Sessions:** not recorded

### What Was Built
- Skills moved into this repository (vendoring retired), with one shared check-order block pinned byte-identical in three places, and Codex `--with-local`
- A hook notice that tells the agent once per session when a BBj file could not be checked, confirmed on real Claude Code and real Codex
- A stdlib-only example gate that compiles every `bbj` block on `bbjcpl -t` and `bbj-ls`, with a ratcheted baseline
- Both skills rebuilt from claim ledgers (150 and 242 rows), each claim cited, compile-reproduced or owner-confirmed
- Release 0.2.0: merged, tagged, GitHub Release published, installs confirmed on both hosts

### What Worked
- Measuring before rewriting: the Phase 3 baseline (69 failing blocks) turned into the to-do list for Phases 4 and 5, and the ratchet kept the suite green while the skills were still red
- The claim ledger with fixed classes (DOC, COMPILE, RUNTIME, OWNER) and checker scripts made "only verified facts" testable rather than a matter of judgment
- One-sitting owner checklists (exact claim, repro program, devtools step) got nine DWC claims confirmed in one pass
- Real-client runs in throwaway configs (Claude Code, codex-cli) found payload facts that docs alone could not, such as Codex's `apply_patch` delivery

### What Was Inefficient
- The Dialog-flag modality went through two review rounds: generalizing "the page says only X" into "X is undocumented" dropped a documented fact (debug session dialog-flag-modality)
- The plain-`mkdir` marker assumption broke on uutils coreutils (D-1), and that cost a post-plan fix
- Local tooling gaps (no ShellCheck until Phase 6) pushed some checks to CI only
- Review dispositions in Phase 2 were never set, so seven findings stay "open" in the record
- Four review-fix commits landed after the tag and missed the release

### Patterns Established
- Fence grammar for skill code: `bbj`, `bbj should-fail`, `bbj nocheck (reason)`, with a `nocheck` ratchet at 0
- OWNER-confirmed rules are worded as maintainer-confirmed, never passed off as documented
- Probe runners with a recorded OUTPUT.txt that `--check` reproduces
- A blocking human confirmation directly before every push, merge, tag push and release

### Key Lessons
1. When a review narrows a claim, re-fetch every page that might state it, not only the page under review, before reclassifying a DOC claim
2. Test concurrency primitives against the coreutils actually installed (uutils is the default on recent Ubuntu); prefer an O_EXCL create (`set -C`) over `mkdir`
3. Land review fixes before cutting the tag, or plan explicitly for them to ride the next release
4. Gates that watch a real home directory must ignore other tools' runtime files

### Cost Observations
- Model mix: not recorded
- Sessions: not recorded
- Notable: real-client confirmation runs were cheap (one billed Claude Code run at 0.46 USD) compared with what they established

---

## Milestone: v0.2.1 — Platform verification and release hygiene

**Shipped:** 2026-10-15
**Phases:** 4 | **Plans:** 39 | **Sessions:** not recorded

### What Was Built
- A maintainer-proof suite: `PATH` scrub for the no-route gates, content snapshots for `real_home_untouched`, and release-text fact gates that FAIL with a re-pin message at a new version
- The Codex native plugin route (`.codex-plugin` overlay, literal-URL `.codex-mcp.json` with the public OAuth client, unchanged hook after `/hooks` trust) and `install-codex.sh --remove` as the switch
- Real runs on Windows and macOS with an owner smoke driver, runbooks, and a record checker; three Windows defects fixed with gates written red first
- The Windows installer launcher fix (`<Git root>\bin\sh.exe`), met in a second owner round
- Per-platform, per-route install wording backed only by the run records, and release 0.2.1 (tag `0.2.1` on M2 `4234e76`)

### What Worked
- Owner runbooks with fixed reply templates, plus a record checker with verdict rules: each Windows and macOS round produced a record that Phase 10 could quote without interpretation
- Every platform defect got a fake-based CI gate written red first, so the fixes stay pinned without a Windows or macOS runner
- Real Codex in throwaway homes (never `~/.codex`, never `/tmp`) settled the plugin-route facts: hook trust, version-only upgrades, the double install
- "Not run" lines that name exactly the configurations missing from the records, with gates and mutation cases that ban the old hints

### What Was Inefficient
- Windows installer round 1 was a recorded negative: the `Git\usr\bin\sh.exe` call form had not been tried from PowerShell before it shipped to the owner, which cost three gap-closure plans (10-15 to 10-17)
- The D-22 upgrade reading came after merge M1 and changed the CHANGELOG, so a second PR and merge (M2) were needed before the tag
- The gate-prefix block needed two gap-closure plans in Phase 7 (07-05, 07-06) and still drifted again by the end of the milestone
- The review-fix commits reached tag `0.2.1` as patch-equal cherry-picks, so the Phase 7 ancestry proof did not carry over to the tag
- Phase 10 grew to 17 plans because owner rounds and release steps were each a separate checkpoint plan

### Patterns Established
- Run records with a per-line verdict rule (`met`, `fixed and re-run met`, `known gap`), checked by `platform-run/check-records.sh` in final mode
- One plugin tree serves both hosts: Claude Code reads `.claude-plugin`, Codex reads the `.codex-plugin` overlay; layout gates pin version and URL drift between them
- Route detection by testing a host variable (`CLAUDE_PLUGIN_ROOT`) without ever printing it
- Billed real-client runs only with the owner's approval for each run

### Key Lessons
1. Try a launch form on the real platform and shell the host uses (PowerShell for Codex on Windows) before shipping it to an owner round
2. Finish every real-client reading that can change release text before the first merge, not between the merge and the tag
3. A doc block copied by hand with no gate drifts within one milestone; gate it, or generate it from the suite transcript
4. Prove "in the release" against the tag with `git cherry` or patch IDs, not ancestry on a working branch

### Cost Observations
- Model mix: not recorded
- Sessions: not recorded
- Notable: most wall-clock time went to owner-paced platform rounds, not to agent execution

---

## Milestone: v0.2.2 — Plugin-only cleanup

**Shipped:** 2026-10-17
**Phases:** 5 | **Plans:** 34 | **Sessions:** not recorded

### What Was Built
- The Codex installer route removed with all its tests, gates and fakes; `layout_no_retired_route` keeps it out, so the plugin is the only route for both clients
- The docs server renamed `bbj-docs` → `bbj`, with sign-in labels copied from a real Linux run (`12-LINUX-RUN.md`) and `layout_no_old_server_name` keeping the old name out
- The Phase 9 Windows leftovers fixed: `commandWindows` Git lookup with a loud not-found branch, one tier-2 connect timeout per run, a backslash gate that catches a regression; confirmed on Windows 10
- One install page `docs/install.md`, one term list enforced by `layout_no_retired_terms`, and a gate-prefix block checked against the suite by `run_prefix_block`
- Release 0.2.2 on a pinned CI CLI (2.1.301), release suite `ok=864 fail=0 skip=0` with live gates, tag `0.2.2` on 0e9b3c0

### What Worked
- Retiring a route together with a gate that fails the moment it returns, proven by mutation cases on a copy: removal and rename stayed done across later phases
- Copying user-facing labels only from a recorded real-client run, not from expectation (`plugin:bbj:bbj`, `codex mcp login bbj`)
- Ending the gate-prefix drift seen in v0.2.0 and v0.2.1 by making `tests/run.sh` check the hand-kept block against every gate it prints
- All real-client release readings (both clients, sign-in, hook) taken on the release candidate before the merge, so the tag went on the first merge commit

### What Was Inefficient
- The Phase 15 review found WR-01 (a second Linux Claude Code version in `docs/install.md`) in release text after the tag; it is deferred to the next release
- The Windows harness for Phase 13 needed four fixes (H1-H4) during the owner run itself
- The dev home path reached pushed planning records again and needed a scrub commit (D-18), as in v0.2.1
- Local `main` was never fast-forwarded after the 0.2.1 and 0.2.2 merges and still sits at 0.2.0

### Patterns Established
- Retirement gates: one gate per removed name or route, scanning tracked files outside `.planning/` with released CHANGELOG entries exempt by version heading
- A hand-kept source block outside the GSD-generated regions of `.claude/CLAUDE.md`, read by the suite and copied to `CONVENTIONS.md` under an identity check
- CI CLI pin bumped only after an owner check on npmjs.com, with `npm audit signatures` in a scratch install

### Key Lessons
1. A rename or removal is done only when a gate fails on its return; text cleanups without a gate came back in earlier milestones
2. Run the code review before the release candidate is frozen, not after the tag, or its text findings wait a full release
3. Dry-run an owner harness on the target OS (or a faithful fake) before the owner session
4. Check for the dev home path before every push of the planning branch, not after

### Cost Observations
- Model mix: not recorded
- Sessions: not recorded
- Notable: the milestone took three days; owner-paced Windows and release runs again set the pace

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v0.2.0 | — | 6 | Claim ledgers plus a compile gate as the definition of done for skill content |
| v0.2.1 | — | 4 | Owner-run platform records with verdict rules as the only source for install wording |
| v0.2.2 | — | 5 | Retirement gates that fail when a removed route, name or term returns |

### Cumulative Quality

| Milestone | Tests | Coverage | Zero-Dep Additions |
|-----------|-------|----------|-------------------|
| v0.2.0 | 738 gates | — | 0 (stdlib and POSIX sh only) |
| v0.2.1 | 979 gates | — | 0 (stdlib and POSIX sh only) |
| v0.2.2 | 864 gates (installer tests removed) | — | 0 (stdlib and POSIX sh only) |

### Top Lessons (Verified Across Milestones)

1. Real-client runs establish facts that docs alone do not (v0.2.0: Codex `apply_patch` delivery; v0.2.1: PowerShell hook launch, plugin upgrade trust; v0.2.2: the sign-in labels under `bbj`); plan them early and in throwaway homes
2. Work that lands after a merge or tag point misses that point (v0.2.0: review fixes after the tag; v0.2.1: the D-22 reading after M1; v0.2.2: review WR-01 after the tag); put all release-text inputs, the code review included, before the first merge
3. Hand-kept lists drift unless the suite checks them (gate-prefix block drifted in v0.2.0 and v0.2.1; checked by `run_prefix_block` since v0.2.2)
