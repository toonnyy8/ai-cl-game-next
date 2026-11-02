(in-package :duel)
(setf *core-on* nil)   ; (these checks quote the damage numbers of before the core system's scale, 2026-10-27)
;;; ================================================================ the Kikon counts, the ranged hits (what stayed of the cups' block; the
;;; cups KATATE / RYOTE / NOMIHOSE and their NOME went 2026-11-03, DUEL_KEN_V3 §8)
(flet ((rw (name i) (member :ranged (hw-flags (svref (mv-hits (find-move name)) i)))))
  (check (and (rw :ke-meteor 0) (rw :ke-buttagiru 0) (rw :ya-kyoku 1) (rw :ya-taimatsu 0) (rw :ya-nadegiri 0)
              (not (rw :ya-kyoku 0)) (not (rw :ke-kikon-n 0)) (not (rw :ya-kikon 0)))))
(check (and (= 2 (kit-kikon-konpaku (kit :kenpachi :nozarashi))) (= 2 (kit-kikon-konpaku (kit :kenpachi :base)))
            (= 3 (kit-kikon-konpaku (kit :yamamoto :bankai-east))) (= 2 (kit-kikon-konpaku (kit :yamamoto :hellfire)))))
(check (and (= 2 (nth-value 1 (kikon-result 9 2 nil))) (= 3 (nth-value 1 (kikon-result 9 2 t)))
            (= 3 (nth-value 1 (kikon-result 9 3 nil))) (= 4 (nth-value 1 (kikon-result 9 3 t)))
            (= 4 (nth-value 1 (kikon-result 9 4 nil))) (= 5 (nth-value 1 (kikon-result 9 4 t)))
            (= 4 (nth-value 1 (kikon-result 9 5 nil))) (= 5 (nth-value 1 (kikon-result 9 5 t)))
            (= 5 *soul-break-max-event*) (= 4 *kikon-max-event*)))
(check (and (eq 'ken-kikon-cine (kit-kikon-cine (kit :kenpachi :base))) (eq 'ken-sky-split-cine (kit-kikon-cine (kit :kenpachi :nozarashi)))
            (eq 'yama-kikon-cine (kit-kikon-cine (kit :yamamoto :base))) (eq 'yama-tenchi-cine (kit-kikon-cine (kit :yamamoto :bankai-east)))))

;;; ================================================================ Kenpachi's Bankai and 片腕 (docs/duel/DUEL_KEN_BANKAI.md, the user's decisions 2026-09-28)
(let ((b (kit :kenpachi :bankai)))
  ;; 1. entry: P, free and red; only cup 3 has it (once a match: nothing after it does)
  ;; the entry (2026-09-28): free with <= 4 of his own Konpaku (no longer red)
  ;; the entry (2026-10-31): free with his SPIRIT DRIVE full, whatever his Konpaku (DUEL_SUBLIMATION §3)
  (check (and (bankai-allowed-p t t) (not (bankai-allowed-p nil t)) (not (bankai-allowed-p t nil))))
  (check (null (loop for cf in *forms* when (kit-bankai-form (apply #'kit cf)) collect cf)))   ; (V3: P enters it from no form; the
  (check (and (eq (kit-cine b) 'ken-bankai-cine) (kit-awakening b)))                           ;  Shikai's J7 + SP does, KEN-AS-PICK)
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
  (check (and (equal (getf (kit-pips b) :cmds) '(:f :sig :sp1 :sp2 :breaker :kikon)) (null (getf (kit-pips b) :to))
              (kit-pip-cmd-p b :f) (kit-pip-cmd-p b :kikon) (not (kit-pip-cmd-p b :q)) (not (kit-pip-cmd-p b :awaken))
              (null (kit-pips (kit :kenpachi :nozarashi)))))
  ;; 7. the Kikon counts: Bankai 4, 片腕 3 (the universal awakened count); their Soul Breaks 5 / 4 (the cap 5); the
  ;; Soul Break cinematic is the form's Kikon cinematic
  (check (and (= 4 (kit-kikon-konpaku b))
              (= 5 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku b) t))) (= 4 (nth-value 1 (kikon-result 9 (kit-kikon-konpaku b) nil)))))
  (check (and (eq 'ken-oni-kikon-cine (kit-kikon-cine b)) (equal "MAPPUTATSU" (mv-callout (kit-command-move b :kikon)))))
  ;; 8. B1 / B4: no NOME in the Bankai (no :meter-gain, no :ladder, the pips' meter), no cut; x1.2; U still DRINK
  (check (and (null (kit-meter-gain b)) (null (getf (kit-meter b) :ladder)) (= 4 (getf (kit-meter b) :max)) (= 4 (getf (kit-meter b) :start))
              (not (member :cut (kit-passives b))) (member :drink (kit-passives b)) (~= 1.2 (kit-mult b))))
  ;; the K links: guard 28 / 28 / 36 (x2 of a K), rend; TATE-GOTO guard-crushes its whole line; SP2's :land is the punch
  (flet ((g (name) (hw-guard (svref (mv-hits (kit-move b name)) 0))))
    (check (and (= 28 (g :ke-b-k1)) (= 28 (g :ke-b-k2)) (= 28 (g :ke-b-k2s)) (= 36 (g :ke-b-k3))
                (every (lambda (n) (member :rend (hw-flags (svref (mv-hits (kit-move b n)) 0)))) '(:ke-b-k1 :ke-b-k2 :ke-b-k3 :ke-b-punch)))))
  (let ((sp (kit-command-move b :sp1)))
    (check (and (eq (mv-name sp) :ke-b-split) (member :guard-crush (hw-flags (svref (mv-hits sp) 0))) (~= 6.0 (mv-reach sp))
                (eq :ke-b-punch (mv-name (kit-next b :ke-charge :land)))
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
    (flet ((burst-frame (pending frames)             ; KEN-ARM-STEP's rule (ken-meter.lisp) over (state move) frames: the frame the burst fires
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
  (dolist (cf *forms*)
    (let ((k (apply #'kit cf)))
      (let ((br (kit-command-move k :breaker)))        ; (Rukia's rooted zero has none)
        (check (or (null br) (> (+ (mv-reach br) 0.34) *breaker-trigger*))))   ; (with the thinnest hurt radius)
      (check (> (mv-reach (kit-command-move k :kikon)) (+ *kikon-trigger* 0.3)))))
  ;; the looks: the oni body, its aura, the wreck hidden
  (check (and (eq :kenpachi-oni (kit-body b)) (eq :oni (kit-aura b)) (member :arm-wreck (kit-hide b)) (equal (kit-form-name b) "BANKAI")))
  ;; AI keys: the Bankai's K links / hurry / the opponent's wait
  (check (and (~= 0.6 (getf (kit-ai b) :string-k)) (= 90 (getf (kit-ai b) :pip-hurry))
              (equal (getf (kit-ai b) :opp-intent) '(:zone 2 :defend 2)) (null (getf (kit-ai b) :cashout)))))


;; the DANGAI boss (DUEL_ROGUE §5): the base kit's :boss hook (ken-meter.lisp KEN-BOSS); the Bankai keeps the arm's tick
(check (and (eq (kit-hook (kit :kenpachi :base) :boss) 'ken-boss) (eq (kit-hook (kit :kenpachi :bankai) :tick) 'ken-tick)
            (kit-pips (kit :kenpachi :bankai))))

(setf *core-on* t)

;;; ---- the core system's base kit (DUEL_KEN_CORE, 2026-10-29)
(let* ((k (kit :kenpachi :base)))
  (labels ((m (n) (gethash n (kit-moves k))) (cls (n) (kit-class k (m n))))
    ;; classes: NS1-3 segments, AS1-3 segments, the SAs
    (check (every (lambda (n) (eq (cls n) :ns)) '(:ke-n1a :ke-n1b :ke-n1c :ke-n2a :ke-n2b :ke-n3a :ke-n3b :ke-n3c)))
    (check (every (lambda (n) (eq (cls n) :as)) '(:ke-as1 :ke-as2 :ke-as2b :ke-as3 :ke-as3b :ke-as3c)))
    (check (every (lambda (n) (eq (cls n) :sa)) '(:ke-sa :ke-sa-r :ke-sa-c1 :ke-sa-c2 :ke-sa-c3)))
    ;; the tells: every NS opener S >= 14; the stance per pointer
    (check (every (lambda (n) (>= (mv-s (m n)) 14)) '(:ke-n1a :ke-n2a :ke-n3a)))
    (check (equal (getf (kit-core k) :stances) '(:ke-st-chain :ke-st-rush :ke-st-kamae)))
    ;; AS n = n segments; only the last one of a route knocks down / launches
    (check (and (null (getf (mv-params (m :ke-as1)) :ns-next)) (eq (getf (mv-params (m :ke-as2)) :ns-next) :ke-as2b)
                (eq (getf (mv-params (m :ke-as3)) :ns-next) :ke-as3b) (eq (getf (mv-params (m :ke-as3b)) :ns-next) :ke-as3c)))
    (check (every (lambda (n) (eq (getf (mv-spec (m n)) :on-hit) :stagger)) '(:ke-as2 :ke-as3 :ke-as3b)))
    ;; NS2: one armour hit on each segment, lasting through the active frames (KEN-ARMOR), its SA scales with the cancels
    (check (and (= 1 (mv-armor-hits (m :ke-n2a))) (= 1 (mv-armor-hits (m :ke-n2b)))
                (eq (getf (mv-params (m :ke-n2a)) :sa) :ke-sa-r) (getf (mv-params (m :ke-sa-r)) :clash-scale)))
    ;; NS3: three charges that hit nothing, each SA arms a bigger charge x (1.3 < 1.6 < 2.0)
    (check (every (lambda (n) (zerop (mv-a (m n)))) '(:ke-n3a :ke-n3b :ke-n3c)))
    (check (< (getf (mv-params (m :ke-sa-c1)) :charge-mult) (getf (mv-params (m :ke-sa-c2)) :charge-mult) (getf (mv-params (m :ke-sa-c3)) :charge-mult)))
    ;; the hooks reach every cup
    (check (loop for (f . kk) in (gethash :kenpachi *kits*) always (and (eq 'ken-armor (kit-hook kk :armor)) (eq 'ken-clash (kit-hook kk :clash)))))))

;;; ---- the Bankai on the core system (DUEL_KEN_CORE §8, 2026-11-02): 1 the maw, 2 the broken cleaver, 3 the arm that burns
(let ((b (kit :kenpachi :bankai)))
  (labels ((m (x) (gethash x (kit-moves b))) (cls (x) (kit-class b (m x))) (p (x k) (getf (mv-params (m x)) k)))
    (check (every (lambda (x) (eq (cls x) :ns)) '(:ke-b-n1a :ke-b-n1b :ke-b-n1c :ke-b-n2a :ke-b-n2b :ke-b-n3a :ke-b-n3b :ke-b-n3c)))
    (check (every (lambda (x) (eq (cls x) :as)) '(:ke-b-as1 :ke-b-as2 :ke-b-as2b :ke-b-as3 :ke-b-as3b :ke-b-as3c)))
    (check (every (lambda (x) (eq (cls x) :sa)) '(:ke-b-sa1 :ke-b-sa2 :ke-b-sa3)))
    ;; the chains, each pointer's SA, the openers' tier 16
    (check (and (eq (p :ke-b-n1a :ns-next) :ke-b-n1b) (eq (p :ke-b-n1b :ns-next) :ke-b-n1c) (eq (p :ke-b-n2a :ns-next) :ke-b-n2b)
                (eq (p :ke-b-n3a :ns-next) :ke-b-n3b) (eq (p :ke-b-n3b :ns-next) :ke-b-n3c) (eq (p :ke-b-as2 :ns-next) :ke-b-as2b)
                (eq (p :ke-b-as3 :ns-next) :ke-b-as3b) (eq (p :ke-b-as3b :ns-next) :ke-b-as3c)
                (eq (p :ke-b-n1a :sa) :ke-b-sa1) (eq (p :ke-b-n2a :sa) :ke-b-sa2) (eq (p :ke-b-n3a :sa) :ke-b-sa3)))
    (check (every (lambda (x) (= 16 (mv-s (m x)))) '(:ke-b-n1a :ke-b-n2a :ke-b-n3a)))
    (check (equal (mapcar (lambda (x) (mv-s (m x))) '(:ke-b-n1b :ke-b-n1c :ke-b-n2b :ke-b-n3b :ke-b-n3c)) '(12 14 18 14 20)))
    ;; the arm: pointer 3's segments and AS3's last burn one pip each, nothing else; no crack clock, no KATAUDE
    (check (equal (loop for x in '(:ke-b-n1a :ke-b-n1b :ke-b-n1c :ke-b-n2a :ke-b-n2b :ke-b-n3a :ke-b-n3b :ke-b-n3c
                                   :ke-b-as1 :ke-b-as2 :ke-b-as2b :ke-b-as3 :ke-b-as3b :ke-b-as3c)
                        collect (or (p x :pips) 0))
                  '(0 0 0 0 0 1 1 1 0 0 0 0 0 1)))
    (check (and (null (getf (kit-pips b) :crack t)) (null (getf (kit-pips b) :to))))
    ;; no NS segment knocks down or launches (the SA can follow any, §443); each AS's last segment does
    (check (notany (lambda (x) (member (getf (mv-spec (m x)) :on-hit) '(:knockdown :launch)))
                   '(:ke-b-n1a :ke-b-n1b :ke-b-n1c :ke-b-n2a :ke-b-n2b :ke-b-n3a :ke-b-n3b :ke-b-n3c :ke-b-as2 :ke-b-as3 :ke-b-as3b)))
    (check (equal (mapcar (lambda (x) (getf (mv-spec (m x)) :on-hit)) '(:ke-b-as1 :ke-b-as2b :ke-b-as3c)) '(:knockdown :launch :knockdown)))
    (check (equal (mapcar (lambda (x) (mv-dmg (m x))) '(:ke-b-n1a :ke-b-n1b :ke-b-n1c :ke-b-n2a :ke-b-n2b :ke-b-n3a :ke-b-n3b :ke-b-n3c
                                                        :ke-b-as1 :ke-b-as2 :ke-b-as2b :ke-b-as3 :ke-b-as3b :ke-b-as3c :ke-b-sa1 :ke-b-sa2 :ke-b-sa3))
                  '(70 90 100 90 100 130 150 220 120 60 110 55 60 200 40 45 50)))))

;;; the cadence by form (the user, 2026-11-02, DUEL_KEN_CORE §7.2): the NS openers' startup tier, the hitstop by damage
(check (and (= 4 (hs-by-damage 35 *ken-hs-dmg*)) (= 7 (hs-by-damage 60 *ken-hs-dmg*)) (= 8 (hs-by-damage 70 *ken-hs-dmg*))
            (= 9 (hs-by-damage 80 *ken-hs-dmg*)) (= 10 (hs-by-damage 90 *ken-hs-dmg*)) (= 14 (hs-by-damage 140 *ken-hs-dmg*))
            (= 14 (hs-by-damage 210 *ken-hs-dmg*)) (= 4 (hs-by-damage 0 *ken-hs-dmg*))))
(check (equal (mapcar (lambda (f) (kit-open-s (kit :kenpachi f))) '(:base :nozarashi :bankai)) '(14 nil 16)))   ; (the Shikai as written, V3 §9)
(check (every (lambda (fm) (destructuring-bind (f s . names) fm
                             (every (lambda (n) (= s (mv-s (mv :kenpachi f n)))) names)))
              '((:base 14 :ke-n1a :ke-n2a) (:nozarashi 16 :ke-s-n1a) (:nozarashi 14 :ke-s-n2a) (:bankai 16 :ke-b-n1a :ke-b-n2a :ke-b-n3a))))
;; a charge keeps its length; a shifted opener hits on its new S (its window moved, its clip sped up to match)
(check (= 20 (mv-s (mv :kenpachi :base :ke-n3a))))
(let ((old (find-move :ke-n2a)) (new (mv :kenpachi :base :ke-n2a)))
  (check (and (= 22 (mv-s old)) (= 14 (hw-from (aref (mv-hits new) 0))) (= (mv-a old) (mv-a new)) (= (mv-r old) (mv-r new))
              (~= (* (mv-clip-speed new) 14) (* (mv-clip-speed old) 22)))))
;; every Kenpachi hit freezes by its damage; another character keeps the kind's (Ichigo's J1 4)
(check (and (= 14 (hw-hs (aref (mv-hits (mv :kenpachi :nozarashi :ke-s-n2e)) 0))) (= 4 (hw-hs (aref (mv-hits (mv :kenpachi :base :ke-j1)) 0)))
            (= 11 (hw-hs (aref (mv-hits (mv :kenpachi :base :ke-as2b)) 0)))
            (null (kit-hs-dmg (kit :ichigo :base))) (null (kit-open-s (kit :ichigo :base)))))

;;; ---- the Shikai V3 (DUEL_KEN_V3 §3-§9, 2026-11-03): two pointers by grip, the unlock level L, the bursts, the special string
(let ((k (kit :kenpachi :nozarashi)) (b (kit :kenpachi :bankai)))
  (labels ((m (x) (gethash x (kit-moves k))) (cls (x) (kit-class k (m x))) (p (x key) (getf (mv-params (m x)) key)))
    (check (every (lambda (x) (eq (cls x) :ns)) '(:ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1d :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e)))
    (check (every (lambda (x) (eq (cls x) :as)) '(:ke-s-as1 :ke-s-as1b :ke-s-as1c :ke-s-as1d :ke-s-as2 :ke-s-as2b :ke-s-as2c :ke-s-as2d
                                                   :ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2)))
    (check (eq (cls :ke-s-sa) :sa))
    (check (and (= 2 (length (getf (kit-core k) :ns))) (equal (getf (kit-core k) :as-by-press) '(1 1 2))))
    ;; the level each segment needs (§5.3: P1 L0 the lunge only, P2 L0 the jab and the flick; J4-J7 at L3)
    (check (equal (mapcar (lambda (x) (or (p x :lv) 0)) '(:ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1d :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e
                                                           :ke-s-as1 :ke-s-as1b :ke-s-as1c :ke-s-as1d :ke-s-as2 :ke-s-as2b :ke-s-as2c :ke-s-as2d
                                                           :ke-s-j3 :ke-s-j4 :ke-s-j5 :ke-s-j6 :ke-s-j7))
                  '(0 1 2 3 3 0 0 1 2 3 0 1 2 3 0 1 2 3 0 3 3 3 3)))
    (check (and (every (lambda (x) (p x :special-as)) '(:ke-s-j4 :ke-s-j5 :ke-s-j6)) (p :ke-s-j7 :bankai-as) (not (p :ke-s-j7 :special-as))))
    (check (every (lambda (x) (p x :lv-up)) '(:ke-s-as1 :ke-s-as1b :ke-s-as1c :ke-s-as1d :ke-s-as2 :ke-s-as2b :ke-s-as2c :ke-s-as2d)))
    (check (notany (lambda (x) (p x :lv-up)) '(:ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2)))
    (check (every (lambda (x) (equal (p x :burst) '(100 150 200 260))) '(:ke-s-burst1 :ke-s-burst2)))
    ;; §9's figures: S and damage; the openers carry the tell (>= 14); no NS segment knocks down (the SA may follow any)
    (check (equal (mapcar (lambda (x) (mv-s (m x))) '(:ke-s-j1 :ke-s-j2 :ke-s-j3 :ke-s-j4 :ke-s-j5 :ke-s-j6 :ke-s-j7 :ke-s-sa
                                                       :ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1d :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e
                                                       :ke-s-burst1 :ke-s-burst2 :ke-s-sp1 :ke-s-sp2))
                  '(9 9 11 9 9 10 12 8 16 12 12 10 14 14 10 16 14 18 14 12 12 20)))
    (check (equal (mapcar (lambda (x) (mv-dmg (m x))) '(:ke-s-j1 :ke-s-j3 :ke-s-j7 :ke-s-n1a :ke-s-n1e :ke-s-n2a :ke-s-n2e :ke-s-as1d :ke-s-as2d :ke-s-sp2))
                  '(40 55 70 70 100 45 140 110 150 260)))
    (check (equal (map 'list #'hw-dmg (mv-hits (m :ke-s-sp1))) '(60 60 120)))
    (check (equal (map 'list #'hw-dmg (mv-hits (m :ke-s-n1d))) '(35 35)))
    (check (notany (lambda (x) (member (getf (mv-spec (m x)) :on-hit) '(:knockdown :launch)))
                   '(:ke-s-n1a :ke-s-n1b :ke-s-n1c :ke-s-n1e :ke-s-n2a :ke-s-n2b :ke-s-n2c :ke-s-n2d :ke-s-n2e)))
    ;; the hooks are the Shikai's only: the Bankai (where J7 + SP lands) neither reads L nor picks ASs nor refuses J links
    (check (and (eq (kit-hook k :lv) 'ken-lv) (eq (kit-hook k :as-pick) 'ken-as-pick) (eq (kit-hook k :hit) 'ken-hit) (eq (kit-hook k :link-ok) 'ken-link-ok)))
    (check (notany (lambda (h) (kit-hook b h)) '(:lv :as-pick :hit :link-ok)))
    (check (and (eq (kit-hook b :tick) 'ken-tick) (null (kit-hook (kit :kenpachi :base) :lv))))
    (check (and (getf (kit-meter k) :lv) (= 3 (getf (kit-meter k) :max)) (= 0 (getf (kit-meter k) :start)) (null (kit-meter-gain k)) (null (kit-open-s k))))
    ;; the J string: J1-J3, then J4-J7 (the links KEN-LINK-OK gates)
    (check (equal (loop for n = :ke-s-j1 then (mv-name (kit-next k n :q)) while (kit-next k n :q) collect (mv-name (kit-next k n :q)))
                  '(:ke-s-j2 :ke-s-j3 :ke-s-j4 :ke-s-j5 :ke-s-j6 :ke-s-j7)))))
