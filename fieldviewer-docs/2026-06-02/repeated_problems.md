> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# Repeated Problems

Updated: 2026-05-22

This file records mistakes that have repeated across FieldViewer work. Check it
before changing maps, CRS, generated pages, UI styling, exports, or instance
configuration.

## 1. Projection Or CRS Mismatch

Repeated problem:

- Treating Web Mercator as the engineering CRS.
- Bypassing `CRSManager` or the Python/QGIS-compatible transform path.
- Adding browser-only coordinate conversion as if it were authoritative.
- Assuming private engineering instance and Y1 share the same engineering CRS.

Correct rule:

- Engineering CRS stays instance-specific and authoritative.
- private engineering instance uses `EPSG:23033` unless its manifest is explicitly changed.
- Y1 uses `EPSG:32640` unless its manifest is explicitly changed.
- Display/tile CRS is `EPSG:3857`.
- Use the existing `CRSManager` / manifest pipeline path.

Regression checks:

- Inspect generated pages and logs for the manifest CRS values.
- Run `tools/validate_instance.py <manifest>`.
- Run `tools/qc_regression_suite.py` after map, CRS, tile, grid, or geometry
  changes.

## 2. Forgetting The UTM-First Rule

Repeated problem:

- Styling or refactoring the map as if screen coordinates were source data.
- Moving wells, polygons, labels, grids, faults, or readouts through separate
  display logic.
- Forgetting that flat-UTM/exact vector display modes are deliberate
  engineering choices.

Correct rule:

- Source geometry and readouts stay UTM-first.
- Web Mercator is only the display/tile requirement.
- Preserve the manifest-controlled `viewer.vector_display_mode`.
- Do not merge or simplify coordinate paths unless the generated output is
  verified against CRS/QC expectations.

Regression checks:

- Confirm generated HTML still contains the expected vector-mode transform
  behavior.
- Verify wells, faults, contours, labels, key map, and cursor readouts use the
  same coordinate path.

## 3. Missing Back-To-Menu Navigation

Repeated problem:

- New Bokeh pages or static test pages omit an obvious way back to `menu.html`.
- Button labels drift across pages.

Correct rule:

- Every generated app page should include a visible back/menu navigation action.
- Preferred labels are consistent, such as `Back to Apps Menu` or
  `Open Apps Menu`, unless the page already has an accepted label.
- Static prototypes should use `Menu`, not `Hub`.

Regression checks:

- Search generated HTML for `menu.html`.
- Manually open each generated page and confirm a visible menu navigation path.

## 4. Removing Or Hiding The Key Map

Repeated problem:

- Redesigns simplify the map page by removing the key map entirely.
- Mobile constraints are applied to desktop layout.

Correct rule:

- Desktop map pages should keep the key map / overview context.
- It is acceptable to hide or collapse the key map on phone layouts after user
  approval, but do not remove the desktop key map.
- Preserve extent sync and viewport-box behavior when the real Bokeh key map is
  involved.

Regression checks:

- Confirm desktop generated map pages include a key map/overview figure.
- Confirm any mobile hiding is responsive styling only, not a deleted Bokeh
  model unless explicitly approved.

## 5. Breaking Aspect Ratio Or Equal Scale

Repeated problem:

- Changing plot size or responsive behavior without preserving `match_aspect`
  and range correction.
- Letting a responsive layout stretch maps into distorted engineering geometry.
- Forcing mobile maps to `width: 100%` and an unrelated fixed/viewport height,
  which makes X scale and Y scale visually different even when the CRS is
  correct.
- Forgetting previous decisions to preserve aspect-ratio callbacks.

Correct rule:

- Main maps must preserve engineering aspect ratio and equal-scale behavior.
- Do not remove `match_aspect=True` or aspect correction JavaScript unless an
  equivalent verified mechanism replaces it.
- Responsive design must wrap or stack map panels without distorting plotted
  geometry.
- Mobile-specific CSS/JS must keep the data-range aspect equal to the actual
  rendered map frame aspect. Do not assume the desktop/source figure ratio is
  still valid after axes, legends, toolbars, or bottom-sheet controls consume
  space.

Regression checks:

- Inspect source for `match_aspect=True`, range padding, and aspect correction.
- In mobile visual QA, compare the rendered map frame ratio against the current
  x/y data-range ratio before accepting the layout.
- Compare data-range ratio to plot-frame ratio when browser testing is not
  available.
- Run QC after map sizing changes.

## 6. Editing Generated HTML Instead Of Source

Repeated problem:

- Hand-editing `instances/<field>/App/*.html`.
- Treating generated output as source of truth.
- Losing fixes on the next rebuild.

Correct rule:

- Persistent fixes belong in `src/`, `tools/`, shared components, or the
  instance manifest.
- Generated HTML is output and should be rebuilt.
- Static prototypes under `design/` are visual references only.

Regression checks:

- Rebuild the affected instance and confirm the fix survives.
- Review diffs to ensure source files changed, not only generated HTML.

## 7. Replacing The Real Bokeh App With A Static Mockup

Repeated problem:

- Delivering a polished static page when the user expects the actual map app.
- Losing Bokeh callbacks, tools, exports, selections, and data-source behavior.

Correct rule:

- Static pages are only for visual QA or temporary design review.
- Real implementation must preserve Bokeh pages, callbacks, tools, and exports.
- If style conflicts with function, function wins.

Regression checks:

- Verify map tools, timeline controls, production controls, export buttons,
  selections, and callbacks remain wired.
- Use static prototypes only as references for colors/layout hierarchy.

## 8. Letting Theme Styling Bleed Into Map Or Chart Canvases

Repeated problem:

- Applying dark shell colors to the Bokeh plot background.
- Making map/key-map canvases dark when overlays and axes were designed for
  white backgrounds.

Correct rule:

- Shell/sidebar/background styling can change.
- Main map, key map, and chart canvases should remain white or very light
  unless a readable plot theme is explicitly approved and tested.
- Do not apply CSS filters to map/chart canvases.

Regression checks:

- Inspect generated HTML/source for plot `background_fill_color` and
  `border_fill_color`.
- Open pages in light and dark shell modes and confirm plot readability.

## 9. Treating A Theme Marker As Responsive Implementation

Repeated problem:

- Adding shared CSS or a dark-mode toggle but leaving the real Bokeh layouts as
  fixed desktop rows.
- Checking only that generated HTML contains a theme marker, without verifying
  phone behavior.
- Building a static prototype that looks responsive while the actual generated
  app remains the old layout.

Correct rule:

- Responsive implementation must touch the real generated Bokeh layout source.
- Tag page roots, side panels, main plot panels, and key-map panels with stable
  classes.
- Phone controls should use the approved bottom drawer behavior until the user
  approves a different pattern.
- Verify generated map, timeline, production, and status pages contain the
  responsive hooks after rebuild.

Regression checks:

- Search generated pages for `fieldviewer-responsive-root`,
  `fieldviewer-main-plot-panel`, `fieldviewer-key-map-panel`, and
  `fvMobileControlsToggle`.
- Confirm Bokeh side panels still contain all controls and are not replaced by
  static mockups.
- Browser-test narrow widths when a browser runner is available.

## 10. Tile Provider Confused With CRS Ownership

Repeated problem:

- Assuming ESRI/local tile provider changes CRS, datum transform, or tile shift.
- Mixing tile URL row/column order.
- Testing assumed tiles instead of files that exist on disk.

Correct rule:

- Tile provider changes only the basemap.
- CRS, datum transform, grid shift, satellite shift, and tile shift remain
  manifest/config concerns.
- ESRI cached tiles use `MapServer/tile/{Z}/{Y}/{X}`.
- Local deployment pattern uses `/tiles_DH_sat/{Z}/{X}/{Y}.png` or the
  instance-specific equivalent.

Regression checks:

- Verify tile URL templates from the manifest.
- Test a real tile path found on disk when diagnosing 404s.
- Confirm ESRI attribution is present when ESRI imagery is visible.

## 11. Exposing Internal Generated Artifacts

Repeated problem:

- Showing internal generated files such as `faults_utm.json` in user-facing
  dropdowns.
- Removing generated companions from disk instead of hiding them from UI.

Correct rule:

- Internal generated companions may remain on disk for runtime/QC.
- User-facing controls should expose clean operational choices only.

Regression checks:

- Inspect runtime catalogs/dropdowns after grid packaging.
- Confirm internal files are filtered from user-facing selectors.

## 12. Losing Export Context

Repeated problem:

- Exporting only current slider state when the user requested full history.
- Omitting aggregation context or resolved well membership.
- Adding parallel export paths instead of replacing the old behavior when asked.

Correct rule:

- Timeline exports should cover the full date range when requested.
- Production exports should match visible features and selected aggregation.
- Grouped exports should include self-describing aggregation headers and
  membership detail where requested.

Regression checks:

- Test CSV headers and contents after export changes.
- Confirm grouped exports identify which wells are included.

## 13. Treating Blank Operational Inputs As Missing Data

Repeated problem:

- Skipping dashboard generation when operational workbooks are blank.
- Inferring values instead of preserving literal zero-value output.

Correct rule:

- Blank `today_info.xlsx` and `cum_info.xlsx` should still produce a valid
  dashboard with literal zero values.
- Do not fabricate operational numbers.

Regression checks:

- Rebuild the field status dashboard with blank inputs.
- Confirm counts display zeros and the page still loads.

## 14. Ignoring Instance Boundaries

Repeated problem:

- Applying a field-specific exception globally.
- Assuming old root `Data/` and `App/` paths are current.
- Forgetting to keep the selected instance context clear when switching between private engineering instance and Y1.

Correct rule:

- Use `instances/<field>/fieldviewer.instance.json` as the source of truth.
- Apply generator-level fixes only when behavior should affect all instances.
- Preserve explicit per-instance overrides.

Regression checks:

- Validate both changed manifests.
- Rebuild the intended instance(s), not stale root outputs.
- Review generated output under `instances/<field>/App/`.

## Minimum Checklist Before Finishing Relevant Work

- Validate affected instance manifests.
- Rebuild affected instances from `tools/rebuild_site.py`.
- Run QC for CRS/map/generated-output changes.
- Confirm back-to-menu navigation exists.
- Confirm desktop key map exists when applicable.
- Confirm map/chart canvases remain readable.
- Confirm aspect-ratio/equal-scale behavior is preserved.
- Confirm static design files did not replace real generated Bokeh pages.
- Confirm generated output reflects source-level changes after rebuild.


