#lang at-exp slideshow

(require slideshow/code
         slideshow/step
         slideshow/play
         racket/runtime-path
         file/glob
         racket/draw
         racket/class
         pict/face
         qi)

(define-runtime-path here ".")

(define (color-code col p)
  (define q (inset p 2))
  (define h (pict-height q))
  (define w (pict-width q))
  (~> (w h 5) filled-rounded-rectangle
      (colorize col) (cc-superimpose p) (refocus p)))

(slide
 #:title "Functional Shell and Reusable Components for Easy GUIs"
 @t{D. Ben Knoble & Bogdan Popa})

(define typ-solution
  @t{Typical Solution: object-based toolkit})
(define our-solution
  @t{Our Solution: Views and Observables!})

(let ([sad (~> ((face 'unhappy)) (scale-to-fit typ-solution))]
      [happy (~> ((face 'happy)) (scale-to-fit our-solution))])
  (slide
   #:title "Problem: Let's make a small GUI tool"
   'alts
   (list
    (list (hc-append 5 (ghost sad) typ-solution (ghost sad)))
    (list
     @t{Working with the object-based toolkit:}
     'alts
     (list (list @item[#:bullet (colorize @tt{x} "red")]{Code not organized like the GUI})
           (list @item[#:bullet (colorize @tt{x} "red")]{Application state and GUI state manually synchronized})
           (list @item[#:bullet (colorize @tt{x} "red")]{Composition and reuse thwarted by construction order})
           (list @item[#:bullet (colorize @tt{x} "red")]{Daunting: requires expertise in the widget library})
           (list @it{Experts and beginners alike struggle})))
    (list (hc-append 5 (ghost sad) typ-solution (ghost sad)))
    (list (hc-append 5 sad typ-solution sad))
    (list (hc-append 5 happy our-solution happy)))))

(slide
 #:title "Example: Area of Effect Diagram Editor"
 @t{Goal}
 (let ([editor (hc-append (frame (inset @text{Editor} 20))
                          (frame (inset (let ([label (inset @text{Picture} 20)])
                                          (color-code "lightcoral" label))
                                        20)))])
   (frame
    (vc-append
     (let* ([height (pict-height @text{AoE Editor})]
            [buttons (hc-append 3
                                (disk (- height 5) #:color "red" #:draw-border? #f)
                                (disk (- height 5) #:color "yellow" #:draw-border? #f)
                                (disk (- height 5) #:color "green" #:draw-border? #f))])
       (lc-superimpose (cc-superimpose (filled-rectangle (pict-width editor)
                                                         height
                                                         #:color "light gray")
                                       @text{AoE Editor})
                       (inset buttons 2)))
     editor))))

;; runnable example code here

(void
 (with-steps
  {code main-func state-sync boilerplate all}
  (define-syntax only-on-after
    (syntax-rules ()
      [(_ on af then else)
       (if (or (only? on) (only? af) (after? af))
         then
         else)]))
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
(define n-editor-frames (length editor-frames))
(define (run-oop)
  (dynamic-require (build-path here "aoe-editor-oop.rkt") #f))
(play-n
 (λ (timestamp)
   (define frame-file
     (on (timestamp)
       (if (>= 1.0)
         (gen (last editor-frames))
         (~>> (* n-editor-frames) exact-floor (list-ref editor-frames)))))
   (define bitmap
     (make-object bitmap% frame-file 'png))
   (define-values (w h)
     (values (send bitmap get-width) (send bitmap get-height)))
   (~> ((dc (λ (dc dx dy)
              (send dc draw-bitmap bitmap dx dy))
            w h))
       (scale-to-fit titleless-page)
       (cc-superimpose titleless-page)
       (rb-superimpose (clickback (frame (t "Run OOP Code")) run-oop))))
 #:title "AoE Editor In Action"
 #:delay 0.3)

;; on to GUI Easy version…
;; use `ghost` to to introduce each nested piece alongside the resulting GUI

;; ---

;; GUI Easy: the library
;; GUI Easy: the architecture (via Frosthaven Manager)
;; Research connections
