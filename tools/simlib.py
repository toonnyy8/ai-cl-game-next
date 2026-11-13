"""simlib.py — what every native-sim tool shares (docs/engine/REFACTOR_2026-11.md R-c): the host ECL + musl-libm paths, the
build of build/simgate/duel.fas, one native Lisp process, the gate-row parse and a small thread pool. simgate.py re-exports
these names (the tools and the research scripts import them from there)."""
import concurrent.futures as cf, functools, hashlib, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ECL = os.environ.get('ECL_HOST', '/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl')
FAS = os.path.join(ROOT, 'build/simgate/duel.fas')
EMSDK = os.environ.get('EMSDK_DIR', '/media/8tsp/projects/emsdk')
MUSLM = os.path.join(ROOT, 'build/simgate/muslm.so')
MUSL_MATH = ('sinf cosf tanf __sindf __cosdf __tandf __rem_pio2f __rem_pio2_large atan2f atanf acosf asinf tanhf expm1f '
             'expf exp2f_data powf powf_data logf logf_data log2f_data sin cos tan __sin __cos __tan __rem_pio2 atan2 atan '
             'exp exp_data pow pow_data log log_data __math_oflowf __math_uflowf __math_xflowf __math_invalidf '
             '__math_divzerof __math_oflow __math_uflow __math_xflow __math_invalid __math_divzero')
ROW = re.compile(r'duel gate row seed (\d+) \S+ \S+ secs [\d.]+ winner (\S+)')   # a gate row: (seed, winner)
ROW_KO = re.compile(r' ko ([01])$')   # the row's last field since 2026-11-14: 1 = ended before the bell (a K.O.), 0 = the time-out bell


def row_win(line, m, seat, ko_only=False):
    """A gate row LINE (M = its ROW match) -> 1 if SEAT won it, else 0; KO_ONLY: a win counts only if it was a K.O. (a time-out
    lead scores 0, as a draw always does). A row without the ko field under KO_ONLY exits (a sim build older than the field)."""
    if m[2] != seat:
        return 0
    if not ko_only:
        return 1
    k = ROW_KO.search(line)
    if not k:
        sys.exit(f'simlib: --ko-only on a gate row without its ko field (an old build?): {line}')
    return int(k[1])


def row_ko(line):
    """A gate row -> 1 (ended before the bell), 0 (the time-out bell) or None (no ko field)."""
    k = ROW_KO.search(line)
    return int(k[1]) if k else None


def sources():
    out = [os.path.join(ROOT, 'tools/simgate', f) for f in ('build.lisp', 'stubs.c')] + [os.path.join(ROOT, 'engine/c/engine.h')]
    for d in ('engine', 'duel'):
        with open(os.path.join(ROOT, d, 'MANIFEST')) as f:
            out += [os.path.join(ROOT, d, l.strip()) for l in f if l.strip().endswith('.lisp')]
    return out


def build():
    # the wasm build's libm is emscripten's musl; glibc's sinf / expf ... differ in the last bit now and then, and a
    # CPU match drifts apart from there (DEVLOG §38). So the very same musl sources, built for the host, go in front of
    # glibc (LD_PRELOAD): the Lisp's inline calls and libecl's (SIN, EXP, EXPT ...) both land there.
    # Every tool that runs build/simgate/duel.fas calls this first (a stale build played the wrong code: DEVLOG §700).
    os.makedirs(os.path.dirname(MUSLM), exist_ok=True)   # (a fresh checkout has no build/simgate)
    if not os.path.exists(MUSLM):
        m = f'{EMSDK}/upstream/emscripten/system/lib/libc/musl'
        gcc_inc = subprocess.run(['gcc', '-print-file-name=include'], capture_output=True, text=True).stdout.strip()
        r = subprocess.run(['gcc', '-m32', '-msse2', '-mfpmath=sse', '-ffp-contract=off', '-O2', '-fPIC', '-shared', '-w',
                            '-nostdinc'] + [f'-I{m}/{d}' for d in ('src/include', 'src/internal', 'arch/emscripten',
                                                                  'arch/generic', 'include')] +
                           [f'-I{gcc_inc}', '-o', MUSLM] + [f'{m}/src/math/{f}.c' for f in MUSL_MATH.split()],
                           capture_output=True, text=True)
        if r.returncode:
            sys.exit(r.stderr[-3000:] + '\n[simgate] musl libm BUILD FAILED')
    if os.path.exists(FAS) and os.path.getmtime(FAS) >= max(os.path.getmtime(s) for s in sources()):
        return
    print('[simgate] building build/simgate/duel.fas (~2 min)', file=sys.stderr, flush=True)
    r = subprocess.run([ECL, '--norc', '--load', 'tools/simgate/build.lisp', '--', 'build/simgate/duel.fas'], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode or not os.path.exists(FAS):
        sys.exit(r.stdout[-3000:] + r.stderr[-3000:] + '\n[simgate] BUILD FAILED')


def run_lisp(script, cmds, env=None, timeout=None):
    """One native process: tools/<SCRIPT> (a runner, e.g. 'simgate/run.lisp') on build/simgate/duel.fas with the args CMDS.
    ENV is the whole environment (default os.environ); LD_PRELOAD=musl always. -> the CompletedProcess (text stdout / stderr)."""
    return subprocess.run([ECL, '--norc', '--load', 'tools/' + script, '--', FAS] + [str(c) for c in cmds], cwd=ROOT,
                          capture_output=True, text=True, env=dict(os.environ if env is None else env, LD_PRELOAD=MUSLM), timeout=timeout)


def sha(b):
    return hashlib.sha1(b).hexdigest()[:16]


@functools.cache
def build_hash(*extra):
    """sha of the sim build plus the files EXTRA (a runner): the cache key part that changes with the code."""
    return sha(b''.join([open(FAS, 'rb').read()] + [open(p, 'rb').read() for p in extra]))


def gate_rows(out):
    """The gate rows of a sim's stdout -> [(seed, winner)]."""
    return [(int(m[1]), m[2]) for m in map(ROW.search, out.splitlines()) if m]


def pool(fn, jobs, n):
    """fn over JOBS on N threads (they wait on subprocesses), results in order."""
    with cf.ThreadPoolExecutor(n) as ex:
        return list(ex.map(fn, jobs))
