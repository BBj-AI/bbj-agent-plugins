---
phase: 05
review: 05-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "The form-validation example puts a JavaScript validator and `required` on one control, which the file's own rule says makes the validator dead code"
  - id: WR-02
    severity: warning
    disposition: open
    title: "`getDwcUrl(0)` and `getBuiUrl(0)` are shown with an unexplained argument that is the `ssl` flag"
  - id: WR-03
    severity: warning
    disposition: open
    title: "The shoelace.md example moves the same `sl-icon` into two parents and then overwrites the card with `setHtml`"
  - id: WR-04
    severity: warning
    disposition: open
    title: "The BBjColorChooser saturation and lightness rule says \"the documentation does not state it\", but the documentation states a different range"
  - id: WR-05
    severity: warning
    disposition: open
    title: "styling.md tells an agent to define a new theme but never how to activate it, and its `setTheme` quote implies only three names"
  - id: WR-06
    severity: warning
    disposition: open
    title: "\"Attributes set on the closest BBjWindow apply to the controls inside it\" is broader than the guide"
  - id: WR-07
    severity: warning
    disposition: open
    title: "The channel-order rule drops the conditions the source attaches to `setAttribute` and `setProperty`"
  - id: WR-08
    severity: warning
    disposition: open
    title: "The `/files/` rule is stated for any file, but the page states it for one HTML file"
  - id: IN-01
    severity: info
    disposition: open
    title: "`<html>` is not in backticks, so a Markdown renderer swallows it"
  - id: IN-02
    severity: info
    disposition: open
    title: "The running-dwc-apps example puts empty credentials in the code and points to a command-line page that does not launch a DWC app"
  - id: IN-03
    severity: info
    disposition: open
    title: "The label-part selector is normalised from the page's `part::label` without saying so"
---

# Phase 05 — Code Review Disposition

One row per finding in `05-REVIEW.md`; `open` until fixed, accepted or rejected.

