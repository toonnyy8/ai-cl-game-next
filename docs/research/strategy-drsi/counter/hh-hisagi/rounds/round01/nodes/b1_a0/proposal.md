# b1_a0: ken-ki-style only while behind on Konpaku or the opponent is red (hisagi mirror, HARD)
Slice: `(:lead :behind)` OR `(:ored :yes)` (own_share 0.34, cap 0.6). Strategy: `:fn ken-ki-style`, no data keys.
History: sibling b0_a0 (ken-ki-style whenever not ahead: behind + even + red, own 0.42, dev 0.985, score 0.97) is the same style on a
wider slice; baseline = shipped CPU, 0.5. This cell narrows the slice to the catch-up / finish situations only (drops `:lead :even`),
so it is a leaner, lower-own variant of the same mechanism, not a new style. Honest note: it is NOT structurally independent of b0.
Other variants tried (dev seed0 800, 100 seeds): ichigo-ki-style on not-ahead 0.855 (own 0.35); ken-ki on :mr low/:ored 0.825;
on :dn out/afar 0.68; on :ost free x behind/even 0.61 (own 0.10); awk/behind or low/behind/red 0.905-0.985 but own 0.42-0.71
(0.71 and 0.64 capped); + `:dswitch 1.0` 0.90 (no gain, second block 0.92 vs 0.89, within noise).
Dev: seed0 800 x100: 0.94 (z 8.98, own 0.344). Second block seed0 900 x50: 0.89 (z 5.7, own 0.35).
Why it works: the mirror incumbent is the weak generic CPU + MCTS; the KI style CPU is a far stronger general tactic. Benefit: large
(+0.4); risk: it is close to a whole-game replacement by a different CPU, trading tactics for the incumbent only while ahead and even.
