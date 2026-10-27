;;;; core-sim.lisp — the core system's side of the sim (docs/duel/DUEL_CORE.md): what the two buttons start, how a step's hits
;;;; are judged by the triangle (core.lisp), the SP pointer, the Kikon hold and its cancel. Everything here reads and writes the
;;;; fighter component; the pure rules (the table, the counts) are core.lisp's. A fighter of a kit with no :core (the four
;;;; characters out of the roster) never enters any of it: his moves have no class, his hits are clean hits.
(in-package :duel)

;;; ---------------------------------------------------------------- classes of the move in play
(defun core-note-start! (f mv old)
  "A move MV starts (START-MOVE; OLD = the move it replaces, or NIL): record its class (KIT-CLASS), the tick it started on, and
count the attack press (an NA link and an SA are attack presses: the pointer an AS writes)."
  (let ((cls (kit-class (fighter-kit f) mv)))
    (declare (ignorable old))
    (setf (fighter-cls f) cls (fighter-cls-t f) *match-tick*
          (fighter-sp-held f) (and (member cls '(:ns :as)) (if (core-touch-p f) :rearm t))   ; a tap fired on its lift (CORE-HOLD-STEP)
          (fighter-charge-mult f) (let ((c (getf (mv-params mv) :charge-mult)))   ; a charged SA arms it; its string keeps it
                                    (cond (c (f32 c)) ((and old (member cls '(:na :as))) (fighter-charge-mult f)) (t 1f0))))
    (case cls ((:na :sa) (incf (fighter-presses f))))))

(defun core-charge-mult (fa mv own hazard)
  "The damage x of attacker FA's hit with MV: a charged SA's :charge-mult on the string it opened (its J2 / J3 and the AS segments
after it; the user, 2026-10-27: 「月牙靈壓帶來的強化效果除了後續的 J2 J3 以外，連同插入的 SP 結尾也都會一併受到強化」), not on the
charged SA itself (its own :dmg is written high) nor on a hazard."
  (if (and own (not hazard) mv (not (getf (mv-params mv) :charge-mult))) (fighter-charge-mult fa) 1f0))

(defun core-window-class (f)
  "The class of the move F is inside the startup or active frames of (where the triangle judges a hit on him), else NIL."
  (let ((mv (fighter-move f)))
    (and (eq (fighter-state f) :move) (eq (fighter-phase f) :main) (fighter-cls f) mv
         (< (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
         (fighter-cls f))))

;;; ---------------------------------------------------------------- starting moves
(defun core-sp-start! (e f)
  "SP from a free state: NS under the pointer (the next segment pointer's style). T when it started."
  (let ((mv (kit-core-move (fighter-kit f) :ns (fighter-ptr f))))
    (when mv
      (setf (fighter-sp-ptr f) (fighter-ptr f))
      (start-move e mv :quick)
      t)))

(defun core-as-start! (e f)
  "SP after an attack hit: the AS of the attack press count, writing the pointer. Its Kikon (cinematic, Konpaku profile) is the
pointer it writes, AS n's own theme (the user, 2026-10-28: 「幫我把毀魂技的聯動改成依據目前指針指向的 NS 來決定，而不是由切換前的 NS 決定」;
before: the pointer before the write)."
  (let* ((n (core-as-pointer (fighter-presses f) (getf (kit-core (fighter-kit f)) :as-by-press))) (mv (kit-core-move (fighter-kit f) :as n)))
    (when mv
      (setf (fighter-sp-ptr f) n)
      (start-move e mv :quick)
      (setf (fighter-ptr f) n (fighter-as-done f) t)
      (clog "~a AS~d pointer ~d" (side-name e) n n)
      t)))

(defun core-move-sp! (e f vp mv sf button)
  "SP pressed inside move MV at frame SF (MOVE-COMMANDS): AS off a landed attack (an NA link or the SA; the hit or a cancel),
or the next NS / AS segment (2026-10-27: AS n has n segments, 「每段再按 SP」), latched until the segment's active frames are over.
T when something started."
  (declare (ignore sf))
  (case (fighter-cls f)
    ((:na :sa) (and (eq (fighter-contact f) :hit) (not (fighter-as-done f))
                    (cancel-open-p (fighter-sf f) (fighter-land-sf f) (mv-total mv) t)
                    (core-as-start! e f)))
    ((:ns :as) (when (mv-ns-next (fighter-kit f) mv)
           (setf (fighter-queued f) :ns)
           (vpad-consume! vp button))
         nil)))

(defun core-sa-start! (e f vp mv sf button)
  "An attack pressed inside an NS segment (MOVE-COMMANDS): latch the SA (it starts when the segment's active frames are over)."
  (declare (ignore e sf mv))
  (when (kit-sa-move (fighter-kit f))
    (setf (fighter-queued f) :sa)
    (vpad-consume! vp button))
  nil)

(defun core-latch-step (e f mv sf)
  "A latched NS continuation or SA starts once the segment's active frames are over (MOVE-COMMANDS). T when it started."
  (let ((q (fighter-queued f)))
    (when (and (member q '(:ns :sa)) (>= sf (+ (mv-s mv) (mv-a mv))) (< sf (mv-total mv)))
      (setf (fighter-queued f) nil)
      (let ((next (if (eq q :ns) (mv-ns-next (fighter-kit f) mv) (or (mv-sa-move (fighter-kit f) mv) (kit-sa-move (fighter-kit f))))))
        (when next (start-move e next :quick) t)))))

;;; ---------------------------------------------------------------- judging a step's hits
(defun core-verdicts (hits)
  "The triangle's verdict on each pending hit of this step, all judged against the states they were collected in (so a pair of
simultaneous hits is seen as a pair): a list of :hit / :cancel / :absorb in HITS' order. A hazard's hit, a hit of a move with no
class, or on a defender outside a classed window is a clean hit."
  (loop for h in hits
        collect (let* ((mv (pending-mv h)) (att (pending-att h)) (def (pending-def h))
                       (fa (fighter att)) (fd (fighter def))
                       (ca (and mv (not (pending-hazard h)) (eq mv (fighter-move fa)) (fighter-cls fa)))
                       (cd (core-window-class fd)))
                  (if (and ca cd)
                      (core-verdict ca cd
                                    :simul (loop for h2 in hits thereis (and (eq (pending-att h2) def) (eq (pending-def h2) att)
                                                                             (pending-mv h2) (not (pending-hazard h2))))
                                    :att-t (fighter-cls-t fa) :def-t (fighter-cls-t fd))
                      :hit))))

(defun core-nohit! (h verdict)
  "Apply a :cancel or :absorb verdict of pending hit H: no damage. A cancel counts as a hit for the attacker (his chain, cancels
and AS open: 「視同命中」); a same-class tie also ends both moves and bounces the fighters apart; an absorb is a block for him."
  (let* ((att (pending-att h)) (def (pending-def h)) (fa (fighter att)) (fd (fighter def))
         (p (pos-of att)) (q (pos-of def)) (mx (* 0.5 (+ (aref p 0) (aref q 0)))) (mz (* 0.5 (+ (aref p 2) (aref q 2)))))
    (when (and (eq (fighter-state fa) :move) (eq (pending-mv h) (fighter-move fa)))
      (ecase verdict
        (:cancel
         (setf (fighter-contact fa) :hit)
         (when (< (fighter-land-sf fa) 0) (setf (fighter-land-sf fa) (fighter-sf fa)))
         (hitstop *hitstop-block*)
         (slowmo *core-clash-slowmo-scale* *core-clash-slowmo-seconds*)
         (emit :clash mx 1.2 mz)
         (clog "~a ~a x ~a: CANCEL" (side-name att) (mv-name (pending-mv h)) (side-name def))
         (when (and (eq (fighter-cls fa) (core-window-class fd)) (eq (fighter-state fd) :move))   ; a same-class tie: both to neutral
           (core-bounce! att def)))
        (:absorb
         (setf (fighter-contact fa) (or (fighter-contact fa) :block))
         (hitstop *hitstop-block*)
         (emit :armored def mx 1.2 mz)
         (clog "~a ~a x ~a: ABSORBED" (side-name att) (mv-name (pending-mv h)) (side-name def)))))))

(defun core-bounce! (a b)
  "A and B back to neutral, pushed apart (a cancelled tie, a cancelled Kikon follow-up)."
  (let* ((p (pos-of a)) (q (pos-of b)))
    (dolist (x (list a b))
      (let ((fx (fighter x))) (setf (fighter-follow fx) nil (fighter-kikon-lock fx) 0))
      (to-idle x 0))
    (set-slide a (* 0.5 *clash-push*) 12 (- (aref p 0) (aref q 0)) (- (aref p 2) (aref q 2)))
    (set-slide b (* 0.5 *clash-push*) 12 (- (aref q 0) (aref p 0)) (- (aref q 2) (aref p 2)))))

;;; ---------------------------------------------------------------- the Kikon hold
(defun core-kikon-p (f mv)
  "Is MV (a move of F's kit) an SP that holds into the Kikon (an NS or an AS of a kit with a :core)?"
  (and mv (member (kit-class (fighter-kit f) mv) '(:ns :as)) t))

(defun core-hold-step (e f)
  "Each step inside an NS / AS segment: a let-go of the SP button clears the hold (FIGHTER-SP-HELD), so only a hold kept from
the segment's start to its hit is a Kikon; a mashed SP that is down on the hit frame is not (the user, 2026-10-27: 「我是要求『按住』才發動，
但目前連打也會觸發」). On the phone the SP is a tap, fired on the lift, so the segment starts :REARM: the hold is a new touch after it,
kept down to the hit (the user, 2026-10-28: 「實際在觸控時的判斷應該改為『打中後是否有再次點擊並長按 SP』」, judged at the hit: 「打中前按下」)."
  (case (fighter-sp-held f)
    ((nil))
    (:rearm (when (touch-active-p *touch*) (setf (fighter-sp-held f) t)))
    (t (unless (core-held-p e) (setf (fighter-sp-held f) nil)))))

(defun core-touch-p (f)
  "Is F P1 on the phone's thumb pad (*ONE-HAND*), whose SP is a tap?"
  (and *one-hand* *p1* (eq f (fighter *p1*))))

(defun core-held-p (att)
  "Is ATT still holding the SP button (the attack button) this step?"
  (or (vpad-down (pilot-vpad (pilot att)) :quick)
      (and *one-hand* (eq att *p1*) (touch-active-p *touch*))))   ; a phone: the thumb back on the pad while the SP strikes

(defun core-kikon-cine (att)
  "The cinematic of ATT's Kikon by the pointer of the SP that struck (the kit's :core :kikon-cines, one per pointer; NIL: the kit's own).
KESSA's pointer 3 plays 千影 (the user, 2026-10-28: 「指針三的毀魂技使用之前的「千影」動畫」)."
  (let ((f (fighter att)))
    (and *core-on* (nth (1- (max 1 (min 3 (fighter-sp-ptr f)))) (getf (kit-core (fighter-kit f)) :kikon-cines)))))

(defun core-set-kikon-n! (att red)
  "The Konpaku the Kikon about to follow takes: the kit's count in the style of the SP that struck (CORE-KIKON-COUNT)."
  (let ((f (fighter att)))
    (setf (fighter-kikon-n f) (core-kikon-count (kit-kikon-konpaku (fighter-kit f)) (fighter-sp-ptr f) red))))

(defun core-follow-step (e f mv)
  "The Kikon's dash-in after the struck SP (phase :follow): chase the knocked-back victim for KIKON-FOLLOW-WAIT frames, then the
same strike again; its hit is the Kikon (KIKON-OUTCOME)."
  (incf (fighter-hold f))
  (let ((v (motion-vel (motion e))) (left (- (kikon-follow-wait (mv-s mv)) (fighter-hold f))))
    (fill v 0f0)
    (turn-to-opp e f (track-step 360.0))
    (run-velocity e (kikon-follow-speed (fighter-dist f) left (or (getf (mv-params mv) :follow-cap) 22.0)))   ; (a wave's: far)
    (when (<= left 0)
      (setf (fighter-hits f) 0 (fighter-contact f) nil (fighter-land-sf f) -1)
      (enter-main e f mv))))

(defun core-wave-strike (att hz)
  "The follow-up strike (its :params :kikon-strike) of the wave HZ that ATT's NS / AS segment fired (HAZARD-SP-MV), when its hit may
be a Kikon's first strike: the hold kept since that segment (the button still down: APPLY-HIT), ATT still in it or free again
(the user, 2026-10-28: 「我發現月牙天衝揮出去後都無法打出毀魂技」; asked how, 「打中後瞬步衝過去補一刀」). Else NIL."
  (let* ((f (fighter att)) (from (and *core-on* hz (hazard-sp-mv hz))))
    (and from (eq (fighter-sp-held f) t)
         (or (and (eq (fighter-state f) :move) (eq (fighter-move f) from)) (eq (fighter-state f) :idle))
         (gethash (getf (mv-params from) :kikon-strike) (kit-moves (fighter-kit f))))))

(defun core-wave-follow! (att strike)
  "A wave's hit held (CORE-WAVE-STRIKE): ATT flash-steps in after the knocked-back victim and STRIKE is the follow-up (phase
:follow, set by APPLY-HIT; CORE-FOLLOW-STEP), its hit the Kikon. The SP pointer stays the wave's segment's."
  (start-move att strike :quick))

(defun core-kikon-cancel! (victim f)
  "The victim (VICTIM, fighter F) attacked while the Kikon's follow-up was coming (not red): it is cancelled, both bounce to neutral."
  (let ((o (fighter-opp f)))
    (clog "~a cancels the Kikon follow-up" (side-name victim))
    (hitstop *hitstop-block*)
    (slowmo *core-clash-slowmo-scale* *core-clash-slowmo-seconds*)
    (let ((p (pos-of victim)) (q (pos-of o))) (emit :clash (* 0.5 (+ (aref p 0) (aref q 0))) 1.2 (* 0.5 (+ (aref p 2) (aref q 2)))))
    (core-bounce! victim o)))

(defun core-on-hit! (att def mv)
  "What a landed hit of a core AS does besides damage (its :params): :steal-fs takes flash-step from DEF and gives it to ATT.
(Its Reiatsu steal went with the Reiatsu gauge, 2026-10-27: no SP spends it.)"
  (let ((fs (getf (mv-params mv) :steal-fs)))
    (when (and fs (plusp fs))
      (let ((take (f32 (min fs (gauges-fs (gauges def))))))
        (setf (gauges-fs (gauges def)) (f32 (- (gauges-fs (gauges def)) take)))
        (setf (gauges-fs (gauges att)) (f32 (min 100f0 (+ (gauges-fs (gauges att)) take))))))))

(defun core-konpaku-result (konpaku att soul-break)
  "Konpaku left / lost / ko-p after a Kikon or a Soul Break by ATT (a fighter of a core kit): a Kikon takes what CORE-SET-KIKON-N! fixed
when its SP struck, a Soul Break CORE-SOUL-BREAK-COUNT in the style of the SP in play (the pointer, else the SP that killed him: the
attacker's current pointer)."
  (let* ((f (fighter att)) (base (kit-kikon-konpaku (fighter-kit f)))
         (ptr (if (member (fighter-cls f) '(:ns :as)) (fighter-sp-ptr f) (fighter-ptr f)))
         (lost (min konpaku (if soul-break (core-soul-break-count base ptr) (fighter-kikon-n f)))))
    (values (- konpaku lost) lost (<= (- konpaku lost) 0))))
