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
