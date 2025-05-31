TEX = pdflatex -shell-escape # -interaction=nonstopmode -file-line-error
BIB = biber
FILE = LaurentNtibarikureResume

.SUFFIXES: .aux .pdf .tex
.PHONY: clean

all :
	$(TEX) $(FILE).tex
	$(BIB) $(FILE)
	$(TEX) $(FILE).tex
#$(TEX) $(FILE).tex
	open $(FILE).pdf

clean: 
	rm -rf *.aux *.loa *.lof *.log *.lot *.toc *.bbl *.blg *.out *.run.xml *.bcf *.xmpi
