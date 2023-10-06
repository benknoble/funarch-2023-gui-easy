#lang racket/gui/easy

(define (counter @count action)
  (hpanel
   (button "-" (λ () (action sub1)))
   (text (~> @count number->string))
   (button "+" (λ () (action add1)))))
(define @count1 (@ 0))
(define @count2 (@ 0))
(render
 (window
  #:title "Counter"
  (vpanel
   (counter @count1 (λ (proc) (<~ @count1 proc)))
   (counter @count2 (λ (proc) (<~ @count2 proc))))))
