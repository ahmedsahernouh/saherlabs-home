> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Changelog

## 2026-05-25

- Added the `production_full` SQLite table and `v_production_full` safe view so
  Text-to-SQL workflows can query the complete imported production history, not
  only compact production summaries.
- Kept `production_summary` and `v_production_by_well` for compact production
  questions and backward-compatible examples.
- Added semantic metadata and example questions for full-production queries.
- Improved database page usability with a wider results area, horizontal and
  vertical table scrolling, and a taller SQL editor.
- Improved DB read responsiveness by avoiding blocking SELECT responses on
  query-history disk writes.
- Documented that `init_db.py` is schema-focused and fast, while
  `load_db_from_instance.py` is the explicit heavier data-import step.

## 2026-05-22

- Documentation now keeps complete Y1 and private engineering instance instance guidance so both public and private repository versions retain the full technical context.

**Purpose**: Track changes made to the codebase during each phase of refactoring.

Historical note: older sections may refer to the pre-instance root-level
`Data/` and `App/` layout. Current operating guidance is in `AGENTS.md`,
`README.md`, and `docs/HANDOVER.md`.

---

## 2026-05-07: Instance-Aware Basemap Provider And Documentation Refresh

### New / Updated Capabilities

- Added instance-aware basemap provider selection.
- Kept local/server-stored tiles as the default provider.
- Added ESRI World Imagery as a selectable build option for the actual app.
- Preserved the existing FieldViewer CRSManager/QGIS-compatible CRS path.
- Preserved current engineering CRS `EPSG:23033` and display CRS `EPSG:3857`.
- Added visible ESRI attribution when ESRI is selected:
  `Powered by Esri | Sources: Esri and imagery providers`.
- Capped ESRI max zoom through `tiles.esri_max_zoom`, default `17`, to avoid
  gray unavailable ESRI tiles at excessive zoom.

### Important Commands

Default local/server-stored tile build:

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

ESRI World Imagery build:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

### Documentation Updated

- `README.md`
- `AI_HANDOVER.md`
- `docs/HANDOVER.md`
- `docs/RECOVERY_HANDOVER.md`
- `docs/INSTANCE_CONFIG.md`
- `docs/GENERATOR_INSTANCE_SPLIT.md`
- `docs/DECISIONS.md`
- `docs/FEATURES.md`
- `docs/PHASE1_FIX.md`
- `generator/README.md`
- `generator/mcp/README.md`
- `PROJECT_ARCHITECTURE.md`
- `PROJECT_REUSABILITY_PLAN.md`
- `MANAGER_OVERVIEW.md`
- `README_USERS.md`

---

## Phase 1: Minimal Refactor Skeleton (2026-01-16)

Historical note: paths in this Phase 1 section describe the initial root
`Data/` and `App/` layout. The current private engineering instance workflow uses
`instances/private engineering instance/Data/` and `instances/private engineering instance/App/`.

### New Files Created

```
docs/
  â”œâ”€â”€ FEATURES.md          # Complete feature inventory (25+ features)
  â”œâ”€â”€ DECISIONS.md         # Design decisions log (10 decisions)
  â””â”€â”€ CHANGELOG.md         # This file

src/
  â”œâ”€â”€ legacy/
  â”‚   â”œâ”€â”€ __init__.py      # Empty placeholder
  â”‚   â””â”€â”€ legacy_viewer.py # Copy of legacy/Zmap_to_HTML_V2.py (UNCHANGED)
  â”œâ”€â”€ io/
  â”‚   â””â”€â”€ __init__.py      # Empty placeholder (Phase 2)
  â”œâ”€â”€ crs/
  â”‚   â””â”€â”€ __init__.py      # Empty placeholder (Phase 2)
  â”œâ”€â”€ layers/
  â”‚   â””â”€â”€ __init__.py      # Empty placeholder (Phase 3)
  â”œâ”€â”€ ui/
  â”‚   â””â”€â”€ __init__.py      # Empty placeholder (Phase 3)
  â”œâ”€â”€ tools/
  â”‚   â””â”€â”€ __init__.py      # Empty placeholder (Phase 3)
  â””â”€â”€ app/
      â”œâ”€â”€ __init__.py      # Empty placeholder
      â””â”€â”€ main.py          # Minimal wrapper entrypoint (calls legacy function)

requirements.txt           # Python dependencies
README.md                  # Project overview
```

### Files Modified

- None (Phase 1 creates structure only)

### Behavioral Changes

- **None**: Phase 1 preserves 100% functionality by calling legacy code unchanged

### How to Use Phase 1

1. Navigate to project root: `[local FieldViewer workspace]\`
2. Install dependencies: `pip install -r requirements.txt`
3. Edit paths in `src/app/main.py` if needed (data files, output HTML name)
4. Run: `python src/app/main.py`
5. Open generated HTML in browser (e.g., `output/viewer.html`)

### Acceptance Criteria Checklist

Run through `docs/FEATURES.md` and verify all 25+ features work:
- [ ] ZMAP grid display
- [ ] Multi-grid switching
- [ ] Color palette switching
- [ ] Satellite overlay toggle
- [ ] Contours + labels
- [ ] Polygons/faults
- [ ] Wells by STATUS
- [ ] Well highlights
- [ ] Bubble map (if enabled)
- [ ] Objects
- [ ] Distance tool
- [ ] Path picking + CSV export
- [ ] Cursor crosshair + Z readout
- [ ] Overview/key map sync
- [ ] All UI controls present
- [ ] Aspect ratio preserved
- [ ] No layout regressions

**Test Data Used**: Files from `Data/` folder
- `DH_SurfaceElevation_fromSeismic.dat` (ZMAP grid)
- `DH_Well_ID.csv` (wells)
- `DH_3D_SeisBounndary.txt` (polygons)
- GeoTIFF satellite imagery (if configured)

---

## Phase 2: Extract Config + I/O (Future)

*(To be filled during Phase 2 implementation)*

### Planned Changes

- Extract `GRID_SHIFT_X/Y`, `SAT_SHIFT_X/Y`, `TILE_SHIFT_X/Y` to `src/config.py`
- Move `read_zmap_grid_full()` to `src/io/zmap_reader.py`
- Move `load_geotiff_to_bokeh_rgba_uint32()` to `src/io/geotiff_reader.py`
- Create `src/io/wells_reader.py` for CSV loading
- Create `src/io/polygon_reader.py` for TXT loading
- Update `src/app/main.py` to use new modules

### Acceptance Criteria

- Same HTML output as Phase 1
- Config file edits change behavior without code changes
- All data files load correctly

---

## Phase 3: Extract Layers + UI + Tools (Future)

*(To be filled during Phase 3 implementation)*

---

## Phase 4: XYZ Tiles + UTM Mirror (Completed 2026-02-15)

âœ… **Core Implementation**:
- Integrated internal XYZ tile basemaps (Satellite).
- Implemented the **UTM Mirror** logic: Web Mercator visualization with precise ground-UTM coordinate axes.
- Alignment shifts (`SAT_SHIFT`, `TILE_SHIFT`) for pixel-perfect data overlay.

âœ… **Picking Tool Upgrades**:
- Repaired snapping logic for wells and stations.
- Added explicit `name` attributes to sidebar inputs for reliable automated verification.
- Verified accurate Z-lookup from grids using UTM coordinates.

âœ… **Field Styling**:
- Support for `WellSymbols.txt` to define custom symbols, colors, and sizes by status.
- Legend cleanup: Polygons removed from legend to focus on point assets.

---

## Phase 4.1: Ticker & Tool Refinements (Completed 2026-02-20)

âœ… **Axis Tickers**:
- Dynamically calculated round UTM intervals (e.g., 5000m, 10000m).
- Reduced ticker density for better readability during zoom.
- Forced zero-padded fixed-precision labels (no scientific notation).

âœ… **Distance Tool**:
- Measurement unit locked to **meters** for all distances.
- Removed scientific notation from all distance displays.
- Verified 100% Euclidean correctness across the viewport.

---

## Phase 4.2: Raster Grid Fix (Completed 2026-02-21)

âœ… **Grid Data Integrity**:
- Rebuilt missing `grid_values.npy` files for grids (specifically `DH_BAHI_DEM_Corr50`) using `build_grid_packages.py`.
- Ensured that `main.py` correctly detects and loads these files for resampling.

âœ… **Parameter Forwarding**:
- Fixed a bug in the `create_viewer` wrapper in `legacy_viewer.py` where `initial_z_range`, `initial_palette`, `initial_grid`, and `contour_interval` were not being forwarded to the main builder function.
- This restores proper color mapping defaults based on the actual Z range of the data.

---

## Future Phases

### Phase 5: Advanced Modularization & Deployment
- Final extraction of business logic from `legacy_viewer.py` into specialized modules.
- Optimization of grid serialization (using Arrow or specialized binary formats).
- Production-ready deployment scripts for Linux/Windows environments.

---

**Last Updated**: 2026-05-07 (Instance-aware basemap provider and docs refresh)



