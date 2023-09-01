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
	printf '%s\n' '/copyrightyear.#1/d' wq | ed -s tex/report.tex

source.zip: $(LATEX_FILES)
	zip $@ $(LATEX_FILES)

slides.pdf: slides.rkt aoe-editor-frame-1.png aoe-editor-frame-2.png aoe-editor-frame-3.png aoe-editor-frame-4.png aoe-editor-gui-easy.rkt aoe-editor-oop.rkt screenshot-counter.png screenshot-2counter.png screenshot-frosthaven-with-server.png screenshot-frosthaven.png
	racket slides.rkt -D -o $@
