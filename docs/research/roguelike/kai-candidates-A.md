# 解 KAI candidates, batch A: Yamamoto, Kenpachi, Rukia, Ichigo (read-only research, 2026-10-22)

All the numbers below come from the defmove / defkit forms in duel/lisp/{yama,ken,rukia,ichigo}.lisp and duel/lisp/tuning.lisp.

## Things that apply to every candidate (read these before a batch)

- **Armour window**: `:armor-hits` covers move frames `*ARMOR-FROM*` 6 .. S-1 of the main phase. On a Kikon rush it covers
  the dash phase (fighter.lisp DEFENDER-STATE). It does nothing in a `:hold` phase, and nothing on a move with S <= 6.
  ai.lisp never reads armour, so the CPU needs no change for an armour reward.
- **Renamed copies and strings**: `defmove-copy` registers a global name in `*moves*`. A P1-only override therefore needs
  a new name (e.g. `:ya-tenchi/kai`), and P1's kit copy must point its command at that name. Any kit `:strings`, `:grid`
  or `:l-after-k` entry that names the old move must be remapped too, or the follow-up breaks. Flagged where it applies.
- **Copies made at load**: copies made at load time (Rukia's `-50` / `-0` SHIRAFUNE, Ken's `:ke-b-kikon` from
  `:ke-kikon-n`) do not inherit a later override. Each one needs its own override.
- **Frame data**: a `:startup` change without `:clip-s` plays the clip at speed 1, so it reaches its hit pose late. None
  of the picks below change startup or recovery.
- **Global knobs**: some knobs are global defparameters (`*clone-cost*`, `*kessa-parry-cost*`) or kit fields (`:cold`,
  `:meter :ladder`, `:pips`). A defparameter needs a per-fighter read (a run-modifier lookup in the character's own
  file) so a mirror opponent keeps the stock value. A kit field can be edited on P1's kit copy.

## Yamamoto (base Shikai / Hellfire; awakened Bankai East + West, the run's usual state)

1. **疾不知火** — SHIRANUI `:ya-shiranui`, SP1, base / Hellfire. `:hold (12 60)` → `(12 36)`; 170 damage and the
   Inferno fill now come at 36 f. A full charge is worth throwing mid-neutral, so Hellfire comes sooner. Risk: low. The
   CPU's `:oki :sp1-full` reads `mv-hold`. Only matters in stage 1 and after REVERT.
2. **天地一貫** — TENCHI KAIJIN `:ya-tenchi`, O, Bankai East + West. `:armor-hits 0 → 1` on the 14 f flash-step dash
   (the same rule as Ken's base CHARGE, `:ke-kikon` `:armor-hits 1`). The rush plows through a poke instead of being
   jabbed out. Risk: low. YAMA-RUSH-VETO reads only frames and reach.
3. **旭光連閃** — KYOKKO `:ya-e-kyokko`, L, Bankai East. `:cooldown 100 → 40`. It is already a `:cancel` L (it ends a
   landed J/K string), so every string can end in the double-pierce lunge, and against a drained guard 77 per press
   gets through. Risk: low. The CPU's `:cancel (:sig 0.5)` gates it per event.
4. **焦熱三獄** — SHONETSU JIGOKU `:ya-w-shonetsu`, L, Bankai West. `:params :hits 2 → 3` (45 a pillar hit, at most
   90 → 135) and `:cooldown 150 → 90`. The ward stance gets a real 360° pressure answer you can press every 1.5 s, and
   West becomes a stance to stay in. Risk: low (hazard data).
- Spare: **骸手縛** — MINAMI `:ya-kaka`, SP2, Bankai. `:cost 2 → 1`. The unguardable bind costs one bar. Strong; the
  user's 2026-09-28 note calls the 2 bars "its limiter".
- Needs a clip or look: KYOKKO's ray 4.6 → 6.5 m (the look's 4.6 is hard-coded in YAMA-KYOKKO, plus the FK check);
  TENCHI's cut reach 2.4 → 3.4 m (its clip `:ya-e-tenchi`).

## Kenpachi (base; awakened Nozarashi cups KATATE / RYOTE / NOMIHOSE, every stage starts at KATATE NOME 10; Bankai from cup 3)

1. **剣鬼構** — KITTE MIRO YO `:ke-stance`, L. Base, and inherited by all three cups (derived +2 / +3 f). `:flags (:stance)`
   → `(:stance :guard-crush)`. Today the cut crushes only at stored >= `*stance-crush-at*` 150; with this it always
   does (combat.lisp reads the window's `:guard-crush`). A tap stance becomes a guard breaker. Risk: medium. It is a strong
   guard-break tool, so balance is the user's call. Implementation is easy: the move is in no string, so a renamed P1
   copy needs no remapping.
2. **流星不退** — SPLIT THE METEOR `:ke-meteor`, SP1, KATATE + RYOTE. `:armor-hits 0 → 1` (frames 6–25 of its S 26).
   The 240 line cut trades through a jab, so it works as a reversal in neutral. Risk: low. Cup 3's `:ke-meteor-n` is
   unchanged.
3. **空裂不止** — LEAP CLEAVE `:ke-kikon-n`, O, every cup. `:armor-hits 0 → 1` on the 30 f leap, as the base CHARGE has.
   The locked leap is no longer stuffed by a poke. Risk: low. MAPPUTATSU `:ke-b-kikon` is a load-time copy and needs its
   own override for the Bankai.
4. **鯨飲** — NOMIHOSE, cup 3 (a form / meter number). Ladder drain `*nome-drain-t3*` 20/s → 10/s, set on P1's kit copy
   `:meter :ladder` entry `:nomihose`. The 100 → 50 window doubles from ~2.5 s to ~5 s, so cup 3 (KUKAN-GIRI, 390
   NOMIHOSE, the Bankai's entry) becomes a state you can play in. Risk: medium. This is not a move; it is the kit copy's
   ladder. The user doubled this drain on 2026-09-29 (10 → 20), so this reward partly undoes that for P1.
- Spare: **鬼腕** — the Bankai's UDE `*arm-pips*` 4 → 5 (on the kit copy, `:pips :n` and `:meter :max`/`:start`): one more
  heavy before KATAUDE.
- Needs a clip: KATAUDE reach x0.7 → x1.0 (`*kataude-reach*`, the ruined-arm clips); ORE NI KIRENEE's flurry 5 → 7 cuts
  (the `:ke-flurry` clip's cuts are at f4/10/16/22/28).

## Rukia (base Shikai; awakened -18 / -50 / -273, every stage resets to -18)

1. **月白瞬** — SOME NO MAI: TSUKISHIRO `:ru-tsukishiro`, L, base. `:params :delay 24 → 14`, `:tell (21 30) → (11 20)`.
   The pillar comes 10 f sooner, so reacting late with a Step fails, and the ring becomes a punish instead of only a zone
   trap. Risk: medium. `:tell` is the opponent CPU's bind-tell window, so shift it with the delay. Leave the K-link copy
   `:ru-tsukishiro-k` (delay 10) alone.
2. **霜柱無尽** — SHIMOBASHIRA `:ru-shimobashira`, L, -18 (kit field). `*ru-cold-m18*` `(:sig 25)` → `(:sig 0)` on P1's kit
   copy. At -18 only L spends cold, so with this she presses frost pillars freely while guarding toward -50. Risk: low.
   It is a kit `:cold` field, not a defmove-copy; COLD-OK-P is unchanged.
3. **白船不沈** — SAN NO MAI: SHIRAFUNE, SP2, every band. `:armor-hits 0 → 1` (frames 6–15 of S 16) on `:ru-shirafune`,
   `:ru-shirafune-50` and `:ru-shirafune-0` (load-time copies: all three overrides). The 5–7.5 m thrust trades through
   a poke. Risk: low.
4. **永久凍土** — REIDO TOKETSU `:ru-reido`, L, -273 (kit field). `*ru-cold-zero*` `:sig 100 → 50`. Today the 5.5 m freeze
   cashes the whole top bar and drops her to -50. At 50 she stays at zero (TEMP-BAND leaves zero only at C <= 100), so
   zero becomes a state you can hold and play from. Risk: medium. The opponent's `:opp-intent` waits zero out, and zero
   will last longer.
- Spare: **疾白漣** — HAKUREN `:ru-hakuren`, SP1, base. `:hold (16 64) → (8 32)` plus `:params :per 8` (the key the
  -50 copy already uses): the 4-stab wave at 32 f.
- Needs a look check (hit volume): TSUKISHIRO ring `:radius 1.8 → 2.4` (the ring look is drawn from `:radius`);
  SHIRAFUNE -18 `:cap .. 5.0 → 6.0` (RUKIA-SHIRAFUNE-ICE sizes the ice by `mv-reach`). Both may need no new clip, only
  the FK test.

## Ichigo (base Shikai; awakened KESSA, permanent)

1. **鎧月落** — TSUKI-OTOSHI `:ic-tsuki-k`, the stance's K branch, base. `:armor-hits 0 → 1` (frames 6–17 of S 18). The
   stance mixup gets an answer that beats a jab, not just a read. Risk: medium. It is started through `*tsuki-strings*`
   (`:tsuki-k` from three stance moves), so a renamed copy must be remapped in P1's `:strings`.
2. **虚影** — 残像 ZANZO `:ic-k-zanzo`, SP2, KESSA. `:cost` (default `*cost-sp-awakened*` 2) → `:cost 1`. The 6 s echo
   state (every attack echoed at x0.5) costs one bar, so it can stay on most of the fight. Risk: low. KIT-COMMAND-COST
   reads `mv-cost`.
3. **天鎖縛** — KUSARI-BIKI `:ic-k-hiki`, SP1, KESSA. `:hits ((16 19 :stun 40))` → `:stun 60`. Today the pull-and-bind is
   +13 (a J string). At +33 a K1 (S 18) string combos, so the chain becomes a confirm into big damage. Risk: low. The
   combo limits still apply.
4. **分身乱舞** — 分身 clones, KESSA (the form's own number). `*clone-cost*` 15 → 5 guard gauge per clone (a Step or a
   Hoho). Clones become cheap, so 千影 (4 Konpaku at 3 clones) comes up every fight. Risk: medium. It is a global
   defparameter, so ichigo.lisp needs a per-fighter read. The user put this cost back on 2026-09-29 after v2 made clones
   free; this reward lowers it but does not remove it.
- Spare: **無償鎖盾** — KUSARI-TATE `:ic-k-parry`, L, KESSA. `*kessa-parry-cost*` 10 → 0 (the catch still refunds 20):
  parry from blockstun at no cost. It also needs a per-fighter read.
- Needs a clip or look: RANGETSU 4 → 6 slashes (`:ic-rangetsu`'s cuts); GETSUGA TENSHO width 2.4 → 3.6 (the
  half-width stays <= 1.8, the user's Step-clears rule; the crescent look must scale).
