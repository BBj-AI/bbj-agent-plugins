# Phase 10: Install wording and release 0.2.1 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-14
**Phase:** 10-install-wording-and-release-0-2-1
**Areas discussed:** Wording shape and versions, Installer on Windows and the Git-location limit, Not run lines and Upgrading notes, Release checks beyond the Phase 6 pattern

---

## Todos (cross-reference)

| Option | Description | Selected |
|--------|-------------|----------|
| Pre-production wording (score 0.9) | Remove "pre-production instance until the go-live release" from plugin.json, README, both pages and the 0.2.1 entry; drop "trial" | ✓ |
| OAuth client handoff (score 0.6) | scopes, client id as a setting, rename to bbj, installer callback shape | ✓ (folded for `scopes` only, see area 3) |

**User's choice:** both folded.

---

## Wording shape and versions

| Option | Description | Selected |
|--------|-------------|----------|
| Compact table | Rows Claude Code / Codex plugin / Codex installer, columns Linux / Windows / macOS, cells name route(s) and client version | ✓ |
| Prose, one paragraph per client | Today's bullets grow into a sentence each | |
| Table plus a one-line summary | Table preceded by one headline sentence | |

| Option | Description | Selected |
|--------|-------------|----------|
| Per-platform versions, gate relaxed | 2.1.292 Windows, 2.1.296 macOS and Linux; `claude_version_single` becomes one version per platform | ✓ |
| One headline version, Windows version only in CHANGELOG | Pages name 2.1.296 only; gate scoped to exclude platform lines | |
| Re-run Windows on 2.1.296 first | Update Claude Code on the Windows machine and repeat the writes | |

| Option | Description | Selected |
|--------|-------------|----------|
| Keep two levels, add dates | Banner "Verified on Linux, Windows and macOS" with versions and dates; per-fact "Observed on <platform> with <versions>:" | ✓ |
| One word only: "Verified" | Drop "Observed" | |
| Banner only, no per-fact lines | Body states behaviour without naming where it was seen | |

| Option | Description | Selected |
|--------|-------------|----------|
| Route sections plus a macOS section | Route facts under the route headings; platform-only facts in `## Windows` and a new `## macOS` on both pages | ✓ |
| One "Platform notes" section per page | All five facts under one heading per page | |
| Only in CHANGELOG and the records | Pages state behaviour without the Phase 9 anecdotes | |

**User's choice:** the recommended option each time.
**Notes:** the version conflict (2.1.292 vs 2.1.296 against `claude_version_single`) was found in the records during scouting, not in the roadmap.

---

## Installer on Windows and the Git-location limit

| Option | Description | Selected |
|--------|-------------|----------|
| Fix, gate on fakes, you re-run once | PowerShell call form `& "<sh.exe>" "<script>"; exit $LASTEXITCODE`; `command_windows_cygpath` updated; one Windows re-run in a throwaway Codex home before the docs claim it | ✓ |
| Fix blind, docs say "not re-run" | Same fix, no Windows session, a Not run line | |
| Known gap, no code change | Installer route stated as not working under Codex on Windows | |

| Option | Description | Selected |
|--------|-------------|----------|
| State the limit and the alternative | Default Git location and 8.3 names needed; symptom `hook exited`; the installer named as the alternative | ✓ |
| State the limit only | No workaround named | |
| State the limit plus an untested config.toml hint | Mention `command_windows` in config.toml, unobserved | |

| Option | Description | Selected |
|--------|-------------|----------|
| One sentence in the Codex Windows section | WR-02 symptom and remedy (set BBJ_HOME or start BBjServices); no code change | ✓ |
| Not mentioned; fix later | Pages silent | |
| Fix it in this phase | One tier-2 probe per hook call; new hook logic in a release phase | |

| Option | Description | Selected |
|--------|-------------|----------|
| Three platforms, route named | "Verified with Codex CLI 0.162.1 on Linux, on macOS (bbj-local route) and on Windows (Git for Windows)." | ✓ |
| Linux and macOS only, Windows as a gap | Installer claims Windows only in the docs | |
| Point at the docs page | One line that never goes stale | |

**User's choice:** the recommended option each time, then a free-text follow-up.
**Notes:** at the "more or next" check the owner asked whether the installer could fail early on the Git location on Windows and offer a command-line option to set the `sh.exe` location. Reflected back: the installer derives `sh.exe` from the Git Bash it runs under (`cygpath -w "$(command -v sh)"`, no hardcoded location); the Phase 9 failure was the PowerShell quoting. Asked how likely Git is elsewhere; answer given: per-user installs without admin rights (`%LOCALAPPDATA%\Programs\Git`), scoop, portable Git, 32-bit, other drives, and 8.3 names off are routine. Owner's rule: "if it is to be expected we need both." Decided: early refusal (exit 2, nothing written) plus an override option (working name `--sh-exe PATH`), both validated before the first write; the Windows re-run covers the default path and the override once each.

---

## Not run lines and Upgrading notes

| Option | Description | Selected |
|--------|-------------|----------|
| Every gap, one line each, per platform | Each line names the configuration and the record; `not_run` pins the exact lines | ✓ |
| Platform-level lines only | Two or three lines; upgrade gaps folded into the Codex page | |
| Only what a user would do | Drop test-only configurations | |

| Option | Description | Selected |
|--------|-------------|----------|
| Plugin route first, installer users told to switch | Claude Code commands; Codex plugin upgrade then re-trust; installer users `--remove` then the plugin commands, `--force` as the stay path | ✓ |
| Keep the 0.2.0 shape, installer first | `--force` rerun first | |
| Two sections: plugin users, installer users | Split Upgrading by route | |

| Option | Description | Selected |
|--------|-------------|----------|
| Leave 0.2.0 as history, say it in 0.2.1 | Released entries not edited; 0.2.1 states the shorthand now installs the plugin route from main | ✓ |
| Edit the 0.2.0 bullet | Reword or drop the note in the 0.2.0 section | |

| Option | Description | Selected |
|--------|-------------|----------|
| scopes only, re-checked by one sign-in | `"scopes": "offline_access"` in both MCP files, layout gate re-pinned, one real sign-in per client on Linux; client-id setting and rename deferred | ✓ |
| scopes plus the client-id setting | Also a Claude Code user option and an installer flag | |
| All four, including the rename to bbj | Rename touches the notice, pages, installer `--remove` detection and many pinned strings | |

**User's choice:** the recommended option each time.
**Notes:** the installer's OAuth callback shape (a departure in the todo) is answered by the Phase 9 Windows W11 reading, where the throwaway Codex home signed in with the installer's table.

---

## Release checks beyond the Phase 6 pattern

| Option | Description | Selected |
|--------|-------------|----------|
| Install check plus the Git-marketplace upgrade reading | Throwaway Codex home: GitHub marketplace added before the merge (0.2.0), `marketplace upgrade` and `plugin add` after; record URL, skills, re-trust | ✓ |
| Install check only | Shorthand add and plugin add after the merge | |
| No post-merge Codex check | Tag right after the Claude Code check | |

| Option | Description | Selected |
|--------|-------------|----------|
| Blocking: the release waits for it | Wording written only after the Windows installer reading exists | ✓ |
| Time-boxed: ship without it if it does not happen | Fix labelled "not run", two wording variants prepared | |

| Option | Description | Selected |
|--------|-------------|----------|
| The CHANGELOG 0.2.1 entry verbatim | Same text as the entry | ✓ |
| Short summary plus a link to CHANGELOG.md | Three to five lines and the link | |

| Option | Description | Selected |
|--------|-------------|----------|
| Linux closes the release | No further owner sessions; records and the re-run are the evidence | ✓ |
| One machine, recorded as a UAT reading | Owner upgrades on Windows or the Mac after the Release | |
| Both machines | Same on both | |

| Option | Description | Selected |
|--------|-------------|----------|
| Try the RC branch first, else Release-body addendum | Researcher checks whether Codex can add a marketplace at a branch; else an "After the merge" paragraph in the Release body | |
| Second commit on main before the tag | A second small PR amends the 0.2.1 entry; the tag points at that commit (amends Phase 6 D-03) | ✓ |
| Phase record only | Reading in the phase UAT only; entry keeps the "not run" line | |

**User's choice:** the recommended option for the first four; for the fifth the owner chose the second commit on main over the recommended RC-branch attempt.
**Notes:** the fifth question arose because the entry is written before the merge and the tag sat on the merge commit, so a post-merge reading could not reach the shipped text without a second commit.

---

## Claude's Discretion

- README table columns and cell wording; whether BBj 26.03 is a caption or a column.
- Final STATUS_LINE text, the three `UPGRADE_QUOTES`, the exact `NOT_RUN_LINES`.
- Name and usage line of the installer override option; wording of the early refusal.
- Where the Windows installer re-run is recorded (appended to `09-WINDOWS-RUN.md` or a short phase record).
- How `claude_version_single` becomes per-platform; where the banner dates are pinned.
- Shape of the post-merge Codex throwaway-home script; gate names within the prefix convention.

## Deferred Ideas

- OAuth client id as a setting — next milestone.
- Rename `bbj-docs` to `bbj` — next milestone.
- WR-02 (one tier-2 probe per hook call) and WR-03 (independent backslash gate) — later fix candidates.
- `config.toml` `command_windows` override for the plugin route — only if a run observes it.
- Windows or macOS CI runner; the full suite under Git Bash — future requirements.
