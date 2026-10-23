;;;; rogue-rules.lisp — DANGAI 斷界行 (docs/duel/DUEL_ROGUE.md) as pure rules: the run's layout, the ramp per step, the
;;;; rest doors, the doors between steps and their reward types, a rest's carry; batch 2: the generic rewards and traits
;;;; (§4.2) as data, slots, offers, REPLACE / UPGRADE, tiers and the fold into the run modifier plist (§4.4); batch 3: the
;;;; stages' conditions (§5). Plain CL over endless-rules.lisp, host-tested
;;;; (tests/duel-rules/rogue.lisp); the mode (the doors screen, the record) is rogue.lisp over endless.lisp.
;;;; No character names in here.
(in-package :duel)

(defparameter *rogue-steps* 10 "A run: steps 1-10, the boss at 10; after it the continuation (DUEL_ROGUE §2).")
(defparameter *rogue-boss-row* '(10 2 100 t 150)
  "The boss's ramp row: two steps over any floor (HARD), awakened at FIGHT, Reishi 150 % (DUEL_ROGUE §5, R4).")
(defparameter *rogue-rest-from* 4 "The first step that may offer a rest door (DUEL_ROGUE §3).")
(defparameter *rogue-rest-max* 2 "A run offers at most this many rest doors (DUEL_ROGUE §3).")
(defparameter *rogue-rest-konpaku* 3 "A rest door: Konpaku + this, at most *KONPAKU-MAX* (DUEL_ROGUE §3).")

(defun rogue-step-kind (step)
  "STEP's kind (1-based): :boss at *ROGUE-STEPS*, :elite every third step (3 6 9, and on in the continuation), :normal."
  (cond ((= step *rogue-steps*) :boss) ((zerop (mod step 3)) :elite) (t :normal)))

(defun rogue-ramp (step)
  "STEP's ramp row (stage steps awaken awakened reishi-%): a normal step ENDLESS's own; an elite the row two stages on with
one more difficulty step (at most 2); the boss *ROGUE-BOSS-ROW*."
  (case (rogue-step-kind step)
    (:boss *rogue-boss-row*)
    (:elite (let ((r (copy-list (endless-ramp (+ step 2))))) (setf (second r) (min 2 (1+ (second r)))) r))
    (t (endless-ramp step))))

(defun rogue-lcg-at (seed step salt)
  "The doors' own draw for (SEED, STEP, SALT): ENDLESS-LCG, never SIM-RND (how a fight goes never changes the doors)."
  (endless-lcg (endless-lcg (+ (* seed 7919) (* step 104729) (* salt 15485863) 3))))

(defparameter *rogue-door-odds* '(1 2 7)
  "A normal step's door reward, of 10: RARE, KONPAKU, GENERIC (DUEL_ROGUE §3; batch 2's numbers: mostly GENERIC, sometimes
KONPAKU +3, rarely RARE). Elites and the boss are always RARE; step 1 GENERIC.")

(defun rogue-step-reward (step)
  "The reward type a step gives without a door's own (step 1, a debug run's first step): RARE on an elite or the boss,
else GENERIC."
  (if (member (rogue-step-kind step) '(:elite :boss)) :rare :generic))

(defun rogue-door-reward (seed step i)
  "Door I's reward type before STEP of run SEED: :rare on an elite / boss step, else *ROGUE-DOOR-ODDS*' draw (:rare,
:konpaku or :generic) on the run's own LCG."
  (if (eq (rogue-step-reward step) :rare)
      (rogue-step-reward step)
      (let ((r (mod (floor (rogue-lcg-at seed step (+ 3 i)) 65536) 10)) (o *rogue-door-odds*))
        (cond ((< r (first o)) :rare) ((< r (+ (first o) (second o))) :konpaku) (t :generic)))))

;;; ---------------------------------------------------------------- conditions (DUEL_ROGUE §5, batch 3)
(defparameter *rogue-conditions*
  ;; (id name effect...); an effect (where key value): :foe the opponent's rule-point table (*RUN-FOE-MODS*), :p1 P1's
  ;; (stacked with his rewards: x multiplies), :stage the stage start (:foe-reishi x on the opponent's Reishi max, :timer
  ;; the smaller wins)
  '((:foe-reishi "FOE REISHI 130%" (:stage :foe-reishi 1.3))
    (:reiatsu "REIATSU REGEN X2" (:foe :reiatsu-regen 2.0) (:p1 :reiatsu-regen 2.0))
    (:sp-armor "FOE SP ARMOR" (:foe :sp-armor t))
    (:zone "FOE ZONES" (:foe :zone-bias 3))
    (:timer "TIMER 180S" (:stage :timer 180)))
  "A stage's conditions (DUEL_ROGUE §5's five candidates): the opponent's Reishi 130 %; both sides' Reiatsu regen x2; the
opponent's SP takes one armour hit in its startup; the CPU favours its zoning range (+3 on its :zone intent weight); the
stage timer 180 s. Constant for the fight, shown on the doors and the battle tag (§1 fair failure).")

(defun rogue-cond-count (step) "Conditions on STEP: 1 a normal step, 2 an elite, none the boss (its own rule, §5)."
  (case (rogue-step-kind step) (:normal 1) (:elite 2) (t 0)))

(defun rogue-door-conds (seed step i)
  "Door I's conditions before STEP of run SEED (ids, ROGUE-COND-COUNT of them, distinct): the first of a Fisher-Yates
shuffle of *ROGUE-CONDITIONS* on the run's LCG keyed on (SEED, STEP, 20 + I). Step 1 (no doors) uses door 0's."
  (let ((v (coerce (mapcar #'first *rogue-conditions*) 'vector)) (x (rogue-lcg-at seed step (+ 20 i))))
    (loop for k from (1- (length v)) downto 1
          do (setf x (endless-lcg x)) (rotatef (aref v k) (aref v (mod (floor x 65536) (1+ k)))))
    (coerce (subseq v 0 (rogue-cond-count step)) 'list)))

(defun rogue-cond-name (id) "Condition ID's words on the doors and the battle tag." (second (assoc id *rogue-conditions*)))

(defun rogue-cond-mods (conds)
  "CONDS' effects folded (§5): values the P1 plist, the opponent's plist, the stage plist (NIL each when empty)."
  (let ((out (list nil nil nil)))
    (dolist (id conds)
      (dolist (ef (cddr (assoc id *rogue-conditions*)))
        (destructuring-bind (where key v) ef
          (let ((k (position where '(:p1 :foe :stage))))
            (setf (nth k out) (append (nth k out) (list key v)))))))
    (values-list out)))

(defun rogue-merge-x (mods extra)
  "The P1 plist MODS (his rewards' fold) with EXTRA's keys stacked on: a key in both multiplies, else it is added."
  (let ((m (copy-list mods)))
    (loop for (k v) on extra by #'cddr
          do (let ((old (getf m k))) (setf (getf m k) (if (and (numberp old) (numberp v)) (* old v) v))))
    m))

(defun rogue-rest-steps (seed)
  "The steps of run SEED whose second door is a rest: normal steps from *ROGUE-REST-FROM* before the boss, a 1-in-3 draw
each, at most *ROGUE-REST-MAX* (pure in SEED, so the doors replay)."
  (let ((out nil))
    (loop for st from *rogue-rest-from* below *rogue-steps*
          when (and (eq (rogue-step-kind st) :normal) (< (length out) *rogue-rest-max*)
                    (zerop (mod (floor (rogue-lcg-at seed st 1) 65536) 3)))
            do (push st out))
    (nreverse out)))

(defun rogue-doors (seed step prev roster)
  "The doors before STEP (2 on) of run SEED, PREV the last opponent fought: plists (:kind :fight :opponent c) or
(:kind :rest). Two doors with two different opponents, neither PREV while ROSTER allows (one door when only one is
left); the boss step one door; on a rest step (ROGUE-REST-STEPS) the second door is the rest."
  (let* ((pool (or (remove prev roster) roster)) (n (length pool))
         (x (rogue-lcg-at seed step 2)) (i (mod (floor x 65536) n))
         (j (mod (+ i 1 (mod (floor (endless-lcg x) 65536) (max 1 (1- n)))) n))
         (a (list :kind :fight :opponent (nth i pool) :reward (rogue-door-reward seed step 0) :conds (rogue-door-conds seed step 0))))
    (cond ((eq (rogue-step-kind step) :boss) (list a))
          ((member step (rogue-rest-steps seed)) (list a (list :kind :rest)))
          ((= n 1) (list a))
          (t (list a (list :kind :fight :opponent (nth j pool) :reward (rogue-door-reward seed step 1)
                           :conds (rogue-door-conds seed step 1)))))))

(defun rogue-rest (carry &optional (cap *konpaku-max*))
  "CARRY (ENDLESS-CARRY's plist) after a rest door (or a KONPAKU door's reward): Konpaku + *ROGUE-REST-KONPAKU*, at most
CAP (the run's :konpaku-cap) and *KONPAKU-MAX*."
  (let ((c (copy-list carry)))
    (setf (getf c :konpaku) (min cap *konpaku-max* (+ (getf c :konpaku) *rogue-rest-konpaku*)))
    c))

;;; ---------------------------------------------------------------- rewards (DUEL_ROGUE §4.1-§4.2, §4.4)
(defparameter *rogue-slots* '((:zan . 2) (:mamori . 2) (:shun . 1) (:rei . 1) (:chigiri . 1) (:kai . 2))
  "Slots per category, 9 in all (DUEL_ROGUE §4.1, R7). :kai (the character's own moves) has no cards until batch 4.")
(defparameter *rogue-tiers* '("COMMON" "RARE" "LEGEND") "Tier 0-2 names; LEGEND is the top (DUEL_ROGUE §4.1).")
(defparameter *rogue-tier-scale* '(1.0 1.5 2.0)
  "Per tier, the scale of a reward's benefit (a multiplier's m - 1, a + fraction or seconds): x1.5 RARE, x2 LEGEND (§4.4).")

(defparameter *rogue-rewards*
  ;; (id category name rare-only mods...). A mod: (key kind value [role]); kind :x (multiplies) :+ (adds) :flag (ORs)
  ;; :min (the smaller wins) :clear (:clear-konpaku: 0 wins, else the larger); role NIL a benefit (scales by tier),
  ;; :cost (a pact's cost: never scales), :count (an integer: never scales), :revive (殘心: 1, LEGEND 2).
  '((1 :zan "EIJIN" nil (:dmg :x 1.10))                                     ; 鋭刃 all damage +10 %
    (2 :zan "RENGEKI" nil (:ender-dmg :x 1.25))                             ; 連撃 link-3 enders +25 %
    (3 :zan "HAGAI" nil (:guard-drain :x 1.40))                             ; 破鎧 guard drain +40 %
    (4 :zan "HAISUI" nil (:red-dmg :x 1.25))                                ; 背水 damage +25 % while red
    (5 :zan "TSUIGEKI" nil (:post-burst-dmg :x 1.30))                       ; 追擊 the first hit after a Hoho / Burst Reverse
    (6 :zan "DANKON" t (:kikon-past :+ 1 :count))                           ; 斷魂 (RARE+) a Kikon +1 Konpaku past the cap
    (7 :mamori "KENSHU" nil (:gg-max :x 1.30) (:gg-regen :x 1.30))          ; 堅守 guard gauge max / regen +30 %
    (8 :mamori "MIKIRI" nil (:perfect-fs :+ 0.25) (:perfect-reiatsu :+ 0.5)) ; 見切 a perfect Hoho refills
    (9 :mamori "FUKUTSU" nil (:armor-on-soul-loss :+ 3.0))                  ; 不屈 armour 3 s after losing Konpaku
    (10 :mamori "TEKKO" nil (:chip-taken :x 0.60) (:breaker-taken :x 0.60)) ; 鐵甲 chip / Breaker taken -40 %
    (11 :mamori "KAISEI" nil (:regen :+ 0.01))                              ; 回生 1 % Reishi a second after 3 s unhit
    (12 :mamori "ZANSHIN" t (:revive :+ 1 :revive))                         ; 殘心 (RARE+) once a stage Konpaku 0 -> 1 (LEGEND 2)
    (28 :mamori "HAKUGAI" t (:kikon-guard :flag t))                         ; 魄鎧 (RARE only, no tiers) the Kikon always guarded
    (13 :shun "SHIPPU" nil (:fs-regen :x 1.30))                             ; 疾風 flash-step regen +30 %
    (14 :shun "SHUNPO" nil (:hoho-cost :x 0.70))                            ; 瞬歩 Hoho cost -30 %
    (17 :rei "IATSU" nil (:awake-taken :x 0.85))                            ; 威壓 damage taken -15 % while awakened
    (18 :rei "REIRYOKU" nil (:reiatsu-regen :x 1.30))                       ; 靈力 Reiatsu regen +30 %
    (19 :rei "REITAI" nil (:reishi-max :x 1.15))                            ; 靈體 Reishi max +15 %
    (20 :rei "KAIHO" nil (:awaken-heal :+ 0.20))                            ; 解放 the awakening's heal 20 -> 40 %
    (21 :rei "HISSATSU" nil (:sp-dmg :x 1.20))                              ; 必殺 SP1 / SP2 +20 %
    (27 :rei "HAKI" nil (:armor-on-awaken :+ 3.0))                          ; 覇氣 armour 3 s after the awakening
    (22 :chigiri "KEKKEI" nil (:konpaku-cap :min 7 :cost) (:dmg :x 1.20))   ; 血契 Konpaku cap 7; damage +20 %
    (23 :chigiri "KYOKEI" nil (:gg-max :x 0.60 :cost) (:dmg :x 1.15) (:reiatsu-regen :x 1.30))   ; 狂契
    (24 :chigiri "JIKEI" nil (:timer :min 150 :cost) (:clear-konpaku :clear 3 :count))          ; 時契 timer 150 s; a clear +3
    (25 :chigiri "SUTEMI" nil (:reishi-max :x 0.80 :cost) (:kikon-plus :+ 1 :count) (:sb-plus :+ 1 :count))   ; 捨身
    (26 :chigiri "TOKEI" nil (:clear-konpaku :clear 0 :cost) (:extra-pick :+ 1 :count))         ; 賭契 no Konpaku; +1 pick
    ;; 解 KAI (batch 4, §4.3): one character's own cards (*ROGUE-KAI*: whose, its twin), no tiers (every value :count)
    (101 :kai "ZUIJI BANKAI" nil (:any-bankai :flag t))                      ; 劍八 隨時卍解: the Bankai from any cup
    (102 :kai "UDE MUSEIGEN" nil (:no-arm :flag t))                          ; 劍八 無手臂限制: no UDE pip spent
    (103 :kai "SENTAN KYOKA" nil (:hs-tip-dmg :x 3.42 :count) (:hs-flat-dmg :x 0.1 :count))   ; 檜佐木 尖端強化
    (104 :kai "SENTAN HEIKIN" nil (:hs-tip-dmg :x 1.355 :count) (:hs-flat-dmg :x 1.355 :count)  ; 檜佐木 尖端平均
     (:hs-tip-sp :x 1.15 :count) (:hs-flat-sp :x 1.15 :count)))
  "The 26 generic rewards (DUEL_ROGUE §4.2's table, ids = its #), COMMON values = §4.4's, then the 解 cards (101 on, one
character's each: *ROGUE-KAI*). Names are romanized (the HUD font is Latin); the kanji are in the comments and the doc.")

(defparameter *rogue-kai*
  '((101 :kenpachi 102) (102 :kenpachi 101) (103 :hisagi 104) (104 :hisagi 103))
  "The 解 cards' owners and twins (DUEL_ROGUE §4.3, the user 2026-10-22: 「將其設成孿生卡，另一個效果還是會再度出現，但是只能二擇一」):
(id character twin). A card is offered only in a run of its character; while one twin is held the other still appears,
as :twin, and taking it swaps them. The settled pairs (Kenpachi's, Hisagi's); the other characters' wait for the user.")
(defun rogue-kai-char (id) "The character whose 解 card ID is, or NIL (a generic reward)." (second (assoc id *rogue-kai*)))
(defun rogue-twin (id) "ID's twin card, or NIL." (third (assoc id *rogue-kai*)))

(defparameter *rogue-traits*
  ;; (id name (needs...) mods...): on while every reward it needs is held, no tier, no slot (§4.1, §4.2)
  '((:a "SHISEN" (4 9) (:red-dmg :x 1.35) (:red-armor :min 5.0))                      ; 死線 背水 + 不屈
    (:b "SHUNKO" (5 13) (:post-burst-dmg :x 1.45) (:post-burst-fs :+ 0.15))           ; 瞬閧 追擊 + 疾風
    (:c "MANKA" (21 2) (:ender-sp-dmg :x 1.40))                                       ; 卍禍 必殺 + 連撃
    (:d "KIDO" (8 10) (:perfect-taken :x 0.40))                                       ; 鬼道 見切 + 鐵甲
    (:e "SHURA" (22 6) (:kikon-past :+ 2) (:konpaku-cap :min 6))                      ; 修羅 血契 + 斷魂
    (:f "SAIKO SAIKYO" (28 12 6) (:sb-past :+ 1))                                     ; 最古最強 魄鎧 + 殘心 + 斷魂
    (:g "SHINKEN SHOBU" (4 28 22) (:both-reishi :x 0.5) (:kikon-seal :flag t) (:dmg :x 1.30))   ; 真劍勝負
    (:h "KENPACHI" (9 4 27) (:red-armor :min 2.0) (:red-dmg :x 1.40) (:red-no-guard :flag t)))  ; 劍八 不屈 + 背水 + 覇氣
  "The 8 traits: pairs A-E, composites F-H (DUEL_ROGUE §4.2), their prerequisites (reward ids) and §4.4 keys.")

(defun rogue-reward (id) "The reward row of ID." (assoc id *rogue-rewards*))
(defun rogue-reward-cat (id) "ID's category." (second (rogue-reward id)))
(defun rogue-reward-name (id) "ID's (romanized) name." (third (rogue-reward id)))
(defun rogue-rare-only-p (id) "Is ID offered only on a RARE offer (斷魂, 殘心, 魄鎧)?" (fourth (rogue-reward id)))
(defun rogue-reward-mods (id) "ID's mods, (key kind value [role]) each." (nthcdr 4 (rogue-reward id)))
(defun rogue-tierable-p (id)
  "Does ID's tier change anything: a scaling benefit (not a flag, a count or a cost) or 殘心's revive? (魄鎧, 斷魂, 時契,
捨身, 賭契 do not: they are never an UPGRADE.)"
  (some (lambda (m) (and (member (fourth m) '(nil :revive)) (not (eq (second m) :flag)))) (rogue-reward-mods id)))

(defun rogue-mod-value (m tier)
  "Mod M's value at TIER: a benefit scaled by *ROGUE-TIER-SCALE* (x: 1 + (v - 1) s; +: v s), 殘心's revive 1 / LEGEND 2,
a cost or a count as it is."
  (destructuring-bind (key kind v &optional role) m
    (declare (ignore key))
    (let ((s (nth tier *rogue-tier-scale*)))
      (case role
        ((:cost :count) v)
        (:revive (if (= tier 2) 2 1))
        (t (case kind (:x (+ 1.0 (* (- v 1.0) s))) (:+ (* v s)) (t v)))))))

(defun rogue-held-ids (held) "The reward ids of HELD ((id . tier) each)." (mapcar #'car held))
(defun rogue-traits-on (held)
  "The traits HELD switches on: each whose every prerequisite is held (DUEL_ROGUE §4.1)."
  (let ((ids (rogue-held-ids held)))
    (loop for tr in *rogue-traits* when (subsetp (third tr) ids) collect (first tr))))

(defun rogue-fold (plist key kind v)
  "PLIST with mod KEY KIND V stacked in (§4.4: x multiplies, + adds, flags OR, :min the smaller, :clear 0 wins)."
  (let ((old (getf plist key)))
    (setf (getf plist key)
          (if (null old) v
              (case kind (:x (* old v)) (:+ (+ old v)) (:flag t) (:min (min old v))
                (:clear (if (or (eql old 0) (eql v 0)) 0 (max old v))))))
    plist))

(defun rogue-mods (held)
  "The run modifier plist (DUEL_ROGUE §4.4) of HELD ((id . tier) each): every held reward's mods at its tier, then the
traits it switches on, stacked by ROGUE-FOLD in table order (the same set gives the same floats whatever the pick
order). Only keys some reward sets appear; NIL when nothing is held."
  (let ((out nil))
    (dolist (r *rogue-rewards*)
      (let ((h (assoc (first r) held)))
        (when h (dolist (m (nthcdr 4 r)) (setf out (rogue-fold out (first m) (second m) (rogue-mod-value m (cdr h))))))))
    (dolist (tr *rogue-traits*)
      (when (member (first tr) (rogue-traits-on held))
        (dolist (m (nthcdr 3 tr)) (setf out (rogue-fold out (first m) (second m) (third m))))))
    out))

(defun rogue-slots (cat) "CAT's slot count." (or (cdr (assoc cat *rogue-slots*)) 0))
(defun rogue-cat-held (held cat) "HELD's rewards of category CAT ((id . tier) each)." (remove-if-not (lambda (h) (eq cat (rogue-reward-cat (car h)))) held))
(defun rogue-cat-full-p (held cat) "Are CAT's slots all taken in HELD?" (>= (length (rogue-cat-held held cat)) (rogue-slots cat)))

(defun rogue-completes (held id)
  "The first trait not on in HELD that taking ID would switch on (the card names it: `+ SHISEN`), else NIL."
  (let ((on (rogue-traits-on held)) (ids (cons id (rogue-held-ids held))))
    (loop for tr in *rogue-traits*
          when (and (not (member (first tr) on)) (member id (third tr)) (subsetp (third tr) ids)) return (first tr))))

(defun rogue-offer (seed step salt held rare &optional char)
  "An offer of up to 3 cards after STEP of run SEED (SALT: the pick's index, 賭契's extra pick 1), from the run's own
LCG: plists (:id :tier :kind :trait). :kind :new (a free slot), :replace (its category full: taking it drops one held
of the category), :upgrade (RARE offers only: a held tierable reward below LEGEND comes back one tier up; a held one is
never offered otherwise), :twin (a 解 card whose twin is held: taking it swaps them). Never the same reward twice; RARE+
only rewards (斷魂, 殘心, 魄鎧) only when RARE; 解 cards only of CHAR (P1's character; NIL: none); a RARE offer's new
cards are RARE (tier 1), a GENERIC offer's COMMON."
  (let* ((tier (if rare 1 0))
         (cands (loop for r in *rogue-rewards* for id = (first r) for h = (assoc id held) for kc = (rogue-kai-char id)
                      for c = (cond ((and kc (not (eq kc char))) nil)
                                    (h (when (and rare (rogue-tierable-p id) (< (cdr h) 2))
                                         (list :id id :tier (1+ (cdr h)) :kind :upgrade :trait nil)))
                                    ((and (rogue-rare-only-p id) (not rare)) nil)
                                    ((and kc (assoc (rogue-twin id) held)) (list :id id :tier 0 :kind :twin :trait nil))
                                    (t (list :id id :tier tier
                                             :kind (if (rogue-cat-full-p held (second r)) :replace :new)
                                             :trait (rogue-completes held id))))
                      when c collect c))
         (v (coerce cands 'simple-vector)) (x (rogue-lcg-at seed step (+ 10 salt))))
    (loop for i from (1- (length v)) downto 1                  ; Fisher-Yates on the run's LCG
          do (setf x (endless-lcg x)) (rotatef (svref v i) (svref v (mod (floor x 65536) (1+ i)))))
    (subseq (coerce v 'list) 0 (min 3 (length v)))))

(defun rogue-take-card (held card &optional drop)
  "HELD after taking CARD (ROGUE-OFFER's plist): :upgrade raises its reward a tier (LEGEND the top); :new adds it;
:replace drops DROP (a held reward id of the same category, back into the pool) and adds it; :twin drops its held twin
(back into the pool) and adds it. HELD is never changed."
  (let ((id (getf card :id)) (tier (getf card :tier)))
    (ecase (getf card :kind)
      (:twin (append (remove (rogue-twin id) held :key #'car) (list (cons id tier))))
      (:upgrade (mapcar (lambda (h) (if (eql (car h) id) (cons id (min 2 tier)) h)) held))
      (:new (append held (list (cons id tier))))
      (:replace (assert (and drop (eq (rogue-reward-cat drop) (rogue-reward-cat id)) (assoc drop held)))
       (append (remove drop held :key #'car) (list (cons id tier)))))))

(defun rogue-upgradable (held) "HELD's rewards a rest's UPGRADE can raise: tierable, below LEGEND (ids)." (loop for (id . tier) in held when (and (rogue-tierable-p id) (< tier 2)) collect id))
(defun rogue-upgrade (held id) "HELD with reward ID one tier up (at most LEGEND)." (mapcar (lambda (h) (if (eql (car h) id) (cons id (min 2 (1+ (cdr h)))) h)) held))

(defun rogue-clear-konpaku (konpaku mods)
  "P1's Konpaku after a clear in a run with MODS: + its :clear-konpaku (2; 時契 3, 賭契 0), at most its :konpaku-cap and
*KONPAKU-MAX* (ENDLESS's carry with the pacts in)."
  (min (getf mods :konpaku-cap *konpaku-max*) *konpaku-max* (+ konpaku (getf mods :clear-konpaku 2))))
