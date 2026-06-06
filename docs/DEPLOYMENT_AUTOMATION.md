# SaherLabs Deployment Automation

This repo is the GitHub source for the public SaherLabs static files and the
deployment source for two Cloudflare Workers Assets projects:

| Target | Live URL | Local path | Deploy trigger |
| --- | --- | --- | --- |
| SaherLabs homepage | `https://saherlabs.dev/` | repo root | `scripts\publish-saherlabs-home.ps1` |
| FieldViewer frontend | `https://fieldviewer.saherlabs.dev/` | `FieldViewer/` | `scripts\deploy-fieldviewer-frontend.ps1` |

The backend API is a separate Flask repo:

| Target | Live URL | Local path | Deploy trigger |
| --- | --- | --- | --- |
| FieldViewer backend | `https://api.saherlabs.dev/` | `D:\Libya_Machine_28082025\Code\SaherLabs\fieldviewer-backend` | `deployment\deploy-vps.ps1` |

## Core Rules

- Use Y1 only for public FieldViewer deployments.
- Do not publish C32 files, screenshots, generated pages, private data, logs, or
  credentials.
- Change durable FieldViewer behavior in the FieldViewer generator/source repo,
  then validate and rebuild Y1.
- The public frontend folder in this repo is a deployment copy from
  `D:\Libya_Machine_28082025\Code\FieldViewer\instances\y1\App`.
- Do not hand-edit generated Bokeh HTML as the long-term fix for product
  behavior.
- Keep API keys, provider calls, SQL/database access, and generated AI assets on
  `https://api.saherlabs.dev`.

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
4. Refuses to deploy if `demo.is_demo_instance` is not true.
5. Clears `FieldViewer/` while preserving `FieldViewer/wrangler.jsonc`.
6. Copies from `FieldViewer\instances\y1\App` to `saherlabs-home\FieldViewer`.
7. Excludes private/log/database files.
8. Validates generated AI Lab Bokeh JSON.
9. Verifies `https://api.saherlabs.dev` is present in AI Lab and Database pages.
10. Publishes a dated, sanitized public docs snapshot under `fieldviewer-docs/<date>/`.
11. Commits, rebases, and pushes the `FieldViewer/` deployment folder and docs snapshot.

Useful options:

```powershell
.\scripts\deploy-fieldviewer-frontend.ps1 -NoCommit
.\scripts\deploy-fieldviewer-frontend.ps1 -NoPush
.\scripts\deploy-fieldviewer-frontend.ps1 -SkipRebuild
.\scripts\deploy-fieldviewer-frontend.ps1 -SkipDocs
.\scripts\deploy-fieldviewer-frontend.ps1 -DocsStamp "2026-06-02"
.\scripts\deploy-fieldviewer-frontend.ps1 -CommitMessage "Deploy Y1 update"
```

Use `-SkipRebuild` only when `instances\y1\App` already came from current
generator source.

## Backend Deployment

Run from the backend repo:

```powershell
cd "D:\Libya_Machine_28082025\Code\SaherLabs\fieldviewer-backend"
.\deployment\deploy-vps.ps1
```

Commit backend changes and deploy:

```powershell
.\deployment\deploy-vps.ps1 -Commit -CommitMessage "Update backend API"
```

Sync the public Y1 demo SQLite database to the VPS:

```powershell
.\deployment\deploy-vps.ps1 -SyncDemoDatabase
```

The backend deploy script pulls/rebases, pushes GitHub, pulls
`/opt/fieldviewer-backend`, installs `requirements.txt`, restarts systemd, and
checks `https://api.saherlabs.dev/api/health`.

## Homepage Deployment

Run this after changing the SaherLabs homepage root files:

```powershell
cd "D:\Libya_Machine_28082025\Code\SaherLabs\saherlabs-home"
.\scripts\publish-saherlabs-home.ps1 -CommitMessage "Update SaherLabs homepage"
```

The script stages the requested files, commits, rebases, pushes, deploys to
Cloudflare with Wrangler, and verifies the live URL. It prepares a temporary
deploy copy because the repository `_redirects` file includes external redirect
rules for browser routing, while Cloudflare Workers Assets accepts only relative
redirect entries during direct upload. The repository files are not modified by
that filtering step.

By default it stages only:

```text
index.html
about.html
fieldviewer-intro.html
fieldviewer.html
fieldviewer-ai-lab.html
projects.html
resume.html
contact.html
SEO_CLOUDFLARE_NOTES.md
_redirects
_headers
robots.txt
sitemap.xml
.assetsignore
wrangler.jsonc
assets/
scripts/publish-saherlabs-home.ps1
```

To publish specific files:

```powershell
.\scripts\publish-saherlabs-home.ps1 -Paths @("index.html","about.html") -CommitMessage "Refresh homepage copy"
```

To verify specific live text after deployment:

```powershell
.\scripts\publish-saherlabs-home.ps1 `
  -Paths @("projects.html","assets\styles.css") `
  -CommitMessage "Refresh project links" `
  -VerifyUrl "https://saherlabs.dev/projects" `
  -VerifyText @("Seismic_Attributes_3D","stoiip_app")
```

Useful options:

```powershell
.\scripts\publish-saherlabs-home.ps1 -NoPush
.\scripts\publish-saherlabs-home.ps1 -NoDeploy
.\scripts\publish-saherlabs-home.ps1 -AllowDirtyOutsidePaths
.\scripts\publish-saherlabs-home.ps1 -DryRun
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

SQL route check:

```powershell
Invoke-RestMethod `
  -Uri https://api.saherlabs.dev/api/ai-lab/ask `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"question":"Show wells whose names start with XN and contain H with coordinates","model_provider":"openai"}'
```

Selected-well tool check:

```powershell
Invoke-RestMethod `
  -Uri https://api.saherlabs.dev/api/ai-lab/chat `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"mode":"selected_well","message":"Explain selected well XE13-1 and generate map/profile/link","selected_well":"XE13-1","model_provider":"openai"}'
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
  -> publish script deploys Workers Assets with Wrangler
  -> verify saherlabs.dev

fieldviewer-backend
  -> commit/push backend repo
  -> VPS git pull
  -> pip install requirements
  -> systemd restart
  -> api.saherlabs.dev
```
