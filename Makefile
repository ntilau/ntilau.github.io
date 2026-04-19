# ============================================================================
# Build configuration for Master's thesis manuscript and defense presentation
# ============================================================================

# --- Manuscript Build Configuration ---
# MS_TEX: LaTeX engine (default: pdflatex)
# MS_TEXFLAGS: Flags passed to pdflatex
#   -interaction=nonstopmode: non-interactive mode (skip prompts)
#   -file-line-error: show errors in file:line format
# MS_BIB: Bibliography processor (optional, empty by default)
# MS_FILE: Main LaTeX source file (default: thesis)
MS_TEX      = pdflatex
MS_TEXFLAGS ?= -interaction=nonstopmode -file-line-error
MS_BIB      ?= biber
MS_FILE     ?= lncv

# --- Presentation Build Configuration ---
# PR_TEX: LaTeX engine (default: pdflatex, beamer-compatible)
# PR_TEXFLAGS: Flags passed to pdflatex
#   -shell-escape: allow shell commands (required for some beamer features)
#   -interaction=nonstopmode: non-interactive mode
#   -file-line-error: show errors in file:line format
# PR_BIB: Bibliography processor (optional, empty by default)
# PR_FILE: Main LaTeX source file (default: defense)
PR_TEX      = pdflatex
PR_TEXFLAGS ?= -shell-escape -interaction=nonstopmode -file-line-error
PR_BIB      ?=
PR_FILE     ?= lncl

# LaTeX auxiliary files to remove during clean
# Includes: cross-references, bibliography, font database, logs, etc.
CLEAN_EXTS = *.aux *.bcf *.blg *.bbl *.brf *.fdb_latexmk *.fls *.lof *.log *.lot *.lpr *.nav *.out *.run.xml *.snm *.toc *.vrb *.synctex.gz *.xmp*

.SUFFIXES: .aux .pdf .tex
.PHONY: all manuscript presentation clean distclean help

# Build both manuscript and presentation
all: cv cl

# Build manuscript PDF
# Process: LaTeX → (Bibliography if configured) → LaTeX → LaTeX
# Three LaTeX passes ensure cross-references and citations are resolved
cv:
	$(MS_TEX) $(MS_TEXFLAGS) $(MS_FILE).tex
	@if [ -n "$(MS_BIB)" ]; then $(MS_BIB) $(MS_FILE); fi
	$(MS_TEX) $(MS_TEXFLAGS) $(MS_FILE).tex
	$(MS_TEX) $(MS_TEXFLAGS) $(MS_FILE).tex

# Build presentation PDF (beamer slides)
# Process: LaTeX → (Bibliography if configured) → LaTeX → LaTeX
# Three LaTeX passes ensure navigation and cross-references are resolved
cl:
	$(PR_TEX) $(PR_TEXFLAGS) $(PR_FILE).tex
	@if [ -n "$(PR_BIB)" ]; then $(PR_BIB) $(PR_FILE).aux; fi
	$(PR_TEX) $(PR_TEXFLAGS) $(PR_FILE).tex
	$(PR_TEX) $(PR_TEXFLAGS) $(PR_FILE).tex

# Remove temporary LaTeX files (keep PDFs)
clean:
	rm -f $(CLEAN_EXTS)

# Remove temporary files AND generated PDFs
distclean: clean
	rm -f $(MS_FILE).pdf $(PR_FILE).pdf

# Display help message with available targets and variables
help:
	@echo "========== LaTeX Build System =========="
	@echo ""
	@echo "TARGETS:"
	@echo "  make / make all      - Build BOTH manuscript and presentation"
	@echo "  make manuscript      - Build ONLY manuscript/$(MS_FILE).pdf"
	@echo "  make presentation    - Build ONLY presentation/$(PR_FILE).pdf"
	@echo "  make clean           - Remove temporary LaTeX files (keeps PDFs)"
	@echo "  make distclean       - Remove temporary files AND PDFs"
	@echo "  make help            - Show this help message"
	@echo ""
	@echo "CONFIGURABLE VARIABLES (override via: make VAR=value):"
	@echo "  Manuscript:"
	@echo "    MS_FILE=$(MS_FILE)          - Main source file (no .tex extension)"
	@echo "    MS_TEX=$(MS_TEX)            - LaTeX engine"
	@echo "    MS_TEXFLAGS                - Compiler flags"
	@echo "    MS_BIB=$(MS_BIB)            - Bibliography processor (biber, bibtex, or empty)"
	@echo ""
	@echo "  Presentation:"
	@echo "    PR_FILE=$(PR_FILE)          - Main source file (no .tex extension)"
	@echo "    PR_TEX=$(PR_TEX)            - LaTeX engine"
	@echo "    PR_TEXFLAGS                - Compiler flags"
	@echo "    PR_BIB=$(PR_BIB)            - Bibliography processor (biber, bibtex, or empty)"
	@echo ""
	@echo "EXAMPLES:"
	@echo "  make                             # Build both documents"
	@echo "  make manuscript                  # Build thesis only"
	@echo "  make clean                       # Clean all temporary files"
	@echo "  make MS_BIB=biber manuscript     # Build with biber bibliography"
	@echo "  make help                        # Show this help message"
