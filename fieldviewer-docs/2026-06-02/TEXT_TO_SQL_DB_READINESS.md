> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# Text-to-SQL Database Readiness

Updated: 2026-05-25

## Purpose

This foundation prepares the optional FieldViewer SQLite database for AI Lab and Text-to-SQL workflows. It gives an LLM a compact, explainable schema context while keeping SQL execution behind a strict validator and repository/API adapter.

The LLM must never directly access SQLite. It proposes SQL, the validator checks it, and only approved SELECT/WITH queries are executed.

## Architecture

The database has four layers:

1. Physical data layer: SQLite tables for projects, instances, wells, layers, grids, tops, compact production summaries, full production records, annotations, AI query records, and audit records.
2. Semantic metadata layer: descriptions, grain, business purpose, units, synonyms, relationships, and AI visibility controls.
3. Safe SQL execution layer: SELECT-only validation, blocked keywords, limit enforcement, hidden-table checks, execution timing, and query history.
4. Text-to-SQL preparation layer: compact schema-context JSON, example questions, readiness tests, API endpoints, and the unified AI Lab question router.

## Physical Tables

Core FieldViewer tables:

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

Text-to-SQL support tables:

- `db_table_metadata`
- `db_column_metadata`
- `db_relationships`
- `db_query_examples`
- `db_query_history`
- `db_ai_context_snapshots`

All schema initialization uses `CREATE TABLE IF NOT EXISTS` and does not destroy existing tables.

## Semantic Metadata

Semantic metadata is seeded for the core tables and safe views. It includes concise business meaning, table grain, column descriptions, units, synonyms, and allowed relationships. `audit_log` is marked hidden from AI by default.

Preferred AI-facing views:

- `v_well_locations`
- `v_well_tops`
- `v_production_by_well`
- `v_production_full`
- `v_layer_catalog`
- `v_grid_catalog`

Use `production_summary` or `v_production_by_well` for compact production rate
questions. Use `production_full` or `v_production_full` when the question needs
the complete source production history, including monthly volumes, cumulative
volumes, injection, status, reservoir, and source well metadata.

## Safe Text-to-SQL Workflow

```text
User question
-> LLM generates candidate SQL
-> /api/db/validate-sql validates it
-> /api/db/select executes only if safe
-> result table returned
-> LLM summarizes result
-> db_query_history records question, SQL, status, row count
```

Rules:

- Only `SELECT` and `WITH` are allowed.
- Multiple statements and semicolon-separated statements are rejected.
- Dangerous keywords are blocked: `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `CREATE`, `REPLACE`, `TRUNCATE`, `ATTACH`, `DETACH`, `PRAGMA`, `VACUUM`, `EXEC`, and `MERGE`.
- Comments containing hidden SQL or dangerous keywords are rejected.
- A default `LIMIT` is added when missing.
- Limits above the configured maximum are clamped.
- Tables marked `is_ai_visible=0` are rejected for AI SQL.
- Arbitrary write SQL is never exposed.
- Write operations must remain controlled functions only.

## API Endpoints

- `GET /api/db/health`
- `GET /api/db/tables`
- `GET /api/db/schema/<table_name>`
- `GET /api/db/schema-context`
- `GET /api/db/examples`
- `POST /api/db/select`
- `POST /api/db/validate-sql`
- `GET /api/db/query-history?limit=50`

Runtime routes are available only when the active instance has `database.enabled=true`. Use `--force` CLI commands for local setup, export, or evaluation when runtime access is intentionally disabled.

## Load Instance Data

```powershell
python tools\load_db_from_instance.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force --dry-run
python tools\load_db_from_instance.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
```

The loader reads the active manifest, reuses existing database initialization/seed behavior, loads available catalog metadata, imports the compact and full production tables, skips missing files gracefully, and does not delete existing rows unless `--replace` is supplied.

## Export Schema Context

```powershell
python tools\export_db_schema_context.py --instance-config instances\private engineering instance\fieldviewer.instance.json --out instances\private engineering instance\App\db_schema_context.json --force
```

The export contains database purpose, AI-visible tables, column descriptions, relationships, safe-query rules, and example questions. It does not include secrets or internal credentials.

## Validate SQL

Use the API:

```http
POST /api/db/validate-sql
```

With body:

```json
{"sql": "SELECT well_name, x_utm, y_utm FROM v_well_locations"}
```

Then execute only if validation returns `ok=true`.

## Readiness Evaluation

```powershell
python tools\evaluate_text_to_sql_readiness.py --instance-config instances\private engineering instance\fieldviewer.instance.json --force
```

The evaluation checks schema existence, metadata population, relationships, schema-context export, example validation/execution, dangerous SQL rejection, multiple-statement rejection, and query-history creation. It does not call OpenAI or any LLM.

## Limitations

- This is still a controlled Text-to-SQL workflow, not an autonomous SQL agent.
- Conversational memory and multi-step database planning are not implemented.
- The database stores metadata, normalized summaries, and the full production table. It does not store heavy grids, cubes, tiles, SEG-Y, or generated HTML.
- Runtime DB access is controlled per instance by `database.enabled`; private engineering instance is enabled for selected-instance testing, while future runtime exposure should be reviewed per manifest.

## AI Lab Router Integration

`POST /api/ai-lab/ask` now uses this database foundation for routed `text_to_sql`
questions:

1. Load AI-visible schema context.
2. Ask the LLM to generate only SELECT/WITH candidate SQL against AI-visible tables and views.
3. Validate SQL with the existing validator.
4. Send the validator error back for one optional repair.
5. Execute only validated SQL through the safe database adapter.
6. Summarize returned rows with visible caveats for empty or partial data.
7. Show generated SQL, executed SQL, validation status, row count, timing, and warnings to the user.
8. Use `db_query_history` for SQL traceability and `ai_lab_router_log.jsonl` for route-level audit.

See `docs/AI_LAB_QUESTION_ROUTER.md` for the unified classifier/button/Text-to-SQL/custom-question workflow.

