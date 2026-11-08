# Seed strategies (DUEL_AI_STRATEGY §7 step 3)

Five data files in the §2 format (`duel/lisp/strategy.lisp`), run with `tools/simgate/strat-run.lisp`. All are character-agnostic (cues
are kit-relative). Each header comment names the KI behaviour it borrows.

| id | idea | main levers |
|---|---|---|
| `s0-generic` | the current generic core CPU, no base, no rules (strategy 0) | none |
| `s1-brawler` | close-range pressure: walk in to ~1.2-2.1 m, J1 / Step-in over waiting, rarely Hoho, go on after a hit, awaken early, press a knockdown | `:range 0.7`, `:b-walk-in/:b-j1` up, `:b-wait` down, `:hoho 0.5`, `:awaken 3` |
| `s2-punisher` | whiff-punish / counter: hover just outside his reach, wait, answer his committed move (J1 / Step-in / NS when his move is active and he is out of reach), Hoho and the AS/SA read more often | `:range 1.2`, `:b-wait` up, `:hoho 1.8`, `:turn 1.4`, rules on `:ost :active` x `:do :out/:afar` |
| `s3-zoner` | spacing with the NS: wide range, NS share 0.9, shoots a wave from afar, backs off inside his J1 reach, Kikon only on a red opponent | `:range 1.5`, `:ns 0.9`, `:b-sp` at `:dn :reach/:out`, `:kikon` 0.4 / 1.6 on `:ored` |
| `s4-discipline` | reach discipline + knockdown pressure + lead-switched: never start a J1 / NS that cannot reach (walk in instead), Hoho only through an active move at my reach; ahead on Konpaku = patient, behind = pressure and awaken | `:b-j1`/`:b-sp` negative at `:out/:afar`, `:lead :ahead/:behind` rules |

## Wins (10 seeds a cell, seeds 30000..31110, wins of the strategy's character; "none" = no strategy, his KI style CPU if one exists)

Strategy replaces the character's style CPU (`strat-run.lisp` removes it). Opponent: its default CPU (style CPU in KI).
Kenpachi = P2 in pairing 2132; Ichigo = P1 in 2132; Hisagi = P1 in 2164 (vs Kenpachi, no style CPU in KH).

HARD (81022):

| character | none | s0 | s1 | s2 | s3 | s4 |
|---|---|---|---|---|---|---|
| Kenpachi (vs Ichigo style) | 9 | 0 | 0 | 0 | 0 | 0 |
| Ichigo (vs Kenpachi style) | 1 | 0 | 0 | 0 | 0 | 0 |
| Hisagi (vs Kenpachi) | 1 | 1 | 0 | 1 | 2 | 0 |

NORMAL (81021):

| character | none | s0 | s1 | s2 | s3 | s4 |
|---|---|---|---|---|---|---|
| Kenpachi | 6 | 6 | **10** | 2 | 3 | 6 |
| Ichigo | 4 | 2 | 4 | 0 | 0 | 2 |
| Hisagi | 2 | 2 | 2 | 2 | 1 | 1 |

HARD with the opponent also on `s0-generic` (no style CPU on either side; the fair read of a strategy's own strength):

| character | s0 | s1 | s2 | s3 | s4 |
|---|---|---|---|---|---|
| Kenpachi (vs Ichigo s0) | 10 | 10 | 10 | 9 | 10 |
| Ichigo (vs Kenpachi s0) | 0 | 2 | 1 | 0 | 2 |
| Hisagi (vs Kenpachi s0) | 1 | 0 | 1 | 2 | 0 |

Reading (10 seeds: +-3 is noise):
- The gap that matters: at HARD the style CPU (`none`) beats the same character on s0 by 9-0 (Kenpachi) and 1-0 (Ichigo) against the
  other's style CPU; no seed strategy closes it. The format as it is cannot reproduce the style CPUs' strength (list below).
- Against a generic opponent the strategies are within noise of s0 for Kenpachi / Hisagi; Ichigo gains 1-2 wins with s1 / s4.
- NORMAL separates them: s1-brawler is clearly the best for Kenpachi (10/10), s2 / s3 (passive, long range) hurt Kenpachi and Ichigo.
  So the seeds are behaviourally distinct (not duplicates), and the same files ran for all three characters.
- Not yet measured: behaviour descriptors / fingerprint similarity (needs the evaluator, step 4).

## What the KI style CPUs do that the current output keys cannot express

Keys today: action biases (`:b-j1 :b-sp :b-hoho :b-step-in :b-step-out :b-step-side :b-wait :b-walk-in :b-walk-out`), `:range`, `:ns`,
and scales `:hoho :turn :cont :kikon :awaken`.

| KI behaviour | why it is out of reach | proposed output key |
|---|---|---|
| Meaty on wake-up (press so the hit lands on the frame he gets up; Kenpachi's 64-a-loop J1, Ichigo's meaty) | a bias on J1 cannot choose the timing; needs his down-state frames remaining | `:meaty` (0-1 scale of "time the press to his wake-up frame"), with a cue `:wake` (frames until he is actionable, as a fraction) |
| Whiff punish with the fastest move that lands in his recovery (Ichigo `*IKS-PUNISHERS*`) | no move choice, no recovery-frame cue; `:ost :active` lumps active + recovery | cue `:rec` (frames of his recovery left / my fastest punisher's startup) and output `:punish` (scale of firing it) |
| Perfect/timed Hoho window (Ichigo's counter, Kenpachi's Hoho through the wave) | `:hoho` scales the chance only, not the timing | `:hoho-time` (0 = early/as now, 1 = last frame of the window) |
| Bankai / Shikai entry, L3 cash-out, form planning | `:awaken` is the only form lever, no level cue | cues `:lvl` (form level 0-3), `:form`; outputs `:cashout` (end a string with the SP at L3), `:bankai` |
| Pointer choice (Ichigo's pointer 3 hunting, "string to J5 + SP"; Kenpachi's pointer 3 tame) | no pointer output | `:ptr` (preferred pointer 1-3, applied as a bias) and `:string-end` (press the SP at string length n) |
| Kikon only when worth more than the Soul Break (red check, K.O. check) | `:kikon` is a scale of the chance, red rules only via `:ored` | cue `:kok` (Kikon would K.O.), `:kval`; `:kikon` rules can then key on them |
| Reach by closing speed (Kenpachi `KEN-CLOSING`: shrinks reach by his speed away) | `:dj` is static distance | cue `:close` (his closing speed) |
| Stale-SNAP waits (8 f after cinematics / Burst) | pure perception correction | not a strategy item: keep in the action layer |
| Hover band 2.3-2.7 m (bait into his NS start, outside his J1) | `:range` scales the whole lo-hi band uniformly | `:range-lo` / `:range-hi` separately (two keys) |
| Dodge by back Step on a reachable move | `:b-step-out` is neutral-only, not a reaction | `:dodge` (scale of Step-out/Hoho when his move is reachable) |
| Burst / awakening break in his combo | `:awaken` is neutral only | `:break` (scale of the combat-time burst/awaken) |

Verdict: the format must grow by a handful of keys (`:meaty :punish :hoho-time :ptr :string-end :range-lo/hi :dodge :break`) and
cues (`:wake :rec :lvl :kok :close`) before the strategy layer can match the style CPUs (DUEL_AI_STRATEGY §6 bar); the current
keys alone only reach NORMAL-level variety.

Reproduce: `STRAT_<CHAR>=<seed file> LD_PRELOAD=build/simgate/muslm.so ecl --norc --load tools/simgate/strat-run.lisp -- build/simgate/duel.fas 2102 81022 30000 31110 2132`
(count `gate row ... winner P1/P2`). The opponent-on-s0 table adds `STRAT_ICHIGO` / `STRAT_KENPACHI` = `s0-generic.lisp`.
