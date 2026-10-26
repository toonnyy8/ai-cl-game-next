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
§13 is pending, the body assumes its recommended option (marked "Qn A"). Code prefix `hs-`, kit `:hisagi`, files (the file map since the split of 2026-10-21, refactor round 2;
older § name the files as they were when written): `duel/lisp/hisagi.lisp` (knobs, kits, rules, state, hooks, the Bankai's
rules and moves, debug), `hisagi-ai.lisp` (the Shikai's and the Bankai's CPU, the learner, ASSIST, and the `*hs-ai-…*` knobs, except
the three the kit data reads at load, `*hs-ai-string-k*`, `*hs-ai-l-after-j*`, `*hs-ai-awaken*`: they stay in hisagi.lisp; `*hs-ai-release-margin*` and its reader `hs-release-wanted-p`, superseded by `hs-rel-bar` / `*hs-ai-rel-margin*`, were deleted 2026-10-21, refactor round 2),
`hisagi-art.lisp` (body, Kazeshini, clips), `hisagi-draw.lisp` (looks, `HISAGI-DRAW`, the HUD icon, the name), `hisagi-cine.lisp` (the four
cinematics), `hisagi-stills.lisp` (debug stills and probes), in that load order; forms `:base` (Shikai) and `:bankai`. (There is no §3: the concept talk's numbering
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
| `*hs-ai-route-dmg-p*` | — → 0.3 / 0.55 / 0.8 | his CPU's damage pick (the K link) per link-1 / -2 hit (EASY / NORMAL / HARD); superseded by each route style's `:route-dmg` (`*hs-ai-r-styles*`, round01 b1a0) and deleted 2026-10-21 (refactor round 2) |
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
  SENSA. The host's drawn-reach checks skip the stand-ins; B4b deletes each entry it draws. (Drawn by batch A2 and their
  entries deleted, §24.2.)

**The CPU** (`duel-character-cpu`: one roll per event, EASY ≤ NORMAL ≤ HARD).
- The opener is the route: his ranged `:moves` bands 0–2 m K1 3 / L 3 / Step 3 / Breaker 1, 2–3 m **K1 5** / J1 2 /
  Step 1 (gathered first: the damage), 3–4.5 m J1 5 / Step 1 (spread), 4.5–8 m SP1 1 / wait 4 (nothing else of his
  reaches there), then as before; ranges approach 2.5–4.0, pressure 2.0–3.0, zone 3.0–4.5, defend 4.0–6.0.
- `:move-reflex` HS-R-AI-MOVE, one roll on each link-1 / link-2 hit's land step: the damage pick (the K link: spread K2s /
  K3, gathered K2 / K3G) `*hs-ai-route-dmg-p*` (since round01 b1a0 the style's `:route-dmg`; the knob deleted 2026-10-21) of the time when the victim stands inside its reach (HS-R-REACHES-P: past
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
  (`:hs-kb-kaibaku` in `*hs-r-clip-stand-ins*`) until the art batch draws the strike. (Drawn by batch A3, §24.3: the
  entry and HIKIYOSE's clip deleted.) The old bind SP1 RAIDEN
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
- The look is a stand-in for seven of the ten route links (above), and for KAIBAKU-GEKI (HIKIYOSE's gesture). (All
  drawn: batches A2 / A3, §24.2–§24.3.)
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
- (The seven ranged route links and the look: drawn by batch A2, §24.2; the bind's L / SP2 and the ranged L's recovery:
  batch A3, §24.3.)

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
byte-identical (below). The awakening moves no one. (Since 2026-10-23 every Kikon is first set down mid-stage by `cine-stage` and both actors get their own places
back; `hs-cine-stage` is CINE-PLACE alone: STYLE_STORM_DESIGN §5 "Staging", DEVLOG §315.)

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
  still skip it, as in B4c; the art pass B4b draws it to 4.0 m and deletes the entry. No art table changed. (Drawn to 4.0 m by
  batch A2, its entry deleted, §24.2.)
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

## 23. The Shikai's L as a bridge from J to K, charged reach (the user, 2026-10-18)

The user's request: 「然後始解的 L 我想讓 L 能變成 J 與 K 之間的銜接連段。並增加 L 蓄力越長，接上 K 連段時攻擊距離越遠的特性」.

Their answers:
- Where it links: 「J1, J2 或 J3 命中後按 L 進風車，風車結束接一整串 K1→K2→K3。L 不算連段的一段，是接在中間的橋。例：J1 J2 L K1 K2 K3。」
- The charge: 「連續：每幀 +1%，上限 ×1.6」
- What it scales: 「接下來整串 K（推薦）」
- The L from neutral: 「拿掉冷卻」

The spec (batch S1, a sim change, the Shikai `:base` only):
- **The bridge.** Off a J1, J2 or J3 hit, L cancels into the windmill 風車 KAZA. From the windmill, K starts a full K
  string (K1 → K2 → K3). L is not a segment; the string after it is a fresh K string.
- **The charge.** While L is held the windmill keeps spinning, up to its 60 f. Every frame held adds +1 % to the
  following K string's reach, capped at ×1.6. Releasing L or pressing K ends the charge. The scale applies to K1, K2
  and K3 of that string (their volumes' reach: K1's throw, K2's chain, K3's arc) and resets when the string ends or
  breaks.
- **The neutral L** keeps the windmill (its ranged ward), its cooldown 90 → 0. It also charges into K (the user,
  2026-10-18: 「中立的風車可以蓄力接 K」): held, then K starts a full K string with the scaled reach, as off the bridge.
  (This replaces the lead's first default, "only the J-hit bridge charges".)
- His CPU learns the bridge (J hit → L → K at range).

### 23.1 S1 as built (2026-10-18): the windmill bridge, the charge (a sim change)

`duel/lisp/hisagi.lisp` (the moves, knobs, the charge, the CPU, debug 83007 / 83008), `hisagi-art.lisp` (the charge cue,
the scaled strikes), one shared rule for §23.3 (`:hit-only`, fighter.lisp); host tests in `tests/duel-rules-test.lisp`
("Hisagi's S1"). The K string the bridge feeds is §23.3's (K1 薙 NAGI, K2 鋸 NOKO, K3 墜 TSUI), built in the same batch.

**What is built.**
- **The bridge.** The base kit's `:l-after-j :hs-kaza-j`: L pressed during a J1 / J2 / J3 link is latched and starts the
  windmill when that link's chain opens (the generic L link, DUEL_STRINGS §12). The game's link rule lets a latched L
  start after a blocked link too (in the link's last *CHAIN-LEAD* frames), so it is not hit-only: built as the rule is
  (the user's words say 「命中後」; making it hit-only is one flag, `:hit-only`, on the copy, and one line in the L-link
  path). Off the one-handed J2 / J3 (dormant since §23.3) L is refused by HS-OK as before (the sickle out). L is not a
  segment: `:hs-kaza-j` has no J / K follow-up of its own; K from it starts a fresh K string at K1.
- **The windmill copy `:hs-kaza-j`** is the windmill with its push a **stagger (26 f)** in place of the neutral one's 8 f
  flinch, so J → L combos (hitstop on both sides: J1's hit at f8, the push 3 + 6 frames later, inside the 18 f flinch) and
  **K pressed by the windmill's f14 combos into K1** (K at f9-f14: a charge of at most 9 frames, x1.09; from f15 K1 is a
  frame trap at range). The charge trades the combo for reach: a long charge is a reach tool, not a combo. The neutral
  windmill's K1 never combos (its 8 f).
- **The charge** (HS-CHARGE-NEXT): +1 per frame L is held from the up frame f6 to the last held frame, at most 60
  (x1.6); letting L go stops it for this windmill (held again: no more). **K from frame 9** (the push window's end) to the
  move's last frame (hold or recovery) starts K1 through TRY-COMMAND; HS-TICK swaps in K1's copy at the charge. A released
  windmill without K plays on as before: up at least 20 frames, then R 14.
- **The neutral windmill charges too** (the user, 2026-10-18: 「中立的風車可以蓄力接 K」): the same tick, the same rule; its
  cooldown 90 → 0 (「拿掉冷卻」).
- **What the charge scales.** K1 NAGI's arc (its r x (1 + n / 100), the 2.0 m dead zone kept; 61 copies parsed at load,
  `*HS-K1-SCALED*`, the same name, so the strings, hooks and CPU see K1). K2 / K3 follow the victim (§23.3), so they need
  no scale (§23.2: 「K2, K3 的攻擊距離會按照對手的位置決定」). The charge lives while he is in a windmill or in the K string it
  started (HS-KSTR-KEEP-P) and resets on any other move, a hit taken, neutral, a reset; a K1 from neutral never scales.
- **The ender push** stays measured from the uncharged 6.0 m (`:push-reach`): a restarted K string is uncharged (a charged
  one needs a windmill first: 6 + 3 + 18 frames after K3's 39 f of recovery, against its 40 f crumple), and pushing from
  9.6 m would put him out of the O lane (8.4 m) and SP1's line.
- **Presentation.** The windmill's disc grows with the charge (its circling radius x the charge: 1.6 → 2.56 m at x1.6);
  K1's flight drawn at the arc's edge at the charge (HS-SCALED-TIP: 6.0 x the charge; the arc has no radius); 0 B (debug
  83901 adds the windmill, NAGE and KARI-OTOSHI at x1.4: all 0).
- **The state hash** adds `k<charge><K|-><L|-><throw charge>`.

**Choices where the spec was silent:** K from f9 (after the push lands) to the windmill's end; the bridge's stagger (K1
combos after a short charge); block links allowed (the game's rule); the ender push unscaled; only K1 scales (§23.2).

**His CPU.** `:l-after-j` 0.3 (one roll per J-link hit: the bridge). At every L press but a ward against a ranged threat,
one roll *HS-AI-KAZA-K-P* (EASY 0.4 / NORMAL 0.7 / HARD 0.9): yes holds L its full 60 f and presses K once K1 at the charge
so far reaches him (the real distance within its line + 0.3 m, past the 2.0 m dead zone): off the bridge at once (the
combo), from range after the charge it needs; out of reach at x1.6, no K. The neutral windmill at 6.2-9 m (`:sig 1` in
that band): with no cooldown its weight is the only rate (one decision each time, never a per-step roll). The ward
against a ranged threat (HS-AI-REFLEX) holds 36 f and never Ks.

| Knob (hisagi.lisp) | Old → new | Who / when |
|---|---|---|
| `*hs-kaza-cooldown*` (both windmills) | 90 → 0 | the user, 2026-10-18: 「拿掉冷卻」 |
| `*hs-charge-step*` / `*hs-charge-max*` | none → +1 % a frame, 60 frames (x1.6) | the user: 「連續：每幀 +1%，上限 ×1.6」 |
| `*hs-kaza-k-from*` | none → f9 | S1's pick |
| the bridge `:hs-kaza-j`'s push | (the neutral's 8 f flinch) → stagger 26 f | S1's pick (K1 combos after a short charge) |
| `*hs-ai-l-after-j*` | none → 0.3 | S1's pick |
| `*hs-ai-kaza-k-p*` | none → 0.4 / 0.7 / 0.9 | S1's pick |
| `*hs-ai-kaza-margin*` | none → 0.3 m | S1's pick |

**Host tests** (duel-rules-test, "Hisagi's S1"; ALL PASS): the bridge off J1 / J2 / J3 (and the one-handed J2 / J3,
refused there), none off a K link, L not a segment, KKK after it; both windmills' cooldown 0, frames, tick, f0 reset; J1 /
J2 / J3 → L combos with hitstop; L → K1 combos for K at f9-f14, not at f15, never off the neutral windmill; the charge +1 a
frame from f6, 60 at most (x1.6), stopped by a let-go; K1's copies at every charge (frames, damage, flags, links, dead
zone the same, the arc x the charge, the drawn tip on its edge), K2 / K3 themselves at any charge; on stand-ins the charge
kept in a windmill and in its K string (K1's copy swapped in), reset by a J link, a neutral K1, a hit taken, neutral; the
hash fields; the ender push from 6.0; `:hit-only` (§23.3). duel-control-test, learn-test, cine-test ALL PASS; pkgcheck
clean; the build's only warnings the 4 known Lille ones.

**Debug** (DUEL_GAMEPLAY): 83007 2 m from Kenpachi, J1 started with L latched (the bridge: hold L, K); 83008 8 m from
him, the windmill started (hold L, K: the charged K1 at range). The probe line shows `charge n` (` K` in its string). The
gate line counts `bridge`, `kaza-k`, `charge` (frames, summed), `ai-kaza-k`.

**Browser** (one Chrome, `--fixed-dt`): a Shikai mirror (83005) ran with no error; 83901 every look 0 B (a first call's
KUBIKAKE / KOSA 128 / 256 KB are one-time warm-ups: the second call reads 0 everywhere); 83007: J1, the bridge's push
(20), K1 at x1.01 hit; 83008: the windmill charged 59 frames, K1 at x1.59 hit Kenpachi at 8.0 m.

### 23.2 The Shikai's K string pure ranged, J string close; the Bankai's two L (the user, 2026-10-18)

The user's request, verbatim:

> 始解
> - K 串改成純遠距離，近距離打不中，K1 是鎖鏈拉動鐮刀橫向遠程揮擊，K2 是鐮刀快速旋轉變成像圓鋸一樣豎直向前切割後被鎖鍊上拉，K3 將飛上天空的鐮刀用力下扯墜擊。K2, K3 的攻擊距離會按照對手的位置決定，所以一定打的中（重點是 K1, J1 有沒有打中）。
> - J 串依據上面的邏輯改成能互相串接的近距離攻擊。
>
> 卍解（遠距）
> - L 將對手推開的距離必須讓 J1, K1 能打中
>
> 卍解（近距）
> - L 將對手拉近時，增加拉近對手前的動作識別度與前搖時間，並減少攻擊效果的前搖。核心邏輯是對手在遠處時就知道要被拉近該準備防禦，而不是被拉近後才進行應對。

The user's answers:
- 「系統的設計邏輯本來就是 J1, K1 打中才能接後續攻擊」: K2 / K3 follow only a hit.
- 「2.0 m（推薦）」: the Shikai K dead zone.
- 「命中推到 3.0 m，被擋也推到 3.0 m（推薦）」
- 「前 20 幀預備，拉到後 4 幀就打（推薦）」

The spec (added to batch S1, a sim change).

**Shikai K string** (pure ranged, a 2.0 m dead zone on every K):
- **K1** is a horizontal long-range sweep: the chain swings the sickle sideways at range.
- **K2** follows only a hit. The sickle spins into a vertical circular saw cutting forward, then the chain hauls it up.
- **K3** follows only a hit. The sickle, flung up into the sky, is yanked down in a plunging strike.
- K2 and K3 are placed at the opponent's position (their reach is set from where he is), so after a hit they always
  connect (blockable).
- The L charge (§23) scales K1's reach; K2 / K3 follow the opponent anyway.

**Shikai J string:** close-range attacks that link into each other (every J link combos on a hit).

**The Bankai's ranged L:** the hit and the block both push the victim to 3.5 m (were 6.5 / 4.5 m).
- First set at 3.0 m. Then the user, 2026-10-18: 「卍解遠程 L 推到 3.5 公尺，J1 範圍設 3.0–5 m 和 K1 設 2.0–4.0 m」.
- J1 旋鞭 becomes an annulus 3.0–5.0 m, 100° (its own dead zone 3.0 m; the tip ×1.3 at 4.0–5.0 m). K1 綁束 stays
  2.0–4.0 m.
- At 3.5 m both J1 and K1 connect.

**The bind's L KOJO:**
- f0–20 a readable windup (the noose hauled up and taut: the tell).
- From f20 the pull.
- The strike about 4 f after the victim arrives.
- The total stays about 30 f.

Then (the user, 2026-10-18): 「卍解遠程 L 推到 3.5 公尺，J1 範圍設 3.0–5 m 和 K1 設 2.0–4.0 m」 (in place of the 3.0 m above).

### 23.3 §23.2 as built (batch S1, 2026-10-18; a sim change)

**The Shikai K string** (hisagi.lisp; the move ids kept, `:hs-k1` / `-k2` / `-k3`; §8.2's K rows superseded):

| Move | S / A / R | Dmg | Volume | Reaction | Rules |
|---|---|---|---|---|---|
| K1 薙 NAGI (the sideways sweep) | 18 / 4 / 22 | 62 | arc r 6.0 (x the charge, §23.1), **90°** (`*hs-k1-arc*`, S1's pick), h 0.2-2.0, **dead zone 2.0 m** (`*hs-k-dead*`, :min-reach) | stagger | `:ranged :no-close`, :track 30; no throw, no drag |
| K2 鋸 NOKO (the saw, hauled up) | 20 / 4 / 24, enter 6 | 56 | **the chain from his hand to the victim's centre** (`:seg-fn` HS-FOE-SEG, r 0.35) | stagger (S1's pick: hauled up without a launch, so K3 combos as every K link) | `:hit-only`; after K1 and after J1 (the cross link) |
| K3 墜 TSUI (the plunge, ender) | 22 / 5 / 34, enter 8 | 80 | the same, on the victim | crumple | `:hit-only`, `:ender`; after K2 and after J2; its push from 6.0 (`:push-reach`) |

- **Placed on the victim**: K2 / K3 strike along a chain to wherever he is that frame, so after a hit they connect (the
  victim in hitstun; blockable as any hit). They have no dead zone: it binds K1, the only K aimed at range (J1 → K2 sits
  inside 2.0 m by design: the cross link). The look draws their chain to the anchor, which HS-TICK keeps on him while they
  run.
- **Off a hit only** (「系統的設計邏輯本來就是 J1, K1 打中才能接後續攻擊」): the game's link rule also lets a link follow a
  block, so a new move flag `:hit-only` (fighter.lisp LINK-CONTACT-OK-P, read by MOVE-COMMANDS and by CHAIN-MORE-P, so the
  guard lock doesn't hold a blocker for a link that can't come) restricts K2 / K3. No other move has it (host-checked; every
  other pairing byte-identical).
- **Routes** JJJ (98), JJK (J1 J2 TSUI, 140), JKK (J1 NOKO TSUI, 166), KKK (198); **no J after a K** (KKJ, KJJ gone: the
  victim stays at range and nothing drags him in). The J links are as before; each combos on a hit with hitstop
  (host-tested), and J1 → NOKO / J2 → TSUI too.
- **The sickle never leaves his hand now**: no K throws it, so its OUT / RETURNING states, the OUT graph (SEN-1H /
  KAESHI-SEN-1H / RIN-1H, MODOSHI), MAKI and HODOKI are unreachable. Their code, clips and tests stay, dormant, for a
  cleanup batch (or the return of a throw); the L / SP2 refusal while out never fires.
- **Stand-in clips**: K1 plays NAGE's (its flight drawn to the arc's 6.0, back after the hit), K2 HIKI's, K3 HODOKI's (the
  chain to him); KARI-OTOSHI's clip is no move's now. The art pass draws the sweep, the saw and the plunge (done: batch A1,
  §24.1).
- His CPU: the close band no longer picks K (`:f` out of 0-2.0 m; 2.0-3.5 m keeps it); `:string-k` 0.7 picks NOKO after a
  J1 hit as it picked MAKI.

**The Bankai**: L SAHARAI's hit and block push to **3.5 m** (`*hs-saharai-hit*` 6.5 → 3.5, `*hs-saharai-block*` 4.5 →
3.5); J1 旋鞭 an annulus **3.0-5.0 m**, 100° (`*hs-r-j1-dead*` 3.0 in place of `*hs-r-dead*`, reach 4.5 → 5.0; its tip x1.3
on 4.0-5.0; its push to ≥ 3.5 m kept; the other links unchanged; its clip's let-out and drawn reach 5.0); K1 綁束 stays
2.0-4.0 m. His CPU's bands: 2.0-3.0 K (no J), 3.0-4.0 K / J, 4.0-5.0 J, SP1 from 5.0. The J ender push now measures from
J1's 5.0 (~5.43 m), then J3's own push to 5.5 m, still past J1.

**The bind's L KOJO**: `*hs-kojo-pull-at*` 6 → 20 (f0-19 the tell; 「前 20 幀預備，拉到後 4 幀就打（推薦）」), S 30 kept;
`*hs-pull-speed*` 18 → 60 m/s so the drag still lands him from 8 m by f26, 4 f before the strike (host-tested); nearer
victims arrive sooner and wait longer (from 4 m: f22, 8 f). The tell is the clip's windup stretched over f0-29 (its
`:clip-s 20` on S 30); the art pass draws the noose hauled up and taut.

**Gates** (native; the lead re-runs them):
- Identity: `simgate --seeds 10 --summary`'s 42 non-Hisagi lines byte-identical to the parent 1451186's (a `git
  archive` baseline, `[simgate] building` lines filtered); `--cvc` PASS (yy / yk / kk identical).
- His 7 pairings at 20 seeds (NORMAL, P1 Hisagi; before = the parent 1451186):

| Pairing | KOs | Median s (before) | P1 wins (before) |
|---|---|---|---|
| HY | 20 | 137.4 (128.8) | 3 (7) |
| HK | 20 | 125.3 (135.9) | 1 (0) |
| HR | 20 | 141.4 (160.6) | 1 (1) |
| HI | 20 | 177.5 (156.5) | 3 (2) |
| HS | 20 | 165.6 (158.6) | 0 (8) |
| HB | 20 | 165.8 (158.4) | 1 (3) |
| HH | 18 (19) | 233.8 (247.1) | 8-12 (8-12) |

Every cross median inside 125-210 s (HK at the edge, 125.3); the mirror has 2 time-outs (1 before; a mirror may exceed
210). Usage (P1, 140 matches): 162 bridges, 107 K strings out of a windmill, 18.5 charge frames each on average.

**Known issues.** His P1 wins fell (9 of 120 cross matches, 21 before; HS 8 → 0): the Shikai lost its drag, its KJJ / KKJ
routes and K1's close range, and SAHARAI no longer buys 6.5 m; nothing retuned (the spec). The dormant OUT machinery
(above). The stand-in clips. KOJO's nearer victims wait up to ~8 f. The mirror's time-outs. The awaken A/B not run.

### 23.4 Links after a block; the Shikai's KJJ / KKJ leap in (the user, 2026-10-18)

The user's answers after S1, verbatim:
1. 「被防禦後也能繼續接連段」
2. 「始解 KJJ, KKJ 時 J 會跳近對手進行攻擊」

The spec (batch S2, a sim change, the Shikai only):
- **Links after a block too.**
  - K2 / K3 lose S1's `:hit-only`: they follow a K1 / J hit or block, still placed on the victim (on a block, blocked).
  - The bridge (J → L) already follows a block.
  - The shared `:hit-only` flag stays, unused, unless nothing else needs it (a cleanup may drop it).
- **KJJ and KKJ restored, with a leap.**
  - A J link after a K (K1 → J2, and the J3 of K1 → J2 → J3 / K1 → K2 → J3) leaps in toward the victim during its
    startup, closing to J's reach (1.4 m), then strikes.
  - It is a lunge, so it is bounded by the K string's ranges (K1's 6 m × the charge, at most 9.6 m).
  - The leap's speed and frames are the lead's pick, so that the J lands as a link off the K's hitstun.

### 23.5 S2 as built (2026-10-18; a sim change, the Shikai `:base` only)

`duel/lisp/hisagi.lisp` (the copies, the leap, the grid, the CPU, debug 83009 / 83019), `fighter.lisp` / `kit.lisp`
(S1's `:hit-only` removed); host tests in `tests/duel-rules-test.lisp` (the string budget, "Hisagi's Shikai", "Hisagi's
S1" → S2's block).

**1. Links after a block** (「被防禦後也能繼續接連段」).
- K2 NOKO / K3 TSUI drop `:hit-only`: they follow a K1 / K2 / J1 / J2 hit **or block** at the game's link rule (on a
  block in the link's last *CHAIN-LEAD* frames), still placed on the victim (HS-FOE-SEG: on a block, blocked).
- No move used the flag after that, so it is gone: LINK-CONTACT-OK-P and its two calls (MOVE-COMMANDS, CHAIN-MORE-P)
  are back to the pre-S1 code, and kit.lisp's doc line too. The 42 non-Hisagi gate lines are byte-identical (below).
- The guard lock now holds a blocker of K1 / K2 for the next link as it does for every link (CHAIN-MORE-P).

**2. KJJ and KKJ restored, with a leap** (「始解 KJJ, KKJ 時 J 會跳近對手進行攻擊」).
- **The grid** (the game's six routes, one J / K switch at most):

| Route | Links | Damage (before x1.15) |
|---|---|---|
| JJJ | J1 SEN → J2 KAESHI-SEN → J3 RIN | 98 |
| JJK | J1 → J2 → K3 TSUI | 140 |
| JKK | J1 → **K2J** NOKO → K3 TSUI | 166 |
| KKK | K1 NAGI → K2 NOKO → K3 TSUI | 198 |
| KJJ | K1 → **J2K** (the leap) → J3 RIN | 130 |
| KKJ | K1 → K2 → **J3K** (the leap) | 156 |

  KJK and JKJ do not exist (a second switch: the grid's general rule). `:hs-k2j` is J1's own copy of K2 (the same
  data), so K1's K2 can go on with J without J1 → K2 doing so (JKJ). J2K's J3 is the plain J3 (he is close by then).
  The bridge (J → L) also follows J2K / J3K (they are J links). The OUT graph's one-handed J string is unchanged (dormant).
- **The leap copies** `:hs-j2k` / `:hs-j3k`: J2 / J3 with **S 14** (`*hs-leap-s*`, J2's 8 / J3's 9 → 14), **-6 on block**
  (`*hs-leap-block*`), the same damage, reach 1.4, reactions (flinch / stagger), recovery and J3's `:ender`, and the tick
  HS-LEAP-TICK. No other move leaps (host-checked): the leap is only in these two links.
- **The leap** (HS-LEAP-SPEED, each startup frame): STRING-CHASE-SPEED toward the victim's current position (re-aimed
  every frame), to J's chase goal 1.0 m centre to centre (reach 1.4 - 0.4, inside the J's reach) exactly as the hit window
  opens at f14; at most 60 × `*hs-leap-max*` / 13 m/s (44.3 m/s), so the whole leap covers at most **9.6 m** (K1's 6.0 ×
  the charge's 1.6). From 2-10.6 m it ends at 1.0 m (host-tested frame by frame); from farther it stops short; inside 1.0 m
  it doesn't move. It replaces the move step's velocity (a J link has no chase of its own).
- **On a hit it combos, hitstop included**: K1's chain opens at its f22 (S + A), J2K hits 14 f later: 18 f after K1's hit,
  inside its 26 f stagger (free at 18 + 8 hitstop + 1 + 26 against the hit at 22 + 8 + 14); K2 → J3K the same (its hit at
  f20, the chain at f24); J2K → J3 as J2 → J3. All in the host's combo loop with the hitstop on both sides.
- **On a block it is punishable**: the leap's 14 f startup after the blocked K's chain opens (the defender's gap ≥ 13 f: a
  Step, Hoho or his own ranged K fits; a J1 doesn't reach at range), then J2K / J3K at -6 (the defender -9 with the J's
  +3, *QUICK-BLOCK-ADV*): his J1 (S 8) punishes; J2K → J3 on block leaves a gap his J1 interrupts.
- **Placeholder clips** (stand-ins, marked in the code): from f1 the run (`:hs-s-run`) as the leap pose; from the frame
  the J clip's authored windup is left (`:clip-s` 8 / 9: f6 / f5) the J's own clip at speed 1, so it reaches its hit pose
  on f14 (the FK reach test samples the clip at `:clip-s` / S: the J's hit pose too). The art pass draws a real leap
  (done: batch A1, §24.1: each copy its own clip at S 14, `:clip-s` gone, HS-LEAP-TICK plays no clip).

**3. Choices where the spec was silent:** S 14 for both copies (the leap's frames: long enough to read, short enough to
combo); interpolation, not a fixed speed (the J always lands at J range as its window opens, whatever the distance); the
9.6 m cap applied as a speed cap; -6 on block; KJK / JKJ left out by the general rule (K2J the copy that makes it so);
the leap re-aims at the victim every frame (he may drift in his stagger).

**4. His CPU** (`:move-reflex hs-ai-move`, before the generic string reflex): on a K1 / K2 hit, on its land step, one roll
when HS-AI-LEAP-WANTED-P (the victim beyond the K dead zone 2.0 m, and his intent :approach / :pressure: the J route ends at
J range, where his J string, the bridge and SP2 SHIBARI follow): `*hs-ai-leap-p*` EASY 0.3 / NORMAL 0.5 / HARD 0.7 → J
(KJJ / KKJ), else K (the K string, at range). At :zone / :defend, in the dead zone: K, no roll. A learner baiting its Burst
read: the generic reflex. (Before S2 a K1 hit always went on with K: there was no J.) After a blocked K1 / K2 the generic
guard pressure may pick J2K (-6 > the ender floor) as any J link.

| Knob (hisagi.lisp) | Old → new | Who / when |
|---|---|---|
| K2 / K3 `:hit-only` (and the shared flag) | on → gone | the user, 2026-10-18: 「被防禦後也能繼續接連段」 |
| the Shikai grid | JJJ JJK JKK KKK → + KJJ KKJ (J2K, J3K; K2J) | the user, 2026-10-18: 「始解 KJJ, KKJ 時 J 會跳近對手進行攻擊」 |
| `*hs-leap-s*` | none → 14 (J2 8 / J3 9) | S2's pick |
| `*hs-leap-max*` | none → 9.6 m | the spec's bound (K1's 6.0 × 1.6) |
| `*hs-leap-block*` | none → -6 (J2 -2 / J3 -4) | S2's pick |
| `*hs-ai-leap-p*` | none → 0.3 / 0.5 / 0.7 | S2's pick |

**Host tests** (ALL PASS: duel-rules-test, duel-control-test, learn-test, cine-test): the string budget's six routes for
every form again (the Shikai's leap copies' -6 and block gaps its exceptions); the routes (JJJ JJK JKK KKK KJJ KKJ, no JKJ /
KJK) and their damage 98 / 140 / 166 / 198 / 130 / 156; every link combos with hitstop (S2's K1 → J2K, K2 → J3K, J2K → J3,
J1 → K2J, K2J → K3 too); J3K → the O lane inside its stagger; the copies' data (S 14, :clip-s 8 / 9, -6, punishable by
his J1, the tick only on them, the bridge off them); the leap from 2.0 / 3.0 / 4.5 / 6.0 / 8.0 / 9.6 / 10.6 m ends at
1.0 m within 9.6 m moved, none from 0.9 m, 9.6 m and short from 12 m, nothing from the hit frame; no move has
`:hit-only`, LINK-CONTACT-OK-P unbound, K1's chain opens on a block in its last 3 frames; the CPU's pure pick and its
no-roll steps on stand-ins (zone / defend / dead zone → K; another step, a block, K2J, J1, K3 → nothing); the Shikai's
:move-reflex. pkgcheck clean; the build's warnings the 4 known Lille ones; 83901 0 B everywhere.

**Debug** (DUEL_GAMEPLAY): 83009 5 m from Kenpachi, K1 started with J latched (KJ: J2K leaps in; J again: KJJ); 83019 the
same with K latched (KK; J during K2: KKJ). The gate line counts `leap` and `ai-leap`.

**Gates** (native; the lead re-runs them):
- Identity: `simgate --seeds 10 --summary`'s 42 non-Hisagi lines byte-identical to the parent 4f0b207's (an archive
  baseline of that commit, `[simgate] building` lines filtered); `--cvc` PASS, its output identical to the parent's (yy /
  yk / kk). So removing `:hit-only` from fighter.lisp / kit.lisp moved nothing for anyone else.
- His 7 pairings at 20 seeds (NORMAL, P1 Hisagi; in brackets S1's table, §23.3):

| Pairing | KOs | Median s (S1) | P1 wins (S1) |
|---|---|---|---|
| HY | 20 | 127.9 (137.4) | 4 (3) |
| HK | 20 | 123.7 (125.3); **60 seeds: 125.3** | 0 (1); 0 of 60 |
| HR | 20 | 151.3 (141.4) | 2 (1) |
| HI | 20 | 157.4 (177.5) | 3 (3) |
| HS | 20 | 161.1 (165.6) | 2 (0) |
| HB | 20 | 169.1 (165.8) | 0 (1) |
| HH | 20 (18) | 225.1 (233.8) | 12-8 (8-12) |

HK's 20-seed median fell under 125 s (123.7), so it was rerun at 60 seeds (the edge rule): **125.3 s**, inside the window
(at its edge). Every other cross median inside 125-210 s; the mirror all K.O. (2 time-outs before; a mirror may exceed 210).
His P1 wins 11 of 120 cross matches (S1: 9). Usage (HK, 60 matches, P1): 19 leaps (J2K / J3K started), 1 of them his
CPU's hit pick (`ai-leap`), the rest the generic guard pressure after a blocked K1 / K2; 75 bridges, 46 K strings out of
a windmill.

**Browser** (one Chrome, `--fixed-dt`): 83009: K1 hit Kenpachi at 5 m (f18), J2K started at f30 (the chain at S + A plus
K1's 8 f hitstop), leapt and hit at f44 from 1.0 m, J (pressed in it) → J3 hit at f60 (the ender push): KJJ; 83019: K1 hit
(f197), K2 hit (f223), J3K leapt and hit (f249): KKJ. No error. 83901 after the match: 0 B everywhere on the repeat calls
(the first call in a battle reads KUBIKAKE 128 KB / KOSA 256 KB: the one-time warm-up §23.1 noted).

**Known issues.** His CPU almost never picks the leap off a hit (1 in 60 HK matches): his K1 hits mostly land while his
intent is :zone (the K1 band), where the rule keeps K; the leaps the gate sees are the generic block pressure's. Not retuned
(the spec); dropping the intent condition (roll on every K1 / K2 hit past 2.0 m) is the one-line lever. HK sits at the
window's edge (125.3 s at 60 seeds). His P1 wins stay low (11 of 120). The leap's clips are stand-ins (the run, then the J
clip). The S1 issues stand (the dormant OUT machinery, the stand-in K clips, KOJO's wait). The awaken A/B not run.

## 24. The art pass: the stand-in clips drawn (the user, 2026-10-18)

> 「請列出接下來要正式修改的動作」 → the lead's list (below) → 「可以，照這個順序開始畫」 (the user, 2026-10-18)

Presentation only: no frame data, volume, damage or reaction changes; every simgate summary line and `--cvc` stay
byte-identical, the drawn reach on the hit frames within 0.15 m of each volume's far edge (host FK checks). Every clip
gets the exaggerated, readable windup of §21.7 (「動作要配合誇張而明顯的前搖」). Each drawn move's entry leaves its
stand-in list.

**Order** (the user's 「照這個順序」):
1. **Batch A1, the Shikai** (4): K1 薙 NAGI (the chain hauls the sickle in a horizontal long sweep, its reach the arc's
   6.0 m x the charge, up to 9.6 m; now NAGE's clip); K2 鋸 NOKO (the sickle spun into a circular saw cutting upright
   ahead, then hauled up by the chain; now HIKI's); K3 墜 TSUI (the airborne sickle yanked down in a plunge; now HODOKI's);
   the leap J of KJJ / KKJ (J2K / J3K: 14 f, the J thrown on arrival at 1.0 m; now the run, then the J clip).
2. **Batch A2, the Bankai's ranged mode** (7 + the look): K1 綁束 (the hanging chains spun round him, 360° to 4.0 m, bound
   into one bundle; now SAHARAI's r 3.0 ring), spread K2 (a 60° fan of thin chains whipping the ground to 6.0 m), spread
   K3 (every hanging chain lashed forward in a 160° fan to 6.0 m), gathered K2 (the U → L: over and down 2.0–3.5 m ahead,
   the tail lashed on along the ground to 8.0 m, left lying flat), gathered K3 (the lying bundle hauled into a 360° spin to
   6.0 m), gathered J2 (a straight lash of the bundle to 5.0 m), gathered J3 (a flat 180° sweep to 5.0 m); the carousel
   (the orb turning, the 8 hanging chains orbiting at rest, jerked into each strike); the ranged stance (crescents hanging
   at his sides) and the bind stance (gripped, low, the noose taut).
3. **Batch A3, the bind and the rest** (2 + 1): L 絞縄 KOJO's 20 f tell (the noose hauled up and taut before the drag),
   then the reap; SP2 KAIBAKU-GEKI's own release-and-strike (the noose thrown off at f18, then the 3.0 m 140° blow; now
   HIKIYOSE's gesture); the ranged L 鎖払's recovery drawn to its 32 f (now the clip's end pose held).

### 24.1 Batch A1 as built (2026-10-18)

> 「可以，照這個順序開始畫」 (the user, 2026-10-18)

The Shikai's four stand-ins drawn as their own clips, all in `duel/lisp/hisagi-art.lisp` ("A1"): **presentation only**, no
frame data, volume, damage, reaction, flag or knob changed. The moves name the clips (`:clip`, hisagi.lisp); the leap copies
lose `:clip-s` (their clips are authored at S 14) and HS-LEAP-TICK no longer plays the run / the J clip (it keeps the leap
and its `leap` count). NAGE's, HIKI's and HODOKI's clips stay (no move's now: the dormant throw, as KARI-OTOSHI's).

**Machinery (a look, 0 B a frame).**
- `*hs-letout*` takes a swept azimuth: `az` as `(a0 a1 a2)`, the bearing a0 when the sickle leaves the fist, a1 when it is
  out (it spirals out round him between), swept to a2 by f2 and coming back from there. The radius keeps x the charge.
- `*hs-foe-paths*` (clip → segments `(f0 f1 a b spin)`): the left sickle moved between %HS-POINT codes over move frame
  ranges. New codes: 6 the victim's centre (HS-FOE-SEG's far end, 1.0 m over his feet), 7 3.0 m over him, 8 3.8 m over him
  (the sky: the top of the match camera's frame), 9 an upright wheel 0.8 m round the left fist (spun faster each turn,
  rolling forward), 10 K1's sweep end (6.0 m x the charge, 40° to his right; K2J, off J1, starts from the fist instead).
  Every hit frame sits on a segment held at code 6 (host-checked).
- %HS-PLACE! spins 3 (the upright saw about its crossing, its top leant 30° to his left so it reads as a disc from behind;
  three ink comet smears trail its blades) and 4 (point down: the plunge). Long chains (K1's sweep past 5.5 m, the paths)
  are drawn taut in two pieces (%HS-CHAIN2). Black for P1, the white-edged ink for P2 (`*hs-chain-ink*`, unchanged).

| Move | Clip | S/A/R | Frame keys (the windup held near its peak, the hit pose snapped on S) | Drawn on the hit frames vs the volume |
|---|---|---|---|---|
| K1 薙 NAGI | `:hs-s-nagi` | 18/4/22 | f4 the coil starts; **f9-14 coiled far to his left on the bent back leg, the left arm flung back, the right pointing at him (the tell, held)**; the sickle leaves the fist at f9 behind him and spirals round his left side (bearing 160° → 75°) out to full chain by f16; S the lunge, the arm leading the chain; f16-24 swept left to right, +75° → -75°; f22 across his body; f24-36 hauled back to the chest | the let-out at **6.00 ×4 (x1.0) / 9.60 ×4 (x1.6)** vs the arc 6.0 / 9.6; bearings +38 / +19 / 0 / -19°, inside ±45° |
| K2 鋸 NOKO (K2J too) | `:hs-s-noko` | 20/4/24, enter 6 | f6-9 yanked back to the hip (the sickle reeled in off K1's sweep); **f9-16 spun up on the wheel at his left fist, crouching, coiled (held)**; f17 cocked high; f16-20 flung along the line, spinning upright; S the arm thrust at him; f20-24 the saw grinding in him; f24-30 both arms haul it up 3.0 m over him; held to f38, back in the fist by f48 | the saw's crossing **0.00 m** off the victim on all 4 hit frames (K2 and K2J) |
| K3 墜 TSUI | `:hs-s-tsui` | 22/5/34, enter 8 | f8-18 hauled hand over hand, the sickle rising off him into the sky (3.8 m); **f18-20 both arms straight up, arched back on his toes, looking up (held)**; f20-22 yanked down, the sickle plunging point first; S folded in a deep squat; held to f34; hauled back by f46 | the point **0.00 m** off the victim on all 5 hit frames |
| J2K (KJJ's leap) | `:hs-s-tobi-kaeshi` | 14/3/13 | **f3-5 a deep crouch, the arms swept back (held)**; f7 the spring; f10 tucked at the top (0.75 m up), J2's windup; f12 the fall; S J2's hit pose on landing; the left sickle let out f9-24 (J2's, 6 f later); the short grip | the left let-out **1.40 ×3** vs 1.4 |
| J3K (KKJ's leap) | `:hs-s-tobi-rin` | 14/3/18 | **f3-5 the crouch, wound right (held)**; f7 the spring; f9-13 J3's turn in the air (yaw -40 → 40 → 120 → 200 → 270 → 300, ~80° a key), both sickles let out from f8; S J3's hit pose on landing (330), on to 400 | both let-outs **1.40 ×3** vs 1.4 |

The leap's sim move is unchanged (HS-LEAP-TICK carries him 0-9.6 m); the clips have no `:root :f`, so the drawn leap is the
sim's distance. Measured in the browser by debug 83902 (new `duel hisagi tip base …` lines: the body posed by the clip,
HS-POSE and HISAGI-DRAW run on each hit frame).

**Host tests** (duel-rules-test 9817 checks ALL PASS; duel-control-test 89, learn-test 131, cine-test 18 ALL PASS;
pkgcheck three 0 lines):
- the FK reach test reads `*hs-strike-reach*`'s new rows (`:hs-s-nagi` 6.0, the leaps' 1.4); the let-out coverage check
  (the Bankai's, §21.8) now also covers K1, J2K, J3K (out over every hit frame at the volume's edge);
- new: K1's sweep at x1.0 and x1.6 (its let-out r x the charge within 0.15 m of the charged copy's arc edge, its bearing on
  each hit frame within ±45°); K2 / K2J / K3: every hit frame on a `*hs-foe-paths*` segment held at the victim's centre,
  the codes known;
- the leap copies: their own clips, speed 1, the clips' :s mark on 14 and their length S + A + R (in place of `:clip-s` 8 / 9);
- the clip list (§5): the five new clips in, NAGE's / HIKI's / HODOKI's out (no move's).

**Identity** (the proof of presentation only): `simgate --seeds 10 --summary` (all 56 gate lines, Hisagi's 14 included) and
`--cvc` (yy / yk / kk PASS) byte-identical to the parent 6548ee0's (`cmp`, the `[simgate] building` banner filtered).

**Browser** (one Chrome, `--fixed-dt`): 83008 with L held into the windmill, then K: `windmill -> K string x1.60`, K1 hit
Kenpachi at 8 m; 83009 KJJ (K1, J2K leapt and hit, J3); 83019 KKJ (K1, K2, J3K leapt and hit); 83006 JKK (J1, K2J, K3);
83005 the mirror: no exception, no missing clip. 83901 on the repeat call 0 B everywhere (the new NAGI, NOKO, the wheel,
TSUI, the sky and J3K entries included; the first call's one-time buffer growth, 128 / 256 KB as §23.5 noted, now lands on
the windmill x1.4 and SAHARAI entries). `./build.sh duel` with the 4 known Lille warnings.

**Strips**: debug 83910+k, slots 23 NAGI, 24 NOKO, 25 TSUI, 26 J2K, 27 J3K (`*hs-strips*`; 83940+3i+v from the side, the
front, the match camera).

**Known issues / for the user's eyes** (checked by numbers, needs your eyes):
- From the behind camera the saw at the victim's centre (S, A) is mostly hidden in his body; it reads on the wheel, in the
  flight (f16-20) and in the haul up; the hit spark marks the bite.
- K2 reels the sickle in from K1's sweep end (code 10), which is where K1's sweep is when K2 links (f22: -38°); started
  from the fist only after J1 (K2J).
- K3 after J2 (JJK) starts its haul from the victim's centre while J2's left sickle is 1.4 m out there: a small jump.
- The sky is 3.8 m over him (higher left the frame in the match camera); K2's haul 3.0 m.
- The leap's top is a fixed 0.75 m whatever the distance (a hop at 2 m, a dive at 9.6 m).

### 24.2 Batch A2 as built (2026-10-18)

> 「可以，照這個順序開始畫」 (the user, 2026-10-18, approving §24's order; this is its batch A2)

The seven ranged route links get their own clips, and the Bankai gets the carousel and its two stances. All of it is in
`duel/lisp/hisagi-art.lisp` ("The ranged route links", "The carousel, the lashes, the bundle", the bind's stance). In
`hisagi.lisp` only presentation keys change:
- the seven moves' `:clip-s` now equals their S, so each clip plays at speed 1;
- `*hs-r-clip-stand-ins*` keeps only the bind SP2's entry (batch A3);
- the bind kit gets `:stance :hs-kb-stance` and `:look-clips *hs-kb-looks*`.

**Presentation only.** No frame data, volume, damage, reaction, flag or knob changed. B3b's dormant TSUISA, NAGISA and
RAKUSA clips are deleted: no move had played them since B4a, and the stand-ins were their only use.

**The lashes** (`*hs-lashes*`, drawn by `%hs-curtain-draw`).
- Every strike is drawn from the orb as a cubic: down past a knee near him, then out to its free end.
- The middle is lifted by the key's bend, or laid along the floor by a negative bend.
- The chain lags behind its own motion: the middle is dragged toward where the end was 2 frames earlier, at most 1.8 m.
- It tapers toward the free end while it lashes.
- A strike (the end moving faster than 1.2 m a frame) leaves a black trail over its last 2 frames. A haul leaves none.
- No lash is a straight line on its strike frames: the lag, the bend and the travelling wave (J2s) bend it.
- Spread links use the separate hanging chains at ×0.8 width. Gathered links use **the bundle**: all eight hanging
  chains twisted round one cubic (4 turns, tight below, fanning out under the orb).
- The bundle is bound by K1 over f21–26 and held through every gathered link (`*hs-bundled*`). Outside those clips it
  comes apart into the curtain over 0.25 s.
- The keys give each end's r / h / az / bend per clip frame. The rank stagger spreads a fan over a fraction of a frame.

| Move | Clip (S/A/R) | Windup (held) | Strike | Measured drawn reach on the hit frames (83902) vs edge |
|---|---|---|---|---|
| K1 綁束 | `:hs-k-hosoku` (16/4/22) | the stir: right arm overhead, circling every 3 f, coiled right on the back foot (f6–14); all eight chains hauled in and up round his head, swirling with the orb | unwound left with the spin, arms flung wide; the eight whirled out to 4.0 m, a key each 90° (f16–19); wound in and bound into the bundle at his right front (f21–26), right fist low on it | 4.00 ×4 vs 4.0 (arc) |
| spread K2 | `:hs-k-s-k2` (21/4/24, link f6) | whip-crack: right arm up and back over his shoulder, arched, left hand pointing (f10–18); chains 1 2 5 6 hauled up high behind him | over the top and onto the ground in a 60° fan at 6 m, lying there to f30 | 6.00 ×4 vs 6.0 (arc) |
| spread K3 | `:hs-k-s-k3` (21/5/34, link f6) | the curtain drawn back: arms flung back and wide, chest out (f9–19); all eight hauled back high behind him | both arms swept forward in a lunge; all eight lashed forward in a 160° fan to 6 m (0.45 f apart), settling to the floor | 6.00 ×5 vs 6.0 (arc) |
| gathered K2 束打 | `:hs-k-g-k2` (27/10/24, link f6) | the heave: both fists up over his right shoulder, sunk on the back leg (f16–24); the bundle hauled up high behind him | the U: bent double, the bundle arcs over and slams 4.0 m ahead (f27–30); the L: a shove at f33, its tail lashed on along the ground to 8.5 m, left lying flat (to f46) | 4.00 ×4 vs 4.0, then 8.50 ×4 vs 8.5 (lines) |
| gathered K3 束旋 | `:hs-k-g-k3` (27/5/34, link f6) | the lying bundle dragged in hand over hand (f10 / f15), then round to his right and wound up, crouched (f20–26) | the body turned with it, arms flung out; the bundle whirled round him at 6 m, a key each 90° (f27–31) | 6.00 ×5 vs 6.0 (arc) |
| gathered J2 束鞭 | `:hs-k-g-j2` (16/3/13) | the bundle cocked back by his right hip, fist drawn back low, coiled (f6–14) | a lunging punch; the bundle straight down the line at chest height, a wave running out along it | 5.50 ×3 vs 5.5 (line) |
| gathered J3 束薙 | `:hs-k-g-j3` (16/3/18) | wound low to his right, both fists by his right knee (f5–14); the bundle drawn round behind his right | unwound left; the bundle swept flat through the front half at 5 m (f16–18) | 5.00 ×3 vs 5.0 (arc) |

**The tells.**
- Gathered links read heavier: longer holds, the bundle hauled high, the whole body heaving.
- Spread links read quicker: a one-arm crack or a two-arm fling.
- The startups are as before: the spread links' effective S is 15 (link f6), and their holds are 8–10 f.

**The carousel** (`%hs-car!`, `*hs-spins*`, `*hs-car-w*`).
- The orb's phase turns at 0.25 rad/s (the orb's own turn of §21.6). The eight hanging chains orbit him with it.
- A chain passing ahead of him or behind him (within about ±45°) is lifted 2.4 m and drawn in by 35%. §21.6's rule
  stands: none hangs between the fighters or before the behind camera.
- Each ranged strike clip (the seven new ones and B3b's J1 / J2 / J3 / L / SP1 / SP2 / O / KUBIKAKE) jerks the orb and
  the curtain into a spin. It turns 0.5–1 turns: winding up from the windup's start, fastest at S, done by about S+10.
- When the clip changes, the spin is banked into the phase, so a link that cuts it short never makes the curtain jump.
- The §21.8 chain strikes start from and return to where the carousel has their chain.

**The stances.**
- Ranged: unchanged (§21.8: arms hanging, the crescents point-down at his sides, still), with the carousel turning
  round him.
- Bind (`:hs-kb-stance`, its walk `:hs-kb-walk-f/-b`, `-strafe-r/-l`): sunk low over bent knees, leaning in, the right
  crescent gripped up at his chest, the left low. His left fist holds a chain run taut to the opponent's noose
  (`*hs-kb-grip-clips*`: in a bind, the stance and walk only).
- The blades stay the Shikai's S-pair. P1's chains are solid black, P2's the white-edged ink (§22.10).

**Debug.** 83500+k slots 26–32 are the seven route links and 33 the bind's stance (DUEL_GAMEPLAY "Debug commands"; the
slot list there corrected to k 0–33). 83901 adds the route links and the bind's stance. 83902 prints each hit window's
edge.

**Verification.**
- `simgate --seeds 10 --summary` (56 lines) and `--cvc` (yy / yk / kk PASS) are byte-identical to the parent 6548ee0
  (`cmp`, the `[simgate] building` lines filtered).
- duel-rules-test: 9850 checks ALL PASS (9809 at the parent). The FK reach test now covers the seven moves through
  `*hs-strike-reach*`. The tie check walks every hit window of the ranged and bind chain moves; it adds the seven moves,
  evaluates `*hs-lashes*`' keys on their hit frames, and wants no stand-in for them.
- duel-control-test 89, learn-test 131 and cine-test 18 ALL PASS. `tools/pkgcheck.sh duel` is clean.
- `./build.sh duel` shows only the 4 known Lille style warnings.
- Debug 83901 is 0 B in every state on the repeat call, the route links and the bundle included. The first call after a
  scene grows the fx vertex buffer once, as §21.8 noted: 131 KB at KUBIKAKE and 262 KB at KOSA, or 524 KB at the bind's
  stance after 83902's scene.
- Browser smoke (`run.mjs --fixed-dt 16.666667`) ran with no JS / WebGPU error:
  - 83016: K K K and K J J;
  - 83017: J K K and J J K;
  - 83012: the bind;
  - 83018: the CPU zone game for 14 s;
  - the strips 83500+26 … 33, both card views.

**Known issues** (checked by numbers, needs your eyes):
- From the behind camera the bundle and the chains come down from above the frame (the orb is out of it, §21.6). The
  gathered K2's U reads mostly by its slam and the shove; the side view shows the whole arc.
- The trails read as black blades on the spins (K1, K3G): wide and fast by design.
- Thin spread chains are hair-thin in the 12 m wide stills.
- At rest the carousel lifts a chain as it passes ahead of him or behind him. That cannot show in stills: the phase
  advances only with live effect time.
- The ranged stance is §21.8's, now with the carousel turning round it. It is not a new pose.
- The bind leash runs to the hidden opponent's unposed neck on the card stills (as the noose does, §21.8).
- B3b's J1 / J2 / J3 crescents still start in the fist.

### 24.3 Batch A3 as built (2026-10-18)

> 「可以，照這個順序開始畫」 (the user, 2026-10-18, approving §24's order; this is its batch A3). KOJO's tell is §23.2's:
> 「增加拉近對手前的動作識別度與前搖時間，並減少攻擊效果的前搖。核心邏輯是對手在遠處時就知道要被拉近該準備防禦」.

The bind's L and SP2 and the ranged L's recovery are drawn as their own clips in `duel/lisp/hisagi-art.lisp`. In
`hisagi.lisp` only presentation keys change:
- L KOJO and the ranged L SAHARAI lose `:clip-s` (20 and 14): every clip plays at speed 1;
- `*hs-r-clip-stand-ins*` is empty (the bind SP2's entry deleted). It stays defined: the host checks read it, and
  `*hs-bk-clips*` appends it.

**Presentation only.** No frame data, volume, damage, reaction, flag or knob changed. HIKIYOSE's clip
(`:hs-kb-hikiyose`) is deleted: KAIBAKU-GEKI's stand-in was its only use. Its two haul poses stay, in KOJO.

**Machinery (a look, 0 B a frame).**
- **The held chain** (`*hs-kb-grips*`, `%hs-grip-chain`): A2's stance list becomes `(clip F1 FT)` rows. His left fist
  holds a chain to the opponent's noose until clip frame F1. It sags 0.5 m, eased out until FT, then hangs taut and
  trembles (2–4 cm, fast) while FT > 0. The bind's stance and walk keep A2's taut chain (F1 9999, FT 0). KOJO holds it
  to S 30, taut from f9; KAIBAKU-GEKI to its S 18, taut from f5.
- **The throw-off** (`%hs-orb-draw` code 3, KAIBAKU-GEKI from its S, read from the move frame). The noose ring is flung
  off the opponent's neck, out to Hisagi's right and up. It opens to 0.49 m as the noose bundle reels it into the orb
  over 12 f.
- **SAHARAI's ring is a lash now** (`*hs-lashes*`, mask 255, 0.2 f apart). Its eight `*hs-bk-chains*` rows are deleted,
  so the curtain's chains lag, taper and trail as A2's do. The carousel's jerk is re-timed to (3 10 24 1.0).

| Move | Clip (S/A/R) | Frame keys (the windup held near its peak, the hit pose snapped on S) | Drawn on the hit frames vs the volume |
|---|---|---|---|
| L 絞縄 KOJO | `:hs-kb-kojo` (30/4/36, was 20/4/30 at `:clip-s` 20) | f0 from the bind's stance; f4 both hands up the noose chain; **f9–19 the heave: hauled up over his head, arched far back on the back leg, the chain from his left fist to the opponent's noose pulled taut and trembling (the tell, held)**; f21 the yank down to his chest (the drag from f20); f24 hand over hand; f27–29 the right crescent raised high, cocked, the left hauling at the hip; S the wide downward reap, the crescent let out from overhead to 3 m (f27–30 out, back by f46); impact held to f46; the bind's stance by f70 | the let-out **3.00 ×4** vs the arc's 3.0 |
| SP2 解縛擊 KAIBAKU-GEKI | `:hs-kb-kaibaku` (18/4/28, was HIKIYOSE's 16/40/8) | f0 from the bind's stance; f5 the noose chain gripped and hauled; **f11–16 coiled hard to his right, the left fist high on the taut chain, the right crescent cocked far back low behind his hip, sunk (held)**; S the release: the left arm flung up and out, the noose thrown off and reeled into the orb, the right crescent let out in a flat sweep right to left (bearing −120° at f15, −50° at S, +50° by f22); f20–22 unwound; held to f32; the ranged stance by f50 | the let-out **3.00 ×4** vs the arc's 3.0; bearings −50 / −25 / 0 / +25°, inside ±70° |
| L 鎖払 SAHARAI | `:hs-k-saharai` (10/4/32, was 14/4/22 at `:clip-s` 14) | f4 the wrap, the arms crossed tight over his chest; **f4–9 the curtain drawn in tight round his body, curled (held, deeper at f9)**; S the burst, arms flung wide, arched, all eight lashed out in a ring to 3 m; f12–18 the impact hold as they fall to the floor; **the recovery has motion**: f26–32 both fists hauled in to his chest, leaning back, the chains dragged in along the floor (f26 2.4 m, f34 1.6 m lifting) and back into the curtain by f44; f38 settling into the stance | the lash ends **3.00 ×4** vs the arc's 3.0 |

**Debug.** The 83500+k slots are reused: 20 is now KAIBAKU-GEKI's own clip (HIKIYOSE's until A3), and 22 KOJO and
6 SAHARAI are redrawn. 83901 adds SAHARAI's recovery, KOJO's heave and reap, and KAIBAKU-GEKI's haul and throw-off
(DUEL_GAMEPLAY "Debug commands").

**Verification.**
- `simgate --seeds 10 --summary` (56 lines) and `--cvc` (yy / yk / kk PASS) are byte-identical to the parent 5a32e47
  (`cmp`, with the `[simgate] building` lines filtered).
- duel-rules-test: 9869 checks ALL PASS.
  - The tie check adds SP2 KAIBAKU-GEKI, so KOJO, KAIBAKU-GEKI and SAHARAI are each drawn to their volume's far edge
    within 0.15 m on every hit frame (the let-outs, SAHARAI's lash keys).
  - New checks:
    - the stand-in list is empty;
    - the three moves play their own clips at speed 1, each clip's `:s` mark on S and its length S + A + R;
    - KAIBAKU-GEKI's sweep stays inside its 140° arc on every hit frame;
    - KOJO's chain holds to S and is taut before the drag (FT < `*hs-kojo-pull-at*`);
    - §5's clip list has `:hs-kb-kaibaku` in place of `:hs-kb-hikiyose`;
    - SAHARAI's clip speed is 1.0 (was 1.4).
- duel-control-test 89, learn-test 131 and cine-test 18 ALL PASS. `tools/pkgcheck.sh duel` is clean (three 0 lines).
- `./build.sh duel` shows only the 4 known Lille style warnings.
- 83902: KOJO 3.00 ×4, KAIBAKU-GEKI 3.00 ×4, SAHARAI 3.00 ×4, against edges of 3.00.
- 83901: 0 B in every state on the repeat call. On the first call the buffers grow once, as before: the windmill
  131 KB, the Bankai 262 KB, SOKUTEI 524 KB.
- Browser smoke (`run.mjs --fixed-dt 16.666667`) ran with no JS / WebGPU error:
  - 83012: L KOJO dragged Kenpachi from 3.0 to 2.0 m and hit him for 70, then Shift+L KAIBAKU-GEKI released the bind
    and hit;
  - 83010, 83016: the ranged L pushed him to 3.5 m for 30;
  - 83018: the CPU zone game for 14 s.
- Strips 83500+6 / 20 / 22 from all three views; SAHARAI's wrap was lowered to 1.3–1.5 m after the first look, since the
  chains hauled up to 2.7–3.0 m left the frame.

**Known issues** (checked by numbers, needs your eyes):
- The throw-off is small at the card stills' scale (the ring and the reeled bundle are at the hidden opponent's neck).
  In the match it shows over the opponent for 12 f. His own neck tie stays: it is the Bankai's look in both modes, so
  only the opponent's noose is thrown off.
- KOJO's held chain runs to the opponent's noose point wherever he is. Against a far opponent the heave reads mostly by
  the body from the behind camera.
- KOJO's reap goes along the fist's bearing (az NIL, as B3b's): ahead of him in the side and front strips, but its bearing
  is not host-checked (its distance is).
- SAHARAI's wrap hides the curtain's top under the orb (above the frame, §21.6).

### 24.4 One leap a combo; K1's dead zone 3.0 m; the bridge windmill's push (the user, 2026-10-18; a sim change)

> 「將 K1 能打中的最近距離拉遠」 → 「始解 K1 薙」, 「3.0 m（推薦）」; the lead found J1 → L → K1 broken at 3.0 (the bridge
> windmill left the victim at 2.31 m) and an infinite combo on main, K1 → J2K → J3 → L → K1 … (84 f a round, 150 raw, no
> resource, the victim never back in neutral); the user found its twin: 「我發現始解 K1 K2 J3 L K1 K2 J3 L ... 能打出無限連招www，
> 應該要怎麼修改比較好」 → 「一套連段只能跳近一次」, 「3.0 m，風車銀接推更遠（推薦）」

**Why it looped.** S1's bridge (J → L → K) and S2's leap (K → J) close a cycle K → J → L → K, each link a true combo; the
system has no combo cap (the hit-10 knockdown gone 2026-09-30, the stun tolerance's blow-away off since 2026-10-10). Every
way back to K1 is the bridge after a J, and the first J after a K is always a leap, so one leap a combo breaks every cycle.

**As built** (`duel/lisp/hisagi.lisp`, one shared hook in `fighter.lisp`):
- `*hs-k-dead*` 2.0 → **3.0** (K1 NAGI misses inside 3.0 m); his CPU's Shikai band 2.0–3.5 m split at 3.0 (no K below it).
- **One leap a combo**: HSS-LEAPT set as a leap J (J2K / J3K, `*hs-leaps*`) takes off, cleared by HS-TICK once the victim's
  combo is over (`fighter-combo-hits` 0: neutral; a leap after a block leaves nothing set) and by HS-RESET. A new shared
  hook `:link-ok` (fighter.lisp, the latched-link path; DUEL_STRINGS): his HS-LINK-OK refuses a leap J while it is set, so
  the string ends there; his CPU (HS-AI-MOVE) takes the K link instead. No other kit has the hook.
- **The bridge windmill's push** `*hs-bridge-kb*` 1.5 → **2.5** (`:hs-kaza-j`'s `:kb`; the neutral windmill's stays 1.5):
  J1 → L → K1 lands from 3.31 m.
- Longest strings now: two rounds, e.g. K1 K2 J3K L K1 K2 K3, J1 J2 L K1 J2K J3 (no L after it: the next would be K1 →
  a second leap), K1 J2K J3 L K1 K2 K3.

**Browser** (`--fixed-dt`): 83007 J1 → L → K1 hit from 3.31 m (2.31 before, a whiff at 3.0); 83009 K1 J2K J3 L K1 then J:
no second leap (the string ends); 83019 K1 K2 J3K L K1 K2 then J: no J3K, the victim back in neutral.

**Host tests** ("§24.4"): the hook only on his Shikai, the knobs, HS-LINK-OK refusing J2K / J3K while set and passing K2 /
K3 / J3, set through a combo, cleared in neutral and by the reset; the leap CPU test's 2.0 / 2.1 m now 3.0 / 3.1.

**Gates** (the lead): host duel-rules 9867, control 89, learn 131, cine 18 ALL PASS; pkgcheck clean; the 42 non-Hisagi
lines of `simgate --seeds 10 --summary` and `--cvc` byte-identical (the shared hook is inert for them). His 7 pairings at
20 seeds (before = S2, §23.5): HY 136.3 s (127.9), HK 130.9 (123.7; 125.3 at 60), HR 158.8 (151.3), HI 161.9 (157.4), HS
161.1 (161.1), HB 139.4 (169.1), HH 235.6 (225.1, a mirror); every match a K.O., every cross median inside 125–210 s. His
P1 wins 9 of 120 cross matches (S2: 11): still weak, nothing retuned.

### 24.5 No FREE button; KUBIKAKE without a cooldown (the user, 2026-10-18; a sim change)

> 「把 free 的按鍵拿掉，然後 SP2 的捆縛去除冷卻，一樣用打空的後搖來控制出招成本」

**As built** (`duel/lisp/hisagi.lisp`):
- **No FREE**: the bind mode's P (the plain release, the touch deck's FREE chip) is gone: `*hs-bk-hooks*` loses `:p` /
  `:p-label` (HS-P-PRESS, HS-P-LABEL, HS-P-PRESSED!, the release held through his own move, HS-REL-FREE-P / HS-REL-DUE-P and
  HSS-REL-HELD deleted). P does nothing in either Bankai mode now; a bind ends by SP2 KAIBAKU-GEKI's release (its S sets the
  release), the drain or the round. His CPU's plain-P branch (`*hs-ai-plain-release-p*`) is gone: behind on grey with the
  foe out of KAIBAKU-GEKI's reach, he waits (the drain, KOJO's pull). The release path without the strike stays (the debug
  scene 83013, the host test) but no button reaches it.
- **KUBIKAKE (ranged SP2) has no cooldown** (`*hs-kubi-cooldown*` 180 and HSS-KUBI-CD deleted; HS-KUBI-READY-P: his own
  200 and no bind up). Its price is its whiff recovery `*hs-kubi-whiff*` **42 → 60** (the lead's number; R 30, block −20 and
  the rest unchanged; a hit still cuts the recovery to 14).

**Host tests**: no `:p` / `:p-label` on either Bankai kit; P in a bind (idle, or in hitstun past the 2nd hit) releases
nothing; KUBIKAKE ready right after its start (no cooldown), its whiff 60; the release's end effects (set as KAIBAKU-GEKI's
S sets them).

**Gates** (the lead): host duel-rules 9870, control 89, learn 131, cine 18 ALL PASS; pkgcheck clean; the 42 non-Hisagi lines
and `--cvc` byte-identical. His 7 pairings at 20 seeds (before = §24.4): HY 128.5 s (136.3), HK 130.9 (130.9), HR 134.3
(158.8), HI 167.6 (161.9), HS 161.1 (161.1), HB 136.5 (139.4), HH 235.6 (235.6, a mirror); every match a K.O., every cross
median inside 125–210 s. His P1 wins 10 of 120 (9).

## 25. His stylized learning CPU and ASSIST (dream-rsi; the user, 2026-10-18)

> 「請參考過往風格型學習 AI 的開發經驗，使用 /anthropic-skills:dream-rsi 開放檜佐木的專用AI 與輔助模式」

Asked (DREAM_RSI §7's pre-run questions, `duel-character-cpu`), the user chose: the weights 「0.3/0.2/0.5 招牌至上」; the
signature themes 「始解鎖鐮連段」「卍解遠距路線」「捆綁」 plus 「請研究多種招牌風格，並使用機率將這些風格戰法互相結合」; the budget
「先跑 1 輪 8 格」; the integration 「學玩家習慣」「AUTO COMBO 路線」「AUTO GUARD 風車」.

### 25.1 The plan (Lille II's run, DUEL_LILLE_V3 §22, as the model)

1. **The frozen evaluator** `tools/aieval.py --char 7` (one commit; the workspace `docs/research/hisagi-ai-drsi/`):
   - **score = (0.3 strength + 0.2 masher + 0.5 signature) × the NORMAL factor**; 0 when NORMAL pacing fails (every match a
     K.O. by the RESULTS line's Konpaku, median ≤ 220 s);
   - **signature = a whitelist** (`SIG_HISAGI`, three themes, the JSON's `sig_by` per theme): **chain** the Shikai's K
     string (HS-K1 / K2 / K2J / K3), the leaps J2K / J3K, the windmill KAZA and its bridge KAZA-J, SP1 RAIDEN, SP2 SHIBARI;
     **ranged** the Bankai's K1, every route link past J1 (J2 / J2S / J3 / J3G / K2 / K2S / K3 / K3G), the L SAHARAI, the
     SPs, KUBIKAKE; **bind** every HS-B- move but its Kikon. Never his plain J string (HS-J1..J3), the ranged J1, the
     Breaker or a Kikon;
   - **the NORMAL band** (as Lille II's, his shipped CPU being broken: below): his NORMAL win share (both seats) in
     [0.30, 0.60] → ×1, falling linearly to 0 at 0.15 outside;
   - six opponents (the retired old Lille out), both seats; fixed seeds; cells compare at 40 seeds, the final pick at 80.
2. **Opponents fixed** at the freeze commit; every cell's worktree starts there.
3. **Cells** change only `duel/lisp/hisagi-ai.lisp`'s (until 2026-10-21 `hisagi.lisp`'s) CPU parts (the three kits' `:ai` plists but what CPUs facing him read,
   the HS-*-AI-* functions and knobs, CPU-only HSS slots, the CPU branches of the sim ticks) and the host test's new
   `HISAGI-CPU-TESTS` section (his CPU checks moved there from the Shikai's S2 and the Bankai's B4a / B4d blocks; the
   kit-wide pin now only keeps `:move-reflex` off every other character); every chance per event and difficulty-scaled;
   AI-AWAKEN-P, the learner's read clock, the ASSIST's borrowed brain kept working.
4. **Styles by probability** (the user's 「使用機率將這些風格戰法互相結合」): each branch of round 1 opens one primary style
   (b0 the Shikai chain, b1 the ranged routes, b2 the bind, b3 a mix of all three); a cell builds named styles and, with
   more than one, a mix rolled with SIM-RND01 once per match / form entry / event; every cell reports its STYLE paragraph,
   relayed to the user as it lands.
5. **dream-rsi**: W = 2, round 1 = 4 branches × 2 refines (8 cells), λ 0.25, `plan --beta 0.6`; the lead re-scores every
   cell with the frozen evaluator before `record`; after round 1 the user picks (or asks for a combined candidate).
6. **Integration** (after the pick): the styles' mix as picked, the learner's Hisagi situations (`learn-def-kit :hisagi`),
   AUTO COMBO's routes (`:assist-combo`), AUTO GUARD's windmill against an incoming ranged threat (`:assist-guard`), the
   manual's CPU / ASSIST lines, then the full gate (his pairings, the awaken A/B, ASSIST, G2).

### 25.2 The freeze (2026-10-18)

- The baseline at 40 seeds with the frozen evaluator (`baseline/score.json`): **score 0.0** (raw 0.4014): strength **0.000**
  (0 of 480 HARD matches), masher 0.165 (the button-masher beats him 83 % of the time), signature 0.737 (chain 0.426,
  ranged 0.20, bind 0.11, his plain J 0.114, the rest the Breaker, the Kikons, counters); NORMAL share **0.10** (Y 12, K 3,
  R 5, I 6, S 19, Lille 3 of 80), factor 0; pacing ok (NORMAL medians 129.2-168.8 s, every match a K.O.).
- The host test's `HISAGI-CPU-TESTS` section holds his CPU's checks (9871 checks, ALL PASS: +1, which of his forms has the
  `:move-reflex`). `tools/aieval.py`: `HISAGI` weights (0.3, 0.2, 0.5), `SIG_HISAGI`, the NORMAL band and the K.O. by the
  RESULTS line for both banded fighters (Lille II's numbers unchanged).
- The freeze is the commit adding `docs/research/hisagi-ai-drsi/baseline/score.json` (`step.sh` / `rescore.sh` find it).

### 25.3 The Bankai's ranged reach: J 3–6 m, K 1–4 m (the user, 2026-10-18; a sim change, the search paused)

> 「先等等，我想改卍解的遠距範圍」 / 「J 的範圍改 3~6」 / 「K 的範圍改 1~4」; asked how the J / K cross links (J1→K2s,
> K1→J2s, J2→K3, K2→J3G) should connect on the 3–4 m overlap: 「命中把對手定位到 3.5 m (Recommended)」

Round 1's two cells (b0a0, b1a0, still reading the code) were stopped and the round reopened on the new rules (§25.4).

**As built** (`duel/lisp/hisagi.lisp`; every ranged-mode J and K, the SPs / Kikon / KUBIKAKE keep `*hs-r-dead*` 2.0):

| Knob | Old → new |
|---|---|
| `*hs-r-j-dead*` (was `*hs-r-j1-dead*`, J1's only) | J1 3.0, J2 / J3 / J2s / J3G 2.0 → **3.0** (every J) |
| `*hs-r-j-reach*` | J1 / J3 / J3G 5.0, J2 4.5, J2s's line 5.0 + r 0.5 → **6.0** (J2s: the line 3.0–5.5, r 0.5) |
| `*hs-r-k-dead*` | 2.0 → **1.0** (every K) |
| `*hs-r-k-reach*` | K1 4.0, K2s / K3 / K3G 6.0, K2's slam 2.0–3.5 / tail 3.5–8.0 (+ r 0.5) → **4.0** (K2's two caps both 1.0–3.5, r 0.5) |
| `*hs-r-j-push*` 3.5 | a push to *at least* 3.5 (J1 / J2, K2's slam) → a **placement at 3.5** (pushed out or dragged in on the chain, HS-PLACE-TO), and **K1 too** |
| `*hs-r-j3-push*` | J3 / J3G's ender 5.5 → **6.6** (out of a restarted J1's 6.0 + a body 0.45 + 0.05: the rule it had) |
| `*hs-r-k2-launch-kb*` | — → **0.5** (K2's tail launch slides 0.3 m, not the generic 1.0: K3G at 4.0 m reached it at 4.5 m in the smoke) |
| `*hs-ai-close*`, the ranged `:moves` | the CPU's SAHARAI band 2.0 → 1.0; the bands 0–1 (L), 1–3 (K1), 3–4 (K1 / J1), 4–6 (J1), 6–8 (SP1) |

The tip (x1.3, the outer 1.0 m) follows: J 5–6 m, K 3–4 m. The art's drawn reach follows each hit volume (`*hs-strike-reach*`,
the let-out crescents J1 / J2 / J3 6.0, J3's swept chain 5.9, the lashes: spread K2s / K3 and gathered K2 / K3G to 4.0, gathered
J2s / J3G to 6.0).

**The shared J-short / K-long rule** (DUEL_STRINGS §13) gets this form as an exception (the user's inversion; the host walk
skipped `(:hisagi :bankai)`, its K1 vs J1 already since §22.4).

**Host tests**: duel-rules 9869 (−2: that walk's link 2 / 3 rows for the form), control 89, learn 131, cine 18 ALL PASS;
pkgcheck clean; the build with the 4 known Lille warnings. The volumes, dead zones, the placement, the ender push, the tip and
the CPU's reach reads re-pinned; the drawn reach of every changed clip within 0.15 m.

**Smoke** (browser, `--fixed-dt`, debug 83016 / 83017 / 83010): all six routes land three hits — KKK (K1 K2 K2 K3G), KKJ, KJJ
from 2.5 m, JJJ, JJK, JKK from 3.5 m — and J1 → J2 → K3 from 6.0 m (J1 drags him in to 3.5 m, the K3 reaches).

**Gates** (the lead; the playtest Artifact v106 first): the 42 non-Hisagi lines of `--seeds 10 --summary` and `--cvc`
byte-identical. His 7 pairings at 20 seeds (before = §24.5): HY 128.3 s (128.5), HK 131.9 (130.9), HR 152.4 (134.3), HI 151.3
(167.6), HS 172.1 (161.1), HB 157.0 (136.5), HH 206.6 (235.6, a mirror); every match a K.O., every cross median inside 125–210 s.
His P1 wins 13 of 120 (10).

### 25.4 The re-freeze on §25.3's reach (2026-10-18)

- The first freeze (8d11bee, §25.2) is superseded: round 1's two stopped cells and its briefs removed, the workspace's
  `baseline/` re-taken on §25.3's rules (the CPU's ranged bands moved with the reach, §25.3), the brief's rules summary
  updated, round 1 planned again (`plan --beta 0.6`).
- The baseline at 40 seeds: **score 0.0** (raw 0.3803): strength 0.006 (3 of 480), masher 0.103, signature 0.716 (chain
  0.385, ranged 0.20, bind 0.13, plain J 0.109); NORMAL share 0.115 (Y 20, K 3, R 4, I 6, S 17, Lille 5 of 80), factor 0;
  pacing ok (NORMAL medians 126.2-165.6 s).
- The freeze is the commit adding this baseline (`step.sh` / `rescore.sh` find it).

### 25.5 The ranged L's recovery cancelled by J / K; the K 2–5 m; the tip's SP gain (the user, 2026-10-18; a sim change)

> 「然後 L 後可以接 J / K」; asked which L and how: 「卍解遠距的 L 鎖払」, 「理解成 J / K 能取消卍解遠距 L 的後搖」,
> 「卍解的遠距 J / K 能取消 L 的後搖」. Then 「然後卍解遠距 K 改成 2~5 m」 and 「然後卍解遠距的鎖鏈尾端除了傷害加成以外也增加 SP
> 恢復量的加成」.

The re-opened round 1 (§25.4: b0a0, b1a0, minutes in) was stopped again; the search re-freezes on these rules (§25.6).

**As built**:
- **L SAHARAI's recovery cancel** (`duel/lisp/hisagi.lisp` `:hs-r-l` `:params (:r-cancel (:q :f))`; the shared reader in
  `duel/lisp/fighter.lisp` MOVE-COMMANDS, the J / K branch, after the Breaker's: a move whose `:params :r-cancel` names the
  command starts it through TRY-COMMAND from its first recovery frame, S + A): J / K start J1 / K1 out of L's recovery,
  whether L hit, was blocked or whiffed (the literal reading; L's 32 f recovery stays the price of not cancelling). No other
  move has the key (host-pinned), so every other fighter's play is unchanged.
- **The K 2.0–5.0 m** (`*hs-r-k-dead*` 1.0 → **2.0**, `*hs-r-k-reach*` 4.0 → **5.0**; K2's two caps 2.0–4.5 r 0.5; the tip
  4–5 m): the J (3–6) and the K overlap on 3–5 m, the 3.5 m placement inside both. The CPU's SAHARAI band `*hs-ai-close*`
  1.0 → 2.0, its bands 0–2 L, 2–3 K1, 3–5 K1 / J1, 5–6 J1. The art's K (K1's spin, the spread K2s / K3, the gathered K2 / K3G)
  drawn to 5.0 m.
- **The tip's SP gain** (`*hs-r-tip-sp-mult*` **1.3**, the lead's number, the damage's): HS-DMG-MULT marks a tip hit (the
  ranged mode, x1.3) with his Reiatsu before the hit's gains (HSS-TIP-R); his :hit hook (HS-BK-HIT) pays the gain since the
  mark x0.3 more (with the tip's damage x1.3: x1.69 a non-tip hit's Reiatsu); a non-tip hit clears the mark. A `duel hisagi`
  counter `tip-sp`.

**Host tests**: duel-rules 9874 (+4: the r-cancel key on SAHARAI only; the tip's mark, its pay x1.3, a non-tip hit's none),
the volumes, dead zones, table reaches, tips and the CPU's reach reads re-pinned to K 2–5; control 89, learn 131, cine 18 ALL
PASS; pkgcheck clean.

**Smoke** (browser, `--fixed-dt`): the six routes land three hits each at K 2–5 (KKK K1 K2 K2 K3G, KKJ, KJJ from 2.5 m; JJJ,
JJK, JKK from 3.5 m; J1 J2 K3 from 6.0 m); L then J at once: L J1 J2 J3; L K1 K2; L K1 J2s; a whiffed L at 6 m then J1. A dump
of the moves (centre to centre): K1 / K2s / K3 / K2 (both windows) / K3G min 2.0, far edge 5.0; J1 / J2 / J3 / J2s / J3G 3.0,
6.0 (a hit lands to the far edge + the victim's hurt radius ~0.36 m, as everywhere).

**Gates** (the lead; the playtest Artifact v107 first): the 42 non-Hisagi lines of `--seeds 10 --summary` (fighter.lisp is
shared: the new key is read only off a move that has it) and `--cvc` byte-identical. His 7 pairings at 20 seeds (before =
§25.3): HY 127.3 s (128.3), HK 132.9 (131.9), HR 152.8 (152.4), HI 160.3 (151.3), HS 165.8 (172.1), HB 169.5 (157.0), HH 217.0
(206.6, a mirror); every match a K.O., every cross median inside 125–210 s. His P1 wins 11 of 120 (13).

### 25.6 The search restarted: the re-freeze on §25.5-§25.10 (the user, 2026-10-19)

> 「請幫我重新開始風格型學習 AI 的開發」

- **The host tests on the rules since §25.7** (deferred until now on the user's word): duel-rules **9877** ALL PASS
  (control 89, learn 131, cine 18, input 33; pkgcheck clean). The fixes, the tests only:
  - the every-move walk lets a `:seg-fn` window start before S (KOJO's yank at f20, S 30);
  - the Bankai table reads the guard of the window at S;
  - the KOJO block reads the reap's window (index 1), with a new pin on the yank (f20-21, 20 damage, a flinch, `:seg-fn`);
  - the drawn-reach walk skips windows without volumes and checks SENGEN's (2.2 m);
  - the leap J copies' reach 1.4 → 1.7 (§25.9).
- **The evaluator**: `SIG_HISAGI`'s bind theme takes `HS-B-SJ` (SENGEN, §25.10: "every HS-B- move but its Kikon").
- **The workspace**: round 1's two stopped cells and briefs (§25.5) removed; the brief's rules summary on §25.5-§25.10;
  `baseline/` re-taken; round 1 planned again (`plan --beta 0.6`, 4 × 2 cells, W = 2, the same branch styles).
- **The baseline at 40 seeds**: **score 0.0** (raw 0.3842):
  - strength **0.000** (0 of 480);
  - masher 0.107;
  - signature 0.726 (chain 0.442, ranged 0.176, bind 0.108, plain J 0.13);
  - NORMAL share **0.033** (Y 3, K 0, R 2, I 2, S 6, Lille 3 of 80), factor 0;
  - pacing ok (NORMAL medians 118.0-166.7 s).

  He is weaker than at §25.4's freeze (NORMAL 0.115), likely because SAHARAI's slower startup and its hit-only cancel cost the shipped
  CPU's close defence.
- The freeze is the commit adding this baseline (`step.sh` / `rescore.sh` find it).

### 25.7 SAHARAI's longer, readable charge; KOJO's yank a hit; the grey bar after a Kikon in a bind (the user, 2026-10-19)

> 「不用跑 gate / 然後把 L 的前搖加長，並把前搖時蓄力的動作模組做的更容易辨識 / 都我說開始測試在測試 / 卍解近距離 L 拉扯的那一下
> 也算入傷害判定 / 然後我發現如果在捆綁的狀態下受到毀魂技攻擊，那下一條血量的灰血就會失效」; asked which L and how long:
> 「卍解遠距 L 鎖払 10→18 幀」

Built, not tested (the user: tests and gates wait for their word); the playtest Artifact v109.
- **L SAHARAI** `*hs-saharai-s*` 10 → **18** (A 4, R 32, block −16, the J / K recovery cancel unchanged). Its clip
  `:hs-k-saharai` (18/4/32) redrawn for the charge: the wrap (f4), then he sinks and curls ever tighter with a shudder side to
  side (f9-16), a beat's rise (f17), the burst on S; the orb spins up two full turns into S (`*hs-spins*` 3/10/24 x1 → 2/18/32
  x2) and the curtain whirls faster and faster round him (the lashes' keys f4-17), the ring at 3.0 m on f18-21, the rest
  shifted 8 f (f1 44 → 52); the 0-byte probe frames 15 / 26 → 23 / 34.
- **The bind's L KOJO**: the noose's yank at `*hs-kojo-pull-at*` (f20) is a hit of its own, f20-21 (`*hs-kojo-yank-to*` 22)
  along the chain to the victim (`:seg-fn hs-foe-seg`: any distance in the bind, blockable, guard 8), **20** damage
  (`*hs-kojo-yank-dmg*`, the lead's number, the windmill push's), a flinch; the drag goes on and the reap (S 30-33, 70) combos
  after it.
- **The grey bar after a Kikon in a bind** (a display bug): the Kikon refilled the victim's Reishi bar on a lost soul, but
  the HUD's grey band still ended at his Reishi at the bind's start, so the new bar showed no grey until it fell below that.
  `bind-grey-frac` (combat.lisp): his Konpaku below the snapshot's → the band runs to the bar's max (the whole new bar is
  grey). The bookkeeping was right (a release restores the snapshot, a drained end makes the grey real).

### 25.8 SAHARAI blocked: no J / K cancel (the user, 2026-10-19)

> 「讓遠距 L 鎖払被擋下後不能通過 J/K 取消後搖」

> then 「打空也一樣不能取消」

MOVE-COMMANDS' `:r-cancel` branch (fighter.lisp) now also asks that the move hit (its contact `:hit`): only a SAHARAI that
hit cancels into J1 / K1 from its first recovery frame; a blocked or whiffed one plays its full 32 f recovery (−16 on block).
Built, not tested (tests wait for the user's word).

### 25.9 The Shikai's J a little longer (the user, 2026-10-19)

> 「然後幫我把始解的 J 範圍稍微加長」

`*hs-j-reach*` (new) **1.7 m** for J1 旋 SEN / J2 返旋 KAESHI-SEN / J3 輪 RIN (1.4, the J floor's, → 1.7: the lead's number for
「稍微」, +0.3 m); the leaps J2K / J3K are their copies; the J ender's push follows J1's reach (1.7 + its 0.3 lunge + the body
+ 0.05). The art: J1 now lets its right sickle out on the chain to 1.7 m on its hit frames (a new `*hs-letout*` row, f3-18,
as J2's), J2 / J3 and the leaps' let-outs 1.4 → 1.7, `*hs-strike-reach*` likewise. Built, not tested (tests wait for the
user's word).

### 25.10 The bind's Step + J: 穿弦 SENGEN (the user, 2026-10-19)

> 「給檜佐木的卍解捆縛狀態新增一個 step+J 能使出的新招式，這招打中對手的話能接 J1 取消後搖」

In the bind mode (`:bankai-bind`) the Step's J (the hop's J cancel from `*step-j-cancel*` f12, or a J latched in the hop)
starts the new `:hs-b-sj` 穿弦 SENGEN instead of J1 (`hs-bk-command`: the form, `:q`, the fighter still in `:step`).
Frame data the lead's pick: S 10 / A 3 / R 22, 40 damage, reach 2.2 m arc 60, on hit `:stagger`, a 0.6 m lunge, blocked
-10, guard 10. A hit cancels its recovery into J1 (`:params (:r-cancel (:q))`, MOVE-COMMANDS' §25.5 branch: from S + A,
on a hit only; blocked or whiffed it plays its 22 f out); the J1 then opens the bind's J / K grid as usual. Its own
clip `:hs-kb-sengen` (sunk low out of the hop, the right crescent by the hip; the lunge, the arm thrown straight, the
crescent let out on its chain to 2.2 m, `*hs-letout*` f6-13-24; `*hs-strike-reach*` 2.2), strip slot 83534, in
`*hs-tip-moves*`. The CPU: its existing step-J read now starts SENGEN in a bind (it still reads J1's reach); no new CPU
use. Tests: the `:r-cancel` pin now names SENGEN too. Built, not tested (tests wait for the user's word).

### 25.11 The spread route's SP, the gathered route's guard damage (the user, 2026-10-19; a sim change, the search re-frozen)

> 「幫我把遠距 J1 起手的散路線再增加額外的 SP 回收量，K1 起手的聚路線增加削防值」

Asked, the user chose: 「×1.3（推薦）」 for both; 「起手也加」 (J1 and K1 themselves too); for the search's two cells (minutes in),
「停掉，改完重新凍結（推薦）」.

**As built** (`duel/lisp/hisagi.lisp`):

| Knob / value | Old → new |
|---|---|
| `*hs-r-spread-sp-mult*` (new) | — → **1.3**: J1, J2, K2s, J3, K3's Reiatsu gain x1.3; on a tip hit x the tip's 1.3 (x1.69) |
| `*hs-r-gather-guard-mult*` (new; the values written into the moves) | — → **1.3**: K1 / K2 guard 14 → **18**, J2s 8 → **10**, K3G 18 → **23**, J3G 12 → **16** |

- The mechanism is §25.5's tip-SP mark:
  - HS-DMG-MULT marks his Reiatsu on a tip hit or a spread-route hit, with the extra factor (a new HSS slot, `tip-x`, not
    hashed);
  - HS-BK-HIT pays the gain since the mark x that extra (the `tip-sp` counter counts both).
- The damage multipliers are unchanged (the spread x0.85, the gathered x1.3, the tip x1.3).

**Host tests**: duel-rules 9880 ALL PASS (the Bankai table's gathered guard values; the knobs and the guard x1.3 of the
old values on every window; the SP cases: K1 at the tip x1.3, K1 / gathered K2 off the tip none, J1 at the tip x1.69, J1 /
K2s off the tip x1.3). Control 89, learn 131, cine 18 ALL PASS; pkgcheck clean; built (playtest Artifact v115). The sim
gates are not run (the user: 「不用跑 gate」).

**The search**: round 1's b0a0 / b1a0 (minutes in) stopped, their briefs removed; the baseline re-taken on these rules,
round 1 planned again (§25.12).

### 25.12 The re-freeze on §25.11 (2026-10-19)

- §25.6's freeze (1544267) is superseded; `baseline/` re-taken on §25.11's rules; round 1 planned again (`plan --beta 0.6`,
  4 × 2 cells, W = 2).
- The baseline at 40 seeds: **score 0.0** (raw 0.3848):
  - strength 0.000 (0 of 480);
  - masher 0.107;
  - signature 0.727 (chain 0.436, ranged 0.178, bind 0.112, plain J 0.128);
  - NORMAL share **0.042** (Y 5, K 0, R 3, I 3, S 6, Lille 3 of 80), factor 0;
  - pacing ok (NORMAL medians 117.2-172.7 s).
- The freeze is the commit adding this baseline (`step.sh` / `rescore.sh` find it).

### 25.13 The bind stronger and longer, the tip x1.71, the route links reach him where he is (the user, 2026-10-19; a sim change)

> 「1. 把捆縛提高到沒有乘上近身倍率依舊能高於平均值 1.2 倍、並把近身加成升到 1.3 倍。 2. 將遠距的鏈尖加成提高到能讓 K 串傷害能到平均值的
> 1.3 倍。 3. 遠距 J / K 不再將人固定到 3.5 m 處。 4. 延長近身的時長（SP 與血量互換從 1:2 改成 1:3）」; asked (the plan first,
> 「一樣先跟我講修改方式」): 「共用 1.71」, 「1:4」, 「先停掉搜尋」, 「拿掉定位，改成後續接上的 J / K 會自動調整判定範圍，然後鏈尖判定會
> 直接延續 J1 / K1 打中時的判斷狀態」; on a blocked opener and the reach: 「都照你的建議，7.0 m 可以」.

The comparison (the lead's dump of every form's slots, 2026-10-19): the "average" is the mean of the 21 forms the game flags
awakened (every other fighter's; their kit's damage x included), per command slot.

**As built** (`duel/lisp/hisagi.lisp`, `hisagi-art.lisp`):

| What | Old → new |
|---|---|
| Bind J1 / J2, J3 | 32 → **45**, 40 → **55** (the mean 37.0 / 37.1 / 45.8, x1.2 rounded up) |
| Bind K1, K2, K3 | 64 → **93**, 56 → **81**, 80 → **116** (76.9 / 67.4 / 96.0 x1.2) |
| Bind L KOJO (`*hs-kojo-dmg*`) | the reap 70 → **83** (with the yank's 20: 103 >= 85.5 x1.2) |
| Bind SP1 KUSARI-AME (`:hs-r-sp2`, the bind's only) | 70 + 90 → **112 + 144** (256 >= 212.7 x1.2) |
| Bind Kikon KOSHU | 70 → **111** (91.8 x1.2) |
| Bind SP2 KAIBAKU-GEKI, Step J SENGEN | unchanged (120 already x1.49; SENGEN has no slot to compare) |
| `*hs-b-close-mult*` | 1.2 → **1.3** (within 1.2 m) |
| `*hs-bind-drain-rate*` (new; rules BIND-DRAIN's rate) | 0.5 → **1/3**: the pool loses 1 per 3 damage (an SP still 1:1; 0.25, 1 per 4, at first, then the user: 「捆綁模式的 SP 血量互換率還是改成 1:3 好了」) |
| `*hs-r-tip-mult*` (shared by every ranged move with a volume) | 1.3 → **1.71**: K1 → K2 → K3G all on the tip 68 + 43 + 55 + 147 = 313 >= 1.3 x the mean K string 240.3 |
| The 3.5 m placement (`*hs-r-j-push*`, HS-R-J-PUSH, HS-R-UCHI-PUSH, HS-PLACE-TO, `*hs-r-uchi-frames*`) | **removed**: J1 / J2 / K1 / K2's slam place nothing; J3 / J3G's 6.6 m ender push, SAHARAI's 3.5 m and KUBIKAKE's yank kept |
| The route links (J2 K2s J3 K3, K2 J2s K3G J3G) | their volumes and dead zones → one :seg-fn window each (K2 two), **HS-R-LINK-SEG**: the chain from his hand to the victim's centre, its far end capped at **`*hs-r-link-reach*` 7.0 m** from his feet (+ the victim's body); `:reach` 7.0 (the CPU's and the chase's read) |
| The tip of a route link | **its opener's**: HS-DMG-MULT records J1 / K1's tip read at their contact (hit or block: 「都照你的建議」) in HSS-ROUTE-TIP; a link takes x1.71 / x1.0 from it, whatever its own distance (both of K2's windows); the SP marks follow (the tip's x1.3, the spread route's x1.3) |

- **The look**: `*hs-lk*` / HS-LK! / %HS-LK-R. While a route link is drawn, its chain's distance from his feet r is stretched
  to r x (1 + (k - 1) u^2): k is the victim's distance (capped at 7.0) over the clip's authored reach (`*hs-lk-reach*`: J
  6.0, K 5.0), u is r over that reach. The strike point lands on the victim; the windup's near keys barely move. It is
  applied to the let-outs, the chain strikes and the lashes.
  - The art FK walk skips :seg-fn windows (it measures fixed volumes).
  - Debug 83902's tip list skips moves whose first window has no volume.
- **The CPU (the baseline's, the minimum)**: HS-R-REACHES-P reads a route link's chain as 7.0 m (+ 0.36), so the route
  picks still fire.

**Host tests**: duel-rules **9850** ALL PASS (−30: the links' volume and dead-zone rows, the placement and K2 push rows, replaced by):
- the links' chain windows, their 7.0 m end (5 m: on him; 9 m: 7.0 m out) and the CPU reach read;
- the inherited tip (J1 / K1 on the tip → J3 / K3 / K2's second window / J2s / K3G x1.71 at any distance; off the tip → x1.0);
- the knobs (1.71, 1.3, 1/3), the K string's 313 >= 312.4;
- the bind's table and routes (145 206 242 290 229 193), the drain at 1 per 3.

Control 89, learn 131, cine 18 ALL PASS; pkgcheck clean; the build with the 4 known Lille warnings.

**Smoke** (headless, `--fixed-dt`): from debug 83017, J J J lands all three (22 19 26); from 83016, K K K lands K1, K2's two
and K3G (40 25 32 86); debug 83902 runs; no exception. The sim gates are not run (the user: 「不用跑 gate」).

**The search**: stopped after round 1's four first cells (b0a0 0.637, b1a0 0.5669, b2a0 0.6836, b3a0 0.7658 at the §25.12
freeze); b0a1 / b1a1 were briefed but not dispatched (removed). It re-freezes on these rules (§25.15).

### 25.14 FREE back: the bind's P release (the user, 2026-10-19; a sim change)

> 「目前捆綁模式被攻擊與其他的硬直狀態下，能主動使用 SP2 解除綁縛並打斷對手攻勢嗎」 (no: in hitstun / blockstun only Burst and
> AWAKEN are taken, and KAIBAKU-GEKI has S 18, no invulnerability); 「原本 free 按鍵的效果是不是能做到這件事？」 (yes: §17.3's
> FREE, removed in §24.5); 「恢復 FREE 按鍵」.

**As built**: §24.5's removal reverted for FREE only (KUBIKAKE keeps no cooldown and its 60 f whiff):
- **The hook**: `*hs-bk-hooks*` regains `:p hs-p-press :p-label hs-p-label` (the bind mode only; the ranged mode's
  `*hs-r-hooks*` has none), so the touch deck's chip reads FREE again.
- **The release**: HS-P-PRESS, HS-REL-FREE-P, HS-REL-DUE-P, HS-P-PRESSED! and HSS-REL-HELD are back. When it can be pressed:
  - at once from idle / walk / guard / blockstun / a run;
  - in hitstun or airborne under the Burst rule (inputs not locked, past the combo's 2nd hit);
  - during his own move: held to its last frame, never a cancel.

  At the step's release slot (where a Burst applies, before the hits) the effects are:
  - the bind ends (the snapshot back, the pool split, B8);
  - the hazards are cleared;
  - the opponent's move ends into a `*hs-bind-reel*` 30 f stagger;
  - his own hitstun ends into UNWIND (20 f, no hit).

  No damage, no cost. The hash line's H column is back.
- **His CPU (the baseline's)**: `*hs-ai-plain-release-p*` (0.1 / 0.15 / 0.2) and HS-B-AI-REFLEX's plain-P branch are back.
  Behind on grey with the foe beyond KAIBAKU-GEKI's reach, he presses FREE that often, else he waits.

**Host tests**: duel-rules **9854** ALL PASS (+4). The bind kit has `:p` / `:p-label`, the ranged kit has none, and the
label reads "FREE". HS-REL-FREE-P and HS-REL-DUE-P are pinned again. FREE is refused in a combo's 1st hit and taken from its
2nd. A press held during a move fires on its last frame. P is the plain release (no strike, UNWIND, no reel after). Control
89, learn 131, cine 18, touch 64 ALL PASS; pkgcheck clean; built.

**Smoke** (headless): debug 83012 (a bind 3 m from Kenpachi), P → `KAIBAKU`, `BIND RELEASED: 300.0 to the opponent, 133.3
back`, UNWIND; the probe after shows no bind. The sim gates are not run (the user: 「不用跑 gate」).

### 25.15 The re-freeze on §25.13-§25.14; round 1 restarted (the user, 2026-10-19: 「重新凍結 AI 基準並重開第一輪」)

- §25.12's freeze (7623542) is superseded. Its round 1 (b0a0 0.637, b1a0 0.5669, b2a0 0.6836, b3a0 0.7658) is kept as
  history in `prior/round01-s2512/`. The brief gives it as PRIOR_DIR and warns cells never to copy those files' sim: they
  carry the old placement, the old bind and the old tip. Its rules summary is on §25.13-§25.14.
- The baseline at 40 seeds: **score 0.0** (raw 0.4149):
  - strength 0.006 (3 of 480);
  - masher 0.188;
  - signature 0.751 (chain 0.373, ranged 0.204, bind 0.174, plain J 0.111);
  - NORMAL share **0.104** (Y 11, K 2, R 7, I 5, S 14, Lille 11 of 80), factor 0;
  - pacing ok (NORMAL medians 115.0-174.7 s).

  Two runs were stopped before this one: one on the 1:4 drain and one on 1:3 before FREE.
- Round 1 is planned again (`plan --beta 0.6`, 4 × 2 cells, W = 2, the same branch styles). The freeze is the commit adding
  this baseline.

### 25.16 The Shikai's showpiece combo for his CPU (the user, 2026-10-20; CPU only, no sim change)

- The user: 「始解可以用 J1 J2 J3 > L > K1 K2 > J3 > L > K1 K2 K3 做為強力的花式連段，也可以將中段或結尾換成 SP 減少連段並提高
  輸出。」
- The route uses the rules as built:
  - J1 J2 J3: the plain J string.
  - L: the bridge off a J link (§23.1).
  - K1 K2: the windmill's K string.
  - J: after K2 this is the leap J3K, the combo's one leap (§23.5, §24.4).
  - L: the bridge again (J3K is a J link).
  - K1 K2 K3: the K string again.
- The SP versions cancel the middle or the end into SP1 / SP2 (the generic SP cancel off a hit): a shorter string that
  hits harder.
- Nothing in the sim changes. The CPU search's brief (`docs/research/hisagi-ai-drsi/brief.py`) now names the route and its
  SP versions, so the cells briefed from here on (round 1's b2a1 / b3a1 on) may build it into his Shikai CPU. The cells
  already run (b0a0-b3a0, b0a1) and b1a1, in flight, were briefed before it.
- The user, on whether to tell b1a1 (the Bankai ranged refine, in flight): 「不用 這套留給使用始解戰鬥的探索格研究即可」. So
  b1a1 is not told. The brief marks the route for cells whose style fights in the Shikai.

### 25.17 Round 1 on the §25.15 freeze: results (2026-10-20)

- 12 cells (4 branches × 3 attempts), each rescored at the freeze 3686d94 with 40 seeds. Every cell passed its host tests,
  pkgcheck and the awaken A/B (the never-awaken side ≥ 21 of 60 on every row; the baseline's rows were 0-4).

| cell | parent | what it added | score | HARD strength | signature | NORMAL share | chain / ranged / bind of his damage |
|---|---|---|---|---|---|---|---|
| b0a0 | - | b3a0's (§25.12) Shikai ported; KAZAGURUMA-GAESHI (the windmill wards a charging shot, then a charged K string), TODOME (RAIDEN ender on a red victim); Bankai at 4500 | 0.783 | 0.435 | 0.905 | 0.525 | 0.895 / 0.005 / 0.005 |
| b0a1 | b0a0 | MIKIRI / TSUME: past a 0.42 perfect-Hoho rate on K1 he walks the chain in by hand | 0.7945 | 0.498 | 0.890 | 0.527 | 0.881 / 0.005 / 0.004 |
| b0a2 | b0a1 | the HARD combo plan at the first hit: RINNE 80 % (J1 > L > K1 K2 > J3K > L > K1 K2 K3 > RAIDEN), RINNE-OWARI 10 %, HANA 10 % (§25.16's showpiece exactly) | 0.8203 | 0.552 | 0.909 | 0.527 | 0.901 / 0.005 / 0.004 |
| b1a0 | - | Bankai at 2000; ranged route styles SENTAN 60 / KAISEN 25 / NAWAJI 15 | 0.7517 | 0.400 | 0.863 | 0.5625 | 0.605 / 0.175 / 0.083 |
| b1a1 | b1a0 | MACHI-GUSARI: the Bankai never swings at a standing opponent, every route off an answer | 0.7741 | 0.448 | 0.879 | 0.490 | 0.562 / 0.219 / 0.098 |
| b1a2 | b1a1 | TAIHO / NIGE: a pure hop once his hop lash is blocked or Hoho'd; MIKIRI across forms | 0.7783 | 0.467 | 0.877 | 0.523 | 0.572 / 0.216 / 0.089 |
| b2a0 | - | Bankai at 3000; KUBIKAKE only off a confirmed hit; the SAHARAI-cancel read fixed; binds TSURI / SHIME | 0.7855 | 0.458 | 0.896 | 0.454 | 0.777 / 0.066 / 0.053 |
| b2a1 | b2a0 | b0a2's Shikai merged in; KOSHU: in the bind he walks in to J1 range and every string ends in the cinching K route | 0.8229 | 0.565 | 0.907 | 0.475 | 0.812 / 0.046 / 0.049 |
| **b2a2** | b2a1 | SHIBARI-GUCHI: the bind's first J1 timed to land inside the noose's reel (first hit his in 96 % of binds, from 75 %); SANGE 0.5 at HARD | **0.8325** | 0.598 | 0.908 | 0.508 | 0.795 / 0.050 / 0.063 |
| b3a0 | - | the three themes by probability; the HARD reap's 3-frame approach proof; the waking noose; the bind's ledger | 0.785 | 0.490 | 0.876 | 0.5625 | 0.757 / 0.079 / 0.041 |
| b3a1 | b3a0 | b0a2's wheel + MIKIRI merged in; b1a1's MACHI-GUSARI; every Shikai SP ender RAIDEN (SHIBARI's slam lost to hitstun decay) | 0.8144 | 0.552 | 0.899 | 0.506 | 0.806 / 0.062 / 0.031 |
| b3a2 | b3a1 | UTSUSEMI: HARD Hohos a committed swing near him 0.9 while his flash-step lasts; b2a1's KOSHU bind; the waking noose off | 0.8281 | 0.623 | 0.882 | 0.508 | 0.815 / 0.043 / 0.025 |

- §25.16's showpiece, measured (b0a2, HARD, 480 matches each, one route forced): RINNE 254 wins, RINNE-OWARI 251, the
  showpiece HANA 237, no plan 233, an SP in the middle (J1 > L > K1 K2 > RAIDEN) 203. The back half is his strongest
  route; the J1 J2 J3 head is plain J and starts the damage decay early. An SP in the middle can't carry into a second K
  string: the generic guard-cancel lock (FIGHTER-GC-LEFT) and RAIDEN's recovery (f47) leave K1 landing 5 f after the 40 f
  paralysis. SP2 SHIBARI as the ender measured weaker than RAIDEN (b3a1).
- A 40-seed score moves about ±0.01-0.02 with the seed draw alone; the cells compared variants on 960-1200 HARD matches.
  b2a2, b3a2, b2a1 and b0a2 are within that of each other.
- Shared-code findings (not done; they touch other characters):
  - ai.lisp's generic Step → J fires his ranged J1 off every escape hop, the Bankai ranged mode's largest leak.
  - The kit's `:hoho` is one number for every difficulty.
  - AI-AWAKEN-P has no per-style or per-difficulty hook.
  - The forced O ender on a red victim has no kit hook.
- Lille stays 0-2 of 80 at HARD in every cell (her level-3 snipe goes through the windmill).
- dream-rsi: `close-round` froze round 1 into `trace_pool/iter01`. `compare` ranked the skill's adaptive_template
  (reward 0.361) over the fixed parallel-refine incumbent (0.205), and it was promoted for round 2.

### 25.18 After round 1: a combined candidate and an 80-seed final (the user, 2026-10-20)

- Asked to pick between a combined final (recommended), a round 2, an 80-seed final of the top two, or the shared-code
  fixes first, the user chose 「合併後決選（推薦）」.
- The combined candidate (`combo/b3a2+b2a2/`, not a search cell): b3a2's file plus b2a2's own changes over b2a1
  (SHIBARI-GUCHI, the bind's bite; SANGE 0.5 at HARD). The two change different parts (b3a2 the Shikai's defence, UTSUSEMI;
  b2a2 the bind's first hit) and share b2a1's KOSHU bind and b0a2's Shikai, so the merge is a three-way merge of b2a2's
  CPU diff against b2a1 onto b3a2.
- The final (`final80/`): b2a2, b3a2 and the combined candidate rescored at the freeze 3686d94 with 80 seeds
  (`aieval --char 7 --seeds 80`). The user picks the shipped CPU from these. Integration follows the pick (task: the
  style mix, learner situations, AUTO COMBO, AUTO GUARD's windmill, gates).
- **The final at 80 seeds** (the freeze 3686d94):

| candidate | score | HARD strength | signature | NORMAL share | NORMAL wins Y / K / R / I / S / Lille of 160 | ranged + bind of his damage |
|---|---|---|---|---|---|---|
| b3a2 | **0.8324** | 0.635 | 0.884 | 0.509 | 93 / 54 / 70 / 91 / 119 / 62 | 0.063 |
| combined (b3a2 + b2a2's bite) | 0.8282 | 0.621 | 0.884 | 0.5125 | 93 / 55 / 72 / 91 / 119 / 62 | 0.066 |
| b2a2 | 0.8285 | 0.584 | **0.907** | 0.496 | 95 / 47 / 71 / 77 / 122 / 64 | 0.110 |

  The combined candidate's 40-seed score was 0.8239. On paired HARD matches
  (seeds 1-240, 2880) b3a2 won 1789, the combined 1759, b2a2 1638: the bite makes the bind itself better (49.4 dealt / s
  from 43.9, 570 drained from 516) but the ranged mode after it worse (Rukia, Ichigo); no located bug. b2a2's SANGE 0.5
  was not carried (b3a2's ranged mode has no SANGE style). Every match a K.O.; NORMAL medians 106-160 s.

### 25.19 The pick: the combined candidate ships (the user, 2026-10-20)

- Asked to pick from the 80-seed final (b3a2 0.8324, b2a2 0.8285, the combined 0.8282), the user chose 「合併版」.
- Adopted onto main: `combo/b3a2+b2a2/hisagi.lisp` as `duel/lisp/hisagi.lisp` (main's file was still the freeze's, so a
  plain copy), its `HISAGI-CPU-TESTS` section spliced into `tests/duel-rules-test.lisp` (identical to the delivered file).
- What ships, per difficulty (HARD; EASY / NORMAL keep the gentler values the cells left them):
  - **The Shikai** (most of a match): RENSA 80 % of HARD matches / KARIBA 20 %; MIKIRI / TSUME (walk in once his K1 is
    perfect-Hoho'd past 0.42); the combo plan at the first hit (RINNE 80 %, RINNE-OWARI 10 %, HANA 10 % = §25.16's
    showpiece); KAZAGURUMA-GAESHI; TODOME; every Shikai SP ender RAIDEN; UTSUSEMI (a committed swing near him Hoho'd 0.9
    while his flash-step lasts).
  - **The Bankai** at 3000 taken: MACHI-GUSARI at the chain tips (only answers, no neutral swings), the route style per
    entry SENTAN 60 / KAISEN 25 / NAWAJI 15, the noose off a confirmed hit, no waking noose.
  - **The bind**: KOSHU (walk in to J1 range, every string the cinching K route), SHIBARI-GUCHI (the first J1 timed into
    the noose's reel), the grey ledger (release when behind, drain when ahead).
- Checks on main: duel-rules 9878 ALL PASS; control 89, learn 131, input 33, cine 18 ALL PASS; touch 64, 0 failures;
  pkgcheck clean; `./build.sh duel` built; headless smoke ok. The sim gates are not run (the user's 「不用跑 gate」 stands);
  the cell's awaken A/B (seed0 100) passed.
- Next: the integration (§25.1 step 6): the learner's Hisagi situations, AUTO COMBO's routes, AUTO GUARD's windmill.

### 25.20 The integration: the learner's situations, AUTO COMBO's routes, AUTO GUARD's windmill (2026-10-20)

> The user (2026-10-18, §25): 「學玩家習慣」「AUTO COMBO 路線」「AUTO GUARD 風車」; built on the shipped CPU (§25.19).

His CPU's decisions are unchanged: everything below runs only with a learner (a CPU Hisagi facing a human) or for a human
with ASSIST on. CPU vs CPU, `aieval --char 7 --seeds 10 -j 2` before / after: the JSON is identical (score 0.8324, HARD
strength 0.633, masher 1.0, signature 0.885, NORMAL share 0.575, every pacing median the same). The only shared code it
uses is the existing hooks (`learn-def-kit`, `:assist-guard`, `:assist-combo`); no shared file changed. All in
`duel/lisp/hisagi.lisp`'s new section "the learning CPU's situations and ASSIST" (since 2026-10-21 in `hisagi-ai.lisp`).

**The learner** (`learn-def-kit :hisagi`, DUEL_LEARNING §11; the user's design §17.5 #16 asked for "bound, ahead / behind"):

| Situation | Opens (HS-LEARN-SIT) | Read where (once per event, the learner's own stream × `*hs-learn-diff*`) | The plan for his predicted answer |
|---|---|---|---|
| `:reap` | his K1 (not a windmill's K string) starts on a free human | the fence's reap roll, once an approach (HS-AI-FENCE → HS-LEARN-REAP) | a Hoho → no reap (MIKIRI per human); a swing / taking it / backing off → the reap; else as rolled |
| `:ward` | his windmill KAZA (not the bridge) starts, the human not reeling | the ward's sweep roll (HS-AI-SIG-HOLD → HS-LEARN-WARD) | he comes in / shoots again / backs off → the sweep (L held, the charged K string after the shot); a Hoho / a guard → the plain hold |
| `:bind-ahead` / `:bind-behind` | a bind's neutral (both free, its first step), by the grey ledger (HS-GREY-MARGIN ≤ 0: ahead) | the bind's walk-in decision (HS-B-AI-REFLEX → HS-LEARN-BIND; HARD's, `*hs-ai-b-close-p*`) | he swings or Hohos → a guard (the punish after); he guards → the Breaker (inside 3 m, allowed); else the walk-in |

- The human's answer classes `:guard :hoho :attack :back :take`: the generic LEARN-ACTION read as his (HS-LEARN-CLASS: any
  move an attack, a Hoho or Step a Hoho, backing off > 1.2 m along the onset's line); reeling `:take`; at the episode's end
  (`*hs-learn-episode*` 30 f + the perception delay) a held guard `:guard`, else uncounted. The sickle-out situation of §10's
  table is not one: no move leaves the sickle out since S1 (§23.1).
- A read that changes the pick is counted (LEARN-COUNT-READ, its 60 f pay-off) and logged (`read-<situation>-<class>` in the
  pacing log). Without a learner (every gate, aieval) HS-LEARN-READ returns NIL: the rolls are the same SIM-RND01 draws,
  their results kept.
- Knobs: `*hs-learn-diff*` (:easy 0.5 :normal 1.0 :hard 1.5, Lille's), `*hs-learn-episode*` 30.
- Native smoke (the learning gate's runner, HARD, 4 seeds each: P1 Hoho-happy Rukia, a plain CPU Kenpachi, grab-happy
  Yamamoto, P2 Hisagi learning): every kit situation counted and predicted (e.g. `reap=hoho 0.57/18.7 ward=attack 1.00/4.7`
  against the Hoho habit, `bind-ahead=attack 0.49/3.8` against the plain CPU); no errors.

**AUTO GUARD's windmill** (`:assist-guard` HS-ASSIST-GUARD, the Shikai only; §10's row): a ranged threat 4-24 f out
(RANGED-THREAT-IN, the sickle in, L allowed), one roll per threat at his CPU's `*hs-ai-windmill-p*` (the assist's HARD
brain: 0.9): L, the windmill up through it, marked `:assist` so HS-AI-SIG-HOLD holds it `*hs-ai-windmill-hold*` (36 f) and
rolls no K (his own K out of it starts the charged K string). In ALWAYS it comes before the held guard. Nothing existed for
it before (his kits had no `:assist-guard`; AUTO GUARD's generic parry / guard / Hoho only).

**AUTO COMBO's routes** (`:assist-combo` HS-ASSIST-COMBO, all three forms): at a hit's land step his CPU's own pick on the
assist's brain, the latch emptied (HS-AS-DECIDE), pressed on his J (HS-AS-PRESS: J pressed or latched in that move, the
generic rule); where the pick is J, his own J does it (unassisted); a pick that ends the string eats his J (no whiff).
- **The Shikai**: the combo's route plan (HS-AI-PLAN / HS-AI-PLAN-CMD, *HS-AI-PLAN-P* HARD 1.0: RINNE 80 %, RINNE-OWARI
  10 %, HANA 10 %): J1 > L > K1 K2 > J3K > L > K1 K2 K3 > RAIDEN (the user's §25.16 showpiece HANA one combo in ten). The K
  out of a bridge the assist pressed comes at his CPU's frame (HS-KAZA-TICK: a windmill that is FIGHTER-ASSISTED, the K its
  press rolled, HS-AI-KAZA-K; the assist's held L let go; that K string assisted, x0.8); a human's own windmill never.
  The enders (K3: RAIDEN by `:sp-ender`, the O on a red victim) are the generic AUTO COMBO's.
- **The Bankai's ranged mode**: his J while free with the opponent on K1's chain tip (4-5 m, HS-R-TIP-CMD) is K1 (on J1's
  tip, 5-6.2 m, his J already is); each link by the style rolled at the mode's entry (HS-R-AI-MOVE: SENTAN / NAWAJI / KAISEN,
  the K for the tip's damage, the J, the end where neither reaches, NAWAJI's noose off the opener); SAHARAI that hit: his J
  is K1 when the style's pick from where it pushes him is K1.
- **The bind**: the cinching K route and its TODOME (HS-B-AI-MOVE, `*hs-ai-b-route-p*` HARD 1.0); the bite's timing
  (HS-B-BITE-CMD: his J held back while his yank still brings the victim in).
- State: two never-hashed HSS slots (`as-key` the move's start tick, `as-cmd` its entry).

**Debug** (DUEL_GAMEPLAY "Debug commands", claimed): 83020 P1 the ASSIST gate's button-masher with ASSIST ALWAYS + COMBO +
BREAK vs a CPU Lille 6 m off (her shots: the windmill; the route plans), 83021 the same in the Bankai's ranged mode vs
Kenpachi. Native runs of each (one match): 83020 the full RINNE wheel from the first combo (J1 > L > K1 K2 > J3K > L > K1 K2
K3, 29 windmill K strings, 11 leaps, 2 RAIDEN; the windmill against her shots blocked BR-K-HIREN twice), P1 9-0; 83021 J1 >
K2s > K3 > the noose (KUBIKAKE's cancel) > the bind's J1 > K2s > K3 > KUSARI-AME, TODOME off K2s.

**Tests**: duel-rules 9885 (+7 in a new "Hisagi's learner and ASSIST" block after HISAGI-CPU-TESTS: the spec, the class map,
the onsets, the three plans, HS-AS-ENTRY / HS-AS-PRESS, the keys on his kits only); control 89, learn 131, input 33, cine 18
ALL PASS; touch 64, 0 failures; pkgcheck clean; `./build.sh duel` built (the 4 known Lille style warnings). The sim gates,
ASSIST's gate and the learning gate were not run (the user's 「不用跑 gate」); the manual's CPU / ASSIST lines are not written.

### 25.21 Faster seed runs (the user, 2026-10-20)

- The user asked how to speed the seed runs up; of the options offered, 「先做 1、3、4」, and asked whether turning off the
  picture and sound would help.
- Measured (4 cores): the native build ~2 min (redone when hisagi.lisp changes); a process's load 1.2 s + init 1.0 s; a
  match ~0.55 s a core; aieval's 40 seeds = 31 processes, ~12 min at -j 2 with the build; 80 seeds ~17 min at -j 2, ~11 min
  at -j 4. A cell's 1.5-5 h went to its own variant comparisons (960-2880 HARD matches each) and the awaken A/B (1080).
- **Picture and sound**: already off in the sim (tools/simgate/stubs.c: frames draw nothing, no audio device, so no sound
  is synthesized; the turbo steps never draw). What is left of the startup (~2.2 s a process, ~70 s of CPU an aieval run,
  ~3 %) is not worth a sim change.
- **1. -j 4 when alone**: `rescore.sh` / `step.sh done` take `JOBS=4` (the rows are the same at any -j); the cells keep -j 2
  (two run at once).
- **3. Stop early**: the brief's Step 4 now asks for paired comparisons in 240-match blocks, stopping once the paired win
  difference passes 2 standard errors or at 960 matches (a tie: keep the simpler file).
- **4. The awaken A/B only when it can change**: only when the cell changes the awakening's gate or NORMAL's Shikai CPU
  (the never-awaken side); otherwise the parent's rows are quoted.

### 25.22 The manual's lines, the windmill through a held guard (the user, 2026-10-21)

- The user (verbatim): 「幫我修改你說的這兩件事」, of the two left open after §25.20: the manual had no line on his CPU or
  ASSIST, and in ALWAYS a held guard (10-30 f) kept HS-ASSIST-GUARD from being asked, so a shot arriving during it got the
  guard instead of the windmill.
- **The held guard**: shared, assist.lisp ASSIST-STEP (DUEL_ASSIST "A kit's answer through a held guard"): the kit's
  `:assist-guard` is asked through a held guard too; an answer other than the guard replaces it at once. 83020, one match:
  windmills 33 -> 35, one 4 f into a held guard (none before), hits taken 22 -> 20.
- **The manual** (duel/web/manual.html; he still has no section of his own): AUTO GUARD's row (the windmill against a shot,
  also out of ALWAYS's guard; his own K out of it), AUTO COMBO's row (the Shikai's route, the ranged mode's tip K1 and
  SAHARAI's K1, the bind's cinching route and the bite held while the yank reels), and a bullet in 會學習的電腦 (his CPU in a
  few lines and the learner's four situations).
- Host tests 9885 / 131 / 89 ALL PASS, pkgcheck clean, built, smoke; no gate run (「不用跑 gate」).

### 25.23 The ranged L's armour: one hit through the charge (the user, 2026-10-21)

- The user (verbatim): 「我想要請你幫我把修兵卍解的遠距 L 多加一層的霸體，讓他可以扛下一次攻擊」.
- **Built** (a sim change): `:hs-r-l` SAHARAI gains `:armor-hits *hs-saharai-armor*` (0 -> 1), the shared move armour
  (fighter.lisp DEFENDER-STATE, rules ARMOR, the same as Kenpachi's KITTE MIRO YO charge): from move frame *ARMOR-FROM* (6)
  to S-1 (17), i.e. through the charge his §25.7 windup draws, the first hit he takes is `:armored`: its damage, no
  hit-stun or knockback, the move goes on; a second hit in the same charge, a hit from frame 18 on (the swing, the
  recovery) and a Breaker / unguardable / rend hit him as before. The bind mode's L (`:hs-b-l`) keeps none.
- Not changed: his CPU / ASSIST / learner (they still pick L by distance, not as an armoured reversal); no new look (the
  generic `:armored` feedback shows the absorbed hit).
- Host tests 9888 ALL PASS (the knob and both moves' `armor-hits` checked), pkgcheck clean, built, smoke; no gate run
  (「不用跑 gate」): the simgate rows of his pairings change.

## 18. Open

- §24.5 (no FREE, KUBIKAKE without a cooldown, whiff 60): built and gated (every median in the window); his P1 wins 10 of 120.

- §24.4 (one leap a combo, K1 3.0 m, the bridge push 2.5): built and gated (every median in the window); his P1 wins 9 of 120.


- The art pass (§24): batches A1 (the Shikai; built, §24.1), A2 (the Bankai ranged mode and the look; built, §24.2) and
  A3 (the bind's L / SP2 and the ranged L's recovery; built, §24.3), presentation only, waiting on the playtest; no
  stand-in clip left.

- The Bankai's look approved (the user, 2026-10-18: 「可以 但我希望鎖鏈是黑色的」, §21.6); its slot plan approved (§21.7), its clips built (batch B3b, §21.8: presentation only, waiting on the playtest). Still open: the awaken A/B (§20.9), waiting on the user's playtest.
- The two modes made distinct (§22): B4a built (§22.2: the sim, the CPU, a placeholder look); open: the playtest, his 7 pairings at 20 seeds and his awaken A/B, the art pass B4b.

- Answered (the user, 2026-10-17): Q9 A, Q10 A, Q11 A, **Q12 B** (no drip), **Q13 C** (no re-arm wait); the body follows them. To watch at the gates: a stalled bind (no drip) and the clock. Hooks 5 / 7 built as batch B1b (2026-10-17, §17.4 "As built"); the Shikai built as batch B2a (2026-10-17, §19); the Bankai's rules, bookkeeping and CPU as batch B2b (2026-10-17, §20; its look held for a motion-style pass). Open from B2b: the awaken A/B (both directions, §20), the HB / HH medians.

- The user's answers to §13; then a second review pass on what they change, and batch 1 (`duel-character`'s build order).
- The motion-style confirmation and its research (§11.2: kusarigama, rope dart, Blades of Chaos), then the model sheet
  stills.

### 25.24 The windmill's catch holds its K as a guard would (the user, 2026-10-23)

- The user (verbatim, in a Hisagi Shikai mirror): 「為什麼修兵一擋下遠攻後就可以直接發動 K 攻擊？甚至能打斷對手繼續出招」; then
  「幫我確認普通防禦是否有類似的問題」; shown the measurements: 「擋下後給硬直」.
- **Cause (measured in the native sim)**: the windmill's :ranged-ward catches a ranged hit with no blockstun, its K string
  starts from windmill frame 9 (S1) and it has no cooldown (2026-10-18). Against the mirror's K1 the defender's K1 hit on
  the attacker's frame 36 of 44: +26, beating his K2. A **plain guard** has no such gap: every blocked link that can still
  chain is held by the guard lock (advantage 0), only the ender K3 TSUI (+20, his K1 punishes at 3.5–4.5 m) and SP1 / SP2 /
  O (+14, nothing reaches) leave the attacker open; hazards give a fixed 14 f (at most about +12). Hisagi's edge there is
  reach (K1 3–6 m in 18 f, the Bankai J1 in 14 f), not the guard.
- **Change**: a catch records the tick a plain guard's blockstun would end (FIGHTER-WARD-UNTIL, combat.lisp APPLY-HIT's
  ward branch: the same BLOCKSTUN / *HAZARD-BLOCKSTUN* the guard would get); the windmill's K string (hisagi.lisp
  HS-KAZA-K-FREE-P) waits for it and then, like the guard lock, while the attacker's move can still go on (CHAIN-MORE-P).
  A windmill that caught nothing (the J bridge, S1) is unchanged; the windmill still blocks everything it did.
- **Measured after** (native sim, the mirror at 4.5 m; A = the attacker free again): K1 alone: the windmill's K1 at A+0,
  as a plain guard (was A−25, hitting on f36 and beating K2); K1→K2: held through both catches, no interrupt; K3 TSUI:
  still punished (as a plain guard punishes it); SP1 RAIDEN, Yamamoto's L wave, Lille's SANREN: no punish any more (was
  A−26 / A−21 / a trade); the J1 → L bridge → K string identical on hit and on guard. The wait first ran 3 f short (the
  block's hitstop passes *MATCH-TICK* but not a guard's blockstun): the catch adds *HITSTOP-BLOCK*.
- Host tests 9983 ALL PASS, pkgcheck clean, built 0 warnings; no gate run (「不用跑 gate」).

### 25.25 The windmill's hold stands still while a catch holds its K (the user, 2026-10-23)

- The user (verbatim): 「修兵的風車每次擋下對手攻擊後的硬直時間不計入風車的延續時長中，以免在對手的連擊過程中被中斷風車」.
- **Change** (hisagi.lisp HS-KAZA-TICK): from the windmill's K frame (*HS-KAZA-K-FROM*, f9) to its last held frame,
  while a catch holds the K (HS-KAZA-K-FREE-P, §25.24: the plain guard's blockstun, then the attacker's chain), the
  move's frame stands still (FIGHTER-SF steps back each frame), and its clip with it (a look). The 60 held frames, the
  20-frame minimum and L's release count only the free frames; the charge still counts the frames L is held (cap x1.6
  unchanged). A windmill that caught nothing is unchanged.
- **Measured** (native sim, L held from frame 0): the mirror's K1 → K2 → K3 at 3.5 m and 4.5 m: before, the windmill
  ended on frame 79 and K3 hit him (stun 93–132); after, it stays up through the string (0–158), nothing lands.
  Yamamoto's two separate L waves: the windmill 0–79 → 0–92 (the second wave is a new press, not a chain: it still
  lands after the hold). No attack: 0–79 both.
- Host tests ALL PASS, pkgcheck clean, built 0 warnings; no gate run (「不用跑 gate」).


### 25.26 The chain tip 0.5 m, its glint and its landing (the user, 2026-10-23)

- The user (verbatim): 「我想為修兵的尖端位置增加提示，你覺得有什麼適合又不會突兀的方式嗎？」; the lead proposed 1 a glint
  before the hit on what would strike (the hanging chains' ends for K, the right crescent for J), 2 a mark on a tip hit,
  3 a ground ink arc (the most UI-like, held back); the user: 「1+2，然後幫我將鏈尖加成縮短至 0.5m」.
- **The tip 1.0 -> 0.5 m** (`*hs-r-tip*`; a sim change): the ranged mode's x1.71 (and the SP x1.3) now in the outer 0.5 m of
  each volume: J1 5.5-6.0 m, K1 4.5-5.0 m (plus the hurt radius), SP1's line its last 0.5 m, a route link still by its
  opener's read (§25.13). The CPU follows: HS-R-TIP-CMD reads the knob (J1 5.5-6.2, K1 4.5-5.2; at 1.0 it gives the old
  bands exactly), the route styles' back-hop distance (:keep) SENTAN 4.6 -> 4.75, KAISEN 5.0 -> 5.75 (the bands' middles).
- **The glint** (a look, hisagi-draw.lisp): free in the ranged mode (idle / walk / guard / run, no bind, no cinematic), the
  opponent on K1's tip (HS-TIP-BAND, the same bands as HS-R-TIP-CMD, the host sweeps both 0-8 m): each resting hanging
  chain's free end shows a small white 4-point star (r 0.15 m, twinkling on the drawings, each chain its own phase); on
  J1's tip the right crescent's blades (0.6 m along the weapon joint) show one twice as large (it sits on black steel).
  `*hs-tg*` holds the band for the draw; 0 B a frame (83901 at 4.75 and 5.75 m: 0 on the repeat call).
- **The landing** (a look): HS-DMG-MULT notes a tip hit in a new HSS slot `tip-hit` (no sim reads it, not hashed); a new
  generic kit hook `:hit-fx` (FEEDBACK-SYSTEM calls the attacker's after the hit's spark; only his Bankai kits have one,
  HS-TIP-FX) adds the stamp `:tip` (vfx-stamps.lisp %ST-TIP, code 30: the white flash, a long 4-point STEEL cross of light
  round a white 8-spike core, 6 steel shards; envelope 1 2 3 9) and the sound `:hs-tip` (a bright 1.5 kHz ring and a
  short jingle).
- **Debug**: 83022 / 83023 the ranged mode 4.75 / 5.75 m from an idle Kenpachi (the K / J glint; DUEL_GAMEPLAY).
- **Host tests** 10065 ALL PASS (the tip's bands re-pinned to 0.5 m: HS-DIST-MULT, the opener reads, K1 at 4.5 / 4.4 m,
  HS-R-TIP-CMD 5.5-6.2 / 4.5-5.2 and nothing at 5.3-5.45, HS-TIP-BAND = HS-R-TIP-CMD at every 0.1 m, the :keep values on
  their bands, KAISEN's punish at 4.0 m now J1 (off the tip) and K1 at 4.6); control 89, learn 131, cine 18; pkgcheck clean;
  built 0 warnings. Browser: the glints and the landing seen (83022 / 83023, K1 at 4.75 m), no exception.
- **Simgate** (10 seeds, every pairing): every row without him identical to the last run; cvc 3/3. His rows, all K.O.
  (before -> after): HY 110.3 -> 108.5 s, HK 110.7 -> 110.7, HR 145.5 -> 145.5, HI 152.6 -> 153.0, HS 160.9 -> 159.8, HB
  unchanged, the mirror 185.2 -> 169.4. HY and HK sat under 125 s before this change too; the awaken A/B not run (his recent
  changes went in without it, 「不用跑 gate」).

### 25.27 The K tip's flow down the hanging chains (the user, 2026-10-23)

- The user (verbatim): 「幫我將 K 添加白色流光流過鎖鏈作為提示（p2 則是黑色流光）」.
- **Change** (a look, hisagi-draw.lisp %HS-CUBIC-CHAIN): while the opponent stands on K1's tip (`*hs-tg*` 1, §25.26's
  band), each resting hanging chain (no lash, not bundled) carries a streak of light running down it from 0.35 of its
  length (below the frame's top) to its free end every `*hs-flow-period*` 0.7 s (each chain 0.37 of a period apart; the
  streak 0.14 of the chain long, widest at its middle, 0.045 m half-width): white (FX-SHARD, +PAL-HIT+) on P1's black links,
  solid black (%HS-BLACK-KITE, now with an optional push, x1.5 wide) on P2's ink links. It adds to §25.26's end glints; J's
  glint on the crescent unchanged. 0 B a frame (83901 at 4.75 m: 0 on the repeat call).
- **Debug** 83024: the Bankai mirror 4.75 m apart, both CPUs off (both on K1's tip: both flows).
- Built 0 warnings, the browser shots checked (83022, 83024), no exception; nothing the sim reads changed (no gate run).

### 25.28 The flow rarer, the end glints to J, the crescent's glint off (the user, 2026-10-23)

- The user (verbatim): 「降低流光的頻率，然後把 K 原本鎖鏈端點閃耀的特效轉交給 J，並將 J 的鐮刀閃耀關閉」.
- **The flow** (§25.27): each chain's streak still runs down in `*hs-flow-period*` 0.7 s, now once every
  `*hs-flow-every*` 1.8 s (back to back until now; the lead's number), the chains still 0.37 of a cycle apart.
- **The cues by band** (`*hs-tg*`): on K1's tip (4.5-5.2 m) the flow only; on J1's tip (5.5-6.2 m) the hanging chains'
  free-end glints (§25.26's, unchanged in look); the right crescent's glint removed (with `*hs-gl*`).
- 0 B a frame (83901 at 4.75 and 5.75 m: 0 on the repeat call); built 0 warnings; shots 83022 / 83023 checked; nothing
  the sim reads changed.

### 25.29 The flow once a second (the user, 2026-10-23)

- The user (verbatim): 「流光改成 1 秒」. `*hs-flow-every*` 1.8 -> 1.0 s: each hanging chain's streak starts once a second
  (read as the interval §25.28 set; its run down the chain stays 0.7 s). Built 0 warnings; a look only.

### 25.30 The chain tip 0.75 m (the user, 2026-10-23)

- The user (verbatim): 「尖端距離改成 0.75m」. `*hs-r-tip*` 0.5 -> 0.75 (a sim change): J1's tip 5.25-6.0 m, K1's 4.25-5.0 m
  (plus the hurt radius: HS-R-TIP-CMD / HS-TIP-BAND J1 5.25-6.2, K1 4.25-5.2, nothing at 5.2-5.25); the cues follow the
  bands (§25.28). The CPU's :keep values (4.75, 5.75) stay inside them.
- Host tests 10065 ALL PASS (the bands re-pinned to 0.75 m); pkgcheck clean; built 0 warnings; smoke clean. Simgate (10
  seeds): every row without him identical; his rows as §25.26's except one mirror match (the mirror's median 169.4 s
  unchanged); all K.O.

### 25.31 The flow back to 0.7 s (the user, 2026-10-23)

- The user (verbatim): 「流光改回 0.7s」. `*hs-flow-every*` 1.0 -> 0.7 s: each chain's streak starts again as the last
  ends (§25.27's rhythm); the run down stays 0.7 s. A look only; built 0 warnings.

### 25.32 The ranged mode's Step lands on a chain tip (the user, 2026-10-23)

- The user (verbatim): 「我還想設計讓修兵透過 step 移動時，能優先落在尖端的距離，請問有什麼好的設計方式嗎？」; the lead's
  options: 1 by direction, the nearest band (1.5-3.5 m), 2 forward = K's band, back = J's, 3 a soft 0.5 m pull; plus a side
  Step circling (left open). The user: 「選 1 但改成長度在 1.75~2.5 之間自動調整」 (the side Step unchanged).
- **Rule** (hisagi.lisp HS-STEP-LENGTH, a sim change; the ranged mode's new `:step-dist` hook, START-STEP calls it with the
  hop it would make): a forward Step (its cosine toward him >= 0.7) lands in the nearest chain-tip band inward (J1's
  5.25-6.0 m first, then K1's 4.25-5.0), a back one (<= -0.7, neutral included) the nearest outward (K1's first); each band
  0.05 m in from its edges, its middle (5.625 / 4.625 m) when the hop reaches it, else the nearest point it can; the hop
  only shortens: 2.5 -> at least `*hs-step-min*` 1.75 m (her field's shorter hop stays the cap). No band in reach, or a
  side Step: 2.5 m as before. The Step's frames, iframes and J cancel are unchanged. Not in the bind or the Shikai.
- **Measured** (browser, the neutral Step): 3.5 m -> 5.62 (J1's middle, a 2.125 m hop); 2.5 m -> 4.62 (K1's middle);
  4.75 m -> 7.25 (nothing outward in reach: 2.5 m).
- Host tests 10066 ALL PASS (+1: the forward / back picks at 8, 7, 3, 2, 3.6 m, a side Step, no band, her field's hop, a
  diagonal one, and a 0-10 m sweep: every changed hop 1.75-2.5 m lands 0.04 m inside a band); control 89, learn 131;
  pkgcheck clean; built 0 warnings. Simgate (10 seeds): every row without him identical; cvc 3/3; his rows all K.O., the
  medians as §25.30 (HY 108.5, HK 110.7, HR 145.5, HI 153.0, HS 159.8, HB 157.2 s) but the mirror 169.4 -> 188.9 s.

### 25.33 The flow's run and rhythm 1 s (the user, 2026-10-23)

- The user (verbatim): 「流光的落下速度跟頻率都改成 1s 看看」. `*hs-flow-period*` 0.7 -> 1.0 s (the streak's run down a
  chain) and `*hs-flow-every*` 0.7 -> 1.0 s (one a second per chain, still back to back). A look only; built 0 warnings.

### 25.34 The ranged mode's reaches: J 4-7 m, K 2.5-5.5 m (the user, 2026-10-23)

- The user (verbatim): 「J 的攻擊範圍修改成 4~7 m，K 的攻擊範圍修改成 2.5~5.5 m　這樣有什麼要注意的事情嗎」; the lead listed what
  moves (the tips, the larger dead zone, J3's push by its rule, the 7.0 m route links, the balance, the art, the CPU) with
  defaults; the user: 「好，照這樣調整」.
- **The sim** (hisagi.lisp): `*hs-r-j-dead*` 3.0 -> 4.0, `*hs-r-j-reach*` 6.0 -> 7.0, `*hs-r-k-dead*` 2.0 -> 2.5,
  `*hs-r-k-reach*` 5.0 -> 5.5 (the openers J1 / K1; the route links keep `*hs-r-link-reach*` 7.0, which J1's far edge now
  meets); `*hs-r-j3-push*` 6.6 -> 7.55 (out of J1's 7.0 + a body 0.45 + 0.05, plus the ender push the host checks). The
  tips follow (0.75 m): K1 4.75-5.5, J1 6.25-7.0 (HS-R-TIP-CMD 4.75-5.7 / 6.25-7.2; none at 5.7-6.25); the cues and the
  Step's landing (§25.32: the bands' middles 5.125 / 6.625) with them. Nothing of his reaches inside 2.5 m but L SAHARAI
  (3.0 m) and the Breaker.
- **The CPU** (hisagi-ai.lisp): HS-R-HITS-AT-P reads the knobs (J1 4.05-7.2, K1 2.55-5.7); the route styles' back hop
  (:keep) SENTAN 4.75 -> 5.125, KAISEN 5.75 -> 6.625 (the tips' middles), NAWAJI 3.5 -> 4.5 (both openers reach); the waits
  inside J1's dead zone (3.0 -> *HS-R-J-DEAD*) and the blocked-string K1 (2.1-3.0 -> 2.6-4.0); the kit's :ranges (approach
  4.75-5.5, pressure 4.0-5.0, zone 4.75-6.6, defend 6.0-7.5) and :moves bands (0-2.5-4-5.5-7 m).
- **The art** (hisagi-art.lisp; the drawn reach equals the hit reach): `*hs-strike-reach*` J1 / J2 / J3's crescents and
  the gathered J2s / J3G 6.0 -> 7.0, K1 / the spread K2s / K3 / the gathered K2 / K3G 5.0 -> 5.5; the crescents' let-outs
  6.0 -> 7.0; J3's swept chain 5.9 -> 6.9; the lashes' strike keys (r >= 4) x1.1 (K) / x7/6 (J). Debug 83902: J1 7.00 x3,
  K1 5.50 x4 against edges of 7.00 / 5.50. Debug 83022 / 83023 / 83024 moved to the new tips (5.125 / 6.625 m).
- **Tests** 10066 ALL PASS (the tables, the dead zones, the annuli, the tips, the CPU's reads, HS-R-PICK at the new
  distances, the Step's landings re-pinned); control 89, learn 131, cine 18; pkgcheck clean; built 0 warnings; 83901 0 B on
  the repeat call; the browser: J1 at 6.625 m and K1 at 5.125 m land (the tip flash on K1).
- **Simgate** (10 seeds, every pairing): every row without him identical, cvc 3/3; his rows (before -> after): HY 108.5
  -> 108.7 s, HK 110.7 -> 110.7, HR 145.5 -> 136.5, HI 153.0 -> 147.7, HS 159.8 -> 156.3, HB 157.2 -> 161.9, all K.O.; the
  mirror 9 of 10 K.O. (one 300 s time-out), so 20 seeds: 19 of 20 K.O., median 168.0 s; the parent commit at 20 seeds:
  20 of 20, 168.1 s, so the time-out is this change's (reported to the user, nothing retuned). HY and HK stay under 125 s
  as before.
- **CPU score** (`aieval --char 7 --seeds 10 -j 2`, before -> after): 0.8253 -> 0.8256 (strength 0.617 both, masher 1.0,
  signature 0.881; NORMAL's share 0.49 -> 0.47, in its 0.3-0.6 band).

### 25.35 The tip 0.5 m, J back to 3-6 m, K 2.5-4.5 m (the user, 2026-10-24)

- The user (verbatim): 「尖端範圍及改成 0.5m　J 範圍改回 3~6m　K 範圍改 2.5~4.5m」.
- **The sim**: `*hs-r-tip*` 0.75 -> 0.5; `*hs-r-j-dead*` / `*hs-r-j-reach*` back to 3.0 / 6.0; `*hs-r-k-dead*` 2.5 (kept),
  `*hs-r-k-reach*` 5.5 -> 4.5; `*hs-r-j3-push*` back to 6.6 (its rule from J1's 6.0). The tips: K1 4.0-4.5, J1 5.5-6.0
  (HS-R-TIP-CMD 4.0-4.7 / 5.5-6.2, none at 4.7-5.5); the Step lands at their middles 4.25 / 5.75.
- **The CPU**: the reads follow the knobs (J1 3.05-6.2, K1 2.55-4.7); :keep SENTAN 4.25, KAISEN 5.75, NAWAJI 3.5 (both
  openers reach); the kit's :ranges approach 4.0-4.5, pressure 3.5-4.5, zone 4.0-6.0, defend 5.5-6.5, the :moves bands
  0-2.5-3-4.5-6 m. The waits use the knobs (J1's dead zone 3.0; the blocked-string K1 2.6-3.0).
- **The art**: J's reaches back to §25.3's 6.0 (the crescents, the let-outs, J3's swept chain 5.9, the gathered J2s / J3G
  lashes); K's 4.5 (K1 HOSOKU's whirl, the spread K2s / K3, the gathered K2 / K3G: the strike keys x 4.5 / 5.5). 83902: J1
  6.00 x3, K1 4.50 x4 against edges of 6.00 / 4.50. Debug 83022 / 83023 / 83024 at 4.25 / 5.75 m.
- Host tests 10066 ALL PASS (the tables, the dead zones, the annuli, the tips, the CPU's reads, HS-R-PICK, the Step's
  landings re-pinned); control 89, learn 131, cine 18; pkgcheck clean; built 0 warnings; 83901 0 B on the repeat call; the
  browser: K1 at 4.25 m lands with the tip flash, J1 at 5.75 m lands.
- **Simgate** (10 seeds, every pairing): every row without him identical, cvc 3/3; his rows all K.O. (vs §25.32's, before
  §25.34): HY 108.5 -> 108.5 s, HK 110.7 -> 103.0, HR 145.5 -> 137.5, HI 153.0 -> 152.6, HS 159.8 -> 157.1, HB 157.2 ->
  170.2, the mirror 188.9 -> 163.4 (10 of 10 K.O.: §25.34's time-out gone). HY and HK stay under 125 s, as before §25.34.

### 25.36 A chain-tip hit ignores the combo scaling (the user, 2026-10-25)

> 「幫我將修兵卍解遠距的尖端判定也設成不受連擊衰減的影響」 (the user, 2026-10-25)

A new kit hook `:unscaled` (combat.lisp APPLY-HIT, read after `:dmg-mult`): the ranged mode's `hs-tip-now-p` answers T for
a hit HS-DMG-MULT just read on the tip (x > 1: the volume's last `*hs-r-tip*` m, or a route link riding its opener's tip
read), so it is dealt at combo index 1; the bind mode, L SAHARAI, the Breaker and hazards stay scaled. The new HSS slot
`tip-now` is reset on every read (the look-only `tip-hit` is unchanged). Host check in tests/duel-rules/core.lisp; host
10228 ALL PASS, build 0 warnings, smoke exit 0; no sim gate (the user's standing word, DUEL_RUKIA_TYBW §15). Record:
DUEL_RUKIA_TYBW §16.4, DEVLOG §366. Playtest v166.

### 25.37 The tip hint during a Step (the user, 2026-10-26)

The user: 「調整修兵卍解遠距的攻擊提示，現在在 step 的過程中似乎不會啟用遠距提示？要等站定後才會有閃點與流光。我希望能改成在過程中只
要經過尖端的範圍就會起動提示」. The hint (`*hs-tg*`: J1's chain-end glints, K1's flow down the chains, §25.26 / §25.27) was read
only while he stood, walked, guarded or ran; a Step (`:step`) is now one of those states, so the glints and the flow show on
any frame of the hop the opponent's distance is inside a tip band (HS-TIP-BAND), and stop when it leaves it. A look only.
