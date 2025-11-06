# Makefile for LaTeX project automation

LATEXMK ?= latexmk
MAIN_TEX ?= main.tex
MSG ?= chore: publish LaTeX PDF

.PHONY: pdf watch clean publish

pdf:
	$(LATEXMK) -pdf $(MAIN_TEX)

watch:
	$(LATEXMK) -pdf -pvc $(MAIN_TEX)

clean:
	$(LATEXMK) -C
	rm -rf build
	rm -f main.pdf

publish:
	./publish.sh "$(MSG)"
