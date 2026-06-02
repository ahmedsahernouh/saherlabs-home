> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer User Instance Q&A

Updated: 2026-05-22

## Instance Basics

### What is a FieldViewer instance?

An instance is a field-specific application package. It contains a manifest,
input data, settings, generated pages, and deployment/runtime artifacts for one
field or app configuration.

### Which instance should I use for demos?

Use Y1:

```text
instances/y1/
```

Y1 is the demo instance used for demo builds and examples.

### Where is the private engineering instance engineering instance?

```text
instances/private engineering instance/
```

The important files and folders are:

```text
instances/private engineering instance/fieldviewer.instance.json
instances/private engineering instance/Data/
instances/private engineering instance/App/
```

private engineering instance remains fully documented for engineering use.

### What is the manifest?

`fieldviewer.instance.json` is the source of truth for paths, modules, outputs,
CRS, tiles, database settings, demo settings, and viewer behavior.

### Should I use root-level `Data/` and `App/` folders?

No. Use instance paths. Use `instances/y1/` for demo work and
`instances/private engineering instance/` only for selected-instance work.

## Generation Workflow

### What command validates the Y1 demo instance?

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
```

### What command validates the private engineering instance engineering instance?

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
```

### What command rebuilds the Y1 demo instance?

```powershell
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

### What command rebuilds the private engineering instance engineering instance?

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

### What command runs the local server?

```powershell
python src\app\server.py
```

### Is `server.py` supposed to keep running?

Yes. It is a long-running Flask server. A long-running terminal does not
automatically mean the process is stuck.

### Which page should I open first?

Open the menu:

```text
http://127.0.0.1:8000/menu.html
```

## Inputs And Outputs

### What input folder does Y1 use?

```text
instances/y1/Data/
```

### What input folder does private engineering instance use?

```text
instances/private engineering instance/Data/
```

### What output folder does Y1 use?

```text
instances/y1/App/
```

### What output folder does private engineering instance use?

```text
instances/private engineering instance/App/
```

### What pages should be generated?

The current manifest defines menu, map, timeline, production, completions,
well-testing, ESP, field-status dashboard, database, and AI Lab outputs.

### What should I check after rebuilding?

Check that the expected HTML files exist, open the menu, open the main map,
test key pages, and confirm that maps, wells, grids, charts, dashboard blocks,
exports, and database page behavior match the selected instance.

## Tiles And CRS

### What basemap is the default?

Local/server-stored tiles are the manifest default.

### Can I build with ESRI World Imagery?

Yes. Use:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

### Does the ESRI override permanently edit the manifest?

No. It changes the provider for that shell/session build only.

### What attribution is required for ESRI?

```text
Powered by Esri | Sources: Esri and imagery providers
```

### What CRS should I expect?

Engineering data uses `EPSG:23033`. Web display and tiles use `EPSG:3857`.
The authoritative transform path is the existing Python/QGIS-compatible
pipeline.

### What should I do if map alignment looks wrong?

Check CRS settings, tile URL order, tile shift, grid shift, input coordinates,
and generated output. Then rebuild before judging the result.

## UI Usage

### What does the menu do?

The menu is the default entry point. It shows active modules, unavailable
modules, planned modules, and links to generated pages.

### Why do some pages still look more basic than the menu?

The menu has more custom styling. Many analysis pages are Bokeh-generated
layouts and are still being improved for consistent styling and responsive
behavior.

### What is the UI redesign goal?

To make FieldViewer more polished, consistent, and responsive while preserving
the real engineering workflows.

### Can the UI redesign replace the maps and charts with static pages?

No. Static mockups can guide design, but the generated Bokeh app and callbacks
must remain the actual application.

### Why should the map canvas stay light?

The main map and key map carry wells, contours, grids, labels, tiles, and
engineering overlays. A light canvas protects readability unless a new theme is
carefully verified.

## Database

### Is the database module active?

The current Y1 and private engineering instance manifests enable the database module with a SQLite
backend. Use Y1 for database demos.

### What is the database for?

Metadata, file references, catalog rows, annotations, audit history, compact
production summary rows, full production source rows, and future AI query
workflows.

### Which production table should I query?

Use `production_summary` or `v_production_by_well` for compact rate and
latest-date questions. Use `production_full` or `v_production_full` when the
question needs the complete source production history, including monthly
volumes, cumulative volumes, injection, reservoir/status fields, and source
well metadata.

### What is the database not for?

It is not for storing heavy grids, tiles, cubes, SEG-Y files, or generated HTML
payloads. Full production rows are small enough for SQLite and are intentionally
stored for Text-to-SQL use.

### How do I initialize the database?

```powershell
python tools\init_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\init_db.py --instance-config instances\y1\fieldviewer.instance.json
```

`init_db.py` should be fast and schema-focused. Run
`tools\load_db_from_instance.py` when DB source data needs refreshing; that step
loads the full production table and may take longer.

### How do I smoke test it?

```powershell
python tools\smoke_test_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\smoke_test_db.py --instance-config instances\y1\fieldviewer.instance.json
```

### Can users run arbitrary SQL writes?

No. The SQL validator allows controlled read queries. Writes require controlled
repository paths and allowlisted table/column settings.

## Bottlenecks And Uncertainty

### What are the biggest user-level bottlenecks?

Input file quality, required column names, CRS and tile alignment, grid
packaging, production workbook assumptions, deployment copying, and dense UI
layouts.

### What if the operational input files are blank?

Blank operational sheets can still be valid in some workflows, such as field
status dashboard generation. Do not invent values; preserve literal zero or
blank-derived output when that is the actual source state.

### What if generated pages do not match the latest source changes?

Rebuild the instance. Generated HTML may be stale if source or manifest files
changed after the last build.

### What if the server on Linux behaves differently from local Windows?

Separate the questions: which source was changed, which instance was rebuilt,
which generated files were copied, and which server code is running on Linux.

### When should I ask a developer for help?

Ask for help when validation fails, map alignment is uncertain, source columns
are unclear, generated output contradicts input data, database endpoints fail,
or UI changes appear to break map/chart interactions.


