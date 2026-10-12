# Phase 6: Release 0.2.0 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-12
**Phase:** 6-Release 0.2.0
**Areas discussed:** Merge and tag path, 0.1.0 changelog entry, 'Tested against' scope, Pre-release loose ends

---

## Merge and tag path

| Question | Options | Selected |
|----------|---------|----------|
| How 0.2.0 reaches main | PR with .planning/ filtered; PR full history; direct merge | PR with .planning/ filtered |
| Tag target | Merge commit on main; release commit on branch | Merge commit on main |
| Tag kind | Annotated + GitHub Release; annotated only; lightweight | Annotated + GitHub Release |
| Git marketplace install source | main after merge, before tag; release branch before merge; both | main after merge, before tag |
| Merge style | Merge commit; squash; rebase | Merge commit |

---

## 0.1.0 changelog entry

| Question | Options | Selected |
|----------|---------|----------|
| 0.1.0 entry | Keep marked not released; fold into 0.2.0; keep with date | Fold into 0.2.0 |
| 'Next' paragraph | Remove; keep in history | Remove |
| 0.2.0 shape | Mirror 0.1.0 shape; Keep a Changelog | Mirror 0.1.0 shape |
| Upgrade audience | Codex + Claude Code; Codex only | Codex + Claude Code |
| Upgrade framing | 'If you installed from main before 0.2.0'; 'Upgrading from 0.1.0' | 'If you installed from main before 0.2.0' |

---

## 'Tested against' scope

| Question | Options | Selected |
|----------|---------|----------|
| Old 0.1.0 lines | Only what 0.2.0 re-ran; keep others dated | Only what 0.2.0 re-ran |
| Real Codex run | Full incl. upgrade; fresh install only; reuse Phase 2 run | Fresh install only |
| Real Claude Code run | Git marketplace install + hook; install only | Git marketplace install + hook |
| Docs server / CI pin | Record, don't bump; record + bump pin | Record, don't bump |
| Unrun upgrade path in changelog | List under Not run; no mention | No mention |
| Windows/macOS | Still Not run; owner runs one | Still Not run |

---

## Pre-release loose ends

| Question | Options | Selected |
|----------|---------|----------|
| Phase 4 open findings | Triage each; fix all; defer all | Triage each |
| skip=0 scope | Whole suite; live gates only | Whole suite |
| real_home_untouched flake | Run with Codex stopped; harden gate; accept FAIL | Run with Codex stopped |
| Run host | This machine; owner's machine | This machine |

---

## Claude's Discretion

- Plan split, changelog bullet wording, tag message; whether the single version commit also carries the CHANGELOG.

## Deferred Ideas

- Harden real_home_untouched; bump CI Claude CLI pin; real-Codex upgrade-path run; Windows/macOS runs.
