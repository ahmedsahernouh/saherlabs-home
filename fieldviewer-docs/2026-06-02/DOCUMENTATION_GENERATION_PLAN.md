> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieldViewer Documentation Generation Plan

Updated: 2026-05-29

This guide defines how to generate, update, and maintain FieldViewer
documentation at three audience levels. It is also the maintenance plan for the
generated documentation set listed below.

## Purpose

FieldViewer documentation should explain the project clearly to different
audiences without mixing their needs into one large document. Every major
documentation refresh should produce two forms for each audience level:

- typical documentation: structured explanatory documentation
- Q&A study format: questions and answers for review, interview preparation,
  and quick knowledge checks

The documentation should be updated whenever a commit or push changes project
behavior, architecture, deployment, instance generation, data contracts, UI
workflow, UI design, visual standards, responsive behavior, or known
limitations.

## Documentation Levels

### 1. High-Level Documentation

Audience:

- management
- hiring managers
- non-specialist technical reviewers
- stakeholders needing a five-minute explanation

Goal:

Explain what FieldViewer is, what has already been achieved, why it matters,
what is planned, and how the system can scale.

Required content:

- short project description
- business and engineering value
- current achievements
- active modules and visible capabilities
- planned functions
- scalability and reuse potential
- AI potential, governed Text-to-SQL value, and management-facing examples of
  safe natural-language field questions
- UI design direction and product presentation value
- deployment and instance-generation concept at a non-technical level
- risks and dependencies stated briefly
- documentation rule: keep complete Y1 and private engineering instance instance guidance unless a separate publication policy is requested

Tone:

- brief
- descriptive
- attractive
- clear enough for a five-minute verbal explanation

Required forms:

- `docs/high_level_overview.md`
- `docs/high_level_qa.md`

### 2. User-Level Documentation

Audience:

- field users
- project engineers
- power users generating or validating field instances
- users who need to understand required inputs and operational limits

Goal:

Explain what is needed to generate, validate, run, and review a FieldViewer
instance.

Required content:

- required folder structure for an instance
- distinction between the private engineering instance engineering instance and the Y1 demo instance
- table of configurable variables, manifest locations, source file locations,
  examples, and safe-change instructions
- required manifest: `fieldviewer.instance.json`
- required input files and expected locations
- validation command
- rebuild command
- server command and local URLs
- what generated outputs are expected
- UI layout, navigation, page purpose, and visual usage expectations
- UI design constraints that affect daily use, readability, maps, charts, and
  dashboards
- common bottlenecks
- critical issues and checks before trusting output
- possible uncertainties in source data, CRS, tiles, grids, and production
  inputs
- clear distinction between generator code and instance-specific data/output

Tone:

- practical
- step-by-step
- honest about risks and uncertain inputs
- focused on real usage

Required forms:

- `docs/user_instance_guide.md`
- `docs/user_instance_qa.md`

### 3. Coder-Level Documentation

Audience:

- developers
- coding assistants
- technical interviewers
- maintainers studying the system
- engineers reviewing architecture, limits, and improvement paths

Goal:

Provide a detailed technical handover of the system, including architecture,
source ownership, limitations, known problems, performance bottlenecks, and
recommended improvements.

Required content:

- repository architecture
- generator and instance split
- manifest-driven behavior
- core source modules and responsibilities
- build, validation, server, and QC workflows
- CRS and basemap logic
- generated output ownership rules
- UI and Bokeh callback architecture
- UI design system, layout rules, theme constraints, responsive behavior, and
  designer handoff notes
- data contracts and fragile assumptions
- instance documentation rules for both Y1 and private engineering instance
- known limitations
- critical technical bottlenecks
- recommended functionality improvements
- recommended performance improvements
- testing and verification approach
- technical interview study notes
- interviewer-style questions and answers that test architecture, ownership
  boundaries, configuration, CRS, generation, UI, database, and limitations

Tone:

- detailed
- precise
- direct about limitations
- useful as handover, study reference, and technical interview material

Required forms:

- `docs/coder_handover.md`
- `docs/coder_handover_qa.md`

## Current Generated Documentation Set

The current generated documentation set is:

- `docs/high_level_overview.md`
- `docs/high_level_qa.md`
- `docs/user_instance_guide.md`
- `docs/user_instance_qa.md`
- `docs/coder_handover.md`
- `docs/coder_handover_qa.md`

These files should be reviewed whenever the documentation update rules below
are triggered.

## Source Material To Read Before Regeneration

Before generating or updating the documentation set, review:

1. `AGENTS.md`
2. `README.md`
3. `AI_HANDOVER.md`
4. `docs/HANDOVER.md`
5. `docs/RECOVERY_HANDOVER.md`
6. `docs/INSTANCE_CONFIG.md`
7. `docs/GENERATOR_INSTANCE_SPLIT.md`
8. `docs/UI_DESIGN_HANDOFF.md` for UI design, theme, layout, responsive, and
   designer-handoff topics
9. `src/config.py`
10. `instances/private engineering instance/fieldviewer.instance.json`
11. `instances/y1/fieldviewer.instance.json` for demo workflows

If the documentation topic touches database functionality, also review:

1. `docs/DB_MODULE.md`
2. `src/db/`
3. `src/app/routes/db_api.py`
4. `src/app/pages/database.py`
5. `src/db/schema.py`, `src/db/sqlite_adapter.py`, and `src/db/views.py` for
   physical tables such as `production_full`, safe views such as
   `v_production_full`, and DB page behavior.
5. `tools/init_db.py`
6. `tools/smoke_test_db.py`
7. `tools/load_db_from_instance.py`
8. `tools/export_db_schema_context.py`
9. `tools/evaluate_text_to_sql_readiness.py`
10. `docs/TEXT_TO_SQL_DB_READINESS.md`

## Generation Workflow

Use this workflow for a full documentation refresh:

1. Check repository status.

   ```powershell
   git status --short
   ```

2. Read the source material listed above.

3. Identify what changed since the last documentation update:

   ```powershell
   git diff --stat
   git diff --name-only
   ```

4. Validate the affected instance when instance paths, manifests, runtime
   behavior, generated pages, or configuration changed:

   ```powershell
   python tools\validate_instance.py instances\private engineering instance\fieldviewer.instance.json
   python tools\validate_instance.py instances\y1\fieldviewer.instance.json
   ```

5. Rebuild the affected instance when generator behavior, page generation,
   UI output, or manifest-driven output changed:

   ```powershell
   python tools\rebuild_site.py --instance-config instances\private engineering instance\fieldviewer.instance.json
   python tools\rebuild_site.py --instance-config instances\y1\fieldviewer.instance.json
   ```

6. Run regression QC when CRS, geometry, grids, maps, generated pages, outputs,
   or shared runtime behavior changed:

   ```powershell
   python tools\qc_regression_suite.py
   ```

7. Update the six documentation outputs:

   - `docs/high_level_overview.md`
   - `docs/high_level_qa.md`
   - `docs/user_instance_guide.md`
   - `docs/user_instance_qa.md`
   - `docs/coder_handover.md`
   - `docs/coder_handover_qa.md`

8. Update the `Updated:` date in every changed documentation file.

9. Confirm that the documentation matches the current source tree and does not
   describe old root-level `Data/` or `App/` assumptions as current private engineering instance
   behavior.

10. Review the final documentation diff before committing:

   ```powershell
   git diff -- docs
   ```

## Commit And Push Update Rule

Documentation must be reviewed on every commit or push that affects:

- architecture
- instance generation
- manifests
- input or output paths
- validation or rebuild commands
- server routing
- generated pages
- UI behavior
- UI design, theme, layout, responsive behavior, or visual standards
- CRS, basemap, grid, or geometry logic
- database behavior
- known limitations, risks, or troubleshooting steps

For small code-only changes, update only the affected documentation level. For
architecture, workflow, or user-facing changes, update all relevant levels and
their Q&A files.

Before each commit, ask:

1. Does this change alter what FieldViewer does?
2. Does this change alter how an instance is generated or validated?
3. Does this change alter what a user sees or exports?
4. Does this change alter deployment, routing, paths, or server behavior?
5. Does this change introduce or remove a limitation?
6. Does this change alter UI design expectations, layout, colors, page
   hierarchy, or responsive behavior?
7. Would a new developer misunderstand the project if the docs are not updated?

If the answer is yes to any question, update documentation in the same commit.

Before each push, run a final documentation consistency check:

```powershell
git diff --name-only origin/master...HEAD
```

Then confirm that any changed source areas are reflected in the matching
documentation level.

## Documentation Quality Rules

- Keep generated documentation grounded in the real repository.
- Do not invent completed features.
- Separate completed work, planned work, and potential future improvements.
- State limitations directly.
- Keep private engineering instance instance paths instance-based and engineering instance:
  `instances/private engineering instance/fieldviewer.instance.json`, `instances/private engineering instance/Data/`, and
  `instances/private engineering instance/App/`.
- Use Y1 as the demo instance:
  `instances/y1/fieldviewer.instance.json`, `instances/y1/Data/`, and
  `instances/y1/App/`.
- Keep private engineering instance data paths, screenshots, generated pages, and operational details documented when they are needed for engineering handover.
- Treat generated HTML as output. Persistent behavior should be documented as
  generator or manifest behavior.
- Keep high-level documentation short and readable.
- Keep user documentation operational and command-focused.
- Keep coder documentation detailed enough for handover and technical review.
- Keep UI design documentation present at all three levels:
  management-facing value and polish, user-facing layout and workflow
  expectations, and coder-facing implementation constraints.
- UI design documentation must preserve the real Bokeh application, callbacks,
  maps, charts, and instance-generated pages as the source of truth.
- Do not describe static mockups as the delivered UI unless they are explicitly
  marked as design references.
- In Q&A files, include both basic and difficult questions.
- Include questions about limitations, bottlenecks, and uncertainties, not only
  successful workflows.

## Suggested Q&A Structure

Each Q&A document should include:

- basic orientation questions
- workflow questions
- troubleshooting questions
- limitation and risk questions
- improvement and scalability questions
- interview-style technical questions where appropriate

Answers should be concise but complete enough to stand alone.

## Remaining Decisions

The six generated documentation files listed above are now the adopted output
set. These follow-up decisions remain:

1. Whether older top-level docs such as `MANAGER_OVERVIEW.md`,
   `PROJECT_ARCHITECTURE.md`, and `README_USERS.md` should be replaced,
   preserved, or cross-linked.
2. Whether a Git hook or CI check should enforce documentation review before
   commit or push.
3. Whether documentation should be regenerated manually by agents or through a
   scripted helper under `tools/`.

