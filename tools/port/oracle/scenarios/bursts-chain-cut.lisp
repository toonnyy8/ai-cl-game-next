;;;; Scripted outcome traces (docs/bevy/M0_NOTES.md §4 "Scripted outcome traces"): tools/simgate/trial.lisp's format, recorded by
;;;; tools/port/oracle/gen.py as scr-bursts-chain-cut. P (:awaken, unmodified) is the Burst; its mode comes from P1's state (BURST-MODE).
;; WHITE: free.
(:name "B1 P from neutral: WHITE" :p1 :ichigo :p2 :kenpachi :dist 4.0 :fs 300 :script ((:awaken 1)) :frames 60)
;; ORANGE: J1's hit landed, its cancel window open; the next J1 inside *CHAIN-WINDOW* has its startup cut (START-MOVE's "chain cut").
(:name "B2 J1 hit, P: ORANGE, then J1: chain cut" :p1 :ichigo :p2 :kenpachi :dist 1.6 :fs 300
 :script ((:quick 1) (:awaken 1 :on :hit) (:quick 1)) :frames 120)
