#!/usr/bin/env python3
"""run.py — PLAN.md §7 step 2's 3 x 3 baseline under SP (DUEL_AI_STRATEGY §11): every ordered pairing of Kenpachi, Ichigo, Hisagi (the
mirrors included), HARD, held-out seeds 601-800 (debug 30600 + 25 i, 25 a sim process), two conditions:
  none    both seats with no strategy at all (STRAT_P1=none STRAT_P2=none: the shipped CPU, BRAIN-STRAT NIL)
  lookup  both seats on the shipped HARD *strat-lookup* (no STRAT_ variable)
From the repo root: python3 docs/research/strategy-drsi/sp/baseline/run.py [-j 6]  -> baseline.json here (the per-match rows too).
The matches are tools/strategy-switch.py's own (its run_job and cache, build/strategy-eval-cache/)."""
import importlib.util, json, os, re, statistics, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../../..'))
sp = importlib.util.spec_from_file_location('ss', os.path.join(ROOT, 'tools/strategy-switch.py'))
ss = importlib.util.module_from_spec(sp); sp.loader.exec_module(ss)

CHARS = ('kenpachi', 'ichigo', 'hisagi')
SEED0, SEEDS = 600, 200
COND = {'none': (('P1', 'none', 'none'), ('P2', 'none', ['none'])), 'lookup': (None, None)}


def rows(out):
    """-> [(seed, secs, winner, ko, the RESULTS konpaku pair)] of one sim output, and its `strat` lines' ids."""
    res, kp = [], None
    for line in out.splitlines():
        m = re.match(r'duel -> RESULTS winner \S+ konpaku (\d+)-(\d+)', line)
        if m:
            kp = (int(m[1]), int(m[2]))
            continue
        m = re.match(r'duel gate row seed (\d+) \S+ \S+ secs ([\d.]+) winner (\S+) .* ko ([01])$', line)
        if m:
            res.append((int(m[1]), float(m[2]), m[3], int(m[4]), kp))
    return res, sorted(set(re.findall(r'^strat (P[12] \S+)', out, re.M)))


def main():
    j = int(sys.argv[sys.argv.index('-j') + 1]) if '-j' in sys.argv else 6
    ss.build()
    jobs = [(cond, c1, c2, s0) for cond in COND for c1 in CHARS for c2 in CHARS for s0 in range(SEED0, SEED0 + SEEDS, ss.CHUNK)]
    outs = ss.pool(lambda x: ss.run_job(ss.ROSTER[x[1]], ss.ROSTER[x[2]], COND[x[0]][0], 2, x[3], ss.CHUNK, COND[x[0]][1]), jobs, j)
    got = {}
    for (cond, c1, c2, _), out in zip(jobs, outs):
        r, strat = rows(out)
        g = got.setdefault((cond, c1, c2), dict(rows=[], strat=set()))
        g['rows'] += r; g['strat'] |= set(strat)
    table = []
    for (cond, c1, c2), g in got.items():
        rs = sorted(g['rows'])
        n = len(rs)
        assert n == SEEDS, (cond, c1, c2, n)
        assert all((ko == 0) == (secs >= 300.0) for _, secs, _, ko, _ in rs), (cond, c1, c2, 'ko vs secs')
        ko1 = sum(ko and w == 'P1' for _, _, w, ko, _ in rs); ko2 = sum(ko and w == 'P2' for _, _, w, ko, _ in rs)
        table.append(dict(cond=cond, p1=c1, p2=c2, matches=n, ko_p1=ko1, ko_p2=ko2,
                          timeouts=sum(ko == 0 for *_, ko, _ in rs),
                          timeout_wins_p1=sum(ko == 0 and w == 'P1' for _, _, w, ko, _ in rs),
                          timeout_wins_p2=sum(ko == 0 and w == 'P2' for _, _, w, ko, _ in rs),
                          draws=sum(w == 'DRAW' for _, _, w, _, _ in rs),
                          bell_drains=sum(ko == 0 and 0 in kp for *_, ko, kp in rs),   # Konpaku 0 at the bell (a bind drained): a time-out
                          median_secs=statistics.median(secs for _, secs, *_ in rs),
                          score_p1=round((ko1 + 1) / (n + 2), 4), score_p2=round((ko2 + 1) / (n + 2), 4),
                          strat=sorted(g['strat']), rows=[list(r[:4]) for r in rs]))
    json.dump(dict(seed0=SEED0, seeds=SEEDS, diff='hard', build=ss.build_hash(), table=table),
              open(os.path.join(HERE, 'baseline.json'), 'w'), indent=None, separators=(',', ':'))
    for t in table:
        print(f"{t['cond']:6} {t['p1'][0].upper()}{t['p2'][0].upper()} n {t['matches']} KO {t['ko_p1']}:{t['ko_p2']} TO {t['timeouts']} "
              f"(leads {t['timeout_wins_p1']}:{t['timeout_wins_p2']}) draws {t['draws']} drains {t['bell_drains']} median {t['median_secs']} "
              f"score {t['score_p1']}/{t['score_p2']} strat {t['strat']}")


if __name__ == '__main__':
    main()
