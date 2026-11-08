#!/usr/bin/env python3
"""fq.py — the offline fuzzy Q selector for one HARD pairing (docs/duel/DUEL_AI_STRATEGY.md §8.12, §8.15; README.md here). The defaults are
Ichigo vs Kenpachi as in §8.12 (arms Kenpachi's / her own KI style, init c1, logs/ichigo-kenpachi/, Kenpachi's shipped CPU).

  python3 fq.py init [--char C --vs D] [--arms A0 A1] [--policy c1|arm0] [--out FILE]   # the table whose greedy policy is the incumbent
  python3 fq.py log --salt 1 [--eps 0.15] [--seeds 1-500] [--table FILE] [--opp SPEC] [--tag T] [-j 8]   # behaviour = TABLE + eps -> logs/T/*.out.gz
  python3 fq.py train [--tag T] [--init FILE] [--seeds 1-500] [--gamma 0.9] [--scale 0.1] [--conf 0.95] [--out FILE]   # fitted fuzzy Q

An arm (A0 / A1) is a strategy file, a frozen library id (counter/frozen/<id>.lisp) or `none` (NIL: the incumbent, i.e. the character's HARD
CPU with its lookup strategy and style CPU, as a composite's no-entry fallback). The table carries :apply (me vs), so the online learner
(online.py, strat-run.lisp STRAT_FQLEARN) can key it. --opp: the opponent seat's strategy (a file, a frozen id, `none` = his shipped CPU
without any lookup strategy, or a comma list = a pool: strat-run.lisp plays member (match seed mod n)); omitted = whatever the build's lookup
gives him (the §8.12 logs: Kenpachi has no lookup entry against Ichigo, so it is his shipped CPU). Only the character's seat logs and explores
(STRAT_FQLOG's seat), so an opponent that is itself a Q selector stays frozen.
init --policy: c1 (IK only: the composite c1, cells where he is free and she is behind or he is red play arm 1) or arm0 (arm 0 everywhere,
the generic start: arm 0 = the incumbent). train --init: the table whose argmax per cell is pi0 (the policy the gate starts from) and whose
:arms / :apply are copied (default fq-c1.lisp).

The rule base is the product of five crisp cues: his Konpaku lead (behind / even / ahead), his red (ored), his state free (ost 0) or not,
my awakening (awk), the previous arm (prev). At the judgements' integer / 0-1 values every set is crisp, so exactly one rule fires at
strength 1 and the table is tabular in effect (the fuzzy averaging does nothing here; it is the format a TD update can keep). The cues are
strat-feats', the same for every character, so the 48 rules carry over to any pairing as they are.
Reward per judgement window = SCALE x the change of (my mc-full-health - his), + 1 / -1 at the match's end for a win / a loss (0 a
draw; a time-out has a winner by the lead). Policy: pi0, and a cell leaves pi0's arm only when the other arm's Q is higher in >= CONF of the
seed-bootstrap replicates (policy evaluation of the current policy, a few improvement rounds).
"""
import argparse, concurrent.futures as cf, gzip, json, os, re, subprocess, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from simgate import ECL, FAS, MUSLM          # noqa: E402

ROSTER = {'kenpachi': 1, 'ichigo': 3, 'hisagi': 7}
HARD = 2
LOGS = os.path.join(HERE, 'logs')
FROZEN = os.path.join(HERE, '..', 'counter', 'frozen')
LEAD = (':behind', ':even', ':ahead')
IK_ARMS = ('(:id :c1-ken :fn ken-ki-style)', '(:id :c1-own :fn ichigo-ki-style)')
NC = 48


def strip_lisp(text):
    """TEXT without ;-comments (no strings in strategy files), whitespace runs folded."""
    return ' '.join(re.sub(r';[^\n]*', '', text).split())


def spec_path(spec):
    """A strategy spec -> a file path, or 'none'. SPEC: a path, a frozen library id (counter/frozen/<id>.lisp), or none."""
    if spec == 'none' or os.path.exists(spec):
        return spec if spec == 'none' else os.path.abspath(spec)
    f = os.path.join(FROZEN, spec.lstrip(':') + '.lisp')
    if os.path.exists(f):
        return os.path.abspath(f)
    sys.exit(f'fq.py: no strategy file or frozen id {spec}')


def opp_env(spec):
    """--opp SPEC (comma list = a pool) -> the STRAT_P<n> value: absolute paths, or none."""
    return ','.join(spec_path(x) for x in spec.split(','))


def arm_text(spec):
    """An arm spec -> its plist text (nil for none)."""
    p = spec_path(spec)
    return 'nil' if p == 'none' else strip_lisp(open(p).read())


def read_table(path):
    """A table file -> (id, apply text or None, arms text, q array NC x 2), the rules in cell order (as write_table writes them)."""
    text = strip_lisp(open(path).read()).lower()            # (the learner writes upper case)
    sid = re.search(r'\(:id (\S+)', text).group(1)
    ap = re.search(r':apply (\([^()]*\))', text)
    arms = text[text.index(':arms ') + 6:text.index(' :rules ')]
    rows = re.findall(r'\(\(\(:lead :(\w+)\) \(:ored :(\w+)\) \(:ost :(\w+)\) \(:awk :(\w+)\) \(:prev :(\w+)\)\) ([-\d.eE]+) ([-\d.eE]+)\)', text)
    if len(rows) != NC:
        sys.exit(f'fq.py: {path}: {len(rows)} rules, expected {NC}')
    q = np.zeros((NC, 2))
    for lead, ored, ost, awk, prev, q0, q1 in rows:
        c = cell({'behind': -1, 'even': 0, 'ahead': 1}[lead], int(ored == 'yes'), int(ost == 'free'), int(awk == 'yes'), int(prev == 'yes'))
        q[c] = float(q0), float(q1)
    return sid, ap.group(1) if ap else None, arms, q


def cell(lead, ored, free, awk, prev):
    lc = 0 if lead <= -1 else (1 if lead == 0 else 2)
    return (((lc * 2 + ored) * 2 + free) * 2 + awk) * 2 + prev


def cell_parts(c):
    prev, c = c % 2, c // 2
    awk, c = c % 2, c // 2
    free, c = c % 2, c // 2
    ored, lc = c % 2, c // 2
    return lc, ored, free, awk, prev


def c1_arm(c):
    lc, ored, free, _, _ = cell_parts(c)
    return int(free == 1 and (lc == 0 or ored == 1))


def ante(c):
    lc, ored, free, awk, prev = cell_parts(c)
    yn = lambda x: ':yes' if x else ':no'
    return f'((:lead {LEAD[lc]}) (:ored {yn(ored)}) (:ost {":free" if free else ":busy"}) (:awk {yn(awk)}) (:prev {yn(prev)}))'


def write_table(path, sid, q, note, arms, apply_):
    rules = '\n          '.join(f'({ante(c)} {q[c, 0]:.4f} {q[c, 1]:.4f})' for c in range(NC))
    with open(path, 'w') as f:
        f.write(f';; {note}\n;; Arms: {arms}. Rules: lead x ored x ost free x awk x prev (crisp), "Q0 Q1".\n'
                f'(:id {sid}{" :apply " + apply_ if apply_ else ""} :fq (:arms {arms}\n     :rules ({rules})))\n')


def cmd_init(a):
    q = np.zeros((NC, 2))
    for c in range(NC):
        q[c, c1_arm(c) if a.policy == 'c1' else 0] = 1.0
    arms = '(' + ' '.join(arm_text(x) for x in a.arms) + ')' if a.arms else '(' + ' '.join(IK_ARMS) + ')'
    out = a.out or os.path.join(HERE, 'fq-c1.lisp')
    write_table(out, ':' + os.path.splitext(os.path.basename(out))[0], q,
                'The Q selector initialised to ' + ('the composite c1 (greedy = c1 in every cell).' if a.policy == 'c1' else
                                                    'arm 0 in every cell (greedy = the incumbent).'), arms, f'(:{a.char} :{a.vs})')


def seed_range(s):
    lo, hi = (int(x) for x in s.split('-'))
    return lo, hi


def chunks(lo, hi, size=25):
    """(seed0, n) chunks covering seeds lo..hi (a chunk plays seed0+1..seed0+n; debug 30000+seed0 takes seed0 <= 999)."""
    out, s = [], lo
    while s <= hi:
        n = min(size, hi - s + 1)
        out.append((s - 1, n))
        s += n
    return out


def run_log(args):
    salt, eps, seat, seed0, n, table, me, vs, opp, tag = args
    path = os.path.join(LOGS, tag, f'fq-s{salt}-e{eps}-{seat}-{seed0 + 1}-{seed0 + n}.out.gz')
    if os.path.exists(path):
        return path
    c1, c2 = (me, vs) if seat == 'P1' else (vs, me)
    env = {k: v for k, v in os.environ.items() if not k.startswith('STRAT_')}
    env.update(LD_PRELOAD=MUSLM, STRAT_FQLOG=f'{salt} {eps} {seat[1]}')     # (only my seat logs and explores)
    env['STRAT_' + seat] = table
    if opp:
        env['STRAT_' + ('P2' if seat == 'P1' else 'P1')] = opp
    cmds = [30000 + seed0, 31100 + n, 81000, 81020 + HARD, 81030, 81040, 200000 + 100 * c1 + 10 * c2]
    r = subprocess.run([ECL, '--norc', '--load', 'tools/simgate/strat-run.lisp', '--', FAS] + [str(c) for c in cmds], cwd=ROOT,
                       capture_output=True, text=True, env=env, timeout=7200)
    keep = [l for l in r.stdout.splitlines() if l.startswith(('fq ', 'fqend ', 'duel gate row '))]
    rows = sum(l.startswith('duel gate row ') for l in keep)
    if r.returncode or rows != n:
        sys.exit(f'fq.py: sim exited {r.returncode}, {rows} of {n} rows ({path})\n' + (r.stdout + r.stderr)[-2000:])
    with gzip.open(path + '.tmp', 'wt') as f:
        f.write('\n'.join(keep) + '\n')
    os.replace(path + '.tmp', path)
    return path


def cmd_log(a):
    tag = a.tag or f'{a.char}-{a.vs}'
    os.makedirs(os.path.join(LOGS, tag), exist_ok=True)
    table = os.path.abspath(a.table or os.path.join(HERE, 'fq-c1.lisp'))
    opp = opp_env(a.opp) if a.opp else None
    with open(os.path.join(LOGS, tag, 'log-args.txt'), 'a') as f:      # (what the logs under this tag were played with)
        f.write(f'salt {a.salt} eps {a.eps} seeds {a.seeds} char {a.char} vs {a.vs} table {table} opp {opp}\n')
    jobs = [(a.salt, a.eps, seat, s0, n, table, ROSTER[a.char], ROSTER[a.vs], opp, tag)
            for seat in ('P1', 'P2') for s0, n in chunks(*seed_range(a.seeds))]
    with cf.ThreadPoolExecutor(max(1, min(8, a.j))) as ex:
        for p in ex.map(run_log, jobs):
            print(p, flush=True)


FQ = re.compile(r'fq (\d+) (\d+) (P\d) lead (-?\d+) ored (\d) ost (\d) mr \S+ or \S+ dj \S+ awk (\d) prev (\d) greedy (\d) arm (\d) h (\S+) oh (\S+)')


def load(lo, hi, tag):
    """-> transition arrays (s, a, r_shaped, r_term, s2, done, unit) over every log under logs/TAG whose seeds lie in lo..hi; and counts."""
    S, A, D, T, S2, DONE, U = [], [], [], [], [], [], []
    stats = dict(files=0, matches=0, judgements=0, explored=0)
    d = os.path.join(LOGS, tag)
    for fn in sorted(os.listdir(d)):
        m = re.match(r'fq-s(\d+)-e([\d.]+)-(P\d)-(\d+)-(\d+)\.out\.gz$', fn)
        if not m or int(m.group(4)) < lo or int(m.group(5)) > hi:
            continue
        seat = m.group(3)
        stats['files'] += 1
        per, end, win = {}, {}, {}
        for line in gzip.open(os.path.join(d, fn), 'rt'):
            if line.startswith('fq '):
                g = FQ.match(line)
                if g.group(3) != seat:
                    continue
                per.setdefault(int(g.group(1)), []).append(
                    (int(g.group(2)), cell(int(g.group(4)), int(g.group(5)), int(g.group(6) == '0'), int(g.group(7)), int(g.group(8))),
                     int(g.group(10)), float(g.group(11)) - float(g.group(12)), int(g.group(9))))
            elif line.startswith('fqend '):
                p = line.split()
                if p[2] == seat:
                    end[int(p[1])] = float(p[4]) - float(p[6])
            elif line.startswith('duel gate row '):
                g = re.search(r'seed (\d+) .* winner (\S+)', line)
                win[int(g.group(1))] = 1.0 if g.group(2) == seat else (-1.0 if g.group(2) in ('P1', 'P2') else 0.0)
        for sd, js in per.items():
            js.sort()
            stats['matches'] += 1
            for k, (t, c, arm, h, greedy) in enumerate(js):
                stats['judgements'] += 1
                stats['explored'] += arm != greedy
                last = k == len(js) - 1
                h2 = end[sd] if last else js[k + 1][3]
                S.append(c); A.append(arm); D.append(h2 - h); T.append(win[sd] if last else 0.0)
                S2.append(0 if last else js[k + 1][1]); DONE.append(last); U.append(sd)
    return (np.array(S), np.array(A), np.array(D), np.array(T), np.array(S2), np.array(DONE), np.array(U)), stats


def fqe(S, A, R, S2, DONE, w, pi, gamma, iters=80):
    """Q of policy PI (an arm per cell) on the weighted transitions: Q(s,a) = mean of r + gamma Q(s', pi(s')). NaN where (s, a) has no data."""
    idx = S * 2 + A
    n = np.bincount(idx, weights=w, minlength=NC * 2)
    q = np.zeros(NC * 2)
    nxt = S2 * 2 + pi[S2]
    for _ in range(iters):
        tgt = R + gamma * np.where(DONE, 0.0, q[nxt])
        q = np.bincount(idx, weights=w * tgt, minlength=NC * 2) / np.maximum(n, 1e-9)
    q[n == 0] = np.nan
    return q.reshape(NC, 2), n.reshape(NC, 2)


def cmd_train(a):
    init = a.init or os.path.join(HERE, 'fq-c1.lisp')
    _, apply_, arms, q_init = read_table(init)
    apply_ = apply_ or '(:ichigo :kenpachi)'               # (fq-c1.lisp predates :apply: IK)
    tag = a.tag or apply_[2:-1].replace(' :', '-')
    (S, A, D, T, S2, DONE, U), stats = load(*seed_range(a.seeds), tag)
    R = a.scale * D + T
    c1 = np.argmax(q_init, axis=1)                        # (pi0: the init table's greedy arm per cell; ties -> arm 0, as the runtime)
    units, uix = np.unique(U, return_inverse=True)
    rng = np.random.default_rng(a.boot_seed)
    boots = [rng.multinomial(len(units), np.full(len(units), 1.0 / len(units)))[uix].astype(float) for _ in range(a.boot)]
    ones = np.ones(len(S))
    pi = c1.copy()
    for rnd in range(a.rounds):
        frac = np.zeros(NC)
        for w in boots:
            qb, _ = fqe(S, A, R, S2, DONE, w, pi, a.gamma)
            frac += np.nan_to_num(qb[np.arange(NC), 1 - c1] > qb[np.arange(NC), c1]).astype(float)
        frac /= len(boots)
        q, n = fqe(S, A, R, S2, DONE, ones, pi, a.gamma)
        new = np.where((frac >= a.conf) & (n[np.arange(NC), 1 - c1] >= a.nmin), 1 - c1, c1)
        print(f'round {rnd}: flips {[int(c) for c in np.nonzero(new != c1)[0]]}', flush=True)
        if (new == pi).all():
            break
        pi = new
    q, n = fqe(S, A, R, S2, DONE, ones, pi, a.gamma)
    tab = np.nan_to_num(q, nan=0.0)
    for c in range(NC):                                   # (the written table's argmax = the gated policy)
        p, o = pi[c], 1 - pi[c]
        if not tab[c, p] > tab[c, o]:
            if pi[c] == c1[c]:
                tab[c, o] = tab[c, p] - 1e-3
            else:
                tab[c, p] = tab[c, o] + 1e-3
    cells = []
    for c in range(NC):
        lc, ored, free, awk, prev = cell_parts(c)
        cells.append(dict(cell=c, lead=LEAD[lc][1:], ored=ored, free=free, awk=awk, prev=prev, c1=int(c1[c]), pi=int(pi[c]),  # (c1 = pi0)
                          n0=int(n[c, 0]), n1=int(n[c, 1]), q0=None if np.isnan(q[c, 0]) else round(float(q[c, 0]), 4),
                          q1=None if np.isnan(q[c, 1]) else round(float(q[c, 1]), 4), p_other_better=round(float(frac[c]), 3)))
    res = dict(tag=tag, init=os.path.relpath(init, HERE), seeds=a.seeds, gamma=a.gamma, scale=a.scale, conf=a.conf, nmin=a.nmin, boot=a.boot, stats=stats, transitions=int(len(S)),
               flips=[int(c) for c in np.nonzero(pi != c1)[0]], cells=cells)
    out = a.out or os.path.join(HERE, 'fq-trained.lisp')
    write_table(out, ':' + os.path.splitext(os.path.basename(out))[0],
                tab, f'Fitted fuzzy Q (fq.py train --seeds {a.seeds} --gamma {a.gamma} --scale {a.scale} --conf {a.conf}): '
                     f'{len(S)} transitions, flips from c1 in cells {res["flips"]}.', arms, apply_)
    with open(os.path.splitext(out)[0] + '.json', 'w') as f:
        json.dump(res, f, indent=1)
    print(json.dumps({k: v for k, v in res.items() if k != 'cells'}, indent=1))
    for d in cells:
        if d['pi'] != d['c1'] or d['p_other_better'] >= 0.8:
            print(d)


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    p = sub.add_parser('init')
    p.add_argument('--char', default='ichigo', choices=list(ROSTER))
    p.add_argument('--vs', default='kenpachi', choices=list(ROSTER))
    p.add_argument('--arms', nargs=2, help='arm 0 and arm 1: a strategy file, a frozen id or none (default: IK\'s two KI styles)')
    p.add_argument('--policy', default='c1', choices=('c1', 'arm0'))
    p.add_argument('--out')
    p = sub.add_parser('log')
    p.add_argument('--char', default='ichigo', choices=list(ROSTER))
    p.add_argument('--vs', default='kenpachi', choices=list(ROSTER))
    p.add_argument('--table', help='the behaviour table (default fq-c1.lisp)')
    p.add_argument('--opp', help='the opponent seat: a file, a frozen id, none, or a comma list (a pool)')
    p.add_argument('--tag', help='logs/TAG (default CHAR-VS)')
    p.add_argument('--salt', type=int, required=True)
    p.add_argument('--eps', type=float, default=0.15)
    p.add_argument('--seeds', default='1-500')
    p.add_argument('-j', type=int, default=8)
    p = sub.add_parser('train')
    p.add_argument('--init', help='pi0 and the arms: a table file (default fq-c1.lisp)')
    p.add_argument('--tag', help='logs/TAG (default from the init table\'s :apply, else ichigo-kenpachi)')
    p.add_argument('--seeds', default='1-500')
    p.add_argument('--gamma', type=float, default=0.9)
    p.add_argument('--scale', type=float, default=0.1)
    p.add_argument('--conf', type=float, default=0.95)
    p.add_argument('--nmin', type=int, default=30)
    p.add_argument('--boot', type=int, default=200)
    p.add_argument('--boot-seed', type=int, default=1)
    p.add_argument('--rounds', type=int, default=4)
    p.add_argument('--out')
    a = ap.parse_args()
    {'init': cmd_init, 'log': cmd_log, 'train': cmd_train}[a.cmd](a)


if __name__ == '__main__':
    main()
