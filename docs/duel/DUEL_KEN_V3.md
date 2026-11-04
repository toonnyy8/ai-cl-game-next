# DUEL_KEN_V3 — Kenpachi from zero: three forms by weapon, pointers by grip (2026-11-02, in design)

User's request (verbatim, 2026-11-02): 「我想要拋棄當前劍八的設計並從頭開始規劃整體的動作模組、架式概念」. It replaces the
redesign in progress (DUEL_KEN_CORE §7–§8: the cadence batch, no KATAUDE, the Bankai on the core system); that code stays in
the build until this design replaces it.

## 1. Decisions (asked with AskUserQuestion, answered verbatim)

| Question | Answer |
|---|---|
| How far to throw away | 「全部歸零」: the forms, how they are entered, and the shared mechanics (the startup tier, the hitstop by damage, the arm as fuel) are all open again. |
| What ties the three pointers together | 「握法與刀位」: each pointer is a way of holding the blade (grip and blade position); where the blade sits tells the opponent which pointer comes next. |
| References | 「沿用現有研究」: `docs/research/kenpachi-rework/combat-refs.md` (DEVLOG §555), no new research round. |
| Order | 「先出整體總表」: one table of every form × three pointers (theme, stance, Kikon) first, then each form's segment table. |
| The forms (the grip now splits the pointers, so one hand / two hands no longer splits the forms) | 「常態：封印，覺醒：始解，再覺醒：卍解」: three forms by weapon. KATATE / RYOTE / NOMIHOSE (the NOME cups) go. |
| How a form goes up | 「覺醒鍵，其他角色覺醒又不是扣魂魄」: the awaken key (Mod+P). Correction to my option text, which said it costs Konpaku: it does not. The awakening takes a full awakening gauge, the second awakening a full SPIRIT DRIVE (DUEL_SUBLIMATION §3, Kenpachi's Bankai rule since 2026-10-31). |

The user's earlier weight order (DUEL_KEN_CORE §7.2, 2026-11-02): 「武器重量以武士刀最輕，卍解的片手斧次之，始解的大刀最為沉重」.

## 2. The overall table (draft, for the user's approval)

Grades as in combat-refs.md: A canon, D my proposal. Canon beats from combat-refs §5 / `motion-refs.md` §1.

| Form (entry) | Ptr | Grip and blade position (the stance) | Theme | NS shape | AS n | Kikon |
|---|---|---|---|---|---|---|
| Sealed katana (base) | 1 | one hand, the blade hanging, tip dragging on the floor (A, §1.2 approach) | rising cuts, pressure | drag-up cut → back-hand chop → flat sweep | AS1: the rising cut that steals | the bells, behind him, a rising cut (A, §1.2) |
| | 2 | one hand, the blade on the shoulder, chest open (A, "cut me anywhere") | take the hit, cut back | armoured from the startup, the shoulder drop (Zornhau, D) | AS2: grabs the blade, twists him down, stabs (A, §1.2) | takes a cut on the chest, laughs, cuts back |
| | 3 | two hands, chūdan (kendo, A: vs Nnoitra) | read and punish | a still tame → thrust → men cut | AS3: the thrust through the guard (A, §1.2) | the one kendo cut |
| Shikai Nozarashi (awaken) | 1 | one hand, the blade laid behind the back, edge out (D) | the wheel | turning sweeps, each the other side (montante, combat-refs §2) | AS1: the turning sweep | the full turn |
| | 2 | two hands, jōdan, raised high (D) | the drop | the longest tame → one vertical drop | AS2: leaps, cuts down mid-leap (A, §1.7 the meteor) | the meteor cut |
| | 3 | the blade planted in the floor, hands free (D: the act is canon, `motion-refs.md` §1.4 vs Nnoitra, ch. 307–312, but with the **sealed** katana and only for one beat, not a stance; asked by the user) | bare hands | kick → grab the head, slam → vault off the hilt | AS3: plant → yank → slam → the stab down (A, §1.4) | pulls it out of the floor in a rising cut |
| Bankai (second awakening) | 1 | the left claw forward, the blade trailing behind (A, §1.9) | the maw | claw lunge → bite → rip | AS1: bites the knuckle, rips the arm (A, §1.9) | the bite |
| | 2 | crouched low, the blade along the floor (D, the beast) | the leap | leap cut → flat-side hammer | AS2: the chin punch → the leap cut down (A, §1.9) | the roar, then the pounce (A, §1.9) |
| | 3 | two hands, overhead (A, §1.9) | the self-destroying arm | arm-breaking cuts → the vertical split | AS3: leap cut → chin punch → TATE-GOTO (A, §1.9) | TATE-GOTO |

Each form's own verb and cost (combat-refs §1 point 1, "the form that gains power loses something") are not proposed yet: they come
after this table, as do the startups and hitstops (all open since 「全部歸零」).

## 3. Simple, direct, satisfying: the Shikai's unlock and the Bankai as its cash-out (the user, 2026-11-02)

Verbatim, replacing §2's Shikai and Bankai rows:

> 我想將劍八設計成簡單、直白、爽快的角色
> * 始解・野晒只由兩種指針組成，卍解則只有始解的特規（稍後解釋）
> * 始解的特性是當重複使用固定指針造成有效傷害時，NS/AS 會不斷解放新的段數（累積強化）。切換指針時的 AS 會依據解放程度做出對應強化（爆發）並重製解放程度（弱化），臨時切換時會沿用原指針的解放程度且不會觸發重製。
> * 當始解的特定指針解放到最高階段時會開放追加特殊 J 連段，特殊 J 連段沒打滿就放出 AS 時會使出該指針的特殊 AS，如果打滿才放出 AS 則會觸發卍解。
> * 卍解會依據解放時所處的指針得到不同的 NS 與 AS，且進入卍解後只有一套指針與打滿 J 才能釋放的特殊 AS。
> * 卍解每次使用 NS 與 AS 都會對自己造成傷害，最多扣至剩 1 點血量。特殊 AS 會在造成高額傷害（可以接毀魂技）並扣除 1 魂後回到始解。

My reading (to confirm): the Shikai has two pointers, each with an unlock level; landing that pointer's moves raises it and adds NS / AS
segments; an AS that switches pointer cashes the level in (a stronger AS) and resets it; at the top level a special J string opens:
AS before its last link = that pointer's special AS, AS after its last link = the Bankai (two Bankai, one per Shikai pointer); the Bankai has
one pointer, every NS / AS costs him Reiatsu down to 1, and its special AS (after a full J string) hits hard, can take the Kikon, costs him
1 Konpaku and returns him to the Shikai. 毀魂技 = the Kikon (DUEL_CORE §4).

Asked, answered (verbatim):

| Question | Answer |
|---|---|
| The sealed form, now that the Bankai comes from the Shikai's special J string | 「保留封印，覺醒進始解」: the sealed katana is the start, the awakening (Mod+P, a full awakening gauge) the Shikai; the Bankai only through the Shikai's special J string (replaces §1's 「再覺醒：卍解」). |
| 「臨時切換」 | 「我不是有設計一特新系統，可以消耗 25％ 的 drive 量表在 NS 攻擊時可以臨時切換到另一個 NS 嗎」: the temporary pointer switch (DUEL_SUBLIMATION §17: left / right + SP in an NS gap, 0.25 B of SPIRIT DRIVE, back to the pointer when the NS ends). In the Shikai the switched-to NS uses the original pointer's unlock level and resets nothing. |
| 「有效傷害」 | 「打中才算」: an unguarded hit; guarded, cancelled or whiffed moves do not count. |
| What else drops the unlock level | 「只有切換會歸零」: nothing else (taking hits, time). |

## 4. The rules as I read them, with my numbers as knobs (draft, for the user's yes / no)

**Shikai (two pointers, one unlock level L).** Switching resets L, so only the current pointer's level ever exists: one counter, tied to the pointer.

| # | Rule | Knob (mine) |
|---|---|---|
| S1 | L runs 0 → 3 and belongs to the current pointer; a match, the awakening and a return from the Bankai start it at 0 | max 3 |
| S2 | +1 L for each NS route or same-pointer AS that lands at least one unguarded hit (once per route, not per hit); guarded / cancelled / whiffed: +0. **Since §13: once per combo** | 1 per route → 1 per combo |
| S3 | Segments by L: NS 1 + L (cap 3), AS 1 + L (cap 3) | L0 1/1, L1 2/2, L2+ 3/3 |
| S4 | Which pointer an AS writes: the core's press count (J1–J2 + SP → pointer 1's AS, J3+ + SP → pointer 2's AS) | `:as-by-press` |
| S5 | An AS that writes the **other** pointer is the burst: its segments 1 + the old L, damage × (1 + 0.2 L); then L = 0 on the new pointer | ×1.0 / 1.2 / 1.4 / 1.6 |
| S6 | The temporary switch (DUEL_SUBLIMATION §17, 0.25 B of DRIVE): the other pointer's NS with 1 + L segments; its hits count for L; no reset | |
| S7 | At L3 the J string goes on: two special links J6, J7 | 2 links |
| S8 | SP after J6 (not the last) = the pointer's special AS; SP after J7 (the last) = the Bankai, the variant by the pointer | |
| S9 | Entering the Bankai sets L = 0 | |

**Bankai (one pointer, the variant by the Shikai pointer it came from).**

| # | Rule | Knob (mine) |
|---|---|---|
| B1 | One NS route (3 segments), the AS by press count as usual, the J string to J5; SP after J5 = the special AS | |
| B2 | Every NS segment and every AS costs him Reiatsu, never below 1 (so it never Soul-Breaks him by itself) | 40 a use (about 3% of 1300) |
| B3 | The special AS: heavy damage, the Kikon hold works on it, then he loses 1 Konpaku and returns to the Shikai on the pointer he entered from, L 0 | |

**Worked routes.**
1. Shikai pointer 1, L0: NS1 lands (1 segment) → L1; NS1 lands (2 segments) → L2; J1 J2 + SP: AS1 lands (3 segments) → L3; J1…J5 J6 + SP = pointer 1's special AS.
2. The same at L3: J1…J7 + SP = the Bankai (pointer 1's variant), L 0.
3. Pointer 1 at L2: J3 + SP = AS2, the burst (3 segments, × 1.4); now pointer 2, L0.
4. Pointer 1 at L2, in an NS1 gap: right + SP (0.25 DRIVE) = pointer 2's NS with 3 segments; it lands → L3 on pointer 1; still pointer 1.
5. Bankai: NS (3 segments, −120 Reiatsu) → J1…J5 + SP = the special AS → the Kikon hold → −1 Konpaku, Shikai pointer 1, L0.

**Draft table.**

| Form | Ptr | Grip and blade position | Theme | Special AS |
|---|---|---|---|---|
| Sealed (start) | 1–3 | §2's three (drag / shoulder / kendo) unless the user simplifies it; the planted sword moves here (canon, §1.4: plant → yank → slam → stab down, as pointer 2's AS) | | — |
| Shikai | 1 | one hand, the blade behind the back, edge out | the wheel: turning sweeps, left / right | the full wheel |
| | 2 | two hands, jōdan | the drop: one vertical cut, the longest tame | the meteor cut (leaps, cuts down, canon §1.7) |
| Bankai from 1 | 1 | the left claw forward, the blade trailing | the maw: claw, bite, rip | bites the knuckle, rips the arm (canon §1.9) |
| Bankai from 2 | 1 | two hands overhead | the self-destroying arm | TATE-GOTO (canon §1.9) |

**To remove when this is built** (not yet): NOME and the cups (`ken-nome-step`, KATATE / RYOTE / NOMIHOSE), the arm's pips and burst
(`ken-arm-step`, `arm-spend!`, `arm-burst!`, `:params :pips`, `core-pips-ok-p`), KATAUDE, the cup-3 Bankai by SPIRIT DRIVE
(`bankai-allowed-p` for him), the DANGAI boss hook `ken-boss` and the 隨時卍解 card `ken-card-bankai`. G2 `--cvc` will move (IK and KK play
his sealed form). The CPU: the generic core CPU (it will not aim for L or the special J string) unless the user asks.

Asked, answered (verbatim):

| Question | Answer |
|---|---|
| How a Shikai AS keeps or switches the pointer | 「看 J 打幾段」: S4 as written (J1–J2 + SP → pointer 1, J3+ + SP → pointer 2). |
| The special AS on his last Konpaku | 「照樣放出、不扣魂」: it fires, costs nothing at 1 Konpaku, and he still returns to the Shikai. |
| The sealed form | 「維持三個指針」: §2's three (drag / shoulder / kendo), the core grammar, no unlock; the planted sword as pointer 2's AS. |
| The Shikai's two grips | 「我等等附上參考圖片討論架式」: open, the user brings reference pictures. |

The other numbers in §4 stand as my knobs until the playtest.

## 5. The Shikai's two stances and the user's corrections (the user, 2026-11-02)

Corrections to §4 (verbatim, each answering a line of my reply):

| My line | The user |
|---|---|
| the burst: segments 1 + the old L, damage × (1 + 0.2 L) | 「爆發的 AS 是完全重製的新動作」: the burst AS is its own new move, not the pointer's AS with more segments. |
| at L3 the J string gains J6, J7 | 「始解的 J 原始只有 J1~J3，解放後多出 J4~J7」: the Shikai's J string is J1–J3; the unlock adds J4–J7. |
| the planted sword moves to the sealed form's AS2 | 「不要插地了」: no planted sword anywhere. |
| L0: NS and AS one segment each | 「不一定只有一段」: the segment counts per level are designed per pointer. |

The stances (verbatim; pictures in the git-ignored `.refs/kenpachi-v3/`: a statue with the cleaver slung diagonally, the hilt low in
his right hand; a manga panel with the blade's back on his shoulder, the hilt forward):

> * 指針 1 斜扛大刀，身體半蹲前傾，呈現衝刺預備。整體攻擊手段是配合突進、迴旋斬擊與單手舞劍展現出充滿張力又凶悍戰鬥風格
> * 指針 2 一種將刀背扛在單肩上，刀柄對準前方，輕鬆站立。NS 第一段會將刀柄後收後向前敲擊，第二段些微下沉刀柄後用力上翹撞擊對手，第三段開始會用兩手握住上翹的刀柄並以大刀/特大劍的動作用力揮舞

### 5.1 Draft segment table (mine, for the user's approval)

Pointer 1 「突進迴旋」: the cleaver slung diagonally, the hilt low in the right hand, half-crouched, leaning forward (the dash tell: the crouch
deepens). Pointer 2 「扛肩柄擊」: the blade's back on the right shoulder, the hilt pointing at him, standing easy (the tell: the hilt drawn back).

| | Pointer 1 | Pointer 2 |
|---|---|---|
| NS at L0 | a the lunge cut (from the sling, a 3 m dash, a rising diagonal) → b the spin-through sweep | a the hilt drawn back, jabbed forward → b the hilt sunk, flicked up into him → c both hands on the raised hilt, the great-sword overhead cut |
| + L1 | c the reverse spin (the other side) | d the great-sword flat sweep |
| + L2 | d the one-hand sword dance (two quick figure-eight cuts) | e the turning great-sword cut |
| + L3 | e the spinning leap, cutting down | (none: L3 opens the J string instead) |
| AS (keeps the pointer) | J1–J2 + SP: the lunge cut → the spin; one more spin per L | J3 + SP: the hilt jab → both hands, the overhead cut; one more great-sword swing per L |
| Burst AS (switches; its own move, 1 segment, §5.2) | from pointer 2 (J1–J2 + SP): 「斬返」 the blade shrugged off the shoulder into one huge diagonal cut that drags round into the sling (pointer 1's stance) | from pointer 1 (J3 + SP): 「突進一閃」 one dash-through spin cut, the blade swung back onto the shoulder |
| Special AS | the full wheel (a spinning tornado) | the meteor cut (leaps, cuts down, canon §1.7) |
| Kikon | dashes through him, spins back | the hilt launches him, both hands cut him down |
| Bankai from it | the maw (claw forward, the blade trailing) | the self-destroying arm (overhead, TATE-GOTO) |

### 5.2 Asked, answered (verbatim)

| Question | Answer |
|---|---|
| How J4–J7 open | 「最高階一次開放」: all four at L3, the special J string: SP after J4–J6 = the special AS, after J7 = the Bankai; L0–L2 have J1–J3 only. |
| How the burst AS grows with L | 「固定動作、提高傷害，只有 1~2 段呈現簡短而強悍的一擊必殺風格，並通過調整特效來呈現不同階段的視覺表現。」: a fixed motion of 1–2 segments, a short one-blow-kill style; L raises only its damage, and the VFX shows the level. |

So the burst rows above are one segment each. Knobs (mine): damage 100 / 150 / 200 / 260 at L0–L3; the VFX by L: none / a Reiatsu spark /
the yellow Reiatsu column / the skull aura (his canon Reiatsu skull).

### 5.3 Corrections (the user, 2026-11-02, verbatim) and the revised table

| My line | The user |
|---|---|
| the burst's VFX by L: none / a spark / the Reiatsu column / the skull | 「特效請用於增強斬擊演出，包含揮砍時引出的劍風等等」: the VFX strengthens the cut itself (the trail, the sword wind it throws), not an aura. |
| pointer 2: L0 three segments | 「L0 只有柄擊、上翹」 |
| pointer 1: L0 two segments | 「L0 只有突進斬」 |
| the Bankai variants (the maw / the self-destroying arm) | 「卍解請延續原本指針的風格」: each Bankai carries on its Shikai pointer's style. |

The VFX by L (all cuts of the Shikai and the burst; drawn only, the hit volumes do not grow): L0 the plain ink trail; L1 a longer, wider
trail and wind streaks off the edge; L2 a wind crescent thrown along the cut and a dust line on the floor; L3 a gale that tears the floor
and shakes the camera.

| | Pointer 1 突進迴旋 | Pointer 2 扛肩柄擊 |
|---|---|---|
| NS L0 | a the lunge cut | a the hilt jab → b the hilt flick up |
| + L1 | b the spin-through sweep | c both hands, the great-sword overhead cut |
| + L2 | c the reverse spin | d the great-sword flat sweep |
| + L3 | d the one-hand sword dance, e the spinning leap cut | e the turning great-sword cut |

Draft Bankai (one pointer each, the J string J1–J5, SP after J5 = the special AS; every NS segment / AS costs 40 Reiatsu, floor 1):

| | Bankai from pointer 1 「狂嵐」 | Bankai from pointer 2 「斬壞」 |
|---|---|---|
| Stance | lower, wilder: the axe-cleaver in one hand trailing, the free hand clawing the floor | the axe-cleaver on the shoulder, the haft at him, still standing easy |
| NS (fixed, no L) | a the lunge cut → b the spin → c the reverse spin → d the sword dance, faster than the Shikai's | a the haft jab → b the haft flick → c both hands, the overhead chop → d the flat sweep, heavier |
| AS (press count) | AS1 lunge → spin; AS2 + the dance; AS3 + the spinning leap cut | AS1 haft → chop; AS2 + the sweep; AS3 + the turning chop |
| Special AS | 「千切」: a storm of spins ending in a dash through him | TATE-GOTO, the vertical split (canon §1.9) |
| Kikon | the dash-through tornado | the split (for now the old `ken-sky-split-cine`) |

### 5.4 The Bankai's stances and 「千切」 (the user, 2026-11-02, verbatim)

> 「千切」→ 改成類似惡魔獵人中維吉爾的次元斬，並且在最後嘶吼並爆開空間，Kikon 也用類似的演出（只是更加華麗符合大絕的演出）
> 卍解使用這兩種站姿，並且不再使用刀柄攻擊

Pictures (`.refs/kenpachi-v3/`, two prize figures of the red, horned Bankai with the long-hafted cleaver): `bankai-p2-shoulder-figure.png`
the haft over the right shoulder, the cleaver head behind, a wide low stance → the Bankai from pointer **1** (「配反了」: I had them the other
way; the file names keep my first guess); `bankai-p1-low-figure.png` crouched like a beast, both arms out, the long blade held low and trailing
in the right hand → the Bankai from pointer **2**.

| | Bankai from pointer 1 「狂嵐」 | Bankai from pointer 2 「斬壞」 |
|---|---|---|
| Stance | the haft on the right shoulder, the head behind, a wide low stance | the low beast crouch, arms out, the blade trailing low in the right hand |
| NS (fixed) | a the lunge cut → b the spin → c the reverse spin → d the sword dance, faster than the Shikai's | a the shoulder drop, overhead chop → b the dragged rising chop → c both hands, the flat sweep → d the turning chop (no haft strikes) |
| AS (press count) | AS1 lunge → spin; AS2 + the dance; AS3 + the spinning leap cut | AS1 the overhead chop → the rising chop; AS2 + the sweep; AS3 + the turning chop |
| Special AS | 「千切」: a space-cutting draw (after Vergil's Judgement Cut in Devil May Cry): one blurred swing, then cuts open in the air round him, then he roars and the space bursts | TATE-GOTO (canon §1.9) |
| Kikon | the same idea as the finisher's cinematic: more cuts, the space shattering round him, the roar | the split (for now `ken-sky-split-cine`) |

The space cuts hit where he stands (after J5 he is close), so the sim stays a melee hit; the cuts in the air and the burst are drawn only.

The user on §5.4: 「配反了」 (the stances, fixed above), 「其他沒問題」: §5.1–§5.4 approved.

## 6. The sealed form (draft, for the user's approval)

The core grammar unchanged (DUEL_CORE): J1–J5, AS n by press count with n segments (AS1 steals / AS2 launches / AS3 hurts), an SA in each NS
gap, three pointers. No unlock, no planted sword. The VFX rule of §5.3 does not apply (no L).

| Ptr | Stance (grip) and tell | Theme | NS | SA (J in a gap) | AS n | Kikon |
|---|---|---|---|---|---|---|
| 1 | one hand, the blade hanging, tip on the floor, slouched; tell: the tip scraping forward | rising cuts, pressure | a the drag-up cut → b the back-hand chop → c the flat sweep | the free-hand shove | AS1: the drag-up cut that steals | the bells: behind him, a rising cut (canon §1.2) |
| 2 | one hand, the blade on the shoulder, chest open; tell: the shoulder rolls | take the hit, cut back (armour from the startup to the active frames) | a the shoulder drop, overhead → b the second drop | the forearm shove (canon §1.2) | AS2: the overhead → the rising cut that launches | takes a cut on the chest, laughs, cuts back (canon "cut me anywhere") |
| 3 | two hands, chūdan (canon vs Nnoitra); tell: the stillness, the tip on his eyes | read and punish | a the tame (a held stance) → b the thrust → c the men cut | the kote cut | AS3: the thrust → the kote → the thrust through the guard (canon §1.2) | RYŌDAN: the left hand on the pommel, the one downward cut (canon §1.4) |

The user on §6: 「可以」 (approved), then the Shikai blade first: a labelled side view of the current Nozarashi (from `ke-mb-noz-head` / `defweapon :nozarashi`) to discuss its shape.

## 7. Nozarashi's blade widened (the user, 2026-11-03)

「請從 5 開始將刀加寬，從刀尖到護套的加寬程度分別約由 1.3 到 1.1 倍」 (5 = the point on my labelled side view). `ken-art.lisp`
`ke-noz-k` / `ke-noz-widen`: every point of the head (the body, the point, the pale band, the chips) moves away from the spine line (z 0.07 at
y 0.3 → 0.086 at 1.62) by K = 1.3 at the point's end (y −0.183), falling linearly to 1.1 at the cap's foot (y 1.425), held after; the cap
(0.56 → 0.616 m), its groove and its foot follow at 1.1; the bar, the haft and the blade's length do not move (drawn only). The point's
underside rises with it (the notch under it grows). The Bankai's broken cleaver shares the head (`ke-mb-noz-head`), so it widens too.
Checks: host tests 11331, pkgcheck, the build, G2 `--cvc` identical (II 28, IK 26, KK 22 lines); stills from both cameras (debug 84001).

### 7.1 The haft longer and curved (the user, 2026-11-03)

「1 加長並做出些微弧度向下彎」 (1 = the haft), no figures given; mine, as knobs in `ken-art.lisp`: `*ke-noz-haft*` 1.0 → 1.3 (0.76 → 0.99 m,
lengthened toward the butt, the Bankai's figure), `*ke-haft-sag*` 0 → 0.06 m: the haft bends away from the edge, z = −0.06 (u / len)², u
the distance below its top, drawn as 8 straight pieces; the wraps and the butt follow the curve. The left fist's grip clips (RYOTE's set)
still aim at the straight axis: the gap is at most about 0.03 m at the far grip; those clips are to be redrawn in V3 anyway. The Bankai's
haft (already 1.3) sags too.

### 7.2 The head turned back 5 degrees and lowered (the user, 2026-11-03)

「從 5 開始的刀身結構逆時針轉 5 度，並向下移動 0.05 m」: `with-ke-tilt` turns the head 5 degrees clockwise net (was 10) about the same
joint (0.4, 0.08) and then moves it 0.05 m away from the edge; the bar and the haft stay. Checks for §7.1–§7.2: host tests 11331, pkgcheck,
the build, G2 `--cvc` identical (II 28, IK 26, KK 22 lines), stills (debug 84001).

### 7.3 The pale band deeper, the head 1.5 times (the user, 2026-11-03)

「將 7 在刀上的佔比加寬，並將刀身放大 1.5 倍」 (7 = the edge's pale band). `*ke-noz-band*` 1.0 → 1.5 (mine; the band's depth into the
blade, now about half its width); `*ke-noz-scale*` 1.0 → 1.5: `with-ke-tilt` scales the whole head (the point to the cap and the tassel,
thickness too) about the bar's joint. The drawn far end moves from about 1.67 m to 2.31 m past the grip (overall about 3.24 m); the weapon's
`:length` stays 1.62, so the sim's reach and the FK reach test do not see it (drawn only): **open**, whether V3's Shikai moves take their
reach from the new blade. The Bankai's broken cleaver shares `with-ke-tilt`, so it grows too. Checks: host tests 11331, pkgcheck, the
build, G2 `--cvc` identical, stills (debug 84001).

### 7.4 The cap's end narrower (the user, 2026-11-03)

「幫我將護套那端縮短寬度成約 0.8 倍」: the widening factor at the cap's end `*ke-noz-k-cap*` 1.1 → 0.88 (0.8 of it), still 1.3 at the
point and linear between, so the blade tapers toward the cap; the cap (0.56 × K) and its groove follow. Checks: host tests 11331,
pkgcheck, the build, G2 `--cvc` identical, stills (debug 84001).

### 7.5 The taper ends at the middle (the user, 2026-11-03)

「收窄到中間處就結束」: `*ke-noz-k-end*` 1.425 (the cap's foot) → 0.72 (the head's middle, between the point's end −0.183 and the far end
1.62): K falls 1.3 → 0.88 over the first half and holds 0.88 to the cap. Checks: host tests 11331, pkgcheck, the build, G2 `--cvc`
identical, stills (debug 84001).

### 7.6 Back to §7.3's width (the user, 2026-11-03)

「抱歉，回到縮減前的版本」: §7.4–§7.5 undone by their knobs (`*ke-noz-k-cap*` back to 1.1, `*ke-noz-k-end*` back to 1.425, the cap's foot);
the blade is §7.3's again (the still matches). Checks: host tests 11331, pkgcheck, the build, G2 `--cvc` identical.

### 7.7 The middle 1.2 times wider (the user, 2026-11-03)

「將中段加寬 1.2 倍」: `ke-noz-k` times a sine bump, `*ke-noz-mid*` 1.0 → 1.2 halfway between the point's end (y −0.183) and the cap's foot
(1.425), falling smoothly to 1 at both (the point and the cap unchanged). Checks: host tests 11331, pkgcheck, the build, G2 `--cvc`
identical, stills (debug 84001).

Then 「改成 1.1 倍」: `*ke-noz-mid*` 1.2 → 1.1. Checks: host tests 11331, pkgcheck, the build, G2 `--cvc` identical.

### 7.8 The blade final; the reach follows it (the user, 2026-11-03)

「定案」: the Nozarashi blade of §7.1–§7.3 + §7.7 (middle 1.1) is final. 「對，跟著新刀身走」: V3's Shikai moves take their reach from the
drawn blade: when they are built, `defweapon :nozarashi`'s `:length` goes from 1.62 to the drawn far end (about 2.3 m past the grip) and the
moves' volumes are sized to it (the host FK reach test, ±0.15 m, then checks them). Until then the old KATATE moves keep 1.62.

## 8. Build order (the user, 2026-11-03)

Asked (sim of all forms first / one form to the end / the Shikai's sim alone first): 「一個形態做到完」: one form at a time, sim and art
together: the Shikai first (with the removals it needs: NOME and the cups, the arm, KATAUDE, the cup-3 Bankai), then the Bankai, then
the sealed form. Each batch: a control script per route, host tests, the build, the playtest Artifact; the CPU stays the generic one.

## 9. The Shikai's frame table (draft, mine, knobs; for the user's approval)

S = startup frames, dmg before the kit's ×, reach in m past his centre (the new blade, about 2.3 m past the grip, §7.8), "lv" = the
unlock level L a segment needs. Hitstop by damage stays the kit's `:hs-dmg` (4 + (dmg − 30) / 10, 4–14 f). No mid-route knockdown (the SA
may follow any NS segment, §443): NS segments stagger or crumple; an AS's last segment at L3 knocks down.

| Move | lv | S | dmg | reaction | reach / travel |
|---|---|---|---|---|---|
| J1 / J2 / J3 | — | 9 / 9 / 11 | 40 / 40 / 55 | flinch / flinch / stagger | 2.4 |
| J4 / J5 / J6 / J7 (L3 only: the special string) | 3 | 9 / 9 / 10 / 12 | 45 / 45 / 50 / 70 | flinch ×3 / stagger | 2.4 |
| SA (one-hand cut) | — | 8 | 40 | flinch | 2.2 |
| P1 NS a the lunge cut | 0 | 16 | 70 | stagger | 2.6, dash 3.0 |
| P1 NS b the spin-through sweep | 1 | 12 | 60 | stagger | 2.8, all round |
| P1 NS c the reverse spin | 2 | 12 | 65 | stagger | 2.8, all round |
| P1 NS d the sword dance | 3 | 10 | 35 + 35 | flinch, stagger | 2.4 |
| P1 NS e the spinning leap cut | 3 | 14 | 100 | crumple | 2.8, leap 2.0 |
| P2 NS a the hilt jab | 0 | 14 | 45 | stagger | 1.4 (the hilt) |
| P2 NS b the hilt flick up | 0 | 10 | 50 | stagger | 1.2 |
| P2 NS c both hands, the overhead | 1 | 16 | 110 | crumple | 2.8 |
| P2 NS d the great-sword sweep | 2 | 14 | 100 | stagger | 2.8 |
| P2 NS e the turning cut | 3 | 18 | 140 | crumple | 3.0 |
| AS1 (keeps P1; J1–J2 + SP) | 0 / 1 / 2 / 3 | 14 / 12 / 12 / 14 | 70 / 60 / 65 / 110 | stagger ×3, knockdown | P1's a, b, c, e |
| AS2 (keeps P2; J3 + SP) | 0 / 1 / 2 / 3 | 12 / 16 / 14 / 18 | 50 / 110 / 100 / 150 | stagger ×3, knockdown | P2's a, c, d, e |
| Burst to P1 「斬返」 (from P2, J1–J2 + SP) | — | 14 | 100 / 150 / 200 / 260 by the old L | knockdown | 2.8 |
| Burst to P2 「突進一閃」 (from P1, J3 + SP) | — | 12 | 100 / 150 / 200 / 260 by the old L | knockdown | 2.6, dash 3.5 through |
| P1 special AS (J4–J6 + SP) the full wheel | 3 | 12 | 60 + 60 + 120 | launch | 3.0, all round |
| P2 special AS (J4–J6 + SP) the meteor cut | 3 | 20 | 260 | knockdown | 3.0, leap 3.0 |
| J7 + SP | 3 | — | — | — | the Bankai (until the Bankai batch: the current Bankai kit) |

Build notes: copies (`defmove-copy`) override `:min-reach`, `:as-ptr`, `:pips` explicitly; the old KATATE / RYOTE / NOMIHOSE kits go in
a commit right after the Shikai works and before `:length` 1.62 → 2.3; until the art round the clips are borrowed, so the FK reach check
says nothing about the new moves yet.

Asked, answered: the table 「可以，照這份做」 (approved; every figure a knob until the playtest).

## 10. Costume by form (the user, 2026-11-03)

「然後劍八的封印跟常態應該是要穿著長袖的死霸裝配上短袖的白色羽織，卍解才剩下變成短袖的死霸裝」; asked which the Shikai wears:
「和封印一樣」. The sealed form and the Shikai: a long-sleeved shihakushō under a short-sleeved white haori; the Bankai: a short-sleeved
shihakushō, no haori. Built with the Shikai's art round. Corrected in §17: the haori is sleeveless, the long sleeves end in a loose
cuff like Ichigo's.

## 11. Built: the Shikai's sim and the removals (2026-11-03)

The first batch of §8's order (the Shikai), the sim with borrowed clips; the art round (two stances, the clips, the sword-wind VFX by L,
the costume of §10, the special ASs' and the Kikon's cinematics) comes next.

- **Removed**: the kits `:ryote`, `:nomihose`, `:kataude` and their moves (KATATE's `ke-kt-*`, RYOTE's `ke-r-*`, NOMIHOSE's `ke-m-*`,
  KUKAN-GIRI, the cash-out, 片腕's J3), NOME (the meter ladder, `ken-nome-step`, `%hud-nome`, the hooks `ken-drink-dry`, `ken-gulp`,
  `ken-ryote-enter`, `ken-nomihose-enter`, `ken-rift`), the cup-3 Bankai by P (no form has `:bankai-form`), their debug scenes (2380-2386,
  2389, 37000 / 38000, 71002 / 71003, 84002 / 84003) and scripts (`duel-nome`, `duel-ken-katate / ryote / nomihose`). Left for the Bankai
  batch: the arm (`:pips`, `ken-arm-step`, `arm-spend!`, `arm-burst!`, `core-pips-ok-p`); left as dead code: the pure NOME helpers in
  rules.lisp (`nome-gain`, `meter-drain`, `ladder-rung`), `nome-gain!` and the cups' clips in ken-art.lisp (taken off the clip contract).
  The Bankai now inherits the base form, its hooks written out (`:tick ken-tick` …).
- **The Shikai** (`ken.lisp`, §9's moves `ke-s-*`): `:inherit :base` with everything its own (`:startup-add 0 :reach-mult 1.0 :open-s nil`,
  `:commands (:q :ke-s-j1 :f nil :sig nil :sp1 nil :sp2 nil …)`, the J string by `:strings`), the meter KAIHO (`:max 3 :start 0 :lv t`,
  three yellow pips, `%hud-lv`), the hooks `:lv ken-lv`, `:as-pick ken-as-pick`, `:hit ken-hit`, `:link-ok ken-link-ok`.
- **Generic (core-sim.lisp, off without the hooks)**: `core-snap-lv!` reads a kit's `:lv` hook at an NS route's or an AS's start into
  `fighter-lv-cap` (default 99) and clears `fighter-lv-got`; `core-seg-ok-p` refuses a segment whose `:params :lv` is above it, in the latch
  (`core-move-sp!`) and in the start (`core-latch-step`); the temporary switch starts its route without a snapshot, so it keeps the level.
  `core-as-start!` asks a kit's `:as-pick` hook for another move and the pointer it writes, or `:taken`.
- **Reach**: `defweapon :nozarashi :length` 1.62 → 2.3 (§7.8); the FK reach check then measured the borrowed spin (J3, J7) at 3.77 m:
  their reach 2.4 → 3.65. The hilt jab got a 1.0 m step-in and the flick 0.6 m (the scripted 2.2 m scene whiffed them).
- **Checks**: host tests 9831 all pass (1500 fewer: the cups' and KATAUDE's checks went; a new Shikai block: classes, levels, the special /
  Bankai tags, :lv-up, bursts, §9's S and damage, no mid-route knockdown, the hooks only on the Shikai, the J string), control 100, touch
  100, pkgcheck clean (`debug-ranges-check.py`'s one overlap, 2510-2513 vs 2513, as before), the build. Scripted `duel-ken-shikai.json`
  (16 scenes, combat log): P1 at L0 / 1 / 2 / 3 plays 1 / 2 / 3 / 5 segments (70, 60, 65, 35 + 35, 100) and each landed route raises L
  (L0 → 1 → 2 → 3); P2 at L0 the jab and the flick (45, 50), at L3 all five (45, 50, 110, 100, 140); AS1 at L2: 3 segments, L → 3; the
  burst to P2 at L2 hits 200 (`BURST to pointer 2 (L2)`), to P1 at L3 260, at L0 100, the pointer written and L 0; J4 refused at L2 (the
  string stops at J3); J1-J4 + SP at L3 = DAISHARIN 60 / 60 / 120, J1-J6 + SP at P2 = INSEKI-GIRI 260 (`pointer kept`); J1-J7 + SP =
  `BANKAI from pointer 1`, the Bankai's cinematic; the temporary switch at L1 (DRIVE 60): P1's lunge, then P2's route n2a / n2b / n2c (L1's
  segments), L stays (the route already counted); the awakening starts at L 0. Not scripted: a guarded route giving +0 (no P2 guard in the
  core scenes). Playtest Artifact v290.
- **G2** `--cvc`: II identical (28 lines: the new hooks are off for the other kits); IK 26 → 29 lines (P2 0-5, 286.2 s), KK 22 → 30 (P2 0-4,
  300.7 s): the CPU Kenpachi awakens into the new Shikai; `tests/style-cvc-ref.txt` regenerated. No balance gates.
- **The CPU**: the generic core CPU (it does not aim for L, the bursts or the special string).

## 12. After the first playtest: the flick's own clip, the grip, the camera (the user, 2026-11-03)

Requests, verbatim:
1. 「我看不出 柄擊 與 上翹 的動作差異」. Cause: both segments (`ke-s-n2a`, `ke-s-n2b`) played the borrowed left jab `:ke-kt-jab`.
   The flick now has its own clip `:ke-s-flick` (S 10 = the move's startup, A 3, R 16): the right hand sinks, the butt down
   (f6–f8 held), then the arm swings up and the white haft sweeps up through his front while the blade dips behind him. The jab keeps the
   borrowed clip until the art round. Presentation only.
2. 「請將鏡頭改成兩個角色越接近時，拍攝角度就越接近側面」: the behind camera's swing is now a blend, from `*behind-side*` 30° at 6 m and
   farther to `*behind-close*` 90° (was 40°, and the larger of the two) at 2 m; the portrait camera the same (`*pt-close*` 15 → 90).
   After the playtest 90 → 75 for both (「改成最多轉到 75 的度」, DEVLOG §563), then 70 with the swing starting at 12 m instead of 6
   (`*behind-blend-far*`; 「改成 70 度，然後增加鏡頭轉換的緩沖距離到 12 m」, DEVLOG §564).
   Only the look: the stick still follows the sim's `*behind-yaw*` (W = toward the opponent, on screen rightward when side-on).
   DUEL_DESIGN §9.
3. 「始解握住刀柄的位置應該要在介於靠近白色上緣 1/5~2/5 的位置」: read as the white haft's top (the blade end, y 0.08). The right hand
   held it 0.08 m below the top (1/12 of the 0.99 m haft); now `*ke-noz-grip*` 0.3 (the middle of 1/5–2/5): the weapon slides 0.22 m
   up the hand (`ke-noz-grip-y`), `defweapon :nozarashi` `:length` 2.3 → 2.52, `:base` 0.2 → 0.42. The left hand's GRIP-LEFT! still
   finds the haft (0.14–0.62 m below the grip; 0.69 m of haft is below it now). The reach follows the drawn blade (§7.8): only the
   borrowed spin's J3 / J7 drew past their volume (4.00 m against 3.65), reach 3.65 → 3.85; every other Shikai move's volume already
   covers its tip. The Bankai's broken cleaver keeps its grip (the request named the Shikai).

Checks: host tests 9831 ALL PASS (the clip list takes `:ke-s-flick`), control 100, touch 100, pkgcheck clean, the Shikai script's 16
scenes log the same hits and L as §11, G2 identical to the reference (II, IK 29 lines 286.2 s, KK 30 lines 300.7 s). Playtest Artifact v292.

## 13. L once per combo (the user, 2026-11-03)

「現在是用過一段 NS 或 AS 就解放一階段，但我希望是「一整套攻擊」中有用上一段 NS 或 AS 才解放一階段」

S2 was once per route: an NS route that landed and an AS later in the same combo each gave +1. Now **one combo** (the victim's: from his
first hit to his return to neutral, the HUD's combo count) that lands at least one NS segment (the temporary switch's included) or a
same-pointer AS gives +1, however many routes it holds. `ken-hit` clears `fighter-lv-got` on the combo's first hit (the victim's
`combo-hits` ≤ 1 after the hit, any move); `core-snap-lv!` no longer clears it at a route's start (it only snaps the level). A guarded,
cancelled or whiffed NS / AS still gives nothing; a level gained opens segments from the next route on, as before.

Checks: the Shikai script's new scene (P1 at L0: SP, J, J, SP = NS1a → SA → J2 → AS1, one combo): `P1 L1` once, at the lunge; the old
rule gave L2 at AS1. The other 16 scenes log as in §11 (the temporary switch's L3 now comes on NS2c, the victim having recovered before
it). Host tests 9831 ALL PASS, control 100, touch 100, pkgcheck clean, G2 identical. Playtest Artifact v297.

## 14. The Shikai's art round, part 1: the two stances and the sleeves (2026-11-03)

「請開始下一批」 (the art round of §11: the stances, each move's clip, the sword wind by L, the costume, the special ASs' and the Kikons'
cinematics). Split in four parts, each with its own playtest Artifact: 1 the stances and the costume, 2 every move's own clip, 3 the
sword wind by L, 4 the cinematics.

Part 1 (presentation only):
- **Pointer 1 `:ke-s-st-1`** (after the statue, `.refs/kenpachi-v3/shikai-p1-slung-statue.png`): half-crouched and leaning in, the left
  arm out, the hilt low at his right hip (the grip at r 0.34, u 0.98, f 0.18 m), the butt out to his right below it, the blade up
  behind his head toward his left (along r −0.51, u 0.77, f −0.38; the tip about 3.1 m up, 0.33 m behind his head where it passes). The
  right arm was solved by FK on the host (arm flex −30, side 12; elbow 92; hand flex 70, twist 20). The loop breathes lower (the dash
  tell).
- **Pointer 2 `:ke-s-st-2`** (after the manga panel): KATATE's shoulder rest upright and easy: the blade's back on the right shoulder,
  the white haft pointing at him.
- The kit's `:stance` and `:core :stances` take them (the borrowed `:ke-kt-st-chain` / `:ke-kt-st-rush` are no longer used by the Shikai).
- **Costume (§10)**: the shihakushō's long black sleeves (a wide flared sleeve over the forearm, `:sleeve-long`; the shoulders black) and
  the white haori's short sleeve over the upper arm with two teeth at its hem (`:haori`). The Bankai's kit hides `:sleeve-long` with
  `:haori`: short black sleeves (its own look comes with the Bankai batch).

Checks: host tests 9831 ALL PASS (the clip list: `:ke-s-st-1` for `:ke-n-stance`), pkgcheck clean, the build, G2 identical (a first run's
KK started 15.9 s late under load and missed its script; the rerun passed), stills from the behind and the side cameras (84001 + 2510 / 2511,
2109). Playtest Artifact v298.

## 15. Art round, part 2: every move's own clip (2026-11-03)

Built by three agents in parallel worktrees (pointer 1, pointer 2, the J string), merged; presentation only: in each clip `:clip-s` = the
move's startup (speed 1), and the Shikai script's combat log (94 HIT / L / BURST / BANKAI lines) is identical before and after.
Each hit pose was solved by host FK against its volume (the tip within about 0.4 m short of the far edge or up to 0.1 m past it; the
host art test checks the J links, the probe the rest). Rhythm 由緩至急 on every opener (an eased charge, a held trembling coil, the
release in the last 2–3 f); no full root turn inside a clip (spins carry the cleaver round with the root and chest up to ~130°).

| Clip | Move | The motion |
|---|---|---|
| `:ke-s-cut1` | J1 | the hilt flung over the right shoulder, then a diagonal high right → low left on a lunge |
| `:ke-s-cut2` | J2 | coiled low left, the backhand rising low left → high right |
| `:ke-s-cut3` | J3 | dragged flat behind, the arm locked, one flat chest-high cleave across on a long lunge (tip 3.88 m) |
| `:ke-s-cut4`–`7` | J4–J7 (L3) | an overhead drop biting the floor; a floor-drag ripped up the centre; a shoulder-rammed flat hack; the huge overhead slam into the floor |
| `:ke-s-cut-sa` | SA | the hilt across to his left, a flat backhand flicked out as he steps in |
| `:ke-s-p1a` | P1 a TOSSHIN | the crouch sinks and holds (the tell), the cleaver drags low behind and rips up hip → over the left shoulder |
| `:ke-s-p1b` / `p1c` | P1 b / c | a forehand spin mowing the floor right → left; the other way and height: a rising backhand onto the toes |
| `:ke-s-p1d` | P1 d | the figure eight: two steep one-hand cuts, down left (f10), looped, down right (f16) |
| `:ke-s-p1e` | P1 e | deep crouch, a spring, one flat whirl overhead, chopped down landing |
| `:ke-s-issen` | burst to P2 | a low draw, one slanted backhand flash, the blade lifted onto the shoulder (ends in the shoulder stance) |
| `:ke-s-wheel` | DAISHARIN | the cleaver whirled flat overhead three times (f12, f18, f24), the third climbing into the launch |
| `:ke-s-jab` | P2 a TSUKA-UCHI | the hilt drawn back along the shoulder, held, shoved straight out (the butt 1.42 m) |
| `:ke-s-flick` | P2 b | (§12) |
| `:ke-s-p2c` / `p2d` / `p2e` | P2 c / d / e | both hands: the overhead to the floor; off the shoulder, a flat mow; the back turned, a round descending cut |
| `:ke-s-zangaeshi` | burst to P1 | one hand: heaved off the shoulder, one big diagonal, dragged round low and up his back (ends in the sling) |
| `:ke-s-meteor` | INSEKI-GIRI | crouch, leap with the hilt raised, arched, the falling cut |

The two-handed clips (`p2c`, `p2d`, `p2e`, `meteor`) are in `*grip-clips*`. No longer played by any kit: `:ke-kt-jab`, `:ke-k-q1`,
`:ke-k-q2`, `:ke-k-f1`, `:ke-k-f2`, `:ke-k-spin`, `:ke-k-meteor`, `:ke-r-f2` (their defstrikes stay for now). Known flaws: P2 d's left
fist floats up to 0.18 m off the haft through its carry; the L3 AS route as1c → as1d pops one frame (P1 e's frame 0 is P1 d's landing);
some tips dip into the floor (J1 0.2 m at the hit; J4 / J7 bite it on purpose). `tests/duel-view.lisp` draws the KE-S- clips with
Nozarashi.

## 16. Art round, part 3: the sword wind by L (2026-11-03)

`duel/lisp/ken-look.lisp`, the Shikai kit's `:draw` hook (drawn only; the hit volumes do not grow): on every hit window of the move he
is in, at the level it shows (L now; a burst's the route's, since L went to 0 as it started): L0 the plain smear; L1 three white
streaks peeling off behind the tip, longer by L; L2 + a wind crescent (a white lens with an ink rim) whose chord is the cut itself,
thrown along the tip's bearing from 0.6 to 1.6 times the volume's far point over 10 f, and a dust line along the floor; L3 + a second,
wider crescent, a floor crack under the far point, rubble and a camera shake (0.1 m, 0.22 s). Knob: `*ke-wind-life*` 10 f. The
crescents read in the stills; the L1 streaks are faint (to be judged in play).

Checks for §15–§16: host tests 9831 ALL PASS, pkgcheck clean, the build, G2 identical, the Shikai script's log identical. Playtest
Artifact v300 (v299 before the last rebuild after a comment edit).

## 17. Playtest fixes: the sleeveless haori, NS2c's two-handed chop, pointer 1's sling out of the body (2026-11-03)

The user:
1. 「劍八是無袖羽織，而不是你製作的短袖羽織，然後長袖的死霸裝是像一護的那種寬鬆袖口設計。此外，目前手彎曲的時候手肘會透過衣服。」
2. 「NS2c 的下劈姿勢也太奇怪了，應該是要雙手握刀、正對對手向下劈斬。」
3. 「指針一的站姿你自己用三視圖比對一下，不覺得刀都劈開自己了嗎？如果嚴重程度不高，我也可以接受穿模，但這種情況有點太過頭了。」

Presentation only (the Shikai script's 88 HIT / L / BURST lines identical, G2 identical):
- **Costume** (`ken-art.lisp`'s arms): the haori's short sleeve and its teeth removed (sleeveless: the white shoulder pieces stay);
  the black upper sleeve 0.074–0.078 → 0.08–0.084; the forearm's long sleeve now widens from 0.08 at the elbow to 0.1 and ends in a
  loose square cuff 0.21 × 0.22 at the wrist (Ichigo's cuff shape, black, no lining); a black ball 0.082 at the elbow fills the gap
  between the two sleeve pieces when the arm bends (before, the skin elbow 0.045 showed there). The cuff and the ball are
  `:sleeve-long`, so the Bankai still shows short sleeves and a bare forearm.
- **NS2c `:ke-s-p2c`** re-keyed (S/A/R 16/5/24 kept): square to him (pelvis and chest twist 0 throughout), both hands on the hilt
  (GRIP-LEFT!), raised over his head with the blade back (f7–f14, the front foot lifted and held), vertical overhead on f15, then the
  chop straight down the centre line: at S the grip 1.4 m up, 0.4 m out, the blade 22° below level (the drawn tip 2.96 m vs the 2.8 m
  volume, inside the art test's +0.15); on A the tip on the floor 2.9 m out; held to f32, recovered by f39. Both arms solved on the host
  (grip, blade and edge targets; the left fist on the haft 0.35 m behind the grip; the blade's flat kept out of the body).
- **Pointer 1 `:ke-s-st-1`**: three views of the FK body (front, side, top: a torso capsule, the head, the blade's spine and flat)
  showed the old sling ran the haft through his right chest (the spine 0.06 m in front of the chest's back face) and the flat through
  his head. The right arm re-solved for the grip at (0.42, 1.0, 0.12) with the blade along (−0.48, 0.70, −0.53) (r u f): the spine
  passes 0.3 m behind the shoulders, the clearance to the torso ellipse +0.47 of its radius (was −0.12). Arm flex −30 → −34, side 12 →
  16, twist 0 → −7; elbow 92 → 84; hand flex 70 → 95, twist 20 → 8, side 0 → −1. The hand stays near its old angles, so the pointer-1
  clips' first keys blend in without a wrist roll; turning the edge backward instead (fully clear) needs the hand rolled ~180°, which
  would spin the blade at the start of every pointer-1 move. ZANGAESHI's landing key takes the same arm. Left: the crown's hair spikes
  graze the blade's edge from his left side (the turntable stills, `tests/duel-view.lisp` 1000103 + 3000+d).

Checks: host tests 9831 ALL PASS (the art FK test included), pkgcheck clean, the build, the Shikai script's log identical, G2
identical; stills from the viewer's turntable (stance 1 at six angles, NS2c's eight frames from three). Playtest Artifact v301.


## 18. Pointer 1's stance rebuilt step by step from pointer 2's; the sleeves cut to the elbow (2026-11-03 – 2026-11-04)

The user, on a statue photo of the Shikai: 「你再跟我好好形容一遍這個站姿長什麼樣子？」, then 「很好，請以此觀察結果進行修改。另外，劍八的寬鬆長袖實際的
長度也只比手肘稍長一些，目前的袖長過長了。」. A first statue pose (the haft across the back from the right hip to above the left
shoulder, the flat facing the opponent) was dropped mid-way: 「我們先把站姿調好再做其他事情」, 「我們用指針二的副本開始修改，讓他變成我期望的指針一
站姿」. The stance is now built one instruction at a time on a copy of pointer 2's:

1. 「身體前傾，腿部呈現半蹲姿態」: spine flex 0 → 22, head −16 (the eyes kept on him), root u −0.02 → −0.18, thighs l 42 / r 14, knees
   l 64 / r 58 (both feet on the floor by FK, 0.05 m as before); the idle breathes low (root u −0.2, spine 24).
2. 「改成握住刀柄 1/2 處，手臂從面向前方改成向外轉動 45°」: the hand, the hilt and the blade turned 45° out about the right shoulder (FK:
   the grip (0.20, 1.27, 0.58) → (0.50, 1.27, 0.54) r u f; arm flex 24, side 29, twist −44; elbow 99; hand flex 27, twist −4, side −4).
   The half-way grip was the stance's only (the user chose 「只有指針 1 架式」 over moving every Shikai grip, which would lengthen the
   drawn reach 0.2 m), drawn by a `:pose` hook sliding the weapon 0.2 m out along its blade; undone in step 7.
3. 「兩個指針的刀身以刀刃為尖端、刀脊為中心向外偏轉 15°」, then 「再向外偏轉 5°」 twice: both stances roll the weapon 0 → 15° → 20° → 25° about
   its spine, the edge out (`(:weapon-r :side 25)`, the roll about the blade's own axis; a positive roll moves the edge away from the chest in both).
4. 「繼續修改指針 1，請將左肩往前傾斜，右肩後拉使大刀與人物面向的方向呈現 90°」: the upper body turned 56° to his right (spine twist
   0 → −26, chest −4 → −30; the left shoulder 0.36 m ahead of the right, was 0.03 behind), the arm and blade with it: the blade at 90.3° to
   his facing (was 130°, FK); the head turned back 45° (head twist 0 → 45) so he still faces the opponent.
5. 「身體再更往前傾，下盤配合些微下蹲，右膝打開、右腳往外跨一小步。左手幫我調整合適的姿勢」: spine flex 22 → 32; root u −0.18 → −0.24
   (left thigh 42 → 50, knee 64 → 74); the right foot 0.14 m further out, on the floor, the knee opened 0.06 m outside it (FK: thigh
   flex −5, side 52, twist −67; knee 64), the ankle levelling the sole with the toes 30° out (foot flex −55, twist 47, side −22; it
   tilted 57° without); the head −29 / 42 to keep the same view; the left arm (my pick) hanging loose ahead of the left knee, a little
   out, the elbow soft (arm flex −16, side 50, twist −5; elbow 56); the idle breathes at root u −0.26, spine 34.
6. 「右膝太開了，往前收一點」: the right knee 0.1 m forward and 0.05 m in, over the foot instead of 0.06 m outside it, the foot where it
   was (thigh flex −5 → 7, side 52 → 45, twist −67 → −45; knee 64 → 65; the ankle re-levelled: foot flex −34, twist 26, side −29).
7. 「刀柄握回原本 0.3 處，並製作比較圖給我看」: the stance holds the haft at `*ke-noz-grip*` 0.3 like every move; the slide hook and its
   state removed (the Shikai kit has no `:pose` hook again). The blade sits 0.2 m further toward the hand along its own axis: the
   nearest point to the head's centre 0.16 m (the head's radius about 0.14: a graze at the back of the head), 0.27 m to the torso axis.

Pointer 1 approved (「指針 1 沒問題了」). Pointer 2, 「我發現指針 2 的刀柄似乎沉入肩膀中了？」: the spine where the haft meets the head (0.35 m up
from the grip) sat 0.05 m into the haori's shoulder (with the haft's thickness; the same before the roll, so `:ke-k-rest`'s old rest).
The hand lifted 0.06 m with the blade's direction kept (FK: arm flex 35 → 43, side 25 → 26, twist 0 → −4; elbow 110 → 109; hand flex
25 → 18, twist 0 → −2, side 0 → −3): the haft 0.01 m over the haori. Pointer 2's moves key from the old rest kept as `:ke-s-shoulder`
(their first keys reset to it, their frame 0 and ends the new stance), as pointer 1's from `:ke-s-sling`.

Finishing pointer 1 (「沒問題了，請幫我修改並繼續完成下個步驟的動畫」):
- The head graze: the whole weapon pushed 0.07 m off the back of his head (the nearest point 0.16 → 0.22 m from the head's centre, no
  clipping; the blade 86.6° to his facing, was 90.3; arm flex 22, side 34, twist −52; elbow 98; hand flex 26, twist −10, side −6).
- The blends into and out of the stances, checked by FK per frame against ff4f055 (before the stance work) for all 21 clips of the
  two pointers: the clipping is lower or equal everywhere (the stance's own graze gone; pointer 2 no longer sinks into the shoulder)
  and pointer 2's are as smooth or smoother. Pointer 1's recoveries turn the blade further (up to 37° a frame over 9–12 frames, as
  before) since its stance is further from the moves' poses. ISSEN's start (4 frames, the draw) still twirls the blade (up to 100° a
  frame; 78° before): a mid key cannot help, since at the mid body the arm cannot reach the mid blade (30° off), so it stays.

The moves are untouched: the old sling is kept as `:ke-s-sling`, and every pointer-1 clip and landed pose keys from it. The five clips
that start from the stance (p1a, ISSEN, DAISHARIN, cut1, the SA) take `(0 :ke-s-st-1)` and reset to `:ke-s-sling` on their next key;
pointer 2's six clips unroll the blade on their first key (`(:weapon-r :side 0)`); their ends land in the new stances. ZANGAESHI's
landing key (f38) takes the new stance. Left for the stance's end: the start / end blends of the pointer-1 clips are re-checked
(blade spin per frame, clipping) once the stance is settled.

The sleeves: the loose sleeve ends a little below the elbow, the forearm bare: the sleeve tube 0.17 → 0.07 m, the cuff from 0.2 → 0.09 m
down the 0.27 m forearm (both arms; the Bankai still hides them).

Checks: host tests 9831 ALL PASS, pkgcheck clean, the build; viewer turntables of both stances (four angles) and in-game shots (the
behind and side cameras, an SP press sliding the hand back). Playtest Artifact v303.

## 19. Art round, part 4: the special ASs' looks and the two Kikon cinematics (2026-11-04)

「沒問題了，請幫我修改並繼續完成下個步驟的動畫」: part 4 of §14 (presentation only; `ken-look.lisp`):
- **DAISHARIN** (`:ke-s-sp1`, the full wheel, §5.1 「a spinning tornado」): `%ke-tornado`, a funnel of white wind arcs round him from
  frame 4 to 40 (four rings of three arcs, 0.3 m up at r 1.1 to 2.7 m at r 2.3, each ring turning faster than the one below) and a
  dust ring dragged round on the floor, faded in over the wind-up and out over the recovery; on top of §16's sword wind.
- **INSEKI-GIRI** (`:ke-s-sp2`, the meteor cut): a yellow-white tail 1.8 m behind the falling blade (frames 15–21), then on the hit
  window's first frame the floor cratered under the volume's far point (`ke-meteor-impact`: a 2.4 m crack patch, a yellow ring 4.5 m,
  10 rubble chips, a shake).
- **The Kikon cinematics**, one per pointer (the Shikai kit's `:core :kikon-cines`; before, the old base and pointer-2 cinematics):
  - pointer 1 **回天斬 KAITENZAN** (`ken-s-kikon1-cine`, 突進迴旋, 170 f): the stance held, a white card with the brush title; side-on the
    crouch deepening (`:ke-s-p1a`'s startup slowed); the dash 6.4 m through him along the line (ISSEN's clip, a yellow-white streak,
    a heavy cut as he passes); from behind the victim, Kenpachi skidding on; he turns and spins back through him in the wind funnel
    (the wheel's clip), the heavy cut on f104, the Konpaku on f112 (a negative, a manga page); he laughs; wide.
  - pointer 2 **墜天斬 TSUITENZAN** (`ken-s-kikon2-cine`, 扛肩柄擊, 168 f; rebuilt slower in §20, 290 f): the shoulder rest held, the white card; the hilt sunk and
    flicked up into him (`:ke-s-flick`): he goes up tumbling to 3.6 m and hangs; from below, Kenpachi leaps after him (INSEKI-GIRI's
    clip, 2.6 m up), side-on at their height; the cut down on f104, both falling, the floor cratered under him on f110 (the meteor's
    impact), the Konpaku; he laughs; wide.
  The titles use the brush glyphs already baked (回 天 斬 墜): new kana / kanji need `tools/glyph-bake.py` (a first draft 斬り抜け /
  叩き斬る drew only 斬 / き斬る). Debug 84094 / 84095 play them from the 84001 scene (DUEL_GAMEPLAY "Debug commands").

Checks: host tests 9831 ALL PASS, pkgcheck clean, the build. G2: IK and KK moved, since their Shikai Kikons now run 170 / 168 f (the
borrowed ones 192 / 176) and move the actors; with the old lengths put back for a check IK was identical and KK differed only on its
t=6000 hash line, sampled inside the cinematic (P1's place), so the reference was regenerated (II unchanged 28 lines; IK 29 lines,
P2 0-5, 285.5 s; KK 30 lines, P2 0-4, 298.7 s). Both cinematics shot at eleven frames each, DAISHARIN and INSEKI-GIRI scripted
(84001 + L3, J ×4 / ×6 + SP) and shot at seven frames each. The manual's Shikai table: the stances as built, the special ASs' looks,
the Kikon row.

## 20. TSUITENZAN in the style of the meteor cleave, slowed (2026-11-04)

The user, on the playtest of §19: 「墜天斬的動畫請使用原作中劍八將隕石劈開的那招，而且目前的演出太快，讓人無法看清中間過程」. Asked where the
meteor comes from in a 1v1 (A: the victim falls back wrapped as one; B: a meteor of his reiatsu), the user: 「不是真的要劈開隕石，只是要用那招的
風格而已」: no meteor, the cut's style.

- Canon (grade C, chapter summaries of ch. 576-577 "Blade", TYBW episode 20 "I Am the Edge"; to check against the pages): Gremmy drops a
  meteor on the Seireitei; Kenpachi leaps skyward, releases Nozarashi and splits it through its core with one blow; the halves break
  apart and fall across the city. Taken: the leap skyward, the one blow from above, the two halves falling to either side.
- Not taken: the white sky-split line (`vfx-sky-split`): the sealed form's pointer-3 Kikon and the Bankai's MAPPUTATSU already use it.
  This cut is its own look in the world: a yellow-white arc (`ke-kk-cut`, a gold lens crescent under a white one) in the line's vertical
  plane, from 8 m up on Kenpachi's side through the victim to the floor past him.
- Pacing: the middle went from about 0.7 s (launch f69 → floor f110, the cut itself 6 f) to 2.5 s (f77 → f228), length 168 → 290 f:

| Beat | Before | After |
|---|---|---|
| hilt flick (`:ke-s-flick`) | speed 0.6, hit f69 | speed 0.4, hit f77 |
| victim up | to 3.6 m by f88 | to 5.0 m by f125, hangs to f196 (5.2 m), seen from below |
| the leap | f88-104, 2.6 m | INSEKI-GIRI's clip at 0.3: crouch f122, leap f122-152 to 5.8 m (wide side-on) |
| arched over him | - | f145-168, held, his reiatsu flaring (low and close, against the sky) |
| the cut | f104 | f168: a negative, focus lines, slow motion ×0.25 to f196, shot down the line |
| the split | - | the arc whole f168-176, then two halves peel 2.4 m apart to either side and fall (f172-228) |
| the fall | f104-110 | f196-228, side-on, a yellow-white tail over Kenpachi |
| landing | f110 | f228: the crater under him (`ke-meteor-impact`) and the halves' two craters 2.4 m to either side, the Konpaku |
| laugh / wide | f126 / f140 | f246 / f260 |

- Presentation only (`ken-look.lisp`; the in-game INSEKI-GIRI clip untouched, the cinematic plays it slowed). Debug 84095 plays it; its
  `:hold` frame is the cut (168). Checks: host tests 9831 ALL PASS, pkgcheck clean, the build, 22 frames shot (f60-f270, every 6-10
  frames through the middle). G2: II and IK identical; KK: every hash line identical, only its RESULTS line moved 17924 -> 18046 ticks (298.7 -> 300.8 s, P2 0-4: the 122 f of the one TSUITENZAN it plays), so the reference was regenerated.

### 20.1 The cut at full speed (2026-11-04)

The user: 「斬下去的瞬間速度加快，讓演出更有魄力」. Before, INSEKI-GIRI's clip ran at 0.3 through the swing, so the blade took about
10 frames from the arch (key 17, f158) to the hit (S, f168), and slow motion started on the hit frame. Now:
- held arched: the clip restarts at key 13 at 0.25 on f150 (key 17 by f166, the arch barely moving);
- the swing at full speed: on f165 the clip jumps to key 17 at speed 1 (blend 0), S on f168; the blade covers its arc in 1-2 frames,
  a gold smear of the arc growing over f165-168 (`ke-kk-cut`), the lens punched wide (62°, dutch 10) and a whoosh;
- the hit: a 3-frame negative, focus lines 24, the shake 0.3 → 0.55, an extra low explosion; a hit-stop f168-174 (`cine-slow 0`),
  then the slow motion ×0.25 to f196 as before.
Length unchanged (290 f). Shot at eleven frames f156-f182. Host tests 9831 ALL PASS (run for §20, unchanged since: presentation only), G2 identical (II, IK, KK).

Approved as is (the user, 2026-11-04: 「目前這樣就好」).

## 21. The known flaws fixed (2026-11-04)

The user: 「幫我處理舊問題」 (the four left in §15, §16 and §18).
- **P2 d's left fist off the haft** (up to 0.185 m from the hit to the end of the carry, f14-28): the haft was past the left arm's reach
  (GRIP-LEFT!'s IK clamps at 0.999 of the arm). Solved by FK for the smallest change that brings it in reach with the blade where it
  hits: at S the right arm `:flex 20 :side -20 :twist -60` → `15 / -36 / -65`, elbow 85 → 92; at S+A the pelvis −25 → −18, chest 60 →
  57, the arm `20 / 0 / -60` → `5 / -37 / -78`, elbow 60 → 72 (the carry key 28 inherits it). The fist reaches the haft on every
  frame now (the target 0.01 m inside the reach); the tip moves at most 0.11 m in the hit frames.
- **The L3 AS route's pop as1c → as1d**: `:ke-s-as1d` plays NS1e's clip, whose frame 0 is NS1d's landing, but the AS comes from NS1c.
  `:blend 3` on the AS copy crossfades from NS1c's end over 3 frames (presentation: the sim never reads the blend).
- **The faint L1 streaks**: each streak is wider (0.06 → 0.08 m at L1, +0.03 a level, was +0.03 from 0.06) over an ink rim 1.6×
  as wide, and lingers 6 frames after the window (3 before), fading over 5. To be judged in play.
- **ISSEN's draw twirl** (f0-4 from the stance): three keys at f1-f3, the body on the straight line between the stance and the draw,
  the right arm solved for the most even turn of the blade (the summed squares of each frame's blade and edge turn). The blade turns
  at most 33° a frame (80 before), the edge 53° (100 before; it turns 119° over the 4 frames, so ~30 is the floor); the swing after it
  runs ~40° a frame. §18's "a mid key cannot help" was about matching a target blade, not an even turn.

Also the phone's Kikon confirm (DUEL_CORE §4, 「目前手持模式很容易誤觸毀魂技，請延長啟動觸發的判定」). Checks: host tests 9831 ALL PASS,
touch-test 100, pkgcheck clean, the build, G2 identical; the scripted routes (L1 J ×3, L3 J + SP ×4 to AS1D, L2 SP ×4 to N2D) shot.
Playtest v314.

Approved (the user, 2026-11-04: 「非常好」).

## 22. The Bankai: its own weapon builder (2026-11-04)

The user: 「開始卍解設計，然後我先調整卍解的武器造型」, then 「請先確保改動卍解不會影響到始解武器造型」. The broken cleaver `:ke-broken`
was built by Nozarashi's own builder (`ke-mb-noz-head`, `with-ke-tilt`, `ke-noz-k` / `ke-noz-widen`) and knobs (`*ke-noz-scale*`,
`-band`, `-k-cap`, `-mid`, `-k-end`, `*ke-haft-sag*`), so it took every Shikai reshaping of §7 and any Bankai change would have moved
the Shikai. Now it has a copy of its own (`ke-mb-bk-head`, `with-ke-bk-tilt`, `ke-bk-k` / `ke-bk-widen`, knobs `*ke-bk-haft*`
1.3, `*ke-bk-scale*` 1.5, `*ke-bk-band*` 1.5, `*ke-bk-sag*` 0.06, `*ke-bk-k-cap*` 1.1, `*ke-bk-mid*` 1.1, `*ke-bk-k-end*` 1.425: the
values of that day); nothing in Nozarashi's code reads them, nor the copy Nozarashi's. Proof: the viewer's stills of Nozarashi (4101),
the broken cleaver's two faces (4102 / 4112) and the Bankai turntable (2006, 0/90/180/270) are byte-identical to the build before the
split (0 pixels differ). Host tests 9831 ALL PASS, pkgcheck clean, the build. Next: the user's changes to the cleaver.

## 23. The Bankai cleaver: a long haft held halfway, a small head (2026-11-04)

The user: 「幫我將刀柄加長 1.3 倍，角色持握 0.5 的位置，然後刀身縮小至 0.3 倍」. Knobs (ken-art.lisp, the Bankai's own since §22):
- the haft `*ke-bk-haft*` 1.3 → 1.69 (×1.3, longer downward: 0.99 → 1.28 m);
- the grip `*ke-bk-grip*` 0.5 (new, as Nozarashi's `*ke-noz-grip*`): the hand halfway down the white haft, the weapon slid 0.56 m
  out of the hand (`ke-bk-grip-y`), so 0.56 m of haft shows below the fist and the head sits 0.64 m above it;
- the head `*ke-bk-scale*` 1.5 → 0.45 (×0.3) about the bar's joint; the black bar and the haft keep their size.
- `defweapon :ke-broken` `:length` 0.9 → 1.2 (the drawn far end: the break 0.64 up the head frame + 0.56; 0.9 had not followed the
  ×1.5 head since 11-03), `:base` 0.2 → 0.7 (the head's foot, where the trail starts).
The host FK test then drew the placeholder Bankai's J1 TATAKI-GIRI (`:ke-b-j1`, the old Bankai kit still in play until the
redesign) 0.2 m past its volume (1.60 vs 1.40 m, ±0.15): its `:reach` 1.28 → 1.48 (the reach follows the drawn weapon). Nozarashi's
stills byte-identical (0 pixels); the broken cleaver's two faces and the Bankai turntable shot before / after. Host tests 9831 ALL
PASS, pkgcheck clean, G2 identical (no reference match plays the Bankai's J1). Playtest v315.

## 24. The Bankai cleaver reshaped: a bigger head on a shorter bar, the blade parallel to the haft (2026-11-04)

The user, in a row: 「刀身放大 1.5 倍，斜槓連接處縮短成 0.75」, 「修改刀身形狀，使刀刃與刀脊平行」, 「減少刀尖下彎的程度」, 「幫我改成跟刀柄平行」,
and 「在此階段先不要跑對戰測試」 (no match tests, G2 included, at this stage; the host tests, pkgcheck and the build still run).
- The head `*ke-bk-scale*` 0.45 → 0.675 (×1.5).
- The black slanted bar `*ke-bk-bar*` 0.75 (new): its length 0.33 → 0.25 m along its slant, the head's joint moved down with it
  (`ke-bk-joint-y` / `-z`: 0.4 / 0.08 → 0.3175 / 0.06).
- The edge parallel to the spine: `*ke-bk-width*` 0.64 (new; the width the copied Nozarashi taper reached at the break, 0.32 at the
  foot); Nozarashi's widening (`*ke-bk-k-cap*`, `-mid`, `-k-end`, `ke-bk-k`, `ke-bk-widen`) dropped from the copy. The beak (the point
  at the blade's foot) scaled out from the spine to meet the new edge (`ke-bk-beak`; a first try had put its back corner on the edge
  line, a dark wedge under the hook).
- The point's droop below the edge line `*ke-bk-hook*` 1 → 0.5 → 0 (0.24 m → 0.12 → along the edge line).
- Parallel to the haft: the head's 5° turn `*ke-bk-pitch*` −0.0873 → 0 and the spine flat (`ke-bk-spine` 0.07; it rose 0.016 m).
- `:length` 1.2 → 1.22 (the break 0.66 above the hand). The host FK test drew the placeholder Bankai J2 NAGI-HARAI (`:ke-b-j2`,
  and its copy J2S) 0.16 m past its volume: `:reach` 1.28 → 1.44.
Nozarashi's still byte-identical after each step; the cleaver's faces and the Bankai turntable shot at each. Host tests 9831 ALL
PASS, pkgcheck clean. (G2 ran once after the first two steps, identical, before 「先不要跑對戰測試」.) Playtest v316.

### 24.1 The point droops slightly again (2026-11-04)

The user: 「抱歉是我沒說清楚，刀尖依舊輕微下彎，刀刃則改成與刀柄平行」: 「跟刀柄平行」 meant the edge, not the point. `*ke-bk-hook*` 0 → 0.5
(the point 0.12 m below the edge line, in the head's frame); the edge and the spine stay parallel to the haft (`*ke-bk-pitch*` 0, the
spine flat). Nozarashi byte-identical, host tests 9831 ALL PASS, pkgcheck clean. Playtest v317.

## 25. The Bankai cleaver scaled down (2026-11-04)

The user: 「整體縮小成 0.8 倍，刀身額外再縮小成 0.8 倍」, then 「兩個倍率都從 0.8 改成 0.9」.
- `*ke-bk-size*` 0.9 (new): the whole cleaver (haft, bar, head) scaled about the hand, so the grip stays put;
- the head `*ke-bk-scale*` 0.675 → 0.6075 (×0.9 more, on top of the size);
- `:length` 1.22 → 1.06 (the break 0.62 up the head frame + the grip slide 0.56, ×0.9), `:base` 0.7 → 0.63.
The placeholder Bankai J1 / J2 reaches go back to 1.28 (from §23's 1.48 / §24's 1.44): the drawn far end is near its old 0.9 again
and the Bankai is checked one-sided (the art not past the volume + 0.15), passed at 1.28 with the 0.8 and 0.9 sizes. Nozarashi
byte-identical; host tests 9831 ALL PASS, pkgcheck clean (no match tests at this stage). Playtest v318.

## 26. The Bankai batch: the frame table (draft, mine, knobs; for the user's approval)

The user: 「定案，可以開始下一步了」 (the cleaver of §22–§25 final). The styles are §5.4's (approved); the rules B1–B3 (§4). The weapon:
the long haft held halfway, the head 1.06 m past the grip, so a cut reaches about 1.8 m past his centre (the arm 0.7 + the cleaver).
Two kits replace the placeholder `:bankai` (DUEL_KEN_CORE §8's three pointers): one per Shikai pointer it is entered from, each with one
pointer, its own stance, NS, AS and special AS, its own Kikon cinematic. Damage before the kit's ×1.2; hitstop by damage as the Shikai.

| Move | S | dmg | reaction | reach / travel |
|---|---|---|---|---|
| J1–J5 (one string for both, the axe) | 8 / 8 / 9 / 9 / 11 | 45 / 45 / 50 / 50 / 70 | flinch ×4, stagger | 1.8 |
| 狂嵐 (from P1) NS a the lunge cut | 14 | 80 | stagger | 1.8, dash 3.0 |
| b the spin | 10 | 70 | stagger | 1.9, all round |
| c the reverse spin | 10 | 70 | stagger | 1.9, all round |
| d the sword dance | 8 | 40 + 40 | flinch, crumple | 1.8 |
| AS: the segments of a → b → (d) → the spinning leap cut, the last one knocks down | 12 | as the segments, the last 110 | knockdown | |
| special AS 千切 (SP after J5; the space-cutting draw, §5.4) | 12 | 300 | knockdown, the Kikon hold works | 2.4 at his place (the cuts in the air drawn only) |
| 斬壞 (from P2) NS a the shoulder-drop overhead chop | 16 | 100 | crumple | 1.9 |
| b the dragged rising chop | 12 | 90 | stagger | 1.9 |
| c both hands, the flat sweep | 14 | 100 | stagger | 2.0, 180° |
| d the turning chop | 16 | 130 | crumple | 2.0 |
| AS: the segments of a → b → (c) → d, the last one knocks down | 12 | as the segments, the last 150 | knockdown | |
| special AS TATE-GOTO (SP after J5; canon ch. 670) | 20 | 320 | knockdown, the Kikon hold works | 2.4 |

Rules: every NS segment and AS segment costs him 40 Reiatsu, never below 1 (B2); the special AS: −1 Konpaku (none on his last, §4), then
back to the Shikai on the pointer he came from, L 0 (B3); no other way out of the Bankai. No mid-route knockdown (an SA may follow any NS
segment). Kikon cinematics: 狂嵐 the space shattering round him and the roar (the 千切 idea, §5.4); 斬壞 a new split of its own (the sealed
form's pointer 3 keeps `ken-sky-split-cine`, so TATE-GOTO's Kikon is not the same white line). The CPU: the generic core one.

### 26.1 Asked, answered (verbatim) and the table revised

| Question | Answer |
|---|---|
| NS segments (§5.4's table had four, B1 said three) | 「4 段（照表）」: a → b → c → d for both. |
| The AS, now that SP after J5 is the special AS (the core's J1–2 → AS1, J3–4 → AS2, J5 → AS3) | 「只有一種 AS」: SP after J1–J4 is the one AS, its segments as many as the J links landed; after J5 the special AS. |
| One J string for both Bankai or one each | 「各自一串」: 狂嵐's quick one-hand flourishes, 斬壞's heavy dragged chops. |

So each Bankai: J1–J5 of its own; NS a → b → c → d; the AS after Jn (n 1–4) = n segments, the first n − 1 NS a, b, c's cuts and the
last its finisher (狂嵐 the spinning leap cut 110, 斬壞 the turning chop 150, knockdown); SP after J5 = the special AS.

| | 狂嵐 (from P1) J1–J5 | 斬壞 (from P2) J1–J5 |
|---|---|---|
| S | 7 / 7 / 8 / 8 / 10 | 9 / 10 / 10 / 11 / 13 |
| dmg | 40 / 40 / 45 / 45 / 65 | 50 / 55 / 55 / 60 / 85 |
| reaction | flinch ×4, stagger | flinch ×4, stagger |
| reach | 1.8 | 1.9 |

### 26.2 The Bankai's sim built (2026-11-04)

`ken.lisp`: the placeholder `:bankai` (DUEL_KEN_CORE §8's three pointers) replaced by two kits from one macro `def-ken-bankai`:
`:bankai` 狂嵐 KYORAN (moves `:ke-kr-*`) and `:bankai-2` 斬壞 ZANKAI (`:ke-zh-*`). `ken-as-pick`: J7 + SP enters the Bankai of the current
pointer. Each kit: J1–J5 (`:strings`), each J link's `:params :as-ptr` 1–5 names the AS (the core's `core-next-as`), `:core :as` the five
entries (AS1 = the finisher alone, AS2 = a → finisher, AS3 = a → b → finisher, AS4 = a → b → c → finisher, the special), `:as-writes`
(1 1 1 1 1), one NS (a → b → c → d), the SA a J1 copy. Every NS / AS segment's frame 0 `ken-bk-cost` (`*ken-bk-cost*` 40 Reishi, `burn`:
never below 1); the special's `ken-bk-special` (the cost and `fighter-bk-out`); the kits' `:tick` `ken-bk-tick`: once he is out of the
move (and any Kikon cinematic), −1 Konpaku unless it is his last, the Shikai on the pointer he came from, L 0. No arm, no meter (the old
moves and clips stay in the files for the art round and the cleanup). Borrowed clips (the Shikai's) until the art round: 狂嵐's J5 and 斬壞's
J3 / J5 draw their arm-out cuts 2.3 m, so their reach is 2.2 until their own clips (the host FK test, one-sided for the Bankai).
Stances `:ke-b-stance`, Kikon cinematics `ken-oni-kikon-cine` / `ken-sky-split-cine` for now. Debug 84004 / 84005: the 84000 scene in
狂嵐 / 斬壞.

Checks (no match tests at this stage): host tests 9874 ALL PASS (the old Bankai's checks rewritten: per kit the classes, the chains 1 / 2 /
3 / 4 / 4 / 1, S and damage, no NS knockdown, the cost and the way back on frame 0; the old Bankai's clips out of the clip list), pkgcheck
clean, the build. Scripts (P1 vs an idle Ichigo): 84004 / 84005 SP ×4 → NS a–d, four costs (1300 → 1140); J1 J2 J3 + SP ×3 → AS3, three
segments, the finisher knocks down; J1–J5 + SP → the special (300 / 320), then `form NOZARASHI`, `BANKAI ends: Shikai pointer 1` / `2`,
Konpaku 9 → 8. From the Shikai (84001, pointer 2510 / 2511, L3): J1–J7 + SP → `BANKAI from pointer 1` → `form BANKAI` / `BANKAI-2`, the
Bankai cinematic; J1–J5 + SP held → the special's Kikon (−3 Konpaku), its cinematic, then back to the Shikai. The manual's Bankai entry
rewritten. Playtest v319. Next: the art round (both kits' own clips, stances, the 千切 look, the two Kikon cinematics).

### 26.3 Nothing restored on entry: a special form, not an awakening (2026-11-04)

The user: 「進入卍解不回復狀態，劍八的卍解算特殊形態，不計入覺醒」. `bankai!` takes a third argument RESTORE (default T, the old P-key and
DANGAI paths unchanged); `ken-as-pick` (J7 + SP) passes NIL: no awakening regen (`start-awake-regen!`) and no Reishi refill. His
Konpaku, Reiatsu, flash-step and guard gauge were already kept. Script (84001, pointer 1, L3, Ichigo's J1 twice on him, then J1–J7 + SP):
Reishi 1236 at the entry stays (1266 at t=600 with his ordinary regen; before, it refilled to 1300). Host tests 9874 ALL PASS. The manual
says it. Playtest v320.

## 27. The Bankai's art round, part 1: the two stances (2026-11-04)

The user: 「按照你說的階段逐步完成美術設計」 (the order proposed after §26.3: the two stances → each Bankai's J1–J5 → NS a–d and the
finishers → 千切's look → the two Kikon cinematics). Part 1, from §5.4's figures (`.refs/kenpachi-v3/`), replacing the borrowed
`:ke-b-stance`:

| | 狂嵐 `:ke-b-kr-stance` (from P1, `bankai-p2-shoulder-figure.png`) | 斬壞 `:ke-b-zh-stance` (from P2, `bankai-p1-low-figure.png`) |
|---|---|---|
| Legs | splayed wide and deep (thighs 40–48 / side 36–38, knees 78–82, hips 0.36 m down, the feet on the floor) | the beast crouch (the old oni's: the left leg forward and deep, the right back) |
| Body | hunched a little (spine 22), the head up at him | rounded over (spine 38, chest 14), the head thrust low |
| Right hand | the haft on the right shoulder, the grip (0.34 1.34 0.31) r u f, the head up behind his left (its far end 1.86 m high), the edge up, the butt out to his front right | out wide at the hip, the grip (0.61 0.86 0.14), the head trailing low out ahead of his right foot (0.18 m off the floor), the edge forward, the butt up behind the right shoulder |
| Left hand | the claw hanging by the left knee | out wide, the claw open |
| Idle | the shoulders rolling, 1.0 s | heaving, 0.8 s |

The arms by FK (the right arm solved for the grip, the blade's direction and its edge, the head kept out of the body); the Bankai
cinematic's last shot plays the kit's own stance. Both read apart from the match camera (84004 / 84005). Host tests 9874 ALL PASS
(the clip list: the two new stances in, `:ke-b-stance` out of it, kept for the old clips' bases), pkgcheck clean. The duelview's
scene 6 shows both side by side.

### 27.1 The awakening's name colour and push kept (2026-11-04)

Asked after §26.3 whether 「不計入覺醒」 also drops the two things the Bankai still shares with an awakening (its form name in the
awakening's orange on the HUD, and the push that throws the opponent off on entry). The user: 「這兩項保留」. Both stay; only the
restore is gone (§26.3).

## 28. The Bankai's art round, part 2: each Bankai's J1–J5 (2026-11-04)

The plan table (proposed after §27.1), approved by the user: 「可以」.

| | 狂嵐 (fast, one hand, the haft flourished) | 斬壞 (heavy, dragged, slow charge, sudden release) |
|---|---|---|
| J1 | off the shoulder, high right → low left | dragged off the floor, low right → high left |
| J2 | the backhand rising, low left → high right | from J1's top, hoisted overhead, chopped down the centre |
| J3 | the haft twirled once in the hand, then flat at the waist, right → left | the head dragged flat along the floor, right → left |
| J4 | dropped into a crouch, the backhand at the shins, left → right | the backhand dragged up, low left → high right |
| J5 | one full turn to his left, the big diagonal down | both hands, wound up over the right shoulder (the head hanging down his back), slammed into the floor (a crack) |

Built as ten clips (`ken-art.lisp`: `:ke-kr-cut1`–`5`, `:ke-zh-cut1`–`5`, each authored at its move's S, so `:clip-s` = S;
each link's frame 0 is the pose the one before lands in, `:ke-kr-aN` / `:ke-zh-aN`). Every hit, coil and landing arm solved by
FK (the grip, the blade's direction, its edge; the head kept out of the body; the feet on the floor). The tip on the active
frames:

| | J1 | J2 | J3 | J4 | J5 | volume |
|---|---|---|---|---|---|---|
| 狂嵐 | 1.73–1.89 | 1.71–1.89 | 1.71–1.89 | 1.84–1.90 | 1.77–1.87 | 1.8 m |
| 斬壞 | 1.93–1.95 | 1.89–1.98 | 1.69–1.94 | 1.95–1.98 | 1.87–1.96 | 1.9 m (J3's 140°) |

So the borrowed clips' reach 2.2 (狂嵐 J5, 斬壞 J3 / J5, §26.2) goes back to 1.8 / 1.9. Details:

- **A full turn without unwinding**: 狂嵐's J3 twirl (the wrist's side 1 → 361°, a key every 90°, out in front of him: the
  flex axis put the head through his face) and J5's turn (the root's yaw 0 → 360° on the hit frame) are rewound on a key
  0.001 s later with the same orientation, so nothing spins back through the next key or the next clip.
- **由緩至急 (斬壞)**: a small first key, the coil keyed :snap (linear: the match's ease-out made the charge's first frames
  fast), held 1–2 frames trembling, the release in the last 2 frames, a frame past the hit, the weight dragging back. The
  tip per frame (m): J1 charge ≤ 1.4 / release 2.4, J2 1.2 / 2.2, J3 0.6 / 1.3, J4 0.2 / 1.6, J5 0.6 / 2.7.
- **斬壞 J5**: two-handed (`*grip-clips*`, GRIP-LEFT! holds the left fist on the handle); on its hit frame
  `ken-bk-slam` (a look): a 2.4 m ground crack, a scar 1.9 m ahead, the crack sound.

Checked: host tests 9874 ALL PASS (the ten clips in the §5 clip list), pkgcheck clean, the strips from the side and 33° off
the front (duelview 1000000+1000i+k), and both strings scripted on the idle Ichigo (84004 / 84005, J pressed five times):
every link hits (狂嵐 40 / 40 / 45 / 45 / 65, 斬壞 50 / 55 / 55 / 60 / 85). No match tests at this stage (DEVLOG §576).
The manual's Bankai entry names the new moves.


## 29. The Bankai's art round, part 3: NS a–d and the AS finishers (2026-11-04)

The plan table (proposed after §28), approved by the user: 「可以」. Each one is a plane the J string doesn't use.

| | 狂嵐 | 斬壞 |
|---|---|---|
| NS a | the lunge cut: the tell (crouched, the head trailing on the floor behind his right, held), the 3 m lunge, low right → high left | the shoulder-drop chop: the head carried on the right shoulder, squatted to charge, a hop, one hand slamming it down, the body falling after it |
| NS b | the spin: one full turn to his right, the arm straight out, a flat circle at the shoulder | the dragged rise: the head dragged back along the floor to his feet, then straight up the centre line |
| NS c | the reverse spin: crouched, one full turn to his left at the knees | both hands, wound far to his right, the flat sweep at the chest, right → left |
| NS d | the sword dance: the haft spun flat over his head like a propeller, then the cross (two hits): overhead right steep down to his left, high left down to his right | the turning chop: one full turn to his right, the backhand raised over his left shoulder, the heavy diagonal down to his right |
| finisher | a leap, one turn in the air, the vertical chop down the centre on landing (knockdown) | both hands, from low behind his left, the whole body rising through to his right (knockdown); its own clip, no longer NS d's |

Built as ten clips (`ken-art.lisp`: `:ke-kr-ns-a`–`d`, `:ke-kr-fin`, `:ke-zh-ns-a`–`d`, `:ke-zh-fin`), each at its move's S
(`:clip-s` = S). Only the moves' `:clip`, `:clip-s` and `:blend` changed (presentation; the sim never reads them):

- **Frame 0**: NS b / c / d's is the segment before's landing pose (an NS links on as soon as its active frames end, so
  b follows only a, c only b, d only c). NS a and the finisher have several predecessors (neutral; the J1–J4 landings for the
  AS; a / b / c's for the finisher), so they get `:blend 3` (a 3-frame crossfade in `start-move`), and the AS copies
  inherit it.
- **The full turns** (狂嵐 b / c, the finisher's turn in the air, 斬壞 d; NS d's propeller on the wrist's twist): a key
  every 90° or so, rewound on a key 0.001 s later with the same orientation, as in §28.
- **Two-handed**: 斬壞's NS c and finisher (`*grip-clips*`, GRIP-LEFT!).
- **由緩至急 (斬壞)**: as the J string (§28): a small first key, the coil keyed :snap, a held tremble of 2–3 frames, the
  release in the last 2 frames, a frame past the hit, the head dragged back out to his right in the recovery. NS d's turn is
  its charge, accelerating keys (90° in 4 f → 100° in 2 f).
- **Waypoints**: where an interpolation put the blade under the floor or through his body (狂嵐 b's wind-up, a's drop into
  the tell, 斬壞 a's lift onto the shoulder, the finisher's charge round the front and its follow-through), a key solved by FK
  in between.

The tip on the active frames (m, FK, the match's ease; NS d both hit windows):

| | NS a | NS b | NS c | NS d | finisher | volume |
|---|---|---|---|---|---|---|
| 狂嵐 | 1.85–1.86 | 1.93 (the circle) | 1.87 (the circle) | 1.58–1.85 / 1.65–1.88 | 1.86–1.91 | 1.8 m (b / c 1.9 m, 360°) |
| 斬壞 | 1.91–1.97 | 1.85–1.93 on its hit frames | 1.96–2.03 | 2.03–2.06 | 2.03 on its hit frame | 1.9 m (c / d / finisher 2.0 m) |

Checked: host tests 9874 ALL PASS (the ten clips in the §5 clip list; the reach test reads ease 0, every active frame
within +0.15 m of the volume); pkgcheck clean; the strips from the side and 33° off the front (duelview); scripted on the
idle Ichigo (84004 / 84005): NS a → b → c → d and the AS after J1–J4 in both Bankai, every segment hits (狂嵐 NS 80 / 70 /
70 / 40 + 40, the finisher 110; 斬壞 NS 100 / 90 / 100 / 130, the finisher 150). No match tests at this stage (DEVLOG §576).
Left as is: a few recovery frames where the heavy head drags up to 0.2 m into the floor, and 斬壞 b's rise passing close
to his face. The manual's Bankai entry names the new moves.
