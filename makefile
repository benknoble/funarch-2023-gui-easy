.POSIX:
SHELL = /bin/sh

SCRIBBLE = raco scribble

MAIN = report.scrbl

pdf/report.pdf: report.scrbl
	@mkdir -p pdf
	$(SCRIBBLE) $(SCRIBBLE_OPTS) --dest pdf --pdf $(MAIN)

tex/report.tex: report.scrbl
	@mkdir -p tex
	$(SCRIBBLE) $(SCRIBBLE_OPTS) --dest tex --latex $(MAIN)
