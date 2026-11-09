# b2_a2 (round 1): dodge and punish Kenpachi's move starts -- NEUTRAL / NEGATIVE, not keep-worthy

Job (one line): answer each Kenpachi move start inside reach with the evasion (Hoho, else back Step) instead of the J1 / NS1a race, then
hit the whiff (parent b2_a1's recovery punish).

Mechanism: parent b2_a1 (wake-up punish + neutral whiff punish) plus one knob, `*hkd-brawl-p*` (0 / 0 / 0), bound over the KI code's
`*kk-brawl-p*` (0 / 0.1 / 0.6) around `hisagi-merged-style`. In the Shikai Hisagi plays Kenpachi's KI code, whose `kk-read` races an opponent's
move start with J1 / NS1a on that chance and otherwise dodges (`*kk-dodge-p*` Hoho, `*kk-step-p*` back Step, HARD 1.0 / 0.9); with the race off
every Kenpachi move start in reach is dodged and the whiff falls to `hkw-any-step`. State in `hks` (includes `hms`); no globals, no cai-defstyle.

History read: b0_a0 / b0_a1 (replacing the first free frame or walking back loses everywhere), b1_a0 / b1_a1 (kite: gain in stand-in / arms,
live flat), b2_a0 / b2_a1 (whiff punish: live 0.04 -> 0.15-0.19), b3_a0 / b3_a1 (resource timing: noise). The hint (punish the KI code's J1,
Step-in, stand-off attack) is the same punish seam as b2; this tried to create more whiffs to punish. Not a KI-code duplicate (he races; the KI
code at HARD races 60% of the time), but it is a one-knob variant of its parent.

Measurement (dev seed0 300):
| variant | scale | score | live / past / arms / standin |
|---|---|---|---|
| parent b2_a1 (reported) | 0.5 | 0.2747 | .235 / .178 / .416 / .269 |
| parent b2_a1 (reported) | 1 | 0.2408 | .158 / .154 / .435 / .216 |
| this (race off) | 0.5 | 0.2682 | .216 / .134 / .435 / .289 |
| this (race off), final | 1 | 0.2362 | .173 / .137 / .448 / .186 |
Host tests ALL PASS. Within the +-0.02 noise of the parent: the dodge-instead-of-race switch moves nothing measurable (stand-in 0.289 at
0.5 but 0.186 at 1).

Findings: the KI code's own HARD race chance is not what loses to Kenpachi; the dodge's timing (Hoho lead 9, Step lead 7 against an 8-frame
perception delay) makes it no better than the race. Not kept: live 0.17 << 0.2985, total 0.236 << 0.3153. Untried: the Step-in itself (a :step
state has no recovery in SNAP-RECOVERING-P), a dodge lead tuned per Kenpachi move (his J1 startup), the kite + punish combination (a bundle,
so not admissible as one job).
