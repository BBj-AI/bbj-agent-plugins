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

- `BBjAPI().getWebManager()` returns the BBjWebManager, which in BBj 22.03 and higher "provides an interface to BUI and DWC application runtime settings." (BBjAPI_getWebManager.htm) `injectStyle` "injects the specified CSS into the web page" and `injectScript` "injects the specified JavaScript into the web page", both in BBj 22.03 and higher.
- The `top` argument of injectStyle (https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm): "A boolean value specifying whether this CSS is to be injected into the top level window of the page." `injectStyleUrl`, `injectScript` and `injectScriptUrl` say the same of their style or script.
- `injectLinkUrl` differs (https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectLinkUrl.htm): its `top` "Specifies which element the link URL will be injected into." 1 is the head element, 0 is the body element, and the head is the default.
- The attributes argument: "A set of attributes to be added to the style element. Attributes can be specified either as a string in the format "attr=value,attr=value" or as a HashMap containing key/value pairs." The script methods add them to the script element.
- A file saved in the htdocs directory under the basis home directory "can be accessed with a URL in the format http://localhost:8888/files/myhtml.html" (DWC_Registration_Launching.htm); the path part is `/files/`.

```bbj
declare auto BBjWebManager web!
web! = BBjAPI().getWebManager()
css$ = ":root { --app-gap: 8px; }"
web!.injectStyle(css$, 1, "id=app-vars")
web!.injectScriptUrl("/files/lib/shoelace/shoelace.js", 1, "type=module")
web!.injectLinkUrl("/files/app.css", 1, "rel=stylesheet")
```

## Classes and styles on windows and controls

- `addClass(className)`: "In BBj 23.00 and higher, this method adds a CSS class name to the BBjControl." (BBjControl_addClass.htm) "CSS settings have no effect on the GUI client." `setStyle(property, value)` "sets a CSS property on the BBjControl" (BBj 18.00 and higher).
- On a BBjTopLevelWindow `addOuterStyle(class)` (BBjTopLevelWindow_addOuterStyle.htm) "adds a CSS class name to the outer component" (BBj 22) and `setOuterStyle(property, value)` "sets a CSS property on the outer component" (BBj 21): a class against a property. Also there: `removeOuterStyle`, `clearOuterStyles`, `getOuterStyles` (BBj 22), `getOuterStyle`, `getComputedOuterStyle` (BBj 21).
- `setPanelStyle(property, value)` "sets a CSS property on the content panel of a BBjWindow" (BBjWindow_setPanelStyle.htm), the panel which "contains the window's controls" (DWC_Taking_GUI_App_to_DWC.htm).
- addClass() on a BBjTopLevelWindow puts the class on dwc-window-center and addOuterStyle() puts it on dwc-frame. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it horizontally. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose controls are its direct children. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.

A BBjChildWindow or a BBjButton has no `setOuterStyle`: `bbjcpl -t` reports `No match for method` (`bbj-ls` passes it).

```bbj should-fail
declare auto BBjSysGui sysgui!
declare auto BBjTopLevelWindow win!
declare auto BBjChildWindow panel!
sysgui! = BBjAPI().openSysGui("X0")
win! = sysgui!.addWindow("My App", $00101093$)
panel! = win!.addChildWindow("", $00108800$, sysgui!.getAvailableContext())
panel!.setOuterStyle("border-radius", "8px")
```

The window takes `addOuterStyle` and `setOuterStyle`; the child window takes `setPanelStyle` and `addClass`:

```bbj
declare auto BBjSysGui sysgui!
declare auto BBjTopLevelWindow win!
declare auto BBjChildWindow panel!
sysgui! = BBjAPI().openSysGui("X0")
win! = sysgui!.addWindow("My App", $00101093$)
win!.addOuterStyle("login-frame")
win!.setOuterStyle("border-radius", "8px")
panel! = win!.addChildWindow("", $00108800$, sysgui!.getAvailableContext())
panel!.setPanelStyle("display", "grid")
panel!.addClass("sidebar")
```

## Attributes and properties

- `setAttribute`: "This functionality is primarily intended for setting low-level BUI element attributes or DWC component attributes. When running in GUI, the attributes do not affect the control itself, but may be used by the developer." (BBjControl_setAttribute.htm)
- "Each control exposes the same customization through two channels" (https://dwc.style/docs/#/dwc/guide/attributes-and-properties): attribute and property. `setProperty` sends its value "in JSON string format" (BBjControl_setProperty.htm).
- Reflects Yes (BBjButton: `theme`, `disabled`, `expanse`): "changing the property updates the attribute on the DOM as well, and vice versa. Either channel can be used to read or write the value". Reflects No (`autofocus`, `label`): "the attribute is only an initial hint. Changing the property does not update the attribute, and changing the attribute after the component is constructed may have no effect."
- "Use the channels in this order": the dedicated BBj method, then `setAttribute`, then `setProperty`. For reading, prefer the dedicated getter first.
- Declare the control: with an undeclared `button!`, `bbjcpl -t` reports `Cannot assign <undeclared> to BBjString` on `getAttribute`. `getProperty` returns an object: a `$` variable gives `Cannot assign java.lang.Object to BBjString`.
- In the DWC, `setAttribute("label", text)` on a BBjControl creates a label element (https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Labels.htm). The page names three advantages: it reduces "the number of elements", it keeps the control and its label "closely connected regardless of layout", and it helps screenreaders link a field with its description.
- Style a label through its shadow part: "Use CSS to control label styles by targeting the part::label of the Shadow DOM on the control." The selector is `::part(label)` (https://dwc.style/docs/#/theme-engine/css-shadow-parts).
- HTML text in a control must start with <html> or it shows as literal text. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- A BBjColorChooser shows no caption for setAttribute("label", ...). That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a fraction from 0 to 1.0. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.

```bbj
declare auto BBjTopLevelWindow win!
declare auto BBjButton button!
win! = BBjAPI().openSysGui("X0").addWindow("My App", $00101093$)
button! = win!.addButton("Save")
button!.setAttribute("theme", "danger")
themeName$ = button!.getAttribute("theme")
themeValue! = button!.getProperty("theme")
```

## Automatic Layout

- `$00100000$` (https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm) "Automatic Layout : Automatically arranges all controls and child windows placed in the window to fit. In the DWC client, this flag causes the window to use dynamic flow layout, ignoring all absolute control sizes and positions."
- addChildWindow (bbjwindow_addchildwindow.htm): "If the x, y, width, and height parameters are not specified, they are all initialized to 0. This is typically for use with DWC windows that dynamically arrange their contents (window creation flag $00100000$)."
- Window composites, by the flag names of the addWindow page: `$00101093$` is Automatic Layout, Maximized, Maximizable and Minimizable, Invisible, Close box, Resizable. `$00180013$` is Automatic Layout, Dialog, Invisible, Close box, Resizable. Child window composites, by the addChildWindow page: `$00108800$` is Automatic Layout, Simple, Borderless. `$00109000$` is Automatic Layout, Simple, Fieldset, "created as a fieldset element to emulate groupbox functionality". Simple "is only meaningful in the DWC client".
- `sysgui!.getAvailableContext()` "Returns the next available context ID." It is the context argument of addChildWindow and of the addWindow overload with a context.
- Overloads without coordinates compile on a BBjTopLevelWindow: `addButton("Browse")`, `addEditBox("")`, `addStaticText("x")`, `addTree()`, `addGrid()`, `addListButton("")`, `addCEdit("", $0102$)`, `addToolButton("x")`.
- WindowBuilder: the flag "is not currently exposed in the UI, and corresponds to the "GRAVITY" flag. To enable flow layout in the DWC, add a line with the keyword GRAVITY to the ARC source file in the section with the child window properties."

```bbj
declare auto BBjSysGui sysgui!
declare auto BBjTopLevelWindow win!
declare auto BBjChildWindow panel!
sysgui! = BBjAPI().openSysGui("X0")
win! = sysgui!.addWindow(sysgui!.getAvailableContext(), "My App", $00101093$)
panel! = win!.addChildWindow("", $00108800$, sysgui!.getAvailableContext())
panel!.addEditBox("").setAttribute("label", "First Name")
```

## Web components

- "In BBj 24.00 and higher, the BBjWebComponent is a BBjControl that encapsulates a WebComponent or native HTML element in the BUI and DWC browser clients." Its events use `setCallback`; see `references/shoelace.md`.
- Declare the variable as a BBjWebComponent and assign `win!.addWebComponent("sl-card")`; no cast.
- `setSlot(control)` (https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/BBjControl_setSlot.htm): "If no slot string is specified, or is specified as "", the specified control is added to the default slot." `setSlot(slot, control)`: the syntax is "setSlot(String slot , BBjControl control )", slot name first. "This method is only meaningful in the DWC client; it's ignored in all other environments."

Control first: `bbjcpl -t` reports `No match for method ...BBjWebComponent.setSlot(...BBjWebComponent, BBjString)` (`bbj-ls` passes it).

```bbj should-fail
declare auto BBjTopLevelWindow win!
declare auto BBjWebComponent card!
declare auto BBjWebComponent badge!
win! = BBjAPI().openSysGui("X0").addWindow("My App", $00101093$)
card! = win!.addWebComponent("sl-card")
badge! = win!.addWebComponent("sl-badge")
card!.setSlot(badge!, "footer")
```

Slot name first. A `dwc-icon` moves into a button's prefix slot: "In BBj 24.11 and higher, this method moves a child BBjControl into a parent BBjControl that's assumed to be a web component." Per https://dwc.style/docs/#/web-components/dwc-icon, "BBj does not bundle an icons library by default, but it configures several icons pools that the user can choose from. Then the icons will be loaded from a CDN on demand."

```bbj
declare auto BBjTopLevelWindow win!
declare auto BBjWebComponent card!
declare auto BBjWebComponent badge!
declare auto BBjWebComponent icon!
declare auto BBjButton button!
win! = BBjAPI().openSysGui("X0").addWindow("My App", $00101093$)
card! = win!.addWebComponent("sl-card")
badge! = win!.addWebComponent("sl-badge")
card!.setSlot("footer", badge!)
icon! = win!.addWebComponent("dwc-icon")
icon!.setAttribute("name", "bell")
button! = win!.addButton("Alerts")
button!.setSlot("prefix", icon!)
```

## Look it up instead

- `bbj_lookup` gives the page of a BBj method, `bbj_search` finds the rest, `bbj_fetch_page` reads a page. Cite the URL of every page you use.
- The attributes, parts and slots of a DWC component: https://dwc.style/docs/ . Styling and the `--dwc-*` tokens: https://docs.webforj.com/docs/styling/

## References

- `references/styling.md`: themes and the setTheme family, overriding a theme, component theme and expanse, shadow parts, the focus ring
- `references/form-validation.md`: client-side form validation and the accept rule
- `references/running-dwc-apps.md`: registering a program as a DWC or BUI app, its URL, opening it
- `references/shoelace.md`: loading a web component library, creating a component, listening to its events
