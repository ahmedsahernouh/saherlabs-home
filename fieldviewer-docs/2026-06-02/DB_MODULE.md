> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Database Module

Updated: 2026-05-25

## Purpose

The database module is an optional, manifest-controlled foundation for FieldViewer metadata storage and future text-to-SQL or AI-agent workflows. It is isolated under `src/db/` so generated FieldViewer pages can continue to work without a database when an instance disables it.

The module is for metadata, file references, annotations, query history,
compact production summaries, and the full imported production table. Heavy
geoscience artifacts such as grids, cubes, tiles, SEG-Y files, and generated
HTML should stay on disk and be referenced by paths or catalog metadata.

## Architecture

- `src/db/base.py` defines the adapter interface.
- `src/db/sqlite_adapter.py` implements the first backend with Python `sqlite3`.
- `src/db/schema.py` owns deterministic `CREATE TABLE IF NOT EXISTS` statements.
- `src/db/semantic_schema.py`, `src/db/schema_context.py`, `src/db/query_examples.py`, and `src/db/query_history.py` prepare the DB for future Text-to-SQL usage.
- `src/db/query_validator.py` is the required gate for all current and future text-to-SQL reads.
- `src/db/repository.py` is the public interface used by Flask routes and future AI tools.
- `src/db/data_loader.py` reuses the current instance seeders for explicit load commands.
- `src/db/views.py` creates safe AI-facing read views.
- `src/app/routes/db_api.py` exposes optional JSON API endpoints.
- `tools/init_db.py`, `tools/load_db_from_instance.py`, `tools/export_db_schema_context.py`, `tools/evaluate_text_to_sql_readiness.py`, and `tools/smoke_test_db.py` support local initialization and verification without a live Flask server.
- `FieldViewer_Database.html` is generated as a lightweight browser test page when the instance database module is enabled.

## Why SQLite First

SQLite is available in the Python standard library, requires no service process, and fits the first FieldViewer use case: local metadata, catalog rows, annotations, and AI query history for one generated instance.

## Why Access Is Deferred

Microsoft Access requires ODBC driver availability and environment-specific connection handling. The adapter interface intentionally keeps backend concerns behind `DatabaseAdapter`, so an Access adapter can be added later without changing route or AI-tool callers.

## Schema Summary

The initial schema creates these tables:

- `projects`
- `instances`
- `wells`
- `well_tops`
- `layers`
- `grid_catalog`
- `production_summary`
- `production_full`
- `annotations`
- `ai_queries`
- `audit_log`
- `db_table_metadata`
- `db_column_metadata`
- `db_relationships`
- `db_query_examples`
- `db_query_history`
- `db_ai_context_snapshots`

`grid_catalog` and `layers` store metadata and file paths, not grid/cube/tile payloads.
`production_summary` is populated from the configured production source with a
compact set of well, date, rate, water cut, pressure, and source columns.
`production_full` stores the full imported production table with all source rows
and normalized SQL-friendly column names.

Safe AI-facing views are also created:

- `v_well_locations`
- `v_well_tops`
- `v_production_by_well`
- `v_production_full`
- `v_layer_catalog`
- `v_grid_catalog`

## Text-to-SQL Safety Rules

- All generated SQL must go through `validate_select_sql`.
- Only single `SELECT` or `WITH` statements are allowed.
- Write/admin SQL is rejected, including `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `CREATE`, `REPLACE`, `TRUNCATE`, `ATTACH`, `DETACH`, `PRAGMA`, `VACUUM`, `EXEC`, and `MERGE`.
- Multiple statements separated by semicolons are rejected.
- Comments containing hidden SQL or dangerous keywords are rejected.
- A default `LIMIT` is added to SELECT statements when no limit is present, and excessive limits are clamped.
- Tables marked `is_ai_visible=0`, including `audit_log`, are rejected for AI SQL.
- Query validation and execution attempts are recorded in `db_query_history`.
- Arbitrary write SQL is not exposed.
- Controlled writes must use `update_row` and must be allowlisted by table and column.
- `audit_log` cannot be updated through the API.

## API Endpoints

All endpoints return JSON in one of these forms:

```json
{"ok": true}
```

```json
{"ok": false, "error": "..."}
```

Endpoints:

- `GET /api/db/health`
- `POST /api/db/init`
- `GET /api/db/tables`
- `GET /api/db/schema/<table_name>`
- `GET /api/db/table/<table_name>?limit=100`
- `GET /api/db/schema-context`
- `GET /api/db/examples`
- `POST /api/db/select` with `{"question": "optional", "sql": "...", "limit": 500}`
- `POST /api/db/validate-sql` with `{"sql": "..."}`
- `GET /api/db/query-history?limit=50`
- `POST /api/db/update-row`

`update-row` requires `database.allow_updates=true`, an allowlisted table, and an allowlisted real update column. It rejects `audit_log`.

The generated menu can link to `FieldViewer_Database.html` for health, schema initialization, table browsing, and SELECT-only testing.

## Configuration

Instance privacy rule:

- Use Y1 for database demos:
  `instances/y1/fieldviewer.instance.json`.
- private engineering instance is the engineering instance: `instances/private engineering instance/fieldviewer.instance.json`.
- private engineering instance currently has runtime DB access enabled for selected-instance testing.

The instance manifest includes a database section like:

```json
"database": {
  "enabled": true,
  "backend": "sqlite",
  "path": "Data/fieldviewer.db",
  "allow_updates": false,
  "allow_delete": false,
  "default_limit": 500,
  "max_limit": 5000,
  "allowed_tables": [
    "projects",
    "instances",
    "wells",
    "well_tops",
    "layers",
    "grid_catalog",
    "production_summary",
    "production_full",
    "annotations",
    "ai_queries"
  ],
  "ai_visible_tables": [
    "projects",
    "instances",
    "wells",
    "well_tops",
    "layers",
    "grid_catalog",
    "production_summary",
    "annotations",
    "v_well_locations",
    "v_well_tops",
    "v_production_by_well",
    "v_production_full",
    "v_layer_catalog",
    "v_grid_catalog"
  ],
  "blocked_tables": [
    "audit_log"
  ]
}
```

Paths resolve relative to the active instance base directory unless absolute.

Optional `database.allowed_update_columns` can further override the built-in per-table update-column allowlist.

## Initialize

Runtime initialization through normal commands works when `database.enabled=true`:

```powershell
python tools\init_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\init_db.py --instance-config instances\y1\fieldviewer.instance.json
```

For local testing while keeping runtime routes disabled:

```powershell
python tools\init_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
python tools\init_db.py --instance-config instances\y1\fieldviewer.instance.json --force
```

## Smoke Test

Manifest-controlled smoke test:

```powershell
python tools\smoke_test_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools\smoke_test_db.py --instance-config instances\y1\fieldviewer.instance.json
```

Full schema/read validator test while forcing DB availability for offline setup:

```powershell
python tools\smoke_test_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
python tools\smoke_test_db.py --instance-config instances\y1\fieldviewer.instance.json --force
```

## Text-to-SQL Readiness

Initialize, load instance metadata, export schema context, and run the readiness evaluator:

```powershell
python tools\init_db.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
python tools\load_db_from_instance.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
python tools\export_db_schema_context.py --instance-config instances\private engineering instance\fieldviewer.instance.json --out instances\private engineering instance\App\db_schema_context.json --force
python tools\evaluate_text_to_sql_readiness.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
```

See `docs/TEXT_TO_SQL_DB_READINESS.md` for the full safe workflow.

## Future Work

- Add an Access adapter behind the same `DatabaseAdapter` interface.
- Add PostgreSQL or SQL Server adapters for shared deployments.
- Add AI Lab integration that calls `repository.run_select_query` only after validator approval.
- Add importers that populate metadata tables from instance CSV/XLSX/catalog files without storing heavy binary data.


