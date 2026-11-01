# Zaraki Kenpachi: combat-module references (weapons, mechanics, design theory)

Research pass 2026-11-02, for the redesign of Kenpachi's move modules and combat logic under the core system (DUEL_CORE; current
tables: DUEL_KEN_CORE, DUEL_KEN_KATATE, DUEL_KEN_RYOTE, DUEL_KEN_NOMIHOSE; the Bankai and KATAUDE still run the base `:core`).
This file is the synthesis. The evidence is in `combat/`: four researchers' reports (`1a-katana-sword.md`, `1b-heavy-onearm.md`,
`2-game-movesets.md`, `3-berserk-theory.md`) and the verifier's pass (`verify.md`). A reference like **[1a#7]** means report 1a,
findings row 7. Nothing here changes the game; the redesign is discussed with the user first.

## The user's request and direction (verbatim, 2026-11-02)

Request: 「請使用 /academic-research-skills:deep-research 幫我收集劍八的戰鬥模組需要的參考資料，在正式開始研究前請先與我討論方向」.
Asked (AskUserQuestion), answered:

| Question | Answer (verbatim) |
|---|---|
| Directions (the canon looks, the fight-by-fight motion and the Bleach games' kits were already in `motion-refs.md` / `canon-looks.md` / `bankai-refs.md`) | 「格鬥設計理論,原作戰鬥節拍轉成模組,遊戲的狂戰士機制」 |
| The problem to solve | 「形態之間差異不夠,操作或節奏不順,先不設限,我希望能收集各遊戲、動漫與影視作品或武術分析中，關於使用片手劍、武士刀，特大劍與片手斧等等的動作分析」 |
| Forms | 「全部形態」 |
| Deliverable | 「工程筆記」 |
| Weapon classes | 「片手武士刀／單手劍,雙手武士刀／劍道,特大劍／大刀,片手斧／切肉刀／單臂」 |
| Source types | 「遊戲招式與幀數,動畫與影視分析,武術分析,設計演講與論文」 |
| Plan (4 researchers in parallel, 1 verifier, this file) | 「照計畫開始」 |

## 0. Method, grades, verification

- Four researchers, one topic each: **1a** the katana and the sword (one-handed, kendo, koryū, the longsword, screen
  direction); **1b** heavy blades and one arm (montante, greatsword, ōdachi, messer and axe with the free hand, one-armed fighting,
  how animators sell weight, swing biomechanics); **2** game movesets with frame data (GGST, GBVSR, SF6, SC6 with frames;
  Monster Hunter, Sekiro, Nioh 2, DMC5, Elden Ring as design only); **3** berserker / rage / armour mechanics and design theory
  (talks, interviews, papers). Sub-question 4 (the canon's beats as module rules) is my own synthesis from `motion-refs.md` §1 (§5
  below).
- Grades as in the reports: **A** primary (a period manual, a peer-reviewed study, a developer's own text or interview), **B**
  published or official secondary, **C** fan wiki / forum / blog. Most game-mechanic rows are C (Dustloop, Fandom through the
  MediaWiki API); the frame numbers are B (Dustloop's tables, FrameCalibur) or A (Capcom's SF6 page).
- Every claim names the page it was read on. The verifier re-fetched the pages and matched the numbers and quotes (`combat/verify.md`;
  the result is in §0.1). A claim that could not be matched was removed from the reports (gray zone = fail).
- Frame counts at 60 Hz derived from a real-world time (ms) are the researchers' arithmetic, marked "[60 Hz: …]" in the reports,
  never a source's claim.

### 0.1 Verification result

All pages re-fetched live on 2026-11-02 (none from the researchers' captures). **KEEP 208, FIX 7, DROP 1** (games 70, berserk 43,
katana 56, heavy / one-arm 39 kept). All 40 frame-table rows of report 2 match the live pages, numbers and move names; every
paper's title, authors, year and venue match Crossref or the publisher. Fixed in the copies under `combat/`:
- Cross & Bower's n = 0.27 holds at high swing-weight (Io > 0.03 kg·m²); n ≈ 0.12–0.16 below it [1b#15];
- Vaseraga's Savage Rampage has five follow-ups (March too), and no page says a third hit breaks Soul Forge's armour [2];
- Ragna's Overdrive "cranks up the lifesteal" with no figure [3];
- Ohtomo's 7 : 3 is his usual drama : action ratio, reversed for this film; Sucker Punch *states* the 0.3 s; Pichlmair's
  "cohesion, predictability" [1a, 3].

Dropped: a quote attributed to Dustloop's Hakumen page ("commit to a burst"); the stock numbers themselves are confirmed. Not
reached: Murase 2020's content, two keyword checks (UBC's "mie", Onimusha's director), Norling's montante–halberd link, Hurstwic's
axe-horn jab, Swink's book record, the researchers' 60 Hz arithmetic.

## 1. What the research says, in one screen

**Pain point 1: the forms don't differ enough (「形態之間差異不夠」).**
1. **Forms that read as different characters change the verbs, not the multipliers.** Nagoriyuki's blood gauge decides whether
   his specials or his sword normals are the right tool and takes the specials away at the top [3#1, 2#1]; Jamie starts each round
   at 90% damage with tools locked and unlocks moves and finally a stance per drink [3#2] (the closest analogue of the NOME cups);
   Tekken 8's Heat gives Kazuya Devil moves [3#3]; Spartan Rage swaps to a bare-handed set [3#5]; Zato without Eddie is "a much
   weakened character" [3#4]. Pure stat buffs are what designers kept cutting (Tekken's Rage 25% → 5%) [3#20].
   **Rule: each form owns at least one verb the others lack, and the form that gains power loses something.**
2. **Each form gets its own armour profile, and so its own counter-game.** Drive Impact (2 hits, 26 f, paint and sound; loses to
   your own DI, throws, armour breaks, fast chains; absorbed damage still KOs) [3#11, 2#2]; Power Crush (absorbs highs and mids,
   loses to lows and throws) [3#12]; Focus Attack (armour only during the charge, levels flash white / yellow) [3#13]. Profile
   knobs: hit count, which hit levels, when (startup only / through active / the charge only), whether absorbed damage is
   provisional or regained by hitting back (Bloodborne's rally; Miyazaki: the regain amount is "the personality of weapons") [3#14].
3. **Where the weight sits differs per weapon, not one slow multiplier.** Swing speed barely drops with mass (V = C/I^n, n = 0.27 at high
   swing-weight, 0.12–0.16 at low; at a fixed swing-weight, speed stays almost constant as mass rises) [1b#15]; so a heavy form keeps active frames close to the katana's and puts its
   cost in the windup, the hitstop, and the whiff recovery [1b#9, 1b#14, 1a#21]. One engine's ladder: jab impact katana 12 /
   zweihänder 16 / axe 20 f (SC6) [2#6].
4. **The grip is the clearest axis between the katana forms.** One hand = wide lateral arcs, body-first (readable) starts,
   cut-through finishes [1a#1, 1a#5, 1a#17, 1a#18]; two hands = vertical, compact, hand-first, the strike stops on the target and
   holds zanshin [1a#3, 1a#18, 1a#25]. Musashi: two hands make it "difficult to wield it freely to left and right"; switch to two
   only when one can't cut the enemy down [1a#1].

**Pain point 2: the controls or the cadence feel off (「操作或節奏不順」).**
5. **Slow to fast (由緩至急) inside a string: only the first press must be reactable.** Ghost of Tsushima: realistic katana speeds
   were too fast to react to (about 0.3 s), so "the first attack is slow enough to react to, but the others happen fast" [1a#7]. A
   uniform string reads less real (Tanigaki: "As the number of steps increases, it becomes less real"; Ohtomo writes drama : action
   7 : 3 as a rule and reversed it for this film) [1a#12]; Kurosawa: "Rapid pacing requires the foil of extreme immobility" [1a#9]. Note: 0.3 s ≈ 18 f, so the module rule
   "openers ≥ 14 f" sits just under the reaction floor: a 14 f tell reads only when the player is watching for it.
6. **Count links from the end of the hitstop.** "the cancel takes effect at the end of the hitstop" [1b#18]. If a heavy form gets a
   longer hitstop and its link / buffer windows count from the hit frame, the rhythm that works for the katana arrives early on the
   cleaver. (In SOUL DUEL today every Kenpachi move takes the kind's global hitstop, `*hitstop-light*` 4 / `*hitstop-heavy*` 8 /
   `*hitstop-breaker*` 10 f (tuning.lisp, `kit.lisp` `parse-move` `:hs`), so the forms' hits all freeze alike; a per-form `:hs` is
   possible.)
7. **Hitstop scales with the hit, with a cap**: Sakurai [1b#17]; GGST 11 → 15 f by attack level, hitstun 12 → 21 f [2#8]; hitstop,
   sound coherence and camera most influence "impact feel" (Lin et al. 2022) [3#28]; MH Wilds cut it and restored it on player
   demand [1b#30, 3#29].
8. **"Feels off" is usually streamlining, not juice.** Pichlmair & Johansen (IEEE ToG 2022): tuning / juicing / streamlining, the
   last one "allows a game to act on the intention of the player" (buffers, cancel windows) [3#31]; visual embellishments raise
   appeal but help competence only in specific cases (Hicks et al., CHI PLAY 2019) [3#32].
9. **A slow phase must still hold choices.** SF6 deliberately gives "excitement and freedom from the very beginning" [3#22]; a
   fighter that builds slow → fast stands out, but its slow phase can't be empty (Jamie's level 0 still has a full kit) [3#2].
   Resources the player's own actions build pace the climb: Jamie's drinks, Hakumen's 1 of 8 stocks [3#9], Young Joseph's level-up
   for countering with three *different* moves [3#16], Ragna's lifesteal rising inside a combo [3#19].

**Keeping a berserker fair.** A berserk mode ends by (a) a **hit budget** (GBVS Overdrive −33% a hit taken [3#6]; Berserk Musou's
Frenzy ends after "too many hits" [3#7]; Spartan Rage's gauge takes the damage [3#5]), (b) a **cash-out that ends it** whether it
lands or not (Samurai Shodown's Lightning Blade [3#8], Tekken's Heat Smash [3#18]), or (c) a **crash** afterwards (Sol helpless
after Dragon Install [3#17]; Zato's broken state [3#4]). Keep passive multipliers small; comeback boosts that are strong and
permanent make the match see-saw [3#26].

## 2. One profile per form

The table puts each form's weapon model next to the rule it suggests. "Cost" = where the weight / the risk sits (§1 point 3).
"Own verb" = the thing only this form does (§1 point 1). These are candidates for the discussion, not decisions.

| Form | Weapon model | Tempo shape | Cost (where the weight sits) | Stance and tell | Armour profile | Own verb (candidate) |
|---|---|---|---|---|---|---|
| base | one-handed katana, no school: Musashi's warned-against "short sword chopping" [1a#17], Lecküchner's Zornhau "a simple peasant stroke" [1a#16, 1b#5], Silver's foot-led "false times" [1a#5] | short choppy arcs; explosive arm-thrown cuts 250–350 ms, stepless, short reach [1a#2] | short reach; a reckless string that a deflect punishes (Sekiro posture) [2#17] | body-first, early and wide; a weight shuffle before the big cut [1a#4]; the blade carried low | none (he takes the hit in canon, but armour is the other forms' tool) | the crude overhead that wins a clash from above [1b#5]; the "cut me" offer (§5) |
| KATATE | messer + free hand (Lecküchner) [1b#1–#4], bearded axe [1b#33], the falchion's quickness [1b#40] | check → chop pairs; quick chops whose weight shows on contact | the free hand's setup before the grab | the free hand **on the back**, brought to the chest before a punch / grab [1b#1, 1a#15] | Power Crush-like: absorbs some hit levels, loses to lows / throws [3#12]; or a rally window after a trade [3#14] | the free hand: check, punch, grab, throw over the leg [1b#2–#4] |
| RYOTE | kendo, koryū (tame, seme, zanshin) [1a#3, #10, #25, #31], Meyer's Zornhau poses [1a#32] | stillness (tame) → one fast release (elite 0.09–0.15 s from swing start to impact [1a#22]) → a held zanshin; a stopped strike 25–35 ms later than a through-cut [1a#19] | the long still windup; the strike stops on the target | chūdan / jōdan / hassō kamae [1a#34–#37]; skill shows in the upswing, not the drop [1a#3] | none (current design: charges without armour), or only during the charge with colour levels [3#13] | charge tiers carried forward (MH Great Sword's Charged → Strong → True, the tackle braces and upgrades) [2#5]; a level-up only by landing the finisher (MH Long Sword) [2#13] |
| NOMIHOSE | montante wheel (Figueyredo) [1b#6–#11], Jigen-ryū's alternating left / right [1a#14], Nagoriyuki's blood [2#1] | an unbroken left / right stream, each cut turning the body; the side a cut ends on decides the next [1b#8] | a whiff: "you could dangerously fall … by missing" [1b#9]; more damage taken per level [2#1] | a pivot foot [1b#11]; no guard pose [1a#14] | a **hit budget** for the whole form (Overdrive's three hits) [3#6] | startups that shorten per level and a kit half that switches off at the top (Nagoriyuki) [2#1, 3#1] |
| Bankai | "a bladed maul" (the Dragon Slayer's flat as hammer and shield) [1b#12]; prefer the axe "whenever you have all the time in the world to get it up to speed" [1b#14]; Jigen-ryū's one run-in cut [1a#13] | the longest tell, one huge cut that catches and drags (Tanigaki: "caught in the meat once") [1a#11], a frozen mie finish [1a#47, not re-checked by the verifier] | the windup and a huge hitstop; downward cuts [1b#37] | blade on the shoulder [1b#36]; one universal danger cue per attack class (Sekiro's perilous kanji) [2#14] | armour that covers the whole tell, louder payoff when it eats a hit (Drive Impact) [2#2]; Berserker Armour's self-damage [1b#23] | the arm as a gauge drained by use and hits, its break a lockout into KATAUDE (Zato's 273 f broken state) [3#4]; a bite [1b#23] |
| KATAUDE | one arm, **bare-handed** (no blade since the user's 「改成空手（照原作）」, 2026-10-09, DUEL_KEN_REWORK §8: the left fist, a grab, the legs): trunk leans and twists to the intact side, rotation axis there (Nakamura & Okita, gait) [1b#19]; Meyer's spinning one-hand strike that "momentarily exposes" him [1b#21–#22] (a sword move; its spin and opening carry over to a fist) | spin-driven, trunk not forearm (forearm-only swings slow more with weight) [1b#16] | the opening after the spin | the asymmetric lean; an empty sleeve that trails [1b#44]; a one-handed jōdan exists [1a#35] | low-HP armour during attacks (JoJo ASB's Resolve) [3#16] | the missing limb as a move source (Sekiro's prosthetic "multi-use feature", Guts' teeth) [1b#31, 1b#42]; a boost scaled by how far behind he is (X-Factor) [3#25] |

## 3. Cadence and feel rules (candidates)

| # | Rule | Evidence | SOUL DUEL hook |
|---|---|---|---|
| C1 | Only an opener needs the reactable tell; later segments may be faster | [1a#7] | keep NS first segments and NA1 ≥ 14 f (DUEL_CORE §5 recipe); shorten b / c |
| C2 | Active frames stay close across weights; weight goes to startup, hitstop, whiff recovery | [1b#15, 1b#9, 1a#21] | per-form S and whiff R, not a global ×reach / +startup |
| C3 | One startup tier per form | [2#6] | e.g. base ~14, KATATE ~16–18, Bankai ~20+ (SC6's ladder; a candidate, not a number to copy) |
| C4 | Hitstop per form, scaled by damage, capped | [1b#17, 2#8, 3#28] | per-move `:hs` (today all 4 / 8 / 10) |
| C5 | Link and buffer windows count from the end of the hitstop | [1b#18] | check `core-sim` latched presses against a longer `:hs` before changing it |
| C6 | Short strings, slow then sudden; a held stillness before the burst | [1a#9, 1a#12] | RYOTE's tame hold; the Kikon hold |
| C7 | A feint in the gap | Nagoriyuki f.SS → feint [2#3]; Musashi's "Abdomen Timing of Two" [1a#27] | the SA in an NS gap |
| C8 | The charge level must be visible to both players | MH's squat cue [2#5], Focus Attack's colours [3#13] | NS3 charges' `:aura-k`, a colour per level |
| C9 | Polish the input side first | [3#31, 3#32] | buffers and cancel windows before more VFX |

## 4. Mechanics catalogue for the berserker (candidates)

| Mechanic | Example | What it would mean for Kenpachi | Evidence |
|---|---|---|---|
| power-up levels that unlock verbs | Jamie's drinks | the NOME cups unlock NS segments / AS enders, the top changes stance | [3#2] |
| one gauge flips which half of the kit is good | Nagoriyuki | NOMIHOSE: NA strengthens and NS3 switches off at the top | [3#1, 2#1] |
| hit budget | GBVS Overdrive, Berserk Musou Frenzy | NOMIHOSE or the Bankai ends after n hits taken | [3#6, 3#7] |
| cash-out ends the mode | Lightning Blade, Heat Smash | an AS3 / Kikon that ends the Bankai | [3#8, 3#18] |
| crash after the mode | Dragon Install, Zato | the arm breaks: a lockout, then KATAUDE | [3#17, 3#4] |
| taken damage stored as offence | Revenge Gauge, Royalguard, Focus Attack | armoured hits feed SUBLIMATION or the next SA (pointer 2's cancels already do) | [3#24, 2#12] |
| regain by hitting back | Bloodborne rally | provisional damage regained by the next strike; the rate per form | [3#14, 3#15] |
| timer paused by offence | Tekken Heat | the form lasts while he keeps hitting (NOME's drain pauses on hit) | [3#18] |
| low-HP armour | JoJo Resolve | KATAUDE or the last Konpaku | [3#16] |

## 5. The canon's beats as module candidates (from `motion-refs.md` §1)

Each line: the beat (with its §), the class it could become, and the form. The grammar is DUEL_CORE's (NA / NS / AS n / SA / Kikon).

| Beat | Source | Candidate | Form |
|---|---|---|---|
| "Cut me anywhere": arms open, takes the cut, the forearm shove | §1.2, RoS signature (§2.1) | a hold stance that absorbs (pointer 2), release strike scaled by what it took | base |
| The blade dragged tip-down on the approach, up into the clash | §1.2 | an NS opener's tell (the drag is the ≥ 14 f windup) | base / KATATE |
| Grabs the opponent's blade and twists him off his feet while stabbing | §1.2 | an AS segment after a cancel (grab → thrust) | KATATE |
| Vanishes, strikes from behind; the bells give him away | §1.2 | the Kikon flash-step, the bell sound as its tell | all |
| Stabs through the guarding sword into the chest | §1.2 | a guard-piercing AS ender (a thrust) | base / RYOTE |
| Takes the face cut on purpose to close the gap, laughing | §1.2 | an armoured lunge segment | base / NOMIHOSE |
| Eyepatch off: a tiny wrist flick fells a building | §1.2 | the awakening; an SA with a tiny motion and a big effect | base |
| Two hands only when losing; the left hand on the pommel; Ryōdan | §1.1, §1.4 | RYOTE as the "losing" form; Ryōdan as pointer 3's finisher | RYOTE |
| Kicks Ichigo aside; the foot out of the rubble | §1.4 | the free limb's SA | KATATE |
| Plants the sword, yanks the chain, slams the head | §1.4 | an AS2 grab (plant → grab → slam → stab down) | KATATE |
| Catches a weapon by the blade; catches a Cero and throws it | §1.4 | a catch as a cancel variant (the triangle's bounce, then a free hit) | KATATE / base |
| An upward slash launches | §1.4 | AS2's launch | all |
| Leaps at the meteor, releases the Shikai mid-leap, cuts it in two | §1.7 | AS3's meteor (exists) | KATATE+ |
| Rips off his own warped arm, rushes on | §1.8 | the KATAUDE entry | Bankai → KATAUDE |
| Bites the knuckle, rips the arm off | §1.9 | a bite grab (AS or SA) | Bankai |
| Leaps and slashes; punches the chin; bisects vertically | §1.9 | NS a / b / c or AS3: leap slash → chin punch launch → vertical bisect | Bankai |
| Leaps back and roars | §1.9 | a stance / charge segment (roar = the tell) | Bankai |
| The right arm shatters | §1.9 | the crash (§4) | Bankai |
| Trips the giant by the feet, mutilates them | §1.9 | a low segment while injured | KATAUDE |

## 6. What the current build already has, and the gaps the research points at

- **The Bankai and KATAUDE run the base form's `:core`** (checked in `ken.lisp` 2026-11-02: `defkit :kenpachi :bankai` names the base
  literal `:core` with the comment "the Bankai is not reworked yet"; `:kataude` inherits `:base` and sets no `:core`, its fists and grab
  only re-skinning the base moves through `:clip-map`). They have no verbs of their own under the core system: the clearest case of
  「形態之間差異不夠」 (§1 point 1).
- **NOMIHOSE uses RYOTE's stance poses** (`ken.lisp` `:stances (:ke-r-st-chain :ke-r-st-rush :ke-r-st-kamae)`, "cup 3's own poses are
  not drawn"); its strikes are RYOTE's moves on cup 3's clips, NS1 the kendo set with armour.
  The montante wheel and the hit budget (§2) are the research's alternative.
- **The cups re-skin one theme per pointer** (DUEL_KEN_KATATE: 「同主題、各杯換個性」). The research favours a verb per form
  over a skin per form; whether to keep the themes fixed across forms is the user's call.
- **Hitstop is shared** (4 / 8 / 10 f by kind) and the forms differ by ×reach / +startup / ×damage (KATATE ×1.3 reach +2 S, RYOTE
  ×1.4 +3, DUEL_KEN_KATATE §1 / DUEL_KEN_RYOTE §1): exactly the "slow multiplier" §1 point 3 warns against.
- **Pointer 2's cancels feeding the SA** (DUEL_KEN_CORE §2) is already the "taken damage stored as offence" pattern (§4).

## 7. Gaps (searched, not confirmed)

- No frame data for Monster Hunter, Elden Ring, Sekiro, Nioh 2 or Samurai Shodown 2019 (SuperCombo blocked; design notes only).
- No frame-level analysis of Guts' animated fights, no TYBW action-direction interview, no sakuga breakdown of Kenpachi's fights.
- No primary ōdachi kata text; no study of one-armed people *fighting* (only walking).
- Dropped for lack of a readable page: Soulcalibur's Revenge, DMC's Devil Trigger rules, a Sekiro posture interview, the God of
  War GDC 2019 talk, Sakurai's hitstop video episodes.
