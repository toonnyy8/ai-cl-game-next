# Where the damage and the Konpaku come from (2026-11-18)

The user asked why the arms differ so little (「為什麼不同打法帶來的優勢如此不顯著？」), then 「好」 to measuring whether the outcome is
decided in the exchange after a cancel or in neutral. Tool: `dmgsrc.py` (strat-run.lisp `STRAT_CLOG=1`: the combat log on, play unchanged).
Data: `hard-601-620.txt` (HARD vs HARD, the shipped lookup tables, seeds 601-620, 6 pairings x 20 matches).

Method: a combo = one side's hits with no gap above 90 ticks and no hit back; its opener is `xch` when an exchange is open (a cancel, no
`exchange over` since: DUEL_SP §6), else `neu`. Reishi = the `dealt` lines; Konpaku = the `SOUL BREAK on` / `KIKON on` lines.

| pair | Reishi from xch combos | Konpaku via Kikon | Konpaku from xch combos | Konpaku events a match |
|---|---|---|---|---|
| KK | 95.2 % | 11.1 % | 96.2 % | 5.6 |
| KI | 88.4 % | 30.1 % | 88.0 % | 4.7 |
| KH | 68.4 % | 26.3 % | 70.0 % | 4.7 |
| II | 44.8 % | 42.5 % | 44.9 % | 4.5 |
| IH | 52.3 % | 59.3 % | 44.0 % | 4.3 |
| HH | 75.6 % | 100 % | 70.8 % | 6.8 |
| all | 71.2 % | 45.3 % | 69.9 % | 5.1 |

Reading:
- 70 % of the Reishi and of the Konpaku come from combos opened inside an exchange; with Kenpachi 88-96 %. The arms change mostly neutral
  (approach, spacing, when to start an NS) while the exchange unit (`:with`) is shared by every arm of a table: the layer that decides the
  match is the one the arms don't change.
- A match is decided by ~5 Konpaku events (Soul Breaks and Kikons): a small number of large, discrete swings, so a strategy's edge in
  neutral is diluted and the match result is noisy.
- Caveat: an exchange lasts until both fighters are back in neutral, so a fight that never returns to neutral (KK) counts as one long
  exchange; "xch" means "opened while the fight had not reset since a cancel", which includes the break hit and the scramble after it.
