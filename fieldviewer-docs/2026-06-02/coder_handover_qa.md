> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Coder Handover Q&A

Updated: 2026-05-29

## Architecture

### What is the current architecture?

FieldViewer is a central generator plus field instances. The generator owns
source code, tools, documentation, and shared logic. Each instance owns its
manifest, data, generated app, and deployment artifacts.

### Why was the generator/instance split introduced?

To avoid hard-coding private engineering instance as the only application and to make future field apps
repeatable. A selected manifest now drives paths, enabled modules, outputs,
tiles, CRS, and runtime behavior.

### Which instance should I use for demos?

Y1 is the demo instance:

```text
instances/y1/fieldviewer.instance.json
```

### What is the active engineering instance?

```text
instances/private engineering instance/fieldviewer.instance.json
```

private engineering instance is the active engineering instance.

## Programming Stack

### What are the primary programming languages?

Python is the main implementation language. JavaScript is used through Bokeh
`CustomJS` and embedded page logic. HTML/CSS define generated page chrome and
menu/UI styling. JSON defines manifests, generated context, grid packages, and
API payloads. SQL is used for SQLite schema, safe SELECT queries, metadata
tables, and Text-to-SQL readiness.

### What is Python responsible for?

Python owns the generator, data loading, Bokeh page construction, CRS logic,
database adapter, Flask server, validation tools, rebuild tools, DB readiness
tools, and most module-specific page builders.

### What is JavaScript responsible for?

JavaScript handles standalone browser behavior through Bokeh `CustomJS`:
selection, filters, map toggles, chart updates, exports, responsive page state,
AI Lab UI interactions, and page-local workflow logic.

### What frameworks and libraries are central?

Bokeh, Flask, Flask-CORS, pandas, NumPy, SQLite, pyproj, rasterio, matplotlib,
scikit-image, Pillow, PyMuPDF, openpyxl, pywin32, and the optional OpenAI Python
SDK are the main stack components.

### Why is Bokeh important?

Bokeh allows Python to generate standalone interactive HTML pages with figures,
widgets, glyph renderers, selections, hover tools, and JavaScript callbacks.

### Why is Flask important?

Flask serves generated app files and runtime APIs such as health checks, static
assets, tiles, z lookup, ESP payloads, AI routes, Data Parser routes, and DB
routes.

### What does SQLite do in this project?

SQLite stores structured metadata, semantic schema descriptions, relationships,
query examples, query history, normalized summaries, and safe AI-visible views.
It is not used for heavy grids, tiles, cubes, SEG-Y, or generated HTML.

### Where does generated output go for Y1?

```text
instances/y1/App/
```

### Where does generated output go for private engineering instance?

```text
instances/private engineering instance/App/
```

### What should not be reverted casually?

The dirty worktree includes migration changes away from root-level `Data/` and
`App/`. Do not revert these changes unless the user explicitly asks.

## Source Files

### What does `src/config.py` do?

It loads the selected instance manifest, resolves instance-relative paths, and
exposes config values for paths, modules, CRS, alignment, tiles, database, and
outputs.

### What does `src/app/main.py` do?

It is the site builder. It reads config and data, builds generated Bokeh/HTML
pages, and writes outputs into the selected instance app folder.

### What does `src/app/server.py` do?

It serves the generated app and optional runtime routes. It is long-running by
design.

### What does `src/legacy/legacy_viewer.py` do?

It owns the main surface/subsurface Bokeh map engine and many map controls,
callbacks, overlays, and basemap behaviors.

### What do the production-style figure modules do?

`production_figures.py`, `well_testing_figures.py`, and `esp_figures.py` build
the chart, selector-map, and key-map figures for related production-style
applications. Layout changes in one of these pages should be checked against
the others because they share similar chart-first and selector-map-second
desktop patterns.

### Where should menu behavior be changed?

In `src/app/pages/menu.py`, then rebuild the instance.

## Build Workflow

### How do you validate the Y1 demo instance?

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
```

### How do you validate the private engineering instance engineering instance?

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
```

### How do you rebuild the Y1 demo instance?

```powershell
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

### How do you rebuild the private engineering instance engineering instance?

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

### How do you run regression QC?

```powershell
python tools\qc_regression_suite.py
```

### When should QC be run?

Run QC when CRS, geometry, grid packaging, generated pages, map behavior, or
shared runtime behavior changes.

### How do you check database/Text-to-SQL readiness?

```powershell
python tools\smoke_test_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\evaluate_text_to_sql_readiness.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

For offline setup or export when the runtime DB is disabled, use the tool-level
`--force` flag.

### Why is rebuilding important after source edits?

The user-facing pages are generated outputs. Source changes are not reflected
in `instances/<field>/App/*.html` until the app is rebuilt.

## Manifest And Modules

### What is the manifest source of truth?

`fieldviewer.instance.json` controls field identity, paths, modules, outputs,
server default route, database, demo behavior, CRS, alignment, processing,
viewer settings, and tiles.

### How are menu states controlled?

Through `modules.<name>.menu_state`. Supported states are `active`, `dimmed`,
and `hidden`.

### What is the default home route?

The manifest uses `server.default_home_output`, currently pointing to the menu
output.

### How is the QR/server-home URL controlled?

Through `server.url` in each instance manifest. The menu QR card uses that URL,
so local IP addresses and future demo URLs can differ by instance
without code changes.

### How should a new field be represented?

Create a new `instances/<field>/` folder with its own manifest, data folder,
settings, and generated app output. Then build using
`--instance-config <manifest>`.

## CRS And Maps

### What is the engineering CRS?

`EPSG:23033`, ED50 / UTM Zone 33N.

### What is the display/tile CRS?

`EPSG:3857`, Web Mercator.

### Why should CRS not be rewritten in browser-only code?

The authoritative path uses Python/QGIS-compatible CRS logic and manifest
settings. Browser-only conversion risks breaking engineering coordinate
truth, datum behavior, and reproducibility.

### What is the ESRI tile URL?

```text
https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{Z}/{Y}/{X}
```

### What is the local tile URL?

```text
/tiles_DH_sat/{Z}/{X}/{Y}.png
```

### What attribution is required when ESRI is visible?

```text
Powered by Esri | Sources: Esri and imagery providers
```

## UI Design

### Where is the UI design handoff?

`docs/UI_DESIGN_HANDOFF.md`.

### What is the UI redesign goal?

Make the app more polished, consistent, responsive, and readable while keeping
the existing Bokeh app and engineering behavior intact.

### What is non-negotiable during UI work?

Do not replace the working Bokeh pages with static mockups. Preserve maps,
charts, callbacks, exports, widgets, and data sources.

### Which files are most relevant for UI implementation?

`menu.py`, `layout_utils.py`, `legacy_viewer.py`, `timeline_controls.py`,
`timeline_figures.py`, `production_controls.py`, and
`production_figures.py`.

### Why should plot canvases stay light?

Map and chart readability is more important than shell styling. A dark canvas
can harm visibility of wells, contours, labels, axes, tiles, and overlays.

### What is a likely responsive strategy?

Keep persistent side panels on desktop, use drawers/tabs/stacked panels on
small screens, and preserve map/chart priority in the viewport.

## Database

### What is the database module for?

Metadata, catalog rows, annotations, compact production summaries, full
production source rows, audit history, AI query records, and future safe AI
workflows.

### What is the difference between `production_summary` and `production_full`?

`production_summary` is the compact production table used for common rate,
pressure, water-cut, and latest-date questions. `production_full` stores the
complete imported production source rows with SQL-friendly normalized column
names. Use `v_production_full` when a question needs monthly volumes,
cumulative volumes, injection, reservoir/status fields, or other source
production columns.

### What are the main Text-to-SQL readiness components?

Semantic metadata tables, AI-visible table controls, safe views, schema context
builder, query examples, query history, safe SQL validator, `/api/db/validate-sql`,
`/api/db/select`, and the readiness evaluator.

### Why SQLite first?

SQLite is available in the Python standard library, requires no service
process, and fits local instance metadata needs.

### Why is Access deferred?

Access requires environment-specific ODBC drivers and connection handling. The
adapter interface allows an Access backend later without changing callers.

### What protects text-to-SQL workflows?

`src/db/query_validator.py` rejects write/admin SQL, multiple statements, and
unsafe query forms. Only single `SELECT` or `WITH` statements are allowed.

### What dangerous SQL is rejected?

The validator rejects write/admin keywords such as INSERT, UPDATE, DELETE,
DROP, ALTER, CREATE, REPLACE, TRUNCATE, ATTACH, DETACH, PRAGMA, VACUUM, EXEC,
and MERGE. It also rejects multiple statements, hidden semicolon attacks,
dangerous comments, and AI access to hidden tables such as `audit_log`.

### What should the future LLM agent use?

It should use `/api/db/schema-context` for compact schema context,
`/api/db/validate-sql` for validation, and `/api/db/select` for execution. It
must not directly open SQLite or run arbitrary SQL. Detailed production
questions should prefer `v_production_full` when the compact summary table is
not enough.

### Can the database update arbitrary rows?

No. Controlled updates require `database.allow_updates=true` and allowlisted
tables and columns.

### Should grids and tiles be stored in SQLite?

No. Heavy artifacts stay on disk. The database stores references, metadata,
compact summaries, and the full production table. It does not store grids,
tiles, cubes, SEG-Y, or generated HTML payloads.

## Limitations

### What is the biggest migration limitation?

Some code, docs, tests, or habits may still assume old root-level `Data/` and
`App/` paths. Current behavior should be instance-based. Use Y1 for
demo examples and private engineering instance only for selected-instance work.

### What is the biggest UI limitation?

Many Bokeh pages are still fixed desktop layouts. A robust responsive strategy
needs careful implementation without breaking callbacks.

### What is the biggest data limitation?

Many modules depend on specific file formats and column names. More explicit
schema validation is needed.

### What is the biggest deployment limitation?

Local build paths and Linux server paths can differ. A local rebuild does not
prove the deployed Linux server is updated.

### What is the biggest performance limitation?

Large standalone Bokeh pages, dense widget trees, many glyphs, labels, and
large workbook/grid processing can affect build and browser performance.

## Improvement Strategy

### What should be improved first for maintainability?

Strengthen manifest validation, keep docs current, and continue moving durable
behavior into generator/runtime source rather than generated output.

### What should be improved first for UI?

Add shared design tokens/helpers, improve menu and side-panel consistency, then
approach responsive layout page by page.

### What should be improved first for database?

Add importers and tests for additional domain tables, while keeping query
safety, heavy-file references, and the compact/full production split.

### What should be improved first for AI workflows?

Route AI queries through approved context builders, repository functions, and
validated database reads. Preserve traceability.

### What is the current private engineering instance AI/DB state?

private engineering instance has the database backend enabled for selected-instance runtime testing and
the AI Lab can be enabled for selected-instance testing. Y1 remains available
as the demo instance for AI Lab and database demonstrations.

## Interview Questions

The questions below are written from a job-interview stance. A strong candidate
should answer with ownership boundaries, verification steps, tradeoffs, and
known limitations.

### How would you explain the generator pattern?

The generator is shared application code. It reads one manifest at a time and
builds a field-specific app. This prevents each field from becoming a fork of
the application.

### How would you debug a missing generated page?

Check the manifest output path and module state, validate the instance, rebuild
the app, inspect builder output, and verify the generated file under
the selected `instances/<field>/App/` folder. Use `instances/y1/App/` for
demos and `instances/private engineering instance/App/` only for selected-instance checks.

### How would you debug shifted tiles?

Check tile URL pattern, tile provider, CRS settings, tile shift, grid shift,
datum pipeline, real tile file availability, and whether the current app was
rebuilt and deployed.

### How would you make a UI change safely?

Read the UI handoff, edit generator/runtime source, preserve Bokeh callbacks,
rebuild the instance, inspect the generated page, and run validation/QC if the
change affects maps, layout, or shared behavior.

### How would you add a new module?

Add the page generator and source logic, add manifest module/output support,
wire it into `main.py` and the menu, validate instance behavior, rebuild, and
document the module contract.

### How would you add a Text-to-SQL agent later?

Build it outside direct database access. Load schema context, generate a
candidate SELECT/WITH query, validate through the DB API, execute only through
the safe select endpoint, summarize returned rows, and record the user
question, SQL, validation result, row count, and timing in query history.

### Walk me through every place you would change the instance name.

I would start in `fieldviewer.instance.json`: `instance.id`,
`instance.name`, `instance.description`, and usually `viewer.file_title`. If
the change affects docs or screenshots, I would update the documentation
references for the selected instance. Then I would run `validate_instance.py`
and rebuild the selected instance so generated metadata and page titles are
refreshed.

### How would you change the CRS for a new field?

I would not touch browser JavaScript first. I would update `crs.grid`,
`crs.grid_name`, `crs.tile`, `crs.tile_name`, and the QGIS-compatible pipeline
or datum settings in the manifest. Then I would validate, rebuild, inspect map
alignment, and run QC. I would also verify that source wells, grids, polygons,
and tiles are actually in the CRS declared by the manifest.

### Why is changing `crs.tile` different from changing `crs.grid`?

`crs.grid` is the engineering/source coordinate system for wells, grids, and
field data. `crs.tile` is the display coordinate system required by web map
tiles, usually Web Mercator. Mixing these responsibilities can make maps look
right visually while breaking engineering coordinate truth.

### How would you add a new production file for a field?

I would put the file under the instance `Data/` folder and update
`inputs.production.workbook`. If timeline uses the same file, I would update
`inputs.timeline.workbook` too. Then I would validate, rebuild, inspect the
production and timeline pages, and run DB import/smoke tests if the database
production summary depends on that source.

### How would you make a module appear as planned but unavailable?

I would use the manifest rather than editing generated menu HTML. Set the
module `enabled` state according to whether the page should be generated, and
set `modules.<name>.menu_state` to `dimmed` for an unavailable visible card or
`hidden` if it should not appear. Then rebuild and inspect `menu.html`.

### What is the difference between `paths.tiles_dir` and `tiles.url_template`?

`paths.tiles_dir` is the server-side disk location for tile files.
`tiles.url_template` is the browser-facing URL used by Bokeh. They must point
to the same deployment reality, but they serve different sides of the request.
For portable deployment, the URL should usually be relative to the app origin.

### How would you switch a build to ESRI imagery for a demo without changing the manifest?

Set `FIELDVIEWER_TILE_PROVIDER=esri_world_imagery` for that shell, rebuild the
selected instance, then remove the environment variable. That produces an ESRI
build without making ESRI the persistent manifest default. I would verify the
required attribution is visible.

### What would you do if a new grid appears in the folder but not in the UI?

I would check `inputs.subsurface.zmap_files`, `Data/ZmapGrids/Zmap_Groups.txt`,
and `inputs.subsurface.packaged_grid_index`. Then I would run the rebuild flow
so grid packaging regenerates `App/grids/grids_index.json`. If it still fails,
I would inspect the grid parser output and generated page payload.

### How do you decide whether to edit the manifest or Python source?

If the change is field-specific, such as data paths, labels, module states,
CRS, tiles, and instance outputs, edit the manifest or instance files. If the
change affects behavior across instances, such as page generation, callbacks,
data readers, server routing, or UI components, edit generator/runtime source.

### Why is hand-editing generated HTML a bad fix?

Generated HTML is output. It will be overwritten on rebuild and cannot scale to
other instances. A durable fix belongs in the manifest, generator source, or
runtime server code depending on ownership.

### How would you prepare a version for release or review?

I would validate and rebuild the selected instance, check that labels,
screenshots, database rows, AI Lab context, maps, tiles, and generated pages are
complete, and confirm the generated output matches that selected instance.

### What does `server.default_home_output` control and why is it useful?

It tells the server which key from `outputs` should be served as the home page.
This keeps default routing manifest-driven. For example, `"menu"` means `/`
can open `App/menu.html` without hardcoding a filename in server logic.

### How would you debug a broken database page?

First check `database.enabled`, `database.path`, and the menu/page output.
Then run `init_db.py`, `smoke_test_db.py`, and the readiness tool if text-to-SQL
context is involved. I would inspect API responses from `/api/db/health` and
confirm that only safe read/query paths are exposed.

### Why is SQLite acceptable here, and where would it stop being enough?

SQLite is simple, local, portable, and good for instance metadata, catalogs,
annotations, query history, and summaries. It becomes insufficient when the
system needs concurrent multi-user writes, centralized governance, large-scale
shared access, or enterprise authentication and auditing.

### How would you explain the UI redesign constraints to a frontend engineer?

The app is generated Bokeh/Flask, not a React SPA. The redesign must preserve
Bokeh callbacks, data sources, tools, maps, charts, and exports. Shell and
sidebar styling can improve, but plot canvases need to stay readable and light
unless a verified plot theme replaces them.

### What are the most important performance bottlenecks?

Large standalone Bokeh HTML, dense widget trees, many glyphs and labels, grid
packaging, contour extraction, workbook parsing, and browser rendering for
large maps/charts. I would profile before refactoring and reduce data volume or
precompute summaries where the workflow allows it.

### What is your testing strategy after changing generation options?

Validate the manifest, rebuild the affected instance, inspect generated pages,
run QC for map/CRS/grid/shared behavior changes, run DB smoke/readiness tests
for database changes, and verify the specific page or export affected by the
change.

### If a user says the map is wrong after deployment, what exact boundary do you check first?

I separate source, generated output, and deployed server state. I check whether
the manifest changed, whether the instance was rebuilt, whether the generated
`App/` folder was copied to the server, whether tile folders match
`paths.tiles_dir`, and whether the browser is requesting the intended tile URL
from the intended host.


