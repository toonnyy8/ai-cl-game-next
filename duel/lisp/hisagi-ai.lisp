;;;; hisagi-ai.lisp — Hisagi's CPU: the Shikai's (his kit's :ai, docs/duel/DUEL_HISAGI.md §10), the Bankai's (§17.5 #16), the learner's
;;;; situations and the ASSIST routes (§25.20), and the CPU's knobs (the *HS-AI-...* parameters, every chance EASY <= NORMAL <= HARD)
;;;; (split out of hisagi.lisp 2026-10-21, refactor round 2). Loads right after hisagi.lisp, which keeps the three knobs the kit data
;;;; reads while its DEFKIT is evaluated (*HS-AI-STRING-K* *HS-AI-L-AFTER-J* *HS-AI-AWAKEN*) and *HS-AI-RELEASE-MARGIN* (read by the rule function HS-RELEASE-WANTED-P); the kits name the CPU functions as bare
;;;; symbols (:reflex :opp-reflex :sp-ender :sig-hold :move-reflex), so they are late-bound. Plain CL (the host rules test loads it
;;;; after hisagi.lisp); no DEFUN-FAST. The dream-rsi searches (docs/research/hisagi-ai-drsi, skill duel-character-cpu) edit this file.
(in-package :duel)

;;; ================================================================ the CPU's knobs (moved here from hisagi.lisp's knob sections, in their order)
(defparameter *hs-ai-modoshi-p* '(:easy 0.3 :normal 0.5 :hard 0.7)
  "His CPU, once per OUT start (keyed by the throw's tick): MODOSHI as soon as he is free, else wait for the auto-retrieve.")
(defparameter *hs-ai-windmill-p* '(:easy 0.3 :normal 0.6 :hard 0.9)
  "His CPU: the windmill against a ranged threat (RANGED-THREAT-IN 4-24 f), once per threat (its rising edge).")
(defparameter *hs-ai-windmill-hold* 36 "... L held this many frames (the threat passes).")
(defparameter *hs-ai-kaza-k-p* '(:easy 0.4 :normal 0.7 :hard 0.9)
  "His CPU, once per L press (but against a ranged threat): K out of the windmill once the charged K1 reaches him (L held
on meanwhile), else the plain windmill (S1 §23.1, 2026-10-18).")
(defparameter *hs-ai-kaza-margin* 0.3 "... K once the real distance is within K1's charged line + this (m; its tip + radii ~0.66).")
(defparameter *hs-ai-sp-ender-p* '(:easy 0.1 :normal 0.35 :hard 0.8)
  "His CPU's SP off a link-3 hit (:sp-ender): SP1 RAIDEN (6.5 m line) after a K ender or RIN (round01 cell b3a1: SP2 SHIBARI after
RIN -> RAIDEN, HS-AI-ENDER).")
(defparameter *hs-ai-opp-step-p* '(:easy 0.1 :normal 0.25 :hard 0.5)
  "A CPU facing him (:opp-reflex): a side Step against NAGE / SP1 (the Bankai's TSUISA / SP1 / KUBIKAKE too, B2b), once per
throw start, while its line will reach it.")
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
(defparameter *hs-ai-styles* '(:easy (:rensa 0.55 :kariba 0.45) :normal (:rensa 0.55 :kariba 0.45)
                               :hard (:rensa 0.8 :kariba 0.2))
  "His CPU's style per match (weights; HS-AI-STYLE rolls it once, on the first brain step that asks): RENSA 連鎖 the chain-
link rushdown (J up close, then the windmill bridge into the charged K string), KARIBA 刈場 the reaping ground (K range,
K1 punishing every whiff it can reach, K1 -> K2 -> the leap in). Both keep the reaping fence (cell b3a0): KARIBA reaps and
hops out of the dead zone more (*HS-AI-REAP-P*, *HS-AI-HOP-P*). By his brain's difficulty (round01 cell b3a0: HARD 0.55 /
0.45 -> 0.8 / 0.2: forced, RENSA won 217 of 480 HARD matches, KARIBA 190, behind against every opponent; EASY / NORMAL
kept, NORMAL's fair game and the awaken A/B's never-awaken rows). Either one turns, per event, to the close-in (TSUME 詰) once
the Hoho read says he Hohos the K1 (MIKIRI 見切り, cell b0a1: HS-MIKIRI-UNSAFE-P, HS-AI-CLOSE). Under either, each combo rolls
its route plan (cell b0a2, *HS-AI-PLANS*: 輪 RINNE the chain's wheel, 花 HANA the user's showpiece).")
(defparameter *hs-ai-bridge-p*
  '(:rensa (:easy 0.3 :normal 0.5 :hard 0.85) :kariba (:easy 0.15 :normal 0.25 :hard 0.45))
  "His CPU, once per J link hit (J1 / J2 / J2K, its land step; HS-AI-MOVE): L, the windmill bridge, then K at the
windmill's f9 (HS-AI-KAZA-K: the K1 combos in the push's stagger); else the K link (K2J / K3), else the J link. (Cell b3a0:
NORMAL 0.6 / 0.3 -> 0.5 / 0.25, with *HS-AI-SP-ENDER-P*'s 0.4 -> 0.35 and *HS-AI-K1-PUNISH-P*'s 0.2 / 0.3 -> 0.2 / 0.25: the
fence made NORMAL 0.61, over the band; 0.52 after (240 matches), the awaken A/B's never-awaken HK / HB rows 25-28 of 60;
0.45 / 0.2 had NORMAL 0.49 but HK 18, HB 19.)")
(defparameter *hs-ai-jk-p* '(:rensa (:easy 0.5 :normal 0.7 :hard 0.8) :kariba (:easy 0.6 :normal 0.8 :hard 0.9))
  "... and, no bridge, the K link (the chain: K2J / K3) this share of the time, else the J link.")
(defparameter *hs-ai-style-leap-p* '(:rensa (:easy 0.3 :normal 0.5 :hard 0.7) :kariba (:easy 0.2 :normal 0.35 :hard 0.5))
  "*HS-AI-LEAP-P* by style (HS-AI-MOVE: the leap off a K1 / K2 hit while his intent wants him close).")
(defparameter *hs-ai-anti-breaker-p* '(:easy 0.4 :normal 0.55 :hard 0.7)
  "His CPU (HS-AI-GUARD-REFLEX; cell b0a0), once per opponent Breaker seen within *AI-ANTI-BREAKER-RANGE*: in the Shikai,
seen in its aura within J1's reach + 0.3 m early enough for J1 to land before its strike (its aura frames + his perception
delay within *BREAKER-AURA*: HARD's 8 f sees it, NORMAL's 14 never), J1 at once (the generic J1 waits for the dash and came
0-6 f late, 123 combos at HARD). The generic *AI-ANTI-BREAKER-P*'s numbers. (The Bankai's answer: *HS-AI-R-ANTI-BREAKER-P*,
b1a0's Hoho / back hop, since cell b3a0.)")
(defparameter *hs-ai-guard-wait-p* '(:easy 0.6 :normal 0.75 :hard 0.9)
  "His CPU (HS-AI-GUARD-WAIT, every form's :reflex; cell b0a0, the Bankai's since b3a0), once per guard episode the generic reflex
would Breaker (held *AI-GUARD-BREAK-HOLD* f within *AI-GUARD-BREAK-RANGE* m): no Breaker (it waits the guard out), else
the Breaker (the generic's 0.4 Breaker = 0.6 wait; his Breaker whiffed 70 of 103 at HARD: the stronger CPUs J it).")
(defparameter *hs-ai-o-ender-p* '(:rensa (:easy 0.0 :normal 0.0 :hard 0.0) :kariba (:easy 0.0 :normal 0.0 :hard 0.0))
  "His CPU's O ender off a completed string on a victim not red (HS-AI-ENDER, his :sp-ender; the kit's generic :o-ender
0.0), by style (cell b0a0: RENSA 0 / 0.05 / 0.1, KARIBA 0.05 / 0.15 / 0.25; cell b3a0 -> 0: the CPUs guard the rush's
follow-up; RAIDEN, the chain theme, ends the string instead: HARD 0.39 -> 0.41, signature 0.85 -> 0.88 at 20 seeds) ...")
(defparameter *hs-ai-o-ender-mash-p* '(:easy 0.3 :normal 0.6 :hard 0.9)
  "... and against a J masher (AI-MASH-P, as his brain saw him) the O ender this share of the time: the masher punished the
RAIDEN finish (HARD vs the masher 0.79 -> 0.62 without any O ender, 224 matches).")
(defparameter *hs-ai-k1-punish-p* '(:rensa (:easy 0.1 :normal 0.2 :hard 0.55) :kariba (:easy 0.15 :normal 0.25 :hard 0.85))
  "His CPU (HS-AI-REFLEX), once per opponent action seen recovering at K1's range (past its dead zone, inside 6.0 m) with at
least K1's startup left as perceived: K1, the chain punishing the whiff (K2 / K3 follow).")
;; cell b3a0, the reaping fence (HS-AI-FENCE): the Shikai keeps the chain's distance; K1 swept into an approach (the HARD
;; masher 0.66 -> 1.0, his signature 0.79 -> 0.85: the K string at range, not the J trade)
(defparameter *hs-ai-reap-p* '(:rensa (:easy 0.15 :normal 0.25 :hard 0.7) :kariba (:easy 0.2 :normal 0.35 :hard 0.9))
  "His CPU, once per approach (he closes in faster than *HS-AI-REAP-CLOSING* m/s within *HS-AI-REAP-FROM* m, idle or
running): K1 NAGI timed so the sweep meets him inside *HS-AI-REAP-WINDOW* at its hit frame (HS-AI-FENCE; cell b3a0).")
(defparameter *hs-ai-hop-p* '(:rensa (:easy 0.0 :normal 0.0 :hard 0.7) :kariba (:easy 0.0 :normal 0.05 :hard 0.9))
  "His CPU, once per stay inside K1's dead zone (HS-FENCE-BAND) with him not attacking: the back hop and run out to
*HS-AI-HOP-KEEP* m (HS-AI-FENCE; cell b3a0: the masher 0.66 -> 1.0 with the reap at HARD; at NORMAL a hop costs the fair
game, so it stays rare there).")
(defparameter *hs-ai-reap-closing* 1.5 "... an approach: his perceived closing speed above this (m/s) ...")
(defparameter *hs-ai-reap-from* 7.5 "... within this many m.")
(defparameter *hs-ai-reap-sustain* '(:easy 1 :normal 1 :hard 3)
  "... and only once he has closed in this many perceived steps in a row, by his brain's difficulty (HS-P) (round01 cell b3a0,
§25.15, HARD only: NORMAL's 1 keeps the never-awaken Shikai of the awaken A/B as it was, HK 17-19 of 60 with 3; a one-step blip of a walk,
Lille's stance step, read as a 3.6 m/s approach, swept K1 at 6-7 m into the air: 913 of 1784 reaps at HARD whiffed, her shot
landing on its recovery; 6 steps: 354 whiffs of 893 but fewer K strings, signature -0.013; 2: HARD -0.02; a runner exempt:
HARD 0.41).")
(defparameter *hs-ai-reap-window* '(3.4 5.6)
  "... K1 when he will stand this far at its hit frame (m: past the 3.0 m dead zone and inside the 6.0 m sweep, a margin
each side).")
(defparameter *hs-ai-fence-in* 2.9 "The fence's close band: entered below this (m) ...")
(defparameter *hs-ai-fence-out* 3.5 "... left only beyond this (m: the hysteresis; one hop roll per stay).")
(defparameter *hs-ai-hop-keep* 4.3 "The hop's run ends at this distance (m: inside K1's sweep, the reap's window ahead).")
;; cell b0a0 (this freeze, DUEL_HISAGI §25.15): the windmill read on a charge and turned into the sweep (風車返し KAZAGURUMA-
;; GAESHI), and the red string's link 2 into RAIDEN (綴の止め TODOME). The diagnosis: the shot of a held ranged charge (a
;; snipe's level-2 copy starts 8 f before its hit) is never a RANGED-THREAT-IN 4-24 f for a HARD brain (8 f late), so the
;; ward rose late or never; a ward never swept (no K out of it); a string's link 3 on a red victim forces the generic O
;; ender, whose 70 is plain damage (4.4 % of his damage). (Tried and dropped: the reap held back against a perfect-Hoho
;; reader, its roll skipped while he could Hoho: Ichigo 4 -> 10-16 of 80 at HARD, but Yamamoto / Rukia lost more and his
;; J1 openers cost signature: 1200 HARD matches 0.409 -> 0.375-0.408.)
(defparameter *hs-ai-todome-p* '(:easy 0.2 :normal 0.4 :hard 1.0)
  "His CPU, once per link-2 hit (J2 / K2 / K2J / J2K, its land step; HS-AI-MOVE) on a victim in the red with no Soul Break
finish due (AI-SB-FINISH-P) and his SP1's bar there: TSUZURI RAIDEN cancelled out of it (綴の止め TODOME), not the link 3
(its hit on a red victim forces the generic O ender, a 2-Konpaku Kikon: plain damage); the chain's lightning takes the
red window down toward the Soul Break (3 Konpaku in the Shikai) (cell b0a0).")
(defparameter *hs-ai-charge-ward-p* '(:rensa (:easy 0.15 :normal 0.3 :hard 0.7) :kariba (:easy 0.2 :normal 0.4 :hard 0.9))
  "His CPU in the Shikai, once per charge of his (a move seen in its :hold phase with a :ranged window ahead, beyond the
blade's 2.5 m; one roll per its start): the windmill raised against the shot to come (HS-AI-REFLEX; cell b0a0).")
(defparameter *hs-ai-sweep-p* '(:rensa (:easy 0.2 :normal 0.4 :hard 0.7) :kariba (:easy 0.3 :normal 0.5 :hard 0.9))
  "His CPU, once per ward (the windmill raised against a ranged threat or a charge): held its full *HS-KAZA-MAX* and K out of
it, the charged K string, once no ranged hit of his is pending and K1 at the charge reaches him (HS-AI-KAZA-K: the sweep
after the shot, x up to 1.6 its reach), else the plain ward (*HS-AI-WINDMILL-HOLD*) (cell b0a0).")
(defparameter *hs-ai-sweep-wait* 12
  "... the sweep's K waits while a ranged hit of his lands within this many frames as perceived (the ward takes it).")
(defparameter *hs-ai-charge-far* 9.0
  "... the charge read only within this many m (K1 at the full charge, x1.6, reaches 9.6) (cell b0a0).")
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
(defparameter *hs-ai-mikiri-p* '(:easy 0.0 :normal 0.2 :hard 0.75)
  "His CPU in the Shikai, once per decision of the fence (an approach's reap at its K1, a dead-zone stay's hop), while the
read says his K1 is Hoho'd (HS-MIKIRI-UNSAFE-P): the reap's K1 held back, the hop out to the reap's range not taken (cell
b0a1: 0.9 / 0.9 at HARD with the close-in measured 116 HARD wins of 240, 0.75 / 0.75 124, 0.6 / 0.6 6 fewer of 120).")
(defparameter *hs-ai-mikiri-prior* '(1 3)
  "The read's prior: perfect Hohos, K1s not Hoho'd (a 0.25 rate weighing 4 K1s) (cell b0a1).")
(defparameter *hs-ai-mikiri-rate* 0.42
  "... over this share of his K1s perfect-Hoho'd (HS-MIKIRI-RATE, the prior's included), while he can Hoho: the read holds K1
back (cell b0a1: the reap nets -92 a reap against Ichigo's 55 %, +56 / -8 against Kenpachi's 37 %, +96 against Rukia's 30 %;
0.42 with the (1 3) prior 124 HARD wins of 240, 0.38 117, 0.35 with (1 4) 117, 0.28 112).")
(defparameter *hs-ai-hoho-quiet* 36
  "... he can't Hoho for this many frames after his Hoho was last seen (perceived; the lockout 60 from its start, the Hoho 24
long) (cell b0a1).")
(defparameter *hs-ai-close-p* '(:easy 0.0 :normal 0.3 :hard 0.75)
  "His CPU in the Shikai under the read (cell b0a1), once per stay of the opponent (idle or running) in the step-in band
(J1's reach + 0.15 .. + a Step - 0.2) or the far band (to 7.5 m), and once per neutral decision due there: the close-in, the
Step in (the generic Step -> J lashes J1 at its f10), from farther the dash in to 3.2 m, where the step-in band rolls again
(cell b0a1: HARD 0.9 measured 118 HARD wins of 240, 0.75 124; the step band from 2.6 m: within noise).")

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
(defparameter *hs-ai-utsusemi-p* '(:easy 0.0 :normal 0.0 :hard 0.9)
  "His CPU in the Shikai (HS-AI-UTSUSEMI, his :reflex), once per opponent action (the brain's Hoho roll): the Hoho through a
committed move coming (the generic Hoho's own test: live, near, perceived >= 6 f of startup left, his flash-step to spare)
this share of the time in all, the generic :hoho's 0.3 included (it acts first below it); 0 at EASY / NORMAL: they keep the
kit's 0.3, so NORMAL's share and the awaken A/B are b3a1's to the match (cell b3a2). Measured (HARD, seeds 1-80 both seats,
960 matches, with KOSHU in the bind; wins / signature): 0.3 (off) 540 / 0.901, 0.6 557 / 0.893, 0.9 597 / 0.883, 1.0 589 /
0.882 (Ichigo 68 -> 100 of 160, Rukia 141 -> 150, Kenpachi 47 -> 54; his Hohos 1.4 -> 2.9 a match; the counter's plain 60 is
the signature's cost, 0.015 -> 0.030 of his damage). (Tried with it and dropped: the guard against the rest, the generic's
0.35 -> 0.8 / 1.0 at HARD, 592 / 613 vs 610: noise; K1 punish 0.95 for both styles, 603.)")
;; his CPU in the Bankai (§17.5 #16; every chance EASY <= NORMAL <= HARD, rolled once per event)
(defparameter *hs-ai-throw-p* '(:easy 0.02 :normal 0.05 :hard 0.95)
  "His CPU, ranged mode: KUBIKAKE (SP2 since B4c) cancelled off a J / K hit with his own 200 and the victim in its line's
reach, one roll per hit (HS-R-AI-MOVE, HS-R-AI-ENDER; §17.5 #16 rolled it once per entry into 4-7 m, from neutral). Round01
cell b1a0: 0.2 / 0.45 / 0.7 -> 0.05 / 0.1 / 0.95: the bind at HARD (+24 a second there, the ranged mode -35); NORMAL's bind
was the fair game's undoing once the Bankai came at 2000 taken (NORMAL 0.80 -> 0.46 with 0.05, ~0.5 with 0.1). (Round01 cell b3a0: NORMAL 0.1 -> 0.05, EASY 0.05 -> 0.02: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
(defparameter *hs-ai-saharai-p* '(:easy 0.05 :normal 0.1 :hard 0.15)
  "His CPU, ranged mode: L SAHARAI once per entry within *HS-AI-CLOSE* m (§17.1: the escape at close range). B4d (§22.8):
his only close-in answer (K1 misses inside 2.0 m), no cooldown now, so still one roll per entry (never per step: no spam);
his :moves band inside 2.0 m gives L K1's old weight too. b1a0: 0.3 / 0.6 / 0.85 -> 0.05 / 0.1 / 0.15 of what the back
Step (*HS-AI-ESCAPE-P*) leaves, only while he is not attacking (its S 18 lost to every J pressed into it: 30 % of the
baseline's SAHARAIs were hit in their startup), never into a runner; SAHARAI's main use is now the punish by annulus
(HS-R-PICK) and its hit cancelled into J1 / K1 (HS-R-AI-MOVE).")
(defparameter *hs-ai-close* 2.0 "... the close band, m (2.5 -> 2.0, 2026-10-18, §22.2: the dead zone's; 2.0 -> 1.0, §25.3: K reaches from 1.0; 1.0 -> 2.0, §25.5: K from 2.0).")
(defparameter *hs-ai-release-p* '(:easy 0.05 :normal 0.1 :hard 0.9)
  "His CPU in a bind: the release once per change event (a soul turned grey, every 100 of the pool drained) while his grey
loss exceeds the opponent's by *HS-AI-RELEASE-MARGIN* (Konpaku x 1300 + Reishi, §17.5 #16). (Round01 cell b1a0: NORMAL 0.6 -> 0.3, EASY 0.3 -> 0.2: the fair game once the Bankai comes at 2000 taken; HARD kept. Round01 cell b3a0: NORMAL 0.3 -> 0.1, EASY 0.2 -> 0.05: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
(defparameter *hs-ai-rel-margin* 150
  "His CPU's own release margin in the bind's reflex (b1a0; *HS-AI-RELEASE-MARGIN*'s 300 before): a release undoes every grey
loss, his Kikons in it too, so he takes it sooner; KAIBAKU-GEKI releases at its S at any distance, once the opponent is
not attacking (HS-B-AI-REFLEX).")
(defparameter *hs-ai-bite-p* '(:easy 0.0 :normal 0.5 :hard 1.0)
  "Cell b2a2, 縛口 SHIBARI-GUCHI the bind's bite: once per bind (HS-B-AI-BITE), while his KUBIKAKE's reel holds the victim
(perceived: the new stun, its frames left over J1's startup + his own guard-cancel lock): J1 pressed the step his own yank
brings the victim within its reach, so it starts as his lock ends and lands in the reel; the cinching route after it.
Before it the generic follow-up waited for the perceived distance of the yank still under way, and the KOJO band rolled on
that distance (HARD, the awakening forced, 292 binds: an early J1 drained 104 of 135, every first hit his; a KOJO opener 11
of 37, the opponent's first hit 22). (K1 HIKIGIRI as the opener measured 1 f late: his guard-cancel lock lets no attack
start before ~22 f in, K1's S 18 lands ~40, the reel ends ~39: blocked or perfect-Hoho'd, 118 of 262 the opponent's
first hit.) HARD, 960 matches (seeds 1-80, both seats): his first hit in a bind 482 of 616 -> 571 of 599, drained 387 ->
451, the bind dealt / taken a second 37.6 / 22.6 -> 46.4 / 20.6, wins 533 -> 550.")
(defparameter *hs-ai-bite-window* 40
  "Cell b2a2: the bite looks this many frames after the bind's start (KUBIKAKE's stun 30 from its 9 f hitstop's end: the
perceived reel before ~17 f in is the old string's).")
(defparameter *hs-ai-rel-step* 50 "... and the pool's change event every this many of it drained (100 -> 50, b1a0).")
(defparameter *hs-ai-kojo-p* '(:easy 0.1 :normal 0.2 :hard 0.3)
  "His CPU in a bind: L KOJO (the pull and the strike) once per entry into 2.5-4 m, sparingly (its -24 / 0: B4c; HIKIYOSE's
was 0.3 / 0.6 / 0.85 beyond 4 m).")
(defparameter *hs-ai-rel-low* 150
  "Cell b3a0, the bind's ledger: once the pool is down to this (450 more damage drains it, a combo or two), any grey loss is
worth the release (*HS-AI-REL-MARGIN* above it): a drained end while behind turns his grey loss real, a release costs
nothing but the pool's rest (HS-REL-BAR).")
(defparameter *hs-ai-kaibaku-reach* 2.8
  "Cell b3a0: KAIBAKU-GEKI (reach 3.0) is his release only within this many m as perceived (its 120 real lands); farther, the
plain P (*HS-AI-PLAIN-RELEASE-P*).")
(defparameter *hs-ai-plain-release-p* '(:easy 0.05 :normal 0.1 :hard 0.9)
  "His CPU in a bind, behind on grey with the foe beyond KAIBAKU-GEKI's reach: the plain release (P, FREE) this often, else
he waits for the strike's range (B4c; gone with FREE in §24.5, back with it in §25.14). (Cell b3a0, the ledger: 0.1 / 0.15 /
0.2 -> 0.05 / 0.1 / 0.9 of the release roll's yes, now the release farther than *HS-AI-KAIBAKU-REACH*, not only without SP2.)")
(defparameter *hs-ai-bind-sp-p* '(:easy 0.05 :normal 0.1 :hard 0.7)
  "His CPU in a bind: an SP off a link-3 hit (:sp-ender) only while he is ahead on grey (it drains the pool, §17.5 #16). (Round01 cell b1a0: NORMAL 0.35 -> 0.15: the fair game once the Bankai comes at 2000 taken; HARD kept.) (Round01 cell b3a0: NORMAL 0.15 -> 0.1: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
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
(defparameter *hs-ai-b-close-p* '(:easy 0.0 :normal 0.0 :hard 1.0)
  "In a bind, once per neutral decision due with him 1.8 m or more off (HS-B-AI-REFLEX): taken with nothing, so he walks in to
the bind's J1 (+162 net a neutral J1 at HARD) instead of the generic Step-in (its SENGEN -40 net) or a neutral K1 (-24; none in
the bind's bands either) (round01 cell b2a1's, ported by cell b3a2).")

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
  '(:sentan (:open :f :anti :f :tip t :route-dmg (:easy 0.7 :normal 0.8 :hard 0.9) :kubi-at 3 :keep 4.6)
    :nawaji (:open :f :anti :f :tip nil :route-dmg (:easy 0.5 :normal 0.6 :hard 0.7) :kubi-at 1 :keep 3.5)
    :kaisen (:open :q :anti :q :tip t :route-dmg (:easy 0.1 :normal 0.15 :hard 0.2) :kubi-at 3 :keep 5.0))
  "The ranged route styles: :open the opener where both reach and no tip holds him (J1 the spread route, K1 the gathered
one), :anti the anti-approach strike, :tip (T) every opener picked so the victim stands on its chain tip (HS-R-TIP-CMD: K1
at 4-5 m, J1 at 5-6 m: the whole route x1.71, §25.13), :route-dmg the K link's chance per link hit (HS-R-AI-MOVE), :kubi-at
the first link KUBIKAKE's cancel may take (1: off the opener's hit, the bind first; 3: only off the ender, the route's
damage first), :keep the distance his back hop runs out to. SENTAN keeps K1's tip (4.6 m) and plays the gathered K route
to the end (K1 -> K2 -> K3G on the tip: 313); NAWAJI throws the noose off the first link that hits; KAISEN keeps J1's tip
(5.0 m) and plays the spread J route (J2 -> J3's 6.6 m push: back to the tip; the Reiatsu x1.69) for the bars.")
(defparameter *hs-ai-wake-p* '(:easy 0.0 :normal 0.0 :hard 0.0)
  "Cell b3a0, once per awakening (the entry into the ranged mode from the Shikai): the waking noose, KUBIKAKE thrown as soon
as its line holds him and he isn't attacking, inside *HS-AI-WAKE-WINDOW* frames (HS-R-AI-REFLEX): the bind sought at once. (Round01 cell b3a0: NORMAL 0.1 -> 0.05: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)
Round01 cell b3a2: 0.02 / 0.05 / 0.8 -> 0 (off; the knob and its code kept): the noose thrown off the awakening hit 19-23 % of
the time and netted -92 a throw over the next 240 f (HARD, 960 matches); without it, with UTSUSEMI, 610 HARD wins of 960 vs 597
(the awakened matches 208 vs 195 of 451, the others identical), the ranged theme's share the same (0.040 vs 0.039).")
(defparameter *hs-ai-wake-window* 300 "... frames from the awakening (its cinematic's ~180 included).")
(defparameter *hs-ai-punish-p* '(:easy 0.05 :normal 0.1 :hard 0.9)
  "His CPU in the ranged mode, once per opponent action: punish him recovering / reeling with the move whose annulus holds him
(HS-R-PICK: SAHARAI inside 2 m, K1 2-3 m, the style's opener 3-5 m, J1 5-6 m; the generic punish presses J1, which misses
inside 3 m), and after its own blockstun the block punish the same way (b1a0). (Round01 cell b1a0: NORMAL 0.6 -> 0.35, EASY 0.3 -> 0.2: the fair game once the Bankai comes at 2000 taken; HARD kept. Round01 cell b3a0: NORMAL 0.35 -> 0.1, EASY 0.2 -> 0.05: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
(defparameter *hs-ai-anti-p* '(:easy 0.05 :normal 0.1 :hard 0.7)
  "His CPU in the ranged mode, once per approach of his (b1a0: a run; cell b3a0: his perceived closing speed, walking or
running, *HS-AI-REAP-CLOSING*): the style's anti-approach strike (J1 / K1, the other one when it fits better) timed to land
as he comes into its annulus at that speed (HS-R-AI-REFLEX). (Round01 cell b1a0: NORMAL 0.45 -> 0.25, EASY 0.2 -> 0.1: the fair game once the Bankai comes at 2000 taken; HARD kept. Round01 cell b3a0: NORMAL 0.25 -> 0.1, EASY 0.1 -> 0.05: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
(defparameter *hs-ai-dodge-p* '(:easy 0.05 :normal 0.1 :hard 0.7)
  "His CPU in the ranged mode, once per opponent action: his J / K / L perceived starting up close (its hit 2-14 f off):
the back hop through it (the Step's iframes), else the generic guard / Hoho (b1a0). (Round01 cell b1a0: NORMAL 0.45 -> 0.2, EASY 0.2 -> 0.1: the fair game once the Bankai comes at 2000 taken; HARD kept.) (Round01 cell b3a0: NORMAL 0.2 -> 0.1: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
(defparameter *hs-ai-r-anti-breaker-p* '(:easy 0.1 :normal 0.2 :hard 0.85)
  "His CPU, the ranged and bind modes, once per opponent action: his Breaker seen dashing in within 4 m: Hoho through it, else the back hop
(HS-R-AI-ANTI-BREAKER; b1a0). (Round01 cell b1a0: NORMAL 0.6 -> 0.35, EASY 0.3 -> 0.2: the fair game once the Bankai comes at 2000 taken; HARD kept.) (Round01 cell b3a0: NORMAL 0.35 -> 0.2: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")
(defparameter *hs-ai-r-guard-wait-p* '(:easy 0.6 :normal 0.75 :hard 1.0)
  "*HS-AI-GUARD-WAIT-P* in the Bankai's two modes (HS-AI-GUARD-WAIT): his Breaker into a long guard there hit 9 of 46 at HARD,
-164 net a press (round01 cell b1a1: HARD 0.9 -> 1.0; ported by cell b3a1).")
(defparameter *hs-ai-escape-p* '(:easy 0.1 :normal 0.2 :hard 0.85)
  "His CPU in the ranged mode, once per entry within *HS-AI-CLOSE* m while he isn't attacking: the back Step out to the
style's :keep (b1a0); else SAHARAI *HS-AI-SAHARAI-P* of the rest (not into a runner), else the generic guard. (Round01 cell b1a0: NORMAL 0.7 -> 0.35, EASY 0.3 -> 0.2: the fair game once the Bankai comes at 2000 taken; HARD kept.) (Round01 cell b3a0: NORMAL 0.35 -> 0.2: the Bankai at 3000 taken put NORMAL at 0.61 (factor 0.93); 0.562 after these cuts, 480 matches; HARD kept.)")

;;; ================================================================ the CPU (his kit's :ai; DUEL_HISAGI §10)
(defun hs-p (b plist) "PLIST's chance (:easy :normal :hard) at brain B's difficulty." (getf plist (brain-difficulty b) (getf plist :normal 0.0)))
(defun hs-roll (b plist)
  "One roll of PLIST's chance at brain B's difficulty (round01 cell b2a1's): no SIM-RND01 drawn at 0 or 1 (a sure answer; the
host tests have no sim stream)."
  (let ((c (hs-p b plist))) (and (plusp c) (or (>= c 1.0) (< (sim-rnd01) c)))))
(defun hs-ai-style (e)
  "His CPU's style this match (*HS-AI-STYLES*): rolled once (SIM-RND01) on the first brain step that asks, kept on his HSS (a
fresh one each match, never reset by a Kikon)."
  (let ((st (hs e)))
    (or (hss-ai-style st)
        (let* ((b (ai-brain e))
               (style (apply #'weighted-pick (sim-rnd01) (getf *hs-ai-styles* (if b (brain-difficulty b) :normal)))))
          (pace e (if (eq style :rensa) :style-rensa :style-kariba))   ; (the `duel hisagi` line: which style played)
          (setf (hss-ai-style st) style)))))
(defun hs-sp (e b plist) "PLIST's (by style, then by difficulty) chance for E's style at brain B's difficulty." (hs-p b (getf plist (hs-ai-style e))))
(defun hs-k1-punish-ok-p (d left)
  "May K1 punish an opponent D m away with LEFT frames of recovery as perceived: past its dead zone (+ 0.2, the step he may
take), inside its reach + 0.2, and K1's startup + 1 frame left?"
  (and (> d (+ *hs-k-dead* 0.2)) (< d (+ (mv-reach (find-move :hs-k1)) 0.2)) (>= left (1+ (mv-s (find-move :hs-k1))))))
(defun hs-ai-guard-wait (b s d &optional (plist *hs-ai-guard-wait-p*))
  "Every form's free reflex (cell b0a0): a guard episode the generic reflex would Breaker (held *AI-GUARD-BREAK-HOLD* f
within *AI-GUARD-BREAK-RANGE* m): his own roll, the Breaker unless *HS-AI-GUARD-WAIT-P* (the generic's roll taken; his
Breaker whiffed 70 of 103 at HARD: the stronger CPUs J it). A command or NIL."
  (when (and (eq (snap-state s) :guard) (>= (snap-guard-t s) *ai-guard-break-hold*) (< d *ai-guard-break-range*)
             (/= (brain-break-key b) (snap-start s)))
    (setf (brain-break-key b) (snap-start s))
    (and (>= (sim-rnd01) (hs-p b plist)) (why b :guard-break :breaker))))
(defun hs-ai-guard-reflex (e b s d)
  "The Shikai's free reflex's first answers (cell b0a0): his Breaker seen in its aura up close (*HS-AI-ANTI-BREAKER-P*, one
roll per Breaker): J1 at once while it still lands first (the generic waits for the dash: too late there; HARD's 8 f
delay sees it in time, NORMAL's 14 never); then HS-AI-GUARD-WAIT. (The Bankai's answer is HS-R-AI-ANTI-BREAKER's.) A
command or NIL."
  (let ((st (hs e)))
    (cond ((and (eq (snap-kind s) :breaker) (eq (snap-phase s) :aura) (< d (+ *hs-j-reach* 0.3))
                (/= (snap-start s) (hss-ai-pk st)) (<= (+ (snap-hold s) (brain-delay b)) *breaker-aura*))
           (setf (hss-ai-pk st) (snap-start s))         ; (up close its strike comes 8 f after the aura: J beats I)
           (and (< (sim-rnd01) (hs-p b *hs-ai-anti-breaker-p*)) (why b :anti-breaker-j :q)))
          ((hs-ai-guard-wait b s d)))))
(defun hs-ai-utsusemi (e b s d)
  "空蝉 UTSUSEMI (cell b3a2): his CPU's Hoho through a committed move coming, the generic Hoho's test (ai.lisp AI-REFLEX: a
live J / K / L / SP / Breaker / Kikon near him, perceived >= 6 f of its startup left, his flash-step to spare, no reflect),
on the brain's one Hoho roll per opponent action between the kit's :hoho (the generic acts below it) and
*HS-AI-UTSUSEMI-P*. A command or NIL."
  (let ((g (gauges e)) (p (hs-p b *hs-ai-utsusemi-p*)) (h (getf (kit-ai (kit-of e)) :hoho 0.2)) (r (brain-hoho-roll b)))
    (when (and (> p h) (<= h r) (< r p)
               (eq (snap-state s) :move) (member (snap-kind s) '(:quick :flash :sig :sp :breaker :kikon))
               (snap-live-p s) (snap-near-p s e d *ai-threat-margin*) (>= (- (snap-s s) (snap-sf s)) 6)
               (not (snap-reflect-p s)) (not (kit-rooted (kit-of e))) (hoho-ready-p e)
               (ai-hoho-spare-p (gauges-fs g) (gauges-reishi g) (gauges-reishi-max g)))
      (pace e :ai-utsusemi)
      (why b :utsusemi :hoho))))
(defun hs-ai-reflex (e b s d)
  "His :reflex (free): the windmill against a ranged threat (RANGED-THREAT-IN 4-24 f), one roll per threat; K1 punishing
an opponent seen recovering at its range (HS-K1-PUNISH-OK-P, *HS-AI-K1-PUNISH-P* by style, one roll per his action); MODOSHI
once per OUT start (*HS-AI-MODOSHI-P*), else he waits the auto-retrieve out; last, the reaping fence (HS-AI-FENCE, cell
b3a0). Cell b0a0 (§25.15): his charge of a ranged shot seen (HS-CHARGING-P, one roll a charge, *HS-AI-CHARGE-WARD-P*):
the windmill up before the shot; a ward rolls its sweep (HS-AI-SIG-HOLD). A command or NIL."
  (let* ((st (hs e)) (threat (and (eq (hss-state st) :in) (ranged-threat-in e b s d 4 24)))
         (edge (and threat (not (hss-ai-threat st)))))
    (setf (hss-ai-threat st) threat (hss-ai-form st) :base)   ; (the ranged style re-rolls at the next entry: HS-R-STYLE)
    (hs-mikiri-note e b s nil)                                ; (cell b0a1: the read's K1 resolved, his Hoho seen)
    (cond ((and edge (kit-command-ok-p e :sig) (< (sim-rnd01) (hs-p b *hs-ai-windmill-p*)))
           (pace e :ai-windmill)
           (setf (hss-ai-kz-threat st) t)               ; (a ward: HS-AI-SIG-HOLD rolls its sweep, cell b0a0)
           (why b :windmill :sig))
          ;; cell b0a0: his charge of a ranged shot seen (its :hold phase): the windmill up before the shot, one roll a charge
          ((and (hs-charging-p s d) (/= (snap-start s) (hss-ai-hk st)) (eq (hss-state st) :in))
           (setf (hss-ai-hk st) (snap-start s))
           (when (and (kit-command-ok-p e :sig) (< (sim-rnd01) (hs-sp e b *hs-ai-charge-ward-p*)))
             (pace e :ai-charge-ward)
             (setf (hss-ai-kz-threat st) t)
             (why b :charge-ward :sig)))
          ((hs-ai-guard-reflex e b s d))
          ((hs-ai-utsusemi e b s d))                    ; (cell b3a2: the HARD Hoho through a committed swing)
          ((and (eq (hss-state st) :in) (snap-recovering-p s) (/= (snap-start s) (hss-ai-pk st))
                (hs-k1-punish-ok-p d (snap-left-seen s b)) (kit-command-ok-p e :f))
           (setf (hss-ai-pk st) (snap-start s))         ; (one roll per his action)
           (when (< (sim-rnd01) (hs-sp e b *hs-ai-k1-punish-p*))
             (pace e :ai-k1-punish)
             (why b :k1-punish :f)))
          ((and (eq (hss-state st) :out) (not (eql (hss-ai-out st) (hss-throw-t st))))
           (setf (hss-ai-out st) (hss-throw-t st) (hss-ai-modoshi st) (< (sim-rnd01) (hs-p b *hs-ai-modoshi-p*)))
           nil)
          ((and (eq (hss-state st) :out) (hss-ai-modoshi st))
           (setf (hss-ai-modoshi st) nil)
           (pace e :ai-modoshi)
           (why b :modoshi :f))
          ((hs-ai-close e b s d))
          ((hs-ai-fence e b s d)))))
(defun hs-mikiri-rate (k n)
  "The read (cell b0a1): the share of his K1s an opponent able to Hoho perfect-Hoho'd, K of N this match, with
*HS-AI-MIKIRI-PRIOR*."
  (destructuring-bind (a b) *hs-ai-mikiri-prior* (/ (float (+ k a)) (+ n a b))))
(defun hs-hoho-ready-p (state fs since)
  "Can a fighter Hoho, as the read sees him (cell b0a1): perceived STATE free (idle, running, guarding, stepping), his
flash-step FS (the HUD's) at a Hoho's *FS-HOHO*, and SINCE frames past his last Hoho seen beyond *HS-AI-HOHO-QUIET* (its
lockout)?"
  (and (member state '(:idle :run :guard :step)) (>= fs *fs-hoho*) (> since *hs-ai-hoho-quiet*) t))
(defun hs-opp-hoho-ready-p (e s)
  "Can his opponent Hoho now, as E sees him (S: HS-HOHO-READY-P)?"
  (and s (hs-hoho-ready-p (snap-state s) (gauges-fs (gauges (opp-of e))) (- *match-tick* (hss-ai-hseen (hs e))))))
(defun hs-mikiri-unsafe-p (e s)
  "Does the read (cell b0a1) hold his K1 back now: the opponent able to Hoho (HS-OPP-HOHO-READY-P) and his K1s perfect-Hoho'd
over *HS-AI-MIKIRI-RATE* this match (HS-MIKIRI-RATE)?"
  (let ((st (hs e)))
    (and (hs-opp-hoho-ready-p e s) (> (hs-mikiri-rate (hss-ai-hr-k st) (hss-ai-hr-n st)) *hs-ai-mikiri-rate*))))
(defun hs-mikiri-note (e b s mv)
  "The read's bookkeeping (cell b0a1; his own CPU only, HS-TICK-BRAIN): his Hoho seen (S); a K1 of his starting (MV, from his
:move-reflex) noted with his perfect count and whether he could Hoho then; free again (MV NIL), that K1 resolved: one
more K1 into a Hoho, and one more perfect-Hoho'd if his perfect count rose."
  (let ((st (hs e)))
    (when (eq b (hs-tick-brain e))
      (when (and s (eq (snap-state s) :hoho)) (setf (hss-ai-hseen st) *match-tick*))
      (let ((pf (gauges-perfects (gauges (opp-of e)))) (f (fighter e)))
        (cond ((and mv (eq (mv-name mv) :hs-k1))
               (let ((start (- *match-tick* (fighter-sf f))))
                 (unless (= start (hss-ai-hr-key st))
                   (setf (hss-ai-hr-key st) start (hss-ai-hr-p0 st) pf (hss-ai-hr-ready st) (hs-opp-hoho-ready-p e s)))))
              ((and (null mv) (>= (hss-ai-hr-key st) 0))
               (when (hss-ai-hr-ready st)
                 (incf (hss-ai-hr-n st))
                 (when (> pf (hss-ai-hr-p0 st)) (incf (hss-ai-hr-k st)) (pace e :ai-hoho-read)))
               (setf (hss-ai-hr-key st) -1)))))))
(defun hs-ai-close (e b s d)
  "The close-in under the read (cell b0a1): once per stay of the opponent, idle or running, in the step-in band (J1's reach
+ 0.15 .. + a Step - 0.2) or the far band (to 7.5 m), while HS-MIKIRI-UNSAFE-P (not against a J masher: the reap is his
answer), *HS-AI-CLOSE-P*: the Step in toward J1's reach (the generic Step -> J lashes J1 at its f10), from the far band
the dash in to 3.2 m. A command, :PRESSED or NIL."
  (let* ((st (hs e)) (r (mv-reach (find-move :hs-j1)))
         (zone (cond ((< d (+ r 0.15)) nil) ((< d (+ r *step-distance* -0.2)) :step) ((< d 7.5) :far))))
    (unless (eq zone (hss-ai-cz st)) (setf (hss-ai-cz st) zone (hss-ai-cz-rolled st) nil))
    (when (and zone (or (not (hss-ai-cz-rolled st)) (<= (brain-decide-t b) 1))   ; (a stay's entry, or a neutral decision due)
               (member (snap-state s) '(:idle :run)) (eq (hss-state st) :in)
               (not (ai-mash-p b)) (not (kit-rooted (kit-of e))) (hs-mikiri-unsafe-p e s))
      (setf (hss-ai-cz-rolled st) t)
      (when (< (sim-rnd01) (hs-p b *hs-ai-close-p*))
        (when (<= (brain-decide-t b) 1) (setf (brain-decide-t b) (ai-decide-time e b)))   ; (the decision taken: the close-in)
        (pace e (if (eq zone :step) :ai-close :ai-rush))
        (ai-dash b 1.0 (if (eq zone :step) r 3.2))
        (why b (if (eq zone :step) :step-in :rush-in) :pressed)))))
(defun hs-reap-at (d v frames)
  "Where an opponent D m away, closing at V m/s, stands FRAMES frames from now (m)."
  (- d (* v (/ frames 60.0))))
(defun hs-reap-ok-p (at) "Does K1 reach a victim AT m away at its hit frame (inside *HS-AI-REAP-WINDOW*)?"
  (<= (first *hs-ai-reap-window*) at (second *hs-ai-reap-window*)))
(defun hs-fence-band (in d)
  "The fence's close band with hysteresis: IN (he was in it) stays in until D passes *HS-AI-FENCE-OUT*; else in below
*HS-AI-FENCE-IN* (a one-roll stay, never a roll per jittering step)."
  (if in (< d *hs-ai-fence-out*) (< d *hs-ai-fence-in*)))
(defun hs-ai-fence (e b s d)
  "The Shikai's reaping fence (cell b3a0; the last of his free :reflex): his perceived closing speed from the last step's
distance; an approach (he closes in faster than *HS-AI-REAP-CLOSING* m/s within *HS-AI-REAP-FROM* m, idle or running,
not attacking) rolls once (*HS-AI-REAP-P* by style): K1 when he will stand inside its annulus at its hit frame (HS-REAP-AT:
his perception delay + K1's startup + 1 ahead, HS-REAP-OK-P), the chain swept into his walk; a stay inside K1's dead zone
(HS-FENCE-BAND) with him not attacking rolls once (*HS-AI-HOP-P* by style): the back hop and run out to *HS-AI-HOP-KEEP* m,
where the reap waits for him. An approach counts once he has closed in *HS-AI-REAP-SUSTAIN* perceived steps in a row
(round01 cell b3a0). A command, :PRESSED or NIL."
  (let* ((st (hs e)) (ss (snap-state s)) (calm (member ss '(:idle :run :guard)))
         (v (if (= (hss-ai-pt st) (1- *match-tick*)) (* 60.0 (- (hss-ai-pd st) d)) 0.0))
         (closing (and calm (not (eq ss :guard)) (> v *hs-ai-reap-closing*) (< d *hs-ai-reap-from*)))
         (n (setf (hss-ai-app-n st) (if closing (min 999 (1+ (hss-ai-app-n st))) 0)))
         (coming (and closing (>= n (hs-p b *hs-ai-reap-sustain*))))
         (fz (hs-fence-band (hss-ai-fz st) d)))
    (setf (hss-ai-pd st) (f32 d) (hss-ai-pt st) *match-tick*)
    (when (and coming (not (hss-ai-app st)))
      (setf (hss-ai-app-go st) (hs-learn-reap e b (< (sim-rnd01) (hs-sp e b *hs-ai-reap-p*)))))   ; (§25.20: a learner's read)
    (unless (eq fz (hss-ai-fz st)) (setf (hss-ai-fz-rolled st) nil))
    (setf (hss-ai-app st) coming (hss-ai-fz st) fz)
    (cond ((and coming (hss-ai-app-go st) (eq (hss-state st) :in) (kit-command-ok-p e :f)
                (hs-reap-ok-p (hs-reap-at d v (+ (brain-delay b) (mv-s (find-move :hs-k1)) 1))))
           (setf (hss-ai-app-go st) nil)
           (if (and (hs-mikiri-unsafe-p e s) (< (sim-rnd01) (hs-p b *hs-ai-mikiri-p*)))   ; (cell b0a1: the read)
               (progn (pace e :ai-mikiri) nil)
               (progn (pace e :ai-reap) (why b :reap :f))))
          ((and fz calm (not (hss-ai-fz-rolled st)) (not (kit-rooted (kit-of e))))
           (setf (hss-ai-fz-rolled st) t)
           (when (and (< (sim-rnd01) (hs-sp e b *hs-ai-hop-p*))
                      (not (and (hs-mikiri-unsafe-p e s) (< (sim-rnd01) (hs-p b *hs-ai-mikiri-p*)))))   ; (b0a1: stay close)
             (ai-dash b -1.0 *hs-ai-hop-keep*)
             (pace e :ai-hop)
             (why b :hop :pressed))))))
(defun hs-ranged-move-p (mv) "Has move MV a :ranged hit window?"
  (and mv (loop for w across (mv-hits mv) thereis (member :ranged (hw-flags w))) t))
(defun hs-charge-shot-p (state phase mv d)
  "A ranged shot charged (cell b0a0): fighter STATE :move in PHASE :hold of a move MV with a :ranged window, D m away beyond
the blade's 2.5 m and inside *HS-AI-CHARGE-FAR*?"
  (and (eq state :move) (eq phase :hold) (< 2.5 d *hs-ai-charge-far*) (hs-ranged-move-p mv)))
(defun hs-charging-p (s d) "Is he, as perceived (S, D m away), charging a ranged shot (HS-CHARGE-SHOT-P)?"
  (hs-charge-shot-p (snap-state s) (snap-phase s) (snap-move s) d))
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
(defun hs-bridge-p (f)
  "Is F (his fighter) pressing L off a J link that hit (the windmill bridge, S1 §23.1)?"
  (let ((mv (fighter-move f)))
    (and (eq (fighter-state f) :move) mv (eq (fighter-contact f) :hit) (kit-j-link-p (fighter-kit f) (mv-name mv)) t)))
(defun hs-ai-sig-hold (kit d &optional e)
  "His :sig-hold (AI-COMMAND, once per L press: neutral, the J bridge, a ward): S1 (§23.1) K out of this windmill: always
off the bridge (HS-AI-MOVE rolled for it), else one roll (*HS-AI-KAZA-K-P*); a ward (a ranged threat or a charge,
HS-AI-REFLEX) rolls its sweep instead (*HS-AI-SWEEP-P*: :SWEEP, its K waits for the shot; cell b0a0): then L held its full
*HS-KAZA-MAX* (the charge runs until HS-AI-KAZA-K's K), else *HS-AI-WINDMILL-HOLD* frames (the threat passes)."
  (declare (ignore kit d))
  (let* ((st (and e (hs e))) (b (and e (ai-brain e))) (ward (and st (hss-ai-kz-threat st))))
    (when (eq ward :assist)                           ; (§25.20: AUTO GUARD's ward, HS-ASSIST-GUARD: the threat's hold, no K)
      (setf (hss-ai-kz-threat st) nil (hss-ai-kz st) nil)
      (return-from hs-ai-sig-hold *hs-ai-windmill-hold*))
    (when st
      (setf (hss-ai-kz-threat st) nil
            (hss-ai-kz st) (and b (if ward
                                      (hs-learn-ward e b (and (< (sim-rnd01) (hs-sp e b *hs-ai-sweep-p*)) :sweep))   ; (cell b0a0: the ward's sweep; §25.20 a read)
                                      (or (hs-bridge-p (fighter e)) (< (sim-rnd01) (hs-p b *hs-ai-kaza-k-p*)))))))
    (if (and st (hss-ai-kz st)) *hs-kaza-max* *hs-ai-windmill-hold*)))
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
(defun hs-ai-ender (e kit)
  "His :sp-ender (ai.lisp STRING-REFLEX, a link-3 hit): the O ender (the Kikon rush off the completed string: its follow-up
on a hit; a red victim's the generic reflex takes first) *HS-AI-O-ENDER-P* of the time by style (cell b0a0: the kit's
generic :o-ender 0, this roll instead); else SP1 TSUZURI RAIDEN (6.5 m: after a K ender's 6.45 m push, after RIN's 2.15 m),
*HS-AI-SP-ENDER-P* of the time. (Round01 cell b3a1: SP2 SHIBARI after RIN -> RAIDEN: SHIBARI's slam at f46 lands only when
its bind's 46 f stun outlasts the combo's hitstun decay: as a string's SP (after RIN, after K3, TODOME's link 2, the plan's
SP end) of 1238 binds at HARD, 480 matches, the slam landed 402 times and was blocked 659 (after RIN: 35 and 52 of 100): 60 + 90 written against RAIDEN's clean 110.)"
  (let ((b (ai-brain e)))
    (when b
      (cond ((and (kit-command-ok-p e :kikon kit t)
                  (< (sim-rnd01) (if (ai-mash-p b) (hs-p b *hs-ai-o-ender-mash-p*) (hs-sp e b *hs-ai-o-ender-p*))))
             (pace e :ai-o-ender) :kikon)
            ((and (>= (reiatsu-bars e) 1) (< (sim-rnd01) (hs-p b *hs-ai-sp-ender-p*)) (kit-command-ok-p e :sp1))
             (pace e :ai-sp1) :sp1)))))
(defun hs-ai-leap-wanted-p (d intent)
  "Does his CPU roll for the leap (S2, §23.5) off a K1 / K2 hit with the victim D m away and his brain's INTENT? Beyond
the K dead zone (the K reaches him, the J needs the leap), wanting him close (:approach / :pressure)."
  (and (> d *hs-k-dead*) (member intent '(:approach :pressure)) t))
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
            (if (let ((c (hs-p b *hs-ai-plan-p*))) (and (plusp c) (< (sim-rnd01) c)))   ; (no roll at 0: the host test)
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
              (and l (eq (hss-state st) :in) (kit-command-ok-p e :sig kit nil l) (progn (pace e :ai-bridge) (why b :plan-bridge :sig)))))
      (:sp1 (and (kit-command-ok-p e :sp1) (progn (pace e :ai-plan-sp) (why b :plan-sp :sp1)))))))
(defun hs-ai-move (e b f mv)
  "His Shikai's :move-reflex (ai.lisp AI-REFLEX, before the generic string reflex), on a link's hit, its land step, one
roll: a K1 / K2 hit beyond the K dead zone with his intent wanting him close (:approach / :pressure): the J link (the
leap: KJJ / KKJ) *HS-AI-STYLE-LEAP-P* of the time, else the K link (K2 / K3: it stays at range; S2, §23.5); a J1 / J2 / J2K
hit: L, the windmill bridge (*HS-AI-BRIDGE-P*: then K at the windmill's f9, the charged K string), else the K link
(*HS-AI-JK-P*: K2J / K3), else the J link. By his style (HS-AI-STYLE). First (cell b0a0): a link-2 hit on a red victim,
RAIDEN cancelled out of it (*HS-AI-TODOME-P*), not the link 3 the generic O ender would follow. Then (cell b0a2) the
combo's route plan (HS-AI-PLAN, HS-AI-PLAN-CMD: the §25.16 showpiece RINNE / HANA), else the per-hit picks above. A
learner baiting its Burst read, any other link: the generic reflex (NIL)."
  (hs-mikiri-note e b (hs-seen b) mv)                          ; (cell b0a1: the read notes his K1)
  (when (and (eq (fighter-contact f) :hit) (= (fighter-sf f) (fighter-land-sf f)) (null (fighter-queued f))
             (not (and (brain-learn b) (eq (lrn-cmd (brain-learn b)) :bait))))
    (let* ((kit (fighter-kit f)) (name (mv-name mv)) (nq (kit-next kit name :q)) (nf (kit-next kit name :f))
           (route (hs-ai-plan e b name)))                      ; (cell b0a2: the combo's plan, its bookkeeping)
      (cond ((and (member name '(:hs-j2 :hs-k2 :hs-k2j :hs-j2k)) (kikon-ready-p e) (not (ai-sb-finish-p e))   ; (cell b0a0)
                  (kit-command-ok-p e :sp1) (< (sim-rnd01) (hs-p b *hs-ai-todome-p*)))
             (pace e :ai-todome) (why b :todome :sp1))
            ((and route (hs-ai-plan-cmd e b f name route)))     ; (cell b0a2: the plan's route)
            ((and (member name '(:hs-k1 :hs-k2)) nq)
             (if (and (not (hss-leapt (hs e)))                 ; (§24.4: one leap a combo)
                      (hs-ai-leap-wanted-p (fighter-dist f) (brain-intent b)) (< (sim-rnd01) (hs-sp e b *hs-ai-style-leap-p*)))
                 (progn (pace e :ai-leap) (why b :leap :q))
                 (why b :string :f)))
            ((member name '(:hs-j1 :hs-j2 :hs-j2k))
             (let ((l (kit-l-link kit name)))
               (cond ((and l (eq (hss-state (hs e)) :in) (kit-command-ok-p e :sig kit nil l)
                           (< (sim-rnd01) (hs-sp e b *hs-ai-bridge-p*)))
                      (pace e :ai-bridge) (why b :bridge :sig))
                     ((and nf (< (sim-rnd01) (hs-sp e b *hs-ai-jk-p*))) (why b :string :f))
                     (nq (why b :string :q))
                     (nf (why b :string :f)))))))))
(defun hs-ai-opp (e b s d)
  "His kit's :opp-reflex (a CPU facing him): his perceived NAGE / SP1 in its startup, one roll per start (*HS-AI-OPP-STEP-P*);
a yes side-Steps once the line will reach E within 0-14 f (RANGED-THREAT-IN: beyond the blade's 2.0 m). (B4a's side Step
out of a mark: gone with the marks, B4c.)"
  (let ((mv (snap-move s)) (st (hs e)))   ; (his HSS on the CPU's own fighter: a fresh one each match)
    (when (and mv (eq (snap-state s) :move) (eq (snap-phase s) :main) (member (mv-name mv) '(:hs-k1 :hs-raiden :hs-r-sp1 :hs-r-kubikake :hs-r-kubikake-c))
               (< (snap-sf s) (mv-s mv)) (not (kit-rooted (kit-of e))))
      (unless (eql (hss-opp-key st) (snap-start s))
        (setf (hss-opp-key st) (snap-start s) (hss-opp-go st) (< (sim-rnd01) (hs-p b *hs-ai-opp-step-p*))))
      (when (and (hss-opp-go st) (ranged-threat-in e b s d 0 14))
        (setf (hss-opp-go st) nil)
        (pace (opp-of e) (if (member (mv-name mv) *hs-kubi-moves*) :opp-step-kubi :opp-side-step))
        (why b :anti-throw :side-step)))))

;;; ================================================================ the Bankai's CPU (§17.5 #16)
(defun hs-r-ai-anti-breaker (e b s d)
  "His CPU against an incoming Breaker, the ranged and bind modes (b1a0; the Shikai keeps HS-AI-GUARD-REFLEX's J1 in the aura, b0a0): seen in its dash within 4 m, one roll per action
(*HS-AI-R-ANTI-BREAKER-P*): Hoho through it, else the back hop (its iframes). The generic answer, J1 into the dash, is beaten
by its strike more often than not (and misses inside the ranged J's 3 m dead zone). A command or NIL."
  (and (eq (snap-kind s) :breaker) (eq (snap-phase s) :dash) (< d *ai-anti-breaker-range*) (not (kit-rooted (kit-of e)))   ; (b1a1 via b3a1: 4.0 -> the generic's 5.0: its J1 there hit 6 of 96)
       (< (brain-react-roll b) (hs-p b *hs-ai-r-anti-breaker-p*))
       (progn (pace e :ai-anti-breaker) (if (hoho-ready-p e) (why b :anti-breaker :hoho) (why b :anti-breaker :step)))))
(defun hs-r-style (e b)
  "His CPU's ranged style: rolled once per entry into the ranged mode (*HS-AI-R-STYLE-W*, round01 b1a0), kept while he stays
in it (the bind's reflex marks the form left: the next entry rolls again). An entry from the Shikai (the awakening) also rolls
the waking noose (*HS-AI-WAKE-P*, round01 cell b3a0)."
  (let ((st (hs e)))
    (unless (eq (hss-ai-form st) :bankai)
      (when (eq (hss-ai-form st) :base)                ; (cell b3a0: the awakening, one roll: the waking noose)
        (setf (hss-ai-wake st) (< (sim-rnd01) (hs-p b *hs-ai-wake-p*)) (hss-ai-wake-t st) *match-tick*))
      (setf (hss-ai-form st) :bankai
            (hss-ai-rstyle st) (apply #'weighted-pick (sim-rnd01) *hs-ai-r-style-w*))
      (pace e (hss-ai-rstyle st)))
    (hss-ai-rstyle st)))
(defun hs-r-sv (style key) "STYLE's value of KEY (*HS-AI-R-STYLES*)." (getf (getf *hs-ai-r-styles* style) key))
(defun hs-r-hits-at-p (cmd d)
  "Does the ranged mode's command CMD (:q J1, :f K1, :sig SAHARAI, :sp2 KUBIKAKE) reach a victim D m away (centre to
centre)? J1 3.05-6.2, K1 2.05-5.2, SAHARAI to 3.1, KUBIKAKE 2.3-7.0 (their volumes + a hurt radius, a little inside)."
  (case cmd (:q (<= 3.05 d 6.2)) (:f (<= 2.05 d 5.2)) (:sig (<= d 3.1)) (:sp2 (<= 2.3 d 7.0))))
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
(centre to centre, a hurt radius of slack): J1 at 5.0-6.2, K1 at 4.0-5.0; NIL nearer."
  (cond ((<= 5.0 d 6.2) :q) ((<= 4.0 d 5.0) :f)))
(defun hs-threat-p (e s d)
  "Is his perceived move S a live threat to E at the perceived distance D (the generic guard's test)?"
  (and (eq (snap-state s) :move) (snap-live-p s) (snap-near-p s e d *ai-threat-margin*)))
(defun hs-r-ai-reflex (e b s d)
  "His :reflex in the ranged mode (free; b1a0, the fence, every style). In order: his own blockstun just ended (felt at once):
the block punish by annulus (HS-R-PICK in the frames he has); his Breaker dashing in: HS-R-AI-ANTI-BREAKER; his J / K / L
perceived starting up close: the back hop through it (*HS-AI-DODGE-P*); he is seen recovering / reeling: the punish by
annulus, KUBIKAKE first with the 200 (one roll per action, *HS-AI-PUNISH-P*; a red one reeling is the generic Kikon's);
inside J1's dead zone the generic J1 punish / pressure reset would whiff: :WAIT instead, and after his blocked string at
any range too (round01 b1a0: the J1 reset into a free guard hit 6 %); he comes in (walking or running: his perceived
closing speed, the Shikai's reap's read, cell b3a0): once per approach (*HS-AI-ANTI-P*) the strike timed to his arrival:
a :tip style's opener whose chain tip will hold him (HS-R-TIP-CMD), else the style's strike in its annulus (no KUBIKAKE:
side-stepped, 17 % hit, round01 b1a0); once per entry within *HS-AI-CLOSE* m while he isn't attacking: the back Step out to the style's
:keep (*HS-AI-ESCAPE-P*: the hop, then the generic Step -> J lashes J1 from its far end), else L SAHARAI
(*HS-AI-SAHARAI-P*), else the generic guard / Hoho (the kit's :hoho 0.9)."
  (let* ((st (hs e)) (f (fighter e)) (style (hs-r-style e b)) (band (and (< d *hs-ai-close*) :close))
         (v (if (= (hss-ai-pt st) (1- *match-tick*)) (* 60.0 (- (hss-ai-pd st) d)) 0.0))   ; (his closing speed, m/s)
         (run (and (member (snap-state s) '(:idle :run)) (> v *hs-ai-reap-closing*) (< d *hs-ai-reap-from*))))
    (setf (hss-ai-pd st) (f32 d) (hss-ai-pt st) *match-tick*)
    (unless (eq band (hss-ai-band st)) (setf (hss-ai-band st) band (hss-ai-rolled st) nil ))
    (when (and run (not (hss-ai-run st))) (setf (hss-ai-run-go st) (< (sim-rnd01) (hs-p b *hs-ai-anti-p*))))
    (setf (hss-ai-run st) run)
    (flet ((fire (c why) (and c (kit-command-ok-p e c) (progn (pace e why) (why b why c)))))
      (cond
        ;; the block punish (our blockstun just ended: what he has left we feel at once)
        ((and (eq (brain-was b) :guard-hit) (<= (fighter-block-adv f) *ai-punish-adv*))
         (or (and (< (sim-rnd01) (hs-p b *hs-ai-punish-p*))
                  (fire (hs-r-pick style (fighter-dist f) (- (fighter-block-adv f)) (kit-command-ok-p e :sp2)) :ai-block-punish))
             (and (< d 3.0) :wait)))
        ;; his Breaker coming: Hoho through its dash, else the back hop (HS-R-AI-ANTI-BREAKER)
        ((hs-r-ai-anti-breaker e b s d))
        ;; his long guard: the Breaker only now and then (HS-AI-GUARD-WAIT, cell b0a0's)
        ((hs-ai-guard-wait b s d *hs-ai-r-guard-wait-p*))
        ;; cell b3a0, the waking noose: the awakening rolled for it, once inside *HS-AI-WAKE-WINDOW* frames of it: KUBIKAKE as
        ;; soon as its line holds him and he isn't attacking (the Bankai's 30-55 s in the ranged mode before the first bind)
        ((and (hss-ai-wake st)
              (or (<= (- *match-tick* (hss-ai-wake-t st)) *hs-ai-wake-window*) (setf (hss-ai-wake st) nil))
              (hs-r-hits-at-p :sp2 d) (not (hs-threat-p e s d)) (kit-command-ok-p e :sp2))
         (setf (hss-ai-wake st) nil)
         (fire :sp2 :ai-wake-noose))
        ;; his J / K / L coming up close, its hit 2-14 f off as perceived: the back hop through it (its iframes f3-9; the
        ;; hop's J1 then lashes him from its far end: the generic Step -> J), one roll per action
        ((and (hs-threat-p e s d) (< d 3.5) (member (snap-kind s) '(:quick :flash :sig))
              (<= 2 (- (snap-s s) (snap-sf s) (brain-delay b)) 14) (not (kit-rooted (kit-of e))))
         (and (< (brain-react-roll b) (hs-p b *hs-ai-dodge-p*)) (progn (pace e :ai-dodge) (why b :dodge :step))))
        ;; (a red opponent reeling: the generic Kikon rush until cell b3a1; :kikon-range 0 now, b1a1's: the punish below takes him)
        ;; he recovers / reels: the punish by annulus, one roll per action
        ((and (snap-punishable-p s) (not (member (snap-state s) '(:air :down :wakeup))))
         (or (and (< (brain-react-roll b) (hs-p b *hs-ai-punish-p*))
                  (fire (hs-r-pick style d (- (snap-left-seen s b) 1) (kit-command-ok-p e :sp2)) :ai-punish))
             (and (< d 3.0) :wait)))
        ;; b1a1 via cell b3a1: his parry up close: wait it out (the punish above takes its recovery; the generic Breaker into it
        ;; hit 11 of 43 at HARD, -66 net a press)
        ((and (member :parry (snap-flags s)) (eq (snap-phase s) :main) (< d 4.0)) :wait)
        ;; our blocked string just ended: the generic reset's J1 misses inside 3 m
        ((and (eq (brain-was b) :move) (eq (fighter-contact f) :block))   ; (at range too: no J1 reset into a free guard)
         (or (and (<= 2.1 d 3.0) (ai-pressure-p e) (fire :f :ai-pressure)) :wait))
        ;; he comes in: the style's strike (or the other) as he arrives in its annulus
        ((and run (hss-ai-run-go st))
         (let* ((a (hs-r-sv style :anti)))
           (loop for (c tip) in (list (list :q t) (list :f t) (list a nil) (list (if (eq a :q) :f :q) nil))
                 for at = (hs-reap-at d v (+ (brain-delay b) (mv-s (hs-r-cmd-move c))))
                 when (if tip
                          (and (hs-r-sv style :tip) (eq (hs-r-tip-cmd at) c))
                          (and (hs-r-hits-at-p c (+ at 0.3)) (hs-r-hits-at-p c (- at 0.3))))
                   return (progn (setf (hss-ai-run-go st) nil) (fire c :ai-anti)))))
        ;; close in, he isn't attacking: one roll per entry
        ((and band (not (hss-ai-rolled st)) (not (hs-threat-p e s d)))
         (setf (hss-ai-rolled st) t)
         (let ((r (sim-rnd01)) (pe (hs-p b *hs-ai-escape-p*)))
           (cond ((and (< r pe) (not (kit-rooted (kit-of e))))
                  (ai-dash b -1.0 (hs-r-sv style :keep)) (pace e :ai-escape) (why b :escape :pressed))
                 ((and (< (- r pe) (* (- 1.0 pe) (hs-p b *hs-ai-saharai-p*))) (not run))
                  (fire :sig :ai-saharai)))))))))
(defun hs-r-ai-throw-p (e b d)
  "His CPU's KUBIKAKE off a confirmed J / K hit (B4c: SP2's cancel copy): his own 200 there (HS-BK-OK, KIT-COMMAND-OK-P), the
victim D m off inside its line (HS-R-REACHES-P), one roll *HS-AI-THROW-P*."
  (and (kit-command-ok-p e :sp2) (hs-r-reaches-p (find-move :hs-r-kubikake-c) d) (< (sim-rnd01) (hs-p b *hs-ai-throw-p*))))
(defun hs-r-ai-ender (e kit)
  "His :sp-ender in the ranged mode (a link-3 hit): KUBIKAKE (the bind) when HS-R-AI-THROW-P; else SP1 (9 m line: after the
7.95 m K push too) only above 300 Reiatsu, so the throw's 200 stays (*HS-AI-SP-ENDER-P*)."
  (declare (ignore kit))
  (let ((b (ai-brain e)))
    (when b
      (cond ((hs-r-ai-throw-p e b (fighter-dist (fighter e))) (pace e :ai-throw) :sp2)
            ((and (>= (reiatsu-of e) (+ *hs-kubi-reiatsu* *reiatsu-bar*)) (kit-command-ok-p e :sp1)
                  (< (sim-rnd01) (hs-p b *hs-ai-sp-ender-p*)))
             (pace e :ai-sp1)
             :sp1)))))
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
                   ((and in-f (< (sim-rnd01) (hs-p b (hs-r-sv style :route-dmg)))) (pace e :ai-dmg) (why b :route-dmg :f))
                   (in-q (pace e :ai-fast) (why b :route-fast :q))
                   (in-f (pace e :ai-dmg) (why b :route-dmg :f))
                   (t (setf (hss-ai-end st) mv) (pace e :ai-end) (why b :route-end :wait)))))
          ((eq (hss-ai-end st) mv) :wait))))
(defun hs-grey-margin (e)
  "E's grey loss minus his opponent's in E's bind (positive: E is behind)."
  (let* ((st (hs e)) (o (opp-of e)) (g (gauges e)) (go (gauges o)))
    (- (hs-grey-loss (hss-r0 st) (gauges-reishi g) (hss-k0 st) (gauges-konpaku g))
       (hs-grey-loss (hss-or0 st) (gauges-reishi go) (hss-ok0 st) (gauges-konpaku go)))))
(defun hs-rel-bar (pool)
  "The grey margin (his loss minus the opponent's) over which his CPU releases a bind with POOL left (cell b3a0, the ledger):
*HS-AI-REL-MARGIN* while the pool is high, 0 once it is down to *HS-AI-REL-LOW*."
  (if (> pool *hs-ai-rel-low*) *hs-ai-rel-margin* 0))
(defun hs-b-ai-reflex (e b s d)
  "His :reflex in the bind mode (free): once per change event (either Konpaku changed: a grey Kikon; every *HS-AI-REL-STEP*
of the pool drained) when behind by *HS-AI-REL-MARGIN* one roll *HS-AI-RELEASE-P* for the release: SP2 KAIBAKU-GEKI
(the snapshot back at its S, then 120 real if it reaches), pressed once the opponent is seen not attacking and while still
behind (b1a0); round01 cell b3a0, the ledger: the margin is HS-REL-BAR's (0 once the pool is down to *HS-AI-REL-LOW*), and
KAIBAKU-GEKI only within *HS-AI-KAIBAKU-REACH*, else the plain P (FREE, §25.14) *HS-AI-PLAIN-RELEASE-P* of the time; L KOJO
(the pull and the strike) once per entry into 2.5-4 m, *HS-AI-KOJO-P* (B4c)."
  (let* ((st (hs e)))
    (setf (hss-ai-form st) :bankai-bind)            ; (b1a0: the ranged style re-rolls at the next entry)
    (when (hss-bound st)
      (let ((key (+ (* 10000 (floor (hss-pool st) *hs-ai-rel-step*)) (* 100 (gauges-konpaku (gauges (opp-of e))))
                    (gauges-konpaku (gauges e)))))
        (unless (= key (hss-ai-rel-key st))
          (setf (hss-ai-rel-key st) key
                (hss-ai-rel st) (and (> (hs-grey-margin e) (hs-rel-bar (hss-pool st))) (< (sim-rnd01) (hs-p b *hs-ai-release-p*))))))
      ;; b1a0: KAIBAKU-GEKI releases at its S whatever its strike touches; pressed once he is not attacking (his hit in its
      ;; startup would stop the release), while still behind. Cell b3a0 (the ledger): within its reach only (+120 real on
      ;; his reel), farther the plain P (FREE: at once, no 28 f recovery after a whiff: 128 of 150 KAIBAKU-GEKIs whiffed)
      (when (and (hss-ai-rel st) (not (hs-threat-p e s d)))
        (setf (hss-ai-rel st) nil)
        (when (> (hs-grey-margin e) (hs-rel-bar (hss-pool st)))
          (cond ((and (kit-command-ok-p e :sp2) (< d *hs-ai-kaibaku-reach*))
                 (pace e :ai-kaibaku)
                 (return-from hs-b-ai-reflex (why b :kaibaku-geki :sp2)))
                ((< (sim-rnd01) (hs-p b *hs-ai-plain-release-p*))   ; (the plain P, FREE, §25.14)
                 (pace e :ai-release)
                 (return-from hs-b-ai-reflex (why b :kaibaku :awaken)))))))
    (let ((bite (hs-b-ai-bite e b s))) (when bite (return-from hs-b-ai-reflex bite)))   ; (cell b2a2: the bind's bite)
    (let ((ab (or (hs-r-ai-anti-breaker e b s d) (hs-ai-guard-wait b s d *hs-ai-r-guard-wait-p*)))) (when ab (return-from hs-b-ai-reflex ab)))
    ;; (cell b2a2: no KOJO roll while his KUBIKAKE's reel lasts: D there is the perceived yank still under way, 2.5-4 m)
    (let ((band (and (<= 2.5 d 4.0) (>= (- *match-tick* (hss-bind-from st)) *hs-ai-bite-window*) :kojo)))
      (unless (eq band (hss-ai-band st)) (setf (hss-ai-band st) band (hss-ai-rolled st) nil))
      (when (and band (not (hss-ai-rolled st)) (kit-command-ok-p e :sig))
        (setf (hss-ai-rolled st) t)
        (when (< (sim-rnd01) (hs-p b *hs-ai-kojo-p*))
          (pace e :ai-kojo)
          (return-from hs-b-ai-reflex (why b :kojo :sig)))))
    ;; round01 cell b2a1's walk-in (ported by cell b3a2): a neutral decision due at 1.8 m or more: taken with nothing
    ;; (*HS-AI-B-CLOSE-P*), so he walks in to J1 (the bind's bands have no K1 or Step there)
    (when (and (hss-bound st) (>= d 1.8) (<= (brain-decide-t b) 1) (hs-roll b *hs-ai-b-close-p*))
      (setf (brain-decide-t b) (ai-decide-time e b))
      (pace e :ai-b-close)
      (hs-learn-bind e b d))))                     ; (§25.20: a learner's read of the bind's neutral; else NIL, the walk-in)
(defun hs-b-bite-cmd (d left lock)
  "The bite's command (cell b2a2, pure): the victim D m off (his own yank's), LEFT frames of his reel as perceived, LOCK his
own frames before an attack may start (the guard cancel's, FIGHTER-GC-LEFT): :q J1 when its startup fits the reel after
the lock and D is within the generic follow-up's reach (+ 0.6); :wait while it fits and the yank still brings him in; else
NIL (look again: the reel his KUBIKAKE dealt shows only after its hitstop and the perception delay)."
  (let ((j1 (find-move :hs-b-j1)))
    (when (> left (+ (mv-s j1) (max 0 lock)))
      (if (< d (+ (mv-reach j1) 0.6)) :q :wait))))
(defun hs-b-ai-bite (e b s)
  "Cell b2a2, 縛口 SHIBARI-GUCHI the bind's bite (HS-B-AI-REFLEX, before the rest): in the bind's first *HS-AI-BITE-WINDOW*
frames, the victim perceived in a reel, HS-B-BITE-CMD at his own yank's distance: J1 once it reaches and lands in the reel
(pressed during his guard-cancel lock, it starts as the lock ends), once a bind (*HS-AI-BITE-P*, its roll once); :WAIT while
the yank brings him in (the KOJO band and the generic follow-up read its perceived distance). A command or NIL."
  (let* ((st (hs e)) (from (hss-bind-from st)))
    (when (and (hss-bound st) (/= (hss-ai-bite-from st) from) (< (- *match-tick* from) *hs-ai-bite-window*))
      (case (hs-b-bite-cmd (fighter-dist (fighter e)) (if (eq (snap-state s) :stun) (snap-left-seen s b) 0)
                           (fighter-gc-left (fighter e)))
        (:wait :wait)
        (:q (setf (hss-ai-bite-from st) from)
            (and (hs-roll b *hs-ai-bite-p*) (kit-command-ok-p e :q) (progn (pace e :ai-bite) (why b :bite :q))))))))
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
                (< (sim-rnd01) (hs-p b *hs-ai-b-todome-p*)))
           (pace e :ai-b-todome)
           (why b :b-todome :sp1))
          ((and (kit-next (fighter-kit f) (mv-name mv) :f) (hs-roll b *hs-ai-b-route-p*))
           (pace e :ai-b-route)
           (why b :b-route :f)))))
(defun hs-b-ai-ender (e kit)
  "His :sp-ender in the bind mode (a link-3 hit): only while not behind on grey, SP1 KUSARI-AME's charge-less copy (a bar
of the pool, *HS-AI-BIND-SP-P*); behind, nothing (the pool is his clock too; the release-strike is his reflex's, B4c)."
  (declare (ignore kit))
  (let ((b (ai-brain e)))
    (when (and b (hss-bound (hs e)) (<= (hs-grey-margin e) 0) (kit-command-ok-p e :sp1) (< (sim-rnd01) (hs-p b *hs-ai-bind-sp-p*)))
      (pace e :ai-bsp1)
      :sp1)))

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
(defparameter *hs-learn-diff* '(:easy 0.5 :normal 1.0 :hard 1.5)
  "His learner's read chance (p_exploit) x this by difficulty (§25.20, 2026-10-20: Lille's *BR-LEARN-DIFF*).")
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

(defun hs-learn-reap-plan (read go)
  "Pure: the reap's roll GO (HS-AI-FENCE, once an approach) for the human's predicted answer READ to his K1: a Hoho -> no
reap (it would be Hoho'd: MIKIRI's read by rate, per human); he swings, takes it or backs off -> the reap (it sweeps his
walk); else GO."
  (case read (:hoho nil) ((:attack :take :back) t) (t go)))
(defun hs-learn-ward-plan (read sweep)
  "Pure: the ward's sweep roll SWEEP (:SWEEP or NIL, HS-AI-SIG-HOLD) for the human's predicted answer READ to his windmill:
he comes in, shoots again or backs off -> :SWEEP (L held, the charged K string after the shot); he Hohos or guards -> NIL
(the plain hold); else SWEEP."
  (case read ((:attack :back) :sweep) ((:hoho :guard) nil) (t sweep)))
(defun hs-learn-bind-plan (read)
  "Pure: the bind's neutral (his walk-in, HS-B-AI-REFLEX) for the human's predicted answer READ: he swings or Hohos as
Hisagi comes -> :GUARD (wait it out, the punish after); he guards -> :BREAKER; else NIL (the walk-in)."
  (case read ((:attack :hoho) :guard) (:guard :breaker)))

(defstruct (hsl (:conc-name hsl-))
  "His learner's own state within a match (LRN-KDATA)."
  (own-mv nil) (calm nil) (ox 0f0 :type single-float) (oz 0f0 :type single-float) (ux 0f0 :type single-float)
  (uz 0f0 :type single-float) (len 0 :type fixnum))
(defun hs-learn-l (b) "Brain B's learner when it reads his situations (LRN-KIT: a CPU Hisagi facing a human), else NIL."
  (let ((l (and b (brain-learn b)))) (and l (lrn-kit l) l)))

(defun hs-learn-step (e b s d l)
  "His learner's step (LEARN-DEF-KIT's :step): a situation's onset (HS-LEARN-SIT) and the human's answer to it (LEARN-ACTION
as HS-LEARN-CLASS, with his way away from the onset's line; reeling :TAKE; at the episode's end a held guard :GUARD, else
uncounted)."
  (declare (ignore d))
  (let* ((k (or (lrn-kdata l) (setf (lrn-kdata l) (make-hsl))))
         (st (hs e)) (f (fighter e)) (mv (and (eq (fighter-state f) :move) (fighter-move f)))
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

(defun hs-learn-read (b key)
  "Brain B's learner's read of his situation KEY (LEARN-KIT-READ, x *HS-LEARN-DIFF*), or NIL (no learner with his
situations: every CPU vs CPU match, the ASSIST's brain)."
  (let ((l (hs-learn-l b)))
    (and l (learn-kit-read l key (float (getf *hs-learn-diff* (brain-difficulty b) 1.0) 1.0)))))
(defun hs-learn-acted (e b key read)
  "A read of KEY (the predicted READ) that changed his CPU's pick: counted (LEARN-COUNT-READ), the logs."
  (learn-count-read e (brain-learn b) read)
  (pace e (intern (format nil "READ-~a-~a" key read) :keyword))
  (clog "~a read ~(~a~) ~(~a~)" (side-name e) key read))
(defun hs-learn-reap (e b go)
  "HS-AI-FENCE's reap roll GO for one approach as a learner's read of :REAP leaves it (HS-LEARN-REAP-PLAN); else GO."
  (let ((r (hs-learn-read b :reap)))
    (if r
        (let ((g (hs-learn-reap-plan r go))) (unless (eq (and g t) (and go t)) (hs-learn-acted e b :reap r)) g)
        go)))
(defun hs-learn-ward (e b sweep)
  "HS-AI-SIG-HOLD's ward sweep roll SWEEP as a learner's read of :WARD leaves it (HS-LEARN-WARD-PLAN); else SWEEP."
  (let ((r (and b (hs-learn-read b :ward))))
    (if r
        (let ((w (hs-learn-ward-plan r sweep))) (unless (eq w sweep) (hs-learn-acted e b :ward r)) w)
        sweep)))
(defun hs-learn-bind (e b d)
  "HS-B-AI-REFLEX's walk-in (a neutral decision due in a bind, D m off) as a learner's read of the bind's neutral (ahead /
behind on grey) leaves it (HS-LEARN-BIND-PLAN): :GUARD, the Breaker (within *AI-GUARD-BREAK-RANGE*, allowed), or NIL
(the walk-in)."
  (let* ((key (if (<= (hs-grey-margin e) 0) :bind-ahead :bind-behind))
         (r (hs-learn-read b key)) (c (and r (hs-learn-bind-plan r))))
    (when (and (eq c :breaker) (not (and (< d *ai-guard-break-range*) (kit-command-ok-p e :breaker)))) (setf c nil))
    (when c (hs-learn-acted e b key r) (why b :read-bind c))))

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
    (when (and edge (kit-command-ok-p e :sig) (< (sim-rnd01) (hs-p b *hs-ai-windmill-p*)))
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
4-5 m, HS-R-TIP-CMD; on J1's, 5-6.2 m, his J is it); a bind's bite (HS-B-BITE-CMD: his J held back while the yank still
brings the victim in). A command, :NONE or NIL (the generic AUTO COMBO)."
  (let* ((st (hs e)) (mv (and (eq (fighter-state f) :move) (fighter-move f))) (j (vpad-command-pressed-p vp :quick nil)))
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

