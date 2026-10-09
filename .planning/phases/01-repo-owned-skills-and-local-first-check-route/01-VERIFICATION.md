---
phase: 01-repo-owned-skills-and-local-first-check-route
verified: 2026-10-09T19:00:00Z
status: human_needed
score: 4/5 must-haves verified
behavior_unverified: 0
overrides_applied: 0
re_verification: null
coincidental_reliance_items: []
human_verification:
  - test: "Decide whether CHANGELOG.md line 41 (0.1.0 entry) may keep naming the removed lock file"
    expected: "Either accept it as historical release-note text (add an override, see Gaps Summary) or reword/remove the line so the grep-zero for VEND-01 'no doc references them' is literal"
    why_human: "VEND-01 and roadmap SC1 say 'no test, script or doc references them'; CHANGELOG.md:41 still reads 'vendored byte for byte (see `skills.lock.json`)' and line 9 still says 'the two BBjSkills'. Plan 01-01 and an orchestrator ruling excluded CHANGELOG as historical, but no override is recorded and the 0.1.0 entry is marked 'unreleased' (never tagged)"
  - test: "Escalated review finding WR-03: confirm or change locked decision D-01 ('use the hosted check without asking, but tell the user')"
    expected: "A user ruling. If D-01 stays, the check-order block, tests/test_check_order.py ('without asking') and the three copies stay as they are. If D-01 changes, update the block in all three files and the pin test together"
    why_human: "The block lets the agent send code to the hosted server first and disclose afterwards; the code reviewer flagged this as a consent problem. It conflicts with a locked user decision, so it is a user question and not a gap. Also covers the judgment-tier prohibition on 01-05 (see below)"
  - test: "Load the two SKILL.md files in a real Codex (skills in ~/.agents/skills) and confirm both skills are listed and invocable"
    expected: "Both skills appear; the HTML-comment markers `<!-- bbj-check-order:begin/end -->` placed between the frontmatter and the H1 do not break parsing and do not show up in the description"
    why_human: "Needs a Codex skill loader run. The frontmatter is intact and first in each file, and the markers sit in the body, but no test exercises Codex's loader"
  - test: "Run the CI pipeline once so the ShellCheck gate executes on codex/install-codex.sh, tests/test_static_guards.sh, tests/test_install_codex.sh, tests/test_install_pages.sh"
    expected: "ci_shellcheck / shellcheck gate prints ok (CI=true, so a missing shellcheck is a FAIL)"
    why_human: "shellcheck and busybox are not installed locally; both gates were skipped here (skip=2). `sh -n` and dash/bash runs pass"
  - test: "Judgment-tier prohibitions (non-authoritative LLM verdict, human review recommended): (a) 01-05 'check-order text MUST NOT let an agent send code to the hosted check without telling the user'; (b) 01-07 'docs MUST NOT present bbj-local as better or earlier than bbjcpl, imply it type-checks, or hide that the hosted check sends code off the machine'"
    expected: "(a) The block does say the user must be told that the code was sent and checked against a stock BBj, but telling happens after the transfer (see WR-03). (b) README, both install pages and the block state bbjcpl is first and type-checks, bbj-local is syntax only, and the hosted check sends code to the server; no violation found"
    why_human: "unverified-prohibition: judgment-tier items are never silently passed (ADR-550 D4)"
---

# Phase 1: Repo-owned skills and local-first check route Verification Report

**Phase Goal:** The skills are maintained in this repository rather than vendored, and Codex users can register the local `bbj-ls` check with one flag, with docs and shared text presenting the local check as the preferred route.
**Verified:** 2026-10-09T19:00:00Z
**Status:** human_needed
**Re-verification:** No, initial verification

All code-level truths hold in the codebase and under my own runs of the installer. No FAILED truth. One roadmap criterion (SC1) carries a literal discrepancy in `CHANGELOG.md` that needs a user ruling, and one reviewer finding (WR-03) is a deliberately escalated user question. Neither is counted as a gap.

## Goal Achievement

### Observable Truths (roadmap contract)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | A maintainer can edit any file under `plugins/bbj/skills/` and the suite still passes; `skills.lock.json` and `tests/test_skills_hash.py` gone, nothing references them, skills fall under the normal layout/URL rules | ? UNCERTAIN (WARNING) | Files absent (`ls` fails on both). I appended lines to a skill reference and to `bbj-web-programming/SKILL.md` in a scratch copy and ran `sh tests/run.sh`: ok=446, the single FAIL (`layout_script_mode`) is an artifact of my `git init` without `git add`, not of the edit. `docs_host_single_source` (tests/test_layout.py:138-151) walks all of `plugins/` with no skills skip. Grep for `skills.lock\|test_skills_hash\|vendor\|BBjSkills` outside `.planning` and `.gsd` finds only `CHANGELOG.md:9` and `CHANGELOG.md:41`. Those are the literal "doc references them" the requirement forbids; see Gaps Summary |
| 2 | README, NOTICE, both manifests and `docs/install-claude-code.md` describe the skills as maintained in this repository; no "vendored" / "the BBjSkills" wording, no NOTICE provenance line | VERIFIED | NOTICE is exactly two lines (`bbj-agent-plugins`, `Copyright 2026 BASIS International Ltd.`). README has `## Skills` ("live in `plugins/bbj/skills` and are maintained in this repository"). `docs/install-claude-code.md:81` "(maintained in this repository)". Gates `layout_no_vendoring_wording` (7 texts) and `layout_notice_no_provenance` pass in my run. `.claude/CLAUDE.md` and `.planning/codebase/*` grep clean (D-16) |
| 3 | `--with-local` writes exactly one managed `bbj-local` block (fixed URL, three tools approved); rerun updates in place; lone end marker tolerated; `bbj-docs` tests green after refactor | VERIFIED | Ran the installer in scratch homes (no codex on PATH): fresh run wrote one block with `url = "http://127.0.0.1:5009/mcp"` and `bbj_check_syntax`, `bbj_format`, `bbj_denum` at `approval_mode = "approve"`; rerun left `config.toml` byte-identical (cmp) with one begin marker. Lone end marker plus the flag gave a fresh block after it, exit 0. Hand-registered exact-URL table gained approvals, exit 0; other URL gave exit 3 and the file untouched. Old (commit 195668a) vs new installer on a fresh home: `config.toml` identical and `bbj-docs` lines identical; the only new output line is the probe line. Real Codex 0.156.1 was on PATH: `real_codex_parses_configs ok 53 configs` and `real_codex_install ok` (not skipped) |
| 4 | Without the flag one `tools/list` probe (no user code) suggests `--with-local` only when `bbj-ls` answers; with the flag and no answer it registers anyway and warns; tests cover flag, probe, failure, reruns, lone marker | VERIFIED | Against `tests/fake_mcp.py --mode tools-list`: no-flag run exited 0, printed `a bbj-ls answers at ... Rerun with --with-local ...; nothing was written for it`, `config.toml` held no `bbj-local`; the fake's log shows exactly one POST with a static `tools/list` body, headers `Mcp-Method: tools/list` and no project data. With flag and closed port: `warning: no bbj-ls answered ...; registering it anyway`, block written, exit 0. Gates seen ok: `probe_request_shape`, `probe_curl_flags`, `probe_found_suggests`, `probe_no_answer_no_flag`, `probe_no_curl`, `probe_refuses_non_loopback_seam`, `probe_other_server_no_suggestion`, `probe_never_changes_exit`, `local_lone_end_marker*`, `local_rerun_*`, `local_kept_without_flag`, `local_markers_without_table_*` (CR-01 fix) |
| 5 | One check-order block byte-identical in `codex/AGENTS-snippet.md` and both SKILL.md files, a test fails on drift; README and both install pages present `bbj-local` as preferred with its two reasons | VERIFIED | Independent hash of the text between the markers: all three copies `bf5441eb14f2`, one marker pair each. Mutating one copy in a scratch tree made `checkorder_identical FAIL bbj_web_programming differs from the snippet copy`. Block is directly after the frontmatter (line 6) in both skills, replaces the `Check:` paragraph in the snippet (line 23) with the shell-command sentence outside it, names `bbjcpl -t -N -X <file>`, no hosted address, no client-qualified tool name (gate `checkorder_client_neutral`). README, `docs/install-claude-code.md` step 3 and `docs/install-codex.md` step 2 give the two reasons and state `bbjcpl` stays first and `bbj-local` is syntax only |

**Score:** 4/5 truths verified (1 uncertain, needs a user ruling); behavior-dependent installer truths (rerun idempotency, probe outcomes, marker handling) were exercised by named tests and by my own runs, so none is presence-only.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `skills.lock.json`, `tests/test_skills_hash.py` | Deleted | VERIFIED | Both absent; `tests/run.sh`, `tests/ci.sh` carry no reference |
| `tests/test_layout.py` | Skills exemption removed; four new gates | VERIFIED | `no_skills_lock`, `skills_not_executable`, `no_vendoring_wording`, `notice_no_provenance` all ok; forbidden words assembled from pieces per convention |
| `codex/install-codex.sh` | `sync_server` parameterised, `use_docs`/`use_local`, `--with-local`, `probe_local` | VERIFIED | 794 lines; `sync_server` at 430, `use_local` sets `LOCAL_TOOLS`/`LOCAL_URL`, `probe_local` at 640 |
| `tests/fake_mcp.py` | `tools-list` and `tools-list-other` modes | VERIFIED | Present, exercised above; `test_tier2_fake.sh` still green |
| `tests/test_check_order.py` | Pin test, `checkorder_*` gates | VERIFIED | 10 gates, fails on mutation |
| `tests/test_install_codex.sh`, `tests/test_install_pages.sh`, `tests/test_static_guards.sh` | New gates | VERIFIED | `local_*` (33 distinct), `probe_*`, `crlf_config_stays_crlf`, page gates, `curl_gate` extended to `codex/*.sh` |
| `codex/AGENTS-snippet.md`, both `SKILL.md` | Block in place; D-08 untouched | VERIFIED | `git diff --numstat` against phase start: +10/-0 in each SKILL.md; old "parse stdout" section at `bbj-programming/SKILL.md:383` untouched for Phase 4 |
| `README.md`, `docs/install-*.md`, `NOTICE`, manifests | Wording and preferred-route text | VERIFIED | Read in full |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `tests/test_layout.py` | `plugins/bbj/skills` | `os.walk` over `plugins/`, no skip | WIRED | Lines 138-151 |
| `tests/run.sh` | `tests/test_check_order.py` | glob `tests/test_*.py` | WIRED | Gates appear in the run output |
| option parser | `sync_server` for `bbj-local` | `--with-local` or `managed=1` and `main=1` | WIRED | Behaviour confirmed by runs |
| `probe_local` | loopback `bbj-ls` | one-line `curl` POST, `Mcp-Method: tools/list` | WIRED | Confirmed in fake log; `curl_gate` enforces `--noproxy '*'`, `--proto =http`, no `-L` on the installer |
| installer section 5 | `AGENTS-snippet.md` | `cat` between `----8<----` | WIRED | Snippet, markers included, printed in my run |
| install pages | installer messages / `LOCAL_TOOLS` | `codex_quoted_messages_in_installer`, `codex_local_tools_single_source` | WIRED | Gates ok |

### Data-Flow Trace (Level 4)

Not applicable: no component renders dynamic data. The installer's data flow (analysis of `config.toml`, then the rewrite pass, then the file) was traced by the byte-comparison runs above.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite | `sh tests/run.sh` | `SUMMARY: ok=447 fail=0 skip=2` (58 s); skips are `shell_busybox` and `shellcheck` | PASS |
| Real Codex loads written configs | gate `real_codex_parses_configs` | `ok 53 configs` (codex 0.156.1 on PATH, not skipped) | PASS |
| Manifests | `claude plugin validate --strict .` | Validation passed | PASS |
| Fresh `--with-local`, rerun | scratch HOME, no codex on PATH | one block, rerun byte-identical, exit 0 | PASS |
| Probe suggest-only | fake server `tools-list` | one request, suggestion, nothing written, exit 0 | PASS |
| Lone end marker, hand-registered same URL, foreign URL | scratch homes | exit 0 / 0 / 3 as specified | PASS |
| bbj-docs unchanged by refactor | old vs new installer, fresh home | `config.toml` identical; only the new probe line differs | PASS |
| Pin test catches drift | mutate one copy | `checkorder_identical FAIL` | PASS |
| Skill edit keeps suite green | edit two skill files in a scratch copy | no skill-related failure | PASS |

### Probe Execution

SKIPPED: no `probe-*.sh` conventions or PLAN-declared probe scripts exist for this phase.

### Requirements Coverage

All ten IDs appear in PLAN frontmatter (01-01: VEND-01..03; 01-02: VEND-01; 01-03: LOCAL-01; 01-04: LOCAL-01, 02, 07; 01-05: LOCAL-05; 01-06: LOCAL-03, 04, 07; 01-07: LOCAL-06) and in REQUIREMENTS.md. No orphans: REQUIREMENTS.md maps exactly these ten to Phase 1.

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| VEND-01 | 01-01, 01-02 | Lock file and hash test removed; no test, script or doc references them | ? NEEDS HUMAN | Files gone; no reference in tests, scripts, docs, README, `.claude`, `.planning/codebase`. Literal exception: `CHANGELOG.md:41` |
| VEND-02 | 01-01 | Skills described as maintained here; no "vendored" / "the BBjSkills"; no NOTICE provenance | SATISFIED | Listed files clean (CHANGELOG is not in the VEND-02 file list) |
| VEND-03 | 01-01 | Skills exemptions in `test_layout.py` removed | SATISFIED | No exemption; host rule covers the skills; new executable-bit gate |
| LOCAL-01 | 01-03, 01-04 | Server-block logic parameterised; bbj-docs tests green | SATISFIED | `sync_server` / `use_docs` / `use_local`; old-vs-new comparison identical |
| LOCAL-02 | 01-04 | `--with-local` writes one managed `bbj-local` block, reruns in place, lone end marker tolerated | SATISFIED | Runs above |
| LOCAL-03 | 01-06 | Probe without the flag, suggest only | SATISFIED | Fake-server run and gates |
| LOCAL-04 | 01-06 | Flag with no answer registers anyway and warns | SATISFIED | Run above |
| LOCAL-05 | 01-05 | Canonical block byte-identical in snippet and both SKILL.md, pinned, no client-qualified names | SATISFIED | Hash match and mutation test (consent wording: see WR-03 item) |
| LOCAL-06 | 01-07 | Docs present `bbj-local` as preferred with two reasons | SATISFIED | README, both install pages read in full |
| LOCAL-07 | 01-04, 01-06 | Installer tests for flag, probe, probe failure, reruns, lone marker; fake `tools/list` mode | SATISFIED | Gates listed under truth 4 |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| (all 21 files changed in the phase) | - | TBD / FIXME / XXX / TODO / HACK in added lines | none found | No debt markers |
| `CHANGELOG.md` | 41, 9 | Names `skills.lock.json` and "the two BBjSkills" | WARNING | See truth 1 and the human items |
| `.claude/CLAUDE.md` | 183 | Lists the `skills_` gate prefix; no `skills_` gate exists after `test_skills_hash.py` was removed | INFO | Harmless stale convention text |
| `codex/install-codex.sh` | n/a | The `registering it anyway` warning is still printed just before a real foreign-form refusal (exit 3); the fixer left this on purpose (REVIEW-FIX, WR-02) | INFO | Cosmetic; observed in my foreign-URL run |
| `.planning/ROADMAP.md` | Phase 1 | Phase checkbox unchecked and progress row says "In Progress" although 7/7 plans are done | INFO | Bookkeeping for the orchestrator |

The review's CR-01, WR-01, WR-02, IN-01, IN-02 and IN-04 fixes are present in the code and gated; I re-ran the CR-01 and WR-02 behaviours through the suite (`local_markers_without_table_*`, `local_name_in_path_*` ok). The review report's 8 findings have no remaining unresolved item beyond WR-03 and IN-03 (the same CHANGELOG question).

### Human Verification Required

See the `human_verification` list in the frontmatter. In short:

1. **CHANGELOG ruling** (decision): accept as historical (override) or reword line 41 and line 9.
2. **WR-03 / D-01** (user question, not a gap): keep "use the hosted check without asking, but tell the user", or require consent first.
3. **Codex skill loader**: the HTML-comment markers sit between frontmatter and H1 in both SKILL.md files.
4. **ShellCheck in CI**: skipped locally.
5. **Judgment-tier prohibitions**: flagged `unverified-prohibition`, my reading found no violation beyond the WR-03 disclosure-timing question.

### Gaps Summary

No FAILED must-have. One item is a candidate gap pending a ruling:

- **CHANGELOG.md still references the removed lock file** (`CHANGELOG.md:41`: "vendored byte for byte (see `skills.lock.json`)"; line 9: "the two BBjSkills"). VEND-01 and roadmap SC1 say "no ... doc references them". Plan 01-01 deliberately left the never-tagged 0.1.0 entry as history, and `tests/test_layout.py` does not scan CHANGELOG, so the suite cannot see it. Phase 6 (REL-02) writes the 0.2.0 entry but does not say it rewrites the 0.1.0 text, so I did not defer it. If the maintainer accepts the historical reading, record:

```yaml
overrides:
  - must_have: "skills.lock.json and tests/test_skills_hash.py are gone, nothing references them"
    reason: "CHANGELOG.md 0.1.0 entry is historical release text (never tagged); deliberate decision in plan 01-01"
    accepted_by: "{name}"
    accepted_at: "{ISO timestamp}"
```

  Otherwise, a one-line edit of the CHANGELOG makes the requirement literally true; the fix is tiny and `/gsd-plan-phase --gaps` is not needed.

Also treat WR-03 as the escalated user question the review fix report records, not as a gap.

---

_Verified: 2026-10-09T19:00:00Z_
_Verifier: Claude (gsd-verifier)_

## User rulings (2026-10-09)

- **CHANGELOG (VEND-01 / SC1):** reword. `CHANGELOG.md` lines 9 and 41 no longer name the upstream repository or the lock file; `tests/test_layout.py` gates `no_skills_lock` and `no_vendoring_wording` now scan `CHANGELOG.md` (mutation-checked). Commit 718c77c. The candidate gap is closed.
- **WR-03 / D-01:** keep D-01. The agent may use the hosted check without asking and must tell the user afterwards. Accepted, not a gap.
