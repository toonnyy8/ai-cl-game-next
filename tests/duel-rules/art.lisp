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
(let ((bodies nil) (weapons nil) (strike nil) (points nil) (butt 0.0) (grips nil) (frost nil) (seen nil) (plants nil))
  (dolist (art '("ken-art" "ichigo-art" "hisagi-art" "hisagi-draw" "hisagi-cine" "hisagi-stills" "yama-art" "yama-look"))   ; (the files that hold clips, strikes, bodies and the tables read below)
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
                                     (*ya-plants* (setf plants (eval (third form))))         ; (Yamamoto's planted blade, art K3)
                                     ))
                     (defconstant (when (eql 0 (search "+YA-" (symbol-name (second form)))) (eval form)))   ; (art S1's look constants)
                     (defun (when (eq (second form) 'ya-heat-tier) (eval form)))                              ; (art S1's heat tier)
                     (defbody (push (cons (second form) (third form)) bodies))
                     (body-variant (push (cons (second form) (cdr (assoc (third form) bodies))) bodies))   ; (its base's rig)
                     (defweapon (push (cons (second form) (getf (third form) :length)) weapons)))))))
  (let ((jm (make-f32 (* 16 +nj+))) (pose (make-f32 +pose-n+)) (v (make-f32 3)) (g (make-f32 3))
        (min-hurt (loop for (n . b) in bodies unless (eq n :skeleton) minimize (getf b :hurt-r)))   ; (:skeleton: 南's dead, a look
        (max-hurt (loop for (nil . b) in bodies maximize (getf b :hurt-r))))                          ;  body, no fighter)
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
                       (format t "~a ~a: the volume ends ~,2f m, the art ~,2f m~%" (second cf) (mv-name mv) edge art)))))))
    ;; Yamamoto (DUEL_YAMA_CORE §15.2.3, §16, art batch K1): every segment with a blade window, the same FK as above (radial for an arc,
    ;; ahead for a capsule). The Bankai is checked: the J links and the swinging segments both ways within 0.15 m; where a look carries the
    ;; rest (ONE-SIDED: KYOKKO's lance L7, KYOKUJITSUJIN's void line L6, 西's burn round him L8, 北's AS crescent L10) the blade may fall
    ;; short, never over. KNOWN-OFF (the clips K1 found off, §16) is empty since art K3 (§18: AS2a's own clip); a move put back in it must be
    ;; off. HAND: the grab's striker is the free hand (the blade stands planted, YAMA-PLANTED), and the throw's too. The no-hit-window
    ;; segments (南, 北's NS, 西's flares) get a cast check each (§15.2.3, art K3): the tip or the body where the move says on S; and every
    ;; planted window of *YA-PLANTS* opens and closes with the clip's grip on the planted spot (within 0.1 m, the grip 0.76 m up).
    (flet ((ya-pose (k clip sf speed)
             (let* ((b (cdr (assoc (kit-body k) bodies))) (props (and (getf b :props) (apply #'make-rig-proportions (getf b :props)))))
               (clip-sample! pose (find-clip clip) (/ (* sf speed) 60.0))
               (pose-fk! jm pose 0f0 0f0 0f0 0f0 (f32 (getf b :scale)) (f32 (deg (getf b :hunch 0))) props)))
           (ya-wtip (k) (joint-point! v jm (ji :weapon-r) 0f0 0f0 (f32 (- (cdr (assoc (kit-weapon k) weapons))))) v))
      (flet ((ya-tip (k mv &optional what)
               (let* ((hw (svref (mv-hits mv) 0)) (vol (first (hw-vols hw))) (cap (> (aref vol 0) 0.5)) (clip (kit-move-clip k (mv-clip mv))))
                 (values (loop for sf from (hw-from hw) below (hw-to hw)
                               maximize (progn
                                          (ya-pose k clip sf (mv-clip-speed mv))
                                          (case what
                                            (:hand (joint-point! v jm (ji :hand-r) 0f0 0f0 0f0))
                                            (:pommel (joint-point! v jm (ji :weapon-r) 0f0 0f0 0.285f0))   ; (MB-BLADE's kashira end)
                                            (t (ya-wtip k)))
                                          (if cap (- (aref v 2)) (sqrt (+ (expt (aref v 0) 2) (expt (aref v 2) 2))))))
                         (if cap (+ (aref vol 2) (aref vol 4)) (aref vol 1))))))
        (let ((k (find-kit :yamamoto :bankai))
              (one-sided '(:ya-e-n1a :ya-e-n1c :ya-e-n2a :ya-e-n2b :ya-e-as2b :ya-e-as4))
              (hand '(:ya-e-as2 :ya-e-as2b))
              (known-off '()))   ; (K2: AS1 left with ya-e-as1, §17; K3: AS2 with ya-e-grab, §18)
          (format t "yamamoto bankai FK (move, drawn tip, volume end, delta):~%")
          (dolist (n '(:ya-e-j1 :ya-e-j2 :ya-e-j3 :ya-e-n1a :ya-e-n1b :ya-e-n1c :ya-e-as1 :ya-e-n2a :ya-e-n2b :ya-e-n2c :ya-e-as2 :ya-e-as2b
                       :ya-e-as4 :ya-e-sa :ya-e-ns-strike))
            (multiple-value-bind (art edge) (ya-tip k (kit-move k n) (and (member n hand) :hand))
              (let* ((d (- art edge)) (ok (and (<= d 0.15) (or (>= d -0.15) (member n one-sided)))))
                (format t "  ~a ~(~a~)~:[~; (hand)~] | ~,2f | ~,2f | ~,2@f~:[~; (known off)~]~%" (if ok "ok " "OFF") n (member n hand) art edge d
                        (member n known-off))
                (if (member n known-off)
                    (check (not ok))                      ; (a fixed clip must leave the list)
                    (check (or ok (format t "yamamoto bankai ~a: the volume ends ~,2f m, the art ~,2f m~%" n edge art)))))))
          ;; the cast checks: (move frame what test): TIP the blade's tip, HAND / HAND-L the hands (x right, y up, ahead = -z), on frame S
          (format t "yamamoto bankai cast checks (move, frame, what, x y ahead):~%")
          (dolist (c `((:ya-e-n3a 22 :tip "the point in the plaza, ahead" ,(lambda (x y a) (declare (ignore x)) (and (<= -0.2 y 0.05) (<= 0.4 a 1.2))))
                       (:ya-e-n3b 16 :tip "still in the plaza" ,(lambda (x y a) (declare (ignore x)) (and (<= -0.2 y 0.05) (<= 0.4 a 1.2))))
                       (:ya-e-n3c 18 :tip "overhead" ,(lambda (x y a) (declare (ignore x a)) (>= y 2.2)))
                       (:ya-e-as3 10 :tip "the point in the plaza by the front foot" ,(lambda (x y a) (declare (ignore x)) (and (<= -0.2 y 0.05) (<= 0.4 a 1.2))))
                       (:ya-e-as3b 10 :hand "the hand low, swept forward" ,(lambda (x y a) (declare (ignore x)) (and (<= y 0.9) (>= a 0.5))))
                       (:ya-e-as3c 12 :tip "drawn out low" ,(lambda (x y a) (declare (ignore x a)) (<= y 0.6)))
                       (:ya-e-n4 24 :tip "past the wave's start (1 m ahead)" ,(lambda (x y a) (declare (ignore x y)) (>= a 1.0)))
                       (:ya-e-n2a 16 :hand "the arms open (right)" ,(lambda (x y a) (declare (ignore y a)) (>= x 0.6)))
                       (:ya-e-n2a 16 :hand-l "the arms open (left)" ,(lambda (x y a) (declare (ignore y a)) (<= x -0.6)))
                       (:ya-e-n2a 26 :hand "the second pulse: open" ,(lambda (x y a) (declare (ignore y a)) (>= x 0.6)))
                       (:ya-e-n2b 14 :hand "the arms open low" ,(lambda (x y a) (declare (ignore a)) (and (>= x 0.5) (<= y 1.2))))
                       (:ya-e-as2b 12 :hand "the hand opened upward" ,(lambda (x y a) (declare (ignore x a)) (>= y 1.7)))))
            (destructuring-bind (n sf what desc test) c
              (let ((mv (kit-move k n)))
                (ya-pose k (kit-move-clip k (mv-clip mv)) sf (mv-clip-speed mv))
                (case what
                  (:tip (ya-wtip k))
                  (:hand (joint-point! v jm (ji :hand-r) 0f0 0f0 0f0))
                  (:hand-l (joint-point! v jm (ji :hand-l) 0f0 0f0 0f0)))
                (let ((ok (funcall test (aref v 0) (aref v 1) (- (aref v 2)))))
                  (format t "  ~a ~(~a~) f~d ~(~a~) ~a | ~,2f ~,2f ~,2f~%" (if ok "ok " "OFF") n sf what desc (aref v 0) (aref v 1) (- (aref v 2)))
                  (check ok)))))
          ;; the planted windows: the clip's grip on the spot when the blade is left there and when the hand comes back (art S4: 爆炎's
          ;; IKKOTSU too, posed on its own kit's body)
          (dolist (p plants)
            (destructuring-bind (n from to (ahead right) &optional carried) p
              (let* ((k (if (gethash n (kit-moves k)) k (find-kit :yamamoto :blaze))) (mv (kit-move k n)))
                (dolist (sf (if carried (list to) (list from to)))   ; (:carried: the hand was off it already at FROM)
                  (ya-pose k (kit-move-clip k (mv-clip mv)) sf (mv-clip-speed mv))
                  (joint-point! v jm (ji :weapon-r) 0f0 0f0 0f0)
                  (let ((d (sqrt (+ (expt (- (aref v 0) right) 2) (expt (- (aref v 1) 0.76) 2) (expt (+ (aref v 2) ahead) 2)))))
                    (format t "  ~a ~(~a~) f~d the grip on the planted spot: ~,2f m off~%" (if (<= d 0.1) "ok " "OFF") n sf d)
                    (check (<= d 0.1))))))))
        ;; The Shikai and 爆炎 (art batch S1, DUEL_YAMA_CORE §21.6, §22): checked as the Bankai, ±0.15 m both ways; ONE-SIDED where a look
        ;; carries the rest (NADEGIRI's seam SL7, TAIMATSU's halo SL8); TSUKABI (J3) strikes with the POMMEL (the handle's end), IKKOTSU with
        ;; the FIST. KNOWN-OFF: the borrowed clips S1's print found off (§22.1); S2 / S3 / S4 took them out (§23, §24, §25: IKKOTSU), and a
        ;; move put back in it must be off. F10: IKKOTSU's clip on its move (both S9 since art S4), the fist per frame.
        (let ((one-sided '(:ya-n3c :ya-as3c :ya-sa :ya-b-n3c :ya-b-as3c :ya-b-sa
                           :ya-n2a :ya-b-n2a))   ; (§30.1: the melee flame slash on the stream's clip, its tip 1.89 of 2.4 m: the flame
                                                 ;  carries the rest until it has its own clip)
              (pommel '(:ya-j3)) (fist '(:ya-b-j3))
              (known-off '()))   ; (S2: J3's pommel and AS1; S3: AS2a, AS3a, NS3a / NS3b, the Kikon strikes and 爆炎's copies; S4: IKKOTSU)
          (dolist (f '(:base :blaze))
            (let ((k (find-kit :yamamoto f)))
              (format t "yamamoto ~(~a~) FK (move, drawn tip, volume end, delta):~%" f)
              (dolist (mv (sort (loop for m being the hash-values of (kit-moves k)
                                      when (and (plusp (length (mv-hits m))) (find-clip (kit-move-clip k (mv-clip m)) nil)) collect m)
                                #'string< :key (lambda (m) (symbol-name (mv-name m)))))
                (let ((n (mv-name mv)))
                  (multiple-value-bind (art edge) (ya-tip k mv (cond ((member n pommel) :pommel) ((member n fist) :hand)))
                    (let* ((d (- art edge)) (ok (and (<= d 0.15) (or (>= d -0.15) (member n one-sided)))))
                      (format t "  ~a ~(~a~)~@[ (~(~a~))~] | ~,2f | ~,2f | ~,2@f~:[~; (known off)~]~%" (if ok "ok " "OFF") n
                              (cond ((member n pommel) :pommel) ((member n fist) :fist)) art edge d (member n known-off))
                      (if (member n known-off)
                          (check (not ok))
                          (check (or ok (format t "yamamoto ~(~a~) ~a: the volume ends ~,2f m, the art ~,2f m~%" f n edge art))))))))))
          ;; art S2 (§23): pointer 1's segments have no blade window: a cast check on their frames (x right, y up, ahead); pointer 3's stance
          ;; stands the point on the plaza at his right front at every phase of its loop; each S2 clip plays at x1 with its move's S, S+A and end.
          ;; Art S3 (§24): pointer 2's segments too (NS2a's point out on S, NS2c's / AS2b's blade overhead through the hold and level on S), every
          ;; S3 clip on its move's frames (爆炎's NS2b its own clip since J3, below), and no Shikai move clip turns his root by more
          ;; than 45 deg at any key (the blade is carried round him, never the body: the old SA / NADEGIRI / NS2c clips turned 360 / 185 / 360)
          (let ((k (find-kit :yamamoto :base))
                (plaza (lambda (x y a) (declare (ignore x)) (and (<= -0.2 y 0.05) (<= 0.4 a 1.6)))))
            (format t "yamamoto base cast checks (move, frame, x y ahead):~%")
            (dolist (c `((:ya-n1a 22 "the tip past the spiral's start (1 m), at 1.1 m" ,(lambda (x y a) (declare (ignore x)) (and (>= a 1.0) (<= 0.9 y 1.3))))
                         (:ya-n1b 9 "the point on the plaza ahead" ,plaza) (:ya-n1b 12 "still on the plaza" ,plaza)
                         (:ya-n1b 16 "the blade overhead" ,(lambda (x y a) (declare (ignore x a)) (>= y 2.2)))
                         (:ya-n1c 18 "flung past 1 m ahead" ,(lambda (x y a) (declare (ignore x y)) (>= a 1.0)))
                         (:ya-n2a 20 "the point locked out past 1 m ahead" ,(lambda (x y a) (declare (ignore x y)) (>= a 1.0)))
                         ,@(loop for n in '(:ya-n2c :ya-as2b)
                                 append (append (loop for sf from 9 to 14 collect (list n sf "the blade overhead" (lambda (x y a) (declare (ignore x a)) (>= y 2.2))))
                                                (list (list n 18 "chopped to the level point, past 1 m" (lambda (x y a) (declare (ignore x)) (and (>= a 1.0) (<= 0.9 y 1.5)))))))))
              (destructuring-bind (n sf desc test) c
                (let ((mv (kit-move k n)))
                  (ya-pose k (kit-move-clip k (mv-clip mv)) sf (mv-clip-speed mv))
                  (ya-wtip k)
                  (let ((ok (funcall test (aref v 0) (aref v 1) (- (aref v 2)))))
                    (format t "  ~a ~(~a~) f~d ~a | ~,2f ~,2f ~,2f~%" (if ok "ok " "OFF") n sf desc (aref v 0) (aref v 1) (- (aref v 2)))
                    (check ok)))))
            (let ((tips (loop for ph from 0 below 144 by 12 collect (progn (ya-pose k :ya-st-cane ph 1.0) (ya-wtip k) (list (aref v 0) (aref v 1) (- (aref v 2)))))))
              (format t "  stance 3 (ya-st-cane), the tip over its loop: x ~,2f-~,2f y ~,2f-~,2f ahead ~,2f-~,2f~%"
                      (reduce #'min tips :key #'first) (reduce #'max tips :key #'first) (reduce #'min tips :key #'second) (reduce #'max tips :key #'second)
                      (reduce #'min tips :key #'third) (reduce #'max tips :key #'third))
              (check (every (lambda (p) (and (<= 0.45 (first p) 0.55) (<= -0.05 (second p) 0.05) (<= 0.2 (third p) 0.4))) tips))
              (let ((n3 (loop for sf from 0 to 4 collect (progn (ya-pose k (kit-move-clip k (mv-clip (kit-move k :ya-n3a))) sf 1.0) (ya-wtip k)
                                                                (list (aref v 0) (aref v 1) (aref v 2))))))   ; (J3, §28.5: printed)
                (format t "  stance 3 > NS3a, the tip's jump f1-4 (m): ~{~,2f~^ ~}~%"
                        (loop for (p q) on n3 while q collect (sqrt (reduce #'+ (mapcar (lambda (a b) (expt (- a b) 2)) p q)))))))
            (dolist (n '(:ya-j1 :ya-n1a :ya-n1b :ya-n1c :ya-as1 :ya-n2a :ya-n2b :ya-n2c :ya-as2 :ya-as2b :ya-n3a :ya-n3b :ya-n3c :ya-as3 :ya-as3b :ya-as3c
                         :ya-sa :ya-ns-strike :ya-as-strike))
              (let* ((mv (kit-move k n)) (c (find-clip (kit-move-clip k (mv-clip mv)))))
                (check (or (and (= 1.0 (mv-clip-speed mv)) (= (mv-s mv) (round (* 60 (clip-mark c :s)))) (= (+ (mv-s mv) (mv-a mv)) (round (* 60 (clip-mark c :a))))
                                (= (+ (mv-s mv) (mv-a mv) (mv-r mv)) (round (* 60 (clip-dur c)))))
                           (format t "yamamoto ~a: its clip's frames are not its move's~%" n)))))
            ;; art S4 (§25): 爆炎's own clips on their moves' frames (IKKOTSU, the entry pose, ENNETSU, the true NADEGIRI), and ENNETSU's
            ;; point driven into the plaza on S
            (let ((kb (find-kit :yamamoto :blaze)))
              (dolist (n '(:ya-b-j3 :ya-blaze-in :ya-b-n2b :ya-b-n2c :ya-b-n3c))   ; (NS2b's own clip since J3, §28.5)
                (let* ((mv (kit-move kb n)) (c (find-clip (kit-move-clip kb (mv-clip mv)))))
                  (check (or (and (= 1.0 (mv-clip-speed mv)) (= (mv-s mv) (round (* 60 (clip-mark c :s))))
                                  (= (+ (mv-s mv) (mv-a mv) (mv-r mv)) (round (* 60 (clip-dur c))))
                                  (or (zerop (mv-r mv)) (= (+ (mv-s mv) (mv-a mv)) (round (* 60 (clip-mark c :a))))))
                             (format t "yamamoto blaze ~a: its clip's frames are not its move's~%" n)))))
              (let ((mv (kit-move kb :ya-b-n2c)))
                (ya-pose kb (kit-move-clip kb (mv-clip mv)) 18 (mv-clip-speed mv))
                (ya-wtip kb)
                (format t "  ~a ya-b-n2c f18 the point in the plaza ahead | ~,2f ~,2f ~,2f~%" (if (funcall plaza (aref v 0) (aref v 1) (- (aref v 2))) "ok " "OFF")
                        (aref v 0) (aref v 1) (- (aref v 2)))
                (check (funcall plaza (aref v 0) (aref v 1) (- (aref v 2)))))
              (let ((mv (kit-move kb :ya-b-n2b)))         ; (J3: 爆炎 NS2b's own clip, the blade overhead f11-13, level past 1 m on S)
                (dolist (c `((11 "the blade overhead" ,(lambda (x y a) (declare (ignore x a)) (>= y 2.2)))
                             (13 "the blade overhead" ,(lambda (x y a) (declare (ignore x a)) (>= y 2.2)))
                             (16 "chopped to the level point, past 1 m" ,(lambda (x y a) (declare (ignore x)) (and (>= a 1.0) (<= 0.9 y 1.5))))))
                  (destructuring-bind (sf desc test) c
                    (ya-pose kb (kit-move-clip kb (mv-clip mv)) sf (mv-clip-speed mv))
                    (ya-wtip kb)
                    (let ((ok (funcall test (aref v 0) (aref v 1) (- (aref v 2)))))
                      (format t "  ~a ya-b-n2b f~d ~a | ~,2f ~,2f ~,2f~%" (if ok "ok " "OFF") sf desc (aref v 0) (aref v 1) (- (aref v 2)))
                      (check ok))))
                (flet ((tip (n sf) (let ((m (kit-move kb n))) (ya-pose kb (kit-move-clip kb (mv-clip m)) sf (mv-clip-speed m)) (ya-wtip kb)
                                     (list (aref v 0) (aref v 1) (aref v 2))))
                       (gap (p q) (sqrt (reduce #'+ (mapcar (lambda (a b) (expt (- a b) 2)) p q)))))
                  (let* ((m2a (kit-move kb :ya-b-n2a)) (j1 (gap (tip :ya-b-n2a (+ (mv-s m2a) (mv-a m2a))) (tip :ya-b-n2b 0)))
                         (j2 (gap (tip :ya-b-n2b (+ (mv-s mv) (mv-a mv))) (tip :ya-b-n2c 0))))
                    (format t "  ya-b-n2b link jumps (m, printed): NS2a S+A > NS2b f0 ~,2f, NS2b S+A > ENNETSU f0 ~,2f; NS2b f1-4 ~{~,2f~^ ~}~%"
                            j1 j2 (loop for f from 1 to 4 collect (gap (tip :ya-b-n2b (1- f)) (tip :ya-b-n2b f))))
                    (check (< j2 0.02))))))   ; (S+A is ENNETSU's frame 0)
            (dolist (f '(:base :blaze))
              (loop for m being the hash-values of (kit-moves (find-kit :yamamoto f))
                    do (let ((c (and (mv-clip m) (find-clip (kit-move-clip (find-kit :yamamoto f) (mv-clip m)) nil))))
                         (when c
                           (let ((yaw (loop for i below (engine::clip-n c) maximize (abs (aref (engine::clip-poses c) (+ (* i +pose-n+) +root+ 3))))))
                             (check (or (<= yaw (deg 45))   ; (爆炎's entry pose too, since art S4: its own clip, no turn)
                                        (format t "yamamoto ~(~a~) ~a: its clip turns the root ~,0f deg~%" f (mv-name m) (/ yaw (deg 1)))))))))))
          (let* ((k (find-kit :yamamoto :blaze)) (mv (kit-move k :ya-b-j3)))   ; F10 (printed): the clip's S against the move's
            (format t "yamamoto blaze IKKOTSU (clip ~a S~d, move S~d), the fist ahead per frame:" (mv-clip mv)
                    (round (* 60 (clip-mark (kit-move-clip k (mv-clip mv)) :s))) (mv-s mv))
            (loop for sf from 6 to 12
                  do (ya-pose k (kit-move-clip k (mv-clip mv)) sf (mv-clip-speed mv))
                     (joint-point! v jm (ji :hand-r) 0f0 0f0 0f0)
                     (format t " f~d ~,2f" sf (sqrt (+ (expt (aref v 0) 2) (expt (aref v 2) 2)))))
            (terpri)))))))

;; Yamamoto's heat is read, never written, by a look (DUEL_YAMA_CORE §21.1, §21.6 row 2, art batch S1 §22): no form in his look files
;; writes a GAUGES- slot, a YSS- slot or a hazard's data (SETF / INCF / DECF / PUSH / REMF on that place, a GETF of HAZARD-DATA too).
(let ((bad nil))
  (labels ((bad-place-p (p)
             (and (consp p) (symbolp (first p))
                  (let ((nm (symbol-name (first p))))
                    (or (eql 0 (search "GAUGES-" nm)) (eql 0 (search "YSS-" nm)) (string= nm "HAZARD-DATA")
                        (and (string= nm "GETF") (bad-place-p (second p)))))))
           (walk (x file)
             (when (consp x)
               (when (symbolp (first x))
                 (let ((op (symbol-name (first x))) (args (and (listp (cdr x)) (cdr x))))
                   (when (and (member op '("SETF" "INCF" "DECF" "REMF") :test #'string=) args)
                     (loop for (p) on (if (string= op "SETF") args (list (first args))) by (if (string= op "SETF") #'cddr #'cdr)
                           when (bad-place-p p) do (push (list file p) bad)))
                   (when (and (string= op "PUSH") (consp (cdr args)) (bad-place-p (second args))) (push (list file (second args)) bad))))
               (loop for y on x while (consp y) do (walk (car y) file)))))
    (dolist (file '("yama-look" "yama-vfx" "yama-cine" "yama-art"))
      (with-open-file (in (merge-pathnames (format nil "../../duel/lisp/~a.lisp" file) *load-truename*))
        (let ((*package* (find-package :duel)))
          (loop for form = (read in nil in) until (eq form in) do (walk form file))))))
  (format t "yamamoto looks: writes of heat / hazard data: ~:[none~;~:*~s~]~%" bad)
  (check (null bad)))
;; art S1 (§22): the Shikai's looks take a few sim numbers as constants (0 B: no float read off a struct or a list per draw): each equals the
;; sim's, so a retune shows here; the heat tiers (§21.8 Q1); the move looks' literal reaches (YAMA-SK-MOVES: NADEGIRI 2.4, TAIMATSU 2.4 / 3.2,
;; AS1's burst to 1.6) are the moves'.
(flet ((par (form name key) (getf (mv-params (kit-move (find-kit :yamamoto form) name)) key))
       (reach (form name) (mv-reach (kit-move (find-kit :yamamoto form) name))))
  (check (= +ya-wave-half+ (second *wave-box*)))
  (check (= +ya-spiral-speed+ (par :base :ya-n1a :speed) (par :blaze :ya-b-n1a :speed)))
  ;; (NS2a's lance and ENNETSU's rows are no move's since §30.1: the melee slash, the disc round him; their looks' speeds left unchecked)
  (check (= +ya-tornado-speed+ (par :base :ya-n1c :speed) (par :blaze :ya-b-n1c :speed)))
  (check (= +ya-dome-near+ (par :blaze :ya-b-n2b :near)))         ; (爆炎 NS2b's ring at its dome's spot: YA-BEARING-POINT's rule)
  (check (= +ya-dome-far+ (par :blaze :ya-b-n2b :far)))
  (check (= +ya-arena-in+ (- *arena-radius* 0.5)))
  (check (= +ya-ring-band+ *ya-ring-band*))
  (check (= +ya-col-delay+ (par :base :ya-n1b :delay) (par :blaze :ya-b-n1b :delay)))
  (check (= +ya-fire-h+ *ya-fire-h*))
  (check (= 25 *ya-heat-ns*))                          ; (YA-HEAT-TIER's full spend; YA-STANCE-TIER's cap, art S3)
  (check (equal '(0 1 2 2 2) (list (ya-heat-tier 0f0 nil) (ya-heat-tier 12f0 nil) (ya-heat-tier 25f0 nil) (ya-heat-tier 0f0 t) (ya-heat-tier 12f0 t))))
  (check (= 2.4 (reach :base :ya-n3c) (reach :base :ya-as3c) (reach :base :ya-sa)))
  (check (= 3.2 (reach :blaze :ya-b-sa)))
  (check (= 1.6 (reach :base :ya-as1))))
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

