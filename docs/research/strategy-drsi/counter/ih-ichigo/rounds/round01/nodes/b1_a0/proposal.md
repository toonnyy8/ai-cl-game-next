# b1_a0: close the distance (rush) when Hisagi is out of my J1 reach

History: none (round 1); baseline incumbent 0.105 on the search seeds. sitcheck: s0 (the incumbent) beat s1/s3 in every bin, and Hisagi
plays s3-zoner at HARD (spacing, waves), so I tried the counter to a zoner: never give him space.

Slice (`:own`): my distance over my J1 reach is :afar OR :out OR :reach (anything but :in), ~75% of judgements.
Strategy: s1-brawler pushed harder: `:range 0.5` (walk-to range scaled down), `:ns 0.1`, `:cont 1.4`, `:awaken 2.0`,
`:b-walk-in 0.2 :b-step-in 0.15 :b-wait -0.15 :b-walk-out -0.15 :b-step-out -0.08`, a small Hoho bias on his startup.
Inside J1 reach the incumbent plays (it wins the close fights).

Dev runs (seeds 800, 50 seeds x 2 seats; incumbent 0.11):
- punisher (s2-like) claimed when behind: 0.03 (a passive style hurts)
- mild rush, own afar+out: 0.34; afar only 0.26; afar+out+reach 0.41; claiming everything 0.33
- strong rush, afar+out+reach (this cand): 0.64 (z 7.0); stronger still 0.66 (plateau); strong + :in 0.59
Not a repeat: round 1, first cell. Risk: rush bias may be seed-sensitive; plateau suggests robustness. The :dj :in carve-out matters (0.64 vs 0.59).
