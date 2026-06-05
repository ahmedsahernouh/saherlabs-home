> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer UI Design Handoff

Updated: 2026-05-22

This file is a design brief for a UI designer LLM agent. The goal is to propose
a more polished, attractive, and responsive FieldViewer interface while keeping
the current engineering behavior intact and implementable in the existing
Python/Bokeh/Flask codebase.

## Product Context

FieldViewer is a multi-page engineering web application for oil-field
subsurface, production, timeline, completion, well-testing, ESP, database, AI
lab, and field-status workflows. It is not a marketing website. The primary
users are engineers and field/production staff who need to inspect maps,
well data, production charts, and operational dashboards repeatedly.

The app is generated from source code and field-specific manifests. The active
demo instance is Y1. private engineering instance remains documented as the active engineering instance.

Y1 is defined by:

- Manifest: `instances/y1/fieldviewer.instance.json`
- Generated app output: `instances/y1/App/`
- Menu page: `instances/y1/App/menu.html`
- Main surface map: `instances/y1/App/FieldViewer.html`
- Timeline page: `instances/y1/App/FieldViewer_timeline.html`
- Production page: `instances/y1/App/FieldViewer_production.html`
- Field status dashboard: `instances/y1/App/FieldViewer_Field_Status_Dashboard.html`

The private engineering instance instance is defined by:

- Manifest: `instances/private engineering instance/fieldviewer.instance.json`
- Generated app output: `instances/private engineering instance/App/`
- Menu page: `instances/private engineering instance/App/menu.html`
- Main surface map: `instances/private engineering instance/App/FieldViewer.html`
- Timeline page: `instances/private engineering instance/App/FieldViewer_timeline.html`
- Production page: `instances/private engineering instance/App/FieldViewer_production.html`
- Field status dashboard: `instances/private engineering instance/App/FieldViewer_Field_Status_Dashboard.html`

Durable UI changes should be made in generator/runtime source, not by
hand-editing generated HTML. Important implementation files include:

- `src/app/pages/menu.py`
- `src/legacy/legacy_viewer.py`
- `src/app/components/layout_utils.py`
- `src/app/components/map_utils.py`
- `src/app/pages/timeline.py`
- `src/app/pages/timeline_controls.py`
- `src/app/pages/timeline_figures.py`
- `src/app/pages/production.py`
- `src/app/pages/production_controls.py`
- `src/app/pages/production_figures.py`
- `src/app/pages/completions_controls.py`
- `src/app/pages/well_testing_controls.py`
- `src/app/pages/esp_controls.py`

## Current Technical Stack

- Python-generated standalone Bokeh HTML pages.
- Flask-style local/server runtime via `src/app/server.py`.
- Bokeh CDN resources in standalone generated pages.
- Menu is mostly custom HTML/CSS generated from Python.
- Analysis pages are Bokeh layouts using `row`, `column`, `figure`, `Div`,
  `Button`, `Select`, `CheckboxGroup`, `MultiChoice`, `MultiSelect`, `Slider`,
  `TextInput`, and `Toggle`.
- Current layouts are mostly fixed desktop layouts, with large maps/charts and
  fixed side panels.
- Field-specific behavior comes from `fieldviewer.instance.json`.

## Current Responsive Implementation Status

As of 2026-05-22, the real generated Bokeh pages include a first responsive
implementation, not just static prototypes:

- `src/app/components/page_io.py` injects the shared shell theme, dark-shell
  toggle, mobile controls button, and phone bottom-drawer behavior into
  generated standalone Bokeh pages.
- `src/legacy/legacy_viewer.py` tags the real map layout with
  `fieldviewer-responsive-root`, the main plot panel with
  `fieldviewer-main-plot-panel`, and the desktop key-map/readout column with
  `fieldviewer-key-map-panel`.
- `src/app/pages/timeline.py` and `src/app/pages/timeline_figures.py` tag the
  timeline map, control layout, and key-map panel for responsive behavior.
- `src/app/pages/production.py` and `src/app/pages/production_figures.py` tag
  the production line chart, field map, and key-map panel for responsive
  behavior.
- `src/app/pages/field_status_dashboard.py` keeps the status dashboard as a
  real Bokeh map-plus-counts page and tags its map/control layout for the same
  responsive shell behavior.

Phone behavior currently uses a pragmatic Bokeh-compatible approach:

- Left controls become a bottom drawer toggled by a fixed `Controls` button.
- Bokeh rows/columns stack vertically on narrow screens.
- Key maps are hidden on phone only through responsive styling; the Bokeh key
  map model remains present and visible on desktop.
- Main maps/charts keep white plot canvases and existing CRS/aspect behavior.

Important limitation: standalone Bokeh pages do not behave like hand-authored
HTML/CSS apps. Further design refinements should continue from these source
hooks and should be browser-tested at desktop, tablet, and phone widths.

## Current Information Architecture

The menu exposes these active modules for the Y1 demo instance:

- Field Status Dashboard
- FieldViewer AI Lab
- Surface Map
- Subsurface Maps
- Production Profile
- Field Timeline
- Completion
- Well Testing
- Database

private engineering instance may include additional engineering workflows. private engineering instance screenshots and generated pages may be documented when needed for engineering review.

The menu also shows inactive/planned cards:

- Well Intervention
- Drilling Monitoring
- Well Logs
- Well Data Dir

Current default home route is menu-driven through `server.default_home_output`
in the instance manifest.

## Existing Visual Direction

### Menu Page

The menu is the most styled part of the current app.

Current typography:

- Main UI font: `DM Sans`
- Technical/accent font: `Space Mono`
- Fonts are imported from Google Fonts.

Current menu palette:

- Dark navy gradient shell: `#0b1a2e`, `#102542`, `#0d1f35`
- Light mode shell: `#ffffff`
- Primary blue: `#378add`
- Primary green: `#1d9e75`
- Text dark navy: `#102542`
- Light text: `#e6f1fb`, `#c8ddf0`
- Muted blue-grey: `#6a8faf`, `#536f87`, `#61788f`
- AI Lab accent: `#d65a75`
- Field Status accent: `#d64f4f`
- Database accent: `#6b7fdb`

Current menu layout:

- Centered panel, max width about 672 px.
- Header with square gradient logo, title, subtitle, and light/dark toggle.
- Grid of module cards, two columns on desktop, one column under about 640 px.
- Cards have icon area, label, short description, and arrow.
- Light mode is the default.
- Dark mode exists only on the menu through localStorage key
  `fieldviewer-menu-theme`.

Current menu card style:

- Rounded cards, radius about 13 px.
- Light mode cards are white with subtle shadow.
- Active cards use stronger borders and hover lift.
- Inactive cards are grey/dimmed and not clickable.

### Main Surface/Subsurface Map Page

This is the core engineering page and must preserve all current tools and
callbacks. It is generated mainly by `src/legacy/legacy_viewer.py`.

Current structure:

- Left scrolling controls panel, fixed width about 380 px.
- Main Bokeh map figure, about 1200 x 850 px.
- Right column with ESRI attribution, key map, extent, cursor,
  measurement, and path readouts.
- Overall layout is currently a horizontal row:
  controls panel + map + right key-map column.

Current map constraints:

- Main map canvas must stay white unless explicitly approved otherwise.
- Key map canvas must stay white unless explicitly approved otherwise.
- Engineering map geometry and CRS behavior must not be changed by visual
  styling.
- Main map uses UTM engineering coordinates and Web Mercator/local tile display
  logic through the existing CRS pipeline.
- Map tools include pan, wheel zoom, box zoom, reset, save, tap, hover, path,
  distance, object add/export, grid selection, contour/fault/layer toggles,
  well labels, station display, basemap toggles, and bubble analytics.

Current map/control styling:

- Section headers are light grey `#f0f0f0`, with dark left border `#2c3e50`.
- Active checked checkbox labels are highlighted red/yellow:
  `#d00000` on `#fff3cd`.
- Analysis tools panel uses light blue styling:
  `#f8fbff`, `#c7d8e8`, left border `#3b6ea5`.
- Analysis action buttons use pale blue:
  `#eef5ff`, `#9fb9d5`, hover `#e2eefb`.
- Control panel border is currently `#ddd`, padding 6 px.
- Many controls use default Bokeh widget styling.

Important previous limitation:

- A prior styling attempt was rejected because dark shell/background colors
  affected the charts/maps. Redesigns must separate application shell styling
  from Bokeh plot canvases. Keep maps/charts readable and mostly white unless
  the design explicitly proposes a safe alternate plot theme.

### Timeline Page

The timeline page is a Bokeh page with:

- Left side controls panel.
- Large map, about 1200 x 850 px.
- Time slider row with previous/next buttons.
- Date/time info line.
- Bubble metric selector.
- Bubble radius scale input.
- Show all wells toggle.
- Show well names toggle.
- Only wells with current value toggle.
- Well-list filter.
- Download timeline CSV button.
- Map background toggle.
- Grid controls.

Current timeline metric colors:

- Oil: green `#2e7d32`, line `#1b5e20`
- Water: blue `#1e88e5`, line `#0d47a1`
- Gas: red `#e53935`, line `#b71c1c`
- Default: blue `#1f77b4`, line `#1f4f8b`

### Production Page

The production page is a dense analytical workspace with:

- Left controls panel, about 360 px wide and 980 px high.
- Production line chart, about 1180 x 486 px.
- Field map, about 900 x 600 px.
- Key map and map/context readouts.
- Well selection and group creation tools.
- Bubble analytics.
- Timeline analytics.
- Primary/secondary metrics.
- Aggregation controls.
- Curve style and color-family controls.
- Download production CSV button.

Current production chart colors are semantically important:

- Oil family default: green
- Water family default: blue
- Gas family default: red
- Other selectable families: orange, purple, teal, gray

### Field Status Dashboard

Current status dashboard uses a lighter application shell and a dark counts
panel. The counts panel was tuned carefully and should be preserved unless the
redesign explicitly replaces it with equivalent or better typography.

Current dashboard style:

- Page background: `#f4f7fb`
- Main shell font: `DM Sans`
- Sidebar/card border: `#d9e6f2`
- Panel background: `#ffffff`
- Dark count/status cards: `#02040a`
- Dark card border: `#172033`
- Count title and date: 20 px, bold, white
- Section headers in dark card: 16 px, bold, white
- Count rows: 14 px, white
- Separator lines between count blocks:
  `rgba(148,163,184,0.45)`

## Core UX Problems To Solve

1. The app feels visually inconsistent. The menu is modern, while most Bokeh
   pages retain default/basic Bokeh styling.
2. The core analysis pages are desktop-first and fixed-width. They need a
   responsive strategy for laptops, tablets, phones, and different screen
   sizes.
3. The left control panels are long, dense, and visually flat. Controls need
   clearer grouping, hierarchy, and scan paths without hiding important tools.
4. The main map page has many tools. A phone layout cannot simply shrink the
   desktop row. It needs a practical control strategy.
5. The visual design must look more professional and attractive without turning
   the app into a marketing landing page.
6. The design must preserve engineering precision, map readability, CRS logic,
   export behavior, and existing callbacks.

## Design Requirements

### General UI Direction

- Design for an operational engineering application, not a marketing site.
- Prioritize dense but organized information, fast scanning, and repeated use.
- Use a polished professional palette with enough contrast and clear semantic
  colors.
- Do not make the whole app one dominant hue. Avoid making everything blue,
  purple, beige, brown, or dark navy.
- Use card-like surfaces only where useful for panels, repeated module cards,
  and compact dashboard blocks. Avoid nested cards.
- Keep page sections practical and utilitarian.
- Use icons for module cards and common actions where they improve scanning.
- Preserve readable axes, legends, map overlays, well markers, contour lines,
  and production curves.
- Use stable dimensions and responsive constraints so text, controls, and plots
  do not overlap.
- Text must fit within buttons/cards on phone and desktop.
- Letter spacing should be normal or minimal. Do not rely on negative letter
  spacing or viewport-scaled font sizes.

### Responsive Requirements

The designer should propose layouts for at least these breakpoints:

- Phone portrait: 360-430 px wide
- Phone landscape: 640-932 px wide
- Tablet: 768-1024 px wide
- Laptop: 1280-1440 px wide
- Desktop/wide monitor: 1600-1920+ px wide

Expected responsive strategy:

- Menu: keep responsive card grid, improve visual polish, support phone
  portrait cleanly.
- Main map page: propose desktop, tablet, and phone interaction patterns.
  The control panel may become a drawer, bottom sheet, tabbed panel, accordion,
  or responsive rail. The map must remain the primary surface.
- Timeline page: map + time controls must stay usable on phone. Slider and
  date labels need a phone-safe layout.
- Production page: line chart and map need a stacked responsive layout on
  smaller screens. Controls may become drawers/tabs.
- Field status dashboard: should work as a responsive dashboard with readable
  cards and counts on phone.

Phone design should account for Bokeh limitations. It is acceptable to specify
that the first implementation may use stacked panels, scrollable regions, and
collapsible/drawer controls rather than a fully native mobile app interaction
model.

### Accessibility And Usability

- Minimum body/control text should generally be 13-14 px on desktop and not
  smaller than 12 px for dense metadata.
- Hit targets on touch layouts should be about 40-44 px where possible.
- Color alone should not be the only state indicator for critical toggles.
- Maintain visible focus/hover/active states.
- Use clear contrast for map labels, control labels, disabled states, and dark
  panels.
- Avoid decorative elements that interfere with map/chart inspection.

## Non-Negotiable Implementation Constraints

The design must not require replacing the app with a static mockup. FieldViewer
must remain the real Bokeh/Flask application with all current tools and
callbacks.

Do not change these behaviors:

- CRS transform path and map coordinate logic.
- UTM/Web Mercator display behavior.
- Existing data source loading from the manifest.
- Export workflows and CSV semantics.
- Grid selection, fault selection, basemap toggles, well filters, labels,
  object/path/distance tools, and chart controls.
- ESRI attribution when ESRI imagery is visible:
  `Powered by Esri | Sources: Esri and imagery providers`
- Current local tile path pattern:
  `/tiles_DH_sat/{Z}/{X}/{Y}.png`

Important visual boundary:

- Shell/sidebar/background styling can change.
- Bokeh plot canvases, especially the main map and key map, should remain
  white or very light unless the designer provides a specific plot theme with
  verified readability for axes, overlays, and tiles.

## Implementation Preferences

The final design should be implementable in this repository by editing source
generator files, then rebuilding the Y1 demo instance for review and
private engineering instance only for selected-instance validation when needed.

Preferred implementation approach:

- Define shared design tokens in generator code or a small shared Python/CSS
  helper where practical.
- Update `src/app/pages/menu.py` for menu layout and styling.
- Update `src/app/components/layout_utils.py` for common Bokeh side-panel,
  heading, navigation, divider, and control styling.
- Update `src/legacy/legacy_viewer.py` for the main map app shell and control
  panel styling.
- Update `timeline_controls.py`, `timeline_figures.py`,
  `production_controls.py`, and `production_figures.py` for page-specific
  responsive layout and styling.
- Keep generated `instances/<field>/App/*.html` as build outputs.
- Validate by rebuilding:
  `python tools/rebuild_site.py --instance-config instances/y1/fieldviewer.instance.json`
- Run validation/QC after implementation:
  `python tools/validate_instance.py instances/y1/fieldviewer.instance.json`
  and `python tools/qc_regression_suite.py`

## What The Designer Should Deliver

Please return a design recommendation that includes:

1. Overall design concept and rationale for an engineering field-operations app.
2. Design tokens:
   - Colors with hex values
   - Typography scale
   - Spacing scale
   - Border radius values
   - Shadows or elevation rules
   - Plot/map color rules
   - Status/semantic color rules
3. Page-by-page design specs:
   - Menu
   - Main surface/subsurface map
   - Timeline
   - Production
   - Field Status Dashboard
   - Shared side panels and controls
4. Responsive behavior:
   - Desktop layout
   - Tablet layout
   - Phone portrait layout
   - Phone landscape layout
   - How controls are opened/closed on small screens
5. Bokeh implementation notes:
   - Which styles can be CSS-only
   - Which Bokeh model widths/heights/sizing modes should change
   - Which plots should stay fixed-ratio
   - Any expected limitations in standalone Bokeh HTML
6. Concrete component specs:
   - Buttons
   - Selects
   - Text inputs
   - Checkbox/toggle groups
   - Section headers
   - Dividers
   - Panels/drawers
   - Toolbars
   - Legends
   - Map key/overview
   - Cards
   - Dashboard count blocks
7. Any suggested icons or icon style, preferably with an implementation-friendly
   source such as inline SVG or a standard icon set.
8. A prioritized implementation plan:
   - Phase 1: low-risk polish and shared tokens
   - Phase 2: responsive layout changes
   - Phase 3: deeper interaction improvements

If possible, include CSS-like snippets and Bokeh-specific sizing suggestions,
but avoid recommending a frontend framework migration unless absolutely
necessary. A practical design that can be implemented inside the current
Bokeh/Python generator is preferred.

## Implementation Questions For Designer To Answer

- Should the main analysis pages use a persistent left panel on desktop and a
  drawer/bottom sheet on phone?
- Should controls be grouped into tabs/accordions, and if so, what are the tab
  groups for each page?
- Should dark mode exist beyond the menu, or should the app use one consistent
  light operational theme?
- What should the map and chart canvases look like in the proposed theme?
- What are the exact minimum widths/heights for map, chart, side panel, key map,
  and dashboard cards at each breakpoint?
- Which controls are primary, secondary, or advanced?
- Which labels should be shortened for phone without changing meaning?
- What is the recommended visual treatment for active/checked Bokeh controls?

## Current Build And Verification Commands

Use these commands after implementation:

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
python tools\qc_regression_suite.py
```

To run locally:

```powershell
python src\app\server.py
```

Open:

```text
http://127.0.0.1:8000/menu.html
http://127.0.0.1:8000/FieldViewer.html
http://127.0.0.1:8000/FieldViewer_timeline.html
http://127.0.0.1:8000/FieldViewer_production.html
http://127.0.0.1:8000/FieldViewer_Field_Status_Dashboard.html
```

For screenshots or design review, choose the generated instance that matches the review objective.

## Notes For The Implementing Agent

When the designer returns the recommendation, implementation should be reviewed
against these risks:

- Does it preserve Bokeh callbacks and data sources?
- Does it preserve map/chart readability?
- Does it keep maps/key maps white or very light unless explicitly changed?
- Can the responsive behavior be done with generated CSS and Bokeh sizing
  modes, or does it require deeper page restructuring?
- Does it avoid hand-editing generated HTML?
- Does it keep user-facing module labels and export behavior intact?
- Does it avoid exposing internal/generated artifacts in controls?

The most likely implementation path is incremental:

1. Add shared design constants and CSS helper patterns.
2. Refresh menu styling.
3. Refresh shared Bokeh side-panel/control styling.
4. Update map/timeline/production layout sizing modes where safe.
5. Add responsive CSS wrappers or page-level media behavior.
6. Rebuild and verify all generated Y1 pages for review, then verify
   private engineering instance privately if the change affects internal workflows.

