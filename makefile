.POSIX:
SHELL = /bin/sh

SCRIBBLE = raco scribble

STYLE_OPTS = ++style overrides.tex

MAIN = report.scrbl

FILES = $(MAIN) \
        bib.rkt \
        overrides.tex \
        acm-metadata.tex

LATEX_FILES = tex/report.tex \
              tex/acmart.cls \
              tex/screenshot-counter.png \
              tex/screenshot-frosthaven.png

pdf/report.pdf: $(FILES)
	@mkdir -p pdf
	$(SCRIBBLE) $(SCRIBBLE_OPTS) $(STYLE_OPTS) --dest pdf --pdf $(MAIN)

$(LATEX_FILES): $(FILES)
	@mkdir -p tex
	$(SCRIBBLE) $(SCRIBBLE_OPTS) $(STYLE_OPTS) --dest tex --latex $(MAIN)

source.zip: $(LATEX_FILES)
	zip $@ $(LATEX_FILES)
