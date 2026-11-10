# b0_a1 (round 2): guard the wake-up Hoho's end -- NEUTRAL / NOT KEPT

Started from round 2 b0_a0 (PARENT_DIR: wake-up punish + guard on a recovering Kenpachi).
Job (one line): after Hisagi's knockdown wake-up Hoho, on the first free frame (Kenpachi within 2.8 m, not recovering), one roll -> 20 f Guard against the hoho-end J1 the live bait times onto it; else unchanged.
Mechanism: `hkh-step` in the HKS struct (hk-wk = tick of the first free frame after a knockdown, hk-last = last free call); fires when 12 < ticks since hk-wk < 45 and the previous free call was >8 ticks ago (the span in between was the Hoho). Knobs *hkh-p* (0.3/0.6/1.0), *hkh-d*, *hkh-window*. No globals, no cai-defstyle; K read via SNAP S and D only.
History: round 1 b0_* (all first-free-frame replacements lose); b0_a0 round 2 showed the Hoho's end gets a J1 ~60 % of the time, so this acts one step later (the Hoho's end), a seam not tried.
Measurement (dev 300): scale 0.5: 0.2579 (live .216 past .154 arms .393 standin .269) vs parent b0_a0 0.279 (live .284). Scale 1: see score.json.
Verdict: no gain over the parent (live lower within noise); the Guard at the Hoho's end does not beat the hoho-end J1. Not keep-worthy (misses live and stand-in floors); host tests ALL PASS.
