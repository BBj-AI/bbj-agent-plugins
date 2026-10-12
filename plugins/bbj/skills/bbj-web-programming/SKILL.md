---
name: "bbj-web-programming"
description: "Write, review, check, or fix BBj code that runs in a browser (DWC or BUI): injecting CSS and JavaScript with BBjWebManager and its top argument, addClass, addOuterStyle, setOuterStyle and setPanelStyle, setAttribute versus setProperty and the label attribute, Automatic Layout and window flags, BBjWebComponent and setSlot, DWC themes, client form validation, registering a DWC app. Trigger on symptoms without BBj being named: No match for method ... setSlot, No match for method ... setOuterStyle on a child window, HTML shown as literal text in a control, a DWC app opened with bbj instead of a browser URL. For BBj language rules also use the bbj-programming skill."
---

<!-- bbj-check-order:begin -->
**Check BBj code before you hand it back.** Use the first route that exists:

1. `bbjcpl -t -N -X <file>`, when BBj is installed on this machine. It checks syntax and types. `-N` writes no output files; the errors arrive on stderr.
2. `bbj_check_syntax` of the `bbj-local` server (the `bbj-ls` of a running BBjServices, BBj 26.03 or later), when that server is registered. It runs on this machine, against the installation's own PREFIX, classpath and config. It checks syntax only, not types.
3. Only when neither exists: `bbj_check_syntax` of the `bbj-docs` server, the hosted check. You may use it without asking, but tell the user that the code was sent to the server and checked against a stock BBj, not against their installation.

A hook checks the BBj files you write or edit. This order is for code you hand back without writing it to a file: answers, and code from earlier turns.
<!-- bbj-check-order:end -->

# BBj web programming (DWC and BUI)

Read `bbj://primer` before you write BBj; this file adds to it for browser clients. Rules here cite the
documentation page that states them or a compile result on BBj 26.03, except rules that say the skill
maintainer confirmed them on BBj 26.03.

## Injecting CSS and JavaScript

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm
Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectLinkUrl.htm
Page: https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Registration_Launching.htm

- `BBjAPI().getWebManager()` returns the BBjWebManager. In BBj 22.03 and higher it "provides an interface to BUI and DWC application runtime settings." (BBjAPI_getWebManager.htm)
- `injectStyle` "injects the specified CSS into the web page", `injectScript` "injects the specified JavaScript into the web page", both in BBj 22.03 and higher.
- The `top` argument of injectStyle: "A boolean value specifying whether this CSS is to be injected into the top level window of the page." `injectStyleUrl`, `injectScript` and `injectScriptUrl` say the same of their style or script.
- `injectLinkUrl` differs: its `top` "Specifies which element the link URL will be injected into." 1 is the head element, 0 is the body element, and the head is the default.
- The attributes argument: "A set of attributes to be added to the style element. Attributes can be specified either as a string in the format "attr=value,attr=value" or as a HashMap containing key/value pairs." The script methods add them to the script element.
- A file saved in the htdocs directory under the basis home directory "can be accessed with a URL in the format http://localhost:8888/files/myhtml.html"; the path part is `/files/`.

```bbj
declare auto BBjWebManager web!
web! = BBjAPI().getWebManager()
css$ = ":root { --app-gap: 8px; }"
web!.injectStyle(css$, 1, "id=app-vars")
web!.injectScriptUrl("/files/lib/shoelace/shoelace.js", 1, "type=module")
web!.injectLinkUrl("/files/app.css", 1, "rel=stylesheet")
```

## Classes and styles on windows and controls

- addClass() on a BBjTopLevelWindow puts the class on dwc-window-center and addOuterStyle() puts it on dwc-frame. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it horizontally. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose controls are its direct children. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.

## Attributes and properties

- HTML text in a control must start with <html> or it shows as literal text. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- A BBjColorChooser shows no caption for setAttribute("label", ...). That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a fraction from 0 to 1.0. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.

## Look it up instead

- `bbj_lookup` gives the page of a BBj method, `bbj_search` finds the rest, `bbj_fetch_page` reads a page.
- The attributes, parts and slots of a DWC component: https://dwc.style/docs/
- Styling and the `--dwc-*` tokens: https://docs.webforj.com/docs/styling/
- Cite the URL of every page you use.

## References

- `references/styling.md`: themes and the setTheme family, overriding a theme, component theme and expanse, shadow parts, the focus ring
- `references/form-validation.md`: client-side form validation and the accept rule
- `references/running-dwc-apps.md`: registering a program as a DWC or BUI app, its URL, opening it
- `references/shoelace.md`: loading a web component library, creating a component, listening to its events
