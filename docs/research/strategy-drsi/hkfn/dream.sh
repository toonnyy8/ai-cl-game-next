#!/bin/sh
# dream.sh — the dream step after round 1 (DUEL_AI_STRATEGY §8.19 round 5, step 7), from the repo root: the incumbent (the configured grid's
# baseline_parallel_refine) replayed on the frozen round-1 world, three rewrites from the skill's adaptive template (beta 0.6 / 0.3 / 0.9) in
# policy/, compared with the incumbent (drsi.py compare: the M = 4 of the paper) -> proposal_results/. DREAM_RSI = the skill's directory.
set -e
K=docs/research/strategy-drsi/hkfn
T="$DREAM_RSI/scripts/policies/adaptive_template.py"
cp "$T" $K/policy/v1_adaptive.py
sed -e 's/self.config.get("beta", 0.6)/self.config.get("beta", 0.3)/' "$T" > $K/policy/v2_narrow.py
sed -e 's/self.config.get("beta", 0.6)/self.config.get("beta", 0.9)/' "$T" > $K/policy/v3_wide.py
python3 -B "$DREAM_RSI/scripts/drsi.py" -w $K compare --policies $K/policy/v1_adaptive.py $K/policy/v2_narrow.py $K/policy/v3_wide.py
