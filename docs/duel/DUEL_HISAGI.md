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
  5. the orb: one `reiatsu-gain!` for every Reiatsu gain, the exchange in `deal-damage` and in the scorch / mirror burns,
     the `*kikons*` filter at the start of `settle-souls`, the absorbed counter beside `gauges-dealt`, `orb-covered-p` for
     the generic CPU's Reishi reads;
  6. a move flag `:ranged-ward` (the windmill: hazards and `:ranged` windows guarded from every side; unguardables
     through; the crush drops the move);
  7. a kit `:p` hook (P in an awakened form, from a run too: the drop) and a kit `:awaken-ok` hook (the entry rule, the
     CPU's and the A/B's too);
  8. the CPU's ranged-threat reader.
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

## 16. Open

- The user's answers to §13; then a second review pass on what they change, and batch 1 (`duel-character`'s build order).
- The motion-style confirmation and its research (§11.2: kusarigama, rope dart, Blades of Chaos), then the model sheet
  stills.
