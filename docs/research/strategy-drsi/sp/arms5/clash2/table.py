#!/usr/bin/env python3
"""table.py — arms5/clash2.md's before / after tables from measure.sh's JSON (clash2/before, clash2/after).

  python3 docs/research/strategy-drsi/sp/arms5/clash2/table.py
"""
import json, os
HERE = os.path.dirname(os.path.abspath(__file__))
RUNS = [('hard', 'normal', 'HK'), ('hard', 'normal', 'KH'), ('normal', 'easy', 'HK'), ('normal', 'easy', 'KH'),
        ('easy', 'masher', 'HK'), ('easy', 'masher', 'KH'), ('hard', 'normal', 'HI'), ('hard', 'normal', 'IH'), ('hard', 'hard', 'KH')]
ACC = ['clash', 'clash_na_lt3', 'clash_na_ge3', 'clash_ns_lt3', 'clash_ns_ge3', 'xc_open_na', 'xc_won_na', 'xc_lost_na', 'xc_none_na',
       'xc_open_ns', 'xc_won_ns', 'xc_lost_ns', 'xc_none_ns', 'cancel', 'xch', 'x_none', 'xwin_NA', 'xwin_NS', 'xwin_AS', 'xwin_SA',
       'xwin_counter', 'xwin_hazard', 'start_AS', 'start_SA', 'hit_AS', 'hit_SA', 'dmg_AS', 'dmg_SA', 'dmg_NA', 'dmg_NS', 'dmg']


def load(tag, r):
    with open(os.path.join(HERE, tag, '-'.join(r) + '.json')) as f:
        return json.load(f)


def main():
    print('| rung | cell | before share [bell] | after share [bell] | pass (>= .755) |')
    print('|---|---|---|---|---|')
    for r in RUNS:
        b, a = load('before', r), load('after', r)
        c = r[2]
        bl, al = b['bells'][c], a['bells'][c]
        if r[0] == r[1]:
            print(f"| {r[0]}={r[1]} | {c} | K.O. {1 - bl / b['n']:.3f} (share {b['share']:.3f}) | K.O. {1 - al / a['n']:.3f} (share {a['share']:.3f}) | bar D |")
        else:
            print(f"| {r[0]}>{r[1]} | {c} | {b['share']:.3f} [{bl}] | {a['share']:.3f} [{al}] | {'yes' if a['share'] >= .755 else 'no'} |")
    for r in (('hard', 'normal', 'HK'), ('hard', 'normal', 'KH'), ('hard', 'normal', 'HI'), ('hard', 'normal', 'IH'), ('hard', 'hard', 'KH')):
        b, a = load('before', r), load('after', r)
        print(f"\n{r[0]}>{r[1]} {r[2]} per match (hi = {r[2][0]} the {r[0]} side, lo = {r[2][1]}): before hi / lo -> after hi / lo")
        print('| key | before hi | before lo | after hi | after lo |')
        print('|---|---|---|---|---|')
        for k in ACC:
            v = [x['per_match'][t].get(k, 0.0) for x in (b, a) for t in ('hi', 'lo')]
            print(f"| {k} | " + ' | '.join(f'{x:.2f}' for x in v) + ' |')


if __name__ == '__main__':
    main()
