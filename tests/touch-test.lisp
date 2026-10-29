;;;; touch-test.lisp — checks the one-thumb gesture recogniser (engine/lisp/touch.lisp) on the host:
;;;; the main rows of docs/duel/DUEL_MOBILE_DESIGN.md §3.2 as remapped on 2026-09-28 (§15: a tap in the pad's low half =
;;;; Q / J, in its high half = F / K, the split line itself low; up-flick = a forward Step, the dash; rest then up = Hoho;
;;;; the six J / K string routes by taps; drag and drag far, back to rest), CANCELED (never a tap, idempotent), the
;;;; focus-loss clear, the latest-contact rule, chips (held until lift, the hold chip) and the pulse latch.
;;;;   $ECL_HOST --norc --load tests/touch-test.lisp
(dolist (f '("package" "math" "input" "touch"))
  (load (merge-pathnames (format nil "../engine/lisp/~a.lisp" f) *load-truename*)))
(defpackage :touch-test (:use :cl :engine))
(in-package :touch-test)

(defvar *fails* 0)
(defvar *checks* 0)
(defmacro check (form)
  `(progn (incf *checks*) (unless ,form (incf *fails*) (format t "FAIL: ~s~%" ',form))))

(defun new ()
  "A recogniser at DPR 1: pad 16..276 x 600..794, chips O (220 548 r36) and AWAKEN (120 548, hold 300 ms)."
  (touch-layout! (make-touch) 1 '(16 600 276 794) '((220 548 36) (120 548 26)) '(0 300)))

(defun feed (tr now &rest events)
  "Feed EVENTS ((type slot x y ms) ...; type 0 down 1 motion 2 up 3 canceled 4 cancel-all), then the clock at NOW."
  (let ((q (engine::touch-q tr)))
    (loop for e in events for i from 0
          do (loop for v in e for j from 0 do (setf (aref q (+ (* 5 i) j)) (float v 1f0))))
    (setf (engine::touch-now tr) (float now 1f0))
    (touch-feed! tr (length events))
    tr))

(defun take (tr) (touch-take! tr) tr)
(defun pulse (tr bit) (touch-pulse-p (take tr) bit))
(defmacro fresh ((tr) &body body) `(let ((,tr (new))) ,@body))

;;; TAP: a short lift inside the slop = one Quick pulse, live for exactly one read
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(1 0 104 702 30) '(2 0 104 702 90))
  (check (pulse tr engine::+tp-tap+))
  (check (not (pulse tr engine::+tp-tap+)))                 ; the next read: released
  (check (touch-tapped-p tr)))                              ; also a menu tap
;;; pulse latch: a frame with no fixed step keeps the pulse pending
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(2 0 100 700 50))
  (feed tr 33)                                               ; a frame, no read
  (check (pulse tr engine::+tp-tap+)))
;;; a long press is no tap; REST: still for tap-ms = guard, and the lift does nothing
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0))
  (check (not (touch-resting-p tr)))
  (feed tr 125)
  (check (touch-resting-p tr))
  (feed tr 140 '(2 0 100 700 140))
  (check (and (not (touch-resting-p tr)) (zerop (engine::touch-pend tr)))))
;;; PRESS-TAP (the game's, inside his own move): a contact still for PRESS-MS is its tap, the lift gives none; a flick
;;; before it is no tap; a lift before it is the usual tap
(fresh (tr)
  (setf (touch-press-tap tr) t)
  (feed tr 16 '(0 0 100 700 0))
  (check (not (pulse tr engine::+tp-tap+)))
  (feed tr 45)
  (check (pulse tr engine::+tp-tap+))
  (check (touch-active-p tr))                               ; still down: the hold
  (feed tr 300 '(2 0 100 700 300))
  (check (zerop (engine::touch-pend tr))))
(fresh (tr)
  (setf (touch-press-tap tr) t)
  (feed tr 16 '(0 0 100 640 0) '(1 0 100 612 10) '(1 0 100 590 25))   ; high zone, flicked up at once
  (take tr)
  (check (not (logtest (engine::touch-live tr) (logior engine::+tp-tap+ engine::+tp-tap-hi+))))
  (feed tr 60)
  (check (not (pulse tr engine::+tp-tap-hi+))))
(fresh (tr)
  (setf (touch-press-tap tr) t)
  (feed tr 16 '(0 0 100 640 0) '(2 0 100 640 20))
  (check (pulse tr engine::+tp-tap-hi+)))
;;; FLICK (down / side): fires at the crossing, Step + the stroke's direction, before any lift
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 712 10) '(1 0 100 732 30))
  (take tr)
  (check (touch-pulse-p tr engine::+tp-flick+))
  (check (and (touch-flick-down-p tr) (< (touch-sy tr) -0.99) (< (abs (touch-sx tr)) 0.01)))
  (check (touch-step-held-p tr)))                           ; held until the thumb stops or comes back
(fresh (tr)                                                 ; a slow stroke is a drag, not a flick
  (feed tr 16 '(0 0 100 700 0) '(1 0 112 700 20) '(1 0 125 700 200) '(1 0 140 700 260))
  (check (not (pulse tr engine::+tp-flick+)))
  (check (and (> (touch-sx tr) 0.8) (not (touch-step-held-p tr)))))
;;; TAP ZONES (the user's decision 2026-09-28): the pad (y 600..794 here) splits at its middle, y 697: a tap above
;;; is F (+TP-TAP-HI+, K), from the line down Q (+TP-TAP+, J); where the thumb went down decides
(fresh (tr)
  (check (= 697 (touch-split-y tr)))
  (feed tr 16 '(0 0 100 650 0) '(2 0 100 650 50))
  (let ((l (engine::touch-live (take tr))))
    (check (and (logtest l engine::+tp-tap-hi+) (not (logtest l engine::+tp-tap+)))))
  (feed tr 116 '(0 0 100 760 100) '(2 0 100 760 150))
  (let ((l (engine::touch-live (take tr))))
    (check (and (logtest l engine::+tp-tap+) (not (logtest l engine::+tp-tap-hi+)))))
  (feed tr 216 '(0 0 100 696.5 200) '(2 0 100 696.5 250))   ; just above the line: high
  (check (pulse tr engine::+tp-tap-hi+))
  (feed tr 316 '(0 0 100 697 300) '(2 0 100 697 350))       ; on the line: low
  (check (pulse tr engine::+tp-tap+))
  (feed tr 416 '(0 0 100 601 400) '(2 0 100 601 450))       ; the pad's top and bottom edges
  (check (pulse tr engine::+tp-tap-hi+))
  (feed tr 516 '(0 0 100 794 500) '(2 0 100 794 550))
  (check (pulse tr engine::+tp-tap+))
  (feed tr 616 '(0 0 100 692 600) '(1 0 106 700 620) '(2 0 106 700 650))   ; wandered across the line in the slop: high
  (check (pulse tr engine::+tp-tap-hi+)))
(let ((tr (make-touch :cfg (make-gesture-config :tap-split 0.25f0))))   ; the knob moves the line
  (touch-layout! tr 1 '(16 600 276 794) nil)
  (feed tr 16 '(0 0 100 660 0) '(2 0 100 660 50))
  (check (pulse tr engine::+tp-tap+)))
;;; the SLANTED line (TOUCH-SPLIT!, the battle screens' deck, the user 2026-10-28, DUEL_WEBUI §6 v2-v3): over the rect
;;; 0..390 x 532..844 it runs from 20 % of the height at the left edge (y 594.4) to 82 % at the right edge (y 787.84); the
;;; left hand mirrors it (82 % left, 20 % right); outside the rect the line keeps its edge's height
(let ((tr (new)))
  (touch-split! tr 0 532 390 844 0.2 0.82)
  (check (touch-hi-at-p tr 1f0 590f0))                      ; the far (left) edge: just above 594.4 is SP ...
  (check (not (touch-hi-at-p tr 1f0 600f0)))                ; ... just below it ATK
  (check (touch-hi-at-p tr 389f0 780f0))                    ; the thumb's (right) edge: high up to 787.8
  (check (not (touch-hi-at-p tr 389f0 795f0)))
  (check (touch-hi-at-p tr 195f0 690f0))                    ; the middle: 691.1
  (check (not (touch-hi-at-p tr 195f0 692f0)))
  (check (and (touch-hi-at-p tr -50f0 590f0) (not (touch-hi-at-p tr 500f0 795f0))))   ; beyond the rect: the edges' heights
  (check (touch-hi-at-p tr 100f0 400f0))                    ; above the rect (the pad reaches higher): SP
  (feed tr 16 '(0 0 250 710 0) '(2 0 250 710 50))           ; a tap below the level line (697) but above the slant (718.4)
  (check (pulse tr engine::+tp-tap-hi+))
  (feed tr 116 '(0 0 40 640 100) '(2 0 40 640 150))         ; a tap above the level line but under the slant's far end
  (check (pulse tr engine::+tp-tap+))
  (touch-split! tr 0 532 390 844 0.82 0.2)                  ; the left hand
  (check (and (touch-hi-at-p tr 1f0 780f0) (not (touch-hi-at-p tr 389f0 600f0))))
  (touch-split! tr 0 0 0 0 0 0)                             ; none: the pad's level line again
  (check (and (touch-hi-at-p tr 100f0 696f0) (not (touch-hi-at-p tr 100f0 697f0)))))
;;; a HOLD CHIP's early lift (爆 / 覺 merged, DUEL_WEBUI §6 v4): let go before its hold, a TOUCH-CHIP-TAP-P pulse for exactly
;;; one read (never down); held past it, down and no pulse on the lift; a cancel is no tap; a chip without a hold never pulses;
;;; TOUCH-CHIP-HOLD! changes the hold of the next press only
(fresh (tr)                                                 ; chip 1: AWAKEN at (120 548), 300 ms
  (feed tr 16 '(0 0 120 548 0) '(2 0 120 548 120))
  (check (not (touch-chip-down-p tr 1)))
  (take tr)
  (check (touch-chip-tap-p tr 1))
  (take tr)
  (check (not (touch-chip-tap-p tr 1)))                     ; the next read: gone
  (feed tr 400 '(0 1 120 548 200))
  (feed tr 520)
  (check (touch-chip-down-p tr 1))                          ; held 320 ms: down
  (feed tr 540 '(2 1 120 548 530))
  (check (not (touch-chip-tap-p (take tr) 1)))              ; its lift is no tap
  (feed tr 600 '(0 2 120 548 560) '(3 2 120 548 600))
  (check (not (touch-chip-tap-p (take tr) 1)))              ; a cancel neither
  (feed tr 700 '(0 3 220 548 650) '(2 3 220 548 680))       ; chip 0 has no hold
  (check (not (touch-chip-tap-p (take tr) 0)))
  (feed tr 720 '(0 4 120 548 710))                          ; a press under way keeps its hold ...
  (touch-chip-hold! tr 1 0f0)
  (feed tr 760)
  (check (not (touch-chip-down-p tr 1)))
  (feed tr 780 '(2 4 120 548 770))
  (check (touch-chip-tap-p (take tr) 1))                    ; (let go at 60 ms of its 300: a tap)
  (touch-chip-hold! tr 1 0f0)                               ; ... the next press: down at once
  (feed tr 800 '(0 5 120 548 790))
  (check (touch-chip-down-p tr 1))
  (feed tr 820 '(2 5 120 548 810))
  (check (not (touch-chip-tap-p (take tr) 1))))
;;; the six J / K string routes (DUEL_STRINGS §2.1) by taps alone: one pulse per tap, one per vpad read, in order
(dolist (route '("JJJ" "JJK" "JKK" "KKK" "KKJ" "KJJ"))
  (fresh (tr)
    (let ((got (loop for c across route for i from 0 for ms = (* 200 i) for y = (if (char= c #\K) 640 750)
                     do (feed tr (+ ms 60) (list 0 0 120 y ms) (list 2 0 120 y (+ ms 50)))
                     collect (let ((l (engine::touch-live (take tr))))
                               (cond ((= l engine::+tp-tap+) #\J) ((= l engine::+tp-tap-hi+) #\K) (t #\?))))))
      (check (string= route (coerce got 'string))))))
;;; FLICK UP = the forward dash (the user's decision 2026-09-28): a Step at the crossing, straight ahead, no lift
;;; needed; never an attack
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 688 10) '(1 0 100 668 30))
  (let ((l (engine::touch-live (take tr))))
    (check (and (logtest l engine::+tp-flick+) (not (logtest l (logior engine::+tp-tap+ engine::+tp-tap-hi+))))))
  (check (and (> (touch-sy tr) 0.99) (zerop (touch-sx tr)) (touch-step-held-p tr) (not (touch-flick-down-p tr))))
  (feed tr 90 '(2 0 100 668 80))                            ; the lift adds nothing
  (check (and (zerop (engine::touch-live (take tr))) (not (touch-step-held-p tr)))))
;;; a long neutral up-stroke: nothing moves while undecided (the 2026-09-27 playtest), the dash fires at the crossing,
;;; and a thumb that keeps going past the run ring keeps Step held: the hop, then the run
(fresh (tr)
  (feed tr 16 '(0 0 100 780 0) '(1 0 100 768 8) '(1 0 99 758 16))   ; left the slop: undecided, no stick
  (check (and (zerop (touch-sy tr)) (not (touch-step-held-p tr))))
  (feed tr 33 '(1 0 98 750 20) '(1 0 94 700 32) '(1 0 92 670 40) '(1 0 90 640 48))   ; 140 px: past the run ring
  (check (pulse tr engine::+tp-flick+))
  (check (and (touch-step-held-p tr) (> (touch-sy tr) 0.9)))
  (feed tr 150 '(2 0 90 640 140))
  (check (and (not (touch-step-held-p tr)) (zerop (engine::touch-live (take tr))))))
(fresh (tr)                                                 ; a right thumb's slanted up-flick (50 deg): straight ahead
  (feed tr 16 '(0 0 200 750 0) '(1 0 190 742 8) '(1 0 175 732 16) '(1 0 170 725 24) '(2 0 170 725 60))
  (check (and (pulse tr engine::+tp-flick+) (zerop (touch-sx tr)) (> (touch-sy tr) 0.5))))
(fresh (tr)                                                 ; past the up cone: a side flick keeps its direction
  (feed tr 16 '(0 0 200 750 0) '(1 0 188 746 8) '(1 0 170 740 16))
  (check (and (pulse tr engine::+tp-flick+) (< (touch-sx tr) -0.9))))
(fresh (tr)                                                 ; a slow drag up still walks, once the window closes
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 694 40) '(1 0 100 688 80))
  (check (zerop (touch-sy tr)))                             ; undecided (a flick could still come)
  (feed tr 250 '(1 0 100 682 120) '(1 0 100 676 160) '(1 0 100 668 240))
  (check (and (> (touch-sy tr) 0.6) (not (touch-step-held-p tr)) (not (pulse tr engine::+tp-flick+))))
  (feed tr 300)                                             ; the window also closes on the clock, no motion needed
  (check (> (touch-sy tr) 0.6)))
(fresh (tr)                                                 ; the clock alone ends the undecided phase
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 686 10))
  (feed tr 200)
  (check (> (touch-sy tr) 0.2)))
;;; HOHO: rest, then an up-stroke fires at the crossing when the game allows it (neutral / guard) ...
(fresh (tr)
  (setf (engine::touch-rest-up-ok tr) t)
  (feed tr 16 '(0 0 100 700 0))
  (feed tr 150)
  (feed tr 166 '(1 0 100 688 155) '(1 0 100 668 165))
  (check (pulse tr engine::+tp-hoho+)))
;;; ... and the dash otherwise (e.g. mid-move); a fresh up-flick is the dash even when Hoho is allowed
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0))
  (feed tr 150)
  (feed tr 166 '(1 0 100 688 155) '(1 0 100 668 165) '(2 0 100 668 180))
  (let ((l (engine::touch-live (take tr))))
    (check (and (logtest l engine::+tp-flick+) (not (logtest l engine::+tp-hoho+))))))
(fresh (tr)
  (setf (engine::touch-rest-up-ok tr) t)
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 688 10) '(1 0 100 668 30))
  (let ((l (engine::touch-live (take tr))))
    (check (and (logtest l engine::+tp-flick+) (not (logtest l engine::+tp-hoho+))))))
;;; ... any up-flick is a Hoho, no rest, while the game says so (attacking: UP-HOHO)
(fresh (tr)
  (setf (engine::touch-up-hoho tr) t)
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 688 10) '(1 0 100 668 30))
  (let ((l (engine::touch-live (take tr))))
    (check (and (logtest l engine::+tp-hoho+) (not (logtest l engine::+tp-flick+))))))
;;; a flick the game spent (a burst): nothing more from the contact, however far it runs on
(fresh (tr)
  (feed tr 16 '(0 0 100 600 0) '(1 0 100 612 10) '(1 0 100 632 30))
  (take tr)
  (check (touch-pulse-p tr engine::+tp-flick+))
  (engine::touch-spend! tr)
  (check (and (not (touch-pulse-p tr engine::+tp-flick+)) (zerop (touch-sy tr))))
  (feed tr 200 '(1 0 100 700 60) '(1 0 100 760 90) '(1 0 100 800 120))
  (check (and (not (pulse tr engine::+tp-flick+)) (not (touch-step-held-p tr)) (zerop (touch-sy tr)))))
;;; DRAG far: Step held beyond the run ring, released back inside 1.3 r; back to rest
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(1 0 110 700 40) '(1 0 125 700 200) '(1 0 140 700 330) '(1 0 190 700 360))
  (check (and (touch-step-held-p tr) (not (pulse tr engine::+tp-flick+))))
  (feed tr 380 '(1 0 150 700 370))
  (check (not (touch-step-held-p tr)))
  (feed tr 400 '(1 0 103 700 390))
  (feed tr 520)
  (check (touch-resting-p tr)))
;;; CANCELED: never a tap; a second cancel (or one for an unknown finger) is harmless
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(3 0 100 700 40) '(3 0 100 700 41) '(3 5 0 0 42))
  (check (and (not (pulse tr engine::+tp-tap+)) (not (touch-tapped-p tr)) (= -1 (engine::touch-gid tr)))))
;;; focus lost: everything released (a resting guard, a held chip)
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(0 1 220 548 0))
  (feed tr 200)
  (check (and (touch-resting-p tr) (touch-chip-down-p tr 0)))
  (feed tr 216 '(4 -1 0 0 210))
  (check (and (not (touch-resting-p tr)) (not (touch-chip-down-p tr 0)))))
;;; the latest contact in the pad wins; the old one's lift is ignored
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(0 1 200 700 5) '(2 0 100 700 40))
  (check (not (pulse tr engine::+tp-tap+)))
  (feed tr 60 '(2 1 200 700 60))
  (check (pulse tr engine::+tp-tap+)))
;;; chips: down on touch, held while the finger slides off, released on lift; the hold chip needs 300 ms
(fresh (tr)
  (feed tr 16 '(0 0 220 548 0) '(1 0 300 450 10))
  (check (and (touch-chip-down-p tr 0) (touch-chip-hit-p tr 0) (= -1 (engine::touch-gid tr))))
  (feed tr 40 '(2 0 300 450 30))
  (check (not (touch-chip-down-p tr 0)))
  (feed tr 60 '(0 2 120 548 50))
  (check (not (touch-chip-down-p tr 1)))
  (feed tr 360)
  (check (touch-chip-down-p tr 1)))
;;; chips inside the pad (the 2026-09-27 deck: the pad spans the whole thumb area, chips win their hit circles):
;;; a touch just inside a chip's hit circle holds the chip (never a tap); one just outside starts a gesture, whose
;;; up-flick crossing the chip is still the dash (a chip only claims touch-downs)
(let ((tr (touch-layout! (make-touch) 1 '(16 364 358 794) '((318 564 26)))))  ; L at the right edge, hit r 34
  (feed tr 16 '(0 0 318 597 0))                                                 ; 33 px below its centre
  (check (and (touch-chip-down-p tr 0) (= -1 (engine::touch-gid tr))))
  (feed tr 40 '(2 0 318 597 30))
  (check (zerop (engine::touch-live (take tr))))
  (feed tr 60 '(0 1 318 600 50) '(1 1 318 588 58) '(1 1 318 568 66) '(1 1 318 540 74) '(2 1 318 540 100))
  (let ((l (engine::touch-live (take tr))))
    (check (and (logtest l engine::+tp-flick+) (zerop (touch-sx tr)) (not (touch-chip-down-p tr 0)))))
  (feed tr 200 '(0 2 280 564 190) '(1 2 268 564 198) '(1 2 250 564 206))       ; beside it: a sidestep flick
  (check (and (pulse tr engine::+tp-flick+) (touch-step-held-p tr))))
;;; a touch outside the pad and the chips starts no gesture (still a menu tap)
(fresh (tr)
  (feed tr 16 '(0 0 50 100 0) '(2 0 50 100 40))
  (check (and (not (pulse tr engine::+tp-tap+)) (touch-tapped-p tr))))

;;; a flick's direction outlives its pulse while the game may still buffer its press (FLICK-READS reads, the vpad's buffer): a
;;; second up-flick inside the first Step started that Step later, from a neutral stick, so it hopped back (the user, 2026-10-29:
;;; 「連續 DASH 的話會先前跳再後跳」)
(fresh (tr)
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 688 10) '(1 0 100 668 30) '(2 0 100 668 40))   ; an up-flick, lifted at once
  (take tr)
  (check (and (touch-pulse-p tr engine::+tp-flick+) (> (touch-sy tr) 0.99)))
  (loop repeat 9 do (take tr))                                ; nine reads later the pulse is long gone ...
  (check (and (not (touch-pulse-p tr engine::+tp-flick+)) (> (touch-sy tr) 0.99) (zerop (touch-sx tr))))   ; ... the direction is not
  (take tr)                                                   ; the tenth read after: the buffer is over, a neutral stick
  (check (and (zerop (touch-sy tr)) (zerop (touch-sx tr)))))
(fresh (tr)                                                   ; a side flick keeps its side the same way
  (feed tr 16 '(0 0 100 700 0) '(1 0 88 700 10) '(1 0 66 700 30) '(2 0 66 700 40))
  (take tr) (take tr)
  (check (and (< (touch-sx tr) -0.9) (zerop (touch-sy tr)))))
(fresh (tr)                                                   ; a drag after it reads the drag, not the old flick
  (feed tr 16 '(0 0 100 700 0) '(1 0 100 688 10) '(1 0 100 668 30) '(2 0 100 668 40))
  (take tr)
  (feed tr 600 '(0 0 100 700 400) '(1 0 110 700 440) '(1 0 125 700 580) '(1 0 140 700 590))
  (take tr)
  (check (and (> (touch-sx tr) 0.5) (< (abs (touch-sy tr)) 0.01))))
(fresh (tr)                                                   ; a flick the game spent (a burst) leaves no direction behind
  (feed tr 16 '(0 0 100 600 0) '(1 0 100 612 10) '(1 0 100 632 30) '(2 0 100 632 40))
  (take tr) (engine::touch-spend! tr) (take tr)
  (check (zerop (touch-sy tr))))

(format t "~&touch-test: ~d checks, ~d failures~%" *checks* *fails*)
(ext:quit (if (zerop *fails*) 0 1))
