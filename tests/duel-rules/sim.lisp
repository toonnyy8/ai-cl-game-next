(in-package :duel)

;; Hisagi's shared hooks 5 and 7 (docs/duel/DUEL_HISAGI.md §17.4, batch B1b): the bind's readers and P's :p hook, each
;; default off. combat / fighter / flow are loaded here over stand-in entities (a struct holding the fighter and gauges
;; components) with stubs for the engine's entity check, events, log and cinematics; nothing else of theirs is run.
(load (merge-pathnames "../../engine/lisp/touch.lisp" *load-truename*))
(dolist (f '("components" "gauges" "combat" "round" "core-sim" "fighter" "practice" "flow"))
  (load (merge-pathnames (format nil "../../duel/lisp/~a.lisp" f) *load-truename*)))
(defstruct (tent (:constructor tent (f g))) f g)
(defun fighter (e) (tent-f e))
(defun gauges (e) (tent-g e))
(defun brain (e) (declare (ignore e)) nil)
(defun entity-alive-p (e) (tent-p e))
(defvar *t-events* nil)
(defun emit (&rest r) (push r *t-events*))
(defun log-msg (&rest r) (declare (ignore r)) nil)
(defun start-cine (&rest r) (push (cons :cine r) *t-events*))
(defun t-pair (ka kb)
  "Two stand-in fighters in kits KA (P1) and KB (P2), facing each other; *P1* / *P2*."
  (let ((a (tent (make-fighter :kit ka :side 0) (make-gauges))) (b (tent (make-fighter :kit kb :side 1) (make-gauges))))
    (setf (fighter-opp (fighter a)) b (fighter-opp (fighter b)) a *p1* a *p2* b *soul-breaks* nil)
    (values a b)))
(defparameter *bind-hooks* '(:bind :bind-damage :bind-heal :bind-step :bind-resolve :bind-snapshot :p :p-label))   ; (:bind-pool, the shared
;; Reiatsu, left with the gauge, 2026-11-13, REFACTOR_2026-11 R6)
;; inert: no kit but Hisagi's Bankai (B2b) holds a bind hook or :p (Kenpachi's Shikai keeps P in his run through the kit key
;; :RUN-AWAKEN since R11, not a :p hook); every reader then does what the old code did
(check (loop for c being the hash-keys of *kits* using (hash-value alist)
             never (loop for (f . k) in alist
                         thereis (and (not (and (eq c :hisagi) (member f '(:bankai :bankai-bind))))
                                      (some (lambda (h) (kit-hook k h))
                                            *bind-hooks*)))))
(check (and (member :awaken *run-commands-p*) (not (member :awaken *run-commands*))
            (equal (rest *run-commands-p*) *run-commands*)))
(multiple-value-bind (a b) (t-pair (kit :ichigo :base) (kit :kenpachi :base))
  (let ((ga (gauges a)) (gb (gauges b)))
    (check (and (null (bind-of a)) (null (bind-of b))))
    (setf (gauges-reishi ga) 1200)
    (heal! a 500)
    (check (= (gauges-reishi ga) (gauges-reishi-max ga)))
    (check (and (null (bind-snapshot-of a)) (= (bind-grey-frac a) 0f0) (= (bind-grey-souls a) 0)))
    (setf (gauges-reishi ga) 5)
    (check (deal-damage b a 7))                                   ; Reishi 0: the Soul Break, queued
    (check (equal *soul-breaks* (list (cons b a))))
    (check (and (= (gauges-dealt gb) 7) (= (dealt-real b) 7) (= (gauges-grey gb) 0)))
    (setf (gauges-konpaku ga) 2 (fighter-kikon-n (fighter b)) 3)
    (check (settle-konpaku b a nil))                              ; out of Konpaku: the K.O.
    (setf (gauges-awakened ga) t)
    (check (null (try-command a (fighter a) :awaken)))            ; awakened, no :p: P does nothing (as before)
    (bind-step! a :hits) (bind-step! a :release) (bind-resolve! a) ; (no binder: nothing called)
    (check (null (bind-of a)))))
;; ... and with a dummy binder (its kit holds the hooks; the bind's state lives here, as in Hisagi's file; its pool, once the two
;; fighters' Reiatsu, is a plain number since the gauge left, R6)
(defvar *tb-on* nil) (defvar *tb-pool* 0f0) (defvar *tb-snap* nil) (defvar *tb-log* nil) (defvar *tb-release* nil)
(defun tb-bind (x) (and *tb-on* (eq (kit-of x) (kit :t-bind :t-binder))))
(defun tb-damage (b a d n) (declare (ignore b a d)) (setf *tb-pool* (f32 (max 0.0 (- *tb-pool* (* 0.5 n))))))   ; 1 per 2
(defun tb-heal (b e n) (declare (ignore b))
  (let ((s (assoc e *tb-snap*))) (setf (second s) (min (gauges-reishi-max (gauges e)) (+ (second s) n)))))
(defun tb-snapshot (b e) (declare (ignore b)) (let ((s (assoc e *tb-snap*))) (values (second s) (third s))))
(defun tb-start (b)
  (let ((o (opp-of b)))
    (setf *tb-snap* (mapcar (lambda (x) (list x (gauges-reishi (gauges x)) (gauges-konpaku (gauges x)))) (list b o))
          *tb-pool* 400f0 *tb-on* t *tb-log* nil)))
(defun tb-step (b phase)
  (push phase *tb-log*)
  (let ((o (opp-of b)))
    (cond ((and (eq phase :release) *tb-release*)                 ; B8: the snapshot back
           (setf *tb-on* nil *tb-release* nil)
           (dolist (s *tb-snap*) (setf (gauges-reishi (gauges (first s))) (second s) (gauges-konpaku (gauges (first s))) (third s))))
          ((and (eq phase :hits) (<= *tb-pool* 0))                ; B7: the grey turns real, his Soul Break queued first
           (setf *tb-on* nil)
           (dolist (x (list o b)) (when (soul-break-p (gauges-reishi (gauges x))) (queue-soul-break! (opp-of x) x)))))))
(defun tb-resolve (b)                                             ; B10: drained, the Soul Breaks counted, no cinematic
  (setf *tb-pool* 0f0)
  (tb-step b :hits)
  (loop for (att . def) in (reverse *soul-breaks*) do (settle-konpaku att def t))
  (setf *soul-breaks* nil))
(defvar *tp-call* nil)
(defun tp (e free) (setf *tp-call* (list e free)) t)
(defun tp-label (e) (declare (ignore e)) (if *tb-on* "FREE" "BIND"))
(register-kit :t-bind :t-binder '(:hooks (:bind tb-bind :bind-damage tb-damage :bind-heal tb-heal
                                          :bind-step tb-step :bind-resolve tb-resolve :bind-snapshot tb-snapshot
                                          :p tp :p-label tp-label)))
(check (not (member :t-bind *roster*)))
(multiple-value-bind (a b) (t-pair (kit :ichigo :base) (kit :t-bind :t-binder))   ; B binds A (Ichigo)
  (let ((ga (gauges a)) (gb (gauges b)))
    (setf (gauges-reishi ga) 1000 (gauges-konpaku ga) 9)
    (check (null (bind-of a)))
    (tb-start b)
    (check (and (eq (bind-of a) b) (eq (bind-of b) b)))           ; either side: the binder
    ;; the drain: 1 per 2 (nominal) damage, exact on odd damage; grey Reishi floors at 0 with no Soul Break
    (check (null (deal-damage b a 7)))
    (check (= *tb-pool* 396.5f0))
    (check (and (= (gauges-reishi ga) 993) (= (gauges-grey gb) 7) (= (dealt-real b) 0) (= (gauges-dealt gb) 7)))
    (check (null (deal-damage b a 2000)))                          ; past 0: grey, no Soul Break queued
    (check (and (= (gauges-reishi ga) 0) (null *soul-breaks*) (= *tb-pool* 0f0)))
    (setf *tb-pool* 396.5f0)
    ;; flash-step still paid in a bind (its Reiatsu gains were frozen there until the gauge left, R6)
    (setf (gauges-fs ga) 50f0)
    (pay-gauges a 10.0)
    (check (= (gauges-fs ga) 60f0))
    ;; S1 / Q18: the Kikon bar and a steal's gain are PAY-GAUGES gains, so nothing during a burst; a steal's victim loses through SPEND-FS
    (setf (gauges-burst ga) :white)
    (pay-gauges a *kikon-fs-refund*) (pay-gauges a 50.0)
    (check (= (gauges-fs ga) 60f0))
    (setf (gauges-burst ga) nil)
    (pay-gauges a *kikon-fs-refund*)
    (check (= (gauges-fs ga) 165f0))
    (spend-fs ga 30.0)
    (check (and (= (gauges-fs ga) 135f0) (= (gauges-fs-idle ga) 0)))
    ;; S2 / Q18: a refund returns exactly what was paid, capped at the maximum, also in a burst, no SUBLIMATION factor, the regen's wait untouched
    (setf (gauges-fs-idle ga) 17 (gauges-burst ga) :orange (gauges-sub ga) *sub-max*)
    (refund-fs ga 40.0)
    (check (and (= (gauges-fs ga) 175f0) (= (gauges-fs-idle ga) 17)))
    (refund-fs ga 200.0)
    (check (= (gauges-fs ga) *fs-max*))
    (setf (gauges-burst ga) nil (gauges-sub ga) 0f0 (gauges-fs ga) 135f0)
    (setf (gauges-fs ga) 60f0)
    ;; a real heal raises the snapshot too; the grey band and souls read the snapshot
    (setf (gauges-reishi ga) 0 (second (assoc a *tb-snap*)) 1000)
    (heal! a 100)
    (check (and (= (gauges-reishi ga) 100) (= (second (assoc a *tb-snap*)) 1100)))
    (check (and (= (bind-grey-frac a) (f32 (/ 1100 (float (gauges-reishi-max ga))))) (= (bind-grey-souls a) 9)))
    ;; a Kikon inside plays: the Konpaku (grey) floors at 0, never a K.O.
    (setf (gauges-konpaku ga) 2 (fighter-kikon-n (fighter b)) 3)
    (check (null (settle-konpaku b a nil)))
    (check (and (= (gauges-konpaku ga) 0) (= (gauges-reishi ga) (gauges-reishi-max ga)) (= (bind-grey-souls a) 9)))
    ;; :p takes P (with the awakening's free test) once nothing else does
    (setf (gauges-awakened gb) t (gauges-awaken ga) 0f0)
    (check (and (try-command b (fighter b) :awaken) (eq (first *tp-call*) b) (second *tp-call*)))   ; (free: idle)
    (setf (fighter-state (fighter b)) :stun (fighter-combo-hits (fighter b)) 1)
    (check (and (try-command b (fighter b) :awaken) (null (second *tp-call*))))   ; in a combo before its 2nd hit: not free
    (setf (fighter-state (fighter b)) :idle (fighter-combo-hits (fighter b)) 0)
    (check (null (try-command a (fighter a) :awaken)))             ; (his own kit has no :p)
    ;; the release (where a Burst is applied): the snapshot back
    (setf *tb-release* t *tb-pool* 450f0)
    (bind-step! a :release)
    (check (and (null (bind-of a)) (= (gauges-reishi ga) 1100) (= (gauges-konpaku ga) 9)))
    ;; the drained end (after the step's hits, before SETTLE-SOULS): both at 0 Reishi, the opponent's Soul Break first
    (tb-start b)
    (setf (gauges-reishi ga) 1 (gauges-reishi gb) 1 *tb-pool* 2f0)
    (check (and (null (deal-damage b a 3)) (null (deal-damage a b 1))))
    (check (and (= *tb-pool* 0f0) (null *soul-breaks*)))
    (bind-step! a :hits)
    (check (and (null (bind-of a)) (equal (reverse *soul-breaks*) (list (cons b a) (cons a b)))))
    (setf (gauges-konpaku ga) 1 (fighter-kikon-n (fighter b)) 2)
    (check (settle-konpaku b a t))                                 ; unbound again: a K.O. is a K.O.
    ;; time-up during a bind: drained first, then the winner (A led 3 to 2 on the grey values)
    (tb-start b)
    (setf (gauges-konpaku ga) 3 (gauges-reishi ga) 0 (gauges-konpaku gb) 2 (gauges-reishi gb) 1300 *soul-breaks* nil)
    (check (eql 0 (time-up-winner 3 0 1300 2 1300 1300)))
    (time-up)
    (check (and (null (bind-of a)) (= (gauges-konpaku ga) 0) (eql *winner* 1)))))


;; 2026-10-24 (the user: 「只要被 O 打中，非紅血狀態就鎖定防禦以外的一切行為（此狀態可防禦取消硬直並擋下毀魂技），紅血狀態則連同
;; 防禦都鎖定」): the Kikon lock. Its holder (KIKON-LOCK-HOLDS-P) is the rusher's follow-up; in the reel, lock 1 (not red)
;; U cancels it into a guard, lock 2 (red) nothing does, and no Burst / awakening is read under either
;; 2026-10-27 (the core system, docs/duel/DUEL_CORE.md; the user 「用攻擊抵銷毀魂技並彈開雙方回到中立狀態」, 「沒必要其他手段，只留攻擊抵銷」):
;; in the reel, lock 1 (not red) an ATTACK cancels the follow-up (CORE-KICKON-CANCEL!: both bounce to neutral; U no longer exists),
;; lock 2 (red) nothing does, and no Burst / awakening is read under either
(multiple-value-bind (a b) (t-pair (kit :ichigo :base) (kit :kenpachi :base))
  (let* ((fa (fighter a)) (fb (fighter b)) (held nil) (cancelled nil)
         (og (fdefinition 'vpad-command-pressed-p)) (oc (fdefinition 'play-clip)) (ok (fdefinition 'core-kikon-cancel!))
         (ov (fdefinition 'vpad-consume!)))
    (setf (fdefinition 'vpad-command-pressed-p) (lambda (vp button mod) (declare (ignore vp button mod)) held)
          (fdefinition 'vpad-consume!) (lambda (&rest r) (declare (ignore r)) nil)
          (fdefinition 'core-kikon-cancel!) (lambda (e f) (declare (ignore e f)) (setf cancelled t))
          (fdefinition 'play-clip) (lambda (&rest r) (declare (ignore r)) nil))
    (unwind-protect
         (flet ((reel (lock) (setf (fighter-state fb) :stun (fighter-stun fb) 40 (fighter-sf fb) 0 (fighter-kikon-lock fb) lock cancelled nil)))
           (setf (fighter-state fa) :move (fighter-move fa) (kit-command-move (kit :ichigo :base) :kikon)
                 (fighter-follow fa) t (fighter-phase fa) :follow)
           (check (kikon-lock-holds-p fb))
           (setf (fighter-phase fa) :main (fighter-sf fa) 0 (fighter-contact fa) :hit)
           (check (not (kikon-lock-holds-p fb)))                                    ; (the strike connected)
           (setf (fighter-contact fa) nil (fighter-follow fa) nil)
           (check (not (kikon-lock-holds-p fb)))                                    ; (not a follow-up)
           (reel 1) (setf held t) (stun-step b fb nil)
           (check cancelled)                                                       ; (not red: an attack cancels the reel)
           (reel 2) (stun-step b fb nil)
           (check (and (not cancelled) (eq :stun (fighter-state fb)) (= 1 (fighter-sf fb))))   ; (red: nothing does)
           (reel 1) (setf held nil) (stun-step b fb nil)
           (check (and (not cancelled) (eq :stun (fighter-state fb)) (= 1 (fighter-sf fb)))))   ; (no attack: he reels on)
      (setf (fdefinition 'vpad-command-pressed-p) og (fdefinition 'vpad-consume!) ov
            (fdefinition 'core-kikon-cancel!) ok (fdefinition 'play-clip) oc))))

;; 2026-11-12 (the user: 「相消不該有所謂的攻擊方與受擊方，是一個平等的狀態」, DUEL_CORE §2.1): CORE-NOHIT!'s :cancel counts as landed for both
;; fighters. Kenpachi's NS1 hit, judged, lands on Hisagi in his ranged J1's startup (his dead zone: J1 has no hit of its own); both get
;; contact :hit, Kenpachi's land frame his hit frame, Hisagi's his J1's first hit frame (not before); a defender out of his classed
;; window gets nothing; a same-class tie sets both before the bounce
(multiple-value-bind (a b) (t-pair (kit :kenpachi :base) (kit :hisagi :bankai))
  (let* ((fa (fighter a)) (fb (fighter b)) (bounced nil) (names '(pos-of hitstop slowmo core-clash! core-bounce!))
         (old (mapcar (lambda (n) (and (fboundp n) (fdefinition n))) names))
         (ns (kit-core-move (kit :kenpachi :base) :ns 1)) (j1 (kit-move (kit :hisagi :bankai) :hs-r-j1))
         (kj1 (kit-command-move (kit :kenpachi :base) :q)))
    (setf (fdefinition 'pos-of) (lambda (e) (declare (ignore e)) (make-array 3 :initial-element 0f0))
          (fdefinition 'hitstop) (lambda (&rest r) (declare (ignore r)) nil)
          (fdefinition 'slowmo) (lambda (&rest r) (declare (ignore r)) nil)
          (fdefinition 'core-clash!) (lambda (&rest r) (declare (ignore r)) nil)
          (fdefinition 'core-bounce!) (lambda (x y) (setf bounced (list (fighter-contact (fighter x)) (fighter-contact (fighter y))))))
    (unwind-protect
         (flet ((in (f mv cls sf) (setf (fighter-state f) :move (fighter-phase f) :main (fighter-move f) mv (fighter-cls f) cls
                                        (fighter-sf f) sf (fighter-contact f) nil (fighter-land-sf f) -1))
                (cancel () (core-nohit! (make-pending :att a :def b :mv (fighter-move fa)) :cancel)))
           (in fa ns :ns (mv-first-hit ns)) (in fb j1 :na 5)
           (cancel)
           (check (and (eq (fighter-contact fa) :hit) (= (fighter-land-sf fa) (mv-first-hit ns))))
           (check (and (eq (fighter-contact fb) :hit) (= (fighter-land-sf fb) (mv-first-hit j1)) (> (mv-first-hit j1) 5)))
           (check (null bounced))                                                  ; (cross-class: both go on)
           ;; DUEL_CORE §2.1.2 (the user, 2026-11-14: 「在相消的過程不該能進行閃步」): the cancel's exchange, on both, bars the Hoho for
           ;; both until it ends; a press is refused and eaten (no buffered Hoho fires the step it ends)
           (let* ((eaten nil) (ns '(vpad-consume! pilot pilot-vpad)) (os (mapcar (lambda (n) (and (fboundp n) (fdefinition n))) ns)))
             (setf (fdefinition 'vpad-consume!) (lambda (vp btn) (declare (ignore vp)) (push btn eaten))
                   (fdefinition 'pilot) (lambda (e) e) (fdefinition 'pilot-vpad) (lambda (p) p))
             (unwind-protect
                  (progn
                    (setf (gauges-fs (gauges a)) *fs-max* (gauges-fs (gauges b)) *fs-max*)
                    (check (and (>= (fighter-xch fa) 0) (= (fighter-xch fa) (fighter-xch fb))))
                    (check (not (or (hoho-ready-p a) (hoho-ready-p b))))
                    (check (and (null (try-command b fb :hoho :step)) (eq (fighter-state fb) :move) (equal eaten '(:step))))
                    (check (and (null (try-command a fa :hoho :step)) (eq (fighter-state fa) :move)))
                    (setf (fighter-xch fa) -1 (fighter-xch fb) -1)                   ; (the exchange over: CORE-XCH-STEP)
                    (check (and (hoho-ready-p a) (hoho-ready-p b))))
               (loop for n in ns for o in os do (if o (setf (fdefinition n) o) (fmakunbound n)))))
           (in fa ns :ns (mv-first-hit ns)) (in fb j1 :na (+ (mv-s j1) (mv-a j1)))   ; (he is in his recovery: no cancel for him)
           (cancel)
           (check (and (eq (fighter-contact fa) :hit) (null (fighter-contact fb)) (= (fighter-land-sf fb) -1)))
           (setf (fighter-kit fb) (kit :kenpachi :base))                            ; a same-class tie (J1 x J1): both landed, then the bounce
           (in fa kj1 :na (mv-first-hit kj1)) (in fb kj1 :na (mv-first-hit kj1))
           (cancel)
           (check (equal bounced '(:hit :hit))))
      (loop for n in names for f in old do (if f (setf (fdefinition n) f) (fmakunbound n))))))
