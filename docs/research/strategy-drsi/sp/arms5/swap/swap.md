# Swap test: which table makes KH / IH stall (lead, 2026-11-15)

After the in-band run (`../inband.md` §5: KH K.O. .287, IH .550 with the arms5 finals, against B4's recorded KH 1.000 / IH .97), each
Hisagi table played against each opponent table, B4's shipped (`arms4/t0final/`) and arms5's final (`arms5/t0/`). Seeds 141-180, both
seats, 80 matches a cell, `SP_BUILD=f0e2bb129de1` (`run.sh`, records `swap.jsonl`). Points are Hisagi's (the game's result, a draw half).

| Hisagi table | Opponent table | Hisagi points | K.O. rate | Hisagi K.O. wins | time-outs |
|---|---|---|---|---|---|
| B4 | KH Kenpachi B4 | .037 | .525 | 0 | 38 |
| B4 | KH Kenpachi arms5 | .013 | .900 | 0 | 8 |
| arms5 | KH Kenpachi B4 | .013 | .263 | 0 | 59 |
| arms5 | KH Kenpachi arms5 | .025 | .287 | 1 | 57 |
| B4 | IH Ichigo B4 | .487 | .975 | 37 | 2 |
| B4 | IH Ichigo arms5 | .163 | .938 | 9 | 5 |
| arms5 | IH Ichigo B4 | .975 | .875 | 68 | 10 |
| arms5 | IH Ichigo arms5 | .825 | .550 | 39 | 36 |

- **The stall follows Hisagi's arms5 table** (his own Shikai band play, 3.4-5.2 m): with it KH stalls against either Kenpachi table
  (.263 / .287); with B4's it does not against arms5's Kenpachi (.900).
- **B4's KH 1.000 does not hold on today's build**: B4 vs B4 gives .525 (the clash fix and the strategy batches changed the action layer
  under the table; B4's figure was on seeds 501-540 of an older build).
- **KH: Hisagi loses with every table** (.013-.037): Kenpachi leads on the clash and, against arms5 Hisagi, neither side closes, so the
  match goes to the bell with Kenpachi ahead.
- **IH: arms5 Hisagi is much stronger** (.975 / .825 against .487 / .163) and arms5 Ichigo is stronger than B4's. With both arms5 tables
  Hisagi leads and holds the band to the bell (36 of 80 time-outs, Hisagi ahead): "kites to the bell".
- IH with both B4 tables passes bar D (.975) at even points (.487).
