> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# AI Lab Question Router

Updated: 2026-05-26

## Purpose

The AI Lab question router adds one unified backend workflow for natural-language questions:

```text
POST /api/ai-lab/ask
-> LLM classifier, with deterministic fallback for offline evaluation
-> button_question | text_to_sql | custom_question | rejected
-> approved existing AI Lab mode, safe Text-to-SQL, context-only custom answer, or clean rejection
```

The router does not let the LLM execute SQL. SQL is generated as text, validated by the existing database validator, and executed only through the existing safe SQLite adapter.

The router also does not rely on provider-specific tool calling for button
questions. For tool-backed button modes, the backend builds the approved tool
results first, then asks the selected provider to produce the final language
answer from those approved results.

## Route

```http
POST /api/ai-lab/ask
```

Input:

```json
{
  "question": "List all wells with coordinates",
  "instance_id": "y1",
  "selected_well": "optional",
  "mode": "auto"
}
```

Output includes:

- `route`: `button_question`, `text_to_sql`, `custom_question`, or `rejected`
- `classification`: strict classifier result
- `answer`: final answer text
- `display`: existing AI Lab map, plot, and link display payload
- `sql`: generated SQL, validation, executed SQL, rows, row count, and timing for Text-to-SQL
- `warnings`: safe non-secret warnings

## Classification

The classifier receives the original user question and compact routing instructions. It must return strict JSON only:

```json
{
  "route": "button_question",
  "confidence": "high",
  "button_mode": "demo_overview",
  "requires_selected_well": false,
  "selected_well": null,
  "reason": "matched field overview",
  "is_field_related": true
}
```

No SQL generation or answer generation is allowed during classification.

## Button Questions

`button_question` delegates to the existing `/api/ai-lab/chat` workflow and current modes:

- `demo_overview`
- `management_brief`
- `selected_well`
- `available_wells`
- `available_layers`
- `data_catalog`

Existing buttons remain visible in the generated AI Lab page.

### Explain Selected Well

`selected_well` / "Explain Selected Well" uses a provider-neutral backend tool
pipeline:

1. Resolve the selected well name.
2. Run `get_selected_well_context`.
3. Run `generate_selected_well_surface_map`.
4. Run `generate_production_profile_plot`.
5. Run `get_well_completion_link`.
6. Build the display payload with approved links, maps, and plots.
7. Send the compact context and tool results to the selected provider.

The LLM's role is natural-language generation only. It summarizes the approved
backend facts and should not invent missing links, production values,
completion data, or map assets. Free/OpenRouter, Gemini, and OpenAI receive the
same backend-prepared result package; the providers do not run separate tool
pipelines.

## Text-to-SQL

`text_to_sql` uses this controlled sequence:

1. Load compact schema context from AI-visible database metadata.
2. Ask the LLM for one SQLite-compatible `SELECT`/`WITH` query, or use deterministic fallback for offline evaluation.
3. Validate SQL with the existing query validator.
4. Optionally ask for one repair if validation fails.
5. Execute only validated SQL through the existing safe database adapter.
6. Summarize only the returned SQL result.
7. Record SQL execution in `db_query_history`.

Invalid SQL is not executed.

## Custom Questions

`custom_question` answers only from the generated FieldViewer AI Lab context bundle. Unrelated questions are rejected. If the current demo context does not contain the needed information, the answer should say:

```text
This information is not available in the current FieldViewer demo context.
```

## Configuration

AI model selection is separate from routing. The frontend sends only these safe
provider keys:

- `free`
- `gemini`
- `openai`
- `auto`

The backend maps provider keys to the fixed registry in `src/ai/llm_client.py`.
Free/OpenRouter is the default. Manual Free mode does not silently fall back to
paid providers; Auto fallback tries free, then Gemini, then OpenAI.

Instance manifests can enable the router:

```json
"ai_lab": {
  "question_router": {
    "enabled": true,
    "allow_text_to_sql": true,
    "allow_custom_questions": true,
    "reject_unrelated_questions": true,
    "max_sql_result_rows_for_summary": 50,
    "sql_repair_attempts": 1
  }
}
```

## Evaluation

Offline evaluation:

```powershell
python tools\evaluate_ai_lab_router.py --instance-config instances\y1\fieldviewer.instance.json
python tools\evaluate_ai_lab_router.py --instance-config instances\private engineering instance\fieldviewer.instance.json
```

Manual endpoint test:

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8000/api/ai-lab/ask -ContentType application/json -Body '{"question":"List all wells with coordinates","instance_id":"y1"}'
```

