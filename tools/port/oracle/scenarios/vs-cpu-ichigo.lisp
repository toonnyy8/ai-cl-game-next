;;;; A vs-human trace (M2 final review I1), recorded by tools/port/oracle/gen.py as vs-cpu-ichigo with record.lisp's vs driver (not a
;;;; trial file). A VS CPU match as the menu starts it (trace.lisp TR-VS-START): a human Kenpachi (P1, the scenario's seeded device) vs a
;;;; thinking NORMAL Ichigo CPU, the intro played, no debug command. Unlike vs-cpu's Kenpachi CPU (his stand-off styles decide before the
;;;; MCTS) and vs-learn's HARD Ichigo (in *MC-OFF-AT*), a NORMAL Ichigo queues full-sim MCTS jobs, so this trace keys the rollouts
;;;; against a human: the stand-in brain, the pilot no longer camera-relative, the human's device read inside a rollout.
(:seed 1729 :matches ((:vs-start :kenpachi :ichigo :normal 4243)))
