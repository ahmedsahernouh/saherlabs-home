# SaherLabs Frontend Agent Handover

Updated: 2026-06-01

This repo publishes both the SaherLabs homepage and the public FieldViewer
static frontend.

## Fast Facts

- Repo: `D:\Libya_Machine_28082025\Code\SaherLabs\saherlabs-home`
- Branch: `main`
- GitHub: `https://github.com/ahmedsahernouh/saherlabs-home.git`
- Homepage: `https://saherlabs.dev`
- FieldViewer: `https://fieldviewer.saherlabs.dev`
- Backend API: `https://api.saherlabs.dev`
- Public FieldViewer instance: Y1 only

## Read First

1. `docs/DEPLOYMENT_AUTOMATION.md`
2. `scripts/deploy-fieldviewer-frontend.ps1`
3. `scripts/publish-saherlabs-home.ps1`
4. `FieldViewer/FieldViewer_AI_Lab.html` only for verification, not durable edits

## Source Of Truth

For FieldViewer behavior, the source of truth is the main generator repo:

```text
D:\Libya_Machine_28082025\Code\FieldViewer
```

Public generated source:

```text
D:\Libya_Machine_28082025\Code\FieldViewer\instances\y1\App
```

Deployment copy in this repo:

```text
D:\Libya_Machine_28082025\Code\SaherLabs\saherlabs-home\FieldViewer
```

Do not make durable product fixes by hand-editing generated HTML in
`FieldViewer/`. Change the generator/source repo, rebuild Y1, then deploy.

## Safe Deploy Commands

Deploy public FieldViewer Y1:

```powershell
.\scripts\deploy-fieldviewer-frontend.ps1
```

Publish homepage root files:

```powershell
.\scripts\publish-saherlabs-home.ps1 -CommitMessage "Update SaherLabs homepage"
```

## Privacy Rules

- Y1 is public.
- C32 is private/internal.
- Do not publish C32 pages, screenshots, context files, or data.
- Do not commit `.env`, logs, JSONL files, databases, `content.txt`, or
  credentials.

## Verification

Check AI Lab points at the backend:

```powershell
$u = "https://fieldviewer.saherlabs.dev/FieldViewer_AI_Lab.html?cachecheck=$(Get-Date -Format yyyyMMddHHmmss)"
$r = Invoke-WebRequest $u -UseBasicParsing
($r.Content | Select-String 'https://api.saherlabs.dev' -SimpleMatch).Count
```

Check backend separately:

```powershell
Invoke-RestMethod https://api.saherlabs.dev/api/health
```
