# SysGui Information

These apply to both desktop GUI and web (DWC/BUI) clients — the SysGui layer is shared.

**A local `BBjChildWindow` variable must be `declare`d if any control created from it gets assigned to a typed variable** (a class field or a `declare`d local) — otherwise BBj can't infer the control's return type:
```bbj
method private void build(BBjChildWindow parentWin!)
    declare auto BBjChildWindow winRow!
    winRow! = parentWin!.addChildWindow("", $00108800$, #sysGui!.getAvailableContext())
    #txtFoo! = winRow!.addEditBox("")   REM only works because winRow! was declared
methodend
```
If controls from the window are used inline and never assigned to a typed variable, the `declare` isn't strictly required, but adding it anyway is the safe default.

**Every `addWindow()`/`addChildWindow()` call consumes its context** — call `getAvailableContext()` fresh each time, never reuse a stored context variable, or the second call throws ERROR 17 "Context already in use":
```bbj
panel!  = win!.addChildWindow("", $00108800$, sysGui!.getAvailableContext())   REM fresh call
panel2! = win!.addChildWindow("", $00108800$, sysGui!.getAvailableContext())   REM fresh call again — correct
```
This applies to **top-level** windows too, which is easy to miss because the common overloads omit the context. An app with more than one top-level window (e.g. a login dialog plus a main window) must use the `addWindow(int context, string title, string flags)` overload, or the second `addWindow()` throws ERROR 17 "Context already in use: 0":
```bbj
#winLogin! = sysGui!.addWindow(sysGui!.getAvailableContext(), "Login", $00180013$)
#winMain!  = sysGui!.addWindow(sysGui!.getAvailableContext(), "My App", $00101093$)
```

**`addWindow()` creates the window VISIBLE unless you pass the Invisible flag `$00000010$`.** Build several windows up front — a main window plus its dialogs — and every one of them pops onto the screen at startup. Add `$00000010$` to each and call `setVisible(1)` when you actually want it:
```bbj
#winDialog! = sysGui!.addWindow(sysGui!.getAvailableContext(), "Add User", $00180013$)  REM includes $10$
REM ...later, when the user asks for it:
#winDialog!.setVisible(1)
```

**Modality is a CREATION FLAG, not a setter.** There is no `setModal()`. Pass **`$00080000$`** ("Dialog": sets the window to behave as a dialog) at `addWindow()` time; `BBjTopLevelWindow::isModal()` merely reports whether that flag was used. In an `.arc` resource the same thing is spelled `DIALOGBEHAVIOR`. So a modal dialog that stays hidden until needed is `$00080000$ + $00000010$ + …`.

---
### Known-value database fields: BBjListButton / BBjListEdit + backing BBjVector

Docs — BBjListButton: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjlistbutton/bbjlistbutton.htm · BBjListEdit: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjlistedit/BBjListEdit.htm · BBjVector: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/API/bbjvector/bbjvector.htm

For a database field whose value is almost always one of a predetermined set, use a list control:

| Control | When |
|---|---|
| `BBjListButton` | The value is **always** in the known set — pure dropdown, no free entry |
| `BBjListEdit` | The value is **usually** in the known set, but the user may type a unique value — dropdown + editable field |

**Fill with `insertItems()`, not repeated `addItem()`.** `addItem()` is a round trip per item and gets slow with several items. `insertItems(index, items)` takes a 0-based insertion index (items don't have to go at the start or end) and a collection — either a `BBjVector` or a linefeed-delimited (`$0A$`) string. The crude string build works:
```bbj
FOR I = 1 TO 4
    ITEM$ = "ITEM " + STR(I)
    ITEMS$ = ITEMS$ + ITEM$ + $0A$
NEXT I
myListEdit!.insertItems(0, ITEMS$)
```
…but the **backing BBjVector is the better pattern**: fill a vector with the known values, pass it to `insertItems()` (or join it into the control's constructor), and keep it as a field. The vector is then an in-memory model of the control's contents — vector position = dropdown index. And because `BBjVector` implements `java.util.Collection` and `java.util.List`, you get `contains()`, `size()`, `indexOf()`, `lastIndexOf()` etc. for one-line lookups with no iteration.

Filling at creation time via `String.join($0A$, iterable)` — works with a BBjVector or any Iterable (e.g. a method returning an ArrayList):
```bbj
#lstStyle! = win!.addListButton(java.lang.String.join($0A$, cast(Iterable, filterItems!)))
#lstBlade! = win!.addListButton(java.lang.String.join($0A$, #getStyleOptions()))
```

**The full pattern for a known-value field:**

1. Create a `BBjVector` (class field) and load it with the known values.
2. Add the list control (`BBjListButton`, or `BBjListEdit` if user-provided values are necessary or likely).
3. Fill the control at instantiation or later via `insertItems(0, vect!)`.
4. Select the default index if known — or index 0 if that's appropriate.
5. Set the `label` attribute to attach a field label to the control (DWC — see **bbj-web-programming**).
6. Add any CSS classes used to group or identify the control (DWC — see **bbj-web-programming**).
7. Register `ON_LIST_CHANGE` and write a `BBjListChangeEvent` callback (https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjListChangeEvent/bbjlistchangeevent.htm):
   - `event!.getSelectedIndex()` — the selected dropdown index, which is **also the index into the backing vector**, so `#vectOptions!.getItem(event!.getSelectedIndex())` returns the selected item's text.
   - `event!.getSelectedItem()` — the selected item's text directly.

**Syncing the control to a recordset row: use `indexOf()`, never a loop.** When moving to a new row, the control must display the row's field value. The brute-force loop works but is slow and verbose:
```bbj
REM SLOW — hand-rolled iteration
method private void selectStyle(BBjString value!)
    if (#vectStyleOptions!.size() < 1) then methodret
    for i = 0 to #vectStyleOptions!.size() - 1
        item! = #vectStyleOptions!.getItem(i)
        if (item! = value!) then
            #lstStyle!.selectIndex(i)
            break   REM without break it keeps scanning after the match
        endif
    next i
methodend
```
The `List.indexOf()` one-liner is faster and far less code — it returns the index of the first occurrence, or -1 if absent:
```bbj
REM FAST — indexOf does the heavy lifting
method private void selectStyle(BBjString value!)
    index = #vectStyleOptions!.indexOf(value!)
    #lstStyle!.selectIndex(max(index, 0))
methodend
```
Handling the -1 (value not in list) is application-dependent. Here `max(index, 0)` always selects a valid index: the matching item when present, otherwise the first item (useful when index 0 is an "undefined"/"not applicable" entry). For a `BBjListEdit`, an alternative is to `setText(value!)` when the value isn't in the list.


---

### Message boxes: MSGBOX() function and BBjMsgBox object

Docs — function: https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/msgbox_function_bbj.htm · object: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/BBjMsgBox/BBjMsgBox.htm

Basic usage — always application modal, returns which button was pressed:
```bbj
result = msgbox("Delete this record?", BBjSysGui.MSGBOX_BUTTONS_YES_NO + BBjSysGui.MSGBOX_ICON_QUESTION, "Confirm")
if (result = BBjSysGui.MSGBOX_RETURN_YES) then
    REM ... delete ...
endif
```

**Use the `BBjSysGui` constants (BBj 21.00+), not raw numbers** — `BBjSysGui.MSGBOX_ICON_STOP` is far more readable and maintainable than `16`. The second parameter is **additive**: buttons + icon + default button + flags.

| Group | Constants (value) |
|---|---|
| Buttons | `MSGBOX_BUTTONS_OK` (0), `MSGBOX_BUTTONS_OK_CANCEL` (1), `MSGBOX_BUTTONS_ABORT_RETRY_IGNORE` (2), `MSGBOX_BUTTONS_YES_NO_CANCEL` (3), `MSGBOX_BUTTONS_YES_NO` (4), `MSGBOX_BUTTONS_RETRY_CANCEL` (5), `MSGBOX_BUTTONS_CUSTOM` (7) |
| Icon | `MSGBOX_ICON_NONE` (0), `MSGBOX_ICON_STOP` (16), `MSGBOX_ICON_QUESTION` (32), `MSGBOX_ICON_EXCLAMATION` (48), `MSGBOX_ICON_INFORMATION` (64) |
| Default button | `MSGBOX_DEFAULT_FIRST` (0), `MSGBOX_DEFAULT_SECOND` (256), `MSGBOX_DEFAULT_THIRD` (512), `MSGBOX_DEFAULT_NONE` (65536) |
| Flags | `MSGBOX_RAW_TEXT` (32768, disable HTML rendering), `MSGBOX_MDI_DESKTOP` (131072) |
| Return values | `MSGBOX_RETURN_OK` (1), `MSGBOX_RETURN_CANCEL` (2), `MSGBOX_RETURN_ABORT` (3), `MSGBOX_RETURN_RETRY` (4), `MSGBOX_RETURN_IGNORE` (5), `MSGBOX_RETURN_YES` (6), `MSGBOX_RETURN_NO` (7) |

Return-value gotchas: custom-button boxes (type 7) return the button *position* (1/2/3); `Esc`/close returns 2 (Cancel) for types 1/3/5 but **0** for types 0/7; with `TIM=int` (BBj 17+) a timeout returns **-1** — handle 0 and -1 or a dismissed dialog silently falls through.

Custom button labels (return value = position):
```bbj
x = msgbox("Accept print job?", BBjSysGui.MSGBOX_BUTTONS_CUSTOM, "Printing complete", "Yes", "Reprint", "Fax")
```

Message and title render as **HTML** if the string starts with `<html>` (suppress with `MSGBOX_RAW_TEXT`). Force line breaks with `$0a$`.

**MODE= options** (comma-separated in one string, e.g. `mode="X=100,Y=100,theme=danger"`):

| Mode | Effect |
|---|---|
| `X=int,Y=int` | Dialog position (default: centered) — BBj 15+ |
| `W=int,H=int` | Max dialog width/height — BBj 19.10+ |
| `SPLIT=int` | Max chars per line before auto line break (default 100) — BBj 20.11+ |
| `SCALE=num` | Scale factor for button/text fonts — BBj 25.03+ |
| `ICON=imagefile` / `ICON=url` | Custom icon (file path, URL, or data URL) — BBj 22+ |
| `ICONWIDTH=int`, `ICONHEIGHT=int` | Scale the custom icon — BBj 22+ |
| `STYLE=name` | Adds a CSS style name (like `addStyle()`) for BUI custom styling — BBj 14+ |
| `attr=value` | Generic DWC dialog attributes (e.g. `theme=danger`, `blurred=true`) — BBj 21.10+ |
| `TIM=int` (separate option, not in the mode string) | Timeout in seconds; returns -1 on timeout — BBj 17+ |

**DWC theming via `mode="theme=..."`** — critical for DWC apps; the theme has a profound effect on the dialog's appearance. Available control themes: `primary` (blue), `success` (green), `warning` (orange), `danger` (red), `info` (purple), `gray`, and `default` (desaturated light blue-gray). Individual buttons can be themed too: `mode="button-0-theme=success,button-1-theme=danger"`.
```bbj
temp = msgbox("Target device offline; could not copy files", BBjSysGui.MSGBOX_ICON_STOP, "Backup Failed", mode="theme=danger")
temp = msgbox("Files backed up successfully!", BBjSysGui.MSGBOX_ICON_INFORMATION, "Backup Completed", mode="theme=success")
```
The theme colors are the DWC defaults and can be re-tuned via CSS custom properties — e.g. shift primary from blue to purple with `:root { --dwc-color-primary-h: 260; }` (`-h` = hue angle 0–360; DWC's default primary hue is 211). CSS injection and `--dwc-*` tokens are covered in **bbj-web-programming**.

**BBjMsgBox fluent object (BBj 25.03+)** — equivalent to MSGBOX(), nicer for building dialogs programmatically:
```bbj
result = BBjAPI().msgbox().message("Delete this record?")
:               .title("Confirm")
:               .options(BBjSysGui.MSGBOX_BUTTONS_YES_NO + BBjSysGui.MSGBOX_ICON_QUESTION)
:               .modes("theme=danger")
:               .timeout(30)
:               .show()
```
Builder methods: `message()`, `title()`, `options()`, `modes()`, `timeout()`, `button1()`/`button2()`/`button3()` — all return the BBjMsgBox for chaining; `show()` displays the dialog and returns the int result (same return values as MSGBOX()).

---

### Clickable images: BBjImageCtrls in a BBjChildWindow + getOriginalControl()

**`BBjImageCtrl` has no click/mouse callbacks** — setting one throws "Callback ON_MOUSE_DOWN is not valid for BBjImageCtrlFacade". The fix is to make the *containing window* handle mouse events for its images:

1. Put the image(s) in a `BBjChildWindow`.
2. Call `setReportAllMouseEvents(1)` on the window so every contained control forwards low-level mouse events (mouse down/up/move) to the window. (By default only clicks on the window itself and on certain controls — static text, image, group box — are reported; setting it explicitly is the reliable choice, and required if other control types must also report.) Ref: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjwindow/BBjWindow_getReportAllMouseEvents.htm
3. Register a single `ON_MOUSE_DOWN` callback on the **window**, not the images.
4. In the callback, `BBjMouseDownEvent.getOriginalControl()` returns the actual `BBjControl` that was clicked — this is how you tell the images apart. (`event!.getControl()` is different: it returns the window the callback was registered on.) Ref: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjMouseDownEvent/bbjmousedownevent.htm

To identify *which* image was clicked, tag each `BBjImageCtrl` with `setUserData()` at creation time (an ID string, an index, or a whole data object), then read it back with `getOriginalControl().getUserData()`. This avoids keeping a parallel map of control IDs.

Full pattern — a scrolling thumbnail strip where one callback handles every image (as used for a mobile card view: child window under a hero image, filled with thumbnails, CSS arranging them in a single scrolling row — the CSS part is browser-specific, see **bbj-web-programming**):
```bbj
class public ThumbnailStrip
    field private BBjSysGui sysGui!
    field private BBjChildWindow winImagePanel!

    method private void build(BBjWindow parentWin!, BBjVector images!, BBjVector itemIds!)
        REM 1. Child window hosts the images — fresh context every time (ERROR 17 otherwise)
        #winImagePanel! = parentWin!.addChildWindow("", $00108800$, #sysGui!.getAvailableContext())

        REM 2. Forward mouse events from all contained controls to the window
        #winImagePanel!.setReportAllMouseEvents(1)

        REM 3. ONE callback on the window covers every image in it
        #winImagePanel!.setCallback(BBjWindow.ON_MOUSE_DOWN, #this!, "onImageClick")

        REM 4. Add the images, tagging each control with the data the handler needs
        if (images!.size() > 0) then
            for i = 0 to images!.size() - 1
                img! = #winImagePanel!.addImageCtrl(images!.get(i))
                img!.setUserData(itemIds!.get(i))
            next
        endif
    methodend

    method public void onImageClick(BBjMouseDownEvent event!)
        REM getOriginalControl() = the control actually clicked;
        REM getControl() would return #winImagePanel! (where the callback is registered)
        ctrl! = event!.getOriginalControl()

        REM Clicks on the window background have no user data — ignore them
        itemId! = ctrl!.getUserData()
        if (itemId! = null()) then methodret

        REM ... open the detail view for itemId! ...
    methodend
classend
```
Notes:
- `event!.getX()` / `getY()` give the click position relative to the window — useful for hit-testing if you'd rather not tag controls.
- The same pattern works for `ON_MOUSE_UP`, `ON_MOUSE_MOVE`, and `ON_DOUBLE_CLICK` — all deliver `BBjMouseEvent` subclasses that carry `getOriginalControl()`.
- If different windows share the handler, guard by comparing `ctrl!.getID()` or checking the user-data type before acting.
