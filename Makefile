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
CV_TEX      = pdflatex
CV_TEXFLAGS ?= -interaction=nonstopmode -file-line-error
CV_BIB      ?= biber
CV_FILE     ?= cv

# --- Presentation Build Configuration ---
# PR_TEX: LaTeX engine (default: pdflatex, beamer-compatible)
# PR_TEXFLAGS: Flags passed to pdflatex
#   -shell-escape: allow shell commands (required for some beamer features)
#   -interaction=nonstopmode: non-interactive mode
#   -file-line-error: show errors in file:line format
# PR_BIB: Bibliography processor (optional, empty by default)
# PR_FILE: Main LaTeX source file (default: defense)
CL_TEX      = pdflatex
CL_TEXFLAGS ?= -shell-escape -interaction=nonstopmode -file-line-error
CL_BIB      ?=
CL_FILE     ?= cl

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
	$(CV_TEX) $(CV_TEXFLAGS) $(CV_FILE).tex
	@if [ -n "$(CV_BIB)" ]; then $(CV_BIB) $(CV_FILE); fi
	$(CV_TEX) $(CV_TEXFLAGS) $(CV_FILE).tex
	$(CV_TEX) $(CV_TEXFLAGS) $(CV_FILE).tex

# Build presentation PDF (beamer slides)
# Process: LaTeX → (Bibliography if configured) → LaTeX → LaTeX
# Three LaTeX passes ensure navigation and cross-references are resolved
cl:
	$(CL_TEX) $(CL_TEXFLAGS) $(CL_FILE).tex
	# @if [ -n "$(CL_BIB)" ]; then $(CL_BIB) $(CL_FILE).aux; fi
	# $(CL_TEX) $(CL_TEXFLAGS) $(CL_FILE).tex
	# $(CL_TEX) $(CL_TEXFLAGS) $(CL_FILE).tex

# Remove temporary LaTeX files (keep PDFs)
clean:
	rm -f $(CLEAN_EXTS)

# Remove temporary files AND generated PDFs
distclean: clean
	rm -f $(CV_FILE).pdf $(CL_FILE).pdf

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
	@echo "    CV_FILE=$(CV_FILE)          - Main source file (no .tex extension)"
	@echo "    CV_TEX=$(CV_TEX)            - LaTeX engine"
	@echo "    CV_TEXFLAGS                - Compiler flags"
	@echo "    CV_BIB=$(CV_BIB)            - Bibliography processor (biber, bibtex, or empty)"
	@echo ""
	@echo "  Presentation:"
	@echo "    CL_FILE=$(CL_FILE)          - Main source file (no .tex extension)"
	@echo "    CL_TEX=$(CL_TEX)            - LaTeX engine"
	@echo "    CL_TEXFLAGS                - Compiler flags"
	@echo "    CL_BIB=$(CL_BIB)            - Bibliography processor (biber, bibtex, or empty)"
	@echo ""
	@echo "EXAMPLES:"
	@echo "  make                             # Build both documents"
	@echo "  make manuscript                  # Build thesis only"
	@echo "  make clean                       # Clean all temporary files"
	@echo "  make MS_BIB=biber manuscript     # Build with biber bibliography"
	@echo "  make help                        # Show this help message"
