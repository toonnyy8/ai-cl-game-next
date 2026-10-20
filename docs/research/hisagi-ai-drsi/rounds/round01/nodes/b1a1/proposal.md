# b1a1 (round 1, §25.15 freeze): 待鎖 MACHI-GUSARI, the waiting chain: the ranged routes off answers only

Cell b1a1, round 1. A refine of round01 b1a0 (0.7517), primary style the Bankai ranged routes (遠距路線). Everything is in
`duel/lisp/hisagi.lisp`'s CPU parts (the three kits' `:ai` plists, the HS-*-AI-* functions and `*HS-AI-...*` knobs, CPU-only
HSS slots) and the host test's `HISAGI-CPU-TESTS` section.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`, freeze 3686d94)

| | baseline | b1a0 (parent) | b3a0 | b2a0 | **b1a1** |
|---|---|---|---|---|---|
| **score** | 0.0 (raw 0.4149) | 0.7517 | 0.785 | 0.7855 | **0.7741** (raw 0.7741) |
| strength (HARD, 480) | 0.006 | 0.400 | 0.490 | 0.458 | **0.448** |
| masher (HARD, 224) | 0.188 | 1.000 | 1.000 | 1.000 | **1.000** |
| signature | 0.751 | 0.863 | 0.876 | 0.896 | **0.879** |
| sig_by chain / ranged / bind | 0.373 / 0.204 / 0.174 | 0.605 / 0.175 / 0.083 | 0.757 / 0.079 / 0.041 | 0.777 / 0.066 / 0.053 | **0.562 / 0.219 / 0.098** |
| plain J / counter / Kikons (Shikai, ranged, bind) / Breaker | 0.111 / 0.037 / 0.063 / 0.038 | 0.050 / 0.020 / 0.060 / 0.005 | 0.064 / 0.020 / 0.033 / 0.008 | 0.054 / 0.018 / 0.027 / 0.005 | 0.056 / 0.025 / 0.035 / 0.005 |
| NORMAL share (factor) | 0.104 (0) | 0.5625 (1) | 0.5625 (1) | 0.454 (1) | **0.4896 (1)**: Y 38, K 33, R 29, I 45, S 66, Lille 24 of 80 |
| pacing (NORMAL medians, all 240 K.O.) | 115-175 s | 115-167 s | 110-164 s | 111-162 s | **113.4-172.9 s** (Rukia 172.9, Lille 172.8) |

`score.json` is the exact line. The Bankai's two themes are **0.317 of his damage** (b3a0 0.12, b2a0 0.12, b1a0 0.26): the
largest ranged + bind share of any cell at a score within 0.012 of the round's best (40-seed noise is about ±0.02).

Host tests: duel-rules **9869 checks ALL PASS** (the frozen 9865 + 4, the section only; splicing this section into the
frozen file gives the delivered `duel-rules-test.lisp` byte for byte); control 89, learn 131, input 33, cine 18 ALL PASS,
touch 64 (0 failures); `tools/pkgcheck.sh duel` clean.

## History read

| cell | mechanism | rescored | lesson used here |
|---|---|---|---|
| baseline | awakes at once, SAHARAI spam, dead windmill string | 0.0 | — |
| prior b0a0-b3a0 (§25.12) | the Shikai chain RENSA / KARIBA; the ranged fence; the blade gate and bind plans; the reaping fence | 0.637 / 0.567 / 0.684 / 0.766 | the Shikai is his strength; prior b2a0's Reiatsu keep near the gate: neutral (re-tested here, below) |
| round01 b0a0 | prior b3a0 + KAZAGURUMA-GAESHI + TODOME, gate 4500 | 0.783 | the best Shikai layers (taken whole here) |
| round01 b1a0 (parent) | prior b3a0's Shikai, gate 2000, the route styles SENTAN / NAWAJI / KAISEN, NORMAL cuts | 0.7517 | "the HARD ranged mode can't be fixed by the CPU": true for the openers he *keeps*, not for the ones he drops (below) |
| round01 b2a0 | b0a0 + the bind first, gate 3000, the SAHARAI-cancel bug | 0.7855 | the located SAHARAI bug (1 cancel in 35 hits) also sat in my parent; no Kikon rush in the Bankai |
| round01 b3a0 | b0a0 + b1a0's routes, gate 3000, the waking noose, the ledger | 0.785 | the 3-step reap and HARD RENSA 0.8; gate 3000 costs the ranged theme (0.08) |

Why the parent lost 0.03 to b3a0: its Shikai lacked b0a0's layers (signature 0.863 vs 0.876, HARD 0.40 vs 0.49) and its
ranged mode played its neutral openers into every HARD opponent.

## The diagnosis (combat logs as aieval runs them; `an.py` in the cell's scratch: per (form, move, why) n / hit / block /
## perfect-Hohoed / damage dealt and taken in the next 120 f)

HARD, the awakening forced on him (debug 39010 / 39001), 240 matches, the parent's ranged mode: 81 s a match, 13.0 dealt /
31.5 taken a second. His neutral swings lost every exchange: K1 NEUTRAL -46 net a press (PH'd 21 %), J1 NEUTRAL -25, the
band's Step -71 (its generic Step -> J lashes J1 into a close opponent), the dash in -52 / -62. The answers won: the
SAHARAI punish +106 (90 % hit), the K1 punish +66, the L-cancel K1 +149, the Hoho +81. Removing *answers* lost badly (no
anti-approach strike 0.338 -> 0.237, no escape hop 0.338 -> 0.242), which is what b1a0 measured; removing the *neutral
swings* won: no band J / K / Step 0.338 -> 0.371, and no dash in too **0.425** (+0.087, 240 matches).

Located leaks in the Bankai (same table): SAHARAI's hit cancel read at a distance the push was still carrying him through
(round01 b2a0's bug, in the parent too); the Breaker into a long guard 9 of 46 hit (-164 a press); the generic Breaker into
a parry 11 of 43 (-66); the generic J1 into a Breaker's dash at 4-5 m (outside the fence's 4.0 m); SP1 from the 6-10 m band 12
of 70 hit (its bar the noose's); KOSA from afar 8 of 46 hit (plain damage).

## The styles (行動方針) and the mix

| layer | roll | styles and weights / chances (EASY / NORMAL / HARD) |
|---|---|---|
| the Shikai, 始解鎖鐮連段 (round01 b3a0's, taken whole) | once a match (HS-AI-STYLE, SIM-RND01), by difficulty | **RENSA 連鎖** 0.55 / 0.55 / **0.8**, **KARIBA 刈場** 0.45 / 0.45 / 0.2; KAZAGURUMA-GAESHI, TODOME, the 3-step reap at HARD (per event) |
| the awakening | the kit gate `:awaken (:min-taken 2000)` (b1a0's, unchanged) | the Bankai once he has taken 2000 |
| **the ranged mode's posture, 待鎖 MACHI-GUSARI (new)** | every entry, every style | no J1 / K1 / Step / KOSA / SP1 from the neutral bands, no dash in: every route opens off an answer |
| the ranged route style, 卍解遠距路線 (b1a0's) | once per entry into the ranged mode (HS-R-STYLE) | **SENTAN 尖端 60 %**, **KAISEN 回旋 25 %**, **NAWAJI 縄路 15 %** |
| the bind, 捆綁 (b1a0's) | per change event | the release 150 behind on grey (0.05 / 0.1 / 0.9), KOJO per entry into 2.5-4 m |

**MACHI-GUSARI, the waiting chain (every Bankai, the cell's mechanism).** He stands at the chain tips' distance (4-5.6 m)
and swings at nothing that stands still. The chains move only as answers:
- **the strike into his approach** (HS-R-AI-REFLEX, 0.1 / 0.25 / 0.7 an approach): the style's opener timed so the victim
  walks onto its tip (SENTAN K1 at 4-5 m, KAISEN J1 at 5-6 m), then the route;
- **the punish by annulus** (0.2 / 0.35 / 0.9 an action): KUBIKAKE first with the 200, else the tip opener, else the one
  that reaches, SAHARAI inside 2 m;
- **SAHARAI's hit cancelled into K1** where the push leaves him (3.5 m), round01 b2a0's fix (the parent's
  cancel almost never fired; now 729 L-CANCEL K1s in 1200 HARD matches, 93 % hit), then the gathered route;
- **the Hoho** (the kit's 0.9) and its counter, then the punish;
- the escape hop out of 2 m (b1a0's; its generic Step -> J lash stays, ai.lisp's);
- the leaks closed: no Breaker into a long guard at HARD (`*hs-ai-r-guard-wait-p*` 0.6 / 0.75 / **1.0**), a parry up close
  waited out (its recovery is the punish's), the anti-Breaker over the generic's 5.0 m, no Kikon rush and no O ender off a
  victim not red in either Bankai mode (round01 b2a0's).

**The route styles (b1a0's, unchanged; the posture is theirs now).** SENTAN reaps from K1's tip and plays the gathered K
route (K1 -> K2 -> K3G, x1.71 on the tip, 313) with the noose off the ender; KAISEN lashes from J1's tip and plays the spread
J route (J3's 6.6 m push puts him back on the tip); NAWAJI throws the noose off the first link that hits. The mix was
re-measured under the new posture, each style forced (HARD, 1200 matches, seeds 1-50 + 101-150, proxy 0.3 str + 0.5 sig):
SENTAN 0.453 / 0.5622, KAISEN 0.455 / 0.5578, NAWAJI 0.422 / 0.5531, **the 60 / 25 / 15 mix 0.463 / 0.5649**: the mix
beats each pure style, so it is kept.

**NORMAL's fair game.** NORMAL keeps b1a0's ranged fence values (punish 0.35, anti 0.25, escape 0.35, dodge 0.2, anti-Breaker
0.35) and takes round01 b3a0's cuts of the noose and the bind (KUBIKAKE 0.1 -> 0.05, release 0.3 -> 0.1, the bind's SP 0.15
-> 0.1; EASY lower). The path (20 seeds): b0a0's Shikai layers at NORMAL put NORMAL at 0.629 (factor 0.81); b3a0's NORMAL
Bankai cuts 0.454; the waiting chain with those cuts 0.346 (the passive NORMAL Bankai, pacing to 192 s); b1a0's NORMAL fence
back 0.492, pacing to 180 s; **0.4896 at 40 seeds**. HARD values are not touched by any of it.

## What a human will notice

He opens as round01 b0a0 / b3a0's chain kusarigama (at HARD mostly RENSA: J1, the windmill flick, the long reaping K string,
lightning; the windmill comes up against your charge). Once you have hurt him for about a soul and a half, KARE, KAZESHINI:
the Bankai, earlier than in any other strong cell. Then he changes completely: he backs off to the chain's tip and **waits**.
He never swings at you while you stand there, never walks in. Walk in, and the bundle meets you on its tip and drags the
whole three-hit route out of it; whiff, and the chain punishes from wherever it reaches; get close, and he hops away or
sweeps you off with SAHARAI and lashes the bundle into you as you slide. At the route's end the noose goes round your neck
and the bind starts. One stretch in four he lashes from farther, the spread J route; one in seven the noose comes off the
first lash. A third of his damage is the Bankai's.

## Tried and dropped (measured)

| variant | result | verdict |
|---|---|---|
| no anti-approach strike (forced awakening, 240 HARD) | 0.338 -> 0.237 | the answers are what keep him alive |
| no escape hop (same) | 0.338 -> 0.242 | dropped |
| the hygiene fixes alone on the posture (same) | 0.425 -> 0.425 | kept for their logic (the leaks are gone from the log), no measured gain |
| the anti-approach waiting for its own opener's tip (SENTAN never J1) + Hoho / side Step against a red Kikon rush | forced 0.425 -> 0.400; aieval-20 0.7779 -> 0.7689 | dropped |
| 蓄縄 TAKUWAE-NAWA, the noose banked: 200 Reiatsu kept from 1400 taken (HARD only; prior b2a0's keep) | 1200 HARD: 0.463 / proxy 0.5649 without it, 0.460 / 0.5598 with it | dropped (the RAIDEN enders it forgoes cost signature) |
| gate 1500 / 2000 / 3000 / never (1200 HARD, with the keep) | 0.408 / 0.460 / 0.461 / 0.426; proxy 0.5410 / 0.5598 / 0.5667 / 0.5643 | 2000 kept: the Bankai now *adds* HARD wins (never 0.426; Kenpachi 15 -> 54 of 200), 3000 is +0.007 proxy but the ranged theme 0.21 -> 0.09 |
| no Step / L in the ranged 0-2 m band; no K1 / Step in the bind's 1.8-3.2 m band (1200 HARD) | proxy 0.5644 / 0.5641 vs 0.5649 | dropped (neutral) |

## Mechanisms implemented (CPU parts only)

- **Ported** (CPU hunks only, never a whole file): round01 b3a0's Shikai over b1a0's: `*HS-AI-STYLES*` by difficulty,
  `*HS-AI-REAP-SUSTAIN*` and the HSS slot `ai-app-n`; round01 b0a0's KAZAGURUMA-GAESHI (`*HS-AI-CHARGE-WARD-P*`,
  `*HS-AI-SWEEP-P*`, `*HS-AI-SWEEP-WAIT*`, `*HS-AI-CHARGE-FAR*`, HS-RANGED-MOVE-P, HS-CHARGE-SHOT-P, HS-CHARGING-P, HS-SEEN,
  HS-SHOT-PENDING-P, the slot `ai-hk`) and TODOME (`*HS-AI-TODOME-P*`); round01 b2a0's SAHARAI-cancel fix and its Bankai
  `:kikon-range 0` / `:o-ender 0`. Not ported: b3a0's gate, waking noose and ledger.
- **New (this cell)**: the ranged kit's `:moves` (no J1 / K1 / Step from 2 m out, no KOSA / SP1 from afar) and `:dash 0`;
  `*HS-AI-R-GUARD-WAIT-P*` (HS-AI-GUARD-WAIT takes a plist, the Bankai's reflexes pass it); HS-R-AI-REFLEX's parry wait and the
  red Kikon rush clause removed; HS-R-AI-ANTI-BREAKER over `*AI-ANTI-BREAKER-RANGE*`.
- **NORMAL / EASY values**: `*HS-AI-THROW-P*`, `*HS-AI-RELEASE-P*`, `*HS-AI-BIND-SP-P*` (above); every chance an (:easy :normal
  :hard) plist, EASY <= NORMAL <= HARD (host-pinned), rolled once per event (an action, an approach, a link hit, a guard
  episode, an entry, a match).
- **Not touched**: HS-AI-OPP and its knobs, every move, every rule and human hook, the art, every other file, HS-HASH, the sim
  ticks' human branches.
- **Kept working**: AI-AWAKEN-P (the kit gate only; the debug :always / :never modes win); the learner's read clock (the new
  reads act on events, :WAIT only during a parry seen up close); the ASSIST (its hooks read `ai-brain`; the new code is
  :reflex only); the debug modes 83000-83999 and the `duel hisagi` counters.
- **Host tests (the section)**: b3a0's Shikai pins (styles by difficulty, the 3-step reap, the charge / sweep / TODOME
  values, HS-RANGED-MOVE-P / HS-CHARGE-SHOT-P); the waiting chain's bands (nothing but SAHARAI / the Step inside 2 m, no
  dash, no Kikon rush or O ender in either Bankai mode); the SAHARAI cancel on a host fighter (at 2.0 m, the push still
  sliding: SENTAN's K1, where the parent pressed nothing; a block or another frame: nothing); the shipped NORMAL values and
  `*HS-AI-R-GUARD-WAIT-P*`. One parent pin changed with its contract: "some K1 band ending at 5.0 m" -> "no J1 / K1 band".

## Why it is not a repeat

The Shikai is reuse (b0a0 / b3a0's measured layers), stated as such. The new mechanism is in the ranged mode: every earlier
cell (b1a0 included) kept the bands' neutral J1 / K1 / Step and the dash in, and concluded the HARD ranged mode was
unfixable; the logs here split its actions into answers (net positive) and swings (net negative), and the posture that keeps
only the answers lifted the forced-Bankai HARD share 0.338 -> 0.425. With it the Bankai, for the first time in this search,
adds HARD wins at the 2000 gate (0.460 vs 0.426 never awakened, 1200 matches), so the ranged theme can show in most matches
without the strength cost b1a0 paid.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, NORMAL, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60 (this file / the baseline, b0a0's measure):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100 | 36 / 2 | 21 / 1 | 35 / 0 | 25 / 0 | 51 / 1 | 31 / 0 |
| 300 | 29 / 2 | 23 / 0 | 42 / 0 | 29 / 1 | 48 / 4 | 22 / 1 |
| 500 | 31 / 1 | 22 / 0 | 35 / 0 | 33 / 0 | 48 / 2 | 24 / 0 |

Every row is at least 21 of 60: the A/B passes (the bar is 20). All 1080 matches are K.O.s; the medians are 103.4-153.3 s.
The rows equal round01 b0a0's / b3a0's to the match: the never side is b0a0's NORMAL Shikai (b3a0's Shikai changes are
HARD-only). HK (21-23) stays the closest to the bar, as in those cells.

## Expected benefit and risks

- **Benefit**: +0.022 over the parent (0.7517 -> 0.7741), HARD 0.40 -> 0.448, signature 0.863 -> 0.879, with the ranged and
  bind themes at 0.317 of his damage: the cell where all three of the user's themes show in strength.
- **Below b2a0 / b3a0 by ~0.011** (inside 40-seed noise): the earlier Bankai's plain J1 (the generic Step -> J), Hoho counters
  and forced Kikons cost about 0.01 of signature; gate 3000 would buy it back at the ranged theme's expense.
- **Pacing**: the longest NORMAL median is 172.9 s (cap 220); the passive NORMAL Bankai once reached 192 s at 20 seeds before
  NORMAL's fence values came back. A change that makes NORMAL's Bankai more passive must re-check it.
- **NORMAL 0.4896** mid-band. Lille (0-1 of 200 at HARD), Ichigo and Kenpachi still beat him at HARD.

## Shared-code recommendations (not built)

- **ai.lisp's generic Step -> J** is now the ranged mode's largest leak: about 4 lashes a match at HARD off his escape hops,
  21 % hit, -40 net each, plain damage. A kit key (`:step-j` 0, or honouring `:min-reach`) would let the hop be a pure escape.
- **AI-AWAKEN-P is one gate for every difficulty** (every cell's note): NORMAL's Bankai and HARD's want different gates.
- (Standing) the forced O ender on a red victim leaves a kit no say: 0.035 of his damage is a plain Kikon across his forms.
