#!/usr/bin/env python3
"""clash-measure.py — the clash dead-zone fix (arms5/clash.md): Hisagi's dead-zone NAGIs (base HS-N1A started < 3.0 m, attributed to the P
decision line logged before it, as kits/hisagi/probe.py does) and the K.O. wins, the shipped CPUs (their lookup) at HARD, seeds 1-50, KH HK IH HI
(Hisagi in both seats: 100 matches against each opponent).
  python3 docs/research/strategy-drsi/sp/arms5/clash-measure.py [REPO_ROOT]   (default: this checkout; a worktree of the parent commit for "before")"""
import os, re, sys, collections
ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import simlib  # noqa: E402

PROBE = 'docs/research/strategy-drsi/sp/kits/hisagi/probe.lisp'
PAIRS = {'KH': (200170, 'P2'), 'HK': (200710, 'P1'), 'IH': (200370, 'P2'), 'HI': (200730, 'P1')}
JOBS = [(p, ch) for p in PAIRS for ch in range(5)]
DEC = re.compile(r'\] (P[12]) ((?:kk|cpu|hr|hk) [a-z-]+(?: [a-z0-9-]+)?)')
MOVE = re.compile(r'\] (P[12]) move (\S+)')
END = re.compile(r'probe-end (P[12]) HS-N1A (\S+) (\S+)')

def run(job):
    p, ch = job
    code, hs = PAIRS[p]
    env = dict(os.environ, PROBE_LOG='1'); env.pop('STRAT_P1', None); env.pop('STRAT_P2', None)
    r = simlib.run_lisp('../' + PROBE, [30000 + 10 * ch, 31110, 81022, code], env=env)
    if r.returncode:
        sys.exit(r.stdout[-2000:] + r.stderr[-2000:])
    c, dec, q = collections.Counter(), {}, {'P1': [], 'P2': []}
    hko = oko = to = tw = 0
    for l in r.stdout.splitlines():
        m = simlib.ROW.search(l)
        if m:
            ko = simlib.row_ko(l)
            if ko == 0:
                to += 1; tw += m[2] == hs
            elif m[2] == hs: hko += 1
            else: oko += 1
            continue
        m = DEC.search(l)
        if m:
            dec[m[1]] = m[2]; continue
        m = MOVE.search(l)
        if m:
            if m[2].startswith('HS-N1A'):
                q[m[1]].append(dec.get(m[1]))
            dec[m[1]] = None; continue
        m = END.search(l)
        if m and q[m[1]]:
            c[(q[m[1]].pop(0) or 'other', m[2], m[3])] += 1
    return p, c, hko, oko, to, tw

def main():
    simlib.build()
    tab = collections.defaultdict(collections.Counter); ko = collections.defaultdict(lambda: [0, 0, 0, 0])
    for p, c, h, o, t, w in simlib.pool(run, JOBS, 20):
        tab[p] += c; ko[p][0] += h; ko[p][1] += o; ko[p][2] += t; ko[p][3] += w
    for p in PAIRS:
        c = tab[p]
        dz = sum(v for (d, b, o), v in c.items() if b == '<3.0')
        dzc = sum(v for (d, b, o), v in c.items() if b == '<3.0' and d.startswith('cpu clash'))
        dzk = sum(v for (d, b, o), v in c.items() if b == '<3.0' and d.startswith('kk pick'))
        tot = sum(c.values())
        print(f'{p}: Hisagi KO wins {ko[p][0]}  opp KO wins {ko[p][1]}  time-outs {ko[p][2]} (Hisagi ahead {ko[p][3]})  | NAGI {tot}, dead-zone {dz} '
              f'(clash {dzc}, kk pick {dzk}); outcomes <3.0: ' +
              str(dict(sum((collections.Counter({o: v}) for (d, b, o), v in c.items() if b == '<3.0'), collections.Counter()))))
        for k, v in sorted(c.items(), key=lambda kv: -kv[1])[:8]:
            print('   ', k, v)

main()
