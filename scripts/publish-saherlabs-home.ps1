[CmdletBinding()]
param(
    [string[]]$Paths = @("index.html", "about.html", "projects.html", "resume.html", "fieldviewer-intro.html", "_redirects", "robots.txt", "sitemap.xml", ".assetsignore", "wrangler.jsonc", "assets", "scripts/publish-saherlabs-home.ps1"),
    [string]$CommitMessage = "Update SaherLabs homepage",
    [switch]$NoPush,
    [switch]$AllowDirtyOutsidePaths,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..") | Select-Object -ExpandProperty ProviderPath

function Invoke-Checked {
    param([string[]]$Arguments)
    Write-Host ">> git $($Arguments -join ' ')"
    if ($DryRun) {
        return
    }
    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git command failed: git $($Arguments -join ' ')"
    }
}

function Test-PrivatePath {
    param([string]$Path)
    $leaf = Split-Path -Leaf $Path
    return (
        $leaf -like "*.env" -or
        $leaf -eq ".env" -or
        $leaf -like "*.log" -or
        $leaf -like "*.jsonl" -or
        $leaf -like "*.db" -or
        $leaf -like "*.sqlite" -or
        $leaf -like "*.sqlite3" -or
        $leaf -eq "content.txt"
    )
}

$private = foreach ($path in $Paths) {
    if (Test-PrivatePath $path) { $path }
}
if ($private) {
    throw "Refusing to publish private-looking path(s): $($private -join ', ')"
}

$status = & git -C $repoRoot status --porcelain
if ($status -and -not $AllowDirtyOutsidePaths) {
    $allowed = $Paths | ForEach-Object { $_ -replace "\\", "/" }
    $outside = foreach ($line in $status) {
        $changedPath = $line.Substring(3) -replace "\\", "/"
        $matched = $false
        foreach ($path in $allowed) {
            if ($changedPath -eq $path -or $changedPath.StartsWith("$path/")) {
                $matched = $true
                break
            }
        }
        if (-not $matched) { $line }
    }
    if ($outside) {
        throw "Found changes outside requested publish paths. Commit/stash them or rerun with -AllowDirtyOutsidePaths.`n$($outside -join "`n")"
    }
}

$changedInScope = @()
foreach ($path in $Paths) {
    $result = & git -C $repoRoot status --porcelain -- $path
    if ($result) {
        $changedInScope += $result
    }
}

if (-not $changedInScope) {
    Write-Host "No SaherLabs homepage changes detected in requested paths."
    exit 0
}

Write-Host "Publishing these changes:"
Write-Host ($changedInScope -join "`n")

$addArgs = @("-C", $repoRoot, "add", "--") + $Paths
Invoke-Checked -Arguments $addArgs
Invoke-Checked -Arguments @("-C", $repoRoot, "commit", "-m", $CommitMessage)
Invoke-Checked -Arguments @("-C", $repoRoot, "pull", "--rebase", "origin", "main")
if (-not $NoPush) {
    Invoke-Checked -Arguments @("-C", $repoRoot, "push")
} else {
    Write-Host "Commit created but push skipped because -NoPush was supplied."
}
