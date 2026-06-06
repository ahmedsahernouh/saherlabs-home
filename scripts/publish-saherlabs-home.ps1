[CmdletBinding()]
param(
    [string[]]$Paths = @("index.html", "about.html", "projects.html", "resume.html", "fieldviewer-intro.html", "fieldviewer.html", "fieldviewer-ai-lab.html", "contact.html", "SEO_CLOUDFLARE_NOTES.md", "_headers", "_redirects", "robots.txt", "sitemap.xml", ".assetsignore", "wrangler.jsonc", "assets", "scripts/publish-saherlabs-home.ps1"),
    [string]$CommitMessage = "Update SaherLabs homepage",
    [switch]$NoPush,
    [switch]$NoDeploy,
    [string]$VerifyUrl = "https://saherlabs.dev/",
    [string[]]$VerifyText = @(),
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

function Invoke-ExternalChecked {
    param(
        [string]$Command,
        [string[]]$Arguments,
        [string]$WorkingDirectory = $repoRoot
    )
    Write-Host ">> $Command $($Arguments -join ' ')"
    if ($DryRun) {
        return
    }
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "command failed: $Command $($Arguments -join ' ')"
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

function New-DeployCopy {
    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    $deployRoot = Join-Path $env:TEMP "saherlabs-home-deploy-$stamp"
    New-Item -ItemType Directory -Path $deployRoot | Out-Null

    $excludeDirs = @(".git", "node_modules", ".wrangler")
    $excludeFiles = @(".env", "*.log", "*.jsonl")
    $args = @($repoRoot, $deployRoot, "/E")
    foreach ($dir in $excludeDirs) { $args += @("/XD", $dir) }
    foreach ($file in $excludeFiles) { $args += @("/XF", $file) }
    & robocopy @args | Out-Null
    if ($LASTEXITCODE -gt 7) {
        throw "robocopy failed while preparing deploy copy"
    }

    $redirectsPath = Join-Path $deployRoot "_redirects"
    if (Test-Path -LiteralPath $redirectsPath) {
        $filtered = Get-Content -LiteralPath $redirectsPath | Where-Object {
            $parts = $_.Trim() -split "\s+"
            if ($parts.Count -lt 2) { return $true }
            $source = $parts[0]
            $target = $parts[1]
            return (($source -notmatch "^https?://") -and ($target -notmatch "^https?://"))
        }
        Set-Content -LiteralPath $redirectsPath -Value $filtered -Encoding utf8
    }

    return $deployRoot
}

function Invoke-CloudflareDeploy {
    $deployRoot = New-DeployCopy
    Write-Host "Prepared deploy copy: $deployRoot"
    Push-Location $deployRoot
    try {
        Invoke-ExternalChecked -Command "npx" -Arguments @("wrangler", "deploy") -WorkingDirectory $deployRoot
    } finally {
        Pop-Location
    }
}

function Test-LiveContent {
    if (-not $VerifyUrl) {
        return
    }
    $separator = if ($VerifyUrl.Contains("?")) { "&" } else { "?" }
    $url = "$VerifyUrl$separator" + "deploycheck=$(Get-Date -Format yyyyMMddHHmmss)"
    Write-Host ">> verify $url"
    if ($DryRun) {
        return
    }
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    foreach ($text in $VerifyText) {
        if ($response.Content -notlike "*$text*") {
            throw "Live verification failed. Missing text: $text"
        }
    }
    Write-Host "Live verification passed: $url"
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
    if (-not $NoDeploy) {
        Invoke-CloudflareDeploy
        Test-LiveContent
    }
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

if (-not $NoDeploy) {
    Invoke-CloudflareDeploy
    Test-LiveContent
} else {
    Write-Host "Cloudflare deploy skipped because -NoDeploy was supplied."
}
