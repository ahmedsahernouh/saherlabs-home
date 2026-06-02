> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Handover

Updated: 2026-05-22

Use this file for a short orientation. Use `docs/RECOVERY_HANDOVER.md` for a
longer recovery checklist.

For any coding assistant handoff, read `AGENTS.md` first.
For Linux redeploys, use `docs/LINUX_DEPLOYMENT_README.md`.

## Current Source Of Truth

- Repo: `[local FieldViewer workspace]`
- Current instance manifest: `instances/private engineering instance/fieldviewer.instance.json`
- Current instance data: `instances/private engineering instance/Data/`
- Current generated app: `instances/private engineering instance/App/`
- Demo instance: `instances/y1/fieldviewer.instance.json`
- Documentation rule: keep complete private engineering instance and Y1 guidance unless a separate publication policy is requested.

- Central generator code: `src/`
- Build/validation tools: `tools/`
- Generator metadata and future Builder MCP: `generator/`
- Current UI/theme/responsive design brief: `docs/UI_DESIGN_HANDOFF.md`

The private engineering instance field is now an application instance. It should be rebuilt from the
central generator and the private engineering instance manifest, not from old root-level `Data/` and
`App/` assumptions.

Current worktree caution:

- the repo is dirty and includes a migration away from old root `Data/` and
  `App/` content toward `instances/`
- do not revert those deletions or generated moves unless the user explicitly
  asks

## Minimal Restart

Validate:

```powershell
python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
```

Validate the Y1 demo instance:

```powershell
python tools\validate_instance.py instances\y1\fieldviewer.instance.json
```

Rebuild with default local/server-stored tiles:

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Rebuild the Y1 demo instance:

```powershell
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

Rebuild with ESRI World Imagery:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

Run the server only when interactive/runtime behavior is needed:

```powershell
python src\app\server.py
```

Open:

```text
http://127.0.0.1:8000/menu.html
http://127.0.0.1:8000/FieldViewer.html
```

Verified on 2026-05-07:

- `tools\validate_instance.py` passes
- `tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json` passes
- `tools\qc_regression_suite.py` passes with `FAIL=0, WARN=0`

## Current ESRI Basemap Option

Local/server-stored tiles remain the default provider in the private engineering instance manifest.
ESRI World Imagery is now a supported build option for the real app.

ESRI settings:

- provider: `esri_world_imagery`
- URL: `https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{Z}/{Y}/{X}`
- attribution: `Powered by Esri | Sources: Esri and imagery providers`
- label: `ESRI World Imagery (Powered by Esri)`
- max zoom: `17`

The ESRI option changes only the basemap. It does not change `CRSManager`, the
QGIS-compatible pipeline, engineering CRS, display CRS, or tile shifts.

Current surface-map behavior:

- the map page exposes both `Show ESRI World Imagery` and
  `Show XYZ/local tiles`
- default state is ESRI ON and XYZ/local OFF
- if both are ON, XYZ/local tiles render above ESRI
- FieldViewer overlays remain above both basemaps

## CRS Summary

- Engineering CRS: `EPSG:23033`, ED50 / UTM Zone 33N
- Display/tile CRS: `EPSG:3857`, Web Mercator
- Authoritative transform: existing FieldViewer `CRSManager` / QGIS pipeline
- Current tile shift: `0.0 / 0.0`

Do not implement authoritative coordinate conversion in browser-only code.

## Files To Read First

1. `AI_HANDOVER.md`
2. `docs/RECOVERY_HANDOVER.md`
3. `docs/INSTANCE_CONFIG.md`
4. `docs/GENERATOR_INSTANCE_SPLIT.md`
5. `docs/UI_DESIGN_HANDOFF.md` for UI/theme/responsive work
6. `src/config.py`
7. `src/app/main.py`
8. `src/legacy/legacy_viewer.py`

## UI Design Handoff

`docs/UI_DESIGN_HANDOFF.md` was added on 2026-05-22 as a single-file export for
a UI designer LLM agent. It documents the current FieldViewer visual design,
page layouts, responsive gaps, Bokeh/Flask constraints, and what a designer
should return for implementation.

For coding agents, treat that file as design context and implementation
requirements. Persistent UI changes still belong in source generator/runtime
files such as `src/app/pages/menu.py`, `src/app/components/layout_utils.py`,
`src/legacy/legacy_viewer.py`, `timeline_controls.py`, `timeline_figures.py`,
`production_controls.py`, and `production_figures.py`.

Do not replace the real Bokeh app with a static mockup. Keep the map, timeline,
production chart, export workflows, and callbacks intact. Shell/sidebar styling
can change, but the main map and key map should remain white or very light
unless the user explicitly approves a different readable plot theme.

## Operational Cautions

- Generated HTML should be rebuilt from source generator code.
- `src/app/server.py` is supposed to keep running.
- Do not revert dirty worktree changes unless explicitly requested.
- Keep field-specific input/settings changes inside the selected instance
  manifest and instance folder when possible.


