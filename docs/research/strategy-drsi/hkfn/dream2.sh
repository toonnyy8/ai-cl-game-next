#!/bin/sh
# dream2.sh — the dream step after round 2 (DUEL_AI_STRATEGY §8.19 round 5, step 8), from the repo root: close the round, replay the incumbent
# (round 1's promoted v3_wide) on both frozen worlds, three rewrites of the skill's adaptive template (beta 0.45 / 0.15 / its default 0.6) in
# policy/r2/, compared with the incumbent -> proposal_results/; the coordinator then promotes rank 1. DREAM_RSI = the skill's directory.
set -e
K=docs/research/strategy-drsi/hkfn
T="$DREAM_RSI/scripts/policies/adaptive_template.py"
python3 -B "$DREAM_RSI/scripts/drsi.py" -w $K close-round
python3 -B "$DREAM_RSI/scripts/drsi.py" -w $K replay
mkdir -p $K/policy/r2
sed -e 's/self.config.get("beta", 0.6)/self.config.get("beta", 0.45)/' "$T" > $K/policy/r2/v4_mid.py
sed -e 's/self.config.get("beta", 0.6)/self.config.get("beta", 0.15)/' "$T" > $K/policy/r2/v5_lean.py
cp "$T" $K/policy/r2/v6_adaptive.py
python3 -B "$DREAM_RSI/scripts/drsi.py" -w $K compare --policies $K/policy/r2/v4_mid.py $K/policy/r2/v5_lean.py $K/policy/r2/v6_adaptive.py
