#lang racket

(require racket/gui/easy
         racket/gui/easy/operator)

(define (counter @count action)
  (hpanel
   (button "-" (λ () (action sub1)))
   (text (~> @count ~a))
   (button "+" (λ () (action add1)))))

(define/obs @count-1 0)
(define/obs @count-2 5)

(define ((update-counter @counter) proc)
  (<~ @counter proc))

(render
 (window
  #:title "Counters"
  (counter @count-1 (update-counter @count-1))
  (counter @count-2 (update-counter @count-2))))
