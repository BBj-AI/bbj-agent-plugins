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

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v0.2.0 | — | 6 | Claim ledgers plus a compile gate as the definition of done for skill content |

### Cumulative Quality

| Milestone | Tests | Coverage | Zero-Dep Additions |
|-----------|-------|----------|-------------------|
| v0.2.0 | 738 gates | — | 0 (stdlib and POSIX sh only) |

### Top Lessons (Verified Across Milestones)

1. (Needs a second milestone to cross-check.)
