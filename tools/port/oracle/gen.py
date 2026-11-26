#!/usr/bin/env python3
"""gen.py — the Bevy port's answer key into build/oracle/ (git-ignored; docs/bevy/BEVY_PORT.md §6.1, M0 plan Task 7: the sim traces).

  python3 tools/port/oracle/gen.py sim               record every trace (record.lisp on the recorder's image, build-rec.lisp), check
                                                     each against a plain run of the stock image (non-perturbation), write
                                                     build/oracle/INDEX.json and cvc-tag.txt, then replay three (one per kind)
  python3 tools/port/oracle/gen.py replay [NAME ...] replay.lisp on the stock image (default: every trace in INDEX.json)

The set: seeded CPU vs CPU for every ordered pairing of Yamamoto (0), Kenpachi (1), Ichigo (3), Hisagi (7), seeds 1-3 (the pairing gate's
match: debug 30000+s-1, 31101, 200000+100 c1+10 c2); G2's --cvc II / IK / KK (seed 7, debug 2102 + 3007 / 4007 / 5007), whose hash and
RESULTS lines are cvc-tag.txt (tests/style-cvc-ref.txt's format; that file is stale); every combo trial file of tools/simgate/trial.lisp
(tests/trials, the research trial files of the live fighters, tests/sp-costs-check.py's scenes), one trace per file (one match carries
its trials). The browser scripts (tests/scripts/*.json) wait for M1. Trace format: trace.lisp's header.
"""
import concurrent.futures as cf, datetime, glob, hashlib, importlib.util, json, os, re, subprocess, sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..'))
from simlib import ROOT, ECL, FAS, MUSLM, build   # noqa: E402

OUT = os.path.join(ROOT, 'build/oracle')
TRACES = os.path.join(OUT, 'traces')
REC_FAS = os.path.join(OUT, 'rec/duel.fas')
FIGHTERS = {'y': (0, 'YAMAMOTO'), 'k': (1, 'KENPACHI'), 'i': (3, 'ICHIGO'), 'h': (7, 'HISAGI')}
TAG = {'ii': 3007, 'ik': 4007, 'kk': 5007}
RESEARCH_TRIALS = {'ki-ai-kenpachi': 'docs/research/ki-ai/kenpachi/trials.lisp', 'ki-ai-ichigo': 'docs/research/ki-ai/ichigo/trials.lisp',
                   'sp-kits-kenpachi': 'docs/research/strategy-drsi/sp/kits/kenpachi/trials.lisp',
                   'sp-kits-ichigo': 'docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp',
                   'sp-kits-hisagi': 'docs/research/strategy-drsi/sp/kits/hisagi/trials.lisp',
                   'sp-xch-r3': 'docs/research/strategy-drsi/sp/arms6/xch/r3-trial.lisp',
                   'sp-xch-r4': 'docs/research/strategy-drsi/sp/arms6/xch/r4-trial.lisp'}
EXCLUDED = {p: 'Rukia is retired (2026-11-12): her kit is not in the image'
            for p in sorted(glob.glob('docs/research/rukia-cpu/*.lisp', root_dir=ROOT))}
PICKS = ('cvc-hk-s2', 'cvc-yy-s3', 'trial-sp-costs')   # gen.py sim's replays: a cross pairing, a mirror, a trial file
JOBS, TIMEOUT = 6, 3600


def lisp(script, fas, args):
    return subprocess.run([ECL, '--norc', '--load', script, '--', fas] + [str(a) for a in args], cwd=ROOT, capture_output=True,
                          text=True, env=dict(os.environ, LD_PRELOAD=MUSLM), timeout=TIMEOUT)


def build_rec():
    unit = os.path.join(ROOT, 'build/simgate/simgate-all.lisp')
    src = [unit, os.path.join(HERE, 'build-rec.lisp')]
    if os.path.exists(REC_FAS) and os.path.getmtime(REC_FAS) >= max(map(os.path.getmtime, src)):
        return
    print('[oracle] building the recorder image build/oracle/rec/duel.fas (~3 min)', file=sys.stderr, flush=True)
    r = subprocess.run([ECL, '--norc', '--load', 'tools/port/oracle/build-rec.lisp'], cwd=ROOT, capture_output=True, text=True)
    if r.returncode or not os.path.exists(REC_FAS):
        sys.exit(r.stdout[-3000:] + r.stderr[-3000:] + '\n[oracle] recorder image BUILD FAILED')


def sp_costs_file():
    """tests/sp-costs-check.py's trial scenes as a trial file (its TRIALS(), as it writes them)."""
    spec = importlib.util.spec_from_file_location('sp_costs_check', os.path.join(ROOT, 'tests/sp-costs-check.py'))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    path = 'build/oracle/sp-costs-trials.lisp'
    with open(os.path.join(ROOT, path), 'w') as f:
        f.write('\n'.join(m.trials()) + '\n')
    return path


def jobs():
    out = []
    for a in FIGHTERS:
        for b in FIGHTERS:
            for s in (1, 2, 3):
                out.append({'name': f'cvc-{a}{b}-s{s}', 'kind': 'cvc', 'pair': [FIGHTERS[a][1], FIGHTERS[b][1]], 'seed': s,
                            'start': ['cmds', 30000 + s - 1, 31101, 200000 + 100 * FIGHTERS[a][0] + 10 * FIGHTERS[b][0]]})
    for p, c in TAG.items():
        out.append({'name': f'cvctag-{p}', 'kind': 'cvc-tag', 'pair': [FIGHTERS[p[0]][1], FIGHTERS[p[1]][1]], 'seed': 7,
                    'start': ['cmds', 2102, c]})
    files = {f'trial-{os.path.splitext(os.path.basename(p))[0]}': p for p in sorted(glob.glob('tests/trials/*.lisp', root_dir=ROOT))}
    files |= {f'trial-{k}': p for k, p in RESEARCH_TRIALS.items()}
    files['trial-sp-costs'] = sp_costs_file()
    out += [{'name': n, 'kind': 'trials', 'file': p, 'start': ['trials', p]} for n, p in files.items()]
    return out


def compared(out, kind):
    """The console lines a recording must share with the plain run: the 600-tick hash lines and RESULTS (a match), the combat log and
    the trial end lines (a trial file, whose runner keeps the log on)."""
    pat = r'\[|trial end ' if kind == 'trials' else r'duel (hash|-> RESULTS winner)'
    return [l for l in out.splitlines() if re.match(pat, l)]


def record(j):
    trace = os.path.join(TRACES, j['name'] + '.trace')
    rec = lisp('tools/port/oracle/record.lisp', REC_FAS, [trace] + j['start'])
    plain = (lisp('tools/simgate/trial.lisp', FAS, [j['file']]) if j['kind'] == 'trials'
             else lisp('tools/simgate/run.lisp', FAS, j['start'][1:]))
    m = re.search(r'^rec steps (\d+) start-miss (\d+).* post-draw (\d+)', rec.stdout, re.M)
    j = dict(j, path=os.path.relpath(trace, OUT))
    if rec.returncode or plain.returncode or not m:
        return dict(j, error=f'record exit {rec.returncode}, plain exit {plain.returncode}: ' + (rec.stdout + rec.stderr)[-1500:])
    got, want = compared(rec.stdout, j['kind']), compared(plain.stdout, j['kind'])
    with open(trace, 'rb') as f:
        data = f.read()
    text = data.decode()
    ticks = [int(l.split()[1]) for l in text.splitlines() if l.startswith('T ')]
    j |= {'steps': int(m[1]), 'last_tick': ticks[-1] if ticks else None, 'bytes': len(data), 'sha1': hashlib.sha1(data).hexdigest(),
          'start_miss': int(m[2]), 'post_draw': int(m[3]), 'compared_lines': len(want), 'nonperturbed': got == want}
    if j['kind'] == 'trials':
        j['trials'] = re.findall(r'^# trial begin (.*)$', text, re.M)
    if j['kind'] == 'cvc-tag':
        j['tag_lines'] = [l for l in rec.stdout.splitlines() if re.match(r'duel (-> RESULTS winner|hash)', l)]
    if not j['nonperturbed']:
        j['error'] = f'the recording moved the run: {len(got)} compared lines vs the plain run\'s {len(want)}'
    return j


def replay(names):
    def one(n):
        r = lisp('tools/port/oracle/replay.lisp', FAS, [os.path.join(TRACES, n + '.trace')])
        line = next((l for l in r.stdout.splitlines() if l.startswith('replay ')), f'replay: no verdict (exit {r.returncode})')
        return n, r.returncode, line
    bad = 0
    with cf.ThreadPoolExecutor(JOBS) as ex:
        for n, rc, line in ex.map(one, names):
            print(f'{n}: {line}', flush=True)
            bad += rc != 0
    return bad


def sim():
    build()
    build_rec()
    os.makedirs(TRACES, exist_ok=True)
    js = jobs()
    with cf.ThreadPoolExecutor(JOBS) as ex:
        done = list(ex.map(record, js))
    for j in done:
        print(f"{j['name']}: {j.get('steps')} steps, {j.get('bytes', 0) / 1e6:.1f} MB, start-miss {j.get('start_miss')}, "
              f"post-draw {j.get('post_draw')}{', ERROR ' + j['error'] if 'error' in j else ''}", flush=True)
    tag = [f'{j["name"][-2:]} {l}' for j in done if j['kind'] == 'cvc-tag' for l in j.pop('tag_lines', [])]
    head = subprocess.run(['git', 'rev-parse', '--short', 'HEAD'], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    with open(os.path.join(OUT, 'cvc-tag.txt'), 'w') as f:
        f.write(f'# cvc-tag.txt (tools/port/oracle/gen.py, {datetime.date.today()}, at {head}, the native image): G2\'s three CPU matches, '
                'seed 7 II / IK / KK (debug 2102 + 3007 / 4007 / 5007), their RESULTS and 600-tick hash lines in tests/style-cvc-ref.txt\'s '
                'format; it replaces that stale file for M2.\n' + '\n'.join(tag) + '\n')
    index = {'generated': str(datetime.date.today()), 'commit': head, 'format': 'tools/port/oracle/trace.lisp (header)',
             'image': 'build/simgate/duel.fas (replay); build/oracle/rec/duel.fas (record: the same unit plus *oracle-brain-hook*)',
             'cvc_tag': 'cvc-tag.txt', 'traces': done, 'excluded': EXCLUDED,
             'deferred': 'tests/scripts/*.json (browser scripts): M1 brings the scripted-input path on the native image'}
    with open(os.path.join(OUT, 'INDEX.json'), 'w') as f:
        json.dump(index, f, indent=1)
    errors = [j['name'] for j in done if 'error' in j]
    total = sum(j.get('bytes', 0) for j in done)
    print(f'[oracle] {len(done)} traces, {sum(j.get("steps", 0) for j in done)} steps, {total / 1e6:.0f} MB; errors: {errors or "none"}')
    bad = replay([p for p in PICKS if p not in errors])
    sys.exit(1 if errors or bad else 0)


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'sim':
        sim()
    elif cmd == 'replay':
        names = sys.argv[2:] or [j['name'] for j in json.load(open(os.path.join(OUT, 'INDEX.json')))['traces'] if 'error' not in j]
        sys.exit(1 if replay(names) else 0)
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
