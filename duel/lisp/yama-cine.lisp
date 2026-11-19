;;;; yama-cine.lisp — Yamamoto's cinematics on his core kit (DUEL_YAMA_CORE §7.3, batch 1 stage C): the old kit's two that still run on
;;;; today's cinema API, back from the branch `retired-kits` (`git show retired-kits:duel/lisp/yama.lisp`) unchanged but for two lines
;;;; (below). The grammar is cinema.lisp's (docs/style/STYLE_STORM_DESIGN.md §5). Placeholders until the storyboards (§7.4): the Kikon
;;;; cinematics of 東 / 西 / 南 are the generic SOUL-BREAK-CINE; VFX-AWAKEN-BURST has no :bankai / :bankai-burst look today (it draws nothing).
(in-package :duel)

(defcine yama-tenchi-cine (a v :len 168 :hold 26)
  "Tenchi Kaijin (北's Kikon: the NS 北 wave's strike and AS 北 carry it as their :cine; §4.1 of DUEL_YAMA_REWORK, paced by user review 3):
beat 0 in the Bankai's grey; a long black card, Yamamoto silhouetted with a white back-rim under the 北 / 天地灰尽 stamp, silence; the slash:
a white / ink two-tone frame with the hard white slash, then a manga page; the victim flakes into ash (an ink splash) in the same shot; a
low wide of him standing in the grey world. (The old script hid the victim's body after the ash, MODEL-ALPHA 0, which nothing restores
after the reset: dropped.)"
  (at 0 (face-each-other a v 2.4)
      (cine-clip a :ya-tenchi :blend 2 :speed (/ 18.0 68.0)) (cine-clip v :sh-kikon-victim :blend 4)
      (hold-both a v 12) (impact-frame :negative 2) (cine-grade :spot))
  (at 12 (card :black a) (back-rim 56) (shot-on a 70 3.2 0.9 :look 1.2 :off 0.8) (lens 42 -8) (silence 56)
      (caption "天地灰尽" :mark "北" :reading "TENCHI KAIJIN" :sub "ZANKA NO TACHI" :side 0 :hanko t))
  (during (68 168) (vfx-tenchi-slash (/ (- cf 68) 60.0) 0.8))
  (at 68 (card nil) (play-sfx :kikon-slash) (impact-frame :two-tone 4) (shot-pair a v 1 5.0 1.4) (lens 55))
  (at 72 (impact-frame :manga 12))
  (at 86 (multiple-value-bind (x y z) (actor-point v 1.0) (vfx-ash-burst x y z) (vfx-konpaku-shatter x y z 3))
      (impact-splash-at v 0.0 14 0.07)
      (play-sfx :konpaku-shatter) (play-sfx :sizzle) (shake 0.2 0.3))
  (at 110 (shot-on a -35 4.6 0.5 :look 1.3) (lens 48) (caption-exit)))

(defcine yama-bankai-cine (a v :len 138 :hold 72)
  "BANKAI (the awakening's, the kit :bankai's :cine; paced by user review 3): beat 0; every flame in the arena is drawn into the blade
(close, low, wide-angle, focus lines); from behind, in silence, the world drains to grey; the reveal, held long: a negative, then Yamamoto
a black silhouette on a white card, the only colour the ember line of the charred blade, the 卍解 / 残火の太刀 stamp in black with its
splash; the charcoal burst and the plaza cracks in the grey world."
  (at 0 (cine-clip a :ya-bankai :blend 3 :speed (/ 2.2 1.8)) (cine-clip v (kit-stance (kit-of v)) :blend 6)
      (setf (model-weapon (model a)) :ryujin-jakka)
      (hold-both a v 12) (impact-frame :negative 2)
      (play-sfx :awaken-rise))
  (at 12 (let ((p (pos-of a))) (vfx-awaken-burst (aref p 0) 0.0 (aref p 2) :bankai))   ; every flame sucked in (no look today)
      (shot-on a 25 1.5 0.45 :look 1.45) (lens 88 6) (focus-lines 36))
  (during (12 60) (let ((p (pos-of a)))
                    (vfx-charge (aref p 0) 2.4 (aref p 2) u (cine-dt))
                    (vfx-aura (aref p 0) 0.0 (aref p 2) 2.2 :hellfire (/ cf 60.0) (cine-dt) :k (- 1.0 u))))
  (at 40 (silence 20) (shot-on a 200 3.0 0.8 :look 1.4) (lens 50))
  (at 44 (cine-grade :spot))                             ; the form's grey (main.lisp FORM-GRADE takes over after)
  (at 60 (setf (model-weapon (model a)) :zanka)
      (impact-frame :negative 2) (card :white a) (silhouette-black a)
      (caption "卍解" :kanji2 "残火の太刀" :reading "BANKAI" :sub "ZANKA NO TACHI" :side 0 :ink t)
      (play-sfx :awaken-boom) (shake 0.25 0.4)
      (shot-on a 15 4.4 0.6 :look 1.25 :off 0.9) (lens 40))
  (at 118 (card nil) (unsilhouette) (shot-on a -30 6.5 1.6 :look 1.1) (lens 50)
      (let ((p (pos-of a)))                              ; back in the grey world: the charcoal burst, the plaza cracks
        (vfx-awaken-burst (aref p 0) 0.0 (aref p 2) :bankai-burst)
        (stage-crack-add (aref p 0) (aref p 2) 3.0)
        (stage-crack-add (+ (aref p 0) 3.5) (- (aref p 2) 2.0) 2.2)
        (stage-crack-add (- (aref p 0) 3.0) (+ (aref p 2) 2.5) 2.4))))
