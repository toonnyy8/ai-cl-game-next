;;;; Scripted outcome traces (docs/bevy/M0_NOTES.md §4 "Scripted outcome traces"): tools/simgate/trial.lisp's format, recorded by
;;;; tools/port/oracle/gen.py as scr-counter-stance-break. The core system starts no Breaker from a press: P2's comes from :p2-start
;;;; (CORE-START!, the trace's `E core-start 1 :KE-BREAKER`).
;; COUNTER: P1's J1 lands while P2's Breaker is in its aura (DEFENDER-STATE :breaker -> RESOLVE-CONTACT :counter).
(:name "C1 J1 into a Breaker's aura: COUNTER" :p1 :kenpachi :p2 :kenpachi :dist 2.2 :fs 300 :script ((:quick 1))
 :p2-start ((0 :ke-breaker)) :frames 80)
;; STANCE-BREAK: P2's Breaker strike lands in P1's TAME (pointer 3's NS3a, a :parry window f2-28): parry + breaker -> :stance-break.
(:name "C2 a Breaker into the TAME's parry window: STANCE-BREAK" :p1 :kenpachi :p2 :kenpachi :ptr 3 :dist 1.4 :fs 300
 :script ((:quick 1 :modded t)) :p2-start ((0 :ke-breaker)) :frames 80)
