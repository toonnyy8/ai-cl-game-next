#!/usr/bin/env python3
"""band.py — band-specialist tables (PLAN2.md §1, §5 step 1; DUEL_AI_STRATEGY §11): the incumbent arm 0 in every rule of :rb-sp, arm k only
in one pre-registered band's rules. One implementation of the rule base and the table writer: fq/switch/sw.py's (imported, not copied).

  python3 band.py bands                                    # each band's :rb-sp rule indices and antecedents
  python3 band.py write --me C --vs D --inc ARM0 --var ARMK|none --band B --out FILE [--q 0.05] [--margin 0.02] [--period 30]
                        [--no-keep-state [--record]]      # a raw :fq file eval.py scores as --cand (it also writes FILE's .arms beside it
                                                          # for sw.py measure)
  python3 band.py pair --me C --vs D --a FILE --b FILE --seed0 N [--seeds 100] [--spill] [-j 6]
                                                          # eval.py's matches (same sim path and cache), paired: per group and pooled
                                                          # b (A won by K.O., B did not) / c / z = (b - c) / sqrt(b + c), time-outs
  python3 band.py fallback --me C --vs D --inc ARM0 --alt ARM|none ... --out FILE [--q 0.05] [--margin 0.02] [--period 30]
                                                          # PLAN2 §3's fallback: arm 0 everywhere, the --alt arms at -q in G0's rules
                                                          # (Q = the groups' sum: each alternate at exactly -q), :keep-state on
  python3 band.py t0 --me C --vs D --map MAP.json --out FILE [--q 0.06] [--or] [--with UNIT ...] [--margin 0.02] [--period 30]
                                                          # PLAN4 §4's T0 on :rb-sp2: a job map (below), :keep-state on, :gamma 0.966
                                                          # :scale 0.1, :with the pairing's exchange unit(s)

The q values (written, not fitted: PLAN2 §3): arm 0 = 0 everywhere; arm k = +q in the band's rules and -q in every other rule of the
band's group, 0 in the other groups. The -q is needed: STRAT-FQ-PICK keeps the previous arm while it trails the best by less than :margin,
so arm k at 0 outside the band (a tie with arm 0) would hold once picked. The band's groups are crisp (cells, bursts, my form), so exactly
one state fires there and the gap is +-q > :margin in every state: arm k plays exactly in the band, from the first judgement in it.
:keep-state is on by default; off with arm k on another :fn (or none) resets the style's state at every switch, refused without --record
(a run kept for the record, never admitted).
"""
import argparse, importlib.util, json, os, re, sys
import numpy as np
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name, path):
    s = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(s); s.loader.exec_module(m)
    return m


sw = _load('sw', os.path.join(HERE, '../fq/switch/sw.py'))
ev = _load('sp_eval', os.path.join(HERE, 'eval.py'))
ss = ev.ss
sw.set_rule_base(':rb-sp')

# The bands (PLAN2 §1, pre-registered): (group, the antecedent test). Cells read :no 0 / :yes 1 / :p2up 2-3; form :no base / :yes / :k2.
BANDS = {
    'nocell':   (2, lambda a: '(:mcell :no)' in a and '(:ocell :no)' in a),      # no cells on either side
    'mycell':   (2, lambda a: '(:mcell :no)' not in a),                          # I hold >= 1
    'bothrich': (2, lambda a: '(:mcell :p2up)' in a and '(:ocell :p2up)' in a),  # both 2-3
    'myburst':  (3, lambda a: '(:mburst :yes)' in a),
    'hisburst': (3, lambda a: '(:oburst :yes)' in a),
    'awake':    (1, lambda a: '(:form :no)' not in a),                           # my form >= 1
}


def band_rules(b):
    g, test = BANDS[b]
    return [r for r, (a, gg) in enumerate(sw.RULES) if gg == g and test(a)]


def arm_text(spec):
    """An arm file -> its plist on one line (comments stripped, whitespace collapsed); 'none' -> nil (the shipped CPU, no strategy)."""
    return 'nil' if spec == 'none' else ' '.join(ss.strip_lisp(open(spec).read()).split())


def fn_of(text):
    m = re.search(r':fn\s+([^\s()]+)', text)
    return m[1].lower() if m else None


def cmd_bands(_):
    for b, (g, _) in BANDS.items():
        rs = band_rules(b)
        print(f'{b:9s} G{g} rules {rs}: ' + ' '.join(sw.RULES[r][0] for r in rs))


def cmd_write(a):
    arms = [arm_text(a.inc), arm_text(a.var)]
    keep = not a.no_keep_state
    if arms[1] == 'nil' or fn_of(arms[0]) != fn_of(arms[1]):
        if not keep and not a.record:
            sys.exit('band: arm k has another :fn (or is none): --keep-state is required (--record to write the reset table anyway)')
    rs, g = band_rules(a.band), BANDS[a.band][0]
    assert a.q > (a.margin or 0), 'q must exceed :margin, or arm k never takes over'
    q = np.zeros((sw.NR, 2))
    q[sw.GROUP_OF == g, 1] = -a.q
    q[rs, 1] = a.q
    sw.ARMS, sw.NA, sw.MEN, sw.VSN, sw.RB, sw.EVENT = arms, 2, a.me, a.vs, ':rb-sp', None
    sid = ':' + os.path.splitext(os.path.basename(a.out))[0]
    note = (f'band.py: arm 0 {os.path.basename(a.inc)} everywhere, arm k {os.path.basename(a.var)} in band {a.band} (G{g} rules {rs}): '
            f'arm k +{a.q} there, -{a.q} in the rest of G{g}; keep-state {"on" if keep else "OFF (for the record)"}.')
    sw.write_table(a.out, sid, q, note, period=a.period, keep=keep, margin=a.margin)
    with open(os.path.splitext(a.out)[0] + '.arms', 'w') as f:            # (sw.py measure's --arms: the table's arms, in order)
        f.write(f'; {os.path.basename(a.out)}\'s arms (band.py)\n' + '\n'.join(arms) + '\n')
    print(f'{a.out}: band {a.band} G{g} rules {rs}')


def cmd_fallback(a):
    """PLAN2 §3's fallback table: arm 0 plays everywhere. The alternates sit at -q in every G0 rule (sw.py cmd_start's placement), so each
    one's Q is exactly -q in every state; the online learner (fq-online.lisp) only moves the played arm's q, within +-*fq-online-cap*."""
    assert a.q > (a.margin or 0), 'q must exceed :margin, or an alternate could hold once picked'
    arms = [arm_text(a.inc)] + [arm_text(x) for x in a.alt]
    q = np.zeros((sw.NR, len(arms)))
    q[sw.GROUP_OF == 0, 1:] = -a.q
    sw.ARMS, sw.NA, sw.MEN, sw.VSN, sw.RB, sw.EVENT = arms, len(arms), a.me, a.vs, ':rb-sp', None
    sid = ':' + os.path.splitext(os.path.basename(a.out))[0]
    note = (f'band.py fallback (PLAN2 §3): arm 0 {os.path.basename(a.inc)} everywhere; '
            f'{", ".join(os.path.basename(x) for x in a.alt)} at -{a.q} in G0 (a fuzzy Q table in format only); keep-state on.')
    sw.write_table(a.out, sid, q, note, period=a.period, keep=True, margin=a.margin)
    with open(os.path.splitext(a.out)[0] + '.arms', 'w') as f:
        f.write(f'; {os.path.basename(a.out)}\'s arms (band.py fallback)\n' + '\n'.join(arms) + '\n')
    print(f'{a.out}: {len(arms)} arms, arm 0 everywhere')


def cmd_t0(a):
    """PLAN4 §4's designed table T0 on :rb-sp2. MAP (JSON): {"arms": [arm files (or "none"), arm 0 first], "jobs": [null, [[G, [ante
    substring, ...]], ...], ...]}: arm k's job rules are the rules of group G whose antecedent holds every substring (e.g. [2, ["(:ost :atk)",
    "(:dm :m-mid)"]]). Arm 0 = 0 in every rule; arm k = +q in its job rules and -q in the rest of the groups its job names (PLAN4's recipe),
    0 elsewhere. A job over n groups then plays only where all n fire (+q each; one firing nets 0, a tie arm 0 keeps): --or puts -q / n in
    the rest instead, so any one firing gives q / n (keep it above :margin)."""
    sw.set_rule_base(':rb-sp2')
    m = json.load(open(a.map))
    base = os.path.dirname(os.path.abspath(a.map))
    files = [x if x == 'none' else os.path.join(base, x) for x in m['arms']]
    arms = [arm_text(x) for x in files]
    assert len(m['jobs']) == len(arms) and m['jobs'][0] is None, 'one job per arm, arm 0 none'
    q = np.zeros((sw.NR, len(arms)))
    for k, job in enumerate(m['jobs'][1:], 1):
        gs = sorted({g for g, _ in job})
        rest = a.q / len(gs) if a.or_ else a.q
        assert (a.q / len(gs) if a.or_ else a.q) > (a.margin or 0), 'the job\'s lead must exceed :margin'
        mine = [r for r, (ante, g) in enumerate(sw.RULES) for gg, subs in job if g == gg and all(s in ante for s in subs)]
        assert mine, f'arm {k}: no rule matches its job {job}'
        for r, (_, g) in enumerate(sw.RULES):
            if g in gs:
                q[r, k] = a.q if r in mine else -rest
    sw.ARMS, sw.NA, sw.MEN, sw.VSN, sw.RB, sw.EVENT = arms, len(arms), a.me, a.vs, ':rb-sp2', None
    with_ = [sw.unit_text(x if x.startswith(':') else os.path.relpath(os.path.abspath(x), sw.HERE)) for x in (a.with_ or [])]
    sid = ':' + os.path.splitext(os.path.basename(a.out))[0]
    note = (f'band.py t0 (PLAN4 §4): {os.path.basename(a.map)}, arm 0 everywhere, each arm k +{a.q} in its job rules, '
            f'{"-q / n" if a.or_ else "-q"} in the rest of its groups; :with {" ".join(a.with_ or []) or "none"}; keep-state on.')
    sw.write_table(a.out, sid, q, note, period=a.period, gamma=0.966, scale=0.1, keep=True, margin=a.margin, with_=with_)
    with open(os.path.splitext(a.out)[0] + '.arms', 'w') as f:
        f.write(f'; {os.path.basename(a.out)}\'s arms (band.py t0)\n' + '\n'.join(arms) + '\n')
    print(f'{a.out}: {len(arms)} arms, job rules per arm ' + str([int((q[:, k] > 0).sum()) for k in range(len(arms))]))


def paired(wa, wb):
    """Two {(seat, seed): K.O. win 0/1} on the same seeds -> (b, c, z): b = A won by K.O. and B did not, c the reverse."""
    b = sum(1 for k in wa if wa[k] and not wb[k])
    c = sum(1 for k in wa if wb[k] and not wa[k])
    return b, c, z(b, c)


def z(b, c):
    return round((b - c) / max(1, b + c) ** 0.5, 2)


def cmd_pair(a):
    """Two candidates on the same seeds through eval.py's groups / jobs / play (its cache): paired b / c on K.O. wins, per group and pooled."""
    lo, hi = a.seed0 + 1, a.seed0 + a.seeds
    if (a.seeds > 100 and not a.spill) or (lo <= 800 and hi >= 601):
        sys.exit('band pair: more than 100 seeds needs --spill; 601-800 is refused (the ship test)')
    os.dup2(os.open(os.devnull, os.O_RDONLY), 0)
    gs = ev.groups(json.load(open(a.pop or ev.default_pop(a.me, a.vs))))
    ss.build()
    lists = [ev.jobs(a.me, a.vs, ev.mine(c), ss.vs_spec(','.join(m)), a.seed0, a.seeds) for c in (a.a, a.b) for _, m in gs]
    res = ev.play(lists, a.j)
    out, B, C = {}, 0, 0
    for i, (g, _) in enumerate(gs):
        (ca, wa), (cb, wb) = res[i], res[len(gs) + i]
        b, c, zz = paired(wa, wb)
        B, C = B + b, C + c
        out[g] = dict(n=len(wa), a_ko_wins=ca['ko_wins'], b_ko_wins=cb['ko_wins'], b=b, c=c, z=zz,
                      a_timeouts=ca['timeouts'], b_timeouts=cb['timeouts'])
    ta, tb = sum(v['a_timeouts'] for v in out.values()), sum(v['b_timeouts'] for v in out.values())
    print(json.dumps(dict(a=a.a, b_=a.b, seeds=f'{lo}-{hi}', groups=out, pooled=dict(b=B, c=C, z=z(B, C),
                     a_timeouts=ta, b_timeouts=tb, n=sum(v['n'] for v in out.values())), build=ss.build_hash()[:12])))


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    sub.add_parser('bands')
    p = sub.add_parser('write')
    p.add_argument('--me', required=True, choices=list(ss.ROSTER)); p.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    p.add_argument('--inc', required=True, help='arm 0: the incumbent arm file'); p.add_argument('--var', required=True, help='arm k: an arm file or none')
    p.add_argument('--band', required=True, choices=list(BANDS)); p.add_argument('--out', required=True)
    p.add_argument('--q', type=float, default=0.05); p.add_argument('--margin', type=float, default=0.02); p.add_argument('--period', type=int, default=30)
    p.add_argument('--no-keep-state', action='store_true'); p.add_argument('--record', action='store_true')
    p = sub.add_parser('fallback')
    p.add_argument('--me', required=True, choices=list(ss.ROSTER)); p.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    p.add_argument('--inc', required=True, help='arm 0: the best pure arm'); p.add_argument('--alt', required=True, nargs='+', help='arm files or none')
    p.add_argument('--out', required=True)
    p.add_argument('--q', type=float, default=0.05); p.add_argument('--margin', type=float, default=0.02); p.add_argument('--period', type=int, default=30)
    p = sub.add_parser('t0')
    p.add_argument('--me', required=True, choices=list(ss.ROSTER)); p.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    p.add_argument('--map', required=True, help='the job map (JSON; cmd_t0)'); p.add_argument('--out', required=True)
    p.add_argument('--q', type=float, default=0.06); p.add_argument('--or', dest='or_', action='store_true')
    p.add_argument('--with', dest='with_', nargs='+', help='data units under every arm (:with): ids (:d-...) or unit files')
    p.add_argument('--margin', type=float, default=0.02); p.add_argument('--period', type=int, default=30)
    p = sub.add_parser('pair')
    p.add_argument('--me', required=True, choices=list(ss.ROSTER)); p.add_argument('--vs', required=True, choices=list(ss.ROSTER))
    p.add_argument('--a', required=True); p.add_argument('--b', required=True); p.add_argument('--seed0', type=int, required=True)
    p.add_argument('--seeds', type=int, default=100); p.add_argument('--spill', action='store_true'); p.add_argument('--pop'); p.add_argument('-j', type=int, default=6)
    a = ap.parse_args()
    {'bands': cmd_bands, 'write': cmd_write, 'fallback': cmd_fallback, 't0': cmd_t0, 'pair': cmd_pair}[a.cmd](a)


if __name__ == '__main__':
    main()
