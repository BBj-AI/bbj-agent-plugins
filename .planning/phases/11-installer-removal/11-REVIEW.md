---
phase: 11-installer-removal
reviewed: 2026-10-15T00:00:00Z
depth: standard
files_reviewed: 15
files_reviewed_list:
  - .claude/CLAUDE.md
  - README.md
  - docs/install-claude-code.md
  - docs/install-codex.md
  - plugins/bbj/scripts/bbj-check.sh
  - tests/ci.sh
  - tests/lib.sh
  - tests/run.sh
  - tests/test_check_order.py
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_noroute_notice.sh
  - tests/test_release_text.py
  - tests/test_release_text_mutation.sh
  - tests/test_static_guards.sh
findings:
  critical: 0
  warning: 3
  info: 4
  total: 7
status: issues_found
---

# Phase 11: Code Review Report

**Reviewed:** 2026-10-15
**Depth:** standard
**Files Reviewed:** 15
**Status:** issues_found

## Summary

Reviewed the diff against `abb3a63`. `sh tests/run.sh` passes (ok=751, fail=0, skip=0) and
`shellcheck -s sh` over `tests/*.sh` and `plugins/bbj/scripts/*.sh` is clean. No file outside
`.planning/` references the deleted installer files, the fake `codex`, `home_snapshot`/`home_diff`
or `FAKE_CODEX_EXIT`. The hook change is correct: the `apply_patch` arm of `notice()` now has one
text and `CLAUDE_PLUGIN_ROOT` is no longer read by the script. The hook exit contract (0/2, empty
stdout apart from the notice object) is unchanged.

No blockers. The findings are one stale user-facing claim, one gate that fails open into a different
scan set, and one mutation set that does not prove one of the three curl checks.

## Warnings

### WR-01: Codex page "Not covered" names a hook matcher that no longer exists anywhere

**File:** `docs/install-codex.md:200`
**Issue:** "Edits made by tools outside the matcher `apply_patch|Edit|Write`." That matcher string
was the one `install-codex.sh` wrote into `hooks.json`. The only route left is the plugin, whose
`plugins/bbj/hooks/hooks.json` carries `"matcher": "Write|Edit"`. The page now documents a matcher
the user can neither see nor configure, and it contradicts the file the plugin ships. The decision
to leave no installer trace (D-01) made this line unverifiable; the gate in
`tests/test_install_pages.sh` only requires the bare word `apply_patch`, so nothing catches it.
**Fix:** State what the plugin ships and what Codex was observed to do, for example:
```
- Edits made by tools outside the plugin's hook matcher (`Write|Edit`; Codex sends a patch as
  `apply_patch`, which the hook handles).
```
Or drop the matcher string and say "tools other than `apply_patch`".

### WR-02: `layout_no_retired_route` silently switches to a different scan set when `git ls-files` fails

**File:** `tests/test_layout.py:310-332`
**Issue:** `tracked_files()` falls back to `os.walk` whenever `git ls-files` returns no output.
That covers a mutation copy, but also a real checkout where git fails (dubious-ownership
`safe.directory` error, `GIT_DIR` set, git missing). In walk mode only `.git` and the top-level
`.planning` are pruned, so untracked and ignored trees are scanned. I reproduced it:
```
mkdir -p .github/ci-tools/node_modules/x; echo "an installer script" > .../x/a.js
GIT_DIR=/nonexistent python3 -I tests/test_layout.py "$PWD"
-> gate layout_no_retired_route FAIL files naming the retired route: ['.github/ci-tools/node_modules/x/a.js:installer']
```
`tests/ci.sh` runs `npm ci` into `.github/ci-tools`, so a CI container where git cannot read the
repository would make this gate fail on npm package text for a reason unrelated to the change. The
detail line does say "walk mode", but only on success; the failure message does not name the mode.
**Fix:** Walk only when the caller passed a root argument (a mutation copy), and fail with a clear
message when git is expected but unusable:
```python
if out: mode = "git"
elif len(sys.argv) > 1: mode = "walk"
else: gate("no_retired_route", False, "git ls-files failed in the checkout"); ...
```
At minimum, prune `node_modules` in the walk and put `(%s mode)` into the FAIL detail.

### WR-03: curl guard mutation set does not prove the `--noproxy` check

**File:** `tests/test_static_guards.sh:134-149`
**Issue:** The rewritten "has teeth" cases are `curl -sL http://...`, `curl -L --url`, `curl -s --url`
(none has `--proto =http`), `curl --noproxy '*' --url` (no proto) and the `-L` case (has both flags).
No case has `--proto =http` without `--noproxy`. Deleting the `_nosafe` branch of `curl_check`
(lines 36-41) leaves every case still FAIL via `_noproto`, so `static_curl_unsafe_caught` stays green.
The old set had the same gap by construction but the whole point of this block is to prove each
sub-check can fail; the project rule is "every curl call carries `--noproxy '*'` and `--proto =http`".
**Fix:** Add a case that has only the other two properties:
```sh
  "curl --proto =http --url \"\$u\"" \
```
to the list of unsafe calls.

## Info

### IN-01: Stale comment about the removed subagent sentence

**File:** `tests/test_release_text.py:186`
**Issue:** The comment says the `on <platform>` anchor keeps "the subagent check on 2.1.294" out of
the count. Phase 11 deleted that sentence from `docs/install-claude-code.md`, so the comment describes
text that no longer exists.
**Fix:** Drop the clause: `# The "on <platform>" anchor keeps "Claude Code 2.1.281 or later" (a different fact) out of the count.`

### IN-02: Route gates in `test_noroute_notice.sh` now test a variable the script never reads

**File:** `tests/test_noroute_notice.sh:187-203, 276-286`
**Issue:** `bbj-check.sh` no longer references `CLAUDE_PLUGIN_ROOT`. `notice_codex_plugin_route`,
`notice_codex_plugin_route_no_other_steps` and `notice_codex_plugin_root_not_printed` (hostile root,
"never printed") now duplicate `notice_codex_text` with an environment variable that has no effect;
`notice_codex_one_text` is the only gate that states the actual contract. They cannot fail except
through an unrelated print of the environment, so they add run time and imply a behavior that is gone.
**Fix:** Fold `notice_codex_plugin_route*` into `notice_codex_text` and keep one hostile-root gate
(or none), leaving `notice_codex_one_text` as the contract.

### IN-03: Term `installer` matches as a substring, with no word boundary

**File:** `tests/test_layout.py:58-59, 355-360`
**Issue:** The gate matches `installer` anywhere in lower-cased text and paths, so `uninstaller`,
`preinstaller` or an unrelated phrase (for example a quoted "Windows Installer" error) fails the
suite, and the only way out is to rewrite the sentence. Probably intended (D-10 says "the word"), but
the check is a substring, not a word.
**Fix:** Use `re.compile(r"\binstaller\b", re.I)` for the word term, keep substring match for the two
file names.

### IN-04: No migration path in the docs for 0.2.0/0.2.1 installer users (accepted by D-01/D-02)

**File:** `docs/install-codex.md` (whole page), `README.md`
**Issue:** Users who ran `install-codex.sh` have a `hooks.json` entry, a skills copy under
`~/.agents/skills` and a `config.toml` block. After adding the plugin they get two hook entries and
two skill copies, and the removed `--remove` option was the only documented cleanup. The phase
context records this as a locked decision, and no text can name the script without failing
`layout_no_retired_route`, so it is not counted as a defect here. Flagged so the owner knows the
0.2.2 CHANGELOG entry (exempt from nothing) is also bound by the gate and cannot carry a migration
line either.
**Fix:** None required for this phase; revisit if support reports double hook output.

---

_Reviewed: 2026-10-15_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
