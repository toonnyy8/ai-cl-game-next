;;;; hisagi-ai.lisp — Hisagi's CPU: the Shikai's (his kit's :ai, docs/duel/DUEL_HISAGI.md §10), the Bankai's (§17.5 #16), the learner's
;;;; situations and the ASSIST routes (§25.20), and the CPU's knobs (the *HS-AI-...* parameters, every chance EASY <= NORMAL <= HARD)
;;;; (split out of hisagi.lisp 2026-10-21, refactor round 2). Loads right after hisagi.lisp, which keeps the three knobs the kit data
;;;; reads while its DEFKIT is evaluated (*HS-AI-STRING-K* *HS-AI-L-AFTER-J* *HS-AI-AWAKEN*) and *HS-AI-RELEASE-MARGIN* (read by the rule function HS-RELEASE-WANTED-P); the kits name the CPU functions as bare
;;;; symbols (:reflex :opp-reflex :sp-ender :sig-hold :move-reflex), so they are late-bound. Plain CL (the host rules test loads it
;;;; after hisagi.lisp); no DEFUN-FAST. The dream-rsi searches (docs/research/hisagi-ai-drsi, skill duel-character-cpu) edit this file.
(in-package :duel)

;;; ================================================================ the CPU's knobs (moved here from hisagi.lisp's knob sections, in their order)
(defparameter *hs-ai-windmill-p* '(:easy 0.3 :normal 0.6 :hard 0.9)
  "His CPU: the windmill against a ranged threat (RANGED-THREAT-IN 4-24 f), once per threat (its rising edge).")
(defparameter *hs-ai-kaza-margin* 0.3 "... K once the real distance is within K1's charged line + this (m; its tip + radii ~0.66).")
;; His CPU's styles (dream-rsi cells b0a0 / b1a0 / b3a0, DUEL_HISAGI §25; the user, 2026-10-18: 「請研究多種招牌風格，並使用機率
;; 將這些風格戰法互相結合」). Cell b3a0 mixes the three themes by probability: the Shikai's chain style rolled once per match
;; (HS-AI-STYLE: RENSA 55 % / KARIBA 45 %, both behind the reaping fence, HS-AI-FENCE); the Bankai, his last stand, its ranged
;; style rolled once per entry into the ranged mode (HS-R-STYLE: SOKUBAKU 64 % / SANGE 16 % / KUBIGARI 20 %, b1a0's, behind
;; b1a0's fence); the bind's release by its grey margin (HS-B-AI-REFLEX); every route, bridge, leap and ender a roll per
;; event. Every chance inside an (:easy :normal :hard) plist, rolled once per event. Cell b0a0 on the §25.15 freeze (the
;; Shikai chain first): b3a0's CPU ported onto §25.13-§25.14's rules (the bind's release falls back to FREE without SP2's
;; Reiatsu), plus two per-event layers of the chain, by style: KAZAGURUMA-GAESHI (a charge read: the windmill wards the
;; shot, then sweeps with the charged K string) and TODOME (a red victim's link 2 into RAIDEN, not the O ender's Kikon).
;; Round01 cell b3a0 on the §25.15 freeze (SANMI 三味, the three themes mixed by probability): b0a0's Shikai, round01 b1a0's
;; ranged route styles (SENTAN / NAWAJI / KAISEN, one roll per entry into the ranged mode), the awakening at 3000 taken (the
;; Bankai in ~half of the matches, no longer only a last stand), the Shikai's style weighted by difficulty (HARD RENSA 80 %),
;; the reap's approach proven over 3 perceived steps, the waking noose (KUBIKAKE once off the awakening) and the bind's
;; ledger (the release at any grey loss once the pool runs low; KAIBAKU-GEKI only in its reach, else FREE). Round01 cell b3a1
;; (三味・輪 SANMI-RINNE, a refine of b3a0): b3a0's three-theme mix with round01 b0a1 / b0a2's Shikai layers merged in (見切り
;; MIKIRI the Hoho read, 詰 TSUME the close-in, the combo's route plan 輪 RINNE / 輪止 RINNE-OWARI / 花 HANA, §25.16's showpiece,
;; one roll per combo), round01 b1a1's 待鎖 MACHI-GUSARI in the ranged mode (no neutral swings: every route opens off an
;; answer) and its leak fixes (the SAHARAI cancel read where the push leaves him: b3a0 carried round01 b2a0's located bug),
;; and every SP ender RAIDEN (SHIBARI after RIN lost its slam to the combo's hitstun decay, HS-AI-ENDER). Round01 cell b3a2
;; (三味・空蝉 SANMI-UTSUSEMI, a refine of b3a1): the same mix, plus 空蝉 UTSUSEMI (HARD: the Hoho through a committed swing,
;; 0.9 of the opponent's actions in reach where the kit's generic Hoho took 0.3; HS-AI-UTSUSEMI), round01 b2a1's 絞首 KOSHU in
;; the bind (the cinching route, the walk-in, the bind's TODOME; HS-B-AI-MOVE) on b3a0's ledger, and the waking noose off
;; cell b3a0, the reaping fence (HS-AI-FENCE): the Shikai keeps the chain's distance; K1 swept into an approach (the HARD
;; masher 0.66 -> 1.0, his signature 0.79 -> 0.85: the K string at range, not the J trade)
;; cell b0a0 (this freeze, DUEL_HISAGI §25.15): the windmill read on a charge and turned into the sweep (風車返し KAZAGURUMA-
;; GAESHI), and the red string's link 2 into RAIDEN (綴の止め TODOME). The diagnosis: the shot of a held ranged charge (a
;; snipe's level-2 copy starts 8 f before its hit) is never a RANGED-THREAT-IN 4-24 f for a HARD brain (8 f late), so the
;; ward rose late or never; a ward never swept (no K out of it); a string's link 3 on a red victim forces the generic O
;; ender, whose 70 is plain damage (4.4 % of his damage). (Tried and dropped: the reap held back against a perfect-Hoho
;; reader, its roll skipped while he could Hoho: Ichigo 4 -> 10-16 of 80 at HARD, but Yamamoto / Rukia lost more and his
;; J1 openers cost signature: 1200 HARD matches 0.409 -> 0.375-0.408.)
(defparameter *hs-ai-sweep-wait* 12
  "... the sweep's K waits while a ranged hit of his lands within this many frames as perceived (the ward takes it).")
;; cell b0a1 (round 1, a refine of b0a0): 見切り MIKIRI, the Hoho read. The diagnosis (HARD, 120 matches of b0a0's file, the
;; combat log): 494 perfect Hohos against him, 422 of them on a K1 (the reap 327 of 1784, neutral 95 of 498), each the 60
;; counter and a full string after it; the reap's K1 into an opponent able to Hoho (his flash-step, no Hoho of his just seen)
;; was perfect-Hoho'd 55 % by Ichigo, 37 % Kenpachi, 30 % Rukia, 8 % Yamamoto, 7 % Senjumaru, 0 % Lille; unable, 0-8 %.
;; His J1 (S 8) is inside every brain's Hoho lead. So the read: his K1s thrown while the opponent could Hoho, and how many of
;; them were perfect-Hoho'd, this match (a Beta prior); over *HS-AI-MIKIRI-RATE*, while he can Hoho, the K1 is held back
;; (the reap, the hop out to the reap's range) and the chain comes in by hand instead: the step-in J1 (S 8: no Hoho reads
;; it), then the windmill bridge into the charged K string. Once he can't Hoho (his flash-step below a Hoho's on the HUD, or
;; his Hoho just seen: its lockout), K1 is free again. Measured (HARD, seeds 1-20 both seats, paired with the read off):
;; Ichigo 2 -> 14 of 40, Kenpachi 6 -> 8, the others unchanged; the perfect Hohos against him 337 -> 175 (Ichigo), 295 -> 203
;; (Rukia), 175 -> 133 (Kenpachi); the cost, his plain J1 openers (signature 0.902 -> 0.889). The read without the close-in
;; (the reap only held back, b0a0's dropped MACHI-GAMA's shape): Ichigo 6 of 40.

;; cell b0a2 (round 1, a refine of b0a1): the Shikai's showpiece combo (DUEL_HISAGI §25.16, the user, 2026-10-20: 「始解可以用
;; J1 J2 J3 > L > K1 K2 > J3 > L > K1 K2 K3 做為強力的花式連段，也可以將中段或結尾換成 SP 減少連段並提高輸出」) as the combo's
;; route plan, rolled once per combo at its first link hit of his (HS-AI-PLAN): a head (J1 J2 J3 or J1 alone, then the
;; bridge), a middle (after the first K string's K2: the leap J3K -> the bridge again, or RAIDEN), an end (the last K2: K3
;; or RAIDEN). The diagnosis (HARD, 480 matches of b0a1's file, the combat log): the leap in 2 % of his combos, the second
;; K string after it in 1 %, the full showpiece never; 30 % of his combos K1 K2 K3 or J1 L K1 K2 K3 and done. Measured (HARD,
;; seeds 1-40 both seats, each plan forced at plan-p 1.0; wins of 480 / signature): no plan 233 / 0.890; RINNE 254 / 0.922;
;; RINNE with its end an SP 251 / 0.913; HANA (the user's) 237 / 0.818 (its J1 J2 J3 head is plain J and starts the decay
;; three hits early); TSUZURI (J1 > L > K1 K2 > RAIDEN) 203 / 0.884; the mix below 247-251 / 0.901-0.921. (Tried and dropped:
;; RAIDEN's paralysis restarted with K1, 綴返 GAESHI: out of the guard cancel no attack starts before RAIDEN's recovery ends,
;; f47 (FIGHTER-GC-LEFT), so K1's 18 f lands 5 f after the 40 f paralysis; the J1 restart inside 1.7 m: 231 vs 233 of 480.)
(defparameter *hs-ai-plan-routes*
  '(:rinne (:j :leap :k3) :rinne-owari (:j :leap :sp) :hana (:jjj :leap :k3) :hana-sp (:jjj :sp :k3)
    :hana-owari (:jjj :leap :sp) :tsuzuri (:j :sp :k3))
  "The combo's route plans (cell b0a2), each (HEAD MIDDLE END): HEAD after J1's hit, :jjj J2 J3 then the bridge (L), :j the
bridge at once; MIDDLE after the first K string's K2, :leap the leap J3K then the bridge again, :sp RAIDEN; END after the
last K string's K2, :k3 K3 (then the SP ender), :sp RAIDEN. 花 HANA the user's showpiece (J1 J2 J3 > L > K1 K2 > J3K > L >
K1 K2 K3), HANA-SP / HANA-OWARI its middle / end an SP (the user: 「將中段或結尾換成 SP」); 輪 RINNE the chain's wheel, the
showpiece from J1 alone (J1 > L > K1 K2 > J3K > L > K1 K2 K3), RINNE-OWARI its end an SP (... K1 K2 > RAIDEN); 綴 TSUZURI
the short one (J1 > L > K1 K2 > RAIDEN). A K1 opener plays its plan from the middle (K1 K2 > J3K > L > K1 K2 K3).")
(defparameter *hs-ai-plans* '(:rinne 0.8 :rinne-owari 0.1 :hana 0.1)
  "The plan's pick (weights, cell b0a2), once a plan is taken (*HS-AI-PLAN-P*): RINNE the most (measured the strongest:
254 of 480 HARD wins, signature 0.922), its SP end and the user's full showpiece HANA one combo in ten each (HANA is the
signature's cost: 0.818 forced).")
(defparameter *hs-ai-plan-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "His CPU in the Shikai, once per combo at its first link hit of his (J1 / K1): a route plan (*HS-AI-PLANS*), else the
per-hit picks of his style (HS-AI-MOVE: the bridge, the K link, the leap) (cell b0a2; HARD 0.9: 247 of 480, 1.0: 254; NORMAL
0.3 put his NORMAL share at 0.642, over the band's 0.60 (factor 0.72): NORMAL and EASY plan nothing, so they play b0a1's
Shikai to the match, no roll taken).")
;; round01 cell b3a2 (a refine of b3a1): 空蝉 UTSUSEMI, the Hoho through a committed swing. The diagnosis (HARD, 960 matches of
;; b3a1's file, the combat log): his own Hohos in the Shikai net +165 .. +270 a Hoho over the next 240 f against every
;; opponent but Lille (60-85 % of them perfect: the counter, then the plan's wheel), the best thing he does, yet he Hohos 1.4
;; times a match: the kit's generic :hoho 0.3 (one number for every difficulty; NORMAL's never-awaken A/B rows hang on it,
;; cell b0a0) answers a committed move, the guard the rest. The flash-step it spends regenerates 3 a second.
;; his CPU in the Bankai (§17.5 #16; every chance EASY <= NORMAL <= HARD, rolled once per event)
(defparameter *hs-ai-throw-p* '(:easy 0.02 :normal 0.05 :hard 0.95)
  "His CPU, ranged mode: KUBIKAKE (SP2 since B4c) cancelled off a J / K hit with his own 200 and the victim in its line's
reach, one roll per hit (HS-R-AI-MOVE, HS-R-AI-ENDER; §17.5 #16 rolled it once per entry into 4-7 m, from neutral). Round01
cell b1a0: 0.2 / 0.45 / 0.7 -> 0.05 / 0.1 / 0.95: the bind at HARD (+24 a second there, the ranged mode -35); NORMAL's bind
was the fair game's undoing once the Bankai came at 2000 taken (NORMAL 0.80 -> 0.46 with 0.05, ~0.5 with 0.1). (Round01 cell b3a0: NORMAL 0.1 -> 0.05, EASY 0.05 -> 0.02: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
(defparameter *hs-ai-bite-window* 40
  "Cell b2a2: the bite looks this many frames after the bind's start (KUBIKAKE's stun 30 from its 9 f hitstop's end: the
perceived reel before ~17 f in is the old string's).")
;; round01 cell b3a2: round01 cell b2a1's 絞首 KOSHU (the bind as a race to the red; b2a0's bind TODOME), ported onto cell b3a0's
;; ledger (the release), which b2a1's bind plans and drain margin replaced there: the bind's value is the Konpaku a drain makes
;; real, and whoever lands the first Kikon in it wins it (b2a1, HARD, the awakening forced, 311 binds: his first, drained 48 of
;; 52; the opponent's first, released 67 of 71). Ported (b3a2, HARD, seeds 1-80 both seats, 960 matches): 533 -> 540 wins (the
;; awakened matches 227 -> 234 of 553, the others identical), the bind 47.8 / 29.0 -> 60.2 / 26.7 dealt / taken a second
(defparameter *hs-ai-b-todome-p* '(:easy 0.1 :normal 0.2 :hard 0.9)
  "In the bind, once per K link 2 hit (K2 / K2s) on a red victim while he is not behind on grey (HS-B-AI-MOVE): SP1 KUSARI-AME
cancelled out of it, not the link 3 (whose hit forces the O ender's grey Kikon) (round01 cell b2a0's, ported by cell b3a2).")
(defparameter *hs-ai-b-route-p* '(:easy 0.0 :normal 0.3 :hard 1.0)
  "Once per link hit of his in a bind (HS-B-AI-MOVE, its land step): the K link (J1 -> K2s -> K3 242, K1 -> K2 -> K3 290, the
chains cinched) over the generic pick (*AI-STRING-FLASH-P*: mostly J1 -> J2 -> J3, 145) (round01 cell b2a1's, ported by cell
b3a2).")

;; dream-rsi round01 cell b1a0 on §25.13's rules (DUEL_HISAGI §25.15; the user, 2026-10-18: 「請研究多種招牌風格，並使用機率將這些
;; 風格戰法互相結合」): the ranged mode played as one of three ROUTE styles, rolled once per entry into it (the awakening, every
;; bind's end; HS-R-STYLE): each a different use of §25.13's routes (the links reach him anywhere to 7.0 m and inherit the
;; opener's tip x1.71); all share b1a0's fence (the back hop, the punishes by annulus, the Hoho, HS-R-AI-REFLEX) and the
;; bind's release (HS-B-AI-REFLEX). (The §25.12 round's SANGE / SOKUBAKU / KUBIGARI picked the opener only; these pick the
;; distance, the route and where the noose goes in it.)
(defparameter *hs-ai-r-style-w* '(:sentan 0.6 :nawaji 0.15 :kaisen 0.25)
  "His CPU, once per entry into the ranged mode: the route style (weights; HS-R-STYLE, SIM-RND01): SENTAN 尖端 the tip
reaper, NAWAJI 縄路 the noose road, KAISEN 回旋 the Reiatsu wheel (*HS-AI-R-STYLES*).")
(defparameter *hs-ai-r-styles*
  '(:sentan (:open :f :anti :f :tip t :route-dmg (:easy 0.7 :normal 0.8 :hard 0.9) :kubi-at 3 :keep 4.25)
    :nawaji (:open :f :anti :f :tip nil :route-dmg (:easy 0.5 :normal 0.6 :hard 0.7) :kubi-at 1 :keep 3.5)
    :kaisen (:open :q :anti :q :tip t :route-dmg (:easy 0.1 :normal 0.15 :hard 0.2) :kubi-at 3 :keep 5.75))
  "The ranged route styles: :open the opener where both reach and no tip holds him (J1 the spread route, K1 the gathered
one), :anti the anti-approach strike, :tip (T) every opener picked so the victim stands on its chain tip (HS-R-TIP-CMD: K1
at 4.0-4.5 m, J1 at 5.5-6 m since §25.35: the whole route x1.71, §25.13), :route-dmg the K link's chance per link hit (HS-R-AI-MOVE), :kubi-at
the first link KUBIKAKE's cancel may take (1: off the opener's hit, the bind first; 3: only off the ender, the route's
damage first), :keep the distance his back hop runs out to. SENTAN keeps K1's tip (4.6 m; 4.75 since the tip's 0.5 m, §25.26; 5.125 since §25.34's reaches; 4.25 since §25.35's) and plays the gathered K route
to the end (K1 -> K2 -> K3G on the tip: 313); NAWAJI throws the noose off the first link that hits; KAISEN keeps J1's tip
(5.0 m; 5.75 since §25.26; 6.625 with §25.34's reaches, 5.75 again since §25.35; NAWAJI 3.5, 4.5 in §25.34, where both
openers reach) and plays the spread J route (J2 -> J3's 6.6 m push: back to the tip; the Reiatsu x1.69) for the bars.")
(defparameter *hs-ai-wake-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Cell b3a0, once per awakening (the entry into the ranged mode from the Shikai): the waking noose, KUBIKAKE thrown as soon
as its line holds him and he isn't attacking, inside *HS-AI-WAKE-WINDOW* frames (HS-R-AI-REFLEX): the bind sought at once. (Round01 cell b3a0: NORMAL 0.1 -> 0.05: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)
Round01 cell b3a2: 0.02 / 0.05 / 0.8 -> 0 (off; the knob and its code kept): the noose thrown off the awakening hit 19-23 % of
the time and netted -92 a throw over the next 240 f (HARD, 960 matches); without it, with UTSUSEMI, 610 HARD wins of 960 vs 597
(the awakened matches 208 vs 195 of 451, the others identical), the ranged theme's share the same (0.040 vs 0.039).")

;;; ================================================================ the CPU (his kit's :ai; DUEL_HISAGI §10)
(defun hs-seen (b)
  "Brain B's perceived opponent this step (the SNAP BRAIN-PERCEIVE handed its reflexes), or NIL (cell b0a0: the windmill's
sweep reads it in HS-KAZA-TICK's brain branch, where no reflex runs: L is held)."
  (let* ((ring (brain-ring b)) (n (length ring)))
    (svref ring (mod (- (brain-head b) 1 (brain-delay b)) n))))
(defun hs-shot-pending-p (e)
  "His CPU in a ward's sweep (cell b0a0): is a ranged hit of his about to land as perceived (within *HS-AI-SWEEP-WAIT* f:
RANGED-THREAT-IN)? Then the K waits, the windmill wards it. (A charge still held does not wait: the charged K1 strikes
him in it, as his longest shot may go through the ward.)"
  (let* ((b (hs-tick-brain e)) (s (and b (hs-seen b))))
    (and s (let* ((p (pos-of e)) (d (hypot (- (snap-x s) (aref p 0)) (- (snap-z s) (aref p 2)))))
             (ranged-threat-in e b s d 0 *hs-ai-sweep-wait*)))))
(defun hs-ai-kaza-k (e f st)
  "His CPU in the windmill (HS-KAZA-TICK, S1 §23.1): K, once, when the press rolled for it: off the bridge that hit at its
first K frame (*HS-KAZA-K-FROM*: the push carries him past K1's dead zone before its hit, inside the push's stagger: the
combo); else once K1 at the charge so far reaches him (the real distance within its line + *HS-AI-KAZA-MARGIN*, past the
dead zone), from range after the charge it needs. Out of reach at the full charge: no K (the windmill ends)."
  (when (and (hss-ai-kz st)
             (or (and (eq (mv-name (fighter-move f)) :hs-kaza-j) (eq (fighter-contact f) :hit))
                 (and (> (fighter-dist f) (+ *hs-k-dead* 0.1))
                      (<= (fighter-dist f) (+ (mv-reach (hs-scaled :hs-k1 (hss-charge st))) *hs-ai-kaza-margin*))
                      (not (and (eq (hss-ai-kz st) :sweep) (hs-shot-pending-p e))))))   ; (cell b0a0: after the shot)
    (setf (hss-ai-kz st) nil)
    (pace e :ai-kaza-k)
    t))
;; cell b0a2: the combo's route plan (§25.16's showpiece and its SP versions)
(defun hs-plan-next (route name nk leapt bars)
  "The plan's next command (cell b0a2) at a hit of his link NAME: ROUTE (HEAD MIDDLE END) of *HS-AI-PLAN-ROUTES*, NK the K
strings begun in this combo (K1 hits), LEAPT the leap taken (one a combo), BARS his Reiatsu bars. :q, :f, :sig (the
bridge) or :sp1 (RAIDEN); NIL: the style's own pick."
  (destructuring-bind (head mid end) route
    (case name
      (:hs-j1 (if (eq head :jjj) :q :sig))
      (:hs-j2 (and (eq head :jjj) :q))
      ((:hs-j3 :hs-j3k) :sig)
      (:hs-k1 :f)
      (:hs-k2 (let ((how (if (<= nk 1) mid end)))
                (cond ((and (eq how :leap) (not leapt)) :q)
                      ((and (eq how :sp) (>= bars 1)) :sp1)
                      (t :f)))))))
(defun hs-ai-plan (e b name)
  "The route plan of the combo he is in (cell b0a2; his link hits' land steps, HS-AI-MOVE): a new combo (the victim's combo
hits not above the last link hit's, or 90 f since it) clears it; its first J1 / K1 hit rolls it once (*HS-AI-PLAN-P*, then
*HS-AI-PLANS*: else :NONE, the style's per-hit picks); a K1 hit counts a K string. The plan's route, or NIL."
  (let* ((st (hs e)) (o (opp-of e)) (hits (if o (fighter-combo-hits (fighter o)) 0)))
    (when (or (<= hits (hss-ai-plan-hits st)) (> (- *match-tick* (hss-ai-plan-t st)) 90))
      (setf (hss-ai-plan st) nil (hss-ai-plan-k st) 0))
    (setf (hss-ai-plan-hits st) hits (hss-ai-plan-t st) *match-tick*)
    (when (and (null (hss-ai-plan st)) (member name '(:hs-j1 :hs-k1)))
      (setf (hss-ai-plan st)
            (if (let ((c (brain-chance b *hs-ai-plan-p*))) (and (plusp c) (< (sim-rnd01) c)))   ; (no roll at 0: the host test)
                (let ((p (apply #'weighted-pick (sim-rnd01) *hs-ai-plans*)))
                  (case p
                    (:rinne (pace e :plan-rinne)) (:rinne-owari (pace e :plan-rinne-owari)) (:hana (pace e :plan-hana))
                    (t (pace e :plan-other)))
                  (or p :none))
                :none)))
    (when (eq name :hs-k1) (incf (hss-ai-plan-k st)))
    (let ((p (hss-ai-plan st))) (and p (not (eq p :none)) (getf *hs-ai-plan-routes* p)))))
(defun hs-ai-plan-cmd (e b f name route)
  "The plan's command at this link hit (HS-PLAN-NEXT) when the kit allows it now: the J / K link the string has, the bridge
(the sickle in, L's own checks), RAIDEN (its bar); else NIL (the style's pick)."
  (let* ((st (hs e)) (kit (fighter-kit f))
         (c (hs-plan-next route name (hss-ai-plan-k st) (hss-leapt st) (reiatsu-bars e))))
    (case c
      (:q (and (kit-next kit name :q) (why b :plan :q)))
      (:f (and (kit-next kit name :f) (why b :plan :f)))
      (:sig (let ((l (kit-l-link kit name)))
              (and l (eq (hss-state st) :in) (kit-command-ok-p e :sig kit l) (progn (pace e :ai-bridge) (why b :plan-bridge :sig)))))
      (:sp1 (and (kit-command-ok-p e :sp1) (progn (pace e :ai-plan-sp) (why b :plan-sp :sp1)))))))

;;; ================================================================ the Bankai's CPU (§17.5 #16)
(defun hs-r-style (e b)
  "His CPU's ranged style: rolled once per entry into the ranged mode (*HS-AI-R-STYLE-W*, round01 b1a0), kept while he stays
in it (the bind's reflex marks the form left: the next entry rolls again). An entry from the Shikai (the awakening) also rolls
the waking noose (*HS-AI-WAKE-P*, round01 cell b3a0)."
  (let ((st (hs e)))
    (unless (eq (hss-ai-form st) :bankai)
      (when (eq (hss-ai-form st) :base)                ; (cell b3a0: the awakening, one roll: the waking noose)
        (setf (hss-ai-wake st) (< (sim-rnd01) (brain-chance b *hs-ai-wake-p*)) (hss-ai-wake-t st) *match-tick*))
      (setf (hss-ai-form st) :bankai
            (hss-ai-rstyle st) (apply #'weighted-pick (sim-rnd01) *hs-ai-r-style-w*))
      (pace e (hss-ai-rstyle st)))
    (hss-ai-rstyle st)))
(defun hs-r-sv (style key) "STYLE's value of KEY (*HS-AI-R-STYLES*)." (getf (getf *hs-ai-r-styles* style) key))
(defun hs-r-hits-at-p (cmd d)
  "Does the ranged mode's command CMD (:q J1, :f K1, :sig SAHARAI, :sp2 KUBIKAKE) reach a victim D m away (centre to
centre)? J1 3.05-6.2, K1 2.55-4.7 since §25.35 (§25.34's 4.05-7.2 / 2.55-5.7; 3.05-6.2 / 2.05-5.2 before: the knobs'
annuli, 0.05 in, + 0.2 of hurt radius),
SAHARAI to 3.1, KUBIKAKE 2.3-7.0 (their volumes + a hurt radius, a little inside)."
  (case cmd (:q (<= (+ *hs-r-j-dead* 0.05) d (+ *hs-r-j-reach* 0.2))) (:f (<= (+ *hs-r-k-dead* 0.05) d (+ *hs-r-k-reach* 0.2)))
    (:sig (<= d 3.1)) (:sp2 (<= 2.3 d 7.0))))
(defun hs-r-cmd-move (cmd)
  "The ranged mode's move of CMD (:q J1, :f K1, :sig SAHARAI, :sp2 KUBIKAKE)."
  (find-move (case cmd (:q :hs-r-j1) (:f :hs-r-k1) (:sig :hs-r-l) (t :hs-r-kubikake))))
(defun hs-r-pick (style d frames &optional kubi)
  "The ranged command that hits a victim D m away with its startup within FRAMES (b1a0): KUBIKAKE first when KUBI (his 200
there: the bind), then STYLE's opener where both reach (SANGE J1, SOKUBAKU K1), else the other, else SAHARAI; NIL when
nothing reaches in time."
  (let ((o (hs-r-sv style :open)))
    (loop for c in (list (and kubi :sp2) (and (hs-r-sv style :tip) (hs-r-tip-cmd d)) o (if (eq o :q) :f :q) :sig)
          when (and c (hs-r-hits-at-p c d) (<= (mv-s (hs-r-cmd-move c)) frames))
            return c)))
(defun hs-r-tip-cmd (d)
  "The ranged opener whose chain tip (its outer *HS-R-TIP* m: x1.71 for the whole route, §25.13) holds a victim D m away
(centre to centre, 0.2 m of hurt radius past the reach): J1 at 5.5-6.2, K1 at 4.0-4.7 (§25.35: J 3-6, K 2.5-4.5, the 0.5 m
tip; §25.30's 0.75 m: 5.25 / 4.25; 5.5 / 4.5 with §25.26's 0.5 m; J1 5.0-6.2, K1 4.0-5.0 with the 1.0 m tip until §25.26); NIL elsewhere. HISAGI-DRAW's tip glint reads it too."
  (cond ((<= (- *hs-r-j-reach* *hs-r-tip*) d (+ *hs-r-j-reach* 0.2)) :q)
        ((<= (- *hs-r-k-reach* *hs-r-tip*) d (+ *hs-r-k-reach* 0.2)) :f)))
(defun-fast hs-tip-band (v)
  "HS-R-TIP-CMD on the distance V [0] (an f32vec: HISAGI-DRAW's *HS-G*, the opponent's) without boxing it: 1 K1's tip
(4.0-4.7 m), 2 J1's (5.5-6.2), else NIL (the host test sweeps both against each other). 0 B."
  (declare (type f32vec v))
  (let ((d (aref v 0)) (tip (the single-float *hs-r-tip*))
        (jr (the single-float *hs-r-j-reach*)) (kr (the single-float *hs-r-k-reach*)))
    (declare (single-float d tip jr kr))
    (cond ((and (<= (- jr tip) d) (<= d (+ jr 0.2f0))) 2) ((and (<= (- kr tip) d) (<= d (+ kr 0.2f0))) 1))))
(defun hs-r-ai-throw-p (e b d)
  "His CPU's KUBIKAKE off a confirmed J / K hit (B4c: SP2's cancel copy): his own 200 there (HS-BK-OK, KIT-COMMAND-OK-P), the
victim D m off inside its line (HS-R-REACHES-P), one roll *HS-AI-THROW-P*."
  (and (kit-command-ok-p e :sp2) (hs-r-reaches-p (find-move :hs-r-kubikake-c) d) (< (sim-rnd01) (brain-chance b *hs-ai-throw-p*))))
(defun hs-r-reaches-p (mv d)
  "Will move MV's hit reach a victim D m from him (centre to centre): past its dead zone and inside its far edge (the
arc's r, a line's end; a route link's chain, HS-R-LINK-SEG, *HS-R-LINK-REACH*; + a hurt cylinder's 0.36), any window?"
  (loop for w across (mv-hits mv)
        thereis (let* ((v (first (hw-vols w)))
                       (edge (cond (v (if (> (aref v 0) 0.5) (+ (aref v 2) (aref v 4)) (aref v 1)))
                                   ((eq (hw-seg w) 'hs-r-link-seg) *hs-r-link-reach*))))
                  (and edge (>= d (or (hw-min w) 0.0)) (<= d (+ edge 0.36))))))
(defun hs-r-ai-move (e b f mv)
  "His :move-reflex in the ranged mode (ai.lisp AI-REFLEX, in his own move, before the generic string reflex): on a link-1 /
link-2 hit, on its land step: KUBIKAKE's cancel when HS-R-AI-THROW-P (the bind); else one roll (*HS-AI-ROUTE-DMG-P*): the damage pick (the K link: spread K2s / K3, gathered K2 /
K3G) when the victim stands inside its reach, else the speed pick (the J link) inside its; neither reaches: the string
ends there (:WAIT, kept until the move ends: no whiff). A learner baiting its Burst read: the generic reflex (NIL). (The
route itself is the opener's: K1 at 2-4 m, J1 at 2-4.5 m, his :moves bands; B4c, §22.6; B4d, §22.8.)"
  (let* ((st (hs e)) (kit (fighter-kit f)) (name (mv-name mv)) (style (hs-r-style e b)))
    (cond ((and (eq name :hs-r-l) (eq (fighter-contact f) :hit) (= (fighter-sf f) (+ (mv-s mv) (mv-a mv))))
           ;; b1a0: SAHARAI hit, its first recovery frame: J / K cancel it into the style's opener (§25.5: on a hit only)
           (let ((c (hs-r-pick style (max (fighter-dist f) *hs-saharai-hit*) 99)))   ; (round01 b2a0's fix via b3a1: where the push leaves him)
             (when (member c '(:q :f)) (pace e :ai-l-cancel) (why b :l-cancel c))))
          ((not (and (eq (fighter-contact f) :hit) (string-link-p kit name) (null (fighter-queued f))
                     (not (and (brain-learn b) (eq (lrn-cmd (brain-learn b)) :bait)))))
           nil)
          ((= (fighter-sf f) (fighter-land-sf f))
           (setf (hss-ai-end st) nil)
           (let* ((nq (kit-next kit name :q)) (nf (kit-next kit name :f)) (d (fighter-dist f))
                  (in-q (and nq (hs-r-reaches-p nq d))) (in-f (and nf (hs-r-reaches-p nf d))))
             (cond ((and (eql 1 (hs-r-sv style :kubi-at)) (hs-r-ai-throw-p e b d))   ; (NAWAJI: the bind first)
                    (pace e :ai-throw) (why b :kubikake :sp2))
                   ((and in-f (< (sim-rnd01) (brain-chance b (hs-r-sv style :route-dmg)))) (pace e :ai-dmg) (why b :route-dmg :f))
                   (in-q (pace e :ai-fast) (why b :route-fast :q))
                   (in-f (pace e :ai-dmg) (why b :route-dmg :f))
                   (t (setf (hss-ai-end st) mv) (pace e :ai-end) (why b :route-end :wait)))))
          ((eq (hss-ai-end st) mv) :wait))))
(defun hs-grey-margin (e)
  "E's grey loss minus his opponent's in E's bind (positive: E is behind)."
  (let* ((st (hs e)) (o (opp-of e)) (g (gauges e)) (go (gauges o)))
    (- (hs-grey-loss (hss-r0 st) (gauges-reishi g) (hss-k0 st) (gauges-konpaku g))
       (hs-grey-loss (hss-or0 st) (gauges-reishi go) (hss-ok0 st) (gauges-konpaku go)))))
(defun hs-b-bite-cmd (d left lock)
  "The bite's command (cell b2a2, pure): the victim D m off (his own yank's), LEFT frames of his reel as perceived, LOCK his
own frames before an attack may start (the guard cancel's, FIGHTER-GC-LEFT): :q J1 when its startup fits the reel after
the lock and D is within the generic follow-up's reach (+ 0.6); :wait while it fits and the yank still brings him in; else
NIL (look again: the reel his KUBIKAKE dealt shows only after its hitstop and the perception delay)."
  (let ((j1 (find-move :hs-b-j1)))
    (when (> left (+ (mv-s j1) (max 0 lock)))
      (if (< d (+ (mv-reach j1) 0.6)) :q :wait))))
(defun hs-b-ai-move (e b f mv)
  "His :move-reflex in the bind mode (round01 cells b2a0 / b2a1's, ported by cell b3a2), a link's hit, its land step: a K link
2 (K2 / K2s) on a red victim with no Soul Break finish due, him not behind on grey and a bar in the pool: SP1 KUSARI-AME
cancelled out of it (*HS-AI-B-TODOME-P*), not the link 3 whose hit forces the O ender's grey Kikon; else the K link (the
cinching route, *HS-AI-B-ROUTE-P*). A learner baiting its Burst read, any other step or link: NIL (the generic string
reflex)."
  (when (and (eq (fighter-contact f) :hit) (= (fighter-sf f) (fighter-land-sf f)) (null (fighter-queued f))
             (hss-bound (hs e)) (not (and (brain-learn b) (eq (lrn-cmd (brain-learn b)) :bait))))
    (cond ((and (member (mv-name mv) '(:hs-b-k2 :hs-b-k2s))
                (kikon-ready-p e) (not (ai-sb-finish-p e)) (<= (hs-grey-margin e) 0) (kit-command-ok-p e :sp1)
                (< (sim-rnd01) (brain-chance b *hs-ai-b-todome-p*)))
           (pace e :ai-b-todome)
           (why b :b-todome :sp1))
          ((and (kit-next (fighter-kit f) (mv-name mv) :f) (brain-roll b *hs-ai-b-route-p*))
           (pace e :ai-b-route)
           (why b :b-route :f)))))

;;; ================================================================ the learning CPU's situations and ASSIST (DUEL_HISAGI §25.20)
;;; The integration of the shipped CPU (§25.1 step 6, §25.19; the user, 2026-10-18: 「學玩家習慣」「AUTO COMBO 路線」「AUTO
;;; GUARD 風車」). His CPU's decisions are unchanged: a learner (a CPU Hisagi facing a human) only re-reads three of its rolls,
;;; and ASSIST presses for a human what his CPU's own functions pick on the assist's HARD brain.
;;;   learner  his own situations (LEARN-DEF-KIT, DUEL_LEARNING §11): :REAP his K1 at a free human (the fence's reap, the
;;;            punish, a neutral K1), :WARD his windmill up (the ward: the human shot or charged), :BIND-AHEAD / :BIND-BEHIND
;;;            a bind's neutral with him ahead / behind on grey (§17.5 #16's 「bound, ahead / behind」). The human's answer:
;;;            :GUARD :HOHO :ATTACK :BACK :TAKE. Read once per event (the learner's own stream, x *HS-LEARN-DIFF*): the
;;;            reap's roll per approach (HS-LEARN-REAP), the ward's sweep roll (HS-LEARN-WARD), the bind's walk-in
;;;            (HS-LEARN-BIND)
;;;   AUTO GUARD  the Shikai's :assist-guard: the windmill against an incoming ranged threat (HS-ASSIST-GUARD)
;;;   AUTO COMBO  every form's :assist-combo: the Shikai's route plans (RINNE / RINNE-OWARI / HANA, §25.16), the ranged
;;;            mode's routes by style off the tip opener, the bind's cinching K route and its bite (HS-ASSIST-COMBO)
(defparameter *hs-learn-episode* 30
  "Frames a situation of his waits for the human's answer, + the perception delay (§25.20: K1's 18 f startup and its reach).")

(defun hs-learn-class (act)
  "The human's generic action class ACT (an index of *LEARN-ACTIONS*, LEARN-ACTION's) as his situations' class: a move of
any kind :ATTACK, a Hoho / Step :HOHO, a guard :GUARD, backing off :BACK; else NIL (a burst: not counted)."
  (and act (case (aref *learn-actions* act) ((:j :k :i :l :sp :o) :attack) (:hoho :hoho) (:guard :guard) (:back :back))))

(defun hs-learn-sit (name new kstr hstate bound calm was-calm ahead)
  "Pure: the situation of his that opens this step, or NIL. NAME his move (NIL: none), NEW it started this step, KSTR it is
a windmill's K string, HSTATE the human's perceived state, BOUND a bind on, CALM both free (WAS-CALM: last step), AHEAD
him not behind on grey. A reeling human: none; :REAP his K1 (not a windmill's) on a free human; :WARD his windmill (not the
bridge); :BIND-AHEAD / :BIND-BEHIND a bind's neutral (both free, its first step)."
  (cond ((member hstate '(:stun :air :down :wakeup)) nil)
        ((and new (eq name :hs-k1) (not kstr) (member hstate '(:idle :run :guard))) :reap)
        ((and new (eq name :hs-kaza)) :ward)
        ((and bound calm (not was-calm)) (if ahead :bind-ahead :bind-behind))))


(defstruct (hsl (:conc-name hsl-))
  "His learner's own state within a match (LRN-KDATA)."
  (own-mv nil) (calm nil) (ox 0f0 :type single-float) (oz 0f0 :type single-float) (ux 0f0 :type single-float)
  (uz 0f0 :type single-float) (len 0 :type fixnum))
(inline-readers hsl)

(defun hs-learn-step (e b s d l)
  "His learner's step (LEARN-DEF-KIT's :step): a situation's onset (HS-LEARN-SIT) and the human's answer to it (LEARN-ACTION
as HS-LEARN-CLASS, with his way away from the onset's line; reeling :TAKE; at the episode's end a held guard :GUARD, else
uncounted)."
  (declare (ignore d))
  (let* ((k (or (lrn-kdata l) (setf (lrn-kdata l) (make-hsl))))
         (st (hs e)) (f (fighter e)) (mv (current-move f))
         (hst (snap-state s)) (hprev (lrn-hstate l)) (bound (hss-bound st))
         (calm (and (member (fighter-state f) '(:idle :run :guard)) (member hst '(:idle :run :guard)) t))
         (sit (and (< (lrn-ksit l) 0)
                   (hs-learn-sit (and mv (mv-name mv)) (and mv (not (eq mv (hsl-own-mv k)))) (hss-kstr st) hst bound
                                 calm (hsl-calm k) (or (not bound) (<= (hs-grey-margin e) 0))))))
    (setf (hsl-own-mv k) mv (hsl-calm k) calm)
    (when sit
      (let* ((dx (- (snap-x s) (aref (pos-of e) 0))) (dz (- (snap-z s) (aref (pos-of e) 2))) (m (max 1e-3 (hypot dx dz))))
        (setf (hsl-ox k) (f32 (snap-x s)) (hsl-oz k) (f32 (snap-z s)) (hsl-ux k) (f32 (/ dx m)) (hsl-uz k) (f32 (/ dz m))
              (hsl-len k) (+ *hs-learn-episode* (brain-delay b))))
      (learn-kit-open l sit))
    (when (>= (lrn-ksit l) 0)
      (let ((end (>= (incf (lrn-kep-t l)) (hsl-len k)))
            (away (+ (* (- (snap-x s) (hsl-ox k)) (hsl-ux k)) (* (- (snap-z s) (hsl-oz k)) (hsl-uz k)))))
        (cond ((member hst '(:stun :air :down :wakeup)) (learn-kit-close l :take))
              ((let ((a (learn-action hprev hst (snap-kind s) (/= (snap-start s) (lrn-hstart l)) away)))
                 (and a (progn (learn-kit-close l (hs-learn-class a)) t))))
              (end (learn-kit-close l (and (member hst '(:guard :guard-hit)) :guard))))))))


(learn-def-kit :hisagi :situations #(:reap :ward :bind-ahead :bind-behind) :actions #(:guard :hoho :attack :back :take)
               :step 'hs-learn-step)

;;; ASSIST (assist.lisp; DUEL_ASSIST): the windmill for AUTO GUARD, the routes for AUTO COMBO
(defun hs-assist-guard (e b s d)
  "The Shikai's :assist-guard (AUTO GUARD's first answer, 「AUTO GUARD 風車」): a ranged threat coming (RANGED-THREAT-IN
4-24 f, the sickle in, L allowed), one roll per threat at his CPU's *HS-AI-WINDMILL-P* on the assist's HARD brain: L, the
windmill up through it, marked :ASSIST (HS-AI-SIG-HOLD: held *HS-AI-WINDMILL-HOLD* f, no K of the assist's: his own K
takes the charged string). A command or NIL."
  (let* ((st (hs e)) (threat (and (eq (hss-state st) :in) (ranged-threat-in e b s d 4 24)))
         (edge (and threat (not (hss-ai-threat st)))))
    (setf (hss-ai-threat st) threat)
    (when (and edge (kit-command-ok-p e :sig) (< (sim-rnd01) (brain-chance b *hs-ai-windmill-p*)))
      (setf (hss-ai-kz-threat st) :assist)
      (pace e :as-windmill)
      (why b :as-windmill :sig))))

(defun hs-as-entry (c)
  "Pure: his CPU's pick C at a link's hit as that move's AUTO COMBO entry: NIL -> :GENERIC (the generic AUTO COMBO), :WAIT
-> :END (the string ends there: his J eaten, no whiff), :Q -> :OWN (his own J is the link), else the command."
  (case c ((nil) :generic) (:wait :end) (:q :own) (t c)))
(defun hs-as-press (entry j)
  "Pure: one step of a move's AUTO COMBO ENTRY with his J pressed or latched (J): values the route's answer (a command,
:NONE or NIL), the entry after it, and whether his J is eaten. Undecided / :GENERIC: NIL; :OWN: :NONE (his J goes on);
:END / :DONE: :NONE, his J eaten; a command: on his J (then :DONE), else :NONE (waiting for it)."
  (case entry
    ((nil :generic) (values nil entry nil))
    (:own (values :none entry nil))
    ((:end :done) (values :none entry t))
    (t (if j (values entry :done nil) (values :none entry nil)))))

(defun hs-as-decide (e f b mv)
  "AUTO COMBO's pick at a hit of his move MV (its land step): his CPU's own on the assist's brain, the latch emptied (as
STRING-REFLEX's): the Shikai's route plan (HS-AI-PLAN at every hit, its plan at the first: RINNE / RINNE-OWARI / HANA,
HS-AI-PLAN-CMD); the ranged mode's link by its style (HS-R-AI-MOVE: the K for the damage, the J, the end, NAWAJI's noose);
the bind's cinching K route and TODOME (HS-B-AI-MOVE). The entry (HS-AS-ENTRY)."
  (let ((q (fighter-queued f)) (name (mv-name mv)))
    (setf (fighter-queued f) nil)
    (prog1 (hs-as-entry
            (case (fighter-form f)
              (:base (let ((route (hs-ai-plan e b name))) (and route (hs-ai-plan-cmd e b f name route))))
              (:bankai (and (string-link-p (fighter-kit f) name) (hs-r-ai-move e b f mv)))
              (t (setf (hss-ai-form (hs e)) :bankai-bind)   ; (the ranged style re-rolls at the next entry: HS-R-STYLE)
                 (hs-b-ai-move e b f mv))))
      (setf (fighter-queued f) q))))

(defun hs-assist-combo (e f b s d vp)
  "His forms' :assist-combo (assist.lisp AUTO-ROUTE, 「AUTO COMBO 路線」). In a move: at a hit's land step the pick is decided
(HS-AS-DECIDE), then pressed on his J (HS-AS-PRESS: the J pressed or latched in this move, the generic AUTO COMBO's rule);
the windmill's K off a bridge the assist pressed is his tick's (HS-KAZA-TICK); the ranged L SAHARAI that hit: his J ->
K1 when the style's pick from where it pushes him is K1. Free, his J: the ranged mode's tip opener (K1 with him on its tip,
4.0-4.7 m since §25.35, HS-R-TIP-CMD; on J1's, 5.5-6.2 m, his J is it); a bind's bite (HS-B-BITE-CMD: his J held back while the yank still
brings the victim in). A command, :NONE or NIL (the generic AUTO COMBO)."
  (let* ((st (hs e)) (mv (current-move f)) (j (vpad-command-pressed-p vp :quick nil)))
    (cond (mv
           (let ((key (- *match-tick* (fighter-sf f))))
             (unless (= key (hss-as-key st)) (setf (hss-as-key st) key (hss-as-cmd st) nil))
             (when (and (null (hss-as-cmd st)) (eq (fighter-contact f) :hit) (= (fighter-sf f) (fighter-land-sf f)))
               (setf (hss-as-cmd st) (hs-as-decide e f b mv)))
             (if (and j (eq (mv-name mv) :hs-r-l) (eq (fighter-contact f) :hit) (>= (fighter-sf f) (+ (mv-s mv) (mv-a mv)))
                      (eq :f (hs-r-pick (hs-r-style e b) (max (fighter-dist f) *hs-saharai-hit*) 99)))
                 (progn (pace e :as-l-cancel) :f)
                 (multiple-value-bind (c entry eat) (hs-as-press (hss-as-cmd st) (or j (eq (fighter-queued f) :q)))
                   (setf (hss-as-cmd st) entry)
                   (when eat (vpad-consume! vp :quick) (when (eq (fighter-queued f) :q) (setf (fighter-queued f) nil)))
                   (when (and c (not (member c '(:none :f :sig)))) (setf (fighter-queued f) nil))   ; (a cancel drops his J link)
                   (when (and c (not (eq c :none))) (pace e :as-route))
                   c))))
          ((and j (member (fighter-state f) '(:idle :run :guard)))
           (case (fighter-form f)
             (:bankai (and (eq (hs-r-tip-cmd d) :f) (kit-command-ok-p e :f) (progn (pace e :as-tip) :f)))
             (:bankai-bind
              (when (and (hss-bound st) (< (- *match-tick* (hss-bind-from st)) *hs-ai-bite-window*))
                (case (hs-b-bite-cmd (fighter-dist f) (if (eq (snap-state s) :stun) (snap-left-seen s b) 0) (fighter-gc-left f))
                  (:wait (vpad-consume! vp :quick) :none)
                  (:q :none)))))))))

;; the keys (assist.lisp reads them off the form's kit; his CPU never does): AUTO GUARD's windmill in the Shikai, AUTO
;; COMBO's routes in every form
(let ((k (find-kit :hisagi :base)))
  (unless (getf (kit-ai k) :assist-guard) (setf (kit-ai k) (list* :assist-guard 'hs-assist-guard (kit-ai k)))))
(dolist (form *hs-forms*)
  (let ((k (find-kit :hisagi form)))
    (unless (getf (kit-ai k) :assist-combo) (setf (kit-ai k) (list* :assist-combo 'hs-assist-combo (kit-ai k))))))

