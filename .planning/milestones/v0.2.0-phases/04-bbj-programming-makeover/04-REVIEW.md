---
phase: 04-bbj-programming-makeover
reviewed: 2026-10-11T00:00:00Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - plugins/bbj/skills/bbj-programming/references/sysgui.md
findings:
  critical: 0
  warning: 1
  info: 2
  total: 3
status: issues_found
---

# Phase 4: Code Review Report

**Reviewed:** 2026-10-11
**Depth:** standard
**Files Reviewed:** 2
**Status:** issues_found

## Summary

Incremental re-review after gap-closure plan 04-08. I re-fetched every page the new `sysgui.md` text cites and compared
the quotes with the text:

- WINDOW mnemonic page: "Windows created with the dialog behavior flag ($00080000$), that creates a modal dialog, will not have an icon in the Start Bar in Windows", under "The following information is for top level windows in BBj". The quote is exact.
- `isModal()` page: the example comment is "Create a modal window" and the call is `addWindow(X,Y,WIDTH,HEIGHT,"Modal",$00080083$)`. Matches.
- `getActiveContext()` page: the window of context 2 is created with `$80002$` and the comment is "Should print 2 (the modal window)". Matches. `$80002$` does include bit `$80000$`.
- `addWindow` page: the Invisible, Dialog, MDI Desktop Modal and MDI Group Modal entries match the quotes.

The two code blocks equal probes s01 and s02 line for line, and the recorded probe output matches the claims about `setModal(1)`
(bbjcpl type-check error, bbj-ls clean). The D-24 front rule is worded as granted (only windows without the Dialog flag
that already existed, nothing about later windows) and is marked as maintainer-confirmed, as the `str()` rule is. The new SKILL.md intro
sentence and index line are accurate and consistent with the references. `test_layout.py`, `test_skill_examples.py` and
`test_check_order.py` pass.

No new contradictions were introduced by 04-08. One older claim in SKILL.md, which 04-08 did not touch, can mislead,
and two small precision points in the new `sysgui.md` text are listed below. The findings already dispositioned in
04-REVIEW-DISPOSITION.md are not re-raised, and WR-08 stays open as recorded there.

## Warnings

### WR-01: "Put one in every mask" can be read as `@` or `&` being a sign character

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:133-138`
**Issue:** The paragraph lists the sign characters from the Numeric Output page (`-`, `+`, `(` and `)`, `CR` and `DR`) and then says "its BBj-specific page adds the mask characters `@` and `&`. Put one in every mask that can format a negative value." The BBj-specific page (numeric_output_bbj.htm) defines `@` as "replaced by the three-character international currency code" and `&` as "replaced by the local currency symbol". Both are currency characters. The page says nothing about signs, so the sentence implies a documented fact that the page does not state. An agent can reasonably conclude that `str(rate:"@##0.00")` keeps the minus. The text also does not mark this as a maintainer-confirmed rule. The rest of the paragraph is the maintainer rule, which the page does not state.
**Fix:** Do not call `@` and `&` sign characters. Either drop them from this paragraph, or separate them, for example:
```
The Numeric Output page lists the sign characters `-`, `+`, `(` and `)`, `CR` and `DR` (<url>). Put one of these in every
mask that can format a negative value. Its BBj-specific page also defines the currency mask characters `@` and `&`
(<url>); they are not sign characters.
```

## Info

### IN-01: The `getActiveContext()` citation leaves out the later-created window in the same example

**File:** `plugins/bbj/skills/bbj-programming/references/sysgui.md:17-19`
**Issue:** The text says the example creates the window of context 2 with `$80002$` and expects `getActiveContext()` to return 2. The example creates `win1` with `$02$` before it and `win3` with `$02$` after it, and still expects 2. The summary of the example is accurate but partial. D-24 deliberately says nothing about windows created after the Dialog-flag window, and the next paragraph limits the front rule to windows that "already existed". A reader who knows the full example sees a documented case that the rule's wording appears to avoid. The phrase "which includes the Dialog flag" is the reviewer's own arithmetic (`$80002$` = `$80000$` + `$02$`), not a statement of the page.
**Fix:** Optional. Say "which sets the Dialog bit" (it is arithmetic, not a page statement), or add "(two windows with flag `$02$` surround it)". Do not extend the front rule beyond D-24.

### IN-02: "For a modal window, pass the Dialog flag" has no scope for top-level versus MDI windows

**File:** `plugins/bbj/skills/bbj-programming/references/sysgui.md:12-14, 24-26`
**Issue:** The cited WINDOW mnemonic note applies "for top level windows in BBj", and the text quotes that qualifier. The imperative sentence "For a modal window, pass the Dialog flag." does not carry it. The next paragraph lists the MDI Desktop Modal and MDI Group Modal flags with no hint about when to prefer them over the Dialog flag. The `addWindow` page says the MDI Desktop Modal flag is "ignored if the window isn't on an MDI desktop" and applies "In BBj 23.04 and higher". The imperative is therefore broader than its source for windows on an MDI desktop.
**Fix:** Write "For a modal top-level window, pass the Dialog flag." and keep the MDI sentence as it is, or add "For a window on an MDI desktop, see those flags".

---

_Reviewed: 2026-10-11_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
