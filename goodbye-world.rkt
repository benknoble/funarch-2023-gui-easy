#lang racket/gui/easy
(require racket/class)
(define close! #f)
(render
 (window
  #:title "Goodbye World"
  #:mixin (λ (window%)
            (class window% (super-new)
              (set! close!
                (λ ()
                  (when (send this can-close?)
                    (send this on-close)
                    (send this show #f))))))
  (button "Click Me!" (λ () (close!)))))
