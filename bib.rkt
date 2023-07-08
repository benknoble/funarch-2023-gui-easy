#lang racket/base

(provide ~cite citet cite-author cite-year generate-bibliography
         (except-out (all-from-out scriblib/autobib) define-cite)
         (all-defined-out))

(require scriblib/autobib)

(define-cite ~cite citet generate-bibliography
             #:cite-author cite-author
             #:cite-year cite-year
             #:style number-style)

(define b:gui-easy
  (make-bib #:title "Announcing GUI Easy"
            #:url "https://defn.io/2021/08/01/ann-gui-easy/"
            #:author "Bogdan Popa"
            #:date "2021"))

(define b:frosthaven-manager
  (make-bib #:title "frosthaven-manager"
            #:url "https://github.com/benknoble/frosthaven-manager"
            #:author "D. Ben Knoble"
            #:date "2022"))

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
  (make-bib #:author (authors "David Goldberg" "Robert Bruce Findler" "Matthew Flatt")
            #:title "Super and Inner---Together at Last!"
            #:location (proceedings-location
                        "Object-Oriented Programming, Languages, Systems, and Applications")
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

(define b:jigsaw
  (make-bib #:title "The Programming Languages Jigsaw: Mixins, Modularity, and Inheritance"
            #:author "Gilad Bracha"
            #:location (dissertation-location #:institution "University of Utah")
            #:date "1992"
            #:url "https://bracha.org/jigsaw.pdf"
            #:note "Ch. 3"))

(define b:denote-inheritance
  (make-bib #:title "A Denotational Semantics of Inheritance"
            #:author "William R. Cook"
            #:location (dissertation-location #:institution "Brown University")
            #:date "1989"
            #:url "https://www.cs.utexas.edu/~wcook/papers/thesis/cook89.pdf"
            #:note "Ch. 10"))

(define b:flavors
  (make-bib #:title "Object-oriented programming with Flavors"
            #:author "David A. Moon"
            #:location (proceedings-location
                        "ACM Conference on Object-oriented Programming, Systems, Languages, and Applications"
                        #:pages (list 1 8))
            #:date "1986"
            #:url "https://www.cs.tufts.edu/comp/150FP/archive/david-moon/flavors.pdf"))

(define b:functional-core
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
                         "15th European Conference on Programming Languages and Systems"
                         #:pages (list 294 308)
                         #:series "ESOP'06")))

(define b:frtime-gui
  (make-bib #:title "Crossing State Lines: Adapting Object-Oriented Frameworks to Functional Reactive Languages"
            #:author (authors "Daniel Ignatoff" "Gregory H. Cooper" "Shriram Krishnamurthi")
            #:date "2006"
            #:url "https://link.springer.com/chapter/10.1007/11737414_18"
            #:location (proceedings-location
                        "Functional and Logic Programming"
                        #:series "FLOPS 2006")))

(define b:frtime-thesis
  (make-bib #:title "Integrating Dataflow Evaluation into a Practical Higher-Order Call-by-Value Language"
            #:author "Gregory Harold Cooper"
            #:date "2008"
            #:url "https://cs.brown.edu/people/ghcooper/thesis.pdf"
            #:location (dissertation-location #:institution "Brown University")))

;; FRP

(define b:fran
  (make-bib #:title "Functional reactive animation."
            #:author (authors "Conal Elliot" "Paul Hudak")
            #:date "1997"
            #:location (proceedings-location
                        "ACM SIGPLAN International Conference on Functional Programming"
                        #:pages (list 263 277))
            #:url "http://conal.net/papers/icfp97/"))

(define b:frappe
  (make-bib #:title "Frappé: Functional Reactive Programming in Java"
            #:author (authors "Antony Courtney")
            #:date "2001"
            #:location (proceedings-location "Practical Aspects of Declarative Languages")
            #:url "https://doi.org/10.1007/3-540-45241-9_3"))

(define b:frp-cont
  (make-bib #:title "Functional Reactive Programming, Continued"
            #:author (authors "Henrik Nilsson" "Antony Courtney" "John Peterson")
            #:date "2002"
            #:location (proceedings-location "ACM SIGPLAN Workshop on Haskell"
                                             #:pages (list 51 64))
            #:url "https://www.antonycourtney.com/pubs/frpcont.pdf"))

(define b:swift-ui
  (make-bib #:title "SwiftUI"
            #:date "2023"
            #:author "Apple"
            #:url "https://developer.apple.com/xcode/swiftui/"
            #:note "Retrieved June 2023."))

(define b:reagent
  (make-bib #:title "Reagent"
            #:date "2023"
            #:author "reagent-project"
            #:url "https://github.com/reagent-project/reagent"
            #:note "Retrieved June 2023."))

(define b:react
  (make-bib #:title "React"
            #:date "2023"
            #:author "Meta Open Source"
            #:url "https://react.dev"
            #:note "Retrieved June 2023."))

;; unused?
(define b:vue
  (make-bib #:title "Vue.js - The Progressive JavaScript Framework | Vue.js"
            #:date "2023"
            #:author "Evan You"
            #:url "https://vuejs.org"
            #:note "Retrieved June 2023."))

(define b:elm
  (make-bib #:title "Elm - delightful language for reliable web applications"
            #:date "2021"
            #:author "Evan Czaplicki"
            #:url "https://elm-lang.org"
            #:note "Retrieved June 2023."))

(define b:re-frame
  (make-bib #:title "re-frame"
            #:date "2023"
            #:author "Day 8 Technology"
            #:url "https://github.com/day8/re-frame"
            #:note "Retrieved June 2023."))

;; unused?
(define b:areweguiyet
  (make-bib #:title "Are we GUI yet?"
            #:date "2022"
            #:author "areweguiyet"
            #:url "https://www.areweguiyet.com"
            #:note "Retrieved June 2023."))

(define b:markdown
  (make-bib #:title "Daring Fireball: Markdown"
            #:date "2023"
            #:author "John Gruber"
            #:url "https://daringfireball.net/projects/markdown/"
            #:note "Retrieved June 2023."))

(define b:drscheme
  (make-bib #:title "DrScheme: A programming environment for Scheme."
            #:date "2002"
            #:author (authors "Robert Bruce Findler"
                              "John Clements"
                              "Cormac Flanagan"
                              "Matthew Flatt"
                              "Shriram Krishnamurthi"
                              "Paul Steckler"
                              "Matthias Felleisen")
            #:location (journal-location "Journal of Functional Programming"
                                         #:pages (list 159 182)
                                         #:volume 12
                                         #:number 2)))

(define b:raco
  (make-bib #:title "raco: Racket Command-Line Tools"
            #:date "2010"
            #:url "https://docs.racket-lang.org/raco/index.html"))

(define b:garnet
  (make-bib #:title "A New Model for Handling Input"
            #:date "1990"
            #:author "Brad A. Myers"
            #:location (journal-location "ACM Transactions on Information Systems"
                                         #:pages (list 289 320)
                                         #:volume 8
                                         #:number 3)
            #:doi "https://doi.org/10.1145/98188.98204"
            #:url "https://www.cs.cmu.edu/~amulet/papers/p289-myers-TOIS-new-model.pdf"))

(define b:mvc
  (make-bib #:title "A description of the model-view-controller user interface paradigm in the Smalltalk-80 system"
            #:date "1988"
            #:author (authors "Glenn E. Krasner" "Stephen T. Pope")
            #:location (journal-location "Journal of Object-Oriented Programming"
                                         #:pages (list 26 49)
                                         #:volume 1
                                         #:number 3)
            #:url "https://www.ics.uci.edu/~redmiles/ics227-SQ04/papers/KrasnerPope88.pdf"))

(define b:smalltalk80
  (make-bib #:title "Smalltalk-80: The Interactive Programming Environment"
            #:author "Adele Goldberg"
            #:date "1983"
            #:is-book? #t
            #:location (book-location #:publisher "Addison-Wesley Publishers.")))

(define b:andrew
  (make-bib #:title "The Andrew Toolkit—An Overview"
            #:author (authors "Andrew J. Palay" "Wilfred J. Hansen" "Michael L. Kazar" "Mark Sherman" "Maria G. Wadlow" "Thomas P. Neuendorffer" "Zalman Stern" "Miles Bader" "Thom Peters")
            #:date "1988"
            #:location (proceedings-location "USENIX Winter Conference"
                                             #:pages (list 9 22))))

(define b:drc
  (make-bib #:title "Designing Reusable Classes"
            #:date "1988"
            #:author (authors "Ralph E. Johnson" "Brian Foote")
            #:location (journal-location "Journal of Object-Oriented Programming"
                                         #:pages (list 22 35)
                                         #:volume 1
                                         #:number 2)
            #:url "http://www.laputan.org/drc/drc.html"))

(define b:mesa
  (make-bib #:title "The Mesa Programming Environment"
            #:date "1985"
            #:author "Richard E. Sweet"
            #:location (journal-location "ACM SIGPLAN Notices"
                                         #:pages (list 216 229)
                                         #:volume 20
                                         #:number 7)
            #:doi "https://doi.org/10.1145/17919.806843"
            #:url "https://www.digibarn.com/friends/curbow/star/XDEPaper.pdf"))

(define b:tajo
  (make-bib #:title "Tajo Functional Specification Version 6.0,"
            #:date "1980"
            #:author "Donald C. Wallace"
            #:location "Xerox Internal Document"))
