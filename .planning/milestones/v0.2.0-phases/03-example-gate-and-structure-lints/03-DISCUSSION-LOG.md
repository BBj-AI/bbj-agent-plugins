# Phase 3: Example gate and structure lints - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-10
**Phase:** 03-example-gate-and-structure-lints
**Mode:** `--auto` (auto-advance after Phase 2 UAT; config `mode: yolo`). No questions were put to the user; the recommended option was selected each time.
**Areas discussed:** CI meaningfulness while skills are red, Fence grammar, Live check, nocheck ratchet and structure lints, Baseline report

---

## CI meaningfulness while skills are red

| Option | Description | Selected |
|--------|-------------|----------|
| Pending list with ratchet | Pending skills listed in a committed baseline; violations print `skip ... pending`; counts may not rise; empty entry must be removed | ✓ |
| Report-only | Gates print findings but never fail until Phases 4-5 | |
| Fail now | Gate red in CI until the makeover lands | |

**Selection:** [auto] Pending list with ratchet (recommended; satisfies success criterion 5 "listed as pending rather than silently exempt").

---

## Fence grammar

| Option | Description | Selected |
|--------|-------------|----------|
| Allowlist of non-BBj tags | `css html js json bash sh text xml`; unknown tags fail | ✓ |
| Ignore any non-`bbj` tag | Typos like `BBj` would pass unchecked | |

| Option | Description | Selected |
|--------|-------------|----------|
| `should-fail` = fails on ≥1 route | Per roadmap; no error-text match | ✓ |
| Also match expected error text | Stronger, more grammar | |

**Selection:** [auto] Allowlist; `should-fail` without text matching; `...` banned in checked blocks.

---

## Live check

| Option | Description | Selected |
|--------|-------------|----------|
| Call routes directly | Batched `bbjcpl -t -N -X`, then loopback `bbj_check_syntax` | ✓ |
| Run through `bbj-check.sh` | Reuses hook, but hook stops at tier 1 when a compiler exists | |

| Option | Description | Selected |
|--------|-------------|----------|
| Standalone blocks, no wrappers | Fragments fail and become to-do items | ✓ |
| Wrapper directives | `class`/`declares` harness around fragments | |

**Selection:** [auto] Direct route calls; standalone blocks.

---

## nocheck ratchet and structure lints

| Option | Description | Selected |
|--------|-------------|----------|
| One repo-wide nocheck number in the baseline | Fails if count grows | ✓ |
| Per-skill nocheck budget | Finer, more bookkeeping | |

**Selection:** [auto] Repo-wide number; Sources must be the last `##` section of each reference with a `Verified on BBj <version>` line; denylist exactly the six GATE-05 strings.

---

## Baseline report

| Option | Description | Selected |
|--------|-------------|----------|
| Machine baseline + human report | JSON read by gates; Markdown to-do list in the phase dir, both from a report mode | ✓ |
| Markdown report only | Gates would hard-code numbers | |

**Selection:** [auto] Both artifacts, regenerated on this machine.

## Claude's Discretion

- Test file names and split, gate prefix, JSON layout, fence detection details, live-check language.

## Deferred Ideas

- Content-hash stamp file (Pitfall 5 / MAINT-04).
- Error-text matching for `should-fail`.
- Fragment wrappers.
- `java` fence tag.
