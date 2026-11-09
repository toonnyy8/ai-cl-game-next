# b3_a2 (round 1): resource policy = combo breaker + wake-up bait + stand-off breaker

Job (one line): spend and bank resources against Hisagi: break his combos with the awakening / Burst (once per combo), never feed his
wake-up Hoho, and when no gauge (Reishi / Konpaku, either side) has moved for 120 f while the bell is not Kenpachi's, lift the KI code's
Hoho-safety hold and attack.

## Mechanism
`ken-kh-style` = `kh-break` (b3_a0 via b3_a1) -> `khf-bait-step` (b0_a0) -> `kh-delegate`: `ken-ki-style` with `*kk-ns-safe-p*` bound to 0
(approach roll redone once at onset) while `kh-old-p` holds (b2_a1: 4-gauge change clock > `*kh-stale*` HARD 120 / NORMAL 540 / EASY 900, and
`kh-winning-p` false: Konpaku, then Reishi %). State: `khs` (includes `kks`), clock fields prefixed `so-` (slot clash with kks). No new dice.

## Evidence from history (score.rescored.json, seed0 200)
b3_a1 0.9305 (weakest h11-ids / h7-iki 0.82, hk-t2 0.87); b0_a0 bait 0.8828; b2_a1 stand-off breaker 0.6686 (live 0.39, h11/h7 1.0);
b3_a0 0.45; b1_a0 0.453; b2_a0 0.483. The 0.82 members of b3_a1 are time-out matches (Hisagi driven by Ichigo's code, both idle);
the stand-off clock targets them, and acts in a different event from the bait (quiet neutral vs his knockdown).

## Not a repeat
First combination of all three measured pieces (credited); the delta is the resource clock added to b3_a1. Honest caveat: near-duplicate
of b3_a1 except on h11/h7/h1/h2/h10/h3/h6 (+0.04 to +0.16).

## Measurement (dev seed0 300, scale 1, 950 matches)
0.9564: live 0.9554, iterates 0.9356, arms 0.9783 (b3_a1 same block: 0.9163 / 0.9208 / 0.8861 / 0.942). inc_live 0.255 (not moved).
Members: hk-r1 .96, t1 .99, t2 .89, every arm .96-1.0. Host tests ALL PASS. One eval run, no sweep.

## Risks
Reads both Reishi and Konpaku (HUD numbers). The 120 f threshold is from b2_a1 (within noise of 300). Bait trusts the inferred 2.4 m wake-up
Hoho trigger. Burst leaves one Hoho (hk-t2 .89 weakest).
