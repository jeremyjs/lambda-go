#lang web-server/insta
(require web-server/templates)
(require web-server/configuration/responders)
(require web-server/http/request-structs)
(require "board.rkt")
(require "board-pict.rkt")
;(require "board-html.rkt")

(struct players (white black))
(struct game (id players board))

(define (is-empty-string? str)
  (not (non-empty-string? str)))

(define (sorted-by-id l)
  (sort l #:key game-id string<?))

(define (is-joinable? g)
  (ormap is-empty-string? (list (white-player g)
                                (black-player g))))

(define (is-not-joinable? g)
  (not (is-joinable? g)))

(define (white-player g)
  (players-white (game-players g)))

(define (black-player g)
  (players-black (game-players g)))

(define GAMES
  (list (game "1" (players "alice" "bob") (new-board))
        (game "2" (players "" "connor") (new-board))
        (game "3" (players "" "danny") (new-board))))

(define (filtered-by glst fltr)
  (case fltr
    [("" "all") glst]
    [("open") (filter is-joinable? glst)]
    [("in-progress") (filter is-not-joinable? glst)]))
  
(define (game-with-id gid)
  (findf (lambda (g) (string=? gid (game-id g))) GAMES))

(define (set-game-board gid b)
  (set! GAMES (append (remove (game-with-id gid) GAMES)
                      (list (game gid (game-players (game-with-id gid)) b)))))

(define (set-game-players gid pl)
  (set! GAMES (append (remove (game-with-id gid) GAMES)
                      (list (game gid pl (game-board (game-with-id gid)))))))

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

(define (show-games req fltr)
  (response/xexpr
   `(html (head (title "Lambda Go"))
          (body (div ((id "data") (data-uid "jeremy")))
                (h1 "Welcome to Lambda Go!")
                (ul ((class "games-filter-nav"))
                    (li ((class "all")) (a ((href "/games")) "All Games"))
                    (li ((class "open")) (a ((href "/games/open")) "Open Games"))
                    (li ((class "watchable")) (a ((href "/games/in-progress")) "In Progress Games")))
                (table (thead (td "Game #")
                              (td "White")
                              (td "Black")
                              (td "")
                              (td ""))
                       (tbody ((class "games-list")) ,@(map game-list-item (sorted-by-id (filtered-by GAMES fltr)))))
                (script ((src "//code.jquery.com/jquery-3.1.1.min.js")))
                (script ((src "/js/uri.js")))
                (script ((src "/js/games.js")))))))
  ;(include-template "templates/games.html"))

(define (join-btn g)
  (if (is-joinable? g)
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
 (file-response 200
                #"OK"
               (string-append public-root "/img/" filename)
               (header #"Content-Type" #"image/png")))

(define (show-game g)
  (response/xexpr
   `(html (a ((href "/games")) "Back to Games")
          (div ((id "data") (data-gid ,(game-id g))))
          (h1 ,(string-append "Game " (game-id g)))
          (p ,(string-append "White: " (white-player g)))
          (p ,(string-append "Black: " (black-player g)))
          (img ((class "game-board") (src ,(string-append "/img/board-" (game-id g) ".png"))))
          (script ((src "//code.jquery.com/jquery-3.1.1.min.js")))
          (script ((src "/js/game.js"))))))

(define (show-game-with-id gid)
  (show-game (game-with-id gid)))

(define (play-move gid p)
  (set-game-board gid (add-point (game-board (game-with-id gid)) p)))

(define (join-game-with-id gid uid)
  (define g (game-with-id gid))
  (define wp (if (string=? (white-player g) "")
                 uid
                 (white-player g)))
  (define bp (if (string=? (black-player g) "")
                 uid
                 (black-player g)))
  (print wp)
  (print bp)
  (set-game-players gid (players wp bp))
  (redirect-to (string-append "/games/" gid "/watch")))

(define (game-action req id action)
  (case action
    [("watch") (show-game-with-id id)]))

; (point-from-params "1-1") => '(1 1)
(define (point-from-params params)
  (map string->number (string-split params "-")))

(define (game-action-params req gid action params)
  (case action
    [("play") (play-move gid (point-from-params params))]
    [("join") (join-game-with-id gid params)]))

(define-values (my-dispatch my-url)
    (dispatch-rules
     [("") show-index]
     [("games") show-all-games]
     [("games" (string-arg)) show-games]
     [("games" (string-arg) (string-arg)) game-action]
     [("games" (string-arg) (string-arg) (string-arg)) game-action-params]
     [("js" (string-arg)) serve-js]
     [("img" (string-arg)) serve-img]))

(serve/dispatch my-dispatch)

(static-files-path "public")

;  (response/xexpr
;   `(html ,(make-cdata #f #f (include-template "index.html")))))
