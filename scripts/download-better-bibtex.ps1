param(
  [string]$OutputDirectory = (Join-Path (Get-Location) "downloads")
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$release = Invoke-RestMethod -Uri "https://api.github.com/repos/retorquere/zotero-better-bibtex/releases/latest"
$asset = $release.assets | Where-Object { $_.name -like "*.xpi" } | Select-Object -First 1

if (-not $asset) {
  throw "Could not find a Better BibTeX .xpi asset in the latest release."
}

$out = Join-Path $OutputDirectory $asset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $out
Get-Item $out | Select-Object FullName, Length
