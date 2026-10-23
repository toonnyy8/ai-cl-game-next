;;;; rogue.lisp — DANGAI 斷界行 (docs/duel/DUEL_ROGUE.md), batch 1: the run is an ENDLESS run (endless.lisp: the carry,
;;;; STAGE CLEAR, RESULTS, the record) with *ROGUE* set; this file is the DOORS screen between steps (flow state :doors:
;;;; ROGUE-DOORS' doors, a rest or the next fight). Batch 2 (the run layer): the held rewards (*ROGUE-HELD*), the REWARD
;;;; screen (flow state :reward: 3 cards, REPLACE's drop menu, a KONPAKU door's notice, 賭契's extra pick, a rest's
;;;; KONPAKU +3 / UPGRADE), and each stage start's *RUN-MODS* (run-mods.lisp) with the stage-start keys (DUEL_ROGUE §4.4).
;;;; The rules are rogue-rules.lisp. Debug 84000-84999 (debug.lisp: ENDLESS-DEBUG with ROGUE; ROGUE-DEBUG 84501-84552).
;;;; Log: "duel rogue door i step n kind [opponent]", "duel rogue reward step n pick id tier t [replace id]",
;;;; "duel rogue mods (plist)" at each stage start.
(in-package :duel)

(defvar *rogue-held* nil "The run's held rewards, (id . tier) each in pick order (ROGUE-RESET at the run start).")
(defvar *rogue-reward* nil "The reward type of the stage being played (the door's :reward; NIL: ROGUE-STEP-REWARD).")
(defvar *rogue-sub* :cards "The REWARD screen's page: :cards :replace :notice :rest :upgrade.")
(defvar *rogue-offer* nil "The REWARD screen's cards (ROGUE-OFFER's plists).")
(defvar *rogue-rows* nil "The REWARD screen's row keys for its page (reward ids on :replace / :upgrade, then :back).")
(defvar *rogue-card* nil "The REPLACE card waiting for its drop.")
(defvar *rogue-pick* 0 "This clear's pick index (0; 賭契's extra picks 1 on).")
(defvar *rogue-picks* 1 "This clear's picks (1 + :extra-pick).")
(defvar *rogue-rare* nil "This clear's offers are RARE.")

(defvar *rogue-door* nil "The door taken (ROGUE-TAKE) for the next stage's conditions (NIL: step 1 or a debug run).")
(defvar *rogue-stage-conds* nil "The conditions of the DANGAI stage being fought (ids, DUEL_ROGUE §5).")
(defvar *rogue-cond-line* nil "The battle tag's second line: the stage's conditions, or BOSS (made once a stage: 0 B a frame).")

(defun rogue-reset () "A new run: nothing held, the first step's reward by its kind and conditions by its draw."
  (setf *rogue-held* nil *rogue-reward* nil *rogue-door* nil))
(defun rogue-run-mods () "The held rewards' modifier plist (ROGUE-MODS)." (rogue-mods *rogue-held*))

;;; ---------------------------------------------------------------- the stage start (ENDLESS-APPLY!'s hook)
(defun rogue-stage-start ()
  "A DANGAI stage's spawn: *RUN-MODS* / *RUN-MODS-WHO* (P1) for every rule point, then the stage-start keys of §4.4:
P1's :reishi-max, both sides' :both-reishi, P1's :gg-max (his gauge at spawn), :konpaku-cap over the carry / spawn,
:timer on the stage timer (*TIMER-CUT* keeps MATCH-PLAY-TICKS the time played). Batch 3: the stage's conditions (the door
taken, else step 1's draw: §5) as P1's extra keys, the opponent's table (*RUN-FOE-MODS*) and the stage keys (:foe-reishi
on his Reishi, :timer); on the boss step *RUN-BOSS* and his character's :boss hook (its base kit's), after all of that."
  (let* ((step *endless-stage*) (d (shiftf *rogue-door* nil))
         (conds (if d (getf d :conds) (rogue-door-conds *endless-seed* step 0))))
    (multiple-value-bind (cp1 cfoe cstage) (rogue-cond-mods conds)
      (let ((m (rogue-merge-x (rogue-run-mods) cp1)) (g1 (gauges *p1*)) (g2 (gauges *p2*)))
        (setf *run-mods* m *run-mods-who* *p1* *run-foe-mods* cfoe *rogue-stage-conds* conds)
        (flet ((scale-reishi (g x) (let ((rm (round (* (gauges-reishi-max g) x)))) (setf (gauges-reishi-max g) rm (gauges-reishi g) rm))))
          (let ((x (getf m :reishi-max))) (when x (scale-reishi g1 x)))
          (let ((x (getf m :both-reishi))) (when x (scale-reishi g1 x) (scale-reishi g2 x)))
          (let ((x (getf cstage :foe-reishi))) (when x (scale-reishi g2 x))))
        (let ((x (getf m :gg-max))) (when x (setf (gauges-gg g1) (f32 (* *gg-max* x)))))
        (setf (gauges-konpaku g1) (min (gauges-konpaku g1) (getf m :konpaku-cap *konpaku-max*)))
        (let ((tm (min (getf m :timer *match-seconds*) (getf cstage :timer *match-seconds*))))
          (when (< tm *match-seconds*) (let ((f (* 60 tm))) (setf *timer-cut* (- *timer* f) *timer* f))))
        (let ((boss (eq (rogue-step-kind step) :boss)))
          (setf *rogue-cond-line* (cond (boss "BOSS") (conds (format nil "~{~a~^  ~}" (mapcar #'rogue-cond-name conds)))))
          (when boss
            (setf *run-boss* *p2*)
            (let ((h (kit-hook (find-kit (fighter-character (fighter *p2*)) :base) :boss))) (when h (funcall h *p2*)))))
        (log-msg "duel rogue mods ~(~s~) conds ~(~a~) foe ~(~s~)~:[~; boss ~(~a~)~]" m conds cfoe *run-boss*
                 (fighter-character (fighter *p2*)))))))

(defun hud-rogue-tag (w h s)
  "The battle tag's second line (HUD-ENDLESS-TAG): the stage's conditions or BOSS, in ember under STAGE n (landscape: fitted
between the two gauge blocks)."
  (let ((l *rogue-cond-line*))
    (when l
      (if (portrait-p)
          (hud-text l (* 4 s) (+ (portrait-hud-bottom s) (* 14 s)) (* 1.0 s) *ember*)
          (hud-text l (floor w 2) (+ (* 0.13 h) (* 22 s)) (fit-scale l (* 1.5 s) (* 0.16 w)) *ember* :align :center)))))   ; (between the gauges)

(defun rogue-end () "The run is over (ENDLESS-OVER): no rule point reads a run's mods any more."
  (setf *run-mods* nil *run-mods-who* nil *run-foe-mods* nil *run-boss* nil))

;;; ---------------------------------------------------------------- the cards' text
(defparameter *rogue-cat-names* '((:zan . "ZAN") (:mamori . "MAMORI") (:shun . "SHUN") (:rei . "REI") (:chigiri . "CHIGIRI") (:kai . "KAI")))
(defparameter *rogue-mod-labels*
  '((:dmg "DAMAGE" :pct) (:ender-dmg "ENDERS" :pct) (:red-dmg "RED DAMAGE" :pct) (:post-burst-dmg "HIT AFTER HOHO" :pct)
    (:sp-dmg "SP DAMAGE" :pct) (:guard-drain "GUARD DRAIN" :pct) (:kikon-plus "KIKON KONPAKU" :count)
    (:sb-plus "SOUL BREAK KONPAKU" :count) (:kikon-past "KIKON KONPAKU PAST CAP" :count) (:kikon-guard "KIKON ALWAYS GUARDED" :flag)
    (:revive "AT 0 KONPAKU ONCE A STAGE" :count) (:armor-on-soul-loss "ARMOR AFTER SOUL LOSS" :sec)
    (:armor-on-awaken "ARMOR AFTER AWAKENING" :sec) (:chip-taken "CHIP TAKEN" :pct) (:breaker-taken "BREAKER TAKEN" :pct)
    (:awake-taken "AWAKENED DAMAGE TAKEN" :pct) (:perfect-fs "PERFECT HOHO FLASH STEP" :frac) (:perfect-reiatsu "REIATSU" :bar)
    (:regen "REISHI REGEN /S" :frac) (:fs-regen "FLASH STEP REGEN" :pct) (:hoho-cost "HOHO COST" :pct)
    (:reiatsu-regen "REIATSU REGEN" :pct) (:gg-regen "GUARD REGEN" :pct) (:awaken-heal "AWAKENING HEAL" :frac)
    (:reishi-max "REISHI MAX" :pct) (:gg-max "GUARD MAX" :pct) (:konpaku-cap "KONPAKU CAP" :value) (:timer "TIMER" :sec)
    (:clear-konpaku "CLEAR KONPAKU" :count) (:extra-pick "PICKS A CLEAR" :count)
    (:any-bankai "BANKAI FROM ANY CUP, KONPAKU KEPT" :flag) (:no-arm "BANKAI ARM NEVER SPENT" :flag)
    (:hs-tip-dmg "RANGED TIP" :times) (:hs-flat-dmg "OTHER HITS" :times) (:hs-tip-sp "TIP SP" :times) (:hs-flat-sp "OTHER SP" :times))
  "A reward mod's words on its card: the label and how its value reads.")

(defun rogue-num (x) "X with one decimal only when it has one." (if (< (abs (- x (round x))) 0.05) (format nil "~d" (round x)) (format nil "~,1f" x)))
(defun rogue-phrase (key v)
  "One mod at value V in words: DAMAGE +10%, KONPAKU CAP 7, ARMOR AFTER SOUL LOSS 3S, KIKON ALWAYS GUARDED."
  (destructuring-bind (label how) (rest (assoc key *rogue-mod-labels*))
    (case how
      (:pct (format nil "~a ~:[~;+~]~a%" label (> v 1) (rogue-num (* 100 (- v 1)))))
      (:frac (format nil "~a +~a%" label (rogue-num (* 100 v))))
      (:bar (format nil "~a +~a BAR" label (rogue-num v)))
      (:sec (format nil "~a ~aS" label (rogue-num v)))
      (:count (format nil "~a +~d" label v))
      (:value (format nil "~a ~d" label v))
      (:times (format nil "~a X~,2f" label v))
      (t label))))
(defun rogue-effect (id tier) "Reward ID's effect line at TIER." (format nil "~{~a~^  ~}" (mapcar (lambda (m) (rogue-phrase (first m) (rogue-mod-value m tier))) (rogue-reward-mods id))))
(defun rogue-tier-tag (id tier) "TIER's name for a tierable ID, else NIL (魄鎧 and the pacts have no tiers)." (and (rogue-tierable-p id) (nth tier *rogue-tiers*)))
(defun rogue-card-label (c)
  "A card's row: the name, the category, the tier, REPLACE / UPGRADE / TWIN (a 解 card whose twin is held: they swap)."
  (let ((id (getf c :id)))
    (format nil "~a  ~a~@[  ~a~]~@[  ~a~]" (rogue-reward-name id) (cdr (assoc (rogue-reward-cat id) *rogue-cat-names*))
            (rogue-tier-tag id (getf c :tier)) (case (getf c :kind) (:replace "REPLACE") (:upgrade "UPGRADE") (:twin "TWIN")))))
(defun rogue-card-note (c)
  "A card's note: its effect at its tier, then the trait it completes (`+ SHISEN`)."
  (format nil "~a~@[  + ~a~]" (rogue-effect (getf c :id) (getf c :tier))
          (let ((tr (getf c :trait))) (and tr (second (assoc tr *rogue-traits*))))))
(defun rogue-held-label (id) "A held reward's row: its name and tier." (let ((h (assoc id *rogue-held*))) (format nil "~a~@[  ~a~]" (rogue-reward-name id) (rogue-tier-tag id (cdr h)))))
(defun rogue-build-lines ()
  "The run's RESULTS: the held rewards (name and tier initial), then the traits on (+ NAME), as two lines (the first
headed BUILD), the items split in half."
  (let* ((items (append (loop for (id . tier) in *rogue-held*
                              collect (format nil "~a~@[ ~a~]" (rogue-reward-name id) (let ((tg (rogue-tier-tag id tier))) (and tg (char tg 0)))))
                        (mapcar (lambda (tr) (format nil "+ ~a" (second (assoc tr *rogue-traits*)))) (rogue-traits-on *rogue-held*))))
         (k (ceiling (length items) 2)))
    (remove nil (list (format nil "BUILD  ~:[-~;~:*~{~a~^  ~}~]" (subseq items 0 k))
                      (and (> (length items) k) (format nil "~{~a~^  ~}" (subseq items k)))))))

;;; ---------------------------------------------------------------- the REWARD screen
(defun rogue-screen (sub title rows labels notes)
  "Show REWARD page SUB: TITLE, the Konpaku / held line, ROWS (their LABELS, the selected one's NOTES above)."
  (setf *rogue-sub* sub *rogue-rows* rows
        *endless-lines* (vector title
                                (format nil "KONPAKU  ~d   HELD  ~d / 9" (getf *endless-carry* :konpaku) (length *rogue-held*))
                                labels notes (append labels '("CONFIRM"))))
  (set-flow :reward))

(defun rogue-cards-screen ()
  "The REWARD page of *ROGUE-OFFER*: one row a card, its effect line the note."
  (rogue-screen :cards (format nil "~:[REWARD~;RARE REWARD~]~:[~*~*~;  ~d / ~d~]" *rogue-rare* (> *rogue-picks* 1)
                               (1+ *rogue-pick*) *rogue-picks*)
                *rogue-offer* (mapcar #'rogue-card-label *rogue-offer*) (mapcar #'rogue-card-note *rogue-offer*)))

(defun rogue-show-cards ()
  "This clear's next pick: an offer of 3 (fewer if the pool is short; none: on to the doors)."
  (setf *rogue-offer* (rogue-offer *endless-seed* *endless-stage* *rogue-pick* *rogue-held* *rogue-rare* (first *picks*)))
  (if *rogue-offer* (rogue-cards-screen) (rogue-open-doors)))

(defun rogue-open-reward ()
  "After STAGE CLEAR's CONTINUE / REVERT (the carry made): this stage's reward (its door's type), then the doors. KONPAKU:
+3 with a notice; GENERIC / RARE: 1 + :extra-pick offers (賭契's extra picks are the stage's tier, GENERIC after KONPAKU)."
  (let ((type (or (shiftf *rogue-reward* nil) (rogue-step-reward *endless-stage*))))
    (setf *rogue-pick* 0 *rogue-picks* (1+ (getf (rogue-run-mods) :extra-pick 0)) *rogue-rare* (eq type :rare))
    (if (eq type :konpaku)
        (let ((k (getf *endless-carry* :konpaku)))
          (setf *endless-carry* (rogue-rest *endless-carry* (getf (rogue-run-mods) :konpaku-cap *konpaku-max*)))
          (log-msg "duel rogue reward step ~d konpaku ~d->~d" *endless-stage* k (getf *endless-carry* :konpaku))
          (setf *rogue-picks* (1- *rogue-picks*))
          (rogue-screen :notice (format nil "KONPAKU +~d" *rogue-rest-konpaku*) '(:ok) '("CONTINUE")
                        (list (format nil "KONPAKU  ~d -> ~d" k (getf *endless-carry* :konpaku)))))
        (rogue-show-cards))))

(defun rogue-picked (card &optional drop)
  "CARD taken (DROP: the held reward REPLACE gives back): the held list, the log line, the next pick or the doors."
  (setf *rogue-held* (rogue-take-card *rogue-held* card drop))
  (log-msg "duel rogue reward step ~d pick ~d tier ~d~@[ replace ~d~]~@[ ~(~a~)~]" *endless-stage* (getf card :id) (getf card :tier)
           drop (and (eq (getf card :kind) :upgrade) :upgrade))
  (rogue-next-pick))

(defun rogue-next-pick () "The clear's next pick, else the doors." (if (< (incf *rogue-pick*) *rogue-picks*) (rogue-show-cards) (rogue-open-doors)))

(defun rogue-open-rest ()
  "A rest door taken: KONPAKU +3 or UPGRADE (one held reward a tier up; offered while one can go up)."
  (let ((up (rogue-upgradable *rogue-held*)))
    (rogue-screen :rest "REST" (if up '(:konpaku :upgrade) '(:konpaku)) (list* (format nil "KONPAKU +~d" *rogue-rest-konpaku*) (and up '("UPGRADE")))
                  (list* (format nil "KONPAKU  ~d -> ~d" (getf *endless-carry* :konpaku)
                                 (getf (rogue-rest *endless-carry* (getf (rogue-run-mods) :konpaku-cap *konpaku-max*)) :konpaku))
                         (and up (list "ONE HELD REWARD ONE TIER UP"))))))

(defun rogue-row (i)
  "REWARD row I chosen on the current page."
  (let ((k (nth i *rogue-rows*)))
    (ecase *rogue-sub*
      (:cards (if (eq (getf k :kind) :replace)
                  (let ((ids (rogue-held-ids (rogue-cat-held *rogue-held* (rogue-reward-cat (getf k :id))))))
                    (setf *rogue-card* k)
                    (rogue-screen :replace (format nil "REPLACE WITH ~a" (rogue-reward-name (getf k :id)))
                                  (append ids '(:back)) (append (mapcar #'rogue-held-label ids) '("BACK"))
                                  (append (mapcar (lambda (id) (format nil "DROP: ~a" (rogue-effect id (cdr (assoc id *rogue-held*))))) ids)
                                          '("BACK TO THE CARDS"))))
                  (rogue-picked k)))
      (:replace (if (eq k :back) (rogue-cards-screen) (rogue-picked *rogue-card* k)))
      (:notice (if (plusp *rogue-picks*) (rogue-show-cards) (rogue-open-doors)))
      (:rest (if (eq k :konpaku)
                 (let ((k0 (getf *endless-carry* :konpaku)))
                   (setf *endless-carry* (rogue-rest *endless-carry* (getf (rogue-run-mods) :konpaku-cap *konpaku-max*)))
                   (log-msg "duel rogue rest step ~d konpaku ~d->~d" *endless-stage* k0 (getf *endless-carry* :konpaku))
                   (rogue-open-doors))
                 (let ((ids (rogue-upgradable *rogue-held*)))
                   (rogue-screen :upgrade "UPGRADE" (append ids '(:back)) (append (mapcar #'rogue-held-label ids) '("BACK"))
                                 (append (mapcar (lambda (id) (let ((tr (cdr (assoc id *rogue-held*))))
                                                                (format nil "~a -> ~a" (nth tr *rogue-tiers*) (rogue-effect id (1+ tr)))))
                                                 ids)
                                         '("BACK TO THE REST"))))))
      (:upgrade (if (eq k :back)
                    (rogue-open-rest)
                    (progn (setf *rogue-held* (rogue-upgrade *rogue-held* k))
                           (log-msg "duel rogue rest step ~d upgrade ~d tier ~d" *endless-stage* k (cdr (assoc k *rogue-held*)))
                           (rogue-open-doors)))))))

(defun rogue-nav (n)
  "A REWARD / DOORS page's input over N rows: the keys as MENU-NAV (up / down, confirm takes the selected row); a tap on a
row only selects it, so its note shows first, and the CONFIRM row under the rows (drawn on touch only, HUD-ROGUE-DOORS)
takes the selected one (the user, 2026-10-23: 「在關卡之間選擇獎勵的時候請提供一個額外的確認鍵，不然手機點擊連詳細內容預覽都看不見就
直接選擇了」)."
  (when (menu-up-p) (setf *menu* (mod (1- *menu*) n)) (play-sfx :select))
  (when (menu-down-p) (setf *menu* (mod (1+ *menu*) n)) (play-sfx :select))
  (let ((r (tapped-row (1+ n))))
    (cond ((and r (< r n)) (unless (= r *menu*) (setf *menu* r) (play-sfx :select)) nil)
          (r (play-sfx :confirm) *menu*)
          ((confirm-p) (play-sfx :confirm) *menu*))))

(defun rogue-reward-update ()
  "REWARD per frame: the rows take input after 1 s (each page), as STAGE CLEAR; the autopilot takes row 0 every time."
  (cond (*endless-auto* (rogue-row 0))
        ((> *ft* 1.0) (let ((i (rogue-nav (length *rogue-rows*)))) (when i (rogue-row i))))))

(defun rogue-debug (k)
  "Debug 84500+K (DUEL_GAMEPLAY): 1-28 grant reward K to the running run (COMMON, RARE for a RARE+ only one) when it is
not held and its category has a free slot; 50-52 the running stage's reward type GENERIC / KONPAKU / RARE; 60+c (batch
3) a debug DANGAI run from the boss step against roster c (P1 Yamamoto, or Kenpachi against Yamamoto; seed 1, no record);
70-73 (batch 4) grant 解 card 101-104."
  (cond ((<= 70 k 73) (rogue-debug-grant (+ 31 k)))      ; batch 4: 84570+i grants 解 card 101+i
        ((<= 60 k 67)
         (let ((c (nth (- k 60) *roster*)))
           (when (member c (playable-roster))
             (setf *mode* :endless *rogue* t *picks* (list (if (eq c :yamamoto) :kenpachi :yamamoto) c) *endless-seed* 1
                   *one-hand* (one-hand-effective-p) *rogue-next* c)
             (let ((*skip-cines* t)) (endless-start :debug t :stage *rogue-steps*)))))
        ((<= 50 k 52) (setf *rogue-reward* (nth (- k 50) '(:generic :konpaku :rare)))
         (log-msg "duel rogue debug reward ~(~a~)" *rogue-reward*))
        (t (rogue-debug-grant k))))

(defun rogue-debug-grant (k)
  "Reward K into the running run (COMMON, RARE for a RARE+ only one) when it is not held and its category has a free slot;
it acts from the next stage's start."
  (if (and (rogue-reward k) (not (assoc k *rogue-held*)) (not (rogue-cat-full-p *rogue-held* (rogue-reward-cat k))))
      (progn (setf *rogue-held* (rogue-take-card *rogue-held* (list :id k :tier (if (rogue-rare-only-p k) 1 0) :kind :new)))
             (log-msg "duel rogue debug grant ~d held ~a" k *rogue-held*))
      (log-msg "duel rogue debug grant ~d refused" k)))

(defvar *rogue-doors* nil "The DOORS screen's doors (ROGUE-DOORS' plists).")

(defun rogue-door-label (d)
  "A door's row: REST, or the opponent's name."
  (if (eq (getf d :kind) :rest) "REST" (kit-name (find-kit (getf d :opponent) :base))))

(defun rogue-door-note (d step)
  "What the selected door leads to: the rest's choice, or the step's kind, CPU difficulty, the opponent's awakening
(awakened, or its gauge at FIGHT), Reishi and the reward type (REWARD = GENERIC, KONPAKU +3, RARE REWARD)."
  (if (eq (getf d :kind) :rest)
      (format nil "KONPAKU +~d OR UPGRADE" *rogue-rest-konpaku*)
      (let ((r (rogue-ramp step)))
        (format nil "~@[~a  ~]~a~:[~;  AWAKENED~]~:[~*~;  AWAKENING ~d~]  REISHI ~d%  ~a"
                (case (rogue-step-kind step) (:elite "ELITE") (:boss "BOSS"))
                (ramp-difficulty *endless-floor* r *difficulties*) (fourth r)
                (and (not (fourth r)) (plusp (third r))) (third r) (fifth r)
                (case (getf d :reward) (:rare "RARE REWARD") (:konpaku (format nil "KONPAKU +~d" *rogue-rest-konpaku*)) (t "REWARD"))))))

(defun rogue-door-cond-line (d step)
  "The selected door's conditions line (DUEL_ROGUE §5): BOSS RULE on the boss step, its conditions, else NIL (a rest)."
  (cond ((eq (getf d :kind) :rest) nil)
        ((eq (rogue-step-kind step) :boss) "BOSS RULE")
        (t (format nil "~{~a~^  ~}" (mapcar #'rogue-cond-name (getf d :conds))))))

(defun rogue-open-doors ()
  "After STAGE CLEAR's CONTINUE / REVERT (the carry made) or a rest: the next step's doors (the DOORS screen)."
  (let ((next (1+ *endless-stage*)))
    (setf *rogue-doors* (rogue-doors *endless-seed* next (first *endless-foes*) (playable-roster))
          *endless-lines* (vector (format nil "STAGE ~d" next)
                                  (format nil "KONPAKU  ~d" (getf *endless-carry* :konpaku))
                                  (mapcar #'rogue-door-label *rogue-doors*)
                                  (mapcar (lambda (d) (rogue-door-note d next)) *rogue-doors*)
                                  (append (mapcar #'rogue-door-label *rogue-doors*) '("CONFIRM"))
                                  (mapcar (lambda (d) (rogue-door-cond-line d next)) *rogue-doors*)))
    (set-flow :doors)))

(defun rogue-take (i)
  "Door I: a rest (the step passed, the record checked, the rest's KONPAKU +3 / UPGRADE, then the next doors) or the next
fight (its reward type kept for its clear)."
  (let ((d (nth i *rogue-doors*)))
    (log-msg "duel rogue door ~d step ~d ~(~a~)~@[ ~(~a~)~]~@[ ~(~a~)~]" i (1+ *endless-stage*) (getf d :kind) (getf d :opponent)
             (getf d :reward))
    (if (eq (getf d :kind) :rest)
        (progn (incf *endless-stage*) (incf *endless-cleared*)
               (endless-save-record)
               (rogue-open-rest))
        (progn (setf *rogue-next* (getf d :opponent) *rogue-reward* (getf d :reward) *rogue-door* d) (endless-next-stage)))))

(defun rogue-doors-update ()
  "DOORS per frame: the rows take input after 1 s, as STAGE CLEAR; the autopilot takes door 0."
  (cond (*endless-auto* (rogue-take 0))
        ((> *ft* 1.0) (let ((i (rogue-nav (length *rogue-doors*)))) (when i (rogue-take i))))))

(defun hud-rogue-doors (w h s)
  "DOORS (and REWARD, the same layout): the title, P1's Konpaku, the rows with the selected one's note above them; on touch
a CONFIRM row under them (a tap on a row only selects it: ROGUE-NAV)."
  (let ((l *endless-lines*))
    (multiple-value-bind (cx y pw) (results-card w h s)
      (ui-big-text (svref l 0) (round cx) (round (+ y (* 4 s))) (fit-scale (svref l 0) (* 3 s) (- pw (* 8 s)))
                   '(1 0.92 0.8 1) '(0.7 0.18 0.05 1) s :shear 0.0)
      (hud-text (svref l 1) cx (+ y (* 6 s) (* 11 (max 1 (round (* 1.5 s))))) (fit-scale (svref l 1) (* 1.5 s) (- pw (* 8 s)))
                *dim* :align :center)
      (when (> *ft* 1.0)
        (let* ((y0 (if (portrait-p) 0.8 0.72)) (note (nth *menu* (svref l 3)))
               (cl (and (> (length l) 5) (nth *menu* (svref l 5)))))   ; the DOORS: the door's conditions over its note
          (hud-text note cx (- (* y0 h) (* 14 s)) (fit-scale note (* 1.5 s) (- pw (* 8 s))) *ember* :align :center)
          (when cl (hud-text cl cx (- (* y0 h) (* 30 s)) (fit-scale cl (* 1.5 s) (- pw (* 8 s))) *ember* :align :center))
          (hud-menu (svref l (if (touch-tap-zones-p) 4 2)) y0 pw h s cx))))))   ; touch: + CONFIRM (ROGUE-NAV); rows fit the card
