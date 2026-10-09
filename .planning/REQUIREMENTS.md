# Requirements: bbj-agent-plugins 0.2.0

**Defined:** 2026-10-09
**Core Value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t` and `bbj-ls`).

## v1 Requirements

### Vendoring

- [ ] **VEND-01**: `skills.lock.json` and `tests/test_skills_hash.py` are removed; no test, script or doc references them
- [ ] **VEND-02**: README, NOTICE, both manifests and `docs/install-claude-code.md` describe the skills as maintained in this repository; no "vendored" or "the BBjSkills" wording remains, and NOTICE carries no provenance line
- [ ] **VEND-03**: The skills exemptions in `tests/test_layout.py` (e.g. `docs_host_single_source`) are updated so the skills fall under the normal layout and URL rules

### Local check route

- [ ] **LOCAL-01**: The Codex installer's server-block logic is parameterised by server name and tool list; existing `bbj-docs` tests stay green after the refactor
- [ ] **LOCAL-02**: `install-codex.sh --with-local` writes one managed `bbj-local` block (`http://127.0.0.1:5009/mcp`, the three tools `bbj_check_syntax`, `bbj_format`, `bbj_denum` at `approval_mode = "approve"`) with its own markers; reruns update in place; a lone end marker is tolerated
- [ ] **LOCAL-03**: Without `--with-local`, the installer probes `bbj-ls` with one `tools/list` POST (no user code); if it answers, the installer suggests `--with-local` and writes nothing for it
- [ ] **LOCAL-04**: With `--with-local` and a probe that gets no answer, the installer registers the server anyway and prints a warning
- [ ] **LOCAL-05**: One canonical check-order block (`bbjcpl`, then local `bbj-ls`, then the hosted check only when neither exists, noting it sends code to the server and checks against a stock BBj) appears byte-identical in `codex/AGENTS-snippet.md` and both SKILL.md files, pinned by a test; it uses no client-qualified tool names
- [ ] **LOCAL-06**: `docs/install-claude-code.md`, `docs/install-codex.md` and README present `bbj-local` as the preferred check route with the two reasons (code stays on the machine; checked against the installation's own PREFIX, classpath and config)
- [ ] **LOCAL-07**: `tests/test_install_codex.sh` covers the flag, the probe (suggest only), probe failure with the flag, reruns and a lone marker; `tests/fake_mcp.py` gains a `tools/list` mode

### Hook

- [ ] **HOOK-01**: `bbj-check.sh` distinguishes clean / errors / no route / route failed; a clean file never produces the notice
- [ ] **HOOK-02**: With no check route, the hook exits 0 and emits one JSON `hookSpecificOutput.additionalContext` object once per session (`mkdir`-atomic marker keyed by `session_id`, `BBJ_CHECK_STATE_DIR` test seam); the text says the file was written but not checked, how to enable `bbjcpl` (`bbj_home`) or `bbj-local`, and names the hosted check in one clause as a fallback that sends code to the server
- [ ] **HOOK-03**: `tests/test_exit_contract.sh` is amended narrowly (stdout holds exactly that JSON object in the no-route case, empty otherwise) and the silent-path tests are converted to "first call notice, then silent"
- [ ] **HOOK-04**: Notice delivery is verified on a real Codex after `apply_patch`; if `additionalContext` does not reach the model there, Codex alone falls back to exit 2 with stderr

### Example gate

- [ ] **GATE-01**: Fence grammar enforced: `bbj` must pass; `bbj should-fail` must fail on at least one route; `bbj nocheck (reason)` is skipped and needs a reason; non-BBj languages are ignored; untagged fences, unknown attributes, unclosed fences and `...` placeholders in `bbj` blocks fail the lint
- [ ] **GATE-02**: The lint (extraction and grammar) runs in CI without BBj
- [ ] **GATE-03**: The live check runs `bbjcpl -t -N -X` batched over all blocks, then `bbj-ls`; a `bbj` block must pass every available route; it skips without BBj, and `BBJ_SKILLS_LIVE=1` turns a missing route into a failure
- [ ] **GATE-04**: The count of `bbj nocheck` blocks is ratcheted: the gate fails if it grows above the recorded number
- [ ] **GATE-05**: Structure lints: skill description ≤ 1,024 characters; a denylist of project leftovers (`DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches!`, `cart-updated`, fixed install paths like `/opt/basis/bin/`); each reference file ends with a Sources section and a "Verified on BBj <version>" line
- [ ] **GATE-06**: A baseline report of the current skills against the gate is committed and serves as the makeover to-do list

### bbj-programming makeover

- [ ] **PROG-01**: A claim ledger classifies every claim in the skill and its references as DOC (URL, with a quoted sentence where the page is not explicit), COMPILE (`bbjcpl`/`bbj-ls` output with BBj version) or RUNTIME; RUNTIME claims are rewritten to their compile-time observable or dropped
- [ ] **PROG-02**: SKILL.md puts the check workflow first, has a body of about 150 lines or fewer, and points to the docs tools and `bbj://primer` instead of copying reference tables
- [ ] **PROG-03**: The skill keeps only rules the primer lacks (plus the REM/`;` rule the hook enforces), including: bare method calls (`v!.get(0)`, `#foo()`) are valid statements but a bare function-style call `name(args)` is not; "Built in: no USE needed" scoped to BBj classes and `java.lang`; the `bbjcpl -t -N -X` output quirks on 26.03
- [ ] **PROG-04**: Known wrong claims are corrected (`LIMIT` is documented, `str()` mask example, "parse stdout" of `bbjcpl`, `HashMap`/`ArrayList` without `USE`); all taste (`PRECISION 16`, `Utils` class, `q`/`k`/`wi` naming, size-guard rule, etc.) and project leftovers are cut
- [ ] **PROG-05**: Launcher facts are kept only where verified, framed as applying when the user asks to run a program
- [ ] **PROG-06**: Every `bbj` block in the skill and its references passes the gate; the skill name `/bbj:bbj-programming` is unchanged

### bbj-web-programming makeover

- [ ] **WEB-01**: The same claim ledger covers the skill and its references; DWC DOM/CSS claims (DOM structure, `addOuterStyle`, focus-ring padding rule) survive only with a docs URL or an owner reproduction recorded with the DWC/BBj build
- [ ] **WEB-02**: The description is ≤ 1,024 characters with the triggers first; the body is short and references trimmed; all taste is cut (GSAP, Swiper, Tabler Icons, Google Fonts/Inter/Playfair Display, the 420px card grid, etc.)
- [ ] **WEB-03**: The `injectStyle` `top` claim is corrected to the documented meaning; every `bbj` block passes the gate; the skill name `/bbj:bbj-web-programming` is unchanged

### Release

- [ ] **REL-01**: `plugins/bbj`, `plugins/bbj-local`, the marketplace entries and `tests/test_layout.py` `VERSION` move to 0.2.0 in one commit; `claude plugin validate --strict` passes
- [ ] **REL-02**: CHANGELOG has a 0.2.0 entry with Codex upgrade notes (`--force` to replace the skills, `/hooks` re-approval of the changed hook) and a "Tested against" section rewritten from the actual run
- [ ] **REL-03**: The full suite passes with `skip=0` on the live gates (`BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`), and an install from the git marketplace source passes
- [ ] **REL-04**: The release is tagged `0.2.0`

## v2 Requirements

### Maintenance

- **MAINT-01**: The docs URL go-live change is a single constant the tests read
- **MAINT-02**: `--force` moves replaced skill directories and rewritten config files to a backup first
- **MAINT-03**: Hook and installer share one implementation of discovery, loopback validation and JSON escaping
- **MAINT-04**: Per-block staleness stamp (BBj version last checked)
- **MAINT-05**: Codex native plugin format replaces `install-codex.sh`

## Out of Scope

| Feature | Reason |
|---------|--------|
| Fate of the BBjSkills repository | Handled outside this repo |
| Docs-server drift check / primer pin on BBjSkills | Tracked in the docs-server repo |
| Configurable `bbj-local` URL | Stays fixed at `127.0.0.1:5009` |
| Taste kept as labelled suggestions | Decision: cut all taste |
| Hosted `bbj_check_syntax` in CI for skill examples | Gate is local-only by decision |
| Executing BBj to verify runtime claims | Never-execute rule; compile-time proxy instead |
| NOTICE provenance line for BBjSkills | Decision: not kept |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| (filled by roadmap) | | |

**Coverage:**
- v1 requirements: 33 total
- Mapped to phases: 0
- Unmapped: 33 ⚠️

---
*Requirements defined: 2026-10-09*
*Last updated: 2026-10-09 after initial definition*
