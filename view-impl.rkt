#lang racket/base

(require racket/class
         (prefix-in gui: racket/gui)
         racket/gui/easy)

(define text%
  (class* object% (view<%>)
    (init-field @label)
    (super-new)
    (define/public (dependencies)
      (list @label))
    (define/public (create parent)
      (new gui:message% [parent parent] [label (obs-peek @label)]))
    (define/public (update widget _what val)
      (send widget set-label val))
    (define/public (destroy widget)
      (void))))

(define (text @label)
  (new text% [@label @label]))

(module+ main
  (define @seconds
    (obs (current-seconds)))
  (define timer
    (new gui:timer%
         [notify-callback (λ () (obs-update! @seconds (λ (_) (current-seconds))))]
         [interval 1000]
         [just-once? #f]))
  (render
   (window
    (text (obs-map @seconds number->string)))))
