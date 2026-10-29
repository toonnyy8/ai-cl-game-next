# Motion style: evidence from Kenpachi's rework and the new Lille's motion modules (2026-10-08 → 10-13)

Sources: KR = docs/duel/DUEL_KEN_REWORK.md; V3 = docs/duel/DUEL_LILLE_V3.md; DL = docs/duel/DUEL_LILLE.md; DV = docs/DEVLOG.zh-TW.md;
MS = docs/research/lille2-motion-styles/notes.md; MR / CL / BR = docs/research/kenpachi-rework/{motion-refs,canon-looks,bankai-refs}.md;
RD = docs/research/lille-retrospective/digest.md. "[G]" in the sources = the lead's proposal, not the user's or canon.

## 1. Deciding the style

**Starting points**
- *Canon-driven* (Kenpachi): 「…調整劍八的動作與造型模組，在開始工作前記得先收集與調查各種型態的資料」 (KR §1, DV §141).
- *Concept words* (Lille II): 「陀螺旋朝前方傾斜轉三圈…零距離砲擊…光翼拉伸如同長鞭…如同大刀一般遲緩而沈重的揮砍」 (V3 §10).
  - Follow-up answers: 「我只是提概念，請以此延伸自由組合」 and reach 「跟著動作走」.
  - Then: 「長鞭可以連成大砍刀，砲擊也可以接在近距離毆打後面，請調查一般格鬥遊戲/動漫風格對戰遊戲常會有強烈風格的戰鬥動作」 (V3 §10.2, DV §194).
- *Named games / scenes*: 「大刀的揮舞動作請對魔物獵人進行調查，身體動作大而誇張，可以進行形變」 (V3 §13); 一霧銀 for dash-through-then-cuts (V3 §14).
- *Style transfer*: 「用覺醒狀態的…動作模組的設計風格重製常態模式」, asked per button: L 「蓄力狙擊」, J 「槍鬥術」, K 「槍身重揮」 (V3 §19).
- *Vague feedback*: 「動作不太明顯」 (DL §23.31), 「有張力一點…像 Jilliel…一樣帥氣」 (DL §23.37), 「更加明顯大膽」 (V3 §24.1).

**Questions offered**
- Kenpachi: four AskUserQuestions, recommended option first, with the rejected options recorded (KR §4):
  - scope: 「逐型態：模型＋動作一起做」 (one form at a time, the look first, then its strikes);
  - the weapon: 「改成原作形狀，大小貼合現有判定」 (canon shape at the current reach);
  - the eyepatch;
  - which look items follow canon.
- Kenpachi, then a motion-plan table per form, approved with 「可以」 before the build (KR §5.2, §6.2, §8).
- Old Lille: four composable directions; the user took all four: 「全身出招」「每招獨立造型」「翼尖斬痕」「八翼一起斬」 (DL §23.31).
- The owl: a style label 「猛禽爪擊」 plus four extras (DL §23.37).
- RD §3 names the question that would have saved churn: "the motion bar". Does every strike get its own silhouette and whole-body motion? Name one reference clip set as the bar for every form.

**Canon vs invented**
- Claims are graded A–D; "D = a design proposal, not a reference" (MR).
- A user decision is labelled as the user's, not canon: "no eyepatch" (KR §3, CL §8).
- References can reverse a user's pick: KATAUDE went from 「換左手拿刀」 to 「改成空手（照原作）」 after the stills showed no left-hand blade (KR §8).
- Lille II's modules are invented, marked [G] (V3 §10.2).

**Decided per form**
- Kenpachi:
  - base: the canon bar MR §3.1; K3 kept the spin (「維持旋轉斬」, KR §5.2);
  - Nozarashi: KATATE "mass leads, body follows"; RYOTE adds fumikomi; NOMIHOSE gets its own set (KR §6.2);
  - Bankai: beast hacks, the bite with a wrench, a prowl and a roaring back leap (KR §8).
- Lille II awakened:
  - R5: J snake sword, K great sword → blast, L spinning top;
  - R9: J the top, J→LL whips, K three great-sword cuts, L a dash through him (V3 §10.2, §14).
- Lille II base (R15): gun-kata, the rifle as a club, the charged snipe (V3 §19).

## 2. Gathering references

**Sources**
- Canon fights via the wiki's chapter summaries.
- Official game kits: RoS, Soul Resonance, Brave Souls (MR §1–§2).
- Trope catalogues, wikis and guides for archetypes (MS).
- Monster Hunter guides plus animation-principle pages, for weight (MS).
- Images: 49 for the old Lille, with per-form contact sheets and an INDEX.md (DL §17); 18 Bankai stills plus crops (BR).
- User photos: cgtrader's Nozarashi elevations, traced, not bought (KR §6.1); four figure photos (KR §8).
- Gaps are written down with how to close them, e.g. "watch ep. 20 for the cut timings" (MR §4).

**Fetch**
- WebFetch failed, so pages came through curl.
- bleach.fandom answered 403, but its MediaWiki API worked: `prop=wikitext` / `imageinfo`, `path-prefix=en` (else a 520 B placeholder), `format=original` (else WebP) (BR, model sheet §0).
- No video was watched; the motion came from text (MR).

**Grading**
- Motion: A canon text, B official game text, C secondary, D own inference (MR).
- Looks: [A] seen in a still / [B] / [C] (CL); [V] / [A] / [G] / [I] plus [seen: file] (the model sheet).
- [high] / [med] / [low] by independent agreement when only search summaries were reachable (the tybw lille_barro note).
- Anime stills are colour-graded by the scene: sample colours from the manga's digital colour (CL §0).
- A conflicts table (CL §8).

**Formats**
- An archetype table: Archetype | Examples | **What makes it read**, then "the choice" (string → archetype → motion → reach) (MS).
- Fight-by-fight canon, then a graded signature-habits table (MR §1.10).
- A motion bar per form: # | Archetype | Body (one line) | Source grade | Slot, plus idle, walk and run (MR §3).
- An image table: File | URL | What it shows, plus "poses each supports", "dropped" and "could not see" (BR).

**Storage**
- `docs/research/<topic>/`: committed, in English, with sources.
- `.refs/<topic>/`: the images, git-ignored, third-party.

**Useful vs wasted**
- Useful:
  - graded canon gave concrete strikes, so the approved plans needed no motion rework;
  - the images corrected the structure (no cloak, the rifle's shape);
  - the "what makes it read" column.
- Wasted:
  - the first image pass (hosts blocked) produced URLs only (DV §84);
  - explainer sites were dropped unopened (model sheet §0);
  - some of MR's slot suggestions were impossible because of the move's volume (K3).

## 3. Planning into modules

**Mapping rules**
- **No two strikes share an arc plane and a hand set**; vary the plane, hands, travel and end pose (MR §3).
- One archetype per string, and the user's combinations become the finales: J3's whips snap into a cleaver; K3's close blows end in the blast (MS).
- One hit a press, so one archetype beat a press: 「段數跟操作時的點擊次數一致」 (V3 §12).
- A route gets its own clips: 「最後一段 LL 會依據前面 J/K 有不同的動作模組」 (V3 §8.5).
- Each form uses its own clips at its own frames, never a sibling's clip sped up (DL §23.31, §23.37).
- Borrowed upright clips stood the crouched oni up for every strike (KR §2.2).
- The strings keep their roles and frame data (L even, J rapid, K heavy) (MS).

**Inventory** (V3 §1)
- Columns: Clip | S / A / R | Motion | old use | current use | proposed use.
- Grouped by form, with the spares listed; spares can be "revived" into new slots.
- Kenpachi's diagnosis: stills of every form and a 4-frame strip of each of his 53 clips (KR §2).

**Timing and keys**
- The hit pose sits on S. Openers hit once at S with A 2.
- Heavier strings start later: J3 S 14, K1 S 16, K1 / K2 / K3 S 16 / 12 / 18 (V3 §12, §14).
- Charged slash (V3 §14):
  - four snap keys through the arc, f12–15, the arm 228 → 214 → 192 → 168 (accelerating);
  - the slam at f16, held f18–22.
- Gun-kata (V3 §20):
  - S 8 → 10;
  - **a key about every 90° of a spin**;
  - moving holds in the wind-up; the hips lead and the weapon trails.
- Snipe level 1: S 8 → 16 for a breath and a squeeze (V3 §20).
- A segment starts from its predecessor's pose at S + A, so a spin carries across links (V3 §10.2).

**Squash and stretch**
- A generic kit `:pose` hook. `br-deform` scales about the feet: up × SY, sideways × SX, **never along the facing axis** (V3 §13).
- K1: stretched 1.18 / 0.88; the squat tell at f14; squashed 0.74 / 1.3 on the slam, held to f21. J3: 0.78 / 1.25 (V3 §13).
- Base K3: from 1.22 tall to 0.7 / 1.34 flat (V3 §19.2). Base K: sideways ≤ 1.05, "so the reach stays honest" (V3 §24.1).

**Reach**
- The FK test wants the drawn tip within ±0.15 m of the hit volume's edge.
- 「跟著動作走」 means the drawn tip sets `*BR-W-TIPS*`. K1's reach went 2.45 → 2.95 m: a sim change, and gated (V3 §13).
- Kenpachi went the other way: the canon cleaver was sized to the existing reach (KR §6.1).
- Read `:arc` / `:vol` first: a thrust on a 360° spin would hit behind him (KR §5.2).
- Check every form that plays a clip (KATAUDE ×0.7 overshot by 0.58 m).

**Measure before rendering**
- A host script printed the tip per frame and found K1 / K2 drawn 1.6–1.7 m short (the before / after table, KR §5.2).
- Hit poses are solved:
  - the owl's claws from FK targets (DL §23.37);
  - the muzzle at az −2…−7°, ≤ 0.1 m aside (V3 §8.3);
  - `tools/pose-solve.py` grid-searches hand twist / flex for a blade az / el.
- In the repo: `*br-tip-print*` in `tests/duel-rules/core.lisp`. Kenpachi's script is not committed.

**Review loop**
- `duel-view` strips 1000000+1000i+k (k 1: 8 frames from the side; k 2: 33° off the front); a 4-frame strip hides the anticipation.
- The weapon alone: 4100+k. Lille: 82100+k (+20 the front view), 82200+f, 82320+m.
- Contact sheets per key (wind-up, before, hit, follow-through, recovery) from the behind and side cameras, plus before/after strips (DL §23.31).
- Say "checked by numbers, needs your eyes"; one playtest Artifact version per round.

**Rounds**
- Kenpachi: one round per form (v35–v38), with an approved plan, presentation only.
- Lille II awakened: R5 → R11, 6 rounds (v62–v68); rule changes and read failures came in between.
- Lille II base: R15 → R16 → R19.
- Old Lille's wings: 5 decisions (RD §2E).

## 4. Failures and fixes

- **The whip read as a shot**:
  - R10: the sim's 31 m line was drawn over the whip;
  - R11: the "whip" was a 3-frame straight line, i.e. a beam;
  - fix: a 16-segment tapered ribbon with lag × s^1.4 (base leads, tip snaps), slack, drawn back, a crack sound, three distinct lashes (V3 §15–§16, DV §199, §201).
- **An invisible turn**: K3 turned only the pelvis. Fix: root yaw plus a pelvis roll of −10…−24° (V3 §15).
- **Too few keys**: the charged slash and the gun-kata; see Timing (V3 §14, §20).
- **Short or long art**:
  - Kenpachi K1 / K2 drawn 1.6–1.7 m short;
  - KATAUDE 0.58 m long;
  - wrist values guessed from 4-frame strips cost two builds (rework ref §8).
- **Borrowed clips**:
  - the oni stood up for every strike;
  - EN played KIN's clips sped up;
  - the owl played "one move six times" (DL §23.37).
- **Read failures**:
  - weapon parented to the arm: "arms like wings";
  - the trail drawn as a "jade plank";
  - the wings face-on hid the strike (RD §5).
- **The blast as a beam**: 「直接在爆炸點炸開光球」 (V3 §11).
- **A body-swap pop**: legs folded over the turn (V3 §16).
- **Spins**:
  - two keys 0.0001 f apart, the yaw 360° apart;
  - stance poses moved the strike points, so hit poses set the spine, arm and elbows (DL §23.31).
- **A sim change cost art**: r5-art lost 8 clips (move-modules ref §7).
- **Known**: base K3's plank dips into the floor (V3 §24.1).

## 5. Hisagi's Bankai chains (2026-10-29, DUEL_HISAGI §28.9–§28.26)

**The rounds**
- §28.9: the slot plan, 13 new clips, approved with 「可以」 → 2a / 2b. The art followed the reach (presentation only).
- §28.15: the hooks on the bearing; J3 / J4 their own clips. They had been J1's / J2's (「J 五連裡有兩對動作一樣」).
- §28.18 → §28.19: 「單從鎖鏈的揮舞來看完全看不出每段之間的差異」. A path table per link; 散 approved (「散可以」), built as 4a.
- §28.20 → §28.21: 聚 cut to three links (「連同 SA 縮成三段 直刺 → 上撈 → 繞身連枷」), the sim first, then the looks (4b).
- §28.23 → §28.24: 「上撈我希望呈現由近到遠向上抽起的感覺」, 「由慢至快加速橫掃」, 「缺少了由緩至急的續力與放出的打擊感」 → the
  rhythm rule (4c). Then 「善哉，幫我套用」 on the other five 聚 moves (§28.25 → §28.26, 4d).

**What made the paths read**
- 散 thin chains, 聚 one thick bundle: the theme lives in the weapon's thickness too.
- One shape per link: J2 the X, J3 the floor S, J4 the whirl and fling, J5 the six-start helix. Each has a trail of its own
  (`%hs-lo-trail`, `%hs-trail`, `%hs-g-look`).
- A string reads by its paths only from the match camera. Strips alone hid that J2's hanging chains never crossed in view.
- Bending tools: `*hs-waves*` bends a hanging chain's middle (lateral S, vertical S, helix), zero at the knee and at the free end.
  `*hs-letout*` lets a crescent out from the hand, its AZ / H a list swept over the frames.

**The rhythm, as measured** (the bundle end's speed, m a frame, a scratch printout of `%hs-lash-tip!`)
- SA: charge ≤ 0.32, hold ≤ 0.10, release **0.38 1.94 2.31**.
- J2: hold ≤ 0.08, release **0.81 1.26 1.73**.
- J3: charge ≤ 1.1 (it carries the end ~10 m), hold ≤ 0.12, release **0.51 2.27 5.22**.
- TABA before / after: a 9 f drift then 5.85 in one step → hold ≤ 0.12, release **1.90 3.00 3.88**.
- A clip played at 0.9 (`:clip-s` 27, S 30): plan in move frames and key at clip = 0.9 × move frame.

**Cinematics, from storyboards**
- 「先畫分鏡給我」: a beat table per pointer (f | camera | action), approved, then built (3a / 3b). Recorded per beat: the deviations,
  such as the orb that "cannot open as a mesh" and is drawn as a crack of light.
- 0 B per frame: the new looks use DEFUN-FAST on fixnums / f32vecs, derived from the cine frame alone. A first draft with FX-LINE's
  float arguments consed 13–200 KB per 10 calls. Probe twice: the first pass grows the fx buffer once.
