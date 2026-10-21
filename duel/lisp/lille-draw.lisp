;;;; lille-draw.lisp — Lille's draw code (cosmetic; 0 B a frame): the f32 scratch vectors, the wing / halo / leg code, LILLE-DRAW,
;;;; LB-LOOK (his hazards' look) (split out of lille-art.lisp 2026-10-21, refactor round 2). Loads after lille-clips.lisp and
;;;; before lille-cine.lisp; barro-draw.lisp and barro-stills.lisp call its helpers. The wall tables *LB-WALL-JL* / *LB-WALL-OWL*
;;;; the host FK test reads sit here.
(in-package :duel)

;;; ================================================================ drawing (cosmetic; 0 B a frame: f32vecs, macros, DEFUN-FAST)
;;; A DEFUN-FAST call boxes its float arguments (engine/lisp/package.lisp), so these helpers take their numbers in the
;;; scratch vectors below, the frames are filled by macros, and a draw's alpha is one of the boxed *LB-ALPHAS*.
(defparameter *lb-sabaki-from* 1.0 "LB-LOOK's :sabaki line (the misuji) starts this many metres ahead (design 2026-10-06) ...")
(defparameter *lb-sabaki-speed* 40.0 "... erupting outward at this many m/s (design 2026-10-06) ...")
(defparameter *lb-sabaki-life* 24 "... each point burning this many frames (0.4 s; design 2026-10-06) ...")
(defparameter *lb-sabaki-width* 0.6 "... this many metres wide (design 2026-10-06).")
(declaim (type f32vec *lb-m* *lb-p* *lb-v* *lb-fx* *lb-hud*))
(defvar *lb-m* (m4) "A prop's world matrix.")
(defvar *lb-leg-tint* nil "The ㄇ legs' tint this draw: the body's (MODEL-TINT: the mirror match's P2), set by LILLE-DRAW.")
(defvar *lb-p* (make-f32 3))
(defvar *lb-v* (make-f32 32)
  "The draw helpers' arguments: [0..2] the wings' root (the joint's frame); [11] the fold 0..1, [12] the ripple (degrees),
[13] the fx clock, [14] the wings' alpha (1), [15] the pairs shown (a cinematic's unfolding), [16] the wings' length x; [17..22]
the line / reticle / halo / trumpet macros' numbers; [23] unused (the old revival's first pair drawn); [24..27] his x y z and yaw
(%LB-LOAD-PLACE!); [28] the wings' spread 0..1; [8] the owl EN's leg tuck 0..1 and [29] the owl KIN's wing sweep 0..1
(decision 38); [31] his drawn scale (a cinematic's giant, CINE-SCALE: decision 56).")
(defvar *lb-fx* (make-f32 (* 2 24))
  "Per side (24 each), the looks' memory: [0] the eye's tick seen, [1] its fx clock, [2] unused, [3] the old MUJITTAI's
last pass-through (never written now: 0, the wings' ripple over the fx clock's first 0.5 s), [4] its fold (0 now), [5] sealed seen (1), [6] the seal's fx clock, [7..9] the reticle's point,
[10] the reticle shown (1 tracking, 2 locked), [11] the distance there, [12 13] the reflector's x z, [14] the eye's tick
whose third-opening line was shown, [15] 1 while he is the owl (his hazards' gold), [16] the wings' spread 0..1 (an SP
fans them out), [17] its joints' unfurl 0..1 (slower: they furl, then open from the root), [18] the owl's EN spread 0..1
(decision 36: EN fans the wings out, KIN sweeps them back; decision 38: also EN's legs folded up, 5 / s); [19] Lille II's
loaded wings + 1 (BR-DRAW sets it before LILLE-DRAW, which clears it after the wings; 0: none lit).")
(dotimes (s 2) (setf (aref *lb-fx* (* 24 s)) -1f0 (aref *lb-fx* (+ (* 24 s) 14)) -1f0))
(defvar *lb-hud* (make-f32 8) "The HUD pip's arguments: cx cy r, [3] the fx clock.")
(defvar *lb-alphas* (let ((v (make-array 21))) (dotimes (i 21 v) (setf (svref v i) (f32 (/ i 20.0)))))
  "Boxed alphas 0, 0.05 .. 1: a draw's :ALPHA without consing.")
(defmacro lb-alpha (a) `(svref *lb-alphas* (f->i (+ 0.5f0 (* 20f0 (f-clamp ,a 0f0 1f0))))))

(defmacro %lb-frame! (m ox oy oz dx dy dz nx ny nz s &optional sw)
  "Fill M with the frame at (OX OY OZ): +Y along the unit (DX DY DZ), +Z the normal (NX NY NZ) made square to it, +X =
Y x Z, +Y scaled by S, +X and +Z by SW (default S). Single-float forms; a macro: 0 B."
  `(let* ((%dx ,dx) (%dy ,dy) (%dz ,dz) (%nx ,nx) (%ny ,ny) (%nz ,nz) (%s ,s) (%w ,(or sw '%s))
          (%d (+ (* %nx %dx) (* %ny %dy) (* %nz %dz)))
          (%ax (- %nx (* %d %dx))) (%ay (- %ny (* %d %dy))) (%az (- %nz (* %d %dz)))
          (%al (f-max 1f-5 (f-hypot %ax %ay %az)))
          (%zx (/ %ax %al)) (%zy (/ %ay %al)) (%zz (/ %az %al))
          (%xx (- (* %dy %zz) (* %dz %zy))) (%xy (- (* %dz %zx) (* %dx %zz))) (%xz (- (* %dx %zy) (* %dy %zx)))
          (%m ,m))
     (declare (single-float %dx %dy %dz %nx %ny %nz %s %w %d %ax %ay %az %al %zx %zy %zz %xx %xy %xz) (type f32vec %m))
     (setf (aref %m 0) (* %w %xx) (aref %m 1) (* %w %xy) (aref %m 2) (* %w %xz) (aref %m 3) 0f0
           (aref %m 4) (* %s %dx) (aref %m 5) (* %s %dy) (aref %m 6) (* %s %dz) (aref %m 7) 0f0
           (aref %m 8) (* %w %zx) (aref %m 9) (* %w %zy) (aref %m 10) (* %w %zz) (aref %m 11) 0f0
           (aref %m 12) ,ox (aref %m 13) ,oy (aref %m 14) ,oz (aref %m 15) 1f0)))

(defmacro %lb-joint-frame! (m jm o lx ly lz s)
  "Fill M with joint frame O (= 16 x the joint) of JM, its axes scaled by S, its origin moved to the local point (LX LY LZ)."
  `(let* ((%jm ,jm) (%o ,o) (%m ,m) (%lx ,lx) (%ly ,ly) (%lz ,lz) (%s ,s))
     (declare (type f32vec %jm %m) (fixnum %o) (single-float %lx %ly %lz %s))
     (dotimes (%i 12) (setf (aref %m %i) (* %s (aref %jm (+ %o %i)))))
     (setf (aref %m 3) 0f0 (aref %m 7) 0f0 (aref %m 11) 0f0 (aref %m 15) 1f0)
     (dotimes (%k 3)
       (setf (aref %m (+ 12 %k)) (+ (* (aref %jm (+ %o %k)) %lx) (* (aref %jm (+ %o 4 %k)) %ly) (* (aref %jm (+ %o 8 %k)) %lz)
                                    (aref %jm (+ %o 12 %k)))))))

(defmacro %lb-wall (x z ux uz)
  "Metres from (X Z) along the unit (UX UZ) to the arena's wall (*ARENA-RADIUS*). Single-float forms; 0 B."
  `(let* ((%x ,x) (%z ,z) (%ux ,ux) (%uz ,uz) (%r (the single-float (f32 *arena-radius*)))
          (%b (+ (* %x %ux) (* %z %uz))) (%c (- (+ (* %x %x) (* %z %z)) (* %r %r))) (%q (- (* %b %b) %c)))
     (declare (single-float %x %z %ux %uz %r %b %c %q))
     (if (< %q 0f0) 0f0 (f-max 0f0 (+ (- %b) (f-sqrt %q))))))

(defmacro %lb-floor-line (kind x0 z0 ux uz len w)
  "A flat line on the floor from (X0 Z0) along the unit (UX UZ), LEN long, W wide: KIND 0 grey, 1 jade, 2 ink, 3 the owl's
gold (its numbers
go through *LB-V* [17..22]: a DEFUN-FAST call would box them)."
  `(let ((%v *lb-v*))
     (declare (type f32vec %v))
     (setf (aref %v 17) ,x0 (aref %v 18) ,z0 (aref %v 19) ,ux (aref %v 20) ,uz (aref %v 21) ,len (aref %v 22) ,w)
     (%lb-floor-line* ,kind)))
(defun-fast %lb-floor-line* (kind)
  (declare (fixnum kind))
  (let* ((m *lb-m*) (v *lb-v*) (x0 (aref v 17)) (z0 (aref v 18)) (ux (aref v 19)) (uz (aref v 20)) (len (aref v 21)) (w (aref v 22)))
    (declare (type f32vec m v) (single-float x0 z0 ux uz len w))
    (setf (aref m 0) (* w (- uz)) (aref m 1) 0f0 (aref m 2) (* w ux) (aref m 3) 0f0
          (aref m 4) (* len ux) (aref m 5) 0f0 (aref m 6) (* len uz) (aref m 7) 0f0
          (aref m 8) 0f0 (aref m 9) 0.006f0 (aref m 10) 0f0 (aref m 11) 0f0
          (aref m 12) x0 (aref m 13) 0.022f0 (aref m 14) z0 (aref m 15) 1f0)
    (setf (aref *toon-body* 1) 0f0)
    (case kind (0 (draw-weapon :lb-line-grey m)) (1 (draw-weapon :lb-line-jade m)) (3 (draw-weapon :lb-line-gold m))
          (t (draw-weapon :lb-line m)))
    nil))

(defmacro %lb-reticle (jade x z r spin)
  "The reticle (the eye mark) flat on the floor at (X Z), radius R, turned SPIN: JADE (locked) or grey (*LB-V* [17..20])."
  `(let ((%v *lb-v*))
     (declare (type f32vec %v))
     (setf (aref %v 17) ,x (aref %v 18) ,z (aref %v 19) ,r (aref %v 20) ,spin)
     (%lb-reticle* ,jade)))
(defun-fast %lb-reticle* (jade)
  (let* ((m *lb-m*) (v *lb-v*) (x (aref v 17)) (z (aref v 18)) (r (aref v 19)) (spin (aref v 20)) (c (f-cos spin)) (s (f-sin spin)))
    (declare (type f32vec m v) (single-float x z r spin c s))
    (setf (aref m 0) (* r c) (aref m 1) 0f0 (aref m 2) (* r (- s)) (aref m 3) 0f0
          (aref m 4) 0f0 (aref m 5) r (aref m 6) 0f0 (aref m 7) 0f0
          (aref m 8) (* r s) (aref m 9) 0f0 (aref m 10) (* r c) (aref m 11) 0f0
          (aref m 12) x (aref m 13) 0.03f0 (aref m 14) z (aref m 15) 1f0)
    (setf (aref *toon-body* 1) 0f0)
    (if jade (draw-weapon :lb-reticle-jade m) (draw-weapon :lb-reticle-grey m))
    nil))

;;; ---------------------------------------------------------------- the wings (Jilliel's eight, the owl's eight)
;; Translucent (decision 27, 2026-10-06: 「把翅膀調整成半透明以免遮擋視線」): the engine draws an alpha < 1 in its transparent
;; pass (the lit shader, after the opaque scene, no depth write: what is behind shows through; the toon pass is opaque only),
;; where a plain colour reads dark (the duel's toon light is not the lit shader's), so the glass carries a glow (emissive x
;; its colour) that brings it back to its jade / gold. Decision 32 (2026-10-06: 「萊醬你能幫我將覺醒後翅膀的不透明邊界也都換成
;; 半透明嗎？」): the rim (outline band, teeth, hole rings, joints) is see-through too, a little stronger than the glass and
;; with the same glow, so the outline still reads and it is not the dark phantom.
(defparameter *lb-glass-alpha* 0.35 "The wings' glass alpha (decision 27): the fight shows through a blade.")
(defparameter *lb-glass-glow* 1.0 "The glass's (and since decision 32 the rim's) emissive (x its colour): the translucent
path's colour back to the jade / gold.")
(defparameter *lb-rim-alpha* 0.6
  "The rim's alpha (decision 32, the user 2026-10-06: the rims see-through too; was opaque, 1.0): a little stronger than the
glass (0.35) so the blade's outline, teeth and holes still read.")
;; Lille II's lit wings (DUEL_LILLE_V3 §3.1, §4: 「a lit blade each; the owl's gold wings」, 2026-10-10): in his awakened
;; forms his special resource is the wings, and the count shows on the eight blades. BR-DRAW (barro-art.lisp) puts the
;; count + 1 in *LB-FX* [19] of his side before LILLE-DRAW; LILLE-DRAW clears it after the wings
;; (0: every blade plain, neither loaded nor spent). The loaded blades are the first N by row (top pair down, right before left), so a
;; spent wing goes dark from the lowest pair up: the loaded ones' rims stronger and their three holes glowing (jade / the
;; owl's gold, a white core), the spent ones dimmed. A blade lit by a volley beat ([65]) keeps the normal look.
(defparameter *lb-load-rim* 0.85 "Lille II's loaded wing: its rim's alpha (the normal 0.6), the outline and holes reading brighter ...")
(defparameter *lb-load-hole* 0.05 "... its holes' glow radius (m; a white core 0.4 x; the Kikon card's 0.06), pulsing +-15 % ...")
(defparameter *lb-spent-glass* 0.12 "... and a spent wing's glass alpha (the normal 0.35) ...")
(defparameter *lb-spent-rim* 0.25 "... its rim's (the normal 0.6) ...")
(defparameter *lb-spent-glow* 0.45 "... and both their emissive (the normal *LB-GLASS-GLOW* 1.0): a spent blade reads dark.")
;; Jointed (decision 32, 2026-10-06: 「每片翅膀改成中間加 2 節可以彎折的連接觸，讓整體動作與攻擊動畫不會太死板」): each blade is
;; three segments chained at two joints (1/3, 2/3); each joint TILTS the next segment's frame (toward the blade's width
;; axis: a bend in its plane; toward its normal: a curl out of it). What bends them, all cosmetic (the fx clock, his pose
;; and the move's frame; never sim state or the sim's RNG):
;; - the idle WAVE: each joint on the wing's own phase, the tip's joint lagging the root's (travelling root -> tip);
;; - the LAG: a damped spring per wing (*LB-WM*) toward a bend set by the speed of its drive point (a front wing's hand,
;;   another wing's straight tip), plus, in a strike, a virtual speed along his facing: the wind-up cocks the joints back
;;   (trailing), the active frames snap them straight (the spring zeroed), the recovery throws them forward (the overshoot)
;;   and the spring settles them. A free wing's tip trails its motion; a front wing is pinned at both ends (root and hand),
;;   so its middle bows behind the motion;
;; - MUJITTAI curls them round the column (toward it), an SP / Kikon spread furls them then unfurls them from the root.
;; A FRONT wing's chain is then turned about its root so its end is exactly the rig's hand and its length set to reach it:
;; the drawn tip is the hand at every frame (the strike point the host FK test reads), bent or not.
(defparameter *lb-wave-amp* 0.22 "The idle wave: each joint's bend in the blade's plane (radians, at its peak).")
(defparameter *lb-wave-curl* 0.1 "... and its curl out of the plane (radians).")
(defparameter *lb-wave-speed* 2.3 "The wave's angular speed (rad/s of the fx clock).")
(defparameter *lb-wave-lag* 1.1 "The wave's phase lag from the root's joint to the tip's (radians): it travels root -> tip.")
(defparameter *lb-lag-gain* 0.045 "The lag spring's target bend per m/s of the drive point (radians).")
(defparameter *lb-lag-max* 0.75 "... at most (radians a joint; the tip's joint bends 1.4 x).")
(defparameter *lb-strike-in* 14.0 "A strike's wind-up: the virtual speed (m/s) along his facing and up (*LB-STRIKE-UP*) that
cocks the joints back and down.")
(defparameter *lb-strike-up* 0.7 "... the up share of that direction (so the fan's joints bend in its plane too: it reads from behind).")
(defparameter *lb-strike-out* 12.0 "A strike's recovery: the virtual speed back (m/s, easing out) that throws them forward.")
(defparameter *lb-fold-curl* 0.38 "MUJITTAI: each joint's curl toward the column (radians; the tip's 1.2 x).")
(defparameter *lb-furl* 0.55 "An SP / Kikon spread: the joints' furl before they unfurl from the root (radians).")
;; Decision 50 (2026-10-07, DUEL_LILLE §23.31; the user: 「Jilliel 近戰的動作不太明顯」, then all four directions for both modes,
;; 「全身出招」「每招獨立造型」「翼尖斬痕」「八翼一起斬」「近戰＋遠程都換」): every J / K of KIN (:lb-w-q1 .. :lb-w-f3) and of EN (its own
;; casts :lb-e-q1 .. :lb-e-f3) is its own whole-body strike, the striking tips leave a jade smear, and around the hit the six
;; table wings converge in turn: KIN's round his hit point ahead (a ring at his reach), EN's on the line ahead on the floor (a K's
;; on its fan of three). All of it a look: the move's frame read for the timing only, never sim state.
(defparameter *lb-jilliel-strikes* '(:lb-w-q1 :lb-w-q2 :lb-w-q3 :lb-w-f1 :lb-w-f2 :lb-w-f3 :lb-e-q1 :lb-e-q2 :lb-e-q3
                                     :lb-e-f1 :lb-e-f2 :lb-e-f3
                                     :br-en-lc :br-en-l1 :br-en-j1 :br-en-j2 :br-en-j3 :br-en-k1 :br-en-k2 :br-en-k3)
  "Jilliel's strike clips (decision 50): KIN's six, EN's six casts; Lille II's awakened stance openers (barro-art.lisp, his
melee wing strikes since DUEL_LILLE_V3 R4: the ring at his reach, as KIN's). Their moves drive the convergence and the trails.")
(defparameter *lb-conv-from* -2.0 "The convergence: the first table wing launches this many frames from the strike's S ...")
(defparameter *lb-conv-step-j* 0.8 "... the next ones in turn this many frames apart (a J; striking side first, top pair down) ...")
(defparameter *lb-conv-step-k* 1.0 "... (a K) ...")
(defparameter *lb-conv-ramp* 2.5 "... each reaching its target over this many frames (smoothstep) ...")
(defparameter *lb-conv-hold* 3.0 "... held this many frames past the active end ...")
(defparameter *lb-conv-out* 0.5 "... then back to the fan over this share of the recovery.")
(defparameter *lb-conv-stretch* 1.3 "A converging wing reaches its target, at most this many times its own length.")
(defparameter *lb-conv-ring* 0.22 "KIN: the six tips meet in a ring this wide (m) round his hit point (his facing x reach - 0.1 m).")
(defparameter *lb-conv-near* 2.2 "EN: the top pair aims this far ahead on the line (m), each pair below *LB-CONV-GAP* further.")
(defparameter *lb-conv-gap* 0.9 "EN: (the pairs' spacing along the line, m).")
(defparameter *lb-jump-jl* 4.0
  "Jilliel's lag spring jump (m^2; the owl's 1): his spins sweep a tip up to ~1.8 m a frame, still a motion to trail.")
(defparameter *lb-trail-from* -5 "The tip trails record from this frame of the strike (from S) ...")
(defparameter *lb-trail-to* 3 "... to its active end + this; else they fade a sample a frame (the smear: %LB-SMEAR).")
;; Decision 56 (2026-10-08, DUEL_LILLE §23.37; the user: 「梟頭模式近戰的動作不太明顯」, then 「猛禽爪擊」 with 「全身出招」
;; 「金色爪痕」「金翼振翅」「八翼匯聚」 and its EN 「另做一套」): the owl's J / K are a raptor's claws (KIN :lb-o-q1 .. :lb-o-f3, EN's
;; own casts :lb-oe-q1 .. :lb-oe-f3); its eight gold wings beat once into each strike (%LB-OWL-BEAT!), then all eight converge
;; in turn on Jilliel's targets (KIN his hit point, EN the line ahead: its arms are the claws, so no wing is a front wing and
;; every one is free), and the striking claws leave three thin gold streaks (%LB-CLAW-TRAILS). All of it a look: the move's
;; frame read for the timing only, never sim state.
(defparameter *lb-owl-strikes* '(:lb-o-q1 :lb-o-q2 :lb-o-q3 :lb-o-f1 :lb-o-f2 :lb-o-f3 :lb-oe-q1 :lb-oe-q2 :lb-oe-q3
                                 :lb-oe-f1 :lb-oe-f2 :lb-oe-f3
                                 :br-oen-lc :br-oen-l1 :br-oen-j1 :br-oen-j2 :br-oen-j3 :br-oen-k1 :br-oen-k2 :br-oen-k3)
  "The owl's claw strikes (decision 56): KIN's six, EN's six casts; Lille II's owl EN stance openers (his melee claw strikes,
DUEL_LILLE_V3 R4). Their moves drive the beat, the convergence and the claw trails.")
(defparameter *lb-owl-conv-from* -1.0
  "The owl's convergence: its first wing launches this many frames from the strike's S (Jilliel's -2: the beat's down-stroke
reads first) ...")
(defparameter *lb-owl-conv-step-j* 0.5 "... the next ones in turn this many frames apart (a J: eight wings, Jilliel's six 0.8) ...")
(defparameter *lb-owl-conv-step-k* 0.7 "... (a K; Jilliel's 1.0). Its ramp, hold, return, stretch, ring and line are Jilliel's knobs.")
(defparameter *lb-owl-trail-from* -1
  "The claw trails record from this frame of the strike (from S; Jilliel's tips -5): the rake itself, not the wind-up.")
(defparameter *lb-owl-beat-up* 38.0 "The beat (金翼振翅): the eight wings raised this many degrees over the wind-up ...")
(defparameter *lb-owl-beat-down* 30.0
  "... struck down to this many degrees below their place into S, held through the active frames, back over the recovery ...")
(defparameter *lb-owl-beat-stroke* 3 "... the down-stroke over the startup's last this many frames (a K's + 1) ...")
(defparameter *lb-owl-beat-open* 0.45 "... opening KIN's swept-back sheaf this far (0..1) through it ...")
(defparameter *lb-owl-beat-k3* 1.6
  "... K3's (the stoop) raised and pressed down this many times as far, and held flared into the landing.")
;; Two fans of four (decision 19; the refs: the upper pair high and out, the lowest pair down and out), rooted behind the
;; column's top (the owl: behind the ruff). Per wing, a row of 10 in an f32vec (read in DEFUN-FAST code without consing):
;; side, elevation (degrees above the horizontal), length (m), sweep back, where it folds to (MUJITTAI: down round the
;; column, wrapping forward; x y z), front (1: its tip is the rig's hand, the strike point), flip (1: the torn edge up, the
;; lowest pair), the idle sway's phase. Rows in pairs, top pair first (a cinematic unfolds them a pair at a time).
(defparameter *lb-wings-jl*
  (coerce (mapcar #'f32 '( 1  40 1.6  0.18 0.45 -0.75 -0.55 0 0 0.0    -1  40 1.6  0.18 0.45 -0.75 -0.55 0 0 2.1
                           1  13 1.75 0.22 0.62 -0.75 -0.2  0 0 1.1    -1  13 1.75 0.22 0.62 -0.75 -0.2  0 0 3.4
                           1 -16 1.75 0.0  0.5  -0.8  -0.5  1 0 0.0    -1 -16 1.75 0.0  0.5  -0.8  -0.5  1 0 0.0
                           1 -40 1.5  0.18 0.5  -0.86 0.15  0 1 2.6    -1 -40 1.5  0.18 0.5  -0.86 0.15  0 1 0.5))
          'f32vec)
  "Jilliel's eight wing blades: +40 / +13 / the front pair (the rig's hands: about -16 idle) / -40 degrees a side.")
(defparameter *lb-wings-owl*
  (coerce (mapcar #'f32 '( 1  34 1.9  0.25 0.4 -0.8 -0.4   0 0 0.7    -1  34 1.9  0.25 0.4 -0.8 -0.4   0 0 2.9
                           1  11 2.05 0.3  0.5 -0.8 -0.2   0 0 1.8    -1  11 2.05 0.3  0.5 -0.8 -0.2   0 0 0.2
                           1 -11 1.95 0.3  0.5 -0.85 0.0   0 0 3.1    -1 -11 1.95 0.3  0.5 -0.85 0.0   0 0 1.3
                           1 -34 1.7  0.25 0.45 -0.9 0.2   0 1 2.2    -1 -34 1.7  0.25 0.45 -0.9 0.2   0 1 4.0))
          'f32vec)
  "The owl's eight gold wing blades, two fans of four (+34 / +11 / -11 / -34 degrees a side, long: the refs' wide spread);
its claws are its hands.")
(declaim (type f32vec *lb-wings-jl* *lb-wings-owl* *lb-wf* *lb-wm*))
;; Lille II's wing wall (DUEL_LILLE_V3 "The wing wall", the user 2026-10-12: 「把覺醒時的防禦姿勢改成用八翼擋住前面進行防禦」):
;; while he guards in an awakened form his draw hook (BR-DRAW) sets *LB-WF* [91] (0..1, eased in and out) and %LB-WINGS
;; brings the eight blades round in front of him: each blade's chain pinned at its place in the wall (a front wing at the
;; rig's hand, where his guard clip puts it), its face square to his side and its two joints curled toward the column so
;; it bows round his side and crosses his midline in front (the right wings' tips past his left, overlapping the left's).
;; Per wing, a row of 4 (in his chest's frame, the root's side +): across (x the wing's side: - = past his midline), up,
;; forward (m; a front wing's ignored: the hand), the curl at each joint (radians).
(defparameter *lb-wall-jl*
  (coerce (mapcar #'f32 '(-0.3  0.35 0.7  1.1    -0.3  0.35 0.7  1.1
                          -0.3 -0.05 0.75 1.1    -0.3 -0.05 0.75 1.1
                           0.0  0.0  0.0  1.0     0.0  0.0  0.0  1.0
                          -0.3 -0.85 0.7  0.8    -0.3 -0.85 0.7  0.8))
          'f32vec)
  "JILLIEL's wing wall: the top pair high before his head, the next before his chest, the front pair at the hands (his
guard clips, barro-art.lisp :br-w-guard / :br-w-guard-hit, put them low before him), the lowest before his hips.")
(defparameter *lb-wall-owl*
  (coerce (mapcar #'f32 '(-0.3  0.45 0.75 1.1    -0.3  0.45 0.75 1.1
                          -0.3  0.1  0.8  1.2    -0.3  0.1  0.8  1.2
                          -0.3 -0.3  0.9  1.1    -0.3 -0.3  0.9  1.1
                          -0.3 -0.7  1.0  0.9    -0.3 -0.7  1.0  0.9))
          'f32vec)
  "The owl's wing wall: its eight gold blades in four rows before it (its claws crossed behind them: :br-o-guard).")
(declaim (type f32vec *lb-wall-jl* *lb-wall-owl*))
(defvar *lb-wf* (make-f32 92)
  "The jointed wings' scratch: [0..26] the three segments' unit frames (9 each: X Y Z), [30 31] a tilt's numbers (toward X,
toward Z), [32..35] the chain's turn (axis, angle); per call (LILLE-DRAW's %LB-DRIVE!): [39] the strike's virtual speed
(m/s along his facing), [40] the striking front wings (bit 0 right, bit 1 left), [41] 1 on the active frames (straight),
[42] the spread's unfurl 0..1, [43] the step (s; 0 = no spring step), [44] the strike's share for the other wings, [45] the
lag spring's jump (m^2: a drive point moving further in a frame counts as still; 1 the owl, *LB-JUMP-JL* Jilliel's), and
for a Jilliel strike (decision 50) [46] its clock (frames since S), [47] 1 = the six table wings converge, [48] 1 = EN (on
the line ahead) else KIN (round his hit point ahead), [49] 1 = a K (EN: its fan of three lines), [50] A, [51] R, [52] 1 =
the tip trails record (*LB-TRAIL-FROM* .. A + *LB-TRAIL-TO*), [54] the move's reach; per draw [53] the clip's root turn,
[59 60] its root f / r (LILLE-DRAW), and %LB-WINGS' [55 56] where he stands, [57 58] his facing (the clip's turn out); the
SP / Kikon looks (decision 56, %LB-SP-DRIVE!): [61] the ring 0..1, [62] its cup, [63] its shake, [64] the close, [65] the
wings drawn with their holes lit (bits by row), [66] their muzzle flash 0..1, [67] the holes glowing (the first N, the
Kikon cinematic's card); for the owl's claws (decision 56, %LB-OWL-BEAT!) [68] the wing beat's elevation (degrees), [69] its
opening of KIN's swept sheaf 0..1, [70] 1 = an owl strike (all eight wings converge, four pairs); per draw (%LB-STRETCH!,
Lille II's whips) [71] the stretched wing's width gain (*LB-STRETCH-GROW*), [72 73] the right / left front wing's stretch
(m past the hand, *LB-STRETCH*), and %LB-WINGS' [74..76]
[77..79] the right / left front wing's drawn tip (the hand, or past it by the stretch); set by another kit's draw hook
before LILLE-DRAW (Lille II's, DUEL_LILLE_V3 §15 R10, §16 R11; 0 = off, and Lille never sets them): [80] the sweep's
tightness (*LB-V* [29] at least this while a *LB-SWEEP-CLIPS* clip plays), [81 82] 1 = the right / left front wing / claw is
a whip's root (R11: Lille II's whip, drawn after LILLE-DRAW on from it: %LB-WINGS thins that blade to 0.45, %LB-LASHES skips
that claw's gold comet), [89] the ㄇ
legs' fold + 1 (R11, the stance switch: the shanks tucked under the strut, 0..1, in place of the owl EN's own tuck *LB-V*
[8]) and [90] their pull 0..1 (the whole ㄇ shrunk into the hips: %LB-LEGS draws the strut and the shanks 1 - [90] long);
[91] the wing wall 0..1 (his guard: *LB-WALL-JL* / *-OWL*).")
(defvar *lb-stretch* nil
  "Another kit's stretched wings (Lille II's whips, barro-art.lisp *BR-W-STRETCH*, DUEL_LILLE_V3 §10; Lille's own clips are
never in it): clip name -> an f32vec of keys (frame right left), the metres a front wing reaches past the rig's hand at that
frame of the clip (Jilliel: the blade drawn on past the hand along its root -> hand line; the owl: a gold lash drawn on from
the claw along the forearm), linear between the keys, held past the ends. The host FK test reads the same table: the
stretched tip is the strike point.")
(defvar *lb-no-conv* nil
  "Strike clips (in *LB-JILLIEL-STRIKES* / *LB-OWL-STRIKES*) whose table wings do not converge on the hit (Lille II's spinning
L, barro-art.lisp: the wings spin with him); their trails and the owl's beat as the rest.")
(defvar *lb-sweep-clips* nil
  "Clips during which the table wings are swept back into a narrow sheaf along his back (the owl KIN's sweep, *LB-V* [29]
= 1), in either form: Lille II's awakened L dash (DUEL_LILLE_V3 §14, R9: 「八翼往後收、身體前傾高速衝向對手」).")
(defvar *lb-trail-cut* nil
  "Clip -> a move frame: the tip / claw trails of these strike clips stop recording from that frame of the move (Lille II's
零距離砲擊, DUEL_LILLE_V3 §11: 「砲擊不要發射光束」, so the thrust leaves no streak toward him).")
(defvar *lb-stretch-grow* nil
  "Clip -> a width gain (a single-float, per metre of stretch): the stretched front wing (or the owl's lash) of these clips
also grows wider with its stretch (Lille II's heavy blade, DUEL_LILLE_V3 §11: 「揮砍前光翼隨身體的距離伸長放大」); the whips
of the other stretched clips stay thin.")
(defun-fast %lb-stretch! (an)
  "*LB-WF* [72 73]: the front wings' stretch (*LB-STRETCH*) at anim AN's clip and time (its frame: 60 x the clip's seconds);
0 for a clip not in the table; [71] its width gain (*LB-STRETCH-GROW*, 0 when not listed). Cosmetic. 0 B."
  (let* ((w *lb-wf*) (c (anim-clip an)) (e (and c (assoc (clip-name c) *lb-stretch*)))
         (gw (and c (assoc (clip-name c) *lb-stretch-grow*))) (r 0f0) (l 0f0))
    (declare (type f32vec w) (single-float r l))
    (setf (aref w 71) (if gw (the single-float (cdr gw)) 0f0))
    (when e
      (let* ((kv (cdr e)) (n (floor (length kv) 3)) (fr (* 60f0 (the single-float (anim-time an)))))
        (declare (type f32vec kv) (fixnum n) (single-float fr))
        (cond ((<= fr (aref kv 0)) (setf r (aref kv 1) l (aref kv 2)))
              ((>= fr (aref kv (* 3 (1- n)))) (setf r (aref kv (- (* 3 n) 2)) l (aref kv (1- (* 3 n)))))
              (t (dotimes (i (1- n))
                   (let* ((o (* 3 i)) (a (aref kv o)) (b (aref kv (+ o 3))))
                     (declare (fixnum o) (single-float a b))
                     (when (and (<= a fr) (< fr b))
                       (let ((u (/ (- fr a) (f-max 1f-5 (- b a)))))
                         (declare (single-float u))
                         (setf r (+ (aref kv (+ o 1)) (* u (- (aref kv (+ o 4)) (aref kv (+ o 1)))))
                               l (+ (aref kv (+ o 2)) (* u (- (aref kv (+ o 5)) (aref kv (+ o 2))))))))))))))
    (setf (aref w 72) r (aref w 73) l)
    nil))
(declaim (type f32vec *lb-holes* *lb-judge-pierce*))
;; Decision 56's Kikon cinematic (LB-JILLIEL-KIKON-CINE; the storyboard, DUEL_LILLE §23.37): 48 jade lines out of the 24
;; holes (each twice), the first three spaced, then faster and faster; each pierces the opponent and leaves a white hole in
;; him (on the white card, his black silhouette) until the verdict shatters him (VFX-LB-JUDGE). All read from the
;; cinematic's frame, no memory: a skipped or aborted cinematic leaves nothing.
(defparameter *lb-judge-shots*
  (let ((v (make-array 48 :element-type 'fixnum)))
    (dotimes (n 48 v)
      (setf (aref v n) (case n (0 96) (1 143) (2 174) (t (+ 192 (round (* 46 (sqrt (/ (- n 3) 44.0))))))))))
  "The cinematic frame pierce N is fired on (its line flies *LB-JUDGE-FLY* frames of the cinematic's effect time to the
hit): 96 / 143 / 174 (beat 3, Amendment 2: each hit slowed, *LB-JUDGE-SLOW*), then 192 + 46 sqrt((n - 3) / 44) to 238
(beat 4: 7 f apart at first, several a frame at the end).")
(defparameter *lb-judge-fly* 3.0 "A pierce's line flies this many frames (of the cinematic's effect time) to the hit.")
(defparameter *lb-judge-slow* '((99 139 0.2) (146 171 0.33333334) (177 192 0.5))
  "Amendment 2 (the user 2026-10-08: 「1/5 → 1/3 → 1/2」): the first three hits' slow motion, (from to rate) in cinematic
frames: the actors' clips and the effects at RATE (CINE-SLOW, set by the script on the same frames), and the effect time
the lines and holes run on (*LB-JUDGE-TIME*).")
(declaim (type f32vec *lb-judge-time*))
(defparameter *lb-judge-time*
  (let ((v (make-f32 401)) (tm 0.0))
    (dotimes (c 401 v)
      (setf (aref v c) (f32 tm))
      (incf tm (or (loop for (a b k) in *lb-judge-slow* when (and (<= a c) (< c b)) return k) 1.0))))
  "The Kikon cinematic's effect time at each of its frames (frames at speed 1, slower in *LB-JUDGE-SLOW*): the lines'
flight and fade, the holes' and stars' timing, the ring's kicks. Frames past 400 read 400's.")
(defmacro %lb-judge-t (c) "The effect time at cinematic frame C (a fixnum form)." `(aref *lb-judge-time* (min 400 (max 0 ,c))))
(defparameter *lb-judge-pierce*
  (let ((v (make-f32 (* 48 3))))
    (dotimes (n 48 v)
      (let* ((h1 (let ((x (* 43758.547 (sin (+ (* n 12.9898) 4.1))))) (- x (floor x))))
             (h2 (let ((x (* 43758.547 (sin (+ (* n 78.233) 1.3))))) (- x (floor x))))
             (y (+ 0.3 (* 1.42 h2)))                    ; up his body; the half-width by part: legs, torso, head
             (hw (cond ((< y 0.85) 0.17) ((< y 1.48) 0.24) (t 0.09))))
        (setf (aref v (* 3 n)) (f32 (* hw (- (* 2 h1) 1))) (aref v (+ 1 (* 3 n))) (f32 y)
              (aref v (+ 2 (* 3 n))) (f32 (+ 0.045 (* 0.015 (mod (* 7 n) 3))))))))
  "Pierce N's point on the opponent (3 each: across his body, + = his right (m), up from his feet (m), its hole's radius),
hashed once (a fixed pattern).")
(defmacro %lb-judge-hole (n) "The hole pierce N fires from (each hole twice, scattered round the ring)." `(mod (* 7 ,n) 24))
(defvar *lb-holes* (make-f32 (* 2 24 3))
  "Per side, the 24 holes' world points as last drawn (%LB-WINGS: wing I's hole G at 3 I + G; decision 56): the Kikon
cinematic's muzzles (VFX-LB-JUDGE). Cosmetic memory.")
(defvar *lb-wm* (make-f32 (* 2 8 9))
  "Per side and wing (9 each): [0..2] its drive point last frame, [3..5] the lag spring's bend (a world vector, radians),
[6..8] its rate. Cosmetic memory (never sim state).")
(defmacro %lb-ss (x) "Smoothstep of X clamped to 0..1 (single-float; 0 B)." `(let ((%x (f-clamp ,x 0f0 1f0))) (declare (single-float %x)) (* %x %x (- 3f0 (* 2f0 %x)))))

(defmacro %lb-basis! (w o dx dy dz nx ny nz)
  "Fill W [O..O+8] with a unit frame X Y Z: Y the unit (DX DY DZ), Z the normal (NX NY NZ) made square to it, X = Y x Z
(%LB-FRAME!'s axes, unscaled). Single-float forms; 0 B."
  `(let* ((%w ,w) (%o ,o) (%dx ,dx) (%dy ,dy) (%dz ,dz) (%nx ,nx) (%ny ,ny) (%nz ,nz)
          (%d (+ (* %nx %dx) (* %ny %dy) (* %nz %dz)))
          (%ax (- %nx (* %d %dx))) (%ay (- %ny (* %d %dy))) (%az (- %nz (* %d %dz)))
          (%al (f-max 1f-5 (f-hypot %ax %ay %az)))
          (%zx (/ %ax %al)) (%zy (/ %ay %al)) (%zz (/ %az %al)))
     (declare (type f32vec %w) (fixnum %o) (single-float %dx %dy %dz %nx %ny %nz %d %ax %ay %az %al %zx %zy %zz))
     (setf (aref %w %o) (- (* %dy %zz) (* %dz %zy)) (aref %w (+ %o 1)) (- (* %dz %zx) (* %dx %zz))
           (aref %w (+ %o 2)) (- (* %dx %zy) (* %dy %zx))
           (aref %w (+ %o 3)) %dx (aref %w (+ %o 4)) %dy (aref %w (+ %o 5)) %dz
           (aref %w (+ %o 6)) %zx (aref %w (+ %o 7)) %zy (aref %w (+ %o 8)) %zz)))

(defun-fast %lb-tilt! (a b)
  "*LB-WF*'s frame at B = its frame at A tilted at the joint: its Y turned toward X by [30] and toward Z by [31] (radians;
the turn's axis is square to Y, so the frame stays orthonormal). 0 B."
  (declare (fixnum a b))
  (let* ((w *lb-wf*) (tx (aref w 30)) (tz (aref w 31)) (an (f-hypot tx tz)))
    (declare (type f32vec w) (single-float tx tz an))
    (if (< an 1f-5)
        (dotimes (q 9) (setf (aref w (+ b q)) (aref w (+ a q))))
        (let ((c (f-cos an)) (s (f-sin an)) (p (/ tx an)) (r (/ tz an)))
          (declare (single-float c s p r))
          (dotimes (q 3)                                 ; d = the tilt's direction (p X + r Z), e = Y x d (the axis)
            (let* ((x (aref w (+ a q))) (y (aref w (+ a 3 q))) (z (aref w (+ a 6 q)))
                   (d (+ (* p x) (* r z))) (e (- (* r x) (* p z))) (d2 (- (* c d) (* s y))))
              (declare (single-float x y z d e d2))
              (setf (aref w (+ b 3 q)) (+ (* c y) (* s d))
                    (aref w (+ b q)) (+ (* p d2) (* r e))
                    (aref w (+ b 6 q)) (- (* r d2) (* p e)))))))
    nil))

(defun-fast %lb-turn-chain! ()
  "Turn the three frames of *LB-WF* [0..26] about the unit axis [32..34] by the angle [35] (Rodrigues). 0 B."
  (let* ((w *lb-wf*) (kx (aref w 32)) (ky (aref w 33)) (kz (aref w 34)) (an (aref w 35))
         (c (f-cos an)) (s (f-sin an)) (c1 (- 1f0 c)))
    (declare (type f32vec w) (single-float kx ky kz an c s c1))
    (dotimes (i 9)
      (let* ((o (* 3 i)) (x (aref w o)) (y (aref w (+ o 1))) (z (aref w (+ o 2)))
             (kv (* c1 (+ (* kx x) (* ky y) (* kz z)))))
        (declare (fixnum o) (single-float x y z kv))
        (setf (aref w o) (+ (* c x) (* s (- (* ky z) (* kz y))) (* kx kv))
              (aref w (+ o 1)) (+ (* c y) (* s (- (* kz x) (* kx z))) (* ky kv))
              (aref w (+ o 2)) (+ (* c z) (* s (- (* kx y) (* ky x))) (* kz kv)))))
    nil))

(defmacro %lb-seg-m! (m w b ox oy oz len wd)
  "Fill M with *LB-WF*'s segment frame at B (unit X Y Z), at (OX OY OZ), +Y scaled by LEN (the blade's length), +X and +Z
by WD (its width scale). 0 B."
  `(let ((%m ,m) (%w ,w) (%b ,b) (%l ,len) (%d ,wd))
     (declare (type f32vec %m %w) (fixnum %b) (single-float %l %d))
     (dotimes (%q 3)
       (setf (aref %m %q) (* %d (aref %w (+ %b %q))) (aref %m (+ 4 %q)) (* %l (aref %w (+ %b 3 %q)))
             (aref %m (+ 8 %q)) (* %d (aref %w (+ %b 6 %q)))))
     (setf (aref %m 3) 0f0 (aref %m 7) 0f0 (aref %m 11) 0f0 (aref %m 12) ,ox (aref %m 13) ,oy (aref %m 14) ,oz (aref %m 15) 1f0)))

(defmacro %lb-wing-draw (kind g ga ra &optional (em '*lb-glass-glow*))
  "Draw segment G (0 root, 1 middle, 2 tip) of a blade at *LB-M*: its glass at GA, then its rim at RA (both see-through
with the glow EM: a boxed float form, *LB-GLASS-GLOW* unless Lille II's spent wing), KIND 0 jade, 1 jade with the holes
lit, 2 gold."
  (flet ((pair (glass rim) `((draw-weapon ,glass *lb-m* :alpha ,ga :emissive ,em)
                             (draw-weapon ,rim *lb-m* :alpha ,ra :emissive ,em))))
    `(case ,kind
       (0 (case ,g (0 ,@(pair :lb-wing-0 :lb-wing-rim-0)) (1 ,@(pair :lb-wing-1 :lb-wing-rim-1)) (t ,@(pair :lb-wing-2 :lb-wing-rim-2))))
       (1 (case ,g (0 ,@(pair :lb-wing-0 :lb-wing-lit-0)) (1 ,@(pair :lb-wing-1 :lb-wing-lit-1)) (t ,@(pair :lb-wing-2 :lb-wing-lit-2))))
       (t (case ,g (0 ,@(pair :lb-wing-gold-0 :lb-wing-gold-rim-0)) (1 ,@(pair :lb-wing-gold-1 :lb-wing-gold-rim-1))
            (t ,@(pair :lb-wing-gold-2 :lb-wing-gold-rim-2)))))))

(defmacro %lb-conv-share (i s mask)
  "Decision 50: how far table wing I (side S, the strike's front-wing MASK) has converged, 0..1, from *LB-WF* [46 49 50 51]:
in turn, the striking side first and the top pair down (both sides at once when both front wings strike), each launching
*LB-CONV-STEP-J* / *-K* frames after the last from *LB-CONV-FROM*, in over *LB-CONV-RAMP*, held to the active end +
*LB-CONV-HOLD*, out over *LB-CONV-OUT* of the recovery. Single-float forms; 0 B."
  `(let* ((%w *lb-wf*) (%i ,i) (%s ,s) (%m ,mask) (%q (floor %i 2)) (%ow (> (aref %w 70) 0.5f0))   ; (the owl: four pairs,
          (%p (if (or %ow (/= %q 3)) %q 2))                                                              ;  decision 56)
          (%rank (+ (* 2 %p) (if (or (= %m 3) (if (= %m 1) (> %s 0f0) (< %s 0f0))) 0 1)))
          (%t (aref %w 46))
          (%go (if %ow
                   (+ (the single-float *lb-owl-conv-from*)
                      (* (i->f %rank) (if (> (aref %w 49) 0.5f0) (the single-float *lb-owl-conv-step-k*) (the single-float *lb-owl-conv-step-j*))))
                   (+ (the single-float *lb-conv-from*)
                      (* (i->f %rank) (if (> (aref %w 49) 0.5f0) (the single-float *lb-conv-step-k*) (the single-float *lb-conv-step-j*))))))
          (%in (%lb-ss (/ (- %t %go) (the single-float *lb-conv-ramp*))))
          (%out (%lb-ss (/ (- %t (aref %w 50) (the single-float *lb-conv-hold*))
                           (f-max 1f0 (* (the single-float *lb-conv-out*) (aref %w 51)))))))
     (declare (type f32vec %w) (fixnum %i %m %q %p %rank) (single-float %s %t %go %in %out))
     (* %in (- 1f0 %out))))

(defun-fast %lb-wings (jm o tbl n kind side)
  "N wings of table TBL (rows of 10) from joint frame O of JM, KIND 0 jade, 1 jade with the holes lit, 2 gold, for SIDE's
fighter: their root (the joint's local point, each side 0.07 m out) in *LB-V* [0..2], the fold [11], the ripple [12] at the
fx clock [13], their alpha [14], the pairs shown [15], the length x [16], the spread [28] (the SPs: the
fan wider and swept forward); the joints' drive in *LB-WF* [39..44] (%LB-DRIVE!). Idle, each sways on its own phase (the fx
clock: cosmetic). A front wing runs from its root to the rig's hand: the drawn tip is the hand, the strike point the host FK
test reads (*LB-STRIKE-POINTS*), its jointed chain turned and stretched to end there. Each blade is three segments (decision
32), each its glass (*LB-GLASS-ALPHA*) and its rim (*LB-RIM-ALPHA*), both see-through with a glow."
  (declare (type f32vec jm tbl) (fixnum o n kind side))
  (let* ((v *lb-v*) (w *lb-wf*) (mm *lb-wm*) (k (aref v 11)) (j (- 1f0 k)) (rip (aref v 12)) (tm (aref v 13)) (a (aref v 14))
         (ga (lb-alpha (* a (the single-float *lb-glass-alpha*))))
         (ra (lb-alpha (* a (the single-float *lb-rim-alpha*))))
         (ld (f->i (aref *lb-fx* (+ (* 24 side) 19))))   ; Lille II's loaded wings + 1 (0: none)
         (rl (lb-alpha (* a (the single-float *lb-load-rim*))))       ; (his loaded blade's rim, ...
         (gs (lb-alpha (* a (the single-float *lb-spent-glass*))))    ;  his spent blade's glass and rim)
         (rs (lb-alpha (* a (the single-float *lb-spent-rim*))))
         (pairs (f->i (aref v 15))) (lk (aref v 16)) (sp (aref v 28))
         (sb (* (aref v 29) (- 1f0 (aref w 69))))        ; (the owl's beat opens KIN's sheaf: decision 56)
         (wal (aref w 91)) (wt (if (eq tbl *lb-wings-owl*) *lb-wall-owl* *lb-wall-jl*))   ; (Lille II's wing wall)
         (rx (aref v 0)) (ry (aref v 1)) (rz (aref v 2))
         (xx (aref jm o)) (xy (aref jm (+ o 1))) (xz (aref jm (+ o 2)))
         (yx (aref jm (+ o 4))) (yy (aref jm (+ o 5))) (yz (aref jm (+ o 6)))
         (zx (aref jm (+ o 8))) (zy (aref jm (+ o 9))) (zz (aref jm (+ o 10)))
         (xl (f-max 1f-5 (f-hypot xx xy xz))) (zl (f-max 1f-5 (f-hypot zx zy zz)))
         (fx (- (/ zx zl))) (fy (- (/ zy zl))) (fz (- (/ zz zl)))   ; his facing (the joint's -Z) and side (X), unit
         (sx (/ xx xl)) (sy (/ xy xl)) (sz (/ xz xl))
         (yl (f-max 1f-5 (f-hypot yx yy yz))) (su (the single-float *lb-strike-up*))
         (vx0 (+ fx (* su (/ yx yl)))) (vy0 (+ fy (* su (/ yy yl)))) (vz0 (+ fz (* su (/ yz yl))))
         (vl (f-max 1f-5 (f-hypot vx0 vy0 vz0)))
         (dvx (/ vx0 vl)) (dvy (/ vy0 vl)) (dvz (/ vz0 vl))           ; a strike's drive direction: forward and up
         (vb (aref w 39)) (mask (f->i (aref w 40))) (act (> (aref w 41) 0.5f0)) (u (aref w 42)) (dt (aref w 43)) (tsc (aref w 44))
         (rise (f-min 1f0 (/ u 0.12f0)))                  ; the spread: furl (u 0 -> 0.12), then unfurl from the root
         (c1 (* rise (- 1f0 (%lb-ss (/ (- u 0.12f0) 0.4f0)))))
         (c2 (* rise (- 1f0 (%lb-ss (/ (- u 0.3f0) 0.5f0)))))
         (gl (the single-float *lb-lag-gain*)) (lm (the single-float *lb-lag-max*))
         (wa (the single-float *lb-wave-amp*)) (wc (the single-float *lb-wave-curl*)) (ws (the single-float *lb-wave-speed*))
         (wl (the single-float *lb-wave-lag*)) (fc (the single-float *lb-fold-curl*)) (fu (the single-float *lb-furl*)))
    (declare (type f32vec v w mm wt) (fixnum pairs mask ld)
             (single-float wal k j rip tm a lk sp sb rx ry rz xx xy xz yx yy yz zx zy zz xl zl fx fy fz sx sy sz yl su vx0 vy0 vz0 vl dvx dvy dvz vb u dt tsc rise c1 c2
                           gl lm wa wc ws wl fc fu))
    (when (> (aref w 47) 0.5f0)                         ; decision 50: where he stands and faces, the clip's root offset and
      (let* ((pfx (- (aref jm 8))) (pfz (- (aref jm 10)))   ; turn taken out (its spins): [55 56] x z, [57 58] the facing
             (pfl (f-max 1f-5 (f-hypot pfx pfz))) (ux (/ pfx pfl)) (uz (/ pfz pfl))
             (ry (aref w 53)) (cr (f-cos ry)) (sr (f-sin ry)))
        (declare (single-float pfx pfz pfl ux uz ry cr sr))
        (setf (aref w 55) (- (aref jm 12) (* (aref w 59) ux) (* (aref w 60) (- uz)))
              (aref w 56) (- (aref jm 14) (* (aref w 59) uz) (* (aref w 60) ux))
              (aref w 57) (- (* ux cr) (* uz sr)) (aref w 58) (+ (* ux sr) (* uz cr)))))
    (dotimes (i n)
      (when (<= (floor i 2) (1- pairs))
        (let* ((r (* 10 i)) (s (aref tbl r)) (lx (+ rx (* 0.07f0 s)))
               (ox (+ (* xx lx) (* yx ry) (* zx rz) (aref jm (+ o 12))))
               (oy (+ (* xy lx) (* yy ry) (* zy rz) (aref jm (+ o 13))))
               (oz (+ (* xz lx) (* yz ry) (* zz rz) (aref jm (+ o 14))))
               (front (> (aref tbl (+ r 7)) 0.5f0)) (mo (* 9 (+ i (* 8 side))))
               (len 0f0) (wd 0f0) (px 0f0) (py 0f0) (pz 0f0) (wth 0f0) (pwx 0f0) (pwy 0f0) (pwz 0f0))
          (declare (fixnum r mo) (single-float s lx ox oy oz len wd px py pz wth pwx pwy pwz))
          ;; 1. the straight blade's frame (segment 0's) and its drive point
          (if front
              ;; a front wing, root to hand; its torn edge down and out: the normal D x U, D = the joint's -Y + 0.5 s X
              (let* ((h (if (> s 0f0) (* 16 (ji :hand-r)) (* 16 (ji :hand-l))))
                     (hx (aref jm (+ h 12))) (hy (aref jm (+ h 13))) (hz (aref jm (+ h 14)))
                     (dx (- hx ox)) (dy (- hy oy)) (dz (- hz oz))
                     (dl (f-max 0.05f0 (f-hypot dx dy dz)))
                     (ux (/ dx dl)) (uy (/ dy dl)) (uz (/ dz dl))
                     (ddx (- (* 0.5f0 s xx) yx)) (ddy (- (* 0.5f0 s xy) yy)) (ddz (- (* 0.5f0 s xz) yz))
                     (ex (* (aref v 31) (aref w (if (> s 0f0) 72 73))))   ; (Lille II's whips: on past the hand,
                     (to (if (> s 0f0) 74 77)))                            ;  *LB-STRETCH*; 0 for Lille)
                (declare (fixnum h to) (single-float hx hy hz dx dy dz dl ux uy uz ddx ddy ddz ex))
                (%lb-basis! w 0 ux uy uz (- (* ddy uz) (* ddz uy)) (- (* ddz ux) (* ddx uz)) (- (* ddx uy) (* ddy ux)))
                (setf len (+ dl ex) wd (* lk (aref tbl (+ r 2)) (+ 1f0 (* (aref w 71) ex))) px (+ hx (* ex ux)) py (+ hy (* ex uy)) pz (+ hz (* ex uz)))
                (when (> (aref w (if (> s 0f0) 81 82)) 0.5f0) (setf wd (* 0.45f0 wd)))   ; (Lille II's whip, R11: the blade
                (setf (aref w to) px (aref w (+ to 1)) py (aref w (+ to 2)) pz))          ;  thinned, the lash on from its tip)
              ;; (the sweep SB, the owl's KIN, decision 38: the fan closed up into a narrow sheaf lowered along his back,
              ;; the blades trailing back and down close to his midline (a folded bird's), shorter, their faces turned to
              ;; the side: a narrow sheaf from behind, the long swept blades from the side)
              (let* ((e (* 0.017453292f0 (+ (* (aref tbl (+ r 1)) (+ 1f0 (* 0.22f0 sp)) (- 1f0 (* 0.65f0 sb))) (* -48f0 sb)
                                              (aref w 68)                  ; (the owl's wing beat, decision 56)
                                              (* 3f0 j (f-sin (+ (* 1.9f0 tm) (aref tbl (+ r 9)))))
                                              (* rip (f-sin (+ (* 31f0 tm) (* 1.7f0 (i->f i))))))))
                     (ax (* s (f-cos e) (- 1f0 (* 0.7f0 sb)))) (ay (- (f-sin e) (* 0.9f0 sb)))
                     (az (+ (- (aref tbl (+ r 3)) (* 0.7f0 sp)) (* 1.3f0 sb)))
                     (lx2 (+ (* j ax) (* k s (aref tbl (+ r 4))))) (ly2 (+ (* j ay) (* k (aref tbl (+ r 5)))))
                     (lz2 (+ (* j az) (* k (aref tbl (+ r 6)))))
                     (fl (if (> (aref tbl (+ r 8)) 0.5f0) (- s) s)) (nlx (+ (* k fl) (* j fl 0.85f0 sb))) (nlz (* j fl (- 1f0 (* 0.85f0 sb))))
                     (dx (+ (* xx lx2) (* yx ly2) (* zx lz2))) (dy (+ (* xy lx2) (* yy ly2) (* zy lz2)))
                     (dz (+ (* xz lx2) (* yz ly2) (* zz lz2))) (dl (f-max 1f-5 (f-hypot dx dy dz)))
                     (ln (* lk (aref tbl (+ r 2)) (- 1f0 (* 0.15f0 k)) (- 1f0 (* 0.2f0 sb)))))
                (declare (single-float e ax ay az lx2 ly2 lz2 fl nlx nlz dx dy dz dl ln))
                ;; decision 50: converging in turn (C 0..1), round his hit point (KIN) or on the line ahead (EN): the blade
                ;; turned from its fan place toward its target T, stretched to reach it, its face turned to his side
                (let* ((c (if (> (aref w 47) 0.5f0) (%lb-conv-share i s mask) 0f0)) (c1 (- 1f0 c))
                       (ow (> (aref w 70) 0.5f0))                    ; (the owl's four pairs, decision 56)
                       (pr (let ((q (floor i 2))) (if (or ow (/= q 3)) q 2))) (en (> (aref w 48) 0.5f0))
                       (dist (if en (+ (the single-float *lb-conv-near*) (* (the single-float *lb-conv-gap*) (i->f pr)))
                                 (- (aref w 54) 0.1f0)))                       ; (EN: along the line; KIN: his reach)
                       (lat (if en (* s (if (and (> (aref w 49) 0.5f0) (> pr 0)) (* 0.105f0 dist) 0.08f0)) 0f0))
                       (rg (if en 0f0 (the single-float *lb-conv-ring*)))
                       (qx (* rg s (case pr (0 0.6f0) (1 1f0) (2 (if ow 1f0 0.6f0)) (t 0.6f0))))
                       (qy (* rg (case pr (0 0.8f0) (1 (if ow 0.3f0 0.1f0)) (2 (if ow -0.3f0 -0.8f0)) (t -0.8f0))))
                       (yl1 (/ 1f0 yl))
                       (tx (+ (aref w 55) (* dist (aref w 57)) (* lat (- (aref w 58))) (* qx sx) (* qy yx yl1)))
                       (ty (if en (+ (aref v 3) 0.03f0) (+ (- (aref jm (+ (* 16 (ji :chest)) 13)) 0.12f0) (* qx sy) (* qy yy yl1))))
                       (tz (+ (aref w 56) (* dist (aref w 58)) (* lat (aref w 57)) (* qx sz) (* qy yz yl1)))
                       (gx (- tx ox)) (gy (- ty oy)) (gz (- tz oz)) (gl (f-max 1f-3 (f-hypot gx gy gz)))
                       (bx (+ (* c1 (/ dx dl)) (* c (/ gx gl)))) (by (+ (* c1 (/ dy dl)) (* c (/ gy gl))))
                       (bz (+ (* c1 (/ dz dl)) (* c (/ gz gl))))
                       (bl (f-max 1f-5 (f-hypot bx by bz)))
                       (l2 (+ (* c1 ln) (* c (f-min gl (* (the single-float *lb-conv-stretch*) ln))))))
                  (declare (single-float c c1 dist lat rg qx qy yl1 tx ty tz gx gy gz gl bx by bz bl l2) (fixnum pr))
                  (cond
                    ((> (aref w 61) 0f0)
                     ;; decision 56: the ring (NIJUSHI-KO, the Kikon): the pair's place round him in the plane facing his
                     ;; opponent (from the top 22.5 / 67.5 / 157.5 degrees off his up, the front pair's 112.5 the clip's), cupped
                     ;; forward or blown back ([62]), shaking ([63]), closed down ([64]: every place swung to 178 degrees, before
                     ;; him); the face to him
                     (let* ((rg (aref w 61)) (rg1 (- 1f0 rg)) (cl (aref w 64))
                            (th0 (case pr (0 0.3926991f0) (1 1.1780972f0) (t 2.7488935f0)))
                            (th (+ th0 (* cl (- 3.1066861f0 th0)) (* (aref w 63) (f-sin (+ (* 37f0 tm) (* 2.3f0 (i->f i)))))))
                            (ca (f-cos th)) (sa (* s (f-sin th))) (cu (+ (aref w 62) (* 0.3f0 cl)))
                            (gx (+ (* ca yx yl1) (* sa sx) (* cu fx))) (gy (+ (* ca yy yl1) (* sa sy) (* cu fy)))
                            (gz (+ (* ca yz yl1) (* sa sz) (* cu fz))) (gl (f-max 1f-5 (f-hypot gx gy gz)))
                            (bx (+ (* rg1 (/ dx dl)) (* rg (/ gx gl)))) (by (+ (* rg1 (/ dy dl)) (* rg (/ gy gl))))
                            (bz (+ (* rg1 (/ dz dl)) (* rg (/ gz gl))))
                            (bl (f-max 1f-5 (f-hypot bx by bz))))
                       (declare (single-float rg rg1 cl th0 th ca sa cu gx gy gz gl bx by bz bl))
                       (%lb-basis! w 0 (/ bx bl) (/ by bl) (/ bz bl)
                                   (+ (* rg1 (+ (* xx nlx) (* zx nlz))) (* rg fx)) (+ (* rg1 (+ (* xy nlx) (* zy nlz))) (* rg fy))
                                   (+ (* rg1 (+ (* xz nlx) (* zz nlz))) (* rg fz)))))
                    ((> c 0f0)                           ; (the owl's turn their faces up, edge-on from the side: its
                     (let ((ux (if ow (* yx yl1) sx)) (uy (if ow (* yy yl1) sy)) (uz (if ow (* yz yl1) sz)))   ;  claws show)
                       (declare (single-float ux uy uz))
                       (%lb-basis! w 0 (/ bx bl) (/ by bl) (/ bz bl)
                                   (+ (* c1 (+ (* xx nlx) (* zx nlz))) (* c fl ux)) (+ (* c1 (+ (* xy nlx) (* zy nlz))) (* c fl uy))
                                   (+ (* c1 (+ (* xz nlx) (* zz nlz))) (* c fl uz)))))
                    (t (%lb-basis! w 0 (/ dx dl) (/ dy dl) (/ dz dl)
                                   (+ (* xx nlx) (* zx nlz)) (+ (* xy nlx) (* zy nlz)) (+ (* xz nlx) (* zz nlz)))))
                  (let ((lq (cond ((> (aref w 61) 0f0) (* ln (+ 1f0 (* 0.08f0 (aref w 61))))) ((> c 0f0) l2) (t ln))))
                    (declare (single-float lq))
                    (setf len lq wd ln px (+ ox (* lq (aref w 3))) py (+ oy (* lq (aref w 4))) pz (+ oz (* lq (aref w 5))))))))
          ;; 1b. Lille II's wing wall ([91] > 0, his guard): the blade turned toward its place in the wall (*LB-WALL-JL* /
          ;; *-OWL*, in the chest's frame; a front wing's is the rig's hand), its face square to his side (so the joints' curl,
          ;; 3., bows it round his side), the spring's drive point that place; 4. pins its chain there
          (when (> wal 0f0)
            (let ((wq (* 4 i)) (wa1 (- 1f0 wal)) (ms (- s)))
              (declare (fixnum wq) (single-float wa1 ms))
              (setf wth (aref wt (+ wq 3)))
              (if front
                  (setf pwx px pwy py pwz pz)
                  (let ((cr (* s (aref wt wq))) (cu (aref wt (+ wq 1))) (cf (aref wt (+ wq 2))))
                    (declare (single-float cr cu cf))
                    (setf pwx (- (+ (aref jm (+ o 12)) (* cr xx) (* cu yx)) (* cf zx))
                          pwy (- (+ (aref jm (+ o 13)) (* cr xy) (* cu yy)) (* cf zy))
                          pwz (- (+ (aref jm (+ o 14)) (* cr xz) (* cu yz)) (* cf zz)))))
              (let* ((cx (- pwx ox)) (cy (- pwy oy)) (cz (- pwz oz)) (cl (f-max 1f-4 (f-hypot cx cy cz)))
                     (ux (+ (* wa1 (aref w 3)) (* wal (/ cx cl)))) (uy (+ (* wa1 (aref w 4)) (* wal (/ cy cl))))
                     (uz (+ (* wa1 (aref w 5)) (* wal (/ cz cl)))) (ul (f-max 1f-5 (f-hypot ux uy uz)))
                     (nx (+ (* wa1 (aref w 6)) (* wal ms sx))) (ny (+ (* wa1 (aref w 7)) (* wal ms sy)))
                     (nz (+ (* wa1 (aref w 8)) (* wal ms sz))))
                (declare (single-float cx cy cz cl ux uy uz ul nx ny nz))
                (%lb-basis! w 0 (/ ux ul) (/ uy ul) (/ uz ul) nx ny nz)
                (unless front
                  (setf px (+ (* wa1 px) (* wal pwx)) py (+ (* wa1 py) (* wal pwy)) pz (+ (* wa1 pz) (* wal pwz)))))))
          ;; 2. the lag spring: its target from the drive point's speed and the strike's virtual speed (a free wing's tip
          ;; trails: bend against the motion; a pinned front wing bends with it, so its middle bows behind)
          (when (> dt 0f0)
            (let* ((qx (- px (aref mm mo))) (qy (- py (aref mm (+ mo 1)))) (qz (- pz (aref mm (+ mo 2))))
                   (iv (if (> (+ (* qx qx) (* qy qy) (* qz qz)) (aref w 45)) 0f0 (/ 1f0 dt)))   ; (a jump: a cut, a reset)
                   (sw (if front (if (/= 0 (logand mask (if (> s 0f0) 1 2))) 1f0 0.3f0) tsc))
                   (sg (if front gl (- gl)))
                   (tx (* sg (+ (* qx iv) (* vb sw dvx)))) (ty (* sg (+ (* qy iv) (* vb sw dvy)))) (tz (* sg (+ (* qz iv) (* vb sw dvz))))
                   (tl (f-hypot tx ty tz)) (tc (if (> tl lm) (/ lm tl) 1f0))
                   (om 16f0) (o2 (* om om)) (dmp (* 2f0 0.45f0 om)))
              (declare (single-float qx qy qz iv sw sg tx ty tz tl tc om o2 dmp))
              (setf (aref mm mo) px (aref mm (+ mo 1)) py (aref mm (+ mo 2)) pz)
              (if act                                    ; the active frames: snapped straight
                  (dotimes (q 6) (setf (aref mm (+ mo 3 q)) 0f0))
                  (macrolet ((spring (q tq)
                               `(let ((%b (aref mm (+ mo 3 ,q))) (%r (aref mm (+ mo 6 ,q))))
                                  (declare (single-float %b %r))
                                  (setf %r (+ %r (* dt (- (* o2 (- (* tc ,tq) %b)) (* dmp %r))))
                                        (aref mm (+ mo 6 ,q)) %r (aref mm (+ mo 3 ,q)) (+ %b (* dt %r))))))
                    (spring 0 tx) (spring 1 ty) (spring 2 tz)))))
          ;; 3. the joints: the spring's bend (the tip's joint 1.4 x), MUJITTAI's curl toward the column, the spread's furl,
          ;; and the wave (in the blade's frame, the tip's joint lagging)
          (let* ((bx (aref mm (+ mo 3))) (by (aref mm (+ mo 4))) (bz (aref mm (+ mo 5)))
                 (ff (if front 0.5f0 1f0)) (kc (* k fc ff (- s))) (u1 (* c1 fu ff)) (u2 (* c2 fu ff))
                 (b1x (+ bx (* kc sx) (* u1 fx))) (b1y (+ by (* kc sy) (* u1 fy))) (b1z (+ bz (* kc sz) (* u1 fz)))
                 (b2x (+ (* 1.4f0 bx) (* 1.2f0 kc sx) (* u2 fx))) (b2y (+ (* 1.4f0 by) (* 1.2f0 kc sy) (* u2 fy)))
                 (b2z (+ (* 1.4f0 bz) (* 1.2f0 kc sz) (* u2 fz)))
                 (wv (* (if act (if front 0f0 0.3f0) 1f0) (if front 0.6f0 1f0) (- 1f0 (* 0.6f0 k)) (- 1f0 (* 0.8f0 wal))))
                 (ph (+ (* ws tm) (aref tbl (+ r 9)) (if front (* 1.7f0 s) 0f0))))
            (declare (single-float bx by bz ff kc u1 u2 b1x b1y b1z b2x b2y b2z wv ph))
            (setf (aref w 30) (+ (* b1x (aref w 0)) (* b1y (aref w 1)) (* b1z (aref w 2)) (* wv wa (f-sin ph)))
                  (aref w 31) (+ (* b1x (aref w 6)) (* b1y (aref w 7)) (* b1z (aref w 8)) (* wv wc (f-sin (+ ph 0.8f0)))
                                 (* wal wth)))   ; (the wing wall's curl round the column)
            (%lb-tilt! 0 9)
            (setf (aref w 30) (+ (* b2x (aref w 9)) (* b2y (aref w 10)) (* b2z (aref w 11)) (* wv wa (f-sin (- ph wl))))
                  (aref w 31) (+ (* b2x (aref w 15)) (* b2y (aref w 16)) (* b2z (aref w 17)) (* wv wc (f-sin (- (+ ph 0.8f0) wl)))
                                 (* wal wth)))
            (%lb-tilt! 9 18))
          ;; 4. a front wing: turn the chain about its root so its end is on the hand, and stretch it to reach it (in the
          ;; wing wall every wing: on its place, by its share PIN)
          (when (or front (> wal 0f0))
            (let* ((pin (if front 1f0 wal))
                   (dl (if front len (f-max 1f-4 (f-hypot (- pwx ox) (- pwy oy) (- pwz oz)))))
                   (qx (if front px pwx)) (qy (if front py pwy)) (qz (if front pz pwz))
                   (tx (* 0.33333334f0 (+ (aref w 3) (aref w 12) (aref w 21))))
                   (ty (* 0.33333334f0 (+ (aref w 4) (aref w 13) (aref w 22))))
                   (tz (* 0.33333334f0 (+ (aref w 5) (aref w 14) (aref w 23))))
                   (tl (f-max 1f-4 (f-hypot tx ty tz)))
                   (ex (/ tx tl)) (ey (/ ty tl)) (ez (/ tz tl))
                   (hx (/ (- qx ox) dl)) (hy (/ (- qy oy) dl)) (hz (/ (- qz oz) dl))
                   (kx (- (* ey hz) (* ez hy))) (ky (- (* ez hx) (* ex hz))) (kz (- (* ex hy) (* ey hx)))
                   (kl (f-hypot kx ky kz)) (cs (+ (* ex hx) (* ey hy) (* ez hz))))
              (declare (single-float pin dl qx qy qz tx ty tz tl ex ey ez hx hy hz kx ky kz kl cs))
              (when (> kl 1f-6)
                (setf (aref w 32) (/ kx kl) (aref w 33) (/ ky kl) (aref w 34) (/ kz kl) (aref w 35) (* pin (f-atan2 kl cs)))
                (%lb-turn-chain!))
              (setf len (if front (/ len tl) (+ (* (- 1f0 pin) len) (* pin (/ dl tl)))))))
          ;; 5. the three segments, each from the last one's end; a wing in [65]'s bits drawn with its holes lit (decision
          ;; 56: SANREN's firing wing, NIJUSHI-KO's and the Kikon's charge) and, while [66] > 0, the muzzle flash at its holes
          ;; (Lille II, LD > 0: the first LD - 1 blades loaded, the rest spent, a volley beat's lit blade as it is)
          (let* ((qx ox) (qy oy) (qz oz) (l3 (* len 0.33333334f0))
                 (lw (and (= kind 0) (logbitp i (f->i (aref w 65))))) (kd (if lw 1 kind)) (mf (if lw (aref w 66) 0f0))
                 (ldw (and (> ld 0) (not lw) (< i (1- ld)))) (spw (and (> ld 0) (not lw) (>= i (1- ld)))))
            (declare (single-float qx qy qz l3 mf) (fixnum kd))
            (dotimes (g 3)
              (let ((b (* 9 g)))
                (declare (fixnum b))
                (%lb-seg-m! *lb-m* w b qx qy qz len wd)
                (cond (spw (%lb-wing-draw kd g gs rs *lb-spent-glow*))
                      (ldw (%lb-wing-draw kd g ga rl))
                      (t (%lb-wing-draw kd g ga ra)))
                (let* ((ly (* len (case g (0 0.2f0) (1 0.16666667f0) (t 0.12333333f0))))   ; the hole on this segment
                       (lx (* wd (case g (0 0.055f0) (1 0.08f0) (t 0.056f0))))            ;  (*LB-WING-HOLES*: 0.2 / 0.5 /
                       (hx (+ qx (* ly (aref w (+ b 3))) (* lx (aref w b))))              ;  0.79 of the blade, its centre
                       (hy (+ qy (* ly (aref w (+ b 4))) (* lx (aref w (+ b 1)))))        ;  off the chord), kept for the
                       (hz (+ qz (* ly (aref w (+ b 5))) (* lx (aref w (+ b 2)))))        ;  Kikon cinematic's lines
                       (hi (+ (* 3 i) g)) (ho (* 3 (+ (* 24 side) hi))) (sd (i->f (+ 90 hi))))
                  (declare (single-float ly lx hx hy hz sd) (fixnum hi ho))
                  (when (< i 8) (setf (aref *lb-holes* ho) hx (aref *lb-holes* (+ ho 1)) hy (aref *lb-holes* (+ ho 2)) hz))
                  (when (< hi (f->i (aref w 67)))           ; lit one by one (the Kikon cinematic's card)
                    (fx-disc hx hy hz (* 0.06f0 (aref v 31)) 0.04f0 (+ 60f0 sd) +pal-jade+ 0.95f0 :push 0.15f0)
                    (fx-disc hx hy hz (* 0.028f0 (aref v 31)) 0.03f0 (+ 160f0 sd) +pal-hit+ 0.95f0 :push 0.18f0))
                  (when (> mf 0f0)                          ; the muzzle flash
                    (fx-star hx hy hz (* 0.06f0 mf (aref v 31)) (* 0.22f0 mf (aref v 31)) 6 (* 0.7f0 sd) 0f0 0f0 0.1f0 sd
                             +pal-jade+ mf :push 0.2f0)
                    (fx-star hx hy hz (* 0.03f0 mf (aref v 31)) (* 0.1f0 mf (aref v 31)) 4 (* 1.3f0 sd) 0f0 0f0 0.05f0
                             (+ 40f0 sd) +pal-hit+ mf :push 0.25f0))
                  (when ldw                                 ; (Lille II's loaded blade: its holes glowing, pulsing)
                    (let ((hr (* (the single-float *lb-load-hole*) (aref v 31)
                                 (+ 1f0 (* 0.15f0 (f-sin (+ (* 3.1f0 tm) (* 0.9f0 (i->f hi)))))))))
                      (declare (single-float hr))
                      (fx-disc hx hy hz hr 0.04f0 (+ 260f0 sd) (if (= kind 2) +pal-gold+ +pal-jade+) 0.85f0 :push 0.15f0)
                      (fx-disc hx hy hz (* 0.4f0 hr) 0.03f0 (+ 360f0 sd) +pal-hit+ 0.9f0 :push 0.18f0))))
                (setf qx (+ qx (* l3 (aref w (+ b 3)))) qy (+ qy (* l3 (aref w (+ b 4)))) qz (+ qz (* l3 (aref w (+ b 5)))))))))))
    nil))

(defmacro %lb-owl-beat! (be bo clip sf s a r enter)
  "Decision 56, 金翼振翅: set BE (the eight gold wings' elevation offset, degrees) and BO (KIN's swept sheaf opened, 0..1)
at frame SF of an owl strike playing CLIP (S A R, entered at ENTER): raised over the wind-up from the entry, struck down
over the startup's last *LB-OWL-BEAT-STROKE* frames (a K's + 1; at most half the startup) into S, held down through the
active frames, back over the recovery; K3 (the stoop) raised and pressed *LB-OWL-BEAT-K3* x as far, held flared into the
landing. Single-float forms; 0 B."
  `(let* ((%c ,clip) (%k3 (member %c '(:lb-o-f3 :lb-oe-f3))) (%kk (if %k3 (the single-float *lb-owl-beat-k3*) 1f0))
          (%up (* %kk (the single-float *lb-owl-beat-up*))) (%dn (* %kk (the single-float *lb-owl-beat-down*)))
          (%sf ,sf) (%s ,s) (%a ,a) (%r ,r) (%e ,enter)
          (%d (min (+ (the fixnum *lb-owl-beat-stroke*) (if (member %c '(:lb-o-f1 :lb-o-f2 :lb-o-f3 :lb-oe-f1 :lb-oe-f2 :lb-oe-f3)) 1 0))
                   (max 1 (floor (- %s %e) 2))))
          (%w0 (- %s %d)))
     (declare (single-float %kk %up %dn) (fixnum %sf %s %a %r %e %d %w0))
     (cond ((< %sf %w0) (let ((%u (%lb-ss (/ (i->f (- (1+ %sf) %e)) (i->f (max 1 (- %w0 %e)))))))
                          (declare (single-float %u))
                          (setf ,be (* %up %u) ,bo %u)))
           ((< %sf %s) (let ((%u (%lb-ss (/ (i->f (- (1+ %sf) %w0)) (i->f %d)))))
                         (declare (single-float %u))
                         (setf ,be (- %up (* (+ %up %dn) %u)) ,bo 1f0)))
           ((< %sf (+ %s %a)) (setf ,be (- %dn) ,bo 1f0))
           (t (let* ((%u (/ (i->f (- %sf %s %a)) (i->f (max 1 %r))))
                     (%k (- 1f0 (%lb-ss (if %k3 (/ (- %u 0.25f0) 0.6f0) (/ %u 0.6f0))))))
                (declare (single-float %u %k))
                (setf ,be (* (- %dn) %k) ,bo %k))))
     (setf ,bo (* ,bo (the single-float *lb-owl-beat-open*)))))

(defmacro %lb-drive! (f mv rdt owl)
  "Set *LB-WF* [39..52], the jointed wings' drive for F's draw (MV his move or nil, RDT the step, OWL the owl's wings): in a
strike (a move's main phase with active frames, not an SP or Kikon) the wind-up's virtual speed rising to *LB-STRIKE-IN*,
the active frames' straight flag, the recovery's virtual speed back (*LB-STRIKE-OUT*, easing out); which front wings strike
(J1 / K1's clip the right, J2 / K2's the left, the rest both); the other wings' share (Jilliel's 0.35, the owl's 0.7); the lag
spring's jump (the owl's 1 m^2, Jilliel's *LB-JUMP-JL*); in a Jilliel strike (*LB-JILLIEL-STRIKES*, decision 50) the
convergence's clock and kind and the trails' window; in an owl strike (*LB-OWL-STRIKES*, decision 56) the same, its
eight wings converging, and its wing beat (%LB-OWL-BEAT!). Reads the move's frame only for the look. 0 B."
  `(let ((%w *lb-wf*) (%f ,f) (%mv ,mv) (%vb 0f0) (%act 0f0) (%mask 3) (%cv 0f0) (%tr 0f0) (%be 0f0) (%bo 0f0) (%ow 0f0))
     (declare (type f32vec %w) (single-float %vb %act %cv %tr %be %bo %ow) (fixnum %mask))
     (when (and %mv (eq (fighter-phase %f) :main) (> (the fixnum (mv-a %mv)) 0) (not (member (mv-kind %mv) '(:sp :kikon))))
       (let ((%sf (fighter-sf %f)) (%s (mv-s %mv)) (%a (mv-a %mv)) (%r (mv-r %mv)))
         (declare (fixnum %sf %s %a %r))
         (cond ((< %sf %s) (setf %vb (* (the single-float *lb-strike-in*) (%lb-ss (/ (i->f (1+ %sf)) (i->f (max 1 %s)))))))
               ((< %sf (+ %s %a)) (setf %act 1f0))
               (t (let ((%u (f-min 1f0 (/ (i->f (- %sf %s %a)) (i->f (max 1 %r))))))
                    (declare (single-float %u))
                    (setf %vb (- (* (the single-float *lb-strike-out*) (- 1f0 %u) (- 1f0 %u)))))))
         (setf %mask (case (mv-clip %mv) ((:lb-w-q1 :lb-w-f1 :lb-e-q1 :lb-e-f1 :lb-o-q1 :lb-o-f1 :lb-oe-q1 :lb-oe-f1) 1)
                           ((:lb-w-q2 :lb-w-f2 :lb-e-q2 :lb-e-f2 :lb-o-q2 :lb-o-f2 :lb-oe-q2 :lb-oe-f2) 2) (t 3)))
         (when (if ,owl (member (mv-clip %mv) *lb-owl-strikes*) (member (mv-clip %mv) *lb-jilliel-strikes*))   ; decisions 50, 56
           (setf %cv (if (member (mv-clip %mv) *lb-no-conv*) 0f0 1f0)   ; (Lille II's spins: no convergence)
                 %tr (if (and (<= (+ %s (if ,owl (the fixnum *lb-owl-trail-from*) (the fixnum *lb-trail-from*))) %sf
                                  (+ %s %a (the fixnum *lb-trail-to*) -1))
                              (let ((%cut (assoc (mv-clip %mv) *lb-trail-cut*)))   ; (Lille II's cannon: no streak at him)
                                (or (null %cut) (< %sf (the fixnum (cdr %cut))))))
                         1f0 0f0)
                 (aref %w 46) (i->f (- %sf %s))
                 (aref %w 48) (if (member (mv-clip %mv) '(:lb-e-q1 :lb-e-q2 :lb-e-q3 :lb-e-f1 :lb-e-f2 :lb-e-f3 :lb-oe-q1 :lb-oe-q2
                                                          :lb-oe-q3 :lb-oe-f1 :lb-oe-f2 :lb-oe-f3))
                                  1f0 0f0)
                 (aref %w 49) (if (eq (mv-kind %mv) :flash) 1f0 0f0) (aref %w 50) (i->f %a) (aref %w 51) (i->f %r)
                 (aref %w 54) (let ((%rc (mv-reach %mv))) (if (typep %rc 'single-float) %rc 2f0)))
           (when ,owl                                    ; the owl's: all eight converge, after the wing beat
             (setf %ow 1f0)
             (%lb-owl-beat! %be %bo (mv-clip %mv) %sf %s %a %r (the fixnum (mv-enter %mv)))))))
     (setf (aref %w 39) %vb (aref %w 40) (i->f %mask) (aref %w 41) %act
           (aref %w 43) (f-min ,rdt 0.034f0) (aref %w 44) (if ,owl 0.7f0 0.35f0)
           (aref %w 45) (if ,owl 1f0 (the single-float *lb-jump-jl*)) (aref %w 47) %cv (aref %w 52) %tr
           (aref %w 68) %be (aref %w 69) %bo (aref %w 70) %ow)))

;; Decision 56 (2026-10-08, DUEL_LILLE §23.37): the SPs' and the Kikon's looks on the wings (the clips move the column and
;; the front pair; these the rest). SANREN: each shot kicks the firing wing (a virtual speed back: the joints whip forward)
;; and flashes its holes. NIJUSHI-KO and the Kikon: the six table wings swing into a ring round him facing his opponent
;; (the front pair's places the clip's), lit through the charge, which shakes harder; the shot blows them back (cupped back,
;; the joints bent by a burst of virtual speed), the muzzles flash; the Kikon's then close down before him (the verdict).
(defparameter *lb-sp-whip* 16.0 "SANREN: each shot's kick, a virtual speed back (m/s, easing out over *LB-SP-KICK* frames) ...")
(defparameter *lb-sp-kick* 8 "... frames (the firing wing's holes flash for 6).")
(defparameter *lb-ring-blow* 30.0 "NIJUSHI-KO / the Kikon: the shot's virtual speed (m/s, easing out over 10 f) that blows the wings back.")
(defparameter *lb-ring-shake* 0.07 "... and the charge's shake at its height (radians on each table wing's place in the ring, at 37 rad/s).")
(declaim (type f32vec *lb-sp-ext*))
(defvar *lb-sp-ext* (make-f32 8)
  "Another kit's SP looks on these wings (Lille II's recall strings, barro-art.lisp BR-RC-DRIVE; added 2026-10-09, Lille's
own moves never read it): the ring, its cup, the shake, the virtual speed, the flash, the lit bits, the striking wings'
mask, the other wings' share, for %LB-SP-DRIVE! to take.")
(defmacro %lb-sp-drive! (f mv owl ck)
  "Decision 56: Jilliel's SP / Kikon looks for F's draw (MV his move or nil; nothing for the owl, OWL): *LB-WF* [61] the ring
0..1, [62] its cup (+ forward, - blown back), [63] the shake, [64] the close, [65] the wings lit (bits by row: 16 the right
front wing, 32 the left, 255 all), [66] their muzzle flash; at a shot also the strike drive [39 40 44] (the kick). The
timing: SANREN's shots S + 10 i (KIN) / 6 i (EN); NIJUSHI-KO's charge 0..1 over its startup (EN's 20 f, KIN's 40), the
frames after S in its clip's (x 40 / S); the Kikon's charge over its aura (8) and startup (20), then its own frames. Reads
the move's frame only (cosmetic). 0 B."
  `(let ((%w *lb-wf*) (%f ,f) (%mv ,mv) (%rg 0f0) (%cup 0f0) (%sh 0f0) (%cl 0f0) (%lit 0) (%fl 0f0) (%vb 0f0) (%mask -1)
         (%ts 0.6f0))
     (declare (type f32vec %w) (single-float %rg %cup %sh %cl %fl %vb %ts) (fixnum %lit %mask))
     (when ,ck                                            ; the Kikon cinematic (decision 56's storyboard, Amendment 2):
       (let* ((%c ,ck) (%sv *lb-judge-shots*) (%last -1))   ; the ring snapped open on f24 (gathered and shaking before:
         (declare (fixnum %c %last) (type (simple-array fixnum (*)) %sv))   ; LILLE-DRAW), its holes lit one by one through
         (dotimes (%n 48) (when (<= (aref %sv %n) %c) (setf %last %n)))     ; the card (f42-88), the charge shaking, each
         (let* ((%age (if (>= %last 0) (- (%lb-judge-t %c) (%lb-judge-t (aref %sv %last))) 99f0))   ; shot kicking it back
                (%k (if (< %age 6f0) (- 1f0 (/ %age 6f0)) 0f0))           ; (on the effect time: slowed on the first hits),
                (%n (if (< %c 268) (min 24 (max 0 (floor (- %c 40) 2))) 0)))   ; the verdict closing it (f262-268),
           (declare (single-float %age %k) (fixnum %n))                        ; settling after 277
           (setf %rg (* (%lb-ss (/ (- (i->f %c) 24f0) 3f0)) (- 1f0 (%lb-ss (/ (- (i->f %c) 277f0) 18f0))))
                 %cl (%lb-ss (/ (- (i->f %c) 262f0) 6f0))
                 %cup (- 0.3f0 (* 1.0f0 %k %k))
                 %sh (cond ((< %c 90) (* (the single-float *lb-ring-shake*) (%lb-ss (/ (- (i->f %c) 60f0) 30f0))))
                           ((< 192 %c 242) 0.03f0) (t 0f0))
                 %vb (* 0.6f0 (the single-float *lb-ring-blow*) %k %k) %mask 3 %ts 0.8f0
                 %fl (if (< %age 3f0) (- 1f0 (/ %age 3f0)) 0f0)
                 (aref %w 67) (i->f %n))
           (dotimes (%i 8) (when (>= %n (+ 3 (* 3 %i))) (setf %lit (logior %lit (ash 1 %i)))))
           (when (and (> %fl 0f0) (< %c 268))               ; the firing wing's muzzles flash
             (setf %lit (logior %lit (ash 1 (floor (%lb-judge-hole %last) 3))))))))
     (unless ,ck (setf (aref %w 67) 0f0))
     (when (and %mv (not ,owl))
       (let ((%nm (mv-name %mv)) (%ph (fighter-phase %f)) (%sf (fighter-sf %f)) (%s (mv-s %mv)))
         (declare (fixnum %sf %s))
         (case %nm
           ((:lb-sanren :lb-e-sanren :br-w-sanren :br-e-sanren)   ; (+ Lille II's, the same frames: DUEL_LILLE_V2 §12)
            (when (and (eq %ph :main) (>= %sf %s))
              (let* ((%st (if (member %nm '(:lb-sanren :br-w-sanren)) 10 6)) (%n (min 2 (floor (- %sf %s) %st))) (%age (- %sf %s (* %n %st))))
                (declare (fixnum %st %n %age))
                (when (< %age (the fixnum *lb-sp-kick*))
                  (let ((%u (- 1f0 (/ (i->f %age) (i->f (the fixnum *lb-sp-kick*))))))
                    (declare (single-float %u))
                    (setf %mask (case %n (0 1) (1 2) (t 3)) %vb (- (* (the single-float *lb-sp-whip*) %u %u))
                          %lit (case %n (0 16) (1 32) (t 48)) %fl (f-max 0f0 (- 1f0 (/ (i->f %age) 6f0)))))))))
           ((:lb-nijushi :lb-e-nijushi :lb-w-kikon :br-w-nijushi :br-e-nijushi :br-w-kikon)   ; (+ Lille II's)
            (let* ((%kk (member %nm '(:lb-w-kikon :br-w-kikon)))
                   (%pre (cond ((eq %ph :aura) (/ (i->f (the fixnum (fighter-hold %f))) 28f0))   ; (the charge 0..1)
                               ((not (eq %ph :main)) 0.99f0)                                   ; (the Kikon's follow dash)
                               (%kk (f-min 1f0 (/ (+ 8f0 (i->f %sf)) 28f0)))
                               (t (f-min 1f0 (/ (i->f %sf) (i->f (max 1 %s)))))))
                   (%post (if (and (eq %ph :main) (>= %sf %s))                                ; (frames after the shot)
                              (if %kk (i->f (- %sf %s)) (/ (* 40f0 (i->f (- %sf %s))) (i->f (max 1 %s))))
                              -1f0)))
              (declare (single-float %pre %post))
              (setf %mask 3 %ts 0.8f0)
              (if (< %post 0f0)
                  (setf %rg (%lb-ss (/ %pre 0.35f0))
                        %cup (- 0.35f0 (* 0.25f0 (%lb-ss (/ (- %pre 0.4f0) 0.6f0))))
                        %sh (* (the single-float *lb-ring-shake*) (%lb-ss (/ (- %pre 0.3f0) 0.7f0)) (+ 0.3f0 (* 0.7f0 %pre)))
                        %vb (* 0.5f0 (the single-float *lb-strike-in*) (%lb-ss (/ (- %pre 0.5f0) 0.5f0)))
                        %lit 255)
                  (let ((%b (f-max 0f0 (- 1f0 (/ %post 10f0)))))
                    (declare (single-float %b))
                    (setf %rg (- 1f0 (%lb-ss (if %kk (/ (- %post 20f0) 12f0) (/ (- %post 18f0) 16f0))))
                          %cup (* -0.85f0 (%lb-ss (/ %post 2.5f0)) (- 1f0 (%lb-ss (if %kk (/ (- %post 4f0) 6f0) (/ (- %post 8f0) 18f0)))))
                          %cl (if %kk (%lb-ss (/ (- %post 4f0) 8f0)) 0f0)
                          %vb (* (the single-float *lb-ring-blow*) %b %b)
                          %lit (if (< %post 6f0) 255 0) %fl (f-max 0f0 (- 1f0 (/ %post 6f0))))))))
           ((:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)    ; Lille II's recall strings (barro-art.lisp BR-RC-DRIVE)
            (when (br-rc-drive %f %mv)
              (let ((%x *lb-sp-ext*))
                (setf %rg (aref %x 0) %cup (aref %x 1) %sh (aref %x 2) %vb (aref %x 3) %fl (aref %x 4)
                      %lit (f->i (aref %x 5)) %mask (f->i (aref %x 6)) %ts (aref %x 7))))))))
     (setf (aref %w 61) %rg (aref %w 62) %cup (aref %w 63) %sh (aref %w 64) %cl (aref %w 65) (i->f %lit) (aref %w 66) %fl)
     (when (>= %mask 0) (setf (aref %w 39) %vb (aref %w 40) (i->f %mask) (aref %w 44) %ts))))

;; 翼尖斬痕 the wing-tip slash trails (decision 50): per side and front wing a sword trail (the engine's +TRAIL-N+ samples:
;; the elbow -> the hand, i.e. the wing's outer stretch) recorded through the strike's window (*LB-WF* [52]) while the tip
;; moves, faded a sample a frame after (%TRAIL-DROP); drawn as the duel's smear (vfx.lisp's VFX-SMEAR: a comet crescent through the 0.7
;; points of the last samples, re-captured on the fx clock's drawings) in jade.
(defparameter *lb-smear-at* 0.85 "The jade smear runs through this point of each sample's elbow -> hand (the wing's tip end) ...")
(defparameter *lb-smear-w* 0.14 "... its half-width this share of the newest sample's elbow -> hand length ...")
(defparameter *lb-smear-k* 0.7 "... and its presence (toon alpha).")
(defvar *lb-trails* (let ((v (make-array 4))) (dotimes (i 4 v) (setf (svref v i) (make-trail))))
  "The tip trails: side x 2 + wing (0 the right front wing, 1 the left).")
(defvar *lb-smears* (let ((v (make-array 4))) (dotimes (i 4 v) (setf (svref v i) (make-f32 12))))
  "Their smears' state (VFX-SMEAR's SM: x0 y0 z0 x1 y1 z1 bx by bz, half-width, drawing, presence).")
(defun-fast %lb-smear (tr sm)
  "VFX-SMEAR's comet (vfx.lisp) in jade, through *LB-SMEAR-AT*, *LB-SMEAR-W* wide: captured from trail TR into SM on each new drawing. 0 B."
  (declare (type f32vec tr sm))
  (let* ((n (f->i (trail-count tr))) (dr (drawing-no)))
    (declare (fixnum n) (single-float dr))
    (fx-smear-capture! tr sm n dr (the single-float *lb-smear-at*) (len (* (the single-float *lb-smear-w*) len))
                       (* (the single-float *lb-smear-k*) (if (>= n 5) 1f0 0.65f0)))
    (when (> (aref sm 11) 0f0)
      (fx-crescent (aref sm 0) (aref sm 1) (aref sm 2) (aref sm 3) (aref sm 4) (aref sm 5) (aref sm 6) (aref sm 7) (aref sm 8)
                   (aref sm 9) :comet 0.06f0 (+ 17f0 dr) +pal-jade+ (aref sm 11) :push 0.15f0))
    nil))
(defun-fast %lb-trails (jm side)
  "SIDE's two tip trails from JM (decision 50): each striking front wing ([40]'s bits) records its elbow -> hand while the
strike's window is open ([52]) and the tip moved (a hitstop holds the arc), else fades; then its smear. 0 B."
  (declare (type f32vec jm) (fixnum side))
  (let ((w *lb-wf*))
    (declare (type f32vec w))
    (dotimes (g 2)
      (let* ((tr (svref *lb-trails* (+ (* 2 side) g))) (n (f->i (trail-count tr)))
             (h (if (= g 0) (* 16 (ji :hand-r)) (* 16 (ji :hand-l)))) (b (if (= g 0) (* 16 (ji :lower-arm-r)) (* 16 (ji :lower-arm-l))))
             (st (> (aref w (+ 72 g)) 0f0)) (to (+ 74 (* 3 g)))   ; (Lille II's whips: the hand -> the stretched tip)
             (hx (if st (aref w to) (aref jm (+ h 12)))) (hy (if st (aref w (+ to 1)) (aref jm (+ h 13))))
             (hz (if st (aref w (+ to 2)) (aref jm (+ h 14))))
             (bx (aref jm (+ (if st h b) 12))) (by (aref jm (+ (if st h b) 13))) (bz (aref jm (+ (if st h b) 14))))
        (declare (type f32vec tr) (fixnum n h b to) (single-float hx hy hz bx by bz))
        (if (and (> (aref w 52) 0.5f0) (/= 0 (logand (f->i (aref w 40)) (if (= g 0) 1 2))))
            (let* ((o (* 6 (max 0 (1- n)))) (qx (- hx (aref tr (+ o 3)))) (qy (- hy (aref tr (+ o 4)))) (qz (- hz (aref tr (+ o 5)))))
              (declare (fixnum o) (single-float qx qy qz))
              (when (or (= n 0) (> (+ (* qx qx) (* qy qy) (* qz qz)) 1f-4))
                (%trail-push tr bx by bz hx hy hz)))
            (when (> n 0) (%trail-drop tr n)))
        (%lb-smear tr (svref *lb-smears* (+ (* 2 side) g))))))
  nil)

;; 金色爪痕 the owl's claw trails (decision 56): per side and claw a trail of its talons, the sample's ends the claw's tip (the
;; hand's -Y, *LB-CLAW-TIP* out) moved -/+ *LB-CLAW-SPREAD* along the forearm, so the swing leaves three concentric streaks,
;; recorded through the strike's window (*LB-WF* [52], Jilliel's) while it moves and faded a sample a frame after; drawn as
;; three thin gold comets (VFX-SMEAR's crescent, each through its own talon's point of the samples), not one crescent.
(defparameter *lb-claw-tip* 0.2 "The claw trail's middle streak: this far down the hand (m; the talons end about there) ...")
(defparameter *lb-claw-spread* 0.13 "... the outer two this far either side of it along the forearm (m) ...")
(defparameter *lb-claw-w* 0.08 "... each streak's half-width (m) ...")
(defparameter *lb-claw-k* 0.95 "... and its presence (toon alpha).")
(defvar *lb-claw-trails* (let ((v (make-array 4))) (dotimes (i 4 v) (setf (svref v i) (make-trail))))
  "The owl's claw trails: side x 2 + claw (0 the right, 1 the left).")
(defvar *lb-claw-smears* (let ((v (make-array 12))) (dotimes (i 12 v) (setf (svref v i) (make-f32 12))))
  "Their streaks' state: side x 6 + claw x 3 + streak (VFX-SMEAR's SM, as *LB-SMEARS*).")
(defun-fast %lb-claw-smears (tr side g)
  "Claw trail TR's (SIDE, claw G) three gold streaks: each a comet through its talon's point (0, 1/2, 1 across the
samples) of the last samples, *LB-CLAW-W* wide, re-captured on each new drawing. 0 B."
  (declare (type f32vec tr) (fixnum side g))
  (let* ((n (f->i (trail-count tr))) (dr (drawing-no)))
    (declare (fixnum n) (single-float dr))
    (dotimes (k 3)
      (let ((sm (svref *lb-claw-smears* (+ (* 6 side) (* 3 g) k))) (u (* 0.5f0 (i->f k))))
        (declare (type f32vec sm) (single-float u))
        (fx-smear-capture! tr sm n dr u (len (the single-float *lb-claw-w*))
                           (* (the single-float *lb-claw-k*) (if (>= n 5) 1f0 0.65f0)))
        (when (> (aref sm 11) 0f0)
          (fx-crescent (aref sm 0) (aref sm 1) (aref sm 2) (aref sm 3) (aref sm 4) (aref sm 5) (aref sm 6) (aref sm 7) (aref sm 8)
                       (aref sm 9) :comet 0.04f0 (+ 23f0 (* 3f0 (i->f k)) dr) +pal-gold+ (aref sm 11) :push 0.45f0)))))
  nil)
(defun-fast %lb-claw-trails (jm side)
  "SIDE's two claw trails from JM (decision 56): each striking claw ([40]'s bits: J1 / K1 the right, J2 / K2 the left, J3 /
K3 both) records its talons' span while the strike's window is open ([52]) and it moved, else fades; then its streaks. 0 B."
  (declare (type f32vec jm) (fixnum side))
  (let ((w *lb-wf*) (ct (the single-float *lb-claw-tip*)) (cs (the single-float *lb-claw-spread*)))
    (declare (type f32vec w) (single-float ct cs))
    (dotimes (g 2)
      (let* ((tr (svref *lb-claw-trails* (+ (* 2 side) g))) (n (f->i (trail-count tr)))
             (h (if (= g 0) (* 16 (ji :hand-r)) (* 16 (ji :hand-l)))) (b (if (= g 0) (* 16 (ji :lower-arm-r)) (* 16 (ji :lower-arm-l))))
             (hx (aref jm (+ h 12))) (hy (aref jm (+ h 13))) (hz (aref jm (+ h 14)))
             (yx (aref jm (+ h 4))) (yy (aref jm (+ h 5))) (yz (aref jm (+ h 6)))   ; the hand's +Y (its talons: -Y)
             (yl (f-max 1f-5 (f-hypot yx yy yz)))
             (px (- hx (* ct (/ yx yl)))) (py (- hy (* ct (/ yy yl)))) (pz (- hz (* ct (/ yz yl))))
             (ax (- hx (aref jm (+ b 12)))) (ay (- hy (aref jm (+ b 13)))) (az (- hz (aref jm (+ b 14))))   ; the forearm
             (al (/ cs (f-max 1f-5 (f-hypot ax ay az))))
             (ux (* al ax)) (uy (* al ay)) (uz (* al az)))
        (declare (type f32vec tr) (fixnum n h b) (single-float hx hy hz yx yy yz yl px py pz ax ay az al ux uy uz))
        (if (and (> (aref w 52) 0.5f0) (/= 0 (logand (f->i (aref w 40)) (if (= g 0) 1 2))))
            (let* ((o (* 6 (max 0 (1- n)))) (qx (- px (aref tr (+ o 3)) (- ux))) (qy (- py (aref tr (+ o 4)) (- uy)))
                   (qz (- pz (aref tr (+ o 5)) (- uz))))
              (declare (fixnum o) (single-float qx qy qz))
              (when (or (= n 0) (> (+ (* qx qx) (* qy qy) (* qz qz)) 1f-4))
                (%trail-push tr (- px ux) (- py uy) (- pz uz) (+ px ux) (+ py uy) (+ pz uz))))
            (when (> n 0) (%trail-drop tr n)))
        (%lb-claw-smears tr side g))))
  nil)

;; Lille II's whips on the owl (DUEL_LILLE_V3 §10, the user 2026-10-11: 「將光翼拉伸如同長鞭一般鞭擊」): its claws are the
;; rig's hands, so a stretched claw (*LB-STRETCH*) draws a gold lash on from it along the forearm; Jilliel's front wings
;; are drawn longer instead (%LB-WINGS).
(defparameter *lb-lash-w* 0.07 "The owl's gold lash: its half-width (m; a comet thickest near the claw, to a point) ...")
(defparameter *lb-lash-sag* 0.2 "... its droop off the active frames, a share of its length (straight on them).")
(defun-fast %lb-lashes (jm side)
  "The owl's gold lashes (Lille II's J whips): each claw with a stretch (*LB-WF* [72 73], %LB-STRETCH!) draws a gold
comet curve that many metres on from the claw along the forearm, a white core in it; straight on the active frames ([41]),
drooping by *LB-LASH-SAG* of its length off them. Its tip is the strike point (the host FK test). 0 B."
  (declare (type f32vec jm) (fixnum side))
  (let ((w *lb-wf*) (sc (aref *lb-v* 31)))
    (declare (type f32vec w) (single-float sc))
    (dotimes (g 2)
      (let ((ex (* sc (aref w (+ 72 g)))))
        (declare (single-float ex))
        (when (and (> ex 0.02f0) (< (aref w (+ 81 g)) 0.5f0))   ; (R11: [81 82] 1 = Lille II draws this claw's whip itself)
          (let* ((h (if (= g 0) (* 16 (ji :hand-r)) (* 16 (ji :hand-l))))
                 (b (if (= g 0) (* 16 (ji :lower-arm-r)) (* 16 (ji :lower-arm-l))))
                 (hx (aref jm (+ h 12))) (hy (aref jm (+ h 13))) (hz (aref jm (+ h 14)))
                 (dx (- hx (aref jm (+ b 12)))) (dy (- hy (aref jm (+ b 13)))) (dz (- hz (aref jm (+ b 14))))
                 (k (/ ex (f-max 1f-4 (f-hypot dx dy dz))))
                 (tx (+ hx (* k dx))) (ty (+ hy (* k dy))) (tz (+ hz (* k dz)))
                 (sag (if (> (aref w 41) 0.5f0) 0f0 (* 2f0 ex (the single-float *lb-lash-sag*))))
                 (bx (* 0.5f0 (+ hx tx))) (by (- (* 0.5f0 (+ hy ty)) sag)) (bz (* 0.5f0 (+ hz tz)))
                 (lw (* sc (the single-float *lb-lash-w*) (+ 1f0 (* (aref w 71) ex)))) (sd (+ 150f0 (* 5f0 (i->f (+ g (* 2 side)))))))
            (declare (fixnum h b) (single-float hx hy hz dx dy dz k tx ty tz sag bx by bz lw sd))
            (fx-crescent tx ty tz hx hy hz bx by bz lw :comet 0.04f0 sd +pal-gold+ 0.95f0 :push 0.2f0)
            (fx-crescent tx ty tz hx hy hz bx by bz (* 0.4f0 lw) :comet 0.02f0 (+ sd 1f0) +pal-hit+ 0.9f0 :push 0.25f0))))))
  nil)

(defmacro %lb-halo (jm o kind lift r)
  "A halo LIFT m above joint frame O of JM (its local up), radius R: KIND 0 Jilliel's wide jade ring, 1 the owl's spiked
gold one, 2 the owl's broken one. The alpha: *LB-V* [14]; LIFT and R go through [17 18]."
  `(progn (setf (aref *lb-v* 17) ,lift (aref *lb-v* 18) ,r) (%lb-halo* ,jm ,o ,kind)))
(defun-fast %lb-halo* (jm o kind)
  (declare (type f32vec jm) (fixnum o kind))
  (%lb-joint-frame! *lb-m* jm o 0f0 (aref *lb-v* 17) (if (= kind 0) 0f0 -0.2f0) (aref *lb-v* 18))
  (let ((al (lb-alpha (aref *lb-v* 14))))
    (case kind
      (0 (draw-weapon :lb-halo *lb-m* :alpha al :emissive (svref *lb-alphas* 0)))
      (1 (draw-weapon :lb-halo-gold *lb-m* :alpha al :emissive (svref *lb-alphas* 0)))
      (t (draw-weapon :lb-halo-broken *lb-m* :alpha al :emissive (svref *lb-alphas* 0)))))
  nil)

;;; ---------------------------------------------------------------- the ㄇ legs (KIN and the owl) and the owl's extra arms
;; Decision 26: from the fork (the thigh's end, 0.44 m below the hip: the body's knob) the front shank runs down, the strut
;; runs back (horizontal in the thigh's frame) and from its end (the corner's knob) the rear shank runs down: from the side
;; the two shanks and the strut read as ㄇ. Drawn in the thigh's frame (so a hit reaction or a knockdown carries the whole
;; leg); each shank's length is where its line meets the floor (the feet height of his body's draw, *TOON-BODY* [1]), within
;; 0.45-1.35 of its 1 m rest (the clips' float moves the fork; a leg pitched far from upright keeps the rest length).
(defparameter *lb-leg-fork* 0.44 "The fork's distance down the thigh (m; the body's knob).")
(defparameter *lb-leg-strut* 0.52 "The strut's length back from the fork (m): the ㄇ's top bar.")
(defmacro %lb-shank-len (py dy)
  "The shank from height PY along the unit direction's DY: where it meets the floor (*LB-V* [3]), clamped; else 1 m (x his
drawn scale [31])."
  `(let ((%py ,py) (%dy ,dy) (%sc (aref *lb-v* 31)))
     (declare (single-float %py %dy %sc))
     (if (< %dy -0.35f0) (f-clamp (/ (- %py (aref *lb-v* 3)) (- %dy)) (* 0.45f0 %sc) (* 1.35f0 %sc)) %sc)))
(defmacro %lb-unit! (x y z)
  "Normalise the single-float places X Y Z in place (0 B)."
  `(let ((%l (f-max 1f-5 (f-hypot ,x ,y ,z)))) (declare (single-float %l))
     (setf ,x (/ ,x %l) ,y (/ ,y %l) ,z (/ ,z %l))))
(defparameter *lb-tuck-turn* 1.4
  "The owl's EN folds its ㄇ legs up (decision 38): at full tuck each shank turns this many radians about the thigh's side
axis, the front one back and the rear one forward, so both fold under the strut (a short bar under the floating column).")
(defparameter *lb-tuck-len* 0.48 "... and is this long (m; standing, a shank runs to the floor).")
(defun-fast %lb-legs (jm white fl)
  "Both ㄇ legs (decision 26) from the thighs of JM: WHITE 1 the owl's, else KIN's cream; FL 1 the hit flash. The floor's
height in *LB-V* [3], the alpha in [4] (1: the old MUJITTAI's 0.72 went 2026-10-21), the tuck 0..1 in [8] (the owl's EN folds them up, decision
38: the front shank turned back, the rear one forward, both *LB-TUCK-LEN* long); *LB-WF* [90] the pull 0..1 (Lille II's
stance switch, DUEL_LILLE_V3 §16 R11: the strut and the shanks shrunk by 1 - pull, thinner with it, gone at 0.97; his
:pose hook shrinks the thighs the same way)."
  (declare (type f32vec jm) (fixnum white fl))
  (let* ((al (lb-alpha (aref *lb-v* 4))) (fla (svref *lb-alphas* (if (= fl 1) 9 0)))   ; (boxed: 0 B)
         (tk (aref *lb-v* 8)) (tt (* tk (the single-float *lb-tuck-turn*))) (ct (f-cos tt)) (st (f-sin tt))
         (pq (- 1f0 (f-clamp (aref *lb-wf* 90) 0f0 1f0)))                    ; (1 but in Lille II's switch)
         (sc (* pq (aref *lb-v* 31))) (tl (* sc (the single-float *lb-tuck-len*)))   ; (x his drawn scale: a giant's legs)
         (fyc (- (* -0.1f0 st) ct)) (fbc (- st (* 0.1f0 ct)))          ; the front shank's up / back shares, turned back
         (ryc (- (* -0.12f0 st) ct)) (rbc (+ (- st) (* 0.12f0 ct))))   ; the rear's, turned forward
    (declare (single-float tk tt ct st pq sc tl fyc fbc ryc rbc))
    (dotimes (side (if (> pq 0.03f0) 2 0))
      (let* ((o (if (= side 0) (* 16 (ji :thigh-r)) (* 16 (ji :thigh-l)))) (s (if (= side 0) 1f0 -1f0))
             (ox (* s (aref jm o))) (oy (* s (aref jm (+ o 1)))) (oz (* s (aref jm (+ o 2))))            ; out
             (yx (aref jm (+ o 4))) (yy (aref jm (+ o 5))) (yz (aref jm (+ o 6)))                      ; up the thigh
             (bx (aref jm (+ o 8))) (by (aref jm (+ o 9))) (bz (aref jm (+ o 10)))                     ; back
             (fk (the single-float *lb-leg-fork*)) (ls (* sc (the single-float *lb-leg-strut*)))
             (px (- (aref jm (+ o 12)) (* fk yx))) (py (- (aref jm (+ o 13)) (* fk yy))) (pz (- (aref jm (+ o 14)) (* fk yz)))
             ;; the front shank: down, a little forward and out (tucked: turned back under the strut)
             (fx (+ (* 0.07f0 ox) (* fyc yx) (* fbc bx))) (fy (+ (* 0.07f0 oy) (* fyc yy) (* fbc by)))
             (fz (+ (* 0.07f0 oz) (* fyc yz) (* fbc bz)))
             ;; the strut: back, a little out; the rear shank: down, a little back and out (tucked: turned forward)
             (sx (+ bx (* 0.04f0 ox))) (sy (+ by (* 0.04f0 oy))) (sz (+ bz (* 0.04f0 oz)))
             (rx (+ (* ryc yx) (* rbc bx) (* 0.07f0 ox))) (ry (+ (* ryc yy) (* rbc by) (* 0.07f0 oy)))
             (rz (+ (* ryc yz) (* rbc bz) (* 0.07f0 oz))))
        (declare (fixnum o) (single-float s ox oy oz yx yy yz bx by bz fk ls px py pz fx fy fz sx sy sz rx ry rz))
        (%lb-unit! fx fy fz) (%lb-unit! sx sy sz) (%lb-unit! rx ry rz)
        (let ((lf (+ (* pq (- 1f0 tk) (%lb-shank-len py fy)) (* tk tl))) (cx (+ px (* ls sx))) (cy (+ py (* ls sy))) (cz (+ pz (* ls sz))))
          (declare (single-float lf cx cy cz))
          (%lb-frame! *lb-m* px py pz fx fy fz ox oy oz lf sc)
          (if (= white 1) (draw-weapon :lb-shank-white *lb-m* :alpha al :flash fla :tint *lb-leg-tint*) (draw-weapon :lb-shank-cream *lb-m* :alpha al :flash fla :tint *lb-leg-tint*))
          (%lb-frame! *lb-m* px py pz sx sy sz ox oy oz ls)
          (if (= white 1) (draw-weapon :lb-strut-white *lb-m* :alpha al :flash fla :tint *lb-leg-tint*) (draw-weapon :lb-strut-cream *lb-m* :alpha al :flash fla :tint *lb-leg-tint*))
          (let ((lr (+ (* pq (- 1f0 tk) (%lb-shank-len cy ry)) (* tk tl))))
            (declare (single-float lr))
            (%lb-frame! *lb-m* cx cy cz rx ry rz ox oy oz lr sc)
            (if (= white 1) (draw-weapon :lb-shank-white *lb-m* :alpha al :flash fla :tint *lb-leg-tint*)
                (draw-weapon :lb-shank-cream *lb-m* :alpha al :flash fla :tint *lb-leg-tint*)))))))
  nil)

;;; ---------------------------------------------------------------- the looks keyed on his state
(defmacro lb-fxs (side i) `(aref *lb-fx* (+ (* 24 ,side) ,i)))

(defun lb-cine-frame (e name)
  "The running cinematic's frame when it is NAME with E as its subject, else NIL (a look the script drives)."
  (let ((c *cine*)) (and c (eq (cine-name c) name) (eq (cine-a c) e) (cine-cf c))))

;;; Every component lookup of an entity conses 8 B in this build (an ECS getter: the reads probe, debug 79195), so the
;;; draw hook makes the fewest: his fighter and model each frame, his state (LBS, read as it is: the draw never makes one)
;;; only in the looks that read it (the base form's eye, the owl's seal), his transform only while a look needs his place.
(defmacro %lb-load-place! (e)
  "*LB-V* [24..27] = E's x y z and yaw (one transform lookup)."
  `(let* ((%tr (transform ,e)) (%p (transform-pos %tr)) (%v *lb-v*))
     (declare (type f32vec %p %v))
     (setf (aref %v 24) (aref %p 0) (aref %v 25) (aref %p 1) (aref %v 26) (aref %p 2) (aref %v 27) (transform-yaw %tr))))

(defun-fast %lb-eye-look (e m side)
  "The awakening cinematic's eye (LB-JILLIEL-CINE from its f30): the left eye open over the shut lid (the face swap), the
mark flaring jade to its f60. (The old Lille's eye, opened in play, went with him: 2026-10-13.)"
  (declare (fixnum side))
  (let* ((now (fx-clock)) (jm (model-joints m)))
    (declare (single-float now) (type f32vec jm))
    (let ((age (- now (lb-fxs side 1))) (cf (lb-cine-frame e 'lb-jilliel-cine)))
      (declare (single-float age))
      (when (and cf (>= (the fixnum cf) 30))
        (let ((o (* 16 (ji :head))))
          (declare (fixnum o))
          (%lb-joint-frame! *lb-m* jm o 0f0 0f0 0f0 1f0)
          (draw-weapon :lb-eye-open *lb-m*)
          (when (or (< age 0.35f0) (and cf (< 30 (the fixnum cf) 60)))
            (let* ((x (+ (* (aref jm o) -0.0336f0) (* (aref jm (+ o 4)) 0.1488f0) (* (aref jm (+ o 8)) -0.08f0) (aref jm (+ o 12))))
                   (y (+ (* (aref jm (+ o 1)) -0.0336f0) (* (aref jm (+ o 5)) 0.1488f0) (* (aref jm (+ o 9)) -0.08f0) (aref jm (+ o 13))))
                   (z (+ (* (aref jm (+ o 2)) -0.0336f0) (* (aref jm (+ o 6)) 0.1488f0) (* (aref jm (+ o 10)) -0.08f0) (aref jm (+ o 14))))
                   (k (if cf 0.9f0 (- 0.95f0 (* 2.4f0 age)))) (rt (camera-right *camera*)) (up (camera-upv *camera*)))
              (declare (single-float x y z k) (type f32vec rt up))
              (dotimes (i 4)                             ; the X flaring into four long light strokes
                (let* ((a (+ 0.7853982f0 (* 1.5707964f0 (i->f i)))) (c (f-cos a)) (s (f-sin a))
                       (dx (+ (* c (aref rt 0)) (* s (aref up 0)))) (dy (+ (* c (aref rt 1)) (* s (aref up 1))))
                       (dz (+ (* c (aref rt 2)) (* s (aref up 2)))))
                  (declare (single-float a c s dx dy dz))
                  (fx-shard (+ x (* 0.07f0 dx)) (+ y (* 0.07f0 dy)) (+ z (* 0.07f0 dz)) dx dy dz 0.09f0 0.007f0 0.05f0
                            (+ 3f0 (i->f i)) +pal-jade+ k :push 0.12f0)))
              (fx-star x y z 0.012f0 0.026f0 8 0.4f0 0f0 0f0 0.1f0 7f0 +pal-jade+ k :push 0.1f0))))))
    nil))

(defmacro %lb-trumpet (k)
  "神の喇叭 forming over the owl (Trompete's tell, f10-60): the long gold horn from behind his head down to its bell before
him (the beam leaves the bell), its plume rising; K 0..1 how far it has formed (*LB-V* [17]; his place in [24..27])."
  `(progn (setf (aref *lb-v* 17) ,k) (%lb-trumpet*)))
(defun-fast %lb-trumpet* ()
  (let* ((v *lb-v*) (k (aref v 17)) (yaw (aref v 27)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
         (ax (- (aref v 24) (* 0.9f0 ux))) (ay 3.3f0) (az (- (aref v 26) (* 0.9f0 uz)))
         (bx (+ (aref v 24) (* 2.0f0 ux))) (by 1.7f0) (bz (+ (aref v 26) (* 2.0f0 uz)))
         (dx (- bx ax)) (dy (- by ay)) (dz (- bz az)) (l (f-hypot dx dy dz)) (s (* l (+ 0.15f0 (* 0.85f0 k)))))
    (declare (type f32vec v) (single-float k yaw ux uz ax ay az bx by bz dx dy dz l s))
    (%lb-frame! *lb-m* ax ay az (/ dx l) (/ dy l) (/ dz l) uz 0f0 (- ux) s)
    (setf (aref *toon-body* 1) 0f0)
    (draw-weapon :lb-trumpet *lb-m*)          ; (whole: a see-through toon draw reads dark; it forms by growing)
    (when (> k 0.3f0)                                    ; the light gathering in the bell
      (fx-star bx by bz (* 0.2f0 k) (* 0.5f0 k) 10 (* 3f0 (fx-clock)) 0f0 0f0 0.15f0 11f0 +pal-gold+ (* 0.9f0 k) :push 0.3f0))
    nil))

(defparameter *lb-owl-en-spread* 0.9
  "The owl's EN fans its wings out this far of an SP's spread (decision 36: 0.6; decision 38, the user 2026-10-06:
「遠程模式翼張開」: 0.6 -> 0.9, wide and forward, the holes to the opponent).")
(defparameter *lb-spread-clips* '(:lb-w-nijushi :lb-o-trompete)
  "The clips (besides every :sp and :kikon move) that fan the wings out (NIJUSHI-KO's beam, Trompete; the volley's :lb-w-aim went with decision 56).")
(defmacro lb-jilliel-form-p (form) "JILLIEL's two forms (KIN, EN)." `(member ,form '(:jilliel :jilliel-kin)))
(defmacro %lb-owl-p (form) "The owl's two forms (KIN, EN; decision 36)." `(member ,form '(:shin :shin-kin)))

(defun-fast lille-draw (e rdt)
  "His kit's :draw hook (after his body; cosmetic): the base form's eye opening and its aim line / reticle; Jilliel's eight
wing blades (both modes: two fans of four behind the column, the front pair reaching to the rig's hands, each swaying on
its own phase; their holes lit in NIJUSHI-KO's tell, fanned out in the SPs; translucent; each three jointed segments that
wave, lag and whip in the strikes and unfurl in the SPs) and the wide jade halo; on the KIN and owl bodies the ㄇ legs; the
owl's eight gold wings, its spiked halo, the trumpet forming over Trompete's wind-up. The awakening's cinematic drives the
wings and halo (the unfolding), the Kikon's their gather. Its only allocation is the entity lookups (two a frame, three in
the base form and the owl; one more while he aims or a gold look plays). (The old Lille's revival and MUJITTAI looks went
2026-10-21, refactor round 2.)"
  (declare (single-float rdt))
  (let* ((f (fighter e)) (side (fighter-side f)) (form (fighter-form f)) (m (model e)) (jm (model-joints m))
         (mv (and (eq (fighter-state f) :move) (fighter-move f))) (v *lb-v*) (tm (fx-clock))
         (cj (lb-cine-frame e 'lb-jilliel-cine))
         (ct (lb-cine-frame e 'lb-trompete-cine)) (ck (lb-cine-frame e 'lb-jilliel-kikon-cine))
         (look (cond ((and cj (< (the fixnum cj) 92)) :base)
                     ((lb-jilliel-form-p form) :jilliel) ((%lb-owl-p form) :shin) (t :base))))
    (declare (fixnum side) (type f32vec jm v) (single-float tm))
    (setf (lb-fxs side 15) (if (%lb-owl-p form) 1f0 0f0))   ; (his hazards' looks read it: gold or jade)
    (let ((spread (and mv (or (member (mv-kind mv) '(:sp :kikon)) (member (mv-clip mv) *lb-spread-clips*)))))
      (setf (lb-fxs side 16)                             ; the SPs fan the wings out (0.12 s either way) ...
            (if spread (f-min 1f0 (+ (lb-fxs side 16) (* 8f0 rdt))) (f-max 0f0 (- (lb-fxs side 16) (* 8f0 rdt))))
            (lb-fxs side 17)                             ; ... and their joints furl then unfurl from the root (decision 32)
            (if spread (f-min 1f0 (+ (lb-fxs side 17) (* 2.2f0 rdt))) (f-max 0f0 (- (lb-fxs side 17) (* 3f0 rdt))))))
    (setf (aref *lb-wf* 42) (lb-fxs side 17))
    ;; the owl's two modes (decision 38): [18] 0..1 toward EN (5 / s: inside TENSHIN's dash): EN's legs folded up ([8] the
    ;; tuck) and its wings fanned wide and forward ([28] the spread); KIN's legs down and its wings swept back ([29])
    (let ((en (eq form :shin)))
      (setf (lb-fxs side 18) (if en (f-min 1f0 (+ (lb-fxs side 18) (* 5f0 rdt))) (f-max 0f0 (- (lb-fxs side 18) (* 5f0 rdt))))
            (aref v 8) (cond ((> (aref *lb-wf* 89) 0f0) (- (aref *lb-wf* 89) 1f0))   ; (Lille II's stance switch, R11:
                             ((%lb-owl-p form) (lb-fxs side 18)) (t 0f0))           ;  his draw hook's fold + 1)
            (aref v 29) (if (%lb-owl-p form) (- 1f0 (lb-fxs side 18)) 0f0))
      (when (and mv (member (mv-clip mv) *lb-sweep-clips*))   ; (Lille II's dash, R9: the eight wings swept back; R10, §15:
        (setf (aref v 29) (f-max 1f0 (aref *lb-wf* 80)))))   ;  tighter by the L charge's level, his draw hook's [80])
    (%lb-drive! f mv rdt (%lb-owl-p form))               ; the joints' strike drive (cosmetic: the move's frame)
    (%lb-stretch! (model-anim m))                        ; (Lille II's whips: the front wings' / lashes' stretch)
    (%lb-sp-drive! f mv (%lb-owl-p form) ck)             ; the SPs', the Kikon's and its cinematic's (decision 56)
    (let ((pz (anim-pose (model-anim m))) (w *lb-wf*))   ; (the clip's root turn and offset: decision 50's targets)
      (declare (type f32vec pz w))
      (setf (aref w 53) (aref pz 66) (aref w 59) (aref pz 65) (aref w 60) (aref pz 63)))
    (setf (aref v 28) (lb-fxs side 16)
          (aref v 31) (draw-scale-of e)                  ; (the Jilliel Kikon's giant: his wings, holes, legs and flashes)
          (aref v 3) (- (aref *toon-body* 1)             ; his body's feet height (DRAW-BODY's) less the form's drawn
                        (* (aref v 31) (the single-float (f32 (body-lift (fighter-kit f) (model-body m)))))))   ; lift: the floor
    (when (>= (model-alpha m) 0.999f0)
      (let ((bn (body-name (model-body m))) (fl (if (> (model-flash m) 0f0) 1 0)))
        (when (or (eq bn :lille-jilliel-kin) (eq bn :lille-shin))   ; the ㄇ legs (decision 26)
          (setf (aref v 4) 1f0)
          (setf *lb-leg-tint* (model-tint m))   ; (the mirror match's P2 tint, as his body: the user 2026-10-13)
          (%lb-legs jm (if (eq bn :lille-shin) 1 0) fl)
          nil))
      (case look
        (:base (%lb-eye-look e m side))
        (:jilliel
         ;; (the old MUJITTAI's fold [4] and pass-through [3] are never written now: [4] stays 0, the fold only the Kikon
         ;; cinematic's gather; [3] stays 0, so RIP < 0.5 over the fx clock's first 0.5 s: that ripple is kept as it was)
         (let* ((rip (- tm (lb-fxs side 3))) (k (lb-fxs side 4))
                (gather (if (and ck (< (the fixnum ck) 24)) (i->f ck) -1f0))   ; (the Kikon cinematic's beat 1:
                (o (* 16 (ji :chest))))                                         ;  gathered round him, shaking, f0-23)
           (declare (single-float rip k gather) (fixnum o))
           (setf (aref v 0) 0f0 (aref v 1) 0.3f0 (aref v 2) 0.13f0
                 (aref v 11) (if (>= gather 0f0) (f-max k (* 0.85f0 (%lb-ss (/ gather 6f0)))) k)
                 (aref v 12) (cond ((>= gather 0f0) (+ 3f0 (* 0.4f0 gather))) ((< rip 0.5f0) (* 14f0 (- 1f0 (* 2f0 rip))))
                                   (t 0f0))
                 (aref v 13) tm
                 (aref v 14) 1f0 (aref v 16) (aref v 31)
                 (aref v 15) (if (and cj (< (the fixnum cj) 160)) (f-max 0f0 (/ (- (i->f cj) 112f0) 8f0)) 9f0))
           (%lb-wings jm o *lb-wings-jl* 8 0 side)     ; (the holes lit: [65], %LB-SP-DRIVE!)
           (%lb-trails jm side)                        ; the tip trails (decision 50)
           (if (and cj (< (the fixnum cj) 160))        ; the wide thin halo
               (let ((u (f-clamp (/ (- (i->f cj) 120f0) 40f0) 0f0 1f0)))   ; the awakening: it draws itself
                 (declare (single-float u))
                 (when (> u 0f0) (%lb-halo jm (* 16 (ji :head)) 0 0.52f0 (* 0.48f0 u))))
               (%lb-halo jm (* 16 (ji :head)) 0 (+ 0.52f0 (* 0.02f0 (f-sin (* 2f0 tm)))) 0.48f0))))
        (:shin                                           ; the owl (decision 36: Jilliel's forms, the owl's look)
         ;; EN vs KIN (decision 38): EN fans its eight wings out wide and forward (a standing spread, [18]), KIN sweeps
         ;; them back ([29], set above)
         (let ((rip (- tm (lb-fxs side 3))))           ; ([3] and [4] as Jilliel's above)
           (declare (single-float rip))
           (setf (aref v 0) 0f0 (aref v 1) 0.3f0 (aref v 2) 0.13f0 (aref v 11) (lb-fxs side 4)
                 (aref v 12) (if (< rip 0.5f0) (* 14f0 (- 1f0 (* 2f0 rip))) 0f0) (aref v 13) tm
                 (aref v 14) 1f0 (aref v 15) 9f0
                 (aref v 16) (aref v 31)               ; (x (+ 0.3 (* 0.7 grow)) = 1f0 with the revival's grow gone)
                 (aref v 28) (f-max (aref v 28) (* (the single-float *lb-owl-en-spread*) (lb-fxs side 18)))))
         (%lb-wings jm (* 16 (ji :chest)) *lb-wings-owl* 8 2 side)
         (%lb-lashes jm side)                          ; (Lille II's whips: the claws' gold lashes)
         (%lb-claw-trails jm side)                     ; the claw trails (decision 56)
         (%lb-halo jm (* 16 (ji :head)) 1 0.76f0 0.13f0)
         (let ((tsf (cond (ct (if (< 8 (the fixnum ct) 120) (- (the fixnum ct) 8) -1))
                          ((and mv (member (mv-name mv) '(:lb-trompete :br-trompete)) (eq (fighter-phase f) :main))   ; (+ Lille
                           (fighter-sf f))                                                                       ;  II's)
                          ((and mv (member (mv-name mv) '(:lb-oe-trompete :br-oe-trompete)) (eq (fighter-phase f) :main))   ; (EN's: its clip's
                           (truncate (* 60 (the fixnum (fighter-sf f))) (max 1 (the fixnum (mv-s mv)))))   ;  speed, 5 x)
                          (t -1))))
           (declare (fixnum tsf))
           (when (<= 10 tsf 89)
             (%lb-load-place! e)
             (%lb-trumpet (f-clamp (/ (- (i->f tsf) 10f0) 50f0) 0f0 1f0)))))))
    (setf (lb-fxs side 19) 0f0)                          ; (Lille II's lit wings: BR-DRAW's, this frame only)
    nil))

;;; ---------------------------------------------------------------- his hazards' look (kind :lb-fx, :lb-sabaki)
(defmacro %lb-judge-speed () "The owl's materialised trace (裁きの光明, decision 36): its gold blasts erupt along the line at
this many m/s (31 m in 8 f: the hit is the whole line at once, the look follows it fast; a literal: 0 B) ..." 240f0)
(defmacro %lb-judge-burn () "... each point burning this many seconds." 0.3f0)
(defun-fast lb-look (hz rdt)
  "His hazards' draw function (HAZARD-DRAW): a shot's line at the volume's height (jade for an aimed one, ink for a snap
shot; a white core and the muzzle's cross flash on its first frames), a beam (a wide toon band, jade or
the owl's gold, a white core), a Kikon lane on the floor, the SABAKI line's gold blasts erupting along its burning span (a
thin gold sheet under them). Fading over the hazard's life. 0 B."
  (declare (single-float rdt))
  (setf rdt 0f0)                                        ; (unused: HAZARD-DRAW's signature)
  (let* ((d (hazard-data hz)))
    (when (and (lbh-p d) (<= (hazard-delay hz) 0))
      (let* ((x (hazard-x hz)) (z (hazard-z hz)) (yaw (hazard-yaw hz)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
             (age (hazard-age hz)) (fade (f-max 0f0 (- 1f0 (/ (i->f age) (i->f (max 1 (hazard-life hz)))))))
             (owl (> (lb-fxs (if (eql (hazard-owner hz) *p1*) 0 1) 15) 0.5f0))   ; (no lookup: LILLE-DRAW's flag)
             (kind (lbh-kind d)) (len (hazard-size hz))   ; (the struct's float slots would box through an accessor
             (w (case kind (:beam 1.2f0) (:lane 0.5f0) (:sabaki (the single-float (f32 *lb-sabaki-width*)))   ; call)
                      (:judge (if (eq (lbh-lock d) :thick) 1.2f0 0.6f0)) (t 0.05f0)))
             (wall (%lb-wall x z ux uz)) (l (f-min len wall)) (sd (i->f (mod age 97))))
        (declare (single-float x z yaw ux uz fade len w wall l sd) (fixnum age))
        (case kind
          (:shot                                       ; (one line along his facing: the volley's five-line fan went with rework R)
           (let ((y 1.2f0) (ww (* (if (lbh-lock d) 0.07f0 0.05f0) (+ 0.3f0 fade))))
             (declare (single-float y ww))
             (toon-ribbon ((+ x (* 0.6f0 ux)) y (+ z (* 0.6f0 uz))) ((* (- l 0.6f0) ux) 0f0 (* (- l 0.6f0) uz)) (ww ww) :heat (1f0 0.7f0)
                          :seed (- -11f0 sd) :wob 0.02f0 :pal (if (lbh-lock d) +pal-jade+ +pal-ink+) :k (* 0.98f0 fade) :k1 (* 0.9f0 fade) :segs 2)
             (when (< age 4)                            ; the first frames: a white core, the cross flash at the muzzle
               (fx-ribbon (+ x (* 0.6f0 ux)) y (+ z (* 0.6f0 uz)) (* (- l 0.6f0) ux) 0f0 (* (- l 0.6f0) uz) (* 0.4f0 ww) (* 0.4f0 ww)
                          1f0 (- -12f0 sd) 0.0f0 (toon-a +pal-hit+ 0.95f0) 1f0 (- -12f0 sd) 0f0 (toon-a +pal-hit+ 0.9f0) 0f0 0f0
                          :segs 2 :mode :toon)
               (fx-star (+ x (* 1.0f0 ux)) y (+ z (* 1.0f0 uz)) 0.06f0 0.32f0 4 0f0 0f0 0f0 0.05f0 13f0
                        +pal-hit+ (- 0.98f0 (* 0.2f0 (i->f age))) :push 0.2f0))))
          (:beam
           (let* ((ww (* w (+ 0.35f0 (* 0.65f0 fade)))) (pal (if owl +pal-gold+ +pal-jade+)))
             (declare (single-float ww pal))
             (toon-ribbon ((+ x (* 0.6f0 ux)) 1.3f0 (+ z (* 0.6f0 uz))) ((* (- l 0.6f0) ux) 0f0 (* (- l 0.6f0) uz)) (ww ww) :heat (1f0 0.8f0)
                          :seed (- -31f0 sd) :wob 0.05f0 :pal pal :k (* 0.98f0 fade) :k1 (* 0.9f0 fade) :segs 3)
             (toon-ribbon ((+ x (* 0.6f0 ux)) 1.3f0 (+ z (* 0.6f0 uz))) ((* (- l 0.6f0) ux) 0f0 (* (- l 0.6f0) uz)) ((* 0.35f0 ww) (* 0.35f0 ww))
                          :heat (1f0 1f0) :seed (- -32f0 sd) :wob 0.05f0 :pal +pal-hit+ :k (* 0.95f0 fade) :k1 (* 0.9f0 fade) :segs 3)))
          (:lane (%lb-floor-line 1 (+ x (* 0.6f0 ux)) (+ z (* 0.6f0 uz)) ux uz (- l 0.6f0) (* w fade)))
          (:judge                                      ; the owl's trace materialised (decision 36): 裁きの光明, gold blasts
           (let* ((a2 (/ (i->f age) 60f0)) (sp (%lb-judge-speed))   ; erupting along the ground to the wall
                  (from (f-max 0.6f0 (* sp (- a2 (%lb-judge-burn))))) (to (f-min l (+ 0.6f0 (* sp a2)))))
             (declare (single-float a2 sp from to))
             (when (> to from)
               (toon-ribbon ((+ x (* from ux)) 0.2f0 (+ z (* from uz))) ((* (- to from) ux) 0f0 (* (- to from) uz)) ((* 0.2f0 w) (* 0.12f0 w))
                            :heat (1f0 0.6f0) :seed (- -43f0 sd) :wob 0.05f0 :pal +pal-gold+ :k 0.95f0 :k1 0.8f0 :segs 4)
               (do ((r (+ 1f0 (* 1.5f0 (i->f (f->i (/ from 1.5f0))))) (+ r 1.5f0))) ((> r to))
                 (declare (single-float r))
                 (let* ((h (* (+ 1.2f0 (* 0.9f0 w)) (f-min 1f0 (/ (- to r) 2.5f0)) (f-min 1f0 (* 0.4f0 (- r from -0.6f0)))))
                        (bx (+ x (* r ux))) (bz (+ z (* r uz))))
                   (declare (single-float h bx bz))
                   (when (> h 0.05f0)
                     (%tongue bx 0f0 bz 0f0 h 0f0 (* 0.4f0 w) +pal-gold+ 0.95f0 (+ r (* 7f0 sd)) (* 3f0 r) 0.1f0))))
               (when (< age 3)                          ; the first frames: a white core along the line
                 (toon-ribbon ((+ x (* 0.6f0 ux)) 0.25f0 (+ z (* 0.6f0 uz))) ((* (- l 0.6f0) ux) 0f0 (* (- l 0.6f0) uz)) ((* 0.08f0 w) (* 0.08f0 w))
                              :heat (1f0 1f0) :seed (- -44f0 sd) :wob 0f0 :pal +pal-hit+ :k 0.9f0 :k1 0.8f0 :segs 2)))))
          (:sabaki
           (let* ((a2 (/ (i->f age) 60f0)) (r0 (the single-float (f32 *lb-sabaki-from*))) (sp (the single-float (f32 *lb-sabaki-speed*)))
                  (from (f-max r0 (* sp (- a2 (/ (i->f (the fixnum *lb-sabaki-life*)) 60f0))))) (to (f-min len (+ r0 (* sp a2)))))
             (declare (single-float a2 r0 sp from to))
             (when (> to from)
               (toon-ribbon ((+ x (* from ux)) 0.2f0 (+ z (* from uz))) ((* (- to from) ux) 0f0 (* (- to from) uz)) (0.1f0 0.06f0) :heat (1f0 0.6f0)
                            :seed (- -41f0 sd) :wob 0.05f0 :pal +pal-gold+ :k 0.95f0 :k1 0.8f0 :segs 4)
               (do ((r (f-max 1f0 (i->f (f->i from))) (+ r 1f0))) ((> r to))
                 (declare (single-float r))
                 (let* ((h (* 1.7f0 (f-min 1f0 (/ (- to r) 3f0)) (f-min 1f0 (* 0.5f0 (- r from -0.6f0)))))
                        (bx (+ x (* r ux))) (bz (+ z (* r uz))))
                   (declare (single-float h bx bz))
                   (when (> h 0.05f0)
                     (%tongue bx 0f0 bz 0f0 h 0f0 (* 0.32f0 w) +pal-gold+ 0.95f0 (+ r (* 7f0 sd)) (* 3f0 r) 0.1f0)))))))))))
  nil)

