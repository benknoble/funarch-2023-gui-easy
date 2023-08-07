#lang racket/gui/easy

(require frosthaven-manager/aoe-images
         (prefix-in pict: pict))

(define @input (obs ""))

(render
 (window
  #:title "AoE Editor"
  (hpanel
   (input @input
          (λ (_action input)
            (:= @input input))
          #:style '(multiple)
          #:stretch '(#t #t)
          #:min-size '(300 150))
   (pict-canvas @input
                (λ (input)
                  (with-handlers ([exn:fail? (λ (_exn) (pict:text "Invalid Input"))])
                    (spec->shape (string->spec input))))
                #:min-size '(300 150)))))

;; ---

(require (prefix-in gui: racket/gui)
         racket/class)

(define f (new gui:frame% [label "AoE Editor"]))
(define h (new gui:horizontal-panel% [parent f]))
(define editor-input "")
(define (set-input! x)
  (set! editor-input x)
  (send c refresh))
(define _i (new gui:text-field% [parent h]
               [label #f]
               [callback (λ (tf _ce)
                           (set-input! (send tf get-value)))]
               [style '(multiple)]
               [min-width 300]
               [min-height 150]))
(define c (new gui:canvas% [parent h]
               [paint-callback
                (λ (_c dc)
                  (define p
                   (with-handlers ([exn:fail? (λ (_exn) (pict:text "Invalid Input"))])
                     (spec->shape (string->spec editor-input))))
                  (pict:draw-pict p dc 0 0))]
               [min-width 300]
               [min-height 150]))
(send f show #t)
