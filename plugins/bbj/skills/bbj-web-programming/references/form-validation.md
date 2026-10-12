# Form validation in the DWC

Page: https://dwc.style/docs/#/dwc/guide/form-validation
Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjinterfaces/IF_ClientValidation/Interface_ClientValidation.htm
Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjinterfaces/IF_ClientValidation/Interface_ClientValidation_setClientValidationFunction.htm
Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm

- The window stays locked until the callback calls `accept()`. BBjFormValidationEvent.accept: "When BBj fires a
  BBjFormValidationEvent, it also locks the top level window from user changes. This method must be called to
  unlock the window." accept(1), accept(0) and the missing reject method: see
  bbj-programming/references/callback-performance.md.
- Client-side validation needs BBj 22.10 or higher. The form validation guide: "Client-side validation is
  supported in BBj 22.10 and higher through the" ClientValidation interface. The controls that implement it
  are listed on the Interface_ClientValidation page under "Implementing Classes".
- Built-in validation wins over JavaScript validation. The guide: "Built-in validation has a higher priority
  than Javascript validation. In other words if a control is using both built-in and javascript validation the
  built-in validation will always be used."
- Never trust client-validated data. The guide: "Never trust data passed to your server from the client. Even
  if your form is validating correctly and preventing malformed input on the client-side, a malicious user can
  still alter the network request." and "the data is sent to BBj where you can check the validated data again."
- A JavaScript validation is set with `setClientValidationFunction(javascript!)` or with the `validator`
  attribute, `setAttribute("validator", "Expression")`. setClientValidationFunction: "The code must return a
  boolean value to indicate whether the value is considered to be valid." The guide says the same for the
  expression.
- The `return` insertion rule. Interface_ClientValidation: "If the function does not contain the word
  "return", BBj will insert "return " at the start." and "If the function contains multiple lines of JavaScript
  code separated by ";", it must explicitly specify a return statement." The guide: "If the expression has
  many lines, then you will need to provide the ; at the end of each line and also provide the return
  statement."
- The variables available to the function are `value`, `text` and `control` (setClientValidationFunction: "The
  variables available to the client validation function are value, text, and control."). What `value` and
  `text` hold for each control class is in the guide, section "Text & value".
- Attributes set on the closest BBjWindow apply to the controls inside it. The guide: "It is also possible to
  set theses attributes on the closest BBjWindow instead of setting them per control. The attribute name in
  this case must be prefixed with data-".
- The built-in attributes of each control, the value and text of each control class, and the customization
  attributes are tables in the guide and are not copied here.

A JavaScript expression and a built-in attribute on one control, and a `data-` attribute on the window:

```bbj
declare auto BBjSysGui sysgui!
declare auto BBjTopLevelWindow win!
sysgui! = BBjAPI().openSysGui("X0")
win! = sysgui!.addWindow("t", $00100083$)
win!.setAttribute("data-validation-style", "inline")
declare auto BBjEditBox code!
code! = win!.addEditBox("")
code!.setClientValidationFunction("value.length == 8")
code!.setAttribute("required", "true")
```

## Sources

- https://dwc.style/docs/#/dwc/guide/form-validation
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjinterfaces/IF_ClientValidation/Interface_ClientValidation.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjinterfaces/IF_ClientValidation/Interface_ClientValidation_setClientValidationFunction.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probe p12)
