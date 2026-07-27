# ntilau.github.io

Personal site deployed to [GitHub Pages](https://ntilau.github.io). Three independent pieces: a **TV streamer** with 250+ Italian and French live channels, a **LaTeX CV** with cover letter, and **LinkedIn alignment tooling**.

---

## TV Streamer ([`index.html`](index.html))

Single-file HLS-based live TV player with 250+ Italian and French channels, powered by [HLS.js](https://github.com/video-dev/hls.js) with native HLS fallback for Safari.

**Features:**
- **Channel navigation** — Arrow keys, PageUp/PageDown, touch swipe (≥100 px), trackpad horizontal scroll (≥200 px cumulative)
- **Click anywhere** — un-mutes audio and requests fullscreen
- **OSD overlay** — channel name + index indicator (e.g. `3/285`); auto-hides after 1.8 s on playback start
- **Auto-drop** — [`dropChannel()`](index.html#L307) removes failing streams from the array on fatal HLS errors, advancing to the next working channel
- **Wrap-around navigation** — past the last channel loops to the first
- **Empty-state handling** — when all streams fail, title shows *"No streams"* and OSD shows *"All streams failed"*

**Controls:**

| Input | Action |
|---|---|
| `←` / `↑` / `PageUp` | Previous channel |
| `→` / `↓` / `PageDown` | Next channel |
| Touch swipe left/right | Next / previous channel |
| Trackpad horizontal scroll | Channel navigation |
| Click anywhere | Un-mute + fullscreen |

---

## CV ([`cv.tex`](cv.tex), [`cl.tex`](cl.tex), [`my.tex`](my.tex))

A full LaTeX CV built on a custom [`altacv.cls`](altacv.cls) fork. Fonts: Roboto Slab (headings) + Lato (body).

**Files:**

| File | Purpose |
|---|---|
| [`my.tex`](my.tex) | Shared preamble — geometry, fonts, colors, personal info, biblatex config |
| [`cv.tex`](cv.tex) | Two-column CV (paracol): Summary, Experience, Projects, Education, Awards, Certifications, Courses, Skills, Languages, Publications ([`my.bib`](my.bib)), Recommendations |
| [`cl.tex`](cl.tex) | Beamer cover letter — inputs `app.tex` for your personalized letter text (create one!) |
| [`my.bib`](my.bib) | Bibliography: articles, inproceedings, books, patents |
| [`altacv.cls`](altacv.cls) | Custom document class (forked from `altacv`) |
| [`cv.html`](cv.html) | Meta-refresh redirect page → [`cv.pdf`](cv.pdf) |

**Building (requires TeX Live with `pdflatex`/`xelatex` + `biber`):**

```bash
./setup                          # install TeX deps (homebrew/apt/pacman/dnf)
make cv                          # build cv.pdf (pdflatex + biber, 3 passes)
make cl                          # build cl.pdf (cover letter)
make all                         # build both
make clean                       # remove aux files
```

> **Note:** To customize the cover letter, create an `app.tex` file with your personalized text. It is auto-included by `cl.tex`.

---

## LinkedIn Alignment ([`align_linkedin.py`](align_linkedin.py))

Python tool that parses the LaTeX CV and compares it against LinkedIn profile data to find discrepancies.

**Modes:**

| Command | What it does |
|---|---|
| `python align_linkedin.py` | Print parsed CV summary |
| `python align_linkedin.py --json` | Dump CV as JSON |
| `python align_linkedin.py --scrape` | Scrape LinkedIn (uses handle from `my.tex`), compare automatically |
| `python align_linkedin.py --scrape --debug` | Scrape + save page screenshot and HTML |
| `python align_linkedin.py --linkedin-dir <path>` | Compare against a LinkedIn CSV data export (`Download Your Data`) |

**How it works:**
- `build_profile()` — parses `my.tex` + `cv.tex` into a structured `CVProfile` dataclass
- `read_linkedin_export()` — reads LinkedIn data export CSV files
- `LinkedInScraper` — Playwright-based scraper using a persistent browser profile (`~/.linkedin_align_profile`). First run opens a visible Chrome window for manual login; subsequent runs reuse the session
- `compare()` — fuzzy-matches positions (company + title), skills, languages, and education, then reports discrepancies

---

## CI/CD ([`.github/workflows/`](.github/workflows/))

Two GitHub Actions workflows:

| Workflow | Trigger | What it does |
|---|---|---|
| [`build-cv.yml`](.github/workflows/build-cv.yml) | Push/PR on `*.tex`, `*.cls`, `*.bib`, `Makefile`, `setup` | Installs TeX Live, builds `cv.pdf` + `cl.pdf`, verifies output, uploads as build artifacts |
| [`deploy-pages.yml`](.github/workflows/deploy-pages.yml) | Push to `main` (+ manual dispatch) | Installs TeX Live, builds both PDFs, deploys full site to GitHub Pages |

---

## Deployment

The site is published via GitHub Pages from the `main` branch. Any push to `main` triggers automatic build and deploy through the [`deploy-pages.yml`](.github/workflows/deploy-pages.yml) workflow.
