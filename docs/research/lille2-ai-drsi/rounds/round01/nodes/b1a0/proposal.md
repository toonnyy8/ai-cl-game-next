# b1a0 (round 1): the route CPU — every confirmed hit a stance string, the specials from the charged L

Cell b1a0 opens a direction from the baseline (no parent). Measured with the frozen evaluator at 40 seeds
(`python3 tools/aieval.py --char 6 --seeds 40 -j 2`), final file = `barro.lisp` here (v7 below):

| | score | strength | masher | signature | NORMAL share (factor) | raw |
|---|---|---|---|---|---|---|
| baseline | 0.0 | 0.003 | 0.302 | 0.272 | 0.05 (0) | 0.1702 |
| **b1a0 (v7, delivered)** | **0.6985** | **0.517** | **0.802** | **0.828** | **0.5125 (1.0)** | 0.6985 |

The delivered file was re-measured last (after the A/B runs and a rebuild): the same JSON to the digit (`score.json`).
Host test `tests/duel-rules-test.lisp` 8290 checks ALL PASS (BARRO-CPU-TESTS section rewritten: the new plan functions,
levels, knobs and keys pinned); `tools/pkgcheck.sh duel` 0 / 0 / 0.

Pacing (NORMAL P1, all 200 K.O.): YAMAMOTO 121.2, KENPACHI 123.7, RUKIA 149.1, ICHIGO 143.9, SENJUMARU 152.1 s (cap
220; nothing within 15 s of it). NORMAL by opponent (both seats): ICHIGO 38/80, KENPACHI 20/80, RUKIA 38/80, SENJUMARU
47/80, YAMAMOTO 62/80. sig_by: br-e-k 0.215, br-e-kl 0.133, plain-jk 0.100, br-s-k 0.082, br-oe-k 0.073, br-oe-kl 0.071,
charged 0.064, br-w-nijushi-c 0.051, br-s-l1- 0.044, br-s-kl 0.042, br-rc 0.022, the rest (counter, Breakers, Kikons,
gun-kata, HIRENKYAKU ...) under 0.02 each.

## History read

Round 1 has no earlier cell (b0a0 runs in parallel, unreported); the only history is the baseline (`baseline/proposal.md`,
`score.json`: score 0, HARD 0.003, NORMAL 0.05). The old Lille's run (`docs/research/lille-ai-drsi/`) is a different kit.
Diagnosis of the baseline with the combat log (2 + 4 HARD matches, BK / BS, `tools/simgate/run-log.lisp` as aieval runs it):

- base form: 54 stance entries and 38 level-1 snipes in 4 matches, 7 attack-state J1s: the `:zone` reflex enters the
  stance inside 4 m for strings that reach 1.9–2.6 m, the plan then turns to L, and the snipe is always a tap (the CPU
  never holds L: BR-KAMAE-GO starts the held move with button :sig, the brain never presses it) → level 1, 4 m, whiffs;
- awakened: the EN bands walk / wait in a rooted 30 f stance; the dash is never charged;
- dealt 1323 vs 4642 in 4 BS matches.

## The action policy (行動方針) per form

The structural idea: **routes chosen once at their event**, not a neutral that walks into the stance. The stance is never
a place to wait; the specials have one source (the charged L) and one sink (the K route's L L / SP2).

- **confirm (every form)**: an attack-state J / K link that hit → L (`:l-after-k` / `:l-after-j`) → the stance's string at
  once. Base: a J link opens the gun-kata (stance J, S 10: combos off J's 18 f flinch), a K link the rifle (stance K, S 16:
  combos off the stagger) — BR-AI-STANCE-PLAN `:combo` / `:from-k`; the base `:string-k` 0.8 turns J1 into the K2s link so
  most confirms reach the K route. Awakened: **the R17 link for his CPU** (BR-AI-LINK-CMD, called from the CPU branch of
  BR-TO-EN-LINK-TICK): the turn skipped, EN K1 (cut to 14 f, combos) in its reach, J1 in J's, else the charged dash.
- **punish → a stance string**: free, him recovering / reeling with the frames for the stance's opener (base 6 + J1 S 10,
  awakened turn 12 + J1 S 8) in J's reach: L instead of a plain J1 (BR-AI-STANCE-PUNISH, `:punish`, one roll per action on
  his react roll); the stance pick then reads the frames left (J; K when K1 fits).
- **string links** (BR-S-CPU-CALL): the spending L L follow-up while a special is left — the K route always, the J route's
  L L only for its refill (flash step under `:recover-fs`, under 2 bars, or the specials full); at a string's end with no
  follow-up to pay (or at the follow-up's own last line) the charge-less SP2 with 2 bars.
- **charge (the resource engine)**: the base snipe held to level 2 / 3 by the distance (`:far` 7 m → level 3: the 31 m line
  through guard, +3 pips even on a block; else level 2) — BR-AI-KAMAE presses and holds L (`*BR-AI-HOLD*` 1 / 24 / 44 f)
  for the hold phase BR-KAMAE-GO started; the awakened dash held by the distance (≤ 6.4 m level 2, ≤ 10.2 m level 3) through
  the kit's `:sig-hold` (BR-AI-SIG-HOLD: KIN's L held is the dash's charge at the turn's end, R13; EN's L the dash). `:charge`
  of the time (x difficulty), else a tap. Far windows (one roll per `*BR-AI-EVERY*`): the base `:far-snipe` from 4.5 m,
  KIN's `:far-dash` from 3.4 m.
- **EN (rooted)**: one plan per standing window (epoch = the tick its 30 f clock started; BR-AI-EN / BR-AI-EN-PLAN): K in
  its reach (J `:j-share`), the charged dash where it reaches, else the fast Step in (then a new window); his attack coming:
  NIL (the generic guard).
- **base stance pick** (BR-AI-STANCE-PLAN, by the perceived distance): J / K in their reach (K for the damage, J
  `:j-share` or when the flash step / bars need the refill), else the snipe; his attack coming (not in a combo) the stance
  Step 飛廉脚 (iframes) and a fresh pick 5 m out (often the snipe).
- **Breakers**: his J1 (1.45 m) met the generic anti-Breaker J1 too late (75 of 106 Breaker hits on the base form landed 4–5
  f into it). BR-AI-ANTI-BREAKER: Ken's reach model (where the dash will be when our K1 / J1 is active, the strike after the
  1.6 m trigger + 8 f; K1, J1, a Hoho near the strike, else :WAIT), per Breaker on the react roll, `*BR-AI-ANTI-BREAKER*`
  EASY 0.1 / NORMAL 0.3 / HARD 1.0.
- **the owl**: the burst at 2 wings within 8 m (`:burst (:p 0.6 :wings 2 :in 8.0)`, was 5 / 6 m / 0.5): the owl's form had
  the best damage ratio (dealt / taken 1.85 raw, x1.2 dealt; base 0.95, JILLIEL 1.13 over 100 HARD matches).
- **base neutral**: zone-leaning intents (approach 2, pressure 2, zone 3), J pokes close, L (the stance) mid, the snipe far.
- difficulty: every chance x `*BR-AI-DIFF*` EASY 0.25 / NORMAL 0.5 / HARD 1.5 (NORMAL was 1.0: at 1.0 NORMAL's share was
  0.6275 → factor 0.82); every roll once per event / window / string / press; randomness only SIM-RND01 or the brain's
  event rolls; the opponent through the perceived SNAP (BR-AI-SEEN, BR-AI-SEEN-D).

Kept working: AI-AWAKEN-P / `:awaken` unchanged; BR-LEARN-* (BR-AI-KAMAE still routes its plan through BR-LEARN-KAMAE);
the ASSIST (`:sig-hold` reads the brain through AI-BRAIN; BR-TICK-BRAIN branches act for his CPU only; the human branch of
BR-TO-EN-LINK-TICK is unchanged); debug modes untouched.

## The steps measured (40 seeds each, the frozen evaluator)

| step | change | score | str | mash | sig | NORMAL |
|---|---|---|---|---|---|---|
| v1 | routes, held L (snipe / dash), EN window plan, CPU R17 link, BR-S-CPU-CALL | 0.5266 | 0.217 | 0.672 | 0.763 | 0.47 |
| v2 | + anti-Breaker model (0.6 x diff), J route L L only for the refill, base K route (`:string-k` 0.8, `:l-after-k` 0.8, `:l-after-j` 0.3), zone intents, far snipe 0.5 / 4.5 m | 0.5225 (raw 0.640) | 0.450 | 0.750 | 0.774 | 0.6275 (x0.82) |
| v4 | + anti-Breaker by difficulty table, `*BR-AI-DIFF*` NORMAL 1.0 → 0.5 | 0.6506 | 0.477 | 0.750 | 0.774 | 0.4375 |
| v6 | + the owl early (2 wings, 8 m, p 0.6), the stance punish | 0.6700 | 0.507 | 0.760 | 0.787 | 0.535 |
| **v7** | + KIN / the owl KIN `:l-after-*` 0.85, base `:l-after-k` 0.9 | **0.6985** | 0.517 | 0.802 | 0.828 | 0.5125 |
| v8 | KIN / owl `:l-after-*` 1.0, base `:l-after-j` 0.5 (not delivered) | 0.6964 | 0.515 | 0.766 | 0.843 | 0.4825 |

Why not a repeat: there is no earlier cell; against the baseline the mechanism is new (routes on events, the held L by
the brain, the EN window plan, the CPU's R17 link, the anti-Breaker model, the difficulty split), not a retune of its
`:zone` / `:gather` tables (both are gone).

## Awaken A/B (the burst rule changed: `:burst` 5 → 2 wings)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II) wins of 60, all K.O.:

| seed0 | BY | BK | BR | BI | BS |
|---|---|---|---|---|---|
| 100 | 14 | 8 | 4 | 2 | 1 |
| 300 | 15 | 5 | 2 | 4 | 6 |
| 500 | 10 | 7 | 5 | 2 | 6 |
| baseline 100 | 2 | 9 | 0 | 1 | 1 |
| baseline 300 | 2 | 7 | 0 | 0 | 1 |
| baseline 500 | 6 | 3 | 0 | 0 | 1 |

(Baseline measured in this worktree with the baseline `barro.lisp` swapped in and rebuilt, then restored.) The burst only
acts in a JILLIEL form, so the never-awaken side never uses it: these rows measure his NORMAL base form alone (x0.5
chances) against awakening opponents. Both fail ≥ 20 on every stream (the baseline's worse: 0–9, mine 1–15; BK 8 / 5 / 7
vs 9 / 7 / 3 the one row not better); the base form at NORMAL is the weakest of his forms (its J1 reaches 1.45 m).

## Expected benefit, risks

- Benefit: HARD strength 0.003 → 0.517 with 0.83 of his damage on the whitelist; NORMAL inside the band's middle.
- Risks: NORMAL 0.51 sits 0.09 under the band's top (v6 had 0.535): a later change that strengthens NORMAL can leave the
  band; KENPACHI stays his worst matchup (NORMAL 20/80; HARD the lowest); the generic `:l-after-*` keys are raw (not
  difficulty-scaled: ai.lisp's STRING-REFLEX reads them as they are), equal at every difficulty; the awaken A/B rows above
  fail (the base form alone at NORMAL). No pacing median within 15 s of its cap (max 152.1 s).
- The CPU's R17 link adds a CPU branch to BR-TO-EN-LINK-TICK (the brief: "your CPU may use the same link by its own
  means"); the human branch is byte-for-byte the old one.

## Shared-code recommendations (not done)

- ai.lisp STRING-REFLEX: scale `:l-after-k` / `:l-after-j` by the difficulty (a kit factor), so a kit can keep a strong
  HARD confirm without a raw NORMAL one.
- ai.lisp's generic anti-Breaker J1 (`*AI-ANTI-BREAKER-J*` 1.4 on the perceived distance) is late for short J1s (Lille II's
  1.45 m); Ken's and now Lille II's reach models could become the generic one.
