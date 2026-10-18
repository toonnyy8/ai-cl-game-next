# Hisagi Shūhei (檜佐木修兵) — design (in progress)

The next SOUL DUEL fighter after Lille (the user, 2026-10-16). Status (2026-10-17): the Shikai playable as roster index 7
(batch B2a, §19 "As built"); the Bankai (§17) is batch B2b. Process: skill `duel-character` (intent
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

## 6. Role and roster fit (the lead's proposal, 2026-10-16; revised after the review, §14)

Every number from here to §12 is **the lead's proposal** unless a line says "decided" (§2, §4, §5). Where an answer in
§13 is pending, the body assumes its recommended option (marked "Qn A"). Code prefix `hs-`, files `duel/lisp/hisagi.lisp`
+ `hisagi-art.lisp`, kit `:hisagi`, forms `:base` (Shikai) and `:bankai`. (There is no §3: the concept talk's numbering
is kept so the DEVLOG's references hold.)

**Identity (H1, H2).** An all-rounder whose best band is **2–6 m**: short one-chain cuts (J, 1.4 m, Q5 A) up close, the
throw (K1, 6 m) and the pull for mid range, the windmill (L) against projectiles. His price is the **out window** (§7):
after a throw that missed, or a string that left the sickle out, he has only one-handed J and a no-hit retrieve, no
throw, no windmill, no SP2. RoS's grades (Range 4, Power 3, Defense 2, notes §5.1) fit: long reach, middling damage.

**Bands** (centre to centre): close < 1.8 m (his J 1.4 + the victim's body), mid 1.8–4 m (KARI-OTOSHI 2.8, MAKI 3.2,
SP2 4.5), far 4–6.5 m (NAGE, SP1), out > 6.5 m (only the O lane, 7 m, and walking in).

| Opponent | At 2 m | At 4 m | At 6 m + | His plan / the risk |
|---|---|---|---|---|
| Yamamoto (J1 S 9, K 2.4–2.6 m; wave 12 m, Shiranui 20 m; Bankai East / West) | his J (S 8) beats Yamamoto's J1 (S 9); KARI-OTOSHI 2.8 > Yamamoto's K 2.6 | NAGE outranges every Yamamoto K; Taimatsu's cone (4 m) is the threat | the wave and Shiranui outrange him: the windmill blocks both (each drains its guard value), then he walks in | hold 4–6 m. West's 360° ward blocks the throws |
| Kenpachi (walk 4.4, run 10, K 2.8–4.0 m, the stance absorbs, CHARGE armour) | ARAGIRI (S 7, 1.4 m) beats his J (S 8): H1's "a little weaker up close" | NAGE out-pokes Kenpachi's K1 (3.0); RYOTE / NOMIHOSE K (3.9–4.0) contest it | Kenpachi closes 6 m in 0.6 s of run: one throw per approach | the worst matchup on paper. A throw into the stance is absorbed (and stored); Buttagiru's crack (`:ranged`) is blocked by the windmill |
| Rukia (mid-range zoner 5–8 m, the ring, frost) | even (her J 1.44 m, his 1.4) | even: her K 2.5–2.8 vs his 2.8–3.2 | her ring (8 m) and HAKUREN outrange NAGE; the windmill blocks both (a guardable pillar is blocked like any hazard); her freeze-touch bind is unguardable and goes through | contest 5–6 m. Zero's optical ward lets `:ranged` hits through at ×1.0, so his far throw goes through it |
| Ichigo (rushdown, the stance, KESSA's parry and clones) | RANGETSU (a 2.4 m lunge) beats a J started late | NAGE beats the stance at 4 m; KUSARI-BIKI (7 m) pulls him in (the windmill blocks its far part) | GETSUGA / JŪJISHŌ waves: windmill | KESSA's parry catches only the throw's blade part (≤ 2.0 m) |
| Senjumaru (close tailor 1.0–1.9 m, stitches; Bankai zones) | her J (1.44 m, 28 × 1.6) sews; even | his band | the soldier's thrust (a hazard) is blocked by the windmill; WARUI KUSE's spikes are unguardable and go through | KASA (SP2) **catches ranged hits**: a far throw into KASA feeds her tendrils. 星 vs the orb: §9.3 |
| Lille (sniper 6–12 m, the stance at 1.7–2.9 m, 31 m lines) | his J beats the stance's entry | NAGE vs the stance's rifle K (2.6 m) | the windmill blocks his lines as a guard would (Q3 A); walk in under it | canon intro: Lille shot him (ch. 635) |
| Hisagi (mirror) | even | even | throws cross: the one who misses is out of hand | one orb at a time (§9.3) |

**The 10-seed time-at-range probe** (batch 1, before any tuning; `duel-character`'s rule): seeds 1–10 × his 7 live
pairings (HY HK HR HI HS HB HH; HL is retired), NORMAL, cinematics out of the clock. A `duel hisagi` line per side after
each gate row: time share in < 1.8 / 1.8–4 / 4–6.5 / > 6.5 m, the share out of hand, and the counters of §10. **Target
(the lead's):** ≥ 45 % of his time at 1.8–6.5 m in every pairing; under 1.8 m ≤ 40 % (≤ 55 % against Kenpachi); out of
hand ≤ 30 %. A miss changes the AI ranges first, then goes to the user (the old Lille's "pure sniper" spent 83–93 % under
6 m: two rule rebuilds).

## 7. The out-of-hand sickle inside the string grammar (H2 + the decided 60 f auto-retrieve)

### 7.1 The state machine

| State | Entered by | Ends | What he can do |
|---|---|---|---|
| **IN** | the match start, any reset, the sickle arriving | a throw's S | everything: the IN string graph (§7.2) |
| **OUT** | the S frame of a throw (NAGE, MAKI), whatever its result | the S frame of a pull (HIKI, HODOKI, MODOSHI, SP1), or the auto-retrieve | the OUT graph: one-handed J, K = the no-hit retrieve; no throw (H2), no L, no SP2 (Q4 A) |
| **RETURNING** | the auto-retrieve | 8 f later | as OUT; a K pressed now is held (below) |

- **The 60 f timer (decided) counts only frames in which he is in no attack move** (J / K / L / SP / I / O); walking,
  guarding, a Step, a Hoho, hitstun and blockstun count. So the sickle's state changes only at the S frame of a throw or a
  pull, at the auto-retrieve outside his moves, at a reset or at a form change, never inside a move (the review's #5), and
  every route's state follows from its start state.
- **The auto-retrieve has no hit window** (8 f flight). Only a string's pull hits (Q4 A).
- **K during RETURNING**: his `:tick` keeps the press (it is not a refusal: `refused-cue` would consume it) and presses K
  again on the arrival frame, so it fires NAGE. J during RETURNING plays the one-handed J; L / SP2 are refused (the cue,
  the press eaten); SP1 throws its own line and the returning sickle simply arrives.
- **The chain's length**: out of his moves, a hand > 6.5 m from the anchor starts the auto-retrieve at once; inside a
  move the chain is drawn stretched.

**The anchor** (one fixed world point per fighter; never follows anyone, never moved by art):

| Case | The anchor is written | At |
|---|---|---|
| A throw (NAGE / MAKI) touches (hit, block, armour, absorb, a KASA catch) | on the first contact frame | the victim's centre on that frame |
| A throw is caught by a parry (KESSA within 2.0 m) | on the catch | the parrier's centre |
| A throw whiffs | on its last active frame | the line's own end along his facing at S: NAGE 6.0 m, MAKI 3.2 m |
| Every case | — | clamped into the arena circle (r 15 − 0.3 m) |

Drawn: the sickle "hooked" (the chain to the victim's body) only while the victim is within 0.5 m of the anchor, else
lying on the ground, the chain from his hand to it. Host-tested per case.

**Where the state lives** (the review's #23): per fighter, in his file's two-slot vectors indexed by `fighter-side` (a
global would break the mirror): the sickle state, the anchor x z, the out timer, the return timer, the held K, the orb
flag (on Hisagi), each side's orb cover (§9.2), the noose timer. Match start and PRACTICE's reset: IN, no orb. A Kikon /
Soul Break reset: IN; the orb kept. ENDLESS's stage start: IN, no orb. All of it goes into the periodic state-hash line.

Knobs: `*hs-out-frames*` 60 (decided), `*hs-return-frames*` 8, `*hs-chain-max*` 6.5.

### 7.2 Two static string graphs (the review's #6: no per-link pick hook)

With the timer frozen inside moves, the state at every link is fixed by the route, so the kit writes two graphs:

**IN graph** (the general rules' six routes; K throws if the sickle is in hand, pulls if a link of this string threw it):

| Route | Links (the kit's `:strings` rows) | Sickle | Reads as |
|---|---|---|---|
| JJJ | SEN → KAESHI-SEN → RIN | IN | the one-chain cuts |
| JJK | SEN → KAESHI-SEN → KARI-OTOSHI | IN | cuts into the overhead drop |
| JKK | SEN → MAKI → HODOKI | IN → OUT → IN | cut, wrap him, unwind him (the hit from behind; Q8 A) |
| KKK | NAGE → HIKI → KARI-OTOSHI | IN → OUT → IN | the canon Findorr sequence: throw, pull from behind, finish (ch. 325) |
| KKJ | NAGE → HIKI → RIN | IN → OUT → IN | throw, pull, cut |
| KJJ | NAGE → KAESHI-SEN-1H (as J2s) → RIN-1H | IN → OUT (stays out: the timer is frozen during the string) | throw, then one-handed cuts |

So K3 is a per-route move: KARI-OTOSHI after KAESHI-SEN or HIKI, HODOKI after MAKI (explicit `:strings` rows instead of
`:grid`'s one K3). The `:f` command move stays NAGE.

**OUT graph** (neutral while OUT or RETURNING; Q4 A): J1 J2 J3 one-handed (`SEN-1H`, `KAESHI-SEN-1H`, `RIN-1H`: copies
with ×0.8 damage written in and the empty-hand look flag; JJJ only, a K press during it is eaten); **K = 戻 MODOSHI, the
retrieve**: S 6 / A 0 / R 6, no hit window, the sickle IN at f6, not a string link. One kit `:command` hook consulted by
`kit-command-move` picks the OUT graph's `:q` / `:f` while the sickle is out (default off: the review's #6); MODOSHI is
never the `:f` command move of the IN graph, so the generic opener close-in never sees it.

### 7.3 The JKK problem (K2s after J1, nothing thrown): Q8

| | K2s after J1 | K3 after it | For | Against |
|---|---|---|---|---|
| **A (the body)** | MAKI: the chain flung round his body (canon: Ayon tied up ch. 336, Mask's leg ch. 559), the sickle OUT, anchored at him | HODOKI: the pull-through ender | every K string throws and pulls (one idea: "K = the chain"); JKK ends on the canon hit from behind | K3 differs by route |
| B | a chain lash, nothing thrown (3.2 m) | KARI-OTOSHI | no out state in JKK | the K button means "throw" in one route, "lash" in another; JKK carries no out-of-hand risk |

### 7.4 Every hidden movement and hidden aim

| # | What | Movement | Readable by |
|---|---|---|---|
| M1 | J1's lunge | `:slide` 0.3 m (Ichigo's J1 0.6, Rukia's 0.6) | the step in the clip |
| M2 | The opener close-in (generic, DUEL_STRINGS §15: the attacker to 0.7 m over 6 f on a J1 / K1 hit) | kept for J1. **Off for NAGE and TSUISA** (move flag `:no-close`): at 6 m it would be a 5.3 m dash in 6 f. Instead a NAGE / TSUISA hit **drags the victim to 1.6 m over 10 f** (`ichigo-pull-to`'s rule, copied into his file), keeping the close-in's purpose (the links reach) with the chain's logic | the chain taut, the victim's slide |
| M3 | HIKI's drag | the same 1.6 m drag, on hit only | as M2 |
| M4 | Ender push (J3 / K3 / HODOKI; Bankai J3 / K3) | J3: out of J1's reach (1.4 + 0.3 + body + 0.05 ≈ 2.15 m). K enders: out of the K1 throw's full reach, `:push-reach` 6.0 per kit → ≈ 6.45 m (Q6 B, the user); inside the orb the 6 m leash stops it at 6 m | the push slide |
| M5 | The O ender / Kikon follow-up dash | generic: the rusher dashes in; drawn as a zip along the hooked chain (look only) | the chain |
| M6 | Breaker dash | generic | the pink aura |
| M7 | The Bankai leash | **whoever's own motion would stretch the chain past 6 m stops at 6 m** (§9.2 O5): no tow | the noose chain |
| A1 | NAGE's turn in startup | `:track` **30 °/s** (Flash is 60): 9° over 18 f = 0.95 m at 6 m; a side Step (2.5 m) clears it | the wind-up |
| A2 | HIKI / HODOKI | no aim: the window is the segment anchor → hand at that frame (shared hook `:seg-fn`, §12.4) | the chain on the ground |
| A3 | SP1 / TSUISA lines | `:track` 30 °/s | the wind-up |
| A4 | The chained K links' generic turn (fighter.lisp: `*chase-track*` 360 °/s in a chained link's startup) | MAKI (3.2 m line), KARI-OTOSHI, NAGISA, SHIBORI (3.4 m line): generic, listed, unchanged | — |
| A5 | O lanes (KARI / KŌSHU) | 120 °/s during the 6 f aura, then locked (ENJO's rule) | the aura |
| A6 | Bankai SP2 KŌJŌ | no aim within 2.5–6 m (the noose links them); S 24 tell, the normal 200° guard arc (§9.4) | the raised blade |

No `:track 720` and no turn at release. The pulls' "from behind" is presentation: the guard arc is read from Hisagi's
position as for every hit, so a front guard blocks a pull.

## 8. The Shikai 風死 (form `:base`) as a segment table

### 8.1 Stats

| Stat | Value | Matched |
|---|---|---|
| Dealt / taken | **×1.15 / ×1.0** (the first pacing knob, `*hs-mult*`, `*hs-taken*`) | between Ichigo 1.0 / 0.8 and Lille 1.3 / 1.0 |
| Walk / run | **3.8 / 9.0 m/s** | Rukia 3.8 / 9.0 |
| Hurt cylinder | r 0.36, h 1.8 (181 cm, lean) | Ichigo r 0.38 / 1.80 m |
| Kikon worth | 2 (Soul Break 3) | every Shikai |

### 8.2 J / K segments (DUEL_STRINGS §2.1 budget; K2 / K3 at their effective 80 %, as DUEL_DESIGN §5 lists them)

| Move | Kind | S / A / R | Dmg | Guard | Block | Reach (volume) | Reaction | Push / drag | Sickle | Role | Matched |
|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 旋 SEN | quick | 8 / 3 / 12 | 30 | 8 | −2 | 1.4 m, arc 110° | flinch | lunge 0.3; close-in (generic) | — | the opener, J beats I | Ichigo J1 7/3/12, 32; Yamamoto 9 |
| J2 返旋 KAESHI-SEN (+ J2s) | quick | 8 / 3 / 13 | 30 | 8 | −2 | 1.4 m, 110° | flinch | — | — | link | Ichigo J2 |
| J3 輪 RIN | quick, ender | 9 / 3 / 18 | 38 | 12 | −4 | 1.4 m, 200° (drawn as the full spin) | stagger | ender push ≈ 2.15 m | — | the close finish; O ender | Ichigo J3 8/3/18, 40, arc 200 |
| SEN-1H / KAESHI-SEN-1H / RIN-1H | as above | as above | 24 / 24 / 30 | as above | as above | as above | as above | as above | OUT | KJJ's J, the OUT graph | ×0.8 written in |
| K1 投 NAGE | flash | 18 / 4 / 22 | 62 | 14 | −3 | **6.0 m** line (`:cap 0.3 6.0 1.1 0.3`, `:ranged` beyond 2.0, `:melee-range` 2.0), `:track` 30, `:no-close` | stagger | drags to 1.6 m on hit | IN → OUT at S | the mid-range poke | KUSARI-BIKI's 7 m line (S 16); Yamamoto K1 18/4/20, 75 |
| K2 引 HIKI (after NAGE) | flash | 20 / 4 / 24, `:enter` 6 → S_eff 14 | 56 | 14 | −3 | the segment anchor → hand, r 0.35 (`:seg-fn`), `:ranged` beyond 2.0 | stagger | drags to 1.6 m on hit | OUT → IN at S | the pull from behind (ch. 325) | Ichigo K2 20/4/24 enter 6, 60 |
| K2s 巻 MAKI (after J1) | flash | 20 / 4 / 24, enter 6 → 14 | 52 | 14 | −3 | 3.2 m line (`:cap 0.3 3.2 1.1 0.35`) | stagger | — | IN → OUT at S | wrap, sets HODOKI | Kenpachi K2 60 |
| K3 刈落 KARI-OTOSHI (after KAESHI-SEN / HIKI) | flash, ender | 22 / 5 / 34, enter 8 → 14 | 80 | 18 | −20 | 2.8 m, arc 120° | crumple | ender push (Q6) | — | the heavy finish | Kenpachi K3 20/5/34, 80; Yamamoto 88 |
| K3 解 HODOKI (after MAKI) | flash, ender | 22 / 5 / 34, enter 8 → 14 | 78 | 18 | −20 | the segment anchor → hand | crumple | ender push (Q6) | OUT → IN at S | the pull-through finish | KARI-OTOSHI −2 |
| K (OUT) 戻 MODOSHI | — | 6 / 0 / 6 | — | — | — | none | — | — | OUT → IN at f6 | the retrieve | — |

- **Routes on hit** (×1.15, before combo scaling past hit 3): JJJ 98 → 113; JJK 140 → 161; JKK 160 → 184; KKK 198 → 228;
  KKJ 156 → 179; KJJ (one-handed) 116 → 134. Kenpachi base: 112 / 150 / 175 / 210 / 172 / 147; Ichigo Shikai 104 / 148 /
  176 / 212 / 168 / 140. His K routes run ~8 % over Kenpachi's; the out window and the windmill's cooldown pay for it.
- **Combo arithmetic** (host-tested, hitstop included): J1 (A 3, flinch 18) → MAKI S_eff 14: 17 ≤ 17, the roster's
  binding case. NAGE (A 4, stagger 26) → HIKI 14 ✓ / → KAESHI-SEN-1H 8 ✓: the 10 f drag ends at f28, before its hit at f30.
  RIN / both K3 → the O lane (S 20 < stagger 26 / crumple 40). S(K1) − S(J1) = 10 ≥ 7. K ≥ J + 0.5 m (NAGE 6.0, MAKI 3.2,
  KARI-OTOSHI 2.8 ≥ 1.9); the segment windows are exempt (as the chase markers are) and get a cast check instead of FK.
- **KŌSEI**: only within 2.0 m (the blade part); a far throw or pull pays none.

### 8.3 The other buttons

| Button (tap / hold) | Move | Frames | Dmg | Block | Volume | Rules | Matched |
|---|---|---|---|---|---|---|---|
| L hold | 風車 **KAZAGURUMA**, the windmill | up at f6; held 20–60 f; release R 14; **cooldown 90 f from the press** | **one push hit** a hold: 20, no hitstun (`:kb` 1.5 m), KŌSEI once | — | r 2.0 m, 360° (the push) | refused while OUT. Up: hazards and `:ranged` windows are **guarded from every side** (shared flag `:ranged-ward`): blocked with their full guard value drained and the usual chip, no blockstun; **unguardables go through**; a melee hit lands normally; **at 0 guard gauge: GUARD CRUSH and the windmill drops**. Rooted. Free (no Reiatsu) | West's ward (360°, no blockstun) limited to ranged hits; Kenpachi's stance hold ≤ 60 f; L cooldowns exist (`:cooldown`) |
| Shift+K, SP1 | 破道の十一 綴雷電 **TSUZURI RAIDEN** | 20 / 3 / 24 in every state (Q4 A) | 110 | −14 | 6.5 m line, `:track` 30 | 1 bar; throws its own line (any state) and brings the sickle IN; on hit a 40 f paralysis (`:bind`, as KUSARI-BIKI); cancels a J / K link on hit | KUSARI-BIKI S 16, bind 40 |
| Shift+L, SP2 | 縛 **SHIBARI**, the whole-body bind (vs Ayon, ch. 336) | one move, two windows: the bind f16–19 (`:bind`, stun 46), the slam f46–49 (90, knockdown) on the same line; R 26 after the slam | 60 + 90 | −14 (the bind) | 4.5 m line | 1 bar; refused while OUT; if Hisagi is hit before f46 the move ends (no slam; the bind runs out); a BLUE needs the combo's 2nd hit as always; a reset or a cinematic ends it | Kenpachi Buttagiru 180; Ichigo SŌGA 130 |
| I hold | Breaker, drawn as 首掛け **KUBIKAKE** | the universal Breaker (§4) | 150 | GB | 1.35 m | look only: the chain round the neck at the strike, the yank, the slam (ch. 337 / 384); allowed while OUT | every Breaker (防 > J > I > 防) |
| O hold | Kikon module 刈 **KARI** | aura 6 (aim 120 °/s), **no dash**, strike 20 / 2 / 30 locked, `:ender-dash` 0 | 70 | −14 | lane `:cap 0.5 → 7.0 h 1.2 r 1.0` | the sickle hooks him along the lane; the follow-up's generic dash is drawn as a zip along the chain (`:follow-speed` 14); cooldown 90; Kikon 2; allowed while OUT | ENJO / HAKKA / UKIMON NO HATA (lanes 7.5–9 m, S 20) |
| Step / Hoho | generic | Step 2.5 m, J-cancel from f12; Hoho 30 FS | — | — | — | while OUT the anchor stays; > 6.5 m from it (out of a move) the sickle returns | — |
| P | awaken → the Bankai (§9) | generic | | | | | |

**Touch / one hand**: K is the pad's high-zone tap and SP1 chip 3, as for everyone (there is no K chip); the sickle's
state shows as a small HUD icon by his Reiatsu bars (in hand / out / returning). L is held. While the orb is up the
AWAKEN chip (held 300 ms) stays shown, labelled DROP.

## 9. The Bankai 風死絞縄 FUSHI NO KŌJŌ (form `:bankai`)

### 9.1 Entry and exit

- **Entry (decided)**: the generic awakening: the gauge full, P, from any state an awakening allows; it breaks the
  opponent's attack (`repel!`), heals **20 % of max Reishi** (260), starts the awakening's WHITE-like regen (333 f), plays
  the cinematic (§11.5), then **the orb hangs**. One orb a match (decided).
- **P is refused while the cover (§9.2) would be under one bar** (Q1 A): the cue, the press eaten. Its cost, said
  plainly: while either Reiatsu bar is under 100 he also loses the awakening as a combo breaker. A kit `:awaken-ok` hook
  (default off) carries the rule for the player and the CPU alike.
- **Exit**: P again (a 24 f drop move, the blade lowered; from idle / walk / guard / run, not from blockstun; no
  iframes), or his cover running out by any path (decided: "ends when his Reiatsu runs dry"). **Then he is back in the
  Shikai** (Q7 A; canon: he deactivates it), the awakening spent, the sickle IN. The form switch waits for his first free
  frame; the orb's rules stop at once.
- **Running dry (Q7 A): both reel 30 f** (canon: both collapse), so neither gets a free combo; a voluntary drop reels
  nobody.

### 9.2 The orb's rules (decided §4, restated; Q1 A's cover added)

| # | Rule | Implementation |
|---|---|---|
| O0 | **The cover** (Q1 A): at the orb's start each fighter's cover = the smaller of the two Reiatsu bars then (canon: "the pair's combined Reiatsu"). It is a counter beside the bar: every exchanged point and every SP cost inside the orb lowers both the bar and the cover; the cover never exceeds the bar | per side (§7.1); with GAUGES INFINITE (PRACTICE) the bar refills but the cover still runs down, so the orb ends there too |
| O1 | Inside the orb **damage either fighter takes does not lower Reishi; it is paid from his own Reiatsu at 1 Reiatsu per 2 damage** (decided), while his cover lasts | `orb-exchange` (pure): covered = min(d, floor(2 × cover)); Reiatsu and cover −= covered / 2 (halves are exact in f32); the spill d − covered lowers Reishi. Host-tested on odd d. Every wound from the other fighter: `deal-damage` (hits, chip, hazards, DRINK's half) **plus West's scorch and Senjumaru's 眼 mirror**, which lower Reishi directly today and are routed through the exchange |
| O2 | **Reiatsu is frozen** inside (decided: +3 /s and the per-damage gains paused) | the lead's reading of "frozen": **every** Reiatsu gain stops for both while the orb is up (Reiatsu only goes down: the exchange and SP costs). Every gain path goes through one `reiatsu-gain!` with the check: the gauge regen, `pay-gauges` (hit gains, KŌSEI, Lille's stance J gains), BLUE's bar, `white-regen!` (WHITE and the awakening regen), the Kikon / Soul Break refund in `settle-souls`, `reset-round`'s `:reset-reiatsu`, 星's `gauge-move` into Senjumaru's bar. Host test: each path, one by one, inside an orb. Flash-step and the awakening gauge gain as usual |
| O3 | A fighter whose **cover is 0 takes damage normally** and can be K.O.'d (decided, "Reiatsu empty" read as "cover empty" under Q1 A) | |
| O4 | **A Kikon or a Soul Break cannot take Konpaku from a covered fighter** (decided) | a Soul Break can't arise (Reishi doesn't fall while covered; a split hit empties the cover first). A Kikon (Q2 A): `*kikons*` is filtered at the start of `settle-souls`: a covered victim's entry is removed, so no burst-end, no refund, no cinematic, no reset; instead his cover and its Reiatsu go to 0 and the follow-up lands as a plain 70 with a knockdown (real damage: his cover is 0 by then). On Hisagi this ends the orb (and the 30 f reel is both fighters', §9.1) |
| O5 | **Chain 6 m**: leaving it pulls back (decided) | his `:tick`: whoever's own motion (walk, run, Step, a Hoho's destination, a knockback or push) would take the pair past 6.0 m **stops at 6.0 m**; Hisagi can't drag anyone (no tow); a rooted fighter is never moved. A reset inside the orb places them 6 m apart (not 8) |
| O6 | **The noose**: his link-3 and SP hits stagger both (decided) | the lead's reading: **20 f of extra global hitstop** on those hits (both frozen in the noose pose, both chains snap taut): the frame advantage unchanged, the clock +0.33 s a hit. Presses during it are read and applied after it (host test: a BLUE pressed in the freeze) |
| O7 | He can drop it any time; it ends when his cover runs out (decided) | §9.1 |

### 9.3 Interactions (the lead's answers)

| Case | Answer |
|---|---|
| Chip (fire 12 %, the pierce, NOMIHOSE's blade) | through `deal-damage`, so exchanged (chip still never kills) |
| Soul Break at 0 Reishi with cover left | can't happen (O1 / O4); uncovered, as usual |
| Hazards (waves, fire walls, pillars, clones, spikes, `:flat` traces) | the opponent's: exchanged. **Self-costs are not wounds**: Hellfire's burn, Ennetsu's 30, Kenpachi's arm self-damage, Rukia's CRACK 60 stay on Reishi as today |
| Burst Reverse cost | flash-step, untouched. BLUE's Reiatsu bar: frozen (O2) |
| Kikon rush | as §2 up to the follow-up's Kikon; a covered victim: O4 |
| KŌSEI | flash-step part pays, Reiatsu part frozen |
| "Red" (Reishi < 30 %) | frozen in practice: a covered fighter's Reishi doesn't fall, so a fighter who wasn't red at the orb's start can't become red and his Kikon follow-up stays guardable (rules unchanged; a clock risk, §12.2) |
| Time-up | unchanged (Konpaku, then Reishi %). Risk: an orb guards a Reishi lead to the bell; counted at the gate before any tiebreak change |
| Reishi when the orb ends | stays where it is: the healed wounds stay healed (canon heals for real, the reason option B of H3b was rejected) |
| The opponent's awakening inside the orb | allowed: its 20 % heal and Kenpachi's refill (Reishi) apply; its regen's Reiatsu is frozen; it doesn't end the orb |
| The mirror | one orb on the field: the second Hisagi's P is refused while an orb is up, allowed after |
| Senjumaru's 星 (drains Reiatsu 30 /s into her bar) | the orb stops it (O2: her gain is frozen, and the drain is a flow the orb stagnates); its flash-step drain stays. A change in `senjumaru.lisp` (§12.4) |
| SPs inside the orb | allowed for both, paid from the same Reiatsu that covers them |
| A reset inside the orb (a Kikon / Soul Break on an uncovered fighter) | the orb survives; placed 6 m apart |
| ENDLESS | the orb never carries into the next stage (`:endless-form :base`) |
| The generic CPU's Reishi reads (the Soul Break finish, burst-wanted, the Hoho spare) | read a covered fighter's Reishi as untouchable: one `orb-covered-p` predicate (§10) |

**The clock (the lead's estimate, revised after the review's #8).** The orb absorbs at most 2 × the cover on each side
(≤ 600 + 600 when both bars are full; under Q1 A usually less). At ~30 damage /s a side that is 10–20 s of hitting; on
top come the frozen red and the absorbed Kikons (the main Konpaku path), the noose freezes (+0.33 s each), the
post-orb Reiatsu drought (both near 0, 33 s a bar: fewer SPs) and the awakening's ~650 Reishi of heal landing while
Reishi can't fall. So **+15–40 s** where an orb is raised: the slow pairings (HR, HS, HH) may leave the window. Counted
per match (§10) and reported; the prepared order of fixes if it does is in Q2.

### 9.4 The Bankai's strings (canon: single black crescent blades in hand, the chains from the orb)

No out state in the Bankai (canon: the scythes come back to his hands); the K chains are the orb's.

| Move | Kind | S / A / R | Dmg | Guard | Block | Reach | Reaction | Notes |
|---|---|---|---|---|---|---|---|---|
| J1 弦 GEN | quick | 8 / 3 / 12 | 34 | 8 | −2 | 1.4 m, 110° | flinch | the crescent's cut, lunge 0.3 |
| J2 返弦 KAESHI-GEN (+ J2s) | quick | 8 / 3 / 13 | 34 | 8 | −2 | 1.4 m, 110° | flinch | |
| J3 双弦 SŌGEN | quick, ender | 9 / 3 / 18 | 42 | 12 | −4 | 1.4 m, 200° | stagger | both crescents crossed; **noose** |
| K1 墜鎖 TSUISA | flash | 18 / 4 / 22 | 64 | 14 | −3 | 6.0 m line from the orb (`:ranged` beyond 2.0), `:track` 30, `:no-close` | stagger | a chain spears down the line; **drags the victim to 1.6 m on hit** (the chain yanks him in), so the links reach |
| K2 / K2s 薙鎖 NAGISA | flash | 20 / 4 / 24, enter 6 → 14 | 56 | 14 | −3 | arc 3.6 m, 160° (`:ranged` beyond 2.0) | stagger | a chain sweeps the ground |
| K3 絞 SHIBORI | flash, ender | 22 / 5 / 34, enter 8 → 14 | 82 | 18 | −20 | 3.4 m line | crumple | the chains wrap and cinch, lift, drop; push by `:push-reach` 6.0 (Q6 B: ≈ 6.45 m, stopped at 6 m by the leash); **noose** |
| L 風車 | sig | as the Shikai's | | | | | | the orb's chains whirl round him |
| SP1 綴雷電 | sp | 16 / 3 / 24 | 110 | 22 | −14 | 6.0 m line, `:track` 30 | bind 40 | lightning down a chain from the orb; 1 bar; **noose** |
| SP2 絞縄 KŌJŌ | sp | **24** / 3 / 30 | 140 | 30 | −16 | **2.5–6 m from him, no aim** (the noose taut; refused nearer) | crumple | a deliberate range-free punisher: it catches any recovery ≥ 20 f inside 2.5–6 m; answered by a guard (the normal 200° arc), a Step / Hoho's iframes, or staying within 2.5 m; 2 bars (awakened) = 400 damage of his own cover; **noose** |
| I | Breaker | the universal Breaker (no per-kit frames) | 150 | | | 1.35 m | | |
| O | Kikon module 絞首 **KŌSHU** | as KARI (lane 7 m, S 20, no dash) | 70 | | −14 | lane | | chains rain from the orb (Brave Souls' special); Kikon **3** |
| P | drop the orb | 24 f | | | | | | back to the Shikai (Q7 A) |

Dealt / taken **×1.0 / ×1.0** (the orb is the power); walk 3.4 / run 8.5 (the noose holds him); Kikon 3, Soul Break 4.
Routes on hit: JJJ 110, KKK 202, JKK 172. Push for K3 / O ender: inside the 6 m leash.

## 10. CPU, ASSIST, learning, the opponents' reflexes (design level; `duel-character-cpu`: after the rules freeze)

Every chance is rolled **once per event** (named in the table), EASY ≤ NORMAL ≤ HARD; every row has a counter in the
`duel hisagi` gate line.

| Mechanic | His CPU | ASSIST | Learner (appended situations) | Opponents (`:opp-reflex`) | Counter |
|---|---|---|---|---|---|
| NAGE at 3.5–6.2 m | `:moves` weight at 3.5–6.2 m; the kit refuses a throw while OUT | AUTO COMBO: K K K after a throw's contact | — | a side Step on NAGE's startup, rolled once per NAGE start, through a **ranged-threat reader** (new, default off: `snap-flags :ranged` + the window's reach; not the `:x-axis` reader, whose flag would also make KESSA's AI skip parries that work within 2.0 m) | throws, throw contacts |
| The string's pull | K2 after a NAGE contact, rolled once at the contact (`:string-k`-style p) | the same rule | — | the pull's segment is visible to `snap-near-p` / `x-line-gap` through `:seg-fn` | pulls, pull hits |
| The out window | rolled once per OUT start (keyed by the anchor's write tick): MODOSHI at once (p) or stay at 2.5–5 m until the auto-return | AUTO COMBO presses MODOSHI out of a string | "his sickle is out" (the human's punish window) | step in / Breaker while he is OUT, rolled once per OUT start | OUT frames, MODOSHI, auto-returns |
| The windmill | `:react` on the ranged-threat reader (waves, fireballs, rings, lines, KUSARI-BIKI, cracks), rolled once per threat; `:sig-hold` until it passes | AUTO GUARD holds L against an incoming ranged threat when IN and off cooldown | none: a guard-like reaction the learner's guard class already covers | none: it only blocks what they fire | holds, blocks, crushes |
| SP1 / SP2 | `:sp-ender`: SP1 off a NAGE hit, SP2 off a K string hit (IN) | AUTO COMBO's SP route | — | — | |
| Awakening | `:awaken-ok` kit hook: cover ≥ 100 (Q1 A) and his Reiatsu ≥ X, **X from the logged distribution** of both bars at EVOLUTION (log first). The A/B's "always" mode presses only when `:awaken-ok` allows | — | — | — | orb starts, end cause (dry / drop / Kikon) |
| Inside the orb | keeps fighting; never drops (v1); SPs only while the opponent's cover > his | — | "inside the orb, own cover > 0 / = 0" | `orb-covered-p` makes the generic Soul Break finish, burst-wanted and Hoho-spare reads treat a covered fighter's Reishi as untouchable; spend no SP while covered unless it completes a Kikon or empties the cover | orb seconds, Kikons absorbed, time from the orb's end to the next Konpaku, Reiatsu exchanged per side |
| The leash | none: it only stops motion | none | none: the learner's distance classes see its effect | none | stops at 6 m |
| The noose | none: it lands on his own hits | none | none | none | noose freezes |
| Learner bookkeeping | — | — | `gauges-dealt` counts only the Reishi part inside the orb (an `absorbed` counter beside it); WHITE's reward reads the Reishi change only | — | |

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
| 1 | Kusarigama (chain-sickle) | short figure-eight cuts close to the body, the weighted throw from the hip, the retrieve hand over hand | A (canon "kusarigama-like", ch. 325) / C for the martial form (not yet researched) | J1–J3, NAGE, HIKI, MODOSHI |
| 2 | Rope dart / meteor hammer (繩鏢) | the chain wrapped round the elbow, knee or neck to redirect a throw, the body turning inside the chain | D (to research) | MAKI, HODOKI, KAZAGURUMA |
| 3 | God of War's Blades of Chaos (the named bar) | chained blades whirled overhead, thrown and yanked, every strike a whole-body silhouette | C (well known, to research) | KARI-OTOSHI, SHIBARI, the Kikon |
| 4 | Canon manner | the overhead whirl before a throw; the low drop-and-pull (ch. 325); the blade across the face ("are you scared?", Ep219); the low sliding slash (Ep219, anime); the half-step back (ch. 384) | A | the stance, the intro, the win, the zanshin |

The bar: Blades of Chaos for every form; one archetype a string; no two strikes on one arc plane with one hand set.

### 11.3 Clip inventory

| Form | Clips |
|---|---|
| Shikai (≈ 23) | stance; J1 J2 J2s J3 (the one-handed copies are the same clips with the empty-hand flag); NAGE; HIKI; MAKI; KARI-OTOSHI; HODOKI; MODOSHI; KAZAGURUMA in / loop / push / out; SP1; SP2 bind + slam; the Breaker strike (KUBIKAKE) + slam; the O strike; intro (the blade across the face, 「刈れ、風死」: RoS's toss-and-transform); win (the half-step back) |
| Bankai (≈ 18) | stance (wrapped; the blade raised for every K: the K clips are arm signals, the chains drawn from the orb); J1 J2 J2s J3; K1 K2 K2s K3; L; SP1; SP2 (the blade raised, the choke); O; the drop (24 f); the dry-out reel (30 f, both fighters: a shared reel clip on the opponent) |
| Shared | run set, hits, guard, down (the shared `:sh-*`) |

### 11.4 The orb's look

A jet-black ball of tangled chain loops (ink polylines, r ≈ 0.9 m) hanging 4.2 m above the pair's midpoint, swaying; two
chains sag from it to both necks (catenaries, drawn taut at the 6 m stop or a noose freeze); **inverted shadow**: a pale
disc under it (canon: its shadows "like beams of light"); a green spark runs up the payer's chain on every exchanged hit;
each side's cover drawn as a chain overlay on his Reiatsu bars; the world's grade a little greyer (stagnant Reishi). It
must not hide the fight: check the behind camera at 2 / 6 m and both aspect ratios.

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
choke: the shared pain); the victim drops; Hisagi stays up, shaking. Tabled after the answers to Q1, Q2 and Q7.

## 12. Gate plan, risks, plumbing

### 12.1 Gates (SOUL DUEL table in AGENTS.md)

1. Host: `duel-rules-test` (his forms in the per-form lists; the budget; both string graphs (§7.2); the anchor cases
   (§7.1); `orb-exchange` on odd damage; the cover; every Reiatsu gain path frozen one by one (O2); the `*kikons*` filter;
   the 6 m stop for each motion kind and a rooted victim; a BLUE inside a noose freeze; every combo of §8.2 with hitstop;
   the J / K reach rules; FK ±0.15 m for fixed volumes, a cast check for the segment windows, `:seg-fn` against
   `vol-hit-p` on a known case), the other host tests, pkgcheck, the build, a smoke run.
2. Playtest Artifact first, then: `simgate --summary` on HY HK HR HI HS HB HH (10 seeds first, 20 the verdict, 60 on an
   edge; window 125–210 s, a mirror may exceed); **the 22 existing pairings byte-identical** (every shared hook defaults
   off; the `senjumaru.lisp` change only acts inside an orb).
3. Awaken A/B (`--cmd 39020` / `39002` with him on each side, streams 100 / 300 / 500, ≥ 20 of 60).
4. `assistgate.py`, `aieval.py --char 7` (after his CPU), G2 `--cvc` unchanged (no YY / YK / KK change), `style-gates looks`
   seeds re-pinned (the roster grows: CPU-vs-CPU draws move).

### 12.2 Risks

| Risk | Why | Watch |
|---|---|---|
| The orb's clock | +15–40 s where raised (§9.3): frozen red, absorbed Kikons, the drought after | HR / HS / HH medians; orb seconds; time from the orb's end to the next Konpaku; time-outs while an orb is up |
| The awaken A/B | the orb + the ~650 heal: a never-awakening Hisagi may lose too often to his own awakening (Q1 A narrows it) | the A/B rows on 3 streams |
| The 6 m K1 | the longest non-SP poke in the game | his win share vs Rukia / Lille and Kenpachi; the time-at-range probe |
| The windmill | a projectile answer at most once per 90 f (the cooldown from the press) | holds and blocks per match; the zoners' pairings (HR, HB) |
| The exchange's reach into every Reiatsu path | eight gain paths + two direct burns (O1, O2) | the host tests; a debug probe printing both bars and covers inside an orb |
| The CPU and the learner reading the exchange | `duel-character-cpu`: rules first | the counters; no search before the rules freeze |

### 12.3 Debug range claim (proposal; DUEL_GAMEPLAY untouched until the build)

**83000–83999** (free: 82000–82999 is Lille's, 90000+ Senjumaru's knobs): 83000+k his tests (human P1 Hisagi, P2's CPU
off: the throw / pull / out window / windmill / orb scenes), 83100–83299 knobs without a rebuild (k / 100), 83300+f /
83500+f / 83700+f stills of the Shikai Kikon / the Bankai Kikon / the awakening held at f, 83900+k the probe and the
counter dumps. His pairings: k 28–35 (`gate_cmd`: 2163–2170; HL, k 33, retired), his group 2143 (2136 + 7).

### 12.4 Roster index 7 plumbing

- `duel/MANIFEST`: `hisagi.lisp`, `hisagi-art.lisp` after `barro*` (the `:base` defkit's load order appends him to
  `*roster*` as index 7; never reorder).
- `tools/simgate.py` `ROSTER` += `'HISAGI'` (aieval / assistgate read it); `char-pairs` / `roster-pairs` give his 8.
- **Shared hooks, each default off, the 22 pairings proved byte-identical:**
  1. a move flag `:no-close` (the opener close-in off: NAGE, TSUISA);
  2. a window `:seg-fn` (a kit function → the world segment's two ends and radius this frame), tested as a capsule by
     the hit collector and read by `x-line-gap` / `snap-near-p` (HIKI, HODOKI);
  3. a kit `:push-reach` (the K ender's push measured from it; Q6 B: 6.0, ≈ 6.45 m);
  4. a kit `:command` hook consulted by `kit-command-move` (the OUT graph's `:q` / `:f`);
  5. (**superseded by §17.4 5a–5j**, the bind) the orb: one `reiatsu-gain!` for every Reiatsu gain, the exchange in `deal-damage` and in the scorch / mirror burns,
     the `*kikons*` filter at the start of `settle-souls`, the absorbed counter beside `gauges-dealt`, `orb-covered-p` for
     the generic CPU's Reishi reads;
  6. a move flag `:ranged-ward` (the windmill: hazards and `:ranged` windows guarded from every side; unguardables
     through; the crush drops the move);
  7. (**superseded by §17.4 7a–7b**: `:p` kept for the throw / release, `:awaken-ok` dropped) a kit `:p` hook (P in an
     awakened form, from a run too: the drop) and a kit `:awaken-ok` hook (the entry rule, the
     CPU's and the A/B's too);
  8. the CPU's ranged-threat reader.

  **As built (batch B1, 2026-10-17; hooks 1–4, 6, 8).** Each defaults off; with no kit or move setting one,
  `simgate --seeds 10 --summary` (22 pairings) and `simgate --cvc` are byte-identical to the parent commit (`cmp`), and
  `duel-rules-test` pins both the defaults (every existing kit form and move: no flag, no `:seg-fn`, no `:push-reach`, no
  `:command`; each changed reader returns what the old code did, over every form, move and window) and each hook's one
  effect on dummy moves and kits (`:t-dummy`, a non-`:base` form, so no roster slot).

  | # | Name as built | Where | Default | Notes |
  |---|---|---|---|---|
  | 1 | move flag `:no-close` | kit.lisp `string-opener-p` (called by combat.lisp `apply-hit`'s close-in) | absent: the close-in as before | the old inline opener test moved into `string-opener-p`, which also asks the `:command` hook (an OUT-graph J1 is the opener while out) |
  | 2 | hit-window key `:seg-fn SYMBOL` → `hw-seg` | kit.lisp `parse-move` (the window's `:seg-fn`), `window-touches-p` (combat.lisp `collect-melee`; `perfect-now-p` too, the cylinder grown as for every window), `seg-gap` (ai.lisp `snap-seg-gap` → `snap-near-p`) | NIL: the window's volumes | the function takes the attacker entity and returns `(values ax ay az bx by bz r)`, a world capsule (3-D, so the hand's height counts), tested with the engine's `capsule-cyl-hit-p`; a `:seg-fn` window has no fixed volume (`hw-vols` NIL). The hit is collected as the move's own window, so contact, strings, the O ender, SP cancels, `:on-land` and the ender push follow unchanged. **Correction**: `x-line-gap` is the `:x-axis` path only (a move's `:cap` lines from his feet along his facing); the segment reader sits beside it in `snap-near-p` (feet within the capsule + hurt radius + the reader's margin), read from the attacker as he is now (the anchor is a fixed point; the hand moves). Give a `:seg-fn` move an explicit `:reach` for the generic CPU's range reads |
  | 3 | kit key `:push-reach M` → `kit-push-reach` | kit.lisp `ender-push-reach` (fighter.lisp `ender-push`) | NIL: K1's reach | K enders only (a J ender keeps J1's reach); push = M + K1's lunge + the victim's body + `*ender-push*` − the distance; Hisagi: 6.0 (NAGE's lunge 0) + the victim's hurt radius + 0.05 ≈ 6.4–6.5 m by the victim (6.45 at r 0.4) |
  | 4 | kit hook `:command` in `:hooks`, `(e cmd)` → a MOVE or NIL | kit.lisp `kit-command-move (kit command &optional e)` | absent: the `:commands` entry | consulted only when a fighter is passed: `try-command` (the start), `ender-push`, `string-opener-p`. The CPU's reach reads, costs (`kit-command-cost`), the `:ok` refusal check and the HUD still read the static `:commands` (the OUT graph's J has the IN J's reach; MODOSHI costs nothing). **Correction**: the hook returns a MOVE, not a name, because a move named only by the hook is not in the form's `kit-moves` (they are gathered from `:commands`, `:strings` and the L links); Hisagi's file looks his OUT moves up itself (`find-move`) |
  | 6 | move flag `:ranged-ward` | rules.lisp `ranged-ward-p` (pure), combat.lisp `apply-hit` | absent | while the defender is in such a move (any phase, its hold too) and can guard (`can-guard-p`: gauge > 0, not guardless), a ranged hit (`ranged-hit-p`: hazards, `:ranged` windows beyond their `:melee-range`) resolves as against a held guard with a ward: 360°, no blockstun, the hit's full guard value (no `*ward-mult*`: that is West's `:ward` passive only) and its usual chip; unguardables pass (`resolve-contact`); a drain to 0 is the generic GUARD CRUSH (`set-reaction :guard-break`), which ends the move. The ward's 6 f pushback slide applies (as West's) |
  | 8 | `ranged-threat-in (e b s d lo hi)` | ai.lisp (+ kit.lisp `ranged-window-lead`) | unused: no caller | T when a ranged hit reaches E within LO..HI frames as perceived: an opponent hazard with hits left (moving: delay + distance / speed; standing: its delay while it touches E), or his perceived move's next `:ranged` window (lead less the perception delay) with E in reach by `snap-near-p` (lines, segments, the reach) beyond its `:melee-range`. Covers Lille's lines and traces, waves, fireballs, walls, pillars |
  | 5 | (the bind support) | — | — | re-specified for the bind in §17.4 (5a–5j); **built in batch B1b**, §17.4 "As built" |
  | 7 | (`:p`) | — | — | re-specified in §17.4 (7a–7b), `:awaken-ok` dropped; **built in batch B1b**, §17.4 "As built" |
- His own hooks: the anchor, the timers, the held K, the drags, the 6 m stop, the noose freeze, the cover (`:tick`,
  `:hit`, `:struck`).
- A character-file change: `senjumaru.lisp`'s 星 `gauge-move` goes through `reiatsu-gain!` (O2).
- Host tests' per-form lists; `tests/scripts/duel.py` (a `duel-hisagi.json`); the select screen and the HUD (the sickle
  icon, the covers over both Reiatsu bars, the DROP chip); the learning tables (a new index's table); ENDLESS's roster;
  `duel/web/manual.html` and the tutorial (zh-TW); `docs/README.md`; AGENTS.md's roster line.

## 13. Questions decided by the user (asked 2026-10-16, answered 2026-10-17)

The user picked the lead's recommendation (A) for Q1–Q5, Q7 and Q8, and **B for Q6**: a K ender pushes ≈ 6.45 m, out of
the throw's full reach (every K string ends at mid range; inside the orb the 6 m leash stops it at 6 m). The body above
follows these picks. To check at the build: the O ender's and SP2's chase after a 6.45 m push, and the clock (a reset to
mid range after every K string).

| # | Question | Options | Picked |
|---|---|---|---|
| Q1 | **Should the orb protect both fighters equally?** Today he can open it right after you spent your Reiatsu: he gets up to 600 damage of protection and you get none | **A** both are protected by the same amount: the smaller of the two Reiatsu bars when the orb opens (canon: "the pair's Reiatsu"); he can't open it with less than one bar of that (and so loses the awakening as a combo breaker while either bar is under one bar) / B as decided: each is protected by his own bar (expect a third awaken A/B exception, after Yamamoto's and Ichigo's) / C as decided, but your Reiatsu keeps refilling slowly (+3 /s) inside | A |
| Q2 | **A finishing blow (Kikon) on someone the orb still protects** | **A** it takes no Konpaku but empties his protection at once (on Hisagi the orb ends); if matches still run long, the lead reports and proposes, in this order: the Kikon also takes 1 Konpaku, then half the protection (1 Reiatsu per 1 damage) / B it empties the protection **and** takes 1 Konpaku from the start / C it only does its normal 70 damage | A |
| Q3 | **What may the windmill (L) stop?** (It has a 90 f cooldown, one pushing hit, and drops at an empty guard gauge either way) | **A** every projectile and long-range hit, from every side, exactly as a guard would (Lille's lines included; unguardable things still go through) / B only fireballs and waves (Lille's lines, Rukia's ring and chain pulls still hit him) / C everything, Lille's unblockable-by-parry lines treated better than a guard does | A |
| Q4 | **After a missed throw**, is the sickle's absence a real weakness? | **A** yes: until it's back he has only one-handed J and a retrieve that doesn't hit (no windmill, no SP2, no new throw); his pull only hits inside a string after a throw that touched / B the pull still hits from wherever the sickle lies (a trap), but slower (S 20), without the drag, and not as a string start | A |
| Q5 | **Close range (H1: "a little weaker up close")** | **A** his J like the roster's: 1.4 m, a 110° swing, J3 a 200° spin / B the draft's 1.6 m with 160° swings and a 360° J3 (longer and wider than every base-form J: up close he would not be weaker) | A |
| Q6 | **How far does a K finisher (K3) push?** | **A** just out of his throw's blade part (≈ 2.45 m, like Kenpachi's K3 at 2.3–3.1 m) / B literally out of the throw's 6 m reach (≈ 6.45 m: every K string ends with you back at mid range, close to H1's rejected "fling him back out"; in the Bankai the 6 m chain would cut it short anyway) | **B** |
| Q7 | **When the orb ends** | **A** he is back in the Shikai; if it ran dry, both fighters reel 30 f (canon: both collapse); dropping it by hand reels nobody / B back in the Shikai, nobody reels / C he stays in the Bankai form without the orb (needs a second K set: the K chains come from the orb) | A |
| Q8 | **J then K then K** (nothing has been thrown yet) | **A** the second K wraps the chain round you (the sickle goes out), the third unwinds it and hits from behind / B the second K is a chain lash with the sickle kept in hand, the third the overhead drop | A |

**For the record (no choice needed unless the user objects):** O2's "frozen" covers every Reiatsu gain (BLUE's bar,
WHITE, the refunds, Kenpachi's reset bonus, KŌSEI), not only the decided "+3 /s and the per-damage gains"; the noose's
"stagger both" is 20 f of shared hitstop; the throw's hit drags the victim to 1.6 m (the generic close-in would dash him
5.3 m in 6 f); §5's I "KUBIKAKE grab" is the universal Breaker with KUBIKAKE's look (防 > J > I > 防 needs every I alike),
and §5's O "pulls him in" is the generic follow-up dash drawn as a zip along the chain.

## 14. Adversarial review (2026-10-16)

The review (scratchpad `hisagi-review.md`, checked against the code): 2 blockers, 12 majors, 15 minors.

| # | Sev. | Finding | Resolution |
|---|---|---|---|
| 1 | Blocker | the windmill locks (fan every 15 f > flinch gap), is free, stops unguardables | fixed §8.3: one push hit with no hitstun, cooldown 90 f, unguardables through, 0 gauge = crush + drop, full guard values; the matchup rows made consistent (§6); what it may stop → Q3 |
| 2 | Blocker | no mechanism for the anchor → hand window; as a hazard it breaks strings | fixed: shared hook 2 `:seg-fn` (a move window, so contact / O / SP cancels / drags work), read by the CPU's line readers (§7.4 A2, §8.2, §12.4) |
| 3 | Major | out of hand buffs K and SP1 (HIKI-1 faster and longer, SP1 S 10) | Q4 (A in the body: the neutral pull removed, MODOSHI retrieves without a hit, SP1 S 20 in every state) |
| 4 | Major | the anchor undefined / contradictory | fixed §7.1: one fixed point at first contact (parry, whiff, arena clamp cases), drawn hooked only within 0.5 m |
| 5 | Major | the 60 f timer races moves; "refused but buffered" impossible | fixed §7.1: the timer counts only outside attack moves; K during the return held by his `:tick`; J / L / SP during the return defined |
| 6 | Major | a `:pick` hook touches ~50 shared readers | fixed §7.2: two static graphs + one `:command` hook at neutral; the `:pick` hook dropped |
| 7 | Major | a Konpaku guard in `settle-konpaku` heals to full and resets | fixed §9.2 O4: `*kikons*` filtered at the start of `settle-souls`; Q2 decides the effect |
| 8 | Major | the clock estimate too low (frozen red, Kikons, drought, heal) | fixed §9.3 (+15–40 s) and the counters (§10); the fallback order in Q2 |
| 9 | Major | the orb an asymmetric shield; awaken A/B threat | Q1 (A in the body: equal cover, the cover counter O0) |
| 10 | Major | wounds bypassing `deal-damage`; gain paths outside `pay-gauges` | fixed §9.2 O1 / O2: scorch and mirror exchanged, one `reiatsu-gain!` with every path listed, `senjumaru.lisp` listed (§12.4); the freeze's extension recorded under §13 |
| 11 | Major | CPU rolls per step; `:react` blind to lines; `:awaken` keys; `:x-axis` side effect; Reishi reads; learner | fixed §10: rolls per named event, a ranged-threat reader, `:awaken-ok`, no `:x-axis` on NAGE, `orb-covered-p`, the absorbed counter |
| 12 | Major | TSUISA: dead links at 6 m; SHIBORI's push vs the leash | fixed §9.4: TSUISA `:no-close` + the 1.6 m drag; `:push-reach` per kit (Q6) |
| 13 | Major | J 1.6 m / 160° / 360° contradicts H1 | Q5 (A in the body: 1.4 m, 110°, J3 200°) |
| 14 | Major | the leash tows (hidden movement of the opponent) | fixed §9.2 O5: whoever's own motion would pass 6 m stops; no tow; rooted fighters never moved; resets at 6 m |
| 15 | Minor | KŌJŌ range-free with an omni-guard flag | fixed §9.4: S 24, only at 2.5–6 m, the normal guard arc, written as a deliberate punisher with its answers |
| 16 | Minor | SHIBARI's slam unspecified | fixed §8.3: one move, two windows, bind 46 f, ends if he is hit |
| 17 | Minor | no K chip; the DROP chip; P from a run | fixed §8.3 (the HUD icon; the AWAKEN chip labelled DROP) and §12.4 hook 7 (`:p`, run included) |
| 18 | Minor | the chained links' 360 °/s turn not listed | fixed §7.4 A4 |
| 19 | Minor | route-table errors (OUT JKK, KJJ's return) | fixed by the graphs (§7.2) and the frozen timer |
| 20 | Minor | Rukia's lunge 0.6; stun tolerance inert; no §3 | fixed §7.4 M1; stun tolerance removed (§6, §8.1); §3's absence noted at §6 |
| 21 | Minor | the dry reel his alone | Q7 (A in the body: both reel) |
| 22 | Minor | exchange rounding | fixed §9.2 O1: `orb-exchange` with floor on the covered amount, halves exact, host-tested |
| 23 | Minor | where the state lives; resets; hash; PRACTICE | fixed §7.1 (per side vectors, resets, the hash line) and O0 (the cover runs down under GAUGES INFINITE) |
| 24 | Minor | leash / noose / windmill coverage | fixed §10 (rows with "none: why") |
| 25 | Minor | Q8's hidden combo-breaker cost | folded into Q1 A's wording |
| 26 | Minor | Bankai Breaker −1 f has no knob | fixed: dropped (the universal Breaker) |
| 27 | Minor | the noose freeze as global hitstop | fixed §9.2 O6: global hitstop chosen, a BLUE pressed in it applied after (host test) |
| 28 | Minor | I / O differ from §5's draft | recorded under §13 "For the record" (I must be the universal Breaker; O's dash is generic) |
| 29 | Minor | P drop frames | fixed §9.1: a 24 f move, free states only, no iframes |

## 15. Build plan (the user, 2026-10-17: 「好，開始前記得善用 repo 中的 skill 與經開發經驗的文檔」)

Skills read for the plan: `duel-character` (build order, implementation rules), `duel-move-modules` (segment table,
host-test pins), `duel-character-cpu` (rules before CPU; prove each rule fires with a counter), `sim-balance-gates`
(identity proof, scope), `procedural-ink-style` (drawn reach = hit reach, functional art), `duel-character-rework`
(the regression list: hidden movement, stale reads, form switch inside a move, `:hold` f0 hooks), `game-dev-workflow`
(multi-agent rules); guides `CHARACTER_DESIGN.zh-TW.md`, `PLAYBOOK.zh-TW.md`.

| Batch | Scope | Acceptance |
|---|---|---|
| B1 shared hooks | the eight hooks of §12.4, each default off; nothing of Hisagi's yet | host tests ALL PASS; pkgcheck clean; `simgate --seeds 10 --summary` and `--cvc` byte-identical to the parent; the build |
| B2 Hisagi playable | `hisagi.lisp` (both forms, the sickle states, the orb, the plain CPU reflexes and counters), `hisagi-art.lisp` (a functional body, sickles and chain drawn to the rig, clips at the right reach, the orb's look), roster index 7 plumbing, debug range 83000–83999 claimed in DUEL_GAMEPLAY, host tests (§12.1 item 1, the Q6 B push: the O ender's and SP2's chase after 6.45 m) | host tests ALL PASS; pkgcheck; the 22 existing pairings still byte-identical; his 7 pairings all K.O.; the build; a smoke run; the playtest Artifact |
| Gates | §12.1 items 2–4 while the user plays | reported to the user |
| Later | the motion style (§11.2, asked and researched first), real clips, ASSIST / learner, the CPU style search, cinematics | — |

Each batch runs in its own worktree with a fresh agent; the lead re-runs the tests and gates, merges, pushes.

## 17. The Bankai redesigned: two modes, the bind (the user, 2026-10-17)

> 「在開始前我想修改卍解的設定，能請萊醬你在跟我討論一下嗎？」
>
> 「1. 卍解捆綁時大家會受到灰血保護，且雙方的 reiatus 會處在共用的狀態，受攻擊時也會同時扣除 reiatus，如果 reiatus
> 耗盡會推出滾綁模式 此時雙方的灰血就會轉成真實傷害，但如果是主動解除那就會恢復到原本的血量值。
> 2. 捆綁改成一個模式，進入捆綁模式時才會觸發上述的狀態，且攻擊模組切換成近戰，此時的 L 會將對手拉近。
> 3. 非捆綁時設計成遠攻模式，由鎖鏈球設計與揮打鎖鏈為攻擊主體，此時前搖大、攻擊距離長， L 會將人推開。」

Follow-up answers (AskUserQuestion, 2026-10-17): entry 「A 鎖鏈命中才進入」; the pool 「A 雙方相加成一條」; the release
cost 「至少自身要有兩格 reislatus 才能用」, clarified as 「至少要有兩格 reiatus 才能開啟捆綁，結束時剩餘的 reiatus 會優先留給對手，剩餘才給自己」;
the Kikon 「Kikon 也變成灰魂保護」; SP 「A 可以，從共用量扣」; escape 「不能，然後不限制距離，但可以用 L 拉近距離」; regen
「A 不會，只會減少」.

**This supersedes** §4's orb rules (damage paid from each fighter's own Reiatsu, the "can't be K.O.'d while covered"), the
6 m leash and its stop, Q1 (the symmetric cover), Q2 (a Kikon empties the cover), Q7's "back to the Shikai", and §9's
single Bankai string set. Shared hook 5 and 7 (held in B1) are redesigned from this section.

| Piece | Rule (the user's; **lead's reading** where marked) |
|---|---|
| Form | the Bankai is permanent once awakened (as every awakening); it has two **modes**: **ranged** (default) and **bind** |
| Ranged mode | the attacks come from the chain orb and swung chains: long startup, long reach; **L pushes the opponent away** |
| Bind mode | a melee move set; **L pulls the opponent in**; no distance limit (the 6 m leash is gone) |
| Entry | a binding chain throw that must **hit** (guardable, Step-able); he needs **at least 2 bars (200) of Reiatsu** (lead's reading: his own, at the throw) |
| The shared pool | at entry both Reiatsu bars add into one shared pool (up to 600); every hit on either fighter drains it (**lead's proposal: 1 per 2 damage**, as before); both may spend SP from it; it never regenerates (every gain frozen) |
| Grey protection | inside the bind, damage taken by either fighter becomes **grey** (shown on the Reishi bar, not real): nobody is K.O.'d; a Kikon's Konpaku loss is grey too (grey souls) |
| Ending: drained | the pool reaches 0 → the bind ends, both fighters' grey damage and grey Konpaku become real (a Soul Break or a K.O. can follow); back to the ranged mode |
| Ending: released | he drops it himself (any time) → both fighters' Reishi and Konpaku return to their values at entry; the pool left is given **to the opponent first** (lead's reading: up to his 300 bar), the rest to Hisagi |
| Escape | the opponent cannot break the bind |

- **When the bind ends, the opponent reels 30 f** (the user, 2026-10-17: 「捆綁結束時讓對手硬直 30f」; Hisagi does not reel;
  read as both endings, drained or released). This replaces Q7 A's "both reel 30 f on a dry end".
- The readings marked above and the 1-per-2 drain were restated to the user; no objection (2026-10-17), so they stand
  until the playtest.

§17.1–§17.6 below give the two move sets as segment tables (`duel-move-modules`), the entry, the bookkeeping, the
shared hooks, a self-check and the questions left.

**Conventions for §17.1–§17.6.** Every number is **the lead's proposal** (2026-10-17) unless it quotes the user (the
table above). Where a question in §17.6 is open, the body assumes its recommended option (marked "Q9 A" etc.). Forms:
`:bankai` = the ranged mode (prefix `hs-r-`), `:bankai-bind` = the bind mode (prefix `hs-b-`); a mode is a kit form, so
the switch between them is a `set-form` and happens **only out of a move** (`duel-character-rework`'s form-switch
regression). The Shikai (§7–§8) and §13's Q3–Q6, Q8 are unchanged. The Bankai has **no out-of-hand state** (canon: the
scythes come back to his hands, notes §2.3) and **no windmill** (L is the push / the pull now). Damage before the form's
multiplier; reach centre to centre where the doc says "from him", else from his feet along his facing. Roster numbers
quoted from the code (2026-10-17): `yama.lisp`, `rukia.lisp`, `ken.lisp`, `ichigo.lisp`, `barro.lisp`.

### 17.1 The ranged mode (`:bankai`, the default after the awakening)

The user: 「由鎖鏈球設計與揮打鎖鏈為攻擊主體，此時前搖大、攻擊距離長， L 會將人推開」. J = chains swung from his hands
(mid reach), K / SP / O = chains from the orb (long reach). Everything beyond 2.0 m is `:ranged` (`:melee-range` 2.0, as
the Shikai's throw): West's ward and KASA treat it as ranged, KŌSEI pays only within 2.0 m.

**Stats**

| Stat | Value | Matched |
|---|---|---|
| Dealt / taken | ×1.0 / ×1.0 (`*hs-r-mult*`, `*hs-r-taken*`: the first pacing knobs) | the Shikai's 1.15 lowered: the reach is the power; Lille's base 1.3 / 1.0 with paid lines |
| Walk / run | 3.4 / 8.5 m/s | Lille's base (`*br-walk*`, `*br-run*`), the roster's ranged fighter |
| Hurt cylinder | as the Shikai (r 0.36, h 1.8) | — |
| Kikon worth | 3 (Soul Break 4) | every awakened form |

**Segments** (the general string rules: three links, one switch, routes JJJ JJK JKK KKK KKJ KJJ, the latch, the string
gate, `:enter` on K2 / K3; one move per (link, button) + the J2s / K2s copies)

| Move | Kind | S / A / R | Dmg | Guard | Block | Reach (volume) | Reaction | Push / drag | Role | Matched |
|---|---|---|---|---|---|---|---|---|---|---|
| J1 鎖鞭 SABEN | quick | **12** / 3 / 12 | 22 | 8 | −2 | **4.0 m** arc 100° (the swung chain), `:no-close` | flinch, **hitstun 24** | — | the mid poke; S 12 loses to every J1 (7–10) | Lille's J1 / J2 hitstun 24 (DUEL_LILLE_V3 §28); Rukia K1's 2.8 m is the roster's longest K1 today |
| J2 返鞭 KAESHI-BEN (+ J2s) | quick | 11 / 3 / 13 | 22 | 8 | −2 | 4.0 m arc 100° (the other way) | flinch 24 | — | link | — |
| J3 旋鎖 SENSA | quick, ender | 13 / 3 / 18 | 30 | 12 | −4 | 4.4 m arc 180° | stagger | ender push out of J1's reach: 4.0 + body + 0.05 ≈ **4.45 m** | the mid finish; O ender | Lille's J3 S 12 (`br-j3`) |
| K1 墜鎖 TSUISA | flash | **22** / 4 / 22 | 52 | 14 | −3 | **7.5 m** line from the orb, `:cap 0.3 7.5 1.1 0.35`, `:track` 30 °/s, `:no-close` | stagger | **drags to 3.5 m on hit** over 10 f (inside J's 4.0 m, so KJJ reaches; the Shikai NAGE's rule with 3.5 for 1.6) | the long poke | KUSARI-BIKI 7 m S 16 (an SP); NADEGIRI 8 m S 20 (an SP); the Shikai NAGE 6 m S 18 |
| K2 / K2s 薙鎖 NAGISA | flash | 24 / 4 / 24, `:enter` 6 → **S_eff 18** | 44 | 14 | −3 | 6.0 m arc 140° (a chain sweeps the ground) | stagger | — | link | — |
| K3 落鎖 RAKUSA | flash, ender | 24 / 5 / 34, `:enter` 6 → S_eff 18 | 66 | 18 | −20 | 7.5 m line, r 0.5 (a bundle of chains dropped from the orb) | crumple | ender push out of K1's reach: kit `:push-reach` 7.5 (§12.4 hook 3) → ≈ **7.95 m** (Q6 B's rule, the K1 of this form) | the heavy finish; O ender | Kenpachi K3 R 34 −20 |
| L 鎖払 SAHARAI | sig | **14** / 4 / 22 | 30 | 14 | −4 | r **3.0 m, 360°** (the chains whirled round him) | knockback | **hit: pushed to 6.5 m** from him (18 f slide); **block: pushed to 4.5 m** (the block slide, the blockstun sized to −4) | the escape at close range; **cooldown 120 f** from the press | West's SHONETSU (S 16, 360°, cooldown 150); the Shikai windmill's push |
| Shift+K SP1 綴雷電 TSUZURI RAIDEN | sp | 20 / 3 / 24 | 110 | 22 | −14 | 9.0 m line, `:track` 30 | `:bind` 40 (paralysis) | — | 1 bar; cancels a J / K link on hit (generic) | KUSARI-BIKI's bind 40; the Shikai SP1 6.5 m |
| Shift+L SP2 鎖雨 KUSARI-AME | sp | **30** / 14 / 30 alone; off a J / K string hit `:enter` 10 → S_eff 20 (the charge-less copy) | 70 + 90 | 22 each | −18 | a lane 10 m × 2 m from him (`:cap 1.0 10.0 1.2 1.0`): aims 120 °/s for 6 f, then locked | two windows (f30–33 70 flinch, f40–43 90 knockdown) | — | 2 bars (awakened); the long-range spend-all; alone a 30 f tell, −18 | Brave Souls' "chains rain from a sphere"; Lille's `:br-k-hiren-c` copy; Kyokujitsujin's 9 m cone |
| I | Breaker | the universal Breaker (§4) | 150 | | | 1.35 m | | | look: the chain round his arm slammed down | every Breaker |
| O 降鎖 KŌSA | kikon module | aura 6 (aim 120 °/s), **no dash**, strike 20 / 2 / 30 locked, `:ender-dash` 0 | 70 | | −14 | lane `:cap 0.5 9.0 1.2 1.0` | | | chains rain along a lane; cooldown 90; Kikon 3 | ENJO 9 m S 20; HAKKA 7.5 m |
| P 首掛 **KUBIKAKE** | the binding throw | §17.2 | | | | 7.0 m | | | the entry to the bind | — |
| Step / Hoho | generic | Step 2.5 m (J-cancel from f12: a back Step → J1 is his retreating poke); Hoho 30 FS (behind him: into his weak range) | | | | | | | | |

- **Budget exception (stated, host-pinned):** the ranged mode's J1 S 12 and K1 S 22 sit outside DUEL_STRINGS §2.1's
  J1 7–10 / K1 16–20 band (「前搖大」); the host test gets a per-form band for `:bankai` (J1 11–13, K1 21–24) and still
  pins S(K1) − S(J1) = 10 ≥ 7, every on-hit link, K ≥ J + 0.5 m (7.5 / 6.0 / 7.5 ≥ 4.5) and the −2 / −3 / −4 / −20.
- **Combo arithmetic (hitstop included, host-pinned):** J1 (A 3, hitstun 24) → J2 S 11: 14 ≤ 23; → K2s S_eff 18: 21 ≤ 23.
  K1 (A 4, stagger 26) → K2 18: 22 ≤ 25; → J2s 11: 15 ≤ 25, the 10 f drag ends before it. K2 → K3 18: 22; → J3 13: 17.
  J3 / K3 → O lane S 20: 3 + 20 = 23 ≤ 25 / 5 + 20 = 25 ≤ 39 (lane 9 m + r 1.0 covers the 7.95 m push). SP1 off K: 24 ≤ 25, off J: 23;
  SP2's copy S_eff 20 the same. Block gaps: a K link after anything 18 − 3 = 15 ≥ 11.
- **Routes on hit** (×1.0): JJJ 74, JJK 110, JKK 132, KKK 162, KKJ 126, KJJ 104. Lille's attack state for comparison:
  JJJ 76, KKK 166 (×1.3: 99 / 216). Under the Shikai's (JJJ 113, KKK 228 after ×1.15): the reach and the bind pay for it.
- **Ranged without a price?** Lille's rule 「沒有消耗資源的話就不能有遠距離攻擊」 was his; the user asked this mode for long
  unpaid reach (「攻擊距離長」). The price here: the startup (every attack ≥ S 11), the awakening spent, KŌSEI unpaid
  beyond 2.0 m (so his Reiatsu, needed for the bind, builds only from +3 /s and the hit gains: ~30 s a bar), and 2 m.

**At 2 m in this mode** (weak by design; the user's 「前搖大」). His fastest hit is J2's S 11; every opponent's J1
(S 7–10) beats a J1 / L started together, and a Breaker beats his guard. What he does:
1. **Guard, then L 鎖払 in a gap**: S 14 fits the gaps a K link (≥ 11 f, mostly ≥ 14) or an ender leaves; on hit he is at
   6.5 m (his K1 band), on block at 4.5 m at −4 (no J1 reaches from there). Whiffed or stuffed: 120 f without it.
2. **Step back + J1**: a back Step (2.5 m, iframes f3–f9) J-cancelled at f12 puts J1's 4.0 m arc on whoever follows.
3. **Run** (8.5 m/s): faster only than Yamamoto (8.0); Rukia (9.0) and Kenpachi (10) catch him.
4. **The throw at 2 m** works (the line starts at his feet) but S 24 is the slowest thing he owns: a read, not an escape.
The risk, said plainly: a rushdown (Kenpachi, Ichigo) who blocks one L has 120 f of him without it; the CPU target in
§17.5 #12 watches it.

### 17.2 The binding throw 首掛 KUBIKAKE (the entry)

The user: 「鎖鏈命中才進入」, 「至少要有兩格 reiatus 才能開啟捆綁」. Canon: 首掛け is his one named technique, the chain round
the neck (ch. 337 / 384); in the Bankai it becomes the noose (notes §2.4).

| Piece | Rule |
|---|---|
| Button | **P** in the ranged mode (the awakening button, free once he is awakened: Kenpachi's second P is the precedent); from idle / walk / guard / **run** (§17.4 hook 7); not from blockstun, never as a cancel (no J / K / SP route into it: it must be a read). Touch: the AWAKEN chip (held 300 ms) stays shown, labelled BIND |
| Frames | **S 24 / A 4 / R 30**; a whiff R + 12 = 42 (the K-link whiff rule); no armour; `:track` 30 °/s in the startup only (the S-frame tell: the blade raised, the chain whirled overhead, canon's release gesture) |
| Volume | a **7.0 m** line from his hand, `:cap 0.3 7.0 1.1 0.35`, `:ranged` beyond 2.0, `:no-close`; damage **40**, guard 14 |
| Guardable / Step-able | yes: a front guard (200°) blocks it, West's ward, KASA and a parry within 2.0 m catch it as any ranged window; a side Step started by the startup's f16 clears it (30 °/s × 24 f = 12°, 1.5 m at 7 m; host-check against the 2.5 m Step); Step / Hoho iframes dodge it |
| On hit (counter-hit too) | the bind starts (§17.3). The victim is **yanked to 2.0 m over 12 f** (the noose; motion on the hit, readable as the chain snapping taut) into a **30 f reel**; Hisagi's recovery is cut to **14** on hit, so he is **+16** (hitstop aside): a bind-mode J1 (S 8) or SP1 (S 14) combos, a K1 (S 18) does not. The 40 is real (it lands before the snapshot) |
| On block / armour / absorb / parry | **no bind** (a hit is required). Block −20 at up to 7 m: only ranged answers punish it (Lille's lines, a wave already out); up close a J1 punishes it |
| On whiff | 42 f of recovery: a run-in (8–10 m/s covers 7 m in 42–53 f) plus a J1, or any ranged K, punishes it |
| 200 own Reiatsu | checked **at the press** (fewer than 200: refused, the cue `refused-cue`, the press eaten) and **again at contact** (Senjumaru's 星 can drain him during the startup: below 200 then, it lands as a plain hit: 40, the yank, the reel, no bind). The throw itself costs nothing (the user: a requirement, not a cost) |
| Refused also | while a bind is up (the mirror), while it cools, at a refused state: the same cue |
| Cooldown | 180 f from the press after a whiff or a block; **after a bind, no wait** (Q13 C, the user: only his own 2 bars): the release's split (the pool to the opponent first) and a drained end's empty bars are what keep him from binding again at once |
| Hit mid-throw | interrupted like any move in startup (no armour); the cooldown already runs. A trade on its hit frame: both hits land; the bind starts at the end of that step if the throw hit and the step settled no Kikon or Soul Break (one did: no bind, the reset follows). Both throws hitting in one step (the mirror): no bind for either |
| When it starts | at the end of the hit step, after `settle-souls`: the snapshot is taken then, so that step's damage on both sides is real |

### 17.3 The bind mode (`:bankai-bind`) and its bookkeeping

**The melee set** (the user: 「攻擊模組切換成近戰，此時的 L 會將對手拉近」; the general rules and the §2.1 budget as written)

| Move | Kind | S / A / R | Dmg | Guard | Block | Reach (volume) | Reaction | Push / drag | Role | Matched |
|---|---|---|---|---|---|---|---|---|---|---|
| J1 弦 GEN | quick | 8 / 3 / 12 | 32 | 8 | −2 | 1.5 m, arc 110° | flinch | lunge 0.3; the opener close-in (generic) | the opener | Ichigo J1 7/3/12, 32 |
| J2 返弦 KAESHI-GEN (+ J2s) | quick | 8 / 3 / 13 | 32 | 8 | −2 | 1.5 m, 110° | flinch | — | link | |
| J3 双弦 SŌGEN | quick, ender | 9 / 3 / 18 | 40 | 12 | −4 | 1.5 m, 200° (both crescents crossed) | stagger | push ≈ 2.25 m (J1 1.5 + 0.3 lunge + body + 0.05) | O ender | Ichigo J3 40 |
| K1 引斬 HIKIGIRI | flash | 18 / 4 / 20 | 64 | 14 | −3 | 2.6 m line | stagger | the opener close-in (generic) | the heavy opener | Yamamoto K1 18/4/20 |
| K2 / K2s 巻斬 MAKIGIRI | flash | 20 / 4 / 24, `:enter` 6 → 14 | 56 | 14 | −3 | 2.8 m arc 140° | stagger | — | link | Ichigo K2 60 |
| K3 絞 SHIBORI | flash, ender | 22 / 5 / 34, `:enter` 8 → 14 | 80 | 18 | −20 | 3.0 m (the chains wrap and cinch) | crumple | push out of K1's reach (no `:push-reach`): ≈ 3.05 m | O ender | Kenpachi K3 80 |
| L 引寄 HIKIYOSE | sig | **16** / then the drag / R 8 | — | — | — | no hit window: the noose | — | the opponent **dragged to 2.0 m** at 18 m/s (`*chase-max*`'s speed: from the 8 m reset in 20 f); refused within 2.5 m; **cooldown 90 f** | the approach (「可以用 L 拉近距離」) | Ichigo's pull-to rule; the string chase's "motion only" |
| Shift+K SP1 綴雷電 | sp | 14 / 3 / 24 | 110 | 22 | −14 | 4.0 m line | `:bind` 40 | — | 1 bar **from the pool**; cancels a J / K link on hit (3 + 14 = 17 ≤ 17) | KUSARI-BIKI |
| Shift+L SP2 絞縄 KŌJŌ | sp | 20 / 4 / 30 alone; off a J / K hit `:enter` 6 → S_eff 14 | 160 | 30 | −16 | 3.0 m arc 160° | crumple | — | 2 bars **from the pool**; the blade raised, the noose drawn on **both** necks (look only, canon's shared pain) | Ichigo SŌGA 130; Kenpachi Buttagiru 180 |
| I | Breaker | universal | 150 | | | 1.35 m | | | | |
| O 絞首 KŌSHU | kikon module | aura 6, a dash ≤ 30 f at 14 m/s, strike 8 / 3 / 24 within 1.6 m | 70 | | −14 | 1.6 m | | | cooldown 90; Kikon 3 | TENCHI |
| P 解縛 KAIBAKU | the release | below | | | | | | | | |

Walk / run 3.8 / 9.0 (Rukia's), ×1.0 / ×1.0 (the damage is grey anyway; a higher × only drains the pool faster),
Kikon 3 / Soul Break 4. Routes on hit: JJJ 104, JJK 144, JKK 168, KKK 200, KKJ 160, KJJ 136 (Kenpachi base 112 / 150 /
175 / 210 / 172 / 147). The binding case: J1 (A 3, flinch 18) → K2s 14: 17 ≤ 17, as in every form.

**L 引寄 is motion only** (like the string chase): the dragged opponent keeps every input but movement. He can guard, start
an attack (a J1 pressed into the drag reaches Hisagi first: the counterplay), Step (its hop adds to the drag) or Hoho
(it lands him behind Hisagi, inside 2.5 m: the drag ends). It is never a hit, so it is not guardable and needs no
guard arc; the tell is S 16 (the blade raised, the chain snapping taut). Hisagi's R 8 runs past the arrival while the
opponent was free all along, so it is an approach into his range (and a read on what the opponent does on the way
in), never a combo.

**The release 解縛 KAIBAKU** (the user: 「主動解除那就會恢復到原本的血量值」, any time). P in the bind mode:
- From idle / walk / guard / blockstun / a run: at once. **During his own attack move: the press is held** (his `:tick`
  keeps it, as the Shikai's held K, §7.1) **and fires on the move's last frame**, so it never cancels a whiffed or blocked
  recovery (§17.5 #6). **In hitstun / airborne: under the Burst rule** (after the combo's 2nd hit, inputs not locked:
  `awaken-state-p`'s rule; Q9 A).
- The end is applied **after both fighters stepped, before that step's hits** (where a Burst is applied, DUEL_DESIGN §4),
  so a release pressed on the step the pool would run out wins the race, and that step's hits land on the restored
  values.
- Then Hisagi plays **UNWIND, 20 f** (the chains fall slack; no hit, no iframes), replacing whatever he was in (hitstun
  included); the switch to the ranged mode is on UNWIND's last frame. The opponent reels 30 f (below): **Hisagi +10**,
  under every ranged-mode startup (≥ 11), so no release gives a true combo.

**The bookkeeping** (the user's rules: 灰血, the shared pool, 「耗盡…灰血轉成真實傷害」, 「主動解除…恢復到原本的血量值」,
「剩餘的 reiatsu 會優先留給對手，剩餘才給自己」, 「Kikon 也變成灰魂保護」, 「不會，只會減少」, 「捆綁結束時讓對手硬直 30f」)

| # | Rule | Detail |
|---|---|---|
| B0 | **Entry snapshot** | at the bind's start (§17.2), per fighter: Reishi R0 and Konpaku K0. The pool **P = his Reiatsu + the opponent's** (200–600); both Reiatsu bars now show the pool |
| B1 | **Grey damage** | the live Reishi and Konpaku keep changing as usual; the HUD draws the part lost since the snapshot grey. Two exceptions: **Reishi at 0 queues no Soul Break** (it floors at 0, as `deal-damage` already does) and **Konpaku at 0 is no K.O.** (it floors at 0). Nobody is K.O.'d inside |
| B2 | **Grey Kikon** (Q10 A) | a Kikon connects as usual: its cinematic, the victim's Konpaku −n (grey), **his Reishi refilled** (the Kikon paid for that grey Reishi, as outside), the reset (8 m apart, 48 f, guard gauges full); **the bind goes on** (no distance limit). A Kikon on a grey 0 Konpaku takes nothing more. The Kikon refund's Reiatsu bar is frozen (B4); its flash-step bar is paid |
| B3 | **The drain** | the pool loses **1 per 2 damage** of either fighter (every `deal-damage`: hits, chip, hazards, DRINK's half; the **nominal** damage, so hitting a 0-Reishi fighter still drains), and **every SP cost of either fighter** (1 bar 100, 2 bars 200); **no drip over time** (Q12 B, the user: only hits and SPs drain it). Self-costs (`burn`: Kenpachi's arm, Ennetsu, CRACK) are not wounds: no drain, grey like any Reishi loss. Halves are exact in f32 |
| B4 | **Frozen gains** | every Reiatsu gain of both fighters stops while bound (+3 /s, hit gains, KŌSEI, BLUE's bar, WHITE's and the awakening regen's Reiatsu, the Kikon refund, `reset-round`'s `:reset-reiatsu`, Lille's stance gains, 星's flow). Flash-step, the guard gauge and Fighting Spirit run as usual (not undone by a release) |
| B5 | **SP spends** | either fighter may spend SP from the pool; a spend is refused when the pool is under its cost. Two spends in one step that the pool can't both cover: both fire, the pool floors at 0, the drained end follows (symmetric: no side goes first) |
| B6 | **Real heals** | a heal inside the bind (an awakening's 20 %, its regen and WHITE's Reishi regen) raises the live Reishi **and that fighter's snapshot** (each capped at max): a heal is real, so a release keeps it |
| B7 | **Drained end** (pool ≤ 0) | checked at the end of the step's hit resolution, **before** `settle-souls`, so the bind is off while that step settles: the grey becomes real by keeping the live values; each fighter at Reishi 0 who isn't this step's Kikon victim is queued a **Soul Break** (attacker = the other; worth = the other's current form's + 1, ≤ 5; the opponent's queued first, then Hisagi's, for the cinematic order); then `settle-souls` as always (one cinematic, a lethal pair is the trade rule, both out is a draw). A fighter whose Konpaku is already ≤ 0 with no event this step: **K.O.** (`match-over`, its own cinematic). If nobody was settled: the end effects (B9). Both Reiatsu bars: 0 |
| B8 | **Released end** | both fighters' Reishi and Konpaku = the snapshot (B6's heals included); grey Kikons undone. The pool left L goes **to the opponent first, up to his 300** (min(300, L)), the rest to Hisagi (min(300, L − that)); then the end effects (B9) |
| B9 | **End effects** (either end) | hazards of both cleared (a projectile in flight would land on undefined values); the opponent's move ends and he **reels 30 f** (max with a reaction he is already in; airborne / down: his fall and wake-up stand, ≥ 30 f); Hisagi's move ends into UNWIND 20 f (no reel for him); the ranged mode on UNWIND's last frame; the throw re-arms per §17.2; `:bind-ended` emitted (HUD, learner, counters) |
| B10 | **Time-up during a bind** (Q11 A) | resolved **as drained** first (B7 without cinematics or the reset: the Soul Breaks' Konpaku counted), then the usual tiebreak (Konpaku, then Reishi %). So a bind never protects a lead to the bell |
| B11 | **The opponent's awakening** | allowed (`repel!` breaks Hisagi's attack; there is no leash, so the 5 m slide stands); its heal and regen per B6, its Reiatsu frozen (B4). **Kenpachi's Bankai (P in cup 3) is refused while bound**: it rewrites his Konpaku to 1 and refills Reishi, which a release would then undo half of. Lille's and the others' awakenings change forms only |
| B12 | **Bursts** | allowed as usual: BLUE escapes a combo (flash-step, not frozen); WHITE's Reishi regen per B6, its Reiatsu frozen; ORANGE as usual. Every reset still ends every burst |
| B13 | **The opponent's own Kikon** | allowed; grey (B2). A red opponent (live Reishi < 30 %) makes Hisagi's follow-ups unguardable as usual, and the reverse |
| B14 | **The opponent can't break it** | (the user: 「不能」) no button of his ends it; it ends only by the drain, Hisagi's release, time-up or a match / PRACTICE reset |
| B15 | **The mirror** | one bind on the field: the other Hisagi's KUBIKAKE is refused while one is up; if he is the bound one he fights in his own form and mode (only the binder switches to melee); both throws hitting in one step: no bind |
| B16 | **Resets** | match start, PRACTICE's reset (silently: no conversion, no distribution, no reel), ENDLESS's stage start (`:endless-form :base`): no bind, the throw armed. The bind's state is per side (the two-slot vectors of §7.1), in the state-hash line |

**What the user sees**: the Reishi bar's grey band from the snapshot; grey souls for grey Konpaku; both Reiatsu bars
showing the pool (a "×n bars" tally while it holds more than 3); the orb's look (§11.4) with the noose on both necks;
the touch chip labelled FREE.

**The clock (the lead's estimate).** A bind lasts until ~2 × P damage-equivalents are spent: P ≈ 300–450 typically (his
≥ 200 + the opponent's 100–250), the melee rate of two fighters ~50–70 damage /s together, each SP = 200–400 of damage
in pool terms (no drip, Q12 B): **~8–15 s a bind when both attack; unbounded while both stall** (time-up resolves it, B10). A drained bind costs the clock nothing (its damage counts, and
it forces close range); a **released** bind erases its 8–15 s of fighting and gives the opponent his Reiatsu back; the
drained end's drought (both bars at 0, ~33 s a bar) slows the next SPs (+3–8 s). With 1–3 binds a match (the 200
requirement at ~30 s a bar, the re-arm) and the CPU releasing about half of them: **+5–25 s** in his pairings, less than
the orb's +15–40 s. HR / HS / HH (the slow pairings) are the watch. Counted per match (§17.5 #15).

### 17.4 Shared hooks 5 and 7, re-specified (replacing §12.4's orb versions)

Both default off: with no kit setting them every reader returns what the old code did, and the 22 existing pairings
stay byte-identical (`simgate --seeds 10 --summary`, `--cvc`, `cmp` against the parent), as B1 proved for hooks 1–4,
6, 8. The bind's own state, timers and rules live in `hisagi.lisp`; the shared files only ask.

| # | Name (proposal) | Where | Default | What it does when set |
|---|---|---|---|---|
| 5a | kit hook `:bind` → `bind-of (e)` | combat.lisp (beside `siphon-of`, which asks the opponent's kit the same way) | no hook: NIL | T-like (the binder entity) while E is in a bind, on either side. Every other 5x reads only this |
| 5b | `deal-damage` | combat.lisp | unchanged | while bound: no Soul Break queued at 0 (B1); the damage reported to the binder's `:bind-damage` hook (att def dmg), the nominal dmg (B3) |
| 5c | `settle-konpaku` | combat.lisp | unchanged | while bound: Konpaku floors at 0 and returns no K.O. (B1, B2); the refill and the cinematic as usual |
| 5d | `reiatsu-gain!` | combat.lisp + every gain path (`pay-gauges`' Reiatsu part, `white-regen!`, the Kikon refund in `settle-souls`, `reset-round`'s `:reset-reiatsu`, `barro.lisp`'s stance gains, `senjumaru.lisp`'s 星 `gauge-move`) | adds as before | while bound: adds nothing (B4). Host test: each path, one by one, inside a dummy bind |
| 5e | the pool: `reiatsu-of (e)` / `reiatsu-spend! (e n)` | combat.lisp; readers `kit-command-ok-p`, `try-command`'s spend, hud.lisp, ai.lisp's SP reads | the fighter's own gauge | while bound: read from / spent from the binder's pool (the `:bind-pool` hook). B5's double spend falls out of it |
| 5f | `heal! (e n)` | combat.lisp (`awaken!`, `white-regen!`'s Reishi part) | the plain add | also raises that fighter's snapshot through the binder's `:bind-heal` hook (B6) |
| 5g | the drained check + the release slot | combat.lisp: a binder `:bind-step` hook called at the end of the hit resolution before `settle-souls` (B7) and where Bursts are applied (B8's release) | absent: nothing called | the hook may queue Soul Breaks into `*soul-breaks*`, call `match-over`, and apply the end effects (B9) |
| 5h | `bankai-ok-p` | fighter.lisp / combat.lisp | unchanged | refused while `bind-of` (B11) |
| 5i | `time-up` | flow.lisp | unchanged | calls the binder's `:bind-resolve` first (B10) |
| 5j | HUD / learner | hud.lisp (the grey band, grey souls, the pool tally, from `:bind-snapshot`); ai-learn.lisp (`gauges-dealt` beside an `absorbed`-like grey counter; the `:bind-ended` frame is not read as a heal or a hit) | nothing drawn / read | — |
| 7a | kit hook `:p` | fighter.lisp `try-command`'s `:awaken` case (after the awakening and Kenpachi's Bankai, both of which an awakened Hisagi can't take); `*run-commands*` gets `:awaken` only for a kit with `:p`; `awaken-state-p`'s rule passed in for the hitstun case | absent: P does nothing once awakened (today) | the kit's function decides and starts its move (KUBIKAKE / KAIBAKU) or refuses with the cue; also the CPU's path |
| 7b | the touch chip | onehand.lisp / hud.lisp | the AWAKEN chip hidden once awakened | shown for a kit with `:p`, its label from the hook (BIND / FREE) |

**Dropped from the old hook 7**: `:awaken-ok` (the Bankai's entry is the plain awakening again; the 200 requirement
sits inside `:p`). **Dropped from the old hook 5**: `orb-exchange`, the cover, `orb-covered-p`, the scorch / mirror
routing (no Reishi is exchanged any more: wounds stay wounds, only grey), the `*kikons*` filter (B2: a Kikon plays).

**As built (batch B1b, 2026-10-17; hooks 5a–5j, 7a–7b).** Each defaults off: no kit holds any of the hooks below, and
with none `simgate --seeds 10 --summary` (22 pairings) and `simgate --cvc` are byte-identical to the parent commit
(`cmp`, the simgate fas rebuilt from the new sources). `duel-rules-test` (8989 checks) now also loads `components`,
`combat`, `fighter` and `flow` over stand-in entities and pins both the defaults (no registered kit has a bind hook or
`:p`; every changed reader on Yamamoto vs Kenpachi does what the old code did: the gain's clamp, the spend, the plain
heal, the Soul Break queued at 0, the K.O., an awakened P doing nothing, the step / resolve slots calling nothing) and
each hook's one job with a dummy binder kit (`:t-bind`, a non-`:base` form, no roster slot) whose hooks keep the bind's
state in the test, as Hisagi's file will. All the bind's hooks live in the **binder's** kit (`:hooks`), binder first in
every call.

| # | Name as built | Where | Default | Notes / pinning test |
|---|---|---|---|---|
| 5a | kit hook `:bind (x)` → `bind-of (e)` | combat.lisp, beside `siphon-of` | NIL | the binder when E's or his opponent's form has `:bind` and it is true for that fighter (so either side reads the same binder). `bind-hook (b point)`, a binder's hook or NIL, is what every other reader calls. Test: either side → the binder; none → NIL |
| 5b | `deal-damage` + hook `:bind-damage (b att def dmg)` | combat.lisp | unchanged | bound: Reishi floors at 0, no Soul Break queued (returns NIL, so `apply-hit` sets the reaction as for any hit), the **nominal** dmg to `:bind-damage` (the drain) and to ATT's new `gauges-grey` count. The queueing moved into `queue-soul-break! (att def)` (once per victim, in order: B7's drained end calls it). Pure rule `bind-drain (pool dmg &optional (rate 0.5))` in rules.lisp (floors at 0). Test: 7 damage drains 400 → 396.5 exactly, 2000 past 0 queues nothing |
| 5c | `settle-konpaku` | combat.lisp | unchanged | bound: returns no K.O. (Konpaku already floors at 0 in `kikon-result`); the refill, `:settled`, the event as usual, so a grey Kikon plays (Q10 A). Test: Konpaku 2 − 3 → 0, no K.O., Reishi full; after the drained end the same call K.O.s |
| 5d | `reiatsu-gain! (e n)` | combat.lisp; callers `pay-gauges` (hits, KŌSEI, the siphon's, Lille's stance gains), BLUE's bar in `burst!`, `white-regen!` (now `(e g n)`: WHITE and the awakening's regen), the Kikon refund in `settle-souls`, `reset-round`'s `:reset-reiatsu`, `gauge-system`'s +3 /s | adds as before (`(f32 (gauge-add r n *reiatsu-max*))`) | bound: adds nothing. **Correction**: Senjumaru's 星 is a transfer (`gauge-move`, his Reiatsu into hers), not a gain: senjumaru.lisp skips its Reiatsu part while `bind-of` (its flash-step part runs). Test: `reiatsu-gain!`, `pay-gauges` (flash-step still paid), `gain-gauges`, `kosei!`, `white-regen!` each frozen in the dummy bind; the paths the host can't call (the refund, BLUE, the regen, the reset) are pinned by a source check: combat.lisp writes `gauges-reiatsu` only inside `reiatsu-gain!` and `reiatsu-spend!` |
| 5e | `reiatsu-of (e)` / `reiatsu-spend! (e bars)` + hook `:bind-pool (b &optional n)` | combat.lisp; readers `kit-command-ok-p`, `reiatsu-bars` (so ai.lisp's and Lille's SP reads), `try-command`'s spend, hud.lisp's two Reiatsu rows, Senjumaru's SP1 hank shade | the own gauge / `spend-bars` | bound: the pool, `(funcall :bind-pool b n)` spends N Reiatsu (bars × 100) and returns the pool. Test: a 150-Reiatsu Yamamoto bound in a 396.5 pool may SP1 and pays it from the pool (296.5), refused at 50 |
| 5f | `heal! (e n)` + hook `:bind-heal (b e n)` | combat.lisp; `awaken!`'s 20 %, `white-regen!`'s Reishi | the plain capped add | the hook raises E's snapshot (B6). Test: +100 live and snapshot |
| 5g | `bind-step! (e phase)` + hook `:bind-step (b phase)` | combat.lisp; `hit-system` (its hit collection and application moved into `hit-apply`) calls `:hits` after the hits, before `settle-souls`; fighter.lisp `fighter-system` calls `:release` right after the step's bursts are applied (not during a cinematic) | nothing called | Test (the dummy's B7 / B8): drained with both at 0 → `(reverse *soul-breaks*)` = the opponent's first, then the binder's; released → both snapshots back, pool 450 → 300 to the opponent, 150 to the binder. Pure rule `bind-release-split (left &optional (cap 300))` pinned at L = 0 / 150 / 300 / 450 / 600 |
| 5h | `bankai-ok-p` | combat.lisp | unchanged | NIL while `bind-of` (also `bankai-ready-p`, the HUD's and the CPU's reads). Test |
| 5i | `bind-resolve! (e)` + hook `:bind-resolve (b)` | combat.lisp; flow.lisp `time-up` calls it first | nothing called | Test: A ahead 3–2 on grey values with grey 0 Reishi → after `time-up` the Soul Break's Konpaku counted, P2 wins |
| 5j | hook `:bind-snapshot (b e)` → `bind-snapshot-of`, `bind-grey-frac`, `bind-grey-souls`; `dealt-real (e)` | combat.lisp; hud.lisp `%hud-reishi` (new last arg GREY: a grey band from the live fill to the snapshot), `%hud-pips` (new last arg GREY: grey flames up to the snapshot's Konpaku, after any shattering), `pool-tally` ("x3".."x6" beside the Reiatsu label / over the portrait cells while the pool is over 300); ai-learn.lisp | 0 / NIL: nothing drawn | the learner reads `dealt-real` (dealt − `gauges-grey`) everywhere it read `gauges-dealt`; the binder's end clears `gauges-grey` when the grey turns real (drained) and leaves it on a release; a burst window that a bind spans (bound at its open or its close) reads no heal. Test: the grey count and `dealt-real`; the snapshot readers (the draw itself is not host-run) |
| 7a | kit hook `:p (e free)` | fighter.lisp `try-command`'s `:awaken` case, after the awakening and Kenpachi's Bankai; `*run-commands-p*` (`*run-commands*` + `:awaken`) is the run's list for a form with `:p` | absent: P as before | FREE is `awaken-state-p`'s (idle / guard / blockstun, or a combo past its 2nd hit, inputs not locked: Q9 A's rule); the hook reads the state for the run case itself; T = the press taken (it emits its own refusal cue). The CPU presses `:awaken` as before. Test: called with free true when idle, false in a combo's 1st hit; a kit without `:p` gets nothing |
| 7b | kit hook `:p-label (e)` | onehand.lisp `hud-deck` | the chip only at EVOLUTION / a Bankai ready | a form with `:p` always shows chip 5, labelled by `:p-label` (BIND / FREE), else its usual label (draw only, not host-run) |

- Kit docs: kit.lisp's `defkit` docstring lists `:p`, `:p-label` and the bind hooks.
- Not built (Hisagi's own, B2): the bind's state, the throw, UNWIND, the reel, the end effects (B9), the hash line, the
  CPU and the learner situations.

### 17.5 Adversarial self-check (the lead, 2026-10-17)

| # | Failure scenario | Fix applied |
|---|---|---|
| 1 | **Throw → release at once → +reel → throw**: a free loop on the 30 f reel | the release's UNWIND (20 f) leaves +10, under every ranged startup (≥ 11): no true combo; after a release the pool's rest goes to the opponent first, so he rarely keeps the 200 the throw needs (Q13 C: no re-arm wait); it needs a hit at up to 7 m with S 24 each time |
| 2 | **The throw as a combo ender** (K string → P) makes the bind a guaranteed confirm | no cancel into KUBIKAKE (neutral and run only); its S 24 is too slow to link anyway (after a K link 4 + 24 > 25) |
| 3 | **Release as a free reset** (bind, lose the exchange, undo, repeat) | the price: the pool goes to the opponent first (up to his 300), so Hisagi usually leaves with little; re-binding needs 200 of his own (~30 s a bar in ranged mode, KŌSEI unpaid beyond 2 m) and 600 f; counted per match (#15) |
| 4 | **Drained → re-bind at once** | both bars are 0 after a drain: 200 Reiatsu is ~60 s away (Q13 C: no re-arm wait) |
| 5 | **Release breaking any combo instantly** (a free BLUE that also heals) | in hitstun only under the Burst rule (after the 2nd hit; Q9 A), and it ends in UNWIND, so the opponent's reel gives +10, not a punish combo |
| 6 | **Release cancelling his own whiffed / blocked recovery** (a free cancel, `duel-character-rework`'s list) | during his own move the press is held and fires on its last frame |
| 7 | **Form (mode) switch inside a move** leaving a latched link | the switch only on a free frame: after KUBIKAKE's cut recovery (14) on entry, on UNWIND's last frame on either end; UNWIND clears the latch (`fighter-queued`) at its f0 |
| 8 | **A stalled bind** (the opponent turtles; nobody hits; the pool never drains) | no drip (Q12 B, the user): a bind can last while nobody hits; his L pull, the Breaker and SP2 (which spends the pool) against a guard; time-up resolves as drained (B10), so turtling to the bell gains nothing |
| 9 | **0-resource loop on the pool** (an SP that refunds, a gain that refills it) | every Reiatsu gain frozen through one `reiatsu-gain!` (5d), host-tested path by path; the pool only falls |
| 10 | **Pool math edges**: odd damage, the drip in f32, two SPs in one step, a hit larger than the pool, the release split | halves are exact; B5 (both fire, floor 0, drained end); a hit that overshoots counts whole (it's all converted anyway); the split is min(300, L) then min(300, L − that), host-tested at L = 0, 150, 300, 450, 600 |
| 11 | **Release and drain on one step** (who wins) | the release is applied before the step's hits (the Burst slot), the drained check after them: the release wins, deterministically |
| 12 | **Weak at 2 m becomes helpless** vs Kenpachi / Ichigo in ranged mode | L 鎖払 (S 14, 360°, pushes on hit and on block), the back Step → J1, KUBIKAKE as a read; the time-at-range probe target: in the ranged mode ≥ 45 % of his time at 3.5–9 m, ≤ 40 % under 2 m (≤ 55 % vs Kenpachi); a miss changes the AI ranges first, then goes to the user |
| 13 | **Hidden movement / aim** | listed and readable: J1 / K1 / KUBIKAKE `:no-close` (no 3–6 m opener dash); TSUISA's 3.5 m drag and KUBIKAKE's 2.0 m yank only on hit (the chain taut); L 鎖払's push; L 引寄's drag (S 16 tell, motion only, never a hit); the ender pushes (4.45 / 7.95 / 2.25 / 3.05 m); KŌSHU's dash (generic, its look); `:track` 30 °/s only in startups (TSUISA, SP1, KUBIKAKE); SP2's lane aims 6 f then locks; no `:track 720`, no turn at release, no cast-at-the-opponent point anywhere |
| 14 | **Grey edge cases**: a fighter at grey 0 Reishi and 0 Konpaku fights on; Kenpachi's Cornered reads grey Konpaku | both by design: the drain converts, the release restores; Cornered (+5 % a lost Konpaku) follows the live value, so it rises inside and falls back on a release (stated, host-noted) |
| 15 | **The clock** (released binds erase fighting) | the estimate +5–25 s (§17.3); counters per match: binds, seconds bound, drained / released / time-up ends, grey Kikons, SPs spent from the pool, pool at the end; HR / HS / HH medians read first |
| 16 | **CPU blind spots**: his CPU never releases or never drains; the opponents' CPU spends SP while losing a bind (hastening its own drained loss) or ignores the throw | his CPU: KUBIKAKE at 4–7 m when his Reiatsu ≥ 200, rolled once per approach; inside, it **releases** when its grey loss exceeds the opponent's by a margin (Konpaku × 1300 + Reishi), rolled once per change event (a grey Kikon, every 100 of pool drained), and **spends SP** when ahead; the opponents' `:opp-reflex`: a side Step on KUBIKAKE's startup through `ranged-threat-in` (hook 8; it sees a `:ranged` window), rolled once per throw start; while bound and behind, no SP unless it completes a combo; every chance EASY ≤ NORMAL ≤ HARD; the learner gets "bound, ahead / behind" situations; every rule a counter |
| 17 | **Determinism / per-match reset**: the snapshot, the pool, the timers and the re-arm outliving a match, a PRACTICE reset or an ENDLESS stage; the mirror's two binders | per side vectors reset at B16's points and hashed; one bind on the field (B15); the release / drain slots at fixed points of the step |
| 18 | **The awaken A/B**: an awakened Hisagi gets a bind that never loses for him (he releases when behind) | the A/B rows (`--cmd 39020` with him on each side, three streams) are the measure; a miss goes to the user with the release cost as the first knob (e.g. the pool fully to the opponent), not other knobs |

### 17.6 Questions for the user (the lead, 2026-10-17; recommended first)

| # | Question | Options |
|---|---|---|
| Q9 (picked A) | **Can he release the bind while he is being comboed?** | **A** yes, but only from the 2nd hit of a combo on, like a Burst; he then needs 20 frames to recover, so he escapes the combo but gets no free counter-combo / B no: while he is being hit the release waits until he is free / C yes, from the very first hit |
| Q10 (picked A) | **A finishing blow (Kikon) inside the bind** | **A** it plays as usual (the cinematic, the souls turn grey, the round resets apart) and the bind goes on / B no cinematic and no reset: the souls just turn grey and the fight continues (faster, but a Kikon reads less) / C a Kikon ends the bind at once as if the shared Reiatsu ran out (the Kikon's souls become real right away) |
| Q11 (picked A) | **The timer runs out during a bind** | **A** it counts as if the shared Reiatsu ran out: the grey damage and souls become real, then the usual winner check (nobody can hide in a bind until the bell) / B it counts as a release: both go back to their entry values / C the grey values as they are now decide |
| Q12 (picked **B**) | **Does the shared Reiatsu also fall slowly on its own?** (canon: the opponent feels it falling from the start) | **A** yes, 5 a second, so a bind where nobody attacks still ends (≤ 2 minutes for a full 600) / B no: only hits and SPs drain it (a bind can last as long as both avoid hitting) / C yes, faster: 10 a second (≤ 1 minute) |
| Q13 (picked **C**) | **How often can he bind?** | **A** as often as he can pay: the throw is ready 10 s after a release and 5 s after a bind that ran out, and he needs his own 2 bars each time / B once a match (like the orb before) / C no wait at all, only the 2 bars |

## 19. As built (batch B2a, 2026-10-17): the Shikai playable

`duel/lisp/hisagi.lisp` (sim, knobs, CPU, debug) and `duel/lisp/hisagi-art.lisp` (body, Kazeshini, clips, looks, HUD icon,
a placeholder Kikon cinematic), loaded after Lille's (`duel/MANIFEST`: `hisagi.lisp` first, the art reads his knobs); roster
index 7 (`*roster*` by load order; `tools/simgate.py` ROSTER `HISAGI`: his pairings k 28–35, HL k 33 retired). Every §8.2 /
§8.3 number is as the table (pinned in `tests/duel-rules-test.lisp`, section "Hisagi's Shikai"); the shared hooks are B1's
(`:no-close` on NAGE, `:seg-fn` HS-CHAIN-SEG on HIKI / HODOKI, `:push-reach` 6.0, `:command` HS-COMMAND, `:ranged-ward` on
the windmill, `ranged-threat-in` in his CPU). Knobs: `*hs-*` defparameters in hisagi.lisp, each with value, date, who.

**What is built.** The IN / OUT / RETURNING sickle (HS-TICK, HS-THROW-OUT at the throws' S, HS-SICKLE-IN at the pulls' /
MODOSHI's / SP1's S): the 60 f auto-retrieve counted only out of his moves, the 6.5 m chain-length return, the 8 f return;
the anchor at the throw's first contact of any kind (HS-HIT) or its line's end (6.0 / 3.2 m) on its last active frame,
clamped to r 14.7; the IN graph as `:strings` (K3 by route), the OUT graph by `:command` (SEN-1H, MODOSHI); L / SP2 refused
out (HS-OK, the cue); NAGE / HIKI drag to 1.6 m over 10 f; the windmill held 20–60 f; SP1 / SP2 / KUBIKAKE / KARI. The
`duel hisagi` gate line (throws, throw-hit / -touch / -whiff, maki, drag, pull / pull-hit, modoshi, raiden-in, auto- /
far-return, out-frames, windmill / -block / -crush, at-close / -mid / -far / -out, ai-windmill / -modoshi / -sp1 / -sp2,
opp-side-step); debug 83000–83999 (DUEL_GAMEPLAY "Debug commands"); the state in `duel hash` lines (`s<I|O|R> ax az o r`).

**Deviations from the doc (the lead's, for review):**

| # | Doc | Built | Why |
|---|---|---|---|
| D1 | §7.1: per-side two-slot vectors | a component `hss` on his fighter entity (as Ichigo's / Lille's): fresh each match and on PRACTICE's reset; a Kikon / Soul Break reset puts the sickle IN through a new kit hook `:reset` (combat.lisp RESET-ROUND); the state into the hash line through a new kit hook `:hash` (debug.lisp STATE-HASH-LINE) | per-entity state cannot leak between matches; both hooks default off (22 pairings identical) |
| D2 | §7.1: K during RETURNING kept by the tick and pressed again on arrival | the `:command` hook answers `:hold`; TRY-COMMAND starts nothing for a non-move (`(move-p mv)`, one token, default off) and the press stays in the vpad's 10-step buffer, so it fires NAGE on the 8 f arrival | the same rule with no tick press; no refusal cue |
| D3 | §8.3: the windmill "up at f6", "no hitstun" | the `:ranged-ward` flag wards for the whole move (f0 on, B1's hook is per move); the push window f6–8 with an 8 f stun (to carry its 1.5 m slide: 0 f would teleport him) | B1's hook; no lock: he is free 8 f into a ≥ 26 f hold |
| D4 | §9: P awakens to the Bankai | B2b seam: his awakening gauge is held 1 point short of EVOLUTION (HS-TICK), so P does nothing; no `:awaken-form` | the brief ("may be refused") |
| D5 | §10: SP1 off a NAGE hit | his `:sp-ender` runs only at link 3 (ai.lisp STRING-REFLEX): SP2 after RIN with the sickle in, SP1 after a K ender (EASY 0.1 / NORMAL 0.3 / HARD 0.8); after NAGE the pull 0.7 (`:string-k`), else the one-handed J | the generic reflex order |
| D6 | §10: ASSIST, learner situations, AUTO GUARD's windmill | not built | §15 "Later" |
| D7 | §11 | functional art: the K throws' drawn reach is the thrown left sickle's point at the hit volume's edge (`*hs-strike-reach*`: NAGE 6.3, MAKI 3.55, KARI-OTOSHI 2.8, read by the FK test), the pulls' chain drawn along HS-CHAIN-SEG's segment; the J tips 1.41–1.52 m (1.4 ± 0.15), KUBIKAKE 1.38; the Kikon cinematic a 120 f placeholder (刈 / 風死 stamp); glyphs 檜 佐 風 刈 baked into glyphs-extra.lisp | the motion style (§11.2) and the storyboard (§11.5) are later batches |
| D8 | — | MODOSHI is only reached through the hook (not in `kit-moves`); the CPU's reach reads see the IN graph (as B1 noted) | — |

**Host tests** (duel-rules-test, his section + the generic per-form checks with `(:hisagi :base)`): the table, the six
routes and the OUT string, the route damage (98 / 140 / 160 / 198 / 156 / 116), every §8.2 link combos with its hitstop on
both sides, the drag ends (f28) before KAESHI-SEN-1H's hit (f30), every link 3 → the O lane, the state machine pure and on
stand-in fighters (100 frames in a move: the timer at 0; 60 out: RETURNING; 8 more: IN; 7 m from the anchor: at once; the
reset), the anchor cases (contact, first contact only, whiff 6.0 / MAKI 3.2, the clamp), the `:seg-fn` cast check (the chain
through a victim dragged to 1.6 m after a 6 m hit, clear of a 2.5 m side Step, equal to a `:cap` volume at six points), the
windmill's data and hold rule, the refusals, `:hold`, and the push.

**The Q6 B push, measured** (§13 asked to check the chase): a K ender pushes 6.43 m (r 0.38; 6.39–6.50 by body). The O lane
reaches 8.4 m from where he stands (no dash needed); SP1's line 7.2 m; SP2's 4.5 m line chases 2.33 m in its 16 f startup (to
4.10 m, under *ENDER-CHASE-MAX*) and reaches. Nothing changed.

**Gates (B2a).** The 22 existing pairings' `simgate --seeds 10 --summary` lines and `--cvc` byte-identical to the parent.
His 7 pairings at 10 seeds (NORMAL, P1 Hisagi): all 70 matches K.O.; medians HY 122.1, HK 108.3, HR 142.4, HI 167.5, HS
136.3, HB 140.2, HH 195.6 s; his wins as P1 2 / 1 / 1 / 2 / 0 / 1 of 10 (HH 5–5). The time-at-range probe (§6 targets:
1.8–6.5 m ≥ 45 %, < 1.8 m ≤ 40 % / ≤ 55 % vs Kenpachi, out of hand ≤ 30 %): < 1.8 m HY 39 / HK 52 / HR 46 / HI 52 / HS 42 /
HB 40 / HH 44 %; 1.8–6.5 m 55 / 42 / 49 / 43 / 52 / 53 / 50 %; out of hand 7–10 %. Misses: < 1.8 m vs HR, HI, HS, HH; 1.8–6.5 m
vs HK, HI. Per §6 the first lever is his AI ranges, then the user; not tuned in this batch (the plain CPU).

## 20. As built (batch B2b, 2026-10-17): the Bankai's rules, bookkeeping and CPU

`duel/lisp/hisagi.lisp` (the Bankai block after the Shikai's kit: moves, the two mode kits, the bind's bookkeeping, P,
the CPU, the debug scenes) and three data lines in `hisagi-art.lisp`. The Shikai's `:awaken-form :bankai`; B2a's seam
(the awakening gauge held 1 short, §19 D4) is gone. Every §17.1–§17.3 number is as the tables (pinned in
`tests/duel-rules-test.lisp`, section "Hisagi's Bankai"); the bind runs only through B1b's hooks (§17.4 "As built"),
nothing re-added. Knobs: the `*hs-r-*`, `*hs-b-*`, `*hs-kubi-*`, `*hs-bind-reel*`, `*hs-pull-*`, `*hs-saharai-*`,
`*hs-ai-…*` defparameters in hisagi.lisp (value, date, who).

**The look is not part of this batch** (the lead, relaying the user, 2026-10-17: the Bankai's art and every clip are
redone after a motion-style pass with the user). Built only what the sim and the FK reach test need: B2a's body and
sickles as they are; the Bankai moves play B2a's clips (J of the bind mode SEN / KAESHI-SEN / RIN at the same frames; the K
links the pulls' HIKI / HODOKI, which fall short of the K volumes as the FK test allows a K; SAHARAI the windmill's,
KUBIKAKE NAGE's, UNWIND MODOSHI's, …), except the ranged J: three minimal clips `:hs-r-q1` / `:hs-r-q2` / `:hs-r-spin` at
their own frames (12 / 11 / 13), with `*hs-strike-reach*` 4.0 / 4.0 / 4.4 and `*hs-flights*` entries, so HISAGI-DRAW throws
B2a's left sickle out to the arc's edge on the hit frames (the J's ±0.15 m; a host check ties the two tables). No orb,
crescent blades, noose, awakening cinematic or new art scene. The HUD's grey band, grey souls and pool tally are B1b's,
fed by `:bind-snapshot` / `:bind-pool` (seen in the debug stills below).

**What is built.**
- Forms `:bankai` (ranged, prefix `hs-r-`) and `:bankai-bind` (prefix `hs-b-`), both `:awakening t` (Kikon 3), standalone
  kits (not `:inherit`: a child's `:strings` add the parent's). One hook list for both (`*hs-bk-hooks*`: the bind's seven
  hooks, `:p`, `:p-label`, `:tick` HS-BK-TICK, `:ok`, `:command`, `:hit`, `:reset`, `:hash`, the draw). The mode follows the
  bind: HS-BK-TICK does the SET-FORM only when he is not in a move (after KUBIKAKE's cut recovery on entry; after UNWIND on
  either end; in a reaction at once).
- **KUBIKAKE** (P, `:hs-r-kubikake`): HS-P-PRESS starts it from idle / walk / guard / a run with his own 200, not cooling,
  no bind on the field (HS-KUBI-OK-P); otherwise the `:refused` cue and the press eaten. Cooldown 180 from the press,
  cleared by a hit. Its on-land: the yank to 2.0 m (12 f), the recovery cut to 14 from the hit (+16 on the 30 f reel:
  bind J1 S 8 and SP1 S 14 combo, K1 S 18 not; pinned), the 200 checked again; the bind is due that step and starts in
  HS-BK-TICK (after SETTLE-SOULS). A step that settled a Kikon / Soul Break started a cinematic, so the tick comes later
  and the stale hit binds nothing; both throws in one step (the mirror): neither binds.
- **The bookkeeping** (B0–B16) on the binder's `hss` component: the snapshot (both Reishi / Konpaku), the pool (both
  bars), the drain (`:bind-damage`, rules BIND-DRAIN, 1 per 2 nominal), SPs of either side from the pool (`:bind-pool`),
  real heals raise the snapshot (`:bind-heal`), the drained end at `:bind-step :hits` (HS-BIND-DRAINED!: both bars 0, the
  grey counts cleared, Soul Breaks queued opponent first), the release at `:bind-step :release` (HS-BIND-RELEASED!: the
  snapshot back, BIND-RELEASE-SPLIT 300 to the opponent first), the end effects (HS-BIND-END-EFFECTS!: hazards cleared,
  his 30 f reel, Hisagi's UNWIND 20 f), time-up (`:bind-resolve`: drained, the Soul Breaks' Konpaku counted, no
  cinematic). The frozen gains, grey HP / souls, Kenpachi's Bankai refusal and the learner's `dealt-real` are B1b's.
- **The release** KAIBAKU: P bound, from idle / guard / blockstun / a run at once, in hitstun / air under the Burst rule
  (Q9 A, HS-REL-FREE-P; not free: the press stays buffered); during his own move the press is consumed and held
  (`rel-held`) and fires on the move's last frame (HS-REL-DUE-P).
- Ranged L SAHARAI's push (hit 6.5 m / block 4.5 m, PUSH-APART), TSUISA's 3.5 m drag, KUSARI-AME's lane aimed 6 f then
  locked (its move `:tick` HS-R-AME-AIM restores the yaw), the SP2 copies off a J / K hit through `:command`; bind L
  HIKIYOSE moves the opponent 0.3 m a step toward him (motion only, added to his own) to 2.0 m, then R 8; refused within 2.5 m.
- **CPU.** Ranged: :moves at 0–2 / 2–4.2 / 4.2–7.8 / 7.8+ m, no SP from the table; HS-R-AI-REFLEX: L SAHARAI once per
  entry within 2.5 m (EASY 0.3 / NORMAL 0.6 / HARD 0.85), KUBIKAKE once per entry into 4–7 m with his 200 (0.2 / 0.45 /
  0.7); SP1 off a link 3 only above 300 (keeps the 200). Bind: a melee table; HS-B-AI-REFLEX: the release once per change
  event (a Konpaku changed, every 100 of the pool) when his grey loss (Konpaku × 1300 + Reishi) exceeds the opponent's by
  300 (0.3 / 0.6 / 0.9), else he lets it drain; L once per entry beyond 4 m; SP off a link 3 only when not behind (0.1 /
  0.35 / 0.7); the generic SP cancel off (`:sp-cancel-bars` 7). The opponents: HS-AI-OPP's side Step also on TSUISA, the
  ranged SP1 and KUBIKAKE (`opp-step-kubi`). Counters: the `duel hisagi` line (DUEL_GAMEPLAY "Debug commands", 83000).
- `:hash`: the bind's flag, the pool (×10), the snapshot, the release flags, KUBIKAKE's cooldown.
- Debug scenes 83010–83015 (DUEL_GAMEPLAY), knobs 83300+k / 83400+k, the `duel probe hisagi-bind` line.

**Deviations (the lead's, for review):**

| # | Doc | Built | Why |
|---|---|---|---|
| E1 | §11, §17.3 "what the user sees": the orb, the noose, crescent blades; a placeholder awakening cinematic | none: B2a's look; no `:cine` on `:bankai` (the awakening goes straight to neutral) | the user's art hold (above) |
| E2 | §17.3 KŌSHU "strike within 1.6 m" | its reach 2.0 m | the generic Kikon rule (host test): a module's reach > *KIKON-TRIGGER* 1.6 + 0.3 |
| E3 | B7 "Konpaku ≤ 0 with no event: K.O. (its own cinematic)" | such a fighter is queued a Soul Break with the others, so SETTLE-SOULS K.O.s him (the Soul Break's cinematic, then the finish) | one path, no second cinematic in the step |
| E4 | B9 "Hisagi's move ends into UNWIND" | not while he is airborne / down / waking (his fall stands, as the opponent's); the switch to ranged then waits until he is free | no move started mid-air |
| E5 | B16 "ENDLESS's stage start (`:endless-form :base`)" | `:bankai-bind`'s `:endless-form :bankai` (a stage starts in the ranged mode, no bind: a fresh fighter) | read as "no bind carried"; `:base` would undo his awakening |
| E6 | §17.3 L 引寄: "a Step's hop adds to the drag" | the drag moves his position directly each step, so any motion of his adds; a Hoho or a cinematic stops it | motion only, no slide slot shared |
| E7 | §17.5 #16 "while bound and behind, the opponents' CPU spends no SP unless it completes a combo"; the learner's "bound, ahead / behind" situations; ASSIST routes | not built | §15 "Later" (as B2a's D6) |
| E8 | the generic CPU's Kenpachi Bankai reflex in ai.lisp read `kit-bankai-ok` itself, so a bound Kenpachi lost his one roll to a refused press | ai.lisp's reflex also asks `(not (bind-of e))` | inert without a binder (the 21 pairings identical) |
| E9 | tests: the shared `hit-gap` helper read only the reaction's hitstun | it reads a window's `:stun` first (as `on-hit-adv` already did): the ranged J's hitstun 24 | the other forms' checks unchanged (ALL PASS) |
| E10 | — | the Bankai kits carry a draw-less kit meter (`hisagi-art.lisp`) | the HUD inherited the Shikai's sickle row onto the awakened forms' L COOLDOWN row (overlapping text); no sim reads it (his 7 pairings identical with and without it) |

**Host tests** (duel-rules-test 9699 checks, ALL PASS; the others unchanged, ALL PASS): both modes in the generic string
walk (`*forms*` + `(:hisagi :bankai)` / `(:hisagi :bankai-bind)`; the ranged mode's budget rows J1 S 11–13, K1 S 21–24,
the K links' S_eff 18), the FK reach walk, the §5 clip list; his section "Hisagi's Bankai": the tables, the six routes'
damage per mode (74 110 132 162 126 104 / 104 144 168 200 160 136), every link with its hitstop on both sides, SP1 / the
SP2 copies off J1 / K1, TSUISA's drag before J2s, link 3 → KŌSA, the 7.95 m push inside the lane / SP1, the 200 at the press
(199.9 refused, blockstun / stun / a move / cooling / a bind refused) and at contact (199: a plain hit), the +16 on the reel
(J1 / SP1 combo, K1 not), the side-Step cast check (2.5 m aside at 4 / 5.5 / 7 m clear of the 12° tracked line), the bind on
stand-ins through B1b's readers (the pool 430 = 250 + 180, the drain 7 → 426.5, a 2000 hit floors the Reishi with no Soul
Break, every gain frozen, either side's SP from the pool and refused under the cost, a heal raising the snapshot, a grey
Kikon with the bind going on, Kenpachi's Bankai refused, the release refused in a combo's 1st hit and taken from its 2nd,
held through his own move to its last frame, the release's restore and 426.5 → 300 / 126.5, the mode switched only out of a
move both ways, the drained end's order (the opponent's Soul Break first) and cleared grey counts, a Kikon victim with no
Soul Break on top, a grey 0 Konpaku K.O.'d, the release winning a same-step drain, the split at 0 / 150 / 300 / 450 / 600,
time-up as drained (the Soul Break's Konpaku decides it), one bind on the field, the stale hit, the mirror's double throw),
HIKIYOSE's drag (8 m → 2.0 m in 20 steps, then R 8; refused within 2.5 m), the SP2 copy by `:command`, the drawn reaches.

**Gates (B2b).** pkgcheck clean; `./build.sh duel` with the 4 known Lille warnings; the 21 non-Hisagi pairings'
`simgate --seeds 10 --summary` lines and `--cvc` **byte-identical** to the parent b43a2aa (`cmp`; the doc's "22" counts
the same 21 rows); a smoke run (`run.mjs`, scenes 83010–83015) exit 0, no exception. His 7 pairings at 10 seeds (NORMAL, P1
Hisagi), every match but one K.O.:

| Pairing | Median s (B2a) | P1 Hisagi wins | Binds / match | Ends drained / released / time-up | Bound s / match | Pool start → end / bind | Release split opp / self (sum) | Ranged time < 2 m / 3.5–9 m |
|---|---|---|---|---|---|---|---|---|
| HY | 144.3 (122.1) | 3 | 1.3 | 9 / 4 / 0 | 14.0 | 517 → 83 | 834 / 250 | 25 / 50 % |
| HK | 126.8 (108.3) | 6 | 1.7 | 11 / 6 / 0 | 17.9 | 514 → 77 | 1159 / 142 | 27 / 47 % |
| HR | 170.0 (142.4) | 7 | 2.0 | 15 / 5 / 0 | 28.1 | 472 → 69 | 1235 / 149 | 24 / 50 % |
| HI | 185.6 (167.5) | 7 | 1.8 | 11 / 7 / 0 | 25.8 | 524 → 75 | 1247 / 96 | 27 / 49 % |
| HS | 157.6 (136.3) | 6 | 2.3 | 17 / 6 / 0 | 27.0 | 447 → 44 | 947 / 71 | 19 / 59 % |
| HB | 202.3 (140.2) | 1 | 2.2 | 12 / 10 / 0 | 32.8 | 557 → 128 | 2322 / 495 | 23 / 54 % |
| HH | 236.4 (195.6), K.O. 9 / 10 (one time-out at 300 s) | 1 (P2 9) | 2.0 | 11 / 9 / 0 | 35.8 | 495 → 83 | 1599 / 54 | 13 / 66 % |

Grey dealt / taken per match (Hisagi): HY 445 / 574, HK 494 / 690, HR 722 / 590, HI 675 / 706, HS 658 / 613, HB 809 / 906,
HH 462 / 850. KUBIKAKE per 10 matches: thrown 54–92, hit 13–23 (never a plain hit), blocked 15–37, whiffed 17–37, the
opponents' side Step on it 6–17. The medians moved +5–62 s (the §17.3 estimate was +5–25 s; HB +62, HH +41 are the watch); the
time-at-range targets (§17.5 #12: ranged ≥ 45 % at 3.5–9 m, ≤ 40 % under 2 m) hold in all seven. Not tuned (the brief).

**Awaken A/B, a first look** (`--seed0 100 --seeds 20`, one stream). `--cmd 39020` (the gate's definition: Hisagi, P1, never
awakens): the never side wins HY 2, HK 2, HR 4, HI 0, HS 2, HB 0, HH 2 of 20 (the bar is a third: all seven fail; B2a's
Shikai alone already won 0–2 of 10 against the awakening roster). `--cmd 39002` (the opponent never awakens, Hisagi does: the
Bankai's side of §17.5 #18): Hisagi wins 20, 18, 16, 16, 10, 15, 18 of 20, so the never-awakened opponent wins 0–10 of 20:
the Bankai with the bind looks strong, the Shikai weak. Per §17.5 #18 the first knob would be the release cost; reported,
not tuned (the user's call).

### 20.9 Gates on main a55c913 (the lead, 2026-10-17; playtest Artifact v89 published first)

- His 7 pairings, 20 seeds (Hisagi P1): HY 144.3 s (10–10), HK 130.8 (9–11), HR 170.0 (10–10), HI 170.7 (10–9, 1 draw),
  HS 157.6 (11–9), HB 202.3 (2–18), HH 226.2 (6–14) — every cross median inside 125–210; HH (a mirror) has **2 time-outs**
  of 20 (KOs 18), the rest all K.O.
- G2 cvc: yy / yk / kk PASS (unchanged).
- **Awaken A/B, 60 seeds, three streams** (wins of the never-awakening side; pass ≥ 20):
  - `--cmd 39020` (Hisagi never awakens): seed0 100: Y 8, K 5, R 7, I 1, S 7, B 2, H 6; 300: 10, 3, 7, 2, 10, 2, 1;
    500: 11, 4, 3, 10, 7, 4, 4 — **all 21 rows fail**.
  - `--cmd 39002` (the opponent never awakens, vs an awakening Hisagi): seed0 100: Y 0, K 4, R 22, I 11, S 22, B 11, H 5;
    300: 0, 4, 22, 16, 24, 16, 2; 500: 0, 5, 23, 11, 17, 13, 6 — R / S pass on most streams, the rest fail.
- Reading: his Bankai decides the match; his never-awakened Shikai loses ~85–95 %. Not retuned: reported to the user.

## 21. Look and motion style: the skill pass that was skipped (the user, 2026-10-17)

> 「在開始建模前有先使用 skill 調查造型並設計動作模組嗎」

The lead's answer: only half. Done: the canon look research (notes §3, 21 reference images), the text model sheet
(§11.1), the move-set design (`duel-move-modules`). Skipped: the whole `duel-motion-style` pass (§11.2 stayed a draft
marked "to be confirmed with the user and researched before any clip") and model-sheet stills for the user. B2a's body
and clips are placeholders at the right reach (Kazeshini drawn as a large yellow blade: not canon).

Decisions (AskUserQuestion, 2026-10-17):
- 「B 先停卸解的外觀部分」: B2b builds the Bankai's rules, bookkeeping, CPU and tests only; no Bankai art until this pass.
- Source: **「A 原作神態＋自創招式」** (canon manner, invented strikes graded D and labelled as proposals).
- The bar (all four picked): **God of War's Blades of Chaos, real kusarigama-jutsu, the rope dart / meteor hammer,
  Rebirth of Souls' Hisagi**.
- Order: **one form at a time, the look before its strikes** (Shikai: model-sheet stills → slot plan → clips; then the
  Bankai the same way).
- **「距離跟著動作走」**: the drawn motion sets the hit volumes, so the redraw is a sim change (gated against a parent
  baseline), not presentation only.

Research done: `docs/research/hisagi/motion-refs.md` (graded A–D; the Shikai slot proposals §3.1, the Bankai's §3.2–§3.3;
the model-sheet facts §4). It corrects §11.1: the Kazeshini rod is ~0.9–1.0 m (D, measured on ch. 324–325), not ~0.5 m.

Decisions on the research (AskUserQuestion, 2026-10-17):
- **The rod at canon length, gripped near the blades** (「A 照原作柄長，握在靠刀的那端」): a short reverse grip in the J
  strings, so J stays at 1.4 m (Q5 A) while the rod is drawn ~0.9–1.0 m.
- **The neck-noose over-the-shoulder heave and slam (canon Kubikake, Ep225) goes to SP2 全身縛** (「B 給 SP2 全身縛」, not
  the lead's recommendation); the Breaker becomes a front garrote and a push-down.

Next: the Shikai model-sheet stills (front / side / back, the weapon close-up, presentation only), then the slot plan for
the user's 「可以」.

### 21.1 Model-sheet review (the user, 2026-10-17)

> 「鐮刀兩側的新月彎鉤應該要是相反方向，一個朝內一個朝外」

- The look batch's first stills (branch `worktree-agent-a3187ff2a108e4b0a`, not merged) drew one crescent across the rod
  with both tips swept back. The user: the two hooks curve in **opposite directions**, one inward (toward the holder),
  one outward (away from him), an S / pinwheel through the rod. Being redrawn on the same branch; the rest of the sheet
  (69 in blue, the sash knot, the chain's slack, the badge without its flower, the stripe colour, the arm-band heights)
  drew no objection.

### 21.2 Look as built (the Shikai, 2026-10-17)

Approved by the user (2026-10-17: 「這版沒問題」) on the v2 sheet (the opposite hooks); merged as presentation only
(his 7 pairings at 20 seeds byte-identical, cvc 3 PASS, host tests 9699 ALL PASS).

Presentation only, all in `duel/lisp/hisagi-art.lisp` (the body, Kazeshini, the chain's look, debug scenes): no clip,
move, knob or hurt volume changed. Grades as in the research (A canon still / text, B official game, D the lead's own
reading or a guess for the user to check).

| Item | As built | Grade |
|---|---|---|
| Build | scale 1.0 (1.81 m), width 0.94, the shared rig; hurt r 0.36 / h 1.8 kept | A (notes §3) |
| Hair | TYBW: a ragged fringe of five strands over the brows (one down the bridge of the nose), locks over the ears to the lobes, spikes up and back, the nape | A (`Ep370…`, `520.5…`); the strand layout D |
| Scars | three parallel lines from the brow straight down over the right eye to the cheek | A |
| Stripe | blue (#3F6EA8) from the right eye's inner corner across the bridge of the nose to the left cheek's edge, wrapping round it | A (`520.5…`, `ros_hisagi_trailer_thumb`); the hue D |
| 69 | on the left cheek under the stripe's end, **blue** (as the TYBW anime and RoS; the manga inks it black), readable from the front | A placement; the colour D |
| Choker | black band with five white studs | A |
| Arm bands | black, five white studs each, mid upper arm (right) / above the elbow (left, under the badge) | A (ch. 324); the height D |
| Badge | a khaki shield with 九 in three ink strokes, tied with white cloth on the left upper arm | A (anime sheet, RoS); the 9th-squad flower omitted (D: too small to read) |
| Top | sleeveless black, a white trim at the arm holes, a deeper V of the white under-collar | A |
| Sash | white, its knot and two hanging ends at **his right front** (the brief said "front-left": every image, `325…`, `Hisagi_Anime_Fullbody`, `ros_hisagi_ill`, Ep219, draws it on the viewer's left) | A |
| Scabbard | the sealed sword's empty blue-black scabbard (#1E2A48) in the sash at the left hip, 0.72 m, the end down, back and out | A (`325Hisagis_Shikai_Kazeshini`); the angle D |
| Hakama, feet | wide black hakama (three pleat lines), white tabi on straw waraji (a sole and a thong) | A |
| Kazeshini rod | black, 0.97 m: the forked butt (where the chain fixes) 0.22 m behind the fist, the point 0.75 m ahead (the defweapon `:length` the FK test reads: unchanged, so every J tip is as before) | A shape; the length D (measured on `324` / `325`) |
| Grip | the stance grip only: overhand near the butt (the rear fifth). The J strings' grip near the blades (§20, the user's 「握在靠刀的那端」) comes with the slot plan's clips | A (stance) |
| Blades | two crescents leaving the rod 0.5 m ahead of the fist on opposite sides, one on each face of it, **hooked in opposite directions** (v2, the user below): the edge-side one curls back toward him, the other forward (its tip at 0.68 m, behind the rod's point at 0.75), an S / pinwheel point-symmetric about the crossing, tip to tip 0.92 m; each 0.075 m wide at the root, pointed, the outer 40 % of its curve white-silver (#D4D8E0), the inner black | A (`324`, `325`, Ep219, the wiki's "one inverted"; the user's v2 call); the exact 3D layout D |
| Chain | butt to butt with 1.2 m of slack at rest (a parabola, its lowest link 3 cm off the floor: it loops to the shins), links along the curve; thrown: from the right butt to the flying sickle's butt | A (stills: it loops low); "1.2 m of slack" read as length beyond the span (D) |
| Green Reiatsu | none on the weapon or body at rest (canon shows it only as the release's outline glow and in the effects: TSUZURI RAIDEN's jade bolt kept) | A |
| B2a's "large yellow blade" | not found in his own draw: B2a's Kazeshini was a 0.75 m dark spiked stick with two small dark blades (replaced); the yellow in his match frames is Kenpachi's aura and the shared hit spark, unchanged | — |

**v2 (the user, 2026-10-17, on the stills):** 「鐮刀兩側的新月彎鉤應該要是相反方向，一個朝內一個朝外」: v1 drew one crescent with both tips swept back; v2 turns the second blade 180° about the crossing, so one hook curls in (toward him) and one out (away from him). Only the blade geometry (`*hs-crescent*`, HS-MB-CRESCENT) changed: the rod, the grip, `:length` 0.75 and every reach as before. The portrait weapon close-up got its own shot (`*hs-look-weapon-tall*`, the whole weapon in frame). Re-proved: `simgate --seeds 10 --summary` byte-identical to the parent, the `--cvc` PASS lines identical, duel-rules-test ALL PASS, pkgcheck clean, the build with the 4 known Lille warnings, debug 83901 0 B. Stills: the v2 weapon close-up, front, 3/4 and side in both aspects (contact sheet `hs-look-sheet-v2.png`).

**Stills** (`tools/run.mjs --fixed-dt 16.666667`, 1280×720 and 720×1280): debug 83980–83985 (DUEL_GAMEPLAY "Debug commands":
him alone on a white card in a 4 s cinematic shot: front, his left side, back, three-quarters, face, Kazeshini held out)
and 83000 / 83001 (the match, the behind camera, 2 / 6 m from Kenpachi); before / after pairs against B2a. Known: the
portrait weapon close-up frames his chest (the shot's aim is halved on a tall screen) and cuts the weapon off (fixed in v2); the
landscape one is the reference.

**Proofs.** `simgate --seeds 10 --summary` byte-identical to the parent (`cmp`, all 57 lines) and `--cvc`'s three PASS
lines identical (yy / yk / kk; the after run alone printed the native rebuild's banner line); duel-rules-test ALL PASS
(the FK reach test unchanged: the same `:length`); pkgcheck clean; `./build.sh duel` with only the 4 known Lille
warnings; debug 83901 0 B in every case (the stance's slack chain included).

**For the user (D items above):** the 69's colour (blue vs the manga's black), the sash knot on his right, the stripe's
blue, the crescents' 3D layout, the chain hanging to the shins.

### 21.3 The Shikai's slot plan (approved: the user, 2026-10-17: 「可以」)

The plan shown to the user is `docs/research/hisagi/motion-refs.md` §3.1 (stance / walk / run; J1 旋, J2 返旋, J3 輪 and the
one-handed SEN-1H / KAESHI-SEN-1H (reverse-grip backhand ↖) / RIN-1H (arm-length 200° pivot); K1 投 (vertical wheel tell,
hip cast, flat spinning disc), K2 引 (drop and pull), K3 刈落 (Blades of Chaos overhead split drop, ±60°), 戻 (hand over
hand); MAKI (elbow-wrapped curling throw), HODOKI (turn inside the chain, over-the-shoulder heave); L 風車 (overhead fan,
the push widening to 2.0 m at the waist); SP1 綴雷電 (overhand cast ↘, lightning down the taut chain); SP2 全身縛 (lasso,
then the canon over-the-shoulder heave and slam: §21's pick); O (the whirl past his face, a flat disc along the lane, the
zip along the chain, the finish from behind); intro (the sealed blade across the face, 「刈れ」, tossed up and split); win
(looking at his blade)), with one change from the research: **the Breaker is a front garrote, a push-down and the pin, no
over-the-shoulder throw** (the heave is SP2's). The J strings use the short grip near the blades (J reach 1.4 m).

Reach follows the motion (§21): drawn to the current volumes; each strike's tip measured (FK ±0.15 m, cast checks for the
segment windows); any strike that would leave its volume is reported to the user with numbers before a volume changes.

### 21.4 Shikai clips as built (batch B3a, 2026-10-17)

The §21.3 plan drawn as the Shikai's own clips, all in `duel/lisp/hisagi-art.lisp` (prefix `:hs-s-`), to the **current**
hit volumes (the user: reach follows the motion, but this plan is drawn to the volumes as they are): **no sim change**. The
base kit plays them through its `:clip-map` (`*hs-shikai-clips*`, hisagi.lisp), its walk through `:look-clips`
(`*hs-shikai-looks*`), its run set through `:run-clips`; `:stance` / `:intro` / `:win` name them; KAESHI-SEN-1H and RIN-1H
name their own clips in their `defmove-copy` (`:clip`, a look). The Bankai's two forms keep B2a's clips untouched (their
art waits for their motion-style pass); B2a's MAKI clip, played by no form any more, is gone.

**Machinery (a look, 0 B a frame).** A kit `:pose` hook HS-POSE (on every form, inert outside the Shikai's clips): the J
strings' **short grip** (`*hs-grip*`: the right rod slid 0.25 m back through the fist, so he holds it just behind the
blades' crossing, eased in at 4 m/s; the point 0.50 m ahead of the fist, the butt 0.47 behind) and the right sickle **let
out on its chain** (`*hs-letout*`: the `:weapon-r` joint moved where it flies). HISAGI-DRAW draws the left sickle's let-out,
the chain through the holding fists (the right rod's butt → the left fist → an out sickle: the thrower's hand), the thrown
sickle as a flat spinning disc (its far edge within +0.12 m of the volume's), MAKI's curl, the pull's tail (the sim hand →
the left fist), SHIBARI's wrap, KUBIKAKE's slack through the victim's neck, the windmill's circle, and nothing for the
left while the sealed sword is in hand (the intro's `:intro-weapon` `:hs-sealed`, a plain 0.72 m katana, to f70). A let-out
sickle's point is placed at the strike's volume edge on its hit frames by construction (R m from his feet along the fist's
bearing or a set bearing), so its clip is in `*hs-strike-reach*` and the FK test reads that reach; the FK test subtracts the
grip for `*hs-grip*` clips (`tests/duel-rules-test.lisp`). Debug: 83910–83964 the strips (DUEL_GAMEPLAY), 83901 the
consing probe (both hooks, 15 states).

| Slot | Clip | S/A/R | Measured strike (hit frames) vs volume | Notes / deviations |
|---|---|---|---|---|
| stance | `:hs-s-stance` (loop 2 s) | — | — | weight back, right rod low-forward (point 0.28 m up by the right shin), left rod down at the hip, the chain loop |
| walk / strafe | `:hs-s-walk-f/-b`, `:hs-s-strafe-r/-l` | — | — | the shared legs under his stance's arms (the shared ones had the generic stance's arms) |
| run set | `:hs-s-run`, `-skate-b`, `-slide-r/-l` (DEFRUN) | — | — | both rods held back low and level behind the hips |
| J1 旋 SEN (and SEN-1H) | `:hs-s-sen` | 8/3/12 | rod point **1.34 m** (S; 1.32 / 1.25 on A) vs arc 1.4 / 110° (−0.06); the leading hook 1.40 | short grip 0.25; wound right (the tell f4), the skid in, flat R→L at chest height, the left rod back at the hip |
| J2 返旋 KAESHI-SEN | `:hs-s-kaeshi` | 8/3/13 | the left sickle let out to **1.40 m** on f8–11 (by construction) vs 1.4 | out f3–18 on the left arm's rising line (low left → over the right shoulder); the right rod drawn back, short grip |
| J3 輪 RIN | `:hs-s-rin` | 9/3/18 | both sickles let out to **1.40 m** f6–12 vs 1.4 / 200° | a full turn to his left (root yaw −30 → 60 → 150 → 245 → 330 at S → 400), a key ~90°; at S the right one sweeps his front, the left one behind; ends square |
| KAESHI-SEN-1H | `:hs-s-kaeshi-1h` | 8/3/13 | rod point **1.32 m** (S; 1.26 on A) vs 1.4 (−0.08) | short grip; "reversed" drawn as the forearm rolled half a turn (the other hook leading), not a back-pointing reverse grip (that would reach ~0.4 m: the FK test caught it); a rising ↖ from the right hip over the left shoulder |
| RIN-1H | `:hs-s-rin-1h` | 9/3/18 | rod point **1.38 m** (S) vs 1.4 | the stance grip at a slightly bent arm; a 200° pivot (yaw −70 → 0 at S → 100), then unwound over R |
| K1 投 NAGE | `:hs-s-nage` | 18/4/22 | the flight's point at **6.3 m** (by construction) vs the 6.0 line + 0.3 | the vertical wheel at his left side (f0–12, keys 90° apart; 180° written as −180 at f6 so no blend spins the arm round), cocked low-back, the hip cast: left fist 0.87 m ahead, 1.12 m up at S; the disc spins flat |
| K2 引 HIKI | `:hs-s-hiki` | 20/4/24 (link f6) | segment window: the chain drawn on HS-CHAIN-SEG; the guiding right fist at 0.45 ahead / 1.16 up / 0.20 right vs the sim hand (0.45, 1.10, 0) | the drop and lean back, the left hand hauling down past the hip; the chain's tail on to the left fist |
| K2s 巻 MAKI | `:hs-s-maki` | 20/4/24 (link f6) | the flight's point at **3.55 m** vs the 3.2 line + 0.35 | the forearm wind (f11), wound left, the sideways release; the flight bowed 1.1 m out to his left midway (the curl) and on the line at S |
| K3 刈落 KARI-OTOSHI | `:hs-s-kari` | 22/5/34 (link f8) | both sickles let out to **2.8 m at ±60°** (0.3 m up) f22–30 vs arc 2.8 / 120° (its two edges) | crouch (tell f12), the hop (f16–19, arms overhead), both swung over his head (a 1.8 m arc) and down; landed bent over them, held to f40 |
| K3 解 HODOKI | `:hs-s-hodoki` | 22/5/34 (link f8) | segment window: the chain on HS-CHAIN-SEG, its tail from the sim hand to the left fist | the turn inside the chain (yaw −70 / −120 / −160, his back to the foe at S), both hands heaving it over the right shoulder, round to face him over R |
| 戻 MODOSHI | `:hs-s-modoshi` | 6/0/6 | no hit | left pull, right pull, the catch at f6 with a twirl |
| L 風車 KAZAGURUMA in / push / loop / out | `:hs-s-kaza` (one clip, its phases) | 6/60/14 | the push's point on **r 2.0 m** at 0.95 m up f6–9 vs 360° r 2.0 | let out low (f0–6), the push, lifted into the fan (1.6 m round, 2.3 m up, a turn in 12 f, the wrist's circle keyed every 3 f), the right rod across his face; out: lowered and caught (the release jumps the clip to f66 as before) |
| SP1 綴雷電 | `:hs-s-raiden` | 20/3/24 | the flight's point at **6.8 m** vs 6.5 + 0.3 | the overhand cast from above the left shoulder (cocked f15), the left fist high (1.36 m) on the taut chain, the right hand's fingers on it |
| SP2 縛 SHIBARI | `:hs-s-shibari` | 16/34/26 | the flight's point at **4.85 m** vs 4.5 + 0.35; on contact drawn wrapped at the victim | the lasso (f4–13), the cast (S), taut, the turn and the over-the-shoulder heave (f32–44), the slam f46 bent double; round again over R |
| Breaker dash | `:hs-s-breaker` (loop 0.4 s) | — | — | low, both rods back |
| 首掛 KUBIKAKE | `:hs-s-kubikake` | 8/4/18 | rod point **≤ 0.75 m** on f8–11 vs the Breaker's 1.35 (short is allowed; the grab is the chain round the neck) | the user's front garrote: the rods held up (butts forward) and brought down round his neck (the slack drawn through it within 1.8 m), the push-down, the pin (down on the right knee, the left hand at his throat, the right sickle raised point down) |
| O 刈 aura | `:hs-s-kari-aim` (loop 0.5 s) | — | — | the overhead whirl, passing across his face |
| O strike / follow-up | `:hs-s-kari-o` | 20/2/30 | the flight's point at **8.0 m** vs the 7.0 lane + 1.0 | the whirl let down, a sidearm flat release (the disc); the follow-up's dash drawn hooked in him (the chain taut), its strike as a close cut (the sickle stays in hand) |
| intro | `:hs-s-intro` (2 s) | — | — | the sealed sword up across his face, held (「刈れ」), tossed at f66–70, both sickles let out above him (f70–84) and caught (f96–98) |
| win | `:hs-s-win` (2 s) | — | — | the half-step back, looking at the blade in his hand |

No slot was held back: every strike is inside its volume ±0.15 m (the J's FK 1.32–1.38 for 1.4; every let-out and flight at
its edge by construction). Held for later (not in the plan's scope): dust on KARI-OTOSHI's landing and SHIBARI's slam (the
shared hit effects play); the Kikon cinematic still plays B2a's `:hs-kari-o` (§11.5's storyboard is its own batch).

**Proof.** `simgate --seeds 10 --summary` (all 57 lines, every pairing with his) and `--cvc` byte-identical to the parent
(`cmp`); `duel-rules-test` ALL PASS (the FK reach test with the grip correction and the new clips); pkgcheck clean;
`./build.sh duel` with the 4 known Lille warnings; debug 83901 0 B in all 10 states (the first build's 8–16 B a call came
from float reads and `f32` in HISAGI-DRAW's plain code: moved into `%hs-geo!`).

**For the user's eyes** (checked by numbers, the strips and match stills): the short grip's look; J3's two sickles let out
(the plan's "both"); KAESHI-SEN-1H's "reversed" as a rolled forearm; HODOKI and SHIBARI turning his back (canon heave);
the windmill's sickle starting behind him; KUBIKAKE's garrote read without the victim in the strips.

### 21.5 The Bankai's look pass starts (the user, 2026-10-17: 「先開始卍解吧」)

The Shikai's look and clips are in (§21.2–§21.4); the awaken A/B question (§20.9) waits on the user's playtest. The
Bankai follows the same order (§21: the look before its strikes): model-sheet stills (the chain coiled round the neck
and the right arm, the twisted chain rope rising from the neck to the orb, the black crescent blades on dark rods, the
jet-black orb of chains overhead (size a proposal: canon gives none), the noose between the two fighters in a bind),
then the slot plan (`motion-refs.md` §3.2–§3.3) for the user's 「可以」, then the clips. Presentation only.

- Blade shape (the user, 2026-10-17: 「不是 卍解的刀造型跟始解一樣」): the Bankai's blades are the Shikai's Kazeshini
  blades, the S-pair crescents (§21.1: one hook in, one out), on both hands; not the single crescent of the CFYOW
  illustration and Brave Souls that the brief had guessed.
- The orb and its chains (the user, 2026-10-17: 「鎖鏈球可以高到超出鏡頭，自身周遭有許多從鎖鏈球垂下來的鎖鏈，其中有數條鎖鏈捆成束後捆在自己（與對手）的脖子上」):
  the orb may sit high enough to leave the match camera's frame (it is not shrunk to fit); many chains hang down from it
  all around him; several of them gather into a bundle tied round his neck (replacing the single twisted rope), and in
  a bind a bundle the same way round the opponent's neck (the noose). The hanging chains stay thin and sparse enough
  not to hide the fight from the behind camera. Cosmetic only.
- Where attacks launch (the user, 2026-10-17: 「攻擊可以從周遭垂下來的鎖鏈或自己頸部的鎖鏈發動」): the Bankai's attacks may
  start from the chains hanging round him or from his own neck bundle, not only from chains on his hands or from the
  orb. The draft slot plan (`motion-refs.md` §3.2–§3.3) is revised for it before it goes to the user; hit volumes are
  unchanged (a hanging chain ends near the floor beside him, so it arrives on the 1.1 m caps more naturally than a chain
  from the orb).

### 21.6 Bankai look as built (2026-10-17)

Presentation only, both modes (`:bankai`, `:bankai-bind`): no clip, move, knob, hurt volume or rule changed; the Bankai's
moves still play B2a's clips (their slot plan comes after the user has seen these stills). All in
`duel/lisp/hisagi-art.lisp` ("the Bankai 風死絞縄's look") plus the two kits' `:body` in `hisagi.lisp`.

The user's decisions during the batch (relayed by the lead, 2026-10-17):
- 「不是 卍解的刀造型跟始解一樣」: the Bankai's blades are the Shikai's Kazeshini, the S-pair (one hook in, one out), not
  the single long crescent of the Brave Souls / CFYOW art. The kits keep `:weapon :kazeshini`; nothing redrawn.
- 「鎖鏈球可以高到超出鏡頭，自身周遭有許多從鎖鏈球垂下來的鎖鏈，其中有數條鎖鏈捆成束後捆在自己（與對手）的脖子上」: the orb may
  leave the frame; many chains hang from it round him; several gather into a bundle tied round his neck (and, in a bind,
  the opponent's). This replaced the single twisted rope of the first pass.
- 「攻擊可以從周遭垂下來的鎖鏈或自己頸部的鎖鏈發動」: the Bankai's attacks will launch from the hanging chains or his neck
  bundle (for the slot plan): the hanging chains end close round him at waist-to-floor height, and the neck bundle has a
  slack tail.

Grades as in §21.2 (A canon still / text, B official game, D the lead's own reading or a guess for the user to check).

| Item | As built | Grade |
|---|---|---|
| Body | `:hisagi-bankai`, a `body-variant` of `:hisagi` (the same rig, scale and hurt cylinder r 0.36 / h 1.8: the sim can't tell them apart) adding his chain coiled round the **neck** (3 turns, 33 links, r 0.062 m, over the choker) and the **right upper arm** (3.5 turns, 40 links) and **forearm** (4 turns, 40 links, to the wrist); links alternately flat and edge-on, every fourth a steel glint (#5A5A66 on #1A1A20) | B (`BBSHisagi_s_Bankai`) + A (via C) "wrapped in his own chain"; the turns and link size D |
| Blades | the Shikai's Kazeshini in both hands, as §21.2 (S-pair crescents, rod 0.97 m, `:length` 0.75) | the user's call (above) |
| Green Reiatsu | none added at rest (the Shikai's rule: green only in the effects, e.g. TSUZURI RAIDEN's bolt) | A |
| The orb | `:hs-orb`, a mesh: a jet-black core (#09090C, r 0.8) wound with 11 loops of chain (28 links each, r 0.84–0.92, planes the golden angle apart: a tangle), drawn ×1.7 (**~1.6 m round, ~3.2 m across**: larger than him, as Brave Souls draws it), turning 0.25 rad/s, swaying ±0.1 m | A (via C) "a jet-black orb made of chains" + B (Brave Souls: larger than him); the size D |
| Its place | centre **8.0 m up**, 1.5 m to his right; the ranged mode: 0.5 m behind him; a bind: over the pair's midpoint (§11.4); eased at 2.5 /s on a mode change, placed at once on a jump > 8 m. From the behind camera at 2 m and 6 m it is out of frame in both aspects (the user's 「可以高到超出鏡頭」): only its chains come down into the picture; the model sheet's wide shot (83991) frames it whole | D (the lead's proposal; canon gives no size or height) |
| The curtain | 8 chains hanging from the orb's underside round him (`*hs-curtain*`), moving with him: four at his left (bearings 70–150°), four at his right (210–290°), **none ahead** (the opponent) **and none behind** (the behind camera's line of sight); every free end **1.45–1.7 m from his feet at 0.3–0.95 m up** (waist to floor: a later clip can snap one out level at 1.1 m); a slow sway | the user's 「自身周遭有許多從鎖鏈球垂下來的鎖鏈」; the count and layout D |
| The neck bundle | four chains twisted together (3 turns, tight 0.05 m at the bottom, fanning to 0.45 m under the orb) from the orb down to a knot 0.24 m above and 0.2 m behind his neck (clear of the head), then each of the four to one side of his neck (over the body's neck coil); a **slack tail** (sag 0.15 m) from the back of his neck to his lower right back | the user's 「數條鎖鏈捆成束後捆在自己…的脖子上」 + A picture (CFYOW: a thick twisted rope from the neck); the tail D (for the attacks from the neck) |
| The noose (bind) | the same four-chain bundle from the orb to a knot behind the opponent's head and tied round his neck, plus two rings of links round it (20 links, r 0.085 m) | the user's 「（與對手）的脖子上」; §17 |
| Inverted shadow | a pale additive patch on the ground under the orb (r 1.9 m, soft-edged: it reads as a pale ring) | A (via C) "shadows as if they were beams of light"; the look D |
| Not done | the green spark up the payer's chain on a hit, the greyer world grade, each side's cover overlay (§11.4), the awakening cinematic (§11.5): later batches | — |

Machinery: HISAGI-DRAW calls `%hs-orb-draw` on the Bankai's forms only (`%hs-bundle`, `%hs-tie`, the orb's place in
`*hs-orb-v*` per side); every float through f32vecs, the chains through VFX-HS-CHAIN (a long hanging chain is drawn in two
pieces: its 48-link cap spans ~5.8 m). Knobs: `*hs-orb-scale*`, `*hs-orb-h*`, `*hs-orb-side*`, `*hs-orb-back*`,
`*hs-curtain*` (hisagi-art.lisp, a look). Debug: 83986–83994 (DUEL_GAMEPLAY "Debug commands"); 83901 also measures the
Bankai and the bind.

**Stills** (`tools/run.mjs --fixed-dt 16.666667`, 1280×720 and 720×1280): 83986–83991 (front, his left side, back,
three-quarters, Kazeshini held out, the wide shot of the orb), 83992 / 83993 (the ranged mode in the match, behind camera,
2 / 6 m), 83994 (a bind at 2 m); contact sheets per aspect.

**Proof.** `simgate --seeds 10 --summary` (all 56 lines, his 7 pairings included: every awakened match draws the new body)
and `--cvc` (yy / yk / kk PASS) byte-identical to the parent aa731c1 (`cmp`, the `[simgate] building` banner aside);
duel-rules-test 9699 checks ALL PASS (the FK reach test unchanged: the same rig, weapon and `:length`); pkgcheck clean;
`./build.sh duel` with only the 4 known Lille warnings; debug 83901 0 B in every state, the Bankai and the bind included
(the first call after a scene grows the fx vertex buffer once, 131 KB at its SHIBARI row, because the probe piles 120 looks
into one frame: 0 on the repeat; the match's cons/frame ~10 KB as the parent's). Cost to watch: the curtain and the
bundles are ~1000 ink shards a frame (two bundles in a bind); SwiftShader stills render visibly slower (a phone check
belongs to the playtest).

**Known from the stills:** in the portrait match at 2 m a curtain chain (his right curtain, seen from behind) crosses the
opponent's body; landscape keeps the fight clear. The hanging chains read as dotted ink links (VFX-HS-CHAIN's look, as the
Shikai's chain).

**For the user (D items):** the orb's size (~3.2 m across) and height (8 m: never in the match frame; only its chains
are); the curtain's count (8) and its gaps ahead and behind (so it never stands between the camera and the fight); where
the hanging chains end (1.45–1.7 m out, 0.3–0.95 m up); the bundle of four chains and its knot behind the head; the slack
tail; the light patch reading as a ring; the coil's link size on the arm.

**The user's verdict (2026-10-18): 「可以 但我希望鎖鏈是黑色的」.** Every D item above stands as built. The chains turn
solid black: the toon INK palette always draws a white value-opposite edge and a white core (STYLE_STORM_DESIGN, user
review 2) plus VFX-HS-CHAIN's steel glint, so the Bankai's chains (the curtain, both bundles, the noose ring, his hand
chains in both Bankai forms) draw each link as a solid black kite in the alpha batch instead (`%HS-BLACK-KITE`: uv 0 is
opaque and unshaded, near-black, no edge; `*HS-CHAIN-BLACK*` set by HISAGI-DRAW outside the Shikai and by
%HS-ORB-DRAW). Their half-widths are x0.7 the ink links' (0.028 / 0.013 m), because solid black reads heavier. The arm
coils and the orb were already black meshes. The Shikai's chain keeps the ink look. The engine's palettes are untouched,
because a 17th palette would collide with the fan flag at 16. Proof: the same identity checks, debug 83901 0 B.

### 21.7 The Bankai's slot plan (approved: the user, 2026-10-18: 「可以，記得動作要配合誇張而明顯的前搖，來呈現出充滿張力的打擊感」)

The plan is `motion-refs.md` §3.2 (the ranged mode, re-sourced per §21.5: K1 / K2 / L / KUBIKAKE from the hanging
chains, O 降鎖 from the neck bundle, J3 sweeps the nearest hanging chains, K3 / SP2 from the orb, J1 / J2 / SP1 / the
Breaker as tabled) and §3.3 (the bind mode, K2 from a hanging chain instead of the arm coil), with the CFYOW idle
(standing still, arms hanging, the crescents point-down). Hit volumes and frame data unchanged.

The user's direction for every Bankai clip: **exaggerated, obvious anticipation (前搖) for a tense, heavy hit.** In
this presentation-only batch that means the clip's anticipation fills the move's existing startup (`:s` frames; the
ranged mode's are already long, §17.1). Each windup gets a big readable pose held near its peak:
- the arm drawn far back, the body coiled away from the line;
- the crescent raised high;
- the hanging chain hauled up and taut;
- the neck bundle lifted.

Then a sharp release on the strike's first active frame (few in-betweens, overshoot) and a held follow-through
(the ink style's anticipation → snap → hold, `procedural-ink-style`). No frame data moves. If a move's startup is too
short to carry a readable windup, report it with its numbers instead of changing it.

### 21.8 Bankai clips as built (batch B3b, 2026-10-18)

> 「可以，記得動作要配合誇張而明顯的前搖，來呈現出充滿張力的打擊感」 (the user, 2026-10-18, approving §21.7's plan)

The §21.7 plan (motion-refs §3.2 with its revision, §3.3) drawn as every Bankai move's own clip, both modes, all in
`duel/lisp/hisagi-art.lisp` ("the Bankai's clips"; prefix `:hs-k-` the ranged mode, `:hs-kb-` the bind), to the **current**
hit volumes: **presentation only**, no frame data, volume, knob or rule changed. The moves name their clips (`:clip` /
`:clip-2` in hisagi.lisp); the shared Breaker through the two kits' `:clip-map` (`*hs-bk-clips*`), the walk through
`:look-clips` (`*hs-bk-looks*`), the run set through `:run-clips`, the idle through `:stance`; both modes share the idle,
walk and run. B2a's placeholder clips the Bankai played are deleted (`:hs-q1` … `:hs-kari-aim`, `:hs-r-q1/q2/spin`, their
`*hs-flights*` / `*hs-strike-reach*` entries); `:hs-kari-o` stays for the Kikon cinematic (§11.5's storyboard is its own
batch), `:hs-stance` / `:hs-intro` / `:hs-win` for the scenes and the forms' intro / win.

**The windup rule** (the user's line above, §21.7): each clip reaches a big pose early in the startup and **holds it near
its peak** (a second key a few degrees further, so it never freezes dead): the arm drawn far back, the body coiled away
from the line, the crescent raised high, the source chain hauled up taut or into his fist. Then the hit pose is
**snapped** in on S (`:snap`: linear, from the held key 2–3 frames before; the chain itself jumps on S with no
in-between), an overshoot through the active frames and a held follow-through key before the recovery's return to the idle.

**Machinery (a look, 0 B a frame).**
- The crescents on their hand chains: `*hs-letout*` (§21.4's), now read in every form (HS-POSE joins the Bankai's hooks;
  HISAGI-DRAW's left let-out is no longer Shikai-only).
- **Chain strikes** `*hs-bk-chains*` (clip, source, f0 f1 f2 f3 f4, r, h, az0 → az1, lift, flags), drawn by
  `%hs-bk-strike` inside `%hs-orb-draw` in black (§21.6). Source 0–7 is a hanging chain of `*hs-curtain*` (that curtain
  chain is then not drawn at rest), 8 the neck bundle's tail, 9 a chain dropped out of the orb. Windup (f0 → S): the free
  end hauled up and drawn in, taut, or into his right / left fist (flags 4 / 8), or whirled overhead (flag 2), held near
  the peak with a tremble. S: the free end on the strike point (R m from his feet at H m up, az off his facing, swept to
  az1 by f2); a hanging chain hangs to its rest end and then runs level out to it; the neck bundle goes over his right
  shoulder. Held to f3, home by f4; flag 1 hooks it in the victim's neck on a hit (TSUISA's drag, KUBIKAKE's yank).
- `*hs-bolts*`: TSUZURI RAIDEN's bolt runs from 0.5 m to each form's volume edge (the Shikai's 6.5 unchanged).
- KŌSHU's garrote: the Shikai KUBIKAKE's slack through the victim's neck, from S, within 2.1 m (a new `%hs-geo!` flag 16).
- UNWIND: the noose's ring slides down off the opponent and widens over the 20 f (`%hs-orb-draw`'s bound code 2).

| Move | Clip | S/A/R | Source / what strikes | Windup (held) | Measured tip on the hit frames vs the volume edge (debug 83902) |
|---|---|---|---|---|---|
| idle (CFYOW) | `:hs-k-stance` (loop 3 s) | — | — | standing straight and still, arms hanging, the crescents point-down | — |
| walk / run | `:hs-k-walk-f/-b`, `-strafe-r/-l`; `:hs-k-run`, `-skate-b`, `-slide-r/-l` | — | — | unhurried (1.1 s cycle), arms hanging; the run with the arms back | — |
| J1 鎖鞭 | `:hs-k-saben` | 12/3/12 | right crescent on its chain, lashed R→L | coiled right on the back foot, right arm drawn far back (f5–10) | 4.00 4.00 4.00 vs arc 4.0 |
| J2 返鞭 (+J2s) | `:hs-k-kaeshi` | 11/3/13 | left crescent lashed back L→R | the mirror, coiled left (f5–9) | 4.00 ×3 vs 4.0 |
| J3 旋鎖 | `:hs-k-sensa` | 13/3/18 | both crescents at full chain, a half-turn cyclone; hanging chain 6 swept round at 3.9 m | coiled deep right, crouched, both arms wound back (f5–10) | 4.40 ×3 vs 4.4 |
| K1 墜鎖 | `:hs-k-tsuisa` | 22/4/22 | hanging chain 7 (right front) lanced level at 1.1 m, hooked on a hit | right crescent raised high, arched back, left hand pointing; the chain hauled up into the raised fist (f7–19) | 7.85 ×4 vs line 7.85 |
| K2 薙鎖 (+K2s) | `:hs-k-nagisa` | 24/4/24 (link 6) | hanging chain 1 reaping the floor (0.35 m) L→R, +70° → −70° | coiled left, crouched, left arm flung back low, the chain hauled into the left fist (f13–21) | 6.00 ×4 vs arc 6.0 |
| K3 落鎖 | `:hs-k-rakusa` | 24/5/34 (link 6) | four chains dropped out of the orb onto the line (1.8 / 3.9 / 5.9 / 7.9 m) | both crescents high overhead, arched, on his toes (f13–22) | 7.90 ×5 vs line 8.0 (−0.10) |
| L 鎖払 | `:hs-k-saharai` | 14/4/22 | all eight hanging chains flung out to 3 m in a ring (+40° spin) | the wrap: arms crossed over the chest, curled, the curtain drawn in and up (f6–12) | 3.00 ×4 vs r 3.0 |
| SP1 綴雷電 | `:hs-k-raiden` | 20/3/24 | the neck bundle lanced down the line + the bolt to 9.3 m | right crescent raised high, two fingers at the neck, the bundle hauled into the raised fist (f7–17) | 9.30 ×3 vs line 9.3 |
| SP2 鎖雨 | `:hs-k-ame` | 30/14/30 | two rains of five chains out of the orb along the lane (f30, f40) | both arms raised to the orb, arched far back, face up (f8–27); a second beat f38 | 10.89 on every hit frame vs lane 11.0 (−0.11) |
| O 降鎖 | `:hs-k-kosa-aim` (loop), `:hs-k-kosa` | 20/2/30 | the neck bundle whipped down the lane | coiled back, the left hand heaving the bundle up over his head (f7–17) | 10.00 ×2 vs lane 10.0 |
| Breaker | `:hs-k-breaker` (loop), `:hs-k-hammer` (`:clip-map`) | 8/4/18 | the chained right forearm as a hammer-fist (the held rod) | forearm cocked high behind the head (f4–6) | 0.78 0.85 0.88 0.89 vs 1.35 (short: allowed, as every Breaker) |
| P 首掛 | `:hs-k-kubikake` | 24/4/30 | hanging chain 0 whirled overhead, cast along the line, hooked on a hit | left arm up whirling (the wrist keyed every 3 f), coiled, cocked f21 | 7.35 ×4 vs line 7.35 |
| bind J1 弦 | `:hs-kb-gen` | 8/3/12 | the held right rod, flat R→L at the neck line | coiled right, right arm far back (f4–6) | 1.55 1.42 1.35 vs arc 1.5 (FK test) |
| bind J2 返弦 | `:hs-kb-kaeshi` | 8/3/13 | left crescent on a short chain, rising ↗ | wound left, crouched, the crescent at the knee (f4–6) | 1.50 ×3 vs 1.5 |
| bind J3 双弦 | `:hs-kb-sogen` | 9/3/18 | the held rods crossed, then scissored out | both crossed high in front, hunched (f4–7) | 1.56 1.54 1.53 vs arc 1.5 (FK test) |
| bind K1 引斬 | `:hs-kb-hikigiri` | 18/4/20 | right crescent hooked out along the line on its chain; the left yanks the noose | right crescent drawn back over the shoulder, left hand up the noose (f6–15) | 2.95 ×4 vs line 2.95 |
| bind K2 巻斬 | `:hs-kb-makigiri` | 20/4/24 (link 6) | hanging chain 2 flung across L→R at the chest (0.95 m) | coiled left, left arm flung up and back, the chain hauled into the left fist (f12–18) | 2.80 ×4 vs arc 2.8 |
| bind K3 絞 | `:hs-kb-shibori` | 22/5/34 (link 8) | two chains dropped out of the orb at ±22°, cinching | the canon gesture: right crescent straight up, left hand high on the noose (f14–20) | 2.95 ×5 vs arc 3.0 (−0.05) |
| bind L 引寄 | `:hs-kb-hikiyose` | 16/40/8 | no hit (the noose drag) | both hands high up the noose, leaning in (f7–14); the heave, then hand over hand every 6 f | — |
| bind SP1 | `:hs-kb-raiden` | 14/3/24 | left crescent down the line on its chain + the bolt to 4.3 m | right fist raised, left crescent drawn back low, coiled (f5–12) | 4.30 ×3 vs line 4.3 |
| bind SP2 絞縄 | `:hs-kb-kojo` | 20/4/30 | right crescent let out in the wide downward reap | the blade raised (f5), the choke: hunched, his left hand at his own throat (f11), drawn further back (f18) | 3.00 ×4 vs arc 3.0 |
| bind O 絞首 | `:hs-kb-koshu-run` (loop), `:hs-kb-koshu` | 8/3/24 | the garrote: the chain between his fists through the victim's neck (drawn within 2.1 m) | both fists high, the chain taut over his head (f4–6) | the garrote at the victim's neck by construction (the held rod 0.57–0.62 m: not the striker) |
| P 解縛 → UNWIND | `:hs-kb-unwind` | 20/0/0 | no hit | the chains go slack; the noose's ring slides down off him; the crescents lowered | — |

Every hand-chain and chain-strike tip sits on its volume's edge by construction and is measured through the real draw
path (debug 83902: the body posed by the form's clip, HS-POSE and HISAGI-DRAW run on each hit frame). The J / K links' FK
test (`tests/duel-rules-test.lisp`) reads `*hs-strike-reach*` for those clips, and a new host check ties that table to
`*hs-letout*` / `*hs-bk-chains*` (the farthest end out over each move's hit window within 0.15 m of the volume's edge).
The bind's J1 / J3 are the held rod (FK, +0.05 / +0.06).

**Startups too short for a long held windup** (frame data unchanged, as the brief says): the bind's J1 / J2 (S 8: the
peak at f4, held to f6, 2 frames of snap), its J3 (S 9: f4 → f7), the Breaker's strike (S 8: f4 → f6, after the dash) and
KŌSHU's strike (S 8: f4 → f6, after the zip). They read as a hard cock and snap, not a held windup. The longer ones (J 11–13,
K 18–24, SP 14–30, O 20, P 24) hold 5–19 frames.

**Proof.** `simgate --seeds 10 --summary` (56 lines) and `--cvc` (yy / yk / kk PASS) byte-identical to the parent ea1985d
(`cmp`, the `[simgate] building` banner filtered); duel-rules-test 9711 checks ALL PASS; pkgcheck clean; `./build.sh duel`
with only the 4 known Lille style warnings; debug 83901 0 B in every state on the repeat call, the Bankai's twelve new ones
included (the first call after the scene grows the fx vertex buffer once, 131 KB at SHIBARI and 262 KB at SP2's rain, as
§21.6 noted).

**Stills** (`tools/run.mjs --fixed-dt 16.666667`; debug 83500+k picks a Bankai strip slot of `*hs-bk-strips*`, then
83940+3i+v as the Shikai's): every slot at 2S/3, S−2 (the held peak), S and mid-recovery from his right side, and S−2 and S
from the front (1280×720); six slots in portrait (720×1280); eight in the match camera.

**Known issues / for the user's eyes** (checked by numbers, needs your eyes):
- Lines along his facing (K1, SP1, O, KUBIKAKE) are foreshortened from the behind camera: the chain reads as a short line
  reaching the opponent; the side view shows the whole lance.
- TSUZURI RAIDEN's bolt shows from S−3 (the Shikai's timing, kept), so the snap is the chain and the arm, not the bolt.
- The bind's J1 / J2 / J3, the Breaker and KŌSHU (above) have short windups.
- In the card stills of the bind, the noose runs to the hidden opponent's unposed joints (the floor); in the match it is
  round his neck (§21.6).
- The Kikon cinematics still play B2a's `:hs-kari-o` (§11.5's storyboard is its own batch); the opponent's reel is the
  shared clip.

## 22. The two Bankai modes made distinct (the user, 2026-10-18)

The user's playtest: 「目前近遠程的攻擊模組看不出各自的特色」.

**Diagnosis (the lead).**
- Both modes share one grammar: J1–J3 then K1–K3, the same recoveries, block advantages, guard values and hit
  reactions (§17.1 / §17.3).
- The ranged mode differs only by +3–4 f of startup and longer reach. Its J2, J3, K2 and K3 hit at point blank (only
  J1, K1 and KUBIKAKE carry `:no-close`).
- Both modes play from the same blade-in-hand stance (§21.8). The bind adds only the noose.

**Options offered:**
- A: the ranged mode as a placed zone game (standalone moves, delayed chain drops at a chosen spot, hits pushing out,
  nothing inside 2 m).
- B: the bind as a faster rushdown.
- C: the looks and stances pulled apart.
- D: distance sweet spots (the ranged mode's chain tip strong, close weak; the bind the reverse).

**The user's choice:** A + C + D, plus 「遠程攻擊有效利用鎖鏈球拉動垂鏈迴轉對遠程進行抽打」. The orb turns and drags the
hanging chains round in a carousel, lashing out at range. B is not taken: the bind keeps its timing.

The proposal table (§22.1) goes to the user for a 「可以」 before anything is built. This is a sim change: his 7 pairings
get gated against the parent, and his CPU learns the new moves.

### 22.1 The proposal, approved (the user, 2026-10-18: 「可以」)

**Shared rules.**
- Dead zone: every ranged-mode attack except L misses inside 2.0 m.
- Chain tip: a ranged-mode hit in the outer 1.0 m of its volume deals x1.3 (x1.0 elsewhere).
- Bind close-in: a bind-mode hit within 1.2 m deals x1.2.
- Walk: the ranged mode's 3.4 → 2.8 m/s (he stands his ground; the chains move).

**The ranged mode, 旋鎖陣 (the carousel).** At rest the orb turns slowly and the 8 hanging chains orbit him. On a strike
the orb jerks into a spin and flings the chains out; the crescents hang at his sides and only signal.

| Move | New | Was |
|---|---|---|
| J1 / J2 旋鞭 | The orb twists right / left and that side's curtain sweeps an annulus 2.0–4.5 m, 100° ahead. S 14 / 13 (the orb winding). A hit pushes the victim back to ≥ 3.5 m (the tip) | a 4.0 m arc 100°, point blank too; S 12 / 11 |
| J3 旋鎖 (ender) | The orb spins a full turn, every hanging chain lashing an annulus 2.0–5.0 m, 360°. Ender push to 5.5 m | 4.4 m arc 180° |
| K1 墜鎖 (placed) | Marks the ground at the target's feet (2–8 m). A hanging chain is hauled up into the orb; after 36 f a bundle slams down there, r 1.2 m. His own S 12, R 14: he acts while it waits. At most 2 marks live | a 7.5 m line |
| K2 薙鎖 (placed) | The mark leads the target's motion (where it is heading) | a 6.0 m arc 140° |
| K3 落鎖 (ender) | Every live mark slams at once, plus a bundle on the target (r 1.5 m), crumple | a 7.5 m line |
| L 鎖払 | Unchanged: a ring of chains bursts out, r 3.0, push to 6.5 m. His only close-in hit, his escape | — |
| SP1, SP2, O, P | Unchanged (already long), under the 2.0 m dead zone | — |

**The bind mode.** Moves and frame data unchanged, plus the x1.2 close-in. Its look: the crescents gripped, a low
forward stance, the noose taut.

**Build order.**
1. Sim, CPU and host tests in one batch (B4a, a worktree). The marks are hazards (`hazards.lisp`'s delayed disc,
   SPAWN-HAZARD with a hook), with a placeholder look so the playtest can read them.
2. The playtest.
3. His 7 pairings at 20 seeds against the parent, plus his awaken A/B.
4. The art pass (B4b): the carousel, the orb's spin, the two stances, the new J / K clips with the exaggerated windups
   of §21.7.

### 22.2 B4a as built (2026-10-18): the sim, the CPU, the host tests (a sim change)

§22.1's approved table, built in `duel/lisp/hisagi.lisp` (the moves, the marks, the hooks, the CPU), with the smallest
default-off support in the shared files and a placeholder look in `hisagi-art.lisp`. The clips are still B3b's (§21.8);
the art pass B4b (the carousel, the stances, new J / K clips) is next.

**Shared support (default off; every other character's results byte-identical, below).**
- `kit.lisp`: a hit window's `:min-reach` (a move-level key every window inherits, or a window's own): `hw-min`, NIL for
  every move but his ranged mode's. `combat.lisp` COLLECT-MELEE skips a victim nearer than it (centre to centre), except a
  Kikon's follow-up strike (the dash lands it inside 2 m; the dead zone would erase the Kikon itself).
- `combat.lisp` APPLY-HIT: a kit hook `:dmg-mult` (att def hw mv hazard d2) → a factor on the attacker's multiplier (with
  the pierce / ASSIST ones). Only his two Bankai modes set it (HS-DMG-MULT).
- `ai.lisp` AI-REFLEX: a kit `:ai :move-reflex` (e b f mv) asked during his own move, before the generic "in a move:
  nothing". Only his ranged mode sets it (HS-R-AI-MOVE: a placed K has no hit for STRING-REFLEX to read).

**Knobs** (all in `hisagi.lisp`, each with its docstring; the user, 2026-10-18, §22.1, unless marked B4a's pick)

| Knob | Old → new | What |
|---|---|---|
| `*hs-r-walk*` | 3.4 → 2.8 | the ranged mode's walk (m/s) |
| `*hs-r-dead*` | — → 2.0 | the dead zone (m): every ranged-mode attack but L and the universal Breaker |
| `*hs-r-tip*` / `*hs-r-tip-mult*` | — → 1.0 m / x1.3 | the chain tip |
| `*hs-b-close*` / `*hs-b-close-mult*` | — → 1.2 m / x1.2 | the bind's close-in |
| `*hs-r-j-push*` / `-frames*` | — → 3.5 m / 10 f (B4a's frames) | J1 / J2's hit pushes onto the tip |
| `*hs-r-j3-push*` | 4.91 (the generic J1-reach ender push) → 5.5 m | J3's ender push |
| `*hs-mark-delay*` / `*hs-mark-r*` / `*hs-mark-h*` | — → 36 f / 1.2 m / 2.0 m (B4a's height) | a mark's slam |
| `*hs-mark-min*` / `*hs-mark-max*` | — → 2.0 / 8.0 m | where a mark may land (from him) |
| `*hs-mark-live*` | — → 2 | marks waiting at once; a third replaces the oldest |
| `*hs-mark-active*` / `*hs-mark-life*` | — → 3 f / 24 f (B4a's) | the slam's hit window / its look |
| `*hs-rakusa-r*` / `*hs-rakusa-lock*` | — → 1.5 m / 8 f (B4a's lock) | K3's bundle on the target, its spot locked at S − 8 |
| `*hs-ai-close*` | 2.5 → 2.0 m | his CPU's L SAHARAI band (the dead zone's) |
| `*hs-ai-k-link-p*` | — → 0.3 / 0.55 / 0.8 | his CPU's link off a placed K1 / K2 (EASY / NORMAL / HARD) |
| `*hs-ai-mark-near*` | — → 2.0 m | ... K3 only with the foe this near a waiting mark |
| `*hs-ai-opp-mark-p*` | — → 0.15 / 0.35 / 0.6 | a CPU facing him side-Steps out of a mark (once per mark) |
| `*hs-tsuisa-to*` / `-frames*` | 3.5 m / 10 f → deleted | TSUISA's drag (K1 is placed now) |

**The moves as built** (S / A / R; damage; the rest as §17.1)

| Move | As built |
|---|---|
| J1 旋鞭 | S **14** / 3 / 12, 22, hitstun 24; annulus 2.0–4.5 m, 100° (`:reach 4.5 :arc 100 :min-reach 2.0`); `:no-close`; a hit pushes him to ≥ 3.5 m (10 f) |
| J2 / J2s 旋鞭 | S **13** / 3 / 13, 22, the same annulus and push |
| J3 旋鎖 (ender) | S 13 / 3 / 18, 30, stagger; annulus 2.0–5.0 m, **360°**; the ender push to 5.5 m (its `:on-land` after the generic push, which it replaces) |
| K1 墜鎖 | S **12** / A 2 / R **14**, no hit window (`:reach 8.0` for the chase and the CPU's reads, damage 0); at S a mark at the target's feet; the mark: 52, guard 14, stagger |
| K2 / K2s 薙鎖 | the same frames as K1 (**B4a's pick**: the spec gave none; a placed link needs no `:enter`, its own hit is 36 f later); the mark leads him; 44, guard 14, stagger |
| K3 落鎖 (ender) | S 24 :enter 6 (S_eff 18) / 5 / 34, 66, guard 18, crumple, −20: every waiting mark slams at its S, plus its own window: a bundle on the target (`:seg-fn` HS-RAKUSA-SEG, a vertical capsule r 1.5 m at the target's feet, its spot aimed from its first frame and locked at S − 8, clamped 2–8 m); its ender push from the kit's `:push-reach` 7.5 (≈ 7.95 m, unchanged: inside the O's 9 m lane and SP1's 9 m line) |
| SP1, SP2 (+ SP2c), O, P | unchanged but `:min-reach 2.0` (O's follow-up strike excepted, above) |
| L 鎖払, the Breaker | unchanged (no dead zone, no tip) |
| bind mode | unchanged but the x1.2 close-in on every bind move but the Breaker |

**The choices where the spec was silent (B4a's).**
- **The dead zone** is the centre-to-centre distance at the hit (2.0 m); a mark's slam has it too (HS-MARK-HOOK's
  `:touches`). Not the Breaker (the universal one dashes in to 1.35 m: a dead zone would leave him without it).
- **"The outer 1.0 m" (the tip)**: an arc / annulus by the victim's distance from him against the arc's r (J1 / J2 tip
  from 3.5 m, J3 from 4.0); a line / lane along his facing against its far end (SP1 from 8.0 m, SP2 from 9.0, O from 8.0,
  KUBIKAKE from 6.0). **The marks and K3's bundle get no tip** (placed: no "outer" reading; their power is the
  placement). L SAHARAI (unchanged by §22.1) and the Breaker x1.0. The tip applies to SP1 / SP2 / O / P too: §22.1's
  shared rule says "a ranged-mode hit"; "unchanged" in the table read as frame data and volumes.
- **The bind's x1.2** on every bind move but the Breaker, by the centre-to-centre distance at the hit (≤ 1.2 m).
- **The placed K and the string gate**: a placed K1 / K2 counts as the string's touch (FIGHTER-CHAINED at the placement),
  so the next link starts at the chain lead, as after a block (K1 → K2 / J2s, K2 → K3, J1 → K2s → K3 all play); no whiff
  penalty (a move with no hit window ends at S + A + R). KKK in time: K1's mark slams at its f48, K2's is placed at about
  f37 of the string, K3's S at about f68 slams K2's (due at f73) early with the bundle. Combos: JJJ and JJK (J2 → K3: 3 + 18 = 21 ≤ 23)
  as before; a placed K is a set-up, not a combo link (its mark lands 36 f later).
- **K2's lead**: the target's walk / run velocity × the 36 f, plus what is left of his slide (a Step, a push), then the
  2–8 m clamp and the arena.
- **Marks are not fragile**: a mark waits on when he is hit (the chain is already up); they are cleared at the bind's
  start (with the mode), at any bind's end and every reset (CLEAR-HAZARDS), and are in his state-hash text (each 1 + its
  x + z in cm, with K3's spot). A mark is a hazard of his own kind `:hs-mark` (HS-MARK-HOOK answers `:touches`), so no
  shared reader treats it as a projectile (Nozarashi's cut, Senjumaru's reflect, Ichigo's cut skip it); it is `:ranged`
  (every hazard is): a front guard facing **him** blocks it (`:src`: the hazard blockstun 14), West's ward and the Shikai
  windmill's `:ranged-ward` guard it, a parry does not catch it, Rukia's absolute zero lets it through as any ranged hit.
  The opponents' CPUs read it through RANGED-THREAT-IN (hazards) and his `:opp-reflex` (below).
- **Three marks**: the oldest waiting one (placed first) is destroyed when a third is placed.

**The CPU** (`duel-character-cpu`: one roll per event, EASY ≤ NORMAL ≤ HARD).
- The ranged `:ai`: ranges approach 3.5–5.0, pressure 3.0–4.5, zone 3.5–5.5, defend 4.5–7.0 (he holds 3–5 m); the move
  bands 0–2 m L 3 / Step 4 / Breaker 1 (L also by his reflex, `*hs-ai-close*` 2.0), 2.0–2.5 J 1 / K 1 / Step 2, 2.5–4.5 J 5 /
  K 2 / Step 1, 4.5–8 K 5 / Step 1, 8–10 K 1 / O 1 / wait 2, beyond 10 O 1 / wait 3.
- `:move-reflex` HS-R-AI-MOVE: one roll per placed K1 / K2 (keyed by its start tick), the frame after its mark: off K1,
  J2s with the foe at 2.5–4.5 m, else K2 within 9 m; off K2, K3 only while the foe stands within 2.0 m of a waiting mark.
- The bind's `:ai`: ranges approach 1.2–3.0, pressure 0.8–1.2 (inside the x1.2); bands 0–1.2 J 5 / K 2 / Breaker 1,
  1.2–1.8 J 3 / K 2 / Breaker 1, then as before.
- A CPU facing him (`:opp-reflex` HS-AI-OPP): a side Step out of a mark that will slam on it in 4–14 f, once per mark
  (`*hs-ai-opp-mark-p*`); K1 dropped from its anti-line Step (no line any more).
- ASSIST / the learner: nothing of theirs names his moves (no change).

**Look (placeholder, 0 B a frame).** HS-MARK-LOOK draws a mark and K3's bundle spot (a look-only hazard spawned at the
lock): waiting, a black ring at its edge and a white one tightening onto it from 1.5 r, blinking faster in its last 12 f;
the slam, three black chains dropped on it from 4 m (hauled back up over 6 f) and a dust ring spreading to 1.3 r. The
drawn reach: J1 / J2's let-out crescents 4.0 → 4.5 m, J3's 4.4 → 5.0 (and its swept hanging chain 3.9 → 4.9), so the FK
test's ±0.15 m holds; the J clips play at 12 / 14 and 11 / 13 speed (`:clip-s`) so their hit pose lands on the new S.
K1's lance, K2's reap and K3's four line drops (`*hs-bk-chains*`) are deleted (they would lie: nothing hits there now);
the K clips still play their B3b windups, squeezed into K1 / K2's S 12 (`:clip-s` 22 / 24).

**Debug** (DUEL_GAMEPLAY "Debug commands"): 83016 the ranged mode 5 m from an idle Kenpachi, K1 started; 83017 the same
with two marks waiting by him and K2 started (a third: the oldest goes); 83018 the ranged mode 4 m from a CPU Rukia (a fresh CPU battle),
P1's CPU on. 83901's line counts the marks' look (waiting and slamming). New pacing keys in the `duel hisagi` line:
`j-push`, `j3-push`, `mark`, `mark-lead`, `mark-replaced`, `k3-slams`, `ai-kj` / `ai-kk` / `ai-k3`, `opp-step-mark`
(`tsuisa-drag` gone).

**Tests** (`tests/duel-rules-test.lisp`, 9697 checks ALL PASS (9711 before: the placed K1 / K2 left the hit-based walks, B4a's own added)): the string budget walk takes his placed K1 / K2 off the hit-based
checks (pinned in his block instead: no window, S 12, R 14, the mark at S); his block pins the dead zone on every ranged
window but L's and the Breaker's and on no other move of the game, the `:dmg-mult` / `:move-reflex` hooks on no other kit,
the annulus (1.9 m no, 2.0 yes, 4.85 yes, 4.9 no; J1 not behind; J3 all round to 5.36 m), the J pushes, HS-DIST-MULT and
HS-DMG-MULT (the tip on arcs and lines, none for L / the Breaker / a mark / K3's bundle; the bind's x1.2 within 1.2 m), the
mark spot's clamp and K2's lead, a placed mark (the hazard's kind, owner, spot, r 1.2, 36 f, guarded facing him, not
fragile, K1's 52 / stagger / guard 14, the string's touch), its slam active on exactly frames 36–38, the dead zone on a
slam, gone at its life, the third mark replacing the oldest, K3's slam of every waiting mark and its bundle (spot, r 1.5),
the K ender push from 7.5, the bind's start clearing the marks; the route damage (marks' damage for the placed links)
74 / 110 / 132 / 162 / 126 / 104 as before; every link with a hit window combos with its hitstop. duel-control-test 89,
learn-test 131 ALL PASS; `tools/pkgcheck.sh duel` clean; `./build.sh duel` with only the 4 known Lille style warnings.

**Gates on the worktree (parent 5ea33ab; `simgate --seeds 10 --summary`).** The 42 summary lines of the 21 pairings
without him are byte-identical to the parent's (`cmp`; the parent built from a `git archive` of 5ea33ab); `--cvc` yy / yk /
kk PASS, identical to the parent and `tests/style-cvc-ref.txt`. His 7 pairings at 10 seeds (parent → B4a):

| Pairing | K.O.s | Median (s) | Wins (H as P1) |
|---|---|---|---|
| HY | 10 → 10 | 144.3 → **130.9** | 3 → 4 of 10 |
| HK | 10 → 10 | 126.8 → **124.6** | 6 → 1 |
| HR | 10 → 10 | 170.0 → 176.4 | 7 → 1 |
| HI | 10 → 10 | 185.6 → 171.1 | 7 → 2 |
| HS | 10 → 10 | 157.6 → 192.1 | 6 → 1 |
| HB | 10 → 10 | 202.3 → 152.2 | 1 → 1 |
| HH (mirror) | 9 → 9 | 236.4 → 228.6 | 1 → 4 |

The quick pass (all K.O. and 135–200 s) does not clear HY and HK (and HH's one time-out, as on the parent): the lead's
20-seed gate decides. No knob was retuned for the window. Debug 83901: the marks' look 0 B (10 calls waiting and slamming;
SHIBARI 131096 and SP2 262168 are the first-call fx-buffer growth §21.8 noted, the same as on the parent); the browser smoke
(83016, 83017, 83018, 30 s, `--fixed-dt 16.666667`) ran with no JS / WebGPU error, the CPU zone game playing.

**Known issues** (for the playtest and B4b).
- **He is much weaker on these 10 seeds** (wins as P1 against HK / HR / HS 6-7 → 1 of 10). The pacing log of HK shows
  why: the ranged mode spends about a third of its frames inside 2 m (`r-near` 2052 of 6077 in seed 1), where only L,
  a Step and the Breaker do anything; Kenpachi walks him into the dead zone. This is §17.1's "weak at 2 m by design" made
  hard by the dead zone; the window, the walk 2.8 and the CPU's spacing are the user's calls after the playtest.
- The generic CPU still presses J where it reads J1's reach as in range (a punish, a follow-up, the pressure reset) even
  inside 2 m: a whiff there. His `:moves` bands keep J out of 0-2 m; the generic branches do not know a dead zone.
- A perfect Hoho reads a move's volumes (PERFECT-HOHO-P), not its dead zone: inside 2 m his J can make a Hoho "perfect"
  though it could not hit (defender-side generous; rare).
- The placed K is not a true string link: a K1 → K2 / J2s starts at the chain lead (as after a block), and a mark lands
  36 f later, so KKK combos only when K1's mark hits first (K1's mark at f48, its stagger outlasting K3's S at about f68).
- The look is a placeholder: no carousel, no orb spin, the K clips' windups squeezed into S 12 and their chain strikes
  removed (the hanging chains only); the rings sit at the feet (no chain is seen hauled up into the orb while one waits).

**What the art batch B4b must draw.** The carousel (the orb turning, the 8 hanging chains orbiting at rest; the jerk into a
spin on each strike); J1 / J2's side curtain sweeping the 2.0–4.5 m annulus, 100° ahead (14 / 13 f windups: the orb
winding), J3's full turn to 5.0 m; K1 / K2: a chain hauled up into the orb at S 12, the mark's tell for 36 f and the bundle
slamming from above (r 1.2), K2 aimed ahead of him; K3: every mark's bundle at once plus the one on the target (r 1.5, the
spot shown from S − 8); the two stances (ranged: crescents hanging at his sides; bind: gripped, low, the noose taut); the
drawn reach on the hit frames within 0.15 m of the annuli's 4.5 / 5.0 m (and the host check of `*hs-strike-reach*`).

### 22.3 B4a gates (the lead, 2026-10-18)

His 7 pairings at 20 seeds against the parent 5ea33ab (main 1640589, `simgate --pairs 28,29,30,31,32,34,35 --seeds 20`):

| Pairing | Median, parent → B4a | Hisagi's P1 wins of 20, parent → B4a |
|---|---|---|
| HY | 144.3 (10 seeds) → 129.4 s | ? → 4 |
| HK | 130.8 → **116.0 s** | 9 → **1** |
| HR | 170.0 → 147.5 s | 10 → **1** |
| HI | 170.7 → 171.1 s | 10 → 5 |
| HS | 157.6 → 187.6 s | 11 → 3 |
| HB | 202.3 → 169.6 s | 2 → **1** |
| HH (mirror) | 226.2 → 228.6 s (2 time-outs) | 6 → 8 |

- Every match ends in a K.O. except the mirror's 2 time-outs, as on the parent.
- HK's edge rerun at 60 seeds: median **124.6 s**, 0.4 s under the 125 s floor. Hisagi wins 3 of 60 as P1.
- Reported to the user. Nothing is retuned: whether and how to strengthen him is their call after the playtest (v93).
- Candidate levers offered: the 2.0 m dead zone, L's cooldown, the mark's 36 f delay, the 2.8 m/s walk.
- The awaken A/B waits until that call.

### 22.4 The ranged strings by route: gathered vs spread (the user, 2026-10-18)

The user's request, verbatim:

> K1 將垂降的鎖鏈在身旁旋轉並捆成一束
> - K1 接續的 K2 會使用粗壯的鎖鏈束向前方地面抽打後，尾段繼續向前方直線地面甩擊：動畫就像 U => L
> - K1 接續的 K3 會拉動 K2 時平躺於地面的鎖鏈束進行 360° 的旋轉甩打
> - K1 接續的 J2 J3 也會用類似的邏輯使用鎖鏈束快攻
> - J1 接續的 K2 K3 則會更採用散開的鎖鏈發動攻擊
>
> 散開的鎖鏈攻擊更快，聚合的鎖鏈攻擊更痛

Reading (the lead):
- The opener decides the route's chains.
  - A K1-opened string is **gathered**: K1 spins the hanging chains beside him and binds them into one bundle; every
    later segment strikes with the bundle.
  - A J1-opened string is **spread**: the separate hanging chains.
- Spread is faster, gathered hurts more.

The segment table and the open points (K1's own hit, the fate of B4a's placed marks, the speed / damage ratios) go to
the user before anything is built (`duel-move-modules`: restate the notation first).

The user's answers (2026-10-18):
- K1's binding spin hits: 「身旁旋轉會打到」.
- B4a's placed marks are removed: 「拿掉落點」.
- The ratios: 「散 −3 幀×0.85／聚 +3 幀×1.3」.

**The proposed segment table (the lead, for the user's 「可以」).**
- Openers keep their own numbers; the route's ratio applies to segments 2 and 3.
- The 2.0 m dead zone stays on every ranged move except K1 and L.
- Bases: B4a's J (S 14 / 13 / 13, 22 / 22 / 30) and the K timings before the marks (K2 S 24 dmg 44, K3 S 24 dmg 66).

| Route | Segment | Chains | Motion | Volume | S | Dmg | Reaction |
|---|---|---|---|---|---|---|---|
| — | J1 旋鞭 (opener) | spread | as B4a | annulus 2.0–4.5 m, 100° | 14 | 22 | flinch, push to 3.5 m |
| — | K1 綁束 (opener) | gathering | the hanging chains spin round him and bind into one bundle | 360°, r 3.0 (no dead zone) | 16 | 40 | stagger |
| spread (J1 →) | J2 | thin chains | the other side's curtain sweeps | annulus 2.0–4.5 m, 100° | 10 | 19 | flinch, push to 3.5 m |
| spread | K2s | thin chains | several chains whip the ground in a fan | fan 2.0–6.0 m, 60° | 21 | 37 | stagger |
| spread | J3 (ender) | thin chains | a full turn, every chain lashing | annulus 2.0–5.0 m, 360° | 10 | 26 | stagger, push to 5.5 m |
| spread | K3 (ender) | thin chains | every hanging chain lashes forward at once | fan 2.0–6.0 m, 160° | 21 | 56 | crumple |
| gathered (K1 →) | K2 | the bundle | U → L: the bundle arcs over and slams the ground ahead, then its tail lashes on along a straight ground line; the bundle ends lying flat ahead | hit 1: cap 2.0–3.5 m; hit 2: line 3.5–8.0 m | 27 | 57 (25 + 32) | stagger, then knockdown |
| gathered | J2s | the bundle | a quick straight lash of the bundle | line 2.0–5.0 m | 16 | 29 | flinch |
| gathered | K3 (ender) | the bundle | the bundle (flat on the ground after K2) hauled into a 360° spin | annulus 2.0–6.0 m, 360° | 27 | 86 | crumple |
| gathered | J3 (ender) | the bundle | a flat bundle sweep | annulus 2.0–5.0 m, 180° | 16 | 39 | stagger, push to 5.5 m |

Everything else (L, SP1, SP2, O, P, the tip x1.3, the walk 2.8, the bind mode) as B4a.

**Approved (the user, 2026-10-18: 「可以，然後覺醒跟毀魂技的動畫的記得要做」).** The table above is built as batch B4c (sim,
CPU, tests). The awakening and the Kikon (毀魂技) cinematics are built in parallel as batch B5 (presentation only).

**The binding throw moves to SP2 (the user, 2026-10-18).**

The user's request: 「把卍解捆綁給到 SP2，但發動不會消耗 SP」. Their answers:
- 「鎖雨移到捆綁的 SP1」
- 「可以，命中確認後接（推薦）」

What changes:
- The ranged mode's SP2 is 首掛 KUBIKAKE. It keeps its own move data and rules and still needs his own 200 Reiatsu,
  but the press spends no SP bars. It cancels off J / K string hits like any SP2 (hit-confirm).
- The ranged P no longer throws, so it does nothing; the bind's P stays the release.
- 鎖雨 KUSARI-AME becomes the bind mode's SP1, replacing the bind's 綴雷電, paid from the shared pool. The ranged
  SP1 stays 綴雷電.

These are added to batch B4c.

**The bind's L and SP2 (the user, 2026-10-18).**

The user's request: 「絞縄改成給捆綁的 L，捆綁的 SP2 換成解除並附加傷害（有專屬動畫、可被防禦）」. Their answers:
- 「絞縄本身帶拉近」
- 「不冷卻，降低傷害並增加大前搖，通過降低優勢來控制出招動機」
- 「先還原再打，傷害 120（推薦）」

What changes (the lead's numbers for the user's direction):
- **The bind's L becomes 絞縄 KOJO.** It first pulls the victim to 2.0 m along the noose, then strikes (3.0 m, arc
  160). No cooldown and no SP. Damage 160 → 70, startup 20 → 30 (a big windup), recovery 30 → 36, adv-block
  -16 → -24. 引寄 HIKIYOSE is gone as a move: its pull lives in L.
- **The bind's SP2 becomes 解縛擊, the release plus a strike.**
  - The voluntary release as before: the entry snapshot restored, the remaining pool to the opponent first, the
    opponent's 30 f reel.
  - Then a strike for 120 real damage. It is blockable: a block still releases, with no damage.
  - No SP spent. It gets its own animation.
- **The bind's P** stays the plain release, with no damage.

These are added to batch B4c.

**B4c gate (the lead, 2026-10-18; main 651fcb5, 20 seeds, his 7 pairings).**
- Every match ended in a K.O.; every cross-pairing median is inside 125–210 s, so the pacing gate passes:

  | Pairing | Median | His P1 wins of 20 |
  |---|---|---|
  | HY | 126.5 s | 7 |
  | HK | 131.5 s | **0** |
  | HR | 168.4 s | 3 |
  | HI | 179.4 s | 3 |
  | HS | 165.4 s | 6 |
  | HB | 177.9 s | **1** |
  | HH (mirror) | 227.7 s | 7 / 13 |

- He still loses most matches: 0–7 P1 wins of 20.
- Reported to the user with B4c's three open points: K1's close hit has no reaching follow-up, the bind's rain keeps
  the dead zone, gathered K2 launches instead of knocking down. Nothing is retuned.

### 22.5 The cinematics, storyboards revised for the current design (the lead, 2026-10-18)

§11.5's storyboards predate four decisions:
- the S-pair blades (§21.5);
- the orb above the frame with its black hanging chains (§21.5–§21.6);
- the bind starting only from KUBIKAKE (§17.2), so the awakening must not noose the opponent;
- three Kikons now (Shikai 刈れ, the ranged 降鎖 KŌSA, the bind 絞首 KŌSHU).

Revised beats follow (CINE-PLACE the actors; landscape letterbox 9 %, portrait %PORTRAIT-DOLLY). The user can point
at a beat after seeing the stills.

**The awakening 「卍解 風死絞縄」 (~168 f).**

| Beat | f | Camera | Action |
|---|---|---|---|
| 1 | 0–20 | close on his face | eyes shut; the chain between the two Kazeshini slack in his hands |
| 2 | 20–50 | low, looking up, 20 mm | both Kazeshini thrown up; their chain twists into a whirlpool overhead |
| 3 | 50–70 | wide | 卍解: a black wind bursts out (a negative frame, the shockwave); the stamp |
| 4 | 70–100 | medium | silence, the world greys; the blades fall back into his hands; chain coils wind round his neck and right arm |
| 5 | 100–135 | tilt up past the frame's top | the orb of chains forms high above; the black chains drop from it round him; the four-chain bundle ties round his neck; the pale patch on the ground |
| 6 | 135–168 | wide, both | he stands still, arms hanging, crescents point-down (the CFYOW pose) under the curtain; 風死絞縄 stamp, ふしのこうじょう ruby |

**Shikai Kikon 「刈れ」 (~180 f).** §11.5 as tabled, with the S-pair blades.

**Ranged Kikon 降鎖 KŌSA (~150 f).**

| Beat | f | Action |
|---|---|---|
| 1 | 0–25 | low, behind him: he raises one crescent; the neck bundle lifts off his back toward the orb |
| 2 | 25–60 | tilt up: the orb turns; every hanging chain is hauled up into one giant twisted rope |
| 3 | 60–90 | side, long lens: the rope whips down along the lane: a wave of black down the ground to the victim |
| 4 | 90–120 | on the victim: the impact, the ground cracks in a line, a white card with the silhouette (2 drawings) |
| 5 | 120–150 | wide: the chains fall back into the curtain; he lowers the blade, unmoved; stamp |

**Bind Kikon 絞首 KŌSHU (~180 f).** §11.5's beats:
1. He zips along the noose chain.
2. Behind the victim, the chain is drawn across the throat.
3. The orb sinks and chains rain onto the victim, bound standing.
4. He raises a blade; the noose tightens on **both** necks, both choke (the shared pain).
5. The victim drops; Hisagi stays up, shaking; the stamp.

### 22.6 B4c as built (2026-10-18): the routes, gathered vs spread (a sim change)

§22.4's approved table, built in `duel/lisp/hisagi.lisp` (the moves, the strings, the CPU), with one shared change in
`ai.lisp` (below) and the smallest art edits in `hisagi-art.lisp` (the marks' look removed; the cinematics untouched).
B4a's placed marks are gone (「拿掉落點」): the `:hs-mark` hazard, its knobs, HS-MARK-*, RAKUSA's bundle and lock, the
CPU's mark links and the opponents' side Step out of a mark, the marks' look, debug 83016 / 83017's mark scenes, and
the marks and RAKUSA's spot in his state-hash text. B4a's generic hooks stay: `:min-reach` (every route link but K1),
`:dmg-mult` (the tip), `:move-reflex` (now his route picks).

**The strings.** The ranged kit's `:grid` becomes `:strings` (`*hs-r-strings*`, STRING-GRID's shape: JJJ JJK JKK KKK KKJ
KJJ, one switch), so the third link is route-dependent too. Each route link is its own move:

| Route | Link | Move | S / A / R (`:enter`) | Dmg | Guard / block | Volume (dead zone 2.0 unless marked) | Reaction | On land |
|---|---|---|---|---|---|---|---|---|
| — | J1 旋鞭 | `:hs-r-j1` | 14 / 3 / 12 | 22 | 8 / −2 | annulus 2.0–4.5 m, 100° | flinch, hitstun 24 | push to ≥ 3.5 m |
| — | K1 綁束 HŌSOKU | `:hs-r-k1` | 16 / 4 / 22 | 40 | 14 / −3 | **360°, r 3.0, no dead zone**, `:no-close` | stagger | — |
| spread | J2 | `:hs-r-j2` | 10 / 3 / 13 | 19 | 8 / −2 | annulus 2.0–4.5 m, 100° | flinch, hitstun 24 | push to ≥ 3.5 m |
| spread | K2s | `:hs-r-k2s` | 21 / 4 / 24 (6: S_eff 15) | 37 | 14 / −3 | fan 2.0–6.0 m, 60° | stagger | — |
| spread | J3 (ender) | `:hs-r-j3` | 10 / 3 / 18 | 26 | 12 / −4 | annulus 2.0–5.0 m, 360° | stagger | ender push to 5.5 m |
| spread | K3 (ender) | `:hs-r-k3` | 21 / 5 / 34 (6: S_eff 15) | 56 | 18 / −20 | fan 2.0–6.0 m, 160° | crumple | the kit's K ender push (~7.95 m) |
| gathered | K2 束打 | `:hs-r-k2` | 27 / 10 / 24 (6: S_eff 21) | 25 + 32 | 14 / −3 | hit 1 f27–30 `:cap 2.0 3.5 0.5 0.5`; hit 2 f33–36 `:cap 3.5 8.0 0.4 0.5` | stagger, then **launch** | hit 1: push to ≥ 3.5 m over 4 f |
| gathered | J2s 束鞭 | `:hs-r-j2s` | 16 / 3 / 13 | 29 | 8 / −2 | line `:cap 2.0 5.0 1.0 0.5` | flinch, hitstun 24 | — |
| gathered | K3G 束旋 (ender) | `:hs-r-k3g` | 27 / 5 / 34 (6: S_eff 21) | 86 | 18 / −20 | annulus 2.0–6.0 m, 360° | crumple | the kit's K ender push |
| gathered | J3G 束薙 (ender) | `:hs-r-j3g` | 16 / 3 / 18 | 39 | 12 / −4 | annulus 2.0–5.0 m, 180° | stagger | ender push to 5.5 m |

Everything else as B4a: L, SP1, SP2 (+ its charge-less copy off any J / K hit), O, P, the tip ×1.3, the walk 2.8, the
bind mode. Every link is `:ranged` beyond 2.0 m (`:melee-range 2.0`); one press a link (gathered K2's two hits are one
link, the user's U → L).

**Knobs** (`hisagi.lisp`, each with its docstring)

| Knob | Old → new | What |
|---|---|---|
| `*hs-r-spread-s*` / `*hs-r-spread-mult*` | — → −3 f / ×0.85 | spread links 2–3 vs their base (the user: 「散 −3 幀×0.85」) |
| `*hs-r-gather-s*` / `*hs-r-gather-mult*` | — → +3 f / ×1.3 | gathered links 2–3 vs their base (「聚 +3 幀×1.3」) |
| `*hs-r-uchi-frames*` | — → 4 f (B4c's pick) | gathered K2's slam pushes the victim onto its line (to `*hs-r-j-push*` 3.5 m) |
| `*hs-ai-route-dmg-p*` | — → 0.3 / 0.55 / 0.8 | his CPU's damage pick (the K link) per link-1 / -2 hit (EASY / NORMAL / HARD) |
| `*hs-r-push-reach*` | 7.5 (unchanged) | the K ender push still measured from 7.5 m (~7.95 m), docstring updated: K1 reaches 3.0 now |
| `*hs-mark-delay*`, `*hs-mark-r*`, `*hs-mark-h*`, `*hs-mark-min*`, `*hs-mark-max*`, `*hs-mark-live*`, `*hs-mark-active*`, `*hs-mark-life*`, `*hs-rakusa-r*`, `*hs-rakusa-lock*`, `*hs-ai-k-link-p*`, `*hs-ai-mark-near*`, `*hs-ai-opp-mark-p*` | B4a's → deleted | the marks (「拿掉落點」) |

**The choices where the spec was silent (B4c's).**
- **Silent frame data** filled from the base move: K1 綁束 A 4 / R 22 / guard 14 / −3 (§17.1's K1); every route link's
  A / R / guard / block from its base (B4a's J2 / J3, §17.1's K2 / K3); K2s / K3 / K2 / K3G keep `:enter` 6 (the generic
  K-link rule), so S_eff 15 spread, 21 gathered; J2 / J2s keep the hitstun 24 of B4a's J. Ratios applied to S and the
  damage only (rounded: 18.7 → 19, 25.5 → 26, 37.4 → 37, 56.1 → 56, 57.2 → 57, 28.6 → 29, 85.8 → 86, 39).
- **K2's "stagger, then knockdown" is built as stagger, then a launch.** A `:knockdown` reaction makes the victim
  invulnerable until he is up (FIGHTER.LISP DEFENDER-STATE: `:air` with phase `:knockdown`), so K3G / J3G could never
  combo after it (the generic rule: every link combos on hit). A launch knocks him off his feet the same way (airborne
  41 f, then down 30 f and wakeup 30 f if nothing follows) but K3G (25 f after the launch, his feet 1.2 m up) and J3G
  (20 f, 1.3 m) still catch him, inside their 0.2–2.0 m arcs. **For the user to confirm** (the alternative: a true
  knockdown, which makes KKK / KKJ two-hit-then-reset strings).
- **K2's two hits**: hit 1 is the bundle's slam (2.0–3.5 m), hit 2 the tail's line (3.5–8.0 m), both r 0.5 (B2b's
  bundle line). A victim at 2.0–2.6 m would sit in the gap between them, so a hit-1 hit pushes him to ≥ 3.5 m over 4 f
  (`hs-r-uchi-push`, `*hs-r-j-push*`'s 3.5) before hit 2 opens (f33); a victim beyond 4.4 m takes only hit 2. The bundle
  "left lying ahead" is the art's (no sim state).
- **Volumes**: "fan" = an arc from his feet (60° / 160°); "line" = a capsule along his facing at the bundle's r 0.5
  (J2s at chest height 1.0, K2's ground hits at 0.5 / 0.4); "annulus" = an arc with the 2.0 m dead zone.
- **Gathered J2s has no push** (the table gives "flinch" only; B4a's J2s pushed). J3G pushes to 5.5 m as J3 (the table).
- **K1 綁束 is `:ranged` beyond 2.0 m** (`:melee-range 2.0`: the mode's rule, §17.1; L SAHARAI, unchanged since B2b, is
  not), takes the tip ×1.3 beyond 2.0 m (the outer 1.0 m of r 3.0; L and the Breaker stay excepted), `:no-close` (the
  generic opener close-in would dash him into the foe), the default flash tracking (a 360° spin needs none).
- **The K ender push** stays at the kit's `:push-reach` 7.5 (~7.95 m) for both K3s: inside the O lane (9 m) and SP1's
  line; J3 / J3G push to 5.5 m.
- **Clips (a look)**: spread J2 / J3 play B4a's own clips (`:hs-k-kaeshi`, `:hs-k-sensa`, at their new S 10 by
  `:clip-s`); the others name their own clips, played through the Bankai's `:clip-map` as stand-ins
  (`*hs-r-clip-stand-ins*`): K1 `:hs-k-hosoku` → SAHARAI's ring, spread K2s `:hs-k-s-k2` → NAGISA, spread K3 `:hs-k-s-k3`
  → RAKUSA, gathered K2 `:hs-k-g-k2` → TSUISA, J2s `:hs-k-g-j2` → SABEN, K3G `:hs-k-g-k3` → SAHARAI, J3G `:hs-k-g-j3` →
  SENSA. The host's drawn-reach checks skip the stand-ins; B4b deletes each entry it draws.

**The CPU** (`duel-character-cpu`: one roll per event, EASY ≤ NORMAL ≤ HARD).
- The opener is the route: his ranged `:moves` bands 0–2 m K1 3 / L 3 / Step 3 / Breaker 1, 2–3 m **K1 5** / J1 2 /
  Step 1 (gathered first: the damage), 3–4.5 m J1 5 / Step 1 (spread), 4.5–8 m SP1 1 / wait 4 (nothing else of his
  reaches there), then as before; ranges approach 2.5–4.0, pressure 2.0–3.0, zone 3.0–4.5, defend 4.0–6.0.
- `:move-reflex` HS-R-AI-MOVE, one roll on each link-1 / link-2 hit's land step: the damage pick (the K link: spread K2s /
  K3, gathered K2 / K3G) `*hs-ai-route-dmg-p*` of the time when the victim stands inside its reach (HS-R-REACHES-P: past
  the dead zone, inside the far edge + 0.36), else the speed pick (the J link) inside its reach; neither: the string ends
  there (`:wait`, kept to the move's end, no whiff). A learner baiting its Burst read keeps the generic reflex.
- **Shared change** (`ai.lisp` AI-REFLEX): the `:move-reflex` clause moved ahead of the generic "our own hit → STRING-REFLEX"
  clause, so a kit's own reflex picks its links first. Only his ranged kit has the key (host-pinned), so every other kit
  takes the same branches and the same RNG draws (the identity proof below).
- Removed: his mark links (`ai-kj` / `ai-kk` / `ai-k3`) and the opponents' side Step out of a mark (`opp-step-mark`); the
  anti-throw side Step (NAGE / SP1 / KUBIKAKE) stays.

**The buttons moved (the user, 2026-10-18, added to B4c).**

> 「把卍解捆綁給到 SP2，但發動不會消耗 SP」, 「可以，命中確認後接（推薦）」, 「鎖雨移到捆綁的 SP1」
>
> 「絞縄改成給捆綁的 L，捆綁的 SP2 換成解除並附加傷害（有專屬動畫、可被防禦）」; 「絞縄本身帶拉近」, 「不冷卻，降低傷害並增加大前搖，通過降低優勢來控制
> 出招動機」, 「先還原再打，傷害 120（推薦）」

| Mode | Button | Was | Now |
|---|---|---|---|
| ranged | SP2 (Shift+L) | 鎖雨 KUSARI-AME | **首掛 KUBIKAKE**, the binding throw: its data, rules and `:on-land` as §17.2, **`:cost 0`** (no bar spent); his own 200 checked at the press (HS-BK-OK: refused with the cue under 200, while it cools, with a bind up) and at contact; the 180 f cooldown set at its first frame (HS-KUBI-START); from neutral (the generic SP2 states) or **cancelled off any J / K hit** through its copy `:hs-r-kubikake-c` (`:enter` 6, S_eff 18: the hit-confirm combos off every link, J1 39 < 43, K1 46 < 51 with the hitstop; SP2's copy pattern) |
| ranged | P | KUBIKAKE | **nothing** (the ranged kit has no `:p` / `:p-label` hook, so the touch deck hides the AWAKEN chip there) |
| bind | SP1 (Shift+K) | 綴雷電 TSUZURI RAIDEN | **鎖雨 KUSARI-AME**, the same move (its data kept, the dead zone too); the SP1 cost (1 bar, from the shared pool); off a J / K hit its charge-less copy `:hs-r-sp2c` (S_eff 20: it combos off the bind's K links, not off its J's flinch 18) |
| bind | L | 引寄 HIKIYOSE (the pull, no hit) | **絞縄 KOJO**: at f6 the noose drags the victim to 2.0 m at 18 m/s (HS-PULL-STEP, motion only, until it arrives or S), then the reap 3.0 m arc 160°, crumple; **no cooldown, no cost**; S 20 → **30**, R 30 → **36**, damage 160 → **70**, block −16 → **−24**, on hit **0** (crumple 40 against S + A + R − S = 40: neutral) |
| bind | SP2 (Shift+L) | 絞縄 KOJO (2 bars) | **解縛擊 KAIBAKU-GEKI** (`:hs-b-sp2`): no bars; at its S (f18) the release is due as P's (HS-KAIBAKU-GO): at the step's release slot the snapshot comes back and the pool goes to the opponent first, then the step's hits take its strike, **120 real** (no grey, no drain, no ×1.2 / tip); the opponent's 30 f reel after the hits (HS-BK-TICK: the longer of it and his reaction, as every end); no UNWIND (his move is the strike). Blocked or whiffed: the release still happens, no damage (a block takes the generic SP chip and blockstun, then the reel) |
| bind | P | 解縛 the release | unchanged (the plain release, UNWIND) |

- HIKIYOSE is gone as a move of its own (its pull lives in L); its clip `:hs-kb-hikiyose` is KAIBAKU-GEKI's stand-in
  (`:hs-kb-kaibaku` in `*hs-r-clip-stand-ins*`) until the art batch draws the strike. The old bind SP1 RAIDEN
  (`:hs-b-sp1`) stays defined for its clip strip only (no kit plays it); the old KOJO SP2 and its copy are deleted.
- **KAIBAKU-GEKI's frame data (B4c's pick, the coordinator's example):** S 18 / A 4 / R 28, 120, guard 22, block −14
  (blockstun from it, then the 30 f reel takes over), reach 3.0 m arc 140°, knockback 2.0 m; on hit the knockback's 30
  f and the reel's 30 f agree; on a whiff the reel 30 f from f18 against his recovery to f50: about −2.
- **Knobs:** `*hs-kojo-s*` 30, `*hs-kojo-r*` 36, `*hs-kojo-dmg*` 70, `*hs-kojo-block*` −24 (the lead's numbers for the
  user's direction), `*hs-kojo-pull-at*` 6 (B4c's pick: from 8 m he arrives by f26), `*hs-kaibaku-dmg*` 120 (the
  user's); `*hs-pull-min*` (HIKIYOSE's 2.5 m refusal) deleted; `*hs-ai-pull-p*` → `*hs-ai-kojo-p*` 0.1 / 0.2 / 0.3 (L KOJO
  once per entry into 2.5–4 m, sparingly); `*hs-ai-plain-release-p*` 0.1 / 0.15 / 0.2 (new); `*hs-ai-throw-p*` (0.2 /
  0.45 / 0.7) now per confirmed J / K hit.
- **The CPU:** ranged: no neutral throw any more; on every confirmed J / K hit with his 200 and the victim inside the
  throw's line (HS-R-REACHES-P), one roll `*hs-ai-throw-p*`: the SP2 cancel into KUBIKAKE (`ai-throw`), before the route
  pick (links 1–2: HS-R-AI-MOVE; link 3: HS-R-AI-ENDER, else SP1 above 300 as before). Bind: once per change event while
  behind on grey (`*hs-ai-release-p*`), SP2 KAIBAKU-GEKI with the foe within 3.36 m (`ai-kaibaku`), else the plain P
  `*hs-ai-plain-release-p*` of the time (`ai-release`); L KOJO at 2.5–4 m (`ai-kojo`); its SP off a link 3 only SP1 (the
  rain's copy) while ahead (`ai-bsp1`).
- **Tests (added to the block):** ranged SP2 = KUBIKAKE, `:cost 0`, the press spends nothing, refused under 200 / cooling,
  its cancel copy off a J hit (the move itself off a blocked one), ranged P inert (no `:p` hook), the copy's data; bind SP1
  = the rain at 1 bar, its copy off a K hit; bind L's drag (8 → 2.0 m in 20 steps, by f26, the move's frames untouched,
  none at S), its numbers, 0 on hit, no cooldown, no cost, refused nowhere; KAIBAKU-GEKI's data, the release at its S
  (the snapshot back, no UNWIND, his move kept), then 120 real outside the bind, the reel once after the hits, nothing
  unbound (and refused); P still the plain release (UNWIND, no reel flag); the bind pool pays the rain but not SP2.

**Debug.** 83016 the ranged mode 2.5 m from an idle Kenpachi (the gathered route: K K K / K K J / K J J), 83017 3.5 m
from him (the spread route: J J J / J J K / J K K), 83011 KUBIKAKE started (SP2's move now), 83018 unchanged. New pacing
keys: `uchi-push`, `ai-dmg` / `ai-fast` / `ai-end`, `kaibaku`, `ai-kaibaku`, `ai-kojo`; gone: `mark`, `mark-lead`,
`mark-replaced`, `k3-slams`, `ai-kj` / `ai-kk` / `ai-k3`, `opp-step-mark`, `kubi-refused` (a refusal is the :ok hook's
cue now), `ai-pull`, `ai-bsp2`; `pull` / `pull-arrive` are KOJO's drag.

**Tests** (`tests/duel-rules-test.lisp`, 9765 checks ALL PASS; 9697 before). The generic string walk now takes his ranged K1 as a normal K1 (S 16
inside the 16–20 band; only S(K1) − S(J1) ≥ 7 excepted, §17.1) and his route K links at S_eff 15 / 21; his J links' block
gaps ≥ the Step's iframes (the gathered J's 14–15 f pinned in his block); gathered K2's combos pinned in his block from its
last hit (the launch's 41 f); the "K reaches ≥ J + 0.5 m" rule excepts his link 1 only (K1 3.0 vs J1 4.5: the user's table;
links 2–3 hold, 6.0 vs 5.0). His block pins: the ten moves' S / A / R / dmg / guard / block / reach; the ratios against
the base numbers (S −3 / +3, ×0.85 / ×1.3, K2 25 + 32 = 57, `:enter` 6 on the K links); the strings' links = the spread
and gathered lists; all six routes by opener (and JKJ eaten); the enders; the route damage on hit (combo scaling from hit 4)
JJJ 67, JJK 97, JKK 115, KKK 174, KKJ 132, KJJ 108 (B4a: 74 110 132 162 126 104); the dead zone on every ranged move but
K1, L and the Breaker, and on no other move of the game; the volumes (K1 all round to 3.36 m from 0, K2s 60°, K3 160°,
K2's slam 2.0–4.36 m and its line 2.64–8.86 m, J2s to 5.86, K3G 360° to 6.36, J3G 180° to 5.36); K2's push (only off
its first window, done by f31–34, before / inside hit 2's f33–36); the launch's air time and height at K3G / J3G's hit;
every link combos with its hitstop; the SP2 copy and SP1 off J1 / K1; the O ender off all four enders; the J pushes
(J2s none, J3G 5.5); the marks' functions gone and no ranged K with an `:on-frame`; HS-R-REACHES-P; the drawn reach of
B4a's clips (the letout frames now compared in the clip's own frames, `:clip-s`). duel-control-test 89, learn-test 131
ALL PASS; `tools/pkgcheck.sh duel` clean; `./build.sh duel` with only the 4 known Lille style warnings.

**Gates on the worktree (parent b42e2f9; `simgate --seeds 10 --summary`, the whole batch: the routes and the buttons
moved).** The 42 summary lines of the 21 pairings without him are byte-identical to the parent's (`cmp`; the parent built
from an archive of b42e2f9, `[simgate] building` lines filtered), also after the `ai.lisp` clause move; `--cvc` yy / yk /
kk PASS, identical to `tests/style-cvc-ref.txt`. His 7 pairings at 10 seeds (parent = B4a → B4c):

| Pairing | K.O.s | Median (s) | Wins (H as P1) |
|---|---|---|---|
| HY | 10 → 10 | 130.9 → **121.6** | 4 → 3 of 10 |
| HK | 10 → 10 | 124.6 → 138.1 | 1 → **0** |
| HR | 10 → 10 | 176.4 → 191.4 | 1 → 2 |
| HI | 10 → 10 | 171.1 → 170.6 | 2 → 1 |
| HS | 10 → 10 | 192.1 → 180.7 | 1 → 3 |
| HB | 10 → 10 | 152.2 → 179.6 | 1 → 1 |
| HH (mirror) | 9 → 10 | 228.6 → 232.6 | 4 → 2 |

The quick pass (all K.O., 135–200 s) does not clear HY (121.6 s; a mirror may exceed 210): the lead's 20-seed gate
decides. No knob was retuned for the window. (The routes alone, before the buttons moved: HY 141.3, HK 145.8, HR 174.8,
HI 180.3, HS 165.0, HB 173.5, HH 272.0 s with 2 time-outs; his P1 wins 2 / 3 / 1 / 1 / 3 / 0 / 5.) A 3-seed HK pacing
sample: `ai-throw` 6 (the SP2 cancel), `kubi-hit` 2, `binds` 2, `ai-kaibaku` 1, `end-released` 2, `end-drained` 1,
`ai-kojo` 3, `ai-dmg` 4, `ai-fast` 1, `ai-saharai` 20, `r-near` 3487 frames (he still spends long inside 2 m).

**Browser smoke** (`run.mjs --fixed-dt 16.666667`, 54 s, keyboard script, no JS / WebGPU error, exit 0): 83016 K K K
(the victim launched by K2, 193 off him, pushed to 8.0 m), K J J (120); 83017 J J J (80), J K K (122), J then Shift+L
(KUBIKAKE's cancel copy: the bind, the pool 600); in it Shift+K (the rain: 70 + 90 grey); 83012 L (KOJO: dragged 3.0 →
2.0 m, 70 grey), Shift+L (KAIBAKU-GEKI: both snapshots back, then 120 real, the pool's 350 split 300 / 50, the ranged
mode); 83018 a CPU zone game for 15 s (the CPU bound Rukia). Debug 83901: every Bankai look 0 B but SHIBARI 131096 and
SP2 262168, the first-call fx-buffer growth §21.8 noted (the marks' line gone).

**Known issues** (for the playtest and B4b).
- **A K1 hit inside 2.0 m has no follow-up that reaches**: every gathered link keeps the dead zone (the table), and K1 has
  no push, so K1 at point blank is a lone 40 stagger (the CPU ends the string there: `ai-end`). A lever for the user: a
  K1 hit pushing the victim to ≥ 2.0 m (as J1 / J2's push), or K2's slam without the dead zone.
- K2's second hit is a launch, not a knockdown (above): the user's call.
- The gathered J links on block leave 14–15 f (every J1 of the roster beats them; the spread J leave 8 f): the price of
  「聚 +3 幀」.
- The generic CPU branches (a punish, the pressure reset) still read J1's reach without the dead zone (B4a's issue).
- The look is a stand-in for seven of the ten route links (above), and for KAIBAKU-GEKI (HIKIYOSE's gesture).
- **The rain in the bind keeps its 2.0 m dead zone** ("its data kept"): inside the bind (fought at 0.8–1.2 m) it misses
  point blank; it hits from 2.0 m (after an L push-out, a K link's spacing). For the user: a bind copy without the dead
  zone, if wanted.
- The rain's charge-less copy combos off the bind's K links but not off its J's flinch 18 (S_eff 20); RAIDEN (S 14) did.
- After a KUBIKAKE hit (+16) only the bind J1 (S 8) combos now (the bind's SP1 is the rain, S 30).
- HIKIYOSE's long-range pull (beyond 4 m) is now KOJO's, inside a 30 f startup: from 8 m he arrives by f26.

**What the art batch B4b must draw, per route.**
- K1 綁束: the hanging chains spun round him (360°, r 3.0 on f16–19) and bound into one bundle (it stays a bundle for
  the gathered links).
- Spread: J2 the other side's curtain (B4a's clip, now S 10), K2s several thin chains whipping the ground in a 60° fan
  to 6.0 m (S 21), J3 the full turn to 5.0 m (S 10), K3 every hanging chain lashed forward in a 160° fan to 6.0 m (S 21).
- Gathered: K2 the U → L: the bundle arcs over and slams 2.0–3.5 m ahead (f27), then its tail lashes on along the ground
  to 8.0 m (f33) and lies flat ahead; J2s a quick straight lash of the bundle to 5.0 m (S 16); K3G the lying bundle
  hauled into a 360° spin to 6.0 m (S 27); J3G a flat sweep of the bundle, 180° to 5.0 m (S 16).
- The bind: L KOJO's drag on the noose (f6 to the strike at f30) then the reap (KOJO's clip at S 30 for now); SP2
  KAIBAKU-GEKI's own release-and-strike (`:hs-kb-kaibaku`: the noose thrown off at f18, then the blow, 3.0 m 140°); the
  ranged SP2 is KUBIKAKE's clip (unchanged).
- The drawn reach on the hit frames within 0.15 m of each volume's far edge (the host checks read `*hs-strike-reach*`,
  `*hs-letout*`, `*hs-bk-chains*`); then delete the move's entry from `*hs-r-clip-stand-ins*`.

### 22.7 B5 cinematics as built (2026-10-18)

> 「覺醒跟毀魂技的動畫的記得要做」 (the user, 2026-10-18)

Four scripts in `duel/lisp/hisagi-art.lisp` ("the cinematics (batch B5)"), built from §22.5's revised storyboards (the
Shikai Kikon from §11.5's table). Hooks in `hisagi.lisp`: the `:bankai` kit's `:cine hs-awaken-cine` (combat.lisp
AWAKEN! plays it, as every awakened form's), and the three Kikon moves' `:cine` (`:hs-kikon` → `hs-kare-cine`,
`:hs-r-kikon` → `hs-kosa-cine`, `:hs-b-kikon` → `hs-koshu-cine`; KIT-KIKON-CINE also plays each for that form's Soul
Break). B2a's placeholder `hs-kikon-cine` is deleted. No move's frame data, volume, damage or reaction changed.

**Machinery (a look).** HISAGI-DRAW reads the running script's frame (`hs-cine-of`, `%hs-cine-look!`, 0 B): the
awakening's Shikai look and orb forming, KŌSA's curtain hauled up and dropped back, KŌSHU's forced noose and sinking orb,
the Shikai Kikon's sickle flight (`hs-kare-codes`) and KŌSHU's garrote. `%hs-orb-draw` takes `*hs-cl*` (the orb's
growth, the curtain's drop, the neck bundle's descent, a height offset, placed at once); the match fills 1 1 1 0 0, so
its floats are unchanged. A skipped or aborted script leaves nothing behind (CINE-END's REFRESH-LOOK restores his body
and weapon). The scripts' own looks are DURING functions: the whirlpool (`%hs-aw-whirl`), the black wind
(`%hs-aw-wind`), the coils winding on (`hs-aw-coil`), the orb gathering (`hs-aw-gather`), the giant rope and the black
wave (`hs-kosa-rope`), the crack (`hs-kosa-crack`), the rain of chains (`hs-koshu-rain`). New clips: `:hs-aw-still`,
`:hs-aw-throw`, `:hs-aw-catch`, `:hs-aw-rise`, `:hs-cine-raise`, `:hs-cine-shake`, and the victim's `:hs-cine-choke-v`;
the rest are his own move clips. New brush glyphs (glyphs-extra.lisp, baked with tools/glyph-bake.py's GLYPH from the
same Yuji Syuku font): 絞 降 and the ruby's ふ こ う じ ょ.

**Staging.** Each Kikon script first puts him 3 m in front of the victim, where the placeholder left him for the reset
that follows (combat.lisp RESET-ROUND places both from where they stand). It then stages its own distance with
CINE-PLACE, and he is given the 3 m place back however the script ends (`hs-cine-stage`). This keeps the gate rows
byte-identical (below). The awakening moves no one.

**The awakening 卍解 風死絞縄 (168 f, `hs-awaken-cine`).**

| Beat | f | Camera | Action as built |
|---|---|---|---|
| 1 | 0–20 | close on his face, 16°, 1.25 → 1.07 m, lens 36 | the Shikai body, head bowed, eyes down (neutral face), the rods hanging, the chain slack; the opponent held; a 2 f negative, silence |
| 2 | 20–50 | low (0.3 m), 34°, 3.1 m, aimed 2.1 m up, lens 74 | sunk low, then the whole body thrown up (f32): both Kazeshini leave his hands, tumbling round a rim rising to 3.5 m; their ink chain twists down into a funnel over his head; dark wind streaks circle it (f36–50) |
| 3 | 50–70 | wide, 62°, 9.5 m, lens 50, him left of centre | 卍解 / BANKAI stamp; a 2 f negative, a 6 f manga frame, a shake, a dust ring 6 m; 22 black streaks burst out to 8 m and fade |
| 4 | 70–100 | medium, 38°, 3.3 m, lens 42 | silence; the world greys (desaturation to 0.7 by f84, to the end); the blades caught low (f70); the right arm held out, his head turned to it, as 113 black links wind up the forearm, the upper arm and round his neck (f74–89); the coiled `:hisagi-bankai` body from f90 |
| 5 | 100–135 | tilt: low behind his left shoulder (150°, 6.2 m), aimed from 1.3 m up past the frame's top to the orb (f100–112), held, back down (f118–132) | his face up to the orb; the orb grows (f100–116) as six black chains spiral into it; the curtain drops (f114–126); the four-chain bundle comes down (f118–130) and ties round his neck (a snap, f130); the pale patch grows with the orb |
| 6 | 135–168 | wide, both: 30°, 7 m + 0.6 × the gap, him on the left | the CFYOW stance under the curtain; 風死絞縄 with the ruby ふしのこうじょう (the caption's second column), FUSHI NO KOJO, — BANKAI —; no chain reaches the opponent |

**The Shikai Kikon 刈れ (180 f, `hs-kare-cine`).**

| Beat | f | Camera | Action as built |
|---|---|---|---|
| 1 | 0–24 | his left side, low (1.0 m), 5.2 m from the pair's middle, lens 38; 3 m apart | the victim reels (held 8 f); `:hs-s-kari-aim`: the chain whirled overhead, the blade across his face; silence |
| 2 | 24–54 | over his left shoulder, 2.3 m behind him, lens 38 | `:hs-s-kari-o` (S at f30): the left sickle thrown flat as the spinning disc, through his left fist; it nicks the victim (f34: a spark, his flinch) and flies on to 6–7 m |
| 3 | 54–84 | low (0.4 m), 62°, 4.2 m, lens 60 | `:hs-s-hiki` (S at f60): he drops and pulls; the sickle comes back through the victim's back (f63): the white card, the victim a black silhouette, held 4 f (2 drawings); a heavy spark |
| 4 | 84–120 | side-on to the pair, 4.4 m, lens 46; 1.4 m apart | `:hs-s-kubikake`: the chain over the head (the garrote through his neck), the yank (f90: focus lines on the neck, the victim's crumple), the slam (f98: the victim down, a 2 f negative, a dust ring, an ink splash, a 6 f manga frame) |
| 5 | 120–156 | nearly top-down, 6.4 m up, 2 m off | flash steps round the kneeling victim (f120 / 124 / 128, an afterimage each, 60° → 180°); behind him, `:hs-s-kari` (S at f142): both sickles let out over his head and down; the Konpaku shatter, a negative, a 12 f manga frame |
| 6 | 156–180 | the white card, him alone, 30°, 5.2 m, lens 36 | `:hs-s-win`: the chain slack, the half-step back; 刈れ / 風死, KARE, KAZESHINI, — KIKON —, the hanko |

**降鎖 KŌSA (150 f, `hs-kosa-cine`).**

| Beat | f | Camera | Action as built |
|---|---|---|---|
| 1 | 0–25 | low (0.5 m) behind him (165°), 3 m, lens 50; 7 m apart | `:hs-k-kosa` at 0.45×: the right crescent raised, the left hand heaving the neck bundle up (held at its peak f17 from f38); silence |
| 2 | 25–60 | tilt: 160°, 3.2 m, aimed from 2 m up to the orb (f25–42), held | the curtain hauled up into the orb (f28–44); under it the eight chains twisted into one giant rope, lowered to 5.2 m (f30–52) |
| 3 | 60–90 | side-on to the lane, 15.5 m from its middle, 2.6 m high, lens 32 | the rope swung back over him (f60–68), whipped down 2 m ahead (f68–76, a shake, the crack sound), its end run along the ground to the victim (f76–90), the ground black behind it, black spray at its front; KOSA's own bundle whip (S at f61) |
| 4 | 90–120 | on the victim, 35°, 3.8 m, lens 48 | the impact (a 2 f negative, a heavy spark, his crumple); the white card with his silhouette f92–96 (2 drawings); the Konpaku shatter (f96), a 10 f manga frame; a jagged crack along the lane from 1.2 m ahead of Hisagi to the victim (to f150, fading from f130) |
| 5 | 120–150 | wide, 125°, 8 m, him on the left | the rope hauled back up (to f112), the curtain drops back (f120–134); `:hs-k-stance`, the blade lowered; 降鎖, KOSA, — FUSHI NO KOJO KIKON —, the hanko |

**絞首 KŌSHU (180 f, `hs-koshu-cine`).**

| Beat | f | Camera | Action as built |
|---|---|---|---|
| 1 | 0–30 | the pair side-on, 7 m, tracking, lens 44; 6 m apart | `:hs-kb-koshu-run`: six flash-step hops along the line (f4–24, an afterimage each) to 1 m |
| 2 | 30–70 | the victim's front, 32°, 3.7 m, lens 46 | put 0.75 m behind his back; `:hs-kb-koshu` (S at f38): the chain drawn across his throat (the garrote); the victim's choke (both hands at the throat, the head back, a tremble); silence |
| 3 | 70–110 | low (0.45 m) on the victim, 35°, 5.8 m, aimed 2.6 m up, lens 62 | the orb sinks 3.4 m (f70–86); eight black chains drop from it onto him, one every 2 f (f80–101); from f96 three turns bind him standing (`:sh-bound`) |
| 4 | 110–150 | the victim's side, 68°, 3.8 m (f110); close on Hisagi's left side, 1.9 m (f132) | `:hs-cine-raise`: the right crescent straight up, his left hand at his own throat, the head back, a hurt face; the victim chokes; the noose bites (f128: a 1 f negative, a shake, focus lines on the neck) |
| 5 | 150–180 | his left side, 95°, 5.6 m, him on the left | the victim crumples; the Konpaku shatter, a negative, a 12 f manga frame; `:hs-cine-shake`: standing, hunched a little, shaking, the hand at his throat; 絞首, KOSHU, — FUSHI NO KOJO KIKON —, the hanko (f156) |

**Deviations from §22.5 / §11.5.**
- Awakening beat 1: no closed-eye face exists (the faces are neutral / shout / hurt), so his head is bowed with the
  neutral face. The green Reiatsu of §11.5 stays out (the user's rule: green only in the effects).
- 刈れ beat 1: the line 「怖いか？」 is not shown (no spoken-line caption; 怖 and ？ aren't baked).
- 刈れ beat 5: the victim kneels for the reaping cut (he is slammed down in beat 4).
- KŌSHU: the noose is drawn whatever the bind state, so a Soul Break after a drained bind still shows it.
- Beat lengths follow the tables; KŌSA's beat 3 is shared: the whip f60–76, the wave f76–90.

**Debug.** 83965+c starts cinematic c from a fresh scene (0 the awakening, AWAKEN! itself, 6 m from an idle Kenpachi;
1 刈れ 4 m; 2 KŌSA 7.5 m; 3 KŌSHU, a bind 2 m), played through; 83970+b restarts it held at beat b's middle
(`*hs-cine-beats*`: awakening 10 36 60 85 117 152; 刈れ 12 40 64 94 140 168; KŌSA 12 42 75 113 135; KŌSHU 15 50 92 122
165); 83976 lets go (DUEL_GAMEPLAY "Debug commands").

**Proof.**
- `simgate --seeds 10 --summary`, against the parent b42e2f9 (`git archive`, the `[simgate] building` banner filtered):
  the 21 pairings without him are byte-identical (42 lines), and `--cvc` is identical (yy / yk / kk PASS).
- **The three Kikon scripts are sim-neutral.** A run without the awakening's `:cine` gives his 7 pairings the parent's
  rows: the same play-time list, KOs and wins. Only the "with the cinematics" median moves, because the scripts are
  longer than the placeholder's 120 f.
- **The awakening is a sim change**, as every awakened form's cinematic is: AWAKEN!'s cinematic holds the opponent and
  returns both to idle (his slide from the awakening's repel is cut, a reaction ends, the buffered presses are dropped).
  His 7 pairings move. At 20 seeds, parent → B5:

  | Pairing | Median | P1 wins |
  |---|---|---|
  | HY | 129.4 → 124.1 s | 4 → 5 |
  | HK | 116.0 → 114.3 s | 1 → 0 |
  | HR | 147.5 → 168.9 s | 1 → 2 |
  | HI | 171.1 → 175.5 s | 5 → 3 |
  | HS | 187.6 → 177.4 s | 3 → 5 |
  | HB | 169.6 → 170.4 s | 1 → 1 |
  | HH | 228.6 → 261.1 s (KO 18 → 19 of 20) | 8 → 12 |

  Every cross pairing is K.O. 20/20. HY (124.1) joins HK (116.0 already at the parent) under the 125 s floor.
- Host tests ALL PASS (duel-rules 9697, duel-control 89, cine 18); `tools/pkgcheck.sh duel` 0 / 0 / 0; `./build.sh duel`
  with only the 4 known Lille style warnings.
- Debug 83901 is 0 B in every state on the repeat call (the first call after the scene grows the fx buffer once, 131 KB
  at the bind and 262 KB at SHIBORI, as before).
- **Stills** (`tools/run.mjs --fixed-dt 16.666667`, 83965+c then 83970+b; one per beat, mid-beat), 1280×720 and
  720×1280: 22 per aspect, contact sheets per cinematic.

**Known issues / for the user's eyes** (checked by stills, needs your eyes):
- The awakening's sim change (above) needs the lead's gate verdict. If the gates must stay byte-identical instead,
  remove the `:bankai` kit's `:cine` (one line): he then awakens with no cinematic, as before.
- Portrait: in 刈れ beat 1 the victim is out of the frame (Hisagi alone, the whirl); in beat 6 the reading runs close to
  him. In KŌSHU beat 5 the caption overlaps the pair's upper edge.
- The face has no closed eyes (beat 1); the victim's choke pose is drawn on the shared rig (the hands near the throat,
  read best from the front).
- The whirlpool (awakening beat 2) is small in the low wide shot; the awakening's wide shots frame the opponent only in
  beat 6.
- KŌSA's rope is 8 black chains of 14 pieces each (`%hs-bundle`) every frame from f25 to f112. SwiftShader
  draws it slowly; a phone check belongs to the playtest.
- KŌSHU at a Soul Break draws the noose and the forced garrote whatever the bind state.

**B5 merged with B4c, gate (the lead, 2026-10-18; main a979cd9, 20 seeds).**
- The awakening's cinematic goes through the shared awakening path (the opponent held, both to idle after), so his
  pairings move. The lead accepts this as every awakened form's normal behaviour.
- The 42 non-Hisagi lines and `--cvc` are byte-identical.
- His pairings: all K.O. 20 / 20; every cross-pairing median inside 125–210 s.

  | Pairing | Median | His P1 wins |
  |---|---|---|
  | HY | 128.3 s | 4 |
  | HK | 129.2 s | 1 |
  | HR | 171.6 s | 3 |
  | HI | 177.1 s | 2 |
  | HS | 163.4 s | 7 |
  | HB | 167.9 s | 0 |
  | HH (mirror) | 234.1 s | 10 / 9, 1 draw |

### 22.8 K1 far only, the ranged L without cooldown, the rain close in (the user, 2026-10-18)

The user's request, verbatim:

> - 讓 K1 只能打中遠方的敵人，近身的敵人要靠 L 快速擊退（去掉遠程時 L 的冷卻，一樣調整前後搖來控制出招的主動性）
> - 鎖雨改成近距離也打得中
> - 聚合 K2 的第二下改成「浮空」

What changes (the lead's numbers for the user's direction; batch B4d, a sim change):
- **K1 綁束** gets the 2.0 m dead zone back and reaches farther: an annulus 2.0–4.0 m, 360° (was r 3.0 with no dead
  zone). The rest of its data is unchanged.
- **The ranged L 鎖払 SAHARAI** loses its cooldown (120 → 0). It starts faster and recovers slower, so it is a quick
  repel with real commitment:

  | Knob | Old | New |
  |---|---|---|
  | Startup | 14 | 10 |
  | Recovery | 22 | 32 |
  | Block advantage | −4 | −16 |

  Its hit (push to 6.5 m), block push (4.5 m) and volume (360°, r 3.0) are unchanged. It is his only close-in tool.
- **The bind's SP1 鎖雨 KUSARI-AME** loses the 2.0 m dead zone: it hits at any range (its 10 m × 2 m lane from his
  feet).
- **Gathered K2's second hit** stays a launch (B4c's choice, now the user's).
- The CPU follows: K1 at 2.0–4.0 m; L whenever the foe is inside 2 m.

**B4d as built (2026-10-18; a sim change, `duel/lisp/hisagi.lisp` and its test block only).**
- **K1 綁束** (`:hs-r-k1`): `:vol (:arc 4.0 360 0.2 2.0)` (r 3.0 → 4.0) and `:min-reach *hs-r-dead*` (none → 2.0): an
  annulus 2.0–4.0 m all round (a hurt cylinder from 2.0 to 4.36 m). S 16 / A 4 / R 22 / 40 / guard 14 / −3, stagger,
  `:no-close`, `:clip-s 14` unchanged. The tip ×1.3 follows from the volume (HS-DIST-MULT reads the arc's r): 3.0–4.0 m.
  It still plays SAHARAI's ring as its stand-in (`*hs-r-clip-stand-ins*`, drawn at r 3.0), so the host drawn-reach checks
  still skip it, as in B4c; the art pass B4b draws it to 4.0 m and deletes the entry. No art table changed.
- **The ranged L 鎖払** (`:hs-r-l`): new knobs `*hs-saharai-s*` 14 → **10**, `*hs-saharai-r*` 22 → **32**,
  `*hs-saharai-adv*` −4 → **−16** (docstrings: the user's words, the lead's numbers, 2026-10-18); `:cooldown 120` removed
  (→ 0). Volume (360°, r 3.0), damage 30, guard 14, the hit push to 6.5 m and the block push to 4.5 m unchanged. Its clip is
  authored at S 14: `:clip-s 14` plays it at 1.4× so the strike lands on S 10 (its recovery holds the clip's last pose).
- **鎖雨 KUSARI-AME** (`:hs-r-sp2`, the bind's SP1, and its copy `:hs-r-sp2c`): `:min-reach` removed; the lane
  `(:cap 1.0 10.0 1.2 1.0)` reaches from his feet (a victim at 0.3 m is in both windows).
- **Gathered K2's second hit** stays `:launch` (B4c's; the existing pin `(:stagger :launch)` kept).
- **The CPU** (his ranged `:ai`): the 0–2 m band `:f 3 :sig 3 :step 3 :breaker 1` → **`:sig 6 :step 3 :breaker 1`** (K1
  can't hit there; L takes its weight); 2–3 m unchanged (K1 5 / J1 2 / Step 1, gathered first); the old 3–4.5 m J1 band
  split: **3–4 m K1 3 / J1 3 / Step 1** (K1's tip band, B4d's pick), 4–4.5 m J1 5 / Step 1. The `:reflex` HS-R-AI-REFLEX is
  unchanged: one roll per entry into < 2.0 m (`*hs-ai-saharai-p*` 0.3 / 0.6 / 0.85), never per step, so with no cooldown
  the reflex still cannot spam it; the band pick is the generic neutral decision's. The route picks (HS-R-AI-MOVE) as
  B4c: their reach read (HS-R-REACHES-P) now sees K1's dead zone. No other reflex of his read K1 close in.
- **Tests** (`tests/duel-rules-test.lisp` 9767 checks ALL PASS, 9765 at the parent): K1's row reach 4.0, its dead zone
  (in the dead-zone list now; the rain and its copy out of it), its volume (misses at 0.5 and 1.9 m behind, hits at 2.0,
  3.0 behind, 4.3, 3.5 aside, not 4.4), its tip (×1.3 at 3.0 and 4.0 m, ×1.0 at 2.9), HS-R-REACHES-P (not 1.9, 4.3 yes);
  L's row 10 / 4 / 32 / 30 / 14 / −16, cooldown 0, the knobs, its clip speed 1.4, the pushes 6.5 / 4.5; the rain's
  windows without `:min-reach`, hitting at 0.3 / 0.8 / 1.0 / 10.3 m; the CPU bands (`:f` only inside 2.0–4.0 m, one band
  ending at 4.0, no K1 and some L inside 2.0 m). duel-control-test 89, learn-test 131, cine-test 18 ALL PASS;
  `tools/pkgcheck.sh duel` clean; `./build.sh duel` with only the 4 known Lille style warnings; `run.mjs` 8 s smoke exit 0.
- **Identity** (the parent a1c95a1 built from an archive, `[simgate] building` lines filtered): the 42 summary lines of the
  21 pairings without him byte-identical at 10 seeds (`cmp`); `--cvc` yy / yk / kk PASS, identical to the parent's.
- **His 7 pairings at 20 seeds** (B4c's 20-seed gate, §22.6 → B4d):

  | Pairing | K.O.s of 20 | Median (s) | His P1 wins of 20 |
  |---|---|---|---|
  | HY | 20 → 20 | 126.5 → 128.8 | 7 → 6 |
  | HK | 20 → 20 | 131.5 → 132.7 | 0 → 1 |
  | HR | 20 → 20 | 168.4 → 151.8 | 3 → 5 |
  | HI | 20 → **19** | 179.4 → 167.4 | 3 → 6 |
  | HS | 20 → 20 | 165.4 → 162.8 | 6 → **11** |
  | HB | 20 → 20 | 177.9 → 158.3 | 1 → 1 |
  | HH (mirror) | 20 → **19** | 227.7 → 229.2 | 7 / 13 → 10 / 10 |

  Every cross-pairing median is inside 125–210 s, but **two matches time out** (one HI at 300 s, one mirror): "every match
  K.O." fails on those two rows. Reported, nothing retuned (the 10-seed pass showed the same two, HI and HH 9 of 10 K.O.;
  at the parent every match of both passes was a K.O.).
- **Known issues**: K1's look is still SAHARAI's r 3.0 ring for a 4.0 m annulus (B4b); L's recovery holds the clip's end
  pose for its extra frames; the generic CPU branches (a punish, the pressure reset) may still press K1 inside 2 m (B4a's
  issue for J1, now K1's too); the two time-outs above.

### 22.9 The bind's K ender push past K1's capsule (the user, 2026-10-18: 「修 A」)

The user's playtest question: 「卍解捆綁的近身 K 串打完後沒有把對手推出 K1 的攻擊範圍，這是刻意的設計嗎？」. It was not
intentional.

The cause:
- The generic ender push (fighter.lisp ENDER-PUSH) measures from the opener's reach. For the bind's K1 HIKIGIRI that
  is its capsule's length, 2.6 m.
- The push lands the victim at 2.6 + his body 0.35 + 0.05 ≈ 3.0 m.
- But the capsule is 0.35 m thick, so K1 touches a victim out to ≈ 3.3 m. A restarted K1 still reached him.

The options offered:
- A: fix him only, through the bind kit's `:push-reach`.
- B: fix the formula for everyone. Every other fighter's K1 is a capsule too, with the same formula; all 15 pairings
  would move.

The user took A: the bind kit's `:push-reach` is `*hs-b-push-reach*` 2.95 (2.6 + the capsule's 0.35), so the push
reaches ≈ 3.35 m. A host check pins it. B is not done; whether the others really reconnect after their K3 (most of
their K3 reactions keep the victim down) is unmeasured.

**Gate after A (the lead, 2026-10-18; 20 seeds).**
- The 42 non-Hisagi lines and `--cvc` are byte-identical.
- His medians: HY 128.8, HK 135.9, HR 160.6, HI 156.5, HS 158.6, HB 158.4 s, all in the window; HH 247.1 s.
- HI has one time-out (19 / 20 K.O.), as at B4d, and the mirror also has one.
- His P1 wins of 20: HY 7, HK **0**, HR **1**, HI 2, HS 8, HB 3.
- Reported; nothing is retuned.

### 22.10 Black chains in the Shikai too; P2's in the original white-edged ink (the user, 2026-10-18)

The user's request: 「另外始解的鎖鏈也同樣改成黑色，而 P2 的鎖鏈則改成原本的白色」. This is presentation only.

- Every chain HISAGI-DRAW draws is now the solid black kite (`%HS-BLACK-KITE`, §21.6) in both the Shikai and the
  Bankai, for P1's Hisagi.
- P2's Hisagi draws the original ink link (FX-SHARD, +PAL-INK+, the white value-opposite edge; the width the black
  ones lost, ×1/0.7). The switch is `*hs-chain-ink*`, set per side by HISAGI-DRAW and by the three cinematic chain
  helpers (the actor's side). A mirror's two sets of chains read apart.
- The Shikai's steel glint goes with the old look on P1; P2 keeps the ink link only, without the glint.
- The orb and the arm coils (meshes) are unchanged.
- Proof: `simgate --seeds 10 --summary` byte-identical to the A commit's; debug 83901 0 B everywhere; a mirror still shows P1's black chains and P2's white-edged ones.

## 18. Open

- The Bankai's look approved (the user, 2026-10-18: 「可以 但我希望鎖鏈是黑色的」, §21.6); its slot plan approved (§21.7), its clips built (batch B3b, §21.8: presentation only, waiting on the playtest). Still open: the awaken A/B (§20.9), waiting on the user's playtest.
- The two modes made distinct (§22): B4a built (§22.2: the sim, the CPU, a placeholder look); open: the playtest, his 7 pairings at 20 seeds and his awaken A/B, the art pass B4b.

- Answered (the user, 2026-10-17): Q9 A, Q10 A, Q11 A, **Q12 B** (no drip), **Q13 C** (no re-arm wait); the body follows them. To watch at the gates: a stalled bind (no drip) and the clock. Hooks 5 / 7 built as batch B1b (2026-10-17, §17.4 "As built"); the Shikai built as batch B2a (2026-10-17, §19); the Bankai's rules, bookkeeping and CPU as batch B2b (2026-10-17, §20; its look held for a motion-style pass). Open from B2b: the awaken A/B (both directions, §20), the HB / HH medians.

- The user's answers to §13; then a second review pass on what they change, and batch 1 (`duel-character`'s build order).
- The motion-style confirmation and its research (§11.2: kusarigama, rope dart, Blades of Chaos), then the model sheet
  stills.
