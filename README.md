# LaTeX CV / GitHub Pages

This repository contains LaTeX source files for a personal curriculum vitae website and related documents, published via GitHub Pages.

## Contents

- **`cv.tex`** - Main CV/resume source file
- **`cl.tex`** - Cover letter / slides source file
- **`app.tex`** - Optional document source
- **`altacv.cls`** - Custom LaTeX class for CV formatting
- **`my.bib`** - Bibliography file
- **`Makefile`** - Build configuration for LaTeX compilation
- **`setup`** - Bootstrap script for installing dependencies on supported platforms
- **`index.html`** - Redirect to the main CV PDF

## Building

### Prerequisites

- `make`
- `pdflatex` - LaTeX document preparation system
- `biber` - Bibliography processor (optional, for references)

### Setup

Run the repository setup script to install dependencies on supported systems:

```bash
./setup
```

### Build Commands

```bash
# Build CV
make cv

# Build cover letter / slides
make cl

# Build both documents
make all

# Install dependencies via setup script
make setup

# Clean up auxiliary files
make clean

# Remove generated PDFs as well
make distclean
```

### Output Files

- `cv.pdf` - Compiled CV
- `cl.pdf` - Compiled cover letter / slides

## Customization

The CV uses a custom LaTeX class (`altacv.cls`) for styling. Edit the `.tex` source files to:

- Update personal information
- Modify layout and formatting
- Add or remove sections

## Deployment

The repository is deployed to GitHub Pages at `https://ntilau.github.io/`. The `index.html` redirect points to the main `cv.pdf` document.

## License

Personal content. Please request permission before reusing design elements.
