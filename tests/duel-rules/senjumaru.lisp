(in-package :duel)
;;; ================================================================ Senjumaru (docs/duel/DUEL_SENJUMARU.md §10's host tests)
(let ((b (kit :senjumaru :base)) (t1 (kit :senjumaru :tsuji1)) (t6 (kit :senjumaru :tsuji6)))
  ;; the stitches: a hit sews 2, any other contact 1, a parry nothing, capped at 6; 179 idle frames keep them, the 180th
  ;; drops one, then one per 30; a lock pauses the clock
  (check (and (= 2 (hari-sew 0 :hit)) (= 2 (hari-sew 0 :counter)) (= 1 (hari-sew 0 :blocked)) (= 1 (hari-sew 0 :absorbed))
              (= 1 (hari-sew 0 :armored)) (= 0 (hari-sew 0 :parried)) (= 0 (hari-sew 0 nil)) (= 6 (hari-sew 5 :hit))
              (= 6 (hari-sew 6 :blocked))))
  (flet ((run (n idle frames &optional locked)
           (let ((fell 0)) (dotimes (i frames) (multiple-value-bind (n2 i2 f) (hari-step n idle locked) (setf n n2 idle i2) (when f (incf fell))))
             (values n fell))))
    (check (and (= 6 (run 6 0 179)) (= 5 (run 6 0 180)) (= 5 (run 6 0 209)) (= 4 (run 6 0 210)) (= 0 (run 6 0 330))
                (= 1 (run 6 0 329)) (= 6 (run 6 0 400 t)) (= 0 (run 0 50 10)))))
  (check (and (= 180 (hari-falls-in 3 0)) (= 1 (hari-falls-in 3 179)) (= 30 (hari-falls-in 3 180)) (= 1 (hari-falls-in 3 209))))
  ;; 悪い癖: spikes from f10, 2 f apart, 10 each, unguardable, :spare; the last holds him to f38, she is free at f32: +6, no
  ;; combo; the -k copy after a K link lands every spike inside the K link's stagger (A 4 + 8 + 2 x 5 = 22 < 26)
  (let ((l (kit-command-move b :sig)) (lk (kit-l-link b :sj-k1)))
    (check (and (eq :sj-warui-kuse (mv-name l)) (= 8 (mv-s l)) (= 32 (mv-total l)) (= 10 (getf (mv-params l) :first))
                (= 6 (- (+ (getf (mv-params l) :first) (* *hari-gap* 5) *hari-last-stun*) (mv-total l)))
                (eq :sj-warui-kuse-k (mv-name lk)) (= 6 (mv-s lk)) (= 8 (getf (mv-params lk) :first))
                (< (+ 4 (getf (mv-params lk) :first) (* *hari-gap* 5)) (hitstun :stagger))
                (>= (mv-reach lk) 9.0) (= 13 *hari-dmg*) (every (lambda (k) (kit-l-link b k)) '(:sj-k1 :sj-k2 :sj-k2s :sj-k3)))))
  ;; the stitches pay: a hit JJJ is 6; blocked, the universal 24 / 46 of guard and 3 stitches either way
  (check (= 6 (reduce #'hari-sew '(:hit :hit :hit) :initial-value 0)))
  (check (= 3 (reduce #'hari-sew '(:blocked :blocked :blocked) :initial-value 0)))
  ;; the Shikai's grid: the lightest (the user, 2026-10-01: J x0.9, K x0.8: J1 25, JJJ 82, KKK 147 on hit; the Bankai's
  ;; K1 45, K3 58)
  (check (and (= 25 (mv-dmg (kit-command-move b :q))) (= 82 (+ 25 (mv-dmg (mv :senjumaru :base :sj-j2)) (mv-dmg (mv :senjumaru :base :sj-j3))))
              (= 147 (+ (mv-dmg (kit-command-move b :f)) (mv-dmg (mv :senjumaru :base :sj-k2)) (mv-dmg (mv :senjumaru :base :sj-k3))))
              (= 45 (mv-dmg (mv :senjumaru :tsuji1 :sj-t-k1))) (= 58 (mv-dmg (mv :senjumaru :tsuji1 :sj-t-k3)))))
  ;; the soldier: one string of three, 300 f, 3.5 m/s (the user's decision), one stitch when it bursts; it moves the frame
  ;; she is free (2026-10-01); each flinch outlasts the next wind-up (+4 for the hitstop: a true combo); the umbrella: a guard over f4-27,
  ;; the tendrils always fire, 40 + half the largest caught hit, at most 120, a side Step clears them (0.8 + 0.45 < 2.5)
  (check (and (= 3 (length *shinpei-combo*)) (= 300 *shinpei-life*) (~= 3.5 *shinpei-speed*)
              (= (mv-total (kit-command-move b :sp1)) (+ 10 *shinpei-rise*))
              (member '(10 senju-shinpei) (mv-on-frame (kit-command-move b :sp1)) :test #'equal)
              (loop for (h nx) on *shinpei-combo* while nx always (>= (seventh h) (+ (first nx) 4)))
              (= 74 (reduce #'+ *shinpei-combo* :key #'fifth))))
  (let ((k (kit-command-move b :sp2)))
    (check (and (member :shield (mv-flags k)) (= 4 (mv-s k)) (= 24 (mv-a k)) (eq 'senju-kasa-catch (getf (mv-params k) :catch))
                (= 40 (kasa-damage 0)) (= 70 (kasa-damage 60)) (= 120 (kasa-damage 999)) (= 1 (kit-command-cost b :sp2))
                (= 2 (kit-command-cost t1 :sp2)) (< (+ (* 0.5 (getf (mv-params k) :width)) 0.45) *step-distance*)
                (member '(28 senju-kasa-fire) (mv-on-frame k) :test #'equal))))
  ;; NUICHI: 7.7 m, <= 28 f; the Bankai's lane 8.5 m; Kikon 2 / 3, Soul Break 3 / 4
  (let ((o (kit-command-move b :kikon)) (u (kit-command-move t1 :kikon)))
    (flet ((pa (m k) (getf (mv-params m) k)))
      (check (and (~= 7.7 (kikon-rush-reach (pa o :speed) (pa o :dash-max)) 0.05) (= 28 (+ (pa o :aura) (pa o :dash-max) (mv-s o)))
                  (~= 8.5 (mv-reach u)) (= 2 (kit-kikon-konpaku b)) (= 3 (kit-kikon-konpaku t1)) (= 3 (kit-kikon-konpaku t6))
                  (eq 'sj-kikon-cine (kit-kikon-cine b)) (eq 'sj-hata-cine (kit-kikon-cine t1))))))
  ;; the loom: six forms, form k's next hank is k; a release advances along the queue (the user, 2026-09-30): 黒砂 刃金 褥
  ;; 焼野原 眼 星, then 黒砂 again; L held 20-60 (a pass per 20 f), the combo copy no hold, S 8, a 9 m reach (no chase)
  (check (and (equal (loop for n from 1 to 6 collect (hank-next n)) '(6 4 2 5 1 3))
              (equal (loop for n from 1 to 6 collect (form-hank (hank-form n))) '(1 2 3 4 5 6)) (null (form-hank :base))
              (equal (mapcar #'weave-passes '(20 39 40 59 60 61)) '(1 1 2 2 3 3))))
  (loop for n from 1 to 6
        for k = (kit :senjumaru (hank-form n))
        for l = (kit-command-move k :sig)
        for lk = (kit-l-link k :sj-t-k1)
        do (check (and (= n (getf (mv-params l) :hank)) (equal (mv-hold l) '(1 600)) (= 6 (mv-s l)) (member :bind (mv-flags l))
                       (eq 'senju-weave-release (mv-release l)) (null (mv-release lk))
                       (= n (getf (mv-params lk) :hank)) (null (mv-hold lk)) (= 8 (mv-s lk)) (getf (mv-params lk) :combo)
                       (>= (mv-reach lk) 9.0) (eq (intern (format nil "SJ-TACHINAOSHI-~d" n) :keyword) (mv-name (kit-command-move k :sp1)))
                       (= 1 (kit-command-cost k :sp1)) (kit-awakening k)
                       (zerop (mv-cooldown l)))))                 ; (no COOLDOWN row: the torn lock is L's timer)
  ;; the combo cut: L after a K link hits before the K link's stagger ends (A 4 + S 8 + unfold 10 = 22 < 26)
  (check (< (+ 4 8 *unfold-combo*) (hitstun :stagger)))
  ;; the weave's scaling: radius, life, damage never smaller with more passes; every disc's full radius + Kenpachi's hurt r
  ;; < a Step; the corridor's half-width too; the rings with no hit (眼 3.0, 星 3.5) are free of the rule
  (loop for n in '(2 3 4) do (check (< (+ (hank-radius n 3) 0.45) *step-distance*)))
  (check (< (+ (* 0.5 (hank 5 :width)) 0.45) *step-distance*))
  (loop for n from 1 to 6
        do (check (loop for p from 1 below 3
                        always (and (or (not (hank n :r)) (<= (hank-radius n p) (hank-radius n (1+ p))))
                                    (or (not (hank n :life)) (<= (hank-life n p) (hank-life n (1+ p))))
                                    (or (not (hank n :dmg)) (<= (hank-damage n p) (hank-damage n (1+ p))))))))
  (check (and (= 126 (hank-damage 2 3)) (= 90 (hank-damage 2 2)) (= 63 (hank-damage 2 1)) (= 288 (hank-life 1 3))
              (= 120 (hank-life 1 1)) (~= 2.1 (hank-radius 1 1)) (null (hank 1 :dmg)) (null (hank 6 :dmg))
              (~= 24.0 (hank-fx 4 :freeze 1)) (~= 60.0 (hank-fx 4 :freeze 3)) (~= 45.0 (hank-fx 6 :reiatsu 3))))
  ;; the awakened grid: J1 J2 J3 K2 as the Shikai's (no reach derivation: the playtest), K1 3.8 m, MAKITORI 2.5 m with its
  ;; pull to 1.4
  (check (and (~= 1.44 (mv-reach (kit-command-move t1 :q))) (~= 2.5 (mv-reach (kit-next t1 :sj-j1 :f)))
              (~= 3.8 (mv-reach (kit-command-move t1 :f))) (~= 2.5 (mv-reach (kit-next t1 :sj-k2 :f)))
              (~= 1.4 (getf (mv-params (kit-next t1 :sj-k2 :f)) :pull)) (~= 3.3 (kit-walk t1)) (~= 3.6 (kit-walk b))))
  ;; the CPU: the rule's keys, the loom's hold by distance (星 closer), the Shikai taps L
  (check (and (equal (getf (kit-ai b) :awaken) '(:min-taken 150))
              (= 31 (senju-sig-hold t1 7.0)) (= 31 (senju-sig-hold t1 5.0)) (= 21 (senju-sig-hold t1 3.0))   ; a segment; one pass
              (= 31 (senju-sig-hold t6 5.5)) (= 31 (senju-sig-hold t6 3.0)) (= 1 (senju-sig-hold b 3.0))
              (~= 0.5 (getf (kit-ai t6) :opp-rush-hold)) (null (kit-reset-form t1)) (eq :base (kit-reset-form b)))))

;; L: hold to weave, tap to release (the user, 2026-09-29): under 10 f is a tap; a weave's frames count from its 10th (those
;; 10 at once), one a frame after, summed over segments on the hank up to 3 passes; a release (the tap, K -> L, SP1) makes
;; the stored passes, at least 1; a hit while weaving voids the hank (the next one, nothing woven)
(flet ((seg (woven frames) (loop for h from 1 to frames do (setf woven (weave-add woven h))) woven))
  (check (and (= 10 *weave-tap*) (weave-tap-p 9) (not (weave-tap-p 10))
              (= 0 (seg 0 9)) (= 10 (seg 0 10)) (= 15 (seg 0 15))            ; a tap weaves nothing; a hold counts from f1
              (= 30 (seg (seg 0 15) 15)) (= 1 (weave-stored (seg (seg 0 15) 15)))   ; two segments of 15: one pass
              (= 45 (seg (seg (seg 0 15) 15) 15)) (= 2 (weave-stored 45))
              (= 60 (seg 45 40)) (= 3 (weave-stored (seg 0 200)))            ; capped at three passes
              (= 30 (seg 30 9))                                             ; a tap keeps what is stored
              (= 1 (release-passes 0)) (= 1 (release-passes 19)) (= 2 (release-passes 45)) (= 3 (release-passes 60))
              (equal '(2 0) (multiple-value-list (weave-void 3))) (equal '(3 0) (multiple-value-list (weave-void 6))))))
(check (and (eq :sig (mv-kind (find-move :sj-weave-stop))) (= 6 (mv-total (find-move :sj-weave-stop)))))

;; J weaves, K releases (the user, 2026-09-29): a release needs a stored pass: a tap with nothing woven is refused (the cue,
;; then it stops), as over a live zone; a weave just stops; K -> L (the -k copies) is refused at 0 passes, J -> L never
;; (it weaves), nor SP1 (it releases at 0 as at 1, RELEASE-PASSES); J -> L is HITOKOSHI in every loom form after every
;; J link (+1 pass at f8, at most 3; 8/0/10: -3 after a J1 / J2 hit, +5 after J3, <= -17 blocked), none in the Shikai
(let ((t1 (kit :senjumaru :tsuji1)) (hk (find-move :sj-hitokoshi)))
  (check (and (not (release-ok-p 0)) (not (release-ok-p 19)) (release-ok-p 20)
              (eq :refused (weave-release-act 5 0 nil)) (eq :refused (weave-release-act 9 19 nil))      ; a tap at 0 passes
              (eq :release (weave-release-act 5 20 nil)) (eq :refused (weave-release-act 5 60 t))
              (eq :stop (weave-release-act 10 0 nil)) (eq :stop (weave-release-act 40 60 t))))
  (check (and (not (loom-ok-p :sig (kit-l-link t1 :sj-t-k1) 0)) (not (loom-ok-p :sig (kit-l-link t1 :sj-k2) 19))   ; K -> L
              (loom-ok-p :sig (kit-l-link t1 :sj-t-k1) 20) (loom-ok-p :sig nil 0) (loom-ok-p :sig hk 0)
              (loom-ok-p :sp1 nil 0) (= 1 (release-passes 0))))                                                ; SP1 at 0
  (check (and (= 20 (quick-weave 0)) (= 1 (weave-stored (quick-weave 0))) (= 35 (quick-weave 15))              ; +1 pass
              (= 2 (weave-stored (quick-weave (quick-weave 0)))) (= 60 (quick-weave 45)) (= 60 (quick-weave 60))  ; cap 3
              (= 3 (weave-stored (quick-weave (quick-weave (quick-weave (quick-weave 0))))))))
  (check (and (eq :sig (mv-kind hk)) (= 8 (mv-s hk)) (= 18 (mv-total hk)) (null (mv-hold hk))
              (equal (mv-on-frame hk) '((8 senju-quick-weave))) (null (getf (mv-params hk) :combo))))
  (let ((j1 (kit-command-move t1 :q)) (j3 (kit-next t1 :sj-j2 :q)))
    (check (= -3 (- (hitstun :flinch) (mv-a j1) (mv-total hk))))                          ; safe-ish on hit
    (check (= 5 (- (hitstun :stagger) (mv-a j3) (mv-total hk))))
    (check (<= (- (+ (mv-adv-block j1) *chain-lead*) (mv-total hk)) -17)))              ; punishable blocked
  (loop for n from 1 to 6
        for k = (kit :senjumaru (hank-form n))
        do (check (and (every (lambda (j) (eq hk (kit-l-link k j))) '(:sj-j1 :sj-j2 :sj-j3 :sj-j2s))
                       (every (lambda (j) (getf (mv-params (kit-l-link k j)) :combo)) '(:sj-t-k1 :sj-k2 :sj-k2s :sj-t-k3))
                       (~= 0.35 (getf (kit-ai k) :l-after-j)))))
  (check (notany (lambda (j) (kit-l-link (kit :senjumaru :base) j)) '(:sj-j1 :sj-j2 :sj-j3 :sj-j2s)))
  (check (every (lambda (cf) (or (member (first cf) '(:senjumaru :barro)) (equal cf '(:hisagi :base))   ; (Lille II: J3 -> L;
                                 (null (kit-l-after-j (apply #'kit cf))))) *forms*)))   ; Hisagi's Shikai: the windmill bridge, S1)

;; SP1 裁ち直し releases the next two hanks (the user, 2026-09-29): the queue moves +2 (6 wraps to 1); the move cuts the live
;; zone(s) at f0 and releases at f8 and f14 (the combo cut's rules); off a landed link both land inside a stagger (26 f:
;; cancel frame +1, then S + unfold); its :tell is its first hitting hank's; 1 bar
(check (equal (loop for n from 1 to 6 collect (multiple-value-list (tachi-hanks n)))
              '((1 6 3) (2 4 5) (3 2 4) (4 5 1) (5 1 6) (6 3 2))))
(loop for n from 1 to 6
      for k = (kit :senjumaru (hank-form n))
      for sp = (kit-command-move k :sp1)
      do (check (and (eq :sp (mv-kind sp)) (= 8 (mv-s sp)) (= 30 (mv-total sp)) (= 1 (kit-command-cost k :sp1))
                     (equal (mv-on-frame sp) '((0 senju-combo-cut) (8 senju-tachi-release) (14 senju-tachi-release)))
                     (= 6 (- (first (third (mv-on-frame sp))) (first (second (mv-on-frame sp)))))   ; the two releases' gap
                     (< (+ 1 8 *unfold-combo*) (hitstun :stagger)) (< (+ 1 8 6 *unfold-combo*) (hitstun :stagger))
                     (equal (getf (mv-params sp) :tell)
                            (cond ((hank-hits-p n) '(10 22)) ((hank-hits-p (hank-next n)) '(16 28)))))))
(check (and (null (getf (mv-params (kit-command-move (kit :senjumaru :tsuji1) :sp1)) :tell))   ; 眼 + 星: no hit
            (equal '(16 28) (getf (mv-params (kit-command-move (kit :senjumaru :tsuji6) :sp1)) :tell))   ; 星 + 黒砂
            (eq 'senju-sp-ender (getf (kit-ai (kit :senjumaru :tsuji1)) :sp-ender))
            (null (getf (kit-ai (kit :senjumaru :tsuji1)) :skip))))

;; The queue in three SP1 pairs (the user, 2026-09-30): 黒砂 → 刃金 → 褥 → 焼野原 → 眼 → 星, wrapping to 黒砂; the awakening
;; enters 黒砂's form; SP1 from an even slot releases a designed pair (黒砂+刃金, 褥+焼野原, 眼+星), from an odd one a cross
;; pair (刃金+褥, 焼野原+眼, 星+黒砂); SP1 keeps the parity, a single release (or a voided weave) flips it; each hank keeps its data
(let* ((b (kit :senjumaru :base)) (n0 (form-hank (kit-awaken-form b))))
  (check (and (eq :tsuji3 (kit-awaken-form b)) (= 3 n0) (equal "黒砂の腸" (hank n0 :kanji)) (equal *hank-order* '(3 2 4 5 1 6))))
  (check (equal (loop repeat 7 for n = n0 then (hank-next n) collect (hank n :short))
                '("KOKUSA" "HAGANE" "SHITONE" "YAKENOHARA" "ME" "HOSHI" "KOKUSA")))
  (flet ((pair (n) (multiple-value-bind (a c) (tachi-hanks n) (list a c))))
    (check (equal (mapcar #'pair (remove-if-not #'tachi-aligned-p *hank-order*)) '((3 2) (4 5) (1 6))))
    (check (equal (mapcar #'pair (remove-if #'tachi-aligned-p *hank-order*)) '((2 4) (5 1) (6 3))))
    (dolist (n *hank-order*)
      (check (eq (tachi-aligned-p n) (tachi-aligned-p (nth-value 2 (tachi-hanks n)))))      ; SP1 keeps the parity
      (check (not (eq (tachi-aligned-p n) (tachi-aligned-p (hank-next n)))))                ; a single release flips it
      (check (not (eq (tachi-aligned-p n) (tachi-aligned-p (weave-void n))))))              ; so does a voided weave
    ;; repeated SP1 from the entry: the three pairs, then 黒砂 + 刃金 again; one tap first: the cross pairs
    (check (equal (loop repeat 4 for n = n0 then (nth-value 2 (tachi-hanks n)) collect (pair n)) '((3 2) (4 5) (1 6) (3 2))))
    (check (equal (loop repeat 3 for n = (hank-next n0) then (nth-value 2 (tachi-hanks n)) collect (pair n)) '((2 4) (5 1) (6 3))))))
(check (equal *hanks*
              '((1 :name "BANRA NO ME" :short "ME" :kanji "万朶の眼" :r 3.0 :life 240)
                (2 :name "HAGANE NO YOROI" :short "HAGANE" :kanji "刃金のよろい" :r 2.0 :rise 16 :dmg 90 :guard 24 :after 20)
                (3 :name "KOKUSA NO HARAWATA" :short "KOKUSA" :kanji "黒砂の腸" :r 2.0 :life 240 :away 0.4 :period 60 :swirl 12 :dmg 40)
                (4 :name "ITETSUKU SHITONE" :short "SHITONE" :kanji "凍てつく褥" :r 2.0 :life 240 :dmg 70 :freeze 40 :frost 60)
                (5 :name "YAKENOHARA" :short "YAKENOHARA" :kanji "焼野原" :width 2.0 :max 10.0 :hits 2 :dmg 45 :life 150 :chip 0.12)
                (6 :name "YAMIYO NO HOSHIYO" :short "HOSHI" :kanji "闇夜の星よ" :r 3.5 :life 240 :reiatsu 30.0 :fs 15.0))))

;; 星 siphons (the user, 2026-09-29): inside her live star he gains nothing; his Reiatsu / flash-step gains go to her, his
;; Fighting Spirit (and every kit meter: combat.lisp SIPHON-OF) is lost; the drain gives her what it really took, capped
(multiple-value-bind (r fs aw sr sfs) (hit-gains 100 40 nil)
  (check (and (~= r (reiatsu-gain 100 40)) (~= fs (* 40 *fs-taken*)) (~= aw (awakening-gain 100 40 0)) (zerop sr) (zerop sfs))))
(multiple-value-bind (r fs aw sr sfs) (hit-gains 100 40 t)
  (check (and (zerop r) (zerop fs) (zerop aw) (~= sr (reiatsu-gain 100 40)) (~= sfs (* 40 *fs-taken*)) (plusp sr) (plusp sfs))))
(multiple-value-bind (his hers) (gauge-move 50.0 0.5 20.0 100.0) (check (and (~= his 49.5) (~= hers 20.5))))
(multiple-value-bind (his hers) (gauge-move 0.2 0.5 20.0 100.0) (check (and (~= his 0.0) (~= hers 20.2))))   ; what it took
(multiple-value-bind (his hers) (gauge-move 50.0 0.5 99.8 100.0) (check (and (~= his 49.5) (~= hers 100.0))))  ; capped
(check (every (lambda (f) (eq 'senju-siphon (kit-hook (kit :senjumaru f) :siphon))) '(:base :tsuji1 :tsuji6)))
(check (every (lambda (cf) (or (eq (first cf) :senjumaru) (null (kit-hook (apply #'kit cf) :siphon)))) *forms*))

;; the DANGAI boss (DUEL_ROGUE §5): her loom always full (3 passes) after a cast or a void, 0 for anyone else; HITOKOSHI is
;; no move for her (a full hank); the :boss hook on every form (inherited from :base)
(check (and (= 3 (weave-stored (senju-full-woven))) (= 3 (release-passes (senju-full-woven)))
            (= (senju-full-woven) (quick-weave (senju-full-woven))) (= (senju-full-woven) (weave-add (senju-full-woven) 30))
            (let ((*run-boss* nil)) (zerop (senju-woven-after :x)))
            (let ((*run-boss* :x)) (and (= (senju-full-woven) (senju-woven-after :x)) (zerop (senju-woven-after :y))))
            (senju-boss-l-idle-p :x (find-move :sj-hitokoshi))
            (every (lambda (f) (eq 'senju-boss (kit-hook (kit :senjumaru f) :boss))) '(:base :tsuji1 :tsuji3 :tsuji6))))
