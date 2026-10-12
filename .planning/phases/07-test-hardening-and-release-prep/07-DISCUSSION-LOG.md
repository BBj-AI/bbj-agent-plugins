# Phase 7: Test hardening and release prep - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-12
**Phase:** 07-test-hardening-and-release-prep
**Areas discussed:** Release-tree path, CONTENT_VERSION policy, Codex home ignore rule, PATH scrub scope

---

## Release-tree path

| Option | Description | Selected |
|--------|-------------|----------|
| Ride on planning-setup | Fixes already on gsd/planning-setup; Phase 10 /gsd-pr-branch carries them | ✓ |
| Early PR to main now | Small PR off origin/main in Phase 7, no tag | |
| Release branch off origin/main | release/0.2.1 with cherry-picks | |

| Option | Description | Selected |
|--------|-------------|----------|
| Fast-forward local main to origin/main | Local only, no push | ✓ |
| Leave it alone | Always compare against origin/main | |

| Option | Description | Selected |
|--------|-------------|----------|
| Verification step only | merge-base --is-ancestor per SHA + full suite | ✓ |
| Add a repo gate | Content-marker gate in the tree | |

**User's choice:** All recommended options.

---

## CONTENT_VERSION policy

| Option | Description | Selected |
|--------|-------------|----------|
| Split generic / re-pinned | Generic gates always run; fact gates re-pinned; mismatch FAILs | ✓ |
| Re-pin all per release | Today's design, skip on other versions | |
| Per-version facts table | FACTS dict, unknown version FAILs | |

| Option | Description | Selected |
|--------|-------------|----------|
| Phase 7 decides, Phase 10 fills | Values stay 0.2.0 until Phase 10 | ✓ |
| Phase 7 writes placeholders | TODO 0.2.1 slot now | |

| Option | Description | Selected |
|--------|-------------|----------|
| Test docstring + PROJECT.md | Plus mutation proof of FAIL path | ✓ |
| Docstring only | | |

**User's choice:** All recommended options.

---

## Codex home ignore rule

| Option | Description | Selected |
|--------|-------------|----------|
| Allowlist installer targets | Watch only paths the installer writes | ✓ |
| Denylist daemon files | Watch all, ignore known runtime files | |
| Both | Allowlist FAILs, others informational | |

| Option | Description | Selected |
|--------|-------------|----------|
| Content snapshot | cksum before/after | ✓ |
| Keep mtime | find -newer on watched paths | |

| Option | Description | Selected |
|--------|-------------|----------|
| Mutation test with fake home | Separate test, runs in CI without Codex | ✓ |
| Inline cases in test_install_codex.sh | | |

**User's choice:** All recommended options.

---

## PATH scrub scope

| Option | Description | Selected |
|--------|-------------|----------|
| Filter compiler dirs | Remove dirs holding bbjcpl/bbjcplw; clear BBJ_HOME vars | ✓ |
| Fixed minimal PATH | /usr/bin:/bin | |

| Option | Description | Selected |
|--------|-------------|----------|
| No-route gates only | Helper called by the no-route cases | ✓ |
| Every test via mkwork | Global scrub | |

| Option | Description | Selected |
|--------|-------------|----------|
| Fake bbjcpl on PATH, run the gates | Plus no-op-helper mutation expecting FAIL | ✓ |
| Unit-test the helper only | | |

**User's choice:** All recommended options.

---

## Claude's Discretion

- MAINT-08 prefix-list rebuild (CONVENTIONS.md first, CLAUDE.md after) and whether to add a sync gate
- Helper, test file and gate names; exact snapshot format

## Deferred Ideas

None.
