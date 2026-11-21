;;;; Yamamoto's §30 (docs/duel/DUEL_YAMA_CORE.md §30.2 西's garb charge, §30.4 北 a 10 s form; as built §30.6): written scripts driving P1
;;;; (P2 Kenpachi, sealed, standing), every number read from the combat log (the SP / hit lines, `WEST charge` with the reach and the distance
;;;; at each charged hit, MARK, AS4 spent, `form`):
;;;;   python3 tools/combo-trial.py tests/trials/yamamoto-sp30.lisp --log
;;;; One match carries every trial and the marks are his fighter's state: every trial clears them first (87445). :form :bankai = in the
;;;; Bankai from the start (awakened, no cinematic); no 北 form since §33. Cinematics are skipped here (the browser
;;;; script duel-yama-sp30.json plays 北's Kikon and reads the count paused through it).
;; 西 (§30.2): the charge by the SA in NSa's / NSb's gap, carried by the string, dropped at neutral
(:name "W1 西 NSa > SA > J2 > J3 (2.6 m): x1.4, J2 at 2.10 m" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.6 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1) (:quick 1)) :frames 160)
(:name "W1b the same from 3.0 m: J2 at 2.50 m" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 3.0 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1) (:quick 1)) :frames 160)
(:name "W2 西 NSa > NSb > SA > J2 > J3 (4.4 m): x1.7, J2 at 2.51 m" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 4.4 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1) (:quick 1) (:quick 1)) :frames 220)
(:name "W3 西 NSa > SA > J2 > AS2 (2.6 m): the AS charged" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.6 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t)) :frames 220)
(:name "W4 AS2a on its own at 2.1 m, no charge: whiffs (reach 1.6)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.1 :fs 300
 :p1-cmd (87445 87431) :script () :frames 60)
(:name "W5 J1 > J2 (1.4 m), no charge: J2's damage at x1.0" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300
 :p1-cmd (87445) :script ((:quick 1) (:quick 1)) :frames 100)
(:name "W6 NSa > SA (2.0 m), then neutral, J1 > J2: the charge dropped" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.0
 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1 :wait 70) (:quick 1)) :frames 220)
(:name "W7 西 NS a-b-c (4.4 m): NSc 153 at level 2 baked in" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 4.4 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
;; the third mark (§33: no 北 form): 東 西 held, J1-J3 > AS3 gives 南, the marks stay 7, he stays in the Bankai
(:name "N1 the third mark: 東 西 held, J1-J3 > AS3: marks 7, still the Bankai (no 北 form, §33)" :p1 :yamamoto :form :bankai :p2 :kenpachi
 :ptr 1 :dist 1.4 :fs 300 :p1-cmd (87445 87441 87442)
 :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 300)
;; AS4 天地灰尽 (§31): J4's AS, x (1 + 0.25 a mark) on its four segments 40 > 50 > 60 > 140, its Kikon 2 / 3 / 4 / 5 Konpaku by the marks;
;; his next neutral after it clears the marks (`AS4 spent`)
(:name "A1 Bankai J1-J4 > AS4 (1.4 m), no mark: x1.0, no pointer written" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300
 :p1-cmd (87445) :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)
                          (:quick 1 :modded t)) :frames 300)
(:name "A2 the same with 東 西 held: x1.5, then neutral clears them" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300
 :p1-cmd (87445 87441 87442) :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t)
                                      (:quick 1 :modded t) (:quick 1 :modded t)) :frames 300)
(:name "A3 Bankai J1-J4 > AS4a held, 東 西 held: the Kikon takes 4" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300
 :p1-cmd (87445 87441 87442) :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1) (:quick 60 :modded t :on :hit)) :frames 300)
(:name "A3b control: no mark: the Kikon takes 2" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300
 :p1-cmd (87445) :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1) (:quick 60 :modded t :on :hit)) :frames 300)
(:name "A4 three marks in the Bankai: J1-J4 > AS4 x1.75, then neutral clears them" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2
 :dist 1.4 :fs 300 :p1-cmd (87445 87441 87442 87443)
 :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)
          (:quick 1 :modded t)) :frames 300)
(:name "A5 three marks: AS4a held, the Kikon takes 5" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300
 :p1-cmd (87445 87441 87442 87443) :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1) (:quick 60 :modded t :on :hit)) :frames 300)
