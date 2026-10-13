# Cell b3a0 (round 2): "the scout's book" — an opponent model: how the man answers each commitment, read per match and seeded with his reputation

Freeze 2eaf8b9, a new direction from `baseline-r02` (no parent). Only `duel/lisp/barro.lisp` (his CPU parts: eight BRS slots
of CPU state, a new AI-section block "the scout's book" — knobs, pure BR-BOOK-* / BR-AI-ANSWER / BR-AI-BOOK-LEVEL /
BR-AI-TRAP-CHANCE / BR-AI-RESPECT / BR-AI-WARY-PLAN and the BR-AI-BOOK / -WATCH / -BOOK-STEP / -TRAP-TICK / -LEVEL hooks;
calls in BR-AI-REFLEX, BR-AI-KAMAE, BR-AI-SIG-HOLD, BR-AI-KITE, BR-AI-EXIT, BR-AI-CHARGE-TICK, the CPU branch of
BR-TO-EN-LINK-TICK's charge, one CPU-only line in BR-S-TICK gated by BR-TICK-BRAIN) and the `BARRO-CPU-TESTS` section of
`tests/duel-rules-test.lisp` changed. Host test 8396 checks ALL PASS; `tools/pkgcheck.sh duel` 0 / 0 / 0.

Final measure (`python3 tools/aieval.py --char 6 --seeds 40 -j 2`, `score.json`, the delivered file byte for byte, measured
last; the same code as v6 below plus comments):

| | baseline-r02 | b0a1-r2 | b1a2-r2 (round 2 best) | **b3a0 (delivered)** |
|---|---|---|---|---|
| score | 0.9102 | 0.9724 | 0.9733 | **0.9685** (raw 0.9685) |
| strength (HARD, both seats) | 0.853 | 0.998 | 0.998 | **0.990** (396 / 400) |
| masher | 1.0 | 1.0 | 1.0 | **1.0** |
| signature | 0.923 | 0.933 | 0.936 | **0.931** |
| NORMAL share (band 0.30-0.60) | 0.36 (Y 45, K 12, R 37, I 23, S 27 of 80) | 0.4175 | 0.5125 | **0.4475** x1 (Y 52, **K 23**, R 38, I 27, S 39 of 80) |
| pacing medians Y K R I S (cap 220, all 40 / 40 K.O.) | 129.8 124.4 161.3 163.2 158.7 | 130.2 130.4 160.3 160.3 153.0 | 129.4 137.9 157.1 160.2 154.9 | **140.4 148.9 171.7 169.6 159.7** |

sig_by (final): br-e-k 0.243, br-e-kl 0.145, br-s-l1- 0.107, br-oe-k 0.088, charged 0.079, br-rc 0.069, br-k-hiren 0.067,
plain-jk 0.062, br-oe-kl 0.051, br-s-j 0.025, br-w-nijushi-c 0.017; outside the whitelist besides plain-jk: counter 0.005.

Honest summary: 0.9685 is 0.0048 under the round's best (b1a2-r2), about two HARD matches of 400 and 0.005 of signature. It
gets there from the baseline with no aim or line geometry at all (round 2's shared theme), through a different mechanism: a
per-match opponent model. Its own gains: strength 0.853 → 0.99, NORMAL 0.36 → 0.4475, and Kenpachi 12 → 23 / 80 (the
second-best Kenpachi row of the search, after b0a2-r2's 27).

## History read (every proposal, score.json and score.rescored.json; round 1's numbers are pre-R18: mechanisms only)

- **Round 1** (freeze 36e93c7): b0a0 0.8032 (L's hold as the plan, the CPU's R17 link, the turn before the follow-up), b1a0
  0.6985 (routes on events; its gap the missing turn), b2a0 0.915 (the opponent's first-strike *envelope* read off his kit:
  the kite / ward, the Kikon on openings, the unguard), b3a0 0.9192 (the clock, the wings as armour: the reserve), b0a1 0.952
  (b2a0 + the reserve + the wake-up shot), b1a1 0.9529 (the Step-in interrupt, the stance exit, the let-go), b0a2 0.9549 (the
  burst kept for the owl; located dead ends: the dash's follow-up J1 forced by frame data, "bare: back out first" a selection
  bias, NORMAL's ±0.05 RNG noise), b1a2 0.9716 (every link into the stance, the pips cashed from range).
- **baseline-r02** 0.9102 (b1a2 on R18: the charged L no longer snaps onto him; strength 1.0 -> 0.853).
- **Round 2**: b0a0 0.9696 (the marksman: the shot's line against his predicted feet, the charge's Step as the re-aim, his
  Hoho behind the charge answered with it), b0a1 0.9724 (+ the facing, the kept burst), b0a2 0.97 (no follow-up after his own
  push, every shot reaches, no long guard: Kenpachi NORMAL 27/80), b1a0 0.9607 (the line: release when his feet meet the
  frozen aim; the envelope; the facing), b1a1 0.9645 (the line's length / floor, the base backs to 6.5 m), b1a2 0.9733 (the
  Step's re-aimed shot at once, the far snipe from 4.5 m again, the burst kept, a Hoho reader read: HIRENKYAKU only into his
  commitment after one counter).
- All six round-2 cells refine one theme: **aiming the charged L after R18** (where the shot goes vs where his feet are). The
  only adaptive piece in the whole history is b1a2-r2's one-shot read of a HIRENKYAKU counter (no measured gain, kept for
  character). Every other rule in every cell is the same against all five opponents. No cell modelled *who* he fights.

## Diagnosis (baseline-r02, the combat log as aieval runs it; scratch parsers)

HARD (4 seeds × 5 opponents × both seats, 40 matches: 36 / 40, Ichigo 5 / 8 the weak row) — every commitment of Lille's
paired with the man's first answer and the outcome:

| opponent | snipe charge: Hoho → opened | HIRENKYAKU: Perfect-Hoho'd | dash charge: opened (by attack) | main openers on Lille |
|---|---|---|---|---|
| Kenpachi | 15 of 16 | 0 of 22 | 15 of 121 (8) | punish after the snipe whiff, FIRST-STRIKE J1 |
| Ichigo | 13 of 17 | **10 of 14** | 34 of 188 (16) | COUNTER (Perfect Hoho) on dash / HIRENKYAKU, the clone |
| Rukia | 15 of 21 | **10 of 16** | 22 of 194 (12) | COUNTER, ICE-CASH, the freeze |
| Senjumaru | 15 of 15 | 0 of 20 | 20 of 155 (18) | FREEZE [PAIR] into the dash |
| Yamamoto | 18 of 23 | 0 of 24 | 20 of 189 (11) | punish after the snipe whiff, WAVE, Breaker |

- The man's **answers differ by who he is** (Ichigo / Rukia counter HIRENKYAKU 20 of 30, the other three 0 of 66; Senjumaru
  and Rukia attack into the dash's charge; Yamamoto steps off the dash, 126 of 211 whiffed), and every man Hohos the rooted
  snipe's charge at his `:hoho` rate (the generic threat Hoho), which almost always opens Lille (76 openings in 40 matches).
- NORMAL vs Kenpachi (10 seeds both seats): **3 / 20**; openings on an idle JILLIEL KIN 95 (26 k damage) — the stance K3's
  end push, the follow-up J1 whiffed, then KIN stands in Kenpachi's reach (his NEUTRAL J1 / R-J1, GUARD-BREAK Breakers).
  The same idle-KIN pattern against the other four, less often.

## The action policy (行動方針): baseline-r02's routes, plus the book

**THE SCOUT'S BOOK** (BRS-AI-BOOK, a fresh one every match: a new fighter entity). His CPU watches each of its own
commitments and counts how the man answered it, as perceived through the SNAP (the perception delay) and felt through
Lille's own damage taken — never his inputs:

- the watched kinds: `:snipe` (the base snipe's charge), `:dash` (the awakened dash's charge), `:cash` (HIRENKYAKU from
  neutral), `:stand` (his attack started on a free Lille inside his first-strike envelope + 1 m, one watch an action of his);
- per kind: how many, his **first answer** in it (BR-AI-ANSWER: `:hoho`, `:step`, `:attack` (a move of his begun since),
  `:guard` (a guard raised since)), **a hit on Lille** before Lille is free again (he punished it), and whether Lille's move
  **touched** him (a hit or a block; else it missed him);
- a watch opens at the commitment (BR-AI-WATCH: the charge's first hold frame, the cash-out's pick, his attack's start) and
  closes at his CPU's first free step after it (BR-AI-BOOK-STEP, first in BR-AI-REFLEX; it presses nothing and returns NIL);
- **reputation** (*BR-AI-BOOK-PRIOR*, the man's character as any player knows it, as remembered commitments): Kenpachi the
  brawler (two first strikes that landed: respect from the first exchange), Ichigo and Rukia the counter-Hoho (one punished
  HIRENKYAKU: the read from the start). Small on purpose: the match's own book outweighs it within a few exchanges.

**The book's answers** (one roll an event, every chance a table EASY <= NORMAL <= HARD, host-checked):

1. **The trap** (BR-AI-TRAP-TICK, from the CPU's charge tick; *BR-AI-TRAP-P* 0.05 / 0.15 / 1.0 × (1 + every Hoho, Step and
   attack the book holds on that kind)): a charge carries the trap; his Hoho, his Step or his attack in reach perceived during
   the charge → the charge's own Step (R18's BR-CHARGE-STEP-GO: the stance's fast Step, iframes, 5 m away from him, the charge
   kept and re-aimed at its end; L held through it and on into level 2) → back, the charge lets go at once (level 2 at least,
   him ≥ 2.5 m off: his Hoho / his Step / his whiffed attack is the opening). The trap runs before the let-go (b1a1's): the
   Step's iframes instead of a shot fired into his attack. HARD carries it from the first charge; NORMAL learns it from the
   man's answers (0.15 → 0.3 after one, 0.6 after three).
2. **The level by his answers** (BR-AI-BOOK-LEVEL, *BR-AI-LEVEL-P* 0.1 / 0.4 / 1.0, one roll a charge, from 3 charges of
   the kind): a man who guards ≥ 35 % of the snipes gets the 31 m level-3 line (through guard, +3 pips even blocked); a man
   who attacks into ≥ 35 % of them, or walks off the line (≥ 50 % missed), gets level 2 at most (the shorter hold).
3. **The read** (BR-AI-WARY-PLAN, *BR-AI-WARY-P* 0.3 / 0.6 / 1.0, one roll a stance): a man the book holds a punished cash-out
   for gets HIRENKYAKU from neutral only into his commitment (≥ 20 f left, HIRENKYAKU's S); else the stance shoots the snipe.
   (b1a2-r2's read generalised into the book; with the reputation Ichigo and Rukia never get the free first counter.)
4. **Respect** (BR-AI-RESPECT, *BR-AI-RESPECT-P* 0.05 / 0.15 / 0.2 × his landed first strikes / 4): the kite's and the stance
   exit's chances rise with how often he has caught Lille standing (NORMAL kite 0.03 → 0.18, exit 0.15 → 0.3; HARD kite
   0.8 → 1.0): against a brawler Lille keeps out of reach; against a man who never catches him standing nothing changes.

Per form: **base** — the far snipe from 4.5 m as before; the charge now carries the trap (his Hoho behind the rooted rifle
meets the 飛廉脚's iframes and a re-aimed shot from 6.6 m; a man walking in meets the same), the level by his habits, the
cash-out only into a counter-Hoho-er's commitment; it kites away from a brawler. **KIN / the owl KIN** — the dash's charge
(KIN's L held through the turn, the R17 link's L) carries the trap and the level; the stance exit / kite respect the man who
catches KIN standing. **EN / the owl EN** — the window plan's dash carries the trap; strings, wings and the volley unchanged.

Kept working: AI-AWAKEN-P / `:awaken`, BARRO-TICK / BR-AI-BURST-P / `:burst` untouched; every debug / test command; the
`duel barro` counters (new: `book-<kind>[-<answer>][-hit]`, `ai-trap-step`, `ai-trap-fire`, `ai-book-up` / `-down`,
`ai-wary`); the learner (BR-LEARN-* untouched: the book's level is applied before BR-LEARN-CHARGE, whose read keeps the last
word; BR-AI-RESTEP unchanged; the reflex's new first call returns NIL, so LEARN-READ-DUE and AI-DECIDE's neutral run as
before); the ASSIST (`:sig-hold` reads the brain through AI-BRAIN; the trap and the touch line run only under BR-TICK-BRAIN,
never for a human; the book an assisted human's fighter might fill only feeds the CPU-side choices the ASSIST already made).
Randomness only SIM-RND01; the opponent only through the perceived SNAP, his character's name for the reputation, and Lille's
own damage taken.

## The steps measured (aieval, 40 seeds)

| step | change | score | str | sig | NORMAL (K of 80) | pacing medians Y K R I S |
|---|---|---|---|---|---|---|
| baseline-r02 | | 0.9102 | 0.853 | 0.923 | 0.36 (12) | 129.8 124.4 161.3 163.2 158.7 |
| v2 | the book, the trap on his Hoho (press extended through the Step), the read, respect NORMAL 0.35 | **0** (raw 0.9238; RUKIA 39/40 K.O.) | 0.885 | 0.924 | 0.5325 (21) | 150.8 167.8 203.9 199.5 192.9 |
| v3 | answers generalised (Hoho / Step / attack / guard), the trap on his Step too, the level by answers, respect NORMAL 0.15 | 0.9564 | 0.963 | 0.929 | 0.44 (19) | 140.8 140.7 171.4 171.3 165.3 |
| v4 | + the touch (a miss rate: level 2 for a man who walks off the line) | 0.9621 | 0.978 | 0.928 | 0.43 (19) | 138.1 140.7 170.1 171.3 164.5 |
| v5 | + the trap on his attack in reach (before the let-go) | 0.9698 | 0.993 | 0.932 | 0.44 (20) | 140.4 140.7 170.1 172.4 159.7 |
| **v6** | **+ the reputation (Kenpachi / Ichigo / Rukia)** — delivered (+ comments) | 0.9685 | 0.990 | 0.931 | 0.4475 (**23**) | 140.4 148.9 171.7 169.6 159.7 |

- v2's respect at NORMAL 0.35 made NORMAL kite so much that the matches ran long (one 300 s time-out vs Rukia: the pacing gate
  failed). Respect at NORMAL 0.15 keeps every median ≥ 48 s under the cap.
- v5 → v6: the reputation trades HIRENKYAKU from neutral against Ichigo / Rukia (br-k-hiren 0.083 → 0.067) for snipes
  (br-s-l1- 0.097 → 0.107) and lifts NORMAL vs Kenpachi 20 → 23 / 80; score −0.0013, inside the 40-seed noise (±3 HARD
  matches). Delivered for the matchup knowledge the brief asks for; v5 is the variant without it if the coordinator prefers
  the number.
- HARD diagnosis of v4 / v5 (6 seeds × 5 × both seats, 60 matches each): 58 / 60 and 59 / 60. Book counts per 60 HARD
  matches (v4): snipe charges 452 — answered guard 403 (→ level 3), Step 402, Hoho 150 (6 of them still hit Lille), attack
  131 (88 hit Lille: the motive for v5's trap on attacks); dash charges 825 — Step 306, guard 165, attack 211 (56 hit);
  trap Steps 740, re-aimed shots fired 653. The far dash stays the most common opener on him (its follow-up and the cuts'
  timing are the rules', b0a2's finding).

His plain damage (v5's 60 HARD matches): the follow-up J1 after the dash's cuts 3.2 % (forced by frame data), counters 0.6 %,
the base Step-in / Step-J J1 1.0 %, ORANGE's chain J1 0.7 %, punish / anti-Breaker J1s ~0.8 %.

## Why it is not a repeat

No cell modelled the opponent as a *person with habits*: every earlier rule is the same against all five men (the closest,
round-1 b2a0's envelope, reads his kit's reach geometry, and b1a2-r2's read is one flag for one move). Here a per-match model
counts how this man answers each of Lille's commitments and the CPU's choices follow it: the trap for the answers he gives,
the level for the habit he shows, the read for a counter-Hoho-er, the spacing for a brawler; the reputation starts the book
where any player's matchup knowledge would. The trap uses R18's charge Step, as round 2's aim cells did, but keyed on the
man's perceived answer (his Hoho, his Step, his attack), not on a predicted line: no line / aim geometry anywhere in this
cell (no facing check, no line prediction, no floor).

## Awaken A/B

Not required: AI-AWAKEN-P, `:awaken`, the burst (BARRO-TICK, BR-AI-BURST-P, `:burst`) untouched; not run (the base form's
NORMAL kite and trap changed: the never-awakened base form's rows are expected to stay the open problem they were for every
cell).

## Expected benefit, risks

- Benefit: HARD 0.853 → 0.99 without any aim geometry; NORMAL 0.36 → 0.4475 (Kenpachi 12 → 23 / 80, Ichigo 23 → 27); the CPU
  adapts within a match and reads differently against each man (readable: "he Steps out of my Hoho now", "he stopped
  HIRENKYAKU-ing into my counters", "he keeps away from Kenpachi").
- Pacing medians 140.4–171.7 s, ≥ 48 s under the cap (v2 showed respect at NORMAL is the pacing lever: keep NORMAL ≤ 0.15).
- The trap spends the stance's one fast Step on the man's first answer: a second answer in the same stance meets the old
  let-go only. A human who Steps first (baiting the trap) then attacks gets the shot fired into the attack.
- The reputation is per character: a new character starts with an empty book (it learns); retuning a character's CPU may
  make its reputation stale (it is three remembered events, outweighed quickly).
- The read makes HIRENKYAKU from neutral rare against Ichigo / Rukia (signature −0.016 of br-k-hiren there, made up by snipes).
- NORMAL 0.4475 mid-band; ±0.05 is 40-seed noise.

## Shared-code recommendations (not done)

- The learner (learn.lisp) predicts a *human's* answers per situation; the book is the same idea for CPU-vs-CPU, always on and
  much simpler. A shared, generic "answer book" (per commitment kind, perceived answers, damage taken) in ai.lisp would let
  every kit adapt to the man in front of it without the learner.
- Every earlier recommendation stands (the threat Hoho's perceived-frame test; STRING-REFLEX's `:l-after-*` by difficulty;
  the dash's follow-up J1 forced by the cuts' timing).
