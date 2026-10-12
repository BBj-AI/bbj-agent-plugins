# Web component libraries in a DWC app (Shoelace as the example)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent.htm
Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent_setCallback.htm
Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent_setSlot.htm

## Loading the library

- A web component library's ES module is loaded by URL with `injectScriptUrl(url$, top, attributes$)` and
  `attributes$ = "type=module"`. The BBjWebComponent_setSlot page does this in its Shoelace example: it sets
  `attributes$ = "type=module"` and calls `browser!.injectScriptUrl(url$, top, attributes$)`.
- An ES module injected inline with injectScript() cannot load its relative imports, while the same module loaded with injectScriptUrl(url, top, "type=module") can. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.
- DWC_Registration_Launching gives a `/files/` URL for an html file saved in the htdocs directory: see
  SKILL.md, section "Injecting CSS and JavaScript". The `/files/lib/shoelace/shoelace.js` path below is an example, not
  a documented location of a library file; confirm its URL in the browser.

```bbj
declare auto BBjWebManager web!
web! = BBjAPI().getWebManager()
web!.injectScriptUrl("/files/lib/shoelace/shoelace.js", 1, "type=module")
```

## Creating a component

- `addWebComponent(tagName)` creates the component in a window. BBjWebComponent: "In BBj 24.00 and higher, the
  BBjWebComponent is a BBjControl that encapsulates a WebComponent or native HTML element in the BUI and DWC
  browser clients."
- `setAttribute` sets its attributes. BBjControl.setAttribute: "This functionality is primarily intended for
  setting low-level BUI element attributes or DWC component attributes."
  https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/BBjControl_setAttribute.htm
- `setHtml` sets the HTML content: "In BBj 24.00 and higher, this method sets the HTML content of this
  BBjWebComponent."
  https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent_setHtml.htm
- Nesting one component or control into another is `setSlot`: see SKILL.md, section "Web components", and the
  BBjWebComponent_setSlot page. `setSlot` "moves" the child (BBjControl_setSlot), so a control goes into one
  parent; the example makes a second icon for the second parent.

```bbj
declare auto BBjSysGui sysgui!
declare auto BBjTopLevelWindow win!
sysgui! = BBjAPI().openSysGui("X0")
win! = sysgui!.addWindow("t", $00100083$)
declare auto BBjWebComponent card!
declare auto BBjWebComponent icon!
declare auto BBjWebComponent copyIcon!
declare auto BBjWebComponent badge!
declare auto BBjButton copy!
card! = win!.addWebComponent("sl-card")
icon! = win!.addWebComponent("sl-icon")
icon!.setAttribute("name", "copy")
card!.setSlot(icon!); rem default slot of the card
copyIcon! = win!.addWebComponent("sl-icon")
copyIcon!.setAttribute("name", "copy")
copy! = win!.addButton("Copy")
copy!.setSlot("prefix", copyIcon!); rem prefix slot of the button
badge! = win!.addWebComponent("sl-badge")
badge!.setHtml("New"); rem HTML content of a component with no slotted children
```

## Listening to a component event

- The callback method takes one BBjWebEvent. BBjWebComponent.setCallback: "The method must take a single
  BBjWebEvent parameter".
- A component event is listened to with `newEventOptions()`, `addItem("value", "event.target.value")` and
  `setCallback(event, #this!, "method", options!)`. The page's example uses
  `options!.addItem("checked","event.target.checked")` the same way.

```bbj
class public Demo
    field private BBjWebComponent el!

    method public Demo(BBjTopLevelWindow win!)
        #el! = win!.addWebComponent("sl-rating")
        declare auto BBjWebEventOptions options!
        options! = #el!.newEventOptions()
        options!.addItem("value", "event.target.value")
        #el!.setCallback("sl-change", #this!, "onChange", options!)
    methodend

    method public void onChange(BBjWebEvent event!)
        val! = str(event!.getEventMap().get("value"))
    methodend
classend
```

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent_setCallback.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent_setSlot.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent_setHtml.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/BBjControl_setAttribute.htm
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probes p13, p16, q01)
