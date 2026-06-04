# Tooling Matrix

| Area | Tools |
| --- | --- |
| Package managers | Scoop, uv, pixi, npm |
| Codex MCP | paper-search, ToolUniverse, Zotero, Context7, Playwright, optional Exa |
| Literature | Zotero, Better BibTeX, manubot, doi2bib |
| Office documents | officecli |
| Writing | pandoc, quarto, typst, tectonic, Vale, LanguageTool, codespell, cspell |
| PDF/OCR | poppler, qpdf, tesseract, OCRmyPDF, ImageMagick, Ghostscript |
| Data | DuckDB, SQLite, jq, yq, qsv, Miller |
| Sync/versioning | Git, Git LFS, GitHub CLI, DVC, rclone |
| Python quality | ruff, black, pre-commit, pyright |
| Notebooks | jupytext, nbqa, papermill, marimo |
| Experiments | MLflow, W&B, Kaggle, Hugging Face CLI |
| Materials/DFT | pymatgen, ASE, custodian, phonopy, sumo, pyprocar |
| Chemistry | Open Babel |
| Diagrams | Graphviz, PlantUML, Mermaid CLI |
| Statistics | R, radian |
| Scientific computing | Julia |

## Large Tools Not Installed By Default

| Tool | Reason |
| --- | --- |
| Docker Desktop / Podman | Large and system-level |
| GROBID | Best deployed through Docker |
| Rtools | Needed mainly for compiling R packages from source |
| Full TeX Live / TinyTeX | Larger than tectonic; install only when a journal template needs it |
| NCBI EDirect | Native Windows dependency resolution is fragile |
