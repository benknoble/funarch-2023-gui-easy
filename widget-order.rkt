#lang racket/gui
(define frame
  (new frame% [label "A window"]))
(define message
  (new message%
       [parent frame]
       [label "Hello World"]))
(send frame show #t)
