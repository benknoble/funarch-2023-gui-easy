#lang scribble/acmart @sigplan @screen @review @;@anonymous

@; vim: textwidth=72

@(require scribble/core
          (only-in scribble/manual
                   racket
                   racketblock
                   racketmod0)
          scriblib/figure
          scriblib/footnote
          "bib.rkt")

@(define ($ . xs)
   (make-element (make-style "relax" '(exact-chars))
                 (list "$" xs "$")))

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
   [areweguiyet "https://www.areweguiyet.com"]
   [markdown "https://daringfireball.net/projects/markdown/"])

@title{Functional Shell and Observable Architecture for Easy GUIs}
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
rendering. Functional shell and observable toolkits like GUI Easy
simplify and promote the creation of reusable views by analogy to
functional programming. We have successfully used GUI Easy on small and
large GUI projects. We report on our experience constructing and using
GUI Easy and derive from that experience architectural patterns and
principles for building GUI programs.}

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
for building graphical (GUI) programs due to inheritance, composition,
and specialization. Racket's GUI toolkit@~cite[b:racket-gui] is
object-oriented, with message-passing widgets and mutable state. The
Racket platform@~cite[b:racket] provides the core class and object
library for the GUI toolkit.

@figure["oop-counter.rkt"
        "A counter GUI using Racket GUI's object-oriented widgets."
        @racketmod0[
        racket/gui
        (define f (new frame% [label "Counter"]))
        (define container
          (new horizontal-panel% [parent f]))
        (define count 0)
        (define (update-count f)
          (set! count (f count))
          (define new-label (number->string count))
          (send count-label set-label new-label))
        (define minus-button
          (new button% [parent container]
               [label "-"]
               [callback (λ _ (update-count sub1))]))
        (define count-label
          (new message% [parent container]
               [label "0"]
               [auto-resize #t]))
        (define plus-button
          (new button% [parent container]
               [label "+"]
               [callback (λ _ (update-count add1))]))
        (send f show #t)]]

@Figure-ref{oop-counter.rkt} demonstrates typical Racket GUI code: it
renders a counter with buttons to increment and decrement a number.
First, we create a top-level window container, called a @racket[frame%].
To lay out the controls horizontally, we nest a
@racket[horizontal-panel%] as a child of the window. We define the count
state and a procedure to simultaneously update the count and its
associated label. Next, we create the buttons and label for the counter.
Lastly, we call the @racket[show] method on the @racket[frame%] to
render it for the user.

The code in @figure-ref{oop-counter.rkt} has several shortcomings. It is
verbose relative to the complexity of the GUI it describes and organized
in a way that obscures the structure of the resulting interface. The
programmer manually synchronizes application state, like the count, and
UI state, like the message label, by mutation.

@figure["easy-counter.rkt"
        "A counter GUI using GUI Easy's functional widgets."
        @racketmod0[
        racket
        (require racket/gui/easy racket/gui/easy/operator)
        (define |@|count (|@| 0))
        (render
          (window
            #:title "Counter"
            (hpanel
              (button "-" (λ () (<~ |@|count sub1)))
              (text (~> |@|count number->string))
              (button "+" (λ () (<~ |@|count add1))))))]]

GUI Easy is a functional shell for Racket's GUI system based on
observable values and function composition that aims to solve the
problems with the imperative object-based APIs@~cite[b:gui-easy].

With GUI Easy, the code in @figure-ref{easy-counter.rkt} resolves the
previous shortcomings. As state, we define an observable
@racket[|@|count] whose initial value is the number @racket[0]. Then we
@racket[render] the GUI composed of widgets like @racket[window],
@racket[hpanel], @racket[button], and @racket[text]. Their properties,
such as size or label, may be constant values or observables. The
rendered GUI is automatically updated when observables change, as in
React@|react| for the Web. Buttons on the GUI update the counter state,
triggering updates to the GUI.

In this report, we
@itemlist[
    @item{
        examine the difficulties of programming with object-oriented GUI
        systems and motivate the search for a different system in
        @secref{A_Tale_of_Two_Programmers},
    }
    @item{describe the key GUI Easy abstractions in @secref{GUI_Easy_Overview},}
    @item{
        report on our experience constructing large GUI programs, such
        as the Frosthaven Manager@~cite[b:frosthaven-manager], in
        @secref{arch-frost}, and
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

We present the origin stories for two projects. First, in
@secref{Quest_for_Easier_GUIs}, Bogdan describes his frustrations with
Racket's GUI system that drove him to create GUI Easy. Second, in
@secref{Embarking_for_Frosthaven}, Ben describes his desire to construct
a large GUI program without mutable state. The happy union of these two
desires taught us the architectural lessons we present in
@secref{arch-frost}.

@subsection{Quest for Easier GUIs}

Bogdan's day job involved writing many small GUI tools for internal use.
The Racket GUI framework proved an excellent way to build those types of
tools as it provides fast iteration times, portability across major
operating systems, and distribution of self-contained applications.

Over time, however, Bogdan was repeatedly annoyed by the same
inconveniences. Racket's class system requires verbose code. Each
project handles state updates in its own way. Racket GUI's primary means
of constructing view hierarchies is to construct child widgets with
references to their parent widgets, which makes composition especially
frustrating since individual components must always be parameterized
over their parent.

Since Racket GUI offers no special support for managing application
state and wiring said state to widgets, Bogdan had to bring his own
state management to the table, leading to ad hoc solutions for every new
project. See @racket[update-count] in @figure-ref{oop-counter.rkt} for
an example of ad hoc state management. This motivated Bogdan's
observable abstraction in GUI Easy. In @secref{GUI_Easy_Overview}, we'll
see how observables and observable-aware views combine to automatically
connect GUI widgets and state changes.

It is also inconvenient that constructing a component requires the
parent widget. So Bogdan must either (a) construct all components in a
specific, hard-to-change order or (b) wrap all components in procedures
with a parent parameter. Consider the following piece of Racket code:

@racketblock[
  (define f (new frame% [label "A window"]))
  (define msg
    (new message% [parent f]
         [label "Hello World"]))
]

@; is the switch from Bogdan to We jarring?
We cannot create the message object before the frame object in this
case, since we need a @racket[parent] for the message object. This
constrains how we can organize code. We can abstract over message object
construction, but that needlessly complicates wiring up interfaces. This
motivated Bogdan's view abstraction in GUI Easy. In
@secref{GUI_Easy_Overview}, we'll see how views permit functional
abstraction, enabling new organizational approaches that we'll explore
in @secref{arch-frost}.

@subsection{Embarking for the Town of Frosthaven}

Ben enjoys boardgames with a group of friends, especially
Frosthaven@~cite[b:frosthaven], the sequel to Gloomhaven. Due to its
highly complex nature, Frosthaven includes lots of tokens, cards, and
other physical pieces that we the players must manipulate to play the
game. This includes tracking monsters' health and conditions, the
strength of six magical elements that power special abilities, and more.
The original Gloomhaven game had a helper application for mobile devices
to reduce physical manipulation; at one point, it appeared Frosthaven
would not receive the same treatment.

Ben, a programmer, decided to solve the problem for his personal gaming
group by creating his own helper application. But how? Having never
created a complex GUI program---and knowing this would be a complex
GUI---Ben was intimidated by classic object-oriented GUI systems like
Racket's. To a programmer with intimate knowledge of the class, method,
and event relationships, such a system may feel natural. To the GUI
novice, like Ben, GUI Easy represents a simpler functional-oriented path
to GUI programming.

GUI Easy makes it possible to build a complex system out of simple
parts: functions and data. Ben was familiar with functional programming
and grokked GUI Easy, so Ben started programming the Frosthaven
Manager@~cite[b:frosthaven-manager] with GUI Easy in 2022.

@section{GUI Easy Overview}

GUI easy can be broadly split up into two parts: @italic{observables}
and @italic{views}.

Observables contain values and notify subscribed observers of changes
from @racket[<~]. @Figure-ref{observables.rkt} shows an example of how
we might use the low-level observable API in GUI Easy. We create
observables with @racket[|@|]. @Secref{Observable_Values} explains the
other observable operators.

@; Be careful with automatic formatting here; the layout is
@; non-traditional for size…
@figure["observables.rkt"
        "Using the low-level observable API in GUI Easy."
        @racketblock[(define |@|o (|@| 1))
                     (obs-observe! |@|o
                       (λ (x) (printf "observer a saw ~a\n" x)))
                     (obs-observe! |@|o
                       (λ (x) (printf "observer b saw ~a\n" x)))
                     (code:comment "change the observable by adding 1")
                     (<~ |@|o add1)
                     (code:comment "outputs:")
                     (code:comment "observer a saw 2")
                     (code:comment "observer b saw 2")]]

Views are representations of Racket GUI widget trees that, when
rendered, produce instances of those trees and handle the details of
transparently wiring state and view together. We discuss the view
abstraction in more detail in @Secref{view_detail}.

@figure["easy-counter-reuse.rkt"
        "Component re-use in GUI Easy."
        @racketblock[(define (counter |@|count action)
                       (hpanel
                         (button "-" (λ () (action sub1)))
                         (text (~> |@|count number->string))
                         (button "+" (λ () (action add1)))))

                     (define |@|c1 (|@| 0))
                     (define |@|c2 (|@| 5))

                     (render
                      (window
                       #:title "Counters"
                       (counter |@|c1 (λ (proc) (<~ |@|c1 proc)))
                       (counter |@|c2 (λ (proc) (<~ |@|c2 proc)))))]]

@subsection{Observable Values}

The core of the observable abstraction is that arbitrary observers react
to changes in the value of an observable. Application developers
programming with GUI Easy use a few core operators to construct and
manipulate observables.

We can change the contents of an observable using @racket[<~]. This
procedure takes as arguments an observable and a procedure of one
argument, representing the current value, to generate a new value. Every
change is propagated to any observers registered at the time of the
update.

We can derive new observables from existing ones using @racket[~>]. This
procedure also takes an observable and a procedure of one argument, the
current value. A derived observable changes with its input observable by
applying its mapping procedure to the values of its input observables.
In @figure-ref["easy-counter-reuse.rkt"], the derived observable
@racket[(~> |@|count number->string)] changes every time
@racket[|@|count] is updated by @racket[<~]; its value is the result of
applying @racket[number->string] to the value of @racket[|@|count]. We
cannot directly update derived observables.

We can peek at an observable with @racket[obs-peek], which returns the
contents of the observable. This operation is useful to get
point-in-time values out of observables when displaying modal dialogs or
other views that require a snapshot of the state.

@subsection[#:tag "view_detail"]{Views as Functions}
@; etc., whatever we need here

Views are functions that return a @racket[view<%>] instance, whose
underlying details we'll cover in @secref{view_impl}. Views might wrap a
specific GUI widget, like a text message or button, or they might
construct a tree of smaller views, forming a larger component. Both
forms are synonymous with ``view'' in this paper. We've already seen
many examples of views like @racket[text], @racket[hpanel], and
@racket[counter].

Views are typically observable-aware in ways that make sense for each
view. For instance, the @racket[text] view takes as input an observable
string and the rendered text label updates with changes to that
observable. @Figure-ref{easy-counter-reuse.rkt} shows an example of a
reusable counter component made by composing views together.

Many Racket GUI widgets are already wrapped by GUI Easy. Programmers can
implement the @racket[view<%>] interface, discussed in
@secref{view_impl}, in order to integrate arbitrary GUI widgets, such as
those from 3rd-party packages in the Racket ecosystem, into a GUI
Easy-based project.

@section[#:tag "arch-frost"]{The Architecture of Frosthaven}

In this section, we describe various pieces of a large GUI Easy
application, the Frosthaven Manager, and derive principles from our
experience in constructing such applications using GUI Easy and similar
frameworks.

@; Describe the architecture of Frosthaven as it pertains to GUI Easy; derive
@; principles (core/shell, DDAU, centralized v. local state, re-usable
@; components/view organization …?). Also mention tradeoffs, problems
@; encountered, etc.

At time of writing, the Frosthaven Manager includes approximately 5000
lines of Racket code. About half of that code construct the main
application by combining GUI Easy views with domain-specific code. Of
the remaining lines, approximately 1000 implement the data structures
and transformations responsible for the state of the game; 500 cover the
images it draws; 750 implement three plugin languages; 300 test the
project; the remaining lines are small syntactic utilities. The
Frosthaven Manager also has approximately 3000 lines of
Scribble@note{Scribble is a Racket prose and documentation language.}
code which includes a how-to-play guide and developer reference.

@subsection{Functional Core: There and Back Again}

@; Does this section do enough to describe the situation and actually
@; derive useful information from it? I feel like it's heavier on
@; description than analysis.

The Frosthaven Manager manipulates many kinds of data. This includes
game characters and their various attributes, monsters and their
attributes, randomized loot, the status of elemental effects, and more.

The functional programmer naturally represents data via immutable data
structures such as records, enumerations, and collections. They also
writes pure functions that transform immutable data into different
representations or representations with different values. In contrast,
object-oriented systems rely on mutable state and side-effecting class
methods, which usually clash with functional programming techniques.
Programming a GUI with GUI Easy permits the functional programmer to
retain functional programming techniques to a greater degree than
object-oriented GUI systems do.

In constructing the Frosthaven Manager, Ben organized the main data into
immutable records, enumerations, and collections alongside pure
functions that transform data according to the rules of the game. Thus
we say that the Frosthaven Manager uses a ``functional core,'' a common
functional architecture@~cite[b:functional-core].

The choice of a functional core has many well-known benefits. For
example, this code is independent of the choice of GUI presentation and
is also independently testable or useable for other applications. It
also simplifies programmer reasoning about core application data flow.

Layered atop the functional core we find two more major components in
the Frosthaven Manager: GUI-related data and domain-specific views. In
many ways, Ben took the functional approach here, too. GUI-related data
is organized along typical idioms and paired with transformation
functions. Domain-specific views are reusable components built out of
GUI Easy views and other domain-specific views. In
@secref{Reusable_GUIs}, we will cover the design of such reusable GUIs
in more detail. Despite these functional qualities, since most of the
relevant data is observable or intended to be observable, the resulting
system feels far more imperative. For example, pure transformations from
the core are paired with observable updates---akin to mutations---for
real effect on the state of the GUI. As a result, though many important
and reusable views seem pure, they are easily combined into a highly
imperative system. This ``imperative shell'' pairs well with the
previous functional core, giving us a familiar functional
architecture@~cite[b:functional-core].

@subsection{Reusable GUIs}

The Frosthaven Manager's main GUI comprises many smaller reusable views.
By analogy with functional programming's building
blocks---functions---small reusable views permit us to construct large
systems via composition. Reusable views often consist of other views,
just as pure functions often are composed of other pure functions. Since
a view is a function, albeit often a wrapper, this kind of composition
is naturally suited to functional programming architectures.

Reusable views are, in essence, small reusable GUIs. Given the necessary
state, we can turn a reusable view into a GUI by nesting the view in a
@racket[window] and calling @racket[render].

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
whose responsibility is to assign randomly drawn loot to a player. An
example call is shown in @figure-ref{loot-call.rkt}.

@; Be careful with automatic formatting here; the layout is
@; non-traditional for size…
@figure["loot-call.rkt"
        (list "Extract of, and example call to, " @racket[loot-button] ".")
        @racketblock[(define (loot-button |@|loot-deck |@|players
                                          #:on-player on-player)
                       (button ... (on-player p) ...))
                     (loot-button |@|loot-deck |@|players
                       #:on-player
                       (λ (p) (give-player-loot |@|players p)))]]

First, we'll take the perspective of the callers of reusable views.
``Data down'' means that the caller passes observable data down to the
called view. For the Loot button, the caller must pass observables
@racket[|@|loot-deck] and @racket[|@|players]. This is all the
information the button needs to display. Similarly, ``actions up'' means
that the called view will pass actions back up to the caller. Callers
pass in actions that specify how to react when events and actions are
produced by user interactions with the view. In the case of the Loot
button, callers may specify how to react ``on choosing a player.'' It is
the caller's responsibility to correctly assign the loot item to the
chosen player and trigger updates to the relevant observables.

Next, we'll take the perspective of the callee, that is, of the reusable
view itself. We know from the caller's perspective that the reusable
view receives observable data as input, analogously to pure functions
requiring all data to be input. This would be the Loot button's
observable inputs. Similarly, instead of triggering side-effects on
state directly, reusable views pass actions back up to the caller.
Instead of calling @racket[obs-update!] on an input, the view notifies
the caller via callback. The Loot button calls an input procedure
@racket[on-player] with local data, such as the chosen player, to inform
its caller of the loot assignment.

It would be unsafe in the general case to mutate observable inputs, as
they could be derived observables. Requiring informally that observable
inputs not be derived for a particular view creates a trap for
programmers that want to reuse the view in novel contexts and violates
the principles of reusable views.

In practice, DDAU means that reusable views have two groups of formal
function parameters. The first is a series of observables for display.
The second is a series of callbacks for different kinds of actions.
Sometimes, only a single callback is needed for many kinds of events;
other times, it is helpful to distinguish different events with
different callbacks.

DDAU naturally bubbles application state up the view hierarchy, so that
the top-level of an application contains all of the necessary state.
Callers pass the state down to various sub-views and provide procedures
to respond to events and actions. This downward flow of state continues
until we reach the bottom-most layer. Sometimes, however, we need state
in a view that is neither the view caller's nor callee's responsibility.
In this case, a reusable view maintains local observable state which it
is free to mutate, say, in response to an action callback from one of
its sub-views. This is in keeping with the tradition of optimizing
functional programs by allowing interior---but invisible---mutability.

Small reusable views are amenable to independent testing. The Frosthaven
Manager contains multiple independent GUI modules, a hallmark of modular
programming. Each contains related views; sometimes, only a single view
is exported from the module, while others are implementation details.
Each module also acts as an executable script that launches a small GUI
demonstrating the module's views: this permits testing the module's
views independently of any larger context. If the views are integrated
correctly, the larger GUI needs less exercise to be completely tested.

General-purpose views can be considered for extraction to a separate
library, much like generic data-structure functions. Domain-specific
reusable views facilitate cohesive visual style and functionality for an
application.

@subsection{Challenges}

Naturally, constructing such a complex GUI is not without its challenges.
What do you do when you need access to the underlying object-oriented
API for a feature not exposed by existing wrappers? How do you handle a
piece of nearly-global state whose usage is hard to predict when writing
reusable components? Fortunately, both of these problems have solutions.

@(define mixins
   (~cite b:flavors b:denote-inheritance b:jigsaw b:mixins b:super+inner))

The first problem of access to imperative behaviors is solved by GUI
Easy conventions. In the traditional object-based toolkit, we would
subclass widgets as needed to create new behaviors. We cannot subclass a
class we cannot access. In response, all GUI Easy views support a
mixin@|mixins|, a function from class to class. This provides special
access to the class implementing the underlying widget so that we may
override or augment methods of the class as we choose by dynamically
subclassing GUI widgets. This access is crucially achieved without
modifying the source of the class body. When mixins are insufficient, we
choose to write our own @racket[view<%>] implementation, which wraps any
GUI widget(s) we desire. This includes core classes, custom subclasses,
and third-party widgets. The Frosthaven Manager uses mixins and custom
@racket[view<%>]s to implement custom close behavior and to display
rendered Markdown@|markdown| files.

The second problem of global state is handled by functional programming
techniques. Essentially, we have two choices: threading state or dynamic
binding. If we are confident that the state will be required in all
reusable views, we can thread the state as input from one view to the
next, like threading a needle through all parts of the program. Threaded
state is the solution preferred by DDAU and reusuable views. Threading
rarely-used state quickly becomes tedious and, when we are not so
confident, tangles unnecessary concerns. In response, we can use dynamic
binding, which breaks some functional purity for convenience and allows
us to refer to external state. Using dynamic binding makes views less
reusable: they now have dependencies not defined by their inputs.
Dynamic binding permits each view to only be concerned with the global
state if absolutely necessary. The Frosthaven Manager threads state as
much as possible but does use dynamic binding in rare instances.

@; very temporary placement (in terms of headings and such)
@subsection[#:tag "view_impl"]{@racket[view<%>]: Functional Shell, Imperative Core}

The functional architecture popularized by
@cite-author[b:functional-core]'s ``Functional Core, Imperative Shell''
video@~cite[b:functional-core] involves wrapping a core of pure
functional code with a shell of imperative commands, whose benefits
we've already discussed. In a twist on the classic paradigm, the core of
GUI Easy views is an imperative object lifecycle, while its shell is
functional.

The lifecycle is embodied by the @racket[view<%>] interface. Instances
must know how to @italic{create} GUI widgets, how to @italic{update}
them in response to changed data dependencies, and how to
@italic{destroy} them if necessary@~cite[b:gui-easy]. They must also
propagate data dependencies up the object tree to a coordinator object.
Data dependencies are any known observable values; the coordinator
object signals updates when dependencies change, allowing the
@racket[view<%>] to trigger an update in the wrapped widget. Crucially,
@racket[view<%>] instances must be reusable, so they must carefully
associate any internal state they need with each rendered widget.

The @racket[view<%>] interface is shown in @figure-ref{view-iface.rkt}.
The interface reifies the GUI widget lifecycle into a concrete object,
making explicit the separation between a GUI widget, its creation, and
its reaction to changes in data dependencies.

@figure["view-iface.rkt"
        "The view<%> interface."
        @racketblock[
(define container/c (is-a?/c area-container<%>))
(define widget/c (is-a?/c area<%>))

(define view<%>
  (interface ()
    [dependencies (->m (listof obs?))]
    [create (->m container/c widget/c)]
    [update (->m widget/c obs? any/c void?)]
    [destroy (-> widget/c void?)]))]]

@figure["view-impl.rkt"
        "An implementation of a custom view<%>."
        @racketblock[
(define text%
  (class* object% (view<%>)
    (init-field |@|label) (super-new)
    (define/public (dependencies) (list |@|label))
    (define/public (create parent)
      (new gui:message% [parent parent]
           [label (obs-peek |@|label)]))
    (define/public (update widget what val)
      (send widget set-label val))
    (define/public (destroy widget) (void))))

(define (text |@|label)
  (new text% [|@|label |@|label]))
]]

To go from a @racket[view<%>] to a functional view, all that remains is
to wrap object construction in a function. Thus, the shell is
functional. @Figure-ref{view-impl.rkt} shows an implementation of a
custom @racket[view<%>] and its function wrapper.

@section[#:tag "related_work"]{Related Work}

@(define frtime
   @~cite[b:frtime-in-plt-scheme b:frtime-dataflow b:frtime-thesis])

GUI Easy draws a lot of inspiration from Swift UI@|swift-ui|, another
system that wraps an imperative GUI framework in a functional shell.
Other sources of inspiration include Clojure's Reagent@reagent and
JavaScript's React@|react|. In Racket, FrTime@frtime implements a
functional reactive programming language for GUIs and other tasks.
FrTime extends the spirit of the original functional reactive
paradigm@~cite[b:fran b:frp-cont] based on time flow and signals. Vue@vue,
React, and inspired libraries, including GUI Easy, have evolved slightly
different notions of reactive programming; namely, programs react to
changes in state rather than in response to time-varying signals. The
Elm@|elm| programming language strictly constrains component composition
to the data down, actions up style. Clojure's re-frame@re-frame library
builds on Reagent@reagent to add more sophisticated state management.
This includes a global store and effect handler, akin to GUI Easy's
observable update procedures, and queries, akin to GUI Easy's derived
observables. Rust's infamous ``Are We GUI Yet?''@areweguiyet website
mentions at least four GUI libraries for functional reactive programming
in the style of React or FrTime.

While we must be careful not to confuse popularity with usefulness, our
satisfaction programming in the style suggested by GUI Easy and the use
of similar patterns across a variety of programming languages and
ecosystems suggests that, for the functional programmer, reactive GUI
systems are architecturally well-suited all sizes of programs.

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

@acks{Ben is grateful to Savannah Knoble, Derrick Franklin, John Hines,
and Jake Hicks for playtesting the Frosthaven Manager throughout
development, and to Isaac Childres for bringing us the wonderful world
of Frosthaven.}

@(generate-bibliography #:sec-title "References")
