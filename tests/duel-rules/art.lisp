(in-package :duel)
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
;; the J cut). Rukia's Shikai K's strike with their 霜の穂先 (*RU-FROST-POINTS*: the ice's tip, that many metres past the
;; blade's along its axis, DUEL_RUKIA_TYBW §13.2; -18's K1 / K3 past the palm along the forearm, K3's level, -50's
;; K1-K3 level from the palm, -273's K1 lance off the point, K2 sheet off the sleeve, K3 flower level from the palm, §13.4)
;; and, with her Breaker HAINAWA's two fingers, both ways within 0.15 m
;; (*TWO-SIDED*). The host has no C: anim.lisp's float intrinsics as plain CL
(defmacro engine::f-max (a b) `(max ,a ,b))
(defmacro engine::f-mod (a b) `(mod ,a ,b))
(defmacro engine::f-sin (a) `(sin ,a))
(defmacro engine::f-cos (a) `(cos ,a))
(defmacro engine::f-wrap (a) `(let ((x ,a)) (- x (* 6.2831853f0 (floor (+ x 3.14159265f0) 6.2831853f0)))))
(load (merge-pathnames "../../engine/lisp/anim.lisp" *load-truename*))
(defparameter *strikers* '((:ke-kick . :foot-r) (:ic-q1 :weapon-l -0.90) (:ic-na1 :weapon-l -0.90)
                           (:ic-q2 :weapon-l -0.90) (:ic-cross-j :weapon-l -0.90) (:ke-shoulder . :shoulder-l))
  "Clip -> what strikes when it isn't the held weapon's tip: a joint (clip . joint), or a point down a joint's -Y
(clip joint y): Ichigo's Shikai J, the short blade held forward in the left fist, its tip at :weapon-l y -0.90
(DUEL_ICHIGO_TYBW §3.1). (The retired kits' rows -- Yamamoto's TSUKABI pommel, Rukia's palms and HAINAWA fingers, Senjumaru's
SAIDAN -- left with their code on 2026-11-12, branch `retired-kits`.)")
(defparameter *two-sided* nil
  "Clips whose striking point must reach the edge both ways although their move may fall short (a K, a Breaker): none live.")
(defparameter *reach-one-sided* '((:kenpachi :base) (:kenpachi :nozarashi) (:kenpachi :bankai) (:kenpachi :bankai-2)))
(let ((bodies nil) (weapons nil) (strike nil) (points nil) (butt 0.0) (grips nil) (frost nil) (seen nil))
  (dolist (art '("ken-art" "ichigo-art" "hisagi-art" "hisagi-draw" "hisagi-cine" "hisagi-stills"))   ; (the files that hold clips, strikes, bodies and the tables read below)
    (with-open-file (in (merge-pathnames (format nil "../../duel/lisp/~a.lisp" art) *load-truename*))
      (let ((*package* (find-package :duel)))
        (loop for form = (read in nil in) until (eq form in)
              when (consp form)
                do (case (first form)
                     ((defpose defclip defstrike defclip-mirror) (eval form))
                     (defparameter (case (second form)
                                     (*hs-strike-reach*   ; (Hisagi's thrown sickle: its drawn reach)
                                      (setf strike (append strike (eval (third form)))))
                                     (*hs-grip* (setf grips (eval (third form))))            ; (Hisagi's J short grip)
                                     ))
                     (defbody (push (cons (second form) (third form)) bodies))
                     (body-variant (push (cons (second form) (cdr (assoc (third form) bodies))) bodies))   ; (its base's rig)
                     (defweapon (push (cons (second form) (getf (third form) :length)) weapons)))))))
  (let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (v (make-f32 3)) (g (make-f32 3))
        (min-hurt (loop for (nil . b) in bodies minimize (getf b :hurt-r))) (max-hurt (loop for (nil . b) in bodies maximize (getf b :hurt-r))))
    ;; J is close (the J cut): the chase and a lunge stop at *LUNGE-STOP*, outside any two hurt cylinders' push-apart, and
    ;; every J follow-up's chase goal is inside its reach + the thinnest hurt radius (it connects)
    (check (> *lunge-stop* (* 2 max-hurt)))
    (dolist (cf (remove-if (lambda (cf) (trace-form-p cf)) *forms*))   ; (Lille II's stance EN:
      (let* ((k (apply #'kit cf)) (b (cdr (assoc (kit-body k) bodies)))                         ;  hitscan lines, v3)
             (b (or b (cdr (assoc (first cf) bodies))))                  ; (a body variant: the rig of its character)
             (props (and (getf b :props) (apply #'make-rig-proportions (getf b :props))))
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
                 (fr (assoc clip frost)) (ice (or (second fr) 0.0))   ; (Rukia's 霜の穂先: m past the tip along the blade;
                                                                       ;  -18's :palm / :flat off the wrist, the forearm's heading)
                 (art (or (third (assoc clip strike))
                          (loop for sf from (hw-from hw) below (hw-to hw)
                                maximize (progn
                                           (clip-sample! pose (find-clip clip) (/ (* sf (mv-clip-speed mv)) 60.0))
                                           (pose-fk! jm pose 0f0 0f0 0f0 0f0 (f32 (getf b :scale)) (f32 (deg (getf b :hunch 0))) props)
                                           (if striker                            ; (yaw 0 faces -Z)
                                               (joint-point! v jm (joint-index striker) 0f0 (f32 sy) 0f0)
                                               (joint-point! v jm (ji :weapon-r) 0f0 0f0 (f32 (if (eq point :weapon) butt (- grip wlen)))))
                                           (when (plusp ice)                      ; (the ice: on along the blade's axis)
                                             (joint-point! g jm (joint-index (if (fourth fr) :lower-arm-l :weapon-r)) 0f0 0f0 0f0)
                                             (when (eq (fourth fr) :flat) (setf (aref g 1) (aref v 1)))   ; (level)
                                             (let ((l (sqrt (+ (expt (- (aref v 0) (aref g 0)) 2) (expt (- (aref v 1) (aref g 1)) 2)
                                                               (expt (- (aref v 2) (aref g 2)) 2)))))
                                               (dotimes (i 3) (incf (aref v i) (* ice (/ (- (aref v i) (aref g i)) l))))))
                                           (if cap (- (aref v 2)) (sqrt (+ (expt (aref v 0) 2) (expt (aref v 2) 2))))))))
                 (d (- art edge)))
            (when (eq (mv-kind mv) :quick)
              (check (<= (max *lunge-stop* (- (mv-reach mv) *chase-margin*)) (- (+ (mv-reach mv) min-hurt) 0.02))))
            (check (or (if (equal cf '(:kenpachi :kataude))
                           (<= d 0.6)
                           (and (<= d 0.15)
                                (or (>= d -0.15)
                                    (and (not (assoc clip strike))   ; (her K props: both ways)
                                         (not (assoc clip frost)) (not (member clip *two-sided*))   ; (Rukia's frost points, HAINAWA)
                                         (or (member cf *reach-one-sided* :test #'equal) (member (mv-kind mv) '(:flash :breaker)))))))
                       (format t "~a ~a: the volume ends ~,2f m, the art ~,2f m~%" (second cf) (mv-name mv) edge art)))))))))

;; J is short, K long (the user, 2026-09-29, docs/duel/DUEL_STRINGS.md §13): in every form every K link reaches at least 0.5 m further
;; than any J link at the same position of the string (its reach + its lunge, :slide); 片腕's short K against the J floor (2026-10-06) excepted
(dolist (cf (remove-if (lambda (cf) (or (member cf '((:kenpachi :base) (:kenpachi :nozarashi)) :test #'equal) (trace-form-p cf))) *forms*))   ; (the V3 Shikai: J only)
  (let ((lm (link-moves (apply #'kit cf))))   ; (Lille II's stance EN: hitscan lines, DUEL_LILLE_V3 R2)
    (loop for n from 1 to 3
          do (let ((j (loop for (m k) in lm when (and (= k n) (eq (mv-kind m) :quick)) maximize (+ (mv-reach m) (mv-slide m))))
                   (kk (loop for (m k) in lm when (and (= k n) (eq (mv-kind m) :flash)) minimize (+ (mv-reach m) (mv-slide m)))))
               (unless (member cf '((:hisagi :bankai) (:hisagi :bankai-bind) (:kenpachi :bankai) (:kenpachi :bankai-2)) :test #'equal)   ; (+ Kenpachi V3's Bankai: no K, §26)
                  ; (his Bankai has no K since §28.4; before, his ranged J 3-6 m, K 1-4 m: the user, 2026-10-18, 「J 的範圍改 3~6」
                                                       ;  「K 的範圍改 1~4」, DUEL_HISAGI §25.3; K1 vs J1 since §22.4)
                 (check (or (>= (- kk j) 0.5) (format t "~a link ~d: J ~,2f K ~,2f~%" cf n j kk))))))))

