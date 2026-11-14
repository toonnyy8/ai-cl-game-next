(in-package :duel)

(defvar *fails* 0)
(defvar *checks* 0)
(defmacro check (form)
  `(progn (incf *checks*) (unless ,form (incf *fails*) (format t "FAIL: ~s~%" ',form))))
(defun ~= (a b &optional (eps 1e-3)) (< (abs (- a b)) eps))
(defun kit (c f) (find-kit c f))
(defun mv (c f name) (kit-move (kit c f) name))
(defparameter *forms* '((:kenpachi :base) (:kenpachi :nozarashi) (:kenpachi :bankai) (:kenpachi :bankai-2)   ; (the cups and KATAUDE went 2026-11-03;
                                                                                                ;  V3's two Bankai, DUEL_KEN_V3 §26)
                        (:ichigo :base) (:ichigo :kessa)
                        (:hisagi :base) (:hisagi :bankai) (:hisagi :bankai-bind)))   ; (Hisagi's Shikai, B2a: DUEL_HISAGI §8;
                                                                ;  his Bankai's two modes, B2b: §17; the four retired kits' forms
                                                                ;  left with their code, 2026-11-12: branch `retired-kits`)
(defun owl-adv (cf) "The frame advantage CF's J / K add to DUEL_STRINGS's budget (the owl's +1 left with Lille, 2026-11-12): 0." (declare (ignore cf)) 0)
(defun trace-form-p (cf)
  "Is CF a form whose J / K strings lay traces instead of hitting: its J1 has no hit window? The hit-based string checks skip it."
  (zerop (length (mv-hits (kit-command-move (apply #'kit cf) :q)))))   ; (Lille II v3: his stance EN's strings,
                                                                                  ;  DUEL_LILLE_V3 R2: own block below)

;;; ================================================================ the triangle / clash matrix
(check (eq (resolve-contact :neutral) :hit))
(check (eq (resolve-contact :guard) :blocked))                            ; guard > attack
(check (eq (resolve-contact :guard :in-front nil) :hit))                  ; ... only from the front
(check (eq (resolve-contact :guard :breaker t) :guard-break))             ; breaker > guard
(check (eq (resolve-contact :guard :guard-crush t) :guard-break))         ; crushing stance / SP2 hold
(check (eq (resolve-contact :breaker) :counter))                          ; attack > breaker
(check (eq (resolve-contact :neutral :breaker t) :hit))                   ; 150 + knockback
(check (eq (resolve-contact :stance) :absorbed))                          ; super armour, stores
(check (eq (resolve-contact :stance :breaker t) :stance-break))           ; breaker breaks the stance
(check (eq (resolve-contact :stance-in) :counter))
(check (eq (resolve-contact :stance-in :breaker t) :stance-break))
(check (null (resolve-contact :invuln :breaker t)))
;; Bankai West's ward (the rework, the user's decisions 2026-09-27): the defender reports :guard (DEFENDER-STATE); the
;; ward covers 360 deg (a hit from behind is blocked), a Breaker / guard-crush breaks it, an unguardable (the bind, a red
;; victim's Kikon follow-up) goes through, a hazard in the parry's window is blocked (a plain parry lets it hit), a
;; melee hit in the window is parried, iframes still dodge
(check (and (eq (resolve-contact :guard :in-front nil :ward t) :blocked) (eq (resolve-contact :guard :in-front nil) :hit)
            (eq (resolve-contact :guard :hazard t :in-front nil :ward t) :blocked)
            (eq (resolve-contact :guard :breaker t :in-front nil :ward t) :guard-break)
            (eq (resolve-contact :guard :guard-crush t :ward t) :guard-break)
            (eq (resolve-contact :guard :unguardable t :ward t) :hit)
            (eq (resolve-contact :parry :hazard t :ward t) :blocked) (eq (resolve-contact :parry :hazard t) :hit)
            (eq (resolve-contact :parry :ward t) :parried) (eq (resolve-contact :parry :unguardable t :ward t) :hit)
            (null (resolve-contact :invuln :ward t))))
;; the melee / ranged split (the user's decision 2026-09-26): the Meteor's cleaver within 3.4 m, the cash-out's within
;; 3.9 m, Buttagiru's within 2.6 m, Nadegiri's within 2.4 m are melee; beyond, the line. (They were the J1 reaches of their
;; forms until the J cut of 2026-09-29, docs/duel/DUEL_STRINGS.md §13: an SP's own blade, so they stay)
(check (and (ranged-hit-p t nil nil 0.0) (not (ranged-hit-p nil nil nil 100.0)) (ranged-hit-p nil '(:ranged) nil 1.0)
            (not (ranged-hit-p nil '(:ranged) 3.4 (* 3.4 3.4))) (ranged-hit-p nil '(:ranged) 3.4 (* 3.5 3.5))))
(flet ((mr (name) (getf (mv-params (find-move name)) :melee-range)))
  (check (~= (mr :ke-buttagiru) 2.6)))        ; (the old meteor's 3.4 went 2026-11-05, DUEL_KEN_V3 §43; Nadegiri's 2.4 with Yamamoto, 2026-11-12)
;; the contact rule: only a real hit is a hit for the attacker (armour, absorb, parry, block are :block)
(check (every (lambda (r) (eq (contact-of r) :hit)) '(:hit :counter :guard-break :stance-break :kikon)))
(check (every (lambda (r) (eq (contact-of r) :block)) '(:blocked :armored :absorbed :parried)))
(check (null (contact-of nil)))
(check (not (chain-open-p 12 9 3 12 (contact-of :armored))))            ; armour never opens hit timing
(check (breaker-clash-p :dash :strike 2.5))
(check (not (breaker-clash-p :dash :aura 1.0)))
(check (not (breaker-clash-p :dash :dash 3.5)))
;; the Breaker's pre-strike phases
(check (and (eq (breaker-next-phase :aura 11 t 9.0) :aura) (eq (breaker-next-phase :aura 12 t 9.0) :dash)))
(check (eq (breaker-next-phase :dash 20 t 9.0) :dash))
(check (eq (breaker-next-phase :dash 1 t 0.9) :strike))                   ; in range
(check (eq (breaker-next-phase :dash 5 nil 9.0) :dash))                   ; a tap still dashes a bit
(check (eq (breaker-next-phase :dash 12 nil 9.0) :strike))
(check (eq (breaker-next-phase :dash 45 t 9.0) :strike))
(check (and (~= (breaker-speed 0) 9.0) (~= (breaker-speed 45) 10.0)))
;; a Q1 thrown on seeing the aura beats the fastest Breaker (aura 12 + strike startup 8)
(check (< (mv-s (mv :kenpachi :base :ke-j1)) (+ *breaker-aura* *breaker-startup*)))   ; (Kenpachi's J1 now; Yamamoto's before)
;; 防 > J > I > 防 (the user, 2026-09-29; docs/duel/DUEL_STRINGS.md §14): guard blocks J (above), a Breaker breaks the guard
;; (above), and J beats the grab: in every form with a Breaker its strike reaches less far than J1, and J1 has a press
;; window against the dash: the Breaker's aura, dash and strike startup are :breaker (any hit counters it), so J1 connects
;; when its last active frame meets the dash inside J1's reach + the thinnest hurt radius (0.34, Rukia's) and its first
;; active frame comes before the strike's (the dash stops at *BREAKER-TRIGGER*, then *BREAKER-STARTUP* frames). The dash
;; at its fastest (*BREAKER-SPEED-MAX*); the trigger clears the widest pair of hurt radii (0.9: both Kenpachi) and a
;; triggered strike reaches the thinnest
(check (and (> *breaker-trigger* 0.9) (> (+ *breaker-reach* 0.34) *breaker-trigger*)))
(dolist (cf *forms*)
  (let* ((k (apply #'kit cf)) (br (kit-command-move k :breaker)) (j1 (kit-command-move k :q)))
    (when br   ; (Lille II's ranged J is J1 in place again: DUEL_LILLE_V2 decision V6a; V6's TENSHIN in skipped it)
      (let* ((v (/ *breaker-speed-max* 60.0)) (s (mv-s j1)) (a (mv-a j1))
             (d-hi (+ (mv-reach j1) 0.34 (* v (+ s a -1))))              ; the farthest press: its last active frame meets him
             (d-lo (+ *breaker-trigger* (* v (max 0 (- s (mv-s br)))))))  ; the nearest: J1 hits before the strike does
        (check (or (and (< (mv-reach br) (mv-reach j1)) (> (+ (mv-reach j1) 0.34) *breaker-trigger*) (< d-lo d-hi))
                   (format t "~a: grab ~,2f m, J1 ~,2f m S ~d, window ~,2f..~,2f m~%" cf (mv-reach br) (mv-reach j1) s d-lo d-hi)))))))

;;; ================================================================ block / whiff advantage
(check (= (blockstun 24 9 -2) 13))
(check (= (hitstun :flinch) 18))
(check (= (hitstun :stagger t) 36))                                     ; counter-hit +10
(check (= (recovery-frames 12 t) 12))
(check (= (recovery-frames 12 nil) 18))                                 ; whiff = R + 6
(check (= (recovery-frames 18 nil 30) 30))                              ; Breaker whiff 30
(check (and (chain-open-p 12 9 3 12 :hit) (not (chain-open-p 11 9 3 12 :hit))))
;; the contact gate (docs/duel/DUEL_STRINGS.md §2.2): a whiff never chains, at any frame
(check (loop for sf from 0 to 30 never (chain-open-p sf 9 3 12 nil)))
(check (and (chain-open-p 21 9 3 12 :block) (not (chain-open-p 20 9 3 12 :block))
            (not (chain-open-p 24 9 3 12 :block))))
;; the string gate (2026-09-28): a follow-up link (T: an earlier link touched him) carries the string even when it
;; whiffed, at block timing; link 1's whiff (NIL) still never chains
(check (and (chain-open-p 21 9 3 12 t) (not (chain-open-p 20 9 3 12 t)) (not (chain-open-p 24 9 3 12 t))))
;; the follow-up's chase: reach its hit window, clamped, never past him
(let ((g (max *lunge-stop* (- 2.6 *chase-margin*))))
  (check (~= (string-chase-speed (+ g 1.4) 2.6 7) (* 60.0 (/ 1.4 7))))            ; arrives exactly at the hit frame
  (check (~= (string-chase-speed 20.0 2.6 7) *chase-max*))                        ; clamped
  (check (zerop (string-chase-speed g 2.6 7)))                                     ; close enough: no motion
  (check (zerop (string-chase-speed 5.0 2.6 0)))                                   ; not after the startup
  (check (<= (/ (string-chase-speed 3.0 2.6 1) 60.0) (- 3.0 g)))                  ; one frame never overshoots the goal
  (check (zerop (string-chase-speed *lunge-stop* 1.2 5)))                          ; a short reach stops at *LUNGE-STOP*
  ;; simulated: a frame at a time from 6 m, he ends inside the reach by the hit and never nearer than the goal
  (let ((d 6.0))
    (loop for left from 14 downto 1 do (decf d (/ (string-chase-speed d 2.6 left) 60.0)))
    (check (and (<= d 2.6) (>= d (- g 1e-4))))))
(check (and (cancel-open-p 9 9 24 t) (cancel-open-p 23 9 24 t) (not (cancel-open-p 24 9 24 t))
            (not (cancel-open-p 10 9 24 nil))))
(check (and (invulnerable-frame-p 3 *step-iframes*) (invulnerable-frame-p 9 *step-iframes*)
            (not (invulnerable-frame-p 10 *step-iframes*)) (invulnerable-frame-p 14 *hoho-iframes*)
            (not (invulnerable-frame-p 0 *hoho-iframes*))))
;; Frame advantage end to end, as far as it is pure: replay how the fighters step (fighter.lisp
;; MAIN-PHASE-STEP / STUN-STEP: a move starts on step 0 at frame ENTER, +1 frame per step, idles on the
;; step its frame reaches MOVE-END-FRAME; blockstun starts on the hit's step at 0 and idles when it
;; reaches the stun; either side acts on the step after it idles). The headless twin: debug 2315+k.
(defun free-steps (mv)
  "MV blocked on its first hit frame: values the attacker's and the defender's first actionable
step, counted from the move's first step."
  (let* ((enter (mv-enter mv)) (h (- (mv-first-hit mv) enter))
         (end (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) :block nil))
         (stun (blockstun (mv-total mv) (mv-first-hit mv) (mv-adv-block mv))))
    (values (loop for step from 1 when (>= (+ enter step) end) return (1+ step))
            (loop for step from (1+ h) for sf from 1 when (>= sf stun) return (1+ step)))))
(dolist (cf *forms*)
  (maphash (lambda (name m)
             (when (and (integerp (mv-adv-block m)) (plusp (length (mv-hits m))))
               (multiple-value-bind (att def) (free-steps m)
                 (check (or (= (- def att) (mv-adv-block m))        ; the §5 table's number, exactly
                            (format t "~a ~a: block advantage ~d, its :adv-block ~d~%" cf name (- def att) (mv-adv-block m)))))))
           (kit-moves (apply #'kit cf))))
(defun blocked-gap (a b)
         "Steps the defender is free before B's first active frame when A's -2 hit is blocked and the
string goes on at the earliest chain frame (B starts on that step, frame 0)."
         (multiple-value-bind (att def) (free-steps a)
           (declare (ignore att))
           (- (+ (- (mv-total a) (mv-enter a) *chain-lead*) (- (mv-s b) (mv-enter b))) def)))
(defun hit-gap (a b)
         "Frames between the victim leaving hitstun and B's first active frame (< 0 = a combo)."
         (let ((h (mv-first-hit a)))
           (- (+ (mv-s a) (mv-a a) (- (mv-s b) (mv-enter b)))
              (+ h 1 (let ((w (svref (mv-hits a) 0))) (or (hw-stun w) (hitstun (hw-react w))))))))   ; (a window's :stun)
;;; ---------------------------------------------------------------- the J / K strings (docs/duel/DUEL_STRINGS.md §2, §3)
(defun link-moves (k)
  "Every string link of kit K reachable from J1 / K1: a list of (move link-number button-sequence)."
  (let ((out nil))
    (labels ((walk (m n seq)
               (push (list m n seq) out)
               (dolist (c '(:q :f))
                 (let ((nx (kit-next k (mv-name m) c)))
                   (when nx (walk nx (1+ n) (append seq (list c))))))))
      (walk (kit-command-move k :q) 1 '(:q))
      (let ((k1 (kit-command-move k :f))) (when k1 (walk k1 1 '(:f)))))   ; (no K: Hisagi's Bankai since §28.4)
    (nreverse out)))
(defun route (k first presses)
  "The links a string plays when every link makes contact: FIRST (:q / :f) from neutral, then per link the J / K
presses made during it (STRING-LATCH: the last allowed press wins, a press after a switch of the old button is eaten)."
  (let* ((m (kit-command-move k first)) (out (list (mv-name m))))
    (dolist (ps presses (nreverse out))
      (let ((q nil))
        (when (string-link-p k (mv-name m))
          (dolist (c ps) (setf q (string-latch k (mv-name m) c q))))
        (unless q (return (nreverse out)))
        (setf m (kit-next k (mv-name m) q))
        (push (mv-name m) out)))))
(defun on-hit-adv (m &optional (i 0))
  (let ((w (svref (mv-hits m) i))) (- (or (hw-stun w) (hitstun (hw-react w))) (- (mv-total m) (hw-from w)))))
;; the Shikai derives nothing since V3 (startup +0, reach x1.0, DUEL_KEN_V3 §9): the base moves it inherits are the base's (KATATE's +2 / x1.3
;; went with the cups, 2026-11-03)
(let ((t1 (kit :kenpachi :nozarashi)))
  (check (and (= 7 (mv-s (kit-move t1 :ke-j1))) (= 16 (mv-s (kit-move t1 :ke-k1))) (= 6 (mv-enter (kit-move t1 :ke-k2))))))
;; the route damage of Kenpachi base on hit (§3.5, before multipliers; the combo scaling starts at hit 4; K2 / K3 at 80 %
;; of the design's, §9): JJJ 112, KKK 210 (the design's 245), KJJ 147; the O ender as hit 4 x0.9 = 63
(flet ((dmg (&rest names) (loop for n in names for i from 1 sum (hit-damage (mv-dmg (mv :kenpachi :base n)) nil nil i nil))))
  (check (and (= 112 (dmg :ke-j1 :ke-j2 :ke-j3)) (= 210 (dmg :ke-k1 :ke-k2 :ke-k3)) (= 147 (dmg :ke-k1 :ke-j2s :ke-j3))
              (= 60 (hit-damage 70 nil nil 4 nil)))))
(check (~= (mv-clip-speed (mv :kenpachi :nozarashi :ke-s-j1)) 1.0))  ; its own clip, authored at its startup 9 (DUEL_KEN_V3 §15)
(check (~= (mv-clip-speed (mv :kenpachi :base :ke-j1)) 1.0))
(check (= 24 (loop for n in '(:ke-j1 :ke-j2 :ke-j3) sum (hw-guard (svref (mv-hits (mv :kenpachi :base n)) 0)))))
(check (= (move-end-frame 9 3 12 18 nil nil) 30))                      ; whiff: R + 6
(check (and (= (move-end-frame 9 3 12 18 :block nil) 24) (= (move-end-frame 2 1 20 26 nil t) 23)))

;;; ================================================================ damage (§4)
(check (and (~= (combo-scale 1) 1.0) (~= (combo-scale 3) 1.0) (~= (combo-scale 4) 0.85) (~= (combo-scale 6) 0.55) (~= (combo-scale 7) 0.4)
            (~= (combo-scale 8) 0.25) (~= (combo-scale 9) 0.2) (~= (combo-scale 12) 0.2)))
;; ORANGE (the user 2026-10-24: 「橙色爆氣會將減免補正重置，且期間減免速度改成 10%、最低 50%」): -10 % a hit, 50 % floor
(check (and (~= (combo-scale 3 t) 1.0) (~= (combo-scale 4 t) 0.9) (~= (combo-scale 7 t) 0.6) (~= (combo-scale 8 t) 0.5)
            (~= (combo-scale 20 t) 0.5) (= 50 (hit-damage 100 nil nil 20 nil t))))
;; every SP ignores the combo scaling (the user 2026-10-24: 「所有角色的 SP 也都設置成不受傷害減免影響」): kind :sp, or the
;; form's SP1 / SP2 command of another kind (Hisagi's ranged KUBIKAKE, Lille's SHIN recall); never a J / K / L
(check (and (sp-move-p (kit :ichigo :kessa) (find-move :ic-k-zanzo))
            (not (sp-move-p (kit :hisagi :bankai) (find-move :hs-r-k1)))))
;; Hisagi's Bankai ranged mode: a chain-tip hit ignores the combo scaling (the user 2026-10-25: 「修兵卍解遠距的尖端判定也設成
;; 不受連擊衰減的影響」): its :unscaled hook, after :dmg-mult read the tip (HS-TIP-NOW-P); no other kit has the hook
(check (and (eq 'hs-tip-now-p (kit-hook (kit :hisagi :bankai) :unscaled))
            (every (lambda (k) (or (eq (kit-character k) :hisagi) (null (kit-hook k :unscaled))))
                   (loop for al being the hash-values of *kits* append (mapcar #'cdr al)))))
(check (= (hit-damage 100 nil nil 1 nil) 100))
(check (= (hit-damage 100 '(:mult 1.3) nil 1 nil) 130))                 ; Hellfire
(check (= (hit-damage 100 '(:cornered 0.05 :cornered-max 0.25 :lost 2) nil 1 nil) 110))
(check (= (hit-damage 100 '(:cornered 0.05 :cornered-max 0.25 :lost 6) nil 1 nil) 125))   ; capped
(check (= (hit-damage 100 '(:mult 1.15 :cornered 0.05 :cornered-max 0.25 :lost 3) nil 5 t) 116)) ; x1.15x1.15x1.25x0.7 (hit 5: 0.8 until 2026-10-24's -15 %)
(check (= (hit-damage 100 nil nil 20 nil) 20))                          ; floor 20 % (40 % until 2026-10-24)
(check (= (hit-damage 1 nil nil 12 nil) 1))                             ; a hit always does 1
(check (= (hit-damage 0 '(:mult 2.0) nil 1 t) 0))
     ; East x1.0 (the rework)
(check (= (hit-damage 100 (kit-atk-mods (kit :kenpachi :nozarashi) 4) nil 1 nil) 60))   ; the Shikai x1.0 x the core scale (*CORE-DAMAGE* 0.42 x his :core :mult 1.2) x Cornered 1.20 = 60.48 (120 before the scale, the old *CORE-ON* NIL)
(check (= (chip-damage 110 *chip-fire* 500) 13))
(check (and (= (chip-damage 110 0.12 5) 4) (= (chip-damage 110 0.12 1) 0)))   ; chip never kills
(check (= (chip-damage 110 nil 500) 0))                                  ; no chip by default
(check (= 500 (loop for s below 600 sum (burn-amount 1000 *hellfire-burn* s))))  ; 5 %/s x 10 s
(check (= 20 (loop for s below 60 sum (burn-amount 1000 0.02 s))))        ; 2 %/s x 1 s
(check (and (= (burn 30 50) 1) (= (burn 1 5) 1) (= (burn 500 30) 470)))  ; burns floor at 1
(check (= (cornered-mult 0.05 10 0.25) 1.25))

;;; ================================================================ Kikon, Konpaku, Soul Break, time-up
(let ((*red-threshold* 0.30))                  ; the rule at the design value (tuning.lisp may differ)
  (check (and (red-p 299 1000) (not (red-p 300 1000)))))
;; the Kikon rush strike (the user's rule, with the lead's dash-in): the first strike is always guardable; guarded
;; -> nothing; a hit with O held knocks him back and the rusher dashes in to the follow-up, whose hit is the Kikon;
;; released -> a plain hit
(check (eq (kikon-outcome t :hit nil) :follow))
(check (eq (kikon-outcome t :counter nil) :follow))                        ; (a Breaker's startup)
(check (eq (kikon-outcome nil :hit t) :kikon))                             ; the follow-up hit: the Kikon
(check (eq (kikon-outcome t :hit t) :kikon))
(check (null (kikon-outcome nil :hit nil)))                                ; released: a plain hit
(check (notany (lambda (r) (or (kikon-outcome t r nil) (kikon-outcome t r t)))
               '(nil :blocked :absorbed :armored :parried :guard-break)))  ; guarded / dodged: nothing
;; the dash-in (2026-10-24: 「O 到毀魂技的空檔延長」, gap 12 -> 24, the strike 41 f after the O's hit): every victim reels
;; until the strike has landed, locked (KIKON-LOCK-P): not red, U cancels the reel into a guard that blocks it; red,
;; nothing, and the strike can't be guarded (iframes still dodge it)
(check (and (= 24 *kikon-follow-gap*) (= 41 (+ *kikon-follow-stun* 1 *kikon-follow-gap*))
            (= (kikon-follow-wait 6) (- (+ *kikon-follow-stun* 1 *kikon-follow-gap*) 6))
            (= (kikon-follow-wait 99) 0) (~= *kikon-follow-kb* 2.5)))
;; the lock holds while the rusher dashes in (:follow) and until his follow-up strike connected or its active frames
;; are over; never off any other move or state
(check (and (kikon-lock-p :move t :follow nil 0 8 3) (kikon-lock-p :move t :main nil 10 8 3)
            (not (kikon-lock-p :move t :main :hit 10 8 3)) (not (kikon-lock-p :move t :main :block 9 8 3))
            (not (kikon-lock-p :move t :main nil 11 8 3)) (not (kikon-lock-p :move nil :follow nil 0 8 3))
            (not (kikon-lock-p :move nil :main nil 2 8 3)) (not (kikon-lock-p :idle t :follow nil 0 8 3))
            (not (kikon-lock-p :stun t :main nil 2 8 3))))
(check (and (null (kikon-follow-unguardable-p nil)) (kikon-follow-unguardable-p t)))
(check (and (eq (resolve-contact :guard :unguardable (kikon-follow-unguardable-p nil)) :blocked)     ; not red: blocked
            (eq (resolve-contact :guard :unguardable (kikon-follow-unguardable-p t)) :hit)           ; red: the Kikon
            (eq (resolve-contact :stance :unguardable (kikon-follow-unguardable-p t)) :hit)
            (eq (resolve-contact :parry :unguardable (kikon-follow-unguardable-p t)) :hit)
            (null (resolve-contact :invuln :unguardable (kikon-follow-unguardable-p t)))))
(dolist (cf *forms*)
  (let ((s (let ((o (kit-command-move (apply #'kit cf) :kikon))) (and o (mv-s o)))))             ; (none: Kenpachi's, 2026-11-05)
    (when s
      (check (= (kikon-follow-stun nil s) (kikon-follow-stun t s)))                                 ; (2026-10-24: both reel)
      (check (> (kikon-follow-stun t s) (+ (kikon-follow-wait s) s))))))                            ; still reeling as it lands
;; the dash-in's speed: it reaches the trigger range exactly as the wait runs out, never over the module's cap
(check (and (~= (kikon-follow-speed 4.6 10 99.0) 18.0) (~= (kikon-follow-speed 4.6 10 12.0) 12.0)
            (~= (kikon-follow-speed 1.0 10 99.0) 0.0) (~= (kikon-follow-speed 4.6 0 99.0) 99.0)))
;; the strike is guardable: guard and stance stop it (no :unguardable any more); iframes dodge it
(check (eq (resolve-contact :guard) :blocked))
(check (eq (resolve-contact :guard :unguardable t) :hit))
(check (eq (resolve-contact :guard :unguardable nil) :blocked))
(check (eq (resolve-contact :stance :unguardable t) :hit))
(check (eq (resolve-contact :stance-in :unguardable t) :hit))
(check (null (resolve-contact :invuln :unguardable t)))
(check (eq (resolve-contact :breaker :unguardable t) :counter))
;; the rush's phases: the module's aura, then the strike at once when close (or no dash: ENJO), else
;; the dash to the trigger range or its end (the module's dash-max)
(flet ((nx (ph f d &optional (dm 22)) (kikon-rush-next-phase ph f d :aura 5 :dash-max dm)))
  (check (and (eq (nx :aura 4 9.0) :aura) (eq (nx :aura 5 9.0) :dash) (eq (nx :aura 5 *kikon-trigger*) :strike)
              (eq (nx :dash 3 9.0) :dash) (eq (nx :dash 3 (- *kikon-trigger* 0.1)) :strike) (eq (nx :dash 22 9.0) :strike)
              (eq (nx :aura 5 9.0 0) :strike))))                           ; no dash: strike after the aura
(check (and (~= (kikon-rush-reach 36.0 14) 10.0) (~= (kikon-rush-reach 13.0 36) 9.4) (~= (kikon-rush-reach 18.0 30) 10.6)))
;; armour: a move's armour takes hits (:armored) until its budget is spent; a Breaker, an unguardable hit
;; go through (nothing ignores armour: Nozarashi v2 removed :ignore-armor)
(check (and (eq (resolve-contact :armor) :armored) (eq (resolve-contact :armor :in-front nil) :armored)
            (eq (resolve-contact :armor :breaker t) :hit) (eq (resolve-contact :armor :unguardable t) :hit)))
(check (equal (multiple-value-list (kikon-result 6 2 nil)) '(4 2 nil)))
(check (equal (multiple-value-list (kikon-result 6 3 nil)) '(3 3 nil)))           ; awakened
(check (equal (multiple-value-list (kikon-result 6 2 t)) '(3 3 nil)))           ; Soul Break +1
(check (equal (multiple-value-list (kikon-result 6 4 t)) '(1 5 nil)))           ; KESSA's 3 clones: 4 + 1 = the cap 5
(check (equal (multiple-value-list (kikon-result 6 3 t)) '(2 4 nil)))
(check (equal (multiple-value-list (kikon-result 2 2 nil)) '(0 2 t)))
(check (equal (multiple-value-list (kikon-result 1 3 t)) '(0 1 t)))
(check (and (soul-break-p 0) (not (soul-break-p 1))))
;; the step's soul queues as SETTLE-SOULS takes them (BROKEN-SOULS; R15b): the order queued (the queues are pushed, newest
;; first), a Kikon's victim without a Soul Break on top, the queues themselves untouched
(check (equal (multiple-value-list (broken-souls nil nil)) '(nil nil)))
(let ((kq (list (list :x :y :m2) (list :a :b :m1))) (sq (list (cons :b :a) (cons :a :b))))
  (check (equal (multiple-value-list (broken-souls kq nil)) '(((:a :b :m1) (:x :y :m2)) nil)))
  (check (equal (multiple-value-list (broken-souls nil sq)) '(nil ((:a . :b) (:b . :a)))))   ; a lethal trade: both, P1's first
  (check (equal (multiple-value-list (broken-souls (list (list :a :b :m1)) sq)) '(((:a :b :m1)) ((:b . :a)))))   ; :b took the Kikon
  (check (and (equal kq '((:x :y :m2) (:a :b :m1))) (equal sq '((:b . :a) (:a . :b))))))
(check (eql (time-up-winner 3 100 1000 2 900 1000) 0))                   ; Konpaku first
(check (eql (time-up-winner 2 900 1000 3 100 1000) 1))
(check (eql (time-up-winner 2 600 1000 2 500 1000) 0))                   ; then Reishi %
(check (eql (time-up-winner 2 500 1000 2 525 1050) :draw))               ; 50 % each
(multiple-value-bind (ax az bx bz) (reset-placement 10.0 0.0 12.0 0.0)
  (check (and (~= ax -4.0) (~= az 0.0) (~= bx 4.0) (~= bz 0.0))))

;;; ================================================================ gauges
;; the combo bonus on a hit's gains (the user 2026-10-26: the taken side 「受傷值 x combo 加成」; +10 % a hit, at most x2; the Reiatsu by
;; the move's kind, 「依據每招式各自的基礎值 * combo 數加成」, left with the gauge, R6)
(check (and (~= 1.0 (combo-gain-mult 1)) (~= 1.0 (combo-gain-mult 0)) (~= 1.1 (combo-gain-mult 2)) (~= 1.5 (combo-gain-mult 6))
            (~= 2.0 (combo-gain-mult 11)) (~= 2.0 (combo-gain-mult 30))))
(multiple-value-bind (fs aw) (hit-gains 500 0 nil 1.0 1)                ; dealing: no flash-step, Fighting Spirit
  (multiple-value-bind (ft) (hit-gains 0 100 nil 1.0 6)                 ; taking 100 at the combo's 6th hit: flash-step 13.5 x 1.5
    (check (and (~= ft 20.25) (zerop fs) (plusp aw)))))
(check (~= (awakening-gain 100 100 1) 18.9))                                ; x0.7 since 2026-09-30 (was 27)
(check (and (~= *awaken-dealt* 0.035) (~= *awaken-taken* 0.049) (~= *awaken-per-konpaku* 10.5)))
(check (and (~= (gauge-add 290.0 20.0 300.0) 300.0) (~= (gauge-add 5.0 -10.0 300.0) 0.0)))
(check (and (hoho-allowed-p nil 100.0 0) (not (hoho-allowed-p t 300.0 0))          ; flash-step 100 (of 300)
            (not (hoho-allowed-p nil 300.0 10)) (not (hoho-allowed-p nil 99.0 0))))
(check (and (awaken-allowed-p t 100.0 nil) (not (awaken-allowed-p t 100.0 t)) (not (awaken-allowed-p nil 100.0 nil))
            (not (awaken-allowed-p t 99.0 nil))))
;; when the awakening may start (the user, 2026-11-14: 「挨第 1 下就能開」「自己出招中也能開」「Kikon 鎖定中也能開」「倒地／起身中也能開」):
;; every state of play (the first hit: :stun / :air carry no hit count here; a Kikon lock is :stun / :idle too), never under the input
;; lock, in a cinematic, his own Hoho, the intro / win / lose
(check (every (lambda (s) (awaken-state-ok-p s nil nil)) '(:idle :guard :guard-hit :stun :air :down :wakeup :move :step :run)))
(check (notany (lambda (s) (awaken-state-ok-p s nil nil)) '(:hoho :cine :intro :win :lose nil)))
(check (notany (lambda (s) (awaken-state-ok-p s t nil)) '(:idle :stun :air :move :down)))   ; the perfect-Hoho / reset lock
(check (notany (lambda (s) (awaken-state-ok-p s nil t)) '(:idle :stun :air :move :down)))   ; a cinematic running
(check (and (awaken-allowed-p (awaken-state-ok-p :stun nil nil) 100.0 nil) (not (awaken-allowed-p (awaken-state-ok-p :stun nil nil) 100.0 t))))
;; the burst modes (docs/duel/DUEL_DESIGN.md "Burst modes", the user 2026-09-30): the state picks the mode
(check (and (eq (burst-mode :stun nil 2 nil) :blue) (eq (burst-mode :air nil 3 nil) :blue) (null (burst-mode :stun nil 1 nil))
            (eq (burst-mode :guard-hit nil 0 nil) :blue)                        ; blockstun: from any blocked hit
            (eq (burst-mode :move nil 0 t) :orange) (null (burst-mode :move nil 0 nil))   ; a hit's window / a whiff or block
            (eq (burst-mode :idle nil 0 nil) :white) (eq (burst-mode :guard nil 0 nil) :white) (eq (burst-mode :run nil 0 nil) :white)
            (null (burst-mode :step nil 0 nil)) (null (burst-mode :hoho nil 0 nil)) (null (burst-mode :down nil 5 nil))
            (null (burst-mode :cine nil 0 nil)) (null (burst-mode :idle t 0 nil)) (null (burst-mode :stun t 5 nil))))   ; locked
(check (and (burst-allowed-p :white 100.0 nil) (burst-allowed-p :orange 100.0 nil) (burst-allowed-p :blue 100.0 nil)   ; one cell for every mode (S1, 2026-11-13)
            (burst-allowed-p :blue 300.0 nil)
            (not (burst-allowed-p :white 99.9 nil)) (not (burst-allowed-p :blue 99.0 nil)) (not (burst-allowed-p :orange 70.0 nil))
            (not (burst-allowed-p nil 300.0 nil)) (not (burst-allowed-p :white 300.0 :blue))))   ; no mode / one running
;; the drain: 54 / s, to 0 then it ends; from 200 3.7 s, from 300 5.6 s
(check (and (= *burst-drain* 54) (~= (burst-drain 50.0) (- 50.0 0.9)) (~= (burst-drain 0.1) 0.0)))
(flet ((frames (fs) (loop for n from 1 do (setf fs (burst-drain fs)) when (<= fs 0.0) return n)))
  (check (and (<= 110 (frames 100.0) 112) (<= 221 (frames 200.0) 223) (<= 332 (frames 300.0) 334))))   ; from one cell 1.85 s
;; no flash-step gain during a burst; Hoho below one bar spends what is left
(check (and (~= (burst-fs-gain 12.0 nil) 12.0) (~= (burst-fs-gain 12.0 :white) 0.0) (~= (burst-fs-gain 15.0 :orange) 0.0)))
(check (and (hoho-allowed-p nil 12.0 0 :white) (hoho-allowed-p nil 0.1 0 :blue) (not (hoho-allowed-p nil 0.0 0 :blue))
            (not (hoho-allowed-p nil 12.0 0)) (not (hoho-allowed-p nil 12.0 5 :white)) (not (hoho-allowed-p t 50.0 0 :white))))
(check (and (~= (hoho-cost 12.0 :white) 12.0) (~= (hoho-cost 180.0 :white) 100.0) (~= (hoho-cost 180.0 nil) 100.0)))
;; BLUE burns ONE cell (2026-11-12: 「將藍色爆氣改成只燃燒一格的量，期間發動閃步就將那燃燒中的格子用完…」); the others still drain to 0
(check (and (= *blue-burn* 100) (~= (burst-budget :blue) 100.0) (~= (burst-budget :white) 300.0) (~= (burst-budget :orange) 300.0)))
(flet ((run (fs burn) (loop for n from 1 do (multiple-value-setq (fs burn) (burst-burn fs burn))
                            when (or (<= fs 0.0) (<= burn 0.0)) return (list n fs burn))))
  (check (let ((r (run 100.0 100.0))) (and (<= 110 (first r) 112) (= (second r) 0.0) (<= (third r) 0.01))))        ; BLUE from exactly one cell: 100 -> 0
  (check (let ((r (run 100.0 300.0))) (and (<= 110 (first r) 112) (= (second r) 0.0) (~= (third r) 200.0 0.01))))   ; WHITE / ORANGE from one cell: to 0
  (check (let ((r (run 300.0 100.0))) (and (<= 111 (first r) 113) (~= (second r) 200.0) (= (third r) 0.0))))   ; 300 -> 200 in 1.85 s
  (check (let ((r (run 230.0 100.0))) (and (<= 111 (first r) 113) (~= (second r) 130.0) (= (third r) 0.0))))   ; 230 -> 130
  (check (let ((r (run 300.0 300.0))) (and (<= 332 (first r) 334) (= (second r) 0.0))))                        ; WHITE / ORANGE: to 0
  (check (let ((r (run 40.0 100.0))) (and (<= 44 (first r) 46) (= (second r) 0.0) (~= (third r) 60.0))))   ; the gauge ends it first
  (check (let ((r (run 0.5 100.0))) (and (= (second r) 0.0) (~= (third r) 99.5)))))
(check (and (~= (hoho-cost 300.0 :blue 60.0) 60.0) (~= (hoho-cost 300.0 :blue 100.0) 100.0) (~= (hoho-cost 300.0 :blue 0.5) 0.5)
            (~= (hoho-cost 30.0 :blue 60.0) 30.0) (~= (hoho-cost 300.0 :orange 60.0) 100.0) (~= (hoho-cost 300.0 :white) 100.0)))
;; WHITE: Reishi +12 / s in whole points (60 f pay exactly 12), no guard-gauge boost (gg-regen has no WHITE input)
(check (and (= 70 (loop for n from 1 to 60 sum (burst-heal n *white-reishi*))) (= 66 (loop for n from 1 to 333 sum (burst-heal n 12.0)))
            (= 1 (burst-heal 5 12.0)) (= 0 (burst-heal 4 12.0))))
(check (and (~= *white-reishi* 70.0) (~= *white-awaken* 1.4)))
;; BLUE: the guard gauge refills with no delay, x2 when free, x0.5 even while guarding (GUARD HOLD otherwise)
(check (and (~= (gg-regen 50.0 999 nil nil nil 0.25) (+ 50.0 (/ (* 0.25 *gg-regen*) 60)))   ; a form's :gg-regen (Bankai East)
            (~= (gg-regen 50.0 999 t nil nil 0.25) (+ 50.0 (/ *gg-regen-guardless* 60)))   ; (guardless: unchanged)
            ))
(check (and (~= (gg-regen 50.0 0 nil nil :blue) (+ 50.0 (/ 11.0 60))) (~= (gg-regen 50.0 0 nil t :blue) (+ 50.0 (/ 2.75 60)))
            (~= (gg-regen 50.0 0 t nil :blue) (+ 50.0 (/ 13.0 60))) (~= (gg-regen 99.99 0 nil t :blue) 100.0)
            (~= (gg-regen 50.0 999 nil t) 50.0)))                            ; outside BLUE: GUARD HOLD as ever
;; ORANGE: the cancel window is the hit's cancel window (first hit frame .. end of recovery); the startup cut 40 %, >= 1 f left
(check (and (cancel-open-p 12 10 30 t) (not (cancel-open-p 9 10 30 t)) (not (cancel-open-p 30 10 30 t)) (not (cancel-open-p 12 10 30 nil))))
;; the guard cancel (the user, 2026-10-01): after its own hit, over the last half of the recovery; the last three
;; quarters since 2026-10-23 (「將防禦取消提早」; K2 21/4/24: f31-48)
(check (and (= 0.75 *guard-cancel*) (not (guard-cancel-open-p 30 21 4 24 :hit)) (guard-cancel-open-p 31 21 4 24 :hit)
            (guard-cancel-open-p 48 21 4 24 :hit) (not (guard-cancel-open-p 49 21 4 24 :hit))
            (not (guard-cancel-open-p 40 21 4 24 :block)) (not (guard-cancel-open-p 40 21 4 24 nil))))
;; the arena's room for a push (RAY-ROOM): from the centre 5 to an r 5 edge; at 4 m out along +x, 1 left that way and 9 back
(check (and (< (abs (- (ray-room 0.0 0.0 1.0 0.0 5.0) 5.0)) 1e-4) (< (abs (- (ray-room 4.0 0.0 1.0 0.0 5.0) 1.0)) 1e-4)
            (< (abs (- (ray-room 4.0 0.0 -1.0 0.0 5.0) 9.0)) 1e-4) (= 0.0 (ray-room 5.0 0.0 1.0 0.0 5.0))))
;; a J (QUICK) may guard-cancel on block too (the user 2026-10-02): J1 9/3/12 opens f18-23; never on a whiff
;; 2026-10-23 (「拉長打空與被防禦的收招，但收招可以用防禦取消」; 「重度」, then 「調回中間」; 「將防禦取消提早」): a J / K / O blocked
;; recovers R + *BLOCK-ADD*, whiffed its whiff + *WHIFF-ADD*; both may guard-cancel over the last three quarters (J S9 A3
;; R12: blocked 16 from f16, whiffed 20 + 8 from f19)
(check (and (equal *block-add* '(:quick 4 :flash 6 :kikon 6)) (equal *whiff-add* '(:quick 8 :flash 8 :kikon 8))))
(check (and (guard-cancel-open-p 16 9 3 12 :block :quick) (not (guard-cancel-open-p 15 9 3 12 :block :quick))
            (guard-cancel-open-p 27 9 3 12 :block :quick) (not (guard-cancel-open-p 28 9 3 12 :block :quick))
            (guard-cancel-open-p 19 9 3 12 nil :quick 20) (not (guard-cancel-open-p 18 9 3 12 nil :quick 20))
            (guard-cancel-open-p 15 9 3 12 :hit :quick) (not (guard-cancel-open-p 14 9 3 12 :hit :quick))
            (not (guard-cancel-open-p 40 21 4 24 nil :sig 30)) (not (guard-cancel-open-p 40 21 4 24 :block :sp))))
(check (and (= (recovery-frames 12 :block nil :quick) 16) (= (recovery-frames 20 :block nil :flash) 26)
            (= (recovery-frames 24 :block nil :kikon) 30) (= (recovery-frames 12 :hit nil :quick) 12)
            (= (recovery-frames 12 nil 20 :quick) 28) (= (recovery-frames 20 nil 32 :flash) 40) (= (recovery-frames 30 nil 30 :kikon) 38)
            (= (recovery-frames 24 :block nil :sp) 24) (= (recovery-frames 24 nil 30 :sig) 30)))
(check (= (move-end-frame 9 3 12 20 :block nil :quick) 28))
(check (and (= (chain-startup-cut 10 0) 4) (= (chain-startup-cut 20 0) 8) (= (chain-startup-cut 2 0) 0) (= (chain-startup-cut 1 0) 0)
            (= (chain-startup-cut 3 0) 1) (= (chain-startup-cut 12 2) 4) (= *chain-window* 12)))
(check (and (~= (burst-gain-mult :orange) 1.5) (~= (burst-gain-mult :white) 1.0) (~= (burst-gain-mult nil) 1.0)))
(check (and (~= (nth-value 1 (hit-gains 100 0 nil 1.5)) 5.25)                   ; x1.5 dealt
            (~= (nth-value 0 (hit-gains 0 100 nil 1.5)) (nth-value 0 (hit-gains 0 100 nil 1.0)))))   ; taken untouched
;; (S3 2026-11-13: KOSEI left, the ATK gains replace it: tests/duel-rules/sp.lisp) the Kikon refund: a flash-step bar (105 of 300, 2026-10-29), clamped (its Reiatsu bar left, R6)
;; FS-GAIN, PAY-GAUGES' pure core (S3, Q18): nothing in a burst, x (1 + *sub-fs* x sub) otherwise
(check (and (~= (fs-gain 10.0 nil 0.0) 10.0) (~= (fs-gain 10.0 :blue 0.5) 0.0) (~= (fs-gain 10.0 nil 1.0) (* 10.0 (+ 1.0 *sub-fs*)))))
(check (and (= *kikon-fs-refund* 105.0) (~= (burst-fs-gain *kikon-fs-refund* nil) 105.0) (~= (burst-fs-gain *kikon-fs-refund* :white) 0.0)))
;; the flash-step gauge (design v3 G.1; 0-300 since 2026-10-29): Hoho 100, Burst 200, no Reiatsu; 9 / s after 60 f; +0.135 per damage taken
(check (and (= *fs-hoho* 100) (= *fs-burst* 100) (not (boundp '*fs-refund*)) (~= *fs-taken* 0.135) (= *fs-max* 300)))   ; (the 0-300 gauge, 2026-10-29)
(check (and (~= (fs-regen 50.0 59) 50.0) (~= (fs-regen 50.0 60) 50.075) (~= (fs-regen 99.99 600) 100.0)))
;; regen stops at the last cell (S1, 2026-11-13): 40 -> 100 and no further; a gauge above it is never lowered
(check (let ((f 40.0)) (dotimes (i 2000) (setf f (fs-regen f 600))) (~= f 100.0)))
(check (and (= (fs-regen 100.0 600) 100.0) (= (fs-regen 180.0 600) 180.0) (= (fs-regen 300.0 600) 300.0) (= (fs-regen 180.0 0) 180.0)))
(check (~= 4.5 (- (loop with f = 0.0 for i below 60 do (setf f (fs-regen f 60)) finally (return f)) 0.0)))   ; 4.5 per second (9 before 2026-11-12)
(check (~= 1333 (/ *fs-hoho* (/ *fs-regen* 60.0)) 0.5))                    ; ... a Hoho from empty in 23.2 s (22.2 + the 1 s delay; 12.1 s before 2026-11-12)
;; the guard gauge (G.2): values by kind, +4 for an ender, overrides; the drain, the crush, the regen, guardless
(check (and (= (guard-value :quick -2) 8) (= (guard-value :quick -12) 12) (= (guard-value :flash -4) 14)
            (= (guard-value :flash -14) 18) (= (guard-value :sig -6) 18) (= (guard-value :sig -14) 22)
            (= (guard-value :sp -16) 22) (= (guard-value :kikon -14) 20) (= (guard-value nil nil) 12)
            (= (guard-value :sig -6 10) 10)))
(check (and (= (hw-guard (svref (mv-hits (mv :kenpachi :base :ke-j3)) 0)) 8)             ; J3 (-4) 8
            (= (hw-guard (svref (mv-hits (mv :kenpachi :base :ke-k3)) 0)) 18)            ; K3 ender (-20) 18
            ))
;; Kenpachi base J J J blocked = 24, K K K = 46 (DUEL_STRINGS §3.5): a full gauge falls on the 5th J string, the 3rd K
(flet ((gv (name) (hw-guard (svref (mv-hits (mv :kenpachi :base name)) 0))))
  (check (= 24 (+ (gv :ke-j1) (gv :ke-j2) (gv :ke-j3))))
  (check (= 46 (+ (gv :ke-k1) (gv :ke-k2) (gv :ke-k3))))
  (check (and (< (* 4 24) *gg-max*) (>= (* 5 24) *gg-max*) (< (* 2 46) *gg-max*) (>= (* 3 46) *gg-max*))))
(check (equal (multiple-value-list (gg-drain 100.0 8)) '(92.0 nil)))
(check (equal (multiple-value-list (gg-drain 5.0 8)) '(0.0 t)))            ; emptied: GUARD CRUSH
;; the refill (the user's request 2026-09-27, 大幅減少防禦量表的恢復速度: 12 -> 5.5 / s, guardless 14 -> 6.5 / s)
(check (and (= *gg-delay* 60) (~= *gg-regen* 5.5) (~= *gg-regen-guardless* 6.5)))
(check (and (~= (gg-regen 50.0 59 nil nil) 50.0) (~= (gg-regen 50.0 60 nil nil) (+ 50.0 (/ 5.5 60)))
            (~= (gg-regen 50.0 60 t nil) (+ 50.0 (/ 6.5 60))) (~= (gg-regen 99.99 99 nil nil) 100.0)))
(check (<= 983 (loop with g = 0.0 for f from 0 until (>= g *gg-max*)         ; 0 -> 100 guardless: 60 f of delay +
                     do (setf g (gg-regen g f t nil)) finally (return f)) 984))   ;  923 f (15.4 s; + float rounding)
;; GUARD HOLD (guard v3): no refill while guarding, the delay frozen (not restarted): 40 f of delay, 30 f of guard,
;; 20 f released -> the refill starts on the 61st frame not guarding; a drain still zeroes the counter (DRAIN-GUARD)
(check (and (~= (gg-regen 50.0 999 nil t) 50.0) (= (gg-idle-next 40 t) 40) (= (gg-idle-next 40 nil) 41) (= (gg-idle-next 9999 nil) 9999)))
(check (= 60 (let ((idle 0)) (dotimes (i 40) (setf idle (gg-idle-next idle nil))) (dotimes (i 30) (setf idle (gg-idle-next idle t)))
               (dotimes (i 20) (setf idle (gg-idle-next idle nil))) idle)))
;; chip never kills: it leaves 1 (East's pierce, which fed it, left with Yamamoto, 2026-11-12)
(check (= 49 (chip-damage 85 1.0 50)))
;; guarding: the gauge stands still and the delay is frozen (gauges.lisp GAUGE-SYSTEM's GUARD HOLD)
(check (and (~= (gg-regen 40.0 9999 nil t) 40.0) (= (gg-idle-next 30 t) 30)))
(check (and (can-guard-p 1.0 nil) (not (can-guard-p 0.0 nil)) (not (can-guard-p 99.0 t))))
;; a guard crush: Kenpachi's Q1 blocked into an empty gauge -> the attacker acts 25 frames first
(let ((q1 (mv :kenpachi :base :ke-j1)))
  (check (= 25 (- *guard-crush-stun* (- (mv-total q1) (mv-first-hit q1)))))
  (check (= *gg-breaker* 35)))
;; the CPU's guard: all at >= 50 %, half at 25-50 %, 0.15 below, none guardless; flash-step budgeting
(check (and (~= (ai-guard-mult 50.0 nil) 1.0) (~= (ai-guard-mult 30.0 nil) 0.5) (~= (ai-guard-mult 10.0 nil) 0.15)
            (~= (ai-guard-mult 100.0 t) 0.0) (~= (ai-guard-mult 0.0 nil) 0.0)))
(check (and (ai-hoho-spare-p 100.0 1000 1100) (not (ai-hoho-spare-p 190.0 400 1100)) (ai-hoho-spare-p 200.0 400 1100)))
(check (= *reishi-max* 1300))                                               ; guard v3, the user's decision 2026-09-26
;; the CPU's Burst: below half its Reishi, or the next hit would put it in red (30 % of 1100 = 330)
(check (and (ai-burst-wanted-p 540 1100 10) (not (ai-burst-wanted-p 600 1100 10))
            (ai-burst-wanted-p 600 1100 280) (not (ai-burst-wanted-p 600 1100 260))))
(check (and (= (seconds->frames 10.0) 600) (~= (timer-fill 300 600 100.0) 50.0)))
(check (and (= (stance-store 150 80) 200) (= (stance-store 0 45) 45)))
(check (equal (multiple-value-list (stance-release 150)) '(250 t)))
(check (equal (multiple-value-list (stance-release 100)) '(200 nil)))

;;; ================================================================ combo limits
(check (equal (multiple-value-list (combo-step :launch nil 0 0 0)) '(:launch 1 1 0)))
(check (equal (multiple-value-list (combo-step :launch nil 2 1 0)) '(:knockback 3 1 0)))   ; 1 launch
(check (equal (multiple-value-list (combo-step :flinch t 3 1 1)) '(:flinch 4 1 2)))
(check (equal (multiple-value-list (combo-step :flinch t 4 1 2)) '(:knockdown 5 1 3)))     ; 3 air hits
(check (equal (multiple-value-list (combo-step :flinch nil 9 0 0)) '(:flinch 10 0 0)))  ; no hit cap (the user 2026-09-30)
;; the hidden hit-stun tolerance (docs/duel/DUEL_DESIGN.md, the user 2026-09-29)
(check (= (stun-weight :flinch nil) 1))
(check (= (stun-weight :stagger nil) 2))
(check (every (lambda (r) (= (stun-weight r nil) 3)) '(:crumple :knockback :launch :knockdown)))
(check (= (stun-weight :flinch t) 3))                                     ; an SP / Kikon-rush strike: at least 3
(check (= (stun-weight :clash nil) 1))                                    ; any other reaction: 1
(check (= (stun-add 4.0 :stagger nil) 6.0))
(check (= (stun-decay 10.0 (1- *stun-delay*)) 10.0))                      ; no decay inside the delay
(check (~= (stun-decay 10.0 *stun-delay*) (- 10.0 (/ *stun-decay* 60.0))))   ; then -*STUN-DECAY* per second
(check (= (stun-decay 0.01 999) 0.0))                                     ; never below 0
(check (~= (let ((s 12.0)) (dotimes (i (+ *stun-delay* 60) s) (setf s (stun-decay s i)))) (- 12.0 *stun-decay*) 0.05))   ; 1 s past it
(check (and (not (stun-over-p 16.0 16.0)) (stun-over-p 16.5 16.0)))       ; past it, not at it
(check (= (stun-tolerance-of (kit :ichigo :base)) 16.0))                  ; per kit
(check (= (stun-tolerance-of (kit :kenpachi :base)) 26.0))
(check (= (stun-tolerance-of (kit :kenpachi :bankai)) 26.0))              ; derived forms inherit it
(check (= (stun-tolerance-of (kit :ichigo :kessa)) 16.0))
(check (every (lambda (cf) (plusp (stun-tolerance-of (apply #'kit cf)))) *forms*))
(check (= (stun-tolerance-of (make-kit)) *stun-tolerance*))              ; no key: the default
;; a re-pin loop with gaps: a J string (flinch flinch stagger), 20 f of neutral, again ... it still blows him away
(check (let ((s 0.0) (idle 0) (tol 16.0) (strings 0))
         (loop repeat 20 until (stun-over-p s tol)
               do (incf strings)
                  (dolist (r '(:flinch :flinch :stagger))
                    (unless (stun-over-p s tol) (setf s (stun-add s r nil) idle 0)
                            (dotimes (i 20) (setf s (stun-decay s idle)) (incf idle))))
                  (dotimes (i 20) (setf s (stun-decay s idle)) (incf idle)))
         (and (stun-over-p s tol) (<= strings 5))))
;; ... while strings 2 s apart never fill it
(check (let ((s 0.0) (idle 0) (over nil))
         (loop repeat 20
               do (dolist (r '(:flinch :flinch :stagger)) (setf s (stun-add s r nil) idle 0 over (or over (stun-over-p s 16.0))))
                  (dotimes (i 120) (setf s (stun-decay s idle)) (incf idle)))
         (not over)))

;;; ================================================================ perfect Hoho
;;; ================================================================ perfect Hoho
;; A J-like window ([9,12), a 1.4 m arc: the J floor; Yamamoto's Q1 until his code left main, 2026-11-12, now the same numbers
;; inline) from the origin facing -Z; our cylinder r 0.4 h 1.8
(let ((from 9) (to 12) (vols (list (make-vol :arc '(1.4 100 -0.5 2.5)))))
  (flet ((perfect (sf z) (perfect-hoho-p sf from to vols
                                         0f0 0f0 0f0 0f0 -1f0 0f0 0f0 (float z 1f0) 0.4f0 1.8f0)))
    (check (perfect 3 -2.0))                  ; active in 6 f: perfect
    (check (perfect 0 -2.0))                  ; 9 f away: inside the 12 f lead (8 until 2026-10-01)
    (check (not (perfect-hoho-p 0 (+ from 4) (+ to 4) vols   ; 13 f away: too early
                                0f0 0f0 0f0 0f0 -1f0 0f0 0f0 -2f0 0.4f0 1.8f0)))
    (check (perfect 10 -2.0))                 ; active now
    (check (not (perfect 12 -2.0)))           ; over
    (check (perfect 3 -2.2))                  ; out of reach, but inside the 1 m inflation
    (check (perfect 3 -2.6))
    (check (not (perfect 3 -3.0)))))

;;; ================================================================ facing, movement, arena
(check (~= (turn-toward 0.0 (deg 90) (deg 18)) (deg 18)))
(check (~= (turn-toward 0.0 (deg 10) (deg 18)) (deg 10)))
(check (~= (angle-wrap (turn-toward (deg 170) (deg -170) (deg 18))) (deg -172)))   ; short way
(check (~= (track-step 360.0) (deg 6)))
(check (and (in-front-p 0.0 0.0 0.0 (sin (deg 95)) (- (cos (deg 95))) *guard-arc*)
            (not (in-front-p 0.0 0.0 0.0 (sin (deg 105)) (- (cos (deg 105))) *guard-arc*))))
(multiple-value-bind (to st) (stick-toward-strafe 0.0 1.0 0.0 0.0 0.0 0.0 -5.0)
  (check (and (~= to 1.0) (~= st 0.0))))                              ; up = at the opponent
(multiple-value-bind (to st) (stick-toward-strafe 1.0 0.0 0.0 0.0 0.0 0.0 -5.0)
  (check (and (~= to 0.0) (~= st 1.0))))                              ; right = strafe right
(multiple-value-bind (to st) (stick-toward-strafe 0.0 1.0 0.0 0.0 0.0 5.0 0.0)
  (check (and (~= to 0.0) (~= st -1.0))))                             ; opponent to the right: up = strafe left
(multiple-value-bind (dx dz) (toward-strafe-dir 0.6 0.8 1.0 1.0 1.0 -4.0)
  (multiple-value-bind (to st) (stick-toward-strafe dx (- dz) 0.0 1.0 1.0 1.0 -4.0)
    (check (and (~= to 0.6) (~= st 0.8)))))                           ; round trip (camera yaw 0)
(multiple-value-bind (x z) (clamp-to-circle 20.0 0.0 15.0) (check (and (~= x 15.0) (~= z 0.0))))
(multiple-value-bind (x z) (clamp-to-circle 3.0 4.0 15.0) (check (and (~= x 3.0) (~= z 4.0))))
(multiple-value-bind (x z yaw) (hoho-destination 0.0 0.0 0.0)
  (check (and (~= x 0.0) (~= z 1.6) (~= yaw 0.0))))                   ; behind, facing his back
(check (equal (multiple-value-list (step-direction 0.0 0.1)) '(-1.0 0.0)))   ; neutral = back
;; the run (Step held): neutral = at the opponent, stops 1.2 m from him, 6 f brake, 1 m of carry
(check (equal (multiple-value-list (step-direction 0.0 0.1 1.0)) '(1.0 0.0)))
(check (and (not (run-stop-p 1.4 1.0 8.0)) (run-stop-p 1.3 1.0 8.0)      ; 8 m/s = 0.133 m / f
            (not (run-stop-p 1.0 -1.0 8.0)) (not (run-stop-p 1.25 0.0 10.0))))   ; running away / sideways
(check (and (~= (run-carry 5.0) 1.0) (~= (run-carry 1.7) 0.5) (~= (run-carry 1.0) 0.0)))
(check (and (~= (brake-speed 9.0 3) 4.5) (~= (brake-speed 9.0 6) 0.0) (~= (brake-speed 9.0 9) 0.0)))
(check (and (~= (kit-run (kit :kenpachi :base)) 10.0) (~= (kit-run (kit :kenpachi :nozarashi)) 10.0)))
;; the run faces the opponent: one clip set per character (every Kenpachi form shares his)
(check (and (equal (kit-run-clips (kit :kenpachi :nozarashi)) (kit-run-clips (kit :kenpachi :base)))
            (eq (first (kit-run-clips (kit :kenpachi :base))) :ke-run)))
                                          ; Yama backs off to zone

;;; ================================================================ AI helpers
(check (and (eq (weighted-pick 0.0 :a 1 :b 1) :a) (eq (weighted-pick 0.5 :a 1 :b 1) :b)
            (eq (weighted-pick 0.1 :a 0 :b 1) :b) (null (weighted-pick 0.5 :a 0))))
  ; Shiranui beyond 8 m

;;; ================================================================ hit volumes
(flet ((hits (v x z &key (y 0f0))
         (vol-hit-p v 0f0 0f0 0f0 0f0 -1f0 (float x 1f0) y (float z 1f0) 0.38f0 1.8f0 0f0)))
  (let ((arc (make-vol :arc '(2.4 100 0.2 2.0))))
    (check (~= (aref arc 2) (deg 50)))
    (check (hits arc 0 -2))
    (check (not (hits arc 0 2)))
    (check (not (hits arc 0 -3)))
    (check (not (hits arc 0 -2 :y 3f0))))
  (check (hits (make-vol :cap '(0.3 8.0 1.0 0.5)) 0.5 -7.5))            ; Nadegiri line
  (check (hits (make-vol :sph '(2.0 0.0 1.0)) 0 -2.5)))
;; world space: a Shiranui / thrust capsule, a skeleton lunge, a fire wall, a pillar
(check (capsule-cyl-hit-p 0f0 1f0 0f0 0f0 1f0 -9f0 0.3f0 0.5f0 0f0 -5f0 0.4f0 1.8f0))
(check (not (capsule-cyl-hit-p 0f0 1f0 0f0 0f0 1f0 -9f0 0.3f0 1.0f0 0f0 -5f0 0.4f0 1.8f0)))
(check (not (capsule-cyl-hit-p 0f0 1f0 0f0 0f0 1f0 -9f0 0.3f0 0f0 0f0 -10f0 0.4f0 1.8f0)))  ; past the end
(check (not (capsule-cyl-hit-p 0f0 3f0 0f0 0f0 3f0 -9f0 0.3f0 0f0 0f0 -5f0 0.4f0 1.8f0)))   ; overhead
(check (capsule-cyl-hit-p 0f0 0.5f0 0f0 2f0 1.5f0 0f0 0.3f0 2.5f0 0f0 0f0 0.4f0 1.8f0))     ; sloped lunge
(check (capsule-cyl-hit-p 0f0 1f0 -5f0 0f0 1f0 -5f0 0.5f0 0.6f0 0f0 -5f0 0.4f0 1.8f0))     ; a ball
(check (obox-cyl-hit-p 0f0 1f0 -5f0 0f0 3f0 1f0 0.5f0 2.5f0 0f0 -5f0 0.4f0 1.8f0))          ; inside the width
(check (not (obox-cyl-hit-p 0f0 1f0 -5f0 0f0 3f0 1f0 0.5f0 3.5f0 0f0 -5f0 0.4f0 1.8f0)))
(check (obox-cyl-hit-p 0f0 1f0 -5f0 0f0 3f0 1f0 0.5f0 0f0 0f0 -5.8f0 0.4f0 1.8f0))          ; its face
(check (not (obox-cyl-hit-p 0f0 1f0 -5f0 0f0 3f0 1f0 0.5f0 0f0 0f0 -6.0f0 0.4f0 1.8f0)))
(let ((yaw (deg 90)))                                                  ; turned: width along Z
  (check (obox-cyl-hit-p 0f0 1f0 -5f0 yaw 3f0 1f0 0.5f0 0f0 0f0 -7.5f0 0.4f0 1.8f0))
  (check (not (obox-cyl-hit-p 0f0 1f0 -5f0 yaw 3f0 1f0 0.5f0 0f0 0f0 -8.5f0 0.4f0 1.8f0))))
(check (not (obox-cyl-hit-p 0f0 1f0 -5f0 0f0 3f0 1f0 0.5f0 0f0 3f0 -5f0 0.4f0 1.8f0)))      ; above it
(check (cyl-cyl-hit-p 3f0 0f0 0f0 0.6f0 3f0 3.8f0 0f0 0f0 0.4f0 1.8f0))
(check (not (cyl-cyl-hit-p 3f0 0f0 0f0 0.6f0 3f0 4.1f0 0f0 0f0 0.4f0 1.8f0)))
(check (not (cyl-cyl-hit-p 3f0 0f0 0f0 0.6f0 3f0 3.5f0 3.5f0 0f0 0.4f0 1.8f0)))            ; airborne above

;;; ================================================================ kit sanity
;;; The §5 tables, copied independently of yama.lisp / ken.lisp: move S A R dmg block (? = no value in §5)
(defparameter *table*
  '((:ke-j1 7 3 12 35 -2) (:ke-j2 7 3 13 35 -2) (:ke-j3 8 3 18 42 -4) (:ke-k1 16 4 20 70 -3)
    (:ke-k2 20 4 24 60 -3) (:ke-k3 20 5 34 80 -20) (:ke-stance 8 4 24 100 -14) (:ke-buttagiru 22 4 26 180 -14)
    (:ke-charge 14 ? ? 25 -16) (:ke-breaker 8 4 18 150 :guard-break)))   ; (RYOTE's / NOMIHOSE's rows went with the cups, the meteor 2026-11-05)
(dolist (row *table*)
  (destructuring-bind (name s a r dmg adv) row
    (let ((m (find-move name)))
      (flet ((same (want got) (or (eq want '?) (equal want got))))
        (unless (and (same s (mv-s m)) (same a (mv-a m)) (same r (mv-r m)) (same dmg (mv-dmg m))
                     (same adv (mv-adv-block m)))
          (format t "  table mismatch ~s~%" name))
        (check (and (same s (mv-s m)) (same a (mv-a m)) (same r (mv-r m)) (same dmg (mv-dmg m))
                    (same adv (mv-adv-block m))))))))
(check (equal (mv-hold (find-move :ke-stance)) '(6 60)))

;;; every form: all commands mapped, strings resolve, frames consistent, hooks are symbols
(defparameter *kinds* '(:quick :flash :sig :sp :breaker :kikon))
(dolist (cf *forms*)
  (let ((k (apply #'kit cf)))
    (check (every (lambda (c) (or (kit-command-move k c)      ; (or a command the form removes: Rukia's -50 / zero / THAW)
                                  (member c (loop for (cc m) on (kit-commands k) by #'cddr unless m collect cc))))
                  *kit-commands*))
    (check (every (lambda (s) (and (kit-move k (first s)) (kit-next k (first s) (second s)))) (kit-strings k)))
    (maphash
     (lambda (name m)
       (let ((ok (and (member (mv-kind m) *kinds*)
                      (>= (mv-s m) 0) (>= (mv-a m) 0) (>= (mv-r m) 0) (>= (mv-whiff m) (mv-r m))
                      (every (lambda (w) (and (or (<= (mv-s m) (hw-from w)) (hw-seg w))   ; (a :seg-fn hit may land
                                              (< (hw-from w) (hw-to w))                    ;  before S: KOJO's yank, §25.7)
                                              (<= (hw-to w) (+ (mv-s m) (mv-a m))) (or (hw-vols w) (hw-seg w))))
                             (mv-hits m))
                      (or (eq (mv-kind m) :kikon) (zerop (mv-dmg m)) (plusp (length (mv-hits m))))
                      (every (lambda (e) (and (< (first e) (mv-total m)) (symbolp (second e)))) (mv-on-frame m))
                      (every #'symbolp (list (mv-tick m) (mv-release m) (mv-on-land m) (mv-cine m)))
                      (or (not (eq (mv-kind m) :kikon)) (mv-cine m)))))
         (unless ok (format t "  bad move ~s in ~s~%" name cf))
         (check ok)))
     (kit-moves k))))
;; forms: multipliers, inheritance, the Hellfire / Bankai swaps
(check (and (~= (kit-mult (kit :kenpachi :nozarashi)) 1.0) (~= (kit-mult (kit :kenpachi :base)) 1.0)))
  ; inherited
;; the Kikon rush of every form: a strike with a cinematic, clearly punishable on block (-14; K1 of either character
;; reaches it after the block pushback from the trigger range: J1 did until the J cut of 2026-09-29, now it walks in),
;; reach beyond the trigger
(dolist (cf *forms*)
  (let ((m (kit-command-move (apply #'kit cf) :kikon)))
    (check (or (and (null m) (eq (first cf) :kenpachi))          ; (Kenpachi: no O rush since 2026-11-05, DUEL_KEN_V3 §43)
               (and (eq (mv-kind m) :kikon) (mv-cine m) (= 1 (length (mv-hits m))) (<= (mv-adv-block m) -12)
                (> (mv-reach m) *kikon-trigger*) (plusp (mv-dmg m))
                (<= (+ *kikon-trigger* *block-pushback*) (mv-reach (mv :kenpachi :base :ke-k1))))))))
;; cooldowns: every command slot of the fighter's CD vector
(check (= 7 (length *kit-commands*)))
  ; no Hellfire in Bankai
(check (null (kit-duration (kit :kenpachi :nozarashi))))   ; the awakening lasts the match
(check (~= (kit-walk (kit :kenpachi :nozarashi)) 4.4))
;; the Shikai's own J string (DUEL_KEN_V3 §9)
(check (eq (kit-next (kit :kenpachi :nozarashi) :ke-s-j1 :q) (mv :kenpachi :nozarashi :ke-s-j2)))
;; clip names: exactly the §5 contract, and every §5 clip is used
(defparameter *clips-5*
 '(
  :sh-run ; the O modules (TENCHI runs in :sh-run)
   :ke-kick ; the strings' new clips (DUEL_STRINGS §3)
 :ke-stance :ke-q1 :ke-q2 :ke-q3 :ke-f1 :ke-f2 :ke-stance-hold :ke-stance-cut :ke-buttagiru :ke-charge
 :ke-flurry :ke-breaker :ke-shoulder :ke-intro :ke-win :ke-release :ke-nome
 :ke-s-st-1
 :ke-s-flick ; the V3 Shikai's hilt flick (DUEL_KEN_V3 §12)
 :ke-z-cut1 :ke-z-cut2 :ke-z-cut3 :ke-z-cut4 :ke-z-cut5
 :ke-z-p1a :ke-z-p1b :ke-z-p1c :ke-z-shove :ke-z-as1 :ke-z-p2a :ke-z-p2b :ke-z-ram :ke-z-scoop :ke-z-tame :ke-z-tsuki :ke-z-men :ke-z-kote :ke-z-tsuki2 ; V3 sealed J1-J5 (DUEL_KEN_V3 §37; the stances are kit stances, not listed)
 :ke-s-cut1 :ke-s-cut2 :ke-s-cut3 :ke-s-cut4 :ke-s-cut5 :ke-s-cut6 :ke-s-cut7 :ke-s-cut-sa ; the V3 Shikai's J string and SA (§15)
 :ke-s-jab :ke-s-p2c :ke-s-p2d :ke-s-p2e :ke-s-zangaeshi :ke-s-meteor ; its pointer-2 clips (DUEL_KEN_V3 §15)
 :ke-s-p1a :ke-s-p1b :ke-s-p1c :ke-s-p1d :ke-s-p1e :ke-s-issen :ke-s-wheel ; the V3 Shikai's pointer-1 clips (DUEL_KEN_V3 §15)
 :sh-skate-b :sh-slide-r :sh-slide-l :ke-run :ke-skate-b :ke-slide-r :ke-slide-l ; the runs (facing the opponent)
 ; (the cups' :ke-drink and the old Bankai's own strikes left every kit with V3's Bankai, DUEL_KEN_V3 §26; the old core set's, the O
 ;  rushes' and the meteor's clips went 2026-11-05, §43)
 :ke-b-kr-stance :ke-b-zh-stance ; the Bankai (docs/duel/DUEL_KEN_BANKAI.md §12; V3's two, DUEL_KEN_V3 §27)
 :ke-kr-cut1 :ke-kr-cut2 :ke-kr-cut3 :ke-kr-cut4 :ke-kr-cut5 :ke-zh-cut1 :ke-zh-cut2 :ke-zh-cut3 :ke-zh-cut4 :ke-zh-cut5 ; their J1-J5 (§28)
 :ke-kr-ns-a :ke-kr-ns-b :ke-kr-ns-c :ke-kr-ns-d :ke-kr-fin :ke-zh-ns-a :ke-zh-ns-b :ke-zh-ns-c :ke-zh-ns-d :ke-zh-fin ; NS a-d, the finishers (§29)
 :ke-kr-chigiri :ke-zh-tategoto ; the special AS (§30)
 :ke-s-bankai ; the Bankai's burst AS (§32)
 :ic-cross-j :ic-k-jab :ic-k-wrap-j ; the J cut's close J links (DUEL_STRINGS §13)
 :ke-b-run :ke-b-skate-b :ke-b-slide-r :ke-b-slide-l ; its feral pass (2026-09-28; also 片腕)
 ;; names stay, every form maps them))
 :ic-na1 :ic-ns1 :ic-chg1 :ic-chg2 :ic-ns3 :hs-na1 ; (the core system's long coils: NA1, the NS openers, NS2's charges, DUEL_CORE §6)
 :hs-kr-tan :hs-kr-ren :hs-kr-sen :hs-kr-ko :hs-kr-age ; (Hisagi's pointer 2 刈, its NS and AS2: DUEL_HISAGI §27.5)
 :hs-chikuden :hs-hoden ; (his pointer 3 縛雷's CHIKUDEN and 放電: DUEL_HISAGI §27.6)
 :hs-tsumuji ; (his AS1 旋風 TSUMUJI: DUEL_HISAGI §27.10)
 :hs-kb-kagiyose :hs-kb-kagiyose-giri :hs-kb-juji :hs-kb-matoi :hs-kb-shime :hs-kb-tsuri :hs-kb-san ; (the core bind's own: DUEL_HISAGI §28.12)
 :ic-k-summon :ic-k-xa :ic-k-xb ; (KESSA's NS3: the command gesture; the clones' X, ICHIGO-NS-CLONE-X plays them)
 :ic-k-lash-a :ic-k-lash-b :ic-k-lash-c :ic-k-chg1 :ic-k-chg2 :ic-k-wrap :ic-k-whip :ic-k-cut ; (KESSA's NS1 chains, NS2 charges, AS3's turn: 2026-10-28)
 :ic-stance :ic-intro :ic-win :ic-q1 :ic-q2 :ic-spin :ic-f1 :ic-f2 :ic-drop :ic-cross :ic-getsuga :ic-juji :ic-breaker
 :ic-mine :ic-k-stance :ic-k-back :ic-k-parry :ic-k-yank :ic-k-zanzo ; Ichigo (DUEL_ICHIGO §10, v2)
 :ic-tsuki :ic-rangetsu :ic-tsuki-otoshi :ic-soga :ic-juji-x ; (SOGA's and the JUJI rush's own, DUEL_ICHIGO_TYBW §3.2)
 :ic-k-f1 :ic-k-f2 :ic-k-f3 :ic-k-gaeshi :ic-k-uchi ; KESSA's own K, counter and O strike (DUEL_ICHIGO_TYBW §3.2)
 ; the Bankai's own (§8)
 ; KATAUDE's (§8)
 :hs-intro :hs-win ; Hisagi's B2a intro / win (the Bankai's forms)
 :hs-s-stance :hs-s-intro :hs-s-win :hs-s-walk-f :hs-s-walk-b :hs-s-strafe-r :hs-s-strafe-l ; the Shikai's own
 :hs-s-run :hs-s-skate-b :hs-s-slide-r :hs-s-slide-l :hs-s-sen :hs-s-kaeshi :hs-s-rin :hs-s-kaeshi-1h :hs-s-rin-1h ; (§21.4)
 :hs-s-maki :hs-s-modoshi :hs-s-kaza :hs-s-raiden :hs-s-shibari ; (S1, §23.3: :hs-s-kari no move's since; MAKI dormant;
 :hs-s-nagi :hs-s-noko :hs-s-tsui :hs-s-tobi-kaeshi :hs-s-tobi-rin ; A1, §24.1: the K string's and the leap J's own, so
 ; :hs-s-nage, :hs-s-hiki, :hs-s-hodoki no move's)
 :hs-s-breaker :hs-s-kubikake :hs-s-kari-aim :hs-s-kari-o
 :hs-k-stance :hs-k-walk-f :hs-k-walk-b :hs-k-strafe-r :hs-k-strafe-l :hs-k-run :hs-k-skate-b :hs-k-slide-r ; the Bankai's
 :hs-k-slide-l :hs-k-saben :hs-k-kaeshi :hs-k-sensa :hs-k-saharai ; own (§21.8):
 :hs-k-raiden :hs-k-ame :hs-k-kosa-aim :hs-k-kosa :hs-k-breaker :hs-k-hammer :hs-k-kubikake ; the ranged mode,
 :hs-kb-gen :hs-kb-kaeshi :hs-kb-sogen :hs-kb-hikigiri :hs-kb-makigiri :hs-kb-shibori :hs-kb-kaibaku ; the bind
 :hs-kb-raiden :hs-kb-kojo :hs-kb-koshu-run :hs-kb-koshu :hs-kb-unwind
 :hs-k-hosoku :hs-k-s-k2 :hs-k-s-k3 :hs-k-g-k2 :hs-k-g-j2 :hs-k-g-k3 :hs-k-g-j3 ; the ranged route links' (A2, §24.2)
 :hs-k-uchi :hs-k-ogi :hs-k-issei :hs-k-ransa :hs-k-tataki :hs-k-sweep :hs-k-jibashiri ; the core ranged mode's own
 :hs-k-maki :hs-k-kake ; (batch 2a, DUEL_HISAGI §28.11)
 :hs-k-na3 :hs-k-na4 ; the five J's own J3 / J4 (§28.15)
 :hs-k-g-sa ; the gathered SA's own (§28.21)
 :hs-kb-stance :hs-kb-walk-f :hs-kb-walk-b :hs-kb-strafe-r :hs-kb-strafe-l))     ; the bind's stance and walk (A2)
;; (the Kikon cinematics' own clips are played by their DEFCINEs, which the host stubs; KESSA's clones play :ic-k-cut / :ic-k-wrap, ICHIGO-CLONE-STEP)
(let ((used (remove-duplicates (append (loop for cf in *forms* append (kit-clips (apply #'kit cf)))
                                        ;; (moves started outside every kit's tables: Hisagi's MODOSHI, started by his
                                        ;;  :command hook while the sickle is out)
                                        (remove nil (loop for m in '(:ic-c-xa :ic-c-xb :hs-modoshi :hs-k2s :hs-r-kubikake :hs-b-unwind :hs-r-sp2c
                                                                       :hs-b-sp1    ; (B4c: no kit's since, its strip 83524)
                                                                       :hs-r-l :hs-r-sp1 :hs-b-l :hs-r-k1 :hs-b-k1   ; (§28.4: the old Bankai's,
                                                                       :hs-r-k2s :hs-r-k3)  ; (§28.11: spread K2 / K3's clips, strips 27 / 28;
                                                                                ;  no kit's since, their clips kept for the strips)
                                                          collect (mv-clip-2 (find-move m))   ; (his Shikai's MODOSHI mapped)
                                                          collect (kit-move-clip (kit :hisagi :base) (mv-clip (find-move m)))))))))
  (let ((extra (set-difference used *clips-5*)) (unused (set-difference *clips-5* used)))
    (when (or extra unused) (format t "  clips not in §5: ~s, §5 clips unused: ~s~%" extra unused))
    (check (and (null extra) (null unused)))))
;; phase 2: art names, roster, form looks, the flurry, hazard hits
(check (equal (mapcar #'kit-weapon (mapcar (lambda (cf) (apply #'kit cf)) *forms*))
              '(:ken-katana :nozarashi :ke-broken :ke-broken
                :zangetsu-long :tensa :kazeshini :kazeshini :kazeshini)))     ; (Kenpachi, Ichigo, Hisagi)
(check (equal *roster* '(:yamamoto :kenpachi :rukia :ichigo :senjumaru :lille :barro :hisagi)))   ; the retired slots keep their index (no kit behind them since 2026-11-12), Hisagi is 7
              ; cane until 1.35 s
(check (eq (kit-cine (kit :kenpachi :nozarashi)) 'ken-nozarashi-cine))
(check (null (kit-blade (kit :kenpachi :base))))
(check (~= (mv-blend (find-move :ke-stance)) 6))
(let ((fl (find-move :ke-flurry)))                                          ; 4 more cuts + the launcher
  (check (and (= 5 (length (mv-hits fl))) (= 60 (hw-dmg (svref (mv-hits fl) 4))) (eq :launch (hw-react (svref (mv-hits fl) 4)))
              (= (+ 25 (* 4 25) 60) (+ (mv-dmg (find-move :ke-charge)) (loop for w across (mv-hits fl) sum (hw-dmg w)))))))
(check (and (null (hw-stun (make-hitwin))) (= 40 (hw-stun (make-hitwin :stun 40)))))

