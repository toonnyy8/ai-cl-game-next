# b1_a0 (round 1): the whiff confirm (揮空反擊)

Parent: the baseline (v0). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read
- Round 1 has no history yet, and no sibling had delivered when this was written (b0/b2/b3 folders empty).
- Baseline v0 (proposal + score.json, 40 seeds): 0.5781. Whiff 0.307 (559/1822). Its own note says most of its punishes fall outside
  the 3.6 m whiff radius.
- What it does: the punish is a start-time guess. When his perceived move starts, she compares the distance with a table of his
  reach (`*iks-his-reach*`: NA 2.7, NS 3.65) and punishes only if he starts out of reach.

## Diagnosis (scratch observer over the frozen situ.lisp, 10 seeds a seat, HARD)
Each whiff situation was logged with his move, the distance, her state, pointer, form and style mode:
- **Idle and not punishing**: 193 of 450 whiffs found her idle; she punished 15 %. Most had the guess flag "no": he started inside
  the reach table and whiffed anyway, because she had stepped back or his slide fell short.
- **Pointer 2**: no punisher at all (the old punish skips it). KESSA spent most of its time at pointer 2 because KESSA strings were
  steered to AS2: 101 whiffs, 17 % punished.
- **Pointer 3**: NS3a already punished 93 % once pressed. The problem was getting the press out, not the punisher.

## Mechanism (new against v0: a reaction to a whiff that is seen, not a guess at his move start)
1. **Whiff confirm** (`iks-confirm`, `*iks-confirm-p*` 0 / 0.3 / 0.95, rolled once per his move start).
   - The trigger: his perceived SNAP shows an NA, NS or SA past its active frames, no contact, not a `:parry` (the sealed tame).
   - She then presses the fastest entry of `*iks-punishers*` that lands inside his recovery: `snap-left` minus her perception
     delay, plus `*iks-confirm-slack*` 3.
   - The entries: J1 (S14, KESSA S8), NS1a at pointer 1, NS3a at pointer 3, KESSA NS3a + SA, and NS2a + its gap SA at pointer 2.
   - It covers what the old punish never reached: whiffs he started "in reach", SA whiffs, and KESSA.
2. **Walk-in** (`*iks-confirm-walk*` 0.06 m/f). If the punisher is short of his recovering body by a little and the frames still
   fit, she walks in first, then presses once in reach (`iks-pend-step`). This is aimed at pointer 1's NS1a against his NS1a / J1
   whiffs that end at about 3.5 m.
3. **KESSA steering by red** (`*iks-kessa-as*` 3 → (5 3)).
   - Not red: steer to AS3, so KESSA sits at pointer 3, where NS3a punishes and a Soul Break takes 5.
   - Red: AS2 as before, which keeps the red pointer-2 Kikon (ptr3 theme ok, 4 Konpaku).
   - AS3 always (v2) cut red Kikons from 21 to 5 per 10 seeds a seat; this hybrid is the fix.
4. Two bugs fixed while adding this:
   - `iks-punish` now returns T when it presses (it had to, once the confirm runs after it).
   - The stale `:done` flag is keyed to his move start.

## Measurement (matchup-eval, HARD, paired seeds)
| Variant | Seeds | Score | Strength | Spacing | Whiff | Ptr3 | KESSA | NORMAL share (band 0–0.138) |
|---|---|---|---|---|---|---|---|---|
| baseline v0 | 20 | 0.5877 | 0.850 | 0.208 | 0.339 | 0.579 | 0.525 | 0.075 |
| baseline v0 (its score.json) | 40 | 0.5781 | 0.875 | 0.196 | 0.307 | 0.556 | 0.463 | 0.1125 |
| v1: confirm | 20 | 0.6607 | 0.925 | 0.209 | 0.522 | 0.707 | 0.500 | 0.025 |
| v2: + KESSA always AS3 | 20 | 0.6756 | 0.975 | 0.184 | 0.619 | 0.475 | 0.625 | 0.05 |
| v3: + KESSA by red (5 3) | 20 | 0.6747 | 0.950 | 0.190 | 0.571 | 0.629 | 0.575 | 0.05 |
| v4: + walk-in, **final** | 20 | 0.6554 | 0.950 | 0.201 | 0.618 | 0.518 | 0.500 | 0.05 |
| v4 with walk-in off (0.001; also cuts reach by 0.1) | 40 | 0.6360 | 0.9125 | 0.183 | 0.531 | 0.567 | 0.525 | 0.075 |
| **v4, final** | **40** | **0.6583** | **0.9625** | **0.188** | **0.629** | **0.504** | **0.500** | **0.075 (factor 1)** |

- At 40 seeds the walk-in adds whiff +0.10, strength +0.05 and score +0.022 over the same file with it off. The 20-seed v3 / v4 gap
  is within the ptr3 / KESSA draw noise: KESSA has 40 situations, ptr3 about 100.
- Ptr3 events per 10 seeds a seat (her Soul Breaks by Konpaku, her Kikon follow-ups):

  | Version | Red Kikon | Non-red Kikon | Soul Break −5 | −4 | −3 |
  |---|---|---|---|---|---|
  | base | 13 | 8 | 17 | 8 | 1 |
  | v1 | 21 | 6 | 15 | 2 | 5 |
  | v2 | 5 | 7 | 18 | 11 | 7 |
- Whiff by state at 10 seeds a seat (v3):
  - Idle: 37 % punished, against 15 % at baseline.
  - Pointer 3, base form: 79 %. Pointer 3, KESSA: 70 %.
  - Still unpunishable: her stun, down or wake-up (about 60 of 330).
  - KESSA pointer 2 when he is red: 36, 6 %. The pointer-2 NS2a + SA entry never fired in that run, since his recovery is too short
    for 29 f. It stays in the table as a harmless entry; drop it if a later cell confirms it is dead with the walk-in on.
- Host tests: 9843 ALL PASS.

## Expected benefit, risks
- Benefit: whiff 0.31 → 0.63, strength 0.875 → 0.96, score 0.578 → 0.658 (40 seeds). NORMAL stays in band: the confirm is 0.3 at
  NORMAL and needs a style episode (88 % generic there).
- Risk: ptr3 is lower than v1 (0.50 against 0.56–0.71). Two causes:
  - The red/AS2 rule only triggers on red at the string's first link.
  - Faster punishes kill him at pointer 1 more often (Soul Break −3 / −4).
  
  A follow-up cell could route confirm strings at pointer 1 to J5 + SP more surely. It could also hold the red Kikon at pointer 3:
  it takes only 1 Konpaku but counts ok.
- Risk: spacing is unchanged (0.19). The confirm takes no part in the 4–5 m lunge.
