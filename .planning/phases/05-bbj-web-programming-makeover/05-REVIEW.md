---
phase: 05-bbj-web-programming-makeover
reviewed: 2026-10-12T00:00:00Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - plugins/bbj/skills/bbj-web-programming/SKILL.md
  - plugins/bbj/skills/bbj-web-programming/references/form-validation.md
  - plugins/bbj/skills/bbj-web-programming/references/running-dwc-apps.md
  - plugins/bbj/skills/bbj-web-programming/references/shoelace.md
  - plugins/bbj/skills/bbj-web-programming/references/styling.md
  - tests/skills_baseline.json
findings:
  critical: 0
  warning: 8
  info: 3
  total: 11
status: issues_found
---

# Phase 5: Code Review Report

**Reviewed:** 2026-10-12
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

I read the five skill files and the baseline, re-fetched the cited BASIS, dwc.style and docs.webforj pages
and compared each quote and each code block against them, and ran the gates. These pass: `tests/test_skill_examples.py`
(live, `BBJ_SKILLS_LIVE=1`: bbjcpl and bbj-ls, 23 bbj blocks pass, 9 should-fail blocks fail as intended), `tests/test_layout.py`
and `tests/test_check_order.py`. The description is 669 characters (limit 1,024). The baseline `pending: {}` and `nocheck: 0`
match the tree (no `nocheck` block exists). Cross-references resolve: `bbj-programming/references/callback-performance.md`
and `running.md` exist, and the SKILL.md headings "Injecting CSS and JavaScript", "Web components" and
"Attributes and properties" exist. O3 and O8 content (`!important` on dwc-frame, null geometry getters) is absent, and
all seven OWNER sentences (D-19..D-27) carry the maintainer-confirmed wording.

No block fails to compile and no claim is invented. The defects are code examples that contradict the rule next to them,
claims stated more broadly than the page they cite, and load-bearing details the cited page gives that the
skill leaves out. An agent copying these blocks gets wrong or misleading results. Every bullet below is checked against the fetched
page text.

## Warnings

### WR-01: The form-validation example puts a JavaScript validator and `required` on one control, which the file's own rule says makes the validator dead code

**File:** `plugins/bbj/skills/bbj-web-programming/references/form-validation.md:15-17, 39-51`
**Issue:** Lines 15-17 state "Built-in validation wins over JavaScript validation ... if a control is using both ... the
built-in validation will always be used." The example then sets `code!.setClientValidationFunction("value.length == 8")` and
`code!.setAttribute("required", "true")` on the same `BBjEditBox`, with the caption "A JavaScript expression and a built-in
attribute on one control". By the file's own rule the `value.length == 8` check is never applied, so the example teaches a combination
that discards the logic the agent just wrote. An agent that copies the pattern ships a form whose length check never runs.
The value `"true"` for `required` is also not given on any cited page (the guide says only "setting the `required` attribute").
**Fix:** Make the example agree with the rule. Put the JavaScript function on one control and the built-in attribute on another,
or on one control only. Say in the caption that on a control using both, only the built-in rule runs. For example:
```bbj
code! = win!.addEditBox("")
code!.setClientValidationFunction("value.length == 8")
name! = win!.addEditBox("")
name!.setAttribute("required", "true")
```

### WR-02: `getDwcUrl(0)` and `getBuiUrl(0)` are shown with an unexplained argument that is the `ssl` flag

**File:** `plugins/bbj/skills/bbj-web-programming/references/running-dwc-apps.md:27-30, 58`
**Issue:** The Javadoc signature is `String getDwcUrl(boolean ssl)` (and `getBuiUrl(boolean ssl)`; the class sample calls
`getBuiUrl(false)`). The reference quotes the Javadoc sentence but leaves out the parameter, writes `getDwcUrl(0)`, and never
says what `0` means. `0` returns the plain `http` URL. An agent on a TLS-only server, or one told to give the
user an `https` link, has no way to learn that `1` is what it needs. The reference does say the call returns null when `DWC_ENABLED` is false, but the example does not check `url$`.
**Fix:** Add a bullet: "`getDwcUrl(ssl)` and `getBuiUrl(ssl)` take a boolean `ssl`: 0 returns the http URL, 1 the https URL"
(cite the Javadoc `getDwcUrl(boolean ssl)` signature on the BBjAdminAppDeploymentApplication page). Check `url$` for null before using it.

### WR-03: The shoelace.md example moves the same `sl-icon` into two parents and then overwrites the card with `setHtml`

**File:** `plugins/bbj/skills/bbj-web-programming/references/shoelace.md:36-51`
**Issue:** One `icon!` is first moved into `card!`'s default slot (`card!.setSlot(icon!)`) and then into the button's `prefix`
slot (`copy!.setSlot("prefix", icon!)`). `setSlot` is documented as a move ("moves a BBjControl into this BBjWebComponent"), so the
first call is undone by the second and the card ends up empty of the icon. The block ends with `card!.setHtml("Automatic")`, which
sets the HTML content of the card after children were slotted into it. No page says that `setHtml` keeps slotted children. The block compiles,
but it shows a sequence that cannot all take effect, and an agent will copy it as a pattern. The string "Automatic" has no relation
to anything in the block.
**Fix:** Split it into two independent demonstrations, one icon per target, and drop `setHtml` from the slot example:
```bbj
card!.setSlot(icon!)                ; rem default slot of the card
icon2! = win!.addWebComponent("sl-icon")
icon2!.setAttribute("name", "copy")
copy!.setSlot("prefix", icon2!)
```
Show `setHtml` on its own on a component with no slotted children.

### WR-04: The BBjColorChooser saturation and lightness rule says "the documentation does not state it", but the documentation states a different range

**File:** `plugins/bbj/skills/bbj-web-programming/SKILL.md:86`
**Issue:** The line reads "`getClientProperty("saturation")` and `getClientProperty("lightness")` return a fraction from 0 to 1.0. That is the rule
the skill maintainer confirmed ...; the documentation does not state it." The BBjColorChooser page (https://dwc.style/docs/#/dwc/BBjColorChooser,
which `styling.md` itself lists as a source) says "The saturation value, which ranges 0 to 100." An agent that opens that page
sees a conflict with the skill and no hint which one governs getClientProperty, so "the documentation does not state it" is
not accurate. The rule also gives no scale for `putClientProperty` (the only write path the skill mentions), so an agent that
reads a 0-1 value and writes it back, or computes `hsl()` from it, has no guidance. The ledger recorded this conflict (L097,
RESEARCH conflict 3); the shipped wording hides it. The D-26 sentence itself is owner-granted and stays.
**Fix:** Keep the granted sentence and add, next to it: "The BBjColorChooser attribute page lists saturation as 0 to 100;
the value `getClientProperty` returns is the fraction above." Also state what scale `putClientProperty("saturation", ...)` takes,
or say it is unconfirmed.

### WR-05: styling.md tells an agent to define a new theme but never how to activate it, and its `setTheme` quote implies only three names

**File:** `plugins/bbj/skills/bbj-web-programming/references/styling.md:12-14, 44-45, 55-69`
**Issue:** The file says "A new theme: Pick a unique name and define it under its own data-app-theme block" and the
code block shows `html[data-app-theme="brand-dark"]`. The same themes guide says right below the same example: "Activate a new theme by name:
`web!.setTheme("brand")`" and "The method accepts the name of any built-in or custom theme." The file omits both sentences, and
quotes the BBj page as `("light", "dark", "dark-pure")`. Following only this file, an agent writes the CSS and then has no
documented way to select the theme, or concludes `setTheme` accepts only three names. The `brand-dark` block in the code
also contains only the dark-mode declarations, so as shown it changes no colour.
**Fix:** Add a bullet quoting "The method accepts the name of any built-in or custom theme" and one line of code,
`web!.setTheme("brand-dark")`, after the CSS block. Cite the dwc.style themes guide for it.

### WR-06: "Attributes set on the closest BBjWindow apply to the controls inside it" is broader than the guide

**File:** `plugins/bbj/skills/bbj-web-programming/references/form-validation.md:33-37`
**Issue:** The guide's sentence sits in the "Validation customization" section and refers to "these attributes", meaning the
customization attributes (`validation-style`, `invalid-message`, `auto-validate`, and so on). The bullet is written as a general rule
("Attributes set on the closest BBjWindow apply to the controls inside it") and the next bullet says the built-in attributes are
separate tables. An agent can read it as covering the built-in rules and set `data-required` or `data-pattern` on the window.
No page says that works. Only `data-validation-style` is in the example.
**Fix:** Reword: "The validation customization attributes (for example `validation-style`, `invalid-message`) can be set on the
closest BBjWindow instead of per control, with the name prefixed with `data-`." Say that the built-in rule attributes are not covered
by that sentence.

### WR-07: The channel-order rule drops the conditions the source attaches to `setAttribute` and `setProperty`

**File:** `plugins/bbj/skills/bbj-web-programming/SKILL.md:79-80`
**Issue:** Line 80 reduces the guide to "the dedicated BBj method, then `setAttribute`, then `setProperty`". The guide gives the
conditions: `setAttribute` is for customizations documented in the component's Properties section that have no BBj method and have a
plain string or boolean value. `setProperty` is "a last resort" for properties documented as `Reflects: No` (where
`getAttribute` returns the stale initial value) or for non-string values. Line 79 reports the Reflects: No hint but the next bullet never connects
the two, and the section also tells the agent to use `setAttribute("label", text)`, which is a `Reflects: No` property. A later
change of a label (after the control is built) through `setAttribute` "may have no effect"; the live path is `setProperty`.
An agent following the order literally uses `setAttribute` for every runtime update.
**Fix:** State the condition: "Use setProperty for a property documented as `Reflects: No` when you need the live value, or for a
value that is not a string." State that `setAttribute("label", ...)` is an initial hint, and that a later change goes through `setProperty`.

### WR-08: The `/files/` rule is stated for any file, but the page states it for one HTML file

**File:** `plugins/bbj/skills/bbj-web-programming/SKILL.md:28, 35-36`
**Issue:** The bullet reads "A file saved in the htdocs directory under the basis home directory 'can be accessed with a URL in the
format http://localhost:8888/files/myhtml.html' ...; the path part is `/files/`." DWC_Registration_Launching.htm says "**This html file**
should be saved to the htdocs directory ...; it can be accessed with ..." in the section on embedding a DWC app in a custom page. The
skill drops "html", turns the localhost URL into a host-relative `/files/...` path, and builds the block on it:
`injectScriptUrl("/files/lib/shoelace/shoelace.js", 1, "type=module")` and `injectLinkUrl("/files/app.css", ...)`. That a nested directory
`lib/shoelace/` and `.js` and `.css` files are served at host-relative URLs is not on the page. The block compiles, which proves
nothing about what the server serves. `shoelace.md:13` repeats the claim.
**Fix:** Quote the page as written ("This html file should be saved to the htdocs directory ... accessed with
http://localhost:8888/files/myhtml.html") and mark the extension to scripts, styles and subdirectories, and the host-relative form, as
not stated by the page. Either add an OWNER grant or say the agent must confirm the URL in the browser.

## Info

### IN-01: `<html>` is not in backticks, so a Markdown renderer swallows it

**File:** `plugins/bbj/skills/bbj-web-programming/SKILL.md:84`
**Issue:** "HTML text in a control must start with <html> or it shows as literal text." In CommonMark and GitHub rendering `<html>` is a raw
HTML tag and disappears, so a person reading the rendered file sees "must start with  or it shows". The granted D-24 sentence is
reproduced exactly, so the plain text is kept for the agent, but the rendered form is unreadable.
**Fix:** Write `<html>` in backticks if the gate that locks the granted sentence allows it, or add a second clause
such as "(the literal tag `<html>`)".

### IN-02: The running-dwc-apps example puts empty credentials in the code and points to a command-line page that does not launch a DWC app

**File:** `plugins/bbj/skills/bbj-web-programming/references/running-dwc-apps.md:35-61`
**Issue:** The block sets `user$ = ""` and `password$ = ""`, so run as written `getBBjAdmin("", "")` fails; the prose says the caller
supplies them, but the placeholders look like values. The block creates an app named "MyApp" on every run with no check for an existing app
of the same name. Line 61 ("To run a program from a shell when the user asks, see bbj-programming/references/running.md") sits under a file whose rule is
that a DWC app is opened in a browser and invites an agent to start a DWC program with `bbj ...`, which is the symptom the
SKILL.md description lists. The `BBjThinClient.browse` bullet (lines 31-33) has no stated purpose.
**Fix:** Name the placeholders `adminUser$` and `adminPassword$` with a comment that the caller sets them, or read them from the caller. Replace line 61 with a sentence that a DWC app
is not started by the `bbj` command line (the file's own rule) and that `running.md` applies to console programs. Either say when `browse` is used or drop the bullet.

### IN-03: The label-part selector is normalised from the page's `part::label` without saying so

**File:** `plugins/bbj/skills/bbj-web-programming/SKILL.md:83`
**Issue:** DWC_Labels.htm says "targeting the `part::label` of the Shadow DOM". The skill quotes that sentence, then states "The selector is
`::part(label)`" and cites css-shadow-parts. The `label` part name is confirmed on the component pages (BBjEditBox lists a `label` part)
and the `::part()` syntax on css-shadow-parts, so the result is right, but the skill does not name the element the selector is attached to and
does not say it corrected the page's reversed spelling, so a reader comparing with the page sees two different spellings.
**Fix:** Add a `<tag>::part(label) { ... }` example taken from a component page (the BBjEditBox page lists a `label` part), and note that the BASIS page writes it as `part::label`.

---

_Reviewed: 2026-10-12_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
