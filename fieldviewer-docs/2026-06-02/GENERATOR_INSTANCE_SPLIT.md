> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# Generator And Instance Split

FieldViewer should now be treated as two separate concerns.

Updated: 2026-05-07

## Central Generator Container

The central generator owns:

- source code under `src/`,
- build/QC/deploy tools under `tools/`,
- generator documentation under `docs/` and `generator/`,
- dependencies in `requirements*.txt`,
- future Builder MCP under `generator/mcp/`.

All feature changes, UI changes, page changes, data-reader changes, and MCP
orchestration changes should be made in this central generator.

## FieldViewer Instance Container

Each field owns:

- one `fieldviewer.instance.json`,
- source data folders,
- generated `App/` output,
- deployment/runtime-specific artifacts.
- instance-specific basemap settings, including local/server-stored tiles or
  ESRI World Imagery.

Instance privacy rule:

- `instances/y1/` is the demo instance for demo builds and examples.
- `instances/private engineering instance/` is the active engineering instance and remains fully documented.

private engineering instance is currently represented by:

```text
instances/private engineering instance/fieldviewer.instance.json
instances/private engineering instance/config/settings.txt
instances/private engineering instance/Data/
instances/private engineering instance/App/
```

Y1 is currently represented by:

```text
instances/y1/fieldviewer.instance.json
instances/y1/config/settings.txt
instances/y1/Data/
instances/y1/App/
```

The current private engineering instance data and generated app now live inside the private engineering instance instance folder.
The central generator reads `paths.base_dir` from the selected manifest and
resolves instance paths from there.

## Build Flow

```text
central generator + selected instance manifest
  -> validate instance
  -> package grids
  -> generate HTML pages/menu
  -> deploy generated instance
```

Commands:

```powershell
python tools/validate_instance.py instances\private engineering instance\fieldviewer.instance.json
python tools/rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
python tools/validate_instance.py instances\y1\fieldviewer.instance.json
python tools/rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

To build the selected instance with ESRI World Imagery without permanently
changing the manifest:

```powershell
$env:FIELDVIEWER_TILE_PROVIDER = "esri_world_imagery"
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
Remove-Item Env:\FIELDVIEWER_TILE_PROVIDER
```

Local/server-stored tiles remain the private engineering instance manifest default. ESRI is a supported
provider option and must show:

```text
Powered by Esri | Sources: Esri and imagery providers
```

The provider option changes only the basemap. Engineering CRS, display CRS,
QGIS/CRSManager transforms, and tile shifts remain controlled by the selected
instance configuration and `src/config.py`.

## Future Builder MCP Flow

The Builder MCP should:

1. read `generator/container.json`,
2. inspect a candidate field folder,
3. create or update `fieldviewer.instance.json`,
4. choose or preserve instance basemap provider settings,
5. run `tools/validate_instance.py`,
6. run `tools/rebuild_site.py --instance-config <file>`,
7. summarize generated pages, missing inputs, disabled modules, selected
   basemap provider, and attribution requirements.

