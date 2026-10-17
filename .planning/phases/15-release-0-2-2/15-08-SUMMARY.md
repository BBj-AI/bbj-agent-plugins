---
phase: 15-release-0-2-2
plan: 08
subsystem: release
tags: [release, tag, github-release]

requires:
  - phase: 15-release-0-2-2
    provides: "15-07 merge commit M 0e9b3c0d on origin/main, CI on main success, both post-merge installs pass"
provides:
  - "annotated tag 0.2.2 (object 979e457db54aa3f606ec8495586ecc4a1feb60bf) on origin, peeling to M"
  - "GitHub Release 0.2.2, not draft, not prerelease, body equal to the 0.2.2 CHANGELOG entry of M"
affects: [15-09 merge-back and planning scrub]

commits: 2
plan_head_before: 99dcd9fd651b21b293ff2b813281d283d4d10b22
plan_head_after: f07eb629709e693a625534165e51e1a3a112d585

actuals:
  tokens: 40000
  tasks: 3
  commits: 2

tech-stack:
  added: []
  patterns: ["tag pushed by its own ref, never --tags, never forced", "Release body extracted from M and compared before and after publishing"]

key-files:
  created:
    - .planning/phases/15-release-0-2-2/evidence/release-notes.md
    - .planning/phases/15-release-0-2-2/evidence/tag.txt
    - .planning/phases/15-release-0-2-2/evidence/release.txt

key-decisions:
  - "Owner replied 'publish' for Task 2; the only remote actions were git push origin refs/tags/0.2.2 and gh release create 0.2.2 --verify-tag"
  - "The tag was created once locally on M and never moved or recreated"

requirements-completed: [REL-10]

coverage:
  - id: D1
    description: "Annotated tag 0.2.2 (no v prefix, message basis-bbj 0.2.2) on M, pushed after the owner's confirmation"
    requirement: REL-10
    verification:
      - kind: integration
        ref: "git ls-remote --tags origin: refs/tags/0.2.2 = 979e457d, refs/tags/0.2.2^{} = 0e9b3c0d (M); plan Task 3 automated verify printed ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "GitHub Release 0.2.2 published with the CHANGELOG entry of M as its body"
    requirement: REL-10
    verification:
      - kind: integration
        ref: ".planning/phases/15-release-0-2-2/evidence/release.txt (draft false, prerelease false, body_equal yes)"
        status: pass
    human_judgment: false

duration: not measured (continuation run covered Task 3)
completed: 2026-10-17
status: complete
---

# Phase 15 Plan 08: Tag and publish 0.2.2 Summary

**The annotated tag 0.2.2 (object 979e457d) is on origin and peels to the release merge commit 0e9b3c0d, and the GitHub Release 0.2.2 is published with the CHANGELOG entry of that commit as its body.**

## Performance

- **Tasks:** 3 (Task 1 tracer, Task 2 owner decision, Task 3 push and Release)
- **Files:** 3 evidence files created

## Accomplishments

- Task 1: Release body extracted from M (`git show M:CHANGELOG.md`), holds `### Upgrading`, `### Tested against`, `### Not run`; the annotated tag was created locally on M and checked, nothing published.
- Task 2: the owner replied "publish".
- Task 3: before pushing, merge.txt still held `main_ci: success`, `install_gate_main: pass`, `codex_main: pass`; the local tag was object 979e457d peeling to M; origin/main was M; no 0.2.2 or v0.2.2 tag and no Release existed on origin.
- Pushed `refs/tags/0.2.2` only; created the Release with `--verify-tag` from the notes file.
- Remote: `refs/tags/0.2.2` = 979e457db54aa3f606ec8495586ecc4a1feb60bf (equals the local tag object), `refs/tags/0.2.2^{}` = 0e9b3c0d368573047c71e8530ac0b19f89343a3c (M, a two-parent commit), no v0.2.2.
- Release: https://github.com/BBj-AI/bbj-agent-plugins/releases/tag/0.2.2, `draft: false`, `prerelease: false`, `body_equal: yes` (trailing whitespace trimmed per line).
- origin/main is still M.

## Task Commits

1. **Task 1: release notes from M and the local annotated tag** - `ff47f4e`
2. **Task 2: owner confirmation (checkpoint:decision, blocking-human)** - no commit; the owner replied "publish" on 2026-10-17
3. **Task 3: tag push, Release, release.txt** - `f07eb62`

**Plan metadata:** the commit holding this SUMMARY, STATE.md, ROADMAP.md and REQUIREMENTS.md.

## Files Created/Modified

- `evidence/release-notes.md` - the Release body, extracted from M
- `evidence/tag.txt` - target, type, tag_object, peeled, message, v_prefixed, remote_tag (as of before the push)
- `evidence/release.txt` - remote tag object and peel, Release URL, draft, prerelease, body_equal

## Decisions Made

- Only the single tag ref was pushed; the tag was not moved, deleted or recreated.
- REL-10 marked complete only after the plan's Task 3 verify printed `ok`.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. `tag.txt` still reads `remote_tag: absent`, as written at Task 1 (a pre-push fact); `release.txt` holds the post-push state. The uncommitted mode change on `release-run/owner.sh` and the untracked `.planning/milestone.lock` and `.planning/state.json` were left alone.

## User Setup Required

None.

## Next Phase Readiness

0.2.2 is released. Plan 15-09 merges the released main back into the planning branch and scrubs the planning records before any planning push. Nothing was pushed besides the tag.

## Known Stubs

None.

## Self-Check: PASSED

- Remote tag 0.2.2 = 979e457db54aa3f606ec8495586ecc4a1feb60bf, peeled 0e9b3c0d368573047c71e8530ac0b19f89343a3c = M; no v0.2.2
- Release 0.2.2 not draft, not prerelease, body equals release-notes.md
- origin/main = M
- evidence files exist: release-notes.md, tag.txt, release.txt
- Commits ff47f4e and f07eb62 are on the planning branch
