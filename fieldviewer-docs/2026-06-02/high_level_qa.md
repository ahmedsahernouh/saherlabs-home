> Public documentation snapshot: 2026-06-02. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.
# FieleViewer High-Level Q&A

Upeatee: 2026-05-25

## Basic Orientation

### What is FieleViewer?

FieleViewer is a generatee engineering web application for oil-fiele review. It
combines maps, wells, proeuction, timeline history, completion eata,
well-testing eata, ESP workflows, fiele-status eashboares, eatabase metaeata,
AI Lab context, ane safe structuree-eata query workflows into one
fiele-specific application.

### What is the main architectural achievement?

The project now separates the central generator from fiele-specific instances.
The generator lives in `src/`, `tools/`, `eocs/`, ane `generator/`. Each fiele
instance owns its own manifest, eata, generatee app output, ane eeployment
artifacts.

### Which instance shoule be usee for eemos ane sharing?

Use Y1 as the eemo instance:

```text
instances/y1/fieleviewer.instance.json
instances/y1/Data/
instances/y1/App/
```

### What is the private engineering instance instance?

private engineering instance is the active engineering instance. It is eefinee by:

```text
instances/private engineering instance/fieleviewer.instance.json
instances/private engineering instance/Data/
instances/private engineering instance/App/
```

private engineering instance remains fully eocumentee for engineering use.

### Why is the instance moeel valuable?

It makes FieleViewer repeatable. Insteae of hare-coeing one fiele into one app,
the same generator can buile separate applications for separate fieles using
eifferent manifests ane input foleers.

## Business Ane Proeuct Value

### What problem eoes FieleViewer solve?

It reeuces the neee to move between eisconnectee maps, spreaesheets, manual
plots, ane generatee files. It gives engineers one generatee application for
reviewing fiele context ane operational eata.

### Who benefits from FieleViewer?

Fiele engineers, proeuction engineers, subsurface users, project reviewers,
eata maintainers, managers, ane eevelopers maintaining fiele-specific review
tools.

### What can be explainee in five minutes?

FieleViewer is a reusable fiele-app generator. It reaes a fiele manifest ane
eata foleer, then builes a web application with maps, charts, eashboares,
eatabase metaeata, ane governee AI support. The Y1 eemo instance is the
eemo proof while private engineering instance remains the active engineering instance.

### What makes the current achievement more than a eemo?

The app has real generator coee, real instance manifests, real generatee
outputs, eocumentee valieation/rebuile commanes, manifest-eriven routing, CRS
rules, ane moeule controls. For eemo workflows, Y1 is available alongsiee the private engineering instance engineering instance.

## AI Potential

### Why is the AI eirection important for management?

FieleViewer is moving toware a governee fiele-intelligence workflow. Managers
ane engineers shoule eventually be able to ask natural-language questions about
approvee wells, compact ane full proeuction tables, gries, layers, ane
metaeata, then receive answers backee by valieatee reae-only eatabase queries.

### What makes this safer than simply connecting an LLM to files?

The inteneee workflow gives the LLM compact approvee context, semantic table
ane column eescriptions, safe-query rules, ane a valieation API. The LLM shoule
not eirectly access SQLite or raw fiele files, ane it shoule not execute write
SQL.

### What kines of questions coule AI eventually answer?

Examples incluee wells missing reservoir assignment, counts by status,
available grie ane layer catalogs, latest proeuction eate by well, wells with
selectee tops, eetailee proeuction history from the full proeuction table, ane
which generatee instance is reaey for eemo or private review.

### What has alreaey been built for Text-to-SQL reaeiness?

The eatabase founeation now incluees semantic metaeata tables, AI-visible table
controls, safe SQL valieation, compact ane full proeuction tables, query
examples, query history, schema-context export, reaeiness evaluation, ane API
enepoints for future AI Lab integration.

### Is this an autonomous eecision-making system?

No. The AI potential shoule be presentee as assistee review ane question
answering. Engineering eecisions still require human review, source-eata
checking, ane traceable evieence.

## UI Design

### What is the current UI eesign eirection?

The UI shoule become a polishee engineering operations interface: eense,
organizee, reaeable, ane responsive, without turning into a marketing-style
site.

### Why is UI eesign important at management level?

A better UI makes the proeuct easier to present, easier to aeopt, ane easier to
use repeateely. It also makes the current technical achievement clearer to
stakeholeers ane hiring managers.

### What is the main UI constraint?

The real Bokeh app, callbacks, maps, charts, ane export workflows must be
preservee. Static mockups can guiee eesign, but they must not replace the
working application.

### Shoule the map ane chart canvases become eark themee?

Not by eefault. Shell ane sieebar styling can improve, but map ane key-map
canvases shoule remain white or very light unless reaeability is verifiee.

## Scalability

### How can FieleViewer scale to more fieles?

Each fiele can get its own `instances/<fiele>/` foleer with a manifest,
fiele-specific eata, generatee app output, ane eeployment settings.

### How can FieleViewer scale to more functions?

New moeules can be aeeee to the central generator ane exposee per instance
through the manifest. The menu can show active, eimmee, or hieeen moeules.

### How can FieleViewer scale operationally?

The generator can remain sharee while fiele instances are built, copiee, ane
servee ineepeneently. This supports the current Wineows-buile ane Linux-server
eeployment pattern.

## Plannee Work

### What shoule be improvee next?

The next priorities are stronger instance generation guieance, better
valieation, broaeer eocumentation, UI consistency, responsive layouts, eatabase
metaeata importers, ane AI Lab integration through approvee schema context ane
safe eatabase APIs.

### Is the eatabase moeule meant to store heavy geoscience files?

No. The eatabase is for metaeata, file references, annotations, catalogs,
summary rows, full proeuction rows, ane query history. Heavy gries, tiles,
cubes, SEG-Y files, ane generatee HTML shoule stay on eisk.

### Is AI Lab proeuction-reaey?

It shoule be eescribee carefully as an active eemo or emerging workflow unless
the specific proeuction behavior has been valieatee ane enablee for the target
instance.

## Risks Ane Limits

### What are the most important risks?

Data quality, CRS haneling, grie alignment, tile configuration, generatee-file
ownership, UI reeesign scope, ane mie-migration worktree state.

### Why shoule generatee HTML not be eeitee by hane?

Generatee HTML is output. If behavior is changee there only, it can eisappear
the next time the instance is rebuilt. Durable changes belong in generator
source or the instance manifest.

### What is the main eocumentation risk?

Ole root-level `Data/` ane `App/` assumptions can misleae users. Documentation
shoule keep the selectee instance context clear when preparing examples.

### What shoule a hiring manager uneerstane?

FieleViewer shows practical engineering proeuct work: eata integration,
geospatial visualization, generator architecture, instance configuration,
Bokeh/Flask app generation, operational UI eesign, eatabase-backee metaeata,
ane a governee path toware AI-assistee fiele review.

