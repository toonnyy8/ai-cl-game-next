# Kenpachi rework research, topic 3: berserker, rage and armour mechanics, and fighting-game design theory

> Verified 2026-11-02 (`verify.md`: KEEP 208, FIX 7, DROP 1; the rows it did not reach are listed there). The FIX / DROP items are applied in this copy.

Scope: mechanics from other games and design theory, ranked against the user's two pain points: 「形態之間差異不夠」 (the forms don't differ enough) and 「操作或節奏不順」 (the controls or the cadence feel off). Not covered here: Rebirth of Souls, Brave Souls, Soul Resonance and the Bleach canon (see motion-refs.md §2), and per-move frame tables (another researcher has those).

Source notes:
- Every claim cites the page that was actually fetched. Fandom pages were read through the MediaWiki API (`api.php?action=parse&page=…&prop=wikitext`), so they are cited as "(read via MediaWiki API)".
- SuperCombo wiki pages were blocked (HTTP 403 and Cloudflare), so nothing here comes from SuperCombo.
- Wiki numbers are as the page read on 2026-11-02. Patches change them.

Grades: A is a peer-reviewed paper, a developer talk or a developer interview. B is a published book or official material. C is a fan wiki, a forum or a blog. Sirlin's *Playing to Win* chapter and his articles are graded B: published essays by a designer, not talks.

---

## (a) Mechanics catalogue

| Mechanic | Game | Rule (as the source states it) | Counterplay | Anti-oppression limit | Cadence effect | URL |
|---|---|---|---|---|---|---|
| Blood gauge / Blood Rage (self-damage mode) | Guilty Gear Strive, Nagoriyuki | The gauge has 3 bars of 100. Each special adds 90; HS normals drain 57.6, f.SSS 115.2, other sword normals 7.2; it also drains over time. Filling bars strengthens S/HS normals but raises damage taken (+11% at one bar, +25% at two). Full gauge = Blood Rage: strongest normals, **no specials**, "drains up to 75% of his HP" (cannot KO, can leave 1 HP). | Play around his committal movement; he has "no low-commitment defensive options". | The cost is the mode: losing specials plus taking more damage. Entering Blood Rage at the wrong time makes defeat "near certain". | One gauge decides which half of the kit is good: "enhanced sword normals at high Blood and specials at low Blood". The rhythm alternates between building and spending. | https://www.dustloop.com/w/GGST/Nagoriyuki |
| Rage gauge, Rage Explosion, Lightning Blade | Samurai Shodown (2019) | "Your Rage Gauge will fill as you take damage." Full = Max Rage: attack up, some specials enhanced, Weapon Flipping available. Rage Explosion costs the gauge and is "only once per match"; it "will also last for a longer amount of time if your life is low". Lightning Blade's damage depends on the gauge left. | The opponent waits out the timer. Weapon Flipping and Lightning Blade each end the mode, so baiting them out ends it. | Once per match. "Regardless of whether or not Lightning Blade lands, performing it will cause Rage Explosion to come to an end." | The cash-out move ends the mode, so the player chooses between holding the buff and spending it on one big strike. | https://snk-corp.co.jp/webmanual/samuraispirits/eng/howtoplay2.php |
| Heat | Tekken 8 | Heat Burst (a Power Crush) or a character's Heat Engager starts it for 10 s. The timer does not deplete while the opponent "is either hit or grounded"; being hit reduces your Heat. During Heat, attacks without chip deal 30% chip. Heat Smash spends the rest of the gauge and ends Heat; Heat Dash consumes all remaining Heat. Per-character boosts, e.g. Kazuya gains Devil Transformation moves, and Bryan can use Snake Eyes moves "without costing its deactivation". | Since patch 1.05.00 a Heat Burst can be stepped and loses to reversals, parries and other Power Crushes. An Engager that trades does not start Heat. | Once per round; the gauge refreshes each round. Heat regeneration was removed in patch 3.00.03. | Offence extends the mode (the timer pauses on hit) and being hit shortens it. The mode is a per-character move set, not only a multiplier. | https://tekken.fandom.com/wiki/Heat (read via MediaWiki API) |
| Power Crush (armour property) | Tekken 7 / 8 | Absorbs mid or high attacks while the attack continues. In T8, absorbed damage becomes recoverable health. | Lows cancel it. A throw during its absorbing frames is inescapable (in T8 on any frame). Usually punishable on recovery. An absorbed hit delays the user's own attack, so jab then low breaks it. | Rage Arts, Heat Smashes and some charged moves bypass it. | Gives a committal answer to pressure that has known holes, so it never becomes a safe default. | https://tekken.fandom.com/wiki/Power_Crush (read via MediaWiki API) |
| Rage (low-HP buff) | Tekken 6 → 8 | T6: at about 20% HP, later 11%, damage up. T7 added Rage Art, which removes Rage; the damage bonus fell "from 25% to only 5%". Fated Retribution: lower health gives a higher bonus. T8: 10%, but scaled by combo scaling; Rage also reduces chip taken. | Bait out the Rage Art, which removes Rage. | Over successive games the developers shrank the passive bonus and moved the power into a one-shot spend. | It creates a late-round "last stand" beat without dragging the round out. | https://tekken.fandom.com/wiki/Rage (read via MediaWiki API) |
| Drive Impact (2-hit armour) | Street Fighter 6 | HP+HK: 2 hits of armour, 26 f startup "with a splash of paint" and audio cues. On block, a stagger; in the corner, a wall splat; on Punish Counter, a crumple; against a Burnout opponent in the corner, a stun. | Your own Drive Impact, which always becomes a Punish Counter. A throw. Armour breaks (Super Arts, Drive Reversal). A quick chain (e.g. cr.LK, cr.LP into a special) breaks 2 hits. Drive Parry. | Absorbed hits become provisional damage that "can absolutely lead to a Knockout". Projectiles add 6 f of hitfreeze per absorbed hit. Costs Drive gauge. | A loud, readable "I'm trading" button. The tell (paint, sound, 26 f) makes it a read rather than a reaction test. | https://streetfighter.fandom.com/wiki/Drive_Impact (read via MediaWiki API) |
| Drive gauge / Burnout | Street Fighter 6 | Six blocks; players start with "all 6 drive bars". Running dry gives Burnout for "the next 20 or so seconds": no Drive, chip from specials, "4 more frames of block stun". | Pressure a low-gauge opponent, but the reviewer warns "the situation can reverse itself incredibly fast". | The reviewer calls the gauge "as important as a second health bar". | Spending is tempting and overspending is punished: a resource that is offence and defence at once. | https://words.infil.net/w04-sf6review-p2.html |
| Focus Attack (charged armour) | Street Fighter IV | Armour against **one** hit while charging, not during the attack itself. Level 1 crumples only on counter; Level 2 (character flashes white) crumples; Level 3 (flashes yellow, auto-releases) is unblockable and crumples. Absorbed damage is provisional and fills the Revenge Gauge. | Multi-hit moves, and hitting it after release. | The armour is only on the charge. | The charge levels are telegraphed by colour flashes, so the hold length is readable to both players. | https://streetfighter.fandom.com/wiki/Focus_Attack (read via MediaWiki API) |
| Revenge Gauge / Ultra | Street Fighter IV series | Fills when hit, on chip, and on provisional (armoured) damage. Usable at 50% or more; fuller means more Ultra damage. | Don't feed it; spacing. | Needs 50%. | Turns the damage taken by a tank into stored offence. | https://streetfighter.fandom.com/wiki/Revenge_Gauge (read via MediaWiki API) |
| Drink levels (power-up level) | Street Fighter 6, Jamie | Up to 4 drink levels. Starts at "90% damage scaling, with each drink adding an extra 5%". Tools are locked behind drinks (dive kick at 1). Drinking is a committal animation. At level 4 the stance changes, his hair comes undone, and a level-4-only target combo opens. SA2 gives a 15-second level 4. | Hit him before he drinks: "has to complete the animation". | Levels reset each round ("starts with the barebones of his kit at the start of each round"). | Strictly slow then fast within a round. The page says he can "run hot or cold". | https://streetfighter.fandom.com/wiki/Jamie (read via MediaWiki API) |
| Regain / Rally (damage-for-damage trade) | Bloodborne | After being hit, hitting back regains health for a short time. "Most large weapons have good rally potential to compensate for slow swing speeds." | Keep hitting, or back off until the window closes. | A short window; per-weapon rates. | Rewards trading straight back after taking a hit. | https://bloodborne.fandom.com/wiki/Rally (read via MediaWiki API) |
| Regain: design intent | Bloodborne (Miyazaki interview) | Miyazaki wanted to "change the concept of defense to an active one". "The amount of regain is considered as one of the personality of weapons." | n/a | n/a | The trade rate is part of a weapon's identity. | https://gigazine.net/gsc_news/en/20150402-bloodborne-miyazaki-hidetaka-interview |
| X-Factor | Marvel vs. Capcom 3 / UMvC3 | All four attack buttons: a speed and damage boost; duration varies by character; stronger with one or both partners KO'd (Level 2 / 3). | Run out the timer. | "only be activated once per match". | One-time escalation that scales with how far behind you are. | https://marvelvscapcom.fandom.com/wiki/X-Factor (read via MediaWiki API) |
| Overdrive (hit-limited mode) | Granblue Fantasy Versus (2020) | Costs 100% gauge, once per round. +25% damage (not throws or Skybound Arts); normals chip; immune to chip. The meter becomes a timer; **each hit taken cuts 33%, so three hits empty it**. 25 f startup; recovery is a counter-hit state. Super Skybound Arts need under 30% health. | Hit them three times; punish the 25 f activation. | Hits taken end it, plus a timer. | A berserk mode with a "hit budget". | https://www.dustloop.com/w/GBVS/Mechanics |
| Raging Chain penalty | Granblue Fantasy Versus Rising | After a Raging Chain, a "Skybound Gauge Recovery Penalty" of 300 F, gauge filling at 0.2×. | n/a | A cooldown on the follow-up. | A cooldown after the burst stops back-to-back bursts. | https://www.dustloop.com/w/GBVSR/Mechanics |
| Frenzy Mode + Transformation | Berserk and the Band of the Hawk (Koei Tecmo) | Frenzy fills by attacking; it "halves the damage received" and raises attack. "If they suffer too many hits, Frenzy Mode will end." Death Blow only in Frenzy. With a full Death Blow gauge, Guts can transform (Berserker Armor) into "a new moveset, a different sub-weapon", with attack up for a limited time. | Hit them enough times. | A hit limit and a duration tied to level. | Three tiers (base, Frenzy, transformed), each with a new move set at the top. | https://koei.fandom.com/wiki/Berserk_and_the_Band_of_the_Hawk (read via MediaWiki API) |
| Spartan Rage | God of War (2018) | Filled by dealing and taking damage; must be full to start. While enraged Kratos "fights bare-handed" with a different moveset. The meter drains over time and when damage is dealt or taken; "damage taken depletes Rage instead of Health". He heals in proportion to damage dealt. Leaving early costs more Rage. | (single player) | Drains over time and from hits taken. | The mode gauge doubles as an armour pool: hits drain the mode, not life. | https://godofwar.fandom.com/wiki/Spartan_Rage (read via MediaWiki API) |
| Rumble / Resolve modes (low-HP armour) | JoJo's Bizarre Adventure: All Star Battle | Rumble at 25% health: attack up, Guard and Heart Heat gauges fill faster. Resolve at 15% (5 characters only): adds "super armor during their attacks". Young Joseph levels up permanently by countering with three *different* abilities (cap 3). Josuke gains a buff plus super armour after a successful counter. | Finish before the threshold; throws. | Thresholds, and Resolve is limited to a few characters. | Low HP turns into "attacks don't flinch", a last-stand state. Joseph's levels reward *variety*, not repetition. | https://jojo.fandom.com/wiki/JoJo%27s_Bizarre_Adventure:_All_Star_Battle (read via MediaWiki API) |
| Eddie gauge (a mode with its own HP) | Guilty Gear Strive, Zato-1 | Eddie's gauge is 3000 HP; it drains "by 3 HP every frame when idle" and per attack. If Eddie or Zato is hit, or the gauge empties, it turns red and refills at 11 HP/frame over a 273 f duration with no summon. Without Eddie he is "a much weakened character". | Hit Eddie or Zato during his offence. | The broken-state lockout. | Two clearly different characters (puppet out or in), separated by a long, readable lockout. | https://www.dustloop.com/w/GGST/Zato-1 |
| Magatama (pace set by regeneration) | BlazBlue Centralfiction, Hakumen | 8 stocks; he starts with 1. Passive gain of 4 Heat/frame (about 312.5 f per stock); below 35% health +1/frame; combat gain at one-fifth. Specials and big tools cost stocks. A successful Drive (counter) gives a stock. Players are "incentivised to play defensively". | Pressure him before he stocks up. | Slow regeneration. | Slow, deliberate build, then a committed burst (paraphrase). This is the closest slow-to-fast template. | https://www.dustloop.com/w/BBCF/Hakumen |
| Dragon Install (berserk with a crash) | Guilty Gear Xrd Rev 2, Sol | 50 meter: faster Sol and normals, specials with properties "only … while in DI", model and music change. "After DI expires, Sol will be left helpless momentarily." | Survive it, then punish the crash. | The crash at the end; the page says it comes "at the cost of potentially losing the round". | Burst, then a vulnerable comedown. | https://www.dustloop.com/w/GGXRD-R2/Sol_Badguy |
| Soul Eater (lifesteal that escalates within a combo) | BlazBlue Centralfiction, Ragna | Certain attacks heal Ragna. Lifesteal per hit rises within a combo: 1st–5th 100%, 6th 110%, 10th and later 150%. Overdrive "cranks up the lifesteal" (the page gives no figure). | Barrier Block stops the chip and the heal. | n/a | The longer the combo, the more it pays: escalation inside one string. | https://www.dustloop.com/w/BBCF/Ragna_the_Bloodedge |

---

## (b) Design-theory narrative

**1. Forms differ by *what the player can do*, not by multipliers (pain point 1, top rank).**
The mode-switch characters that read as different characters all change the available verbs:
- **Nagoriyuki:** one gauge decides whether his specials or his sword normals are the right tool, and at max he loses specials outright (https://www.dustloop.com/w/GGST/Nagoriyuki).
- **Jamie:** his tools are locked behind drinks, and level 4 changes his stance (https://streetfighter.fandom.com/wiki/Jamie).
- **Tekken 8 Heat:** gives Kazuya Devil Transformation moves and gives stance characters free access to their stance moves (https://tekken.fandom.com/wiki/Heat).
- **Spartan Rage:** swaps the axe for a bare-handed moveset (https://godofwar.fandom.com/wiki/Spartan_Rage).
- **Berserk Musou:** the transformation brings "a new moveset, a different sub-weapon" (https://koei.fandom.com/wiki/Berserk_and_the_Band_of_the_Hawk).
- **Zato:** without Eddie, the page calls him "a much weakened character" (https://www.dustloop.com/w/GGST/Zato-1).

Pure stat buffs are the ones designers kept cutting back. Tekken's Rage bonus went from 25% to 5% and then to 10% scaled by combo scaling (https://tekken.fandom.com/wiki/Rage).

Rule for Kenpachi: each form needs at least one verb the others lack, and the form that gains power should lose something. Nagoriyuki loses specials; Jamie at level 0 has 90% damage and a locked kit.

**2. Every strong option needs a known answer, and the answer differs per form (yomi).**
- Sirlin's layer model needs counters only up to layer 3, because "yomi layer 4 loops back around to layer 0". It also requires the options to be unequal: "If all my moves are equally good, this whole thing falls apart" (gwern mirror of *Playing to Win* ch. 7, https://www.gwern.net/docs/www/www.sirlin.net/c86d4e92f616d6acbf8c65cd5c57484967b1d6eb.html).
- In "Balancing Multiplayer Games, Part 2" he says a dominant move "probably has no real counter", and "If you know what the opponent will do, you should generally have some way of dealing with that" (https://sirlin.net/articles/balancing-multiplayer-games-part-2-viable-options).
- Gingold's ACM Sandbox 2006 paper frames fighting games as real-time rock-paper-scissors. The project page adds that the graph of player choices should contain no sinks (https://cragl.cs.gmu.edu/rps/).

The armour mechanics above show how this is done:
- **Drive Impact:** beaten by your own DI, throws, armour breaks and fast chains; absorbed damage can still KO (https://streetfighter.fandom.com/wiki/Drive_Impact).
- **Power Crush:** beaten by lows, inescapable throws and punishment on recovery (https://tekken.fandom.com/wiki/Power_Crush).
- The infil glossary adds that with few armour hits, "super fast multi-hitting moves can get through too" (https://glossary.infil.net/?t=Armor).

So giving each Kenpachi form a *different* armour profile also gives each form a different counter-game, which separates the forms for both players:
- an armour-hit count;
- which hit levels the armour absorbs;
- whether absorbed damage is provisional.

**3. A berserk mode stays fair through a hit budget, a one-shot cash-out, and a crash.**
The berserk modes end in one of three ways:
- **Hit budget:**
  - GBVS Overdrive loses 33% per hit taken (https://www.dustloop.com/w/GBVS/Mechanics).
  - Berserk Musou's Frenzy ends after "too many hits" (https://koei.fandom.com/wiki/Berserk_and_the_Band_of_the_Hawk).
  - Spartan Rage takes damage from the Rage gauge instead of health (https://godofwar.fandom.com/wiki/Spartan_Rage).
- **Cash-out ends the mode:**
  - In Samurai Shodown, Lightning Blade ends Rage Explosion whether it lands or not (https://snk-corp.co.jp/webmanual/samuraispirits/eng/howtoplay2.php).
  - In Tekken 8, Heat Smash ends Heat (https://tekken.fandom.com/wiki/Heat).
- **Crash afterwards:**
  - Sol is "left helpless momentarily" after Dragon Install (https://www.dustloop.com/w/GGXRD-R2/Sol_Badguy).
  - Zato's 273 f broken state (https://www.dustloop.com/w/GGST/Zato-1).
  - GBVSR's 300 F gauge penalty after Raging Chain (https://www.dustloop.com/w/GBVSR/Mechanics).

Tekken's producer Michael Murray explains why limits stay: "if you take off all of the limits, then there are certain areas where it'll break the game", and keeping some preserves "tension and exhilaration" (One More Game, 2023-03-29, https://onemoregame.ph/tekken-8-balanced-for-excitement-and-exhilaration/).

These map directly onto NOMIHOSE (a hit budget) and the Bankai's self-destroying arm (a crash or lockout).

**4. A slow-to-fast cadence comes from a resource that the player's own action builds (pain point 2).**
- **Passive pacing:** Hakumen starts with 1 of 8 stocks, gains slowly and passively, and gains more when low on health. The result is a defensive, deliberate opening and then a committed burst (paraphrase; the earlier quote marks were removed by the verifier) (https://www.dustloop.com/w/BBCF/Hakumen).
- **Active levelling:** Jamie levels up through committal drinks (https://streetfighter.fandom.com/wiki/Jamie).
- **Reward for varied play:** Young Joseph levels up by countering with three different abilities (https://jojo.fandom.com/wiki/JoJo%27s_Bizarre_Adventure:_All_Star_Battle).
- **Escalation within a combo:** Ragna's lifesteal grows within a combo, 150% from the 10th hit (https://www.dustloop.com/w/BBCF/Ragna_the_Bloodedge).
- **Timer that rewards offence:** Tekken's Heat timer pauses while the opponent is hit or grounded (https://tekken.fandom.com/wiki/Heat).

SF6 went the other way on purpose. Takayuki Nakayama said they wanted "all that excitement and freedom from the very beginning of the fight", unlike SFV's V-Trigger (Game Informer, https://www.gameinformer.com/feature/2022/12/28/street-fighter-6-cover-story-the-dawn-of-a-new-era). A fighter that *does* build from slow to fast stands out against that default, but its slow phase must still give the player real choices. Jamie's level 0 still has a full set of normals, Drive and supers.

The "clunky" risk is a slow phase with nothing to decide. Celia Wagar's comeback-mechanics essay warns that negative-feedback boosts should stay weak or temporary, or the match see-saws (https://critpoints.net/2017/04/01/comeback-mechanics-2/).

**5. Readability: tells, colour and impact frames.**
- **SF6:** the art director, Takayuki Fujioka, said Drive actions use a colour language so that it is "easier to tell from a player perspective" (https://www.gameinformer.com/feature/2022/12/28/street-fighter-6-cover-story-the-dawn-of-a-new-era). Drive Impact's 26 f startup comes with paint and audio cues, which makes it a read (https://streetfighter.fandom.com/wiki/Drive_Impact).
- **SF4:** Focus Attack's charge levels flash white and then yellow (https://streetfighter.fandom.com/wiki/Focus_Attack).
- **Hitstop:** it sells weight; the infil glossary says more hitstop frames "greatly exaggerate the power and force of a strike" (https://glossary.infil.net/?t=Hitstop). Monster Hunter Wilds' developers lightened it after players found World's "too strong", then restored "hit stops and additional sound effects that make it feel like you are hitting the actual monsters" (Tsujimoto and Tokuda, mp1st, 2025-02-11, https://mp1st.com/news/monster-hunter-wilds-hitstops-final-game-closer-to-people-are-looking-forward).
- **Research:**
  - Lin et al. (arXiv 2022) found that hit stop, sound coherence and camera control most influence "impact feel" (https://arxiv.org/abs/2208.06155).
  - Tomizawa and Ishikawa (GRAPP 2024) found that matching hitstop length to gaze duration improved game feel (https://scitepress.org/PublishedPapers/2024/124614).
  - **Caution:** Hicks et al. (CHI PLAY 2019) found that visual embellishments raise visual appeal but affect competence only "under specific circumstances" (abstract via Semantic Scholar API, DOI 10.1145/3311350.3347171). Effects help readability but don't fix cadence.

**6. Game feel vocabulary for the cadence problem.**
- **Pichlmair and Johansen (IEEE Transactions on Games, 2022)** split polish into three:
  - tuning, which gives "cohesion, predictability";
  - juicing, which gives empowerment and clarity;
  - streamlining, which "allows a game to act on the intention of the player".

  A cadence that "feels off" usually has a streamlining problem rather than a juicing one: buffering, and cancel windows that match intent (https://arxiv.org/abs/2011.09201; DOI 10.1109/TG.2021.3072241).
- **Swink (2007)** lists six parts of game feel: input, response, context, polish, metaphor, rules. In games that feel right, feedback returns quickly (https://www.gamedeveloper.com/design/game-feel-the-secret-ingredient).

---

## (c) Findings table (top-ranked first)

Rank logic: findings that give a concrete rule for making forms *play* differently come first, then rules for a slow-to-fast cadence that avoids clunkiness, then readability and feel.

| # | Claim | Source URL | Grade | Form(s) it informs | Module hook it suggests |
|---|---|---|---|---|---|
| 1 | One gauge decides which half of the kit is optimal (specials at low Blood, sword normals at high). At max, specials are lost and damage taken rises (+11% / +25% per bar); Blood Rage drains up to 75% HP. | https://www.dustloop.com/w/GGST/Nagoriyuki | C | NOMIHOSE, Bankai | mode distinction (the berserk form loses SP / NS specials and gains bigger NA), armour (take more damage), SA |
| 2 | A power-up level that starts the round weak (90% damage, tools locked), +5% per level, unlocks moves per level and changes stance at max. Levelling is a committal animation that can be hit. Resets each round. | https://streetfighter.fandom.com/wiki/Jamie | C | base → all (NOME cups) | cadence (cups unlock NS segments / AS enders), tell ≥ 14 f (cup animation), stance change at max cups |
| 3 | The mode is a separate move set, not a multiplier: Heat gives Kazuya Devil moves and lets stance characters use stance moves without leaving the stance. | https://tekken.fandom.com/wiki/Heat | C | KATATE, RYOTE, NOMIHOSE, Bankai | mode distinction (each form owns moves no other form has) |
| 4 | Without the puppet, the character is "a much weakened character". Losing it (hit, or gauge emptied) gives a 273 f broken state with no re-summon. | https://www.dustloop.com/w/GGST/Zato-1 | C | Bankai (self-destroying right arm), KATAUDE | mode distinction; an arm "HP" gauge drained by use and by being hit, a broken-arm lockout → KATAUDE |
| 5 | The berserk mode gauge absorbs damage instead of health, the mode is a different (bare-handed) moveset, and the gauge drains over time and on hits. | https://godofwar.fandom.com/wiki/Spartan_Rage | C | NOMIHOSE, Bankai | armour (hits drain the mode, not life), mode distinction (fist-only set) |
| 6 | The berserk mode has a hit budget: GBVS Overdrive loses 33% per hit taken (3 hits end it), 25 f startup, recovery counter-hit. | https://www.dustloop.com/w/GBVS/Mechanics | C | NOMIHOSE | armour (`:armor-hits` as a form-wide budget), cadence (tell on entering) |
| 7 | Frenzy halves damage, ends after "too many hits"; at the top a transformation brings a new moveset and sub-weapon for a limited time. | https://koei.fandom.com/wiki/Berserk_and_the_Band_of_the_Hawk | C | NOMIHOSE → Bankai | mode distinction (tiered forms), armour |
| 8 | The cash-out ends the mode whether it hits or not (Lightning Blade); the mode lasts longer if activated at low life; once per match. | https://snk-corp.co.jp/webmanual/samuraispirits/eng/howtoplay2.php | B | NOMIHOSE, Bankai | SA / Kikon as the cash-out that ends the form; cadence |
| 9 | Pace set by a regenerating resource: starts at 1 of 8 stocks, slow passive gain, faster below 35% HP, combat gain at 1/5, so the opening is defensive and the end is a committed burst. | https://www.dustloop.com/w/BBCF/Hakumen | C | RYOTE, base | cadence (slow to fast), charge |
| 10 | Each strong option needs a counter only up to layer 3; options must be unequal ("If all my moves are equally good, this whole thing falls apart"). | https://www.gwern.net/docs/www/www.sirlin.net/c86d4e92f616d6acbf8c65cd5c57484967b1d6eb.html | B | all | mode distinction (each form's signature option and its counter) |
| 11 | Armour with a full counter-set: 2 hits, 26 f startup with paint and sound, beaten by your own DI, throws, armour breaks and fast chains; absorbed damage is provisional and can KO. | https://streetfighter.fandom.com/wiki/Drive_Impact | C | KATATE, NOMIHOSE | armour (`:armor-hits` 2), tell ≥ 14 f, AS ender |
| 12 | Power Crush absorbs highs and mids, loses to lows; throws become inescapable; absorbed damage becomes recoverable life (T8); an absorbed hit delays the attack. | https://tekken.fandom.com/wiki/Power_Crush | C | KATATE, KATAUDE | armour (absorbs only some hit levels per form) |
| 13 | Charge armour only during the charge, one hit; levels flash white / yellow; level 3 auto-releases unblockable. | https://streetfighter.fandom.com/wiki/Focus_Attack | C | RYOTE | charge (stance levels with colour tells), armour |
| 14 | Regain: hitting back soon after being hit recovers that health. Miyazaki: "change the concept of defense to an active one"; regain amount is part of "the personality of weapons". | https://gigazine.net/gsc_news/en/20150402-bloodborne-miyazaki-hidetaka-interview | A | base, KATATE, KATAUDE | armour + a retaliation window (the next strike after a trade restores provisional HP), per-form rate as identity |
| 15 | Large weapons get high rally potential "to compensate for slow swing speeds". | https://bloodborne.fandom.com/wiki/Rally | C | KATATE (cleaver) | cadence (slow weapon, bigger trade reward) |
| 16 | Low-HP modes: 25% attack up and gauges fill faster; 15% super armour during attacks. A level-up from countering with three *different* moves. | https://jojo.fandom.com/wiki/JoJo%27s_Bizarre_Adventure:_All_Star_Battle | C | KATAUDE, base | armour at low Konpaku; cancels that feed later strikes reward variety |
| 17 | Mode crash: after Dragon Install expires, Sol is "left helpless momentarily". | https://www.dustloop.com/w/GGXRD-R2/Sol_Badguy | C | Bankai | mode distinction (exit recovery), cadence |
| 18 | Heat's timer pauses while the opponent is hit or grounded; being hit drains it; Heat Smash spends the rest and ends Heat. | https://tekken.fandom.com/wiki/Heat | C | NOMIHOSE, Bankai | cadence (offence extends the form) |
| 19 | Lifesteal grows within a combo (6th hit 110%, 10th+ 150%). | https://www.dustloop.com/w/BBCF/Ragna_the_Bloodedge | C | NOMIHOSE | NS segment escalation (later segments pay more) |
| 20 | Developers kept cutting passive low-HP damage (Tekken 25% → 5%, then 10% scaled by combo scaling) and moved the power into one-shot spends. | https://tekken.fandom.com/wiki/Rage | C | all (Konpaku attack bonus) | SA, keep passive multipliers small |
| 21 | "If you take off all of the limits … it'll break the game"; keep some for "tension and exhilaration". | https://onemoregame.ph/tekken-8-balanced-for-excitement-and-exhilaration/ | A | all | mode distinction (every form gets a limit) |
| 22 | Drive actions get a colour language so they are "easier to tell from a player perspective" (Fujioka). SF6 wanted "excitement and freedom from the very beginning" (Nakayama). | https://www.gameinformer.com/feature/2022/12/28/street-fighter-6-cover-story-the-dawn-of-a-new-era | A | all | tell (a per-form colour / ink language), cadence (the slow phase still needs choices) |
| 23 | Burnout: an empty shared gauge gives about 20 s of weakness (+4 f blockstun, chip); the gauge is "as important as a second health bar". | https://words.infil.net/w04-sf6review-p2.html | C | Bankai, NOMIHOSE | cadence (a post-form weakness window) |
| 24 | The Revenge Gauge fills from damage taken, including armoured (provisional) damage; fuller means a stronger Ultra. | https://streetfighter.fandom.com/wiki/Revenge_Gauge | C | base, KATATE | armour feeds SUBLIMATION / SA (taking hits on purpose pays) |
| 25 | A once-per-match boost that scales with how far behind you are (X-Factor levels 1–3). | https://marvelvscapcom.fandom.com/wiki/X-Factor | C | KATAUDE | SA, Konpaku scaling |
| 26 | Comeback (negative-feedback) boosts should stay weak or temporary or the match see-saws; in fighting games, losing health doesn't reduce your ability to win exchanges. | https://critpoints.net/2017/04/01/comeback-mechanics-2/ | C | all | limit how much Konpaku and NOME multiply each other |
| 27 | A dominant move "probably has no real counter"; you should have a way to deal with a known option. | https://sirlin.net/articles/balancing-multiplayer-games-part-2-viable-options | B | all | armour (never armour without a beater) |
| 28 | Hit stop, sound coherence and camera control most influence "impact feel". | https://arxiv.org/abs/2208.06155 | A (preprint; accepted at GEM 2022 per its arXiv comments) | RYOTE, KATATE, Bankai | per-form hitstop and camera as identity |
| 29 | Hitstop was lightened after it was found too strong, then restored with extra sound effects to sell weapon contact. | https://mp1st.com/news/monster-hunter-wilds-hitstops-final-game-closer-to-people-are-looking-forward | A | KATATE, RYOTE | per-form hitstop length |
| 30 | Hitstop length should match gaze duration for pleasant game feel. | https://scitepress.org/PublishedPapers/2024/124614 | A | all | tune hitstop per form |
| 31 | Polish has three kinds: tuning (predictability), juicing (clarity), and streamlining (acting on the player's intention). | https://arxiv.org/abs/2011.09201 | A | all | cadence (buffers and cancel windows = streamlining) |
| 32 | Visual embellishments raise appeal but affect competence only in specific circumstances. | https://api.semanticscholar.org/graph/v1/paper/DOI:10.1145/3311350.3347171?fields=title,abstract,venue,year | A | all | effects alone won't separate forms |
| 33 | Against armour, "super fast multi-hitting moves can get through too"; an install is a timed mode before you "return to your mortal self". | https://glossary.infil.net/?t=Armor | C | all | armour, mode distinction |
| 34 | Fighting games are real-time rock-paper-scissors variants; the choice graph should have no sinks. | https://cragl.cs.gmu.edu/rps/ | A | all | mode distinction |
| 35 | Game feel has six parts: input, response, context, polish, metaphor, rules; feedback must return quickly. | https://www.gamedeveloper.com/design/game-feel-the-secret-ingredient | B | all | cadence |

---

## (d) Sources

**Papers**
- Pichlmair, M., & Johansen, M. (2022). Designing Game Feel: A Survey. *IEEE Transactions on Games*, 14(2), 138–152. https://doi.org/10.1109/TG.2021.3072241 (metadata confirmed on Crossref; preprint at https://arxiv.org/abs/2011.09201)
- Hicks, K., Gerling, K., Dickinson, P., & Vanden Abeele, V. (2019). Juicy Game Design: Understanding the Impact of Visual Embellishments on Player Experience. *Proceedings of the Annual Symposium on Computer-Human Interaction in Play (CHI PLAY '19)*, 185–197. https://doi.org/10.1145/3311350.3347171 (Crossref; abstract via Semantic Scholar API)
- Hicks, K., Dickinson, P., Holopainen, J., & Gerling, K. (2018). Good Game Feel: An Empirically Grounded Framework for Juicy Design. *Proceedings of DiGRA 2018: The Game is the Message*. https://doi.org/10.26503/dl.v2018i1.936 (https://dl.digra.org/index.php/dl/article/view/936)
- Gingold, Y. I. (2006). From Rock, Paper, Scissors to Street Fighter II: Proof by Construction. *Proceedings of the 2006 ACM SIGGRAPH Symposium on Videogames (Sandbox '06)*, 155–158. https://doi.org/10.1145/1183316.1183339 (Crossref; project page https://cragl.cs.gmu.edu/rps/)
- Tomizawa, R., & Ishikawa, T. (2024). An Evaluation Research on Dynamic Hit Stop Using Eye Gaze. *Proceedings of the 19th International Joint Conference on Computer Vision, Imaging and Computer Graphics Theory and Applications (GRAPP)*, Vol. 1, 151–158. SciTePress. https://doi.org/10.5220/0012461400003660
- Lin, Z., Duan, H., Wen, Z. A., & Cai, W. (2022). What Features Influence Impact Feel? A Study of Impact Feedback in Action Games. arXiv:2208.06155 (preprint; its arXiv comments say it was accepted at IEEE GEM 2022). https://arxiv.org/abs/2208.06155

**Books and essays**
- Swink, S. *Game Feel: A Game Designer's Guide to Virtual Sensation*. Morgan Kaufmann Publishers / CRC Press. ISBN 978-0-12-374328-2 (OpenLibrary record: https://openlibrary.org/isbn/9780123743282.json, publish date 2009). Not read; listed only as the reference for the 2007 article below.
- Swink, S. (2007-11-23). Game Feel: The Secret Ingredient. Game Developer (formerly Gamasutra). https://www.gamedeveloper.com/design/game-feel-the-secret-ingredient
- Sirlin, D. "7) Spies of the Mind", from *Playing to Win*. Live at https://www.sirlin.net/ptw-book/7-spies-of-the-mind; text read on the gwern.net mirror https://www.gwern.net/docs/www/www.sirlin.net/c86d4e92f616d6acbf8c65cd5c57484967b1d6eb.html
- Sirlin, D. (2014-08-15). Balancing Multiplayer Games, Part 2: Viable Options. https://sirlin.net/articles/balancing-multiplayer-games-part-2-viable-options
- Wagar, C. (2017-04-01). Comeback Mechanics & Slippery Slopes. CritPoints. https://critpoints.net/2017/04/01/comeback-mechanics-2/

**Developer interviews (A)**
- Miyazaki, H., interview by GIGAZINE (2015-04-02). https://gigazine.net/gsc_news/en/20150402-bloodborne-miyazaki-hidetaka-interview
- Game Informer, Street Fighter 6 cover story, "The Dawn of a New Era" (2022-12; quotes from Nakayama and Fujioka). https://www.gameinformer.com/feature/2022/12/28/street-fighter-6-cover-story-the-dawn-of-a-new-era
- Garcia, C. (2023-03-29). Tekken 8 balanced for excitement and exhilaration (Murray quotes). One More Game. https://onemoregame.ph/tekken-8-balanced-for-excitement-and-exhilaration/
- mp1st (2025-02-11). Monster Hunter Wilds hitstops (Tsujimoto and Tokuda). https://mp1st.com/news/monster-hunter-wilds-hitstops-final-game-closer-to-people-are-looking-forward

**Official (B)**
- SNK, Samurai Shodown web manual, How to Play 2. https://snk-corp.co.jp/webmanual/samuraispirits/eng/howtoplay2.php

**Fan wikis and blogs (C)**
- Dustloop: GGST Nagoriyuki, GGST Zato-1, BBCF Hakumen, BBCF Ragna, GGXrd Rev 2 Sol Badguy, GBVS Mechanics, GBVSR Mechanics (URLs in the tables).
- Fandom, read via the MediaWiki API: Tekken Wiki (Heat, Power Crush, Rage); Street Fighter Wiki (Drive Impact, Focus Attack, Revenge Gauge, Jamie); Bloodborne Wiki (Rally); Marvel vs. Capcom Wiki (X-Factor); Koei Wiki (Berserk and the Band of the Hawk); God of War Wiki (Spartan Rage); JoJo Wiki (All Star Battle).
- infil, Street Fighter 6 review part 2, Battle System. https://words.infil.net/w04-sf6review-p2.html
- infil, The Fighting Game Glossary (entries Armor, Install, Hitstop, Stance, Turn, Archetype, Big Body; data from https://glossary.infil.net/json/glossary.json). https://glossary.infil.net/

Dropped for lack of a readable source:
- the Soulcalibur "Revenge" page (empty body);
- the Devil May Cry Devil Trigger rules (only the infobox came through);
- a Sekiro posture interview (the fetch failed);
- the God of War GDC 2019 talk (listing only);
- Sakurai's hitstop episodes (no transcript reached);
- all SuperCombo pages (blocked).
