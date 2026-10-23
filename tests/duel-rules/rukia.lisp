(in-package :duel)
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
  ;; the DANGAI boss (DUEL_ROGUE §5): only *RUN-BOSS*'s clones are free; the :boss hook is the base kit's
  (check (and (let ((*run-boss* nil)) (not (clone-free-p :x))) (let ((*run-boss* :x)) (and (clone-free-p :x) (not (clone-free-p :y))))
              (eq 'ichigo-boss (kit-hook (kit :ichigo :base) :boss))))
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

