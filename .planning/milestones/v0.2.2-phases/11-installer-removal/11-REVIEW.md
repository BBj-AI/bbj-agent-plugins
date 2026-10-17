---
phase: 11-installer-removal
reviewed: 2026-10-15T00:00:00Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - tests/test_release_text.py
  - tests/test_static_guards.sh
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
---

# Phase 11: Code Review Report

**Reviewed:** 2026-10-15T00:00:00Z
**Depth:** standard
**Files Reviewed:** 2
**Status:** clean

## Summary

This is an incremental re-review. It supersedes the earlier report for commit 878ae6f. All findings of that report are dispositioned in `11-REVIEW-DISPOSITION.md` and `11-REVIEW-FIX.md`.

The scope is the two Phase 11 fix commits made after 878ae6f. Phase 12 hunks were ignored.

- **ab0fba1 (IN-01), `tests/test_release_text.py`:** The change edits a comment only. It removes the stale clause about the subagent check on 2.1.294 and the "REVIEW IN-01" reference. The comment now says the "on <platform>" anchor keeps "Claude Code 2.1.281 or later" out of the count. That matches `CLAUDE_ON_PLATFORM`, which requires "on (Linux|Windows|macOS)". No code changed, and no stale "subagent" or "REVIEW IN-01" text remains in the file.
- **098bca5 (WR-03), `tests/test_static_guards.sh`:** The change adds the mutation `curl --proto =http --url "$u"`, which has `--proto =http` but no `--noproxy`. I traced it through `curl_check`. The call is matched as a curl call, and `_nosafe` is set because `--noproxy` is missing, so `CURL_STATUS=FAIL`.
  - The mutation set now covers each branch on its own: no `--noproxy` and no `--proto` (case 3), `--noproxy` without `--proto` (case 4), `--proto` without `--noproxy` (case 5, new), and `-L` with both flags present (cases 1, 2 and 6).
  - Deleting the `--noproxy` check from `curl_check` would now fail `static_curl_unsafe_caught`. Case 3 alone could not catch that deletion, because the `--proto` check would still catch it.
  - The count in the gate message is computed (`_mut_n`), so it stays correct, and it now reads "6 unsafe curl calls are all caught".

I found no real bugs in either file.

Verification:

- `python3 -I tests/test_release_text.py` exits 0 with every `release_*` gate ok.
- `sh tests/test_static_guards.sh` exits 0 with every `static_*` gate ok, including `static_curl_unsafe_caught` (6 cases) and `static_curl_safe_passes`.
- No BBj was run.

All reviewed files meet quality standards. No issues found.

---

_Reviewed: 2026-10-15T00:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
