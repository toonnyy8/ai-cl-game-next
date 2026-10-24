# SOUL DUEL: Rukia, TYBW look, motion modules and a new Shikai (2026-10-24)

Status: **in design** (the request and the scope are decided, §1–§2; the diagnosis §3; the Shikai's combat logic is a
proposal under discussion, §4). Skills: `duel-move-modules` (the Shikai's grammar), `duel-motion-style` (decide,
research, plan, measure, draw), `duel-character-rework` (presentation vs sim, the proofs). Research:
`docs/research/rukia-rework/` (canon looks, canon motion, nihon buyō style references; in progress) on top of
`docs/research/tybw-characters/notes/rukia_tybw.md`. Earlier design: `DUEL_RUKIA.md` (the kit as built 2026-09-28 and
every decision since; it stays the record of the awakening's rules), `DUEL_STRINGS.md` §2 / §12.

## 1. The request

> 我想要請你依據 repo 中的 skill 重新調查與設計露琪亞的動作模組，並與我討論設計細節
> (the user, 2026-10-24)

The lead's diagnosis (§3) and three directions (A: one 舞 stance grammar for both forms; B: rebuild the awakening only;
C: motion only) went to the user with four questions. The answers:

> 範圍：「重作整體造型模組，並重新設計始解的戰鬥邏輯。覺醒只改動作模組跟對應的攻防距離，核心的戰鬥邏輯不變」
> 動作風格：「原作舉止＋日本舞踊」
> (the user, 2026-10-24; no preference on the awakening's cold sources and on −273 °C, which follow from the scope)

## 2. Scope (decided)

| Part | In scope | Kind of change |
|---|---|---|
| Look (model) | the whole model of every form: the TYBW Shikai battle look, the −273 white look, the 白霞罸 Bankai look | presentation (stills, byte-identical sim) |
| Shikai `:base` | **the combat logic is redesigned** (the move set's grammar, its resource, its routes), then its motion modules | sim change: gated against the parent, her pairings at 20 seeds |
| Awakening `:m18` / `:m50` / `:zero` | **the motion modules and the matching attack / defence distances** (reach follows the drawn motion: 「對應的攻防距離」); **the core rules stay**: the cold gauge (two bars, its gains, warming, spending, the band lock, the overdraft), the bands' walk / run, −273's rooting, ward, freeze-touch, bracing, the CRACK, the field, the Hoho cold | reach only: a sim change limited to hit volumes, gated; every other awakened number byte-identical |
| Motion style | 「原作舉止＋日本舞踊」: canon manner and the canon dances (grade A), the strikes in nihon buyō's body language (扇の手, 回り, 摺り足, 見得; grade D proposals) | — |
| Not in scope | the awakened kits' rules above; the DANGAI cards that read them (永凍, 永久凍土, 霜柱無尽 …; re-checked once the Shikai's rules settle) | — |

Implementation note: the awakened kits `:inherit :base`, so any Shikai command, string or knob the new logic changes must
be pinned in `:m18` (or overridden) so the bands keep their rules (a host test lists the awakened kits' commands and grids
before and after).

## 3. Diagnosis (main e378418, 2026-10-24)

### 3.1 The Shikai's grammar (the `duel-move-modules` checklist)
- The attack state is the universal grid (J1–J3 / K1–K3, the six routes, DUEL_STRINGS §2.1); K hits frost (walk / run
  ×0.7). L is TSUKISHIRO (a ring under him ≤ 8 m, the pillar 24 f later; the K → L copy at S 8). SP1 HAKUREN (held 1–4
  stabs, a wave), SP2 SHIRAFUNE (a 5 m ice thrust), I HAINAWA, O ENBU (a shunpo rush into a spin).
- **No resource of her own and no routes**: each canon dance is one button, the universal bars pay for SP. Nothing gives
  a button a role (gain / refill / damage) and nothing follows a string except K → L and the O ender.
- It works: the gates are inside the window and the dances are canon. What it lacks is a decision inside her strings.

### 3.2 The awakening (kept by the scope; recorded for the motion and reach pass)
- The cold gauge has about 15 special rules stacked over a month (the hysteresis by bars, the band switch only while
  free, the combo band lock, the K → L overdraft, only L spending at −18, three warming rates, the ward that also guards
  shots, freeze-touch, bracing, the CRACK, the THAW lock, the Hoho's +50, the field, the DANGAI 永凍 floor). The skill reads
  this as a redesign signal; the user keeps the rules (§2), so only motion and reach change there.
- The user's playtest-1 point 5 (「越冷越強，而且每個階段要有看得出不同的動作」, DUEL_RUKIA "Playtest 1") is met only in part:
  see §3.3.

### 3.3 Clip inventory (31 clips; S / A / R in frames, loops in seconds)

| Clip | S/A/R | Plays | Note |
|---|---|---|---|
| `:ru-stance` | loop 1.8 s | Shikai idle | a light bounce |
| `:ru-cold-stance` | loop 2.6 s | −18 / −50 idle; 白霞罸's tell | |
| `:ru-zero` | loop 4.0 s | −273 idle | |
| `:ru-q1` | 7/3/12 | J1 in Shikai, −18, −50 (and −273 through the white body's swap to `:ru-q1-z`) | **one clip, three forms** |
| `:ru-q2` | 7/3/13 | J2 in Shikai, −18, −50 | **one clip, three forms** |
| `:ru-spin` | 8/3/18 | J3 in Shikai, −18, −273; **ENBU's strike** | shared with O |
| `:ru-thrust` | 17/4/20 | Shikai K1 (−273 swaps to `:ru-thrust-z`) | |
| `:ru-ring` | 21/4/24 | **K2 in all four forms** | the one clip that never changes |
| `:ru-drop` | 21/5/34 | Shikai K3 | |
| `:ru-tsukishiro` | 10/0/26 | L, its K → L copy | |
| `:ru-stab` | loop | HAKUREN's charge; **−18's SHIMOBASHIRA** | shared |
| `:ru-hakuren` | 6/1/24 | SP1 release (Shikai, −50, −273 at `:clip-s 6`) | |
| `:ru-shirafune` | 16/4/28 | SP2 in all four forms | |
| `:ru-breaker`, `:ru-hainawa` | loop, 8/4/18 | I | |
| `:ru-kikon` | 2.0 s | ENBU's Kikon pose | |
| `:ru-intro`, `:ru-win`, `:ru-awaken`, `:ru-hand` | 2.0 s | intro, win, the awakening, 白霞罸's last shot | |
| `:ru-palm` | 17/4/20 | −18 K1 TŌSHU; **−273 J2 at `:clip-s 17`** | a K clip sped up for a J (the skill's red flag) |
| `:ru-flower` | 21/5/34 | −18 K3 HYŌKA; −273 K3 | |
| `:ru-palm-50`, `:ru-spin-50`, `:ru-flower-50` | 17/4/20, 8/3/18, 21/5/34 | −50 K1, J3, K3 | |
| `:ru-stab-2h` | 0.4 s | −50 L HYŌSHIN | |
| `:ru-reido` | 6/0/26 | −273 L at `:clip-s 6` | |
| `:ru-hakka` | 20/3/30 | O 白霞罸 (all bands) | |
| `:ru-q1-z`, `:ru-thrust-z` | 7/3/12, 17/4/20 | −273 J1, K1 (the white body's clip swap) | |

Strike clips of its own per form (J1–J3, K1–K3; the rest are another form's): Shikai 6 of 6, −18 2 (K1, K3), −50 3
(J3, K1, K3), −273 2 (J1, K1; its J2 is −18's K1 sped up, its K3 is −18's). Every clip dates from 2026-09-28, before the motion-style
skill: no anticipation squats, no follow-through, the hit poses held on a planted stance (the same findings as Ichigo's and
Yamamoto's TYBW diagnoses). The FK reach report and the 8-frame strips come with the motion plan.

## 4. The Shikai's combat logic: proposals (under discussion)

The user decided the scope; the shape is still open. Three whole candidates, each a grammar the `duel-move-modules`
recipe can encode once (a segment table, its knobs in `rukia.lisp`); the user may pick or combine.

| | 1. 舞 stance (Lille's grammar) | 2. 舞の順 the dance order | 3. 霜の層 frost layers on him |
|---|---|---|---|
| Attack state | the universal J / K grid | the universal J / K grid | the universal J / K grid |
| L | enters the stance; inside it L1–3 stab the plaza (gain 雪 +1 each), J1–3 shunpo cuts (reposition, refill Reiatsu), K1–3 ice cuts (damage) | **the next dance in canon order**: 初の舞 月白 (ring) → 次の舞 白漣 (wave) → 参の舞 白刀 (ice blade) → 初 again; each dance that hits makes the next one stronger | TSUKISHIRO as now; its freeze adds 2 layers |
| Resource | 雪 pips 0–6 (hers) | the dance index 初 / 次 / 参 (a position, not a meter) | **霜 layers 0–3 on the opponent** (each slows his walk / run ×0.85 / 0.7 / 0.55 and thaws over time) |
| Routes | J3 → JL1–3 月白 rings ≤ 8 m (1 pip each); K3 → KL1–3 白漣 lanes (1 pip each) | K → L plays the current dance as a combo copy | K hits and the dances add layers; at 3 layers he is brittle |
| SP2 | 参の舞 白刀, spend-all (length and damage by pips), only off a string hit | 舞・終: the three dances in one move | 参の舞 白刀 **shatters** the layers (damage by layers, resets them) |
| Identity | a stance dancer like Lille | a dancer who plans her next figure | a freezer who builds and shatters, the awakening's frost-on-every-hit foreshadowed |
| Risk | the most work; close to Lille's grammar (「避免同質化」) | predictable for the opponent; the CPU must plan the order | a new status rule on the victim (host tests, the CPU's thaw read) |

The lead recommends **3** (her own resource on the victim, the canon "freeze, then shatter" of Tsukishiro and
Shirafune's wound that keeps freezing, the fewest new moves), optionally with 2's dance order for L. The questions the
skill asks before any build (tap or hold per button and its one-hand mapping, what a press does with nothing to pay,
which hits reach far, where each string ends, what she does at 2 m) follow once the shape is chosen, as a segment table
for the user's yes.

## 5. Next steps
1. The research notes (`docs/research/rukia-rework/`), then the look plan (a model-sheet review against canon, stills).
2. The Shikai's grammar chosen → its segment table → the user's 「可以」 → the sim batch, host tests, gates vs the parent.
3. The motion plan per form (inventory → archetype per string → slot table) → 「可以」 → the clips, FK reach, the awakened
   bands' volumes moved to the drawn reach (gated), before/after sheets from both cameras, landscape and portrait.
