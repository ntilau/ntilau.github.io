# Personal Website & CV

This repository contains a personal CV/resume and related documents built with LaTeX, published as a GitHub Pages site.

## Contents

- **`lncv.tex`** - Main CV/resume source file
- **`lncl.tex`** - Presentation/beamer slides
- **`altacv.cls`** - Custom LaTeX class for CV formatting
- **`ln.bib`** - Bibliography/references file
- **`Makefile`** - Build configuration for LaTeX compilation
- **`index.html`** - Redirect to the main CV PDF

## Building

### Prerequisites

- `pdflatex` - LaTeX document preparation system
- `biber` - Bibliography processor (optional, for references)

### Build Commands

```bash
# Build CV
make cv

# Build presentation slides
make cl

# Build all documents
make all

# Clean up auxiliary files
make clean

# Remove all generated files
make distclean
```

### Output Files

- `lncv.pdf` - Compiled CV
- `lncl.pdf` - Compiled presentation slides

## Customization

The CV uses a custom LaTeX class (`altacv.cls`) for styling. Edit the `.tex` source files to:

- Update personal information
- Modify layout and formatting
- Add or remove sections

## Deployment

This repository is deployed as a GitHub Pages site at `https://ntilau.github.io/`. The `index.html` file redirects to the main CV PDF.

## License

Personal content. Please request permission before reusing design elements.
