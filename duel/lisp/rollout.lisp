;;;; rollout.lisp — the rollout mode: *IN-ROLLOUT* (defined here only) and WITH-ROLLOUT, the bindings every rollout runner shares
;;;; (sim-state.lisp SIM-ROLLOUT, the offline teacher's and snaptest's; cpu-mcts.lisp MC-FULL-ROLLOUT, the in-game MCTS's and the strategy
;;;; layer's). Loaded before every reader (strategy-glue, cpu-hisagi-range, cpu-mcts, flow), REFACTOR_2026-11 R12.
(in-package :duel)

(defvar *in-rollout* nil "T inside a search's rollout (SIM-ROLLOUT, MC-FULL-STEP): no search, no job, no match end (GO-RESULTS).")

(defmacro with-rollout ((&rest extra) &body body)
  "BODY as a search's rollout: *IN-ROLLOUT*, every log off (*LOG-MUTE*, the pacing / combat / gate logs, a tool's *STEP-HOOK*),
cinematics skipped (*SKIP-CINES*: one ends at once with its AFTER, so a Kikon's Konpaku is settled and the rollout goes on); EXTRA
are the caller's own bindings, in the same LET. (*GATE-LOG* and *STEP-HOOK* are defined in gate.lisp, after cpu-mcts.lisp: there
they bind lexically, which is harmless, a lean step never calls HASH-LOG.)"
  `(let ((*in-rollout* t) (*log-mute* t) (*pacing-log* nil) (*combat-log* nil) (*gate-log* nil) (*step-hook* nil) (*skip-cines* t)
         ,@extra)
     ,@body))
