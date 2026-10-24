# Kuchiki Rukia (TYBW): nihon buyō and related style references, and the motion bars

Research pass 2026-10-24. The user's style: 「原作舉止＋日本舞踊」 (canon manner plus Japanese classical dance; the user,
2026-10-24, `docs/duel/DUEL_RUKIA_TYBW.md` §2). Canon moves stay canon (grade A); invented strikes are proposals (grade D).
Use: archetypes for a small (1.44 m) one-handed sword dancer with a long ribbon, in SOUL DUEL's code-animated clips. Canon
beats: `canon-motion.md`; looks: `canon-looks.md`. Method: skill `duel-motion-style`; format:
`docs/research/ichigo-rework/style-refs.md`. Kit slots: `duel/lisp/rukia.lisp` (current volumes), the new Shikai logic
霜の層 in `DUEL_RUKIA_TYBW` §4.1 (the user, 2026-10-24).

**Fetch note.** ja.wikipedia's API gave `日本舞踊`, `仕舞`, `摺り足`, `舞扇`, `上方舞`, `雪 (地唄)`, `巫女舞`,
`京鹿子娘道成寺`, `剣舞`; en.wikipedia `Kenshibu`. It then rate-limited, so `鷺娘`, `見得`, `地唄舞` were read only through
search-engine summaries of kotobank, Daily, fun-japan, allabout and the Pitt kabuki glossary (graded C). The Pitt glossary
and samurai-archives failed TLS / DNS. No video was watched; no dance was seen in motion, so every body below is text-based.

**Grades.** **A** BLEACH canon (see `canon-motion.md`). **B** official game text. **C** a dance reference as described by an
encyclopedia or secondary text. **D** my inference or proposal.

---

## 1. Nihon buyō in one screen (what the user's word covers)

- 日本舞踊 joins two kinds: **舞 (mai)**: slow, solemn music, "摺り足や静かな動作で舞台を廻る" (gliding feet and quiet motion,
  circling the stage), inward feeling shown in horizontal motion, ritual roots (gagaku, kagura, Noh); **踊り (odori)**:
  rhythmic, light, leaps; and **振り (furi)**: mimetic gestures (kabuki dance) [C, ja.wikipedia 日本舞踊].
- In Noh's account "舞" comes from **まわる** (turning, circular motion) and 踊り from leaping; Noh dance is "極端な摺り足と独特の
  身体の構え、そして円運動" (extreme gliding steps, a held body, circular motion), with **序破急** (start slow, speed up, stop
  dead), and a stillness that is "forces in balance", not rest [C, ja.wikipedia 仕舞].
- Kamigata-mai (地歌舞, 座敷舞) is "抽象的で内面的…ゆっくりとした動き" (abstract, inward, slow) next to Edo kabuki dance's
  rhythm [C, ja.wikipedia 上方舞].
- Body: the weight low at the hips, posture straight, no hips out, belly in; the base move 「落とし」 (lowering the hips) is
  done either controlled or dropped [C, IPSJ / NEEC syllabus summaries via search].
- **Rukia's dances are named 舞** (初の舞, 次の舞, 参の舞; command 「舞え」) [A]. Read literally, her style is *mai*: gliding,
  circling, slow-quick-stop. This is the strongest link between canon and the user's word [D].

## 2. Archetypes

| Archetype | Examples | What makes it read |
|---|---|---|
| **摺り足 / 腰を落とす** (glide, the low held body; Noh's ハコビ and 構え) | Noh shimai (C); every nihon buyō school's basic walk (C); kendō and sumō footwork (C, 摺り足) | the head never bobs; knees bent, hips low, the feet slide without lifting; she moves like a piece on ice while everyone else steps |
| **回り** (mawari, turning; 旋舞) | 巫女舞: "右回り左回りと順逆双方に交互に回り" (alternating turns, the origin of 舞) (C); Noh's circular paths (C); Rukia's counter-clockwise release (A) | full turns on the spot; the hem bells out and the sleeves and ribbon fly; alternating directions read as ritual, not spinning for damage |
| **扇の手** (fan work: 開く・返す・投げる・回す; 見立て) | 舞扇 thrown and spun on the rivet (要返し), weighted with lead for it (C, ja.wikipedia 舞扇); the fan "seen as" a brush, a wave, wind (C, 日本舞踊) | the wrist leads and the arm stays; small exact flips; the flat of the object flashes as it turns over; for her the white blade is the fan |
| **見得 / 決まり** (the held pose) | kabuki 見得: stop, roll the head, glare, held; the tsuke beats (C, kotobank / allabout via search); Dōjōji's final pose on the bell (C, ja.wikipedia 京鹿子娘道成寺); shimai's closing 打込 (C) | a full stop after motion, held 10–30 f; the head arrives last; stillness that looks tense, not idle |
| **袖 / 袂** (sleeve work) | 地唄舞「雪」: "花も雪も払えば清き袂かな" (brush off flowers and snow: the sleeve is pure) (C, ja.wikipedia 雪 (地唄)); Sagi Musume's long white sleeves (C); Chinese 水袖 water sleeves (C, not Japanese) | the sleeve lags the arm, then snaps or pools; from behind it is the largest moving shape on a small body; the name 袖白雪 is literally "sleeve white snow" [A] |
| **能の型** (サシコミ, ヒラキ, 左右, サシ, 足拍子, 序破急) | shimai: サシコミ (right hand with the fan forward a little high), ヒラキ (three steps back L-R-L, both arms opened), 左右 (a hand raised, steps left, then right), サシ (the fan raised from the side to high front), 足拍子 (stamping the stage) (C, ja.wikipedia 仕舞) | a clear direction (point, open, step back), a stamp you can hear, slow-quick-stop timing |
| **剣舞** (kenbu, shigin kenbu) | a sword dance to recited poetry, in hakama, tabi, tasuki, a white belt; fans in shibu (C, en.wikipedia Kenshibu; ja.wikipedia 剣舞) | real sword figures (draw, cut, guard) done as dance: each cut ends in a held pose before the next; martial, readable |
| **巫女舞・採物** (miko-mai with a held object) | kagura with 鈴, 扇, 笹, 榊, 幣 as the god's seat; turning one way and back (C, ja.wikipedia 巫女舞) | the held object raised and turned over the head; repeated figures round a centre; a ritual count (her four stabs) |
| **地唄舞「雪」** (the still dance) | Takehara Han's 「雪」: white kimono, a white silk umbrella, a nun's lament on a snowy night (C, ja.wikipedia 雪 (地唄)) | almost no travel; one small gesture after a long stillness; interior, cold; the white figure in white |
| **鷺娘・引き抜き** (the white heron, the costume change) | Sagi Musume: enters in white (白無垢), a gauze umbrella, quick changes by 引き抜き on stage, a final ぶっ返り to the heron, ends fallen in the snow (C, Daily / fun-japan via search); Dōjōji's 引き抜き (C) | the costume turns in one beat in front of you; a white figure in snow; the collapse at the end |
| **Ribbon spirals and snakes** (not Japanese; the ribbon's own grammar) | rhythmic gymnastics ribbon (~6 m on a stick): spirals (tight loops), snakes (waves), boomerang (C, Wikipedia / glossary via search) | loops of equal size travelling with the body; waves along a thrust; the ribbon always moving after the hand stops |

### What reads from SOUL DUEL's behind camera
- The camera sits behind P1 and at least 30° round to her right (DEVLOG §338–§339), 2.0 m up, 3.3 m back. She is the
  smallest fighter (1.44 m), so a pose reads by what leaves her body: the arm line, the blade's flat, the sleeve, the hem,
  the ribbon.
- **Read well**: root-yaw turns (the hem bell and the ribbon ring show the turn, `回り`); level changes (the deep crouch, the
  rise); arms out to the side (a T); the blade raised overhead; shapes on the plaza (the drawn circle, stabs); a stop after
  motion (`見得`, 序破急's 急-then-stop).
- **Read badly**: thrusts straight away from the camera (foreshortened: let the ice and the ribbon carry Shirafune);
  the face of a 見得 (only P2's camera sees it: carry it with the head roll and the hold); left-hand moves on her far side
  (raise the left arm forward-high or out, as the canon catch does); wrist-only flips (`扇の手`) unless the flat flashes and the
  ribbon amplifies them; the glide (`摺り足`) only by contrast, so the root must slide 0.3–0.6 m with no bob.
- Facing her (she is P2, or the portrait camera): palms, the head roll and the glare read.

### The choice
(Left blank for the user: which archetypes, per form and per string. §3 is the lead's proposal to react to.)

---

## 3. Motion bars (grade D proposals unless marked)

**Notation.** Hands: **B1** blade, right hand, forehand; **B1b** backhand (wrist turned over); **B1r** reversed, point down
(canon's "upside down"); **B2** both hands; **P** the left palm; **P2** both palms; **S** a sleeve leading (the blade or palm
under it). Planes, in her view: **H→** horizontal right-to-left (her forehand), **H←** left-to-right, **↘** high right to low
left, **↗** low left to high right, **↖** low right to high left, **↙** high left to low right, **V↓**, **V↑**, **T** thrust
(**T-hi** at the head line), **⟲ / ⟳** a turn counter-clockwise / clockwise, **G** a circle drawn on the plaza, **stab**
point into the plaza, **pt** a point (no arc). **Rules**: no two strikes of a form share a plane and a hand set; one
archetype a string (its finale may combine); each band its own clips; the slot's current `:arc` / `:vol` is read first
(listed in the Slot column). The Shikai's new logic (霜の層, §4.1 of the design doc) may move volumes: re-read them when its
segment table is approved. Reach stays as built unless the drawn tip moves it (the awakening's reaches may follow the
motion: the user's scope).

### 3.1 Shikai 袖白雪 (舞: turns for J, kenbu for K, canon dances for the specials)

> Superseded for the new Shikai (霜の層, the bursts, the kidō) by `docs/duel/DUEL_RUKIA_TYBW.md` §13.3 (2026-10-24).

**Idle.** 構え: hips low, knees soft and close, no bounce (the hips sink 1 cm with the breath); the blade one-handed forward
at chest height, level (A `Ep385RukiaShikaiSodeNoShirayuki.png`); the left hand at the chest (A `Ep155SomeNoMaiTsukishiro1.png`);
the ribbon hanging to the plaza. **Walk.** 摺り足, no head bob. **Run.** Crouched, the blade trailing level behind (A
`Ep411RukiaRunsZabimaru.png`).

| # | Archetype | Body in one line | Grade | Slot |
|---|---|---|---|---|
| J1 | 回り | a quarter turn ⟲ on the ball of the right foot, hips low; the extended arm carries the blade flat across at chest height, the left hand at the chest [H→ / B1] | D (⟲ from the canon release, A) | J1 `:ru-j1` 1.44 m, 100° |
| J2 | 回り (turning back) | a quarter turn ⟳ back; the wrist turns over: a rising backhand from her left hip to above the right shoulder, the ribbon flipping over the blade [↗ / B1b] | D | J2 1.32 m, 100° |
| J3 | 回り, finale | a full turn ⟲, a key every 90°, arms in a T (blade flat at arm's length, left arm out), the hakama belling, the ribbon closing the hip ring; ends in a small 決まり, left hand back at the chest [⟲ / B1] | A (hip ring, ⟲) + D | J3 1.56 m, 200° |
| K1 | 剣舞・摺り足 | from the two-hand high guard (hilt at the right temple, blade level at him, A ch. 235) a 0.5 m glide without lifting the feet and a two-hand thrust at the head line [T-hi / B2] | A (guard) + D | K1 cap 2.8 m |
| K2 | 剣舞 | the hips turn out of the thrust: a two-hand cut across the waist, the sleeves flaring, weight to the back foot [H← / B2] | D | K2 2.5 m, 140° |
| K3 | 剣舞 → 見得 | a step in, the blade raised straight overhead in both hands (A ch. 469, Ep385), held 3 f, dropped; then the 見得: the low finish held 12+ f, the head rolling up to him last, the ribbon settling; snow burst (as built) [V↓ / B2] | A (raise) + C (見得) + D | K3 cap 2.7 m |
| L | canon 月白 (能・円) | the blade reversed point-down, a glow (A); she sinks into the deep crouch (A) and sweeps round ⟲ so the tip draws the circle on the plaza (A), the ribbon a hip ring (A); rises and turns half away (A "walks away") [G / B1r] | **A** | L `:ru-tsukishiro` (cast ≤ 8 m) and its K → L copy (the same figure, shortened) |
| SP1 | canon 白漣 (巫女舞 + 足拍子) | one stab at her feet (the circle, A), then each held step a stab in a half circle before her (A), each with a foot stamp (C); then the two-hand high guard, the ribbon straight up (A ch. 235); release: the blade swept down-forward from the guard [stab + ↘ / B2] | **A** + C | SP1 `:ru-hakuren` (held 1–4) |
| SP2 | canon 白刀 (仕舞 サシコミ・ヒラキ) | サシコミ: the right arm rises from low and drives straight at his face (A ch. 268), the ice growing in three steps; on the hit, the shatter: either the canon downward slash (A) or ヒラキ, three steps back opening both arms (C) [T / B1] | **A** + C | SP2 cap 5.0 m; the 霜の層 shatter |
| O | 回り (reversed) + shunpo | the crouched shunpo run, blade trailing level (A Ep411); then a turn ⟳ (against J3's ⟲) with the blade raised overhead in two hands, descending in a spiral to the waist [⟳ / B2] | A (run) + D | O `:ru-kikon` 2.4 m, 360° (its own clips, not `:sh-run` / `:ru-spin`) |
| I | 仕舞 サシ | a low dash; the left arm rises from the side and points forward-high, two fingers (A ch. 266, the rope from her hand; C サシ), the blade kept low and back point-down [pt / P] | A + C | I `:ru-breaker`, universal reach 2.6 |

Check: J1 H→ B1, J2 ↗ B1b, J3 ⟲ B1, K1 T-hi B2, K2 H← B2, K3 V↓ B2, L G B1r, SP1 stab + ↘ B2, SP2 T B1, O ⟳ B2,
I pt P. Unique. Intro: the canon release (A, as built). Win: the blade lowered point-down, turned half away (A, as built).

### 3.2 −18 °C 氷点下十八度 (the body adjusting: 摺り足 for J, 袖・素手 for K)

**Idle.** The canon catch posture: the left arm forward-high, palm open to him, the blade low and back in the right hand
(A `SodeNoShirayuki.gif` 12.6–13.8 s); hips lower than the Shikai's; breath puffs (as built).

| # | Archetype | Body in one line | Grade | Slot |
|---|---|---|---|---|
| J1 | 摺り足 | a 0.3 m glide, no step; a short cut from the right shoulder down across, the body level [↘ / B1] | D | J1 1.44 m |
| J2 | 摺り足 | the glide goes on; a short backhand up from the left knee, wrist turned [↖ / B1b] | D | J2 1.32 m |
| J3 | 摺り足, finale: the pass | a fast glide across his line to her left, a flat cut at chest height as she passes, ending side-on, back half turned, still (A the −18 pass, ends behind); the root stays inside the drawn reach [H← / B1] | A + D | J3 1.56 m, 200° |
| K1 TŌSHU | 袖・素手 (the catch) | the left arm rises forward-high, the palm open to him (A), the right sleeve swung back as counterweight; frost blooms on the palm [T / P] | **A** | K1 cap 2.0 m |
| K2 | 袖 | the right sleeve flung across first, the blade following under it, low across [H→ / S + B1] | C + D | K2 2.5 m, 140° (today the shared `:ru-ring`) |
| K3 HYŌKA | 袖・素手 → 見得 | down on one knee, the left palm laid flat on the plaza (as built), the sleeve pooling; the ice flower; held, the head up last [V↓ / P] | D | K3 2.4 m, 160° |
| L 霜柱 | 巫女舞 | the blade point-down tapped into the plaza at her feet while she turns a half circle on the spot: the ring of pillars [stab + ⟲ / B1r] | D | L disc r 2.5 (today `:ru-stab`, shared with SP1) |
| SP1 | canon 白漣 (摺り足) | one-hand stabs, a sideways glide between them (a half circle walked); release: the blade swept up from the last stab [stab + ↗ / B1] | A + D | SP1 |
| SP2 | canon 白刀 | the glide in first, then the one-arm thrust, ice to 5 m [T / B1] | **A** | SP2 cap 5.0 m |
| O 白霞罸 | canon battle stance | the blade raised overhead one-handed (A), held while the pillar rises at her; levelled at him (A), the cold off the tip [V↑ + level / B1] | **A** | O lane 6.5 m |
| I | サシ (low) | two fingers flicked from the hip out and up, the blade low [pt ↗ / P] | C + D | I |

Check: J1 ↘ B1, J2 ↖ B1b, J3 H← B1, K1 T P, K2 H→ S+B1, K3 V↓ P, L stab+⟲ B1r, SP1 stab+↗ B1, SP2 T B1, O V↑ B1,
I pt P (from the hip, against K1's palm forward-high). Unique.

### 3.3 −50 °C 氷点下五十度 (the quake: 足拍子 for J, both palms for K; heavier and lower)

**Idle.** Deeper knees, both hands near the hilt, the ribbon stiff with frost (as built `:ru-rime`).

| # | Archetype | Body in one line | Grade | Slot |
|---|---|---|---|---|
| J1 | 足拍子 | the right foot stamps as a two-hand short chop lands at the waist [↘ / B2] | C + D | J1 1.58 m |
| J2 | 足拍子 | the left foot stamps; a two-hand rising cut [↗ / B2] | D | J2 1.45 m |
| J3 | 足拍子, finale | a low two-hand half-turn sweep at knee height, ending on a double stamp (as built: two hands, low) [H← low / B2] | D | J3 1.72 m, 200° |
| K1 | 両掌 | the left palm forward-low, the blade's point driven in beside it (as built `:ru-palm-50`) [T / P + B1] | D | K1 cap 2.2 m |
| K2 | 両掌 (the ice wall) | both palms swept up from the plaza, the blade held reversed along the right forearm; a wall of ice shards rises [V↑ / P2] | A (the wall exists; its motion is not shown) + D | K2 2.75 m, 140° |
| K3 | 両掌 → 見得 | both palms driven down (as built), held [V↓ / P2] | D | K3 2.64 m |
| L 氷震 | 足拍子 | two stamps (left, right), then both hands drive the blade into the plaza (as built `:ru-stab-2h`): the quake [stab / B2] | A (the quake) + C | L disc r 3.5 |
| SP1 | 白漣 by stamps | the stabs become stamps (each stamp raises a spike), the blade held two-handed at the hip; release: swept low across the plaza [H→ low / B2] | A (spikes, wave) + C + D | SP1 (a stamp per 12 f) |
| SP2 | 白刀, two hands | a two-hand low thrust rising to his chest, the back knee near the plaza [T low / B2] | A (ice blade) + D | SP2 cap 6.0 m |
| O 白霞罸 | canon battle stance | the two-hand overhead raise (A), held, levelled [V↑ + level / B2] | **A** | O lane 7.5 m |
| I | サシ + 足拍子 | a stamp, then the two-finger point forward [pt / P] | C | I |

Check: J1 ↘ B2, J2 ↗ B2, J3 H← low B2, K1 T P+B1, K2 V↑ P2, K3 V↓ P2, L stab B2, SP1 H→ low B2, SP2 T-low B2,
O V↑ B2 (two hands on the hilt, against K2's open palms), I pt P. Unique.

### 3.4 −273.15 °C 絶対零度 (rooted: 地唄舞「雪」; 扇の手 for J, サシ / 袖 for K; feet never move, 序破急)

**Idle.** Upright, the blade point-down low across her (A the Bankai's still figure, `Ep385RukiaBankaiHakkaNoTogame.png`), the
head a little bowed (as built), no breath; only the ribbon moves.

| # | Archetype | Body in one line | Grade | Slot |
|---|---|---|---|---|
| J1 | 扇の手 | wrist only: from point-down the wrist flips the ice blade up and flat across at chest height (序 still, 破 the flick, 急 the stop); the elbow barely moves [H→ / B1] | C + D | J1 1.94 m |
| J2 | 扇の手 | the wrist flips back: a backhand from high left down to low right, back to point-down [↙ / B1b] | D | J2 1.78 m (today a palm clip sped up: replaced) |
| J3 | 扇の手, finale | the torso turns 60° on pinned feet, the blade raised and drawn round flat over her head (a halo), ending point-down, a stop [⟲ overhead / B1] | D | J3 2.11 m, 200° |
| K1 | サシ (the guard levelled) | from the two-hand vertical guard before her face (A Ep411) the blade tips forward slowly to level, then the ice shoots out [T / B2] | A (guard) + D | K1 cap 3.78 m |
| K2 | 袖 (袂払い) | the left sleeve brushes across before her at the waist, as if brushing snow off (C 「雪」), frost sheeting off it [H→ / S] | C + D | K2 3.38 m, 140° |
| K3 | 袖 → 見得 | a bow from the hips, the palm laid on the plaza, the ice flower; the head rises last [V↓ / P] | D | K3 3.24 m |
| L 零度凍結 | 地唄舞「雪」 | the eyes open; the left sleeve swept out low in a wide half circle, slow, then sudden (as built `:ru-reido`, re-timed) [H← low / S + P] | C | L disc r 5.5 |
| SP1 | canon 白漣, one stroke | the point lowered to the plaza once (A "punctures the ground once"), four spikes rise together; the blade raised toward him (A the Bankai's "raising her blade"): the wave [stab + V↑ / B1] | **A** | SP1 (no hold) |
| SP2 | canon 白刀 | the right arm raised straight forward, the ice growing 7.5 m in steps, the body still (A ch. 268) [T / B1] | **A** | SP2 cap 7.5 m |
| O 白霞罸 | the Bankai's still figure | no raise: from point-down across her, the blade levelled slowly toward him (A), the ribbons lifting [level ↗ / B1] | **A** | O lane 9.0 m |
| I | — | none at zero (rooted) | — | — |

Check: J1 H→ B1, J2 ↙ B1b, J3 ⟲ B1, K1 T B2, K2 H→ S, K3 V↓ P, L H← low S+P, SP1 stab+V↑ B1, SP2 T B1, O ↗ B1.
Unique.

### 3.5 Counts and order
- New strike clips: Shikai 11, −18 11, −50 11, −273 10 (43, against 31 shared today), plus idle / walk / run per form.
- The skill's order: one form at a time, its look before its strikes; measure the drawn tip per frame before rendering
  (FK ±0.15 m); a key every 90° in the turns; the hit pose on S.

## 4. Gaps
- **No dance seen in motion.** Every archetype body is from encyclopedia text. Close: a nihon buyō basics video (摺り足,
  回り, 扇の返し), a Noh shimai (サシコミ・ヒラキ, 足拍子), Takehara Han's 「雪」, a Sagi Musume recording, a shigin kenbu
  performance; log the timings (wind-up, motion, hold).
- **Fan technique names** (要返し, かざし, ちらし, 招き): only 要返し and throwing / spinning are confirmed (ja.wikipedia 舞扇);
  the others' exact forms were not found.
- **見得 for onnagata** (female roles) was not found; the kabuki 見得 source describes the male, aragoto form.
- 鷺娘 and 見得 are C from search summaries (Wikipedia rate-limited).
- The motion bars use today's volumes; the 霜の層 Shikai may change them (re-read before the plan is approved).

## 5. Sources
- ja.wikipedia (API extracts, 2026-10-24): 日本舞踊 https://ja.wikipedia.org/wiki/日本舞踊 ; 仕舞 https://ja.wikipedia.org/wiki/仕舞 ;
  摺り足 https://ja.wikipedia.org/wiki/摺り足 ; 舞扇 https://ja.wikipedia.org/wiki/舞扇 ; 上方舞 https://ja.wikipedia.org/wiki/上方舞 ;
  雪 (地唄) https://ja.wikipedia.org/wiki/雪_(地唄) ; 巫女舞 https://ja.wikipedia.org/wiki/巫女舞 ;
  京鹿子娘道成寺 https://ja.wikipedia.org/wiki/京鹿子娘道成寺 ; 剣舞 https://ja.wikipedia.org/wiki/剣舞
- en.wikipedia: Kenshibu https://en.wikipedia.org/wiki/Kenshibu ; Ribbon (rhythmic gymnastics)
  https://en.wikipedia.org/wiki/Ribbon_(rhythmic_gymnastics) (search summary)
- Search summaries (C): 鷺娘: https://www.daily.co.jp/gossip/kabuki/2016/11/22/0009629846.shtml ,
  https://www.fun-japan.jp/jp/articles/14337 , https://kotobank.jp/word/%E9%B7%BA%E5%A8%98-68643 ; 見得:
  https://kotobank.jp/word/%E8%A6%8B%E5%BE%97 , https://allabout.co.jp/gm/gc/427223 ; kabuki glossary (mie, roppo):
  https://japanpitt.pitt.edu/glossary/mie ; body and 落とし: https://ipsj.ixsq.nii.ac.jp/record/109074/files/IPSJ-Z73-6ZA-6.pdf ;
  mai-ōgi weights: https://www.sg.emb-japan.go.jp/JCC/E-Magazine-Aug-2021-Folding-Fans.html
- BLEACH canon and RoS: see `canon-motion.md` and `canon-looks.md`.
