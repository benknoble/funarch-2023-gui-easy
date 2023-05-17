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
rendering. Functional shells and observable toolkits like GUI Easy
simplify and promote the creation of reusable views by analogy to
functional programming. We have successfully used GUI Easy on small and
large GUI projects. We report on our experience constructing and using
GUI Easy and derive from that experience architectural patterns and
principles for building functional programs out of imperative systems.}

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
        racket/gui/easy
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

With GUI Easy, the code in @figure-ref{easy-counter.rkt} resolves
the previous shortcomings. As state, we define an observable
@racket[|@|count] whose initial value is the number @racket[0]. Then we
@racket[render] an interface composed of widgets like @racket[window],
@racket[hpanel], @racket[button], and @racket[text]. Widget properties,
such as size or label, may be constant values or observables. The
rendered widgets automatically update when their observable inputs
change @~cite[b:react b:swiftui]. In this example, pressing the buttons
causes the counter to be updated, which transparently updates the text
label.

In this report, we examine the difficulties of programming with
object-oriented GUI systems and motivate the search for a different
system in @secref{A_Tale_of_Two_Programmers}, describe the key GUI Easy
abstractions in @secref{GUI_Easy_Overview}, report on our experience
constructing large GUI programs in @secref{arch-frost}, explore two key
architectural lessons in @secref{Architectural_Lessons}, and explore
related trends in GUI programming in @secref{related_work}.

@section{A Tale of Two Programmers}
@; or "… Two Programs" ?

@; Origin stories in subsections for GUI Easy and Frosthaven, including
@; why Frosthaven chose GUI Easy. Ben thinks the clearest style will be
@; to write about ourselves in the 3rd person, so that the individual
@; stories are clear?

We present the origin stories for two projects. First, in
@secref{Quest_for_Easier_GUIs}, Bogdan describes his frustrations with
Racket's GUI system that drove him to create GUI Easy. Second, in
@secref{embarking}, Ben describes his desire to construct a large GUI
program without mutable state. The happy union of these two desires
taught us the architectural lessons we present in @secref{arch-frost}.

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
state, Bogdan had to bring his own state management to the
table, leading to ad hoc solutions for every new project. See
@racket[update-count] in @figure-ref{oop-counter.rkt} for an example of
ad hoc state management. This motivated the observable abstraction in
GUI Easy. In @secref{GUI_Easy_Overview}, we'll see how observables and
observable-aware views combine to automatically connect GUI widgets and
state changes.

Bogdan found it inconvenient that constructing most widgets requires a
reference to a parent widget. Consider the following piece of Racket
code:

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
construction, but that needlessly complicates wiring up interfaces.
This motivated Bogdan to come up with the view abstraction in GUI Easy.
In @secref{GUI_Easy_Overview}, we'll see how views permit functional
abstraction, enabling new organizational approaches that we'll explore
in @secref{arch-frost}.

@subsection[#:tag "embarking"]{Embarking for the Town of Frosthaven}

Ben enjoys boardgames with a group of friends, especially
Frosthaven@~cite[b:frosthaven], the sequel to Gloomhaven. Due to its
highly complex nature, Frosthaven includes lots of tokens, cards, and
other physical pieces that the players must manipulate to play the game.
This includes tracking monsters' health and conditions, the strength
of six magical elements that power special abilities, and more. The
original Gloomhaven game had a helper application for mobile devices to
reduce physical manipulation; at one point, it appeared Frosthaven would
not receive the same treatment.

Ben, a programmer, decided to solve the problem for his personal
gaming group by creating his own helper application. But how? Having
never created a complex GUI program, Ben was intimidated by classic
object-oriented systems like Racket's. To a programmer with intimate
knowledge of the class, method, and event relationships, such a system
may feel natural. To the novice, GUI Easy represents a simpler,
functional-oriented, path to interface programming.

GUI Easy makes it possible to build a complex system out of simple
parts: functions and data. Ben was familiar with functional programming
and grokked GUI Easy, so he started programming the Frosthaven
Manager@~cite[b:frosthaven-manager] with GUI Easy in 2022.

@section{GUI Easy Overview}

The functional programmer naturally represents data via immutable
data structures such as records, enumerations, and collections. They
write pure functions that transform immutable data into different
representations or representations with different values. In contrast,
object-oriented systems rely on mutable state and side-effecting class
methods, which usually clash with functional programming techniques.
Programming with GUI Easy permits the functional programmer to
retain functional programming techniques to a greater degree than
object-oriented systems do. In this section, we give a brief overview of
how GUI Easy achieves this.

GUI easy can be broadly split up into two parts: @italic{observables}
and @italic{views}.

Observables contain values and notify subscribed observers of changes to
their contents. @Figure-ref{observables.rkt} demonstrates the low-level
observable API. @Secref{Observable_Values} explains the observable
operators.

@figure["observables.rkt"
        "Using the low-level observable API in GUI Easy."
        @racketmod0[
        racket/gui/easy
        (define o (|@| 1))
        (obs-observe! o (λ (x) (printf "a got ~a\n" x)))
        (obs-observe! o (λ (x) (printf "b got ~a\n" x)))
        (code:comment "change the observable by adding 1")
        (<~ o add1)
        (code:comment "outputs:")
        (code:comment "a got 2")
        (code:comment "b got 2")]]

Views are representations of Racket GUI widget trees that, when
rendered, produce instances of those trees and handle the details of
transparently wiring state and view together. We discuss the view
abstraction in more detail in @Secref{view_detail}.

@figure["easy-counter-reuse.rkt"
        "Component re-use in GUI Easy."
        @racketmod0[
        racket/gui/easy
        (define (counter |@|count action)
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

The core of the observable abstraction is that arbitrary observers
can react to changes in the contents of an observable. Application
developers programming with GUI Easy use a few core operators to
construct and manipulate observables.

We create observables with @racket[|@|].

We can change the contents of an observable using @racket[<~]. This
procedure takes as arguments an observable and a procedure of one
argument, representing the current value, to generate a new value. Every
change is propagated to any observers registered at the time of the
update.

We can derive new observables from existing ones using @racket[~>].
This procedure takes an observable and a procedure of one argument, the
current value. A derived observable changes with the observable it's
derived from by applying its mapping procedure to the values of its
input observable. In @figure-ref["easy-counter-reuse.rkt"], the derived
observable @racket[(~> |@|count number->string)] changes every time
@racket[|@|count] is updated by @racket[<~]; its value is the result
of applying @racket[number->string] to the value of @racket[|@|count].
Derived observables may not be directly updated.

We can peek at an observable with @racket[obs-peek], which returns
the contents of the observable. This operation is useful to get
point-in-time values out of observables when displaying modal dialogs or
other views that require a snapshot of the state.

@subsection[#:tag "view_detail"]{Views as Functions}

Views are functions that return a @racket[view<%>] instance, whose
underlying details we'll cover in @secref{view_impl}. Views might
wrap a specific GUI widget, like a text message or button, or they
might construct a tree of smaller views, forming a larger component.
Both forms are synonymous with ``view'' in this paper. We've already
seen many examples of views like @racket[text], @racket[hpanel], and
@racket[counter].

Views are typically observable-aware in ways that make sense for each
individual view. For instance, the @racket[text] view takes as input an
observable string and the rendered text label updates with changes to
that observable. @Figure-ref{easy-counter-reuse.rkt} shows an example of
a reusable counter component made by composing views together.

Many Racket GUI widgets are already wrapped by GUI Easy, but programmers
can implement the @racket[view<%>] interface themselves in order to
integrate arbitrary widgets, such as those from 3rd-party packages in
the Racket ecosystem, into their projects.

@section[#:tag "arch-frost"]{The Architecture of Frosthaven}

In this section, we describe various pieces of a large GUI Easy
application, the Frosthaven Manager.

@; Describe the architecture of Frosthaven as it pertains to GUI Easy; derive
@; principles (core/shell, DDAU, centralized v. local state, re-usable
@; components/view organization …?). Also mention tradeoffs, problems
@; encountered, etc.

At time of writing, the Frosthaven Manager includes approximately 5000
lines of Racket code. About half of that code construct the main
application by combining GUI Easy views with domain-specific code. Of
the remaining lines, approximately 1000 implement the data structures
and transformations responsible for the state of the game; 500 cover the
images it draws; 750 implement three user-programmable data-definition
languages@url-note{https://benknoble.github.io/frosthaven-manager/Programming_a_Scenario.html};
300 test the project; the remaining lines are small syntactic utilities.
The Frosthaven Manager also has approximately 3000 lines of Scribble, a
Racket prose and documentation language, which includes a how-to-play
guide and developer reference.

The Frosthaven Manager manipulates many kinds of data. This includes
game characters and their various attributes, monsters and their
attributes, randomized loot, the status of elemental effects, and more.
To organize and manipulate this data, Ben chose a ``functional core,
imperative shell'' architecture@~cite[b:functional-core].

The choice of a functional core and imperative shell has many well-known
benefits. For example, core code is independent of the choice of UI
presentation and is independently testable or useable for other
applications. Functional cores also simplify programmer reasoning about
application data flow, keeping state change at the boundaries of the
system.

In constructing the Frosthaven Manager, Ben organized the main data into
immutable records, enumerations, and collections alongside pure
functions that transform data according to the rules of the game. We
thus say that the Frosthaven Manager uses a functional core.

Layered atop the functional core we find two more major components in
the Frosthaven Manager: GUI-specific data and domain-specific views
built on GUI Easy. In many ways, Ben took the functional approach here,
too. GUI-related data is organized along typical idioms and paired with
transformation functions. Despite these functional qualities, since most
of the relevant data is observable or intended to be observable, the
resulting system feels far more imperative. For example, pure
transformations from the functional layers are paired with observable
updates---akin to mutations---for real effect on the state of the GUI.
As a result, though many important and reusable views seem pure, they
are easily combined into a highly imperative system. These views and
updates form the Frosthaven Manager's imperative shell.

The Frosthaven Manager's main GUI comprises many smaller reusable views.
By analogy with functional programming's building
blocks---functions---small reusable views permit us to construct large
systems via composition. We'll discuss the design principles behind
reusable views in @secref{Reusable_Views}.

@section{Architectural Lessons}

In this section, we will cover the following two major lessons. First,
reusable components (@secref{Reusable_Views}) permit composition akin to
functional composition by constraining state manipulation. Second,
wrapping an imperative API with a functional shell (@secref{view_impl})
allows programmers to use functional techniques and architectures when
constructing imperative systems.

@subsection{Reusable Views}

@; TODO should we mention something from FH in here?

Our experience with GUI Easy led us to strive for reusable views. Much
like pure functions, a reusable view is composable and is subject to
constraints on state manipulation. All the views provided by GUI Easy
are reusable as described in this section.

There is one major design factor of reusable views. @emph{Views should
not directly manipulate external state.} This is analogous to the rule
for pure functions, and all the same arguments apply to show that
manipulating external state makes a view less reusable. Following this
design principle leads naturally to the principle ``data down, actions
up,'' or @emph{DDAU}. It also guides us to make decisions about which
state to centralize at the highest levels of the GUI and which state to
localize in reusable views.

DDAU prescribes how a function, like a reusable view, should manipulate
state. The ``data down'' prescription means that all necessary data, be
it state or not, must be inputs to a function or reusable view. For GUI
Easy, these inputs are observables. Recall the @racket[counter] view
from @figure-ref{easy-counter-reuse.rkt}: the data needed to display the
value of the counter was an input to the view called @racket[|@|count].
Similarly, the ``actions up'' prescription means that functions and
views should not directly manipulate state; rather, they should pass
actionable date back to their caller, which is better positioned to
decide how to manipulate state. In the @racket[counter] view and in GUI
Easy, actions are represented by callbacks. For the @racket[counter]
view, the @racket[action] callback is passed a procedure indicating
whether the minus or plus button was clicked; the caller of the
@racket[counter] view decides how to react to user manipulations of the
GUI.

Notice that it would be generally unsafe to mutate observable inputs, as
they could be derived observables. Requiring informally that a
particular view's observable inputs are not derived observables creates
a trap for programmers that want to reuse the view in novel contexts and
violates the principles of reusable views.

DDAU naturally bubbles application state up the layers of application
architecture, so that the top-level of an application contains all of
the necessary state. Callers pass the state down to various components
and provide procedures to respond to events and actions. This downward
flow of state continues until we reach the bottom-most layer. Sometimes,
however, we need state that is neither the caller's nor callee's
responsibility. In this case, a reusable view maintains local state
which it is free to mutate, say, in response to an action callback from
one of its components This is in keeping with the tradition of
optimizing functional programs by allowing interior---but
invisible---mutability.

The benefits of reusable views and reusable components are threefold.
Small reusable components are amenable to independent testing.
General-purpose components can be considered for extraction to a
separate library, much like generic data-structure functions.
Domain-specific components facilitate cohesion, such as visual style for
a GUI application. Thus we highly recommend reusable components across a
variety of functional architectures.

While reusable views are a GUI-specific idea, the notions of DDAU and
constrained state management are also a more general lesson for
functional programming: identifying patterns of state manipulation and
constraining such state manipulation is a useful way to contain state in
a smaller portion of code and to permit functional techniques in the
remainder.

@subsection[#:tag "view_impl"]{@racket[view<%>]: Functional Shell, Imperative Core}

The ``Functional Core, Imperative Shell'' architecture involves wrapping
a core of pure functional code with a shell of imperative commands,
whose benefits we've already discussed. In a twist on the classic
paradigm, the core of GUI Easy views is an imperative object lifecycle,
while its shell is functional. In this section, we'll describe that
shell in detail and explain how it permits retaining functional
programming techniques when dealing with imperative systems.

The GUI object lifecycle is embodied by the @racket[view<%>] interface.
Instances must know how to @italic{create} GUI widgets, how to
@italic{update} them in response to changed data dependencies, and how
to @italic{destroy} them if necessary@~cite[b:gui-easy]. They must also
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
        (list "The " @racket[view<%>] " interface.")
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
        (list "An implementation of a custom " @racket[view<%>] ".")
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
to wrap object construction in a function. Thus, the shell---the part
that most library consumers interact with---is functional.
@Figure-ref{view-impl.rkt} shows an implementation of a custom
@racket[view<%>] and its function wrapper.

How does such a shell permit the use of functional programming
techniques? We've already seen in the previous sections and in code
examples that this shell abstracts away all the imperative details from
most library consumers: until now, we haven't needed to understand
the imperative object-based API being wrapped in order to write GUI
programs. Further, those GUI programs have used functional programming
techniques, such as composition of reusable components. Even the
Frosthaven Manager sticks mostly to the functional shell and is thus
able to use the ``Functional Core, Imperative Shell'' architecture.

The key lesson for functional programmers here is that, when possible,
wrapping an imperative API in a functional shell enables all the
benefits of functional programming. For highly complex systems, like
GUIs, to rewrite the entire system in a functional style may be
impractical. Instead, it may be practical to reuse existing imperative
or object-based work by wrapping it in a functional shell.

@subsection{Challenges}

Naturally, maintaining reusable components and programming against a
functional shell is not without its challenges. What do you do when you
need access to the underlying object-oriented API for a feature not
exposed by existing wrappers? How do you handle a piece of nearly-global
state whose usage is hard to predict when writing reusable components?
Fortunately, both of these problems have solutions.

@(define mixins
   (~cite b:flavors b:denote-inheritance b:jigsaw b:mixins b:super+inner))

The first problem of access to imperative behaviors is solved by GUI
Easy conventions. In the traditional object-based toolkit, we would
subclass widgets as needed to create new behaviors. We cannot subclass a
class we cannot access, for it is ostensibly hidden by the wrapper. In
response, all GUI Easy views support a mixin@|mixins| argument, a
function from class to class. This provides special access to the class
implementing the underlying widget so that we may override or augment
methods of the class as we choose by dynamically subclassing GUI
widgets. This access is crucially achieved without modifying the source
of the class body. When mixins are insufficient, we choose to write our
own @racket[view<%>] implementation, which wraps any GUI widget(s) we
desire. This includes core classes, custom subclasses, and third-party
widgets. The Frosthaven Manager uses mixins and custom @racket[view<%>]s
to implement custom close behavior and to display rendered
Markdown@|markdown| files. Here is a lesson for functional shells:
provide hooks back to the original API, since piercing the abstraction
may be necessary.

The second problem of global state is handled by functional programming
techniques. Essentially, we have two choices: threading state or dynamic
binding. If we are confident that the state will be required in all
reusable views, we can thread the state as input from one view to the
next, like threading a needle through all parts of the program. Threaded
state is the solution preferred by DDAU and reusuable views. Threading
rarely-used state quickly becomes tedious and, when not needed
everywhere, tangles unnecessary concerns. In response, we can use
dynamic binding, which breaks some functional purity for convenience and
allows us to refer to external state. Using dynamic binding makes views
less reusable: they now have dependencies not defined by their inputs.
Dynamic binding permits each view to only be concerned with the global
state if absolutely necessary. The Frosthaven Manager threads state as
much as possible but does use dynamic binding in rare instances. It is
important to mention that using dynamic binding via Racket's parameters
is not straightforward when working with the GUI system due to the
multi-threaded environment and queued callbacks; to achieve
dynamic-binding for the Frosthaven Manager, Ben had to both bind
parameters in the GUI event threads and take care to spawn more event
threads when new bindings were needed. This complexity may not be worth
it in all applications.

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
imperative, object-based APIs. We also described a functional wrapper,
called GUI Easy, inspired by functional reactive programming for UI
systems. GUI Easy has successfully been used for small and large GUI
projects, such as the Frosthaven Manager discussed in this report. We
derived several architectural principles from the construction of both
projects: functional shells over imperative APIs enable functional
programming techniques via functional shell. Reusable components from
the shell, much like pure functions, should not mutate external state.
Like in functional programs, reusable components are independently
testable. Extensible hooks are necessary in functional shells to permit
access to the underlying abstraction.

@acks{Ben is grateful to Savannah Knoble, Derrick Franklin, John Hines,
and Jake Hicks for playtesting the Frosthaven Manager throughout
development, and to Isaac Childres for bringing us the wonderful world
of Frosthaven.}

@(generate-bibliography #:sec-title "References")
