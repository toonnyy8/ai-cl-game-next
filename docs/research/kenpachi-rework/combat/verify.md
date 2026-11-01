# Source verification of the four Kenpachi research reports (2026-11-02)

The verifier fetched every page live on 2026-11-02, with curl, a browser user agent and the Fandom/Wiktenauer/Wikipedia
MediaWiki API, and reduced each page to text before string-matching it. The researchers' captures were never needed:
**no verdict below is CACHED**. Two notes on fetches:
- The SF6 official page answered 403 to a bare request and 200 to one with browser `Accept` headers.
- eurjhm.com (Ogle) answers HTTP 500 but serves the full article page in the body.

Verdicts: KEEP = number / quote / meaning found on the page. FIX = the page supports a corrected version (given).
DROP = not on the page.

Source keys used in the URL column (full URLs):
- **NFD** https://www.dustloop.com/w/GGST/Nagoriyuki/Frame_Data (oldid 558768, "last edited on 12 April 2026": confirmed)
- **NAG** https://www.dustloop.com/w/GGST/Nagoriyuki (oldid 582233 confirmed)
- **PFD** https://www.dustloop.com/w/GGST/Potemkin/Frame_Data (oldid 504653 confirmed)
- **POT** https://www.dustloop.com/w/GGST/Potemkin (oldid 581585 confirmed)
- **VFD** https://www.dustloop.com/w/GBVSR/Vaseraga/Frame_Data (oldid 431094, "22 December 2023": confirmed)
- **VAS** https://www.dustloop.com/w/GBVSR/Vaseraga (oldid 580659 confirmed)
- **SF6Z** https://www.streetfighter.com/6/character/zangief/frame
- **SF6D** https://web.archive.org/web/2024id_/https://wiki.supercombo.gg/w/Street_Fighter_6/Drive_System
- **SCM** https://web.archive.org/web/20220809023141id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Mitsurugi/Move_list (oldid 210702, "provided by FrameCalibur": confirmed)
- **SCN** https://web.archive.org/web/20220815131750id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Nightmare/Move_list (oldid 210703 confirmed)
- **SCA** https://web.archive.org/web/20240114072952id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Astaroth/Move_list (oldid 210686 confirmed)
- **DMC** https://devilmaycry.fandom.com/wiki/Royalguard_Style (wikitext via API)
- **ER** https://eldenring.wiki.fextralife.com/Poise
- **MHGS / MHLS** https://mhworld.kiranico.com/guide/great-sword , https://mhworld.kiranico.com/guide/long-sword
- **SEKP / SEKA** https://sekiroshadowsdietwice.wiki.fextralife.com/Posture , https://sekiroshadowsdietwice.wiki.fextralife.com/Perilous+Attacks
- **NIOS / NIOO** https://nioh2.wiki.fextralife.com/Stances , https://nioh2.wiki.fextralife.com/Odachi
- Report 3 and the 1a / 1b reports: the URL as written in the report's row (each fetched exactly as written).

## Verdict table

### 2-game-movesets.md: (b) frame-data table, every row

| report | row or claim | URL | verdict | evidence (page text) |
|---|---|---|---|---|
| 2 | Nagoriyuki 5P 5 / 3 / 9 | NFD | KEEP | "5P \| 26 \| All \| 5 \| 3 \| 9 \| 0" |
| 2 | f.S L1/L2/L3/BR 16/14/12/12, act 3, rec 28, -17 | NFD | KEEP | "f.S Level 1 … 16 \| 3 \| 28 \| -17"; L2 14, L3 12, BR 12 |
| 2 | f.SS L1 13 / 3 / 19, -8 | NFD | KEEP | "f.SS Level 1 \| 25 \| All \| 13 \| 3 \| 19 \| -8" |
| 2 | f.SSS L1 14 / 6 / 35, -22, HKD +35 | NFD | KEEP | "f.SSS Level 1 … 14 \| 6 \| 35 \| -22 \| HKD +35" |
| 2 | 5H 20/16/16, 6, 27, Guard Crush, -8 | NFD | KEEP | "5H Level 1 … All (Guard Crush) \| 20 \| 6 \| 27 \| -8"; L2/L3 16 |
| 2 | 2H 19/17/15, 7, 29, GC, -11 | NFD | KEEP | "2H Level 1 … 19 \| 7 \| 29 \| -11"; L2 17, L3 15 |
| 2 | 6H 17/16/15, 6, 30, GC, -2 | NFD | KEEP | "6H Level 1 … 17 \| 6 \| 30 \| -2"; L2 16, L3 15 |
| 2 | 214S Yukimoyoi 29 / 4 / 9, Low, +6 | NFD | KEEP | "214S \| Yukimoyoi \| 61 \| Low \| 29 \| 4 \| 9 \| +6" |
| 2 | BR Activation 4+(38 Flash)+3 / 10 / 70, GC, 1-16F Full | NFD | KEEP | "BR Activation \| 0 \| All (Guard Crush) \| 4+(38 Flash)+3 \| 10 \| 70 … 1-16F Full" |
| 2 | Hitstop Lv.0–4 11–15; standing hitstun 12/14/16/19/21 | NFD | KEEP | table "Lv.0 11 12 … Lv.4 15 21" |
| 2 | Potemkin [4]6H Hammer Fall 18~37 / 2 / 34, armour 5~38F, -17 | PFD | KEEP | "[4]6H \| Hammer Fall \| 58 \| All \| 18~37 \| 2 \| 34 \| -17 … 1 Hit Armor Mid/Overhead 5~38F" |
| 2 | Hammer Fall Break rec 21, armour 1~9F | PFD | KEEP | "[4]6H P \| Hammer Fall Break … 21 … 1 Hit Armor Mid/Overhead 1~9F" |
| 2 | 623K Heat Tackle 12 / 13~28 / 32~38, armour 12~39F | PFD | KEEP | "623K \| Heat Tackle \| 72 \| All \| 12 \| 13~28 \| 32~38 … 1 Hit Armor 12~39F" |
| 2 | 214H Garuda Impact 28 / 11 / 24, GC, +19 | PFD | KEEP | "214H \| Garuda Impact \| 63 \| All (Guard Crush) \| 28 \| 11 \| 24 \| +19" |
| 2 | Potemkin 6H 23 / 7 / 35 | PFD | KEEP | "6H \| 65 \| All \| 23 \| 7 \| 35" |
| 2 | Vaseraga c.L 7 / 3 / 6 | VFD | KEEP | "c.L \| 600 \| Mid \| 7 \| 3 \| 6" |
| 2 | c.H 15~29 [30] / 6 / 21, [12-34 Armor ×2] | VFD | KEEP | "c.H … 15~29 [30] \| 6 \| 21 … Soul Forge: [12-34 Armor ×2]" |
| 2 | f.H 17~29 [30] / 6 / 23, [12-34] | VFD | KEEP | "f.H … 17~29 [30] \| 6 \| 23 … [12-34 Armor ×2]" |
| 2 | 2H 13~29 [30] / 6 / 26, [11-35] | VFD | KEEP | "2H … 13~29 [30] \| 6 \| 26 … [11-35 Armor ×2]" |
| 2 | 66H 20~39 [40] / 4 / 23, [19-47] | VFD | KEEP | "66H … 20~39 [40] \| 4 \| 23 … [19-47 Armor ×2]" |
| 2 | 5U Soul Forge 21 / 3 / 17, 5-23 Armor ×2 | VFD | KEEP | "5U \| Soul Forge \| 1300 \| Mid \| 21 \| 3 \| 17 … 5-23 Armor ×2" |
| 2 | 22X~H Crushing Strike 15 [40] / 2 / 31, GC 49, 1-16 [1-41] | VFD | KEEP | "22X~H \| Crushing Strike … Mid [Guard Crush 49] \| 15 [40] \| 2 \| 31 … 1-16 [1-41] Armor ×2" |
| 2 | 22X~U Ravaging Stomp 20~40 / 6 / 30, 1-25~45 Superarmor | VFD | KEEP | "22X~U \| Ravaging Stomp … 20~40 \| 6 \| 30 … 1-25~45 Superarmor" |
| 2 | Raging Strike 28 (1) / 1 / 37, GC 45 [52] | VFD | KEEP | "Raging Strike \| 1500 \| Guard Crush 45 [52] \| 28 (1) \| 1 \| 37" |
| 2 | Zangief Standing Heavy Punch 16 / 16-18 / 22, held armour from frame 4 | SF6Z | KEEP | "Standing Heavy Punch H \| 16 \| 16-18 \| 22 … When the button is held, 1 hit of super armor is added to the upper half of the body from frame 4" |
| 2 | St.HP (Charged) 32 / 32-34 / 22, armour 4-34 | SF6Z | KEEP | "Standing Heavy Punch(Charged) Hold H \| 32 \| 32-34 \| 22 … Super Armor for 1 attack from frames 4 - 34" |
| 2 | Drive Impact 26 / 26-27 / 35, armour 2 hits 1-27, -3 | SF6Z | KEEP | "Drive Impact: Double Russian Chop HH \| 26 \| 26-27 \| 35 \| D \| -3 … Super Armor for 2 hits from frames 1 - 27" |
| 2 | Mitsurugi A impact 12 | SCM | KEEP | "Prime Moon Shadow Rush \| A … Impact … 12" |
| 2 | Mitsurugi B impact 14 | SCM | KEEP | "Celestial Divide \| B … 14" |
| 2 | Nightmare A impact 16 | SCN | KEEP | "Plague Spreader \| A … 16" |
| 2 | 6A Blood Storm 22, Armor[10-20] | SCN | KEEP | "Blood Storm \| 6A … 22 \| 20 \| -16 … Armor[10-20]" |
| 2 | 6B Double Avenger 22, Armor[10-22] | SCN | KEEP | "Double Avenger \| 6B … 22 … Armor[10-22]" |
| 2 | 6A+B Soul Wave 36, Armor[10-35], -14 | SCN | KEEP | "Soul Wave \| 6A+B … 36 \| 30 \| -14 … Armor[10-35]" |
| 2 | 1A / 1(A) Shadow Slicer 32 / 62 | SCN | KEEP | "1A … 32 … 1(A) … 62" |
| 2 | Astaroth A 20 | SCA | KEEP | "Annihilation \| A … 20" |
| 2 | Astaroth B 20 | SCA | KEEP | "Great Divide \| B … 20" |
| 2 | 1B / 1(B) Ax Grave 24 / 34, held +6 | SCA | KEEP | "1B … 24 \| 24 \| -18 … 1(B) … 34 \| 30 \| 6" |
| 2 | Vicious Madness 46, Armor [10-46] | SCA | KEEP | "Vicious Madness \| (3)_(6)_(9)A+G … 46 … Armor [10-46]" |
| 2 | SC 1AA Bringer of Ruin 36, Armor [8-32] | SCA | KEEP | "Bringer of Ruin \| SC 1AA … 36 … Armor [8-32]" |
| 2 | DMC5 Royal Block window 6 | DMC | KEEP | "the perfect guard timing window is exactly the same (6 frames)" |

### 2-game-movesets.md: narrative (a) and findings table (c)

| report | row or claim | URL | verdict | evidence |
|---|---|---|---|---|
| 2 | Blood gauge 3×100, +90 per special, Fukyo +43.2 | NAG | KEEP | page lists +90, 43.2, 57.6, 115.2, 7.2 gauge values |
| 2 | "+11% at one bar filled", "+25% at two bars filled" | NAG | KEEP | exact strings |
| 2 | Blood Rage "loses access to special moves and drains up to 75% of his HP" | NAG | KEEP | exact; "cannot KO … can leave him with 1 HP" |
| 2 | Feint: "If nothing is pressed afterwards, Nagoriyuki feints the animation for f.SSS" | NAG | KEEP | "feints the animation for f.SSS" |
| 2 | No run, no airdash | NFD | KEEP | "Fukyo, Unique High Jump, No Run, No Airdash" |
| 2 | Hammer Fall Break "armor through two hits with careful timing"; "armored taxi" | POT | KEEP | both strings present |
| 2 | Armour "is vulnerable to lows, and can be broken by quick successive attacks such as multi-hits" | POT | KEEP | page has the sentence with the typo "sucessive" |
| 2 | Armoured hits 50% damage | POT | KEEP | "The damage of attacks that the armor endures is reduced by 50%." |
| 2 | Soul Forge "applies 2 hits of Armor to certain moves such as H attacks and his Savage Rampage stance" | VAS | KEEP | exact |
| 2 | Soul Forge armour takes 50%; third hit breaks through (§2 and (c) row 4) | VAS | FIX → "2 hits of armor; armoured hits take 50%" | "gives 2 hits of armor … damage reduced by 50%"; no sentence says a third hit breaks it |
| 2 | Meter drains once an armoured move is used; knockdown = re-apply | VAS | KEEP | "meter will start going down after using a move affected by Soul Forge … Can be safely used after a knockdown" |
| 2 | Charged H keeps armour while held; "Can be charged to manipulate timing" | VAS | KEEP | "provides armor as long as you hold the button (this goes for all charged H normals)"; quote exact |
| 2 | Savage Rampage = four branches plus a cancel (also (c) row 11) | VFD | FIX → five follow-ups plus Cancel | page lists 22X~L Rising Slash, ~M Sweeping Slash, ~H Crushing Strike, ~U Ravaging Stomp **and 22X~6 March**, plus 22X~G Cancel |
| 2 | Drive Impact crumples on Punish Counter "or after the Super Armor absorbs a hit" | SF6Z | KEEP | "when the attack lands as a Punish Counter, or after the Super Armor absorbs a hit: … crumple stun" |
| 2 | "Perform this on an opponent backed into the corner to induce a wall splat, even if they block the attack." | SF6D | KEEP | exact |
| 2 | Zangief held >23 f → charged | SF6Z | KEEP | "Hold down the button for over 23 frames to change its properties" |
| 2 | Nightmare "Dire Vengeance" when "armor clicks" | SCN | KEEP | "Dire Vengeance \| hit 6A+B … If armor clicks." |
| 2 | Grim Stride; Night Lower / Behind / Side stances | SCN | KEEP | "Shadow Slicer ~ Grim Stride", "~ Night Behind Stance", "~ Night Side Stance" |
| 2 | Mitsurugi AA/AAA same first impact; "Jails if 2nd attack hits" | SCM | KEEP | AA 12, AAA 12, "Jails if 2nd attack hits" |
| 2 | MH GS: "Each charged slash has three different charge levels, Levels 1 to 3"; squat cue; overcharge → Level 2 | MHGS | KEEP | exact; "Overcharging a charged slash will reduce its strength to Level 2." |
| 2 | Tackle braces "without knockback", upgrades tier; hit / knock / evade loses charge | MHGS | KEEP | "brace for incoming attacks without knockback"; "Holding during a Tackle will perform a True Charged Slash"; "If the player is hit, knocked away, evades … lose all the charge" |
| 2 | MH LS: Roundslash levels up, levels decay, Helm Breaker spends one, Foresight "right before being hit" | MHLS | KEEP | "After a set duration, the Spirit Gauge will reduce by one level"; "consume one level"; quote present |
| 2 | Sekiro: "a high amount of posture damage to the attacker"; blocking fills defender's gauge; no regain while attacking | SEKP | KEEP | exact; "posture cannot be regained while attacking" |
| 2 | Perilous thrust "by drawing their right shoulder back and pointing their weapon straight forwards"; sweep = left shoulder back or spin | SEKA | KEEP | exact; "drawing their left shoulder back or spinning 180 degrees" |
| 2 | Nioh 2 High / Mid / Low quotes; dodges roll / step+roll / quick step | NIOS | KEEP | "increased damage at the cost of heavy Ki consumption", "won't bounce off guard", "fast and low Ki consuming"; "Dodge is always a roll / a quick step followed by a roll / always a quick step" |
| 2 | Odachi "breaking guard", "chain strong and quick attacks from different stances together", mid not reflected | NIOO | KEEP | exact; "Mid stance attacks do not get reflected by blocking enemies." |
| 2 | DMC Royal Revenge "no timing requirement"; Release spends the gauge | DMC | KEEP | exact; "Release all the energy stored in the Royal Gauge" |
| 2 | DMC: a Royal Block fills the gauge more | DMC | KEEP | Royal Block: "greatly increase the angry energy stored within the Royal Gauge" |
| 2 | Sekiro perilous: red kanji "Danger" | SEKA | KEEP | "A red Kanji for the word "Danger" will appear above Sekiro's head" |
| 2 | Nioh 2 Ki Pulse timed to the blue flash | https://nioh2.wiki.fextralife.com/Ki+Pulse | KEEP | "recover Ki when surrounded by blue light" |
| 2 | Elden Ring "8 ⇨ Very short hitstun \| Dagger R1" … "3 ⇨ Long hitstun \| Colossal Sword R1" | ER | KEEP | lines "8 ⇨ Very short hitstun \| Dagger R1", "1 ⇨ Short…", "2 ⇨ Medium…", "3 ⇨ Long…" |
| 2 | (c) rows 1–17 | as above | KEEP (except rows 4 and 11, FIX above) | every number in rows 1–17 is one of the rows checked above |

### 3-berserk-theory.md

| report | row or claim | URL | verdict | evidence |
|---|---|---|---|---|
| 3 | Nagoriyuki gauge values 90 / 57.6 / 115.2 / 7.2; "no low-commitment defensive options"; "near certain"; "enhanced sword normals at high Blood" | NAG | KEEP | all strings present |
| 3 | SamSho: "Your Rage Gauge will fill as you take damage"; "only once per match"; longer "if your life is low"; Lightning Blade ends it | https://snk-corp.co.jp/webmanual/samuraispirits/eng/howtoplay2.php | KEEP | all four quotes exact |
| 3 | Heat: Kazuya gains Devil Transformation moves | https://tekken.fandom.com/wiki/Heat | KEEP | "Kazuya Mishima: Grants additional Devil Transformation-exclusive moves" |
| 3 | Tekken 8 Heat: 10 s, pauses while opponent "is either hit or grounded", being hit reduces Heat, 30% chip, Heat Smash ends Heat, Heat Dash consumes all, patches 1.05.00 / 3.00.03, Bryan "without costing its deactivation" | https://tekken.fandom.com/wiki/Heat | KEEP | "All Heat Bursts function as a Power Crush"; "all remaining Heat is consumed by the Heat Dash"; "Performing a Heat Smash … will end the Heat state"; "The Heat Bar is refreshed after every round" |
| 3 | Power Crush: lows, throws, recoverable health in T8 | https://tekken.fandom.com/wiki/Power_Crush | KEEP | "low", "throw", "recoverable" in the rules text |
| 3 | Tekken Rage: T6 ~20% → 11%; T7 bonus "from 25% to only 5%"; FR lower health = higher bonus; T8 10% with combo scaling, less chip | https://tekken.fandom.com/wiki/Rage | KEEP | "decreased significantly from 25% to only 5%"; "changed to 11% in later builds"; "rescaled to 10%, but is now also affected by combo scaling" |
| 3 | Drive Impact 26 f "with a splash of paint" and audio; absorbed damage "can absolutely lead to a Knockout"; 6 f hitfreeze per projectile | https://streetfighter.fandom.com/wiki/Drive_Impact | KEEP | "startup of 26 frames … watch for the splash of paint and listen to the unique audio cues"; "an extra six frames of hitfreeze per hit" |
| 3 | infil SF6 review: "all 6 drive bars", "the next 20 or so seconds", "4 more frames of block stun", "the situation can reverse itself incredibly fast", "as important as a second health bar" | https://words.infil.net/w04-sf6review-p2.html | KEEP | all five exact |
| 3 | Focus Attack: armour vs one hit while charging only; white / yellow flashes | https://streetfighter.fandom.com/wiki/Focus_Attack | KEEP | "Super Armor … against one attack"; "active during charging, but not during the actual attack"; white, yellow |
| 3 | Revenge Gauge usable at 50%, fills from chip and provisional damage | https://streetfighter.fandom.com/wiki/Revenge_Gauge | KEEP | "50%", "chip" |
| 3 | Jamie "90% damage scaling, with each drink adding an extra 5%"; "has to complete the animation"; resets each round; SA2 15 s level 4; "run hot or cold" | https://streetfighter.fandom.com/wiki/Jamie | KEEP | all exact; "granting Jamie a 15-second Level 4 Drink buff" |
| 3 | Bloodborne Rally "Most large weapons have good rally potential to compensate for slow swing speeds" | https://bloodborne.fandom.com/wiki/Rally | KEEP | exact |
| 3 | Miyazaki "change the concept of defense to an active one"; "The amount of regain is considered as one of the personality of weapons" | https://gigazine.net/gsc_news/en/20150402-bloodborne-miyazaki-hidetaka-interview | KEEP | both exact |
| 3 | X-Factor "only be activated once per match", Level 2 / 3 | https://marvelvscapcom.fandom.com/wiki/X-Factor | KEEP | exact; "known as Level 2 and Level 3 X-Factors" |
| 3 | GBVS Overdrive: 100% gauge, once per round, +25% (not throws / SBA), 33% per hit, three hits empty it, 25 f, counter-hit recovery, SSBA ≤ 30% | https://www.dustloop.com/w/GBVS/Mechanics | KEEP | "once-per-round buff that costs 100%"; "Getting hit will drop the timer by 33%, with three hits emptying the gauge"; "slow (25f startup)"; "activation recovery leaves you in a counterhit state"; "30% or lower" |
| 3 | GBVSR Raging Chain penalty 300 F at 0.2× | https://www.dustloop.com/w/GBVSR/Mechanics | KEEP | "Raging Chain \| 300F starting from the move's startup"; "(×0.2 of normal)" |
| 3 | Berserk Musou: "halves the damage received", "If they suffer too many hits, Frenzy Mode will end", "a new moveset, a different sub-weapon"; Death Blow only in Frenzy | https://koei.fandom.com/wiki/Berserk_and_the_Band_of_the_Hawk (redirects to `BERSERK_and_the_Band_of_the_Hawk`) | KEEP | all exact on the redirect target |
| 3 | Spartan Rage "fights bare-handed", "damage taken depletes Rage instead of Health", heals by damage dealt | https://godofwar.fandom.com/wiki/Spartan_Rage | KEEP | exact; "recovers Health proportional to the damage he delivers" |
| 3 | JoJo ASB Rumble 25%, Resolve 15% "super armor during their attacks", Joseph three different abilities cap 3, Josuke armour after counter | https://jojo.fandom.com/wiki/JoJo%27s_Bizarre_Adventure:_All_Star_Battle | KEEP | "Activated at 25% health", "Activated at 15% health", "counters with three different abilities, with the level capping at 3", Josuke "unflinching ("super armor")" |
| 3 | Zato Eddie 3000 HP, "by 3 HP every frame when idle", red gauge 11 HP/f, 273 f, "a much weakened character" | https://www.dustloop.com/w/GGST/Zato-1 | KEEP | "recover at a slower rate (11 HP recovered every frame until full, 273f duration)"; other quotes exact |
| 3 | Hakumen: starts with 1 of 8, 4 Heat/f, ~312.5 f per stock, +1/f below 35%, one-fifth combat gain, "incentivised to play defensively" | https://www.dustloop.com/w/BBCF/Hakumen | KEEP | "Heat Gauge is visually divided up into 8 "Magatama" stocks"; "starts a round with 1 Magatama"; "gains 4 Heat points per frame"; "it takes 312.5 frames to gain one Magatama"; "below 35% health"; "one-fifth of the rate" |
| 3 | Zato: no summon during the red state | https://www.dustloop.com/w/GGST/Zato-1 | KEEP | "Zato cannot summon Eddie until the gauge has completely refilled or Zato uses Sun Void" (Sun Void is an exception the report leaves out) |
| 3 | Hakumen: slow build, then "commit to a burst" (quoted) | https://www.dustloop.com/w/BBCF/Hakumen | DROP (the quote) | the string isn't on the page; the page's only commit / burst sentences are about bursts in combos. Keep the paraphrase without quote marks, or drop it |
| 3 | Hakumen: a successful Drive gives a stock | same | KEEP | "Gain 1 Magatama when followup attack connects" |
| 3 | Sol DI "After DI expires, Sol will be left helpless momentarily", "at the cost of potentially losing the round" | https://www.dustloop.com/w/GGXRD-R2/Sol_Badguy | KEEP | both exact |
| 3 | Ragna lifesteal 1st–5th 100%, 6th 110%, 10th+ 150%; Barrier Block stops the heal | https://www.dustloop.com/w/BBCF/Ragna_the_Bloodedge | KEEP | "1st to 5th Soul Eater hit: 100% … 6th 110% … 10th … and beyond: 150%"; "will heal against normal block but not Barrier Block" |
| 3 | Ragna: "Overdrive raises lifesteal from 100 to 150" | same | FIX → "Overdrive cranks up the lifesteal" (no figure) | the page gives no Overdrive lifesteal number; 150% appears only for the 10th combo hit |
| 3 | Sirlin "yomi layer 4 loops back around to layer 0"; "If all my moves are equally good, this whole thing falls apart" | https://www.gwern.net/docs/www/www.sirlin.net/c86d4e92f616d6acbf8c65cd5c57484967b1d6eb.html | KEEP | both exact |
| 3 | Sirlin "probably has no real counter"; "If you know what the opponent will do, you should generally have some way of dealing with that" | https://sirlin.net/articles/balancing-multiplayer-games-part-2-viable-options | KEEP | both exact |
| 3 | Gingold project page: choice graph "no sinks" | https://cragl.cs.gmu.edu/rps/ | KEEP | "the graph of player choices: that it should contain no sinks whatsoever" |
| 3 | Murray "if you take off all of the limits, then there are certain areas where it'll break the game"; "tension and exhilaration" | https://onemoregame.ph/tekken-8-balanced-for-excitement-and-exhilaration/ | KEEP | exact (curly apostrophe "it’ll") |
| 3 | Nakayama "all that excitement and freedom from the very beginning of the fight"; Fujioka "easier to tell from a player perspective" | https://www.gameinformer.com/feature/2022/12/28/street-fighter-6-cover-story-the-dawn-of-a-new-era | KEEP | both exact |
| 3 | Wagar: comeback boosts weak or temporary, else see-saw | https://critpoints.net/2017/04/01/comeback-mechanics-2/ | KEEP | "making their effects weak or temporary so they don’t result in … the match see-sawing" |
| 3 | infil glossary: "super fast multi-hitting moves can get through too", "return to your mortal self", "greatly exaggerate the power and force of a strike" | https://glossary.infil.net/json/glossary.json | KEEP | all three in the JSON |
| 3 | MH Wilds: hitstop "too strong" in World, restored "hit stops and additional sound effects that make it feel like you are hitting the actual monsters" (Tsujimoto, Tokuda) | https://mp1st.com/news/monster-hunter-wilds-hitstops-final-game-closer-to-people-are-looking-forward | KEEP | exact |
| 3 | Lin et al.: hit stop, sound, camera drive "impact feel"; accepted at GEM 2022 | https://arxiv.org/abs/2208.06155 | KEEP | abstract; Crossref shows DOI 10.1109/GEM56474.2022.10017782, IEEE GEM 2022, pp. 1–6 |
| 3 | Tomizawa & Ishikawa, hitstop matched to gaze, GRAPP 2024 | https://scitepress.org/PublishedPapers/2024/124614 | KEEP | title and authors on the page; Crossref confirms pp. 151–158 |
| 3 | Hicks et al. CHI PLAY 2019: competence only "under specific circumstances" | Semantic Scholar API (DOI 10.1145/3311350.3347171) | KEEP | "only affects aspects such as competence under specific circumstances" |
| 3 | Pichlmair & Johansen: tuning gives "cohesion and predictability"; streamlining "allows a game to act on the intention of the player" | https://arxiv.org/abs/2011.09201 | FIX → "cohesion, predictability" | abstract: "creates cohesion, predictability"; the second quote is exact |
| 3 | Swink 2007: six parts; feedback returns quickly | https://www.gamedeveloper.com/design/game-feel-the-secret-ingredient | KEEP | "Feedback returns just as quickly"; Rules defined as a layer |

### 1a-katana-sword.md

| report | row or claim | URL | verdict | evidence |
|---|---|---|---|---|
| 1a | #1 Musashi "it is difficult to wield it freely to left and right"; "It is not difficult to wield a sword in one hand" | https://archive.org/download/book_of_five_rings/book_of_five_rings_djvu.txt | KEEP | both exact (this English translation) |
| 1a | #17 "If you try to wield the long sword quickly you will mistake the Way"; "short sword chopping"; "always stretching the elbows broadly" | same | KEEP | all exact |
| 1a | #26 Fire and Stones Cut "you cut as strongly as possible without raising the sword even a little"; Flowing Water "cut him as slowly as possible" | same | KEEP | exact |
| 1a | #27 Abdomen Timing of Two: "as you see him tense you must feint a cut … as he relaxes, follow up and hit him" | same | KEEP | exact |
| 1a | #2 Renk: explosive 250–350 ms, "cannot be done in sync with a step"; standard "600 ms and more", "10-20 cm can be all the difference", "ample warning" | https://science-and-fiction.org/swordfighting/cuts.html | KEEP | "their duration ranges between 250 and 350 ms"; other quotes exact |
| 1a | Renk: human reaction ~250 ms | same | KEEP | "given that the human reaction time is about 250 ms" |
| 1a | #19 stopped cut "a good 25-35 ms" later | same | KEEP | exact |
| 1a | #20 "an initial arc in which mainly the body starts to move and the blade moves little", 30–40°, "over in less than 50 ms"; 1000–2000 deg/s | same | KEEP | "size of 30-40 deg"; "between 1000 and 2000 deg/s" |
| 1a | #21 "if such a cut misses, it takes long to recover"; "somewhat below 100 J"; Meyer "Every cut needs to be done with a matching step" | same | KEEP | all exact |
| 1a | #3 Murase 2017: 1.031 ± 0.105 s (0.801–1.172, n = 20, 2.30 m); upswing correlates, downswing r = −0.154 n.s. | https://www.jstage.jst.go.jp/article/ijshs/15/0/15_201611/_pdf | KEEP | PDF text: "1.031", "0.105", "0.801", "1.172", "2.30"; "downswing phase time (r＝－0.154, n.s.)" |
| 1a | #4 slower strikers "shifted their weight from the left foot to the right foot and back to the left foot" | same | KEEP | present across the PDF's two-column break ("shifted their weight from the left foot to the … right foot and back to the left foot") |
| 1a | #6 Kanzaki & Ito as cited: basic strikes kensaki first, battle strikes "the right foot moves before the kensaki" | same | KEEP | `pdftotext -raw`: "Kanzaki and Ito (2005) … in basic strike movements, the kensaki moves before the right foot; whereas in battle strikes, the right foot moves before the kensaki" |
| 1a | 2.30 m "about the match maai"; n = 20 university players | same | KEEP | "This distance is nearly identical to the maai when standing face-to-face with an opponent in an actual match"; "20 male students belonging to the Chukyo University Kendo Club" |
| 1a | #23 "lifting the right foot from the ground quickly"; shinai 120 cm, 510 g | same | KEEP | exact; 120, 510 present |
| 1a | #22 Ogle & O'Donoghue: "7.6% of attacks of 0.09s-0.12s and 6.5% of attacks of 0.13s-0.15s that led to ippon"; quarter-finalists faster and more consistent | https://eurjhm.com/index.php/eurjhm/article/view/354 | KEEP | exact; "This was a greater success rate than shorter or longer attacks"; EJHM Vol. 34 (2015) |
| 1a | #24 Jeong & Fuss: "–0.040 s (stomping before striking)", "+0.502 s (stomping after striking)" | https://commons.nmu.edu/isbs/vol42/iss1/63 | KEEP | "medians of –0.040 s (stomping before striking) and +0.502 s (stomping after striking)" |
| 1a | #5 Silver: true times "The time of the hand, body, and foot"; foot-led false, foot slower | https://wiktenauer.com/api.php?action=parse&page=George_Silver&prop=wikitext&format=json | KEEP | "whatsoever is done with the foot or feet before the hand, is false, because the hand is swifter than the foot" |
| 1a | #7 GoT ~0.3 s reaction; "the first attack is slow enough to react to, but the others happen fast" | https://blog.playstation.com/?p=332432 | KEEP | "it takes about 0.3 seconds to respond to a visual stimulus"; quote exact |
| 1a | narrative §3 and table §4: "Sucker Punch measured about 0.3 s" | same | FIX → "Sucker Punch (Zimmerman) states about 0.3 s" | the blog states the figure as general knowledge ("Human reaction times are slower than you think — it takes about 0.3 seconds"); it reports no measurement |
| 1a | #8 "a handful of cuts is enough to fell the toughest enemy"; "the sword no longer felt sharp" | same | KEEP | both exact |
| 1a | #46 "can be instantly cancelled at any point"; "While one enemy attacks, another enemy can be winding up"; stances per enemy subset | same | KEEP | exact; "Each Stance is designed to be particularly effective against a subset of the dozens of enemy types" |
| 1a | #9 Bordwell: "stand still for long periods of time, sword raised, before a blow is struck"; "Rapid pacing requires the foil of extreme immobility" | https://cinema.wisc.edu/2025/02/06/the-distinct-rhythms-of-seven-samurai | KEEP | both exact |
| 1a | #10 tame "active waiting"; "a natural suspension (not a halt) of the exhalation"; "move-in to strike, in one single motion" | https://www.britishkendoassociation.com/?p=381 | KEEP | all exact |
| 1a | #11 Tanigaki: "the opponent does not die with one shot"; blade "caught in the meat once" | https://gigazine.net/gsc_news/en/20210624-rurouni-kenshin-keishi-otomo-kenji-tanigaki-interview | KEEP | "the blade will be caught in the meat once, and you can slash it with force" |
| 1a | #12 "As the number of steps increases, it becomes less real" | same | KEEP | exact |
| 1a | #12 Ohtomo: slow = drama, sudden = action, 7:3 | same | FIX → 7:3 drama : action was his usual script ratio; for this film he reversed it (action 7, the rest 3) | "'slow' in 'slow' is a drama, 'sudden' is an action, and the ratio is 7: 3 … I reversed it this time and wrote it with the intention that the action is 7 and the others are 3" |
| 1a | #13 Jigen-ryū (Wikipedia): "a second strike is not even to be considered"; "running forward … cutting diagonally down on their neck"; "Ei!" | https://en.wikipedia.org/wiki/Jigen-ry%C5%AB | KEEP | all present |
| 1a | #14 Jigen-ryū site: tonbo "with the right hand raised high against the side of the head"; "around 9 meters"; "repeatedly on the left and right sides"; "there are no uke-waza" | https://www.jigen-ryu.com/?p=2037 | KEEP | all exact |
| 1a | #15 Lecküchner "you should fence with one hand with the Messer and you should have the other one on the back"; hand to the chest; "clench" | https://wiktenauer.com/wiki/Johannes_Leck%C3%BCchner/%C5%BBabi%C5%84ski-Mitchell-Fritz_Messer_(Munich)_2013_%C2%A71-100 | KEEP | exact |
| 1a | Lecküchner Zornhau "nothing else but a simple peasant stroke" (#16) | same | KEEP | "breaks all the strokes from above but is still nothing else but a simple peasant stroke" |
| 1a | #18 / #38 / #39 hyoho: "In Kendo the Shinai stops as it hits the target"; continues "until it reaches the finishing location"; kissaki "30 to 45 degrees behind the head"; "must not look big"; "The target is small and shallow"; "Is a potential cut before arriving at the main target"; "the final positive act of cutting" | https://www.hyoho.com/Kiso11.html | KEEP | all exact |
| 1a | #25 FIK "followed by zanshin"; "If the attacker shows excessive excitement … it will be deemed invalid." | https://www.kendo-fik.org/wp-content/uploads/2026/01/FIK-Handbook-for-Kendo-Shiai-and-Shinpan-Management-20250707.pdf | KEEP | both exact in the PDF |
| 1a | #28 katsugi "your motion must be big; otherwise, it does not really work"; "when you do the katsugi motion" | https://www.kendo-guide.com/katsugi-waza-in-kendo.html | KEEP | exact |
| 1a | #29 "All the strikes should be fully executed in consecutive strikes"; san-dan; hiki | https://kendo-guide.com/kendo_techniques.html | KEEP | exact |
| 1a | #30 Sakudo "is it from their shinai top? their right hand? their eyes?"; "When you strike, do so straight from your kamae." | https://kenshi247.net/blog/2012/05/14/seme | KEEP | exact |
| 1a | #31 Tanaka "means storing energy in the lower abdomen"; "This explosiveness creates follow-through"; "beginners often finish quickly, while advanced practitioners take more time" | https://kendojidai.com/2023/11/20/tame-and-follow-through-tanaka-hiroaki/ | KEEP | all exact |
| 1a | #32 Meyer Zornhau "a serious strike from your Right Shoulder", "strongest beyond all others", Wrathful → Long Point → Changer | https://wiktenauer.com/wiki/Zornhaw | KEEP | all present |
| 1a | #33 "one should not remain too long in one guard"; "He who lies still, is dead, he who moves is still alive" | https://wiktenauer.com/wiki/Vier_Leger | KEEP | exact |
| 1a | #34 hassō quotes; right vom Tag | https://en.wikipedia.org/wiki/Hass%C5%8D-no-kamae | KEEP | exact; "vom Tag" |
| 1a | #35 jōdan "most aggressive stance of the five", "more difficult to judge the striking distance", "only one hand is used" | https://en.wikipedia.org/wiki/J%C5%8Ddan-no-kamae | KEEP | exact |
| 1a | #36 waki "only exposing the pommel", "give him no hint about your own intention" | https://en.wikipedia.org/wiki/Waki-gamae | KEEP | exact |
| 1a | #37 jōdan "you must overwhelm your opponent with only ki" | https://www.kendo-guide.com/questions-about-jodan.html | KEEP | exact |
| 1a | #40 Seitei Mae: saya-biki; horizontal strike; kirioroshi | https://akban.org/wiki/Seitei_gata_-_Mae_%E5%89%8D | KEEP | "draws the sword with sayabiki"; both quotes exact |
| 1a | #41 Kamimoto: tsuke "acting to forestall an opponent's attack" | https://kenshi247.net/?p=4169 | KEEP | exact |
| 1a | #42 kodachi: left hand on hip, grabs arm / elbow; aisen "throw your life away" | https://kampaibudokai.org/Kodachi.htm | KEEP | strings present |
| 1a | #43 sabre r = −0.83, wrist "non-significant", elbow "may be 110°", six subjects | https://emerginginvestigators.org/articles/21-230 | KEEP | "-0.83"; "angular differences in the wrist were non-significant"; "may be 110"; "six" |
| 1a | #44 "wrist work was essential for the execution of a number of historical techniques" | https://doaj.org/api/articles/a641a771b54e44078b8dde5358dc4e2c | KEEP | exact; Crossref: Marynowski 2019, RAMA 14(2s) 77–78 |
| 1a | #45 Miyazaki "comes from the clash of steel between katanas … clang, clang, clang" | https://www.gameinformer.com/interview/2018/08/21/hidetaka-miyazaki-on-sekiro-shadows-die-twice | KEEP | exact |
| 1a | #47 Kikuchiyo ōdachi "a longsword rarely used by foot soldiers"; aragoto; mie | https://blogs.ubc.ca/hansenke/category/action/page/3/ | KEEP | strings present |
| 1a | #48 Zatoichi "to unsheathe, strike and re-sheath without any wasted movement"; "reverse-draw"; "Hong Kong wire-action acrobatics" | https://www.japan-experience.com/plan-your-trip/to-know/japanese-movies/film-zatoichi | KEEP | exact |
| 1a | #49 Sugino "dynamism and reality to what had been staid and poorly stylized fight-scene choreography" | https://new.tokumeikan.org/people/sugino-yoshio-sensei/ | KEEP | exact |
| 1a | #50 Onimusha "very realistic, grounded sword action"; Katsugekiza; Yugen | https://www.pcgamer.com/games/action/onimusha-way-of-the-swords-incredible-sword-fighting-secret-sauce-explained-we-really-wanted-to-focus-on-creating-this-very-realistic-grounded-sword-action/ | KEEP | strings present |

### 1b-heavy-onearm.md

| report | row or claim | URL | verdict | evidence |
|---|---|---|---|---|
| 1b | #1 Messer stance quotes (same as 1a #15) | Lecküchner §1-100 | KEEP | exact |
| 1b | #2 "hit with your left hand into his right elbow well to his right side and strike with your Messer to his head" | Lecküchner §301-400 | KEEP | exact |
| 1b | #3 "drop your Messer"; "approach to the hands and the arms … wait cleverly the grabbing"; grab behind the elbow and push | Lecküchner §201-300 | KEEP | all exact |
| 1b | #4 "Grab the neck and learn to throw over the leg"; "strike to him with the hilt at his head" | Lecküchner §101-200 | KEEP | exact |
| 1b | narrative: right elbow into his Messer; "take the balance at the elbow" | Lecküchner §301-400 | KEEP | both on §301-400 (not §201-300) |
| 1b | #5 Zornhau peasant stroke; "great peasant stroke" | Lecküchner §1-100 | KEEP | exact |
| 1b | #6–#11 Figueyredo: "the body must always turn toward where the montante cuts"; "must be helped by the movements of the body"; "alternating talho and revez, until the people stop"; "all the thrusts which are readied over the right arm originate from the end of talhos"; "could dangerously fall … or by missing"; Fly-Swatter "while standing still and with the left arm held firmly against the body"; "the blows will be executed with more force"; "serves as an axis for the body"; "a wide road with people in front and behind"; 1651; Myers / Hick | https://www.wiktenauer.com/wiki/Diogo_Gomes_de_Figueyredo | KEEP | every string exact |
| 1b | #12 / #13 / #32 Dragon Slayer: "more like a bladed maul than an actual sword"; "squash and flatten"; "in lieu of a shield"; Miura "were merely drawn big", "invoked realistic reactions upon being swung", "swing it once or twice"; Prototype "only wields the Dragon Slayer with his right hand" | https://berserk.fandom.com/api.php?action=parse&page=Dragon_Slayer&prop=wikitext&format=json | KEEP | all exact; "Guidebook" cited |
| 1b | #23 Berserker Armour: "pain and fear, allowing them to bypass the limitations of their body"; "harm themselves through overexertion"; "a mouth capable of biting enemies" | https://berserk.fandom.com/api.php?action=parse&page=Berserker_Armor&prop=wikitext&format=json | KEEP | exact |
| 1b | #31 prosthetic "a small magnet in order to better handle the Dragon Slayer"; cannon fired "pulling the cord with his teeth" | https://berserk.fandom.com/api.php?action=parse&page=Cannon_Arm&prop=wikitext&format=json | KEEP | "The hand hides a small magnet in order to better handle the [[Dragon Slayer]]" (wiki link markup); teeth quote exact |
| 1b | #14 Föll: "much faster than the axe"; "whenever you have all the time in the world to get it up to speed" | https://www.tf.uni-kiel.de/matwis/amat/iss/kap_c/backbone/rc_4_1.html | KEEP | exact |
| 1b | #15 and narrative §5: Cross & Bower V = C/I^n, n = 0.27 (stated without a condition; the report's "doubling swing-weight costs about 17%" rests on it) | https://people.stfx.ca:443/smackenz/Courses/DirectedStudy/Articles/Cross%20and%20Bauer%202006%20Effects%20of%20swing-weight%20on%20swing%20speed%20and%20racket%20power.pdf | FIX → "n = 0.27 at high swing-weight (Io > 0.03 kg·m²); n ≈ 0.12–0.16 at low swing-weight" | "V = C/Io^n, where C is a different constant for each participant and n = 0.27 when Io > 0.03 kg × m2"; "standing, n = 0.12 + 0.02 at low Io and n = 0.27 + 0.01 at high Io; sitting, n = 0.16 + 0.05 at low Io". The 17% figure holds only above 0.03 kg·m² |
| 1b | #15 "remained approximately constant as swing mass increased" | same | KEEP | exact |
| 1b | #16 "Changes in rod MOI have a greater influence on forearm-only swing speeds"; "obey the same or very similar power laws"; cited "only 10%" for 1.6× MOI | same | KEEP | all exact |
| 1b | Cross & Bower reference: J. Sports Sci. 24(1) 2006, DOI 10.1080/02640410500127876 | Crossref | KEEP | Crossref: Cross R, Bower R, J Sports Sci 24(1) 23–30, 2006 |
| 1b | #17 Sakurai "the more damage an attack inflicts, the longer the hitstop period"; "will never exceed"; "for the exact same amount of time" | https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/ | KEEP | exact |
| 1b | #18 "the cancel takes effect at the end of the hitstop, so it always comes out during the same part of the move" | https://critpoints.net/2017/05/17/hitstophitfreezehitlaghitpausehitshit/ | KEEP | exact |
| 1b | #19 / #20 Nakamura & Okita: five patients; trunk "rotated toward the intact side … all patients swung the intact arm"; "The heavier the prosthesis was, the more symmetric the posture became"; arm swing counteracts trunk rotation | https://www.unb.ca/ibme/_assets/documents/past-docs/MEC17-papers/nakamura-postural-asymmetries.pdf | KEEP | all exact; authors Nakamura, Okita; "five" (MEC17 abstract, not indexed by Crossref) |
| 1b | #21 / #22 Norling "use your full body rotation to make a very powerful one-hand strike"; "momentarily exposes the one who performs it"; Meyer "turn your self fully to your right side … at his head" | https://hroarr.com/temp/2011-site/articles/article-spinning-around.php | KEEP | exact |
| 1b | #24 One-Armed Swordsman "a new, one-armed style of swordplay", "a broken sword", "a half-burnt martial arts manual" | https://en.wikipedia.org/wiki/One-Armed_Swordsman | KEEP | exact |
| 1b | #25 Lau Kar-leung "designed a variety of signature moves … highlighting the tenacity of the character" | https://www.hkmemory.hk/en/collections-weaponry-spirits-broken_sabre.html | KEEP | exact |
| 1b | #26 Shimada "is never treated as if it is weightless or easy to wield"; "his entire life until he was able to properly wield it" | https://www.thepopverse.com/comics-manga-berserk-guts-sword-dragon-slayer-kentaro-miura-proud | KEEP | exact |
| 1b | #27 Hamaguchi "would weaken the sense of realism"; "around with one hand" | https://www.thepopverse.com/gaming-final-fantasy-vii-7-remake-cloud-buster-sword-interview-naoki-hamaguichi | KEEP | exact |
| 1b | #28 WKU "more frames create slower, heavier movements"; "Prepares the audience for a major action"; "Nothing stops all at once" | https://people.wku.edu/joon.sung/edu/anim/3d/theory/principles.html | KEEP | exact |
| 1b | #29 タメツメ 「原画寄りに中割を詰めて、アニメーションに動きに緩急やメリハリをつける技法」 | https://pedia.3rd-in.co.jp/wiki/%E5%8B%95%E7%94%BB%20%28%E3%82%A2%E3%83%8B%E3%83%A1%E5%88%B6%E4%BD%9C%29 | KEEP | exact |
| 1b | #30 MH Wilds "a little bit lighter", "everybody wanted to have a harder hit stop", "the feeling of the weapons hitting the monster" | https://mp1st.com/news/monster-hunter-wilds-hitstops-final-game-closer-to-people-are-looking-forward | KEEP | exact |
| 1b | #33 beard "pull a weapon or shield out of the grasp of an enemy" | https://en.wikipedia.org/wiki/Bearded_axe | KEEP | exact |
| 1b | #34 Hurstwic "an aggressive, direct fighting approach using simple moves"; "down to his shoulders" | https://hurstwic.com/history/articles/manufacturing/text/the_shape_of_viking_combat.htm | KEEP | exact |
| 1b | #35 Jack Chen quotes | https://www.chineselongsword.com/single-post/2017/07/06/practicality-of-sticking-your-hand-out-in-sword-fights | KEEP | both exact |
| 1b | #36 Zweihänder 2–4 kg, ~2 kg at 1.4 m; "across the shoulder like a pike or halberd"; "force polearms out of the way" | https://en.wikipedia.org/wiki/Zweih%C3%A4nder | KEEP | "Mass 2 to 4 kg"; "at least 1.4 m … and around 2 kg"; quotes exact |
| 1b | #37 ōdachi "on downward cuts", "only a few powerful men could use it effectively", 2.2–14.5 kg | https://en.wikipedia.org/wiki/%C5%8Cdachi | KEEP | all present |
| 1b | #38 half-sword "the central part of the sword blade", "more forceful thrusts" | https://en.wikipedia.org/wiki/Half-sword | KEEP | exact |
| 1b | #39 Messer 45–90 cm, Nagel, "suitable for a second hand-hold" | https://en.wikipedia.org/wiki/Messer_(sword) | KEEP | "ranged from about 45 cm (18 in) to 90 cm (35 in)" |
| 1b | #40 falchion "not cleaving or chopping weapons similar to the machete, but quick slashing weapons" | https://en.wikipedia.org/wiki/Falchion | KEEP | exact |
| 1b | #41 smear frame "used to simulate motion blur" | https://en.wikipedia.org/w/api.php?action=parse&page=Smear_frame&prop=wikitext&format=json | KEEP | "a frame used to simulate [[motion blur]]" (wiki link markup) |
| 1b | #42 Miyazaki prosthetic "multi-use feature", "a variety of moves that you can use in combat" | https://blog.playstation.com/2018/07/13/interview-miyazaki-on-the-limbs-and-lore-of-sekiro-shadows-die-twice/ | KEEP | exact |
| 1b | #43 Götz "continued his military activities"; "a shield or reins to a quill" | https://en.wikipedia.org/wiki/G%C3%B6tz_von_Berlichingen | KEEP | exact |
| 1b | #44 Tange Sazen "losing his right eye and right arm"; "an empty right sleeve" | https://en.wikipedia.org/wiki/Tange_Sazen | KEEP | exact |

### Paper references (Crossref unless noted)

| report | reference | URL | verdict | evidence |
|---|---|---|---|---|
| 3 | Pichlmair & Johansen 2022, IEEE ToG 14(2) 138–152 | https://doi.org/10.1109/TG.2021.3072241 | KEEP | Crossref: same title, authors, year, vol / issue / pages |
| 3 | Hicks, Gerling, Dickinson, Vanden Abeele 2019, CHI PLAY '19, 185–197 | https://doi.org/10.1145/3311350.3347171 | KEEP | Crossref match |
| 3 | Hicks, Dickinson, Holopainen, Gerling 2018, DiGRA | https://doi.org/10.26503/dl.v2018i1.936 | KEEP | Crossref: "Good Game Feel: An Empirically Grounded Framework for Juicy Design", DiGRA DL, 2018 |
| 3 | Gingold 2006, Sandbox '06, 155–158 | https://doi.org/10.1145/1183316.1183339 | KEEP | Crossref match |
| 3 | Tomizawa & Ishikawa 2024, GRAPP, 151–158 | https://doi.org/10.5220/0012461400003660 | KEEP | Crossref match |
| 3 | Lin, Duan, Wen, Cai 2022, arXiv 2208.06155 / GEM 2022 | https://arxiv.org/abs/2208.06155 | KEEP | arXiv page; Crossref GEM 2022 record (DOI 10.1109/GEM56474.2022.10017782) |
| 1a | Murase et al. 2017, IJSHS 15 | https://www.jstage.jst.go.jp/article/ijshs/15/0/15_201611/_pdf | KEEP | Crossref 10.5432/ijshs.201611: Murase, Horiuchi, Sumi, Horiyama, Sakurai, Int. J. Sport Health Sci. 15, 36–45, 2017 |
| 1a | Murase et al. 2020, ISBS 38 | https://commons.nmu.edu/isbs/vol38/iss1/135 | KEEP | the page shows Murase, "eighth dan", 2020 |
| 1a | Ogle & O'Donoghue 2015, EJHM 34 | https://eurjhm.com/index.php/eurjhm/article/view/354 | KEEP | "Authors James Ogle Peter O’Donoghue … Vol. 34 (2015)" |
| 1a | Jeong & Fuss 2024, ISBS 42 | https://commons.nmu.edu/isbs/vol42/iss1/63 | KEEP | page shows the authors and the title |
| 1a | Greene et al. 2023, J. Emerging Investigators | https://emerginginvestigators.org/articles/21-230 | KEEP | the article page |
| 1a | Marynowski 2019, RAMA | DOAJ / Crossref 10.18002/rama.v14i2s.5961 | KEEP | RAMA 14(2s) 77–78, 2019 |
| 1b | Cross & Bower 2006, J. Sports Sci. 24(1) | https://doi.org/10.1080/02640410500127876 | KEEP | Crossref match |
| 1b | Nakamura & Okita, MEC17 | the UNB PDF | KEEP | PDF shows the title and the authors; no DOI (conference abstract) |
| 3 | Swink, *Game Feel*, ISBN 978-0-12-374328-2 | OpenLibrary (not re-fetched) | not reached | the report says it didn't read the book |

## Not reached

- Report 3: Swink's book record on OpenLibrary (the report itself says it didn't read the book).
- Report 1a: the Murase 2020 ISBS paper's content (only its metadata); UBC's "mie on several occasions" and Onimusha's
  "animation director Hiroshi Yugen" (keyword-level only: "mie" and "Yugen" are present).
- Report 1b:
  - Norling linking the montante to Meyer's halberd spin (the Meyer quote is confirmed, the halberd link isn't);
  - Hurstwic's "axe-horn jab after a sidestep" (only the two quotes);
  - the Lecküchner §401-500 page (listed in the sources, no claim cites it).
- All reports: the "[60 Hz: …]" frame conversions and the researchers' own arithmetic (17% speed loss, 1.4× energy).
  These are labelled as theirs, so they weren't checked as source claims. The 17% one depends on the Cross & Bower
  condition (FIX above).

## Totals

- **KEEP: 208 table rows**, paper references included. By report:
  - report 2: 70 (40 frame-data rows + 30 narrative / findings);
  - report 3: 43;
  - report 1a: 56;
  - report 1b: 39.

  A row that bundles several quotes from one page counts once. Swink's book is "not reached" and isn't counted.
- **FIX: 7**:
  - 1b: Cross & Bower's n = 0.27 holds only at high swing-weight (Io > 0.03 kg·m²; 0.12–0.16 below), and the report's
    17% arithmetic inherits that condition;
  - 2: Vaseraga's Savage Rampage has five follow-ups (March 22X~6 is missing), not four;
  - 2: Soul Forge's "third hit breaks through" isn't stated (the page says 2 hits of armour, 50% damage);
  - 3: Ragna's "100 → 150" Overdrive lifesteal has no figure on the page ("cranks up the lifesteal");
  - 3: Pichlmair's "cohesion and predictability" reads "cohesion, predictability";
  - 1a: Ohtomo's 7:3 is his usual drama : action ratio, which he reversed for this film;
  - 1a: Sucker Punch didn't "measure" the 0.3 s; the blog states it.
- **DROP: 1**: Hakumen's quoted "commit to a burst" (no such string on the page; the 8-stock cap itself is confirmed).
- **CACHED: 0.**

Every number in 2-game-movesets.md's frame-data table (40 rows) matched the live page exactly, move name included.
