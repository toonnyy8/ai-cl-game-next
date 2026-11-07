# b0_a1 (round 3, 封印肉搏, parent b0_a0): no move on a SNAP that predates a cinematic or a Burst, turn before the follow-up J1, and the Hoho-end J1

Direction: 封印肉搏 (brawl), keeping the other three themes usable. Parent: round 3 b0_a0 (0.7892 at 40 seeds; reproduced at 20 seeds a
seat as 0.7952, HARD 35/40). Opponent: Ichigo's champion. Only `duel/lisp/cpu-ki-ken.lisp` changed. Every new knob is a `defparameter`
whose docstring gives its evidence.

The worktree was at 7c5e696, not the freeze cee7bd6. `git diff --stat cee7bd6 HEAD` touches only `docs/`, so the evaluator and the game
code are the freeze's.

## History read
- **Rounds 1–2, all 15 cells.** I read each one's headline and score.rescored.json. Every big step came from a located bug or a missing
  follow-through: the AS read, the Kikon rules, the FS budget, `kk-link` / `kk-as-on`, the meaty. Knob drift gained little.
- **Baseline** (round 2's champion against her new champion): 0.2872, HARD 3/80. Her timed perfect Hoho is behind it.
- **Round 3 siblings**, each proposal in full with its rescore:
  - b0_a0 (my parent), 0.7892: the NS gate, the dodge on time, the wake-up Hoho, the follow-up after his perfect Hoho, the meaty out of
    her 2.2 m, the Step-in J1.
  - b1_a0, 0.828: the same gate plus the wake-up bait; the Shikai lunge ungated.
  - b2_a0, 0.7122: the gate, the wake-up Hoho and the clone hold. Its J1 gate left the Shikai with nothing to do.
  - b3_a0, 0.8609 (80/80): the gate with a persistent lockout read, the J1 onto her Hoho's end (`:hend`), and the wake bait.
  - b3_a1 (antiwave, parent b3_a0) landed as I finished: 0.8609, 80/80, brawl .931; no NS into a wave already out. I read its headline
    and rescore only. b1_a1 was still empty.
- **What I took.** b3_a0's lockout tick and `:hend` are ported here (credited in the docstrings). They are combined with the parent's
  follow-up pieces, which b3_a0 lacks. b3_a0's wake bait was tried here and dropped (below).

## Diagnosis (parent file, HARD, 20 seeds a seat, logs from the frozen evaluator's own `run`)
- **The sealed form is already won against her sealed form.** In BASE vs BASE she dealt 500 Reishi in 40 matches; he dealt 147k.
- **Brawl failures, 40 of 290, all but 3 against KESSA** (he is still sealed after she awakens). By what came just before:
  1. **A J1 on a SNAP from before a cinematic.** She awakened during his meaty J1. On the cinematic's last frame KK-PICK pressed
     `J1 at 1.8`, but she was really at ~2.4 m (her own view said 2.4). The J1 whiffed into her whiff-confirm J1, or her N1A punish.
     The perceived SNAP is 8 frames old, and the brain is not stepped through a cinematic.
  2. **The follow-up J1 after his perfect Hoho.** Every one came 37–38 frames after the perfect, once her J1 (which lands on the
     Hoho's own frame) had let him out of hitstun. Most of the failures whiffed into her confirm J1 (counts below). The Hoho
     puts him behind her, he does not turn in hitstun, and the J1 (arc 100°, 6°/frame of tracking during its 6–9 frame startup) swings
     past her. On the parent's file (v0 logs) 17 of 93 pf J1s were hit first; with the sealed J1 it was 6 of 10.
- After fixing 1, a KK-PICK clog (logging only) showed the next leak:
  3. **A J1 into her Burst.** 77 of the sealed form's 111 KK-PICK J1s (v3 logs) were at a perceived 1.5 m, and every one of the 77
     had her BURST BLUE within the 12 log lines before it (pressed ~11 frames after it).
     Only 9 hit, and 21 were punished. REPEL! ends his move, makes her invulnerable for 20 frames, and slides him 5 m away over 20.
- **His Shikai lost to KESSA**: she dealt 77k, he dealt 57k. The losses (5/40) were his Shikai / second Bankai against KESSA.

## Mechanism (HARD only. Every chance and rule is 0 / NIL at EASY and NORMAL; SIM-RND01 only; one roll per event)
1. **`*kk-cine-wait*` (rule, HARD t), `*kk-cine-gap*` 60.** If the style has not run for more than 60 ticks, a cinematic has just
   ended. The brain is not stepped through one, and his longest lock, the perfect lock, is 40. He then takes no decision for his
   perception delay, and holds still. The generic CPU is not handed those steps either.
   - Read from his own side only, never from her gauge (which is not in the SNAP).
2. **`*kk-repel-wait*` 20, the same rule.** He drops from `:move` to `:idle` before his move's last frame (REPEL!: her Burst or her
   awakening). He then takes no decision for 20 frames: her invulnerability, and his 5 m slide.
3. **`*kk-face-max*` 60°.** The follow-up J1 after his perfect Hoho (`kk-pf-step`) and the Hoho-end J1 are pressed only while he faces
   her within 60°. Otherwise he stands still for the 18°/frame idle auto-turn and presses once turned.
4. **From b3_a0:**
   - **`*kk-hend-p*` (0 / 0 / 1.0), one roll per Hoho of hers.** A J1 timed to land on her first free frame after her Hoho.
   - **`*kk-hoho-lockout*` 84 (KKS-HL).** The NS gate now reads her Hoho's lockout from its start (24 + 60), also after she reappears.
     The parent used 60, and only while she was seen in `:hoho`.
- Rules: she is read only through the SNAP and the distance. His own move frame, his facing and the ticks between his own steps
  supply the rest. Nothing is keyed to the evaluator. The file registers only Kenpachi against Ichigo.

## Measurements
Rows v0–v5: HARD only, 20 seeds a seat, paired, with the frozen evaluator's `run` / `parse` (raw = 0.4 strength + 0.6 signature, antiwave
out when 0/0). Each row adds to the one above.

| Variant | HARD | raw | brawl | shikai | bankai | antiwave |
|---|---|---|---|---|---|---|
| v0 parent (full eval, 20 seeds: 0.7952) | 35/40 | 0.7952 | .862 (250/290) | .700 (42/60) | .739 (34/46) | 2/3 |
| v1 + lockout tick + `:hend` (+ KK-PICK clogs) | 33/40 | 0.7667 | .865 | .656 | .723 | 2/3 |
| v2 + facing for pf / hend, cine wait (keyed on `brain-was`) | 39/40 | 0.8391 | .882 (254/288) | .676 | .769 | 2/3 |
| v3 cine wait keyed on the tick gap (`brain-was` never shows `:cine`) | 37/40 | 0.8391 | .855 (259/303) | .765 | .726 | 0/0 |
| **v4 + repel wait (delivered)** | **39/40** | **0.8734** | **.946 (262/277)** | .638 (44/69) | **.833 (40/48)** | 0/0 |
| v4 without `:hend` | 39/40 | 0.8559 | .946 | .629 | .755 | 0/0 |
| v4 without the lockout tick (the parent's gate) | 39/40 | 0.8759 | .946 | .632 | .851 | 0/0 |
| v5 = v4 + b3_a0's wake bait (Shikai meaty J1 → wait in her 2.2 m) | 39/40 | 0.851 | .946 | .667 | .692 | 0/0 |

- **v1 was noise.** His sealed damage was identical. Every pf J1 then whiffed or hit for the same facing reason.
- **v2:** the pf J1 landed 73 of 73 (v1: 65 of 84). Her damage on his Shikai fell from 77k to 58k.
- **v2's cine wait never fired.** `brain-was` is not `:cine` on the first free step. In v3, keyed on the tick gap, it fires.
- **v4:**
  - her damage on him while he is sealed against KESSA went 13.6k → 2.9k;
  - his Shikai against KESSA went from 57k / 77k (his / hers) to 60k / 42k;
  - the sealed KK-PICK J1 into her Burst is gone: at v4 the sealed KK-PICK presses 11 J1s (8 hit, 3 hit first), against 111 at v3;
  - brawl failures 15 of 277; the largest class is 6 Step-in J1s beaten by her J1 (KESSA's S8, or her sealed J1).
- **The lockout tick is neutral** at 20 seeds (0.8759 against 0.8734). It stays because `:hend` needs the tick for its new-Hoho test.
- **The wake bait works mechanically, but costs bankai.**
  - Mechanically: the Hoho-end J1 landed 48 times, and her Shikai damage went 42k → 33k.
  - At 40 seeds: bankai .723 against .83, score 0.8541 against 0.8811. Dropped.

**40 seeds a seat (EVAL_COMMAND):**

| | baseline | parent b0_a0 | b3_a0 (sibling best) | v5 (dropped) | **v4 (delivered)** |
|---|---|---|---|---|---|
| score | 0.2872 | 0.7892 | 0.8609 | 0.8541 | **0.8811** |
| HARD | 3/80 | 71/80 | 80/80 | 77/80 | **79/80** |
| brawl | .272 | .849 (596) | .931 (551) | .954 | **.954 (535/561)** |
| shikai | .337 | .672 (119) | .646 (130) | .669 | .647 (88/136) |
| bankai | .706 | .707 (92) | .727 (99) | .723 | **.83 (78/94)** |
| antiwave | 1/2 | 2/3 | excluded | excluded | excluded (0/0) |
| NORMAL | .9375 | .9875 | .9375 | .9875 | .9875 (band .863–1.0, factor 1) |

score.json (the delivered file's 40-seed line):
`{"side": "ken", "seeds": 40, "strength": 0.9875, "signature": 0.8102, "excluded": ["antiwave"], "themes": {"brawl": {"rate": 0.954, "ok": 535, "occ": 561}, "shikai": {"rate": 0.647, "ok": 88, "occ": 136}, "bankai": {"rate": 0.83, "ok": 78, "occ": 94}, "antiwave": {"rate": 0.0, "ok": 0, "occ": 0}}, "hard": "79/80", "normal": {"share": 0.9875, "band": [0.863, 1.0], "factor": 1.0, "matches": 80}, "raw": 0.8811, "score": 0.8811}`

Host tests: 9843 checks, ALL PASS.

## Why it is not a repeat
- **The nearest priors are round 2 b0_a1's.** It had a stale-SNAP rule of its own: patience while she is seen in a Hoho she has not
  reappeared from. Its docstring also records "a wait after her Burst / awakening repel", tried there and dropped: standing gave brawl
  0.797, walking in 0.814, against her older champion and without the rest of this file.
  - Here the repel wait is different in what it keys on: his own move cut short, detected from his own move frame, for exactly the
    20 frames of her invulnerability and his slide.
  - It is measured against her current champion, whose Burst was behind 77 of 111 sealed KK-PICK J1s. v3 → v4: brawl .855 → .946,
    raw 0.8391 → 0.8734.
- No earlier cell detects the end of a cinematic (a grep of every round 1–3 Kenpachi file for `yaw-of`, `face-yaw`, `repel`, `:cine`
  and `brain-was` finds only b1_a0's wake-up use of `brain-was` and the r2 b0_a1 note above).
- No earlier cell checked **his facing** before a J1. The parent's pf follow-up and b3_a0's `:hend` both press J1 with him possibly
  facing away.
- `:hend` and the lockout tick are b3_a0's, ported as a combination: b3_a0 has no pf follow-up and no wake-up Hoho, and the parent has
  no `:hend`. The ablation shows `:hend` pays here (bankai .755 → .833 at 20 seeds).

## What is left
- **Shikai .65 is the end-of-match ceiling.** Every failed stay at v4 is one the match ended in, mostly at L1–L2: the brawl now leaves
  her little life for the climb. Shaping kills around the detector is off limits, so I left it.
- **Her clones and her KESSA J1 against his Shikai NS2a.** Pointer 2's 1.4 m hilt, from KK-PICK: 39 hit, 13 lost or perfect-Hoho'd.
- **Antiwave did not come up** in any 40-seed run (0/0, excluded).

## Risks
- **The tick-gap test assumes the brain is not stepped through a cinematic,** and that no lock lasts over 60 ticks. A rule change there
  makes it fire on a long lock: an 8-frame wait.
- **The repel wait** also fires on any other cut-short move of his, costing 20 frames of neutral.
  - CORE-BRAIN-STEP skips the style while a press is held (`brain-press-left` > 0), so KKS-MSF can lag his real move frame.
  - A move that ends naturally under a held press can then read as cut short. The likeliest case is an SP held into a Kikon when she
    is red.
  - The 40-seed result includes that cost.
- **`*kk-face-max*` 60°** is a margin under the J1's measured 86° (sealed) / 104° (Shikai) reach of facing. Untuned.
- **NORMAL is unchanged in behaviour.** Every new rule is HARD-only, and BRAIN-ROLL draws nothing at 0. NORMAL measured 0.9875.
