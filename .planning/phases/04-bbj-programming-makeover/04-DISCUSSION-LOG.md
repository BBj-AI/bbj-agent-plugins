# Phase 4: bbj-programming makeover - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-11
**Phase:** 04-bbj-programming makeover
**Areas discussed:** Claim ledger, Wrong-code examples, What survives, Launcher & description

---

## Claim ledger

| Question | Options | Selected |
|---|---|---|
| Where does the ledger live? | Phase dir / In repo, not shipped / In the skill | Phase dir |
| Row granularity | One row per rule / One row per sentence / You decide | One row per rule |
| COMPILE evidence when docs are silent | Probe file + output / Output quote only / Skill block is the proof | Probe file + output |
| Documented runtime behaviour | URL is enough / URL + quoted sentence always | URL is enough |
| Primer cross-check | Yes, column in ledger / Only for doubtful rules | Yes, column in ledger |

---

## Wrong-code examples

| Question | Options | Selected |
|---|---|---|
| How to show wrong code | Separate should-fail block / Prose only / Mix | Separate should-fail block |
| should-fail failing only on bbjcpl type check | Yes / No, must fail on both | Yes |
| Self-contained fragments | Minimal complete program / Prefer one-liners / You decide | Minimal complete program |
| nocheck for uncreatable objects | Rewrite, nocheck stays 0 / Allow a few with reasons | Rewrite, nocheck stays 0 |
| Same-line comments | Allowed with `; rem` / Own line only | Allowed with `; rem` |

---

## What survives

| Question | Options | Selected |
|---|---|---|
| !ERROR=26 section | Rewrite to bbjcpl observable / Drop entirely / Keep in a reference | Rewrite to bbjcpl observable |
| Which references survive | reserved-words / sysgui / database + java-interop / callback-performance (multi) | All four groups |
| Body shape | Check-order, rules, pointers / You decide | Check-order, rules, pointers |
| Thin references | Fold into body or another ref / Keep file regardless | Fold |
| str() mask tables | Point to docs; keep the sign trap / Move tables to a reference | Free text: "point to the docs as recommended. propose an improvement to the documentation to augment the STR() chapter" |
| Precision section | Keep documented facts only / Cut entirely | Keep documented facts only |
| Docs proposal scope | STR() plus every gap found / STR() only | STR() plus every gap found |

**Notes:** The docs-improvement proposal (D-18) was the user's own addition.

---

## Launcher & description

| Question | Options | Selected |
|---|---|---|
| Launcher section | Docs-cited reference, gated by "when asked to run" / Keep in body, docs-cited / Owner reproduction allowed | Docs-cited reference |
| Description | Triggers first, only kept topics / Minimal description | Triggers first, only kept topics |

---

## Claude's Discretion

- Plan split and order, probe layout, new reference names, and whether database and java-interop merge.

## Deferred Ideas

- Error-text matching for should-fail blocks; keeping the ledger current past the milestone (v2 MAINT-04).
