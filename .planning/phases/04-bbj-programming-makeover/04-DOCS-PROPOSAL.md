# Documentation improvement proposal: BBj language pages (from the bbj-programming rewrite)

To: the BASIS documentation owners
From: the bbj-agent-plugins repository, Phase 4 (bbj-programming makeover), 2026-10-11
Status: not shipped. This file is a planning document of the repository. Nothing in the BASIS
documentation, in the documentation server or in the primer was edited from this repository, and
nothing here was sent anywhere. Every change below is a suggestion for the owners to accept, reword
or reject.

Why this exists. Phase 4 rewrote the `bbj-programming` agent skill so that it states only facts that
are documented (page URL) or reproduced on a real BBj. Every rule of the old skill went into a claim
ledger (`04-LEDGER.md`). Where a rule survives only because a compile probe shows it, or because the
project owner confirmed it, the documentation is silent on a thing agents and people trip over. This
file is the list of those gaps, the STR() chapter first, each with suggested wording.

How evidence is given.

- Page evidence: the page URL under https://documentation.basis.cloud/BASISHelp/WebHelp/ and one
  sentence quoted from the official page body, read from the page file itself on 2026-10-11. Text
  that the documentation server appends to a page, or serves as a search result labelled "not a
  citable page", is never used as evidence (see the last section).
- Compile evidence: a probe file `probes/<name>.bbj` in the Phase 4 directory and the matching lines
  of `probes/OUTPUT.txt`, produced with `bbjcpl -t -N -X` and with the `bbj-ls` check on BBj 26.03.
  Probes are compiled only. Nothing was run, because this repository never runs BBj.
- Owner evidence: a behaviour that no page states and no compile can show, confirmed on a real BBj
  by the project owner. It is named as such with confirmer, date and version, and carries its OWNER
  ledger id.
- Ledger ids (L0NN) refer to rows of `04-LEDGER.md`.

## STR(): masks, sign, return type, trimming

Five gaps, S1 to S5. S1 and S2 are one finding seen from two pages. Pages involved:

- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/str_function.htm (PRO/5 page)
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/str_function_bbj.htm (BBj page)
- https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Language_Concepts/numeric_output.htm (Numeric Output)
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/cvs_function.htm (CVS())

### S1. The STR() page gives no sign guidance for numeric masks (OWNER-confirmed, L031)

Page: `commands/str_function.htm`.

Says today: "The result can be formatted using the optional string mask. See Numeric Output for more
information." Its four examples are `STR(123:"0000")`, `STR(52.3)`, `STR(3352.3:"$##,##0.00")` and
`STR("abcdefg":"XX-XXX-XX")`; none of them has a negative value.

Lacks: the one trap agents and people fall into with numeric masks. A mask with no sign character
loses the minus sign of a negative number, and the page does not say so, nor which characters carry
the sign.

Evidence: confirmed by Stephan Wald, 2026-10-11, BBj 26.03, the project owner, on a real BBj
(OWNER ledger id L031; granted in the Phase 4 context, decisions D-21 and D-22). No documentation
page states it and no compile check can show a printed result, and this repository never runs BBj,
so the observation is the owner's, not a probe's. The only probe on this subject,
`probes/t21_str_sign.bbj` (`str(rate:"-##0.00")` with `rate = -1.5`), passes `bbjcpl -t -N -X` and
`bbj-ls` and proves only that the corrected example compiles, not what it prints.

Request: please amend the STR() page and, as S2, the Numeric Output page with the sentence below and
a negative-value example.

Suggested wording for the STR() page, after the sentence that links to Numeric Output:

> A numeric mask shows the minus sign of a negative value only if it contains a sign character:
> `-`, `+`, `(`, `)`, `CR` or `DR`. A mask with none of them, such as `"##0.00"`, loses the minus
> sign, so `-1.5` and `1.5` look the same. Start the mask with `-` or `+` when the value can be
> negative.

Suggested example (the result column is for the owners to fill from a real run, as this repository
cannot produce it):

| Statement | Result |
| --- | --- |
| `PRINT STR(-1.5:"-##0.00")` | to be filled from a real run |
| `PRINT STR(-1.5:"##0.00")` | to be filled from a real run |

The same finding in the shape of the documentation server's "Notes for Agents" (Rule, Why, Edge,
Evidence, Example), which the docs server now offers:

- Rule: put a sign character in every numeric `STR()` mask that can receive a negative value.
- Why: a mask without one drops the minus sign, and the printed number is then wrong in sign.
- Edge: the floating characters `-`, `+`, `$` and `(` move to the last position where a `#` or `,`
  became the fill character (Numeric Output page), so the sign sits next to the first digit.
- Evidence: confirmed by Stephan Wald, 2026-10-11, BBj 26.03 (L031); the Numeric Output page lists
  the sign characters; `probes/t21_str_sign.bbj` compiles on both routes.
- Example, which passes `bbjcpl -t -N -X` and `bbj-ls`:

```bbj
rate = -1.5
shown$ = str(rate:"-##0.00")
print shown$
```

### S2. The Numeric Output page never says what a mask without a sign character does (OWNER-confirmed, L031)

Page: `usr/Language_Concepts/numeric_output.htm`.

Says today: it lists the special mask characters and, for the sign, "The minus sign creates a "-" in
the result if the number is negative; otherwise, it is replaced by the fill character." and "The plus
sign becomes a "+" in the result if the number is positive, or a "-" if the number is negative."

Lacks: a sentence on a mask that contains none of `-`, `+`, `(`, `)`, `CR`, `DR`, and a negative
example anywhere on the page. The reader has to infer the consequence from the absence of a
character.

Evidence: the same owner confirmation as S1: confirmed by Stephan Wald, 2026-10-11, BBj 26.03
(L031, D-21, D-22). Again no compile check can show it; nothing was run here.

Suggested wording, after the table of mask characters:

> If the mask contains none of the characters `-`, `+`, `(`, `)`, `CR` or `DR`, nothing in the result
> can show that the number is negative: the minus sign is lost. For example, `STR(-1.5:"##0.00")`
> has no sign position; use `STR(-1.5:"-##0.00")` to keep the sign.

(Owners: please add the real printed results of both statements from a run. The statement that
matters is the first sentence, which is the owner-confirmed fact; the printed digits were never
observed by this repository.)

### S3. The return type of STR() is ambiguous: it is a string primitive

Pages: `commands/str_function.htm` and `commands/bbj-commands/str_function_bbj.htm`.

Says today: the PRO/5 page, "The first STR() function above returns an ASCII string representing the
value of its numeric argument." The BBj page, "In BBj, the STR() function accepts arguments of any
type. If the argument evaluates to a number, STR(num) is used, otherwise STR(str) is used." (The
documentation server's rendering of the BBj page shows a "RETURN TYPE: String" summary line, RESEARCH
S3; the page file itself does not carry it, so it is not relied on here.)

Lacks: whether the result is a primitive string or a BBjString object. Agents and people infer "a
string object" and write `str(n:mask).trim()`.

Evidence: `probes/t12_str_trim.bbj` (`? str(n:"-##0.00").trim()`): `bbjcpl -t -N -X` reports
`error at line 20 (2): ? str(n:"-##0.00").trim()` and `bbj-ls` reports
`line 2, column 1: [SyntaxError] syntax error` (`probes/OUTPUT.txt`, section `== t12_str_trim.bbj`),
so a method call chained on the result is a syntax error on both routes. `probes/t14_cast.bbj`
(`s! = cast(BBjString, str(n:"-##0.00"))`, then `s!.trim()`) is clean on both routes. Ledger id L039.

Suggested wording, for the Description of both pages:

> STR() returns a string primitive, not a BBjString object, so a method cannot be chained on the
> result: `STR(n:mask).trim()` is a syntax error. Assign the result to a variable first, or use
> CVS() (see the example below).

### S4. No trim idiom for the fixed-width result: CVS(STR(n:mask),3)

Pages: `usr/Language_Concepts/numeric_output.htm` and `commands/cvs_function.htm`.

Says today: Numeric Output, "The resulting string is always the same size as the mask." CVS(), in
the table of values for `int`, `1` is "Strip leading spaces." and `2` is "Strip trailing spaces.",
and "A combination of operations may be specified by adding functional values."

Lacks: a pointer from the STR() and Numeric Output pages to the way to remove the padding that a
mask leaves, and an example. Flag 3 is 1 + 2 (strip leading and trailing spaces), which the CVS()
page implies and never shows for this case.

Evidence: `probes/t13_cvs.bbj` (`x$ = cvs(str(n:"-##0.00"), 3)`): clean on `bbjcpl -t -N -X` and
`bbj-ls` (`probes/OUTPUT.txt`, section `== t13_cvs.bbj`). The padding itself is the page's own
sentence above. Ledger id L039 (the same row as S3).

Suggested wording, after the sentence about the fixed width on the Numeric Output page and on the
STR() page:

> The result is always as long as the mask, padded with the fill character. To remove leading and
> trailing spaces use `CVS(STR(n:mask),3)`; the flag 3 is 1 + 2 (see CVS()).

### S5. The primer paragraph two_string_worlds/10 still describes the old Integer example

Pages: `commands/bbj-commands/str_function_bbj.htm` and the BBj primer (`bbj://primer`, docs build
2026-09-29, hash 3d63c5e4).

Says today: the BBj page, in its examples, `X!=new java.lang.Integer(123)` then
`PRINT STR(X!:"00-00"); REM ' numeric masking` and the result `01 23`.

Lacks: agreement. The primer paragraph `two_string_worlds/10` still describes the example from the old
skill text (the `Integer` example returning `12-3`), which the BBj page no longer shows (RESEARCH S5,
ledger id L038). A reader who trusts the primer gets a result the page contradicts.

Evidence: the page text above, read on 2026-10-11; the old skill claim is ledger row L038 (verdict
drop: nothing of the example is kept in the rewritten skill).

Suggested action for the primer owners: replace the example with the page's, or remove the sentence.
Suggested page-level change: none; the page is right.
