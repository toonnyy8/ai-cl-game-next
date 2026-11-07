# b3_a0 (round 3, 破月牙 hint): never start a move she can see in time while her Hoho is ready. J1 or a Step in instead of NS1a, the meaty out of her wake-up Hoho's reach, J1 onto her Hoho's end

Direction hint: 破月牙 (antiwave), keeping the other three themes usable. There is no parent; the start is BASELINE_DIR, round 2's
b0_a0, re-measured against her round-2 champion b1_a1 at 0.2872 (HARD 3/80). Only `duel/lisp/cpu-ki-ken.lisp` changed. Every new knob
is a `defparameter` with a docstring.

**Disclosed up front: every mechanism here sits on the brawl side, not the wave.** Antiwave was 0/0 in all my runs (20 and 40 seeds,
every variant), so the theme leaves the mean. Her champion waits at pointer 2 against his released forms and shoots only from a perceived
7.5 m or more, so she never starts the route at 3.6–6.6 m. The diagnosis below found her Hoho behind 377 of her 416 combos. I made no
rule aimed at opening the wave situation.

## History read
- **Round 1 (8 cells) and round 2 (7 cells).** I read every score.rescored.json. For the cells my work touches I read the
  summary / mechanism sections:
  - the four 破月牙 cells: r1 b3_a0 / b3_a1, r2 b3_a0 / b3_a1 (mechanisms; measurements by heading);
  - r2 b0_a0 (the baseline, whole);
  - r2 b0_a1 ("patience through her Hoho").
  The rest I read by headline and score. The lineage is in DUEL_MATCHUP_AI §9–§10.
- **Baseline against her new champion: 0.2872.**
  - HARD 3/80.
  - Themes: brawl 0.272, shikai 0.337, bankai 0.706, antiwave 1/2.
  - Round 2's 0.92 was measured against her previous champion. Her new one adds the timed perfect Hoho, the wake-up Hoho, the meaty J1
    loop and the pointer-2 wait.
- **r2 b0_a1** (wait while she is seen mid-Hoho; tried "J1 always first where both reach") is the nearest prior.
  - Its J1-first row came from 8 perfect Hohos on 124 NS1a openers against her old champion. That champion had no timed Hoho, so it was
    no big leak then.
  - My gate is different. It keys on whether *she* can see the move start in time: her perception against the move's startup, her own
    move or stun, and her Hoho lockout. The Shikai lunge and the S9 Shikai J1 fall under it as well. When J1 is out of reach, he Steps in
    instead of walking.
  - I also checked his moves after her non-perfect Hohos (v3 logs). They mostly landed, so I did not repeat b0_a1's wait.
- **The 破月牙 cells' pieces** (the far Hoho, the Step-held fix, the arrival gates of r2 b3_a0 / b3_a1) are not in the baseline. I did
  not merge them: the route never opened against this opponent, so a merge could not be measured.
- **Round 3 siblings:** all three directories were still empty when I finished.

## Diagnosis (baseline file, her champion, HARD, 20 seeds a seat; scratch parsers over the frozen evaluator's job logs)
- Her combos on him come to 271k Reishi; 232k of it (377 combos) came after **her perfect Hoho**:
  - 209 combos on his Shikai NS1a lunge (S16);
  - 147 on his sealed NS1a (S14).
- Her style Hohos his perceived move start when its hit is 1–6 frames off, within reach + slide + 1 m. She sees him 8 frames late, so a
  move with startup 8 or less (sealed J1 S6, KYORAN J1 S7, every SA) is out before she can react.
- The counter (60, 36 hitstun, his 40-frame lock) opens her J string, then AS3, a knockdown, and her meaty J1 loop.
- After v2:
  - **her wake-up Hoho** (at 0.9, only with him within 2.2 m) met 168 of his 304 meaty J1s in one seat. The J1 still landed, but her
    Hoho took her out of his string after one hit;
  - in the Shikai, her timed Hoho read the S9 J1 at lead 1, and her KESSA J1 (S8) then won the follow-up.

## The mechanism (every chance EASY ≤ NORMAL ≤ HARD, one roll per event, SIM-RND01 only; she is read through the SNAP and distance)
1. **`kk-seen-p` + `*kk-blind-p*` 0 / 0 / 1.0 (one roll per approach in `kk-pick`, per decision in `kk-decide`).**
   - The test: would she see a move start in time to Hoho it? That is true when:
     - its startup is over `*kk-blind-s*` 8;
     - she is free before its hit (her perceived frames left in her move / stun, less his delay; never while she is down);
     - her Hoho is not locked out. `*kk-hoho-lockout*` 84 = 24 + 60 after a Hoho of hers he saw, from the SNAP's state and frame.
   - Such a move is not started from neutral:
     - the sealed NS1a;
     - the Shikai NS1a lunge, in `kk-pick` and in the climb lunge;
     - the Bankai NS;
     - the S9 Shikai J1, in `kk-pick` and in the L3 J string.
   - J1 is taken where it reaches.
2. **The Step in** (`*kk-step-in*` 2.8–4.8 m). Out of J1's reach, inside a widened zone (to 4.8 m when `*kk-blind-p*` > 0):
   - he Steps toward her (2.5 m in 12 frames; a Step is no move for her Hoho to read);
   - J1 comes out of the Step's J cancel (`kk-step-j`, now corrected for her perceived walk back);
   - for a J1 she could see, the gate is checked at the J1's own start: `*step-j-cancel*` frames ahead.
3. **`*kk-meaty-out*` (HARD 2.25–2.4 m).** The meaty chase waits outside her wake-up Hoho's 2.2 m, and J1 (1.8 + 0.6 slide) still lands
   on her first free frame. He walks back into the band while she is down.
4. **`*kk-hend-p*` 0 / 0 / 1.0 (one roll per Hoho of hers he sees).**
   - J1 is timed to land on her Hoho's last frame + 1 (`*kk-hend-lead*` 0).
   - She reappears 1.6 m behind him, and her next Hoho is locked out.
   - A perfect Hoho of hers locks him, so this never fires then.
5. **`*kk-wake-bait*` (HARD t).** With a J1 she would see (the Shikai's S9, the Bankais' over 8):
   - no meaty J1;
   - he waits within her wake-up Hoho's reach (`*kk-meaty-near*`), and mechanism 4 punishes the Hoho.

## Measurements (`matchup-eval --side ken`; 20 seeds a seat paired; each row adds to the one above)

| Variant | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| baseline b0_a0 (reproduced) | 0.3809 | 3/40 | .264 (69/261) | .353 | .722 | 1/1 | 1.0 |
| v1 + seen gate, with a dash in | 0.4274 | 8/40 | .626 | .407 | .704 | 0/0 | 1.0 |
| v2 + busy / lockout read, Step in + J1 (dash gone) | 0.6993 | 25/40 | .737 | .732 | .778 | 0/0 | 1.0 |
| v3 + meaty out of 2.2 m | 0.8074 | 34/40 | .909 | .677 | .750 | 0/0 | 1.0 |
| v4 + the L3 J string gated | 0.8308 | 35/40 | .909 | .703 | .792 | 0/0 | 1.0 |
| **v5 + Hoho-end J1, wake bait, the Step's J1 checked at its start (final)** | **0.85** | **40/40** | .914 | .613 | .723 | 0/0 | 1.0 |

Log evidence:
- **Her damage on him in 40 HARD matches:** 271k (baseline) → 76k (v4) → 40k (v5).
- **Wake-up Hohos against his meaty:** 168 (v2, one seat) → 2 (v3, both seats). His meaty J1 then landed 753 of 777.
- **v5:** the Hoho-end J1 landed 84 of 91; the Step-in J1 landed 256 of 276 (93 %) across forms.
- **Shikai stays at v5** (20 seeds a seat, both seats; no Shikai stay counted in a lost match):
  - 38 reach L3 and go into the Bankai (ok);
  - the 24 failed stays all end with the match while he is in the Shikai (he won all 40 matches): 9 at L3, 15 at L0–L2.
  - Most kills come right after his Bankai return, at L0–L1 (J1 J2 J3 AS2 at pointer 2).
  - This is round 1–2's known trade: he wins before the theme closes. Dragging out a kill would be keyed to the detector, so I left it.

**40 seeds a seat:**

| | v3 | **v5 (final, score.json)** | baseline (BASELINE_DIR) |
|---|---|---|---|
| score | 0.8274 | **0.8609** | 0.2872 |
| HARD | 72/80 | **80/80** | 3/80 |
| brawl | .917 (507/553) | **.931 (513/551)** | .272 |
| shikai | .680 | .646 (84/130) | .337 |
| bankai | .740 | .727 (72/99) | .706 |
| antiwave | 0/0 (excluded) | 0/0 (excluded) | .5 (1/2) |
| NORMAL | .9375 | .9375 (band .863–1.0, factor 1) | .9375 |

## Why it is not a repeat
- No earlier cell played her timed perfect Hoho or her wake-up Hoho; both are new in her round-2 champion.
- The gate (her perception against a move's startup, her busy frames, her Hoho lockout from the SNAP) is new.
- The Step-in J1 as a neutral opener is new. `kk-step-j` existed only for the wave chase.
- So are the meaty band outside her 2.2 m, the J1 timed onto her Hoho's end, and the wake-up bait.
- b0_a1's J1-first row was a plain NS-odds switch against an opponent without the timed Hoho.

## Expected benefit and risks
- **Expected:** about 0.86 against her champion. The gain comes from strength (80/80) and the brawl (0.27 → 0.93).
- **Antiwave.** If her route opens in the rescore and fails, a 0 enters the mean (about −0.15). The wave code is b0_a0's, untouched
  except for `kk-step-j`'s reach, which now allows for her perceived walk back. That is stricter on the wave chase's J1 too, and could
  not be measured here.
- **Shikai 0.65, bankai 0.73.** Both are lower than v4 at 20 seeds because he wins sooner, and both still beat the baseline.
- **Knowledge of her style.**
  - `*kk-meaty-out*` relies on her wake-up Hoho's 2.2 m (`*iks-wake-hoho-near*`). If her next champion widens it, the meaty is met
    again; the Hoho-end J1 would then punish the Hoho.
  - `*kk-blind-s*` 8 is her HARD perception delay.
- **The widened zone (unmeasured).** With `*kk-blind-p*` > 0 an approach starts at 4.8 m, before `kk-decide` gets its turn, so the
  climb lunge and the Bankai NS (3.8 m) now mostly fire only on an approach's first decision. Bankai stayed 0.72–0.79 across v1–v5.
- **Stalemates.** With her Hoho ready and only S9 moves in the Shikai, he walks and waits. No match timed out at v5.
- **NORMAL** is unchanged: every new chance is 0 / NIL at NORMAL (0.9375, inside the band).
- **Host tests:** 9843 checks, ALL PASS.
