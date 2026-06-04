---
name: deploy-research-cli-toolkit
description: Use this skill when the user wants to deploy, verify, repair, or explain the Codex Research CLI Toolkit from github.com/Yang1Bai/codex-research-cli-toolkit. This includes installing academic research CLI tools on Windows, configuring Codex MCP servers for paper search/Zotero/ToolUniverse/Context7/Playwright, running dry-run previews, validating installed tools, or helping another user reproduce the setup from the GitHub repository.
---

# Deploy Research CLI Toolkit

## Overview

Deploy the Windows-first Codex Research CLI Toolkit and verify that its research CLI tools and MCP servers are usable.

Prefer the repository scripts over hand-written installation commands. The public repo is:

```text
https://github.com/Yang1Bai/codex-research-cli-toolkit
```

## Workflow

1. State the action briefly before running commands.
2. Confirm the machine is Windows/PowerShell. If not, explain that this toolkit is Windows-first and offer to adapt manually.
3. Clone or enter the repository.
4. Run a dry-run first if the user wants a preview or if the environment looks sensitive.
5. Run the installer.
6. Configure MCP servers.
7. Run the verifier.
8. Summarize what succeeded, what was skipped, and what requires user secrets or login.

## Commands

Fresh deployment:

```powershell
git clone https://github.com/Yang1Bai/codex-research-cli-toolkit.git
cd codex-research-cli-toolkit
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -All
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
```

Preview only:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -All -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1 -DryRun
```

Existing clone:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -All
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
```

Optional Exa MCP:

```powershell
$env:EXA_API_KEY = "<user-provided-key>"
powershell -ExecutionPolicy Bypass -File .\scripts\setup-mcp.ps1 -IncludeExa
```

Download Zotero Better BibTeX:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\download-better-bibtex.ps1
```

## Deployment Notes

- Restart Codex after `setup-mcp.ps1`; MCP servers are loaded at session startup.
- Never invent or ask to store API keys. Use existing environment variables when present.
- Exa requires `EXA_API_KEY`; skip it if missing.
- Kaggle, W&B, Hugging Face, GitHub, and Zotero sync may require the user to log in separately.
- Better BibTeX still needs manual Zotero plugin installation from the downloaded `.xpi`.
- Docker, GROBID, Rtools, full TeX Live, and NCBI EDirect are intentionally not part of the default install.

## Validation

Treat these as passing checks:

- `install-windows.ps1 -All -DryRun` completes.
- `setup-mcp.ps1 -DryRun` shows expected MCP commands.
- `setup-mcp.ps1` adds enabled MCP entries.
- `verify.ps1` reports installed CLI tools as `OK`.

If a tool fails, continue with the next step when safe and report the exact failed tool and reason.

For a compact reference of tool categories and skipped heavy tools, read `references/deployment.md`.
