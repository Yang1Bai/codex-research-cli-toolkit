param(
  [switch]$SkipMcp
)

$ErrorActionPreference = "Continue"

$extraPath = @(
  "$env:USERPROFILE\scoop\apps\openjdk\current\bin",
  "$env:USERPROFILE\scoop\persist\nodejs-lts\bin",
  "$env:USERPROFILE\.pixi\bin",
  "$env:USERPROFILE\scoop\apps\imagemagick\current",
  "$env:USERPROFILE\scoop\shims",
  "$env:USERPROFILE\.local\bin",
  "$env:USERPROFILE\scoop\apps\nodejs-lts\current",
  "$env:USERPROFILE\scoop\apps\nodejs-lts\current\bin"
)
$env:Path = ($extraPath -join ";") + ";$env:Path"
if (-not $env:R_HOME -and (Test-Path "$env:USERPROFILE\scoop\apps\r\current")) {
  $env:R_HOME = "$env:USERPROFILE\scoop\apps\r\current"
}

$checks = @(
  @{ Name = "uvx"; Command = "uvx"; Args = @("--version") },
  @{ Name = "node"; Command = "node"; Args = @("--version") },
  @{ Name = "npx"; Command = "$env:USERPROFILE\scoop\apps\nodejs-lts\current\npx.cmd"; Args = @("--version") },
  @{ Name = "git"; Command = "git"; Args = @("--version") },
  @{ Name = "gh"; Command = "gh"; Args = @("--version") },
  @{ Name = "rg"; Command = "rg"; Args = @("--version") },
  @{ Name = "pandoc"; Command = "pandoc"; Args = @("--version") },
  @{ Name = "quarto"; Command = "quarto"; Args = @("--version") },
  @{ Name = "typst"; Command = "typst"; Args = @("--version") },
  @{ Name = "tectonic"; Command = "tectonic"; Args = @("--version") },
  @{ Name = "pdfinfo"; Command = "pdfinfo"; Args = @("-v") },
  @{ Name = "qpdf"; Command = "qpdf"; Args = @("--version") },
  @{ Name = "tesseract"; Command = "tesseract"; Args = @("--version") },
  @{ Name = "ocrmypdf"; Command = "ocrmypdf"; Args = @("--version") },
  @{ Name = "duckdb"; Command = "duckdb"; Args = @("--version") },
  @{ Name = "jq"; Command = "jq"; Args = @("--version") },
  @{ Name = "yq"; Command = "yq"; Args = @("--version") },
  @{ Name = "qsv"; Command = "qsv"; Args = @("--version") },
  @{ Name = "mlr"; Command = "mlr"; Args = @("--version") },
  @{ Name = "pmg"; Command = "pmg"; Args = @("--help") },
  @{ Name = "ase"; Command = "ase"; Args = @("--version") },
  @{ Name = "cstdn"; Command = "cstdn"; Args = @("--help") },
  @{ Name = "phonopy"; Command = "phonopy"; Args = @("-v") },
  @{ Name = "sumo-bandplot"; Command = "sumo-bandplot"; Args = @("--help") },
  @{ Name = "obabel"; Command = "obabel"; Args = @("-V") },
  @{ Name = "Rscript"; Command = "Rscript"; Args = @("--version") },
  @{ Name = "radian"; Command = "radian"; Args = @("--version") },
  @{ Name = "julia"; Command = "julia"; Args = @("--version") },
  @{ Name = "ruff"; Command = "ruff"; Args = @("--version") },
  @{ Name = "black"; Command = "black"; Args = @("--version") },
  @{ Name = "pre-commit"; Command = "pre-commit"; Args = @("--version") },
  @{ Name = "pyright"; Command = "$env:USERPROFILE\scoop\persist\nodejs-lts\bin\pyright.cmd"; Args = @("--version") },
  @{ Name = "jupytext"; Command = "jupytext"; Args = @("--version") },
  @{ Name = "papermill"; Command = "papermill"; Args = @("--version") },
  @{ Name = "marimo"; Command = "marimo"; Args = @("--version") },
  @{ Name = "mlflow"; Command = "mlflow"; Args = @("--version") },
  @{ Name = "wandb"; Command = "wandb"; Args = @("--version") },
  @{ Name = "kaggle"; Command = "kaggle"; Args = @("--version") },
  @{ Name = "vale"; Command = "vale"; Args = @("--version") },
  @{ Name = "codespell"; Command = "codespell"; Args = @("--version") },
  @{ Name = "cspell"; Command = "$env:USERPROFILE\scoop\persist\nodejs-lts\bin\cspell.cmd"; Args = @("--version") },
  @{ Name = "dot"; Command = "dot"; Args = @("-V") },
  @{ Name = "plantuml"; Command = "plantuml"; Args = @("-version") },
  @{ Name = "mmdc"; Command = "$env:USERPROFILE\scoop\persist\nodejs-lts\bin\mmdc.cmd"; Args = @("--version") },
  @{ Name = "languagetool"; Command = "languagetool-commandline"; Args = @("--version") }
)

$results = foreach ($check in $checks) {
  $out = ""
  $ok = $false
  $exists = $false
  try {
    if ($check.Command -match "[\\/]" -or $check.Command -like "*.cmd" -or $check.Command -like "*.exe") {
      $exists = Test-Path $check.Command
    } else {
      $exists = $null -ne (Get-Command $check.Command -ErrorAction SilentlyContinue)
    }
    if (-not $exists) {
      throw "Command not found: $($check.Command)"
    }
    $global:LASTEXITCODE = 0
    $out = & $check.Command @($check.Args) 2>&1 | Select-Object -First 2 | Out-String
    $ok = $out.Trim().Length -gt 0
  } catch {
    $out = $_.Exception.Message
    $ok = $false
  }
  [pscustomobject]@{
    Tool = $check.Name
    OK = $ok
    Output = (($out -replace "\s+", " ").Trim())
  }
}

$results | Format-Table -AutoSize

if (-not $SkipMcp) {
  $codex = Get-Command codex -ErrorAction SilentlyContinue
  if ($codex) {
    Write-Host ""
    Write-Host "Codex MCP list:" -ForegroundColor Cyan
    try {
      & $codex.Source mcp list
    } catch {
      Write-Host "Codex MCP list failed through PATH. Run scripts/setup-mcp.ps1 from Codex Desktop if needed."
    }
  }
}

if ($results | Where-Object { -not $_.OK }) {
  exit 1
}
