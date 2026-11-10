#!/bin/sh
# dream3.sh — the dream step after round 3 (DUEL_AI_STRATEGY §8.19 round 5, step 9), from the repo root: close the round, replay the incumbent
# (round 2's promoted v6_adaptive) on the three frozen worlds, three rewrites of the skill's adaptive template (beta 0.3 / 0.9 / 0.75) in
# policy/r3/, compared with the incumbent -> proposal_results/; the coordinator then promotes rank 1. DREAM_RSI = the skill's directory.
set -e
K=docs/research/strategy-drsi/hkfn
T="$DREAM_RSI/scripts/policies/adaptive_template.py"
python3 -B "$DREAM_RSI/scripts/drsi.py" -w $K close-round
python3 -B "$DREAM_RSI/scripts/drsi.py" -w $K replay
mkdir -p $K/policy/r3
sed -e 's/self.config.get("beta", 0.6)/self.config.get("beta", 0.3)/' "$T" > $K/policy/r3/v7_narrow.py
sed -e 's/self.config.get("beta", 0.6)/self.config.get("beta", 0.9)/' "$T" > $K/policy/r3/v8_wide.py
sed -e 's/self.config.get("beta", 0.6)/self.config.get("beta", 0.75)/' "$T" > $K/policy/r3/v9_mid.py
python3 -B "$DREAM_RSI/scripts/drsi.py" -w $K compare --policies $K/policy/r3/v7_narrow.py $K/policy/r3/v8_wide.py $K/policy/r3/v9_mid.py
