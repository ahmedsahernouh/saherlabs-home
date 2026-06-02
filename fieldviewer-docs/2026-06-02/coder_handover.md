> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Coder Handover

Updated: 2026-05-29

## Current State

FieldViewer is a Python-generated Bokeh/Flask engineering web application with
standalone browser interactivity. The current architecture separates the
central generator from field-specific instances.

Repo root:

```text
[local FieldViewer workspace]
```

Active private engineering instance instance:

```text
instances/private engineering instance/fieldviewer.instance.json
instances/private engineering instance/Data/
instances/private engineering instance/App/
```

Demo instance:

```text
instances/y1/fieldviewer.instance.json
instances/y1/Data/
instances/y1/App/
```

Privacy rule:

- private engineering instance is the active engineering instance.
- Y1 is the demo instance used for demo builds and examples.
- Keep private engineering instance data paths, generated pages, screenshots, and operational details documented when they are needed for engineering handover.

The worktree is dirty and mid-migration. Do not revert tracked deletions or
generated-file movement unless explicitly asked.

## Programming Languages, Frameworks, And Libraries

Primary languages and file formats:

- Python: generator, data loading, CRS handling, database adapter, Flask
  runtime, build tools, validation tools, and most page builders.
- JavaScript: Bokeh `CustomJS` callbacks, standalone page interactivity,
  widget behavior, map-layer toggles, chart filtering, exports, AI Lab browser
  interactions, and UI state management.
- HTML/CSS: generated menu page, global shell styling, responsive layout
  wrappers, dashboard fragments, and embedded page chrome.
- JSON: instance manifests, generated grid packages, AI context payloads,
  database schema context exports, deployment manifests, and API payloads.
- SQL: SQLite schema creation, safe SELECT execution, semantic metadata tables,
  query examples, and Text-to-SQL readiness checks.
- PowerShell/batch: local Windows workflow, deployment helpers, and server
  launch scripts.

Core Python frameworks and libraries:

- Bokeh: generated standalone interactive pages, figures, widgets, layouts,
  glyphs, legends, hover tools, selection tools, and `CustomJS` callbacks.
- Flask and Flask-CORS: local/runtime web server and `/api/*` JSON routes.
- pandas and NumPy: workbook/CSV parsing, production/timeline/test/ESP data
  shaping, well tables, grid preparation, and numeric arrays.
- SQLite via Python `sqlite3`: optional database backend, semantic metadata,
  query history, and safe read API.
- pyproj: CRS transformation and QGIS-compatible projection pipelines.
- rasterio: GeoTIFF/grid raster input handling where available.
- matplotlib and scikit-image: grid package rendering support and contour
  extraction.
- Pillow, PyMuPDF, openpyxl, and pywin32: completion image/PDF/Excel extraction
  and Windows Office automation paths.
- OpenAI Python SDK: optional backend-only AI Lab client. AI features must stay
  behind approved context and route boundaries.

Browser/runtime stack:

- Generated pages are mostly standalone Bokeh HTML with embedded data and
  JavaScript callbacks.
- The Flask server serves generated `instances/<field>/App/` files, static
  assets, local tiles, Data Parser routes, ESP payload routes, AI routes, and
  optional DB API routes.
- Bokeh plot canvases remain the engineering display surface; custom HTML/CSS
  should style shell/menu/panels without corrupting map or chart readability.

Data and AI stack:

- Instance data remains file-based for heavy artifacts: grids, tiles, images,
  completion assets, workbooks, and generated HTML.
- SQLite stores structured metadata, summaries, semantic schema descriptions,
  relationships, examples, query history, and safe AI-visible views.
- Text-to-SQL readiness is implemented as database foundation only. The LLM
  agent itself should be built later and must call schema-context, validation,
  and safe-select APIs rather than SQLite directly.

## Source Ownership

Central generator owns:

- `src/`
- `tools/`
- `docs/`
- `generator/`
- dependency files

Field instance owns:

- `fieldviewer.instance.json`
- instance `Data/`
- instance `config/`
- generated `App/`
- deployment/runtime artifacts

Durable behavior belongs in generator source or the manifest. Generated HTML is
output.

## Entry Points

Important source files:

- `src/config.py`: instance-aware path, module, CRS, tile, database, and output
  configuration.
- `src/app/main.py`: site builder that generates the app pages and menu.
- `src/app/server.py`: Flask runtime server.
- `src/app/pages/menu.py`: generated menu page.
- `src/legacy/legacy_viewer.py`: main Bokeh surface/subsurface map engine.
- `src/app/pages/timeline.py`: timeline page builder.
- `src/app/pages/production.py`: production analysis page builder.
- `src/app/pages/field_status_dashboard.py`: field-status dashboard builder.
- `src/app/pages/database.py`: generated database test page.
- `src/app/routes/db_api.py`: database JSON API routes.
- `src/db/`: optional database adapter, schema, validator, repository,
  semantic metadata, schema context, query history, examples, safe views, and
  Text-to-SQL readiness checks.

Important tools:

- `tools/validate_instance.py`
- `tools/rebuild_site.py`
- `tools/qc_regression_suite.py`
- `tools/init_db.py`
- `tools/smoke_test_db.py`
- `tools/load_db_from_instance.py`
- `tools/export_db_schema_context.py`
- `tools/evaluate_text_to_sql_readiness.py`

## Build And Verification

Validate private engineering instance:

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
```

Validate Y1:

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
```

Rebuild private engineering instance:

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Rebuild Y1:

```powershell
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

Run QC:

```powershell
python tools\qc_regression_suite.py
```

Run server:

```powershell
python src\app\server.py
```

Open:

```text
http://127.0.0.1:8000/menu.html
http://127.0.0.1:8000/FieldViewer.html
```

The server is long-running by design. Do not treat it as a build command.

Database readiness checks:

```powershell
python tools\init_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
python tools\load_db_from_instance.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
python tools\export_db_schema_context.py --instance-config instances\private engineering instance\fieldviewer.instance.json --out instances\private engineering instance\App\db_schema_context.json --force
python tools\smoke_test_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\evaluate_text_to_sql_readiness.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Use `--force` for offline initialization/export tasks when a database is
intentionally disabled in a manifest. Runtime API access requires
`database.enabled=true`.

## Instance Contract

The manifest controls:

- selected instance identity
- path base and input/output folders
- module enablement and menu state
- generated output filenames
- default home output
- public/home URL for QR codes through `server.url`
- database settings
- demo/AI Lab disclosure settings
- CRS settings
- alignment settings
- processing settings
- viewer settings
- tile provider settings

Path resolution is relative to `paths.base_dir` and the manifest directory when
paths are not absolute.

For docs, demos, screenshots, and engineering handover, keep the selected
instance context explicit. private engineering instance and Y1 examples can both remain documented.

## Configuration And Variable Reference

The main variable reference is `docs/INSTANCE_CONFIG.md`. A coder should know
which layer owns each kind of change:

| Variable class | Primary location | Example | Source owner | Verification |
| --- | --- | --- | --- | --- |
| Instance identity | `fieldviewer.instance.json` -> `instance.*` | `instance.name = "Y1 Demo FieldViewer"` | Instance manifest | Validate and rebuild selected instance. |
| Demo/documentation behavior | `demo.*`, documentation policy | `demo.is_demo_instance = true` | Instance manifest plus docs | Confirm the selected instance context is documented clearly. |
| Data roots | `paths.*` | `paths.data_dir = "Data"` | Instance manifest | `validate_instance.py` checks resolved paths. |
| Input files | `inputs.*` | `inputs.wells.wells = "Data/Y1_Well_ID.csv"` | Instance manifest and instance data | Validate, rebuild, inspect page output. |
| Generated files | `outputs.*` | `outputs.production = "App/FieldViewer_production.html"` | Instance manifest | Rebuild and check `instances/<field>/App/`. |
| Server home route | `server.default_home_output` | `"menu"` | Instance manifest plus `src/app/server.py` | Start server and check `/`. |
| Demo URL | `server.url` | Y1 public or local URL | Instance manifest plus menu page | Rebuild and verify QR card/link target. |
| Module availability | `modules.*` | `modules.esp.enabled = false` | Instance manifest plus menu/page generation | Validate menu and generated outputs. |
| Display defaults | `inputs.display.settings_file` and the settings file | `config/settings.txt` | Instance config file | Rebuild and inspect controls. |
| CRS | `crs.*`, `src/crs/transformers.py`, `src/config.py` | `crs.grid = "EPSG:32640"` | Manifest plus CRS code | Validate, rebuild, run QC. |
| Alignment | `alignment.*` | `tile_shift.x = 0.0` | Instance manifest | Visual map check and QC. |
| Grid generation | `processing.*`, grid input files, `tools/build_grid_packages.py` | `contour_interval = 10` | Manifest plus generator tools | Rebuild packages and inspect grid index/map. |
| Viewer behavior | `viewer.*`, page builders, `src/legacy/legacy_viewer.py` | `vector_display_mode = "flat_utm"` | Manifest plus generator source | Rebuild and inspect generated HTML/map. |
| Tiles | `tiles.*`, `src/app/routes/static_assets.py`, tile folder | `tiles.url_template = "/tiles_y1_demo/{Z}/{X}/{Y}.png"` | Manifest, server, deployment | Check real tile URL and generated page. |
| Database | `database.*`, `src/db/`, DB tools | `database.path = "Data/fieldviewer.db"` | Manifest plus DB source | `init_db.py`, `smoke_test_db.py`, readiness tool. |
| UI design | `docs/UI_DESIGN_HANDOFF.md`, page builders, layout helpers | side-panel styling, responsive sizing | Generator source | Rebuild Y1, inspect pages, run QC if maps are affected. |
| AI Lab context | `demo.*`, `src/ai/`, generated context files | `show_ai_lab_demo_controls = true` | Manifest plus AI source | Rebuild and test AI Lab route. |

Important rule: if the change should survive regeneration, put it in the
manifest or generator source. Do not hand-edit generated HTML as the durable
fix.

## Module Surface

Current active Y1 demo modules include:

- subsurface
- timeline
- production
- completions
- well testing
- field status dashboard
- AI Lab
- database

private engineering instance may include additional engineering modules such as ESP. Keep those
details documented when they are needed for engineering handover.

As of this handover, the private engineering instance manifest has the database backend enabled for
selected-instance DB API testing, while AI Lab is disabled and dimmed in the private engineering instance
menu. Y1 remains the demo instance for AI Lab demonstrations.

Menu states are controlled by `modules.<name>.menu_state` with supported values
`active`, `dimmed`, and `hidden`.

## CRS And Basemap Rules

Current CRS:

- engineering CRS: `EPSG:23033`
- display/tile CRS: `EPSG:3857`
- datum transform: manifest pipeline consumed through the Python CRS path
- tile shift: currently `0.0 / 0.0`

Do not replace the authoritative CRS path with browser-only projection logic.

Current local tile URL:

```text
/tiles_DH_sat/{Z}/{X}/{Y}.png
```

ESRI World Imagery URL:

```text
https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{Z}/{Y}/{X}
```

Required ESRI attribution:

```text
Powered by Esri | Sources: Esri and imagery providers
```

## UI Architecture And Constraints

FieldViewer uses generated Bokeh layouts and some custom HTML/CSS. The menu is
custom HTML generated from Python. Core analysis pages are Bokeh layouts with
figures, widgets, CustomJS callbacks, and generated standalone HTML.

Read `docs/UI_DESIGN_HANDOFF.md` before UI/theme/responsive work.

Key UI implementation files:

- `src/app/pages/menu.py`
- `src/app/components/layout_utils.py`
- `src/legacy/legacy_viewer.py`
- `src/app/pages/timeline_controls.py`
- `src/app/pages/timeline_figures.py`
- `src/app/pages/production_controls.py`
- `src/app/pages/production_figures.py`

Rules:

- Preserve the real Bokeh app and callbacks.
- Do not replace generated pages with static mockups.
- Keep shell/sidebar styling separate from plot canvas styling.
- Keep main map and key map white or very light unless an approved, verified
  plot theme replaces them.
- Keep export behavior tied to visible or selected state as documented by the
  page workflow.
- Rebuild generated HTML after source changes.

## Database Architecture

The database module is optional infrastructure for metadata and future AI
workflows. SQLite is the implemented backend. Use the instance that matches the
selected database workflow.

Source roles:

- `src/db/base.py`: adapter interface.
- `src/db/sqlite_adapter.py`: SQLite implementation.
- `src/db/schema.py`: deterministic table creation.
- `src/db/query_validator.py`: SELECT/WITH safety gate.
- `src/db/repository.py`: public database interface.
- `src/db/semantic_schema.py`: table/column/relationship metadata seed data.
- `src/db/schema_context.py`: compact AI schema context builder and snapshot
  helper.
- `src/db/query_history.py`: query history/audit logging for safe reads.
- `src/db/query_examples.py`: example natural-language questions and expected
  SQL.
- `src/db/data_loader.py`: instance-data loading helpers.
- `src/db/views.py`: safe AI-readable SQLite views.
- `src/db/text_to_sql_readiness.py`: readiness checks for DB/Text-to-SQL
  foundations.
- `src/app/routes/db_api.py`: JSON endpoints.
- `src/app/pages/database.py`: generated browser test page.

The database stores metadata, references, annotations, compact production
summaries, the full imported production table, and AI query history. Heavy
geoscience files such as grids, cubes, tiles, SEG-Y, and generated HTML remain
on disk.

Production tables:

- `production_summary`: compact, normalized rate/pressure/water-cut rows for
  common production questions and legacy examples.
- `production_full`: complete imported production source rows with normalized,
  SQL-friendly column names such as `wellname`, `uwi`, `res_name`, `date`,
  `daily_oil_bbl`, `monthly_oil_bbl`, `oil_cum_bbl`, `water_cum_bbl`,
  `gas_cum_mscf`, injection columns, ratios, and status metadata.
- `v_production_full`: AI-visible safe view over `production_full`.

Important API endpoints:

- `GET /api/db/health`
- `GET /api/db/tables`
- `GET /api/db/schema/<table_name>`
- `GET /api/db/schema-context`
- `GET /api/db/examples`
- `POST /api/db/validate-sql`
- `POST /api/db/select`
- `GET /api/db/query-history?limit=50`

Text-to-SQL safety requirements:

- only single `SELECT` or `WITH` statements
- default `LIMIT` added when missing
- write/admin SQL rejected
- dangerous keywords rejected, including INSERT, UPDATE, DELETE, DROP, ALTER,
  CREATE, REPLACE, TRUNCATE, ATTACH, DETACH, PRAGMA, VACUUM, EXEC, and MERGE
- hidden semicolon/multiple-statement and dangerous-comment attacks rejected
- tables marked `is_ai_visible=0` rejected for AI-facing SQL
- arbitrary writes not exposed
- controlled updates require allowlisted table and column settings
- query attempts logged with status, message, row count, execution time, and
  optional user question
- query-history writes are best-effort/asynchronous so SELECT responses do not
  block on disk commits during demos

Safe Text-to-SQL flow:

```text
User question
-> LLM generates candidate SQL from schema context
-> /api/db/validate-sql validates it
-> /api/db/select executes only if safe
-> result table is returned
-> LLM summarizes the result
-> db_query_history records the trace
```

The LLM must never directly access SQLite and must never execute arbitrary
write SQL. Write operations should remain controlled functions only.

## Known Technical Limits

Instance migration:

The repo is mid-migration from root-level `Data/` and `App/` assumptions to
`instances/<field>/`. Code or tests that assume root paths need careful review.

Instance privacy:

private engineering instance is the active engineering instance. Documentation can retain both Y1 and private engineering instance details until a separate publication policy is required.

Bokeh layout:

Many analysis pages still use fixed desktop dimensions. Responsive behavior is
a known design and implementation gap.

Generated output:

Generated HTML can become stale or be overwritten. Source-level changes must be
rebuilt.

CRS and tiles:

CRS, tile ordering, datum transforms, and alignment settings are high-risk
areas. Avoid casual rewrites.

Data contracts:

Production, timeline, completions, and status workflows depend on specific
workbook/sheet/column conventions. These need better machine-readable
validation over time.

Database:

The current database layer is a strong local SQLite foundation with semantic
metadata, safe SELECT APIs, query history, and full production records. It is
not yet a full multi-user enterprise database implementation.

AI Lab:

AI workflows need explicit approved data paths, traceability, and safe query
interfaces before being treated as operational automation. The database is now
ready for future Text-to-SQL integration, but the actual LLM SQL agent has not
been created yet.

## Performance Bottlenecks

- large generated standalone Bokeh HTML
- dense Bokeh widget trees
- fixed large map/chart canvases
- grid packaging and contour extraction cost
- local tile availability and serving behavior
- production workbook parsing
- browser performance for many glyphs, labels, and callbacks
- database import work for full production tables can take time when reading
  Excel sources; `init_db.py` should stay fast and schema-focused, while
  `load_db_from_instance.py` is the explicit heavier load step

## Recommendations

Functionality:

- add a guided instance creation tool
- expand manifest validation by module and file schema
- add clearer data-contract docs for each module
- extend database importers/tests for additional domain tables while preserving
  the current compact and full production imports
- connect AI Lab only through approved schema-context, validation,
  repository/query interfaces, and result summarization paths
- keep module enablement and menu state fully manifest-driven

UI:

- introduce shared design tokens and Bokeh layout helpers
- improve side-panel hierarchy and spacing
- create responsive patterns for map, timeline, production, and dashboard pages
- preserve light plot canvases while improving shell styling
- add clearer active/disabled/focus states

Performance:

- profile large standalone pages
- reduce unnecessary glyphs and labels when possible
- prefer lazy or filtered data views where Bokeh allows it
- cache or precompute expensive summaries
- keep heavy artifacts on disk and store references in database metadata

Testing:

- keep `validate_instance.py` as the first check
- rebuild before judging generated artifacts
- run QC for CRS/map/generated-output changes
- add focused smoke tests for database API and generated page availability
- add regression checks for key export headers and membership files where
  export workflows change

## Technical Interview Study Notes

Be prepared to explain:

- why generator/instance separation matters
- how manifest-driven paths and modules work
- why generated HTML is output, not source
- how CRS is handled and why browser-only projection is insufficient
- how Bokeh CustomJS enables standalone interactivity
- how to preserve callbacks during UI redesign
- why SQLite is a reasonable first database backend
- how query validation reduces text-to-SQL risk
- how schema context prepares LLMs without exposing secrets or raw private
  files
- how to validate and rebuild an instance
- what the main current bottlenecks are and how to improve them

