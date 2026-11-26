;;;; Scripted outcome traces (docs/bevy/M0_NOTES.md §4 "Scripted outcome traces"): tools/simgate/trial.lisp's format, recorded by
;;;; tools/port/oracle/gen.py as scr-draw. A time-up tie: both idle (no script, P2's brain off) from TRIAL-RUN's setup (Konpaku and
;;;; Reishi full on both sides) while the match timer TRIAL-RUN sets (36000 f) runs out: TIME-UP-WINNER :draw, both :lose at RESULTS.
;;;; ponytail: the whole 600 s idle (~36k steps), not a short timer: trial.lisp has no timer key and a debug command is unported in Rust.
(:name "D1 idle to the bell: a draw" :p1 :kenpachi :p2 :ichigo :dist 4.0 :script () :frames 36060)
