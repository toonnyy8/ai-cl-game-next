# 解 KAI candidates, batch B: Senjumaru, Lille, Hisagi

I read the numbers from the defmove forms (duel/lisp/senjumaru.lisp, barro.lisp, hisagi.lisp) on 2026-10-22. I did not edit any repo file.

## Implementation note for every candidate (read first)

- Do not register the override under a new name. `defmove-copy` does that (`register-move NAME`). Instead, re-parse
  the move under its **own name** into P1's kit copy: `(setf (gethash name (kit-moves copy)) (parse-move name (append
  overrides (mv-spec mv))))`. The reason is that many hooks match moves by name: Hisagi's `:hs-r-l` in HS-DMG-MULT and
  HS-BK-HIT, `:hs-b-l` in the KOJO pull, `*hs-kazas*`, `*hs-kubi-moves*`; Lille's `:br-kamae*` lists; the
  `*br-s-openers*` table. A renamed copy would silently skip all of them.
- Each form keeps its own `kit-moves` hash (kit.lisp ~470 copies the parent's entries). So a move shared by several
  forms has to be overridden in every form's hash. For example, KASA is in all 7 of Senjumaru's forms.
- A `defmove-copy` sibling such as `-k`, `-c` or `-2..-6` copied the spec when it was registered. It does not follow
  the override, so the card has to list it too.
- Move armour (`:armor-hits`) covers move frames 6..S-1 in the `:main` phase only (fighter.lisp DEFENDER-STATE). It
  does not cover a `:hold` phase. On a Kikon it covers only the `:dash` phase, so the lane Kikons (dash-max 0: UKIMON,
  BANBUTSU KANTSU, KARI, KOSA) cannot take armour without a new hook.

## Senjumaru (base Shikai; awakened = the six TSUJI hank forms)

Boss rule: TSUJI always fully woven. No candidate below pre-weaves.

1. **針返** — L 悪い癖 WARUI KUSE `:sj-warui-kuse`, Shikai. Recovery 24 → 20 (free at f28, not f32).
   - Why: with all 6 stitches the last spike holds him to f38, so she is +10 and J1 (S7) combos. With 4 she is +6
     (unchanged). Cashing out at full becomes a combo starter, not a frame trap.
   - Risk: it reopens DUEL_SENJUMARU blocker B2 (stitch loops: spikes → J string → 6 stitches → spikes). Only the
     combo limits' forced knockdown caps it. The `-k` copy is untouched. The CPU is not affected.
2. **蛇目傘** — SP2 傘 KASA `:sj-kasa`, both forms, matters in TSUJI. `:cost` none (awakened default 2 bars) → 1.
   - Why: the umbrella-and-tendrils answer to zoners costs 1 bar in the Bankai, so it is used as a routine counter, not
     a last resort.
   - Risk: low. KIT-COMMAND-COST reads `mv-cost` first. The override must go into all 7 forms' hashes. The Shikai's
     cost is already 1, so it does not change.
3. **疾杼** — J→L 一越 HITOKOSHI `:sj-hitokoshi`, TSUJI. Recovery 10 → 4.
   - Why: off a J1/J2 hit -3 → +3 (a frame trap). Off J3 +5 → +11, so J1 combos. Blocked -17 → -11. Weaving moves
     into her pressure (J → L → J …) instead of a pause.
   - Risk: low. A plain number. Its f8 on-frame hook is unchanged. This is the weave tempo, not the boss's
     "always woven".
4. **速裁** — SP1 裁ち直し TACHINAOSHI `:sj-tachinaoshi-1..6`, TSUJI. Recovery 22 → 10 (free at f18, not f30).
   - Why: she is free as the first zone lands (f18, the second at f24), so the double release becomes a mid-combo
     bridge into J or K, not only a string ender.
   - Risk: low. Six copies, one card. The combo scaling applies. SENJU-SP-ENDER is the CPU's only.

- Alternate: **縫地鎧** — O 縫地 NUICHI `:sj-kikon` (Shikai). `:armor-hits` 0 → 1 on its flash-step dash (≤ 14 f).
  Kenpachi's CHARGE `:ke-kikon` already has this, so the dash armour path exists. Low risk.
- Needs a clip / a reach call:
  - Shikai K1 MACHIBARI 2.9 m → the Bankai's TANMONO-UCHI `:sj-t-k1` (3.8 m, its existing clip and volume, dmg 48 → 45).
    No new art is needed, but it is a reach change, so it is the user's call.

## Lille (`:barro`; base = the sniper with 3 pips; awakened = JILLIEL KIN / EN with 8 wings; the owl = the burst)

Boss rule: KIN at FIGHT, wings refilling over time, and the owl after his first Konpaku lost. No candidate below
refills wings.

1. **神速蓄** — the charged L (base snipe `:br-s-l1`, awakened dash `:br-e-l1`, the owl's `:br-oe-l1`), base and
   awakened. Charge levels `*br-w-l-levels*` (20 40) → (12 24) frames held.
   - Why: level 3 (the base's 31 m 萬物貫通 line, the awakened 10 m dash with 6 cuts and +3 wings) comes 16 f sooner,
     so the charged L becomes the neutral tool and the wing engine runs faster.
   - Risk: it is a knob, not a move key. BR-W-L-LEVEL(held) has no fighter, so it needs a per-fighter read. That is 2
     sim call sites (BR-W-DASH, BR-S-SNIPE-RELEASE) and 3 draw sites (the charge glow: barro-art.lisp 1344,
     barro-draw.lisp 434/504/581), else the glow shows the wrong level. Also barro-ai 492/500/533 (P1's ASSIST only).
2. **翼鎧** — the 4-wing armour, KIN / EN (and the owl). `*br-armor-wings*` 4 → 2 (the owl's `*br-owl-armor-wings*`
   2 → 1).
   - Why: he can armour through two hits per full wing bar, which makes armoured stance strings a build.
   - Risk: it is a knob. BR-ARMOR-COST(form) has no fighter: 3 sites (BR-ARMOR-P, BARRO-STRUCK, barro-ai 357). Do not
     use `:armor-hits` for this. BARRO-STRUCK treats every `:armored` as wing armour (its docstring: "his moves carry
     no :armor-hits"), so move armour on any Lille move would also spend wings.
3. **五連射** — SP1 SANREN `:br-w-sanren` (KIN; EN inherits it). Lines 3 → 5. `:hits` add (42 44) (52 54),
   `:on-frame` add (42 br-line-shot) (52 br-line-shot), active 22 → 42, recovery 24 kept. Damage 3 × 30 → 5 × 30.
   - Why: a longer zoning volley that still gives SP1's flash step back. DUEL_LILLE_V3 §3.4 once had "8 wings: 5 shots".
   - Risk: medium. BR-SANREN-TICK turns only between f14 and f32 (hard-coded), so lines 4–5 don't re-aim unless it
     reads the active frames. The clip `:lb-w-sanren` ends before the move does (a look). The wing armour stays on
     longer.
4. **疾風飛廉** — SP2 HIRENKYAKU `:br-hiren`, `:br-k-hiren`, `:br-k-hiren-c`, base. Recovery 42 → 22, adv-block
   -30 → -10.
   - Why: the pip spend-all after the 6 m back-slide is no longer a free punish, so he can fire it raw from range.
   - Risk: low as code (3 moves, one card). As design, it undoes `*br-sp2-slow-r*` (R3, the user's 「單發破綻大」), so
     flag that to the user.

- Alternate: **神速裁** — SP2 NIJUSHI-KO `:br-w-nijushi` (KIN/EN) on its own: startup 40 → 24, `:clip-s 40`, beam
  on-frame 40 → 24. The 260-damage wing dump becomes a neutral threat. This goes against R3's 「必須接在 KK 後執行」.
- Needs a clip / a hit-volume call:
  - The owl's SP1 裁きの光明 `:br-misuji` fan (-20 0 20) → (-40 -20 0 20 40): 5 ground lines (`:params :fan`). This
    adds hit volume.

## Hisagi (base Shikai; awakened = the Bankai's ranged mode `:bankai` and its bind mode `:bankai-bind`)

Boss rule: 1 % Reishi a second unhit, the bind on 100 Reiatsu (not 200), and a release that refunds him first. So
KUBIKAKE's `*hs-kubi-reiatsu*` 200 → 100 is excluded, because it copies the boss.

1. **二重風車** — L 風車 KAZAGURUMA `:hs-kaza`, Shikai. `:hits ((6 9 :stun 8))` → `((6 9 :stun 8) (36 39 :stun 8))`:
   a second push (20 damage, kb 1.5, flinch) if L is still held at f36.
   - Why: a long hold while charging K1 bites a rusher twice, which sets up the charged K1 instead of being stuffed.
   - Risk: low to medium. HS-KAZA-TICK jumps `sf` to the active's end on release, so the second window is skipped
     cleanly. Leave the `:hs-kaza-j` bridge stock. P1's AUTO GUARD windmill would get it too.
2. **剛鎖払** — L 鎖払 SAHARAI `:hs-r-l`, ranged Bankai. `:armor-hits` 1 → 2 (frames 6–17, its charge). This is
   DUEL_ROGUE §4.1's own example.
   - Why: his only close tool trades through a 2-hit poke, so it becomes a dependable armoured reversal.
   - Risk: low. The same path as §25.23. The host test pins the stock move's `armor-hits` 1; that is fine because P1's
     copy is separate.
3. **鉄絞縄** — bind L 絞縄 KOJO `:hs-b-l`, bind Bankai. `:armor-hits` 0 → 1 (frames 6–29, the 30 f heave including
   the f20 yank).
   - Why: the noose pull can't be jabbed out of once, so KOJO becomes the bind's committal opener.
   - Risk: low as code. §25.23 says "the bind mode's L keeps none", and the user's 「增加大前搖」 made its startup its
     cost, so this softens a deliberate tell. Flag it.
4. **痺雷電** — SP1 綴雷電 TSUZURI RAIDEN `:hs-r-sp1`, ranged Bankai (the Shikai's `:hs-raiden` can share the card).
   Paralysis `:stun` 40 → 64 on its (20 23) window.
   - Why: about +13 → +37 on a 9 m hit, so the ranged J1/K1, or even KUBIKAKE (S24) into the bind, combos off it.
     SP1 becomes a string or bind starter from range.
   - Risk: low. A plain number (hw-stun). A bind in a combo is still a flinch. The CPU is not affected.

- Alternate: **首狩** — SP2 首掛 KUBIKAKE `:hs-r-kubikake` + `-c`. Whiff 60 → 36. A cheaper fishing throw. It is
  distinct from the boss's 100-Reiatsu rule.
- Needs a clip:
  - The Shikai K1 薙 NAGI arc `*hs-k1-arc*` 90° → 140°.
  - The ranged SAHARAI whirl r 3.0 → 3.8 m (the chain drawn longer).

## Coverage (base / awakened)

- Senjumaru: 1 base; 3 awakened (KASA, HITOKOSHI, TACHINAOSHI).
- Lille: 1 both forms (the charge); 2 awakened (wing armour, SANREN); 1 base (HIRENKYAKU).
- Hisagi: 1 base (the windmill); 3 awakened (SAHARAI and RAIDEN ranged, KOJO bind).
