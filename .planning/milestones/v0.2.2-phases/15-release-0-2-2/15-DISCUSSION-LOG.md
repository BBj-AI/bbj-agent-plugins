# Phase 15: Release 0.2.2 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-16
**Phase:** 15-release-0-2-2
**Areas discussed:** Entry wording, Upgrading section, Release run scope, Open review items

---

## Todos

| Option | Description | Selected |
|--------|-------------|----------|
| Social sign-in help link | Connect-page link, `codex mcp logout` before retry | |
| Minimum client versions | Refuse/warn on untested clients; new capability | |
| VS Code extension route | Install without the claude CLI; new capability | |
| None, release as scoped | Bump, entry, checks, publish only | ✓ |

## Entry wording

| Question | Options | Selected |
|----------|---------|----------|
| Server name in summary | Present state / Leave it out / Say it changed | Present state |
| Plugin-only route | Present state / Leave it out | Present state |
| Phase 14 changes (WR-04) | New state per item / One summary line | New state per item |
| Windows fixes detail | 0.2.1 level / Short line | 0.2.1 level |

## Upgrading section

| Question | Options | Selected |
|----------|---------|----------|
| Content | Update commands both clients / Claude Code only / Commands plus pointer | Update commands, both clients |
| Addressee gate | Keep / Loosen | Keep |

## Release run scope

| Question | Options | Selected |
|----------|---------|----------|
| Machines | Linux + Windows Claude Code / Linux only / All three | Linux only |
| Tested against sources | Release run + phase records / Release-tree run only | Release run + phase records |
| Post-merge check | Yes, planning only / Yes, amend CHANGELOG / No | Yes, planning only |
| Codex / macOS cell | Keep / Replace with counted reading | Keep |

## Open review items

| Question | Options | Selected |
|----------|---------|----------|
| 12 WR-02 CLI pin | Bump pin to release-run version / Check on 2.1.293 / Leave open | Bump pin |
| 12 WR-01 needles | Leave open / Fix | Leave open |
| 14 IN-10 | Leave open / Fix | Leave open |
| Path scrub + planning push | Scrub, push after release / Not in this phase | Scrub, push after release |

## Claude's Discretion

- Exact entry wording, gate re-pin mechanics, branch and run-file names, plan split.

## Deferred Ideas

- The three matching todos (not folded); 12 WR-01 and 14 IN-10 left open.
