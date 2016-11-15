#lang slideshow

(define (is-zero n)
  (= n 0))

(define (is-one n)
  (= n 1))

(define (square n)
  ; A semi-colon starts a line comment.
  ; The expression below is the function body.
  (rectangle n n))

(define (four p)
  (define two-p (hc-append p p))
  (vc-append two-p two-p))

(define (std-sq)
  (square 20))

(define (tile-row w)
  (if (is-one w)
      (std-sq)
      (let ([sq (std-sq)]
            [row (tile-row (- w 1))])
        (hc-append sq row))))

(define (tile w h)
  (if (is-one h)
      (tile-row w)
      (let ([row (tile-row w)]
             [board (tile w (- h 1))])
         (vc-append row board))))

(define (draw-board n)
  (tile n n))
