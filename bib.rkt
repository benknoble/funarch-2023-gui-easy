#lang racket/base

(provide ~cite citet cite-author cite-year generate-bibliography
         (except-out (all-from-out scriblib/autobib) define-cite)
         (all-defined-out))

(require scriblib/autobib)

(define-cite ~cite citet generate-bibliography
             #:cite-author cite-author
             #:cite-year cite-year)

(define b:gui-easy
  (make-bib #:title "racket-gui-easy"
            #:url "https://github.com/Bogdanp/racket-gui-easy"
            #:author "Bogdan Popa"
            #:date "2023"))

(define b:frosthaven-manager
  (make-bib #:title "frosthaven-manager"
            #:url "https://github.com/benknoble/frosthaven-manager"
            #:author "D. Ben Knoble"
            #:date "2023"))

(define b:frosthaven
  (make-bib #:title "Frosthaven"
            #:author (org-author-name "Cephalofair Games")
            #:url "https://cephalofair.com/pages/frosthaven"
            #:date "2023"))

;; https://racket-lang.org/tr/
(define b:racket
  (make-bib #:title    "Reference: Racket"
            #:author   (authors "Matthew Flatt" "PLT")
            #:date     "2010"
            #:location (techrpt-location #:institution "PLT Design Inc."
                                         #:number "PLT-TR-2010-1")
            #:url      "https://racket-lang.org/tr1/"))

(define b:racket-gui
  (make-bib #:title    "GUI: Racket Graphics Toolkit"
            #:author   (authors "Matthew Flatt" "Robert Bruce Findler" "John Clements")
            #:date     "2010"
            #:location (techrpt-location #:institution "PLT Design Inc."
                                         #:number "PLT-TR-2010-3")
            #:url      "https://racket-lang.org/tr3/"))

;; many references to functional or reactive Rust GUI projects: evidence of the
;; direction of GUI development, utility of approach?
(define b:are-we-gui-yet
  (make-bib #:title "Are We GUI Yet?"
            #:url "https://www.areweguiyet.com/"
            #:note "Accessed 1st April 2023"
            #:date "2023"))

;; Racket Java+Beta-inspired class system: "OOP is a natural fit for GUIs!" (roughly)
(define b:super+inner
  (make-bib #:author "David Goldberg, Robert Bruce Findler, and Matthew Flatt"
            #:title "Super and Inner---Together at Last!"
            #:location "Object-Oriented Programming, Languages, Systems, and Applications"
            #:date "2004"
            #:url "http://www.cs.utah.edu/plt/publications/oopsla04-gff.pdf"))

;; more on mixins
(define b:mixins
  (make-bib #:title "Classes and mixins"
            #:author (authors "Matthew Flatt" "Shriram Krishnamurthi" "Matthias Felleisen")
            #:doi "https://doi.org/10.1145/268946.268961"
            #:url "https://cs.brown.edu/~sk/Publications/Papers/Published/fkf-classes-mixins/"
            #:location
            (proceedings-location "25th ACM SIGPLAN-SIGACT symposium on Principles of programming languages"
                                  #:series "POPL '98"
                                  #:pages (list 171 183))
            #:date "1998"))

(define b:functional-core-imperative-shell
  (make-bib #:title "Functional Core, Imperative Shell"
            #:author "Gary Bernhardt"
            #:url "https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell"
            #:date "2012"))

;; FrTime
(define b:frtime-in-plt-scheme
  (make-bib #:title "FrTime: Functional Reactive Programming in PLT Scheme"
            #:author (authors "Gregory Cooper" "Shriram Krishnamurthi")
            #:location (techrpt-location #:institution "Brown"
                                         #:number "CS-03-20")
            #:date "2004"
            #:url "https://cs.brown.edu/research/pubs/techreports/reports/CS-03-20.html"))

(define b:frtime-dataflow
  (make-bib #:title "Embedding Dynamic Dataflow in a Call-by-Value Language"
            #:author (authors "Gregory H. Cooper" "Shriram Krishnamurthi")
            #:date "2006"
            #:url "https://cs.brown.edu/people/sk/Publications/Papers/Published/ck-frtime/"
            #:doi "10.1007/11693024_20"
            #:location (proceedings-location
                         "Proceedings of the 15th European Conference on Programming Languages and Systems"
                         #:pages (list 294 308)
                         #:series "ESOP'06")))

(define b:frtime-thesis
  (make-bib #:title "Integrating Dataflow Evaluation into a Practical Higher-Order Call-by-Value Language"
            #:author "Gregory Harold Cooper"
            #:date "2008"
            #:url "https://cs.brown.edu/people/ghcooper/thesis.pdf"
            #:location (dissertation-location #:institution "Brown University")))
