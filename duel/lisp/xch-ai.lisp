;;;; xch-ai.lisp — the core CPU's exchange after a cancel and its seeking of one (docs/duel/DUEL_AI_STRATEGY.md §11.18; the user,
;;;; 2026-11-14: 「好 1+2，然後再以此修改 AI 的策略，然後盡量讓 AI 積極相消互動」), as plain CL over the triangle (core.lisp), host-tested
;;;; (tests/duel-rules/xch-ai.lisp). core-ai.lisp plays them (CAI-XCH-NEW, CAI-XCH-STEP, CAI-CLASH) for every CPU, its style CPUs included:
;;;; the one place a CPU answers a cancel.
;;;;
;;;; After a J x NS cancel both moves count as landed (DUEL_CORE §2.1). The J side may take its AS at once; the NS side's SA opens on the
;;;; cancel (§2.1.1), and a J pressed after the J side's AS (or next link) started starts it at once and wins (AS vs SA: the later start,
;;;; NA vs SA: absorbed). So the J side guesses (AS, the next J, a Hoho out: its perfect Hoho dodges the segment's later hits and counters)
;;;; and the NS side reacts to what it sees, BRAIN-DELAY late (EASY 24, NORMAL 14, HARD 8 frames against a ~16-frame window).
(in-package :duel)

(defun xch-side (cls contact xch cls-t)
  "Which side of a cancel a CPU's move in play (class CLS, CONTACT, begun on tick CLS-T; his exchange XCH, FIGHTER-XCH) stands on:
:J an NA link or SA that took part (its AS, next link and Hoho are open), :NS an NS segment that took part (its SA is open at once), else
NIL (no cancel in this move, an AS, or a real hit's route). An SA counts only for an exchange strictly after its start: an SA latched
before the cancel fires on it stamped with the cancel's tick (CORE-LATCH-STEP) and took no part."
  (when (core-cancelled-p xch cls-t)
    (case cls
      (:ns :ns)
      (:na (and (eq contact :hit) :j))
      (:sa (and (eq contact :hit) (> xch cls-t) :j)))))

(defun xch-j-answer (r ws reach-ok hoho-ok)
  "The J side's answer for the event's roll R in [0,1) over the weight plist WS (:as :j :hoho, the difficulty's *CAI-XCH-J*): the AS and
the next J only when REACH-OK (the AS reaches him), the Hoho only when HOHO-OK (ready): WEIGHTED-PICK, NIL (hold) when nothing is left."
  (weighted-pick r :as (if reach-ok (getf ws :as 0.0) 0.0) :j (if reach-ok (getf ws :j 0.0) 0.0) :hoho (if hoho-ok (getf ws :hoho 0.0) 0.0)))

(defun xch-turn-seen-p (ocls ostart xch own-hit)
  "Does the NS side see a J side's attack its SA beats, after their cancel on tick XCH, in the opponent's perceived move (class OCLS, begun
on tick OSTART)? His turn: an AS or a new NA link started after the cancel (AS vs SA: the later start; NA vs SA: absorbed). Or, when OWN-HIT
(the NS segment's own hit was the cancel's: his J was still in its startup), that J or SA itself, still to land or recovering (DUEL_AI_STRATEGY
§11.18: unanswered, its hit lands on the segment's recovery)."
  (and (or (and (member ocls '(:as :na)) (> ostart xch))
           (and own-hit (member ocls '(:na :sa))))
       t))

(defun clash-opener (ocls)
  "The class a CPU throws into the opponent's classed move OCLS to cancel it whichever hit lands first (CORE-VERDICT :CANCEL both ways),
of the two it can open with from neutral (:NA an attack, :NS an SP): :NA against his NS or AS, :NS against his NA or SA; NIL else."
  (and ocls (find-if (lambda (c) (and (eq (core-verdict c ocls) :cancel) (eq (core-verdict ocls c) :cancel))) '(:na :ns))))
