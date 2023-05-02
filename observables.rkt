#lang racket/base

(require racket/gui/easy)

(define o (obs 1))
(define ((make-observer name) v)
  (printf "observer ~a saw ~a~n" name v))
(obs-observe! o (make-observer "a"))
(obs-observe! o (make-observer "b"))
(obs-update! o add1)
