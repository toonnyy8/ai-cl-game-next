;;;; Yamamoto's Bankai, batch 1 stage C (docs/duel/DUEL_YAMA_CORE.md "As built (batch 1 C)"): written scripts driving both sides (P1 the
;;;; script, P2 :p2-at / :p2-press / :p2-start), every number read from the combat log (the AWAKEN / ZANKA / MARK / NORTH / SP / hit lines):
;;;;   python3 tools/combo-trial.py tests/trials/yamamoto-bankai.lisp --log
;;;; P1 Yamamoto vs Kenpachi (sealed, standing) unless :p2 says. :form :bankai = in the Bankai from the start (awakened, no cinematic).
;;;; One match carries every trial and the marks are his fighter's state: every Bankai trial sets them first (yama.lisp YAMA-DEBUG:
;;;; 87445 cleared, 87441-87443 a mark, 87444 北 armed, 87447 the switch line, 87420+i a Bankai segment started on its own).
(:name "C1 the awakening from the Shikai at heat 40: the Bankai, heat 0" :p1 :yamamoto :p2 :kenpachi :dist 4.0 :fs 300 :meter 40
 :awaken 1000 :script ((:awaken 1 :modded t)) :frames 60)
(:name "C2 the awakening in 爆炎 (heat 100): 爆炎 ends, the Bankai, heat 0" :p1 :yamamoto :form :blaze :p2 :kenpachi :dist 4.0 :fs 300
 :meter 100 :awaken 1000 :script ((:awaken 1 :modded t)) :frames 60)
(:name "C3 東 NS a-b-c" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 3.0 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
(:name "C4 西 NS a-b-c" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.6 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
(:name "C5 南 NS a-b-c" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 4.0 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 260)
(:name "C6 J1 > AS1: mark 東" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 1.4 :fs 300 :p1-cmd (87445)
 :script ((:quick 1) (:quick 1 :modded t :on :hit)) :frames 120)
(:name "C7 J1 J2 > AS2: mark 西" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 1.4 :fs 300 :p1-cmd (87445)
 :script ((:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t)) :frames 160)
(:name "C8 J1 J2 J3 > AS3: mark 南" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 1.4 :fs 300 :p1-cmd (87445)
 :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 240)
(:name "C9 a repeated mark stays one: 東 held, J1 > AS1 again" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300
 :p1-cmd (87445 87441) :script ((:quick 1) (:quick 1 :modded t :on :hit)) :frames 120)
(:name "C10 the third mark arms 北: 東 西 held, J1-J3 > AS3" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 1.4 :fs 300
 :p1-cmd (87445 87441 87442)
 :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 240)
;; (C11 / C12, 北 armed as a flag, left 2026-11-21: 北 is a form since DUEL_YAMA_CORE §30.4; its NS / AS rows are yamamoto-sp30.lisp N2-N4)
(:name "C13a the switch in 北 (87444: the form :north): refused" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 4.0 :fs 300
 :p1-cmd (87445 87444 87447) :script () :frames 2)
(:name "C13b control: the switch with no 北: open" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 4.0 :fs 300
 :p1-cmd (87445 87447) :script () :frames 2)
(:name "C14a 西 NSb's armour takes P2's J (NSa whiffs at 2.6 m, NSb steps in)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.6
 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t)) :p2-at ((27 :j)) :log-simf t :frames 120)
(:name "C14b control: the same J on NSa's startup (no armour): a cancel" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.6
 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t)) :p2-at ((3 :j)) :frames 80)
(:name "C15 西 NSb loses to an AS (P2's AS1 started under it)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.6 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t)) :p2-start ((27 :ke-z-as1)) :log-simf t :frames 120)
(:name "C16a 南 NSa's hands, P2 steps after S: dodged" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 5.0 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :p2-press ((24 :step 1)) :frames 90)
(:name "C16b control: no Step: the hands bind" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 5.0 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :frames 90)
(:name "C17 南 NSc's bone wall stops Ichigo's Getsuga" :p1 :yamamoto :form :bankai :p2 :ichigo :ptr 3 :dist 8.0 :fs 300 :p1-cmd (87445 87428)
 :script () :p2-start ((22 :ic-as2b)) :frames 120)
(:name "C18 AS 北 held after J1: the Kikon at pointer 3's profile (the Bankai's 3 - 1 = 2 Konpaku)" :p1 :yamamoto :form :bankai
 :p2 :kenpachi :ptr 2 :dist 1.4 :fs 300 :p1-cmd (87445 87444) :script ((:quick 1) (:quick 60 :modded t :on :hit)) :frames 200)
(:name "C18b control: AS2 held after J1 J2 under pointer 2 (no 北): pointer 2's profile, 3 Konpaku" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2
 :dist 1.4 :fs 300 :p1-cmd (87445) :script ((:quick 1) (:quick 1) (:quick 60 :modded t :on :hit)) :frames 200)
;;; §30.3 (2026-11-21): 南's skeleton tower. NSa raises it 2.5 m before him (the `tower level 1 at ... m from him` line): a victim at 2.5 m
;;; is bound (40, `bind stun 60`), one at 6 m is not; NSb's second bind stays a bind (50, the combo counter up); NSc topples it along the
;;; victim's bearing: level 2 (a-b-c) reaches a victim at 7 m (100), level 1 (NSc alone, 87428: a level-1 tower at the spot) reaches one at
;;; 5 m (70) and not one at 7 m; the SA in NSa's gap is the shatter (55, a bind that keeps); AS3's three hits and MARK SOUTH are C8.
(:name "C19a 南 NSa at 2.5 m: the tower binds" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :frames 100)
(:name "C19b 南 NSa at 6 m: the tower misses" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 6.0 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :frames 100)
(:name "C19c 南 NS a-b at 2.5 m: NSb's bind is a bind" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t) (:quick 1 :modded t)) :frames 140)
(:name "C19d 南 NS a-b-c at 2.5 m: binds, the level-2 topple (100)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "C19e 南 NS a-b-c at 7 m: the binds miss, the level-2 topple reaches him (100)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 7.0 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "C19f 南 NSc alone (87428) at 5 m: a level-1 topple, 3 m, reaches him (70)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 5.0 :fs 300 :p1-cmd (87445 87428) :script () :frames 60)
(:name "C19g 南 NSc alone (87428) at 7 m: the level-1 topple falls short" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 7.0 :fs 300 :p1-cmd (87445 87428) :script () :frames 60)
(:name "C19h 南 NSa > the SA (J in its gap) at 2.5 m: the bind, the shatter binds again" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 2.5 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1)) :frames 140)
(:name "C19i 南 NSa > the shatter > J2 (the SA's string)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 2.5 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1)) :frames 160)
(:name "C19j 南 NSa > the shatter > AS (SP on its hit)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 2.5 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1 :modded t :on :hit)) :frames 200)
