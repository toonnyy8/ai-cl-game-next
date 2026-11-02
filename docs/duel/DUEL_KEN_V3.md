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
| S2 | +1 L for each NS route or same-pointer AS that lands at least one unguarded hit (once per route, not per hit); guarded / cancelled / whiffed: +0 | 1 per route |
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
