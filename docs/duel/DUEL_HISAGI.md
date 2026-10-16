# Hisagi Shūhei (檜佐木修兵) — design (in progress)

The next SOUL DUEL fighter after Lille (the user, 2026-10-16). Status: design drafted (§6–§13, the lead's proposals),
waiting on the user's answers (§13) and an adversarial review; no code. Process: skill `duel-character` (intent
questions → canon research → design doc + adversarial review → batch 1 playable → playtest loop).
Canon research: `docs/research/hisagi/notes.md` (graded A–D).

## 1. The choice (the user, 2026-10-16)

- Asked which fighter comes next, the lead proposed Kyōraku / Yhwach / Byakuya. The user asked for plans for four others
  (「經歷最後的月牙天衝修行後的一護、破面篇與崩玉逐漸融合的藍染、能虛化與歸刃的東仙要、學會卍解的檜佐木」) and for Mayuri
  (「涅繭利呢？」); the lead's sketches are in DEVLOG §230. Ranked by build risk, Hisagi came first (lowest: reuses the
  chain idea, no HUD / lock-on changes), paired with Tōsen next (canon: his captain, whom he killed).
- The user: 「先從檜佐木開始設計」.
- Forms: base = Shikai Kazeshini (風死, two sickles joined by a long chain), awakening = Bankai 風死絞縄 (canon from the
  light novel *Can't Fear Your Own World*; the user's acceptance of a novel-only source is implied by the request).
- Corrections from the research (`docs/research/hisagi/notes.md`): the Bankai reads **Fushi no Kōjō** (ふしのこうじょう;
  風死 read "fushi", a likely pun on 不死), used on Hikone Ubuginu in CFYOW III ch. 24 (not on Tokinada); Tōsen dies in
  ch. 386–387. The Bankai is in no anime episode found and in no fighting game (RoS makes the Shikai his awakening).
- Roster: a new index (7) appended by load order; slot 5 stays reserved (AGENTS.md).

## 2. Intent decisions (AskUserQuestion, 2026-10-16)

| # | Question | The user's pick | Rejected |
|---|---|---|---|
| H1 | Caught inside 2 m? | **Shorten the chain and spin-cut at close range** (an all-rounder, a little weaker up close) | the chain pulls him / flings the opponent back out to mid range (a pure mid-range fighter); close range as his plain weakness |
| H2 | A "blade not in hand" state after a throw? | **Yes: no second throw until the sickle comes back** (auto or pulled back by a press; he is weaker while it is out: 「害怕自己的刀」, the retrieve timing is his skill) | the throw returns at once (a plain mid-range move) |
| H3 | The Bankai's direction | **Wait for the canon research**, then 2–3 proposals to pick from | a tether with K.O. suspended and the damage settled as a debt when it breaks (the lead's recommendation); a tether only (a range cap, normal damage) |
| H3b | The Bankai, after the research (§4) | **A, the undying war of attrition (不死的消耗戰)**: inside the orb every wound is healed and paid in Reiatsu instead | B the noose's debt (K.O. suspended, damage settled when the orb goes; not canon: canon heals for real); C the tether only (the orb, the pull-back, the noose's mutual stagger, a slow self-heal from Reiatsu; no K.O. change) |

## 4. The Bankai 風死絞縄 (the user, 2026-10-16: option A)

Canon (CFYOW III ch. 24, graded A via the wiki's summaries; notes §2):
- Release: both scythes thrown up, the chains whirl overhead into a black wind of Reiatsu; the scythes come back to his
  hands, his own chain wraps him.
- A jet-black orb of chains hangs above, chained to him and to the opponent; raising a blade tightens a noose round both
  necks; cut chains regrow (even with the orb hit by a Cero); backing off pulls the opponent back.
- Every wound on either fighter heals at once, each heal draining the pair's Reiatsu; neither can kill the other until
  both run dry; pain stays. The orb stops the Reishi around it from flowing (Shunsui: an extreme "Bakudō-type" Bankai).
- No timer: he drops it himself once both are nearly dry. It is his fear of dying and of killing made into a power.

The user's pick: **A** — inside the orb the damage either fighter takes does not lower Reishi; it is paid from that
fighter's own **Reiatsu** (the SP gauge, 0–300). A fighter whose Reiatsu is empty takes damage normally again and can be
K.O.'d. Leaving the chain's length pulls the opponent back. He can drop it any time; it ends when his own Reiatsu runs dry.

The lead's numbers, **confirmed** (the user, 2026-10-16: 「數字照你的提案」):
- The exchange: 1 Reiatsu per 2 damage (so a full 300 bar absorbs 600, under half of the 1300 Reishi).
- Reiatsu does not regenerate inside the orb (+3/s and the per-damage gains paused), or the exchange never ends.
- A Kikon or a Soul Break cannot take Konpaku from a fighter who still has Reiatsu (the canon "can't kill"); with 0 it can.
- Chain length 6 m (the pull-back from there); the noose: his link-3 / SP hits stagger both (the shared pain).
- Entry: the generic awaken gauge and the P press; one orb a match; the Bankai form's own strings TBD (the canon art
  draws single crescent blades and chains from the orb).
- Risks: the clock (two fighters who can't be hurt), an opponent who saves Reiatsu for the orb, the CPU / learner
  needing to read the exchange.

## 5. The Shikai's move set, first draft (the user, 2026-10-16: 「J K 照一般規則，1 秒自動收回」)

- **J / K follow the general string rules** (DUEL_DESIGN §4, DUEL_STRINGS): up to three links, one button switch, routes
  JJJ JJK JKK KKK KKJ KJJ; one move per (link, button), `J1 K1 J2 K2 J3 K3` plus the switched copies.
- **A thrown sickle comes back by itself after 1 s (60 f)** if K has not pulled it back first.
- The draft table (the lead's, shown to the user; the full design doc details and checks it):

| Button | Move | Segments | Reach | Content (canon) |
|---|---|---|---|---|
| J | short-chain spin cuts | J1–J3 | ~2.2 m | the chain held short, both sickles whirled round the body (H1) |
| K | the throw | K1 throw, K2 pull back | ~6 m | K1 throws one sickle (out of hand); K again pulls it back, hitting from behind (ch. 325); no second throw until it is back (H2) |
| L | 風車 the windmill | hold | around him | the chain whirled overhead like a fan, stopping projectiles (canon fan whirl; RoS's projectile-proof slide) |
| I | 首掛け KUBIKAKE | grab | mid-close | the chain round the neck, pull, slam (the one named technique, ch. 337 / 384) |
| SP1 | 破道の十一・綴雷電 | one | chain length | lightning sent down the chain (ch. 337) |
| SP2 | the whole-body bind | one | mid | the chain binds the whole body, then a slam (vs Ayon, ch. 336) |
| O | throw-and-pull | — | — | the sickle hooks the opponent, pulls him in, the cut |

## 6. Role and roster fit (the lead's proposal, 2026-10-16)

Every number from here to §12 is **the lead's proposal** unless a line says "decided" (§2, §4, §5). Code prefix `hs-`,
files `duel/lisp/hisagi.lisp` + `hisagi-art.lisp`, kit `:hisagi`, forms `:base` (Shikai) and `:bankai`.

**Identity (H1, H2).** An all-rounder whose best band is **2–6 m**: a short-chain spin (J, 1.6 m, 360° at J3) for close
range, the throw (K1, 6 m) and the pull for mid range, the windmill (L) against projectiles. His price is the **out-of-hand
window** (§7): after a throw he has no second throw, no windmill and lighter J for up to 68 f. RoS's grades (Range 4,
Power 3, Defense 2, notes §5.1) fit: long reach, middling damage, ×1.0 taken.

**Bands** (centre to centre): close < 2 m (his J reaches 1.6 + the victim's body ≈ 2.0), mid 2–4 m (K3 2.8, MAKI 3.2, SP2
4.5), far 4–6.5 m (NAGE, SP1, HIKI's line), out > 6.5 m (nothing but the O lane, 7 m, and walking in).

| Opponent | At 2 m | At 4 m | At 6 m + | His plan / the risk |
|---|---|---|---|---|
| Yamamoto (S 9 J1, K 2.4–2.6 m; L wave 12 m, Shiranui 20 m; Bankai East / West) | his J (S 8) beats Yamamoto's J1 (S 9); KARI-OTOSHI 2.8 > Yamamoto's K 2.6 | NAGE outranges every Yamamoto K; Taimatsu's cone (4 m) is the threat | the wave and Shiranui outrange him: the windmill (L) blocks both, then he walks in | hold 4–6 m. Risk: West's 360° ward eats the throws (a ranged window is blocked by a ward) |
| Kenpachi (walk 4.4, run 10, K 2.8–4.0 m, the stance absorbs, CHARGE armour) | the J spin trades with ARAGIRI (S 7 vs 8): he loses a little (H1: "a little weaker up close") | NAGE out-pokes Kenpachi's K1 (3.0); RYOTE / NOMIHOSE K (3.9–4.0) contest it | Kenpachi closes 6 m in 0.6 s of run: one throw per approach | the worst matchup on paper: Kenpachi gets inside. A throw into the stance is absorbed (and stored) |
| Rukia (mid-range zoner 5–8 m, the ring, frost) | his J (1.6 m) ≥ her J (1.44 m); she is light (stun tolerance 13) | even: her K 2.5–2.8 vs his 2.8–3.2 | her ring (8 m) and HAKUREN outrange NAGE: the windmill blocks the wave, not the ring (a ground hazard: blocked too, §8.3) | contest 5–6 m. Note: zero's optical ward lets `:ranged` hits through at ×1.0, so his far throw goes through it |
| Ichigo (rushdown, the stance, KESSA's parry and clones) | the stance's RANGETSU (2.4 m lunge) beats a J spin started late | NAGE beats the stance at 4 m; KUSARI-BIKI (7 m) pulls him in | GETSUGA / JŪJISHŌ waves: windmill | KESSA's parry catches only the blade part (≤ 2.0 m): a far throw can't be parried. Clones answer his presses at close range |
| Senjumaru (close tailor 1.0–1.9 m, stitches; Bankai zones) | her J (1.44 m, 28 × 1.6) sews; even | his band: NAGE / HIKI line | the soldier walks the line; the windmill doesn't stop a walker | KASA (SP2) **catches ranged hits**: a throw into KASA feeds her tendrils. 星's Reiatsu drain vs the orb: §9.3 |
| Lille (sniper 6–12 m, the stance at 1.7–2.9 m, 31 m lines) | his J beats the stance's entry | NAGE vs the stance's rifle K (2.6 m): his | Lille's lines are `:ranged` windows: the windmill must block them (§8.3) | walk in under the windmill. Canon intro: Lille shot him (ch. 635) |
| Hisagi (mirror) | even | even | throws cross: the first one out loses the windmill | one orb at a time (§9.3) |

**The 10-seed time-at-range probe** (batch 1, before any tuning; `duel-character`'s rule): seeds 1–10 × his 7 live
pairings (HY HK HR HI HS HB HH; HL is retired), NORMAL, cinematics left out of the clock. A `duel hisagi` line per side
after each gate row: the share of match time in < 2 / 2–4 / 4–6.5 / > 6.5 m, the share with the sickle out, throws,
throw hits, pulls (pressed / auto), orb seconds. **Target (the lead's):** ≥ 45 % of his time at 2–6.5 m in every pairing;
under 2 m ≤ 40 % (≤ 55 % against Kenpachi); sickle out ≤ 30 %. Missing it changes the AI ranges first, then asks the user
(the old Lille's "pure sniper" spent 83–93 % under 6 m: two rule rebuilds).

## 7. The out-of-hand sickle inside the string grammar (H2 + the decided 60 f auto-retrieve)

### 7.1 The state machine

| State | Entered by | Lasts | What it means |
|---|---|---|---|
| **IN** | the match start, a reset, the sickle arriving | — | both sickles in hand: every move available |
| **OUT** | a throw's release frame (S of NAGE or MAKI), whatever the throw's result | until a pull's S, or 60 f after the release (decided) | one sickle lies at its **anchor**: on a hit / block the victim's position at the hit (hooked in him or his guard); on a whiff the line's end (6 m ahead at the release yaw). The chain is drawn hand → anchor. No throw (H2), no windmill, no SP2; J at ×0.8; SP1 faster (§8.3) |
| **RETURNING** | a pull's S (HIKI-1, HIKI, HODOKI, SP1) or the auto-retrieve at OUT + 60 f | a pull: its active frames (4–5 f); the auto: 8 f | the sickle flies back along the chain. A pull's flight **is its hit window**; the auto-return **has none** |

- **The auto-retrieve does not hit** (the lead's pick): a whiffed throw must not become a free delayed hit 1 s later
  (`duel-character`: "delayed damage: when should it land?"). The K pull is the only returning hit, so its timing is his
  skill (H2's 「回收時機就是他的技術」).
- **The chain's length**: if a Step / Hoho / knockback takes his hand > 6.5 m from the anchor, the auto-retrieve fires at
  once.
- **K pressed during the 8 f auto-return**: refused with the cue, buffered 10 f as any press, so it fires as NAGE on
  arrival.
- The anchor is a sim point (written at the release frame, never moved by art); the chain and sickle are drawn from it.
  Knobs: `*hs-out-frames*` 60 (decided), `*hs-return-frames*` 8, `*hs-chain-max*` 6.5, `*hs-out-j-mult*` 0.8.

### 7.2 One rule for K: **throw if in hand, pull if out**

The K button's move at each link is picked from the sickle's state **at the link's frame 0** (the latch fires the link;
the state is read then, so a K latched during NAGE becomes the pull):

| K slot | Sickle IN | Sickle OUT |
|---|---|---|
| K1 (neutral K) | 投 **NAGE**, the throw (→ OUT) | 引 **HIKI-1**, the pull from neutral (→ IN) |
| K2 / K2s | 巻 **MAKI**, the wrap-throw: the chain flung round his body (→ OUT) | 引 **HIKI**, the pull: the sickle rips back through him from behind (→ IN) |
| K3 (ender) | 刈落 **KARI-OTOSHI**, both sickles whirled overhead and dropped | 解 **HODOKI**, the pull-through ender (→ IN) |

J never changes the sickle; J while OUT is the same J (one sickle) at ×0.8 damage.

| Route (start IN) | Links | Sickle | Reads as |
|---|---|---|---|
| JJJ | SEN, KAESHI-SEN, RIN | IN throughout | the short-chain spin (H1) |
| JJK | SEN, KAESHI-SEN, KARI-OTOSHI | IN | spin into the overhead drop |
| JKK | SEN, MAKI, HODOKI | IN → OUT → IN | spin, wrap him, unwind him (the hit from behind) |
| KKK | NAGE, HIKI, KARI-OTOSHI | IN → OUT → IN | the canon Findorr sequence: throw, pull from behind, finish (ch. 325) |
| KKJ | NAGE, HIKI, RIN | IN → OUT → IN | throw, pull, spin |
| KJJ | NAGE, KAESHI-SEN(s), RIN | IN → OUT (auto-return during J3) | throw, then one-handed cuts |

| Route (start OUT, after a whiffed throw) | Links | Sickle |
|---|---|---|
| KKK | HIKI-1, MAKI, HODOKI | OUT → IN → OUT → IN |
| KJJ | HIKI-1, J2s, RIN | → IN |
| JKK / JJK / JJJ | one-handed J1 (J2), then the K by state (HIKI as K2s, HODOKI as K3) | the J links at ×0.8 |

A string stopped after a throw (JK, K) leaves the sickle OUT: it returns by the 60 f rule.

### 7.3 The JKK problem (K2s after J1, nothing thrown)

The draft's K = "K1 throw, K2 pull back" has nothing to pull after a J1. Options:

| | K2s after J1 | K3 after it | For | Against |
|---|---|---|---|---|
| **A (recommended)** | MAKI: the chain flung round his body (canon: Ayon tied up ch. 336, Mask's leg ch. 559), the sickle OUT, anchored at him | HODOKI: the pull-through ender | one rule (K throws if in hand, pulls if out) covers every route and every start state; every K string carries the out-of-hand risk; JKK ends on the canon hit from behind | K3 has two moves by state (the grammar's "one move per (link, button)" becomes "per (link, button, sickle)"); a pick hook (§12.4) |
| B | a chain lash with the sickle kept in hand (3.2 m, no OUT) | KARI-OTOSHI as in JJK | no state at link 2; one K3 | the K button means "throw" in one route and "lash" in another; JKK has no out-of-hand price; the OUT start state still needs A's pick for K1 |

Rejected outright: refusing K after J1 (the general rules give all six routes, §5).

### 7.4 Every hidden movement and hidden aim

| # | What | Movement | Readable by |
|---|---|---|---|
| M1 | J1's lunge | `:slide` 0.3 m (Ichigo's J1 0.6, Rukia 0.32) | the step in the clip |
| M2 | The opener's close-in (generic, DUEL_STRINGS §15: the attacker slides to 0.7 m on a J1 / K1 hit) | **kept for J1; off for NAGE and HIKI-1** (at 6 m it would be a 5.3 m dash in 6 f, 53 m/s). Instead **every K that hits as an opener or a pull drags the victim to 1.6 m over 10 f** (KUSARI-BIKI's pull, `ichigo-pull-to`'s rule copied into his file) | the chain drawn taut, the victim's slide |
| M3 | HIKI / HODOKI's drag | the same 1.6 m drag, on hit only | as M2 |
| M4 | J3 / K3 / HODOKI ender push | J3: out of J1's reach (1.6 + 0.3 + body + 0.05 ≈ 2.35 m). K3 / HODOKI: **open question Q2** (the generic rule measures K1 = NAGE: 6.0 + 0.4 + 0.05 ≈ 6.45 m) | the push slide (generic) |
| M5 | The O ender / Kikon follow-up dash | generic; drawn as **a zip along the hooked chain** (look only) | the chain |
| M6 | Breaker dash | generic (12–45 f at 10 m/s, strike at 1.6 m) | the pink aura |
| M7 | Bankai leash | the opponent never farther than 6 m from him (§9.2) | the noose chain |
| A1 | NAGE's turn in startup | `:track` **30 °/s** (Flash is 60): 9° over 18 f = 0.95 m at 6 m, so a side Step (2.5 m) always clears the line | the arm's wind-up |
| A2 | HIKI-1 / HIKI / HODOKI / SP1-from-OUT | **no aim**: the line runs from the anchor to his hand at S (he aims it by where he stands; the anchor is drawn) | the chain on the ground |
| A3 | SP1 / Bankai K1 lines | `:track` 30 °/s | the wind-up |
| A4 | O lane (KARI / KŌSHU) | aims 120 °/s during the 6 f aura, then locked (ENJO's rule) | the aura |
| A5 | Bankai SP2 KŌJŌ | **no range check inside the leash** (the noose already links them): a 20 f tell, guardable from every side, Step / Hoho iframes dodge it (§9.4) | the raised blade |

No `:track 720` and no turn at release anywhere. The pull's "from behind" is presentation: the guard arc is read from
Hisagi's position as for every hit, so a front guard blocks a pull (no hidden unblockable).

## 8. The Shikai 風死 (form `:base`) as a segment table

### 8.1 Stats

| Stat | Value | Matched |
|---|---|---|
| Dealt / taken | **×1.15 / ×1.0** (the first pacing knob, `*hs-mult*`, `*hs-taken*`) | between Ichigo 1.0 / 0.8 and Lille 1.3 / 1.0; Senjumaru's 1.6 was the gate's |
| Walk / run | **3.8 / 9.0 m/s** | Rukia 3.8 / 9.0 |
| Stun tolerance | 16 | Ichigo (the middle) |
| Hurt cylinder | r 0.36, h 1.8 (181 cm, lean) | Ichigo r 0.38 / 1.80 m |
| Kikon worth | 2 (Soul Break 3) | every Shikai |

### 8.2 J / K segments (DUEL_STRINGS §2.1 budget; K2 / K3 written at their effective 80 %, as DUEL_DESIGN §5 lists them)

| Move | Kind | S / A / R | Dmg | Guard | Block | Reach (volume) | Reaction | Push / drag | Sickle | Role | Matched |
|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 旋 SEN | quick | 8 / 3 / 12 | 30 | 8 | −2 | 1.6 m, arc 160° | flinch | lunge 0.3; close-in (generic) | — | the opener, J beats I | Ichigo J1 7/3/12, 32; Yamamoto 9 |
| J2 返旋 KAESHI-SEN (+ J2s) | quick | 8 / 3 / 13 | 30 | 8 | −2 | 1.6 m, 160° (the reverse figure-eight) | flinch | — | — | link | Ichigo J2 |
| J3 輪 RIN | quick, ender | 9 / 3 / 18 | 38 | 12 | −4 | 1.6 m, **360°** (both sickles round him on the short chain: H1's spin) | stagger | ender push ≈ 2.35 m | — | the close finish; O ender | Ichigo J3 8/3/18, 40 (arc 200); Kenpachi K3's 360° |
| K1 投 NAGE | flash | 18 / 4 / 22 | 62 | 14 | −3 | **6.0 m** line (`:cap 0.3 6.0 1.1 0.3`, `:ranged` beyond 2.0, `:melee-range` 2.0), `:track` 30 | stagger | drags to 1.6 m on hit; no close-in | IN → OUT at S | the mid-range poke | KUSARI-BIKI's 7 m line (S 16); Yamamoto K1 18/4/20, 75 |
| K1′ 引 HIKI-1 (K while OUT) | flash | 16 / 4 / 20 | 56 | 14 | −3 | the chain line anchor → hand (≤ 6.5 m, r 0.35), `:ranged` beyond 2.0 | stagger | drags to 1.6 m on hit | OUT → IN at S | the retrieve as an attack | K1 budget S 16–20 (Kenpachi 16) |
| K2 / K2s 巻 MAKI (IN) | flash | 20 / 4 / 24, `:enter` 6 → S_eff 14 | 52 | 14 | −3 | 3.2 m line (`:cap 0.3 3.2 1.1 0.35`) | stagger | — | IN → OUT at S (anchor = him) | wrap, sets the HODOKI ender | Ichigo K2 20/4/24 enter 6, 60 |
| K2 / K2s 引 HIKI (OUT) | flash | 20 / 4 / 24, enter 6 → 14 | 56 | 14 | −3 | the chain line anchor → hand | stagger | drags to 1.6 m on hit | OUT → IN at S | the pull from behind (ch. 325) | Kenpachi K2 60 |
| K3 刈落 KARI-OTOSHI (IN) | flash, ender | 22 / 5 / 34, enter 8 → 14 | 80 | 18 | −20 | 2.8 m, arc 120° | crumple | ender push (Q2) | — | the heavy finish | Kenpachi K3 20/5/34, 80; Yamamoto 88 |
| K3 解 HODOKI (OUT) | flash, ender | 22 / 5 / 34, enter 8 → 14 | 78 | 18 | −20 | the chain line anchor → hand | crumple | ender push (Q2) | OUT → IN at S | the pull-through finish | as KARI-OTOSHI −2 (no guaranteed line) |

- **Routes on hit** (×1.15, before combo scaling past hit 3): JJJ 98 → 113; JJK 140 → 161; JKK 160 → 184; KKK 198 → 228;
  KKJ 156 → 179; KJJ 130 → 150 (one-handed J at ×0.8: 134). Kenpachi base: 112 / 150 / 175 / 210 / 172 / 147;
  Ichigo Shikai 104 / 148 / 176 / 212 / 168 / 140. His K routes run ~8 % over Kenpachi's, paid for by the out window.
- **Combo arithmetic** (host-tested, hitstop included): J1 (A 3, flinch 18) → MAKI S_eff 14: 17 ≤ 17, the roster's binding
  case. NAGE (A 4, stagger 26) → HIKI 14 ✓ / → J2s 8 ✓, the 10 f drag ends at f28, before J2s's hit at f30. RIN / both K3 →
  the O lane (S 20 < stagger 26 / crumple 40). S(K1) − S(J1) = 10 ≥ 7; HIKI-1 8 ≥ 7. Every K ≥ J + 0.5 m (NAGE 6.0, MAKI 3.2,
  KARI-OTOSHI 2.8 ≥ 2.1); the pulls' dynamic lines are exempt (as the chase markers are) and get a cast check instead of FK.
- **KŌSEI**: only within 2.0 m (the blade part); a far throw or pull pays none (the price of range, as every `:ranged` hit).

### 8.3 The other buttons

| Button (tap / hold) | Move | Frames | Dmg | Block | Volume | Rules | Matched |
|---|---|---|---|---|---|---|---|
| L hold | 風車 **KAZAGURUMA**, the windmill | up at f6; held 20–60 f; release R 14 | fan 12 every 15 f | — | r 2.2 m, 360° (the fan's hit) | **refused while OUT**. Up: every hazard and every `:ranged` window (waves, fireballs, rings, Lille's lines, KUSARI-BIKI's far part) is **blocked from every side**, no blockstun, ×0.5 of its guard value drained; a melee hit lands normally. Rooted. Free (no Reiatsu) | Kenpachi's stance hold ≤ 60 f; West's ward (360°, no blockstun) limited to ranged hits; RoS's projectile-proof slide |
| Shift+K, SP1 | 破道の十一 綴雷電 **TSUZURI RAIDEN** | IN: 20 / 3 / 24 (throws a line); OUT: **10** / 3 / 24 (down the chain already out) | 110 | −14 | IN: 6.5 m line, `:track` 30; OUT: anchor → hand | 1 bar. On hit a 40 f paralysis (`:bind`, as KUSARI-BIKI); ends with the sickle IN. An SP: cancels a J / K link on hit | KUSARI-BIKI S 16, 40 dmg, bind 40; Shiranui 90+ |
| Shift+L, SP2 | 縛 **SHIBARI**, the whole-body bind (vs Ayon, ch. 336) | 16 / 3 / 26; the slam at hit + 30 f | 60 + 90 (slam, knockdown) | −14 | 4.5 m line | 1 bar; **refused while OUT**; the combo ender (knockdown) | Kenpachi Buttagiru 180; Ichigo SŌGA 130 |
| I hold | Breaker, drawn as 首掛け **KUBIKAKE** | the universal Breaker (§4: trigger 1.6, reach 1.35, 150, Guard Break) | 150 | GB | 1.35 m | look only: the chain round the neck at the strike, the yank and the slam (ch. 337 / 384); allowed while OUT | every Breaker |
| O hold | Kikon module 刈 **KARI** | aura 6 (aim 120 °/s), **no dash**, strike 20 / 2 / 30 locked, `:ender-dash` 0 | 70 | −14 | lane `:cap 0.5 → 7.0 h 1.2 r 1.0` | the sickle hooks him along the lane; the follow-up's dash is drawn as the zip along the chain (`:follow-speed` 14); cooldown 90; Kikon 2. As the O ender it reaches from where he stands (pushes ≤ 6.45 m) | ENJO / HAKKA / UKIMON NO HATA (lanes 7.5–9 m, S 20) |
| Step / Hoho | generic | Step 2.5 m, J-cancel from f12; Hoho 30 FS | — | — | — | while OUT the anchor stays; > 6.5 m from it the sickle returns at once | — |
| P | awaken → the Bankai (§9) | generic | | | | | |

**Touch / one hand**: the same chips; the K chip's icon shows throw / pull by the sickle state; L is held (the windmill),
everything else tapped as for the roster.

## 9. The Bankai 風死絞縄 FUSHI NO KŌJŌ (form `:bankai`)

### 9.1 Entry and exit

- **Entry (decided)**: the generic awakening: the gauge full, P, from any state an awakening allows; it breaks the
  opponent's attack (`repel!`), heals **20 % of max Reishi** (260, DUEL_DESIGN "Awakening heal"), starts the awakening's
  WHITE-like regen (333 f), plays the cinematic (§11.5), then **the orb hangs**. One orb a match (decided).
- **The lead's addition: P is refused below one Reiatsu bar (100)** (an orb at 0 would end on its first frame; Q8).
- **Exit**: P again (from idle / walk / guard / run: a voluntary drop), or his Reiatsu reaching 0 by any path (decided).
  **Then he is back in the Shikai** (Q4; canon: he deactivates it), the awakening spent. Running dry also costs a
  **30 f exhausted reel** (canon: both collapse); a voluntary drop doesn't (so dropping early is a real choice).

### 9.2 The orb's rules (decided §4, restated exactly)

| # | Rule | Implementation note |
|---|---|---|
| O1 | Inside the orb **damage either fighter takes does not lower Reishi; it is paid from that fighter's own Reiatsu at 1 Reiatsu per 2 damage** | one point: `deal-damage` (every hit, chip, hazard, DRINK's half goes through it), via a generic hook (§12.4). A hit larger than the Reiatsu left: the Reiatsu pays what it can, **the rest lowers Reishi** (100 damage at 30 Reiatsu: 60 absorbed, 40 to Reishi) |
| O2 | **Reiatsu is frozen** inside: +3 /s and the per-damage gains paused | the lead extends it to **every Reiatsu gain**: KŌSEI's Reiatsu, BLUE's bar, WHITE's +15 /s, the awakening regen's Reiatsu, the Kikon / Soul Break refund, Kenpachi's reset bonus. One rule: **inside the orb Reiatsu only goes down** (the exchange and SP costs). Flash-step and the awakening gauge gain as usual (from the nominal damage) |
| O3 | A fighter with **0 Reiatsu takes damage normally** and can be K.O.'d | |
| O4 | **A Kikon or a Soul Break cannot take Konpaku from a fighter who still has Reiatsu** | a Soul Break can't arise (Reishi doesn't fall while Reiatsu remains; a split hit (O1) empties the Reiatsu first). A Kikon: **Q5** (the lead: it empties his Reiatsu instead, no Konpaku, no cinematic, no reset) |
| O5 | **Chain 6 m**: leaving it pulls the opponent back | his `:tick` hook: each step, if the distance > 6.0 m the opponent is moved back onto the 6 m circle round Hisagi (a hard clamp: walking away does nothing, a Step stops at 6 m, and if Hisagi walks away he tows him). A reset's 8 m placement is taken to 6 m over 10 f |
| O6 | **The noose**: his link-3 and SP hits stagger both | **Q6**; the lead: a shared 20 f freeze at the hit (both in the noose pose, both chains snap taut): the frame advantage unchanged, the clock + 0.33 s a hit |
| O7 | He can drop it any time; it ends when his Reiatsu runs dry | §9.1 |

### 9.3 Interactions to settle (the lead's answers)

| Case | Answer |
|---|---|
| Chip (fire 12 %, the pierce, NOMIHOSE's blade) | through `deal-damage`, so paid in Reiatsu (chip still never kills) |
| Soul Break at 0 Reishi with Reiatsu left | can't happen (O1 / O4); with 0 Reiatsu as usual |
| Hazards (waves, fire walls, pillars, clones, spikes, `:flat` traces) | the opponent's: exchanged like any damage. **Self-costs are not wounds**: Hellfire's burn, Ennetsu's 30, Kenpachi's arm self-damage, Rukia's CRACK 60 stay on Reishi as today |
| Burst Reverse cost | flash-step (70), untouched. BLUE's Reiatsu bar: frozen (O2) |
| Kikon rush outcomes | the rush, the guard / dodge / Burst escapes as §2; a strike that hits is 70 damage (exchanged); the follow-up's Kikon on a fighter with Reiatsu: Q5 |
| KŌSEI | flash-step part pays, Reiatsu part frozen |
| Time-up | unchanged (Konpaku, then Reishi %). Risk: an orb protects a Reishi lead to the bell; watch the time-outs at the gate before adding a Reiatsu tiebreak |
| Reishi when the orb ends | stays where it is: the healed wounds stay healed (canon heals for real, the reason option B was rejected) |
| The opponent's awakening inside the orb | allowed: its 20 % heal and Kenpachi's refill (Reishi) apply, its regen's Reiatsu is frozen; it doesn't end the orb |
| The mirror | one orb on the field: the second Hisagi's P is refused while an orb is up (the cue), allowed after |
| Senjumaru's 星 (drains Reiatsu 30 /s in its dome) | **the orb stops it** (canon: the orb stagnates the Reishi's flow; and O2's "only the exchange and SPs lower Reiatsu"); its flash-step drain stays |
| SPs inside the orb | allowed for both, paid from the same Reiatsu that protects them (his SP2 costs 2 bars = 400 damage of cover) |
| A reset inside the orb (a Kikon / Soul Break on a 0-Reiatsu fighter) | the orb survives; the leash takes the 8 m placement to 6 m |
| ENDLESS | the orb never carries into the next stage (`:endless-form :base`) |
| His own Kikon on a 0-Reiatsu opponent | a normal Kikon (3 Konpaku in the Bankai) |

**The clock (the lead's estimate).** The orb absorbs at most 600 (his 300 Reiatsu) + 2 × the opponent's Reiatsu (≤ 600).
The roster deals ~30 damage /s a side (≈ 4500 a match over 150 s), so an orb adds about **10–25 s** to a match in which it
is raised; inside the 125–210 s window but it will push the slow pairings (HR, HS, HH) up. The leash also shortens chases
(nobody can run 12 m away), which may give some back.

### 9.4 The Bankai's strings (the canon art: single black crescent blades in hand, the chains from the orb)

No out-of-hand state in the Bankai: the scythes stay in his hands (canon: "the scythes come back to his hands"); the K
chains are the orb's, dropping on the line he points at.

| Move | Kind | S / A / R | Dmg | Guard | Block | Reach | Reaction | Notes |
|---|---|---|---|---|---|---|---|---|
| J1 弦 GEN | quick | 8 / 3 / 12 | 34 | 8 | −2 | 1.6 m, 120° | flinch | the crescent's cut, lunge 0.3 |
| J2 返弦 KAESHI-GEN (+ J2s) | quick | 8 / 3 / 13 | 34 | 8 | −2 | 1.6 m, 120° | flinch | |
| J3 双弦 SŌGEN | quick, ender | 9 / 3 / 18 | 42 | 12 | −4 | 1.6 m, 200° | stagger | both crescents crossed; **noose** |
| K1 墜鎖 TSUISA | flash | 18 / 4 / 22 | 64 | 14 | −3 | 6.0 m line from the orb (`:ranged` beyond 2.0), `:track` 30 | stagger | a chain spears down along the line; no drag (the leash keeps him ≤ 6 m) |
| K2 / K2s 薙鎖 NAGISA | flash | 20 / 4 / 24, enter 6 → 14 | 56 | 14 | −3 | arc 3.6 m, 160° (`:ranged` beyond 2.0) | stagger | a chain sweeps the ground |
| K3 絞 SHIBORI | flash, ender | 22 / 5 / 34, enter 8 → 14 | 82 | 18 | −20 | 3.4 m line | crumple | the chains wrap and cinch, lift, drop; **noose** |
| L 風車 | sig | as the Shikai's | | | | | | the orb's chains whirl round him |
| SP1 綴雷電 | sp | 16 / 3 / 24 | 110 | 22 | −14 | 6.0 m line, `:track` 30 | bind 40 | lightning down a chain from the orb; 1 bar; **noose** |
| SP2 絞縄 KŌJŌ | sp | 20 / 3 / 30 | 140 | 30 | −16 | **anywhere inside the leash** (A5) | crumple | the blade raised (the 20 f tell), the noose cinches both necks; guardable from every side, Step / Hoho dodge it; 2 bars (awakened) = 400 damage of his own cover; **noose** |
| I | Breaker | the Shikai's, −1 f | 150 | | | 1.35 m | | |
| O | Kikon module 絞首 **KŌSHU** | as KARI (lane 7 m, S 20, no dash) | 70 | | −14 | lane | | chains rain from the orb (Brave Souls' special); Kikon **3** |
| P | drop the orb | from free states | | | | | | back to the Shikai (Q4) |

Dealt / taken **×1.0 / ×1.0** (the orb is the power); walk 3.4 / run 8.5 (the noose holds him); Kikon 3, Soul Break 4.
Routes on hit: JJJ 110, KKK 202, JKK 172.

## 10. CPU, ASSIST, learning, the opponents' reflexes (design level; `duel-character-cpu`: after the rules freeze)

| Mechanic | His CPU (`:ai`, EASY ≤ NORMAL ≤ HARD, one roll per event) | ASSIST | Learner (appended situations) | Opponents (`:opp-reflex`, read off his kit) | Counter in `duel hisagi` |
|---|---|---|---|---|---|
| NAGE at 3.5–6.2 m | `:moves` weight at 3.5–6.2 m; never a second throw (the kit refuses it anyway) | AUTO COMBO: K K K after a throw hit | — | a side Step on NAGE's startup tell from ≥ 4 m (the threat test must read a 6 m line: reuse the `:x-axis` point-to-line reader by flagging NAGE / HIKI / SP1 lines) | throws, throw hits |
| The pull timing (OUT) | `hisagi-ai-reflex`: when the opponent's feet are within 0.6 m of the anchor → hand line, roll the pull (p 0.3 / 0.6 / 0.9); else let it come back | AUTO COMBO presses K when the line crosses him | — | — | pulls (pressed / auto), pull hits |
| The out window (his weakness) | stays at 2.5–5 m while OUT (no walk-in) | — | "his sickle is out" (the human's punish window) | step in / Breaker while OUT, p by difficulty | OUT frames |
| The windmill | `:react (:projectile :sig)`, `:sig-hold` until the hazard passes | AUTO GUARD holds L against an incoming hazard / ranged window when IN | — | — | windmill holds, blocks |
| SP1 / SP2 | `:sp-ender`: SP1 off a NAGE hit or from OUT; SP2 off a K string hit (IN) | AUTO COMBO's SP route | — | — | |
| Awakening | `:awaken`: only with ≥ 150 Reiatsu (**log the distribution first**: the threshold must come from data) | — | — | — | orb seconds, end cause (dry / drop / Kikon) |
| Inside the orb | keeps fighting; never drops (v1); SPs only while the opponent's Reiatsu > his | — | "inside the orb, own Reiatsu > 0 / = 0" | spend no SP while the orb is up unless it completes a Kikon or ends the orb; go for the Kikon (Q5) | Reiatsu exchanged per side, noose freezes, leash pulls |

## 11. Look and motion

### 11.1 Model sheet (notes §3, grade A unless marked)

- 181 cm, 67 kg, lean; `:hisagi` body, the hurt cylinder §8.1. Upright stance, arms loose and wide, chain slack between
  them (D, Ep219 stills).
- TYBW face: messy black fringe down to the ears; **three parallel scars down over the right eye**; **69 on the left
  cheek**; a **blue horizontal stripe** across the left cheek and the bridge of the nose; dark grey eyes.
- A choker; matching bands on both upper arms; **sleeveless** shihakushō; the lieutenant's badge on the left arm; a white
  sash.
- Shikai Kazeshini: in each hand a spiked rod (~0.5 m, forearm-long) carrying **two scythe blades, one inverted (a
  pinwheel / S)**; one chain joins the rods, kept short (Kubo: he prefers it short): 1.2 m slack at rest, up to 6.5 m out.
  Reiatsu **green**.
- Bankai: single long **black crescent** blades (the CFYOW illustration and Brave Souls, D: possibly simplified), his own
  chain wound round the right arm, the shoulders and the **neck**, a thick twisted chain rising from the neck to the orb.

### 11.2 Motion style (`duel-motion-style`: to be confirmed with the user and researched before any clip)

| # | Archetype | Body in one line | Grade | Slots |
|---|---|---|---|---|
| 1 | Kusarigama (chain-sickle) | short figure-eight spins close to the body, the weighted throw from the hip, the retrieve hand over hand | A (canon "kusarigama-like", ch. 325) / C for the martial form (not yet researched) | J1–J3, NAGE, HIKI |
| 2 | Rope dart / meteor hammer (繩鏢) | the chain wrapped round the elbow, knee or neck to redirect a throw, the body turning inside the chain | D (to research) | MAKI, HODOKI, KAZAGURUMA |
| 3 | God of War's Blades of Chaos (the named bar) | chained blades whirled overhead, thrown and yanked, every strike a whole-body silhouette | C (well known, to research) | KARI-OTOSHI, SHIBARI, the Kikon |
| 4 | Canon manner | the overhead whirl before a throw; the low drop-and-pull (ch. 325); the blade across the face ("are you scared?", Ep219); the low sliding slash (Ep219, anime); the half-step back (ch. 384) | A | the stance, the intro, the win, the zanshin |

The bar: Blades of Chaos for every form; one archetype a string; no two strikes on one arc plane with one hand set.

### 11.3 Clip inventory

| Form | Clips |
|---|---|
| Shikai (≈ 24) | stance; J1 J2 J2s J3; NAGE; HIKI-1; MAKI, MAKI-s; HIKI, HIKI-s; KARI-OTOSHI; HODOKI; KAZAGURUMA in / loop / out; SP1 (IN throw, OUT down the chain); SP2 bind + slam; the Breaker strike (KUBIKAKE) + slam; the O strike; intro (the blade across the face, 「刈れ、風死」: RoS's toss-and-transform); win (the half-step back); the one-sickle J look is a flag on the same clips (the empty hand), not new clips |
| Bankai (≈ 18) | stance (wrapped, the blade raised for every K: the K clips are arm signals, the chains drawn from the orb); J1 J2 J2s J3; K1 K2 K2s K3; L; SP1; SP2 (the blade raised, the choke); O; the drop (P); the dry-out reel (30 f) |
| Shared | run set, hits, guard, down (the shared `:sh-*`) |

### 11.4 The orb's look

A jet-black ball of tangled chain loops (ink polylines, r ≈ 0.9 m) hanging 4.2 m above the pair's midpoint, swaying; two
chains sag from it to both necks (catenaries, drawn taut at a leash pull or a noose freeze); **inverted shadow**: a pale
disc under it (canon: its shadows "like beams of light"); a green spark runs up the payer's chain on every exchanged hit;
the world's grade a little greyer (stagnant Reishi). It must not hide the fight: check the behind camera at 2 / 6 m and
both aspect ratios.

### 11.5 Storyboards (text first; CINE-PLACE the actors; landscape letterbox 9 %, portrait %PORTRAIT-DOLLY)

**Shikai Kikon 「刈れ」 (Kikon 2 / Soul Break 3, ~180 f)**, from the Findorr fight (ch. 325):

| Beat | f | Camera | Action |
|---|---|---|---|
| 1 | 0–24 | side, low (1.0 m), 35 mm; gap 3 m | the victim reels; Hisagi whirls the chain overhead, the blade across his face: 「怖いか？」 |
| 2 | 24–54 | over his shoulder, 2.4 m back, 50 mm | the throw: the sickle nicks the victim and flies past |
| 3 | 54–84 | front, 0.4 m high, 24 mm | he drops low and pulls: the other blade returns and hits the back (white card + silhouette, 2 drawings) |
| 4 | 84–120 | side, medium | KUBIKAKE: the chain round the neck, the yank, the slam; dust ring, crack |
| 5 | 120–156 | top-down | flash-step afterimages: behind him, the reaping cut across (canon "appears behind and finishes him") |
| 6 | 156–180 | wide | the chain goes slack, the half-step back; 風死 / 刈れ stamp on a white card |

**The awakening 「卍解 風死絞縄」 (~168 f)**, from CFYOW III ch. 24:

| Beat | f | Camera | Action |
|---|---|---|---|
| 1 | 0–20 | close on his face | eyes shut, green Reiatsu rising |
| 2 | 20–50 | low, looking up, 20 mm | both scythes thrown up; the chains twist into a whirlpool overhead |
| 3 | 50–70 | wide | 卍解: a black wind of Reiatsu bursts out (a negative frame, the shockwave); the stamp |
| 4 | 70–100 | medium | silence, the world greys; the blades fall back into his hands as single black crescents; his chain winds round him |
| 5 | 100–130 | tilt up | the orb of chains forms above; the pale inverted shadow |
| 6 | 130–150 | cut to the opponent | a chain drops onto his neck and snaps tight |
| 7 | 150–168 | wide, both | linked neck to neck under the orb; 風死絞縄 stamp, ふしのこうじょう ruby |

**Bankai Kikon 絞首 KŌSHU (Kikon 3 / Soul Break 4, ~180 f)**, beats only: the orb sinks; chains rain on the victim (Brave
Souls' "countless chains from a sphere"); bound standing; he raises a blade; the noose tightens on **both** necks (both
choke: the shared pain); the victim drops; Hisagi stays up, shaking. To be tabled after Q4–Q6.

## 12. Gate plan, risks, plumbing

### 12.1 Gates (SOUL DUEL table in AGENTS.md)

1. Host: `duel-rules-test` (his forms in the per-form lists; the budget; the K pick table §7.2 for both states; the orb's
   exchange as a pure function `orb-exchange reiatsu dmg → reiatsu-left absorbed spill`; the leash clamp; every combo of
   §8.2 with hitstop; the J / K reach rules; FK ±0.15 m for fixed volumes, a cast check for the chain lines), the other
   host tests, pkgcheck, the build, a smoke run.
2. Playtest Artifact first, then: `simgate --summary` on HY HK HR HI HS HB HH (10 seeds first pass, 20 the verdict, 60 on
   an edge; window 125–210 s, mirror may exceed); the 22 existing pairings must stay byte-identical (every shared hook
   defaults off).
3. Awaken A/B (`--cmd 39020` / `39002` with him on each side, streams 100 / 300 / 500, ≥ 20 of 60).
4. `assistgate.py`, `aieval.py --char 7` (after his CPU), G2 `--cvc` unchanged (no YY / YK / KK change), `style-gates looks`
   seeds re-pinned (the roster grows: CPU-vs-CPU draws move).

### 12.2 Risks

| Risk | Why | Watch |
|---|---|---|
| The orb's clock | +10–25 s where raised (§9.3) | HR / HS / HH medians; time-outs while an orb is up |
| The 6 m K1 | the longest non-SP poke in the game | his win share vs Rukia / Lille (zoners) and Kenpachi (rushers); the time-at-range probe |
| Q2's 6.45 m push | every K-ended string resets to mid range (H1's rejected option) | a playtest |
| The exchange's reach into every Reiatsu path | seven gain paths (O2) + SP costs + 星 | host test each path; a debug probe printing both Reiatsu bars inside an orb |
| A Kikon that empties Reiatsu (Q5) | may make the orb too short against Kikon-heavy CPUs | orb seconds and end causes in `duel hisagi` |
| The CPU and the learner reading the exchange | `duel-character-cpu`: rules first | the counters; no search before the rules freeze |
| A form switch mid-move | the orb ending (dry) inside a move switches the form | switch only out of a move (`duel-move-modules` red flag): the end waits for his free state, the orb's rules stop at once |

### 12.3 Debug range claim (proposal; DUEL_GAMEPLAY untouched until the build)

**83000–83999** (free: 82000–82999 is Lille's, 90000+ Senjumaru's knobs): 83000+k his tests (human P1 Hisagi, P2's CPU
off: the throw / pull / out window / windmill / orb scenes), 83100–83299 knobs without a rebuild (k / 100), 83300+f /
83500+f / 83700+f stills of the Shikai Kikon / the Bankai Kikon / the awakening held at f, 83900+k the probe and the
counter dumps. His pairings: k 28–35 (`gate_cmd`: 2163–2170; HL, k 33, retired), his group 2143 (2136 + 7).

### 12.4 Roster index 7 plumbing

- `duel/MANIFEST`: `hisagi.lisp`, `hisagi-art.lisp` after `barro*` (the `:base` defkit's load order appends him to
  `*roster*` as index 7; never reorder).
- `tools/simgate.py` `ROSTER` += `'HISAGI'` (aieval / assistgate read it); `char-pairs` / `roster-pairs` give his 8.
- Shared hooks, each default off, the other pairings proved byte-identical: (1) the K pick by state (a kit hook `:pick`
  `(e cmd link) → move`, consulted at a link's frame 0; or two forms IN / OUT, rejected: a form switch inside a string);
  (2) a move flag `:no-close` (the opener's close-in off: NAGE, HIKI-1); (3) a kit `:push-reach` if Q2 picks B; (4) the
  exchange hook in `deal-damage`, the Konpaku guard in `settle-konpaku`, the Reiatsu freeze at every gain path (one
  predicate, like `siphon-of`); (5) a move flag `:ranged-ward` (the windmill); (6) a kit hook `:p` (P in an awakened form:
  the drop). The leash, the noose freeze, the drags and the anchor live in his own `:tick` / `:hit` hooks.
- Host tests' per-form lists; `tests/scripts/duel.py` (a `duel-hisagi.json`); the select screen and the HUD (the K chip's
  icon, the orb's chain over both Reiatsu bars); the learning tables (a new index's table); ENDLESS's roster;
  `duel/web/manual.html` and the tutorial (zh-TW); `docs/README.md`; AGENTS.md's roster line.

## 13. Open questions for the user (only those that change the design; recommended first)

| # | Question | Options | The lead's pick |
|---|---|---|---|
| Q1 | JKK: what is K2s after J1 (nothing thrown)? (§7.3) | **A** MAKI wraps him (the sickle goes out), HODOKI unwinds him: "K throws if in hand, pulls if out" everywhere / B a chain lash, nothing thrown | A |
| Q2 | How far does a K ender push? | A the general rule literally: out of NAGE's 6 m (≈ 6.45 m: every K string resets to mid range) / **B** out of NAGE's blade part (`:melee-range` 2.0 + the body + 0.05 ≈ 2.45 m; Kenpachi's K3 pushes 2.3–3.1 m) | B (A replays H1's rejected "fling him back to mid range"; K3 is +1–2 on hit, so a restarted 18 f throw is no true combo) |
| Q3 | A throw (or pull) that hits as an opener | **A** drags the victim to 1.6 m (the generic close-in, done by the chain) / B no drag: the sickle stays hooked, the links are pulls only, KJJ works only up close | A |
| Q4 | After the orb ends | **A** back to the Shikai (canon: he deactivates it; the K chains come from the orb) / B stays in the Bankai form without the orb (needs a second K set) | A |
| Q5 | A Kikon on a fighter who still has Reiatsu inside the orb | **A** it empties his Reiatsu (no Konpaku, no cinematic; on Hisagi it ends the orb) / B it costs one bar (100) / C nothing but its 70 hit | A (the opponent's answer to the orb; keeps the clock) |
| Q6 | The noose's "stagger both" | **A** a shared 20 f freeze at the hit (both in the noose pose; advantage unchanged) / B a real 16 f stagger on him after his move (his enders become −14 on hit) | A |
| Q7 | J reach | **A** 1.6 m (the general rules: J light-short-fast, inside the roster's 1.4–1.6 m band) / B the draft's 2.2 m (§5: the lead's draft, longer than every J) | A |
| Q8 | P with less than one Reiatsu bar | **A** refused (an orb at 0 ends on its first frame) / B allowed (the orb ends at once, the heal kept) | A |

## 14. Open

- The user's answers to §13; then the adversarial review of §6–§12 (`duel-character`'s build order 2).
- The motion-style confirmation and its research (§11.2: kusarigama, rope dart, Blades of Chaos), then the model sheet
  stills; the movement units in Step lengths are in §7.4 / §8.
