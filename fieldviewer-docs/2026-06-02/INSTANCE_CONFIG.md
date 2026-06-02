> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Instance Configuration

Updated: 2026-05-29

`fieldviewer.instance.json` is the source of truth for a generated FieldViewer
field instance. The current private engineering instance instance is:

```text
instances/private engineering instance/fieldviewer.instance.json
```

private engineering instance is the active engineering instance. The Y1 demo instance is:

```text
instances/y1/fieldviewer.instance.json
```

The central generator reads one selected instance manifest, resolves paths
relative to that instance, then builds the runtime app into the instance `App/`
folder.

## Instance Selection

Use the default current private engineering instance instance:

```powershell
python tools\rebuild_site.py
```

Use an explicit instance:

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Use another field/app instance:

```powershell
python tools\rebuild_site.py --instance-config instances\new_field\fieldviewer.instance.json
```

Use the Y1 demo instance:

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

Direct environment variable form:

```powershell
$env:FIELDVIEWER_INSTANCE_CONFIG = "instances\new_field\fieldviewer.instance.json"
python src\app\main.py
Remove-Item Env:\FIELDVIEWER_INSTANCE_CONFIG
```

Validate before building:

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
```

For a self-contained instance folder, keep `paths.base_dir` as `"."`. Then
paths such as `Data/...`, `App/...`, and `config/settings.txt` resolve inside
that instance folder.

## Variable Reference Table

Use this table when creating, reviewing, or changing an instance. Keep both Y1
and private engineering instance details documented when they are useful for engineering handover.

| What to change | Manifest location | Example | Effect | How to change safely |
| --- | --- | --- | --- | --- |
| Instance ID | `instance.id` | `"y1"` | Short technical instance key used in docs, logs, and generated metadata. | Edit the manifest. Keep it stable after release. |
| Instance name | `instance.name` | `"Y1 Demo FieldViewer"` | Human-readable name shown in documentation, generated context, and app metadata. | Edit the manifest, then validate and rebuild. |
| Instance description | `instance.description` | `"Imaginary UAE demo instance derived from demo inputs."` | Explains purpose and instance status. | Keep Y1 descriptions clear. Keep private engineering instance details documented when needed for engineering handover. |
| Demo status | `demo.is_demo_instance` | `true` | Marks whether the instance is intended for demo-style disclosure and AI Lab traceability. | Set according to the selected instance workflow. |
| Base directory | `paths.base_dir` | `"."` | Root used to resolve relative instance paths. | Keep `"."` for self-contained `instances/<field>/` folders. |
| Input data directory | `paths.data_dir` | `"Data"` | Folder containing input CSV, XLSX, grids, settings inputs, and source data. | Put field inputs under `instances/<field>/Data/`; update only if layout changes. |
| Generated app directory | `paths.app_dir` | `"App"` | Folder where generated HTML and runtime assets are written. | Keep generated output under `instances/<field>/App/`; do not edit generated HTML as source. |
| Output directory | `paths.output_dir` | `"App/output"` | General generated output folder for page-specific artifacts. | Change only when deployment or module layout changes; rebuild afterward. |
| Tile directory | `paths.tiles_dir` | `"../../tiles_y1_demo"` or `"../../tiles_DH_sat"` | Server-side disk folder for local tiles. | Confirm the folder exists on the target server. Keep Y1 and private engineering instance tile folders separate when privacy matters. |
| Grid source folder | `paths.grid_source_dir` | `"Data/ZmapGrids"` | Folder read by grid packaging. | Put ZMAP grids here or update the path. Rebuild grid packages after changing. |
| Grid output folder | `paths.grid_output_dir` | `"App/grids"` | Folder containing packaged grid JSON/PNG/runtime artifacts. | Treat as generated output. Rebuild instead of hand-editing. |
| Data Parser folder | `paths.dataparser_dir` | `"App/dataparser"` | Runtime/generated folder for Data Parser and ESP payload artifacts. | Change with care because ESP and parser pages may reference it. |
| Display settings file | `inputs.display.settings_file` | `"config/settings.txt"` | Controls default off controls, keymap limits, bubble columns, and hover columns. | Edit the settings file for display defaults; validate and rebuild. |
| Page title/info file | `inputs.display.title_file` | `"Data/title.txt"` | Provides title/sidebar information for generated pages. | Keep CRS text consistent with manifest CRS. Rebuild after editing. |
| ZMAP files | `inputs.subsurface.zmap_files` | `"Surface": "Data/ZmapGrids/XNS_DEM.dat"` | Declares subsurface/grid layers available to the map. | Add labels and file paths, then run validation and rebuild. |
| Grid groups file | `inputs.subsurface.grid_groups` | `"Data/ZmapGrids/Zmap_Groups.txt"` | Groups grids for map dropdowns and page organization. | Keep labels synchronized with declared grid files. |
| Packaged grid index | `inputs.subsurface.packaged_grid_index` | `"App/grids/grids_index.json"` | Generated index consumed by the app after grid packaging. | Do not hand-edit except for diagnosis; rebuild packages. |
| Default polygon file | `inputs.subsurface.default_polygon` | `"Data/Y1_polygons_keymap.txt"` | Main polygon/key map boundary source. | Use the Y1 polygons for demo builds. Validate coordinates and CRS. |
| Keymap definition | `inputs.subsurface.keymap` | `"Data/KeyMapContents.txt"` | Lists key-map polygon/object layers and colors. | Keep file references relative to the instance data folder. |
| Line segment folder/glob | `inputs.subsurface.line_segments_dir`, `inputs.subsurface.line_segments_glob` | `"Data"`, `"Lines*.txt"` | Controls optional line/fault segment loading. | Use glob patterns carefully; unexpected files can appear as layers. |
| Wells file | `inputs.wells.wells` | `"Data/Y1_Well_ID.csv"` | Main well table with UWI and coordinates. | Required columns include well ID and coordinates. Validate before rebuild. |
| Stations file | `inputs.wells.stations` | `"Data/Y1_Station_ID.csv"` | Station/location table used by map workflows. | Keep CRS consistent with the wells file. |
| Well symbols file | `inputs.wells.symbols` | `"Data/WellSymbols.txt"` | Maps well status/category to marker styling. | Change to adjust symbol appearance by status without editing generator code. |
| Well lists workbook | `inputs.wells.well_lists` | `"Data/Well_Lists.xlsx"` | Defines saved well groups/lists for UI selection. | Keep sheet/column structure compatible with loader expectations. |
| Production source | `inputs.production.workbook` | `"Data/Y1_Production.csv"` | Source for production profile page and database production loading. | CSV and Excel sources can differ by instance; confirm expected columns before rebuild/import. |
| Timeline source | `inputs.timeline.workbook` | `"Data/Y1_Production.csv"` | Source for timeline page. | Usually matches production source; can be separate if needed. |
| Well testing summary | `inputs.well_testing.summary_csv` | `"Data/Y1_well_test_summary_normalized.csv"` | Source for well-testing page. | Date formats must be parseable; rebuild and inspect the generated payload if dates look wrong. |
| Completion source folder | `inputs.completions.source_dir` | `"Data/Completions"` | Source folders/files for completion images and extracted ranges. | If source files are newer than assets, refresh extraction before release. |
| Completion assets | `inputs.completions.assets_dir`, `inputs.completions.manifest` | `"App/completions_assets"` | Generated completion images and manifest. | Treat as generated/runtime assets; regenerate through extractor workflow when needed. |
| ESP payload folder | `inputs.esp.current_payload_dir` | `"App/dataparser/current/esp_payload"` | ESP page payload source. | Optional for instances where ESP is disabled, such as Y1. |
| Field status inputs | `inputs.field_status_dashboard.today_info`, `inputs.field_status_dashboard.cum_info` | `"Data/today_info.xlsx"`, `"Data/cum_info.xlsx"` | Operational dashboard inputs. | Blank files should produce zero-value output rather than fabricated values. |
| Derived well summary | `inputs.derived.well_summary_from_production` | `"Data/Y1_Well_Summary_From_Prod.csv"` | Generated or cached summary derived from production input. | Regenerate when production source changes. |
| Menu output | `outputs.menu` | `"App/menu.html"` | Generated main menu page. | Normally keep as `App/menu.html`; server default can point to it. |
| Page outputs | `outputs.subsurface`, `outputs.timeline`, etc. | `"App/FieldViewer.html"` | Generated HTML file names for modules. | Change when file naming/deployment conventions change; rebuild and update links. |
| Default home page | `server.default_home_output` | `"menu"` | Selects which configured output the server serves at `/`. | Use manifest setting rather than hardcoding server routes. |
| Public/home URL | `server.url` | `"http://127.0.0.1:8001/menu.html"` | URL used by QR cards or demo entrypoints. | Use the URL for the selected instance and deployment target. |
| Module enabled flag | `modules.<name>.enabled` | `"database": {"enabled": true}` | Controls whether a module is generated and available. | Disable modules when inputs are missing or unavailable for the selected build. |
| Menu label | `modules.<name>.label` | `"Production Analysis"` | User-facing module name. | Keep labels concise and aligned with the selected instance. |
| Menu state | `modules.<name>.menu_state` | `"active"`, `"dimmed"`, `"hidden"` | Controls menu visibility and availability. | Use `hidden` for unavailable modules in selected builds. |
| Database enabled flag | `database.enabled` | `true` or `false` | Enables optional DB runtime/API behavior. | Keep runtime access disabled unless intentionally configured and tested. |
| Database backend/path | `database.backend`, `database.path` | `"sqlite"`, `"Data/fieldviewer.db"` | Chooses DB backend and storage location. | SQLite is current. Keep DB inside the instance for portability. |
| Database query limits | `database.default_limit`, `database.max_limit` | `100`, `1000` | Controls safe result sizes for DB/API/Text-to-SQL workflows. | Keep conservative limits for browser and LLM use. |
| Database AI-visible tables | `database.ai_visible_tables`, `database.blocked_tables` | `["v_well_locations"]`, `["audit_log"]` | Controls what schema context and future AI SQL can see. | Expose only useful views for the selected workflow; block audit or sensitive runtime tables as needed. |
| Engineering CRS | `crs.grid`, `crs.grid_name` | `"EPSG:32640"` for Y1, `"EPSG:23033"` for private engineering instance | Source coordinate system for engineering data. | Change only when source data CRS changes; validate maps carefully. |
| Display/tile CRS | `crs.tile`, `crs.tile_name` | `"EPSG:3857"`, `"WebMercator"` | Web display/tile coordinate system. | Usually keep Web Mercator for web basemaps. |
| Datum/projection pipeline | `crs.qgis_pipeline_forward`, `crs.datum_helmert` | QGIS-compatible pipeline string | Authoritative transform from engineering CRS to display CRS. | Do not replace with browser-only projection logic. Test roundtrip/QC after changing. |
| Grid/satellite/tile shift | `alignment.grid_shift`, `alignment.satellite_shift`, `alignment.tile_shift` | `{ "x": 0.0, "y": 0.0 }` | Manual alignment offsets. | Use only when justified by visual/QC evidence. Record why values changed. |
| Grid display processing | `processing.apply_flipud`, `processing.negate_z`, `processing.contour_interval` | `true`, `true`, `10` | Controls grid orientation, sign convention, and contour extraction. | Rebuild grid packages and inspect generated maps after changing. |
| Viewer title | `viewer.file_title` | `"Y1 Demo FieldViewer"` | Browser/page title and map title context. | Use a title that matches the selected instance. |
| Vector display mode | `viewer.vector_display_mode` | `"flat_utm"` for Y1, `"exact"` for private engineering instance | Controls geometry display behavior for vector overlays. | Preserve known per-instance exceptions; verify generated HTML and map geometry. |
| Tile provider | `tiles.provider` | `"local"` or `"esri_world_imagery"` | Chooses default basemap provider for generated map. | ESRI can also be set temporarily with `FIELDVIEWER_TILE_PROVIDER`. |
| Local tile URL | `tiles.url_template` | `"/tiles_y1_demo/{Z}/{X}/{Y}.png"` or `"/tiles_DH_sat/{Z}/{X}/{Y}.png"` | Browser URL for local tiles. | Keep URL relative to app origin for deployment portability. |
| ESRI URL/label/attribution | `tiles.esri_url_template`, `tiles.esri_label`, `tiles.esri_attribution` | `MapServer/tile/{Z}/{Y}/{X}` and `Powered by Esri...` | ESRI basemap configuration and required credit. | Keep attribution visible whenever ESRI imagery is available or selected. |
| Tile zoom range | `tiles.min_zoom`, `tiles.max_zoom`, `tiles.esri_max_zoom` | `0`, `20`, `17` | Controls tile request zoom levels. | Cap ESRI at a safe max zoom to avoid unavailable-tile placeholders. |

## Common Change Examples

### Rename The Demo instance

Edit:

```json
{
  "instance": {
    "id": "y1",
    "name": "Y1 Demo FieldViewer",
    "description": "demo instance."
  },
  "viewer": {
    "file_title": "Y1 Demo FieldViewer"
  }
}
```

Then run:

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

### Add A New Grid Layer

Edit `inputs.subsurface.zmap_files`:

```json
{
  "inputs": {
    "subsurface": {
      "zmap_files": {
        "Surface": "Data/ZmapGrids/XNS_DEM.dat",
        "NewLayer": "Data/ZmapGrids/NewLayer.dat"
      }
    }
  }
}
```

Then update `Data/ZmapGrids/Zmap_Groups.txt` if the layer should appear in a
specific group, validate, and rebuild.

### Hide A Module From The Menu

Edit the module state:

```json
{
  "modules": {
    "esp": {
      "enabled": false,
      "label": "ESP",
      "menu_state": "hidden"
    }
  }
}
```

Use this pattern when a workflow is unavailable for the selected build.

### Change The Default Home Page

Edit:

```json
{
  "server": {
    "default_home_output": "menu"
  }
}
```

The value should match a key under `outputs`, not a raw filename.

### Temporarily Build With ESRI Imagery

Use an environment override without editing the manifest:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

Make ESRI persistent only by editing `tiles.provider`.

## Main Sections

- `paths`: base folders for input data, generated app files, grids, tiles, and
  Data Parser output.
- `inputs`: source files and folders used by the generators.
- `outputs`: generated HTML files.
- `modules`: module enable/disable switches and menu labels.
- `demo`: optional demo-disclosure switches for prototype pages such as AI Lab.
- `crs`: source CRS, tile CRS, and datum transform settings.
- `alignment`: grid, satellite, and tile shifts.
- `processing`: grid packaging and contour generation settings.
- `viewer`: default palette, title, and viewer defaults.
- `tiles`: basemap provider, URL templates, zoom limits, labels, and
  attribution.

### Module Menu Options

Each `modules.<name>` block may define:

```json
{
  "enabled": true,
  "label": "FieldViewer AI Lab",
  "menu_state": "active"
}
```

`menu_state` is optional. Supported values are:

- `active`: show the module as a normal clickable menu card.
- `dimmed`: show the module as a disabled/dimmed menu card.
- `hidden`: omit the module from the menu.

This is currently used by the AI Lab menu card so instances can expose, dim, or
hide the prototype without changing generated HTML by hand.

### Demo Disclosure Options

Instances can enable extra demo-oriented controls without changing generated
HTML by hand:

```json
{
  "demo": {
    "is_demo_instance": true,
    "enabled": true,
    "show_ai_lab_demo_controls": true,
    "reveal_methodology": true,
    "reveal_capabilities": true,
    "reveal_data_sources": true,
    "reveal_source_references": true,
    "reveal_ai_interaction_explanation": true
  }
}
```

When enabled, AI Lab responses can include traceability details such as initial
data sources, final generated context files sent to the LLM, compact line or
paragraph references from that final context, and approved tool/script sources
for generated plots or maps.

## Tile Provider Contract

The `tiles` section controls the basemap used by the generated surface map.
Local/server-stored tiles remain the default for the private engineering instance manifest.

Current fields:

```json
{
  "provider": "local",
  "url_template": "http://{host}:{port}/tiles_DH_sat/{Z}/{X}/{Y}.png",
  "label": "XYZ Tiles",
  "attribution": "Tile Server",
  "min_zoom": 5,
  "max_zoom": 20,
  "esri_url_template": "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{Z}/{Y}/{X}",
  "esri_label": "ESRI World Imagery (Powered by Esri)",
  "esri_attribution": "Powered by Esri | Sources: Esri and imagery providers",
  "esri_max_zoom": 17
}
```

Supported provider values:

- `local`: uses `tiles.url_template` and local/server-hosted tile files.
- `esri_world_imagery`: uses the ESRI World Imagery tiled MapServer URL and
  visible ESRI attribution.

The ESRI URL order is important:

```text
MapServer/tile/{Z}/{Y}/{X}
```

ArcGIS REST expects `tile/level/row/column`, while Bokeh placeholders are
`Z = level`, `Y = row`, and `X = column`.

## Local Versus ESRI Builds

Build with the manifest default:

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Build the same instance with ESRI World Imagery for this shell/session:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

The environment override does not edit the manifest. This means the generated
HTML can reflect ESRI while `fieldviewer.instance.json` still says `local`.
If ESRI should be the persistent default for a field, edit the manifest value:

```json
"provider": "esri_world_imagery"
```

## CRS And Alignment Rules

The tile provider must not redefine the engineering coordinate system.

Current private engineering instance CRS settings:

- Engineering CRS: `EPSG:23033`, ED50 / UTM Zone 33N
- Display/tile CRS: `EPSG:3857`, Web Mercator
- Authoritative transform: existing FieldViewer `CRSManager` / QGIS-compatible
  pipeline
- Current tile shift: `TILE_SHIFT_X = 0.0`, `TILE_SHIFT_Y = 0.0`

Web Mercator is only the display CRS required by web map tiles. Do not replace
the existing Python CRS path with direct browser-only projection logic.

## Builder MCP Contract

The Builder MCP should treat the instance JSON as the source of truth and avoid
hard-coding private engineering instance paths. Its first responsibilities should be:

- inspect a candidate field folder,
- map discovered files into this JSON structure,
- validate required inputs per enabled module,
- preserve or select the tile provider explicitly,
- ensure ESRI attribution is present when ESRI services are selected,
- run `tools/validate_instance.py <file>`,
- run `tools/rebuild_site.py --instance-config <file>`,
- report missing inputs, disabled modules, selected basemap provider, and
  generated outputs.


