# b3_a0 (round 1): 破月牙 rebuilt around what lands — the late Hoho + J1, the lunge where it reaches, the AS on her route

Direction hint: lean on 破月牙 (antiwave) and keep the other three usable. Changed only `duel/lisp/cpu-ki-ken.lisp`, starting from
the baseline (v0).

## History read
- Round 1 has no history. When I started and when I finished, the sibling nodes (b0_a0, b1_a0, b2_a0) had no proposal or score yet.
- Baseline v0 (score.json): 0.3505. strength 10/80; brawl 0.568, shikai 0.768, bankai 0.312, **antiwave 0.356 (16/45)**. The v0
  proposal already said that "the timed cut / late Hoho rarely fire".

## Diagnosis (raw combat logs of the 20-seed HARD matches, both seats, every antiwave situation bucketed by form and plan)
- **How a situation arises.** Ichigo's style shoots the Getsuga only from a perceived ≥ 7.5 m. Kenpachi's generic CPU dashes in
  blind from beyond 7 m (to 4.5 m), and the style is not called while that dash is held. So most situations open with him arriving
  at about 4.4 m as her *second* charge starts. That leaves him about 32 frames before the wave.
- **v0's answers by form.**
  - In the Shikai, `:close` worked (8 of 10): the pointer 1 lunge reaches from 5.4 m.
  - Sealed, `:close` landed 1 of 4 (the Hoho, then a walk to 2.6 m, is too slow). `:late` landed 0 of 2: after the Hoho nothing
    followed, she recovered and started her next move first.
  - `:cut` never scores. The cut leaves him about 4 m away during her 26-frame recovery.
- **Bugs and shortfalls located in the code:**
  1. `kk-move`'s climb target overrode the AS read. While she charged, a landed (cancelling) J went on to J2 (a J only cancels
     her charge; JUJISHO still fires), and the wave hit him (logged at 10120–10172).
  2. A J1 approach on her charge is read by her charge's SA (`IC-SA-G1/G2 -> HIT`, several logs). Against a charge the right tool
     is the NS, where the first hit wins.
  3. The `:hit` stage dashed to 2.2 m and then pressed NS1a. The dash's momentum carried him past her and the NS whiffed (3104–3139).
  4. In a Bankai, his NS costs 40 Reishi. Pressed during her JUJISHO, that is both a waste and a Reishi drop. A Bankai J1 cuts the
     wave instead.

## Mechanism (all inside the approved 破月牙 style; knobs are `defparameter`s with docstrings)
- **The plan per route (`kk-wave-plan`, still one roll per route, `*kk-wave-p*` unchanged).**
  - Where his pointer's NS reaches her from where he stands (`kk-reach`: reach + slide − `*kk-reach-margin*`, plus
    `*kk-wave-carry*` while running): always `:close`. This is the Shikai lunge (F15) and KYORAN's (F18).
  - Otherwise by `*kk-wave-mix*`, now **:late 1.0** (only with a Hoho open), :close 0.25, :cut 0.15 (was 1.0 / 1.0 / 0.5).
    `:close` is never rolled beyond `*kk-wave-close-max*` 5.6 m.
- **A new `:chase` after `:late` / `:cut`.** Until JUJISHO + `*kk-chase-frames*` (90), he presses J1 as soon as she is in J1 reach,
  else the NS if only it reaches, else he dashes in from beyond `*kk-chase-dash*` 4.5 m. After a late Hoho he lands about 1.6 m
  from her. The sealed J1 (S6) lands on the frame before her next press (log 3290–3321: J1 HIT, then AS1 90).
- **`:close` / `:hit`.**
  - He presses the pointer's NS once it reaches, or J1 where the NS has no hit (the sealed tame).
  - The dash stops at the NS's reach, not at 2.2 m.
  - In a Bankai during her JUJISHO, J1 instead of the NS.
- **The route AS (`kk-route-as-p`).** A J that lands while her route is live turns into the SP at once (AS beats NS). This applies
  sealed, in the Shikai at pointer 1, and at pointer 2 short of an L3 plan. At L3 with a plan the J string goes on (every Shikai J
  window cuts the wave). Never in a Bankai.
- **Unchanged:** the band (3.4–7.0 m) and all other themes' code.
  - I tried 9.5 m to answer her far shots. It cost strength (3 of 40 against 6 of 40, paired) and added situations he could not win.
  - I also tried a walk-in instead of the generic dash. It went badly: 1 of 40, antiwave 2 of 14. Both were reverted.

## Why it is not a repeat
v0 had the `:late` and `:cut` answers but nothing after them, and its J-based close fed her SA. This cell changes four things:
- it chooses the answer by what can land (reach, Hoho open);
- it adds the follow-through that turns a dodge into a hit;
- it fixes the AS read that the climb target overrode;
- it fixes the overrunning dash.

## Measurement (paired seeds; opponent = the Ichigo champion = v0)
| file | seeds | score | strength | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|---|
| baseline v0 | 20 | 0.3692 | 6/40 | 0.557 | 0.714 | 0.316 | 0.474 (9/19) | 0.95 |
| baseline v0 (score.json) | 40 | 0.3505 | 10/80 | 0.568 | 0.768 | 0.312 | 0.356 (16/45) | 0.9625 |
| intermediate variants (J-first close, far band 9.5, walk-in, forced late on late sightings) | 20 | 0.257–0.370 | 1–6/40 | ≈0.56 | 0.59–0.73 | 0.35–0.45 | 0.14–0.39 | 0.95–1.0 |
| **this file** | 20 | 0.4048 | 5/40 | 0.565 | 0.700 | 0.373 | **0.727 (8/11)** | 0.95 |
| **this file** | 40 | **0.4106** | 10/80 | 0.567 | 0.757 | 0.330 | **0.750 (24/32)** | 0.9375 (factor 1) |

Host tests: 9843 checks, ALL PASS. The 20-seed log buckets for this file:
- sealed `:late` 4/5 ok;
- the Shikai lunge `:close` 2/3;
- sealed `:close` 1/1, Bankai `:close` 1/1;
- the three failures: a Shikai pointer 2 close (the hilt's 2.4 m, too short), a Shikai pointer 2 late Hoho (the Shikai J1's S9 is
  2 frames slower than her J1 start), and a route during his awakening cinematic.

## Expected benefit and risks
- Antiwave about 0.36 → about 0.75. The other three themes and strength stay where they were, NORMAL stays in its band, so the score
  gains about +0.06.
- Risks:
  - Antiwave rests on about 30 situations in 40 seeds a seat, so expect ±0.08 on that rate.
  - Fewer situations open than with v0 (32 vs 45 in 40 seeds). The rate gain is not a smaller denominator: successes rose 16 → 24
    and failures fell 29 → 8.
    - Waves that hit him, counted in the paired 20-seed logs (both seats): v0 78 + 104 = 182, this file 58 + 69 = 127.
    - The logs show failures chaining: a wave knocks him down, she backs off and shoots again as he gets up, and a new, unwinnable
      situation opens (seen too late, the wave already flying). Fewer wave hits mean fewer of those chains. That is the measured
      reason situations fell.
  - **Detector interaction, disclosed.** In situ.lisp, any Reishi drop of his while she is in IC-N2C / IC-K-N2C sets the "wave hit
    him" flag. A Bankai NS's 40-Reishi cost is such a drop (log 8344–8360 of an earlier variant: KE-ZH-NA hit her for 100, yet the
    situation closed occ). The Bankai rule "J1, not the NS, during her JUJISHO" avoids it.
    - It has its own game reasons: the NS costs 40 Reishi, and the Bankai J1 cuts the wave (F32).
    - It covers very few situations (Bankai routes: 1–2 in 20 seeds).
    - The coordinator may judge it.
  - The late Hoho + J1 timing depends on her pressing right after JUJISHO's recovery. An opponent that waits would be hit even more
    reliably; one that Hohos away would escape.
- Open lead for later cells: Shikai pointer 2 has no answer that lands. One option is to time the cut and then the burst. Another is
  to steer the pointer to 1 before she zones.
