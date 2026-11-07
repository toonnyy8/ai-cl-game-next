# b2_a1 (round 3, Ichigo): pointer 3's lunge on the Step tell. Level with the parent; the NS3b chase was refuted by trial

Direction: 指針三狩魂 (ptr3), keeping the other three usable. Parent: round 3's b2_a0 (bait hover, k-SA dodge stop; 0.8517 at 40 seeds,
rescored 0.8517). Opponent: `ken/champion/cpu-ki-ken.lisp`. Only `duel/lisp/cpu-ki-ichigo.lisp` changed.

**Result: no gain.** The final file measured 0.8477 at 40 seeds against the parent's 0.8517. Spacing went up (0.071 → 0.115), but whiff
went down (0.983 → 0.966) and HARD went from 80/80 to 79/80. The mechanism is HARD only and sits behind one knob (`*iks-tell-p*`; HARD 0
gives back the parent). I deliver it as a measured negative node, not as a candidate champion.

## History read
- I read every round-1 / round-2 score.rescored.json, and the titles and summaries of their proposals. I grepped all proposals for
  `n3b|NS3b`. The only hits are about *his* NS3b, so no cell ever used her NS3a → NS3b.
- In full: the parent b2_a0, and round 3's b0_a0 (shut-gauge lunge, 0.8387), b1_a0 (hold ground, 0.8407) and b3_a0 (disciplined KESSA,
  0.8343) in their summary, mechanism and measurement sections.
- Pointer 3 is saturated: ptr3 is 0.99–1.0 in every cell since round 1. Whiff and KESSA sit at 0.96–0.98, and strength is 1.0. Spacing
  (0.07) is the only theme with room, so a ptr3-led cell can only pay through pointer 3's spacing tool, the NS3a lunge (5.0–5.1 m, R5).
- Every earlier lunge lost to his read (`kk-read`): the Hoho when one is open, otherwise the back Step within `*kk-step-max*` 5.0.
  b0_a0 got past it by reading his flash-step gauge off the HUD, which still waits for the coordinator's ruling. b0_a1 builds on b0_a0.

## Diagnosis (parent, 20 seeds a seat, HARD; scratch observer = b2_a0's `sx` copy of situ.lisp)
- Spacing pools (ok / occ):
  - **dead pools, 79 of 262**:
    - far sealed pointer 1 vs sealed, 0/46: the match start, where pointer 1 has no 4 m tool;
    - far sealed pointer 3 vs sealed, 0/33: the reset after her own Soul Break. His awakening cinematic follows shortly after and
      flushes the situation as a failure. The window is too short to close 3 m and lunge.
  - mid KESSA pointer 3 vs his Shikai: 14/53 (the far k-lunge).
  - mid sealed pointer 3 vs his Shikai: 2/32. Every one of these closes the same way: his TOSSHIN, her perfect Hoho, the counter (not
    a move start, so it can't count), then the follow-up J1 at 1.5 m.
- His flash-step is under 100 in 40–50 % of hash samples while she is at pointer 3 (so a blind lunge meets an open Hoho about half the
  time).

## Step A: the NS3b chase (refuted by a scripted trial, no eval spent)
The idea: when his back Step dodges her NS3a, she continues into NS3b (S18, arc 2.6 + 4.0 slide, reach 6.6 m) instead of stopping
(`*iks-ns-stop*`). His Step alone means his Hoho is shut.

Trial `scratchpad/ki-ichigo-b2_a1/r3/t-n3b.lisp` (`tools/combo-trial.py`; his Step through `:p2-press`):
- The latched NS3b starts at NS3a f30 and hits at f48. After his Step from 4.0–5.0 m it connects for 100 (A1–A4).
- A second Step of his around NS3a f35 dodges it (A6).
- His read Steps again whenever her NS3b start reads as ≤ 5.0 m to him. In play, her perceived 5.0 m lunges start at a true 4.3 m,
  because he walks in during her 8 blind frames. His read comes at 3.8 m, and NS3b then starts at about 4.4 m, inside his Step range.

So the chase works only for lunges whose true start is 4.85–5.0 m, a window that sealed play almost never offers. Dropped.

## Step B: the control, the lunge alone
`*iks-patient-lunge*` T on the parent (round 2's c6 replayed on the bait hover), 22 lunges:
- his read answered 14 with the back Step and 6 with the Hoho;
- raw 0.8493 against 0.8507, spacing 0.083. Level.

## Step C: the mechanism, pointer 3's lunge on the Step tell (the final file)
- **The tell** (`iks-tell-watch`, every call, SNAP-only):
  - his back Step seen starting while her own move is live. KK-READ Steps only when no Hoho is open, so this means his Hoho is shut;
    it holds `*iks-tell-window*` 300 f;
  - his Hoho seen starting means it is locked; that holds `*iks-tell-lockout*` 48 f.

  One roll of `*iks-tell-p*` (0 / 0 / HARD 0.9) per tell.
- **The lunge** (`iks-tell-lunge`, in `iks-neutral` after pointer 2): pointer 3, her form in `*iks-tell-forms*` (:base), episode mode in
  `*iks-tell-modes*` (:space :ptr3).
  - She dashes back to `*iks-tell-wait*` 6.5 (+0.3) and stands.
  - She lunges as he walks in, with b0_a0's geometry (`*iks-tell-band*` (5.25 5.1 18) and the closing speed `iks-closing`, copied from
    b0_a0): his read lands beyond 5.0 and NS3a still reaches him. One lunge per tell.
  - A Hoho tell does not set up the dash (`*iks-tell-hoho-setup*` NIL): 48 f is too short.
- Rules:
  - no flash-step gauge read: only his SNAP state, positions and the perceived distance;
  - one roll per tell, HARD only, so NORMAL is unchanged (0.075, factor 1);
  - randomness through `brain-roll`;
  - every knob is a `defparameter` with a docstring;
  - host tests 9843 ALL PASS.

## Measurements (paired seeds 1–20 a seat, HARD only, scratch runner = matchup-eval's parse)
| Variant | raw | HARD | spacing | whiff | ptr3 | kessa |
|---|---|---|---|---|---|---|
| parent b2_a0 | 0.8507 | 40/40 | 0.069 (18/262) | 0.986 | 1.0 | 0.95 |
| L1 = lunge alone (`*iks-patient-lunge*` T) | 0.8493 | 40 | 0.083 (24/290) | 0.987 | 1.0 | 0.925 |
| T1 = tell, both forms, every mode, Hoho tells set up too | 0.8002 | 39 | 0.145 (65/449) | 0.815 | 1.0 | 0.775 |
| T2 = T1, Hoho tells don't set up | 0.8407 | 40 | 0.182 (54/297) | 0.931 | 1.0 | 0.825 |
| T3 = T2, sealed form only | 0.8485 | 40 | 0.160 (48/300) | 0.955 | 1.0 | 0.875 |
| **T4 = T3, :space / :ptr3 episodes only (final)** | **0.8532** | 40 | 0.103 (29/282) | 0.969 | 1.0 | 0.95 |

- In T1, tells fire often (195 Step, 311 Hoho in 40 matches), and the backing off (424 dashes) is what costs:
  - whiff, because she leaves the bait hover, where his NS1a comes into her timed Hoho;
  - KESSA's ledger: the KESSA k-lunges on the tell repeat round 2's b3_a0 and b2_a0's K1 finding.
- Each restriction gives back whiff and KESSA and takes back spacing. At T4 the 20-seed gain (+0.0025) is inside the noise.

**Final, 40 seeds a seat (EVAL_COMMAND, score.json):**
`{"side": "ichigo", "seeds": 40, "strength": 0.9875, "signature": 0.7546, "excluded": [], "themes": {"spacing": {"rate": 0.115, "ok": 66, "occ": 573}, "whiff": {"rate": 0.966, "ok": 618, "occ": 640}, "ptr3": {"rate": 1.0, "ok": 195, "occ": 195}, "kessa": {"rate": 0.938, "ok": 75, "occ": 80}}, "hard": "79/80", "normal": {"share": 0.075, "band": [0.0, 0.138], "factor": 1.0, "matches": 80}, "raw": 0.8477, "score": 0.8477}`

| Part (40 seeds) | Parent b2_a0 | **b2_a1** |
|---|---|---|
| Score | 0.8517 | 0.8477 |
| HARD | 80/80 | 79/80 |
| Spacing | 0.071 (36/509) | **0.115 (66/573)** |
| Whiff | 0.983 | 0.966 |
| Ptr3 | 0.995 | 1.0 |
| KESSA | 0.963 | 0.938 |
| NORMAL | 0.075 (factor 1) | 0.075 (factor 1) |

Seeds 21–40 alone are worse than seeds 1–20, which put it level or ahead: one HARD loss, and KESSA 37/40 against 39/40. The 1–20 gain does
not hold out of sample.

## Not a repeat
- The NS3b chase is new, and was refuted by trial before any eval was spent.
- The Step tell is a new sensor for "his Hoho is shut", taken from his own visible choice (KK-READ's Step branch), with no HUD gauge
  read.
- The lunge geometry is b0_a0's, copied on purpose, so the two sensors can be compared on equal terms.

## For the coordinator
- **If the HUD flash-step read is ruled out**, the tell is a rule-clean stand-in, but it carries less volume and must back off to set the
  lunge up. That backing off is the cost: whiff −0.017 at 40 seeds.
- Spacing's structural ceiling here is about 0.7: 30 % of its situations are dead pools (the match start, and the post-Soul-Break reset
  that his awakening cinematic flushes).
- What failed:
  - the tell lunge in KESSA (ledger);
  - setting it up from Hoho tells (too short);
  - the tell lunge in :whiff / :kessa episodes (it loses the bait hover's whiff conversions).
- The parent's file with `*iks-tell-p*` HARD 0 is b2_a0, behavior for behavior.
- The `*iks-tell-p*` docstring is stale: it still says "any style mode" and includes KESSA's NS3a + SA, which was T1. In the final file
  `*iks-tell-forms*` (:base) and `*iks-tell-modes*` (:space :ptr3) restrict it. I left it as it is, because the file is the measured one.
