;;;; barro-draw.lisp — Lille's draw code (cosmetic): the wing wall, the draw hook BR-DRAW (his wing count to Lille's lit wings, then
;;;; the base stance's aim line, the spends' looks and the volley's), the recall's and the strings' looks, the R5 K3 ball, the R15
;;;; base-stance looks, the special resource's looks, and the HUD row (BR-HUD-METER) (split out of barro-art.lisp 2026-10-21,
;;;; refactor round 2). Loads after barro-art.lisp (the clips; its DECLAIM SPECIAL line covers this file) and before
;;;; barro-stills.lisp and barro.lisp (whose state and knobs these functions read at draw time).
(in-package :duel)

;;; ---------------------------------------------------------------- the wing wall (his awakened guard)
;;; The user, 2026-10-12: 「把覺醒時的防禦姿勢改成用八翼擋住前面進行防禦」 (DUEL_LILLE_V3 "The wing wall"). In JILLIEL (KIN and
;;; EN) and the owl (KIN and EN) his guard is the eight wings brought round in front of him into a closed, overlapping screen,
;;; the column lowered and leaning in behind it; a blocked hit knocks the wall and the column back a little and they settle.
;;; The kits' :look-clips (barro.lisp *BR-WALL-CLIPS* ..) play these for the generic :sh-guard / :sh-guard-hit; the wall
;;; itself is LILLE-DRAW's (*LB-WF* [91], *LB-WALL-JL* / *-OWL*: every blade pinned at its place before him, curled round
;;; the column), its share eased in as the guard goes up (*BR-WALL-IN*) and out as it drops (*BR-WALL-OUT*) by BR-DRAW
;;; (%BR-WALL-SHARE). JILLIEL's hands are the front pair's tips (low before him, past his midline); the owl's claws crossed
;;; before its chest, behind the wall (solved to points in the chest's frame: JILLIEL's hands at (-0.3, -0.45, 0.75) across /
;;; up / forward, the owl's claws at (-0.12, -0.05, 0.45), its EN's at (-0.12, -0.1, 0.4)). A look: no state, timer or volume
;;; reads a clip.
(defpose :br-w-wall-pose (:base :lb-w-stance)          ; JILLIEL: lowered, leaning in, the front pair's tips low before him
  (:root :u -0.1) (:spine :flex 8) (:chest :flex 4) (:head :flex 10)
  (:arm-r :flex 28.5 :side 5.3 :twist 55) (:elbow-r :flex 85.8) (:arm-l :flex 28.5 :side 5.3 :twist 55) (:elbow-l :flex 85.8))
(defclip :br-w-guard (2.4 :loop t :base :br-w-wall-pose)   ; held: a slow breath behind the wall
  (0) (1.2 (:root :u -0.125) (:head :flex 13)) (2.4))
(defclip :br-w-guard-hit (0.3 :base :br-w-wall-pose)   ; blocked: the wall and the column knocked back, settled
  (0) (0.05 :snap (:root :f -0.12 :u -0.13) (:spine :flex 6) (:chest :flex 0) (:head :flex 12)   ; (the hands 0.15 m back)
              (:arm-r :flex 33.3 :side 15.8 :twist 66) (:elbow-r :flex 99.3) (:arm-l :flex 33.3 :side 15.8 :twist 66) (:elbow-l :flex 99.3))
  (0.3 :br-w-wall-pose))
(defpose :br-o-wall-pose (:base :lb-o-stance)          ; the owl KIN: crouched lower on its legs, pitched in, the claws crossed
  (:root :u -0.1) (:spine :flex 28) (:neck :flex 20) (:head :flex 4)
  (:arm-r :flex 10.8 :side -11 :twist 37) (:elbow-r :flex 123.8) (:arm-l :flex 10.8 :side -11 :twist 37) (:elbow-l :flex 123.8))
(defclip :br-o-guard (2.4 :loop t :base :br-o-wall-pose)
  (0) (1.2 (:root :u -0.125) (:head :flex 8)) (2.4))
(defclip :br-o-guard-hit (0.3 :base :br-o-wall-pose)
  (0) (0.05 :snap (:root :f -0.12 :u -0.04) (:spine :flex 20) (:neck :flex 12) (:head :flex -4)
              (:arm-r :flex 4 :side -9 :twist 37) (:elbow-r :flex 132) (:arm-l :flex 4 :side -9 :twist 37) (:elbow-l :flex 132))
  (0.3 :br-o-wall-pose))
(defpose :br-oe-wall-pose (:base :lb-oe-stance)        ; the owl EN: upright, afloat, a little lowered, the claws crossed
  (:root :u -0.04) (:spine :flex 8) (:head :flex 6)
  (:arm-r :flex 0.8 :side -13 :twist 35) (:elbow-r :flex 125.5) (:arm-l :flex 0.8 :side -13 :twist 35) (:elbow-l :flex 125.5))
(defclip :br-oe-guard (2.4 :loop t :base :br-oe-wall-pose)
  (0) (1.2 (:root :u -0.065) (:head :flex 9)) (2.4))
(defclip :br-oe-guard-hit (0.3 :base :br-oe-wall-pose)
  (0) (0.05 :snap (:root :f -0.12 :u -0.02) (:spine :flex 0) (:head :flex -2)
              (:arm-r :flex -4 :side -11 :twist 35) (:elbow-r :flex 134) (:arm-l :flex -4 :side -11 :twist 35) (:elbow-l :flex 134))
  (0.3 :br-oe-wall-pose))
(defparameter *br-wall-in* 9.0
  "The wing wall's share rises this much a second as his guard goes up (0 -> 1 in ~0.11 s, smoothstepped: the raise) ...")
(defparameter *br-wall-out* 7.0 "... and falls this much a second once it drops (~0.14 s: the release).")
(declaim (type f32vec *br-wall*))
(defvar *br-wall* (make-f32 2) "Per side, the wing wall's share 0..1 as last drawn (the looks' memory, never the sim).")
(defun-fast %br-wall-share (f side awake rdt)
  "The wing wall for F (SIDE) this frame: its share eased toward 1 while he guards (:guard / :guard-hit) in an AWAKE form,
else toward 0 (*BR-WALL-IN* / *BR-WALL-OUT* a second of RDT); smoothstepped into *LB-WF* [91] for LILLE-DRAW. 0 B."
  (declare (fixnum side) (single-float rdt))
  (let* ((v *br-wall*) (on (and awake (member (fighter-state f) '(:guard :guard-hit))))
         (u (if on
                (f-min 1f0 (+ (aref v side) (* (the single-float *br-wall-in*) rdt)))
                (f-max 0f0 (- (aref v side) (* (the single-float *br-wall-out*) rdt))))))
    (declare (type f32vec v) (single-float u))
    (setf (aref v side) u (aref *lb-wf* 91) (%lb-ss u))
    nil))
;;; ---------------------------------------------------------------- the draw hook
(defparameter *br-aim-stance* '(:br-kamae :br-kamae-k :br-kamae-j :br-kamae-re)
  "The base stance's moves: the aim line tracks while one runs ...")
(defparameter *br-aim-locked* '(:br-s-jl1 :br-s-jl2 :br-s-jl3 :br-s-kl1 :br-s-kl2 :br-s-kl3)
  "... and turns jade, locked, through the startup of these shots (the stance's spending 萬物貫通 lines, decision R3).")
(defun-fast %br-aim-look (e f side)
  "The stance's aim line (Lille's %LB-AIM-LOOK on his moves): a thin line on the floor from under the muzzle to the wall,
grey while the stance (:br-kamae / :br-kamae-k / :br-kamae-j / :br-kamae-re) tracks, jade once the shot :br-k-shot locks until it fires; the reticle at
the opponent's distance, turning while it tracks, closing once locked."
  (declare (fixnum side))
  (setf side 0)                                         ; (unused: the slot memory is Lille's HUD tag's, not his)
  (let* ((mv (fighter-move f)) (nm (and mv (eq (fighter-state f) :move) (mv-name mv)))
         (stance (and nm (member nm *br-aim-stance*)))
         (locked (and nm (member nm *br-aim-locked*) (eq (fighter-phase f) :main) (< (fighter-sf f) (mv-s mv)))))
    (when (or stance locked)
      (%lb-load-place! e)
      (let* ((v *lb-v*) (yaw (aref v 27)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
             (x0 (+ (aref v 24) (* 0.5f0 ux))) (z0 (+ (aref v 26) (* 0.5f0 uz)))
             (wall (%lb-wall x0 z0 ux uz)) (dist (the single-float (fighter-dist f)))
             (dq (f-clamp (- dist 0.5f0) 1f0 (f-max 1f0 wall)))
             (rx (+ x0 (* dq ux))) (rz (+ z0 (* dq uz)))
             (r (if locked (- 0.65f0 (* 0.018f0 (i->f (fighter-sf f)))) 1.1f0))
             (tm (fx-clock)))
        (declare (type f32vec v) (single-float yaw ux uz x0 z0 wall dist dq rx rz r tm))
        (%lb-floor-line (if locked 1 0) x0 z0 ux uz wall (if locked 0.06f0 0.035f0))
        (%lb-reticle locked rx rz r (if locked 0.785398f0 (* 1.4f0 tm)))))
    nil))

;;; ---------------------------------------------------------------- the recall and its strings' looks (§12)
(defparameter *br-rc-beats*
  '((:br-rc0 (6 3)) (:br-rc1 (6 1) (16 2)) (:br-rc2 (6 1) (14 2) (22 1) (32 3)) (:br-rc3 (6 1) (12 2) (18 1) (24 2) (36 4))
    (:br-rc4 (6 1) (12 2) (18 1) (24 2) (30 1) (36 2) (48 4)))
  "The recall strings' beats (their moves' line frames, barro.lisp): (frame kind), kind 1 the right wing / claw fires, 2 the
left, 3 both, 4 the finisher (the ring and the beam). The clips (above) and the looks (BR-RC-DRIVE, BR-DRAW) read them.
:br-rc4 (裁き・極, decision V8's 10+ recall, §22) is spec frames until barro.lisp has the move (the host test compares).")
(defparameter *br-finisher* '((:br-rc3 36 10 1.0) (:br-rc4 48 10 1.6))
  "The strings that end in NIJUSHI-KO's ring and beam: (move beam-frame ring-frames scale): the ring rises over the frames
before the beam; SCALE (1 = 裁き's) drives 裁き・極's bigger ring, harder shake, wider and longer beam and blow-back (§22).")
;; 裁き・極's brush callout (decision V8, §22; its 極 baked into glyphs-extra.lisp): barro.lisp's list replaces only the rows it
;; names, so this row stands until it names :br-rc4 itself
(when (boundp '*brush-callouts*)
  (setf *brush-callouts* (append (remove :br-rc4 *brush-callouts* :key #'first) '((:br-rc4 "裁き・極" "SABAKI KIWAMI" nil)))))
(dolist (c '(:br-recall :br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4))   ; the six table wings fan out through the recall and its strings
  (pushnew c *lb-spread-clips*))                             ;  (LILLE-DRAW's spread: an SP's; Lille never plays these clips)

(defun-fast br-rc-beat (nm sf)
  "The latest beat of recall string NM at its frame SF: (+ (* 1000 kind) age), age the frames since it (<= 999), or -1
before the first (or NM not a string). 0 B (a constant list walked)."
  (declare (fixnum sf))
  (let ((best -1))
    (declare (fixnum best))
    (dolist (b (cdr (assoc nm *br-rc-beats*)) best)
      (let ((fr (first b)))
        (declare (fixnum fr))
        (when (<= fr sf) (setf best (+ (* 1000 (the fixnum (second b))) (min 999 (- sf fr)))))))))

(defmacro %br-chain-clock (nm sf)
  "The recall's look clock: its own frame through :br-recall, 7 + the string's frame through :br-rc0..3 (its f7 starts
it), else -1."
  `(let ((%nm ,nm) (%sf ,sf))
     (declare (fixnum %sf))
     (cond ((eq %nm :br-recall) %sf) ((member %nm '(:br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)) (+ 7 %sf)) (t -1))))

(defun-fast br-rc-drive (f mv)
  "Lille's %LB-SP-DRIVE! for his recall strings (JILLIEL's wings; its clause calls this): each beat kicks the firing wing
(SANREN's whip: a virtual speed back, easing out over *LB-SP-KICK* frames) and flashes its holes; the finisher (:br-rc3's
f36) rises into NIJUSHI-KO's ring over f26-35 (lit, shaking), the beam blows it back. The numbers go out through
*LB-SP-EXT* (ring, cup, shake, speed, flash, lit bits, the striking wings' mask, the other wings' share). T when it set
them. Reads the move's frame only (cosmetic). 0 B."
  (let* ((x *lb-sp-ext*) (sf (fighter-sf f)) (nm (mv-name mv)) (b (br-rc-beat nm sf)) (fin (assoc nm *br-finisher*))
         (bf (if fin (the fixnum (second fin)) 9999)) (rf (if fin (the fixnum (third fin)) 0))
         (sc (if fin (f32 (fourth fin)) 1f0)))
    (declare (type f32vec x) (fixnum sf b bf rf) (single-float sc))
    (when (eq (fighter-phase f) :main)
      (cond ((>= sf (- bf rf))                              ; the finisher: NIJUSHI-KO's ring, its beam (frames; 極 scaled)
             (let ((post (i->f (- sf bf))) (pre (/ (i->f (- sf (- bf rf))) (i->f rf))))
               (declare (single-float post pre))
               (setf (aref x 5) 255f0 (aref x 6) 3f0 (aref x 7) 0.8f0 (aref x 2) 0f0 (aref x 4) 0f0)
               (if (< post 0f0)
                   (setf (aref x 0) (%lb-ss (/ pre 0.35f0))
                         (aref x 1) (- (* 0.35f0 sc) (* 0.25f0 (%lb-ss (/ (- pre 0.4f0) 0.6f0))))
                         (aref x 2) (* sc (the single-float *lb-ring-shake*) (%lb-ss (/ (- pre 0.3f0) 0.7f0)) (+ 0.3f0 (* 0.7f0 pre)))
                         (aref x 3) (* 0.5f0 (the single-float *lb-strike-in*) (%lb-ss (/ (- pre 0.5f0) 0.5f0))))
                   (let ((bl (f-max 0f0 (- 1f0 (/ post (* 10f0 sc))))))
                     (declare (single-float bl))
                     (setf (aref x 0) (- 1f0 (%lb-ss (/ (- post 18f0) 16f0)))
                           (aref x 1) (* -0.85f0 (%lb-ss (/ post 2.5f0)) (- 1f0 (%lb-ss (/ (- post 8f0) 18f0))))
                           (aref x 3) (* sc (the single-float *lb-ring-blow*) bl bl)
                           (aref x 5) (if (< post (* 6f0 sc)) 255f0 0f0) (aref x 4) (f-max 0f0 (- 1f0 (/ post (* 6f0 sc)))))))
               t))
            ((>= b 0)                                         ; a beat: SANREN's kick on the firing wing
             (let ((kind (floor b 1000)) (age (mod b 1000)))
               (declare (fixnum kind age))
               (when (< age (the fixnum *lb-sp-kick*))
                 (let ((u (- 1f0 (/ (i->f age) (i->f (the fixnum *lb-sp-kick*))))))
                   (declare (single-float u))
                   (setf (aref x 0) 0f0 (aref x 1) 0f0 (aref x 2) 0f0
                         (aref x 3) (- (* (the single-float *lb-sp-whip*) u u (if (= kind 3) 1.3f0 1f0)))
                         (aref x 4) (f-max 0f0 (- 1f0 (/ (i->f age) 6f0)))
                         (aref x 5) (case kind (1 16f0) (2 32f0) (t 48f0)) (aref x 6) (i->f (min 3 kind)) (aref x 7) 0.6f0)
                   t))))))))

;; the traces' light flying back (the recall): BR-TRACE-LOOK notes each live trace it draws (*BR-SEEN*), BR-DRAW keeps the
;; last frame's set while he is not recalling (*BR-FLY*) and draws it flying into him through the recall's look clock
(declaim (type f32vec *br-seen* *br-fly*))
(defvar *br-seen* (make-f32 (* 2 65)) "Per side (65 a side): [0] the traces noted this frame, then x z yaw thick per trace (16).")
(defvar *br-fly* (make-f32 (* 2 65)) "Per side: the last frame's traces before the recall (as *BR-SEEN*).")
(defparameter *br-fly-f* 9 "The recall's look: the traces' far ends reach him on this frame of its clock (their near ends at 2/3) ...")
(defparameter *br-gather-f* '(5 15) "... and the light gathered at his chest flares over these frames.")
(declaim (type fixnum *br-art-hold* *br-art-hold-next*))
(defvar *br-art-hold* -1 "Debug 82200+f (art stills): the sim freezes once his look clock (BR-HOLD-CLOCK) reaches f; -1 none.")
(defvar *br-art-hold-next* -1 "... armed by 82200+f, taken by the next scene (82100+k) once it is set up.")

(defun-fast %br-recall-look (e jm side c)
  "The recall's look at its clock C (frames): each trace taken back (*BR-FLY*) a jade line (the owl's gold) whose near end
rushes along the floor and up into his chest by 2/3 of *BR-FLY-F* and whose far end follows from the wall by *BR-FLY-F*,
brightening, a light at its head; then the gathered light flares at his chest (*BR-GATHER-F*, bigger with more traces; a
faint puff for none). 0 B."
  (declare (type f32vec jm) (fixnum side c))
  (setf e nil)                                          ; (unused: the hook's entity, kept for the signature)
  (let* ((v *br-fly*) (o (* 65 side)) (n (min 16 (f->i (aref v o)))) (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+))
         (ff (i->f (the fixnum *br-fly-f*))) (cf (i->f c)) (b (%lb-ss (/ cf ff))) (a (%lb-ss (/ cf (* 0.667f0 ff))))
         (k (- 1f0 (%lb-ss (/ (- cf (- ff 2f0)) 3f0)))) (p *lb-p*))
    (declare (type f32vec v p) (fixnum o n) (single-float pal ff cf b a k))
    (joint-point! p jm (ji :chest) 0f0 0f0 0f0)
    (let ((cx (aref p 0)) (cy (aref p 1)) (cz (aref p 2)))
      (declare (single-float cx cy cz))
      (when (> k 0.01f0)
        (dotimes (i n)
          (let* ((q (+ o 1 (* 4 i))) (yaw (aref v (+ q 2))) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
                 (ox (+ (aref v q) (* 0.6f0 ux))) (oz (+ (aref v (+ q 1)) (* 0.6f0 uz))) (l (%lb-wall ox oz ux uz))
                 (fx0 (+ ox (* l ux))) (fz0 (+ oz (* l uz)))
                 (nx (+ ox (* a (- cx ox)))) (ny (+ 0.05f0 (* a (- cy 0.05f0)))) (nz (+ oz (* a (- cz oz))))
                 (fx (+ fx0 (* b (- cx fx0)))) (fy (+ 0.05f0 (* b (- cy 0.05f0)))) (fz (+ fz0 (* b (- cz fz0))))
                 (w (* (if (> (aref v (+ q 3)) 0.5f0) 0.12f0 0.045f0) (+ 1f0 (* 1.4f0 b)))) (sd (i->f i)))
            (declare (fixnum q) (single-float yaw ux uz ox oz l fx0 fz0 nx ny nz fx fy fz w sd))
            (toon-ribbon (fx fy fz) ((- nx fx) (- ny fy) (- nz fz)) ((* 0.5f0 w) w) :heat (0.8f0 1f0) :seed (- -61f0 sd) :wob 0.04f0
                         :pal pal :k (* 0.95f0 k) :k1 k :segs 3)
            (toon-ribbon (fx fy fz) ((- nx fx) (- ny fy) (- nz fz)) ((* 0.15f0 w) (* 0.35f0 w)) :heat (1f0 1f0) :seed (- -62f0 sd)
                         :wob 0.02f0 :pal +pal-hit+ :k (* 0.9f0 k) :k1 (* 0.9f0 k) :segs 2)
            (when (< a 0.98f0)                              ; the light's head
              (fx-star nx ny nz 0.05f0 0.16f0 6 (+ sd (* 0.3f0 cf)) 0f0 0f0 0.1f0 (+ 63f0 sd) pal (* 0.9f0 k) :push 0.2f0)))))
      (let* ((g0 (i->f (the fixnum (first *br-gather-f*)))) (g1 (i->f (the fixnum (second *br-gather-f*))))
             (u (/ (- cf g0) (- g1 g0))) (s (+ 0.3f0 (* 0.12f0 (i->f n)))))
        (declare (single-float g0 g1 u s))
        (when (< 0f0 u 1f0)
          (let ((kk (* (if (zerop n) 0.5f0 0.95f0) (f-sin (* 3.1415927f0 u)))))
            (declare (single-float kk))
            (fx-star cx cy cz (* 0.15f0 s kk) (* 0.55f0 s kk) 10 (* 2f0 cf 0.1f0) 0f0 0f0 0.15f0 64f0 pal kk :push 0.35f0)
            (fx-star cx cy cz (* 0.06f0 s kk) (* 0.22f0 s kk) 6 (* -3f0 cf 0.1f0) 0f0 0f0 0.05f0 65f0 +pal-hit+ kk :push 0.4f0))))))
  nil)

(defun-fast %br-beat-look (e f jm side mv)
  "A recall string's beat (*BR-RC-BEATS*), its first 5 frames: from each firing wing tip (the claw: the rig's hand) a line
at him (to his chest, the line's height), jade (the owl's gold), thinning, a flash at the tip; the finisher's from both
(wider; 裁き・極's wider still and held 9 frames). 0 B but the opponent's place (one lookup on those frames)."
  (declare (type f32vec jm) (fixnum side))
  (setf e nil)
  (let* ((b (br-rc-beat (mv-name mv) (fighter-sf f))) (kind (if (>= b 0) (floor b 1000) 0)) (age (if (>= b 0) (mod b 1000) 99))
         (big (and (= kind 4) (eq (mv-name mv) :br-rc4))) (life (if big 9 5)))
    (declare (fixnum b kind age life))
    (when (and (eq (fighter-phase f) :main) (< age life))
      (let* ((q (pos-of (fighter-opp f))) (p *lb-p*) (k (- 1f0 (/ (i->f age) (i->f life))))
             (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)) (w (* k (if (= kind 4) (if big 0.24f0 0.16f0) 0.06f0)))
             (tx (aref q 0)) (ty 1.2f0) (tz (aref q 2)))
        (declare (type f32vec q p) (single-float k pal w tx ty tz))
        (dotimes (h 2)
          (when (logbitp h (if (= kind 4) 3 kind))
            (joint-point! p jm (if (= h 0) (ji :hand-r) (ji :hand-l)) 0f0 0f0 0f0)
            (let ((hx (aref p 0)) (hy (aref p 1)) (hz (aref p 2)) (sd (i->f (+ h (* 2 kind)))))
              (declare (single-float hx hy hz sd))
              (toon-ribbon (hx hy hz) ((- tx hx) (- ty hy) (- tz hz)) (w (* 0.6f0 w)) :heat (1f0 0.7f0) :seed (- -71f0 sd)
                           :wob 0.02f0 :pal pal :k (* 0.95f0 k) :k1 (* 0.7f0 k) :segs 2)
              (toon-ribbon (hx hy hz) ((- tx hx) (- ty hy) (- tz hz)) ((* 0.35f0 w) (* 0.2f0 w)) :heat (1f0 1f0) :seed (- -72f0 sd)
                           :wob 0f0 :pal +pal-hit+ :k (* 0.9f0 k) :k1 (* 0.6f0 k) :segs 2)
              (fx-star hx hy hz (* 0.05f0 k) (* (if (= kind 4) 0.4f0 0.2f0) k) 6 sd 0f0 0f0 0.1f0 (+ 73f0 sd) pal k :push 0.25f0)))))))
  nil)

;; 裁き・極's own looks (decision V8, §22), over the shared finisher drive (BR-RC-DRIVE's ring at *BR-FINISHER*'s scale):
;; JILLIEL's NIJUSHI-KO ring drawn out as its twenty-four holes round him, bigger than the wings' (lit one after another,
;; all lit and shaking by f44), bursting outward with the beam; the owl's Trompete-like gold blast gathering between its
;; raised claws; then the wider, longer beam along his line to the wall, a floor shock ring under him.
(defparameter *br-kiwami-ring* '(1.0 2.0 0.35)
  "裁き・極's hole ring: its radius grows from the first (m) to the second over the ring's first half; its centre sits the
third (m) behind his chest, in the plane facing the opponent.")
(defparameter *br-kiwami-beam* '(14 0.42 3.0)
  "裁き・極's beam overlay: lasts this many frames from f48, this half-width (m) at its widest (裁き's line overlay 5 f, 0.16),
and runs this far (m) past the opponent (the wall nearer; never on into the front view's camera).")

(defun-fast %br-kiwami-look (f jm side)
  "裁き・極 (the move :br-rc4) at its frame: f38-47 the ring (JILLIEL: 24 holes on a circle facing him, lit in turn,
shaking; the owl: the gold blast gathering between its raised claws), f48 on the beam (*BR-KIWAMI-BEAM*: a wide jade / gold
ribbon from his chest along his line to the wall, its white core, the holes bursting outward, a shock ring on the floor).
Reads *BR-AT* (his place and the opponent's, BR-DRAW's) and the move's frame. 0 B."
  (declare (type f32vec jm) (fixnum side))
  (let* ((at *br-at*) (o (* 8 side)) (sf (fighter-sf f)) (gold (> (lb-fxs side 15) 0.5f0))
         (pal (if gold +pal-gold+ +pal-jade+)) (tm (fx-clock)) (p *lb-p*))
    (declare (type f32vec at p) (fixnum o sf) (single-float pal tm))
    (when (and (> (aref at (+ o 4)) 0.5f0) (<= 38 sf 61))
      (let* ((dx (- (aref at (+ o 2)) (aref at o))) (dz (- (aref at (+ o 3)) (aref at (+ o 1))))
             (dl (f-max 0.01f0 (f-hypot dx dz))) (ux (/ dx dl)) (uz (/ dz dl)) (sx (- uz)) (sz ux)
             (r0 (f32 (first *br-kiwami-ring*))) (r1 (f32 (second *br-kiwami-ring*))) (bk (f32 (third *br-kiwami-ring*))))
        (declare (single-float dx dz dl ux uz sx sz r0 r1 bk))
        (joint-point! p jm (ji :chest) 0f0 0f0 0f0)
        (let ((cx (- (aref p 0) (* bk ux))) (cy (+ (aref p 1) 0.25f0)) (cz (- (aref p 2) (* bk uz))))
          (declare (single-float cx cy cz))
          (if (< sf 48)
              (let* ((u (/ (i->f (- sf 38)) 10f0)) (r (+ r0 (* (- r1 r0) (%lb-ss (/ u 0.5f0)))))
                     (lit (f->i (* 24f0 (%lb-ss (/ u 0.6f0))))) (shk (* 0.06f0 (%lb-ss (/ (- u 0.3f0) 0.7f0)))))
                (declare (single-float u r shk) (fixnum lit))
                (if gold                                ; the owl: the blast gathering between the raised claws
                    (progn
                      (joint-point! p jm (ji :hand-r) 0f0 0f0 0f0)
                      (let ((hx (aref p 0)) (hy (aref p 1)) (hz (aref p 2)))
                        (declare (single-float hx hy hz))
                        (joint-point! p jm (ji :hand-l) 0f0 0f0 0f0)
                        (let* ((mx (* 0.5f0 (+ hx (aref p 0)))) (my (+ 0.1f0 (* 0.5f0 (+ hy (aref p 1)))))
                               (mz (* 0.5f0 (+ hz (aref p 2)))) (j (* shk (f-sin (* 41f0 tm))))
                               (g (+ 0.12f0 (* 0.48f0 (%lb-ss u)))))
                          (declare (single-float mx my mz j g))
                          (fx-disc (+ mx j) my (- mz j) g 0.25f0 131f0 +pal-gold+ 0.95f0 :push 0.3f0)
                          (fx-disc (+ mx j) my (- mz j) (* 0.45f0 g) 0.15f0 132f0 +pal-hit+ 0.98f0 :push 0.4f0)
                          (fx-star (+ mx j) my (- mz j) (* 0.5f0 g) (* 2.2f0 g) 10 (* 2f0 tm) 0f0 0f0 0.15f0 133f0 +pal-gold+
                                   (+ 0.5f0 (* 0.45f0 u)) :push 0.35f0))))
                    (dotimes (i 24)                     ; JILLIEL: the twenty-four holes, lit in turn
                      (when (< i lit)
                        (let* ((a (+ (* 0.2617994f0 (i->f i)) (* shk (f-sin (+ (* 37f0 tm) (* 2.3f0 (i->f i)))))))
                               (ca (f-cos a)) (sa (f-sin a)) (hx (+ cx (* r ca sx))) (hy (+ cy (* r sa))) (hz (+ cz (* r ca sz)))
                               (sd (i->f i)))
                          (declare (single-float a ca sa hx hy hz sd))
                          (fx-star hx hy hz 0.03f0 (+ 0.06f0 (* 0.06f0 u)) 6 (+ sd tm) 0f0 0f0 0.1f0 (+ 134f0 sd) +pal-jade+ 0.95f0
                                   :push 0.25f0)
                          (fx-disc hx hy hz 0.04f0 0.1f0 (+ 160f0 sd) +pal-hit+ 0.95f0 :push 0.3f0)
                          (when (< (1+ i) lit)                ; (the chord to the next lit hole: the ring's line)
                            (let* ((b (+ a 0.2617994f0)) (nx (+ cx (* r (f-cos b) sx))) (ny (+ cy (* r (f-sin b))))
                                   (nz (+ cz (* r (f-cos b) sz))))
                              (declare (single-float b nx ny nz))
                              (toon-ribbon (hx hy hz) ((- nx hx) (- ny hy) (- nz hz)) (0.02f0 0.02f0) :heat (0.8f0 0.8f0)
                                           :seed (- -170f0 sd) :wob 0f0 :pal +pal-jade+ :k 0.85f0 :segs 1))))))))
              (let* ((a (i->f (- sf 48))) (life (i->f (the fixnum (first *br-kiwami-beam*))))
                     (hw (f32 (second *br-kiwami-beam*))) (ex (f32 (third *br-kiwami-beam*)))
                     (k (* (f-min 1f0 (+ 0.5f0 (/ a 4f0))) (- 1f0 (* (/ a life) (/ a life)))))
                     (bx (+ (aref p 0) (* 0.4f0 ux))) (bz (+ (aref p 2) (* 0.4f0 uz)))
                     (len (f-min (+ dl ex) (%lb-wall bx bz ux uz))))
                (declare (single-float a life hw ex k bx bz len))
                (when (and (< a life) (> k 0.02f0))     ; the beam, wider and longer than 裁き's
                  (toon-ribbon (bx 1.2f0 bz) ((* len ux) 0f0 (* len uz)) ((* hw k) (* 0.5f0 hw k)) :heat (1f0 0.8f0)
                               :seed -141f0 :wob 0.03f0 :pal pal :k (* 0.95f0 k) :k1 (* 0.8f0 k) :segs 3)
                  (toon-ribbon (bx 1.2f0 bz) ((* len ux) 0f0 (* len uz)) ((* 0.35f0 hw k) (* 0.25f0 hw k)) :heat (1f0 1f0)
                               :seed -142f0 :wob 0f0 :pal +pal-hit+ :k (* 0.95f0 k) :k1 (* 0.85f0 k) :segs 2)
                  (fx-star bx 1.2f0 bz (* 0.2f0 k) (* 1.4f0 k) 12 (* 0.5f0 a) 0f0 0f0 0.15f0 143f0 +pal-hit+ k :push 0.4f0)
                  (%tring (aref at o) 0f0 (aref at (+ o 1)) (+ 1f0 (* 0.45f0 a)) 0.08f0 pal (* 0.9f0 k) 144f0 32))
                (when (and (not gold) (< a 10f0))       ; the holes burst outward with it
                  (let ((r (+ r1 (* 0.12f0 a))) (kk (- 1f0 (/ a 10f0))))
                    (declare (single-float r kk))
                    (dotimes (i 24)
                      (let* ((an (* 0.2617994f0 (i->f i))) (ca (f-cos an)) (sa (f-sin an)) (sd (i->f i)))
                        (declare (single-float an ca sa sd))
                        (fx-star (+ cx (* r ca sx)) (+ cy (* r sa)) (+ cz (* r ca sz)) 0.03f0 (* 0.12f0 kk) 6 sd 0f0 0f0 0.1f0
                                 (+ 134f0 sd) +pal-jade+ kk :push 0.25f0)))))))))))
  nil)

;; (unused with the swing clips since the revert: no move plays them, so this never draws) the ranged L swing's hit
;; (decision V8: a hit sets the aim point): a light stroke flicked from the swing's tip back over
;; his shoulder onto the new sigil 0.5 m behind him, while the set's flare (%BR-LIVE-LOOK) stamps it in
(defun br-hold-clock (f)
  "The art stills' clock of F's move (debug 82200+f): the recall chain's (%BR-CHAIN-CLOCK), else the move's frame, else -1."
  (let ((mv (and (eq (fighter-state f) :move) (fighter-move f))))
    (if mv (let ((c (%br-chain-clock (mv-name mv) (fighter-sf f)))) (if (>= c 0) c (fighter-sf f))) -1)))


;;; ---------------------------------------------------------------- BR-DRAW
(declaim (type f32vec *br-at*))
(defvar *br-at* (make-f32 16)
  "Per side (8 a side), written by BR-DRAW every frame: [0 1] his x z, [2 3] the opponent's, [4] 1 once written (the volley's
裁き・極 look reads it).")
(defmacro %br-place! (e opp side)
  "*BR-AT* [8 SIDE ..] = E's and OPP's x z, read in a DO-ENTITIES pass over the transforms (a component getter conses
8 B in this build; the pass does not)."
  `(let ((%at *br-at*) (%o (* 8 ,side)) (%e ,e) (%q ,opp))
     (declare (type f32vec %at) (fixnum %o))
     (do-entities (%h (%tr transform))
       (cond ((eql %h %e) (let ((%p (transform-pos %tr)))
                            (declare (type f32vec %p))
                            (setf (aref %at %o) (aref %p 0) (aref %at (+ %o 1)) (aref %p 2) (aref %at (+ %o 4)) 1f0)))
             ((eql %h %q) (let ((%p (transform-pos %tr)))
                            (declare (type f32vec %p))
                            (setf (aref %at (+ %o 2)) (aref %p 0) (aref %at (+ %o 3)) (aref %p 2))))))))

;;; ---------------------------------------------------------------- R5 K3 零距離砲擊 (DUEL_LILLE_V3 §10; R6 §11: a ball of light)
(defmacro %br-ball (x y z a life r pal sd)
  "A ball of light at (X Y Z), its frame A (a fixnum, from the shot) of LIFE (a fixnum), full radius R, palette PAL, seed SD
(零距離砲擊's blast, R6, §11: 「砲擊不要發射光束，直接在爆炸點炸開光球來表示」; the awakened K route's L L shots, R8, §13): a jade /
gold flash ball with a small white heart on the first two frames (R12, the user 2026-10-11: 「我希望架式 K > L 的砲擊每下都是
代表色（玉綠或是黃金色）」: the flash white and the core 0.62 of the shell before), then the ball swelling over its first
third, its jade / gold shell in a dark rim round a small white heart (0.28 of it) that shrinks away, eroding over its last half, dark smoke puffs rising and thinning from frame 6, a new drawing
every two frames. Single-float forms (a macro: 0 B)."
  `(let* ((%x ,x) (%y ,y) (%z ,z) (%a ,a) (%life ,life) (%r ,r) (%pal ,pal)
          (%d (i->f (* 2 (floor %a 2))))                 ; (on twos)
          (%u (/ %d (i->f %life)))
          (%es (* %r (+ 0.55f0 (* 0.6f0 (%lb-ss (* 3f0 %u))))))   ; (swells over the first third)
          (%k (- 1f0 (%lb-ss (/ (- %u 0.45f0) 0.55f0))))          ; (erodes over the last half)
          (%sd (+ ,sd %d)))
     (declare (fixnum %a %life) (single-float %x %y %z %r %pal %d %u %es %k %sd))
     (if (< %a 2)
         (progn (fx-disc %x %y %z (* 0.55f0 %r) 0.05f0 %sd %pal 0.98f0 :push 0.45f0)   ; (the flash: a jade / gold ball,
                (fx-disc %x %y %z (* 0.18f0 %r) 0.04f0 (+ %sd 1f0) +pal-hit+ 0.95f0 :push 0.5f0))   ;  a white heart, R12)
         (progn                                        ; (the ball of light: no spikes, no line toward him)
           (fx-disc %x %y %z (* 1.08f0 %es) 0.06f0 (+ %sd 3f0) +pal-ink+ (* 0.6f0 %k) :push 0.2f0)   ; (its dark rim)
           (fx-disc %x %y %z %es 0.05f0 %sd %pal %k :push 0.3f0)                               ; (the shell)
           (let ((%cr (* %es (- 0.28f0 (* 0.28f0 (%lb-ss (/ %u 0.45f0)))))))                  ; (the white heart: small, R12)
             (declare (single-float %cr))
             (when (> %cr 0.02f0) (fx-disc %x %y %z %cr 0.04f0 (+ %sd 5f0) +pal-hit+ 0.97f0 :push 0.4f0)))
           (when (>= %a 6)                              ; the smoke: three puffs rising off it
             (dotimes (%j 3)
               (let* ((%fj (i->f %j)) (%an (+ (* 2.1f0 %fj) (* 0.3f0 %u))) (%rr (* %r (+ 0.3f0 (* 0.5f0 %u)))))
                 (declare (single-float %fj %an %rr))
                 (fx-disc (+ %x (* %rr (f-cos %an))) (+ %y (* %r (+ 0.1f0 (* 0.9f0 %u))) (* 0.2f0 %fj)) (+ %z (* %rr (f-sin %an)))
                          (* %r (+ 0.22f0 (* 0.3f0 %u))) 0.25f0 (+ %sd 20f0 %fj) +pal-smoke+ (* 0.8f0 %k)))))))))
(defparameter *br-blast-life* 18
  "A ball of light (%BR-BALL: the awakened K route's L L, R8; K3's 零距離砲擊 until R9 took the blast out, §14): the frames it
lasts from the shot ...")
(defparameter *br-blast-r* 0.8 "... its radius at full size (m), x the draw scale.")

;; R8 (DUEL_LILLE_V3 §13, the user 2026-10-11: 「K 砲擊銜接的 L 也用一樣的砲擊特效炸在不同位置上」): the awakened K route's
;; L L (KL1 KL2 KL3, the 萬物貫通 lines after K3's blast) drawn as K3's balls of light instead of the line (BR-SHOT-FIRE spawns
;; their look as :ball, which LB-LOOK does not draw); the hit is still the line's
(defparameter *br-kl-balls*
  '((:br-e-kl1 0.9 1.9 0.75) (:br-oe-kl1 0.9 2.2 0.75) (:br-e-kl2 -0.9 0.55 0.75) (:br-oe-kl2 -0.9 0.8 0.75)
    (:br-e-kl3 0 1.25 1.15) (:br-oe-kl3 0 1.55 1.15))
  "The balls' places (R8, §13) round the line's point at the opponent's distance (on the line along his facing, even when
he is off it), by move: (move right up radius): KL1 off to his right and high, KL2 the other side and low, KL3 a bigger
one on him; metres (right of the line, above his floor) and the full radius.")
(defun-fast %br-kl-balls (f side mv)
  "The awakened K route's L L shot (a move in *BR-KL-BALLS*) at its frame: from its hit's first frame for *BR-BLAST-LIFE*
frames a ball of light (%BR-BALL) at its place on the line at the opponent's distance (his place and facing: *POSE-AT*,
DRAW-FIGHTER's; the opponent's: *BR-AT*), and a smaller one beside it. Reads the move's frame only. 0 B."
  (declare (fixnum side))
  (let* ((ent (assoc (mv-name mv) *br-kl-balls*)) (hits (mv-hits mv)) (n (length hits)) (life (the fixnum *br-blast-life*))
         (at *br-at*) (o (* 8 side)) (pa *pose-at*)
         (a (if (and ent (> n 0) (> (aref at (+ o 4)) 0.5f0))
                (- (the fixnum (fighter-sf f)) (the fixnum (hw-from (aref hits 0)))) -1)))
    (declare (fixnum n life o a) (type f32vec at pa))
    (when (<= 0 a life)
      (let* ((pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)) (sc (aref *lb-v* 31))
             (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
             (dist (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
             (lr (the single-float (f32 (second ent)))) (up (the single-float (f32 (third ent))))
             (r (* sc (the single-float (f32 (fourth ent)))))
             (x (+ (aref at o) (* dist ux) (* lr rx))) (y (+ (aref *lb-v* 3) up)) (z (+ (aref at (+ o 1)) (* dist uz) (* lr rz)))
             (sd (+ 470f0 (* 50f0 (i->f side)) (* 7f0 lr))))
        (declare (single-float pal sc yaw ux uz rx rz dist lr up r x y z sd))
        (%br-ball x y z a life r pal sd)
        (when (> a 1)                                   ; (a smaller one beside it, a frame later)
          (%br-ball (- x (* 0.5f0 r rx)) (+ y (* 0.45f0 r)) (- z (* 0.5f0 r rz)) (1- a) life (* 0.45f0 r) pal (+ sd 31f0)))))
    nil))

;; R9 (DUEL_LILLE_V3 §14, the user 2026-10-11: 「架式 L 的動作模組改成八翼往後收、身體前傾高速衝向對手，如果有碰到對手就穿過對
;; 方並造成連續斬擊（類似阿修羅壹霧銀先穿過對手、然後在讓對方受傷的表現）」): the awakened L's dash (the sim slides him through
;; him, barro.lisp BR-W-DASH) streaks, and once he is past, the cuts appear on the one he passed (Zoro's 阿修羅 一霧銀); the
;; cuts outlive the move (the next L press starts at its S + A), so their place and start are kept per side (*BR-CUTS*)
(defparameter *br-dash-moves* '(:br-e-l1 :br-oe-l1)
  "The awakened L dashes (R9; one charged dash since R10, §15): the charge's tells (%BR-CHARGE-LOOK), the streaks and, when
it hit, the cuts after (%BR-DASH-LOOK, %BR-CUTS-LOOK).")
(defparameter *br-dash-frames* 8 "The dash's frames from S (= barro.lisp's *BR-W-DASH-F*): the streaks, then the cuts.")
(defparameter *br-dash-streak* '(1.0 1.5 2.1)
  "The streaks' length x this by the charge level 1 / 2 / 3 (R10, DUEL_LILLE_V3 §15: 「隨著續力階段增加衝刺距離」; level 3 a white
core streak in them as well).")
(defparameter *br-dash-cut-len* '(2.2 2.5 2.8)
  "The cuts on him after the dash (R9; R11, DUEL_LILLE_V3 §16: each a hit of the sim's, barro.lisp BR-W-CUTS' :br-cut
hazards, drawn by BR-CUT-LOOK): this long (m, by the charge level), crossing round his middle.")
(defmacro %br-l-level (held)
  "The awakened L dash's charge level 1-3 for HELD frames (barro.lisp's BR-W-L-LEVEL on *BR-W-L-LEVELS*, inline: 0 B)."
  `(let ((%h ,held) (%l *br-w-l-levels*))
     (declare (fixnum %h))
     (cond ((>= %h (the fixnum (second %l))) 3) ((>= %h (the fixnum (first %l))) 2) (t 1))))
(defun-fast %br-dash-look (f side mv)
  "The awakened L dash (a move in *BR-DASH-MOVES*) at its frame: through the dash (S .. S + *BR-DASH-FRAMES* + 1) five
speed streaks trailing behind him (his drawn place: *POSE-AT*), longer by the charge level (*BR-DASH-STREAK*, R10; level 3
a white core streak too); the cuts after it are the sim's hazards (R11: BR-CUT-LOOK). Reads the move's frame and the frames L was
held (FIGHTER-CHARGE: the level, as BR-W-DASH's) only (cosmetic). 0 B."
  (declare (fixnum side))
  (let* ((sf (fighter-sf f)) (s (mv-s mv)) (dashf (the fixnum *br-dash-frames*)) (pa *pose-at*)
         (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+))
         (lv (%br-l-level (fighter-charge f))) (sk (the single-float (nth (1- lv) *br-dash-streak*)))
         (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw))))
    (declare (fixnum sf s dashf lv) (type f32vec pa) (single-float pal sk yaw ux uz rx rz))
    (when (and (<= s sf) (< sf (+ s dashf 2)))           ; the streaks behind him
      (let ((x (aref pa 0)) (y (aref pa 1)) (z (aref pa 2)))
        (declare (single-float x y z))
        (dotimes (i 5)
          (let* ((fi (i->f i)) (lat (* 0.32f0 (- fi 2f0))) (h (+ y 0.55f0 (* 0.28f0 (f-abs (- fi 2f0)))))
                 (ln (* sk (+ 1.6f0 (* 0.5f0 (hash01 fi 7.3f0)))))
                 (x0 (+ x (* lat rx) (* -0.4f0 ux))) (z0 (+ z (* lat rz) (* -0.4f0 uz))))
            (declare (single-float fi lat h ln x0 z0))
            (%streak x0 h z0 (- x0 (* ln ux)) h (- z0 (* ln uz)) (* 0.05f0 (+ 0.6f0 (* 0.4f0 sk))) pal 0.9f0 (+ 520f0 fi))
            (when (and (= lv 3) (= i 2))               ; (level 3: a white core in the middle one)
              (%streak x0 h z0 (- x0 (* 0.8f0 ln ux)) h (- z0 (* 0.8f0 ln uz)) 0.025f0 +pal-hit+ 0.95f0 526f0))))))
    nil))
(defun-fast br-cut-look (hz rdt)
  "One cut of the awakened L dash on the one he passed (R11, DUEL_LILLE_V3 §16: 「我希望衝刺 L 依據蓄力階段給出多段的斬擊特效
與 combo 計數」): a :br-cut hazard of barro.lisp's BR-W-CUTS (its data: the cut's index I and the charge level), drawn from
its hit (the hazard's delay over) for its life: a crossing pair of jade (the owl: gold) lenses with white cores, *BR-DASH-CUT-LEN*
long by the level, at golden-angle turns cut to cut in the plane square to the dash, each drawn in from one end over 2
frames, held, fading, a spark where it opens: 阿修羅 一霧銀's after-the-fact cuts, one a hit (the combo counts them). 0 B."
  (declare (single-float rdt))
  (when (and (<= (hazard-delay hz) 0) (>= rdt 0f0))
    (let* ((d (hazard-data hz)) (fi (i->f (the fixnum (first d)))) (lv (max 1 (min 3 (the fixnum (second d)))))
           (side (fighter-side (fighter (hazard-owner hz))))
           (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+))
           (a (i->f (the fixnum (hazard-age hz)))) (life (i->f (the fixnum (hazard-life hz))))
           (yaw (hazard-yaw hz)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
           (half (* 0.5f0 (the single-float (nth (1- lv) *br-dash-cut-len*))))
           (cx (hazard-x hz)) (cz (hazard-z hz)) (cy (+ (aref *lb-v* 3) 1.05f0))
           (k (- 1f0 (%lb-ss (/ (- a (* 0.5f0 life)) (* 0.5f0 life))))) (g (f-min 1f0 (/ (+ a 1f0) 2f0))))
      (declare (fixnum lv side) (single-float fi pal a life yaw ux uz rx rz half cx cy cz k g))
      (dotimes (j 2)                                    ; (the crossing pair: 「交叉斬痕」)
        (let* ((fj (i->f j)) (th (+ 0.4f0 (* 2.39996f0 fi) (* 1.7f0 fj)))   ; (the golden angle: the cuts spread round)
               (dx (* 0.18f0 (- (hash01 fi 3.1f0) 0.5f0))) (dy (* 0.3f0 (- (hash01 (+ fi fj) 5.7f0) 0.5f0)))
               (ca (* half (f-cos th))) (sa (* half (f-sin th)))
               (x0 (+ cx (* dx rx) (- (* ca rx)))) (y0 (+ cy dy (- sa))) (z0 (+ cz (* dx rz) (- (* ca rz))))
               (x1 (+ x0 (* g 2f0 ca rx))) (y1 (+ y0 (* g 2f0 sa))) (z1 (+ z0 (* g 2f0 ca rz)))
               (bx (+ (* 0.5f0 (+ x0 x1)) (* 0.12f0 ux))) (by (* 0.5f0 (+ y0 y1))) (bz (+ (* 0.5f0 (+ z0 z1)) (* 0.12f0 uz)))
               (sd (+ 540f0 (* 9f0 fi) (* 4f0 fj))))
          (declare (single-float fj th dx dy ca sa x0 y0 z0 x1 y1 z1 bx by bz sd))
          (fx-crescent x0 y0 z0 x1 y1 z1 bx by bz 0.09f0 :lens 0.04f0 sd pal k :push 0.3f0)
          (fx-crescent x0 y0 z0 x1 y1 z1 bx by bz 0.035f0 :lens 0.02f0 (+ sd 1f0) +pal-hit+ (* 0.95f0 k) :push 0.35f0)
          (when (< a 2f0)                                ; (the cut's spark where it opens)
            (fx-star x1 y1 z1 0.05f0 0.22f0 6 sd 0f0 0f0 0.08f0 (+ sd 2f0) +pal-hit+ 0.95f0 :push 0.4f0))))))
  nil)

;; R10 (DUEL_LILLE_V3 §15, the user 2026-10-11: 「L 衝刺改成只能衝一次不能連接，但可以三階段續力，隨著續力階段增加衝刺距離與
;; 交叉斬痕（增加傷害）並提昇特殊資源回收量」): while L is held (the move's :hold phase) the charge pose (:br-en-lc), coiled lower
;; by the level (BR-DEFORM, %BR-CHARGE-DEPTH) and its wings swept tighter (*LB-WF* [80]); light gathering into him, more
;; by the level, a glow at his core from level 2 (a white heart in it at 3), and a flash at each level-up (the frames held
;; reach *BR-W-L-LEVELS*' 20 / 40). All read from the frames held (FIGHTER-HOLD), then the frames L was held (FIGHTER-CHARGE).
(defun-fast %br-charge-look (f side mv)
  "The awakened L's charge (a move in *BR-DASH-MOVES*; R10, §15) at the frames held: motes of light spiralling in to him
(4 / 8 / 12 by the level), his core's glow from level 2 (a white heart at 3, flickering on twos), the level-up flash (a
white ball, a star burst: bigger at 3) over 10 frames from the level's frame held; after the release the motes and the
glow fade over the dash's load (8 frames). His drawn place: *POSE-AT*. Cosmetic. 0 B."
  (declare (fixnum side))
  (let* ((hold (eq (fighter-phase f) :hold)) (h (if hold (fighter-hold f) (fighter-charge f)))
         (lvs *br-w-l-levels*) (la (the fixnum (first lvs))) (lb (the fixnum (second lvs))) (lv (%br-l-level h))
         (fade (if hold 1f0 (- 1f0 (%lb-ss (/ (i->f (fighter-sf f)) 8f0)))))
         (pa *pose-at*) (x (aref pa 0)) (y (aref pa 1)) (z (aref pa 2)) (sc (aref *lb-v* 31)) (cy (+ y (* 1.15f0 sc)))
         (pal (if (> (lb-fxs side 15) 0.5f0) +pal-gold+ +pal-jade+)))
    (declare (fixnum h la lb lv) (type f32vec pa) (single-float fade x y z sc cy pal))
    (setf mv nil)                                       ; (unused: the looks' signature)
    (when (> fade 0f0)
      (dotimes (i (* 4 lv))                             ; the motes gathering in
        (let* ((fi (i->f i)) (ph (/ (i->f (mod (+ h (* 7 i)) 18)) 18f0))
               (r (* sc (- 1.5f0 (* 1.3f0 ph)))) (an (+ (* 2.39996f0 fi) (* 0.12f0 (i->f h))))
               (k (* fade (%lb-ss (* 4f0 ph)) (- 1f0 (%lb-ss (/ (- ph 0.8f0) 0.2f0))))))
          (declare (single-float fi ph r an k))
          (fx-star (+ x (* r (f-cos an))) (+ y (* sc (+ 0.3f0 (* 0.9f0 ph) (* 0.4f0 (hash01 fi 2.3f0))))) (+ z (* r (f-sin an)))
                   0.02f0 (* sc 0.08f0) 4 (* 0.5f0 fi) 0f0 0f0 0.05f0 (+ 600f0 fi) pal k :push 0.3f0)))
      (when (>= lv 2)                                   ; his core's glow
        (let ((r (* sc (+ 0.22f0 (* 0.12f0 (i->f (- lv 2))) (* 0.03f0 (i->f (mod (floor h 2) 2)))))))
          (declare (single-float r))
          (fx-disc x cy z r 0.15f0 (+ 620f0 (i->f lv)) pal (* fade 0.8f0) :push 0.35f0)
          (when (= lv 3) (fx-disc x cy z (* 0.5f0 r) 0.1f0 623f0 +pal-hit+ (* fade 0.95f0) :push 0.45f0)))))
    (when hold                                          ; the level-up flash
      (let ((u (cond ((<= la h (+ la 9)) (i->f (- h la))) ((<= lb h (+ lb 9)) (i->f (- h lb))) (t -1f0))))
        (declare (single-float u))
        (when (>= u 0f0)
          (let* ((t1 (/ u 10f0)) (k (- 1f0 t1)) (big (if (>= h lb) 1.35f0 1f0)))
            (declare (single-float t1 k big))
            (when (< u 2f0) (fx-disc x cy z (* sc big 0.4f0) 0.05f0 625f0 +pal-hit+ (- 0.98f0 (* 0.3f0 u)) :push 0.5f0))
            (fx-star x cy z (* sc 0.15f0) (* sc big (+ 0.6f0 (* 1.2f0 (%lb-ss t1)))) (if (>= h lb) 12 8) (* 0.3f0 (i->f h)) 0f0 0f0
                     0.1f0 626f0 pal k :push 0.4f0)
            (fx-star x cy z (* sc 0.08f0) (* sc big (+ 0.3f0 (* 0.8f0 (%lb-ss t1)))) 6 0.2f0 0f0 0f0 0.08f0 627f0 +pal-hit+ k
                     :push 0.45f0)))))
    nil))

;;; ---------------------------------------------------------------- R15 (DUEL_LILLE_V3 §19): the base stance's looks
;; The user 2026-10-11: 「用覺醒狀態的系統邏輯與動作模組的設計風格重製常態模式」 (「蓄力狙擊」, 「槍鬥術」, 「槍身重揮」). The base
;; form's stance L is one charged snipe, its J the gun-kata's point-blank shots, its K the rifle swung heavy. Their looks, read
;; off his move, its frame and the frames L was held (cosmetic): the charge's tells at the muzzle (BR-CHARGE, the kit's
;; :charge hook in place of the generic fire charge), the shot by its level (%BR-SNIPE-LOOK; the 4 / 12 / 31 m line itself
;; is LB-LOOK's, from BR-SHOT-FIRE's hazard of the move's :len), the coil and the kick (BR-DEFORM), the gun-kata's
;; point-blank blasts and the swings' impacts (%BR-KATA-LOOK; Diagramm's smear is the generic blade trail's).
(defparameter *br-snipe-moves* '(:br-s-l1 :br-s-l1-2 :br-s-l1-3)
  "The base stance's L, the charged snipe (R15), and the copies its release starts at level 2 / 3 (barro.lisp
BR-S-SNIPE-RELEASE): the charge's coil (BR-DEFORM, %BR-CHARGE-DEPTH) and tells (BR-CHARGE); after the release the shot's
level is the move's place in this list (%BR-SNIPE-LOOK, the kick in BR-DEFORM).")
(defparameter *br-snipe-kick* '(0.06 0.16 0.42)
  "The snipe's kick by its level 1 / 2 / 3: he is thrown back this far (m, drawn only: BR-DEFORM) over the 3 frames from the
shot, then eased back over 14.")
(defparameter *br-kata-moves* '(:br-s-j1 :br-s-j2 :br-s-j3 :br-s-k1 :br-s-k2 :br-s-k3)
  "The base stance's melee openers (R15): the gun-kata's point-blank shots (J, the first three) and the rifle swung (K): a
blast / an impact at the muzzle from the hit frame S (%BR-KATA-LOOK).")
(declaim (type f32vec *br-mz* *br-gp* *br-armed*))
(defvar *br-mz* (make-f32 3) "Scratch: Diagramm's muzzle (a joint point of the drawn body) ...")
(defvar *br-gp* (make-f32 3) "... and its grip.")
(defvar *br-armed* (make-f32 2) "Per side: 1 while a gun-kata shot's crack is still to sound (its move before S), else 0.")
(declaim (type f32vec *br-hit-at*))
(defvar *br-hit-at* (make-f32 18)
  "Per side (9 each): where a swing's struck end was on its hit frame S ([0..2]) and on S + 1 ([3..5], K3's floor): the
impact stays there while the rifle swings on (%BR-KATA-LOOK); [6..8] the muzzle on the snipe's shot frame (%BR-SNIPE-LOOK:
its line stays there while the kick throws the rifle up).")
(defmacro %br-barrel! (jm)
  "Diagramm's muzzle and grip of the posed joints JM into *BR-MZ* / *BR-GP* (0 B)."
  `(let ((%jm ,jm))
     (joint-point! *br-mz* %jm (ji :weapon-r) 0f0 0f0 -1.75f0)
     (joint-point! *br-gp* %jm (ji :weapon-r) 0f0 0f0 0f0)))

(defun-fast br-charge (e rdt)
  "His kit's :charge hook (draw.lisp: while a move of his base form, Diagramm in hand, is held; R15, DUEL_LILLE_V3 §19,
「蓄力狙擊」): the snipe's charge tells by the frames held (FIGHTER-HOLD; the levels at *BR-W-L-LEVELS*' 20 / 40), drawn after
his draw hook (BR-DRAW: his place and the opponent's, *BR-AT*): on the opponent, at his chest on the line, the reticle's
four brackets closing in over each level (ink at level 1, jade from 2, turned 45 deg a level; from level 2 a ring of ticks
round them; locked at the top with a white heart); the aim light from the muzzle to that point (level 1 a faint grey line,
2 jade, 3 the jade line on to the wall with a white core); light gathering into the muzzle (5 / 8 / 11 motes) and its glow
from level 2; the scope's glint at his eye, bigger by the level; the level-up flash (a white ball and a star burst at the
muzzle, a ring of shards off the reticle; bigger at 3) over 10 frames from the level's frame held. Cosmetic. 0 B."
  (declare (single-float rdt))
  (setf rdt 0f0)                                        ; (unused: the hook's signature)
  (let* ((f (fighter e)) (mv (fighter-move f)))
    (when (and mv (member (mv-name mv) *br-snipe-moves*))
      (let* ((h (fighter-hold f)) (lvs *br-w-l-levels*) (la (the fixnum (first lvs))) (lb (the fixnum (second lvs)))
             (lv (%br-l-level h)) (side (fighter-side f)) (jm (model-joints (model e))) (mz *br-mz*) (gp *br-gp*) (pa *pose-at*)
             (at *br-at*) (o (* 8 side)) (rt (camera-right *camera*)) (up (camera-upv *camera*)) (sc (aref *lb-v* 31))
             (pal (if (= lv 1) +pal-ink+ +pal-jade+)) (fl (i->f (mod (floor h 2) 2)))
             (p (f-clamp (/ (i->f (- h (case lv (1 0) (2 la) (t lb)))) (i->f (- lb la))) 0f0 1f0))
             (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw)))
             (dist (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
             (tx (+ (aref pa 0) (* dist ux))) (ty (+ (aref pa 1) (* 1.25f0 sc))) (tz (+ (aref pa 2) (* dist uz))))
        (declare (fixnum h la lb lv side o) (type f32vec jm mz gp pa at rt up)
                 (single-float sc pal fl p yaw ux uz dist tx ty tz))
        (%br-barrel! jm)
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2))
               (dx (- mx (aref gp 0))) (dy (- my (aref gp 1))) (dz (- mzz (aref gp 2))) (dl (f-max 1f-4 (f-hypot dx dy dz)))
               (bx (/ dx dl)) (by (/ dy dl)) (bz (/ dz dl)))
          (declare (single-float mx my mzz dx dy dz dl bx by bz))
          ;; the reticle on him: four brackets closing in, a ring of ticks from level 2, the lock
          (let ((r (* sc (+ 0.42f0 (* 0.9f0 (- 1f0 (%lb-ss p)))))) (rot (* 0.785f0 (i->f (1- lv)))))
            (declare (single-float r rot))
            (dotimes (q 4)
              (let* ((an (+ rot (* 1.5708f0 (i->f q)))) (cq (f-cos an)) (sq (f-sin an))
                     (ox (+ (* cq (aref rt 0)) (* sq (aref up 0)))) (oy (+ (* cq (aref rt 1)) (* sq (aref up 1))))
                     (oz (+ (* cq (aref rt 2)) (* sq (aref up 2)))))
                (declare (single-float an cq sq ox oy oz))
                (fx-shard (+ tx (* r ox)) (+ ty (* r oy)) (+ tz (* r oz)) (- ox) (- oy) (- oz) (* sc 0.5f0) (* sc 0.1f0) 0.03f0
                          (+ 710f0 (i->f q)) pal 0.97f0 :push 0.9f0)))
            (when (>= lv 2)
              (let ((rr (+ r (* sc 0.3f0))))
                (declare (single-float rr))
                (dotimes (q 12)
                  (let* ((an (+ (* 0.5236f0 (i->f q)) (* 0.02f0 (i->f h)))) (cq (f-cos an)) (sq (f-sin an))
                         (ox (+ (* cq (aref rt 0)) (* sq (aref up 0)))) (oy (+ (* cq (aref rt 1)) (* sq (aref up 1))))
                         (oz (+ (* cq (aref rt 2)) (* sq (aref up 2)))))
                    (declare (single-float an cq sq ox oy oz))
                    (fx-shard (+ tx (* rr ox)) (+ ty (* rr oy)) (+ tz (* rr oz)) (- sq) cq 0f0 (* sc 0.2f0) (* sc 0.045f0) 0.02f0
                              (+ 714f0 (i->f q)) +pal-jade+ (if (= lv 3) 0.95f0 0.75f0) :push 0.9f0)))))
            (when (and (= lv 3) (>= p 1f0))
              (fx-disc tx ty tz (* sc (+ 0.12f0 (* 0.04f0 fl))) 0.03f0 727f0 +pal-hit+ 0.95f0 :push 0.95f0)
              (fx-disc tx ty tz (* sc 0.24f0) 0.05f0 728f0 +pal-jade+ 0.75f0 :push 0.92f0)))
          ;; the aim light, the muzzle to him (level 3: on to the wall)
          (let* ((wl (%lb-wall mx mzz ux uz)) (len (if (= lv 3) (f-min wl 31f0) (f-max 0.4f0 (- dist 0.3f0)))))
            (declare (single-float wl len))
            (toon-ribbon ((+ mx (* 0.1f0 ux)) my (+ mzz (* 0.1f0 uz))) ((* (- len 0.1f0) ux) (- ty my) (* (- len 0.1f0) uz))
                         ((* sc (case lv (1 0.014f0) (2 0.026f0) (t 0.045f0))) (* sc (case lv (1 0.01f0) (2 0.018f0) (t 0.03f0))))
                         :heat (1f0 0.8f0) :seed -730f0 :wob 0.01f0 :pal (if (= lv 1) +pal-steel+ +pal-jade+)
                         :k (* (if (= lv 1) 0.55f0 0.9f0) (+ 0.8f0 (* 0.2f0 fl))) :k1 (if (= lv 1) 0.35f0 0.7f0) :segs 2)
            (when (= lv 3)
              (toon-ribbon ((+ mx (* 0.1f0 ux)) my (+ mzz (* 0.1f0 uz))) ((* (- len 0.1f0) ux) (- ty my) (* (- len 0.1f0) uz))
                           ((* sc 0.01f0) (* sc 0.007f0)) :heat (1f0 1f0) :seed -731f0 :wob 0f0 :pal +pal-hit+ :k 0.9f0 :k1 0.7f0
                           :segs 2)))
          ;; light gathering into the muzzle, its glow
          (dotimes (i (+ 2 (* 3 lv)))
            (let* ((fi (i->f i)) (ph (/ (i->f (mod (+ h (* 5 i)) 16)) 16f0)) (an (+ (* 2.39996f0 fi) (* 0.11f0 (i->f h))))
                   (r (* sc (- 1.2f0 (* 1.1f0 ph)))) (ca (* r (f-cos an))) (sa (* r (f-sin an))) (fw (* 0.5f0 r))
                   (k (* (%lb-ss (* 4f0 ph)) (- 1f0 (%lb-ss (/ (- ph 0.82f0) 0.18f0))))))
              (declare (single-float fi ph an r ca sa fw k))
              (fx-star (+ mx (* ca (aref rt 0)) (* sa (aref up 0)) (* fw bx)) (+ my (* ca (aref rt 1)) (* sa (aref up 1)) (* fw by))
                       (+ mzz (* ca (aref rt 2)) (* sa (aref up 2)) (* fw bz)) 0.03f0 (* sc 0.12f0) 4 (* 0.5f0 fi) 0f0 0f0 0.05f0
                       (+ 700f0 fi) pal (* 0.95f0 k) :push 0.4f0)))
          (when (>= lv 2)
            (fx-disc mx my mzz (* sc (+ 0.11f0 (* 0.08f0 (i->f (- lv 2))) (* 0.025f0 fl))) 0.1f0 716f0 +pal-jade+ 0.85f0 :push 0.4f0)
            (when (= lv 3) (fx-disc mx my mzz (* sc (+ 0.06f0 (* 0.015f0 fl))) 0.05f0 718f0 +pal-hit+ 0.95f0 :push 0.45f0)))
          ;; the scope's glint at his eye
          (joint-point! gp jm (ji :head) 0.035f0 0.05f0 -0.12f0)
          (let ((g (* sc (case lv (1 0.14f0) (2 0.28f0) (t 0.5f0)) (+ 0.8f0 (* 0.2f0 (i->f (mod h 3)))))))
            (declare (single-float g))
            (fx-star (aref gp 0) (aref gp 1) (aref gp 2) (* 0.07f0 g) g 4 (+ 0.785f0 (* 0.03f0 (i->f h))) 0f0 0f0 0.02f0 717f0
                     +pal-hit+ 0.95f0 :push 0.6f0))
          ;; the level-up flash
          (let ((u (cond ((<= la h (+ la 9)) (i->f (- h la))) ((<= lb h (+ lb 9)) (i->f (- h lb))) (t -1f0))))
            (declare (single-float u))
            (when (>= u 0f0)
              (let* ((t1 (/ u 10f0)) (k (- 1f0 t1)) (big (if (>= h lb) 1.6f0 1f0)))
                (declare (single-float t1 k big))
                (when (< u 2f0) (fx-disc mx my mzz (* sc big 0.45f0) 0.05f0 735f0 +pal-hit+ (- 0.98f0 (* 0.3f0 u)) :push 0.5f0))
                (fx-star mx my mzz (* sc 0.15f0) (* sc big (+ 0.6f0 (* 1.2f0 (%lb-ss t1)))) (if (>= h lb) 12 8) (* 0.3f0 (i->f h))
                         0f0 0f0 0.1f0 736f0 +pal-jade+ k :push 0.45f0)
                (fx-star mx my mzz (* sc 0.08f0) (* sc big (+ 0.3f0 (* 0.8f0 (%lb-ss t1)))) 6 0.2f0 0f0 0f0 0.08f0 737f0 +pal-hit+ k
                         :push 0.5f0)
                (let ((rr (* sc big (+ 0.5f0 (* 1.1f0 (%lb-ss t1))))))   ; (a ring of shards off the reticle)
                  (declare (single-float rr))
                  (dotimes (q 8)
                    (let* ((an (+ 0.39f0 (* 0.785f0 (i->f q)))) (cq (f-cos an)) (sq (f-sin an))
                           (ox (+ (* cq (aref rt 0)) (* sq (aref up 0)))) (oy (+ (* cq (aref rt 1)) (* sq (aref up 1))))
                           (oz (+ (* cq (aref rt 2)) (* sq (aref up 2)))))
                      (declare (single-float an cq sq ox oy oz))
                      (fx-shard (+ tx (* rr ox)) (+ ty (* rr oy)) (+ tz (* rr oz)) ox oy oz (* sc 0.36f0) (* sc 0.07f0) 0.04f0
                                (+ 740f0 (i->f q)) +pal-jade+ k :push 0.9f0)))))))))))
  nil)

(defun-fast %br-snipe-look (e f side mv)
  "The snipe's shot (a move in *BR-SNIPE-MOVES*, its main phase) by its level, from the shot (S) for 18 frames, at the muzzle
of the drawn body on the shot frame (*BR-HIT-AT*) and along his facing (*POSE-AT*): level 1 a short point-blank burst (a white flash, a jade star, a cone of
sparks, smoke); level 2 a bigger flash and a tracer, a jade comet with a white core running the 12 m in 3 frames; level 3
the 萬物貫通 muzzle blast (a big white flash, a jade star of 12, an ink one), a jade band with a white core along the line to
the wall thinning away, rings of shards bursting off it at 1.5 / 5 / 10 m, smoke. The line itself is LB-LOOK's. R16 (DUEL_LILLE_V3
§20, 「增加第 1 階 L 射擊的前搖」): before the shot, from the release (level 1's 16 frames, the copies' 8), the charge's aim light
held on him by the level and the scope's glint growing, flaring with a white tick at the muzzle over the last 3 frames (the
squeeze). 0 B."
  (declare (fixnum side))
  (let* ((a (- (the fixnum (fighter-sf f)) (the fixnum (mv-s mv)))) (lv (1+ (the fixnum (position (mv-name mv) *br-snipe-moves*)))))
    (declare (fixnum a lv))
    (when (< a 0)                                       ; R16 (§20): the wind-up from the release to the crack
      (let* ((jm (model-joints (model e))) (mz *br-mz*) (gp *br-gp*) (pa *pose-at*) (at *br-at*) (o (* 8 side))
             (sc (aref *lb-v* 31)) (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (s (the fixnum (mv-s mv)))
             (dist (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
             (ty (+ (aref pa 1) (* 1.25f0 sc))) (fl (i->f (mod (floor (the fixnum (fighter-sf f)) 2) 2)))
             (u (f-clamp (/ (i->f (+ s a)) (i->f (max 1 s))) 0f0 1f0))   ; (0 at the release, 1 at the crack)
             (q (if (>= a -3) (/ (i->f (+ a 4)) 3f0) 0f0)))              ; (the squeeze: the last 3 frames)
        (declare (type f32vec jm mz gp pa at) (fixnum o s) (single-float sc yaw ux uz dist ty fl u q))
        (%br-barrel! jm)
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2))
               (wl (%lb-wall mx mzz ux uz)) (len (if (= lv 3) (f-min wl 31f0) (f-max 0.4f0 (- dist 0.3f0)))))
          (declare (single-float mx my mzz wl len))
          ;; the aim light held on him (the charge's, by the level), steadier as the crack nears
          (toon-ribbon ((+ mx (* 0.1f0 ux)) my (+ mzz (* 0.1f0 uz))) ((* (- len 0.1f0) ux) (- ty my) (* (- len 0.1f0) uz))
                       ((* sc (case lv (1 0.014f0) (2 0.026f0) (t 0.045f0))) (* sc (case lv (1 0.01f0) (2 0.018f0) (t 0.03f0))))
                       :heat (1f0 0.8f0) :seed -732f0 :wob 0.01f0 :pal (if (= lv 1) +pal-steel+ +pal-jade+)
                       :k (* (if (= lv 1) 0.55f0 0.9f0) (+ 0.85f0 (* 0.15f0 (if (> q 0f0) 1f0 fl)))) :k1 (if (= lv 1) 0.35f0 0.7f0) :segs 2)
          ;; the scope's glint at his eye, growing over the wind-up and flaring on the squeeze
          (joint-point! gp jm (ji :head) 0.035f0 0.05f0 -0.12f0)
          (let ((g (* sc (+ (case lv (1 0.12f0) (2 0.24f0) (t 0.42f0)) (* 0.1f0 u) (* 0.35f0 q)))))
            (declare (single-float g))
            (fx-star (aref gp 0) (aref gp 1) (aref gp 2) (* 0.07f0 g) g 4 (+ 0.785f0 (* 0.4f0 q)) 0f0 0f0 0.02f0 (+ 881f0 (i->f side))
                     +pal-hit+ 0.95f0 :push 0.6f0))
          (when (> q 0f0)                               ; (the squeeze: a white tick at the muzzle)
            (fx-disc mx my mzz (* sc (+ 0.04f0 (* 0.05f0 q))) 0.05f0 (+ 883f0 (i->f side)) +pal-hit+ (* 0.9f0 q) :push 0.5f0)))))
    (when (<= 0 a 17)
      (let* ((jm (model-joints (model e))) (mz *br-mz*) (pa *pose-at*) (sc (aref *lb-v* 31))
             (yaw (aref pa 3)) (ux (- (f-sin yaw))) (uz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
             (fa (i->f a)) (sd (+ 750f0 (* 40f0 (i->f side)))))
        (declare (type f32vec jm mz pa) (single-float sc yaw ux uz rx rz fa sd))
        (%br-barrel! jm)
        (let ((ha *br-hit-at*) (ho (+ 6 (* 9 side))))   ; (the shot's muzzle kept from S: the kick throws the rifle up)
          (declare (type f32vec ha) (fixnum ho))
          (when (= a 0) (setf (aref ha ho) (aref mz 0) (aref ha (+ ho 1)) (aref mz 1) (aref ha (+ ho 2)) (aref mz 2)))
          (setf (aref mz 0) (aref ha ho) (aref mz 1) (aref ha (+ ho 1)) (aref mz 2) (aref ha (+ ho 2))))
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2)) (big (case lv (1 1f0) (2 1.35f0) (t 2f0))))
          (declare (single-float mx my mzz big))
          (when (< a 2)                                   ; the flash
            (fx-disc (+ mx (* 0.15f0 ux)) my (+ mzz (* 0.15f0 uz)) (* sc big 0.26f0) 0.05f0 sd +pal-hit+ (- 0.98f0 (* 0.3f0 fa))
                     :push 0.5f0)
            (fx-star mx my mzz (* sc 0.1f0) (* sc big 0.55f0) (if (= lv 3) 12 7) (* 0.7f0 (i->f lv)) 0f0 0f0 0.12f0 (+ sd 1f0)
                     +pal-jade+ 0.95f0 :push 0.4f0)
            (when (>= lv 2)
              (fx-star mx my mzz (* sc 0.14f0) (* sc big 0.75f0) 9 0.3f0 0f0 0f0 0.15f0 (+ sd 2f0) +pal-ink+ 0.9f0 :push 0.3f0)))
          (when (< a 4)                                   ; the sparks thrown forward
            (dotimes (i (+ 3 (* 2 lv)))
              (let* ((fi (i->f i)) (sp (* 0.6f0 (- (hash01 fi (+ sd 3f0)) 0.5f0))) (el (* 0.5f0 (- (hash01 fi (+ sd 4f0)) 0.5f0)))
                     (d (* big (+ 0.3f0 (* 0.35f0 fa (+ 0.6f0 (hash01 fi (+ sd 5f0)))))))
                     (vx (+ ux (* sp rx))) (vz (+ uz (* sp rz))))
                (declare (single-float fi sp el d vx vz))
                (fx-shard (+ mx (* d vx)) (+ my (* d el)) (+ mzz (* d vz)) vx el vz (* sc 0.22f0 big) (* sc 0.025f0) 0.05f0
                          (+ sd 10f0 fi) (if (= lv 1) +pal-hit+ +pal-jade+) (- 1f0 (* 0.22f0 fa)) :push 0.3f0))))
          (when (and (= lv 2) (< a 4))                    ; the tracer
            (let* ((wl (%lb-wall mx mzz ux uz)) (len (f-min wl 12f0)) (hd (f-min len (+ 0.6f0 (* 5.5f0 (+ fa 1f0)))))
                   (tl (f-max 0.6f0 (- (+ 0.6f0 (* 5.5f0 (+ fa 1f0))) 4.5f0))))
              (declare (single-float wl len hd tl))
              (when (> hd tl)
                (%streak (+ mx (* tl ux)) my (+ mzz (* tl uz)) (+ mx (* hd ux)) my (+ mzz (* hd uz)) 0.1f0 +pal-jade+ 0.95f0 (+ sd 20f0))
                (%streak (+ mx (* tl ux)) my (+ mzz (* tl uz)) (+ mx (* hd ux)) my (+ mzz (* hd uz)) 0.04f0 +pal-hit+ 0.95f0 (+ sd 21f0)))))
          (when (= lv 3)                                  ; the 萬物貫通 band and its rings
            (let* ((wl (%lb-wall mx mzz ux uz)) (len (f-min wl 31f0)) (w (* sc (+ 0.03f0 (* 0.24f0 (- 1f0 (%lb-ss (/ fa 14f0)))))))
                   (k (- 1f0 (%lb-ss (/ (- fa 8f0) 9f0)))))
              (declare (single-float wl len w k))
              (toon-ribbon ((+ mx (* 0.2f0 ux)) my (+ mzz (* 0.2f0 uz))) ((* (- len 0.2f0) ux) 0f0 (* (- len 0.2f0) uz)) (w (* 0.7f0 w))
                           :heat (1f0 0.8f0) :seed (- -760f0 fa) :wob 0.03f0 :pal +pal-jade+ :k (* 0.98f0 k) :k1 (* 0.85f0 k) :segs 3)
              (when (< a 7)
                (toon-ribbon ((+ mx (* 0.2f0 ux)) my (+ mzz (* 0.2f0 uz))) ((* (- len 0.2f0) ux) 0f0 (* (- len 0.2f0) uz))
                             ((* 0.35f0 w) (* 0.25f0 w)) :heat (1f0 1f0) :seed (- -761f0 fa) :wob 0.02f0 :pal +pal-hit+
                             :k 0.95f0 :k1 0.85f0 :segs 3))
              (when (< a 9)
                (dotimes (j 3)
                  (let* ((dd (case j (0 1.5f0) (1 5f0) (t 10f0))) (rr (* sc (+ 0.25f0 (* 0.16f0 fa)))) (kk (- 1f0 (/ fa 9f0))))
                    (declare (single-float dd rr kk))
                    (when (< dd len)
                      (dotimes (q 8)
                        (let* ((an (+ (* 0.785f0 (i->f q)) (* 0.4f0 (i->f j)))) (cx (f-cos an)) (sy (f-sin an)))
                          (declare (single-float an cx sy))
                          (fx-shard (+ mx (* dd ux) (* rr cx rx)) (+ my (* rr sy)) (+ mzz (* dd uz) (* rr cx rz)) (* cx rx) sy (* cx rz)
                                    (* sc 0.2f0) (* sc 0.03f0) 0.04f0 (+ sd 30f0 (i->f q) (* 8f0 (i->f j))) +pal-jade+ (* 0.9f0 kk)
                                    :push 0.3f0)))))))))
          (when (<= 2 a 16)                               ; the smoke off the muzzle
            (let ((u (/ (- fa 2f0) 14f0)))
              (declare (single-float u))
              (dotimes (i lv)
                (let ((fi (i->f i)))
                  (declare (single-float fi))
                  (fx-disc (+ mx (* 0.2f0 fi ux)) (+ my (* 0.4f0 u) (* 0.08f0 fi)) (+ mzz (* 0.2f0 fi uz)) (* sc big (+ 0.08f0 (* 0.14f0 u)))
                           0.25f0 (+ sd 50f0 fi) +pal-smoke+ (* 0.7f0 (- 1f0 u)) :push 0.2f0))))))))
    nil))

(defun-fast %br-kata-look (e f side mv)
  "The base stance's melee openers (a move in *BR-KATA-MOVES*, its main phase), from the hit frame S at the muzzle of the
drawn body: J (槍鬥術) the point-blank shot: a white flash, an ink star round a jade one, sparks thrown along the barrel,
smoke rising, and the gun's crack once (armed before S: *BR-ARMED*); K (槍身重揮) the struck end's impact: an ink star round
a white one and ink shards over 3 frames, and K3's smash into the floor: dust puffs, a ring and chips where the muzzle meets
it. 0 B (but the one crack a shot)."
  (declare (fixnum side))
  (let* ((sf (fighter-sf f)) (s (mv-s mv)) (a (- sf s)) (pos (the fixnum (position (mv-name mv) *br-kata-moves*))) (gun (< pos 3)))
    (declare (fixnum sf s a pos))
    (if (< a 0)
        (setf (aref *br-armed* side) 1f0)
        (when (and gun (> (aref *br-armed* side) 0.5f0))
          (setf (aref *br-armed* side) 0f0)
          (sfx-on :lb-crack e)))
    (when (<= 0 a 14)
      (let* ((jm (model-joints (model e))) (mz *br-mz*) (gp *br-gp*) (sc (aref *lb-v* 31)) (fa (i->f a))
             (sd (+ 800f0 (* 40f0 (i->f side)) (* 7f0 (i->f pos)))))
        (declare (type f32vec jm mz gp) (single-float sc fa sd))
        (%br-barrel! jm)
        (let* ((mx (aref mz 0)) (my (aref mz 1)) (mzz (aref mz 2))
               (dx (- mx (aref gp 0))) (dy (- my (aref gp 1))) (dz (- mzz (aref gp 2))) (dl (f-max 1f-4 (f-hypot dx dy dz)))
               (bx (/ dx dl)) (by (/ dy dl)) (bz (/ dz dl)))
          (declare (single-float mx my mzz dx dy dz dl bx by bz))
          (if gun
              (progn
                (when (< a 2)                             ; the point-blank blast
                  (fx-disc (+ mx (* 0.12f0 bx)) (+ my (* 0.12f0 by)) (+ mzz (* 0.12f0 bz)) (* sc 0.3f0) 0.05f0 sd +pal-hit+
                           (- 0.98f0 (* 0.3f0 fa)) :push 0.5f0)
                  (fx-star mx my mzz (* sc 0.12f0) (* sc 0.62f0) 7 (* 0.9f0 (i->f pos)) 0f0 0f0 0.15f0 (+ sd 1f0) +pal-ink+ 0.92f0
                           :push 0.35f0)
                  (fx-star mx my mzz (* sc 0.08f0) (* sc 0.4f0) 6 (* 0.4f0 (i->f pos)) 0f0 0f0 0.1f0 (+ sd 2f0) +pal-jade+ 0.95f0
                           :push 0.45f0))
                (when (< a 4)                             ; sparks along the barrel
                  (dotimes (i 4)
                    (let* ((fi (i->f i)) (d (+ 0.2f0 (* 0.3f0 fa (+ 0.6f0 (hash01 fi (+ sd 3f0))))))
                           (ox (* 0.3f0 (- (hash01 fi (+ sd 4f0)) 0.5f0))) (oy (* 0.3f0 (- (hash01 fi (+ sd 5f0)) 0.5f0))))
                      (declare (single-float fi d ox oy))
                      (fx-shard (+ mx (* d bx) ox) (+ my (* d by) oy) (+ mzz (* d bz)) bx by bz (* sc 0.2f0) (* sc 0.022f0) 0.05f0
                                (+ sd 10f0 fi) +pal-hit+ (- 1f0 (* 0.22f0 fa)) :push 0.3f0))))
                (when (<= 1 a 12)                         ; the smoke rising off it
                  (let ((u (/ (- fa 1f0) 11f0)))
                    (declare (single-float u))
                    (dotimes (i 2)
                      (let ((fi (i->f i)))
                        (declare (single-float fi))
                        (fx-disc (+ mx (* 0.15f0 fi bx)) (+ my (* 0.35f0 u) (* 0.06f0 fi)) (+ mzz (* 0.15f0 fi bz))
                                 (* sc (+ 0.07f0 (* 0.12f0 u))) 0.25f0 (+ sd 20f0 fi) +pal-smoke+ (* 0.65f0 (- 1f0 u)) :push 0.2f0))))))
              (let* ((ha *br-hit-at*) (ho (* 9 side)))   ; (the struck point kept from S, the floor's from S + 1)
                (declare (type f32vec ha) (fixnum ho))
                (when (= a 0) (setf (aref ha ho) mx (aref ha (+ ho 1)) my (aref ha (+ ho 2)) mzz))
                (when (= a 1) (setf (aref ha (+ ho 3)) mx (aref ha (+ ho 4)) my (aref ha (+ ho 5)) mzz))
               (let ((ix (aref ha ho)) (iy (aref ha (+ ho 1))) (iz (aref ha (+ ho 2))) (gx (aref ha (+ ho 3))) (gz (aref ha (+ ho 5))))
                (declare (single-float ix iy iz gx gz))
                (when (< a 3)                             ; the struck end's impact
                  (let ((k (- 1f0 (* 0.28f0 fa))))
                    (declare (single-float k))
                    (fx-star ix iy iz (* sc 0.16f0) (* sc (+ 0.6f0 (* 0.2f0 fa))) 9 (* 0.7f0 (i->f pos)) 0f0 0f0 0.15f0 (+ sd 1f0)
                             +pal-ink+ k :push 0.35f0)
                    (when (< a 2)
                      (fx-star ix iy iz (* sc 0.1f0) (* sc 0.38f0) 7 0.2f0 0f0 0f0 0.1f0 (+ sd 2f0) +pal-hit+ 0.95f0 :push 0.45f0))
                    (let ((rt (camera-right *camera*)) (up (camera-upv *camera*)))   ; (ink chips thrown out round it)
                      (declare (type f32vec rt up))
                      (dotimes (i 5)
                        (let* ((fi (i->f i)) (an (+ (* 1.2566f0 fi) (* 0.5f0 (hash01 fi (+ sd 3f0))))) (d (* sc (+ 0.3f0 (* 0.25f0 fa))))
                               (cx (f-cos an)) (sy (f-sin an))
                               (ox (+ (* cx (aref rt 0)) (* sy (aref up 0)))) (oy (+ (* cx (aref rt 1)) (* sy (aref up 1))))
                               (oz (+ (* cx (aref rt 2)) (* sy (aref up 2)))))
                          (declare (single-float fi an d cx sy ox oy oz))
                          (fx-shard (+ ix (* d ox)) (+ iy (* d oy)) (+ iz (* d oz)) ox oy oz (* sc 0.22f0) (* sc 0.04f0) 0.05f0
                                    (+ sd 10f0 fi) +pal-ink+ k :push 0.3f0))))))
                (when (and (= pos 5) (<= 1 a 14))         ; K3: the smash into the floor
                  (let* ((pa *pose-at*) (gy (aref pa 1)) (u (/ (- fa 1f0) 13f0)) (k (- 1f0 (%lb-ss u))))
                    (declare (type f32vec pa) (single-float gy u k))
                    (%tring gx gy gz (* sc (+ 0.3f0 (* 0.9f0 (%lb-ss (* 2f0 u))))) (* sc 0.05f0) +pal-ink+ (* 0.8f0 k) (+ sd 30f0))
                    (dotimes (i 5)
                      (let* ((fi (i->f i)) (an (+ (* 1.2566f0 fi) 0.3f0)) (r (* sc (+ 0.2f0 (* 0.7f0 u)))))
                        (declare (single-float fi an r))
                        (fx-disc (+ gx (* r (f-cos an))) (+ gy 0.1f0 (* 0.5f0 u)) (+ gz (* r (f-sin an))) (* sc (+ 0.1f0 (* 0.2f0 u)))
                                 0.25f0 (+ sd 40f0 fi) +pal-dust+ (* 0.75f0 k) :push 0.2f0)))
                    (when (< a 6)
                      (dotimes (i 4)
                        (let* ((fi (i->f i)) (an (+ (* 1.5708f0 fi) 0.6f0)) (h (* 0.5f0 fa (- 1.2f0 (* 0.15f0 fa)))))
                          (declare (single-float fi an h))
                          (fx-shard (+ gx (* 0.3f0 fa (f-cos an))) (+ gy 0.05f0 (f-max 0f0 h)) (+ gz (* 0.3f0 fa (f-sin an)))
                                    (f-cos an) 1f0 (f-sin an) (* sc 0.14f0) (* sc 0.05f0) 0.1f0 (+ sd 50f0 fi) +pal-ink+ 0.9f0
                                    :push 0.2f0))))))))))))
    nil))

;; R11 (DUEL_LILLE_V3 §16, the user 2026-10-11 on v66: 「現在的架式 J > L 看起來依舊是射擊？」): the J route's L L rebuilt as
;; whips. R10's lash was a straight line from his chest to the opponent for 3 frames (it read as a beam, a shot). Now the
;; striking front wing (the owl: its claw) runs on into a long tapered lash, a thick-to-thin chain of ribbon segments with
;; small blade segments along its root two thirds (the wing's glass carried on, a snake sword), that is wound up behind him and
;; swung through a big arc with overlapping action (each point of it follows the swing's angle a little later than the one
;; before it: the base leads, the wave runs down it, the tip trails and snaps), cracks on him on the hit frame S (the tip
;; pulled onto the point of his line at the opponent's distance, a burst there), then falls slack and is drawn back in.
;; Three different lashes: JL1 a flat swing from his right, JL2 a backhand from high on his left down across him, JL3 an
;; overhead crack straight down (the longest, the heaviest). Draw-time only, read off the clip's frame (the hit is still the
;; 31 m line, barro.lisp BR-SHOT-FIRE; the clips' own stretch *BR-W-STRETCH* is what the host tip test reads).
(defparameter *br-whip-max* 31.0 "R10 (§15): the whip reaches at most this far (m: the line's 31 m, barro.lisp *BR-X-LEN*) ...")
(defparameter *br-whip-up* 1.1 "... its crack this high over his floor (m: the opponent's chest).")
(defun %br-lash-keys (keys)
  "KEYS ((frame value) ...) as an f32vec (frame value ...)."
  (coerce (mapcar #'f32 (apply #'append keys)) 'f32vec))
(defparameter *br-lash-n* 16 "The lash's segments (*BR-LASH-P* holds its N + 1 points).")
(defparameter *br-lashes*
  '((:br-e-jf1 :g 0 :plane (1.0 0.25) :lag 1.6 :swing 3.2 :w 0.1 :crack 1.0
     :theta ((0 35) (2.5 120) (4 150) (5 140) (5.6 100) (6.4 0) (7.2 -35) (8 -50) (9.5 -72) (12 -80) (16 -40) (20 20) (24 35))
     :wind ((0 0.08) (2 0.45) (4 0.85) (5.5 1) (11 1) (17 0.45) (24 0))
     :reach ((0 0) (6.5 0) (8 1) (10.5 1) (16 0))
     :sag ((0 0.4) (3 0.12) (5 0) (10.5 0) (13 0.55) (19 0.95) (24 1))
     :wave ((0 0.15) (4 0.05) (5.5 0) (10.5 0) (13 0.45) (19 0.3) (24 0.1)))
    (:br-e-jf2 :g 1 :plane (-0.75 0.66) :lag 1.6 :swing 3.2 :w 0.1 :crack 1.0
     :theta ((0 -20) (2.5 80) (4 140) (5 140) (5.6 100) (6.4 0) (7.2 -35) (8 -50) (9.5 -70) (12 -75) (16 -40) (20 0) (24 15))
     :wind ((0 0.08) (2 0.45) (4 0.85) (5.5 1) (11 1) (17 0.45) (24 0))
     :reach ((0 0) (6.5 0) (8 1) (10.5 1) (16 0))
     :sag ((0 0.4) (3 0.12) (5 0) (10.5 0) (13 0.55) (19 0.95) (24 1))
     :wave ((0 0.15) (4 0.05) (5.5 0) (10.5 0) (13 0.45) (19 0.3) (24 0.1)))
    (:br-e-jf3 :g 0 :plane (0.5 0.87) :lag 2.0 :swing 3.8 :w 0.12 :crack 1.4
     :theta ((0 -10) (2.5 90) (3.8 150) (4.6 160) (5.3 110) (6 0) (6.8 -30) (8 -42) (10 -50) (13 -48) (18 -25) (22 -5) (26 0))
     :wind ((0 0.1) (2.5 0.6) (4.5 1) (12 1) (19 0.4) (26 0))
     :reach ((0 0) (6.5 0) (8 1) (11 1) (18 0))
     :sag ((0 0.3) (3 0.1) (4.5 0) (11 0) (14 0.7) (20 1) (26 1))
     :wave ((0 0.1) (4 0) (11 0) (14 0.5) (21 0.3) (26 0.1))))
  "R11 (DUEL_LILLE_V3 §16): the J route's L L whips by clip (the owl's :br-oe-jf* the same keys on its claws): :g the
striking wing (0 right, 1 left); :plane the swing's side axis (his right, up) squared to the line to the target (the
angle 0 points at the crack's point, + toward this axis); :lag the frames the tip's angle trails the base's (s^1.4 along it:
the overlapping action); :swing its length while wound up and swinging (m; at the crack it is pulled onto the point, as
long as the distance); :w its half-width at the root (m, to 0.1 of it at the tip); :crack the burst's size. The keys,
by the clip's frame (S 8): :theta the base's swing angle (degrees, a C1 spline through them), :wind its share of the swing
length, :reach the share of the rest of the distance (the lash shot out to him on the crack), :sag its droop (slack),
:wave a wave running down it, out of the swing's plane (slack).")
(declaim (type list *br-lash-v*))
(defparameter *br-lash-v*
  (loop for (c . p) in *br-lashes*
        for v = (vector (let ((h (make-f32 10)))
                          (setf (aref h 0) (f32 (getf p :g)) (aref h 1) (f32 (first (getf p :plane)))
                                (aref h 2) (f32 (second (getf p :plane))) (aref h 3) (f32 (getf p :lag))
                                (aref h 4) (f32 (getf p :swing)) (aref h 5) 8f0 (aref h 6) (f32 (getf p :w))
                                (aref h 8) (f32 (getf p :crack)))
                          h)
                        (%br-lash-keys (getf p :theta)) (%br-lash-keys (getf p :wind)) (%br-lash-keys (getf p :reach))
                        (%br-lash-keys (getf p :sag)) (%br-lash-keys (getf p :wave)))
        collect (cons c v)
        collect (cons (intern (concatenate 'string "BR-OE-" (subseq (symbol-name c) 5)) :keyword)   ; (the owl's twin)
                      (let ((v2 (copy-seq v)) (h (copy-seq (svref v 0))))
                        (setf (aref h 7) 1f0 (aref h 6) (* 1.1f0 (aref h 6)) (svref v2 0) h)
                        v2)))
  "*BR-LASHES* as (clip . #(header theta wind reach sag wave)), the header an f32vec [0] g, [1 2] the plane, [3] the lag,
[4] the swing length, [5] S, [6] the root half-width, [7] 1 = the owl (from the claw), [8] the crack's size; the owl's
twins (:br-oe-jf*) with its lash 1.1 x wider at the claw. Read without consing.")
(declaim (type f32vec *br-lv* *br-lash-p*))
(defvar *br-lv* (make-f32 48)
  "The whip's scratch (draw time): [0] the clip's frame; [1..3] the root H (the wing's drawn tip / the claw), [4..6] the
wing's direction there (unit), [7..9] A (unit, H -> the crack's point), [10..12] B (the swing's side axis, unit, square to
A), [13..15] A x B, [16..18] the crack's point T, [19] the stub length (the owl: its stretch), [20] the floor, [21] |T - H|;
[29] the chain's time, [30..35] the tip and the mid point a frame back, [36..41] half a frame back; [42] a key query's
time, [43] its value.")
(defvar *br-lash-p* (make-f32 (* 3 17)) "The lash's points (x y z each), root first.")
(defmacro %br-pow (x y) `(ffi:c-inline (,x ,y) (:float :float) :float "powf(fmaxf(#0,0.0f),#1)" :one-liner t))
(defun-fast %br-key! (kv herm)
  "*BR-LV* [43] = the keys KV (frame value ...) at the frame *BR-LV* [42], held past the ends: HERM 1 a C1 spline (the
tangents the neighbours' slope), else linear. 0 B."
  (declare (type f32vec kv) (fixnum herm))
  (let* ((lv *br-lv*) (tq (aref lv 42)) (n (floor (length kv) 2)) (r (aref kv 1)))
    (declare (type f32vec lv) (single-float tq r) (fixnum n))
    (cond ((<= tq (aref kv 0)) (setf r (aref kv 1)))
          ((>= tq (aref kv (* 2 (1- n)))) (setf r (aref kv (1- (* 2 n)))))
          (t (dotimes (i (1- n))
               (let ((t0 (aref kv (* 2 i))) (t1 (aref kv (+ 2 (* 2 i)))))
                 (declare (single-float t0 t1))
                 (when (and (<= t0 tq) (< tq t1))
                   (let* ((v0 (aref kv (1+ (* 2 i)))) (v1 (aref kv (+ 3 (* 2 i)))) (dt (f-max 1f-4 (- t1 t0)))
                          (u (/ (- tq t0) dt)))
                     (declare (single-float v0 v1 dt u))
                     (if (= herm 1)
                         (let* ((m0 (if (> i 0)
                                        (/ (- v1 (aref kv (- (* 2 i) 1))) (f-max 1f-4 (- t1 (aref kv (- (* 2 i) 2)))))
                                        (/ (- v1 v0) dt)))
                                (m1 (if (< (+ i 2) n)
                                        (/ (- (aref kv (+ 5 (* 2 i))) v0) (f-max 1f-4 (- (aref kv (+ 4 (* 2 i))) t0)))
                                        (/ (- v1 v0) dt)))
                                (u2 (* u u)) (u3 (* u2 u)))
                           (declare (single-float m0 m1 u2 u3))
                           (setf r (+ (* (+ (* 2f0 u3) (* -3f0 u2) 1f0) v0) (* (+ u3 (* -2f0 u2) u) dt m0)
                                      (* (+ (* -2f0 u3) (* 3f0 u2)) v1) (* (- u3 u2) dt m1))))
                         (setf r (+ v0 (* u (- v1 v0)))))))))))
    (setf (aref lv 43) r))
  nil)
(defun-fast %br-lash-chain! (ent)
  "The lash of the *BR-LASH-V* entry ENT at the chain's time *BR-LV* [29] into *BR-LASH-P* (*BR-LV* [1..21] set): its
length (the stub, the wound-up swing length by :wind, at most 1.15 x the distance to the crack's point but 1.8 m, the
rest of the way to him by :reach); each point s along it at the
swing angle the base had lag x s^1.4 frames before (the overlapping action), plus the slack's droop and wave; its first
fifth bent from the wing's own direction; kept off the floor; then, round the crack (S - 2.5 .. S + 4), turned and scaled
about its root so its tip lands on the crack's point T. 0 B."
  (declare (type simple-vector ent))
  (let* ((lv *br-lv*) (p *br-lash-p*) (hd (svref ent 0)) (n (the fixnum *br-lash-n*)) (tc (aref lv 29))
         (lag (aref hd 3)) (sw (f-min (aref hd 4) (f-max 1.8f0 (* 1.15f0 (aref *br-lv* 21))))) (s0 (aref hd 5)) (wind 0f0) (reach 0f0) (sag 0f0) (wave 0f0) (ln 0f0)
         (hx (aref lv 1)) (hy (aref lv 2)) (hz (aref lv 3)) (qx (aref lv 4)) (qy (aref lv 5)) (qz (aref lv 6))
         (ax (aref lv 7)) (ay (aref lv 8)) (az (aref lv 9)) (bx (aref lv 10)) (by (aref lv 11)) (bz (aref lv 12))
         (nx (aref lv 13)) (ny (aref lv 14)) (nz (aref lv 15)) (fl (+ (aref lv 20) 0.03f0)) (dd (aref lv 21)))
    (declare (type f32vec lv p hd) (fixnum n)
             (single-float tc lag sw s0 wind reach sag wave ln hx hy hz qx qy qz ax ay az bx by bz nx ny nz fl dd))
    (setf (aref lv 42) tc)
    (%br-key! (svref ent 2) 0) (setf wind (aref lv 43))
    (%br-key! (svref ent 3) 0) (setf reach (aref lv 43))
    (%br-key! (svref ent 4) 0) (setf sag (aref lv 43))
    (%br-key! (svref ent 5) 0) (setf wave (aref lv 43))
    (setf ln (+ (aref lv 19) (* wind sw) (* reach (f-max 0f0 (- dd sw)))))
    (setf (aref p 0) hx (aref p 1) hy (aref p 2) hz)
    (let ((step (/ ln (i->f n))) (px hx) (py hy) (pz hz))
      (declare (single-float step px py pz))
      (loop for i fixnum from 1 to n do
        (let* ((s (/ (i->f i) (i->f n))) (lg (* lag (%br-pow s 1.4f0))))
          (declare (single-float s lg))
          (setf (aref lv 42) (- tc lg))
          (%br-key! (svref ent 1) 1)
          (let* ((th (* 0.017453292f0 (aref lv 43))) (c (f-cos th)) (sn (f-sin th))
                 (wv (* wave s (f-sin (* 6.2831855f0 (- (* 1.3f0 s) (* 0.16666667f0 tc))))))
                 (sg (* sag (%br-pow s 1.2f0)))
                 (dx (+ (* c ax) (* sn bx) (* wv nx))) (dy (- (+ (* c ay) (* sn by) (* wv ny)) sg))
                 (dz (+ (* c az) (* sn bz) (* wv nz)))
                 (k (%lb-ss (/ s 0.2f0))) (k1 (- 1f0 k))
                 (ex (+ (* k1 qx) (* k dx))) (ey (+ (* k1 qy) (* k dy))) (ez (+ (* k1 qz) (* k dz)))
                 (el (f-max 1f-5 (f-hypot ex ey ez))) (o (* 3 i)))
            (declare (single-float th c sn wv sg dx dy dz k k1 ex ey ez el) (fixnum o))
            (setf px (+ px (* step (/ ex el))) py (f-max fl (+ py (* step (/ ey el)))) pz (+ pz (* step (/ ez el)))
                  (aref p o) px (aref p (+ o 1)) py (aref p (+ o 2)) pz)))))
    ;; the crack: the tip pulled onto T (turned about the root and scaled), all of it at the hit frames, eased either side
    (let ((wt (* (%lb-ss (/ (- tc (- s0 2.5f0)) 2f0)) (- 1f0 (%lb-ss (/ (- tc (+ s0 1.5f0)) 2.5f0))))))
      (declare (single-float wt))
      (when (> wt 0f0)
        (let* ((o (* 3 n)) (ux (- (aref p o) hx)) (uy (- (aref p (+ o 1)) hy)) (uz (- (aref p (+ o 2)) hz))
               (vx (- (aref lv 16) hx)) (vy (- (aref lv 17) hy)) (vz (- (aref lv 18) hz))
               (ul (f-max 1f-4 (f-hypot ux uy uz))) (vl (f-max 1f-4 (f-hypot vx vy vz)))
               (kx (- (* uy vz) (* uz vy))) (ky (- (* uz vx) (* ux vz))) (kz (- (* ux vy) (* uy vx)))
               (kl (f-hypot kx ky kz)) (phi (* wt (f-atan2 kl (+ (* ux vx) (* uy vy) (* uz vz)))))
               (sc (+ 1f0 (* wt (- (/ vl ul) 1f0)))) (c (f-cos phi)) (sn (f-sin phi)))
          (declare (fixnum o) (single-float ux uy uz vx vy vz ul vl kx ky kz kl phi sc c sn))
          (if (> kl 1f-5) (setf kx (/ kx kl) ky (/ ky kl) kz (/ kz kl)) (setf kx 0f0 ky 1f0 kz 0f0))
          (loop for i fixnum from 1 to n do
            (let* ((q (* 3 i)) (rx (- (aref p q) hx)) (ry (- (aref p (+ q 1)) hy)) (rz (- (aref p (+ q 2)) hz))
                   (kd (* (+ (* kx rx) (* ky ry) (* kz rz)) (- 1f0 c))))
              (declare (fixnum q) (single-float rx ry rz kd))
              (setf (aref p q) (+ hx (* sc (+ (* rx c) (* sn (- (* ky rz) (* kz ry))) (* kx kd))))
                    (aref p (+ q 1)) (+ hy (* sc (+ (* ry c) (* sn (- (* kz rx) (* kx rz))) (* ky kd))))
                    (aref p (+ q 2)) (+ hz (* sc (+ (* rz c) (* sn (- (* kx ry) (* ky rx))) (* kz kd))))))))))
    nil))
(defun-fast %br-whip-lash (side)
  "After LILLE-DRAW (R11, DUEL_LILLE_V3 §16): while a J route L L whip clip (*BR-LASH-V*) plays, its lash from the striking
wing's drawn tip (JILLIEL: *LB-WF* [74..79], LILLE-DRAW's; the owl: the claw, its stretch the lash's stub, %LB-LASHES
skipping it: [81 82]) at the clip's frame (%BR-LASH-CHAIN!): the ribbon segments, jade (the owl's gold) with a white core,
thick to thin, small blade segments along its root two thirds; its tip's and middle's arc smeared over the swing (the chain a
frame and half a frame back); the crack's burst on the point of his line at the opponent's distance (*BR-AT*: the line's
31 m at most, the opponent's chest height) from S over 5 frames, bigger with the distance; nothing else plays. 0 B."
  (declare (fixnum side))
  (let* ((m (svref *br-model* side)) (an (and m (model-anim m))) (c (and an (anim-clip an)))
         (ent (and c (assoc (clip-name c) *br-lash-v*))))
    (when ent
      (let* ((jm (model-joints m)) (ev (cdr ent)) (hd (svref ev 0)) (lv *br-lv*) (p *br-lash-p*) (w *lb-wf*) (pa *pose-at*) (at *br-at*) (o (* 8 side))
             (n (the fixnum *br-lash-n*)) (tf (* 60f0 (the single-float (anim-time an)))) (s0 (aref hd 5))
             (g (f->i (aref hd 0))) (owl (> (aref hd 7) 0.5f0)) (sc (aref *lb-v* 31))
             (yaw (aref pa 3)) (fx (- (f-sin yaw))) (fz (- (f-cos yaw))) (rx (f-cos yaw)) (rz (- (f-sin yaw)))
             (dist (if (> (aref at (+ o 4)) 0.5f0)
                       (f-min (the single-float *br-whip-max*)
                              (f-max 1f0 (f-hypot (- (aref at (+ o 2)) (aref at o)) (- (aref at (+ o 3)) (aref at (+ o 1))))))
                       3f0))
             (fl (- (aref pa 1) (aref *br-legs* (+ (* 10 side) 6))))   ; (his floor: the drawn lift off, *BR-LEGS* [6])
             (tx (+ (aref pa 0) (* dist fx))) (ty (+ fl (the single-float *br-whip-up*))) (tz (+ (aref pa 2) (* dist fz)))
             (pal (if owl +pal-gold+ +pal-jade+)) (wb (* sc (aref hd 6))) (sd (+ 800f0 (* 40f0 (i->f side)) (* 20f0 (i->f g))))
             (zz (* (aref hd 8) (+ 1f0 (* 0.035f0 (f-min dist 20f0))))))
        (declare (type simple-vector ev) (type f32vec jm hd lv p w pa at) (fixnum o n g)
                 (single-float tf s0 sc yaw fx fz rx rz dist fl tx ty tz pal wb sd zz))
        ;; the root H and the wing's direction there
        (if owl
            (let* ((h (* 16 (if (= g 0) (ji :hand-r) (ji :hand-l)))) (b (* 16 (if (= g 0) (ji :lower-arm-r) (ji :lower-arm-l))))
                   (hx (aref jm (+ h 12))) (hy (aref jm (+ h 13))) (hz (aref jm (+ h 14)))
                   (dx (- hx (aref jm (+ b 12)))) (dy (- hy (aref jm (+ b 13)))) (dz (- hz (aref jm (+ b 14))))
                   (dl (f-max 1f-4 (f-hypot dx dy dz))))
              (declare (fixnum h b) (single-float hx hy hz dx dy dz dl))
              (setf (aref lv 1) hx (aref lv 2) hy (aref lv 3) hz (aref lv 4) (/ dx dl) (aref lv 5) (/ dy dl) (aref lv 6) (/ dz dl)
                    (aref lv 19) (+ 0.15f0 (* sc (aref w (+ 72 g))))))
            (let* ((q *lb-p*) (to (if (= g 0) 74 77)))
              (declare (type f32vec q) (fixnum to))
              (if (= g 0) (joint-point! q jm (ji :chest) 0.07f0 0.3f0 0.13f0) (joint-point! q jm (ji :chest) -0.07f0 0.3f0 0.13f0))
              (let* ((hx (aref w to)) (hy (aref w (+ to 1))) (hz (aref w (+ to 2)))
                     (dx (- hx (aref q 0))) (dy (- hy (aref q 1))) (dz (- hz (aref q 2))) (dl (f-max 1f-4 (f-hypot dx dy dz))))
                (declare (single-float hx hy hz dx dy dz dl))
                (setf (aref lv 1) hx (aref lv 2) hy (aref lv 3) hz (aref lv 4) (/ dx dl) (aref lv 5) (/ dy dl) (aref lv 6) (/ dz dl)
                      (aref lv 19) 0.15f0))))
        ;; the swing's frame: A at the crack's point, B its side axis (his right / up by :plane) squared to A, N = A x B
        (let* ((ax (- tx (aref lv 1))) (ay (- ty (aref lv 2))) (az (- tz (aref lv 3))) (al (f-max 1f-4 (f-hypot ax ay az)))
               (ax (/ ax al)) (ay (/ ay al)) (az (/ az al))
               (b0x (* (aref hd 1) rx)) (b0y (aref hd 2)) (b0z (* (aref hd 1) rz))
               (bd (+ (* b0x ax) (* b0y ay) (* b0z az)))
               (bx (- b0x (* bd ax))) (by (- b0y (* bd ay))) (bz (- b0z (* bd az))) (bl (f-max 1f-4 (f-hypot bx by bz)))
               (bx (/ bx bl)) (by (/ by bl)) (bz (/ bz bl)))
          (declare (single-float ax ay az al b0x b0y b0z bd bx by bz bl))
          (setf (aref lv 7) ax (aref lv 8) ay (aref lv 9) az (aref lv 10) bx (aref lv 11) by (aref lv 12) bz
                (aref lv 13) (- (* ay bz) (* az by)) (aref lv 14) (- (* az bx) (* ax bz)) (aref lv 15) (- (* ax by) (* ay bx))
                (aref lv 16) tx (aref lv 17) ty (aref lv 18) tz (aref lv 20) fl (aref lv 21) al (aref lv 0) tf))
        ;; the swing's smear: the tip and the middle a frame and half a frame back
        (let ((sm (* (%lb-ss (/ (- tf (- s0 3.5f0)) 1.5f0)) (- 1f0 (%lb-ss (/ (- tf (+ s0 1f0)) 1.5f0))))) (mi (* 3 (floor (* 5 n) 8))))
          (declare (single-float sm) (fixnum mi))
          (when (> sm 0.02f0)
            (setf (aref lv 29) (- tf 1f0)) (%br-lash-chain! ev)
            (setf (aref lv 30) (aref p (* 3 n)) (aref lv 31) (aref p (1+ (* 3 n))) (aref lv 32) (aref p (+ 2 (* 3 n)))
                  (aref lv 33) (aref p mi) (aref lv 34) (aref p (1+ mi)) (aref lv 35) (aref p (+ 2 mi)))
            (setf (aref lv 29) (- tf 0.5f0)) (%br-lash-chain! ev)
            (setf (aref lv 36) (aref p (* 3 n)) (aref lv 37) (aref p (1+ (* 3 n))) (aref lv 38) (aref p (+ 2 (* 3 n)))
                  (aref lv 39) (aref p mi) (aref lv 40) (aref p (1+ mi)) (aref lv 41) (aref p (+ 2 mi))))
          (setf (aref lv 29) tf) (%br-lash-chain! ev)
          (when (> sm 0.02f0)
            (dotimes (j 2)
              (let* ((q0 (if (= j 0) 30 33)) (qm (if (= j 0) 36 39)) (pe (if (= j 0) (* 3 n) mi))
                     (x0 (aref lv q0)) (y0 (aref lv (+ q0 1))) (z0 (aref lv (+ q0 2)))
                     (x1 (aref p pe)) (y1 (aref p (+ pe 1))) (z1 (aref p (+ pe 2)))
                     (cx (- (* 2f0 (aref lv qm)) (* 0.5f0 (+ x0 x1)))) (cy (- (* 2f0 (aref lv (+ qm 1))) (* 0.5f0 (+ y0 y1))))
                     (cz (- (* 2f0 (aref lv (+ qm 2))) (* 0.5f0 (+ z0 z1))))
                     (sw (* sc zz (if (= j 0) 0.16f0 0.1f0))))
                (declare (fixnum q0 qm pe) (single-float x0 y0 z0 x1 y1 z1 cx cy cz sw))
                (when (> (f-hypot (- x1 x0) (- y1 y0) (- z1 z0)) 0.3f0)
                  (fx-crescent x0 y0 z0 x1 y1 z1 cx cy cz sw :comet 0.05f0 (+ sd 30f0 (i->f j)) pal (* 0.8f0 sm) :push 0.2f0)
                  (fx-crescent x0 y0 z0 x1 y1 z1 cx cy cz (* 0.35f0 sw) :comet 0.03f0 (+ sd 32f0 (i->f j)) +pal-hit+
                               (* 0.7f0 sm) :push 0.25f0))))))
        ;; the lash: thick to thin, a white core over its first four fifths, blade segments along its root two thirds
        (dotimes (i n)
          (let* ((a (* 3 i)) (b (+ a 3)) (s (/ (i->f i) (i->f n))) (s1 (/ (i->f (1+ i)) (i->f n)))
                 (w0 (* wb (+ 0.1f0 (* 0.9f0 (- 1f0 s))))) (w1 (* wb (+ 0.1f0 (* 0.9f0 (- 1f0 s1)))))
                 (x0 (aref p a)) (y0 (aref p (+ a 1))) (z0 (aref p (+ a 2)))
                 (dx (- (aref p b) x0)) (dy (- (aref p (+ b 1)) y0)) (dz (- (aref p (+ b 2)) z0)) (si (i->f i)))
            (declare (fixnum a b) (single-float s s1 w0 w1 x0 y0 z0 dx dy dz si))
            (toon-ribbon (x0 y0 z0) (dx dy dz) (w0 w1) :heat (1f0 0.9f0) :seed (- -1f0 sd si) :wob 0.03f0 :pal pal :k 0.95f0
                         :segs 1)
            (when (< s 0.8f0)
              (toon-ribbon (x0 y0 z0) (dx dy dz) ((* 0.4f0 w0) (* 0.4f0 w1)) :heat (1f0 1f0) :seed (- -100f0 sd si) :wob 0f0
                           :pal +pal-hit+ :k 0.85f0 :segs 1))
            (when (and (oddp i) (< s 0.7f0))
              (let ((dl (f-max 1f-4 (f-hypot dx dy dz))))
                (declare (single-float dl))
                (fx-shard (+ x0 (* 0.5f0 dx)) (+ y0 (* 0.5f0 dy)) (+ z0 (* 0.5f0 dz)) (/ dx dl) (/ dy dl) (/ dz dl)
                          (f-min (* 0.7f0 sc) (* 2.4f0 dl)) (* 2.2f0 w0) 0.04f0 (+ sd 200f0 si) pal 0.92f0 :push 0.1f0)))))
        ;; the crack on him: a white flash and a star over a jade (gold) one, sparks flung out, from S over 5 frames
        (let ((a (- tf s0)))
          (declare (single-float a))
          (when (and (>= a -0.2f0) (< a 5f0))
            (when (< a 2f0)
              (let ((k (- 1f0 (* 0.45f0 a))))
                (declare (single-float k))
                (fx-star tx ty tz (* 0.06f0 zz) (* zz (+ 0.55f0 (* 0.25f0 a))) 10 (* 0.7f0 a) 0f0 0f0 0.08f0 (+ sd 60f0) pal k
                         :push 0.4f0)
                (fx-star tx ty tz (* 0.04f0 zz) (* zz (+ 0.3f0 (* 0.15f0 a))) 7 (* -0.5f0 a) 0f0 0f0 0.06f0 (+ sd 61f0) +pal-hit+
                         (* 0.98f0 k) :push 0.45f0)
                (when (< a 0.6f0) (fx-disc tx ty tz (* 0.1f0 zz (- 1.2f0 a)) 0.05f0 (+ sd 62f0) +pal-hit+ 0.95f0 :push 0.5f0))))
            (dotimes (j 7)
              (let* ((hj (i->f j)) (u (* 6.2831855f0 (+ (* 0.1428f0 hj) (* 0.08f0 (hash01 hj 7.1f0)))))
                     (v (- (* 1.6f0 (hash01 hj 3.3f0)) 0.6f0)) (cu (f-cos u)) (su (f-sin u))
                     (ex (+ (* cu rx) (* 0.4f0 su fx))) (ey (+ su v)) (ez (+ (* cu rz) (* 0.4f0 su fz)))
                     (el (f-max 1f-4 (f-hypot ex ey ez))) (r (* zz (+ 0.18f0 (* 0.32f0 (f-max 0f0 a))))) (k (- 1f0 (* 0.2f0 a))))
                (declare (single-float hj u v cu su ex ey ez el r k))
                (fx-shard (+ tx (* r (/ ex el))) (+ ty (* r (/ ey el))) (+ tz (* r (/ ez el))) (/ ex el) (/ ey el) (/ ez el)
                          (* 0.26f0 zz) (* 0.03f0 zz) 0.02f0 (+ sd 70f0 hj) (if (evenp j) +pal-hit+ pal) k :push 0.35f0))))))))
  nil)
(defsound :br-whip-crack (:peak 0.95)               ; R11 (§16): the awakened J route L L's crack (BR-SHOT-FIRE): a whip's
  (let ((b (au-buf 0.6)))                            ;  supersonic snap, a slap, then the slack lash swishing back
    (au-mix! b (au-fnoise 0.012 :hp 4000 :decay 0.003) 0.0 1.0)
    (au-mix! b (au-fnoise 0.03 :bp 2200 :q 1.5 :decay 0.008) 0.002 0.7)
    (au-ping! b 0.0 3300 0.025 0.4 :attack 0.0005)
    (au-thump! b 0.0 220 90 0.01 0.04 0.35)
    (au-mix! b (au-whoosh 0.22 5200 1400 :q 1.6 :peak 0.08) 0.04 0.45)
    (au-reverb! b 0.18 :size 0.9)
    b))
(defun-fast %br-whip-reach (f side mv)
  "Before LILLE-DRAW (R10, §15): *LB-WF* [80] the wings' sweep tightness while the awakened L charges (1 + 0.25 x
%BR-CHARGE-DEPTH: the eight wings folding tighter by the level); R11 (§16): [81 82] 1 for the striking claw of a J route L
L whip clip (*BR-LASH-V*): the whip's root (%BR-WHIP-LASH draws its lash on from it; %LB-WINGS thins JILLIEL's blade,
%LB-LASHES skips the owl's comet). Zeroed otherwise (Lille never sets
them). 0 B."
  (declare (fixnum side))
  (let ((w *lb-wf*))
    (declare (type f32vec w))
    (setf (aref w 80) 0f0 (aref w 81) 0f0 (aref w 82) 0f0)
    (when mv
      (when (member (mv-name mv) *br-dash-moves*)
        (setf (aref w 80) (+ 1f0 (* 0.25f0 (%br-charge-depth f nil))))))
    (let* ((m (svref *br-model* side)) (c (and m (anim-clip (model-anim m)))) (ent (and c (assoc (clip-name c) *br-lash-v*))))
      (when ent
        (let ((hd (svref (the simple-vector (cdr ent)) 0)))
          (declare (type f32vec hd))
          (setf (aref w (+ 81 (f->i (aref hd 0)))) 1f0))))
    nil))

;;; ---------------------------------------------------------------- the special resource's looks (DUEL_LILLE_V3 §4)
;;; The lit wings are LILLE-DRAW's (%LB-WINGS reads the count BR-DRAW puts in *LB-FX* [19]); here the spends. BR-DRAW keeps
;;; last frame's count per side (cosmetic memory, never the sim's hooks) and reads a drop as:
;;; - a spend (one wing: a stance follow-up shot, BR-S-SPEND; or the owl's full volley, BR-RECALL-GO, every wing at once):
;;;   a light burst at each spent blade's tip and its three holes flashing out (jade, the owl's gold), *BR-SPEND-LIFE*;
;;; - the wing armour (two or more at once outside the volley: BARRO-STRUCK's 4, the owl's 2): those blades shatter, a flash
;;;   along each and shards flung out from him and falling (*BR-SHATTER-LIFE*);
;;; - in the base form a 狙擊 pip spent: a small jade glint at Diagramm's muzzle (*BR-PIP-LIFE*).
(defparameter *br-spend-life* 0.25 "A spent wing's light burst at its tip: seconds of the fx clock (held through a hitstop) ...")
(defparameter *br-shatter-life* 0.35 "... the armour's shatter (the shards' flight; the flash along each blade its first third) ...")
(defparameter *br-pip-life* 0.18 "... and a spent pip's glint at Diagramm's muzzle.")
(defparameter *br-shatter-speed* '(2.4 4.2) "The shards' speed, m/s (hashed between the two) ...")
(defparameter *br-shatter-up* 1.6 "... plus this much up (m/s), falling at *BR-SHATTER-FALL* (m/s^2) ...")
(defparameter *br-shatter-fall* 7.0 "... (a little under g: they read as light glass, not stone).")
(defparameter *br-volley-moves* '(:br-recall :br-rc0 :br-rc1 :br-rc2 :br-rc3 :br-rc4)
  "The volley's moves: a drop while one runs is its spend-all (each blade's burst, never the shatter).")
(declaim (type f32vec *br-wl* *br-shards*))
(defvar *br-wl* (make-f32 (* 2 136))
  "Per side (136 a side), the spends' memory: [0] the count seen last frame, [1] its pool (1 the base's pips, 2 the wings, 0
none yet), [2] the fx clock of that draw, [3] the pip glint's start (fx clock); per wing W at 8 + 16 W: [0] its look's
start (fx clock), [1] its look (0 none, 1 the spend's burst, 2 the armour's shatter), [2] 1 = the owl's gold, [3..5] its
tip and [6..14] its three holes at the start (the shards fly from there). Cosmetic memory.")
(defvar *br-shards* (let ((v (make-f32 (* 8 6 4))))
                      (dotimes (n 48 v)
                        (flet ((h (a b) (let ((x (* 43758.547 (sin (+ (* n a) b))))) (- x (floor x)))))
                          (setf (aref v (* 4 n)) (f32 (- (* 2 (h 12.9898 0.7)) 1))   ; the sideways jitter (x his side)
                                (aref v (+ 1 (* 4 n))) (f32 (h 78.233 2.1))           ; the speed share (0..1)
                                (aref v (+ 2 (* 4 n))) (f32 (- (h 39.425 4.3) 0.3))   ; the up share
                                (aref v (+ 3 (* 4 n))) (f32 (+ 0.7 (* 0.6 (h 93.989 5.9))))))))   ; the size
  "The armour's shards, 6 a wing (wing W's shard J at 4 (6 W + J)): hashed once (a fixed pattern): sideways jitter, speed
share, up share, size.")

(defmacro %br-tip! (side i p)
  "P (an f32vec) = SIDE's wing I's tip as last drawn: its third hole (*LB-HOLES*, 0.79 of the blade) carried on along the
blade past it by 0.72 x the second -> third hole (the tip at 1.0). 0 B."
  `(let* ((%h *lb-holes*) (%o (* 3 (+ (* 24 ,side) (* 3 ,i)))) (%p ,p))
     (declare (type f32vec %h %p) (fixnum %o))
     (dotimes (%q 3)
       (setf (aref %p %q) (+ (aref %h (+ %o 6 %q)) (* 0.72f0 (- (aref %h (+ %o 6 %q)) (aref %h (+ %o 3 %q)))))))))

(defun-fast %br-spend-note (f side n pool)
  "BR-DRAW's spend detector, after LILLE-DRAW (so *LB-HOLES* holds this frame's blades): SIDE's special count N in POOL (1
the base's pips, 2 the wings) against last frame's (*BR-WL*); a drop in the same pool, the last draw at most 0.25 s ago,
starts the spent wings' looks (the volley's or one: the burst; two or more otherwise: the armour's shatter) or the pip's
glint. 0 B."
  (declare (fixnum side n pool))
  (let* ((wl *br-wl*) (o (* 136 side)) (tm (fx-clock)) (last (f->i (aref wl o))) (dt (- tm (aref wl (+ o 2)))))
    (declare (type f32vec wl) (fixnum o last) (single-float tm dt))
    (when (and (= pool (f->i (aref wl (+ o 1)))) (< n last) (<= -0.001f0 dt 0.25f0))
      (if (= pool 1)
          (setf (aref wl (+ o 3)) tm)
          (let* ((mv (and (eq (fighter-state f) :move) (fighter-move f)))
                 (volley (and mv (member (mv-name mv) *br-volley-moves*)))
                 (mode (if (and (>= (- last n) 2) (not volley)) 2f0 1f0))
                 (gold (if (> (lb-fxs side 15) 0.5f0) 1f0 0f0)) (p *lb-p*) (h *lb-holes*))
            (declare (type f32vec p h) (single-float mode gold))
            (loop for i of-type fixnum from n below (min 8 last)
                  do (let ((q (+ o 8 (* 16 i))) (ho (* 3 (+ (* 24 side) (* 3 i)))))
                       (declare (fixnum q ho))
                       (%br-tip! side i p)
                       (setf (aref wl q) tm (aref wl (+ q 1)) mode (aref wl (+ q 2)) gold
                             (aref wl (+ q 3)) (aref p 0) (aref wl (+ q 4)) (aref p 1) (aref wl (+ q 5)) (aref p 2))
                       (dotimes (k 9) (setf (aref wl (+ q 6 k)) (aref h (+ ho k)))))))))
    (setf (aref wl o) (i->f n) (aref wl (+ o 1)) (i->f pool) (aref wl (+ o 2)) tm))
  nil)

(defun-fast %br-spend-look (e side)
  "The spent wings' looks (*BR-WL*, noted by %BR-SPEND-NOTE) at the fx clock: the spend's burst at each blade's tip as it
is drawn now (a star, a white core, its three holes flashing out); the armour's shatter (a flash along the blade over its
first third, six shards a blade flung out from him from its holes and tip as they were, falling, shrinking); the pip's
glint at Diagramm's muzzle (the model looked up only while one shows). 0 B but that lookup."
  (declare (fixnum side))
  (let* ((wl *br-wl*) (o (* 136 side)) (tm (fx-clock)) (p *lb-p*) (h *lb-holes*) (at *br-at*) (sv *br-shards*)
         (sl (the single-float *br-spend-life*)) (hl (the single-float *br-shatter-life*)))
    (declare (type f32vec wl p h at sv) (fixnum o) (single-float tm sl hl))
    (dotimes (i 8)
      (let* ((q (+ o 8 (* 16 i))) (mode (f->i (aref wl (+ q 1)))) (age (- tm (aref wl q)))
             (pal (if (> (aref wl (+ q 2)) 0.5f0) +pal-gold+ +pal-jade+)) (sd (i->f (+ i (* 8 side)))))
        (declare (fixnum q mode) (single-float age pal sd))
        (cond ((= mode 0))
              ((or (< age -0.001f0) (> age (if (= mode 1) sl hl))) (setf (aref wl (+ q 1)) 0f0))
              ((= mode 1)                                ; the spend: the light bursting off the tip
               (let* ((u (/ age sl)) (k (- 1f0 (* u u))) (ho (* 3 (+ (* 24 side) (* 3 i)))))
                 (declare (single-float u k) (fixnum ho))
                 (%br-tip! side i p)
                 (fx-star (aref p 0) (aref p 1) (aref p 2) (+ 0.04f0 (* 0.06f0 u)) (+ 0.14f0 (* 0.36f0 (%lb-ss (/ u 0.4f0))))
                          7 (+ sd (* 2f0 u)) 0f0 0f0 0.1f0 (+ 280f0 sd) pal k :push 0.25f0)
                 (fx-star (aref p 0) (aref p 1) (aref p 2) 0.03f0 (* 0.2f0 (- 1f0 u)) 5 (* 1.7f0 sd) 0f0 0f0 0.05f0
                          (+ 290f0 sd) +pal-hit+ k :push 0.3f0)
                 (dotimes (g 3)                          ; its holes flashing out
                   (fx-disc (aref h (+ ho (* 3 g))) (aref h (+ ho (* 3 g) 1)) (aref h (+ ho (* 3 g) 2))
                            (* 0.08f0 (- 1f0 u)) 0.04f0 (+ 300f0 sd (i->f g)) pal (* 0.9f0 k) :push 0.15f0))))
              (t                                         ; the armour: the blade shatters
               (let* ((u (/ age hl)) (k (- 1f0 (* u u u))) (ax (aref at (* 8 side))) (az (aref at (+ (* 8 side) 1)))
                      (sp0 (f32 (first *br-shatter-speed*))) (sp1 (f32 (second *br-shatter-speed*)))
                      (up (the single-float *br-shatter-up*)) (gv (the single-float *br-shatter-fall*)))
                 (declare (single-float u k ax az sp0 sp1 up gv))
                 (when (< u 0.34f0)                      ; the flash along the blade
                   (let ((kf (- 1f0 (/ u 0.34f0))))
                     (declare (single-float kf))
                     (toon-ribbon ((aref wl (+ q 6)) (aref wl (+ q 7)) (aref wl (+ q 8)))
                                  ((- (aref wl (+ q 3)) (aref wl (+ q 6))) (- (aref wl (+ q 4)) (aref wl (+ q 7)))
                                   (- (aref wl (+ q 5)) (aref wl (+ q 8))))
                                  ((* 0.12f0 kf) (* 0.08f0 kf)) :heat (1f0 1f0) :seed (- -300f0 sd) :wob 0.05f0 :pal +pal-hit+
                                  :k kf :k1 (* 0.8f0 kf) :segs 2)
                     (fx-star (aref wl (+ q 9)) (aref wl (+ q 10)) (aref wl (+ q 11)) (* 0.08f0 kf) (+ 0.25f0 (* 0.35f0 u)) 9
                              (* 2.3f0 sd) 0f0 0f0 0.15f0 (+ 310f0 sd) pal kf :push 0.3f0)))
                 (dotimes (j 6)                          ; the shards: from the holes and the tip, outward from him, falling
                   (let* ((r (* 4 (+ (* 6 i) j))) (c (* 0.6f0 (i->f j)))   ; (their start: along holes 0 -> 1 -> 2 -> tip)
                          (seg (min 2 (f->i c))) (fr (- c (i->f seg)))
                          (a0 (+ q 6 (* 3 seg))) (a1 (if (= seg 2) (+ q 3) (+ q 9 (* 3 seg))))
                          (x0 (+ (aref wl a0) (* fr (- (aref wl a1) (aref wl a0)))))
                          (y0 (+ (aref wl (+ a0 1)) (* fr (- (aref wl (+ a1 1)) (aref wl (+ a0 1))))))
                          (z0 (+ (aref wl (+ a0 2)) (* fr (- (aref wl (+ a1 2)) (aref wl (+ a0 2))))))
                          (ox (- x0 ax)) (oz (- z0 az)) (ol (f-max 0.05f0 (f-hypot ox oz))) (ux (/ ox ol)) (uz (/ oz ol))
                          (jt (aref sv r)) (spd (+ sp0 (* (aref sv (+ r 1)) (- sp1 sp0))))
                          (vx (* spd (- ux (* 0.6f0 jt uz)))) (vz (* spd (+ uz (* 0.6f0 jt ux))))
                          (vy (+ up (* spd (aref sv (+ r 2)))))
                          (px (+ x0 (* vx age))) (py (+ y0 (* vy age) (* -0.5f0 gv age age))) (pz (+ z0 (* vz age)))
                          (dvy (- vy (* gv age))) (dl (f-max 1f-3 (f-hypot vx dvy vz))) (sz (aref sv (+ r 3))))
                     (declare (fixnum r seg a0 a1)
                              (single-float c fr x0 y0 z0 ox oz ol ux uz jt spd vx vz vy px py pz dvy dl sz))
                     (when (> py 0.02f0)
                       (fx-shard px py pz (/ vx dl) (/ dvy dl) (/ vz dl) (* 0.2f0 sz (- 1f0 (* 0.5f0 u))) (* 0.045f0 sz k)
                                 0.1f0 (+ 320f0 sd (i->f j)) pal k :push 0.1f0)))))))))
    (let ((age (- tm (aref wl (+ o 3)))) (pl (the single-float *br-pip-life*)))   ; the base's pip glint at the muzzle
      (declare (single-float age pl))
      (when (<= 0f0 age pl)
        (let ((u (/ age pl)))
          (declare (single-float u))
          (joint-point! p (model-joints (model e)) (ji :weapon-r) 0f0 0f0 -1.75f0)
          (fx-star (aref p 0) (aref p 1) (aref p 2) 0.04f0 (+ 0.12f0 (* 0.2f0 (%lb-ss (/ u 0.3f0)))) 6 (* 2f0 u) 0f0 0f0
                   0.08f0 330f0 +pal-jade+ (- 1f0 (* u u)) :push 0.2f0)
          (fx-star (aref p 0) (aref p 1) (aref p 2) 0.02f0 (* 0.1f0 (- 1f0 u)) 4 0.4f0 0f0 0f0 0.05f0 331f0 +pal-hit+
                   (- 1f0 u) :push 0.25f0)))))
  nil)



(defun-fast br-draw (e rdt)
  "His kit's :draw hook: his special count to Lille's wings (*LB-FX* [19]: awakened, the first N blades lit, the rest
dimmed), Lille's (LILLE-DRAW: his forms carry Lille's form names, so the wings, the halos, the legs and the cinematics'
drives come out the same; his volley strings drive its SP looks through BR-RC-DRIVE), then the base stance's aim line
(%BR-AIM-LOOK); his place and the opponent's (%BR-PLACE!); the spends (%BR-SPEND-NOTE against last frame's count: a
wing's burst at its tip, the armour's shatter, a pip's glint at the muzzle; %BR-SPEND-LOOK); the volley's light gathering
(%BR-RECALL-LOOK), each string beat's lines from the wing tips (%BR-BEAT-LOOK) and 裁き・極's ring, blast and beam
(%BR-KIWAMI-LOOK); R10 (§15): the charge's wing sweep handed to LILLE-DRAW (%BR-WHIP-REACH), the L charge's tells
(%BR-CHARGE-LOOK); R11 (§16): the whips' claws flagged for LILLE-DRAW (%BR-WHIP-REACH), the lash after it (%BR-WHIP-LASH),
the stance switch's legs' fold and pull handed to it (*BR-LEGS*, set by his :pose hook); R15 (§19): the base stance's
snipe shot and its gun-kata / swings (%BR-SNIPE-LOOK, %BR-KATA-LOOK; the snipe's charge is his :charge hook, BR-CHARGE)."
  (declare (single-float rdt))
  (let* ((f (fighter e)) (side (fighter-side f)) (mv (and (eq (fighter-state f) :move) (fighter-move f)))
         (c (if mv (%br-chain-clock (mv-name mv) (fighter-sf f)) -1)) (o (* 65 side))
         (awake (member (fighter-form f) '(:jilliel-kin :jilliel :shin-kin :shin))) (n (br-ammo-look e)))
    (declare (fixnum side c o n))
    (setf (lb-fxs side 19) (if awake (i->f (1+ (min 8 n))) 0f0))
    (%br-place! e (fighter-opp f) side)                ; (before LILLE-DRAW: R10's whips read it; R15: the snipe's reticle)
    (%br-whip-reach f side mv)                          ; (R10, §15: *LB-WF* [80..82] for LILLE-DRAW, zeroed after it)
    (let ((lg *br-legs*) (o (* 10 side)))               ; (R11, §16: the stance switch's legs, [89 90])
      (setf (aref *lb-wf* 89) (if (>= (aref lg o) 0f0) (+ 1f0 (aref lg (+ o 7))) 0f0) (aref *lb-wf* 90) (aref lg (+ o 8))))
    (%br-wall-share f side awake rdt)                   ; (the wing wall: his awakened guard, [91])
    (lille-draw e rdt)
    (%br-whip-lash side)                                ; (R11, §16: the J route's L L whips, both forms)
    (let ((w *lb-wf*)) (setf (aref w 80) 0f0 (aref w 81) 0f0 (aref w 82) 0f0 (aref w 89) 0f0 (aref w 90) 0f0 (aref w 91) 0f0))
    (when (eq (fighter-form f) :base) (%br-aim-look e f side))
    (%br-spend-note f side n (if awake 2 1))
    (%br-spend-look e side)
    (setf (aref *br-fly* o) 0f0)                        ; (no traces to fly back since v3: the gathering only)
    (when (>= c 0)
      (let ((jm (model-joints (model e))))
        (when (<= c 16) (%br-recall-look e jm side c))
        (when (not (eq (mv-name mv) :br-recall)) (%br-beat-look e f jm side mv))
        (when (and (eq (mv-name mv) :br-rc4) (eq (fighter-phase f) :main)) (%br-kiwami-look f jm side))))
    (when (and mv (assoc (mv-name mv) *br-kl-balls*) (eq (fighter-phase f) :main))   ; R8: the K route's L L as balls
      (%br-kl-balls f side mv))
    (when (and mv (eq (fighter-phase f) :main) (eq (fighter-form f) :base))   ; R15 (§19): the base stance's snipe, gun-kata, swings
      (cond ((member (mv-name mv) *br-snipe-moves*) (%br-snipe-look e f side mv))
            ((member (mv-name mv) *br-kata-moves*) (%br-kata-look e f side mv))))
    (when (and mv (member (mv-name mv) *br-dash-moves*))   ; R9: the L dash, the cuts after (R10: its charge first)
      (%br-charge-look f side mv)
      (when (eq (fighter-phase f) :main) (%br-dash-look f side mv)))
    (when (and (>= *br-art-hold* 0) (>= (the fixnum (br-hold-clock f)) *br-art-hold*))   ; (debug stills)
      (setf *br-art-hold* -1)
      (hitstop 100000)))
  nil)

;;; ---------------------------------------------------------------- the HUD: the special resource (DUEL_LILLE_V3 §3.1)
(defparameter *br-sn-strings* #("SN 0" "SN 1" "SN 2" "SN 3") "The base form's label: SN + the 狙擊 pips.")
(defparameter *br-wg-strings* (let ((v (make-array 9))) (dotimes (i 9 v) (setf (svref v i) (format nil "WG ~d" i))))
  "The awakened forms' label: WG + the wings.")

(defun br-hud-label (g kit)
  "The portrait block's label: SN n (the 狙擊 pips) in the base form, WG n (the wings) awakened."
  (let* ((e (lb-side-of g)) (st (brs e)) (n (if st (brs-ammo st) 0)))
    (if (eq (kit-form kit) :base)
        (svref *br-sn-strings* (max 0 (min 3 n)))
        (svref *br-wg-strings* (max 0 (min 8 n))))))

(defun br-hud-meter (e kit x y w h right tm lx ly ls)
  "His kit-meter row (LX LY LS: the landscape label's place, NIL in the portrait slot): the special resource's pips (Lille's
reticle glyph: a filled pip the open jade eye, an empty one the shut white): the base form's three 狙擊 pips, awakened the
eight wings; its label SN n / WG n."
  (let* ((st (brs e)) (v *lb-hud*) (n (if st (brs-ammo st) 0)) (cap (if (eq (kit-form kit) :base) 3 8)))
    (setf (aref v 3) (f32 tm) (aref v 4) (f32 x) (aref v 5) (f32 y) (aref v 6) (f32 w) (aref v 7) (f32 h))
    (let* ((step (/ w cap)) (r (min (* 0.36 step) (max 5.0 (* 2.4 h)))))
      (dotimes (i cap)
        (setf (aref v 0) (f32 (if right (- (+ x w) (* step (+ i 0.5))) (+ x (* step (+ i 0.5)))))
              (aref v 1) (f32 (+ y (* 0.5 h))) (aref v 2) (f32 r))
        (%lb-pip (if (< i n) 1 0))))
    (when lx
      (hud-text (br-hud-label (gauges e) kit) lx ly ls *c-lb-jade* :align (if right :right :left)))))
