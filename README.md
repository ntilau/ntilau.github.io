# ntilau.github.io

Personal site with an Italian/French TV streamer, LaTeX CV, and LinkedIn alignment tooling.

## Contents

### TV Streamer

- **`index.html`** — HLS-based live TV player with 250+ Italian and French channels. Swipe (touch or trackpad) or PageUp/PageDown to change channels. Failing streams auto-drop.
- **`github.svg`** — Favicon (GitHub Octicons mark).

### CV

- **`cv.tex`** — Main CV source (Lorenzo Ntibarikure).
- **`my.tex`** — Shared preamble (fonts, colors, personal info, bibliography config).
- **`my.bib`** — Publications and patents bibliography.
- **`altacv.cls`** — Custom LaTeX class (`altacv`).
- **`cl.tex`** — Cover letter / slides source.
- **`Makefile`** — Build targets for LaTeX compilation.

### LinkedIn Alignment

- **`align_linkedin.py`** — Parses the LaTeX CV and compares it against LinkedIn profile data. Supports CSV export comparison and Playwright-based profile scraping.

```
python align_linkedin.py                       # print CV summary
python align_linkedin.py --json                # dump CV as JSON
python align_linkedin.py --linkedin-dir <dir>  # compare against LinkedIn data export
python align_linkedin.py --scrape              # scrape and compare (uses handle from my.tex)
```

## Building the CV

### Prerequisites

- `make`
- `pdflatex` or `xelatex`
- `biber` (for bibliography)

### Setup

```bash
./setup
```

### Build

```bash
make cv     # build cv.pdf
make cl     # build cl.pdf
make all    # build both
make clean  # remove auxiliary files
```
