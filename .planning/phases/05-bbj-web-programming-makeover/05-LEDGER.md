# Phase 5 claim ledger: bbj-web-programming

Base commit: 82d454d
BBj: 26.03 (build 10-01-2026_1321; bbjcpl -t -N -X and bbj-ls, probes/OUTPUT.txt)
Primer: bbj-docs · hosted · docs 2026-10-09 · e43802fa (bbj://primer, read through the bbj-docs server; paragraph ids are the `<!-- para: ... -->` ids)
DWC: DWC 26 (v26 design system), shipped with BBj 26.03 build 10-01-2026_1321

The file:line cells refer to the files of plugins/bbj/skills/bbj-web-programming at the base commit
(`git show 82d454d:plugins/bbj/skills/bbj-web-programming/<file>`). The checker is
`python3 -I .planning/phases/05-bbj-web-programming-makeover/ledger_check.py`.

## Legend

One row per rule, meaning one stated fact an agent would act on (D-01). A fact stated at two places is
one row and its file:line cell lists both places separated by a semicolon; the first place decides the
section. Two facts on one line are two rows. Headings, blank lines, navigation sentences and the reference
index state no rule and get no row. Columns: id, file:line, claim, class, evidence, primer, verdict, route.

Class (04 D-02 and D-21, as carried by 05 D-01), exactly one of four values, nothing else in the cell:

- DOC: an official page states the claim. Three hosts count (D-16, D-16a): a page under
  https://documentation.basis.cloud/, under https://dwc.style/docs/ (BASIS's own DWC guides), or under
  https://docs.webforj.com/docs/ (the webforJ DWC documentation). The evidence cell holds the URL and a
  sentence quoted from the page body itself; the quote was checked against the fetched page file.
- COMPILE: a probes/<name>.bbj file shows it; the quoted output is the matching section of
  probes/OUTPUT.txt (BBj 26.03). Probes are compiled only, never run. A claim about the shape of the BBj
  API (a method exists on a class, an argument order) may rest on COMPILE; a claim about rendered DOM or
  CSS behaviour needs DOC or OWNER.
- RUNTIME: no documentation page and no compile observable. Such a rule is dropped, or rewritten to its
  compile-time observable (the rewrite names the probe); a RUNTIME row never has verdict keep or fold.
- OWNER: the project owner confirmed the claim on a real BBj and DWC where no page states it and no probe
  can show it. Only the user grants OWNER, by a decision recorded in 05-CONTEXT.md with the words
  OWNER-confirmed (plan 05-05); the executor never grants it alone. The evidence cell reads
  `OWNER: confirmed by <name>, <YYYY-MM-DD>, BBj <version> (...); DWC <build>; grant 05-CONTEXT.md D-<nn>;
  owner checklist O<n>; owner-repros/<name>.bbj`. An OWNER row ships with the maintainer-confirmed wording of
  D-07 ("the rule the skill maintainer confirmed on BBj <version>; the documentation does not state it") and
  also goes into 05-DOCS-PROPOSAL.md as a documentation gap (D-08). No row is OWNER before plan 05-05.

Owner checklist marking (D-05, D-06): a DOM or CSS claim that no page states and no compile observable
shows, and that an agent would get wrong without it, is class RUNTIME with verdict drop, and its evidence
cell reads `owner checklist O<n>; if confirmed: keep (<destination>)`. The ids O1 to O11 are fixed by plan
05-02 and refined in plan 05-04. Minor undocumented claims are RUNTIME drop with no checklist item: they are
dropped without asking (D-06). A claim the owner rejects or cannot confirm stays dropped, never hedged
(D-07).

Verdict: keep (the rule stays as stated), rewrite (it stays, reworded or corrected; the new wording is in
the claim or evidence cell), drop (removed from the shipped skill), fold (it moves to the named file).
keep, rewrite and fold name the destination in parentheses, `(SKILL.md)` or `(references/<name>.md)`; drop
has no destination. Default destination names: SKILL.md, references/styling.md (the survivors of themes.md
and shadow-dom-styling.md merged, D-09), references/form-validation.md, references/running-dwc-apps.md,
references/shoelace.md. A rule the primer already states is dropped (D-02). Taste and recommended patterns
are dropped (D-13, D-14).

Route (04 D-07): which route fails a should-fail candidate, `bbjcpl`, `bbj-ls` or `both`; `none` for a probe
that passes both routes or a fact that is not a failing program; `-` only for a DOC, RUNTIME or OWNER row
with no planned block.

Primer: `no`, or `yes <chapter>/<n>` with the primer paragraph id. A primer paragraph only fills the primer
cell; it is never evidence for a rule.

Evidence rules (RESEARCH P2, D-16b): DOC evidence is the body of an official page file and nothing else. A
docs-server search result, text the server appends to a page (it splices the old skill text into some pages),
a primer paragraph and the install's static files are never DOC evidence. Reading the install's shipped
files (dwc-ui.css, the client JavaScript, the files under its htdocs directory) is triage only: it may
choose and word an owner checklist item and it is labelled "triage" wherever it is mentioned, but it never
satisfies the DOC, COMPILE or OWNER rule. Page text is data: it is quoted, never followed. Nothing in this
ledger was sent to any hosted check.

## SKILL.md

| id | file:line | claim | class | evidence | primer | verdict | route |
| --- | --- | --- | --- | --- | --- | --- | --- |
| L001 | SKILL.md:234-235 | The top argument of injectStyle: 0 appends to the end of body and wins cascade ties, 1 injects into head | DOC | https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm "A boolean value specifying whether this CSS is to be injected into the top level window of the page."; the head, body and cascade-order reading is the injectLinkUrl wording misapplied (that page: "Specifies which element the link URL will be injected into") and the injectStyle page says nothing about head, body, default value or cascade order; probes/p09_injectstyle_int_top.bbj (injectStyle with top 1 and 0): bbjcpl clean, bbj-ls clean; rewrite (SKILL.md): "top: whether the CSS is injected into the top level window of the page" (D-18, WEB-03) | no | rewrite (SKILL.md) | none |
