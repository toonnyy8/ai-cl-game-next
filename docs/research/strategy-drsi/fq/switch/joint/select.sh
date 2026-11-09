#!/bin/sh
# select.sh — step 3's candidate per side (DUEL_AI_STRATEGY §8.19 round 5, step 3), from the switch directory: each side's two iterates on
# seeds 801-1000 against every member of its last pool (one at a time); the mean share picks the candidate -> joint/select.json.
set -e
FZI=../../counter/frozen/ki-ichigo.lisp
FZK=../../counter/frozen/ki-ken.lisp
Q1=../../counter/frozen/q1-ichigo-ken.lisp
KI0=kenpachi/qks-ichigo.lisp
m() { python3 sw.py measure --me $1 --vs $2 --opp $3 --arms $4 --table $5 --tag ev/$6 --seeds 801-1000 -j ${J:-20} > /dev/null; }
for t in 1 2; do
  i=0; for o in $Q1 joint/ik-t1.lisp $FZI; do i=$((i+1)); m kenpachi ichigo $o kenpachi/ki.arms joint/ki-t$t.lisp js-ki-t$t-o$i; done
  i=0; for o in $KI0 joint/ki-t1.lisp $FZK; do i=$((i+1)); m ichigo kenpachi $o ichigo/ik.arms joint/ik-t$t.lisp js-ik-t$t-o$i; done
done
python3 - <<'EOF'
import json
out = {}
for side in ('ki', 'ik'):
    for t in (1, 2):
        s = [json.load(open(f'ev/js-{side}-t{t}-o{i}.json'))['share'] for i in (1, 2, 3)]
        out[f'{side}-t{t}'] = dict(shares=s, mean=round(sum(s) / 3, 4))
    out[f'{side}-pick'] = max((1, 2), key=lambda t: out[f'{side}-t{t}']['mean'])
json.dump(out, open('joint/select.json', 'w'), indent=1)
print(json.dumps(out))
EOF
