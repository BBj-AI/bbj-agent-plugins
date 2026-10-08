# Loading web components (local-first, CDN fallback) & Shoelace integration

## Loading web components (local-first, CDN fallback)

When loading web component JavaScript and CSS files, the pattern is:
1. Attempt to load locally first — from the project directory, or served by BBj's Jetty server (same machine as BBjServices, works without internet access).
2. Fall back gracefully to a CDN if the local files are not available.

Using Shoelace as the example: its `cdn/shoelace.js` is an ES module that dynamically imports chunk files (`./chunks/...`). Inline injection of its file contents via `injectScript()` breaks those relative imports — it **must** be loaded via a URL (Pattern 2 in `injecting CSS / JS / fonts` in the main skill). The theme CSS has no relative imports, so it's safe to inject inline.

**One-time setup** — copy the Shoelace CDN folder to htdocs so BBj's Jetty server can serve it:
```bash
cp -r lib/shoelace/node_modules/@shoelace-style/shoelace/cdn/ <BBjHome>/htdocs/lib/shoelace/
```
This makes these URLs available:
- `/files/lib/shoelace/shoelace.js`
- `/files/lib/shoelace/assets/icons/` (required by `sl-icon`)
- `/files/lib/shoelace/themes/dark.css` (also loadable by reading the file inline)

**Loading pattern** — project directory first, then Jetty htdocs, then CDN:
```bbj
use java.nio.file.Files
use java.nio.file.Path

REM --- Theme CSS: self-contained, safe to inject inline ---
themeFile!    = "dark.css"
localCssFile! = dsk("") + dir("") + "lib/shoelace/node_modules/@shoelace-style/shoelace/cdn/themes/" + themeFile!
jettyCssFile! = System.getProperty("basis.BBjHome") + "/htdocs/lib/shoelace/themes/" + themeFile!
cdnCssUrl!    = "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.1/cdn/themes/" + themeFile!

localFile! = new java.io.File(localCssFile!)
if (localFile!.exists()) then
    REM Local project file exists — read it in and inject it
    css! = cast(BBjString, new String(Files.readAllBytes(Path.of(localCssFile!))))
    webManager!.injectStyle(css!, 0, "id=shoelace-theme-css")
else
    jettyFile! = new java.io.File(jettyCssFile!)
    if (jettyFile!.exists()) then
        REM Served by Jetty — read the htdocs copy and inject it
        css! = cast(BBjString, new String(Files.readAllBytes(Path.of(jettyCssFile!))))
        webManager!.injectStyle(css!, 0, "id=shoelace-theme-css")

        REM Alternatively, inject via Jetty's URL:
        REM webManager!.injectLinkUrl("/files/lib/shoelace/themes/" + themeFile!, 0, "rel=stylesheet,id=shoelace-theme-css")
    else
        REM No local copy — fall back to the CDN
        webManager!.injectLinkUrl(cdnCssUrl!, 0, "rel=stylesheet,id=shoelace-theme-css")
    endif
endif

REM --- JS bundle: ES module with dynamic chunk imports — MUST be loaded via URL, not inline ---
localJsUrl! = "/files/lib/shoelace/shoelace.js"
cdnJsUrl!   = "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.1/cdn/shoelace.js"

localHtdocsFile! = new java.io.File(System.getProperty("basis.BBjHome") + "/htdocs/lib/shoelace/shoelace.js")
if (localHtdocsFile!.exists()) then
    webManager!.injectScriptUrl(localJsUrl!, 1, "type=module,id=shoelace-js")
    REM Set the Shoelace asset base path so sl-icon can find its SVGs
    webManager!.executeAsyncScript("document.addEventListener('DOMContentLoaded', () => { if(window.SlSetBasePath) window.SlSetBasePath('/files/lib/shoelace/'); });")
else
    webManager!.injectScriptUrl(cdnJsUrl!, 1, "type=module,id=shoelace-js")
endif
```
Pin the CDN fallback URLs to the same version you have installed locally (adjust `2.20.1` to match).

---

## Shoelace integration

### Creating and nesting components

```bbj
card! = cast(BBjWebComponent, parentWindow!.addWebComponent("sl-card"))
card!.addClass("watch-card")
card!.setAttribute("label", "Seiko Presage")

icon! = cast(BBjWebComponent, parentWindow!.addWebComponent("sl-icon"))
icon!.setAttribute("name", "star-fill")
card!.setSlot(icon!)                  REM default slot

badge! = cast(BBjWebComponent, parentWindow!.addWebComponent("sl-badge"))
badge!.setAttribute("variant", "primary")
badge!.setHtml("Automatic")
card!.setSlot(badge!, "footer")       REM named slot: slot="footer"
```
Setting inner HTML directly on a control: `comp!.setText("<html><strong>39.5mm</strong> case</html>")`.

### Events

```bbj
eventOptions! = comp!.newEventOptions()
eventOptions!.addItem("value", "event.target.value")
comp!.setCallback("sl-change", #this!, "onSlChange", eventOptions!)

method public void onSlChange(BBjWebEvent event!)
    val! = str(event!.getEventMap().get("value"))
methodend
```
For components where you need a checked/toggled state instead of a value: `eventOptions!.addItem("checked", "event.target.checked")`.

### Component reference

| Component | Tag | Key attributes | Key events |
|-----------|-----|----------------|------------|
| Card | `sl-card` | — | — |
| Rating | `sl-rating` | `value`, `max`, `precision`, `readonly` | `sl-change` |
| Badge | `sl-badge` | `variant` (primary/success/neutral/warning/danger), `pill`, `pulse` | — |
| Accordion / Details | `sl-details` | `summary`, `open`, `disabled` | `sl-show`, `sl-hide` |
| Button | `sl-button` | `variant`, `size`, `outline`, `pill`, `href` | `click` |
| Dialog | `sl-dialog` | `label`, `open`, `no-header` | `sl-show`, `sl-hide`, `sl-after-hide` |
| Drawer | `sl-drawer` | `label`, `open`, `placement` (top/end/bottom/start), `contained` | `sl-show`, `sl-hide` |
| Tab group | `sl-tab-group` | `placement` (top/bottom/start/end), `activation` | `sl-tab-show` |
| Tab | `sl-tab` | `slot="nav"`, `panel`, `active`, `disabled` | — |
| Tab panel | `sl-tab-panel` | `name`, `active` | — |
| Tooltip | `sl-tooltip` | `content`, `placement`, `trigger`, `disabled` | `sl-show`, `sl-hide` |
| Carousel | `sl-carousel` | `navigation`, `pagination`, `autoplay`, `loop`, `slides-per-page` | `sl-slide-change` |
| Carousel item | `sl-carousel-item` | — | — |
| Icon | `sl-icon` | `name`, `src`, `label` | — |

For `sl-tab-group`, every `<sl-tab>` needs `slot="nav"` and every `<sl-tab-panel>` needs a `name` matching its tab's `panel` attribute — mismatches fail silently (tab shows, no panel switches).

### Theming to match the host app

Map Shoelace's `--sl-*` design tokens to the app's own CSS custom properties (or directly to `--dwc-*` tokens) so a single theme swap updates Shoelace too, instead of maintaining two parallel palettes:
```css
:root {
  --sl-color-primary-600:    var(--dwc-color-primary);
  --sl-color-neutral-0:      var(--dwc-surface-1);
  --sl-color-neutral-900:    var(--dwc-color-on-surface);
  --sl-border-radius-medium: var(--dwc-border-radius);
  --sl-font-sans:            var(--dwc-font-family);
  --sl-shadow-medium:        var(--dwc-shadow-2);
}
```
