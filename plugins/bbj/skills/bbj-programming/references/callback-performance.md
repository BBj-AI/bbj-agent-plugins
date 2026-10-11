# Form validation callbacks (ON_FORM_VALIDATION)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm

- The callback must call `accept()`. "When BBj fires a BBjFormValidationEvent, it also locks the top level
  window from user changes. This method must be called to unlock the window."
- `accept(1)` accepts the form and then fires the button push event: "If the form is accepted, BBj fires a
  BBjButtonPushEvent. If the form is rejected, this event is not fired."
- There is no `reject` method. `accept(0)` rejects: "valid Indicates whether the form is accepted (1) or
  rejected (0)." `bbjcpl -t` reports `No match for method ...BBjFormValidationEvent.reject(BBjInt)`;
  `bbj-ls` passes it.

```bbj should-fail
class public Demo
    method public void onValidate(BBjFormValidationEvent event!)
        event!.reject(0)
    methodend
classend
```

Every path of the callback ends in `accept(1)` or `accept(0)`:

```bbj
class public Demo
    method public void onValidate(BBjFormValidationEvent event!)
        failed = 0
        if failed = 0 then
            event!.accept(1)
        else
            event!.accept(0)
        endif
    methodend
classend
```

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probes s03, s04)
