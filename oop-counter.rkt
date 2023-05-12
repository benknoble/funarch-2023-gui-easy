#lang racket/gui

(define f
  (new frame% [label "Counter"]))
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

(send f show #t)
