#lang slideshow
(require file/convertible)
(require dyoo-while-loop)
(require "board.rkt")

(define dotsize 6)
(define num-sq-board 18)
(define std-sq-size 20)
(define piecesize 16)

(define (is-zero n)
  (= n 0))

(define (is-one n)
  (= n 1))

;(define (first l)
;  (list-ref l 0))

(define (second l)
  (list-ref l 1))

(define (square n)
  ; A semi-colon starts a line comment.
  ; The expression below is the function body.
  (rectangle n n))

(define (filled-circle n)
  (filled-ellipse n n))

(define (four p)
  (define two-p (hc-append p p))
  (vc-append two-p two-p))

(define (std-sq)
  (square std-sq-size))

(define (tile-row w s)
  (if (is-one w)
      (square s)
      (let ([sq (square s)]
            [row (tile-row (- w 1) s)])
        (hc-append sq row))))

(define (tile w h s)
  (if (is-one h)
      (tile-row w s)
      (let ([row (tile-row w s)]
            [board (tile w (- h 1) s)])
        (vc-append row board))))

(define (tile-sq n s)
  (tile n n s))

(define (add-dot board-pict point)
  (pin-over board-pict
            (- (* (first point)
                  num-sq-board)
               (/ dotsize 2))
            (- (* (second point)
                  num-sq-board)
               (/ dotsize 2))
            (filled-circle dotsize)))

(define (new-board-pict)
  (add-dot
   (add-dot
    (add-dot
     (add-dot
      (add-dot
       (add-dot
        (add-dot
         (add-dot
          (add-dot
           (tile-sq num-sq-board num-sq-board)
           '(3 3))
          '(3 9))
         '(3 15))
        '(9 3))
       '(9 9))
      '(9 15))
     '(15 3))
    '(15 9))
   '(15 15)))

(define (get-x point)
       (first point))

(define (get-y point)
       (second point))

(define (add-piece bp point color)
  (let ([x (first point)]
        [y (second point)]
        [circ (lambda (size) (disk size #:color color))])
    (pin-over bp
              (- (* x num-sq-board)
                 (/ piecesize 2))
              (- (* y num-sq-board)
                 (/ piecesize 2))
              (circ piecesize))))

(define (print-board-pict b)
  (print (foldl add-piece
                new-board-pict
                (board-points b))))

(define (new-board)
  (board empty))

(define (start-game)
  (define b (new-board))
  (define bpict (new-board-pict))
  (define color "Black")
  (print bpict)
  (while #t
         (define input (read-line))
         (when (regexp-match #px"quit" input)
           (break))
         (define p (map string->number (string-split input)))
         (set! b (add-point b p))
         (set! bpict (add-piece bpict p color))
         (set! color (if (string=? color "Black") "White" "Black"))
         (print bpict)
         (print-board b)))

(start-game)

;(send (pict->bitmap (new-board-pict))
;      save-file
;      "../public/img/board.png"
;      'png)
