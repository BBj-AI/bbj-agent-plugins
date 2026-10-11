# Phase 4 claim ledger: bbj-programming

Base commit: d61265c
BBj: 26.03 (bbjcpl -t -N -X and bbj-ls, recorded in probes/OUTPUT.txt, reproducible with probes/run.py --check)
Primer: bbj-docs · hosted · docs 2026-09-29 · 3d63c5e4 (bbj://primer, read through the bbj-docs server; paragraph ids are the `<!-- para: ... -->` ids)

The file:line cells refer to the files of plugins/bbj/skills/bbj-programming at the base commit
(`git show d61265c:plugins/bbj/skills/bbj-programming/<file>`). The checker is
`python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py`.

## Legend

One row per rule, meaning one stated fact an agent would act on (D-02). A fact stated at two places is
one row and its file:line cell lists both places separated by a semicolon. Two facts on one line are two
rows. Headings, blank lines and transitions that state no rule get no row. Columns: id, file:line, claim,
class, evidence, primer, verdict, route.

Class (D-04, D-21), exactly one of four values, nothing else in the cell:

- DOC: an official page of https://documentation.basis.cloud/BASISHelp/WebHelp/ states the claim. The
  evidence cell holds the URL and, where the page is not explicit, a quoted sentence of the page body.
- COMPILE: a probes/<name>.bbj file shows it; the quoted output is the matching section of
  probes/OUTPUT.txt (BBj 26.03). Probes are compiled only, never run.
- RUNTIME: no documentation page and no compile observable. Such a rule is dropped, or rewritten to
  its compile-time observable (the rewrite names the probe); a RUNTIME row never has verdict keep or fold.
- OWNER: the project owner confirmed the claim on a real BBj where no page states it and no probe can
  show it (D-21). Only the user grants OWNER, by a decision recorded in 04-CONTEXT.md; the executor never
  grants it alone. The evidence cell reads `OWNER: confirmed by <name>, <YYYY-MM-DD>, BBj <version>`,
  then `grant 04-CONTEXT.md D-<nn>`, then any supporting URL or probe. An OWNER row ships as verified
  and also goes into 04-DOCS-PROPOSAL.md as a documentation gap (D-23).

Verdict: keep (the rule stays as stated), rewrite (it stays, reworded or corrected; the new wording is
in the claim or evidence cell), drop (removed from the shipped skill), fold (it moves to the named
file). keep, rewrite and fold name the destination in parentheses, `(SKILL.md)` or
`(references/<name>.md)`; drop has no destination. A rule the primer already states is dropped (D-05),
except the trailing-rem rule the hook enforces (D-05) and the str() sign trap (D-15).

Route (D-07): which route fails a should-fail candidate, `bbjcpl`, `bbj-ls` or `both`; `none` for a
probe that passes both routes or a fact that is not a failing program; `-` only for a DOC, RUNTIME or
OWNER row with no planned block.

Primer: `no`, or `yes <chapter>/<n>` with the primer paragraph id. Primer paragraphs that end with
"Source: from the BBj programming skills curated by BASIS" are skill-derived (RESEARCH F4): gotchas/9,
10, 11, 12, 14, 15 and java_object_model/11, 12. A rule is dropped because the primer states it, but a
skill-derived primer paragraph is never evidence for the rule.

Evidence rule (RESEARCH F3, F4): DOC evidence is the body of an official documentation page and nothing
else. A docs-server result labelled "not a citable page", text appended after an official page body (the
server splices the old skill text into some pages), and any primer paragraph are never DOC evidence; a
primer paragraph only fills the primer cell. Nothing in this ledger was sent to any hosted check.

## SKILL.md

| id | file:line | claim | class | evidence | primer | verdict | route |
| --- | --- | --- | --- | --- | --- | --- | --- |
| L001 | SKILL.md:32-36 | A trailing `rem` on a line that holds code needs a `;` before it; a label takes `rem` with no `;` | DOC | https://documentation.basis.cloud/BASISHelp/WebHelp/commands/rem_verb.htm "In compound statements, REM may only be the last verb"; https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Language_Concepts/commands_and_statements.htm "The statements within a compound statement must be separated by semicolons"; probes/t03_rem_bad.bbj: bbjcpl `error at line 10 (1): interval = 0 rem Manual`, bbj-ls `line 1, column 1: [SyntaxError] syntax error`; probes/t04_rem_ok.bbj (`interval = 0 ; rem Manual`): bbjcpl clean, bbj-ls clean; probes/t05_label_rem.bbj (label then rem, no `;`): both clean; D-05 exception: the hook enforces it | yes gotchas/3 | keep (SKILL.md) | both |
