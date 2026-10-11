# SOUL DUEL: Lille Barro II, awakening v3: the stance grammar (proposal)

Status: **revision 3 built 2026-10-10 (the user: 「開始實作」; §7 the build notes). The current Lille II (kit `:barro`).** The current kit is `DUEL_LILLE_V2.md` (decisions
V1–V9l); this file holds the animation inventory the user asked for and the v3 design drawn from the base form's stance.

The request (the user, 2026-10-10), verbatim:

> 請幫我彙整 lille 所有的動畫模組，並依據覺醒前的架式概念構思全新的版本三設計。

Reading [G]: "版本三" is the third design of Lille II's awakening (the user, earlier the same day: 「我想第三次重新設計覺醒狀態」,
paused with 「主要是軌跡的手感不好，想用新玩法替代」; kept: the owl's revival, U MUJITTAI, the melee / ranged forms, the K → L
five-tier recall; wanted: 指向, materialising one by one and all at once, the J / K feel split with a fast pendulum that
spends flash step and returns Reiatsu and big Reiatsu spends for output or flash step). The base form stays as built. If a
separate fighter (a "Lille III", roster index 7) is meant instead, the design below still applies; only the build plan (§6)
changes.

## 0. User decisions on the proposal

### R1 (2026-10-10): three stances, the burst owl, one spend-all, plain guard, SP by wings, the 4-wing armour

The user, on revision 1 (verbatim):

> - 我想把架式改有不同的效果，包含高攻擊、高額普通資源恢復、高額特殊資源恢復
> - 取消掉再覺醒，改成爆氣時會進入梟頭模式與獲得對應的 buff（因此取得資源並進入爆氣變成主要的輸出循環）
> - 盡量避免不同手段的效果同質化 e.g. 不要有多種將資源耗盡來打出高額傷害的路線
> - U 變成普通防禦
> - 依據特殊資源數量不同，SP1 與 SP2 會有相對應的變化
> - 攻擊時如果被攻擊可以消耗四片翼使自己不會被打斷（不足時不觸發效果）

What it changes in revision 1: the one stance becomes **three** (§3.2); the owl's revival (Konpaku ≤ 4) is gone and the
owl becomes **the awakened burst** (§3.4); only **one** route spends every wing for damage (§3.3); U is a **plain guard**
in every form (MUJITTAI gone); SP1 / SP2 **read the wing count** (§3.5); a hit during his own attack can spend **4 wings**
to keep it going (§3.6). Read as accepted by building on it: the wing magazine replaces the ground traces (rev. 1's Q1).
Superseded: rev. 1's Q2 (the stance's K: no longer a spend-all) and Q3 (the tiers matter only for the one volley).

### R2 (2026-10-10): one stance by L, its three strings; the base too; one owl buff set

The user, on revision 2 (verbatim):

> 架勢用 L 進入（兩個相同的符號代表連擊）
> 1. 架勢 > LL：回收特殊資源
> 2. 架勢 > KK： 高攻擊，可以再銜接 JJ 消耗資源提高傷害
> 3. 架勢 > JJ： 高額閃步/SP 量表恢復，可以再銜接 KK 消耗資源提高恢復量

Then four questions (AskUserQuestion, the recommended first):

| Question | The user's pick |
|---|---|
| Where it applies (only the awakening / the base too) | **「常態也一起改」** |
| The follow-up's price (1 a hit / 4 at once / all) | **「每下花 1 翼」** |
| Back to melee (a forward Step dashes / the string's end / when the stance lapses) | **「連段打完自動回近戰」** |
| Rev. 2's Q3 / Q4 (buffs by colour and the volley the owl's only / one buff set / the volley always) | **「buff 不分顏色」** (the volley stays the owl's only) |

What it settles: rev. 2's Q1 (shared = flash step and Reiatsu, special = the wings / the base's pips: 「高額閃步/SP 量表恢復」),
Q2 (one stance, its strings pick the effect: replaces the three stances), Q3 (one buff set), Q4 (the owl's only), and the
base stance's spend-all K (replaced by its KK → JJ).

## 1. The animation inventory

Lille's art lives in two files and is shared by both kits (`DUEL_LILLE_V2` §2: the art is shared, not copied):
`lille-art.lisp` holds **73** clips (`defclip` / `defstrike`) plus their poses, `barro-art.lisp` **17** (Lille II's
recall, its strings, the mode turns, the owl's twins). Walking, running, Step, Hoho, guard and the hit reactions use the
game's generic clips on his bodies, not clips of his own. Frames are startup / active / recovery as the clip is timed
(`defstrike`), or a loop's length. "v3" is the proposed use (§3–§6).

**Base form (the man and Diagramm)** (`lille-art.lisp`)

| Clip | Frames (S / A / R) | Motion | Lille | Lille II | v3 |
|---|---|---|---|---|---|
| `:lb-stance` | loop 2.6 s | idle: upright, Diagramm levelled at the hip | idle | idle | idle |
| `:lb-aim` | loop 0.6 s | the shouldered aim, held | old L aim | Kikon's wind-up | as II (Kikon) |
| `:lb-fire` | 4 / 2 / 26 | the shoulder shot: recoil, the plank drops | old L shot | Kikon's shot | stance L 1 (gather) |
| `:lb-snap` | 6 / 2 / 20 | the snap shot from the hip | unused | stance J snap (also in a Step) | stance J 1; L 2 |
| `:lb-q1` | 8 / 3 / 12 | J1 SHOBI-UCHI: the rifle reversed, the plank swung up | J1 | J1 | J1 |
| `:lb-q2` | 7 / 3 / 13 | J2 KAESHI: the plank's backhand | J2 | J2 | J2 |
| `:lb-jab` | 9 / 3 / 18 | J3 JUKO-TSUKI: the muzzle cross jabbed up | J3 | J3 | J3 |
| `:lb-f1` | 17 / 4 / 21 | K1 JUSHIN-NAGI: the barrel swept flat | K1 | K1 | K1 |
| `:lb-f2` | 20 / 4 / 24 | K2 FURIOROSHI: raised overhead, brought down | K2 | K2 | K2 |
| `:lb-f3` | 21 / 5 / 34 | K3 REI-KYORI: the muzzle pressed in, fired | K3 | K3 | K3 |
| `:lb-sanren` | 12 / 22 / 24 | SP1 SANREN: three shoulder shots, turning | SP1 | SP1, stance SP1 | SP1 (by the pips) |
| `:lb-hiren` | 20 / 2 / 22 | SP2 HIRENKYAKU: the low back-slide, then a shot | SP2 | SP2, stance SP2 | SP2 (by the pips) |
| `:lb-kamae` | loop 0.8 s | the 狙撃構え: low, levelled, aimed | stance | the stance | L into the stance |
| `:lb-k-shot` | 10 / 2 / 26 | stance L: 10 f on the line, the crack, the recoil | stance L | stance L | stance K 1 (heavy) |
| `:lb-k-hosha` | 6 / 10 / 16 | HOSHA: the leap, three bullets in the air | stance J | unused (V9b) | stance J 2 (revived) |
| `:lb-k-taisha` | 16 / 2 / 24 | TAISHA: the 3 m back-slide, the shoulder shot | stance K | stance K (1 / 2 / 3 pips) | stance K 2 |
| `:lb-k-dash` | 12 / 0 / 0 | HIRENKYAKU: the stance Step, crouched | stance Step | stance Step | stance Step |
| `:lb-breaker + :lb-butt` | loop 0.4 s; 8 / 4 / 18 | Breaker: the dash, the plank slammed down | Breaker | Breaker | same |
| `:lb-intro / :lb-win` | 2.0 s | intro (the rifle levelled) / win (the rifle upright) | yes | yes | same |

**Jilliel melee (KIN, the wing blades)** (`lille-art.lisp`)

| Clip | Frames (S / A / R) | Motion | Lille | Lille II | v3 |
|---|---|---|---|---|---|
| `:lb-w-stance` | loop 3.0 s | idle: afloat, the eight wings fanned | idle | idle | idle (lit wings = the magazine) |
| `:lb-w-q1` | 8 / 3 / 12 | J1 左斬: the right wing cut right to left | KIN J1 | KIN J1 | KIN J1 |
| `:lb-w-q2` | 7 / 3 / 13 | J2 右斬: the mirror | KIN J2 | KIN J2 | KIN J2 |
| `:lb-w-q3` | 9 / 3 / 18 | J3 十字: both wings crossed down | KIN J3 | KIN J3, the empty recall | KIN J3 |
| `:lb-w-f1` | 17 / 4 / 21 | K1 旋: a full turn, the right wing sweeping | KIN K1 | KIN K1 | KIN K1 |
| `:lb-w-f2` | 20 / 4 / 24 | K2 逆旋: the counter-spin | KIN K2 | KIN K2 | KIN K2 |
| `:lb-w-f3` | 21 / 5 / 34 | K3 昇翼: a rising cleave, the landing | KIN K3 | KIN K3 | KIN K3 |
| `:lb-w-fold` | loop 2.0 s | MUJITTAI: the wings curled round the column | MUJITTAI | MUJITTAI, the L turn | spare (MUJITTAI dropped) |

**Jilliel ranged (EN, the casts)** (`lille-art.lisp`)

| Clip | Frames (S / A / R) | Motion | Lille | Lille II | v3 |
|---|---|---|---|---|---|
| `:lb-e-q1` | 4 / 3 / 6 | EN J1: the right wing thrown down along the line | EN J1 lay | ranged L, 1st | stance J 1 |
| `:lb-e-q2` | 4 / 3 / 6 | EN J2: the mirror | EN J2 | ranged L, 2nd | stance J 2 |
| `:lb-e-q3` | 5 / 3 / 9 | EN J3: both wings crossed onto the line | EN J3 | unused | stance L 2 (revived) |
| `:lb-e-f1` | 9 / 4 / 10 | EN K1: a whirl, the right wing fanned low | EN K1 | ranged L, 3rd | stance K 1 |
| `:lb-e-f2` | 10 / 4 / 12 | EN K2: the counter-whirl | EN K2 | ranged L, 4th | stance K 2 |
| `:lb-e-f3` | 11 / 5 / 17 | EN K3: risen, both wings slammed down | EN K3 | ranged L, 5th | spare |
| `:lb-e-sanren` | 6 / 14 / 12 | EN SP1: three lines | EN SP1 | ranged SP1 (3 points) | SP1 in the stance (by the wings) |

**Jilliel's specials and Kikon** (`lille-art.lisp`)

| Clip | Frames (S / A / R) | Motion | Lille | Lille II | v3 |
|---|---|---|---|---|---|
| `:lb-w-sanren` | 12 / 22 / 24 | KIN SP1: three wing shots | KIN SP1 | KIN SP1 | KIN SP1 (FS back by the wings) |
| `:lb-w-nijushi` | 40 / 6 / 30 | NIJUSHI-KO: the ring charged, the beam | SP2 | SP2 (melee beam / ranged thick line) | SP2 (fixed damage; wings cut the charge) |
| `:lb-w-kikon + -fire` | 8 / 0 / 0; 20 / 3 / 30 | Kikon: the wind-up, the fire | Kikon | Kikon | Kikon |
| `:lb-w-judge-open / -shot / -close / -volley` | 24 / 0 / 64; 2 / 0 / 14; 6 / 0 / 40; loop | the old Kikon cinematic's judgement beats | cinematic | unused | spare (for the full volley's look) |
| `:lb-w-breaker + :lb-w-ram` | loop 0.4 s; 8 / 4 / 18 | Breaker: the ram | Breaker | Breaker | same |

**Turns, dashes, the recall (incl. Lille II's own)** (`lille-art / barro-art`)

| Clip | Frames (S / A / R) | Motion | Lille | Lille II | v3 |
|---|---|---|---|---|---|
| `:lb-w-tenshin` | 14 / 0 / 8 | TENSHIN out: fold, the flash step, open | TENSHIN out | J3 → L backstep | J3 → L backstep into the stance |
| `:lb-w-tenshin-in` | 30 / 0 / 8 (cancel at f14) | TENSHIN in: the wind-up, the dash | TENSHIN in | ranged J dash | spare (no dash) |
| `:br-to-en` | 12 / 0 / 0 | melee to ranged: folded, risen, thrown open | — | L to ranged | L into the stance |
| `:br-recall` | 8 / 0 / 0 | 回収: flung open, the light flies in | — | K3 → L recall | spare (the volley is the owl's) |
| `:br-rc0` | 6 / 2 / 24 | 空收: one line, both wings | — | 0 traces | spare |
| `:br-rc1` | 6 / 12 / 24 | 二連: right f6, left f16 | — | 1–2 | spare |
| `:br-rc2` | 6 / 28 / 24 | 四連: three beats and the launch | — | 3–5 | spare |
| `:br-rc3` | 6 / 32 / 26 | 裁き: four beats, the ring, the beam | — | 6–9 | spare |
| `:br-rc4` | 6 / 44 / 30 | 裁き・極: six beats, the ring, the big beam | — | 10+ | spare |
| `:br-e-swing / :br-oe-swing` | 7 / 3 / 6; 7 / 3 / 5 | V8's ranged L swing | — | withdrawn (V8b) | stance L 1 (revived) |

**The owl (v3: the burst mode)** (`lille-art / barro-art`)

| Clip | Frames (S / A / R) | Motion | Lille | Lille II | v3 |
|---|---|---|---|---|---|
| `:lb-o-stance` | loop 2.4 s | KIN: pitched on the ㄇ legs, wings back | idle | idle | burst owl idle |
| `:lb-o-q1 / q2 / q3` | 8/3/12; 7/3/13; 9/3/18 | 右爪撕 / 左爪撕 / 雙爪剪 | J1–J3 | J1–J3 | burst owl J1–J3 |
| `:lb-o-f1 / f2 / f3` | 17/4/21; 20/4/24; 21/5/34 | 掠爪 / 回爪 / 俯衝 | K1–K3 | K1–K3 | burst owl K1–K3 |
| `:lb-o-chop` | 16 / 0 / 24 | SABAKI NO KOMYO: the chop | SP1 | MISUJI SP1 | burst owl SP1 |
| `:lb-o-trompete` | 60 / 30 / 40 | TROMPETE: the fist at the beak | SP2 | SP2 (reflectable) | burst owl SP2 |
| `:lb-oe-stance` | loop 2.6 s | EN: upright, afloat, wings wide | idle | idle | the burst owl's stance |
| `:lb-oe-q1 / q2` | 4 / 3 / 5 | EN claw casts | EN J1–J2 | ranged L 1–2 | owl stance J 1–2 |
| `:lb-oe-q3` | 5 / 3 / 8 | EN J3: both claws and a peck | EN J3 | unused | owl stance L 2 |
| `:lb-oe-f1 / f2 / f3` | 9/4/9; 10/4/11; 11/5/16 | EN rakes and the slam | EN K1–K3 | ranged L 3–5 | owl stance K 1–2 (f3 spare) |
| `:lb-oe-sabaki` | 6 / 14 / 11 | EN SP1: three chops, a line each | EN SP1 | ranged SP1 | owl stance SP1 |
| `:lb-o-fold / :lb-oe-fold` | loop 2.0 s | MUJITTAI, each mode's silhouette | MUJITTAI | MUJITTAI | spare (MUJITTAI dropped) |
| `:lb-o-tenshin / -in` | 14 / 0 / 8; 30 / 0 / 8 | the owl's TENSHIN out / in | TENSHIN | in: ranged J; out: unused | spare (no dash) |
| `:br-o-to-en / :br-o-backstep` | 12 / 0 / 0; 14 / 0 / 8 | KIN to EN / the backstep (ranged at f0) | — | L turn / J3 → L | as II (in the burst) |
| `:br-o-recall, :br-o-rc0 … rc4` | as Jilliel's | the recall strings on the claws | — | the recall | the burst's full volley (the one spend-all) |
| `:lb-o-breaker + :lb-o-stamp` | loop 0.4 s; 8 / 4 / 18 | Breaker: the stamp | Breaker | Breaker | burst owl Breaker |

**Cinematics** (`lille-art.lisp`)

| Clip | Frames (S / A / R) | Motion | Lille | Lille II | v3 |
|---|---|---|---|---|---|
| `:lb-rise` | 1.0 s | the revival: the headless column rises | cinematic | cinematic | spare (the revival dropped) |
| `:lb-o-reveal` | 2.0 s | the owl revealed | cinematic | cinematic | burst transformation (candidate) |

**Spare clips** (in no move of revision 3): `:lb-e-f3` / `:lb-oe-f3`, `:lb-w-tenshin-in`, `:lb-o-tenshin` /
`-in` (no dash), Jilliel's `:br-recall` and `:br-rc0..rc4` (the volley is the owl's), `:lb-w-judge-*`, the MUJITTAI folds
`:lb-w-fold`, `:lb-o-fold`, `:lb-oe-fold`, the revival's `:lb-rise`. Revived from the spares: `:lb-k-hosha`, `:lb-e-q3` /
`:lb-oe-q3`, `:br-e-swing` / `:br-oe-swing`.

## 2. What the base stance already is

Lille II's base form (`DUEL_LILLE_V2` §4, decisions V1, V6, V9–V9e, V9i, V9l) is a complete little grammar:

| # | Rule | Built as |
|---|---|---|
| B1 | A string ends in L to open the stance | J / K link → L opens `:br-kamae` at f4 (V9c), only with ≥ 1 pip (V9e) |
| B2 | The stance's L / SP1 / SP2 are shots with 萬物貫通 that **load** on a hit | +1 狙擊 pip (within 3 m +2, V8), cap 3 |
| B3 | The stance's J **spends one**: fast, small, links back to J1 | the snap shot 40, 1 pip (V9b, V9c) |
| B4 | The stance's K **spends all**, tiered by the count: slow, big | 退射 70 / 穿甲弾 110 / 破陣弾 150 (V9) |
| B5 | The Step keeps the stance and shoots on the move | HIRENKYAKU; J in any Step = the moving snap (V9i, V9l) |
| B6 | Empty, J / K are the plain J1 / K1; an empty string never reopens the stance | V9d, V9e |

B3 and B4 are the user's two materialisations already: one at a time, and all at once.

## 3. v3, revision 3

### 3.1 Resources

| Resource | Base | Awakened / the burst owl |
|---|---|---|
| Shared (普通) | flash step (100; a burst needs 70) and Reiatsu (3 bars) | the same |
| Special (特殊) | 狙擊 pips, cap 3 | 翼 the wings, cap 8 (a lit blade each; the owl's gold wings); the pips carry in as wings |

### 3.2 One grammar in every form

Attack state = the form's J / K strings (the man with Diagramm, KIN's wing cuts, the owl's claws), plain: no resource in
or out. **L enters the stance** (from neutral, after a string, J3 → L the backstep `:lb-w-tenshin`). In the stance a
button's first press picks a string; **every string ends back in the attack state** (R2). A button always plays the same
clips, so the follow-up looks like the other string's opening.

| In the stance | Hits | Effect [numbers G] |
|---|---|---|
| **L L** 回收 | 2 萬物貫通 shots, 10 each | each hit or block **+1 special** (base pip / wing); the 2nd +2 (a full string: +3) |
| **K K** 高攻 | 2 萬物貫通 shots, **45** each (the owl ×1.1) | damage only |
| → **J J** after K K | 2 shots | each **spends 1 special**: 15 → **45** each (none left: the plain 15) |
| **J J** 回復 | 2 萬物貫通 shots, 15 each | each hit **+10 flash step, +15 Reiatsu** (a block half) |
| → **K K** after J J | 2 shots | each **spends 1 special**: **+20 flash step, +30 Reiatsu** more on its hit (none left: no extra) |

Step keeps the stance; a J in its Step starts J J on the move (V9l's moving snap carried over) [G]. U guards (every form).
Rejected sinks (R1 「避免同質化」): KIN's J no longer fires a wing; TENSHIN in (the forward dash) is gone (R2: the string's
end returns to melee).

| Clips | L | J | K |
|---|---|---|---|
| Base (`:lb-kamae`) | `:lb-fire`, `:lb-snap` | `:lb-snap`, `:lb-k-hosha` (revived) | `:lb-k-shot`, `:lb-k-taisha` |
| Awakened (EN, `:br-to-en`) | `:br-e-swing`, `:lb-e-q3` (revived) | `:lb-e-q1`, `:lb-e-q2` | `:lb-e-f1`, `:lb-e-f2` |
| The owl (EN) | `:br-oe-swing`, `:lb-oe-q3` | `:lb-oe-q1`, `:lb-oe-q2` | `:lb-oe-f1`, `:lb-oe-f2` |

### 3.3 The burst owl and the one full volley

- A burst in an awakened form (any colour, the shared rules) turns him into the owl until it ends, then back. No
  cinematic (`:lb-o-reveal` a candidate flourish). The base's burst stays plain [G].
- **One buff set** (R2: 「buff 不分顏色」) [G]: damage ×1.2, +1 wing a second, the 4-wing armour costs 2; plus V9j's owl
  numbers where they still apply (SP2 Trompete 120, its reflect and seal).
- **The full volley**: K3 → L in the owl, `:br-o-recall` → `:br-o-rc0..rc4`, every wing, tiers 0 / 1–2 / 3–4 / 5–7 / 8 =
  30 / 70 / 160 / 300 / 480 [G], SP2 after it uncharged (V9l). **The only spend-all**; outside the owl K3 → L opens the stance.

### 3.4 SP1 / SP2 by the special count (read, not spent)

| Wings (base pips) | SP1 (1 bar) | SP2 (2 bars; fixed damage: NIJUSHI-KO 90, the owl's Trompete 120, the base's HIRENKYAKU 50) |
|---|---|---|
| 0–3 (0–1) | 3 shots, +18 flash step | the charge as built |
| 4–7 (2) | 3 shots, +35 | half the charge |
| 8 (3) | 5 shots, +70 (a burst's worth) | no charge, a guard break on block |

### 3.5 The 4-wing armour

Awakened and the owl (the base's pips cap at 3): a hit that would stagger him during his own attack spends 4 wings (the
owl 2) and the move goes on; he takes the damage. Fewer: the hit lands as usual. Automatic; Breaker, Kikon and throws
ignore it [G].

### 3.6 What is gone

The owl's revival, MUJITTAI, the ground traces and their rules, TENSHIN in, KIN J's wing shot, the base stance's L / J /
K / SP shots as built (V1–V9l: replaced by the three strings) and its spend-all K. The slow motion moves to the first
stance hit of each stance and the volley's last beam (rev. 1) [G].

## 4. Animation plan

Reused: the inventory's v3 column and §3.2's table. New, all cosmetic: the lit wings (and the base's pips on Diagramm's
sleeve or the HUD only [G]); a wing / pip spent in a follow-up (a flash at the muzzle or the wing tip); the armour's
shatter (4 wings at once); optional: the burst's owl flourish (`:lb-o-reveal`), the judge beats for the 8-wing volley.

## 5. Open points

None blocks the build; every [G] number is a starting value for the playtest. Ask again only if the user changes a rule.

## 6. Build plan (after 「開始實作」)

1. Sim (`barro.lisp` only): the special counts and their sinks, the stance's strings and follow-ups in every form, the
   burst owl and its buff, SP1 / SP2 tiers, the armour; the traces, MUJITTAI, the revival, TENSHIN in and the old stance
   moves removed. The armour needs a kit hook in the shared hit path (inert for everyone else).
2. Art: §4. 3. CPU / ASSIST / learning. 4. Docs, manual, playtest; then his gates (6 pairings, the mirror, the A/B).

## 7. Build notes (2026-10-10, the user: 「開始實作」)

### 7.1 What was built

- `duel/lisp/barro.lisp` rewritten for v3 (the V2 copy is in git history, commit cfe2e0c). Kept: 萬物貫通, the base J / K
  strings and decision V8's route split (`BR-DEFSTRING`), the base stance `:br-kamae` (its window, its Step 飛廉脚 once a
  stance), the base SP1 / SP2 in and out of the stance, Breaker, Kikon, JILLIEL's KIN strings and SPs, the owl's strings,
  MISUJI, Trompete and its reflect / seal, the volley strings `:br-rc0..4`, the backstep, the turn `:br-to-en`.
  Removed: the traces and aim points, TENSHIN in, KIN J's materialising, the base stance's L / J / K shots of V1–V9l (and
  the moving snap of V9i / V9l), MUJITTAI and its forms, the owl's revival, the HOSHA / V8 swing / lay moves.
- **The stance strings** (`BR-DEFSTANCE`, one macro per form: `BR-S-*` base, `BR-E-*` JILLIEL, `BR-OE-*` the owl): L1 L2,
  J1 J2 → JK1 JK2, K1 K2 → KJ1 KJ2. J / K are kind `:quick` / `:flash` string links (the generic J / K latch and its
  chain rule: a link goes on after a touch, combos on a hit, no chase); L2 by `BR-S-TICK`'s latch (`:lchain`, from L1's
  S + A, unchained). Every shot a 萬物貫通 hitscan line (31 m), `:track 720` (he faces him in the startup). The follow-ups'
  f0 `BR-S-SPEND`; every shot's f0 `BR-S-START` (its gains unpaid). Clips (§3.2's table): base L `:lb-fire` / `:lb-snap`, J
  `:lb-snap` / `:lb-k-hosha`, K `:lb-k-shot` / `:lb-k-taisha`; JILLIEL L `:br-e-swing` / `:lb-e-q3`, J `:lb-e-q1` /
  `:lb-e-q2`, K `:lb-e-f1` / `:lb-e-f2`; the owl's `:br-oe-swing` / `:lb-oe-q3`, `:lb-oe-q1` / `-q2`, `:lb-oe-f1` / `-f2`
  (R one less). Block advantage -12 where the blockstun allows (`BLOCKSTUN` >= 1 f: the short L / J shots -6 .. -11).
- **The awakened stance** = EN (`:jilliel`, `:shin`): its commands L / J / K the strings' openers; `BARRO-TICK` turns him
  back into KIN when a string run in EN ends in a free state (`BRS-IN-STRING`); a stun leaves him in EN (he may walk, or
  start a string again). KIN's L / a J1 / J2 / K link's L: the turn (12 f); J3 → L the backstep (free since v3); K3 → L the
  turn (the owl: the volley). The base stance: L from neutral or a link at f4 (any pips: V9e's gate is gone, the stance's
  own strings never reopen it: `BARRO-OK` refuses an L link off a stance shot).
- **The special resource** `BRS-AMMO`: the base's cap 3, awakened 8 (`BR-AMMO-CAP`, clamped every step: the pips carry
  in at the awakening). L L's gains in `BARRO-HIT` (a hit or a block, once a move); J J's / J J → K K's flash step and
  Reiatsu through `PAY-GAUGES` (a burst gains no flash step: the shared rule).
- **SP1 / SP2 by the count**: SP1's f0 `BR-SP1-FS-GO` (18 / 35 / 70 flash step; **3 shots at every tier**: the spec's
  5 at tier 2 is not built, the clips have three); SP2 a router (`:br-sp2`, `:br-k-sp2`, `:br-w-sp2`, `:br-o-sp2`: kind
  `:sig`, 1 f, its f0 `BR-SP2-GO` starts the tier's copy): HIRENKYAKU enter 0 / 10 / 18, NIJUSHI-KO 0 / 20 / 38,
  Trompete 0 / 30 / 58; tier 2 `:guard-crush` (Trompete's tier 2 not reflectable); the damage never changes.
- **The burst owl**: `BR-OWL-SWITCH` in `BARRO-TICK`, applied only out of a move (the first gate run crashed: a burst ending
  inside the owl's K1 switched him to JILLIEL, whose kit has no owl link for the latched K2) (`*BR-KEEP-OWL*`: debug, the
  owl kept without one); the owl's kits
  `:mult` 1.2, `*BR-OWL-WING-EVERY*` 60 f a wing; the volley `BR-RECALL-GO` spends every wing.
- **The wing armour**: a kit hook `:armor` (shared code: `DEFENDER-STATE`, fighter.lisp, asks it in a move after the
  move's own armour; `combat.lisp` spends `:armor-hits` only while the move has some): `BR-ARMOR-P` (awakened, kinds
  `:quick :flash :sig :sp`, phase `:main`, wings >= 4 / the owl 2); `BARRO-STRUCK` pays it on `:armored`. The generic
  armour's rules hold: damage, no reaction; a Breaker and an unguardable go through (the Kikon rush's strike is its own
  outcome).
- **The slow motion**: `BRS-SLOW` armed at each stance entry (the base stance's f0, the turn's f0, the backstep); the first
  stance hit then 0.1 for 0.2 s; the volley's last line on a hit 0.2 for 0.5 s.
- **CPU** (`BR-AI-*`): the generic bands and string reflex run the strings (the follow-ups spend when they can); the base
  stance's pick `BR-AI-STANCE-PLAN` (:stance key: L L under half the cap, J J short of flash step / bars, SP2 at 2 bars,
  else K K; the Step on his attack); `BR-AI-REFLEX` the base stance from range (:zone), awakened the burst into the owl
  (`BR-AI-BURST-P`: 5 wings, 70 flash step, inside 6 m); `BR-AI-SP-ENDER` J3 → L the backstep, the owl's K3 → L the
  volley. Learning: one situation `:shot` (the stance's K K on a free opponent; `BR-LEARN-KAMAE-PLAN`). ASSIST: a J link
  → its K link → L; in a stance his J → K K.
- `barro-art.lisp`: the trace / aim-point looks removed; `BR-DRAW` keeps the base stance's aim line (locked through K1 /
  JK1's startup) and the volley's looks; the HUD row draws 3 pips (SN n) or 8 (WG n); the art stills 82100+k rewritten.
- SP2's routers start their tier through the kit's strings (`:tier0` .. `:tier2`, `*BR-SP2-TIERS*`): a move the kit does
  not list can't be started by name (the first build's router stopped there).
- **The looks (§4, an art agent in its own worktree, merged)**: `lille-art.lisp` `*LB-FX*` slot 19 per side (his loaded
  wings + 1; the old Lille never sets it, his path unchanged): `%LB-WINGS` lights the first N blades (rim 0.6 → 0.85, the
  three holes glowing, jade / the owl's gold) and dims the rest (glass 0.12, rim 0.25); `barro-art.lisp` `%BR-SPEND-NOTE`
  reads last frame's count per side (`*BR-WL*`, draw-side memory): one wing (or the volley's) a burst at that blade's tip,
  0.25 s; 2+ at once outside the volley the armour's shatter (a flash along each blade, 6 shards a blade), 0.35 s; a base
  pip a glint at Diagramm's muzzle. Debug 82380+k sets his special to k (stills). The looks gate: 110 of 112 stills
  byte-identical to the parent (every old-Lille still); the 2 others his (`cvc-bk/w3-0`, `cine-barro/barro-awaken-150`).
  Draw 80 B / 10 draws (as before), the spend looks 0 B.
- Shared files touched: `fighter.lisp` (the `:armor` hook), `combat.lisp` (the `:armor-hits` guard): inert for everyone
  else.

### 7.2 Host tests and checks

- `tests/duel-rules-test.lisp`: the Lille II block rewritten (7809 checks, ALL PASS; 8787 before: the traces' checks
  went): the forms (5), no MUJITTAI / revival, the owl switch, the caps and gains, the strings' links / roles / clips /
  prices, **every link combos on a hit** (the next hit lands inside the last one's stun), the base stance's picks, the
  routers' tiers (never more damage), the armour's cases, the volley tiers (30 / 70 / 160 / 300 / 480), the CPU plans.
  Generic blocks skip his stance EN forms where they measure melee strings (`trace-form-p`).
- duel-control / learn / input / touch / cine: pass. pkgcheck 0. `./build.sh duel` 0 warnings (7919 rules checks after
  the SP2 routers' strings).

### 7.3 Browser checks (`node tools/run.mjs dist/duel --fixed-dt 16.666667`, combat log)

| Debug | Input | Result |
|---|---|---|
| 82005 (base, 3 pips, 4 m) | L, K K, J | K1 / K2 / KJ1 hit 58 each (45 x 1.3; KJ1 15 + 30 for a pip), 3 → 2 pips; the stance's slow motion on K1 |
| 82015 (base stance up, 0 pips) | L L | L1 +1, L2 +2: 0 → 3 pips |
| 82016 (base stance, 3 pips, 20 FS, 0 Rei) | J J K K | J1 J2 JK1 JK2 hit: FS 20 → 100, Reiatsu 0 → 132, 3 → 1 pip |
| 82010 (EN, 8 wings) | K K J J | K1 K2 KJ1 KJ2 hit, 8 → 6 wings, back in KIN at its end |
| 82002 (KIN, 0 wings) | L, L L | the turn into EN (11 f), L1 L2: 0 → 3 wings, back in KIN |
| 82013 (KIN, 8 wings, 100 FS) | Shift+J | WHITE: the owl at once; FS drains 18 / s; at 0 (tick 353) back to JILLIEL KIN |
| 82014 (the owl, 8 wings, 1.4 m) | K K K, L | K3 → L: the volley tier 4 (six 40s and the 240 beam: a knockdown, the volley's slow motion), 8 → 0 wings |
| 82017 (KIN, 4 wings) | his K1, P2's J1 | P2's J1 `ARMORED`: 4 → 0 wings, his K1 goes on and hits |
| 82010 | Shift+L | the router → `:br-w-nijushi-2` (no charge): the beam 2 f in, 180 |
| 82005 | L, Step, J J | the stance Step, its J → the stance's J1 J2 |


### 7.4 Gates (native sim, `tools/simgate.py`; no BL, no old-Lille pairing)

20 seeds, all K.O. (median of play time, his wins of 20):

| BY | BK | BR | BI | BS | BB (mirror) |
|---|---|---|---|---|---|
| **96.3 s**, 16 | **118.7 s**, 9 | 154.2 s, 15 | 131.0 s, 13 | 155.3 s, 16 | 136.4 s, 11 |

60-seed reruns of the two under 125 s (all K.O.): **BY 98.4 s** (137.9 with the cinematics), his wins 48 / 12;
**BK 121.0 s** (166.7), 26 / 34. V2 stood at BY 115.9 / BK 112.9 (accepted, decision V5). BY is 17.5 s shorter than V2's
(not attributed: the whole kit changed at once). **Reported to the user, not tuned** (gate policy).

**Awaken A/B** (`--cmd 39020`: he is P1 and never awakens, P2 by its kit's rule; 60 seeds a stream, seed0 100 / 300 / 500;
the never-awaken side's wins of 60, pass ≥ 20; all K.O.):

| BK | BB (mirror) |
|---|---|
| 21 / 25 / 28 | 41 / 47 / 38 |

Both pass on every stream. BK failed on every stream in V2 (8 / 11 / 14, V6–V7: 11–18): his base stance (K K at 45 a
hit, J J → K K for flash step) holds Kenpachi without the awakening now.

## 8. Revision 4: decision R3 (2026-10-11, after the playtest of v57)

The user (verbatim):

> - 進入架式後靠 step 快速移動一次
> - 沒有消耗資源的話就不能有遠距離攻擊
> - 覺醒後所有的 JJ 都太快了請回到標準速度
> - 架勢中的 JJ / KK / LL 都改成差異明顯的數段連擊
> - 架勢中的 JJ / KK 由銜接 KK / JJ 改成統一銜接 LL，風格延續
> - JJ 與 KK 接入 L 不再有特殊動作，只是普通的接入架式
> - 現在的資源回收量太高了，請下降至少 50%
> - 高資源換取高傷害的定位設計給 SP2 佔有，並讓其單發破綻大、必須接在 KK 後執行才能有效利用。

Answers (AskUserQuestion): the L L after J J / K K: 「兩者都花資源」 (J J → L L spends for more refill, K K → L L for
damage); SP2: 「花光全部，每單位加傷害」; the owl's full volley: 「併入梟頭的 SP2」; the cut: 「特殊資源＋閃步／靈壓都降」.

Mid-build (the user): 「SP2 接在 JJ 後面也可以」, then 「不是 JJ 不是 J2，是 J 連段的意思」, 「然後剛剛說的 JJ KK LL 都不表示只要二連擊，
只是簡化多段攻擊的描述方式」, 「架式 > JJ/KK > LL 中，最後一段 LL 會依據前面 J/K 有不同的動作模組」. Answers: SP2's cancel
「任一段打中都能接」; the strings 「各 3 段」.

### 8.1 What changed (every number [G])

| Rule | Before (rev. 3) | Now (R3) |
|---|---|---|
| The stance's strings L / J / K | two segments, one 萬物貫通 line each, 31 m | **three segments of several plain shots each, 4 m** (`*BR-S-NEAR*`), no 萬物貫通, each string its own rhythm: L 2 / 2 / 3 hits (8 each, an even beat), J 3 / 3 / 4 (5 each, every 3 f), K 2 / 2 / 3 (14 each, heavy, every 8–10 f; 98 a string); standard J speed (startup 8) |
| The follow-ups | K K → J J (spend: 15 → 45), J J → K K (spend: more refill) | **J string → L L and K string → L L** (from J3 / K3, L presses), each route its own clips (「最後一段 LL 會依據前面 J/K 有不同的動作模組」: new clips, §8.5), **three segments** (JL1–JL3, KL1–KL3; §8.5: 「每段花 1，共 3」), one 萬物貫通 line a segment (31 m), **one special spent a line; none: no follow-up** (the press does nothing; the string stops at the segment it cannot pay for). K → L L 45 a line; J → L L 15 a line + J's refill + 10 flash step / 15 Reiatsu |
| L's gain | +1 / +2 (a string +3) | **+0 / +0 / +1** (a string +1) |
| J's refill | 10 flash step / 15 Reiatsu a segment, 20 / 30 a string | **3 / 5 a segment, 9 / 15 a string** (the follow-up + 10 / 15 a line) |
| SP1's flash step by the count | 18 / 35 / 70 | **9 / 18 / 35** |
| The owl's wing regen | a wing a second | **a wing every 2 s** (`*BR-OWL-WING-EVERY*` 120) |
| SP2 | the charge shortened by the count (tiers), fixed damage | **spends every special**: HIRENKYAKU 40 + 40 a pip (160 at 3), NIJUSHI-KO 60 + 25 a wing (260 at 8), the owl's **full volley** (Trompete gone: 30 / 70 / 160 / 300 / 480 by the wings). On its own: the full charge (HIRENKYAKU 20 f, NIJUSHI-KO 40 f, the volley 30 f), recovery + 20 f, −30 on block. **Off any segment of the stance's J / K strings or their follow-ups that hit** (Shift+L during it): the charge-less copy, a combo (`:sp2c`). Nothing else cancels into SP2 (`BARRO-OK`: the generic SP cancel off a link that hit is refused for him) |
| L from a J / K link | J3 → L the backstep, the owl's K3 → L the volley, else the turn | **the plain entry everywhere** (base: the stance at f4; awakened: the turn) |
| The stance's Step | the base's 3.5 m / 12 f, once a stance; EN the plain Step | **5 m / 10 f**, once a stance, 10 flash step; **EN's first Step after the turn the same** (`BARRO-STEP`, the kit's `:step` hook) |
| The awakened J strings (KIN, the owl) | V8's J route (startup − 2, recovery − 2) | **the standard speed** (route `:JN`: V8's damage and block advantage kept) |

Kept: the forms, the burst owl and its buffs (x1.2, the armour at 2 wings), the 4-wing armour, SP1's tiers, the wings'
carry-over, the slow motion on the first stance hit.

Gone: Trompete (its reflect and seal), the backstep, the KIN L router, the SP2 routers and tiers, the stance's K K → J J /
J J → K K, the CPU's standalone stance SP2.

### 8.2 CPU

The base form closes in (the stance from inside 4 m, `:zone :in`); the EN forms' bands are short range (pressure 1.5–3.5 m).
At the end of a stance move's hits one roll (`BR-S-CPU-CALL`, the kit's `:stance`): a string's last segment (J3 / K3 /
JL3 / KL3, `:end`) that hit with 2 bars and `:sp2-at` specials (base 2, JILLIEL 4, the owl 3) → SP2 (`:sp2` 0.8 / 0.9 x the
difficulty); else the follow-up with a special (`:follow` 0.6 / 0.7). SP2 no longer appears in the distance bands.

### 8.3 Clips

The sim's stance moves name clips by segment (`BR-DEFSTANCE`'s plist); the awakened forms' openers reuse the old clips (the
third segments the spare `:lb-e-f3` / `:lb-oe-f3`); the base form's are its own (below); the follow-ups in every form have
their own (§8.5).

**The base form's art pass (2026-10-11).** The base stance's segments (fifteen since §8.5) play their own clips
`:br-sk-<segment>` (`barro-art.lisp`, "the base stance's strings"; `:br-sk-l1` … `:br-sk-kl3`), each at its move's frames (S + A + R, the
`:s` mark on S, speed 1; `:clip-s` = S in the BR-S instance). Frame data unchanged (sim untouched). Every hit frame puts
Diagramm's muzzle on his line (FK over the rig: ≥ 1.6 m ahead, ≤ 0.15 m aside, 0.8–1.6 m up, the barrel within 8° of level
and of straight; the hit poses were solved to az −2…−7°, el 0°, the muzzle ≤ 0.1 m aside at ~2.1 m), the recoil right
after (the barrel ≥ 4° higher within 2 f). The openers start from `:lb-kamae-pose`; each later segment from the pose its
predecessor holds at S + A (the link's start); every end blends to `:lb-stance`.

| String | Look |
|---|---|
| L 集 (L1 L2 L3) | shouldered, upright, two hands, an even deliberate beat (kick +2 f, back on the line +6 f): L1 squared up, L2 turned side-on (the rifleman's profile), L3 a step in and three, then Diagramm swung up before him, muzzle high (the pip loaded) |
| J 補 (J1 J2 J3) | one hand from the hip, the free arm out for balance, a small kick every shot (+1 f) back on the line at +3 f: J1 stepped in, J2 hopped to his left and low, J3 swaying (two shots right shoulder forward, two left), then Diagramm flipped up onto his shoulder |
| K 重 (K1 K2 K3) | two hands at the waist, wide and low; each shot rocks him back with the barrel thrown up 24–26°, he leans back in: K1 left foot forward, K2 the right, K3 three with the last blowing him back 0.36 m, Diagramm flung up 40° (the finisher) |
| J → L L (JL1 JL2 JL3, §8.5) | J's one-handed lightness: JL1 wound half round and whipped back at arm's length, skipped back by the kick; JL2 spun round on the spot, out of the spin low at arm's length (J2's solved hop pose); JL3 crouched, a hop back, fired from the air at arm's length, landed |
| K → L L (KL1 KL2 KL3, §8.5) | K's two-handed weight: KL1 the knee raised, stamped down into the shot, slid back by it; KL2 dropped to the right knee, braced, rocked back on it (the barrel 36° up), kept down; KL3 the long held aim from the knee, the big shot throws him up and back, Diagramm flung up 40° (K3's finisher pose), risen |

Host-tested (`tests/duel-rules-test.lisp`, after "Lille II's own clips": the clip names and speed, the durations and `:s`
marks, the muzzle on every hit frame, the recoil; 8091 checks then, 8194 with §8.5). pkgcheck 0, `./build.sh duel` 0
warnings. Stills: 82100+15 / 16 / 17 and 82100+40…51 (L2 L3 J2 J3 K2 K3 JL1 JL2 JL3 KL1 KL2 KL3, started on their own 3 m
out; + 20 the front view) with 82200+f. `:lb-snap` is unused again. (A subagent's batch, merged with §8.5: its two-segment
follow-ups became JL1 / JL3 and KL1 / KL2, JL2 and KL3 composed from its solved poses.)

### 8.4 Checks

- `tests/duel-rules-test.lisp`: 8037 checks, ALL PASS. The Lille II block: the thirteen stance moves a form (hits, reach,
  萬物貫通 only on the follow-ups, roles, the spend hook), every hit inside a move and every link combos on a hit (every
  J / K segment → the charge-less SP2 too), SP2's spend hook / −30 / recovery, the gains cut, the routes gone, the J speed,
  the J and K routes' follow-ups on different clips. The volley's clips hold their last pose through the + 20 f.
- duel-control / learn / input / touch / cine: pass. pkgcheck 0. `./build.sh duel` 0 warnings.
- Browser (the first build, before the three segments): EN's first Step 5 m for 10 flash step, the second the plain 2.5 m;
  K K → L with no pip: no follow-up; KIN J J → L the plain turn. It also found the generic SP cancel letting SP2 follow
  any link that hit; `BARRO-OK` refuses it now.

### 8.5 The follow-ups: three segments, each route its own clips (2026-10-11)

The user, after the rev. 4 build (verbatim, re-stated):

> - 然後剛剛說的 JJ KK LL 都不表示只要二連擊，只是簡化多段攻擊的描述方式
> - 架式 > JJ/KK > LL 中，最後一段 LL 會依據前面 J/K 有不同的動作模組

Asked (AskUserQuestion) how the follow-up's three segments spend: **「每段花 1，共 3」** (the recommended; not "1 to enter,
the rest free", not "two near segments and one long line").

| Rule | Before (§8.1) | Now |
|---|---|---|
| The follow-ups | JL1 JL2 / KL1 KL2, two lines | **JL1 JL2 JL3 / KL1 KL2 KL3**, three lines (`*BR-S-SEGS*`): JL 8 / 2 / 14, 14, 16 (the last a knockback); KL 10 / 2 / 16, 16, 20 (stagger, stagger, knockback); one special each, the string stops at the one it cannot pay for (the base's 3 pips: a full follow-up spends all) |
| SP2 off them | any segment that hit | the same, JL3 / KL3 included; the CPU's SP2 call on JL3 / KL3 (`:end`) |
| Clips | the openers' old clips | **18 new clips** (`barro-art.lisp`, at their moves' own frames, `:clip-s` = startup) |

The clips (each one line fired on S; the L style carried on: a line a beat; the root's side / back offsets are the clip's,
the sim does not move him):

| Route | Base (Diagramm) | JILLIEL EN (the front wings) | The owl EN (the claws) |
|---|---|---|---|
| J → L L 疾射 (light, on the move) | `:br-sk-jl1` the whip at arm's length, skipped back; `:br-sk-jl2` spun round, out of it low; `:br-sk-jl3` the hop back, the shot in the air (§8.3) | `:br-e-jf1` / `-jf2` a single wing thrust from a slide (right / left); `:br-e-jf3` both from a hop back | `:br-oe-jf1` / `-jf2` / `-jf3` the same on the claws (the volley's solved keys) |
| K → L L 重砲 (planted, heavy) | `:br-sk-kl1` the knee raised, stamped into the shot; `:br-sk-kl2` down on one knee, rocked back, kept down; `:br-sk-kl3` the big shot from the knee throws him back (§8.3) | `:br-e-kf1` both wings swept up from low; `:br-e-kf2` slammed down from high; `:br-e-kf3` NIJUSHI-KO's ring held, the recoil | `:br-oe-kf1` the launch from low; `-kf2` spread then thrown; `-kf3` raised overhead, the big throw |

The base's aim line locks (jade) through every follow-up segment's startup (`*BR-AIM-LOCKED*`). Art stills: debug
82140–82151 (the base's segments on their own) and 82320+m (the awakened stances' moves, §9), `DUEL_GAMEPLAY.md`.

Checks: `tests/duel-rules-test.lisp` 8134 checks, ALL PASS (8194 merged with the base form's art pass, §8.3) (the six follow-up segments a form: three a route, 萬物貫通,
the spend hook, the links JL1 → JL2 → JL3 / KL1 → KL2 → KL3 combo, every one → SP2 combos, `:end` only on JL3 / KL3, six
distinct clips none an opener's, played at speed 1); duel-control / learn / input / touch / cine pass; pkgcheck 0.

Rev. 4 before this change (10 seeds, `--pairs 21,22,23,24,25,27`): all 60 K.O.; BY 135.8, BK 131.6, BR 160.0, BI 132.3,
BS 156.0, BB 197.3 s.

### 8.6 Gates after §8.5 (native sim; the follow-ups' 3 segments; the art does not touch the sim)

10 seeds, all 60 K.O.: BY 132.2, BK 121.9, BR 180.1, BI 176.0, BS 162.1, BB 200.6 s. BY and BK under 135 → 20 seeds (the
verdict): **BY 129.5 s** (his wins 10 / 20), **BK 130.1 s** (5 / 20), all K.O., inside 125–210: pass. Rev. 3's BY 96.3 / BK
118.7 (§7.4) are back in the window.

Awaken A/B (`--cmd 39020`, 60 seeds a stream, seed0 100 / 300 / 500; the never-awaken side's wins, pass ≥ 20; all K.O.):
BK **30 / 38 / 36**, BB **54 / 50 / 48** (mirror medians 200.5–204.2 s). Both pass; the mirror's never-awaken side wins
more than at rev. 3 (41 / 47 / 38): his awakening loses the mirror. Reported, not tuned.

## 9. Revision 4b: decision R4 (2026-10-11, the awakening first)

The user (verbatim):

> 先從覺醒開始改
> 1. 爆氣後的 K 沒辦法連 SP2
> 2. 所有起手連段一律用近距離攻擊
> 3. 架式 L 的動作太快了

Answers (AskUserQuestion, each the recommended): 2. 「覺醒架勢 L/J/K 改近戰」 (the awakened stance's openers, JILLIEL EN
and the owl EN; the base stance's stay 4 m shots; the spending L L follow-ups stay 萬物貫通 lines); 3. 「出手和間隔都放慢」;
1. 「梟頭近戰 K 連段」 (the owl KIN's own K string; the stance's K string already cancels).

| Rule | Before | Now (R4, every number [G]) |
|---|---|---|
| The awakened stance's openers L / J / K (`BR-E-*`, `BR-OE-*`) | 4 m plain shots (`:ranged`, a line drawn) | **melee strikes**: each hit its own volume, its reach the striking wing tip's / claw's distance on that frame (`*BR-W-TIPS*`, FK-measured: JILLIEL L 1.6–1.8, J 1.65–1.7, K 1.8–2.2 m; the owl L 1.7–1.8, J 1.35–1.5, K 1.5–2.2 m; radius `*BR-W-NEAR-R*` 0.4), not `:ranged`, no line; a hit pushes 0.05 m (`*BR-W-KB*`; the shots' 0.3 pushed him out of reach within a string: 1.3 → 2.3 m after L1 + L2 in the browser) |
| The awakened stance's L (L1 L2 L3) | startup 8, every 8 f (L3 every 6) | **x 1.5** (`*BR-W-L-SLOW*`): startup 12, every 12 f (L3 9); the clips at 2 / 3 speed; recovery as before. The base's L as it was |
| The owl KIN's K string (`:br-o-k1` / `-k2` / `-k2s` / `-k3`) | no SP2 cancel (`BARRO-OK` refuses the generic one) | **→ the charge-less SP2 (the full volley `:br-recall`) on a hit**: `:sp2c` links, Shift+L latched by `BR-S-TICK` (each K's entry frame resets the latch, `BR-S-START`), fired from the end of its hits; the CPU's call at K3 (`:end`) |
| CPU (JILLIEL EN / the owl EN) | pressure 1.5–3.5 m, the openers inside 4 m | pressure 1.2–2.0 m / 1.0–1.8 m, the openers inside 2.0 / 1.9 m |

Merged with it: the awakened stance's own clips (a subagent's batch on R3, 26 clips; its 8 two-segment follow-up clips
dropped for §8.5's three-segment ones): `:br-en-*` (JILLIEL EN: L the gathering casts, J the rapid flicks, K the heavy
throws) and `:br-oen-*` (the owl EN's claws), now the melee openers' clips, in Jilliel's / the owl's strike lists
(`lille-art.lisp` `*LB-JILLIEL-STRIKES*` / `*LB-OWL-STRIKES*`: the tip smear, the wings converging on the ring at his reach;
old Lille never plays these clips). `:br-e-swing` / `:br-oe-swing` (§1 "stance L 1 (revived)") are spare again. Three §8.5
follow-up clips moved so a tip is on his line on the shot frame (JILLIEL / the owl JF3 the hop back after the shot, JILLIEL
KF3 both wings at him before the recoil).

Checks: `tests/duel-rules-test.lisp` 8399 checks, ALL PASS (the openers melee: no `:ranged`, no line, each hit's edge =
`*BR-W-TIPS*` = the drawn tip ± 0.15 m, the push; L x 1.5 in the awakened forms only; the owl K's `:sp2c`, latch reset and
combo into the volley; JILLIEL KIN's own K still without one). duel-control / learn / input / touch / cine pass, pkgcheck 0,
`./build.sh duel` 0 warnings. Browser (`run.mjs --fixed-dt`): the owl KIN K1 hit → Shift+L → the volley at 8 wings (裁き・
極, 2 bars); JILLIEL EN at 1.35 m: J1 J2 hit, L1 L2 L3 all seven hits (12 / 9 f apart) in reach. Playtest v60.

### 9.1 Gates after R4 (native sim)

10 seeds, all 60 K.O.: BY 134.5, BK 150.6, BR 185.5, BI 182.1, BS 174.2, BB 217.9 s (the mirror may exceed 210); his wins
of 10: 5, 4, 2, 2, 5, (mirror). BY under 135 → 20 seeds (the verdict): **BY 125.8 s** (his wins 6 / 20), inside 125–210:
pass, at the window's floor.

Awaken A/B (`--cmd 39020`, 60 seeds, seed0 100 / 300 / 500; the never-awaken side's wins, pass ≥ 20; all K.O.): BK 30 / 38 /
36 (as §8.6: Kenpachi is the side that awakens there, Lille II never does), **BB 60 / 58 / 58** (§8.6: 54 / 50 / 48;
medians 194.8–210.8 s). Pass; in the mirror the awakened Lille II now loses nearly every match: the melee openers need him
inside ~2 m. Reported, not tuned (the user's playtest decides).

## 10. Decision R5 (2026-10-11): a whiffed L stops, the awakened stance's motion modules

The user (verbatim):

> - LILLE II 的架式 > L 只要沒打中就就進入硬直
> - 架式 > LL / JJ / KK 將動作模組差異化，例如像陀螺旋朝前方傾斜轉三圈揮舞光翼、爆炸特效的零距離砲擊，將光翼拉伸如同長鞭一般鞭擊、又如同大刀一般遲緩而沈重的揮砍

Answers (AskUserQuestion): the whiff 「就跟一般的 J / K 普攻一樣」; the four motions 「我只是提概念，請以此延伸自由組合」; the
reach 「跟著動作走」 (drawn reach = hit reach).

### 10.1 A whiffed L (built, 8c2f372)

| Rule | Before | Now |
|---|---|---|
| A stance L link (L1 → L2 → L3; J3 / K3 → L L) | started from the end of its hits whatever it touched | **only after the move touched him** (a hit or a block), as a J / K string's link; a whiff ends the string (pacing `l-whiff`) |
| A whiffed L segment's recovery | R + `*whiff-extra*` 6 (a `:sig` move) | **R + 8** (`*br-s-l-whiff*` = a J link's `*whiff-extra-j*`), every form |

Host tests 8409, ALL PASS.

### 10.2 The awakened stance's motion modules (built 2026-10-11, a subagent's batch r5-art, merged)

The user, after the first design (verbatim): 「長鞭可以連成大砍刀，砲擊也可以接在近距離毆打後面，請調查一般格鬥遊戲/動漫風格對戰遊戲
常會有強烈風格的戰鬥動作，並選擇適合的搭配來建置動作模組」. The survey: `docs/research/lille2-motion-styles/notes.md` (the snake
sword whip ↔ blade, rush → blast, the spinning tornado, restraint → finisher, the heavy overhead, the simultaneous flurry).
The choice ([G], frame data and hit counts unchanged; each hit's reach the drawn tip, `*BR-W-TIPS*`):

| String | Archetype | The motion (JILLIEL EN's light wings; the owl EN the same on its claws / long arms / gold wings) |
|---|---|---|
| J (rapid) | the snake sword (Ivy, SoulCalibur) | J1 / J2 the wings stretched into whips, crossing figure-eight lashes (~2.6–3.0 m); **J3's last hit: the whips snap rigid into one giant cleaver** (both wings joined), a heavy downward chop (~2.4 m) — 「長鞭連成大砍刀」 |
| K (heavy) | the great sword, then rush → blast (DBFZ / Sparking! ZERO rush into a finisher) | K1 great-sword chops (a held overhead wind-up, a rising cut); K2 stepping in, a close beating (~1.2–1.4 m); **K3 two close blows, then the point-blank cannon blast with an explosion** (~1.0–1.3 m) — 「砲擊也可以接在近距離毆打後面」 |
| L (even beat) | the spinning top (Tatsumaki Senpukyaku) | tilted forward, the wings swung flat, three turns over the string (L1, L2 one each, L3 one and a half), a hit as a wing sweeps the front (~1.8 m) |

**As built** (clip names, frame data and hit counts unchanged):
- L 陀螺: the pelvis twist inside a forward root pitch (the axis leaning at him), the wings / claws swung out flat, a hit as one
  sweeps his line; L1 one turn, L2 one more (lower), L3 one and a half (rising); each segment starts from the last one's S + A
  twist, so the spin carries across links; the table wings spin with him (`*lb-no-conv*`: no convergence).
- J 長鞭 → 大砍刀: J1 crossing figure-eights from high outside (R L R), J2 rising from low (L R L), J3 R L R then the whips shorten,
  go rigid and join into one cleaver for the downward chop (its last hit).
- K 大刀 → 近身 → 零距離砲擊: K1 the held overhead wind-up, the whole-body chop, a rising cut; K2 stepping in, the folded wings
  clubbed down R then L; K3 a folded-wing hook, a club, then both tips thrust into him with the blast.
- The stretch (a look): `barro-art.lisp *br-w-stretch*` keys (frame right left) metres past the hand, by clip, loaded into
  `lille-art.lisp *lb-stretch*`; `%lb-stretch!` / `%lb-wings` (JILLIEL's front blades continued along root → hand) and the
  owl's `%lb-lashes` (a gold comet from the claw along the forearm). Zero for every other clip: old Lille's draw unchanged.
- The blast (a look): `%br-blast-look` for `:br-e-k3` / `:br-oe-k3`, 18 f from the last hit: a white flash, a jade (the owl:
  gold) star over an ink star, a white core, rising smoke, fixed on his line at the hit's reach. 0 B a frame (82398).
- The reach (`*BR-W-TIPS*`, the drawn tips incl. the stretch): JILLIEL L 1.85, J 2.8–2.85 (the cleaver 2.4), K1 2.0 / 1.8, K2
  1.35, K3 1.3 / 1.35 / 1.2; the owl L 1.7, J 2.75–2.8 (2.4), K1 1.75 / 1.55, K2 1.35, K3 1.35 / 1.35 / 1.15. The K links chase in
  their startup (the string's follow-up chase), so K1 at 1.95 m still reaches K2 / K3 (browser).
- CPU bands (JILLIEL EN / the owl EN): K inside 1.4 m, L inside 1.9 / 1.75, J inside 2.8 / 2.75; pressure 1.0–2.6 m.

Checks: host tests 8412, ALL PASS (the tip with the stretch; K3's blast hit both hands together at the reach ≤ 1.3 m);
duel-control / learn / input / touch / cine pass, pkgcheck 0, build 0 warnings. Browser (`run.mjs --fixed-dt`): JILLIEL EN K1 at
1.95 m → K3, all seven hits (the blast the last); J1 at 2.55 m → J3, all ten (the cleaver the last); L at 3 m whiffs L1 and
stops. Playtest v62.


### 10.3 Gates after R5 (native sim)

10 seeds, all 60 K.O.: BY 123.7, BK 130.4, BR 196.7, BI 156.4, BS 168.3, BB 192.6 s (his wins of 10: 2, 2, 4, 2, 3, mirror).
BY / BK under 135 → 20 seeds (the verdict): **BY 130.1 s** (8 / 20), **BK 129.0 s** (3 / 20), all K.O., inside 125–210:
pass. Awaken A/B (BB, 39020, 60 seeds, seed0 100 / 300 / 500; the never-awaken side's wins, pass ≥ 20): **56 / 53 / 53** (R4:
60 / 58 / 58), all K.O.: pass; the awakened mirror side still loses most (reported at R4, not tuned). (BK's A/B is Kenpachi's
awakening, unchanged by his art: not re-run.)

## 11. Decision R6 (2026-10-11): 3 hits a move, the one-wing cleaver, the orb blast

The user (verbatim):

> - 動作段數最多三段
> - 大砍刀的動作要更緩慢沉重、扭轉身體、砍刀後拉，每次只用一隻光翼揮砍，揮砍前光翼隨身體的距離伸長放大
> - 砲擊不要發射光束，直接在爆炸點炸開光球來表示

Reading [G]: 「段數」 = a move's hits (only J3 had 4); 「大砍刀」 = J3's cleaver and K1's great-sword chops. **The first line is superseded by R7 (§12): the user meant one hit a press.**

| Rule | Before | Now |
|---|---|---|
| J3 (every form) | 4 hits (0 3 6 9), R 14 | **3 hits** (0 3 6); the base's R 14 → 17 (its clip's length kept) |
| The awakened J3 (`*BR-W-SEGS*`) | the cleaver 3 f after the whips | **(0 3 15)**, R 14: two whips, then the cleaver 12 f later |
| The awakened K1 | chops 10 f apart | **14 f apart** (0 14), R 18 |
| The cleaver / great-sword motion | both wings joined | the body twisted, the blade pulled back, **one wing a chop** (the other back), the wing lengthening and growing with the pull before the swing; the owl one claw / long arm |
| K3's blast | a flash, a star and the tips thrust along his line | **no beam**: a ball of light bursting at the blast point (a white core, a jade / gold shell, fading) |

Host tests: 3 hits at most; the art in progress (a subagent's batch r6-art).

## 12. Decision R7 (2026-10-11): one hit a press

The user (verbatim): 「抱歉不該說最多三下，我希望段數跟操作時的點擊次數一致，這樣玩家才能輕鬆確認到底打到哪一段」. Answers
(AskUserQuestion): 「每段總傷害不變」, 「所有型態」.

| Rule | Before (R3–R6) | Now |
|---|---|---|
| A stance opener segment (L1–K3), every form | 2–4 hits | **one hit, at S** (A 2) |
| Damage a segment (before the form's multiplier) | L 8 x 2 / 2 / 3, J 5 x 3 / 3 / 3, K 14 x 2 / 2 / 3 | **L 16 / 16 / 24, J 15 / 15 / 15, K 28 / 28 / 42** (`*br-s-l-dmg*`, `*br-s-l3-dmg*`, `*br-s-j-dmg*`, `*br-s-k-dmg*`, `*br-s-k3-dmg*`) |
| Reactions | the last hit's | L1 / L2 / J1 / J2 flinch, L3 / J3 / K stagger |
| Frame data | | base L1 / L2 S 8 R 14, L3 S 8 R 18, J1 / J2 S 8 R 12, J3 S 8 R 14, K1 / K2 S 12 R 18, K3 S 12 R 22; awakened L x 1.5 (S 12), J3 S 14, K1 S 16 (`*BR-W-SEGS*`) |
| The awakened modules | several strikes a segment | one a press: L one top's turn each, J1 / J2 a whip lash each, J3 the one-wing cleaver, K1 the one-wing great-sword chop, K2 a close blow, K3 the light-ball blast |

Gains as before (a segment's). The follow-ups (one line each) unchanged. Clips (a subagent's batch r6-art, merged): the
base's nine one shot at S each (the solved muzzle poses kept, the recoil 1–3 f after); the awakened eighteen one module a
press: L1 / L2 / L3 one top's turn each (upright, lower, rising; the spin carried across the links), J1 / J2 one whip each
(R, L), J3 the one-wing cleaver (the whips drawn in, the twist, the right wing pulled back behind the head and grown 1.6–1.9 m
past the hand, held, the slow chop), K1 the same great blade held longer, K2 a folded-wing blow, K3 both tips thrust in and the
light ball (R6: a white flash ball, a jade / gold shell round a shrinking white core, smoke; no trail, no convergence: no
beam). `*BR-W-TIPS*`: JILLIEL L 1.85, J1 / J2 2.85, J3 2.65, K1 2.45, K2 1.35, K3 1.2; the owl L 1.7, J 2.8, J3 2.55, K1 2.35,
K2 1.35, K3 1.15 (the awakened K1 reaches 0.4 m less than J1: J is the long whip here, K the heavy blade). Host tests 8322,
ALL PASS; build 0 warnings; browser: K K K, J J J, L L L (JILLIEL EN) and J J J (base) three hits each. Playtest v63.

