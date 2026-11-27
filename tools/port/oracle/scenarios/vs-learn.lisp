;;;; A vs-human trace (docs/bevy/M0_NOTES.md §4, M2 Task 1), recorded by tools/port/oracle/gen.py as vs-learn with record.lisp's vs driver
;;;; (not a trial file). Debug 2504: a human Kenpachi (P1, the scenario's seeded device) vs a HARD Ichigo CPU that learns (fq-online.lisp:
;;;; FQ-ATTACH! gives it the player's copy of its Q table, FQ-MATCH-END updates it and saves it to the page). Twice: the second 2504
;;;; forgets *FQ-TABLES*, so its attach reloads the copy the first match saved, from the recorder image's in-memory page ("duel fq load
;;;; 1 3 page matches 1"), and plays it.
(:seed 2504 :matches ((:cmd 2504) (:cmd 2504)))
