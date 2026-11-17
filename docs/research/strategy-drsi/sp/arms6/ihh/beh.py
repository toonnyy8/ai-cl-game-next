#!/usr/bin/env python3
"""beh.py — batch p10-ih-ichigo's behaviour table (arms6/ih-human.md): CPU Ichigo against human-like Hisagis, per Ichigo tier and Hisagi
opponent, both seats, through beh.lisp. Tool side only.

  python3 beh.py [--tiers easy,normal,hard] [--opps none,arm:h5-all,arm:h4-range,lookup] [--his hard] [--seed0 140] [--seeds 40]
                 [--ichigo FILE] [-j 12] [--json OUT]
-> per (tier, opponent): Ichigo's share; per minute of battle: the hits she takes (all, NAGI's string HS-N1A/B/C, the ranged J HS-R-J1-J5),
   the combos he opens on her by what she was doing (free = walking / standing, rec = her move's recovery: a whiff punished, up = her
   startup) and by his opener (NAGI, KIRI = the SA in NAGI's gap, ranged J, other), the share of those within 60 ticks of a cancel, her
   attack starts out of a free state (and those into his live move), her own combo openers; the share of his Shikai time she spends in
   NAGI's 3.1-6.0 m and of his ranged mode in 3.4-6.2 m.
Raw outputs cached in build/ihh-cache (keyed by the sim build, the runner, the env and the args).
"""
import argparse, collections, hashlib, json, os, re, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '../../../../../../tools')))
from simlib import ROOT, ROW, build, build_hash, pool, row_ko, run_lisp  # noqa: E402

RUNNER = os.path.relpath(os.path.join(HERE, 'beh.lisp'), os.path.join(ROOT, 'tools'))
CACHE = os.path.join(ROOT, 'build/ihh-cache')
TICK = re.compile(r'^\[\s*(\d+)\] (P[12]) (.*)$')
NAGI = {'HS-N1A', 'HS-N1B', 'HS-N1C'}
RJ = {'HS-R-J1', 'HS-R-J2', 'HS-R-NA3', 'HS-R-NA4', 'HS-R-J3'}


def job(j):
    seat, tier, his, opp, ich, s0, n, kset = j
    env = dict(os.environ, **{f'STRAT_DIF_P{seat}': tier, f'STRAT_DIF_P{3 - seat}': his, 'BEH_HISAGI': opp, 'BEH_ICHIGO': ich or '',
                              'BEH_SET': kset})
    cmd = [30000 + s0, 31100 + n, 81022, 200000 + (100 * 3 + 10 * 7 if seat == 1 else 100 * 7 + 10 * 3)]
    key = hashlib.sha1(json.dumps([build_hash(os.path.join(ROOT, 'tools', RUNNER)), seat, tier, his, opp,
                                   ich and open(ich).read(), cmd, kset]).encode()).hexdigest()[:20]
    path = os.path.join(CACHE, key + '.out')
    if os.path.exists(path):
        return j, open(path).read()
    r = run_lisp(RUNNER, cmd, env=env, timeout=4 * 3600)
    rows = [l for l in r.stdout.splitlines() if ROW.search(l)]
    if r.returncode or len(rows) != n:
        sys.exit(f'beh: job {j} gave {len(rows)} of {n} (exit {r.returncode}): {r.stderr[-600:]}')
    os.makedirs(CACHE, exist_ok=True)
    with open(path, 'w') as f:
        f.write(r.stdout)
    return j, r.stdout


def parse(out, seat):
    """One process -> Counter of the cell's sums (Ichigo on P<seat>)."""
    me, him = f'P{seat}', f'P{3 - seat}'
    c = collections.Counter()
    tag, cancel, last = {}, -999, None
    for l in out.splitlines():
        if l.startswith('duel match seed'):
            tag, cancel, last = {}, -999, None
            continue
        m = ROW.search(l)
        if m:
            c['n'] += 1
            c['pts'] += 1.0 if m[2] == me else 0.0 if m[2] == him else 0.5
            c['ko'] += row_ko(l)
            continue
        p = l.split()
        if not p:
            continue
        if p[0] == 'bf':
            v = list(map(int, p[3:]))
            c['ticks'] += sum(v[0::2]); c['f_base'] += v[0]; c['f_base_band'] += v[1]; c['f_bk'] += v[2]; c['f_bk_band'] += v[3]
            c['f_bind'] += v[4]
            continue
        if p[0] == 'bh' and p[3] == me:
            c['hit'] += 1
            c['hit_nagi'] += p[4] in NAGI
            c['hit_rj'] += p[4] in RJ
            c['hit_far'] += float(p[6]) >= 3.0
            continue
        if p[0] == 'bo':
            t = int(p[2])
            if p[3] == him:
                c['myopen'] += 1
                continue
            c['open'] += 1
            mv, doing = p[4], p[6]
            c['open_' + ('nagi' if mv in NAGI else 'kiri' if mv == 'HS-SA-KIRI' else 'rj' if mv in RJ else 'other')] += 1
            c['openby_' + ('free' if doing == 'free' else doing.split('-')[1].lower() if '-' in doing else 'other')] += 1
            c['open_xcancel'] += 0 <= t - cancel <= 60
            c[f'ob_{mv}/{doing}'] += 1
            if doing.endswith('-rec') and last:   # her whiff punished: which start of hers, from where, by whose choice
                c[f'wp_{last[0]}@{last[2]}:{int(last[1])}m/{last[3]}'] += 1
            tg = tag.get(me)
            c['opentag_' + (tg[1] if tg and t - tg[0] <= 90 else 'none')] += 1
            continue
        if p[0] == 'bs' and p[3] == me:
            c['start'] += 1; c['start_into'] += p[5] == '1'
            tg = tag.get(me)
            last = (p[8] if len(p) > 8 else '?', float(p[6]), p[7], tg[1] if tg and int(p[2]) - tg[0] <= 30 else 'generic')
            continue
        m = TICK.match(l)
        if m:
            t, side, rest = int(m[1]), m[2], m[3]
            if rest.endswith(': CANCEL'):
                cancel = t
            elif side == me and (rest.startswith('ki-style') or rest.startswith('cpu ')):
                w = rest.split()
                tag[me] = (t, (w[2] if w[0] == 'ki-style' else w[0] + '-' + w[1]).replace('_', '-'))
    return c


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tiers', default='easy,normal,hard')
    ap.add_argument('--opps', default='none,arm:h5-all,arm:h4-range,lookup')
    ap.add_argument('--his', default='hard')
    ap.add_argument('--seed0', type=int, default=140); ap.add_argument('--seeds', type=int, default=40)
    ap.add_argument('--ichigo'); ap.add_argument('-j', type=int, default=12); ap.add_argument('--json')
    ap.add_argument('--set', default='', help="BEH_SET: '*knob*=value;...' bound at load (beh.lisp)")
    ap.add_argument('--tags', action='store_true', help='print the openers by her last tag too')
    o = ap.parse_args()
    if o.seed0 + 1 > 800 or o.seed0 + o.seeds > 800:
        sys.exit('beh: seeds 801-1000 are held out')
    ich = o.ichigo and os.path.abspath(o.ichigo)
    build()
    jobs = [(seat, t, o.his, op, ich, o.seed0 + k, min(20, o.seeds - k), o.set) for t in o.tiers.split(',') for op in o.opps.split(',')
            for seat in (1, 2) for k in range(0, o.seeds, 20)]
    cells = collections.OrderedDict()
    for (seat, t, _, op, *_), out in pool(job, jobs, o.j):
        cells.setdefault((t, op), collections.Counter()).update(parse(out, seat))
    print(f'beh seeds {o.seed0 + 1}-{o.seed0 + o.seeds} both seats; Hisagi {o.his}; ichigo={o.ichigo or "lookup"}; set {o.set or "-"}; build '
          f'{build_hash(os.path.join(ROOT, "tools", RUNNER))[:12]}')
    print('per minute of battle (60 s); band = share of his Shikai time in 3.1-6.0 m / of his ranged mode in 3.4-6.2 m')
    hdr = ('tier   opp            share |  hit  nagi   rJ  far | open free  rec   up | o:nagi kiri  rJ  oth xcan | start into'
           ' myopen | band S  band R  R-min')
    print(hdr)
    rows = []
    for (t, op), c in cells.items():
        mins = c['ticks'] / 3600.0
        pm = lambda k: c[k] / mins  # noqa: E731
        r = dict(tier=t, opp=op, n=c['n'], share=c['pts'] / c['n'], ko=c['ko'], **{k: round(pm(k), 3) for k in (
            'hit', 'hit_nagi', 'hit_rj', 'hit_far', 'open', 'openby_free', 'openby_rec', 'openby_up', 'open_nagi', 'open_kiri', 'open_rj',
            'open_other', 'open_xcancel', 'start', 'start_into', 'myopen')},
            band_s=c['f_base_band'] / max(1, c['f_base']), band_r=c['f_bk_band'] / max(1, c['f_bk']), r_min=c['f_bk'] / 3600.0 / c['n'],
            tags={k[8:]: round(v / mins, 3) for k, v in c.items() if k.startswith('opentag_')})
        rows.append(r)
        print(f"{t:6s} {op[:14]:14s} {r['share']:.3f} | {r['hit']:4.1f} {r['hit_nagi']:5.2f} {r['hit_rj']:4.2f} {r['hit_far']:4.1f} |"
              f" {r['open']:4.2f} {r['openby_free']:4.2f} {r['openby_rec']:4.2f} {r['openby_up']:4.2f} |"
              f" {r['open_nagi']:5.2f} {r['open_kiri']:4.2f} {r['open_rj']:4.2f} {r['open_other']:4.2f} {r['open_xcancel']:4.2f} |"
              f" {r['start']:5.2f} {r['start_into']:4.2f} {r['myopen']:5.2f} | {r['band_s']:.3f}  {r['band_r']:.3f}  {r['r_min']:.2f}")
        if o.tags:
            print('    tags: ' + ', '.join(f'{k} {v:.2f}' for k, v in sorted(r['tags'].items(), key=lambda kv: -kv[1])[:10]))
            print('    openers: ' + ', '.join(f'{k[3:]} {v / mins:.2f}' for k, v in c.most_common() if k.startswith('ob_'))[:400])
            print('    whiffs punished (her start @ his form : m / her tag): ' + ', '.join(
                f'{k[3:]} {v / mins:.2f}' for k, v in c.most_common() if k.startswith('wp_'))[:500])
    if o.json:
        with open(o.json, 'w') as f:
            json.dump(dict(seed0=o.seed0, seeds=o.seeds, his=o.his, ichigo=o.ichigo, rows=rows), f, indent=1)


if __name__ == '__main__':
    main()
