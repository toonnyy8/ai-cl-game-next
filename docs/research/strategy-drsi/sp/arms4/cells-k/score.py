#!/usr/bin/env python3
"""score.py — the cells-k scorer (PLAN4 §3 "the scorer is the played policy"; B3 Kenpachi side, 2026-11-15).

  python3 score.py WS NODE_DIR [--seed0 300] [-j 4]

NODE_DIR/arm.lisp holds ONE arm plist (the cell's candidate). For each table of workspace WS (CONF below) the side's T0 is rewritten with that
arm in its slot (the slot's job rules unchanged; for i-vsh the arm joins as a fifth arm with the job rules of NODE_DIR/job.json), written to
NODE_DIR/cand-<pair>.lisp, and scored by eval.py (K.O.-only, HARD, both seats) against the opponent's population file here (pop-*.json:
anchor his `none`, mix = none and his T0 by seed, rest = his T0). Score = the mean of the tables' eval scores. Prints one JSON line.

Each table is ONE eval.py call: k-rush and k-guard cost two a score (KI and KH), k-wave and i-vsh one.

eval.py runs from the main checkout (MAIN below): the cells' pin SP_BUILD=b835ac41b83b is that checkout's sim build. A worktree's
build/simgate/duel.fas embeds its own path, so its hash differs although the sources are identical (checked: duel/, engine/, strat-run.lisp,
simlib.py, strategy-switch.py, eval.py all equal main 59a9f779).
"""
import argparse, importlib.util, json, os, re, subprocess, sys, types
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
A4 = os.path.dirname(HERE)
MAIN = '/media/8tsp/projects/ai-cl-game-next'
EVAL = os.path.join(MAIN, 'docs/research/strategy-drsi/sp/eval.py')
PIN = 'b835ac41b83b'

_s = importlib.util.spec_from_file_location('proof', os.path.join(A4, 'proof.py'))
proof = importlib.util.module_from_spec(_s); _s.loader.exec_module(proof)

# table: (opponent, map, :with unit, q, pop file)
KI = ('ichigo', 'cells-k/maps-at-search/ki-kenpachi.json', 'x-units/d-x-ki-k.lisp', 0.075, 'pop-ki-I.json')
KH = ('hisagi', 'cells-k/maps-at-search/kh-kenpachi.json', 'x-units/d-x-kh-k.lisp', 0.075, 'pop-kh-H.json')
IH = ('hisagi', 't0/ih-ichigo.json', 'x-units/d-x-ih-i.lisp', 0.06, 'pop-ih-H.json')
CONF = {
    'k-rush':  dict(me='kenpachi', slot='a4-k-rush', tables=[KI, KH]),
    'k-guard': dict(me='kenpachi', slot='a4-k-guard', tables=[KI, KH]),
    'k-wave':  dict(me='kenpachi', slot='a4-k-wave', tables=[KI]),
    'i-vsh':   dict(me='ichigo', slot='a4-i-vsh', tables=[IH], new=True),
}
PAIR = {('kenpachi', 'ichigo'): 'ki', ('kenpachi', 'hisagi'): 'kh', ('ichigo', 'hisagi'): 'ih'}


def one_plist(path):
    t = proof.ss.strip_lisp(open(path).read()).strip()
    if not t.startswith('(') or proof.ss.form_end(t, 0) != len(t):
        sys.exit(f'score: {path}: not exactly one plist')
    return ' '.join(t.split())


def build_table(ws, node, tab):
    c = CONF[ws]
    vs, mp, unit, q, _ = tab
    m = json.load(open(os.path.join(A4, mp)))
    arm = one_plist(os.path.join(node, 'arm.lisp'))
    aid = re.search(r':id\s+:([^\s()]+)', arm)
    if not aid or aid[1].lower() != c['slot']:
        sys.exit(f"score: arm.lisp's :id must be :{c['slot']} (found {aid[1] if aid else 'none'})")
    if not re.search(r':apply\s+\(:' + c['me'] + r'\)', arm):
        sys.exit(f"score: arm.lisp needs :apply (:{c['me']})")
    if proof.band.ev.UNIT_IDS.search(re.sub(r':id\s+[^\s()]+', '', arm, flags=re.I)):
        sys.exit('score: arm.lisp must be inline (no :style / :data / unit ids)')
    x = re.search(r':(xch-sa-p|xch-carry-p|xch-j|clash-p|clash-margin|xch-sa-wait|awaken-break-p|awaken-kikon-p)\b', arm)
    if x:
        sys.exit(f'score: arm.lisp names the exchange key :{x[1]}: those come from the pairing\'s :with unit (KNOBS.md §6.5, PLAN4 §3)')
    scratch = os.path.join(node, 'scratch', 'tables')
    os.makedirs(scratch, exist_ok=True)
    files, jobs = [], list(m['jobs'])
    for ref in m['arms']:
        f, rid = ref.split('#')
        txt = arm if rid == c['slot'] else proof.forms(os.path.join(A4, f))[rid]
        p = os.path.join(scratch, rid + '.lisp')
        open(p, 'w').write(txt + '\n')
        files.append(p)
    if c.get('new'):
        jp = os.path.join(node, 'job.json')
        if not os.path.exists(jp):
            sys.exit('score: i-vsh needs NODE_DIR/job.json ({"job": [[G, ["(:cue :set)", ...]], ...], ...}) written before the first eval')
        jobs.append(json.load(open(jp))['job'])
        p = os.path.join(scratch, c['slot'] + '.lisp')
        open(p, 'w').write(arm + '\n')
        files.append(p)
    tmp = os.path.join(scratch, f'map-{PAIR[(c["me"], vs)]}.json')
    json.dump(dict(arms=files, jobs=jobs), open(tmp, 'w'))
    out = os.path.join(node, f'cand-{PAIR[(c["me"], vs)]}.lisp')
    import contextlib, io
    with contextlib.redirect_stdout(io.StringIO()):
        proof.band.cmd_t0(types.SimpleNamespace(me=c['me'], vs=vs, map=tmp, out=out, q=q, or_=True,
                                                with_=[os.path.join(A4, unit)], margin=0.02, period=30))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('ws', choices=list(CONF)); ap.add_argument('node')
    ap.add_argument('--seed0', type=int, default=300); ap.add_argument('-j', type=int, default=4)
    a = ap.parse_args()
    if a.seed0 not in (200, 300):
        sys.exit('score: --seed0 300 (the cells) or 200 (the coordinator\'s rescore) only')
    node = os.path.abspath(a.node)
    c = CONF[a.ws]
    env = dict(os.environ, SP_BUILD=PIN)
    parts = {}
    for tab in c['tables']:
        cand = build_table(a.ws, node, tab)
        r = subprocess.run([sys.executable, EVAL, '--me', c['me'], '--vs', tab[0], '--cand', cand, '--seed0', str(a.seed0),
                            '--pop', os.path.join(HERE, tab[4]), '-j', str(a.j)], cwd=MAIN, env=env, capture_output=True, text=True,
                           stdin=subprocess.DEVNULL)
        line = (r.stdout.strip().splitlines() or [''])[-1]
        if r.returncode or not line.startswith('{'):
            print(json.dumps(dict(error=f'eval.py vs {tab[0]} exited {r.returncode}', stderr=(r.stderr or r.stdout)[-1500:])))
            sys.exit(1)
        d = json.loads(line)
        parts[tab[0]] = dict(score=d['score'], groups={g: {k: v[k] for k in ('ko_wins', 'ko_losses', 'timeouts', 'matches', 'share')}
                                                       for g, v in d['groups'].items()}, build=d['build'][:12])
    print(json.dumps(dict(ws=a.ws, node=os.path.relpath(node, A4), seed0=a.seed0,
                          score=round(sum(p['score'] for p in parts.values()) / len(parts), 4), parts=parts)))


if __name__ == '__main__':
    main()
