.POSIX:
SHELL = /bin/sh

SCRIBBLE = scribble

MAIN = report.scrbl

pdf/report.pdf: report.scrbl
	-mkdir pdf
	$(SCRIBBLE) $(SCRIBBLE_OPTS) --dest pdf --pdf $(MAIN)

tex/report.tex: report.scrbl
	-mkdir tex
	$(SCRIBBLE) $(SCRIBBLE_OPTS) --dest tex --latex $(MAIN)
