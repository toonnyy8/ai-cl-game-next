#!/usr/bin/env python3
"""gen.py — the Bevy port's answer key into build/oracle/ (git-ignored; docs/bevy/BEVY_PORT.md §6.1, M0 plan Task 7: the sim traces).

  python3 tools/port/oracle/gen.py sim               record every trace (record.lisp on the recorder's image, build-rec.lisp), check
                                                     each against a plain run of the stock image (non-perturbation), write
                                                     build/oracle/INDEX.json and cvc-tag.txt, then replay three (one per kind)
  python3 tools/port/oracle/gen.py replay [NAME ...] replay.lisp on the stock image (default: every trace in INDEX.json)
  python3 tools/port/oracle/gen.py look [--check] [--no-stills]
                                                     the look data (Task 8, look.lisp's header): build/oracle/fk/<clip>.json, sound/<key>.f32
                                                     (rendered twice in two fresh processes and compared), stills/ (the frozen dist's 83
                                                     looks-gate stills, tests/style-gates.py looks, ~minutes; --no-stills copies an
                                                     earlier render left in build/style/looks/), then the check. --check: only the check

The set: seeded CPU vs CPU for every ordered pairing of Yamamoto (0), Kenpachi (1), Ichigo (3), Hisagi (7), seeds 1-3 (the pairing gate's
match: debug 30000+s-1, 31101, 200000+100 c1+10 c2); G2's --cvc II / IK / KK (seed 7, debug 2102 + 3007 / 4007 / 5007), whose hash and
RESULTS lines are cvc-tag.txt (tests/style-cvc-ref.txt's format, checked equal to it); every combo trial file of tools/simgate/trial.lisp
(tests/trials, the research trial files of the live fighters, tests/sp-costs-check.py's scenes), one trace per file (one match carries
its trials). The browser scripts (tests/scripts/*.json) wait for M1. Trace format: trace.lisp's header.
"""
import concurrent.futures as cf, datetime, glob, hashlib, importlib.util, json, os, re, shutil, subprocess, sys

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


def provenance():
    """(lisp-freeze's short sha, whether every source of the image and the trial files equals the tag's). tools/simgate/build.lisp is
    left out: since the tag it only takes SG_STUBS, whose default writes the same unit (build-rec.lisp copies that unit)."""
    git = lambda *a: subprocess.run(['git', *a], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    paths = ['duel', 'engine', 'tools/simgate/stubs.c', 'tools/simgate/prelude.lisp', 'tools/simgate/run.lisp', 'tools/simgate/trial.lisp',
             'tests/trials', 'tests/sp-costs-check.py'] + list(RESEARCH_TRIALS.values())
    return git('rev-parse', '--short', 'lisp-freeze'), git('diff', '--stat', 'lisp-freeze', 'HEAD', '--', *paths) == ''


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
    tag_lines = [f'{j["name"][-2:]} {l}' for j in done if j['kind'] == 'cvc-tag' for l in j.pop('tag_lines', [])]
    head = subprocess.run(['git', 'rev-parse', '--short', 'HEAD'], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    freeze, same = provenance()
    with open(os.path.join(OUT, 'cvc-tag.txt'), 'w') as f:
        f.write(f'# cvc-tag.txt (tools/port/oracle/gen.py, {datetime.date.today()}, at {head}; lisp-freeze {freeze}, sources equal to the tag: {same}; the native image): G2\'s three CPU matches, '
                'seed 7 II / IK / KK (debug 2102 + 3007 / 4007 / 5007), their RESULTS and 600-tick hash lines in tests/style-cvc-ref.txt\'s '
                'format (M2\'s reference; equal to that file at the tag).\n' + '\n'.join(tag_lines) + '\n')
    with open(os.path.join(ROOT, 'tests/style-cvc-ref.txt')) as f:
        ref = [l.rstrip('\n') for l in f if not l.startswith('#')]
    print(f'[oracle] cvc-tag.txt: {len(tag_lines)} lines, {"equal to" if tag_lines == ref else "DIFFERENT from"} tests/style-cvc-ref.txt\'s', flush=True)
    index = {'generated': str(datetime.date.today()), 'commit': head, 'lisp_freeze': freeze, 'sources_equal_tag': same, 'format': 'tools/port/oracle/trace.lisp (header)',
             'image': 'build/simgate/duel.fas (replay); build/oracle/rec/duel.fas (record: the same unit plus *oracle-brain-hook*)',
             'cvc_tag': 'cvc-tag.txt', 'traces': done, 'excluded': EXCLUDED,
             'deferred': 'tests/scripts/*.json (browser scripts): M1 brings the scripted-input path on the native image'}
    with open(os.path.join(OUT, 'INDEX.json'), 'w') as f:
        json.dump(index, f, indent=1)
    errors = [j['name'] for j in done if 'error' in j] + ([] if tag_lines == ref else ['cvc-tag.txt'])
    total = sum(j.get('bytes', 0) for j in done)
    print(f'[oracle] {len(done)} traces, {sum(j.get("steps", 0) for j in done)} steps, {total / 1e6:.0f} MB; errors: {errors or "none"}')
    bad = replay([p for p in PICKS if p not in errors])
    sys.exit(1 if errors or bad else 0)


FK, SOUND, STILLS = (os.path.join(OUT, d) for d in ('fk', 'sound', 'stills'))
FROZEN_DIST = '/media/8tsp/projects/ai-cl-game-next/dist/duel'   # the frozen browser build (index.wasm sha256 e35032a7...)
N_SOUNDS, N_STILLS, FK_JOBS = 51, 83, 6


def look_check():
    """The look side of the key is complete: one FK file per clip of clips.json, 51 nonzero finite sounds, 83 stills."""
    import math, struct
    bad = []
    clips = json.load(open(os.path.join(ROOT, 'rs/duel-data/data/clips.json')))
    have = {f[:-5] for f in os.listdir(FK) if f.endswith('.json') and f != 'INDEX.json'} if os.path.isdir(FK) else set()
    if have != set(clips):
        bad.append(f'fk: {len(have)} files, {len(set(clips) - have)} clips missing, {len(have - set(clips))} extra')
    snd = sorted(f for f in os.listdir(SOUND) if f.endswith('.f32')) if os.path.isdir(SOUND) else []
    if len(snd) != N_SOUNDS:
        bad.append(f'sound: {len(snd)} files, want {N_SOUNDS}')
    for f in snd:
        data = open(os.path.join(SOUND, f), 'rb').read()
        xs = struct.unpack(f'<{len(data) // 4}f', data)
        if not xs or len(data) % 4 or not all(map(math.isfinite, xs)) or not any(xs):
            bad.append(f'sound {f}: empty, not finite or all zero')
    st = [f for f in os.listdir(STILLS) if f.endswith('.png')] if os.path.isdir(STILLS) else []
    if len(st) != N_STILLS:
        bad.append(f'stills: {len(st)}, want {N_STILLS}')
    print(f'[oracle] look check: {len(have)} FK files / {len(clips)} clips, {len(snd)} sounds, {len(st)} stills; '
          f'{"PASS" if not bad else "FAIL: " + "; ".join(bad)}', flush=True)
    return not bad


def look_sound(out):
    """look.lisp sound into OUT (a fresh process); -> {key: (samples, loop, peak, bad)}."""
    shutil.rmtree(out, ignore_errors=True)
    r = lisp('tools/port/oracle/look.lisp', FAS, ['sound', out])
    if r.returncode:
        sys.exit(r.stdout[-2000:] + r.stderr[-2000:] + '\n[oracle] look sound FAILED')
    return {m[0]: (int(m[1]), m[2] != 'NIL', m[3], int(m[4])) for m in re.findall(r'^sound (\S+) (\d+) (\S+) (\S+) (\d+)$', r.stdout, re.M)}


def look_stills(render):
    """The frozen dist's looks-gate stills (style-gates looks BASE = NEW = the frozen dist: three renders) -> build/oracle/stills/.
    RENDER false: reuse the render already in build/style/looks/ (its log: build/oracle/looks-gate.log)."""
    wasm = hashlib.sha256(open(os.path.join(FROZEN_DIST, 'index.wasm'), 'rb').read()).hexdigest()
    if not wasm.startswith('e35032a7'):
        sys.exit(f'[oracle] {FROZEN_DIST}/index.wasm is {wasm[:8]}, not the frozen build e35032a7')
    src = os.path.join(ROOT, 'build/style/looks')
    rc = 'not run (--no-stills)'
    if render:
        shutil.rmtree(src, ignore_errors=True)
        r = subprocess.run([sys.executable, 'tests/style-gates.py', 'looks', FROZEN_DIST, FROZEN_DIST, '--jobs', '4'], cwd=ROOT,
                           capture_output=True, text=True, timeout=TIMEOUT)
        with open(os.path.join(OUT, 'looks-gate.log'), 'w') as f:
            f.write(r.stdout + r.stderr)
        rc = r.returncode
    shutil.rmtree(STILLS, ignore_errors=True)
    os.makedirs(STILLS)
    for p in glob.glob(os.path.join(src, 'base1', '*.png')):
        shutil.copy2(p, STILLS)
    same = sum(open(p, 'rb').read() == open(os.path.join(src, t, os.path.basename(p)), 'rb').read()
               for p in glob.glob(os.path.join(src, 'base1', '*.png')) for t in ('base2', 'new'))
    print(f'[oracle] stills: {len(os.listdir(STILLS))} copied (frozen dist {wasm[:8]}); byte-identical to the other two renders: '
          f'{same} of {2 * len(os.listdir(STILLS))}; style-gates exit {rc} (build/oracle/looks-gate.log)', flush=True)


def look():
    build()
    look_stills('--no-stills' not in sys.argv)
    a, b = look_sound(SOUND), look_sound(os.path.join(OUT, 'sound-2'))
    diff = [k for k in a if open(os.path.join(SOUND, k + '.f32'), 'rb').read() != open(os.path.join(OUT, 'sound-2', k + '.f32'), 'rb').read()]
    print(f'[oracle] sound: {len(a)} rendered twice in two fresh processes; {len(a) - len(diff)} identical'
          f'{", DIFFER: " + " ".join(diff) if diff or a.keys() != b.keys() else ""}', flush=True)
    shutil.rmtree(os.path.join(OUT, 'sound-2'))
    with open(os.path.join(SOUND, 'INDEX.json'), 'w') as f:
        json.dump({k: {'samples': n, 'loop': lp, 'peak': pk, 'nan_inf_zeroed': bad,
                       'sha1': hashlib.sha1(open(os.path.join(SOUND, k + '.f32'), 'rb').read()).hexdigest()}
                   for k, (n, lp, pk, bad) in a.items()}, f, indent=1)
    shutil.rmtree(FK, ignore_errors=True)
    with cf.ThreadPoolExecutor(FK_JOBS) as ex:
        rs = list(ex.map(lambda s: lisp('tools/port/oracle/look.lisp', FAS, ['fk', FK, s, FK_JOBS]), range(FK_JOBS)))
    for r in rs:
        if r.returncode:
            sys.exit(r.stdout[-2000:] + r.stderr[-2000:] + '\n[oracle] look fk FAILED')
    lines = [l for r in rs for l in r.stdout.splitlines() if l.startswith('fk ')]
    size = sum(os.path.getsize(os.path.join(FK, f)) for f in os.listdir(FK))
    index = {}
    for f in sorted(os.listdir(FK)):
        d = json.load(open(os.path.join(FK, f)))
        index[d['clip']] = {'frames': d['frames'], 'dur': d['dur'], 'loop': d['loop'], 'rigs': [r['bodies'] for r in d['rigs']],
                            'forms': [[x['form'], x['by'], x['weapon']] for x in d['forms']]}
    with open(os.path.join(FK, 'INDEX.json'), 'w') as f:
        json.dump(index, f, indent=1)
    by = {}
    for c in index.values():
        k = c['forms'][0][1] if c['forms'] else 'none'
        by[k] = by.get(k, 0) + 1
    print(f'[oracle] fk: {len(lines)} clips, {size / 1e6:.0f} MB; clips by attribution {by} (fk/INDEX.json)', flush=True)
    sys.exit(0 if look_check() and not diff and a.keys() == b.keys() else 1)


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'look':
        if '--check' in sys.argv:
            sys.exit(0 if look_check() else 1)
        look()
    if cmd == 'sim':
        sim()
    elif cmd == 'replay':
        names = sys.argv[2:] or [j['name'] for j in json.load(open(os.path.join(OUT, 'INDEX.json')))['traces'] if 'error' not in j]
        sys.exit(1 if replay(names) else 0)
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
