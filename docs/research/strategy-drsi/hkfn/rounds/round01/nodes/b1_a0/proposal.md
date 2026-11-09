# b1_a0 (round 1): Shikai kiting

Job: when Kenpachi walks in to the edge of his reach, Hisagi backs off with one Step and pokes with his pointer's NS from the new distance.

Mechanism (cpu-hk-hisagi.lisp; struct HKS includes HMS so the merged style keeps its state):
- Only outside the Bankai, only when free (idle/run). Kenpachi perceived closing, 2.0 <= d < 3.3 m, not in stun/air/down/wakeup/cine: one roll per approach event (*hkk-p*, HARD 1.0, EASY <= NORMAL <= HARD), then mc-press :step-out.
- Within 50 frames of the back-step, the first free step with Kenpachi at 2.9-6.0 m and not mid-move presses the pointer's NS once (hr-sp, a tap); else the merged style decides. Everything else is hisagi-merged-style unchanged; the Bankai's ranged mode keeps the existing distance rule.
- Kenpachi is read only through SNAP S and D. No globals, no cai-defstyle.

Evidence from history: the baseline has no spacing in the Shikai (the existing range rule is Bankai-only). Not a KI-code repeat: Kenpachi's KI code never retreats.

Measurement (seed0 300, dev): baseline 0.195 (scale 1); this 0.2604 (scale 1): live 0.040 (flat), past 0.177, arms 0.433, standin 0.392. Scale 0.5: 0.284 (near 3.3, poke 2.9) vs 0.271 (near 4.0, poke 2.6): widening gave nothing. inc_live 0.125 (unmoved). Host tests ALL PASS.

Risks: the gain is in the stand-in and arms; the live KH (the bait) is unmoved at ~0.04, so the keep rule's live-KH >= 0.2985 will not pass. Step cost / cooldown not studied; one poke per kite only.
