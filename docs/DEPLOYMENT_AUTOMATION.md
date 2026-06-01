# SaherLabs Deployment Automation

This repo is the GitHub source for two Cloudflare Pages projects:

| Target | Live URL | Local path | Deploy trigger |
| --- | --- | --- | --- |
| SaherLabs homepage | `https://saherlabs.dev/` | repo root | commit and push `main` |
| FieldViewer frontend | `https://fieldviewer.saherlabs.dev/` | `FieldViewer/` | commit and push `main` |

The backend API is a separate Flask repo:

| Target | Live URL | Local path | Deploy trigger |
| --- | --- | --- | --- |
| FieldViewer backend | `https://api.saherlabs.dev/` | `D:\Libya_Machine_28082025\Code\SaherLabs\fieldviewer-backend` | push repo, pull on VPS, restart systemd |

## Rules

- Use Y1 only for public FieldViewer deployments.
- Do not publish C32 files, screenshots, generated pages, or private data.
- Change FieldViewer behavior in the FieldViewer generator/source repo first, then rebuild Y1.
- Do not hand-edit generated Bokeh HTML for durable product changes.
- Do not publish `.env`, `*.log`, `*.jsonl`, `*.db`, `*.sqlite`, `*.sqlite3`, or `content.txt`.
- Keep API keys and SQL/database access on `https://api.saherlabs.dev`, never in browser code.

## FieldViewer Frontend Deployment

Run this after FieldViewer source, manifest, or generated Y1 output changes:

```powershell
cd "D:\Libya_Machine_28082025\Code\SaherLabs\saherlabs-home"
.\scripts\deploy-fieldviewer-frontend.ps1
```

What the script does:

1. Validates `D:\Libya_Machine_28082025\Code\FieldViewer\instances\y1\fieldviewer.instance.json`.
2. Rebuilds the Y1 generated app with `tools\rebuild_site.py`.
3. Refuses to deploy if the manifest is not `instance.id = y1`.
4. Clears `FieldViewer/` while preserving `FieldViewer/wrangler.jsonc`.
5. Copies from `FieldViewer\instances\y1\App` to `saherlabs-home\FieldViewer`.
6. Excludes private/log/database files.
7. Validates the generated AI Lab Bokeh JSON.
8. Verifies `https://api.saherlabs.dev` is present in the AI Lab page.
9. Commits, rebases, and pushes the `FieldViewer/` deployment folder.

Useful options:

```powershell
.\scripts\deploy-fieldviewer-frontend.ps1 -NoCommit
.\scripts\deploy-fieldviewer-frontend.ps1 -NoPush
.\scripts\deploy-fieldviewer-frontend.ps1 -SkipRebuild
.\scripts\deploy-fieldviewer-frontend.ps1 -CommitMessage "Deploy Y1 menu update"
```

Use `-SkipRebuild` only when `instances\y1\App` has already been rebuilt from current source.

## Homepage Deployment

Run this after changing the SaherLabs homepage root files:

```powershell
cd "D:\Libya_Machine_28082025\Code\SaherLabs\saherlabs-home"
.\scripts\publish-saherlabs-home.ps1 -CommitMessage "Update SaherLabs homepage"
```

By default it stages only:

```text
index.html
about.html
fieldviewer-intro.html
_redirects
wrangler.jsonc
assets/
```

To publish a specific set of files:

```powershell
.\scripts\publish-saherlabs-home.ps1 -Paths index.html,about.html -CommitMessage "Refresh homepage copy"
```

## Backend Deployment

Run from the backend repo:

```powershell
cd "D:\Libya_Machine_28082025\Code\SaherLabs\fieldviewer-backend"
.\deployment\deploy-vps.ps1
```

When local backend files have changed and should be committed first:

```powershell
.\deployment\deploy-vps.ps1 -Commit -CommitMessage "Update backend API"
```

What the backend script does:

1. Refuses private-looking files.
2. Optionally commits backend changes.
3. Pulls/rebases and pushes `main`.
4. SSHes to the VPS.
5. Pulls `/opt/fieldviewer-backend` with the server deploy key.
6. Restarts `fieldviewer-backend.service`.
7. Checks `https://api.saherlabs.dev/api/health`.

Useful options:

```powershell
.\deployment\deploy-vps.ps1 -NoRemotePull
.\deployment\deploy-vps.ps1 -NoRestart
.\deployment\deploy-vps.ps1 -NoSmoke
.\deployment\deploy-vps.ps1 -NoPush
```

## Verification

After a FieldViewer frontend deploy:

```powershell
$u = "https://fieldviewer.saherlabs.dev/FieldViewer_AI_Lab.html?cachecheck=$(Get-Date -Format yyyyMMddHHmmss)"
$r = Invoke-WebRequest $u -UseBasicParsing
($r.Content | Select-String 'https://api.saherlabs.dev' -SimpleMatch).Count
```

Expected: count greater than `0`.

After a backend deploy:

```powershell
Invoke-RestMethod https://api.saherlabs.dev/api/health
Invoke-RestMethod https://api.saherlabs.dev/api/ai-lab/context-summary
```

Expected health:

```text
service             status
-------             ------
fieldviewer-backend ok
```

## Current Deployment Model

```text
FieldViewer generator/source
  -> validate Y1
  -> rebuild Y1 App
  -> copy public App to saherlabs-home/FieldViewer
  -> commit/push saherlabs-home
  -> Cloudflare deploys fieldviewer.saherlabs.dev

saherlabs-home root files
  -> commit/push saherlabs-home
  -> Cloudflare deploys saherlabs.dev

fieldviewer-backend
  -> commit/push backend repo
  -> VPS git pull
  -> systemd restart
  -> api.saherlabs.dev
```
