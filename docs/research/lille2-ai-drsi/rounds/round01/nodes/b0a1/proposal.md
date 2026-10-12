# Cell b0a1 (round 1, refines b0a0): "the reach and the reserve" — b2a0's opponent model and b3a0's wing reserve together, plus the wake-up shot

Freeze 36e93c7. Only `duel/lisp/barro.lisp` (his CPU parts) and the `BARRO-CPU-TESTS` section of
`tests/duel-rules-test.lisp` changed (host test 8314 checks ALL PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0). Final measure
(`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, score.json; the delivered file differs from the measured v3 only in
comments, and was re-measured last: the same JSON to the digit):

| | baseline | b0a0 (parent) | b2a0 | b3a0 (best so far) | **b0a1 (40 seeds)** |
|---|---|---|---|---|---|
| score | 0.0 (raw 0.1702) | 0.8032 | 0.915 | 0.9192 | **0.952** (raw 0.952) |
| strength (HARD, both seats) | 0.003 | 0.652 | 0.882 | 0.943 | **0.963** |
| masher | 0.302 | 0.953 | 1.0 | 1.0 | **1.0** |
| signature | 0.272 | 0.879 | 0.905 | 0.856 | **0.918** |
| NORMAL share (band 0.30-0.60) | 0.05 (x0) | 0.5025 | 0.53 | 0.52 | **0.525** (x1; I 46, K 23, R 40, S 54, Y 47 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 131 114 122 122 124 | 128 134 170 165 170 | 143 146 188 172 177 | 123 121 170 151 168 | **150.4 147.8 171.7 183.8 174.1** |

sig_by (top): br-e-k 0.262, br-rc 0.148, br-oe-k 0.125, charged 0.083, **plain-jk 0.073** (b2a0 0.082, b3a0 0.094),
br-e-kl 0.068, br-w-nijushi-c 0.055, br-s-l1- 0.051, br-k-hiren-c 0.043, br-oe-kl 0.032, br-s-j 0.029; outside the
whitelist besides plain-jk only counter 0.006 and Breakers / cuts ≤ 0.001 each.

## History read

- **baseline** (0): broken by R12-R17 (stance entered at 4 m, never charges, waits in the rooted EN).
- **b0a0** (my parent, 0.8032 rescored): L's hold length as the plan, the CPU's R17 link, the stance calls, EN decisions
  every 10 f, the turn before the follow-up after the dash through him (its biggest step). Weak spots: KIN's neutral,
  Kenpachi, the neutral Kikon, being first-struck while idle.
- **b1a0** (0.6985): routes on events, the anti-Breaker reach model, the owl earlier. Lower only for lacking b0a0's turn.
- **b2a0** (0.915, a refinement of b0a0's file): the opponent's first-strike envelope (the kite / the ward), the Kikon only
  on openings (`:kikon-range` 0), the long-guard answer, the snipe's level-1 let-go bug fixed, the dash released on his
  commitment, `*BR-AI-DIFF*` NORMAL 0.3. Strength 0.88, signature 0.905.
- **b3a0** (0.9192, from the baseline): the clock (charges timed on his perceived commitment) and **the wings as armour
  first** (the reserve `:keep` = the armour's price; the armoured J1 into his approach; the burst at 4 wings / 7 m rolled in
  EN too) — its reserve step alone took HARD from 77 to 95 of 100. Its v6 / v7 showed `:l-after-j` 1.0 trading signature
  +0.02 for strength -0.03 there.
- No failure in the history was a located bug left open; the two strongest cells improved different, orthogonal layers:
  b2a0 the neutral (where Lille gets opened), b3a0 the resource economy (what the wings are for). **They had never been
  combined.** b2a0 is b0a0's file plus its pieces, so this cell takes b0a0 + b2a0's pieces (credited) as the base, adds
  b3a0's reserve mechanism (re-implemented in b0a0's BR-AI-CALL / BR-AI-EN / BR-AI-REFLEX, not b3a0's clock), then a new
  mechanism of its own (the wake-up shot) and one parameter step justified by the new strength headroom.

## The action policy (per form; b0a0's routes and b2a0's reach model kept, see their proposals)

- **The wings' reserve** (`BR-AI-CALL`, every awakened form's `:stance`): never an L L follow-up line at or below `:keep`
  wings (= `BR-ARMOR-COST`: JILLIEL 4, the owl 2); SP2 (it spends every wing) only short of the reserve or at `:sp2-all`
  (JILLIEL 8: NIJUSHI-KO 60 + 8 x 25; the owl 5: the volley's 300 tier); the owl's full volley at once at `:volley-at` 8
  (480). Lines above the reserve stay the K route's 70-a-wing spend. The base form keeps `:keep` 0 (no armour there).
- **Armour as initiative**: with the reserve held (`BR-AI-ARMOUR-P`), KIN / the owl KIN meet his approach with J1 (`:zone
  :armour` 0.6 / 0.8 x difficulty, J1's reach + 0.5 / 0.6 m, one roll per action of his) — ordered after b2a0's
  anti-Breaker / Kikon / unguard / turn / punish and *before* b2a0's ward, so the armoured form trades and the unarmoured
  one kites; in EN his attack is no threat to the stance pick when armoured (K / J into it, no masher J-override).
- **The owl at the reserve**: `:burst (:p 0.6 :wings 4 :in 7.0)` in both JILLIEL forms (b2a0 had 3 / 8 m), the burst
  window rolled in EN too (one roll a 30 f window).
- **The wake-up shot** (`BR-AI-OKI`, new): him perceived down (`:down` + `:wakeup`, both invulnerable 30 f), the charged L
  started so its hit lands on his first open frame: held `left - after + 1` frames (`BR-AI-OKI-HOLD`, pure: level 2 from
  26 f, level 3 from 46, under the 60 f cap; else not yet / too late) — the base snipe within its level-2 line, awakened
  the dash through him (KIN's L held through the turn, EN's L; within 6 / 8 m for level 2 / 3). One roll per perceived
  state of his (`BR-AI-EVENT-ROLL`), `*BR-AI-OKI-P*` 0.1 / 0.25 / 1.0. The kit's 「蓄力招」 as his okizeme.
- **L after every J link** (`:l-after-j` 1.0 in the base, KIN and the owl KIN; `:l-after-k` unchanged 0.6 / 0.7 / 0.3):
  every attack-state J that hits goes into the stance (the base at f4, the awakened R17 link): fewer plain J2 / J3.
- Unchanged from b2a0: `*BR-AI-DIFF*` 0.15 / 0.3 / 1.5 and every b2a0 / b0a0 table.

Difficulty: every new chance EASY <= NORMAL <= HARD (`BR-AI-CHANCE` or a difficulty table); rolls once per event / window /
string link; randomness only SIM-RND01 / the brain's event rolls; the opponent through the perceived SNAP. The reserve is a
rule (all difficulties), as in b3a0.

Kept working: AI-AWAKEN-P / `:awaken` untouched; the learner (BR-LEARN-* untouched; the new reflex branches act on events
/ windows and return NIL otherwise); the ASSIST (`:sig-hold` unchanged, no new hook reads `(brain e)` — the new code is in
BR-AI-REFLEX / BR-AI-EN / BR-AI-CALL, the CPU's own paths); debug commands and the `duel barro` counters (new: ai-armour,
ai-oki; ai-burst now in EN too). No new BRS slot.

## The steps measured (40 seeds, the frozen evaluator)

| step | change | score | str | mash | sig | NORMAL |
|---|---|---|---|---|---|---|
| b2a0 | (rescored, the base) | 0.915 | 0.882 | 1.0 | 0.905 | 0.53 |
| v1 | + the reserve, the armoured J1, the armour in EN, the burst 4 / 7 m in EN too | 0.9402 | 0.955 | 1.0 | 0.895 | 0.5125 |
| v2 | + the wake-up shot | 0.9463 | 0.970 | 1.0 | 0.896 | 0.51 |
| **v3** | **+ `:l-after-j` 1.0 (base, KIN, the owl KIN)** — delivered | **0.952** | 0.963 | 1.0 | 0.918 | 0.525 |
| v4 | + `:l-after-k` 1.0 (base, KIN) — not delivered | 0.9533 | 0.965 | 1.0 | 0.918 | 0.565 |

v4's +0.001 is noise (plain-jk unchanged: K links that hit are rare) and it lifts NORMAL to 0.565, near the band's top:
not taken. HARD diagnosis of v2 (8 seeds x 5 opponents x 2 seats, combat log): 78 / 80 wins (K 15/16, Y 15/16, the rest
16/16); dealt by form EN 136 k, the owl EN 64 k, the volley 61 k, the base stance 59 k, KIN 40 k, base 40 k, the owl KIN
12 k; per 80 matches 193 armoured J1s, 202 bursts, 182 volleys (110 at tier 3, 63 at tier 4), 53 wake-up shots, 701
level-3 / 152 level-2 snipes. v3's `:l-after-j` 1.0: plain-jk 0.092 -> 0.073, signature +0.022, strength -0.007 (within
noise) — the trade b3a0 measured as net negative is net positive here because the reserve and the reach model left
strength headroom.

## Why it is not a repeat

The two mechanisms that carried the round (b2a0's model of the opponent's reach, b3a0's wings-as-armour economy) are
orthogonal and had never been combined; the combination alone gave +0.025 over the best cell. The wake-up shot is a new
mechanism (no earlier cell timed a charge to the knockdown's end; b3a0's "meaty" hold only extended a charge already
running and never fired). The `:l-after-j` step is a parameter, taken only because the measured trade changed sign.

## Awaken A/B (the burst changed; the base form's links and wake-up shot too)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2`, the never-awaken side's (P1 Lille
II, NORMAL) wins of 60, Y K R I S:

| seed0 | b0a1 | baseline (b1a0's measure) | b2a0 | b3a0 |
|---|---|---|---|---|
| 100 | 5 0 0 1 1 | 2 9 0 1 1 | 5 2 0 1 3 | 7 0 0 1 1 |
| 300 | 5 0 0 4 1 | 2 7 0 0 1 | 6 0 2 4 0 | 6 1 0 2 0 |
| 500 | 6 2 2 4 0 (BS 59/60 K.O.: one 300 s time-out) | 6 3 0 0 1 | 7 0 1 2 2 | 2 1 0 0 2 |

All far under the 20 pass mark, as for the baseline and every earlier cell (the burst never acts in the base form; these
rows measure his NORMAL base form alone against awakening opponents). The one time-out is in the forced never-awaken
mode, not in the evaluator's pacing (all 200 K.O.). For the integration gate.

## Expected benefit, risks

- Benefit: HARD 0.963, masher 1.0, signature 0.918 (the highest so far), NORMAL mid-band.
- Pacing: medians 147.8-183.8 s, ≥ 36 s under the 220 cap (v1 had RUKIA 197.2; later variants 171-181). No median within
  15 s of the cap; the RUKIA / ICHIGO pairings move ±15 s between variants.
- NORMAL 0.525 (KENPACHI 23/80 its low row). The reserve is a rule at every difficulty and the generic `:l-after-*` keys
  are not difficulty-scaled: a later change strengthening the awakened forms or the confirms raises NORMAL with HARD (v4:
  0.565).
- The wake-up shot fires rarely (53 in 80 HARD matches): its strength share is small and inside noise at 40 seeds (v2 vs
  v1 +0.015 str); it is kept for its character (the 「蓄力招」 on a knockdown) and costs nothing measured.
- The armoured J1 makes KIN press into an approaching opponent when the reserve is held; against a human who reads it
  (a Breaker / Kikon / throw ignores the armour) it is a habit to exploit; the learner does not read it yet.
- The awaken A/B rows fail (as everywhere in the history).

## Shared-code recommendations (not done)

- ai.lisp STRING-REFLEX: scale `:l-after-k` / `:l-after-j` by the difficulty (a kit factor): HARD could keep 1.0 for the
  signature while NORMAL keeps its fair share (b0a0, b1a0, b3a0 asked the same).
- A generic okizeme hook (`:oki` takes only `:sp1-full` today): a kit function returning a timed hold would let any charge
  kit meet the wake-up as BR-AI-OKI does.
- b2a0's recommendations stand (a guard-break kit key instead of writing `brain-break-key`; the neutral Kikon "only on an
  opening" as a kit key; a hook in the hold-guard re-press).
