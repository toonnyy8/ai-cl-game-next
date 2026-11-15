#!/usr/bin/env python3
"""jobs.py — Ichigo's arms5 job maps (:rb-sp2, PLAN4 checkpoint 2a; arms5/ichigo.md) and their vacuity scored OFFLINE (arms4/t0final/jobscore.py's
score) on judgements logged by the shipped T0 tables (arms4/t0final/t0-*.lisp, B4), seeds 501-540 both seats: the states those matches
visited, not what a new map would play. A job firing (any weight) on > 60 % of the judgements is VACUOUS (proof.py VACUOUS).
  python3 jobs.py            # KI (Ichigo P2) and IH (Ichigo P1)
  python3 jobs.py --json     # writes jobs-ki.json / jobs-ih.json here (the maps, arm ids from arms.lisp)"""
import importlib.util, json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
A4 = os.path.join(HERE, '..', '..', 'arms4')
sys.path.insert(0, os.path.join(A4, 't0final'))
_s = importlib.util.spec_from_file_location('jobscore', os.path.join(A4, 't0final', 'jobscore.py'))
js = importlib.util.module_from_spec(_s); _s.loader.exec_module(js)
proof = js.proof

# arm id -> job (a list of [group, [antecedent substrings]]; an OR over its entries). From the Situations column of kits/ichigo/strategies.md.
JOBS = {
    'a5-i-answer': [[2, ['(:ost :atk)', '(:dm :m-close)']], [5, ['(:xch :yes)']]],                      # G2 his attack x close; G5 exchange open
    'a4-i-brawl': [[2, ['(:ost :free)']]],                                                               # as shipped (B4 v1: G2 free, all distances)
    'a5-i-economy': [[3, ['(:mcell :no)', '(:ocell :yes)']], [3, ['(:mcell :no)', '(:ocell :p2up)']]],  # G3 my cells 0 x his >= 1
    # (my cells 0 alone fired on .55 (KI) / .74 (IH, VACUOUS) of the judgements: narrowed before any proof run, ichigo.md)
    'a5-i-punish': [[2, ['(:ost :atk)', '(:dm :m-mid)']], [2, ['(:ost :evade)', '(:dm :m-close)']],
                    [2, ['(:ost :evade)', '(:dm :m-mid)']]],                                             # G2 attack x mid, evade x close / mid
    'a5-i-kessa-lunge': [[1, ['(:form :yes)', '(:dm :m-mid)']], [1, ['(:form :yes)', '(:dm :m-far)']]],  # G1 awakened x mid / far (B4's narrowing)
    'a4-i-keep': [[8, ['(:time :t-late)', '(:lead :ahead)']]],                                          # T2 (KI): G8 late x ahead
    'a5-i-inside': [[1, ['(:form :no)', '(:dm :m-mid)']], [10, ['(:optr :yes)', '(:dm :m-mid)']]],      # T3 (IH): G1 sealed x mid; G10 his ptr 1 x mid
}
TABLES = {'KI': (['a4-i-all', 'a5-i-answer', 'a4-i-brawl', 'a5-i-economy', 'a5-i-punish', 'a5-i-kessa-lunge', 'a4-i-keep'], 'd-x-ki-i'),
          'IH': (['a4-i-all', 'a5-i-answer', 'a4-i-brawl', 'a5-i-economy', 'a5-i-punish', 'a5-i-kessa-lunge', 'a5-i-inside'], 'd-x-ih-i')}


def main():
    if '--json' in sys.argv:
        for row, (ids, unit) in TABLES.items():
            json.dump(dict(note=f'arms5 Ichigo {row} job map (PLAN4 checkpoint 2a; :with {unit})', arms=[f'../arms5/ichigo/arms.lisp#{i}' for i in ids],
                           jobs=[None] + [JOBS[i] for i in ids[1:]]), open(os.path.join(HERE, f'jobs-{row.lower()}.json'), 'w'), indent=1)
        return
    for row, side in (('KI', 2), ('IH', 1)):
        t1, c1, t2, c2 = js.bars.ROWS[row]
        res = proof.both_seats(c1, c2, os.path.join(A4, f't0final/t0-{t1}.lisp'), os.path.join(A4, f't0final/t0-{t2}.lisp'), 500, 40,
                               {'STRAT_FQLOG': '0 0'}, 8)
        flip = {'P1': 'P2', 'P2': 'P1'}
        groups = [(ls, seat if side == 1 else flip[seat]) for seat, ls in res.items()]
        for aid in TABLES[row][0][1:]:
            r = js.score(groups, JOBS[aid])
            print(f'{row} {aid:18s} fire {r["fire"]:.3f} weight {r["weight"]:.3f} lasting {r["lasting"]:.3f} matches on {r["matches_on"]:.2f}'
                  + ('  VACUOUS' if r['fire'] > proof.VACUOUS else ''))


if __name__ == '__main__':
    main()
