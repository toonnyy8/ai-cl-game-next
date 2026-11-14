# b2_a0: clash off (:clash-p 0.0, :clash-margin 0.3 inert)
cand.lisp = baseline + `:clash-p 0.0 :clash-margin 0.3` in :base. Final score 0.8614 (baseline 0.7706), seed0 300, build 949a94db54fe.
Final groups: anchor 198/2/0 (ko_wins/losses/timeouts of 200), mix 154/41/5, rest 167/32/1.
Runs (seed0 300): v1 clash-p 1.7 margin 1.6 (KI's pilot setting) 0.6122 (anchor 180/18/2, mix 81/65/54, rest 107/62/31) -> worse;
v2 clash-p 0 margin 0.3 0.8614; v3 awaken-break 1.9 kikon 1.2 0.7673 (mix 122/48/30; ~baseline);
v4 clash-p 0 margin 0 0.8614 (identical counts to v2: with p 0 the margin's clash read is dead, J-side AS read unaffected here);
v5 v2 + awaken-break 0.3 kikon 0.5 0.8597 (no gain). 5 of 8 runs used.
Reading: against Hisagi the active clash (throwing the cancelling move into his) loses; stronger clash raises time-outs, none lowers them. Awakening breakers are ~neutral.
