;;;; Scripted outcome traces (docs/bevy/M0_NOTES.md §4 "Scripted outcome traces"): tools/simgate/trial.lisp's format, recorded by
;;;; tools/port/oracle/gen.py as scr-blocked-guard-crush-back. The core system has no guard (fighter.lisp GUARD-HELD-P); the one guard a
;;;; core kit has is KESSA's :parry-block ward: a ranged hit in his parry's window (鎖盾, :ic-k-parry, f2-25, started by :p2-start) is
;;;; :guard (RESOLVE-CONTACT), so it is BLOCKED and drains the guard gauge (DRAIN-GUARD: at 0 GUARD CRUSH, guardless until full: GUARD BACK).
;;;; P1's wave: Ichigo's pointer 2 NS2 a-b-c, GETSUGA JUJISHO (guard 22), 6 m away it lands at the trial's frame 73.
(:name "K1 JUJISHO into KESSA's parry: BLOCKED" :p1 :ichigo :p2 :ichigo :p2-form :kessa :ptr 2 :dist 6.0 :fs 300
 :script ((:quick 1 :modded t) (:quick 1 :modded t) (:quick 1 :modded t)) :p2-start ((60 :ic-k-parry)) :frames 160)
;; Eight parries 46 f apart (each costs 10 on its frame 0, ICHIGO-PARRY-OPEN; the regen waits *GG-DELAY* 60 after each) leave 20; the
;; ninth leaves 10 and the blocked JUJISHO (22) empties it: GUARD CRUSH; ~1000 f later the guardless regen fills it: GUARD BACK.
(:name "K2 the guard gauge drained by parries, then a blocked JUJISHO: GUARD CRUSH, GUARD BACK" :p1 :ichigo :p2 :ichigo :p2-form :kessa
 :ptr 2 :dist 6.0 :fs 300 :script ((:quick 1 :modded t :wait 306) (:quick 1 :modded t) (:quick 1 :modded t))
 :p2-start ((0 :ic-k-parry) (46 :ic-k-parry) (92 :ic-k-parry) (138 :ic-k-parry) (184 :ic-k-parry) (230 :ic-k-parry) (276 :ic-k-parry)
            (322 :ic-k-parry) (368 :ic-k-parry))
 :frames 1500)
