(in-package :duel)
;;; ================================================================ Bankai stances (docs/duel/DUEL_YAMA_REWORK.md, the user's decisions 2026-09-27)
(let ((east (kit :yamamoto :bankai-east)) (west (kit :yamamoto :bankai-west)))
  ;; the forms: East x1.0 dealt + the pierce, x*BANKAI-TAKEN* 1.5 taken, projectile-cut; U goes West (:guard-to). West
  ;; x1.0 / x1.0, the ward + the parry's scorch; every command but L / SP1 drops to East (:drop-to / :keep); both
  ;; awakened and permanent
  (check (and (~= (kit-mult east) 1.0) (~= (kit-taken east) 1.5) (~= *bankai-taken* 1.5) (null (kit-blade-chip east))
              (equal (kit-passives east) '(:projectile-cut :pierce)) (eq (kit-guard-to east) :bankai-west)
              (null (kit-drop-to east))))
  (check (and (~= (kit-mult west) 1.0) (~= (kit-taken west) 1.0) (null (kit-blade-chip west))
              (equal (kit-passives west) '(:ward :scorch)) (null (kit-guard-to west))
              (eq (kit-drop-to west) :bankai-east) (equal (kit-keep west) '(:sig :sp1))))
  (check (and (kit-awakening west) (null (kit-duration west)) (eq (kit-awaken-form (kit :yamamoto :base)) :bankai-east)
              (null (kit-guard-to (kit :yamamoto :base))) (null (kit-drop-to (kit :kenpachi :nomihose)))))
  (check (and (eq (mv-name (kit-command-move east :sp1)) :ya-kyoku) (eq (mv-name (kit-command-move west :sp1)) :ya-w-parry)
              (eq (mv-name (kit-command-move east :sig)) :ya-e-kyokko) (eq (mv-name (kit-command-move west :sig)) :ya-w-shonetsu)))
  ;; East <-> West (fighter.lisp KIT-DROP): in West J, K, O, I, Shift+L drop to East first (East's own move starts),
  ;; L and Shift+K stay West; East drops nothing
  (check (and (every (lambda (c) (eq (kit-drop west c) :bankai-east)) '(:q :f :sp2 :breaker :kikon))
              (null (kit-drop west :sig)) (null (kit-drop west :sp1))
              (notany (lambda (c) (kit-drop east c)) *kit-commands*)
              (eq (kit-command-move (find-kit :yamamoto (kit-drop west :q)) :q) (kit-command-move east :q))))
  (check (and (= (hit-damage 100 nil (kit-def-mods east) 1 nil) 150) (= (hit-damage 100 nil (kit-def-mods west) 1 nil) 100)))
  ;; the derivation rule: East's inherited moves derived (-1 f; reach x1.15, but a Breaker's stays unscaled); West takes East's versions
  (check (and (= (mv-s (kit-command-move east :breaker)) 7) (~= (mv-reach (kit-command-move east :breaker)) *breaker-reach* 0.01)
              (eq (kit-move west :ya-e-j2) (kit-move east :ya-e-j2)) (eq (kit-command-move west :q) (kit-command-move east :q))))
  (check (and (= (mv-s (kit-move east :ya-e-j1)) 8) (= (mv-s (kit-move east :ya-e-j3)) 8) (= (mv-s (kit-move west :ya-w-counter)) 6)))
  (dolist (name '(:ya-kaka :ya-tenchi))
    (let ((a (kit-move east name)) (b (kit-move west name)))
      (check (and (eq a b) (= (mv-s a) (mv-s (find-move name))) (equal (mv-on-frame a) (mv-on-frame b))))))
  (check (~= (mv-clip-speed (kit-move east :ya-e-j2)) 1.0))                   ; East's own clip at its own frames (DUEL_YAMA_TYBW §3.2)
  ;; KYOKKO cancels a landed J2 in time; a blocked J1 -> J2 leaves a gap >= Step's first iframe and < 7
  (let* ((k east) (q1 (kit-command-move k :q)) (q2 (kit-next k (mv-name q1) :q)))
    (check (< (- (mv-s (kit-command-move k :sig)) (hitstun (hw-react (svref (mv-hits q2) 0)))) 0))
    (check (and (>= (blocked-gap q1 q2) (first *step-iframes*)) (< (blocked-gap q1 q2) 7))))
  ;; the ender-gap rule: after a string ender that leaves the victim near, his Step fits before the next E-Q1
  (progn
    (check (= 5 (on-hit-adv (find-move :ya-e-j3))))
    (dolist (m (loop for (nil nil to) in (kit-strings east) collect (kit-move east to)))
      (let ((w (svref (mv-hits m) 0)))
        (when (or (member (hw-react w) '(:flinch :stagger)) (and (eq (hw-react w) :knockback) (<= (hw-kb w) 1.5)))
          (check (>= (- (mv-s (kit-command-move east :q)) (on-hit-adv m)) (first *step-iframes*)))))))
  ;; KYOKKO: S15 A3 R26, 85, a 1.6 m lunge, a 4.6 m line, pierce x2, guard 22 (an ender), cooldown 100, cancels a landed
  ;; Q / F; no armour anywhere in either stance
  (let* ((l (kit-command-move east :sig)) (w (svref (mv-hits l) 0)))
    (check (and (eq (mv-kind l) :sig) (member :cancel (mv-flags l)) (= (mv-cooldown l) 100) (~= (mv-slide l) 1.6)
                (~= (getf (mv-params l) :pierce-mult) 2.0) (= (hw-guard w) 22) (eq (hw-react w) :knockback)
                (~= (aref (first (hw-vols w)) 2) 4.6) (> (mv-cooldown l) (+ (mv-total l) *chain-lead*)))))
  ;; SHONETSU JIGOKU: S16 R24 (40 f, no hit window: the pillars do it), on-frames 0 (the tell) and 16, 45 x 2 in a 2 m
  ;; ring, guard 12, cooldown 150, not a cancel (a West Q / F would already have dropped him to East)
  (let* ((l (kit-command-move west :sig)) (pa (mv-params l)))
    (check (and (eq (mv-kind l) :sig) (zerop (length (mv-hits l))) (= (mv-total l) 40) (= (mv-cooldown l) 150)
                (not (member :cancel (mv-flags l))) (equal (mapcar #'first (mv-on-frame l)) '(0 16))
                (= (getf pa :dmg) 45) (= (getf pa :hits) 2) (~= (getf pa :size) 2.0) (= (getf pa :guard) 12)
                (= (move-end-frame (mv-s l) (mv-a l) (mv-r l) (mv-whiff l) nil t) 40))))
  (check (every (lambda (m) (zerop (mv-armor-hits (find-move m)))) '(:ya-e-kyokko :ya-w-shonetsu :ya-w-parry :ya-w-counter)))
  ;; KYOKUJITSUJIN: the blade [18,20) breaks guard (and a ward), the tip's cone [20,23) 25 deg x 9 m, 130, knockback
  ;; 4 m, blockable (never a break), -16; the blade's short knockback keeps the victim in the cone
  (let* ((m (kit-command-move east :sp1)) (bl (svref (mv-hits m) 0)) (co (svref (mv-hits m) 1)))
    (check (and (= 2 (length (mv-hits m))) (= (hw-from bl) 18) (= (hw-to bl) 20 (hw-from co)) (= (hw-to co) 23)
                (= (hw-dmg bl) 90) (= (hw-dmg co) 130) (equal (hw-flags bl) '(:guard-crush)) (equal (hw-flags co) '(:ranged))
                (eq (hw-react bl) :knockback) (~= (hw-kb bl) 0.5) (eq (hw-react co) :knockback) (~= (hw-kb co) 4.0)
                (= (mv-adv-block m) -16) (= (hw-guard co) 22)))
    (check (and (~= (aref (first (hw-vols co)) 1) 9.0) (~= (* 2 (aref (first (hw-vols co)) 2)) (deg 25))))
    (check (and (eq (resolve-contact :guard :guard-crush (member :guard-crush (hw-flags bl))) :guard-break)
                (eq (resolve-contact :guard :guard-crush (member :guard-crush (hw-flags bl)) :ward t) :guard-break)
                (eq (resolve-contact :guard :guard-crush (member :guard-crush (hw-flags co))) :blocked)))
    (flet ((hits (v x z) (vol-hit-p v 0f0 0f0 0f0 0f0 -1f0 (float x 1f0) 0f0 (float z 1f0) 0.36f0 1.65f0 0f0)))
      (check (and (hits (first (hw-vols co)) 0 -8.5) (hits (first (hw-vols co)) 2.0 -8.5) (not (hits (first (hw-vols co)) 3.0 -8.5))
                  (not (hits (first (hw-vols co)) 0 -9.6)) (hits (first (hw-vols bl)) 0 -2.0) (not (hits (first (hw-vols bl)) 0 -3.2))))))
  ;; the ward vs Kenpachi: his base J J J blocked = 24 x*WARD-MULT* 1.1 = 26.4: the 4th string crushes a full
  ;; gauge; RYOTE's K K K (the cut) 69 x 1.1 = 75.9: the 2nd
  (flet ((gv (k name) (hw-guard (svref (mv-hits (kit-move k name)) 0))))
    (let ((qs (* *ward-mult* (+ (gv (kit :kenpachi :base) :ke-j1) (gv (kit :kenpachi :base) :ke-j2) (gv (kit :kenpachi :base) :ke-j3))))
          (kk (* *ward-mult* (+ (cut-value (gv (kit :kenpachi :ryote) :ke-r-k1) :flash) (cut-value (gv (kit :kenpachi :ryote) :ke-r-k2) :flash)
                                (cut-value (gv (kit :kenpachi :ryote) :ke-r-k3) :flash)))))
      (check (and (< (* 3 qs) *gg-max*) (>= (* 4 qs) *gg-max*) (< kk *gg-max*) (>= (* 2 kk) *gg-max*)))))
  ;; GOKUI GAESHI: the parry catches a melee hit on f2-25 (24 f = its active frames; Ichigo's window, 2026-10-01), not a hazard, not an
  ;; unguardable one; a Breaker breaks it; parried = a block for the attacker (no string, no Kikon); the counter
  ;; (150, knockback) lands inside the parried attacker's stagger: guaranteed
  (let ((p (kit-command-move west :sp1)) (c (kit-next west :ya-w-parry :land)))
    (check (and (not (parry-frame-p 1)) (parry-frame-p 2) (parry-frame-p 25) (not (parry-frame-p 26))
                (= (mv-a p) (1+ (- (second *parry-window*) (first *parry-window*)))) (= (mv-s p) (first *parry-window*))
                (member :parry (mv-flags p)) (zerop (length (mv-hits p))) (= (mv-total p) 46) (= (kit-command-cost west :sp1) 1)))
    (check (and (eq (resolve-contact :parry) :parried) (eq (resolve-contact :parry :in-front nil) :parried)
                (eq (resolve-contact :parry :breaker t) :stance-break) (eq (resolve-contact :parry :hazard t) :hit)
                (eq (resolve-contact :parry :unguardable t) :hit) (eq (contact-of :parried) :block)
                (null (kikon-outcome t :parried nil))))
    (check (and (eq (mv-name c) :ya-w-counter) (= (mv-dmg c) 150) (eq (hw-react (svref (mv-hits c) 0)) :knockback)
                (< (1+ (mv-s c)) *parry-stun*) (= *parry-stun* 32) (= *scorch* 15))))
  ;; South, the bind: 20/1/34 (55 f), 2 bars and no cooldown (the user's decision 2026-09-28: the bars are its limiter); the
  ;; grab 16 f after the stab; 40 + bound 60; the follow-up window 41; unguardable (guard, stance, armour, parry
  ;; don't stop it; iframes do); it only opens a combo (else a flinch) and books 2 hits: 70 flash-step Bursts out
  (let* ((m (kit-command-move east :sp2)) (pa (mv-params m)))
    (check (and (= (mv-total m) 55) (= (kit-command-cost east :sp2) 2) (= (mv-cooldown m) 0) (member :bind (mv-flags m))
                (= (getf pa :delay) 16) (= (getf pa :dmg) 40) (= (getf pa :stun) *bind-stun* 60) (~= (getf pa :range) 10.0)
                (= 41 (- (+ (mv-s m) (getf pa :delay) (getf pa :stun)) (mv-total m)))))
    (check (and (eq (resolve-contact :guard :unguardable t) :hit) (eq (resolve-contact :stance :unguardable t) :hit)
                (eq (resolve-contact :armor :unguardable t) :hit) (eq (resolve-contact :parry :unguardable t :hazard t) :hit)
                (null (resolve-contact :invuln :unguardable t))))
    (check (equal (multiple-value-list (combo-step :bind nil 0 0 0)) '(:bind 2 0 0)))       ; the opener: 2 hits
    (check (equal (multiple-value-list (combo-step :bind nil 1 0 0)) '(:flinch 2 0 0)))     ; in a combo: a flinch
    (check (and (burst-allowed-p (burst-mode :stun nil (nth-value 1 (combo-step :bind nil 0 0 0)) nil) *fs-burst* nil)
                (not (burst-allowed-p (burst-mode :stun nil (nth-value 1 (combo-step :bind nil 0 0 0)) nil) (1- *fs-burst*) nil))))
    (check (equal (multiple-value-list (combo-step :flinch nil 2 0 0)) '(:flinch 3 0 0)))   ; the follow-up is hit 3
    ;; the escapes: a Step pressed from the stab's f16 carries him past the grab disc; one pressed f28-33 has
    ;; its iframes over the grab (f36-37); a Hoho pressed f23-35 too; walking doesn't (16 f of walk < the disc)
    (let ((grab (+ (mv-s m) (getf pa :delay))) (r (+ (getf pa :radius) 0.45)))
      (check (and (= grab 36) (> *step-distance* r) (< (* *walk-kenpachi* (/ (getf pa :delay) 60.0)) r)
                  (<= (+ 33 (first *step-iframes*)) grab) (>= (+ 28 (second *step-iframes*)) (1+ grab))
                  (<= (+ 35 (first *hoho-iframes*)) grab) (>= (+ 23 (second *hoho-iframes*)) (1+ grab)))))
    (multiple-value-bind (x z) (cast-point 0.0 0.0 12.0 0.0 10.0) (check (and (~= x 10.0) (~= z 0.0))))
    (multiple-value-bind (x z) (cast-point 0.0 0.0 3.0 4.0 10.0) (check (and (~= x 3.0) (~= z 4.0))))))

