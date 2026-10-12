# Cell b0a0 (round 1): "hold L as the plan" — charges from range, links into the stance, turn before the follow-up

Freeze 36e93c7. Only `duel/lisp/barro.lisp` (his CPU parts) and the `BARRO-CPU-TESTS` section of
`tests/duel-rules-test.lisp` changed. Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, score.json):

| | baseline (40 seeds) | **b0a0 (40 seeds)** |
|---|---|---|
| score | 0.0 (raw 0.1702) | **0.8032** (raw 0.8032) |
| strength (HARD, both seats) | 0.003 | **0.652** |
| masher | 0.302 | **0.953** |
| signature | 0.272 | **0.879** |
| NORMAL share (band 0.30–0.60) | 0.05 → factor 0 | **0.5025** → factor 1 (by opp: Y 55/80, K 17/80, R 34/80, I 40/80, S 55/80) |
| pacing medians Y K R I S (cap 220) | 130.7 113.6 122.2 122.4 123.6 | 128.1 134.3 170.4 164.7 169.5 (all 40/40 K.O.) |

sig_by (top): br-e-k 0.231, br-e-kl 0.142, br-rc 0.122, br-oe-k 0.094, charged 0.092, **plain-jk 0.080** (0.459 in the
baseline), br-w-nijushi-c 0.061, br-s-l1- 0.030, br-oe-kl 0.029, br-s-j 0.028, br-k-hiren-c 0.025.

## History read

HISTORY_DIR held no earlier cell (round 1, this is the first branch); the baseline's proposal / score.json / score80.json
were read. Its failure was confirmed in the combat log before designing (HARD vs Kenpachi): the base stance entered from
4 m and fired level-1 snipes (Perfect-Hoho'd, then a full combo), the CPU never held L (no level 2 / 3, `charged` 0.0),
and in KIN / EN it stood in the rooted EN until it lapsed. Lille's dream-rsi lessons (DREAM_RSI §5.5 NORMAL drift, §5.7
reflex starving AI-DECIDE, §5.8 the ASSIST's brain) shaped the rules below.

## The action policy (per form)

**L pressed: how long it is held IS the plan** (`BR-AI-SIG-HOLD`, every form's `:sig-hold`, ai.lisp AI-COMMAND):
- base: nearer than 3.2 m a tap (the stance, for its melee strings); farther L is held into the stance and handed on to the
  snipe's charge at 10 f (the existing BR-KAMAE-TICK rule): 26 f → level 2 (12 m), from 5 m 46 f → level 3 (the 31 m
  萬物貫通 line, +3 pips);
- KIN (`:br-to-en`): nearer than 2.9 m a tap (EN's melee strings); farther held through the turn into the dash's charge
  (BR-GO-RANGED's R13 rule): 26 f level 2 (8 m, 4 hits, +2 wings), from 5.6 m 46 f level 3 (10 m, 6 hits, +3);
- EN's L (the dash itself): always the charge, same levels.
- A charge lets go early (`BR-AI-CHARGE-TICK`, the CPU branch of BR-S-TICK's `:hold` phase) when his attack is perceived
  in reach (+0.8 m) or he runs in within 2.5 m: the shot / dash at the level reached. No roll: a reaction.

**Base form** (`:base`): neutral J pokes (the band no longer presses L near him: a stance from neutral is Hoho'd by HARD
CPUs — any opener with ≥ 6 f of startup left after the 8 f delay is), it keeps the snipe's range (intents zone 4, zone
6–10 m, dash-back 0.6, neutral guard 0.1). One roll a 30 f window: the level-3 snipe from 5–14 m when his attack isn't on
him and he isn't running in. One roll per action of his (`BR-AI-EVENT-ROLL`): the stance as a punish (his perceived
recovery ≥ the stance's up + J1's startup, inside K1's reach). L after a J / K link (`:l-after-j` 0.8) → the stance at f4.
In the stance one pick (`BR-AI-STANCE-PLAN`, pure): the HIRENKYAKU Step off his attack; out of melee reach the charged
snipe (L held for its level, `BR-AI-CHARGE`); K when he can't answer K1's startup (perceived open frames ≥ 16); J when he
can't answer J1's; under his attack J; else K `:k` of the time. Off a link it takes J (the gun-kata combos off J1; K1's
16 f startup does not — measured: Perfect Hoho after J1 → L → K1).

**Stance calls** (`BR-AI-CALL`, pure; BR-S-CPU-CALL): SP2 at ≥ `:sp2-at` specials (the J route's own `:sp2-j`: the
base's J3 → HIRENKYAKU at ≥ 1 pip, 40 a pip, instead of JL's 15 a line), else the L L follow-up with a special
(`:follow`), and at a string's very end (KL3 / JL3 / the owl's K3, no follow-up left) SP2 with what is left
(`:sp2-empty`). So: K string → KL1-3 spending wings (70 a line) → SP2; J string → SP2 cashing the pips.

**JILLIEL KIN / the owl KIN**: they keep the dash's range (zone 4.5–7.5 m, intents zone 4 / 3, dash-back 0.6; KIN lost
every close J exchange, e.g. Kenpachi's FIRST-STRIKE). One roll a window: the charged dash from 3–8.6 m (`:zone :p` 0.6).
L after a J link (`:l-after-j` 0.9; K 0.7, the owl's K 0.3 so its K3 → volley SP2 keeps priority): the turn, whose CPU
branch now **skips into the stance's K1 / J1 at once** (R17's link by its own means, `BR-AI-LINK-CMD`, in
BR-TO-EN-LINK-TICK; the human path is unchanged): K1 when in its reach (`:link-k` of the time), else J1. This is the
route that carries most of the signature: J1 → (turn skipped) EN K1 K2 K3 → KL1 KL2 KL3 → NIJUSHI-KO.
**The turn before the follow-up** (`*BR-AI-TURN-P*` by difficulty, one roll per his action): after the dash through him
he reels *behind* Lille; the generic follow-up J1 whiffed at once (22 punished whiffs in 8 BK matches). The reflex now
waits (`:wait`) until he is within 1 rad of the facing; the J1 then lands and links into the stance — this single change
took HARD strength from 0.23 to 0.52 at 10 seeds.

**EN / the owl EN** (rooted, 30 f): `BR-AI-EN`, one decision every 10 f (each its roll): the fast Step off his attack,
the charged dash out of melee reach (≤ 8.6 m; farther nothing — EN lapses into KIN, which walks), K / J in reach by the
same stance plan. The burst into the owl is unchanged (`BR-AI-BURST-P`, `:burst`).

**Difficulty**: every chance through `BR-AI-CHANCE` (`:step`, `:k` too now); `*br-ai-diff*` 0.5 / 1.0 / 1.5 →
**0.25 / 0.5 / 1.5** (EASY ≤ NORMAL ≤ HARD): NORMAL measured 0.69 at 1.0, 0.54 at 0.6, 0.405 at 0.45, 0.50 at 0.5
(40 seeds). The turn-wait is 0.2 / 0.4 / 1.0. Rolls per event / window / stance, never per step; the CPU reads only its
perceived SNAP and its own state; SIM-RND01 only.

**Kept working**: AI-AWAKEN-P (`:awaken`), the burst (`BR-AI-BURST-P` and `:burst` untouched), every debug / test
command, the `duel barro` pace counters (new: ai-charge, ai-let-go, ai-link-k / -j, ai-punish), the learner (BR-LEARN-KAMAE
still reads the plan's K; the reflex acts on events / windows and returns NIL otherwise; the EN decisions only in the 30 f
EN), the ASSIST (`:sig-hold` reads no brain; BR-ASSIST-COMBO untouched). `BR-TICK-BRAIN` gates every new tick branch.
New CPU state: three BRS slots (`ai-key`, `ai-roll`, `ai-en`).

## Evidence (HARD strength, Lille II both seats vs the five, strdiag = aieval's matches(); 10 seeds = 100 matches)

| step | change | HARD wins |
|---|---|---|
| v1 | the policy above minus the items below | 24/100 (aieval 10 s: 0.533, NORMAL 0.41) |
| B | no stance from neutral (Hoho bait), base link → J, J route → SP2 | 22/100 |
| – | anti-breaker J1 from 2.4 m + neutral guard 0.1 | 23/100; the J1 opened 36 combos on him → J1 removed |
| C | KIN keeps the dash's range | 23/100 |
| D | **turn before the follow-up** | **52/100** (aieval: raw 0.684 but NORMAL 0.69 → ×0.4) |
| F, G | KIN / base dash-back, base zone intents | 63, 66/100; G at 40 seeds 0.7714 (str 0.66, NORMAL 0.57) |
| H | snipe always level 3, never into his run-in | 129/200 = G's 129/200 (kept: the 萬物貫通 line) |
| I | Kikon range 3.5 (the neutral Kikon missed 128 of 212 tries) | 125/200 (reverted) |
| J | L after J links 0.8 / 0.9 | 131/200, plain-jk 0.158 → 0.080 |
| J2 | + NORMAL ×0.5 | 40 seeds 0.7869 (str 0.625, sig 0.876, NORMAL 0.4475) |
| – | snipe from 7.5 m + on a downed foe; dash level-3 always / level-2 more | 128, 120, 131 /200 (reverted) |
| – | burst at 3 wings, p 0.7 | 134/200 (reverted: keeps the burst / the A/B untouched) |
| M, N | JILLIEL EN `:k` / `:link-k` up; `:step` / `:k` difficulty-scaled | 140/200; **N at 40 seeds 0.8032** |

Per-form diagnosis (8 matches vs each, HARD, before D): KIN 53 s a match dealing ~400 and taking 1100–2200, EN
dealing 900–1850 and taking < 100: the damage is in the stance strings, KIN's neutral is the weak spot. Kenpachi stays
the hard pairing (FIRST-STRIKE J1 on anything idle within 4 m: 76–84 of his openings; HARD ~11/40).

## Why not a repeat

First cell of the search (no history). Structurally new against the baseline: the L hold length as the decision (the
baseline never charged), the CPU's own R17 link, the facing wait after the dash, event-keyed reflexes (no per-window stance
entry at 4 m).

## Awaken A/B (informational: AI-AWAKEN-P and the burst are untouched)

Pairings 21–25 (Lille II P1 never awakening, NORMAL), `--cmd 39020`, 60 seeds, the never-awaken side's wins Y K R I S:
seed0 100: 4 1 1 0 1; 300: 2 2 1 0 1; 500: 4 0 0 0 0 (all K.O.). Baseline seed0 100: 2 9 0 1 1. Both far below 20: his
base form cannot win without the awakening (it was so in the baseline, which never got the band's 20 either). Not a
regression of this cell; listed for the integration gate.

## Risks

- Pacing medians are 128–170 s, ≥ 50 s under the 220 cap (no risk); Rukia / Senjumaru lengthened vs the baseline
  (122 → 170 s): his matches go the distance now.
- NORMAL 0.5025 sits mid-band, but NORMAL is sensitive (0.45 multiplier → 0.405, 0.6 → 0.54); later cells raising
  chances should re-check it.
- The awaken A/B rows (above) fail as in the baseline.
- ASSIST: a human's AUTO route that presses L now gets the CPU's hold by distance (a tap near him, the charge from range).
- Kenpachi pairing stays weak at HARD (~0.25–0.3).

## Shared-code recommendations

- ai.lisp's generic step-in (`*AI-STEP-IN-P*`) and neutral Kikon (`:kikon-range`) are punished often for him (base step-in
  opened ~29 combos in 30 matches; the neutral Kikon reached a Konpaku in 35 of 212 tries); a kit key to scale them would
  help kits with short J reach.
- `AI-COMMAND`'s `:sig-hold` is the only lever for a held L; a kit hook to release a held charge (like BR-AI-CHARGE-TICK)
  would let other charge kits do the same without a tick branch.
