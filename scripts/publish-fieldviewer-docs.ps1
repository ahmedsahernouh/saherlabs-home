[CmdletBinding()]
param(
    [string]$FieldViewerRoot,
    [string]$SourceDocs,
    [string]$DestinationRoot,
    [string]$DocsStamp = (Get-Date -Format "yyyy-MM-dd"),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Resolve-AbsolutePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    return $resolved.ProviderPath
}

$repoRoot = Resolve-AbsolutePath (Join-Path $PSScriptRoot "..")
if (-not $FieldViewerRoot) {
    $codeRoot = Split-Path -Parent (Split-Path -Parent $repoRoot)
    $FieldViewerRoot = Join-Path $codeRoot "FieldViewer"
}
$FieldViewerRoot = Resolve-AbsolutePath $FieldViewerRoot

if (-not $SourceDocs) {
    $SourceDocs = Join-Path $FieldViewerRoot "docs"
}
$SourceDocs = Resolve-AbsolutePath $SourceDocs

if (-not $DestinationRoot) {
    $DestinationRoot = Join-Path $repoRoot "fieldviewer-docs"
}

if (-not ($DestinationRoot.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase))) {
    throw "DestinationRoot must stay inside the saherlabs-home repository: $DestinationRoot"
}

$destination = Join-Path $DestinationRoot $DocsStamp
$files = Get-ChildItem -LiteralPath $SourceDocs -File -Filter "*.md" | Sort-Object Name
if (-not $files) {
    throw "No markdown docs found in $SourceDocs"
}

if (-not $DryRun) {
    if (Test-Path -LiteralPath $destination) {
        Remove-Item -LiteralPath $destination -Recurse -Force
    }
    New-Item -ItemType Directory -Path $destination | Out-Null
    if (-not (Test-Path -LiteralPath $DestinationRoot)) {
        New-Item -ItemType Directory -Path $DestinationRoot | Out-Null
    }
}

foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $text = $text -replace "C32", "private engineering instance"
    $text = $text -replace "Concession 32", "private engineering instance"
    $text = $text -replace "D:\\Libya_Machine_28082025\\Code\\FieldViewer", "[local FieldViewer workspace]"
    $text = $text -replace "D:\\Computer\\Code\\FieldViewer", "[local FieldViewer workspace]"
    $text = $text -replace "D:\\Libya_Machine_28082025\\Code", "[local workspace]"
    $text = $text -replace "D:\\Computer\\Code", "[local workspace]"
    $text = $text -replace "http://10\.224\.132\.91:8000", "[internal server URL]"
    $text = $text -replace "10\.224\.132\.91", "[internal server]"
    $text = $text -replace "/geohome/owadmin/miniconda3[^\s``]*", "[internal Python environment]"
    $text = $text -replace "/geohome/owadmin/Code/geoviewer[^\s``]*", "[internal Linux deployment path]"
    $text = $text -replace "/geohome/owadmin/[^\s``]*", "[internal Linux path]"
    $text = $text -replace "/etc/fieldviewer-ai/fieldviewer\.env", "[server-only env path]"
    $text = $text -replace "key/\.env", "[local server-only env file]"
    $text = $text -replace "key\\\.env", "[local server-only env file]"

    $banner = @"
> Public documentation snapshot: $DocsStamp. Sanitized from the private FieldViewer repository docs for the public Y1 demo. Private engineering instance names, local paths, internal server addresses, and server-only environment paths were redacted.

"@
    $target = Join-Path $destination $file.Name
    Write-Host "Publish doc $($file.Name)"
    if (-not $DryRun) {
        Set-Content -LiteralPath $target -Value ($banner + $text) -Encoding UTF8
    }
}

$cards = foreach ($file in $files) {
    $safeName = [System.Net.WebUtility]::HtmlEncode($file.Name)
    $label = [System.Net.WebUtility]::HtmlEncode(($file.BaseName -replace "_", " "))
    "        <a class=""doc-card"" href=""$safeName""><strong>$label</strong><span>$safeName</span></a>"
}

$index = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>FieldViewer Public Documentation - $DocsStamp</title>
  <style>
    :root { color-scheme: light; --ink:#102542; --muted:#5f7185; --line:#d8e1ea; --brand:#378add; --bg:#f6f9fc; }
    * { box-sizing: border-box; }
    body { margin:0; font-family: Arial, Helvetica, sans-serif; color:var(--ink); background:var(--bg); }
    header { background:#fff; border-bottom:1px solid var(--line); }
    .wrap { width:min(1080px, calc(100% - 32px)); margin:0 auto; }
    .hero { padding:42px 0 30px; }
    h1 { margin:0 0 10px; font-size:clamp(28px, 4vw, 46px); line-height:1.05; letter-spacing:0; }
    p { max-width:760px; color:var(--muted); font-size:16px; line-height:1.6; }
    .meta { display:flex; flex-wrap:wrap; gap:10px; margin-top:20px; color:var(--muted); font-size:13px; }
    .pill { border:1px solid var(--line); border-radius:999px; padding:7px 10px; background:#fff; }
    main { padding:28px 0 48px; }
    .grid { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:14px; }
    .doc-card { display:flex; flex-direction:column; gap:7px; min-height:92px; padding:16px; background:#fff; border:1px solid var(--line); border-radius:8px; color:var(--ink); text-decoration:none; }
    .doc-card:hover { border-color:var(--brand); box-shadow:0 10px 24px rgba(16,37,66,.08); }
    .doc-card strong { font-size:15px; line-height:1.25; }
    .doc-card span { color:var(--muted); font-size:12px; overflow-wrap:anywhere; }
    .note { margin:0 0 20px; padding:14px 16px; background:#fff; border:1px solid var(--line); border-radius:8px; color:var(--muted); }
    @media (max-width: 820px) { .grid { grid-template-columns:1fr 1fr; } }
    @media (max-width: 560px) { .grid { grid-template-columns:1fr; } .wrap { width:min(100% - 24px, 1080px); } }
  </style>
</head>
<body>
  <header>
    <div class="wrap hero">
      <h1>FieldViewer Public Documentation</h1>
      <p>Dated documentation snapshot for the public Y1 FieldViewer demo. These files are copied from the private FieldViewer documentation set and sanitized for public access.</p>
      <div class="meta"><span class="pill">Snapshot: $DocsStamp</span><span class="pill">Public demo: Y1</span><span class="pill">Private operational details redacted</span></div>
    </div>
  </header>
  <main>
    <div class="wrap">
      <div class="note">This public snapshot is intended for visitors who cannot access the private FieldViewer repository. For source-level engineering work, use the private repository docs.</div>
      <section class="grid" aria-label="Documentation files">
$($cards -join "`n")
      </section>
    </div>
  </main>
</body>
</html>
"@

$landing = @"
<!doctype html>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=./$DocsStamp/">
<title>FieldViewer Public Documentation</title>
<a href="./$DocsStamp/">FieldViewer Public Documentation $DocsStamp</a>
"@

if (-not $DryRun) {
    Set-Content -LiteralPath (Join-Path $destination "index.html") -Value $index -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $DestinationRoot "index.html") -Value $landing -Encoding UTF8
}

$privateHits = rg -n "C32|Concession 32|D:\\|10\.224|/geohome|/etc/fieldviewer-ai|OPENAI_API_KEY=[^.]|GEMINI_API_KEY=[^.]|FREE_MODEL_API_KEY=[^.]|password\s*=|secret\s*=|private key" $DestinationRoot
if ($LASTEXITCODE -eq 0) {
    throw "Public docs snapshot still contains private-looking strings:`n$privateHits"
}
if ($LASTEXITCODE -gt 1) {
    throw "Public docs sensitivity scan failed."
}

Write-Host "Published FieldViewer public docs snapshot: $destination"
