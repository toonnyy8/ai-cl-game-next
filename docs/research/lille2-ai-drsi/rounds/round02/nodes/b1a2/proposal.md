# Cell b1a2 (round 2, refines b1a1): "the line-reader shoots again from 4.5 m" — the Step's re-aimed shot, the burst kept, a Hoho reader read

Freeze 2eaf8b9. Parent: round 2's b1a1 ("the distant line-reader", 0.9645): its `barro.lisp` copied in, its BARRO-CPU-TESTS
section spliced into the frozen test. Only `duel/lisp/barro.lisp` (his CPU parts: the base kit's `:ai` (`:far-snipe :in`,
`:sp-ender`), four BRS slots of CPU state, new BR-AI-* functions / knobs, one clause in BR-AI-CHARGE-TICK, three lines in
BR-AI-KAMAE, one call in BR-AI-REFLEX) and the `BARRO-CPU-TESTS` section changed. Host test 8386 checks ALL PASS (the section
spliced into the frozen file with `splice-tests.py`: byte-identical to the delivered test); `tools/pkgcheck.sh duel` 0 / 0 / 0.

Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, `score.json`, the delivered file byte for byte, measured
last; v4 below gave the same JSON before its comments were written):

| | baseline-r02 | b1a1 (parent) | b0a1 (round 2 best so far) | **b1a2 (delivered)** |
|---|---|---|---|---|
| score | 0.9102 | 0.9645 | 0.9724 | **0.9733** (raw 0.9733) |
| strength (HARD, both seats) | 0.853 | 0.985 | 0.998 | **0.998** (399 / 400) |
| masher | 1.0 | 1.0 | 1.0 | **1.0** |
| signature | 0.923 | 0.926 | 0.933 | **0.936** |
| NORMAL share (band 0.30-0.60) | 0.36 | 0.445 | 0.4175 | **0.5125** x1 (Y 60, K 19, R 48, I 28, S 50 of 80) |
| pacing medians Y K R I S (cap 220, all 40/40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | 140.2 136.8 158.5 155.5 163.1 | 130.2 130.4 160.3 160.3 153.0 | **129.4 137.9 157.1 160.2 154.9** |

sig_by (top): br-e-k 0.265, br-e-kl 0.151, **br-s-l1- 0.100** (parent 0.056), br-oe-k 0.088, charged 0.077, **br-k-hiren 0.075**
(0.066), br-rc 0.074, **plain-jk 0.057** (0.066), br-oe-kl 0.052, br-w-nijushi-c 0.019, br-s-j 0.013; outside the whitelist
besides plain-jk: counter 0.004, the cuts / the level-1 dash 0.001 each.

## History read (every proposal, score.json and score.rescored.json; round 1's numbers pre-R18: mechanisms only)

- Round 1: b0a0 0.8032 (L's hold as the plan, the CPU's R17 link, the turn before the follow-up), b1a0 0.6985 (routes on
  events; the missing turn), b2a0 0.915 (the reach envelope / kite, the Kikon on openings), b3a0 0.9192 (the clock, the wing
  reserve), b0a1 0.952, b1a1 0.9529 (the Step-in interrupt, the stance exit, the let-go), b0a2 0.9549 (the burst kept for the
  owl; the dash's follow-up J1 forced by frame data; "bare: back out first" a selection bias), b1a2 0.9716 (every link into
  the stance, the pips cashed from range).
- baseline-r02 0.9102 (b1a2 on R18: the charged L no longer snaps onto him).
- Round 2: b0a0 0.9696 (the marksman: the charge's Step as the re-aim), b1a0 0.9607 (the line: release when his feet meet the
  frozen aim; the envelope: the far snipe from 6 m; the facing), **b1a1 0.9645 (my parent: the line's length / floor, the
  base form backs off to 6.5 m, no shot into his Hoho, NORMAL's KIN windows)**, b0a1 0.9724 (b0a0 + the facing + the kept
  burst; its dead end: the far snipe from 6 m on the marksman cost signature).
- Located, not repeated: the dash's follow-up J1 (b0a2 / b0a1: forced by the cuts' stagger; re-measured below), `:l-after-*`,
  the level-3 dash from 3 m (flat twice), "bare: back out first" (b0a2).

## Diagnosis of the parent (combat logs exactly as aieval's strength runs: 40 seeds x 5 opponents x both seats, HARD, 394 / 400 = its 0.985; scratch parsers)

- **Where his damage is not signature** (7.4 %): the attack state's J1 FOLLOW-UP after the dash's cuts 4.0 % (KIN 3.13, the
  owl 0.86: re-measured frame by frame: after a level-2 dash he is free 6 f after the last cut, after level 3 2 f before it;
  the K route needs the J1 bridge, EN J1's J route fits level 3 but deals a quarter of the K route: no share gain), the base
  form's J1s 1.9 % (Step-in 0.60, Step-J 0.41, ORANGE's chain 0.26, anti-Breaker 0.24), the awakened Step-in / punish / chain
  J1s ~0.9 %, counters 0.5 %.
- **By form**: the base form dealt 20.5 % of his damage (signature 0.909) and **took 60 %** of what he took (354 k of 586 k);
  JILLIEL EN / the owl EN dealt 74 % at 0.997.
- **The base snipe's releases** (a temporary combat-log line on the CPU's release reason, removed; 16 seeds): the line's own
  fires hit 1 104 of 1 352 (82 %), but **inside the envelope** the shot was a loss: AI-ENV-FIRE 483 (207 hit, 93 whiffs,
  11 k taken), **AI-ENV-SHOT 124 at a median 1.5 m: 96 whiffs, 13.6 k taken** (the Step spent, him off the line on top of
  the rooted charge). With the far snipe from 6 m the base form also stood idle out of its strings' reach: 1 138 kites, the
  Step-in / Step-J J1s.
- **HIRENKYAKU's cash-out**: Perfect-Hoho'd **112 of 205 times by Ichigo and 92 of 229 by Rukia** (their timed-Hoho reflexes:
  the shot at f20, a Hoho from f8 is perfect), **0 of 704** by the other three; 204 counters = 23 k taken (4 %), and the
  COUNTER after HIRENKYAKU was the top opener in 3 of the 4 lost Ichigo matches.

## The action policy (行動方針): b1a1's line-reader, plus

1. **The Step's re-aimed shot** (BR-AI-CHARGE-TICK, `*BR-AI-STEP-FIRE-MIN*` 2.5 m, BRS `ai-stepped`): the line-reader's
   charge that had to Step out (him inside the envelope, his Hoho, the line lost) comes back re-aimed on him by the sim
   (R18's BR-CHARGE-STEP-GO) — it now **fires at once at level 2 / 3** instead of waiting for the line again (in the parent he
   chased the Step down and the charge ended as a blind AI-ENV-SHOT); nearer than 2.5 m (he caught the Step) the line / the
   envelope decide as before. A rule, no roll. 16 seeds: the re-aimed shot hit 630 of 848, its whiffs all under 2 m.
2. **The far snipe from 4.5 m again** (`:far-snipe :in` 6.0 -> 4.5; the back-offs still stop at the line's 6.5 m,
   BR-AI-BACK-TO): with (1), the envelope's Step out is no longer a dead end, so the base form opens the stance where it used
   to walk into Step-in / Step-J J1s and kites. 16-seed diag: far snipes 2 843 -> 4 590, base Step-in / Step-J J1s halved,
   kites 2 272 -> 1 460, the awakening ~6 s sooner (the base form deals more: the gauge's dealt share); full eval: br-s-l1-
   0.067 -> 0.100, plain-jk 0.065 -> 0.057, HARD 394 -> 399 / 400. (b0a1 measured the opposite move, 4.5 -> 6 on the
   marksman, as a loss; b1a0 moved 4.5 -> 6 for the envelope; the Step's shot is what makes 4.5 pay on the line.)
3. **The burst kept for the owl** (b0a1's piece, round 1 b0a2's mechanism; the base kit's `:sp-ender` BR-AI-KEEP-BURST,
   `*BR-AI-KEEP-BURST*` 0.2 / 0.5 / 1.0, one roll a string end): the base form's ORANGE chain J1 (0.26 % plain) is gone, the
   flash step kept for JILLIEL's owl.
4. **A Hoho reader read** (BR-AI-CASH-READ / BR-AI-CASH-WARY, `*BR-AI-CASH-WARY-P*` 0 / 0.3 / 1.0, `*BR-AI-CASH-COMMIT*`
   20 f, BRS `ai-cash-t / -hp / -read`): every cash-out (HIRENKYAKU from the base stance) is remembered; at his next free step,
   damage he took since (his own gauges: a counter, a punish) is one event, one roll -> a read. Read once in a match, the
   cash-out from neutral waits for an opponent perceived committed >= 20 frames (a recovery, a stagger), else the stance
   shoots the snipe. Against Yamamoto / Kenpachi / Senjumaru (who never answer it) nothing changes; against Ichigo / Rukia the
   second and later counters go: 16 seeds 119 -> 58 HIRENKYAKU counters (an ablation without the read: the same signature and
   wins within noise, so it is kept as his adaptation, not as a measured gain).

Per form: **base** — the far window from 4.5 m: the stance, the snipe held for the line; inside his envelope the stance Step
out and the re-aimed shot at once; HIRENKYAKU at the pips' cap (after a read only on a committed opponent); his strings end
without ORANGE. Backs off to 6.5 m (kite, unguard). **KIN / the owl KIN / EN / the owl EN** — b1a1's (the line for the dash,
the facing, the floor, the windows, the strings, the reserve, the volley); the dash's Step out (a lost line) also gets the
re-aimed release.

Difficulty: every new chance a table EASY <= NORMAL <= HARD (host-checked: the kept burst, the read); one roll per event (a
string end, a cash-out's answer); the step-fire and the 4.5 m window are rules on existing one-per-window / one-per-charge
rolls. Randomness only SIM-RND01. The opponent only through the perceived SNAP (his distance, his frames left); the read uses
his own gauges (damage taken). Kept working: AI-AWAKEN-P / `:awaken`, BARRO-TICK / BR-AI-BURST-P / `:burst` untouched; every
debug / test command; the `duel barro` counters (new: `ai-step-fire`, `ai-keep-burst`, `ai-cash-read`); the learner (no new
reflex: BR-AI-CASH-READ returns NIL; BR-LEARN-* untouched; the learner's kamae plan is read before the cash-out as before);
the ASSIST (`:sp-ender` acts only for his own CPU, BR-TICK-BRAIN; the difficulty through AI-BRAIN; the charge tick is his own
CPU's branch).

## The steps measured

aieval 40 seeds; the 16-seed HARD diag = the evaluator's strength matches for seeds 1-16 (160 matches, logs parsed).

| step | change | score | str | mash | sig | NORMAL | diag: wins / sig / taken |
|---|---|---|---|---|---|---|---|
| b1a1 | parent | 0.9645 | 0.985 | 1.0 | 0.926 | 0.445 | 159 / 0.9262 / 236 k |
| v1 | no AI-ENV-SHOT (hold instead) — not kept: the cap fired them blind (146 whiffs, 15.8 k) | | | | | | 160 / 0.9266 / 240 k |
| v3 | the Step's shot + the kept burst + the read | 0.9645 | 0.985 | 1.0 | 0.926 | 0.51 | 157 / 0.9263 / 224 k |
| **v4** | **v3 + the far snipe from 4.5 m (delivered)** | **0.9733** | **0.998** | 1.0 | **0.936** | 0.5125 | 159 / 0.9365 / 229 k |
| v5 | v4 + the Step kept for his Hoho inside the envelope — not kept | | | | | | 157 / 0.9318 / 226 k |
| v6 | v4 with the far snipe from 3.5 m — not kept | | | | | | 158 / 0.9373 / 245 k |
| v7 | v4 + v5's rule only vs an opponent not closing — not kept (≈ v4) | | | | | | 158 / 0.9360 / 230 k |
| abl. | v4 without the read | | | | | | 158 / 0.9362 / 229 k |

v5 cut the blind point-blank shots (264 -> 41) and the base form's damage taken (144 k -> 133 k) but fired more snipes into
guards (843 blocked) and lost signature (0.9365 -> 0.9318): signature outweighs strength at 0.998, so not taken (the
coordinator may prefer it for the never-awakened base form: see the risks).

## Why it is not a repeat

The parent's line kept its Step only as an escape and then waited for the line again; the logs located the dead end (the
chased Step, the blind AI-ENV-SHOT). Firing the re-aimed charge at once is the marksman's "back from that Step" piece (round 2
b0a0), taken onto the line-reader where the parent had none, and it is what turns the 4.5 m window (which b1a0 and b0a1 each
measured as worse on their own lines) into the signature gain. The kept burst is b0a1's measured piece (allowed by the brief).
The read is new: no cell adapted to one opponent's answers within a match; it is located (Ichigo / Rukia's timed Hohos, 0 by
the others) and event-driven (one roll a cash-out's answer).

## Awaken A/B (the kept burst changes the base form's burst use; the awakening itself untouched)

`python3 tools/simgate.py --pairs 21,22,23,24,25 --seed0 S --seeds 60 --cmd 39020 -j 2` on the delivered file, the
never-awaken side's (P1 Lille II, NORMAL) wins of 60, Y K R I S:

| seed0 | **b1a2** (Y K R I S) | b1a1 (parent; 100 only) | b0a1 (sibling line) |
|---|---|---|---|
| 100 | **10 0 2 1 4** | 8 0 1 0 2 | 13 0 0 2 2 |
| 300 | **15 1 0 0 1** | — | 12 0 3 0 2 |
| 500 | **13 0 1 2 1** | — | 16 0 2 1 3 |

All 900 matches K.O. (medians 139.6-169.5 s). Unchanged in kind and far under the pass mark 20, as for every cell: these
rows are his NORMAL base form alone against awakening opponents; the kept burst only saves a bar the base form cannot turn
into the owl there. The never-awakened base form stays the open problem (Kenpachi 0-1 / 60 on every stream).

## Expected benefit, risks

- Benefit: +0.0088 over the parent (strength 0.985 -> 0.998, signature 0.926 -> 0.936), the round's best measure so far
  (b0a1 0.9724). The base form deals more of his damage (the snipe 0.056 -> 0.100) and Steps / kites less.
- The step-fire and the 4.5 m window are rules at every difficulty: NORMAL rose 0.445 -> 0.5125 (Y 60 / 80 the band's top
  row; 0.0875 under the top): a later change that strengthens NORMAL could leave the band. Kenpachi NORMAL 19 / 80 unchanged.
- The blind point-blank snipe stays (AI-ENV-SHOT ~260 in 160 HARD matches, ~30 k of his damage taken): v5 removes it at a
  signature cost; the never-awakened base form (the A/B) might prefer v5.
- Pacing medians 129.4-160.2 s, >= 59 s under the cap (no risk).
- A human sees the rifle up from 4.5 m again; inside 5.5 m a Step back (vanish) and the shot at once — a Hoho after his Step
  is the counter (the Step is spent). The read means HIRENKYAKU from neutral stops after the human punishes one.

## Shared-code recommendations (not done)

- ai.lisp's threat Hoho tests the perceived frame (every round-2 cell): Ichigo's / Rukia's timed Hohos make any slow line
  from neutral a perfect-Hoho target (HIRENKYAKU 40-55 %), the generic CPUs never answer it.
- The rules' follow-up after the dash (b0a2 / b0a1's): the dash's recovery facing him, or a stance opener cancelling its end,
  would move ~4 % of his damage onto the whitelist.
