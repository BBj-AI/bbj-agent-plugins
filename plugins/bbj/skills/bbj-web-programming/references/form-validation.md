# Form validation — server-side vs. client-side (DWC)

**Server-side:** when the user submits (clicking a `BBjButton`), data goes to BBj and you validate it by listening for `BBjFormValidationEvent`. At that point BBj has already locked the top-level window (all input disabled) — the program must call `accept(0)` or `accept(1)` on the event (or on the `BBjButton`) to unlock it. Forgetting this call is a real gotcha: the UI stays frozen (see **bbj-programming** → `references/callback-performance.md` for the `ON_FORM_VALIDATION`/`event!.accept(1)` freeze trap).

**Client-side (DWC only, BBj 22.10+, via the `ClientValidation` interface):** feedback appears inline or as a popover under the control as the user types, entirely in the browser, before anything is sent to BBj. **Never trust client-validated data on the server** — a malicious user can alter the network request even when the client-side form validates cleanly, so re-check on the BBj side regardless.

Client-side validation comes in two flavors, and **built-in validation always wins when a control has both**:
- **Built-in** — no JavaScript, just validation attributes on the control.
- **JavaScript** — a boolean expression/function you supply.

Controls supporting client-side validation (all support JS validation; some also have built-in rules): `BBjCEdit`, `BBjCheckBox`, `BBjEditBox`, `BBjEditBoxSpinner`, `BBjInputD`, `BBjInputDSpinner`, `BBjInputE`, `BBjInputESpinner`, `BBjInputN`, `BBjInputNSpinner`, `BBjListBox`, `BBjListButton`, `BBjListEdit`, `BBjRadioButton`.

## Built-in validation attributes by control

| Control | Attributes |
|---|---|
| `BBjEditBox` | `required`, `minlength`/`maxlength`, `min`/`max` (numeric input types), `type` (number/email/etc.), `pattern` (regex) |
| `BBjInputD` | `required`, `pattern` (applied to the masked *string* value, not the julian number), `min`/`max` (julian date) |
| `BBjInputT` | `required`, `pattern` (applied to the masked string), `min`/`max` (0–24) |
| `BBjInputE` | `required`, `pattern` (applied to the masked value) |
| `BBjInputN` | `required`, `min`/`max` |
| `BBjRadioButton` | `required` — only one button in a same-named group can be selected at a time |
| `BBjCheckBox` | `required` — must be checked before submit |
| `BBjCEdit` | `required`, `minlength` |

## JavaScript validation

Set the expression with `setClientValidationFunction(javascript!)` (or the equivalent `validator` attribute: `control!.setAttribute("validator", "Expression")`). The expression must evaluate to a boolean:
- No `return` in the expression → BBj wraps it in `return ...;` for you.
- Contains `return` → treated as a multi-line function body; you supply `;` on each line and the `return` yourself.

Expression parameters available: `value` (alias `x`, control-specific — see table below), `text` (text representation of the current value), `control` (the client component instance).

| Control | `value` | `text` |
|---|---|---|
| `BBjCEdit` | Text | Text |
| `BBjCheckBox` | Boolean | `'1'` checked / `'0'` not |
| `BBjRadioButton` | Boolean | `'1'` checked / `'0'` not |
| `BBjEditBox`, `BBjEditBoxSpinner` | Text | Text |
| `BBjInputD`, `BBjInputDSpinner` | Date | Date string as typed |
| `BBjInputT`, `BBjInputTSpinner` | Number | Text |
| `BBjInputE`, `BBjInputESpinner` | Text | Text |
| `BBjInputN`, `BBjInputNSpinner` | Number | Number as text |
| `BBjListBox` | Array of selected item(s) | Selected item text(s), `\n`-joined |
| `BBjListEdit` | Text | Text |
| `BBjListButton` | Selected item text | Selected item text |

```bbj
REM Valid when the value is present
control!.setClientValidationFunction("value")

REM Valid when the value is exactly 8 characters
control!.setClientValidationFunction("value.length == 8")

REM Valid when value is an array containing "item-1" — needs an explicit return (multi-statement)
control!.setClientValidationFunction("return Array.isArray(value) && value.indexOf('item-1') > -1;")

REM Valid when the value is all digits
control!.setClientValidationFunction("/^\d+$/.test(value)")
```

## Customizing validation behavior, placement, style, and message

A set of attributes per control (or set once on the closest `BBjWindow`/prefixed with `data-` to apply to every control inside it, e.g. `window!.setAttribute("data-validation-style", "inline")`):

| Attribute | Description | Type | Default |
|---|---|---|---|
| `auto-validate` | Validate on every change | boolean | `true` |
| `auto-validate-on-load` | Validate on first load | boolean | `false` |
| `auto-was-validated` | Auto-flip the `valid` property once the control becomes valid | boolean | `false` |
| `invalid-message` | Error message shown when invalid | string | `` |
| `validation-icon` | Icon for the validation message — URL, data URL, `ICON_NAME`, or `POOL_NAME:ICON_NAME` | string | `'bbj:info'` |
| `validation-popover-distance` | Offset (px) away from the control | number | `6` |
| `validation-popover-skidding` | Offset (px) along the control | number | `0` |
| `validation-popover-placement` | `top`/`bottom`/`left`/`right` (+ `-start`/`-end`) | string | `'bottom'` |
| `validation-style` | `popover` message vs. `inline` | string | `'popover'` |
| `validation-stop-after-first-invalid` | Stop at first invalid control and focus it, vs. validating the whole form | boolean | `true` |
| `validation-auto-disable` | Disable the form's submit button while any control is invalid | boolean | `false` |
| `message` | Busy-indicator message | string | `` |
| `suppress-spinner` / `suppress-message` | Hide the spinner / hide the message | boolean | `false` / `true` |
| `spinner-clockwise` | Spinner animation direction | boolean | `true` |
| `spinner-expanse` | Spinner size (`2xs`…`3xl`) | string | `'default'` |
| `spinner-theme` | Spinner semantic theme (`primary`/`success`/`danger`/etc.) | string | `'default'` |

## BBjControlValidation plugin

A reusable set of JS validators, composed with a builder instead of hand-writing expressions:
```bbj
use ::BBjControlValidation/ValidationBuilder.bbj::ValidationBuilder
use ::BBjControlValidation/Validators/NotBlank.bbj::NotBlank
use ::BBjControlValidation/Validators/MinLength.bbj::MinLength
use ::BBjControlValidation/Validators/MaxLength.bbj::MaxLength
use ::BBjControlValidation/Validators/Regex.bbj::Regex

validation! = new ValidationBuilder()
validation!.add(new NotBlank("Please provide a username"))
validation!.add(new MinLength(2))
validation!.add(new MaxLength(20))
validation!.add(new Regex("^[a-zA-Z0-9_]+$"))
control!.setClientValidationFunction(validation!.build())
```
