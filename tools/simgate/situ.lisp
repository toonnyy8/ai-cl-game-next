;;;; situ.lisp — the KI matchup evaluator's situation observer (docs/duel/DUEL_MATCHUP_AI.md §4; tools/matchup-eval.py). FROZEN with the
;;;; evaluator: a style CPU never reads it. Loaded after the native build; it sets DUEL::*STEP-HOOK* (gate.lisp HASH-LOG calls it once a
;;;; step), reads the state only, and prints one line per situation when it closes:
;;;;   "situ P1 <theme> occ"  or  "situ P1 <theme> ok"   (P1 / P2 = the side the theme belongs to; ok = the situation and its success)
;;;; Themes: Kenpachi brawl shikai bankai antiwave; Ichigo spacing whiff kessa. (Ichigo's pointer-3 theme is read from the combat
;;;; log by matchup-eval.py: the SOUL BREAK and KIKON FOLLOW-UP lines.) Only a Kenpachi-vs-Ichigo battle is observed.
(in-package :duel)

(defstruct (situ-st (:conc-name ss-))
  (tick -1) ken ich (rk 0f0) (ri 0f0) (kk 0) (ki 0)  ; the last tick; the two entities; their Reishi and Konpaku a step ago
  (ken-cls -1) (ich-cls -1)                          ; the cls-t of each one's move seen last
  ex ex-t                                            ; brawl: an open exchange and its start tick
  (form :base) stay stay-ok (lv 0)                   ; Kenpachi's form a step ago; a Shikai stay open, it succeeded; his L
  l3s                                                ; L3 situations: a list of conses (state . nil), state :wait / :in
  aw aw-t aw-wave aw-hit                             ; antiwave: open, start tick, the wave hit him, he hit her
  sp sp-left (ich-d 0f0)                             ; spacing: open, steps left after leaving the band; Ichigo's move start distance
  wf wf-cls wf-t                                     ; whiff: open, the cls-t of his whiffed move, steps of grace left
  (wf-seen -1)                                       ; the cls-t already judged a whiff (once a move)
  kz kz-in (kz-dealt 0f0) (kz-taken 0f0) (kz-full nil))   ; KESSA: the situation open, in KESSA, dealt / taken there, gauge full a step ago

(defvar *situ* (make-situ-st))

(defun situ-say (e theme ok) (log-msg "situ ~a ~(~a~) ~:[occ~;ok~]" (side-name e) theme ok))

(defun situ-flush (st)
  "The match is over: close every open situation (as it stands: an unfinished one is a failure)."
  (let ((k (ss-ken st)) (i (ss-ich st)))
    (when k
      (when (ss-stay st) (situ-say k :shikai (ss-stay-ok st)))
      (dolist (c (ss-l3s st)) (situ-say k :bankai (eq (car c) :out)))   ; (:out: his special AS ended the match, §9)
      (when (ss-aw st) (situ-say k :antiwave (and (ss-aw-hit st) (not (ss-aw-wave st))))))
    (when i
      (when (ss-sp st) (situ-say i :spacing nil))
      (when (ss-kz st) (situ-say i :kessa (and (ss-kz-in st) (>= (ss-kz-dealt st) (ss-kz-taken st)))))))
  (setf *situ* (make-situ-st)))

(defun situ-dist (a b)
  (let ((p (pos-of a)) (q (pos-of b))) (sqrt (+ (expt (- (aref p 0) (aref q 0)) 2) (expt (- (aref p 2) (aref q 2)) 2)))))
(defun situ-free-p (f) (member (fighter-state f) '(:idle :run :move :step :hoho :guard)))
(defun situ-mv (f) (and (eq (fighter-state f) :move) (fighter-move f) (mv-name (fighter-move f))))
(defun situ-wave-p (o)
  "Is a hitting hazard of O's alive (his Getsuga)?"
  (let ((w nil)) (do-entities (h (hz hazard)) (when (and (eql (hazard-owner hz) o) (hazard-hw hz) (> (hazard-hits-left hz) 0)) (setf w t))) w))
(defun situ-name-in (name prefixes) (and name (let ((s (symbol-name name))) (some (lambda (p) (eql 0 (search p s))) prefixes))))

(defun situ-step ()
  (let ((st *situ*))
    (unless (and (eq *flow* :battle) *p1* *p2* (entity-alive-p *p1*) (entity-alive-p *p2*))
      (when (ss-ken st) (situ-flush st))
      (return-from situ-step))
    (when (< *match-tick* (ss-tick st)) (situ-flush st) (setf st *situ*))   ; a new match
    (unless (ss-ken st)                                                      ; the first step of a match: who is who
      (let ((c1 (fighter-character (fighter *p1*))) (c2 (fighter-character (fighter *p2*))))
        (cond ((and (eq c1 :kenpachi) (eq c2 :ichigo)) (setf (ss-ken st) *p1* (ss-ich st) *p2*))
              ((and (eq c1 :ichigo) (eq c2 :kenpachi)) (setf (ss-ken st) *p2* (ss-ich st) *p1*))
              (t (return-from situ-step)))
        (setf (ss-rk st) (gauges-reishi (gauges (ss-ken st))) (ss-ri st) (gauges-reishi (gauges (ss-ich st)))
              (ss-kk st) (gauges-konpaku (gauges (ss-ken st))) (ss-ki st) (gauges-konpaku (gauges (ss-ich st))))))
    (when (= *match-tick* (ss-tick st)) (return-from situ-step))
    (setf (ss-tick st) *match-tick*)
    (let* ((ke (ss-ken st)) (ie (ss-ich st)) (kf (fighter ke)) (if* (fighter ie)) (kg (gauges ke)) (ig (gauges ie))
           (d (situ-dist ke ie))
           (rk (gauges-reishi kg)) (ri (gauges-reishi ig))
           (kmv (situ-mv kf)) (imv (situ-mv if*))
           (k-new (and (fighter-cls kf) (/= (fighter-cls-t kf) (ss-ken-cls st))))
           ;; a Reishi drop this step (a refill after a break is a rise); his own Bankai segment cost (*KEN-BK-COST* on a segment's
           ;; start, ken-bk-cost) is not a hit on him (2026-11-07, DUEL_MATCHUP_AI §9)
           (self-cost (if (and k-new (member (fighter-form kf) '(:bankai :bankai-2))) *ken-bk-cost* 0))
           ;; ... or a Konpaku lost (a Soul Break / Kikon: the bar refills on the breaking step, so its Reishi reads as a rise; 2026-11-07,
           ;; §10), except his own Konpaku paid as a Bankai ends (ken-bk-tick)
           (kk (gauges-konpaku kg)) (ki (gauges-konpaku ig))
           (ken-hurt (or (< (+ rk self-cost) (ss-rk st))
                         (and (< kk (ss-kk st)) (not (and (eq (fighter-form kf) :nozarashi) (member (ss-form st) '(:bankai :bankai-2)))))))
           (ich-hurt (or (< ri (ss-ri st)) (< ki (ss-ki st))))
           (i-new (and (fighter-cls if*) (/= (fighter-cls-t if*) (ss-ich-cls st))))
           (form (fighter-form kf)) (lv (if (eq form :nozarashi) (round (gauges-meter kg)) 0)))
      (when k-new (setf (ss-ken-cls st) (fighter-cls-t kf)))
      (when i-new (setf (ss-ich-cls st) (fighter-cls-t if*) (ss-ich-d st) d))
      ;; ---- Kenpachi 封印肉搏: sealed, inside 3.6 m, an exchange starts (a classed move by either, both free); the first hit decides
      (when (and (ss-ex st) (or ken-hurt ich-hurt))
        (situ-say ke :brawl (and ich-hurt (not ken-hurt))) (setf (ss-ex st) nil))
      (when (and (ss-ex st) (> (- *match-tick* (ss-ex-t st)) 120)) (setf (ss-ex st) nil))   ; (no hit: no exchange)
      (when (and (not (ss-ex st)) (eq form :base) (<= d 3.6) (or k-new i-new) (situ-free-p kf) (situ-free-p if*)
                 (not (or ken-hurt ich-hurt)))
        (setf (ss-ex st) t (ss-ex-t st) *match-tick*))
      ;; ---- 解放攀升: each Shikai stay; ok = J4-J7 or a special AS lands in it
      (when (and (ss-stay st) (not (eq form :nozarashi))) (situ-say ke :shikai (ss-stay-ok st)) (setf (ss-stay st) nil))
      (when (and (eq form :nozarashi) (not (eq (ss-form st) :nozarashi))) (setf (ss-stay st) t (ss-stay-ok st) nil))
      (when (and (ss-stay st) ich-hurt (member kmv '(:ke-s-j4 :ke-s-j5 :ke-s-j6 :ke-s-j7 :ke-s-sp1 :ke-s-sp2))) (setf (ss-stay-ok st) t))
      ;; ---- 卍解爆發: each rise to L3; ok = a Bankai entered after it and left by the special AS (back to the Shikai)
      (when (and (eq form :nozarashi) (>= lv 3) (< (ss-lv st) 3)) (push (cons :wait nil) (ss-l3s st)))
      (when (and (member form '(:bankai :bankai-2)) (eq (ss-form st) :nozarashi))
        (dolist (c (ss-l3s st)) (when (eq (car c) :wait) (setf (car c) :in))))
      (when (member kmv '(:ke-kr-sp :ke-zh-sp))                      ; his special AS started: the way back (a K.O. by it counts, §9)
        (dolist (c (ss-l3s st)) (when (eq (car c) :in) (setf (car c) :out))))
      (when (and (eq form :nozarashi) (member (ss-form st) '(:bankai :bankai-2)))
        (setf (ss-l3s st) (remove-if (lambda (c) (when (member (car c) '(:in :out)) (situ-say ke :bankai t) t)) (ss-l3s st))))
      ;; ---- 破月牙: Ichigo starts his Getsuga route (NS2a) at 3.6-6.6 m; ok = the wave never hit, and Kenpachi hit him before his next move
      (when (ss-aw st)
        (when (and ken-hurt (or (situ-wave-p ie) (situ-name-in imv '("IC-N2C" "IC-K-N2C" "IC-AS2B" "IC-K-AS2B" "IC-WAVE"))))
          (setf (ss-aw-wave st) t))
        (when ich-hurt (setf (ss-aw-hit st) t))
        (when (or (> (- *match-tick* (ss-aw-t st)) 200)
                  (and i-new (not (situ-name-in imv '("IC-N2" "IC-K-N2" "IC-SA-G" "IC-K-SA-G" "IC-WAVE")))))
          (situ-say ke :antiwave (and (ss-aw-hit st) (not (ss-aw-wave st)))) (setf (ss-aw st) nil)))
      (when (and (not (ss-aw st)) i-new (member imv '(:ic-n2a :ic-k-n2a)) (<= 3.6 d 6.6))
        (setf (ss-aw st) t (ss-aw-t st) *match-tick* (ss-aw-wave st) nil (ss-aw-hit st) nil))
      ;; ---- Ichigo 間合い管理: the distance enters 4-5 m or >= 7.5 m (both free); ok = she lands a hit from there (a move started at
      ;;      >= 4 m, or her wave), while in the band or within 90 steps after leaving it
      (let ((band (or (<= 4.0 d 5.0) (>= d 7.5))))
        (when (ss-sp st)
          (cond ((and ken-hurt (or (>= (ss-ich-d st) 4.0) (situ-wave-p ie)) (not ich-hurt))
                 (situ-say ie :spacing t) (setf (ss-sp st) nil))
                ((not band) (when (<= (decf (ss-sp-left st)) 0) (situ-say ie :spacing nil) (setf (ss-sp st) nil)))
                (t (setf (ss-sp-left st) 90))))
        (when (and (not (ss-sp st)) band (situ-free-p kf) (situ-free-p if*) (not (or ken-hurt ich-hurt)))
          (setf (ss-sp st) t (ss-sp-left st) 90)))
      ;; ---- 揮空反擊: his classed move started inside 3.6 m ends its active frames without contact; ok = she hits him in its recovery
      (when (ss-wf st)
        (cond (ken-hurt (situ-say ie :whiff t) (setf (ss-wf st) nil))
              ((and (eq (fighter-state kf) :move) (= (fighter-cls-t kf) (ss-wf-cls st))) nil)
              ((<= (decf (ss-wf-t st)) 0) (situ-say ie :whiff nil) (setf (ss-wf st) nil))))
      (when (and (not (ss-wf st)) (fighter-cls kf) (eq (fighter-state kf) :move) (fighter-move kf)
                 (/= (fighter-cls-t kf) (ss-wf-seen st))
                 (> (fighter-sf kf) (+ (mv-s (fighter-move kf)) (mv-a (fighter-move kf))))
                 (null (fighter-contact kf)) (<= d 3.6))
        (setf (ss-wf-seen st) (fighter-cls-t kf) (ss-wf st) t (ss-wf-cls st) (fighter-cls-t kf) (ss-wf-t st) 4))
      ;; ---- KESSA 強攻: her awakening gauge fills; ok = she enters KESSA and deals >= what she takes there (closed at the match end)
      (let ((full (>= (gauges-awaken ig) *awaken-max*)))
        (when (and full (not (ss-kz-full st)) (not (ss-kz st)) (not (eq (fighter-form if*) :kessa))) (setf (ss-kz st) t))
        (setf (ss-kz-full st) full))
      (when (and (ss-kz st) (eq (fighter-form if*) :kessa))
        (setf (ss-kz-in st) t)
        (when ken-hurt (incf (ss-kz-dealt st) (- (ss-rk st) rk)))
        (when ich-hurt (incf (ss-kz-taken st) (- (ss-ri st) ri))))
      (setf (ss-rk st) rk (ss-ri st) ri (ss-kk st) kk (ss-ki st) ki (ss-form st) form (ss-lv st) lv))))

(setf *step-hook* #'situ-step)
