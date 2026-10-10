---
phase: 03-example-gate-and-structure-lints
review: 03-REVIEW.md
updated: 2026-10-10
---

# Phase 3: Code Review Disposition

| Finding | Severity | Disposition | Where |
|---------|----------|-------------|-------|
| WR-01 symlinked skill dir silently skipped | warning | fixed | ba59a32, fixture `fx_structure_linked_skill_dir` |
| WR-02 empty skill tree passes | warning | fixed | ebba06e, gate `skills_discovery` + 3 fixtures |
| WR-03 raw dir names in ratchet/pending gate names | warning | fixed | 0199429, fixture `fx_structure_hostile_dir_name` |
| IN-01 guard_cpl_args compares a constant to a copy of itself | info | open | advisory; the argv guard on the fake compiler log is the real check |
| IN-02 ratchet leaves headroom until baseline is lowered | info | accepted | by design (D-02); `--report` lowers it |
| IN-03 broken live route is skip unless BBJ_SKILLS_LIVE=1 | info | open | for user review: D-13 meant the exemption for a missing route |
| IN-04 approximate `\|` unfolding; ls_call misses RecursionError | info | open | advisory |
| IN-05 `## Sources` heading edge cases; two-file report rename not atomic as a pair | info | open | advisory |
