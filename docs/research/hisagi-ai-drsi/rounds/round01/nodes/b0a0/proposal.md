# b0a0: the Shikai chain, 鎖鐮連段 (RENSA / KARIBA), the Bankai as a last stand

Cell b0a0, round 1. Branch b0's primary style is the Shikai chain. It opens from BASELINE_DIR; PARENT_DIR is none. The
history held only the baseline. b1a0, the other round-1 cell, ran at the same time and had nothing written yet.

## The measurement (frozen evaluator, `python3 tools/aieval.py --char 7 --seeds 40 -j 2`)

| | baseline | b0a0 |
|---|---|---|
| **score** | **0.0** (raw 0.3848) | **0.637** (raw 0.637) |
| strength (HARD, 480) | 0.000 | **0.346** |
| masher (HARD, 224) | 0.107 | **0.670** |
| signature | 0.727 | **0.799** |
| sig_by | chain 0.436, ranged 0.178, bind 0.112, plain-j 0.128 | chain **0.791**, plain-j 0.102, hs-kikon 0.068, ranged 0.004, bind 0.004 |
| NORMAL share (factor) | 0.042 (0) | **0.540 (1.0)**: Y 39, K 26, R 54, I 37, S 63, Lille 40 of 80 |
| pacing (NORMAL medians) | 117-173 s | 103.8-159.3 s, every match a K.O. |

The score's JSON line is in `score.json`. The host tests pass: duel-rules 9883 ALL PASS, plus control 89, learn 131,
input 33, touch 64 and cine 18. pkgcheck is clean.

## The diagnosis (combat logs, `tools/simgate/run-log.lisp`)

These are damage rates by form, HARD Hisagi P1 against all six opponents, as shipped:

| form | dealt / s | taken / s |
|---|---|---|
| Shikai | 13.7-21.7 | 24-45 |
| Bankai ranged mode | **0.9-5.6** | 25-51 |
| bind | 6-26 | 22-38 |

The shipped CPU awakens at once (the kit has no `:awaken`), so most of each match is spent in the ranged mode, which is
a death zone. Even the button-masher beats it: the shipped Shikai wins its exchanges with the masher (29-38 dealt vs ~20
taken per second), and the ranged mode loses them (5 vs 36). These are the located bugs and losses, each with the fix in
this cell:

1. **The windmill's K string was dead.** HS-KAZA-TICK started K1 out of the windmill, but the CPU's L hold kept running
   (BRAIN-STEP's press countdown skips every reflex while a press is held), so after K1 no K2 / K3 was ever pressed. The
   K1 itself also waited for `dist > 3.1` while the bridge's push was still sliding, and missed the push's stagger. The
   log showed the bridge K1 at f32 instead of f9. Of 166 bridge K1s, 70 whiffed, 33 were blocked, and 56 were countered
   by a Hoho (the #1 opener against him). **Fix:**
   - The CPU branch of HS-KAZA-TICK lets L go when the K string starts.
   - HS-AI-KAZA-K presses K at the windmill's first K frame (f9) off a bridge that hit. K1 is active at f27, inside the
     push's 26 f stagger, by which time the push has carried the victim past the 3.0 m dead zone.
   - Off the bridge, HS-AI-SIG-HOLD always takes the K. HS-AI-MOVE already rolled the bridge.
   - Result: the bridge K1 hits 2086 of 2089 times at HARD, and K2 / K3 follow.
2. **SAHARAI spam (the ranged mode).** One roll per entry inside 2 m (0.85 at HARD) fired SAHARAI's 18 f startup into
   anything. Of 729 presses, 401 whiffed and 147 were blocked, and it was the top combo opener against him (COUNTER /
   J1). Its hit cancel was never used: the CPU guard-cancelled, and the generic ORANGE burned the flash-step. **Fix:** no
   neutral SAHARAI. HS-R-AI-REFLEX's punish (HS-R-PUNISH-CMD) uses SAHARAI only inside 2 m on an opponent seen
   recovering or reeling. It uses K1 to 5.2 m and J1 to 6.2 m, and each fires only when its startup + 1 frame is left. A
   SAHARAI hit is cancelled into K1 or J1 (HS-R-AI-MOVE, buffered to S + A) by a per-style route taste.
3. **Generic J1 answers misfire because of his reach.**
   - Against a Breaker, the generic J1 waits for the dash. Up close the strike comes 8 f after a 12 f aura, so the J1
     came 0-6 f late: 123 combos at HARD. Fix: J1 in the aura, but only while `aura frames + perception delay <=
     *BREAKER-AURA*`, the frames in which it can still land first. HARD sees it; NORMAL's 14 f delay never does.
   - In the ranged mode the J1 / K1 dead zones whiffed 126 of 129 anti-Breaker J1s. Fix: a side Step instead.
   - The generic J1 punish whiffed inside the ranged J1's 3.0 m dead zone. Fix: `:WAIT` there while the opponent
     recovers, and HS-R-PUNISH-CMD covers the punish.
4. **Passive neutral guard.** This was the largest NORMAL lever. The kit's `:guard` doubles as the neutral "hold guard
   within 3.4 m" chance. Measured at 480 NORMAL / 120 HARD matches:

   | setting | NORMAL | HARD |
   |---|---|---|
   | `:guard` 0.55 | 0.19 | 31 / 120 |
   | `:guard` 0.4 | 0.30 | 24 / 120 |
   | `:guard` 0.3 | 0.33 | 28 / 120 |
   | `:guard` 0.2 | 0.38 | 33 / 120 |
   | `:guard` 0.35 with `:neutral-guard` 0.1 | **0.56** | 35 / 120 |

   Standing in guard fed the opponents' Breakers and pressure. **Fix:** `:guard 0.35 :neutral-guard 0.1`.
5. **His Kikon rushes whiff.** KARI is aura 6 + S 20 along a locked lane, so a neutral or reeling-red rush misses: 128
   of 147 at NORMAL. The O ender off a completed string hits 98 %. **Fix:** `:kikon-range 0.0` in the Shikai and the
   ranged mode, which leaves the O ender only (the bind keeps 3.0).
6. **The Breaker against a held guard.** The generic Breaker whiffed 70 of 103 at HARD, because the stronger CPUs J it.
   **Fix:** HS-AI-GUARD-REFLEX takes that guard episode's roll (brain-break-key) and waits it out *HS-AI-GUARD-WAIT-P*
   (0.6 / 0.75 / 0.9) of the time. The neutral Breaker and the neutral SHIBARI (45 of 86 whiffed) left the Shikai
   bands. SHIBARI stays as the ender after RIN.
7. **The late awakening.** Gate `:awaken (:min-taken 4500)` in the Shikai's `:ai`, which AI-AWAKEN-P reads. The debug
   :always / :never modes still win.

   | awakening | NORMAL | HARD |
   |---|---|---|
   | at once (shipped) | 4 / 120 | 0 / 120 |
   | min-taken 3000 | 0.258 | 0.20 |
   | min-taken 4500 | 0.292 | 34 / 120 |
   | never | 0.30 | 35 / 120 |

   These were measured before fix 4 (the neutral guard), at 480 NORMAL / 120 HARD matches. In the final build he
   awakens in 42 of 240 HARD matches and 25 of 480 NORMAL ones. That is a last stand: the combo break, the 20 % heal,
   then KUBIKAKE into the bind, which nearly breaks even (20.1 dealt vs 18.3 taken per second at HARD).
8. **Smaller fixes:**
   - The generic `:string-k` 0.7 → 0.0. HS-AI-MOVE now picks every link. The generic one only opens a string off a
     Breaker hit, where K1's dead zone whiffed every time (39 of 39).
   - `:block-string` 0.6 → 0.25.
   - `:dash` 0.6 → 0.25 in the Shikai, 0.3 → 0 in the ranged mode.
   - The ranged `:block-string` 0.4 → 0.

Tried and dropped:
- No neutral K1: roughly neutral, and less signature.
- A K1 timed into the opponent's run: it never fired, because the run window falls past 7 m.
- Guarding a masher's J: no gain.
- `:guard` 0.45 with `:neutral-guard` 0.05: NORMAL 0.65, over the band.

## The styles (rolled once a match, HS-AI-STYLE, SIM-RND01, a CPU slot on his fresh-per-match HSS)

| style | weight | what it does (Shikai) | HARD wins (P1 seat, 240) |
|---|---|---|---|
| **RENSA 連鎖** (the chain link) | 0.55 | Rushdown. J1 up close, then off a J hit the **windmill bridge** (L) into the charged K string at f9: J → L → K1 → K2 → K3, then RAIDEN. Bridge chance 0.3 / 0.6 / 0.85, else K2J (0.5 / 0.7 / 0.8). The leap J2K / J3K off K1 / K2 with his intent close: 0.3 / 0.5 / 0.7. Rarely the O ender (0 / 0.05 / 0.1); the bar goes on RAIDEN (the chain theme). | 53 / 136 (0.39) |
| **KARIBA 刈場** (the reaping ground) | 0.45 | Holds K range. **K1 punishes** any whiff seen at 3.2-6.2 m (0.15 / 0.3 / 0.85). Off a J hit the K link first (K2J: 0.6 / 0.8 / 0.9), bridge less (0.15 / 0.3 / 0.45). Leap less (0.2 / 0.35 / 0.5), so K1 → K2 → K3 at range. Finishes with the O ender more (0.05 / 0.15 / 0.25). | 35 / 104 (0.34) |

Both styles share the rest:
- The windmill against ranged threats (0.3 / 0.6 / 0.9, one roll a threat).
- The windmill's charged K1 from far (the bands).
- Against a J masher (AI-MASH-P) the O ender 0.3 / 0.6 / 0.9: the masher punished a RAIDEN-only finish (masher 0.79
  → 0.62).
- The awakening and the Bankai.

In the late Bankai the styles differ only in SAHARAI's cancel: RENSA takes K1 (the gathered route) 0.6 of the time,
KARIBA 0.4.

Every chance is an (:easy :normal :hard) plist (by style where it has one), rolled once per event: per hit, per
opponent action (HSS ai-pk), per guard episode (brain-break-key), per threat, or per match for the style. The host test
pins the ordering, EASY <= NORMAL <= HARD. NORMAL's values sit below HARD's (e.g. bridge 0.6 vs 0.85, K1 punish 0.2 /
0.3 vs 0.55 / 0.85, SP ender 0.4 vs 0.8), which keeps NORMAL at 0.54. NORMAL got stronger with more of HARD's values:
0.57 with them, 0.65 with the HARD-leaning guard.

## What a human will notice

- He fights in the Shikai almost the whole match.
- **RENSA**: once a J lands up close, the windmill comes up and the charged chain reaps him three times (K1 → K2 → K3),
  then lightning.
- **KARIBA**: he keeps 3-6 m away, punishes every whiff with the sideways chain sweep, and drags the string out at
  range.
- He rarely stands in guard. He doesn't throw SAHARAI blindly, and he doesn't Breaker a turtle.
- The Bankai appears only when he is losing badly, as a last stand that goes for KUBIKAKE and the bind.

## Mechanisms implemented (all in `duel/lisp/hisagi.lisp`'s CPU parts)

- **New functions:** HS-AI-STYLE, HS-SP (the style × difficulty chance), HS-K1-PUNISH-OK-P, HS-AI-GUARD-REFLEX (both
  free reflexes' first answers: the Breaker aura J1 / the ranged side Step, the guard-episode Breaker roll),
  HS-BRIDGE-P, HS-R-PUNISH-CMD.
- **Rewritten:** HS-AI-REFLEX (+ the K1 punish), HS-AI-SIG-HOLD (the bridge always K), HS-AI-KAZA-K (the bridge K at
  f9), HS-AI-MOVE (the J-link route pick: bridge / K / J, by style), HS-AI-ENDER (the O ender by style and against a
  masher, else the SP), HS-R-AI-REFLEX (the punish, no neutral SAHARAI), HS-R-AI-MOVE (+ the SAHARAI hit cancel).
- **The CPU branch of HS-KAZA-TICK:** `(brain-press-left b) 0` when the K string starts.
- **Knobs:** *HS-AI-STYLES*, *HS-AI-BRIDGE-P*, *HS-AI-JK-P*, *HS-AI-STYLE-LEAP-P* (which replaces *HS-AI-LEAP-P*),
  *HS-AI-K1-PUNISH-P*, *HS-AI-O-ENDER-P*, *HS-AI-O-ENDER-MASH-P*, *HS-AI-AWAKEN*, *HS-AI-ANTI-BREAKER-P*,
  *HS-AI-GUARD-WAIT-P*, *HS-AI-R-PUNISH-P*, *HS-AI-SAHARAI-K-P*. *HS-AI-SAHARAI-P* is removed. *HS-AI-STRING-K* is
  0.7 → 0.0. Several NORMAL values were moved.
- **HSS CPU slots:** `ai-style`, `ai-pk`. The unused `ai-go` is removed. None of them is hashed.
- **Pacing counters:** `style-rensa` / `style-kariba`, `ai-bridge`, `ai-k1-punish`, `ai-o-ender`, `ai-r-punish`,
  `ai-saharai-k` / `-j`.
- **Not touched:** HS-AI-OPP and its knobs, every move, every rule, the art, every other file. Of the tests, only the
  HISAGI-CPU-TESTS section changed: it pins the styles, every plist's ordering, the awaken gate, the Kikon range, the
  bands, HS-K1-PUNISH-OK-P and HS-R-PUNISH-CMD.
- **The ASSIST:** the hooks read `(ai-brain e)`. HS-KAZA-TICK's brain branch stays HS-TICK-BRAIN's (his own CPU).

## Why it is not a repeat

There was no history beyond the baseline. The baseline's styleless CPU had a dead windmill string, awakened at once,
and spammed SAHARAI. This cell is a structurally different policy: a Shikai-first plan with two named styles, the
located bridge / hold bugs fixed, and the awakening moved to a late gate.

## Expected benefit and risks

- **The benefit:** a large score gain (0 → 0.637), and chain-themed damage (0.79 of his damage is the chain).
- **The ranged and bind themes almost vanish** (0.004 each), because he rarely awakens. A mix cell (b3, or a refine)
  should combine this Shikai with a repaired ranged mode. The ranged mode is still 5.8 dealt vs 24.6 taken per second.
  The remaining causes are generic ones listed below, plus its own slow neutral pokes (J1 / K1 Hoho'd).
- **NORMAL 0.54** is within 0.06 of the band's top. A change that strengthens NORMAL (HARD's values, less guard) crosses
  0.60.
- Pacing is far from its cap (max median 159 s).
- **The masher is 0.67.** The masher's Rukia and Hisagi beat him: 5 / 32 and 17 / 32. Against Rukia he deals more
  damage (30 vs 21 per second) but loses on souls: his red Kikons take 2, the masher's Soul Breaks take 3.

## The awaken A/B (Hisagi P1 never awakening, `--cmd 39020`, 60 seeds a stream; pairs 28 29 30 31 32 34)

The never-awaken side's wins of 60 per stream, next to the baseline's (the same command on BASELINE_DIR/hisagi.lisp):

| stream (seed0) | HY | HK | HR | HI | HS | HB |
|---|---|---|---|---|---|---|
| 100: b0a0 / baseline | 34 / 2 | 25 / 1 | 38 / 0 | 33 / 0 | 49 / 1 | 30 / 0 |
| 300: b0a0 / baseline | 31 / 2 | 27 / 0 | 38 / 0 | 29 / 1 | 45 / 4 | 23 / 1 |
| 500: b0a0 / baseline | 34 / 1 | 25 / 0 | 36 / 0 | 32 / 0 | 51 / 2 | 26 / 0 |

Every b0a0 row is at least 20 of 60, so the A/B passes. The baseline fails every row. Every match is a K.O. The medians
are 109-163 s; HR has the longest, 158.6-162.6 s.

## Shared-code recommendations (not done: outside this cell's scope)

- **ai.lisp, the generic J1 answers:** J-BEATS-OPEN-P, the PUNISH / FOLLOW-UP / STEP-J / BLOCK-PUNISH / ANTI-BREAKER
  reflexes, the reset and AI-ATTACK's "don't whiff a string at range" all read only `(mv-reach q)`. They should also
  respect the move's `:min-reach`. Hisagi's ranged J1, a 3-6 m annulus, whiffs every one of them up close: J-BEATS-K 50
  of 50 against the masher, STEP-J 134 of 168 at HARD.
- **ai.lisp, the anti-Breaker J1:** it is pressed only in the dash phase, after a 12 f aura. Against a Breaker
  triggered up close it is late for every character. It should be pressed in the aura when `aura frames + delay <=
  *BREAKER-AURA*`, as HS-AI-GUARD-REFLEX does here.
- **The kit `:guard` doubles as the neutral standing guard:** every kit without `:neutral-guard` may be losing NORMAL
  matches to it, as Hisagi did (0.30 → 0.56).
