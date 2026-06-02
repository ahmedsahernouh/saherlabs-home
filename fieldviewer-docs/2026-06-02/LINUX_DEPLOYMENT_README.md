> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Linux Deployment README

Updated: 2026-05-25

Purpose: use this checklist when restarting or updating the local Linux
FieldViewer server. Normal restarts do not require database initialization.

## Key Rule

The Flask server serves the `App/` folder resolved from the active instance
manifest. For private engineering instance, the expected deployed generated app folder is:

```text
[internal Linux deployment path] engineering instance/App/
```

Do not assume this folder is the same as:

```text
[internal Linux deployment path]
```

If the uploaded files go to the wrong `App/` folder, restarting the server will
still show the previous version.

## Recommended Deployment Layout

```text
[internal Linux deployment path]
  src/
  tools/
  docs/
  tiles_DH_sat/
  instances/
    private engineering instance/
      fieldviewer.instance.json
      Data/
      App/
```

The private engineering instance manifest should be the active server manifest:

```text
[internal Linux deployment path] engineering instance/fieldviewer.instance.json
```

## Normal Restart

Use this when no files changed and you only need to restart the running server:

```bash
cd [internal Linux deployment path]
bash src/tools/stop_fieldviewer.sh
bash src/tools/start_fieldviewer.sh
```

This does not require DB initialization, DB loading, or smoke tests.

## Generated App Redeploy

1. Upload or copy the generated private engineering instance app files into:

```bash
[internal Linux deployment path] engineering instance/App/
```

2. Restart FieldViewer if the manifest, menu routing, DB page, or server-side
   behavior changed. For simple HTML replacement, a browser hard refresh is
   often enough, but restarting is a safe habit:

```bash
cd [internal Linux deployment path]
bash src/tools/stop_fieldviewer.sh
bash src/tools/start_fieldviewer.sh
```

3. Open with a cache buster:

```text
[internal server URL]/menu.html?v=20260525
```

Use `Ctrl+F5` in the browser if the old page is still shown.

## Code Or Manifest Redeploy

Use this when you upload updated `src/`, `tools/`, startup scripts, or
`instances/private engineering instance/fieldviewer.instance.json`:

```bash
cd [internal Linux deployment path]
bash src/tools/stop_fieldviewer.sh
bash src/tools/start_fieldviewer.sh
curl -i [internal server URL]/health
```

If the database page is involved, also check:

```bash
curl -i [internal server URL]/api/db/health
```

## Database Redeploy

The database page is not fully static. `FieldViewer_Database.html` calls live
JSON endpoints under `/api/db/...`, so the Linux server must have:

- updated server source code under `[internal Linux deployment path]`
- the active private engineering instance manifest with `"database.enabled": true`
- the SQLite file at `[internal Linux deployment path] engineering instance/Data/fieldviewer.db`
- the server restarted after code, manifest, or DB changes

Do not run the full DB setup for every restart. `init_db.py` is intended to be
fast and schema-focused. `load_db_from_instance.py` may take longer because it
reads instance data such as wells, tops, grids, compact production summaries,
and the full production table.

Run the full DB setup only after DB schema changes, DB loader changes, a new DB
file, or changed DB-related input data.

For a DB schema/data refresh, run:

```bash
cd [internal Linux deployment path]
export FIELDVIEWER_INSTANCE_CONFIG=[internal Linux deployment path] engineering instance/fieldviewer.instance.json
[internal Python environment] tools/init_db.py --instance-config instances/private engineering instance/fieldviewer.instance.json --force
[internal Python environment] tools/load_db_from_instance.py --instance-config instances/private engineering instance/fieldviewer.instance.json --force
[internal Python environment] tools/smoke_test_db.py --instance-config instances/private engineering instance/fieldviewer.instance.json --force
bash src/tools/stop_fieldviewer.sh
bash src/tools/start_fieldviewer.sh
```

Then test the API directly:

```bash
curl -i [internal server URL]/api/db/health
curl -i [internal server URL]/api/db/tables
```

Both responses should have `Content-Type: application/json` and a JSON body.
If the browser database page shows `Invalid JSON response`, the page received
non-JSON from `/api/db/...`.

## When To Run Which Commands

- Normal restart: run only `stop_fieldviewer.sh` and `start_fieldviewer.sh`.
- New generated `instances/private engineering instance/App/` only: copy files, hard refresh browser,
  and restart only if routing or manifest settings changed.
- New `src/` or `tools/`: copy files, restart, then check `/health`.
- New manifest: copy `fieldviewer.instance.json`, restart, then confirm the log
  shows the expected `Serving assets from:` folder.
- New DB schema, loader, or DB data: run `init_db.py`, `load_db_from_instance.py`,
  `smoke_test_db.py`, then restart.
- Layout-only DB page changes require copying `FieldViewer_Database.html` and
  updated source, but they do not require DB reload.
- DB troubleshooting: run `smoke_test_db.py` and inspect
  `fieldviewer_server.log`.

## If The Old Version Still Appears

Check that the uploaded file is newer in the instance folder:

```bash
ls -l [internal Linux deployment path] engineering instance/App/menu.html
ls -l [internal Linux deployment path]
```

Check which process is running:

```bash
ps -ef | grep -i fieldviewer
ps -ef | grep -i server.py
```

Check the active manifest used by the server:

```bash
echo $FIELDVIEWER_INSTANCE_CONFIG
```

For private engineering instance, it should point to:

```bash
[internal Linux deployment path] engineering instance/fieldviewer.instance.json
```

When the server starts, confirm this line in the log:

```text
Serving assets from: [internal Linux deployment path] engineering instance/App
```

If the log shows another folder, upload to that folder or fix the startup
script to use the private engineering instance manifest.

## Manual Start For Verification

Use this only for troubleshooting, not as the normal production restart method:

```bash
cd [internal Linux deployment path]
export FIELDVIEWER_INSTANCE_CONFIG=[internal Linux deployment path] engineering instance/fieldviewer.instance.json
export FIELDVIEWER_PORT=8000
python src/app/server.py
```

The server reads the manifest at startup. After changing files, paths, or
manifest values, restart the server process.

## Common Causes Of Stale Pages

- Files were uploaded to `[internal Linux deployment path]` instead of
  `[internal Linux deployment path] engineering instance/App/`.
- `start_fieldviewer` uses a different `FIELDVIEWER_INSTANCE_CONFIG`.
- The previous Python process did not stop.
- The browser cached the old HTML or JavaScript.
- The app was rebuilt locally but the generated `instances/private engineering instance/App/` files were
  not uploaded.
- The database page was uploaded but the Linux `src/` server code was not
  updated, so `/api/db/...` routes are missing or stale.
- The database file was not initialized at
  `[internal Linux deployment path] engineering instance/Data/fieldviewer.db`.


