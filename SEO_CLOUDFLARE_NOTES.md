# SaherLabs SEO Cloudflare Notes

Updated: 2026-06-05

## Canonical Host

The SEO target for the public site is:

```text
https://saherlabs.dev/
```

Desired canonical behavior:

```text
https://www.saherlabs.dev/* -> https://saherlabs.dev/*
```

The path and query string should be preserved.

## Current Repository Scope

The root repository now provides SEO-facing pages for:

```text
/
/about
/fieldviewer-ai-lab
/fieldviewer-intro
/projects
/resume
/contact
```

Cloudflare Pages serves the clean URLs from the matching root `.html` files. The `_redirects` file intentionally canonicalizes direct `.html` requests back to clean URLs and keeps `/fv` as a short link to the live FieldViewer demo.

The repository includes `fieldviewer.html` as the intended future SEO landing page for `https://saherlabs.dev/fieldviewer`, but the live `/fieldviewer` route is currently intercepted by a Cloudflare-side redirect to `https://fieldviewer.saherlabs.dev/`. Until that Cloudflare rule is removed, the sitemap and primary internal links should use `/fieldviewer-intro` instead of advertising `/fieldviewer`.

The `_redirects` file does not try to force the `www` hostname from repository code because that only works when the `www` request is already reaching this Pages project.

## Manual Cloudflare Action

If `https://www.saherlabs.dev/` serves different or older content than `https://saherlabs.dev/`, treat it as a Cloudflare custom-domain or routing issue.

Manual actions:

1. Ensure `www.saherlabs.dev` is not attached to an old Pages project.
2. Attach `www.saherlabs.dev` to the correct `saherlabs-home-git` Pages project, or configure a Cloudflare Redirect Rule or Bulk Redirect.
3. Remove or replace any Cloudflare rule that redirects `https://saherlabs.dev/fieldviewer` to `https://fieldviewer.saherlabs.dev/` if the `/fieldviewer` SEO landing page should go live.
4. Target redirect:

```text
https://www.saherlabs.dev/* -> https://saherlabs.dev/*
```

Use a 301 redirect and preserve the path and query string.
