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

## 6. The evaluator and its baseline (2026-11-06)

`tools/matchup-eval.py --side ken|ichigo [--seeds 40]` (§1, §4), with the observer `tools/simgate/situ.lisp` run by
`tools/simgate/run-situ.lisp`. The observer hangs on `*step-hook*`, reads the state each step and prints a line as each situation
closes. Ichigo's pointer-3 theme comes from the combat log: her SOUL BREAK lines (ok at −5 Konpaku) and KIKON FOLLOW-UP lines (ok when
"(red)"). The NORMAL band runs against the other side's **generic** CPU (`SITU_GENERIC` unregisters its style), so one side's band
does not move when the other side's style changes from round to round. The band = the generic-vs-generic NORMAL share ± 0.10, the
factor falling to 0 another 0.15 out.

How each situation is detected (frozen with the evaluator):

| Theme | Opens | Closes / success |
|---|---|---|
| brawl | sealed, ≤ 3.6 m, either side starts a classed move, both free, no hit this step | the first Reishi drop within 120 steps: ok if only Ichigo's; no hit: not counted |
| shikai | Kenpachi enters the Shikai | he leaves it or the match ends: ok if ke-s-j4…j7 / ke-s-sp1 / sp2 hit during the stay |
| bankai | his L rises to 3 | ok when a Bankai entered after it ends back in the Shikai (only the special AS does that, `ken-bk-tick`); open at the match end: fail |
| antiwave | Ichigo starts ic-n2a / ic-k-n2a at 3.6–6.6 m | she starts a move outside the NS2 route, or 200 steps: ok if he hit her and her wave (a hazard of hers, or the wave segment) never hit him |
| spacing | the distance enters 4–5 m or ≥ 7.5 m, both free | ok if she hits him with a move started at ≥ 4 m or a wave; fail 90 steps after leaving the band |
| whiff | his classed move started inside 3.6 m passes its active frames with no contact | ok if she hits him before that move ends (+4 steps) |
| ptr3 | her SOUL BREAK / her KIKON FOLLOW-UP (combat log) | ok at −5 Konpaku / "(red)" |
| kessa | her awakening gauge fills (not in KESSA) | at the match end: ok if she entered KESSA and dealt ≥ what she took there |

**Baseline**: generic vs generic, 40 seeds a seat, at bcf196a plus the evaluator.

| Side | HARD | Strength | Signature | Themes (ok / situations) | NORMAL | Score |
|---|---|---|---|---|---|---|
| Kenpachi | 76/80 | 0.950 | 0.326 | brawl 0.66 (3472/5241), shikai 0 (0/65), bankai 0 (0/157), antiwave 0.64 (9/14) | 0.9625 (band 0.86–1.0) | 0.576 |
| Ichigo | 4/80 | 0.050 | 0.084 | spacing 0.02 (60/3011), whiff 0.22 (548/2511), ptr3 0.10 (88/901), kessa 0 (0/80) | 0.0375 (band 0–0.14) | 0.070 |

## 7. Step 4: the two style CPUs, v0 (2026-11-06)

Two agents, one file each: `duel/lisp/cpu-ki-ken.lisp` (`ken-ki-style`, knobs `*kk-…*`) and `duel/lisp/cpu-ki-ichigo.lisp`
(`ichigo-ki-style`, knobs `*iks-…*`). Each rolls once per event, reads the opponent through the perceived SNAP and the distance, writes a
combat-log line per style action (`kk …` / `Px ki-style …`), and keeps NORMAL's chances small. Ichigo's reads the opponent's form
directly (`fighter-form`) to choose its distance tables: a visible fact, the one exception to the SNAP rule.

**A bug in §5's hook, fixed:** `cai-style-fn` read `fighter-opp` (an entity) as a fighter, so the first registered style crashed on its
first step. §5's proof could not see it, since nothing was registered then. Both agents found it; the fix is one line.

| Against | Kenpachi's style | Ichigo's style |
|---|---|---|
| the other's generic CPU, 20 seeds a seat (the agents) | HARD 40/40, NORMAL 38/40 (generic 37 / 38) | HARD 39/40, NORMAL 3/40 (generic 3 / 2) |
| **each other, the evaluator, 40 a seat** | HARD 10/80; **score 0.351** (str 0.125, sig 0.501: brawl 0.57, shikai 0.77, bankai 0.31, antiwave 0.36); NORMAL 0.96 | HARD 70/80; **score 0.578** (str 0.875, sig 0.380: spacing 0.20, whiff 0.31, ptr3 0.56, kessa 0.46); NORMAL 0.11 |

- Kenpachi's style now enters the Bankai (18 a seat in 20 HARD matches) and leaves it by the special AS (13–16); his Shikai reaches L3
  and lands J4–J7 and the special AS. His anti-Getsuga mostly closes in; the timed cut / late Hoho fire rarely.
- Ichigo's style punishes his whiffs (J 0.93, NS 0.78 first-hit), lunges at 4–5 m, shoots from ≥ 7.5 m, steers strings to AS3 and holds
  Kikons only on red. Her default hover (3.7–4.2 m) sits outside the evaluator's whiff radius (3.6 m, the approved table), so most of her
  punishes don't count for that theme; the search may move the knobs. One time-out in 40 HARD matches (KI seed 8).
- Checks: host 9843 ALL PASS, pkgcheck clean, `./build.sh duel` with the allowed warning, native `--cvc` II and KK identical, **IK moves by
  design** (30 lines vs 42, P2 0-3 at 298.6 s). IK's reference waits for the search's final pick (regenerated then).

## 8. The search (dream-rsi, from 2026-11-06)

Workspaces `docs/research/ki-ai-drsi/{ken,ichigo}/` (README there), the freeze 989aaab (the evaluator and both v0 files).
- Round 1's opponent for each side is the other side's v0, its best version at the time (§1's "round 1: the generic CPU" was written
  before the v0s existed; v0 is the other side's best, which is what 「每輪換上對方最佳版」 asks).
- Baselines: Kenpachi 0.3505, Ichigo 0.5781 (§7). Grid 4 branches × 2 attempts a side, W = 4, λ 0.05 (the skill's default).
- What a cell may change: only its side's style file. Knobs, and how the four approved styles are carried out (thresholds, the mix,
  route choice, timing, a located bug), not new styles. §369 says the search "only tunes weights"; the styles stay the user's.

## 9. Round 1 and the evaluator's second freeze (2026-11-06 – 11-07)

Round 1, 8 cells a side, every cell rescored (the rescores reproduced each cell's own line exactly):

| Side | b0 a0 / a1 | b1 a0 / a1 | b2 a0 / a1 | b3 a0 / a1 | Champion |
|---|---|---|---|---|---|
| Kenpachi (baseline 0.3505) | 0.654 / 0.811 | 0.656 / 0.835 | 0.495 / 0.871 | 0.411 / **0.876** | b3_a1: the disciplined sealed brawl (moves only where they reach, Hoho / back Step through her lunge and clones, a Hoho kept in reserve), the climb and the Bankai cycle, the far-Getsuga answers (Hoho behind her, the cut, a forward Step through the wave) |
| Ichigo (baseline 0.5781) | 0.648 / 0.665 | 0.658 / 0.775 | 0.715 / **0.783** | 0.683 / 0.724 | b2_a1: the whiff confirm (punish a whiff seen in the SNAP), KESSA kept at pointer 3, the Konpaku-aware finisher (a red AS2 Kikon or the AS3 Soul Break for 5) |

- Reads beyond the SNAP that I accepted, HUD facts of the same class as `gauges-red-p` (which the generic CPU already reads): his /
  her Konpaku pips (Ichigo's finisher), her red bar (Kenpachi's Kikon gate), the opponent's form (Ichigo's distance tables).
- The champions against each other (40 a seat): **Kenpachi 74/80 at HARD, 0.808; Ichigo 0.292.**
- Dreaming: three policy candidates (`docs/research/ki-ai-drsi/policies/`: topk, spread, frontier) compared on each side's one world;
  **topk** (open the four roots, then refine the top ceil(1 + 3 β) branches by anchor) won on both (reward 0.360 / 0.347 against the
  baseline policy's −0.0125) and was promoted. The grid stays 4 × 2 (the user's budget).

**The evaluator, re-frozen** before round 2 (both changes in `tools/simgate/situ.lisp`):
- The user, asked whether a K.O. by Kenpachi's special AS should count for 卍解爆發 (most failures were him winning inside the Bankai
  with the way-back move itself): **「算成功」**. A Bankai entered after an L3 now succeeds once its special AS (ke-kr-sp / ke-zh-sp)
  starts and the match ends during it, as well as when he is back in the Shikai.
- A bug fixed: his Bankai segments' own 40-Reishi cost read as a hit on him. It made antiwave fail when it was his best outcome, and gave
  Ichigo's spacing / whiff false successes. A Reishi drop on the step a Bankai segment starts now discounts `*ken-bk-cost*`.
- Round 2 starts from the champions (each side's `baseline/` = its champion), not from v0: the opponent changed, so v0 is no longer the
  round's reference. The skill's protocol starts every round from the initial program; with co-evolution that would discard the
  round's opponent-specific work.

## 10. Round 2 and the evaluator's third freeze (2026-11-07)

Round 2 from the round-1 champions, each side against the other's champion (baselines Kenpachi 0.8334, Ichigo 0.2877). The topk policy
refined three branches a side (7 cells). One Ichigo cell (b2_a0) ran out of context reading the history whole and delivered nothing: recorded
as a resource failure (the briefs since ask for summaries first and proposals under ~150 lines).

| Side | b0 a0 / a1 | b1 a0 / a1 | b2 a0 | b3 a0 / a1 | Champion |
|---|---|---|---|---|---|
| Kenpachi | **0.921** / 0.786 | 0.876 / 0.921 | 0.870 | 0.887 / 0.889 | b0_a0: the meaty J1 on every knockdown, NS links only where they reach, the AS run to its end, the dodge on every reachable move, no Hoho-in (walks into reach); HARD 80/80 |
| Ichigo | 0.415 / 0.793 | 0.584 / **0.833** | fail | 0.715 / 0.787 | b1_a1: the patient sealed game (never first; the whiff confirm and the timed perfect Hoho), the whole Hoho kit (wake-up Hoho, his lunge's slide in its reach, the 64 f follow-up), pointer 2 waits against his Shikai / Bankai, a meaty J1 on his wake-up; HARD 80/80 |

**The evaluator's third freeze** (before round 3):
- The user, on a theme whose situation never came up (Kenpachi's b0_a1 lost antiwave to 0/0 because Ichigo never started a Getsuga, 0.935 →
  0.786): **「對手觸發的不列入平均」**. A theme the opponent opens (Kenpachi's antiwave, Ichigo's whiff) leaves the signature's mean when it has no
  situation in the whole run; the others still score 0 (the user's rule against dodging a theme).
- A bug fixed (reported by Kenpachi's b1_a0): a Soul Break's hit read as no hit, since the bar refills on the breaking step. A Konpaku lost
  now counts as a hit (his own Konpaku paid as a Bankai ends excepted). My first version of this made the KESSA ledger subtract the refill
  (Ichigo's kessa fell to 0.03); fixed the same hour: the ledger adds Reishi drops only, his Bankai segment cost excluded.
- The candidates re-measured at the third freeze: Kenpachi b0_a0 0.9213, b1_a1 0.9211, b0_a1 0.914 (antiwave excluded), b3_a1 0.889; Ichigo
  b1_a1 0.8339, b0_a1 0.7929, b3_a1 0.7873. Champions: Kenpachi b0_a0, Ichigo b1_a1.
- **The champions against each other: Ichigo 77/80 at HARD, 0.810; Kenpachi 0.287.** The lead has swung each round (v0: Ichigo; round 1:
  Kenpachi; round 2: Ichigo): each side's best is tuned against the other's previous best. Round 3 (the last) starts from these.

## 11. Round 3 and the final pair (2026-11-07)

Round 3 from the round-2 champions (baselines Kenpachi 0.2872, Ichigo 0.8104), 7 cells a side.

| Side | b0 a0 / a1 | b1 a0 / a1 | b2 a0 | b3 a0 / a1 | Final |
|---|---|---|---|---|---|
| Kenpachi | 0.789 / **0.881** | 0.828 / 0.824 | 0.712 | 0.861 / 0.861 | b0_a1 |
| Ichigo | 0.839 / **0.861** | 0.841 / 0.847 | 0.852 / 0.848 | 0.834 | b0_a1 |

- **Kenpachi's final (b0_a1)**: against her timed perfect Hoho he never starts a move she can see in time (sealed J1, S6; out of reach a Step
  in and J1 from its cancel; NS1a only while her Hoho is spent); the meaty from just outside her wake-up Hoho's 2.2 m; his own wake-up Hoho
  and J1 through her 40 locked frames after his perfect Hoho; a J1 timed to her Hoho's last frame; stale-SNAP waits (8 f after any
  cinematic, her 20 invulnerable frames after a Burst cuts his move), turning to face her before the follow-up. The climb, the Bankai cycle and
  the far-Getsuga answers from rounds 1–2 stay.
- **Ichigo's final (b0_a1)**: the bait hover at 2.3–2.7 m (inside his NS1a's start, outside his J1) into her timed perfect Hoho, the counter,
  the J string and AS3; when his Hoho is shut for 90+ frames, a dash out to ~6.5 m and a pointer-3 lunge he can't back-Step; the whole Hoho
  kit, KESSA kept at pointer 3, the Konpaku-aware finisher, the meaty on his wake-up.
- Reads beyond the SNAP accepted in this round, HUD facts like §9's: his flash-step gauge and Burst (Ichigo's "his Hoho is shut"). The 84-frame
  Hoho lockout Kenpachi reads is a game rule, read from the SNAP (her Hoho seen), not her gauge.
- A side note from round 3 (Ichigo b1_a1), not fixed: the perfect Hoho's automatic COUNTER is no classed move, so `situ.lisp` credits it with
  her last classed move's start distance; a counter after a 4 m lunge can count as a spacing ok. No cell exploited it.

**The final pair against each other** (40 seeds a seat, the evaluator; recorded, no target, DREAM_RSI §5.3):

| | HARD | Score | Signature themes | NORMAL |
|---|---|---|---|---|
| Kenpachi | 55/80 | 0.697 | brawl 0.66, shikai 0.65, bankai 0.80, antiwave excluded (0/0) | 0.9875 |
| Ichigo | 25/80 | 0.461 | spacing 0.18, whiff 0.66, ptr3 1.00, kessa 0.40 | 0.075 |

Pacing (`aieval`'s runner, 40 a seat): HARD KI 29–11, IK 14–26 (Kenpachi 55 of 80), every match a K.O., no time-out, medians 158.5 / 142.6 s;
NORMAL KI 36–4, IK 5–35, 79 of 80 K.O.s (one time-out), medians 198.9 / 194.9 s. Round 3's Kenpachi b2_a0 won mostly by sealed 300 s
time-outs against her round-2 champion; the final pair has none.

The lead swung every round (v0 Ichigo 70/80; round 1 Kenpachi 74/80; round 2 Ichigo 77/80; final Kenpachi 55/80): each side's best is tuned
against the other's previous best, so the final pair is closer than any round's champion against its own opponent.

**Shipped**: both files in `duel/lisp/`. Host 9843 ALL PASS, pkgcheck clean, `./build.sh duel` (the allowed warning), G2 II and KK identical,
**IK regenerated** (27 lines, P2 0-5, 270.1 s, browser = native; before 42 lines, P2 0-3, 419.4 s). The manual's CPU VS CPU row mentions the
matchup CPUs.

**The search in numbers**: 3 rounds, 44 cells dispatched (8 + 7 + 7 a side; the two v0 agents apart), 43 delivered (Ichigo r2 b2_a0 ran out of context); every rescore reproduced its
cell's own 40-seed line. Dreaming: the topk policy (refine the top ceil(1 + 3 β) branches) replaced the baseline policy after round 1 and kept
winning the compare (replay reward 0.29 / 0.30 on three worlds, the baseline policy −0.01); it saved one cell a side per round. The gains came
from the cells' diagnoses (located bugs, stale-SNAP timing, perfect-Hoho windows), as in DREAM_RSI §6, more than from the replay.
