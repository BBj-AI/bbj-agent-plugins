# Phase 5: bbj-web-programming makeover - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-11
**Phase:** 05-bbj-web-programming-makeover
**Areas discussed:** Owner proof for DOM/CSS, Which references survive, Where taste ends, Evidence for CSS/JS

---

## Owner proof for DOM/CSS

| Option | Description | Selected |
|--------|-------------|----------|
| Batch owner session | Checklist with a repro program and a devtools step per claim; owner confirms in one sitting | ✓ |
| Drop all undocumented | Keep only claims with a docs URL | |
| Claude reproduces in browser | Run the repros locally and inspect with Playwright (breaks 04 D-04) | |

| Option | Description | Selected |
|--------|-------------|----------|
| Only the 'worth keeping' | Triage first; minor claims dropped without asking | ✓ |
| Every undocumented claim | Everything surviving taste goes on the list | |

| Option | Description | Selected |
|--------|-------------|----------|
| Mid-phase checkpoint | ledger → owner checkpoint → rewrite; rejected claims dropped | ✓ |
| During UAT at the end | Confirm/strike during UAT | |

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, 05-DOCS-PROPOSAL.md | New proposal for this phase | ✓ |
| Append to 04-DOCS-PROPOSAL.md | One running list | |

## Which references survive

| Option | Description | Selected |
|--------|-------------|----------|
| Ledger decides, D-13/D-14 rule | Fewer than ~3 rules → fold/delete | ✓ |
| Pre-decide now | User names keep/delete | |

| Option | Description | Selected |
|--------|-------------|----------|
| Keep the BBj part only | URL loading vs injectScript, BBjWebComponent, /files paths | ✓ |
| Cut shoelace.md entirely | | |
| Keep as is (ledger-checked) | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Keep DWC-specific, link running.md | Drop launcher flags, point to bbj-programming running.md | ✓ |
| Fold into running.md | Touch the Phase 4 skill | |

| Option | Description | Selected |
|--------|-------------|----------|
| Point to docs, keep traps | Replace tables with URL | ✓ |
| Keep the table, cited | | |

## Where taste ends

| Option | Description | Selected |
|--------|-------------|----------|
| Cut unless BBj-specific | Pure CSS advice is taste | ✓ |
| Keep if factually correct | MDN-citable general rules stay | |

| Option | Description | Selected |
|--------|-------------|----------|
| Cut all patterns | No labelled suggestions | ✓ |
| Keep the mechanism only | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Fact only, owner-proven | Drop the accessibility framing | ✓ |
| Keep the rationale too | | |

## Evidence for CSS/JS

| Option | Description | Selected |
|--------|-------------|----------|
| BASIS docs + DWC/webforJ docs | DWC version noted | ✓ |
| documentation.basis.cloud only | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Minimize, each one ledgered | No new lint | ✓ |
| Add a token-name lint | | |

## Claude's Discretion

- Plan split and order (within ledger → owner checkpoint → rewrite), probe/checklist layout, merging references, wording.

## Deferred Ideas

- `--dwc-*` token-name lint (v2 maintenance).

## Post-research follow-up (2026-10-11)

| Question | Choice |
|----------|--------|
| dwc.style/docs as DOC evidence? | Yes, DOC source (D-16a) |
| Focus-ring mechanism (docs say "shadow", D-15 said "outline") | Use the docs' wording "focus ring", no mechanism claim (D-15 amended) |
| Shipped dwc-ui.css / client JS read statically | Triage only (D-16b) |
