;;;; barro-stills.lisp — Lille's art stills (debug 82100-82399, docs/duel/DUEL_GAMEPLAY.md "Debug commands") and the consing
;;;; probe BR-CONS-PROBE (split out of barro-art.lisp 2026-10-21, refactor round 2). Debug scaffolding only: the sim never
;;;; reads it. Loads after barro-draw.lisp (*BR-ART-HOLD* and the look clocks are defined there).
(in-package :duel)

;;; ---------------------------------------------------------------- the art stills (debug 82100-82399, DUEL_GAMEPLAY)
(defun br-art-scene (k)
  "82100+k: Lille II (P1; k + 20: P2, facing the behind camera: the front view) 4 m from an idle Kenpachi, Reiatsu and flash
step full: k 0-4 the owl (kept without a burst) with 0 / 2 / 4 / 6 / 8 wings, the volley started (its string by the
count: 空收 / 二連 / 四連 / 裁き / 裁き・極); 8 / 9 JILLIEL's turn into the stance / its stance's K K -> L L line (KL1); 10 / 11
the owl's; 12 the owl's SP2 on its own (the volley's wind-up); 13 the base stance's SP2 HIRENKYAKU; 14 JILLIEL's SANREN;
15 / 16 / 17 the base stance's L1 / J1 / K1 (3 m out); 18 / 19 JILLIEL's stance L1 / K1 (3 m out); 40-51 the base stance's
L1-2 L1-3 (R15, DUEL_LILLE_V3 §19: the snipe's level 2 / 3 shots) J2 J3 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3 (3 m out, started on
their own, 3 pips; + 20 the front view); 52-56 (R15) the base stance's L, the snipe, in its charge held 22 / 33 / 48 / 64 /
84 frames (level 1, level 2's flash, level 2, level 3's flash, level 3: x1.5 with its levels, 2026-10-26; 15 / 22 / 32 / 43
/ 56 before), the sim frozen there at once (82299 lets go: the release, its shot); 57 (R16, DUEL_LILLE_V3 §20) the base
form's attack-state J3 銃口突 (:br-j3, its clip :br-jab) 2.2 m out; 58 / 59 (2026-10-26) a whiffed snipe's recovery
(:br-sk-lw) at its frame 6 / 12;
5 / 6 / 7 the base form's attack-state K1 / K2 / K3 (:br-k1 / :br-k2 / :br-k3, each started on its own, K2 / K3 from their
link frame :enter) 2.3 m out. The awakened stances' moves: BR-ART-STANCE."
  (let* ((front (oddp (floor k 20))) (k (if front (- k 20) k)) (owl (or (<= 0 k 4) (<= 10 k 13))))
    (if front (ensure-battle :kenpachi :barro) (ensure-battle :barro :kenpachi))
    (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
      (setf *br-keep-owl* owl)
      (force-form b (cond ((or (<= 5 k 7) (<= 15 k 17) (<= 40 k 59)) :base) ((<= 18 k 19) :jilliel) (owl :shin-kin) (t :jilliel-kin)))
      (place *p1* *p2* (cond ((= k 57) 2.2) ((<= 5 k 7) 2.3) ((or (<= 15 k 19) (<= 40 k 56) (<= 58 k 59)) 3.0) (t 4.0)))
      (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
            (gauges-reishi (gauges o)) (gauges-reishi-max (gauges o)))   ; (no K.O. across a script's scenes)
      (case k
        ((0 1 2 3 4) (br-set-ammo b (nth k '(0 2 4 6 8))) (start-move b (find-move :br-recall)))
        ((8 10) (start-move b (find-move :br-to-en)))
        (9 (start-move b (find-move :br-e-kl1)))
        (11 (start-move b (find-move :br-oe-kl1)))
        (12 (start-move b (find-move :br-recall-s)))
        (13 (force-form b :base) (start-move b (find-move :br-k-hiren)))
        (14 (start-move b (find-move :br-w-sanren)))
        (15 (start-move b (find-move :br-s-l1) :sig))   ; (R15: a held move, its button L: released at once, level 1)
        (16 (start-move b (find-move :br-s-j1))) (17 (start-move b (find-move :br-s-k1)))
        (18 (start-move b (find-move :br-e-l1) :sig)) (19 (start-move b (find-move :br-e-k1)))   ; (18: the awakened L dash, held as 15)
        ((40 41 42 43 44 45 46 47 48 49 50 51)
         (br-set-ammo b 3)
         (setf (fighter-charge (fighter b)) (case k (40 40) (41 70) (t 0)))   ; (2026-10-26: its levels 30 / 60)   ; (R15: the snipe's level 2 / 3 as if held)
         (start-move b (find-move (nth (- k 40) '(:br-s-l1-2 :br-s-l1-3 :br-s-j2 :br-s-j3 :br-s-k2 :br-s-k3 :br-s-jl1 :br-s-jl2
                                                  :br-s-jl3 :br-s-kl1 :br-s-kl2 :br-s-kl3)))))
        ((52 53 54 55 56)                              ; (R15: the snipe's charge held, frozen at once)
         (let ((h (nth (- k 52) '(22 33 48 64 84))) (an (model-anim (model b))))
           (start-move b (find-move :br-s-l1) :sig)
           (setf (fighter-hold (fighter b)) h (anim-time an) (/ h 60f0))
           (hitstop 100000)))
        ((58 59)                                       ; (2026-10-26: a whiffed snipe's recovery, frozen in its clip)
         (let ((an (model-anim (model b))))
           (start-move b (find-move :br-s-l1) :sig)
           (play-clip b :br-sk-lw :blend 0)
           (setf (anim-time an) (/ (if (= k 58) 6 12) 60f0))
           (hitstop 100000)))
        (57 (start-move b (find-move :br-j3)))   ; (R16, §20: the base form's attack-state J3 銃口突, its own clip :br-jab)
        ((5 6 7) (start-move b (find-move (nth (- k 5) '(:br-k1 :br-k2 :br-k3))))))   ; (the base form's attack-state K string,
                                                       ;  each on its own: K2 / K3 from their link frame, :enter)
      (setf *br-art-hold* *br-art-hold-next* *br-art-hold-next* -1))))

(defvar *br-art-front* nil "Debug 82389 (R11): the next BR-ART-STANCE scene puts him as P2 (the front view), the owl's too.")
(defun br-art-wall (k)
  "82394+k (the wing wall): Lille II 2 m from an idle Kenpachi, 8 wings, holding his guard (his brain's press: P1's brain
made when he has none): k 0 JILLIEL KIN, 1 the owl KIN (kept without a burst), 2 JILLIEL EN, 3 the owl EN; P1 (the behind
camera: his back), or P2 (the front view) after 82389. 82399: the opponent's J1 started now (the block: the wall's knock)."
  (let ((front *br-art-front*) (owl (oddp k)) (en (>= k 2)))
    (setf *br-art-front* nil)
    (ensure-battle (if front :kenpachi :barro) (if front :barro :kenpachi) :cpu t)
    (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
      (dolist (e (list *p1* *p2*))                      ; (no CPU plays: his brain only holds the guard)
        (when (brain e) (setf (brain-off (brain e)) t (brain-press-left (brain e)) 0)))
      (setf *br-keep-owl* owl)
      (force-form b (if en (if owl :shin :jilliel) (if owl :shin-kin :jilliel-kin)))
      (place *p1* *p2* 2.0)
      (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
            (gauges-reishi (gauges o)) (gauges-reishi-max (gauges o)))
      (br-set-ammo b 8)
      (if (brain b)
          (let ((br (brain b))) (setf (brain-press br) :guard (brain-press-mod br) nil (brain-press-left br) 100000 (brain-act br) :hold))
          (log-msg "duel barro: wall scene: no brain for P~d (hold U)" (if front 2 1))))))
(defun br-art-wall-hit ()
  "82399: the opponent of the Lille II on the field starts his J1 now (the wing wall takes it: the block's knock)."
  (let* ((b (if (and *p1* (eq (kit-character (fighter-kit (fighter *p1*))) :barro)) *p1* *p2*)) (o (if (eq b *p1*) *p2* *p1*))
         (mv (kit-command-move (fighter-kit (fighter o)) :q)))
    (when mv (start-move o mv))))

(defun br-art-stance (m)
  "82320+m: Lille II (P1) 3 m from an idle Kenpachi, 8 wings, Reiatsu and flash step full, his awakened stance's move
started on its own: m 0-14 JILLIEL EN's (L1 L2 L3 J1 J2 J3 K1 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3, *BR-S-SEGS*' order: the
openers' clips :br-en-*, the follow-ups' :br-e-jf* / -kf*), 20-34 the owl EN's (kept without a burst: :br-oen-*, :br-oe-jf* /
-kf*); 40-54 JILLIEL's again as P2, facing the behind camera (the front view). Since R10 (one charged L, no L2 / L3) m 1
(21, 41) sets the same scene with no move started, for a script to hold L (the charge) itself; m 15-17 (35-37, 55-57)
JL1-JL3 6 m out (the whips' reach). R11 (DUEL_LILLE_V3 §16): 82389 first puts the next scene in the front view, any m (the
owl's too)."
  (let* ((front (or (>= m 40) *br-art-front*)) (m (if (>= m 40) (- m 40) m)) (owl (>= m 20))
         (far (<= 15 (if owl (- m 20) m) 17)) (m (if far (- m 6) m))   ; (R10: the whips at 6 m)
         (sn (nth (if owl (- m 20) m) '("L1" "L2" "L3" "J1" "J2" "J3" "K1" "K2" "K3" "JL1" "JL2" "JL3" "KL1" "KL2" "KL3")))
         (idle (= (if owl (- m 20) m) 1))              ; (R10: L held by the script)
         (mv (and sn (gethash (intern (format nil "~a-~a" (if owl "BR-OE" "BR-E") sn) :keyword) *moves*))))
    (setf *br-art-front* nil)
    (if (and (null mv) (not idle))
        (log-msg "duel barro: no stance still ~d" m)
        (progn
          (if front (ensure-battle :kenpachi :barro) (ensure-battle :barro :kenpachi))
          (let* ((b (if front *p2* *p1*)) (o (if front *p1* *p2*)) (g (gauges b)))
            (setf *br-keep-owl* owl)
            (force-form b (if owl :shin :jilliel))
            (place *p1* *p2* (if far 6.0 3.0))
            (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
                  (gauges-reishi (gauges o)) (gauges-reishi-max (gauges o)))
            (br-set-ammo b 8)
            (when mv (start-move b mv (and (mv-hold mv) :sig)))   ; (a held L, the dash: its button L, released at once)
            (setf *br-art-hold* *br-art-hold-next* *br-art-hold-next* -1))))))

(defun br-art-legs (k)
  "82390+k (R11, DUEL_LILLE_V3 §16): the stance switch's legs, Lille II (P1) 3 m from an idle Kenpachi, 8 wings: k 0 / 1
JILLIEL KIN / the owl KIN with the turn into the stance (:br-to-en) started (the legs put away); 2 / 3 JILLIEL EN / the owl
EN with the stance's J1 started (its string ends, back to KIN: the legs let out)."
  (let ((owl (oddp k)) (out (>= k 2)))
    (ensure-battle :barro :kenpachi)
    (let* ((b *p1*) (g (gauges b)))
      (setf *br-keep-owl* owl)
      (force-form b (if out (if owl :shin :jilliel) (if owl :shin-kin :jilliel-kin)))
      (place *p1* *p2* 3.0)
      (setf (gauges-reiatsu g) *reiatsu-max* (gauges-fs g) (f32 *fs-max*)
            (gauges-reishi (gauges *p2*)) (gauges-reishi-max (gauges *p2*)))
      (br-set-ammo b 8)
      (start-move b (find-move (if out (if owl :br-oe-j1 :br-e-j1) :br-to-en)))
      (setf *br-art-hold* *br-art-hold-next* *br-art-hold-next* -1))))

(defun br-art-cine (f)
  "82300+k: his awakening (Lille's lb-jilliel-cine, his caption) with P1 Lille II 6 m from Kenpachi, held at frame 10 k."
  (unless (and *cine* (eq (cine-name *cine*) 'lb-jilliel-cine))
    (abort-cine) (setf *cine-hold* nil)
    (ensure-battle :barro :kenpachi) (place *p1* *p2* 6.0) (force-form *p1* :jilliel-kin)
    (start-cine 'lb-jilliel-cine *p1* *p2*))
  (when *cine* (setf *cine-hold* t (cine-hold *cine*) f)))

(defun br-art-ammo (k)
  "82380+k: the special resource of the Lille II on the field (P1, else P2) set to K, as a sim spend would (the looks
read the drop: one wing the burst at its tip, two or more the armour's shatter, a pip the muzzle glint)."
  (let ((b (if (and *p1* (eq (kit-character (fighter-kit (fighter *p1*))) :barro)) *p1* *p2*)))
    (when b (br-set-ammo b k))))

(defun barro-art-debug (c)
  "His art stills (barro.lisp registers 82100-82399 ahead of BARRO-DEBUG): 82100+k BR-ART-SCENE k (+ 20 the front view);
82200+f the sim freezes once his look clock reaches f (the volley chain's: the recall's frame, 7 + its string's; else the
move's frame; issue it before the scene), 82299 lets go; 82300+k his awakening held at frame 10 k (BR-ART-CINE);
82320+m his awakened stance's move m on its own (BR-ART-STANCE); 82380+k his special set to k, 0-8 (BR-ART-AMMO: the spend
looks); 82389 the next stance (or wing wall) scene in the front view; 82390+k the stance switch's legs (BR-ART-LEGS, R11);
82394+k his awakened guard, the wing wall (BR-ART-WALL), 82399 the opponent's J1 against it; 82398 the consing probe."
  (let ((n (- c 82100)))
    (cond ((< n 100) (br-art-scene n))
          ((< n 199) (setf *br-art-hold-next* (- n 100)))
          ((= n 199) (setf *br-art-hold* -1 *br-art-hold-next* -1 *hitstop* 0))
          ((< n 219) (br-art-cine (* 10 (- n 200))))
          ((<= 220 n 277) (br-art-stance (- n 220)))   ; (R11: to m 57, the front view's JL1-JL3 6 m out)
          ((= n 289) (setf *br-art-front* t))
          ((<= 280 n 288) (br-art-ammo (- n 280)))
          ((<= 290 n 293) (br-art-legs (- n 290)))
          ((<= 294 n 297) (br-art-wall (- n 294)))     ; (the wing wall: his awakened guard)
          ((= n 299) (br-art-wall-hit))
          ((= n 298) (br-cons-probe))
          (t (log-msg "duel barro: no debug command ~d" c)))))

(defun br-cons-probe ()
  "82398: bytes consed by 10 draws of P1 Lille II's :draw hook (BR-DRAW, LILLE-DRAW's lookups included), of the spends'
note and looks (%BR-SPEND-NOTE / -LOOK: the pip glint's model lookup aside), of his volley look
at its clock 4 and of a string beat's lines (when a string runs), and of 裁き・極's look (while it runs), of 零距離砲擊's
blast (in an awakened K3), of the whips' stretch and the owl's lashes (R5), of the body's squash (BR-DEFORM, R8) and the
K route's balls (in an awakened KL, R8), the whips' reach and the L charge's tells (R10), the whip's lash and the stance
switch's legs (R11), the base stance's snipe charge, its shot and the gun-kata / swings' looks (R15; a \"barro consing\"
line)."
  (let* ((e *p1*) (f (fighter e)) (side (fighter-side f)) (m (model e)) (jm (model-joints m))
         (mv (current-move f)))
    (macrolet ((per (form) `(let ((c0 (cons-bytes))) (dotimes (i 10) ,form) (- (cons-bytes) c0))))
      (setf (aref *br-armed* side) 0f0)                 ; (R15: the gun-kata's crack is a sound, not a draw)
      (log-msg "barro consing (10 draws, B): form ~a clock ~d draw ~d (Lille's ~d) spends ~d recall ~d beat (lines drive beat) ~a kiwami ~d stretch ~d lashes ~d deform ~d kl-balls ~d dash ~d cuts ~d whip ~d charge ~d legs ~d snipe-charge ~d snipe ~d kata ~d"
               (fighter-form f) (br-hold-clock f)
               (per (br-draw e 0.016f0)) (per (lille-draw e 0.016f0))
               (per (progn (%br-spend-note f side (br-ammo-look e) 2) (%br-spend-look e side))) (per (%br-recall-look e jm side 4))
               (if (and mv (member (mv-name mv) '(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)))
                   (list (per (%br-beat-look e f jm side mv)) (per (br-rc-drive f mv)) (per (br-rc-beat (mv-name mv) (fighter-sf f))))
                   -1)
               (if (and mv (eq (mv-name mv) :br-rc4)) (per (%br-kiwami-look f jm side)) -1)
               (per (%lb-stretch! (model-anim m))) (per (%lb-lashes jm side)) (per (br-deform e m))
               (if (and mv (assoc (mv-name mv) *br-kl-balls*)) (per (%br-kl-balls f side mv)) -1)
               (if (and mv (member (mv-name mv) *br-dash-moves*)) (per (%br-dash-look f side mv)) -1)
               (let ((h0 nil)) (do-entities (h (hz hazard)) (when (eq (hazard-kind hz) :br-cut) (setf h0 hz)))   ; (R11)
                 (if h0 (per (br-cut-look h0 0.016f0)) -1))
               (per (progn (%br-whip-reach f side mv) (%br-whip-lash side)))
               (if (and mv (member (mv-name mv) *br-dash-moves*)) (per (%br-charge-look f side mv)) -1)
               (per (%br-legs-pose f side m))
               (if (and mv (member (mv-name mv) *br-snipe-moves*) (eq (fighter-phase f) :hold)) (per (br-charge e 0.016f0)) -1)
               (if (and mv (member (mv-name mv) *br-snipe-moves*)) (per (%br-snipe-look e f side mv)) -1)
               (if (and mv (member (mv-name mv) *br-kata-moves*)) (per (%br-kata-look e f side mv)) -1)))))

