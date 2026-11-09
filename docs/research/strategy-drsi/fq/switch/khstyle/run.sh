#!/bin/sh
# khstyle/run.sh — KH (with the step-5 style arm) and HK optimised together (DUEL_AI_STRATEGY §8.19 round 5, step 5; step 4's khstyle/run.sh), from the
# switch directory, after start.sh. Two iterations of simultaneous fictitious play from the live tables with the kept arms (kh-t0 / hk-t0 = the
# live lookup); pools: the other side's past iterates (+ Kenpachi's KI style CPU on HK's). Then the candidate per side (iterate 1 or 2 on
# 801-1000 against the last pool's members) and the held-out verdict under step 3's fixed rule, decided beforehand: a side swaps only if its
# candidate beats its old table at z >= 1.96 against the other side's old AND new table (601-800, both seats), and for HK also not at z <= -1.96
# against the stand-in; KH has no stand-in. -> khstyle/select.json, khstyle/heldout.json
set -e
FZK=../../counter/frozen/ki-ken.lisp
KA=khstyle/kh.arms; HA=arms/hk.arms; export KH_ARMS=$KA HK_ARMS=$HA OUT=khstyle TAGP=s
[ -f khstyle/hk-t1.lisp ] || sh khjoint/iterate.sh 0 khstyle/kh-t0.lisp khstyle/hk-t0.lisp "khstyle/hk-t0.lisp" "khstyle/kh-t0.lisp,$FZK"
[ -f khstyle/hk-t2.lisp ] || sh khjoint/iterate.sh 1 khstyle/kh-t1.lisp khstyle/hk-t1.lisp "khstyle/hk-t0.lisp,khstyle/hk-t1.lisp" "khstyle/kh-t0.lisp,khstyle/kh-t1.lisp,$FZK"
m() { python3 sw.py measure --me $1 --vs $2 --opp $3 --arms $4 --table $5 --tag ev/$6 --seeds $7 -j ${J:-20} > /dev/null; }
for t in 1 2; do
  i=0; for o in khstyle/hk-t0.lisp khstyle/hk-t1.lisp; do i=$((i+1)); m kenpachi hisagi $o $KA khstyle/kh-t$t.lisp sjs-kh-t$t-o$i 801-1000; done
  i=0; for o in khstyle/kh-t0.lisp khstyle/kh-t1.lisp $FZK; do i=$((i+1)); m hisagi kenpachi $o $HA khstyle/hk-t$t.lisp sjs-hk-t$t-o$i 801-1000; done
done
python3 - <<'EOF'
import glob, json
out = {}
for side in ('kh', 'hk'):
    for t in (1, 2):
        n = len(glob.glob(f'ev/sjs-{side}-t{t}-o*.json'))
        s = [json.load(open(f'ev/sjs-{side}-t{t}-o{i}.json'))['share'] for i in range(1, n + 1)]
        out[f'{side}-t{t}'] = dict(shares=s, mean=round(sum(s) / n, 4))
    out[f'{side}-pick'] = max((1, 2), key=lambda t: out[f'{side}-t{t}']['mean'])
json.dump(out, open('khstyle/select.json', 'w'), indent=1)
print(json.dumps(out))
EOF
K=$(python3 -c "import json; print(json.load(open('khstyle/select.json'))['kh-pick'])")
H=$(python3 -c "import json; print(json.load(open('khstyle/select.json'))['hk-pick'])")
KO=khstyle/kh-t0.lisp; HO=khstyle/hk-t0.lisp; KN=khstyle/kh-t$K.lisp; HN=khstyle/hk-t$H.lisp
h() { for b in 601-700 701-800; do m $1 $2 $3 $4 $5 sjh-$6-${b%%-*} $b; done; }
h kenpachi hisagi $HO $KA $KO kh-o-vs-hko
h kenpachi hisagi $HO $KA $KN kh-n-vs-hko
h kenpachi hisagi $HN $KA $KO kh-o-vs-hkn
h kenpachi hisagi $HN $KA $KN kh-n-vs-hkn
h hisagi kenpachi $KO $HA $HO hk-o-vs-kho
h hisagi kenpachi $KO $HA $HN hk-n-vs-kho
h hisagi kenpachi $KN $HA $HO hk-o-vs-khn
h hisagi kenpachi $KN $HA $HN hk-n-vs-khn
h hisagi kenpachi $FZK $HA $HO hk-o-vs-fz
h hisagi kenpachi $FZK $HA $HN hk-n-vs-fz
python3 - <<'EOF'
import json
def wins(tag):
    w = {}
    for b in ('601', '701'):
        d = json.load(open(f'ev/sjh-{tag}-{b}.json'))
        w.update({f'{b}-{k}': v for k, v in d['wins'].items()})
    return w
def share(tag):
    w = wins(tag); return round(sum(1 for v in w.values() if v > 0) / len(w), 4)
def pair(new, old):
    a, o = wins(new), wins(old)
    b = sum(1 for k in a if a[k] > 0 and not o[k] > 0); c = sum(1 for k in a if o[k] > 0 and not a[k] > 0)
    return dict(b=b, c=c, z=round((b - c) / max(1, b + c) ** 0.5, 2))
out = {'2x2 (Kenpachi\'s share)': {k: share(f'kh-{k}') for k in ('o-vs-hko', 'n-vs-hko', 'o-vs-hkn', 'n-vs-hkn')},
       '2x2 (Hisagi\'s share)': {k: share(f'hk-{k}') for k in ('o-vs-kho', 'n-vs-kho', 'o-vs-khn', 'n-vs-khn')},
       'stand-in': {k: share(k) for k in ('hk-o-vs-fz', 'hk-n-vs-fz')}}
kh = [pair('kh-n-vs-hko', 'kh-o-vs-hko'), pair('kh-n-vs-hkn', 'kh-o-vs-hkn')]
hk = [pair('hk-n-vs-kho', 'hk-o-vs-kho'), pair('hk-n-vs-khn', 'hk-o-vs-khn'), pair('hk-n-vs-fz', 'hk-o-vs-fz')]
out['KH new vs old: vs HK_old, vs HK_new'] = kh
out['HK new vs old: vs KH_old, vs KH_new, vs stand-in'] = hk
out['KH swaps'] = kh[0]['z'] >= 1.96 and kh[1]['z'] >= 1.96
out['HK swaps'] = hk[0]['z'] >= 1.96 and hk[1]['z'] >= 1.96 and hk[2]['z'] > -1.96
json.dump(out, open('khstyle/heldout.json', 'w'), indent=1)
print(json.dumps(out, indent=1))
EOF
