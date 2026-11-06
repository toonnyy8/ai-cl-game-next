# Matchup style CPUs (2026-11-06)

A CPU per pairing: each character gets a style of play written for one opponent, on top of the generic core CPU
(`duel/lisp/core-ai.lisp`, DUEL_CORE §5). Every other pairing keeps the generic CPU unchanged. The first pairing is Kenpachi vs Ichigo
("KI"). Method: the style-search order of DEVLOG §369 (skill `duel-character-cpu`), then dream-rsi (`docs/guides/DREAM_RSI.zh-TW.md`).

## 1. Decisions (the user, 2026-11-06, asked with AskUserQuestion, answered verbatim)

The request: 「我打算開始為每種對戰組合實作各自的風格 AI，並且同時對該組合的兩個角色進行探索，請基於 /anthropic-skills:dream-rsi 建立劍八 vs 一護時的 AI」.

| Question | Options | The user's choice |
|---|---|---|
| The process | §369's four steps (data sheet → catalogue verified in the native sim → strategies as styles the user picks → a matchup CPU, its weights tuned by dream-rsi) / let the cells rewrite the CPU freely (AI v2) | **§369's four steps** (「照 §369 四步」) |
| Each side's opponent while both are searched | fixed opponents throughout (the other side's current generic CPU), new vs new recorded at the end / **each round, the other side's best version swapped in** and the baseline re-measured | **「每輪換上對方最佳版」** |
| Score weights | **strength 0.4 / signature 0.6** / 0.6 / 0.4 / 0.3 / 0.5 / masher 0.2 | **0.4 / 0.6** (「勝率 0.4 / 招牌 0.6」) |
| Budget | **3 rounds × 8 cells a side, W = 4** / 2 × 4, W = 2 / 4 × 10, W = 5 | **3 × 8, W = 4** (48 cells for both sides, 8 at a time) |

What these mean, as I will build them:
- **strength**: HARD, the side's CPU against the other side's CPU of the round, both seats: its win share.
- **signature**: the share of the side's dealt damage that comes from the moves on its style whitelist. The whitelist is
  fixed once the user picks the styles in step 3 (DREAM_RSI §5.9: a whitelist, never "anything but the J string").
- **The NORMAL band**: the score × a factor that falls to 0 when the side's NORMAL win share leaves a band around the
  shipped CPU's (DREAM_RSI §5.5). The band is set from the baseline below.
- **Co-evolution and the replay**: each round's opponent is the other side's best version from the round before (round 1:
  the generic CPU). Every round is re-baselined against its own opponent. Each frozen replay world is internally consistent,
  since all of its cells met the same opponent. The dream objective normalises each world by its own best, so worlds
  scored against different opponents still compare policies fairly. What is lost is a common scale across rounds: a round-2
  score does not mean the same as a round-1 score.
- **Masher**: dropped. A button-masher is not part of this pairing.
- **Seeds** (the user asked 「一定要用 40 場重量一次嗎？」, 2026-11-06): not required. One native process plays 10 KI matches in
  3.7 s, load included, and only one pairing is scored. I proposed 100 seeds a seat (about ±0.02 on a win share near 0.9);
  the user: 「不用這麼多，雜訊 ±0.03 已經很小了」. So **40 seeds a seat**: 80 HARD + 80 NORMAL matches, about ±0.03, seconds
  at -j 8. Then 「10~20 場不夠嗎？」: the win share's 1σ at p ≈ 0.9 is ±0.07 / ±0.05 / ±0.03 at 10 / 20 / 40 a seat (×0.4 in
  the score: ±0.027 / ±0.019 / ±0.013; near p = 0.5: ±0.11 / ±0.08 / ±0.06), and variants often differ by 0.02–0.05
  (DREAM_RSI §5.4). My proposal, 「好，按你的建議來」: **a cell compares its own variants at 20 seeds a seat; the coordinator's
  rescore, the dream-rsi record and the final pick use 40** (fixed seeds 1–20 / 1–40).

## 2. Baseline: the generic CPU in KI (2026-11-06, HEAD 382ab86)

Native sim (`tools/aieval.py`'s match runner), seeds 1–20 per row, both CPUs generic.

| Row | P1 wins | P2 wins | K.O. | Median |
|---|---|---|---|---|
| KI NORMAL (Kenpachi P1) | 18 | 2 | 20 / 20 | 201.5 s |
| KI HARD | 19 | 1 | 20 / 20 | 194.3 s |
| IK NORMAL (Ichigo P1) | 0 | 20 | 20 / 20 | 167.2 s |
| IK HARD | 2 | 18 | 20 / 20 | 173.6 s |

Kenpachi wins 37 of 40 at HARD and 38 of 40 at NORMAL. Over 20 HARD matches (both seats, seeds 1–10), his CPU never used:
- the Shikai's J4–J7 (open at L3);
- the special AS;
- either Bankai (KYORAN / ZANKAI).

The bursts (KE-S-BURST1 / 2) do occur, 54 hits in those matches. His damage comes from the sealed form's NS1 / AS1 / the
J string and the Shikai's NS1. Ichigo deals about 28 % of his hits in KESSA (520 of 1883), with 25 Getsuga waves in 20
matches. ~~and no Kikon~~: corrected in §3.

## 3. Steps 1–2: data sheets and catalogues (2026-11-06)

Two agents, one a side, in `docs/research/ki-ai/<side>/`: `sheet.lisp` (a host generator over the kits' `:core`) and its tables,
`trials.lisp` + `catalogue.md` (each entry played in the native sim by `tools/combo-trial.py`, P2 the other character), `means.md`
(the means against this opponent, each with its trials, and what the generic CPU can never reach).

| Side | Trials | Kept as refutations | Forms |
|---|---|---|---|
| Kenpachi | 153 | 6 | sealed, Shikai L0–L3, KYORAN, ZANKAI |
| Ichigo | 174 | 3 (+ range probes that miss by design) | Shikai (three pointers), KESSA |

**The trial tooling fixed** (`tools/simgate/trial.lisp`, `tools/combo-trial.py`; no game code):
- A core kit's P1 was never driven by its script. `brain-step` hands a core kit to `core-brain-step` before the `:trial` habit is read,
  so the generic CPU played every core trial. Now a core P1's brain is off and `trial-core-drive` calls `trial-step` once per sim frame.
- Every trial resets the match timer and both sides' SUBLIMATION / DRIVE / awakening gauges. They carried over and read 3–10 % high.
- New optional keys: `:ptr` / `:p2-ptr`, `:awaken`, `:p2-reishi`, `:p2-press` (P2 acting through his vpad, by trial frame), `:p2-at`
  (P2's J / SP by sim frame). The end line adds `konpaku` and `more` (P1's own Reishi, both Konpaku, form / pointer / kit meter).
- Rukia's 54 Shikai trials still run. Both KI files re-run after the merge: Kenpachi's are identical but for three held Kikons'
  end adv / dist; Ichigo's 45 rows deal a few % less (the gauge reset), and the re-run is the reference.

**Corrections to §2:**
- Ichigo does land Kikons. A 10-seed HARD diagnostic counted 126 follow-ups: 97 cancelled, 29 landed (13 of 13 on a red Kenpachi).
  The landed line reads `-> P1 KIKON n`, which aieval's hit regex (`-> P[12] (HIT|COUNTER)`) skips. The evaluator must count it.
- Kenpachi's stun tolerance 26 is inert: `*stun-blow-away*` is NIL since 2026-10-10.

**What the matchup turns on** (numbers: dealt damage; trial names in the catalogues):
- Up close (1.7–3.6 m) the triangle is Kenpachi's. His sealed J1 is S6 / 1.8 m against her S14; his NS1a (S14) beats every NS she
  starts from neutral; his CPU's reads (AS after a cancel, SA in his NS gap) beat both of her answers (Ichigo T1–T13).
- Ichigo's openings: his J whiffs (a whiffed J can't chain; NS1a / NS3a punish at 3.2 m), the 4–5 m band where only her NS3a reaches,
  the Getsuga from 7.5 m on (or point-blank inside AS2), a Kikon held only when he is red, and **pointer 3: a Soul Break there takes
  5 Konpaku instead of 3**.
- Kenpachi's openings beyond the sealed brawl: the Getsuga's charges are NS windows he can close with Hoho / Step + NS1; the Shikai /
  Bankai J1 cuts the wave; a meaty J1 wake-up loop (64 a loop); the Shikai's L2 route (251, ends at L3); the Bankai entry and
  KYORAN / ZANKAI strings (278–461).

**What the generic CPU can never reach** (why the matchup CPU needs code, not only weights):
- Kenpachi:
  - J4–J7, the special AS and the Bankai: `cai-move-step` forces an SP once the presses reach `:as-by-press`'s length, `(1 1 2)` in
    the Shikai, so J4 is never pressed;
  - his forced J3 + SP at pointer 1 is a burst that resets L;
  - **a CPU in a Bankai could never leave it**: the Bankai kits have no `:as-by-press`, so `(1 2 3)` forces the AS at J3, and J5 + SP,
    the only exit, never comes while each segment burns 40 Reishi. Hidden today only because the CPU never enters a Bankai;
  - no answer at 3.6–6.6 m: no `:ns-range`, so he walks into the Getsuga.
- Ichigo:
  - no Hoho off a hit, no Kikon off a later segment (so no wave Kikon), no NS3a from 4–5 m (moves start only within 3.6 m);
  - no Getsuga from 7.5 m or more (it dashes in past 7 m);
  - no whiff punish, no pointer steering;
  - the Kikon held into a 0.95 cancel when he is not red;
  - it charges NS2 inside 3.6 m, into his AS read: 18 of 37 charges were hit in the diagnostic.

## 4. Step 3: the styles and the signature (the user, 2026-11-06)

Asked with AskUserQuestion (multi-select, the search mixes the chosen styles by chance). The user chose all four on both sides:

| Side | Style | What it is |
|---|---|---|
| Kenpachi | 封印肉搏 (sealed brawl) | stay sealed: the J1 race (S6, 1.8 m against her S14), NS1a over every NS she starts, the pointer 3 tame as a read, the meaty J1 wake-up loop (64 a loop) |
| | 解放攀升 (the Shikai climb) | build L to 3 on purpose (three lunges, or L2's NS2 a–d SA J2 J3 AS2, 251, ending at L3), then J4–J7 and the special AS (INSEKI-GIRI 174–198, DAISHARIN 166–190 + launch); avoid the burst that resets L |
| | 卍解爆發 (the Bankai cash-out) | at L3 J1–J7 + SP into a Bankai (145, him 6 m away, +77), chase into KYORAN / ZANKAI strings (278–461), back by the special AS (CHIGIRI / TATE-GOTO). Needs the CPU's Bankai exit fixed |
| | 破月牙 (anti-Getsuga) | close the wave's charges with Hoho / Step + NS1, cut the wave with the Shikai / Bankai J1, Hoho late through it; fills his empty 3.6–6.6 m |
| Ichigo | 間合い管理 (spacing) | no exchange at 1.7–3.6 m; NS3a's lunge at 4–5 m (only she reaches; up to 197), the Getsuga from ≥ 7.5 m or point-blank inside AS2 |
| | 揮空反擊 (whiff punish) | wait near 3.2 m for his whiff (a whiffed J can't chain, 28 f recovery) and punish with NS1a / NS3a; his NS whiff when he stops (NS3a → 197) |
| | 指針三狩魂 (pointer 3) | run strings to J5 + SP to hold pointer 3: a Soul Break there takes 5 Konpaku, not 3; hold a Kikon only when he is red |
| | KESSA 強攻 | enter KESSA early (20 % Reishi back): the chains' NS1 to 3.4 m, +9; NS3a's SA from 4.2 m; AS2 routes end +79 at 4.8 m |

**The signature.** With four styles a side, the union of their moves is nearly every move, so a damage share would start near full. The
user: 「四種主題不用完全均衡，但請讓 CPU 能在需要的時候有效利用對應的工具」. So the signature is **how often the right tool works when its
situation comes up**, averaged over the four themes. Approved as drawn (「可以，照這張表」):

| Side | Theme | Situation (one count each) | Success |
|---|---|---|---|
| Kenpachi | 封印肉搏 | sealed, both inside 3.6 m, an exchange starts | the first hit of the exchange is his |
| | 解放攀升 | each stay in the Shikai | he reaches L3 and lands J4–J7 or a special AS |
| | 卍解爆發 | each time he is at L3 | he enters a Bankai and leaves it by the special AS (not by his Reishi running out) |
| | 破月牙 | Ichigo starts a Getsuga at 3.6–6.6 m | the wave does not hit him, and he hits her before her next move |
| Ichigo | 間合い管理 | the distance is 4–5 m or ≥ 7.5 m | she lands a hit from that distance (NS3a or the Getsuga) |
| | 揮空反擊 | he whiffs inside 3.6 m | she hits him during his recovery |
| | 指針三狩魂 | his Reishi bar breaks / she holds a Kikon | pointer 3 at the break (−5) / he is red when she holds |
| | KESSA 強攻 | her awakening gauge is full | she enters KESSA, and deals ≥ what she takes while in it |

A theme's score = successes / situations; a theme whose situation never came up scores 0; the signature = the mean of the four. The
situations are detected by a frozen observer in `tools/simgate/` that reads the sim's state each step, never by the CPU's own code.

## 5. Where the matchup CPU lives (2026-11-06)

- `core-ai.lisp` `*cai-styles*` (own character → opponent → function), registered by `cai-defstyle` from the style's own file. In
  `core-brain-step`, a registered style runs first on every step the CPU is free to press (no press held, not locked) and returns T when it
  decided; NIL leaves the step to the generic CPU. No entry: the generic CPU unchanged.
- The brain's new slot `style` holds the style's own state.
- `gate.lisp` `*step-hook*`: a tool's per-step observer, NIL in play (the evaluator's situation detector).
- Proof that this changes nothing: host tests 9843 ALL PASS, pkgcheck clean, native `--cvc` II / IK / KK identical.
- The style files: `duel/lisp/cpu-ki-ken.lisp` (Kenpachi against Ichigo), `duel/lisp/cpu-ki-ichigo.lisp` (Ichigo against Kenpachi), after
  `core-ai.lisp` in the MANIFEST. Once they register, IK's G2 reference moves by design; II and KK must stay identical.
