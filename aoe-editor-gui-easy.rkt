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
