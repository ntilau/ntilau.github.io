TEX = pdflatex -shell-escape -interaction=nonstopmode -file-line-error
BIB = bibtex
FILE = defense

.SUFFIXES: .aux .pdf .tex
.PHONY: clean

all :
	$(TEX) $(FILE).tex
	$(BIB) $(FILE).aux
	$(TEX) $(FILE).tex
	$(TEX) $(FILE).tex

clean: 
	rm -rf *.aux *.loa *.lof *.log *.lot *.toc *.bbl *.blg
