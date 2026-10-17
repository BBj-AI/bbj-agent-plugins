---
phase: 03
fixed_at: 2026-10-10T00:00:00Z
review_path: <home>/repos/bbj-agent-plugins/.planning/phases/03-example-gate-and-structure-lints/03-REVIEW.md
iteration: 1
findings_in_scope: 3
fixed: 3
skipped: 0
status: all_fixed
---

# Phase 3: Code Review Fix Report

**Fixed at:** 2026-10-10
**Source review:** <home>/repos/bbj-agent-plugins/.planning/phases/03-example-gate-and-structure-lints/03-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 3
- Fixed: 3
- Skipped: 0

Fixes were made in the main checkout (no worktree), one commit per finding. Every fix is pinned by a
child-run fixture gate in `tests/test_skill_examples.py`; each fixture was checked to fail when its fix is
reverted (mutation check on a scratch copy).

## Fixed Issues

### WR-01: A symlinked skill directory is silently skipped, so it escapes every lint

**Files modified:** `tests/test_skill_examples.py`
**Commit:** ba59a32
**Applied fix:** Added `skill_links(root)` and a loop in `run_gates` that prints
`gate skills_structure_<name> FAIL ... is a symlink (not followed)` for every symlink directly under
`plugins/bbj/skills`. The link is still not followed, in line with the symlink rule. Fixture
`fx_structure_linked_skill_dir` builds a root with a symlinked skill directory and requires rc 1 and that
gate line.

### WR-02: A tree with no skills at all is green

**Files modified:** `tests/test_skill_examples.py`
**Commit:** ebba06e
**Applied fix:** Added a `skills_discovery` gate in `run_gates` after `scan_tree`: FAIL when no skill
directory is found, otherwise ok with the count and names. Fixtures `fx_discovery_ok`,
`fx_discovery_missing_tree_fails` and `fx_discovery_empty_dir_fails` pin both outcomes. No existing fixture
root lacks skills, so none changed behaviour.

### WR-03: Raw directory names reach gate lines, contradicting the "printable ASCII only" guarantee

**Files modified:** `tests/test_skill_examples.py`
**Commit:** 0199429
**Applied fix:** The ratchet and both pending gates now build their names with `gate_name()`
(`"ratchet_" + gate_name(name, check)`, `"pending_" + gate_name(name)`). Fixture
`fx_structure_hostile_dir_name` uses a directory name with a space, a newline and a forged `gate` line, and
requires rc 1, no forged line, every child line's status in ok/FAIL/skip, and exactly one sanitised ratchet
gate line.

## Verification

Run in the main checkout (no worktree), so the numbers are reproducible from this tree.

- `python3 -I tests/test_skill_examples.py`: exit 0.
- `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`: exit 0 (live bbjcpl and bbj-ls).
- `--report` output JSON is `cmp`-equal to `tests/skills_baseline.json` (baseline unchanged).
- `sh tests/run.sh`: first run `fail=1`, only the known unrelated flake `real_home_untouched`
  (a live Codex process changed a file under `~/.codex`); re-run `ok=703 fail=0 skip=163`.

---

_Fixed: 2026-10-10_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
