# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🔧 Common Commands

### CV/LaTeX Development
```bash
# Build both CV and cover letter
make all

# Build CV only  
make cv

# Build cover letter only
make cl

# Install LaTeX dependencies (run once)
./setup

# Clean auxiliary files (keeps PDFs)
make clean

# Clean everything including PDFs
make distclean
```

### LinkedIn Alignment Tool
```bash
# Print CV summary (default)
python vitae/align_linkedin.py

# Compare against LinkedIn data export
python vitae/align_linkedin.py --linkedin-dir /path/to/linkedin/export

# Scrape LinkedIn profile and compare
python vitae/align_linkedin.py --scrape

# Dump CV data as JSON for inspection
python vitae/align_linkedin.py --json

# Scrape with debug output (saves screenshots/HTML)
python vitae/align_linkedin.py --scrape --debug
```

### Site Development
```bash
# The TV streamer is in index.html - open directly in browser
# No build step required for HTML/JS
```

## 🏗️ Architecture Overview

### Three Independent Systems

1. **TV Streamer** (`index.html`)
   - Single-file HLS-based live player
   - 250+ Italian/French channels
   - Features: channel navigation, OSD overlay, auto-drop failed streams
   - Tech: vanilla JS, HLS.js, native HLS fallback
   - No build process - edit and refresh

2. **LaTeX CV System** (`vitae/` directory)
   - Two-column CV (`cv.tex`) and beamer cover letter (`cl.tex`)
   - Shared preamble (`my.tex`) with fonts, colors, personal info
   - Custom document class (`altacv.cls` - forked)
   - Bibliography (`my.bib`)
   - Build system: `Makefile` with targets for cv, cl, all, clean
   - Output: `cv.pdf`, `cl.pdf`

3. **LinkedIn Alignment Tool** (`vitae/align_linkedin.py`)
   - Parses LaTeX CV into structured data
   - Compares against LinkedIn profile (scraped or CSV export)
   - Reports discrepancies in: headline, summary, positions, projects, skills, languages, education, certifications, courses, publications, awards
   - Uses Playwright for scraping with persistent session

### Data Flow
- CV Source: `my.tex` + `cv.tex` → (parsed by align_linkedin.py) → CVProfile
- LinkedIn Sources: 
  - Live scraping via Playwright → normalized data
  - OR CSV export from LinkedIn "Download Your Data"
- Comparison: Fuzzy matching on company+title, degree+school, etc.
- Output: Human-readable discrepancy report

## 📁 Key File Locations

### Root Level
- `index.html` - TV streamer application
- `README.md` - Project overview
- `.claude/` - Claude Code configuration
  - `CLAUDE.md` - This file
  - `skills/align_linkedin.md` - Skill documentation
  - `scripts/` - (Scripts now live in vitae/)
  - `settings.local.json` - Local settings

### vitae/ Directory
- `align_linkedin.py` - LinkedIn alignment tool
- `index.html` - CV redirect to PDF (meta-refresh)
- `Makefile` - LaTeX build system
- `setup` - Dependency installer
- Source files:
  - `cv.tex` - Main CV (two-column, paracol)
  - `cl.tex` - Cover letter (beamer)
  - `my.tex` - Shared preamble (geometry, fonts, colors, personal info)
  - `my.bib` - Bibliography
  - `altacv.cls` - Custom document class
- Output:
  - `cv.pdf` - Generated CV
  - `cl.pdf` - Generated cover letter

### .github/workflows/
- `build-cv.yml` - CI: builds and verifies PDFs on tex changes
- `deploy-pages.yml` - CD: builds and deploys site to GitHub Pages on main pushes

## 💡 Development Workflow

### For CV Changes
1. Edit `.tex` files in `vitae/` (`cv.tex`, `cl.tex`, `my.tex`)
2. Test locally: `make cv` or `make cl` or `make all`
3. Check output: `vitae/cv.pdf` and/or `vitae/cl.pdf`
4. Clean aux files periodically: `make clean`
5. Push to GitHub to trigger CI/CD

### For LinkedIn Tool Changes
1. Edit `vitae/align_linkedin.py`
2. Test: `python vitae/align_linkedin.py --json` (to inspect CV parsing)
3. For scraping tests: `python vitae/align_linkedin.py --scrape --debug` 
4. Requires Playwright: `pip install playwright && playwright install chromium`

### For TV Streamer Changes
1. Edit `index.html` directly
2. Refresh browser to see changes
3. Features are self-contained in the single file

### Site Deployment
- Push to `main` branch triggers automatic:
  1. TeX Live installation
  2. PDF generation (`make all`)
  3. Site deployment to GitHub Pages
- Manual deployment: Trigger `deploy-pages.yml` workflow

## 🎯 Component-Specific Guidance

### TV Streamer (`index.html`)
- Channel list: JS array of `{name, url}` objects at top of file
- Navigation: Keyboard arrows, PageUp/Down, touch, trackpad scroll
- OSD: Shows channel name and index, auto-hides after 1.8s
- Error handling: Failed streams auto-removed via `dropChannel()`
- Click anywhere: Unmutes and requests fullscreen

### LaTeX CV (`vitae/`)
- **Section ordering** in `cv.tex`: Summary, Experience, Projects, Education, Awards, Certifications, Courses, Skills, Languages, Publications, Recommendations
- **Fonts**: Roboto Slab (headings), Lato (body) - configured in `my.tex`
- **Colors**: Defined in `my.tex`
- **Bibliography**: `my.bib` - standard BibTeX format
- **Cover letter**: Customize via `app.tex` (create file with your letter text)

### LinkedIn Alignment Tool
- **Normalization**: `_clean_for_match()` handles LaTeX accents, unicode, abbreviations
- **Fuzzy matching**: Substring matching after normalization
- **Company canonicalization**: Handles known aliases (see `_COMPANY_CANONICAL`)
- **Date handling**: Converts various formats to MM/YYYY for comparison
- **Debug mode**: `--scrape --debug` saves: debug_screenshot.png, debug_page_text.txt, debug_page.html

## ⚙️ Configuration

### LaTeX Build Variables (override via `make VAR=value`)
- CV: `CV_TEX`, `CV_TEXFLAGS`, `CV_BIB`, `CV_FILE`
- Cover Letter: `CL_TEX`, `CL_TEXFLAGS`, `CL_BIB`, `CL_FILE`

### LinkedIn Tool
- Base directory: `--base-dir` (defaults to script location)
- Scraping: Uses headless Chrome by default (`--no-headless` to show browser)
- Persistent session: Stored in `~/.linkedin_align_profile`

## 🔍 Troubleshooting

### LaTeX Build Issues
- Missing packages: Run `./setup` to install TeX Live dependencies
- PDF generation fails: Check `make cv` output for specific LaTeX errors
- Bibliography issues: Ensure `biber` is installed and `my.bib` is valid

### LinkedIn Tool Issues
- Scraping fails: First run requires manual login in Chrome window
- Playwright missing: Run `pip install playwright && playwright install chromium`
- Date mismatches: Tool normalizes various date formats to MM/YYYY
- Encoding issues: CSV export uses UTF-8-SIG (handled automatically)

### TV Streamer Issues
- Channel not loading: Check URL in channels array, some may be geo-restricted
- Fullscreen blocked: Browser permissions may need adjustment
- OSD not showing: JavaScript errors - check browser console