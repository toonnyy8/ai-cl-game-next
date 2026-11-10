# b2_a0 (round 3): b0_a2 + a Step-in answer

Job of the new rule (a THIRD rule on b0_a2's two; its own step function hks-step, knobs *hks-**, slots hk-sw / hk-at / hk-d):
when Kenpachi's KI code hops in (Step, 2.2-4.4 m) to cut J1 out of the hop, Hisagi plans one Hoho whose invulnerable frames cover that
J1's hit, a perfect Hoho (counter 60, 40 frame lock) that the merged style's pf J1 then cashes.

Mechanism: Kenpachi seen in :step; judged at perceived hop frame 3 (it shows whether the hop closes: d at least 0.4 m shorter than before;
a back hop opens it); Hisagi free (idle / run), Hoho open, d <= 4.4, one roll (*hks-p* 0.3 / 0.6 / 1.0). The J1 hits on hop frame 19 (logs:
hop 26, J1 press 37, move 39, hit 45); the Hoho is pressed at hop frame 11 (*hks-hit* 19 - *hks-lead* 8). Stands still until then.
b0_a2's two rules (wake-up punish / guard, Reishi pot) are untouched.

Evidence from logs (HARD, stand-in, native combat log): the stand-in is the merged style (= Kenpachi's KI code on Hisagi's kit, J1 startup
14 vs Kenpachi's 6) against the real KI code; every loss is an early K.O. by Kenpachi's combos, every win a 300 s clock win. The loops:
Kenpachi's meaty J1 vs Hisagi's wake-up Hoho (perfect; Hisagi wins it via pf J1); Hisagi's meaty / step-in J1 into Kenpachi's wake-up Hoho
(always fired from inside 2.4 m), then Kenpachi's J1 on Hisagi's 29 frame recovery (Hisagi loses it); and the Step-in J1 race (Kenpachi's
J1 beats Hisagi's slower one). Not a KI-code duplicate: the KI code answers moves (kk-read) but never the Step's tell.

Dead ends measured (stand-in group, dev seeds 300, 100 seeds a seat):
- "Wake-up respect" (stand >= 2.6 m while Kenpachi is down so his wake-up Hoho never fires): alone 0.17 (Kenpachi then Steps in
  unanswered); with the Step answer stand-in 0.40 but live 0.51 -> 0.25 (full eval 0.376): the live KH table does not Hoho out of its
  wake-up and profits from the initiative. Gated on two wake-up Hohos seen in the match: stand-in 0.335, no gain. Dropped.
- Step answer alone: stand-in 0.355 (200 matches) vs 0.35 for b0_a2 (100 matches); live 0.49 (100 matches).

Measurement (dev seed0 300, scale 1, 1,220 matches, the final file): score 0.4461; live 0.4505, past 0.3731, arms 0.5785, standin 0.3824;
inc_live 0.125 (tripwire unmoved). b0_a2 on the same block (round 2 proposal): 0.4496 / 0.5099 / 0.3706 / 0.5651 / 0.3529.
So stand-in +0.03 (just above the 0.3762 floor, inside the noise of 100 matches), live -0.06 (noise range), score equal. Host tests ALL PASS.

Risks: the stand-in gain is not established beyond the noise (+-0.05 on 100 matches); the rule fires rarely (most Step-ins are the mirrored
opening hops, where Hisagi is itself mid-hop and cannot Hoho); a Hoho spent on a Step whose J1 does not reach is punished by the hoho-end
J1; HK stays a combination of rules (split into one-job arms if kept). Verdict: a sound but small piece; the stand-in's real loss is the
symmetric wake-up loop, which no standoff fixed without hurting the live KH.
