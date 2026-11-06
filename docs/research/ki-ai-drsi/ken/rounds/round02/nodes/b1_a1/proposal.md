# b1_a1 (round 2, 解放攀升, parent b1_a0): b1_a0's Shikai + Bankai pieces combined with b0_a0's sealed follow-through; one Shikai mechanism tried and dropped

Direction: 解放攀升 (shikai), keeping the other three themes usable.
- Parent: b1_a0 (0.8755).
- Opponent: Ichigo's champion.
- Only `duel/lisp/cpu-ki-ken.lisp` changed.
- The worktree is at 3d98bfa, not the freeze 2605e96. `git diff --stat 2605e96 3d98bfa` touches only `docs/research/ki-ai-drsi/`.

## History read

Every score.json and score.rescored.json. What I read of each proposal:
- the round-2 siblings b0_a0, b1_a0 and b3_a0: whole or nearly whole;
- the baseline, b2_a0 and the eight round-1 cells: their opening sections only (title, history, diagnosis), plus the tables the other
  cells give of them;
- b0_a1 and b3_a1 of round 2 were still empty when I finished.

| Cell | Rescored | Mechanism | Relevance here |
|---|---|---|---|
| round 1, all 8 | 0.41-0.876 (first freeze) | b3_a1 = everything combined = the baseline | method: big steps came from located bugs and missing follow-through |
| baseline (b3_a1, 2nd freeze) | 0.8334 | | brawl .681 is the weak theme against her champion |
| r2 b0_a0 | **0.9213** | sealed follow-through: KK-LINK, KK-AS-ON, meaty 1.0, dodge 1.0, Hoho-in off | brawl .874, HARD 80/80; shikai .851, bankai .75 (he wins sooner); antiwave 1/1 |
| r2 b1_a0 (parent) | 0.8755 | gated lunge 1.0 + lunge pick over J1 (s-ns) + b2_a0's Bankai lunge / SA | shikai .913, bankai .860, brawl .681 untouched |
| r2 b2_a0 | 0.8698 | Bankai NS-a lunge into her hover, SA in its gap | grafted into the parent already |
| r2 b3_a0 | 0.887 | `kk-far` Hoho at her pointer 2, the Step-held edge fix, `:close` 1.0 | antiwave; b0_a0 found it idle on the strong-brawl base |

The parent's pieces and b0_a0's pieces touch different forms: Shikai and Bankai in the parent, sealed in b0_a0.
- b0_a0 already merged b2_a0's Bankai lunge / SA and b3_a0's pieces into its file. That merge scored 0.9172 at 20 seeds, was called
  "nearly idle" from its firing counts, and was not delivered.
- No cell had put b1_a0's Shikai pieces with b0_a0's sealed play.

## Mechanism (the delivered file = v1)

**b0_a0's sealed follow-through grafted verbatim onto b1_a0's file.**
- The pieces: `*kk-link-p*`, `*kk-as-on-p*`, `*kk-link-margin*`, `kk-link-reach`, `kk-link`, `kk-as-on`.
- Knob changes: `*kk-dodge-p*` HARD 0.8 -> 1.0, `*kk-meaty-p*` HARD 0.7 -> 1.0, `*kk-hoho-in-p*` 0 / 0 / 0.
- The diff applied with `patch` except two hunks: the header and the style dispatch. Those were merged by hand.
- The `:move` chain is now `kk-l3-sa`, `kk-bk-sa`, `kk-move`, `kk-link`, `kk-as-on`, `kk-ns-whiff`.
- b1_a0's Shikai pieces (the gate, lunge 1.0, s-ns) and its Bankai graft from b2_a0 are unchanged.

Every rule holds:
- one roll per event, SIM-RND01 only, EASY <= NORMAL <= HARD;
- she is read through the SNAP and the distance only;
- the style registers only for Kenpachi against Ichigo.

Host tests: 9843 checks, ALL PASS.

## Measurements

40 seeds a seat, the same seeds (EVAL_COMMAND for the final row; the same command line otherwise):

| File | score | HARD | brawl | shikai | bankai | antiwave | NORMAL |
|---|---|---|---|---|---|---|---|
| baseline, rescored | 0.8334 | 74/80 | .681 (904/1328) | .930 (185/199) | .812 (156/192) | 2/3 | .9125 |
| b1_a0 (parent), rescored | 0.8755 | 79/80 | .681 (904/1328) | .913 (199/218) | .860 (178/207) | 3/4 | .9125 |
| b0_a0, rescored | 0.9213 | 80/80 | .874 (541/619) | .851 (126/148) | .750 (105/140) | 1/1 | .9375 |
| **v1 = final (score.json)** | **0.9211** | **80/80** | .874 (541/619) | .836 (127/152) | .764 (107/140) | 1/1 | .925 (factor 1) |
| v2 = v1 + the Shikai trap (dropped) | raw 0.7556 | 80/80 | .874 | .764 (110/144) | .733 (96/131) | **0/0** | .925 |

**Held-out HARD seeds 41-140, both seats.** Each file played 200 matches. The command line is the evaluator's, with only 30000+seed0
changed. Damage taken is per his form, summed over both seats.

| File | HARD | brawl | shikai | bankai | antiwave | damage taken in Shikai | in Bankai |
|---|---|---|---|---|---|---|---|
| b0_a0 | 200/200 | .863 (1320/1529) | .889 (327/368) | .767 (266/347) | 1/2 | 137087 | 18138 |
| v1 | 200/200 | .863 (1320/1529) | .885 (331/374) | .773 (272/352) | 1/1 | 134569 | **2774** |

**The play gains, the score does not.**
- On top of the strong brawl, the parent's pieces cut the damage he takes in a Bankai by 85 % (b2_a0's Bankai lunge / SA) and in the
  Shikai by 2 %.
- He already wins every match (80/80, 200/200), so strength cannot rise.
- The theme rates are equal within the draw. The 40-seed score is the same as b0_a0's (0.9211 against 0.9213).
- The real evidence is the held-out table.

## Shikai finding: the rates sit at the end-of-match ceiling

Every shikai and bankai failure is the match's last situation, in each log I checked: v1 at 20 seeds, 13 / 13 shikai and 18 / 18 bankai
failures closed at the K.O.

How the matches ended (v1, 20 seeds a seat, 40 matches):

| Matches | Ending | Situation that fails |
|---|---|---|
| 11 | K.O. by the Bankai's special AS (KE-KR-SP) | none |
| 11 | K.O. in a Bankai by J1-J5 | bankai |
| 2 | K.O. by the Bankai entry hit | bankai |
| 13 | K.O. in a Shikai stay before J4 (the lunge, J1 / J2, an AS, the SA) | shikai, and bankai too if L3 was reached |

- A stay counts only if L3 is reached and J4+ lands. L rises once per combo (`ken-hit`), and the NS segments open by the L read at the
  route's start (`core-seg-ok-p`).
- So a failing stay is simply a match he won before the third climb combo. Nothing went wrong in the climb.
- Changing which hit lands the K.O. would change only what the detector sees, so I left it alone, as b1_a0 and b0_a0 did.
- What lifts the Shikai and Bankai rates is more stays per match (b1_a0's weaker brawl: 2.7 stays a match; here 1.9). A faster win
  costs those two rates.
- Antiwave opens about once in 40 seeds a seat on this base. A run where it never opens scores the theme 0 and loses about 0.15.

Her combo openers in his Shikai (held-out v1): 364 openers, 134.6k damage.

| Her opener | Count |
|---|---|
| IC-K-J1 | 129 |
| clone strike (IC-HIT) | 77 |
| perfect-Hoho COUNTER | 52 |
| IC-K-N1A | 47 |

- They mostly follow his `kk pick ns1` lunge (172 openers).
- The clone hits I traced start inside his perception delay: her NS3a, then his pick 1-7 frames later, then the clone on her f15. That
  is reaction-limited, not a bug.
- From 1.5-2.5 m the pick lunge lands 210 times and loses first 52 times (v1, 40 seeds).
- From 4.0-5.0 m the lunge is a coin flip: 18 landed, 15 lost first.

## Tried and dropped: the Shikai trap (v2)

**The mechanism (new, not in any earlier cell).**
- After his Shikai NS route ends on a landed segment below L3 (NS1b at L1, NS1c at L2, the next segment shut by the route's L), he
  pressed J1 on the first free step.
- NS1b / NS1c leave him +2, and her KESSA J1 reaches only 1.56 m. So J1 J2 + AS1 starts a new combo, and AS1 (`:lv-up`) raises L
  again.
- Before it, the generic CPU's next decision came 20-50 frames later and was a fresh lunge.
- One roll per segment, HARD 1.0, NORMAL 0.

**What happened.**
- It worked as a tool. The trap J1 fired 139 times. In the KI seat's 71, J1 landed 47 times; she perfect-Hoho'd 21, 8 of them into a
  COUNTER.
- But faster Shikai damage means more K.O.s in the Shikai before J4: shikai .836 -> .764, bankai .764 -> .733.
- Antiwave never opened: 0/0, raw 0.7556.

**Removed.** This confirms the ceiling above: a stronger Shikai lowers its own theme rate against this opponent.

## Why it is not a repeat
- b0_a0 already tried b2_a0's Bankai pieces on its file (0.9172 at 20 seeds, not delivered). New here: b1_a0's Shikai pieces in the
  combination.
- New evidence: the held-out run shows the Bankai graft is not idle on the strong-brawl base. b0_a0's firing counts could not show this.
  - The Bankai damage taken falls from 18.1k to 2.8k over 200 matches.
  - Brawl is byte-identical, and the Shikai rate is equal.
- The round-2 siblings b0_a1 and b3_a1 were empty when I finished, so I could not check them for the same graft.
- The trap is a new Shikai mechanism. It was measured and dropped, with the reason.

## Expected benefit and risks
- **Expected on rescore:** 0.9211, deterministic on the same seeds. That equals b0_a0, not above it.
  - The gain is in play quality: the far smaller Bankai damage, and a sturdier style if her side improves.
  - The score does not show that gain while he wins 80/80.
- **Antiwave 1/1 is fragile.** On another seed set it could open 0 times; the held-out run opened it 1 time in 200 matches.
  - I added no rule aimed at her 3.6-6.6 m band, since that would be keyed to the detector.
- **NORMAL** 0.925 is inside the band. b0_a0's NORMAL chances (`*kk-link-p*` 0.3) carry over.
- **For the coordinator:**
  - The Shikai direction looks spent against this opponent. Its failures are end-of-match wins.
  - Further Shikai cells are unlikely to move the score unless the evaluator changes or a stronger Ichigo lengthens matches.
- **Detector quirk, repeated from b1_a0 and not coded around:** a stay won by KE-S-J4 itself still fails shikai. v1's 20 seeds have
  one: a K.O. on KE-S-J4 marked as both a shikai and a bankai failure.
