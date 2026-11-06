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
  at -j 8. Cells and the coordinator's rescore use the same fixed seeds 1–40.

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
matches and no Kikon.
