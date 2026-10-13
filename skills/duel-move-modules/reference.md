# Move modules: evidence and encoding from the new Lille (2026-10-09 → 10-13)

Sources: `docs/duel/DUEL_LILLE_V2.md` (V1–V9l), `docs/duel/DUEL_LILLE_V3.md` (§1 the animation inventory, §2 the base
stance's rules B1–B6, §3 the grammar, R1–R20), `docs/DEVLOG.zh-TW.md` §156–§216, `docs/research/lille2-motion-styles/`.
Code: `duel/lisp/barro.lisp`, `barro-art.lisp`, `lille-art.lisp` (shared art). "G" = generalizable, "P" = project-specific.

## 1. The grammar as it ended up (P → G)

| Piece | Rule | Where |
|---|---|---|
| Attack state | the form's plain J / K strings; no resource in or out | R1 「避免同質化」 |
| Stance | L enters (tap; from neutral or off any J / K link); base: `:br-kamae` (rooted, one fast Step, 30 f stand); awakened: the EN form by a 12 f turn | §3.2, R12 |
| Strings | L gain (one charged press, 3 levels by hold 20 / 40 f), J refill flash step + Reiatsu, K damage | R3, R10, R15 |
| One hit a press | 3 segments, each exactly one hit; the damage kept when hits were merged (K 28/28/42 → 46/46/66) | R7 |
| Follow-ups | L after J3 / K3 → JL1–3 / KL1–3, each route its own clips, 1 special a segment, the string stops where it can't pay; the only 31 m hits | R3, §8.5 |
| Links | an L link only after a hit or block; a whiffed L recovers R + 8 | R5 |
| `:end` | J3, K3, JL3, KL3, L3 push out of their opener's reach (far edge + body + 0.3 m, `BR-S-END-PUSH`, `BR-MOVE-REACH`); every string ends back in the attack state | §15.1, R12 |
| Enders | charge-less SP2 (`:sp2c`, off any J / K / JL / KL segment that hit); the O / Kikon ender (`BR-S-O-ENDER`, not the generic `:ender` flag, which would double the push and chase) | R3, R20 |
| Economy | L gains, J refills, K / KL damage, SP1 *reads* the count (refund tiers), SP2 the only spend-all (+ a unit a special; alone: full charge, R +20, −30 on block), the wing armour spends 4 (the owl 2) | R1, R3 |
| Forms | the same segment table; a clip plist and an FK reach table per form; transitions skippable in combos (R17 `:br-to-en-l`); a held L enters the charge directly (R13) | §8.5, R17 |

The user's verbatim lines that set the shape: 「架式 > JJ/KK > LL 中，最後一段 LL 會依據前面 J/K 有不同的動作模組」,
「沒有消耗資源的話就不能有遠距離攻擊」, 「高資源換取高傷害的定位設計給 SP2 佔有，並讓其單發破綻大、必須接在 KK 後」,
「我希望段數跟操作時的點擊次數一致，這樣玩家才能輕鬆確認到底打到哪一段」.

## 2. The encoding (P)

- `*BR-S-SEGS*`: one row a segment, `(name kind startup hit-offsets recovery dmg react-mid react-last role extra)`,
  extra `(:gain n)` / `(:spend t)` / `(:end t)`. Per-form timing overrides in side tables (`*BR-W-SEGS*` the awakened
  melee, `*BR-S-KATA-SEGS*` the base gun-kata); per-form reach `*BR-W-TIPS*` (prefix → segment → metres, from FK).
- `(br-defstance PREFIX CLIPS &key adv melee snipe l-slow)` → one `defmove` a segment (`BR-S` base, `BR-E` JILLIEL EN,
  `BR-OE` the owl EN). CLIPS: `(:j1 (clip authored-S [charge-clip]) …)`, played at `:clip-s` = the authored S. Flags pick
  the volume (melee capsule to the drawn tip, a 31 m `:x-axis` line for paid hits), `:hold` for charges, `:through` for
  the dash; the f0 hook `br-s-start` (reset gains) or `br-s-spend` (pay).
- `(br-stance-strings PREFIX SP2 &optional melee)` → the kit `:strings`: J by `:q`, K by `:f`, L chains and routes by
  `:lchain` (a latch set in the tick `BR-S-TICK`), every J / K / JL / KL → `:sp2c`. A move the kit doesn't list cannot be
  started by name: non-button strings are how a tick starts a move.
- Attack-state strings: `(br-defstring ROUTE name …)` → `BR-V8-SPEC` applies a route's feel deltas (`:j` −2 f / ×0.85,
  `:k` +2 f) and retimes with `:clip-s`. `:clip-s` is the normal retiming tool; what stays wrong is playing a *sibling
  form's* clip sped up instead of the form's own.
- Kits: `defkit :barro <form> :inherit …` with `:commands` (buttons → openers), `:strings`, `:clip-map`, `:look-clips`
  (a shared generic clip replaced by the form's own: the guard → the wing wall, R19), `:hooks`, `:ai (… :stance (…))`.
- Generic hooks this added to shared files (each default off, the other pairings byte-identical): `:armor` (kit armour),
  `:pose` (squash-and-stretch; never scale the facing axis so reach stays honest, `BR-DEFORM`), `:look-clips`,
  `:through`, `:charge` / `:hold` + `:release`, `:step-branch`, `FIGHTER-STEP-OPEN`, `DRAW-WEAPON :tint`.
- Host tests (`tests/duel-rules-test.lisp`, BARRO sections): every link combos on a hit incl. hitstop; every segment →
  SP2 combos; `:end` only on last segments; routes on distinct clips; clip length / `:s` / speed 1; FK tip = reach
  ±0.15 m; `BR-K-ORDER-P` (KL > stance K > attack-state K, R14); the route rule's cases (`BR-ROUTE-J-P`).

## 3. How the grammar was found (G)

- **Stacked rules are the redesign signal.** V6–V9l added ~20 trace rules in 2 days (V9g: three rules stacked made one
  dash spend 3 traces), then the user: 「主要是軌跡的手感不好，想用新玩法替代」.
- What worked: **an animation inventory** (every clip: frames S / A / R, motion, old / current / proposed use, the
  spares; V3 §1, 90 clips) and **a proposal distilled from the part that already worked** (the base stance's six rules,
  V3 §2), revised three times as a private zh-TW Artifact before 「開始實作」; the old version stayed in git.
- Restating the inventory's spare clips into new slots ("revived") made v3 cheap to draw.

## 4. Wording that was misread (G)

| The user wrote | First read | Meant | Cost |
|---|---|---|---|
| 「架勢 > JJ / KK / LL」 | two presses | a multi-hit string (「只是簡化多段攻擊的描述方式」) | R3 rebuilt |
| 「不是 JJ 不是 J2」 | the second J | the J string as a whole | a mid-build reroute |
| 「動作段數最多三段」 | ≤ 3 hits a segment | one hit a press (R7 the next message) | a rebuild |
| 「附近」 | 10° of the line | 2.5 m (V4 → V6) | a rebuild |
| 「Step」 (V9i) | the stance Step | any Step (V9l) | a fix round |

## 5. What churned vs what held (G)
- Held once asked: the roles (gain / refill / damage), one spend-all, the route follow-ups, one hit a press.
- Churned by play: hits per segment (2–4 → ≤ 3 → 1), follow-up segments (2 → 3), refills (L +3 → +1 a string, J 10 / 15
  → 3 / 5, SP1 18 / 35 / 70 → 9 / 18 / 35), the K multiplier 1.2 → 1.0 → 0.8 in one day, openers 4 m shots → melee.
  Expose them as knobs with docstrings; don't predict them.

## 6. Bug classes the grammar produced (G)
- A `:hold` move's f0 hooks never run (`START-MOVE` skips entry hooks in the hold phase): reset per-move state at S (R11).
- A tick that starts another move during a hold phase: the release test read a NIL button and crashed (`HOLD-PHASE-STEP`,
  R18; found only in a browser run).
- A form switch inside a move left a latched link the new kit lacked (§7.1): switch only out of a move.
- The generic SP cancel let SP2 follow any link (§8.4): refuse in `:ok`.
- A zero-resource loop: L in a link reopened the stance at 0 pips → an infinite combo (V9e).
- A 1-frame combo break: a K link's startup 15 vs J's flinch 18 + hitstop (R12): host-check links with hitstop.
- A push measured to the capsule's end without its radius (R12).
- Hidden aim: `:track 720` + a turn at release made the charged snipe unmissable (R18).

## 7. The motion bar for modules
Deciding the style, researching it and mapping archetypes onto the segments: `skills/duel-motion-style/` (its reference
holds this case: the archetype table, 2–3 rounds a string, the whip / turn / key-density failures). One rule that belongs
here: brief art batches from the segment table of the build they merge into (r5-art lost 8 clips to a sim change, §8.3).
