# b0_a0: Ichigo's KI style CPU as a counter to Hisagi's s3-zoner

Siblings/history: none written yet (round 1, parallel); baseline = shipped CPU, 0.105 on search seeds.

Mechanism. Hisagi HARD plays s3-zoner by the lookup (spacing, NS spam, backs off inside J1 reach). Slice: everything
(:own = lead even / behind / ahead). Strategy: `:fn ichigo-ki-style` (existing code, seeds/s6), no data keys.

Dev evidence (seeds 800+, 50 per seat, same-seed paired):
- ki-ichigo, all leads: composite 100/100, incumbent 11/100, b=89 c=0 (below).
- data-only counters all failed or tied: s1-brawler everywhere 0/100 (c=11); brawler sliced by lead / Reishi / distance:
  ahead 2, behind 11, mr low 10, mr high 10, far 4, near 12 (noise or worse); s2-punisher everywhere 0/100.
- The sitcheck (analysis.txt) showed s0 best per bin for Ichigo, but that was before Hisagi switched to s3; the style
  CPU, not a bias strategy, is what breaks the zoner.

Why not a repeat: first cell. Risk: 100/100 is suspiciously perfect: ichigo-ki-style (written for Kenpachi) may exploit a
quirk of the s3 zoner (or a sim bug); the coordinator should check held-out seeds and a replay before trusting it.
Narrowing :own would only lower the share.
