#!/usr/bin/env python3
"""jobscore.py — candidate job maps scored OFFLINE on already-logged judgements (B4, before any bar run of a narrowed map): a row's bar-A
run (proof.py bar's cached sim output, the same env = a cache hit, no sim) re-read for each candidate job: its firing share (any weight,
and weighted) and how lasting it is (the firing share after its first firing in a match). The logs were played by the v0 tables, so these
are the states those matches visited, not what a new map would play.
  python3 jobscore.py ROW SIDE   (ROW as bars.py, SIDE 1|2; candidates below)"""
import importlib.util, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
A4 = os.path.dirname(HERE)
_s = importlib.util.spec_from_file_location('proof', os.path.join(A4, 'proof.py'))
proof = importlib.util.module_from_spec(_s); _s.loader.exec_module(proof)
import bars  # noqa: E402

CAND = {
    'kessa2': {'v0 G0 awakened | G1 form1': [[0, ["(:awst :k2)"]], [1, ["(:form :yes)"]]],
               'G1 form1 x mid/far': [[1, ["(:form :yes)", "(:dm :m-mid)"]], [1, ["(:form :yes)", "(:dm :m-far)"]]],
               'G1 form1 x far': [[1, ["(:form :yes)", "(:dm :m-far)"]]],
               'G0 awakened x behind': [[0, ["(:awst :k2)", "(:lead :behind)"]]]},
    'keep': {'v0 G8 ahead': [[8, ["(:lead :ahead)"]]],
             'G8 ahead x mid/late': [[8, ["(:time :t-mid)", "(:lead :ahead)"]], [8, ["(:time :t-late)", "(:lead :ahead)"]]],
             'G8 ahead x late': [[8, ["(:time :t-late)", "(:lead :ahead)"]]],
             'G8 late (any lead)': [[8, ["(:time :t-late)"]]],
             'G0 ahead x not awakened': [[0, ["(:lead :ahead)", "(:awst :no)"]], [0, ["(:lead :ahead)", "(:awst :yes)"]]],
             'G0 ahead x awst no': [[0, ["(:lead :ahead)", "(:awst :no)"]]],
             'G1 sealed x far': [[1, ["(:form :no)", "(:dm :m-far)"]]],
             'G8 ahead x mid': [[8, ["(:time :t-mid)", "(:lead :ahead)"]]]},
    'range': {'v0 G1 form1 x mid/far | G9 open': [[1, ["(:form :yes)", "(:dm :m-mid)"]], [1, ["(:form :yes)", "(:dm :m-far)"]], [9, ["(:swopen :yes)"]]],
              'G1 form1 x mid/far': [[1, ["(:form :yes)", "(:dm :m-mid)"]], [1, ["(:form :yes)", "(:dm :m-far)"]]],
              'G1 form1 x mid/far | G9 open x ptr1': [[1, ["(:form :yes)", "(:dm :m-mid)"]], [1, ["(:form :yes)", "(:dm :m-far)"]],
                                                      [9, ["(:swopen :yes)", "(:mptr :yes)"]]],
              'G9 open x ptr1': [[9, ["(:swopen :yes)", "(:mptr :yes)"]]],
              'G1 form1 x far | G9 open x ptr1': [[1, ["(:form :yes)", "(:dm :m-far)"]], [9, ["(:swopen :yes)", "(:mptr :yes)"]]]},
    'climb': {'v0': [[0, ["(:lead :behind)", "(:awst :no)"]], [0, ["(:lead :behind)", "(:awst :yes)"]], [9, ["(:swopen :no)"]]]},
}


def score(lines_by_seat, job):
    proof.sw.set_rule_base(':rb-sp2')
    jr = proof.job_rules(job)
    seq = {}
    for gi, (lines, seat) in enumerate(lines_by_seat):
        for l in lines:
            m = proof.FQRE.match(l)
            if m and m[3] == seat:
                fire = {int(k): float(v) for k, v in (x.split(':') for x in m[5].split())}
                seq.setdefault((gi, int(m[1])), []).append(min(1.0, max(sum(fire.get(r, 0.0) for r in rs) for rs in jr.values())))
    J = sum(len(s) for s in seq.values())
    anyf = sum(w > 0 for s in seq.values() for w in s)
    wsum = sum(w for s in seq.values() for w in s)
    ln = lf = 0
    on = 0
    for s in seq.values():
        seen = False
        for w in s:
            seen = seen or w > 0
            if seen:
                ln += 1; lf += w > 0
        on += any(w > 0 for w in s)
    return dict(fire=anyf / J, weight=wsum / J, lasting=lf / max(1, ln), matches_on=on / len(seq))


def main():
    row, side = sys.argv[1], int(sys.argv[2])
    t1, c1, t2, c2 = bars.ROWS[row]
    a = dict(p1=f't0final/v0/t0-{t1}.lisp', p2=f't0final/v0/t0-{t2}.lisp')
    res = proof.both_seats(c1, c2, os.path.join(A4, a['p1']), os.path.join(A4, a['p2']), 500, 40, {'STRAT_FQLOG': '0 0'}, 8)
    flip = {'P1': 'P2', 'P2': 'P1'}
    groups = [(ls, seat if side == 1 else flip[seat]) for seat, ls in res.items()]
    char = c1 if side == 1 else c2
    for arm, cands in CAND.items():
        if (arm in ('kessa2', 'keep') and char != 'ichigo') or (arm == 'range' and char != 'hisagi') or (arm == 'climb' and char != 'kenpachi'):
            continue
        for name, job in cands.items():
            r = score(groups, job)
            print(f'{row} {char:9s} {arm:7s} {name:38s} fire {r["fire"]:.3f} weight {r["weight"]:.3f} lasting {r["lasting"]:.3f} matches on {r["matches_on"]:.2f}')


if __name__ == '__main__':
    main()
