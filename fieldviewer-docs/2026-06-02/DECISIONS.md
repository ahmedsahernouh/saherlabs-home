> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Design Decisions

**Purpose**: Log of design decisions made during refactoring to maintain project context and rationale.

Historical note: this is a cumulative log. Early decisions may describe the
pre-instance root-level `Data/` and `App/` layout. Use `AGENTS.md`,
`README.md`, and `docs/HANDOVER.md` for current workflow guidance.

Current privacy note: private engineering instance is the active engineering instance. Use Y1 for demo builds and examples.

---

## Phase 1: Minimal Refactor Skeleton

**Date**: 2026-01-16

### Decision 1: Immutable Legacy Reference

**Rationale**: The original `legacy/Zmap_to_HTML_V2.py` works perfectly and contains 2,063 lines of complex Bokeh code with 25+ features. Any refactoring carries regression risk.

**Decision**:
- Keep `legacy/Zmap_to_HTML_V2.py` **immutable** (never modify)
- Copy to `src/legacy/legacy_viewer.py` for Phase 1 wrapper
- Use as regression test baseline (compare generated HTML outputs)

**Alternatives Considered**:
- âŒ Modify original in-place: high risk, no rollback
- âŒ Use git for versioning only: harder to compare side-by-side

---

### Decision 2: Data Folder at Project Root

**Rationale**: User provided `Data/` folder containing input files (ZMAP grids, wells CSV, polygons, GeoTIFF imagery, production data).

**Current 2026-05-07 note**: this was correct for the early refactor. The
current private engineering instance workflow has moved field data into the instance container:
`instances/private engineering instance/Data/`. New fields should use their own
`instances/<field>/Data/` folder.

**Decision**:
- Keep `Data/` at project root level: `[local FieldViewer workspace]\Data\`
- Easy access for both legacy and refactored code
- Separate from deployment files (`App/`)

**Alternatives Considered**:
- âŒ Move to `App/data/`: confusing, mixing input data with deployment artifacts
- âŒ Embed in `src/data/`: data is not source code

---

### Decision 3: Phased Refactoring with Acceptance Gates

**Rationale**: 2,000+ line monolith with no tests. "Big bang" rewrite is too risky.

**Decision**:
- **5 phases**: Skeleton â†’ Config/IO â†’ Layers/UI â†’ Tiles â†’ Deployment
- **Acceptance checks** after each phase (manual testing against feature inventory)
- **User approval required** before advancing to next phase
- **Full file outputs** (not snippets) to avoid partial refactor issues

**Alternatives Considered**:
- âŒ All-at-once rewrite: high risk, hard to debug regressions
- âŒ TDD approach: no existing tests to start from

---

### Decision 4: Shift Configuration Centralization (Phase 2)

**Rationale**: Current code has hard-coded `GRID_SHIFT_X/Y` (0, 0) and `SAT_SHIFT_X/Y` (17, 55). User stated these are **trial-and-error** values that change frequently.

**Decision** (for Phase 2):
- Create `src/config.py` with:
  ```python
  GRID_SHIFT_X = 0.0  # meters, applied to grid plotting
  GRID_SHIFT_Y = 0.0
  TILE_SHIFT_X = 0.0  # meters, applied to tile layer (Phase 4)
  TILE_SHIFT_Y = 0.0
  SAT_SHIFT_X = 17.0  # meters, applied to satellite overlay
  SAT_SHIFT_Y = 55.0
  ```
- Phase 1: Keep hard-coded (no behavior change)
- Phase 2: Extract to config file

**Rationale**: Avoid "magic numbers" scattered across codebase; enable runtime adjustment without code edits.

---

### Decision 5: Module Boundaries

**Rationale**: Need clear separation of concerns for maintainability.

**Decision** (for Phases 2-3):
- `io/`: Pure data loading (ZMAP, GeoTIFF, CSV) â†’ returns Python objects (numpy arrays, dataframes)
- `crs/`: Coordinate transforms (UTM â†” WebMercator) + shift application
- `layers/`: Bokeh layer builders (grid, contours, wells, etc.) â†’ returns ColumnDataSource + renderers
- `ui/`: Bokeh widgets (controls, callbacks, layout) â†’ returns Bokeh models
- `tools/`: Interactive tools (distance, path, cursor) â†’ returns event handlers
- `app/`: Entrypoint orchestration

**Principle**: Each module has clear **inputs** and **outputs**. Minimize coupling.

**Alternatives Considered**:
- âŒ Feature-based modules (e.g., `wells_module.py` with IO + rendering): tight coupling, harder to test
- âŒ Flat structure (all in `app/`): same maintainability issues as monolith

---

### Decision 6: Static HTML Output (No Server-Side Bokeh)

**Rationale**: Legacy approach generates single self-contained HTML file (~460MB). User wants deployment on localhost:8000 for testing, later Linux server.

**Current 2026-05-07 note**: static HTML is still the model, but outputs are
now written to the selected instance `App/` folder, for example
`instances/private engineering instance/App/`.

**Decision**:
- Continue using `bokeh.io.save()` (not `bokeh serve`)
- Output: static HTML with embedded JavaScript
- Tiles: referenced via URL (e.g., `http://localhost:8000/tiles/{Z}/{X}/{Y}.png`)
- Server: simple HTTP file server (Python `http.server` or Flask)

**Advantages**:
- No Bokeh server runtime dependencies
- Easy deployment (just HTML + tiles)
- Works offline (except tiles)

**Alternatives Considered**:
- âŒ Bokeh Server: requires Python runtime on deployment server, adds complexity
- âŒ Convert to Leaflet/OpenLayers: complete rewrite, loses Bokeh ecosystem

---

### Decision 7: Preserve All UI Elements

**Rationale**: User explicitly stated "never re-introduce removed UI panels" and "do not remove sidebar controls".

**Decision**:
- **No UI removals** without explicit user approval
- Document all controls in `FEATURES.md`
- If new features added (e.g., tile toggle), append to controls sidebar

**Enforcement**: Manual checklist in acceptance tests includes "Left sidebar controls" section.

---

### Decision 8: XYZ Tile Scheme (Not TMS)

**Rationale**: User specified `gdal2tiles --profile=mercator --xyz` which uses XYZ origin (top-left = 0,0,0).

**Decision** (for Phase 4):
- Tile URL template: `http://{HOST}:{PORT}/tiles/{Z}/{X}/{Y}.png`
- **No Y-axis inversion** (XYZ scheme, not TMS)
- Verify with `gdal2tiles` output structure

**Alternatives Considered**:
- âŒ TMS scheme: requires Y = 2^Z - 1 - Y conversion, incompatible with user's tiles

---

### Decision 9: Aspect Ratio Preservation

**Rationale**: Legacy code has complex aspect ratio logic to prevent box zoom distortion. User stated "not a priority, but do not regress".

**Decision**:
- **Preserve existing aspect ratio callbacks unchanged** in Phase 1-3
- Do not modify `match_aspect=True` or aspect correction JavaScript
- Only touch if tiles integration (Phase 4) breaks it

**Risk Mitigation**: Aspect ratio behavior tested in manual acceptance checklist.

---

### Decision 10: Code Formatting (Full Files Only)

**Rationale**: User explicitly requested "No line-by-line instructions; when modifying a file, output the FULL updated file content."

**Decision**:
- All code edits: output complete file contents
- Use `write_to_file` or `replace_file_content` with full replacements
- **Never** use partial snippets or "insert at line X" instructions

**Rationale**: Avoids merge conflicts, ensures consistency, easier for user to review.

---

## 2026 Instance And Basemap Decisions

**Date**: 2026-05-07

### Decision 11: Generator And Field Instances Are Separate Ownership Domains

**Rationale**: FieldViewer needs to be reusable across fields with different
data, settings, maps, CRS declarations, and deployment folders.

**Decision**:
- Central generator owns `src/`, `tools/`, `docs/`, `generator/`, dependencies,
  and the future Builder MCP.
- Each field owns a `fieldviewer.instance.json`, source data, instance settings,
  generated `App/`, and deployment/runtime artifacts.
- private engineering instance currently lives under `instances/private engineering instance/`.
- Y1 currently lives under `instances/y1/` and is the demo instance
  for demo workflows.
- private engineering instance remains documented as the active engineering instance.
- New fields should be created as new instance folders instead of hard-coding
  new paths into generator code.

### Decision 12: Local Tiles Remain Default, ESRI World Imagery Is A Build Option

**Rationale**: The current production behavior depends on server-stored/local
tiles, but users also need an option to generate the real app with live ESRI
World Imagery.

**Decision**:
- `tiles.provider = "local"` remains the private engineering instance manifest default.
- `FIELDVIEWER_TILE_PROVIDER=esri_world_imagery` can override the selected
  instance for a single build.
- A field can make ESRI persistent by setting
  `tiles.provider = "esri_world_imagery"` in its manifest.
- The generated tile toggle must identify ESRI as powered by Esri.
- Required ESRI attribution is:
  `Powered by Esri | Sources: Esri and imagery providers`.

### Decision 13: ESRI Uses Cached Tiled MapServer URL

**Rationale**: The ArcGIS `MapServer/export` BBox path avoided unavailable tile
messages but was too slow for normal zoom/pan behavior. The cached tiled service
is much faster and good enough when max zoom is capped.

**Decision**:
- Use `WMTSTileSource` with:
  `https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{Z}/{Y}/{X}`.
- Keep ArcGIS REST placeholder order as level/row/column:
  `{Z}/{Y}/{X}`.
- Use `tiles.esri_max_zoom`, defaulting to `17`, to avoid ESRI gray
  "Map data not yet available" placeholders at excessive zoom.
- Do not use the slower BBox export endpoint for the actual app.

### Decision 14: Basemap Provider Does Not Own CRS

**Rationale**: The earlier standalone ESRI test showed that bypassing the
existing QGIS-compatible transform path can introduce datum-style misalignment.

**Decision**:
- Engineering data remain authoritative in `EPSG:23033`, ED50 / UTM Zone 33N.
- Web Mercator `EPSG:3857` remains display-only for web tiles.
- The existing FieldViewer `CRSManager` / QGIS-compatible pipeline remains the
  authoritative projection path.
- Browser-side projection mirrors remain UI/readout helpers only.
- Tile shift remains controlled by the selected config and is not changed by
  selecting ESRI.

---

## Future Decisions (To Be Logged)

- Phase 2: CRS transformation approach (pyproj vs manual formulas)
- Phase 3: Callback organization strategy (single file vs per-feature)
- Phase 4: Tile layer renderer choice (WMTSTileSource vs custom)
- Phase 5: Server framework (http.server vs Flask vs Nginx)

---

**Last Updated**: 2026-05-07 (Instance split and ESRI basemap option)

