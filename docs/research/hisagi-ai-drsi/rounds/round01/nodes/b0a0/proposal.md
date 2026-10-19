# b0a0 (§25.15 freeze): the Shikai chain, 鎖鐮連段, with the windmill's sweep (風車返し) and the red string's lightning (綴の止め)

Cell b0a0, round 1 on the §25.15 freeze (3686d94). Branch b0's primary style: the Shikai chain. PARENT_DIR none: a new
direction from BASELINE_DIR. Everything is in `duel/lisp/hisagi.lisp`'s CPU parts and the host test's
`HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline (§25.15) | b3a0 ported (20 seeds) | **b0a0 (this file, 40 seeds)** |
|---|---|---|---|
| **score** | **0.0** (raw 0.4149) | 0.7608 | **0.783** (raw 0.783) |
| strength (HARD, 480) | 0.006 | 0.400 | **0.435** |
| masher (HARD, 224) | 0.188 | 0.991 | **1.000** |
| signature | 0.751 | 0.885 | **0.905** |
| sig_by | chain 0.373, ranged 0.204, bind 0.174, plain-j 0.111 | chain 0.875, plain-j 0.054, Kikon 0.044, counter 0.013 | chain **0.895**, plain-j 0.055, Kikon **0.022**, counter 0.013, ranged 0.005, bind 0.005 |
| NORMAL share (factor) | 0.104 (0) | 0.521 (1) | **0.525 (1)**: Y 45, K 26, R 46, I 45, S 64, Lille 26 of 80 |
| pacing (NORMAL medians, all K.O.) | 115-175 s | 103-159 s | 104.2-158.1 s (Rukia 158.1, the longest) |

The JSON line is `score.json`. Host tests: duel-rules 9867 checks ALL PASS (the frozen 9865 + 2 in the section; the splice
of this section into the frozen file is byte-identical to the delivered `duel-rules-test.lisp`), control 89, learn 131,
input 33, touch 64 (0 failures), cine 18. `tools/pkgcheck.sh duel` is clean.

## History read

The rounds directory held only this round's two briefs (b1a0 runs alongside, nothing written). PRIOR_DIR holds round 1 on
the §25.12 rules: b0a0 0.637 (the Shikai chain RENSA / KARIBA, the dead windmill string fixed, the late awakening), b1a0
0.567 (the ranged fence, three ranged styles), b2a0 0.684 (b0a0 + b1a0's fence behind a blade-aware awakening gate, the
bind styles), b3a0 0.766 (b0a0's Shikai + its reaping fence + b1a0's Bankai as the last stand). The rules that changed
since (§25.13-§25.14: the bind's damage x1.3 and its pool 1 per 3, the tip x1.71, no 3.5 m placement, the route links
reaching the victim where he is, FREE back) touch only the Bankai: the Shikai's moves are as they were. So the prior
mechanisms are reusable as they stand; their scores are not.

## What I did

1. **Ported b3a0's CPU onto this freeze** (a three-way merge of its CPU diff onto the frozen file; never its whole file).
   One conflict, the bind's release: b3a0's KAIBAKU-GEKI at any distance is kept, and without SP2's Reiatsu it now falls
   back to §25.14's plain FREE (`*hs-ai-plain-release-p*`). The section's §25.13 reach pins (HS-R-REACHES-P on the route
   links) are the frozen ones. Measured: 0.7608 at 20 seeds (strength 0.400, sig 0.885, NORMAL 0.521).
2. **Diagnosed his HARD losses** (combat logs, a move-outcome table per tag; scripts in the cell's scratch):
   - Lille (0 of 80 at HARD): she snipes from 5.6-7.2 m. Her charged shot's level-2 copy starts 8 f before its hit,
     inside a HARD brain's 8 f delay, so RANGED-THREAT-IN 4-24 f never saw it and the ward rose only 3 times in a match;
     a ward never turned into anything (no K out of it).
   - Ichigo / Kenpachi: the reap K1 was perfect-Hoho'd 16 of 32 (Ichigo) and 10 of 24 (Kenpachi); his J1 never was
     (its 8 f startup is inside the Hoho read's lead).
   - The signature: 4.4 % of his damage was HS-KIKON. The generic AI-REFLEX forces the O ender on any link-3 hit on a
     red victim, so every string that reaches the red ends in a 70-damage Kikon (plain).
3. **Added two per-event layers to the chain** (below) and tried and dropped a third.

## The styles and the mix (the 行動方針)

| layer | roll | styles and weights |
|---|---|---|
| the Shikai, the chain (始解鎖鐮連段) | once a match (HS-AI-STYLE, SIM-RND01) | **RENSA 連鎖 55 %** / **KARIBA 刈場 45 %** (b3a0's) |
| per charge of his | once per charge seen (HS-AI-REFLEX, his move's start tick) | **KAZAGURUMA-GAESHI 風車返し**: the windmill wards, RENSA 0.15 / 0.3 / 0.7, KARIBA 0.2 / 0.4 / 0.9 |
| per ward | once per ward (HS-AI-SIG-HOLD) | its sweep: RENSA 0.2 / 0.4 / 0.7, KARIBA 0.3 / 0.5 / 0.9, else the plain 36 f ward |
| per red string | once per link-2 hit on a red victim (HS-AI-MOVE) | **TODOME 綴の止め**: RAIDEN cancelled out of it, 0.2 / 0.4 / 1.0 |
| the Bankai's ranged mode, his last stand (at 4500 taken) | once per entry (HS-R-STYLE) | SOKUBAKU 64 % / SANGE 16 % / KUBIGARI 20 % (b1a0's, via b3a0) |
| the bind | per change event | the release 150 behind on grey (KAIBAKU-GEKI anywhere, else FREE 0.1 / 0.15 / 0.2), KOJO 0.1 / 0.2 / 0.3 |

(Chances EASY / NORMAL / HARD.)

- **RENSA 連鎖, the chain link (55 %)**: rushdown. J1 up close, then off a J hit the windmill bridge into the charged K
  string (J → L → K1 → K2 → K3 → RAIDEN), the leap J2K / J3K. It wards charges less (0.7 at HARD) and sweeps less.
- **KARIBA 刈場, the reaping ground (45 %)**: holds 3-6 m, hops out of K1's dead zone, reaps every approach with K1 and
  punishes whiffs at range. It wards every charge it sees at HARD (0.9) and sweeps out of the ward (0.9).
- **KAZAGURUMA-GAESHI 風車返し (new, both styles)**: when he is seen charging a ranged shot (a move in its `:hold` phase
  with a `:ranged` window, 2.5-9.0 m: a snipe held, Rukia's held wave, Senjumaru's weave), the windmill comes up before
  the shot. Then the ward rolls its sweep. On a yes, L is held its full 60 f, so the charge runs (+1 % reach a frame). K
  fires as soon as K1 at that charge reaches him and no ranged hit of his lands within 12 f as perceived (the ward takes
  that one). He doesn't wait out a charge still held: his longest shots go through the ward. The ward against a ranged
  threat (b0a0's) rolls the same sweep. At HARD: 1.7 charge wards, 2.6 threat wards and 2.2 sweeps a match.
- **TODOME 綴の止め (new, both styles)**: on a link-2 hit (J2 / K2 / K2J / J2K) with the victim in the red, no Soul
  Break finish due (AI-SB-FINISH-P) and SP1's bar there, RAIDEN is cancelled out of it. The link 3 is never pressed,
  because its hit would force the generic O ender's 2-Konpaku Kikon. The chain's lightning takes the red window down
  toward the Soul Break (3 Konpaku in the Shikai) instead. HARD: 1.7 a match; HS-KIKON fell from 4.4 % to 2.2 % of his
  damage.

What a human notices: he fights in the Shikai almost the whole match.
- RENSA closes in and chains the windmill bridge into the reaping K string.
- KARIBA keeps the chain's distance and sweeps you as you walk in.
- Either one raises the windmill the moment you start charging a shot, eats it, and answers with a long, charged chain
  sweep from where he stands.
- When you are in the red, his string ends in lightning, not the Kikon rush.
- The Bankai comes only as a last stand.

## Tried and dropped (measured, HARD strength / signature; 40 seeds = 480 matches, 100 = 1200)

| variant | strength | sig | verdict |
|---|---|---|---|
| the port (b3a0 on this freeze) | 0.406 | 0.883 | the base |
| + TODOME 0.85 | 0.417 | 0.897 | kept (Kikon 4.4 → 2.4 %) |
| + b2a0's blade gate (`:awaken (:min-taken 2000 :melee-share 0.999)`) | 0.400 | 0.892 | dropped: Kenpachi 7 of 80 either way. Under these rules the always-awaken side is 34 of 120 at HARD vs the never side's 47 |
| + the ward-sweep, TODOME 1.0, `:hoho` 0.15 (v5) vs the same without the ward-sweep | 0.409 vs 0.375 (1200) | 0.908 vs 0.905 | the ward-sweep kept: +0.034, mostly Yamamoto and Rukia |
| + MACHI-GAMA 待ち鎌: the reap's roll skipped vs a perfect-Hoho reader (≥ 1 PERFECT this match, his flash-step ≥ 30, no Hoho of his seen within its lockout), 0.9 at HARD | 0.375 | 0.891 | dropped: Ichigo 4 → 15 of 80, but Yamamoto, Rukia and Senjumaru lost more, and his J1 openers cost signature |
| the same, only after 4 PERFECTs | 0.4075 (1200) | 0.903 | dropped: Ichigo up, Rukia down, net ≈ 0 |
| `:hoho` 0.3 → 0.15 (his perfect Hoho's counter is plain) | aieval 0.412 / 0.913, score 0.7802 | | dropped: the key is every difficulty's, and NORMAL's never-awaken A/B rows fell to HK 18 / 14 / 16 and HB 16 / 12 / 25 of 60. Back at 0.3: HK 21 / 23, HB 31 / 22 at seed0 100 / 300 |

## Mechanisms implemented (CPU parts only)

- **New functions:**
  - HS-RANGED-MOVE-P and HS-CHARGE-SHOT-P (pure, host-tested);
  - HS-CHARGING-P (the read of the perceived snap);
  - HS-SEEN (the brain's perceived snap, for the windmill's brain branch, where no reflex runs while L is held);
  - HS-SHOT-PENDING-P.
- **Changed:**
  - HS-AI-REFLEX: the charge read after the threat ward.
  - HS-AI-SIG-HOLD: a ward rolls its sweep (`:sweep`).
  - HS-AI-KAZA-K: a sweep's K waits only for a shot about to land.
  - HS-AI-MOVE: TODOME first.
  - HS-B-AI-REFLEX: the FREE fallback, from the merge.
- **Knobs:**
  - new: *HS-AI-CHARGE-WARD-P*, *HS-AI-SWEEP-P* (by style × difficulty), *HS-AI-TODOME-P*, *HS-AI-SWEEP-WAIT* 12,
    *HS-AI-CHARGE-FAR* 9.0;
  - every one of b3a0's (ported).
- **HSS CPU slots:** b3a0's, plus `ai-hk` (the charge rolled for). None is hashed.
- **Pacing counters:** `ai-charge-ward`, `ai-todome`.
- **Not touched:** HS-AI-OPP and its knobs, every move, every rule, the art, every other file, HS-HASH, HS-KAZA-TICK's
  human branch.
- **Kept working:**
  - The learner's clock: the new reads act on events and return NIL otherwise.
  - The ASSIST: HS-AI-SIG-HOLD and HS-AI-MOVE read the brain they are given. The sweep's pending read uses
    HS-TICK-BRAIN, his own CPU's.
  - The debug modes 83000-83999 and the `duel hisagi` counters.
  - The awakening goes only through AI-AWAKEN-P (b0a0's `:awaken (:min-taken 4500)` kit gate).
- Every chance is EASY ≤ NORMAL ≤ HARD (host-pinned), rolled once per event: a charge (its start tick), a ward, a link
  hit, a match.

## Why it is not a repeat

- The port is b3a0's measured CPU, carried onto rules it never saw. That is reuse, not a rename.
- The two layers are new mechanisms aimed at located causes:
  - **KAZAGURUMA-GAESHI** reads a charge (the `:hold` phase), which no earlier cell read. Every earlier ward was a dead
    end with no K out of it; this one turns into the charged K string. b0a0 / b3a0 explicitly never swept out of a ward.
  - **TODOME** is aimed at the generic O ender, which forces a plain Kikon on a red victim. No earlier cell touched it:
    b3a0 removed the O ender only for non-red victims.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60, this file next to the baseline's (the frozen baseline file measured the same way in
this worktree):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100: b0a0 / baseline | 36 / 2 | 21 / 1 | 35 / 0 | 25 / 0 | 51 / 1 | 31 / 0 |
| 300: b0a0 / baseline | 29 / 2 | 23 / 0 | 42 / 0 | 29 / 1 | 48 / 4 | 22 / 1 |
| 500: b0a0 / baseline | 31 / 1 | 22 / 0 | 35 / 0 | 33 / 0 | 48 / 2 | 24 / 0 |

Every b0a0 row is at least 21 of 60: the A/B passes. Every match is a K.O. (medians 103-153 s).
The baseline fails every row (0-4 of 60): its never-awakening Shikai is the broken CPU (its NORMAL share 0.104).

## Expected benefit and risks

**The benefit:**
- 0 → 0.783 over the baseline, +0.02 over b3a0's CPU ported onto this freeze.
- The signature is 0.905: the chain alone is 0.895 of his damage.
- The masher is solved (224 of 224).
- HARD strength is 0.435.

**Risks:**
- Lille stays 0 at HARD. Her awakened form's melee and her level-3 snipe (uncatchable: it goes through the ward) beat him.
- Ichigo and Kenpachi still perfect-Hoho the reap at HARD (4-15 of 80).
- The ranged and bind themes are about 1 % of his damage: the Bankai is his last stand (at 4500 taken). The new rules make
  the Bankai stronger, but at HARD the never-awaken side still beats the always-awaken one (47 vs 34 of 120).
- The HK / HB A/B rows (21-31) are the closest to the bar (20), and so is the masher's.
- NORMAL is 0.525, mid-band. The pacing's longest median is 158.1 s (cap 220): no risk.

## Shared-code recommendations (not done: outside this cell's scope)

- **ai.lisp RANGED-THREAT-IN reads only a move's `:main` phase.** A held charge whose release starts a short-startup
  copy (Lille's level-2 / 3 snipes, 8 f) is never a threat for an 8-14 f brain. Every kit's ward and Hoho reader misses
  it. The `:hold` phase of a ranged move should count as a threat, as HS-CHARGE-SHOT-P does here.
- **ai.lisp's forced O ender on a red victim** (AI-REFLEX's first clause) leaves a kit no say. A kit hook, or the kit's
  `:sp-ender` asked first, would let a character finish its own way. Here TODOME has to sidestep it from link 2.
- **The kit's `:hoho` is one number for every difficulty.** A HARD-only cut (his counter is plain damage) costs NORMAL's
  A/B rows. A difficulty plist there would let the layering hold.
- (Standing, from the prior cells.) The generic J1 answers ignore a move's `:min-reach`. A style can't pick its own
  awakening (AI-AWAKEN-P's kit gate is one plist).
