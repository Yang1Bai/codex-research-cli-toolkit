param(
  [switch]$IncludeExa,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) {
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Test-CommandWorks($Command, [string[]]$Args) {
  try {
    $p = Start-Process -FilePath $Command -ArgumentList $Args -NoNewWindow -PassThru -Wait -RedirectStandardOutput "$env:TEMP\codex-mcp-test.out" -RedirectStandardError "$env:TEMP\codex-mcp-test.err"
    return $p.ExitCode -eq 0
  } catch {
    return $false
  }
}

function Resolve-CodexCli {
  $cmd = Get-Command codex -ErrorAction SilentlyContinue
  if ($cmd -and (Test-CommandWorks $cmd.Source @("mcp", "--help"))) {
    return $cmd.Source
  }

  $config = Join-Path $env:USERPROFILE ".codex\config.toml"
  if (Test-Path $config) {
    $match = Select-String -Path $config -Pattern "CODEX_CLI_PATH\s*=\s*'([^']+)'" | Select-Object -First 1
    if ($match -and $match.Matches[0].Groups[1].Value) {
      $candidate = $match.Matches[0].Groups[1].Value
      if (Test-Path $candidate) { return $candidate }
    }
  }

  $candidates = Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA "OpenAI\Codex\bin") -Recurse -Filter codex.exe -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -ExpandProperty FullName
  foreach ($candidate in $candidates) {
    if (Test-CommandWorks $candidate @("mcp", "--help")) {
      return $candidate
    }
  }

  throw "Could not find a working Codex CLI. Install Codex CLI or open this from Codex Desktop."
}

function Add-Mcp($Name, $Command, [string[]]$ToolArgs, [hashtable]$Env = @{}) {
  $codex = Resolve-CodexCli
  $cmdArgs = @("mcp", "add", $Name)
  foreach ($key in $Env.Keys) {
    $cmdArgs += @("--env", "$key=$($Env[$key])")
  }
  $cmdArgs += "--"
  $cmdArgs += $Command
  $cmdArgs += $ToolArgs

  if ($DryRun) {
    Write-Host "[dry-run] $codex $($cmdArgs -join ' ')"
    return
  }

  try {
    & $codex mcp remove $Name 2>$null | Out-Null
  } catch {
    # Removing a missing server is harmless.
  }
  & $codex @cmdArgs
}

function Require-Path($Path, $Description) {
  if (-not (Test-Path $Path)) {
    throw "$Description not found at $Path"
  }
  return $Path
}

Write-Step "Resolving tool paths"
$uvx = Require-Path (Join-Path $env:USERPROFILE ".local\bin\uvx.exe") "uvx"
$node = Require-Path (Join-Path $env:USERPROFILE "scoop\apps\nodejs-lts\current\node.exe") "Node.js"

$context7 = Join-Path $env:USERPROFILE "scoop\persist\nodejs-lts\bin\node_modules\@upstash\context7-mcp\dist\index.js"
$playwright = Join-Path $env:USERPROFILE "scoop\persist\nodejs-lts\bin\node_modules\@playwright\mcp\cli.js"

if (-not (Test-Path $context7)) {
  $npm = Require-Path (Join-Path $env:USERPROFILE "scoop\apps\nodejs-lts\current\npm.cmd") "npm"
  if ($DryRun) {
    Write-Host "[dry-run] $npm install -g @upstash/context7-mcp"
  } else {
    & $npm install -g "@upstash/context7-mcp"
  }
}

if (-not (Test-Path $playwright)) {
  $npm = Require-Path (Join-Path $env:USERPROFILE "scoop\apps\nodejs-lts\current\npm.cmd") "npm"
  if ($DryRun) {
    Write-Host "[dry-run] $npm install -g @playwright/mcp"
  } else {
    & $npm install -g "@playwright/mcp"
  }
}

Write-Step "Adding MCP servers"
Add-Mcp "paper-search" $uvx @("paper-search-mcp")
Add-Mcp "tooluniverse" $uvx @("--refresh", "tooluniverse") @{ "PYTHONIOENCODING" = "utf-8" }

$zoteroPaths = @(
  (Join-Path $env:USERPROFILE "scoop\shims\zotero.exe"),
  "C:\Program Files\Zotero\zotero.exe",
  (Join-Path $env:LOCALAPPDATA "Zotero\zotero.exe")
)
if ($zoteroPaths | Where-Object { Test-Path $_ }) {
  Add-Mcp "zotero" $uvx @("--upgrade", "zotero-mcp") @{ "ZOTERO_LOCAL" = "true" }
} else {
  Write-Host "Skipping zotero MCP: local Zotero was not found."
}

Add-Mcp "context7" $node @($context7)
Add-Mcp "playwright" $node @($playwright)

if ($IncludeExa -and $env:EXA_API_KEY) {
  $npx = Require-Path (Join-Path $env:USERPROFILE "scoop\apps\nodejs-lts\current\npx.cmd") "npx"
  Add-Mcp "exa" $npx @("-y", "exa-mcp-server") @{ "EXA_API_KEY" = $env:EXA_API_KEY }
} elseif ($IncludeExa) {
  Write-Host "Skipping exa MCP: EXA_API_KEY is not set."
}

Write-Step "Current MCP servers"
if ($DryRun) {
  Write-Host "[dry-run] codex mcp list"
} else {
  & (Resolve-CodexCli) mcp list
}
