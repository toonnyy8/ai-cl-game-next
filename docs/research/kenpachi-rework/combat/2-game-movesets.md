# Topic 2: how games turn Kenpachi's weapon types into movesets, with frame data

> Verified 2026-11-02 (`verify.md`: KEEP 208, FIX 7, DROP 1; the rows it did not reach are listed there). The FIX / DROP items are applied in this copy.

Collected 2026-11-02 for the Kenpachi move-module redesign (SOUL DUEL, 60 Hz). BLEACH Rebirth of Souls, Brave Souls and
Soul Resonance are left out (they're in `docs/research/kenpachi-rework/motion-refs.md` §2), and so is the Bleach canon.

**Conventions.** Every game below runs at 60 Hz, so its frames carry over 1:1 to SOUL DUEL's steps. Dustloop and Capcom
count startup up to and including the first active frame. Capcom writes active frames as a range ("26-27" means active
on frames 26 to 27). Soulcalibur VI publishes an **impact** frame, the first frame the hit lands. It goes in the startup
column below; SC6 pages give no separate active or recovery figure, so those cells read "—" and nothing was
back-computed from block advantage. "a~b" is a chargeable startup, "[x]" a fully charged or buffed value, exactly as
each page writes it.

Dustloop's Frame_Data pages pull their numbers from a `<char>/Data` subpage, so the oldid and "last modified" date
quoted for them belong to the wrapper page, not necessarily to the data. The dates don't tell you which patch the
numbers come from.

**Grades.** A = official or developer (Capcom's SF6 site). B = a published frame-data table or a data-mined guide
(Dustloop frame tables, FrameCalibur through SuperCombo, Kiranico). C = wiki narrative, Fextralife, Fandom.

**What wasn't found.** I got no fetched frame numbers for Monster Hunter, Elden Ring, Sekiro, Nioh 2 or Samurai
Shodown 2019. SuperCombo's live site answers 403, the SamSho 2019 pages aren't archived, and the only Monster Hunter
frame count I saw came secondhand from a search summary of a Reddit page I couldn't open. Those titles appear below as
narrative and design findings only.

---

## (a) Per-title play patterns

### 1. Guilty Gear -Strive-: Nagoriyuki (katana, blood gauge) and Potemkin (armoured grappler)

- **Nagoriyuki** is the best single model for a form whose moves get faster and stronger while it hurts the user.
  - Special moves fill his Blood Gauge: three bars of 100 points, +90 per special.
  - Each filled bar enhances his S and HS sword normals. It also raises the damage he takes: "+11% at one bar filled,
    +25% at two bars filled".
  - Landing sword normals drains the gauge.
  - A full gauge triggers **Blood Rage**: the normals are at their strongest, but he "loses access to special moves and
    drains up to 75% of his HP".
  - The frame table shows the same buttons at faster startups per blood level: f.S 16 → 14 → 12, 5H 20 → 16 → 16,
    2H 19 → 17 → 15.
  - His forward slash is a three-press string, f.S > f.SS > f.SSS, with a built-in feint: "If nothing is pressed
    afterwards, Nagoriyuki feints the animation for f.SSS".
  - His heavies are Guard Crush moves.
  - He has no run and no airdash. He moves by Fukyo, a step special that also feeds the gauge (+43.2).
  - Source: https://www.dustloop.com/w/GGST/Nagoriyuki
- **Potemkin's Hammer Fall** is a held-direction dash with one hit of armour from frame 5. It has a **Break** (stop
  short) that carries its own separate armour on frames 1–9, "giving Potemkin the opportunity to armor through two hits
  with careful timing".
  - The armour "is vulnerable to lows, and can be broken by quick successive attacks such as multi-hits".
  - Armoured hits deal 50% damage.
  - Its startup can be charged (18~37 f).
  - The Break lets him use the dash as an "armored taxi" into a grab or a super.
  - Source: https://www.dustloop.com/w/GGST/Potemkin
- **Hitstop by attack level** (GGST system table on the Nagoriyuki frame page): Lv.0–Lv.4 = 11 / 12 / 13 / 14 / 15 f
  hitstop, with standing hitstun 12 / 14 / 16 / 19 / 21 f. A heavier button means a longer freeze; the steps are
  1 f each.

### 2. Granblue Fantasy Versus: Rising, Vaseraga (greatscythe, Soul Forge armour)

- **Soul Forge** (5U) is a buff. It "applies 2 hits of Armor to certain moves such as H attacks and his Savage Rampage
  stance".
  - Armoured hits take 50% damage.
  - The buff runs on a meter that starts draining once an armoured move is used. A knockdown is the moment to re-apply
    it.
- Every H normal is **chargeable**, and with Soul Forge active the armour holds for as long as the button is held.
  - c.H startup runs 15~29, or [30] fully charged, with armour 12–34.
  - Holding is therefore the tell, the armour and a timing mix-up at once: "Can be charged to manipulate timing."
- **Savage Rampage** (22X) is an armoured stance with five follow-ups:
  - Rising Slash: mid, launch.
  - Sweeping Slash: low.
  - Crushing Strike: guard crush when charged.
  - Ravaging Stomp: superarmour.
  - March (22X~6).

  Plus a cancel. In move-module terms it's a stance whose follow-ups are the NS segments.
- Sources: https://www.dustloop.com/w/GBVSR/Vaseraga (overview) and
  https://www.dustloop.com/w/GBVSR/Vaseraga/Frame_Data.

### 3. Street Fighter 6: Drive Impact and Zangief's held heavy (Capcom's official frame data)

- **Drive Impact** (universal, shown on Zangief's page as "Drive Impact: Double Russian Chop"):
  - 26 f startup, "Super Armor for 2 hits from frames 1 - 27".
  - It crumples on a Punish Counter "or after the Super Armor absorbs a hit".
  - It wall-splats in the corner even on block. Capcom: "Perform this on an opponent backed into the corner to induce a
    wall splat, even if they block the attack."
  - The armour covers the entire 26 f tell. The payoff is louder (a crumple) when it eats a hit.
- **Zangief's Standing Heavy Punch** shows the held-button version:
  - 16 f startup.
  - "When the button is held, 1 hit of super armor is added to the upper half of the body from frame 4".
  - Held for more than 23 frames, it becomes the 32 f charged version with "Super Armor for 1 attack from frames
    4 - 34".
- Sources: https://www.streetfighter.com/6/character/zangief/frame (official). The Drive System quotes from Capcom are
  on SuperCombo's archived page,
  https://web.archive.org/web/2024id_/https://wiki.supercombo.gg/w/Street_Fighter_6/Drive_System.

### 4. Soulcalibur VI: Mitsurugi (katana), Nightmare (zweihänder) and Astaroth (axe) in one engine

One engine and one table format, so this is the cleanest weapon-class speed ladder found. All figures are
FrameCalibur's, as mirrored on SuperCombo.

- **Jab (A) impact by weapon:** Mitsurugi 12, Nightmare 16, Astaroth 20.
- **Vertical (B) impact by weapon:** Mitsurugi 14, Astaroth 20.
- **Nightmare** has armour on his heavy commands:
  - Blood Storm 6A: 22, Armor[10-20].
  - Double Avenger 6B: 22, Armor[10-22].
  - Soul Wave 6A+B: 36, Armor[10-35], and its follow-up "Dire Vengeance" is listed for when "armor clicks".
- **Nightmare's stance web:**
  - Grim Stride (236) is a forward lunge stance that many strings cancel into ("~ Grim Stride").
  - Three Night stances (Lower, Behind, Side) branch from each other with B+K, 6B+K and 4B+K.
- **Holds:** Shadow Slicer 1A goes from 32 to 62 when held as 1(A). Astaroth's Ax Grave 1B goes from 24 to 34 as
  1(B), and turns +6 on block.
- **Astaroth's grabs** are armoured command throws with long tells: Vicious Madness is impact 46 with Armor [10-46].
- **Astaroth's Soul Charge** gives his strings armour. For example, Bringer of Ruin SC 1AA: 36, Armor [8-32].
- **Mitsurugi** routes through Relic and Mist stances. His A has impact 12; the AA and AAA rows list the same
  first-hit impact, which is how SC6 string rows read, not a per-press interval. The AAA row notes "Jails if 2nd attack
  hits".
- Sources (archived SuperCombo, data credited to FrameCalibur):
  - Nightmare (oldid 210703): https://web.archive.org/web/20220815131750id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Nightmare/Move_list
  - Mitsurugi (oldid 210702): https://web.archive.org/web/20220809023141id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Mitsurugi/Move_list
  - Astaroth (oldid 210686): https://web.archive.org/web/20240114072952id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Astaroth/Move_list

### 5. Monster Hunter: World. Great Sword charge chain and Long Sword Spirit Gauge (design only, no frames)

- **Great Sword.** Three tiers chain into each other: Charged Slash → Strong Charged Slash → True Charged Slash.
  - "Each charged slash has three different charge levels, Levels 1 to 3."
  - The hunter glows brighter at each level and, at Level 3, "will perform a quick squatting motion. This helps the
    player in timing the attack."
  - Overcharging drops the slash to Level 2's power.
  - The **Tackle** cancels a charge, braces "for incoming attacks without knockback", and upgrades the tier (Charged →
    Strong → True).
  - Being hit, knocked away or evading loses all the charge.
  - So the weapon's identity is: hold for a tier, read the cue, release; an armoured shoulder carries the chain
    forward; overholding is punished.
  - Source: https://mhworld.kiranico.com/guide/great-sword
- **Long Sword.** Landing attacks fills the Spirit Gauge.
  - A landed Spirit Roundslash levels it up (three levels, each a bigger attack buff), and each level decays after a
    set time.
  - Spirit Helm Breaker spends a level for a big hit.
  - Foresight Slash, done "right before being hit", absorbs the attack and combos into a Roundslash.
  - The identity is a confirm-to-level-up rhythm: you can't level up without landing the finisher.
  - Source: https://mhworld.kiranico.com/guide/long-sword

### 6. Sekiro: posture and perilous attacks (design only)

- Posture replaces stamina.
  - Deflecting does "a high amount of posture damage to the attacker"; blocking only fills the defender's gauge.
  - A full posture gauge opens a Deathblow.
  - The attacker can't regain posture while attacking.
- **Perilous attacks** flash a red kanji ("Danger") and can't be guarded. Each type has its own answer:
  - Thrust: Mikiri Counter.
  - Sweep: jump.
  - Grab: dodge.
- The tells are body cues, for example a thrust is signalled "by drawing their right shoulder back and pointing their
  weapon straight forwards".
- One unguardable class with a universal on-screen glyph, plus a distinct posture per class, is a direct model for a
  ≥ 14 f opener tell that names its answer.
- Sources: https://sekiroshadowsdietwice.wiki.fextralife.com/Posture and
  https://sekiroshadowsdietwice.wiki.fextralife.com/Perilous+Attacks

### 7. Nioh 2: three stances per weapon and the odachi (design only)

- **The same weapon has three stances** that change the moveset, the Ki (stamina) cost and the dodge:
  - High: "increased damage at the cost of heavy Ki consumption". Its heavies "won't bounce off guard". Its dodge is a
    roll.
  - Mid: balanced, has the parries. Its dodge is a step plus a roll.
  - Low: "fast and low Ki consuming", short range. Its dodge is a quick step.
- **Odachi:** "breaking guard", "chain strong and quick attacks from different stances together", and mid stance
  attacks aren't reflected by a blocking enemy.
- Ki Pulse restores Ki after a string when timed to the blue flash: a rhythm reward for ending a string cleanly.
- Sources: https://nioh2.wiki.fextralife.com/Stances, https://nioh2.wiki.fextralife.com/Odachi and
  https://nioh2.wiki.fextralife.com/Ki+Pulse

### 8. Devil May Cry 5: Dante's Royalguard (taking hits as a resource)

- Blocking fills the Royal Gauge. A Royal Block (just-timed) fills it more, and "the perfect guard timing window is
  exactly the same (6 frames)" as in earlier games.
- Release spends the whole gauge as one blast.
- Royal Revenge spends one stock to nullify a hit and counter, with "no timing requirement".
- This is the template for a berserker who wants to be hit: damage absorbed becomes the next big swing.
- Source: https://devilmaycry.fandom.com/wiki/Royalguard_Style (read through the wiki API, `page=Royalguard_Style`).

### Supplement: Elden Ring hitstun tier by weapon class (no frames)

- Fextralife's PvP cheat sheet sets DamageLevel per attack, and an attack must still exceed the target's poise for the
  hitstun to apply.
- Its one example per level lines up with weapon size: "8 ⇨ Very short hitstun | Dagger R1", "1 ⇨ Short hitstun |
  Straight Sword R1", "2 ⇨ Medium hitstun | Greatsword R1", "3 ⇨ Long hitstun | Colossal Sword R1".
- Source: https://eldenring.wiki.fextralife.com/Poise

---

## (b) Frame-data table

| game | version | character or weapon | move as spelled | startup | active | recovery | armour | URL |
|---|---|---|---|---|---|---|---|---|
| GGST | Dustloop oldid 558768 (last modified 12 Apr 2026) | Nagoriyuki (katana) | 5P | 5 | 3 | 9 | — | https://www.dustloop.com/w/GGST/Nagoriyuki/Frame_Data |
| GGST | same | Nagoriyuki | f.S Level 1 / Level 2 / Level 3 / Level BR | 16 / 14 / 12 / 12 | 3 | 28 | — (-17 on block) | same |
| GGST | same | Nagoriyuki | f.SS Level 1 | 13 | 3 | 19 | — (-8) | same |
| GGST | same | Nagoriyuki | f.SSS Level 1 | 14 | 6 | 35 | — (-22; HKD +35 on hit) | same |
| GGST | same | Nagoriyuki | 5H Level 1 / Level 2 / Level 3 | 20 / 16 / 16 | 6 | 27 | Guard Crush (-8) | same |
| GGST | same | Nagoriyuki | 2H Level 1 / Level 2 / Level 3 | 19 / 17 / 15 | 7 | 29 | Guard Crush (-11) | same |
| GGST | same | Nagoriyuki | 6H Level 1 / Level 2 / Level 3 | 17 / 16 / 15 | 6 | 30 | Guard Crush (-2) | same |
| GGST | same | Nagoriyuki | 214S Yukimoyoi | 29 | 4 | 9 | — (Low, +6 on block) | same |
| GGST | same | Nagoriyuki | BR Activation | 4+(38 Flash)+3 | 10 | 70 | Guard Crush; 1-16F Full invuln | same |
| GGST | same | system | Attack Level Lv.0 … Lv.4 hitstop | 11 / 12 / 13 / 14 / 15 (hitstop) | — | — | standing hitstun 12 / 14 / 16 / 19 / 21 | same |
| GGST | Dustloop oldid 504653 | Potemkin | [4]6H Hammer Fall | 18~37 | 2 | 34 | 1 Hit Armor Mid/Overhead 5~38F (-17) | https://www.dustloop.com/w/GGST/Potemkin/Frame_Data |
| GGST | same | Potemkin | [4]6H P Hammer Fall Break | — | — | 21 | 1 Hit Armor Mid/Overhead 1~9F | same |
| GGST | same | Potemkin | 623K Heat Tackle | 12 | 13~28 | 32~38 | 1 Hit Armor 12~39F | same |
| GGST | same | Potemkin | 214H Garuda Impact | 28 | 11 | 24 | Guard Crush, +19 on block | same |
| GGST | same | Potemkin | 6H | 23 | 7 | 35 | — | same |
| GBVSR | Dustloop oldid 431094 (last modified 22 Dec 2023) | Vaseraga (greatscythe) | c.L | 7 | 3 | 6 | — | https://www.dustloop.com/w/GBVSR/Vaseraga/Frame_Data |
| GBVSR | same | Vaseraga | c.H | 15~29 [30] | 6 | 21 | Soul Forge: [12-34 Armor ×2] | same |
| GBVSR | same | Vaseraga | f.H | 17~29 [30] | 6 | 23 | Soul Forge: [12-34 Armor ×2] | same |
| GBVSR | same | Vaseraga | 2H | 13~29 [30] | 6 | 26 | Soul Forge: [11-35 Armor ×2] | same |
| GBVSR | same | Vaseraga | 66H | 20~39 [40] | 4 | 23 | Soul Forge: [19-47 Armor ×2] | same |
| GBVSR | same | Vaseraga | 5U Soul Forge | 21 | 3 | 17 | Soul Forge: 5-23 Armor ×2 | same |
| GBVSR | same | Vaseraga | 22X~H Crushing Strike | 15 [40] | 2 | 31 | Mid [Guard Crush 49]; Soul Forge: 1-16 [1-41] Armor ×2 | same |
| GBVSR | same | Vaseraga | 22X~U Ravaging Stomp | 20~40 | 6 | 30 | 1-25~45 Superarmor | same |
| GBVSR | same | system | Raging Strike | 28 (1) | 1 | 37 | Guard Crush 45 [52] | same |
| SF6 | official site, no patch stated (fetched 2026-11-02) | Zangief | Standing Heavy Punch | 16 | 16-18 | 22 | when held: 1 hit super armor, upper body, from frame 4 | https://www.streetfighter.com/6/character/zangief/frame |
| SF6 | same | Zangief | Standing Heavy Punch(Charged) | 32 | 32-34 | 22 | Super Armor for 1 attack from frames 4 - 34 | same |
| SF6 | same | universal (Zangief's) | Drive Impact: Double Russian Chop | 26 | 26-27 | 35 | Super Armor for 2 hits from frames 1 - 27 (-3 on block) | same |
| SC6 | SuperCombo oldid 210702, FrameCalibur data, archived 2022-08-09 | Mitsurugi (katana) | A (Prime Moon Shadow Rush) | 12 (impact) | — | — | — | https://web.archive.org/web/20220809023141id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Mitsurugi/Move_list |
| SC6 | same | Mitsurugi | B (Celestial Divide) | 14 (impact) | — | — | — | same |
| SC6 | SuperCombo oldid 210703, FrameCalibur, archived 2022-08-15 | Nightmare (zweihänder) | A (Plague Spreader) | 16 (impact) | — | — | — | https://web.archive.org/web/20220815131750id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Nightmare/Move_list |
| SC6 | same | Nightmare | 6A (Blood Storm) | 22 (impact) | — | — | Armor[10-20] | same |
| SC6 | same | Nightmare | 6B (Double Avenger) | 22 (impact) | — | — | Armor[10-22] | same |
| SC6 | same | Nightmare | 6A+B (Soul Wave) | 36 (impact) | — | — | Armor[10-35] (-14 on block) | same |
| SC6 | same | Nightmare | 1A / 1(A) (Shadow Slicer, held) | 32 / 62 (impact) | — | — | — | same |
| SC6 | SuperCombo oldid 210686, FrameCalibur, archived 2024-01-14 | Astaroth (axe) | A (Annihilation) | 20 (impact) | — | — | — | https://web.archive.org/web/20240114072952id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Astaroth/Move_list |
| SC6 | same | Astaroth | B (Great Divide) | 20 (impact) | — | — | — | same |
| SC6 | same | Astaroth | 1B / 1(B) (Ax Grave, held) | 24 / 34 (impact) | — | — | — (held: +6 on block) | same |
| SC6 | same | Astaroth | (3)_(6)_(9)A+G (Vicious Madness) | 46 (impact) | — | — | Armor [10-46] | same |
| SC6 | same | Astaroth | SC 1AA (Bringer of Ruin, Soul Charge) | 36 (impact) | — | — | Armor [8-32] | same |
| DMC5 | Fandom wiki (no version stated) | Dante, Royalguard | Royal Block (perfect guard window) | window 6 | — | — | — | https://devilmaycry.fandom.com/wiki/Royalguard_Style |

---

## (c) Findings, top-ranked first

The ranking weighs two pain points: 「形態之間差異不夠」 (the forms don't differ enough) and 「操作或節奏不順」 (the
controls or the cadence feel off).

| # | claim | source URL | grade | form(s) | module hook |
|---|---|---|---|---|---|
| 1 | One weapon, one button grammar, different cadence per resource level: Nagoriyuki's f.S starts 16 → 14 → 12 f and 5H 20 → 16 f as blood bars fill. Each bar also raises damage taken (+11% / +25%), and a full gauge locks out specials and drains up to 75% HP. | https://www.dustloop.com/w/GGST/Nagoriyuki (and /Frame_Data) | B | NOMIHOSE (main); base → NOMIHOSE as a dial | cadence; NS segment speed-up per level; a self-damage risk state instead of new moves |
| 2 | Armour sized to cover the tell: Drive Impact 26 f with 2-hit armour on frames 1-27, and a louder payoff (crumple) once the armour has eaten a hit. The armoured tell moves listed have startup ≥ 14 f, with armour from early in the startup through the active frames (Hammer Fall 5~38F, Soul Wave 10-35, c.H 12-34, Vicious Madness 10-46). The exception is Heat Tackle: 12 f startup, armour 12~39F. | https://www.streetfighter.com/6/character/zangief/frame (plus the Dustloop and SC6 rows in (b)) | A / B | Bankai, KATATE | armour; tell ≥ 14 f; AS ender whose payoff grows when the armour clicks |
| 3 | A three-press string with a built-in feint: f.S > f.SS > f.SSS (startup 16 / 13 / 14, recovery 28 / 19 / 35). If nothing is pressed after f.SS, he feints f.SSS, which sets up strike or throw and a backstep. | https://www.dustloop.com/w/GGST/Nagoriyuki | B | base, RYOTE | NS 1–3; SA in the NS gap (the feint *is* the gap); cadence: fast middle, slow last |
| 4 | A held button that is the tell, the armour and a timing mix-up at once: Vaseraga's c.H is 15~29 [30] and keeps 2-hit armour while held; "Can be charged to manipulate timing". Armoured hits take 50%. | https://www.dustloop.com/w/GBVSR/Vaseraga | B | Bankai, KATATE | charge; armour; Kikon-style hold |
| 5 | Charge tiers carried forward by an armoured brace: MH Great Sword Charged → Strong → True, each with levels 1–3. The Tackle braces without knockback and upgrades the tier; overcharge drops to Level 2; Level 3 shows a squat cue; being hit loses the charge. | https://mhworld.kiranico.com/guide/great-sword | B | RYOTE (or Bankai) | charge; NS segments as tiers; tell (squat cue at the sweet spot); armour on the linking move |
| 6 | Weapon-class speed ladder in one engine: jab impact katana 12 / zweihänder 16 / axe 20, vertical katana 14 / axe 20. The heavy weapon's *fast* button sits where the katana's is slow. | SC6 Mitsurugi / Nightmare / Astaroth move lists (archived, FrameCalibur) | B | base vs KATATE vs Bankai | cadence: one startup tier per form (for example base ~14, KATATE ~16–18, Bankai ~20+) |
| 7 | An armoured hold-dash with a brake: Hammer Fall (18~37 startup, 1-hit armour 5~38F) plus Break (its own armour 1~9F, recovery 21) allows armouring two hits, or using the dash as an "armored taxi" into a grab or super. | https://www.dustloop.com/w/GGST/Potemkin | B | Kikon (all forms), Bankai | Kikon hold flash-step that armours and can be stopped short |
| 8 | Hitstop climbs 1 f per attack level (11 → 15 f) and hitstun 12 → 21 f. Elden Ring sets a DamageLevel (hitstun tier) per attack, and its cheat sheet's examples line up with weapon size (Dagger R1 very short … Colossal Sword R1 long). | https://www.dustloop.com/w/GGST/Nagoriyuki/Frame_Data ; https://eldenring.wiki.fextralife.com/Poise | B / C | all; contrast katana forms vs Bankai | feel: per-form hitstop and hitstun table rather than per-move ad hoc |
| 9 | Stance changes the whole kit and the dodge: Nioh 2 High (heavy Ki, won't bounce off guard, roll), Mid (parries, step + roll), Low (fast, cheap, quick step); the odachi chains attacks across stances. | https://nioh2.wiki.fextralife.com/Stances ; https://nioh2.wiki.fextralife.com/Odachi | C | KATATE vs RYOTE (one-hand vs two-hand as two stances of one blade) | stance; the Step/Hoho per form differs too, not only the attacks |
| 10 | Armour bought as a temporary buff: Soul Forge applies 2-hit armour to H moves and the Rampage stance; the meter drains once armoured moves are used, and a knockdown is the time to re-apply it. | https://www.dustloop.com/w/GBVSR/Vaseraga | B | Bankai, NOMIHOSE | armour as a form state with a timer; SA to refresh |
| 11 | A stance whose branches are the string: Savage Rampage (22X) splits into mid launch, low, guard crush (charged), a superarmour stomp and March (22X~6), plus a cancel. | https://www.dustloop.com/w/GBVSR/Vaseraga/Frame_Data | B | Bankai, KATAUDE | stance; NS segments as branches (high / low / crush) |
| 12 | Taking hits as the resource: Royalguard blocks fill a gauge, a 6 f just-block fills more, and Release spends the whole gauge in one blast; Royal Revenge spends one stock to nullify and counter with no timing. | https://devilmaycry.fandom.com/wiki/Royalguard_Style | C | NOMIHOSE, Bankai | armour → charge: absorbed hits power the AS ender |
| 13 | Level-up only by landing the finisher: the Long Sword Spirit Gauge fills on hits; a landed Spirit Roundslash raises the level, levels decay over time, and Helm Breaker spends one. Foresight Slash absorbs a hit just before impact. | https://mhworld.kiranico.com/guide/long-sword | B | RYOTE (kendo discipline) | AS ender that levels the form; a counter-slash SA |
| 14 | One universal danger glyph plus a body cue per attack class: Sekiro's perilous kanji; a thrust is shown by the right shoulder drawn back, a sweep by the left shoulder back or a spin. Each class has one answer. | https://sekiroshadowsdietwice.wiki.fextralife.com/Perilous+Attacks | C | all; especially Bankai's crude swings | tell ≥ 14 f: a pose per NS theme, read before the hit |
| 15 | Held versions as a second move on the same input: SC6 Shadow Slicer 1A 32 → 1(A) 62; Astaroth Ax Grave 1B 24 → 1(B) 34 and +6 on block; Zangief st.HP 16 → charged 32 after >23 f held. | SC6 archived move lists; https://www.streetfighter.com/6/character/zangief/frame | A / B | KATATE, Bankai | charge: hold an NS press for a slower, plus-on-block version |
| 16 | Armoured grabs with very long tells are the axe's answer to turtling: Astaroth's Vicious Madness is impact 46 with Armor [10-46]. Soul Charge adds armour to his strings (SC 1AA 36, Armor [8-32]). | https://web.archive.org/web/20240114072952id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Astaroth/Move_list | B | Bankai, KATAUDE (free hand / one arm grabs) | armour; SA as an armoured grab; awaken adds armour to strings |
| 17 | Posture punishes the attacker who gets deflected: deflects do "a high amount of posture damage to the attacker", and an attacker cannot regain posture while attacking. | https://sekiroshadowsdietwice.wiki.fextralife.com/Posture | C | base (reckless swinging has a cost) | cadence: a reason to stop the string |

---

## (d) Sources

- Dustloop, GGST Nagoriyuki overview (oldid 582233): https://www.dustloop.com/w/GGST/Nagoriyuki
- Dustloop, GGST Nagoriyuki frame data (oldid 558768, last modified 12 Apr 2026): https://www.dustloop.com/w/GGST/Nagoriyuki/Frame_Data
- Dustloop, GGST Potemkin overview (oldid 581585): https://www.dustloop.com/w/GGST/Potemkin
- Dustloop, GGST Potemkin frame data (oldid 504653): https://www.dustloop.com/w/GGST/Potemkin/Frame_Data
- Dustloop, GBVSR Vaseraga overview (oldid 580659): https://www.dustloop.com/w/GBVSR/Vaseraga
- Dustloop, GBVSR Vaseraga frame data (oldid 431094, last modified 22 Dec 2023): https://www.dustloop.com/w/GBVSR/Vaseraga/Frame_Data
- Capcom, Street Fighter 6 Zangief frame data (official): https://www.streetfighter.com/6/character/zangief/frame
- SuperCombo, SF6 Drive System (archived; quotes Capcom): https://web.archive.org/web/2024id_/https://wiki.supercombo.gg/w/Street_Fighter_6/Drive_System
- SuperCombo / FrameCalibur, SC6 Nightmare move list (oldid 210703): https://web.archive.org/web/20220815131750id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Nightmare/Move_list
- SuperCombo / FrameCalibur, SC6 Mitsurugi move list (oldid 210702): https://web.archive.org/web/20220809023141id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Mitsurugi/Move_list
- SuperCombo / FrameCalibur, SC6 Astaroth move list (oldid 210686): https://web.archive.org/web/20240114072952id_/https://wiki.supercombo.gg/w/Soulcalibur_VI/Astaroth/Move_list
- Kiranico, MHW Great Sword guide: https://mhworld.kiranico.com/guide/great-sword
- Kiranico, MHW Long Sword guide: https://mhworld.kiranico.com/guide/long-sword
- Fextralife, Sekiro Posture: https://sekiroshadowsdietwice.wiki.fextralife.com/Posture
- Fextralife, Sekiro Perilous Attacks: https://sekiroshadowsdietwice.wiki.fextralife.com/Perilous+Attacks
- Fextralife, Nioh 2 Stances: https://nioh2.wiki.fextralife.com/Stances
- Fextralife, Nioh 2 Odachis: https://nioh2.wiki.fextralife.com/Odachi
- Fextralife, Nioh 2 Ki Pulse: https://nioh2.wiki.fextralife.com/Ki+Pulse
- Fextralife, Elden Ring Poise (DamageLevel cheat sheet): https://eldenring.wiki.fextralife.com/Poise
- Fandom, Devil May Cry Royalguard Style: https://devilmaycry.fandom.com/wiki/Royalguard_Style
