# Kurosaki Ichigo (TYBW): greatsword and dual-blade style references for the strike-clip rebuild

Research pass 2026-10-14. The user's request: 「動作模組可以額外搜尋其他遊戲或動漫作品中雙刀與大劍的戰鬥風格，並以此為基礎進行改進並增加演出魄力」.
Use: rebuilding Ichigo's keyframed clips in SOUL DUEL with more impact (演出魄力). Shikai 二刀の斬月: a 1.55 m cleaver in the
**right** hand, a ~0.5 m hiltless short blade in the **left** (a big + small pair). Awakened 血鎖の一護 KESSA: one white
pointless slab (1.6 m) in the right hand, blood chains, reiatsu clones. Method: skill `duel-motion-style`; format:
`docs/research/yamamoto-rework/motion-refs.md`, `docs/research/kenpachi-rework/motion-refs.md`. Kit slots:
`docs/duel/DUEL_ICHIGO.md` §3, "v2: built".

**Fetch note.** Fandom page views answer 403; their MediaWiki API (`api.php?action=parse&prop=wikitext`) worked for
monsterhunter, devilmaycry, finalfantasy, soulcalibur, berserk, swordartonline, onepiece, ninjagaiden, godofwar,
kingdomhearts, nier, godeater, dragonsdogma and bleach; monsterhunterwiki.org's API for the MH Wilds Great Sword page.
Fextralife (MH World, Elden Ring) refused every request, and Wikipedia / Commons rate-limited after one call, so Elden Ring and
some MH World detail is from memory (graded C/D below). Resource of Souls (RoS in-game strings) answered. I watched no video.
I looked at 5 GIFs as frame sheets and 9 stills (§8); they are in the git-ignored `.refs/ichigo-style/`.

**Grades.**
- **A**: seen by me in a still or a GIF frame sheet (file named), or BLEACH canon as told by the wiki's chapter-cited prose.
- **B**: official game text (in-game move strings, official controls quoted on a wiki).
- **C**: secondary (fan-wiki prose describing a move, articles, my memory of a widely documented move).
- **D**: my inference or proposal. A design proposal, not a reference.

---

## 1. Greatsword references

### 1.1 Monster Hunter, Great Sword (大剣)
- **The charge ladder** (B, MH Wilds official controls quoted on monsterhunterwiki.org): "Hold down [the button] to expend
  stamina and store up power. There are three charge levels"; Overhead Slash → Charged Slash → **Strong Charged Slash** →
  **True Charged Slash**, each chained from the last; a Strong Wide Slash branches off. The level rises "for each 1 second it
  is held". Rise text: True Charge Slash "strik[es] twice by making a large swing with the weapon" (B, MH Rise switch skills).
- **Body** (C, memory of World/Rise/Wilds): the charge pose is the sword **cocked over the right shoulder, the body coiled
  low and twisted away, the knees bent**, and it flashes at each level (the tell grows). Charged Slash = one vertical drop.
  True Charged Slash = a **first sweeping hit that winds the blade round, then a huge overhead drop** whose follow-through
  buries the tip in the ground; the body ends folded over the front knee.
- **Tackle** (B): "A shoulder thrust that withstands all attacks … useful for standing your ground while charging";
  Wilds: "executed without getting knocked back"; a **Perfect Tackle keeps the charge level**. Guard Tackle (B, Rise): "a
  forward-dashing attack using **the flat side of the blade**". Body (C): the left shoulder drives forward with the off hand
  braced on the flat; it links the charges (charge → tackle → bigger charge).
- **Hitstop** (B, MH 2nd-gen text): "If the slash seems to **lag briefly upon contact**, the point is weak" — the series
  sells weight with a per-hit freeze that grows with the charge level (C: TCS's freeze is the longest of any weapon).
- Old gen (B): no slash repeats twice in a row (vertical → horizontal or upward); the upswing "can literally send fellow
  hunters flying"; the kick is the only fast move; MH3 added "slaps the monster with the side of the blade" (the flat).
- **What reads**: the long coiled hold, the charge flash, the two-beat TCS, the drop that finishes in the ground, the stop.

### 1.2 Berserk, Guts and the Dragon Slayer
- "Too big to be called a sword … a heap of raw iron" (A, Berserk wiki quoting ep. 0-1). "Functions more like a **bladed
  maul**"; "the sheer **momentum** of Guts swinging it can tear anyone … to pieces"; he "has used **the broad side** of the
  weapon to squash and flatten several opponents" and its width "in lieu of a shield" (A/C, wiki with episode refs).
- `bk_e94.png` (A, manga ep. 94, the first Dragon Slayer kill): panel 1, the sword **held horizontal over the head in both
  hands, the blade reaching far back** (the wind-up shows the whole length); panel 2, the cut has **already passed**: Guts
  in a very deep wide stance, torso twisted past the target, the blade **ended low near the ground beyond the foe**; the arc
  is drawn as a **dense half-disc of speed lines**; the wall behind explodes; the apostle is split.
- `bk_btp.png` (A, a later chapter): the Dragon Slayer **held out one-handed at arm's length, level**, flat to the reader:
  the strength shown by holding it still.
- Spins and momentum turns are his habit in the later fights (C); the cannon arm is his "off-hand trick" (A).

### 1.3 Final Fantasy VII / Remake / Rebirth, Cloud and the Buster Sword
- **Braver** (B, FF wiki): "Cloud **leaps into the air and strikes** … leaving behind a trail of light" (Remake); Dissidia:
  dashes in, stabs, "jump up and **slam them down**", "a **shockwave** at the point of impact", charge to widen it; Kingdom
  Hearts: "stabbing the Buster Sword into the ground and releasing a shockwave".
- **Cross-slash** 凶斬り (B, FF7): "a **lunge forward and three slices** … that forms a '凶'"; only one damage tick.
  `ff7_cross.gif` (A, the PS1 limit): a 1.6 s aura charge (flame cone), the sword raised upright overhead, a crouched low
  cut, a level shoulder-height cut, a final rising diagonal into a burst; the 凶 marks hang where he cut.
- **Omnislash** (B): "charging up his sword, then lunging … a barrage of sword strikes, before **jumping in the air and
  charging his final attack** that he brings down". Dissidia: 14 slashes then "a final powerful overhead slash".
- **Punisher Mode** (B): "less mobile, but … stronger attacks, and … **counterattack melee attacks**" while guarding: a
  slow, rooted, counter-hitting stance for the big sword.
- Body (C, memory): the Buster Sword **rests on the right shoulder / hangs low behind** between attacks; Punisher swings
  are flat, wide and one-handed.

### 1.4 Soulcalibur, Siegfried and Nightmare (zweihänder stances)
- Siegfried's stances (B, SC wiki move tables): **Chief Hold**, **Side Hold** (デキスター = dexter), **Reverse Side Hold**
  (シニスター = sinister, the sword in the left hand), **Base Hold**. The tables are full of transitions: "Chief Hold ~ Side
  Hold", "Base Hold ~ Chief Hold", "Grief Scythe ~ Side Hold": **a strike ends in a hold and the next strike starts from
  it**, so the big sword never stops — it parks. Base Hold "deflects low attacks"; Side Hold has Guard Impact properties.
  (The brief's "Rear Hold" is not on the wiki; the closest is Nightmare's "Night Behind Stance".)
- Body (C, memory): Chief Hold = blade upright before the face; Side Hold = blade level at the hip, point back; Base Hold =
  point down to the ground. **What reads**: each finished swing is a readable pose; the hand switch (dexter / sinister).

### 1.5 Devil May Cry, Dante's Rebellion
- **Stinger** (B): "a powerful thrust after lunging forward"; DMC4 cinematic: "Dante appears to be **dragged by his
  sword**, as his feet literally slide over the ground". `dmc3_sting1.jpg` (A): body tipped forward, sword arm locked level.
- **High Time** (B): "Swing Rebellion upwards to fling enemies into the air. Hold … to launch the player". **Helm Breaker**
  兜割り (B): "a powerful overhead swing from mid-air which returns the player to the ground".
- **Million Stab** (B): "rapidly stab … with blinding speed. Combo is finished by a longer range thrust". **Dance Macabre**
  (B): after the stabs "an upward swing and then striking the enemy … **like he is swinging a baseball bat**".
  **Prop Shredder** (B): "spin your sword vertically … like a buzzsaw". **Drive** (B): "a slow start that sends a powerful
  shockwave"; held longer = stronger. Combo A (B, DMC4): "4-hit combo **ending with a diagonal spinning slash**".

### 1.6 Elden Ring / Dark Souls, greatswords and colossal swords (C/D, memory; Fextralife refused)
- The two-handed **jump attack**: leap, sword raised overhead, the body folding as it lands, a dust ring. The **charged
  heavy**: the sword drawn back over the shoulder, the body leaning back for a long hold, then one huge release.
  Colossal-sword light chains: **alternating horizontal sweeps** where each swing's end is the next one's wind-up (momentum
  carries through), the feet dragging. **What reads**: a slow, honest wind-up, the drag, the long recovery.

### 1.7 NieR:Automata 2B, light + heavy weapon sets (the closest game model of big + small)
- (B, NieR wiki) Weapons go in the **light or heavy slot**; "the type of combo attacks unleashed when **transitioning from
  light to heavy** … change based on the weapon configuration". 2B's set: Virtuous Contract (small sword, light) and
  Virtuous Treaty (large sword, heavy). Body (C, memory): the large sword is a floating pod-carried slab swung in
  whole-body arcs; light hits are quick; a mixed string interleaves them. **This is exactly J (short) / K (cleaver) / the
  switched link.**

### 1.8 God Eater and Dragon's Dogma (B)
- God Eater Buster Blade: "**Charge Crush**, which slams the weapon downward after gathering energy", and a **Parrying
  Upper**. Dragon's Dogma Warrior: Savage / Indomitable **Lash** (charged, holds through hits), **Arc of Might** ("spins the
  blade in a swift circle"), a **charging lunge "with the blade extended"**, **Pommel Bash** ("drives the blade's hilt into
  the target" — a short, close hit from a long weapon).

## 2. Dual-blade references

### 2.1 Monster Hunter, Dual Blades (双剣)
- (B, MH wiki) "high speed … inability to block"; "**Demon mode** … strike faster, deal more damage … super armor"; the
  **Demon Dance** "will not bounce on contact"; some strikes "**one sided**" (a spin-slash up to the right, or left with the
  stick); Demon Dodge "strafes" and links into attacks. Rise (B): **Demon Flurry Rush** "a spinning multi-hit attack …
  with reliable dash"; **Demon Flight** "an attack performed by **slamming down both blades**. A successful hit vaults you
  into the air, slicing … as you spin upwards".
- Body (C): the demon pose is a low crouch with both blades held back and down like wings; the Blade Dance is a turning
  flurry whose cuts alternate hands.

### 2.2 Sword Art Online, Kirito's Dual Blades (二刀流)
- **Starburst Stream** (C, SAO wiki, detailed): "a horizontal swing from left to right with the right sword, immediately
  followed by an uppercut with the left … jumps up and slashes … with both swords from left to right while spinning, twice …
  **slashes an X from top to bottom, before inversely slashing the X again from bottom to top** … two diagonal slashes from the
  same starting point … reverses his grip … a barrel-roll … a diagonal slash with the right sword, top-right to bottom-left,
  then **spins left and uses this momentum** to deal a horizontal, right to left slash with the left". 16 hits. Author's
  image: "two swords becoming countless shooting stars tearing through the darkness".
- `sao_ss.gif` (A, anime ep. 14 frames): cuts drawn as **light ribbons**; **red parallel slash marks stay on the target**;
  face cut-ins (gritted teeth) between beats; a full **white-out**, then the last thrust **as a silhouette** on white.
- The Eclipse: 27 hits; Double Circular: 2 hits; Cross Block: the defensive skill (B, wiki list).

### 2.3 Roronoa Zoro (One Piece): Nitōryū and the Santōryū cross shapes
- **Oni Giri** (C, OP wiki): swords "crossed across his chest … approaches the target (usually at high speed) and cuts
  through by swinging the swords across his chest, resulting in a **descending diagonal-crossing slash**". `op_onigiri.png`
  (A, anime ep. 7): **after the pass**, Zoro's back to the foe, **arms flung wide in a T**, blades out to both sides; the foe
  behind him bleeding from the cross.
- Two-sword (C): **Nigiri** (both blades held parallel, tips to one side) → **Toro Samon** "two swords in an **upward
  diagonal slash**"; **Rashōmon** (an iai: draws and re-sheathes both; the cut appears after); **Sai Kuru** "swords in front
  of him pointing up, like rhinoceros' horns, and spin-slashes"; **72 Pound Ho** "two swords horizontally above the
  shoulder … a circular swing"; **Clear Lance** "a downward slash with two swords, generating a strong shockwave";
  **Gokuraku Anyō Rashōmon** "two … swords, held crosswise, while … moving past them". Three-sword: **Ushi Bari** "two
  swords held out like a bull's horns" (a running double stab); **Tora Gari** "a forward descending slash"; **Tatsu Maki**
  a spin. The wiki notes Zoro's two-sword style "is based on the Niten Ichi-ryū".

### 2.4 Musashi's Niten Ichi-ryū (the real-world big + small)
- Gorin no Sho (C, via Wikipedia's summary): Musashi advocates "wielding both katana and wakizashi, contrary to … the
  katana two-handed"; five attitudes: "Upper, Lower and Middle attitudes are decisive. Left Side and Right Side attitudes
  are fluid".
- The school's five **Nitō Seihō** forms map to those five attitudes (C, kampaibudokai.org): chūdan, jōdan, gedan, left and
  right waki.
- The **chūdan guard** (C, nitojuku.com quoting Tokitsu's translation of Hyōhō 39): "**cross your large and small swords in
  a forward position and at a middle level** … The point of the large sword is tilted slightly upward"; tips "directed toward
  the opponent's face"; historical duels describe Musashi in the crossed-sword chūdan. Today's Niten lines keep the tips
  apart (Ensō-no-kamae); older lines cross them (Enkyoku-no-kamae).
- **What reads** (D from the above): the short sword is held forward at the face line and **controls** (catches,
  presses, points); the long sword cuts from the side or above. The crossed X is a **guard that becomes a cut**.

### 2.5 Other dual wielders
- **Ninja Gaiden** Dual Katana (B/C, NG wiki): "Large Japanese swords, wielded as a pair"; strings named Fire Dragon
  Spinning Descent, **Purgatory Slash** ("a rapid strike with good dismemberment"), **Rise to Heaven** (a launcher with long
  invincibility), Swooping Dragon Fang ("slow start-up … high hitstun"), the Ultimate Technique **Eight Heavenly Dragons**
  (hold, release). Body (C, memory): Ryu's NG2 dual katana are all whirling, wide, both-arm spins.
- **God of War** Blades of Chaos (B): chained blades; **Cyclone of Chaos** "swings his blades around him multiple
  times"; **Spear of Chaos** impales, then **Elemental Surge** "send[s] … energy down the chain, blasting … the enemy"; Chaos
  Slam "leap into the air and … a powerful chain-slam"; Chaotic Flurry "triple-stab dash". → the **chain** form's grammar.
- **DMC3 Agni & Rudra** (B): twin scimitars; their crazy combo "Jet-Stream-to-Twister" (named only).
- **Kingdom Hearts** Roxas (B): "dual-wield Keyblades, Oathkeeper and Oblivion" via Synch Blade; moves not fetched.
- Nioh dual swords, Tales / Xenoblade dual wielders: not fetched (gap).

## 3. BLEACH's own Ichigo (TYBW dual Zangetsu and Blood Chains)

### 3.1 Canon (A, Bleach Wiki with chapter / episode refs)
- The Shikai: a khyber-knife cleaver "the size of his previous sword" and a short blade "about the size of Ichigo's arm …
  resembles a trench knife … an enclosed handle, with a portion acting like a hand guard" (ch. 555). (Canon carries the
  big one on the back, the short on the right hip; the game puts the cleaver in the right hand, the short in the left.)
- **Getsuga Tenshō** with the true Zangetsu: "by simply **pointing his smaller sword** at the enemy and making a small
  slash"; or with the larger sword, "powerful enough to blast a large hole in the Soul King Palace" (ch. 618).
- **Getsuga Jūjishō** (ch. 583; anime 387 / 394): "**crosses the path of his sword swings**", one Getsuga per blade fused
  into a cross. `bl_juji394.gif` (A, 0.5–2.8 s): the cleaver held **level across the waist** in the right hand, flat to the
  camera (the coil); then a crouched twist, the **short blade raised high behind the head on the other side** while the
  cleaver sweeps **horizontally low** with a gold trail; an eye close-up; **vertical** gold lines fall: horizontal first,
  vertical second, the cross. Then a long hold on the cross, white-out, explosion.
- **Chain** (anime 406): calls either blade back to the hand "akin to pulling it by an invisible chain".
- Stills: `bl_542.png` (ch. 542 colour): striding, the cleaver **trailing level behind at shoulder height**, the short
  blade **hanging point-down** in the other hand. `bl_615.png`: crouched under Yhwach, a huge white **C-arc** of the cut
  around them. `bl_618.png` "Ichigo grabs": the **free hand reaching for Yhwach** inside a giant white crescent.
  `bl_676.png` (ch. 676, Half-Hollow): one hand **restrains Yhwach's sword wrist** while the white blade is raised
  diagonally overhead — canon "restrained his sword arm with one hand … destroyed a large chunk of the tower with … his
  subsequent slash".
- **Blood Chains Ichigo** 血鎖の一護 (anime ep. 411): "a large silver sword with a white handle … **the tip … sheared
  off**"; "glowing blood-red chains … from his **neck, hands, and feet**"; "footprints of flaming black Reiatsu"; chains
  "defend against attacks" and "wrap around and **bind** an enemy"; **reiatsu clones** left "in locations he steps in",
  "dozens … in nearly an instant", "strike from multiple directions near-simultaneously", **Delayed Strikes** "land even if
  his opponent dodges"; the enhanced Getsuga leaves "a large black crescent moon … suspended in the air".
  `bl_ep411.png` (A): rest pose, the slab **hanging low in the right hand, the sheared tip angled down across the front of
  the legs**, arms slightly out from the body, chains coiling off the wrists, ankles and neck. `bl_kessa411.gif` (A, 41 s):
  stylised clash frames, **black/white inverted** impact frames, a full white-out, the eclipsed C hanging in the sky, his
  silhouette under it with red chains.

### 3.2 Games
- **Rebirth of Souls**, TYBW Ichigo (B, in-game strings via Resource of Souls): "a balanced fighter who controls the pace
  of battle with **a flurry of hits**"; Rushdown. Signature **Syzygy** "Take a stance with your **blade forward**", then
  **Full Moon** "A spinning slash attack **while advancing**", **Moonlight** "Execute **wide slashes with both blades**.
  Takes a while", **Getsugatensho** "a **horizontal** Getsugatensho from your stance", **Rising Moon** "major forward
  movement … no hitbox" (a dash that transitions); **Mid-Stance Thrust** "Advance forward and **thrust**"; **Sōgetsu
  Ranbu** "Charge forward and slash, with an additional attack on hit"; **Reborn Power** "Take a stance and perform **a
  single horizontal slash**. If it misses, it flows … into a Getsugatensho; on a hit … a Getsuga Jūjishō"; Kikon Getsuga
  Jūjishō; awakened Kikon Gran Rey Cero, Cero Creciente. (Our TSUKIMACHI already follows Syzygy.)
- **Brave Souls** (C, Bleach Wiki "Other Media"): True Shikai's first strong attack is "a Getsuga Tenshō, performed
  exactly as he used it against Candice", the third Getsuga Jūjishō; reiatsu red on the long blade, blue on the short.
- **Heat the Soul** (C): a Getsuga counter that **grabs the attacker with the free hand, shoves them aside, then
  strikes**; Bankai "rapidly slashes all around him" = 天鎖凶牙 Tensa Kyōga. **Blade Battlers 2nd** (C): **Sōga 爪牙** "slide-
  slashes forward with an outwards slash, … a Getsuga … braces him in front"; Issen Getsuga "slashes out a large crescent
  wave in place … then performs another slash to shoot it forward".

---

## 4. Archetypes and the choice

| Archetype | Examples | What makes it read |
|---|---|---|
| **The charge ladder** (coil, hold, drop) | MH Great Sword charge → TCS (B); God Eater Charge Crush (B); DMC Drive; ER charged heavy (C) | a long coiled hold over the shoulder that visibly grows; one drop that ends in the ground; the stop |
| **The momentum maul** | Guts' Dragon Slayer (A); colossal-sword chains (C); DMC "diagonal spinning slash" (B) | the swing passes far through the target; each swing's end is the next one's wind-up; a body spin feeds it |
| **The parked zweihänder** | Siegfried's holds (B); Cloud's shoulder rest (C); Punisher's rooted counters (B) | every strike ends in a readable hold (shoulder, hip, point-down) and the next starts from it |
| **The sword-dragged lunge** | DMC Stinger "dragged by his sword" (B); Braver's leap (B); Cross-slash lunge (B) | the blade leads, the body follows, feet sliding; the arm locked level |
| **Long cuts, short controls** (Niten) | Musashi's crossed chūdan (C); NieR light/heavy sets (B); canon "point the small sword" Getsuga (A) | the short blade forward at the face line catches or pokes; the big one cuts from the side or above |
| **The blade dance** (dual flurry) | MH Demon Dance (B); Starburst Stream (C, A frames); NG dual katana (B/C) | alternating hands, turning, ribbons; the cuts accumulate on the target as marks |
| **The cross** | Oni Giri (A); Starburst's X down / X up (C); Getsuga Jūjishō (A); FF7 凶 (B) | two blades meet on one point in an X; a held cross shape after; a pass-through ending arms-open |
| **The grab-and-cut** | ch. 676 wrist restraint (A); `618Ichigo_grabs` (A); Heat the Soul's grab-Getsuga (C) | the free hand stops the foe, the blade comes from above while he cannot move |
| **The chain whip / reel** | Blood Chains bind (A); GoW Spear of Chaos, chain slam (B) | a cast line, a lagging tapered chain, then the whole body leans back to reel |
| **The phantom echo** | Kessa clones, "delayed strikes" (A); Rashōmon's delayed cut (C) | strikes from where he no longer is; a beat late; ghost bodies |

**The choice (proposal, D, for the user to approve):**
- **Shikai 二刀の斬月 (rushdown)**: **long cuts, short controls** as the grammar of the whole form; J = **the blade
  dance** done with the short blade only (fast, the cleaver parked on the shoulder as a counterweight); K = **the momentum
  maul** with a **charge-ladder** finale (K3); the switched links and the stance's K = **the cross**; SP2 / O = **the
  sword-dragged lunge** into a cross. The cleaver **parks** between strikes (Siegfried / Cloud): on the shoulder, trailing
  level behind (`bl_542`), or point-down.
- **KESSA (one slab, chains, clones)**: **the momentum maul** one-handed for J, two-handed for K with a **charge-ladder**
  K3 wrapped in chains; **the grab-and-cut** for the counter; **the chain whip / reel** for SP1; **the phantom echo** for
  the clones and ZANZŌ. No cross (one blade) and no thrust (no point, canon).

## 5. Impact tricks (演出魄力) a keyframed clip + simple VFX can do

| # | Trick | Source | In a clip / VFX |
|---|---|---|---|
| T1 | **Anticipation coil**: squat and twist away 2–4 f before the swing, bigger for heavier moves; the charge glow grows with the hold | MH charge levels (B), FF7 Cross-slash aura (A `ff7_cross.gif`), Jūjishō's waist coil (A `bl_juji394.gif`) | a `:pose` squash about the feet inside the startup; a rim glow keyed to the startup frames |
| T2 | **Hit pose + hold**: freeze the body 2–4 f on S, longer for K / K3 (×2 on a hit) | MH "lag briefly upon contact" (B), TCS hitstop (C) | a hold key at S; hitstop already exists per hit — scale it by link |
| T3 | **Smear fan**: the arc drawn as a filled half-disc / tapered ribbon for 2–3 f | Berserk ep. 94 speed-line fan (A), SAO ribbons (A), `bl_615` white C-arc (A) | the existing trail ribbon widened to a filled fan for heavy strikes only |
| T4 | **Overshoot and settle**: the blade goes well past the target and ends low, the torso twisted past; then settles back | Berserk ep. 94 (A), MH TCS ends in the ground (C) | keys past S (follow-through 30–60° beyond), a settle key in R |
| T5 | **Ground contact**: crack decal + dust ring when the big blade or a landing hits the plaza | Braver shockwave (B), Clear Lance (C), DMC Helm Breaker (B), ER jump attack (C) | an existing scorch / dust VFX at the tip on S for K3, the pounce, the Breaker |
| T6 | **Camera kick**: a 2–4 f shake along the cut direction on heavy hits | MH TCS (C), SAO GIF (A) | camera impulse on hit, direction = the arc's tangent |
| T7 | **Off hand braced on the spine / flat**: the left forearm or the short blade's guard pressed on the cleaver's back for the heaviest drop and the tackle | MH Guard Tackle "flat side" (B), Dragon Slayer as a shield (B) | left-hand IK target on the cleaver's spine; reads as "two hands" without dropping the short blade |
| T8 | **Shoulder-carry rest**: the cleaver parked on the right shoulder between strikes, idle and walk | Cloud (C), Kenpachi canon carry; Siegfried's holds (B) | idle / walk / recovery pose; every J ends back on the shoulder |
| T9 | **Body spin feeds the big blade**: a 270–360° turn whose last 90° is the cut | DMC Combo A "diagonal spinning slash" (B), Starburst "spins left and uses this momentum" (C), RoS Full Moon (B) | a key every 90° (skill rule), accelerating keys, root yaw + roll |
| T10 | **Short blade parries / points while the cleaver cuts**: the left blade forward at face height through the cleaver's wind-up | Musashi crossed chūdan (C), canon "pointing his smaller sword" (A) | the left arm keyed forward during the right arm's wind-up: the silhouette shows two jobs |
| T11 | **Pass-through, arms-open end pose, delayed wound**: he ends past the foe facing away, blades out, the cut marks bloom a beat later | Oni Giri (A `op_onigiri.png`), Rashōmon (C), Kessa "delayed strikes" (A) | end key with arms in a T; the hit VFX delayed 6–10 f (cosmetic only, the sim hit stays on S) |
| T12 | **Wound marks that linger**: the cross / 凶 / parallel slash marks stay on the target for ~0.5 s | SAO red marks (A), FF7 凶 (B), Jūjishō's held cross (A) | a decal ribbon on the victim at the hit point, fading |
| T13 | **Sword drags the body**: the blade leads a lunge, the feet slide without stepping | DMC4 Stinger (B) | root slide with feet planted (no stride cycle) for SP2 / O / RANGETSU's lunge |
| T14 | **Negative flash / white-out** on the biggest hit (cinematic and Kikon only) | `bl_kessa411.gif` inverted frames (A), SAO white-out (A), Jūjishō (A) | 1–2 inverted frames + white frame; never in neutral play |
| T15 | **Chain reel**: a cast with a lagging, tapered chain, then the body leans back two-handed to pull | GoW Spear of Chaos / chain slam (B), Blood Chains bind (A) | a ribbon with lag (skill red flag: never a straight line for 3 f), lean-back keys on the yank |

**The best eight** for this rebuild: T1, T2, T4, T7, T8, T9, T10, T11 (they live in the clip keys; T3, T5, T6 reuse
existing VFX; T12–T15 are extras).

---

## 6. Motion bars (grade D proposals unless marked)

Hand sets. Shikai: **C** cleaver (right) forehand, **C-b** backhand, **C-flat**, **C+brace** (left hand on the spine),
**S** short blade (left) forehand, **S-b** backhand, **S-pt** stab, **X** both blades. KESSA: **W1** slab one-hand
forehand, **W1-b** backhand, **W2** two hands, **G** free-hand grab, **Ch** chain, **body**. Planes, in his view: horizontal
R→L, horizontal L→R, ↘ (high right → low left), ↗ (low left → high right), ↖ (low right → high left), vertical down,
vertical up, thrust, spin. **Rule: no two strikes of a form share a plane and a hand set.** Read each slot's `:arc` / `:vol`
first (DUEL_ICHIGO §3.2, "v2: built"); reach stays as built unless the user asks for 「跟著動作走」.

### 6.1 Shikai 二刀の斬月

**Idle.** Square to the foe, knees soft, the **cleaver on the right shoulder** (edge up, the blade reaching back), the
short blade **forward in the left hand at chest height, point at the foe's face** (Niten's control blade). (T8, T10;
`bl_542` trailing carry as the walk variant.) **Walk.** Same, the cleaver bouncing on the shoulder. **Run.** Leaning in,
the cleaver **trailing level behind at shoulder height**, the short blade point-down at the left hip (A `bl_542.png`).

| Slot | Archetype | Body in one line | Plane / hands | Source (grade) |
|---|---|---|---|---|
| J1 小牙 KOKIBA | Blade dance | A half-step in, the short blade **flicked level L→R at neck height**, wrist snap; the cleaver stays on the shoulder | horizontal L→R / S | MH DB one-sided slashes (B), NieR light slot (B); D |
| J2 返し KAESHI | Blade dance | The wrist turns, a **rising backhand ↖** from the right hip to above the left shoulder, the hips turning with it | ↖ / S-b | Starburst "uppercut with the left" (C); D |
| J2s 返牙 KAESHI-KIBA (after K1) | Long cuts, short controls | Out of the cleaver's follow-through, the short blade **stabs under it**, trench-knife punch, the left foot stepping through | thrust / S-pt | canon trench-knife short blade (A ch. 555); DMC Pommel/Million Stab (B); D |
| J3 双旋 SŌSEN-GIRI | Blade dance finale | A **full turn** on the left foot, both blades out (cleaver high, short low), keys every 90°, ends square with the cleaver back on the shoulder | spin / X | RoS Full Moon (B), DMC Combo A spin (B), Zoro Tatsu Maki (C) |
| K1 大牙 ŌKIBA | Momentum maul | The cleaver **drops off the shoulder behind**, a step, a **waist-high sweep R→L** that passes 60° beyond the foe, torso twisted past (T4); the short blade held back as counterweight | horizontal R→L / C | Guts ep. 94 (A), colossal-sword sweeps (C), MH Wide Slash (B) |
| K2 昇牙 SHŌGA | Momentum maul | The cleaver's tip **dragged on the ground**, then swung **straight up** in front, the body rising onto the toes; the 4 f hold at the top, blade vertical (as built) | vertical up / C | MH Rising Slash (B), DMC High Time (B) |
| K3 落牙 RAKUGA | Charge ladder finale | The **coil**: cleaver cocked over the right shoulder, the body twisted low, the **left forearm braced on its spine** (T7), the held 3 f with a glow (T1); dropped to the plaza in front, tip into the ground, crack + dust (T5), a long hit hold (T2) | vertical down / C+brace | MH charge → TCS (B/C), God Eater Charge Crush (B), Braver slam (B) |
| K2s 交牙 KŌGA (after J1) | The cross | Both blades **crossed low before the hips**, then scissored **up and out** into an X that opens above the head (the inverse X) | rising X / X | Starburst "the X again from bottom to top" (C), Zoro Toro Samon (C) |
| L / stance L GETSUGA TENSHŌ | Long cuts, short controls | The short blade **points** at the foe (the aim, T10), then the cleaver swung **up and out ↗** one-handed, the crescent peeling off the edge | ↗ / C | canon "pointing his smaller sword" (A); Issen Getsuga (C) |
| Stance 月待 TSUKIMACHI | Parked zweihänder | **Blade forward**: the cleaver level at the right hip pointing at the foe, the short blade crossed over it at the guard (Niten crossed chūdan), weight low on the back foot | — | RoS Syzygy "blade forward" (B), Musashi chūdan (C) |
| Stance J 乱月 RANGETSU | Sword-dragged lunge + blade dance | A 2.4 m slide, feet not stepping (T13), **four short-blade cuts alternating fore / back** (↘, ↗, ↘, level), the cleaver kept back as counterweight; the 4th lands with the body squared | alternating / S | MH Demon Flurry Rush (B), Starburst (C), DMC Stinger drag (B) |
| Stance K 月落 TSUKI-OTOSHI | Charge ladder (pounce) | A 3.0 m **leap**, both blades raised **parallel overhead**, **slammed down together**, both tips into the plaza, the body folded, crack + dust (T5) | vertical down / X | MH Demon Flight "slamming down both blades" (B), Braver leap (B), Clear Lance (C) |
| SP1 月牙十字衝 JŪJISHŌ | The cross | Cleaver **level across the waist** (coil), crouch; the cleaver **sweeps horizontally low**, the short blade **already raised behind the head** comes **straight down**; the two crescents hold as a cross (T12) | horizontal + vertical / C then S | **A** `bl_juji394.gif` 0.5–2.8 s; RoS Reborn Power (B) |
| SP2 双牙 SŌGA | The cross (pass-through) | Vanish; reappear mid-slide, blades **crossed over the chest**, a **descending X** through the foe as he **passes**; ends behind, back turned, **arms flung open** (T11) | descending X / X | **A** `op_onigiri.png` + Oni Giri text (C), Gokuraku Anyō Rashōmon (C), Blade Battlers Sōga slide (C) |
| I Breaker 峰打ち MINEUCHI | Charge ladder (tackle) | A low dash, the **left hand flat on the cleaver**, the **flat** slammed sideways L→R at hip height like a door (MH Guard Tackle), dust off the impact | horizontal L→R / C-flat | MH Guard Tackle, Side Blow (B), Guts' "broad side to squash" (A/C) |

Check: J1 L→R S, J2 ↖ S-b, J2s thrust S-pt, J3 spin X, K1 R→L C, K2 up C, K3 down C+brace, KŌGA rising X, Getsuga ↗ C,
RANGETSU alternating S (a multi-cut unit), TSUKI-OTOSHI down X, JŪJISHŌ horizontal C + vertical S (a composite; its first
beat resembles K1's plane but is low and level with no step-through), SŌGA descending X, MINEUCHI L→R C-flat. Unique.
**O 十字 JŪJI** shares `:ic-cross` with KŌGA today; a free slot is a **double thrust X** (both blades level like horns after
the flash step: Zoro's Ushi Bari, C) — only if its 140° arc is narrowed or the thrust is honest within it (read `:arc`).

### 6.2 KESSA 血鎖の一護

**Idle.** **A** `bl_ep411.png`: upright, the slab **hanging low in the right hand, the sheared tip angled down across the
front of the legs**, arms slightly out, chains drifting off the wrists, neck and ankles; barefoot. **Walk.** Slow, the slab's
tip almost touching the plaza, black flame footprints (A). **Run.** Leaning forward, the slab trailing low behind,
afterimage clones peeling off (A "remnants … in locations he steps in").

| Slot | Archetype | Body in one line | Plane / hands | Source (grade) |
|---|---|---|---|---|
| J1 板薙 ITA-NAGI | Momentum maul (one hand) | From the hang, the slab swung up and over into a **short one-hand chop ↘** from the right shoulder, the weight pulling the shoulder down after | ↘ / W1 | Guts one-hand (A `bk_btp.png`); D |
| J2 返板 KAESHI-ITA | Momentum maul | The chop's end rebounds into a **rising backhand ↗**, the hips snapping back | ↗ / W1-b | MH no-repeat chain (B); D |
| J3 板旋 ITA-SEN | Momentum maul finale | A **full turn**, the slab at arm's length level, the last 90° the cut, chains flaring outward with the spin | spin (R→L) / W1 | Dragon's Dogma Arc of Might (B), DMC diagonal spinning slash (B) |
| K1 大板 ŌITA | Momentum maul (two hands) | Both hands on the grip at the left hip, a **baseball-bat sweep L→R** at waist height, the follow-through wrapping round his back (T4) | horizontal L→R / W2 | DMC Dance Macabre "like … swinging a baseball bat" (B), Guts (A) |
| K2 昇板 SHŌ-ITA | Momentum maul | The slab **dragged** behind on the plaza, then **up through vertical**, both hands, the body leaving the ground a little | vertical up / W2 | MH Rising Slash (B), DMC High Time (B) |
| K3 天鎖落 TENSA-OTOSHI | Charge ladder | Raised **horizontal overhead in both hands, the blade reaching back** (Berserk ep. 94 wind-up); the **chains wind round the slab** during the hold (the tell, T1); the drop to the plaza, crack, chains snapping taut, long hold (T2, T5) | vertical down / W2 | **A** `bk_e94.png` panel 1; MH TCS (C); GoW chain slam (B) |
| L 鎖盾 KUSARI-TATE (parry) | Chain guard | Chains **whirl up** from the wrists into a disc in front, the slab hanging still; no swing | — / Ch, body | canon chains "defend against attacks" (A); Siegfried Guard Impact holds (B) |
| Counter 残月返し ZANGETSU-GAESHI | Grab-and-cut | The chain **pulls** the foe in, the **left hand clamps their wrist**, the slab raised one-handed and brought **straight down** | vertical down / G + W1 | **A** `bl_676.png`, ch. 676 text; Heat the Soul grab-Getsuga (C) |
| SP1 鎖引 KUSARI-BIKI | Chain reel | The left arm **casts** the chain forward like a throw, it **lags and tapers** in flight (T15); on catch he **leans back** with both arms and reels | thrust (cast) + reel / Ch | GoW Spear of Chaos (B), canon bind (A) |
| Clone heavy 影断 KAGE-DACHI | Phantom echo (maul) | A clone in place: the slab **over the right shoulder in both hands, a big ↘ two-handed diagonal** (Berserk's passed cut), ends low past the foe | ↘ / W2 | **A** `bk_e94.png` panel 2; canon clones (A) |
| Clone light 影薙 KAGE-NAGI | Phantom echo (snap) | A clone: a **one-hand backhand level L→R** flick at chest height, no step | horizontal L→R / W1-b | canon "strike from multiple directions" (A); D |

Check: J1 ↘ W1, J2 ↗ W1-b, J3 spin W1, K1 L→R W2, K2 up W2, K3 down W2 (+ chains), counter down G + W1, SP1 Ch, clone
heavy ↘ W2, clone light L→R W1-b. Unique. The clones get **their own clips** (today they borrow the Shikai's `:ic-f1` /
`:ic-drop` and KESSA's J clips — the skill's red flag); their second links (`:ic-drop`, `:ic-k-wrap`) could reuse K3 /
J3 at the clone's alpha since those are KESSA's own. O 影討 KAGE-UCHI (a vertical cut after the rush) and SP2 残像 ZANZŌ
(echoes of his own clips) need no new strike plane.

## 7. Gaps
- **No video watched.** MH World / Wilds bodies (charge pose, TCS's first hit, Tackle), Elden Ring and NG2 are C/D from
  memory. Close: watch a MH Wilds GS tutorial and a RoS TYBW Ichigo combo video and log wind-up / S / hold frames.
- **RoS strings have no poses** (Moonlight "wide slashes with both blades", Full Moon "spinning slash while advancing"):
  close with the RoS TYBW Ichigo trailer at full frame rate.
- **Canon choreography of the dual Shikai is thin**: Jūjishō (A, GIF) and the grab (A, stills) are the only beats seen; J,
  K and the stance strings are D proposals built on game archetypes.
- **Hand**: canon carries the cleaver on the back and the short blade on the right hip; the anime GIF holds the cleaver in
  the right hand. The game's right-cleaver / left-short is kept; confirm if the user wants it swapped.
- Nioh, Tales, Xenoblade, KH Roxas move bodies not fetched; Siegfried's hold poses are C (memory).
- **Measure before drawing** (skill rule): the big overshoots (K1, KESSA K1, the clone heavy) must still put the tip on
  the hit volume at S (FK ±0.15 m); presentation-only unless the user asks for reach to follow the motion.

## 8. Sources and images
- MH: monsterhunter.fandom.com `Great_Sword`, `Dual_Blades`, `MHRise:_Switch_Skills`; monsterhunterwiki.org
  `MHWilds/Great_Sword_Mechanics` (quotes the official controls).
- DMC: devilmaycry.fandom.com `Rebellion`, `Stinger`, `Agni_&_Rudra`. FF: finalfantasy.fandom.com `Braver`, `Omnislash`,
  `Cross-slash_(Final_Fantasy_VII)`, `Omnislash_(Final_Fantasy_VII)`, `Punisher_Mode`.
- Soulcalibur: soulcalibur.fandom.com `Siegfried`, `Chief_Hold`, `Side_Hold`, `Base_Hold`, `Reverse_Side_Hold`, `Nightmare`.
- Berserk: berserk.fandom.com `Guts`, `Dragon_Slayer`. NieR: nier.fandom.com `Weapons_(Automata)`, `Virtuous_Contract`.
  God Eater: `Buster_Blade_(God_Eater_3)`. Dragon's Dogma: `Warrior`.
- SAO: swordartonline.fandom.com `Starburst_Stream`, `Dual_Blades`. One Piece: onepiece.fandom.com `Santoryu`,
  `Nitoryu` (Three / Two Sword Style). Ninja Gaiden: `Dual_Katana`. God of War: `Blades_of_Chaos`. KH: `Roxas`,
  `Oathkeeper_&_Oblivion`, `Synch_Blade`.
- Niten: Wikipedia `The_Book_of_Five_Rings` (one API call before the rate limit); https://kampaibudokai.org/NTIkatas.htm;
  https://nitojuku.com/articles/musashi-chudan-no-kamae.html.
- BLEACH: bleach.fandom.com `Ichigo_Kurosaki`, `Ichigo_Kurosaki/Other_Media`; RoS strings:
  https://resource-of-souls.com/characters/ichigo-kurosaki-thousand-year-blood-war.

| File (`.refs/ichigo-style/`) | What | Used for |
|---|---|---|
| `bl_juji394.gif` (+ `sheet_juji*.png`) | anime Getsuga Jūjishō, 24 s, 190×108 | SP1 body order (A) |
| `bl_getsuga394.gif` (+ `sheet_getsuga.png`) | the shout close-up, then the wave from afar | the shout as a tell; no body shown |
| `bl_kessa411.gif` (+ `sheet_kessa*.png`) | Blood Chains Getsuga, 41 s | inverted frames, white-out, C moon, rest silhouette |
| `bl_ep411.png`, `bl_542.png`, `bl_615.png`, `bl_618.png`, `bl_676.png` | KESSA rest; Shikai carry; C-arc; grab; wrist restraint | idle / run / counter (A) |
| `bk_e94.png` (+ `_small.jpg`), `bk_btp.png` | Berserk ep. 94 kill; one-hand hold | K3 / clone heavy / K1 overshoot (A) |
| `ff7_cross.gif` (+ sheet) | FF7 Cross-slash limit | aura coil, three cuts (A, low-res) |
| `sao_ss.gif` (+ sheet) | Starburst Stream, anime | ribbons, lingering marks, white-out (A) |
| `dmc3_sting1.jpg`, `op_onigiri.png` | Stinger pose; Oni Giri after-pass | lunge, arms-open end (A) |
| could not see | MH / ER / NG / NieR animations, RoS Ichigo, Wikimedia Musashi portrait | fetch refused or no video |
