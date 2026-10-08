# DWC theming — design tokens, light/dark themes, component theme & expanse

## CSS with a DWC app — prefer the --dwc-* design tokens

BBj DWC apps are styled with CSS. For simple programs you can rely on `BBjControl::setStyle()`, but most of the time keep the CSS in an external file (conventionally named after the main project file, with a `.css` extension) that's injected at startup by the `BBjWebManager`.

The DWC includes hundreds of pre-defined CSS custom properties named as `--dwc-*` tokens. Prefer changing these tokens over hardcoding traditional CSS — most look-and-feel changes only require redefining a token value.

**Sizing:** use the `--dwc-size-*` tokens. When writing standard CSS sizes, prefer `em` units relative to the app's font size so everything scales together when the font size changes; hardcoded `px` values won't scale.

**Colors:** the DWC provides these semantic colors, each with lightness variations from 5 (dark) to 95 (light) — e.g. `--dwc-color-primary-80` is a light primary, `--dwc-color-primary-20` a much darker one:

- `--dwc-color-primary`
- `--dwc-color-default`
- `--dwc-color-danger`
- `--dwc-color-success`
- `--dwc-color-info`
- `--dwc-color-warning`

There are also tokens for text, and low-level hue/saturation config tokens per color:
```css
:root {
    /* Change the DWC's primary color to a 75% saturated purple */
    --dwc-color-primary-h: 265;
    --dwc-color-primary-s: 75%;
}
```

**Injection ordering matters.** `injectStyle()`'s second parameter controls placement: `0` appends the style at the end of `<body>` — last in the DOM, so it wins same-specificity cascade ties; `1` injects into `<head>`, where later stylesheets can still beat it. For app CSS or any override that must win over earlier styles, use `0`.

**Habits that keep custom CSS aligned with the design system:**

- **Always reference tokens with `var(...)`** instead of hardcoded literals (`#3b82f6`, `rgb(59 130 246)`) — hardcoded colors don't adapt to dark mode or track palette changes. `background: var(--dwc-surface-3); color: var(--dwc-color-body-text); border: 1px solid var(--dwc-border-color);`
- **Prefer variation tokens over raw step numbers.** `--dwc-color-primary`, `-dark`, `-light`, `-text`, `-alt` resolve to a different step automatically in light vs. dark mode; a raw step like `--dwc-color-primary-50` is frozen at that step in both modes.
- **Use the suffix that matches the role:**

  | Suffix | Role |
  |---|---|
  | `--dwc-color-{name}` | Solid fill at full strength (buttons, badges, banners) |
  | `--dwc-color-{name}-dark` | Active / pressed state |
  | `--dwc-color-{name}-light` | Hover / focus background |
  | `--dwc-color-{name}-alt` | Subtle tinted background for callouts and alt rows |
  | `--dwc-color-{name}-text` | Colored text on a neutral surface |
  | `--dwc-color-on-{name}-text` | Text placed on the colored shade as background (auto-contrast) |
  | `--dwc-border-color-{name}` | Borders and dividers |

- **Reserve surfaces and borders for their roles** — `--dwc-surface-1/2/3` build page hierarchy, `--dwc-border-color[-*]` draw separators. Reusing palette steps for these looks fine visually but loses automatic mode adaptation.
- **Override at the seed level in custom themes**, not individual steps: `--dwc-color-{name}-seed` (or `-h`/`-s`) regenerates the whole 19-step palette consistently; overriding one step (e.g. `--dwc-color-primary-50: #6366f1`) leaves the rest of the palette drifting against the brand color.
- **Apply the same pattern to spacing, sizing, radius, and transitions** — `var(--dwc-space-m)`, `var(--dwc-border-radius)`, `var(--dwc-transition)` instead of magic numbers. Hardcoded values bypass user-preference font-size scaling and skip the design system's eased timing curves.
- **Use `::part(...)` to reach into components** — DWC components are Shadow DOM, so `.dwc-button-label {}` matches nothing from outside. Target exposed parts instead: `dwc-button[theme='primary']::part(label) { letter-spacing: 0.02em; }`
- **Scope token overrides with a wrapper selector** when you only want to retune one area: `.danger-section { --dwc-color-primary-seed: #ef4444; }` re-hues every component inside `.danger-section` without touching the rest of the app.
- **Test in both light and dark mode** before shipping custom CSS — hardcoded colors that look fine in one mode often read as illegible or out-of-palette in the other.
- **Don't reach for `!important`** — it escapes the cascade and makes future overrides harder. If a rule isn't winning, the fix is almost always matching the framework's selector specificity or adding a parent qualifier. Reserve `!important` for third-party styling you have no other way to defeat.

---

## Light and dark themes

DWC only — `BBjWebManager::setTheme` and friends below are honored only by the DWC client; on BUI/WebUI the calls are no-ops.

DWC ships three built-in application themes (`light`, `dark`, `dark-pure` — like dark, but with no primary-color tint, pure neutral grays), plus the reserved keyword `system`:
```bbj
web! = bbjapi().getWebManager()
web!.setTheme("dark")   REM switches at runtime, no rebuild
```

**Following the OS light/dark preference:** register which theme to use for each appearance state, then activate `"system"`:
```bbj
web! = bbjapi().getWebManager()
web!.setDarkTheme("dark")
web!.setLightTheme("light")
web!.setTheme("system")
```
`"system"` is resolved at runtime to the registered light/dark theme and re-resolves automatically when the OS preference changes. Once resolved, `data-app-theme` on `<html>` is set to the actual resolved name (`light`/`dark`), never `"system"` itself — so CSS overrides should target those concrete names.

The active theme is exposed as the `data-app-theme` attribute on `<html>` — `setTheme()` sets it (confirmed by inspecting `document.documentElement`). To adjust the **light** theme, redefine palette config tokens at `:root`. To adjust the **dark** theme, redefine them on `html[data-app-theme="dark"]`. Custom themes work the same way with your own theme name:
```css
/* Modify the light theme */
:root {
    --dwc-color-primary-h: 265;
    --dwc-color-primary-s: 75%;
}

/* Modify the dark theme */
html[data-app-theme="dark"] {
    --dwc-color-primary-h: 0;
}

/* Define a custom theme */
html[data-app-theme="my-custom-theme"] {
    --dwc-color-primary-h: 210;

    /* Bump the font size from medium to large.
       Sizes range small→large: -3xs, -2xs, -xs, -m, -l, -xl, -2xl, -3xl */
    --dwc-font-size: var(--dwc-font-size-l);
}
```
Most branding work should override the existing `light`/`dark`/`dark-pure` themes (retune seed colors, keep the same names) rather than defining a brand-new theme — every component then picks up the new look with no `setTheme()` name change needed. Reach for a genuinely new theme name only when it must coexist with the built-ins (a high-contrast variant, a customer-specific skin).

**A custom *dark* theme (built-in `dark`/`dark-pure`, or your own) needs two extra declarations** on its `data-app-theme` selector, or native browser surfaces (scrollbars, form-control widgets, autofill highlights) render light and look out of place against the dark app:
```css
html[data-app-theme='brand-dark'] {
    --dwc-dark-mode: 1;
    color-scheme: dark;
}
```
`dark` and `dark-pure` already set this for you; you only need it when authoring your own dark variant. Light themes don't need `color-scheme` — browsers default to light.

Load a theme override stylesheet with `BBjWebManager::injectStyle` (inline) or `injectStyleUrl` (hosted file), e.g. `web!.injectStyleUrl("/static/themes/brand.css")`.

**Component-level theme is independent of the app-wide theme.** Most controls accept a `theme` attribute picking from the semantic palette (`default`, `primary`, `success`, `warning`, `danger`, `info`, `gray`) regardless of which app theme (light/dark/custom) is active:
```bbj
button!.setAttribute("theme", "primary")
```

**`expanse` unifies control sizing across the design system** — set it so a row of `BBjButton`, `BBjEditBox`, `BBjComboBox`, etc. with the same `expanse` line up at the same height/font size. Scale runs `xs, s, m, l, xl` (icon buttons extend down to `2xs` and up to `3xl`). A control has no `expanse` by default — sizing then comes purely from the BBj-side width/height arguments (`addButton`, `addEditBox`, ...). Set `expanse` on any control that relies on flow layout or omits explicit sizing, or it can render at inconsistent dimensions across the page:
```bbj
button!.setAttribute("expanse", "l")
```

**Reduced motion** — DWC automatically disables non-essential animations when the user has "reduce motion" enabled at the OS level. No BBj code required.

### Toggling the theme between light and dark mode

- Default to light; if injecting web component CSS files (e.g. Shoelace themes), choose their light theme CSS at startup
- Theme toggle UI convention: a `BBjRadioButton` with `setAttribute("switch", "true")` in the top-right corner, labeled with a Tabler sun/moon icon (inline SVG or `<i class="ti ti-sun">` HTML)
- Because CSS custom properties drive all colors/typography, a single swap updates everything

```bbj
REM Switch the DWC theme — this sets data-app-theme="light" on <html>, which is
REM exactly what the html[data-app-theme="..."] theme CSS selectors target.
REM No manual setAttribute call is needed.
#webManager!.setTheme("light")

REM Swap any web-component theme CSS (e.g. Shoelace) by re-injecting the matching
REM light/dark theme stylesheet under the same id so it replaces the previous one
themeCdnUrl! = "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.20.1/cdn/themes/light.css"
#webManager!.injectLinkUrl(themeCdnUrl!, 0, "rel=stylesheet,id=shoelace-theme-css")
```
