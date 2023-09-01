#lang at-exp slideshow

(require slideshow/text
         slideshow/code
         slideshow/step
         slideshow/play
         racket/runtime-path
         file/glob
         racket/draw
         racket/class
         pict/face
         syntax/parse/define
         qi)

(define-syntax-parse-rule (screen-only e:expr)
  (let ([v e])
    (cond
      [printing? (ghost v)]
      [else v])))

(define (screen-clickback p t)
  (screen-only (clickback p t)))

(define-runtime-path here ".")

(define arrow-size 10)

(define (color-code col p)
  (define q (inset p 2))
  (define h (pict-height q))
  (define w (pict-width q))
  (~> (w h 5) filled-rounded-rectangle
      (colorize col) (cc-superimpose p) (refocus p)))

(define-syntax interact-gui-easy
  (syntax-parser
   [(_ {~optional {~seq #:alt alt:expr}}
       e:expr ... t:expr)
    #`(interactive
       {~? alt (blank)}
       (λ (f)
         #,(syntax-local-introduce #'(local-require racket/gui/easy
                                                    racket/gui/easy/operator))
         e ...
         (embed f t)
         void))]))

(define (strikethrough p)
  (define line
    (~> (p) (-< pict-width pict-height) hline))
  (cc-superimpose p line))

(define column
  (ghost
   (rectangle (/ (pict-width titleless-page) 2)
              (pict-height titleless-page))))

(define 1/3column
  (ghost
   (rectangle (/ (pict-width titleless-page) 3)
              (pict-height titleless-page))))

(define 2/3column (hc-append 1/3column 1/3column))

(define editor-widget-text
  @text{Editor})
(define editor-widget
  (frame (inset editor-widget-text 20)))

(define input-view
  (frame (inset @small{@t{input%}} 20)))

(define pic-widget-text
  (let ([label (inset @text{Picture} 20)])
    (color-code "lightcoral" label)))
(define pic-widget
  (frame (inset pic-widget-text 20)))

(define pic-view
  (frame (inset (inset @small{@t{pict-canvas%}} 20)
                20)))

(define editor-and-pic-widget
  (hc-append editor-widget pic-widget))

(define hpanel-view
  (frame (lt-superimpose
          (inset (hc-append input-view pic-view) 25)
          (translate @small{@t{hpanel%}} 20 0))))

(define example-window-widget
  (frame
   (vc-append
    (let* ([height (pict-height @text{AoE Editor})]
           [buttons (hc-append 3
                               (disk (- height 5) #:color "red" #:draw-border? #f)
                               (disk (- height 5) #:color "yellow" #:draw-border? #f)
                               (disk (- height 5) #:color "green" #:draw-border? #f))])
      (lc-superimpose (cc-superimpose (filled-rectangle (pict-width editor-and-pic-widget)
                                                        height
                                                        #:color "light gray")
                                      @text{AoE Editor})
                      (inset buttons 2)))
    editor-and-pic-widget)))

(define example-window-view
  (frame (lt-superimpose
          (inset hpanel-view 25)
          (translate @small{@t{window%}} 20 0))))

(slide
 #:title "Functional Shell and Reusable Components for Easy GUIs"
 (~> (titleless-page)
     (ct-superimpose @small{@t{and some Frosthaven}})
     (cc-superimpose @t{D. Ben Knoble & Bogdan Popa})))

(define typ-solution
  @t{Typical Solution: object-based toolkit})
(define our-solution
  @t{Our Solution: Views and Observables!})

(let ([sad (~> ((face 'unhappy)) (scale-to-fit typ-solution))]
      [happy (~> ((face 'happy)) (scale-to-fit our-solution))])
  (slide
   #:title "Problem: Let's make a small GUI tool"
   'next
   'alts
   (list
    (list @small{@t{(with Racket)}})
    (list (hc-append 5 (ghost sad) typ-solution (ghost sad)))
    (list
     @t{Working with the object-based toolkit:}
     'alts
     (list (list @item[#:bullet (colorize @tt{x} "red")]{Code not organized like GUI})
           (list @item[#:bullet (colorize @tt{x} "red")]{Application state and GUI state manually synchronized})
           (list @item[#:bullet (colorize @tt{x} "red")]{Composition, reuse, abstraction thwarted by construction})
           (list @item[#:bullet (colorize @tt{x} "red")]{Daunting: requires expertise in the widget library})
           (list @it{Experts and beginners alike struggle})))
    (list (hc-append 5 sad typ-solution sad))
    (list
     @t{Working with GUI Easy:}
     'alts
     (list (list @item[#:bullet (colorize @tt{✓} "green")]{GUI containers programatically contain GUI children}
                 (strikethrough @item[#:bullet (colorize @tt{x} "red")]{Code not organized like the GUI}))
           (list @item[#:bullet (colorize @tt{✓} "green")]{Views update automatically when observables change}
                 (strikethrough @item[#:bullet (colorize @tt{x} "red")]{Application state and GUI state manually synchronized}))
           (list @item[#:bullet (colorize @tt{✓} "green")]{GUIs are composable functions}
                 (strikethrough @item[#:bullet (colorize @tt{x} "red")]{Composition and reuse thwarted by construction}))
           (list @item[#:bullet (colorize @tt{✓} "green")]{Small flexible core}
                 @item[#:bullet (colorize @tt{✓} "green")]{Easy to extend}
                 (strikethrough @item[#:bullet (colorize @tt{x} "red")]{Daunting: requires expertise in the widget library}))
           (list @it{Easier to learn}
                 @it{Gateway to object-oriented toolkit})))
    (list (hc-append 5 happy our-solution happy)))))

(slide
 #:title "Example: Area of Effect Diagram Editor"
 @t{Goal}
 (scale example-window-widget 2))

;; runnable example code here

(void
 (with-steps
  {code main-func state-sync boilerplate all}
  (define-syntax-parse-rule (only-on-after on:id af:id then:expr else:expr)
    (if (or (only? on) (only? af) (after? af))
      then
      else))
  (define (color-main x) (only-on-after main-func all (color-code "aquamarine" x) x))
  (define (color-state x) (only-on-after state-sync all (color-code "gold" x) x))
  (define (color-boilerplate x) (only-on-after boilerplate all (color-code "lightcoral" x) x))
  (define-syntax icky-new (make-code-transformer (λ (stx)
                                                   (if (identifier? stx)
                                                     #'(color-boilerplate (code new))
                                                     #f))))
  (define legend
    (~> ((vl-append
          3
          @tt{Legend}
          (blank)
          (color-code "aquamarine" @tt{Functionality})
          (color-code "gold" @tt{Input Synchronization})
          (color-code "lightcoral" @tt{Boilerplate})))
        (inset 10) frame
        (scale-to-fit (rectangle (/ client-w 5) (/ client-h 5)))))
  (slide
   #:title "Example: Area of Effect Diagram Editor"
   (~> ((code
         (#,(color-boilerplate (code define f)) (icky-new #,(color-boilerplate (code gui:frame%)) #,(color-main (code [label "AoE Editor"]))))
         #,(color-boilerplate (code (define h (icky-new gui:horizontal-panel% [parent f]))))
         #,(color-main (code (define editor-input "")))
         #,(color-state
            (code
             (define (set-input! x)
               (set! editor-input x)
               (send c refresh))))
         (#,(color-boilerplate (code define i)) (icky-new #,(color-boilerplate (code gui:text-field% [parent h]))
                                                          [label #f]
                                                          [callback #,(color-state
                                                                       (code (λ (tf ce)
                                                                               (set-input! (send tf get-value)))))]
                                                          #,(color-main (code [style '(multiple)]))
                                                          [min-width 300]
                                                          [min-height 150]))
         (#,(color-boilerplate (code define c)) (icky-new #,(color-boilerplate (code gui:canvas%)) #,(color-boilerplate (code [parent h]))
                                                          [paint-callback
                                                           #,(color-main
                                                              (code (λ (c dc)
                                                                      (define p
                                                                        (with-handlers ([exn:fail? (λ (exn) (pict:text "Invalid Input"))])
                                                                          (spec->shape (string->spec editor-input))))
                                                                      (pict:draw-pict p dc 0 0))))]
                                                          [min-width 300]
                                                          [min-height 150]))
         #,(color-boilerplate (code (send f show #t)))))
       (scale-to-fit titleless-page)
       (cc-superimpose titleless-page)
       (rb-superimpose legend)))))

;; image of running code
(define editor-frames
  (sort (glob (build-path here "aoe-editor-frame-*.png"))
        path<?))
(define (make-editor-frame-slide f)
  (~> (f) bitmap
      (scale-to-fit titleless-page)
      (cc-superimpose titleless-page)
      (rb-superimpose (screen-clickback (frame (t "Run OOP Code")) run-oop))))
(define n-editor-frames (length editor-frames))
(define (run-oop)
  (dynamic-require (build-path here "aoe-editor-oop.rkt") #f))

(cond
  [printing? (for ([f editor-frames])
               (slide
                #:title "AoE Editor In Action"
                (make-editor-frame-slide f)))]
  [else (play-n
         (λ (timestamp)
           (define frame-file
             (on (timestamp)
               (if (>= 1.0)
                 (gen (last editor-frames))
                 (~>> (* n-editor-frames) exact-floor (list-ref editor-frames)))))
           (make-editor-frame-slide frame-file))
         #:title "AoE Editor In Action"
         #:delay 0.3)])

(slide #:name "On to the GUI Easy Version"
       @titlet{On to the GUI Easy Version})

;; on to GUI Easy version…
(void
 (with-steps
  {render window hpanel input pict-canvas run}
  (define-syntax-parse-rule (reveal id:id then:expr)
    (let ([then* (code then)])
      (before id (ghost then*) (only id (color-code "aquamarine" then*) then*))))
  (define (run-easy)
    (dynamic-require (build-path here "aoe-editor-gui-easy.rkt") #f))
  (slide
   #:title "Easy Example: Area of Effect Diagram Editor"
   (~> ((code
         #,(reveal input (define |@|input (obs "")))
         #,(reveal
            render
            (render
             #,(reveal
                window
                (window
                 #:title "AoE Editor"
                 #,(reveal
                    hpanel
                    (hpanel
                     #,(reveal
                        input
                        (input |@|input
                               (λ (action input)
                                 (:= |@|input input))
                               #:style '(multiple)
                               #:stretch '(#t #t)
                               #:min-size '(300 150)))
                     #,(reveal
                        pict-canvas
                        (pict-canvas |@|input
                                     (λ (input)
                                       (with-handlers ([exn:fail? (λ (exn) (pict:text "Invalid Input"))])
                                         (spec->shape (string->spec input))))
                                     #:min-size '(300 150)))))))))))
       (scale-to-fit titleless-page)
       (cc-superimpose titleless-page)
       (rb-superimpose ((vonly run) (screen-clickback (frame (t "Run Code")) run-easy)))))))

(slide
 #:title "Easy Example: Area of Effect Diagram Editor"
 (interact-gui-easy
  #:alt titleless-page
  (local-require (prefix-in pict: pict)
                 frosthaven-manager/aoe-images)
  (define |@|input (obs ""))
  (hpanel
   (input |@|input
          (λ (_action input)
            (:= |@|input input))
          #:style '(multiple)
          #:stretch '(#t #t)
          #:min-size '(300 150))
   (pict-canvas |@|input
                (λ (input)
                  (with-handlers ([exn:fail? (λ (_exn) (pict:text "Invalid Input"))])
                    (spec->shape (string->spec input))))
                #:min-size '(300 150)))))

;; ---

(slide #:name "GUI Easy Details"
       @titlet{GUI Easy Details})

;; GUI Easy: the library
(slide
 #:title "GUI Easy Details"
 (ct-superimpose
  @t{Observables are Values}
  (hc-append
   (cc-superimpose column
                   (vr-append gap-size
                              @t{Observables}
                              @t{Set Observables}
                              @t{Update Observables}
                              @t{Map Observables}
                              @t{Peek Observables}
                              @t{Subscribe}))
   (cc-superimpose column
                   (vc-append gap-size
                              ;; ghosts for alignment
                              (code #,(ghost (code x<~)) (|@| _v) #,(ghost (code _fx)))
                              (code (:= (|@| _v) _e))
                              (code (<~ (|@| _v) _f))
                              (code (~> (|@| _v) _f))
                              (code (obs-peek (|@| _v)) #,(ghost (code xxxxxxx)))
                              (code obs-subscribe!))))))

(slide
 #:title "GUI Easy Details"
 (~> (titleless-page)
     (ct-superimpose @t{Views are Functions})
     (cc-superimpose (code (-> ... view<%>)))))

(slide
 #:title "GUI Easy Details"
 (~> (titleless-page)
     (ct-superimpose @para[#:align 'center]{Views are @it{Observable-aware} Functions})
     (cc-superimpose
      (vl-append
       gap-size
       (code (-> _dependencies view<%>))
       (code (pict-canvas _|@|data _draw-pict-from-data))))))

(slide
 #:title "GUI Easy Details"
 (~> (titleless-page)
     (ct-superimpose @para[#:align 'center]{Views are @it{Composable} Functions})
     (cc-superimpose
      (vl-append
       gap-size
       (code (-> _children view<%>))
       (code (hpanel _child1 _child2 _child3))))))

(slide
 #:title "GUI Easy Details"
 (hc-append
  (cc-superimpose 2/3column
                  (scale-to-fit (code
                                 (define |@|count (|@| 0))
                                 code:blank
                                 (render
                                  (window
                                   (hpanel
                                    (button "-" (λ () (<~ |@|count sub1)))
                                    (text (~> |@|count number->string))
                                    (button "+" (λ () (<~ |@|count add1)))))))
                                2/3column))
  (cc-superimpose 1/3column
                  (interact-gui-easy
                   #:alt (scale-to-fit (bitmap (build-path here "screenshot-counter.png"))
                                       1/3column)
                   (define |@|count (|@| 0))
                   (hpanel (button "-" (λ () (<~ |@|count sub1)))
                           (text (~> |@|count number->string))
                           (button "+" (λ () (<~ |@|count add1))))))))

(slide #:name "Abstraction"
       @titlet{Abstraction})

(slide
 #:title "Abstraction"
 (hc-append
  (cc-superimpose 2/3column
                  (scale-to-fit (code
                                 (define (counter |@|count action)
                                   (hpanel
                                    (button "-" (λ () (action sub1)))
                                    (text (~> |@|count number->string))
                                    (button "+" (λ () (action add1)))))
                                 code:blank
                                 (define |@|count1 (|@| 0))
                                 (define |@|count2 (|@| 0))
                                 code:blank
                                 (render
                                  (window
                                   (vpanel
                                    (counter |@|count1 (λ (proc) (<~ |@|count1 proc)))
                                    (counter |@|count2 (λ (proc) (<~ |@|count2 proc)))))))
                                2/3column))
  (cc-superimpose 1/3column
                  (interact-gui-easy
                   #:alt (scale-to-fit (bitmap (build-path here "screenshot-2counter.png"))
                                       1/3column)
                   (define (counter |@|count action)
                     (hpanel
                      (button "-" (λ () (action sub1)))
                      (text (~> |@|count number->string))
                      (button "+" (λ () (action add1)))))
                   (define |@|count1 (|@| 0))
                   (define |@|count2 (|@| 0))
                   (vpanel
                    (counter |@|count1 (λ (proc) (<~ |@|count1 proc)))
                    (counter |@|count2 (λ (proc) (<~ |@|count2 proc))))))))

;; GUI Easy: the architecture (via Frosthaven Manager)

(slide #:name "Model-View-Controller"
       @titlet{Model-View-Controller})

(void
 (with-steps
  {blank model view controller}
  (define-syntax-parse-rule (highlight id:id c:expr ...)
    (let ([c* (code c ...)])
      (if (only? id) (color-code "aquamarine" c*) c*)))
  (slide
   #:title "Model-View-Controller"
   (cond
     [(only? model) @t{Model}]
     [(only? view) @t{View}]
     [(only? controller) @t{Controller}]
     [else @t{ }])

   (scale-to-fit
    (code
     #,(highlight
        view
        (define (counter |@|count #,(highlight controller action))
          (hpanel
           (button "-" #,(highlight controller (λ () (action sub1))))
           (text (~> |@|count number->string))
           (button "+" #,(highlight controller (λ () (action add1)))))))
     code:blank
     #,(highlight
        model
        (define |@|count1 (|@| 0))
        (define |@|count2 (|@| 0)))
     code:blank
     (render
      #,(highlight
         view
         (window
          (vpanel
           (counter |@|count1 #,(highlight controller (λ (proc) (<~ |@|count1 proc))))
           (counter |@|count2 #,(highlight controller (λ (proc) (<~ |@|count2 proc)))))))))
    titleless-page))))

(slide
 #:title "Model-View-Controller"
 @para{Pass observable models from top of application down to child components})

(slide
 #:title "Model-View-Controller"
 @para{Controller callbacks specialize components to react to user input})

(slide
 #:title "Model-View-Controller"
 @it{Data Down, Actions Up (DDAU)}
 @it{Reusable Components ~ Pure Functions})

(slide
 #:title "Other Details (in the paper)"
 @item{Object lifecyle managed by @code[view<%>] and renderer objects}
 @subitem{Inversion of Control}
 @item{Black-box vs. White-box frameworks}
 @subitem{Escape hatches: custom @code[view<%>]s, @it{mixins}}
 @item{Related work: GUI toolkits, reactive web frameworks, FRP})

(slide
 #:title "Conclusion"
 @t{Functional Shell and Reusable Components for Easy GUIs}
 @item{GUIs with objects: hard}
 @item{GUIs with observables and functions: easier, FP}
 @item{Purity, composition, abstraction, reuse!}
 @item{What other imperative systems deserve the FP treatment?})

(slide
 #:title "Extras"
 (~> ("screenshot-frosthaven.png")
     (build-path here _)
     bitmap
     (scale-to-fit titleless-page)
     (cc-superimpose titleless-page)))

(slide
 #:title "Extras"
 (~> ("screenshot-frosthaven-with-server.png")
     (build-path here _)
     bitmap
     (scale-to-fit titleless-page)
     (cc-superimpose titleless-page)))

(slide
 #:title "Extras"
 'alts
 (let ([diagram (hc-append (cc-superimpose column (scale example-window-widget 1.5))
                           (cc-superimpose column example-window-view))])
   (define alts
     (~> (diagram)
         (-< (pin-arrows-line arrow-size _
                              example-window-view lt-find
                              example-window-widget rt-find)
             (pin-arrows-line arrow-size _
                              hpanel-view lt-find
                              editor-and-pic-widget rt-find)
             (pin-arrows-line arrow-size _
                              input-view lt-find
                              editor-widget-text rt-find)
             (pin-arrows-line arrow-size _
                              pic-view lt-find
                              pic-widget-text rt-find)) collect (map list _)))
   alts))

(slide
 #:title "Extras"
 @t{Create}
 (let* ([window% (frame (inset @code[window%] 5))]
        [hpanel% (frame (inset @code[hpanel%] 5))]
        [input% (frame (inset @code[input%] 5))]
        [pict-canvas% (frame (inset @code[pict-canvas%] 5))]
        [diag (vc-append gap-size
                        window%
                        hpanel%
                        (hc-append gap-size
                                   input%
                                   pict-canvas%))])
   (~> (diag)
       (pin-arrow-line arrow-size _
                       window% cb-find
                       hpanel% ct-find)
       (pin-arrow-line arrow-size _
                       hpanel% cb-find
                       input% ct-find)
       (pin-arrow-line arrow-size _
                       hpanel% cb-find
                       pict-canvas% ct-find))))

(slide
 #:title "Extras"
 (~> (example-window-view)
     (pin-arrow-line arrow-size _
                     input-view lt-find
                     example-window-view lt-find
                     #:label @small{@t{deps}}
                     #:x-adjust-label -60
                     #:y-adjust-label -20)
     (pin-arrow-line arrow-size _
                     example-window-view rt-find
                     pic-view rt-find
                     #:label @small{@t{updates}}
                     #:x-adjust-label +70
                     #:y-adjust-label -10)))
