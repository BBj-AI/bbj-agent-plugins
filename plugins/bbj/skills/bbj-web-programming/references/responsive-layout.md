# Laying out a responsive DWC app

How to decide the layout of a DWC screen and express it in CSS. Assumes the DOM stack, the
Automatic Layout flag `$00100000$` and the flag composites from the main skill — this file is about
what to *do* with them.

The premise: with Automatic Layout on every window and child window, BBj emits no coordinates and no
sizes, so the stylesheet is the only thing deciding where anything goes. Any layout logic left in
BBj is either dead or fighting the CSS.

---

## Grid or flex — the decision rule

| Reach for | When |
|---|---|
| **Grid** | Two-dimensional structure: named regions (header / nav / content / actions / status), a form's label and field columns, a dashboard, a set of equal cards |
| **Flex** | A one-dimensional run of interchangeable, same-kind items whose count and order are not fixed: toolbars, button groups, tags, chips |

Combining them is normal: grid for the page shell, flex inside each region.

### Both are responsive on their own — media queries are for a *different* layout

Neither mechanism needs a breakpoint to adapt. Reach for the intrinsic tools first:

```css
/* flex: items drop to a new line at whatever width they stop fitting */
.toolbar { display: flex; flex-wrap: wrap; gap: 8px; }

/* grid: as many columns as fit, each at least 320px, sharing the leftover space */
.card-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px; }

/* grid: fluid named regions -- the sidebar has a floor and a ceiling, content takes the rest */
.shell { display: grid; grid-template-columns: clamp(180px, 20vw, 260px) minmax(0, 1fr); }
```
`auto-fit` / `auto-fill` with `minmax()`, `fr` units, and `min()` / `max()` / `clamp()` cover most of
what "responsive" means, at every width rather than at the three or four widths a breakpoint list
happens to name.

Add an `@media` rule when you want a **genuinely different layout**, not merely a resized one —
when continuing to shrink the current arrangement produces something unusable:

- a sidebar beside the content becoming a strip above it (the browser cannot infer that reordering)
- `grid-template-areas` re-assigned so regions stack in a different order
- a two-column label/value pair stacking to label-above-value
- a button column becoming a button row, or buttons going full-width for thumbs

The test: *would this still be usable if it just got narrower?* If yes, let `auto-fit`/`flex-wrap`
handle it. If no, spend a breakpoint. Under Automatic Layout every one of these is a stylesheet
change only — no BBj code moves either way.

---

## Declare the grid on the parent, not the children

The container that holds the child windows owns `display: grid`. Each child window's own class
carries **only** its `grid-area` — no width, no height, no position. This is what lets one
`@media` rule re-arrange the whole page without touching any child rule.

For a **top-level window** the controls' parent is the auto-created `dwc-window-content`, so the
grid goes on a `>` child selector. For a **child window** it goes directly on the class (there is no
`dwc-window-content` inside a `dwc-panel`):

```css
/* page shell — grid on the top-level window's content box */
dwc-window-center.app > dwc-window-content {
    display: grid;
    grid-template-columns: 216px minmax(0, 1fr);
    grid-template-rows: auto minmax(0, 1fr) auto auto;
    grid-template-areas:
        "header  header"
        "nav     content"
        "actions actions"
        "status  status";
    gap: 12px;
    height: 100%;
    padding: 20px;
    box-sizing: border-box;
    overflow: hidden;
}

/* each child window's class does one job */
.app-header   { grid-area: header;  }
.nav-rail     { grid-area: nav;     }
.content-area { grid-area: content; }
.action-bar   { grid-area: actions; }
.status-bar   { grid-area: status;  }

/* one rule collapses the whole page */
@media (max-width: 1100px) {
    dwc-window-center.app > dwc-window-content {
        grid-template-columns: minmax(0, 1fr);
        grid-template-rows: auto auto minmax(0, 1fr) auto auto;
        grid-template-areas: "header" "nav" "content" "actions" "status";
    }
}
```

**Use `minmax(0, 1fr)`, not `1fr`, for any track holding a scrollable control.** A bare `1fr` track
has `min-width: auto`, so a wide grid or a long unbroken string pushes the track past the viewport
and the whole page scrolls sideways. `minmax(0, 1fr)` lets the track shrink and the control scroll
inside itself.

---

## Let CSS switch views, not `setVisible()`

When one region shows one of several panels, create them all as sibling child windows, give them a
shared class plus a state class, and toggle the state class from BBj. The CSS decides what visible
means; BBj never touches geometry.

```bbj
#panelWindow!.addClass("category-panel")            REM at build time
REM ...on navigation:
outgoing!.removeClass("category-panel--active")
incoming!.addClass("category-panel--active")
```
```css
.category-panel           { display: none; }
.category-panel--active   { display: grid; gap: 20px; align-content: start; }
```

The same trick scales up to whole-application state. One class on the top-level window can re-shape
the page, because `addClass()` lands on `dwc-window-center`, which is an ancestor of everything:

```bbj
#mainWindow!.addClass("is-disconnected")     REM or removeClass() when connected
```
```css
.app.is-disconnected > dwc-window-content {
    grid-template-columns: minmax(0, 1fr);
    grid-template-areas: "header" "content" "status";
}
.app.is-disconnected .nav-rail,
.app.is-disconnected .action-bar { display: none; }
.app:not(.is-disconnected) .welcome-panel { display: none; }
```
Hiding a grid item with `display: none` removes it from the grid entirely, so no empty track is left
behind — which is why the areas can simply be re-declared without it.

---

## Recipes

**Push a button group to the trailing edge of a flex bar** without a spacer control:
```css
.action-bar     { display: flex; flex-wrap: wrap; align-items: end; gap: 12px; }
.action-buttons { display: flex; flex-wrap: wrap; gap: 8px; margin-inline-start: auto; }
```
`margin-inline-start: auto` eats the free space, and stops doing so by itself once the bar wraps.
It is also writing-mode aware, unlike `margin-left`.

**Pair labels with values without wrapper windows.** Add the label and the value as *siblings* of
the same parent and let a two-column grid pair them up; on a phone, one column stacks each label
above its value with no change to the BBj side:
```css
.info-card  { display: grid; grid-template-columns: minmax(10ch, 20ch) minmax(0, 1fr);
              align-items: baseline; gap: 6px 12px; }
.info-label { text-align: right; }

@media (max-width: 640px) {
    .info-card  { grid-template-columns: minmax(0, 1fr); gap: 0; }
    .info-label { text-align: left; margin-top: 8px; }
}
```
For *form* controls prefer the `label` attribute instead (see the main skill) — this pattern is for
read-only label/value pairs, where there is no control to attach a label to.

**A list or grid with a button column that becomes a button row:**
```css
.list-card     { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 12px; }
.panel-actions { display: flex; flex-direction: column; flex-wrap: wrap; gap: 8px; }

@media (max-width: 1100px) {
    .list-card     { grid-template-columns: minmax(0, 1fr); }
    .panel-actions { flex-direction: row; }
}
```

**Touch targets.** Give every interactive control a `min-height` from a token (`44px` on phones,
`40px` above that) rather than letting the DWC defaults shrink. Then widen rather than shrink at the
narrow breakpoint — `flex: 1 1 140px` turns a row of buttons into full-width stacked ones:
```css
:root { --touch-target: 40px; }
@media (max-width: 640px) { :root { --touch-target: 44px; } }
.nav-button, .panel-button, .action-button { min-height: var(--touch-target); }
@media (max-width: 640px) {
    .nav-button, .panel-button, .action-button { flex: 1 1 140px; min-width: 0; }
}
```

**Wide content scrolls inside its own box, never the page.** Grids with many columns, code blocks
and diagrams get `overflow-x: auto` on the control itself; the shell keeps `overflow: hidden`.

**Reserve room for the focus ring.** Every `overflow: hidden` / `overflow: auto` box you add above
is a place the keyboard focus outline gets clipped, because an outline is painted outside the border
box and reserves no layout space. Pair a scrolling shell with the padding rule from the main skill's
"Reserve room for the keyboard focus ring" — it is cheap and it is the difference between a keyboard
user seeing where they are and not.

---

## Load the stylesheet from beside the program

`pgm(-2)` returns the path of the currently running program, so a program can find its own companion
`.css` without a configured prefix or an absolute path — the app stays copyable to any directory:

```bbj
cssPath! = new File(pgm(-2)).getParent() + "/MyApp.css"
cssText! = null()
cssText! = Files.readString(Path.of(cssPath!), err=*next)
if (cssText! <> null()) then #webManager!.injectStyle(str(cssText!), 0, "id=myapp-css")
```
`Files.readString()` avoids the `new String(byte[])` overload resolution that trips the type checker
on an undeclared byte array. Guard the whole thing on `#webManager! <> null()` so the program still
runs (unstyled) under a non-browser client.

---

## Two things to check in the browser

- **`display: grid` on a fieldset child window** (`$00109000$`, the groupbox replacement) renders as
  a real `<fieldset>` with a `<legend>`. Current Chrome/Firefox/Safari keep the rendered legend out
  of the grid formatting context, but this was historically buggy — confirm the legend is not being
  treated as a grid item before relying on it.
- **Design tokens with fallbacks.** Prefer `var(--dwc-space-m, 12px)` over a bare `--dwc-*`
  reference: if a token name is wrong or absent in the running theme, the declaration is dropped
  entirely and the layout silently loses its gaps. The fallback keeps it standing.