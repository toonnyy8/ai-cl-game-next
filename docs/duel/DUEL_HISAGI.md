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
  | 5 | (the bind support) | — | — | **held; re-specified for the bind in §17.4 (5a–5j)**, to build after the §17.6 answers |
  | 7 | (`:p`) | — | — | **held; re-specified in §17.4 (7a–7b)**; `:awaken-ok` dropped |
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

## 18. Open

- Answered (the user, 2026-10-17): Q9 A, Q10 A, Q11 A, **Q12 B** (no drip), **Q13 C** (no re-arm wait); the body follows them. To watch at the gates: a stalled bind (no drip) and the clock. Next: hooks 5 / 7 (§17.4) as batch B1b and the Bankai's two modes in B2.

- The user's answers to §13; then a second review pass on what they change, and batch 1 (`duel-character`'s build order).
- The motion-style confirmation and its research (§11.2: kusarigama, rope dart, Blades of Chaos), then the model sheet
  stills.
