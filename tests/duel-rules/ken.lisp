(in-package :duel)
;;; ================================================================ Nozarashi v2: NOME, the three-cup ladder (§2.13)
(let* ((t1 (kit :kenpachi :nozarashi)) (t2 (kit :kenpachi :ryote)) (t3 (kit :kenpachi :nomihose))
       (m (kit-meter t1)) (ladder (getf m :ladder)) (gains (kit-meter-gain t1)))
  ;; 1. nome-gain: three sources only
  (check (and (~= (nome-gain 125 0 0 gains) 10.0) (~= (nome-gain 0 200 0 gains) 24.0) (~= (nome-gain 0 0 62 gains) 18.6)
              (~= (nome-gain 0 18 17 gains) (+ 2.16 5.1))))
  ;; 2. meter-drain: cup 1 never, cup 2 3/s after 180 idle frames (the user 2026-09-29: x2 of guard v3's 1.5), cup 3
  ;; 20/s from the first frame (a gain doesn't pause it)
  (flet ((dr (i nome idle) (let ((r (nth i ladder))) (meter-drain nome (second r) (third r) idle))))
    (check (and (~= (dr 0 30.0 999) 30.0) (~= (dr 1 50.0 179) 50.0) (~= (dr 1 50.0 180) 49.95) (~= (dr 2 90.0 0) (- 90.0 (/ 20.0 60)))
                (~= (dr 2 0.05 0) 0.0))))
  ;; 3. ladder-rung: hysteresis, several steps at once
  (check (and (= 0 (ladder-rung 39.9 0 ladder)) (= 1 (ladder-rung 40.0 0 ladder)) (= 1 (ladder-rung 25.0 1 ladder))
              (= 0 (ladder-rung 24.9 1 ladder)) (= 2 (ladder-rung 100.0 1 ladder)) (= 2 (ladder-rung 100.0 0 ladder))
              (= 2 (ladder-rung 50.0 2 ladder)) (= 1 (ladder-rung 49.9 2 ladder)) (= 0 (ladder-rung 0.0 2 ladder))))
  (check (equal (mapcar #'first ladder) '(:nozarashi :ryote :nomihose)))
  (check (and (~= (getf m :start) 10.0) (~= (getf m :max) 100.0)))
  ;; 4. drink-split: the taken half rounded up (real damage: at 1 Reishi a drink of 1 Soul Breaks)
  (check (and (equal (multiple-value-list (drink-split 35)) '(18 17)) (equal (multiple-value-list (drink-split 1)) '(1 0))
              (soul-break-p (- 1 (drink-split 1)))))
  ;; 5. drink as a guard: the guard's triangle (Breaker -> Guard Break, unguardable / behind -> hit), drink-adv
  (check (and (eq (resolve-contact :guard :breaker t) :guard-break) (eq (resolve-contact :guard :unguardable t) :hit)
              (eq (resolve-contact :guard :in-front nil) :hit) (= (drink-adv -2) -6) (= (drink-adv -12) -16)))
  (check (and (member :drink (kit-passives t3)) (not (member :drink (kit-passives t2))) (not (member :drink (kit-passives t1)))))
  ;; 6. the cut: Flash / Signature / SP x1.5 (RYOTE, NOMIHOSE), the J string untouched: blocked RYOTE J J J = 24,
  ;; K K K = 69 (into West's ward too: x*WARD-MULT*)
  (flet ((gv (k name) (hw-guard (svref (mv-hits (kit-move k name)) 0))))
    (check (and (= (cut-value 8 :quick) 8) (= (cut-value 14 :flash) 21) (= (cut-value 22 :sp) 33) (= (cut-value 12 nil) 12)))
    (check (= 24 (+ (cut-value (gv t2 :ke-r-j1) :quick) (cut-value (gv t2 :ke-r-j2) :quick) (cut-value (gv t2 :ke-r-j3) :quick))))
    (check (= 69 (+ (cut-value (gv t2 :ke-r-k1) :flash) (cut-value (gv t2 :ke-r-k2) :flash) (cut-value (gv t2 :ke-r-k3) :flash)))))
  ;; the ranged hits (guard v3): the Meteor, the cash-out, Buttagiru's crack, the heat cone, Taimatsu, Nadegiri are
  ;; :ranged; the blades (the J / K strings, the Kikon strikes, KYOKUJITSUJIN's guard-breaking blade) are not
  (flet ((rw (name i) (member :ranged (hw-flags (svref (mv-hits (find-move name)) i)))))
    (check (and (rw :ke-meteor 0) (rw :ke-meteor-n 0) (rw :ke-buttagiru 0) (rw :ya-kyoku 1) (rw :ya-taimatsu 0) (rw :ya-nadegiri 0)
                (not (rw :ya-kyoku 0)) (not (rw :ke-r-k1 0)) (not (rw :ke-kikon-n 0)) (not (rw :ya-kikon 0)) (not (rw :ke-n-f1 0)))))
  (check (and (member :cut (kit-passives t2)) (member :cut (kit-passives t3)) (not (member :cut (kit-passives t1)))))
  ;; 7. the Kikon count per cup (read at rush start) with the per-event cap
  (check (and (= 2 (kit-kikon-konpaku t1)) (= 3 (kit-kikon-konpaku t2)) (= 4 (kit-kikon-konpaku t3))
              (= 2 (kit-kikon-konpaku (kit :kenpachi :base))) (= 3 (kit-kikon-konpaku (kit :yamamoto :bankai-east)))
              (= 2 (kit-kikon-konpaku (kit :yamamoto :hellfire)))))
  (check (and (= 2 (nth-value 1 (kikon-result 9 2 nil))) (= 3 (nth-value 1 (kikon-result 9 2 t)))
              (= 3 (nth-value 1 (kikon-result 9 3 nil))) (= 4 (nth-value 1 (kikon-result 9 3 t)))
              (= 4 (nth-value 1 (kikon-result 9 4 nil))) (= 5 (nth-value 1 (kikon-result 9 4 t)))))   ; Kikon cap 4, Soul Break 5
  ;; the Soul Break rule (the user's decision 2026-09-27): the attacker's current count + 1, capped at 5 (a Kikon at 4);
  ;; NOMIHOSE's Soul Break = 5; the cinematic is the attacker's current form's Kikon cinematic
  (check (and (= 4 (nth-value 1 (kikon-result 9 5 nil))) (= 5 (nth-value 1 (kikon-result 9 5 t)))
              (= 5 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku t3) t))) (= 3 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku t1) t)))
              (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku t2) t))) (= 2 (nth-value 1 (kikon-result 2 (kit-kikon-konpaku t3) t)))
              (= 5 *soul-break-max-event*) (= 4 *kikon-max-event*)))
  (check (and (eq 'ken-kikon-cine (kit-kikon-cine (kit :kenpachi :base))) (eq 'ken-sky-split-cine (kit-kikon-cine t1))
              (eq 'ken-sky-split-cine (kit-kikon-cine t2)) (eq 'ken-sky-split-cine (kit-kikon-cine t3))
              (eq 'yama-kikon-cine (kit-kikon-cine (kit :yamamoto :base))) (eq 'yama-kikon-cine (kit-kikon-cine (kit :yamamoto :hellfire)))
              (eq 'yama-tenchi-cine (kit-kikon-cine (kit :yamamoto :bankai-east)))
              (eq 'yama-tenchi-cine (kit-kikon-cine (kit :yamamoto :bankai-west)))))
  ;; 8. register-kit: NOMIHOSE plays RYOTE's moves (not re-derived); RYOTE's meteor / LEAP as written; Hellfire unchanged
  (check (and (eq (kit-move t3 :ke-r-j3) (kit-move t2 :ke-r-j3)) (= 10 (mv-s (kit-move t3 :ke-r-j3)))
              (= 21 (mv-s (kit-move t3 :ke-r-k3))) (eq (kit-move t3 :ke-r-j2) (kit-move t2 :ke-r-j2))
              (~= (mv-reach (kit-move t2 :ke-r-j2)) 1.44) (~= (mv-reach (kit-move t2 :ke-r-j3)) 1.52)))
  (check (and (eq (kit-move t2 :ke-meteor) (find-move :ke-meteor)) (eq (kit-move t2 :ke-kikon-n) (find-move :ke-kikon-n))
              (eq (kit-command-move t3 :kikon) (find-move :ke-kikon-n))
              (eq (kit-move (kit :yamamoto :hellfire) :ya-j1) (find-move :ya-j1))))
  (check (and (= 10 (mv-s (kit-move t1 :ke-stance))) (= 11 (mv-s (kit-move t2 :ke-stance))) (= 11 (mv-s (kit-move t3 :ke-stance)))))
  ;; 9. the links: every J / K pair of every form combos (the string budget above); cup 3's K1 KUKAN-GIRI -> K2 too
  (check (< (hit-gap (kit-move t3 :ke-n-f1) (kit-next t3 :ke-n-f1 :f)) 0))
  ;; 10. the rift: at f20, cuts f40 (a 2 f window), 50 x1.2, guard 12, chip 20 %; on block inside N-F1's blockstun
  ;; (he acts at f43, the rift's 14 f blockstun frees the defender at f55: +8)
  (let* ((n (kit-move t3 :ke-n-f1)) (pa (mv-params n)) (bs (blockstun (mv-total n) (mv-s n) (mv-adv-block n))))
    (check (and (equal (mv-on-frame n) '((20 ken-rift))) (= 40 (+ 20 *rift-delay*)) (= 50 (getf pa :rift-dmg))
                (= 12 (getf pa :rift-guard)) (~= 0.2 (getf pa :rift-chip))
                (< (+ 20 *rift-delay*) (+ (mv-s n) bs))                         ; the rift cuts inside the blockstun
                (= 8 (- (+ 20 *rift-delay* *hazard-blockstun* 1) (1+ (mv-total n)))))))
  ;; 11. the cash-out: NOME 0 and cup 1 on its first frame, 390, the guard break only within 6 m
  (let ((c (kit-command-move t3 :sp1)))
    (check (and (eq (mv-name c) :ke-meteor-n) (= 390 (mv-dmg c)) (equal (first (mv-on-frame c)) '(0 ken-drink-dry))
                (~= 6.0 (getf (mv-params c) :crush-range)) (= -16 (mv-adv-block c)) (= 22 (hw-guard (svref (mv-hits c) 0)))
                (= 390 (hit-damage 390 (kit-atk-mods t1 0) nil 1 nil)))))
  ;; the looks: one hand in cup 1, two hands in cups 2 / 3 (cup 3 its own low stance and drink since DUEL_KEN_REWORK §6.2;
  ;; the Bankai keeps the old drink); the HUD names
  (check (and (eq (kit-stance t1) :ke-n-stance) (eq (kit-stance t2) :ke-r-stance) (eq (kit-stance t3) :ke-x-stance)
              (equal (mapcar #'kit-form-name (list t1 t2 t3)) '("KATATE" "RYOTE" "NOMIHOSE"))
              (eq (kit-aura t3) :nomihose) (eq (kit-drink-clip t3) :ke-x-drink) (eq (kit-drink-clip (kit :kenpachi :bankai)) :ke-drink)
              (equal (kit-respect-callout t2) "OMOSHIREE!")))
  ;; AI keys: the Kikon chance by cup, the cash-out rule (the near cash-out below 55 since the 2x drain: DUEL_NOZARASHI_V2.md,
  ;; "The CPU after the faster drain")
  (check (and (~= 0.25 (getf (kit-ai t1) :kikon-p)) (~= 0.5 (getf (kit-ai t2) :kikon-p)) (~= 0.9 (getf (kit-ai t3) :kikon-p))
              (equal (getf (kit-ai t3) :cashout) '(:punish 30 :near 6.0 :below 55.0)) (null (getf (kit-ai t2) :cashout)))))

;;; ================================================================ Kenpachi's Bankai and 片腕 (docs/duel/DUEL_KEN_BANKAI.md, the user's decisions 2026-09-28)
(let ((b (kit :kenpachi :bankai)) (a (kit :kenpachi :kataude)) (t3 (kit :kenpachi :nomihose)))
  ;; 1. entry: P, free and red; only cup 3 has it (once a match: nothing after it does)
  ;; the entry (2026-09-28): free with <= 4 of his own Konpaku (no longer red)
  (check (and (= *bankai-konpaku* 4) (bankai-allowed-p t 4) (bankai-allowed-p t 1) (not (bankai-allowed-p nil 4))
              (not (bankai-allowed-p t 5)) (not (bankai-allowed-p t 9))))
  (check (equal (loop for cf in *forms* when (kit-bankai-form (apply #'kit cf)) collect cf)
              '((:kenpachi :nomihose))))   ; (Lille's revival gone: his owl is the burst's, DUEL_LILLE_V3 R1)
  (check (and (eq (kit-bankai-form t3) :bankai) (eq (kit-cine b) 'ken-bankai-cine) (kit-awakening b) (kit-awakening a)))
  ;; 2. the arm: 4 pips; spend 4 -> 3, 0 refused; the crack at 300 f, idle back to 0; locked frames don't count;
  ;; 4 cracks = 1200 f of play
  (check (and (equal (multiple-value-list (pip-spend 4)) '(3 t)) (equal (multiple-value-list (pip-spend 0)) '(0 nil))
              (= 4 *arm-pips*) (= 300 *arm-crack*)))
  (check (and (equal (multiple-value-list (pip-step 4 298 nil)) '(4 299 nil)) (equal (multiple-value-list (pip-step 4 299 nil)) '(3 0 t))
              (equal (multiple-value-list (pip-step 4 299 t)) '(4 299 nil)) (equal (multiple-value-list (pip-step 0 5 nil)) '(0 6 nil))))
  (check (= 1200 (let ((p 4) (i 0) (n 0)) (loop while (plusp p) do (multiple-value-setq (p i) (pip-step p i nil)) (incf n)) n)))
  ;; 3. the pending burst: waits in the move that spent the last pip, in reactions / blockstun / air / down / Hoho, fires
  ;; on anything else (a later move included)
  (let ((m1 (kit-move b :ke-b-k1)) (m2 (kit-move b :ke-b-j1)))
    (check (and (not (burst-due-p m1 m1 :move)) (burst-due-p m1 m2 :move) (burst-due-p m1 nil :idle) (burst-due-p :none nil :guard)
                (not (burst-due-p m1 nil :stun)) (not (burst-due-p m1 nil :hoho)) (not (burst-due-p m1 nil :air))
                (not (burst-due-p m1 nil :guard-hit)) (not (burst-due-p nil nil :idle)) (burst-due-p :none m2 :move))))
  ;; 4. rend: armour -> a hit, a stance -> broken; a guard, the ward and a parry still hold
  (check (and (eq (resolve-contact :armor :rend t) :hit) (eq (resolve-contact :stance :rend t) :stance-break)
              (eq (resolve-contact :stance-in :rend t) :stance-break) (eq (resolve-contact :guard :rend t) :blocked)
              (eq (resolve-contact :guard :rend t :ward t :in-front nil) :blocked) (eq (resolve-contact :parry :rend t) :parried)
              (eq (resolve-contact :armor) :armored)))
  ;; the bite beats every defence but iframes; +9 on hit (his J1, S 8, combos after it)
  (let* ((bite (kit-command-move b :sig)) (w (svref (mv-hits bite) 0)))
    (check (and (eq (mv-name bite) :ke-b-bite) (member :grab (mv-flags bite)) (member :unguardable (hw-flags w))
                (~= 1.5 (mv-reach bite)) (eq :crumple (hw-react w))))
    (check (every (lambda (st) (eq :hit (resolve-contact st :unguardable t :rend t))) '(:guard :stance :stance-in :armor :parry)))
    (check (and (null (resolve-contact :invuln :unguardable t)) (eq :hit (resolve-contact :guard :unguardable t :ward t))))
    (check (= 9 (on-hit-adv bite))) (check (> (on-hit-adv bite) (mv-s (kit-command-move b :q)))))
  ;; the pip commands: K, L, SP1, SP2, I, O (and every latched K link: the latch reads :f); J, Step, Hoho, Burst, U, P don't
  (check (and (equal (getf (kit-pips b) :cmds) '(:f :sig :sp1 :sp2 :breaker :kikon)) (eq :kataude (getf (kit-pips b) :to))
              (kit-pip-cmd-p b :f) (kit-pip-cmd-p b :kikon) (not (kit-pip-cmd-p b :q)) (not (kit-pip-cmd-p b :awaken))
              (null (kit-pips a)) (null (kit-pips t3))))
  ;; 7. the Kikon counts: Bankai 4, 片腕 3 (the universal awakened count); their Soul Breaks 5 / 4 (the cap 5); the
  ;; Soul Break cinematic is the form's Kikon cinematic
  (check (and (= 4 (kit-kikon-konpaku b)) (= 3 (kit-kikon-konpaku a))
              (= 5 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku b) t))) (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku a) t)))
              (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku b) nil)))))
  (check (and (eq 'ken-oni-kikon-cine (kit-kikon-cine b)) (eq 'ken-kikon-cine (kit-kikon-cine a))
              (equal "MAPPUTATSU" (mv-callout (kit-command-move b :kikon))) (eq :ke-kikon (mv-name (kit-command-move a :kikon)))))
  ;; 8. B1 / B4: no NOME in the Bankai (no :meter-gain, no :ladder, the pips' meter), no cut; x1.2; U still DRINK
  (check (and (null (kit-meter-gain b)) (null (getf (kit-meter b) :ladder)) (= 4 (getf (kit-meter b) :max)) (= 4 (getf (kit-meter b) :start))
              (not (member :cut (kit-passives b))) (member :drink (kit-passives b)) (~= 1.2 (kit-mult b))
              (null (kit-meter-gain a)) (null (kit-meter a)) (not (member :drink (kit-passives a))) (~= 1.0 (kit-mult a))))
  ;; the K links: guard 28 / 28 / 36 (x2 of a K), rend; TATE-GOTO guard-crushes its whole line; SP2's :land is the punch
  (flet ((g (name) (hw-guard (svref (mv-hits (kit-move b name)) 0))))
    (check (and (= 28 (g :ke-b-k1)) (= 28 (g :ke-b-k2)) (= 28 (g :ke-b-k2s)) (= 36 (g :ke-b-k3))
                (every (lambda (n) (member :rend (hw-flags (svref (mv-hits (kit-move b n)) 0)))) '(:ke-b-k1 :ke-b-k2 :ke-b-k3 :ke-b-punch)))))
  (let ((sp (kit-command-move b :sp1)))
    (check (and (eq (mv-name sp) :ke-b-split) (member :guard-crush (hw-flags (svref (mv-hits sp) 0))) (~= 6.0 (mv-reach sp))
                (eq :ke-b-punch (mv-name (kit-next b :ke-charge :land))) (eq :ke-flurry (mv-name (kit-next a :ke-charge :land)))
                (= 2 (kit-command-cost b :sp2)) (= 1 (kit-command-cost b :sp1)))))
  ;; one pip per J / K string (the playtest decision 2026-09-28): owed from its first K link or its O ender, charged once
  ;; he is out of the string (a whiff, a hit on him, the end, an SP / L cancel); JJJ owes none
  (check (and (not (string-pip-due-p t :move :quick)) (not (string-pip-due-p t :move :flash)) (not (string-pip-due-p t :move :kikon))
              (string-pip-due-p t :idle nil) (string-pip-due-p t :stun nil) (string-pip-due-p t :guard-hit nil)
              (string-pip-due-p t :move :sp) (string-pip-due-p t :move :sig) (not (string-pip-due-p nil :idle nil))))
  ;; the last pip's move comes out in full (the user's report 2026-09-28: the burst cut it): the pending burst follows
  ;; the move's chain (a latched link, SP2's punch started by its hook, the O ender after a link 3: MOVE-FOLLOWS-P) and
  ;; fires only once he is out of it; a new move of his own (J1 after the bite) is cut as before
  (let* ((charge (kit-move b :ke-charge)) (punch (kit-next b :ke-charge :land)) (k1 (kit-move b :ke-b-k1))
         (k2 (kit-next b :ke-b-k1 :f)) (k3 (kit-next b :ke-b-k2 :f)) (o (kit-command-move b :kikon))
         (bite (kit-command-move b :sig)) (j1 (kit-command-move b :q)) (split (kit-command-move b :sp1)))
    (check (and (move-follows-p b charge punch) (move-follows-p b k1 k2) (move-follows-p b k3 o) (move-follows-p b k1 (kit-next b :ke-b-k1 :q))
                (not (move-follows-p b bite j1)) (not (move-follows-p b split j1)) (not (move-follows-p b k1 o))))
    (flet ((burst-frame (pending frames)             ; ARM-STEP's rule over (state move) frames: the frame the burst fires
             (loop for (st m) in frames for i from 0
                   do (when (and (typep pending 'move) m (not (eq m pending)) (move-follows-p b pending m)) (setf pending m))
                   when (burst-due-p pending m st) return i)))
      (check (and (= 3 (burst-frame bite `((:move ,bite) (:move ,bite) (:move ,bite) (:idle nil))))          ; L
                  (= 3 (burst-frame split `((:move ,split) (:move ,split) (:move ,split) (:idle nil))))   ; SP1
                  (= 4 (burst-frame charge `((:move ,charge) (:move ,punch) (:move ,punch) (:move ,punch) (:idle nil))))   ; SP2
                  (= 4 (burst-frame k2 `((:move ,k2) (:move ,k3) (:move ,o) (:stun nil) (:idle nil))))   ; a string + O
                  (= 2 (burst-frame bite `((:move ,bite) (:guard-hit nil) (:move ,j1))))))))   ; a new move is cut
  ;; route damage on hit (x1.2, before Cornered; each hit rounded): KKK 444 (1 pip), JJK 272 (1)
  (flet ((route-dmg (first presses)
           (loop for n in (route b first presses) for i from 1
                 sum (hit-damage (mv-dmg (kit-move b n)) (kit-atk-mods b 0) nil i nil))))
    (check (and (= 444 (route-dmg :f '((:f) (:f)))) (= 272 (route-dmg :q '((:q) (:f)))))))
  ;; 6. 片腕: the sword moves at reach x0.7 (J1 0.73 -> the J floor 1.4, K1 1.96, K3 1.89), the kick, the Breaker and O as written; B2:
  ;; every form's Breaker strike out-reaches its trigger, every Kikon strike *KIKON-TRIGGER* + 0.3
  (check (and (~= *j-reach-min* (mv-reach (kit-move a :ke-j1))) (~= 1.96 (mv-reach (kit-move a :ke-k1))) (~= 1.89 (mv-reach (kit-move a :ke-k3)))
              (~= *j-reach-min* (mv-reach (kit-next a :ke-j2 :q))) (~= *breaker-reach* (mv-reach (kit-command-move a :breaker)))
              (~= 2.4 (mv-reach (kit-command-move a :kikon))) (= 7 (mv-s (kit-move a :ke-j1)))))
  (dolist (cf *forms*)
    (let ((k (apply #'kit cf)))
      (let ((br (kit-command-move k :breaker)))        ; (Rukia's rooted zero has none)
        (check (or (null br) (> (+ (mv-reach br) 0.34) *breaker-trigger*))))   ; (with the thinnest hurt radius)
      (check (> (mv-reach (kit-command-move k :kikon)) (+ *kikon-trigger* 0.3)))))
  ;; the looks: the oni body in both, the aura only in the Bankai, the cracks hidden in 片腕, the wreck hidden in the Bankai
  (check (and (eq :kenpachi-oni (kit-body b)) (eq :kenpachi-oni (kit-body a)) (eq :oni (kit-aura b)) (null (kit-aura a))
              (member :arm-wreck (kit-hide b)) (not (member :arm-wreck (kit-hide a))) (member :crack-4 (kit-hide a))
              (equal (kit-form-name b) "BANKAI") (equal (kit-form-name a) "KATAUDE")))
  ;; AI keys: the entry rule on cup 3, the Bankai's K links / hurry / the opponent's wait
  (check (and (equal (getf (kit-ai t3) :bankai) '(:p 0.9 :opp-below 0.6 :opp-konpaku 4 :own-konpaku 4))
              (~= 0.6 (getf (kit-ai b) :string-k)) (= 90 (getf (kit-ai b) :pip-hurry))
              (equal (getf (kit-ai b) :opp-intent) '(:zone 2 :defend 2)) (null (getf (kit-ai b) :cashout)))))

