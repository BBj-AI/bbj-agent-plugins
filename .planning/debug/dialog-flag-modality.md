---
status: diagnosed
trigger: "UAT test 2 (phase 04): sysgui.md describes the Dialog window-creation flag correctly -- owner: the \"Dialog\" window creation flag makes the window modal (IOW no other windows can come to front that have no \"modal\" flag\", unless created later)"
created: 2026-10-11T12:53:26Z
updated: 2026-10-11T13:14:00Z
goal: find_root_cause_only
symptoms_prefilled: true
audit_acknowledged:
  milestone: v0.2.0
  at: 2026-10-12
  status: diagnosed
---

## Current Focus

bug_class: Bohrbug (deterministic content defect in a shipped reference and the planning decisions behind it; nothing executes)
hypothesis: CONFIRMED -- sysgui.md withholds (and, via IN-02, explicitly disclaims) the Dialog flag's modality because ledger L117 was reclassified DOC -> RUNTIME on the premise that no page states modality; that premise came from reading only the addWindow page, and D-21 then barred the executor from stating it on owner authority. The documentation does state it on other pages.
test: done -- local docs grep + live re-fetch of six pages; compile-only isModal probe
expecting: n/a
next_action: return ROOT CAUSE FOUND to the orchestrator (goal find_root_cause_only); plan-phase --gaps owns the fix

reasoning_checkpoint:
  hypothesis: "sysgui.md is neutral-to-negative on Dialog-flag modality because 04-07 rewrote L117 as RUNTIME (D-04) after WR-02/verification generalized 'the addWindow page does not say modal' into 'modality is undocumented', and D-21 forbade an executor OWNER grant; IN-02 (70de816) then added an explicit 'no claim about modality' disclaimer"
  confirming_evidence:
    - "04-LEDGER.md:197 L117 RUNTIME/rewrite, evidence cites only bbjsysgui_addwindow.htm and probe s02; :199 L119 'no source for isModal() or DIALOGBEHAVIOR was checked'; :257 'Reclassified from DOC to RUNTIME (D-04)'"
    - "04-07-PLAN.md:43 prohibition and :318 'No owner confirmation of Dialog-flag behavior exists and the executor may not grant one (D-21), so state only the page'; read_first re-fetches only addWindow, setReportAllMouseEvents, getOriginalControl"
    - "Round-one 04-REVIEW.md (bda781c) WR-02: 'The only documented effect of $00080000$ is Sets the window to behave as a dialog'"
    - "Live pages 2026-10-11: window_mnemonic_create_sysgui_window_bbj.htm 'dialog behavior flag ($00080000$), that creates a modal dialog'; bbjtoplevelwindow_ismodal.htm 'Create a modal window' with $00080083$; bbjsysgui_getactivecontext.htm '(the modal window)' for $80002$"
  falsification_test: "If the cited pages did not exist live or did not mention modality for $00080000$, the premise of L117's RUNTIME class would stand and the only route would be an OWNER grant -- refuted: all six pages return 200 with the quoted text"
  fix_rationale: "Restore L117 to DOC with the WINDOW-mnemonic BBj page as primary source, state 'the Dialog flag creates a modal window' with that URL, drop the IN-02 disclaimer and the MDI-only juxtaposition; carry the owner's finer z-order rule only through a user-recorded OWNER decision (D-21/D-22 pattern) or omit it"
  blind_spots: "The bbj-docs MCP tools were not available in this agent (no ToolSearch), so the hosted primer/bbj_search were not consulted; the owner's 'unless created later' exception is undocumented and its exact semantics (z-order vs focus) are unverified; DWC-client behavior of the flag is not covered by any page read"
  candidate_causes:
    - "data/evidence: ledger L117 misclassified (DOC -> RUNTIME) and L119 marked unsourced, from a one-page search"
    - "process/config: review and verification made an exhaustive 'only documented effect' claim from one page; 04-07 read_first scoped the re-fetch to that page; no step asked the owner although the verifier named owner confirmation as a route"
    - "code/content: sysgui.md:12-14 and :24 (IN-02 lead-in) wording that puts 'Modal' only on MDI flags beside a rejected setModal and disclaims Dialog modality"
  and_gate: "yes -- it took (1) the one-page search that misclassified L117 AND (2) the D-21 rule plus no owner question during gap planning; either the pages being found or the owner being asked would have kept the modality claim. (3) IN-02 then hardened the omission into an explicit disclaimer."

## Symptoms

expected: (UAT test 2) Owner confirms sysgui.md does not imply the Dialog flag is modal; running.md leaves the -tIO line unhedged (D-22); no changed sentence states an absence or an exhaustive claim beyond its page
actual: Owner (verbatim): "the \"Dialog\" window creation flag makes the window modal (IOW no other windows can come to front that have no \"modal\" flag\", unless created later)"
errors: None reported
reproduction: Test 2 in .planning/phases/04-bbj-programming-makeover/04-UAT.md
started: Discovered during UAT, after plan 04-07 and the code-review fix run (commit 70de816 "IN-02 add a lead-in to the Dialog-flag block that makes no modality claim")

## Eliminated

- hypothesis: H0 -- sysgui.md (or another bbj-programming file) states outright that the Dialog flag is not modal
  evidence: grep finds no such sentence; sysgui.md:10 quotes only "behave as a dialog" and sysgui.md:24 says the example "makes no claim about modality". The defect is omission plus misleading juxtaposition (the word "Modal" appears only on the MDI flags, directly before a rejected setModal call), not a false negative statement.
  timestamp: 2026-10-11T13:02Z

- hypothesis: H1-premise -- Dialog-flag modality has no documentation source, so an OWNER grant is the only way to state it
  evidence: window_mnemonic_create_sysgui_window_bbj.htm "the dialog behavior flag ($00080000$), that creates a modal dialog"; bbjtoplevelwindow_ismodal.htm example "Create a modal window" with $00080083$; bbjsysgui_getactivecontext.htm "(the modal window)" for $80002$; resource_files_and_the_resource_editor.htm "$00080000$ Modal dialog behavior" (all re-fetched live 2026-10-11). Only the owner's finer z-order rule ("unless created later") lacks a page.
  timestamp: 2026-10-11T13:06Z

## Evidence

- timestamp: 2026-10-11T12:55Z
  checked: grep -rniE '00080000|dialog|modal' plugins/bbj/skills/ codex/AGENTS-snippet.md
  found: bbj-programming/references/sysgui.md:5-31 is the only bbj-programming place. L10 quotes the page only ("Sets the window to behave as a dialog."); L12-14 name "$02000000$ MDI Desktop Modal" and "$40000000$ MDI Group Modal" as flags the page also lists, then state bbjcpl rejects win!.setModal(1) (bbj-ls accepts); L16-22 should-fail setModal block; L24 lead-in "The Dialog and Invisible flags together (this example makes no claim about modality):"; L26-31 block with $00080010$. SKILL.md:155 index line "window flags and the Dialog flag". bbj-web-programming/SKILL.md:3 (description "window creation flags (modal/Dialog, ...)") and :209 (table row "$00180013$ | AutoLayout + **Dialog(modal)** + ... | modal dialog window") still call the Dialog flag modal (Phase 5 scope, untouched by phase 4). No place in either skill tells an agent how to make a window modal.
  implication: the shipped bbj-programming text never says the Dialog flag is modal, explicitly disclaims modality on the example, and places the word "Modal" only on the MDI flags right before a rejected setModal call. An agent reading it infers either "no way to make a modal window" or "use the MDI modal flags" -- the opposite of the owner's fact. The two skills now contradict each other.

- timestamp: 2026-10-11T12:56Z
  checked: git log --follow sysgui.md; git show 51245c9:.../sysgui.md (vendored original, line 33)
  found: original said "**Modality is a CREATION FLAG, not a setter.** There is no `setModal()`. Pass **`$00080000$`** ("Dialog": sets the window to behave as a dialog) at `addWindow()` time; `BBjTopLevelWindow::isModal()` merely reports whether that flag was used. In an `.arc` resource the same thing is spelled `DIALOGBEHAVIOR`. So a modal dialog that stays hidden until needed is `$00080000$ + $00000010$ + ...`." History: e763bc0 (04-05 reduce to ledger survivors, kept "use the Dialog flag" as setModal replacement), 3375a43 (04-07 "states the Dialog flag as documented" -- removed the modality instruction), 70de816 (IN-02 added the "makes no claim about modality" lead-in).
  implication: the correct claim existed before phase 4; it was removed in two steps (04-07, then IN-02 hardened the neutrality into an explicit disclaimer).

- timestamp: 2026-10-11T12:58Z
  checked: 04-LEDGER.md rows L117, L118, L119, L128 and the closing notes (line 257)
  found: L117 ("Modality is a creation flag: pass $00080000$ (Dialog) ...") is class RUNTIME, verdict "rewrite (references/sysgui.md)", route none; evidence: the quoted Dialog entry "does not say that the window becomes modal", the page lists separate MDI Desktop Modal / MDI Group Modal flags, probe s02 shows only that the flags compile -> "says nothing about modal behavior of the Dialog flag". Line 257: "Reclassified from DOC to RUNTIME (D-04) and rewritten in plan 04-07 ... L117 (the modal-behavior wording of the Dialog flag)". L119 (isModal() reports the Dialog flag; DIALOGBEHAVIOR in .arc) RUNTIME/drop: "no source for isModal() or DIALOGBEHAVIOR was checked, so nothing is claimed". L118 setModal COMPILE/rewrite (bbjcpl rejects, bbj-ls accepts). L128 msgbox "All message boxes are application modal." DOC/drop.
  implication: L117 and L119 are the ledger rows that encode the neutrality. L119 notes that the isModal()/DIALOGBEHAVIOR pages were never checked -- a research gap, not a refutation.

- timestamp: 2026-10-11T12:59Z
  checked: 04-CONTEXT.md D-04, D-06, D-21, D-22, D-23; 04-07-PLAN.md must_haves/prohibitions/threats; 04-REVIEW.md IN-02/WR-02; 04-VERIFICATION.md
  found: D-04 "RUNTIME is reserved for runtime claims with no doc source. Those are rewritten to their compile-time observable or dropped." D-21 "Only the user can grant OWNER; the executor never assigns it alone." D-22 grants exactly two OWNER claims (str() sign trap, bbj -tIO). 04-07-PLAN.md:43 prohibition (test tier): "references/sysgui.md MUST NOT state or imply that the Dialog flag makes a window modal, nor offer it as the replacement for setModal, while no page and no owner grant says so". 04-07-PLAN.md:318 "No owner confirmation of Dialog-flag behavior exists and the executor may not grant one (D-21), so state only the page." Threat T-04-31 (executor granting Dialog modality as OWNER) mitigated by "exactly two OWNER rows". ledger_check.py gate ledger_owner + every 04-07 task verify require exactly two OWNER rows (L031, L072). 04-DOCS-PROPOSAL.md:354 asks the BASIS docs owners "whether the Dialog flag ... makes a window modal". 04-REVIEW.md IN-02 asked for the lead-in "(no claim about modality)" to stop the setModal-replacement reading; 04-VERIFICATION.md:47 routed the question to the owner as UAT test 2.
  implication: the neutrality is a deliberate, gated outcome of D-04 + D-21 + the "while no page and no owner grant says so" clause. The question was asked of the BASIS docs owners (proposal) and of the project owner (UAT test 2) but never of the project owner during discuss/plan-check, when D-22 was recorded.

- timestamp: 2026-10-11T13:00Z
  checked: commit ea9bf42 (IN-06), SKILL.md:18-20 and :133-136, running.md:36-41 and :55, ledger L031/L072, ledger_check.py OWNER_RE and D-<nn> check
  found: OWNER precedent = (1) a decision in 04-CONTEXT.md under "Owner confirmation" whose first line contains "OWNER-confirmed" (D-22); (2) ledger row class OWNER, evidence "OWNER: confirmed by Stephan Wald, 2026-10-11, BBj 26.03 ...; grant 04-CONTEXT.md D-22; <supporting URL>" (ledger_check.py OWNER_RE and the "OWNER-confirmed" check on the cited decision's first line); (3) an entry in 04-DOCS-PROPOSAL.md (D-23); (4) shipped wording: SKILL.md:133-134 "That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it." (IN-06), running.md:55 Sources line "Verified on BBj 26.03 by the skill maintainer: ...", and SKILL.md:18-20 intro "...except the `str()` sign rule, which the skill maintainer confirmed on BBj 26.03."
  implication: a third OWNER fact must touch: a new D-24 (or amend D-22) in 04-CONTEXT.md, ledger L117 (class OWNER, verdict keep/rewrite), the ledger_owner count (2 -> 3) wherever "exactly two OWNER rows" is asserted, the proposal L118 bullet (question -> owner-confirmed gap), sysgui.md wording + Sources line, and the SKILL.md intro, which currently names only the str() rule (it already omits -tIO).

- timestamp: 2026-10-11T13:05Z
  checked: local docs copy <home>/repos/bbjdocs/Content (grep "behave as a dialog", "modal", "00080000", "dialogbehavior", "isModal"), then the same pages re-fetched live from documentation.basis.cloud on 2026-10-11 (all HTTP 200, text matches)
  found: The official documentation DOES tie the Dialog flag to modality, on pages phase 4 never read:
    (a) https://documentation.basis.cloud/BASISHelp/WebHelp/mnemonic/sysgui/window_mnemonic_create_sysgui_window_bbj.htm (WINDOW Mnemonic, BBj-Specific Information, "for top level windows in BBj"): "Windows created with the dialog behavior flag ($00080000$), that creates a modal dialog, will not have an icon in the Start Bar in Windows."
    (b) https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjtoplevelwindow/bbjtoplevelwindow_ismodal.htm (BBjTopLevelWindow::isModal, "returns whether the BBjWindow is modal (1 = Modal, 0 = Not modal)"): example "rem 'Create a modal window" / "myWindow! = mySysGui!.addWindow(X,Y,WIDTH,HEIGHT,"Modal",$00080083$)" -- $00080083$ = Dialog $00080000$ + Maximizable/Minimizable $80$ + Close box $02$ + Resizable $01$; the Dialog flag is the only non-chrome flag.
    (c) https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_getactivecontext.htm: example creates win1 ($02$), win2 ("Win2",$80002$ = Dialog + Close box), win3 ($02$, created after win2), then "rem 'Should print 2 (the modal window)"; after win2 is destroyed "rem 'Should print 3".
    (d) https://documentation.basis.cloud/BASISHelp/WebHelp/events/resource_files_and_the_resource_editor.htm (Visual PRO/5 'WINDOW' attributes table): "$00080000$ Modal dialog behavior".
    (e) https://documentation.basis.cloud/BASISHelp/WebHelp/usr/BBj_Enhancements/windows_and_dialogs_bbj.htm: "Modal dialogs in BBj do not have an icon in the task bar in Windows."; https://documentation.basis.cloud/BASISHelp/WebHelp/events/windows_and_dialogs.htm Dialog Capabilities: "Can be modal (whole application pauses until user responds)."
    (f) https://documentation.basis.cloud/BASISHelp/WebHelp/resprops/resource_property_dialogbehavior.htm: "Make Window Behave as Dialog (dialogbehavior) ... Sets the window to behave as a dialog. ... Flag $00080000$ ... ResCompiler Syntax dialogbehavior" -- the DIALOGBEHAVIOR half of ledger L119 is documented too.
    The addWindow page and the BBjTopLevelWindow flags snippet (Resources/Snippets/bbjtoplevelwindow_flags.flsnp, embedded in bbjtoplevelwindow.htm) say only "Dialog: Sets the window to behave as a dialog." No page has setModal.
  implication: H1 holds in its mechanism (D-04 + D-21 drove the neutrality) but its premise is wrong: the modality claim was never undocumented. L117 was DOC all along (it needed a different URL, not reclassification to RUNTIME). The round-one review WR-02 ("The only documented effect of `$00080000$` is 'Sets the window to behave as a dialog'") and verification ("It never says modal") generalized from one page to the whole documentation -- the exact "exhaustive claim beyond its page" defect class the phase forbids. Plan 04-07 then re-fetched only addWindow (read_first lists three pages; its action says "No owner confirmation of Dialog-flag behavior exists ... so state only the page") and never searched other pages, although the verifier had named "sourcing or owner confirmation" as the route.

- timestamp: 2026-10-11T13:08Z
  checked: owner's specific behavior ("no other windows can come to front that have no modal flag, unless created later") against all 43 local pages containing "modal"
  found: No page states the z-order rule or the "unless created later" exception. Closest: windows_and_dialogs.htm "whole application pauses until user responds" (generic, PRO/5 concept page); stbl_formats_bbj.htm GROUP_MODAL_DIALOGS ("As of BBj 7.00, the behavior of dialogs such as the ones created by MSGBOX(), FILEOPEN()/FILESAVE(), etc. is to only be modal over the windows of the current interpreter") is about MSGBOX-style dialogs, not the flag. The getActiveContext example (c) shows the Dialog-flag window stays the ACTIVE context although a non-flag window (win3) is created after it; that concerns focus, not z-order, so it neither confirms nor refutes "unless created later", but a fix must not word the exception so that it contradicts this example (e.g. "a later window takes focus").
  implication: "the Dialog flag creates a modal window" is DOC (cite (a), with (b) and (c) as supporting examples). The precise scope -- other windows without the flag cannot come to the front, windows created later can -- is undocumented and can ship only as an OWNER fact granted by the user (D-21 path), or be left out.

- timestamp: 2026-10-11T13:10Z
  checked: compile-only probe (scratchpad, not committed): addWindow(..., $00080010$) then `modal = win!.isModal()`, /opt/bbx/bin/bbjcpl -t -N -X; canary with win!.setModal(1)
  found: isModal() probe: no stderr (clean). Canary: "type check error [No match for method com.basis.bbj.proxies.sysgui.BBjTopLevelWindow.setModal(BBjInt)] at line 50 (5): win!.setModal(1)" (bbjcpl working).
  implication: an isModal() line can go into a gate-checked block if the fix wants one; it proves the method exists for the type checker, nothing about behavior.

- timestamp: 2026-10-11T13:11Z
  checked: tests/, docs/, README.md, CHANGELOG.md, codex/ for modal / 00080000 enforcement; ledger_check.py OWNER count
  found: no test pins the sysgui.md modality wording (VERIFICATION.md:48 confirms the prohibition had no wired test). ledger_check.py counts OWNER rows but does not hardcode two; "exactly two OWNER rows" lives only in the 04-07 plan verify commands and in 04-07 prohibition text / STATE.md decision notes.
  implication: a fix is not blocked by an automated gate; the planning prohibition (04-07-PLAN.md:43) carries its own escape ("while no page and no owner grant says so"), which is now met.

## Resolution

root_cause: "references/sysgui.md (bbj-programming) deliberately withholds and, since 70de816 (IN-02), explicitly disclaims that the Dialog flag $00080000$ makes a window modal, and its only 'Modal' words sit on the MDI flags right before a rejected setModal call, so an agent concludes the Dialog flag is not the modal flag. Cause: ledger L117 was reclassified DOC -> RUNTIME (and L119 dropped as unsourced) because round-one review WR-02 and 04-VERIFICATION generalized 'the addWindow page says only behave as a dialog' into 'modality is undocumented'; plan 04-07 re-fetched only the addWindow page, D-21 barred the executor from an OWNER grant, and the owner was not asked. The documentation does state the modality: mnemonic/sysgui/window_mnemonic_create_sysgui_window_bbj.htm ('the dialog behavior flag ($00080000$), that creates a modal dialog'), supported by the isModal and getActiveContext examples. Only the owner's finer rule (windows without the flag cannot come to the front unless created later) is undocumented."
oracle_type: specified (official documentation pages, re-fetched 2026-10-11)
fix: "(not applied -- goal find_root_cause_only)"
verification: "(diagnosis only)"
files_changed: []
