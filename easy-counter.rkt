#lang racket/gui/easy

(define @count (@ 0))
(render
 (window
  #:title "Counter"
  (hpanel
   (button "-" (λ () (<~ @count sub1)))
   (text (~> @count number->string))
   (button "+" (λ () (<~ @count add1))))))
