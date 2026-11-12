;;;; sp.lisp — SP spending on the flash-step gauge (docs/duel/DUEL_SP.md §2-§6, §8.2), as plain CL (host-tested,
;;;; tests/duel-rules/sp.lisp). Every rule is a pure function of numbers; the sim's mutation places (core-sim, combat, fighter)
;;;; call these. Knobs (`*sp-...*`, `*fs-cell*`, `*fs-max*`) are in tuning.lisp and are only default arguments / read values.
;;;; Batch S0: no call site yet.
(in-package :duel)

(defun sp-cost (damage &optional (mult 1.0) override)
  "A segment's SP cost: OVERRIDE if given, else DAMAGE x `*sp-cost-rate*` x MULT (the kit's multiplier) rounded to 5 and clamped to
`*sp-cost-min*` .. `*sp-cost-max*` (DUEL_SP §4; a setup segment with no damage costs the minimum)."
  (or override
      (let ((r (* 5.0 (floor (+ (/ (* damage *sp-cost-rate* mult) 5.0) 0.5)))))
        (max *sp-cost-min* (min *sp-cost-max* r)))))

(defun sp-start-p (cls first fs bursting)
  "May a segment of class CLS (:ns / :as) start (DUEL_SP §3)? An AS always; an NS when it is a route's first segment (NSa), the gauge FS is
above 0, or BURSTING (SP is free in a burst)."
  (or (eq cls :as) (and first t) (> fs 0) (and bursting t)))

(defun sp-pay (fs cost bursting)
  "(values new-fs paid): a burst pays nothing, else min(COST, FS)."
  (if bursting
      (values fs 0.0)
      (let ((p (max 0.0 (min cost fs)))) (values (- fs p) p))))

(defun sp-scale (paid cost)
  "Damage factor of a segment that paid PAID of its COST: 0.5 + 0.5 x PAID / COST (DUEL_SP §3); 1.0 when COST is 0 (the caller passes cost 0 for
a segment that started free in a burst, §8.6 Q7)."
  (if (<= cost 0.0) 1.0 (+ 0.5 (* 0.5 (min 1.0 (/ paid cost))))))

(defun sp-refund (fs paid)
  "The gauge after a cancel gives back what the segment PAID, capped at `*fs-max*`."
  (min *fs-max* (+ fs paid)))

(defun sp-atk-gain (cls cancel)
  "SP one ATK event earns (DUEL_SP §5): CANCEL (the move takes part in a cancel) -> `*sp-gain-cancel*` for :na (J) and :sa; else a hit gives
`*sp-gain-j*` / `*sp-gain-sa*`. 0 for :ns / :as / Kikon and anything else. The caller asks once per damaging hit window, the cancel once per exchange."
  (case cls
    (:na (if cancel *sp-gain-cancel* *sp-gain-j*))
    (:sa (if cancel *sp-gain-cancel* *sp-gain-sa*))
    (t 0.0)))

(defun sp-break-take (victim-fs)
  "(values take gain) of a breakthrough on a victim with VICTIM-FS: `*sp-break-share*` of what is above the last cell (`*fs-cell*`); the
attacker gains `*sp-break-gain*` of the take (DUEL_SP §6)."
  (let ((take (* *sp-break-share* (max 0.0 (- victim-fs *fs-cell*)))))
    (values take (* take *sp-break-gain*))))

(defun sp-exchange-open-p (xch-a xch-b)
  "Do two fighters carry the same live exchange id (the cancel's tick; negative = none)?"
  (and (>= xch-a 0) (= xch-a xch-b)))

(defun sp-switch-ok-p (fs was-full switched routes)
  "The pointer switch's gate (DUEL_SP §3): not SWITCHED yet, ROUTES > 1 NS routes, the awakening gauge WAS-FULL at some time, and FS > 0."
  (and (not switched) (> routes 1) was-full (> fs 0)))
