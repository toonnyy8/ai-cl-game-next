;;;; duel-rules-test.lisp — checks SOUL DUEL's pure rules (duel/lisp/rules.lisp) and its kit data
;;;; (kit.lisp + yama.lisp + ken.lisp) on the host, no browser, no build:
;;;;   $ECL_HOST --norc --load tests/duel-rules-test.lisp
;;;; The files are plain Common Lisp over the engine's plain-CL math, hit volumes and vpad, so they
;;;; load here after engine/lisp/{package,math,hitvol,input}.lisp.
(dolist (f '("package" "math" "hitvol" "input"))
  (load (merge-pathnames (format nil "../engine/lisp/~a.lisp" f) *load-truename*)))
(defpackage :duel (:use :cl :engine))
;; the character files also hold their hook functions and cinematics: those need the engine, so the
;; host skips the cinematics (a no-op DEFCINE) and never calls a hook; their state components (DEFCOMPONENT) are
;; plain structs here (no entities: the tests make them with MAKE-...)
(defmacro duel::defcine (&rest r) (declare (ignore r)) nil)
(defmacro engine:defcomponent (name &rest slots) `(defstruct (,name (:copier nil) (:predicate nil)) ,@slots))
(dolist (f '("tuning" "rules" "learn" "kit" "yama" "ken" "rukia" "ichigo" "endless-rules" "senjumaru" "barro" "hisagi"))
  (load (merge-pathnames (format nil "../duel/lisp/~a.lisp" f) *load-truename*)))
(in-package :duel)

(defvar *br-tip-print* nil)   ; (t: print the awakened stances' drawn tips, *BR-W-TIPS*)
(defvar *br-w-stretch* nil)   ; (barro-art.lisp's whips, read with the art files below)
(defvar *br-squash* nil)      ; (barro-art.lisp's squash and stretch, R8)
(defvar *lb-wall-jl* nil)     ; (lille-art.lisp's wing wall rows: Lille II's awakened guard)
(defvar *lb-wall-owl* nil)
(defvar *fails* 0)
(defvar *checks* 0)
(defmacro check (form)
  `(progn (incf *checks*) (unless ,form (incf *fails*) (format t "FAIL: ~s~%" ',form))))
(defun ~= (a b &optional (eps 1e-3)) (< (abs (- a b)) eps))
(defun kit (c f) (find-kit c f))
(defun mv (c f name) (kit-move (kit c f) name))
(defparameter *forms* '((:yamamoto :base) (:yamamoto :hellfire) (:yamamoto :bankai-east) (:yamamoto :bankai-west)
                        (:kenpachi :base) (:kenpachi :nozarashi) (:kenpachi :ryote) (:kenpachi :nomihose)
                        (:kenpachi :bankai) (:kenpachi :kataude)
                        (:rukia :base) (:rukia :m18) (:rukia :m50) (:rukia :zero) (:ichigo :base) (:ichigo :kessa)
                        (:senjumaru :base) (:senjumaru :tsuji1) (:senjumaru :tsuji2) (:senjumaru :tsuji3) (:senjumaru :tsuji4)
                        (:senjumaru :tsuji5) (:senjumaru :tsuji6)
                        (:barro :base) (:barro :jilliel-kin) (:barro :jilliel) (:barro :shin-kin) (:barro :shin)
                        (:hisagi :base) (:hisagi :bankai) (:hisagi :bankai-bind)))   ; (Hisagi's Shikai, B2a: DUEL_HISAGI §8;
                                                                ;  his Bankai's two modes, B2b: §17; Lille II
                                                                ;  v3: MUJITTAI gone, DUEL_LILLE_V3 R1)
(defun owl-adv (cf)
  "The frame advantage CF's J / K add to DUEL_STRINGS's budget: the owl's *SHIN-ADV* (decision 36: each recovery 1 f
shorter, its :adv-block 1 higher), else 0."
  (cond ((and (eq (first cf) :barro) (br-owl-form-p (second cf))) *br-owl-adv*)   ; (Lille II's owl: the same +1)
        (t 0)))
(defun trace-form-p (cf)
  "Is CF a form whose J / K strings lay traces instead of hitting (Lille's JILLIEL EN, DUEL_LILLE §22.2): its J1 has no hit
window? The hit-based string checks skip it (its own block below checks its frames)."
  (or (zerop (length (mv-hits (kit-command-move (apply #'kit cf) :q))))
      (and (eq (first cf) :barro) (member (second cf) '(:jilliel :shin)) t)))   ; (Lille II v3: his stance EN's strings,
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
  (check (and (~= (mr :ke-meteor) 3.4) (~= (mr :ke-meteor-n) 3.9) (~= (mr :ke-buttagiru) 2.6) (~= (mr :ya-nadegiri) 2.4)
              (null (mr :ya-kyoku)) (null (mr :ya-taimatsu))
              (= 1 (length (mv-hits (find-move :ke-meteor-n)))) (= 1 (length (mv-hits (find-move :ke-meteor)))))))
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
(let ((b (mv :yamamoto :base :ya-breaker)))
  (check (and (= (mv-s b) 8) (= (mv-a b) 4) (= (mv-r b) 18) (= (mv-whiff b) 30) (= (mv-dmg b) 150)
              (eq (mv-adv-block b) :guard-break) (member :breaker (hw-flags (svref (mv-hits b) 0)))
              (~= (mv-track b) *track-breaker*) (= (hw-hs (svref (mv-hits b) 0)) 10))))
;; a Q1 thrown on seeing the aura beats the fastest Breaker (aura 12 + strike startup 8)
(check (< (mv-s (mv :yamamoto :base :ya-j1)) (+ *breaker-aura* *breaker-startup*)))
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
      (walk (kit-command-move k :f) 1 '(:f)))
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
(defun on-hit-adv (m)
  (let ((w (svref (mv-hits m) 0))) (- (or (hw-stun w) (hitstun (hw-react w))) (- (mv-total m) (hw-from w)))))
(dolist (cf (remove-if #'trace-form-p *forms*))
  (let* ((k (apply #'kit cf)) (links (link-moves k)) (j1 (kit-command-move k :q)) (k1 (kit-command-move k :f))
         (cup3 (equal cf '(:kenpachi :nomihose))) (fails0 *fails*) (a (owl-adv cf))
         (v8 (eq (first cf) :barro))   ; (Lille II: decision V8 splits his J / K off the budget, DUEL_LILLE_V2 §21: own rows)
         (hs1 (equal cf '(:hisagi :base)))   ; (Hisagi's Shikai since S2, DUEL_HISAGI §23.5: a J after a K leaps in, J2K / J3K)
         (hr (equal cf '(:hisagi :bankai))))   ; (Hisagi's ranged mode, DUEL_HISAGI §17.1: 「前搖大」; B4a, §22.2: J1 S 14;
                                               ;  B4c, §22.4: the route links' S -3 (spread) / +3 (gathered), K1 綁束 S 16;
                                               ;  its own block below pins the rest)
    ;; the shape: exactly the six full routes JJJ JJK JKK KKK KKJ KJJ (J / K switch at most once), every link 3 an ender
    (check (equal (sort (loop for (nil n seq) in links when (= n 3) collect (format nil "~{~a~}" (mapcar (lambda (c) (if (eq c :q) "J" "K")) seq)))
                        #'string<)
                  '("JJJ" "JJK" "JKK" "KJJ" "KKJ" "KKK")))
    (check (every (lambda (l) (eq (and (member :ender (mv-flags (first l))) t) (= 3 (second l)))) links))
    (check (every (lambda (l) (eq (string-link-p k (mv-name (first l))) (< (second l) 3))) links))
    ;; the budget (§2.1): J1 S 7-10 A 3 R 12 flinch -2; K1 S 16-20 A 4 R 20-22 stagger -3, no armour (cup 3's K1 is
    ;; KUKAN-GIRI, -4); J beats K: S(K1) - S(J1) >= 7
    ;; (the owl's +1, decision 36: R 1 f shorter, :adv-block 1 higher on every J / K)
    (if v8   ; (decision V8: J S - 2 / R - 2 / adv + 2, K S + 2 / R + 2 / adv - 4 over the budget's numbers)
        (check (and (if (eq (second cf) :base)   ; (decision R3: the awakened J strings at the standard speed, route :JN)
                        (and (= 6 (mv-s j1)) (= (- 10 a) (mv-r j1)))
                        (and (<= 7 (mv-s j1) 10) (= (- 12 a) (mv-r j1))))
                    (= 3 (mv-a j1)) (= a (mv-adv-block j1))
                    (eq :flinch (hw-react (svref (mv-hits j1) 0)))
                    (= 19 (mv-s k1)) (= 4 (mv-a k1)) (= (- 23 a) (mv-r k1)) (= (+ a -7) (mv-adv-block k1))
                    (zerop (mv-armor-hits k1)) (eq :stagger (hw-react (svref (mv-hits k1) 0)))))
        (progn
    (check (and (if hr (= 14 (mv-s j1)) (<= 7 (mv-s j1) 10)) (= 3 (mv-a j1)) (= (- 12 a) (mv-r j1)) (= (+ -2 a) (mv-adv-block j1))
                (eq :flinch (hw-react (svref (mv-hits j1) 0)))))
    (check (and (<= 16 (mv-s k1) 20) (= 4 (mv-a k1)) (<= (- 20 a) (mv-r k1) 22) (= (+ a (if cup3 -4 -3)) (mv-adv-block k1))
                (zerop (mv-armor-hits k1)) (eq :stagger (hw-react (svref (mv-hits k1) 0)))))))
    (unless hr (check (>= (- (mv-s k1) (mv-s j1)) 7)))   ; (his ranged J1 S 14 / K1 S 16: §17.1's exception, B4c)
    (dolist (l (remove-if (lambda (l) (zerop (length (mv-hits (first l))))) links))
      (destructuring-bind (m n seq) l
        (let ((kk (eq (car (last seq)) :f)) (w (svref (mv-hits m) 0)))
          ;; every K at link 2 / 3 enters at S_eff 14; J links 2 / 3 -2 / -4, K links -3 / -20; enders stagger / crumple
          (when (and kk (> n 1)) (check (= (cond (hr (if (member (mv-name m) *hs-r-gather-links*) 21 15))   ; (B4c: 24 -/+ 3, enter 6)
                                                 ((and v8 (eq (second cf) :base)) 15) (t 14))
                                           (- (mv-s m) (mv-enter m)))))   ; (V8: *BR-K-LINK-SLOW* 1; R12: the awakened :KN 14)
          (when (> n 1)
            (check (= (mv-adv-block m) (+ a (cond ((and hs1 (member (mv-name m) '(:hs-j2k :hs-j3k))) *hs-leap-block*)   ; (S2's leap)
                                                  (v8 (cond ((and (= n 2) kk) -7) ((= n 2) 0) (kk -24) (t -2)))
                                                  (t (cond ((and (= n 2) kk) -3) ((= n 2) -2) (kk -20) (t -4)))))))
            (check (eq (hw-react w) (cond ((and (= n 3) kk) :crumple) ((or kk (= n 3)) :stagger) (t :flinch)))))
          ;; the whiff: one swing, R + 8 (J) / R + 12 (K)
          (check (= (mv-whiff m) (+ (mv-r m) (if kk *whiff-extra-k* *whiff-extra-j*))))
          (check (= (move-end-frame (mv-s m) (mv-a m) (mv-r m) (mv-whiff m) nil nil)
                    (+ (mv-s m) (mv-a m) (mv-r m) (if kk *whiff-extra-k* *whiff-extra-j*))))
          ;; every follow-up combos on hit (after a J and after a K link alike); on block (the gap is S_eff - 1 -
          ;; *CHAIN-LEAD* - adv: S_eff - 2 after a -2 link, S_eff - 1 after a -3 one) a K link leaves >= 11 f (any J1
          ;; <= 10 f interrupts it; after KUKAN-GIRI the rift closes it) and a J link 3 .. S(J1) f (Step / Hoho fit;
          ;; his own J1 at best trades: Kenpachi's and KATATE's K2 -> J3 leave exactly S(J1))
          (dolist (c '(:q :f))
            (let ((nx (kit-next k (mv-name m) c)))
              (when (and nx (plusp (length (mv-hits nx))))
                (unless (and hr (> (length (mv-hits m)) 1))   ; (his gathered K2's two hits, its launch: his block below)
                  (check (< (hit-gap m nx) 0)))
                (let ((g (blocked-gap m nx)))
                  (cond ((eq c :f) (check (>= g (if v8 (if (eq (second cf) :base) 10 9) 11))))   ; (V8: the owl's J +1 over ±0: J -> K 10 f, base 12; R12: the awakened K links S_eff 14, 9 f)
                        (v8 (check (>= g 0)))   ; (V8: his J links block-safe up to ±0: no gap to Step into, by design)
                        ((or hr (and hs1 (intersection (list (mv-name m) (mv-name nx)) '(:hs-j2k :hs-j3k))))   ; (B4c: the gathered
                         (check (>= g (first *step-iframes*))))   ; J S 16 leave 14-15 f: his block; S2: the leap's 14 f, a Step /
                                                                  ; Hoho / his ranged K fits; after J2K's -6 his J1 punishes)
                        (t (check (and (>= g (first *step-iframes*)) (<= g (mv-s j1)))))))))))))
    ;; the switched link 2 (J2s, K2s) is a copy: the same data as J2 / K2 but its name
    (let ((j2 (kit-next k (mv-name j1) :q)) (j2s (kit-next k (mv-name k1) :q))
          (k2 (kit-next k (mv-name k1) :f)) (k2s (kit-next k (mv-name j1) :f)))
      (unless (or cup3 (eq (first cf) :hisagi))   ; (Hisagi: K2s MAKI is its own move, J2s the one-handed x0.8: DUEL_HISAGI §7.2)
        ;; (Ichigo's Shikai: the copies are the CROSS, both blades: they may differ only in :guard and the clip)
        (flet ((core (m) (if (equal cf '(:ichigo :base))
                             (loop for (key v) on (mv-spec m) by #'cddr unless (member key '(:guard :clip :clip-s)) append (list key v))
                             (mv-spec m))))
          (check (and (not (eq j2 j2s)) (not (eq k2 k2s))
                      (equal (core j2) (core j2s)) (equal (core k2) (core k2s))
                      (= (mv-enter k2) (mv-enter k2s)) (= (mv-s j2) (mv-s j2s))
                      (or (equal cf '(:ichigo :base)) (eq (mv-clip k2) (mv-clip k2s))))))))
    ;; K3 on block -20: every J1 and every base K1 punishes it; J3 -4 is safe
    (check (every (lambda (l) (or (/= 3 (second l)) (< (max (mv-s (mv :yamamoto :base :ya-j1)) (mv-s (mv :kenpachi :base :ke-j1))
                                                             (mv-s (mv :yamamoto :base :ya-k1)) (mv-s (mv :kenpachi :base :ke-k1)))
                                                        (- (mv-adv-block (first l))))
                                  (= (+ (if v8 -2 -4) a) (mv-adv-block (first l)))
                                  (and hs1 (eq (mv-name (first l)) :hs-j3k))))   ; (S2's leap J3K: -6, his J1 punishes it, below)
                  links))
    ;; the O ender always combos off a link-3 hit: the module's dash from the ender's reach to *KIKON-TRIGGER* + its
    ;; strike's startup inside the ender's stagger / crumple
    (let* ((o (kit-command-move k :kikon)) (pa (mv-params o)))
      (dolist (l links)
        (when (= 3 (second l))
          (let* ((m (first l)) (dash (if (zerop (getf pa :dash-max)) 0
                                        (ceiling (* 60 (/ (max 0.0 (- (mv-reach m) *kikon-trigger*)) (getf pa :speed)))))))
            (check (< (+ (- (mv-total m) (hw-from (svref (mv-hits m) 0)) (mv-r m)) dash (mv-s o))
                      (hitstun (hw-react (svref (mv-hits m) 0)))))))))
    (unless (= fails0 *fails*) (format t "  string budget fails in ~s~%" cf))))
;; route resolution (the latch, §2.1 / §2.3), Yamamoto Shikai and Kenpachi RYOTE
(let ((y (kit :yamamoto :base)) (r (kit :kenpachi :ryote)))
  (check (equal (route y :q '((:q) (:q))) '(:ya-j1 :ya-j2 :ya-j3)))
  (check (equal (route y :q '((:q) (:f))) '(:ya-j1 :ya-j2 :ya-k3)))
  (check (equal (route y :q '((:f) (:f))) '(:ya-j1 :ya-k2s :ya-k3)))
  (check (equal (route y :f '((:f) (:f))) '(:ya-k1 :ya-k2 :ya-k3)))
  (check (equal (route y :f '((:f) (:q))) '(:ya-k1 :ya-k2 :ya-j3)))
  (check (equal (route y :f '((:q) (:q))) '(:ya-k1 :ya-j2s :ya-j3)))
  (check (equal (route y :q '((:f) (:q))) '(:ya-j1 :ya-k2s)))              ; JKJ: switched back, eaten: the string ends
  (check (equal (route y :f '((:q) (:f))) '(:ya-k1 :ya-j2s)))              ; KJK
  (check (equal (route y :q '((:q :f) (:f :q))) '(:ya-j1 :ya-k2s :ya-k3)))   ; the last allowed press wins; the eaten J
  (check (equal (route y :q '((:q) (:q) (:q))) '(:ya-j1 :ya-j2 :ya-j3)))   ; link 3 latches nothing: no link 4
  (check (equal (route y :q '(() (:q))) '(:ya-j1)))                       ; nothing pressed: it stops at link 1
  (check (equal (route r :f '((:q) (:q))) '(:ke-r-k1 :ke-r-j2s :ke-r-j3)))
  (check (equal (route (kit :kenpachi :nomihose) :f '((:f) (:f))) '(:ke-n-f1 :ke-r-k2 :ke-r-k3)))   ; KUKAN-GIRI is cup 3's K1
  (check (and (eq (string-latch y :ya-k2s :q :f) :f) (eq (string-latch y :ya-k2s :q nil) nil)
              (eq (string-latch y :ya-j1 :f :q) :f) (not (string-link-p y :ya-j3)) (not (string-link-p y :ya-sig)))))
;; KATATE (+2) keeps S_eff 14: :enter grows with the startup (J1 9, K1 18, K2 22 from 8); the design's examples
(let ((t1 (kit :kenpachi :nozarashi)))
  (check (and (= 9 (mv-s (kit-move t1 :ke-j1))) (= 18 (mv-s (kit-move t1 :ke-k1))) (= 22 (mv-s (kit-move t1 :ke-k2)))
              (= 8 (mv-enter (kit-move t1 :ke-k2))) (= 8 (mv-enter (kit-move t1 :ke-k3))) (= 10 (mv-s (kit-move t1 :ke-j3))))))
;; the route damage of Kenpachi base on hit (§3.5, before multipliers; the combo scaling starts at hit 4; K2 / K3 at 80 %
;; of the design's, §9): JJJ 112, KKK 210 (the design's 245), KJJ 147; the O ender as hit 4 x0.9 = 63
(flet ((dmg (&rest names) (loop for n in names for i from 1 sum (hit-damage (mv-dmg (mv :kenpachi :base n)) nil nil i nil))))
  (check (and (= 112 (dmg :ke-j1 :ke-j2 :ke-j3)) (= 210 (dmg :ke-k1 :ke-k2 :ke-k3)) (= 147 (dmg :ke-k1 :ke-j2s :ke-j3))
              (= 63 (hit-damage 70 nil nil 4 nil)))))
;; Yama's J1 -> J2 on block: exactly the 6 f gap (free on step 23, J2 hits on step 21 + 8)
(let ((q1 (mv :yamamoto :base :ya-j1)) (q2 (mv :yamamoto :base :ya-j2)))
  (check (= 23 (nth-value 1 (free-steps q1))))
  (check (= 6 (- (+ (- (mv-total q1) *chain-lead*) (mv-s q2)) (nth-value 1 (free-steps q1))))))
(check (~= (mv-clip-speed (mv :kenpachi :nozarashi :ke-j1)) (/ 7.0 9.0)))  ; hit pose on the later hit frame
(check (~= (mv-clip-speed (mv :kenpachi :base :ke-j1)) 1.0))
;; KOSEI (§5): x1 at a full guard gauge, x3 empty, x2 half; a JJJ (g 24) pays 4.8 R / 2.4 FS full, 14.4 / 7.2 empty
(check (and (~= (kosei-mult 100.0) 1.0) (~= (kosei-mult 0.0) 3.0) (~= (kosei-mult 50.0) 2.0) (~= *kosei-bonus* 2.0)))
(multiple-value-bind (r fs m) (kosei-gain 24 100.0) (check (and (~= r 4.8) (~= fs 2.4) (~= m 1.0))))
(multiple-value-bind (r fs m) (kosei-gain 24 0.0) (check (and (~= r 14.4) (~= fs 7.2) (~= m 3.0))))
(check (= 24 (loop for n in '(:ke-j1 :ke-j2 :ke-j3) sum (hw-guard (svref (mv-hits (mv :kenpachi :base n)) 0)))))
(check (= (move-end-frame 9 3 12 18 nil nil) 30))                      ; whiff: R + 6
(check (and (= (move-end-frame 9 3 12 18 :block nil) 24) (= (move-end-frame 2 1 20 26 nil t) 23)))

;;; ================================================================ damage (§4)
(check (and (~= (combo-scale 1) 1.0) (~= (combo-scale 3) 1.0) (~= (combo-scale 4) 0.9)
            (~= (combo-scale 9) 0.4) (~= (combo-scale 12) 0.4)))
(check (= (hit-damage 100 nil nil 1 nil) 100))
(check (= (hit-damage 100 '(:mult 1.3) nil 1 nil) 130))                 ; Hellfire
(check (= (hit-damage 100 '(:cornered 0.05 :cornered-max 0.25 :lost 2) nil 1 nil) 110))
(check (= (hit-damage 100 '(:cornered 0.05 :cornered-max 0.25 :lost 6) nil 1 nil) 125))   ; capped
(check (= (hit-damage 100 '(:mult 1.15 :cornered 0.05 :cornered-max 0.25 :lost 3) nil 5 t) 132)) ; x1.15x1.15x1.25x0.8
(check (= (hit-damage 100 nil nil 20 nil) 40))                          ; floor 40 %
(check (= (hit-damage 1 nil nil 12 nil) 1))                             ; a hit always does 1
(check (= (hit-damage 0 '(:mult 2.0) nil 1 t) 0))
(check (= (hit-damage 100 (kit-atk-mods (kit :yamamoto :bankai-east) 4) nil 1 nil) 100))     ; East x1.0 (the rework)
(check (and (= (hit-damage 100 (kit-atk-mods (kit :kenpachi :nozarashi) 4) nil 1 nil) 120)   ; KATATE x1.0 x Cornered 1.20
            (= (hit-damage 100 (kit-atk-mods (kit :kenpachi :ryote) 4) nil 1 nil) 138)      ; RYOTE 1.15 x 1.20
            (= (hit-damage 100 (kit-atk-mods (kit :kenpachi :nomihose) 5) nil 1 nil) 150))) ; worst case 1.2 x 1.25
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
;; the dash-in: a non-red victim reels *KIKON-FOLLOW-STUN*, then has *KIKON-FOLLOW-GAP* frames (a guard needs
;; *GUARD-RAISE*) before the strike: a guard held during the dash blocks it; a red one reels until it has landed
;; and can't guard it (iframes still dodge it)
(check (and (>= *kikon-follow-gap* (+ *guard-raise* 1)) (= (kikon-follow-wait 6) (- (+ *kikon-follow-stun* 1 *kikon-follow-gap*) 6))
            (= (kikon-follow-wait 99) 0) (~= *kikon-follow-kb* 2.5)))
(check (and (null (kikon-follow-unguardable-p nil)) (kikon-follow-unguardable-p t)))
(check (and (eq (resolve-contact :guard :unguardable (kikon-follow-unguardable-p nil)) :blocked)     ; not red: blocked
            (eq (resolve-contact :guard :unguardable (kikon-follow-unguardable-p t)) :hit)           ; red: the Kikon
            (eq (resolve-contact :stance :unguardable (kikon-follow-unguardable-p t)) :hit)
            (eq (resolve-contact :parry :unguardable (kikon-follow-unguardable-p t)) :hit)
            (null (resolve-contact :invuln :unguardable (kikon-follow-unguardable-p t)))))
(dolist (cf *forms*)
  (let ((s (mv-s (kit-command-move (apply #'kit cf) :kikon))))
    (check (= (+ (kikon-follow-wait s) s) (+ (kikon-follow-stun nil s) 1 *kikon-follow-gap*)))     ; free GAP f first
    (check (> (kikon-follow-stun t s) (+ (kikon-follow-wait s) s)))))                              ; red: still reeling
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
(check (eql (time-up-winner 3 100 1000 2 900 1000) 0))                   ; Konpaku first
(check (eql (time-up-winner 2 900 1000 3 100 1000) 1))
(check (eql (time-up-winner 2 600 1000 2 500 1000) 0))                   ; then Reishi %
(check (eql (time-up-winner 2 500 1000 2 525 1050) :draw))               ; 50 % each
(multiple-value-bind (ax az bx bz) (reset-placement 10.0 0.0 12.0 0.0)
  (check (and (~= ax -4.0) (~= az 0.0) (~= bx 4.0) (~= bz 0.0))))

;;; ================================================================ gauges
(check (and (~= (reiatsu-gain 100 0) 8.0) (~= (reiatsu-gain 0 100) 10.0) (~= (reiatsu-gain 0 0 60) 3.0)))   ; SPs only: 3 / s
(check (~= (awakening-gain 100 100 1) 18.9))                                ; x0.7 since 2026-09-30 (was 27)
(check (and (~= *awaken-dealt* 0.035) (~= *awaken-taken* 0.049) (~= *awaken-per-konpaku* 10.5)))
(check (and (~= (gauge-add 290.0 20.0 300.0) 300.0) (~= (gauge-add 5.0 -10.0 300.0) 0.0)))
(check (equal (multiple-value-list (spend-bars 150.0 1)) '(50.0 t)))
(check (equal (multiple-value-list (spend-bars 50.0 1)) '(50.0 nil)))
(check (and (hoho-allowed-p nil 30.0 0) (not (hoho-allowed-p t 100.0 0))          ; flash-step 30
            (not (hoho-allowed-p nil 100.0 10)) (not (hoho-allowed-p nil 29.0 0))))
(check (and (awaken-allowed-p t 100.0 nil) (not (awaken-allowed-p t 100.0 t)) (not (awaken-allowed-p nil 100.0 nil))
            (not (awaken-allowed-p t 99.0 nil))))
;; the burst modes (docs/duel/DUEL_DESIGN.md "Burst modes", the user 2026-09-30): the state picks the mode
(check (and (eq (burst-mode :stun nil 2 nil) :blue) (eq (burst-mode :air nil 3 nil) :blue) (null (burst-mode :stun nil 1 nil))
            (eq (burst-mode :guard-hit nil 0 nil) :blue)                        ; blockstun: from any blocked hit
            (eq (burst-mode :move nil 0 t) :orange) (null (burst-mode :move nil 0 nil))   ; a hit's window / a whiff or block
            (eq (burst-mode :idle nil 0 nil) :white) (eq (burst-mode :guard nil 0 nil) :white) (eq (burst-mode :run nil 0 nil) :white)
            (null (burst-mode :step nil 0 nil)) (null (burst-mode :hoho nil 0 nil)) (null (burst-mode :down nil 5 nil))
            (null (burst-mode :cine nil 0 nil)) (null (burst-mode :idle t 0 nil)) (null (burst-mode :stun t 5 nil))))   ; locked
(check (and (burst-allowed-p :white 70.0 nil) (burst-allowed-p :orange 70.0 nil) (burst-allowed-p :blue 100.0 nil)   ; 70 for every mode
            (not (burst-allowed-p :white 69.9 nil)) (not (burst-allowed-p :blue 69.0 nil)) (not (burst-allowed-p :orange 60.0 nil))
            (not (burst-allowed-p nil 100.0 nil)) (not (burst-allowed-p :white 100.0 :blue))))   ; no mode / one running
;; the drain: 18 / s, to 0 then it ends; from 70 3.9 s, from 100 5.6 s
(check (and (= *burst-drain* 18) (~= (burst-drain 50.0) (- 50.0 0.3)) (~= (burst-drain 0.1) 0.0)))
(flet ((frames (fs) (loop for n from 1 do (setf fs (burst-drain fs)) when (<= fs 0.0) return n)))
  (check (and (<= 232 (frames 70.0) 234) (<= 332 (frames 100.0) 334))))
;; no flash-step gain during a burst; Hoho below one bar spends what is left
(check (and (~= (burst-fs-gain 12.0 nil) 12.0) (~= (burst-fs-gain 12.0 :white) 0.0) (~= (burst-fs-gain 15.0 :orange) 0.0)))
(check (and (hoho-allowed-p nil 12.0 0 :white) (hoho-allowed-p nil 0.1 0 :blue) (not (hoho-allowed-p nil 0.0 0 :blue))
            (not (hoho-allowed-p nil 12.0 0)) (not (hoho-allowed-p nil 12.0 5 :white)) (not (hoho-allowed-p t 50.0 0 :white))))
(check (and (~= (hoho-cost 12.0 :white) 12.0) (~= (hoho-cost 80.0 :white) 30.0) (~= (hoho-cost 80.0 nil) 30.0)))
;; WHITE: Reishi +12 / s in whole points (60 f pay exactly 12), no guard-gauge boost (gg-regen has no WHITE input)
(check (and (= 70 (loop for n from 1 to 60 sum (burst-heal n *white-reishi*))) (= 66 (loop for n from 1 to 333 sum (burst-heal n 12.0)))
            (= 1 (burst-heal 5 12.0)) (= 0 (burst-heal 4 12.0))))
(check (and (~= *white-reishi* 70.0) (~= *white-reiatsu* 15.0) (~= *white-awaken* 1.4)))
;; BLUE: the guard gauge refills with no delay, x2 when free, x0.5 even while guarding (GUARD HOLD otherwise)
(check (and (~= (gg-regen 50.0 999 nil nil nil 0.25) (+ 50.0 (/ (* 0.25 *gg-regen*) 60)))   ; a form's :gg-regen (Bankai East)
            (~= (gg-regen 50.0 999 t nil nil 0.25) (+ 50.0 (/ *gg-regen-guardless* 60)))   ; (guardless: unchanged)
            (= 0.25 (kit-gg-regen (find-kit :yamamoto :bankai-east))) (= 1.0 (kit-gg-regen (find-kit :yamamoto :base)))))
(check (and (~= (gg-regen 50.0 0 nil nil :blue) (+ 50.0 (/ 11.0 60))) (~= (gg-regen 50.0 0 nil t :blue) (+ 50.0 (/ 2.75 60)))
            (~= (gg-regen 50.0 0 t nil :blue) (+ 50.0 (/ 13.0 60))) (~= (gg-regen 99.99 0 nil t :blue) 100.0)
            (~= (gg-regen 50.0 999 nil t) 50.0)))                            ; outside BLUE: GUARD HOLD as ever
;; ORANGE: the cancel window is the hit's cancel window (first hit frame .. end of recovery); the startup cut 40 %, >= 1 f left
(check (and (cancel-open-p 12 10 30 t) (not (cancel-open-p 9 10 30 t)) (not (cancel-open-p 30 10 30 t)) (not (cancel-open-p 12 10 30 nil))))
;; the guard cancel (the user, 2026-10-01): only after its own hit, over the last half of the recovery (K2 21/4/24: f37-44)
(check (and (= 0.5 *guard-cancel*) (not (guard-cancel-open-p 36 21 4 24 :hit)) (guard-cancel-open-p 37 21 4 24 :hit)
            (guard-cancel-open-p 48 21 4 24 :hit) (not (guard-cancel-open-p 49 21 4 24 :hit))
            (not (guard-cancel-open-p 40 21 4 24 :block)) (not (guard-cancel-open-p 40 21 4 24 nil))))
;; the arena's room for a push (RAY-ROOM): from the centre 5 to an r 5 edge; at 4 m out along +x, 1 left that way and 9 back
(check (and (< (abs (- (ray-room 0.0 0.0 1.0 0.0 5.0) 5.0)) 1e-4) (< (abs (- (ray-room 4.0 0.0 1.0 0.0 5.0) 1.0)) 1e-4)
            (< (abs (- (ray-room 4.0 0.0 -1.0 0.0 5.0) 9.0)) 1e-4) (= 0.0 (ray-room 5.0 0.0 1.0 0.0 5.0))))
;; a J (QUICK) may guard-cancel on block too (the user 2026-10-02): J1 9/3/12 opens f18-23; never on a whiff
(check (and (guard-cancel-open-p 18 9 3 12 :block t) (not (guard-cancel-open-p 17 9 3 12 :block t))
            (not (guard-cancel-open-p 24 9 3 12 :block t)) (not (guard-cancel-open-p 20 9 3 12 nil t))
            (guard-cancel-open-p 20 9 3 12 :hit t)))
(check (and (= (chain-startup-cut 10 0) 4) (= (chain-startup-cut 20 0) 8) (= (chain-startup-cut 2 0) 0) (= (chain-startup-cut 1 0) 0)
            (= (chain-startup-cut 3 0) 1) (= (chain-startup-cut 12 2) 4) (= *chain-window* 12)))
(check (and (~= (burst-gain-mult :orange) 1.5) (~= (burst-gain-mult :white) 1.0) (~= (burst-gain-mult nil) 1.0)))
(check (and (~= (nth-value 0 (hit-gains 100 0 nil 1.5)) 12.0) (~= (nth-value 2 (hit-gains 100 0 nil 1.5)) 5.25)   ; x1.5 dealt
            (~= (nth-value 0 (hit-gains 0 100 nil 1.5)) 10.0) (~= (nth-value 0 (hit-gains 100 0 nil)) 8.0)))    ; taken untouched
;; the Kikon refund: a flash-step bar (35) and a Reiatsu bar, clamped
(check (and (equal (multiple-value-list (kikon-refund 10.0 50.0)) '(45.0 150.0))
            (equal (multiple-value-list (kikon-refund 90.0 250.0)) '(100.0 300.0))))
;; the flash-step gauge (design v3 G.1): Hoho 30, Burst 70, no Reiatsu; 3 / s after 60 f; +0.03 per damage taken
(check (and (= *fs-hoho* 30) (= *fs-burst* 70) (= *fs-refund* 15) (~= *fs-taken* 0.03) (= *fs-max* 100)))
(check (and (~= (fs-regen 50.0 59) 50.0) (~= (fs-regen 50.0 60) 50.05) (~= (fs-regen 99.99 600) 100.0)))
(check (~= 3.0 (- (loop with f = 0.0 for i below 60 do (setf f (fs-regen f 60)) finally (return f)) 0.0)))   ; 3 per second
(check (~= 600 (/ *fs-hoho* (/ *fs-regen* 60.0)) 0.5))                     ; ... a Hoho from empty in 11 s (10 + the 1 s delay)
;; the guard gauge (G.2): values by kind, +4 for an ender, overrides; the drain, the crush, the regen, guardless
(check (and (= (guard-value :quick -2) 8) (= (guard-value :quick -12) 12) (= (guard-value :flash -4) 14)
            (= (guard-value :flash -14) 18) (= (guard-value :sig -6) 18) (= (guard-value :sig -14) 22)
            (= (guard-value :sp -16) 22) (= (guard-value :kikon -14) 20) (= (guard-value nil nil) 12)
            (= (guard-value :sig -6 10) 10)))
(check (and (= (hw-guard (svref (mv-hits (mv :kenpachi :base :ke-j3)) 0)) 8)             ; J3 (-4) 8
            (= (hw-guard (svref (mv-hits (mv :kenpachi :base :ke-k3)) 0)) 18)            ; K3 ender (-20) 18
            (= (hw-guard (svref (mv-hits (mv :yamamoto :base :ya-sig)) 0)) 10)           ; the Signature's cuts 10 each
            (= 15 (getf (mv-params (find-move :ya-sig)) :guard))))                       ; ... its wave 15
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
;; East's pierce (the rework): k = 0.1 .. 0.5 by his guard gauge (full = sharpest, the user's decision 2026-09-27), x a
;; move's :pierce-mult (KYOKKO 2: 0.2 .. 1.0). On hit x(1 + k) (KIT-ATK-MODS' pierce factor): E-Q1 Q2 E-Q3 (34 38 55)
;; at full = 51 + 57 + 82 = 190 (82.5 rounds to even); blocked, k x the damage goes through as chip (never kills): 17 + 19 + 28 = 64 at
;; full, 3 + 4 + 6 = 13 empty; KYOKKO at full: 170 on hit, all 85 through a guard
(check (and (~= *pierce-min* 0.1) (~= *pierce-max* 0.45) (~= *ward-mult* 1.1)))   ; the gate's values (2026-09-27)
(let ((*pierce-max* 0.5))                                                  ; the spec's arithmetic at 0.5
 (check (and (~= (pierce-rate 100.0) 0.5) (~= (pierce-rate 0.0) 0.1)
             (~= (pierce-rate 50.0) 0.3) (~= (pierce-rate 100.0 2.0) 1.0) (~= (pierce-rate 0.0 2.0) 0.2)))
 (let ((east (kit :yamamoto :bankai-east)))
  (flet ((hit (dmg gg &optional (m 1.0)) (hit-damage dmg (kit-atk-mods east 0 (+ 1.0 (pierce-rate gg m))) nil 1 nil))
         (through (dmg gg &optional (m 1.0)) (chip-damage dmg (pierce-rate gg m) 1300)))
    (check (= 190 (+ (hit 34 100.0) (hit 38 100.0) (hit 55 100.0))))
    (check (= 165 (+ (hit 34 50.0) (hit 38 50.0) (hit 55 50.0))))
    (check (= 64 (+ (through 34 100.0) (through 38 100.0) (through 55 100.0))))
    (check (= 13 (+ (through 34 0.0) (through 38 0.0) (through 55 0.0))))
    (check (and (= 170 (hit 85 100.0 2.0)) (= 85 (through 85 100.0 2.0)) (= 102 (hit 85 0.0 2.0)) (= 17 (through 85 0.0 2.0))))
    (check (= 49 (chip-damage 85 1.0 50))))))                                  ; the pierce never kills: it leaves 1
(check (and (~= (pierce-rate 100.0) 0.45) (~= (pierce-rate 100.0 2.0) 0.9)))    ; as tuned: KYOKKO 162 / 77 at full
;; the ward never refills: GUARD HOLD counts it as guarding (combat.lisp GAUGE-SYSTEM), so the gauge stands still and
;; the delay is frozen; West's drain is x*WARD-MULT*; Kenpachi's base Q string (28) crushes it on the 4th string
(check (and (~= (gg-regen 40.0 9999 nil t) 40.0) (= (gg-idle-next 30 t) 30)))
(check (and (can-guard-p 1.0 nil) (not (can-guard-p 0.0 nil)) (not (can-guard-p 99.0 t))))
;; a guard crush: Kenpachi's Q1 blocked into an empty gauge -> the attacker acts 25 frames first
(let ((q1 (mv :kenpachi :base :ke-j1)))
  (check (= 25 (- *guard-crush-stun* (- (mv-total q1) (mv-first-hit q1)))))
  (check (= *gg-breaker* 35)))
;; the CPU's guard: all at >= 50 %, half at 25-50 %, 0.15 below, none guardless; flash-step budgeting
(check (and (~= (ai-guard-mult 50.0 nil) 1.0) (~= (ai-guard-mult 30.0 nil) 0.5) (~= (ai-guard-mult 10.0 nil) 0.15)
            (~= (ai-guard-mult 100.0 t) 0.0) (~= (ai-guard-mult 0.0 nil) 0.0)))
(check (and (ai-hoho-spare-p 30.0 1000 1100) (not (ai-hoho-spare-p 90.0 400 1100)) (ai-hoho-spare-p 100.0 400 1100)))
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
(check (= (stun-tolerance-of (kit :rukia :base)) 13.0))
(check (= (stun-tolerance-of (kit :kenpachi :bankai)) 26.0))              ; derived forms inherit it
(check (= (stun-tolerance-of (kit :ichigo :kessa)) 16.0))
(check (= (stun-tolerance-of (kit :senjumaru :tsuji6)) 13.0))
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
;; Yama's Q1 (window [9,12), 1.4 m arc: the J floor) from the origin facing -Z; our cylinder r 0.4 h 1.8
(let* ((q1 (mv :yamamoto :base :ya-j1)) (w (svref (mv-hits q1) 0)))
  (flet ((perfect (sf z) (perfect-hoho-p sf (hw-from w) (hw-to w) (hw-vols w)
                                         0f0 0f0 0f0 0f0 -1f0 0f0 0f0 (float z 1f0) 0.4f0 1.8f0)))
    (check (perfect 3 -2.0))                  ; active in 6 f: perfect
    (check (perfect 0 -2.0))                  ; 9 f away: inside the 12 f lead (8 until 2026-10-01)
    (check (not (perfect-hoho-p 0 (+ (hw-from w) 4) (+ (hw-to w) 4) (hw-vols w)   ; 13 f away: too early
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
(check (and (~= (kit-run (kit :yamamoto :base)) 8.0) (~= (kit-run (kit :kenpachi :base)) 10.0)
            (~= (kit-run (kit :kenpachi :nozarashi)) 10.0) (~= (kit-run (kit :yamamoto :bankai-east)) 8.0)))
;; the run faces the opponent: one clip set per character (every Kenpachi form shares his)
(check (and (equal (kit-run-clips (kit :yamamoto :bankai-west)) '(:sh-run :sh-skate-b :sh-slide-r :sh-slide-l))
            (equal (kit-run-clips (kit :kenpachi :nozarashi)) (kit-run-clips (kit :kenpachi :base)))
            (eq (first (kit-run-clips (kit :kenpachi :base))) :ke-run)))
(check (and (> (getf (kit-ai (kit :kenpachi :base)) :dash) (getf (kit-ai (kit :yamamoto :base)) :dash))   ; Ken dashes more
            (getf (kit-ai (kit :yamamoto :base)) :dash-back)))                                          ; Yama backs off to zone

;;; ================================================================ AI helpers
(check (and (eq (weighted-pick 0.0 :a 1 :b 1) :a) (eq (weighted-pick 0.5 :a 1 :b 1) :b)
            (eq (weighted-pick 0.1 :a 0 :b 1) :b) (null (weighted-pick 0.5 :a 0))))
(let ((bands (getf (kit-ai (kit :yamamoto :base)) :moves)))
  (check (eq (apply #'weighted-pick 0.0 (band-weights bands 6.0)) :sig))   ; Signature at 5-8 m
  (check (eq (apply #'weighted-pick 0.0 (band-weights bands 9.0)) :sp1)))  ; Shiranui beyond 8 m
(check (equal (multiple-value-list (heat-range 6.0 8.0 10.0)) '(3.0 5.0)))
(check (equal (multiple-value-list (heat-range 6.0 8.0 30.0)) '(1.0 1.0)))
(check (and (= (heat-breaker-mult 7.9) 1) (= (heat-breaker-mult 8.0) 2)))
(check (and (~= (heat-after 1.0 nil) (+ 1.0 (/ *ai-heat-rate* 60))) (~= (heat-after 1.0 t) (+ 1.0 (/ *ai-heat-rate* 30)))))

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
  '((:ya-j1 9 3 12 38 -2) (:ya-j2 8 3 13 38 -2) (:ya-j3 9 3 18 45 -4) (:ya-k1 18 4 20 75 -3)
    (:ya-k2 22 4 24 64 -3) (:ya-k3 22 5 34 88 -20) (:ya-sig 16 ? 26 30 -6) (:ya-taimatsu 16 8 24 120 -14)
    (:ya-nadegiri 20 4 30 240 -16) (:ya-breaker 8 4 18 150 :guard-break) (:ya-kyoku 18 5 26 90 -16)
    (:ya-kaka 20 1 34 0 nil)
    ;; Bankai East / West (DUEL_STRINGS §3.2; the rework's L moves)
    (:ya-e-j1 8 3 12 34 -2) (:ya-e-j2 7 3 13 38 -2) (:ya-e-j3 8 3 18 42 -4) (:ya-e-k1 16 4 20 70 -3)
    (:ya-e-k2 19 4 24 60 -3) (:ya-e-k3 21 5 34 84 -20) (:ya-e-kyokko 15 3 26 85 -12) (:ya-w-shonetsu 16 0 24 0 nil)
    (:ya-w-parry 2 24 20 0 nil) (:ya-w-counter 6 3 24 150 -12)
    (:ke-j1 7 3 12 35 -2) (:ke-j2 7 3 13 35 -2) (:ke-j3 8 3 18 42 -4) (:ke-k1 16 4 20 70 -3)
    (:ke-k2 20 4 24 60 -3) (:ke-k3 20 5 34 80 -20) (:ke-stance 8 4 24 100 -14) (:ke-buttagiru 22 4 26 180 -14)
    (:ke-charge 14 ? ? 25 -16) (:ke-breaker 8 4 18 150 :guard-break) (:ke-meteor 26 4 30 240 ?)
    ;; RYOTE's kendo strings (DUEL_STRINGS §3.4), NOMIHOSE's space cut and cash-out (DUEL_NOZARASHI_V2 §2.3)
    (:ke-r-j1 10 3 12 40 -2) (:ke-r-j2 9 3 13 38 -2) (:ke-r-j3 10 3 18 48 -4) (:ke-r-k1 19 4 20 85 -3)
    (:ke-r-k2 21 4 24 68 -3) (:ke-r-k3 21 5 34 92 -20) (:ke-n-f1 20 4 22 90 -4) (:ke-meteor-n 26 4 30 390 -16)))
(dolist (row *table*)
  (destructuring-bind (name s a r dmg adv) row
    (let ((m (find-move name)))
      (flet ((same (want got) (or (eq want '?) (equal want got))))
        (unless (and (same s (mv-s m)) (same a (mv-a m)) (same r (mv-r m)) (same dmg (mv-dmg m))
                     (same adv (mv-adv-block m)))
          (format t "  table mismatch ~s~%" name))
        (check (and (same s (mv-s m)) (same a (mv-a m)) (same r (mv-r m)) (same dmg (mv-dmg m))
                    (same adv (mv-adv-block m))))))))
(check (equal (map 'list (lambda (w) (list (hw-from w) (hw-dmg w))) (mv-hits (find-move :ya-sig)))
              '((16 30) (28 30))))                                        ; hits f16, f28, 30 each
(check (= 110 (getf (mv-params (find-move :ya-sig)) :dmg)))              ; the wave
(check (equal (mv-hold (find-move :ke-stance)) '(6 60)))
(check (equal (mv-hold (find-move :ya-shiranui)) '(12 60)))

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
                      (every (lambda (w) (and (<= (mv-s m) (hw-from w)) (< (hw-from w) (hw-to w))
                                              (<= (hw-to w) (+ (mv-s m) (mv-a m))) (or (hw-vols w) (hw-seg w))))
                             (mv-hits m))
                      (or (eq (mv-kind m) :kikon) (zerop (mv-dmg m)) (plusp (length (mv-hits m))))
                      (every (lambda (e) (and (< (first e) (mv-total m)) (symbolp (second e)))) (mv-on-frame m))
                      (every #'symbolp (list (mv-tick m) (mv-release m) (mv-on-land m) (mv-cine m)))
                      (or (not (eq (mv-kind m) :kikon)) (mv-cine m)))))
         (unless ok (format t "  bad move ~s in ~s~%" name cf))
         (check ok)))
     (kit-moves k))))
;; costs
(check (and (= (kit-command-cost (kit :yamamoto :base) :sp2) 1) (= (kit-command-cost (kit :yamamoto :base) :sp1) 1)
            (= (kit-command-cost (kit :yamamoto :hellfire) :sp2) 2) (= (kit-command-cost (kit :yamamoto :bankai-east) :sp2) 2)
            (= (kit-command-cost (kit :kenpachi :nozarashi) :sp2) 2) (= (kit-command-cost (kit :kenpachi :base) :q) 0)))
;; forms: multipliers, inheritance, the Hellfire / Bankai swaps
(check (and (~= (kit-mult (kit :yamamoto :hellfire)) 1.3) (~= (kit-mult (kit :yamamoto :bankai-east)) 1.0)
            (~= (kit-mult (kit :kenpachi :nozarashi)) 1.0) (~= (kit-mult (kit :kenpachi :ryote)) 1.15) (~= (kit-mult (kit :kenpachi :nomihose)) 1.2) (~= (kit-mult (kit :kenpachi :base)) 1.0)))
(check (eq (mv-name (kit-command-move (kit :yamamoto :hellfire) :sp2)) :ya-nadegiri))
(check (eq (mv-name (kit-command-move (kit :yamamoto :hellfire) :sp1)) :ya-shiranui))  ; inherited
(check (eq (mv-name (kit-command-move (kit :yamamoto :bankai-east) :kikon)) :ya-tenchi))
;; the Kikon rush of every form: a strike with a cinematic, clearly punishable on block (-14; K1 of either character
;; reaches it after the block pushback from the trigger range: J1 did until the J cut of 2026-09-29, now it walks in),
;; reach beyond the trigger
(dolist (cf *forms*)
  (let ((m (kit-command-move (apply #'kit cf) :kikon)))
    (check (and (eq (mv-kind m) :kikon) (mv-cine m) (= 1 (length (mv-hits m))) (<= (mv-adv-block m) -12)
                (> (mv-reach m) *kikon-trigger*) (plusp (mv-dmg m))
                (<= (+ *kikon-trigger* *block-pushback*) (min (mv-reach (mv :yamamoto :base :ya-k1))
                                                              (mv-reach (mv :kenpachi :base :ke-k1))))))))
;; the O modules (design v2 §B): cooldown 90, a melee strike with its cinematic, reach and press -> hit,
;; aura >= 5 (>= 8 for a locked dash), armour <= 1 hit; the melee ones strike from *KIKON-TRIGGER* (a
;; blocked strike stays punishable); ENJO has no dash (a lane, locked)
(defparameter *modules* '((:yamamoto :base :ya-kikon 9.0 26) (:yamamoto :bankai-east :ya-tenchi 10.0 30) (:yamamoto :bankai-west :ya-tenchi 10.0 30)
                          (:kenpachi :base :ke-kikon 9.4 50) (:kenpachi :nozarashi :ke-kikon-n 10.6 49)))
(dolist (row *modules*)
  (destructuring-bind (c f name reach press) row
    (let* ((m (mv c f name)) (p (mv-params m)))
      (flet ((pa (k) (getf p k)))
        (check (and (eq (mv-name (kit-command-move (kit c f) :kikon)) name) (= (mv-cooldown m) 90) (mv-cine m)
                    (= 70 (mv-dmg m)) (= -14 (mv-adv-block m)) (>= (pa :aura) 5) (<= (mv-armor-hits m) 1)
                    (or (plusp (pa :dash-track)) (zerop (pa :dash-max)) (>= (pa :aura) 8))))
        (check (~= reach (max (mv-reach m) (kikon-rush-reach (pa :speed) (pa :dash-max))) 0.01))
        (check (= press (+ (pa :aura) (pa :dash-max) (mv-s m))))))))
(check (and (= (mv-armor-hits (find-move :ke-kikon)) 1) (zerop (mv-armor-hits (find-move :ya-tenchi)))))
(check (and (~= 0.0 (mv-track (find-move :ya-kikon))) (~= 0.0 (getf (mv-params (find-move :ya-tenchi)) :dash-track))
            (~= 0.0 (getf (mv-params (find-move :ke-kikon-n)) :dash-track)) (~= 150.0 (getf (mv-params (find-move :ke-kikon)) :dash-track))))
(check (~= 160 (/ (* 2 (aref (first (hw-vols (svref (mv-hits (find-move :ke-kikon-n)) 0))) 2)) (deg 1))))   ; the widest strike
(check (and (~= (mv-clip-speed (mv :kenpachi :nozarashi :ke-kikon-n)) (/ 8.0 11.0)) (~= (mv-clip-speed (mv :kenpachi :base :ke-kikon)) (/ 8.0 9.0))
            (~= (mv-clip-speed (mv :yamamoto :bankai-east :ya-tenchi)) 1.0)))    ; clips reach their hit pose on frame S
                                                                                 ; (TENCHI's own clip since DUEL_YAMA_TYBW §3.2)
;; cooldowns: every command slot of the fighter's CD vector
(check (= 7 (length *kit-commands*)))
(check (and (null (kit-meter (kit :yamamoto :bankai-east))) (kit-meter (kit :yamamoto :hellfire))))  ; no Hellfire in Bankai
(check (and (kit-awakening (kit :yamamoto :bankai-east)) (not (kit-awakening (kit :yamamoto :hellfire)))
            (null (kit-duration (kit :kenpachi :nozarashi))) (null (kit-duration (kit :yamamoto :bankai-east)))))   ; both awakenings last the match
(check (and (member :ward (kit-passives (kit :yamamoto :bankai-west)))
            (not (member :ward (kit-passives (kit :yamamoto :bankai-east))))))
(check (and (~= (kit-walk (kit :yamamoto :base)) 3.2) (~= (kit-walk (kit :kenpachi :nozarashi)) 4.4)))
(check (~= (kit-reset-reiatsu (kit :kenpachi :base)) 10.0))
;; Nozarashi: derived by the kit, not copied (startup +3, reach x1.4), own moves as written
(let ((base (mv :kenpachi :base :ke-j1)) (noz (mv :kenpachi :nozarashi :ke-j1)))
  (check (and (= (mv-s base) 7) (= (mv-s noz) 9) (= (mv-r noz) 12) (= (mv-dmg noz) 35)
              (~= (mv-reach noz) (* 1.4 1.3)) (= (hw-from (svref (mv-hits noz) 0)) 9)
              (~= (aref (first (hw-vols (svref (mv-hits noz) 0))) 1) (* 1.4 1.3)))))
(check (= (mv-s (mv :kenpachi :nozarashi :ke-stance)) 10))
(check (= (mv-s (mv :kenpachi :nozarashi :ke-breaker)) 10))
(check (~= (aref (first (hw-vols (svref (mv-hits (mv :kenpachi :nozarashi :ke-charge)) 0))) 2) (* 1.4 1.3)))
(check (= (mv-s (mv :kenpachi :nozarashi :ke-meteor)) 26))
(check (eq (mv :kenpachi :nozarashi :ke-meteor) (find-move :ke-meteor)))
(check (eq (kit-next (kit :kenpachi :nozarashi) :ke-j1 :q) (mv :kenpachi :nozarashi :ke-j2)))
;; clip names: exactly the §5 contract, and every §5 clip is used
(defparameter *clips-5*
  '(:ya-stance :ya-q1 :ya-q2 :ya-f1 :ya-f2 :ya-f3 :ya-sig :ya-shiranui :ya-shiranui-throw :ya-taimatsu
    :ya-nadegiri :ya-breaker :ya-ikkotsu :ya-intro :ya-win :ya-hellfire :ya-bankai :ya-kyoku
    :ya-kaka :sh-run :ya-enjo :ke-n-leap ; the O modules (TENCHI runs in :sh-run, CHARGE in :ke-charge)
    :ya-shonetsu :ya-w-parry :ya-w-counter   ; the Bankai stances
    :ya-e-stance :ya-e-q1 :ya-e-q2 :ya-e-q3 :ya-e-f1 :ya-e-f2 :ya-e-kyokko :ya-e-tenchi   ; East's own (DUEL_YAMA_TYBW §3.2)
    :ya-tsuka :ya-e-drop :ke-kick :ke-r-kote :ke-r-tsuki   ; the strings' new clips (DUEL_STRINGS §3)
    :ke-stance :ke-q1 :ke-q2 :ke-q3 :ke-f1 :ke-f2 :ke-stance-hold :ke-stance-cut :ke-buttagiru :ke-charge
    :ke-flurry :ke-breaker :ke-shoulder :ke-intro :ke-win :ke-release :ke-nome :ke-meteor
    :ke-n-stance
    :sh-skate-b :sh-slide-r :sh-slide-l :ke-run :ke-skate-b :ke-slide-r :ke-slide-l   ; the runs (facing the opponent)
    :ke-r-stance :ke-drink     ; the cups
    :ke-r-q1 :ke-r-q3 :ke-r-f1 :ke-r-f2 :ke-n-f1     ; RYOTE's kendo set and KUKAN-GIRI (their own clips since Phase 5)
    :ke-b-stance :ke-b-fist :ke-b-bite                ; the Bankai (docs/duel/DUEL_KEN_BANKAI.md §12)
    :ke-b-hook :ic-cross-j :ic-k-jab :ic-k-wrap-j     ; the J cut's close J links (DUEL_STRINGS §13)
    :ke-b-leap :ke-b-run :ke-b-skate-b :ke-b-slide-r :ke-b-slide-l   ; its feral pass (2026-09-28; also 片腕)
    :ru-stance :ru-intro :ru-win :ru-q1 :ru-q2 :ru-spin :ru-thrust :ru-ring :ru-drop :ru-tsukishiro :ru-stab :ru-hakuren
    :ru-shirafune :ru-breaker :ru-hainawa :ru-cold-stance :ru-palm :ru-flower :ru-zero :ru-reido :ru-hakka   ; Rukia
    :ru-palm-50 :ru-spin-50 :ru-flower-50 :ru-stab-2h   ; her -50 key edits (zero's pinned J1 / K1 are body-variant clips)
    :ic-stance :ic-intro :ic-win :ic-q1 :ic-q2 :ic-spin :ic-f1 :ic-f2 :ic-drop :ic-cross :ic-getsuga :ic-juji :ic-breaker
    :ic-mine :ic-k-stance :ic-k-back :ic-k-parry :ic-k-yank :ic-k-zanzo   ; Ichigo (DUEL_ICHIGO §10, v2)
    :ic-tsuki :ic-rangetsu :ic-tsuki-otoshi :ic-soga :ic-juji-x   ; (SOGA's and the JUJI rush's own, DUEL_ICHIGO_TYBW §3.2)
    :ic-k-f1 :ic-k-f2 :ic-k-f3 :ic-k-gaeshi :ic-k-uchi   ; KESSA's own K, counter and O strike (DUEL_ICHIGO_TYBW §3.2)
    :sj-stance :sj-q1 :sj-q2 :sj-spin :sj-f1 :sj-f2 :sj-drop :sj-yank :sj-summon :sj-kasa :sj-breaker :sj-saidan :sj-intro
    :sj-win :sj-loom-stance :sj-weave :sj-unravel :sj-tanmono :sj-makitori :sj-snip   ; Senjumaru (:sj-awaken is the cine's)
    :lb-stance :lb-intro :lb-win :lb-q1 :lb-q2 :lb-aim :lb-fire :lb-sanren :lb-hiren :lb-breaker :lb-butt   ; Lille's shared
    :lb-w-stance :lb-w-q1 :lb-w-q2 :lb-w-q3 :lb-w-f1 :lb-w-f2 :lb-w-f3 :lb-w-sanren :lb-w-kikon :lb-w-kikon-fire   ;  art (the
    :lb-w-nijushi :lb-w-breaker :lb-w-ram :lb-o-stance :lb-o-q1 :lb-o-q2 :lb-o-q3 :lb-o-f1 :lb-o-f2 :lb-o-f3 :lb-o-chop   ;  old
    :lb-o-trompete :lb-o-breaker :lb-o-stamp :lb-kamae :lb-k-dash :lb-oe-stance   ;  Lille's, DUEL_LILLE §12, §22, §23)
    :br-f1 :br-f2 :br-f3                          ; the base form's attack-state K string (the user 2026-10-12: bold)
    :br-sk-l1 :br-sk-l1s :br-sk-lc :br-jab :br-sk-j1 :br-sk-j2 :br-sk-j3 :br-sk-k1 :br-sk-k2 :br-sk-k3   ; the base stance's strings
    :br-sk-jl1 :br-sk-jl2 :br-sk-jl3 :br-sk-kl1 :br-sk-kl2 :br-sk-kl3   ; and its follow-ups (DUEL_LILLE_V3 §8.3, §8.5; :lb-snap unused again)
    :br-en-l1 :br-en-j1 :br-en-j2 :br-en-j3 :br-en-k1 :br-en-k2 :br-en-k3   ; the awakened stance EN's openers,
    :br-en-lc :br-oen-lc                          ; (R10, DUEL_LILLE_V3 §15: the L charge's pose while held)
    :br-oen-l1 :br-oen-j1 :br-oen-j2 :br-oen-j3 :br-oen-k1 :br-oen-k2 :br-oen-k3   ; JILLIEL's and the owl's (§8)
    :br-e-jf1 :br-e-jf2 :br-e-jf3 :br-e-kf1 :br-e-kf2 :br-e-kf3 :br-oe-jf1 :br-oe-jf2 :br-oe-jf3 :br-oe-kf1 :br-oe-kf2 :br-oe-kf3
                                                  ; their L L follow-ups, by route (§8.5; V8's swings :br-e-swing / :br-oe-swing spare again)
    :br-recall :br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4 :br-to-en   ; Lille II's own (the art batch, DUEL_LILLE_V2 §12) ...
    :br-o-recall :br-o-rc0 :br-o-rc1 :br-o-rc2 :br-o-rc3 :br-o-rc4 :br-o-to-en   ; ... and the owl's (the backstep gone, v3 R3)
    :br-w-guard :br-w-guard-hit :br-o-guard :br-o-guard-hit :br-oe-guard :br-oe-guard-hit   ; his wing wall (the awakened guard)
    :ke-k-q1 :ke-k-q2 :ke-k-f1 :ke-k-f2 :ke-k-spin :ke-k-meteor   ; Kenpachi's cup 1 and cup 3 sets (DUEL_KEN_REWORK §6.2)
    :ke-x-stance :ke-x-q1 :ke-x-kote :ke-x-q3 :ke-x-f1 :ke-x-tsuki :ke-x-f2 :ke-x-meteor :ke-x-drink
    :ke-b-q1 :ke-b-q2 :ke-b-f1 :ke-b-f2 :ke-b-f3 :ke-b-split :ke-b-cut   ; the Bankai's own (§8)
    :ke-a-stance :ke-a-q1 :ke-a-q2 :ke-a-f1 :ke-a-f2 :ke-a-spin :ke-a-haymaker :ke-a-stomp :ke-a-flurry   ; KATAUDE's (§8)
    :hs-intro :hs-win                                                  ; Hisagi's B2a intro / win (the Bankai's forms)
    :hs-s-stance :hs-s-intro :hs-s-win :hs-s-walk-f :hs-s-walk-b :hs-s-strafe-r :hs-s-strafe-l   ; the Shikai's own
    :hs-s-run :hs-s-skate-b :hs-s-slide-r :hs-s-slide-l :hs-s-sen :hs-s-kaeshi :hs-s-rin :hs-s-kaeshi-1h :hs-s-rin-1h   ; (§21.4)
    :hs-s-nage :hs-s-hiki :hs-s-maki :hs-s-hodoki :hs-s-modoshi :hs-s-kaza :hs-s-raiden :hs-s-shibari   ; (S1, §23.3: :hs-s-kari no move's since; MAKI dormant)
    :hs-s-breaker :hs-s-kubikake :hs-s-kari-aim :hs-s-kari-o
    :hs-k-stance :hs-k-walk-f :hs-k-walk-b :hs-k-strafe-r :hs-k-strafe-l :hs-k-run :hs-k-skate-b :hs-k-slide-r   ; the Bankai's
    :hs-k-slide-l :hs-k-saben :hs-k-kaeshi :hs-k-sensa :hs-k-saharai                                         ;  own (§21.8):
    :hs-k-raiden :hs-k-ame :hs-k-kosa-aim :hs-k-kosa :hs-k-breaker :hs-k-hammer :hs-k-kubikake   ;  the ranged mode,
    :hs-kb-gen :hs-kb-kaeshi :hs-kb-sogen :hs-kb-hikigiri :hs-kb-makigiri :hs-kb-shibori :hs-kb-hikiyose   ;  the bind
    :hs-kb-raiden :hs-kb-kojo :hs-kb-koshu-run :hs-kb-koshu :hs-kb-unwind
    :hs-k-hosoku :hs-k-s-k2 :hs-k-s-k3 :hs-k-g-k2 :hs-k-g-j2 :hs-k-g-k3 :hs-k-g-j3   ; the ranged route links' (A2, §24.2)
    :hs-kb-stance :hs-kb-walk-f :hs-kb-walk-b :hs-kb-strafe-r :hs-kb-strafe-l))     ; the bind's stance and walk (A2)
;; (Jilliel's SPs and Kikon, decision 56, DUEL_LILLE §23.37: :lb-w-sanren is KIN's SANREN through his :clip-map, :lb-e-sanren
;; EN's own, :lb-w-kikon / :lb-w-kikon-fire the Kikon in play; :lb-w-aim and :lb-w-fire are gone)
;; (the Kikon cinematics' own clips, :ya-kikon :ya-tenchi :ke-kikon :ke-kikon-n, are played by their
;; DEFCINEs, which the host stubs; KESSA's clones play :ic-k-cut / :ic-k-wrap, ICHIGO-CLONE-STEP)
(let ((used (remove-duplicates (append (loop for cf in *forms* append (kit-clips (apply #'kit cf)))
                                        ;; (moves started outside every kit's tables: Lille II's base snipe's level 2 / 3
                                        ;;  copies, BR-S-SNIPE-RELEASE; R16, DUEL_LILLE_V3 §20: only they play :br-sk-l1)
                                        ;;  Hisagi's MODOSHI, started by his :command hook while the sickle is out)
                                        (remove nil (loop for m in '(:br-s-l1-2 :br-s-l1-3 :hs-modoshi :hs-k2s :hs-r-kubikake :hs-b-unwind :hs-r-sp2c
                                                                       :hs-b-sp1)   ; (B4c: no kit's since, its strip 83524)
                                                          collect (mv-clip-2 (find-move m))   ; (his Shikai's MODOSHI mapped)
                                                          collect (kit-move-clip (kit :hisagi :base) (mv-clip (find-move m)))))))))
  (let ((extra (set-difference used *clips-5*)) (unused (set-difference *clips-5* used)))
    (when (or extra unused) (format t "  clips not in §5: ~s, §5 clips unused: ~s~%" extra unused))
    (check (and (null extra) (null unused)))))
;; phase 2: art names, roster, form looks, the flurry, hazard hits
(check (equal (mapcar #'kit-weapon (mapcar (lambda (cf) (apply #'kit cf)) *forms*))
              '(:ryujin-jakka :ryujin-jakka :zanka :zanka :ken-katana :nozarashi :nozarashi :nozarashi :ke-broken nil
                :sode-no-shirayuki :sode-no-shirayuki :ru-rime :ru-ice :zangetsu-long :tensa
                :shigarami :shigarami :shigarami :shigarami :shigarami :shigarami :shigarami
                :diagramm nil nil nil nil :kazeshini :kazeshini :kazeshini)))     ; (+ Lille II's five forms, DUEL_LILLE_V3: MUJITTAI gone; Hisagi)
(check (equal *roster* '(:yamamoto :kenpachi :rukia :ichigo :senjumaru :lille :barro :hisagi)))   ; index 5 reserved (the old Lille, removed 2026-10-13), 6 Lille, 7 Hisagi
(check (equal (kit-intro-weapon (kit :yamamoto :base)) '(:ya-cane 81)))              ; cane until 1.35 s
(check (and (eq (kit-cine (kit :yamamoto :bankai-east)) 'yama-bankai-cine) (eq (kit-cine (kit :kenpachi :nozarashi)) 'ken-nozarashi-cine)
            (null (kit-cine (kit :yamamoto :hellfire)))))
(check (and (equal (kit-blade (kit :yamamoto :hellfire)) '(:fire 1.3)) (eq (kit-grade (kit :yamamoto :bankai-east)) :spot)
            (null (kit-blade (kit :kenpachi :base)))))
(check (and (mv-planted (find-move :ya-breaker)) (~= (mv-blend (find-move :ke-stance)) 6)))
(let ((fl (find-move :ke-flurry)))                                          ; 4 more cuts + the launcher
  (check (and (= 5 (length (mv-hits fl))) (= 60 (hw-dmg (svref (mv-hits fl) 4))) (eq :launch (hw-react (svref (mv-hits fl) 4)))
              (= (+ 25 (* 4 25) 60) (+ (mv-dmg (find-move :ke-charge)) (loop for w across (mv-hits fl) sum (hw-dmg w)))))))
(check (and (null (hw-stun (make-hitwin))) (= 40 (hw-stun (make-hitwin :stun 40)))))

;;; ================================================================ Bankai stances (docs/duel/DUEL_YAMA_REWORK.md, the user's decisions 2026-09-27)
(let ((east (kit :yamamoto :bankai-east)) (west (kit :yamamoto :bankai-west)))
  ;; the forms: East x1.0 dealt + the pierce, x*BANKAI-TAKEN* 1.5 taken, projectile-cut; U goes West (:guard-to). West
  ;; x1.0 / x1.0, the ward + the parry's scorch; every command but L / SP1 drops to East (:drop-to / :keep); both
  ;; awakened and permanent
  (check (and (~= (kit-mult east) 1.0) (~= (kit-taken east) 1.5) (~= *bankai-taken* 1.5) (null (kit-blade-chip east))
              (equal (kit-passives east) '(:projectile-cut :pierce)) (eq (kit-guard-to east) :bankai-west)
              (null (kit-drop-to east))))
  (check (and (~= (kit-mult west) 1.0) (~= (kit-taken west) 1.0) (null (kit-blade-chip west))
              (equal (kit-passives west) '(:ward :scorch)) (null (kit-guard-to west))
              (eq (kit-drop-to west) :bankai-east) (equal (kit-keep west) '(:sig :sp1))))
  (check (and (kit-awakening west) (null (kit-duration west)) (eq (kit-awaken-form (kit :yamamoto :base)) :bankai-east)
              (null (kit-guard-to (kit :yamamoto :base))) (null (kit-drop-to (kit :kenpachi :nomihose)))))
  (check (and (eq (mv-name (kit-command-move east :sp1)) :ya-kyoku) (eq (mv-name (kit-command-move west :sp1)) :ya-w-parry)
              (eq (mv-name (kit-command-move east :sig)) :ya-e-kyokko) (eq (mv-name (kit-command-move west :sig)) :ya-w-shonetsu)))
  ;; East <-> West (fighter.lisp KIT-DROP): in West J, K, O, I, Shift+L drop to East first (East's own move starts),
  ;; L and Shift+K stay West; East drops nothing
  (check (and (every (lambda (c) (eq (kit-drop west c) :bankai-east)) '(:q :f :sp2 :breaker :kikon))
              (null (kit-drop west :sig)) (null (kit-drop west :sp1))
              (notany (lambda (c) (kit-drop east c)) *kit-commands*)
              (eq (kit-command-move (find-kit :yamamoto (kit-drop west :q)) :q) (kit-command-move east :q))))
  (check (and (= (hit-damage 100 nil (kit-def-mods east) 1 nil) 150) (= (hit-damage 100 nil (kit-def-mods west) 1 nil) 100)))
  ;; the derivation rule: East's inherited moves derived (-1 f; reach x1.15, but a Breaker's stays unscaled); West takes East's versions
  (check (and (= (mv-s (kit-command-move east :breaker)) 7) (~= (mv-reach (kit-command-move east :breaker)) *breaker-reach* 0.01)
              (eq (kit-move west :ya-e-j2) (kit-move east :ya-e-j2)) (eq (kit-command-move west :q) (kit-command-move east :q))))
  (check (and (= (mv-s (kit-move east :ya-e-j1)) 8) (= (mv-s (kit-move east :ya-e-j3)) 8) (= (mv-s (kit-move west :ya-w-counter)) 6)))
  (dolist (name '(:ya-kaka :ya-tenchi))
    (let ((a (kit-move east name)) (b (kit-move west name)))
      (check (and (eq a b) (= (mv-s a) (mv-s (find-move name))) (equal (mv-on-frame a) (mv-on-frame b))))))
  (check (~= (mv-clip-speed (kit-move east :ya-e-j2)) 1.0))                   ; East's own clip at its own frames (DUEL_YAMA_TYBW §3.2)
  ;; KYOKKO cancels a landed J2 in time; a blocked J1 -> J2 leaves a gap >= Step's first iframe and < 7
  (let* ((k east) (q1 (kit-command-move k :q)) (q2 (kit-next k (mv-name q1) :q)))
    (check (< (- (mv-s (kit-command-move k :sig)) (hitstun (hw-react (svref (mv-hits q2) 0)))) 0))
    (check (and (>= (blocked-gap q1 q2) (first *step-iframes*)) (< (blocked-gap q1 q2) 7))))
  ;; the ender-gap rule: after a string ender that leaves the victim near, his Step fits before the next E-Q1
  (progn
    (check (= 5 (on-hit-adv (find-move :ya-e-j3))))
    (dolist (m (loop for (nil nil to) in (kit-strings east) collect (kit-move east to)))
      (let ((w (svref (mv-hits m) 0)))
        (when (or (member (hw-react w) '(:flinch :stagger)) (and (eq (hw-react w) :knockback) (<= (hw-kb w) 1.5)))
          (check (>= (- (mv-s (kit-command-move east :q)) (on-hit-adv m)) (first *step-iframes*)))))))
  ;; KYOKKO: S15 A3 R26, 85, a 1.6 m lunge, a 4.6 m line, pierce x2, guard 22 (an ender), cooldown 100, cancels a landed
  ;; Q / F; no armour anywhere in either stance
  (let* ((l (kit-command-move east :sig)) (w (svref (mv-hits l) 0)))
    (check (and (eq (mv-kind l) :sig) (member :cancel (mv-flags l)) (= (mv-cooldown l) 100) (~= (mv-slide l) 1.6)
                (~= (getf (mv-params l) :pierce-mult) 2.0) (= (hw-guard w) 22) (eq (hw-react w) :knockback)
                (~= (aref (first (hw-vols w)) 2) 4.6) (> (mv-cooldown l) (+ (mv-total l) *chain-lead*)))))
  ;; SHONETSU JIGOKU: S16 R24 (40 f, no hit window: the pillars do it), on-frames 0 (the tell) and 16, 45 x 2 in a 2 m
  ;; ring, guard 12, cooldown 150, not a cancel (a West Q / F would already have dropped him to East)
  (let* ((l (kit-command-move west :sig)) (pa (mv-params l)))
    (check (and (eq (mv-kind l) :sig) (zerop (length (mv-hits l))) (= (mv-total l) 40) (= (mv-cooldown l) 150)
                (not (member :cancel (mv-flags l))) (equal (mapcar #'first (mv-on-frame l)) '(0 16))
                (= (getf pa :dmg) 45) (= (getf pa :hits) 2) (~= (getf pa :size) 2.0) (= (getf pa :guard) 12)
                (= (move-end-frame (mv-s l) (mv-a l) (mv-r l) (mv-whiff l) nil t) 40))))
  (check (every (lambda (m) (zerop (mv-armor-hits (find-move m)))) '(:ya-e-kyokko :ya-w-shonetsu :ya-w-parry :ya-w-counter)))
  ;; KYOKUJITSUJIN: the blade [18,20) breaks guard (and a ward), the tip's cone [20,23) 25 deg x 9 m, 130, knockback
  ;; 4 m, blockable (never a break), -16; the blade's short knockback keeps the victim in the cone
  (let* ((m (kit-command-move east :sp1)) (bl (svref (mv-hits m) 0)) (co (svref (mv-hits m) 1)))
    (check (and (= 2 (length (mv-hits m))) (= (hw-from bl) 18) (= (hw-to bl) 20 (hw-from co)) (= (hw-to co) 23)
                (= (hw-dmg bl) 90) (= (hw-dmg co) 130) (equal (hw-flags bl) '(:guard-crush)) (equal (hw-flags co) '(:ranged))
                (eq (hw-react bl) :knockback) (~= (hw-kb bl) 0.5) (eq (hw-react co) :knockback) (~= (hw-kb co) 4.0)
                (= (mv-adv-block m) -16) (= (hw-guard co) 22)))
    (check (and (~= (aref (first (hw-vols co)) 1) 9.0) (~= (* 2 (aref (first (hw-vols co)) 2)) (deg 25))))
    (check (and (eq (resolve-contact :guard :guard-crush (member :guard-crush (hw-flags bl))) :guard-break)
                (eq (resolve-contact :guard :guard-crush (member :guard-crush (hw-flags bl)) :ward t) :guard-break)
                (eq (resolve-contact :guard :guard-crush (member :guard-crush (hw-flags co))) :blocked)))
    (flet ((hits (v x z) (vol-hit-p v 0f0 0f0 0f0 0f0 -1f0 (float x 1f0) 0f0 (float z 1f0) 0.36f0 1.65f0 0f0)))
      (check (and (hits (first (hw-vols co)) 0 -8.5) (hits (first (hw-vols co)) 2.0 -8.5) (not (hits (first (hw-vols co)) 3.0 -8.5))
                  (not (hits (first (hw-vols co)) 0 -9.6)) (hits (first (hw-vols bl)) 0 -2.0) (not (hits (first (hw-vols bl)) 0 -3.2))))))
  ;; the ward vs Kenpachi: his base J J J blocked = 24 x*WARD-MULT* 1.1 = 26.4: the 4th string crushes a full
  ;; gauge; RYOTE's K K K (the cut) 69 x 1.1 = 75.9: the 2nd
  (flet ((gv (k name) (hw-guard (svref (mv-hits (kit-move k name)) 0))))
    (let ((qs (* *ward-mult* (+ (gv (kit :kenpachi :base) :ke-j1) (gv (kit :kenpachi :base) :ke-j2) (gv (kit :kenpachi :base) :ke-j3))))
          (kk (* *ward-mult* (+ (cut-value (gv (kit :kenpachi :ryote) :ke-r-k1) :flash) (cut-value (gv (kit :kenpachi :ryote) :ke-r-k2) :flash)
                                (cut-value (gv (kit :kenpachi :ryote) :ke-r-k3) :flash)))))
      (check (and (< (* 3 qs) *gg-max*) (>= (* 4 qs) *gg-max*) (< kk *gg-max*) (>= (* 2 kk) *gg-max*)))))
  ;; GOKUI GAESHI: the parry catches a melee hit on f2-25 (24 f = its active frames; Ichigo's window, 2026-10-01), not a hazard, not an
  ;; unguardable one; a Breaker breaks it; parried = a block for the attacker (no string, no Kikon); the counter
  ;; (150, knockback) lands inside the parried attacker's stagger: guaranteed
  (let ((p (kit-command-move west :sp1)) (c (kit-next west :ya-w-parry :land)))
    (check (and (not (parry-frame-p 1)) (parry-frame-p 2) (parry-frame-p 25) (not (parry-frame-p 26))
                (= (mv-a p) (1+ (- (second *parry-window*) (first *parry-window*)))) (= (mv-s p) (first *parry-window*))
                (member :parry (mv-flags p)) (zerop (length (mv-hits p))) (= (mv-total p) 46) (= (kit-command-cost west :sp1) 1)))
    (check (and (eq (resolve-contact :parry) :parried) (eq (resolve-contact :parry :in-front nil) :parried)
                (eq (resolve-contact :parry :breaker t) :stance-break) (eq (resolve-contact :parry :hazard t) :hit)
                (eq (resolve-contact :parry :unguardable t) :hit) (eq (contact-of :parried) :block)
                (null (kikon-outcome t :parried nil))))
    (check (and (eq (mv-name c) :ya-w-counter) (= (mv-dmg c) 150) (eq (hw-react (svref (mv-hits c) 0)) :knockback)
                (< (1+ (mv-s c)) *parry-stun*) (= *parry-stun* 32) (= *scorch* 15))))
  ;; South, the bind: 20/1/34 (55 f), 2 bars and no cooldown (the user's decision 2026-09-28: the bars are its limiter); the
  ;; grab 16 f after the stab; 40 + bound 60; the follow-up window 41; unguardable (guard, stance, armour, parry
  ;; don't stop it; iframes do); it only opens a combo (else a flinch) and books 2 hits: 70 flash-step Bursts out
  (let* ((m (kit-command-move east :sp2)) (pa (mv-params m)))
    (check (and (= (mv-total m) 55) (= (kit-command-cost east :sp2) 2) (= (mv-cooldown m) 0) (member :bind (mv-flags m))
                (= (getf pa :delay) 16) (= (getf pa :dmg) 40) (= (getf pa :stun) *bind-stun* 60) (~= (getf pa :range) 10.0)
                (= 41 (- (+ (mv-s m) (getf pa :delay) (getf pa :stun)) (mv-total m)))))
    (check (and (eq (resolve-contact :guard :unguardable t) :hit) (eq (resolve-contact :stance :unguardable t) :hit)
                (eq (resolve-contact :armor :unguardable t) :hit) (eq (resolve-contact :parry :unguardable t :hazard t) :hit)
                (null (resolve-contact :invuln :unguardable t))))
    (check (equal (multiple-value-list (combo-step :bind nil 0 0 0)) '(:bind 2 0 0)))       ; the opener: 2 hits
    (check (equal (multiple-value-list (combo-step :bind nil 1 0 0)) '(:flinch 2 0 0)))     ; in a combo: a flinch
    (check (and (burst-allowed-p (burst-mode :stun nil (nth-value 1 (combo-step :bind nil 0 0 0)) nil) *fs-burst* nil)
                (not (burst-allowed-p (burst-mode :stun nil (nth-value 1 (combo-step :bind nil 0 0 0)) nil) (1- *fs-burst*) nil))))
    (check (equal (multiple-value-list (combo-step :flinch nil 2 0 0)) '(:flinch 3 0 0)))   ; the follow-up is hit 3
    ;; the escapes: a Step pressed from the stab's f16 carries him past the grab disc; one pressed f28-33 has
    ;; its iframes over the grab (f36-37); a Hoho pressed f23-35 too; walking doesn't (16 f of walk < the disc)
    (let ((grab (+ (mv-s m) (getf pa :delay))) (r (+ (getf pa :radius) 0.45)))
      (check (and (= grab 36) (> *step-distance* r) (< (* *walk-kenpachi* (/ (getf pa :delay) 60.0)) r)
                  (<= (+ 33 (first *step-iframes*)) grab) (>= (+ 28 (second *step-iframes*)) (1+ grab))
                  (<= (+ 35 (first *hoho-iframes*)) grab) (>= (+ 23 (second *hoho-iframes*)) (1+ grab)))))
    (multiple-value-bind (x z) (cast-point 0.0 0.0 12.0 0.0 10.0) (check (and (~= x 10.0) (~= z 0.0))))
    (multiple-value-bind (x z) (cast-point 0.0 0.0 3.0 4.0 10.0) (check (and (~= x 3.0) (~= z 4.0))))))

;;; ================================================================ Nozarashi v2: NOME, the three-cup ladder (§2.13)
(let* ((t1 (kit :kenpachi :nozarashi)) (t2 (kit :kenpachi :ryote)) (t3 (kit :kenpachi :nomihose))
       (m (kit-meter t1)) (ladder (getf m :ladder)) (gains (kit-meter-gain t1)))
  ;; 1. nome-gain: three sources only
  (check (and (~= (nome-gain 125 0 0 gains) 10.0) (~= (nome-gain 0 200 0 gains) 24.0) (~= (nome-gain 0 0 62 gains) 18.6)
              (~= (nome-gain 0 18 17 gains) (+ 2.16 5.1))))
  ;; 2. meter-drain: cup 1 never, cup 2 3/s after 180 idle frames (the user 2026-09-29: x2 of guard v3's 1.5), cup 3
  ;; 20/s from the first frame (a gain doesn't pause it)
  (flet ((dr (i nome idle) (let ((r (nth i ladder))) (meter-drain nome (second r) (third r) idle))))
    (check (and (~= (dr 0 30.0 999) 30.0) (~= (dr 1 50.0 179) 50.0) (~= (dr 1 50.0 180) 49.95) (~= (dr 2 90.0 0) (- 90.0 (/ 20.0 60)))
                (~= (dr 2 0.05 0) 0.0))))
  ;; 3. ladder-rung: hysteresis, several steps at once
  (check (and (= 0 (ladder-rung 39.9 0 ladder)) (= 1 (ladder-rung 40.0 0 ladder)) (= 1 (ladder-rung 25.0 1 ladder))
              (= 0 (ladder-rung 24.9 1 ladder)) (= 2 (ladder-rung 100.0 1 ladder)) (= 2 (ladder-rung 100.0 0 ladder))
              (= 2 (ladder-rung 50.0 2 ladder)) (= 1 (ladder-rung 49.9 2 ladder)) (= 0 (ladder-rung 0.0 2 ladder))))
  (check (equal (mapcar #'first ladder) '(:nozarashi :ryote :nomihose)))
  (check (and (~= (getf m :start) 10.0) (~= (getf m :max) 100.0)))
  ;; 4. drink-split: the taken half rounded up (real damage: at 1 Reishi a drink of 1 Soul Breaks)
  (check (and (equal (multiple-value-list (drink-split 35)) '(18 17)) (equal (multiple-value-list (drink-split 1)) '(1 0))
              (soul-break-p (- 1 (drink-split 1)))))
  ;; 5. drink as a guard: the guard's triangle (Breaker -> Guard Break, unguardable / behind -> hit), drink-adv
  (check (and (eq (resolve-contact :guard :breaker t) :guard-break) (eq (resolve-contact :guard :unguardable t) :hit)
              (eq (resolve-contact :guard :in-front nil) :hit) (= (drink-adv -2) -6) (= (drink-adv -12) -16)))
  (check (and (member :drink (kit-passives t3)) (not (member :drink (kit-passives t2))) (not (member :drink (kit-passives t1)))))
  ;; 6. the cut: Flash / Signature / SP x1.5 (RYOTE, NOMIHOSE), the J string untouched: blocked RYOTE J J J = 24,
  ;; K K K = 69 (into West's ward too: x*WARD-MULT*)
  (flet ((gv (k name) (hw-guard (svref (mv-hits (kit-move k name)) 0))))
    (check (and (= (cut-value 8 :quick) 8) (= (cut-value 14 :flash) 21) (= (cut-value 22 :sp) 33) (= (cut-value 12 nil) 12)))
    (check (= 24 (+ (cut-value (gv t2 :ke-r-j1) :quick) (cut-value (gv t2 :ke-r-j2) :quick) (cut-value (gv t2 :ke-r-j3) :quick))))
    (check (= 69 (+ (cut-value (gv t2 :ke-r-k1) :flash) (cut-value (gv t2 :ke-r-k2) :flash) (cut-value (gv t2 :ke-r-k3) :flash)))))
  ;; the ranged hits (guard v3): the Meteor, the cash-out, Buttagiru's crack, the heat cone, Taimatsu, Nadegiri are
  ;; :ranged; the blades (the J / K strings, the Kikon strikes, KYOKUJITSUJIN's guard-breaking blade) are not
  (flet ((rw (name i) (member :ranged (hw-flags (svref (mv-hits (find-move name)) i)))))
    (check (and (rw :ke-meteor 0) (rw :ke-meteor-n 0) (rw :ke-buttagiru 0) (rw :ya-kyoku 1) (rw :ya-taimatsu 0) (rw :ya-nadegiri 0)
                (not (rw :ya-kyoku 0)) (not (rw :ke-r-k1 0)) (not (rw :ke-kikon-n 0)) (not (rw :ya-kikon 0)) (not (rw :ke-n-f1 0)))))
  (check (and (member :cut (kit-passives t2)) (member :cut (kit-passives t3)) (not (member :cut (kit-passives t1)))))
  ;; 7. the Kikon count per cup (read at rush start) with the per-event cap
  (check (and (= 2 (kit-kikon-konpaku t1)) (= 3 (kit-kikon-konpaku t2)) (= 4 (kit-kikon-konpaku t3))
              (= 2 (kit-kikon-konpaku (kit :kenpachi :base))) (= 3 (kit-kikon-konpaku (kit :yamamoto :bankai-east)))
              (= 2 (kit-kikon-konpaku (kit :yamamoto :hellfire)))))
  (check (and (= 2 (nth-value 1 (kikon-result 9 2 nil))) (= 3 (nth-value 1 (kikon-result 9 2 t)))
              (= 3 (nth-value 1 (kikon-result 9 3 nil))) (= 4 (nth-value 1 (kikon-result 9 3 t)))
              (= 4 (nth-value 1 (kikon-result 9 4 nil))) (= 5 (nth-value 1 (kikon-result 9 4 t)))))   ; Kikon cap 4, Soul Break 5
  ;; the Soul Break rule (the user's decision 2026-09-27): the attacker's current count + 1, capped at 5 (a Kikon at 4);
  ;; NOMIHOSE's Soul Break = 5; the cinematic is the attacker's current form's Kikon cinematic
  (check (and (= 4 (nth-value 1 (kikon-result 9 5 nil))) (= 5 (nth-value 1 (kikon-result 9 5 t)))
              (= 5 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku t3) t))) (= 3 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku t1) t)))
              (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku t2) t))) (= 2 (nth-value 1 (kikon-result 2 (kit-kikon-konpaku t3) t)))
              (= 5 *soul-break-max-event*) (= 4 *kikon-max-event*)))
  (check (and (eq 'ken-kikon-cine (kit-kikon-cine (kit :kenpachi :base))) (eq 'ken-sky-split-cine (kit-kikon-cine t1))
              (eq 'ken-sky-split-cine (kit-kikon-cine t2)) (eq 'ken-sky-split-cine (kit-kikon-cine t3))
              (eq 'yama-kikon-cine (kit-kikon-cine (kit :yamamoto :base))) (eq 'yama-kikon-cine (kit-kikon-cine (kit :yamamoto :hellfire)))
              (eq 'yama-tenchi-cine (kit-kikon-cine (kit :yamamoto :bankai-east)))
              (eq 'yama-tenchi-cine (kit-kikon-cine (kit :yamamoto :bankai-west)))))
  ;; 8. register-kit: NOMIHOSE plays RYOTE's moves (not re-derived); RYOTE's meteor / LEAP as written; Hellfire unchanged
  (check (and (eq (kit-move t3 :ke-r-j3) (kit-move t2 :ke-r-j3)) (= 10 (mv-s (kit-move t3 :ke-r-j3)))
              (= 21 (mv-s (kit-move t3 :ke-r-k3))) (eq (kit-move t3 :ke-r-j2) (kit-move t2 :ke-r-j2))
              (~= (mv-reach (kit-move t2 :ke-r-j2)) 1.44) (~= (mv-reach (kit-move t2 :ke-r-j3)) 1.52)))
  (check (and (eq (kit-move t2 :ke-meteor) (find-move :ke-meteor)) (eq (kit-move t2 :ke-kikon-n) (find-move :ke-kikon-n))
              (eq (kit-command-move t3 :kikon) (find-move :ke-kikon-n))
              (eq (kit-move (kit :yamamoto :hellfire) :ya-j1) (find-move :ya-j1))))
  (check (and (= 10 (mv-s (kit-move t1 :ke-stance))) (= 11 (mv-s (kit-move t2 :ke-stance))) (= 11 (mv-s (kit-move t3 :ke-stance)))))
  ;; 9. the links: every J / K pair of every form combos (the string budget above); cup 3's K1 KUKAN-GIRI -> K2 too
  (check (< (hit-gap (kit-move t3 :ke-n-f1) (kit-next t3 :ke-n-f1 :f)) 0))
  ;; 10. the rift: at f20, cuts f40 (a 2 f window), 50 x1.2, guard 12, chip 20 %; on block inside N-F1's blockstun
  ;; (he acts at f43, the rift's 14 f blockstun frees the defender at f55: +8)
  (let* ((n (kit-move t3 :ke-n-f1)) (pa (mv-params n)) (bs (blockstun (mv-total n) (mv-s n) (mv-adv-block n))))
    (check (and (equal (mv-on-frame n) '((20 ken-rift))) (= 40 (+ 20 *rift-delay*)) (= 50 (getf pa :rift-dmg))
                (= 12 (getf pa :rift-guard)) (~= 0.2 (getf pa :rift-chip))
                (< (+ 20 *rift-delay*) (+ (mv-s n) bs))                         ; the rift cuts inside the blockstun
                (= 8 (- (+ 20 *rift-delay* *hazard-blockstun* 1) (1+ (mv-total n)))))))
  ;; 11. the cash-out: NOME 0 and cup 1 on its first frame, 390, the guard break only within 6 m
  (let ((c (kit-command-move t3 :sp1)))
    (check (and (eq (mv-name c) :ke-meteor-n) (= 390 (mv-dmg c)) (equal (first (mv-on-frame c)) '(0 ken-drink-dry))
                (~= 6.0 (getf (mv-params c) :crush-range)) (= -16 (mv-adv-block c)) (= 22 (hw-guard (svref (mv-hits c) 0)))
                (= 390 (hit-damage 390 (kit-atk-mods t1 0) nil 1 nil)))))
  ;; the looks: one hand in cup 1, two hands in cups 2 / 3 (cup 3 its own low stance and drink since DUEL_KEN_REWORK §6.2;
  ;; the Bankai keeps the old drink); the HUD names
  (check (and (eq (kit-stance t1) :ke-n-stance) (eq (kit-stance t2) :ke-r-stance) (eq (kit-stance t3) :ke-x-stance)
              (equal (mapcar #'kit-form-name (list t1 t2 t3)) '("KATATE" "RYOTE" "NOMIHOSE"))
              (eq (kit-aura t3) :nomihose) (eq (kit-drink-clip t3) :ke-x-drink) (eq (kit-drink-clip (kit :kenpachi :bankai)) :ke-drink)
              (equal (kit-respect-callout t2) "OMOSHIREE!")))
  ;; AI keys: the Kikon chance by cup, the cash-out rule (the near cash-out below 55 since the 2x drain: DUEL_NOZARASHI_V2.md,
  ;; "The CPU after the faster drain")
  (check (and (~= 0.25 (getf (kit-ai t1) :kikon-p)) (~= 0.5 (getf (kit-ai t2) :kikon-p)) (~= 0.9 (getf (kit-ai t3) :kikon-p))
              (equal (getf (kit-ai t3) :cashout) '(:punish 30 :near 6.0 :below 55.0)) (null (getf (kit-ai t2) :cashout)))))

;;; ================================================================ Kenpachi's Bankai and 片腕 (docs/duel/DUEL_KEN_BANKAI.md, the user's decisions 2026-09-28)
(let ((b (kit :kenpachi :bankai)) (a (kit :kenpachi :kataude)) (t3 (kit :kenpachi :nomihose)))
  ;; 1. entry: P, free and red; only cup 3 has it (once a match: nothing after it does)
  ;; the entry (2026-09-28): free with <= 4 of his own Konpaku (no longer red)
  (check (and (= *bankai-konpaku* 4) (bankai-allowed-p t 4) (bankai-allowed-p t 1) (not (bankai-allowed-p nil 4))
              (not (bankai-allowed-p t 5)) (not (bankai-allowed-p t 9))))
  (check (equal (loop for cf in *forms* when (kit-bankai-form (apply #'kit cf)) collect cf)
              '((:kenpachi :nomihose))))   ; (Lille's revival gone: his owl is the burst's, DUEL_LILLE_V3 R1)
  (check (and (eq (kit-bankai-form t3) :bankai) (eq (kit-cine b) 'ken-bankai-cine) (kit-awakening b) (kit-awakening a)))
  ;; 2. the arm: 4 pips; spend 4 -> 3, 0 refused; the crack at 300 f, idle back to 0; locked frames don't count;
  ;; 4 cracks = 1200 f of play
  (check (and (equal (multiple-value-list (pip-spend 4)) '(3 t)) (equal (multiple-value-list (pip-spend 0)) '(0 nil))
              (= 4 *arm-pips*) (= 300 *arm-crack*)))
  (check (and (equal (multiple-value-list (pip-step 4 298 nil)) '(4 299 nil)) (equal (multiple-value-list (pip-step 4 299 nil)) '(3 0 t))
              (equal (multiple-value-list (pip-step 4 299 t)) '(4 299 nil)) (equal (multiple-value-list (pip-step 0 5 nil)) '(0 6 nil))))
  (check (= 1200 (let ((p 4) (i 0) (n 0)) (loop while (plusp p) do (multiple-value-setq (p i) (pip-step p i nil)) (incf n)) n)))
  ;; 3. the pending burst: waits in the move that spent the last pip, in reactions / blockstun / air / down / Hoho, fires
  ;; on anything else (a later move included)
  (let ((m1 (kit-move b :ke-b-k1)) (m2 (kit-move b :ke-b-j1)))
    (check (and (not (burst-due-p m1 m1 :move)) (burst-due-p m1 m2 :move) (burst-due-p m1 nil :idle) (burst-due-p :none nil :guard)
                (not (burst-due-p m1 nil :stun)) (not (burst-due-p m1 nil :hoho)) (not (burst-due-p m1 nil :air))
                (not (burst-due-p m1 nil :guard-hit)) (not (burst-due-p nil nil :idle)) (burst-due-p :none m2 :move))))
  ;; 4. rend: armour -> a hit, a stance -> broken; a guard, the ward and a parry still hold
  (check (and (eq (resolve-contact :armor :rend t) :hit) (eq (resolve-contact :stance :rend t) :stance-break)
              (eq (resolve-contact :stance-in :rend t) :stance-break) (eq (resolve-contact :guard :rend t) :blocked)
              (eq (resolve-contact :guard :rend t :ward t :in-front nil) :blocked) (eq (resolve-contact :parry :rend t) :parried)
              (eq (resolve-contact :armor) :armored)))
  ;; the bite beats every defence but iframes; +9 on hit (his J1, S 8, combos after it)
  (let* ((bite (kit-command-move b :sig)) (w (svref (mv-hits bite) 0)))
    (check (and (eq (mv-name bite) :ke-b-bite) (member :grab (mv-flags bite)) (member :unguardable (hw-flags w))
                (~= 1.5 (mv-reach bite)) (eq :crumple (hw-react w))))
    (check (every (lambda (st) (eq :hit (resolve-contact st :unguardable t :rend t))) '(:guard :stance :stance-in :armor :parry)))
    (check (and (null (resolve-contact :invuln :unguardable t)) (eq :hit (resolve-contact :guard :unguardable t :ward t))))
    (check (= 9 (on-hit-adv bite))) (check (> (on-hit-adv bite) (mv-s (kit-command-move b :q)))))
  ;; the pip commands: K, L, SP1, SP2, I, O (and every latched K link: the latch reads :f); J, Step, Hoho, Burst, U, P don't
  (check (and (equal (getf (kit-pips b) :cmds) '(:f :sig :sp1 :sp2 :breaker :kikon)) (eq :kataude (getf (kit-pips b) :to))
              (kit-pip-cmd-p b :f) (kit-pip-cmd-p b :kikon) (not (kit-pip-cmd-p b :q)) (not (kit-pip-cmd-p b :awaken))
              (null (kit-pips a)) (null (kit-pips t3))))
  ;; 7. the Kikon counts: Bankai 4, 片腕 3 (the universal awakened count); their Soul Breaks 5 / 4 (the cap 5); the
  ;; Soul Break cinematic is the form's Kikon cinematic
  (check (and (= 4 (kit-kikon-konpaku b)) (= 3 (kit-kikon-konpaku a))
              (= 5 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku b) t))) (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku a) t)))
              (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku b) nil)))))
  (check (and (eq 'ken-oni-kikon-cine (kit-kikon-cine b)) (eq 'ken-kikon-cine (kit-kikon-cine a))
              (equal "MAPPUTATSU" (mv-callout (kit-command-move b :kikon))) (eq :ke-kikon (mv-name (kit-command-move a :kikon)))))
  ;; 8. B1 / B4: no NOME in the Bankai (no :meter-gain, no :ladder, the pips' meter), no cut; x1.2; U still DRINK
  (check (and (null (kit-meter-gain b)) (null (getf (kit-meter b) :ladder)) (= 4 (getf (kit-meter b) :max)) (= 4 (getf (kit-meter b) :start))
              (not (member :cut (kit-passives b))) (member :drink (kit-passives b)) (~= 1.2 (kit-mult b))
              (null (kit-meter-gain a)) (null (kit-meter a)) (not (member :drink (kit-passives a))) (~= 1.0 (kit-mult a))))
  ;; the K links: guard 28 / 28 / 36 (x2 of a K), rend; TATE-GOTO guard-crushes its whole line; SP2's :land is the punch
  (flet ((g (name) (hw-guard (svref (mv-hits (kit-move b name)) 0))))
    (check (and (= 28 (g :ke-b-k1)) (= 28 (g :ke-b-k2)) (= 28 (g :ke-b-k2s)) (= 36 (g :ke-b-k3))
                (every (lambda (n) (member :rend (hw-flags (svref (mv-hits (kit-move b n)) 0)))) '(:ke-b-k1 :ke-b-k2 :ke-b-k3 :ke-b-punch)))))
  (let ((sp (kit-command-move b :sp1)))
    (check (and (eq (mv-name sp) :ke-b-split) (member :guard-crush (hw-flags (svref (mv-hits sp) 0))) (~= 6.0 (mv-reach sp))
                (eq :ke-b-punch (mv-name (kit-next b :ke-charge :land))) (eq :ke-flurry (mv-name (kit-next a :ke-charge :land)))
                (= 2 (kit-command-cost b :sp2)) (= 1 (kit-command-cost b :sp1)))))
  ;; one pip per J / K string (the playtest decision 2026-09-28): owed from its first K link or its O ender, charged once
  ;; he is out of the string (a whiff, a hit on him, the end, an SP / L cancel); JJJ owes none
  (check (and (not (string-pip-due-p t :move :quick)) (not (string-pip-due-p t :move :flash)) (not (string-pip-due-p t :move :kikon))
              (string-pip-due-p t :idle nil) (string-pip-due-p t :stun nil) (string-pip-due-p t :guard-hit nil)
              (string-pip-due-p t :move :sp) (string-pip-due-p t :move :sig) (not (string-pip-due-p nil :idle nil))))
  ;; the last pip's move comes out in full (the user's report 2026-09-28: the burst cut it): the pending burst follows
  ;; the move's chain (a latched link, SP2's punch started by its hook, the O ender after a link 3: MOVE-FOLLOWS-P) and
  ;; fires only once he is out of it; a new move of his own (J1 after the bite) is cut as before
  (let* ((charge (kit-move b :ke-charge)) (punch (kit-next b :ke-charge :land)) (k1 (kit-move b :ke-b-k1))
         (k2 (kit-next b :ke-b-k1 :f)) (k3 (kit-next b :ke-b-k2 :f)) (o (kit-command-move b :kikon))
         (bite (kit-command-move b :sig)) (j1 (kit-command-move b :q)) (split (kit-command-move b :sp1)))
    (check (and (move-follows-p b charge punch) (move-follows-p b k1 k2) (move-follows-p b k3 o) (move-follows-p b k1 (kit-next b :ke-b-k1 :q))
                (not (move-follows-p b bite j1)) (not (move-follows-p b split j1)) (not (move-follows-p b k1 o))))
    (flet ((burst-frame (pending frames)             ; ARM-STEP's rule over (state move) frames: the frame the burst fires
             (loop for (st m) in frames for i from 0
                   do (when (and (typep pending 'move) m (not (eq m pending)) (move-follows-p b pending m)) (setf pending m))
                   when (burst-due-p pending m st) return i)))
      (check (and (= 3 (burst-frame bite `((:move ,bite) (:move ,bite) (:move ,bite) (:idle nil))))          ; L
                  (= 3 (burst-frame split `((:move ,split) (:move ,split) (:move ,split) (:idle nil))))   ; SP1
                  (= 4 (burst-frame charge `((:move ,charge) (:move ,punch) (:move ,punch) (:move ,punch) (:idle nil))))   ; SP2
                  (= 4 (burst-frame k2 `((:move ,k2) (:move ,k3) (:move ,o) (:stun nil) (:idle nil))))   ; a string + O
                  (= 2 (burst-frame bite `((:move ,bite) (:guard-hit nil) (:move ,j1))))))))   ; a new move is cut
  ;; route damage on hit (x1.2, before Cornered; each hit rounded): KKK 444 (1 pip), JJK 272 (1)
  (flet ((route-dmg (first presses)
           (loop for n in (route b first presses) for i from 1
                 sum (hit-damage (mv-dmg (kit-move b n)) (kit-atk-mods b 0) nil i nil))))
    (check (and (= 444 (route-dmg :f '((:f) (:f)))) (= 272 (route-dmg :q '((:q) (:f)))))))
  ;; 6. 片腕: the sword moves at reach x0.7 (J1 0.73 -> the J floor 1.4, K1 1.96, K3 1.89), the kick, the Breaker and O as written; B2:
  ;; every form's Breaker strike out-reaches its trigger, every Kikon strike *KIKON-TRIGGER* + 0.3
  (check (and (~= *j-reach-min* (mv-reach (kit-move a :ke-j1))) (~= 1.96 (mv-reach (kit-move a :ke-k1))) (~= 1.89 (mv-reach (kit-move a :ke-k3)))
              (~= *j-reach-min* (mv-reach (kit-next a :ke-j2 :q))) (~= *breaker-reach* (mv-reach (kit-command-move a :breaker)))
              (~= 2.4 (mv-reach (kit-command-move a :kikon))) (= 7 (mv-s (kit-move a :ke-j1)))))
  (dolist (cf *forms*)
    (let ((k (apply #'kit cf)))
      (let ((br (kit-command-move k :breaker)))        ; (Rukia's rooted zero has none)
        (check (or (null br) (> (+ (mv-reach br) 0.34) *breaker-trigger*))))   ; (with the thinnest hurt radius)
      (check (> (mv-reach (kit-command-move k :kikon)) (+ *kikon-trigger* 0.3)))))
  ;; the looks: the oni body in both, the aura only in the Bankai, the cracks hidden in 片腕, the wreck hidden in the Bankai
  (check (and (eq :kenpachi-oni (kit-body b)) (eq :kenpachi-oni (kit-body a)) (eq :oni (kit-aura b)) (null (kit-aura a))
              (member :arm-wreck (kit-hide b)) (not (member :arm-wreck (kit-hide a))) (member :crack-4 (kit-hide a))
              (equal (kit-form-name b) "BANKAI") (equal (kit-form-name a) "KATAUDE")))
  ;; AI keys: the entry rule on cup 3, the Bankai's K links / hurry / the opponent's wait
  (check (and (equal (getf (kit-ai t3) :bankai) '(:p 0.9 :opp-below 0.6 :opp-konpaku 4 :own-konpaku 4))
              (~= 0.6 (getf (kit-ai b) :string-k)) (= 90 (getf (kit-ai b) :pip-hurry))
              (equal (getf (kit-ai b) :opp-intent) '(:zone 2 :defend 2)) (null (getf (kit-ai b) :cashout)))))

;;; ================================================================ Kuchiki Rukia (docs/duel/DUEL_RUKIA.md)
(let ((b (kit :rukia :base)) (m18 (kit :rukia :m18)) (m50 (kit :rukia :m50)) (z (kit :rukia :zero)))
  ;; frost: max, not a sum; capped; x0.7 on walk / run only while it lasts
  (check (and (= 90 (frost-next 60 90)) (= 90 (frost-next 90 60)) (= *frost-cap* (frost-next 140 400)) (= 150 *frost-cap*)
              (~= (frost-speed 3.8 1) (* 3.8 *frost-slow*)) (~= (frost-speed 3.8 0) 3.8) (~= *frost-slow* 0.7)))
  ;; the cold gauge (two stacked bars, the user's decision 2026-09-28): guarding cools *RU-COOL-RATE*/s, not guarding warms
  ;; at the band's rate, clamped 0 .. 200
  (check (and (~= 200.0 *cold-max*) (~= 100.0 *cold-bar*) (~= 1.5 (temp-next 0.0 t 10.0)) (~= 200.0 (temp-next 199.5 t 10.0))
              (~= 0.0 (temp-next 0.1 nil 10.0)) (~= (- 150.0 (/ 12.0 60)) (temp-next 150.0 nil 12.0))))
  ;; the bands with hysteresis by bars: -18 -> -50 at 100, back at 0; -50 -> zero at 200, back at 100; several at once
  (check (and (eq :m18 (temp-band 99.9 :m18)) (eq :m50 (temp-band 100.0 :m18)) (eq :m50 (temp-band 0.5 :m50))
              (eq :m18 (temp-band 0.0 :m50)) (eq :m50 (temp-band 199.0 :m50)) (eq :zero (temp-band 200.0 :m50))
              (eq :zero (temp-band 100.5 :zero)) (eq :m50 (temp-band 100.0 :zero)) (eq :m18 (temp-band 0.0 :zero))
              (eq :zero (temp-band 200.0 :m18)) (eq :m50 (temp-band 150.0 :m50))))
  ;; the pacing (§1): guarding from -18 reaches zero in 134 f (2.2 s; the user's decision 2026-09-28: cool faster); a bar
  ;; of -50 warms out in ~8 s, one of
  ;; -18 in 10 s; zero's top bar in 20 s unbraced (the user's decision 2026-09-28: zero warms slowest, easier to hold)
  (flet ((walk (c band guarding warm)
           (loop for n from 1 to 2000 do (setf c (temp-next c guarding warm))
                 when (not (eq band (temp-band c band))) return n)))
    (check (and (= 67 (walk 0.0 :m18 t 0.0)) (= 67 (walk 100.0 :m50 t 0.0)) (= 67 (temp-cool-frames 0.0))
                (<= 1190 (walk 200.0 :zero nil (kit-warm z)) 1210) (<= 480 (walk 100.0 :m50 nil (kit-warm m50)) 520)
                (= 67 (temp-cool-frames 100.0)) (= 40 (temp-cool-frames 140.0)))))
  ;; the kit side: a :temp meter of 200 in every band, warming 10 / 12 / 5 (zero the slowest), reset to -18
  (check (and (eq (kit-awaken-form b) :m18) (every (lambda (k) (and (getf (kit-meter k) :temp) (~= 200.0 (getf (kit-meter k) :max)))) (list m18 m50 z))
              (> (kit-warm m50) (kit-warm m18) (kit-warm z)) (null (kit-meter b))
              (every (lambda (k) (eq (kit-reset-form k) :m18)) (list m18 m50 z)) (null (kit-reset-form b))
              (null (kit-duration z)) (kit-rooted z) (notany #'kit-rooted (list b m18 m50)) (eq 'rukia-crack (kit-crush-hook z))
              (null (kit-crush-hook m50)) (null (kit-drop-to z))))
  ;; spending (§3, rescaled): at -18 only L (refused below its cost); at -50 / zero everything; zero's L and SPs cash the
  ;; whole top bar (100: always back to -50); J / K cost the same whatever the link
  (check (and (equal (kit-cold m18) '(:sig 25)) (= 0 (getf (kit-cold m18) :q 0)) (= 0 (getf (kit-cold m18) :step 0))
              (every (lambda (c) (plusp (getf (kit-cold m50) c 0))) '(:q :f :sig :sp1 :sp2 :kikon :breaker :step))
              (= 0 (getf (kit-cold m50) :hoho 0)) (eq 'rukia-hoho-cold (kit-hook m50 :hoho)) (eq 'rukia-hoho-cold (kit-hook m18 :hoho))   ; a Hoho adds cold
              (eq :zero (temp-band (min *cold-max* (+ 150.0 *ru-hoho-cold*)) :m50)) (eq :m50 (temp-band (+ 60.0 *ru-hoho-cold*) :m18))
              (every (lambda (c) (>= (getf (kit-cold z) c 0) *cold-bar*)) '(:sig :sp1 :sp2))
              (< (getf (kit-cold m18) :sig) (getf (kit-cold m50) :sig) (getf (kit-cold z) :sig))
              (< (* 3 (getf (kit-cold z) :q)) *cold-bar*) (< (* 2 (getf (kit-cold z) :f)) *cold-bar*)))   ; zero's JJJ, KK fit its bar
  ;; the field (§4.1): only the away part of a walk is scaled; a side Step untouched, a back Step x :step; the floor
  (multiple-value-bind (vx vz) (field-velocity 2.0 0.0 1.0 0.0 0.55) (check (and (~= vx 1.1) (~= vz 0.0))))   ; straight away
  (multiple-value-bind (vx vz) (field-velocity -2.0 1.0 1.0 0.0 0.55) (check (and (~= vx -2.0) (~= vz 1.0))))  ; toward / strafe
  (multiple-value-bind (vx vz) (field-velocity 0.0 3.0 1.0 0.0 0.55) (check (and (~= vx 0.0) (~= vz 3.0))))   ; circling
  (check (and (~= 2.5 (field-step 2.5 0.0 0.75)) (~= (* 2.5 0.75) (field-step 2.5 -1.0 0.75)) (~= 2.5 (field-step 2.5 1.0 0.75))
              (< (* 2.5 0.75) (field-step 2.5 -0.5 0.75) 2.5)
              (~= (field-k 0.55 t) (/ *field-floor* *frost-slow*)) (~= (field-k 0.85 t) 0.85) (~= (field-k 0.55 nil) 0.55)
              (>= (* *frost-slow* (field-k 0.55 t)) (- *field-floor* 1e-4))))
  (check (and (< (getf (kit-field m18) :r) (getf (kit-field m50) :r) (getf (kit-field z) :r))
              (> (getf (kit-field m18) :away) (getf (kit-field m50) :away) (getf (kit-field z) :away))
              (null (kit-field b)) (~= (getf (kit-field z) :r) (getf (mv-params (kit-command-move z :sig)) :radius))))
  ;; colder is never weaker (the playtest fix, §4): damage x, frost on every hit, J / K reach, the L family (radius, damage),
  ;; SP1 / SP2 / O reach and damage grow band by band; -50 and zero take less
  (flet ((up (fn) (let ((v (mapcar fn (list m18 m50 z)))) (and (< (first v) (second v)) (< (second v) (third v)))))
         (sig (k key) (getf (mv-params (kit-command-move k :sig)) key)))
    (check (and (up #'kit-mult) (up #'kit-frost-touch) (up (lambda (k) (mv-reach (kit-command-move k :q))))
                (up (lambda (k) (mv-reach (kit-command-move k :f)))) (up (lambda (k) (sig k :radius))) (up (lambda (k) (sig k :dmg)))
                (up (lambda (k) (mv-reach (kit-command-move k :sp2)))) (up (lambda (k) (mv-dmg (kit-command-move k :sp2))))
                (up (lambda (k) (mv-reach (kit-command-move k :kikon))))
                (up (lambda (k) (getf (mv-params (kit-command-move k :sp1)) :dmg)))
                (> (kit-taken m18) (kit-taken m50) (kit-taken z))
                (~= 1.44 (mv-reach (kit-move m18 :ru-j1))) (~= 1.584 (mv-reach (kit-move m50 :ru-j1))) (~= 1.944 (mv-reach (kit-move z :ru-j1)))
                (~= 3.78 (mv-reach (kit-command-move z :f))) (~= 2.106 (mv-reach (kit-move z :ru-j3))) (~= 1.72 (mv-reach (kit-move m50 :ru-j3-50)))
                (~= 5.0 (mv-reach (kit-command-move m18 :sp2))) (~= 7.5 (mv-reach (kit-command-move z :sp2))))))
  ;; rooted zero: at zero no chase, so each follow-up link must still reach after a blocked link's push from where a J1
  ;; lands (the Shikai J1's reach): J2 >= J1 - *BLOCK-PUSHBACK* (the x1.35 reach covers the 0.6 m push)
  (let ((j1 (mv-reach (kit-move m18 :ru-j1))))
    (check (and (>= (+ (mv-reach (kit-move z :ru-z-j2)) 0.45) (+ j1 *block-pushback*))
                (>= (+ (mv-reach (kit-move z :ru-k2)) 0.45) (+ j1 *block-pushback*)))))
  ;; the moves each band has: L SHIMOBASHIRA / HYOSHIN / REIDO (no cooldown: the gauge is the limiter, no COOLDOWN row);
  ;; SP1 HAKUREN in every band (-50 faster stabs, zero no hold); no Breaker at zero; HAKKA in every band
  (check (and (eq :ru-shimobashira (mv-name (kit-command-move m18 :sig))) (eq :ru-hyoshin (mv-name (kit-command-move m50 :sig)))
              (eq :ru-reido (mv-name (kit-command-move z :sig))) (notany (lambda (k) (plusp (mv-cooldown (kit-command-move k :sig)))) (list m18 m50 z))
              (eq :ru-hakuren (mv-name (kit-command-move m18 :sp1))) (equal '(12 48) (mv-hold (kit-command-move m50 :sp1)))
              (null (mv-hold (kit-command-move z :sp1))) (null (kit-command-move z :breaker)) (kit-command-move m50 :breaker)
              (every (lambda (k) (eq 'ru-hakka-cine (mv-cine (kit-command-move k :kikon)))) (list m18 m50 z))
              (every (lambda (k) (null (kit-command-move k :step))) (list m18 m50 z))
              (eq (mv-name (kit-command-move m18 :f)) :ru-a-k1) (eq (mv-name (kit-next m18 :ru-k2 :f)) :ru-a-k3)
              (eq (mv-name (kit-next m50 :ru-j2 :q)) :ru-j3-50) (eq (mv-name (kit-next z :ru-j1 :q)) :ru-z-j2)
              (eq (mv-name (kit-next z :ru-k2 :f)) :ru-z-k3) (= 2 (kit-command-cost m18 :sp2)) (= 1 (kit-command-cost b :sp2))))
  ;; the passives: every band no chip; zero the ward, optic, freeze-touch
  (check (and (equal (kit-passives m18) '(:chipless)) (equal (kit-passives m50) '(:chipless))
              (equal (kit-passives z) '(:ward :freeze-touch :chipless)) (null (kit-passives b)) (= 0 (kit-frost-touch b))
              (~= *rukia-mult* (kit-mult b)) (~= *rukia-taken* (kit-taken b))))
  ;; optic: a ranged hit on the zero ward lands as on an open defender (the defender state :neutral), a melee one is blocked
  (check (and (optic-p t t t) (not (optic-p t t nil)) (not (optic-p nil t t)) (not (optic-p t nil t))
              (eq (resolve-contact (if (optic-p t t t) :neutral :guard) :hazard t) :hit)
              (eq (resolve-contact :guard :in-front nil :ward t) :blocked)))
  ;; walk / run by band (colder is slower; zero rooted)
  (check (and (~= (kit-walk b) 3.8) (~= (kit-run b) 9.0) (~= (kit-walk m18) 3.4) (~= (kit-run m18) 8.0) (~= (kit-walk m50) 2.8)
              (~= (kit-run m50) 6.4) (~= (kit-walk z) 0.0) (~= (kit-run z) 0.0)))
  ;; the Kikon counts: Shikai 2, every band 3; Soul Breaks 3 / 4; the cinematics
  (check (and (= 2 (kit-kikon-konpaku b)) (every (lambda (k) (= 3 (kit-kikon-konpaku k))) (list m18 m50 z))
              (= 3 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku b) t))) (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku m18) t)))
              (eq 'ru-kikon-cine (kit-kikon-cine b)) (eq 'ru-hakka-cine (kit-kikon-cine m18)) (eq 'ru-hakka-cine (kit-kikon-cine z))
              (eq 'ru-awaken-cine (kit-cine m18))))
  ;; the reaches: ENBU 8.0 m in <= 30 f; HAKKA's lane 6.5 / 7.5 / 9.0, no dash; J1 S7 beats every K1 in the game
  (let ((en (kit-command-move b :kikon)))
    (check (and (~= 8.0 (kikon-rush-reach (getf (mv-params en) :speed) (getf (mv-params en) :dash-max))) (= 30 (+ (getf (mv-params en) :aura) (getf (mv-params en) :dash-max) (mv-s en)))
                (equal '(6.5 7.5 9.0) (mapcar (lambda (k) (mv-reach (kit-command-move k :kikon))) (list m18 m50 z)))
                (zerop (getf (mv-params (kit-command-move z :kikon)) :dash-max)) (= 7 (mv-s (kit-command-move b :q)))
                (< (mv-s (kit-command-move b :q)) (min (mv-s (mv :yamamoto :base :ya-k1)) (mv-s (mv :kenpachi :base :ke-k1)))))))
  ;; fairness: TSUKISHIRO's circle + Kenpachi's hurt radius < a Step; every HAKUREN's widest half-width + his hurt radius
  ;; < a Step (a side Step clears every wave, never shortened by the field); the ring's tell 24 f, one ring at a time (no
  ;; cooldown since 2026-09-29: the move outlasts its pillar)
  (let* ((ts (kit-command-move b :sig)) (pa (mv-params ts)))
    (check (and (< (+ (getf pa :radius) 0.45) *step-distance*) (= 24 (getf pa :delay)) (> (mv-total ts) (+ (mv-s ts) (getf pa :delay)))
                (member :bind (mv-flags ts)) (equal (getf pa :tell) '(21 30))
                (every (lambda (k) (let ((hp (mv-params (kit-command-move k :sp1))))
                                     (< (+ (* 0.5 (+ (getf hp :width) (* 3 (getf hp :width-per)))) 0.45) *step-distance*)))
                       (list b m18 m50 z))
                (equal (mv-hold (kit-command-move b :sp1)) '(16 64))
                (= 130 (let ((hp (mv-params (kit-command-move b :sp1)))) (+ (getf hp :dmg) (* 3 (getf hp :dmg-per))))))))
  ;; frost on the hits: the K links, Shirafune, the new links
  (flet ((fr (k n) (hw-frost (svref (mv-hits (kit-move k n)) 0))))
    (check (and (= 60 (fr b :ru-k1)) (= 60 (fr b :ru-k2)) (= 90 (fr b :ru-k3)) (= 0 (fr b :ru-j1)) (= 150 (fr b :ru-shirafune))
                (= 90 (fr m18 :ru-a-k1)) (= 120 (fr m18 :ru-a-k3)) (= 120 (fr m18 :ru-hakka-18)) (= 150 (fr z :ru-z-k3)))))
  ;; the route damage on hit (before multipliers): KKK 208, JJJ 110, the O ender 63
  (flet ((dmg (&rest names) (loop for n in names for i from 1 sum (hit-damage (mv-dmg (kit-move b n)) nil nil i nil))))
    (check (and (= 110 (dmg :ru-j1 :ru-j2 :ru-j3)) (= 208 (dmg :ru-k1 :ru-k2 :ru-k3)) (= 63 (hit-damage 70 nil nil 4 nil)))))
  ;; the looks and the HUD: the body variants, the blades, the hidden tags, the U tags, the band names
  (check (and (eq :rukia (kit-body b)) (eq :rukia (kit-body m50)) (eq :rukia-zero (kit-body z))
              (equal '(:sode-no-shirayuki :ru-rime :ru-ice) (mapcar #'kit-weapon (list m18 m50 z)))
              (not (member :ice-trim (kit-hide m50))) (member :ice-trim (kit-hide m18)) (member :hand-crack (kit-hide z))
              (equal (mapcar #'kit-u-tag (list m18 m50 z)) '("U: COOL" "U: COOL" "U: BRACE"))
              (equal (mapcar #'kit-form-name (list m18 m50 z)) '("-18C" "-50C" "-273C"))))
  ;; AI keys: the awakening rule, cooling (-50 not below half a guard gauge), bracing at zero, the stun follow-ups, the
  ;; opponent's wait
  (check (and (equal (getf (kit-ai b) :awaken) '(:melee-share 0.6 :min-taken 150)) (equal (getf (kit-ai b) :stun-follow) '(:sp2 2.4 5.0))
              (equal (getf (kit-ai m18) :cool) '(:p 0.3 :near 3.5)) (= 50 (getf (getf (kit-ai m50) :cool) :min-gg))
              (null (getf (kit-ai z) :cool)) (getf (kit-ai z) :brace) (null (getf (kit-ai z) :zero-exit))
              (equal (getf (kit-ai z) :opp-intent) '(:zone 2 :defend 2)) (null (getf (kit-ai b) :opp-intent)))))

;; L after a K link (the kit's :l-after-k, docs/duel/DUEL_STRINGS.md §12, the user's decision 2026-09-28): every K link of
;; every Rukia form (K1 K2 K2s K3) has one, no J link and no other character; the Shikai's is the combo copy of TSUKISHIRO,
;; the bands' their own L. On hit it combos: from the K link's hit its A + the L's hit frame (the last :on-frame hook + a
;; hazard's :delay) < the K link's hitstun; the Shikai's plain TSUKISHIRO wouldn't (its 24 f tell)
(flet ((l-hit (l) (+ (first (car (last (mv-on-frame l)))) (or (getf (mv-params l) :delay) 0))))
  (dolist (form '(:base :m18 :m50 :zero))
    (let* ((k (kit :rukia form)) (ks (remove-if-not (lambda (l) (eq :f (car (last (third l))))) (link-moves k))))
      (check (= 4 (length (remove-duplicates (mapcar #'first ks)))))
      (dolist (l ks)
        (let* ((m (first l)) (lm (kit-l-link k (mv-name m))) (w (svref (mv-hits m) 0)))
          (check (and lm (eq (mv-kind lm) :sig)))
          (check (< (+ (- (mv-s m) (hw-from w)) (mv-a m) (l-hit lm)) (hitstun (hw-react w))))))
      (check (notany (lambda (l) (and (eq :q (car (last (third l)))) (kit-l-link k (mv-name (first l)))))
                     (link-moves k)))))
  (let* ((b (kit :rukia :base)) (lk (kit-l-link b :ru-k1)) (ts (kit-command-move b :sig)))
    (check (and (eq :ru-tsukishiro-k (mv-name lk)) (= 18 (l-hit lk)) (= 36 (l-hit ts)) (zerop (mv-cooldown ts)) (zerop (mv-cooldown lk))   ; (no L cooldown: the user 2026-09-29)
                (>= (+ 4 (l-hit ts)) 26)                                 ; the plain one misses the combo after a K1
                (>= (mv-reach lk) (getf (mv-params lk) :range))           ; no chase: the ring is cast at him
                (equal (mv-callout ts) (mv-callout lk)) (member :bind (mv-flags lk))))
    (check (every (lambda (f) (eq (kit-l-link (kit :rukia f) :ru-k2) (kit-command-move (kit :rukia f) :sig))) '(:m18 :m50 :zero)))
    (check (every (lambda (cf) (null (kit-l-after-k (apply #'kit cf)))) (remove-if (lambda (c) (member c '(:rukia :ichigo :senjumaru :lille :barro))) *forms* :key #'first)))
    (check (every (lambda (f) (numberp (getf (kit-ai (kit :rukia f)) :l-after-k))) '(:base :m18 :m50 :zero)))))

;; the combo band lock with overdraft (the user's decision 2026-09-28): inside a combo the band holds whatever C does; L is
;; refused short of its cold outside a combo, allowed on credit inside one while C > 0; once free the band re-resolves,
;; several at once: -273 K K K (40 each) leaves 80, the chained L (100) overdraws to 0, and she lands at -18
(let* ((z (kit :rukia :zero)) (kc (getf (kit-cold z) :f)) (lc (getf (kit-cold z) :sig))
       (c (- *cold-max* (* 3 kc))))
  (check (and (= 40 kc) (= 100 lc) (= 80 c)
              (not (cold-ok-p c lc nil)) (cold-ok-p c lc t) (not (cold-ok-p 0.0 lc t)) (cold-ok-p 100.0 lc nil)
              (eq :zero (temp-band-at c :zero :move)) (eq :zero (temp-band-at 0.0 :zero :move))   ; locked in the combo
              (eq :zero (temp-band-at 0.0 :zero :stun)) (eq :m50 (temp-band-at 80.0 :zero :idle))
              (eq :m18 (temp-band-at (max 0.0 (- c lc)) :zero :idle))                          ; the overdrawn combo: -18
              (eq :m50 (temp-band-at 150.0 :m50 :guard)) (eq :m18 (temp-band-at 0.0 :m50 :run))
              (eq :m18 (temp-band-at 10.0 :m18 :move)) (eq :zero (temp-band-at 200.0 :m18 :idle)))))

;; Ichigo v2 (docs/duel/DUEL_ICHIGO.md "v2: built"): the cross copies, the stance and its branches (every one combos after a K
;; link), KESSA's cuts, the clones (their timing, the Konpaku table, their fate), the parry's own window (GOKUI GAESHI's
;; unchanged), the counter, the afterimages, the pull, the Kikon counts and cinematics, the removed tools
(let* ((b (kit :ichigo :base)) (ks (kit :ichigo :kessa)) (parry (kit-move ks :ic-k-parry)) (gaeshi (kit-move ks :ic-k-gaeshi))
       (hiki (kit-move ks :ic-k-hiki)) (kj1 (kit-command-move ks :q)) (kk1 (kit-command-move ks :f)) (hk (svref (mv-hits hiki) 0))
       (tsuki (kit-command-move b :sig)) (tk2 (kit-l-link b :ic-k1)) (win (getf (mv-params parry) :window))
       (kr 0.45))                                          ; Kenpachi's hurt r (ken-art.lisp: the host loads no body)
  (flet ((gv (k n) (hw-guard (svref (mv-hits (kit-move k n)) 0))))
    ;; the CROSS: J2s / K2s = J2 / K2 with guard 12 / 24 (J2 / K2 8 / 16); KESSA's copies are plain (one blade)
    (check (and (= 8 (gv b :ic-j2)) (= 12 (gv b :ic-j2s)) (= 16 (gv b :ic-k2)) (= 24 (gv b :ic-k2s)) (= 22 (gv b :ic-k3))
                (eq :ic-cross (mv-clip (kit-move b :ic-k2s))) (equal (mv-spec (kit-move ks :ic-k-k2)) (mv-spec (kit-move ks :ic-k-k2s)))))
    ;; KESSA's cuts: ordinary reach (J 2.6, K 3.2), routes on hit JJJ 100 / KKK 204, blocked KKK drains 48
    (check (and (~= 1.56 (mv-reach kj1)) (~= 2.9 (mv-reach kk1)) (<= (mv-reach (kit-move ks :ic-k-k3)) 3.6)
                (= 100 (+ (mv-dmg kj1) (mv-dmg (kit-move ks :ic-k-j2)) (mv-dmg (kit-move ks :ic-k-j3))))
                (= 204 (+ (mv-dmg kk1) (mv-dmg (kit-move ks :ic-k-k2)) (mv-dmg (kit-move ks :ic-k-k3))))
                (= 48 (+ (gv ks :ic-k-k1) (gv ks :ic-k-k2) (gv ks :ic-k-k3))))))
  ;; the stance: up at f6, 30 f held (60 with L held) then R 14, no hits (hit as neutral); its branches are non-button
  ;; strings; L after a K link opens it at f4; L, L fires the Getsuga at the old L's f14; the dash comes back at f6
  (check (and (= 6 (mv-s tsuki)) (= 80 (mv-total tsuki)) (zerop (length (mv-hits tsuki))) (eq :ic-tsuki-k2 (mv-name tk2))
              (= 4 (mv-enter tk2)) (= 6 (mv-enter (find-move :ic-tsuki-re))) (= 80 (+ *tsuki-up* *tsuki-max* 14))
              (eq (kit-next b :ic-tsuki :tsuki-j) (find-move :ic-tsuki-j)) (eq (kit-next b :ic-tsuki-k2 :tsuki-k) (find-move :ic-tsuki-k))
              (eq (kit-next b :ic-tsuki-re :tsuki-step) (find-move :ic-tsuki-dash))
              (eq (kit-next b :ic-tsuki-dash :tsuki-back) (find-move :ic-tsuki-re))
              (= 14 (+ *tsuki-up* (mv-s (kit-next b :ic-tsuki :tsuki-l)))) (null (kit-l-link b :ic-j1))
              (not (string-link-p b :ic-tsuki))))
  ;; RANGETSU: four hits, -6 on block (J1 7 f doesn't punish it); TSUKI-OTOSHI: guard 30, -10
  (let ((rj (find-move :ic-tsuki-j)) (rk (find-move :ic-tsuki-k)))
    (check (and (= 4 (length (mv-hits rj))) (= 72 (* 4 (mv-dmg rj))) (= -6 (mv-adv-block rj)) (= 30 (hw-guard (svref (mv-hits rk) 0)))
                (= -10 (mv-adv-block rk)) (eq :crumple (hw-react (svref (mv-hits rk) 0))))))
  ;; every branch combos off a K link's hit: its A + 2 (the stance's f4 -> f6) + the branch's first hit (the wave's travel
  ;; from 1 m out to 3 m) < the K link's hitstun
  (dolist (k '(:ic-k1 :ic-k2 :ic-k3))
    (let* ((m (kit-move b k)) (st (hitstun (hw-react (svref (mv-hits m) 0)))))
      (check (and (< (+ (mv-a m) 2 (mv-first-hit (kit-next b :ic-tsuki-k2 :tsuki-j))) st)
                  (< (+ (mv-a m) 2 (mv-first-hit (kit-next b :ic-tsuki-k2 :tsuki-k))) st)
                  (< (+ (mv-a m) 2 (mv-s (kit-next b :ic-tsuki-k2 :tsuki-l)) (ceiling (* 60 (/ 2.0 16.0)))) st)))))
  ;; the clones: a J press's heavy lands inside Ichigo's J1 flinch (between J1 and J2), a K press's light before his K1;
  ;; an opponent's J1 (7 f) beats the light (a real hit on Ichigo clears every clone)
  (check (and (= 22 (clone-hit-frame :q)) (= 14 (clone-hit-frame :f))
              (< (mv-s kj1) (clone-hit-frame :q) (+ (mv-s kj1) (hitstun :flinch))) (< (clone-hit-frame :f) (mv-s kk1))
              (< (mv-s (mv :kenpachi :base :ke-j1)) (clone-hit-frame :f))
              (eq :stagger (hw-react (svref (mv-hits (clone-move :q 1)) 0))) (eq :crumple (hw-react (svref (mv-hits (clone-move :q 3)) 0)))
              (eq :flinch (hw-react (svref (mv-hits (clone-move :f 1)) 0)))))
  ;; the Kikon's Konpaku by the clones at the O press (the user's table 0 / 1 / 2 / 3 -> 2 / 2 / 3 / 4, at most 4)
  (check (and (equal '(2 2 3 4) (mapcar #'clone-konpaku '(0 1 2 3))) (= 4 (clone-konpaku 5)) (<= (clone-konpaku 3) *kikon-max-event*)))
  ;; a clone's life and fate: 300 f, 3 at most (the oldest replaced), 15 guard gauge each (no Step gap); its string touched him
  ;; (hit or block): it fades, a whiff keeps it (idle), its time up: it fades; a real hit on Ichigo (not a block, not a
  ;; parry) clears them all
  (check (and (= 300 *clone-life*) (= 3 *clone-max*) (= 15.0 *clone-cost*)
              (eq :idle (clone-after-string nil 100)) (eq :fade (clone-after-string t 100)) (eq :fade (clone-after-string nil 0))
              (null (clone-evict '(5 9))) (= 1 (clone-evict '(7 3 9)))
              (clone-vanish-p :hit) (clone-vanish-p :counter) (clone-vanish-p :guard-break)
              (not (clone-vanish-p :blocked)) (not (clone-vanish-p :parried)) (not (clone-vanish-p nil))))
  ;; the parry: its own window f2-25 (24 f; the move's :window), 360 deg, 10 of the gauge, R 18; GOKUI GAESHI's shared
  ;; window is the same f2-25 since 2026-10-01; a catch staggers 40 f, and ZANGETSU-GAESHI (the :land string) is +15: his J1 combos
  (check (and (member :parry (mv-flags parry)) (equal '(2 25) win) (= 2 (mv-s parry)) (= 24 (mv-a parry)) (= 44 (mv-total parry))
              (parry-frame-p 2 win) (parry-frame-p 25 win) (not (parry-frame-p 1 win)) (not (parry-frame-p 26 win))
              (parry-frame-p 2) (parry-frame-p 25) (not (parry-frame-p 1)) (not (parry-frame-p 26))
              (eq (kit-next ks :ic-k-parry :land) gaeshi) (= 10 *kessa-parry-cost*) (= 20 *kessa-parry-catch*)
              (= 40 *kessa-parry-stun*) (< (mv-s gaeshi) *kessa-parry-stun*)
              (= 15 (- (+ (mv-s gaeshi) (hitstun :crumple)) (mv-total gaeshi))) (< (mv-s kj1) 15)
              (member :parry-block (kit-passives ks)) (not (member :parry-block (kit-passives b)))))
  ;; a :parry-block parry blocks a hazard and catches a melee hit
  (check (and (eq (resolve-contact :parry :hazard t :ward t) :blocked) (eq (resolve-contact :parry) :parried)
              (eq (resolve-contact :parry :breaker t) :stance-break) (eq (resolve-contact :parry :unguardable t) :hit)))
  ;; the afterimages: each hit repeats *ZANZO-LAG* (10) f later at x0.5 damage and guard, a blade's hit: J1's at f18,
  ;; RANGETSU's four at f18 21 24 27
  (let ((w (echo-hitwin (svref (mv-hits kj1) 0) *zanzo-mult*)))
    (check (and (equal '(18) (echo-hit-frames kj1)) (equal '(18 21 24 27) (echo-hit-frames (find-move :ic-tsuki-j)))
                (= 15 (hw-dmg w)) (~= 4.0 (hw-guard w)) (member :blade (hw-flags w)) (eq :flinch (hw-react w))
                (= 360 *zanzo-life*))))
  ;; KUSARI-BIKI: the far part ranged (beyond 3.8 m), bound 40 f from its f16 hit: +13, so his J1 (8 f) combos
  (check (and (member :ranged (hw-flags hk)) (= 40 (hw-stun hk)) (eq :bind (hw-react hk))
              (~= 3.8 (getf (mv-params hiki) :melee-range)) (= 13 (- (+ (hw-from hk) (hw-stun hk)) (mv-total hiki)))
              (< (mv-s kj1) 13)))
  ;; the Kikon counts 2 / 3 (a Soul Break 3 / 4); KESSA's Soul Break plays the Getsuga (its :soul-break-cine), its O 千影
  (check (and (= 2 (kit-kikon-konpaku b)) (= 3 (kit-kikon-konpaku ks)) (kit-awakening ks)
              (eq 'ic-kessa-getsuga-cine (kit-kikon-cine ks)) (eq 'ic-kikon-cine (kit-kikon-cine b))
              (eq 'ic-kessa-kikon-cine (mv-cine (kit-command-move ks :kikon)))
              (~= 8.6 (kikon-rush-reach 30.0 14)) (> (+ (mv-reach (kit-command-move ks :breaker)) 0.34) *breaker-trigger*)))
  ;; a side Step (2.5 m) clears every crescent: its half-width + Kenpachi's hurt r < 2.5
  (check (every (lambda (w) (< (+ (* 0.5 w) kr) *step-distance*))
                (list (getf (mv-params (kit-next b :ic-tsuki :tsuki-l)) :width) (getf (mv-params (kit-command-move b :sp1)) :width))))
  ;; U is a guard again in both forms (no :u hook, no chain skin); the removed base tools (sidegrade rule 2): no JUJISHO,
  ;; no SOGA, no cross links, no stance; slower
  (check (and (null (kit-hook ks :u)) (null (kit-hook ks :hud-guard)) (null (kit-u-tag ks)) (null (kit-l-after-k ks))
              (not (eq (kit-command-move ks :sp1) (kit-command-move b :sp1))) (not (eq (kit-command-move ks :sp2) (kit-command-move b :sp2)))
              (not (eq (kit-command-move ks :sig) tsuki)) (< (kit-walk ks) (kit-walk b)) (< (kit-run ks) (kit-run b))))
  ;; the CPU: the awakening after 150 taken; KESSA guards (0.4) and parries / sends the clones by its :reflex
  (check (and (equal (getf (kit-ai b) :awaken) '(:min-taken 150)) (eq 'ichigo-ai-kessa (getf (kit-ai ks) :reflex))
              (~= 0.4 (getf (kit-ai ks) :guard)) (equal (kit-form-name ks) "KESSA") (member :kessa (kit-hide b)) (member :shikai (kit-hide ks)))))
;; ================================================================ ENDLESS (docs/duel/DUEL_ENDLESS.md, endless-rules.lisp)
(defun snap (c f &rest kv)
  (append kv (list :character c :form f :konpaku 5 :reiatsu 123.5 :fs 42.25 :awaken 37.0 :awakened (kit-awakening (kit c f))
                   :meter 55.0)))
(defun carry (c f choice &rest kv) (endless-carry (apply #'snap c f kv) choice))
;; Konpaku + 2, at most 9; Reiatsu and flash step bit-identical; the rest comes from the fresh spawn
(check (equal '(3 9 9 9) (mapcar (lambda (k) (getf (carry :yamamoto :base :stay :konpaku k) :konpaku)) '(1 7 8 9))))
(check (every (lambda (cf) (let ((r (carry (first cf) (second cf) :stay)))
                             (and (eql 123.5 (getf r :reiatsu)) (eql 42.25 (getf r :fs)))))
              *forms*))
;; not awakened: the awakening gauge and the kit meter (Inferno) kept; Hellfire ends like its timer: the base, meter 0
(let ((r (carry :yamamoto :base :stay)))
  (check (and (eq :base (getf r :form)) (eql 37.0 (getf r :awaken)) (null (getf r :awakened)) (eql 55.0 (getf r :meter)))))
(let ((r (carry :yamamoto :hellfire :stay)))
  (check (and (eq :base (getf r :form)) (eql 37.0 (getf r :awaken)) (zerop (getf r :meter)))))
;; revert, every awakened form of every character: the base, not awakened, the awakening full, the meter 0
(check (every (lambda (cf) (let ((r (carry (first cf) (second cf) :revert)))
                             (and (eq :base (getf r :form)) (null (getf r :awakened)) (= *awaken-max* (getf r :awaken))
                                  (zerop (getf r :meter)))))
              (remove-if-not (lambda (cf) (kit-awakening (apply #'kit cf))) *forms*)))
;; stay: Yamamoto East / West -> East; every Kenpachi awakened form -> cup 1 at NOME 10 (the user's decision 2026-09-29:
;; no cup kept); Rukia's bands -> -18 at cold 0
(check (every (lambda (f) (eq :bankai-east (getf (carry :yamamoto f :stay) :form))) '(:bankai-east :bankai-west)))
(check (every (lambda (f) (let ((r (carry :kenpachi f :stay)))
                            (and (eq :nozarashi (getf r :form)) (= *nome-awaken* (getf r :meter)) (getf r :awakened)
                                 (zerop (getf r :awaken)))))
              '(:nozarashi :ryote :nomihose :bankai :kataude)))
(check (every (lambda (f) (let ((r (carry :rukia f :stay))) (and (eq :m18 (getf r :form)) (zerop (getf r :meter)))))
              '(:m18 :m50 :zero)))
(check (eq :base (getf (carry :kenpachi :base :stay) :form)))
;; generic guards (a new character's forms must satisfy them): every stay target of an awakened form is awakened, none
;; is any kit's :bankai-form or its arm's :to, and a timed form's stay target is not timed
(let ((targets (loop for cf in *forms* when (kit-awakening (apply #'kit cf))
                     collect (list (first cf) (endless-stay-form (apply #'kit cf)))))
      (second-forms (loop for cf in *forms* for k = (apply #'kit cf)
                          when (kit-bankai-form k) collect (list (first cf) (kit-bankai-form k))
                          when (kit-pips k) collect (list (first cf) (getf (kit-pips k) :to)))))
  (check (every (lambda (ct) (kit-awakening (apply #'kit ct))) targets))
  (check (notany (lambda (ct) (member ct second-forms :test #'equal)) targets))
  (check (every (lambda (cf) (null (kit-duration (kit (first cf) (endless-stay-form (apply #'kit cf))))))
                (remove-if-not (lambda (cf) (kit-duration (apply #'kit cf))) *forms*))))
;; §5: a Bankai at Konpaku 4 leaves 1, the clear gives 3, and cup 3 may take the Bankai again at 3
(check (and (= 3 (getf (carry :kenpachi :bankai :stay :konpaku 1) :konpaku)) (bankai-allowed-p t 3)))
;; the ramp: the difficulty never falls and clamps at HARD, equal from 12 on; the awakening and Reishi never fall
(check (every (lambda (fl)
                (loop for n from 1 to 40
                      for d = (position (endless-difficulty fl n) '(:easy :normal :hard)) and d0 = -1 then d
                      always (and d (>= d d0)) finally (return t)))
              '(:easy :normal :hard)))
(check (and (eq :hard (endless-difficulty :easy 5)) (eq :normal (endless-difficulty :easy 3)) (eq :hard (endless-difficulty :normal 3))
            (eq :easy (endless-difficulty :easy 1)) (eq :hard (endless-difficulty :hard 1))
            (every (lambda (fl) (loop for n from 12 to 60 always (equal (endless-ramp n) (endless-ramp 12)))) '(:easy :normal :hard))))
(check (loop for n from 1 to 40 for r = (endless-ramp n) and r0 = (endless-ramp 1) then r
             always (and (>= (third r) (third r0)) (or (fourth r) (not (fourth r0))) (>= (fifth r) (fifth r0)))))
(check (equal '(0 50 100 100) (mapcar (lambda (n) (third (endless-ramp n))) '(4 5 7 9))))
(check (and (not (fourth (endless-ramp 8))) (fourth (endless-ramp 9)) (= 110 (fifth (endless-ramp 11))) (= 120 (fifth (endless-ramp 12)))))
;; the bag: each bag the roster once; never the same opponent twice in a row (seeds 1-200); a seed replays; seeds differ
(flet ((run (seed n roster) (loop for s from 1 to n collect (endless-opponent seed s roster))))
  (dolist (roster (list *roster* '(:a :b) '(:a :b :c :d :e)))
    (let ((n (length roster)))
      (check (loop for seed from 1 to 200 for r = (run seed (* 6 n) roster)
                   always (and (loop for b below 6 always (null (set-exclusive-or (subseq r (* b n) (* (1+ b) n)) roster)))
                               (loop for (a b) on r while b never (eq a b)))))))
  (check (equal (run 7 12 *roster*) (run 7 12 *roster*)))
  (check (> (length (remove-duplicates (loop for seed from 1 to 20 collect (run seed 3 *roster*)) :test #'equal)) 2)))
(check (/= (endless-stage-seed 1 2) (endless-stage-seed 1 3) (endless-stage-seed 2 2)))
;; the record: more stages wins, equal stages less time, an empty record (0) loses to any stage, 0 stages never writes
(check (and (endless-better-p 3 500 2 100) (not (endless-better-p 2 50 3 900)) (endless-better-p 3 400 3 500)
            (not (endless-better-p 3 500 3 500)) (not (endless-better-p 3 600 3 500)) (endless-better-p 1 999 0 0)
            (not (endless-better-p 0 10 0 0))))

;;; ================================================================ Senjumaru (docs/duel/DUEL_SENJUMARU.md §10's host tests)
(let ((b (kit :senjumaru :base)) (t1 (kit :senjumaru :tsuji1)) (t6 (kit :senjumaru :tsuji6)))
  ;; the stitches: a hit sews 2, any other contact 1, a parry nothing, capped at 6; 179 idle frames keep them, the 180th
  ;; drops one, then one per 30; a lock pauses the clock
  (check (and (= 2 (hari-sew 0 :hit)) (= 2 (hari-sew 0 :counter)) (= 1 (hari-sew 0 :blocked)) (= 1 (hari-sew 0 :absorbed))
              (= 1 (hari-sew 0 :armored)) (= 0 (hari-sew 0 :parried)) (= 0 (hari-sew 0 nil)) (= 6 (hari-sew 5 :hit))
              (= 6 (hari-sew 6 :blocked))))
  (flet ((run (n idle frames &optional locked)
           (let ((fell 0)) (dotimes (i frames) (multiple-value-bind (n2 i2 f) (hari-step n idle locked) (setf n n2 idle i2) (when f (incf fell))))
             (values n fell))))
    (check (and (= 6 (run 6 0 179)) (= 5 (run 6 0 180)) (= 5 (run 6 0 209)) (= 4 (run 6 0 210)) (= 0 (run 6 0 330))
                (= 1 (run 6 0 329)) (= 6 (run 6 0 400 t)) (= 0 (run 0 50 10)))))
  (check (and (= 180 (hari-falls-in 3 0)) (= 1 (hari-falls-in 3 179)) (= 30 (hari-falls-in 3 180)) (= 1 (hari-falls-in 3 209))))
  ;; 悪い癖: spikes from f10, 2 f apart, 10 each, unguardable, :spare; the last holds him to f38, she is free at f32: +6, no
  ;; combo; the -k copy after a K link lands every spike inside the K link's stagger (A 4 + 8 + 2 x 5 = 22 < 26)
  (let ((l (kit-command-move b :sig)) (lk (kit-l-link b :sj-k1)))
    (check (and (eq :sj-warui-kuse (mv-name l)) (= 8 (mv-s l)) (= 32 (mv-total l)) (= 10 (getf (mv-params l) :first))
                (= 6 (- (+ (getf (mv-params l) :first) (* *hari-gap* 5) *hari-last-stun*) (mv-total l)))
                (eq :sj-warui-kuse-k (mv-name lk)) (= 6 (mv-s lk)) (= 8 (getf (mv-params lk) :first))
                (< (+ 4 (getf (mv-params lk) :first) (* *hari-gap* 5)) (hitstun :stagger))
                (>= (mv-reach lk) 9.0) (= 13 *hari-dmg*) (every (lambda (k) (kit-l-link b k)) '(:sj-k1 :sj-k2 :sj-k2s :sj-k3)))))
  ;; the stitches pay: a hit JJJ is 6; blocked, the universal 24 / 46 of guard and 3 stitches either way
  (check (= 6 (reduce #'hari-sew '(:hit :hit :hit) :initial-value 0)))
  (check (= 3 (reduce #'hari-sew '(:blocked :blocked :blocked) :initial-value 0)))
  ;; the Shikai's grid: the lightest (the user, 2026-10-01: J x0.9, K x0.8: J1 25, JJJ 82, KKK 147 on hit; the Bankai's
  ;; K1 45, K3 58)
  (check (and (= 25 (mv-dmg (kit-command-move b :q))) (= 82 (+ 25 (mv-dmg (mv :senjumaru :base :sj-j2)) (mv-dmg (mv :senjumaru :base :sj-j3))))
              (= 147 (+ (mv-dmg (kit-command-move b :f)) (mv-dmg (mv :senjumaru :base :sj-k2)) (mv-dmg (mv :senjumaru :base :sj-k3))))
              (= 45 (mv-dmg (mv :senjumaru :tsuji1 :sj-t-k1))) (= 58 (mv-dmg (mv :senjumaru :tsuji1 :sj-t-k3)))))
  ;; the soldier: one string of three, 300 f, 3.5 m/s (the user's decision), one stitch when it bursts; it moves the frame
  ;; she is free (2026-10-01); each flinch outlasts the next wind-up (+4 for the hitstop: a true combo); the umbrella: a guard over f4-27,
  ;; the tendrils always fire, 40 + half the largest caught hit, at most 120, a side Step clears them (0.8 + 0.45 < 2.5)
  (check (and (= 3 (length *shinpei-combo*)) (= 300 *shinpei-life*) (~= 3.5 *shinpei-speed*)
              (= (mv-total (kit-command-move b :sp1)) (+ 10 *shinpei-rise*))
              (member '(10 senju-shinpei) (mv-on-frame (kit-command-move b :sp1)) :test #'equal)
              (loop for (h nx) on *shinpei-combo* while nx always (>= (seventh h) (+ (first nx) 4)))
              (= 74 (reduce #'+ *shinpei-combo* :key #'fifth))))
  (let ((k (kit-command-move b :sp2)))
    (check (and (member :shield (mv-flags k)) (= 4 (mv-s k)) (= 24 (mv-a k)) (eq 'senju-kasa-catch (getf (mv-params k) :catch))
                (= 40 (kasa-damage 0)) (= 70 (kasa-damage 60)) (= 120 (kasa-damage 999)) (= 1 (kit-command-cost b :sp2))
                (= 2 (kit-command-cost t1 :sp2)) (< (+ (* 0.5 (getf (mv-params k) :width)) 0.45) *step-distance*)
                (member '(28 senju-kasa-fire) (mv-on-frame k) :test #'equal))))
  ;; NUICHI: 7.7 m, <= 28 f; the Bankai's lane 8.5 m; Kikon 2 / 3, Soul Break 3 / 4
  (let ((o (kit-command-move b :kikon)) (u (kit-command-move t1 :kikon)))
    (flet ((pa (m k) (getf (mv-params m) k)))
      (check (and (~= 7.7 (kikon-rush-reach (pa o :speed) (pa o :dash-max)) 0.05) (= 28 (+ (pa o :aura) (pa o :dash-max) (mv-s o)))
                  (~= 8.5 (mv-reach u)) (= 2 (kit-kikon-konpaku b)) (= 3 (kit-kikon-konpaku t1)) (= 3 (kit-kikon-konpaku t6))
                  (eq 'sj-kikon-cine (kit-kikon-cine b)) (eq 'sj-hata-cine (kit-kikon-cine t1))))))
  ;; the loom: six forms, form k's next hank is k; a release advances along the queue (the user, 2026-09-30): 黒砂 刃金 褥
  ;; 焼野原 眼 星, then 黒砂 again; L held 20-60 (a pass per 20 f), the combo copy no hold, S 8, a 9 m reach (no chase)
  (check (and (equal (loop for n from 1 to 6 collect (hank-next n)) '(6 4 2 5 1 3))
              (equal (loop for n from 1 to 6 collect (form-hank (hank-form n))) '(1 2 3 4 5 6)) (null (form-hank :base))
              (equal (mapcar #'weave-passes '(20 39 40 59 60 61)) '(1 1 2 2 3 3))))
  (loop for n from 1 to 6
        for k = (kit :senjumaru (hank-form n))
        for l = (kit-command-move k :sig)
        for lk = (kit-l-link k :sj-t-k1)
        do (check (and (= n (getf (mv-params l) :hank)) (equal (mv-hold l) '(1 600)) (= 6 (mv-s l)) (member :bind (mv-flags l))
                       (eq 'senju-weave-release (mv-release l)) (null (mv-release lk))
                       (= n (getf (mv-params lk) :hank)) (null (mv-hold lk)) (= 8 (mv-s lk)) (getf (mv-params lk) :combo)
                       (>= (mv-reach lk) 9.0) (eq (intern (format nil "SJ-TACHINAOSHI-~d" n) :keyword) (mv-name (kit-command-move k :sp1)))
                       (= 1 (kit-command-cost k :sp1)) (kit-awakening k)
                       (zerop (mv-cooldown l)))))                 ; (no COOLDOWN row: the torn lock is L's timer)
  ;; the combo cut: L after a K link hits before the K link's stagger ends (A 4 + S 8 + unfold 10 = 22 < 26)
  (check (< (+ 4 8 *unfold-combo*) (hitstun :stagger)))
  ;; the weave's scaling: radius, life, damage never smaller with more passes; every disc's full radius + Kenpachi's hurt r
  ;; < a Step; the corridor's half-width too; the rings with no hit (眼 3.0, 星 3.5) are free of the rule
  (loop for n in '(2 3 4) do (check (< (+ (hank-radius n 3) 0.45) *step-distance*)))
  (check (< (+ (* 0.5 (hank 5 :width)) 0.45) *step-distance*))
  (loop for n from 1 to 6
        do (check (loop for p from 1 below 3
                        always (and (or (not (hank n :r)) (<= (hank-radius n p) (hank-radius n (1+ p))))
                                    (or (not (hank n :life)) (<= (hank-life n p) (hank-life n (1+ p))))
                                    (or (not (hank n :dmg)) (<= (hank-damage n p) (hank-damage n (1+ p))))))))
  (check (and (= 126 (hank-damage 2 3)) (= 90 (hank-damage 2 2)) (= 63 (hank-damage 2 1)) (= 288 (hank-life 1 3))
              (= 120 (hank-life 1 1)) (~= 2.1 (hank-radius 1 1)) (null (hank 1 :dmg)) (null (hank 6 :dmg))
              (~= 24.0 (hank-fx 4 :freeze 1)) (~= 60.0 (hank-fx 4 :freeze 3)) (~= 45.0 (hank-fx 6 :reiatsu 3))))
  ;; the awakened grid: J1 J2 J3 K2 as the Shikai's (no reach derivation: the playtest), K1 3.8 m, MAKITORI 2.5 m with its
  ;; pull to 1.4
  (check (and (~= 1.44 (mv-reach (kit-command-move t1 :q))) (~= 2.5 (mv-reach (kit-next t1 :sj-j1 :f)))
              (~= 3.8 (mv-reach (kit-command-move t1 :f))) (~= 2.5 (mv-reach (kit-next t1 :sj-k2 :f)))
              (~= 1.4 (getf (mv-params (kit-next t1 :sj-k2 :f)) :pull)) (~= 3.3 (kit-walk t1)) (~= 3.6 (kit-walk b))))
  ;; the CPU: the rule's keys, the loom's hold by distance (星 closer), the Shikai taps L
  (check (and (equal (getf (kit-ai b) :awaken) '(:min-taken 150))
              (= 31 (senju-sig-hold t1 7.0)) (= 31 (senju-sig-hold t1 5.0)) (= 21 (senju-sig-hold t1 3.0))   ; a segment; one pass
              (= 31 (senju-sig-hold t6 5.5)) (= 31 (senju-sig-hold t6 3.0)) (= 1 (senju-sig-hold b 3.0))
              (~= 0.5 (getf (kit-ai t6) :opp-rush-hold)) (null (kit-reset-form t1)) (eq :base (kit-reset-form b)))))

;; L: hold to weave, tap to release (the user, 2026-09-29): under 10 f is a tap; a weave's frames count from its 10th (those
;; 10 at once), one a frame after, summed over segments on the hank up to 3 passes; a release (the tap, K -> L, SP1) makes
;; the stored passes, at least 1; a hit while weaving voids the hank (the next one, nothing woven)
(flet ((seg (woven frames) (loop for h from 1 to frames do (setf woven (weave-add woven h))) woven))
  (check (and (= 10 *weave-tap*) (weave-tap-p 9) (not (weave-tap-p 10))
              (= 0 (seg 0 9)) (= 10 (seg 0 10)) (= 15 (seg 0 15))            ; a tap weaves nothing; a hold counts from f1
              (= 30 (seg (seg 0 15) 15)) (= 1 (weave-stored (seg (seg 0 15) 15)))   ; two segments of 15: one pass
              (= 45 (seg (seg (seg 0 15) 15) 15)) (= 2 (weave-stored 45))
              (= 60 (seg 45 40)) (= 3 (weave-stored (seg 0 200)))            ; capped at three passes
              (= 30 (seg 30 9))                                             ; a tap keeps what is stored
              (= 1 (release-passes 0)) (= 1 (release-passes 19)) (= 2 (release-passes 45)) (= 3 (release-passes 60))
              (equal '(2 0) (multiple-value-list (weave-void 3))) (equal '(3 0) (multiple-value-list (weave-void 6))))))
(check (and (eq :sig (mv-kind (find-move :sj-weave-stop))) (= 6 (mv-total (find-move :sj-weave-stop)))))

;; J weaves, K releases (the user, 2026-09-29): a release needs a stored pass: a tap with nothing woven is refused (the cue,
;; then it stops), as over a live zone; a weave just stops; K -> L (the -k copies) is refused at 0 passes, J -> L never
;; (it weaves), nor SP1 (it releases at 0 as at 1, RELEASE-PASSES); J -> L is HITOKOSHI in every loom form after every
;; J link (+1 pass at f8, at most 3; 8/0/10: -3 after a J1 / J2 hit, +5 after J3, <= -17 blocked), none in the Shikai
(let ((t1 (kit :senjumaru :tsuji1)) (hk (find-move :sj-hitokoshi)))
  (check (and (not (release-ok-p 0)) (not (release-ok-p 19)) (release-ok-p 20)
              (eq :refused (weave-release-act 5 0 nil)) (eq :refused (weave-release-act 9 19 nil))      ; a tap at 0 passes
              (eq :release (weave-release-act 5 20 nil)) (eq :refused (weave-release-act 5 60 t))
              (eq :stop (weave-release-act 10 0 nil)) (eq :stop (weave-release-act 40 60 t))))
  (check (and (not (loom-ok-p :sig (kit-l-link t1 :sj-t-k1) 0)) (not (loom-ok-p :sig (kit-l-link t1 :sj-k2) 19))   ; K -> L
              (loom-ok-p :sig (kit-l-link t1 :sj-t-k1) 20) (loom-ok-p :sig nil 0) (loom-ok-p :sig hk 0)
              (loom-ok-p :sp1 nil 0) (= 1 (release-passes 0))))                                                ; SP1 at 0
  (check (and (= 20 (quick-weave 0)) (= 1 (weave-stored (quick-weave 0))) (= 35 (quick-weave 15))              ; +1 pass
              (= 2 (weave-stored (quick-weave (quick-weave 0)))) (= 60 (quick-weave 45)) (= 60 (quick-weave 60))  ; cap 3
              (= 3 (weave-stored (quick-weave (quick-weave (quick-weave (quick-weave 0))))))))
  (check (and (eq :sig (mv-kind hk)) (= 8 (mv-s hk)) (= 18 (mv-total hk)) (null (mv-hold hk))
              (equal (mv-on-frame hk) '((8 senju-quick-weave))) (null (getf (mv-params hk) :combo))))
  (let ((j1 (kit-command-move t1 :q)) (j3 (kit-next t1 :sj-j2 :q)))
    (check (= -3 (- (hitstun :flinch) (mv-a j1) (mv-total hk))))                          ; safe-ish on hit
    (check (= 5 (- (hitstun :stagger) (mv-a j3) (mv-total hk))))
    (check (<= (- (+ (mv-adv-block j1) *chain-lead*) (mv-total hk)) -17)))              ; punishable blocked
  (loop for n from 1 to 6
        for k = (kit :senjumaru (hank-form n))
        do (check (and (every (lambda (j) (eq hk (kit-l-link k j))) '(:sj-j1 :sj-j2 :sj-j3 :sj-j2s))
                       (every (lambda (j) (getf (mv-params (kit-l-link k j)) :combo)) '(:sj-t-k1 :sj-k2 :sj-k2s :sj-t-k3))
                       (~= 0.35 (getf (kit-ai k) :l-after-j)))))
  (check (notany (lambda (j) (kit-l-link (kit :senjumaru :base) j)) '(:sj-j1 :sj-j2 :sj-j3 :sj-j2s)))
  (check (every (lambda (cf) (or (member (first cf) '(:senjumaru :barro)) (equal cf '(:hisagi :base))   ; (Lille II: J3 -> L;
                                 (null (kit-l-after-j (apply #'kit cf))))) *forms*)))   ; Hisagi's Shikai: the windmill bridge, S1)

;; SP1 裁ち直し releases the next two hanks (the user, 2026-09-29): the queue moves +2 (6 wraps to 1); the move cuts the live
;; zone(s) at f0 and releases at f8 and f14 (the combo cut's rules); off a landed link both land inside a stagger (26 f:
;; cancel frame +1, then S + unfold); its :tell is its first hitting hank's; 1 bar
(check (equal (loop for n from 1 to 6 collect (multiple-value-list (tachi-hanks n)))
              '((1 6 3) (2 4 5) (3 2 4) (4 5 1) (5 1 6) (6 3 2))))
(loop for n from 1 to 6
      for k = (kit :senjumaru (hank-form n))
      for sp = (kit-command-move k :sp1)
      do (check (and (eq :sp (mv-kind sp)) (= 8 (mv-s sp)) (= 30 (mv-total sp)) (= 1 (kit-command-cost k :sp1))
                     (equal (mv-on-frame sp) '((0 senju-combo-cut) (8 senju-tachi-release) (14 senju-tachi-release)))
                     (= 6 *tachi-second*)
                     (< (+ 1 8 *unfold-combo*) (hitstun :stagger)) (< (+ 1 8 *tachi-second* *unfold-combo*) (hitstun :stagger))
                     (equal (getf (mv-params sp) :tell)
                            (cond ((hank-hits-p n) '(10 22)) ((hank-hits-p (hank-next n)) '(16 28)))))))
(check (and (null (getf (mv-params (kit-command-move (kit :senjumaru :tsuji1) :sp1)) :tell))   ; 眼 + 星: no hit
            (equal '(16 28) (getf (mv-params (kit-command-move (kit :senjumaru :tsuji6) :sp1)) :tell))   ; 星 + 黒砂
            (eq 'senju-sp-ender (getf (kit-ai (kit :senjumaru :tsuji1)) :sp-ender))
            (null (getf (kit-ai (kit :senjumaru :tsuji1)) :skip))))

;; The queue in three SP1 pairs (the user, 2026-09-30): 黒砂 → 刃金 → 褥 → 焼野原 → 眼 → 星, wrapping to 黒砂; the awakening
;; enters 黒砂's form; SP1 from an even slot releases a designed pair (黒砂+刃金, 褥+焼野原, 眼+星), from an odd one a cross
;; pair (刃金+褥, 焼野原+眼, 星+黒砂); SP1 keeps the parity, a single release (or a voided weave) flips it; each hank keeps its data
(let* ((b (kit :senjumaru :base)) (n0 (form-hank (kit-awaken-form b))))
  (check (and (eq :tsuji3 (kit-awaken-form b)) (= 3 n0) (equal "黒砂の腸" (hank n0 :kanji)) (equal *hank-order* '(3 2 4 5 1 6))))
  (check (equal (loop repeat 7 for n = n0 then (hank-next n) collect (hank n :short))
                '("KOKUSA" "HAGANE" "SHITONE" "YAKENOHARA" "ME" "HOSHI" "KOKUSA")))
  (flet ((pair (n) (multiple-value-bind (a c) (tachi-hanks n) (list a c))))
    (check (equal (mapcar #'pair (remove-if-not #'tachi-aligned-p *hank-order*)) '((3 2) (4 5) (1 6))))
    (check (equal (mapcar #'pair (remove-if #'tachi-aligned-p *hank-order*)) '((2 4) (5 1) (6 3))))
    (dolist (n *hank-order*)
      (check (eq (tachi-aligned-p n) (tachi-aligned-p (nth-value 2 (tachi-hanks n)))))      ; SP1 keeps the parity
      (check (not (eq (tachi-aligned-p n) (tachi-aligned-p (hank-next n)))))                ; a single release flips it
      (check (not (eq (tachi-aligned-p n) (tachi-aligned-p (weave-void n))))))              ; so does a voided weave
    ;; repeated SP1 from the entry: the three pairs, then 黒砂 + 刃金 again; one tap first: the cross pairs
    (check (equal (loop repeat 4 for n = n0 then (nth-value 2 (tachi-hanks n)) collect (pair n)) '((3 2) (4 5) (1 6) (3 2))))
    (check (equal (loop repeat 3 for n = (hank-next n0) then (nth-value 2 (tachi-hanks n)) collect (pair n)) '((2 4) (5 1) (6 3))))))
(check (equal *hanks*
              '((1 :name "BANRA NO ME" :short "ME" :kanji "万朶の眼" :r 3.0 :life 240)
                (2 :name "HAGANE NO YOROI" :short "HAGANE" :kanji "刃金のよろい" :r 2.0 :rise 16 :dmg 90 :guard 24 :after 20)
                (3 :name "KOKUSA NO HARAWATA" :short "KOKUSA" :kanji "黒砂の腸" :r 2.0 :life 240 :away 0.4 :period 60 :swirl 12 :dmg 40)
                (4 :name "ITETSUKU SHITONE" :short "SHITONE" :kanji "凍てつく褥" :r 2.0 :life 240 :dmg 70 :freeze 40 :frost 60)
                (5 :name "YAKENOHARA" :short "YAKENOHARA" :kanji "焼野原" :width 2.0 :max 10.0 :hits 2 :dmg 45 :life 150 :chip 0.12)
                (6 :name "YAMIYO NO HOSHIYO" :short "HOSHI" :kanji "闇夜の星よ" :r 3.5 :life 240 :reiatsu 30.0 :fs 15.0))))

;; 星 siphons (the user, 2026-09-29): inside her live star he gains nothing; his Reiatsu / flash-step gains go to her, his
;; Fighting Spirit (and every kit meter: combat.lisp SIPHON-OF) is lost; the drain gives her what it really took, capped
(multiple-value-bind (r fs aw sr sfs) (hit-gains 100 40 nil)
  (check (and (~= r (reiatsu-gain 100 40)) (~= fs (* 40 *fs-taken*)) (~= aw (awakening-gain 100 40 0)) (zerop sr) (zerop sfs))))
(multiple-value-bind (r fs aw sr sfs) (hit-gains 100 40 t)
  (check (and (zerop r) (zerop fs) (zerop aw) (~= sr (reiatsu-gain 100 40)) (~= sfs (* 40 *fs-taken*)) (plusp sr) (plusp sfs))))
(multiple-value-bind (his hers) (gauge-move 50.0 0.5 20.0 100.0) (check (and (~= his 49.5) (~= hers 20.5))))
(multiple-value-bind (his hers) (gauge-move 0.2 0.5 20.0 100.0) (check (and (~= his 0.0) (~= hers 20.2))))   ; what it took
(multiple-value-bind (his hers) (gauge-move 50.0 0.5 99.8 100.0) (check (and (~= his 49.5) (~= hers 100.0))))  ; capped
(check (every (lambda (f) (eq 'senju-siphon (kit-hook (kit :senjumaru f) :siphon))) '(:base :tsuji1 :tsuji6)))
(check (every (lambda (cf) (or (eq (first cf) :senjumaru) (null (kit-hook (apply #'kit cf) :siphon)))) *forms*))

;; The reach matches the art (the user's playtests, 2026-09-29: first Senjumaru's, DUEL_SENJUMARU.md "Playtest: reach
;; matches the art"; then every character's J / K, docs/duel/DUEL_STRINGS.md §13): at a J / K link's hit frames what it strikes
;; with reaches the volume's far edge, where his hurt cylinder's near side may stand (an arc's r, a capsule's b + r): the
;; held weapon's tip (the rig's FK over the art files' own poses and bodies; radial for an arc, ahead for a capsule), the
;; fist / foot / sleeve of a strike that isn't the blade (*STRIKERS*), or Senjumaru's K prop's far end (*SJ-STRIKE-REACH*).
;; The Breaker's strike too (its clip 2: the grab is close, §14; it may fall short, never over).
;; Within 0.15 m either way for the J links and Senjumaru's K props; the other K links, and every link of the forms that play
;; another form's clip at another reach or blade (*REACH-ONE-SIDED*), may fall short (fire, ice, cloth and the ember line
;; carry them) but never pass the edge by more than 0.15 m. 片腕 KATAUDE is
;; the exception: the base clips at x0.7 with the broken cleaver (the ruined arm; pass the edge by up to 0.6 m, as before
;; the J cut). The host has no C: anim.lisp's float intrinsics as plain CL
(defmacro engine::f-max (a b) `(max ,a ,b))
(defmacro engine::f-mod (a b) `(mod ,a ,b))
(defmacro engine::f-sin (a) `(sin ,a))
(defmacro engine::f-cos (a) `(cos ,a))
(defmacro engine::f-wrap (a) `(let ((x ,a)) (- x (* 6.2831853f0 (floor (+ x 3.14159265f0) 6.2831853f0)))))
(load (merge-pathnames "../engine/lisp/anim.lisp" *load-truename*))
(defparameter *strikers* '((:ya-tsuka :weapon-r 0.14) (:ke-kick . :foot-r) (:ke-b-hook . :hand-l) (:ic-q1 :weapon-l -0.90)
                           (:ic-q2 :weapon-l -0.90) (:ic-cross-j :weapon-l -0.90) (:ru-palm . :hand-l)
                           (:ya-ikkotsu . :hand-r) (:ke-shoulder . :shoulder-l) (:ru-hainawa . :hand-l) (:sj-saidan . :hand-r)
                           (:ke-a-q1 . :hand-l) (:ke-a-q2 . :hand-l) (:ke-a-f1 . :hand-l) (:ke-a-f2 . :hand-l) (:ke-a-spin . :foot-r))
  "Clip -> what strikes when it isn't the held weapon's tip: a joint (clip . joint), or a point down a joint's -Y
(clip joint y): Yamamoto's J3 TSUKABI, the pommel at :weapon-r y +0.14 (DUEL_YAMA_TYBW §8); Ichigo's Shikai J, the short blade held forward in the left fist, its tip at :weapon-l y -0.90
(DUEL_ICHIGO_TYBW §3.1).")
(defparameter *reach-one-sided* '((:kenpachi :nozarashi) (:kenpachi :bankai) (:rukia :zero)))   ; (Yamamoto's East / West: their
                                                                 ; own clips, both ways since DUEL_YAMA_TYBW §3.3)
(let ((bodies nil) (weapons nil) (strike nil) (points nil) (butt 0.0) (grips nil))
  (dolist (art '("yama" "ken" "rukia" "ichigo" "senjumaru" "lille" "barro" "hisagi"))
    (with-open-file (in (merge-pathnames (format nil "../duel/lisp/~a-art.lisp" art) *load-truename*))
      (let ((*package* (find-package :duel)))
        (loop for form = (read in nil in) until (eq form in)
              when (consp form)
                do (case (first form)
                     ((defpose defclip defstrike) (eval form))
                     (defun (when (eq (second form) 'sj-okobo-props) (eval form)))
                     (defparameter (case (second form)
                                     ((*sj-strike-reach* *hs-strike-reach*)   ; (Hisagi's thrown sickle: its drawn reach)
                                      (setf strike (append strike (eval (third form)))))
                                     (*hs-grip* (setf grips (eval (third form))))            ; (Hisagi's J short grip)
                                     (*lb-strike-points* (setf points (eval (third form))))   ; Lille: the plank, the
                                     (*lb-butt* (setf butt (eval (third form))))           ; wing / arm tips
                                     (*br-w-stretch* (eval form))                           ; (Lille II's whips, R5)
                                     (*br-squash* (eval form))                              ; (his squash, R8)
                                     ((*lb-wall-jl* *lb-wall-owl*) (eval form))))           ; (his wing wall)
                     (defbody (push (cons (second form) (third form)) bodies))
                     (defweapon (push (cons (second form) (getf (third form) :length)) weapons)))))))
  (let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (v (make-f32 3))
        (min-hurt (loop for (nil . b) in bodies minimize (getf b :hurt-r))) (max-hurt (loop for (nil . b) in bodies maximize (getf b :hurt-r))))
    ;; J is close (the J cut): the chase and a lunge stop at *LUNGE-STOP*, outside any two hurt cylinders' push-apart, and
    ;; every J follow-up's chase goal is inside its reach + the thinnest hurt radius (it connects)
    (check (> *lunge-stop* (* 2 max-hurt)))
    (dolist (cf (remove-if (lambda (cf) (and (eq (first cf) :barro) (trace-form-p cf))) *forms*))   ; (Lille II's stance EN:
      (let* ((k (apply #'kit cf)) (b (cdr (assoc (kit-body k) bodies)))                         ;  hitscan lines, v3)
             (b (or b (cdr (assoc (first cf) bodies))))                  ; (a body variant: the rig of its character)
             (props (if (eq (first cf) :senjumaru) (sj-okobo-props) (and (getf b :props) (apply #'make-rig-proportions (getf b :props)))))
             (wlen (cdr (assoc (kit-weapon k) weapons))))
        (dolist (lm (append (remove-if (lambda (l) (or (zerop (length (mv-hits (first l))))   ; (EN's traces; Hisagi's
                                                       (getf *hs-r-clip-stand-ins* (mv-clip (first l)))   ; B4c stand-ins;
                                                       (hw-seg (svref (mv-hits (first l)) 0))))   ;  pulls: a :seg-fn
                                       (link-moves k))                                           ;  window, its cast check)
                            (let ((br (kit-command-move k :breaker))) (and br (list (list br :breaker))))))
                                                               ; (the stance's HOSHA / TAISHA: line hits from the muzzle, §23.1)
          (let* ((mv (first lm)) (hw (svref (mv-hits mv) 0)) (vol (first (hw-vols hw))) (cap (> (aref vol 0) 0.5))
                 (edge (if cap (+ (aref vol 2) (aref vol 4)) (aref vol 1)))
                 (clip (kit-move-clip k (if (eq (second lm) :breaker) (mv-clip-2 mv) (mv-clip mv))))   ; (the Breaker's strike:
                                                                                         ; its clip 2; the form's :clip-map)
                 (point (second (assoc clip points)))                ; Lille's: :weapon (the plank) or a joint
                 (se (cdr (assoc clip *strikers*)))                 ; (joint or (joint y))
                 (striker (or (if (consp se) (first se) se) (and point (not (eq point :weapon)) point)))
                 (sy (if (consp se) (second se) 0.0))
                 (grip (or (second (assoc clip grips)) 0.0))   ; (Hisagi's J: the rod slid back through his fist, §21.4)
                 (art (or (third (assoc clip strike))
                          (loop for sf from (hw-from hw) below (hw-to hw)
                                maximize (progn
                                           (clip-sample! pose (find-clip clip) (/ (* sf (mv-clip-speed mv)) 60.0))
                                           (pose-fk! jm pose 0f0 0f0 0f0 0f0 (f32 (getf b :scale)) (f32 (deg (getf b :hunch 0))) props)
                                           (if striker                            ; (yaw 0 faces -Z)
                                               (joint-point! v jm (joint-index striker) 0f0 (f32 sy) 0f0)
                                               (joint-point! v jm (ji :weapon-r) 0f0 0f0 (f32 (if (eq point :weapon) butt (- grip wlen)))))
                                           (if cap (- (aref v 2)) (sqrt (+ (expt (aref v 0) 2) (expt (aref v 2) 2))))))))
                 (d (- art edge)))
            (when (eq (mv-kind mv) :quick)
              (check (<= (max *lunge-stop* (- (mv-reach mv) *chase-margin*)) (- (+ (mv-reach mv) min-hurt) 0.02))))
            (check (or (if (equal cf '(:kenpachi :kataude))
                           (<= d 0.6)
                           (and (<= d 0.15)
                                (or (>= d -0.15)
                                    (and (not (assoc clip strike))   ; (her K props: both ways)
                                         (or (member cf *reach-one-sided* :test #'equal) (member (mv-kind mv) '(:flash :breaker)))))))
                       (format t "~a ~a: the volume ends ~,2f m, the art ~,2f m~%" (second cf) (mv-name mv) edge art)))))))))

;; Lille II's own clips (the art batch, DUEL_LILLE_V2 §12; the art evaluated above): each lasts its move (S + A + R, its :s
;; mark on S), JILLIEL's and the owl's; the recall strings' beats are their moves' line frames (BR-RC-SHOT / BR-BEAM-SHOT),
;; and on each the firing tip (JILLIEL's wing: the rig's hand; the owl's claw) points at him (>= 1.2 m ahead, within 0.4 m
;; of his line, the owl's 0.5); the finisher (裁き f36) in NIJUSHI-KO's ring the frame before (each wing >= 1 m aside), the
;; owl's both claws thrown at him on it
(let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (v (make-f32 3))
      (pj (make-rig-proportions :arms 2.6)) (po (make-rig-proportions :arms 2.2 :legs 1.5))
      (beats '((:br-rc0 (6 3)) (:br-rc1 (6 1) (16 2)) (:br-rc2 (6 1) (14 2) (22 1) (32 3)) (:br-rc3 (6 1) (12 2) (18 1) (24 2) (36 4)))))
  (flet ((tip (clip frame joint props)
           (clip-sample! pose (find-clip clip) (/ frame 60.0))
           (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 props)
           (joint-point! v jm (joint-index joint) 0f0 0f0 0f0)
           (values (aref v 0) (- (aref v 2)))))
    (dolist (row '((:br-recall :br-recall :br-o-recall) (:br-rc0 :br-rc0 :br-o-rc0) (:br-rc1 :br-rc1 :br-o-rc1)
                   (:br-rc2 :br-rc2 :br-o-rc2) (:br-rc3 :br-rc3 :br-o-rc3) (:br-rc4 :br-rc4 :br-o-rc4) (:br-to-en :br-to-en :br-o-to-en)))
      (destructuring-bind (move jclip oclip) row
        (let ((mv (find-move move)))
          (check (eq (or jclip :lb-w-tenshin) (mv-clip mv)))
          (check (eq oclip (kit-move-clip (kit :barro :shin-kin) (mv-clip mv))))
          (check (~= 1.0 (mv-clip-speed mv)))
          (dolist (clip (remove nil (list jclip oclip)))
            (check (or (and (= (round (* 60 (clip-dur (find-clip clip))))   ; (the volley as the owl's SP2, v3 R3: its R +
                                   (+ (mv-s mv) (mv-a mv) (mv-r mv)          ;  *BR-SP2-SLOW-R*, the clip's last pose held)
                                      (if (member move '(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)) (- *br-sp2-slow-r*) 0)))
                            (= (round (* 60 (clip-mark clip :s))) (mv-s mv)))
                       (format t "~a: ~,1f f, its move ~a ~d f~%" clip (* 60 (clip-dur (find-clip clip))) move
                               (+ (mv-s mv) (mv-a mv) (mv-r mv)))))))))
    (dolist (row beats)
      (destructuring-bind (move &rest bs) row
        (let ((mv (find-move move)) (oclip (intern (format nil "BR-O-~a" (subseq (symbol-name move) 3)) :keyword)))
          (check (equal (mapcar #'first bs) (loop for (fr fn) in (mv-on-frame mv) when (member fn '(br-rc-shot br-beam-shot)) collect fr)))
          (loop for (fr kind) in bs
                do (if (= kind 4)
                       (dolist (j '(:hand-r :hand-l))
                         (multiple-value-bind (x ahead) (tip move (1- fr) j pj)
                           (declare (ignore ahead))
                           (check (or (>= (* x (if (eq j :hand-r) 1 -1)) 1.0) (format t "~a f~d ~a: ~,2f m aside~%" move (1- fr) j x))))
                         (multiple-value-bind (x ahead) (tip oclip fr j po)
                           (check (or (and (>= ahead 1.2) (<= (abs x) 0.5)) (format t "~a f~d ~a: ~,2f ahead ~,2f aside~%" oclip fr j ahead x)))))
                       (dolist (j (case kind (1 '(:hand-r)) (2 '(:hand-l)) (t '(:hand-r :hand-l))))
                         (multiple-value-bind (x ahead) (tip move fr j pj)
                           (check (or (and (>= ahead 1.2) (<= (abs x) 0.4)) (format t "~a f~d ~a: ~,2f ahead ~,2f aside~%" move fr j ahead x))))
                         (multiple-value-bind (x ahead) (tip oclip fr j po)
                           (check (or (and (>= ahead 1.2) (<= (abs x) 0.5)) (format t "~a f~d ~a: ~,2f ahead ~,2f aside~%" oclip fr j ahead x))))))))))))

;; Lille II's base stance strings (DUEL_LILLE_V3 §8.3, R3: 「架勢中的 JJ / KK / LL 都改成差異明顯的數段連擊」, 「最後一段 LL 會依據前面
;; J/K 有不同的動作模組」; the follow-ups three segments, §8.5): each of the fifteen segments plays its own clip :br-sk-<segment> at speed 1, lasting its move (S + A +
;; R, its :s mark on S); on every hit frame Diagramm's muzzle (1.75 m down the barrel, the :lille rig) is on his line (>= 1.6 m
;; ahead, within 0.15 m of it, 0.8-1.6 m up, the barrel within 8 deg of level and of straight at him), and the recoil follows
;; (the barrel >= 4 deg higher on one of the 2 frames after)
(let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (m (make-f32 3)) (g (make-f32 3)))
  (flet ((barrel (clip frame)
           (clip-sample! pose (find-clip clip) (/ frame 60.0))
           (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 nil)
           (joint-point! m jm (ji :weapon-r) 0f0 0f0 -1.75f0)
           (joint-point! g jm (ji :weapon-r) 0f0 0f0 0f0)
           (let ((dx (- (aref m 0) (aref g 0))) (dy (- (aref m 1) (aref g 1))) (df (- (aref g 2) (aref m 2))))
             (values (aref m 0) (aref m 1) (- (aref m 2)) (* (/ 180 pi) (atan dx df))
                     (* (/ 180 pi) (atan dy (sqrt (+ (* dx dx) (* df df)))))))))
    ;; (R15, DUEL_LILLE_V3 §19: the base stance's J / K melee, the gun-kata and the rifle swung: their clips' own checks
    ;; with the awakened openers' (the drawn reach); its L the charged snipe: the shot the move's :clip-2)
    ;; (R16, DUEL_LILLE_V3 §20: level 1's shot its own clip :br-sk-l1s at S 16, the level 2 / 3 copies :br-sk-l1 at S 8)
    (dolist (row '((:br-s-l1 :br-sk-l1s) (:br-s-l1-2 :br-sk-l1) (:br-s-l1-3 :br-sk-l1) (:br-s-jl1 :br-sk-jl1) (:br-s-jl2 :br-sk-jl2)
                   (:br-s-jl3 :br-sk-jl3) (:br-s-kl1 :br-sk-kl1) (:br-s-kl2 :br-sk-kl2) (:br-s-kl3 :br-sk-kl3)))
      (let* ((mv (find-move (first row))) (clip (second row)))
        (check (and (eq (or (mv-clip-2 mv) (mv-clip mv)) clip) (~= 1.0 (mv-clip-speed mv))))
        (check (or (and (= (round (* 60 (clip-dur (find-clip clip)))) (+ (mv-s mv) (mv-a mv) (mv-r mv)))
                        (= (round (* 60 (clip-mark clip :s))) (mv-s mv)))
                   (format t "~a: ~,1f f, its move ~d f~%" clip (* 60 (clip-dur (find-clip clip))) (+ (mv-s mv) (mv-a mv) (mv-r mv)))))
        (loop for w across (mv-hits mv)
              do (let ((fr (hw-from w)))
                   (multiple-value-bind (x y ahead az el) (barrel clip fr)
                     (check (or (and (>= ahead 1.6) (<= (abs x) 0.15) (<= 0.8 y 1.6) (<= (abs az) 8) (<= (abs el) 8)
                                     (>= (max (nth-value 4 (barrel clip (+ fr 1))) (nth-value 4 (barrel clip (+ fr 2)))) (+ el 4)))
                                (format t "~a f~d: the muzzle ~,2f aside ~,2f up ~,2f ahead, az ~,1f el ~,1f~%" clip fr x y ahead az el))))))))))

;; J is short, K long (the user, 2026-09-29, docs/duel/DUEL_STRINGS.md §13): in every form every K link reaches at least 0.5 m further
;; than any J link at the same position of the string (its reach + its lunge, :slide: Yamamoto's East K step in since
;; DUEL_YAMA_TYBW §3.3); 片腕's short K against the J floor (2026-10-06) excepted
(dolist (cf (remove-if (lambda (cf) (or (equal cf '(:kenpachi :kataude)) (and (eq (first cf) :barro) (trace-form-p cf)))) *forms*))
  (let ((lm (link-moves (apply #'kit cf))))   ; (Lille II's stance EN: hitscan lines, DUEL_LILLE_V3 R2)
    (loop for n from 1 to 3
          do (let ((j (loop for (m k) in lm when (and (= k n) (eq (mv-kind m) :quick)) maximize (+ (mv-reach m) (mv-slide m))))
                   (kk (loop for (m k) in lm when (and (= k n) (eq (mv-kind m) :flash)) minimize (+ (mv-reach m) (mv-slide m)))))
               (unless (and (equal cf '(:hisagi :bankai)) (= n 1))   ; (his K1 綁束 r 4.0 (B4d) vs J1's 4.5 annulus: the user's
                                                                     ;  §22.4 table, 2026-10-18 「可以」; links 2-3 hold)
                 (check (or (>= (- kk j) 0.5) (format t "~a link ~d: J ~,2f K ~,2f~%" cf n j kk))))))))

;;; ---------------------------------------------------------------- the guard lock (the user 2026-09-30, DUEL_DESIGN.md "Guard lock")
;; the lock holds a blockstun past its end while the attacker's move may still chain; it ends when that can't happen
(check (guard-locked-p :guard-hit nil 0 :move :main 20 10 3 12 t t))                ; frame 20 of 25: a chain may still start
(check (not (guard-locked-p :guard-hit nil 0 :move :main 24 10 3 12 t t)))          ; frame 24: the last chance was 24
(check (not (guard-locked-p :guard-hit nil 0 :move :main 20 10 3 12 t nil)))        ; nothing left to chain (a link 3)
(check (not (guard-locked-p :guard-hit nil 0 :move :main 20 10 3 12 nil t)))        ; his move never touched him
(check (not (guard-locked-p :guard-hit t 0 :idle nil 0 0 0 0 nil nil)))             ; a new neutral action ends it
(check (not (guard-locked-p :guard-hit t 0 :step nil 0 0 0 0 nil nil)))
;; a follow-up he started carries it through its startup and active frames, then its own window decides
(check (and (guard-locked-p :guard-hit t 0 :move :main 3 10 3 12 t nil) (guard-locked-p :guard-hit t 0 :move :hold 0 10 3 12 t nil)
            (guard-locked-p :guard-hit t 0 :move :main 12 10 3 12 t nil) (not (guard-locked-p :guard-hit t 0 :move :main 13 10 3 12 t nil))))
(check (and (guard-locked-p :guard-hit t 5 :idle nil 0 0 0 0 nil nil)                ; ORANGE's window: the next move is the chain
            (not (guard-locked-p :guard-hit t 5 :step nil 0 0 0 0 nil nil))))
;; the escapes: BLUE (and the awakening) leave blockstun, the lock with it; BLUE is still a blockstun press
(check (and (eq (burst-mode :guard-hit nil 0 nil) :blue) (not (guard-locked-p :idle t 5 :move :main 20 10 3 12 t t))))
(defun locked-free-steps (mv more)
  "FREE-STEPS with the guard lock (fighter.lisp STUN-STEP / FIGHTER-SYSTEM): MV blocked on its first hit, MORE = it may
chain. The lock is judged after each step (from the hit's next one: the hit lands after the fighters stepped) for the
defender's next step. Values: the attacker's and the defender's first actionable step."
  (let* ((enter (mv-enter mv)) (h (- (mv-first-hit mv) enter))
         (end (move-end-frame (mv-s mv) (mv-a mv) (mv-r mv) (mv-whiff mv) :block nil))
         (stun (blockstun (mv-total mv) (mv-first-hit mv) (mv-adv-block mv))) (lock nil))
    (values (loop for step from 1 when (>= (+ enter step) end) return (1+ step))
            (loop for step from (1+ h) for sf from 1
                  when (and (>= sf stun) (not lock)) return (1+ step)
                  do (let ((fr (+ enter step)))
                       (setf lock (guard-locked-p :guard-hit lock 0 (if (>= fr end) :idle :move) :main fr
                                                  (mv-s mv) (mv-a mv) (mv-r mv) t more)))))))
;; every blocked string link that goes on holds the defender to even (the attacker's move ends as he is freed); a link
;; that can't (link 3, no L link ready) keeps its block advantage: an ender is still punishable (Lille II's stance EN, its
;; hitscan strings: their own block below)
(dolist (cf (remove-if (lambda (cf) (and (eq (first cf) :barro) (trace-form-p cf))) *forms*))
  (let ((k (apply #'kit cf)))
    (dolist (row (link-moves k))
      (let ((m (first row)))
        (when (and (integerp (mv-adv-block m)) (plusp (length (mv-hits m))))
          (multiple-value-bind (att def) (locked-free-steps m (string-link-p k (mv-name m)))
            (check (or (= (- def att) (if (string-link-p k (mv-name m)) (max 0 (mv-adv-block m)) (mv-adv-block m)))
                       (format t "~a ~a: lock ~d, adv ~d~%" cf (mv-name m) (- def att) (mv-adv-block m))))))))))
(let* ((k (kit :yamamoto :base)) (j1 (kit-command-move k :q)) (j3 (kit-next k (mv-name (kit-next k (mv-name j1) :q)) :q)))
  (check (and (string-link-p k (mv-name j1)) (not (string-link-p k (mv-name j3))) (< (mv-adv-block j3) -2)
              (= (mv-adv-block j3) (multiple-value-bind (a d) (locked-free-steps j3 nil) (- d a))))))

;;; ================================================================ :x-axis lines: the CPU's threat perception (DUEL_LILLE §11.3,
;;; gap G1 / G8; ai.lisp SNAP-LIVE-P / SNAP-NEAR-P, AI-OPP-AIM, AI-OPP-REFLECT; the moves here are fakes, no kit has the flag yet)
(check (~= (line-dist 0.0 0.0 0.0 0.6 31.0 0.5 -10.0) 0.5))      ; yaw 0 faces -Z: 0.5 m beside the line
(check (~= (line-dist 0.0 0.0 0.0 0.6 31.0 0.0 2.0) 2.6))        ; behind him: from the muzzle (0.6 m ahead)
(check (~= (line-dist 0.0 0.0 0.0 0.6 31.0 0.0 -40.0) 9.0))      ; past the line's end
(check (~= (line-dist 1.0 1.0 (deg 90.0) 0.0 10.0 -4.0 1.0) 0.0)) ; yaw 90: faces -X
(let* ((shot (parse-move :x-fake '(:kind :sig :hold (34 64) :startup 4 :active 2 :recovery 26 :dmg 40
                                   :vol (:cap 0.6 31.0 1.2 0.25) :flags (:ranged :x-axis) :params (:lock 34))))
       (beam (parse-move :x-fake-beam '(:kind :sp :startup 60 :active 30 :recovery 40 :dmg 240
                                        :vol (:cap 0.6 31.0 1.4 1.2) :flags (:ranged :x-axis :reflectable)
                                        :params (:lock 40 :blast 60))))
       (sanren (parse-move :x-fake-3 '(:kind :sp :startup 12 :active 2 :recovery 24 :dmg 30 :vol (:cap 0.6 20.0 1.2 0.25)
                                       :hits ((12 14) (22 24) (32 34)) :flags (:ranged :x-axis))))
       (on (+ 0.4 *ai-line-margin*)))                            ; a 0.4 m hurt radius + the margin
  (check (= (move-lock shot) 34))
  (check (= (move-lock beam) 40))
  (check (null (move-lock sanren)))
  (check (= (move-active-end shot) 6))
  (check (= (move-active-end sanren) 34))                        ; every line of it, not S + A
  ;; on the line at 20 m (the generic reach test, 31 + 1.5, is true everywhere); 3 m beside it at 20 m: not
  (check (<= (x-line-gap shot 0.0 0.0 0.0 0.0 -20.0) on))
  (check (> (x-line-gap shot 0.0 0.0 0.0 3.0 -20.0) on))
  (check (~= (x-line-gap shot 0.0 0.0 0.0 0.5 -10.0) 0.25))      ; the line's own radius taken off
  (check (> (x-line-gap shot 0.0 0.0 0.0 0.0 1.5) on))           ; right behind him
  (check (<= (x-line-gap beam 0.0 0.0 0.0 1.6 -25.0) on))        ; the 1.2 m beam is wider
  ;; the aim: no threat before the lock (no guard through the aim), a threat from it; the shot until its window ends
  (check (not (x-live-p shot :hold 10 0)))
  (check (not (x-live-p shot :hold 33 0)))
  (check (x-live-p shot :hold 34 0))
  (check (x-live-p shot :hold 64 0))
  (check (x-live-p shot :main 40 5))
  (check (not (x-live-p shot :main 40 6)))
  ;; a wind-up with a :lock: from the lock to the window's end
  (check (not (x-live-p beam :main 0 39)))
  (check (x-live-p beam :main 0 40))
  (check (x-live-p beam :main 0 89))
  (check (not (x-live-p beam :main 0 90)))
  (check (x-live-p sanren :main 0 0))                            ; no lock: from frame 0, through its 3rd line
  (check (x-live-p sanren :main 0 33))
  (check (not (x-live-p sanren :main 0 34)))
  (check (not (x-live-p shot :aura 0 0))))
;; the Step off the line goes away from it, to the side he is on (the CPU's stick: TOWARD-STRAFE-DIR)
(loop for (ax az yaw px pz) in '((0.0 0.0 0.0 0.3 -10.0) (0.0 0.0 0.0 -0.3 -10.0) (2.0 1.0 0.7 -3.0 -4.5) (2.0 1.0 0.7 -2.0 -6.5)
                                 (-5.0 3.0 -2.5 0.5 -1.0) (-5.0 3.0 -2.5 -1.0 0.0))
      do (let* ((st (line-off-strafe ax az yaw px pz ax az))
                (fx (fwd-x (float yaw 1f0))) (fz (fwd-z (float yaw 1f0)))
                (al (+ (* (- px ax) fx) (* (- pz az) fz))) (lx (- px ax (* al fx))) (lz (- pz az (* al fz))))
           (multiple-value-bind (dx dz) (toward-strafe-dir 0.0 st px pz ax az)
             (check (plusp (+ (* dx lx) (* dz lz)))))))
;; chances read off the opponent's kit, by difficulty (EASY <= NORMAL <= HARD; :opp-reflect 0.3 -> 0.1 / 0.3 / 0.5)
(check (~= (opp-chance 0.3 :easy) 0.1))
(check (~= (opp-chance 0.3 :normal) 0.3))
(check (~= (opp-chance 0.3 :hard) 0.5))
(check (= (opp-chance 0.6 :hard) 1.0))
(check (<= (opp-chance 0.25 :easy) (opp-chance 0.25 :normal) (opp-chance 0.25 :hard)))
;; the reflect's timing (a blast at f60): a guard pressed at f52 is 8 f old there (2-10: DUEL_LILLE §6.3), a Hoho at f50
;; (f48-f60); hands off just before; nothing after the blast
(check (null (reflect-action 45 60 t)))
(check (eq (reflect-action 46 60 t) :wait))
(check (eq (reflect-action 51 60 t) :wait))
(check (eq (reflect-action 52 60 t) :guard))
(check (<= 2 (- 60 (- 60 *ai-reflect-guard-lead*)) 10))
(check (eq (reflect-action 60 60 t) :guard))
(check (eq (reflect-action 61 60 t) :late))
(check (null (reflect-action 43 60 nil)))
(check (eq (reflect-action 44 60 nil) :wait))
(check (eq (reflect-action 50 60 nil) :hoho))
(check (<= 48 (- 60 *ai-reflect-hoho-lead*) 60))
(check (<= (- 60 *ai-reflect-hoho-lead*) (+ 60 0) (+ (- 60 *ai-reflect-hoho-lead*) *perfect-lead*)))   ; (it is perfect)
;; inert for the first five characters: no move has :x-axis / :reflectable, no form the keys :opp-aim / :opp-reflect /
;; :bankai-ok (Lille's forms have them: DUEL_LILLE §8, §11.3)
(dolist (cf (remove-if (lambda (c) (member c '(:lille :barro))) *forms* :key #'first))
  (let ((k (apply #'kit cf)))
    (check (null (kit-bankai-ok k)))
    (check (not (or (getf (kit-ai k) :opp-aim) (getf (kit-ai k) :opp-reflect))))
    (loop for m being the hash-values of (kit-moves k)
          do (check (not (intersection '(:x-axis :reflectable) (mv-flags m)))))))

;;; ================================================================ Lille Barro II, version 3 (docs/duel/DUEL_LILLE_V3.md, R1 / R2, 2026-10-10)
(let* ((b (kit :barro :base)) (m (kit :barro :jilliel-kin)) (r (kit :barro :jilliel)) (om (kit :barro :shin-kin)) (or* (kit :barro :shin)))
  ;; his kits share no move with the old Lille (every move his: BR-; the art is shared, the sim isn't)
  (check (every (lambda (f) (loop for n being the hash-keys of (kit-moves (kit :barro f)) always (eql 0 (search "BR-" (symbol-name n)))))
                *br-forms*))
  (check (and (= 6 (position :barro *roster*)) (string= "LILLE" (kit-name b))))
  (check (equal *br-forms* '(:base :jilliel-kin :jilliel :shin-kin :shin)))
  (check (equal (mapcar #'first (gethash :barro *kits*)) (reverse *br-forms*)))
  ;; R1: U a plain guard in every form (no MUJITTAI), no revival (the owl is the burst's), the awakening into KIN
  (check (every (lambda (f) (let ((k (kit :barro f))) (and (null (kit-guard-to k)) (null (kit-passives k)) (null (kit-bankai-form k)))))
                *br-forms*))
  (check (eq :jilliel-kin (kit-awaken-form b)))
  (check (and (eq (kit-body r) :lille-jilliel) (eq (kit-body m) :lille-jilliel-kin) (eq (kit-body om) :lille-shin) (eq (kit-body or*) :lille-shin)))
  (check (and (~= (kit-mult om) 1.5) (~= (kit-mult or*) 1.5) (= 4 (kit-kikon-konpaku om)) (= 3 (kit-kikon-konpaku m))))
  ;; §29 (2026-10-15): the owl's stance K / KL x their own (a move's :form-mult) in place of the owl's x; JILLIEL's untouched;
  ;; 裁きの光明 100. §30: the owl x1.5, its stance K x1.75 (46 -> 80.5, 66 -> 115.5: HIT-DAMAGE's ROUND to even), KL x2
  (flet ((dmg (k n) (let ((mv (kit-move k n))) (hit-damage (mv-dmg mv) (kit-atk-mods k 0 1.0 (getf (mv-params mv) :form-mult)) nil 1 nil))))
    (check (and (= 80 (dmg or* :br-oe-k1)) (= 116 (dmg or* :br-oe-k3)) (= 140 (dmg or* :br-oe-kl1)) (= 140 (dmg or* :br-oe-kl3))
                (= 22 (dmg or* :br-oe-j1)) (= 33 (dmg om :br-o-j1)) (= 120 (dmg om :br-o-kikon)) (= 46 (dmg r :br-e-k1)) (= 70 (dmg r :br-e-kl1))
                (null (getf (mv-params (kit-move r :br-e-k1)) :form-mult))))
    (check (= 100 (getf (mv-params (kit-move om :br-misuji)) :dmg))))
  ;; 萬物貫通 (V1)
  (check (and (= *br-x-guard* 40) (~= *br-x-chip* 0.30) (~= *br-x-len* 31.0)))
  ;; the forms' predicates and the burst owl's switch (R1: 「爆氣時會進入梟頭模式」; the base's burst stays plain)
  (check (and (br-awake-form-p :shin) (br-awake-form-p :jilliel-kin) (not (br-awake-form-p :base))
              (br-ranged-form-p :jilliel) (br-ranged-form-p :shin) (br-melee-form-p :shin-kin) (not (br-ranged-form-p :jilliel-kin))))
  (check (equal (list (br-owl-switch :jilliel-kin :white) (br-owl-switch :jilliel :blue) (br-owl-switch :shin-kin nil)
                      (br-owl-switch :shin nil) (br-owl-switch :shin-kin :orange) (br-owl-switch :jilliel-kin nil)
                      (br-owl-switch :base :white))
                '(:shin-kin :shin :jilliel-kin :jilliel nil nil nil)))
  ;; the special resource (R2, R3): the base's 3 pips, the wings' 8; L L +0 / +1 on a hit or a block (R3: +3 -> +1); J J's
  ;; gains halved (R3); one a line spent by the L L follow-ups, none: no follow-up
  (check (and (= 3 (br-ammo-cap :base)) (= 8 (br-ammo-cap :jilliel-kin)) (= 8 (br-ammo-cap :shin))))
  (check (equal (list (br-ammo-add 2 2 :base) (br-ammo-add 7 2 :jilliel) (br-ammo-add 1 -4 :shin-kin) (br-ammo-add 3 0 :jilliel-kin))
                '(3 8 0 3)))
  (check (equal (list (br-l-gain :hit 0) (br-l-gain :block 1) (br-l-gain nil 2) (br-l-gain :hit 2) (br-l-gain :block 2)) '(0 0 0 1 1)))
  (flet ((g (c role spent) (multiple-value-list (br-recover-gain c role spent))))
    (check (equal (g :hit :j nil) '(3.0 5.0)))
    (check (equal (g :block :j nil) '(1.5 2.5)))
    (check (equal (g :hit :jl t) '(13.0 20.0)))
    (check (equal (g :hit :jl nil) '(3.0 5.0)))
    (check (equal (g nil :j nil) '(0.0 0.0))))
  (check (equal (multiple-value-list (br-spend 3)) '(2 t)))
  (check (equal (multiple-value-list (br-spend 0)) '(0 nil)))
  (check (and (br-follow-ok-p 1) (not (br-follow-ok-p 0))))
  ;; the stance's three strings in every form (R2, R3): the moves, their links, their hits, reach, roles and prices
  (dolist (row '(("BR-S" :base :br-k-hiren-c) ("BR-E" :jilliel :br-w-nijushi-c) ("BR-OE" :shin :br-recall)))
    (destructuring-bind (pre form sp2) row
      (flet ((mv (s) (find-move (intern (format nil "~a-~a" pre s) :keyword)))
             (nm (s) (intern (format nil "~a-~a" pre s) :keyword))
             (ls () '("L1")))   ; (R10: the awakened L one charged dash; R15: the base's one charged snipe)
        (let ((k (kit :barro form)))
          (dolist (pair (append nil
                                '(("J1" :q "J2") ("J2" :q "J3") ("K1" :f "K2") ("K2" :f "K3")
                          ("J3" :lchain "JL1") ("JL1" :lchain "JL2") ("JL2" :lchain "JL3") ("K3" :lchain "KL1") ("KL1" :lchain "KL2")
                          ("KL2" :lchain "KL3"))))
            (destructuring-bind (from c to) pair (check (eq (kit-next k (nm from) c) (mv to)))))
          (check (and (null (kit-next k (nm "K1") :q)) (null (kit-next k (nm "J1") :f)) (null (kit-next k (nm "J3") :q))
                      (null (kit-next k (nm "K3") :f)) (null (kit-next k (nm (car (last (ls)))) :lchain)) (null (kit-next k (nm "JL3") :lchain))
                      (null (kit-next k (nm "KL3") :lchain)) (null (kit-next k (nm "J2") :lchain)) (null (kit-next k (nm "K2") :lchain))))
          ;; every J / K segment and their follow-ups that hit -> the form's charge-less SP2 (「任一段打中都能接」); not L
          (check (every (lambda (sg) (eq (kit-next k (nm sg) :sp2c) (find-move sp2))) '("J1" "J2" "J3" "JL1" "JL2" "JL3" "K1" "K2" "K3" "KL1" "KL2" "KL3")))
          (check (notany (lambda (sg) (kit-next k (nm sg) :sp2c)) (ls)))
          (dolist (s (append (ls) '("J1" "J2" "J3" "K1" "K2" "K3" "JL1" "JL2" "JL3" "KL1" "KL2" "KL3")))
            (let* ((m (mv s)) (far (member s '("JL1" "JL2" "JL3" "KL1" "KL2" "KL3") :test #'string=))
                   (n (cdr (assoc s '(("L1" . 1) ("L2" . 1) ("L3" . 1) ("J1" . 1) ("J2" . 1) ("J3" . 1) ("K1" . 1) ("K2" . 1) ("K3" . 1))
                                  :test #'string=))))
              ;; the openers: several plain hits, 4 m (no 萬物貫通: nothing spent); the follow-ups one 萬物貫通 line, 31 m
              ;; (R4, 「所有起手連段一律用近距離攻擊」: the awakened forms' openers melee strikes, each hit its drawn tip's reach
              ;; *BR-W-TIPS*, not :ranged, no line drawn; the base's 4 m shots)
              (check (and (= (length (mv-hits m)) (or n 1)) (eq (mv-tick m) 'br-s-tick)
                          (if (or far (and (string= pre "BR-S") (char= (char s 0) #\L)))   ; (R15: the base's L the snipe, J / K melee)
                              (and (every (lambda (w) (~= (if far *br-x-len* *br-s-near*) (aref (first (hw-vols w)) 2))) (mv-hits m))
                                   (= (length (mv-hits m)) (count 'br-shot-fire (mv-on-frame m) :key #'second)))
                              (and (null (member :ranged (mv-flags m))) (zerop (count 'br-shot-fire (mv-on-frame m) :key #'second))
                                   (if (char= (char s 0) #\L)   ; (R9: the awakened L a dash through him, :through, BR-W-DASH at S)
                                       (and (member :through (mv-flags m)) (eq 'br-w-dash (second (assoc (mv-s m) (mv-on-frame m))))
                                            (= (mv-a m) (+ 2 *br-w-dash-f*)))
                                       (equal (loop for w across (mv-hits m) collect (+ (aref (first (hw-vols w)) 2) (aref (first (hw-vols w)) 4)))
                                              (mapcar (lambda (x) (float x 1.0)) (cdr (assoc s (cdr (assoc pre *br-w-tips* :test #'string=)) :test #'string=)))))))
                          (eq (and far t) (and (every #'br-x-hit-p (mv-hits m)) t))))
              (check (eq (getf (mv-params m) :stance)
                         (cdr (assoc s '(("L1" . :l) ("L2" . :l) ("L3" . :l) ("J1" . :j) ("J2" . :j) ("J3" . :j) ("K1" . :k) ("K2" . :k)
                                         ("K3" . :k) ("JL1" . :jl) ("JL2" . :jl) ("JL3" . :jl)
                                         ("KL1" . :kl) ("KL2" . :kl) ("KL3" . :kl))
                                     :test #'string=))))
              (check (eq (second (assoc 0 (mv-on-frame m))) (if far 'br-s-spend 'br-s-start)))))
          (check (and (= (mv-dmg (mv "L1")) (if (string= pre "BR-S") *br-snipe-dmg-1* *br-w-cut-dmg*)) (= (mv-dmg (mv "K2")) *br-s-k-dmg*) (= (mv-dmg (mv "J1")) *br-s-j-dmg*)
                      (= (mv-dmg (mv "KL1")) *br-s-kl-dmg*) (= (mv-dmg (mv "JL2")) *br-s-jl-dmg*)))
          (if (string= pre "BR-S")
              (check (and (getf (mv-params (mv "L1")) :charged) (equal (mv-hold (mv "L1")) (list 0 *br-w-l-hold*))   ; (R15)
                          (eq 'br-s-snipe-release (mv-release (mv "L1"))) (null (gethash (nm "L2") *moves*))
                          (equal (mapcar (lambda (n) (mv-dmg (find-move n))) '(:br-s-l1 :br-s-l1-2 :br-s-l1-3))
                                 (list *br-snipe-dmg-1* *br-snipe-dmg-2* *br-snipe-dmg-3*))
                          (~= (aref (first (hw-vols (svref (mv-hits (find-move :br-s-l1-2)) 0))) 2) *br-snipe-len-2*)
                          (br-x-hit-p (svref (mv-hits (find-move :br-s-l1-3)) 0))
                          (not (br-x-hit-p (svref (mv-hits (find-move :br-s-l1-2)) 0)))))
              (check (and (getf (mv-params (mv "L1")) :dash) (equal (mv-hold (mv "L1")) (list 0 *br-w-l-hold*))
                          (null (gethash (nm "L2") *moves*)))))   ; (R10: held 3 levels; no L2 / L3)
          (check (every (lambda (sg) (getf (mv-params (mv sg)) :end)) '("J3" "K3" "JL3" "KL3")))
          (check (notany (lambda (sg) (getf (mv-params (mv sg)) :end)) '("JL1" "JL2" "KL1" "KL2")))   ; (3 segments, 「每段花 1，共 3」)
          (check (and (eq :quick (mv-kind (mv "J1"))) (eq :flash (mv-kind (mv "K1"))) (eq :sig (mv-kind (mv "KL1")))
                      (eq :sig (mv-kind (mv "JL1"))) (eq :sig (mv-kind (mv "L1")))))
          ;; 「最後一段 LL 會依據前面 J/K 有不同的動作模組」: the J route's follow-up and the K route's play different clips
          ;; (§8.5: every follow-up segment its own clip, none an opener's, each at its move's own frames: :clip-s = startup)
          (let ((fl '("JL1" "JL2" "JL3" "KL1" "KL2" "KL3")))
            (check (= 6 (length (remove-duplicates (mapcar (lambda (sg) (mv-clip (mv sg))) fl)))))
            (check (notany (lambda (sg) (member (mv-clip (mv sg)) (mapcar (lambda (o) (mv-clip (mv o))) (append (ls) '("J1" "J2" "J3" "K1" "K2" "K3")))))
                           fl))
            (check (every (lambda (sg) (= 1.0 (mv-clip-speed (mv sg)))) fl)))
          ;; every hit combos: within a move each hit before the last one's stun ends; a link's first hit before the stun of
          ;; the last hit of the move it follows (the link starts from its S + A)
          (dolist (s (append (ls) '("J1" "J2" "J3" "K1" "K2" "K3")))
            (let ((hs (mv-hits (mv s))))
              (loop for a from 0 below (1- (length hs))
                    do (let ((w (svref hs a)) (x (svref hs (1+ a))))
                         (check (or (< (- (hw-from x) (hw-from w)) (or (hw-stun w) (hitstun (hw-react w))))
                                    (format t "~a ~a: hit ~d -> ~d~%" pre s a (1+ a))))))))
          (dolist (pair (append nil
                                '(("J1" "J2") ("J2" "J3") ("J3" "JL1") ("JL1" "JL2") ("JL2" "JL3") ("K1" "K2") ("K2" "K3") ("K3" "KL1")
                                  ("KL1" "KL2") ("KL2" "KL3"))))
            (let* ((a (mv (first pair))) (n (mv (second pair))) (w (svref (mv-hits a) (1- (length (mv-hits a)))))
                   (gap (+ (- (+ (mv-s a) (mv-a a)) (hw-from w)) (- (mv-first-hit n) (mv-enter n))))
                   (stun (or (hw-stun w) (hitstun (hw-react w)))))
              (check (or (< gap stun) (format t "~a ~a -> ~a: the next hit ~d f after, the stun ~d~%" pre (first pair) (second pair) gap stun)))))
          ;; every J / K segment -> the charge-less SP2 combos too
          (dolist (from '("J1" "J2" "J3" "JL1" "JL2" "JL3" "K1" "K2" "K3" "KL1" "KL2" "KL3"))
            (let* ((a (mv from)) (n (find-move sp2)) (w (svref (mv-hits a) (1- (length (mv-hits a)))))
                   (first-hit (if (eq sp2 :br-recall) (+ *br-recall-f* -1 (mv-first-hit (find-move :br-rc0))) (- (mv-first-hit n) (mv-enter n))))
                   (gap (+ (- (+ (mv-s a) (mv-a a)) (hw-from w)) first-hit))
                   (stun (or (hw-stun w) (hitstun (hw-react w)))))
              (check (or (< gap stun) (format t "~a ~a -> SP2: ~d f, the stun ~d~%" pre from gap stun)))))))))
;; R4 (the user, 2026-10-11): 「架式 L 的動作太快了」: the awakened stances' L x *BR-W-L-SLOW* (startup 8 -> 12, every 8 -> 12 f,
;; L3 every 6 -> 9 f), the base's as it was; 「爆氣後的 K 沒辦法連 SP2」: the owl's own K links -> the charge-less volley on a hit
;; (:sp2c through BR-S-TICK), combo
(let ((b (kit :barro :base)) (om (kit :barro :shin-kin)) (or* (kit :barro :shin)))
  (declare (ignorable b))
  (check (and (~= *br-w-l-slow* 1.5) (= 12 (mv-s (find-move :br-e-l1))) (= 12 (mv-s (find-move :br-oe-l1))) (= *br-snipe-s1* (mv-s (find-move :br-s-l1))) (= 8 (mv-s (find-move :br-s-l1-2))) (= 8 (mv-s (find-move :br-s-l1-3)))))   ; (R16)
  (check (equal (loop for w across (mv-hits (find-move :br-e-l1)) collect (hw-from w)) '(12)))   ; (R7: one hit a press)
  (check (equal (loop for w across (mv-hits (find-move :br-s-l1)) collect (hw-from w)) (list *br-snipe-s1*)))   ; (R16: level 1's wind-up)
  (check (and (~= (hw-kb (svref (mv-hits (find-move :br-e-j1)) 0)) *br-w-kb*) (~= (hw-kb (svref (mv-hits (find-move :br-oe-k3)) 0)) *br-w-kb*)
              (~= (hw-kb (svref (mv-hits (find-move :br-s-j1)) 0)) *br-w-kb*)))   ; (the melee openers barely push: in reach all string; R15 the base's too)
  (dolist (k (list om or*))
    (dolist (nm '(:br-o-k1 :br-o-k2 :br-o-k2s :br-o-k3))
      (let* ((a (find-move nm)) (w (svref (mv-hits a) (1- (length (mv-hits a)))))
             (gap (+ (- (+ (mv-s a) (mv-a a)) (hw-from w)) *br-recall-f* -1 (mv-first-hit (find-move :br-rc0)))))
        (check (eq (kit-next k nm :sp2c) (find-move :br-recall)))
        (check (eq 'br-s-tick (mv-tick a)))
        (check (eql (mv-enter a) (first (find 'br-s-start (mv-on-frame a) :key #'second))))   ; (its entry frame resets the latch)
        (check (or (< gap (or (hw-stun w) (hitstun (hw-react w)))) (format t "~a -> the volley: ~d f~%" nm gap))))))
  (check (getf (mv-params (find-move :br-o-k3)) :end))
  ;; R5 (「架式 > L 只要沒打中就進入硬直」「就跟一般的 J / K 普攻一樣」): a whiffed stance L recovers as a J link (R + *WHIFF-EXTRA-J*;
  ;; BR-S-TICK starts the next L / L L link only after a contact)
  (dolist (pre '("BR-S" "BR-E" "BR-OE"))
    (dolist (sg '("L1"))   ; (R15: the base's one charged L too)
      (let ((m (find-move (intern (format nil "~a-~a" pre sg) :keyword))))
        (check (= (mv-whiff m) (+ (mv-r m) *br-s-l-whiff*))))))
  (check (= *br-s-l-whiff* *whiff-extra-j*))
  ;; R10 (「L 衝刺改成只能衝一次不能連接，但可以三階段續力…」): the awakened L held 0-60 f, levels at 20 / 40 f; by level the dash's
  ;; longest, its damage on the move's 16 and its specials
  (check (and (= 1 (br-w-l-level 0)) (= 1 (br-w-l-level 19)) (= 2 (br-w-l-level 20)) (= 3 (br-w-l-level 40)) (= 3 (br-w-l-level 60))))
  (check (and (equal *br-w-l-dash-max* '(6.0 8.0 10.0)) (equal *br-w-l-cuts* '(2 4 6)) (= *br-w-cut-dmg* 8) (= *br-w-cut-step* 3)
              (equal (mapcar (lambda (n) (* n *br-w-cut-dmg*)) *br-w-l-cuts*) '(16 32 48))   ; (R11: the R10 totals, as hits)
              (= *br-w-cut-dmg* (mv-dmg (find-move :br-e-l1))) (= *br-w-cut-dmg* (mv-dmg (find-move :br-oe-l1)))
              (fboundp 'br-w-cuts) (equal *br-w-l-gain* '(1 2 3))
              (null (kit-next (kit :barro :jilliel) :br-e-l1 :lchain)) (null (kit-next (kit :barro :shin) :br-oe-l1 :lchain))))
  ;; 「架式連段結束後要像 J/K 結尾一樣將對手推離初始起手勢的攻擊範圍」 (the user 2026-10-11): every stance string's last
  ;; segment is :end (BR-S-END-PUSH: out of its first segment's reach), the awakened L dash excepted (its own pass-through)
  (check (and (member :lille *roster*) (equal (playable-roster) (remove :lille *roster*)) (member :barro (playable-roster))))   ; (the old Lille retired, 2026-10-12)
  (check (br-k-order-p))   ; (R14: 「K 之後的 LL 傷害大於架式 K 又大於普通 K」)
  (check (fboundp 'br-s-end-push))
  (dolist (pre '("BR-S" "BR-E" "BR-OE"))
    (dolist (sg '("J3" "K3" "JL3" "KL3"))
      (check (getf (mv-params (find-move (intern (format nil "~a-~a" pre sg) :keyword))) :end)))
    (dolist (sg '("L1" "J1" "K1"))
      (check (plusp (mv-reach (find-move (intern (format nil "~a-~a" pre sg) :keyword)))))))
  (check (null (gethash :br-s-l2 *moves*)))   ; (R15)
  (check (null (kit-next (kit :barro :jilliel-kin) :br-w-k1 :sp2c))))   ; (JILLIEL's own K: no SP2 cancel, as before)
  ;; the base stance: L picks the strings; the Step and its J
  (dolist (s '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re))
    (check (equal (mapcar (lambda (c) (mv-name (kit-next b s c))) '(:kamae-l :kamae-j :kamae-k :kamae-sp1 :kamae-sp2 :kamae-step))
                  '(:br-s-l1 :br-s-j1 :br-s-k1 :br-k-sanren :br-k-hiren :br-k-dash))))
  (check (eq (kit-next b :br-k-dash :kamae-j) (find-move :br-s-j1)))
  (check (and (~= *br-kamae-dash* 5.0) (= *br-kamae-dash-f* 10) (= *br-kamae-back* 9)))   ; (R3: the fast Step)
  ;; R18 (the user, 2026-10-12, DUEL_LILLE_V3 §23): 「射擊的一瞬間會強制面對對手變成必中狀態。我不希望這樣」: the snipe's three
  ;; moves track nothing (the stance's J / K as before); 「續力狙擊時能透過 step 閃身保持續力並重新瞄準對手」: its Step (BR-SNIPE-STEP)
  ;; is the stance's, back in the charge (BR-KAMAE-BACK)
  ;; 「覺醒後的衝刺 L 也套用一樣的規則」: the awakened dash too; every charge takes Step (:step-branch: a one-hand flick a Step)
  (check (and (every (lambda (n) (zerop (mv-track (find-move n)))) '(:br-s-l1 :br-s-l1-2 :br-s-l1-3 :br-e-l1 :br-oe-l1))
              (every (lambda (n) (member :step-branch (mv-flags (find-move n)))) '(:br-s-l1 :br-s-l1-2 :br-s-l1-3 :br-e-l1 :br-oe-l1))
              (~= (mv-track (find-move :br-s-j1)) 720.0) (~= (mv-track (find-move :br-s-k1)) 720.0)
              (~= (mv-track (find-move :br-e-j1)) 720.0) (not (member :step-branch (mv-flags (find-move :br-s-j1))))
              (eq 'br-s-tick (mv-tick (find-move :br-s-l1))) (eq 'br-s-tick (mv-tick (find-move :br-e-l1))) (fboundp 'br-snipe-step)
              (equal (assoc 9 (mv-on-frame (find-move :br-k-dash))) '(9 br-kamae-back))
              (equal (mv-on-frame (find-move :br-w-charge-step)) (mv-on-frame (find-move :br-k-dash)))
              (null (mv-tick (find-move :br-w-charge-step))) (= (mv-total (find-move :br-w-charge-step)) (mv-total (find-move :br-k-dash)))))
  (check (and (eq (kit-l-after-k b) :br-kamae-k) (eq (kit-l-after-j b) :br-kamae-j)))
  ;; the awakened stance EN: L / J / K the strings; KIN's L from neutral or a link the plain turn (R3); EN's fast Step
  (check (equal (list (mv-name (kit-command-move r :q)) (mv-name (kit-command-move r :f)) (mv-name (kit-command-move r :sig)))
                '(:br-e-j1 :br-e-k1 :br-e-l1)))
  (check (equal (list (mv-name (kit-command-move or* :q)) (mv-name (kit-command-move or* :f)) (mv-name (kit-command-move or* :sig)))
                '(:br-oe-j1 :br-oe-k1 :br-oe-l1)))
  (check (and (eq :br-to-en (mv-name (kit-command-move m :sig))) (eq :br-to-en (mv-name (kit-command-move om :sig)))
              (eq (kit-l-after-k m) :br-to-en-l) (eq (kit-l-after-j m) :br-to-en-l) (eq (kit-l-after-k om) :br-to-en-l)
              (eq 'br-to-en-link-tick (mv-tick (find-move :br-to-en-l)))))
  (check (and (null (gethash :br-backstep *moves*)) (null (gethash :br-trompete *moves*)) (null (gethash :br-l-link *moves*))))
  (check (eq 'barro-step (getf (kit-hooks b) :step)))
  ;; the awakened J strings at the standard speed (R3, route :JN): J1 S 8 like the old Lille's; the base keeps V8's 6
  (check (and (= 8 (mv-s (find-move :br-w-j1))) (= 8 (mv-s (find-move :br-o-j1))) (= 6 (mv-s (find-move :br-j1)))))
  ;; SP1 by the count (R1; R3 halved), SP2 spends every special (R3)
  (check (equal (mapcar (lambda (n) (br-sp-tier n :jilliel-kin)) '(0 3 4 7 8)) '(0 0 1 1 2)))
  (check (equal (mapcar (lambda (n) (br-sp-tier n :base)) '(0 1 2 3)) '(0 0 1 2)))
  (check (equal (mapcar #'br-sp1-fs '(0 1 2)) '(9.0 18.0 35.0)))
  (check (equal (list (br-sp2-bonus 3 :base) (br-sp2-bonus 8 :jilliel) (br-sp2-bonus 8 :jilliel-kin) (br-sp2-bonus 8 :shin) (br-sp2-bonus 0 :base))
                '(120 200 200 0 0)))
  (check (equal (list (mv-name (kit-command-move b :sp2)) (mv-name (kit-command-move m :sp2)) (mv-name (kit-command-move r :sp2))
                      (mv-name (kit-command-move om :sp2)) (mv-name (kit-command-move or* :sp2)))
                '(:br-hiren :br-w-nijushi :br-w-nijushi :br-recall-s :br-recall-s)))
  (dolist (row '((:br-hiren nil) (:br-k-hiren :br-k-hiren-c) (:br-w-nijushi :br-w-nijushi-c)))
    (destructuring-bind (n c) row
      (let ((mv (find-move n)))
        (check (and (eq 'br-sp2-spend (second (assoc 0 (mv-on-frame mv)))) (= -30 (mv-adv-block mv))))
        (when c
          (let ((cm (find-move c)))
            (check (and (eq 'br-sp2-spend (second (assoc (mv-enter cm) (mv-on-frame cm)))) (= (mv-s cm) (mv-s mv))
                        (<= (- (mv-s cm) (mv-enter cm)) 2) (= (mv-dmg cm) (mv-dmg mv)) (= (mv-r cm) (mv-r mv)))))))))
  (check (and (= 42 (mv-r (find-move :br-k-hiren))) (= 50 (mv-r (find-move :br-w-nijushi))) (= 60 (mv-dmg (find-move :br-w-nijushi)))))
  (check (and (= (mv-s (find-move :br-recall-s)) *br-recall-charge*) (= (mv-s (find-move :br-recall)) *br-recall-f*)
              (eq 'br-recall-go (second (assoc 0 (mv-on-frame (find-move :br-recall-s)))))
              (assoc *br-recall-charge-fire* (mv-on-frame (find-move :br-recall-s)))
              (= *br-recall-charge-fire* (1- *br-recall-charge*))))
  (dolist (n '(:br-sanren :br-k-sanren :br-w-sanren :br-misuji))
    (check (eq 'br-sp1-fs-go (second (assoc 0 (mv-on-frame (find-move n)))))))
  ;; the wing armour (R1): awakened, his own attack, 4 wings (the owl 2); fewer, the Breaker, the Kikon, the base form: never
  (check (and (br-armor-p :jilliel-kin :quick :main 4) (br-armor-p :jilliel :sig :main 8) (br-armor-p :shin-kin :flash :main 2)
              (not (br-armor-p :jilliel-kin :quick :main 3)) (not (br-armor-p :shin :sp :main 1))
              (not (br-armor-p :jilliel-kin :breaker :main 8)) (not (br-armor-p :jilliel-kin :kikon :main 8))
              (not (br-armor-p :base :quick :main 3)) (not (br-armor-p :jilliel-kin :quick :hold 8))))
  (check (and (= 4 (br-armor-cost :jilliel)) (= 2 (br-armor-cost :shin-kin))))
  (check (eq 'barro-armor (getf (kit-hooks b) :armor)))
  (check (= 120 *br-owl-wing-every*))   ; (R3: a wing every 2 s)
  ;; the full volley (the owl's SP2, R3): the tiers by the wings, their damages, the strings, R + *BR-SP2-SLOW-R*
  (check (equal (mapcar #'br-recall-tier '(0 1 2 3 4 5 6 7 8)) '(0 1 1 2 2 3 3 3 4)))
  (check (equal (mapcar (lambda (tr) (reduce #'+ (br-recall-damage tr))) '(0 1 2 3 4)) '(30 70 160 300 480)))
  (loop for tr from 0 to 4
        do (let ((mv (find-move (br-recall-move tr))))
             (check (equal (map 'list #'hw-dmg (mv-hits mv)) (br-recall-damage tr)))
             (check (every #'br-x-hit-p (mv-hits mv)))
             (check (= (mv-r mv) (+ *br-sp2-slow-r* (nth tr '(24 24 24 26 30)))))
             (check (eq (kit-next om :br-recall (svref #(:rc0 :rc1 :rc2 :rc3 :rc4) tr)) mv))))
  (check (equal *br-owl-clip-map* (kit-clip-map om)))
;; R20 (the user, 2026-10-13): his stance strings' O ender (BR-S-O-ENDER, not the :ender flag: no generic push / chase on top
;; of BR-S-END-PUSH); the mirror match's P2 tint on his legs; AUTO GUARD ALWAYS guards what a guard stops
(check (and (fboundp 'br-s-o-ender)
            (every (lambda (n) (and (getf (mv-params (find-move n)) :end) (not (member :ender (mv-flags (find-move n))))))
                   '(:br-s-j3 :br-s-k3 :br-s-jl3 :br-s-kl3 :br-e-k3 :br-oe-kl3))))
;;; >>> BEGIN BARRO-CPU-TESTS: the checks of Lille II's own CPU's shipped values and pure BR-AI-* / BR-LEARN-* functions.
;;; A dream-rsi cell (docs/research/lille2-ai-drsi, DUEL_LILLE_V3 §22) may deliver this file and its rescore splices ONLY
;;; the lines between these two markers into the frozen test: they must still pin the cell's own shipped values; everything
;;; outside them (shared behaviour, rules, hooks, the other characters) stays frozen.
  ;; his CPU (dream-rsi b1a0): the base stance's pick by the distance, the EN window's plan, the charged L's levels, the burst
  (let ((k '(:recover-fs 40.0 :recover-bars 1 :j-share 0.3 :step 0.4 :far 7.0)))
    (check (eq :kamae-step (br-ai-stance-plan 0.1 1.5 2.3 3.0 100.0 3 k :threat t)))
    (check (eq :kamae-j (br-ai-stance-plan 0.1 1.5 2.3 3.0 100.0 3 k :threat t :combo t)))   ; (a combo: no Step)
    (check (eq :kamae-k (br-ai-stance-plan 0.9 1.5 2.3 3.0 100.0 3 k :combo t :from-k t)))
    (check (eq :kamae-k (br-ai-stance-plan 0.9 2.6 2.3 3.0 100.0 3 k :combo t)))
    (check (eq :kamae-j (br-ai-stance-plan 0.1 1.5 2.3 3.0 100.0 3 k)))   ; (no Step without a threat: r 0.1 < :j-share, J)
    (check (eq :kamae-k (br-ai-stance-plan 0.9 1.5 2.3 3.0 100.0 3 k)))   ; (in J's reach, past :j-share: K, the damage)
    (check (eq :kamae-j (br-ai-stance-plan 0.9 1.5 2.3 3.0 20.0 3 k)))
    (check (eq :kamae-j (br-ai-stance-plan 0.9 1.5 2.3 3.0 90.0 0 k)))
    (check (eq :kamae-j (br-ai-stance-plan 0.1 1.5 2.3 3.0 90.0 2 k)))
    (check (eq :kamae-k (br-ai-stance-plan 0.5 2.8 2.3 3.0 90.0 2 k)))
    (check (eq :kamae-l (br-ai-stance-plan 0.5 4.0 2.3 3.0 90.0 2 k)))
    (check (eq :kamae-l (br-ai-stance-plan 0.5 4.0 2.3 3.0 90.0 2 k :combo t)))
    (check (equal (list (br-ai-snipe-level 4.0 k) (br-ai-snipe-level 7.0 k) (br-ai-snipe-level 15.0 k)) '(2 3 3))))
  (check (equal *br-ai-hold* '(1 24 44)))
  (check (equal (mapcar #'br-ai-dash-level '(2.0 3.0 4.5 4.6 10.2 10.5)) '(nil 2 2 3 3 nil)))   ; (b1a1: level 2 inside 4.5 m)
  (destructuring-bind (l2 l3) *br-w-l-levels*   ; (the holds reach their levels)
    (check (and (< (first *br-ai-hold*) l2) (<= l2 (second *br-ai-hold*) l3) (<= l3 (third *br-ai-hold*) *br-w-l-hold*))))
  (let ((k '(:j-share 0.25)))
    (check (eq :q (br-ai-en-plan 0.1 1.5 2.2 3.3 k nil)))
    (check (eq :f (br-ai-en-plan 0.5 1.5 2.2 3.3 k nil)))
    (check (eq :f (br-ai-en-plan 0.1 3.0 2.2 3.3 k nil)))
    (check (eq :sig (br-ai-en-plan 0.1 5.0 2.2 3.3 k nil)))
    (check (eq :sig (br-ai-en-plan 0.1 9.0 2.2 3.3 k t)))
    (check (eq :step (br-ai-en-plan 0.1 12.0 2.2 3.3 k nil)))
    (check (null (br-ai-en-plan 0.1 12.0 2.2 3.3 k t))))
  (dolist (f *br-forms*)   ; (every form's CPU knows the stance's calls: :follow, :sp2-at, :sp2, :charge; the L held, the reflex)
    (let ((ai (kit-ai (kit :barro f))))
      (check (getf (getf ai :stance) :sp2-at))
      (check (getf (getf ai :stance) :charge))
      (check (eq (getf ai :sig-hold) 'br-ai-sig-hold))
      (check (eq (getf ai :reflex) 'br-ai-reflex))))
  (check (getf (kit-ai (kit :barro :base)) :far-snipe))
  (check (and (getf (kit-ai (kit :barro :jilliel-kin)) :far-dash) (getf (kit-ai (kit :barro :shin-kin)) :far-dash)))
  (check (= 1 (br-ai-sig-hold (kit :barro :jilliel-kin) 5.0)))   ; (no fighter, no brain: a tap)
  (let ((k '(:p 0.5 :wings 5 :in 6.0)))
    (check (br-ai-burst-p 0.1 5 70.0 4.0 k :normal))
    (check (not (br-ai-burst-p 0.2 4 70.0 4.0 k :normal)))
    (check (not (br-ai-burst-p 0.2 5 60.0 4.0 k :normal)))
    (check (not (br-ai-burst-p 0.2 5 70.0 7.0 k :normal)))
    (check (not (br-ai-burst-p 0.6 5 70.0 4.0 k :normal)))
    (check (br-ai-burst-p 0.6 5 70.0 4.0 k :hard)))
  (check (equal *br-ai-diff* '(:easy 0.2 :normal 0.3 :hard 1.5)))   ; (NORMAL x0.3: a fair NORMAL, DUEL_LILLE_V3 §22's band; b1a1)
  (check (let ((c (mapcar (lambda (d) (br-ai-chance 0.6 d)) '(:easy :normal :hard))))
           (and (< (abs (- (first c) 0.12)) 1e-6) (< (abs (- (second c) 0.18)) 1e-6) (< (abs (- (third c) 0.9)) 1e-6))))
  (check (= 1.0 (br-ai-chance 0.9 :hard)))   ; (at most 1)
  (check (equal *br-ai-anti-breaker* '(:easy 0.1 :normal 0.3 :hard 1.0)))
  (dolist (f *br-forms*) (check (getf (getf (kit-ai (kit :barro f)) :stance) :punish)))
  (check (equal (list (br-learn-kamae-plan :step :kamae-k t) (br-learn-kamae-plan :attack :kamae-k t)
                      (br-learn-kamae-plan :hoho :kamae-k nil) (br-learn-kamae-plan :guard :kamae-k t) (br-learn-kamae-plan nil :kamae-k t))
                '(:kamae-j :kamae-step :kamae-l :kamae-k :kamae-k)))
  (let ((sp (learn-kit-spec :barro)))
    (check (and (equalp (getf sp :situations) #(:shot :charge)) (eq (getf sp :step) 'br-learn-step))))
  ;; (the integration, DUEL_LILLE_V3 §22.3) :charge's read: a guard -> level 3, a Hoho / an attack -> a tap, a Step / backing
  ;; off -> the level kept and its Step re-aims (a charge only)
  (check (equal (loop for r in '(:guard :hoho :attack :step :back :take nil)
                      collect (multiple-value-list (br-learn-charge-plan r 2)))
                '((3 nil) (1 nil) (1 nil) (2 t) (2 t) (2 nil) (2 nil))))
  (check (equal (multiple-value-list (br-learn-charge-plan :step 1)) '(1 nil)))
  (check (and (fboundp 'br-ai-restep) (fboundp 'br-charge-step-go) (eq 'br-assist-combo (getf (kit-ai (kit :barro :jilliel-kin)) :assist-combo))))
  ;; (dream-rsi b1a1) the stance call with the wing reserve, the Step-in answer, the stance's exit, the knobs by difficulty
  (let ((kin '(:follow 0.6 :sp2-at 0 :sp2 0.6 :keep 4 :sp2-all 8))
        (owl '(:follow 0.7 :sp2-at 3 :sp2 0.9 :keep 2 :sp2-all 5 :volley-at 8)))
    (check (eq :go (br-ai-call 0.1 6 3 nil t nil kin :hard)))          ; (a line above the reserve)
    (check (null (br-ai-call 0.1 4 3 nil t nil kin :hard)))           ; (never below it: the armour's price)
    (check (null (br-ai-call 0.1 5 3 t nil nil kin :hard)))           ; (SP2 would spend the reserve)
    (check (eq :sp2 (br-ai-call 0.1 3 3 t nil nil kin :hard)))        ; (short of it: SP2 cashes what is left)
    (check (eq :go (br-ai-call 0.1 8 3 t t nil kin :hard)))           ; (full, a line to pay: the line first (70 a wing))
    (check (eq :sp2 (br-ai-call 0.1 8 3 t nil nil kin :hard)))        ; (full, no line left: SP2 at :sp2-all)
    (check (null (br-ai-call 0.1 3 1 t nil nil kin :hard)))           ; (SP2 needs 2 bars)
    (check (eq :sp2 (br-ai-call 0.1 8 2 t t t owl :hard)))            ; (the owl's full volley at once)
    (check (eq :go (br-ai-call 0.1 4 2 t t t owl :hard)))             ; (the owl: a line above its 2-wing reserve)
    (check (null (br-ai-call 0.95 6 3 nil t nil kin :normal)))        ; (the chances x the difficulty)
    (check (eq :go (br-ai-call 0.1 2 3 nil t nil '(:follow 0.6) :hard))))   ; (the base: no reserve)
  (check (eq :go (br-ai-step-in-plan 0 8 5 0.2 3.5 1.8)))      ; (lands at his Step's f13, him 1.1 m off)
  (check (eq :wait (br-ai-step-in-plan 0 8 1 0.2 3.5 1.8)))    ; (would land in his iframes: wait)
  (check (null (br-ai-step-in-plan 0 8 5 0.05 3.5 1.8)))       ; (not coming in)
  (check (null (br-ai-step-in-plan 8 8 5 0.2 3.5 1.8)))        ; (too late: his J comes first)
  (check (null (br-ai-step-in-plan 0 8 5 0.2 5.0 1.8)))        ; (he lands out of our J1's reach)
  (check (equal (list (br-ai-exit-plan 3.5 5 4 2) (br-ai-exit-plan 2.8 5 4 nil) (br-ai-exit-plan 3.5 2 4 2)
                      (br-ai-exit-plan 7.0 2 4 3))
                '(:sig :back :back nil)))
  (check (equal *br-ai-turn-p* '(:easy 0.2 :normal 0.3 :hard 1.0)))
  (check (equal *br-ai-kikon-p* '(:easy 0.05 :normal 0.15 :hard 1.0)))
  (check (equal *br-ai-unguard-p* '(:easy 0.0 :normal 0.1 :hard 1.0)))
  (check (equal *br-ai-step-in-p* '(:easy 0.03 :normal 0.08 :hard 1.0)))
  (check (equal *br-ai-exit-p* '(:easy 0.05 :normal 0.15 :hard 1.0)))   ; (round 2 b1a1 0.35; combo b1a2+b2a0 0.15 back: NORMAL band)
  (check (equal *br-ai-kite-p* '(:easy 0.01 :normal 0.03 :hard 0.8)))
  (check (equal *br-ai-let-go-p* '(:easy 0.1 :normal 0.3 :hard 1.0)))
  (dolist (p (list *br-ai-turn-p* *br-ai-kikon-p* *br-ai-unguard-p* *br-ai-step-in-p* *br-ai-exit-p* *br-ai-kite-p* *br-ai-let-go-p*
                   (getf (getf (kit-ai (kit :barro :jilliel-kin)) :far-dash) :p)))   ; (EASY <= NORMAL <= HARD)
    (check (<= (getf p :easy) (getf p :normal) (getf p :hard))))
  (dolist (f *br-forms*)   ; (no neutral Kikon: BR-AI-KIKON on openings only)
    (check (= 0.0 (getf (kit-ai (kit :barro f)) :kikon-range))))
  (check (equal (mapcar (lambda (f) (getf (getf (kit-ai (kit :barro f)) :stance) :keep 0)) *br-forms*) '(0 4 4 2 2)))
  (check (equal (mapcar (lambda (f) (br-armor-cost f)) '(:jilliel :shin)) '(4 2)))   ; (the reserve is the armour's price)
  (check (equal *br-ai-let-go* '(12 20)))   ; (the charge let go: the snipe held into level 2 from 12 f)
  (check (equal (list (br-ai-let-go-p 5 t t) (br-ai-let-go-p 15 t t) (br-ai-let-go-p 25 t t) (br-ai-let-go-p 15 nil t)
                      (br-ai-let-go-p 25 t nil))
                '(t nil t t nil)))
  (check (equal (getf (getf (kit-ai (kit :barro :jilliel-kin)) :far-dash) :p) '(:easy 0.05 :normal 0.15 :hard 1.0)))   ; (round 2 b1a1)
  (check (equal (getf (getf (kit-ai (kit :barro :shin-kin)) :far-dash) :p) '(:easy 0.05 :normal 0.15 :hard 1.0)))
  ;; (dream-rsi b1a2) every attack-state link that hit -> L -> the stance (the base's J the gun-kata, no K2s bridge), the
  ;; base stance's cash-out at the pips' cap
  (dolist (f '(:jilliel-kin :shin-kin))
    (check (= 1.0 (getf (kit-ai (kit :barro f)) :l-after-j) (getf (kit-ai (kit :barro f)) :l-after-k))))
  (dolist (f (rest *br-forms*))   ; (every awakened charge, line and cash-out at HARD: 0.7 x1.5; NORMAL 0.21)
    (let ((k (getf (kit-ai (kit :barro f)) :stance)))
      (check (and (= 0.7 (getf k :charge)) (= 0.7 (getf k :follow)) (= 1.0 (br-ai-chance (getf k :charge) :hard))))))
  (check (equal (mapcar (lambda (f) (getf (getf (kit-ai (kit :barro f)) :stance) :sp2)) (rest *br-forms*)) '(0.7 0.7 0.9 0.9)))
  ;; (dream-rsi b2a0, combined onto b1a2) the never-awakened base form's own plan: every J link that hit -> its K link (K2s)
  ;; -> L -> the rifle (the stance K string, whose L L lines spend the pips), never the gun-kata off a confirm; the base's
  ;; chances as its own tables (EASY <= NORMAL <= HARD, HARD 1.0 as before); a failed charge roll the line's floor
  ;; (BR-AI-FLOOR-LEVEL, below); no stance K1 into a free man in J's reach (:j-share 1.0); no long neutral guard; the ladder
  (let ((ai (kit-ai (kit :barro :base))))
    (check (and (= 1.0 (getf ai :l-after-k)) (= 0.0 (getf ai :l-after-j)) (= 1.0 (getf ai :string-k))))
    (check (= 0.1 (getf ai :neutral-guard)))
    (check (equal (getf ai :far-snipe) '(:p (:easy 0.2 :normal 0.5 :hard 1.0) :in 4.5)))   ; (round 2 b1a2 4.5: the Step's shot)
    (let ((k (getf ai :stance)))
      (check (= 1.0 (getf k :j-share)))
      (check (equal (list (getf k :charge) (getf k :follow) (getf k :sp2))
                    '((:easy 0.2 :normal 0.5 :hard 1.0) (:easy 0.3 :normal 0.8 :hard 1.0) (:easy 0.3 :normal 0.6 :hard 1.0))))
      (dolist (p (list (getf k :charge) (getf k :follow) (getf k :sp2) (getf (getf ai :far-snipe) :p) *br-ai-ladder-p*))
        (check (<= (getf p :easy) (getf p :normal) (getf p :hard))))
      (check (equal (mapcar (lambda (d) (br-ai-p k :follow d)) '(:easy :normal :hard)) '(0.3 0.8 1.0)))))
  (check (< (abs (- (br-ai-p '(:follow 0.7) :follow :normal) 0.21)) 1e-6))   ; (a plain chance: x *BR-AI-DIFF*)
  (check (equal (list (br-ai-ladder-intent 0 3) (br-ai-ladder-intent 2 3) (br-ai-ladder-intent 3 3)) '(:zone :zone :pressure)))
  (check (equal *br-ai-ladder-p* '(:easy 0.3 :normal 0.6 :hard 1.0)))
  ;; (b2a0) the far snipe in sight only: facing him, his drift across the line small by the time the shot lands
  (check (and (= 0.6 *br-ai-sight-gap*) (= 38 *br-ai-sight-f*) (= 4 *br-ai-sight-k*)))
  (check (br-ai-sight-p 8.0 0.0 0.0 46))         ; (square, still)
  (check (br-ai-sight-p 8.0 0.04 0.005 46))      ; (0.32 + 0.23 m: in)
  (check (not (br-ai-sight-p 8.0 0.3 0.0 46)))   ; (2.4 m off his facing)
  (check (not (br-ai-sight-p 8.0 0.0 0.03 46)))  ; (strafing: 1.4 m by the shot)
  (check (not (br-ai-sight-p 8.0 0.0 -0.03 46))) ; (either way)
  (check (equal *br-ai-hoho-step-p* '(:easy 0.1 :normal 0.4 :hard 1.0)))
  (check (<= (getf *br-ai-hoho-step-p* :easy) (getf *br-ai-hoho-step-p* :normal) (getf *br-ai-hoho-step-p* :hard)))
  (check (equal *br-ai-cash-p* '(:easy 0.1 :normal 0.3 :hard 1.0)))
  (check (<= (getf *br-ai-cash-p* :easy) (getf *br-ai-cash-p* :normal) (getf *br-ai-cash-p* :hard)))
  (check (equal (list (br-ai-cash-plan :kamae-l 3 3 t 0.5 1.0) (br-ai-cash-plan :kamae-l 2 3 t 0.5 1.0)
                      (br-ai-cash-plan :kamae-l 3 3 nil 0.5 1.0) (br-ai-cash-plan :kamae-l 3 3 t 0.5 0.3)
                      (br-ai-cash-plan :kamae-k 3 3 t 0.5 1.0))
                '(:kamae-sp2 :kamae-l :kamae-l :kamae-l :kamae-k)))
  ;; (dream-rsi round 2 b1a0) the line: a charge held as a threat, released when the predicted line meets him (his perceived
  ;; offset + his lateral speed x the frames to the hit), at the highest level that still lands; the snipe never inside the
  ;; CPUs' threat envelope (its charge's reach + *AI-THREAT-MARGIN*); a charge starts only facing him
  (check (eq :lost (br-ai-line-call 2 2 0.0 0.0 -1.0 17 0.5 0.6 12.3 0 0.0)))     ; (him behind its start: a Hoho, a cross-up)
  (check (eq :hold (br-ai-line-call 1 2 0.0 0.0 8.0 17 0.5 0.6 12.3 5 31.0)))     ; (level 1: never on the line)
  (check (eq :fire (br-ai-line-call 2 2 0.1 0.0 8.0 17 0.5 0.6 12.3 20 31.0)))    ; (the target reached, on the line)
  (check (eq :hold (br-ai-line-call 2 2 1.0 0.0 8.0 17 0.5 0.6 12.3 20 31.0)))    ; (off it: he may walk back onto it)
  (check (eq :fire (br-ai-line-call 2 2 1.0 -0.05 8.0 17 0.5 0.6 12.3 20 31.0)))  ; (walking onto it: 1.0 - 0.85 at the hit)
  (check (eq :hold (br-ai-line-call 2 2 0.1 0.0 14.0 17 0.5 0.6 12.3 20 31.0)))   ; (past level 2's 12 m)
  (check (eq :hold (br-ai-line-call 2 3 0.0 0.0 8.0 17 0.5 0.6 12.3 20 31.0)))    ; (level 3 will land too: wait for it)
  (check (eq :fire (br-ai-line-call 2 3 0.0 0.02 8.0 17 0.5 0.6 12.3 20 31.0)))   ; (level 3 would find him off it: now)
  (check (eq :fire (br-ai-line-call 3 3 0.0 0.0 20.0 17 0.5 0.6 31.3 0 31.0)))
  (check (equal (list (br-ai-envelope-p 6.0 0.0 8) (br-ai-envelope-p 6.0 0.1 8) (br-ai-envelope-p 5.0 -0.1 8))
                '(nil t t)))   ; (*BR-S-NEAR* 4 + *AI-THREAT-MARGIN* 1.5, his closing over the perception delay)
  (check (= *br-ai-snipe-min* 6.0))   ; (the line's range, his back-offs' stop; the far window from 4.5 m since round 2 b1a2)
  (check (equal *br-ai-line-p* '(:easy 0.2 :normal 0.5 :hard 1.0)))
  (check (<= (getf *br-ai-line-p* :easy) (getf *br-ai-line-p* :normal) (getf *br-ai-line-p* :hard)))
  (check (and (= *br-ai-line-margin* 0.1) (= *br-ai-line-k* 6) (= *br-ai-face-max* 0.35)))
  ;; (dream-rsi round 2 b1a1) the line has a length: a failed charge roll takes the lowest level whose line reaches him (a
  ;; rule at every difficulty), never a tap from out of the tap's reach; the base form backs off to the far snipe's range
  (check (equal (list (br-ai-floor-level 3.0 4.3 12.3) (br-ai-floor-level 4.3 4.3 12.3) (br-ai-floor-level 6.0 4.3 12.3)
                      (br-ai-floor-level 12.3 4.3 12.3) (br-ai-floor-level 13.0 4.3 12.3))
                '(1 1 2 2 3)))
  (check (equal (list (br-ai-plan-level t 3 2) (br-ai-plan-level t 2 3) (br-ai-plan-level nil 3 2) (br-ai-plan-level nil 2 1))
                '(3 3 2 1)))   ; (charged: the plan, never under the floor; else the floor)
  (check (equal *br-ai-dash-floor* '(6.4 8.4)))
  (check (equal (mapcar #'br-ai-dash-floor '(3.0 6.4 7.0 8.4 9.0)) '(1 1 2 2 3)))
  (destructuring-bind (l1 l2 l3) *br-w-l-dash-max*   ; (each floor inside its level's dash + volume)
    (declare (ignore l3))
    (check (and (< (first *br-ai-dash-floor*) (+ l1 *br-w-dash-reach*)) (< (second *br-ai-dash-floor*) (+ l2 *br-w-dash-reach*)))))
  (check (= *br-ai-snipe-back* 0.5))
  (check (equal (list (br-ai-back-to :base 5.0) (br-ai-back-to :base 7.0) (br-ai-back-to :jilliel-kin 5.0) (br-ai-back-to :shin-kin 5.5))
                '(6.5 7.0 5.0 5.5)))
  (check (equal (getf (kit-ai (kit :barro :base)) :intents) '(:approach 1 :pressure 1 :zone 5 :defend 1)))   ; (the line's distance)
  ;; (dream-rsi round 2 b1a2) the charge back from its Step (re-aimed on him by the sim) goes at once from 2.5 m; the burst
  ;; kept for the owl (b0a1's piece); a Hoho reader read: a cash-out he answered makes the next wait for his commitment
  (check (= *br-ai-step-fire-min* 2.5))
  (check (equal *br-ai-keep-burst* '(:easy 0.2 :normal 0.5 :hard 1.0)))
  (check (<= (getf *br-ai-keep-burst* :easy) (getf *br-ai-keep-burst* :normal) (getf *br-ai-keep-burst* :hard)))
  (check (eq 'br-ai-keep-burst (getf (kit-ai (kit :barro :base)) :sp-ender)))
  (dolist (f '(:jilliel-kin :jilliel :shin-kin :shin))   ; (the awakened forms' ORANGE is the owl's entry: never vetoed)
    (check (null (getf (kit-ai (kit :barro f)) :sp-ender))))
  (check (not (member :keep-burst *kit-commands*)))   ; (the veto presses nothing: no form has the command)
  (check (equal *br-ai-cash-wary-p* '(:easy 0.0 :normal 0.3 :hard 1.0)))
  (check (<= (getf *br-ai-cash-wary-p* :easy) (getf *br-ai-cash-wary-p* :normal) (getf *br-ai-cash-wary-p* :hard)))
  (check (= *br-ai-cash-commit* 20))
  (check (equal (list (br-ai-cash-wary :kamae-sp2 0 0) (br-ai-cash-wary :kamae-sp2 1 0) (br-ai-cash-wary :kamae-sp2 1 19)
                      (br-ai-cash-wary :kamae-sp2 2 20) (br-ai-cash-wary :kamae-k 1 0) (br-ai-cash-wary :kamae-l 1 0))
                '(:kamae-sp2 :kamae-l :kamae-l :kamae-sp2 :kamae-k :kamae-l)))
  (let ((st (make-brs)))   ; (a fresh match: nothing read, no cash-out pending)
    (check (and (= -1 (brs-ai-cash-t st)) (zerop (brs-ai-cash-read st)) (null (brs-ai-stepped st)))))
;; (the user 2026-10-13: 「依據目前資源的多寡選擇不同的架式」, then 「只有閃步跟 SP 量表全滿才會使用架式 K」) the route by his resources: K by
;; default and with 3 spare; J only on a low flash step (< 30) or 0 Reiatsu bars; the base stance pick and EN's plan follow it
(let ((k '(:recover-fs 40.0 :recover-bars 1 :j-share 0.0 :keep 4)))
  (check (and (br-route-j-p 20.0 3 0 k) (br-route-j-p 100.0 0 2 k) (not (br-route-j-p 20.0 0 3 k))   ; (3 spare: K, spend)
              (not (br-route-j-p 100.0 3 0 k)) (not (br-route-j-p 30.0 1 0 k))))   ; (the default K, no special needed)
  (check (and (eq :kamae-j (br-ai-stance-plan 0.9 1.5 2.3 3.0 20.0 3 k :spare 0))
              (eq :kamae-k (br-ai-stance-plan 0.9 1.5 2.3 3.0 100.0 3 k :spare 0))
              (eq :q (br-ai-en-plan 0.9 1.5 2.0 3.0 k t t)) (eq :f (br-ai-en-plan 0.9 1.5 2.0 3.0 k t nil)))))
;;; <<< END BARRO-CPU-TESTS
  ;; his state starts empty
  (let ((st (make-brs))) (check (and (zerop (brs-ammo st)) (null (brs-sp2-next st)) (null (brs-in-string st))))))

;;; ---------------------------------------------------------------- Lille II decision V8's art (DUEL_LILLE_V2 §22, art batch 3)
;; 裁き・極 :br-rc4 / :br-o-rc4 (the recall at 10+): S 6, active 43, R 30 (79 f; barro.lisp's move when it has one, else the
;; spec's numbers); six beats f6 R / f12 L / f18 R / f24 L / f30 R / f36 L, each firing tip at him (>= 1.2 m ahead, within
;; 0.4 m of his line, the owl's 0.5; the move's BR-RC-SHOT frames when it exists), the beam on f48 (BR-BEAM-SHOT); f47 in
;; the bigger ring (each wing >= 1 m aside, further aside and higher than 裁き's f35), the owl's claws thrown at him on f48.
;; The ranged L swing :br-e-swing / :br-oe-swing (S 7, A 3, R 6 / 5): through its hit frames f7-9 the striking tip (the
;; rig's right hand) reaches 1.8 m +-0.15 (the spec; the ranged kits' L move's own volume edge once it plays the clip).
(let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (v (make-f32 3))
      (pj (make-rig-proportions :arms 2.6)) (po (make-rig-proportions :arms 2.2 :legs 1.5))
      (rc4 (gethash :br-rc4 *moves*)))
  (flet ((tip (clip frame joint props)
           (clip-sample! pose (find-clip clip) (/ frame 60.0))
           (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 props)
           (joint-point! v jm (joint-index joint) 0f0 0f0 0f0)
           (values (aref v 0) (- (aref v 2)) (aref v 1)))
         (frames (clip) (round (* 60 (clip-dur (find-clip clip))))))
    (let ((sar (if rc4 (list (mv-s rc4) (mv-a rc4) (- (mv-r rc4) *br-sp2-slow-r*)) '(6 44 30)))   ; (v3 R3: R + 20, the clip's end held)
          (beats '((6 :hand-r) (12 :hand-l) (18 :hand-r) (24 :hand-l) (30 :hand-r) (36 :hand-l))))
      (check (equal sar '(6 44 30)))
      (dolist (clip '(:br-rc4 :br-o-rc4))
        (check (or (and (= (frames clip) (reduce #'+ sar)) (= (round (* 60 (clip-mark clip :s))) (first sar)))
                   (format t "~a: ~d f, ~a~%" clip (frames clip) sar))))
      (when rc4
        (check (eq :br-rc4 (mv-clip rc4)))
        (check (eq :br-o-rc4 (kit-move-clip (kit :barro :shin-kin) :br-rc4)))
        (check (equal (append (mapcar #'first beats) '(48))
                      (loop for (fr fn) in (mv-on-frame rc4) when (member fn '(br-rc-shot br-beam-shot)) collect fr))))
      (loop for (fr j) in beats
            do (multiple-value-bind (x ahead) (tip :br-rc4 fr j pj)
                 (check (or (and (>= ahead 1.2) (<= (abs x) 0.4)) (format t ":br-rc4 f~d ~a: ~,2f ahead ~,2f aside~%" fr j ahead x))))
               (multiple-value-bind (x ahead) (tip :br-o-rc4 fr j po)
                 (check (or (and (>= ahead 1.2) (<= (abs x) 0.5)) (format t ":br-o-rc4 f~d ~a: ~,2f ahead ~,2f aside~%" fr j ahead x)))))
      (dolist (j '(:hand-r :hand-l))
        (let ((sg (if (eq j :hand-r) 1 -1)))
          (multiple-value-bind (x ahead up) (tip :br-rc4 47 j pj)
            (declare (ignore ahead))
            (multiple-value-bind (x3 ahead3 up3) (tip :br-rc3 35 j pj)
              (declare (ignore ahead3))
              (check (or (and (>= (* sg x) 1.0) (> (* sg x) (* sg x3)) (> up up3))
                         (format t ":br-rc4 f47 ~a: ~,2f aside ~,2f up (裁き f35: ~,2f ~,2f)~%" j x up x3 up3)))))
          (multiple-value-bind (x ahead) (tip :br-o-rc4 48 j po)
            (check (or (and (>= ahead 1.2) (<= (abs x) 0.5)) (format t ":br-o-rc4 f48 ~a: ~,2f ahead ~,2f aside~%" j ahead x)))))))
    ;; the swing: the spec's 1.8 m, or the ranged kits' L move's volume edge once it plays the swing clip
    (dolist (row '((:br-e-swing :jilliel (7 3 6) pj) (:br-oe-swing :shin (7 3 5) po)))
      (destructuring-bind (clip form sar pv) row
        (let* ((props (if (eq pv 'pj) pj po)) (l (kit-command-move (kit :barro form) :sig))
               (mine (and nil l))                    ; (v3: the stance's L1 plays it as a hitscan line: the spec's 1.8 m)
               (edge (if (and mine (plusp (length (mv-hits l)))) (aref (first (hw-vols (svref (mv-hits l) 0))) 1) 1.8))
               (sar (if mine (list (mv-s l) (mv-a l) (mv-r l)) sar))
               (art (loop for fr from (first sar) below (+ (first sar) (second sar))
                          maximize (multiple-value-bind (x ahead) (tip clip fr :hand-r props) (sqrt (+ (* x x) (* ahead ahead)))))))
          (check (or (and (= (frames clip) (reduce #'+ sar)) (= (round (* 60 (clip-mark clip :s))) (first sar)))
                     (format t "~a: ~d f, ~a~%" clip (frames clip) sar)))
          (check (or (<= (abs (- art edge)) 0.15) (format t "~a: the reach ~,2f m, the swing's tip ~,2f m~%" clip edge art))))))))

;;; ---------------------------------------------------------------- Lille II's awakened stance EN, its own clips (DUEL_LILLE_V3 §8)
;; Decision R3 (the user, 2026-10-11: 「架勢中的 JJ / KK / LL 都改成差異明顯的數段連擊」, 「最後一段 LL 會依據前面 J/K 有不同的動作
;; 模組」): the stance moves of JILLIEL EN (:br-e-*) and of the owl EN (:br-oe-*, R one less) each play a clip of their own: the
;; openers :br-en-* / :br-oen-* (18), the follow-ups :br-e-jf* / -kf* and :br-oe-jf* / -kf* (12, §8.5), lasting the move as
;; authored (S + A + R, its :s mark on S; L slowed with its move, R4 「架式 L 的動作太快了」: played at 2 / 3). R4 (「所有起手
;; 連段一律用近距離攻擊」): the openers are melee strikes: on every hit frame a wing tip (JILLIEL: the rig's hands) / a claw (the
;; owl) reaches its hit's volume edge (*BR-W-TIPS*, +-0.15 m: drawn reach = hit reach) within 0.5 m of his line; the
;; follow-ups' lines: a tip thrown at his line (>= 1.2 m ahead, within 0.5 m of it). The floats' kit :lift aside.
;; R5 (the user 2026-10-11, J 「將光翼拉伸如同長鞭一般鞭擊」; the reach 「跟著動作走」): a whip's stretch (*BR-W-STRETCH*, the
;; clip's keys (frame right left), linear) is drawn on past the hand, so it is in the tip: JILLIEL's along the front wing's
;; root (the chest's local (+-0.07 0.3 0.13), LILLE-DRAW's) -> hand line, the owl's lash along the forearm (elbow -> hand).
(defun br-keys-at (table clip frame g default)
  "Clip CLIP's keys in TABLE ((clip (frame a b) ...) ...) at its frame FRAME, value G (0: a, 1: b), linear between keys, held
past the ends; DEFAULT if the clip is not listed."
  (let ((keys (cdr (assoc clip table))) (prev nil))
    (flet ((val (k) (float (if (= g 0) (second k) (third k)) 1.0)))
      (cond ((null keys) default)
            ((<= frame (first (first keys))) (val (first keys)))
            (t (dolist (k keys (val prev))
                 (when (< frame (first k))
                   (return (+ (val prev) (* (/ (- frame (first prev)) (- (first k) (first prev))) (- (val k) (val prev))))))
                 (setf prev k)))))))
(defun br-stretch-at (clip frame g)
  "The stretch (m) of clip CLIP's front wing G (0 right, 1 left) at its frame FRAME (*BR-W-STRETCH*; 0 if not listed)."
  (br-keys-at *br-w-stretch* clip frame g 0.0))
;; R8 (DUEL_LILLE_V3 §13): the body's squash and stretch (*BR-SQUASH*, keys (frame up sideways), barro-art.lisp BR-DEFORM)
;; scales the posed joints about his feet, up and along his right axis, never his facing: the tips with it (the stretch's
;; root and hand both scaled, then the stretch drawn on), so the reach moves only through the stretch's direction
(check (and (~= 1.0 (br-keys-at *br-squash* :lb-w-q1 10 0 1.0)) (~= 0.74 (br-keys-at *br-squash* :br-en-k1 16 0 1.0))
            (~= 1.3 (br-keys-at *br-squash* :br-en-k1 16 1 1.0)) (~= 1.0 (br-keys-at *br-squash* :br-en-k1 40 0 1.0))))
(check (and (~= 0.0 (br-stretch-at :lb-w-q1 10 0)) (~= 0.4 (br-stretch-at :br-e-jf1 8 0)) (~= 0.1 (br-stretch-at :br-e-jf1 8 1))
            (~= 0.35 (br-stretch-at :br-e-jf1 9 0)) (~= 0.0 (br-stretch-at :br-e-jf1 40 0)) (~= 0.0 (br-stretch-at :br-en-j1 8 0))))
(let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (v (make-f32 3))
      (pj (make-rig-proportions :arms 2.6)) (po (make-rig-proportions :arms 2.2 :legs 1.5)) (seen nil))
  (flet ((tip (clip time joint props)
           (clip-sample! pose (find-clip clip) time)
           (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 props)
           (joint-point! v jm (joint-index joint) 0f0 0f0 0f0)
           (let* ((sy (br-keys-at *br-squash* clip (* 60 time) 0 1.0)) (sx (br-keys-at *br-squash* clip (* 60 time) 1 1.0))
                  (hx (* sx (aref v 0))) (hy (* sy (aref v 1))) (hz (aref v 2)) (g (if (eq joint :hand-r) 0 1))
                  (ex (br-stretch-at clip (* 60 time) g)))
             (if (zerop ex)
                 (values hx (- hz))
                 (progn
                   (if (eq props po)                   ; the owl: along the forearm; JILLIEL: from the wing's root
                       (joint-point! v jm (joint-index (if (= g 0) :lower-arm-r :lower-arm-l)) 0f0 0f0 0f0)
                       (joint-point! v jm (joint-index :chest) (if (= g 0) 0.07f0 -0.07f0) 0.3f0 0.13f0))
                   (let* ((dx (- hx (* sx (aref v 0)))) (dy (- hy (* sy (aref v 1)))) (dz (- hz (aref v 2)))
                          (k (/ ex (sqrt (+ (* dx dx) (* dy dy) (* dz dz))))))
                     (values (+ hx (* k dx)) (- (+ hz (* k dz))))))))))
    (loop for (mpre cpre fpre props) in (list (list "BR-E" "BR-EN" "BR-E" pj) (list "BR-OE" "BR-OEN" "BR-OE" po))
          do (loop for (sn nil nil nil nil nil nil nil nil extra) in *br-s-segs*
                   unless (char= (char sn 0) #\L)   ; (R9: the L dash has no striking tip: its reach is the dash)
                   do (let* ((mv (find-move (intern (format nil "~a-~a" mpre sn) :keyword)))
                             (far (getf extra :spend))
                             (clip (intern (if far (format nil "~a-~aF~a" fpre (char sn 0) (char sn 2)) (format nil "~a-~a" cpre sn))
                                           :keyword))
                             (sp (mv-clip-speed mv)))
                        (push clip seen)
                        (check (or (and (eq clip (mv-clip mv)) (~= sp (if (char= (char sn 0) #\L) (/ 1 *br-w-l-slow*) 1.0)))
                                   (format t "~a: clip ~a at ~,2f~%" (mv-name mv) (mv-clip mv) sp)))
                        (check (or (= (round (* 60 (clip-mark clip :s))) (round (* sp (mv-s mv))))
                                   (format t "~a: :s ~,1f f, its move ~d f~%" clip (* 60 (clip-mark clip :s)) (mv-s mv))))
                        (check (or (null (member :ranged (mv-flags mv))) far))   ; (the openers: melee, no line)
                        (loop for w across (mv-hits mv)
                              do (let* ((fr (hw-from w)) (best nil) (vol (first (hw-vols w))) (edge (+ (aref vol 2) (aref vol 4))))
                                   (dolist (j '(:hand-r :hand-l))
                                     (multiple-value-bind (x ahead) (tip clip (/ (* fr sp) 60.0) j props)
                                       (when (and (<= (abs x) 0.5) (or (null best) (> ahead best))) (setf best ahead))))
                                   (when *br-tip-print* (format t "  tip ~a f~d: ~,2f~%" clip fr best))
                                   (check (or (and best (if far (>= best 1.2) (<= (abs (- best edge)) 0.15)))
                                              (format t "~a f~d: the tip ~a m ahead (~a)~%" clip fr best (if far ">= 1.2" edge)))))))))
    ;; R9 (DUEL_LILLE_V3 §14, 「拿掉砲擊」): K3 is the turn and the overhead split, no blast; the L dash clips (no striking
    ;; tip: the dash is the reach) are the moves' own, at 8 / 12 of their speed; R10 (§15, 「可以三階段續力」): the dash the
    ;; move's :clip-2 (played from the release), its :clip the charge pose held up to *BR-W-L-HOLD* (= clip f40 at 8 / 12)
    (dolist (pre '("BR-E" "BR-OE"))
      (dolist (sn '("L1"))   ; (R10: one charged dash)
        (let ((mv (find-move (intern (format nil "~a-~a" pre sn) :keyword)))
              (cp (if (string= pre "BR-E") "BR-EN" "BR-OEN")))
          (push (mv-clip-2 mv) seen)
          (check (or (and (eq (mv-clip-2 mv) (intern (format nil "~a-~a" cp sn) :keyword))
                          (eq (mv-clip mv) (intern (format nil "~a-LC" cp) :keyword))
                          (~= (mv-clip-speed mv) (/ 1 *br-w-l-slow*)) (= (round (* 60 (clip-mark (mv-clip-2 mv) :s))) 8)
                          (>= (+ 0.01 (* 60 (clip-dur (find-clip (mv-clip mv))))) (* *br-w-l-hold* (mv-clip-speed mv))))
                     (format t "~a: clips ~a / ~a at ~,2f~%" (mv-name mv) (mv-clip mv) (mv-clip-2 mv) (mv-clip-speed mv))))))))
  (check (= 26 (length (remove-duplicates seen)))))

;; R15 (DUEL_LILLE_V3 §19, the user 2026-10-11: 「用覺醒狀態的系統邏輯與動作模組的設計風格重製常態模式」: 「槍鬥術」, 「槍身重揮」,
;; the openers 「改成近距離」): the base stance's J / K are melee strikes as the awakened openers are. Each plays its own clip
;; :br-sk-<segment> at speed 1, lasting its move (S + A + R, its :s mark on S), one hit at S, no line; on the hit frame
;; Diagramm's struck end -- the muzzle, 1.75 m down the barrel from :weapon-r (the gun-kata's point-blank shot, the rifle
;; swung's leading end) on the :lille rig, the squash and stretch scaling it as BR-DEFORM does (*BR-SQUASH*: up and his
;; right, never his facing) -- is at the hit's reach (*BR-W-TIPS* "BR-S" = the volume's edge, +-0.15 m: drawn reach = hit
;; reach), within 0.3 m of his line, 0.6-1.7 m up. J is short, K long (K >= J + 0.5 m). The L, the charged snipe: its charge
;; pose :br-sk-lc (the move's :clip) lasts the longest hold at speed 1, its shot :br-sk-l1 (the :clip-2; the level 2 / 3
;; copies' :clip, started on the release) starts from the pose the charge settles in (f9) and holds on its line.
(let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (p2 (make-f32 +pose-n+)) (v (make-f32 3))
      (tips (cdr (assoc "BR-S" *br-w-tips* :test #'string=))))
  (dolist (sn '("J1" "J2" "J3" "K1" "K2" "K3"))
    (let* ((mv (find-move (intern (format nil "BR-S-~a" sn) :keyword))) (clip (intern (format nil "BR-SK-~a" sn) :keyword))
           (tip (float (second (assoc sn tips :test #'string=)) 1.0)))
      (check (or (and (eq (mv-clip mv) clip) (null (mv-clip-2 mv)) (~= 1.0 (mv-clip-speed mv))
                      (= (round (* 60 (clip-dur (find-clip clip)))) (+ (mv-s mv) (mv-a mv) (mv-r mv)))
                      (= (round (* 60 (clip-mark clip :s))) (mv-s mv)))
                 (format t "~a: clip ~a at ~,2f, ~,1f f (:s ~,1f), its move ~d + ~d + ~d~%" (mv-name mv) (mv-clip mv) (mv-clip-speed mv)
                         (* 60 (clip-dur (find-clip clip))) (* 60 (clip-mark clip :s)) (mv-s mv) (mv-a mv) (mv-r mv))))
      (check (and (= 1 (length (mv-hits mv))) (= (mv-s mv) (hw-from (svref (mv-hits mv) 0)))
                  (null (member :ranged (mv-flags mv))) (zerop (count 'br-shot-fire (mv-on-frame mv) :key #'second))))
      (loop for w across (mv-hits mv)
            do (let* ((fr (hw-from w)) (vol (first (hw-vols w))) (edge (+ (aref vol 2) (aref vol 4))))
                 (clip-sample! pose (find-clip clip) (/ fr 60.0))
                 (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 nil)
                 (joint-point! v jm (ji :weapon-r) 0f0 0f0 -1.75f0)
                 (let* ((sy (br-keys-at *br-squash* clip fr 0 1.0)) (sx (br-keys-at *br-squash* clip fr 1 1.0))
                        (x (* sx (aref v 0))) (y (* sy (aref v 1))) (ahead (- (aref v 2))))
                   (when *br-tip-print* (format t "  tip ~a f~d: ~,2f ahead ~,2f aside ~,2f up~%" clip fr ahead x y))
                   (check (~= edge tip 0.01))
                   (check (or (and (<= (abs (- ahead tip)) 0.15) (<= (abs x) 0.3) (<= 0.6 y 1.7))
                              (format t "~a f~d: the muzzle ~,2f ahead (the reach ~,2f), ~,2f aside, ~,2f up~%" clip fr ahead tip x y))))))))
  (loop for n from 1 to 3
        do (check (>= (- (second (assoc (format nil "K~d" n) tips :test #'string=))
                         (second (assoc (format nil "J~d" n) tips :test #'string=)))
                      0.5)))
  (let ((l (find-move :br-s-l1)))
    (check (and (eq (mv-clip l) :br-sk-lc) (eq (mv-clip-2 l) :br-sk-l1s) (~= 1.0 (mv-clip-speed l))
                (>= (+ 0.01 (* 60 (clip-dur (find-clip :br-sk-lc)))) (* *br-w-l-hold* (mv-clip-speed l)))))
    ;; (R16, DUEL_LILLE_V3 §20, the user 2026-10-12: 「增加第 1 階 L 射擊的前搖」: level 1's shot S *BR-SNIPE-S1* 16, its own clip
    ;;  :br-sk-l1s the move's S + A + R, its :s on 16; the level 2 / 3 copies keep S 8 and :br-sk-l1, each lasting its move)
    (check (and (= (mv-s l) *br-snipe-s1* 16)
                (= (round (* 60 (clip-dur (find-clip :br-sk-l1s)))) (+ (mv-s l) (mv-a l) (mv-r l)))
                (= (round (* 60 (clip-mark :br-sk-l1s :s))) 16)))
    (dolist (c '(:br-s-l1-2 :br-s-l1-3))
      (let ((m (find-move c)))
        (check (and (eq (mv-clip m) :br-sk-l1) (null (mv-clip-2 m)) (~= 1.0 (mv-clip-speed m)) (= (mv-s m) 8)
                    (= (hw-from (svref (mv-hits m) 0)) 8)
                    (= (round (* 60 (clip-dur (find-clip :br-sk-l1)))) (+ (mv-s m) (mv-a m) (mv-r m)))
                    (= (round (* 60 (clip-mark :br-sk-l1 :s))) 8)))))
    (clip-sample! pose (find-clip :br-sk-lc) (/ 9 60.0))
    (dolist (c '(:br-sk-l1 :br-sk-l1s))   ; (both shots start from the charge's settled pose: the release snaps to it)
      (clip-sample! p2 (find-clip c) 0.0)
      (check (every (lambda (a b) (< (abs (- a b)) 1e-4)) pose p2))))
  ;; R16 (§20, the user 2026-10-12: 「普通攻擊的 J3 幫我插入更多關鍵幀並放慢一些速度」): the base form's attack-state J3 銃口突
  ;; :br-j3 plays its own clip :br-jab (Lille's :lb-jab is the old Lille's) at speed 1: S 10, A 3, R 18, the clip lasting
  ;; them, its :s on S (its drawn reach: the generic J / K reach check above)
  (let ((m (find-move :br-j3)))
    (check (or (and (eq (mv-clip m) :br-jab) (null (mv-clip-2 m)) (~= 1.0 (mv-clip-speed m))
                    (= (mv-s m) 10) (= (mv-a m) 3) (= (mv-r m) 18)
                    (= (round (* 60 (clip-dur (find-clip :br-jab)))) (+ (mv-s m) (mv-a m) (mv-r m)))
                    (= (round (* 60 (clip-mark :br-jab :s))) (mv-s m)))
               (format t ":br-j3: clip ~a at ~,2f, ~d + ~d + ~d~%" (mv-clip m) (mv-clip-speed m) (mv-s m) (mv-a m) (mv-r m))))))

;; The user 2026-10-12: 「將常態的普攻 K 動作模組改的更加明顯大膽」: the base form's attack-state K string :br-k1 / :br-k2 /
;; :br-k3 (and the copy :br-k2s) play their own clips :br-f1 / -f2 / -f3 (Lille's :lb-f* are the old Lille's) at speed 1:
;; each clip lasting its move (S + A + R), its :s on S; a link's clip starts (its :enter) on the pose the link before holds
;; at its S + A (the chain opens there on a hit). On S Diagramm's muzzle (1.75 m down the barrel from :weapon-r, the
;; squash and stretch scaling it as BR-DEFORM does) is at the volume's edge (an arc: radial, +-0.15 m: drawn reach = hit
;; reach), within 0.3 m of his line, 0.6-1.7 m up; on every hit frame it never passes the edge by more than 0.15 m.
(let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (p2 (make-f32 +pose-n+)) (v (make-f32 3)))
  (loop for (name clip prev) in '((:br-k1 :br-f1 nil) (:br-k2 :br-f2 :br-k1) (:br-k2s :br-f2 nil) (:br-k3 :br-f3 :br-k2))
        do (let* ((m (find-move name)) (w (svref (mv-hits m) 0)) (vol (first (hw-vols w))) (edge (aref vol 1)))
             (check (or (and (eq (mv-clip m) clip) (null (mv-clip-2 m)) (~= 1.0 (mv-clip-speed m)) (< (aref vol 0) 0.5)
                             (= (round (* 60 (clip-dur (find-clip clip)))) (+ (mv-s m) (mv-a m) (mv-r m)))
                             (= (round (* 60 (clip-mark clip :s))) (mv-s m) (hw-from w)))
                        (format t "~a: clip ~a at ~,2f, ~,1f f (:s ~,1f), its move ~d + ~d + ~d~%" name (mv-clip m) (mv-clip-speed m)
                                (* 60 (clip-dur (find-clip clip))) (* 60 (clip-mark clip :s)) (mv-s m) (mv-a m) (mv-r m))))
             (when prev                                 ; (the link's first frame: the pose its predecessor holds at S + A)
               (let ((pm (find-move prev)))
                 (clip-sample! pose (find-clip (mv-clip pm)) (/ (+ (mv-s pm) (mv-a pm)) 60.0))
                 (clip-sample! p2 (find-clip clip) (/ (mv-enter m) 60.0))
                 (check (or (every (lambda (a b) (< (abs (- a b)) 1e-4)) pose p2)
                            (format t "~a: its clip at :enter ~d is not ~a's at ~d~%" name (mv-enter m) prev (+ (mv-s pm) (mv-a pm)))))))
             (loop for fr from (hw-from w) below (hw-to w)
                   do (clip-sample! pose (find-clip clip) (/ fr 60.0))
                      (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 nil)
                      (joint-point! v jm (ji :weapon-r) 0f0 0f0 -1.75f0)
                      (let* ((sy (br-keys-at *br-squash* clip fr 0 1.0)) (sx (br-keys-at *br-squash* clip fr 1 1.0))
                             (x (* sx (aref v 0))) (y (* sy (aref v 1))) (r (sqrt (+ (* x x) (expt (aref v 2) 2)))))
                        (when *br-tip-print* (format t "  tip ~a f~d: ~,2f out ~,2f aside ~,2f up~%" clip fr r x y))
                        (check (or (if (= fr (hw-from w))
                                       (and (<= (abs (- r edge)) 0.15) (<= (abs x) 0.3) (<= 0.6 y 1.7))
                                       (<= r (+ edge 0.15)))
                                   (format t "~a f~d: the muzzle ~,2f out (the reach ~,2f), ~,2f aside, ~,2f up~%" clip fr r edge x y))))))))
;; The wing wall (DUEL_LILLE_V3 "The wing wall", the user 2026-10-12: 「把覺醒時的防禦姿勢改成用八翼擋住前面進行防禦」): his
;; awakened forms play their own guard / blocked-hit clips through :look-clips (a look: PLAY-CLIP), the base form and every
;; other kit the generic ones (no :look-clips); the clips exist (the loop held, the hit settled back into the wall pose);
;; JILLIEL's hands (the front pair's tips) low before him past his midline at the wall's place, the owl's claws crossed
;; before its chest; the wall rows (lille-art.lisp) put every blade past his midline, in front, curled round the column.
(let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (v (make-f32 3))
      (pj (make-rig-proportions :arms 2.6)) (po (make-rig-proportions :arms 2.2 :legs 1.5)))
  (loop for (form g gh) in '((:jilliel-kin :br-w-guard :br-w-guard-hit) (:jilliel :br-w-guard :br-w-guard-hit)
                             (:shin-kin :br-o-guard :br-o-guard-hit) (:shin :br-oe-guard :br-oe-guard-hit))
        do (let ((lc (kit-look-clips (kit :barro form))))
             (check (and (eq (getf lc :sh-guard) g) (eq (getf lc :sh-guard-hit) gh) (= (length lc) 4)
                         (member g (kit-clips (kit :barro form))) (member gh (kit-clips (kit :barro form)))))
             (check (and (clip-loop (find-clip g)) (not (clip-loop (find-clip gh))) (~= 0.3 (clip-dur (find-clip gh)))))
             (let ((base (find-pose (getf '(:br-w-guard :br-w-wall-pose :br-o-guard :br-o-wall-pose :br-oe-guard :br-oe-wall-pose) g)))
                   (p2 (make-f32 +pose-n+)))
               (clip-sample! pose (find-clip g) 0.0) (clip-sample! p2 (find-clip gh) 0.3)
               (check (and (every (lambda (a b) (< (abs (- a b)) 1e-4)) pose base)
                           (every (lambda (a b) (< (abs (- a b)) 1e-4)) p2 base))))))
  (check (every (lambda (cf) (or (and (eq (first cf) :barro) (not (eq (second cf) :base)))
                                 (and (equal cf '(:hisagi :base))   ; (Hisagi's Shikai: the walk's legs under his own arms,
                                      (equal (kit-look-clips (apply #'kit cf)) *hs-shikai-looks*))   ;  §21.4; his Bankai's, §21.8)
                                 (and (equal cf '(:hisagi :bankai)) (equal (kit-look-clips (apply #'kit cf)) *hs-bk-looks*))
                                 (and (equal cf '(:hisagi :bankai-bind))   ; (the bind's low walk, A2 §24.2)
                                      (equal (kit-look-clips (apply #'kit cf)) *hs-kb-looks*))
                                 (null (kit-look-clips (apply #'kit cf)))))
                *forms*))
  (flet ((at (j) (joint-point! v jm (joint-index j) 0f0 0f0 0f0) (list (aref v 0) (aref v 1) (aref v 2)))
         (chest-rel (p)                                 ; P in the chest's frame: across (his right), up, forward
           (let* ((o (* 16 (joint-index :chest))) (d (mapcar #'- p (list (aref jm (+ o 12)) (aref jm (+ o 13)) (aref jm (+ o 14))))))
             (list (+ (* (first d) (aref jm o)) (* (second d) (aref jm (+ o 1))) (* (third d) (aref jm (+ o 2))))
                   (+ (* (first d) (aref jm (+ o 4))) (* (second d) (aref jm (+ o 5))) (* (third d) (aref jm (+ o 6))))
                   (- (+ (* (first d) (aref jm (+ o 8))) (* (second d) (aref jm (+ o 9))) (* (third d) (aref jm (+ o 10)))))))))
    (replace pose (find-pose :br-w-wall-pose))
    (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 pj)
    (let ((r (chest-rel (at :hand-r))) (l (chest-rel (at :hand-l))))
      (check (or (and (every (lambda (a b) (< (abs (- a b)) 0.02)) r '(-0.3 -0.45 0.75))
                      (every (lambda (a b) (< (abs (- a b)) 0.02)) l '(0.3 -0.45 0.75)))
                 (format t "JILLIEL's wall hands: ~a ~a~%" r l))))
    (loop for (p tg) in '((:br-o-wall-pose (-0.12 -0.05 0.45)) (:br-oe-wall-pose (-0.12 -0.1 0.4)))
          do (replace pose (find-pose p))
             (pose-fk! jm pose 0f0 0f0 0f0 0f0 1f0 0f0 po)
             (let ((r (chest-rel (at :hand-r))) (l (chest-rel (at :hand-l))))
               (check (or (and (every (lambda (a b) (< (abs (- a b)) 0.02)) r tg)
                               (every (lambda (a b) (< (abs (- a b)) 0.02)) l (cons (- (first tg)) (rest tg))))
                          (format t "~a claws: ~a ~a~%" p r l))))))
  (dolist (wt (list *lb-wall-jl* *lb-wall-owl*))
    (check (and (= (length wt) 32)
                (loop for i below 8 for q = (* 4 i)
                      always (and (< 0.5 (aref wt (+ q 3)) 1.6)
                                  (or (and (eq wt *lb-wall-jl*) (<= 4 i 5))   ; (JILLIEL's front pair: the hands)
                                      (and (< (aref wt q) -0.1) (> (aref wt (+ q 2)) 0.5))))))))
  (check (equal (loop for i below 4 collect (aref *lb-wall-jl* (+ 3 (* 8 i))))   ; (each pair's two sides alike)
                (loop for i below 4 collect (aref *lb-wall-jl* (+ 7 (* 8 i)))))))

;; The gate's match length leaves the cinematics out (the user, 2026-10-08: 「毀魂技演出不計入對戰時長」, every cinematic):
;; PLAY-TICKS (flow's MATCH-PLAY-TICKS) are the frames the timer ran (it stops while a cinematic plays: MAIN's step)
(check (= 600 (play-ticks 300 (- 18000 600))))
(check (= 18000 (play-ticks 300 -3)))

;; Hisagi's shared hooks (docs/duel/DUEL_HISAGI.md §12.4, batch B1): each defaults off. Inert: no kit / move but Hisagi's
;; (B2a, his own section below) sets one, and the generic readers they changed return what the old code did for every
;; other kit form and move.
(defun hs-own-move-p (name) (let ((n (symbol-name name))) (and (> (length n) 3) (string= "HS-" n :end2 3))))
(let ((kits (remove :hisagi (loop for alist being the hash-values of *kits* append (mapcar #'cdr alist)) :key #'kit-character))
      (moves (loop for name being the hash-keys of *moves* using (hash-value m) unless (hs-own-move-p name) collect m)))
  (check (every (lambda (k) (and (null (kit-push-reach k)) (null (kit-hook k :command)))) kits))
  (check (loop for m in moves
               never (or (intersection '(:no-close :ranged-ward) (mv-flags m)) (some #'hw-seg (mv-hits m)))))
  (dolist (k kits)
    (dolist (c *kit-commands*)                                    ; :command: the same move with and without a fighter
      (check (eq (kit-command-move k c) (kit-command-move k c :e))))
    (loop for m being the hash-values of (kit-moves k)            ; :no-close: STRING-OPENER-P = the old close-in test
          do (check (eq (and (string-opener-p k m :e) t)
                        (and (member (mv-kind m) '(:quick :flash))
                             (eq m (kit-command-move k (if (eq (mv-kind m) :quick) :q :f))) t)))
             (let ((o (kit-command-move k (if (eq (mv-kind m) :quick) :q :f))))   ; :push-reach: the opener's reach
               (when o (check (= (ender-push-reach k m o) (mv-reach o)))))))
  ;; :seg-fn: WINDOW-TOUCHES-P = the old volume loop for every window of every move, at points around the attacker
  (check (loop for m in moves
               always (loop for w across (mv-hits m)
                            always (loop for (tx tz) in '((0.0 -1.0) (0.5 -2.0) (-1.5 -0.5) (0.0 -4.0) (3.0 -6.0) (0.0 1.0))
                                         always (eq (and (window-touches-p w :e 0f0 0f0 0f0 0f0 -1f0 tx 0f0 tz 0.38 1.8) t)
                                                    (and (loop for v in (hw-vols w)
                                                               thereis (vol-hit-p v 0f0 0f0 0f0 0f0 -1f0 tx 0f0 tz 0.38 1.8 0f0))
                                                         t)))))))
;; ... and each, set by a dummy kit in this test, does its one thing
(defun t-seg (e) (declare (ignore e)) (values 0f0 1f0 0f0 0f0 1f0 -6f0 0.35))   ; a chain from him to 6 m ahead, 1 m up
(defun t-command (e cmd) (and (eq e :out) (eq cmd :q) (find-move :t-alt-j1)))     ; out of hand: the other J1
(register-move :t-j1 '(:kind :quick :startup 8 :active 3 :recovery 12 :dmg 30 :reach 1.4))
(register-move :t-alt-j1 '(:kind :quick :startup 8 :active 3 :recovery 12 :dmg 24 :reach 1.4))
(register-move :t-k1 '(:kind :flash :startup 18 :active 4 :recovery 22 :dmg 62 :vol (:cap 0.3 6.0 1.1 0.3) :flags (:no-close)))
(register-move :t-k1-close '(:kind :flash :startup 18 :active 4 :recovery 22 :dmg 62 :vol (:cap 0.3 6.0 1.1 0.3)))
(register-move :t-k3 '(:kind :flash :startup 22 :active 5 :recovery 34 :dmg 80 :reach 2.8 :flags (:ender)))
(register-move :t-j3 '(:kind :quick :startup 9 :active 3 :recovery 18 :dmg 38 :reach 1.4 :flags (:ender)))
(register-move :t-pull '(:kind :flash :startup 20 :active 4 :recovery 24 :dmg 56 :reach 2.0 :hits ((20 24 :seg-fn t-seg))))
(register-move :t-ward '(:kind :sig :startup 6 :active 20 :recovery 14 :flags (:ranged-ward)))
(register-move :t-shots '(:kind :sp :startup 10 :active 2 :recovery 20 :dmg 40 :reach 6.0
                         :hits ((10 12 :flags (:ranged)) (20 22 :flags (:ranged)))))
(let ((k (register-kit :t-dummy :t-form '(:commands (:q :t-j1 :f :t-k1 :sig :t-ward) :strings ((:t-j1 :q :t-j3) (:t-k1 :f :t-k3))
                                           :push-reach 6.0 :hooks (:command t-command))))
      (k0 (register-kit :t-dummy :t-plain '(:commands (:q :t-j1 :f :t-k1-close)))))
  (check (not (member :t-dummy *roster*)))                         ; (not a :base form: no roster slot)
  ;; :command: the hook picks with a fighter, the :commands entry without one or when the hook says NIL
  (check (eq (kit-command-move k :q :out) (find-move :t-alt-j1)))
  (check (eq (kit-command-move k :q :in) (find-move :t-j1)))
  (check (eq (kit-command-move k :q) (find-move :t-j1)))
  (check (eq (kit-command-move k :f :out) (find-move :t-k1)))
  ;; :no-close: K1 takes no close-in, J1 does; the same K1 without the flag does
  (check (string-opener-p k (find-move :t-j1)))
  (check (not (string-opener-p k (find-move :t-k1))))
  (check (string-opener-p k0 (find-move :t-k1-close)))
  (check (string-opener-p k (find-move :t-alt-j1) :out))            ; (the hook's J1 is the opener out of hand)
  (check (not (string-opener-p k (find-move :t-alt-j1) :in)))
  ;; :push-reach: a K ender's push from 6.0 m, a J ender's from J1's reach; without the key the opener's own
  (check (= 6.0 (ender-push-reach k (find-move :t-k3) (find-move :t-j1))))
  (check (= 1.4 (ender-push-reach k (find-move :t-j3) (find-move :t-j1))))
  (check (= 1.4 (ender-push-reach k0 (find-move :t-k3) (find-move :t-j1)))))
;; :seg-fn: the window's capsule, not its volume; the CPU's gap to it
(let ((w (svref (mv-hits (find-move :t-pull)) 0)))
  (check (and (eq (hw-seg w) 't-seg) (null (hw-vols w))))
  (check (window-touches-p w :e 0f0 0f0 0f0 0f0 -1f0 0.2 0f0 -4.0 0.36 1.8))     ; 4 m out, on the chain (the 2 m reach: no)
  (check (not (window-touches-p w :e 0f0 0f0 0f0 0f0 -1f0 2.0 0f0 -3.0 0.36 1.8)))
  (check (~= (seg-gap (find-move :t-pull) :e 2.0 -3.0) 1.65))
  (check (null (seg-gap (find-move :t-j1) :e 2.0 -3.0))))
;; :ranged-ward: a ranged hit on a warding defender who can guard resolves as a 360 deg ward guard; an unguardable passes
(check (ranged-ward-p t t :neutral t))
(check (not (ranged-ward-p nil t :neutral t)))                     ; (no such move: off)
(check (not (ranged-ward-p t nil :neutral t)))                     ; (melee: lands)
(check (not (ranged-ward-p t t :neutral nil)))                     ; (guard gauge empty / guardless: lands)
(check (not (ranged-ward-p t t :invuln t)))
(check (eq (resolve-contact :guard :in-front nil :hazard t :ward t) :blocked))
(check (eq (resolve-contact :guard :in-front nil :hazard t :ward t :unguardable t) :hit))
;; the ranged-threat reader's frame lead: the next :ranged window of a move, none for a move without one
(check (equal (mapcar (lambda (sf) (ranged-window-lead (find-move :t-shots) sf)) '(0 11 15 22)) '(10 0 5 nil)))
(check (null (ranged-window-lead (find-move :t-j1) 0)))

;; Hisagi's shared hooks 5 and 7 (docs/duel/DUEL_HISAGI.md §17.4, batch B1b): the bind's readers and P's :p hook, each
;; default off. combat / fighter / flow are loaded here over stand-in entities (a struct holding the fighter and gauges
;; components) with stubs for the engine's entity check, events, log and cinematics; nothing else of theirs is run.
(load (merge-pathnames "../engine/lisp/touch.lisp" *load-truename*))
(dolist (f '("components" "combat" "fighter" "flow"))
  (load (merge-pathnames (format nil "../duel/lisp/~a.lisp" f) *load-truename*)))
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
(defparameter *bind-hooks* '(:bind :bind-damage :bind-pool :bind-heal :bind-step :bind-resolve :bind-snapshot :p :p-label))
;; inert: no kit but Hisagi's Bankai (B2b) holds a bind hook or :p; every reader then does what the old code did
(check (loop for c being the hash-keys of *kits* using (hash-value alist)
             never (loop for (f . k) in alist
                         thereis (and (not (and (eq c :hisagi) (member f '(:bankai :bankai-bind))))
                                      (some (lambda (h) (kit-hook k h)) *bind-hooks*)))))
(check (and (member :awaken *run-commands-p*) (not (member :awaken *run-commands*))
            (equal (rest *run-commands-p*) *run-commands*)))
(multiple-value-bind (a b) (t-pair (kit :yamamoto :base) (kit :kenpachi :base))
  (let ((ga (gauges a)) (gb (gauges b)))
    (check (and (null (bind-of a)) (null (bind-of b))))
    (setf (gauges-reiatsu ga) 250f0)
    (check (= (reiatsu-of a) 250f0))
    (reiatsu-gain! a 70.0)                                        ; the old (f32 (gauge-add r n *reiatsu-max*))
    (check (= (gauges-reiatsu ga) (f32 (gauge-add 250f0 70.0 *reiatsu-max*)) 300f0))
    (reiatsu-spend! a 2)
    (check (= (gauges-reiatsu ga) 100f0))
    (setf (gauges-reishi ga) 1200)
    (heal! a 500)
    (check (= (gauges-reishi ga) (gauges-reishi-max ga)))
    (check (and (null (bind-snapshot-of a)) (= (bind-grey-frac a) 0f0) (= (bind-grey-souls a) 0)))
    (check (bankai-ok-p b))
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
;; ... and with a dummy binder (its kit holds the hooks; the bind's state lives here, as in Hisagi's file)
(defvar *tb-on* nil) (defvar *tb-pool* 0f0) (defvar *tb-snap* nil) (defvar *tb-log* nil) (defvar *tb-release* nil)
(defun tb-bind (x) (and *tb-on* (eq (kit-of x) (kit :t-bind :t-binder))))
(defun tb-damage (b a d n) (declare (ignore b a d)) (setf *tb-pool* (f32 (bind-drain *tb-pool* n))))
(defun tb-pool (b &optional (n 0)) (declare (ignore b)) (setf *tb-pool* (f32 (max 0.0 (- *tb-pool* n)))))
(defun tb-heal (b e n) (declare (ignore b))
  (let ((s (assoc e *tb-snap*))) (setf (second s) (min (gauges-reishi-max (gauges e)) (+ (second s) n)))))
(defun tb-snapshot (b e) (declare (ignore b)) (let ((s (assoc e *tb-snap*))) (values (second s) (third s))))
(defun tb-start (b)
  (let ((o (opp-of b)))
    (setf *tb-snap* (mapcar (lambda (x) (list x (gauges-reishi (gauges x)) (gauges-konpaku (gauges x)))) (list b o))
          *tb-pool* (f32 (+ (gauges-reiatsu (gauges b)) (gauges-reiatsu (gauges o)))) *tb-on* t *tb-log* nil)))
(defun tb-step (b phase)
  (push phase *tb-log*)
  (let ((o (opp-of b)))
    (cond ((and (eq phase :release) *tb-release*)                 ; B8: the snapshot back, the pool to him first
           (setf *tb-on* nil *tb-release* nil)
           (dolist (s *tb-snap*) (setf (gauges-reishi (gauges (first s))) (second s) (gauges-konpaku (gauges (first s))) (third s)))
           (multiple-value-bind (to-o to-b) (bind-release-split *tb-pool*)
             (setf (gauges-reiatsu (gauges o)) (f32 to-o) (gauges-reiatsu (gauges b)) (f32 to-b))))
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
(register-kit :t-bind :t-binder '(:hooks (:bind tb-bind :bind-damage tb-damage :bind-pool tb-pool :bind-heal tb-heal
                                          :bind-step tb-step :bind-resolve tb-resolve :bind-snapshot tb-snapshot
                                          :p tp :p-label tp-label)))
(check (not (member :t-bind *roster*)))
(multiple-value-bind (a b) (t-pair (kit :yamamoto :base) (kit :t-bind :t-binder))   ; B binds A (Yamamoto)
  (let ((ga (gauges a)) (gb (gauges b)))
    (setf (gauges-reiatsu ga) 150f0 (gauges-reiatsu gb) 250f0 (gauges-reishi ga) 1000 (gauges-konpaku ga) 9)
    (check (null (bind-of a)))
    (tb-start b)
    (check (and (eq (bind-of a) b) (eq (bind-of b) b)))           ; either side: the binder
    (check (= (reiatsu-of a) (reiatsu-of b) 400f0))                ; the shared pool
    ;; the drain: 1 per 2 (nominal) damage, exact on odd damage; grey Reishi floors at 0 with no Soul Break
    (check (null (deal-damage b a 7)))
    (check (= *tb-pool* 396.5f0))
    (check (and (= (gauges-reishi ga) 993) (= (gauges-grey gb) 7) (= (dealt-real b) 0) (= (gauges-dealt gb) 7)))
    (check (null (deal-damage b a 2000)))                          ; past 0: grey, no Soul Break queued
    (check (and (= (gauges-reishi ga) 0) (null *soul-breaks*) (= *tb-pool* 0f0)))
    (setf *tb-pool* 396.5f0)
    ;; every gain frozen, flash-step still paid; the pool spent by either side's SP
    (reiatsu-gain! a 50.0)
    (check (= (gauges-reiatsu ga) 150f0))
    (setf (gauges-fs ga) 50f0)
    (pay-gauges a 50.0 10.0)
    (check (and (= (gauges-reiatsu ga) 150f0) (= (gauges-fs ga) 60f0)))
    (gain-gauges a 100 0)
    (check (= (gauges-reiatsu ga) 150f0))
    (kosei! a 14 0f0 0f0 0f0)
    (check (= (gauges-reiatsu ga) 150f0))
    (white-regen! a ga 1)
    (check (= (gauges-reiatsu ga) 150f0))
    ;; (combat.lisp writes Reiatsu only in REIATSU-GAIN! and REIATSU-SPEND!: the refund, BLUE, the regen, the reset too)
    (check (let ((src (with-open-file (s (merge-pathnames "../duel/lisp/combat.lisp" *load-truename*))
                        (let ((str (make-string (file-length s)))) (subseq str 0 (read-sequence str s))))))
             (loop with n = 0 for i = (search "(setf (gauges-reiatsu" src) then (search "(setf (gauges-reiatsu" src :start2 (1+ i))
                   while i do (incf n) finally (return (= n 2)))))
    (check (kit-command-ok-p a :sp1))                              ; his own 150 aside: the pool pays
    (reiatsu-spend! a 1)
    (check (and (= *tb-pool* 296.5f0) (= (gauges-reiatsu ga) 150f0)))
    (setf *tb-pool* 50f0)
    (check (not (kit-command-ok-p a :sp1)))
    (setf *tb-pool* 296.5f0)
    ;; a real heal raises the snapshot too; the grey band and souls read the snapshot
    (setf (gauges-reishi ga) 0 (second (assoc a *tb-snap*)) 1000)   ; (WHITE's frame above healed him too)
    (heal! a 100)
    (check (and (= (gauges-reishi ga) 100) (= (second (assoc a *tb-snap*)) 1100)))
    (check (and (= (bind-grey-frac a) (f32 (/ 1100 (float (gauges-reishi-max ga))))) (= (bind-grey-souls a) 9)))
    ;; a Kikon inside plays: the Konpaku (grey) floors at 0, never a K.O.; Kenpachi's Bankai refused
    (setf (gauges-konpaku ga) 2 (fighter-kikon-n (fighter b)) 3)
    (check (null (settle-konpaku b a nil)))
    (check (and (= (gauges-konpaku ga) 0) (= (gauges-reishi ga) (gauges-reishi-max ga)) (= (bind-grey-souls a) 9)))
    (check (not (bankai-ok-p a)))
    ;; :p takes P (with the awakening's free test) once nothing else does
    (setf (gauges-awakened gb) t (gauges-awaken ga) 0f0)
    (check (and (try-command b (fighter b) :awaken) (eq (first *tp-call*) b) (second *tp-call*)))   ; (free: idle)
    (setf (fighter-state (fighter b)) :stun (fighter-combo-hits (fighter b)) 1)
    (check (and (try-command b (fighter b) :awaken) (null (second *tp-call*))))   ; in a combo before its 2nd hit: not free
    (setf (fighter-state (fighter b)) :idle (fighter-combo-hits (fighter b)) 0)
    (check (null (try-command a (fighter a) :awaken)))             ; (his own kit has no :p)
    ;; the release (where a Burst is applied): the snapshot back, the pool left to the opponent first (<= 300)
    (setf *tb-release* t *tb-pool* 450f0)
    (bind-step! a :release)
    (check (and (null (bind-of a)) (= (gauges-reishi ga) 1100) (= (gauges-konpaku ga) 9)))
    (check (and (= (gauges-reiatsu ga) 300f0) (= (gauges-reiatsu gb) 150f0)))
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
(check (equal (loop for l in '(0.0 150.0 300.0 450.0 600.0) collect (multiple-value-list (bind-release-split l)))
              '((0.0 0.0) (150.0 0.0) (300.0 0.0) (300.0 150.0) (300.0 300.0))))
(check (and (= (bind-drain 300.0 7) 296.5) (= (bind-drain 3.0 7) 0.0)))

;;; ================================================================ Hisagi's Shikai (docs/duel/DUEL_HISAGI.md §7-§8, batch B2a)
;; stand-ins: a position / facing per stand-in fighter and his state component (the engine's ECS is not on the host);
;; his file loaded again now that combat / fighter / components are (its SETFs of their slots expand against them);
;; hazards.lisp too (B4a: his marks are hazards) over a stand-in entity list of hazards (the engine's DO-ENTITIES over
;; components is not on the host: here only the HAZARD component, in spawn order)
(defvar *t-hz* nil "The stand-in hazard entities, (handle . hazard), in spawn order.")
(defmacro do-entities ((var &rest comps) &body body)
  (let ((c (first comps)) (x (gensym)))
    `(dolist (,x (copy-list *t-hz*))
       (let ((,var (car ,x)) ,@(when (consp c) `((,(first c) (cdr ,x)))))
         (declare (ignorable ,var))
         ,@body))))
(defun spawn-entity (&rest cs) (let ((h (gensym "HZ"))) (setf *t-hz* (append *t-hz* (list (cons h (first cs))))) h))
(defun destroy-entity (h) (setf *t-hz* (remove h *t-hz* :key #'car)))
(defun hazard (h) (cdr (assoc h *t-hz*)))
(load (merge-pathnames "../duel/lisp/hazards.lisp" *load-truename*))
(load (merge-pathnames "../duel/lisp/hisagi.lisp" *load-truename*))
(defvar *t-pos* (make-hash-table :test 'eq)) (defvar *t-yaw* (make-hash-table :test 'eq)) (defvar *t-hss* (make-hash-table :test 'eq))
(defun pos-of (e) (or (gethash e *t-pos*) (setf (gethash e *t-pos*) (make-f32 3))))
(defun yaw-of (e) (gethash e *t-yaw* 0f0))
(defun hss (e) (gethash e *t-hss*))
(defun add-component (e c) (setf (gethash e *t-hss*) c))
(defun t-at (e x z &optional (yaw 0f0)) (let ((p (pos-of e))) (setf (aref p 0) (f32 x) (aref p 1) 0f0 (aref p 2) (f32 z) (gethash e *t-yaw*) (f32 yaw))) e)
(let* ((k (kit :hisagi :base)) (mv* (lambda (n) (kit-move k n))))
  (flet ((m (n) (funcall mv* n)))
    ;; the roster slot, the stats (§8.1), the hooks he sets (each a shared hook B1 built: :no-close, :seg-fn, :push-reach,
    ;; :command, :ranged-ward; and this batch's :reset / :hash and :command's :hold)
    (check (and (= 7 (position :hisagi *roster*)) (member :hisagi (playable-roster))))
    (check (and (~= (kit-mult k) 1.15) (~= (kit-taken k) 1.0) (~= (kit-walk k) 3.8) (~= (kit-run k) 9.0)
                (~= (kit-push-reach k) 6.0) (= 2 (kit-kikon-konpaku k)) (eq :bankai (kit-awaken-form k))))   ; (B2b: the Bankai)
;; (S1, DUEL_HISAGI §23.3: the K string the chain at range, K1 NAGI a 90 deg sweep 2.0-6.0 m, K2 NOKO / K3 TSUI along
    ;; HS-FOE-SEG on the victim, off a hit or a block since S2 (§23.5; K2J the cross copy); MAKI, HODOKI and the one-handed J copies dormant: FIND-MOVE's)
    (check (and (member :no-close (mv-flags (m :hs-k1))) (member :ranged (mv-flags (m :hs-k1)))
                (~= 2.0 (getf (mv-params (m :hs-k1)) :melee-range)) (~= 30.0 (mv-track (m :hs-k1)))
                (null (getf (mv-params (m :hs-k1)) :throw)) (null (mv-on-land (m :hs-k1))) (null (mv-on-frame (m :hs-k1)))
                (~= *hs-k-dead* (hw-min (svref (mv-hits (m :hs-k1)) 0))) (~= 2.0 *hs-k-dead*)
                (let ((v (first (hw-vols (svref (mv-hits (m :hs-k1)) 0)))))
                  (and (< (aref v 0) 0.5) (~= 6.0 (aref v 1)) (~= 90 (/ (* 2 (aref v 2)) (deg 1)))))
                (every (lambda (n) (let ((w (svref (mv-hits (m n)) 0)))
                                     (and (eq 'hs-foe-seg (hw-seg w)) (null (hw-vols w)) (null (hw-min w))
                                          (member :ranged (mv-flags (m n))))))
                       '(:hs-k2 :hs-k2j :hs-k3))
                (equal (mv-spec (m :hs-k2j)) (mv-spec (m :hs-k2)))
                (eq :stagger (hw-react (svref (mv-hits (m :hs-k2)) 0))) (eq :crumple (hw-react (svref (mv-hits (m :hs-k3)) 0)))
                (member :ender (mv-flags (m :hs-k3))) (null (mv-on-land (m :hs-k2))) (null (mv-on-frame (m :hs-k2)))
                (eq 'hs-chain-seg (hw-seg (svref (mv-hits (find-move :hs-k3h)) 0)))
                (notany (lambda (n) (gethash n (kit-moves k))) '(:hs-k2s :hs-k3h))))
    ;; the §8.2 table (S1's K string): S A R dmg guard block reach
    (dolist (row '((:hs-j1 8 3 12 30 8 -2 1.4) (:hs-j2 8 3 13 30 8 -2 1.4) (:hs-j3 9 3 18 38 12 -4 1.4)
                   (:hs-k1 18 4 22 62 14 -3 6.0) (:hs-k2 20 4 24 56 14 -3 6.0) (:hs-k3 22 5 34 80 18 -20 6.0)))
      (destructuring-bind (name s a r dmg g adv reach) row
        (let ((x (find-move name)))
          (check (or (and (= s (mv-s x)) (= a (mv-a x)) (= r (mv-r x)) (= dmg (mv-dmg x)) (= g (hw-guard (svref (mv-hits x) 0)))
                          (= adv (mv-adv-block x)) (~= reach (mv-reach x)))
                     (format t "  Hisagi table mismatch ~s~%" name))))))
    (check (and (= 14 (- (mv-s (m :hs-k2)) (mv-enter (m :hs-k2)))) (= 14 (- (mv-s (m :hs-k3)) (mv-enter (m :hs-k3))))
                (~= 0.3 (mv-slide (m :hs-j1))) (~= 110 (/ (* 2 (aref (first (hw-vols (svref (mv-hits (m :hs-j1)) 0))) 2)) (deg 1)))
                (~= 200 (/ (* 2 (aref (first (hw-vols (svref (mv-hits (m :hs-j3)) 0))) 2)) (deg 1)))))   ; (Q5 A)
    ;; the routes (S2, §23.5): the grid's six, JJJ JJK JKK KKK KJJ KKJ (one switch at most: no JKJ, no KJK), K3 the same
    ;; move after a J as after K2, K2J J1's copy of K2; a J after a K the leap copies (J2K, then the plain J3; J3K); the OUT
    ;; graph's J string (dormant) as it was
    (check (equal (route k :q '((:q) (:q))) '(:hs-j1 :hs-j2 :hs-j3)))
    (check (equal (route k :q '((:q) (:f))) '(:hs-j1 :hs-j2 :hs-k3)))
    (check (equal (route k :q '((:f) (:f))) '(:hs-j1 :hs-k2j :hs-k3)))
    (check (equal (route k :q '((:f) (:q))) '(:hs-j1 :hs-k2j)))
    (check (equal (route k :f '((:f) (:f))) '(:hs-k1 :hs-k2 :hs-k3)))
    (check (equal (route k :f '((:q) (:q))) '(:hs-k1 :hs-j2k :hs-j3)))
    (check (equal (route k :f '((:q) (:f))) '(:hs-k1 :hs-j2k)))
    (check (equal (route k :f '((:f) (:q))) '(:hs-k1 :hs-k2 :hs-j3k)))
    (check (and (null (kit-next k :hs-k2j :q)) (null (kit-next k :hs-j2k :f))
                (eq (kit-next k :hs-j1-1h :q) (find-move :hs-j2-1h)) (null (kit-next k :hs-j1-1h :f)) (null (kit-next k :hs-j2-1h :f))
                (eq (string-latch k :hs-j1-1h :f nil) nil) (member :ender (mv-flags (find-move :hs-j3-1h)))))
    ;; the routes on hit (before the x1.15; no combo scaling within three hits)
    (flet ((dmg (&rest names) (loop for n in names for i from 1 sum (hit-damage (mv-dmg (m n)) nil nil i nil))))
      (check (equal (list (dmg :hs-j1 :hs-j2 :hs-j3) (dmg :hs-j1 :hs-j2 :hs-k3) (dmg :hs-j1 :hs-k2j :hs-k3) (dmg :hs-k1 :hs-k2 :hs-k3)
                          (dmg :hs-k1 :hs-j2k :hs-j3) (dmg :hs-k1 :hs-k2 :hs-j3k))
                    '(98 140 166 198 130 156))))
    ;; the combo arithmetic on every link: the victim's stun (from its hit frame) outlasts the link's hit (the next link's
    ;; chain opens at S + A on a hit and plays S_eff to its hit); the global hitstop freezes both sides alike (each link's own
    ;; hitstop added to both sides below); every link 3 -> the O lane (no dash: S 20) inside its stagger / crumple
    (loop for (a b) in '((:hs-j1 :hs-j2) (:hs-j1 :hs-k2j) (:hs-j2 :hs-j3) (:hs-j2 :hs-k3) (:hs-k1 :hs-k2) (:hs-k2 :hs-k3)
                         (:hs-k2j :hs-k3) (:hs-k1 :hs-j2k) (:hs-j2k :hs-j3) (:hs-k2 :hs-j3k))   ; (S2's links too)
          do (let* ((ma (m a)) (mb (m b)) (w (svref (mv-hits ma) 0)) (hs (hw-hs w))
                    (free (+ (hw-from w) hs 1 (or (hw-stun w) (hitstun (hw-react w)))))
                    (hit (+ (mv-s ma) (mv-a ma) hs (- (mv-s mb) (mv-enter mb)))))
               (check (or (and (< hit free) (< (hit-gap ma mb) 0)) (format t "  Hisagi link ~a -> ~a: hit ~d, free ~d~%" a b hit free)))))
    (let ((o (m :hs-kikon)))
      (check (and (zerop (getf (mv-params o) :dash-max)) (zerop (getf (mv-params o) :ender-dash)) (= 20 (mv-s o)) (= 90 (mv-cooldown o))))
      (dolist (n '(:hs-j3 :hs-k3 :hs-j3k))
        (let ((x (m n))) (check (< (+ (- (mv-total x) (hw-from (svref (mv-hits x) 0)) (mv-r x)) (mv-s o))
                                   (hitstun (hw-react (svref (mv-hits x) 0))))))))
    ;; the sickle's state machine, pure (§7.1): OUT counts only out of his moves (frozen in a move, far or not), RETURNING at
    ;; 60 f or at once when his hand is past 6.5 m of the anchor out of a move; the OUT graph's commands; L / SP2 refused out
    (check (equal (multiple-value-list (hs-out-next :out 10 t t)) '(:out 10)))          ; in a move: frozen, even far
    (check (equal (multiple-value-list (hs-out-next :out 10 nil nil)) '(:out 11)))
    (check (equal (multiple-value-list (hs-out-next :out 59 nil nil)) '(:ret 60)))
    (check (equal (multiple-value-list (hs-out-next :out 3 nil t)) '(:ret 4)))           ; far, out of a move: at once
    (check (equal (multiple-value-list (hs-out-next :in 3 nil t)) '(:in 3)))
    (check (= 60 (loop for n from 0 for o = 0 then o2 for o2 = (nth-value 1 (hs-out-next :out o (evenp n) nil))
                       until (eq :ret (hs-out-next :out o (evenp n) nil)) finally (return o2))))   ; (half the frames in moves)
    (check (and (null (hs-command-for :in :q)) (null (hs-command-for :in :f)) (eq :hs-j1-1h (hs-command-for :out :q))
                (eq :hs-modoshi (hs-command-for :out :f)) (eq :hold (hs-command-for :ret :f)) (eq :hs-j1-1h (hs-command-for :ret :q))
                (null (hs-command-for :out :sp1)) (null (hs-command-for :out :breaker))))
    (check (and (hs-refused-p :out :sig) (hs-refused-p :ret :sp2) (not (hs-refused-p :in :sig)) (not (hs-refused-p :out :sp1))
                (not (hs-refused-p :out :breaker)) (not (hs-refused-p :out :kikon)) (not (hs-refused-p :out :q))))
    (check (and (zerop (length (mv-hits (find-move :hs-modoshi)))) (= 12 (mv-total (find-move :hs-modoshi)))
                (member '(6 hs-sickle-in) (mv-on-frame (find-move :hs-modoshi)) :test #'equal)
                (member '(20 hs-throw-out) (mv-on-frame (find-move :hs-k2s)) :test #'equal)   ; (S1: MAKI the only throw, dormant)
                (equal *hs-throws* '(:hs-k2s)) (member '(22 hs-sickle-in) (mv-on-frame (find-move :hs-k3h)) :test #'equal)
                (member '(20 hs-sickle-in) (mv-on-frame (m :hs-raiden)) :test #'equal)))
    ;; ... on stand-in fighters: the 60 f timer frozen in moves, the far return, the return's arrival, the reset
    (multiple-value-bind (a b) (t-pair k (kit :kenpachi :base))
      (let ((fa (fighter a)) (ga (gauges a)) (st (hs a)))
        (t-at a 0 0) (t-at b 0 -3)
        (setf (hss-state st) :out (hss-out-t st) 0)
        (hs-anchor! a 0.0 -3.0)
        (setf (fighter-state fa) :move (fighter-move fa) (m :hs-j1-1h) (fighter-phase fa) :main (fighter-sf fa) 1)
        (dotimes (i 100) (hs-tick a fa ga))
        (check (and (eq :out (hss-state st)) (= 0 (hss-out-t st))))                        ; 100 frames in a move: frozen
        (setf (fighter-state fa) :idle (fighter-move fa) nil)
        (dotimes (i 59) (hs-tick a fa ga))
        (check (and (eq :out (hss-state st)) (= 59 (hss-out-t st))))
        (hs-tick a fa ga)
        (check (and (eq :ret (hss-state st)) (= *hs-return-frames* (hss-ret-t st))))
        (dotimes (i 7) (hs-tick a fa ga))
        (check (eq :ret (hss-state st)))
        (hs-tick a fa ga)
        (check (eq :in (hss-state st)))                                                    ; arrived after 8 f
        (setf (hss-state st) :out (hss-out-t st) 0) (t-at a 0 4)                            ; 7 m from the anchor: at once
        (hs-tick a fa ga)
        (check (eq :ret (hss-state st)))
        (setf (hss-state st) :out) (hs-reset a)
        (check (eq :in (hss-state st)))
        (setf (gauges-awaken ga) *awaken-max*) (hs-tick a fa ga)                           ; (B2b: B2a's seam gone, the
        (check (= (gauges-awaken ga) *awaken-max*))                                        ;  tick leaves the gauge alone)
        ;; the anchor (§7.1): a throw's first contact of any kind writes the victim's centre; a whiff its line's end along
        ;; his facing on its last active frame (MAKI 3.2), clamped into the arena (S1: MAKI the only throw, dormant; K1 NAGI
        ;; no throw)
        (check (and (not (hs-throw-name-p :hs-k1)) (hs-throw-name-p :hs-k2s)))
        (t-at a 0 0) (t-at b 1.0 -2.0)
        (setf (fighter-state fa) :move (fighter-move fa) (find-move :hs-k2s) (fighter-phase fa) :main (fighter-sf fa) 20)
        (hs-throw-out a)
        (check (and (eq :out (hss-state st)) (not (hss-anchored st))))
        (dolist (res '(:blocked)) (hs-hit a b res (svref (mv-hits (find-move :hs-k2s)) 0) (find-move :hs-k2s) nil t))
        (check (and (hss-anchored st) (~= 1.0 (aref (hss-anchor st) 0)) (~= -2.0 (aref (hss-anchor st) 1))))
        (t-at b 2.0 -3.0) (hs-hit a b :hit (svref (mv-hits (find-move :hs-k2s)) 0) (find-move :hs-k2s) nil t)   ; (first contact)
        (check (~= 1.0 (aref (hss-anchor st) 0)))
        (hs-throw-out a) (setf (fighter-sf fa) 23)                                          ; a whiff: its last active frame
        (hs-tick a fa ga)
        (check (and (hss-anchored st) (~= 0.0 (aref (hss-anchor st) 0)) (~= -3.2 (aref (hss-anchor st) 1))))
        (t-at a 0 -13.0) (hs-throw-out a) (hs-tick a fa ga)                                 ; clamped to r 14.7
        (check (~= (- *arena-radius* 0.3) (hypot (aref (hss-anchor st) 0) (aref (hss-anchor st) 1))))
        (t-at a 0 0 (deg 90)) (setf (fighter-move fa) (find-move :hs-k2s) (fighter-sf fa) 23) (hs-throw-out a) (hs-tick a fa ga)
        (check (and (~= -3.2 (aref (hss-anchor st) 0)) (~= 0.0 (aref (hss-anchor st) 1))))  ; MAKI 3.2 m (yaw 90: -X)
        (multiple-value-bind (x z) (hs-anchor-point 0.0 0.0 0f0 6.0) (check (and (~= x 0.0) (~= z -6.0))))
        ;; the pulls' :seg-fn: the chain from the anchor to his hand; a cast check of HIKI's window: after NAGE hit at 6 m
        ;; (the anchor at his centre) and the drag to 1.6 m the chain runs through him; a side Step's 2.5 m clears it; it
        ;; agrees with the same capsule as a :cap volume (VOL-HIT-P)
        (t-at a 0 0) (hs-anchor! a 0.0 -6.0)
        (multiple-value-bind (ax ay az bx by bz r) (hs-chain-seg a)
          (check (and (~= ax 0.0) (~= az -6.0) (~= ay *hs-anchor-up*) (~= bz (- *hs-hand-ahead*)) (~= by *hs-hand-up*) (~= r 0.35)))
          (check (capsule-cyl-hit-p ax ay az bx by bz r 0f0 0f0 -1.6f0 0.45f0 2.0f0))
          (check (not (capsule-cyl-hit-p ax ay az bx by bz r 2.5f0 0f0 -1.6f0 0.36f0 1.8f0)))
          (let ((v (make-vol :cap (list *hs-hand-ahead* 6.0 1.05 0.35))))
            (check (loop for (tx tz) in '((0.0 -1.6) (0.6 -3.0) (0.9 -4.0) (2.5 -1.6) (0.0 -7.0) (0.0 -6.6))
                         always (eq (and (capsule-cyl-hit-p ax ay az bx by bz r (f32 tx) 0f0 (f32 tz) 0.36f0 1.8f0) t)
                                    (and (vol-hit-p v 0f0 0f0 0f0 0f0 -1f0 (f32 tx) 0f0 (f32 tz) 0.36f0 1.8f0 0f0) t))))))
        (check (window-touches-p (svref (mv-hits (m :hs-k2)) 0) a 0f0 0f0 0f0 0f0 -1f0 0f0 0f0 -1.6f0 0.38f0 1.8f0))
        ;; the windmill (§8.3, Q3 A): a :ranged-ward move, up from f6, one push hit as it comes up (20, 1.5 m, 8 f), cooldown
        ;; 90 from the press, held 20-60 f (HS-KAZA-RELEASE-P), refused while the sickle is out; a ranged hit on it is warded
        ;; while the guard gauge can guard, an unguardable / an empty gauge land
        (let ((x (m :hs-kaza)) (w (svref (mv-hits (m :hs-kaza)) 0)))
          (check (and (member :ranged-ward (mv-flags x)) (= 0 (mv-cooldown x))   ; (S1: 90 -> 0, §23.1)
                      (= 6 (mv-s x)) (= 60 (mv-a x)) (= 14 (mv-r x))
                      (= 1 (length (mv-hits x))) (= 6 (hw-from w)) (= 9 (hw-to w)) (= 20 (hw-dmg w)) (~= 1.5 (hw-kb w)) (= 8 (hw-stun w))
                      (~= 2.0 (mv-reach x)) (~= 360 (/ (* 2 (aref (first (hw-vols w)) 2)) (deg 1))) (null (mv-cost x)))))
        (check (and (not (hs-kaza-release-p 25 6 66 nil)) (hs-kaza-release-p 26 6 66 nil) (not (hs-kaza-release-p 40 6 66 t))
                    (not (hs-kaza-release-p 66 6 66 nil))))
        (check (and (ranged-ward-p t t :neutral t) (not (ranged-ward-p t t :neutral nil))
                    (eq :hit (resolve-contact :guard :unguardable t :ward t :hazard t :in-front nil))
                    (eq :blocked (resolve-contact :guard :hazard t :ward t :in-front nil))))
        (setf (hss-state st) :out)
        (check (and (not (hs-ok a :sig nil)) (not (hs-ok a :sp2 nil)) (hs-ok a :sp1 nil) (hs-ok a :breaker nil) (hs-ok a :kikon nil)))
        (setf (hss-state st) :in)
        (check (and (hs-ok a :sig nil) (hs-ok a :sp2 nil)))
        ;; :command: the OUT graph with a fighter, the IN one without; K while returning: :HOLD (TRY-COMMAND starts nothing)
        (setf (hss-state st) :out)
        (check (and (eq (kit-command-move k :q a) (m :hs-j1-1h)) (eq (kit-command-move k :f a) (find-move :hs-modoshi))
                    (eq (kit-command-move k :q) (m :hs-j1)) (eq (kit-command-move k :f) (m :hs-k1))
                    (eq (kit-command-move k :sig a) (m :hs-kaza))))
        (setf (hss-state st) :ret)
        (check (eq :hold (kit-command-move k :f a)))
        (setf (fighter-state fa) :idle (fighter-move fa) nil)
        (check (null (try-command a fa :f :flash)))
        (check (eq :idle (fighter-state fa)))
        (setf (hss-state st) :in)))
    ;; the K enders' push (Q6 B): from 6.0 m, out of the throw's full reach: 6.0 + the victim's radius + 0.05 (6.43 by a 0.38
    ;; body, 6.50 by Kenpachi's 0.45); a J ender's from J1's (1.4 + 0.3 + r + 0.05). After it: the O lane reaches him from
    ;; where Hisagi stands (no dash; 7.0 + its radius 1.0 + r); SP1 (6.5 + 0.3 + r) too; SP2's 4.5 m line chases him in its
    ;; 16 f startup (STRING-CHASE-SPEED off an ender, <= *ENDER-CHASE-MAX*), measured below
    (check (and (~= 6.0 (ender-push-reach k (m :hs-k3) (m :hs-k1))) (~= 6.0 (ender-push-reach k (find-move :hs-k3h) (m :hs-k1)))
                (~= 1.4 (ender-push-reach k (m :hs-j3) (m :hs-j1)))))
    (dolist (r '(0.34 0.36 0.38 0.45))
      (let* ((push (+ 6.0 (mv-slide (m :hs-k1)) r *ender-push*)) (o (m :hs-kikon)) (ov (first (hw-vols (svref (mv-hits o) 0))))
             (sp1 (m :hs-raiden)) (sp2 (m :hs-shibari)) (d push))
        (check (and (<= 6.39 push 6.5) (<= push (+ (aref ov 2) (aref ov 4) r))
                    (<= push (+ (mv-reach sp1) 0.3 r))))
        (loop for left from (mv-s sp2) downto 1 do (decf d (/ (string-chase-speed d (mv-reach sp2) left *ender-chase-max*) 60.0)))
        (check (<= d (+ (mv-reach sp2) 0.35 r)))
        (when (= r 0.38) (format t "  Hisagi: K ender push ~,2f m (r ~,2f); SP2 chases ~,2f m in its ~d f to ~,2f m; the O lane reaches ~,2f m~%"
                                 push r (- push d) (mv-s sp2) d (+ (aref ov 2) (aref ov 4) r)))))))

;;; ================================================================ Hisagi's S1 (docs/duel/DUEL_HISAGI.md §23, §23.1): the
;;; Shikai's L a bridge from a J hit into the windmill, K from it a K string at the charge's reach (+1 %/f, x1.6 at 60 f)
(defun hs-charge-next-run (to let-at)
  "The windmill's charge after move frames 1..TO (HS-KAZA-TICK's order: count, then L's let-go), L let go from LET-AT on."
  (let ((n 0) (let nil))
    (loop for sf from 1 to to
          do (let ((held (or (null let-at) (< sf let-at))))
               (setf n (hs-charge-next n held let sf 6 66))
               (unless held (setf let t))))
    n))
(let* ((k (kit :hisagi :base)) (kz (kit-move k :hs-kaza)) (kj (kit-move k :hs-kaza-j)))
  (flet ((m (n) (kit-move k n)))
    ;; the bridge: L after J1 / J2 / J3 (and the one-handed J2 / J3 links, where HS-OK refuses it: the sickle is out); none after
    ;; a K link; not a string segment (no J / K follow-up of its own: the K string after it starts fresh at K1)
    (check (and (every (lambda (j) (eq kj (kit-l-link k j))) '(:hs-j1 :hs-j2 :hs-j3 :hs-j2-1h :hs-j3-1h))
                (null (kit-l-link k :hs-j1-1h))   ; (the OUT graph's opener, started by HS-COMMAND: not a kit J link)
                (notany (lambda (n) (kit-l-link k n)) '(:hs-k1 :hs-k2 :hs-k2s :hs-k3 :hs-k3h))
                (null (kit-next k :hs-kaza-j :q)) (null (kit-next k :hs-kaza-j :f)) (not (string-link-p k :hs-kaza-j))
                (not (string-link-p k :hs-kaza)) (eq kz (kit-command-move k :sig))
                (equal (route k :q '((:q) (:q))) '(:hs-j1 :hs-j2 :hs-j3)) (equal (route k :f '((:f) (:f))) '(:hs-k1 :hs-k2 :hs-k3))
                (null (kit-l-after-j (kit :hisagi :bankai))) (null (kit-l-after-j (kit :hisagi :bankai-bind)))
                (~= 0.3 (getf (kit-ai k) :l-after-j))))
    ;; both windmills: no cooldown (「拿掉冷卻」), the same frames, ward, tick and frame-0 reset (the neutral one charges too:
    ;; 「中立的風車可以蓄力接 K」); the bridge's push a stagger, the neutral's 8 f
    (check (and (= 0 (mv-cooldown kz) (mv-cooldown kj)) (= (mv-s kz) (mv-s kj) 6) (= (mv-a kz) (mv-a kj) 60) (= (mv-r kz) (mv-r kj) 14)
                (member :ranged-ward (mv-flags kj)) (eq (mv-tick kz) (mv-tick kj))
                (member '(0 hs-kaza-start) (mv-on-frame kz) :test #'equal) (member '(0 hs-kaza-start) (mv-on-frame kj) :test #'equal)
                (eq :stagger (hw-react (svref (mv-hits kj) 0))) (null (hw-stun (svref (mv-hits kj) 0)))
                (= 8 (hw-stun (svref (mv-hits kz) 0))) (= 20 (hw-dmg (svref (mv-hits kj) 0)))))
    ;; J1 / J2 / J3 -> the windmill combos (its push inside J's flinch / stagger, hitstop on both sides); the windmill -> K1:
    ;; the bridge's combos when K starts by f14 (a charge of at most 9 frames), not from f15; the neutral windmill's never
    (dolist (j '(:hs-j1 :hs-j2 :hs-j3))
      (let* ((ma (m j)) (w (svref (mv-hits ma) 0)) (hs (hw-hs w))
             (free (+ (hw-from w) hs 1 (or (hw-stun w) (hitstun (hw-react w)))))
             (hit (+ (mv-s ma) (mv-a ma) hs (- (mv-s kj) (mv-enter kj)))))
        (check (or (< hit free) (format t "  Hisagi S1 ~a -> L: hit ~d, free ~d~%" j hit free)))))
    (flet ((k1-combos-p (wm kf)
             (let* ((w (svref (mv-hits wm) 0)) (hs (hw-hs w)))
               (< (+ kf hs (mv-s (m :hs-k1))) (+ (hw-from w) hs 1 (or (hw-stun w) (hitstun (hw-react w))))))))
      (check (and (= *hs-kaza-k-from* (hw-to (svref (mv-hits kj) 0))) (k1-combos-p kj 9) (k1-combos-p kj 14) (not (k1-combos-p kj 15))
                  (not (k1-combos-p kz *hs-kaza-k-from*))
                  (= 9 (hs-charge-next-run 14 nil)))))   ; (K at f14, L held throughout: 9 frames of charge, f6-14)
    ;; the charge: +1 a frame held from the up frame f6, at most 60 (x1.6); let go: it stops (held again: no more)
    (check (and (~= 1.0 (hs-charge-scale 0)) (~= 1.01 (hs-charge-scale 1)) (~= 1.37 (hs-charge-scale 37)) (~= 1.6 (hs-charge-scale 60))
                (~= 1.6 (hs-charge-scale 61)) (= 60 (hs-charge-next-run 90 nil)) (= 4 (hs-charge-next-run 90 10))
                (= 0 (hs-charge-next-run 90 3)) (= 0 (hs-charge-next 0 nil nil 10 6 66)) (= 60 (hs-charge-next 60 t nil 30 6 66))
                (= 5 (hs-charge-next 5 t nil 66 6 66)) (= 5 (hs-charge-next 5 t t 20 6 66))))
    ;; K1 NAGI's copies (§23.2: the charge scales K1; K2 / K3 follow the victim, themselves at any charge): the same move
    ;; (name, frames, damage, hooks, links, dead zone) with its arc's r x (1 + n / 100); 0 = the move itself, capped at 60;
    ;; the drawn tip (HS-SCALED-TIP of the art's 6.0) on the arc's edge at every charge (within 0.15 m: the FK rule)
    (dolist (n '(1 9 30 59 60))
      (let* ((sc (hs-charge-scale n)) (a (m :hs-k1)) (b (hs-scaled :hs-k1 n)) (v (first (hw-vols (svref (mv-hits b) 0)))))
        (check (or (and (eq (mv-name a) (mv-name b)) (= (mv-s a) (mv-s b)) (= (mv-a a) (mv-a b)) (= (mv-r a) (mv-r b))
                        (= (mv-dmg a) (mv-dmg b)) (equal (mv-flags a) (mv-flags b)) (~= (mv-track a) (mv-track b))
                        (~= (mv-clip-speed a) (mv-clip-speed b)) (eq (kit-next k :hs-k1 :f) (kit-next k (mv-name b) :f))
                        (~= (* sc 6.0) (mv-reach b)) (~= (* sc 6.0) (aref v 1)) (~= (aref v 2) (aref (first (hw-vols (svref (mv-hits a) 0))) 2))
                        (~= *hs-k-dead* (hw-min (svref (mv-hits b) 0)))
                        (<= (abs (- (hs-scaled-tip 6.0 6.0 n) (aref v 1))) 0.15)
                        (eq (hs-scaled :hs-k2 n) (m :hs-k2)) (eq (hs-scaled :hs-k3 n) (m :hs-k3)))
                   (format t "  Hisagi S1 copy x~,2f~%" sc)))))
    (check (and (eq (m :hs-k1) (hs-scaled :hs-k1 0)) (eq (hs-scaled :hs-k1 60) (hs-scaled :hs-k1 99))
                (~= 9.6 (mv-reach (hs-scaled :hs-k1 60)))))
    ;; the charge's life on stand-ins (HS-TICK): a windmill keeps it; the K string it started plays each link's copy (K1, K2,
    ;; K3 swapped in); any other move (the one-handed J2 off K1), neutral, a hit taken: reset; a K string not from a windmill
    ;; (KSTR NIL) never scales; the far return measured from the throw's charged chain; the whiff's anchor at the charged line
    (multiple-value-bind (a b) (t-pair k (kit :kenpachi :base))
      (let ((fa (fighter a)) (ga (gauges a)) (st (hs a)))
        (declare (ignorable b))
        (t-at a 0 0) (t-at b 0 -3)
        (flet ((in (name &optional (sf 1)) (setf (fighter-state fa) :move (fighter-move fa) (m name) (fighter-phase fa) :main
                                                 (fighter-sf fa) sf)))
          (in :hs-kaza 20) (setf (hss-charge st) 25 (hss-kstr st) nil) (hs-tick a fa ga)
          (check (and (= 25 (hss-charge st)) (eq (fighter-move fa) kz)))
          (in :hs-kaza-j 20) (hs-tick a fa ga)
          (check (= 25 (hss-charge st)))
          (setf (hss-kstr st) t)
          (dolist (name *hs-k-string*)          ; (K1's copy swapped in; K2 / K3 themselves, the anchor kept on him)
            (in name) (t-at b 1.0 -4.0) (hs-tick a fa ga)
            (check (or (and (eq (fighter-move fa) (hs-scaled name 25)) (= 25 (hss-charge st)) (hss-kstr st)
                            (or (eq name :hs-k1) (and (~= 1.0 (aref (hss-anchor st) 0)) (~= -4.0 (aref (hss-anchor st) 1)))))
                       (format t "  Hisagi S1 swap ~a~%" name))))
          (multiple-value-bind (ax ay az bx by bz r) (hs-foe-seg a)   ; K2 / K3's chain: his hand to the victim's centre
            (check (and (~= ax 1.0) (~= az -4.0) (~= ay *hs-anchor-up*) (~= bz (- *hs-hand-ahead*)) (~= by *hs-hand-up*) (~= r *hs-seg-r*)
                        (capsule-cyl-hit-p ax ay az bx by bz r 1.0f0 0f0 -4.0f0 0.36f0 1.8f0))))
          (in :hs-j2-1h) (hs-tick a fa ga)
          (check (and (= 0 (hss-charge st)) (null (hss-kstr st)) (eq (fighter-move fa) (m :hs-j2-1h))))
          (setf (hss-charge st) 40) (in :hs-k1) (hs-tick a fa ga)            ; (K1 from neutral: no windmill, no scale)
          (check (and (eq (fighter-move fa) (m :hs-k1)) (= 0 (hss-charge st))))
          (setf (hss-charge st) 40 (hss-kstr st) t) (in :hs-k2) (setf (fighter-state fa) :stun) (hs-tick a fa ga)
          (check (and (= 0 (hss-charge st)) (null (hss-kstr st))))
          (setf (hss-charge st) 40 (hss-kstr st) t) (setf (fighter-state fa) :idle (fighter-move fa) nil) (hs-tick a fa ga)
          (check (and (= 0 (hss-charge st)) (null (hss-kstr st))))
          ;; NAGI at x1.6 throws nothing: the sickle stays in (S1: no move leaves it out; the dormant throw's chain length
          ;; still scales with a charge it never has)
          (setf (hss-state st) :in (hss-charge st) 60 (hss-kstr st) t)
          (in :hs-k1 (+ (mv-s (m :hs-k1)) (mv-a (m :hs-k1)) -1)) (hs-tick a fa ga) (hs-tick a fa ga)
          (check (and (eq :in (hss-state st)) (eq (fighter-move fa) (hs-scaled :hs-k1 60))))
          (hs-reset a)
          (check (and (eq :in (hss-state st)) (= 0 (hss-charge st))))
          (check (search " k0--0" (hs-hash a)))
          (setf (hss-charge st) 12 (hss-kstr st) t (hss-kz-let st) t)
          (check (search " k12KL" (hs-hash a)))
          (hs-kaza-start a)
          (check (and (= 0 (hss-charge st)) (null (hss-kstr st)) (null (hss-kz-let st))))
          (setf (fighter-state fa) :idle (fighter-move fa) nil))))
    ;; S2 (§23.5, 「被防禦後也能繼續接連段」): S1's :hit-only gone (no move has the flag, fighter.lisp's check removed), so
    ;; K2 / K3 follow a block as every link does: K1's chain opens on its block in the last *CHAIN-LEAD* frames
    (check (and (loop for mv being the hash-values of *moves* never (member :hit-only (mv-flags mv)))
                (not (fboundp 'link-contact-ok-p))
                (let ((x (m :hs-k1)))
                  (and (chain-open-p (- (mv-total x) *chain-lead*) (mv-s x) (mv-a x) (mv-r x) :block)
                       (not (chain-open-p (- (mv-total x) *chain-lead* 1) (mv-s x) (mv-a x) (mv-r x) :block))))))
    ;; S2 (「始解 KJJ, KKJ 時 J 會跳近對手進行攻擊」): the J links after a K, J2K / J3K, are J2 / J3 with S 14 (their clips'
    ;; authored 8 / 9: :clip-s), -6 on block (his J1 punishes: -9 with the J's +3) and the leap tick; no other move leaps
    (dolist (row '((:hs-j2k :hs-j2 8) (:hs-j3k :hs-j3 9)))
      (destructuring-bind (c o cs) row
        (let ((x (m c)) (y (m o)))
          (check (or (and (= *hs-leap-s* (mv-s x) 14) (= (mv-a x) (mv-a y)) (= (mv-r x) (mv-r y)) (= (mv-dmg x) (mv-dmg y))
                          (equal (mv-flags x) (mv-flags y)) (eq (mv-clip x) (mv-clip y)) (~= (mv-reach x) (mv-reach y)) (~= (mv-reach x) 1.4)
                          (~= (mv-clip-speed x) (/ cs 14.0)) (= cs (round (* (mv-s x) (mv-clip-speed x))))
                          (eq (hw-react (svref (mv-hits x) 0)) (hw-react (svref (mv-hits y) 0)))
                          (= (hw-from (svref (mv-hits x) 0)) 14) (= (mv-adv-block x) *hs-leap-block* -6)
                          (eq 'hs-leap-tick (mv-tick x)) (null (mv-tick y))
                          (< (mv-s (m :hs-j1)) (- (+ (mv-adv-block x) (- *quick-block-adv*))))
                          (eq (kit-l-link k c) (m :hs-kaza-j)))   ; (the bridge off them too: J links)
                     (format t "  Hisagi S2 copy ~a~%" c))))))
    (check (loop for mv being the hash-values of *moves*
                 always (eq (eq 'hs-leap-tick (mv-tick mv)) (and (member (mv-name mv) '(:hs-j2k :hs-j3k)) t))))
    ;; the leap (HS-LEAP-SPEED, frame by frame with the victim still): from 2-9.6 m (K1's reach x the charge) it closes to
    ;; J's chase goal 1.0 m (inside its 1.4 reach) by the hit frame, never past him, at most 9.6 m in all; nothing in
    ;; reach already, nothing from the hit frame on; beyond 10.6 m it stops short (the cap)
    (flet ((leap (d0) (let ((d d0) (moved 0.0))
                        (loop for sf from 1 below 20
                              do (let ((step (/ (hs-leap-speed d 1.4 14 sf) 60.0))) (decf d step) (incf moved step)))
                        (values d moved))))
      (dolist (d0 '(2.0 3.0 4.5 6.0 8.0 9.6 10.6))
        (multiple-value-bind (d moved) (leap d0)
          (check (or (and (~= d 1.0 0.01) (<= moved (+ *hs-leap-max* 0.001)))
                     (format t "  Hisagi S2 leap from ~,1f: ~,2f m (moved ~,2f)~%" d0 d moved)))))
      (check (and (~= 0.9 (leap 0.9)) (> (leap 12.0) 1.5) (~= 9.6 (nth-value 1 (leap 12.0)) 0.01)
                  (zerop (hs-leap-speed 6.0 1.4 14 14)) (zerop (hs-leap-speed 6.0 1.4 14 20))
                  (~= (hs-leap-speed 9.6 1.4 14 1) (/ (* 60 8.6) 13)))))
    ;; his CPU (HS-AI-MOVE, the Shikai's :move-reflex): on a K1 / K2 hit's land step, beyond the dead zone, his intent close
    ;; (:approach / :pressure): one roll *HS-AI-LEAP-P* (EASY <= NORMAL <= HARD) -> J (the leap), else K; at :zone /
    ;; :defend, inside the dead zone: K, no roll; off any other step, a block or another link (K2J: no J after it): nothing
    (check (and (eq 'hs-ai-move (getf (kit-ai k) :move-reflex))
                (<= (getf *hs-ai-leap-p* :easy) (getf *hs-ai-leap-p* :normal) (getf *hs-ai-leap-p* :hard))))
    (check (and (hs-ai-leap-wanted-p 5.0 :approach) (hs-ai-leap-wanted-p 9.6 :pressure) (hs-ai-leap-wanted-p 2.1 :approach)
                (not (hs-ai-leap-wanted-p 2.0 :approach)) (not (hs-ai-leap-wanted-p 5.0 :zone)) (not (hs-ai-leap-wanted-p 5.0 :defend))))
    (multiple-value-bind (a b) (t-pair k (kit :kenpachi :base))   ; (the steps that roll nothing: the host has no sim stream)
      (declare (ignore b))
      (let ((fa (fighter a)) (br (make-brain)))
        (unless (fboundp 'why) (setf (symbol-function 'why) (lambda (b r c) (declare (ignore b r)) c)))
        (flet ((cpu (name intent d &key (sf 22) (land 22) (contact :hit))
                 (setf (fighter-state fa) :move (fighter-move fa) (m name) (fighter-sf fa) sf (fighter-land-sf fa) land
                       (fighter-contact fa) contact (fighter-queued fa) nil (fighter-dist fa) d (brain-intent br) intent)
                 (hs-ai-move a br fa (m name))))
          (check (and (eq :f (cpu :hs-k1 :zone 5.0)) (eq :f (cpu :hs-k2 :defend 8.0)) (eq :f (cpu :hs-k1 :approach 1.9))
                      (null (cpu :hs-k1 :approach 5.0 :sf 23)) (null (cpu :hs-k1 :approach 5.0 :contact :block))
                      (null (cpu :hs-k2j :approach 5.0)) (null (cpu :hs-j1 :approach 5.0)) (null (cpu :hs-k3 :approach 5.0))))
          (setf (fighter-state fa) :idle (fighter-move fa) nil))))
    ;; the ender push stays measured from the uncharged 6.0 m (a restarted string is uncharged; the O lane / SP1 reach it)
    (check (~= 6.0 (ender-push-reach k (m :hs-k3) (hs-scaled :hs-k1 60))))))

;;; ================================================================ Hisagi's Bankai (docs/duel/DUEL_HISAGI.md §17, batch B2b)
;; the ranged mode (§17.1) and the bind mode (§17.3) as their tables; the budget's own rows (the generic string walk above
;; with (:hisagi :bankai)'s exception) and every link with its hitstop; KUBIKAKE (§17.2); the bind's bookkeeping (B0-B16)
;; on stand-in fighters, through B1b's shared readers (DEAL-DAMAGE, REIATSU-OF / -SPEND!, HEAL!, SETTLE-KONPAKU, BIND-STEP!,
;; TIME-UP); the release rule (Q9 A); the mode switch only out of a move; HIKIYOSE's drag (a cast check: no hit window)
(defvar *t-moved* nil)
(defun set-slide (e dist frames dx dz) (push (list e dist frames dx dz) *t-moved*))   ; (stand-ins: no motion)
(defun refresh-look (e) (declare (ignore e)) nil)
(defun start-move (e mv &optional button)
  (declare (ignore button))
  (let ((f (fighter e))) (setf (fighter-state f) :move (fighter-move f) mv (fighter-sf f) (mv-enter mv) (fighter-phase f) :main
                               (fighter-contact f) nil (fighter-queued f) nil))
  mv)
(defvar *t-ends* nil)
(defun hs-p-pressed! (e) (declare (ignore e)) nil)                                     ; (no vpad: HSS-REL-HELD set below)
(with-open-file (in (merge-pathnames "../duel/lisp/hisagi-art.lisp" *load-truename*))   ; (the drawn reaches, the art's data)
  (let ((*package* (find-package :duel)))
    (loop for form = (read in nil in) until (eq form in)
          when (and (consp form) (eq (first form) 'defparameter)
                    (member (second form) '(*hs-strike-reach* *hs-flights* *hs-letout* *hs-bk-chains* *hs-lashes*)))
            do (eval form))))
(defun hs-bind-end-effects! (b) (push b *t-ends*))                                     ; (B9: clips, reels, hazards)
(let* ((kr (kit :hisagi :bankai)) (kb (kit :hisagi :bankai-bind)))
  (flet ((m (n) (find-move n)))
    ;; the forms: both awakened (Kikon 3), the stats; the base form awakens into the ranged mode; the hooks B1b asks
    (check (and (kit-awakening kr) (kit-awakening kb) (= 3 (kit-kikon-konpaku kr)) (= 3 (kit-kikon-konpaku kb))
                (~= (kit-mult kr) 1.0) (~= (kit-taken kr) 1.0) (~= (kit-walk kr) 2.8) (~= (kit-run kr) 8.5)
                (~= (kit-walk kb) 3.8) (~= (kit-run kb) 9.0) (~= (kit-push-reach kr) 7.5) (~= *hs-b-push-reach* (kit-push-reach kb))   ; (§22.9: from 2.95, past K1 HIKIGIRI's capsule)
                (eq :bankai (kit-endless-form kb))))
    (check (every (lambda (k) (every (lambda (h) (kit-hook k h)) '(:bind :bind-damage :bind-pool :bind-heal :bind-step
                                                                   :bind-resolve :bind-snapshot)))
                  (list kr kb)))
    (check (and (kit-hook kb :p) (kit-hook kb :p-label) (null (kit-hook kr :p)) (null (kit-hook kr :p-label))))   ; (B4c: the
                                                                   ; ranged P inert, KUBIKAKE on SP2; the bind's P the release)
    (check (notany (lambda (h) (kit-hook (kit :hisagi :base) h)) '(:bind :p :p-label)))
    ;; the tables: S A R dmg guard block reach (§17.1 / §17.3)
    (dolist (row '((:hs-r-j1 14 3 12 22 8 -2 5.0) (:hs-r-k1 16 4 22 40 14 -3 4.0)   ; (B4c, §22.4: the openers, then
                   (:hs-r-j2 10 3 13 19 8 -2 4.5) (:hs-r-k2s 21 4 24 37 14 -3 6.0)          ;  the spread links,
                   (:hs-r-j3 10 3 18 26 12 -4 5.0) (:hs-r-k3 21 5 34 56 18 -20 6.0)
                   (:hs-r-k2 27 10 24 25 14 -3 8.0) (:hs-r-j2s 16 3 13 29 8 -2 5.0)         ;  the gathered ones)
                   (:hs-r-k3g 27 5 34 86 18 -20 6.0) (:hs-r-j3g 16 3 18 39 12 -4 5.0)
                   (:hs-r-l 10 4 32 30 14 -16 3.0) (:hs-r-sp1 20 3 24 110 22 -14 9.0) (:hs-r-sp2 30 14 30 70 22 -18 10.0)   ; (B4d: L
                   (:hs-r-kubikake 24 4 30 40 14 -20 7.0)
                   (:hs-b-j1 8 3 12 32 8 -2 1.5) (:hs-b-j2 8 3 13 32 8 -2 1.5) (:hs-b-j3 9 3 18 40 12 -4 1.5)
                   (:hs-b-k1 18 4 20 64 14 -3 2.6) (:hs-b-k2 20 4 24 56 14 -3 2.8) (:hs-b-k3 22 5 34 80 18 -20 3.0)
                   (:hs-b-sp1 14 3 24 110 22 -14 4.0) (:hs-b-sp2 18 4 28 120 22 -14 3.0)   ; (B4c: SP2 KAIBAKU-GEKI,
                   (:hs-b-l 30 4 36 70 30 -24 3.0)))                                        ;  L KOJO)
      (destructuring-bind (name s a r dmg g adv reach) row
        (let ((x (m name)))
          (check (or (and (= s (mv-s x)) (= a (mv-a x)) (= r (mv-r x)) (= dmg (mv-dmg x)) (= g (hw-guard (svref (mv-hits x) 0)))
                          (= adv (mv-adv-block x)) (~= reach (mv-reach x)))
                     (format t "  Hisagi Bankai table mismatch ~s~%" name))))))
    ;; the routes' ratios (the user: 「散 −3 幀×0.85／聚 +3 幀×1.3」): every spread / gathered link 2-3 against its base
    ;; (B4a's J2 S 13 dmg 22, J3 13 / 30; the K before the marks: K2 S 24 dmg 44, K3 24 / 66), K2's 57 = 25 + 32; every
    ;; route K link at :enter 6 (S_eff 15 spread, 21 gathered)
    (flet ((dmg (n) (loop for w across (mv-hits (m n)) sum (hw-dmg w))))
      (loop for (n bs bd) in '((:hs-r-j2 13 22) (:hs-r-k2s 24 44) (:hs-r-j3 13 30) (:hs-r-k3 24 66)
                               (:hs-r-k2 24 44) (:hs-r-j2s 13 22) (:hs-r-k3g 24 66) (:hs-r-j3g 13 30))
            do (let ((g (member n *hs-r-gather-links*)))
                 (check (or (and (= (mv-s (m n)) (+ bs (if g *hs-r-gather-s* *hs-r-spread-s*)))
                                 (= (dmg n) (round (* bd (if g *hs-r-gather-mult* *hs-r-spread-mult*))))
                                 (if (eq (mv-kind (m n)) :flash) (= 6 (mv-enter (m n))) (zerop (mv-enter (m n)))))
                            (format t "  Hisagi B4c ratio ~a: S ~d dmg ~d~%" n (mv-s (m n)) (dmg n))))))
      (check (and (equal (sort (copy-list (append *hs-r-spread-links* *hs-r-gather-links*)) #'string<)
                         (sort (remove-duplicates (loop for (nil nil to) in (kit-strings kr) collect to)) #'string<))
                  (= -3 *hs-r-spread-s*) (~= 0.85 *hs-r-spread-mult*) (= 3 *hs-r-gather-s*) (~= 1.3 *hs-r-gather-mult*)
                  (equal '(25 32) (map 'list #'hw-dmg (mv-hits (m :hs-r-k2)))) (= 57 (dmg :hs-r-k2)))))
    (check (and (= 14 (- (mv-s (m :hs-b-k2)) (mv-enter (m :hs-b-k2)))) (= 14 (- (mv-s (m :hs-b-k3)) (mv-enter (m :hs-b-k3))))
                (= 20 (- (mv-s (m :hs-r-sp2c)) (mv-enter (m :hs-r-sp2c))))
                (= 42 (mv-whiff (m :hs-r-kubikake))) (zerop (mv-cooldown (m :hs-r-l))) (zerop (mv-cooldown (m :hs-b-l)))
                (= 10 *hs-saharai-s*) (= 32 *hs-saharai-r*) (= -16 *hs-saharai-adv*)   ; (B4d, §22.8: L 14 / 22 / -4, cd 120 ->)
                (~= (mv-clip-speed (m :hs-r-l)) 1.4) (~= 3.5 *hs-saharai-hit*) (~= 3.5 *hs-saharai-block*)   ; (S1, §23.3: both 3.5)
                   ; (its clip's S 14 on S 10)
                (= 90 (mv-cooldown (m :hs-r-kikon))) (= 90 (mv-cooldown (m :hs-b-kikon)))
                (zerop (length (mv-hits (m :hs-b-unwind)))) (= 20 (mv-total (m :hs-b-unwind)))
                (= 24 (hw-stun (svref (mv-hits (m :hs-r-j1)) 0))) (= 24 (hw-stun (svref (mv-hits (m :hs-r-j2)) 0)))
                (= 30 (hw-stun (svref (mv-hits (m :hs-r-kubikake)) 0))) (= 40 (hw-stun (svref (mv-hits (m :hs-r-sp1)) 0)))
                (equal '(30 40) (map 'list #'hw-from (mv-hits (m :hs-r-sp2)))) (equal '(70 90) (map 'list #'hw-dmg (mv-hits (m :hs-r-sp2))))
                (eq :knockdown (hw-react (svref (mv-hits (m :hs-r-sp2)) 1)))
                (zerop (getf (mv-params (m :hs-r-kikon)) :dash-max)) (= 30 (getf (mv-params (m :hs-b-kikon)) :dash-max))
                (~= 14.0 (getf (mv-params (m :hs-b-kikon)) :speed))))
    ;; beyond 2.0 m everything of the ranged mode is :ranged (the chain), the openers and the throw take no close-in
    (dolist (n '(:hs-r-j1 :hs-r-j2 :hs-r-j2s :hs-r-j3 :hs-r-j3g :hs-r-k1 :hs-r-k2 :hs-r-k2s :hs-r-k3 :hs-r-k3g
                 :hs-r-sp1 :hs-r-sp2 :hs-r-kubikake))
      (check (and (member :ranged (mv-flags (m n))) (~= 2.0 (getf (mv-params (m n)) :melee-range)))))
    (check (and (member :no-close (mv-flags (m :hs-r-j1))) (member :no-close (mv-flags (m :hs-r-k1)))
                (member :no-close (mv-flags (m :hs-r-kubikake))) (~= 30.0 (mv-track (m :hs-r-kubikake)))
                (~= 30.0 (mv-track (m :hs-r-sp1))) (~= 0.0 (mv-track (m :hs-b-unwind)))))
    ;; the six routes per mode and their damage on hit (§17.1: 74 110 132 162 126 104; §17.3: 104 144 168 200 160 136)
    (flet ((dmg (&rest names) (let ((i 0))   ; (B4c: every window a hit, gathered K2's two)
                                (loop for n in names
                                      sum (loop for w across (mv-hits (m n)) sum (hit-damage (hw-dmg w) nil nil (incf i) nil))))))
      (check (or (equal (list (dmg :hs-r-j1 :hs-r-j2 :hs-r-j3) (dmg :hs-r-j1 :hs-r-j2 :hs-r-k3) (dmg :hs-r-j1 :hs-r-k2s :hs-r-k3)
                              (dmg :hs-r-k1 :hs-r-k2 :hs-r-k3g) (dmg :hs-r-k1 :hs-r-k2 :hs-r-j3g) (dmg :hs-r-k1 :hs-r-j2s :hs-r-j3g))
                        '(67 97 115 174 132 108))
                 (format t "  Hisagi B4c route damage ~a~%"
                         (list (dmg :hs-r-j1 :hs-r-j2 :hs-r-j3) (dmg :hs-r-j1 :hs-r-j2 :hs-r-k3) (dmg :hs-r-j1 :hs-r-k2s :hs-r-k3)
                               (dmg :hs-r-k1 :hs-r-k2 :hs-r-k3g) (dmg :hs-r-k1 :hs-r-k2 :hs-r-j3g) (dmg :hs-r-k1 :hs-r-j2s :hs-r-j3g)))))
      (check (equal (list (dmg :hs-b-j1 :hs-b-j2 :hs-b-j3) (dmg :hs-b-j1 :hs-b-j2 :hs-b-k3) (dmg :hs-b-j1 :hs-b-k2s :hs-b-k3)
                          (dmg :hs-b-k1 :hs-b-k2 :hs-b-k3) (dmg :hs-b-k1 :hs-b-k2 :hs-b-j3) (dmg :hs-b-k1 :hs-b-j2s :hs-b-j3))
                    '(104 144 168 200 160 136))))
    ;; the opener decides the route (B4c, §22.4): J1 -> spread, K1 -> gathered, in all six routes
    (check (and (equal (route kr :q '((:q) (:q))) '(:hs-r-j1 :hs-r-j2 :hs-r-j3))
                (equal (route kr :q '((:q) (:f))) '(:hs-r-j1 :hs-r-j2 :hs-r-k3))
                (equal (route kr :q '((:f) (:f))) '(:hs-r-j1 :hs-r-k2s :hs-r-k3))
                (equal (route kr :f '((:f) (:f))) '(:hs-r-k1 :hs-r-k2 :hs-r-k3g))
                (equal (route kr :f '((:f) (:q))) '(:hs-r-k1 :hs-r-k2 :hs-r-j3g))
                (equal (route kr :f '((:q) (:q))) '(:hs-r-k1 :hs-r-j2s :hs-r-j3g))
                (equal (route kr :q '((:f) (:q))) '(:hs-r-j1 :hs-r-k2s))              ; (JKJ: switched back, eaten)
                (every (lambda (n) (member :ender (mv-flags (m n)))) '(:hs-r-j3 :hs-r-k3 :hs-r-j3g :hs-r-k3g))
                (notany (lambda (n) (member :ender (mv-flags (m n)))) '(:hs-r-j1 :hs-r-k1 :hs-r-j2 :hs-r-k2 :hs-r-j2s :hs-r-k2s))))
    (check (equal (route kb :q '((:f) (:f))) '(:hs-b-j1 :hs-b-k2s :hs-b-k3)))
    ;; every link combos with its hitstop on both sides (the victim's stun from its hit frame outlasts the next link's
    ;; hit), as in the Shikai's; TSUISA's 10 f drag ends before J2s's hit; every link 3 -> the O module inside its
    ;; stagger / crumple (KOSA: no dash; KOSHU: its dash from the ender's reach); SP2's copy off J1 / K1 combos; SP1 too
    (dolist (k (list kr kb))
      (loop for (a nil b) in (kit-strings k)
            when (and (plusp (length (mv-hits (m a)))) (plusp (length (mv-hits (m b)))))   ; (B4a: the placed K: below)
            do (let* ((ma (m a)) (mb (m b)) (w (svref (mv-hits ma) (1- (length (mv-hits ma))))) (hs (hw-hs w))   ; (its last hit:
                      (free (+ (hw-from w) hs 1 (if (eq (hw-react w) :launch)                    ;  gathered K2's launch, the
                                                    (ceiling (* 60 (/ (* 2 (getf *air-vy* :launch)) *gravity*)))   ;  air time)
                                                    (or (hw-stun w) (hitstun (hw-react w))))))
                      (hit (+ (mv-s ma) (mv-a ma) hs (- (mv-s mb) (mv-enter mb)))))
                 (check (or (< hit free) (format t "  Hisagi Bankai link ~a -> ~a: hit ~d, free ~d~%" a b hit free)))))
      (dolist (sp (if (eq k kr) (list (m :hs-r-kubikake-c) (kit-command-move k :sp1)) (list (m :hs-r-sp2c))))
        (dolist (n (remove-if (lambda (n) (or (zerop (length (mv-hits n)))   ; (B4c: the bind's rain copy S_eff 20 combos off
                                              (and (eq sp (m :hs-r-sp2c)) (eq n (m :hs-b-j1)))))   ;  K1, not off J1's flinch 18)
                              (list (kit-command-move k :q) (kit-command-move k :f))))
          (let* ((w (svref (mv-hits n) 0)) (hs (hw-hs w)))
            (check (or (< (+ (mv-s n) (mv-a n) hs (- (mv-s sp) (mv-enter sp))) (+ (hw-from w) hs 1 (or (hw-stun w) (hitstun (hw-react w)))))
                       (format t "  Hisagi Bankai SP ~a off ~a: no combo~%" (mv-name sp) (mv-name n))))))))
    (let ((o (m :hs-r-kikon)))
      (dolist (n '(:hs-r-j3 :hs-r-k3 :hs-r-j3g :hs-r-k3g))
        (let ((x (m n))) (check (< (+ (mv-a x) (mv-s o)) (hitstun (hw-react (svref (mv-hits x) 0))))))))
    ;; the K ender push from 7.5 m (Q6 B's rule): ~7.95 m, inside the O lane (9 m + its r 1.0) and SP1's 9 m line; J3's
    ;; from J1's 4.0 m (~4.45 m), inside SP2's 10 m lane
    (check (and (~= 7.5 (ender-push-reach kr (m :hs-r-k3) (m :hs-r-k1))) (~= 5.0 (ender-push-reach kr (m :hs-r-j3) (m :hs-r-j1)))   ; (S1: J1 to 5.0)
                ))
    ;; the bind's K ender push from 2.95 m (§22.9): past K1 HIKIGIRI's capsule (2.6 m + its r 0.35 + the victim's 0.35),
    ;; so a restarted K1 cannot touch him; its J ender's from J1's 1.5 m as before
    (check (and (~= 2.95 (ender-push-reach kb (m :hs-b-k3) (m :hs-b-k1))) (~= 1.5 (ender-push-reach kb (m :hs-b-j3) (m :hs-b-j1)))
                (> (+ 2.95 0.35 *ender-push*) (+ 2.6 0.35 0.35))))
    (dolist (r '(0.34 0.38 0.45))
      (let ((push (+ 7.5 r *ender-push*)) (ov (first (hw-vols (svref (mv-hits (m :hs-r-kikon)) 0)))))
        (check (and (<= 7.85 push 8.05) (<= push (+ (aref ov 2) (aref ov 4) r)) (<= push (+ 9.0 0.3 r))))))
    ;; KUBIKAKE (§17.2): the 200 at the press (from idle / guard / a run only; not blockstun; cooling; a bind on the field)
    ;; (B4c: on SP2, its states the generic SP2's: from neutral, or cancelled off a J / K hit)
    (check (and (hs-kubi-ready-p 200.0 0 nil) (hs-kubi-ready-p 300.0 0 nil) (not (hs-kubi-ready-p 199.9 0 nil))
                (not (hs-kubi-ready-p 300.0 1 nil)) (not (hs-kubi-ready-p 300.0 0 t))))
    ;; ... on hit +16 (the 30 f reel against the recovery cut to 14 from the hit): a bind J1 (S 8) and SP1 (S 14) combo,
    ;; a bind K1 (S 18) does not (hitstop freezes both alike)
    (check (and (< (+ *hs-kubi-cut* (mv-s (m :hs-b-j1))) *hs-bind-reel*)   ; (B4c: the bind's SP1 the rain, S 30: no combo)
                (> (+ *hs-kubi-cut* (mv-s (kit-command-move kb :sp1))) *hs-bind-reel*)
                (> (+ *hs-kubi-cut* (mv-s (m :hs-b-k1))) *hs-bind-reel*) (= 16 (- *hs-bind-reel* *hs-kubi-cut*))))
    ;; ... a side Step clears it (the cast check): its line turns at most 30 deg/s over its whole 24 f startup (12 deg);
    ;; a victim 2.5 m aside at 4-7 m stays clear of the 0.35 m line + his body (a whiff: R 42, the run-in punishes)
    (let ((turn (deg (* 30.0 (/ 24 60.0)))))
      (dolist (d '(4.0 5.5 7.0))
        (check (> (- 2.5 (* d (sin turn))) (+ 0.35 0.45)))))
    ;; the release: at once from idle / guard / blockstun / a run, in hitstun only past the combo's 2nd hit (Q9 A, as a
    ;; Burst); during his own move held to its last frame (never a cancel)
    (check (and (hs-rel-free-p :idle nil) (hs-rel-free-p :guard-hit nil) (hs-rel-free-p :run nil) (not (hs-rel-free-p :stun nil))
                (hs-rel-free-p :stun t) (hs-rel-free-p :air t) (not (hs-rel-free-p :move t))))
    (check (and (not (hs-rel-due-p 40 42)) (hs-rel-due-p 41 42)))
    (check (and (= 1300 (hs-grey-loss 1300 1300 9 8)) (= 250 (hs-grey-loss 1000 750 3 3))
                (hs-release-wanted-p 700 300) (not (hs-release-wanted-p 600 300))))
    ;; ---- the bind on stand-ins: H (P1, Hisagi in the ranged mode) binds K (P2, Kenpachi)
    (multiple-value-bind (h o) (t-pair kr (kit :kenpachi :base))
      (let ((fh (fighter h)) (gh (gauges h)) (go (gauges o)) (st (hs h)))
        (setf (fighter-form fh) :bankai (gauges-awakened gh) t (fighter-character fh) :hisagi)
        (t-at h 0 0) (t-at o 0 -5)
        ;; SP2 (B4c, 「把卍解捆綁給到 SP2，但發動不會消耗 SP」): KUBIKAKE from idle with his own 200 (the cooldown set at its
        ;; start, no bar spent), refused under 200 (the :ok hook: the cue); P in the ranged mode does nothing
        (setf (gauges-reiatsu gh) 150f0 (fighter-state fh) :idle (fighter-move fh) nil)
        (check (and (null (try-command h fh :sp2)) (eq :idle (fighter-state fh)) (not (kit-command-ok-p h :sp2))
                    (null (try-command h fh :awaken)) (eq :idle (fighter-state fh)) (zerop (kit-command-cost kr :sp2))))
        (setf (gauges-reiatsu gh) 250f0 (gauges-reiatsu go) 180f0)
        (check (and (try-command h fh :sp2) (eq (fighter-move fh) (m :hs-r-kubikake)) (= 250f0 (gauges-reiatsu gh))
                    (equal '((0 hs-kubi-start)) (mv-on-frame (m :hs-r-kubikake)))
                    (equal '((6 hs-kubi-start)) (mv-on-frame (m :hs-r-kubikake-c)))))
        (hs-kubi-start h)
        (check (= 180 (hss-kubi-cd st)))
        (check (not (kit-command-ok-p h :sp2)))                           ; (cooling)
        ;; ... cancelled off a J / K hit (「可以，命中確認後接」): its copy :enter 6 (S_eff 18), the rest its data; a blocked
        ;; link: the move itself (no cancel: the generic SP rules)
        (let ((c (m :hs-r-kubikake-c)) (b (m :hs-r-kubikake)))
          (check (and (= 6 (mv-enter c)) (= (mv-s c) (mv-s b)) (= (mv-dmg c) (mv-dmg b)) (eq (mv-on-land c) 'hs-kubi-land)
                      (~= 2.0 (hw-min (svref (mv-hits c) 0))) (zerop (mv-cost c)))))
        (start-move h (m :hs-r-j1)) (setf (fighter-contact fh) :hit)
        (check (eq (kit-command-move kr :sp2 h) (m :hs-r-kubikake-c)))
        (setf (fighter-contact fh) :block)
        (check (eq (kit-command-move kr :sp2 h) (m :hs-r-kubikake)))
        (start-move h (m :hs-r-kubikake))
        ;; ... its hit at contact: the yank to 2.0 m (12 f), the recovery cut to 14, the cooldown cleared, the bind due now;
        ;; under 200 at contact (星 drained him): a plain hit
        (setf (fighter-sf fh) 24 (fighter-contact fh) :hit *t-moved* nil *match-tick* 500)
        (hs-kubi-land h)
        (check (and (= 500 (hss-bind-t st)) (zerop (hss-kubi-cd st)) (= (- (mv-total (m :hs-r-kubikake)) 14) (fighter-sf fh))
                    (equal (list 3.0 12) (subseq (first *t-moved*) 1 3))))
        (setf (gauges-reiatsu gh) 199f0 (hss-bind-t st) -1)
        (hs-kubi-land h)
        (check (= -1 (hss-bind-t st)))
        (setf (gauges-reiatsu gh) 250f0)
        (hs-kubi-land h)
        ;; the bind starts at the step's end (the tick), the mode switched only once he is out of the move
        (hs-bk-tick h fh gh)
        (check (and (hss-bound st) (eq (bind-of o) h) (eq (bind-of h) h) (eq :bankai (fighter-form fh))))   ; (still in KUBIKAKE)
        (check (and (= (hss-r0 st) (gauges-reishi gh)) (= (hss-or0 st) (gauges-reishi go)) (= 9 (hss-k0 st) (hss-ok0 st))
                    (= (hss-pool st) 430f0) (= (reiatsu-of o) (reiatsu-of h) 430f0) (= 4 (reiatsu-bars o))))
        (incf *match-tick*)
        (setf (fighter-state fh) :idle (fighter-move fh) nil)
        (hs-bk-tick h fh gh)
        (check (eq :bankai-bind (fighter-form fh)))                       ; (a SET-FORM out of the move)
        (check (equal (hs-p-label h) "FREE"))
        ;; B3: the drain 1 per 2 nominal damage of either side, exact on odd damage; grey Reishi floors at 0, no Soul Break
        (check (and (null (deal-damage h o 7)) (= (hss-pool st) 426.5f0) (= (gauges-reishi go) (- (hss-or0 st) 7))))
        (check (and (null (deal-damage o h 2000)) (= 0 (gauges-reishi gh)) (null *soul-breaks*) (= (hss-pool st) 0f0)))
        (setf (hss-pool st) 426.5f0 (gauges-reishi gh) (hss-r0 st))
        ;; B4 every gain frozen; B5 SPs of either side from the pool (refused under the cost)
        (reiatsu-gain! o 50.0) (reiatsu-gain! h 50.0)
        (check (and (= (gauges-reiatsu go) 180f0) (= (gauges-reiatsu gh) 250f0)))
        (check (kit-command-ok-p o :sp1))
        (reiatsu-spend! o 1) (reiatsu-spend! h 2)
        (check (= (hss-pool st) 126.5f0))
        (setf (hss-pool st) 150f0)
        (check (and (kit-command-ok-p h :sp1 kb) (kit-command-ok-p h :sp2 kb)))   ; (B4c: KAIBAKU-GEKI spends nothing)
        (setf (hss-pool st) 50f0)
        (check (and (not (kit-command-ok-p h :sp1 kb)) (kit-command-ok-p h :sp2 kb) (zerop (kit-command-cost kb :sp2))))
        (setf (hss-pool st) 426.5f0)
        ;; B6 a real heal raises the snapshot (capped)
        (setf (gauges-reishi go) 600 (hss-or0 st) 1000)
        (heal! o 100)
        (check (and (= (gauges-reishi go) 700) (= (hss-or0 st) 1100) (= (bind-grey-frac o) (f32 (/ 1100 (float (gauges-reishi-max go)))))))
        ;; B2 a Kikon inside plays: grey souls (Konpaku floors at 0), no K.O., the bind goes on
        (setf (gauges-konpaku go) 2 (fighter-kikon-n (fighter h)) 3)
        (check (and (null (settle-konpaku h o nil)) (= 0 (gauges-konpaku go)) (hss-bound st) (= 9 (bind-grey-souls o))))
        ;; Kenpachi's Bankai refused while bound (B11)
        (check (not (bankai-ok-p o)))
        ;; the release (Q9 A): from idle at once; in a combo's 1st hit not (the press stays buffered), from its 2nd yes
        (setf (fighter-state fh) :stun (fighter-combo-hits fh) 1 (fighter-lock fh) 0)
        (check (and (null (try-command h fh :awaken)) (not (hss-rel st))))
        (setf (fighter-combo-hits fh) 2)
        (check (and (try-command h fh :awaken) (hss-rel st)))
        (setf (hss-rel st) nil (fighter-state fh) :idle (fighter-combo-hits fh) 0)
        ;; ... during his own move: held to its last frame (the mode stays bind while he is in it)
        (start-move h (m :hs-b-k1))
        (setf (hss-rel-held st) t (fighter-sf fh) 10)
        (hs-bk-tick h fh gh)
        (check (and (not (hss-rel st)) (hss-rel-held st)))
        (setf (fighter-sf fh) (1- (move-end-frame 18 4 20 (mv-whiff (m :hs-b-k1)) nil nil)))
        (hs-bk-tick h fh gh)
        (check (and (hss-rel st) (not (hss-rel-held st))))
        ;; B8 the release at the step's release slot: the snapshot back (the grey Kikon undone, the heal kept), the pool's
        ;; 426.5 to him first (300) and the rest (126.5) to Hisagi; the end effects; the ranged mode once out of the move
        (setf *t-ends* nil (gauges-reishi gh) 100)
        (bind-step! h :release)
        (check (and (not (hss-bound st)) (null (bind-of o)) (= (gauges-reishi go) 1100) (= (gauges-konpaku go) 9)
                    (= (gauges-reishi gh) (hss-r0 st)) (= (gauges-reiatsu go) 300f0) (= (gauges-reiatsu gh) 126.5f0)
                    (equal *t-ends* (list h))))
        (hs-bk-tick h fh gh)
        (check (eq :bankai-bind (fighter-form fh)))                       ; (in K1 still: no switch inside a move)
        (setf (fighter-state fh) :idle (fighter-move fh) nil)
        (hs-bk-tick h fh gh)
        (check (eq :bankai (fighter-form fh)))
        ;; B7 the drained end, both at Reishi 0 (the opponent's Soul Break queued first), the grey counts cleared
        (hs-bind-start! h)
        (setf (gauges-reishi go) 1 (gauges-reishi gh) 1 (hss-pool st) 1.5f0 *soul-breaks* nil *kikons* nil *t-ends* nil)
        (check (and (null (deal-damage h o 2)) (null (deal-damage o h 1))))
        (check (and (= (hss-pool st) 0f0) (null *soul-breaks*) (plusp (gauges-grey gh))))
        (bind-step! h :hits)
        (check (and (not (hss-bound st)) (equal (reverse *soul-breaks*) (list (cons h o) (cons o h)))
                    (= 0 (gauges-grey gh) (gauges-grey go)) (= 0f0 (gauges-reiatsu gh) (gauges-reiatsu go)) (null *t-ends*)))
        ;; ... a Kikon victim this step gets no Soul Break on top; nobody at 0: the end effects (the reel, UNWIND)
        (hs-bind-start! h)
        (setf (gauges-reishi go) 0 (gauges-reishi gh) 500 (hss-pool st) 0f0 *soul-breaks* nil *kikons* (list (list h o nil)))
        (bind-step! h :hits)
        (check (and (null *soul-breaks*) (null *t-ends*)))
        (hs-bind-start! h)
        (setf (gauges-reishi go) 300 (gauges-reishi gh) 500 (hss-pool st) 0f0 *soul-breaks* nil *kikons* nil)
        (bind-step! h :hits)
        (check (and (null *soul-breaks*) (equal *t-ends* (list h))))
        ;; ... a grey 0 Konpaku (grey Kikons) with Reishi left becomes real: queued, so SETTLE-SOULS K.O.s him
        (hs-bind-start! h)
        (setf (gauges-reishi go) 300 (gauges-konpaku go) 0 (hss-pool st) 0f0 *soul-breaks* nil *t-ends* nil)
        (bind-step! h :hits)
        (check (and (equal *soul-breaks* (list (cons h o))) (settle-konpaku h o t)))
        ;; a release and a drain on one step: the release (before the hits) wins
        (setf (gauges-konpaku go) 9 (gauges-reishi go) 1300 *soul-breaks* nil)
        (hs-bind-start! h)
        (setf (hss-rel st) t (hss-pool st) 2f0)
        (bind-step! h :release)
        (check (and (not (hss-bound st)) (= (gauges-reiatsu go) 2f0) (= (gauges-reiatsu gh) 0f0)))
        (bind-step! h :hits)
        (check (null *soul-breaks*))
        ;; KAIBAKU-GEKI's release then its real 120 (a hit or a block alike: the release is at its S, before the step's hits)
        (setf (gauges-konpaku go) 9 (gauges-reishi go) 1300 (gauges-reishi gh) 1300 *soul-breaks* nil *t-ends* nil)
        (hs-bind-start! h) (setf (fighter-form fh) :bankai-bind)
        (deal-damage o h 300) (deal-damage h o 200)
        (start-move h (m :hs-b-sp2)) (setf (fighter-sf fh) 18)
        (hs-kaibaku-go h)
        (check (and (hss-rel st) (hss-rel-strike st)))
        (bind-step! h :release)
        (check (and (not (hss-bound st)) (= 1300 (gauges-reishi gh) (gauges-reishi go)) (null *t-ends*) (hss-rel-reel st)
                    (eq (fighter-move fh) (m :hs-b-sp2))))
        (deal-damage h o 120)
        (check (or (and (= 1180 (gauges-reishi go)) (null (bind-of o))) (format t "  KAIBAKU real: ~a grey ~a~%" (gauges-reishi go) (gauges-grey go))))
        (let ((rf (symbol-function 'hs-bind-reel!)))
          (setf (symbol-function 'hs-bind-reel!) (lambda (b) (push (list :reel b) *t-ends*)))
          (hs-bk-tick h fh gh)
          (hs-bk-tick h fh gh)
          (setf (symbol-function 'hs-bind-reel!) rf))
        (check (and (equal *t-ends* (list (list :reel h))) (not (hss-rel-reel st))))
        (setf (hss-rel st) nil *t-ends* nil)
        (hs-kaibaku-go h)                                                 ; (no bind up: nothing; SP2 refused)
        (check (and (not (hss-rel st)) (not (hs-bk-ok h :sp2 nil))))
        (setf (fighter-state fh) :idle (fighter-move fh) nil (gauges-reishi go) 1300)
        ;; ... and P stays the plain release (no strike: UNWIND, no reel after)
        (hs-bind-start! h) (setf (fighter-form fh) :bankai-bind (fighter-kit fh) kb)
        (check (and (try-command h fh :awaken) (hss-rel st) (not (hss-rel-strike st))))
        (bind-step! h :release)
        (check (and (equal *t-ends* (list h)) (not (hss-rel-reel st))))
        (setf (fighter-form fh) :bankai (fighter-kit fh) kr *t-ends* nil)
        ;; B8's split at a pool left of 0 / 150 / 300 / 450 / 600
        (check (equal (loop for l in '(0.0 150.0 300.0 450.0 600.0)
                            collect (progn (hs-bind-start! h) (setf (hss-pool st) (f32 l) (hss-rel st) t) (bind-step! h :release)
                                           (list (gauges-reiatsu go) (gauges-reiatsu gh))))
                      '((0f0 0f0) (150f0 0f0) (300f0 0f0) (300f0 150f0) (300f0 300f0))))
        ;; B10 time-up during a bind = drained: H led 3-2 on grey values, his grey 0 Reishi turns into a Soul Break
        (hs-bind-start! h)
        (setf (gauges-konpaku gh) 3 (gauges-reishi gh) 0 (gauges-konpaku go) 2 (gauges-reishi go) 1300 *soul-breaks* nil)
        (time-up)
        (check (and (not (hss-bound st)) (= (gauges-konpaku gh) 0) (eql *winner* 1) (null *soul-breaks*)))
        ;; B15 one bind on the field: a bound fighter's (or the binder's) KUBIKAKE refused; a stale hit (a Kikon's step:
        ;; the tick came after its cinematic) binds nothing; two throws in one step (the mirror) bind neither
        (setf (gauges-konpaku gh) 9 (gauges-konpaku go) 9 (gauges-reishi gh) 1300 (gauges-reiatsu gh) 300f0)
        (hs-bind-start! h)
        (check (not (hs-kubi-ready-p 300.0 0 (bind-of h))))
        (hs-bind-off! h :end-released)
        (setf (hss-bind-t st) (1- *match-tick*) (fighter-form fh) :bankai)
        (hs-bk-tick h fh gh)
        (check (not (hss-bound st)))
        (multiple-value-bind (h2 h3) (t-pair kr kr)
          (setf (hss-bind-t (hs h2)) *match-tick* (hss-bind-t (hs h3)) *match-tick*)
          (hs-try-bind! h2) (hs-try-bind! h3)
          (check (and (not (hss-bound (hs h2))) (not (hss-bound (hs h3))))))
        ;; L KOJO (B4c, 「絞縄改成給捆綁的 L」, 「絞縄本身帶拉近」; S1 §23.3, 「前 20 幀預備，拉到後 4 幀就打」): f0-19 the tell, at
        ;; f20 the noose drags him from 8 m to 2.0 m at 60 m/s (1.0 m a step, 6 steps: by f26, 4 f before S 30), the move's
        ;; frames untouched; the drag stops at S; then the reap 3.0 m 160
        ;; deg; no cooldown, no cost, refused nowhere; on hit 0 (crumple 40 against S + A + R - S), on block -24
        (hs-bind-start! h) (setf (fighter-form fh) :bankai-bind)
        (t-at h 0 0) (t-at o 0 -8)
        (start-move h (m :hs-b-l)) (setf (fighter-sf fh) 20 (fighter-state (fighter o)) :idle)
        (check (equal '((20 hs-pull-go)) (mv-on-frame (m :hs-b-l))))
        (hs-pull-go h)
        (let ((n (loop for i from 1 to 60 do (hs-pull-step h fh st) until (not (hss-pull st)) finally (return i))))
          (check (and (= n 6) (~= 2.0 (- (aref (pos-of o) 2))) (= (fighter-sf fh) 20) (= 4 (- (mv-s (m :hs-b-l)) (+ 20 n))))))
        (t-at o 0 -8) (hs-pull-go h) (setf (fighter-sf fh) 30)
        (hs-pull-step h fh st)
        (check (and (not (hss-pull st)) (~= 8.0 (- (aref (pos-of o) 2)))))   ; (at S: no drag)
        (check (and (= 0 (on-hit-adv (m :hs-b-l))) (= -24 (mv-adv-block (m :hs-b-l))) (zerop (kit-command-cost kb :sig))
                    (eq :crumple (hw-react (svref (mv-hits (m :hs-b-l)) 0))) (= 30 *hs-kojo-s*) (= 36 *hs-kojo-r*)
                    (= 70 *hs-kojo-dmg*) (= -24 *hs-kojo-block*)))
        (setf (fighter-dist fh) 1.0f0)
        (check (and (hs-bk-ok h :sig nil) (hs-bk-ok h :q nil)))
        ;; SP2 KAIBAKU-GEKI (「捆綁的 SP2 換成解除並附加傷害」, 「先還原再打，傷害 120」): the move itself off a hit too (the
        ;; generic SP cancel), no bars; at its S the release is due (P's, his move kept: no UNWIND), the snapshot back
        ;; at the release slot, then its strike real (outside the bind: no grey, no drain; no x1.2); the reel after the hits
        (start-move h (m :hs-b-j1)) (setf (fighter-contact fh) :hit)
        (check (eq (kit-command-move kb :sp2 h) (m :hs-b-sp2)))
        (setf (fighter-state fh) :idle (fighter-move fh) nil)
        (check (and (eq (kit-command-move kb :sp2 h) (m :hs-b-sp2)) (equal '((18 hs-kaibaku-go)) (mv-on-frame (m :hs-b-sp2)))
                    (= 18 (hw-from (svref (mv-hits (m :hs-b-sp2)) 0))) (= 120 (mv-dmg (m :hs-b-sp2))) (= 120 *hs-kaibaku-dmg*)
                    (eq :knockback (hw-react (svref (mv-hits (m :hs-b-sp2)) 0))) (zerop (mv-cooldown (m :hs-b-sp2)))))
        ;; the bind's SP1 is KUSARI-AME (B4c, 「鎖雨移到捆綁的 SP1」): the same move, the SP1 cost (1 bar, from the pool);
        ;; off a J / K hit its charge-less copy; the ranged mode's SP1 stays TSUZURI RAIDEN, its SP2 KUBIKAKE
        (check (and (eq (kit-command-move kb :sp1 h) (m :hs-r-sp2)) (= 1 (kit-command-cost kb :sp1))
                    (eq (kit-command-move kr :sp1) (m :hs-r-sp1)) (eq (kit-command-move kr :sp2) (m :hs-r-kubikake))
                    (zerop (kit-command-cost kb :sp2))))
        (start-move h (m :hs-b-k1)) (setf (fighter-contact fh) :hit)
        (check (eq (kit-command-move kb :sp1 h) (m :hs-r-sp2c)))
        (setf (fighter-state fh) :idle (fighter-move fh) nil)
        (hs-bind-off! h :end-released)))
    ;; ---- B4a (DUEL_HISAGI §22.1-§22.2, the user 2026-10-18): the two modes made distinct
    ;; the dead zone: every window of every ranged-mode attack but L and the universal Breaker misses inside 2.0 m
    ;; (:min-reach; K1 綁束 again since B4d, 「讓 K1 只能打中遠方的敵人」); the bind's SP1 KUSARI-AME (and its copy) none since
    ;; B4d (「鎖雨改成近距離也打得中」); no other move of the game has one (every other character's hits as before)
    (let ((dz '(:hs-r-j1 :hs-r-j2 :hs-r-j2s :hs-r-j3 :hs-r-j3g :hs-r-k1 :hs-r-k2 :hs-r-k2s :hs-r-k3 :hs-r-k3g
                :hs-r-sp1 :hs-r-kikon :hs-r-kubikake :hs-r-kubikake-c)))
      (dolist (n dz)
        (check (or (and (plusp (length (mv-hits (m n)))) (every (lambda (w) (~= (if (eq n :hs-r-j1) 3.0 2.0) (hw-min w))) (mv-hits (m n))))   ; (S1: J1 3.0)
                   (format t "  Hisagi B4a: ~a has no dead zone~%" n))))
      (check (loop for mv being the hash-values of *moves*
                   always (or (member (mv-name mv) dz) (eq (mv-name mv) :hs-k1)   ; (S1: the Shikai's K1 NAGI's 2.0 m, §23.3)
                              (every (lambda (w) (null (hw-min w))) (mv-hits mv))))))
    ;; ... and only his Bankai has the :dmg-mult hook, only its ranged mode the CPU's :move-reflex
    (check (loop for c being the hash-keys of *kits* using (hash-value alist)
                 always (loop for (f . k) in alist
                              always (if (and (eq c :hisagi) (member f '(:bankai :bankai-bind)))
                                         (and (eq 'hs-dmg-mult (kit-hook k :dmg-mult))
                                              (eq (getf (kit-ai k) :move-reflex) (and (eq f :bankai) 'hs-r-ai-move)))
                                         (and (null (kit-hook k :dmg-mult))
                                              (eq (getf (kit-ai k) :move-reflex) (and (eq c :hisagi) 'hs-ai-move)))))))   ; (S2: the Shikai's)
    ;; the annulus (J1 / J2 2.0-4.5 m 100 deg ahead, J3 2.0-5.0 m all round): a hurt cylinder r 0.36 at D m (ahead, or
    ;; behind); the window's dead zone first, then its volume (facing -Z)
    (flet ((reach-p (n d &optional behind)
             (let ((w (svref (mv-hits (m n)) 0)))
               (and (>= d (hw-min w))
                    (vol-hit-p (first (hw-vols w)) 0f0 0f0 0f0 0f0 -1f0 0f0 0f0 (f32 (if behind d (- d))) 0.36f0 1.8f0 0f0)))))
      (check (and (not (reach-p :hs-r-j1 2.9)) (reach-p :hs-r-j1 3.0) (reach-p :hs-r-j1 5.35) (not (reach-p :hs-r-j1 5.4))   ; (S1: 3.0-5.0)
                  (not (reach-p :hs-r-j1 4.0 t)) (reach-p :hs-r-j2 3.5) (not (reach-p :hs-r-j2 1.0))
                  (reach-p :hs-r-j3 3.0 t) (reach-p :hs-r-j3 5.3) (not (reach-p :hs-r-j3 5.4)) (not (reach-p :hs-r-j3 1.99 t))
                  (~= (aref (first (hw-vols (svref (mv-hits (m :hs-r-j1)) 0))) 2) (deg 50.0)))))
    (check (and (= 14 (mv-s (m :hs-r-j1))) (= 10 (mv-s (m :hs-r-j2))) (~= (mv-clip-speed (m :hs-r-j1)) (/ 12.0 14.0))
                (~= (mv-clip-speed (m :hs-r-j2)) (/ 11.0 10.0)) (~= (mv-clip-speed (m :hs-r-j3)) (/ 13.0 10.0))))
    ;; the J pushes: J1 / J2 onto the tip (>= 3.5 m, the next J link's annulus reaches him there, inside its tip), J3's
    ;; ender to 5.5 m (past the generic 4.5 + body + 0.05), inside the O lane (9 m) and SP1's 9 m line
    (check (and (eq 'hs-r-j-push (mv-on-land (m :hs-r-j1))) (eq 'hs-r-j-push (mv-on-land (m :hs-r-j2)))
                (null (mv-on-land (m :hs-r-j2s))) (eq 'hs-r-j3-push (mv-on-land (m :hs-r-j3)))   ; (B4c: gathered J2s no push,
                (eq 'hs-r-j3-push (mv-on-land (m :hs-r-j3g))) (eq 'hs-r-uchi-push (mv-on-land (m :hs-r-k2)))   ;  §22.4)
                (null (mv-on-land (m :hs-r-k1))) (null (mv-on-land (m :hs-r-k2s))) (null (mv-on-land (m :hs-r-k3)))
                (null (mv-on-land (m :hs-r-k3g)))
                (~= 3.5 *hs-r-j-push*) (<= (- 4.5 *hs-r-tip*) *hs-r-j-push* 4.5) (~= 5.5 *hs-r-j3-push*)
                (> *hs-r-j3-push* (+ 4.5 0.45 *ender-push*)) (< (+ *hs-r-j3-push* 0.45) 9.0)))
    ;; the tip x1.3 (the outer 1.0 m: an arc by his distance, a line along it) and the bind's x1.2 within 1.2 m
    (check (and (~= 1.3 (hs-dist-mult :bankai nil 4.5 3.5 0.0)) (~= 1.0 (hs-dist-mult :bankai nil 4.5 3.49 0.0))
                (~= 1.3 (hs-dist-mult :bankai nil 4.5 4.8 0.0)) (~= 1.3 (hs-dist-mult :bankai t 9.0 3.0 8.0))
                (~= 1.0 (hs-dist-mult :bankai t 9.0 8.5 7.9)) (~= 1.0 (hs-dist-mult :bankai nil nil 7.0 7.0))
                (~= 1.2 (hs-dist-mult :bankai-bind nil nil 1.2 0.0)) (~= 1.0 (hs-dist-mult :bankai-bind nil nil 1.21 0.0))
                (~= 1.0 (hs-dist-mult :base nil 4.5 4.0 4.0)) (~= 1.3 *hs-r-tip-mult*) (~= 1.2 *hs-b-close-mult*)))
    (multiple-value-bind (h o) (t-pair kr (kit :kenpachi :base))
      (let ((fh (fighter h)))
        (t-at h 0 0) (t-at o 0 -4)                                      ; (he faces -Z: O 4 m ahead)
        (setf (fighter-form fh) :bankai)
        (flet ((x (n d2 &optional (i 0)) (hs-dmg-mult h o (svref (mv-hits (m n)) i) (m n) nil d2)))
          (check (and (~= 1.3 (x :hs-r-j1 16.0)) (~= 1.3 (x :hs-r-j3 16.0)) (~= 1.0 (x :hs-r-j3 15.9))
                      (~= 1.0 (x :hs-r-l 4.0)) (~= 1.0 (x :hs-r-k3 16.0)) (~= 1.0 (x :hs-breaker 1.0))
                      (~= 1.0 (hs-dmg-mult h o (make-hitwin) nil t 16.0))      ; (a mark: a hazard, no move)
                      (~= 1.0 (x :hs-r-sp1 16.0))))                      ; (SP1's 9 m line: 4 m along it, no tip)
          (t-at o 0 -8.5)
          (check (and (~= 1.3 (x :hs-r-sp1 72.25)) (~= 1.3 (x :hs-r-kubikake 49.0)) (~= 1.0 (x :hs-r-sp2 72.25 1))))
          (t-at o 0 -3.0)                                                 ; (B4d: K1's tip, the outer 1.0 m of r 4.0)
          (check (and (~= 1.3 (x :hs-r-k1 9.0)) (~= 1.3 (x :hs-r-k1 16.0))))
          (t-at o 0 -2.9)
          (check (~= 1.0 (x :hs-r-k1 8.41)))
          (t-at o 0 -9.5)
          (check (and (~= 1.3 (x :hs-r-sp2 90.25 1)) (~= 1.3 (x :hs-r-kikon 90.25))))
          (t-at o 0 -1.0)
          (setf (fighter-form fh) :bankai-bind)
          (check (and (~= 1.2 (x :hs-b-j1 1.0)) (~= 1.2 (x :hs-b-l 1.0)) (~= 1.0 (x :hs-b-sp2 1.0)) (~= 1.0 (x :hs-b-j1 1.96)) (~= 1.0 (x :hs-breaker 1.0)))))
        ;; B4c (§22.4, §22.6): B4a's marks are gone (「拿掉落點」): no mark functions, no ranged K placing anything, every
        ;; ranged J / K a hit window of its own
        (check (and (notany #'fboundp '(hs-mark-place hs-mark-spawn hs-mark-hook hs-marks-slam hs-marks-clear hs-mark-spot
                                        hs-mark-lead hs-rakusa-aim hs-rakusa-lock hs-rakusa-seg hs-foe-near-mark-p))
                    (every (lambda (n) (and (null (mv-on-frame (m n))) (plusp (length (mv-hits (m n))))
                                            (notany #'hw-seg (mv-hits (m n)))))
                           (append '(:hs-r-j1 :hs-r-k1) *hs-r-spread-links* *hs-r-gather-links*))))
        ;; the volumes (he at the origin facing -Z, a hurt cylinder r 0.36 at D m ahead / behind / aside): K1 all round
        ;; 2.0-4.36 m (B4d: the dead zone back, r 4.0); the bind's rain from his feet (B4d: no dead zone); spread K2s a 60 deg fan 2.0-6.0, K3 160 deg; gathered K2's two hits (the slam's cap
        ;; 2.0-3.5 m, its tail's line 3.5-8.0 m, r 0.5), J2s a line 2.0-5.0, K3G all round 2.0-6.0, J3G 180 deg 2.0-5.0
        (flet ((in-p (n d &key (i 0) (side 0.0) behind)
                 (let ((w (svref (mv-hits (m n)) i)))
                   (and (>= (sqrt (+ (* d d) (* side side))) (or (hw-min w) 0.0))
                        (vol-hit-p (first (hw-vols w)) 0f0 0f0 0f0 0f0 -1f0 (f32 side) 0f0 (f32 (if behind d (- d))) 0.36f0 1.8f0 0f0)))))
          (check (and (not (in-p :hs-r-k1 0.5)) (not (in-p :hs-r-k1 1.9 :behind t)) (in-p :hs-r-k1 2.0) (in-p :hs-r-k1 3.0 :behind t)
                      (in-p :hs-r-k1 4.3) (not (in-p :hs-r-k1 4.4)) (in-p :hs-r-k1 0.0 :side 3.5)
                      (~= 2.0 (hw-min (svref (mv-hits (m :hs-r-k1)) 0)))
                      (in-p :hs-r-sp2 0.3) (in-p :hs-r-sp2 0.8 :i 1) (in-p :hs-r-sp2c 1.0) (in-p :hs-r-sp2 10.3 :i 1)
                      (notany #'hw-min (mv-hits (m :hs-r-sp2))) (notany #'hw-min (mv-hits (m :hs-r-sp2c)))
                      (eq :stagger (hw-react (svref (mv-hits (m :hs-r-k1)) 0)))
                      (in-p :hs-r-k2s 2.0) (in-p :hs-r-k2s 6.3) (not (in-p :hs-r-k2s 6.4)) (not (in-p :hs-r-k2s 1.9))
                      (not (in-p :hs-r-k2s 4.0 :side 3.0)) (in-p :hs-r-k3 4.0 :side 3.0) (not (in-p :hs-r-k3 4.0 :behind t))
                      (in-p :hs-r-k2 2.0) (in-p :hs-r-k2 3.5) (not (in-p :hs-r-k2 4.4)) (not (in-p :hs-r-k2 1.9))
                      (not (in-p :hs-r-k2 2.5 :i 1)) (in-p :hs-r-k2 3.0 :i 1) (in-p :hs-r-k2 8.8 :i 1) (not (in-p :hs-r-k2 8.9 :i 1))
                      (not (in-p :hs-r-k2 5.0 :i 1 :side 1.0))
                      (equal '(27 33) (map 'list #'hw-from (mv-hits (m :hs-r-k2)))) (equal '(31 37) (map 'list #'hw-to (mv-hits (m :hs-r-k2))))
                      (equal '(:stagger :launch) (map 'list #'hw-react (mv-hits (m :hs-r-k2))))
                      (= 37 (+ (mv-s (m :hs-r-k2)) (mv-a (m :hs-r-k2))))
                      (in-p :hs-r-j2s 2.0) (in-p :hs-r-j2s 5.8) (not (in-p :hs-r-j2s 5.9)) (not (in-p :hs-r-j2s 4.0 :side 1.0))
                      (in-p :hs-r-k3g 4.0 :behind t) (in-p :hs-r-k3g 6.3) (not (in-p :hs-r-k3g 6.4)) (not (in-p :hs-r-k3g 1.9 :behind t))
                      (in-p :hs-r-j3g 0.5 :side 4.0) (not (in-p :hs-r-j3g 3.0 :behind t)) (in-p :hs-r-j3g 5.3) (not (in-p :hs-r-j3g 5.4)))))
        ;; ... K2's slam pushes him onto the tail's line (>= 3.5 m, 4 f) only when its first window hit (a hit by the second
        ;; first: nothing), so the second window's line (from 2.64 m: 3.5 - 0.5 - 0.36) reaches him; it opens after the push
        (setf (fighter-form fh) :bankai *t-moved* nil)
        (t-at o 0 -2.2)
        (start-move h (m :hs-r-k2))
        (let ((pa (symbol-function 'push-apart)))   ; (stand-ins: no model, no arena: the push as a slide of the victim)
          (setf (symbol-function 'push-apart) (lambda (a b dist frames) (declare (ignore a)) (set-slide b dist frames 0 0)))
          (setf (fighter-sf fh) 27) (hs-r-uchi-push h)
          (check (and (= 1 (length *t-moved*)) (eq o (first (first *t-moved*))) (~= (second (first *t-moved*)) 1.3)
                      (= *hs-r-uchi-frames* (third (first *t-moved*))) (<= (+ 27 *hs-r-uchi-frames*) 33) (< (+ 30 *hs-r-uchi-frames*) 37)
                      (< 2.2 (- 3.5 0.5 0.36)) (>= *hs-r-j-push* (- 3.5 0.5 0.36))))
          (setf *t-moved* nil (fighter-sf fh) 33) (hs-r-uchi-push h)
          (check (null *t-moved*))
          (setf (symbol-function 'push-apart) pa))
        ;; ... its launch carries the gathered K3G / J3G: the victim still airborne at their hit (the launch's air time) and
        ;; low enough for their 0.2-2.0 m arcs (his feet below 2.0 m)
        (let* ((air (ceiling (* 60 (/ (* 2 (getf *air-vy* :launch)) *gravity*)))) (w2 (svref (mv-hits (m :hs-r-k2)) 1)))
          (dolist (n '(:hs-r-k3g :hs-r-j3g))
            (let* ((tl (/ (- (+ (mv-s (m :hs-r-k2)) (mv-a (m :hs-r-k2)) (- (mv-s (m n)) (mv-enter (m n)))) (hw-from w2)) 60.0))
                   (y (- (* (getf *air-vy* :launch) tl) (* 0.5 *gravity* tl tl))))
              (check (or (and (< (* 60 tl) air) (< 0.2 y 1.6)) (format t "  Hisagi B4c: ~a after K2's launch at ~,2f m~%" n y))))))
        ;; ... the block gaps (the generic walk pins >= the Step's iframes for his J links): spread J2 / J3 8 f, the gathered
        ;; J2s 15 f, J3G 14 (after J2s) / 15 (after K2): every J1 of the roster (7-10) beats a blocked gathered J link
        (check (equal (list (blocked-gap (m :hs-r-j1) (m :hs-r-j2)) (blocked-gap (m :hs-r-j2) (m :hs-r-j3))
                            (blocked-gap (m :hs-r-k1) (m :hs-r-j2s)) (blocked-gap (m :hs-r-j2s) (m :hs-r-j3g))
                            (blocked-gap (m :hs-r-k2) (m :hs-r-j3g)))
                      '(8 8 15 14 15)))
        ;; ... his CPU's reach read (HS-R-AI-MOVE's picks): past the dead zone, inside the far edge + 0.36
        (check (and (hs-r-reaches-p (m :hs-r-k2) 7.5) (not (hs-r-reaches-p (m :hs-r-k2) 1.9)) (hs-r-reaches-p (m :hs-r-j2s) 5.3)
                    (not (hs-r-reaches-p (m :hs-r-j2s) 5.9)) (not (hs-r-reaches-p (m :hs-r-k1) 1.9)) (hs-r-reaches-p (m :hs-r-k1) 4.3)
                    (not (hs-r-reaches-p (m :hs-r-j3) 1.5))
                    (eq 'hs-r-ai-move (getf (kit-ai kr) :move-reflex))))
        ;; ... his CPU's openers (B4d, §22.8): K1 only in bands inside its annulus 2.0-4.0 m; inside 2.0 m L SAHARAI (no
        ;; cooldown now: his :reflex rolls once per entry into the band, never per step)
        (let ((bands (getf (kit-ai kr) :moves)))
          (check (and (every (lambda (bd) (or (null (getf (cddr bd) :f)) (and (>= (first bd) 2.0) (<= (second bd) 4.0)))) bands)
                      (some (lambda (bd) (and (getf (cddr bd) :f) (= 4.0 (second bd)))) bands)
                      (let ((b0 (find 0.0 bands :key #'first))) (and (null (getf (cddr b0) :f)) (plusp (getf (cddr b0) :sig))))
                      (~= 2.0 *hs-ai-close*) (eq 'hs-r-ai-reflex (getf (kit-ai kr) :reflex)))))
        (setf *t-moved* nil)))
    ;; the drawn reach (the Bankai's clips, DUEL_HISAGI §21.8): each of its clips in *HS-STRIKE-REACH* (the FK test above
    ;; reads that reach) is drawn to it by its let-out crescents (*HS-LETOUT*), chain strikes (*HS-BK-CHAINS*) or lashes
    ;; (*HS-LASHES*, batch A2 §24.2: the ranged route links, their free ends on the keys, each rank's stagger, keys eased
    ;; 4 f apart or more, as %HS-LASH-TIP!): their farthest end out on each hit window's frames; every one of them reaches
    ;; its hit volume's far edge within 0.15 m (the arc's r, the line's end + its r, along his facing; a chain dropped on a
    ;; line within its r), and nothing lands past it; the table holds the first window's
    (flet ((lash-end (clip f cap)                                      ; the farthest lash end at clip frame F (NIL: none)
             (let ((best nil))
               (dolist (x *hs-lashes* best)
                 (destructuring-bind (c mask ds w f0 f1 &rest keys) x
                   (declare (ignore w f0 f1))
                   (when (eq c clip)
                     (dotimes (k (logcount mask))
                       (let ((ff (- f (* k ds))))
                         (when (<= (first (first keys)) ff (first (car (last keys))))
                           (let* ((i (position-if (lambda (y) (> (first y) ff)) keys))
                                  (a (nth (if i (max 0 (1- i)) (1- (length keys))) keys)) (b (if i (nth i keys) a))
                                  (x (if (eq a b) 0 (/ (- ff (first a)) (- (first b) (first a)))))
                                  (u (if (>= (- (first b) (first a)) 4) (* x x (- 3 (* 2 x))) x))
                                  (r (+ (second a) (* u (- (second b) (second a)))))
                                  (a0 (+ (fourth a) (* k (fifth a)))) (a1 (+ (fourth b) (* k (fifth b))))
                                  (az (+ a0 (* u (- (mod (+ (- a1 a0) 180) 360) 180))))
                                  (d (if cap (* r (cos (* az (/ pi 180)))) r)))
                             (setf best (max (or best d) d))))))))))))
      (let ((bk-moves '(:hs-r-j1 :hs-r-j2 :hs-r-j3 :hs-r-l :hs-r-sp1 :hs-r-sp2 :hs-r-kubikake
                        :hs-r-k1 :hs-r-k2s :hs-r-k3 :hs-r-k2 :hs-r-j2s :hs-r-k3g :hs-r-j3g      ; (A2: the route links)
                        :hs-b-j2 :hs-b-k1 :hs-b-k2 :hs-b-k3 :hs-b-sp1 :hs-b-l)))
        (dolist (n bk-moves)
          (let* ((mv (m n)) (clip (mv-clip mv)) (sr (third (assoc clip *hs-strike-reach*))))
            (check (null (getf *hs-r-clip-stand-ins* clip)))                ; (its own clip, no stand-in)
            (loop for hw across (mv-hits mv) for wi from 0
                  do (let* ((vol (first (hw-vols hw)))
                            (cap (> (aref vol 0) 0.5)) (edge (if cap (+ (aref vol 2) (aref vol 4)) (aref vol 1)))
                            (sp (mv-clip-speed mv)) (c0 (* sp (hw-from hw))) (c1 (* sp (1- (hw-to hw))))   ; (the hit frames in
                            (ends (append (loop for (c nil nil f1 f2 nil r) in *hs-letout*                  ;  the clip's own: B4c's
                                                when (and (eq c clip) (<= f1 c0) (>= f2 c1)) collect r)      ;  J2 / J3 at S 10)
                                          (loop for (c nil nil f1 nil f3 nil r) in *hs-bk-chains*
                                                when (and (eq c clip) (<= f1 c1) (> f3 c0)) collect r)
                                          (remove nil (loop for f from (hw-from hw) below (hw-to hw)
                                                            collect (lash-end clip (* sp f) cap)))))
                            (art (and ends (reduce #'max ends))))
                       (check (or (and art (<= (abs (- art edge)) 0.15) (or (null sr) (> wi 0) (~= sr art)))
                                  (format t "~a ~a (window ~d): the volume ends ~,2f m, the drawn end ~a, the table ~a~%"
                                          n clip wi edge art sr)))))))))))

(format t "duel-rules-test: ~d checks, ~a~%" *checks*
        (if (zerop *fails*) "ALL PASS" (format nil "~d FAILED" *fails*)))
(ext:quit (if (zerop *fails*) 0 1))
