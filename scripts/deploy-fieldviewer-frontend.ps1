[CmdletBinding()]
param(
    [string]$FieldViewerRoot,
    [string]$InstanceConfig,
    [string]$SourceApp,
    [string]$Destination,
    [string]$BackendApiBase = "https://api.saherlabs.dev",
    [string]$CommitMessage = "Deploy FieldViewer frontend",
    [switch]$SkipValidate,
    [switch]$SkipRebuild,
    [switch]$NoCommit,
    [switch]$NoPush,
    [switch]$AllowDirty,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Resolve-AbsolutePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    return $resolved.ProviderPath
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$WorkingDirectory
    )
    $display = "$FilePath $($Arguments -join ' ')"
    Write-Host ">> $display"
    if ($DryRun) {
        return
    }
    if ($WorkingDirectory) {
        Push-Location $WorkingDirectory
    }
    try {
        & $FilePath @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed: $display"
        }
    } finally {
        if ($WorkingDirectory) {
            Pop-Location
        }
    }
}

function Assert-CleanRepo {
    param([string]$RepoRoot)
    $status = (& git -C $RepoRoot status --porcelain)
    if ($status -and -not $AllowDirty) {
        throw "Repository has existing changes. Commit/stash them or rerun with -AllowDirty.`n$status"
    }
}

function Test-ExcludedPath {
    param([string]$RelativePath)
    $leaf = Split-Path -Leaf $RelativePath
    $normalized = $RelativePath -replace "\\", "/"
    $excludedNames = @(".git", "__pycache__", ".venv", "venv", "node_modules", ".wrangler")
    $excludedPatterns = @(
        ".env",
        "*.env",
        "*.log",
        "*.jsonl",
        "*.db",
        "*.sqlite",
        "*.sqlite3",
        "content.txt",
        ".dev.vars",
        ".dev.vars*"
    )
    foreach ($name in $excludedNames) {
        if ($leaf -eq $name -or $normalized -like "*/$name/*") {
            return $true
        }
    }
    foreach ($pattern in $excludedPatterns) {
        if ($leaf -like $pattern) {
            return $true
        }
    }
    return $false
}

function Get-RelativeChildPath {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$ChildPath
    )
    $baseFull = [System.IO.Path]::GetFullPath($BasePath).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $childFull = [System.IO.Path]::GetFullPath($ChildPath)
    if (-not $childFull.StartsWith($baseFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is not inside base path: $ChildPath"
    }
    return $childFull.Substring($baseFull.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
}

function Clear-Destination {
    param([string]$DestinationPath)
    $preserve = @("wrangler.jsonc")
    if (-not (Test-Path -LiteralPath $DestinationPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $DestinationPath | Out-Null
        }
        return
    }
    Get-ChildItem -LiteralPath $DestinationPath -Force | ForEach-Object {
        if ($preserve -contains $_.Name) {
            return
        }
        Write-Host "Remove $($_.FullName)"
        if (-not $DryRun) {
            Remove-Item -LiteralPath $_.FullName -Recurse -Force
        }
    }
}

function Copy-PublicApp {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )
    Get-ChildItem -LiteralPath $SourcePath -Recurse -Force | ForEach-Object {
        $relative = Get-RelativeChildPath -BasePath $SourcePath -ChildPath $_.FullName
        if (Test-ExcludedPath $relative) {
            Write-Host "Skip private/excluded: $relative"
            return
        }
        $target = Join-Path $DestinationPath $relative
        if ($_.PSIsContainer) {
            if (-not $DryRun -and -not (Test-Path -LiteralPath $target)) {
                New-Item -ItemType Directory -Path $target | Out-Null
            }
            return
        }
        $targetParent = Split-Path -Parent $target
        if (-not $DryRun -and -not (Test-Path -LiteralPath $targetParent)) {
            New-Item -ItemType Directory -Path $targetParent | Out-Null
        }
        Write-Host "Copy $relative"
        if (-not $DryRun) {
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
    }
}

function Test-ForbiddenDeploymentFiles {
    param([string]$DestinationPath)
    $bad = Get-ChildItem -LiteralPath $DestinationPath -Recurse -Force -File |
        Where-Object { Test-ExcludedPath (Get-RelativeChildPath -BasePath $DestinationPath -ChildPath $_.FullName) }
    if ($bad) {
        $list = ($bad | ForEach-Object { $_.FullName }) -join "`n"
        throw "Forbidden files are present in deployment folder:`n$list"
    }
}

function Test-BokehJson {
    param([string]$HtmlPath)
    $script = @"
import json
import pathlib
import re
import sys
path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8", errors="replace")
blocks = re.findall(r'<script type="application/json" id="[^"]+">(.*?)</script>', text, re.S)
for block in blocks:
    json.loads(block)
print(f"bokeh_json_blocks={len(blocks)}")
"@
    $script | python - $HtmlPath
    if ($LASTEXITCODE -ne 0) {
        throw "Bokeh JSON validation failed for $HtmlPath"
    }
}

$repoRoot = Resolve-AbsolutePath (Join-Path $PSScriptRoot "..")
if (-not $FieldViewerRoot) {
    $codeRoot = Split-Path -Parent (Split-Path -Parent $repoRoot)
    $FieldViewerRoot = Join-Path $codeRoot "FieldViewer"
}
$FieldViewerRoot = Resolve-AbsolutePath $FieldViewerRoot

if (-not $InstanceConfig) {
    $InstanceConfig = Join-Path $FieldViewerRoot "instances\y1\fieldviewer.instance.json"
}
if (-not $SourceApp) {
    $SourceApp = Join-Path $FieldViewerRoot "instances\y1\App"
}
if (-not $Destination) {
    $Destination = Join-Path $repoRoot "FieldViewer"
}

$InstanceConfig = Resolve-AbsolutePath $InstanceConfig
$SourceApp = Resolve-AbsolutePath $SourceApp
$Destination = Resolve-AbsolutePath $Destination

if (-not ($Destination.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase))) {
    throw "Destination must stay inside the saherlabs-home repository: $Destination"
}
if (-not ($SourceApp.StartsWith($FieldViewerRoot, [System.StringComparison]::OrdinalIgnoreCase))) {
    throw "Source app must stay inside FieldViewer root: $SourceApp"
}

$manifest = Get-Content -LiteralPath $InstanceConfig -Raw | ConvertFrom-Json
if ($manifest.instance.id -ne "y1") {
    throw "Refusing to deploy non-Y1 instance: $($manifest.instance.id)"
}
if (-not $manifest.demo.is_demo_instance) {
    throw "Refusing to deploy instance without demo.is_demo_instance=true"
}

Assert-CleanRepo $repoRoot

if (-not $SkipValidate) {
    Invoke-Checked -FilePath "python" -Arguments @("tools\validate_instance.py", $InstanceConfig) -WorkingDirectory $FieldViewerRoot
}
if (-not $SkipRebuild) {
    Invoke-Checked -FilePath "python" -Arguments @("tools\rebuild_site.py", "--instance-config", $InstanceConfig) -WorkingDirectory $FieldViewerRoot
}

foreach ($required in @("menu.html", "FieldViewer.html", "FieldViewer_AI_Lab.html")) {
    if (-not (Test-Path -LiteralPath (Join-Path $SourceApp $required))) {
        throw "Expected generated file missing from Y1 App: $required"
    }
}

Clear-Destination $Destination
Copy-PublicApp -SourcePath $SourceApp -DestinationPath $Destination
if (-not $DryRun) {
    $indexHtml = Join-Path $Destination "index.html"
    $menuHtml = Join-Path $Destination "menu.html"
    if (-not (Test-Path -LiteralPath $indexHtml) -and (Test-Path -LiteralPath $menuHtml)) {
        Write-Host "Create index.html from menu.html"
        Copy-Item -LiteralPath $menuHtml -Destination $indexHtml -Force
    }
    Test-ForbiddenDeploymentFiles $Destination
}

$aiLabHtml = Join-Path $Destination "FieldViewer_AI_Lab.html"
if (Test-Path -LiteralPath $aiLabHtml) {
    Test-BokehJson $aiLabHtml
    $aiLabContent = Get-Content -LiteralPath $aiLabHtml -Raw
    if ($BackendApiBase -and -not $aiLabContent.Contains($BackendApiBase)) {
        throw "AI Lab page does not contain expected backend API base: $BackendApiBase"
    }
}

$databaseHtml = Join-Path $Destination "FieldViewer_Database.html"
if (Test-Path -LiteralPath $databaseHtml) {
    $databaseContent = Get-Content -LiteralPath $databaseHtml -Raw
    if ($BackendApiBase -and -not $databaseContent.Contains($BackendApiBase)) {
        throw "Database page does not contain expected backend API base: $BackendApiBase"
    }
}

$changed = (& git -C $repoRoot status --porcelain -- FieldViewer)
if (-not $changed) {
    Write-Host "No FieldViewer deployment changes detected."
    exit 0
}

Write-Host "Deployment changes:"
Write-Host $changed

if ($NoCommit) {
    Write-Host "Leaving changes uncommitted because -NoCommit was supplied."
    exit 0
}

Invoke-Checked -FilePath "git" -Arguments @("-C", $repoRoot, "add", "--", "FieldViewer") -WorkingDirectory $repoRoot
Invoke-Checked -FilePath "git" -Arguments @("-C", $repoRoot, "commit", "-m", $CommitMessage) -WorkingDirectory $repoRoot
Invoke-Checked -FilePath "git" -Arguments @("-C", $repoRoot, "pull", "--rebase", "origin", "main") -WorkingDirectory $repoRoot

if (-not $NoPush) {
    Invoke-Checked -FilePath "git" -Arguments @("-C", $repoRoot, "push") -WorkingDirectory $repoRoot
} else {
    Write-Host "Commit created but push skipped because -NoPush was supplied."
}
