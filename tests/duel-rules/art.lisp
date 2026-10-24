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
;; the J cut). The host has no C: anim.lisp's float intrinsics as plain CL
(defmacro engine::f-max (a b) `(max ,a ,b))
(defmacro engine::f-mod (a b) `(mod ,a ,b))
(defmacro engine::f-sin (a) `(sin ,a))
(defmacro engine::f-cos (a) `(cos ,a))
(defmacro engine::f-wrap (a) `(let ((x ,a)) (- x (* 6.2831853f0 (floor (+ x 3.14159265f0) 6.2831853f0)))))
(load (merge-pathnames "../../engine/lisp/anim.lisp" *load-truename*))
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
  (dolist (art '("yama-art" "ken-art" "rukia-art" "ichigo-art" "senjumaru-art" "lille-art" "lille-clips" "lille-draw" "lille-cine"
                 "barro-art" "barro-draw" "hisagi-art" "hisagi-draw" "hisagi-cine" "hisagi-stills"))   ; (the files that hold clips, strikes, bodies and the tables read below)
    (with-open-file (in (merge-pathnames (format nil "../../duel/lisp/~a.lisp" art) *load-truename*))
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
                     (body-variant (push (cons (second form) (cdr (assoc (third form) bodies))) bodies))   ; (its base's rig)
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
                       (format t "~a ~a: the volume ends ~,2f m, the art ~,2f m~%" (second cf) (mv-name mv) edge art)))))))
    ;; Rukia's Shikai bursts (DUEL_RUKIA_TYBW §4.4) on their own clips (the motion pass, §13.3, 2026-10-24; at speed 1): the
    ;; blade's tip, her farthest drawn point (霜散's flung sleeve rides the arm inside it), against the volume's far edge,
    ;; reported (a "Rukia burst reach" line each), checked only never to pass it by > 0.15 m. Every one falls short: the
    ;; rest is carried by 霜散's frost off the sleeve, 雪煙's snow-smoke, 霜陣's snow ring, 氷礫's pebbles, 氷柱's icicles
    ;; and 白漣's 11 m wave (the kido are lines, a cone and rings off the hand: out)
    (let* ((k (kit :rukia :base)) (b (cdr (assoc :rukia bodies))) (props (and (getf b :props) (apply #'make-rig-proportions (getf b :props))))
           (wlen (cdr (assoc (kit-weapon k) weapons))))
      (dolist (n '(:ru-shimochiri :ru-setsuen :ru-sojin :ru-hyoreki :ru-tsurara :ru-hakuren-k))
        (let* ((mv (kit-move k n)) (hw (svref (mv-hits mv) 0)) (vol (first (hw-vols hw))) (cap (> (aref vol 0) 0.5))
               (edge (if cap (+ (aref vol 2) (aref vol 4)) (aref vol 1)))
               (art (loop for sf from (hw-from hw) below (hw-to hw)
                          maximize (progn
                                     (clip-sample! pose (find-clip (mv-clip mv)) (/ (* sf (mv-clip-speed mv)) 60.0))
                                     (pose-fk! jm pose 0f0 0f0 0f0 0f0 (f32 (getf b :scale)) (f32 (deg (getf b :hunch 0))) props)
                                     (joint-point! v jm (ji :weapon-r) 0f0 0f0 (f32 (- wlen)))
                                     (if cap (- (aref v 2)) (sqrt (+ (expt (aref v 0) 2) (expt (aref v 2) 2))))))))
          (format t "  Rukia burst reach ~a (~a): the volume ends ~,2f m, the art ~,2f m (~@d cm)~%" n (mv-clip mv) edge art
                  (round (* 100 (- art edge))))
          (check (<= (- art edge) 0.15)))))))

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
               (unless (equal cf '(:hisagi :bankai))   ; (his ranged J 3-6 m, K 1-4 m: the user, 2026-10-18, 「J 的範圍改 3~6」
                                                       ;  「K 的範圍改 1~4」, DUEL_HISAGI §25.3; K1 vs J1 since §22.4)
                 (check (or (>= (- kk j) 0.5) (format t "~a link ~d: J ~,2f K ~,2f~%" cf n j kk))))))))

