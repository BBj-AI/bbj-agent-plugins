---
phase: "14"
slug: "one-install-page-and-one-term-list"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-16"
---

# Phase 14 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution. Source: `14-RESEARCH.md` § Validation Architecture.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | repo-local gate protocol: `gate NAME ok\|FAIL\|skip DETAIL`, runner `tests/run.sh`, entry `tests/ci.sh` |
| **Config file** | none (`.shellcheckrc` for lint) |
| **Quick run command** | the touched file's own test: `sh tests/test_install_pages.sh`, `python3 -I tests/test_release_text.py`, `sh tests/test_release_text_mutation.sh`, `python3 -I tests/test_layout.py`, `python3 -I tests/test_check_order.py`, `sh tests/test_ci_gates.sh`, `sh tests/test_hook_mutation.sh`, `sh tests/test_static_guards.sh` |
| **Full suite command** | `sh tests/run.sh` (last line `SUMMARY: ok=<N> fail=0 skip=0`; baseline ok=797) |
| **CI entry** | `CI=true sh tests/ci.sh` |
| **Estimated runtime** | ~110 seconds (full suite); quick commands 1–25 s |

---

## Sampling Rate

- **After every task commit:** the quick command of each test file the task touched, plus `python3 -I tests/test_layout.py` whenever a tracked file is added or removed
- **After every plan wave:** `sh tests/run.sh`, require `fail=0` and zero `^gate .* FAIL ` lines
- **Before `/gsd-verify-work`:** `CI=true sh tests/ci.sh` green, then the MAINT-11 grep returns nothing
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled by the planner from the PLAN.md `<automated>` commands (each task's full command is in its plan; every one ends with `sh tests/run.sh` or `sh tests/ci.sh` and requires ` fail=0 `).

| Task | Wave | Requirement | Behavior checked | Key gates / checks in the automated command | Status |
|------|------|-------------|------------------|---------------------------------------------|--------|
| 14-01 T1 | 1 | DOCS-05 | one page by step, readers moved, old pages still present | `claude_sections` (exact D-01 headings), new heading pins, `link_README_md_docs_install_md`, `release_upgrade_install_page`, `release_codex_version_single`, `release_mut_no_unrun_hint_install_page*`, no duplicate sentences, no retired variant or tier word on the page | ⬜ pending |
| 14-01 T2 | 1 | DOCS-05 | old pages gone, history-only exemption, names kept out | `link_history_cut_newer_entry`, `link_history_cut_old_entry`, `layout_no_removed_pages`, six `layout_mutation_removed_page_*`, `git grep` for the removed names outside .planning/ and CHANGELOG empty | ⬜ pending |
| 14-02 T1 | 2 | DOCS-07 | macOS Claude Code cell and qualifier definitions | `release_cell_claude_code_macos`, `release_cell_qualifiers_defined`, their `release_mut_cell_*` cases | ⬜ pending |
| 14-02 T2 | 2 | DOCS-07, DOCS-05 | six cells audited and pinned, page claims traced | seven `release_cell_*` and seven `release_mut_cell_*`, 14-CLAIM-TRACE.md row for each cell and each 'Observed on' / 'Verified on' / 'Not run' line of docs/install.md | ⬜ pending |
| 14-04 T1 | 2 | MAINT-09 | discovery_ and tier2_ prefixes, hook mutation follows | HEAD-versus-tree (name, status) pairs under the rename rule, `hookmut_*` ok, test_path_scrub.sh ok | ⬜ pending |
| 14-04 T2 | 2 | MAINT-09 | BBj/claude/shellcheck-dependent files and skip branches | pairs check, source scan of literal gate names, runs with `BBJ_TEST_HOME=/nonexistent-bbj` and without claude on PATH | ⬜ pending |
| 14-03 T1 | 3 | NAME-04 | term gate over shipped scope, skills and manifests follow | `layout_no_retired_terms`, `layout_mutation_retired_term_readme`, `checkorder_*`, `layout_codex_overlay_fields`, `layout_docs_url_description`, `sh tests/ci.sh` (validate --strict) | ⬜ pending |
| 14-03 T2 | 3 | NAME-04 | term list in both conventions files, every scope and edge proven | `layout_term_list`, `layout_term_definition`, 20 `layout_mutation_*` term cases, identical '## Terms' sections, no gate name with a retired variant | ⬜ pending |
| 14-09 T1 | 3 | MAINT-09 | neverexec_ and reviewfix_; names followed into the run.sh output | HEAD-versus-tree (name, status) pairs under the rename rule, source scan of literal gate names, gate lines under the two `== file` headers of the full run | ⬜ pending |
| 14-09 T2 | 3 | MAINT-09 | last free-form names; every printed name under its file's prefixes | pairs check, source scan, awk check of the whole run against the full prefix set | ⬜ pending |
| 14-05 T1 | 4 | MAINT-09 | run.sh checks the flat block; fixture follows | `run_prefix_block ok ... CONVENTIONS.md copy identical`, `run_prefix_control`, `run_python_missing_*`, 21 identical block lines | ⬜ pending |
| 14-05 T2 | 4 | MAINT-09 | every failure rule and edge of the prefix gate | 14 `run_prefix_*` fixture cases | ⬜ pending |
| 14-06 T1 | 5 | MAINT-10 | retired-route leftovers out of the fakes | grep of the removed seams and modes empty, the five tests that use the fakes ok, 14-SWEEP.md rows S1-S4 | ⬜ pending |
| 14-06 T2 | 5 | MAINT-10 | dead SC2181 out; every sweep category re-run | `shellcheck --norc --include=SC2181` clean, function and seam scans empty, 14-SWEEP.md S5 and six 'nothing found' categories, `sh tests/ci.sh` | ⬜ pending |
| 14-07 T1 | 6 | MAINT-11 | STRUCTURE and TESTING match the tree | stale-name grep empty, every tracked tests/ file named, run_prefix_block named, no block line copied | ⬜ pending |
| 14-07 T2 | 6 | MAINT-11 | ARCHITECTURE and CONCERNS current | stale-name grep empty, shipped mechanisms named, no block-grammar line, open concerns only | ⬜ pending |
| 14-08 T1 | 7 | MAINT-11 | STACK, INTEGRATIONS, CONVENTIONS, PROJECT.md sources current | stale-name grep empty, '## Terms' kept, SC2181 absent, run_prefix_block identical copy | ⬜ pending |
| 14-08 T2 | 7 | MAINT-11 | CLAUDE.md regenerated, no-op regeneration, map stamped | scratch `generate-claude-md` byte-identical, stale-name grep empty, 7 stamped files, `layout_no_retired_route`, `layout_no_old_server_name`, `layout_no_removed_pages`, `layout_term_list`, `sh tests/ci.sh` | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/test_layout.py` — term gate and its mutation cases; optional removed-page-name gate (NAME-04, DOCS-05)
- [ ] `tests/test_release_text.py` (+ mutation lines) — Verified-cells gate (DOCS-07)
- [ ] `tests/run.sh` + `tests/test_ci_gates.sh` — prefix gate and fixture-based mutation proof (MAINT-09)
- [ ] `14-SWEEP.md` and the cell-audit record (MAINT-10, DOCS-07)

No framework install needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Environment-dependent gate names (BBj, shellcheck, claude CLI present/absent) all fall under a listed prefix | MAINT-09 | CI lacks BBj; this host has it | run single test files with `BBJ_TEST_HOME=/nonexistent-bbj` and check every printed name matches a listed prefix |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
