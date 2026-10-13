---
name: duel-move-modules
description: Use when designing, restating or restructuring a fighter's move set in an arena fighter like SOUL DUEL — attack strings, a stance entered by a button, follow-up routes, enders, resources gained or spent per button, the same grammar across forms or awakenings — especially when the user writes shorthand like 「架勢 > JJ / KK > LL」 or asks for 「動作模組」 per route or form.
---

# Move sets as modules

## Overview
From the new Lille (kit `:barro`; `docs/duel/DUEL_LILLE_V3.md` §3, §8, §12, §15.1, §25; code `duel/lisp/barro.lisp`
`*BR-S-SEGS*`, `BR-DEFSTANCE`, `BR-STANCE-STRINGS`). Core principle: **one grammar, written once as data (a segment
table), played by every form with its own clips; each button has one role, each resource one sink.** Evidence and the
encoding in detail: `reference.md`. New fighter flow: `duel-character`; changing one: `duel-character-rework`; its CPU:
`duel-character-cpu`; the clips' style and research:
`duel-motion-style`.

## ⚠ Restate the user's notation before building
The user's notation is shorthand. Every misreading here cost a rebuild (「JJ KK LL 都不表示只要二連擊」, 「不是 J2，是 J 連段的意思」,
「最多三段」 → 「段數跟點擊次數一致」). Reply with a **segment table** and get a yes:

| String | Enter by | Segments (presses) | Hits a segment | Range | Gains | Spends | Ends with |
|---|---|---|---|---|---|---|---|

Then ask what the table cannot show (AskUserQuestion, recommended first):
- **Does the follow-up's motion depend on the route?** (「最後一段 LL 會依據前面 J/K 有不同的動作模組」: JL and KL are two
  clip sets, not one L string.)
- **Price and empty behaviour**: per segment or per string? With nothing to pay, does the press do nothing (the string
  stops) or play a plain move? An empty stance must never reopen itself (a 0-resource infinite combo).
- **Which hits reach far**: only paid ones? (「沒有消耗資源的話就不能有遠距離攻擊」)
- **Roles must not overlap** (「避免同質化」): exactly one spend-all route; one gain button, one refill button, one damage
  button. Gains come as ratios (「2 格閃步換 1 格 SP」): ask for the ratio, derive the numbers.
- **Tap or hold** for each button (charge levels by hold frames?), and its one-hand touch mapping.
- **Where a string ends**: back to the attack state? Pushed out of the opener's reach? Which enders (SP2, the O ender) may
  cancel which segments (hit only, or block too)?
- **Each form: same timing or its own** (speed ×, melee vs shots), and are the transitions skippable inside a combo?

## The recipe
1. A plain **attack state** (J / K strings, no resource in or out) and a **stance** entered by one button.
2. In the stance each button **opens one string with one role** (L gain, J refill, K damage). **One hit a press**, three
   segments, named button + index (J1 J2 J3) so the player can count.
3. **Route follow-ups** off the last segment (J3 → JL1–3, K3 → KL1–3), each route its own clips, one special a segment,
   the string stopping at the segment it cannot pay for.
4. **`:end` segments** (every string's last) push the victim out of that string's opener's reach (volume far edge + body
   radius + 0.3 m) and are where enders cancel in.
5. **One spend-all super** (SP2), cancellable only off string hits, punishable when used alone.
6. **Encode once**: a segment table (name kind startup hit-offsets recovery dmg reactions role extra), a macro that
   expands it per form with that form's clip plist and FK reach, a function that returns the kit's strings. A new form
   = one macro call + a defkit; a new route = rows with a new role + a latch + clips. A new character copies the
   pattern into its own file under its own prefix (`br-defstance` is Lille's); lift a macro into `kit.lisp` only when a
   second character really shares it, proving the other pairings byte-identical. The character's knobs live in its own
   file as `defparameter`s with docstrings (old → new, date, who decided); `tuning.lisp` holds the shared ones.
7. **Pin in host tests**: every link combos on a hit *including hitstop*, every segment → SP2 combos, `:end` only on last
   segments, the routes on distinct clips, drawn tip = reach ±0.15 m, any user-ruled order (damage KL > stance K >
   attack K), the route / price cases.

## Red flags
- Building from 「JJ」 before the segment table got a yes.
- Two buttons that both dump the resource for damage, or a refill that can feed itself (a free loop).
- A follow-up drawn with the opener's clip "for now": the user reads the route by its motion.
- `:track` 720 or a turn at release on a charged shot: hidden aim makes it unmissable (same class as hidden movement).
- Per-move state reset in a frame-0 hook of a `:hold` move (hold moves skip their f0 hooks: reset at S).
- A form switch inside a move (a burst ending) with a latched link the new kit lacks: switch only out of a move.
- The generic SP cancel letting SP2 follow any link: refuse it in the move's `:ok`.
- Art drawn for a rule the user hasn't played yet (a same-day withdrawal threw away a drawn swing).
