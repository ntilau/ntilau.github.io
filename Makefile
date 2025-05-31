TEX = pdflatex -shell-escape # -interaction=nonstopmode -file-line-error
BIB = biber
FILE = LaurentNtibarikureResume
MSG = $(shell date +%Y%m%d%H%M%S)

.SUFFIXES: .aux .pdf .tex
.PHONY: clean

all :
	$(TEX) $(FILE).tex
	$(BIB) $(FILE)
	$(TEX) $(FILE).tex
#$(TEX) $(FILE).tex
	open $(FILE).pdf

push :
	git add --all
	git commit -m $(MSG)
	git push -u origin master

clean: 
	rm -rf *.aux *.loa *.lof *.log *.lot *.toc *.bbl *.blg *.out *.run.xml *.bcf *.xmpi
