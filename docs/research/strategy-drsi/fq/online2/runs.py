#!/usr/bin/env python3
"""runs.py — online2's configurations (online2.md §3): per pairing x proxy x eps, online.py train (4 runs x 125 matches, seeds 1-500, Ichigo
learning on P2 from the shipped table, the frozen table on the same seeds), then each run's final table frozen: online.py heldout against the
proxy on 601-800 and against the opponent's shipped HARD CPU on 501-600, both seats, plus online.py stats.
  usage: runs.py WORK [TAG ...]   WORK: a scratch folder for the per-chunk tables; train.json, the final tables and the JSONL land in out/ here.
Tags: <ki|ih>-<shipped|istyle>-e<eps x 1000> (e.g. ki-istyle-e050); a suffix d<K> = eps / (1 + matches / K) by chunk (online.py --eps-decay);
a suffix -n<eta x 1000> = that eta (default 0.05, the shipped one; e.g. ih-shipped-e000-n005: eta 0.005)."""
import json, os, re, shutil, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
FQ = os.path.dirname(HERE)
PROX = json.load(open(os.path.join(HERE, 'proxies.json')))['proxies']
PAIR = {'ki': ('ichigo', 'kenpachi'), 'ih': ('ichigo', 'hisagi')}


def config(tag):
    m = re.fullmatch(r'(ki|ih)-(shipped|istyle)-e(\d+)(?:d(\d+))?(?:-n(\d+))?', tag)
    p, px, e, d, n = m.groups()
    return p, px, int(e) / 1000, d and int(d), int(n) / 1000 if n else 0.05


def online(*args):
    r = subprocess.run([sys.executable, 'online.py', *map(str, args)], cwd=FQ, capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stdout[-2000:] + r.stderr[-2000:])
    return r.stdout


def run(work, tag):
    p, px, eps, dk, eta = config(tag)
    me, vs = PAIR[p]
    table = f'online2/t0-{p}-ichigo.lisp'
    proxy = PROX[f'{me}-{vs}'][px]
    pa = ['--char', me, '--vs', vs, '--table', table]
    online('train', *pa, *(['--proxy', proxy] if proxy else []), '--tag', tag, '--eta', eta, '--eps', eps, *(['--eps-decay', dk] if dk else []),
           '--runs', 4, '--seeds', '1-500', '--out-root', work)
    src = os.path.join(work, f'{me}-{vs}', tag)
    dst = os.path.join(HERE, 'out', tag)
    os.makedirs(dst, exist_ok=True)
    tj = json.load(open(os.path.join(src, 'train.json')))
    finals = []
    for t in tj['tables']:                                # (the final table of each run; the per-chunk ones stay in WORK)
        f = os.path.join(dst, os.path.basename(t))
        shutil.copy(os.path.join(src, os.path.basename(t)), f)
        finals.append(f)
    tj['tables'] = [os.path.relpath(f, os.path.join(FQ, '../../../..')) for f in finals]
    json.dump(tj, open(os.path.join(dst, 'train.json'), 'w'), indent=1)
    with open(os.path.join(dst, 'heldout-proxy-601-800.jsonl'), 'w') as o:
        o.write(online('heldout', *pa, *(['--proxy', proxy] if proxy else []), '--learned', *finals, '--seed0', 600, '--n', 200))
    with open(os.path.join(dst, 'heldout-shipped-501-600.jsonl'), 'w') as o:
        o.write(online('heldout', *pa, '--learned', *finals, '--seed0', 500, '--n', 100))
    with open(os.path.join(dst, 'stats.jsonl'), 'w') as o:
        o.write(online('stats', *pa, *finals))
    print(tag, 'live', tj['learner'], '/', tj['q1'], 'of', tj['n'], 'z', tj['z'], flush=True)


if __name__ == '__main__':
    work = os.path.abspath(sys.argv[1])
    tags = sys.argv[2:] or [f'{p}-{px}-e{e:03d}' for p in ('ki', 'ih') for px in ('shipped', 'istyle') for e in (0, 50, 100)]
    for t in tags:
        run(work, t)
