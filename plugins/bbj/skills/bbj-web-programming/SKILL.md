---
name: "bbj-web-programming"
description: "Write, debug, or review browser-facing BBj code for DWC (Dynamic Web Client) or BUI applications — anything where a BBj program renders in a browser and touches HTML, CSS, or JavaScript. Use this whenever the user works with DWC window/CSS theming, --dwc-* design tokens, light/dark themes, expanse/component theming, setAttribute/getAttribute vs. setProperty/getProperty, client-side or server-side form validation (ClientValidation, BBjFormValidationEvent), the dwc-frame/dwc-window-center/dwc-window-content/dwc-panel DOM structure, setStyle/setOuterStyle/addOuterStyle, Automatic Layout ($00100000$) and making a DWC app responsive with CSS Grid/Flexbox and media queries, window creation flags (modal/Dialog, Invisible, Maximized), converting a legacy fixed-coordinate or .arc-resource GUI app to DWC, injecting CSS/JS/fonts into a BBj app, BBjWebManager, BBjWebComponent, Shoelace or other web components, dwc-icon/icon buttons, BBjColorChooser, or HTML text inside BBj controls. Also trigger on symptoms without BBj being named: a DWC window's CSS not applying or only half-applying, a window or dialog appearing off-centre / clipped / with its top or left cut off, controls truncated or overlapping, a window that won't fill the viewport, Shoelace components not loading or icons missing, HTML showing as literal text in a control, HTML entities getting garbled in output, a form control not validating as expected, or a submit button not unlocking the window. Always use this together with the bbj-programming skill, which covers general language syntax and gotchas."
---

<!-- bbj-check-order:begin -->
**Check BBj code before you hand it back.** Use the first route that exists:

1. `bbjcpl -t -N -X <file>`, when BBj is installed on this machine. It checks syntax and types. `-N` writes no output files; the errors arrive on stderr.
2. `bbj_check_syntax` of the `bbj-local` server (the `bbj-ls` of a running BBjServices, BBj 26.03 or later), when that server is registered. It runs on this machine, against the installation's own PREFIX, classpath and config. It checks syntax only, not types.
3. Only when neither exists: `bbj_check_syntax` of the `bbj-docs` server, the hosted check. You may use it without asking, but tell the user that the code was sent to the server and checked against a stock BBj, not against their installation.

A hook checks the BBj files you write or edit. This order is for code you hand back without writing it to a file: answers, and code from earlier turns.
<!-- bbj-check-order:end -->

# BBj Web Programming (DWC / BUI)

BBj DWC (Dynamic Web Client) apps are **not** HTML pages — they are ordinary BBj programs whose UI renders in a browser via the DWC runtime. All widgets are created with BBj calls (`addButton`, `addStaticText`, etc.); HTML/CSS only enters the picture through deliberate injection points (see below) and through wrapping third-party web components (Shoelace, custom elements) via `BBjWebComponent`.

This skill covers everything browser-specific. For general BBj language syntax, gotchas, class boilerplate, Java interop, and database access, use the **bbj-programming** skill — always load both when writing DWC/BUI code.

Acquire the web manager once (typically in the constructor): `#webManager! = BBjAPI().getWebManager()`.

---

## HTML text in controls — two silent traps

**HTML content in a control must start with `<html>`** or it renders as literal text:
```bbj
myWindow.addStaticText("<html><h3>Title</h3></html>")
```

**`&` must be doubled (`&&`) inside BBj strings**, or the HTML entity gets silently dropped/garbled:
```bbj
html! = "Price &&mdash; $199"   ;REM renders: Price — $199   (correct)
html! = "Price &mdash; $199"    ;REM broken output
```

---

## Form control labels — use the label attribute in DWC, not a separate static text

In DWC, give a form control its label via the `label` attribute instead of adding a separate `BBjStaticText`:
```bbj
firstName! = win!.addEditBox("")
firstName!.setAttribute("label", "First Name")
```
This is preferred in DWC for three reasons: it's more efficient (one control instead of two), it behaves better in responsive layouts (the label moves and wraps with its control), and screen readers can associate the label with the control — they can't make that association with a separate static text control.

**Corollary: never manage the label's own placement or sizing — and never add a container just to hold it.** The control renders its `label` inside its own shadow DOM, so there is no separate label element to align, size, or keep next to the control. A wrapper `BBjChildWindow` "so the label and control travel together" is grouping one element with nothing, and every layout rule written for the pair is inert:
```bbj
REM Pointless — the group has exactly one child, so gap/flex-direction have nothing to act on
REM (and each wrapper costs a SysGui context, a server-side window, and a DOM node).
grp! = panel!.addChildWindow("", $00108800$, #sysGui!.getAvailableContext())
grp!.addClass("field-group")                REM .field-group { display:flex; gap:0.5em; ... }
txt! = grp!.addEditBox("")
txt!.setAttribute("label", "First Name")

REM Correct — the control is a direct flex/grid item of the panel and labels itself
txt! = panel!.addEditBox("")
txt!.setAttribute("label", "First Name")
```
This is a habit carried over from the two-element era (and from BUI, where the pair is real) — it survives code review easily because the wrapper looks like conscientious layout work. Reach for a wrapper only when a row genuinely holds two or more controls, such as an EditBox plus a Browse button. To restyle or reposition a label in the rare outlier case, target the control's own shadow part — `::part(label)` — rather than building an external container:
```css
.my-field::part(label) { font-weight: 600; }
```

**BUI does not support this** — a separate `BBjStaticText` label is still valid and required there. The attribute pattern is DWC-only.

**Known exception: `BBjColorChooser` does not support the `label` attribute** — setting it silently has no effect. Caption it with a sibling `BBjStaticText` instead (see **[references/color-chooser.md](references/color-chooser.md)**).

---

## Attributes and properties — setAttribute/getAttribute vs. setProperty/getProperty

DWC only. In the DWC client, BBj controls render as web components, and each one exposes customization through two channels on top of `BBjControl`: an **attribute** (the HTML-side knob) and a **property** (the JavaScript-side knob). `setAttribute`/`getAttribute`/`setProperty`/`getProperty` exist on `BBjControl` across all clients, but GUI, BUI, and WebUI have no concept of attribute/property customization — the calls are no-ops there. Only rely on these channels when the target is DWC, or guard the call with a client check.

| | Attribute | Property |
|---|---|---|
| Layer | HTML attribute on the underlying web component | JS property on the underlying web component |
| Value type | Always a string | Typed (string, number, boolean, object, array) |
| Visible in DOM | Yes, under its own name (e.g. `theme="danger"`) | Only if marked `Reflects: Yes` in the control's docs |
| Best for | Simple string/boolean values matching the documented attribute form | Structured data, large values, anything not a plain string |
| BBj API | `setAttribute` / `getAttribute` | `setProperty` / `getProperty` |

```bbj
button! = window!.addButton(1,10,10,130,30,"Button",$$)
button!.setAttribute("theme","danger")
button!.setAttribute("expanse","l")
themeName$ = button!.getAttribute("theme")

REM Same value via the property channel:
button!.setProperty("theme", "danger")
themeName$ = button!.getProperty("theme")
```

**Reflection** keeps the property and attribute in sync, and it's documented per-property in each control's Properties table:
- `Reflects: Yes` — either channel reads/writes the same live value, and the value shows up on the DOM (useful for CSS state selectors like `dwc-button[theme="danger"]`). Example: `theme`, `disabled`, `expanse` on `BBjButton`.
- `Reflects: No` — the attribute is only an initial hint; changing the property does not update the attribute, and changing the attribute after construction may do nothing. Use `setProperty`/`getProperty` for the live value. Example: `autofocus`, `label` on `BBjButton`.

**Choosing the right channel, in order:**
1. A dedicated BBj API method if one exists (`setEnabled`, `setText`, `addItem`, etc.) — these are the documented, supported entry points and may coordinate several internal attributes/properties at once, validate, or trigger control-specific behavior. A direct `setAttribute` with the same value is not guaranteed to produce the same outcome.
2. `setAttribute` for a customization documented under the control's Properties section with no dedicated BBj method, where the value is a plain string or boolean.
3. `setProperty` as a last resort — for properties documented `Reflects: No` (where `getAttribute` would return a stale initial value) or whose value isn't a string.

The same priority order applies to reading: dedicated getter first, then `getAttribute` for reflected properties, then `getProperty` for live state of non-reflected ones.

---

## DWC window/DOM structure

A `BBjTopLevelWindow` is **four** elements deep, not one. `addClass()` lands in the middle of that stack, which is the single most common cause of "my window CSS does nothing / half-applies". `BBjChildWindow` renders as `<dwc-panel>` with **no** `dwc-window-content` wrapper — its controls are direct children.

```
<dwc-frame class="app-frame">                 the window's POSITION/SIZE box — addOuterStyle() ONLY
  <dwc-window-container>
    <dwc-window-center class="app">           BBjTopLevelWindow — what addClass() targets
      <dwc-window-content>                    the CONTROLS' parent; content layout goes here
        <dwc-panel class="nav">               BBjChildWindow — no dwc-window-content inside
          ...direct children...
        </dwc-panel>
      </dwc-window-content>
    </dwc-window-center>
  </dwc-window-container>
</dwc-frame>
```

Which element gets which job:

| Want to style | Target | Reach it with |
|---|---|---|
| Window **position / size** | `dwc-frame` | `addOuterStyle("cls")` |
| Window chrome / background | `dwc-window-center` | `addClass("cls")` |
| **Layout of the controls** (grid/flex) | `> dwc-window-content` | `addClass()` on the window, then a `>` child selector |
| A child window's own layout | `.cls` directly | `addClass("cls")` |

```css
/* top-level window: content layout goes on > dwc-window-content, NOT on dwc-window-center */
dwc-window-center.app > dwc-window-content { display: grid; grid-template-rows: 64px 1fr; }

/* child window: layout goes directly on the class, no > dwc-window-content */
.nav { display: flex; align-items: center; gap: 20px; }
```
When querying the DOM from injected JS, match `dwc-panel.my-class` for child windows, not `dwc-window` — the latter returns `null`.

### Positioning/sizing a top-level window (three things to get right)

**1. `dwc-frame` is only reachable via `addOuterStyle()`.** `addClass()` puts the class on `dwc-window-center`, which is *inside* the frame — position it there and offsets resolve against `dwc-window-container` instead of the viewport, clipping the window against its own parent. The whole family is `addOuterStyle` / `removeOuterStyle` / `clearOuterStyles` / `getOuterStyle(s)` / `getComputedOuterStyle` (BBj 22+), all on `BBjTopLevelWindow`:
```bbj
win!.addClass("login")             REM -> dwc-window-center  (content styling)
win!.addOuterStyle("login-frame")  REM -> dwc-frame          (placement/sizing)
```

**2. `dwc-frame` sits in NORMAL FLOW — it is not absolutely positioned.** So `top`/`left` are silent no-ops on it, but `transform` *does* apply. The reflex centering idiom therefore **half-applies**: the offsets are ignored while the translate drags the frame up and left by half its own size, off the top-left of the viewport (symptom: the top and left of the window are cut off). Center a flow-level block with `margin` instead:
```css
dwc-frame.login-frame {
    margin: 8vh auto !important;          /* auto = horizontal centering; vh = vertical offset */
    width: min(560px, 94vw) !important;
    height: auto !important;
    max-height: 84vh !important;          /* 8vh top + 8vh bottom leaves 84vh */
}
```
Use `vh` for the vertical margin, never `%` — a percentage vertical margin resolves against the containing block's **width**, so `margin: 25% auto` grows the top gap as the browser widens.

**3. BBj writes `width`/`height` on `dwc-frame` as INLINE styles**, and inline styles beat stylesheet rules at any specificity — hence the `!important` above. It is required here, not laziness.

**Corollary — never compute window layout in BBj.** See the Automatic Layout section below: an auto-layout window has no absolute geometry, so `getX()/getY()/getWidth()/getHeight()` return null. Anything that centers or sizes a window by reading those (e.g. `BBWindowUtils.centerWindow()`) throws `!ERROR=252` (NullPointerException) against an auto-layout window. Placement is CSS's job.

**`setStyle()` vs `setOuterStyle()`:** `setStyle()` sets inline styles on a widget's inner element. `setOuterStyle()` reaches the outer `<dwc-*>` wrapper, but is **only valid on `BBjTopLevelWindow`/`BBjChildWindow`** — calling it on a `BBjButton` or other control is a syntax error; use `setStyle()` there instead. Note the naming asymmetry: `setOuterStyle(prop, value)` sets an inline *style property*, while `addOuterStyle(cssClassName)` adds a *CSS class* — different jobs, similar names.

**Entrance/exit animation pattern:**
```bbj
win!.setOuterStyle("opacity", "0")
win!.setOuterStyle("transform", "translate(0, 20px)")
win!.setOuterStyle("transition", "all 400ms ease-out")
win!.setVisible(1)
wait 0.05   REM let the browser render the initial state before the transition fires
win!.setOuterStyle("opacity", "1")
win!.setOuterStyle("transform", "translate(0, 0)")
```

**Not every control's content is reachable from a page stylesheet.** A `BBjStaticText`'s HTML is ordinary light DOM and styles normally, but a `BBjListBox`'s item HTML renders inside the control's **shadow root**, where no page-level selector reaches it — not a class, not a tag, not an attribute selector, at either injection position. Inline `style=` attributes always work; `::part()`, a `<style>` inside the item markup, and `adoptedStyleSheets` from JS are the three ways in. See **[references/shadow-dom-styling.md](references/shadow-dom-styling.md)** before concluding that an injection failed.

**Styling `BBjImageCtrl`:** it renders as `<dwc-image><img src="..."></dwc-image>`. Style the wrapper via `addClass()`, and target the inner `<img>` in CSS (e.g. `.my-image-class img { object-fit: cover; }`) to make it fill its container.

---

## Automatic Layout — the basis of a responsive DWC app

Flag **`$00100000$`** on a window or child window. In DWC it makes the container use dynamic flow layout, **ignoring all absolute control sizes and positions** so CSS owns the layout. This is the flag that makes a DWC app responsive; without it the container keeps fixed pixel coordinates and sizes instead of adapting to the viewport.

Set it at creation — there is no setter:
```bbj
REM Top-level window. Pass a FRESH getAvailableContext() per window (see bbj-programming/references/sysgui.md)
win! = sysGui!.addWindow(sysGui!.getAvailableContext(), "My App", $00101093$)
win!.addClass("app")                REM -> dwc-window-center
win!.addOuterStyle("app-frame")     REM -> dwc-frame

REM Child windows as layout containers. $00108800$ = AutoLayout + Simple + Borderless
panel! = win!.addChildWindow("", $00108800$, sysGui!.getAvailableContext())
panel!.addClass("sidebar")
```

Useful composites (decode the bits before reusing — a wrong digit changes the flags silently):

| Flags | Bits | Use |
|---|---|---|
| `$00101093$` | AutoLayout + Maximized + Invisible + Maximizable + Close box + Resizable | main app window, fills viewport |
| `$00180013$` | AutoLayout + **Dialog(modal)** + Invisible + Close box + Resizable | modal dialog window |
| `$00108800$` | AutoLayout + Simple + Borderless | plain flex/grid container child window |
| `$00109000$` | AutoLayout + Simple + Fieldset | bordered/titled group child window (groupbox replacement) |

**Use the coordinate-less `add*()` overloads.** Nearly every control has them — `addButton("text")`, `addEditBox("")`, `addStaticText("x")`, `addTree()`, `addGrid()`, `addListButton("")`, `addCEdit("", $0102$)`, `addToolButton("x")`, `addChildWindow(title, flags, context)`. Passing x/y/w/h under Automatic Layout is pointless: the values are ignored.

**Auto-layout windows have NO absolute geometry.** `getX()`, `getY()`, `getWidth()`, `getHeight()` return null, so anything that reads them to compute placement throws `!ERROR=252` (NullPointerException). Do sizing and placement in CSS — that is the point of the flag. If you genuinely need measurements client-side, go through the web manager's computed-style APIs rather than the SysGui geometry getters.

**ARC equivalent:** the flag is exposed in WindowBuilder's UI as **`GRAVITY`** — add a line with the keyword `GRAVITY` in a child window's properties section of the `.arc` source to enable DWC flow layout for a resource-defined window.

---

## Injecting CSS / JS / fonts — two patterns, pick correctly

Reading a CSS/JS file into a string for injection (`p_source$` is the path to the file):
```bbj
use java.nio.file.Files
use java.nio.file.Path

fileContents! = Files.readAllBytes(Path.of(p_source$), err=ERR_READ_ERROR)
contentsString! = cast(BBjString, new String(fileContents!))
```

**Pattern 1 — inline injection**, for self-contained files with no internal `import`/relative-asset references. Read the file as above, then inject the string:
```bbj
REM CSS (0 = end of <body>, wins same-specificity cascade ties):
webManager!.injectStyle(contentsString!, 0, "id=theme-css")

REM JS:
webManager!.injectScript(contentsString!, 1, "id=my-helper-js")
```

**Pattern 2 — URL-served (htdocs)**, required for fonts referenced via `@font-face`, and any JS module doing dynamic `import()` of relative chunk files (e.g. Shoelace's ES module bundle):

BBj's Jetty server serves `<BBjHome>/htdocs/` at the relative path `/files/`. Always reference `/files/...` (never a hardcoded `http://localhost:PORT/files/...`) so the app still works when accessed from another hostname on the network:
```bbj
webManager!.injectScriptUrl("/files/lib/shoelace/shoelace.js", 1, "type=module,id=shoelace-js")
webManager!.injectStyle("@font-face { font-family: 'MyFont'; src: url('/files/fonts/MyFont-700.woff2') format('woff2'); font-weight: 700; }", 0, "id=my-fonts")
```
If you inject a CSS var block repeatedly (e.g. from a small helper method that pushes a single CSS variable), give the injection a stable name/id tag (`"name=app-vars"`) so it replaces rather than accumulates duplicate `:root {}` blocks.

Google Fonts fallback if not self-hosting:
```bbj
webManager!.injectLinkUrl("https://fonts.googleapis.com", 0, "rel=preconnect")
webManager!.injectLinkUrl("https://fonts.gstatic.com", 0, "rel=preconnect,crossorigin")
webManager!.injectLinkUrl("https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap", 0, "rel=preload,as=style,onload=this.onload=null;this.rel='stylesheet'")
```

---

## CSS conventions

### Naming pattern
BBj control → `addClass()` → CSS class in the app's external CSS file:
```bbj
btn! = win!.addButton("Browse")
btn!.addClass("btn-cta")
```
```css
.btn-cta { ... }
```

### CSS custom properties (design tokens)
Define all colors, spacing, typography as CSS vars in `:root` so theme switching works by changing a small set of values. Fall back to the DWC tokens so unstyled cases still match the theme:
```css
:root {
  /* Typography */
  --app-font-display:      'Playfair Display', var(--dwc-font-family-sans);
  --app-font-body:         'Inter', var(--dwc-font-family);
  --app-font-serif:        'PT Serif', var(--dwc-font-family-serif);
  --app-font-mono:         'Roboto Mono', var(--dwc-font-family-mono);
}
```

### Card grid layout
```css
.my-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(420px, 1fr));
  gap: 24px;
  padding: 24px;
}
```

### Reserve room for the keyboard focus ring

DWC marks the keyboard-focused control with an **outline drawn outside its border box** —
`outline: var(--dwc-focus-ring-width) solid …` with `outline-offset: var(--dwc-focus-ring-gap)`
(both default to `2px`). An outline takes part in no layout calculation, so nothing reserves that
space for it. Tab through a tightly-packed form and the ring is clipped on whichever sides have no
room — most visibly inside any ancestor with `overflow: hidden` or `overflow: auto`, and in grid or
flex containers with a small `gap`.

Give the form controls padding worth the full reach of the ring:
```css
dwc-field, dwc-choicebox, dwc-radio, dwc-textfield {
    padding: calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap));
}
```
This is an accessibility bug, not a cosmetic one — a keyboard user navigating by focus loses the
only indication of where they are. Add the rule to any app that ships its own CSS.

The rest of the family: `--dwc-focus-ring-a` (alpha), and per-theme ring colors
`--dwc-focus-ring-primary` / `-success` / `-warning` / `-danger` / `-info` / `-gray` / `-default`.

---

## Web components (BBjWebComponent)

`BBjWebComponent` extends `BBjControl`, so `addClass()`, `setStyle()`, `setAttribute()`, `setCallback()` all work normally on it. This is the general mechanism for embedding any custom element / third-party web component library (Shoelace, or anything else that ships as custom elements) inside a BBj DWC app:
```bbj
el! = cast(BBjWebComponent, parentWindow!.addWebComponent("some-tag"))
el!.setAttribute("variant", "primary")   REM most props are read as HTML attributes
el!.setStyle("margin-top", "8px")        REM setStyle wins over class rules inside shadow DOM
child! = cast(BBjWebComponent, parentWindow!.addWebComponent("child-tag"))
el!.setSlot(child!)                      REM appends to default slot
el!.setSlot(child!, "footer")            REM appends to slot="footer"
```
Listening to custom DOM events the component emits:
```bbj
eventOptions! = el!.newEventOptions()
eventOptions!.addItem("value", "event.target.value")
el!.setCallback("some-custom-event", #this!, "onSomeEvent", eventOptions!)
method public void onSomeEvent(BBjWebEvent event!)
    val! = str(event!.getEventMap().get("value"))
methodend
```
Components that use shadow DOM can only be styled via `::part()` selectors or CSS custom properties — regular descendant selectors from the page's CSS won't reach inside.

**Adding icons to BBjButtons via a native `dwc-icon` web component.** A `BBjWebComponent` can supply a button's icon instead of building the icon into the button's text as HTML. Add a `dwc-icon` component, then move it into the button's `prefix` slot:
```bbj
copyIcon! = window!.addWebComponent("dwc-icon")
copyIcon!.setAttribute("name", "copy")

copyButton! = window!.addButton("Copy")
copyButton!.setSlot("prefix", copyIcon!)
```
`setAttribute("name", ...)` selects the icon from BBj's built-in icon pool (`"copy"` here). `setSlot()` moves a child control into a named slot on the parent — `"prefix"` places the icon before the button's "Copy" label; other controls likely expose a `"suffix"` slot for trailing placement. This avoids hand-writing `<html>` markup for the button text just to embed an icon. Docs — [setAttribute()](https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/BBjControl_setAttribute.htm) · [setSlot()](https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/BBjControl_setSlot.htm)

---

## Optional libraries worth reaching for

- **GSAP** (`gsap.min.js`) — hero animations, parallax, scroll triggers. Self-contained UMD bundle, safe to inject inline.
- **Swiper.js** (`swiper-bundle.min.js` + `.css`) — image carousels. Self-contained, safe to inject inline.
- **Tabler Icons** — prefer inline SVG over a hosted icon font/sprite for reliability (no network dependency, no base-path config needed). Inline SVG also drops straight into a control's HTML text, e.g. `btn!.setText("<html><svg ...>...</svg></html>")`.

---

## Utility helper pattern

Most BBj DWC projects benefit from a small static `Utils` class centralizing the boilerplate used everywhere: file-to-string reading (the `Files.readAllBytes` pattern above), a CSS-file injector for startup, a `setCssProperty()` helper for pushing a single CSS var, `getCookies()`/`setCookies()` for small persisted state, and `consoleLog()`/`consoleError()` for browser-console debugging from BBj. Building this once and reusing it across projects avoids re-solving file I/O and injection boilerplate each time.

---

## Deeper references (load on demand)

The material below is off-loaded to keep this file focused on always-relevant DWC/BUI concerns. Read the referenced file when the task hits its topic:

- **[references/shadow-dom-styling.md](references/shadow-dom-styling.md)** — Why page CSS does not reach inside some controls, and the three ways in: `::part()`, a `<style>` element inside the control's own HTML content, and handing a stylesheet to `el.shadowRoot` from JS (`adoptedStyleSheets`) — plus which to pick, since they differ in LIFETIME not capability. Covers the probe technique for telling shadow DOM apart from attribute-stripping apart from a failed injection; which controls are light DOM (BBjStaticText, slotted children) versus shadow DOM (BBjListBox items); why custom properties cross the boundary when no selector can; and the recurring traps — a list sizing every item to the widest one, `text-overflow` doing nothing on an inline span, flex items refusing to shrink without `min-width:0`, CSS `url('...')` breaking a JS string in `executeAsyncScript`, and focus rings clipped for want of padding. **Read this the moment any CSS "does nothing" on a DWC control, before assuming the injection failed.**

- **[references/responsive-layout.md](references/responsive-layout.md)** — Deciding and writing the layout of a DWC screen: the grid-vs-flex rule, why both are already responsive without any media query (`auto-fit`/`minmax()`/`clamp()` for grid, `flex-wrap` for flex) and what breakpoints are actually for, declaring the grid on the parent while each child window's class carries only `grid-area`, the `minmax(0, 1fr)` requirement for tracks holding scrollable controls, switching views and whole-app state with a CSS class instead of `setVisible()`, recipes for trailing button groups / label-value pairs / button columns that become rows / touch targets, and loading a companion stylesheet via `pgm(-2)`. Read this when starting a DWC screen or making an existing one responsive.

- **[references/running-dwc-apps.md](references/running-dwc-apps.md)** — Actually getting a DWC app into a browser: why `bbj -q myapp.bbj` runs the ThinClient and hides every DWC problem, registering the program as an EM application through `BBjAdminFactory` → `getRemoteConfiguration()` → `createApplication()` → `commit()`, the application property constants, the `"--"` config-file sentinel trap, the `/webapp/<name>` (DWC) vs `/apps/<name>` (BUI) URLs on port 8888, and a reusable headless registration helper. Read this before trying to run or test any DWC/BUI app.

- **[references/themes.md](references/themes.md)** — The `--dwc-*` design token system (color suffix roles, seed overrides, `::part()`, spacing/sizing tokens), light/dark/custom themes (`setTheme`/`setDarkTheme`/`setLightTheme`/`"system"`, the `--dwc-dark-mode`/`color-scheme` requirement for custom dark themes), component-level `theme`/`expanse` attributes, reduced motion, and the light/dark toggle pattern. Read this on any CSS/theming task, or before building a theme switcher or custom brand theme.

- **[references/form-validation.md](references/form-validation.md)** — Server-side validation via `BBjFormValidationEvent`/`accept()`, and DWC client-side validation (`ClientValidation`, BBj 22.10+): built-in per-control validation attributes, `setClientValidationFunction()` JS expressions with the value/text parameter tables, validation-customization attributes (style, placement, message), and the `BBjControlValidation` plugin. Read this whenever a form needs required fields, patterns, length/range limits, or custom validation logic.

- **[references/shoelace.md](references/shoelace.md)** — Loading web-component JS/CSS with a local-first/CDN-fallback pattern (why Shoelace's JS bundle must load via URL, not inline injection), plus full Shoelace integration: creating/nesting `sl-*` components, slots, events, the component reference table, and mapping `--sl-*` tokens to `--dwc-*` tokens. Read this before wiring up Shoelace or diagnosing "components not loading"/"icons missing" symptoms.

- **[references/color-chooser.md](references/color-chooser.md)** — `BBjColorChooser` full HSL picker setup, the `label` attribute exception, and the `getClientProperty()` 0–1.0 fraction gotcha for saturation/lightness. Read this whenever a color picker feeds theme tokens.
