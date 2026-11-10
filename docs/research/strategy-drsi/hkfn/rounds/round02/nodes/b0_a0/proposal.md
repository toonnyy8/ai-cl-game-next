# b0_a0 (round 2): answer his own wake-up by reading what Kenpachi whiffed into it

Started from round 1's b2_a0 (the whiff punish after his knockdown). Job (one line): on Hisagi's first free frame after a knockdown, a
Kenpachi perceived recovering is hit by J1/NS when the move fits his recovery, else answered with a 20-frame Guard instead of the generic
wake-up Hoho; every other frame is the merged style unchanged.

## History read and what it said
- Round 1: every replacement of the first free frame (roll, guard, SP, walk, withheld Hoho: b0_a0/a1/a2) lost, because the frame cannot
  tell the live bait (K idle at 2.3 m) from the KI code's meaty J1 (also idle at 2.25-2.4 until it presses). b2_a0's punish raised live only.
- My logs (live KH, HARD, 25 matches): Hisagi's wake-up Hoho is perfect ~20 %, and the hoho-end J1 lands ~60 % (K times it to the Hoho's
  first free frame, *KK-HEND-P*), which opens the J1 + AS combo and the next knockdown: a loop. A Hoho is 100 of 300 flash-step, so fs sits
  at 40-130 on most first free frames (no Burst: it needs 200). Of 124 first free frames logged, ~2/3 find K in KE-Z-N1A/N2A/J1 recovery at
  0.9-1.4 m; the punish only fits when the real left is >= 14 (J1), i.e. N1A with snap-left >= 22.
- Tried and dropped (live, 100 seeds a seat, dev 300): Burst out of the combo that starts on the Hoho's end (0.195 vs 0.185; it almost never
  fires: the combo is J1 + AS1, two hits, and fs < 200); Step-out instead of the Hoho 0.18; guard also vs an idle K inside 1.8 m 0.255 (no
  gain, riskier); guard 12 f 0.22, 36 f 0.185, guard until the recovery ends +8 f 0.135 (the length matters, 20 f best; trajectories are chaotic).

## Mechanism
`hkw-step` (state in `hks`, includes `hms`): own state {:air :down :wakeup} -> {:idle :run} and `snap-recovering-p`: J1 (else NS) if
`hkw-fits-p`; else, with K within `*hkw-guard-d*` 1.6 m, one roll (`*hkw-p*` 0.3/0.6/1.0) -> `(mc-press b :guard)` (20 f) and return T so
the generic Hoho does not fire. New knob `*hkw-guard-d*`. No globals, no cai-defstyle; Kenpachi is read only via SNAP S and D.

## Measurement (dev seed0 300, final file, scale 1, 1,220 matches)
score 0.2559: live 0.2723 / past 0.1393 / arms 0.4061 / standin 0.2059 (inc_live 0.125, the tripwire, unmoved).
Reference: the starting file (b2_a0) at scale 0.5 scored 0.2681 (live .245 past .154 arms .405 standin .269); this file at scale 0.5 scored
0.2791 (live .284, past .158, arms .405, standin .269). Live only, 100 seeds a seat: seed0 300 0.185 -> 0.27 (54/200); seed0 600
0.175 -> 0.23 (46/200). The stand-in and arm groups are unchanged at scale 0.5 (the guard almost never fires there); their scale-1
spread (stand-in .206, arms .406) is draw noise (+-0.03-0.04).

## Not a repeat / not a KI duplicate
Round 1 replaced the wake-up frame blindly; this fires only on a perceived recovering Kenpachi, where the Hoho buys nothing, and only
chooses between punish and guard. Kenpachi's KI code never guards at a wake-up. It is a one-knob extension of b2_a0 (the same seam), so
close to its parent, but with a measured live gain the parent lacks.

## Expected benefit and risks
Live-KH group +0.06-0.09 (still far under the keep rule's 0.2985); the stand-in is NOT improved (0.21-0.27 vs the floor 0.3762), so the
keep rule fails: a live-KH-only job. Risks: the effect is chaotic in the guard length (12/20/36 f = .22/.27/.185), so part of the gain may
be seed-block luck (two blocks agree: +0.085, +0.055); it fires only when K whiffs a long move into the wake-up, the live KH's signature,
so it should not move other pairings (no cai-defstyle, tripwire unmoved).
