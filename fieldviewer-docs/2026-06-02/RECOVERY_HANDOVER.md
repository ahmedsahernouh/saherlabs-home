> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Recovery Handover

Date: 2026-05-22

Purpose: use this file to recover project context quickly if chat history is lost again.

## 2026-05-22 current update

The repo now includes a designer-facing UI/theme/responsive handoff:

- `docs/UI_DESIGN_HANDOFF.md`

Use it when a UI designer LLM or coding agent needs the current FieldViewer UI
inventory, constraints, responsive requirements, and implementation handoff.
It is documentation only; generated HTML should still be rebuilt from source
generator/runtime files.

Important UI implementation rules:

- preserve the real Bokeh app, callbacks, map tools, charts, and export flows
- do not replace pages with static mockups unless explicitly asked
- keep shell/sidebar styling separate from map/chart canvases
- keep the main map and key map white or very light unless the user explicitly
  approves a different readable plot theme

## 2026-05-07 current update

The project has since moved to an instance-aware generator workflow.

- Current private engineering instance manifest: `instances/private engineering instance/fieldviewer.instance.json`
- Current private engineering instance data: `instances/private engineering instance/Data/`
- Current private engineering instance generated app: `instances/private engineering instance/App/`
- Demo manifest: `instances/y1/fieldviewer.instance.json`
- private engineering instance is the active engineering instance. Use Y1 for demo builds and examples.
- Central generator/source: `src/`, `tools/`, `docs/`, `generator/`
- Linux deployment can keep the whole instance at
  `[internal Linux deployment path] engineering instance/` while root-level server
  code stays under `[internal Linux deployment path]` and shared tiles stay at
  `[internal Linux deployment path]`.
- Use `docs/LINUX_DEPLOYMENT_README.md` when updating the Linux server and
  confirming which `App/` folder is actually being served.
- The private engineering instance app can be rebuilt with default local/server-stored tiles or with
  ESRI World Imagery by setting `FIELDVIEWER_TILE_PROVIDER=esri_world_imagery`
  for the build.
- The actual private engineering instance app was regenerated on 2026-05-07 with the ESRI option enabled
  during the build.
- `tools/qc_regression_suite.py` was updated on 2026-05-07 to use instance-aware
  paths instead of the obsolete root `App/` and `Data/` layout.
- The surface map now supports both ESRI and XYZ/local basemaps together in the
  same page, with ESRI ON by default and XYZ/local OFF by default.

Prefer these commands over older root `App/` and `Data/` assumptions:

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

For demo output, use Y1:

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

For ESRI:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

## Current project state

- Project root: `[local FieldViewer workspace]`
- Repo remote: `https://github.com/ahmedsahernouh/FieldViewer.git`
- Branch: `master` tracking `origin/master`
- Main entrypoint: `src/app/main.py`
- Main viewer engine: `src/legacy/legacy_viewer.py`
- Server entrypoint: `src/app/server.py`
- Grid packager: `tools/build_grid_packages.py`
- Regression QC: `tools/qc_regression_suite.py`
- Instance validator: `tools/validate_instance.py`
- Instance rebuild command: `tools/rebuild_site.py --instance-config <manifest>`
- Current private engineering instance generated output root: `instances/private engineering instance/App/`
- Current demo output root: `instances/y1/App/`
- Current UI/design brief: `docs/UI_DESIGN_HANDOFF.md`

## What was reconstructed in this session

- The repo path was initially confused with `OpendTect`. The correct project is its own repo under `Code\FieldViewer`.
- Git was blocked after the Windows reinstall by safe-directory protection. It was fixed with:
  - `git config --global --add safe.directory D:/Libya_Machine_28082025/Code/FieldViewer`
- The Windows Python environment was incomplete at first. Missing packages were installed, including:
  - `bokeh`
  - `rasterio`
  - `pyproj`
  - `flask`
  - `flask-cors`
  - `scikit-image`
  - `openpyxl`

## Important fixes made in this session

### 1. Optional GeoTIFF startup hardening

Problem:
- `src/app/main.py` imported `read_wells_csv` from `data_io`
- `src/data_io/__init__.py` eagerly imported `geotiff_reader`
- `geotiff_reader` imported `rasterio`
- This made the whole app fail at startup on machines without `rasterio`, even when GeoTIFF overlays were not used

Fix:
- `src/data_io/__init__.py` now treats GeoTIFF support as optional and raises a clear error only if GeoTIFF functions are actually used

### 2. Polygon reader warning cleanup

Problem:
- `src/data_io/polygon_reader.py` emitted a docstring escape warning for `\s+`

Fix:
- the docstring was corrected to use `\\s+`

### 3. QC warning cleanup

Problem:
- `tools/qc_regression_suite.py` reported stale `faults.json` transform signatures
- it also warned about callback guardrail detection because the QC pattern expected a different tick-label sync variant

Fix:
- `tools/build_grid_packages.py` now writes `transform_signature` into packaged `faults.json`
- `tools/qc_regression_suite.py` now accepts the current padded tick-label synchronization pattern
- grid packages were rebuilt after that change

### 4. Maps default visibility change

User-requested change:
- in the maps app, the red `Lines` overlay should be off by default

Fix:
- `Lines` was added to the defaults-off list in the settings file used at that
  time; in the current private engineering instance workflow, check `instances/private engineering instance/config/settings.txt`

## Current verified behavior

### QC status

Command:

```powershell
python tools\qc_regression_suite.py
```

Result:

- `FAIL=0`
- `WARN=0`
- `QGIS CSV match` is still `SKIP` unless a reference CSV is supplied
- this result is now from the instance-aware QC path, not the old root-path QC

### Full site build status

Historical direct-builder command used:

```powershell
$env:MPLCONFIGDIR='C:\Users\lmkapp05\AppData\Local\Temp\matplotlib-fieldviewer'
python src\app\main.py
```

Current preferred instance-aware command:

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Result:

- Full build succeeds
- Generated pages:
  - `instances/private engineering instance/App/FieldViewer.html`
  - `instances/private engineering instance/App/FieldViewer_timeline.html`
  - `instances/private engineering instance/App/FieldViewer_production.html`
  - `instances/private engineering instance/App/FieldViewer_completions.html`
  - `instances/private engineering instance/App/FieldViewer_well_testing.html`
  - `instances/private engineering instance/App/FieldViewer_esp.html`
  - `instances/private engineering instance/App/menu.html`
- Surface map basemap behavior:
  - ESRI World Imagery ON by default
  - XYZ/local tiles OFF by default
  - if both are enabled, XYZ/local tiles render above ESRI

### Server behavior

Command:

```powershell
python src\app\server.py
```

Important:
- this is a long-running Flask server by design
- if a future session looks â€œstuck for 50 minutesâ€, first check whether `server.py` is simply still running
- `main.py` is the builder and should finish
- `server.py` is supposed to stay alive

## Current settings that matter

From `instances/private engineering instance/config/settings.txt` for the current private engineering instance instance:

- defaults off:
  - `Reverse palette`
  - `Show XY Plot Grid`
  - `Grid`
  - `Contours`
  - `Show contour labels`
  - `Lines`
  - `Distance tool active`
  - `Path tool active`
  - `Enable bubbles`
- `keymap_limit` is active
- bubble metric columns are active
- hover-box column lists are active

## Current environment notes

- Python imports verified successfully:

```powershell
python -c "import openpyxl, bokeh, rasterio, pyproj; print('ok')"
```

- Matplotlib cache permissions may be noisy on this Windows profile if `MPLCONFIGDIR` is not set
- safest build invocation on this machine:

```powershell
$env:MPLCONFIGDIR='C:\Users\lmkapp05\AppData\Local\Temp\matplotlib-fieldviewer'
python src\app\main.py
```

## Working tree note

The repo is not clean. There are both user/data changes and generated artifacts in the working tree. Do not assume the current diff is disposable.

Examples may include:
- modified tracked data/code files
- generated `instances/private engineering instance/App/grids/*/overlay.png`
- untracked or instance-local `instances/private engineering instance/App/completions_assets/`
- instance-local `instances/private engineering instance/Data/Completions/`
- untracked manuals:
  - `FieldViewer_Manager_Overview_with_Screenshots.docx`
  - `FieldViewer_Users_Manual_with_Screenshots.docx`

Rule for future recovery:
- do not revert anything unless the user explicitly asks

## Fast recovery checklist for the next assistant

1. Confirm you are in `[local FieldViewer workspace]`
2. If Git complains after a Windows/user change, re-add safe directory:

```powershell
git config --global --add safe.directory D:/Libya_Machine_28082025/Code/FieldViewer
```

3. Check repo state:

```powershell
git status --short --branch
git log --oneline -5
```

4. Verify environment:

```powershell
python -c "import openpyxl, bokeh, rasterio, pyproj; print('ok')"
```

5. Run QC:

```powershell
python tools\qc_regression_suite.py
```

6. Validate and rebuild the current private engineering instance instance:

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

7. Only run the server if interactive lookup/testing is needed:

```powershell
python src\app\server.py
```

## If something breaks again

- If startup fails on imports, check package availability first
- If maps build but QC warns about grid/fault artifacts, rerun:

```powershell
python tools\build_grid_packages.py
python tools\qc_regression_suite.py
```

- If the app appears hung, distinguish:
  - `src/app/main.py`: builder, should finish
  - `src/app/server.py`: long-running server

## Key files to inspect first

- `src/app/main.py`
- `src/legacy/legacy_viewer.py`
- `src/config.py`
- `instances/private engineering instance/fieldviewer.instance.json`
- `instances/private engineering instance/config/settings.txt`
- `tools/build_grid_packages.py`
- `tools/qc_regression_suite.py`
- `tools/validate_instance.py`
- `tools/rebuild_site.py`
- `docs/UI_DESIGN_HANDOFF.md` for UI/theme/responsive redesign work
- `docs/HANDOVER.md`
- `AI_HANDOVER.md`

## ESRI basemap recovery note

The ESRI option should use cached ArcGIS MapServer tiles, not the slower export
endpoint:

```text
https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{Z}/{Y}/{X}
```

Required attribution:

```text
Powered by Esri | Sources: Esri and imagery providers
```

Local/server-stored tiles remain the manifest default unless the selected
instance is edited.

