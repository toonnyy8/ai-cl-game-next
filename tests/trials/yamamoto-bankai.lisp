;;;; Yamamoto's Bankai, batch 1 stage C (docs/duel/DUEL_YAMA_CORE.md "As built (batch 1 C)"): written scripts driving both sides (P1 the
;;;; script, P2 :p2-at / :p2-press / :p2-start), every number read from the combat log (the AWAKEN / ZANKA / MARK / SP / hit lines):
;;;;   python3 tools/combo-trial.py tests/trials/yamamoto-bankai.lisp --log
;;;; P1 Yamamoto vs Kenpachi (sealed, standing) unless :p2 says. :form :bankai = in the Bankai from the start (awakened, no cinematic).
;;;; One match carries every trial and the marks are his fighter's state: every Bankai trial sets them first (yama.lisp YAMA-DEBUG:
;;;; 87445 cleared, 87441-87443 a mark, 87447 the switch line, 87420+i a Bankai segment started on its own).
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
(:name "C13b control: the switch with no 北: open" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 4.0 :fs 300
 :p1-cmd (87445 87447) :script () :frames 2)
(:name "C14a 西 NSb's armour takes P2's J (NSa whiffs at 2.6 m, NSb charges in place since §39)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.6
 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t)) :p2-at ((27 :j)) :log-simf t :frames 120)
(:name "C14b control: the same J on NSa's startup (no armour): a cancel" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 1.6
 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t)) :p2-at ((3 :j)) :frames 80)
(:name "C15 西 NSb loses to an AS (P2's AS1 started under it)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2 :dist 2.6 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t)) :p2-start ((27 :ke-z-as1)) :log-simf t :frames 120)
(:name "C16a 南 NSa's hands (the tower 1.5 m ahead), P2 at 2.5 m steps after S: dodged" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :p2-press ((24 :step 1)) :frames 90)
(:name "C16b control: no Step: the hands bind" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :frames 90)
(:name "C17 南 NSc's bone wall stops Ichigo's Getsuga" :p1 :yamamoto :form :bankai :p2 :ichigo :ptr 3 :dist 8.0 :fs 300 :p1-cmd (87445 87428)
 :script () :p2-start ((22 :ic-as2b)) :frames 120)
(:name "C18b control: AS2 held after J1 J2 under pointer 2 (no 北): pointer 2's profile, 3 Konpaku" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 2
 :dist 1.4 :fs 300 :p1-cmd (87445) :script ((:quick 1) (:quick 1) (:quick 60 :modded t :on :hit)) :frames 200)
;;; §30.3 (2026-11-21): 南's skeleton tower. NSa raises it 1.5 m before him (2.5 until §35) (the `tower level 1 at ... m from him` line): a victim at 2.5 m
;;; is bound (40, `bind stun 60`), one at 3.4 m is not (the disc r 0.9 ends 2.4 m out since 2026-11-23, Kenpachi's hurt r 0.45 past it: 2.85; r 1.2 /
;;; 3.15 until then; 4 m until §38); NSb's second bind stays a bind (50, the combo counter up); NSc topples it along the victim's bearing, a line
;;; as long as the tower is tall from its base (1.68 / 2.94 m since 2026-11-23: ends 3.18 / 4.44 m out, + 0.45): level 2 (a-b-c) reaches a
;;; victim at 4.7 m (100) and not one at 5.1 m, level 1 (NSc alone, 87428: a level-1 tower at the spot) reaches one at 3.4 m (70) and not one
;;; at 3.9 m (re-aimed 2026-11-23 for the lower tower: 5.8 / 6.2 and 3.8 / 4.2 m since §38; 7 / 4 / 5.5 m until §38; 5 / 7 m until §35); the
;;; SA in NSa's gap is the shatter (55, a bind that keeps); AS3's three hits and MARK SOUTH are C8.
(:name "C19a 南 NSa at 2.5 m: the tower binds" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :frames 100)
(:name "C19b 南 NSa at 3.4 m: the tower misses (4 m until §38, 6 m until §35)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 3.4 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t)) :frames 100)
(:name "C19c 南 NS a-b at 2.5 m: NSb's bind is a bind" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t) (:quick 1 :modded t)) :frames 140)
(:name "C19d 南 NS a-b-c at 2.5 m: binds, the level-2 topple (100)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300
 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "C19e 南 NS a-b-c at 4.7 m: the binds miss, the level-2 topple reaches him (100) (5.8 m until 2026-11-23, 7 m until §38)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 4.7 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "C19e2 南 NS a-b-c at 5.1 m: the level-2 topple falls short (6.2 m until 2026-11-23)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 5.1 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "C19f 南 NSc alone (87428) at 3.4 m: a level-1 topple, 1.68 m from 1.5, reaches him (70) (3.8 m until 2026-11-23, 4 m until §38)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 3.4 :fs 300 :p1-cmd (87445 87428) :script () :frames 60)
(:name "C19g 南 NSc alone (87428) at 3.9 m: the level-1 topple falls short (4.2 m until 2026-11-23, 5.5 m until §38)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 3.9 :fs 300 :p1-cmd (87445 87428) :script () :frames 60)
(:name "C19h 南 NSa > the SA (J in its gap) at 2.5 m: the bind, the shatter binds again" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 2.5 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1)) :frames 140)
(:name "C19i 南 NSa > the shatter > J2 (the SA's string)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 2.5 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1)) :frames 160)
(:name "C19j 南 NSa > the shatter > AS (SP on its hit)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 2.5 :fs 300 :p1-cmd (87445) :script ((:quick 1 :modded t) (:quick 1) (:quick 1 :modded t :on :hit)) :frames 200)
;;; 2026-11-23 (the user: 「殘日獄衣的強化要回到中立才解除，因此當指針臨時切換時也要有強化效果（包含旭日刀攻擊上升、斬擊裂痕變大，南的高塔變大、
;;; 附帶火焰效果以增加傷害等等）」, 「南的 AS3 也要吃強化」): 西's garb level set directly (87456 / 87457 with the segment in the same command list:
;;; his next neutral clears it; the switch itself is a side stick, which these trials cannot press: tests/scripts/duel-yama-garb.json). NS1c
;;; alone reaches b + r + 0.45: 5.65 m as written (4.5 x 0.7), 6.69 m at garb 1 (5.4 x 0.84), 7.73 m at garb 2 (6.3 x 0.98); its damage x1.4 /
;;; x1.7 (120 -> 168 / 204). 南 under garb 2: the disc r 1.26 (2.76 + 0.45 m), the hands 40 / 50 x1.7 = 68 / 85, the level-2 tower 4.12 m (its
;;; topple ends 5.62 m out, + 0.45), 100 x1.7 = 170; AS3's hands under garb 2: 40 x1.7 = 68. The `GARB` lines: set, then cleared at neutral.
(:name "G1a 東 NS1c alone at 6.0 m, no garb: short (5.65 m)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 6.0 :fs 300
 :p1-cmd (87445 87422) :script () :frames 70)
(:name "G1b 東 NS1c alone at 6.0 m under garb 1: the x1.2 capsule reaches, 168" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 6.0 :fs 300
 :p1-cmd (87445 87456 87422) :script () :frames 70)
(:name "G1c 東 NS1c alone at 3.0 m under garb 2: 204" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 3.0 :fs 300
 :p1-cmd (87445 87457 87422) :script () :frames 70)
(:name "G1d 東 NS a-b-c from neutral after a garb level (87457 alone, 2 idle frames: his neutral clears it): C3's 114, NS1c 120" :p1 :yamamoto :form :bankai
 :p2 :kenpachi :ptr 1 :dist 3.0 :fs 300 :p1-cmd (87445 87457) :script ((:quick 1 :modded t :wait 2) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
(:name "G2a 南 NS a-b-c at 2.5 m under garb 2: 68, 85, the topple 170" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.5 :fs 300
 :p1-cmd (87445 87457 87426) :script ((:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "G2b 南 NS a-b-c at 5.8 m under garb 2: the binds miss, the 4.12 m topple reaches him (170)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3
 :dist 5.8 :fs 300 :p1-cmd (87445 87457 87426) :script ((:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "G3 AS3's hands alone (87433) at 2.0 m under garb 2: 68" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.0 :fs 300
 :p1-cmd (87445 87457 87433) :script () :frames 60)
(:name "G1e control: 東 NS1c alone at 3.0 m, no garb (G1b / G1c's x1.4 / x1.7 over this)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 1 :dist 3.0
 :fs 300 :p1-cmd (87445 87422) :script () :frames 70)
(:name "G3b control: AS3's hands alone at 2.0 m, no garb (G3's x1.7 over this)" :p1 :yamamoto :form :bankai :p2 :kenpachi :ptr 3 :dist 2.0 :fs 300
 :p1-cmd (87445 87433) :script () :frames 60)
;;; ... and the garb reached by real presses (no debug): 西 NSa sets it (`GARB 0 -> 1`), its charged SA, J2, J3 carry x1.4 by the charge alone
;;; (CORE-CHARGE-MULT; W1's), AS3's three hazards x1.4 by the garb alone (a hazard gets no charge x): no free frame from NSa to AS3c, then
;;; `GARB 1 -> 0 (neutral)`. Its control: STRAT_SET='*ya-garb-x*=(1.0 1.0)' (the same route, the garb's x off) gives AS3's hits x1.0.
(:name "G4 西 NSa > SA > J2 > J3 > AS3 a-b-c (2.6 m): the string x1.4 by its charge, AS3's dead x1.4 by the garb" :p1 :yamamoto :form :bankai
 :p2 :kenpachi :ptr 2 :dist 2.6 :fs 300 :p1-cmd (87445)
 :script ((:quick 1 :modded t) (:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 300)
