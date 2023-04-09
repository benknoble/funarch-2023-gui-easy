#lang racket/gui

(define f
  (new frame% [label "Counter"]))
(define container
  (new horizontal-panel% [parent f]))
(define count 0)
(define (update-count f)
  (set! count (f count))
  (send count-label set-label (~a count)))
(define -button
  (new button% [parent container]
       [label "-"]
       [callback (λ (button event)
                   (update-count sub1))]))
(define count-label
  (new message% [parent container]
       [label (~a count)]
       [auto-resize #t]))
(define +button
  (new button% [parent container]
       [label "+"]
       [callback (λ (button event)
                   (update-count add1))]))

(send f show #t)
