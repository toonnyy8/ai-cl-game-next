# Stage 0: the populations re-scored under the exchange rules (PLAN3 §3, 2026-11-15)

PLAN3 §3 stage 0 and checkpoint 1. This is sim only: no cells, no source edits.

## Build and method

- Main is at `c9e74926` (X1 merged). `build/simgate/duel.fas` was current, so `simlib.build()` did not rebuild it.
  - `ss.build_hash()` (`duel.fas` + `strat-run.lisp`) = **`949a94db54fe5779`**.
  - **`SP_BUILD=949a94db54fe`** was exported for every call. Every rewritten `pop/*.json` (its `screen.build`) and every `*-matrix.json`
    (its `build`) carries `949a94db54fe5779`.
  - `pop.py` has no `SP_BUILD` guard; `eval.py` does. The `build` fields are the only check on the pop.py runs.
- **Screens.** `pop.py screen --force --seed0 200 --seeds 100`: block 200, both seats, each arm against the opponent's `none`.
  - The 2026-11-14 screens used 301-340.
  - On block 200, every screen row is also the matrix's `none` column, so those cells came from the cache.
- **Matrices.** `pop.py matrix --seed0 200 --seeds 100`: both seats, 200 matches a cell, K.O.-only regret matching. The orientation is
  as before (KI: K rows; KH: K rows; IH: I rows). The gaps are at most 0.0004.
- **Groups.** `eval.py --seed0 200` scored each side's incumbent against the other side's new population file: the groups anchor, mix
  and rest, 200 matches each.
- **Members per side.** Every member of the 2026-11-14 population files (the files in the tree equalled `eb35b393`), plus each shipped
  final table's arm 0, plus `none`.
  - Only one arm 0 was not already a member: IH Hisagi's `c-ih-h-r1-b2a0`. It was added to ih-H.
  - Each `.arms` line 1 was checked equal to its `arms/` file (after `strip_lisp`).
- **Counts** are row K.O. wins : column K.O. wins : time-outs, of 200. A draw is a time-out.

## The screen's drops, kept by the brief

`pop.py screen` admits an arm only when its K.O. rate is at least 0.5 **and** its score is at least `none`'s score + 0.05.
- It dropped 11 old members, among them **two shipped arm 0s** (KH Kenpachi `r2-b0a2`, IH Hisagi `b2a0`).
- The stage 0 brief, and PLAN3 §3's "no member is ever deleted", keep them. They were appended to `members` by hand, each with a `why`
  that carries its screen numbers. `screen.rows` holds every row as pop.py wrote it.

| Side | Member | vs his `none` | Score | Floor (`none` + 0.05) | Why it failed |
|---|---|---|---|---|---|
| KI K | `a-ken-press` | 14:168:18 | 0.074 | 0.114 | score |
| KI K | `a-ken-kh-standoff` | 12:186:2 | 0.064 | 0.114 | score |
| KH K | `a-ichigo-ki` | 87:47:66 | 0.436 | 0.530 | score (its K.O. rate, 0.67, passes) |
| KH K | `s1-brawler` | 46:148:6 | 0.233 | 0.530 | score |
| KH K | **`c-ki-k-r2-b0a2`** (shipped arm 0) | 106:94:0 | 0.5297 | 0.5302 | misses by 0.0005 (`none` 96:100:4 = 0.4802; paired z +1.00) |
| IH H | `a-hisagi-kite` | 180:2:18 | 0.896 | 1.001 | floor unreachable |
| IH H | `h1-range` | 196:3:1 | 0.975 | 1.001 | floor unreachable |
| IH H | `a-zoner` | 173:0:27 | 0.861 | 1.001 | floor unreachable |
| IH H | `s7-kite` | 189:0:11 | 0.941 | 1.001 | floor unreachable |
| IH H | `c-ih-h-r1-b0a2` | 191:2:7 | 0.951 | 1.001 | floor unreachable |
| IH H | **`c-ih-h-r1-b2a0`** (shipped arm 0) | 197:3:0 | 0.980 | 1.001 | floor unreachable |

- **The screen rule is blind when the anchor is near the ceiling.** Hisagi's `none` beats Ichigo's `none` 191:8:1 (score 0.951). The
  floor is then 1.001, which no arm can reach. Followed literally, the rule would have left ih-H with only `none` and `a-generic`, which
  are the same strategy. This is a tool problem: pop.py was not changed.
- **The screen reproduced PLAN3's probe A exactly.** Probe A ran on the uncommitted build `6cd131d205f3`.

  | Row | Probe A | Stage 0 |
  |---|---|---|
  | KI `none` vs `none` | 12:83:105 | 12:83:105 |
  | KI `r2-b1a2` vs his `none` | 93:102:5 | 93:102:5 |
  | KH `r2-b0a2` vs his `none` | 106:94:0 | 106:94:0 |
  | IH `b0a1` vs her `none` | 187:13:0 | 187:13:0 |

  So, at HARD, the pending batch's commit and X1 (with no key set) left these four rows bit-identical (200 matches each). The full
  claim rests on X1's own proofs (§11.23).

## Mixes and incumbents

Value = the side's K.O. win share at the equilibrium. "Old" is the 2026-11-14 matrix (`eb35b393`: builds f5048d03 / f0e24140 / 95b02590).

| Pair | Side | Mix (now) | Value now | Old mix | Old value |
|---|---|---|---|---|---|
| KI | Kenpachi | `r2-b1a2` 1.0 | **0.115** | `r2-b1a2` 1.0 | 0.280 |
| KI | Ichigo | `r2-b2a2` 1.0 | 0.885 | `r2-b2a2` 1.0 | 0.720 |
| KH | Kenpachi | `r2-b1a2` 0.723, `r2-b0a2` 0.277 | **0.059** | `r2-b0a2` 0.999 | 0.975 |
| KH | Hisagi | `a-hk-pot` 0.987, `s7-kite` 0.011, `a-ken-ki` 0.001 | 0.272 | `a-hk-pot` 0.999 | 0.010 |
| IH | Ichigo | `r2-b2a2` 0.548, `ih-r1-b0a1` 0.452 | 0.620 | `ih-r1-b0a1` 0.808, `ih-r1-b1a1` 0.192 | 0.941 |
| IH | Hisagi | `ih-r1-b0a2` 0.961, `a-hisagi-kite` 0.039 | **0.289** | `a-hisagi-kite` 0.839, `ih-r1-b0a2` 0.161 | 0.032 |

- No equilibrium puts weight on `none` or `a-generic`, so there is no split mass to sum. In KH and IH those two are the same strategy:
  their rows and columns are identical, bit for bit.
- Equilibrium time-outs (1 − both values): KI 0 %, **KH 67 %**, IH 9 %. Time-outs over all matrix cells: KI 317 of 7000 (4.5 %), KH
  18318 of 39200 (47 %), IH 3669 of 24000 (15 %).

**Incumbents (the top of each mix), against the other side's new population.** `eval.py`, block 200. Each group is 200 matches:
K.O. wins : K.O. losses : time-outs.

| Side | Incumbent | Score | anchor (his `none`) | mix | rest | K.O. rate (600) | Time-outs |
|---|---|---|---|---|---|---|---|
| KI Kenpachi | `c-ki-k-r2-b1a2` | 0.340 | 93:102:5 | 23:177:0 | 87:111:2 | 98.8 % | 7 |
| KI Ichigo | `c-ki-i-r2-b2a2` | **0.947** | 200:0:0 | 177:23:0 | 194:6:0 | 100 % | 0 |
| KH Kenpachi | `c-ki-k-r2-b1a2` | 0.444 | 196:4:0 | 10:35:155 | 60:16:124 | 53.5 % | 279 |
| KH Kenpachi (2nd, shipped) | `c-ki-k-r2-b0a2` | 0.274 | 106:94:0 | 11:105:84 | 46:102:52 | 77.3 % | 136 |
| KH Hisagi | `a-hk-pot` | 0.490 | 178:3:19 | 51:8:141 | 65:3:132 | 51.3 % | 292 |
| IH Ichigo | `c-ki-i-r2-b2a2` | 0.693 | 149:47:4 | 125:61:14 | 143:45:12 | 95.0 % | 30 |
| IH Ichigo (2nd, shipped) | `c-ih-i-r1-b0a1` | 0.767 | 187:13:0 | 122:50:28 | 153:39:8 | 94.0 % | 36 |
| IH Hisagi | `c-ih-h-r1-b0a2` | 0.536 | 191:2:7 | 63:117:20 | 68:98:34 | 89.8 % | 61 |

- In IH the matrix and the score disagree on Ichigo. The mix tops `r2-b2a2`; the full score prefers `b0a1` (0.767 against 0.693),
  mostly through the anchor group: 187 K.O. wins against her `none`, where `r2-b2a2` gets 149. In rest it is 153 against 143, and in
  mix 122 against 125.
**The shipped arm 0s** (today's tables; `ship.py --arm0` will compare against them):

| Side | Shipped arm 0 | Mix weight now | Note |
|---|---|---|---|
| KI K | `r2-b1a2` | 1.0 | the incumbent |
| KI I | `r2-b2a2` | 1.0 | the incumbent (its table adds the `awake` band) |
| KH K | `r2-b0a2` | 0.277 | behind `r2-b1a2` |
| KH H | `a-hisagi-pressd` | **0** | against Kenpachi's incumbent `r2-b1a2` it scores 10:23 (Hisagi's K.O.s first); `a-hk-pot` scores 35:10 |
| IH I | `ih-r1-b0a1` | 0.452 | second in the mix, first by the full score |
| IH H | `ih-r1-b2a0` | **0** | Ichigo's strategy members take 122-160 K.O.s of 200 off it |

Two of the six shipped arm 0s are outside the support: KH Hisagi and IH Hisagi.

- No incumbent reaches 0.95. Under §11.13's allocation, every side gets cells; KI Ichigo misses the bar by 0.003.

## Where the headroom is

- **KI: Kenpachi trails by 77 points (11.5 % against 88.5 %).** It is still a pure equilibrium (`r2-b1a2` vs `r2-b2a2`, 23:177:0), and
  his share there fell from 28 %.
  - Kenpachi's best row against every Ichigo member is `r2-b1a2`.
  - No Kenpachi arm takes more than 1 % off `r2-b2a2`, except `r2-b1a2` (11.5 %).
  - No time-outs at the equilibrium: a clean pilot signal, as PLAN3 expected.
- **KH: flipped, and stalled. Hisagi leads 27 to 6, and 67 % of equilibrium matches go to the bell.**
  - Kenpachi's KH arms (`a-ken-ki`, `a-ken-press`, `a-ken-kh`, `a-ken-zoner`) against Hisagi's ten style-CPU arms (`a-hisagi-*`,
    `a-hk-*`, `a-ken-ki`): at most 27 K.O.s a side of 200, and most cells are 0:0:200. Neither side commits. Against `h1-range` and
    `s7-kite`, the same arms end every match.
  - The KI-tuned arms and `a-ken-kh-standoff` end some of those matches: `r2-b0a2` about half, `r2-b1a2` about 20 %. Most arms lose
    most of the matches they end. `r2-b1a2` is the exception: it is ahead in 7 of the 10 cells, and behind against `a-hk-pot` (10:35),
    `a-hk-all` (17:20) and `a-ken-ki` (1:35).
  - Kenpachi's mix moved off the shipped `r2-b0a2` (0.277) onto KI's `r2-b1a2` (0.723). `r2-b1a2` beats Hisagi's `none` 196:4; the
    shipped `r2-b0a2` only 106:94, no better than `none`'s own 96:100.
  - Both sides have headroom. Kenpachi's is the larger (6 % K.O. share), and the stall is PLAN3's flagged risk: an admission must not
    add time-outs.
- **IH: Ichigo leads 62 to 29.** The old order (94 to 3) is gone.
  - Both mixes are interior: Ichigo 55 / 45 over two arms, Hisagi 96 / 4. The support changed on both sides.
  - Hisagi's `ih-r1-b0a2` now takes 49-108 K.O.s of 200 off every Ichigo member except the plain ones. Before, it lost 0:200 to `b0a1`.
  - The trailing side is Hisagi (29 %), but Ichigo is far from the ceiling too.

- **The shipped tables are stale on both Hisagi sides.** Their arm 0s have no weight in the new mixes (above).

## Compared with 2026-11-14, and surprises

- **Plain Hisagi got much stronger.**
  - IH `none` vs `none`: Hisagi 191:8:1.
  - KH `none` vs `none`: 96:100:4. The baseline was 172:28 for Kenpachi (§11.2).
  - So the screen's floor rose, and the shipped KH Kenpachi arm no longer beats plain Hisagi by more than `none` does.
- **Reversals in IH.** KI's `r2-b2a2` against Hisagi's `b0a2` went from 44:141:15 to 123:65:12, and it is now IH Ichigo's top member.
  The old IH incumbent `b0a1` against `b0a2` went from 200:0:0 to 126:49:25.
- **KH, cell by cell.** Against Hisagi's ten style-CPU arms, the shipped `r2-b0a2` went from 183-197 K.O. wins and 0-2 losses to
  7-52 wins and 79-105 losses, with 56-94 time-outs a cell. Against `h1-range` it fell from 200:0 to 161:39.
- **KI** widened: `r2-b1a2` against `r2-b2a2` went from 56:144 to 23:177. `r2-b1a2` against Ichigo's `none` fell from 195:5 to 93:102.
- **KI's plain CPUs stall:** `none` vs `none` 12:83:105 (probe A's number). `r2-b2a2` ends every match against every Kenpachi member.

## Tool notes

- **`pop.py screen` rewrites the whole file.** It drops each member's provenance (`why`, `status`) and the `initial` key of the KH / IH
  files.
  - The old `why` / `status` were copied back by member id.
  - `initial` was not restored. It holds the 2026-11-14 block-300 scores, which probe A made void, and it is still at `eb35b393`.
- **The screen's floor (`none` + margin) is unreachable when `none` is near the ceiling** (ih-H, above). Kept members were added by
  hand. The next screen of a near-ceiling anchor needs a different rule, such as a paired z against `none`, or no screen.
- **`a-generic` equals `none` in KH and IH** (identical rows and columns). Each matrix there carries one redundant row and column.

## Cost

| Step | Wall | CPU (user) |
|---|---|---|
| 6 screens, concurrent (`-j 4` each) | 2.8 min | 46.5 min |
| 3 matrices, concurrent (`-j 8` each; KH the long pole, 17.5 min) | 17.5 min | 4.13 h |
| 8 `eval.py` group scores (`-j 4`/`-j 6`) | about 2 min | about 20 min (estimate, 4800 matches) |
| **Total** | **about 23 min** | **about 5.2 CPU-h** |

- PLAN3's guess was 3 CPU-h. KH's 196 cells, with 47 % going to the bell, account for 2.3 CPU-h on their own.
- Throughput is about 0.22 CPU-s a match (KH 36400 new matches in 8127 s).
- `pop.py` / `eval.py` cap their threads at 8 (`play()`: `min(8, j)`), whatever `-j` asks for. Three concurrent matrices are needed to
  fill 24 cores.

## The matrices

Rows are the first side named; cells are row K.O. wins : column K.O. wins : time-outs, of 200 (seeds 201-300, both seats). Prefixes
are dropped, along with a leading `a-`.
- `k-` means `c-ki-k-`, and `h-` means `c-ih-h-`.
- `i-` means `c-ki-i-`, except `i-r1-b0a1` and `i-r1-b1a1`, which are the IH round's `c-ih-i-`.
- `gen` is `a-generic`.
 Raw data:
`pop/<pair>-matrix.json`.

### KI (Kenpachi rows, Ichigo columns)

| row \ col | none | gen | ichigo-press | i-r1-b3a2 | i-r2-b2a2 |
|---|---|---|---|---|---|
| none | 12:83:105 | 162:38:0 | 2:108:90 | 0:169:31 | 0:200:0 |
| gen | 0:199:1 | 184:14:2 | 0:200:0 | 1:195:4 | 0:200:0 |
| k-pilot-b0a0 | 23:177:0 | 147:53:0 | 14:186:0 | 1:197:2 | 1:199:0 |
| k-r1-b2a2 | 30:160:10 | 145:53:2 | 24:168:8 | 9:174:17 | 0:200:0 |
| k-r2-b1a2 | 93:102:5 | 189:11:0 | 74:120:6 | 58:137:5 | 23:177:0 |
| ken-press | 14:168:18 | 146:54:0 | 7:187:6 | 0:198:2 | 0:200:0 |
| ken-kh-standoff | 12:186:2 | 157:43:0 | 6:193:1 | 0:200:0 | 0:200:0 |

### KH (Kenpachi rows, Hisagi columns)

| row \ col | none | gen | hisagi-merged | hisagi-dswitch | hisagi-press | hisagi-pressd | hisagi-kite | hk-wake | hk-pot | hk-kite | hk-all | h1-range | ken-ki | s7-kite |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| none | 96:100:4 | 96:100:4 | 4:192:4 | 8:191:1 | 6:190:4 | 1:197:2 | 5:175:20 | 2:193:5 | 3:178:19 | 6:144:50 | 1:130:69 | 65:133:2 | 6:184:10 | 24:167:9 |
| gen | 96:100:4 | 96:100:4 | 4:192:4 | 8:191:1 | 6:190:4 | 1:197:2 | 5:175:20 | 2:193:5 | 3:178:19 | 6:144:50 | 1:130:69 | 65:133:2 | 6:184:10 | 24:167:9 |
| ken-ki | 127:73:0 | 127:73:0 | 1:0:199 | 0:0:200 | 0:0:200 | 0:0:200 | 2:0:198 | 1:0:199 | 0:0:200 | 2:4:194 | 1:3:196 | 138:62:0 | 0:0:200 | 93:107:0 |
| ken-press | 148:52:0 | 148:52:0 | 0:0:200 | 0:0:200 | 0:0:200 | 0:0:200 | 1:1:198 | 0:0:200 | 0:1:199 | 3:0:197 | 0:0:200 | 154:46:0 | 0:0:200 | 105:95:0 |
| ken-zoner | 163:37:0 | 163:37:0 | 8:6:186 | 6:7:187 | 2:1:197 | 2:1:197 | 6:8:186 | 9:6:185 | 2:5:193 | 11:27:162 | 2:23:175 | 158:42:0 | 0:0:200 | 125:75:0 |
| ken-kh | 149:51:0 | 149:51:0 | 0:0:200 | 0:0:200 | 0:0:200 | 0:0:200 | 0:0:200 | 0:0:200 | 0:1:199 | 0:0:200 | 0:0:200 | 142:58:0 | 0:0:200 | 94:106:0 |
| ken-kh-standoff | 137:63:0 | 137:63:0 | 5:42:153 | 4:39:157 | 5:26:169 | 5:25:170 | 12:43:145 | 5:41:154 | 2:55:143 | 24:46:130 | 4:65:131 | 142:58:0 | 2:39:159 | 96:104:0 |
| k-pilot-b0a0 | 137:63:0 | 137:63:0 | 18:46:136 | 13:46:141 | 18:47:135 | 11:42:147 | 21:55:124 | 18:46:136 | 6:93:101 | 18:60:122 | 18:76:106 | 162:38:0 | 8:47:145 | 118:82:0 |
| k-r1-b0a1 | 150:50:0 | 150:50:0 | 13:62:125 | 14:52:134 | 14:50:136 | 12:53:135 | 22:79:99 | 13:62:125 | 8:102:90 | 28:56:116 | 20:103:77 | 158:42:0 | 9:61:130 | 129:71:0 |
| k-r1-b2a2 | 139:61:0 | 139:61:0 | 5:43:152 | 5:48:147 | 8:44:148 | 4:44:152 | 7:41:152 | 5:43:152 | 0:85:115 | 9:44:147 | 3:65:132 | 170:29:1 | 2:59:139 | 104:96:0 |
| k-r2-b1a2 | 196:4:0 | 196:4:0 | 20:15:165 | 17:16:167 | 29:13:158 | 23:10:167 | 42:16:142 | 20:15:165 | 10:35:155 | 38:16:146 | 17:20:163 | 194:6:0 | 1:35:164 | 172:28:0 |
| ichigo-ki | 87:47:66 | 87:47:66 | 0:38:162 | 4:41:155 | 1:26:173 | 0:17:183 | 2:77:121 | 2:44:154 | 0:23:177 | 14:9:177 | 0:4:196 | 70:98:32 | 0:39:161 | 21:65:114 |
| s1-brawler | 46:148:6 | 46:148:6 | 22:146:32 | 24:157:19 | 12:167:21 | 12:176:12 | 39:130:31 | 16:162:22 | 7:152:41 | 20:143:37 | 5:141:54 | 41:155:4 | 30:152:18 | 15:178:7 |
| k-r2-b0a2 | 106:94:0 | 106:94:0 | 33:79:88 | 14:92:94 | 7:99:94 | 10:101:89 | 52:92:56 | 33:79:88 | 11:105:84 | 45:89:66 | 29:91:80 | 161:39:0 | 19:104:77 | 77:121:2 |

### IH (Ichigo rows, Hisagi columns)

| row \ col | none | gen | hisagi-kite | h1-range | zoner | s7-kite | h-r1-b0a2 | h-r1-b2a0 |
|---|---|---|---|---|---|---|---|---|
| none | 8:191:1 | 8:191:1 | 2:180:18 | 3:196:1 | 0:173:27 | 0:189:11 | 2:191:7 | 3:197:0 |
| gen | 8:191:1 | 8:191:1 | 2:180:18 | 3:196:1 | 0:173:27 | 0:189:11 | 2:191:7 | 3:197:0 |
| ichigo-ki | 181:11:8 | 181:11:8 | 67:63:70 | 139:52:9 | 125:7:68 | 89:22:89 | 85:64:51 | 151:38:11 |
| ichigo-press | 181:7:12 | 181:7:12 | 63:61:76 | 149:43:8 | 131:13:56 | 89:26:85 | 95:65:40 | 148:42:10 |
| ichigo-kite | 166:8:26 | 166:8:26 | 22:8:170 | 134:50:16 | 47:3:150 | 14:1:185 | 66:62:72 | 135:38:27 |
| ichigo-zoner | 180:8:12 | 180:8:12 | 27:15:158 | 150:43:7 | 74:2:124 | 17:4:179 | 80:68:52 | 141:39:20 |
| i-r1-b0a2 | 191:7:2 | 191:7:2 | 92:57:51 | 139:58:3 | 150:9:41 | 113:17:70 | 73:108:19 | 155:41:4 |
| i-r1-b2a2 | 184:11:5 | 184:11:5 | 74:70:56 | 143:41:16 | 136:15:49 | 98:19:83 | 62:80:58 | 142:40:18 |
| i-r1-b3a2 | 127:56:17 | 127:56:17 | 77:50:73 | 138:57:5 | 78:51:71 | 39:67:94 | 80:100:20 | 147:49:4 |
| i-r2-b1a2 | 49:116:35 | 49:116:35 | 55:51:94 | 85:103:12 | 16:111:73 | 7:123:70 | 86:97:17 | 122:71:7 |
| i-r2-b2a2 | 149:47:4 | 149:47:4 | 149:25:26 | 153:44:3 | 140:40:20 | 102:68:30 | 123:65:12 | 160:35:5 |
| i-r2-b3a2 | 112:64:24 | 112:64:24 | 52:68:80 | 141:51:8 | 64:86:50 | 38:100:62 | 118:65:17 | 147:50:3 |
| ki-ichigo | 141:55:4 | 141:55:4 | 166:21:13 | 141:56:3 | 143:47:10 | 94:87:19 | 88:96:16 | 143:54:3 |
| i-r1-b0a1 | 187:13:0 | 187:13:0 | 79:97:24 | 160:34:6 | 180:19:1 | 150:42:8 | 126:49:25 | 156:40:4 |
| i-r1-b1a1 | 190:10:0 | 190:10:0 | 148:36:16 | 156:42:2 | 179:18:3 | 181:18:1 | 97:79:24 | 158:38:4 |
