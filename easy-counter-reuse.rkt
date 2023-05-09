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

(render
 (window
  #:title "Counters"
  (counter @count-1 (λ (proc) (<~ @count-1 proc)))
  (counter @count-2 (λ (proc) (<~ @count-2 proc)))))
