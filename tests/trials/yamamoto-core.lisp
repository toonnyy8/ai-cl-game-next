;;;; Yamamoto's core kit, batch 1 stage A (docs/duel/DUEL_YAMA_CORE.md "As built (batch 1 A)"): every route by a written script, both
;;;; sides' inputs (P1 the script, P2 :p2-at / :p2-press), read from the combat log:
;;;;   python3 tools/combo-trial.py tests/trials/yamamoto-core.lisp        (or tools/simgate/trial.lisp directly, after simlib's build)
;;;; P1 Yamamoto's Shikai vs Kenpachi (sealed, standing). J = :quick, SP = (:quick 1 :modded t), the Kikon hold = (:quick 60 :modded t).
;;;; P1's flash-step 300 unless :fs says.
(:name "Y1 NS1 a-b-c" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
(:name "Y2 NS2 a-b-c (the ring, then the dome on it)" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 5.0 :fs 300
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
(:name "Y3 NS3 a-b-c" :p1 :yamamoto :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
(:name "Y4 J1 AS1" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 1.6 :fs 100
 :script ((:quick 1) (:quick 1 :modded t :on :hit)) :frames 150)
(:name "Y5 J1 J2 AS2 (2 seg)" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 1.6 :fs 300
 :script ((:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t)) :frames 200)
(:name "Y6 J1-J3 AS3 (3 seg)" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 1.6 :fs 300
 :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 240)
(:name "Y7 NS3a SA (TAIMATSU in the gap)" :p1 :yamamoto :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300
 :script ((:quick 1 :modded t) (:quick 1)) :frames 150)
(:name "Y8 NS1a wave x P2 J1 (a cancel: refund)" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300
 :script ((:quick 1 :modded t)) :p2-at ((26 :j)) :frames 120)
(:name "Y9a NS1b alone (87411): the column x P2 J1 at simf 16 (a cancel: refund)" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300
 :p1-cmd (87411) :script () :p2-at ((16 :j)) :frames 90)
(:name "Y9b NS1b alone (87411): the column x P2 J1 at simf 20" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300
 :p1-cmd (87411) :script () :p2-at ((20 :j)) :frames 90)
(:name "Y9c NS2c alone (87415): the dome at his bearing, no ring" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 5.0 :fs 300
 :p1-cmd (87415) :script () :frames 90)
(:name "Y10 NS3a Kikon hold" :p1 :yamamoto :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300
 :script ((:quick 60 :modded t)) :frames 200)
(:name "Y11 NS1a wave Kikon hold (the strike flash-steps in)" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300
 :script ((:quick 80 :modded t)) :frames 220)
(:name "Y12 NS2 a-b twice (one ring at a time)" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 5.0 :fs 300
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t :on :free) (:quick 1 :modded t)) :frames 320)
(:name "Y13 NS2 a-b, P2 steps back out of the ring (it burns)" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 5.0 :fs 300
 :script ((:quick 1 :modded t) (:quick 1 :modded t)) :p2-press ((75 :step 1 nil -1.0)) :frames 160)
;;; §30.1 (2026-11-21): pointer 2 close. NS2a the melee flame slash (2.4 m): a hit at 2.2 m, a whiff at 3.0 m; NS2b's ring at the victim's
;;; bearing clamped to 3 m (the `ring at ... m from him` line) with the victim at 6 m (87414: NS2b on its own); the route from 2.2 m.
(:name "Y14a NS2a at 2.2 m: the slash hits" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 2.2 :fs 300
 :script ((:quick 1 :modded t)) :frames 80)
(:name "Y14b NS2a at 3.0 m: the slash whiffs" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 3.0 :fs 300
 :script ((:quick 1 :modded t)) :frames 80)
(:name "Y14c NS2b alone (87414), the victim at 6 m: the ring lands 3 m from him" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 6.0 :fs 300
 :p1-cmd (87414) :script () :frames 60)
(:name "Y14d NS2 a-b-c from 2.2 m (the slash, the ring round him, the dome on it)" :p1 :yamamoto :p2 :kenpachi :ptr 2 :dist 2.2 :fs 300
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
