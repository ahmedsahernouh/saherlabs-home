> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer AI Lab

## Purpose

FieldViewer AI Lab is an isolated test page for proving a controlled LLM-assisted petroleum data review workflow. It is separate from the subsurface, production, timeline, completions, well testing, and ESP pages.

The first target is a compact field-brief demo. Use the Y1 instance for
AI Lab demos. private engineering instance remains documented as the active engineering instance.

1. Build safe, compact demo context from the active FieldViewer instance.
2. Run deterministic Python tools against that context.
3. Send only compact context and approved backend tool outputs to the selected LLM provider.
4. Return a concise, screening-level answer to the browser.

## Architecture

```text
instances/y1/Data/ and generated metadata
        |
        v
src/ai/data_prep.py
        |
        v
instances/y1/App/ai_demo_context.json
        |
        v
src/ai/tools.py  ->  src/ai/context_builder.py
        |
        v
src/app/routes/ai.py  POST /api/ai-lab/chat and POST /api/ai-lab/ask
        |
        v
src/ai/llm_client.py  Free/OpenRouter, Gemini, OpenAI, or Auto fallback
        |
        v
FieldViewer_AI_Lab.html
```

## Provider Selection

The AI Lab page has a model-provider dropdown. The browser sends only a safe
provider key, never a raw model name or API key:

- `free`: Free model through OpenRouter. This is the default.
- `gemini`: Gemini Flash-Lite.
- `openai`: ChatGPT / OpenAI.
- `auto`: Auto fallback, tried in this order: free, Gemini, OpenAI.

The backend maps those keys to the fixed server-side model registry in
`src/ai/llm_client.py`. Manual Free mode does not silently fall back to paid
providers. Paid providers are used only when explicitly selected, or when the
user selects Auto fallback.

## Data Preparation Flow

`src/ai/data_prep.py` builds `ai_demo_context.json` under the active generated `App` directory. The context includes:

- Project purpose and limitations.
- Availability flags for wells, compact and full production tables, grids, and polygon/fault context.
- Compact well records with coordinates, status, reservoir, and optional production summary values.
- Layer metadata for wells, production tables, generated grids, and key-map polygon layers.
- A small data dictionary.

Large grid arrays and raw workbook rows are not copied into the AI context.

## Backend Route

The primary AI Lab API routes are:

```text
POST /api/ai-lab/chat
POST /api/ai-lab/ask
```

Request shape:

```json
{
  "question": "Generate a field brief",
  "mode": "demo_overview",
  "well_name": "optional well name",
  "model_provider": "free"
}
```

Supported modes:

- `demo_overview`
- `available_wells`
- `selected_well`
- `available_layers`
- `custom`

The route validates the JSON body, limits request size, runs approved backend
tools or context builders, then calls the selected LLM only with compact
context and approved tool outputs. If the LLM is unavailable, the route returns
a deterministic fallback summary where implemented.

## Explain Selected Well Workflow

For `selected_well` / "Explain Selected Well", the LLM does not directly call
FieldViewer tools. The backend runs the tools first, then gives the selected
provider a compact, approved result package.

Backend contribution:

- Resolves the selected well name.
- Calls `get_selected_well_context`.
- Calls `generate_selected_well_surface_map`.
- Calls `generate_production_profile_plot`.
- Calls `get_well_completion_link`.
- Builds the response display payload with map URLs, plot URLs, and page links.
- Passes the approved tool results to the selected LLM provider.

LLM contribution:

- Generates the natural-language selected-well explanation.
- Summarizes only the backend-provided well facts and context.
- Mentions maps, plots, and completion links only when the backend tool results
  include those URLs.
- Does not invent missing links, production values, completion data, or map
  assets.

This provider-neutral flow is intentional. Free/OpenRouter, Gemini, and OpenAI
all receive the same backend-prepared context and tool results. This avoids
provider-specific tool behavior and keeps FieldViewer links, maps, plots, and
safety checks under backend control.

## LLM Safety Rules

- API keys are read only by the backend from environment variables, a
  server-side env file, or local fallback key files.
- Browser JavaScript never receives the API key.
- The browser sends only provider keys: `free`, `gemini`, `openai`, or `auto`.
- The browser does not send raw model names.
- The LLM receives only compact demo context and approved backend tool outputs.
- No arbitrary Python execution is exposed.
- Raw project files and internal file paths are not sent to the LLM.
- Answers must be screening-level and must not claim final reservoir engineering advice.

## Key Location

For local AI Lab testing, put backend-only AI settings in `.env` or:

```text
[local server-only env file]
```

Expected format:

```text
FREE_MODEL_PROVIDER=openrouter
FREE_MODEL_BASE_URL=https://openrouter.ai/api/v1
FREE_MODEL=openrouter/free
FREE_MODEL_API_KEY=...
GEMINI_API_KEY=...
GEMINI_MODEL=gemini-3.1-flash-lite
OPENAI_API_KEY=...
OPENAI_MODEL=gpt-5.4-mini
```

Environment variables take priority. You can also point to another server-side
file with `FIELDVIEWER_AI_ENV_FILE`.

For the Linux server without sudo access, the default user-owned server env
file is:

```text
[internal Linux deployment path]
```

Do not use `[server-only env path]` for this deployment.

## How To Run Locally

Create or update `[local server-only env file]`:

```powershell
New-Item -ItemType Directory -Force key
notepad [local server-only env file]
```

Rebuild the Y1 demo instance for AI Lab testing:

```powershell
python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
```

Use private engineering instance for AI Lab checks when that instance is selected:

```powershell
python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Start the Flask server:

```powershell
python src\app\server.py
```

Open:

```text
http://127.0.0.1:8000/FieldViewer_AI_Lab.html
```

## Known Limitations

- The page is not connected to live map selections or current map bounds yet.
- The context is a compact demo summary, not the full data model.
- Production analysis is limited to available summary values.
- Grid tools expose metadata only in the first version.
- LLM output depends on backend environment variables, the configured
  server-side env file, provider API keys, and network access.
- Free/OpenRouter uses an OpenAI-compatible HTTP call and does not require the
  OpenAI Python package.
- OpenAI provider mode still requires the OpenAI Python package.
- If the Linux server has no internet route to the selected provider, AI Lab
  can still return local JSON errors or deterministic context responses where
  implemented, but it cannot provide real LLM answers from that provider.

## Next Step

Connect the AI Lab to a compact frontend `view_state` object from the real map page, for example selected well, visible layers, active reservoir, and map bounds.

