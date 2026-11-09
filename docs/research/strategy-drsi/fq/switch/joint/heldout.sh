#!/bin/sh
# heldout.sh KI_NEW IK_NEW — step 3's acceptance runs (DUEL_AI_STRATEGY §8.19 round 5, step 3, the rule fixed beforehand), from the switch
# directory, seeds 601-700 + 701-800, both seats: the 2x2 from each side's seat (old / new KI x old / new IK) and each table against the other
# side's frozen style CPU; then the rule's verdict -> joint/heldout.json. Step 4 overrides the old tables and the names: KIO=joint/ki-t2.lisp
# PFX=j4h OUT=joint/heldout4.json (the defaults are step 3's).
set -e
FZI=../../counter/frozen/ki-ichigo.lisp
FZK=../../counter/frozen/ki-ken.lisp
KIO=${KIO:-kenpachi/qks-ichigo.lisp}
IKO=${IKO:-../../counter/frozen/q1-ichigo-ken.lisp}
export PFX=${PFX:-jh} OUT=${OUT:-joint/heldout.json}
KIN=$1; IKN=$2
m() { for b in 601-700 701-800; do python3 sw.py measure --me $1 --vs $2 --opp $3 --arms $4 --table $5 --tag ev/$PFX-$6-${b%%-*} --seeds $b -j ${J:-20} > /dev/null; done; }
m kenpachi ichigo $IKO kenpachi/ki.arms $KIO ki-o-vs-iko
m kenpachi ichigo $IKO kenpachi/ki.arms $KIN ki-n-vs-iko
m kenpachi ichigo $IKN kenpachi/ki.arms $KIO ki-o-vs-ikn
m kenpachi ichigo $IKN kenpachi/ki.arms $KIN ki-n-vs-ikn
m kenpachi ichigo $FZI kenpachi/ki.arms $KIO ki-o-vs-fz
m kenpachi ichigo $FZI kenpachi/ki.arms $KIN ki-n-vs-fz
m ichigo kenpachi $KIO ichigo/ik.arms $IKO ik-o-vs-kio
m ichigo kenpachi $KIO ichigo/ik.arms $IKN ik-n-vs-kio
m ichigo kenpachi $KIN ichigo/ik.arms $IKO ik-o-vs-kin
m ichigo kenpachi $KIN ichigo/ik.arms $IKN ik-n-vs-kin
m ichigo kenpachi $FZK ichigo/ik.arms $IKO ik-o-vs-fz
m ichigo kenpachi $FZK ichigo/ik.arms $IKN ik-n-vs-fz
python3 - <<'EOF'
import json, os
PFX, OUT = os.environ['PFX'], os.environ['OUT']
def wins(tag):
    w = {}
    for b in ('601', '701'):
        d = json.load(open(f'ev/{PFX}-{tag}-{b}.json'))
        w.update({f'{b}-{k}': v for k, v in d['wins'].items()})
    return w
def share(tag):
    w = wins(tag); return round(sum(1 for v in w.values() if v > 0) / len(w), 4)
def pair(new, old):
    a, o = wins(new), wins(old)
    b = sum(1 for k in a if a[k] > 0 and not o[k] > 0); c = sum(1 for k in a if o[k] > 0 and not a[k] > 0)
    return dict(b=b, c=c, z=round((b - c) / max(1, b + c) ** 0.5, 2))
out = {'2x2 (Kenpachi\'s share)': {f'{k}': share(f'ki-{k}') for k in ('o-vs-iko', 'n-vs-iko', 'o-vs-ikn', 'n-vs-ikn')},
       '2x2 (Ichigo\'s share)': {f'{k}': share(f'ik-{k}') for k in ('o-vs-kio', 'n-vs-kio', 'o-vs-kin', 'n-vs-kin')},
       'stand-in': {k: share(k) for k in ('ki-o-vs-fz', 'ki-n-vs-fz', 'ik-o-vs-fz', 'ik-n-vs-fz')}}
ki = [pair('ki-n-vs-iko', 'ki-o-vs-iko'), pair('ki-n-vs-ikn', 'ki-o-vs-ikn'), pair('ki-n-vs-fz', 'ki-o-vs-fz')]
ik = [pair('ik-n-vs-kio', 'ik-o-vs-kio'), pair('ik-n-vs-kin', 'ik-o-vs-kin'), pair('ik-n-vs-fz', 'ik-o-vs-fz')]
out['KI new vs old: vs IK_old, vs IK_new, vs stand-in'] = ki
out['IK new vs old: vs KI_old, vs KI_new, vs stand-in'] = ik
out['KI swaps'] = ki[0]['z'] >= 1.96 and ki[1]['z'] >= 1.96 and ki[2]['z'] > -1.96
out['IK swaps'] = ik[0]['z'] >= 1.96 and ik[1]['z'] >= 1.96 and ik[2]['z'] > -1.96
json.dump(out, open(OUT, 'w'), indent=1)
print(json.dumps(out, indent=1))
EOF
