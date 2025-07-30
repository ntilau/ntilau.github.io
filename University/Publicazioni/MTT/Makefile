TEX = pdflatex #-shell-escape -interaction=nonstopmode -file-line-error
BIB = bibtex
FILE = MTT_HBFE

.SUFFIXES: .aux .pdf .tex
.PHONY: clean

all :
	$(TEX) $(FILE).tex
	$(BIB) $(FILE).aux
	$(TEX) $(FILE).tex
	$(TEX) $(FILE).tex

clean: 
	rm -rf *.aux *.lo* *.lof *.log *.lot *.toc *.bbl *.blg *.pag
