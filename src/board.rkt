#lang racket
(provide board)
(provide board-points)
(provide add-point)
(provide print-board)
(provide new-board)

(struct board (points))

(define (add-point b p)
  (board (cons p (board-points b))))

(define (print-board b)
  (for-each print (board-points b))
  (newline))

(define (new-board)
  (board empty))

;(print-board b)
;
;(set! b (add-point b '(3 4)))
;
;(print-board b)
;
;(set! b (add-point b '(15 4)))
;
;(print-board b)
