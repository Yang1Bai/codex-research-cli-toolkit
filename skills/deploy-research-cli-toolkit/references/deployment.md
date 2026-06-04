# Deployment Reference

## Main Tool Areas

- Literature: paper-search MCP, Zotero MCP, Zotero, Better BibTeX helper, manubot, doi2bib
- Writing: officecli, pandoc, quarto, typst, tectonic, Vale, LanguageTool, codespell, cspell
- PDF/OCR: poppler, qpdf, tesseract, OCRmyPDF, ImageMagick, Ghostscript
- Data: uv/Python, R/radian, Julia, DuckDB, SQLite, jq, yq, qsv, Miller
- Materials/chemistry: pymatgen, ASE, custodian, phonopy, sumo, pyprocar, Open Babel
- Reproducibility: git, gh, git-lfs, dvc, rclone, ruff, black, pre-commit, pyright
- Notebooks/experiments: jupytext, nbqa, papermill, marimo, MLflow, W&B, Kaggle, Hugging Face CLI
- Diagrams: Graphviz, PlantUML, Mermaid CLI

## Expected MCP Servers

- paper-search
- tooluniverse
- zotero, if Zotero is installed
- context7
- playwright
- exa, only when `EXA_API_KEY` is set and `-IncludeExa` is used

## Common Follow-Ups

- Ask the user to restart Codex after MCP setup.
- Ask the user to log in to `gh`, `hf`, `wandb`, or Kaggle only when a later task requires that service.
- For Zotero, ask the user to open Zotero at least once and install Better BibTeX manually from the `.xpi`.
- Use dry-run mode before changing another user's machine if they only asked what would happen.
