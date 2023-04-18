#lang racket/base

(require racket/gui
         racket/gui/easy)

(define widget-container/c (is-a?/c area-container<%>))
(define widget/c (is-a?/c area<%>))

(define view<%>
  (interface ()
    [dependencies (->m (listof obs?))]
    [create (->m widget-container/c widget/c)]
    [update (->m widget/c obs? any/c void?)]
    [destroy (-> widget/c void?)]))