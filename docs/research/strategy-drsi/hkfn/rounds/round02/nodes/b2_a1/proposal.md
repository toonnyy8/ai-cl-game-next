# b2_a1 (round 2): punish the whiffed recovery after ANY busy state -- NEGATIVE, not keep-worthy

Started from: PARENT b2_a0 (round 2: whiff punish after knockdown / own Hoho / own Step).
Job (one line): on Hisagi's first free frame after any busy state (a move, a hit, a dodge), a Kenpachi perceived recovering whose recovery
outlasts J1's (else the pointer's NS) startup and who is in reach is hit by that move; everything else is the merged style.

History read: round 1 none kept (first-frame replacements after a knockdown lose; whiff punish lifts live only); round 2 b2_a0 (live 0.158
rescored), b0_a0 guard (live 0.198), b1_a0 counter-Hoho (live 0.045), b3_a0 Ichigo+Reishi (live 0.27, standin 0.01).
Mechanism: one-line change to hkw-step: the `was` set {:air :down :wakeup :hoho :step} becomes "anything but :idle/:run" (one roll on the
transition into free, HARD 1.0), aimed at the KI code's meaty J1, hoho-end J1, Step-in and stand-off attack, whose whiffs recover in reach.
Measurement (dev 300): an any-free-frame variant at scale 0.5: 0.277 (live 0.245). Final (entry-only roll), scale 1: 0.2477, live 0.198 /
past 0.144 / arms 0.433 / standin 0.216 (baseline merged style dev 0.195; b2_a0 0.2419, live 0.193): inside the +-0.02 noise of b2_a0.
Host tests ALL PASS.
Finding: broadening the trigger set adds almost no trigger frames (the fit test needs snap-left >= 14 and K in reach); the punish is not the lever.
Fails the keep rule (live < 0.2985, score < 0.3153). Not a KI duplicate (reacts only to a seen recovery).
