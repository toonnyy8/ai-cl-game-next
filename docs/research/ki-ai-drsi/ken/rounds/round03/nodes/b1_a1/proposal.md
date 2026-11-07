# b1_a1 (round 3, 解放攀升 hint, parent b1_a0): J1 onto the end of her Hoho, ported from b3_a0; why the Shikai rate did not move, and eleven variants that failed

Direction: 解放攀升 (shikai), keeping the other three themes usable.
- Parent: b1_a0 (rescored 0.828, HARD 68/80, shikai .719).
- Opponent: Ichigo's champion (her round-2 b1_a1).
- Only `duel/lisp/cpu-ki-ken.lisp` changed.
- The worktree is at 7c5e696, not the freeze cee7bd6. Between the two, only `docs/research/ki-ai-drsi/` differs.

**In short:** one mechanism was kept, `*kk-hend-p*`, the sibling b3_a0's J1 timed onto the end of her Hoho. It raises strength on held-out seeds. No Shikai-specific mechanism beat the noise. The analysis below says why: the shikai theme's ceiling is set by how matches end.

## History read
- The score.rescored.json of every cell, and the opening, mechanism and measurement sections of each proposal:
  - round 1: all 8 cells;
  - round 2: all 7 cells, with r2 b1_a1 ("the Shikai rate sits at the end-of-match ceiling") and r2 b1_a0 (the gated lunge) read in full;
  - round 3: b0_a0, b2_a0, b3_a0 and the parent b1_a0, the parent and b3_a0 in full.
- **Siblings b0_a1 and b3_a1** were still empty when I finished.
- **Round 3 so far.**
  - All four a0 cells found the same leak independently: his slow NS starts feed her timed perfect Hoho.
  - b3_a0 (0.8609, 80/80) reads her as busy or locked out, and has the meaty out of her wake-up Hoho's reach and J1 onto her Hoho's end.
  - The parent (0.828) has the Step in, the wake-up bait, his own wake-up Hoho and the perfect follow-up.
  - The parent has no Hoho-end J1, so that is the piece this cell ports.

## Diagnosis (the parent file, HARD, matchup-eval's own sim commands with the logs kept, seeds 1-60 a seat = "P60")
- **Every shikai failure is the last stay of a match** (seeds 1-20: 19 of 19).
  - A stay succeeds once L3 and J4+ land. The climb leads into the Bankai, so the Bankai entry always succeeds.
  - The stay that opens on the return from the Bankai starts at L0, and the match usually ends in it: he wins at L0-L2, often with a red
    pointer-2 AS2 Kikon. All 16 of his losses in H60 came in the Shikai, 13 of them in that post-Bankai stay.
  - So the rate is about k / (k + 1) for k Bankai cycles, unless the match ends inside the Bankai.
  - The rate rises only if the match ends in the Bankai, or there are more cycles. Declining a kill would be keyed to the detector, so
    I left it out.
- **His Shikai is where she wins.** Her combo openers by his form (seeds 41-80), with the Reishi she then dealt:

  | His form | Her openers | Reishi |
  |---|---|---|
  | Shikai | 384 | 229k |
  | sealed | 94 | 33k |
  | Bankai | 49 | 19k |

  The Shikai openers break down as:
  - COUNTER off his N1A lunge: 90 openers, 77k;
  - her KESSA J1: 127, 72k;
  - clone hits: 119, 60k.
- **KK-PICK's Shikai lunge where J1 also reaches** first-hit his 88 / hers 40 from 2.0-2.5 m, and his 46 / hers 60 from 3.0 m. The
  climb's lunge first-hit 68 / 72.
- **The pointer-2 AS read bursts into her clones.**
  - His Shikai J is CANCELled by her KESSA NS3a, a clone segment with no hit of its own.
  - `*kk-as-read-p*` then presses SP after J1 / J2 at pointer 2: the burst to pointer 1, L reset to 0. The clone hits him anyway.
  - 43 bursts in seeds 41-80, 33 clone openers after them.
- **The Shikai perfect follow-up's clock** (`kk-pf-on`).
  - His perfect is seen only on his next free step. Against her meaty J1 (it lands on the Hoho's frame) that step is 38 frames later,
    so the 36-frame window opens when her 40-frame lock has 2 frames left.
  - The Shikai pf-on J1 (S9) first-hit his 192 / hers 87.

## The mechanism (the delivered file)
**`*kk-hend-p*` (0 / 0 / 1.0, one roll per Hoho of hers he sees) and `*kk-hend-lead*` 0.**
- Ported from b3_a0, credited.
- J1 is timed to land on her Hoho's last frame: its start (`kks-ho`, which the parent already read from the SNAP) + 24 − J1's startup.
- After a Hoho she reappears behind him, and her next Hoho is shut for 60 frames.
- A new `:hend` plan in `kk-wave-step`.
- It does not fire on the wake-up Hoho the parent's bait already answers (`kks-bait`).
- In H60 (seeds 1-60 a seat) it was planned 156 times and pressed 131 times; the J1 first-hit his 102 / hers 14 / none 12.

Rules:
- One roll per event, SIM-RND01 only, NORMAL 0, so NORMAL is unchanged (0.9375).
- She is read through the SNAP only. The file registers only Kenpachi against Ichigo.
- Host tests: 9843 checks, ALL PASS.

## Measurements (`raw` = 0.4 strength + 0.6 signature, HARD only; each variant against the parent on the same seeds)

| Variant (seeds 1-60 a seat unless noted) | raw | HARD | brawl | shikai | bankai |
|---|---|---|---|---|---|
| parent b1_a0 (P60) | 0.8204 | 102/120 | .940 | .689 (144/209) | .773 |
| A: no AS read on a clone segment (bursts 43 → 6) | 0.8211 | 104/120 | .940 | .646 | .786 |
| C: `*kk-lunge-p*` HARD 0.5 → 1.0 | 0.8175 | 101/120 | .940 | .688 | .776 |
| cash-outs 0 → 9 | 0.7803 | 103/120 | .940 | .756 | .489 |
| cash-outs 0 → 1 (seeds 1-20) | 0.817 vs 0.8293 | 34/40 | .944 | .768 | .673 |
| pf-on timed from his Hoho (J1 only while she is locked) | 0.6645 | 64/120 | .935 | .625 | .696 |
| same, a back Step in the Shikai when late | 0.6785 | 68/120 | .940 | .601 | .718 |
| J1 first in the Shikai, never the lunge | 0.7977 | 98/120 | .940 | .723 | .692 |
| + Step in before the lunge | 0.7721 | 94/120 | .940 | .668 | .686 |
| **H: + J1 onto her Hoho's end (delivered)** | **0.8289** | **104/120** | .938 | .678 (143/211) | **.795** |
| H + the Shikai lunge gated, busy / lockout read (b3_a0's) | 0.8039 | 101/120 | .936 | .697 | .703 |
| H + the busy read on the sealed gate only | 0.8049 | 97/120 | .936 | .695 | .777 |
| H + the Step-in J1 reach check (b3_a0's) | 0.8221 | 103/120 | .938 | .665 | .791 |

What the variants showed:
- **The cash-outs move shikai and bankai against each other.** Kills inside the Bankai come by J / KYORAN AS / NS segments, not the
  special AS. They fail 卍解爆發 and spare a final Shikai stay. Every count lost more than it gained.
- **The pf-on J1 at 38 frames is a gamble that pays.** Two out of three land. Anything else at that frame let her loop run (HARD 102
  → 64-68).
- **A is a located fix that ties.** It stops L resets, but with the burst gone he is hit by the clone or by her J1 instead. Shikai fell on
  both samples, so it was not kept.

**Held-out seeds 61-120 a seat** (never looked at while choosing):

| File | raw | HARD | brawl | shikai | bankai | antiwave |
|---|---|---|---|---|---|---|
| parent | 0.776 | 90/120 | .933 | .736 (145/197) | .711 | 0/0 |
| **H** | 0.8389 | **99/120** | .938 | .736 (145/197) | .719 | 1/1 (without it: 0.809) |

**The evaluator, 40 seeds a seat, NORMAL included** (the delivered file; this exact line is in score.json):

`{"side": "ken", "seeds": 40, "strength": 0.8625, "signature": 0.7975, "excluded": ["antiwave"], "themes": {"brawl": {"rate": 0.937, "ok": 1701, "occ": 1816}, "shikai": {"rate": 0.688, "ok": 97, "occ": 141}, "bankai": {"rate": 0.768, "ok": 86, "occ": 112}, "antiwave": {"rate": 0.0, "ok": 0, "occ": 0}}, "hard": "69/80", "normal": {"share": 0.9375, "band": [0.863, 1.0], "factor": 1.0, "matches": 80}, "raw": 0.8235, "score": 0.8235}`

- On seeds 1-40 that is a tie with the parent's 0.828: HARD 69 against 68 of 80, shikai .688 against .719, which is inside the ±0.03
  draw.
- Over seeds 1-120 (240 matches a file), H won 203 against the parent's 192.

## Why it is not a repeat
- The Hoho-end J1 is b3_a0's, and this is the first time it is combined with the parent's pieces: the Step in, the bait, the wake-up
  Hoho and pf-on. The two answers to her wake-up Hoho are kept apart: the bait covers it, and hend skips it.
- The diagnosis is new: the shikai failure structure, her openers by his form, the clone burst, and the pf-on clock. So are the eleven
  variants. The cash-outs were last tried at the first freeze, before a K.O. by the special AS counted.

## Expected benefit and risks
- **Benefit.** About +0.02-0.05 strength over many seeds (held-out +9 of 120). The signature stays the same.
- **Shikai.** Unchanged, at the k / (k + 1) end-of-match ceiling.
  - What would move it: more Bankai cycles a match, or fewer losses in the post-Bankai stay (13 of 16 losses there, H60).
  - Her KESSA game against his Shikai (lunge counters, clones, her S8 J1 against his S9) is where the next cell should look.
- **Risk.** The rescore at 40 seeds may land slightly under the parent: the seeds 1-40 draw favoured the parent's shikai.
