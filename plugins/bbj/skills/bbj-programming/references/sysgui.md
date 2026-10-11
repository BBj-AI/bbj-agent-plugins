# SysGui: windows, list buttons, clickable images

An undeclared window or control assigned to a typed field is covered by the undeclared-value rule in SKILL.md.

## Window flags: Invisible and Dialog

`addWindow` takes a flags value. Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm

- `$00000010$` Invisible: "Sets the window to be initially invisible."
- `$00080000$` Dialog: "Sets the window to behave as a dialog." The flags add up: `$00080010$` is a dialog that starts invisible.

A top-level window has no `setModal` method. `bbjcpl -t` reports `No match for method ...BBjTopLevelWindow.setModal(BBjInt)`;
`bbj-ls` passes it. Pass the Dialog flag when the window is created.

```bbj should-fail
declare auto BBjSysGui sysGui!
declare auto BBjTopLevelWindow win!
sysGui! = BBjAPI().openSysGui("X0")
win! = sysGui!.addWindow(10, 10, 300, 200, "Demo")
win!.setModal(1)
```

```bbj
declare auto BBjSysGui sysGui!
declare auto BBjTopLevelWindow win!
sysGui! = BBjAPI().openSysGui("X0")
win! = sysGui!.addWindow(10, 10, 300, 200, "Demo", $00080010$)
```

## insertItems on a list button

`insertItems(index, items)` takes a 0-based index and either a `BBjVector` or one string whose items are
separated by `$0a$` (https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjlistbutton/bbjlistbutton_insertitems.htm).

```bbj
declare auto BBjSysGui sysGui!
declare auto BBjTopLevelWindow win!
sysGui! = BBjAPI().openSysGui("X0")
win! = sysGui!.addWindow(10, 10, 300, 200, "Demo")
declare auto BBjListButton lb!
declare auto BBjVector items!
lb! = win!.addListButton(101, 10, 10, 100, 20, "")
items! = BBjAPI().makeVector()
items!.addItem("a")
lb!.insertItems(0, items!)
lb!.insertItems(0, "x" + $0a$ + "y")
```

## Clickable images

By default "low-level mouse events are only reported when the user clicks directly on the window, or on
certain selected controls (static text, image, group box)"
(https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjwindow/BBjWindow_setReportAllMouseEvents.htm).
Call `setReportAllMouseEvents(1)` on the window and register `ON_MOUSE_DOWN` on the window. In the callback,
`getOriginalControl()` returns the control that was clicked; "As always, getControl returns the window"
(https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjMouseEvent/BBjMouseEvent_getOriginalControl.htm).

```bbj
class public Demo
    field private BBjTopLevelWindow win!
    method public Demo()
        declare auto BBjSysGui sysGui!
        sysGui! = BBjAPI().openSysGui("X0")
        #win! = sysGui!.addWindow(10, 10, 300, 200, "Demo")
        #win!.setReportAllMouseEvents(1)
        #win!.setCallback(BBjAPI.ON_MOUSE_DOWN, #this!, "onImageClick")
    methodend

    method public void onImageClick(BBjMouseDownEvent event!)
        declare auto BBjControl ctrl!
        ctrl! = event!.getOriginalControl()
    methodend
classend
```

## Message boxes

For the constants and the MODE options use `bbj_lookup` on MSGBOX and
https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/msgbox_function_bbj.htm.
`bbjcpl -t` reports a misspelled constant: `No such field: com.basis.bbj.proxies.BBjSysGui.MSGBOX_NOSUCH_CONSTANT`
(`bbj-ls` passes it).

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjlistbutton/bbjlistbutton_insertitems.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjwindow/BBjWindow_setReportAllMouseEvents.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjMouseEvent/BBjMouseEvent_getOriginalControl.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/msgbox_function_bbj.htm
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probes s01, s02, s05, s06, i01, s09)
