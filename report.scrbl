#lang scribble/acmart @sigplan @review @;@anonymous

@(require "bib.rkt")

@title{Functional Reactive Architecture for Easy GUIs}
@subtitle{Experience Report}

@acmConference["FUNARCH" "September 2023" "The Westin Seattle Hotel, Seattle, Washington, United States"]

@author["D. Ben Knoble"
        #:email @email|{ben.knoble+funarch2023@gmail.com}|
        #:affiliation (affiliation
                        #:institution @institution{Independent}
                        #:city "Richmond"
                        #:state "Virginia"
                        #:country "USA")]

@author["Bogdan Popa"
        #:email @email|{bogdan@defn.io}|
        #:affiliation (affiliation
                       #:institution @institution{Independent}
                       #:city "Cluj-Napoca"
                       #:state "Cluj"
                       #:country "Romania")]

@; needed?
@abstract{TODO}

@; TODO @terms{} @keywords{}

@section{Introduction}
@; try and fit on one page, for reader impact?

@; - Introduce Racket, class sytem, GUI programming (briefly!)
@; - OOP traditionally good fit for building GUIs (@~cite[b:super+inner])
@; - Motivate the story: example(s) constructing GUIs with (clunky) imperative
@;   APIs
@; - This method of GUI programming isn't satisfying (do we briefly include reasons?)
@;   - Forward reference to "Tale of Two Programmers": we'll spend more time on
@;     why this isn't satisfying there.
@; - Contrast examples with gui-easy FRP-style
@;   - Forward reference to "GUI Easy Overview": we'll describe GUI Easy in more
@;     detail there.
@; - Pose claim: programming functional and reactive GUIs _is_ satisfying (do we
@;   briefly include reasons?)!
@;   - Forward reference to "Architecting FH": we'll spend more time on the
@;     benefits there.

@section{A Tale of Two Programmers}
@; or "… Two Programs" ?

@; Origin stories in subsections for GUI Easy and Frosthaven, including why
@; Frosthaven chose GUI Easy. Ben thinks the clearest style will be to write
@; about ourselves in the 3rd person, so that the individual stories are clear?

@subsection{Quest for Easier GUIs}

@; GUI Easy origin

@subsection{Embarking for Frosthaven}

@; FH origin

@; A sentence or two about the game itself. I was intimidated by the imperative
@; APIs and GUI Easy made working on the project possible. Etc.

@section{GUI Easy Overview}

@; Describe GUI Easy enough to follow the rest of the paper. (Is this the best
@; place to mention mixins/view<%>s, aka flexibility?)

@subsection{Twist: Functional Shell, Imperative Core}
@; etc., whatever we need here

@section{Architecting Frosthaven}

@; Describe the architecture of Frosthaven as it pertains to GUI Easy; derive
@; principles (core/shell, DDAU, centralized v. local state, re-usable
@; components/view organization …?). Also mention tradeoffs, problems
@; encountered, etc.

@subsection{Functional Core: There and Back Again}
@; etc.

@section{Related Work: Are We GUI Yet?}

@; We've highlighted related work as we went, but now: draw more explicit
@; connections to other work. frtime, Rust FP/FRP GUI projects, Web stacks like
@; React, Vue, Elm, Ember, Redux, re-frame. Citations needed :)

@section{Conclusion}

@; Summarize problem, works, architectural principles for large functional GUIs

@; needed?
@acks{TODO}

@(generate-bibliography #:sec-title "References")
