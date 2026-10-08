# Eliminating client–server round trips in callbacks

BBj UIs are server-rendered: every time a callback reads a control's value (`.getText()`, `.isSelected()`, `.getSelectedIndex()`) it makes a synchronous round trip from the BBj server to the client and back. Multiple reads in one callback multiply the latency — especially costly in DWC/BUI where the client is a browser.

## Rule: read from the event, not the control

When a callback fires **for** a control, the event already carries the new value — use it instead of re-querying the control:
```bbj
REM WRONG — round trip to the client
method public void onSearchModify(BBjEditModifyEvent event!)
    #savedText! = #searchBox!.getText()   ;REM ❌ round trip
methodend

REM CORRECT — value comes with the event, no round trip
method public void onSearchModify(BBjEditModifyEvent event!)
    #savedText! = event!.getText()        ;REM ✅ no round trip
methodend
```
Similarly for checkbox change events:
```bbj
method public void onIsBaseChange(BBjCheckChangeEvent event!)
    #savedIsBase! = iff(event!.getSelected() = 1, "1", "0")   ;REM ✅
methodend
```

## Tracking saved values to avoid reads in unrelated callbacks

When a callback fires for a **different** control (e.g. a button push that reads several edit boxes), those values can't come from the button event. Track them via `ON_EDIT_MODIFY` / `ON_CHECK_CHANGE` callbacks, each saving to a class field:
```bbj
REM In build() — register lightweight modify callbacks
#txtWatchH!.setCallback(BBjEditBox.ON_EDIT_MODIFY, #this!, "onWatchHChange")

REM Tiny callback — fires on each keystroke, no DB work
method public void onWatchHChange(BBjEditModifyEvent event!)
    #savedWatchH! = event!.getText()
methodend

REM Button callback now reads the pre-tracked field — 0 round trips
method public void onAdjustSeconds(BBjButtonPushEvent event!)
    h = num(#savedWatchH!, err=*NEXT)    ;REM ✅ already in memory
methodend
```

## ON_FORM_VALIDATION — best pattern for form Save buttons

For a Save button that needs to read **many** form controls at once, `ON_FORM_VALIDATION` is the best option. It collects all control values in one server-side snapshot — a single event delivers everything with no individual round trips:
```bbj
REM Register the Save button for form validation instead of a plain push
btnSave!.setCallback(BBjButton.ON_FORM_VALIDATION, #this!, "onSave")

REM The BBjFormValidationEvent carries all control values server-side
method public void onSave(BBjFormValidationEvent event!)
    make!    = event!.getText(#txtMake!).trim()     ;REM ✅ no round trip
    model!   = event!.getText(#txtModel!).trim()
    chron!   = iff(event!.getValue(#chkChron!) = 1, "1", "0")
    REM ... pass to DB method ...

    REM CRITICAL: the UI stays frozen until you accept or reject the event.
    REM Always call event!.accept(1) before returning, or the app will hang.
    event!.accept(1)
methodend
```
**Critical gotcha:** `BBjFormValidationEvent` holds the UI in a suspended state until the callback calls `event!.accept(1)` (or `event!.reject(0)`). If you forget this call, the entire UI freezes permanently after the first Save press. Always end every `ON_FORM_VALIDATION` callback with `event!.accept()`.

Ref: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjFormValidationEvent/bbjformvalidationevent.htm

## Summary: which pattern to use

| Situation | Pattern |
|---|---|
| Callback fires **for** the control being read | `event!.getText()` / `event!.getValue()` / `event!.getSelected()` |
| Button reads **one or two** other controls infrequently | Track those controls via `ON_EDIT_MODIFY` → saved field |
| Button reads **many** form controls (Save button) | `ON_FORM_VALIDATION` + `BBjFormValidationEvent` |
| Server already knows the value (set it programmatically) | Store it in a class field at set-time; never re-read from the control |
