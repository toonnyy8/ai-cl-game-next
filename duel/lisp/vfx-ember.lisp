;;;; vfx-ember.lisp — the two warm-colour looks the shared dispatch still calls after the retired kits' files left main: the
;;;; EMBER star (VFX-EMBER, its stamp %ST-EMBER: a parry / armoured hit, feedback.lisp) and the charge at a held blade
;;;; (VFX-CHARGE, draw.lisp's default hold look). Moved verbatim, names kept, out of yama-vfx.lisp by refactor batch B3
;;;; (REFACTOR_2026-11 §11.3 R2); B8c may re-home or retire them. Cosmetic: RND01, the fx clock, 0 B a frame.
(in-package :duel)

(defun-fast vfx-charge (x y z k dt)
  "Charging at the blade (x y z), K 0..1 (§4.1 Shiranui, Phase 5): anticipation — 6 FIRE / EMBER shards converging on
it (a new drawing every 1/12 s, looping inward), flame scraps sucked in — and a FIRE disc growing in drawn steps (1/6 of
the charge each) with a white HIT core disc. (The caller adds the focus lines when the charge starts.)"
  (with-floats (x y z k dt)
    (let* ((dr (drawing-no)) (kq (* 0.16667f0 (i->f (f->i (* 6f0 (f-clamp k 0f0 1f0)))))))
      (declare (single-float dr kq))
      (with-cam (rx ry rz ux uy uz)
        (dotimes (i 6)
          (let* ((f (i->f i)) (a (+ (* 1.0472f0 f) (* 0.4f0 (hash01 f 3.3f0))))
                 (ph (- 1f0 (* 0.25f0 (i->f (mod (+ (f->i dr) i) 4))))) (rr (* (+ 0.35f0 (* 0.5f0 k)) (+ 0.4f0 (* 0.8f0 ph))))
                 (c (f-cos a)) (sn (f-sin a)) (wx (+ (* c rx) (* sn ux))) (wy (+ (* c ry) (* sn uy))) (wz (+ (* c rz) (* sn uz))))
            (declare (single-float f a ph rr c sn wx wy wz))
            (fx-shard (+ x (* rr wx)) (+ y (* rr wy)) (+ z (* rr wz)) (- wx) (- wy) (- wz) (* 0.22f0 (+ 0.6f0 k)) 0.03f0 0.05f0
                      (+ f dr) (if (evenp i) +pal-fire+ +pal-ember+) 0.9f0 :push 0.3f0)))
        nil)
      (fx-disc x y z (+ 0.07f0 (* 0.26f0 kq)) 0.3f0 (+ 50f0 (i->f (mod (f->i dr) 5))) +pal-fire+ 0.95f0 :push 0.2f0)
      (fx-disc x y z (+ 0.03f0 (* 0.08f0 kq)) 0.2f0 (+ 55f0 (i->f (mod (f->i dr) 5))) +pal-hit+ 0.98f0 :push 0.25f0)   ; the core
      (dotimes (i (n-of (+ 20f0 (* 40f0 k)) dt))
        (let* ((dx (rnd-range -1f0 1f0)) (dy (rnd-range -1f0 1f0)) (dz (rnd-range -1f0 1f0))
               (l (f-max 0.05f0 (f-hypot dx dy dz))) (r (+ 0.6f0 (* 0.5f0 k))) (sp (/ r (* l 0.3f0))))
          (declare (single-float dx dy dz l r sp))
          (%t-blob (+ x (* r (/ dx l))) (+ y (* r (/ dy l))) (+ z (* r (/ dz l))) (- (* sp dx)) (- (* sp dy)) (- (* sp dz))
                   0.3f0 (+ 0.03f0 (* 0.04f0 k)) 0f0 0.2f0 +pal-fire+)))
      (%light x y z 1f0 0.5f0 0.15f0 (+ 3f0 (* 3f0 k)) (+ 0.5f0 k) 5))))

(defun-fast %st-ember (o)
  "Armour / parry / scorch in the Bankai stances: an EMBER star and 4 ember shards (not guard's steel hexagon; no
dark backing: effects carry no black rim, user review 2); envelope 1 2 2 8."
  (declare (fixnum o))
  (with-stamp (o)
    (let* ((a (hit-age age)))
      (declare (single-float a))
      (fx-envelope (es k fl ph) (a 1 2 2 8)
        (if (= ph 1)
            (%flash x y z (* sc 0.2f0) seed)
            (when (< ph 5)
              (%star x y z (* sc 0.15f0) (* sc es 0.55f0) 7 sdx sdy 0.06f0 seed +pal-ember+ k)
              (%shards-out 4 x y z sdx sdy a 4f0 (* sc 0.25f0) (* sc 0.04f0) +pal-ember+ k seed 2f0)))
        (= ph 5)))))

(defun-fast vfx-ember (x y z &key (dx 0.0) (dz -1.0) (scale 1.0))
  "An EMBER star over charcoal at (x y z) (a Bankai armour / parry / scorch hit), hit direction (DX DZ)."
  (with-floats (x y z dx dz scale)
    (stamp :ember x y z :dx dx :dz dz :scale scale)
    (flash-light x y z 1.0 0.5 0.2)
    nil))
