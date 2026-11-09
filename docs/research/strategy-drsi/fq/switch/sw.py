#!/usr/bin/env python3
"""sw.py — the Hisagi vs Ichigo pilot of a Q table that switches (docs/duel/DUEL_AI_STRATEGY.md §8.19; README.md here).

  python3 sw.py start [--period 90] [--out FILE]           # the start table: :qh-ichigo's 48 rules inside the grouped rule base, 4 arms
  python3 sw.py log --table FILE --tag T --salt 1 [--eps 0.08] [--runs 6 18] [--seeds 1-599] [-j 8]   # behaviour = TABLE + runs
  python3 sw.py fit --tag T[,T2...] --init FILE --out FILE [--gamma 0.99] [--scale 0.1] [--lam 30] [--conf 0.95] [--seeds 1-599]
  python3 sw.py measure --table FILE --tag T [--seeds 701-800]  # eps 0: shares, per-seed winners, switch statistics, the ranged mode's distance
  python3 sw.py pair A.json B.json                          # paired b / c of two evals on the same seeds

The opponent is Ichigo's frozen :ki-ichigo (counter/frozen/ki-ichigo.lisp) on the other seat, HARD, both seats. Logs go under
logs/<tag>/ (gitignored); an eval's summary is written to <tag>.json beside this file.

The rule base (Lisp groups, strategy.lisp STRAT-FQ-Q :GROUPS; Q = the sum of each group's firing-weighted average):
  G0  72  lead x ored x ost x awk x prev: the shipped 48 (prev :no / :yes = arm 0 / arm 1) + 24 with prev :p2up (arm 2 or later)
  G1   9  my form (Shikai / ranged / bind) x distance in metres (:m-close / :m-mid / :m-far): the user's distance rule lives here
  G2   4  the switch's gauge (DRIVE awakened, SUBLIMATION before; :g-low / :g-high about 0.25) x awk
  G3   2  the wall (:w-near within 2-3 m / :w-open)
  G4   2  his awakening (Ichigo's KESSA)
Arms: general 0 :hm1-merged (the shipped arm 0), 1 :s3-zoner (the shipped arm 1), 2 the merged style + the DRIVE switch, 3 the merged style
+ the brawler's data (close pressure), 4 the merged style + s7-kite's data (the kite); targeted 5 Kenpachi's KI style code (written against
Ichigo). Every arm but s3-zoner is data over the existing style functions (no new Lisp).
"""
import argparse, concurrent.futures as cf, gzip, json, os, re, subprocess, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
FQD = os.path.dirname(HERE)
ROOT = os.path.abspath(os.path.join(HERE, '../../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
sys.path.insert(0, FQD)
from simgate import ECL, FAS, MUSLM          # noqa: E402
import fq                                    # noqa: E402

ME, VS, HARD = 7, 3, 2
OPP = os.path.join(FQD, '..', 'counter', 'frozen', 'ki-ichigo.lisp')
LOGS = os.path.join(HERE, 'logs')
SHIPPED = os.path.join(FQD, 'hisagi', 'hi-fqm.lisp')
ARMS = [                                                              # (general: :apply (:hisagi), against anyone; targeted: (:hisagi :ichigo))
    '(:id :hm1-merged :fn hisagi-merged-style :ken-ranged t :apply (:hisagi))',                  # general: all-round, the ranged mode's distance rule
    None,                                                             # general: the zoner, the shipped arm 1 (s3-zoner, copied from the shipped table)
    '(:id :hm2-dswitch :fn hisagi-merged-style :ken-ranged t :apply (:hisagi) :base (:dswitch 1.0) :dswitch-map ((:base 1 3)))',   # general: the DRIVE switch route
    '(:id :hm3-press :fn hisagi-merged-style :ken-ranged t :apply (:hisagi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05) :rules ((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05))))',   # general: close pressure (the merged code + the brawler's data)
    '(:id :hm4-kite :fn hisagi-merged-style :ken-ranged t :apply (:hisagi) :base (:range 3.2 :ns 1.0 :hoho 1.0 :kikon 0.4 :cont 1.3 :awaken 4.0 :p 1.0 :b-walk-out 0.05 :b-wait 0.04 :b-j1 -0.3 :b-walk-in -0.08 :b-step-in -0.05) :rules ((((:dn :reach)) (:b-sp 0.2 :b-walk-in -0.05)) (((:dn :out)) (:b-sp 0.15)) (((:dn :afar) (:wave :yes)) (:b-sp 0.22 :b-walk-in -0.06)) (((:do :in)) (:b-walk-out 0.2 :b-step-out 0.18 :b-j1 -0.1)) (((:do :reach)) (:b-walk-out 0.1 :b-step-out 0.08))))',   # general: the kite (the merged code + s7-kite's data)
    '(:id :ht1-ki :fn ken-ki-style :apply (:hisagi :ichigo) :base (:p 1.3))',                     # targeted: Kenpachi's KI style code, written against Ichigo
]
NA = len(ARMS)
LEAD = (':behind', ':even', ':ahead')
YN = (':no', ':yes')


def rules():
    """-> [(antecedent text, group)] in table order."""
    out = [(fq.ante(c), 0) for c in range(fq.NC)]
    for lc in range(3):
        for ored in range(2):
            for free in range(2):
                for awk in range(2):
                    out.append((f'((:lead {LEAD[lc]}) (:ored {YN[ored]}) (:ost {":free" if free else ":busy"}) (:awk {YN[awk]}) (:prev :p2up))', 0))
    for fm in (':no', ':yes', ':k2'):
        for dm in (':m-close', ':m-mid', ':m-far'):
            out.append((f'((:form {fm}) (:dm {dm}))', 1))
    for g in (':g-low', ':g-high'):
        for awk in YN:
            out.append((f'((:gauge {g}) (:awk {awk}))', 2))
    out += [('((:wall :w-near))', 3), ('((:wall :w-open))', 3), ('((:oawk :no))', 4), ('((:oawk :yes))', 4)]
    return out


RULES = rules()
NR = len(RULES)
GROUPS = [sum(1 for _, g in RULES if g == k) for k in range(5)]
GROUP_OF = np.array([g for _, g in RULES])
RULE_NAMES = [a for a, _ in RULES]


def arms_text():
    _, _, arms, _ = fq.read_table(SHIPPED)
    s3 = arms[arms.index('(:id :s3-zoner'):-1].strip()               # (the shipped arms text: "(A0 A1)")
    return '(' + ' '.join(ARMS[i] if ARMS[i] else s3 for i in range(NA)) + ')'


def write_table(path, sid, q, note, period=None, gamma=None, scale=None):
    keys = f':groups ({" ".join(map(str, GROUPS))}) :xfeats t :keep-state t'
    if period:
        keys += f' :period {period}'
    if gamma is not None:
        keys += f' :gamma {gamma} :scale {scale}'
    body = '\n          '.join(f'({RULES[r][0]} {" ".join(f"{q[r, a]:.4f}" for a in range(NA))})' for r in range(NR))
    with open(path, 'w') as f:
        f.write(f';; {note}\n;; Groups {GROUPS}: G0 lead x ored x ost x awk x prev, G1 form x distance (m), G2 gauge x awk, G3 wall, G4 his awakening.\n'
                f'(:id {sid} :apply (:hisagi :ichigo) :fq (:arms {arms_text()} {keys}\n     :rules ({body})))\n')


def read_q(path):
    """A table written by write_table -> q (NR x NA)."""
    text = open(path).read().lower()
    q = np.zeros((NR, NA))
    for r, (ante, _) in enumerate(RULES):
        i = text.index('(' + ante + ' ')
        q[r] = [float(x) for x in text[i + len(ante) + 2:text.index(')', i + len(ante) + 1)].split()]
    return q


def cmd_start(a):
    _, _, _, q0 = fq.read_table(SHIPPED)
    q = np.zeros((NR, NA))
    for c in range(fq.NC):
        q[c, :2] = q0[c]
        q[c, 2:] = q0[c].min() - 1.0                                  # (arms 2- strictly below: the shipped argmax everywhere)
    for k in range(24):                                               # (prev arm 2 or later: the prev :no cell's values; never reached at the start)
        q[fq.NC + k] = q[2 * k]
    write_table(a.out, ':hi-sw0', q, 'The start table: :qh-ichigo (hisagi/hi-fqm.lisp) inside the grouped rule base; arms 2 / 3 below, '
                'every new group 0, so it plays the shipped table bit for bit at the same period.', period=a.period)


def chunks(lo, hi, size=25):
    return fq.chunks(lo, hi, size)


def run(args):
    salt, eps, rmin, rmax, seat, seed0, n, table, tag = args
    path = os.path.join(LOGS, tag, f'sw-s{salt}-e{eps}-{seat}-{seed0 + 1}-{seed0 + n}.out.gz')
    if os.path.exists(path):
        return path
    c1, c2 = (ME, VS) if seat == 'P1' else (VS, ME)
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    env.update(LD_PRELOAD=MUSLM, STRAT_FQLOG=f'{salt} {eps} {seat[1]}' + (f' {rmin} {rmax}' if rmax else ''), STRAT_HRANGE='1')
    env['STRAT_' + seat] = table
    env['STRAT_' + ('P2' if seat == 'P1' else 'P1')] = os.path.abspath(OPP)
    cmds = [30000 + seed0, 31100 + n, 81000, 81020 + HARD, 81030, 81040, 200000 + 100 * c1 + 10 * c2]
    r = subprocess.run([ECL, '--norc', '--load', 'tools/simgate/strat-run.lisp', '--', FAS] + [str(c) for c in cmds], cwd=ROOT,
                       capture_output=True, text=True, env=env, timeout=7200)
    keep = [l for l in r.stdout.splitlines() if l.startswith(('fq ', 'fqend ', 'duel gate row ', 'hrange ', 'switch '))]
    rows = sum(l.startswith('duel gate row ') for l in keep)
    if r.returncode or rows != n:
        sys.exit(f'sw.py: sim exited {r.returncode}, {rows} of {n} rows ({path})\n' + (r.stdout + r.stderr)[-2000:])
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with gzip.open(path + '.tmp', 'wt') as f:
        f.write('\n'.join(keep) + '\n')
    os.replace(path + '.tmp', path)
    return path


def play(table, tag, seeds, salt=0, eps=0.0, runs=(None, None), j=8):
    table = os.path.abspath(table)
    os.makedirs(os.path.join(LOGS, tag), exist_ok=True)
    with open(os.path.join(LOGS, tag, 'args.txt'), 'a') as f:
        f.write(f'salt {salt} eps {eps} runs {runs} seeds {seeds} table {os.path.relpath(table, ROOT)}\n')
    lo, hi = (int(x) for x in seeds.split('-'))
    jobs = [(salt, eps, runs[0], runs[1], seat, s0, n, table, tag) for seat in ('P1', 'P2') for s0, n in chunks(lo, hi)]
    with cf.ThreadPoolExecutor(max(1, min(22, j))) as ex:
        return list(ex.map(run, jobs))


def cmd_log(a):
    for p in play(a.table, a.tag, a.seeds, a.salt, a.eps, tuple(a.runs), a.j):
        print(p, flush=True)


LINE = re.compile(r'fq (\d+) (\d+) (P\d) lead (-?\d+) ored (\d) ost (\d) mr \S+ or \S+ dj \S+ awk (\d) prev (\d) greedy (\d) arm (\d) '
                  r'h (\S+) oh (\S+)(?: dm (\S+) form (\d) oawk (\d) gauge (\S+) wall (\S+) fire(.*))?')   # (no extra cues: a plain table)


def parse_file(path, seat):
    """-> {seed: dict(js=[(tick, arm, greedy, h, dm, form, fire dict, oawk, gauge, wall, lead)], end=h, win=+1/-1/0, hr=...)}"""
    per = {}
    for line in gzip.open(path, 'rt'):
        if line.startswith('fq '):
            g = LINE.match(line)
            if not g or g.group(3) != seat:
                continue
            x = g.group(13) is not None
            fire = {int(k): float(v) for k, v in (y.split(':') for y in g.group(18).split())} if x else {}
            per.setdefault(int(g.group(1)), dict(js=[]))['js'].append(
                (int(g.group(2)), int(g.group(10)), int(g.group(9)), float(g.group(11)) - float(g.group(12)), float(g.group(13)) if x else None,
                 int(g.group(14)) if x else None, fire, int(g.group(15)) if x else None, float(g.group(16)) if x else None,
                 float(g.group(17)) if x else None, int(g.group(4))))
        elif line.startswith('fqend '):
            p = line.split()
            if p[2] == seat:
                per.setdefault(int(p[1]), dict(js=[]))['end'] = float(p[4]) - float(p[6])
        elif line.startswith('duel gate row '):
            m = re.search(r'seed (\d+) .* winner (\S+)', line)
            secs = re.search(r' secs? ([\d.]+)', line)
            d = per.setdefault(int(m.group(1)), dict(js=[]))
            d['win'] = 1.0 if m.group(2) == seat else (-1.0 if m.group(2) in ('P1', 'P2') else 0.0)
            d['secs'] = float(secs.group(1)) if secs else None
        elif line.startswith('hrange '):
            m = re.match(r'hrange (\d+) ' + seat + r' steps (\d+) dsum (\S+) close (\d+) wafar (\d+) cnt (.*)', line)
            if m:
                per.setdefault(int(m.group(1)), dict(js=[]))['hr'] = [int(m.group(2)), float(m.group(3)), int(m.group(4)), int(m.group(5))] + \
                    [int(x) for x in m.group(6).split()]
    return per


def load(tags, lo, hi):
    """-> list of matches (dicts as parse_file's, plus seed / seat / tag) over every log of TAGS within seeds lo..hi."""
    out = []
    for tag in tags.split(','):
        d = os.path.join(LOGS, tag)
        for fn in sorted(os.listdir(d)):
            m = re.match(r'sw-s(\d+)-e([\d.]+)-(P\d)-(\d+)-(\d+)\.out\.gz$', fn)
            if not m or int(m.group(4)) < lo or int(m.group(5)) > hi:
                continue
            for sd, x in parse_file(os.path.join(d, fn), m.group(3)).items():
                if 'win' in x:
                    out.append(dict(x, seed=sd, seat=m.group(3), tag=tag, salt=int(m.group(1))))
    return out


def design(matches, gamma, scale):
    """-> X (n x NR firing), arm, y (the discounted return per judgement window), unit (match index)."""
    X, A, Y, U = [], [], [], []
    for u, mt in enumerate(matches):
        js = mt['js']
        if not js:
            continue
        h = [j[3] for j in js] + [mt.get('end', js[-1][3])]
        r = [scale * (h[k + 1] - h[k]) for k in range(len(js))]
        r[-1] += mt['win']
        g, ys = 0.0, []
        for k in range(len(js) - 1, -1, -1):
            g = r[k] + gamma * g
            ys.append(g)
        ys.reverse()
        for k, jj in enumerate(js):
            X.append(jj[6]); A.append(jj[1]); Y.append(ys[k]); U.append(u)
    Xd = np.zeros((len(X), NR), dtype=np.float32)
    for i, fire in enumerate(X):
        for r, x in fire.items():
            Xd[i, r] = x
    return Xd, np.array(A), np.array(Y, dtype=np.float32), np.array(U)


def ridge_fit(X, A, Y, w, lam_v, lam_d):
    """V: one ridge over every row (the state's value); per arm a delta ridge on the residuals (shrunk toward 0 = no preference).
    -> theta (NR x NA) = v + delta_a."""
    w = w.astype(np.float32)
    Xw = X * w[:, None]
    v = np.linalg.solve((Xw.T @ X).astype(float) + lam_v * np.eye(NR), (Xw.T @ Y).astype(float))
    res = (Y - X @ v.astype(np.float32)).astype(np.float32)
    th = np.zeros((NR, NA))
    for a in range(NA):
        m = (A == a)
        if w[m].sum() <= 0:
            th[:, a] = v
            continue
        Xa, Xwa = X[m], Xw[m]
        d = np.linalg.solve((Xwa.T @ Xa).astype(float) + lam_d * np.eye(NR), (Xwa.T @ res[m]).astype(float))
        th[:, a] = v + d
    return th, v


def cmd_fit(a):
    lo, hi = (int(x) for x in a.seeds.split('-'))
    ms = load(a.tag, lo, hi)
    X, A, Y, U = design(ms, a.gamma, a.scale)
    print(f'matches {len(ms)} judgements {len(Y)} arms {np.bincount(A, minlength=NA).tolist()}', flush=True)
    th, v = ridge_fit(X, A, Y, np.ones(len(Y)), a.lam_v, a.lam)
    d = th - v[:, None]
    # the gate: a delta coefficient survives when the match bootstrap agrees on its sign in >= CONF of the replicates
    rng = np.random.default_rng(1)
    nu = len(ms)
    sign = np.zeros((NR, NA))
    for b in range(a.boot):
        w = rng.poisson(1.0, nu)[U].astype(float)
        tb, vb = ridge_fit(X, A, Y, w, a.lam_v, a.lam)
        sign += np.sign(tb - vb[:, None]) == np.sign(d)
    agree = sign / a.boot
    dg = np.where(agree >= a.conf, d, 0.0)
    q = v[:, None] + dg
    q -= 1e-4
    q[:, a.default] += 1e-4                                           # (no preference: the default arm, pi0)
    q = np.round(q, 4)
    # what the table would play on the data's own states
    Q = X @ q
    pick = Q.argmax(1)
    write_table(a.out, ':' + os.path.splitext(os.path.basename(a.out))[0], q,
                f'sw.py fit --tag {a.tag} --seeds {a.seeds} --gamma {a.gamma} --scale {a.scale} --lam {a.lam} --lam-v {a.lam_v} '
                f'--conf {a.conf} --boot {a.boot} --default {a.default}: {len(ms)} matches, {len(Y)} judgements.', period=a.period, gamma=a.gamma, scale=a.scale)
    res = dict(tag=a.tag, seeds=a.seeds, gamma=a.gamma, scale=a.scale, lam=a.lam, lam_v=a.lam_v, conf=a.conf, boot=a.boot, matches=len(ms),
               judgements=int(len(Y)), behaviour_arms=np.bincount(A, minlength=NA).tolist(), greedy_on_data=np.bincount(pick, minlength=NA).tolist(),
               kept=[[RULE_NAMES[r], a_] for r in range(NR) for a_ in range(NA) if dg[r, a_] != 0])
    with open(os.path.splitext(a.out)[0] + '.json', 'w') as f:
        json.dump(res, f, indent=1)
    print(json.dumps({k: v_ for k, v_ in res.items() if k != 'kept'}))
    print(f'kept deltas: {len(res["kept"])}')


def band(dm):
    return 'close' if dm < 2.9 else ('mid' if dm < 4.5 else 'far')


def summarize(ms):
    """-> the eval's numbers: share, per-seed winners, switch statistics, the ranged mode's distance."""
    wins = {f'{m["seat"]}-{m["seed"]}': m['win'] for m in ms}
    n = len(ms)
    changes = [sum(1 for k in range(1, len(m['js'])) if m['js'][k][1] != m['js'][k - 1][1]) for m in ms]
    arms = np.zeros(max([NA] + [j[1] + 1 for m in ms for j in m['js']]))
    by = {}
    for m in ms:
        for j in m['js']:
            arms[j[1]] += 1
            if j[4] is None:
                continue
            for key in (('band', band(j[4])), ('form', ('shikai', 'ranged', 'bind')[j[5]]), ('form-band', ('shikai', 'ranged', 'bind')[j[5]] + '-' + band(j[4]))):
                by.setdefault(key[0], {}).setdefault(key[1], np.zeros(NA))[j[1]] += 1
    hr = np.array([m['hr'] for m in ms if m.get('hr')]) if any(m.get('hr') for m in ms) else None
    out = dict(matches=n, share=round(sum(1 for m in ms if m['win'] > 0) / max(1, n), 3),
               judged=int(arms.sum()), judged_per_match=round(arms.sum() / max(1, n), 1),
               arm_share=[round(x / max(1, arms.sum()), 3) for x in arms],
               changes_per_match=dict(mean=round(float(np.mean(changes)), 2), median=float(np.median(changes)),
                                      zero=int(sum(c == 0 for c in changes))),
               by={k: {kk: dict(n=int(vv.sum()), share=[round(x / max(1, vv.sum()), 3) for x in vv]) for kk, vv in v.items()} for k, v in by.items()},
               wins=wins)
    if hr is not None:
        out['hrange'] = dict(steps=int(hr[:, 0].sum()), mean_d=round(float(hr[:, 1].sum() / max(1, hr[:, 0].sum())), 3),
                             close_share=round(float(hr[:, 2].sum() / max(1, hr[:, 0].sum())), 4), wa_far=int(hr[:, 3].sum()),
                             counts=hr[:, 4:].sum(0).tolist())
    return out


def cmd_eval(a):
    play(a.table, a.tag, a.seeds, j=a.j)
    lo, hi = (int(x) for x in a.seeds.split('-'))
    out = dict(table=os.path.relpath(os.path.abspath(a.table), ROOT), seeds=a.seeds, **summarize(load(a.tag, lo, hi)))
    with open(os.path.join(HERE, a.tag + '.json'), 'w') as f:
        json.dump(out, f, indent=1)
    print(json.dumps({k: v for k, v in out.items() if k not in ('wins', 'by')}))


def cmd_pair(a):
    x, y = (json.load(open(p))['wins'] for p in (a.a, a.b))
    b = sum(1 for k in x if x[k] > 0 and not y.get(k, 0) > 0)
    c = sum(1 for k in x if y.get(k, 0) > 0 and not x[k] > 0)
    print(json.dumps(dict(a=a.a, b_=a.b, b=b, c=c, z=round((b - c) / max(1, (b + c)) ** 0.5, 2))))


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('start'); p.add_argument('--period', type=int); p.add_argument('--out', default=os.path.join(HERE, 'hi-sw0.lisp'))
    p = sub.add_parser('log')
    p.add_argument('--table', required=True); p.add_argument('--tag', required=True); p.add_argument('--salt', type=int, required=True)
    p.add_argument('--eps', type=float, default=0.08); p.add_argument('--runs', type=int, nargs=2, default=[6, 18])
    p.add_argument('--seeds', default='1-599'); p.add_argument('-j', type=int, default=20)
    p = sub.add_parser('fit')
    p.add_argument('--tag', required=True); p.add_argument('--out', required=True); p.add_argument('--seeds', default='1-599')
    p.add_argument('--gamma', type=float, default=0.99); p.add_argument('--scale', type=float, default=0.1)
    p.add_argument('--lam', type=float, default=300.0); p.add_argument('--lam-v', type=float, default=1.0)
    p.add_argument('--conf', type=float, default=0.95); p.add_argument('--boot', type=int, default=40); p.add_argument('--period', type=int, default=30)
    p.add_argument('--default', type=int, default=0, help='the arm where no delta survives (pi0)')
    p = sub.add_parser('measure')
    p.add_argument('--table', required=True); p.add_argument('--tag', required=True); p.add_argument('--seeds', default='701-800')
    p.add_argument('-j', type=int, default=8)
    p = sub.add_parser('pair'); p.add_argument('a'); p.add_argument('b')
    a = ap.parse_args()
    {'start': cmd_start, 'log': cmd_log, 'fit': cmd_fit, 'measure': cmd_eval, 'pair': cmd_pair}[a.cmd](a)


if __name__ == '__main__':
    main()
