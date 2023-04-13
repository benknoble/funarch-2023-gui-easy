#lang scribble/acmart @sigplan @review @;@anonymous

@(require scribble/core
          scribble/racket
          scriblib/figure
          scriblib/footnote
          "bib.rkt")

@(define-code racket to-element)
@(define-code racketblock to-paragraph)

@(define ($ . xs)
   (make-element (make-style "relax" '(exact-chars))
                 (list "$" xs "$")))

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

Object-oriented program is traditionally considered a good paradigm for building
graphical (GUI) programs@~cite[b:super+inner]. Racket's GUI toolkit is based on
object-oriented message-passing widgets and mutable state@~cite[b:racket-gui].
Racket's GUI toolkit is built atop the Racket programming
platform@~cite[b:racket].

@; TODO: make this two-column with the code split
@figure["oop-counter.rkt"
        "A counter GUI using Racket GUI's object-oriented widgets."
        @racketblock[(require racket/gui)
                     (define f (new frame% [label "Counter"]))
                     (define container
                       (new horizontal-panel% [parent f]))
                     (define count 0)
                     (define (update-count f)
                       (set! count (f count))
                       (send count-label set-label (~a count)))
                     (define -button
                       (new button% [parent container]
                            [label "-"]
                            [callback (λ (button event)
                                        (update-count sub1))]))
                     (define count-label
                       (new message% [parent container]
                            [label (~a count)]
                            [auto-resize #t]))
                     (define +button
                       (new button% [parent container]
                            [label "+"]
                            [callback (λ (button event)
                                        (update-count add1))]))
                     (send f show #t)]]

@Figure-ref{oop-counter.rkt} demonstrates typical Racket GUI code: it creates a
counter GUI, with buttons to increment and decrement a number displayed on the
screen. First, we create a top-level window container, called a @racket[frame%].
To lay out the controls horizontally, we create a @racket[horizontal-panel%] as
a child of window @racket[f]. Now we define some state to represent the count.
We'll also define a procedure to simultaneously update the count and its GUI
display @racket[count-label]. Next, we create the buttons and label for the
counter. Lastly, we call the @racket[show] method on a @racket[frame%] to
display it to the user.

The code in @figure-ref{oop-counter.rkt} has several shortcomings: it tangles
state with visual representation; the structure of widget construction does not
match the structure of the widgets in the GUI; and, new abstractions must be
created as imperative objects.

@; TODO: this should be figure (single-column), but it doesn't show up?
@figure["easy-counter.rkt"
        "A counter GUI using GUI Easy's functional widgets."
        @racketblock[(require racket/gui/easy racket/gui/easy/operator)
                     (define/obs |@|count 0)
                     (render
                       (window
                         #:title "Counter"
                         (hpanel
                           (button "-" (λ () (<~ |@|count sub1)))
                           (text (~> |@|count ~a))
                           (button "+" (λ () (<~ |@|count add1))))))]]

GUI Easy is a functional reactive wrapper for Racket's GUI system based on
immutable observable values and function composition that aims to solve problems
with the imperative object-based APIs@~cite[b:gui-easy].

With GUI Easy, the code in @figure-ref{easy-counter.rkt} resolves the previous
shortcomings. We define an observable @racket[|@|count] whose state is the
number @racket[0]. Then we call @racket[render] to show the GUI described by the
composition of functions like @racket[window], @racket[hpanel], @racket[button],
and @racket[text]. The callbacks on the @racket[button] widgets update
@racket[|@|count] by computing new values; these updates automatically propagate
to the derived textual label in the GUI.

In this report, we
@itemlist[
    @item{
        examine the difficulties of programming with object-oriented GUI systems
        and motivate the search for a different system in
        @secref{A_Tale_of_Two_Programmers},
    }
    @item{describe GUI Easy in @secref{GUI_Easy_Overview},}
    @item{
        report on our experience constructing large GUI programs, such as the
        Frosthaven Manager@~cite[b:frosthaven-manager], in
        @secref{Architecting_Frosthaven}, and
    }
    @item{
        explore related trends in GUI and Web programming in
        @secref{related_work}.
    }
]

@section{A Tale of Two Programmers}
@; or "… Two Programs" ?

@; Origin stories in subsections for GUI Easy and Frosthaven, including why
@; Frosthaven chose GUI Easy. Ben thinks the clearest style will be to write
@; about ourselves in the 3rd person, so that the individual stories are clear?

We will present the origin stories for two projects. First, in
@secref{Quest_for_Easier_GUIs}, Bogdan describes the frustrations with Racket's
GUI system that drove him to create GUI Easy. Second, in
@secref{Embarking_for_Frosthaven}, Ben describes the desire to construct a large
GUI program without imperative state. It is the happy union of these two
projects that taught us many architectural lessons.

@subsection{Quest for Easier GUIs}

Bogdan's dayjob involved writing many small GUI tools for internal
use.  For his purposes, the Racket GUI framework proved to be an
excellent way to build those types of GUIs as it provides fast
iteration times, portability across macOS, Linux and Windows, and the
ability to distribute self-contained applications on the
aforementioned platforms.

@; note: the last one is really more of a property of Racket itself

Over time, however, the same set of small annoyances kept cropping up:
Racket's class system is overly verbose, data management and wiring is
bespoke to each project, and, Racket GUI's primary means of linking
parent and child widgets is by passing in the parent to the child at
construction time.  The latter point makes composability especially
frustrating since individual components must always be parameterized
over a parent argument.

@; fixme
The class system is rarely used in Racket outside the GUI toolkit, so
it's a barrier to entry to a Racketeer intending to make a GUI.  As
will hopefully become clear in reading the examples shown in this
article, it is possible to express the same interfaces using a much
lighter weight textual representation.

Since Racket GUI offers no special support for managing application
data and wiring said data to widgets, the user is forced to come up
with their own abstraction or to write everything up manually (as is
often the case when putting something together quickly).  See
@figure-ref{oop-counter.rkt} for an example of manual data management.
This was the motivation behind the observable abstraction in GUI Easy.

Forcing the user to pass in the parent of a widget at construction
time means that components have to either be constructed in a very
specific order, or all components must be wrapped in procedures that
take a parent widget as argument.  Consider the following piece of
Racket code:

@racketblock[
  (define f (new frame% [label "A window"]))
  (define msg
    (new message%
         [parent f]
         [label "Hello World"]))
]

It is impossible to create the message before the frame in this case,
since the button needs a @racket[parent] in order to be constructed in
the first place.  This constrains the ways in which the user can
organize their code.  Of course, the user can always abstract over
button creation, but that needlessly complicates the process of wiring
up interfaces.  This was the motivation behind the @racket[view<%>]
abstraction in GUI Easy.

@; GUI Easy origin

@; - Introduce Racket, class system, GUI programming (briefly!)
@; - Motivate the story: example(s) constructing GUIs with (clunky) imperative
@;   APIs
@; - This method of GUI programming isn't satisfying (do we briefly include reasons?)

@subsection{Embarking for Frosthaven}

Frosthaven is a cooperative tactical fantasy adventure board game for 2 to 4
players and the sequel to Gloomhaven@~cite[b:frosthaven]. In both games, players
play cards to determine turns during a scenario; separately, monsters take turns
based on a deck of cards. Typical scenarios pit the player team against strange
monsters and challenging obstacles in order to achieve victory. In Frosthaven,
victory means more resources to rebuild the outpost of Frosthaven.

Due to its highly complex nature, Frosthaven includes lots of tokens, cards, and
other physical pieces that must be manipulated to play the game. This includes
tracking monster's health and status, the level of power of six elements that
power special abilities, and more.

The original Gloomhaven game had a helper application for mobile devices to
manage the complexity; at one point, it appeared Frosthaven would not receive
the same treatment.

Ben, a programmer, decided to solve the problem for his personal gaming group by
creating his own helper application. But how? Having never created a complex GUI
program---and knowing this would be a complex GUI---Ben was intimidated by
classic object-oriented GUI systems like Racket's. To a programmer with intimate
knowledge of the class, method, and event relationships, such a system probably
feels natural. To the novice, GUI Easy presents a simple interface to get
started quickly.

GUI Easy made it possible to begin building a complex system out of simple
parts: functions and data. Ben was familiar with functional programming and was
able to grok GUI Easy.

@section{GUI Easy Overview}

GUI easy can be broadly split up into two parts: the observable
abstraction and views.

Observables are box-like@note{Boxes are mutable cells; typically they hold
immutable data to permit constrained mutation.} values with the additional
property that arbitrary procedures can subscribe to changes in their values.
@Figure-ref{observables.rkt} shows a usage example of the basic observable API
in GUI Easy. Observables are constructed with @racket[obs] or the shorthand
@racket[|@|]. The @racket[define/obs] syntactic form creates and binds an
observable to a name. @Secref{Observable_Values} explains the common observable
operators.

@figure["observables.rkt"
        "Use of the basic observable API in GUI Easy."
        @racketblock[(define o (obs 1))
                     (define (observer name)
                       (λ (v)
                         (printf "observer ~a saw ~a~n" name v)))
                     (obs-observe! o (observer "a"))
                     (obs-observe! o (observer "b"))
                     (obs-update! o add1)
                     (code:comment "outputs:")
                     (code:comment "observer a saw 2")
                     (code:comment "observer b saw 2")]]

Views in GUI Easy are representations of Racket GUI widgets that, when rendered,
produce instances of Racket GUI widgets and handle the details of transparently
wiring the views together.  Additionally, they are typically observable-aware in
ways that make sense for each individual view.  For example, the @racket[text]
view takes as input an observable of a string and the rendered widget's label
updates with changes to that observable.  @Figure-ref{easy-counter-reuse.rkt}
shows an example of a reusable counter component made by composing views
together. @Secref{view_detail} explains the view abstraction in more detail.

@figure["easy-counter-reuse.rkt"
        "Component re-use in GUI Easy."
        @racketblock[(define (counter |@|count action)
                       (hpanel
                         (button "-" (λ () (action sub1)))
                         (text (~> |@|count ~a))
                         (button "+" (λ () (action add1)))))

                     (define/obs |@|count-1 0)
                     (define/obs |@|count-2 5)

                     (define (update-counter |@|counter)
                       (λ (proc)
                         (<~ |@|counter proc)))

                     (render
                      (window
                       #:title "Counters"
                       (counter |@|count-1 (update-counter |@|count-1))
                       (counter |@|count-2 (update-counter |@|count-2))))]]

@subsection{Observable Values}

The core of the observable abstraction is that arbitrary listeners can react to
changes to the boxed value. Application developers programming with GUI Easy use
a few core operators to construct, manipulate, and destruct observables.
Observables can be @italic{peeked} with @racket[obs-peek]; this unwraps the
inner value for use with normal Racket computation, dual to the observable
constructor @racket[obs]. Observables can be @italic{updated}: the new value is
computed byapplying a procedure to the inner value, much like a monadic bind,
using @racket[obs-update!]. The alias @racket[<~] is reminiscent of mutation
notations like @tt{:=} or @tt{<-}. Finally, observables can be @italic{derived}
with @racket[obs-map], computing a derived observable by applying a function to
the inner value of a parent observable. Derived observables cannot be directly
updated, but update automatically when their parent observable updates. The
alias @racket[~>] is reminiscent of threading computations and suggests duality
with @racket[obs-update!]. An extension @racket[obs-combine] permits mapping
@${n} observables together into a single observable via an @${n}-ary function.

@; Describe GUI Easy enough to follow the rest of the paper. (Is this the best
@; place to mention mixins/view<%>s, aka flexibility?)

@subsection[#:tag "view_detail"]{Views: Functional Shell, Imperative Core}
@; etc., whatever we need here

A view is represented by a class implementing the @racket[view<%>] interface.
View objects wrap a GUI object while keeping track of data dependencies and
responding to their changes@~cite[b:gui-easy].

If the use of class and objects is surprising, it is also sensible: wrapping
class-based GUI widgets into the view abstraction is often straightforward. At
the core, in a twist on the classic "Functional Core, Imperative Shell"
paradigm@~cite[b:functional-core-imperative-shell], lies an imperative object
lifecycle. Views must know how to @italic{create} GUI widgets, how to
@italic{update} them in response to changed data dependencies, and how to
@italic{destroy} them if necessary. They must also be able to report data
dependencies to a coordinator object. Data dependencies are typically
observable values; the coordinator object signals updates when dependencies
change, allowing the view to trigger an update in the underlying widget.

At the edge of the library, most programmers interact only with the functional
wrappers around view construction. These wrappers delegate their observable and
non-observable parameters to specific view objects' constructor arguments. Thus
the shell is functional.

Sometimes the abstraction is too rigid. For flexibility, it is possible to
program against the underlying GUI widgets when the functional abstraction
exposes a @italic{mixin}@note{Mixins permit ad-hoc class specialization without
modifying the source of the class body@~cite[b:mixins b:super+inner].}
parameter; this mixin is composed with the underlying GUI widget thanks to
Racket's first-class classes.

The most common core GUI controls are wrapped by GUI Easy, making it easy to get
started programming a GUI quickly. The view abstraction makes it possible to
integrate arbitrary GUI widgets, such as those from 3rd-party packages in the
Racket ecosystem, into a GUI Easy-based GUI project.

@section{Architecting Frosthaven}

@; Describe the architecture of Frosthaven as it pertains to GUI Easy; derive
@; principles (core/shell, DDAU, centralized v. local state, re-usable
@; components/view organization …?). Also mention tradeoffs, problems
@; encountered, etc.

At time of writing, the Frosthaven Manager includes approximately 5000 lines of
Racket code. About half of that code composes GUI Easy views with application
code to form the main application. Of the remaining lines, approximately 1000
implement the data structures and transformations responsible for the state of
the game; 500 cover the images it draws; 750 implement three plugin languages;
300 test the project; the remaining lines are small syntactic utilities.
Frosthaven Manager also has approximately 3000 lines of Scribble code, a Racket
documentation language, including a how-to-play guide and developer reference.

@subsection{Functional Core: There and Back Again}
@; etc.

@subsection{GUI Organization and Reuse}

@subsection{Challenges}

@section[#:tag "related_work"]{Related Work: Are We GUI Yet?}

@; We've highlighted related work as we went, but now: draw more explicit
@; connections to other work. frtime, Rust FP/FRP GUI projects, Web stacks like
@; React, Vue, Elm, Ember, Redux, re-frame. Citations needed :)

@section{Conclusion}

@; Summarize problem, works, architectural principles for large functional GUIs

@acks{We thank the anonymous reviewers for their suggestions. Ben is grateful to
Savannah Knoble, Derrick Franklin, John Hines, and Jake Hicks for playtesting
the Frosthaven Manager throughout development, and to Isaac Childres for
bringing us the wonderful world of Gloomhaven and Frosthaven.}

@(generate-bibliography #:sec-title "References")
