# b3_a0 (round 3): b0_a2 + the Shikai kite (a third rule)

Job (honest): THREE separable rules in the file: (1) hkw-step wake-up punish / guard, (2) hkb-step the Reishi pot (both unchanged from round 2's
b0_a2), (3) NEW hkk-step, the kite: Kenpachi perceived closing inside 3.3 m (4.2 m in the Bankai) while Hisagi is free (idle / run): one roll per
approach event (*hkk-p* EASY .25 / NORMAL .6 / HARD 1.0), a back Step (free, no flash-step cost), then within 50 frames the pointer's NS from
the new 2.9-6.0 m. Rule 3 is round 1's b1_a1 ported verbatim (knobs *hkk-*), so it can be split into its own one-job arm. Everything else:
hisagi-merged-style.

Resource hint tried first: where b0_a2 loses to the stand-in (ki-ken, 100 seeds a seat, seed0 700): 65 wins of 200, 64 of them at the 300 s bell
(9-9 Konpaku, Reishi % decides), 103 losses are real K.O.s (mean ~120 s) plus 29 clock losses on Konpaku. Only ~5 of 200 are 9-9 bell matches lost
on Reishi, so a resource lever (pot, awaken timing) has ~2 % to give; the loss is combat (Kenpachi's KI code walks in and strings J1..J6).
Replacing the merged style by a bare generic CPU scored 0/200 (the shipped CPU's strength comes from the strategy data its Q table sets), so the
merged style stays. The lever is round 1's kite (b1_a0 / b1_a1: stand-in .41, the KI-code arms k1 / k2 / k10 ~.4 when the rest was .23), which
could not be kept alone because live stayed flat; b0_a2 now supplies live.

Not a repeat: first time the kite is stacked on the wake-up + pot pair. Not a KI-code duplicate (Kenpachi's KI code never retreats).

Measurement (dev seed0 300, scale 1, 1,220 matches), b0_a2 (round 2 dev) -> this:
score 0.4496 -> 0.4977; live .510 -> .411, past .371 -> .440, arms .565 -> .649, standin .353 -> .490; inc_live .125 (tripwire unmoved).
members: ki-ken .49, k1-ken .55, k2-press .375, k10-kends .525, kh-t0 .41, cand-khfn .425, cand-standoff .275.
Direct checks (seed0 700): ki-ken, 100 seeds a seat, b0_a2 .325 -> .50. Live KH, 200 seeds a seat, same seeds, kite on / off: .445 / .41, so the
dev live drop (.51 -> .41) is draw noise, the kite does not cost the live KH. Host tests ALL PASS. The evaluator is deterministic (a re-run
gave the same JSON).

Risks: three rules in one file (the keep rule needs a split into wake-up, pot and kite arms); the rescore of b0_a2 live was .36, so live sits
near .4 with +-.035 noise; kite knobs (3.3 / 4.2 m, 50 f window) untuned here (round 1: wider near distance gave nothing).
