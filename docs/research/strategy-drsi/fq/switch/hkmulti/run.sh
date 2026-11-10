#!/bin/sh
# hkmulti/run.sh — step 10's rule candidates (DUEL_AI_STRATEGY §8.19 round 5, step 10; hksplit/run.sh's procedure), from the switch directory,
# after start.sh: KH (the live :qks5-hisagi, layer on) and HK (hk9-t0: :qhs-ken + the three one-job arms + the all-on arm, = the live HK)
# refit simultaneously, two iterations (step 3's method), the candidate per side on 801-1000, the held-out verdict on 601-800 under the fixed rule (z >= 1.96 against
# the other side's old and new table; HK also not z <= -1.96 against the stand-in; KH has none). The no-refit start tables equal the old
# ones (KH has no new arm; HK's new arms sit below every row), so the candidates are the iterates. -> hkmulti/select.json, heldout.json
set -e
FZK=../../counter/frozen/ki-ken.lisp
KA=khevent/kh.arms; HA=hkmulti/hk9.arms; export KH_ARMS=$KA HK_ARMS=$HA OUT=hkmulti TAGP=s10 KH_EVENT="(:id :kp7-kh :fn ken-kh-style :apply (:kenpachi))"
[ -f hkmulti/hk-t1.lisp ] || sh khjoint/iterate.sh 0 khevent/kh-t0.lisp hkmulti/hk9-t0.lisp "hkmulti/hk9-t0.lisp" "khevent/kh-t0.lisp,$FZK"
[ -f hkmulti/hk-t2.lisp ] || sh khjoint/iterate.sh 1 hkmulti/kh-t1.lisp hkmulti/hk-t1.lisp "hkmulti/hk9-t0.lisp,hkmulti/hk-t1.lisp" "khevent/kh-t0.lisp,hkmulti/kh-t1.lisp,$FZK"
m() { python3 sw.py measure --me $1 --vs $2 --opp $3 --arms $4 --table $5 --tag ev/$6 --seeds $7 -j ${J:-20} > /dev/null; }
for t in 1 2; do
  i=0; for o in hkmulti/hk9-t0.lisp hkmulti/hk-t1.lisp; do i=$((i+1)); m kenpachi hisagi $o $KA hkmulti/kh-t$t.lisp s10s-kh-t$t-o$i 801-1000; done
  i=0; for o in khevent/kh-t0.lisp hkmulti/kh-t1.lisp $FZK; do i=$((i+1)); m hisagi kenpachi $o $HA hkmulti/hk-t$t.lisp s10s-hk-t$t-o$i 801-1000; done
done
python3 - <<'EOF'
import glob, json
out = {}
for side in ('kh', 'hk'):
    for t in (1, 2):
        n = len(glob.glob(f'ev/s10s-{side}-t{t}-o*.json'))
        s = [json.load(open(f'ev/s10s-{side}-t{t}-o{i}.json'))['share'] for i in range(1, n + 1)]
        out[f'{side}-t{t}'] = dict(shares=s, mean=round(sum(s) / n, 4))
    out[f'{side}-pick'] = max((1, 2), key=lambda t: out[f'{side}-t{t}']['mean'])
json.dump(out, open('hkmulti/select.json', 'w'), indent=1)
print(json.dumps(out))
EOF
K=$(python3 -c "import json; print(json.load(open('hkmulti/select.json'))['kh-pick'])")
H=$(python3 -c "import json; print(json.load(open('hkmulti/select.json'))['hk-pick'])")
KO=khevent/kh-t0.lisp; HO=hkmulti/hk9-t0.lisp; KN=hkmulti/kh-t$K.lisp; HN=hkmulti/hk-t$H.lisp
h() { for b in 601-700 701-800; do m $1 $2 $3 $4 $5 s10h-$6-${b%%-*} $b; done; }
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
        d = json.load(open(f'ev/s10h-{tag}-{b}.json'))
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
json.dump(out, open('hkmulti/heldout.json', 'w'), indent=1)
print(json.dumps(out, indent=1))
EOF
