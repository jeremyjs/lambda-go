#lang web-server/insta
(require web-server/templates)
(require web-server/configuration/responders)
(require web-server/http/request-structs)
(require "board.rkt")
;(require "board-html.rkt")

(struct players (white black))
(struct game (id players board))

(define (is-empty-string? str)
  (not (non-empty-string? str)))

(define (is-joinable g)
  (ormap is-empty-string? '((white-player g)
                            (black-player g))))

(define (white-player g)
  (players-white (game-players g)))

(define (black-player g)
  (players-black (game-players g)))

(define GAMES
  (list (game "1" (players "jeremy" "connor") (new-board))))

(define (game-with-id id)
  (findf (lambda (g) (string=? id (game-id g)))))

; render-as-itemized-list: (listof xexpr) -> xexpr
; Consumes a list of items, and produces a rendering
; as an unordered list.
(define (render-as-itemized-list fragments)
  `(ul ,@(map render-as-item fragments)))
 
; render-as-item: xexpr -> xexpr
; Consumes an xexpr, and produces a rendering
; as a list item.
(define (render-as-item a-fragment)
  `(li ,a-fragment))

(define (start request)
  (show-index))

(define (show-index req)
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   empty
   (list (string->bytes/utf-8 (include-template "../public/index.html")))))

(define (show-all-games req)
  (show-games req "all"))

(define (show-games req filter)
  (response/xexpr
   `(html (head (title "Lambda Go"))
          (body (h1 "Welcome to Lambda Go!")
                (ul ((class "games-filter-nav")) (li ((class "all")) (a ((href "/games")) "All Games"))
                                                   (li ((class "open")) (a ((href "/games/open")) "Open Games"))
                                                   (li ((class "watchable")) (a ((href "/games/watchable")) "Watchable Games")))
                (table (thead (td "Game #")
                              (td "White")
                              (td "Black")
                              (td "")
                              (td ""))
                       (tbody ((class "games-list")) ,@(map game-list-item GAMES)))
                (script ((src "//code.jquery.com/jquery-3.1.1.min.js")))
                (script ((src "/js/games.js")))))))
  ;(include-template "templates/games.html"))

(define (join-btn g)
  (if (is-joinable g)
      `(button ((class "join") (data-id ,(game-id g))) "Join")
      ""))

(define (watch-btn g)
  `(button ((class "watch") (data-id ,(game-id g))) "Watch"))

(define (game-list-item g)
  `(tr ((class "game-list-item"))
       (td ,(game-id g))
       (td ,(white-player g))
       (td ,(black-player g))
       (td ,(join-btn g))
       (td ,(watch-btn g))))

(define (show-404 req)
  (response/full
   200 #"Okay"
   (current-seconds) TEXT/HTML-MIME-TYPE
   empty
   (list (string->bytes/utf-8 (include-template "../public/404.html")))))

(define public-root "/Users/jeremy/code/lambda-go/public")

(define (serve-js req filename)
 (file-response 200
                #"OK"
               (string-append public-root "/js/" filename)
               (header #"Content-Type" #"application/javascript")))

(define (serve-img req filename)
 (print (string-append (string-append public-root "/img/") filename))
 (file-response 200
                #"OK"
               (string-append (string-append public-root "/img/") filename)
               (header #"Content-Type" #"image/png")))

(define (show-game req id)
  `(img (src "/img/board.png"))) ; (game-with-id id)))

(define-values (my-dispatch my-url)
    (dispatch-rules
     [("") show-index]
     [("games") show-all-games]
     [("games" (string-arg)) show-games]
     [("games" (integer-arg)) show-game]
     [("js" (string-arg)) serve-js]
     [("img" (string-arg)) serve-img]))

(serve/dispatch my-dispatch)

(static-files-path "public")

;  (response/xexpr
;   `(html ,(make-cdata #f #f (include-template "index.html")))))
