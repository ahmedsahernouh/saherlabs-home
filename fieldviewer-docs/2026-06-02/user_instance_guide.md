> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer User Instance Guide

Updated: 2026-05-29

## Purpose

This guide explains what a user or project engineer needs to generate,
validate, run, and review a FieldViewer instance. It focuses on the current
instance-based architecture and documents both the Y1 demo workflow and the private engineering instance engineering workflow.

## Instance Documentation Rule

Use Y1 for demo builds and examples:

```text
instances/y1/fieldviewer.instance.json
instances/y1/Data/
instances/y1/App/
```

private engineering instance is the engineering instance:

```text
instances/private engineering instance/fieldviewer.instance.json
instances/private engineering instance/Data/
instances/private engineering instance/App/
```

Keep private engineering instance documentation complete unless a separate publication policy is required.

## Current Instance Layout

The Y1 demo instance is:

```text
instances/y1/
  fieldviewer.instance.json
  config/
  Data/
  App/
```

The private engineering instance engineering instance is:

```text
instances/private engineering instance/
  fieldviewer.instance.json
  config/
  Data/
  App/
```

Important Y1 paths:

- manifest: `instances/y1/fieldviewer.instance.json`
- input data: `instances/y1/Data/`
- generated output: `instances/y1/App/`
- generated menu: `instances/y1/App/menu.html`
- generated main map: `instances/y1/App/FieldViewer.html`

Important private engineering instance paths:

- manifest: `instances/private engineering instance/fieldviewer.instance.json`
- input data: `instances/private engineering instance/Data/`
- generated output: `instances/private engineering instance/App/`
- generated menu: `instances/private engineering instance/App/menu.html`
- generated main map: `instances/private engineering instance/App/FieldViewer.html`

Do not use old root-level `Data/` and `App/` assumptions. Use
the instance folder that matches the selected workflow.

## What Is Needed To Generate An Instance

At minimum, an instance needs:

- a `fieldviewer.instance.json` manifest
- an instance `Data/` folder containing the required input files for enabled
  modules
- instance display/settings files, such as `config/settings.txt`
- output paths under the instance `App/` folder
- correct CRS and alignment settings
- tile provider settings
- module enable/disable settings

The manifest is the source of truth. It tells the generator where to find input
data and where to write generated pages.

## What Can Be Changed

Most instance behavior can be changed in `fieldviewer.instance.json` without
editing Python source. The full variable reference is in
`docs/INSTANCE_CONFIG.md`. The most common user-level variables are:

| Change | Where | Y1 example | What it changes |
| --- | --- | --- | --- |
| Instance name | `instance.name` | `"Y1 Demo FieldViewer"` | Display name in docs, generated metadata, and context. |
| Demo/privacy flag | `demo.is_demo_instance` | `true` | Marks Y1 as suitable for demo disclosure. |
| Input data folder | `paths.data_dir` | `"Data"` | Base folder for source files under `instances/y1/`. |
| Generated app folder | `paths.app_dir` | `"App"` | Output folder for generated HTML under `instances/y1/`. |
| Tile disk folder | `paths.tiles_dir` | `"../../tiles_y1_demo"` | Local/server tile folder used by the runtime server. |
| Wells CSV | `inputs.wells.wells` | `"Data/Y1_Well_ID.csv"` | Well locations and IDs used by map, timeline, and DB imports. |
| Production source | `inputs.production.workbook` | `"Data/Y1_Production.csv"` | Production chart and production summary source. |
| Timeline source | `inputs.timeline.workbook` | `"Data/Y1_Production.csv"` | Timeline map source. |
| Well testing source | `inputs.well_testing.summary_csv` | `"Data/Y1_well_test_summary_normalized.csv"` | Well-testing page source. |
| Grid files | `inputs.subsurface.zmap_files` | `"Surface": "Data/ZmapGrids/XNS_DEM.dat"` | Available map/grid layers. |
| Generated page names | `outputs.*` | `"menu": "App/menu.html"` | HTML filenames and server output targets. |
| Default home page | `server.default_home_output` | `"menu"` | Which generated output opens at `/`. |
| Demo URL | `server.url` | public or local Y1 URL | QR card and demo entrypoint URL. |
| Enable/disable module | `modules.<name>.enabled` | `"database": {"enabled": true}` | Whether a module is generated and available. |
| Menu state | `modules.<name>.menu_state` | `"active"`, `"dimmed"`, `"hidden"` | Whether a module appears as active, unavailable, or hidden. |
| Engineering CRS | `crs.grid` | `"EPSG:32640"` | Source CRS for Y1 engineering coordinates. |
| Tile/display CRS | `crs.tile` | `"EPSG:3857"` | CRS for web map display and tiles. |
| Alignment shifts | `alignment.*_shift` | `{ "x": 0.0, "y": 0.0 }` | Manual grid/satellite/tile offsets. |
| Contour interval | `processing.contour_interval` | `10` | Generated contour spacing. |
| Viewer title | `viewer.file_title` | `"Y1 Demo FieldViewer"` | Main generated viewer title. |
| Vector display mode | `viewer.vector_display_mode` | `"flat_utm"` | Vector overlay display behavior. |
| Tile provider | `tiles.provider` | `"local"` | Default basemap provider. |
| Local tile URL | `tiles.url_template` | `"/tiles_y1_demo/{Z}/{X}/{Y}.png"` | Browser URL for local tiles. |
| ESRI attribution | `tiles.esri_attribution` | `"Powered by Esri | Sources: Esri and imagery providers"` | Required visible credit for ESRI imagery. |
| Database path | `database.path` | `"Data/fieldviewer.db"` | SQLite database file inside the instance. |

After any manifest change, run:

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

Run QC when the change touches CRS, grids, tiles, maps, generated pages, or
shared runtime behavior:

```powershell
python tools\qc_regression_suite.py
```

## Manifest Responsibilities

Each instance manifest controls:

- field identity and description
- input data paths
- generated output page paths
- default home route
- enabled modules and menu labels
- database backend settings
- demo/AI Lab disclosure behavior
- CRS settings
- grid, satellite, and tile alignment
- grid packaging behavior
- viewer settings
- local and ESRI tile settings

Paths are resolved relative to the instance base folder when `paths.base_dir`
is `"."`.

## Active Generated Pages

The Y1 and private engineering instance manifests define these generated outputs:

- `App/menu.html`
- `App/FieldViewer.html`
- `App/FieldViewer_timeline.html`
- `App/FieldViewer_production.html`
- `App/FieldViewer_completions.html`
- `App/FieldViewer_well_testing.html`
- `App/FieldViewer_esp.html`
- `App/FieldViewer_Field_Status_Dashboard.html`
- `App/FieldViewer_Database.html`
- `App/FieldViewer_AI_Lab.html`

The menu is the normal first page.

## Validate The Instance

Run validation before building:

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
```

Validation checks whether the manifest and required paths are coherent enough
for the selected instance workflow. If validation fails, fix missing or
incorrect paths before rebuilding.

## Rebuild The Instance

Run the rebuild command:

```powershell
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

This rebuilds the generated output under the instance `App/` folder. If grids,
geometry packaging, generated pages, menus, UI source, or manifest behavior
changed, rebuild before judging the result.

## Run The Local Server

Run:

```powershell
python src\app\server.py
```

This is a long-running server by design.

Open:

```text
http://127.0.0.1:8000/menu.html
http://127.0.0.1:8000/FieldViewer.html
```

Depending on the current development setup, a separate server may already be
serving an instance app on another port.

## Basemap Selection

The Y1 and private engineering instance manifest defaults are local/server-stored tiles:

```json
"provider": "local"
```

The current local tile URL pattern is:

```text
/tiles_DH_sat/{Z}/{X}/{Y}.png
```

ESRI World Imagery is also supported. To build with ESRI for the current shell
without permanently editing the manifest:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

When ESRI is visible, the app must show:

```text
Powered by Esri | Sources: Esri and imagery providers
```

## CRS And Alignment Checks

Current instance CRS rules:

- Y1 demo engineering CRS: `EPSG:32640`
- private engineering instance engineering CRS: `EPSG:23033`
- display/tile CRS: `EPSG:3857`
- current tile shift: `0.0 / 0.0`
- authoritative transform path: Python/QGIS-compatible CRS pipeline

Do not treat browser display coordinates as the source of engineering truth.
If maps look shifted or distorted, check the manifest CRS, tile settings,
alignment settings, input data, and rebuild output.

## UI Layout And Usage Expectations

The app is a multi-page engineering tool. The menu is the entry point. The
analysis pages are dense and designed for repeated field review.

Expected page behavior:

- Menu: module selection, active/dimmed/hidden states, light/dark menu toggle.
- Main map: core surface/subsurface map with controls, key map, basemap
  toggles, measurement tools, grid selection, labels, and overlays.
- Timeline: map plus time slider, metric controls, well filters, and CSV
  export.
- Production: production chart, map, well/group controls, primary/secondary
  metrics, aggregation, and CSV export.
- Field status dashboard: operational counts and status blocks.
- Database: optional metadata browser and SELECT-only query test page when
  database is enabled.

The current UI design goal is to improve visual consistency and responsive
behavior without removing engineering tools.

## UI Design Constraints For Users

- Maps and charts must remain readable.
- Main map and key map should remain white or very light unless a readable
  alternate plot theme is explicitly approved.
- Dense controls may remain desktop-oriented until responsive layout work is
  implemented.
- On small screens, future designs may use drawers, bottom sheets, stacked
  panels, tabs, or accordions.
- Static mockups are design references only; the working generated app remains
  the real source of behavior.

## Database Module

The database module is enabled in the current Y1 and private engineering instance manifests and uses
SQLite:

```json
"backend": "sqlite",
"path": "Data/fieldviewer.db"
```

The database is for metadata, file references, annotations, query history,
compact production summaries, and the full imported production table. It is
not for storing heavy grids, cubes, tiles, SEG-Y files, or generated HTML.

Production data is available in two forms:

- `production_summary`: compact normalized production rows for common
  production questions.
- `production_full` / `v_production_full`: complete imported production source
  rows with normalized SQL-friendly column names for detailed questions.

Useful commands:

```powershell
python tools\init_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\smoke_test_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\init_db.py --instance-config instances\y1\fieldviewer.instance.json
python tools\smoke_test_db.py --instance-config instances\y1\fieldviewer.instance.json
```

Use `tools\load_db_from_instance.py` only when source data or DB schema changed.
It can take longer because it imports full production rows.

The database API is designed around safe reads and controlled updates. Text SQL
must be single-statement `SELECT` or `WITH` SQL after validation.

## Bottlenecks And Critical Issues

Data completeness:

Missing input files, unexpected column names, blank operational sheets, or
inconsistent workbooks can affect generated output.

CRS and geometry:

Wrong CRS, tile order, datum transform, grid shift, or tile shift can create
misleading maps.

Generated output ownership:

Hand edits to generated HTML can be overwritten. Make persistent changes in
the generator or manifest.

Deployment:

The local Windows build and Linux server deployment layout may differ. Confirm
which files were copied and which server code is running.

UI:

Visual redesign must preserve Bokeh callbacks, exports, map tools, and chart
behavior.

Database:

The database is currently a local SQLite foundation with metadata, safe reads,
query history, compact production summaries, and full production records. It
should not be treated as a complete multi-user enterprise database layer.

## When To Rebuild Or Revalidate

Run validation when:

- the manifest changed
- paths changed
- enabled modules changed
- database config changed
- deployment layout changed

Run rebuild when:

- generator code changed
- UI source changed
- page source changed
- data changed
- grid or geometry packaging changed
- manifest output behavior changed

Run QC when:

- CRS, grid, geometry, map, generated pages, or shared runtime behavior changed

```powershell
python tools\qc_regression_suite.py
```

## User Checklist

1. Confirm the selected instance manifest.
2. Confirm the required input files exist under the instance `Data/` folder.
3. Run instance validation.
4. Rebuild the instance.
5. Open the menu and expected generated pages.
6. Check maps, tiles, grids, wells, charts, exports, dashboard, and database
   page if enabled.
7. Treat any mismatch as either a data issue, manifest issue, generator issue,
   or deployment issue before trusting the output.

