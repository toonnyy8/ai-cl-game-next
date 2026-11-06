# b0_a0 (round 1): pointer 2 commits to the Getsuga game; pointer 1 hovers where its punisher reaches

Direction: 間合い管理 (spacing), keeping the other three usable. Parent: the baseline v0 (0.5781 at 40 seeds). There was no history and
no sibling result to read yet (round 1, sibling node dirs empty when this cell started).

## Diagnosis (10 HARD matches, Ichigo P1, full combat log + situ lines, v0)
Spacing results by her pointer and form (B = sealed Shikai, K = KESSA):

| | B1 | B3 | K1 | K2 | K3 |
|---|---|---|---|---|---|
| spacing ok / fail | 3 / 67 (0.04) | 12 / 56 (0.18) | 1 / 32 | **24 / 24 (0.50)** | 15 / 33 |
| whiff ok / fail | 16 / 69 (0.19) | 32 / 17 (0.65) | 4 / 11 | 9 / 41 | 12 / 10 |

- Pointer 2 is the only state where spacing converts (every ok there is a wave hit). Pointer 1 can't score: NS1a reaches 3.4 m and
  the theme needs a move started at 4 m or more. In the sealed form she never reached pointer 2 at all (0 base-form AS2 in 10
  matches): every pointer-2 spacing hit came in KESSA.
- The style's own Getsuga from at least 7.5 m beats him (K2 getsuga: 71 of her hits first, 7 of his), because his anti-Getsuga band
  is 3.4–7.0 m.
- **A located bug-like gap**: the pointer-2 back-dash roll was made once per neutral episode. When it said no, or after one dash,
  she walked back at 2.3–3.6 m with no punisher while his Shikai kamae (KE-S-N2A) came again and again. One stall: 15 whiffs of his
  in 900 frames, no answer, no Getsuga.
- Pointer 1: the v0 hover (3.7–4.2 m) sits beyond her J-whiff punisher (NS1a 3.4 m). His 15 J1 whiffs at B1 got no answer, and his
  whiffs land outside the whiff theme's 3.6 m radius.

## The change (duel/lisp/cpu-ki-ichigo.lisp only)
1. `*iks-retreat-rearm*` T (new): in the pointer-2 middle band, each move of his he starts re-arms the back-dash roll, not just the
   episode's start. She gets out to Getsuga range and shoots, instead of walking backwards into his kamae.
2. `*iks-retreat-p*` HARD 0.8 → 1.0 (NORMAL stays 0.5).
3. `*iks-mix*` HARD :generic 0.12 → 0.04, :space 0.24 → 0.32. A generic episode breaks the retreat-and-shoot loop: the generic CPU
   shoots from 3.6–6.6 m into his anti-Getsuga band, or charges inside 3.6 m. NORMAL is unchanged.
4. `*iks-hover-p1*` (new): the :whiff / :space hover band under pointer 1 is 3.4–3.8 m in the sealed form, inside NS1a's punish reach
   and past his sealed NS1a (3.3 m). The Shikai keeps 4.9–5.3 m.

## Measurements (paired, same seeds; the opponent is Kenpachi's champion = v0)
20 seeds a seat:

| variant | score | str | spacing | whiff | ptr3 | kessa | NORMAL |
|---|---|---|---|---|---|---|---|
| v0 baseline | 0.5877 | 34/40 | 0.208 | 0.339 | 0.579 | 0.525 | 0.075 |
| V1 :space strings steer to AS2 (unless he is red) | 0.5652 | 33/40 | 0.239 | 0.222 | 0.557 | 0.55 | 0.05 |
| V2 = V1 + re-arm | 0.5424 | 31/40 | 0.259 | 0.305 | 0.511 | 0.475 | 0.05 |
| V2b re-arm only | 0.6318 | 37/40 | 0.250 | 0.345 | 0.600 | 0.55 | 0.075 |
| V3 = V2b + mix + retreat 1.0 | 0.6462 | 38/40 | 0.265 | 0.375 | 0.610 | 0.525 | 0.075 |
| V4 = V3 + no J at pointer 2 + no walk-in NS1a | 0.5621 | 33/40 | 0.273 | 0.282 | 0.616 | 0.375 | 0.10 |
| V4a = V3 + no J at pointer 2 | 0.5428 | 32/40 | 0.265 | 0.274 | 0.571 | 0.375 | 0.075 |
| V5 = V3 + :space AS2 steer in KESSA only | 0.5899 | 35/40 | 0.291 | 0.332 | 0.577 | 0.40 | 0.075 |
| V6 = V3 + pointer-1 hover 3.4–3.8 | 0.6309 | 38/40 | 0.280 | 0.410 | 0.582 | 0.40 | 0.025 |

40 seeds a seat: V3 0.6431 (str 0.9625, spacing 0.271, whiff 0.353, ptr3 0.598, kessa 0.500, NORMAL 0.10), **V6 0.648** (str
0.95, spacing 0.274, whiff 0.415, ptr3 0.585, kessa 0.512, NORMAL 0.0375). V6's 20-seed kessa dip was draw noise. V6 is delivered.

Final (V6, 40 seeds a seat, score.json): `{"side": "ichigo", "seeds": 40, "strength": 0.95, "signature": 0.4466, "themes": {"spacing": {"rate": 0.274, "ok": 518, "occ": 1892}, "whiff": {"rate": 0.415, "ok": 552, "occ": 1329}, "ptr3": {"rate": 0.585, "ok": 100, "occ": 171}, "kessa": {"rate": 0.512, "ok": 41, "occ": 80}}, "hard": "76/80", "normal": {"share": 0.0375, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.648, "score": 0.648}`
(the same line twice: the run before the final whitespace-only fix of a docstring line and the run after it.)

Against the baseline's 40-seed line: score 0.578 → 0.648; strength 0.875 → 0.95; spacing 0.196 → 0.274; whiff 0.307 → 0.415;
ptr3 0.556 → 0.585; kessa 0.463 → 0.512; NORMAL 0.1125 → 0.0375 (band 0–0.138, factor 1).

## What the history says (negative results worth keeping)
- **Steering strings to AS2 to buy pointer-2 time costs more than it gains** (V1, V2, V5): spacing rises (to 0.29), but she loses
  pointer 3's whiff punishes (pointer 2 has no punisher; B2 / K2 whiff 0.04–0.10), AS3's damage, and KESSA's margin. Don't retry
  this as a knob tweak.
- **Pointer 2's point-blank J string is bad on its own** (16 of her hits first, 41 of his; his J1 S6 against her S14), but removing it
  is worse (V4a −0.10): it is how she leaves pointer 2 for AS3. A better close-range exit from pointer 2 is open.
- The pointer-1 walk-in NS1a loses its exchanges 5 : 10, but removing it didn't help (V4, bundled with the J removal).

## Not a repeat
Round 1, no prior nodes. The mechanism is structural: the retreat roll is per his move, not per episode, and the pointer-1 band follows
her punisher's reach. It is not a re-weighting of v0's knobs.

## Risks
- The Getsuga loop leans on his anti-Getsuga band ending at 7.0 m. A Kenpachi champion that closes from farther will cut the K2
  spacing hits (about half of all spacing ok).
- The pointer-1 hover at 3.4–3.8 m sits near his NS3b (3.6 m) and the champion's brawl read (3.1 m). Strength held (76/80), but a
  more aggressive Kenpachi may punish it.
- NORMAL fell to 0.0375. It is inside the band (0–0.138), and its lower edge is 0, so it can't fall out.
