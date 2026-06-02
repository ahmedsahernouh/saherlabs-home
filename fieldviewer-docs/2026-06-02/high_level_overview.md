> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer High-Level Overview

Updated: 2026-05-25

## Five-Minute Summary

FieldViewer is an engineering web application for reviewing an oil-field from
multiple operational and subsurface angles: maps, wells, grids, production,
timeline history, completions, well testing, ESP, database metadata, AI Lab
context, field-status dashboards, and safe structured-data query workflows.

The project has moved from a single fixed app into an instance-based generator.
The central codebase builds a complete FieldViewer application from a
field-specific manifest and data folder. Instance use is split by privacy:

- Y1 is the demo instance for demo builds and examples.

- private engineering instance is an active engineering instance and remains fully documented.

The Y1 demo application is defined by:

```text
instances/y1/fieldviewer.instance.json
instances/y1/Data/
instances/y1/App/
```

The private engineering instance application is defined by:

```text
instances/private engineering instance/fieldviewer.instance.json
instances/private engineering instance/Data/
instances/private engineering instance/App/
```

This split is the most important achievement in the current architecture. It
means FieldViewer is no longer only one generated site for one dataset. It is a
repeatable generator that can create and maintain separate field applications
with their own data, settings, generated pages, tiles, and deployment layout.

## Current Value

FieldViewer already provides a practical integrated review environment for
field data. Instead of moving between disconnected files, maps, spreadsheets,
and manual plots, users can open generated pages for:

- surface and subsurface map review
- grid, contour, fault, well, and station visualization
- production profile analysis
- field timeline review
- completion, well-testing, and ESP workflows
- field-status dashboard review
- database metadata browsing and controlled query testing
- AI Lab demo workflows with traceable context
- early Text-to-SQL readiness through safe database schema context, example
  questions, query validation, and audit history

The value is operational rather than cosmetic. The app helps preserve field
context, improve repeatability, and reduce the manual effort needed to rebuild
the same analysis package when source data changes.

## AI And Management Potential

FieldViewer now has the beginnings of a practical AI-ready field data platform,
not only a visualization site. The database and AI Lab work create a controlled
path where an LLM can eventually answer management and engineering questions
from approved structured data without directly touching raw files or executing
arbitrary SQL.

Near-term AI value:

- ask natural-language questions over wells, compact and full production
  tables, layers, grids, tops, annotations, and metadata
- generate explainable SQL from a compact semantic schema context
- validate candidate SQL before execution
- keep read-only query history for accountability
- let managers ask portfolio-style questions while engineers can inspect the
  exact data path behind the answer

Important examples of future management questions:

- Which wells have missing reservoir assignments?
- What grids and layers are available for the current field package?
- Which wells have the latest production records?
- How many wells are active by status or reservoir?
- Which fields or instances are ready for publication, internal review, or AI
  demonstration?

This AI direction is deliberately governed. The LLM must use approved context,
schema metadata, validators, and repository APIs. It must not directly access
SQLite, source files, or uncontrolled write operations. This makes the AI
potential useful for management review while preserving engineering traceability
and data safety.

## Current Achievements

- Central generator and field-instance architecture are in place.
- private engineering instance is represented as the active engineering instance with its own manifest, data
  folder, and generated app output.
- Y1 is represented as a demo instance.
- Build, validation, and QC commands are documented and instance-aware.
- The menu is manifest-driven and can expose active, hidden, or dimmed modules.
- The default home route is menu-driven through the instance manifest.
- Local/server-stored tiles remain the default, with ESRI World Imagery
  available as a supported build option.
- CRS handling remains tied to the Python/QGIS-compatible pipeline rather than
  browser-only projection logic.
- The UI design direction now has a dedicated handoff document for improving
  polish and responsive behavior while preserving the real Bokeh application.
- A SQLite-backed database module exists for metadata, catalog rows,
  annotations, query history, compact production summaries, the full imported
  production table, semantic schema descriptions, safe Text-to-SQL preparation,
  and future AI workflows.
- private engineering instance can now run the database API when enabled in the selected manifest; AI Lab
  can be dimmed or disabled per instance while remaining visible in the menu.
- Menu QR/server-home links are driven by each instance manifest through
  `server.url`, so local and future online demo URLs can differ safely.

## Active Product Areas

The Y1 demo menu currently includes:

- Field Status Dashboard
- FieldViewer AI Lab
- Surface Map
- Subsurface Maps
- Production Analysis
- Field Timeline
- Completion
- Well Testing
- Database

private engineering instance may include additional engineering workflows and should remain documented when those workflows matter.

The application also tracks planned or inactive areas, such as well
intervention, drilling monitoring, well logs, and well data directory
workflows. Those should be described as planned unless their generated pages
and workflows are active in the current manifest.

## UI Design Direction

FieldViewer should look like a polished engineering operations tool, not a
marketing landing page. The menu is already more styled than the core Bokeh
pages, and the next UI goal is to bring the map, timeline, production, status,
and database pages into a more consistent visual system.

The design direction is:

- dense but organized information
- clear visual hierarchy for repeated technical use
- professional colors with semantic meaning for oil, gas, water, status, and
  controls
- responsive layouts for laptop, tablet, and phone widths
- preserved map and chart readability
- no replacement of the real Bokeh callbacks with static mockups

The main maps and key maps should remain white or very light unless a reviewed
plot theme proves that axes, labels, wells, contours, tiles, and overlays remain
readable.

## Planned Functions

Near-term planned work should focus on improving the repeatable generator and
the usability of generated instances:

- stronger instance creation guidance
- safer validation for missing or uncertain inputs
- broader documentation around expected data contracts
- more polished shared UI styles across Bokeh pages
- responsive control strategies for dense map and chart pages
- database importers for metadata and file catalogs
- richer database-backed production questions using both compact and full
  production tables
- AI Lab integration with approved metadata, query paths, and database schema
  context
- clearer deployment packaging for Windows-build and Linux-server workflows

## Scalability Potential

The current architecture can scale in three directions.

Field scale:

New fields can be represented by new `instances/<field>/` folders with their
own manifest, data, generated app, tiles, and settings. Examples can use the
instance that matches the documentation or review objective.

Feature scale:

New modules can be added to the central generator and enabled per instance.
The manifest can control whether each module is active, hidden, or dimmed.

Deployment scale:

The central generator can remain shared while instances move independently
between local Windows builds and Linux server deployment folders. Shared assets,
such as local tile folders, can remain outside one specific field instance when
the deployment layout requires it.

AI scale:

FieldViewer can grow from visual review into governed field intelligence. Each
instance can publish a compact schema context, expose only AI-visible tables and
views, answer detailed production questions from the full production table, and
record query history. This gives future AI Lab workflows a repeatable path
across fields while keeping data boundaries and destructive SQL
controls in place.

## Main Risks

- Source data quality and format uncertainty can affect generated output.
- CRS, grid alignment, tiles, and geometry packaging remain critical technical
  areas that must be validated carefully.
- Generated HTML should not become the long-term source of truth; durable fixes
  need to be made in generator/runtime source.
- The worktree is mid-migration and dirty, so old root-level `Data/` and `App/`
  assumptions must not be restored casually.
- private engineering instance documentation and generated outputs
  should use Y1.
- UI redesign must preserve engineering behavior, callbacks, maps, charts, and
  exports.
- The database module is a foundation for safe structured-data questions, not a
  replacement for heavy geoscience file storage.
- AI answers must remain grounded in approved context, validated SQL, and
  visible evidence. The system should not be presented as autonomous field
  decision-making.

## Management Message

FieldViewer is becoming a reusable field-application generator and an AI-ready
field intelligence foundation. Its strongest current value is that it combines
engineering map review, production analysis, timeline review, operational
dashboards, database-backed structured metadata, and governed AI potential in
one field-specific package. The next phase should focus on making instance
generation more predictable, improving UI consistency, hardening data
validation, and connecting AI Lab only through approved schema context and safe
read-only query APIs so the same platform can support more fields with less
manual rework.

