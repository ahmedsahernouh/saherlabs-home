> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Features Inventory

**Purpose**: Complete list of all features in the legacy viewer (`legacy/Zmap_to_HTML_V2.py`). This serves as the acceptance baseline - all features must work in every phase.

**Last Updated**: 2026-05-07

---

## Core Display Features

### Current Instance/Basemap Addendum

- [x] **Instance documentation policy**
  - Y1 is the demo instance used for demo builds and examples.
  - private engineering instance is an active engineering instance and remains fully documented.

- [x] **Instance-aware app generation**
  - Current private engineering instance app is built from `instances/private engineering instance/fieldviewer.instance.json`
  - private engineering instance inputs live under `instances/private engineering instance/Data/`
  - private engineering instance outputs live under `instances/private engineering instance/App/`
  - Y1 demo app is built from `instances/y1/fieldviewer.instance.json`
  - Y1 inputs live under `instances/y1/Data/`
  - Y1 outputs live under `instances/y1/App/`

- [x] **Basemap provider selection**
  - Local/server-stored tiles remain the default provider
  - ESRI World Imagery is available as a build option
  - ESRI attribution is visible when ESRI is selected:
    `Powered by Esri | Sources: Esri and imagery providers`
  - Provider selection does not change CRSManager/QGIS transform behavior

- [x] **ZMAP Grid Display**
  - Reads `.dat` files with proper header parsing
  - Handles null values (1.0E30 â†’ NaN)
  - Optional upscaling (block-averaged)
  - Optional flipud + negation for orientation

- [x] **Multi-Grid Support**
  - Switch between multiple loaded grids
  - Preserve per-grid metadata (extents, aspect ratio, Z range)
  - Dynamic contours regeneration on grid switch

- [x] **Color Mapping**
  - 4 built-in palettes: Viridis256, Inferno256, Cividis256, Turbo256
  - Palette switching (dropdown)
  - Reverse palette toggle
  - Manual Z-range adjustment (min/max inputs)

- [x] **GeoTIFF Satellite Overlay**
  - Load RGB/RGBA GeoTIFF as background layer
  - Toggle visibility (checkbox)
  - Manual X/Y shift adjustment (`SAT_SHIFT_X`, `SAT_SHIFT_Y`)
  - Correct color interpretation (handles band order)

---

## Vector Layers

- [x] **Contours**
  - Generated from grid using `matplotlib.pyplot.contour`
  - Configurable interval (default: 10 ft)
  - Toggle visibility (checkbox)
  - Black lines, 0.7pt width, 75% alpha

- [x] **Contour Labels**
  - Text labels at contour midpoints
  - Toggle visibility (separate checkbox)
  - White background, 7pt font
  - Shows elevation values (formatted as integers)

- [x] **Polygons/Faults**
  - Reads space-delimited `.txt` files
  - Columns: `Fault_name`, `X`, `Y`, `Z`, `Seg_ID`
  - Groups by `Seg_ID` and `Fault_name`
  - White multi-lines, 1.5pt width, 90% alpha
  - Toggle visibility (checkbox)

- [x] **Wells**
  - Reads CSV with required columns: `UWI`, `X`, `Y`
  - Optional `STATUS` column for categorization
  - Multiple marker types by STATUS:
    - Majority status: circle (aqua, 6px)
    - "Station" status: asterisk (red, 13px, outlined)
    - Others: triangle/square/diamond/cross/etc (colored)
  - Per-status visibility toggles (checkboxes)
  - Global wells toggle (checkbox)
  - Well labels toggle (checkbox)
  - Hover tooltips showing all well attributes

- [x] **Well Highlights**
  - Multi-select widget for well selection
  - Search/filter by substring
  - Yellow squares with red outlines (12px)
  - Clear highlights button

- [x] **Bubble Map** (optional, if `bubble_column` set)
  - Size proportional to well attribute (e.g., TD, production)
  - Percentile clamping (low/high sliders: 5-95%)
  - Optional log scale (checkbox)
  - Bubble toggle + labels toggle
  - Robust sizing (6-30px range)

- [x] **Objects**
  - User-added points with labels
  - Manual X/Y input + label text input
  - Orange stars, 12px
  - Orange labels with -10px Y offset
  - Toggle visibility (checkbox)

---

## Interactive Tools

- [x] **Distance Measurement Tool**
  - Toggle activation (checkbox)
  - Click 2 points â†’ displays distance
  - Blue cross markers (10px)
  - Dashed blue line connecting points
  - Info panel shows: P1 coords, P2 coords, distance (map units)
  - Auto-resets after 2 points

- [x] **Path Picking Tool**
  - Toggle activation (checkbox)
  - Click to add ordered points
  - Magenta circles (8px) + magenta polyline
  - Z lookup at each click point
  - Info panel shows: point count, last point XYZ
  - "Show picked path" toggle (visibility control)
  - **Clear path** button (resets points)
  - **Export path CSV** button (downloads `picked_path.csv` with columns: i, x, y, z)

- [x] **Cursor Crosshair**
  - Vertical + horizontal black lines follow mouse
  - Updates on MouseMove event
  - Synchronized with cursor info display

- [x] **Cursor Info Display**
  - Shows current cursor X, Y coordinates
  - Z lookup from active grid (nearest-neighbor)
  - Displays "outside grid" or "Z=NaN" when appropriate
  - Real-time update on mouse move

---

## UI Controls

- [x] **Left Sidebar Controls Panel**
  - Scrollable column (overflow-y: auto)
  - 380px width, bordered
  - Contains all controls (see below)

- [x] **Grid Selection**
  - Dropdown: select active ZMAP grid
  - Switches image, contours, labels, Z range, extents

- [x] **Satellite Toggle**
  - Checkbox to show/hide GeoTIFF overlay
  - Only visible if satellite loaded

- [x] **Palette Selection**
  - Dropdown: Viridis256 / Inferno256 / Cividis256 / Turbo256
  - Reverse toggle (checkbox)

- [x] **Z Range Inputs**
  - Min Z (text input)
  - Max Z (text input)
  - Updates color mapper live

- [x] **X/Y Limits Inputs**
  - X min, X max, Y min, Y max (text inputs)
  - Preserves aspect ratio when zooming programmatically

- [x] **Layer Toggles**
  - Checkboxes: Grid, Contours, Polygons, Wells, Well labels, Objects
  - Globally enable/disable layers

- [x] **Wells by STATUS Toggles**
  - Per-category checkboxes (if multiple STATUS values)
  - Only visible if >1 STATUS category

- [x] **Bubble Controls** (if bubble_column set)
  - Bubble toggle (visibility)
  - Bubble labels toggle
  - Percentile sliders (low: 0-40%, high: 60-100%)
  - Log scale toggle

- [x] **Tool Activation**
  - Distance tool toggle (checkbox with red highlight when active)
  - Path tool toggle (checkbox with red highlight when active)

- [x] **Object Creation**
  - X input, Y input, label input (text boxes)
  - "Add object" button

- [x] **Well Search & Highlight**
  - Search box (substring filter)
  - Multi-select dropdown (filtered well list)
  - "Clear well highlights" button

---

## Overview/Key Map

- [x] **Miniature Map**
  - Same grid as main map
  - Same color mapper (synchronized)
  - Aspect ratio matches main map
  - 250px base size (scaled by aspect)

- [x] **Zoom Box Overlay**
  - Red rectangle showing main map viewport
  - Synchronized with main map X/Y ranges
  - Updates on pan/zoom in main map

- [x] **Info Displays Below Key Map**
  - **Extent info**: Current X/Y ranges of main map
  - **Cursor info**: XYZ at mouse position
  - **Measurement info**: Distance tool status/results
  - **Path info**: Path tool status (point count, last point XYZ)

---

## Map Behavior

- [x] **Aspect Ratio Preservation**
  - Main map: `match_aspect=True`
  - Automatic aspect correction on X-range change
  - Prevents box zoom distortion

- [x] **Tools**
  - Pan (drag)
  - Wheel zoom (scroll to zoom)
  - Box zoom (drag rectangle)
  - Reset (restore initial view)
  - Save (download PNG)

- [x] **Active Scroll**
  - Wheel zoom is default scroll behavior

---

## Output Format

- [x] **Static HTML**
  - Single self-contained `.html` file
  - All data embedded (grid, wells, polygons, JavaScript)
  - Satellite overlay embedded as RGBA uint32 image
  - File size: ~460MB for full dataset (acceptable)
  - No server-side dependencies (pure client-side Bokeh)

---

## Data Format Support

- [x] **ZMAP `.dat` Grids**
  - Robust header parsing (handles varying formats)
  - Null value handling (1.0E30)
  - Supports nrows, ncols, xmin/xmax, ymin/ymax
  - Optional upscaling (block-averaged)

- [x] **GeoTIFF Imagery**
  - RGB or RGBA
  - Automatic color interpretation (red/green/blue/alpha bands)
  - Optional flipud + R/B swap
  - Reads bounds from rasterio

- [x] **Wells CSV**
  - Required: `UWI`, `X`, `Y`
  - Optional: `STATUS`, `TD`, and any other attributes (all shown in hover)

- [x] **Polygons TXT**
  - Space-delimited
  - Required: `Fault_name`, `X`, `Y`, `Z`, `Seg_ID`
  - Grouped by Seg_ID for multi-line rendering

---

## Styling & Polish

- [x] **CSS Enhancements**
  - Active tool checkboxes highlighted (red border, yellow background)
  - Tool titles in red bold text
  - Scrollable controls sidebar

- [x] **Title & Description**
  - HTML title (configurable via `file_title`)
  - Description text (contour interval, data sources, CRS, units)

- [x] **Number Formatting**
  - Axis labels: no decimals (NumeralTickFormatter)
  - Hover/info displays: 2 decimal places (toLocaleString)
  - Bubble labels: no scientific notation

---

## Configuration (Legacy Hard-Coded)

- [x] **Shifts**
  - `GRID_SHIFT_X`, `GRID_SHIFT_Y` (default: 0.0)
  - `SAT_SHIFT_X`, `SAT_SHIFT_Y` (default: 17, 55 in example)

- [x] **Grid Processing**
  - `upscale_factor` (None for native resolution)
  - `apply_flipud` (True to flip grid vertically)
  - Grid negation (`*-1` if flipud=True)

- [x] **Contours**
  - `contour_interval` (e.g., 10 ft)

- [x] **Bubble Map**
  - `bubble_column` (None or column name like "TD")
  - `BUBBLE_LABEL_COL` (None or column name)

---

## Total Feature Count: 25+

**Critical**: All features above must work identically in refactored code before adding new capabilities (tiles, deployment).


