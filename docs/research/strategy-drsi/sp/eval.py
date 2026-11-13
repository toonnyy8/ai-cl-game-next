#!/usr/bin/env python3
"""eval.py — the scorer of the SP strategy search (PLAN.md §2 step 3, §3; DUEL_AI_STRATEGY §11): character C playing candidate FILE (a raw
strategy plist: a plain arm, a composite or a Q selector, as tools/strategy-switch.py --raw takes it) against D's frozen population, HARD,
both seats, K.O.s only.

  python3 docs/research/strategy-drsi/sp/eval.py --me C --vs D --cand FILE --seed0 N [--seeds 100] [--pop POPFILE] [-j 6]
  -> one JSON line on stdout; exit 0. A bad candidate (not one plist, unexpanded unit ids, a sim error) exits non-zero with a message.

Opponent groups (PLAN §2 step 3, weights 1/3 each), read from the population file (default pop/<pair>-<D>.json, the pair's letters in roster
order K I H, e.g. --me kenpachi --vs ichigo reads pop/ki-I.json):
  anchor  `none`: his shipped CPU with no strategy at all (BRAIN-STRAT NIL, his matchup style CPU kept)
  mix     the population's equilibrium mix ("mix" in the file, pop.py matrix): a pool, members repeated by weight over 20 slots
          (largest remainder: a member well under 1/20 may get no slot). Fallback, a file with no "mix": uniform over every member
  rest    uniform over every member but the anchor. Fallback, a population of the anchor alone: the anchor
  group score = (K.O. wins + 1) / (matches + 2); score = the mean of the three (positive, higher is better). A time-out and a draw score 0.
A pool plays member (seed mod n) of its list (strat-run.lisp), so every group plays the same seeds (common random numbers).
Seed blocks (seed0): 200 the coordinator's rescore, 300 the cells' dev runs, 400 held-out for admission; 601-800 is the final gates' held-out
set and is refused here. Default 100 seeds a seat = 600 matches (3 groups x 2 seats), one whole block; more than 100 needs --spill.
The matches are strategy-switch.py --raw --ko-only's candidate arm (its run_job, parse and cache, build/strategy-eval-cache/, keyed by the
sim build hash, the candidate's text, the characters, the seeds and the opponent pool's texts), without its incumbent arm: a repeated call
costs no sim."""
import argparse, importlib.util, json, os, re, sys, time
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))
_s = importlib.util.spec_from_file_location('strategy_switch', os.path.join(ROOT, 'tools/strategy-switch.py'))
ss = importlib.util.module_from_spec(_s); _s.loader.exec_module(ss)

LETTER = {'kenpachi': 'K', 'ichigo': 'I', 'hisagi': 'H'}
SLOTS = 20                                               # the mix pool's resolution (1/20 a slot)
UNIT_IDS = re.compile(r':(?:a|st|d|rb)-[a-z0-9-]+|:style\b|:data\b|:rule-base\b', re.I)


def pair(a, b):
    """The pairing's name, letters in roster order K I H: pair('ichigo', 'kenpachi') = 'ki'."""
    return ''.join(sorted((LETTER[a], LETTER[b]), key='KIH'.index)).lower()


def default_pop(me, vs):
    return os.path.join(HERE, 'pop', f'{pair(me, vs)}-{LETTER[vs]}.json')


def chunks(seed0, n):
    return [(seed0 + s, min(ss.CHUNK, n - s)) for s in range(0, n, ss.CHUNK)]


def mine(spec):
    """A member / candidate SPEC ('none' or a file) on the playing seat -> (STRAT_ value, cache text) as strategy-switch --raw keys it."""
    if spec == 'none':
        return 'none', 'none'
    return os.path.abspath(spec), ss.strip_lisp(open(spec).read()).strip() + '\n'


def jobs(me, vs, cand, opp, seed0, n):
    """run_job argument tuples, tagged by seat: ME on CAND (mine()) against VS on the pool OPP (ss.vs_spec()), both seats."""
    R, out = ss.ROSTER, []
    for seat, (c1, c2) in (('P1', (R[me], R[vs])), ('P2', (R[vs], R[me]))):
        oseat = 'P2' if seat == 'P1' else 'P1'
        for s0, k in chunks(seed0, n):
            out.append((seat, (c1, c2, (seat, cand[0], cand[1]), ss.DIFF['hard'], s0, k, (oseat, opp[0], opp[1]))))
    return out


def play(job_lists, j):
    """Run several jobs() lists in one pool -> per list (counts, {(seat, seed): K.O. win 0/1})."""
    flat = [x for jl in job_lists for x in jl]
    outs = ss.pool(lambda x: ss.run_job(*x[1]), flat, max(1, min(8, j)))
    res, i = [], 0
    for jl in job_lists:
        cnt, wins = dict(ko_wins=0, ko_losses=0, timeouts=0, draws=0, matches=0), {}
        for seat in ('P1', 'P2'):
            o = [outs[i + k] for k, x in enumerate(jl) if x[0] == seat]
            w, _, _, c = ss.parse(o, seat, ko_only=True)
            for x in c:
                cnt[x] += c[x]
            cnt['matches'] += len(w)
            wins.update({(seat, s): v for s, v in w.items()})
        res.append((cnt, wins))
        i += len(jl)
    return res


def mix_pool(mix, files):
    """The mix {id: weight} -> a list of member files, each repeated by its share of SLOTS (largest remainder)."""
    tot = sum(w for w in mix.values() if w > 0)
    q = {m: w / tot * SLOTS for m, w in mix.items() if w > 0}
    n = {m: int(v) for m, v in q.items()}
    for m in sorted(q, key=lambda m: n[m] - q[m])[:SLOTS - sum(n.values())]:
        n[m] += 1
    return [files[m] for m in mix for _ in range(n.get(m, 0))]


def groups(pop):
    """A population file's dict -> [(group, [member files])]: anchor, mix, rest (the fallbacks in the header)."""
    files = {m['id']: m['file'] if m['file'] == 'none' else os.path.join(ROOT, m['file']) for m in pop['members']}
    anchor = pop.get('anchor', 'none')
    mix = pop.get('mix') or {m: 1.0 for m in files}
    rest = [f for m, f in files.items() if m != anchor] or [files[anchor]]
    return [('anchor', [files[anchor]]), ('mix', mix_pool(mix, files)), ('rest', rest)]


def check_cand(path):
    """Exit 2 unless PATH holds one balanced plist with no unexpanded unit ids (a raw file is READ as it is: strat-run.lisp)."""
    if not os.path.isfile(path):
        sys.exit(f'eval: {path}: no such file')
    text = ss.strip_lisp(open(path).read()).strip()
    if not text.startswith('(') or ss.form_end(text, 0) != len(text):
        sys.exit(f'eval: {path}: not exactly one plist (a form starting with an open parenthesis, balanced, nothing after it)')
    body = re.sub(r':id\s+[^\s()]+', '', text, flags=re.I)   # (every :id: an inline arm keeps its own)
    m = UNIT_IDS.search(body)
    if m:
        sys.exit(f'eval: {path}: names {m[0]}: a raw file is not expanded (no :style / :data / :rule-base, no unit ids); '
                 'write the arm inline, e.g. as docs/research/strategy-drsi/sp/arms/dump.lisp writes it')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--me', required=True, choices=list(ss.ROSTER))
    ap.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    ap.add_argument('--cand', required=True, help='a raw strategy plist (a plain arm, a composite or a Q selector), or none')
    ap.add_argument('--seed0', type=int, required=True, help='seeds seed0+1..seed0+seeds: 200 rescore, 300 dev, 400 held-out admission')
    ap.add_argument('--seeds', type=int, default=100, help='seeds a seat and group (default 100: 600 matches)')
    ap.add_argument('--pop', help="the opponent's population file (default pop/<pair>-<D>.json)")
    ap.add_argument('--spill', action='store_true', help='allow more than 100 seeds (past the block)')
    ap.add_argument('-j', type=int, default=6)
    a = ap.parse_args()
    t0 = time.time()
    os.dup2(os.open(os.devnull, os.O_RDONLY), 0)         # (an ECL error must not wait in its debugger on a terminal)
    lo, hi = a.seed0 + 1, a.seed0 + a.seeds
    if a.seeds < 1 or (a.seeds > 100 and not a.spill):
        sys.exit('eval: --seeds must be 1-100 (one block); --spill for more')
    if lo <= 800 and hi >= 601:
        sys.exit(f'eval: seeds {lo}-{hi} touch the held-out set 601-800 (PLAN §6), never used by the search')
    if a.seed0 + ((a.seeds - 1) // ss.CHUNK) * ss.CHUNK > 999:
        sys.exit('eval: each sim chunk starts at seed0 + 25 i <= 999 (debug 30000+k)')
    if a.cand != 'none':                                 # (`none`: the anchor's own score, a reference)
        check_cand(a.cand)
    pop_path = a.pop or default_pop(a.me, a.vs)
    pop = json.load(open(pop_path))
    if pop.get('side') != a.vs:
        sys.exit(f"eval: {pop_path} is {pop.get('side')}'s population, not {a.vs}'s")
    gs = groups(pop)
    cand = mine(a.cand)
    ss.build()
    specs = {}                                           # (identical pools played once)
    for _, members in gs:
        specs.setdefault(','.join(members), None)
    keys = list(specs)
    got = dict(zip(keys, play([jobs(a.me, a.vs, cand, ss.vs_spec(k), a.seed0, a.seeds) for k in keys], a.j)))
    out = {}
    for g, members in gs:
        cnt = got[','.join(members)][0]
        if cnt['matches'] != 2 * a.seeds:
            sys.exit(f"eval: group {g}: {cnt['matches']} matches, expected {2 * a.seeds}")
        names = [os.path.splitext(os.path.basename(m))[0] for m in members]
        out[g] = dict(cnt, share=round((cnt['ko_wins'] + 1) / (cnt['matches'] + 2), 4),
                      members={n: names.count(n) for n in dict.fromkeys(names)})
    m = re.search(r':id\s+:?([^\s()]+)', cand[1])
    print(json.dumps(dict(me=a.me, vs=a.vs, cand=m[1] if m else os.path.basename(a.cand), seed0=a.seed0, seeds=a.seeds,
                          score=round(sum(v['share'] for v in out.values()) / 3, 4), groups=out,
                          pop=os.path.relpath(pop_path, ROOT), build=ss.build_hash(), wall_s=round(time.time() - t0, 1))))


if __name__ == '__main__':
    main()
