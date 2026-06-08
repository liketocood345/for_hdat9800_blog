# Render Quarto (.qmd) blog posts with distill via rmarkdown (not quarto CLI plain HTML).
# Distill Rmd pages (index.Rmd, about.Rmd) still use rmarkdown::render_site().
#
# Usage:
#   powershell -File tools/render-qmd-posts.ps1                 # skip draft: true
#   powershell -File tools/render-qmd-posts.ps1 -IncludeDrafts  # include drafts (local preview)
#   powershell -File tools/render-qmd-posts.ps1 -PostPath "_posts/.../file.qmd"

param(
    [switch]$IncludeDrafts,
    [string]$PostPath = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if (-not (Get-Command Rscript -ErrorAction SilentlyContinue)) {
    Write-Error "Rscript not on PATH. Add R bin to PATH or run from RStudio."
}

function Test-DraftPost {
    param([string]$File)
    $head = Get-Content $File -TotalCount 30 -Encoding UTF8
    return ($head -match '^\s*draft:\s*true\s*$')
}

function Get-QmdPosts {
    if ($PostPath) {
        return @(Resolve-Path $PostPath)
    }
    return Get-ChildItem -Path "_posts" -Recurse -Filter "*.qmd" -File |
        Where-Object { $_.Name -notmatch '^_' }
}

$posts = Get-QmdPosts
if ($posts.Count -eq 0) {
    Write-Host "No .qmd posts found."
    exit 0
}

foreach ($post in $posts) {
    $isDraft = Test-DraftPost $post.FullName
    if ($isDraft -and -not $IncludeDrafts) {
        Write-Host "[skip draft] $($post.FullName)"
        continue
    }
    $rel = $post.FullName
    if ($rel.StartsWith($Root)) {
        $rel = $rel.Substring($Root.Length).TrimStart('\', '/')
    }
    $rel = $rel -replace '\\', '/'
    Write-Host "[render distill] $rel"
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    Rscript -e "setwd('.'); rmarkdown::render('$rel', quiet = FALSE)" 2>&1 | ForEach-Object { "$_" }
    $exit = $LASTEXITCODE
    $ErrorActionPreference = $prevEap
    if ($exit -ne 0) {
        throw "rmarkdown::render failed for $rel (exit $exit)"
    }

    $postDirRel = (Split-Path $rel -Parent) -replace '\\', '/'
    & (Join-Path $PSScriptRoot "sync-qmd-post-to-docs.ps1") -PostDir $postDirRel
}

Write-Host "Done."
