TEX = pdflatex -shell-escape # -interaction=nonstopmode -file-line-error
BIB = biber
CV = LNResume
CL = LNCoverLetter

.SUFFIXES: .aux .pdf .tex
.PHONY: clean

all : cv

cv:
	$(TEX) $(CV).tex
	$(BIB) $(CV)
	$(TEX) $(CV).tex
	$(TEX) $(CV).tex
	open $(CV).pdf

cl:
	$(TEX) $(CL).tex
	$(TEX) $(CL).tex
	open $(CL).pdf

clean: 
	rm -rf *.aux *.loa *.lof *.log *.lot *.toc *.bbl *.blg *.out *.run.xml *.bcf *.xmpi
