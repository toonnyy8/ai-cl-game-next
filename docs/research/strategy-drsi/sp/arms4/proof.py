#!/usr/bin/env python3
"""proof.py — PLAN4 §3's one-job proof of an arm, and bar A's switching measures of a table (PLAN4 §1 A), over tools/simgate/strat-run.lisp.

  python3 proof.py desc --me C --vs D --arms ichigo.lisp --with x-units/d-x-ki-i.lisp [--ids a4-i-all,...] [--seed0 0] [--seeds 100] [-j 20]
      Each arm (arm 0 = the file's first) played whole against D's `none`, HARD, both seats, seeds seed0+1..seed0+seeds (200 matches at 100),
      as T0 plays it: a 1-arm :rb-sp2 table with keep-state, period 30 and the pairing's :with unit (band.py's writer, sw.write_table).
      Per arm: the descriptor vector (STRAT_DESC's counters, per match), its difference from arm 0, the K.O. rate (any K.O.; must be
      >= 0.50, PLAN4 §3.3) and the K.O.-win share, the pre-registered test (TESTS), distinctness from the siblings (TOL). Writes
      proof/<me>-vs-<vs>.json; prints a table.
  python3 proof.py t0 --me C --vs D --map t0/X.json --out t0/X.lisp [--with UNIT] [--or] [--q 0.06]
      band.py t0 over a map whose arms are "FILE#id" (an arm of an arms file here) or "none".
  python3 proof.py bar --p1 TABLE --p1map MAP --p2 TABLE --p2map MAP --c1 C --c2 D [--seeds 501-540] [-j 20]
      Two tables against each other on both seats (C's table on P1 first, then on P2: 2 x seeds matches), every judgement logged
      (STRAT_FQLOG eps 0: play unchanged). Per side: arm changes a match (median, zero), judgements, arm shares, each arm's share inside vs
      outside its job rules (the map's jobs; a job over several groups is an OR: a judgement's in-job weight = the largest of its groups'
      summed job-rule firing), K.O. rate; bar A's four checks.
Seeds: dev only (1-600). 601-1000 refused. Sim output cached in build/arms4-cache/ by (sim build hash, runner, env texts, commands).
"""
import argparse, hashlib, importlib.util, json, os, re, statistics, sys, types
from concurrent.futures import ThreadPoolExecutor
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import simlib  # noqa: E402

_s = importlib.util.spec_from_file_location('band', os.path.join(HERE, '..', 'band.py'))
band = importlib.util.module_from_spec(_s); _s.loader.exec_module(band)
sw, ss = band.sw, band.ss
CACHE = os.path.join(ROOT, 'build/arms4-cache')
WORK = os.path.join(ROOT, 'build/arms4')
HARD = 2
KEEP = ('desc ', 'duel gate row ', 'fq ', 'strat ')

# Pre-registered (written before the first proof run, ichigo.md / kenpachi.md): arm id -> (descriptor, op, amount) against arm 0.
# '+': value >= arm 0's + amount; '-': value <= arm 0's - amount; 'x': value >= arm 0's x amount; 'x<': value <= arm 0's x amount.
# A list: every part must pass.
TESTS = {
    # Ichigo's code cell (B3, 2026-11-15; registered in ichigo.md §"Re-jobbed arms" before the seeds 1-100 run)
    'a4-i-brawl': ('close', '+', 0.10), 'a4-i-keep': [('p2', '+', 0.20), ('mean_d', '+', 0.5)], 'a4-i-kessa2': ('k_d', '-', 0.30),
    'a4-i-whiff': ('mid', '+', 0.05), 'a4-i-space': ('mean_d', '+', 0.5), 'a4-i-ptr3': ('p3', '+', 0.10), 'a4-i-kessa': ('awk', '+', 0.05),
    'a4-k-rush': ('close', '+', 0.10), 'a4-k-guard': ('evade', 'x', 1.3), 'a4-k-spend': ('spend', 'x', 1.5),
    'a4-k-climb': ('bankai', '+', 0.05), 'a4-k-bait': ('wake_kd', 'x<', 0.5), 'a4-k-wave': ('evade', 'x', 1.2),
}
# Distinctness tolerance (pre-registered): two arms are NOT distinct when within these of each other on every descriptor.
# ('abs', t): |a - b| <= t; ('rel', t): |a - b| <= t x max(|a|, |b|, 1) (counts a match).
TOL = {'mean_d': ('abs', 0.25), 'close': ('abs', 0.03), 'mid': ('abs', 0.03), 'far': ('abs', 0.03), 'awk': ('abs', 0.03),
       'p3': ('abs', 0.05), 'bankai': ('abs', 0.03), 'released': ('abs', 0.03),
       'sp': ('rel', 0.15), 'burst': ('rel', 0.15), 'kikon': ('rel', 0.15), 'spend': ('rel', 0.15), 'wake_kd': ('rel', 0.15),
       'evade': ('rel', 0.15), 'acts': ('rel', 0.15), 'clash': ('rel', 0.15),
       # Ichigo's code cell (B3, pre-registered in ichigo.md before its proof run): pointer 2's share, move starts into his neutral, SP moves
       # per 1000 awakened steps (pooled)
       'p2': ('abs', 0.05), 'nstart': ('rel', 0.15), 'k_sp': ('rel', 0.15), 'k_d': ('abs', 0.25)}
DESC = list(TOL)
# Hisagi's arms (B3 cells, cells-h; pre-registered in hisagi.md §5 before any cell or proof run). A cell's winner keeps its slot's id.
TESTS.update({'h4-press': ('close', '+', 0.10), 'h4-kite': ('mean_d', '+', 0.5), 'h4-range': [('mean_d', '+', 0.5), ('bankai', '+', 0.10)],
              'h4-wake': ('wake_kd', 'x', 1.3), 'h4-hoho6': ('evade', 'x', 1.3), 'h4-ihx': ('nstart', 'x', 1.2)})


def forms(path):
    """An arms file -> {id (no colon): one-line plist}, in file order."""
    t = ss.strip_lisp(open(path).read())
    out, i = {}, 0
    while True:
        i = t.find('(', i)
        if i < 0:
            return out
        j = ss.form_end(t, i)
        x = ' '.join(t[i:j].split())
        out[re.search(r':id\s+:([^\s()]+)', x)[1].lower()] = x
        i = j


def arm_ref(ref):
    """'FILE#id' (FILE relative to here) -> an arm file under build/arms4 holding that plist; 'none' stays."""
    if ref == 'none':
        return ref
    f, aid = ref.split('#')
    os.makedirs(WORK, exist_ok=True)
    p = os.path.join(WORK, f'{aid}.lisp')
    with open(p, 'w') as o:
        o.write(forms(os.path.join(HERE, f))[aid] + '\n')
    return p


def write_table(me, vs, arms, q, out, with_files, note, margin=0.02):
    """sw.write_table on :rb-sp2 with ARMS (one-line plists), Q (104 x n) and the :with unit files."""
    sw.set_rule_base(':rb-sp2')
    sw.ARMS, sw.NA, sw.MEN, sw.VSN, sw.RB, sw.EVENT = arms, len(arms), me, vs, ':rb-sp2', None
    w = [sw.unit_text(os.path.relpath(os.path.abspath(x), sw.HERE)) for x in with_files]
    sw.write_table(out, ':' + os.path.splitext(os.path.basename(out))[0], q, note, period=30, gamma=0.966, scale=0.1, keep=True,
                   margin=margin, with_=w)


def seeds_ok(lo, hi):
    if lo < 1 or hi > 600:
        sys.exit(f'proof: seeds {lo}-{hi}: dev seeds 1-600 only (PLAN4 §1: 601-800 spent, 801-1000 the final)')


def run(c1, c2, env, seed0, n):
    """One sim process (cached): roster c1 (P1) vs c2 (P2), HARD, seeds seed0+1..seed0+n; ENV = the STRAT_ variables (file paths: their
    texts go into the key). -> the kept lines."""
    simlib.build()
    texts = {k: (open(v).read() if os.path.isfile(v) else v) for k, v in sorted(env.items())}
    cmds = [30000 + seed0, 31100 + n, 81020 + HARD, 200000 + 100 * c1 + 10 * c2]
    key = hashlib.sha1(json.dumps([simlib.build_hash(os.path.join(ROOT, 'tools/simgate/strat-run.lisp')), texts, cmds]).encode()).hexdigest()[:20]
    path = os.path.join(CACHE, key + '.out')
    if os.path.exists(path):
        return open(path).read().splitlines()
    e = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    e.update(env)
    r = simlib.run_lisp('simgate/strat-run.lisp', cmds, e, timeout=7200)
    keep = [l for l in r.stdout.splitlines() if l.startswith(KEEP)]
    rows = sum(l.startswith('duel gate row ') for l in keep)
    if r.returncode or rows != n:
        sys.exit(f'proof: sim exited {r.returncode}, {rows} of {n} rows\n' + (r.stdout + r.stderr)[-2000:])
    if 'STRAT_DESC' in env and sum(l.startswith('desc ') for l in keep) != 2 * n:
        sys.exit(f'proof: {sum(l.startswith("desc ") for l in keep)} desc lines for {n} matches (2 a match expected)')
    os.makedirs(CACHE, exist_ok=True)
    with open(path + '.tmp', 'w') as f:
        f.write('\n'.join(keep) + '\n')
    os.replace(path + '.tmp', path)
    return keep


def chunks(seed0, n, size=25):
    return [(seed0 + s, min(size, n - s)) for s in range(0, n, size)]


def both_seats(me, vs, mine, theirs, seed0, n, extra, j, dif=None):
    """MINE on ME's seat, THEIRS (a file or none) on VS's, both seats; DIF: ME's difficulty (STRAT_DIF_P<n>; default the gate's HARD).
    -> {seat: [lines]} (seat = ME's)."""
    R = ss.ROSTER
    jobs = []
    for seat in ('P1', 'P2'):
        other = 'P2' if seat == 'P1' else 'P1'
        c1, c2 = (R[me], R[vs]) if seat == 'P1' else (R[vs], R[me])
        for s0, k in chunks(seed0, n):
            env = dict(extra, **{'STRAT_' + seat: mine, 'STRAT_' + other: theirs})
            if dif:
                env['STRAT_DIF_' + seat] = dif
            jobs.append((seat, c1, c2, env, s0, k))
    with ThreadPoolExecutor(max(1, min(22, j))) as ex:
        outs = list(ex.map(lambda x: run(x[1], x[2], x[3], x[4], x[5]), jobs))
    res = {'P1': [], 'P2': []}
    for x, o in zip(jobs, outs):
        res[x[0]] += o
    return res


ROWRE = re.compile(r'duel gate row seed (\d+) \S+ \S+ secs [\d.]+ winner (\S+).* ko ([01])$')


def rows(lines):
    """-> {seed: (winner, ko)}"""
    return {int(m[1]): (m[2], int(m[3])) for m in map(ROWRE.search, lines) if m}


def desc_vec(line):
    """A desc line -> the descriptor dict of that match and side."""
    p = line.split()
    kv = {p[i]: int(p[i + 1]) for i in range(3, p.index('form'), 2)}
    fm = {x.split(':')[0]: int(x.split(':')[1]) for x in p[p.index('form') + 1:]}
    st = max(1, kv['steps'])
    return dict(mean_d=kv['dsum'] / 1000.0 / st, close=kv['close'] / st, far=kv['far'] / st, mid=1 - (kv['close'] + kv['far']) / st,
                awk=kv['awk'] / st, p3=kv['p3'] / st, p2=kv.get('p2', 0) / st, nstart=kv.get('nstart', 0), asp=kv.get('asp', 0), adsum=kv.get('adsum', 0), awk_n=kv['awk'], bankai=fm.get('bankai', 0) / st, released=1 - fm.get('base', 0) / st,
                sp=kv['sp'], burst=kv['burst'], kikon=kv['kikon'], spend=kv['burst'] + kv['kikon'], kd=kv['kd'], wake=kv['wake'],
                evade=kv['evade'], acts=kv['acts'], clash=kv['clash'], steps=kv['steps'])


def arm_desc(res):
    """{seat: lines} -> the arm's per-match means, K.O. rate, K.O.-win share, matches."""
    ms, ko, kow = [], 0, 0
    for seat, lines in res.items():
        rw = rows(lines)
        for l in lines:
            if l.startswith('desc ') and l.split()[2] == seat:
                ms.append(desc_vec(l))
        ko += sum(k for _, k in rw.values())
        kow += sum(1 for w, k in rw.values() if k and w == seat)
    n = len(ms)
    out = {k: statistics.fmean(m[k] for m in ms) for k in DESC if k not in ('wake_kd', 'k_sp', 'k_d')}
    out['k_d'] = sum(m['adsum'] for m in ms) / 1000.0 / max(1, sum(m['awk_n'] for m in ms))   # (pooled: mean distance of the awakened steps)
    out['k_sp'] = 1000.0 * sum(m['asp'] for m in ms) / max(1, sum(m['awk_n'] for m in ms))   # (pooled: SP moves per 1000 awakened steps)
    out['wake_kd'] = sum(m['wake'] for m in ms) / max(1, sum(m['kd'] for m in ms))   # (pooled: presses per knockdown of his)
    out.update(matches=n, ko_rate=ko / max(1, n), ko_win=kow / max(1, n))
    return out


def test(aid, d, d0):
    if aid not in TESTS:
        return None
    t = TESTS[aid]
    if isinstance(t, list):
        parts = [test1(x, d, d0) for x in t]
        return dict(desc='+'.join(x['desc'] for x in parts), parts=parts, ok=all(x['ok'] for x in parts))
    return test1(t, d, d0)


def test1(t, d, d0):
    k, op, amt = t
    ok = {'+': d[k] >= d0[k] + amt, '-': d[k] <= d0[k] - amt, 'x': d[k] >= d0[k] * amt, 'x<': d[k] <= d0[k] * amt}[op]
    return dict(desc=k, op=op, amount=amt, value=round(d[k], 4), arm0=round(d0[k], 4), ok=bool(ok))


def close_on_all(a, b):
    for k, (kind, t) in TOL.items():
        lim = t if kind == 'abs' else t * max(abs(a[k]), abs(b[k]), 1.0)
        if abs(a[k] - b[k]) > lim:
            return False
    return True


def cmd_desc(a):
    seeds_ok(a.seed0 + 1, a.seed0 + a.seeds)
    arms = forms(os.path.join(HERE, a.arms))
    ids = a.ids.split(',') if a.ids else list(arms)
    a0 = next(iter(arms))
    if a0 not in ids:
        ids = [a0] + ids
    os.makedirs(WORK, exist_ok=True)
    os.dup2(os.open(os.devnull, os.O_RDONLY), 0)
    out = {}
    import numpy as np
    for aid in ids:
        t = os.path.join(WORK, f'one-{a.me}-{a.vs}-{aid}.lisp')
        write_table(a.me, a.vs, [arms[aid]], np.zeros((104, 1)), t, a.with_ or [],
                    f'proof.py: {aid} whole (a 1-arm table: as T0 plays it), :with {" ".join(a.with_ or []) or "none"}')
        out[aid] = arm_desc(both_seats(a.me, a.vs, t, 'none', a.seed0, a.seeds, {'STRAT_DESC': '1'}, a.j, a.dif))
        print(f'{aid}: {out[aid]["matches"]} matches, K.O. {out[aid]["ko_rate"]:.3f}', file=sys.stderr, flush=True)
    d0 = out[a0]
    sheet = {}
    for aid in ids:
        d = out[aid]
        sheet[aid] = dict(desc={k: round(d[k], 4) for k in DESC}, delta={k: round(d[k] - d0[k], 4) for k in DESC},
                          ko_rate=round(d['ko_rate'], 3), ko_win=round(d['ko_win'], 3), ko_ok=d['ko_rate'] >= 0.5, matches=d['matches'],
                          test=test(aid, d, d0), not_distinct_from=[b for b in ids if b != aid and close_on_all(d, out[b])])
    os.makedirs(os.path.join(HERE, 'proof'), exist_ok=True)
    dst = os.path.join(HERE, 'proof', f'{a.me}-vs-{a.vs}' + (f'-{a.dif}' if a.dif else '') + (f'-{a.tag}' if a.tag else '') + '.json')   # (--dif: a diagnostic, the proof is HARD)
    json.dump(dict(me=a.me, vs=a.vs, opp='none', dif=a.dif or 'hard', seeds=f'{a.seed0 + 1}-{a.seed0 + a.seeds} both seats', with_=a.with_,
                   build=simlib.build_hash(os.path.join(ROOT, 'tools/simgate/strat-run.lisp'))[:12], arms=sheet), open(dst, 'w'), indent=1)
    cols = ['mean_d', 'close', 'mid', 'far', 'p2', 'p3', 'awk', 'bankai', 'sp', 'spend', 'evade', 'wake_kd', 'nstart', 'k_sp', 'k_d', 'acts', 'clash']
    print(f'{a.me} vs {a.vs} none, {d0["matches"]} matches an arm  ({os.path.relpath(dst, HERE)})')
    print('arm'.ljust(12) + ''.join(c.rjust(8) for c in cols) + '     K.O.  KOwin  test')
    for aid in ids:
        s = sheet[aid]
        vals = s['desc'] if aid == a0 else s['delta']
        tt = s['test']
        print(aid[3:].ljust(12) + ''.join(f'{vals[c]:8.3f}' for c in cols) + f'  {s["ko_rate"]:6.3f} {s["ko_win"]:6.3f}  '
              + ('' if tt is None else f'{tt["desc"]} {"PASS" if tt["ok"] else "FAIL"}') + (' K.O.<.5' if not s['ko_ok'] else '')
              + (f' ~{",".join(x[3:] for x in s["not_distinct_from"])}' if s['not_distinct_from'] else ''))
    print('(arm 0 row: values; the others: differences from arm 0)')


def cmd_t0(a):
    m = json.load(open(os.path.join(HERE, a.map)))
    os.makedirs(WORK, exist_ok=True)
    tmp = os.path.join(WORK, 'map-' + os.path.basename(a.map))
    json.dump(dict(m, arms=[arm_ref(x) for x in m['arms']]), open(tmp, 'w'))
    band.cmd_t0(types.SimpleNamespace(me=a.me, vs=a.vs, map=tmp, out=os.path.join(HERE, a.out), q=a.q, or_=a.or_, with_=a.with_,
                                      margin=0.02, period=30))


def job_rules(job):
    """A map's job [[G, [substrings]], ...] -> {group: [rule indices]} on :rb-sp2 (band.cmd_t0's matching)."""
    out = {}
    for r, (ante, g) in enumerate(sw.RULES):
        for gg, subs in job:
            if g == gg and all(s in ante for s in subs):
                out.setdefault(g, []).append(r)
    return {g: sorted(set(v)) for g, v in out.items()}


FQRE = re.compile(r'^fq (\d+) (\d+) (P\d) .* arm (\d+) h .* fire(.*)$')


def side_bar(groups, jobs):
    """One side's fq lines, GROUPS = [(lines, its seat in them), ...] (one a seat run) -> bar A's numbers."""
    sw.set_rule_base(':rb-sp2')
    jr = [None if j is None else job_rules(j) for j in jobs]
    na = len(jobs)
    seq = {}
    for gi, (lines, seat) in enumerate(groups):
        for l in lines:
            m = FQRE.match(l)
            if m and m[3] == seat:
                fire = {int(k): float(v) for k, v in (x.split(':') for x in m[5].split())}
                x = re.search(r' dm (\S+) form (\d)', l)
                seq.setdefault((gi, int(m[1])), []).append((int(m[4]), fire, f'f{x[2]}-{sw.band(float(x[1]))}' if x else '?'))
    ch = [sum(1 for i in range(1, len(s)) if s[i][0] != s[i - 1][0]) for s in seq.values()]
    held = [0] * na
    inn, inw, out_, outw = [0.0] * na, [0.0] * na, [0.0] * na, [0.0] * na
    by = {}
    for s in seq.values():
        for arm, fire, fb in s:
            held[arm] += 1
            by.setdefault(fb, [0] * na)[arm] += 1
            for k in range(1, na):
                w = min(1.0, max(sum(fire.get(r, 0.0) for r in rs) for rs in jr[k].values()))
                inw[k] += w; outw[k] += 1 - w
                if arm == k:
                    inn[k] += w; out_[k] += 1 - w
    J = sum(held)
    share = [h / max(1, J) for h in held]
    job = {}
    for k in range(1, na):
        si, so = inn[k] / max(1e-9, inw[k]), out_[k] / max(1e-9, outw[k])
        job[k] = dict(in_share=round(si, 4), out_share=round(so, 4), ratio=round(si / so, 2) if so > 0 else None, in_weight=round(inw[k] / max(1, J), 3),
                      ok=si >= 2 * so and si > 0)
    big = sum(1 for x in share if x >= 0.10)
    res = dict(matches=len(seq), judgements_per_match=round(J / max(1, len(seq)), 1),
               changes=dict(median=statistics.median(ch) if ch else 0, mean=round(statistics.fmean(ch), 1) if ch else 0, zero=sum(c == 0 for c in ch)),
               arm_share=[round(x, 3) for x in share], job=job,
               by_form_band={k: dict(n=sum(v), share=[round(x / sum(v), 3) for x in v]) for k, v in sorted(by.items())})
    res['A'] = dict(no_zero=res['changes']['zero'] == 0, median_10=res['changes']['median'] >= 10, three_arms=big >= 3 and max(share) <= 0.70,
                    division=all(v['ok'] for v in job.values()))
    return res


def cmd_bar(a):
    lo, hi = (int(x) for x in a.seeds.split('-'))
    seeds_ok(lo, hi)
    os.dup2(os.open(os.devnull, os.O_RDONLY), 0)
    t1, t2 = os.path.join(HERE, a.p1), os.path.join(HERE, a.p2)
    j1, j2 = (json.load(open(os.path.join(HERE, x)))['jobs'] for x in (a.p1map, a.p2map))
    res = both_seats(a.c1, a.c2, t1, t2, lo - 1, hi - lo + 1, {'STRAT_FQLOG': '0 0'}, a.j)   # (C1's table on P1, then on P2)
    out = {}
    for name, me_seat_of, jobs in (('c1 ' + a.c1, lambda s: s, j1), ('c2 ' + a.c2, lambda s: 'P2' if s == 'P1' else 'P1', j2)):
        groups = [(ls, me_seat_of(seat)) for seat, ls in res.items()]
        r = side_bar(groups, jobs)
        rw = [(rows(ls), ms) for ls, ms in groups]
        n = sum(len(x) for x, _ in rw)
        kos = sum(k for x, _ in rw for _, k in x.values())
        wins = sum(1 for x, ms in rw for w, k in x.values() if k and w == ms)
        r.update(ko_rate=round(kos / max(1, n), 3), ko_win=round(wins / max(1, n), 3), timeouts=n - kos)
        out[name] = r
    print(json.dumps(dict(p1=a.p1, p2=a.p2, seeds=a.seeds, build=simlib.build_hash(os.path.join(ROOT, 'tools/simgate/strat-run.lisp'))[:12],
                          sides=out), indent=1))


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('desc')
    p.add_argument('--me', required=True, choices=list(ss.ROSTER)); p.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    p.add_argument('--arms', required=True); p.add_argument('--with', dest='with_', nargs='*'); p.add_argument('--ids')
    p.add_argument('--seed0', type=int, default=0); p.add_argument('--seeds', type=int, default=100); p.add_argument('-j', type=int, default=20)
    p.add_argument('--dif', choices=('easy', 'normal'), help='my seat at this difficulty (a diagnostic; the proof is HARD)')
    p.add_argument('--tag', help='suffix of the output file (proof/<me>-vs-<vs>[-dif]-TAG.json)')
    p = sub.add_parser('t0')
    p.add_argument('--me', required=True, choices=list(ss.ROSTER)); p.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    p.add_argument('--map', required=True); p.add_argument('--out', required=True); p.add_argument('--with', dest='with_', nargs='*')
    p.add_argument('--or', dest='or_', action='store_true'); p.add_argument('--q', type=float, default=0.06)
    p = sub.add_parser('bar')
    p.add_argument('--p1', required=True); p.add_argument('--p1map', required=True); p.add_argument('--c1', required=True, choices=list(ss.ROSTER))
    p.add_argument('--p2', required=True); p.add_argument('--p2map', required=True); p.add_argument('--c2', required=True, choices=list(ss.ROSTER))
    p.add_argument('--seeds', default='501-540'); p.add_argument('-j', type=int, default=20)
    a = ap.parse_args()
    {'desc': cmd_desc, 't0': cmd_t0, 'bar': cmd_bar}[a.cmd](a)


if __name__ == '__main__':
    main()
