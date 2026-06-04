# Codex Research CLI Toolkit

A Windows-first toolkit for turning Codex into a practical academic research assistant.

It installs and configures command-line tools for literature search, Zotero workflows, PDF/OCR processing, reproducible writing, scientific data analysis, materials/DFT work, and Codex MCP servers.

The project is intentionally scriptable and idempotent: run the installer again to fill in missing tools.

## What This Sets Up

Core research workflow:

- Literature and citation support: Zotero, Better BibTeX download helper, manubot, doi2bib
- Codex MCP servers: paper-search, ToolUniverse, Zotero, Context7, Playwright, optional Exa
- Writing and publishing: officecli, pandoc, quarto, typst, tectonic
- PDF/OCR: poppler, qpdf, tesseract, OCRmyPDF, ImageMagick, Ghostscript
- Data analysis: Python/uv, R/radian, Julia, DuckDB, SQLite, jq, yq, qsv, Miller
- Materials and chemistry: pymatgen/pmg, ASE, custodian, phonopy, sumo, pyprocar, Open Babel
- Reproducibility and code quality: Git, Git LFS, GitHub CLI, DVC, rclone, ruff, black, pre-commit, pyright, jupytext, papermill, marimo, MLflow, W&B, Kaggle
- Writing QA and diagrams: Vale, LanguageTool, codespell, cspell, Graphviz, PlantUML, Mermaid CLI

## Quick Start

Open PowerShell and run:

```powershell
git clone https://github.com/Yang1Bai/codex-research-cli-toolkit.git
cd codex-research-cli-toolkit
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -All
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
```

Restart Codex after MCP setup so the new servers are discovered.

## Deploy Directly From Codex

If you are using Codex Desktop or Codex CLI on Windows, you can ask Codex to run the deployment for you.

Paste this into a Codex chat:

```text
Clone and deploy this toolkit:

https://github.com/Yang1Bai/codex-research-cli-toolkit

Please run:
1. git clone https://github.com/Yang1Bai/codex-research-cli-toolkit.git
2. cd codex-research-cli-toolkit
3. powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -All
4. powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1
5. powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1

If a command fails, continue with the next step and summarize what worked.
```

If you already cloned the repository in a Codex workspace, ask Codex:

```text
Deploy this repository on my machine. Run the Windows installer, configure Codex MCP servers, then run the verifier and summarize the result.
```

For a safer preview first:

```text
Run a dry-run deployment for this repository. Use install-windows.ps1 -All -DryRun and setup-mcp.ps1 -DryRun, then tell me what would be installed.
```

After deployment, restart Codex or open a new Codex session. MCP servers are read at session startup, so newly added servers may not appear in the current session immediately.

## Use As A Codex Skill

This repository also includes a ready-to-install Codex skill:

```text
skills/deploy-research-cli-toolkit/
```

To install it locally, copy that folder into your Codex skills directory:

```powershell
Copy-Item -Recurse .\skills\deploy-research-cli-toolkit "$env:USERPROFILE\.codex\skills\deploy-research-cli-toolkit"
```

Restart Codex, then prompt:

```text
Deploy the Codex research CLI toolkit on this Windows machine, configure MCP servers, and verify the setup.
```

The skill will prefer the repository scripts over ad hoc commands and will run dry-runs, MCP setup, and verification in the intended order.

## Safer Dry Run

Preview what would be installed:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -All -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1 -DryRun
```

## Install Profiles

Default installs a compact research stack:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1
```

Install everything currently captured by this project:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -All
```

Use targeted profiles:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -Core -Writing -Pdf -Data
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -Materials
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -RJulia
```

## MCP Setup

Configure Codex MCP servers:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1
```

The script adds:

- `paper-search`: arXiv, PubMed, Semantic Scholar, OpenAlex, Crossref, and related paper search
- `tooluniverse`: scientific API and dataset tool universe
- `zotero`: local Zotero integration, when Zotero is installed
- `context7`: current library documentation
- `playwright`: structured browser automation
- `exa`: optional semantic web search when `EXA_API_KEY` is available

Enable Exa:

```powershell
$env:EXA_API_KEY = "your_exa_api_key"
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1 -IncludeExa
```

## Zotero Better BibTeX

Zotero extensions still need manual installation from the Zotero UI.

Download the current Better BibTeX XPI:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\download-better-bibtex.ps1
```

Then open Zotero and install the `.xpi` file through `Tools -> Plugins`.

## Verification

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
```

The verifier checks tool availability and prints a status table. It does not require accounts for GitHub, Kaggle, W&B, Hugging Face, Zotero, or Exa.

## Notes

- This repository is Windows-first because Codex Desktop on Windows commonly runs inside PowerShell.
- Some tools require login tokens after installation: GitHub CLI, Hugging Face, Kaggle, W&B, Zotero sync, and Exa.
- Docker, GROBID, full TeX Live, and Rtools are intentionally not installed by default because they are large or require system-level setup.
- Mermaid CLI is installed without downloading its bundled browser. For rendering, use an existing browser/Playwright setup or provide a Puppeteer config.

## License

MIT
