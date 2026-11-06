# b0_a1 (round 1): the lunge that counts. NS3a from where it really starts at 4 m, in every style mode, and a fresh episode each round

Direction: 間合い管理 (spacing), keeping the other three usable. Parent: b0_a0 (0.648 at 40 seeds; its 20-seed line reproduced
exactly here, 0.6309). Opponent: `ken/champion/cpu-ki-ken.lisp` (= Kenpachi's v0). Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
- **Baseline v0** (0.578): spacing 0.196. Its own notes: the hover sits outside the whiff radius, the pointer-2 J string is bad, one time-out.
- **b0_a0** (parent, 0.648; spacing 0.274): the pointer-2 back dash re-armed on every move of his, :generic 0.04, the pointer-1 hover at
  3.4–3.8 m. Its negative results: steering strings to AS2 costs more than it gains, and removing the pointer-2 J is worse. I kept both
  as they are and did not retry either.
- **b1_a0** (0.658): the whiff confirm (reacting to a whiff it sees), KESSA steered by red. Whiff 0.63, spacing unchanged (0.19).
- **b2_a0** (0.715): the Konpaku-aware finisher and the generic Kikon rule. ptr3 0.95, spacing 0.23.
- **b3_a0** (0.683): KESSA led (awakening gap, KESSA strings by pointer). Spacing fell to 0.17.

No cell had looked at why pointer 3's lunge converts so rarely. b0_a0's own table shows B3 spacing at 0.18.

## Diagnosis
I ran the frozen observer with a scratch wrapper that tags each spacing situation with her pointer, form, mode and distance at open
and close, and logs every Reishi drop with the observer's `ich-d` (10 HARD seeds, Ichigo P1).

1. **Most of pointer 3's lunges hit but did not count.** The observer credits a hit only from a move that starts at 4 m or more.
   - A lunge the style decided at a perceived 4.2 m started, by the observer, at 3.56–3.57 m, every time. That is about 0.64 m of her
     own travel before the move's class tick.
   - So v0 / b0_a0's band (4.0–5.0, lunging at its near edge) produced landed four-hit NS3a strings that scored as failures. It also
     put the lunge inside his NS3b (3.6 m) and his J1 cancel → AS1 (U3), which accounts for most of the CANCEL / ABSORBED lines in the
     failed situations.
   - The first attempt read this as perception lag (8 frames at HARD). The projection fixed real lag, but alone it did nothing (v1, v2).
     The constant 0.64 m offset was what remained.
2. **Only :space episodes lunged.** :whiff, :ptr3 and pre-awakening :kessa episodes let him walk through 4–5 m into the brawl range.
   Their pointer-3 situations failed at 0–0.17.
3. **Located bug: no new episode at a round's start.** A new episode was keyed to "she left neutral or lost Reishi". Her Reishi
   refills at a new round, so the last round's episode carried over with its wait (150 f) long spent. The generic CPU then dashed in
   from 8 m to 4.5 m and pressed NS3a / J1 into his read. Every 8.00 m pointer-3 opening in the logs went this way.

## The change
1. `*iks-lunge-band*` base 4.0–5.0 → **4.7–5.0**: the true start is then 4.0 m or more, where only her NS3a reaches (R4 / R5 hit from
   4.6 / 5.0).
2. `*iks-lead*`, `*iks-lead-vmax*` (new): the band tests the perceived distance plus its change between two consecutive calls (clamped
   to 0.07 m/step, a walk) times the perception delay. Only perceived distances are used, no position of his. `iks-in-lunge-band-p`
   also requires the stale distance not under the band.
3. `*iks-any-lunge-p*` (new, 0 / 0.5 / 0.95, one roll per episode): at pointer 3 in the sealed form, any style mode lunges when he is
   not attacking and the projected distance is in the band. `*iks-lunge-approach*` (new): in such an episode, from beyond the band she
   walks in to it, instead of the generic CPU's dash to 4.5 m.
4. `*iks-gap-episode*` 30 (new): a call more than 30 steps after the last one (a round's start, a cinematic) starts a new episode with
   a fresh mode roll. Her own dash (the pointer-2 back dash) is excluded.

Every roll stays once per event and EASY ≤ NORMAL ≤ HARD. Randomness comes only through `brain-roll` / `sim-rnd01`. The opponent is read
only through the SNAP and the distance. Host tests: 9843 checks, ALL PASS.

## Measurements (paired seeds; 20 a seat unless noted)
| Variant | Score | Str | Spacing | Whiff | Ptr3 | Kessa | NORMAL |
|---|---|---|---|---|---|---|---|
| parent b0_a0 | 0.6309 | 0.95 | 0.280 | 0.410 | 0.582 | 0.400 | 0.025 |
| v1: band 4.4–5.0 | 0.6085 | 0.90 | 0.256 | 0.387 | 0.563 | 0.450 | 0.025 |
| v2: + projection + any-mode lunge (band 4.15) | 0.6150 | 0.90 | 0.260 | 0.350 | 0.565 | 0.525 | 0.05 |
| v4: band 4.7–5.0 (+ clamp) | 0.6640 | 0.90 | 0.376 | 0.473 | 0.553 | 0.625 | 0.025 |
| v5: + approach walk | 0.6569 | 0.975 | 0.342 | 0.476 | 0.611 | 0.350 | 0.10 |
| v6: + new episode on a call gap | 0.6766 | 0.975 | 0.413 | 0.492 | 0.505 | 0.500 | 0.025 |
| v7: + own dash excluded (final) | 0.6849 | 0.975 | 0.349 | 0.491 | 0.576 | 0.550 | 0.025 |
| v7 without the approach walk | 0.6812 | 0.975 | 0.363 | 0.536 | 0.616 | 0.425 | 0.05 |
| **40 seeds:** v7 without the approach | 0.6617 | 0.95 | 0.358 | 0.509 | 0.606 | 0.405 | 0.0375 |
| **40 seeds: v7, final (score.json)** | **0.6652** | 0.95 | **0.351** | 0.492 | 0.565 | 0.494 | 0.0375 |

- Diagnostic (10 seeds, P1), pointer 3 sealed spacing: parent 27/100 (0.27) → v4 45/80 (0.56) → v5 50/87 (0.57).
- The approach walk is neutral within noise (40 seeds: +0.0035 score, −0.007 spacing). It is kept for the round-start case it was
  written for.
- Spacing moves about ±0.06 between near-identical variants at 20 seeds (v6 against v7), so judge it at 40.

**Final, 40 seeds a seat, against the parent's 40-seed line:**
- score 0.648 → **0.6652**;
- spacing 0.274 → **0.351**;
- whiff 0.415 → **0.492**: fewer brawls at 4.0–4.4 m, more of his whiffs inside 3.6 m;
- ptr3 0.585 → 0.565 (noise, 168 situations);
- kessa 0.512 → 0.494 (noise, 79 situations);
- strength 0.95 → 0.95 (76/80);
- NORMAL 0.0375 → 0.0375 (band 0–0.138, factor 1).

## Why it is not a repeat
- No earlier cell touched where the lunge starts or which modes lunge. b0_a0 retuned the pointer-2 retreat and the pointer-1 hover.
- The 4.7 m edge rests on a measured offset between the decision and the observer's move start, not on a sweep.
- The round-start episode is a located bug in the shared episode logic. It affects every mode, so later cells inherit the fix.

## Remaining ceiling and risks
- **Pointer 1 is about a quarter of all spacing situations and converts about 2 %.** No pointer-1 move starts from 4 m, and every
  round opens at 8 m at pointer 1. Only leaving pointer 1 sooner moves this. That is b2_a0's territory (its finisher steer and
  generic Kikon rule are orthogonal to this cell and should combine).
- **KESSA's pointer-3 `k-lunge` has the same flaw.** It fires at a perceived 3.6–3.8 m (`*iks-kessa-lunge-band*`), so it can't count
  for spacing. Raising it needs the KESSA NS3a / SA reach measured first; it was not done here.
- **KESSA against his Shikai** stays at about 0.2: his NS1a reaches 4.6 m and owns the band.
- **His Hoho** goes through the 4.7 m lunge now and then (a COUNTER 60). Lunging from farther only makes it easier for him.
- **The 4.7–5.0 window is 0.3 m wide.** Against a faster-closing Kenpachi the projection (clamped to a walk) may skip it. The
  approach walk then hands back to the other clauses.
