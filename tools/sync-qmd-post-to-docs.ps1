# Copy a rendered QMD post (slug.html + assets) into docs/posts/ for GitHub Pages.
# Only run for posts you intend to publish (draft: false or removed draft: true).
#
# Usage:
#   powershell -File tools/sync-qmd-post-to-docs.ps1 -PostDir "_posts/2026-06-08-ggplot-hourglass-four-skill-fusion"

param(
    [Parameter(Mandatory = $true)]
    [string]$PostDir
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$folder = Split-Path $PostDir -Leaf
if ($folder -notmatch '^(\d{4}-\d{2}-\d{2})-(.+)$') {
    Write-Error "PostDir must match YYYY-MM-DD-slug (got: $folder)"
}
$slug = $Matches[2]

$qmd = Get-ChildItem $PostDir -Filter "*.qmd" -File | Where-Object { $_.Name -notmatch '^_' } | Select-Object -First 1
if (-not $qmd) { Write-Error "No .qmd in $PostDir" }

$htmlName = [System.IO.Path]::GetFileNameWithoutExtension($qmd.Name) + ".html"
$htmlPath = Join-Path $PostDir $htmlName
if (-not (Test-Path $htmlPath)) {
    Write-Error "Missing $htmlPath — run tools/render-qmd-posts.ps1 first"
}

$destDir = Join-Path (Join-Path "docs" "posts") $folder
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
Copy-Item $htmlPath (Join-Path $destDir "index.html") -Force

$assetsSrc = Join-Path $PostDir "assets"
if (Test-Path $assetsSrc) {
    $assetsDest = Join-Path $destDir "assets"
    New-Item -ItemType Directory -Force -Path $assetsDest | Out-Null
    Copy-Item (Join-Path $assetsSrc "*") $assetsDest -Recurse -Force
}

$badgeSrc = Join-Path $PostDir "title-badge.png"
if (Test-Path $badgeSrc) {
    Copy-Item $badgeSrc (Join-Path $destDir "title-badge.png") -Force
}

$takeawaySrc = Join-Path $PostDir "takeaway"
if (Test-Path $takeawaySrc) {
    $takeawayDest = Join-Path $destDir "takeaway"
    New-Item -ItemType Directory -Force -Path $takeawayDest | Out-Null
    Copy-Item (Join-Path $takeawaySrc "*") $takeawayDest -Recurse -Force
}

Copy-Item $qmd.FullName (Join-Path $destDir $qmd.Name) -Force

function Repair-QmdDistillHtml {
    param(
        [string]$HtmlPath,
        [string]$PostFolder,
        [string]$SiteRoot
    )

    $baseUrl = "https://liketocood345.github.io/for_hdat9800_blog"
    $canonical = "$baseUrl/posts/$PostFolder/"
    $html = Get-Content $HtmlPath -Raw -Encoding UTF8

    # Per-post *_files/ libs are not copied to docs; use shared site_libs like Rmd posts.
    $html = $html -replace '[\w-]+_files/', '../../site_libs/'

    $faviconPath = Join-Path $SiteRoot "favicon.html"
    if (Test-Path $faviconPath) {
        $siteHeader = (Get-Content $faviconPath -Raw -Encoding UTF8).Trim()
        $html = $html -replace '(?s)<!--radix_placeholder_site_in_header-->\s*<!--/radix_placeholder_site_in_header-->', "<!--radix_placeholder_site_in_header-->`n$siteHeader`n<!--/radix_placeholder_site_in_header-->"
    }

    $navBlock = @"
<!--radix_placeholder_navigation_before_body-->
<header class="header header--fixed" role="banner">
<nav class="distill-site-nav distill-site-header">
<div class="nav-left">
<a href="../../index.html" class="title">HDAT9800 Blog</a>
<input id="distill-search" class="nav-search hidden" type="text" placeholder="Search..."/>
</div>
<div class="nav-right">
<a href="../../index.html">Overview</a>
<a href="../../about.html">About Me</a>
<a href="javascript:void(0);" class="nav-toggle">&#9776;</a>
</div>
</nav>
</header>
<!--/radix_placeholder_navigation_before_body-->
"@
    $html = $html -replace '(?s)<!--radix_placeholder_navigation_before_body-->\s*<!--/radix_placeholder_navigation_before_body-->', $navBlock

    if ($html -notmatch 'rel="canonical"') {
        $html = $html -replace '(<!--radix_placeholder_meta_tags-->)', "`$1`n<link rel=`"canonical`" href=`"$canonical`"/>`n<meta property=`"og:url`" content=`"$canonical`"/>`n<meta property=`"twitter:url`" content=`"$canonical`"/>"
    }

    # If Distill JS fails to load, avoid a permanently hidden page.
    if ($html -notmatch 'noscript body') {
        $html = $html -replace '(body \{\s*\n\s*visibility: hidden;\s*\n\s*\})', "`$1`n  noscript body { visibility: visible !important; }"
    }

    [System.IO.File]::WriteAllText($HtmlPath, $html, [System.Text.UTF8Encoding]::new($false))
}

$destHtml = Join-Path $destDir "index.html"
Repair-QmdDistillHtml -HtmlPath $destHtml -PostFolder $folder -SiteRoot $Root

function Get-QmdScalar($lines, $key) {
    $pattern = "^\s*$([regex]::Escape($key)):\s*(.+)\s*$"
    foreach ($line in $lines) {
        if ($line -match $pattern) { return $Matches[1].Trim().Trim('"') }
    }
    return $null
}

function Get-QmdBlockScalar($lines, $key) {
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*$([regex]::Escape($key)):\s*\|\s*$") { $start = $i + 1; break }
    }
    if ($start -lt 0) { return Get-QmdScalar $lines $key }
    $parts = New-Object System.Collections.Generic.List[string]
    for ($j = $start; $j -lt $lines.Count; $j++) {
        if ($lines[$j] -match '^\s+\S' -or $lines[$j] -match '^\s*$') {
            $parts.Add($lines[$j].Trim())
        } else { break }
    }
    return ($parts -join " ").Trim()
}

$yamlLines = Get-Content $qmd.FullName -Encoding UTF8
$title = Get-QmdScalar $yamlLines "title"
$description = Get-QmdBlockScalar $yamlLines "description"
$date = Get-QmdScalar $yamlLines "date"
$authorName = $null
$authorUrl = $null
for ($i = 0; $i -lt $yamlLines.Count; $i++) {
    if ($yamlLines[$i] -match '^\s*-\s*name:\s*(.+)\s*$') { $authorName = $Matches[1].Trim().Trim('"') }
    if ($yamlLines[$i] -match '^\s*url:\s*(.+)\s*$' -and $authorName) { $authorUrl = $Matches[1].Trim().Trim('"'); break }
}
if (-not $title) { $title = $slug }
if (-not $date -and $folder -match '^(\d{4}-\d{2}-\d{2})-') { $date = $Matches[1] }
if (-not $description) { $description = $title }

$postPath = "posts/$folder/"
$postsJsonPath = Join-Path (Join-Path "docs" "posts") "posts.json"
$posts = @()
if (Test-Path $postsJsonPath) {
    $posts = Get-Content $postsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
$posts = @($posts | Where-Object { $_.path -ne $postPath })
$lastModified = (Get-Item (Join-Path $destDir "index.html")).LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ssK")
$entry = [ordered]@{
    path          = $postPath
    title         = $title
    description   = $description
    author        = @(
        [ordered]@{
            name = $(if ($authorName) { $authorName } else { "liketocood345" })
            url  = $(if ($authorUrl) { $authorUrl } else { "https://github.com/liketocood345" })
        }
    )
    date          = $date
    categories    = @()
    contents      = "`r`n$description`r`n`r`n`r`n"
    preview       = @{}
    last_modified = $lastModified
    input_file    = @{}
}
$posts = ,$entry + $posts
$posts = $posts | Sort-Object { [datetime]$_.date } -Descending
$posts | ConvertTo-Json -Depth 6 | Set-Content $postsJsonPath -Encoding UTF8

Write-Host "Synced QMD post to $destDir/index.html"
