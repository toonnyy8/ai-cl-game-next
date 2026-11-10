# b2_a2 (round 2): step through Kenpachi's move, J1 out of the Step's cancel -- NEGATIVE, not keep-worthy

Started from: PARENT b2_a1 (any-busy whiff punish); that punish was dropped, only the new rule remains.
Job (one line): outside the Bankai, when Kenpachi starts a move that reaches him, press a Step toward him timed so the Step's iframes
(3-9) cover his first hit, then J1 out of the Step's J cancel (frame 12) onto his recovery; else the merged style.
History read: round 1 none kept (first-free-frame replacements lose; whiff punish lifts live to ~0.19 only); round 2 b2_a0/b2_a1 whiff
punish (live 0.16, inside noise of each other), b0_a0 guard (0.198), b1_a0 counter-Hoho (0.045), b3_a0 Ichigo+Reishi (0.27 live, 0.01 stand-in).
Mechanism: hkj-step. One roll per Kenpachi move start (HARD 1.0 / NORMAL 0.5 / EASY 0) when the move has hits and d <= reach+slide+0.3;
press tick = now + (frames to his first hit less perception delay) - 6; while waiting return T with stick neutral; at the press
kk-stick toward + Step; at Step frame 10 (J cancel latch) J1 if within J1 reach. State in HKS (includes HMS) in brain-style.
Not a KI duplicate: the KI code answers a move start with a race J1/NS1a, a Hoho or a BACK Step; it never steps through and cancels.
Measurement (dev 300): scale 0.5 0.2306 (live .069); scale 1 0.2073: live 0.0594 / past 0.1269 / arms 0.4272 / standin 0.2157
(baseline merged style dev 0.195, live ~0.04; parent b2_a0 live ~0.19). Host tests ALL PASS.
Verdict: no gain; live is baseline-level, so the punish half (parent) was lost and nothing replaced it. I did not verify the rule fires
(eval.py shows no clog output). Possible faults: the :fn may not run during :step so the J cancel never fires, or the forward Step is
blocked by body collision. Fails keep rule (live < 0.2985, stand-in < 0.3762, score < 0.3153).
Risk: waiting with a neutral stick while his move runs can eat the merged style's own race/dodge.
