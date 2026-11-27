#!/usr/bin/env python3
"""gen.py — the Bevy port's answer key into build/oracle/ (git-ignored; docs/bevy/BEVY_PORT.md §6.1, M0 plan Task 7: the sim traces).

  python3 tools/port/oracle/gen.py sim [NAME ...]    (NAMEs: record and replay only those, then merge the entries of those whose replay
                                                     passed into INDEX.json by name; a cvctag-* among them rewrites its own lines of
                                                     cvc-tag.txt, the rest of the file kept)
                                                     record every trace (record.lisp on the recorder's image, build-rec.lisp), check
                                                     each against a plain run of the stock image (non-perturbation), write
                                                     build/oracle/INDEX.json and cvc-tag.txt, then replay three (one per kind)
  python3 tools/port/oracle/gen.py replay [--live] [NAME ...]
                                                     replay.lisp on the stock image (default: every trace in INDEX.json); --live: the
                                                     brains think and the whole A line is compared (a vs-* trace on the recorder's image,
                                                     its in-memory page on)
  python3 tools/port/oracle/gen.py look [--check] [--no-stills]
                                                     the look data (Task 8, look.lisp's header): build/oracle/fk/<clip>.json, sound/<key>.f32
                                                     (rendered twice in two fresh processes and compared), stills/ (the frozen dist's 83
                                                     looks-gate stills, tests/style-gates.py looks, ~minutes; --no-stills copies an
                                                     earlier render left in build/style/looks/), then the check. --check: only the check
  python3 tools/port/oracle/gen.py draw [NAME ...] [--check]
                                                     the draw key (M3a Task 1, docs/bevy/M3A_NOTES.md §1): builds build/oracle/draw-img/duel.fas
                                                     (SG_STUBS=tools/port/oracle/stubs-draw.c, whose header is the format), runs each scene of
                                                     tools/port/oracle/draw-scenes.json (draw.lisp) twice in fresh processes, requires the two
                                                     .bin files byte-identical, then writes build/oracle/draw/<scene>.bin + .log, meshes.json
                                                     and INDEX.json (NAMEs: only those, merged by name) and runs the check. --check: only the
                                                     check (counts, NaN, mesh ids, hb in battle frames)

The set: seeded CPU vs CPU for every ordered pairing of Yamamoto (0), Kenpachi (1), Ichigo (3), Hisagi (7), seeds 1-3 (the pairing gate's
match: debug 30000+s-1, 31101, 200000+100 c1+10 c2), plus KI seed 1 at HARD and at EASY (cvc-ki-s1-hard / -easy: debug 81022 / 81020
first, the gates' difficulty); G2's --cvc II / IK / KK (seed 7, debug 2102 + 3007 / 4007 / 5007), whose hash and
RESULTS lines are cvc-tag.txt (tests/style-cvc-ref.txt's format, checked equal to it); every combo trial file of tools/simgate/trial.lisp
(tests/trials, the research trial files of the live fighters, tests/sp-costs-check.py's scenes), one trace per file (one match carries
its trials); the scripted outcome traces, trial files in tools/port/oracle/scenarios/ (scr-<file name>); the vs-human traces (M2 Task 1),
scenarios/vs-*.lisp (record.lisp's vs driver; the name is the file's), whose non-perturbation run is the same driver on the recorder's
image with no hook (its in-memory page is what the stock image lacks). The browser scripts (tests/scripts/*.json) wait for M1. Trace format: trace.lisp's header.
"""
import concurrent.futures as cf, datetime, glob, hashlib, importlib.util, json, os, re, shutil, subprocess, sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..'))
from simlib import ROOT, ECL, FAS, MUSLM, build   # noqa: E402

OUT = os.path.join(ROOT, os.environ.get('ORACLE_OUT', 'build/oracle'))   # ORACLE_OUT=build/oracle2: record a new key beside the pinned one
TRACES = os.path.join(OUT, 'traces')
REC_FAS = os.path.join(OUT, 'rec/duel.fas')
FIGHTERS = {'y': (0, 'YAMAMOTO'), 'k': (1, 'KENPACHI'), 'i': (3, 'ICHIGO'), 'h': (7, 'HISAGI')}
TAG = {'ii': 3007, 'ik': 4007, 'kk': 5007}
DIF_ROWS = (('k', 'i', 'hard'), ('k', 'i', 'easy'))   # cvc-ki-s1-<dif>: the pairing gate's KI seed 1 at another difficulty (debug 81020+i)
RESEARCH_TRIALS = {'ki-ai-kenpachi': 'docs/research/ki-ai/kenpachi/trials.lisp', 'ki-ai-ichigo': 'docs/research/ki-ai/ichigo/trials.lisp',
                   'sp-kits-kenpachi': 'docs/research/strategy-drsi/sp/kits/kenpachi/trials.lisp',
                   'sp-kits-ichigo': 'docs/research/strategy-drsi/sp/kits/ichigo/trials.lisp',
                   'sp-kits-hisagi': 'docs/research/strategy-drsi/sp/kits/hisagi/trials.lisp',
                   'sp-xch-r3': 'docs/research/strategy-drsi/sp/arms6/xch/r3-trial.lisp',
                   'sp-xch-r4': 'docs/research/strategy-drsi/sp/arms6/xch/r4-trial.lisp'}
EXCLUDED = {p: 'Rukia is retired (2026-11-12): her kit is not in the image'
            for p in sorted(glob.glob('docs/research/rukia-cpu/*.lisp', root_dir=ROOT))}
SCENARIOS = 'tools/port/oracle/scenarios'   # the scripted outcome traces (M0_NOTES §4), trial files: scr-<file name>
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
    if REC_FAS != os.path.join(ROOT, 'build/oracle/rec/duel.fas'):   # (build-rec.lisp writes there only)
        sys.exit(f'[oracle] {REC_FAS} missing or stale: build it with ORACLE_OUT unset, then cp -a build/oracle/rec {OUT}/')
    print('[oracle] building the recorder image build/oracle/rec/duel.fas (~3 min)', file=sys.stderr, flush=True)
    r = subprocess.run([ECL, '--norc', '--load', 'tools/port/oracle/build-rec.lisp'], cwd=ROOT, capture_output=True, text=True)
    if r.returncode or not os.path.exists(REC_FAS):
        sys.exit(r.stdout[-3000:] + r.stderr[-3000:] + '\n[oracle] recorder image BUILD FAILED')


def sp_costs_file():
    """tests/sp-costs-check.py's trial scenes as a trial file (its TRIALS(), as it writes them)."""
    spec = importlib.util.spec_from_file_location('sp_costs_check', os.path.join(ROOT, 'tests/sp-costs-check.py'))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    path = os.path.relpath(os.path.join(OUT, 'sp-costs-trials.lisp'), ROOT)
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
    for a, b, dif in DIF_ROWS:   # (M2 final review I2: the cvc gate is NORMAL; one EASY and one HARD row, debug 81020+i first)
        out.append({'name': f'cvc-{a}{b}-s1-{dif}', 'kind': 'cvc', 'pair': [FIGHTERS[a][1], FIGHTERS[b][1]], 'seed': 1, 'difficulty': dif,
                    'start': ['cmds', 81020 + ('easy', 'normal', 'hard').index(dif), 30000, 31101,
                              200000 + 100 * FIGHTERS[a][0] + 10 * FIGHTERS[b][0]]})
    for p, c in TAG.items():
        out.append({'name': f'cvctag-{p}', 'kind': 'cvc-tag', 'pair': [FIGHTERS[p[0]][1], FIGHTERS[p[1]][1]], 'seed': 7,
                    'start': ['cmds', 2102, c]})
    files = {f'trial-{os.path.splitext(os.path.basename(p))[0]}': p for p in sorted(glob.glob('tests/trials/*.lisp', root_dir=ROOT))}
    files |= {f'trial-{k}': p for k, p in RESEARCH_TRIALS.items()}
    files['trial-sp-costs'] = sp_costs_file()
    scen = sorted(glob.glob(f'{SCENARIOS}/*.lisp', root_dir=ROOT))
    files |= {f'scr-{os.path.splitext(os.path.basename(p))[0]}': p for p in scen if not os.path.basename(p).startswith('vs-')}
    out += [{'name': n, 'kind': 'trials', 'file': p, 'start': ['trials', p]} for n, p in files.items()]
    out += [{'name': os.path.splitext(os.path.basename(p))[0], 'kind': 'vs', 'file': p, 'start': ['vs', p]}
            for p in scen if os.path.basename(p).startswith('vs-')]
    return out


def compared(out, kind):
    """The console lines a recording must share with the plain run: the 600-tick hash lines and RESULTS (a match), the combat log and
    the trial end lines (a trial file, whose runner keeps the log on)."""
    pat = {'trials': r'\[|trial end ', 'vs': r'\[|duel (hash|-> RESULTS winner|fq )'}.get(kind, r'duel (hash|-> RESULTS winner)')
    return [l for l in out.splitlines() if re.match(pat, l)]


def record(j):
    trace = os.path.join(TRACES, j['name'] + '.trace')
    rec = lisp('tools/port/oracle/record.lisp', REC_FAS, [trace] + j['start'])
    plain = (lisp('tools/simgate/trial.lisp', FAS, [j['file']]) if j['kind'] == 'trials'
             else lisp('tools/port/oracle/record.lisp', REC_FAS, ['-', 'vs', j['file']]) if j['kind'] == 'vs'
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
    if j['kind'] == 'vs':
        j['p1_presses'] = p1_presses(text)
        j['fq_lines'] = re.findall(r'^R (duel fq .*)$', text, re.M)
        j['page_writes'] = len(re.findall(r'^R page-set ', text, re.M))
    if j['kind'] == 'cvc-tag':
        j['tag_lines'] = [l for l in rec.stdout.splitlines() if re.match(r'duel (-> RESULTS winner|hash)', l)]
    if not j['nonperturbed']:
        j['error'] = f'the recording moved the run: {len(got)} compared lines vs the plain run\'s {len(want)}'
    return j


def p1_presses(text):
    """P1's presses in a trace: the rising edges of his buttons (Mod excluded) between consecutive T lines."""
    n, prev = 0, 0
    for l in text.splitlines():
        if l.startswith('T '):
            d = int(l.split()[3], 16) & ~1
            n += bin(d & ~prev).count('1')
            prev = d
    return n


def replay(names, live=False):
    def one(n):
        fas = REC_FAS if live and n.startswith('vs-') else FAS
        r = lisp('tools/port/oracle/replay.lisp', fas, [os.path.join(TRACES, n + '.trace')] + (['live'] if live else []))
        line = next((l for l in r.stdout.splitlines() if l.startswith('replay ')), f'replay: no verdict (exit {r.returncode})')
        return n, r.returncode, line
    bad = []
    with cf.ThreadPoolExecutor(JOBS) as ex:
        for n, rc, line in ex.map(one, names):
            print(f'{n}: {line}', flush=True)
            if rc != 0 or not line.startswith('replay OK'):   # (an ECL error drops into the debugger, which exits 0 at stdin's end)
                bad.append(n)
    return bad


def sim(names=()):
    build()
    build_rec()
    os.makedirs(TRACES, exist_ok=True)
    js = jobs()
    if names:   # a subset: those recorded and replayed, their INDEX.json entries replaced or added by name (the rest kept as it is)
        js = [j for j in js if j['name'] in names]
        with cf.ThreadPoolExecutor(JOBS) as ex:
            done = list(ex.map(record, js))
        for j in done:
            print(f"{j['name']}: {j.get('steps')} steps, last tick {j.get('last_tick')}, sha1 {j.get('sha1')}{', ERROR ' + j['error'] if 'error' in j else ''}", flush=True)
        recorded = [j for j in done if 'error' not in j]
        failed = set(replay([j['name'] for j in recorded]))
        good = [j for j in recorded if j['name'] not in failed]
        path = os.path.join(OUT, 'INDEX.json')
        index = json.load(open(path))
        new = {j['name']: j for j in good}
        tags = {j['name'][-2:]: [f'{j["name"][-2:]} {l}' for l in j.pop('tag_lines', [])] for j in good if j['kind'] == 'cvc-tag'}
        index['traces'] = [new.pop(t['name'], t) for t in index['traces']] + list(new.values())
        with open(path, 'w') as f:
            json.dump(index, f, indent=1)
        if tags:   # (its own pair's lines replaced, the header and the other pairs kept)
            with open(os.path.join(OUT, 'cvc-tag.txt')) as f:
                lines = f.read().splitlines()
            head, body = [l for l in lines if l.startswith('#')], [l for l in lines if not l.startswith('#')]
            body = [l for p in TAG for l in (tags[p] if p in tags else [x for x in body if x.startswith(p + ' ')])]
            with open(os.path.join(OUT, 'cvc-tag.txt'), 'w') as f:
                f.write('\n'.join(head + body) + '\n')
        print(f'[oracle] merged {len(good)} of {len(names)} into INDEX.json; cvc-tag.txt pairs rewritten: {sorted(tags) or "none"}', flush=True)
        sys.exit(0 if len(good) == len(names) else 1)
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
FROZEN_DIST = os.path.join(OUT, 'frozen-dist') if os.path.isdir(os.path.join(OUT, 'frozen-dist')) else '/media/8tsp/projects/ai-cl-game-next/dist/duel'   # the frozen browser build (index.wasm sha256 e35032a7...)
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
    RENDER false: reuse the render already in build/style/looks/ (its log: build/oracle/looks-gate.log). Stills already in place
    (83, e.g. copied from the pinned key: the browser's, never the native image's) are kept."""
    if os.path.isdir(STILLS) and len([f for f in os.listdir(STILLS) if f.endswith('.png')]) == N_STILLS:
        print(f'[oracle] stills: {N_STILLS} already in {STILLS}, kept', flush=True)
        return
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


DRAW = os.path.join(OUT, 'draw')
DRAW_FAS = os.path.join(OUT, 'draw-img/duel.fas')
DRAW_STUBS = 'tools/port/oracle/stubs-draw.c'
DRAW_SCENES = os.path.join(ROOT, 'tools/port/oracle/draw-scenes.json')
# (name, the fixed length of fu / p, else the stride the array's length is a multiple of: render.lisp 309-311, ui.lisp 55, paint.lisp 38,
# paint-shapes.lisp 50), in the file's order
DRAW_ARRAYS = (('fu', 160), ('p', 30), ('dq', 32), ('fxa', 9), ('fxb', 9), ('ui', 8), ('ft', 9), ('hb', 16), ('hk', 16))


def draw_frames(spec):
    """DRAW_FRAMES (stubs-draw.c's grammar: "a", "a-b", "a-b/k", comma separated) -> the sorted frame numbers."""
    out = set()
    for item in spec.split(','):
        m = re.fullmatch(r'(\d+)(?:-(\d+))?(?:/(\d+))?', item)
        if not m:
            sys.exit(f'[oracle] bad frame item {item!r}')
        a = int(m[1])
        out.update(range(a, int(m[2] or a) + 1, int(m[3] or 1)))
    return sorted(out)


def build_draw():
    """The draw recorder's image: tools/simgate/build.lisp's unit with SG_STUBS=stubs-draw.c (-> OUT/draw-img/duel.fas)."""
    from simlib import sources
    src = sources() + [os.path.join(ROOT, p) for p in (DRAW_STUBS, 'duel/hud-font/atlas.r8', 'duel/hud-font/metrics.bin')]
    if os.path.exists(DRAW_FAS) and os.path.getmtime(DRAW_FAS) >= max(map(os.path.getmtime, src)):
        return
    print(f'[oracle] building the draw image {os.path.relpath(DRAW_FAS, ROOT)} (~2.5 min)', file=sys.stderr, flush=True)
    r = subprocess.run([ECL, '--norc', '--load', 'tools/simgate/build.lisp', '--', os.path.relpath(DRAW_FAS, ROOT)], cwd=ROOT,
                       stdin=subprocess.DEVNULL, capture_output=True, text=True, env=dict(os.environ, SG_STUBS=DRAW_STUBS), timeout=TIMEOUT)
    if r.returncode or not os.path.exists(DRAW_FAS):
        sys.exit(r.stdout[-3000:] + r.stderr[-3000:] + '\n[oracle] draw image BUILD FAILED')


def draw_run(sc, out):
    """One fresh process of scene SC writing OUT -> (error or None, stdout)."""
    frames = draw_frames(sc['frames'])
    w, h, dpr = sc['viewport']
    env = dict(os.environ, LD_PRELOAD=MUSLM, DRAW_FRAMES=sc['frames'], DRAW_OUT=out, DRAW_W=str(w), DRAW_H=str(h), DRAW_DPR=str(dpr))
    env.pop('DRAW_DONE', None)
    args = [frames[-1] + 120] + [c if isinstance(c, int) else f'{c[0]}:{c[1]}' for c in sc['cmds']]
    if os.path.exists(out):
        os.remove(out)
    try:
        r = subprocess.run([ECL, '--norc', '--load', 'tools/port/oracle/draw.lisp', '--', DRAW_FAS] + [str(a) for a in args], cwd=ROOT,
                           stdin=subprocess.DEVNULL, capture_output=True, text=True, env=env, timeout=TIMEOUT)
    except subprocess.TimeoutExpired:
        return 'timeout', ''
    m = re.search(r'draw: (\d+) meshes made, (\d+) drawn, (\d+) frames -> ', r.stdout)
    if r.returncode or not m or int(m[3]) != len(frames) or not os.path.exists(out):   # (an ECL error lands in the debugger: exit 0)
        return f'exit {r.returncode}, {m[0] if m else "no draw: line"} (want {len(frames)} frames): ' + (r.stdout + r.stderr)[-1500:], r.stdout
    return None, r.stdout


def draw_scene(sc):
    """Scene SC run twice in fresh processes; the two .bin files must be byte-identical. -> its INDEX entry (+ '_meshes', '_inputs')."""
    name, t0 = sc['name'], datetime.datetime.now()
    out, out2 = os.path.join(DRAW, name + '.bin'), os.path.join(DRAW, '.run2', name + '.bin')
    with cf.ThreadPoolExecutor(2) as ex:
        (e1, o1), (e2, o2) = ex.map(lambda p: draw_run(sc, p), (out, out2))
    j = {k: sc[k] for k in ('name', 'group', 'about', 'viewport', 'cmds', 'frames') if k in sc} | {'named': sc.get('named', {})}
    if e1 or e2:
        return j | {'error': e1 or e2}
    with open(os.path.join(DRAW, name + '.log'), 'w') as f:   # run 1's stdout: the per-frame state lines (draw.lisp's header)
        f.write(o1)
    data = open(out, 'rb').read()
    j['identical'] = data == open(out2, 'rb').read()
    os.remove(out2)
    mesh = lambda o: {int(m[1]): (int(m[2]), m[3]) for m in re.finditer(r'^draw mesh (\d+) (\d+) (.+)$', o, re.M)}
    m = re.search(r'draw: (\d+) meshes made, (\d+) drawn, (\d+) frames', o1)
    j |= {'n_frames': int(m[3]), 'meshes_made': int(m[1]), 'meshes_drawn': int(m[2]), 'bytes': len(data),
          'sha1': hashlib.sha1(data).hexdigest(), 'rng_start': re.search(r'draw: rng at start (0x[0-9a-f]+)', o1)[1],
          'match_seed': [[int(a), int(b)] for a, b in re.findall(r'^draw seed (\d+) (-?\d+)$', o1, re.M)],
          'seconds': round((datetime.datetime.now() - t0).total_seconds(), 1), '_meshes': mesh(o1),
          '_inputs': re.findall(r'^draw inputs \S+ (.+)$', o1, re.M)}
    if not j['identical'] or mesh(o1) != mesh(o2):
        j['error'] = 'the two runs differ' + ('' if j['identical'] else ' (the .bin files)')
    return j


def draw_read(path):
    """A draw .bin -> (w, h, {id: floats}, [{frame, tick, rng, fu .. hk}]), arrays as array('f'); stubs-draw.c's header is the format."""
    import array, struct
    data = open(path, 'rb').read()
    if data[:8] != b'SDDRW1\0\0':
        raise ValueError(f'{path}: bad magic')
    w, h, nm, nf = struct.unpack_from('<4I', data, 8)
    at, meshes, frames = 24, {}, []
    def u32s(n):
        nonlocal at
        at += 4 * n
        return struct.unpack_from(f'<{n}I', data, at - 4 * n)
    def floats(n):
        nonlocal at
        a = array.array('f', data[at:at + 4 * n])
        at += 4 * n
        return a
    for _ in range(nm):
        mid, n = u32s(2)
        meshes[mid] = floats(n)
    for _ in range(nf):
        fr = dict(zip(('frame', 'tick', 'rng'), u32s(3)))
        for a, _k in DRAW_ARRAYS:
            fr[a] = floats(u32s(1)[0])
        frames.append(fr)
    if at != len(data):
        raise ValueError(f'{path}: {len(data) - at} bytes after the last frame')
    return w, h, meshes, frames


def draw_check():
    """Counts and sanity: every scene of INDEX present with its sha1; fu 160 and p 30 per frame; every stream a whole number of its
    records; every dq record's mesh id in the file and in meshes.json (and every mesh a whole number of vertices); no NaN; the keyed
    frames are the scene's list; hb non-empty in every BATTLE frame of a battle scene with no cinematic running at its end or the frame's before (per its log)."""
    import math
    bad = []
    index = json.load(open(os.path.join(DRAW, 'INDEX.json')))
    names = json.load(open(os.path.join(DRAW, 'meshes.json')))['meshes']
    nfr = nfl = 0
    for sc in index['scenes']:
        n = sc['name']
        path = os.path.join(DRAW, n + '.bin')
        if 'error' in sc or not os.path.exists(path):
            bad.append(f'{n}: missing or failed')
            continue
        if hashlib.sha1(open(path, 'rb').read()).hexdigest() != sc['sha1']:
            bad.append(f'{n}: sha1 differs from INDEX')
        w, h, meshes, frames = draw_read(path)
        if [w, h] != sc['viewport'][:2]:
            bad.append(f'{n}: header viewport {w}x{h}')
        for mid, v in meshes.items():
            nfl += len(v)
            if len(v) % 9 or str(mid) not in names or any(map(math.isnan, v)):
                bad.append(f'{n}: mesh {mid} ({len(v)} floats, named {str(mid) in names}) bad')
        if [f['frame'] for f in frames] != draw_frames(sc['frames']):
            bad.append(f'{n}: keyed frames differ from its list')
        flow = {int(m[1]): (m[2], m[3]) for m in re.finditer(r'^draw f (\d+) \S+ \S+ (\S+) (\S+)', open(os.path.join(DRAW, n + '.log')).read(), re.M)}
        for f in frames:
            nfr += 1
            for a, k in DRAW_ARRAYS:
                v = f[a]
                nfl += len(v)
                if (len(v) != k) if a in ('fu', 'p') else (len(v) % k):
                    bad.append(f'{n} frame {f["frame"]}: {a} has {len(v)} floats')
                if any(map(math.isnan, v)):
                    bad.append(f'{n} frame {f["frame"]}: NaN in {a}')
            ids = {int(f['dq'][32 * r + 23]) for r in range(len(f['dq']) // 32)}
            if ids - meshes.keys():
                bad.append(f'{n} frame {f["frame"]}: dq draws meshes {sorted(ids - meshes.keys())[:5]} not in the file')
            quiet = all(flow.get(f['frame'] - d) == ('BATTLE', '-') for d in (0, 1))   # (no HUD in a cinematic, nor on the frame it ends)
            if sc.get('group') == 'battle' and quiet and not f['hb']:
                bad.append(f'{n} frame {f["frame"]}: hb empty in a battle frame')
    print(f'[oracle] draw check: {len(index["scenes"])} scenes, {nfr} frames, {nfl / 1e6:.1f} M floats, {len(names)} named meshes; '
          f'{"PASS" if not bad else "FAIL: " + "; ".join(bad[:20]) + (f" (+{len(bad) - 20} more)" if len(bad) > 20 else "")}', flush=True)
    return not bad


def draw(names=()):
    t0 = datetime.datetime.now()
    build()
    build_draw()
    spec = json.load(open(DRAW_SCENES))
    scenes = [s for s in spec['scenes'] if not names or s['name'] in names]
    if names and len(scenes) != len(names):
        sys.exit(f'[oracle] unknown scenes: {sorted(set(names) - {s["name"] for s in scenes})}')
    os.makedirs(os.path.join(DRAW, '.run2'), exist_ok=True)
    with cf.ThreadPoolExecutor(max(1, JOBS // 2)) as ex:   # (each scene runs its two processes at once)
        done = list(ex.map(draw_scene, scenes))
    for j in done:
        print(f"{j['name']}: " + (f"ERROR {j['error']}" if 'error' in j else
                                  f"draw OK twice, identical, {j['n_frames']} frames, {j['bytes'] / 1e6:.1f} MB, {j['seconds']} s"), flush=True)
    os.rmdir(os.path.join(DRAW, '.run2'))
    errors = [j['name'] for j in done if 'error' in j]
    # meshes.json: id -> what made it, the same in every scene and both runs (ids are per process: a lazily built mesh could differ)
    mpath = os.path.join(DRAW, 'meshes.json')
    merged = ({int(k): (v['verts'], v['made_by']) for k, v in json.load(open(mpath))['meshes'].items()}
              if names and os.path.exists(mpath) else {})
    for j in done:
        for mid, v in j.pop('_meshes', {}).items():
            if merged.setdefault(mid, v) != v:
                errors.append(f'mesh {mid}: {merged[mid]} vs {v} in {j["name"]}')
        if 'meshes_made' in j and any(k not in merged for k in range(j['meshes_made'])):
            errors.append(f'{j["name"]}: a mesh with no name ("?")')
    inputs = sorted({i for j in done for i in j.pop('_inputs', [])})
    if len(inputs) != 1:
        errors.append(f'the fixed inputs differ between scenes or over a scene: {inputs}')
    with open(mpath, 'w') as f:
        json.dump({'about': "mesh id (r_mesh_new's order in the native image) -> what made it: the shortest path to its MESH struct from a "
                            'DUEL / ENGINE special variable (draw.lisp DW-NAME-MESHES), and its vertex count',
                   'meshes': {str(k): {'made_by': p, 'verts': n} for k, (n, p) in sorted(merged.items())}}, f, indent=1)
    head = subprocess.run(['git', 'rev-parse', '--short', 'HEAD'], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    freeze, same = provenance()
    ipath = os.path.join(DRAW, 'INDEX.json')
    new = ({s['name']: s for s in json.load(open(ipath))['scenes']} if names and os.path.exists(ipath) else {}) | {j['name']: j for j in done}
    index = {'generated': str(datetime.date.today()), 'commit': head, 'lisp_freeze': freeze, 'sources_equal_tag': same,
             'format': 'tools/port/oracle/stubs-draw.c (header)', 'scenes_file': 'tools/port/oracle/draw-scenes.json',
             'image': os.path.relpath(DRAW_FAS, ROOT), 'image_sha1': hashlib.sha1(open(DRAW_FAS, 'rb').read()).hexdigest(),
             'stubs_sha1': hashlib.sha1(open(os.path.join(ROOT, DRAW_STUBS), 'rb').read()).hexdigest(),
             'fixed_inputs': spec['fixed_inputs'] | {'read_from_image': inputs}, 'commands': spec['commands'],
             'scenes': [new[s['name']] for s in spec['scenes'] if s['name'] in new]}
    index['total_bytes'] = sum(s.get('bytes', 0) for s in index['scenes']) + os.path.getsize(mpath)
    with open(ipath, 'w') as f:
        json.dump(index, f, indent=1)
    print(f'[oracle] draw: {len(done)} scenes, {sum(j.get("n_frames", 0) for j in done)} frames, {index["total_bytes"] / 1e6:.0f} MB '
          f'in the key, {(datetime.datetime.now() - t0).total_seconds():.0f} s; errors: {errors or "none"}', flush=True)
    sys.exit(0 if not errors and draw_check() else 1)


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'draw':
        if '--check' in sys.argv:
            sys.exit(0 if draw_check() else 1)
        draw([a for a in sys.argv[2:] if not a.startswith('--')])
    if cmd == 'look':
        if '--check' in sys.argv:
            sys.exit(0 if look_check() else 1)
        look()
    if cmd == 'sim':
        sim(sys.argv[2:])
    elif cmd == 'replay':
        live = '--live' in sys.argv
        names = [a for a in sys.argv[2:] if a != '--live'] or [j['name'] for j in json.load(open(os.path.join(OUT, 'INDEX.json')))['traces'] if 'error' not in j]
        sys.exit(1 if replay(names, live) else 0)
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
