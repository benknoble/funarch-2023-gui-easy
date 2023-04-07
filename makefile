.POSIX:
SHELL = /bin/sh

SCRIBBLE = raco scribble

MAIN = report.scrbl

FILES = $(MAIN) \
        bib.rkt

pdf/report.pdf: $(FILES)
	@mkdir -p pdf
	$(SCRIBBLE) $(SCRIBBLE_OPTS) --dest pdf --pdf $(MAIN)

tex/report.tex: $(FILES)
	@mkdir -p tex
	$(SCRIBBLE) $(SCRIBBLE_OPTS) --dest tex --latex $(MAIN)
