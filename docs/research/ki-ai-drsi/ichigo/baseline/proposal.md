# b2_a1 (round 1, Ichigo): pointer 3 as home, b2_a0's finisher with b1_a0's whiff confirm and b0_a0's pointer-2 re-arm

Direction: 指針三狩魂 (ptr3), keeping the other three usable. Parent: b2_a0 (0.7151 at 40 seeds; 0.7128 at 20, re-measured here).
Opponent: `ken/champion/cpu-ki-ken.lisp` (Kenpachi v0). Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

## History read (every sibling's proposal, score.json and score.rescored.json; the rescores equal the claims)
| Cell | Mechanism | 40-seed score | Spacing | Whiff | Ptr3 | Kessa | Lesson |
|---|---|---|---|---|---|---|---|
| baseline v0 | four modes, start-time punish guess | 0.578 | 0.196 | 0.307 | 0.556 | 0.463 | |
| b0_a0 | pointer-2 back-dash re-armed per his move; pointer-1 hover 3.4–3.8 | 0.648 | 0.274 | 0.415 | 0.585 | 0.512 | steering strings to AS2 is a loss |
| b1_a0 | whiff confirm (a whiff SEEN in the SNAP, the fastest punisher that fits, walk-in); KESSA (5 3) | 0.658 | 0.188 | **0.629** | 0.504 | 0.500 | whiff doubles; ptr3 falls (kills at pointer 1) |
| b2_a0 (parent) | Konpaku-aware finisher, generic Kikon rule, awaken in every mode | **0.715** | 0.227 | 0.287 | **0.953** | 0.700 | ptr3 near its ceiling; whiff untouched |
| b3_a0 | KESSA-led: awaken gap, KESSA AS3 / red AS2 | 0.683 | 0.170 | 0.324 | 0.783 | 0.675 | KESSA at pointer 3 > pointer 2 |

None of the round-1 ideas failed through a bug; each fixed a different leak. ptr3 is at 0.95, so ptr3 alone can add only about +0.006. The parent's
open leak is whiff (0.29), and b1_a0's confirm fixes whiff but cost b1 its ptr3. This cell combines the two: the finisher protects ptr3,
while pointer 3 becomes where the whiff punishes happen.

## Diagnosis (the parent, 20 seeds a seat, HARD, raw logs; pointer tracked from her AS starts)
| Form / pointer | Whiff ok / occ | Spacing ok / occ |
|---|---|---|
| base 1 | 45 / 237 (0.19) | 5 / 162 |
| base 3 | 113 / 222 (0.51) | 57 / 226 |
| KESSA 2 | **14 / 289 (0.05)** | 60 / 125 (0.48) |
| KESSA 3 | 68 / 111 (0.61) | 50 / 203 |

- **KESSA sat at pointer 2.** That cell was 289 of the 913 whiff situations, punished 5 % of the time: no fast punisher, and
  127 `p2-j` attempts (44 hits hers, 42 his).
- KESSA ended 76 strings in AS2:
  - 30 are the finisher's K.O. Kikons;
  - the rest come from v0's `*iks-kessa-as*` 3 in :kessa episodes when he is not red.
- ptr3's leaks in the parent are tiny: 3 failures in 72.

## The change (the final file = c6)
1. **Pointer 3 kept in KESSA**: `*iks-kessa-as*` 3 → (5 3) (b1_a0's form).
   - Not red: AS3, so pointer 3 stays.
   - Red: AS2. In practice `iks-finish-target` decides first: AS2 when the red Kikon K.O.s, AS3 when the Soul Break takes 5.
2. **b1_a0's whiff confirm**, grafted verbatim: `iks-confirm`, `*iks-punishers*`, the walk-in, the `:g-sa` NS2 branch.
   - At pointer 3 it presses NS3a (S18, 5.0 m), so pointer 3 is where it pays.
   - NORMAL `*iks-confirm-p*` 0.3 → 0.1. At 0.3, NORMAL read 5 of 40 (0.125), against the band's edge of 0.138. At 0.1 it reads
     0.075–0.10.
3. **b0_a0's pointer-2 pieces**: `*iks-retreat-rearm*` T, `*iks-retreat-p*` HARD 0.8 → 1.0, `*iks-hover-p1*` 3.4–3.8 sealed.
4. Unchanged from the parent: the finisher, the Konpaku read, the generic Kikon rule, the mix, awakening in every mode.

After the change (c6 logs, 20 seeds a seat):
- KESSA pointer-2 whiff situations fell from 289 to 10.
- Whiff at base pointer 3 is 148 / 185 (0.80), at KESSA pointer 3 79 / 89 (0.89), at base pointer 1 74 / 156 (0.47).
- ptr3 failures: 6 in 81, all Soul Breaks off pointer 3:
  - base pointer 1, −3 (NS1a, SA);
  - base pointer 2, −3 (NS2c);
  - KESSA pointer 1, −4 (NS1a ×2);
  - KESSA pointer 2, −4 (AS2).

## Measurements (20 seeds a seat, paired on seeds 1–20, same opponent)
| Variant | Score | HARD | Spacing | Whiff | Ptr3 | Kessa | NORMAL |
|---|---|---|---|---|---|---|---|
| parent b2_a0 | 0.7128 | 39/40 | 0.229 | 0.289 | 0.958 (69/72) | 0.675 | 0.025 |
| c2 = parent + confirm + KESSA (5 3) | 0.7519 | 39/40 | 0.190 | 0.646 | 0.901 (73/81) | 0.675 | 0.100 |
| c1 = c2 + b0's re-arm / retreat 1.0 / hover-p1 | **0.7731** | 39/40 | 0.190 | 0.688 | 0.926 (75/81) | 0.750 | 0.125 |
| c3 = c1 + :ptr3 episodes lunge at pointer 3 (both forms), NORMAL confirm 0.1 | 0.7238 | 37/40 | **0.254** | 0.672 | 0.882 | 0.550 | 0.075 |
| c5 = c1 + KESSA lunge band (3.6 4.3) → (4.0 4.3), NORMAL confirm 0.1 | 0.7668 | 39/40 | 0.171 | 0.674 | 0.917 | 0.750 | 0.100 |
| c7 = c1 + :ptr3 lunge at pointer 3, sealed only, NORMAL confirm 0.1 | 0.7501 | 38/40 | 0.220 | 0.668 | 0.929 | 0.650 | 0.100 |

- c6 = c1 with NORMAL's confirm at 0.1. Its HARD play is identical to c1's (only NORMAL's knob differs).
- c1 against c2: b0's pieces add whiff +0.04 and ptr3 +0.025. The kessa difference (3 situations) is noise, but no theme fell, so the pieces stay.

**Rejected (worth keeping as history)**: letting :ptr3 episodes play the 4–5 m lunge at pointer 3 instead of the generic neutral
(c3, c7).
- Spacing rises (+0.03 to +0.06).
- Twice, strength and kessa fell with it: 37–38/40, kessa 0.55–0.65.
- The lunge loses about a third of its exchanges (parent: lunge from base pointer 3, 56 hers / 28 his). In the :space share it pays; at
  twice the share it costs more than it gains.

Rejected too: moving KESSA's lunge band to ≥ 4 m (c5) lowered spacing, presumably through more walking and fewer lunges.

## Final (c6, 40 seeds a seat, score.json)
`{"side": "ichigo", "seeds": 40, "strength": 0.975, "signature": 0.6547, "themes": {"spacing": {"rate": 0.209, "ok": 281, "occ": 1346}, "whiff": {"rate": 0.702, "ok": 731, "occ": 1041}, "ptr3": {"rate": 0.933, "ok": 153, "occ": 164}, "kessa": {"rate": 0.775, "ok": 62, "occ": 80}}, "hard": "78/80", "normal": {"share": 0.1, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.7828, "score": 0.7828}`

| Part | Baseline v0 | Parent b2_a0 | **b2_a1** |
|---|---|---|---|
| Score | 0.5781 | 0.7151 | **0.7828** |
| HARD | 70/80 | 78/80 | 78/80 |
| Spacing | 0.196 | 0.227 | 0.209 |
| Whiff | 0.307 | 0.287 | **0.702** |
| Ptr3 | 0.556 | 0.953 | 0.933 |
| Kessa | 0.463 | 0.700 | 0.775 |
| NORMAL | 0.1125 | 0.0625 | 0.100 (band 0–0.138, factor 1) |

Host tests: 9843 ALL PASS.

## Not a repeat
- No sibling combined the finisher with the confirm. The other refine cells' folders (b0_a1, b1_a1, b3_a1) were still empty at delivery.
  b1_a1 may graft b2's finisher onto b1 from the other side. This cell starts from the finisher:
  - it removes the KESSA pointer-2 sink located above;
  - it adds b0's pointer-2 re-arm;
  - it tests and rejects the pointer-3 lunge in :ptr3 episodes, a new negative result.
- The ptr3 direction is served by protecting ptr3 (0.93, against b1_a0's 0.50) while pointer 3 becomes the state where the whiff
  punishes land.

## Risks
- **NORMAL is 0.100 (8 of 80) against the band's edge of 0.138.**
  - The evaluator is deterministic: every sibling's rescore matched its claim. The NORMAL runs face Kenpachi's generic CPU, so the
    re-measure will reproduce 0.100.
  - The real exposure is a later cell adding another piece that reaches NORMAL. The headroom is about 3 wins in 80.
  - Pieces here that reach NORMAL:
    - the confirm (0.1);
    - b0's retreat (NORMAL 0.5);
    - the parent's value rule and awaken modes.
  - The levers: NORMAL `*iks-retreat-p*` lower, or the confirm to 0.
- **The pointer-1 hover sits near his reach** (b0_a0's risk). At 3.4–3.8 m it is close to his NS3b (3.6 m).
- **The opponent will change.** Strength and every theme were measured against Kenpachi v0 only. Ken's round-1 cells score up to 0.656
  against Ichigo's v0, so a stronger champion is likely next round. The hover and the confirm's timings are untested against it.
- **Spacing is now the weakest theme** (0.21; the parent had 0.23):
  - KESSA no longer sits at pointer 2, where the Getsuga gave 60 of 178 spacing hits;
  - base pointer 1 converts almost none (4 of 146).

  A spacing tool that does not cost strength is still open.
- **Carried from b2_a0:** `iks-kikon-value` reads his Konpaku pips (`gauges-konpaku`), beyond SNAP + distance. It is a HUD fact of the
  same class as `GAUGES-RED-P`, which v0 already reads. If the read is rejected, the finisher's `:ko` / `:tap` / `:even` split goes with it.
- **The confirm's assumptions (b1_a0's):** the 8 f perception delay subtracted from the SNAP's frames left; the walk at 0.06 m/f.
