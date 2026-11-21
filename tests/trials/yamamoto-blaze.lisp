;;;; Yamamoto's heat gauge and 爆炎, batch 1 stage B (docs/duel/DUEL_YAMA_CORE.md "As built (stage B)"): written scripts driving both
;;;; sides (P1 the script, P2 :p2-at), every number read from the combat log (the HEAT / GOKUEN / SP / dealt lines):
;;;;   python3 tools/combo-trial.py tests/trials/yamamoto-blaze.lisp --log
;;;; P1 Yamamoto vs Kenpachi (sealed, standing). :meter = P1's heat at the start, :form :blaze = in 爆炎 from the start (no pose).
;;;; 87730 / 87805: P1's / P2's Reishi (debug, yama.lisp YAMA-DEBUG).
(:name "B1 J1 hit: +8 heat" :p1 :yamamoto :p2 :kenpachi :dist 1.6 :fs 300 :meter 0 :script ((:quick 1)) :frames 60)
(:name "B2 J1 whiff: no heat" :p1 :yamamoto :p2 :kenpachi :dist 4.0 :fs 300 :meter 0 :script ((:quick 1)) :frames 60)
(:name "B3a NS3a at heat 0: plain 40" :p1 :yamamoto :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300 :meter 0
 :script ((:quick 1 :modded t)) :frames 70)
(:name "B3b NS3a at heat 10: pays 10, x1.12" :p1 :yamamoto :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300 :meter 10
 :script ((:quick 1 :modded t)) :frames 70)
(:name "B3c NS3a at heat 40: pays 25, x1.3" :p1 :yamamoto :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300 :meter 40
 :script ((:quick 1 :modded t)) :frames 70)
(:name "B4 J1-J3 AS3 from heat 90: 100 mid-route, GOKUEN at the next neutral" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 1.6 :fs 300
 :meter 90 :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 300)
(:name "B5 GOKUEN from Reishi 30: the drain held at 1" :p1 :yamamoto :form :blaze :p2 :kenpachi :dist 5.0 :fs 300 :meter 100
 :p1-cmd (87730) :script () :frames 150)
(:name "B6a Shikai NS1a at fs 100: pays 30" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 5.0 :fs 100 :meter 0
 :script ((:quick 1 :modded t)) :frames 80)
(:name "B6b GOKUEN NS1a at fs 100: free (fs unchanged), 91" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 1 :dist 5.0 :fs 100 :meter 100
 :script ((:quick 1 :modded t)) :frames 80)
(:name "B7 GOKUEN NS3 a-b from heat 20: 8.3 + what is left (1/3 of 25 since §32), out at the next neutral" :p1 :yamamoto :form :blaze
 :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300 :meter 20 :script ((:quick 1 :modded t) (:quick 1 :modded t)) :frames 150)
(:name "B8a GOKUEN NS1a wave x P2 J1: the burn 23" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300 :meter 100
 :script ((:quick 1 :modded t)) :p2-at ((26 :j)) :frames 120)
(:name "B8b the same, P2 at Reishi 5: the burn stops at 1" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300 :meter 100
 :p1-cmd (87805) :script ((:quick 1 :modded t)) :p2-at ((26 :j)) :frames 120)
(:name "B9 Shikai NS1a wave x P2 J1 at heat 40: the 25 back" :p1 :yamamoto :p2 :kenpachi :ptr 1 :dist 5.0 :fs 300 :meter 40
 :script ((:quick 1 :modded t)) :p2-at ((26 :j)) :frames 120)
(:name "B10 GOKUEN NS1 a-b-c (the tornado's turn: host-tested, the trial has no side step)" :p1 :yamamoto :form :blaze :p2 :kenpachi
 :ptr 1 :dist 5.0 :fs 300 :meter 100 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 260)
(:name "B11 GOKUEN NS2 a-b-c (the dome at once, ENNETSU)" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 2 :dist 5.0 :fs 300 :meter 100
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "B12 GOKUEN J1 J2 J3 (IKKOTSU) AS3 (NADEGIRI 143)" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 1 :dist 1.6 :fs 300 :meter 100
 :script ((:quick 1) (:quick 1) (:quick 1) (:quick 1 :modded t :on :hit) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 240)
(:name "B13 GOKUEN NS3 a-b-c (NADEGIRI 200)" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 3 :dist 1.8 :fs 300 :meter 100
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 220)
(:name "B14 the entry pose: P2's J1 inside it whiffs (heat 100, P1 idle)" :p1 :yamamoto :p2 :kenpachi :dist 1.4 :fs 300 :meter 100
 :script () :p2-at ((4 :j)) :frames 60)
(:name "B14b control: the same J1 at heat 0 (no pose) hits" :p1 :yamamoto :p2 :kenpachi :dist 1.4 :fs 300 :meter 0
 :script () :p2-at ((4 :j)) :frames 60)
(:name "B15 Shikai NS1 a-b at heat 60, P2's J1 meets NS1a's wave after NS1b started: 25 back" :p1 :yamamoto :p2 :kenpachi :ptr 1
 :dist 5.0 :fs 300 :meter 60 :script ((:quick 1 :modded t) (:quick 1 :modded t)) :p2-at ((26 :j)) :frames 140)
(:name "B16 J1 hit in his ORANGE burst: no heat" :p1 :yamamoto :p2 :kenpachi :dist 1.6 :fs 300 :meter 0 :burst :orange
 :script ((:quick 1)) :frames 60)
;;; §30.1 (2026-11-21): 爆炎's NS2 close. ENNETSU a disc of fire round him (r 2.5, 104, a crumple; 87475: on its own): a hit at 2.4 m, a
;;; miss at 3.5 m; the route from 2.2 m (the slash 52, the dome at 0-3 m, ENNETSU).
(:name "B17a 爆炎 ENNETSU alone (87475) at 2.4 m: the disc hits" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 2 :dist 2.4 :fs 300 :meter 100
 :p1-cmd (87475) :script () :frames 70)
(:name "B17b 爆炎 ENNETSU alone (87475) at 3.5 m: out of the disc" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 2 :dist 3.5 :fs 300 :meter 100
 :p1-cmd (87475) :script () :frames 70)
(:name "B17c 爆炎 NS2 a-b-c from 2.2 m" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 2 :dist 2.2 :fs 300 :meter 100
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :frames 200)
(:name "B7b GOKUEN NS3 a-b from heat 50: 8.3 + 8.3, still in 爆炎 (§32)" :p1 :yamamoto :form :blaze :p2 :kenpachi :ptr 3 :dist 1.8
 :fs 300 :meter 50 :script ((:quick 1 :modded t) (:quick 1 :modded t)) :frames 150)
