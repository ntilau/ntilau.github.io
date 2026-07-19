# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal site deployed to GitHub Pages (`ntilau.github.io`). Three independent pieces:
- **TV streamer** — HLS-based live player with 230+ Italian and French channels
- **LaTeX CV** — Two-column CV and beamer-based cover letter, built with `make`
- **LinkedIn alignment** — Python tool to scrape/compare LinkedIn profile against the CV

## Commands

```bash
# CV
./setup          # install LaTeX deps (homebrew/apt/pacman/dnf)
make cv          # build cv.pdf (pdflatex + biber, 3 passes)
make cl          # build cl.pdf (beamer cover letter)
make all         # build both
make clean       # remove aux files

# LinkedIn alignment
python align_linkedin.py                        # print CV summary
python align_linkedin.py --json                 # dump parsed CV as JSON
python align_linkedin.py --scrape               # scrape LinkedIn and compare (uses handle from my.tex)
python align_linkedin.py --scrape --debug       # scrape + save page screenshot/HTML
python align_linkedin.py --linkedin-dir <path>  # compare against CSV export from LinkedIn
```

## Architecture

### TV streamer (`index.html`)
Single-file HLS player. Channel list is a JS array of `{name, url}` objects. HLS.js handles playback; native HLS fallback for Safari. Failing streams are auto-removed from the array via `dropChannel()`. Channel switching via Arrow keys, PageUp/PageDown, touch swipe, or trackpad horizontal scroll. Click to unmute + fullscreen. OSD overlay shows channel name and index.

### CV (`cv.tex`, `my.tex`, `altacv.cls`, `my.bib`)
- `my.tex` — shared preamble: geometry, fonts (Roboto Slab / Lato), colors, personal info, biblatex config. Input by both `cv.tex` and `cl.tex`.
- `cv.tex` — two-column CV using `paracol`. Sections: Summary, Experience, Projects, Education, Awards, Certifications, Courses, Skills, Languages, Publications (from `my.bib`), Recommendations.
- `altacv.cls` — custom document class (forked altacv).
- `my.bib` — BibTeX bibliography with articles, inproceedings, books, and patents.
- `cv.html` — meta-refresh redirect to `cv.pdf`.
- `.gitignore` allows only `cv.pdf`, `cl.pdf`, `cv.tex`, `cl.tex`, `my.tex` — all other `.tex`/`.pdf` files are ignored.

### LinkedIn alignment (`align_linkedin.py`)
- `build_profile(base_dir)` — parses `my.tex` + `cv.tex` into a `CVProfile` dataclass
- `read_linkedin_export(dir)` — reads LinkedIn "Download Your Data" CSV files
- `LinkedInScraper` — Playwright-based scraper with persistent browser profile in `~/.linkedin_align_profile`. First run opens a visible Chrome window for manual login; subsequent runs reuse the session.
- `compare(cv, li_data)` — fuzzy-matches positions (by company + title), skills, languages, education and reports discrepancies
- `print_summary()` / `print_comparison()` — report output
