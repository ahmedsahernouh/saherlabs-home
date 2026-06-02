# FieldViewer Public Frontend Handover

Updated: 2026-06-01

The public FieldViewer site is a static deployment copy of the Y1 generated app.

## Paths

| Purpose | Path |
| --- | --- |
| Generator/source repo | `D:\Libya_Machine_28082025\Code\FieldViewer` |
| Y1 manifest | `D:\Libya_Machine_28082025\Code\FieldViewer\instances\y1\fieldviewer.instance.json` |
| Generated public app source | `D:\Libya_Machine_28082025\Code\FieldViewer\instances\y1\App` |
| Git-tracked deployment copy | `D:\Libya_Machine_28082025\Code\SaherLabs\saherlabs-home\FieldViewer` |
| Live frontend | `https://fieldviewer.saherlabs.dev` |
| Live backend | `https://api.saherlabs.dev` |

## Update Workflow

1. Change the FieldViewer generator/source repo.
2. Validate Y1.
3. Rebuild Y1.
4. Run `scripts\deploy-fieldviewer-frontend.ps1` from this repo.
5. Let Cloudflare deploy from GitHub.
6. Verify the live page and backend together.

Command:

```powershell
cd "D:\Libya_Machine_28082025\Code\SaherLabs\saherlabs-home"
.\scripts\deploy-fieldviewer-frontend.ps1 -CommitMessage "Deploy Y1 FieldViewer update"
```

By default this also publishes a dated, sanitized copy of
`D:\Libya_Machine_28082025\Code\FieldViewer\docs` under:

```text
fieldviewer-docs/<yyyy-mm-dd>/
```

Use `-SkipDocs` only when the public docs snapshot should not be refreshed.

## AI Lab And Database Coupling

The static frontend must call:

```text
https://api.saherlabs.dev
```

The backend owns:

- provider keys and model calls
- text-to-SQL
- read-only SQLite access
- selected-well surface map generation
- selected-well production profile generation
- completion links
- generated AI output assets

If AI Lab or Database looks broken, verify both the frontend HTML and the live
backend API before changing generated files.

## Do Not Publish

```text
C32 data or pages
.env
*.env
*.log
*.jsonl
*.db
*.sqlite
*.sqlite3
content.txt
credentials
private keys
```

## Notes For Agents

- `FieldViewer/` is a deployment artifact in this repo.
- Durable FieldViewer product changes belong in the main FieldViewer generator.
- `fieldviewer-backend` is a separate repo and deploy path.
- Parent folder handover files under `D:\Libya_Machine_28082025\Code\SaherLabs`
  are useful local notes, but they are not in a Git repository.
