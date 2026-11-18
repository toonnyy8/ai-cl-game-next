#!/usr/bin/env python3
"""dmgsrc.py — where the damage and the Konpaku come from in CPU vs CPU matches (the user, 2026-11-18: 「好」 to measuring why the arms
differ so little: is the outcome decided in the exchange after a cancel or in neutral?).

Runs tools/simgate/strat-run.lisp's pairing gate with STRAT_CLOG=1 (the combat log on; play unchanged) and reads the CLOG lines:
- a combo = A's hits on V with no gap above GAP ticks and no hit of V on A in between; its opener's context:
  `xch`  an exchange is open at the opener (a CANCEL, or a cancelled Kikon follow-up, and no `exchange over` since): the breakthrough's hit;
  `neu`  otherwise (neutral: a poke, a whiff punish, a triangle win from neutral).
- Reishi: every `dealt D` line, summed by its combo's opener context.
- Konpaku: every `SOUL BREAK on` / `KIKON on` line (-N konpaku), by kind and by the context of the combo it ended.
- --split (q3-xch, sp/arms6/xch.md): `xch` split at the `BREAK` line into `brk` (the combo the breakthrough's hit opened) and `scr` (a
  combo opened later in the still open exchange: the scramble after the break, or the next cancel's).
  usage: dmgsrc.py [--pairs KK,KI,KH,II,IH,HH] [--seed0 600] [--seeds 20] [--dif hard] [-j 12] [--split]
Seeds: never 801-1000 (PLAN4's final block)."""
import argparse, collections, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../tools')))
from simlib import build, pool, run_lisp

ROSTER = {'K': 1, 'I': 3, 'H': 7}
GAP = 90
TICK = re.compile(r'^\[ *(\d+)\] (.*)$')
DEALT = re.compile(r'^P(\d) dealt (\d+):')
BRK = re.compile(r'^P(\d) BREAK fs ')
KON = re.compile(r'^P(\d) (SOUL BREAK|KIKON) on P(\d): -(\d+) konpaku')


def job(j):
    a, b, s0, n, dif = j
    env = dict(os.environ, STRAT_DIF_P1=dif, STRAT_DIF_P2=dif, STRAT_CLOG='1')
    r = run_lisp('simgate/strat-run.lisp', [30000 + s0, 31100 + n, 81022, 200000 + 100 * ROSTER[a] + 10 * ROSTER[b]], env=env, timeout=6 * 3600)
    return j, r.stdout


def parse(out, split=False):
    """-> per match: dict(dmg={ctx: reishi}, kon=[(kind, ctx, n)], combos={ctx: count}, winner)."""
    matches, m = [], None
    for line in out.splitlines():
        if line.startswith('duel match seed'):
            m = dict(dmg=collections.Counter(), kon=[], combos=collections.Counter(), cl=[], xch=False, last={}, ctx={}, winner=None)
            matches.append(m)
            continue
        if m is None:
            continue
        if line.startswith('duel -> RESULTS winner'):
            m['winner'] = line.split()[4]
            continue
        t = TICK.match(line)
        if not t:
            continue
        tick, body = int(t[1]), t[2]
        if ': CANCEL' in body or 'cancels the Kikon' in body:
            m['xch'] = True
        elif body == 'exchange over':
            m['xch'] = False
        d = DEALT.match(body)
        if d:
            att, dmg = d[1], int(d[2])
            vic = '2' if att == '1' else '1'
            last = m['last'].get(att)
            if last is None or tick - last > GAP or m['last'].get(vic, -1) > last:   # a new combo
                m['ctx'][att] = {'ctx': 'xch' if m['xch'] else 'neu', 'start': tick, 'dmg': 0}
                m['cl'].append(m['ctx'][att])
            m['last'][att] = tick
            m['ctx'][att]['dmg'] += dmg
            continue
        b = BRK.match(body)
        if b:   # the breakthrough's hit (logged after its dealt line, same tick) opened its combo: --split's brk
            c = m['ctx'].get(b[1])
            if c and c['start'] == tick and c['ctx'] == 'xch':
                c['ctx'] = 'brk'
            continue
        k = KON.match(body)
        if k:
            m['kon'].append((k[2], m['ctx'].get(k[1], {'ctx': 'neu'}), int(k[4])))

    def ctx(c):   # split: xch = brk (the break hit's combo) + scr (a combo opened later in the open exchange); else brk counts as xch
        x = c['ctx']
        return ('scr' if x == 'xch' else x) if split else ('xch' if x == 'brk' else x)
    for m in matches:
        for c in m['cl']:
            m['dmg'][ctx(c)] += c['dmg']
            m['combos'][ctx(c)] += 1
        m['kon'] = [(kind, ctx(c), n) for kind, c, n in m['kon']]
    return matches


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pairs', default='KK,KI,KH,II,IH,HH')
    ap.add_argument('--seed0', type=int, default=600)
    ap.add_argument('--seeds', type=int, default=20)
    ap.add_argument('--dif', default='hard')
    ap.add_argument('-j', type=int, default=12)
    ap.add_argument('--split', action='store_true', help='split the xch bucket at the BREAK line (brk / scr)')
    o = ap.parse_args()
    assert o.seed0 + o.seeds <= 800 or o.seed0 >= 1000, 'seeds 801-1000 are the final block'
    build()
    jobs = []
    for p in o.pairs.split(','):
        for s in range(0, o.seeds, 10):
            jobs.append((p[0], p[1], o.seed0 + s, min(10, o.seeds - s), o.dif))
    per = collections.defaultdict(list)
    if o.split:   # (q3-xch, arms6/xch.md: the xch bucket split at the BREAK line)
        print(f'dmgsrc --split {o.dif} vs {o.dif}, seeds {o.seed0 + 1}-{o.seed0 + o.seeds}: brk = the combo the breakthrough hit opened, '
              f'scr = a combo opened later in the open exchange, neu = neutral')
        print('pair |  n | reishi brk / scr / neu % | combos brk / scr / neu | konpaku brk / scr / neu %')
        for (a, b, s0, n, dif), out in pool(job, jobs, o.j):
            per[a + b] += parse(out, True)
        for p, ms in per.items():
            d = sum((m['dmg'] for m in ms), collections.Counter())
            c = sum((m['combos'] for m in ms), collections.Counter())
            k = collections.Counter()
            for m in ms:
                for _, x, n in m['kon']:
                    k[x] += n
            td, tk = max(1, sum(d.values())), max(1, sum(k.values()))
            print(f"{p}   | {len(ms):2d} | {100 * d['brk'] / td:4.1f} / {100 * d['scr'] / td:4.1f} / {100 * d['neu'] / td:4.1f} | "
                  f"{c['brk']} / {c['scr']} / {c['neu']} | {100 * k['brk'] / tk:4.1f} / {100 * k['scr'] / tk:4.1f} / {100 * k['neu'] / tk:4.1f}")
        return
    for (a, b, s0, n, dif), out in pool(job, jobs, o.j):
        ms = parse(out)
        if len(ms) != n:
            sys.exit(f'dmgsrc: {a}{b} seeds {s0 + 1}-{s0 + n}: {len(ms)} matches')
        per[a + b] += ms
    print(f'dmgsrc {o.dif} vs {o.dif}, seeds {o.seed0 + 1}-{o.seed0 + o.seeds}, both CPUs; combo gap {GAP} ticks')
    print('pair |  n | reishi xch / neu (xch %) | combos xch / neu | dmg a combo xch / neu | konpaku: SB / Kikon (Kikon %), '
          'from xch combos % | events a match')
    tot = collections.Counter()
    for p, ms in per.items():
        d = sum((m['dmg'] for m in ms), collections.Counter())
        c = sum((m['combos'] for m in ms), collections.Counter())
        sb = sum(n for m in ms for k, _, n in m['kon'] if k == 'SOUL BREAK')
        kk = sum(n for m in ms for k, _, n in m['kon'] if k == 'KIKON')
        kx = sum(n for m in ms for _, ctx, n in m['kon'] if ctx == 'xch')
        ev = sum(len(m['kon']) for m in ms) / len(ms)
        for key, v in (('dx', d['xch']), ('dn', d['neu']), ('cx', c['xch']), ('cn', c['neu']), ('sb', sb), ('kk', kk), ('kx', kx),
                       ('ev', sum(len(m['kon']) for m in ms)), ('n', len(ms))):
            tot[key] += v
        print(f"{p}   | {len(ms):2d} | {d['xch']:6d} / {d['neu']:6d} ({100 * d['xch'] / max(1, d['xch'] + d['neu']):4.1f} %) | "
              f"{c['xch']:4d} / {c['neu']:4d} | {d['xch'] / max(1, c['xch']):5.1f} / {d['neu'] / max(1, c['neu']):5.1f} | "
              f"{sb:3d} / {kk:3d} ({100 * kk / max(1, sb + kk):4.1f} %), {100 * kx / max(1, sb + kk):4.1f} % | {ev:.1f}")
    t = tot
    print(f"all  | {t['n']:3d} | {t['dx']:6d} / {t['dn']:6d} ({100 * t['dx'] / max(1, t['dx'] + t['dn']):4.1f} %) | {t['cx']:4d} / {t['cn']:4d} | "
          f"{t['dx'] / max(1, t['cx']):5.1f} / {t['dn'] / max(1, t['cn']):5.1f} | {t['sb']:3d} / {t['kk']:3d} "
          f"({100 * t['kk'] / max(1, t['sb'] + t['kk']):4.1f} %), {100 * t['kx'] / max(1, t['sb'] + t['kk']):4.1f} % | {t['ev'] / t['n']:.1f}")


if __name__ == '__main__':
    main()
