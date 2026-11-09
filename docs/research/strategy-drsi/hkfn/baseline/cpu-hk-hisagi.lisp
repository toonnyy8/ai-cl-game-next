;;;; cpu-hk-hisagi.lisp — Hisagi's style CPU against Kenpachi (DUEL_AI_STRATEGY §8.19 round 5, step 7). HISAGI-HK-STYLE is a strategy's :fn
;;;; (§9), run first on every step he is free to press: T when it decided, NIL leaves the step to the in-game MCTS and the generic core CPU. Off
;;;; by default: only a strategy that names it plays it (a §10 style unit, once kept). Written by the dream-rsi search in
;;;; docs/research/strategy-drsi/hkfn/. The search's starting program: his merged style (cpu-hisagi-range.lisp) unchanged.
(in-package :duel)

(defun hisagi-hk-style (e b f kit s d)
  "Hisagi's style against Kenpachi: T when it decided this step, NIL for the MCTS / the generic core CPU."
  (hisagi-merged-style e b f kit s d))
