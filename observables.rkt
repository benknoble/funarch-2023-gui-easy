#lang racket/base

(require racket/gui/easy)

(define o (obs 1))
(define ((observer name) v)
  (printf "observer ~a saw ~a~n" name v))
(obs-observe! o (observer "a"))
(obs-observe! o (observer "b"))
(obs-update! o add1)
