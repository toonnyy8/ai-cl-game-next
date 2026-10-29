;;;; hisagi-stills.lisp — Hisagi's debug stills and probes: the look and tip consing checks (83901-83902), the 餘電 scene (83903-83904), the clip strips (83500-83549,
;;;; 83910-83964), the cinematics' stills (83965-83978), the two model sheets (83980-83994) (split out of hisagi-art.lisp
;;;; 2026-10-21, refactor round 2). Debug scaffolding only: the sim never reads it. The PUSHNEW order onto *CHAR-DEBUG* is the dispatch
;;;; order; keep it.
(in-package :duel)

(defun hisagi-look-cons-check ()
  "Debug 83901 (P1 Hisagi): bytes consed by 10 calls of his :pose hook and HISAGI-DRAW in the stance, out at the anchor, in
K1 NAGI's hit frame, in K2 NOKO's (A1, §24.1: also its wheel, K3 TSUI's plunge and its sky, the leap J3K), in the windmill,
and (the Shikai's clips, §21.4) J1's short grip, J3's two let out, KARI-OTOSHI's,
SHIBARI's wrap and KUBIKAKE's garrote, and the Bankai's look (§21.6: the orb, the rope) in the stance and
with the noose of a bind, and the Bankai's clips (§21.8): J3's two let out and its swept chain, TSUISA's lance (hooked),
KUBIKAKE's whirl, SAHARAI's ring, SP1's bundle and bolt, SP2's rain, KOSA's whip, the bind's MAKIGIRI, SHIBORI's drops, KOSHU's
garrote, UNWIND's ring (B4a's marks gone), and batch A2's (§24.2): the route links' lashes, trails and the bundle (K1
HOSOKU's spin and binding, spread K2 / K3, gathered K2 SOKUDA's U and L, K3 SOKUSEN, J2 SOKUBEN, J3 SOKUTEI), the bind's
stance with the noose held taut, and batch A3's (§24.3): SAHARAI's ring lash in its recovery, KOJO's heave (the held chain
trembling) and its reap, KAIBAKU-GEKI's haul and its throw-off (the noose reeled up), and §27.5's: 刈's stance (the wound
chain), its five strikes' hit frames, CHIKUDEN's charge down the chain, 放電's burst, 餘電 at 400 and fading at 30, and §27.6's (their own clips, the bind kept
wound on him): CHIKUDEN's front down the chain, 放電's charge, NS3a's wrap, and §27.10's AS1 TSUMUJI (its own clip): the
flat-spinning sickle's flight, its spin in him with the cuts, its return: each must be 0."
  (let* ((e *p1*) (f (fighter e)) (st (hs e)) (m (model e)) (an (model-anim m)) (c0 (anim-clip an)) (t0 (anim-time an))
         (state (fighter-state f)) (mv (fighter-move f)) (ph (fighter-phase f)) (sf (fighter-sf f)) (s0 (hss-state st))
         (ct (fighter-contact f)) (p (pos-of e)) (z0 (hss-zan st)))
    (setf (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2) (aref *pose-at* 3) (yaw-of e))
    (flet ((bytes () (let ((c0 (cons-bytes))) (dotimes (i 10) (hs-pose e m) (hisagi-draw e 0.016)) (- (cons-bytes) c0)))
           (at (name frame &optional clip) (setf (fighter-state f) :move (fighter-move f) (find-move name) (fighter-phase f) :main
                                                 (fighter-sf f) frame)
             (when clip (setf (anim-clip an) (find-clip clip) (anim-time an) (/ frame 60f0)))))
      (let* ((idle (bytes))
             (out (progn (setf (hss-state st) :out) (bytes)))
             (nage (progn (at :hs-k1 18 :hs-s-nagi) (bytes)))                     ; (A1, §24.1: K1's sweep, K2's
             (hiki (progn (at :hs-k2 21 :hs-s-noko) (bytes)))                     ;  saw on him, its wheel, K3's
             (a1 (list (progn (at :hs-k2 12 :hs-s-noko) (bytes)) (progn (at :hs-k3 23 :hs-s-tsui) (bytes))   ;  plunge,
                       (progn (at :hs-k3 19 :hs-s-tsui) (bytes)) (progn (at :hs-j3k 15 :hs-s-tobi-rin) (bytes))))   ;  the sky, the leap J3)
             (kaza (progn (at :hs-kaza 20 :hs-s-kaza) (bytes)))
             (grip (progn (setf (hss-state st) :in) (at :hs-j1 9 :hs-s-sen) (bytes)))
             (rin (progn (at :hs-j3 10 :hs-s-rin) (bytes)))
             (kari (progn (at :hs-k3 24 :hs-s-kari) (bytes)))
             (ch (prog1 (progn (setf (hss-charge st) 40 (hss-kstr st) t)          ; (S1: a charge of x1.4)
                               (list (progn (at :hs-kaza-j 30 :hs-s-kaza) (bytes))
                                     (progn (at :hs-k1 19 :hs-s-nagi) (setf (fighter-move f) (hs-scaled :hs-k1 40)) (bytes))
                                     (progn (at :hs-k3 24 :hs-s-tsui) (setf (fighter-move f) (hs-scaled :hs-k3 40)) (bytes))))
                   (setf (hss-charge st) 0 (hss-kstr st) nil)))
             (shibari (progn (at :hs-shibari 30 :hs-s-shibari) (setf (fighter-contact f) :hit) (bytes)))
             (kubi (progn (setf (fighter-contact f) ct) (at :hs-breaker 9 :hs-s-kubikake) (bytes)))
             (fm (fighter-form f)) (b0 (hss-bound st))
             (bankai (progn (setf (fighter-state f) :idle (fighter-move f) nil (fighter-form f) :bankai
                                  (anim-clip an) (find-clip :hs-k-stance))
                            (bytes)))
             (bind (progn (setf (hss-bound st) t) (bytes)))
             (bk (progn (setf (hss-bound st) nil)
                        (list (progn (at :hs-r-j3 14 :hs-k-sensa) (bytes))
                              (progn (at :hs-r-k2 28 :hs-k-g-k2) (setf (fighter-contact f) :hit) (bytes))
                              (progn (setf (fighter-contact f) ct) (at :hs-r-kubikake 12 :hs-k-kubikake) (bytes))
                              (progn (at :hs-r-l 23 :hs-k-saharai) (bytes))
                              (progn (at :hs-r-sp1 21 :hs-k-raiden) (bytes))
                              (progn (at :hs-r-sp2 31 :hs-k-ame) (bytes))
                              (progn (at :hs-r-kikon 21 :hs-k-kosa) (bytes))
                              (progn (at :hs-r-l 34 :hs-k-saharai) (bytes)))))            ; (A3: its recovery)
             (a2 (list (progn (at :hs-r-k1 17 :hs-k-hosoku) (bytes))           ; (A2, §24.2: the route links, the bundle)
                       (progn (at :hs-r-k1 24 :hs-k-hosoku) (bytes))
                       (progn (at :hs-r-k2s 21 :hs-k-s-k2) (bytes))
                       (progn (at :hs-r-k3 22 :hs-k-s-k3) (bytes))
                       (progn (at :hs-r-k2 34 :hs-k-g-k2) (bytes))
                       (progn (at :hs-r-k3g 28 :hs-k-g-k3) (bytes))
                       (progn (at :hs-r-j2s 16 :hs-k-g-j2) (bytes))
                       (progn (at :hs-r-j3g 17 :hs-k-g-j3) (bytes))))
             (bb (progn (setf (hss-bound st) t (fighter-form f) :bankai-bind)
                        (list (progn (at :hs-b-k2 21 :hs-kb-makigiri) (bytes))
                              (progn (at :hs-b-k3 23 :hs-kb-shibori) (bytes))
                              (progn (at :hs-b-sp1 15 :hs-kb-raiden) (bytes))
                              (progn (at :hs-b-kikon 9 :hs-kb-koshu) (bytes))
                              (progn (at :hs-b-l 12 :hs-kb-kojo) (bytes))                 ; (A3: KOJO's heave, the reap,
                              (progn (at :hs-b-l 31 :hs-kb-kojo) (bytes))                 ;  KAIBAKU-GEKI's haul, the
                              (progn (at :hs-b-sp2 10 :hs-kb-kaibaku) (bytes))            ;  throw-off)
                              (progn (at :hs-b-sp2 22 :hs-kb-kaibaku) (bytes))
                              (progn (setf (fighter-state f) :idle (fighter-move f) nil (anim-clip an) (find-clip :hs-kb-stance))
                                     (bytes))                                  ; (A2: the stance, the noose held taut)
                              (progn (setf (hss-bound st) nil) (at :hs-b-unwind 10 :hs-kb-unwind) (bytes)))))
             (b2 (progn (setf (hss-bound st) t (fighter-form f) :bankai-bind)    ; (batch 2b, §28.12: the core bind's own)
                        (list (progn (at :hs-b-n1a 20 :hs-kb-kagiyose) (bytes))                 ; (the reel onto him)
                              (progn (at :hs-b-as1 20 :hs-kb-kagiyose-giri) (bytes))
                              (progn (at :hs-b-as1 28 :hs-kb-kagiyose-giri) (bytes))           ; (the cut)
                              (progn (at :hs-b-n1c 15 :hs-kb-juji) (bytes))                    ; (the X: two let-outs)
                              (progn (at :hs-b-n2a 24 :hs-kb-matoi) (setf (fighter-contact f) :hit) (bytes))   ; (the wrap)
                              (progn (setf (fighter-contact f) ct) (at :hs-b-n2b 21 :hs-kb-shime) (bytes))     ; (two grips)
                              (progn (at :hs-b-as2b 23 :hs-kb-tsuri) (setf (fighter-contact f) :hit) (bytes))  ; (hooked)
                              (progn (setf (fighter-contact f) ct) (at :hs-b-as3b 10 :hs-kb-san) (bytes))     ; (§28.13: SAN)
                              (progn (setf (fighter-contact f) ct (fighter-state f) :idle (fighter-move f) nil
                                           (anim-clip an) (find-clip :hs-kb-st-shibori))
                                     (bytes)))))                                      ; (the 絞 stance: up to the orb)
             (core (progn (setf (fighter-form f) :base)                              ; (§26: NA1's grip, the pointer
                          (list (progn (at :hs-j1 15 :hs-na1) (bytes))                ;  stances' hawser and sparks)
                                (progn (setf (fighter-state f) :idle (fighter-move f) nil (anim-clip an) (find-clip :hs-st-bind))
                                       (bytes))
                                (progn (setf (anim-clip an) (find-clip :hs-st-raiden)) (bytes)))))
             (kr (list (progn (setf (anim-clip an) (find-clip :hs-st-kari)) (bytes))   ; (§27.5: 刈's stance, its five
                       (progn (at :hs-n2a 17 :hs-kr-tan) (bytes)) (progn (at :hs-n2b 13 :hs-kr-ren) (bytes))   ;  hit frames,
                       (progn (at :hs-n2c 17 :hs-kr-sen) (bytes)) (progn (at :hs-as2 9 :hs-kr-ko) (bytes))     ;  CHIKUDEN's
                       (progn (at :hs-as2b 10 :hs-kr-age) (bytes))                                            ;  charge,
                       (progn (at :hs-n3b 22 :hs-chikuden) (bytes))                                           ;  放電's burst,
                       (progn (at :hs-sa-hoden 12 :hs-hoden) (setf (fighter-contact f) :hit) (bytes))          ;  餘電 full
                       (progn (setf (fighter-contact f) ct (fighter-state f) :idle (fighter-move f) nil        ;  and fading)
                                    (anim-clip an) (find-clip :hs-st-kari) (hss-zan st) 400)
                              (bytes))
                       (progn (setf (hss-zan st) 30) (bytes))
                       (progn (setf (hss-zan st) 0) (at :hs-n3b 15 :hs-chikuden) (bytes))   ; (§27.6: CHIKUDEN's front down
                       (progn (at :hs-sa-hoden 6 :hs-hoden) (bytes))                        ;  the chain, 放電's charge,
                       (progn (at :hs-n3a 30 :hs-s-shibari) (bytes))                        ;  NS3a's wrap)
                       (progn (at :hs-as1 8 :hs-tsumuji) (bytes))                           ; (§27.10: TSUMUJI's flight,
                       (progn (at :hs-as1 19 :hs-tsumuji) (bytes))                          ;  the spin and two cuts,
                       (progn (at :hs-as1 34 :hs-tsumuji) (bytes)))))                       ;  the return)
        (setf (fighter-state f) state (fighter-move f) mv (fighter-phase f) ph (fighter-sf f) sf (hss-state st) s0
              (fighter-contact f) ct (anim-clip an) c0 (anim-time an) t0 (fighter-form f) fm
              (hss-bound st) b0 (hss-zan st) z0)
        (log-msg "duel hisagi look consing 2b (10 calls, B): KAGIYOSE ~d, KAGIYOSE-GIRI ~d, its cut ~d, JUJI ~d, MATOI's wrap ~d, ~
SHIME ~d, TSURI ~d, SAN ~d, the 絞 stance ~d" (nth 0 b2) (nth 1 b2) (nth 2 b2) (nth 3 b2) (nth 4 b2) (nth 5 b2) (nth 6 b2) (nth 7 b2)
                 (nth 8 b2))
        (log-msg "duel hisagi look consing (10 calls, B): stance ~d, out ~d, NAGI ~d, NOKO ~d, A1's wheel ~d, TSUI ~d, sky ~d, J3K ~d, ~
windmill ~d, J1 grip ~d, J3 ~d, KARI-OTOSHI ~d, S1's charge x1.4: windmill ~d, NAGI ~d, TSUI ~d; SHIBARI ~d, KUBIKAKE ~d, Bankai ~d, bind ~d; the Bankai's clips: J3 ~d, SOKUDA ~d, KUBIKAKE ~d, SAHARAI ~d, ~
SP1 ~d, SP2 ~d, KOSA ~d, SAHARAI's recovery ~d; the route links (A2): HOSOKU ~d, its bundle ~d, spread K2 ~d, K3 ~d, SOKUDA's L ~d, SOKUSEN ~d, SOKUBEN ~d, ~
SOKUTEI ~d; the bind's MAKIGIRI ~d, SHIBORI ~d, SP1 ~d, KOSHU ~d, KOJO's heave ~d, its reap ~d, KAIBAKU's haul ~d, its throw-off ~d, ~
stance ~d, UNWIND ~d; the core (§26): NA1 ~d, the bind's stance ~d, the lightning's ~d; 刈 (§27.5): stance ~d, TAN-GARI ~d, ~
REN-GARI ~d, SEN-GARI ~d, KO-GARI ~d, KARI-AGE ~d, CHIKUDEN ~d, HODEN ~d, ZANDEN ~d, its fade ~d; 縛雷 (§27.6): CHIKUDEN's front ~d, ~
HODEN's charge ~d, NS3a's wrap ~d; TSUMUJI (§27.10): its flight ~d, the spin and cuts ~d, the return ~d"
                 idle out nage hiki (nth 0 a1) (nth 1 a1) (nth 2 a1) (nth 3 a1) kaza grip rin kari (nth 0 ch) (nth 1 ch) (nth 2 ch) shibari kubi bankai bind
                 (nth 0 bk) (nth 1 bk) (nth 2 bk) (nth 3 bk) (nth 4 bk) (nth 5 bk) (nth 6 bk) (nth 7 bk)
                 (nth 0 a2) (nth 1 a2) (nth 2 a2) (nth 3 a2) (nth 4 a2) (nth 5 a2) (nth 6 a2) (nth 7 a2)
                 (nth 0 bb) (nth 1 bb) (nth 2 bb) (nth 3 bb) (nth 4 bb) (nth 5 bb) (nth 6 bb) (nth 7 bb) (nth 8 bb)
                 (nth 9 bb) (nth 0 core) (nth 1 core) (nth 2 core)
                 (nth 0 kr) (nth 1 kr) (nth 2 kr) (nth 3 kr) (nth 4 kr) (nth 5 kr) (nth 6 kr) (nth 7 kr) (nth 8 kr) (nth 9 kr)
                 (nth 10 kr) (nth 11 kr) (nth 12 kr) (nth 13 kr) (nth 14 kr) (nth 15 kr))))))
(defparameter *hs-tip-moves*
  '((:bankai :hs-r-j1) (:bankai :hs-r-j2) (:bankai :hs-r-j3) (:bankai :hs-r-k1) (:bankai :hs-r-k2s) (:bankai :hs-r-k3)
    (:bankai :hs-r-k2) (:bankai :hs-r-j2s) (:bankai :hs-r-k3g) (:bankai :hs-r-j3g)
    (:bankai :hs-r-l) (:bankai :hs-r-sp1) (:bankai :hs-r-sp2) (:bankai :hs-r-kikon) (:bankai :hs-r-kubikake)
    (:bankai :hs-breaker) (:bankai-bind :hs-b-j1) (:bankai-bind :hs-b-j2) (:bankai-bind :hs-b-j3) (:bankai-bind :hs-b-k1)
    (:bankai-bind :hs-b-k2) (:bankai-bind :hs-b-k3) (:bankai-bind :hs-b-sp1) (:bankai-bind :hs-b-sp2) (:bankai-bind :hs-b-l)
    (:bankai-bind :hs-b-kikon) (:bankai-bind :hs-b-sj)
    ;; §28.4: the core Bankai's segments with their own volumes (copies on the old clips)
    (:bankai :hs-r-n1a) (:bankai :hs-r-n1b) (:bankai :hs-r-n1c) (:bankai :hs-r-as1) (:bankai :hs-r-n2a) (:bankai :hs-r-n2b)
    (:bankai :hs-r-n2c) (:bankai :hs-r-as2b) (:bankai :hs-r-as3)
    (:bankai :hs-r-na3) (:bankai :hs-r-na4) (:bankai :hs-r-na3g) (:bankai :hs-r-na4g) (:bankai :hs-r-sa) (:bankai :hs-r-sa-g)   ; (§28.11)
    (:bankai :hs-r-as2) (:bankai-bind :hs-b-n1b) (:bankai-bind :hs-b-n1c)
    (:bankai-bind :hs-b-n2a) (:bankai-bind :hs-b-n2b) (:bankai-bind :hs-b-n2c) (:bankai-bind :hs-b-as2b) (:bankai-bind :hs-b-as3c)
    (:bankai-bind :hs-b-as2) (:bankai-bind :hs-b-as3b))                                           ; (batch 2b, §28.12: SHIME's AS copy, on its clip too)
  "Debug 83902's moves: (form move), every Bankai move with a hit window of volumes (B4c: the ranged route links too, on
their own clips since batch A2, §24.2).")
(defun hisagi-tip-check ()
  "Debug 83902 (P1 Hisagi 3 m from an idle Kenpachi; DUEL_HISAGI §21.8): for every move of *HS-TIP-MOVES*, on each of its
hit frames, the body posed by its form's clip (the FK and HS-POSE, as DRAW-FIGHTER) and HISAGI-DRAW run, what strikes
measured from his feet: a chain strike's free end (*HS-TIPV*), else a let-out crescent's point (*HS-LO*), else the held
right rod's point; along his facing for a line, from him for an arc. One `duel hisagi tip` line a move, with the volume's
far edge. A debug measurement (it conses)."
  (ensure-battle :hisagi :kenpachi)
  (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
  (place *p1* *p2* 3.0)
  (hs-reset *p1*)
  (hs-awaken-now! *p1*)
  (let* ((e *p1*) (f (fighter e)) (m (model e)) (an (model-anim m)) (b (model-body m)) (p (pos-of e)) (st (hs e))
         (v (make-f32 3)) (jm (model-joints m)) (yaw (yaw-of e)) (lo *hs-lo*) (tp *hs-tipv*))
    (dolist (fm (remove-if-not (lambda (fm) (hw-vols (svref (mv-hits (find-move (second fm))) 0))) *hs-tip-moves*))
      (destructuring-bind (form name) fm                              ; (a :seg-fn window has no edge: the route links
        (let* ((kit (find-kit :hisagi form)) (mv (find-move name))      ;  since §25.13, KOJO's yank since §25.7)
               (clip (kit-move-clip kit (if (member (mv-kind mv) '(:kikon :breaker)) (mv-clip-2 mv) (mv-clip mv))))
               (vol (first (hw-vols (svref (mv-hits mv) 0)))) (cap (> (aref vol 0) 0.5))
               (tips nil))
          (setf (fighter-form f) form (hss-bound st) (eq form :bankai-bind) (fighter-state f) :move (fighter-move f) mv
                (fighter-phase f) :main (fighter-contact f) nil)
          (loop for w across (mv-hits mv)
                do (loop for sf from (hw-from w) below (hw-to w)
                         do (setf (fighter-sf f) sf (anim-clip an) (find-clip clip) (anim-blend an) 0f0
                                  (anim-time an) (/ (* sf (mv-clip-speed mv)) 60f0)   ; (§28.11: at its clip speed, as play-clip)
                                  (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2)
                                  (aref *pose-at* 3) yaw)
                            (pose-fk! jm (anim-eval an) (aref p 0) (aref p 1) (aref p 2) yaw (body-scale b) (body-hunch b)
                                      (body-props b))
                            (hs-pose e m) (hisagi-draw e 0.016)
                            (push (cond ((or (> (aref tp 0) 0) (> (aref lo 0) 0.99) (> (aref lo 8) 0.99))
                                         (max (aref tp (if cap 1 0)) (if (> (aref lo 0) 0.99) (aref lo 7) 0)
                                              (if (> (aref lo 8) 0.99) (aref lo 15) 0)))
                                        (t (joint-point! v jm (ji :weapon-r) 0f0 0f0 -0.75f0)
                                           (let ((dx (- (aref v 0) (aref p 0))) (dz (- (aref v 2) (aref p 2))))
                                             (if cap (- (* dx (- (sin yaw))) (* dz (cos yaw))) (sqrt (+ (* dx dx) (* dz dz)))))))
                                  tips)))
          (log-msg "duel hisagi tip ~(~a ~a ~a~): ~{~,2f~^ ~} | edge ~{~,2f~^ / ~} (~a)" form name clip (reverse tips)
                   (loop for w across (mv-hits mv)                      ; (each window's: A2's gathered K2 has two)
                         collect (let ((v (first (hw-vols w)))) (if cap (+ (aref v 2) (aref v 4)) (aref v 1))))
                   (if cap "line" "arc")))))
    ;; §28.15 (the user, 2026-10-29: 「鉤寄、鉤寄斬、纏甩出去的鐮刀是沿修兵的面向畫的」): the bind's reels with the victim
    ;; off his facing (his yaw kept, the victim moved DEG round him at D m): how far the drawn crescent's point lies off the
    ;; victim's feet, the worst over the hit window and the 8 f after it (0.15 wanted); MATOI (a line, not a hook) on a hit
    ;; at 0 / 7 deg (inside its r 0.35) and whiffed at 30 deg (it stays on its line: far off him)
    (let* ((q (pos-of *p2*)) (qx (aref q 0)) (qz (aref q 2)) (ml *hs-ml*))
      (setf (fighter-form f) :bankai-bind (hss-bound st) t)
      (dolist (row '((:hs-b-n1a :r 3.0 (0 30 60)) (:hs-b-n1a :r 6.0 (0 30 60)) (:hs-b-as1 :l 3.0 (0 30 60))
                     (:hs-b-as1 :l 6.0 (0 30 60)) (:hs-b-n2a :l 2.5 (0 7 -30))))
        (destructuring-bind (name side d degs) row
          (let* ((mv (find-move name)) (clip (mv-clip mv)) (f0 (hw-from (svref (mv-hits mv) 0))) (offs nil))
            (dolist (deg degs)
              (let ((a (+ yaw (* (abs deg) (/ pi 180)))) (worst 0.0))
                (setf (aref q 0) (f32 (- (aref p 0) (* d (sin a)))) (aref q 2) (f32 (- (aref p 2) (* d (cos a))))
                      (fighter-state f) :move (fighter-move f) mv (fighter-phase f) :main
                      (fighter-contact f) (if (and (eq name :hs-b-n2a) (>= deg 0)) :hit nil))
                (loop for sf from f0 below (+ f0 8)
                      do (setf (fighter-sf f) sf (anim-clip an) (find-clip clip) (anim-blend an) 0f0 (anim-time an) (/ sf 60f0)
                               (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2)
                               (aref *pose-at* 3) yaw)
                         (pose-fk! jm (anim-eval an) (aref p 0) (aref p 1) (aref p 2) yaw (body-scale b) (body-hunch b) (body-props b))
                         (hs-pose e m) (hisagi-draw e 0.016)
                         (if (eq side :r)
                             (joint-point! v jm (ji :weapon-r) 0f0 0f0 -0.75f0)
                             (setf (aref v 0) (+ (aref ml 12) (* 0.75 (aref ml 4))) (aref v 2) (+ (aref ml 14) (* 0.75 (aref ml 6)))))
                         (setf worst (max worst (sqrt (+ (expt (- (aref v 0) (aref q 0)) 2) (expt (- (aref v 2) (aref q 2)) 2))))))
                (push (format nil "~d° ~,2f" (abs deg) worst) offs)))
            (log-msg "duel hisagi tip hook ~(~a ~a~) at ~,1f m: ~{~a~^, ~} (the drawn point off the victim's feet, f~d-~d; ~a)"
                     name clip d (reverse offs) f0 (+ f0 7)
                     (if (eq name :hs-b-n2a) "on a hit <= 0.15 wanted at 0 / 7 deg; the 30 deg one a whiff, on its line" "<= 0.15 wanted")))))
      (setf (aref q 0) qx (aref q 2) qz (fighter-contact f) nil))
    ;; A1 (§24.1): the Shikai's K string and leap J: K1's sweep at x1 / x1.6 and the leaps against their arcs' r; K2 / K2J
    ;; / K3 (a :seg-fn window: placed on the victim) as how far the drawn sickle sits off his feet (0 wanted)
    (setf (fighter-form f) :base (hss-bound st) nil)
    (dolist (row '((:hs-k1 0) (:hs-k1 60) (:hs-j2k 0) (:hs-j3k 0) (:hs-k2 0) (:hs-k2j 0) (:hs-k3 0)
                   (:hs-n2a 0) (:hs-n2b 0) (:hs-n2c 0) (:hs-as2 0) (:hs-as2b 0)   ; (§27.5: 刈's let-outs)
                   (:hs-as1 0)))                                                     ; (§27.10: TSUMUJI on the victim)
      (destructuring-bind (name n) row
        (let* ((mv (hs-scaled name n)) (clip (mv-clip mv)) (hw (svref (mv-hits mv) 0)) (seg (hw-seg hw)) (tips nil))
          (setf (hss-charge st) n (hss-kstr st) (> n 0) (fighter-state f) :move (fighter-move f) mv (fighter-phase f) :main
                (fighter-contact f) nil)
          (loop for sf from (hw-from hw) below (hw-to hw)
                do (setf (fighter-sf f) sf (anim-clip an) (find-clip clip) (anim-time an) (/ sf 60f0) (anim-blend an) 0f0
                         (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2)
                         (aref *pose-at* 3) yaw)
                   (pose-fk! jm (anim-eval an) (aref p 0) (aref p 1) (aref p 2) yaw (body-scale b) (body-hunch b) (body-props b))
                   (hs-pose e m) (hisagi-draw e 0.016)
                   (push (cond (seg (aref *hs-foe-d* 0))
                               ((or (> (aref lo 0) 0.99) (> (aref lo 8) 0.99))
                                (max (if (> (aref lo 0) 0.99) (aref lo 7) 0) (if (> (aref lo 8) 0.99) (aref lo 15) 0)))
                               (t (joint-point! v jm (ji :weapon-r) 0f0 0f0 -0.75f0)
                                  (sqrt (+ (expt (- (aref v 0) (aref p 0)) 2) (expt (- (aref v 2) (aref p 2)) 2)))))
                         tips))
          (log-msg "duel hisagi tip base ~(~a~) x~,2f ~(~a~): ~{~,2f~^ ~} | ~a" name (hs-charge-scale n) clip (reverse tips)
                   (if seg (if (eq name :hs-as1)
                               (format nil "off the victim (§27.10: its orbit ~,2f; <= ~,2f wanted, the capsule's r + 0.15)"
                                       *hs-tsumuji-orbit* (+ *hs-seg-r* 0.15))
                               "off the victim (0 wanted)")
(format nil "edge ~,2f (arc)" (aref (first (hw-vols hw)) 1)))))))
    (setf (hss-charge st) 0 (hss-kstr st) nil)
    (setf (fighter-form f) :bankai (hss-bound st) nil (fighter-contact f) nil)
    (to-idle e 0)))
(defun hisagi-zan-scene (c)
  "83903 / 83904 (§27.5): P1 Hisagi in his Shikai 2.5 m from an idle Kenpachi, 餘電 ZANDEN on him at 480 frames (the full
crawl) / 50 (its fade, gone in under a second); the match camera, the sim running (HS-ZAN-TICK counts it down)."
  (abort-cine)
  (ensure-battle :hisagi :kenpachi)
  (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
  (setf (hss-bound (hs *p1*)) nil)
  (force-form *p1* :base)
  (hs-reset *p1*)
  (place *p1* *p2* 2.5)
  (full-gauges! *p1*) (full-gauges! *p2*)
  (setf (hss-zan (hs *p1*)) (if (= c 83903) *hs-zan-frames* 50)))
(pushnew '(83901 83904 hisagi-art-debug) *char-debug* :test #'equal)
(defun hisagi-look-cons-2a ()
  "Debug 83901's second line (batch 2a, DUEL_HISAGI §28.11): bytes consed by 10 calls of HS-POSE and HISAGI-DRAW in the ranged
mode's 聚 stance (the bundle held) and on the core ranged clips' hit frames (UCHI and the gathered UCHI's bundle by its move,
OGI, ISSEI, RANSA's three, TATAKI, the AS2a sweep, JIBASHIRI with its crack, MAKI round him, KAKE over the shoulder, hooked;
§28.15: the five J's own J3 / J4, spread and gathered): each must be 0."
  (let* ((e *p1*) (f (fighter e)) (st (hs e)) (m (model e)) (an (model-anim m)) (c0 (anim-clip an)) (t0 (anim-time an))
         (state (fighter-state f)) (mv (fighter-move f)) (ph (fighter-phase f)) (sf (fighter-sf f)) (ct (fighter-contact f))
         (fm (fighter-form f)) (b0 (hss-bound st)) (p (pos-of e)))
    (setf (aref *pose-at* 0) (aref p 0) (aref *pose-at* 1) (aref p 1) (aref *pose-at* 2) (aref p 2) (aref *pose-at* 3) (yaw-of e)
          (fighter-form f) :bankai (hss-bound st) nil)
    (flet ((bytes () (let ((c0 (cons-bytes))) (dotimes (i 10) (hs-pose e m) (hisagi-draw e 0.016)) (- (cons-bytes) c0)))
           (at (name frame clip) (setf (fighter-state f) :move (fighter-move f) (find-move name) (fighter-phase f) :main
                                       (fighter-sf f) frame (anim-clip an) (find-clip clip) (anim-time an) (/ frame 60f0))))
      (let ((r (list (progn (setf (fighter-state f) :idle (fighter-move f) nil (anim-clip an) (find-clip :hs-k-st-shu)) (bytes))
                     (progn (at :hs-r-sa 11 :hs-k-uchi) (bytes)) (progn (at :hs-r-sa-g 11 :hs-k-uchi) (bytes))
                     (progn (at :hs-r-n1b 22 :hs-k-ogi) (bytes)) (progn (at :hs-r-n1c 22 :hs-k-issei) (bytes))
                     (progn (at :hs-r-as1 21 :hs-k-ransa) (bytes)) (progn (at :hs-r-as1 23 :hs-k-ransa) (bytes))
                     (progn (at :hs-r-as1 25 :hs-k-ransa) (bytes)) (progn (at :hs-r-n2b 31 :hs-k-tataki) (bytes))
                     (progn (at :hs-r-as2 31 :hs-k-sweep) (bytes)) (progn (at :hs-r-as2b 38 :hs-k-jibashiri) (bytes))
                     (progn (at :hs-r-as3b 29 :hs-k-maki) (bytes))
                     (progn (at :hs-r-as3c 25 :hs-k-kake) (setf (fighter-contact f) :hit) (bytes))
                     (progn (setf (fighter-contact f) ct) (at :hs-r-na3 11 :hs-k-na3) (bytes))   ; (§28.15: the five J's
                     (progn (at :hs-r-na4 11 :hs-k-na4) (bytes))                                  ;  own J3 / J4)
                     (progn (at :hs-r-na3g 20 :hs-k-g-na3) (bytes)) (progn (at :hs-r-na4g 20 :hs-k-g-na4) (bytes)))))
        (setf (fighter-state f) state (fighter-move f) mv (fighter-phase f) ph (fighter-sf f) sf (fighter-contact f) ct
              (anim-clip an) c0 (anim-time an) t0 (fighter-form f) fm (hss-bound st) b0)
        (apply #'log-msg "duel hisagi look consing 2a (10 calls, B): 聚 stance ~d, UCHI ~d, gathered UCHI ~d, OGI ~d, ISSEI ~d, RANSA ~d / ~d / ~d, ~
TATAKI ~d, AS2a ~d, JIBASHIRI ~d, MAKI ~d, KAKE ~d, J3 ~d, J4 ~d, gathered J3 ~d, gathered J4 ~d" r)))))
(defun hisagi-art-debug (c)
  (case c (83902 (hisagi-tip-check)) ((83903 83904) (hisagi-zan-scene c)) (t (hisagi-look-cons-check) (hisagi-look-cons-2a))))

;;; ---------------------------------------------------------------- the clip strips (debug 83910-83964, 83500-83549: stills)
;; 83910+k picks strip slot k (*HS-STRIPS*; 83500+k the Bankai's, *HS-BK-STRIPS*, §21.8); 83940 + 3 i + v shows its frame i of 8 (DUEL_GAMEPLAY: 0, S/3, 2S/3, S-2, S,
;; S+A, mid-recovery, end; a loop's 8 even steps) from view v (0 his right side, 1 the front, 33 degrees to his left; 2 the
;; match's behind camera, the sim frozen); 83964 lets go. He is P1 in his Shikai on a white card (views 0-1), the sim his
;; move at that frame (the draw hook's sickles and chain), a held cinematic shot; Kenpachi stands DIST m ahead (unseen
;; on the card).
(defparameter *hs-bk-strips*
  '((:hs-k-stance nil 3.0 nil :bankai) (:hs-k-walk-f nil 3.0 nil :bankai) (:hs-k-run nil 3.0 nil :bankai)
    (:hs-k-saben :hs-r-j1 4.0 nil :bankai) (:hs-k-kaeshi :hs-r-j2 4.0 nil :bankai) (:hs-k-sensa :hs-r-j3 4.0 nil :bankai)
    (:hs-k-saharai :hs-r-l 2.5 nil :bankai) (:hs-k-raiden :hs-r-sp1 8.0 nil :bankai) (:hs-k-ame :hs-r-sp2 8.0 nil :bankai)
    (:hs-k-kosa-aim nil 8.0 nil :bankai) (:hs-k-kosa :hs-r-kikon 8.0 nil :bankai) (:hs-k-breaker nil 3.0 nil :bankai)
    (:hs-k-hammer :hs-breaker 1.0 nil :bankai) (:hs-k-kubikake :hs-r-kubikake 6.0 nil :bankai)
    (:hs-kb-gen :hs-b-j1 1.5 nil :bind) (:hs-kb-kaeshi :hs-b-j2 1.5 nil :bind) (:hs-kb-sogen :hs-b-j3 1.5 nil :bind)
    (:hs-kb-hikigiri :hs-b-k1 2.5 nil :bind) (:hs-kb-makigiri :hs-b-k2 2.5 nil :bind) (:hs-kb-shibori :hs-b-k3 2.8 nil :bind)
    (:hs-kb-kaibaku :hs-b-sp2 2.5 nil :bind) (:hs-kb-raiden :hs-b-sp1 3.5 nil :bind) (:hs-kb-kojo :hs-b-l 2.5 nil :bind)
    (:hs-kb-koshu-run nil 4.0 nil :bind) (:hs-kb-koshu :hs-b-kikon 1.2 nil :bind) (:hs-kb-unwind :hs-b-unwind 2.0 nil :unwind)
    (:hs-k-hosoku :hs-r-k1 3.5 nil :bankai) (:hs-k-s-k2 :hs-r-k2s 5.0 nil :bankai) (:hs-k-s-k3 :hs-r-k3 5.0 nil :bankai)
    (:hs-k-g-k2 :hs-r-k2 5.0 nil :bankai) (:hs-k-g-k3 :hs-r-k3g 5.0 nil :bankai) (:hs-k-g-j2 :hs-r-j2s 4.0 nil :bankai)
    (:hs-k-g-j3 :hs-r-j3g 4.0 nil :bankai) (:hs-kb-stance nil 1.5 nil :bind) (:hs-kb-sengen :hs-b-sj 2.0 nil :bind)
    (:hs-na1 :hs-j1 2.0) (:hs-st-bind nil 3.0) (:hs-st-raiden nil 3.0)   ; (§26: the Shikai's core clips, the base form)
    (:hs-st-kari nil 3.0) (:hs-kr-tan :hs-n2a 2.5) (:hs-kr-ren :hs-n2b 1.7) (:hs-kr-sen :hs-n2c 3.0)   ; (§27.5: pointer 2 刈,
    (:hs-kr-ko :hs-as2 2.4) (:hs-kr-age :hs-as2b 2.4)                                               ;  38-43; CHIKUDEN 44,
    (:hs-chikuden :hs-n3b 2.0) (:hs-hoden :hs-sa-hoden 2.0 :wrapped)                                ;  放電 45 on a hit; §27.6's clips)
    (:hs-tsumuji :hs-as1 4.5))                                                                      ; (§27.10: AS1 TSUMUJI, 46)
  "83500+k (DUEL_HISAGI §21.8): the Bankai's strip slots, as *HS-STRIPS* plus the form: :bankai the ranged mode, :bind a
bind (the noose), :unwind the bind mode just ended (UNWIND's ring). Batch A2 (§24.2): 26-32 the ranged route links (K1
HOSOKU, spread K2 / K3, gathered K2 / K3G / J2s / J3G), 33 the bind's stance, 34 its Step + J SENGEN (§25.10). The core rebuild (§26, the Shikai, no form): 35 NA1, 36 the bind's stance, 37 the lightning's. Batch A3 (§24.3): 20 SP2 KAIBAKU-GEKI's own
clip (HIKIYOSE's, its stand-in, gone), 22 KOJO's and 6 SAHARAI's redrawn. §27.5 (the Shikai): 38 pointer 2 刈's stance, 39
TAN-GARI, 40 REN-GARI, 41 SEN-GARI, 42 KO-GARI, 43 KARI-AGE, 44 CHIKUDEN, 45 放電 HODEN (a hit: the burst on the victim;
views 0-1 show only him); since §27.6 44 / 45 their own clips :hs-chikuden / :hs-hoden at their S (the bind wound on the
victim, the lightning along the chain; NOKO's / RAIDEN's clips before); §27.10: 46 AS1 TSUMUJI :hs-tsumuji (4.5 m, where its
leap ends: the sickle thrown spinning flat into the victim, the cuts round him).")
(defparameter *hs-strips*
  '((:hs-s-stance nil 3.0) (:hs-s-walk-f nil 3.0) (:hs-s-run nil 3.0) (:hs-s-sen :hs-j1 2.0) (:hs-s-kaeshi :hs-j2 2.0)
    (:hs-s-rin :hs-j3 2.0) (:hs-s-kaeshi-1h :hs-j2-1h 2.0 :out) (:hs-s-rin-1h :hs-j3-1h 2.0 :out) (:hs-s-nage :hs-k1 6.0)
    (:hs-s-hiki :hs-k2 1.6 :hooked) (:hs-s-maki :hs-k2s 3.0) (:hs-s-kari :hs-k3 2.5) (:hs-s-hodoki :hs-k3h 2.0 :hooked)
    (:hs-s-modoshi :hs-modoshi 3.0 :out) (:hs-s-kaza :hs-kaza 3.0) (:hs-s-raiden :hs-raiden 6.0)
    (:hs-s-shibari :hs-shibari 3.0 :wrapped) (:hs-s-breaker nil 3.0) (:hs-s-kubikake :hs-breaker 1.0) (:hs-s-kari-aim nil 7.0)
    (:hs-s-kari-o :hs-kikon 7.0) (:hs-s-intro nil 3.0) (:hs-s-win nil 3.0)
    (:hs-s-nagi :hs-k1 5.0) (:hs-s-noko :hs-k2 4.0) (:hs-s-tsui :hs-k3 4.0) (:hs-s-tobi-kaeshi :hs-j2k 1.0)   ; (A1, §24.1:
    (:hs-s-tobi-rin :hs-j3k 1.0))                                                                       ;  slots 23-27)
  "83910+k: (clip move dist [sickle]): the clip, the move its frames are (NIL: idle), Kenpachi's distance, the sickle's
state (:out anchored 4 m ahead on the floor, :hooked anchored in him, :wrapped SHIBARI's contact).")
(defparameter *hs-r2-strips*
  '((:hs-k-st-shu nil 3.0 nil :bankai) (:hs-k-uchi :hs-r-sa 5.0 nil :bankai) (:hs-k-uchi :hs-r-sa-g 4.0 nil :bankai)
    (:hs-k-saharai :hs-r-n1a 4.0 nil :bankai) (:hs-k-ogi :hs-r-n1b 5.0 nil :bankai) (:hs-k-issei :hs-r-n1c 5.0 nil :bankai)
    (:hs-k-ransa :hs-r-as1 5.0 nil :bankai) (:hs-k-tataki :hs-r-n2b 4.0 nil :bankai) (:hs-k-sweep :hs-r-as2 4.0 nil :bankai)
    (:hs-k-jibashiri :hs-r-as2b 4.0 nil :bankai) (:hs-k-maki :hs-r-as3b 5.0 nil :bankai) (:hs-k-kake :hs-r-as3c 5.0 nil :bankai)
    (:hs-k-g-j2 :hs-r-j2s 4.0 nil :bankai) (:hs-k-g-j3 :hs-r-j3g 4.0 nil :bankai) (:hs-k-stance nil 3.0 nil :bankai)
    (:hs-k-na3 :hs-r-na3 5.0 nil :bankai) (:hs-k-na4 :hs-r-na4 5.0 nil :bankai)                     ; (§28.15: 15-18, the
    (:hs-k-g-na3 :hs-r-na3g 4.0 nil :bankai) (:hs-k-g-na4 :hs-r-na4g 4.0 nil :bankai))              ;  five J's own J3 / J4)
  "83560+k (batch 2a, DUEL_HISAGI §28.11): the core ranged mode's strip slots, as *HS-BK-STRIPS*: 0 聚 stance, 1 SA UCHI, 2 the
gathered UCHI (the bundle), 3 NS1a WA (L SAHARAI's clip at 18/14), 4 NS1b OGI, 5 NS1c ISSEI, 6 AS1 RANSA, 7 NS2b TATAKI, 8 AS2a
叩 (the sweep), 9 AS2b JIBASHIRI, 10 AS3b MAKI, 11 AS3c KAKE, 12 / 13 the gathered J2 / J5 at 4.5 m, 14 散 stance (for the
pair); §28.15: 15 J3 SHOBEN, 16 J4 SOBEN, 17 / 18 the gathered J3 / J4 (the five J's own J3 / J4).")
(defparameter *hs-kb-strips*
  '((:hs-kb-st-shibori nil 1.6 nil :bind) (:hs-kb-kagiyose :hs-b-n1a 4.0 nil :bind) (:hs-kb-kagiyose-giri :hs-b-as1 4.0 nil :bind)
    (:hs-kb-juji :hs-b-n1c 1.5 nil :bind) (:hs-kb-matoi :hs-b-n2a 2.0 :wrapped :bind) (:hs-kb-shime :hs-b-n2b 2.0 nil :bind)
    (:hs-kb-tsuri :hs-b-as2b 2.5 :wrapped :bind) (:hs-kb-san :hs-b-as3b 2.3 nil :bind))
  "83580+k (batch 2b, DUEL_HISAGI §28.12): the core bind's own clips' strip slots, as *HS-BK-STRIPS* (a bind on): 0 the 絞
stance, 1 NS1a KAGIYOSE, 2 AS1 KAGIYOSE-GIRI, 3 NS1c JŪJI, 4 NS2a MATOI (on a hit: the wrap), 5 NS2b / AS2a SHIME, 6 AS2b
TSURI (on a hit: hooked in his neck), 7 AS3b SAN (§28.13, 2.3 m: where J5's ender push leaves him).")
(defvar *hs-strip-k* 0 "The strip slot (83910+k, 83500+k, 83560+k, 83580+k).")
(defvar *hs-strip-tab* *hs-strips* "The strip slots in use: *HS-STRIPS* (83910+k) or *HS-BK-STRIPS* (83500+k).")
(defvar *hs-strip-fv* '(0 0) "The strip's frame and view (83940+3i+v).")
(defun hs-strip-frames (clip)
  "A clip's eight strip frames: a strike's 0, S/3, 2S/3, S-2, S, S+A, mid-recovery, end; else eight even steps."
  (let* ((c (find-clip clip)) (end (round (* 60 (clip-dur c)))) (s (clip-mark c :s)) (a (clip-mark c :a)))
    (if s
        (let* ((s (round (* 60 s))) (a (round (* 60 a))))
          (list 0 (round s 3) (round (* 2 s) 3) (max 0 (- s 2)) s a (+ a (round (- end a) 2)) end))
        (loop for k below 8 collect (round (* k (if (clip-loop c) (* 7/8 end) end)) 7)))))
(defun hs-strip-pose (a v)
  "Frame 0 of HS-STRIP-CINE: A in the strip slot's move at its frame (the sim state the draw hook reads), the clip there."
  (destructuring-bind (clip move dist &optional sickle form) (nth *hs-strip-k* *hs-strip-tab*)
    (declare (ignore dist form))
    (let* ((f (fighter a)) (st (hs a)) (fr (nth (first *hs-strip-fv*) (hs-strip-frames clip))) (mv (and move (find-move move))))
      (setf (hss-state st) :in (fighter-contact f) nil)
      (when mv (setf (fighter-state f) :move (fighter-move f) mv (fighter-phase f) :main (fighter-sf f) fr))
      (case sickle
        (:out (let ((p (pos-of a)))
                (multiple-value-bind (x z) (hs-anchor-point (aref p 0) (aref p 2) (yaw-of a) 4.0) (hs-anchor! a x z))
                (setf (hss-state st) :out)))
        (:hooked (let ((q (pos-of v))) (hs-anchor! a (aref q 0) (aref q 2)) (setf (hss-state st) :out)))
        (:wrapped (setf (fighter-contact f) :hit)))
      (setf (model-weapon (model a)) (if (and (eq clip :hs-s-intro) (< fr 70)) :hs-sealed :kazeshini))
      (play-clip a clip :blend 0 :time (/ fr 60.0))
      (setf (anim-blend (model-anim (model a))) 0f0))))
(defcine hs-strip-cine (a v :len 240 :hold 0)
  "The strip still (83940+3i+v, views 0-1): A alone on a white card at the slot's frame, held."
  (at 0 (card :white a) (hs-strip-pose a v)
      (destructuring-bind (clip move dist &optional sickle form) (nth *hs-strip-k* *hs-strip-tab*)
        (declare (ignore clip sickle))
        (let ((far (member move '(:hs-k1 :hs-raiden :hs-kikon :hs-k2s :hs-shibari :hs-k2 :hs-k3h :hs-modoshi :hs-k3
                                  :hs-n2a :hs-n2c :hs-as2 :hs-as2b :hs-n3b :hs-sa-hoden :hs-as1)))   ; (§27.5: 刈's 2.4-3 m, 縛雷's)
              (wide (and form (>= dist 4.0))))                         ; (the Bankai's long reach)
          (cond (wide (if (= (second *hs-strip-fv*) 0)
                          (shot-on a -90 12.0 1.6 :look 1.2 :ahead (min 4.6 (* 0.55 dist)))
                          (shot-on a 33 11.0 1.8 :look 1.2 :ahead 2.4)))
                ((= (second *hs-strip-fv*) 0)
                 (shot-on a -90 (if far 9.5 5.2) 1.2 :look 1.0 :ahead (if far (min 3.2 (* 0.5 dist)) 0.6)))
                (t (shot-on a 33 (if far 8.0 4.8) 1.4 :look 1.0 :ahead (if far 1.6 0.3))))
          (lens 40)))))
(defun hisagi-strip (c)
  "83910+k: the strip slot (83500+k: the Bankai's, *HS-BK-STRIPS*); 83940+3i+v: its frame i from view v (HS-STRIP-CINE; v 2
the match camera, frozen); 83964 lets go."
  (cond ((<= 83560 c 83579) (setf *hs-strip-tab* *hs-r2-strips* *hs-strip-k* (min (- c 83560) (1- (length *hs-r2-strips*)))))
        ((<= 83580 c 83589) (setf *hs-strip-tab* *hs-kb-strips* *hs-strip-k* (min (- c 83580) (1- (length *hs-kb-strips*)))))
        ((< c 83600) (setf *hs-strip-tab* *hs-bk-strips* *hs-strip-k* (min (- c 83500) (1- (length *hs-bk-strips*)))))
        ((< c 83940) (setf *hs-strip-tab* *hs-strips* *hs-strip-k* (min (- c 83910) (1- (length *hs-strips*)))))
        ((= c 83964) (abort-cine) (setf *cine-hold* nil *hitstop* 0))
        (t (multiple-value-bind (i v) (floor (- c 83940) 3)
             (setf *hs-strip-fv* (list (min i 7) v))
             (abort-cine) (setf *cine-hold* nil)
             (ensure-battle :hisagi :kenpachi)
             (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
             (setf (hss-bound (hs *p1*)) nil)
             (force-form *p1* :base)
             (place *p1* *p2* (third (nth *hs-strip-k* *hs-strip-tab*)))
             (full-gauges! *p1*) (full-gauges! *p2*)
             (let ((form (fifth (nth *hs-strip-k* *hs-strip-tab*))))     ; (the Bankai's: awakened, a bind)
               (when form (hs-reset *p1*) (hs-awaken-now! *p1*))
               (when (eq form :bind) (hs-bind-start! *p1*))
               (when (member form '(:bind :unwind)) (set-form *p1* :bankai-bind)))
             (if (< v 2)
                 (progn (setf *cine-hold* t) (start-cine 'hs-strip-cine *p1* *p2*))
                 (progn (hs-strip-pose *p1* *p2*) (hitstop 100000)))))))
(pushnew '(83910 83964 hisagi-strip) *char-debug* :test #'equal)
(pushnew '(83500 83549 hisagi-strip) *char-debug* :test #'equal)
(pushnew '(83560 83579 hisagi-strip) *char-debug* :test #'equal)   ; (batch 2a, §28.11: *HS-R2-STRIPS*)
(pushnew '(83580 83589 hisagi-strip) *char-debug* :test #'equal)   ; (batch 2b: *HS-KB-STRIPS*)

;;; ---------------------------------------------------------------- the cinematics' stills (debug 83965-83978)
;; 83965+c starts cinematic c from a fresh scene (0 the awakening: P1 Hisagi in his Shikai 6 m from an idle Kenpachi,
;; AWAKEN! itself; 1 刈れ, the Shikai 4 m from him; 2 KOSA, the ranged mode 7.5 m from him; 3 KOSHU, a bind 2 m from him;
;; 4 首掛 KUBIKAKE, the Shikai 4 m from him; 83977 is c 5, 綴雷電 TSUZURI RAIDEN, the same: DUEL_HISAGI §26.6; 83978 is c 6,
;; 刈 KARI, the same: §27.8), played
;; through; 83970+b restarts the last one held at its beat b's middle frame (*HS-CINE-BEATS*); 83976 lets go.
(defparameter *hs-cine-beats*
  '((10 36 60 85 117 152) (12 40 64 94 140 168) (12 42 75 113 135) (15 50 92 122 165) (10 35 66 94 125) (12 35 62 98 134)
    (12 37 53 84 92 128))
  "Each cinematic's beats' middle frames (83970+b; as built, DUEL_HISAGI §22.7, §26.6; 刈's two cuts in its beat 2 and
the Konpaku in its beat 3, §27.8).")
(defvar *hs-cine-k* 0 "The cinematic the last 83965+c picked.")
(defun hisagi-cine-scene (c)
  "83965+C's scene and its cinematic (see above)."
  (abort-cine)
  (ensure-battle :hisagi :kenpachi)
  (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
  (setf (hss-bound (hs *p1*)) nil (gauges-awakened (gauges *p1*)) nil)
  (force-form *p1* :base)
  (hs-reset *p1*)
  (place *p1* *p2* (case c (0 6.0) ((1 4 5 6) 4.0) (2 7.5) (t 2.0)))
  (full-gauges! *p1*) (full-gauges! *p2*)
  (case c
    (0 (awaken! *p1*))
    (1 (start-cine 'hs-kare-cine *p1* *p2*))
    (4 (start-cine 'hs-kubikake-cine *p1* *p2*))
    (5 (start-cine 'hs-raiden-cine *p1* *p2*))
    (6 (start-cine 'hs-kari-cine *p1* *p2*))
    (2 (hs-awaken-now! *p1*) (start-cine 'hs-kosa-cine *p1* *p2*))
    (t (hs-awaken-now! *p1*) (hs-bind-start! *p1*) (set-form *p1* :bankai-bind) (start-cine 'hs-koshu-cine *p1* *p2*))))
(defun hisagi-cine-debug (c)
  "83965-83969 / 83977 / 83978: cinematic c 0-4 / 5 / 6 played (HISAGI-CINE-SCENE); 83970-83975: the last one held at beat
b; 83976 lets go."
  (cond ((or (< c 83970) (>= c 83977))
         (setf *hs-cine-k* (case c (83977 5) (83978 6) (t (- c 83965))) *cine-hold* nil) (hisagi-cine-scene *hs-cine-k*))
        ((< c 83976)
         (let ((f (nth (- c 83970) (nth *hs-cine-k* *hs-cine-beats*))))
           (when f
             (setf *cine-hold* t)
             (hisagi-cine-scene *hs-cine-k*)
             (when *cine* (setf (cine-hold *cine*) f)))))
        (t (abort-cine) (setf *cine-hold* nil))))
(pushnew '(83965 83978 hisagi-cine-debug) *char-debug* :test #'equal)

;;; ---------------------------------------------------------------- the model sheet (debug 83980-83985: stills, a look)
;; Him alone on a white card (CARD, as Kenpachi's black robe) in the stance, the camera a cinematic shot: the front, his
;; left side (the badge), the back, three-quarters from his left front, the face, and Kazeshini held out to his right
;; (the weapon close-up). The match frames are 83000 / 83001 (the behind camera, 2 / 6 m from Kenpachi).
(defpose :hs-look-weapon (:base :hs-stance)            ; the right rod held out flat to his right, the left one hanging
  (:arm-r :flex 0 :side 86 :twist 90) (:elbow-r :flex 4) (:hand-r :flex -90 :twist 0))
(defclip :hs-look-weapon (1.0 :loop t :base :hs-look-weapon) (0))
(defparameter *hs-look-shots*
  '((0 4.6 1.0 0.92 35 0.0 :hs-stance) (90 4.6 1.0 0.92 35 0.0 :hs-stance) (180 4.6 1.0 0.92 35 0.0 :hs-stance)
    (35 4.6 1.0 0.92 35 0.0 :hs-stance) (0 0.85 1.66 1.64 35 0.0 :hs-stance) (0 2.0 1.3 1.3 40 1.0 :hs-look-weapon))
  "83980+k: (angle around his facing, distance, eye height, look height, lens, aim off to the shot's left, clip).")
(defparameter *hs-look-weapon-tall* '(0 5.5 1.3 1.2 30 2.2 :hs-look-weapon)
  "83985 on a tall screen: SHOT-ON halves the aim there (a quarter up close), so farther and aimed further left.")
(defvar *hs-look-k* 0 "The model sheet's shot (83980+k).")
(defcine hs-look-cine (a v :len 240 :hold 60)
  "The model sheet's held shot *HS-LOOK-K* (*HS-LOOK-SHOTS*) of A alone on a white card, 4 s; then the match again."
  (at 0 (destructuring-bind (ang dist h look fov off clip)
            (if (and (= *hs-look-k* 5) (portrait-p)) *hs-look-weapon-tall* (nth *hs-look-k* *hs-look-shots*))
          (card :white a) (cine-clip a clip :blend 0) (shot-on a ang dist h :look look :off off) (lens fov))))
(defun hisagi-look-scene (k)
  "83980+k: P1 Hisagi 8 m from an idle Kenpachi, the model sheet's shot K (HS-LOOK-CINE)."
  (setf *cine-hold* nil *hs-look-k* (min k (1- (length *hs-look-shots*))))
  (ensure-battle :hisagi :kenpachi)
  (place *p1* *p2* 8.0)
  (start-cine 'hs-look-cine *p1* *p2*))
(pushnew '(83980 83985 hisagi-look-debug) *char-debug* :test #'equal)
(defun hisagi-look-debug (c) (hisagi-look-scene (- c 83980)))

;;; ---------------------------------------------------------------- the Bankai's model sheet (debug 83986-83994: stills, a look)
;; 83986+k, k 0-5: him awakened (the ranged mode) alone on a white card, 8 m from an idle Kenpachi, held 4 s in a cinematic
;; shot (*HS-BK-LOOK-SHOTS*): the front, his left side, the back, three-quarters from his left front, Kazeshini held out
;; to his right, and a wide shot up at the orb, its curtain and his neck bundle; 83992 / 83993 the match (the behind camera) in the
;; ranged mode 2 / 6 m from Kenpachi; 83994 a bind 2 m from him (no damage dealt: the noose, the orb over the pair).
(defparameter *hs-bk-look-shots*
  '((0 4.6 1.0 0.92 35 0.0 :hs-stance) (90 4.6 1.0 0.92 35 0.0 :hs-stance) (180 4.6 1.0 0.92 35 0.0 :hs-stance)
    (35 4.6 1.0 0.92 35 0.0 :hs-stance) (0 2.0 1.3 1.3 40 1.0 :hs-look-weapon) (-30 19.0 2.0 4.6 50 -1.5 :hs-stance))
  "83986+k: (angle around his facing, distance, eye height, look height, lens, aim off to the shot's left, clip).")
(defvar *hs-bk-look-k* 0 "The Bankai sheet's shot (83986+k).")
(defcine hs-bk-look-cine (a v :len 240 :hold 60)
  "The Bankai sheet's held shot *HS-BK-LOOK-K* (*HS-BK-LOOK-SHOTS*) of A alone on a white card, 4 s; then the match again."
  (at 0 (destructuring-bind (ang dist h look fov off clip)
            (if (and (= *hs-bk-look-k* 4) (portrait-p)) *hs-look-weapon-tall* (nth *hs-bk-look-k* *hs-bk-look-shots*))
          (card :white a) (cine-clip a clip :blend 0) (shot-on a ang dist h :look look :off off) (lens fov))))
(defun hisagi-bankai-look (c)
  "83986+k: the Bankai's model sheet shot k (0-5, HS-BK-LOOK-CINE), 6 / 7 the ranged mode 2 / 6 m from Kenpachi in the
match, 8 a bind 2 m from him; P1 Hisagi awakened (HS-AWAKEN-NOW!), P2's CPU off."
  (let ((k (- c 83986)))
    (setf *cine-hold* nil)
    (abort-cine)
    (ensure-battle :hisagi :kenpachi)
    (when (brain *p2*) (setf (brain-off (brain *p2*)) t))
    (place *p1* *p2* (case k (6 2.0) (7 6.0) (8 2.0) (t 8.0)))
    (hs-reset *p1*)
    (full-gauges! *p1*) (full-gauges! *p2*)
    (hs-awaken-now! *p1*)
    (cond ((< k 6) (setf *hs-bk-look-k* k) (start-cine 'hs-bk-look-cine *p1* *p2*))
          ((= k 8) (hs-bind-start! *p1*) (set-form *p1* :bankai-bind)))))
(pushnew '(83986 83994 hisagi-bankai-look) *char-debug* :test #'equal)
