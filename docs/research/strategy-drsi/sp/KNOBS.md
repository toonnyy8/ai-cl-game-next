# KNOBS: what a strategy arm can actually move (API sheet for search agents)

Traced from the sources on 2026-11-14 (all paths under `duel/lisp/` unless noted). An arm is `(:id .. :fn STYLE :base (k v ..) :rules ((((cue set) ..) (k v ..)) ..))`.
Where I am not sure, the text says so.

**Update 2026-11-14 (style knobs, §6):** the KI / KH style CPUs now read 53 of their own tunables through `style-knob` (strategy-glue.lisp), so an arm whose `:fn` is that style sets them as data: `:kk-*` (Kenpachi, 25), `:kso-*` / `:khf-*` (his KH styles, 4), `:iks-*` (Ichigo, 24). Where the text below says a style's constants are "not arm keys", §6 is current.

## 0. The one fact that explains "byte-identical" edits

The step order in `core-brain-step` (core-ai.lisp:213-260, the press chain at 238-243) is:

1. the arm's `:fn` (core-ai.lisp:240). If it returns T the step is over.
2. `mc-neutral`, the in-game MCTS (core-ai.lisp:242). This is the ONLY reader of the `:b-*` biases (`mc-est`, cpu-mcts.lisp:116-119).
3. the matchup style CPU, only when NO strategy is active (core-ai.lisp:243: `(not cur)`).
4. the generic core CPU: `cai-neutral` / `cai-move-step` (core-ai.lisp:174 / 132), which read the scale keys.

Consequences:
- **An arm with no `:fn` never runs a style CPU.** `--cand none` (no strategy) does run it as the anchor; an arm without `:fn` plays MCTS + generic CPU.
- **A style that returns T at every free step starves the MCTS, so every `:b-*` key is inert for it.** `ken-ki-style` does exactly this (see 2.1). A `:rules` entry that sets only `:b-*` keys on such an arm cannot change a single press: the match is byte-identical. That is the observed failure, not a bug in `:lead`.
- A key read only on a path the style never reaches is inert in the same way. Check the tables below before spending an attempt.

## 1. How `:rules` and `:base` are evaluated (all arms)

| Item | Fact | file:line |
|---|---|---|
| Per key | zero-order Sugeno over the rules that NAME that key: `num/den` with weight w = strength; **if any such rule has w > 0 its average REPLACES `:base`** (not added). If none fires: `:base` value; if `:base` lacks it too: NIL = the CPU's own default. | strategy.lisp:23-34 |
| Strength | AND = min over the antecedents' memberships. Rules are independent per key: a rule naming `:b-j1` and `:b-wait` contributes to each key separately. | strategy.lisp:18-21 |
| Consequence | A rule that fires at w = 0.1 still replaces the base outright (weights only matter relative to other firing rules). So a rule is "base unless cue", with a blend between rules. Never additive. | strategy.lisp:33-34 |
| Cue source | `strat-feats` every step. A cue name not in it reads **0** (`getf feats cue 0`), so a typo or a `strat-xfeats` name (`:mcell :dm :wall :form ...`) in an ARM's rules reads 0 and silently fires `:no` / `:low` / `:free` at 1. | strategy.lisp:20, strategy-glue.lisp:22 |
| xfeats | `strat-xfeats` (:dm :form :oawk :gauge :wall + SP cues :mcell :ocell :mburst :oburst :xch) are appended ONLY in a Q selector's judgement (strategy-glue.lisp:~70). An arm's own `:rules` never see them. | strategy-glue.lisp:38-47, 70 |
| Set name | Must exist in `*fz-sets*`; an unknown set name errors (`svref` of NIL) at the first evaluation. | engine/lisp/fuzzy.lisp:18-24 |
| Where read | `strat-out now key default` (value or default; strategy.lisp:48) and `strat-scale now key p` (p x value, clamped 0-1; strategy.lisp:53). `now` = (arm . feats) set at core-ai.lisp:226-227. | |
| `:p` | A prior weight read only by `strat-prior` in the strategy layer (strategy-glue.lisp:~151), and `*strat-layer*` defaults to NIL (strategy.lisp:214). Inert in `eval.py` runs unless that harness turns the layer on (I did not check). | strategy.lisp:2876 |

### Cues (strategy-glue.lisp:22-36) and their fuzzy sets (fuzzy.lisp:17-37)

| Cue | Meaning | Range | Sets (trapezoid a b c d) |
|---|---|---|---|
| `:dj` | d / reach of my command move (Q, "J1") | 0..~8 | `:in` (-99 -99 .8 1.0), `:reach` (.8 1.0 1.2 1.5), `:out` (1.2 1.5 2.0 2.6), `:afar` (2.0 2.6 99 99) |
| `:dn` | d / reach of my current pointer's NS (`kit-core-move :ns (mc-ptr f)`) | same | same four |
| `:do` | d / reach of HIS command move | same | same four |
| `:lead` | my Konpaku minus his (integer) | integers | `:behind` (-99 -99 -1 0), `:even` (-1 0 0 1), `:ahead` (0 1 99 99). On integers: 0 is only `:even`; any nonzero is fully `:behind` or `:ahead`; `:even` has w = 0 at +-1. |
| `:mr` / `:or` | my / his Reishi fraction | 0..1 | `:low` (-1 0 .25 .5), `:high` (.5 .75 1 2) |
| `:ored` `:hoho` `:wave` `:awk` | crisp 0/1: he is red / my Hoho ready / my pointer's NS is a wave / I am awakened | 0, 1 | `:yes` (.5 1 1 1.5), `:no` (-.5 0 0 .5) |
| `:ost` | his perceived state class: 0 idle/run/guard, 1 in a move before its hit window (startup), 2 in a move past it, 3 step/hoho, 4 anything else (air, down, stun, wakeup, cine) | 0..4 | `:free` (0), `:startup` (1), `:active` (2), `:evade` (3), `:down` (4) as peaks; `:busy` (.5 1 99 99) |

Any set name in `*fz-sets*` may be applied to any cue (e.g. `:near` / `:mid` / `:far` are in metres, meaningless on `:dj`). Distance sets only make sense on `:dj :dn :do`; the `:ost` sets only on `:ost`.

Delta keys and where they are read (the only keys that do anything for these three styles' kits; everything else is dead):

| Key | Value meaning | Read at | Effect |
|---|---|---|---|
| `:b-j1 :b-sp :b-hoho :b-step-in :b-step-out :b-step-side :b-wait :b-walk-in :b-walk-out` | additive bias (Konpaku units, MCTS values ~0.01-0.3) on the macro action's estimate. `:b-guard` does not exist (action 6 has no key). | `mc-est` cpu-mcts.lisp:116-119, via `*strat-bias-keys*` strategy.lisp:15, order of `*mc-actions*` mcts-lite.lisp:19 | only when `mc-neutral` runs (2 above) |
| `:range` | scale on the walk-in band (lo, hi) = (first/second of the kit's `:range`, default `*cai-range*` (1.7 3.0), core-ai.lisp:10) | `cai-neutral` core-ai.lisp:178-179 | where the generic CPU walks to / decides to start a move (decisions at d <= hi + 0.6) |
| `:ns` | REPLACES the NS share of an in-range decision (default `*cai-ns-near*` .45 at d <= 1.7, `*cai-ns-far*` .8 beyond; not scaled, a roll < value) | core-ai.lisp:197 | NS vs J1 at the generic CPU's decision |
| `:awaken` | scale on `*cai-awaken-p*` (.02 per decision once the gauge is full), clamped 0-1 (so 3.0 gives .06) | core-ai.lisp:190 | generic CPU's awaken |
| `:hold-awaken` | fraction H: no awakening while Sublimation < H x max (via `gauges-awakened-ok-p`, which the styles also call) | strategy-glue.lisp:49-54, core-ai.lisp:201 | blocks every awaken press incl. the styles' |
| `:hoho` | scale on `*fz-hoho*` (Hoho out of an attack at him) | `cai-fz` core-ai.lisp:41-48, used in `cai-neutral` core-ai.lisp:180-183 | generic reactive Hoho |
| `:turn` | scale on `*fz-as-now*` and `*fz-ns-turn*` (AS / SA read) | `cai-move-step` core-ai.lisp:132-170 | in-string AS choice, NS-gap SA read |
| `:cont` | scale on `*fz-ns-cont*` (continue the NS route) | core-ai.lisp:~160-168 | NS next segment |
| `:kikon` | scale on `*fz-kikon*` (hold an SP into a Kikon) | `cai-sp` core-ai.lisp:61-69 | EVERY SP press, style's or generic |
| `:other` | scale on the rest (`*fz-burst*`, `*fz-cancel*`: the Burst / Kikon-cancel chance) | `cai-fz` fallthrough | Burst and cancel |
| `:dswitch` `:dswitch-map` | DRIVE switch chance in an NS gap (x `*cai-dswitch-dif*`, HARD 1.0); no key = never | `cai-dswitch` core-ai.lisp:102-111 | needs `core-switch-open-p` (awakening gauge full once, SP > 0: core-sim.lisp:126). Reached only through `cai-move-step`'s `:ns` branch. |
| `:fn` | the style | core-ai.lisp:240 | |
| `:hk-pot :hk-kite :hk-wake :shikai-dswitch :ken-ranged` | Hisagi's styles only | cpu-hk-hisagi.lisp:122-140, cpu-hisagi-range.lisp:182-184 | inert for Kenpachi / Ichigo |
| `:id :apply :p` | bookkeeping / strategy layer | | inert in play |

## 2. Per style

A style's own constants (`*kk-...-p*`, `*iks-...*`) are `defparameter` plists by difficulty; before 2026-11-14 no `:base` key reached them. Since then the 53 of §6 are arm keys (`style-knob`); the rest still are not. They see the arm only through the shared helpers `cai-neutral`, `cai-move-step`, `cai-sp`, `gauges-awakened-ok-p`.

### 2.1 `ken-ki-style` (cpu-ki-ken.lisp:772-813; also :id :a-ken-ki's `:fn`)

Flow per free step: track state and meaty (`kk-track`), then in `:idle :run :move`: `(or (kk-neutral | kk-move kk-link kk-as-on kk-ns-whiff kk-l3-sa) (cai-neutral | cai-move-step))`, then `kk-kikon-rule`, then **always T** (cpu-ki-ken.lisp:806-812). So:

| Key | Live? | How |
|---|---|---|
| `:b-*` (all nine) | **INERT** | the style returns T in `:idle :run :move`, so `mc-neutral` never runs. (A step in `:step`, `:stun` etc. is not a free neutral for the MCTS either: `mc-neutral` needs `:idle :run`.) |
| `:range` | live, partial | only when `kk-neutral` declines and `cai-neutral` walks (decide-t > 1, or `kk-pick` outside `hi+0.6`). Note `kk-pick`'s own band uses the kit `:range` hi unscaled (cpu-ki-ken.lisp:588-590), so the scale moves the walking band but not the decision-zone test. Weak. |
| `:ns` | live, weak | only in `cai-neutral`'s decision (core-ai.lisp:197), reached when `kk-neutral` returns NIL at a decision step: `kk-pick` decides first at HARD (its own *cai-ns-near/far* test inside, cpu-ki-ken.lisp:607, unscaled), so mostly shadowed. |
| `:awaken` | live | `kk-neutral` rolls `*kk-awaken-p*` itself (cpu-ki-ken.lisp:628-629); the arm's `:awaken` is only reached through `cai-neutral` (core-ai.lisp:190) in Nozarashi / when kk declines. Treat as weak. |
| `:hold-awaken` | **live, strong** | `gauges-awakened-ok-p` gates both `kk-neutral` (628, 630) and `cai-neutral`. |
| `:hoho` | live, weak | `cai-neutral` Hoho (core-ai.lisp:180) after `kk-read`/`kk-wake-hoho` declined. `kk-read` (the dodge, `*kk-dodge-p*`) and the wake Hoho are unscaled. |
| `:turn :cont` | live | `cai-move-step` is the fallback when `kk-move kk-link kk-as-on kk-ns-whiff` all return NIL. The style's own string logic (`*kk-link-p*`, `*kk-ns-stop-p*`, `*kk-as-on-p*`, `*kk-as-read-p*`) takes the usual cases first. |
| `:kikon` | live, strong | every SP goes through `cai-sp` (cpu-ki-ken.lisp:388, 509-552, 610, 682); `kk-kikon-rule` then cuts the hold with `*kk-kikon-red-p*` / `*kk-kikon-ptr-p*` (not arm keys). |
| `:dswitch` | live (rare) | via `cai-move-step`'s `:ns` branch. I did not verify that Kenpachi's kit ever has `core-switch-open-p`. |
| `:other` | live | Burst / cancel through `cai-fz`, when the generic stun branch runs (kk returns NIL in `:stun`/`:air`, so core-ai.lisp:244+ runs). |

What the style's constants do (set in the file; all of these are arm keys since 2026-11-14, §6): `*kk-reach-p*` (:34) approach discipline, `*kk-hoho-in-p*` (:95, 0 at all difficulties), `*kk-ns-safe-p*` (:214) Hoho-safety, `*kk-meaty-p*` (:111), `*kk-step-in-p*` (:238), `*kk-dodge-p*` (:62), `*kk-awaken-p*` (:127), `*kk-kikon-red-p*` (:90), `*kk-wave-p*` (:172).

### 2.2 `ken-kh-standoff-style` over `ken-ki-style` (cpu-kh-ken.lisp:86-95)

It is `ken-ki-style` unchanged until the stand-off is old, so every row of 2.1 applies; its added knob is data in `*kso-...*`, not an arm key.

| Piece | Value | file:line |
|---|---|---|
| Clock (`kso-old-p`) | frames since ANY of the four gauges (both Reishi, both Konpaku) last changed; a change resets it | cpu-kh-ken.lisp:77-84 |
| Trigger | clock > `*kso-stale*` (EASY 900, NORMAL 540, **HARD 120** frames) AND Kenpachi is not winning the bell | :60, :80-83 |
| "Winning" (`kso-winning-p`) | my Konpaku > his, or equal and my Reishi fraction exceeds his by more than `*kso-lead*` (0.0) | :62, :70-74 |
| Effect | `ken-ki-style ... :safe '(0 0 0)`: the Hoho-safety roll (`*kk-ns-safe-p*`) is forced to 0, so `kk-ns-open-p` is never required and he starts J1 / the NS into an idle opponent; the approach roll is redone once at onset (`kks-appr` NIL) | :90-94 |
| Not winning the bell | normal `ken-ki-style` (patience) | :89 |
| Arm keys | `:kso-stale`, `:kso-lead` (§6); `:safe` is a code argument and beats the arm's `:kk-ns-safe-p` while the breaker is on |

`ken-kh-style` (the other, :st-ken-kh): the wake-up bait (cpu-kh-ken.lisp:26-48): on Hisagi's knockdown, roll `*khf-bait-p*` (HARD 1.0); if yes it holds at 2.3 m (`*khf-bait-d*`) and passes `:meaty 0` to `ken-ki-style` while the bait holds. Its state `KHS` is a struct in `brain-style`. Arm keys `:khf-bait-p`, `:khf-bait-d` (§6); while the bait holds its `:meaty 0` beats the arm's `:kk-meaty-p`.

### 2.3 `ichigo-ki-style` (cpu-ki-ichigo.lisp:759-798)

Different return rule: the result is the `case` value. Per episode it picks a mode from `*iks-mix*` (HARD: generic .04 / space .26 / whiff .26 / ptr3 .28 / kessa .16; NORMAL: generic .88; EASY: generic 1) at line 45.

| Key | Live? | How |
|---|---|---|
| `:b-*` | **HARD: mostly inert; NORMAL/EASY: live in `:generic` episodes.** | A `:generic` episode returns `(and (getf *iks-generic-kikon* dif) (iks-generic ..))` (:788-790, :773): NIL at EASY / NORMAL, so `mc-neutral` runs; T at HARD (`*iks-generic-kikon*` :161), and the other modes end in `(or (iks-neutral) (iks-generic))` which is always T. Also `*mc-off-at*` has `(:ichigo :hard)` (cpu-mcts.lisp:21): the MCTS never runs for Ichigo at HARD whatever the style returns. **So for eval at HARD every `:b-*` is dead for Ichigo, with or without `:fn`.** |
| `:range :ns :awaken` | live only inside `iks-generic` / `iks-neutral`'s fallthroughs (`cai-neutral`, :731-740) | NORMAL generic episodes: live. HARD: rare, the style's own walk bands (`*iks-hover*`, `*iks-lunge-band*`...) take over. |
| `:hold-awaken` | **live, strong** | `gauges-awakened-ok-p` at cpu-ki-ichigo.lisp:628 and in `cai-neutral`. |
| `:hoho` | live in generic paths only | the style's timed Hoho (`*iks-hoho-p*`, :229) and wake Hoho (:256) are unscaled. |
| `:turn :cont` | live where `iks-move` returns NIL and `iks-generic` runs `cai-move-step` | partial. |
| `:kikon` | live, strong | `iks-sp` / `cai-sp` (kikon profile) except where `iks-sp-frames` sets the press length itself (:374, :734-737): then the style's `*iks-kikon-p*` decides, unscaled. Partial. |
| `:dswitch` | live (rare) | via `cai-move-step`. Not verified for Ichigo's kit. |

### 2.4 An arm with NO `:fn` (generic core CPU + MCTS)

`:fn` absent means the shipped style CPU is NOT used (core-ai.lisp:243), so the arm plays `mc-neutral` then `cai-*`.

| Key | Live? | Default when absent | What it does |
|---|---|---|---|
| `:b-j1 :b-sp :b-hoho :b-step-in :b-step-out :b-step-side :b-wait :b-walk-in :b-walk-out` | live except Ichigo HARD | 0 | Added to the MCTS's estimate before ranking; the `mc-neutral` softmax (`*mc-tau*`, `*mc-budget*`) then draws. At HARD the MCTS decides only when best minus second >= `*mc-sure*` 0.16 (cpu-mcts.lisp:25, :136-138); otherwise it defers to the generic CPU. Needs `*mc-on*` T (default), d <= `*mc-far*`, `idle/run`, not about to awaken (:125-130). With `*mc-full*` T (default, :40) the best two are re-scored in the full sim and the bias only shapes the two finalists. Biases much below ~0.02-0.05 will rarely flip a ranking. |
| `:range` | live | kit's `:range` (else 1.7 3.0), scale 1 | Walking band lo, hi and the decision zone (<= hi + 0.6). cai-neutral:178-179, 203. |
| `:ns` | live | 0.45 (d <= 1.7) / 0.8 (d > 1.7) | NS share at the generic decision. |
| `:awaken` | live | `*cai-awaken-p*` .02 | decision roll once the gauge is full. |
| `:hold-awaken` | live | none | holds the awaken until Sublimation >= H. |
| `:hoho` `:turn` `:cont` `:kikon` `:other` | live | scale 1 | on the fuzzy chances in core-ai.lisp (see 1). |
| `:dswitch` `:dswitch-map` | live | never | the DRIVE switch in an NS gap. |

## 3. Inert or near-inert for these three styles (do not spend attempts)

- Every `:b-*` for `ken-ki-style`, `ken-kh-style`, `ken-kh-standoff-style` (style returns T), and for `ichigo-ki-style` at HARD (T, and `*mc-off-at*`).
- `:p`, `:id`, `:apply`; `:hk-*`, `:shikai-dswitch`, `:ken-ranged` (Hisagi's styles).
- Any cue outside `strat-feats` in a plain arm's `:rules` (`:mcell :ocell :mburst :oburst :xch :dm :form :oawk :gauge :wall :prev`): they read 0 there; only a Q selector's judgement sees them.
- `:range`, `:ns`, `:awaken`, `:hoho` on `ken-ki-style` and `ichigo-ki-style`: reached only on the generic fallthrough, shadowed by the styles' own rolls. Possible but weak; expect small effect sizes and run a control.
- Antecedent sets that nothing needs: `:lead` is exactly `:even` only at 0.
- The style's own constants (`*kk-*`, `*iks-*`, `*kso-*`, `*khf-*`) outside §6's tables are not arm keys. To change one of those an agent must edit the `.lisp` source, not the arm.

Strongest levers that do reach the style CPUs from an arm: §6's style keys, then `:kikon`, `:hold-awaken`, `:turn` / `:cont` (partial), `:other` (Burst / cancel). For anything else, remove `:fn` (and accept the MCTS + generic CPU) or write a new style function.

## 4. SP (flash-step gauge) decisions inside these styles

- SP presses (Mod + attack, the NS / AS starts) go through `cai-sp` (core-ai.lisp:61); a later NS segment's SP is checked against the gauge by `cai-next-ok-p` (core-ai.lisp:110-120): refused when `kit-sp-start-p` fails (logs `cpu holds`), so the route ends. `cai-hoho-hold-p` (:~123-130, called at the end of `core-brain-step`) drops an SP the Hoho's resume would refuse.
- Kenpachi: the approach's Hoho-in needs `gauges-fs >= *kk-hin-fs*` 200 (one Hoho, 100 of 300, stays in reserve; cpu-ki-ken.lisp:84, 614). `*kk-hoho-in-p*` is 0 at every difficulty (:95), so Hoho-in is currently off.
- Ichigo: `*iks-gap-fs*` 96 (cpu-ki-ichigo.lisp:303, :510-517) times the gap lunge by the gauge, and `ai-hoho-spare-p` (:488) checks the Hoho can be afforded.
- Two style keys set a flash-step threshold (§6): `:kk-hin-fs` (his own gauge before a Hoho in) and `:iks-gap-fs` (his gauge under which Ichigo counts his Hoho as shut). Otherwise no arm key reads the SP gauge. `strat-sp-cues` (`:mcell :ocell :mburst :oburst :xch`) exist only through `:rule-base :rb-sp` Q selectors (strategy.lisp:513-519, strategy-glue.lisp:44-47), not in an arm's `:rules`. `:b-sp` is the MCTS bias on "press SP" as a macro action, not a gauge control.

## 5. Quick checks before writing a rule

1. Does the arm's style return T at free steps? (Kenpachi: always.) Then no `:b-*`.
2. Is the key in section 1's table AND reached for that style in section 2? If it is "partial", test with a control arm that sets the key to an extreme (e.g. `:kikon 0` vs `1`) and confirm the matches differ before tuning.
3. Cue names: only the ten in `strat-feats` work in an arm; sets must match the cue's type (distance / fraction / 0-1 / state class).
4. A firing rule REPLACES `:base` for that key. Put the "else" value in `:base` and the cue-specific value in the rule; do not expect addition.

## 6. Style keys: the style CPUs' own tunables as arm keys (2026-11-14, DUEL_AI_STRATEGY §11.6)

Each style reads the tunables below through `(style-knob b KEY default)` (strategy-glue.lisp) = `strat-out` on the brain's `now`: the arm's
`:base` value, or the average of its `:rules` that fire (§1: a firing rule replaces the base), else the style's own value. The key is the
special's name without its stars (`*kk-hin-fs*` -> `:kk-hin-fs`). Rules:

- **Only for an arm whose `:fn` is that style** (`ken-ki-style`, `ken-kh-style`, `ken-kh-standoff-style`, `ichigo-ki-style`). Under `none`
  the style runs with no strategy and every key is inert; an arm without `:fn` runs no style. Hisagi's `hisagi-merged-style` (and
  `hisagi-hk-style` on it) plays `ken-ki-style` outside his ranged mode, so a Hisagi arm naming `:kk-*` keys changes that part of his play
  too (none does today): a lever for the KH / IH searches.
- **Per-difficulty knobs**: the arm's value REPLACES the value at the brain's difficulty (it is the same at every difficulty). The default
  column gives HARD (the eval's difficulty), then EASY / NORMAL in brackets where they differ.
- **Chances** (`-p`): a number 0-1, rolled once per event as before (`style-roll`). A value at 0 or 1 draws no random number, so moving a
  chance to or from 0 / 1 shifts the random stream of the whole match: expect every later event to differ, not only this one.
- **Read once per decision**, at that step's cues: a `:rules` entry on a chance makes it situational (e.g. `(((:lead :behind)) (:kk-ns-safe-p 0.0))`).
- **Precedence**: a code argument beats the arm: `ken-kh-standoff-style` passes `:safe 0` once the stand-off is old (beats `:kk-ns-safe-p`),
  `ken-kh-style` passes `:meaty 0` while the wake-up bait holds (beats `:kk-meaty-p`).
- Values are plain numbers (a list or NIL cannot be averaged: bands, form tables and booleans were left out, see the skipped list).
- No shipped strategy or arm names any of these keys (host check `tests/duel-rules/style-knob.lisp`), so every arm before 2026-11-14 plays
  as before (proof: §11.6).

### 6.1 `ken-ki-style` (cpu-ki-ken.lisp), also the base of `ken-kh-style` / `ken-kh-standoff-style`: 25 keys

| Key | Default | Unit | What it changes | Search range |
|---|---|---|---|---|
| `:kk-brawl-p` | 0.6 (0 / 0.1) | chance per her move start | sealed read within `:kk-read-range`: tame / J1 / NS1a on her start | 0-1 |
| `:kk-read-range` | 3.1 | m | farthest the brawl read answers her from (also the dodge's reach floor) | 2.0-4.0 |
| `:kk-reach-p` | 1.0 (0 / 0.3) | chance per approach | start only a move that reaches her, else walk in (a Bankai always) | 0-1 |
| `:kk-reach-margin` | 0.5 | m | reach + slide less this = farthest a neutral J1 / NS starts from | 0-1.0 |
| `:kk-ns-stop-p` | 1.0 (0 / 0.3) | chance per own NS segment | a whiffed NS segment stops the route | 0-1 |
| `:kk-link-p` | 1.0 (0 / 0.3) | chance per landed sealed NS segment | next segment / SA by reach, else stop (vs the generic SA) | 0-1 |
| `:kk-as-on-p` | 1.0 (0 / 0) | chance per sealed AS segment | the AS runs all its segments once each lands | 0-1 |
| `:kk-dodge-p` | 1.0 (0 / 0.1) | chance per her move start | Hoho through a move of hers he cannot beat | 0-1 |
| `:kk-step-p` | 0.9 (0 / 0.05) | chance per her move start | back Step instead when no Hoho is open | 0-1 |
| `:kk-step-max` | 5.0 | m | the back Step only within this | 3.5-7.0 |
| `:kk-hin-fs` | 200 | flash-step (of 300; a Hoho costs 100) | Hoho in only with this much in the gauge | 100-300 |
| `:kk-hoho-in-p` | 0 (0 / 0) | chance per approach | Hoho in instead of walking in (off since round 2) | 0-1 |
| `:kk-hoho-in-max` | 4.6 | m | farthest he Hohos in from | 3.0-6.0 |
| `:kk-kikon-red-p` | 1.0 (0 / 0.3) | chance per SP held into a Kikon, she not red | tap it instead | 0-1 |
| `:kk-kikon-ptr-p` | 1.0 (0 / 0.5) | chance per SP held into a Kikon, she red | tap it unless pointer 2 (sealed / Shikai) | 0-1 |
| `:kk-meaty-p` | 1.0 (0 / 0.1) | chance per her knockdown | the meaty J1 chase onto her first free frame | 0-1 |
| `:kk-awaken-p` | 1.0 (0 / 0) | chance, once per match at a full gauge | awaken at once (`:hold-awaken` still gates it) | 0-1 |
| `:kk-climb-p` | 1.0 (0 / 0.1) | chance per Shikai stay | build L to 3 on purpose (strings end in the pointer's AS) | 0-1 |
| `:kk-lunge-p` | 0.5 (0 / 0.1) | chance per decision at 3.0-5.2 m, climbing at pointer 1 | the NS1 lunge | 0-1 |
| `:kk-bankai-p` | 1.0 (0 / 0.1) | chance per L3 reached | J1-J7 + SP into the Bankai (else the special AS) | 0-1 |
| `:kk-bk-ns-p` | 0.25 (0 / 0.1) | chance per decision in a Bankai | the NS route rather than J1 | 0-1 |
| `:kk-wave-p` | 0.9 (0 / 0.15) | chance per Getsuga route of hers | answer it (by `*kk-wave-mix*`) | 0-1 |
| `:kk-ns-safe-p` | 1.0 (0 / 0) | chance per approach and per style decision | start a J1 / NS only when her timed Hoho cannot read it | 0-1 |
| `:kk-step-in-p` | 1.0 (0 / 0) | chance per approach | Step in (2.2-4.4 m) then J1 out of its cancel | 0-1 |
| `:kk-wake-hoho-p` | 1.0 (0 / 0) | chance per own wake-up | Hoho on his first free step, her within 2.4 m | 0-1 |

### 6.2 `ken-kh-standoff-style` / `ken-kh-style` (cpu-kh-ken.lisp): 4 keys (+ the 25 above)

| Key | Default | Unit | What it changes | Search range |
|---|---|---|---|---|
| `:kso-stale` | 120 (900 / 540) | frames | stand-off clock (no gauge change) before the breaker turns the Hoho-safety off | 60-600 |
| `:kso-lead` | 0.0 | Reishi fraction | he counts as winning the bell (keeps his patience) above this Reishi lead at equal Konpaku | -0.2-0.2 |
| `:khf-bait-p` | 1.0 (0 / 0.5) | chance per Hisagi knockdown | `ken-kh-style`'s wake-up bait: hold instead of the meaty J1 | 0-1 |
| `:khf-bait-d` | 2.3 | m | the distance the bait holds | 1.8-3.0 |

### 6.3 `ichigo-ki-style` (cpu-ki-ichigo.lisp): 24 keys

| Key | Default | Unit | What it changes | Search range |
|---|---|---|---|---|
| `:iks-mix-generic` | 0.04 (1.0 / 0.88) | weight | the episode mode's weight: the shipped CPU's neutral | 0-1 |
| `:iks-mix-space` | 0.26 (0 / 0.03) | weight | spacing (hover, the pointer-3 lunge, the KESSA k-lunge) | 0-1 |
| `:iks-mix-whiff` | 0.26 (0 / 0.03) | weight | whiff punish (hover at his whiff distance) | 0-1 |
| `:iks-mix-ptr3` | 0.28 (0 / 0.03) | weight | pointer-3 play | 0-1 |
| `:iks-mix-kessa` | 0.16 (0 / 0.03) | weight | KESSA play (chains, awakening) | 0-1 |
| `:iks-punish-p` | 0.9 (0 / 0.5) | chance per his move start | punish a move he starts out of his reach | 0-1 |
| `:iks-confirm-p` | 0.95 (0 / 0.1) | chance per his move | whiff confirm: the fastest punisher that lands in his recovery | 0-1 |
| `:iks-ns-wait` | 32 | frames | after his whiffing NS starts before her punish | 16-48 |
| `:iks-wait-max` | 150 (0 / 90) | frames | hover per episode before the generic CPU takes it (not in a patient form: sealed at HARD) | 60-300 |
| `:iks-retreat-p` | 1.0 (0 / 0.5) | chance per episode / his move | pointer 2: back dash to the Getsuga range | 0-1 |
| `:iks-getsuga-min` | 7.5 | m | pointer 2 shoots the Getsuga from this on | 6.0-9.0 |
| `:iks-steer-p` | 0.95 (0 / 0.6) | chance per string | a string runs to the mode's AS | 0-1 |
| `:iks-kikon-p` | 0.95 (0 / 0.6) | chance per SP, he red, the Kikon K.O.s or matches | hold the Kikon | 0-1 |
| `:iks-kikon-costly-p` | 0 | chance per SP, he red, the Kikon takes less | hold it anyway | 0-1 |
| `:iks-awaken-p` | 1.0 (0 / 0.5) | chance per episode at a full gauge | awaken at a free moment (`:hold-awaken` still gates it) | 0-1 |
| `:iks-hoho-p` | 0.9 (0 / 0) | chance per his move start | the timed (perfect) Hoho on his attack | 0-1 |
| `:iks-hoho-follow` | 64 | frames | window after her Hoho for the follow-up J1 | 40-90 |
| `:iks-wake-hoho-p` | 0.9 (0 / 0) | chance per her wake-up | Hoho at once, him within 2.2 m | 0-1 |
| `:iks-meaty-p` | 0.9 (0 / 0) | chance per his knockdown | the meaty J1 | 0-1 |
| `:iks-meaty-far` | 3.0 | m | the meaty only when he goes down within this | 2.0-5.0 |
| `:iks-gap-p` | 0.9 (0 / 0) | chance per episode | the shut-gauge lunge (pointer 3, his Hoho shut) | 0-1 |
| `:iks-gap-fs` | 96 | flash-step (his) | his Hoho counts as shut while his gauge is under this | 80-150 |
| `:iks-gap-wait` | 6.5 | m | the shut-gauge lunge backs off to this and waits | 5.5-7.5 |
| `:iks-break-p` | 0 (0 / 0) | chance per combo of his | break out by the Burst (or the awakening with `*iks-break-awaken*`) | 0-1 |

The mix: naming any `:iks-mix-*` key replaces that mode's weight and keeps the difficulty's other weights (a mode the difficulty lacks
counts 0); the weights are normalised; all 0 plays `:generic`. At HARD a `:generic` episode still returns T (the MCTS stays off for her,
2.3).

### 6.4 Left out (one line each)

- Frame timings measured from trials, not decisions: `*kk-dodge-lead*`, `*kk-step-lead*`, `*kk-meaty-lead*`, `*kk-cut-lead*`, `*kk-late-lead*`, `*kk-wave-step-lead*`, `*kk-hend-lead*`, `*kk-clone-strike*`, `*iks-meaty-lead*`, `*iks-confirm-slack*`.
- Engine facts (lock frames, perception delay, turn and walk rates): `*kk-hoho-lockout*`, `*kk-hoho-blind*`, `*kk-pf-window*`, `*kk-cine-gap*`, `*kk-repel-wait*`, `*kk-face-max*`, `*iks-gap-lockout*`, `*iks-confirm-walk*`, `*iks-lead-vmax*`.
- Lists (bands, weight plists, form tables; a rule cannot average them): `*kk-wave-band*`, `*kk-wave-mix*`, `*kk-lunge-band*`, `*kk-step-in-band*`, `*iks-hover*`, `*iks-hover-p1*`, `*iks-bait-hover*`, `*iks-lunge-band*`, `*iks-gap-band*`, `*iks-kessa-*-band*`, `*iks-his-reach*`, `*iks-punish-reach*`, `*iks-punishers*`, `*iks-hoho-lead*`, `*iks-kessa-as*`, `*iks-gap-dash-his-forms*`. Split into `-lo` / `-hi` keys if a search needs one.
- Booleans and mode / form lists (NIL cannot be a value): `*kk-cine-wait*`, `*iks-patient-p*`, `*iks-ns-stop*`, `*iks-p2-wait*`, `*iks-untimed-hoho*`, `*iks-hoho-slide*`, `*iks-finish-steer*`, `*iks-finish-even*`, `*iks-break-awaken*`, `*iks-retreat-rearm*`, `*iks-punish-ns-reach*`, `*iks-k-sa-perceived*`, `*iks-k-sa-dodge-stop*`, `*iks-meaty-space-skip*`, `*iks-patient-lunge*`, `*iks-generic-kikon*`, `*iks-follow-any-perfect*`, `*iks-burst-no-hoho*`, `*iks-bait-modes*`, `*iks-awaken-modes*`, `*iks-kessa-space-modes*`, `*iks-*-forms*`, `*iks-walkin-band*`, `*iks-kessa-chain-band*`, `*iks-gap-dash-dt*`.
- Located bug fixes at 1.0 everywhere (turning them off only re-opens the bug): `*kk-as-read-p*`, `*iks-read-p*`, `*iks-kessa-read-min*`.
- Move geometry and the Bankai's string plan (second tier, kept to 25 a style): `*kk-meaty-near*`, `*kk-meaty-min*`, `*kk-meaty-back*`, `*kk-chase-hoho*`, `*kk-wave-close-max*`, `*kk-wave-margin*`, `*kk-wave-carry*`, `*kk-wave-far*`, `*kk-wave-timeout*`, `*kk-chase-frames*`, `*kk-chase-dash*`, `*kk-link-margin*`, `*kk-dodge-reach*`, `*kk-clone-reach*`, `*kk-l3-range*`, `*kk-l3-sa-range*`, `*kk-bk-floor*`, `*kk-bk-ns-spare*`, `*kk-bk-ns-range*`, `*kk-bk-walk-range*`, `*kk-special-n*`, `*kk-bk-cashouts*`, `*kk-reach-retry*`, `*kk-wake-hoho-near*`, `*iks-j-reach*`, `*iks-ns2-min*`, `*iks-retreat-to*`, `*iks-shot-gap*`, `*iks-k-sa-reach*`, `*iks-k-sa-min*`, `*iks-meaty-near*`, `*iks-hoho-j-reach*`, `*iks-wake-hoho-near*`, `*iks-gap-cmin*`, `*iks-gap-dash-over*`, `*iks-gap-max*`, `*iks-gap-dash-need*`.
- HARD-only follow-ups left for a next pass (one `style-roll` each to add): `*kk-pf-p*`, `*kk-hend-p*`, `*kk-l3-sa-p*`.
