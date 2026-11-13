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
    (unless (eq cls :ns) (setf (fighter-tmp f) 0 (fighter-csa f) nil))   ; a temporary pointer lasts the NS route (DUEL_SUBLIMATION §17)
    (when (and (eq cls :ns) (not (eq (kit-class (fighter-kit f) old) :ns))) (setf (fighter-clash-n f) 0))   ; a fresh NS route counts its cancels from 0
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
(defun core-start! (e mv)
  "Start core move MV. T."
  (start-move e mv :quick)
  t)

(defun core-snap-lv! (e f)
  "A new NS route or AS starts: its unlock level is the kit's :lv hook now (Kenpachi's Shikai, DUEL_KEN_V3 §4: its segments' :params :lv;
a level gained in the route opens segments from the next route on). No hook: 99 (no cap). (FIGHTER-LV-GOT is the kit's own: Kenpachi's
:hit hook clears it on a combo's first hit, once a combo since 2026-11-03.)"
  (let ((h (kit-hook (fighter-kit f) :lv)))
    (setf (fighter-lv-cap f) (if h (funcall h e) 99))))

(defun core-seg-ok-p (f mv)
  "Is segment MV open in F's route (its :params :lv at most the level read at the route's start, CORE-SNAP-LV!)? A move without one: T."
  (<= (getf (mv-params mv) :lv 0) (fighter-lv-cap f)))

(defun core-sp-start! (e f)
  "SP from a free state: NS under the pointer (the next segment pointer's style). T when it started."
  (let ((mv (kit-core-move (fighter-kit f) :ns (fighter-ptr f))))
    (when mv
      (setf (fighter-sp-ptr f) (fighter-ptr f) (fighter-tmp f) 0 (fighter-csa f) nil)
      (core-snap-lv! e f)
      (core-start! e mv))))

(defun core-next-as (f)
  "The AS an SP pressed now would start in F's combo: the one the move he is in names (its :params :as-ptr: Hisagi's gathered
route, DUEL_HISAGI §28.20: SA > AS1, J2 > AS2, J3 > AS3), else the attack presses' (CORE-AS-POINTER, the kit's :as-by-press)."
  (let* ((mv (fighter-move f)) (core (kit-core (fighter-kit f)))
         (n (or (and mv (getf (mv-params mv) :as-ptr))
                (core-as-pointer (fighter-presses f) (getf core :as-by-press)))))
    (setf n (min n (max 1 (length (getf core :as)))))                  ; (no AS of that number in this kit: the last it has)
    n))

(defun core-as-start! (e f)
  "SP after an attack hit: the AS of the attack press count, writing the pointer. Its Kikon (cinematic, Konpaku profile) is the
pointer before the write (the user, 2026-11-07: 「幫我將觸發的毀魂技改回【AS 改變指針前指向的毀魂技】」, DUEL_CORE §4 / DEVLOG §615;
2026-10-28 to 2026-11-07: the pointer it writes). A kit's :core :as-writes (one entry per AS, NIL: none) may leave the pointer as it
is (Hisagi's Bankai, DUEL_HISAGI §28.4: AS3 is the mode switch, 「三個 AS 只有兩組指針」). A kit's :as-pick hook (E F N) may name another move and the pointer it writes (NIL: kept), or :TAKEN (it did the press
itself), else NIL (Kenpachi's Shikai: the burst, the special AS, the Bankai; DUEL_KEN_V3 §4)."
  (core-snap-lv! e f)
  (let* ((writes (getf (kit-core (fighter-kit f)) :as-writes '(1 2 3)))
         (n (core-next-as f)) (h (kit-hook (fighter-kit f) :as-pick)))
    (multiple-value-bind (pm pw) (and h (funcall h e f n))
      (when (eq pm :taken) (setf (fighter-as-done f) t) (return-from core-as-start! t))
      (let ((mv (or pm (kit-core-move (fighter-kit f) :as n)))
            (w (if pm pw (nth (1- n) writes))))
        (when mv
          (setf (fighter-sp-ptr f) (fighter-ptr f))
          (core-start! e mv)
          (setf (fighter-ptr f) (or w (fighter-ptr f)) (fighter-as-done f) t)
          (if w (clog "~a AS~d pointer ~d" (side-name e) n w) (clog "~a AS~d pointer kept ~d" (side-name e) n (fighter-ptr f)))
          t)))))

(defun core-move-sp! (e f vp mv sf button)
  "SP pressed inside move MV at frame SF (MOVE-COMMANDS): AS off a landed attack (an NA link or the SA; the hit or a cancel),
or the next NS / AS segment (2026-10-27: AS n has n segments, 「每段再按 SP」), latched until the segment's active frames are over.
T when something started."
  (declare (ignore sf))
  (case (fighter-cls f)
    ((:na :sa) (and (eq (fighter-contact f) :hit) (not (fighter-as-done f))
                    (cancel-open-p (fighter-sf f) (fighter-land-sf f) (mv-total mv) t)
                    (core-as-start! e f)))
;; stick left / right + SP in an NS gap (a human, awakened, DRIVE >= *DRIVE-SWITCH*, not already switched): the first segment of
    ;; the previous / next pointer's NS, latched like a next segment (DUEL_SUBLIMATION §17)
    ((:ns :as) (let ((to (and (eq (fighter-cls f) :ns) (core-switch-target e f))))
           (cond (to (setf (fighter-queued f) :sw (fighter-sw f) to)
                     (vpad-consume! vp button))
                 ((let ((nx (mv-ns-next (fighter-kit f) mv))) (and nx (core-seg-ok-p f nx)))   ; (a segment above the route's level: none)
                  (setf (fighter-queued f) :ns)
                  (vpad-consume! vp button))))
         nil)))

(defun core-switch-open-p (e f)
  "The switch's own rules (DUEL_SUBLIMATION §17): not already switched, a second pointer, and DRIVE (awakened) or SUBLIMATION (before) of
at least *DRIVE-SWITCH* x its maximum."
  (let ((g (gauges e)))
    (and (zerop (fighter-tmp f)) (> (length (getf (kit-core (fighter-kit f)) :ns)) 1)
         (if (gauges-awakened g)
             (>= (gauges-drive g) (* *drive-max* *drive-switch*))
             (>= (gauges-sub g) (* *sub-max* *drive-switch*))))))   ; (before the awakening only SUBLIMATION is spent, DUEL_SUBLIMATION §17.6)

(defun core-switch-ready-p (e f)
  "Can E switch pointer now (DUEL_SUBLIMATION §17): a human, or a CPU whose press in progress is a strategy's switch (its act :SWITCH,
core-ai.lisp CAI-SWITCH-PRESS; DUEL_AI_STRATEGY §8.16: the shipped CPU never presses one), and CORE-SWITCH-OPEN-P."
  (let ((b (brain e)))
    (and (or (not b) (eq (brain-act b) :switch)) (core-switch-open-p e f))))

(defun core-switch-target (e f)
  "The pointer a stick left (previous) / right (next, cyclic) + SP in an NS gap switches to, or NIL: the CPU never, once a route, gauge
under *DRIVE-SWITCH* x B, or no other pointer (DUEL_SUBLIMATION §17)."
  (let* ((n (length (getf (kit-core (fighter-kit f)) :ns))))
    (when (core-switch-ready-p e f)
      (let ((st (nth-value 1 (stick-relative e f))))
        (when (> (abs st) 0.5f0)
          (let ((to (1+ (mod (+ (1- (fighter-ptr f)) (if (> st 0f0) 1 -1)) n))))
            (and (/= to (fighter-ptr f)) (kit-core-move (fighter-kit f) :ns to) to)))))))

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
    (when (and (member q '(:ns :sa :sw)) (>= sf (+ (mv-s mv) (mv-a mv))) (< sf (mv-total mv)))
      (setf (fighter-queued f) nil)
      (when (eq q :sw)                                  ; the temporary pointer: its NS route from segment 1, DRIVE paid
        (let ((to (fighter-sw f)) (g (gauges e)))
          (if (gauges-awakened g) (decf (gauges-drive g) (* *drive-max* *drive-switch*)) (decf (gauges-sub g) (* *sub-max* *drive-switch*)))
          (let ((sa (mv-sa-move (fighter-kit f) mv)))   ; a charge on the segment he leaves stays for his next SA
            (when (and sa (getf (mv-params sa) :charge-mult)) (setf (fighter-csa f) sa)))
          (setf (fighter-sp-ptr f) to)
          (start-move e (kit-core-move (fighter-kit f) :ns to) :quick)
          (setf (fighter-tmp f) to)                     ; (after START-MOVE, which clears it for a non-NS)
          (clog "~a NS pointer ~d -> ~d (DRIVE)" (side-name e) (fighter-ptr f) to)
          (return-from core-latch-step t)))
      (let ((next (if (eq q :ns) (mv-ns-next (fighter-kit f) mv) (or (fighter-csa f) (mv-sa-move (fighter-kit f) mv) (kit-sa-move (fighter-kit f))))))
        (when (and next (or (not (eq q :ns)) (core-seg-ok-p f next))) (core-start! e next))))))

;;; ---------------------------------------------------------------- judging a step's hits
(defun core-verdicts (hits)
  "The triangle's verdict on each pending hit of this step, all judged against the states they were collected in (so a pair of
simultaneous hits is seen as a pair): a list of :hit / :cancel / :absorb in HITS' order. A hazard's hit, a hit of a move with no
class, or on a defender outside a classed window is a clean hit; a hit on a defender in a parry's window (:parry) skips the
triangle, so the parry catches it (COMBAT :parried)."
  (loop for h in hits
        collect (let* ((mv (pending-mv h)) (att (pending-att h)) (def (pending-def h))
                       (fa (fighter att)) (fd (fighter def))
                       (ca (and mv (not (pending-hazard h)) (eq mv (fighter-move fa)) (fighter-cls fa)))
                       (cd (core-window-class fd)))
                  (if (and ca cd (not (eq (pending-state h) :parry)))   ; a parry's window catches first (Kenpachi's tame, DUEL_KEN_V3 §35.1)
                      (core-verdict ca cd
                                    :simul (loop for h2 in hits thereis (and (eq (pending-att h2) def) (eq (pending-def h2) att)
                                                                             (pending-mv h2) (not (pending-hazard h2))))
                                    :att-t (fighter-cls-t fa) :def-t (fighter-cls-t fd))
                      :hit))))

(defun core-nohit! (h verdict)
  "Apply a :cancel or :absorb verdict of pending hit H: no damage. A cancel counts as landed for both fighters, the one whose hit
was judged and the one in whose classed window it was (the user, 2026-11-12: 「相消不該有所謂的攻擊方與受擊方，是一個平等的狀態」,
DUEL_CORE §2.1): each one's chain, cancels and AS open (contact :hit, CORE-CANCEL-LAND-SF), the other side only while he is still in
a classed move's startup / active frames; a same-class tie also ends both moves and bounces the fighters apart; an absorb is a block
for the attacker."
  (let* ((att (pending-att h)) (def (pending-def h)) (fa (fighter att)) (fd (fighter def))
         (p (pos-of att)) (q (pos-of def)) (mx (* 0.5 (+ (aref p 0) (aref q 0)))) (mz (* 0.5 (+ (aref p 2) (aref q 2)))))
    (when (and (eq (fighter-state fa) :move) (eq (pending-mv h) (fighter-move fa)))
      (ecase verdict
        (:cancel
         (flet ((landed! (f)
                  (setf (fighter-contact f) :hit
                        (fighter-land-sf f) (core-cancel-land-sf (fighter-land-sf f) (fighter-sf f) (mv-first-hit (fighter-move f))))))
           (landed! fa)
           (when (core-window-class fd) (landed! fd)))   ; (re-read: an earlier hit this step may have moved him)
         (hitstop *hitstop-block*)
         (slowmo *core-clash-slowmo-scale* *core-clash-slowmo-seconds*)
         (emit :clash mx 1.2 mz)
         (clog "~a ~a x ~a: CANCEL" (side-name att) (mv-name (pending-mv h)) (side-name def))
         (core-clash! att def)
         (when (and (eq (fighter-cls fa) (core-window-class fd)) (eq (fighter-state fd) :move))   ; a same-class tie: both to neutral
           (core-bounce! att def)))
        (:absorb
         (setf (fighter-contact fa) (or (fighter-contact fa) :block))
         (hitstop *hitstop-block*)
         (emit :armored def mx 1.2 mz)
         (clog "~a ~a x ~a: ABSORBED" (side-name att) (mv-name (pending-mv h)) (side-name def)))))))

(defun core-clash! (a b)
  "A clash between A and B (攻擊抵銷: a triangle cancel, CORE-NOHIT!, or a cancelled Kikon follow-up, CORE-KIKON-CANCEL!): each
side's kit :clash hook (x other), once a step for the pair however many cancel verdicts the step had (a same-class tie gives two;
Hisagi's bind evens the Reishi once a clash, DUEL_HISAGI §28.4). No kit with the hook: nothing."
  (let ((fa (fighter a)) (fb (fighter b)))
    (unless (or (= (fighter-clash-t fa) *match-tick*) (= (fighter-clash-t fb) *match-tick*))
      (setf (fighter-clash-t fa) *match-tick* (fighter-clash-t fb) *match-tick*)
      (dolist (x (list a b))
        (let ((h (kit-hook (kit-of x) :clash))) (when h (funcall h x (opp-of x))))))))

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
  "Is MV (a move of F's kit) an SP that holds into the Kikon (an NS or an AS of a kit with a :core)? Not a segment with :params
:no-kikon (Hisagi's Bankai AS3, the mode switch: DUEL_HISAGI §28.4)."
  (and mv (member (kit-class (fighter-kit f) mv) '(:ns :as)) (not (getf (mv-params mv) :no-kikon)) t))

(defun core-hold-step (e f)
  "Each step inside an NS / AS segment: a let-go of the SP button clears the hold (FIGHTER-SP-HELD), so only a hold kept from
the segment's start to its hit is a Kikon; a mashed SP that is down on the hit frame is not (the user, 2026-10-27: 「我是要求『按住』才發動，
但目前連打也會觸發」). On the phone the SP is a tap, fired on the lift, so the segment starts :REARM: the hold is a new touch after it,
kept down to the hit (the user, 2026-10-28: 「實際在觸控時的判斷應該改為『打中後是否有再次點擊並長按 SP』」, judged at the hit: 「打中前按下」)."
  (case (fighter-sp-held f)
    ((nil))
    (:rearm (when (core-touch-sp-p) (setf (fighter-sp-held f) t)))
    (t (unless (core-held-p e) (setf (fighter-sp-held f) nil)))))

(defun core-touch-p (f)
  "Is F P1 on the phone's thumb pad (*ONE-HAND*), whose SP is a tap?"
  (and *one-hand* *p1* (eq f (fighter *p1*))))

(defun core-touch-sp-p ()
  "Is a contact down in the pad's SP zone (above the tap split, where it went down: a tap's own test, %GESTURE-LIFT)? The attack's
zone below is not the SP's hold (the user, 2026-10-28: 「程式的毀魂技觸控判定並沒有區分 SP 跟攻擊的差異，所以如果打完 SP 後按住攻擊的區域
也一樣會觸發毀魂技」)."
  (and (touch-active-p *touch*) (touch-hi-at-p *touch* (touch-ox *touch*) (touch-oy *touch*))))   ; (the slanted line since 2026-10-28)

(defun core-held-p (att)
  "Is ATT still holding the SP button (the attack button) this step?"
  (or (vpad-down (pilot-vpad (pilot att)) :quick)
      (and *one-hand* (eq att *p1*) (core-touch-sp-p))))   ; a phone: the thumb back on the SP zone while the SP strikes

(defun core-kikon-cine (att)
  "The cinematic of ATT's Kikon by the pointer of the SP that struck (the kit's :core :kikon-cines, one per pointer; NIL: the kit's own).
KESSA's pointer 3 plays 千影 (the user, 2026-10-28: 「指針三的毀魂技使用之前的「千影」動畫」)."
  (core-pointer-cine att (fighter-sp-ptr (fighter att))))

(defun core-pointer-cine (att ptr)
  "Pointer PTR's Kikon cinematic in ATT's kit (:core :kikon-cines), or NIL."
  (and *core-on* (nth (1- (max 1 (min *core-pointer-max* ptr))) (getf (kit-core (kit-of att)) :kikon-cines))))

(defun core-soul-break-cine (att)
  "The cinematic of ATT's Soul Break (the Reishi at zero): the current pointer's Kikon (the user, 2026-10-28: 「如果是血量歸零自動釋放到
毀魂技，一樣選擇當前指針對應的毀魂技」), else the kit's (KIT-KIKON-CINE)."
  (or (core-pointer-cine att (fighter-ptr (fighter att))) (kit-kikon-cine (kit-of att))))

(defun core-set-kikon-n! (att red)
  "The Konpaku the Kikon about to follow takes: the kit's count in the style of the SP that struck (CORE-KIKON-COUNT)."
  (let ((f (fighter att)))
    (setf (fighter-kikon-n f) (core-kikon-count (kit-kikon-konpaku (fighter-kit f)) (fighter-sp-ptr f) red))))

(defun core-confirm-frames (f mv)
  "Frames of F's dash-in (phase :follow) after his held SP MV's hit that the hold is judged on: *CORE-KIKON-CONFIRM*, on the phone
*CORE-KIKON-CONFIRM-TOUCH* (:DASH = all of KIKON-FOLLOW-WAIT)."
  (if (core-touch-p f)
      (let ((c *core-kikon-confirm-touch*)) (if (eq c :dash) (kikon-follow-wait (mv-s mv)) c))
      *core-kikon-confirm*))

(defun core-kikon-defer (f)
  "Frames after the hitstop a core SP's held hit waits as an ordinary one before the Kikon's knockback and dash-in start
(*CORE-KIKON-CONFIRM*; 0 for an old-style rush): a let-go inside them leaves nothing pushed (the user, 2026-11-04: 「就算沒觸發毀魂技
有時候也會將對手彈開」, asked: 「確認後才擊退」)."
  (if (fighter-kikon-undo f) *core-kikon-confirm* 0))

(defun core-follow-step (e f mv)
  "The Kikon's dash-in after the struck SP (phase :follow): for CORE-KIKON-DEFER frames he stands, the victim in the hit's own
reaction; still held then, the victim is knocked back (CORE-KIKON-KNOCK!) and he chases him for KIKON-FOLLOW-WAIT frames, then the
same strike again; its hit is the Kikon (KIKON-OUTCOME). The hold is judged on for CORE-CONFIRM-FRAMES (the phone: the whole dash):
a let-go drops it (CORE-KIKON-UNDO!)."
  (incf (fighter-hold f))
  (when (and (<= (fighter-hold f) (core-confirm-frames f mv)) (not (core-held-p e)) (fighter-kikon-undo f))
    (clog "~a lets go: no Kikon" (side-name e))
    (return-from core-follow-step (core-kikon-undo! e f)))
  (let ((d (core-kikon-defer f)))
    (cond ((zerop d) (when (= (fighter-hold f) 1) (core-follow-cues e (fighter-opp f))))   ; (a tap is up after the hitstop)
          ((= (fighter-hold f) d) (core-kikon-knock! e f)))
    (let ((v (motion-vel (motion e))) (left (- (+ (kikon-follow-wait (mv-s mv)) d) (fighter-hold f))))
      (fill v 0f0)
      (turn-to-opp e f (track-step 360.0))
      (when (>= (fighter-hold f) d)                     ; (standing until the hold is confirmed)
        (run-velocity e (kikon-follow-speed (fighter-dist f) left (or (getf (mv-params mv) :follow-cap) 22.0))))   ; (a wave's: far)
      (when (<= left 0)
        (setf (fighter-hits f) 0 (fighter-contact f) nil (fighter-land-sf f) -1)
        (enter-main e f mv)))))

(defun core-kikon-knock! (e f)
  "The hold confirmed (CORE-KIKON-DEFER): the victim knocked back into the Kikon's reel, the dash-in's cues."
  (destructuring-bind (def r ostun sx sz kb wave kreact kstun) (fighter-kikon-undo f)
    (declare (ignore r ostun kb wave))
    (set-reaction def kreact kstun sx sz *kikon-follow-kb*)
    (core-follow-cues e def)))

(defun core-follow-cues (att def)
  "The Kikon follow-up's cues: the KIKON call-out and the dash-in's take-off (cosmetic)."
  (emit :kikon-follow att def)
  (emit :rush-dash att))

(defun core-kikon-undo! (e f)
  "A let-go inside the confirm (CORE-FOLLOW-STEP): the held SP's hit was an ordinary one after all (FIGHTER-KIKON-UNDO, kept by
APPLY-HIT): the victim in that hit's own reaction (inside CORE-KIKON-DEFER he never left it; after it, the phone's late let-go,
set back with the frames he already reeled taken off), and E back in his move where it hit, so its string goes on (a wave's
strike: E free again). A tap still down on a quick hit (AS3's SOSEN-GIRI, startup 8) is released in the hitstop, so this comes on
the dash-in's first frame (the user, 2026-10-28: 「常態的 AS3 不知為何非常容易誤觸出毀魂技」)."
  (destructuring-bind (def react stun sx sz kb wave &rest kikon) (fighter-kikon-undo f)
    (declare (ignore kikon))
    (let ((knocked (or (> (fighter-hold f) (core-kikon-defer f))
                       (member react '(:knockdown :launch)))))   ; (held on his feet through the confirm: APPLY-HIT)
      (setf (fighter-follow f) nil (fighter-kikon-undo f) nil (fighter-kikon-lock (fighter def)) 0)
      (fill (motion-vel (motion e)) 0f0)
      (when knocked (set-reaction def react (max 1 (- stun (fighter-hold f))) sx sz kb)))
    (if wave (to-idle e 0) (setf (fighter-phase f) :main))))

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
    (core-clash! victim o)
    (hitstop *hitstop-block*)
    (slowmo *core-clash-slowmo-scale* *core-clash-slowmo-seconds*)
    (let ((p (pos-of victim)) (q (pos-of o))) (emit :clash (* 0.5 (+ (aref p 0) (aref q 0))) 1.2 (* 0.5 (+ (aref p 2) (aref q 2)))))
    (core-bounce! victim o)))

(defun core-on-hit! (att def mv &optional (mult 1.0) hw)
  "What a landed hit of a core AS does besides damage (its :params), at MULT (a KESSA clone's replay: 0.1): :steal-fs (the hit window HW's
own, else the move's) takes flash-step from DEF, never below the last cell (STEAL-TAKE, S1 2026-11-13), and gives *STEAL-FS-GAIN* of it to ATT
(PAY-GAUGES: nothing in ATT's burst; DUEL_SP Q18). (Its Reiatsu steal
went with the Reiatsu gauge, 2026-10-27: no SP spends it.)"
  (let ((fs (or (and hw (hw-steal hw)) (getf (mv-params mv) :steal-fs))))
    (when (and fs (plusp fs))
      (multiple-value-bind (take gain) (steal-take (* mult fs) (gauges-fs (gauges def)))
        (when (plusp take) (spend-fs (gauges def) take))   ; (Q18: the victim's loss and the attacker's gain each go through their one writer)
        (pay-gauges att gain)
        (clog "~a STEAL fs ~,1f from ~a, gains ~,1f" (side-name att) take (side-name def) gain)))))

(defun steal-scene-fs! (tag)
  "A steal scene's gauges (debug 83815 / 74908, DUEL_CORE §2.2): P1 flash-step 100 (room to gain 200), P2's full; a `duel steal` line."
  (setf (gauges-fs (gauges *p1*)) 100f0 (gauges-fs (gauges *p2*)) *fs-max*)
  (steal-fs-line tag))

(defun steal-fs-line (tag)
  "Debug 83816 / 74909: a `duel steal` line, both sides' flash-step now."
  (log-msg "duel steal ~a t ~d fs p1 ~,1f p2 ~,1f" tag *match-tick* (gauges-fs (gauges *p1*)) (gauges-fs (gauges *p2*))))

(defun core-konpaku-result (konpaku att soul-break)
  "Konpaku left / lost / ko-p after a Kikon or a Soul Break by ATT (a fighter of a core kit): a Kikon takes what CORE-SET-KIKON-N! fixed
when its SP struck, a Soul Break CORE-SOUL-BREAK-COUNT in the style of the SP in play (the pointer, else the SP that killed him: the
attacker's current pointer)."
  (let* ((f (fighter att)) (base (kit-kikon-konpaku (fighter-kit f)))
         (ptr (if (member (fighter-cls f) '(:ns :as)) (fighter-sp-ptr f) (fighter-ptr f)))
         (lost (min konpaku (if soul-break (core-soul-break-count base ptr) (fighter-kikon-n f)))))
    (values (- konpaku lost) lost (<= (- konpaku lost) 0))))
