> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# Phase 1 - Quick Fix Applied

Historical note: this file documents an early Phase 1 recovery fix. For the
current instance-aware private engineering instance workflow, use `AI_HANDOVER.md`,
`docs/HANDOVER.md`, and `docs/INSTANCE_CONFIG.md`.

## Issue
The legacy `legacy_viewer.py` had module-level data loading code that executed immediately on import, causing `FileNotFoundError` before `main.py` could configure paths.

## Solution
Commented out module-level execution blocks:
- Lines 53-54: `df_poly` and `df_wells` loading
- Lines 57-58: STATUS column check
- Lines 253-277: Grid loading loop
- Lines 291-310: Polygon/wells validation
- Lines 2041-2049: Final execution (`create_zmap_viewer_html_xyz()` call)

This makes the module importable - only function definitions remain active. The `main.py` wrapper handles all data loading.

## Files Modified
- `src/legacy/legacy_viewer.py` - Commented module-level execution
- `fix_legacy.py` - Cleanup script (can be deleted)

## Test Result âœ…
```
python src/app/main.py
```

**SUCCESS!**
- Loaded 1 grid: Surface (978x1146, Z range: 756.89 to 1292.71)
- Loaded 33 polygon points (1 segment)
- Loaded 323 wells  
- Generated HTML: `App/output/FieldViewer_Phase1.html`

## Next Steps
1. Open the HTML file in your browser
2. Run through the acceptance checklist (25+ features)
3. Compare with legacy HTML for visual parity

## Note
The `delim_whitespace` warning is a pandas deprecation - will be fixed in Phase 2 when we extract the polygon reader.


