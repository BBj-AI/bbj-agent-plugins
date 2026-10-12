---
phase: 01-repo-owned-skills-and-local-first-check-route
fixed_at: 2026-10-09T00:00:00Z
review_path: .planning/phases/01-repo-owned-skills-and-local-first-check-route/01-REVIEW.md
iteration: 1
findings_in_scope: 8
fixed: 6
skipped: 2
status: partial
---

# Phase 1: Code Review Fix Report

**Fixed at:** 2026-10-09
**Source review:** .planning/phases/01-repo-owned-skills-and-local-first-check-route/01-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 8 (CR-01, WR-01, WR-02, WR-03, IN-01, IN-02, IN-03, IN-04)
- Fixed: 6
- Skipped: 2 (WR-03 and IN-03, both by instruction)

**Verification:** `sh tests/run.sh` was run in the isolated review-fix worktree (a git worktree of this
repository at `.claude/worktrees/rf-01-...`, no `node_modules`; the repository has none). Result after
the last fix: `SUMMARY: ok=447 fail=0 skip=2` (436 ok before, plus the new gates). ShellCheck is not
installed on this machine, so its gates were skipped; `sh -n` passed on every changed script. Each new
gate was also run against the pre-fix installer or guard and failed there, so it pins the defect.

## Fixed Issues

### CR-01: A managed block with its table deleted is re-registered on a run without `--with-local`

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`, `docs/install-codex.md`
**Commit:** fc871da
**Applied fix:** The flagless in-place refresh now needs both the begin marker and the table
(`managed = 1` and `main = 1`). Markers without a table and no flag: no probe, no write, no line of
output (chosen over printing a note because it matches how a hand-registered `bbj-local` is treated,
"never probed and never mentioned without the flag", and a note on every run would nag a user who removed
the entry on purpose). With `--with-local` and markers without a table, `sync_server` no longer appends a
whole second block: it puts `[mcp_servers.SRV]` and the url back inside the existing markers (before the
end marker, or, when no end marker follows the begin marker, right after the begin marker together with a
new end marker), so there is never a second begin marker. The same branch covers `bbj-docs`, which shared
the defect. The tool approvals are then added by the existing pass. New gates:
`local_markers_without_table_no_flag`, `local_markers_without_table_with_flag`,
`local_markers_table_inside`, `local_begin_marker_alone`, `local_markers_without_table_no_probe`.
`docs/install-codex.md` states that a rerun without the flag leaves the removal in place.

### WR-01: `curl_gate` skips every curl call that shares a line with ` say "`

**Files modified:** `tests/test_static_guards.sh`
**Commit:** 9d0bcee
**Applied fix:** `curl_gate` is split into `curl_check` (sets the verdict) and `curl_gate` (emits the gate;
gate names unchanged). The exclusion is anchored to a line that is nothing but one `say "..."`, optionally
behind a case-arm label such as `nocurl)` and followed by `;;`. A say whose text contains `$(` or a
backtick is not excused either (it would run a command), which goes slightly beyond the review's regex.
New mutation gates: `static_curl_say_not_excused` (six lines such as
`r=$(curl -sL ...) && say "done"` and `curl -L --url "$u"; say "ok"` must FAIL the guard) and
`static_curl_say_messages_ok` (the real message lines, a `command -v curl` test and a safe call followed
by a say must pass).

### WR-02: Foreign-form detection is a substring match

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`
**Commit:** c620fba
**Applied fix:** `analyze` sets `mention` only for real definitions: a header whose key under
`mcp_servers` is exactly the server name (any quote and space spelling, optional `[[`), a key that starts
with the name under a plain `[mcp_servers]` table, and a dotted key starting with `mcp_servers` at the top
level or under `[mcp_servers]`. The name inside `[projects."..."]` headers or string values is ignored.
Server names that merely contain the name (`my-bbj-local`) no longer count either. All existing
`foreign_toml_form`, `foreign_tool_forms` and `local_foreign_forms` gates still exit 3 unchanged. New
gates: `local_name_in_path_not_foreign` (a `[projects]` path and a string value naming both servers:
exit 0, both registered, rerun byte-identical), `local_name_in_path_is_probed` (flagless run probes and
suggests), `local_foreign_key_forms` (top-level dotted key and a quoted key under `[mcp_servers]` still
exit 3, config byte-identical).
Not changed: the "registering it anyway" warning is still printed before a real foreign-form refusal
(the second half of the review's fix text); with the false positive gone it only appears for a real
foreign definition, and moving it would touch the pinned warning matrix.

### IN-01: `extract()` in `tests/test_check_order.py` is dead code

**Files modified:** `tests/test_check_order.py`
**Commit:** 09da0d5
**Applied fix:** Deleted the unused function (no caller anywhere in `tests/`).

### IN-02: Inserted lines are LF-only inside a CRLF `config.toml`

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`
**Commit:** 05022c7
**Applied fix:** A new `config_cr` helper reads the first line of `config.toml`; when it ends in a carriage
return, every inserted line (the appended block and its separator, the missing tool tables, the approval
key, and the restored table of CR-01) ends in one too. LF files are unchanged byte for byte. New gate
`crlf_config_stays_crlf` covers three CRLF cases (tool tables added, block appended, table restored
between markers): no line without a carriage return, file still parses.

### IN-04: Ambiguous "step 2" references on the Codex page

**Files modified:** `docs/install-codex.md`
**Commit:** 84649c7
**Applied fix:** Both references now read `see section 2, "Enable the local check"`. `tests/test_install_pages.sh`
and `tests/test_layout.py` stay green.

## Skipped Issues

### WR-03: The check-order block tells the agent it may send the user's code to the hosted server without asking

**File:** `codex/AGENTS-snippet.md` (check-order block, item 3); both `SKILL.md` files; `tests/test_check_order.py`
**Reason:** conflicts with locked user decision D-01 ("use the hosted check without asking, and tell the
user"); escalated to user. The wording is also pinned by `tests/test_check_order.py` ("without asking").
Whether to change D-01 is the user's call.
**Original issue:** The block pre-authorizes the one action that leaves the machine, and disclosure comes
after the transfer; the review proposed requiring consent before the first hosted use in a session.

### IN-03: `CHANGELOG.md` still describes the removed vendoring and a deleted file

**File:** `CHANGELOG.md:41`
**Reason:** skipped by instruction: the 0.1.0 entry is deliberately historical per the phase plans, and
`tests/test_layout.py` exempts the file on purpose. The missing release entry for this phase's changes
is not covered by this fix run.
**Original issue:** "BBjSkills: commit `79f19822ab82`, vendored byte for byte (see `skills.lock.json`)"
points at a file this phase deletes; no entry for `--with-local`, the probe and the check-order block.

---

_Fixed: 2026-10-09_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
