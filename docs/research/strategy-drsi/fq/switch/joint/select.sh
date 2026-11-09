#!/bin/sh
# select.sh — step 3's candidate per side (DUEL_AI_STRATEGY §8.19 round 5, step 3), from the switch directory: each side's two iterates on
# seeds 801-1000 against every member of its last pool (one at a time); the mean share picks the candidate -> joint/select.json. Step 4
# overrides TS="3 4", the pools KPOOL / IPOOL (space lists), PFX=j4s, OUT=joint/select4.json (the defaults are step 3's).
set -e
FZI=../../counter/frozen/ki-ichigo.lisp
FZK=../../counter/frozen/ki-ken.lisp
Q1=../../counter/frozen/q1-ichigo-ken.lisp
KI0=kenpachi/qks-ichigo.lisp
export TS="${TS:-1 2}" PFX="${PFX:-js}" OUT="${OUT:-joint/select.json}"
KPOOL=${KPOOL:-$Q1 joint/ik-t1.lisp $FZI}
IPOOL=${IPOOL:-$KI0 joint/ki-t1.lisp $FZK}
m() { python3 sw.py measure --me $1 --vs $2 --opp $3 --arms $4 --table $5 --tag ev/$6 --seeds 801-1000 -j ${J:-20} > /dev/null; }
for t in $TS; do
  i=0; for o in $KPOOL; do i=$((i+1)); m kenpachi ichigo $o kenpachi/ki.arms joint/ki-t$t.lisp $PFX-ki-t$t-o$i; done
  i=0; for o in $IPOOL; do i=$((i+1)); m ichigo kenpachi $o ichigo/ik.arms joint/ik-t$t.lisp $PFX-ik-t$t-o$i; done
done
python3 - <<'EOF'
import glob, json, os
PFX, TS = os.environ['PFX'], [int(t) for t in os.environ['TS'].split()]
out = {}
for side in ('ki', 'ik'):
    for t in TS:
        n = len(glob.glob(f'ev/{PFX}-{side}-t{t}-o*.json'))
        s = [json.load(open(f'ev/{PFX}-{side}-t{t}-o{i}.json'))['share'] for i in range(1, n + 1)]
        out[f'{side}-t{t}'] = dict(shares=s, mean=round(sum(s) / n, 4))
    out[f'{side}-pick'] = max(TS, key=lambda t: out[f'{side}-t{t}']['mean'])
json.dump(out, open(os.environ['OUT'], 'w'), indent=1)
print(json.dumps(out))
EOF
