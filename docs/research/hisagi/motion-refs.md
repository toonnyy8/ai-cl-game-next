# Shūhei Hisagi: motion references for the Shikai and Bankai clips

Research pass 2026-10-17, for `duel-motion-style` (DUEL_HISAGI §20). Use: the model-sheet stills, then the slot plan the
user approves, then the clips, one form at a time (the Shikai first, its look before its strikes). Canon facts, the
Bankai's rules and the first image set: `notes.md` (same folder). Format follows `docs/research/ichigo-rework/` and
`docs/research/yamamoto-rework/motion-refs.md`.

**The user's decisions this pass works under (U, DUEL_HISAGI §20, 2026-10-17).** Style 「A 原作神態＋自創招式」: canon for
stance and habits, invented strikes (graded D, labelled proposals). The bar, all four: God of War's Blades of Chaos,
real kusarigama-jutsu, the rope dart / meteor hammer, Rebirth of Souls' Hisagi. Order: one form at a time, the look
before its strikes. 「距離跟著動作走」: the drawn motion sets the hit volumes (a gated sim change). B2a's clips and the
large yellow blade are placeholders (§19 D7).

**Grades.** **A** canon: a manga still I looked at (file named), or the wiki's battle / episode page with its chapter or
episode cite (**A (via C)** when only the summary was read); "anime" marks anime-only scenes, "filler" the Zanpakutō
Unknown Tales arc. **B** official game text or art (Bandai Namco's RoS page, the RoS in-game strings, Brave Souls
skill text). **C** secondary (Wikipedia, the God of War wiki, practitioner lesson pages, news). **C (memory)** = a
well-known game I describe from memory, no page read. **D** my inference or proposal. **U** a user decision.

**Fetch notes.**
- bleach.fandom.com: the MediaWiki API with curl (`action=parse&prop=wikitext`, `action=query&list=allimages&aiprefix=…`
  to find the manga's digital-colour panels by chapter, `prop=imageinfo` for the URL, then `&format=original`; the
  `path-prefix=en` is already in the returned URL). Same for godofwar.fandom.com.
- Wikipedia: its API answers 429 to curl; the plain `/wiki/<title>` page with a browser User-Agent works (text
  extracted with a stdlib HTML parser).
- RoS: the data-mine site moved to "Neo Resource of Souls" (`https://www.resource-of-souls.com/characters/shuhei-hisagi`);
  its move strings are in the page's embedded Next.js data. The official JP page
  (`https://bleach-ros.bn-ent.net/character/?chara=shuhei-hisagi`) now returns its text (it rendered empty for
  `notes.md`). YouTube pages answer with Google's "sorry" captcha; only oEmbed titles and thumbnails came through.
- The wiki's GIF `Kubikake.gif` (190×108, 25 fps, 475 frames, 19 s) read as a frame sheet every 0.48 s. It is an edit
  with cuts, so it gives the order and the poses, not real timing. No full episode and no game video was watched.

**New since `notes.md`.**
- **The weapon's proportions** (§4.1): the rod is ~0.9–1.0 m, not ~0.5 m as DUEL_HISAGI §11.1 assumed; the chain fixes
  to the rod's butt; the sealed scabbard stays in his sash after the release (ch. 324–325 stills).
- **RoS's official JP text** (B): SP2 戦士の心構え counters by going behind the opponent and following with 綴雷電;
  閃撃 changes in the Shikai to give mid-range attacks.
- **Kazeshini's structure is a double meteor hammer**: two heads on one chain, one striking while the other stays in
  hand as the guard (C). This is the grammar of the whole Shikai: one sickle out, one in hand (§2.3).

---

## 1. Canon manner, fight by fight

### 1.1 vs Findorr Calius (ch. 319–325; anime Ep216, 218, **219**; A)
- **Sealed for most of the fight**: a swordsman blocking a lieutenant-level blade (ch. 322, 324). Anime-only: he
  pushes off a lamppost to fly back in, and **slides on the ground to slash at Findorr's legs** (Ep219, A anime). He
  tries Shunpo behind Findorr for a downward cut and Findorr catches his wrist (Ep219).
- **Armband bomb, then Bakudō #62 Hyapporankan** pins Findorr to a wall (ch. 324 pp. 11–13; `219Findorr_and_armband.png`).
- **The release**: trapped in a water bubble, "Reap, Kazeshini" (刈れ, ch. 324 p. 19). In the anime the burst of
  Reiatsu blows the water away (Ep219). The reveal pose (`324Hisagis_Shikai_Kazeshini.png`, seen): **the right arm
  straight out at shoulder height, the right sickle's rod level and pointing at the enemy; the left sickle hangs from
  the relaxed left arm, rod pointing down-forward, blades near the shin; the chain loops between them to the ground**.
  The face is calm, eyes narrowed.
- **"I hate it"** (ch. 325 pp. 3–4): he looks at the blades while he says their shape is "made for reaping lives"
  (`325Hisagis_Shikai_Kazeshini.png`, seen: standing tall, both rods held low and forward, blades crossed in an X in
  front of his legs, chain slack behind).
- **The attack sequence** (ch. 325 pp. 7–18):
  1. A cut under Findorr's eye, a swing that wrecks the building behind him.
  2. Shunpo behind him and **a downward swing**; Findorr blocks with his arm (`325Hisagi_and_Findorr_clash.png`, seen:
     airborne above Findorr, **the right fist grips the rod at the butt and drives the blade down-forward, the left arm
     high behind him holding the chain**, which trails up out of the panel).
  3. Findorr swings at his face; **he drops away, falling backward**, and as Findorr follows **he pulls the chain down
     so the other sickle hits Findorr from behind** (`325Hisagi_evades.png`, seen: leaning far back, mid-fall, the
     right arm pointing at Findorr, **the left hand low behind the hip hauling the chain**; the thrown sickle sits
     behind Findorr).
  4. **"Can you read its movements? Are you scared?"**, swinging Kazeshini overhead (`325Hisagi_overwhelms.png`,
     seen: one hand raised above his head working the chain, the other low; the next panel is his face behind a
     whirl of speed lines). In the anime he asks it **sitting on a lamppost** above Findorr (Ep219, A anime).
  5. **He swings backward** and the sickle splits Findorr's arm lengthwise (`325Kazeshini_severs.png`, seen: the blade
     edge-on as a spinning disc; `325Hisagi_kills.png`, seen: on a rooftop, **the whole arm swept back and up behind
     him, the chain a long arc to the blade**, which passes through the arm).
  6. **Appears behind** Findorr and finishes him with a swing (ch. 325 p. 18). Anime: he **parries a Cero so it splits
     around him and throws Kazeshini through Findorr's head** (Ep219, A anime).
  7. After: standing on a broken pillar, **one rod held level at arm's length, the chain lofted in a loop above him,
     the other sickle in the air at its end** (`325Hisagi_stands.png`, seen): a win / intro pose.
- Anime summary line: he alternates "flinging his Zanpakutō at his opponent" with Hyapporankan (Ep219, A anime).

### 1.2 vs Ayon (ch. 336–337; Ep225; A)
- **Ties Ayon up** by the neck from outside the fight (ch. 336 pp. 14–19; `336Kubikake.png`, seen: several turns of
  chain round the neck and an arm). He stands holding **the chain over his right shoulder like a rope, the fist at
  his chest** (`336Hisagi_and_Izuru_intervene.png`, seen).
- **Kubikake, the haul**: he pulls and Ayon falls (ch. 337 pp. 5–7). `337Kubikake1.png` (seen): **crouched, the right
  arm raised over his head gripping the chain, the chain running over his shoulder**, the whole back bent into the
  pull. `337Kubikake.png` (seen): Ayon face-down on the roof, Hisagi standing, the chain held low in one hand.
- **Restraint at range**: `337Hisagi_restrains.png` (seen, from behind): feet apart, **both arms out low and wide**,
  chains running from each hand to Ayon; a sickle whirls between them as a blurred disc.
- **Hadō #11 Tsuzuri Raiden through the chain** (ch. 337 p. 8): "deciding to be cautious … attacking from a distance".
  `337Tsuzuri_Raiden.png` (seen): **the right hand holds the rod level at the hip, the left hand holds the chain taut
  above the shoulder**; lightning runs along the chain. Anime `Ep225TsuzuriRaiden2.png` (seen): the same split, the
  left fist raised at face height on the chain, the rod across the body, lightning crackling on the rod.
- **Anime Kubikake** (Ep225; `Kubikake.gif` frame sheet, t = seconds into the clip; the GIF is an edit, so the order
  counts, not the times):

| t (s) | What happens |
|---|---|
| 0–1.0 | Airborne, **one arm up whirling the sickle overhead on a short chain**, the other low |
| 1.4–2.4 | The release: the sickle flies **spinning flat, drawn as a ring / disc** |
| 2.9–4.8 | It wraps the neck: several coils, the chain snaps taut |
| 4.8–7.2 | Close-ups: his arm swings across, the fist clenched on the chain, the hauling face |
| 7.7–8.2 | He hangs at the far end of the taut chain, mid-air |
| 11.5–13.0 | **Ayon lifted into the air** by the neck (`Ep225Kubikake.png`, seen) |
| 13.4–14.9 | **The heave**: torso twisted, the arm swept from high behind over the shoulder down to the front |
| 15.4–18.7 | The slam: the chain straight up out of a dust cloud (`Ep225Kubikake3.png`, seen) |

- Ayon breaks the chains and grabs him; Iba and Yamamoto intervene (ch. 337).

### 1.3 With Komamura vs Tōsen (ch. 367–368, 383–387; Ep280, 289–291; A)
- **Entrance**: Tōsen's sword is entangled by Kazeshini's chain (ch. 367 pp. 16–19). `367Hisagi_intervenes.png`
  (seen): **feet wide, the right arm extended forward-left at shoulder height holding the chain taut, the left hand
  low holding the other rod point-down, the blades by the floor, the chain coiled loosely between**. Anime
  `Ep280HisagiEntersBattle.png` (seen): the same, from behind; the chain runs straight to Tōsen's blade. Tōsen frees
  the sword by vibrating it (ch. 368).
- **Kubikake from behind** (ch. 384 p. 12): "a chain wraps around his neck pulling him back and slamming him into the
  roof" (`384Kubikake.png`, `384Kubikake2.png`, `384Kubikake3.png`, seen: the chain round the neck from behind, Tōsen
  flying backward, a long chain arc in the sky, the roof cracking).
- **The pin** (ch. 384): `384Hisagi_pins.png` (seen): **kneeling over Tōsen, one hand pressing him down by the
  throat, the other fist raised high holding the sickle, blade pointing down at him**. He explains "never use
  excessive force". Tōsen stabs him and throws him off the roof.
- **The final blow** (ch. 386 pp. 17–19): standing on the transformed Tōsen's back, he stabs the **sealed** sword
  down through the head, then **releases Shikai inside the wound**, the blades bursting out through the mouth
  (`386Hisagi_impales.png`, seen: a crouched silhouette, both hands on the hilt, the chain hanging from above).
- Tōsen's lesson in the same chapter (ch. 384 pp. 15–18): "on the inside, I'm always taking a half-step back" (A).

### 1.4 The Kazeshini spirit (anime filler Ep230–265; A filler)
Filler, but the only long animated Shikai-vs-Shikai fight; it shows how the anime staff move these weapons.
- The spirit (`Kazeshini_Full_Body_ep260.png`, seen): crouched, long hair, a sickle held high over the shoulder; red
  outline, grey cloth strips. "Frequently attacks from several different angles, and has great control over where his
  kusarigama go when he throws them"; "can control the paths of the kusarigama by pulling on their chains"; "wrapping
  one of them around [the opponent's] weapon"; Hisagi "notes Kazeshini's style of fighting is very similar to his own"
  (wiki, Ep234, 260, 265).
- Ep234: the thrown kusarigama **curve around and come up from under** Hisagi. Ep235: Hisagi blocks one, **the other
  smashes through a tree and cuts his back** (two heads, two angles). He holds a kusarigama **in front of his face**
  ("look at its shape").
- Ep260 (`Shūhei Hisagi vs. Kazeshini: Final Fight`):
  - Hisagi **embeds one kusarigama in a tree and swings up to a branch, then pulls it back** (a grapple swing).
  - **Deflects a kusarigama with his own** (`260Hisagi_deflects.png`, seen: airborne, arms flung wide, sparks where
    the blades meet). **Elbows** Kazeshini in the chest after a Shunpo.
  - Kazeshini **spins his kusarigama, then throws**; Hisagi leans aside, the kusarigama **returns** and he blocks it.
  - Kazeshini **pulls the chain so the blade embeds in the enemy's back, then stabs the other kusarigama in** by hand.
  - The end: Hisagi **leaps and slashes him down the chest**; `260Hisagi_slashes.png` (seen): **a deep low lunge past
    him, the front knee bent, one rod swept up behind, the other low**; `Kazeshini_fights_Hisagi.png` (seen): airborne,
    both fists on one rod held across the body as a bar, chains whirling.
  - `235Hisagi_jumps.png` (seen): airborne, one arm forward with a rod, the thrown sickle stuck in the ground behind.

### 1.5 TYBW (ch. 495–635; anime TYBW 4–33 = Ep370–399; A)
- vs Driscoll (Ep370–371): Shikai, overwhelmed; `Ep370DriscollConfrontsHisagi.png` (seen): the TYBW look (§4.2).
- vs Mask De Masculine (ch. 559–560; Ep382–383): **wraps Kazeshini round Mask's leg**; Mask pulls him in and
  clotheslines him (`Ep383MaskClotheslinesHisagi.png`). The leg wrap is a rope-dart move in canon (A).
- Under PePe's Love (ch. 595; Ep389): `Ep389ByakuyaBlocksHisagi.png` (seen): **a straight one-armed thrust with the
  rod, the arm locked level, the blades crossing in front of Byakuya's face**; `Ep389HisagiAttacksByakuya.png`: rapid
  cuts with Kazeshini and the sealed Senbonzakura.
- Black creatures (Ep397): Shikai, the chain mid-swing in the background (`Ep397IkkakuHisagiStruggle.png`).
- Sniped by Lille Barro (ch. 635; Ep399): `Ep399HisagiShot.png` (seen): **knees buckling, back arched, arms thrown
  back**: a hit-reaction reference, and the canon intro for the Lille pairing.
- No Bankai in the manga or the TYBW anime (notes §2.7).

### 1.6 Can't Fear Your Own World (novel III ch. 22–24; A (via C), no text read)
- vs Tokinada (ch. 23): **the chain blocks every blade** of a copied Benihikō; the sickles are too fast for a copied
  Wabisuke; **the sickles deflect every Senbonzakura petal and take Tokinada's arm in the same motion**; he **hides
  Kazeshini inside a Reiatsu-concealing cloak** for an ambush.
- vs Hikone (ch. 24): binds Hikone with the chains; is cut apart over and over, **standing and not resisting**, while
  the chain pulls him together; "consistently aims for Hikone's vital points without injuring them".
- **The Bankai release**: both scythes thrown up, the chains twist into a whirlpool overhead, a black wind bursts
  out, the scythes **fall back into his hands**, his own chain wraps him; **raising one blade tightens the noose round
  both necks** (notes §2.3–§2.4).
- The novel illustration (`Hisagi_s_Bankai_CFYOW.png`, seen): standing straight and still, **arms hanging, a single
  long crescent in each hand pointing down, chains pooling round his feet, a thick twisted rope of chain rising from
  his neck straight up** to a tangle at the top of the page; a body lies at his feet.

### 1.7 Signature habits (graded)

| Habit | Grade | Evidence |
|---|---|---|
| **One sickle in the hand, the other out**: the hand that keeps a rod cuts, the other hand works the chain | A | ch. 325 clash and evades stills; ch. 337 Tsuzuri Raiden; ch. 367 |
| **The reveal / ready pose**: one rod pointed level at the enemy at arm's length, the other hanging point-down by the shin, the chain looping to the ground between | A | `324Hisagis_Shikai_Kazeshini`, `367Hisagi_intervenes`, `Ep280HisagiEntersBattle` |
| **The overhead whirl before a throw**, one arm raised, "are you scared?" | A | ch. 325 (`325Hisagi_overwhelms`), Ep225 GIF 0–1.0 s |
| **The sickle in flight spins flat, drawn as a disc / ring** | A | `325Kazeshini_severs`, Ep225 GIF 1.4–2.4 s, `337Hisagi_restrains` |
| **Drop and pull**: he falls / sinks away and hauls the chain low so the out sickle returns into the enemy's back | A | ch. 325 (`325Hisagi_evades`), Ep219; the spirit does the same (Ep260) |
| **The backward swing**: the arm swept back past his body, the long chain carrying the blade through the target | A | ch. 325 (`325Hisagi_kills`) |
| **Neck, then over-the-shoulder heave, then slam** (Kubikake) | A | ch. 336–337, 384; Ep225 GIF |
| **The chain over the shoulder like a hawser**, the fist at the chest | A | `336Hisagi_and_Izuru_intervene`, `337Kubikake1` |
| **Ensnares weapons and limbs**: Tōsen's sword, Ayon's neck and arm, Mask's leg | A | ch. 336, 367, 559–560 |
| **Kidō down the chain** (Tsuzuri Raiden): one hand high on the taut chain | A | ch. 337, Ep225 |
| **Kneels on the pinned enemy, blade raised, a hand at the throat**; never excessive force | A | `384Hisagi_pins`, ch. 384 |
| **Appears behind** with Shunpo for the finishing cut | A | ch. 325, Ep219 |
| **A low sliding slash at the legs** | A anime | Ep219; RoS's SF "Sliding" (B) |
| **Deep low lunge past the enemy** | A filler | `260Hisagi_slashes` |
| **Looks at his blade** with distaste; holds it in front of his face | A | ch. 325 pp. 3–4; Ep219 `Ep219HisagiShikaiIntimidation`; the spirit, Ep235 |
| **Fights sealed first**, releases only when cornered; the release itself can be the blow | A | ch. 324, 386 |
| **Takes the hit standing** (CFYOW; the Bankai) | A (via C) | CFYOW III ch. 24 |
| **"A half-step back"** (inner, a quote, not a drawn pose) | A quote / D as a pose | ch. 384 p. 15 |
| **Holds the chain short** | B-ish | Kubo, Klub Outside Q&A #397 (notes §1.1) |
| The sealed scabbard **stays in his sash** after the release | A | `324…`, `325Hisagis_Shikai_Kazeshini` |

---

## 2. The reference archetypes

### 2.1 God of War's Blades of Chaos (C: godofwar.fandom.com `Blades of Chaos` move lists; C (memory) for the bodies)
- **The weapon**: two blades with chains seared into Kratos's forearms; "the chains would stretch out for a set
  distance with each attack" (wiki). So the reach is the chain's, and the body stays near the centre.
- **Greek-era lists** (GoW 2005, Chains of Olympus, Ascension; C):
  - **Plume of Prometheus** (□ □ △): "a quick and powerful combo ending in an explosive / fiery finish". Body (C
    memory): two alternating lashes, left then right, then both blades swung up and slammed down in front.
  - **Cyclone of Chaos** (L1 + □, also in the air): "Kratos swings his blades around him multiple times" / "360 spin
    attack". Body (C memory): arms out, the blades on full chain whirled flat round the body while he turns.
  - **Orion's Harpoon**: "throws out his chain to harpoon an opponent" (Ascension R1); "launch an enemy and tap ○ to
    slam them back to the ground" (GoW, CoO).
  - **Rampage of the Furies** (L1 + ○): focused multi-hit on one enemy; with the Blades "diagonal slashes" (wiki trivia).
  - **Tartarus Rage**: "swing your blades down onto multiple enemies, launching them" (CoO).
  - **Hyperion Might** (hold □): "slash your blades in an arc".
- **Norse era** (GoW 2018, Ragnarök; C):
  - **Spear of Chaos** / **Hyperion Pull**: "impale an enemy and yank them towards Kratos"; airborne enemies "are
    instead slammed to the ground".
  - **Blazing Surge** / **Elemental Surge**: "send a fiery pulse down a chain" after impaling: the same idea as canon
    Tsuzuri Raiden through the chain (ch. 337).
  - **Hyperion Grapple**: holding after the pull "launches Kratos forward towards grounded enemies": he zips along
    his own chain.
  - **Whirling Chaos** (hold R1): "strikes all enemies around Kratos"; **Chaos Slam** (sprint R2): "leap into the air
    and perform a powerful chain-slam attack"; **Plume of Chaos**: a heavy finisher added to the light string.
  - **Flame Whiplash** (Ragnarök): a charge that ends in **Scorched Sweep** (a sweep) or **Scorched Earth** ("spike
    the blade downward").
  - Light R1 (C memory): alternating arm lashes straight out on the chain and snapping back; heavy R2: both blades
    swept in wide flat arcs round him.
- **What makes it read**: the hands stay at the body and the blades travel on long lagging chains; every lash has a
  whip-crack snap at full extension and a fast retract; the torso twists hard behind each arm; finishers lift both
  blades and bring them down together; the harpoon and pull lean the whole body back.

### 2.2 Kusarigama-jutsu (C: Wikipedia `Kusarigama`, `Kusarigamajutsu`, `Isshin-ryū kusarigamajutsu`, `Shintō Musō-ryū`; ja.wikipedia `鎖鎌`)
- **Three parts**: kama (sickle), kusari (chain), fundo (weight). Kamajutsu, kusarijutsu and fundōjutsu combine.
- **The canonical attack**: "swinging the weighted chain in a large circle over one's head, and then whipping it
  forward to entangle an opponent's spear, sword, or other weapon, or immobilizing their arms or legs. This allows the
  kusarigama user to easily rush forward and strike with the sickle."
- **Two rigs** (en and ja wiki):
  - chain on the sickle's **head**: one hand, small sickle, short chain; the weight swung one-handed while measuring
    the distance;
  - chain on the handle's **butt** (Kazeshini's rig, §4.1): two hands, bigger sickle, chain 2–4 m; a few tens of cm of
    hanging chain **spun to build speed, then thrown in a straight line, like a sling** (ja: 「数十cmほど垂らした鎖を回転
    させて勢いをつけたうえで直線的に投げつける、スリングによる投石に近い」).
- **The re-arm cost** (ja): once thrown, the weight takes "a very long time" to be reeled in and swung up again, so
  the schools drill close combat with the sickle for when the weight misses (「鎖分銅をかわされた場合の…接近戦戦闘法を
  繰り返し稽古」). This is H2's out-of-hand window, and the reason J must work one-handed (§3).
- **Targets** (ja): the weight at the head, face, shins and wrists; the chain knocks the weapon down or wraps the
  wrist or foot; **the sickle, in the left hand, delivers the finish** (「左手に持った鎌刃で…とどめを刺す」).
- **Isshin-ryū** (in Shintō Musō-ryū; C): a straight double-edged 30 cm blade on a 36 cm handle with a guard, a
  3.6 m chain on the handle's bottom. The blade "strikes, slashes or thrusts at … neck, hands, wrists and solar
  plexus", **catches the sword between blade and guard**, and is used **"upside down"** too (ja: held reverse-grip,
  逆手); **the hardwood handle strikes, thrusts, blocks and parries**; the chain is "swung as a flail and used to
  ensnare the opponent's sword, limbs or even the body"; "in some kata the weight is deployed to strike the
  opponent's body, including the head, back and hands"; non-lethal kata "trap and apprehend a swordsman". 30 kata in
  Omote, Kage and Oku series (names only: e.g. Furikomi ichimonji, Furikomi jūmonji).
- **Space**: Yamada Shinryūkan was killed in a bamboo grove where he could not swing the chain (en wiki): the
  kusarigama needs open space around the body. (The game's arena is open; the windmill's r 2.0 fits.)
- Grades for the body details: the figure-eight weight pattern appears only on a weak site (C low); the
  hand-over-hand reel is my reading of 巻き取り (D). Real kata choreography is a gap (§6).
- **What makes it read**: the sickle hand stays guarded at the body while the chain hand works far out; the weight is
  always moving (circles, then a straight cast); a wrap freezes the opponent for a beat; the sickle cut comes in
  right after the entangle; the chain hand reels while the feet close in.

### 2.3 Rope dart and meteor hammer (繩鏢 / 流星錘; C: en Wikipedia `Rope dart`, `Meteor hammer`; zh Wikipedia `繩標`, `流星錘`; Home of Poi lesson index)
- **Rope dart**: a metal dart on a 3–5 m rope. "Play consists of spinning, shooting, and retrieval. One end … held
  in or tied to the non-dominant hand to serve as an anchor, while the dominant hand is used to guide the rope, often
  moving along the length … the user not only uses both hands, but their arms, legs and neck … using momentum of the
  dart to **wind the rope around specific body parts** … then carefully timing a release to send the dart flying out
  in a straight line, followed quickly by retrieval" (en wiki). zh: thrown "用臂腕的抖甩之勁" (a shaking flick of the
  arm and wrist), "發出後又可立即收回" (retrieved at once), the rope wound on the chest and waist when carried. A wushu
  page: "the practitioner appears to be tying themselves up, and the dart suddenly shoots toward the opponent"
  (flashmavi.com, C).
- **The wrap catalogue** (Home of Poi rope-dart lesson index, C; names only, videos not watched): kicks, throws,
  **elbow shoots** ("twining, wrapping, and shooting … over various planes", lead and anchor elbow), **neck wraps**,
  hybrid wraps, **body wraps**, **leg twines**, **knee shoots**, hooks, stalls, dodging.
- **Meteor hammer**: a weight on each end, or one. "Swinging the weight around the body to build up angular momentum,
  and then striking … If the weight swings around the intended target … the long length of chain may wrap around the
  target's body, limbs, or weapons" (en wiki). **Double meteor: "one may use one head offensively while using the
  other to defend"**; the *Wubei Zhi* calls the thrown head 正鎚 and the held one 救命鎚 "the life-saving hammer" (zh
  wiki). Ropes 1.6–2.6 m (zh) to 6 m (en, single).
- **"Flowers"**: the figure-eight spins (舞花) are standard wushu vocabulary for flexible weapons; no page I could read
  describes them, so the term is D here.
- **What makes it read**: the body turns *inside* the line; a wrap round the elbow, knee or neck shortens it and
  redirects it, and the release flies off on a new line; the anchor hand never lets go; one head is out while the
  other is held.

### 2.4 Rebirth of Souls' Hisagi (B: the official JP page; the in-game strings in the data-mine; patch 1.10)
- **Official JP page** (fetched 2026-10-17):
  - Overview: 「動作中に飛び道具を無効化する特殊閃撃や飛び道具を相殺しやすい己有技など、飛び道具に対して高い対応力を持っている」
    (strong against projectiles: a Special Flash that ignores them while it moves, and a signature that cancels them
    easily); 「攻撃力は控えめなものの扱いやすく優秀な技が多い」; 「長期戦で本領を発揮する」. Tags:
    「斬拳走鬼全てに長けたオールマイティ」, 「恐怖を受け入れ強くなる九番隊副隊長」. Ease of use ★★★.
  - 己有技 **破道の五十八『闐嵐』**: 「前方に竜巻を起こして攻撃する。攻撃範囲は狭いが、持続が長く、接近して来る相手の迎撃に適した技」
    (a tornado in front, narrow but long-lasting, for meeting an opponent coming in); hits and range grow with Fear.
  - 霊圧技1: 赤火砲 → 蒼火墜 → 廃炎 by the Fear held.
  - 霊圧技2 **戦士の心構え**: 「腕を構えて反撃の態勢をとる。構え中に攻撃を受けると**敵の背後に回り込んで攻撃し、綴雷電で追撃**」
    (an arm guard; when hit, he **goes behind the enemy, strikes, and follows with Tsuzuri Raiden**).
  - 覚醒 **始解"風死"**: 「閃撃の内容が変化し、**中距離への攻撃手段を得る**」 (the Flash attacks change and gain
    mid-range attacks); the stat gains are small, Fear makes up for it.
  - 己有仕様 **恐怖**: Fear grows when either side loses a Konpaku or awakens; more Fear = more damage, some moves
    change.
- **In-game strings** (data-mine): Special Flash **"Sliding"**: "Slide toward the enemy to slash with great force.
  You're invulnerable to enemy projectiles during this movement … if the slide hits at point-blank range, the slash
  will be blocked". Awakening: "Hisagi **tosses his blade aside, as it warps into a double-ended scythe, spinning in
  the air connected to a second scythe by a long chain, returning to Hisagi**". Kikon: Normal "Blade That Knows Fear",
  Awakened "Inherited Techniques" (Konpaku counts by Fear; no content text). Strings: Q→Q→Q, F→F, ANY→F→F.
- **Key art** (`ros_hisagi_ill.webp`, seen): the pre-TYBW short hair, sleeveless, lieutenant badge (九) on the left
  arm; the **sealed** katana held low-right, its blade angled up behind the shoulder. The RoS Shikai's own animations
  (the awakened Flash strings, the Kikon's cinematic) are not described in any text I could read (gap).
- **What makes it read (B + D)**: a calm swordsman base, Kidō on the side, then the chain as the mid-range layer; a
  projectile-proof slide; a counter that ends behind the enemy; Fear as the reason he gets stronger. For our Shikai:
  the slide (J1's lunge or a Step-J), the "behind" finish (the O), Tsuzuri Raiden as the chain's Kidō (SP1).

### 2.5 Archetype table

| # | Archetype | Examples | **What makes it read** | Risk in our engine (code-animated rig, ink style) |
|---|---|---|---|---|
| R1 | **Short-chain twin sickles** (the double meteor held short) | Kubo "keeps it short" (B-ish); 正鎚 / 救命鎚 (C); Kratos's alternating light lashes (C memory); the ch. 325 clash (A) | one head cuts while the other is held back as the guard; alternate hands; a full turn whirls both for the finish | the two blades and the short chain overlap the body: needs the side view to read; the chain between the hands must sag and swing, never be a stiff bar |
| R2 | **The cast and the reel** (sling throw, haul back) | ja 鎖鎌 "spun then thrown straight like a sling" (C); Spear of Chaos / Hyperion Pull (C); ch. 325 drop-and-pull (A) | a tell (one loop of the chain at his side), a straight cast with the arm along the line, the sickle spinning flat; the reel = the body sinking and leaning back, the chain hand low behind the hip | the line volume is a 0.3 m cap at 1.1 m height: the drawn sickle must fly level at ~1.1 m, not arc high (reach follows motion); a straight chain for ≥ 3 frames reads as a beam (skill red flag): the chain needs lag and slack |
| R3 | **The overhead whirl / fan** | ch. 325 "swung … in large circles so the blade end spins like a fan" (A via C); Ep225 GIF (A); kusarigama "a large circle over one's head" (C) | one arm up, the sickle circling flat above the head, a smear disc; the body still beneath it | a spin is invisible at 2 keys: a key every 90°; the smear disc must be drawn at head height so it does not hide the face; per-loop keys cost no memory if precomputed |
| R4 | **The body wrap and redirect** | rope dart elbow / neck / knee wraps (C); meteor wraps (C); Mask's leg (A) | the chain winds round his own forearm or waist, shortening it; the release whips off on a new curve; the body turns inside the line | wrap geometry = a polyline through bone points: compute per frame into preallocated f32vecs (0 B/frame); the wrap round the *victim* reads the victim's pose (cosmetic, allowed) |
| R5 | **Ensnare and haul** (Kubikake) | ch. 336–337, 384; Ep225 GIF (A); Orion's Harpoon slam (C) | coils on the neck, the chain over his shoulder, his whole back bent into the heave; the victim rises and drops; the slam with dust | the victim's lift is a shared reaction (the sim owns positions): the art can only lean / lift within the reaction clip; a lift must not look like a launch the sim does not have |
| R6 | **The Blades lash** (long whip arcs from the hand) | Kratos's R1 / □ lashes (C memory); Flame Whiplash (C) | the hand snaps, the chain unrolls with lag, a crack at full length, a fast retract | needs the tapered lagging ribbon (Lille R11's fix: 16 segments, lag × s^1.4); the ink line must stay ≥ 2 px at 4–7 m |
| R7 | **The cyclone** | Cyclone of Chaos, Whirling Chaos (C); ch. 337 restrains (A) | arms out, the blades at full chain, a flat ring round him while he turns | 360° volumes only: a cyclone on a 110° arc would draw hits behind him that do not exist (read `:arc`) |
| R8 | **The chain conduit** | Tsuzuri Raiden (A); Blazing Surge (C) | the chain held taut, a pulse running down it to the target | the lightning must run along the drawn chain, so the chain must be drawn taut first (2–3 f) |
| R9 | **The plume / slam finisher** | Plume of Prometheus, Chaos Slam, Tartarus Rage (C) | both blades lifted overhead together and brought down in front; dust | KARI-OTOSHI's volume is a 120° fan at 2.8 m: a single vertical drop covers a strip, so the two blades must part to the fan's edges (§3.1) |
| R10 | **The grapple zip** | Hyperion Grapple (C); the spirit's tree swing (A filler) | he flies along his own taut chain to the hooked target | the follow-up dash is generic (DUEL_HISAGI M5): drawn only, no sim change |
| R11 | **The slide and the appearance behind** | Ep219 slide (A anime); RoS Sliding, 戦士の心構え (B); ch. 325 "appears behind" (A) | a low skid with the blade at the shins; a vanish, the cut from behind | Shunpo-behind needs a sim position change: only where a move already moves him (the O's dash) |

**The choice for the Shikai (proposal, D, for the user to approve).**
- **J (JJJ) = R1 short-chain twin sickles**, finale **R7 the cyclone** at short chain (RIN). The one-handed (OUT)
  copies keep R1 with the right sickle alone (kusarigama's "fight on with the sickle when the weight is out").
- **K (KKK / KKJ) = R2 the cast and the reel**, with the Blades of Chaos as the K finale: **R9 the plume** (KARI-OTOSHI).
- **JKK = R4 the body wrap** (MAKI wraps him, HODOKI unwinds it).
- **L = R3 the overhead whirl** (KAZAGURUMA).
- **SP1 = R8 the chain conduit**, **SP2 and the Breaker = R5 ensnare and haul** (at range and up close), **O = R3 → R2
  → R10 → R11** (the Findorr finish: whirl, the flat throw, the zip, behind him).
- Canon manner everywhere between strikes: the reveal pose as the stance, the drop-and-pull, looking at the blade, the
  pin.

---

## 3. The motion bar per form

**Hand sets.** The right hand keeps its sickle and cuts; the left sickle is the thrown head (B2a's D7) and the left
hand works the chain (canon §1.7). **R** right sickle forehand, **R-b** right backhand, **R-pt** right rod point
(thrust), **R-h** right rod butt / handle (block, strike), **L** left sickle on a short chain (≤ 1.2 m), **Lc** the left
chain cast, **Lr** the left chain reel / haul, **W** both sickles whirled, **Cw** the chain wrapped on his body, **G**
both hands on the chain as a garrote, **K** kidō hand, **body** (no strike plane).
**Planes** (his view): horizontal R→L, horizontal L→R, ↘ (high right to low left), ↗ (low left to high right), ↖ (low
right to high left), vertical down, vertical up, line (a cast along the facing), reel (toward him), spin (a flat ring
round the body), overhead (a flat ring above the head), wheel (a vertical circle at his side).
**Rules** (skill): no two strikes in a form share a plane *and* a hand set; one archetype a string; one beat a press;
each route its own clip; the hit pose on S; **read each slot's `:arc` / `:vol` first** (values from
`duel/lisp/hisagi.lisp`, 2026-10-17); reach follows the drawn motion (U), so a drawn tip off the volume is a sim change
to propose, never a silent mismatch.

### 3.1 Shikai 風死 (form `:base`)

**Stance / idle** (A): the reveal pose, softened: feet a shoulder and a half apart, **weight on the back foot** (the
half-step back, D as a pose), upright; **the right rod held low-forward at the hip, point down-forward, blades by the
right shin; the left hand holds the left rod at the hip, point down; the chain hangs in one loop to the floor between
them** (`324…`, `367…`, `Ep280…`). Breath: the chain loop sways, the blades tick. Out of hand (OUT): the left hand
holds the chain running along the floor to the anchor, the left fist at the hip (`325Hisagi_evades`'s chain hand).
**Walk**: the same, the chain loop dragging on the floor. **Run**: leaning in, both rods held back low and level
behind the hips (D), the chain trailing in a lagging curve. **Step / Hoho**: generic, the chain trailing.

| Slot | `:arc` / `:vol` (built) | Archetype | Body in one line | Plane / hands | Grade |
|---|---|---|---|---|---|
| J1 旋 SEN | 1.4 m arc 110, lunge 0.3 | R1 | A slide-step in (RoS Sliding's skid, short), the right sickle **hooked flat R→L at chest height**, the left sickle held back at the hip as the guard head | horizontal R→L / R | D (B Sliding, A ch. 325) |
| J2 返旋 KAESHI-SEN | 1.4 m arc 110 | R1 | The hips turn back, the left sickle **flung on ~1 m of chain rising ↗** from the left knee to over the right shoulder (the second head), the right rod drawn back to the shoulder | ↗ / L | D (C double meteor, C memory Kratos) |
| J3 輪 RIN (ender) | 1.4 m arc 200, drawn as the full spin | R1 → R7 finale | Both sickles let out to ~1.2 m and **whirled flat round him in a full turn on the left foot**, a key every 90°, blades at waist height; ends square, the chain slack | spin / W | D (C Cyclone, A `337Hisagi_restrains`'s disc) |
| SEN-1H (OUT J1, KJJ's J) | as J1 | R1 one-handed | J1's clip: it is right-hand only, so it stands as is (the left fist on the taut chain to the anchor) | horizontal R→L / R | D |
| KAESHI-SEN-1H (J2s after NAGE; OUT J2) | as J2 | R1 one-handed | Not J2's clip (the left sickle is out): the **right rod reversed, a backhand rising ↖** from the right hip to over the left shoulder, Isshin-ryū's upside-down grip | ↖ / R-b | D (C Isshin-ryū reverse grip) |
| RIN-1H (OUT J3) | as J3 | R1 one-handed | A pivot turn, **the right sickle swung at arm's length through 200°**, the chain to the anchor sweeping across the floor behind him | spin (arm, not chain) / R | D |
| K1 投 NAGE | cap 0.3 → 6.0 m at 1.1 m, `:track` 30, `:no-close` | R2 | Tell inside S 18: the left sickle **swung once in a vertical wheel at his left side**; step through, **cast from the hip along the line**, the left arm fully out at chest height, the sickle **spinning flat** (a disc) at 1.1 m; the right sickle pulled back to the right hip | wheel → line / Lc | A (disc: ch. 325, Ep225) + C (ja sling throw) |
| K2 引 HIKI (after NAGE) | the segment anchor → hand, r 0.35 | R2 | **Drop and pull**: he sinks and leans back, the left hand **hauls the chain down past the hip**, the right arm pointing at the foe; the sickle comes back along the chain into his back | reel (low) / Lr | **A** (ch. 325, `325Hisagi_evades`) |
| K2s 巻 MAKI (after J1) | cap 0.3 → 3.2 m | R4 | **Elbow shoot**: the chain wound once round his left forearm to shorten it, the sickle released sideways in a **curling L→R arc** that wraps round the foe's body | horizontal L→R (curving) / Cw + Lc | C (rope dart elbow shoots) + A (Ayon tied, ch. 336–337) |
| K3 刈落 KARI-OTOSHI (after KAESHI-SEN / HIKI) | 2.8 m arc 120 | R9 (the K finale) | A hop; **both sickles swung up overhead together and brought down in front**, the two blades **parting to the fan's edges (±60°)** so the drop covers the 120° arc; dust, a long hold | vertical down (split) / W | C (Plume / Chaos Slam) + D |
| K3 解 HODOKI (after MAKI) | the segment anchor → hand | R4 | **Turns inside the chain**: a full back-turn, the chain thrown **over his right shoulder** and heaved, the wrap unwinding off the foe and the sickle ripping free into him from behind | reel (high, over the shoulder) + spin / Lr | C (rope dart body turns) + A (over-the-shoulder haul, `337Kubikake1`) |
| K (OUT) 戻 MODOSHI | no hit, S 6 | R2 | **Two hand-over-hand pulls** (left, then right on the chain), the sickle flies home and is **caught in the left hand on f6** with a short twirl | — / Lr | D (ja 巻き取り) |
| L 風車 KAZAGURUMA in | r 2.0, 360°; ward from f0 | R3 | The left sickle let out to ~1.6 m and swung up | — | D |
| KAZAGURUMA loop (20–60 f) | — | R3 | **The fan**: the left arm raised, the sickle **circling flat above his head** (a key every 90°, ~12 f a turn, a smear disc at head height); the right sickle held up across the face as a guard | overhead / W | **A** (ch. 325 fan, Ep225 0–1.0 s) |
| KAZAGURUMA push (f6–8 hit) | 360° r 2.0 | R3 | The whirl **drops to waist height and widens** to 2.0 m for one turn | spin (low, wide) / L | D |
| KAZAGURUMA out | — | R3 | The whirl slows, the sickle caught | — | D |
| SP1 綴雷電 TSUZURI RAIDEN | cap 0.3 → 6.5 m, `:track` 30 | R8 | An **overhand cast ↘** from above the left shoulder (not NAGE's hip cast); then **the left fist high on the taut chain, the right hand's two fingers on it**; green-white lightning runs down the chain | ↘ line / Lc + K | **A** (ch. 337, Ep225) + C (Blazing Surge) |
| SP2 縛 SHIBARI bind (f16) | cap 0.3 → 4.5 m | R5 | **A lasso**: the chain circled flat over his head once and cast so it **winds several turns round the foe's body** | overhead → cast / Lc | A (Ayon tied, ch. 336–337) |
| SHIBARI slam (f46) | the same line | R5 | **The heave**: the chain over his right shoulder, the right arm raised gripping it, **the back bent forward**, the foe hauled up and over and slammed (dust) | reel (over the shoulder, two hands) / G | **A** (`337Kubikake1`, Ep225 GIF 11.5–18.7 s) |
| I Breaker 首掛 KUBIKAKE | 1.35 m (generic) | R5 close | **A garrote**: the short chain between the two rods **thrown over the foe's head from the front**, a turn so his back is to the foe, the chain over his shoulder, the foe heaved over and slammed; ends in **the pin** (kneeling, a hand at the throat, the right sickle raised point-down) | over-the-shoulder throw / G | A (ch. 384 slam + `384Hisagi_pins`), D (from the front) |
| O 刈 KARI aura (6 f) | aim 120 °/s | R3 | The overhead whirl, **the blade passing in front of his face** ("are you scared?") | overhead / L | **A** (ch. 325, Ep219) |
| O strike (S 20) | lane 0.5 → 7.0 m, r 1.0 | R2 | The fan **released flat**: the sickle skims the lane as a wide spinning disc at waist height (fits the 1.0 m lane radius) | flat disc / Lc | A (`325Kazeshini_severs`) + D |
| O follow-up (generic dash) | `:follow-speed` 14 | R10 → R11 | **Zips along the taut chain** to the hooked foe, then the cut from behind (canon "appears behind and finishes him") | — | C (Hyperion Grapple) + A (ch. 325) |
| Hits / guard / down | shared `:sh-*` | — | Stay shared; canon references for later: `Ep399HisagiShot` (sniped: knees buckle, back arched), `Ep383MaskClotheslinesHisagi` | — | A |
| Intro | — | canon | Sealed sword drawn and held **across his face** (Ep219 intimidation); 「刈れ」; RoS: **tossed up spinning, splitting into the two sickles on the chain**, which whips round and he catches both, settling into the stance | — | A (Ep219) + B (RoS awakening text) |
| Win | — | canon | The chain goes slack; **he looks at the blade in his hand** (ch. 325 pp. 3–4), a half-step back; alt.: `325Hisagi_stands` (one rod level, the other sickle aloft on the looping chain) | — | A + D |

**Uniqueness check** (plane / hands): J1 R→L / R; J2 ↗ / L; J3 spin / W; KAESHI-SEN-1H ↖ / R-b; RIN-1H arm spin / R
(differs from J3 by hands); NAGE wheel → line / Lc; HIKI low reel / Lr; MAKI curving L→R / Cw + Lc; KARI-OTOSHI split
drop / W; HODOKI high reel + turn / Lr (differs from HIKI by plane); KAZAGURUMA overhead / W, push low spin / L; SP1 ↘
line / Lc + K (differs from NAGE by plane); SHIBARI lasso → shoulder heave / Lc then G; KUBIKAKE shoulder throw / G
(close, from the front; SHIBARI's heave is at range); O flat disc / Lc. **Two close pairs to watch**: SHIBARI's slam and
KUBIKAKE share the over-the-shoulder heave (different range and entry; if the user wants them apart, KUBIKAKE can end
in the pin without the throw); J3 and the windmill's push are both flat spins (different hands and heights).

**Read `:arc` / `:vol` notes.**
- NAGE / SP1 / MAKI / SHIBARI are caps at 1.1 m along the facing: the sickle must fly level at about chest height and
  land on the line's end; an arcing lob would draw a tip off the volume.
- KARI-OTOSHI's `:reach 2.8 :arc 120` is a fan: draw the blades reaching the fan's edges at S (FK ±0.15 m), not one
  central drop.
- RIN's arc is 200°, not 360°: the full turn's hit pose (S 9) must have the blades in front; the back half is
  follow-through (B2a draws it so).
- The pulls (HIKI, HODOKI) hit along HS-CHAIN-SEG (anchor → hand): the drawn returning sickle must travel that
  segment, and the guard is read from his position as for any hit (the "from behind" look must not suggest an
  unblockable).
- The Kikon's lane is 7.0 m with r 1.0: the flat disc is the honest drawing.
- **The rod length** (§4.1) moves the J tips: B2a's J tips are 1.41–1.52 m with a placeholder blade; a ~1.0 m rod held
  at the butt at arm's length plus ~0.3 m of blade gives about 1.5–1.7 m from the root. Measure before drawing; if the
  canon-proportioned weapon reaches past 1.55 m, the user's 「跟著動作走」 makes it a J reach change (a sim change,
  gated), or the grip slides up the rod to keep 1.4 m.

### 3.2 Bankai 風死絞縄: the ranged mode (`:bankai`, §17.1)

**Look in motion** (A picture + B): wrapped in his own chain (neck, right arm), a **single black crescent** in each
hand, the orb above, the thick twisted chain rope from his neck to it. **Idle** (A, the CFYOW illustration): standing
straight and still, **arms hanging, the crescents point-down, chains pooling at his feet**; the stillness is the
Bakudō-type Bankai. **Walk**: unhurried, the orb drifting with him. **Run**: the arms back, the chains streaming.
Hand sets: **R / L** a crescent on its hand chain (the "swung chains"), **O** a chain from the orb (no hand; he gives an
arm signal: canon "raises one of the blades"), **B** both, **N** the neck rope.

| Slot | `:arc` / `:vol` (§17.1) | Archetype | Body in one line | Plane / hands | Grade |
|---|---|---|---|---|---|
| J1 鎖鞭 SABEN (S 12) | 4.0 m arc 100 | R6 | The right arm **cracks the chain out**: a lagging lash R→L at chest height, the crescent at 4 m | horizontal R→L / R | C (Kratos lash) + D |
| J2 返鞭 KAESHI-BEN | 4.0 m arc 100 | R6 | The left arm lashes back L→R | horizontal L→R / L | C + D |
| J3 旋鎖 SENSA (ender) | 4.4 m arc 180 | R6 → R7 | Both crescents swung round in a **half-turn cyclone** at full chain (180°: the front half is the hit, ends facing the foe) | spin / B | C (Cyclone of Chaos) |
| K1 墜鎖 TSUISA (S 22) | cap 0.3 → 7.5 m at 1.1 m | R2 (orb) | Signal: the right crescent **raised high, then cut down toward the foe**; a chain spears out of the orb, dives to the floor ~1 m in front of him and **lances level along the line** (so it matches the 1.1 m cap); on hit the drag to 3.5 m reads as the chain reeling | ↘ signal + line / O | A (raised blade) + C (Spear of Chaos) |
| K2 / K2s 薙鎖 NAGISA | 6.0 m arc 140 | R6 (orb) | Signal: the left arm swept low L→R; an orb chain **sweeps the floor** in a reaping fan | horizontal L→R low / O | D |
| K3 落鎖 RAKUSA (ender) | 7.5 m line r 0.5 | R9 (orb) | Signal: both crescents lifted overhead and brought down; **a bundle of chains drops** from the orb onto the line (dust) | vertical down / O + B | C (Plume / Tartarus Rage) |
| L 鎖払 SAHARAI | r 3.0, 360° | R4 reversed | **The wrap bursts**: the chains wound on his body uncoil outward in a ring, arms flung open | spin (burst) / Cw | C (rope dart body-wrap release) + D |
| SP1 綴雷電 | 9.0 m line | R8 | The right crescent raised, two fingers on the neck rope; lightning runs **up the rope, through the orb, down a chain** to the foe | line / N + K | A (ch. 337) + D |
| SP2 鎖雨 KUSARI-AME | lane 10 × 2 m, two windows | R9 (many) | **Both arms raised to the orb**; the orb tilts and **many thin chains rain** along the lane in two waves | — / O + B | **B** (Brave Souls: "countless chains rain down from a sphere") |
| O 降鎖 KŌSA | lane 9 m r 1.0 | R6 (orb) | The right crescent pointed along the lane; **one thick twisted rope of chain** (the neck rope's twin) whips down along it | vertical whip / O + R | A (the CFYOW rope) + D |
| I Breaker | 1.35 m | — | **The chained right forearm** (BBS art) brought down as a hammer-fist | vertical down / R-arm | B (art) + D |
| P 首掛 KUBIKAKE throw (S 24) | 7.0 m line from his hand | R3 → R5 | Tell: the left chain **whirled overhead**; cast as a noose loop that **snaps round the neck**; on hit the yank to 2.0 m, the noose linking both necks to the orb | overhead → cast / L | A (Kubikake, the noose) |
| Hits | shared | — | Inside the bind (§3.3) the canon "takes it standing" could swap a stagger for a held flinch (presentation only, later) | — | A (via C) |

Uniqueness: J1 R→L / R, J2 L→R / L, J3 spin / B, K1 ↘ + line / O, K2 low L→R / O (differs from J2 by hands), K3 down
/ O + B, L burst / Cw, SP1 line / N, SP2 rain, O whip / O + R, Breaker down / R-arm, KUBIKAKE overhead → cast / L.
**Read `:vol` first**: every orb attack's volume starts at his feet along the facing at 1.1 m (caps) or is a lane; the
art may *start* at the orb but must *arrive* on the volume by S (the drawn tip sets the reach, U). A chain drawn
straight from a 4.2 m orb to the target's head would sit 1–3 m above the caps: draw it diving to the floor first.

### 3.3 The bind mode (`:bankai-bind`, §17.3) and the release

Both necks noosed to the orb; melee. Hand sets as §3.2 plus **Nh** his hand on the noose chain.

| Slot | `:arc` / `:vol` (§17.3) | Archetype | Body in one line | Plane / hands | Grade |
|---|---|---|---|---|---|
| J1 弦 GEN | 1.5 m arc 110, lunge 0.3 | R1 | The right crescent **hooked flat R→L** at the neck line | horizontal R→L / R | D |
| J2 返弦 KAESHI-GEN | 1.5 m arc 110 | R1 | The left crescent **rising backhand ↗** | ↗ / L | D |
| J3 双弦 SŌGEN (ender) | 1.5 m arc 200 | R1 finale | **Both crescents crossed** in front, then scissored outward (an opening X) | crossed → open / B | D |
| K1 引斬 HIKIGIRI | 2.6 m line | R5 | **The pull-cut**: the left hand yanks the noose chain back at his chest while the right crescent hooks forward along the line | line (hook) / R + Nh | A (the noose) + D |
| K2 / K2s 巻斬 MAKIGIRI | 2.8 m arc 140 | R4 | The chain on his right arm **uncoils** and the crescent swings out in a wide flat arc L→R | horizontal L→R / Cw | C (elbow shoot) |
| K3 絞 SHIBORI (ender) | 3.0 m | R5 | **The canon gesture**: the right crescent raised high, the left hand hauls down; the orb's chains wrap and cinch the foe | vertical up (signal) / R + Nh | **A** (CFYOW: "raises one of the blades and the chains constrict") |
| L 引寄 HIKIYOSE | no hit, the drag | R2 | **Hand over hand** on the noose chain, leaning back | reel / Nh (both) | A (Kubikake haul) + D |
| SP1 綴雷電 | 4.0 m line | R8 | Lightning down the noose chain from his raised fist | line / Nh + K | A + D |
| SP2 絞縄 KŌJŌ | 3.0 m arc 160 | R5 | The blade raised, **both nooses snap tight, both choke** (his own hand at his throat for a beat), then a wide downward reap | ↘ wide / R | A (shared pain) + D |
| O 絞首 KŌSHU | dash ≤ 30 f, strike 1.6 m | R10 → R5 | **Zips along the noose chain**, then from behind draws the chain across the throat (the ch. 384 Kubikake from behind) | — / G | A + C |
| I Breaker | universal | — | as the ranged mode | — | — |
| P 解縛 KAIBAKU → UNWIND (20 f) | no hit | — | The chains go slack and **unwind off both necks**, he lowers the crescents (the canon voluntary release) | — | A (via C) |
| The opponent's 30 f reel | shared reel clip | — | A hand to the throat, a stagger back (the shared reel on the opponent) | — | D |

Uniqueness: J1 R→L / R, J2 ↗ / L, J3 X / B, K1 hook line / R + Nh, K2 L→R / Cw, K3 up / R + Nh (differs from K1 by
plane), L reel / Nh, SP1 line / Nh + K, SP2 ↘ / R, O garrote / G.

### 3.4 Cinematic beats (presentation only; DUEL_HISAGI §11.5 already tables them)
- Shikai Kikon 「刈れ」: the storyboard's beats match the canon (§1.1) beat for beat; add the **lamppost** perch for
  beat 1 (Ep219) only if the stage has a prop; otherwise the reveal pose.
- The awakening: canon order (§1.6): both scythes thrown up, the whirlpool, the black wind, the scythes falling back
  as single crescents, the chain winding him, the orb, the noose.

---

## 4. Model-sheet notes for the stills

### 4.1 Kazeshini (Shikai)
| Item | Fact | Grade / source |
|---|---|---|
| Parts | Each weapon: a **black rod** with a **pointed tip** beyond the blades and a **forked / ringed butt** where the chain fixes; **two long crescent blades** mounted on the front quarter of the rod | A (`324…`, `325Hisagis_Shikai_Kazeshini`, `367…`) |
| Blade layout | The two crescents leave the rod on opposite sides and both sweep back toward the holder: side-on they read as one large crescent crossing the rod (a ")" with the rod through it, `324`); turned, as an S or an X (`325`). The wiki: "two scythe blades, with one inverted, giving it the resemblance of a pinwheel" | A + A (via C); the exact 3D layout is my reading (D) |
| Rod length | ≈ 0.9–1.0 m overall: the butt ~0.15 m behind the fist, fist to blade root ~0.45 m, the point ~0.15 m past the blades | D, measured on `324` / `325` against his head (~0.23 m) |
| Blade size | each crescent ≈ 0.5–0.6 m along its curve; tip to tip across the rod ≈ 0.9–1.0 m | D (same) |
| Chain | thick oval links (~4–5 cm), from butt to butt; slack it loops to the floor; he keeps it short | A (stills) / B-ish (Q&A #397) |
| Grip | overhand at the rear third, near the butt; the cutting hand's rod points at the foe or down | A (`325` clash, `324`) |
| Colours | rod black; blades white-silver edge with a black spine (manga colour), steel-grey with blue shading (anime); chain dark grey; **Reiatsu green** (the Ep219 release still shows a cyan-green outline glow) | A (stills) / A (via C) |
| The sealed sword | a plain katana, octagonal tsuba; **its blue-black scabbard stays in the sash on the left hip after the release** | A (stills, fandom) |
| In flight | the sickle spins flat and is drawn as a disc / ring | A (`325Kazeshini_severs`, Ep225 GIF) |
| Correction to DUEL_HISAGI §11.1 | "a spiked rod (~0.5 m, forearm-long)" → ~0.9–1.0 m; "two scythe blades, one inverted (a pinwheel / S)" stands | — |

### 4.2 The TYBW costume (A unless marked)
- **Hair**: grown out, a messy black fringe to the ears and over the eyes (`Ep370…`, `520.5Hisagi_profile`); blue-black
  in colour art, purple-tinted in the anime.
- **Face**: three parallel scars straight down over the right eye to the cheek; **69** on the left cheek; a **blue
  stripe** across the left cheek and the bridge of the nose; dark grey eyes (`520.5…`, `ros_hisagi_trailer_thumb`).
- **Neck and arms**: a black **choker** with white studs / bars; **studded bands on both upper arms** (explosive, ch. 324);
  the **lieutenant's badge (九) on the left upper arm** (RoS art, the anime full-body sheet; B / A).
- **Clothes**: sleeveless shihakushō with a deep V, white under-collar; **white sash tied at the front-left with
  hanging ends**; wide black hakama; white tabi and waraji (`Hisagi_Anime_Fullbody`, `ros_hisagi_ill`).
- Build: 181 cm, 67 kg, lean, long arms (notes §3).

### 4.3 The Bankai look
| Item | Fact | Grade / source |
|---|---|---|
| Blades | **single long black crescents**, one in each hand, on dark rods, held point-down | A picture (CFYOW pencil) + B (Brave Souls art); whether the Bankai changes the Shikai's twin blades or the artists simplified them: unknown (notes §7.5) |
| Chain on him | coiled round the **neck** and the **right upper arm and forearm** | B (`BBSHisagi_s_Bankai`) + A (via C) "wrapped in his own chain" |
| The rope to the orb | a **thick twisted rope of chain** rising straight from his neck, about the neck's width | A picture (CFYOW pencil) |
| The orb | "a jet-black orb made of chains, hovering above"; Brave Souls draws a sphere larger than him with chains radiating and hanging | A (via C) + B; **size and texture not stated** (gap); our §11.4 r ≈ 0.9 m at 4.2 m is a proposal |
| Light | the orb casts shadows "as if they were beams of light" (inverted shadow) | A (via C) |
| Colours | black orb, black chains, black wind at release; his Reiatsu green | A (via C) |

### 4.4 Image table (new this pass; `.refs/hisagi/`, git-ignored; URLs appended to `_urls.tsv`)

| File | What it shows | Poses it supports |
|---|---|---|
| `324Hisagis_Shikai_Kazeshini.png` | Manga colour: the Shikai reveal, full weapon detail | **stance**, weapon model sheet |
| `325Hisagis_Shikai_Kazeshini.png` | Manga colour: both rods low, blades crossed, chain slack; scabbard in the sash | idle, weapon model sheet, win |
| `325Hisagi_and_Findorr_clash.png` | Airborne downward cut, the chain hand high behind | J1–J2 grip, O's cut from behind |
| `325Hisagi_evades.png` | Falling back, the chain hand low behind the hip, the thrown sickle behind Findorr | **HIKI** |
| `325Hisagi_overwhelms.png` | The overhead whirl, "are you scared?" | **KAZAGURUMA**, O aura, NAGE's tell |
| `325Kazeshini_severs.png` | The sickle edge-on as a spinning disc | NAGE / O in flight |
| `325Hisagi_kills.png` | The backward swing, arm swept up behind, chain arc to the blade | HODOKI, KARI-OTOSHI's wind-up |
| `325Hisagi_stands.png` | On a pillar, one rod level, the chain looping above, the other sickle aloft | **win / intro** |
| `336Kubikake.png` | Chain coils on the neck and arm (close-up) | SHIBARI / KUBIKAKE wrap look |
| `336Hisagi_and_Izuru_intervene.png` | Chain over the right shoulder, fist at the chest | SHIBARI hold, Bankai L haul |
| `337Kubikake.png` | Ayon slammed face-down, chain held low | SHIBARI end |
| `337Kubikake1.png` | **The haul**: crouched, arm over the head on the chain over the shoulder | **SHIBARI slam, KUBIKAKE, HODOKI** |
| `337Hisagi_restrains.png` | From behind, both arms out low, chains to Ayon, a whirling disc | SHIBARI bind, RIN's disc |
| `337Tsuzuri_Raiden.png` | Rod level at the hip, the chain taut above the shoulder, lightning on it | **SP1** |
| `337Tsuzuri_Raiden2.png` | Lightning reaching the neck along the chain | SP1 VFX |
| `367Hisagi_intervenes.png` | Feet wide, chain taut in the right hand, the other rod point-down | **stance** (alt.), MAKI's ensnare |
| `384Kubikake.png`, `384Kubikake2.png`, `384Kubikake3.png` | Chain round Tōsen's neck from behind, the yank, the slam arc | **Breaker**, bind O |
| `384Hisagi_pins.png` | Kneeling, a hand at the throat, the sickle raised point-down | **the pin** (KUBIKAKE end, win alt.) |
| `386Hisagi_impales.png` | Silhouette on Tōsen's back, both hands on the hilt | intro alt. (the release as the blow) |
| `Ep225Kubikake.png`, `Ep225Kubikake1.png`, `Ep225Kubikake3.png` | Anime: Ayon lifted, the coils, the slam | SHIBARI slam, Breaker |
| `Ep225TsuzuriRaiden2.png` | Anime: fist high on the chain, rod across the body, lightning | SP1 (anime colours) |
| `Ep280HisagiEntersBattle.png` | Anime, from behind: chain taut to Tōsen's sword, rod low | stance from behind (camera) |
| `Ep219FindorrBlocksHisagi.png` | Anime: airborne cut, rod gripped at the butt, chain hand behind | J grips |
| `Ep219HisagiFaceOff.png` | Anime: sealed sword held low, sleeveless, armbands | pre-release / intro |
| `Ep389ByakuyaBlocksHisagi.png` | TYBW anime: one-armed level thrust with the rod | a thrust option (R-pt) |
| `Ep399HisagiShot.png` | TYBW anime: sniped, knees buckling, back arched | hit reaction; the Lille intro |
| `Kazeshini_fights_Hisagi.png` | Filler: both fists on one rod as a bar, chains whirling | guard / block pose |
| `260Hisagi_deflects.png` | Filler: arms flung wide, blades clash in sparks | Step / parry look |
| `235Hisagi_jumps.png` | Filler: airborne, the thrown sickle stuck in the ground | OUT state (the anchor) |
| `260Hisagi_slashes.png` | Filler: deep low lunge past the foe | J1's slide / O's pass |
| `Kazeshini_Full_Body_ep260.png` | Filler: the spirit, sickle over the shoulder | (character art only) |
| `Hisagi_Anime_Fullbody.png` | Anime model sheet, front | body proportions, costume |
| `ros_hisagi_ill.webp` | RoS key art (pre-TYBW hair, badge, sealed katana) | costume details |
| `ros_hisagi_trailer_thumb.jpg` | RoS trailer card: face close-up | face (scars, 69, stripe, choker) |

Used from the first set (notes §6): `Ep219HisagiShikaiKazeshini.png` (Reiatsu colour), `Ep219HisagiShikaiIntimidation.png`,
`Hisagi_s_Bankai_CFYOW.png`, `BBSHisagi_s_Bankai.png`, `Ep370DriscollConfrontsHisagi.png`, `520.5Hisagi_profile.png`,
`Kubikake.gif` (frame sheet), `Ep397IkkakuHisagiStruggle.png`.

**Dropped**: `325Findorr_is_thrown.png` (no Hisagi), `Ep225TsuzuriRaiden.png` (an effect close-up),
`Ep219FindorrStabbed.png` (an unreadable silhouette), the two YouTube trailer thumbnails (the same face card as
`ros_hisagi_trailer_thumb.jpg`).
**Could not see**: the RoS trailers (`https://www.youtube.com/watch?v=1hkNH7tlj9E` EN, `…?v=w1y8-W4CRQI` JP: YouTube
blocks this container); any God of War footage; any kusarigama or rope-dart kata video; the CFYOW text; Ep219 / Ep225
as video (only stills and the GIF).

---

## 5. Gaps and how to close them

1. **RoS's Shikai animations** (the awakened Flash strings, the Kikon "Inherited Techniques"): no text describes them.
   Close: the user (or a browser session) watches the character trailer `1hkNH7tlj9E` (EN) / `w1y8-W4CRQI` (JP) and
   notes the Shikai strikes; or a training-mode capture.
2. **Real kusarigama choreography** (how a koryū moves the weight: figure-eights, the cast, the reel): only weapon facts
   and kata names were reachable. Close: Pascal Krieger's *Jōdō* (Isshin-ryū kata), an SMR embu video, Ellis Amdur's
   *Old School* pp. 118–122. Until then the R2 / R4 bodies are C–D.
3. **Rope-dart wraps as bodies**: the Home of Poi lessons are videos (not watched). Close: watch "Lead Elbow Basics",
   "Neck wraps", "Body Wraps" for MAKI / HODOKI / SAHARAI key poses.
4. **Blades of Chaos bodies** are from memory (C memory). Close: a GoW 2018 / Ragnarök Blades combo video for the lash
   timing and the Cyclone's turn rate.
5. **Weapon proportions** are measured on two manga pages (D). Close: a third angle (`367…`, the anime model sheet if
   the wiki has one) before the model-sheet still; then the FK host print for the J tips (§3.1, the rod-length note).
6. **The Bankai's orb** (size, texture, how many chains) and **the blades** (single or twin): the novel's text was not
   read. Close: the CFYOW III ch. 24 text (Viz EN 2021) or the anime Part 4 if it adapts the novel (unconfirmed).
7. **Timing**: no frame data for any canon move (the GIF is edited). The slot table keeps B2a's frames; the keys follow
   the skill's rules (the hit pose on S, a key every 90° of a spin).
8. **Hand assignment**: canon swaps which hand holds the cutting rod (ch. 324 right extended; ch. 337 / 367 the chain
   in either hand). The plan fixes right = cutter, left = thrown (B2a's D7); the user may prefer the mirror.
9. **Two close slots** (§3.1): SHIBARI's slam and KUBIKAKE's throw share the over-the-shoulder heave; decide with the
   user (or end KUBIKAKE in the pin only).

## 6. Sources
- bleach.fandom.com (MediaWiki API): `Shūhei Hisagi` (+ `/Expanded Universe`, `/Image Gallery`, `/Battles & Events`),
  `Shūhei Hisagi vs. Findorr Calius`, `Sajin Komamura & Shūhei Hisagi vs. Kaname Tōsen`, `Battle of the Chimera:
  Gotei 13 vs. Ayon`, `Shūhei Hisagi vs. Kazeshini`, `Shūhei Hisagi vs. Kazeshini: Final Fight`, `Kazeshini (Zanpakutō
  spirit)`, `Kubikake`, `Episode 219`, `Episode 225`, `Episode 235`, `Episode 236`, `Episode 260`; images by prefix.
- godofwar.fandom.com (API): `Blades of Chaos`, `Hyperion Charge`, `Spartan Rage`.
- Wikipedia: `Kusarigama`, `Kusarigamajutsu`, `Isshin-ryū kusarigamajutsu`, `Shintō Musō-ryū`, `Rope dart`, `Meteor
  hammer`; ja `鎖鎌`; zh `繩標`, `流星錘`.
- Rope dart: `https://www.homeofpoi.com/en/lessons_all/teach/Rope-Dart` (lesson index), `…/Elbow-shoots/Lead-Elbow-Basics`;
  `https://www.flashmavi.com/learn/wushu-rope-dart`.
- RoS: `https://bleach-ros.bn-ent.net/character/?chara=shuhei-hisagi` (official JP, B);
  `https://www.resource-of-souls.com/characters/shuhei-hisagi` (in-game strings, B via C);
  `https://www.gematsu.com/2025/01/bleach-rebirth-of-souls-character-trailer-shuhei-hisagi` (trailer embeds, C);
  YouTube oEmbed titles: "BLEACH Rebirth of Souls — Shuhei Hisagi Character Trailer" (Bandai Namco Entertainment
  America), 「BLEACH Rebirth of Souls」キャラクタームービー #27｜檜佐木修兵 (Bandai Namco Entertainment).
