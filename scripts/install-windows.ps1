param(
  [switch]$All,
  [switch]$Core,
  [switch]$Writing,
  [switch]$Pdf,
  [switch]$Data,
  [switch]$Materials,
  [switch]$RJulia,
  [switch]$Quality,
  [switch]$Diagrams,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not ($All -or $Core -or $Writing -or $Pdf -or $Data -or $Materials -or $RJulia -or $Quality -or $Diagrams)) {
  $Core = $true
  $Writing = $true
  $Pdf = $true
  $Data = $true
  $Quality = $true
}

function Write-Step($Message) {
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Invoke-Logged($Command, [string[]]$Arguments) {
  $line = "$Command $($Arguments -join ' ')"
  if ($DryRun) {
    Write-Host "[dry-run] $line"
    return
  }
  Write-Host $line
  & $Command @Arguments
}

function Ensure-UserPath($PathToAdd) {
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $parts = @()
  if ($userPath) {
    $parts = $userPath -split ";" | Where-Object { $_ -ne "" }
  }
  if ($parts -notcontains $PathToAdd) {
    if ($DryRun) {
      Write-Host "[dry-run] Add to user PATH: $PathToAdd"
    } else {
      $parts += $PathToAdd
      [Environment]::SetEnvironmentVariable("Path", ($parts -join ";"), "User")
      $env:Path = "$PathToAdd;$env:Path"
    }
  }
}

function Ensure-Scoop {
  $scoopCmd = Join-Path $env:USERPROFILE "scoop\shims\scoop.cmd"
  if (Test-Path $scoopCmd) {
    return $scoopCmd
  }
  Write-Step "Installing Scoop"
  if ($DryRun) {
    Write-Host "[dry-run] Install Scoop from https://get.scoop.sh"
    return $scoopCmd
  }
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression
  return $scoopCmd
}

function Ensure-Uv {
  $uv = Join-Path $env:USERPROFILE ".local\bin\uv.exe"
  if (Test-Path $uv) {
    return $uv
  }
  Write-Step "Installing uv"
  if ($DryRun) {
    Write-Host "[dry-run] Install uv from https://astral.sh/uv/install.ps1"
    return $uv
  }
  powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
  return $uv
}

function Scoop-Install($Packages) {
  if (-not $Packages -or $Packages.Count -eq 0) { return }
  $scoop = Ensure-Scoop
  Invoke-Logged $scoop (@("install") + $Packages)
}

function Uv-Tool-Install($Packages) {
  if (-not $Packages -or $Packages.Count -eq 0) { return }
  $uv = Ensure-Uv
  foreach ($pkg in $Packages) {
    Invoke-Logged $uv @("tool", "install", $pkg)
  }
}

function Npm-Global-Install($Packages, [switch]$IgnoreScripts) {
  if (-not $Packages -or $Packages.Count -eq 0) { return }
  $npm = Join-Path $env:USERPROFILE "scoop\apps\nodejs-lts\current\npm.cmd"
  if (-not (Test-Path $npm)) {
    Scoop-Install @("nodejs-lts")
  }
  $args = @("install", "-g") + $Packages
  if ($IgnoreScripts) { $args += "--ignore-scripts" }
  Invoke-Logged $npm $args
}

Write-Step "Preparing package managers and PATH"
$scoop = Ensure-Scoop
$uv = Ensure-Uv
Ensure-UserPath (Join-Path $env:USERPROFILE "scoop\shims")
Ensure-UserPath (Join-Path $env:USERPROFILE ".local\bin")
Ensure-UserPath (Join-Path $env:USERPROFILE ".pixi\bin")

if (-not $DryRun) {
  & $scoop bucket add extras 2>$null
  & $scoop bucket add java 2>$null
}

if ($All -or $Core) {
  Write-Step "Installing core tools"
  Scoop-Install @("git", "git-lfs", "gh", "nodejs-lts", "ripgrep", "fd", "fzf", "bat", "delta", "just", "hyperfine", "pixi")
}

if ($All -or $Writing) {
  Write-Step "Installing writing and publishing tools"
  Scoop-Install @("zotero", "pandoc", "quarto", "typst", "tectonic", "vale", "languagetool", "languagetool-java")
  Uv-Tool-Install @("manubot", "doi2bib", "codespell")
  Npm-Global-Install @("cspell")
}

if ($All -or $Pdf) {
  Write-Step "Installing PDF, OCR, and image tools"
  Scoop-Install @("poppler", "qpdf", "tesseract", "imagemagick", "ghostscript")
  Uv-Tool-Install @("ocrmypdf")
}

if ($All -or $Data) {
  Write-Step "Installing data tools"
  Scoop-Install @("duckdb", "jq", "yq", "qsv", "miller", "sqlite", "rclone", "dvc")
  Uv-Tool-Install @("huggingface_hub", "kaggle", "mlflow", "wandb", "marimo", "papermill", "jupytext", "nbqa")
}

if ($All -or $Materials) {
  Write-Step "Installing materials and chemistry tools"
  Uv-Tool-Install @("pymatgen", "ase", "custodian", "phonopy", "sumo", "pyprocar")
  Scoop-Install @("pixi")
  Invoke-Logged (Join-Path $env:USERPROFILE "scoop\shims\pixi.cmd") @("global", "install", "-c", "conda-forge", "openbabel")
}

if ($All -or $RJulia) {
  Write-Step "Installing R, radian, and Julia"
  Scoop-Install @("r", "julia")
  Uv-Tool-Install @("radian")
  if (-not $DryRun) {
    $rHome = & (Join-Path $env:USERPROFILE "scoop\shims\R.exe") RHOME
    [Environment]::SetEnvironmentVariable("R_HOME", $rHome, "User")
  } else {
    Write-Host "[dry-run] Set user R_HOME"
  }
}

if ($All -or $Quality) {
  Write-Step "Installing code quality tools"
  Uv-Tool-Install @("ruff", "black", "pre-commit")
  Npm-Global-Install @("pyright")
}

if ($All -or $Diagrams) {
  Write-Step "Installing diagram tools"
  Scoop-Install @("openjdk", "graphviz", "plantuml")
  Npm-Global-Install @("@mermaid-js/mermaid-cli") -IgnoreScripts
}

Write-Step "Done"
Write-Host "Restart PowerShell and Codex so PATH and MCP changes are picked up."
