#!/bin/sh
# standoff.sh — step 6: the rewritten stand-off breaker (ken-kh-standoff-style, cand-standoff.lisp) under the fixed keep rule (DUEL_AI_STRATEGY
# §8.19 round 5, steps 5-6), from the repo root on the build with it: the search block (seed0 200) and the held-out block (seed0 400, scale 2),
# then the rule against refs.jsonl and its distance from the kept bait (rounds/round01/nodes/b0_a0/heldout.json) -> standoff.jsonl
set -e
K=docs/research/strategy-drsi/khfn
python3 $K/eval.py --cand $K/cand-standoff.lisp --seed0 200 -j 20 > $K/standoff.jsonl
python3 $K/eval.py --cand $K/cand-standoff.lisp --seed0 400 --scale 2 -j 20 >> $K/standoff.jsonl
python3 - $K <<'EOF'
import json, sys
k = sys.argv[1]
s, h = [json.loads(l) for l in open(f'{k}/standoff.jsonl')]
refs = {d['cand']: d for d in map(json.loads, open(f'{k}/refs.jsonl')) if d['seed0'] == 400}
bait = json.load(open(f'{k}/rounds/round01/nodes/b0_a0/heldout.json'))
ki, ik = refs['cand-khfn'], refs['k5-iki']
dist = lambda a, b: round(sum(abs(a['members'][m] - b['members'][m]) for m in a['members']) / len(a['members']), 4)
best = max(ki['score'], ik['score']); live = max(ki['groups']['live'], ik['groups']['live'])
r = dict(search=s['score'], heldout=h['score'], live=h['groups']['live'], need_score=round(best + 0.03, 4), need_live=live,
         dist_ken_ki=dist(h, ki), dist_ichigo_ki=dist(h, ik), dist_bait=dist(h, bait), inc_live=[s['inc_live'], h['inc_live']])
r['keep'] = h['score'] >= best + 0.03 and h['groups']['live'] >= live and r['dist_ken_ki'] >= 0.05 and r['dist_ichigo_ki'] >= 0.05
print(json.dumps(r))
with open(f'{k}/standoff.jsonl', 'a') as f:
    f.write(json.dumps(r) + '\n')
EOF
