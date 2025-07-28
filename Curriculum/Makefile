TEX = pdflatex -shell-escape # -interaction=nonstopmode -file-line-error
BIB = biber
CV = LaurentNtibarikureResume
CL = LaurentNtibarikureCoverLetter
MSG = $(shell date +%Y%m%d%H%M%S)

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

push :
	git add --all
	git commit -m $(MSG)
	git push -u origin master

clean: 
	rm -rf *.aux *.loa *.lof *.log *.lot *.toc *.bbl *.blg *.out *.run.xml *.bcf *.xmpi
