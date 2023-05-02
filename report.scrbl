#lang scribble/acmart @sigplan @review @;@anonymous

@; vim: textwidth=72

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

@abstract{Some object-oriented GUI toolkits tangle state management with
rendering. Functional reactive toolkits like GUI Easy simplify and
promote the creation of reusable views by analogy to functional
programming. We have successfully used GUI Easy on small and large GUI
projects. We report on our experience constructing and using GUI Easy
and derive from that experience architectural patterns and principles
for building GUI programs.}

@CCSXML|{

<ccs2012>
   <concept>
       <concept_id>10011007.10011006.10011008.10011024.10011029</concept_id>
       <concept_desc>Software and its engineering~Classes and objects</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10010940.10010971.10010972.10010975</concept_id>
       <concept_desc>Software and its engineering~Publish-subscribe / event-based architectures</concept_desc>
       <concept_significance>500</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011009.10011019</concept_id>
       <concept_desc>Software and its engineering~Extensible languages</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011074.10011092.10011096</concept_id>
       <concept_desc>Software and its engineering~Reusability</concept_desc>
       <concept_significance>500</concept_significance>
       </concept>
 </ccs2012>

 }|

@ccsdesc[#:number 500 "Software and its engineering~Publish-subscribe / event-based architectures"]
@ccsdesc[#:number 500 "Software and its engineering~Reusability"]
@ccsdesc[#:number 300 "Software and its engineering~Classes and objects"]
@ccsdesc[#:number 300 "Software and its engineering~Extensible languages"]

@keywords{Reactive GUI, Functional wrapper}

@section{Introduction}
@; try and fit on one page, for reader impact?

Object-oriented programming is traditionally considered a good paradigm
for building graphical (GUI) programs@~cite[b:super+inner]. Racket's GUI
toolkit is object-oriented, using message-passing widgets and mutable
state@~cite[b:racket-gui], and is built atop the Racket programming
platform@~cite[b:racket].

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
                            [callback (λ _ (update-count sub1))]))
                     (define count-label
                       (new message% [parent container]
                            [label (~a count)]
                            [auto-resize #t]))
                     (define +button
                       (new button% [parent container]
                            [label "+"]
                            [callback (λ _ (update-count add1))]))
                     (send f show #t)]]

@Figure-ref{oop-counter.rkt} demonstrates typical Racket GUI code: it
creates a counter, with buttons to increment and decrement a number
displayed on the screen. First, we create a top-level window container,
called a @racket[frame%]. To lay out the controls horizontally, we
create a @racket[horizontal-panel%] as a child of the window. We define
some state to represent the count and a procedure to simultaneously
update the count and its associated label. Next, we create the buttons
and label for the counter. Lastly, we call the @racket[show] method on a
@racket[frame%] to display it to the user.

The code in @figure-ref{oop-counter.rkt} has several shortcomings: it is
overly verbose and organized in a way that obscures the structure of the
resulting interface; it has to manually keep application and UI state in
sync; and, custom components must be created as imperative objects.

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

GUI Easy is a functional reactive wrapper for Racket's GUI system based
on immutable observable values and function composition that aims to
solve problems with the imperative object-based APIs@~cite[b:gui-easy].

With GUI Easy, the code in @figure-ref{easy-counter.rkt} resolves the
previous shortcomings. We define an observable @racket[|@|count] whose
state is the number @racket[0]. Then we call @racket[render] to show the
GUI described by the composition of functions like @racket[window],
@racket[hpanel], @racket[button], and @racket[text]. The callbacks on
the @racket[button] widgets update @racket[|@|count] by computing new
values; these updates automatically propagate to the derived textual
label in the GUI.

In this report, we
@itemlist[
    @item{
        examine the difficulties of programming with object-oriented GUI
        systems and motivate the search for a different system in
        @secref{A_Tale_of_Two_Programmers},
    }
    @item{describe GUI Easy in @secref{GUI_Easy_Overview},}
    @item{
        report on our experience constructing large GUI programs, such
        as the Frosthaven Manager@~cite[b:frosthaven-manager], in
        @secref{Architecting_Frosthaven}, and
    }
    @item{
        explore related trends in GUI and Web programming in
        @secref{related_work}.
    }
]

@section{A Tale of Two Programmers}
@; or "… Two Programs" ?

@; Origin stories in subsections for GUI Easy and Frosthaven, including
@; why Frosthaven chose GUI Easy. Ben thinks the clearest style will be
@; to write about ourselves in the 3rd person, so that the individual
@; stories are clear?

We will present the origin stories for two projects. First, in
@secref{Quest_for_Easier_GUIs}, Bogdan describes the frustrations with
Racket's GUI system that drove him to create GUI Easy. Second, in
@secref{Embarking_for_Frosthaven}, Ben describes the desire to construct
a large GUI program without imperative state. It is the happy union of
these two projects that taught us many architectural lessons.

@subsection{Quest for Easier GUIs}

Bogdan's day job involved writing many small GUI tools for internal use.
For his purposes, the Racket GUI framework proved to be an excellent way
to build those types of GUIs as it provides fast iteration times,
portability across macOS, Linux and Windows, and the ability to
distribute self-contained applications on the aforementioned platforms.

Over time, however, the same set of small annoyances kept cropping up:
Racket's class system is overly verbose; state management and wiring is
bespoke to each project; and, Racket GUI's primary means of constructing
view hierarchies is by passing in parent widgets to child widgets at
construction time. The latter point makes composability especially
frustrating since individual components must always be parameterized
over a parent argument.

@; fixme
@; db library; lexi-lambda/racket-commonmark; http123
The class system is rarely used in Racket outside the GUI toolkit, so
it's a barrier to entry to a Racketeer intending to make a GUI.  As will
hopefully become clear in reading the examples shown in this article, it
is possible to express the same interfaces using a much lighter-weight
textual representation.

Since Racket GUI offers no special support for managing application
state and wiring said state to widgets, the user is forced to bring
their own state management to the table, leading to ad-hoc solutions for
every new project. See @figure-ref{oop-counter.rkt} for an example of
ad-hoc state management. This was the motivation behind the observable
abstraction in GUI Easy. In @secref{GUI_Easy_Overview}, we'll see how
observables and observable-aware views combine to automatically connect
GUI widgets and state changes.

Forcing the user to pass in the parent of a widget at instantiation time
means that components have to either be constructed in a very specific
order, or all components must be wrapped in procedures that take a
parent widget as argument.  Consider the following piece of Racket code:

@; Question someone might reasonably ask: are the problems with Racket
@; GUI caused by its API more than its imperative-ness? Is the state
@; stuff a satisfying answer?

@; consider joining new-message% line to parent line to keep in the same
@; column if needed
@racketblock[
  (define f (new frame% [label "A window"]))
  (define msg
    (new message%
         [parent f]
         [label "Hello World"]))
]

It is impossible to create the message before the frame in this case,
since the message needs a @racket[parent] in order to be constructed in
the first place. This constrains the ways in which the user can organize
their code. Of course, the user can always abstract over message
creation, but that needlessly complicates the process of wiring up
interfaces. This was the motivation behind the @racket[view<%>]
abstraction in GUI Easy. In @secref{GUI_Easy_Overview}, we'll see how
views permit functional abstraction, enabling new organizational
approaches that we'll explore in @secref{Architecting_Frosthaven}.

@; GUI Easy origin

@; - Introduce Racket, class system, GUI programming (briefly!)
@; - Motivate the story: example(s) constructing GUIs with (clunky) imperative
@;   APIs
@; - This method of GUI programming isn't satisfying (do we briefly include reasons?)

@subsection{Embarking for Frosthaven}

Frosthaven is a cooperative tactical fantasy adventure board game for 2
to 4 players and the sequel to Gloomhaven@~cite[b:frosthaven]. In both
games, players play cards to determine turns during a scenario;
separately, monsters take turns based on a deck of cards. Typical
scenarios pit the player team against strange monsters and challenging
obstacles in order to achieve victory. In Frosthaven, victory means more
resources to rebuild the outpost of Frosthaven.

Due to its highly complex nature, Frosthaven includes lots of tokens,
cards, and other physical pieces that must be manipulated to play the
game. This includes tracking monster's health and status, the level of
power of six elements that power special abilities, and more.

The original Gloomhaven game had a helper application for mobile devices
to manage the complexity; at one point, it appeared Frosthaven would not
receive the same treatment.

Ben, a programmer, decided to solve the problem for his personal gaming
group by creating his own helper application. But how? Having never
created a complex GUI program---and knowing this would be a complex
GUI---Ben was intimidated by classic object-oriented GUI systems like
Racket's. To a programmer with intimate knowledge of the class, method,
and event relationships, such a system probably feels natural. To the
novice, GUI Easy presents a simple interface to get started quickly.

GUI Easy made it possible to begin building a complex system out of
simple parts: functions and data. Ben was familiar with functional
programming and was able to grok GUI Easy. Ben began constructing the
Frosthaven Manager@~cite[b:frosthaven-manager] in 2022 using GUI Easy.

@section{GUI Easy Overview}

GUI easy can be broadly split up into two parts: the observable
abstraction and views.

Observables are box-like@note{Boxes are mutable cells; typically
they hold immutable data to permit constrained mutation.} values
with the added property that arbitrary procedures can subscribe to
changes in their contents. @Figure-ref{observables.rkt} shows a usage
example of the basic observable API in GUI Easy. Observables are
constructed with @racket[obs] or the shorthand @racket[|@|]. The
@racket[define/obs] syntactic form creates and binds an observable
to a name. @Secref{Observable_Values} explains the common observable
operators.

@figure["observables.rkt"
        "Use of the basic observable API in GUI Easy."
        @racketblock[(define o (obs 1))
                     (define ((observer name) v)
                       (printf "observer ~a saw ~a~n" name v))
                     (obs-observe! o (observer "a"))
                     (obs-observe! o (observer "b"))
                     (obs-update! o add1)
                     (code:comment "outputs:")
                     (code:comment "observer a saw 2")
                     (code:comment "observer b saw 2")]]

Views in GUI Easy are representations of Racket GUI widgets that,
when rendered, produce instances of Racket GUI widgets and handle the
details of transparently wiring view trees together. They are typically
observable-aware in ways that make sense for each individual widget. For
example, the @racket[text] view takes as input an observable of a string
and the rendered widget's label updates with changes to that observable.
@Figure-ref{easy-counter-reuse.rkt} shows an example of a reusable
counter component made by composing views together. We discuss the view
abstraction in more detail in @Secref{view_detail}.

@figure["easy-counter-reuse.rkt"
        "Component re-use in GUI Easy."
        @racketblock[(define (counter |@|count action)
                       (hpanel
                         (button "-" (λ () (action sub1)))
                         (text (~> |@|count ~a))
                         (button "+" (λ () (action add1)))))

                     (define/obs |@|count-1 0)
                     (define/obs |@|count-2 5)

                     (define ((update-counter |@|counter) proc)
                       (<~ |@|counter proc))

                     (render
                      (window
                       #:title "Counters"
                       (counter |@|count-1 (update-counter |@|count-1))
                       (counter |@|count-2 (update-counter |@|count-2))))]]

@subsection{Observable Values}

The core of the observable abstraction is that arbitrary listeners can
react to changes in the contents of an observable. Application
developers programming with GUI Easy use a few core operators to
construct and manipulate observables.

The value of an observable can be changed using @racket[obs-update!]
(aliased @racket[<~]). The update procedure takes as arguments an
observable and a procedure of one argument (the current value) to
generate a new value. Every update is propagated to any observers
registered at the time of the update.

New observables can be derived from existing ones using the
@racket[obs-map] procedure (aliased @racket[~>]). A derived observable
applies its mapping procedure to every change in value to the observable
it's derived from. Finally, two or more observables can be combined
together into a single derived observable whose value changes when any
input observable changes using @racket[obs-combine]. Derived observables
may not be updated.

@;NOTE(bogdan): might be better not to mention peek unless we need to
@;for other reasons. The idea being that the smaller we keep the API
@;presented, the easier it'll be to grok. Likewise, I'm on the fence
@;about aliases, though right now I'm leaning towards talking about
@;them.

Observables can be @italic{peeked} with @racket[obs-peek];
this unwraps the inner value for use with normal Racket computation,
dual to the observable constructor @racket[obs]. Dialogs and other
side-effectful computations that do not fit into @racket[obs-update!] or
@racket[obs-map] paradigms often use @racket[obs-peek] to operate on
concrete data, effectively collapsing the observable to a single point
in time.

@; Observables can be
@; @italic{updated}: the new value is computed by applying a procedure to
@; the inner value, using @racket[obs-update!]. The alias @racket[<~] is
@; reminiscent of mutation notations like @tt{:=} or @tt{<-}. Finally,
@; observables can be @italic{derived} with @racket[obs-map], computing
@; a derived observable by applying a function to the inner value of a
@; parent observable. Derived observables cannot be directly updated,
@; but update automatically when their parent observable updates. The
@; alias @racket[~>] is reminiscent of threading computations and suggests
@; duality with @racket[obs-update!]. An extension @racket[obs-combine]
@; permits mapping @${n} observables together into a single observable via
@; an @${n}-ary function.

@; Describe GUI Easy enough to follow the rest of the paper. (Is this the best
@; place to mention mixins/view<%>s, aka flexibility?)

@subsection[#:tag "view_detail"]{Views: Functional Shell, Imperative Core}
@; etc., whatever we need here

A view is represented by a class implementing the @racket[view<%>]
interface (@figure-ref{view-iface.rkt}). View implementations wrap
Racket GUI widgets while keeping track of data dependencies and
responding to their changes@~cite[b:gui-easy]. The interface reifies the
GUI widget lifecyle into a concrete object, making explicit the
separation between a GUI widget, its creation, and its reaction to
changes in data dependencies.

@figure["view-iface.rkt"
        "The view<%> interface."
        @racketblock[
(define widget-container/c
  (is-a?/c area-container<%>))
(define widget/c
  (is-a?/c area<%>))

(define view<%>
  (interface ()
    [dependencies (->m (listof obs?))]
    [create (->m widget-container/c widget/c)]
    [update (->m widget/c obs? any/c void?)]
    [destroy (-> widget/c void?)]))]]

If the use of classes, interfaces, and objects is surprising, it is also
sensible: wrapping class-based GUI widgets into the view abstraction is
often straightforward. At the core, in a twist on the classic
``Functional Core, Imperative Shell'' paradigm@~cite[b:functional-core],
lies an imperative object lifecycle. Views must know how to
@italic{create} GUI widgets, how to @italic{update} them in response to
changed data dependencies, and how to @italic{destroy} them if
necessary. They must also be able to propagate data dependencies up the
view tree to a coordinator object. Data dependencies are any observable
values passed into a view; the coordinator object signals updates when
dependencies change, allowing the view to trigger an update in the
underlying widget. Crucially, view instances must be reusable, so they
must carefully associate any internal state they need with each rendered
widget.

At the edge of the library, most programmers interact only with the
functional wrappers around view construction. These wrappers handle the
construction of @racket[view<%>] instances and delegate their observable
and non-observable arguments to specific view objects' constructor
arguments. Thus the shell is functional.

Sometimes the abstraction is too rigid. For flexibility, it is possible
to program against the underlying GUI widgets when the functional
abstraction exposes a @italic{mixin}@note{Mixins permit ad-hoc class
specialization without modifying the source of the class
body@~cite[b:mixins b:super+inner].} parameter; this mixin is composed
with the underlying GUI widget thanks to Racket's first-class classes.

Most Racket GUI widgets are already wrapped by GUI Easy, making it
easy to get started. Programmers can implement the view abstraction
themselves in order to integrate arbitrary GUI widgets, such as those
from 3rd-party packages in the Racket ecosystem, into a GUI Easy-based
project.

@section{Architecting Frosthaven}

This section will describe various pieces of a large GUI Easy
application, the Frosthaven Manager, and derive principles from our
experience in constructing such applications using GUI Easy and similar
frameworks.

@; Describe the architecture of Frosthaven as it pertains to GUI Easy; derive
@; principles (core/shell, DDAU, centralized v. local state, re-usable
@; components/view organization …?). Also mention tradeoffs, problems
@; encountered, etc.

At time of writing, the Frosthaven Manager includes approximately 5000
lines of Racket code. About half of that code composes GUI Easy views
with application code to form the main application. Of the remaining
lines, approximately 1000 implement the data structures and
transformations responsible for the state of the game; 500 cover the
images it draws; 750 implement three plugin languages; 300 test the
project; the remaining lines are small syntactic utilities. The
Frosthaven Manager also has approximately 3000 lines of Scribble code, a
Racket documentation language, including a how-to-play guide and
developer reference.

@subsection{Functional Core: There and Back Again}

@; Does this section do enough to describe the situation and actually
@; derive useful information from it? I feel like it's heavier on
@; description than analysis.

The Frosthaven Manager manipulates many kinds of data. This includes
game characters and their various attributes, monsters and their
attributes, randomized loot, the status of elemental effects, and more.

The functional programmer naturally represents data via immutable data
structures such as records, enumerations, and collections. This
programmer also writes pure functions that transform immutable data into
different representations or representations with different values.
Programming a GUI with GUI Easy does not require the functional
programmer to give up this technique to the same degree that
object-oriented GUI systems do.

In constructing the Frosthaven Manager, Ben organized the main data into
functional records, enumerations, and collections alongside data that
transforms them according to the rules of the game. Thus we say that the
Frosthaven Manager uses a ``functional core,'' a common functional
architecture@~cite[b:functional-core].

The choice of a functional core has many well-known benefits. For
example, this code is independent of the choice of GUI presentation and
is also independently testable or useable for other applications. It is
also independently auditable for correctness according to the game's
rules, which is important for the GUI to be useful.

Layered atop the functional core we find two more major components in
the Frosthaven Manager: GUI-related data and views. In many ways, Ben
took the functional approach here, too. GUI-related data is organized
along typical idioms and paired with transformation functions. Views are
functions that receive only the observable data they need and call input
procedures rather than triggering side-effects themselves.
@Secref{Reusable_GUIs} will cover that design in more detail. Since most
of the relevant data is observable or intended to be observable,
however, the resulting system feels far more imperative. Pure
transformations are useful for reasoning. These same transformations are
paired with observable updates---aka, mutations---for real effect on the
state of the GUI. As a result, though many important and reusable views
seem pure, they are easily composed into a highly imperative system.
This ``imperative shell'' pairs well with typical functional programming
architectures, like the previous functional
core@~cite[b:functional-core].

@subsection{Reusable GUIs}

The Frosthaven Manager's main GUI is composed of many smaller views. By
analogy with functional programming's building blocks (the function),
small reusable views permit construction large systems by composition.
Since a view is a function, this kind of composition is naturally suited
to functional programming architectures.

Reusable views are, in essence, small reusable GUIs. Given the necessary
state, we can turn a reusable view into a GUI by nesting the view in a
@racket[window] and calling @racket[render]. Thus, small reusable views
are amenable to independent testing. The Frosthaven Manager GUI modules
each contain several related views, or sometimes only a single view.
They are each also executable scripts that launch a small GUI for the
module's views: this permits testing the module's views independently of
the larger context. If the views are integrated correctly, the larger
GUI needs less exercise to be completely tested.

Reusable views can be general-purpose, like the @racket[counter] view in
@figure-ref{easy-counter-reuse.rkt} or the Frosthaven Manager's
@racket[markdown-view]. They can also be domain-specific, like views in
the Frosthaven Manager for displaying and manipulating magical elements
or monster groups. Both can be reused and tested as described
previously; general-purpose views might be considered for extraction to
a separate library, much like generic data-structure functions.

There is one major design factor of reusable views. @emph{Views should
not directly manipulate external state.} This is analogous to the rule
for pure functions, and all the same arguments apply to show that
manipulating external state makes a view less reusable. Following this
design principle leads naturally to the principle ``data down, actions
up,'' or @emph{DDAU}. It also guides us to make decisions about which
state to centralize at the highest levels of the GUI and which state to
localize in reusable views.

Let's look at DDAU from two points of view: caller and callee. As a
running example, we'll use the Frosthaven Manager's ``Loot'' button,
whose responsibility is to allow the user assign randomly drawn loot to
a player. An example call is shown in @figure-ref{loot-call.rkt}.

@; Be careful with automatic formatting here; the layout is
@; non-traditional for size…
@figure["loot-call.rkt"
        (list "Extract of and example call to " @racket[loot-button] ".")
        @racketblock[(define (loot-button |@|loot-deck |@|players
                                          #:on-player on-player)
                       (button ... (on-player p) ...))
                     ...
                     (loot-button |@|loot-deck |@|players
                       #:on-player
                       (λ (p) (give-player-loot |@|players p)))]]

First, we'll take the perspective of the callers of reusable views. It
is natural to think of the callees as sub-views and thus ``under'' the
caller. So ``data down'' means that the caller passes observable data
down to the sub-view. For the Loot button, the caller must pass
observables representing the pool of loot to choose from and the players
to which the loot might be assigned. This is all the information the
button needs to display. Similarly, ``actions up'' means that the
sub-view will pass actions back up to the caller. This means that
callers get to specify how to react to events or actions taken by
interacting with the view. In the case of the Loot button, callers may
specify how to react when loot is assigned: they are passed back an
action representing the player to which loot should be assigned. It is
the caller's responsibility to correctly assign the loot item to the
chosen player and trigger updates to the relevant observables.

Next, we'll take the perspective of the callee, that is, of the reusable
view itself. We know from the caller's perspective that the reusable
view receives observable data as input, analogously to pure functions
requiring all data to be input. This would be the Loot button's
observable inputs of the loot pool and players. Similarly, instead of
triggering side-effects on state directly, reusable views pass actions
back up to the caller. This means that instead of calling
@racket[obs-update!] on an input, the view notifies the caller via
callback of a particular action and allows the caller to decide if or
how to update any state. The Loot button calls an input procedure with
local data, such as the ID of the chosen player, to inform its caller of
the loot being assigned. It would be unsafe in the general case to
mutate observable inputs, as they could be derived observables.
Requiring informally that observable inputs not be derived for a
particular view creates a trap for programmers that want to reuse the
view in novel contexts and violates the principles of reusable views.

In practice, DDAU means that reusable views have two groups of formal
function parameters. The first is a series of observables that the view
needs to display itself. The second is a series of callbacks for
different kinds of actions that might be taken. Sometimes, only a single
callback is needed for many kinds of events; other times, it is helpful
to distinguish different events with different callbacks.

DDAU naturally bubbles application state up the view hierarchy, so that
the top-level of an application contains all of the necessary state. It
passes the state down to various sub-views and provides procedures to
respond to their events and actions. This flow of state downward
continues until we reach the very bottom-most layer of abstraction.

Reusable views often compose other views, just as pure functions often
compose other pure functions. So it is natural for a caller to also be a
callee and vice versa. As a consequence, a view sometimes needs to
transform input observables for use as inputs to sub-views. Derived
observables and @racket[obs-map] are particularly helpful in this
situation. Sometimes, however, we need state in a view that is neither
its caller's nor its callee's responsibility. In this case, a reusable
view maintains local observable state which it is free to mutate, say,
in response to an action callback from one of its sub-views. This is in
keeping with the tradition of optimizing functional programs by allowing
interior---but invisible---mutability.

@subsection{Challenges}

Naturally, constructing such a complex GUI is not without its challenges.
What do you do when you need access to the underlying object-oriented
API for a feature not exposed by existing wrappers? How do you handle a
piece of nearly-global state whose usage is hard to predict when writing
reusable components? Fortunately, both of these problems have solutions.

The first problem of access to imperative behaviors is solved by GUI
Easy conventions and APIs. In the traditional object-based API, we would
subclass widgets as needed to create new behaviors. Without access to
the classes, we cannot provide such custom behavior. Thus, many GUI Easy
wrappers support a mixin argument, as discussed in @secref{view_detail}.
This provides a special kind of access to the class implementing the
underlying widget so that we may override or augment methods of the
class as we choose, akin to dynamically subclassing GUI widgets. When
mixins are insufficient, we may choose to write our own @racket[view<%>]
implementation, which can wrap any GUI widget we desire. This includes
core classes, custom subclasses, and third-party widgets. The Frosthaven
Manager makes use of this functionality to implement custom closing
behavior for certain widgets and to wrap editor widgets to display
rendered Markdown@note{https://daringfireball.net/projects/markdown/}
files.

The second problem of global state is handled by functional programming
techniques. Essentially, we have two choices: threading state or dynamic
binding. If we are confident that the state will be required in all
reusable views, we can thread the state as input to every single view.
This quickly becomes tedious and, when we are not so confident, tangles
unnecessary concerns. Dynamic binding breaks some functional purity for
convenience, allowing us to refer to external state. Using dynamic
binding makes views less reusable: they now have dependencies not
defined by their inputs. Dynamic binding permits each view to only be
concerned with the global state if absolutely necessary. The Frosthaven
Manager threads state as much as possible according to DDAU but does use
dynamic binding to retain a reference to the top widget of the main GUI
hierarchy. This reference is needed to calculate the correct relative
coordinates for mouse clicks and popup menus, among other uses.

@section[#:tag "related_work"]{Related Work: Are We GUI Yet?}

@(define (url-note dest)
   @note[@url[dest]])
@(define-syntax-rule (define-notes [id url] ...)
   (begin (define id (url-note url)) ...))
@(define-notes
   [swift-ui "https://developer.apple.com/xcode/swiftui/"]
   [reagent "https://github.com/reagent-project/reagent"]
   [react "https://react.dev"]
   [vue "https://vuejs.org"]
   [elm "https://elm-lang.org"]
   [re-frame "https://github.com/day8/re-frame"]
   [areweguiyet "https://www.areweguiyet.com"])
@(define frtime
   @~cite[b:frtime-in-plt-scheme b:frtime-dataflow b:frtime-thesis])

GUI Easy draws a lot of inspiration from Swift UI@|swift-ui|, another
system that wraps an imperative GUI framework in a functional shell.
Other sources of inspiration include Clojure's Reagent@reagent and
JavaScript's React@|react|. In Racket, FrTime@frtime implements a
functional reactive programming language for GUIs and other tasks.
FrTime is in the spirit of the original functional reactive paradigm,
while Vue@vue, React, and inspired libraries, including GUI Easy,
have evolved slightly different notions of reactive programming. The
Elm@|elm| programming language strictly constrains component composition
to the data down, actions up style. Clojure's re-frame@re-frame
library builds on Reagent@reagent to add more sophisticated state
management, with a global store and effect handler (like observable
update procedures) registry and queries (like derived observables).
Rust's infamous ``Are We GUI Yet?''@areweguiyet website mentions at
least four GUI libraries for functional reactive programming in the
style of React or FrTrime.

While we must be careful not to confuse popularity with usefulness, our
satisfaction programming in the style suggested by GUI Easy and the use
of similar patterns across a variety of programming languages and
ecosystems suggests that, for the functional programmer, reactive GUI
systems are architecturally well-suited to small and large programs.

@section{Conclusion}

@; Summarize problem, works, architectural principles for large
@; functional GUIs

We have reported on the difficulties of programming stateful GUIs with
imperative, object-based APIs. We also described a functional wrapper
called GUI Easy that was inspired by functional reactive programming for
various UI systems. GUI Easy has successfully been used for small and
large GUI projects, such as the Frosthaven Manager discussed in this
report. We derived several architectural principles from the
construction of both projects: functional wrappers over imperative APIs
enable programming via functional shell, even when peeling back layers of
abstraction reveals an imperative core. This also allows organizing
views as independent reusable components. Reusable views, much like pure
functions, should not mutate external state. Like in functional
programs, smaller and reusable views are more easily tested. The
functional approach is not without its challenges, particularly when
abstracting over imperative concerns; escape hatches that pierce the
veil of abstraction are necessary. With careful control, such piercings
can be themselves wrapped in abstractions to manage complexity.

@acks{We thank the anonymous reviewers for their suggestions. Ben is
grateful to Savannah Knoble, Derrick Franklin, John Hines, and Jake
Hicks for playtesting the Frosthaven Manager throughout development, and
to Isaac Childres for bringing us the wonderful world of Gloomhaven and
Frosthaven.}

@(generate-bibliography #:sec-title "References")
