# www.saherlabs.dev Deployment Diagnosis

Updated: 2026-06-02

## What Was Checked

- Git status and recent commits for `saherlabs-home`.
- Root homepage files, FieldViewer deployment files, `_redirects`, and Wrangler
  configs for:
  - `www.saherlabs.dev`
  - `saherlabs.dev`
  - `fieldviewer.saherlabs.dev`
  - old/stale homepage phrases
- Root and FieldViewer file sizes and modification dates.
- Duplicate `fieldviewer-intro` routes.
- Live responses for:
  - `https://saherlabs.dev/`
  - `https://www.saherlabs.dev/`
  - `https://saherlabs.dev/about`
  - `https://www.saherlabs.dev/about`
  - `https://saherlabs.dev/fieldviewer-intro`
  - `https://www.saherlabs.dev/fieldviewer-intro`

## Repository Findings

- Root `index.html` contains `Applied subsurface intelligence tools`.
- Live `https://saherlabs.dev/` and `https://www.saherlabs.dev/` both currently
  return the same homepage content with that phrase, so this phrase is not
  evidence that `www` is serving an older repository file.
- No repository file was found that specifically routes `www.saherlabs.dev` to a
  different local page.
- `_redirects` was incomplete and only contained `/about /about.html 301`.
- The stale duplicate route `fieldviewer-intro/index.html` was still tracked.

## Repository Changes Made

- Added the intended clean redirect:

```text
/fieldviewer-intro /fieldviewer-intro.html 301
```

- Removed the duplicate tracked folder route:

```text
fieldviewer-intro/index.html
```

The preferred page remains:

```text
fieldviewer-intro.html
```

## Current www Diagnosis

`https://www.saherlabs.dev/` currently returns `200` with the same content as
`https://saherlabs.dev/`; it does not issue a redirect to the apex domain.

That canonical host behavior is not safely fixable with the repository
`_redirects` file alone. A Pages `_redirects` rule is path-based for traffic that
already reaches this Pages project. Adding a broad rule such as:

```text
/* https://saherlabs.dev/:splat 301
```

would risk redirecting apex traffic too if both hostnames are attached to the
same Pages project.

## Required Cloudflare Change

Add a Cloudflare Redirect Rule or equivalent zone-level rule:

```text
When incoming request hostname equals: www.saherlabs.dev
Then redirect to: https://saherlabs.dev/${path}
Status code: 301
Preserve query string: enabled
```

Expected behavior:

```text
https://www.saherlabs.dev/
-> https://saherlabs.dev/

https://www.saherlabs.dev/about
-> https://saherlabs.dev/about

https://www.saherlabs.dev/fieldviewer-intro
-> https://saherlabs.dev/fieldviewer-intro
```

If `www.saherlabs.dev` is attached to an old or wrong Cloudflare Pages project,
remove it from that project first, then configure the redirect at the zone level
or attach it only to the correct Pages project with an explicit host redirect.

## Desired Final State

```text
https://saherlabs.dev/             canonical homepage
https://www.saherlabs.dev/         redirects to https://saherlabs.dev/
https://www.saherlabs.dev/about    redirects to https://saherlabs.dev/about
https://fieldviewer.saherlabs.dev/ remains FieldViewer app
https://api.saherlabs.dev/         remains backend API
```
