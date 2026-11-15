#!/usr/bin/env python3
"""digest.py — Kenpachi's kit-study catalogue tables (PLAN4 step 2): play trials.lisp in the native sim (tools/simgate/trial.lisp, as
tools/combo-trial.py does), keep each trial's combat-log events (hits, cancels, breakthroughs, Kikon, moves; ticks counted from the
trial's first logged line) and print catalogue.md's section tables on stdout. The digest is cached in build/kit-kenpachi/.
    python3 docs/research/strategy-drsi/sp/kits/kenpachi/digest.py [--cached] [trials.lisp] > tables.md
"""
import json, os, re, sys
from collections import defaultdict, OrderedDict
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, *(['..'] * 6)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
ARGS = [a for a in sys.argv[1:] if not a.startswith('--')]
SRC = os.path.abspath(ARGS[0]) if ARGS else os.path.join(HERE, 'trials.lisp')
CACHE = os.path.join(ROOT, 'build', 'kit-kenpachi', os.path.basename(SRC) + '.json')
KEEP = re.compile(r'-> P[12] (HIT|COUNTER|KIKON|ABSORB|ARMOR|PARRIED|PARRY)|x P[12]: |PARR|BREAK fs|refused|WAVE|perfect|CANCEL|bounce|'
                  r'STEAL|HOHO|hoho|lets go|cancels the Kikon|KIKON|KIN on|L\d$|BANKAI|BURST|P[12] move ')


def run():
    import simgate
    simgate.build()
    r = simgate.run_lisp('simgate/trial.lisp', [SRC])
    if r.returncode:
        sys.exit((r.stdout + r.stderr)[-3000:] + f'\n[digest] trial.lisp exited {r.returncode}')
    rows, cur, tick = [], None, re.compile(r'\[\s*(\d+)\] (.*)')
    for line in r.stdout.splitlines():
        if 'trial begin' in line:
            cur = []
        elif 'trial end' in line and cur is not None:
            f = [x.strip() for x in line.split('trial end', 1)[1].split('|')]
            row = dict(name=f[0], **{x.split(' ', 1)[0]: (x.split(' ', 1)[1] if ' ' in x else '') for x in f[1:]})
            t0, ev = None, []
            for l in cur:
                m = tick.search(l)
                if not m: continue
                tk, msg = int(m.group(1)), m.group(2)
                t0 = tk if t0 is None else t0
                if KEEP.search(msg): ev.append(f'{tk - t0}:{msg}')
            row['ev'] = ev
            rows.append(row); cur = None
        elif cur is not None:
            cur.append(line)
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    json.dump(rows, open(CACHE, 'w'))
    return rows


R = json.load(open(CACHE)) if '--cached' in sys.argv else run()
out = []
def p(*a): out.append(' '.join(str(x) for x in a))
def tag(n): return re.search(r'\[(\w+)\]$', n).group(1)
def base(n): return re.sub(r' \[\w+\]$', '', n)
def more(r):
    m = re.search(r'self ([+-]\d+) konpaku ([+-]\d+)/([+-]\d+) form (\S+) ptr (\d) meter (\d)', r['more'])
    return dict(self=int(m.group(1)), k1=int(m.group(2)), k2=int(m.group(3)), form=m.group(4), ptr=m.group(5), L=m.group(6))
def events(r): return [(int(e.split(':', 1)[0]), e.split(':', 1)[1]) for e in r['ev']]
def first_hit(r, after=-1):
    for rel, msg in events(r):
        m = re.search(r'P([12]) (\S+) -> P[12] (HIT|COUNTER|KIKON|PARRIED) (\d+)', msg)
        if m and rel > after:
            return rel, ('me' if m.group(1) == '1' else 'him'), m.group(2).lower(), m.group(3).lower()
    return None
def moves(r, side): return [(rel, msg.split()[-2] if msg.endswith('TRIAL') else msg.split()[-1]) for rel, msg in events(r) if f'P{side} move ' in msg]
def cancels(r): return [rel for rel, msg in events(r) if 'CANCEL' in msg]
def brk(r):
    for rel, msg in events(r):
        b = re.search(r'P([12]) BREAK fs ([\d.]+)', msg)
        if b: return f"{'me' if b.group(1) == '1' else 'him'} {float(b.group(2)):.0f}"
    return ''
def who(f, r=None):
    if not f: return 'none'
    if f[3] == 'parried': return f'**me**: my catch ({f[2]} parried), thrust + men' + (f" (dmg {r['dmg']})" if r else '')
    return f"{'**me**' if f[1] == 'me' else 'him'} {f[2]}" + ('' if f[3] == 'hit' else f' {f[3]}')
def sec(prefix): return [r for r in R if re.match(prefix, r['name'])]

# ---------------------------------------------------------------- R
p('### R. Hit-confirmed routes\n')
p("dmg = Reishi he lost (after scaling; Ichigo's Shikai takes x0.8, every other form x1.0); gaps 0 = a true combo; adv = his first free frame "
  "minus mine after the last hit (a knockdown counts his wake-up); FS = my flash-step spent (300 at the start); self = my Reishi lost (the "
  "Bankai's 40 a segment); K = Konpaku me / him (a Kikon); end = form, pointer, L.\n")
p('| Route | dmg I | dmg H | dmg IK / Hr / Hb | hits | gaps | adv | end dist | FS | self | K | end |')
p('|---|---|---|---|---|---|---|---|---|---|---|---|')
rows = OrderedDict()
for r in sec('R'): rows.setdefault(base(r['name']), {})[tag(r['name'])] = r
for nm, d in rows.items():
    i, h = d['I'], d['H']; mi = more(i)
    ex = ' / '.join(d[t]['dmg'] for t in ('IK', 'Hr', 'Hb') if t in d) or '—'
    flag = '' if (i['gaps'] == h['gaps'] and i['adv'] == h['adv']) else f" (H: gaps {h['gaps'] or '—'}, adv {h['adv']})"
    p(f"| {nm} | {i['dmg']} | {h['dmg']} | {ex} | {i['hits']} | {i['gaps'] or '—'} | {i['adv']}{flag} | {i['dist']} | {i['fs']} | "
      f"{mi['self']} | {mi['k1']}/{mi['k2']} | {mi['form']} p{mi['ptr']} L{mi['L']} |")

# ---------------------------------------------------------------- P + E: my reach
p('\n### P / E. My openers by distance (against a standing Hisagi, hurt radius 0.36 m; Ichigo 0.38)\n')
p('Distances centre to centre; "far edge" = the farthest distance that hit (0.1 m steps).\n')
reach = defaultdict(list)
for r in sec(r'^(P|EP)'):
    m = re.match(r'^E?(P\w+) (.*) @([\d.]+)', r['name'])
    reach[(m.group(1), m.group(2))].append((float(m.group(3)), any('-> P2 HIT' in msg for _, msg in events(r)), r))
p('| Opener | hits at (m) | far edge | whiff at | dmg vs H | adv on hit |')
p('|---|---|---|---|---|---|')
for (pid, lab), v in reach.items():
    v.sort(key=lambda x: x[0]); hits = [d for d, h, _ in v if h]; miss = [d for d, h, _ in v if not h]
    hr = next(r for d, h, r in v if h)
    p(f"| {lab} | {min(hits)}-{max(hits)} | **{max(hits)}** | {min([m for m in miss if m > max(hits)], default='—')} | {hr['dmg']} | {hr['adv']} |")

# ---------------------------------------------------------------- Q + E: his reach
p('\n### Q / E. His openers by distance against an idle sealed Kenpachi (hurt radius 0.45 m)\n')
reach = defaultdict(list)
for r in sec(r'^E?Q-'):
    m = re.match(r'^E?(Q-\w+) his (.*) @([\d.]+) \[(\w+)\]', r['name'])
    hit = [(rel, msg) for rel, msg in events(r) if '-> P1 HIT' in msg]
    reach[(m.group(4), m.group(2))].append((float(m.group(3)), bool(hit), r, hit))
p('| His form | opener | hits Kenpachi at (m) | dead zone / far edge | his hit tick | my Reishi change |')
p('|---|---|---|---|---|---|')
for (o, lab), v in reach.items():
    v.sort(key=lambda x: x[0]); hits = [d for d, h, _, _ in v if h]; miss = [d for d, h, _, _ in v if not h]
    hr = next(x for x in v if x[1])
    dz = max([m for m in miss if m < min(hits)], default=None)
    far = min([m for m in miss if m > max(hits)], default=None)
    ticks = sorted({x[3][0][0] for x in v if x[1]})
    p(f"| {o} | {lab} | {min(hits)}-{max(hits)} | {('under ' + str(min(hits)) + ' (whiff at ' + str(dz) + ')') if dz else '—'} / "
      f"{max(hits)}{' (whiff at ' + str(far) + ')' if far else ' (8 m tried)'} | {ticks[0]}{'-' + str(ticks[-1]) if len(ticks) > 1 else ''} | {more(hr[2])['self']} |")

# ---------------------------------------------------------------- T
p('\n### T. Both press on frame 0: the first real hit or the cancel\n')
p('Cells: my J / NS against his J1 / NS1a ("cancel" = no hit after it in this trial: the exchange decides, section X).\n')
tt = defaultdict(dict)
for r in sec(r'^T[zs] '):
    m = re.match(r'^T(\w) my (\w+) vs his (\w+) @([\d.]+) \[(\w+)\]', r['name'])
    f = first_hit(r); c = cancels(r)
    res = who(f) + (' (after a cancel)' if c and f and c[0] < f[0] else '') + ('cancel' if c and not f else '')
    tt[(m.group(1), m.group(2), m.group(5))][(m.group(4), m.group(3))] = res.replace('nonecancel', 'cancel')
p('| Me | vs | 1.5 m: his J1 / his NS1a | 2.5 m | 3.5 m |')
p('|---|---|---|---|---|')
for (f, mine, o), d in tt.items():
    if ('1.5', 'J') not in d: continue
    form = 'sealed' if f == 'z' else 'Shikai L0'
    p(f"| {form} {mine}{'1' if mine == 'J' else '1a'} | {o} | " + ' | '.join(f"{d[(x, 'J')]} / {d[(x, 'NS')]}" for x in ('1.5', '2.5', '3.5')) + ' |')
p('\n| Me (sealed) | vs (2.0 m) | his J1 / his NS1a |')
p('|---|---|---|')
for (f, mine, o), d in tt.items():
    if ('2.0', 'J') in d: p(f"| {mine}{'1' if mine == 'J' else '1a'} | {o} | {d[('2.0', 'J')]} / {d[('2.0', 'NS')]} |")
for r in sec(r'^Tz[23] '):
    p(f"| {base(r['name'])[4:].replace(' @2.0', '')} | {tag(r['name'])} | {who(first_hit(r), r)} |")

# ---------------------------------------------------------------- X
p('\n### X. The exchange after a cancel\n')
p('First real hit after the cancel; brk = the breakthrough (who took how much flash-step). His presses are sim frames from the start '
  '(the cancel lands on ~f9). His SA here starts on a fixed sim frame: section Y keys it to my AS.\n')
p('| Exchange | I | H | IK | Hr | Hb |')
p('|---|---|---|---|---|---|')
xx = OrderedDict()
for r in sec(r'^X'): xx.setdefault(base(r['name']), {})[tag(r['name'])] = r
for nm, d in xx.items():
    cells = []
    for t in ('I', 'H', 'IK', 'Hr', 'Hb'):
        if t not in d: cells.append(''); continue
        b = brk(d[t]); cells.append(who(first_hit(d[t])) + (f' ({b})' if b else ''))
    p(f"| {nm} | " + ' | '.join(cells) + ' |')

# ---------------------------------------------------------------- Y
p('\n### Y. The J side\'s AS timing: his SA by sim frame, and his HARD CPU\n')
p('My J1 cancels his NS1a (~f9); my AS at once (+0) or 6 / 10 sim frames after the contact. Scripted: his SA pressed on sim frame f. '
  'CPU: his NS1a started by `:p2-start`, then his HARD CPU plays (`:p2-cpu 2`), ten seeds. "me" = my AS lands first; "AS<SA" = my AS '
  'started before his SA (the later start wins, DUEL_CORE §2.1.1).\n')
yy = defaultdict(dict); cpu = defaultdict(list)
for r in sec(r'^Y '):
    m = re.match(r'^Y my J1>AS1 \+(\d+) vs his (SA on f(\d+)|HARD CPU, seed (\d+)) \[(\w+)\]', r['name'])
    w, o, f = int(m.group(1)), m.group(5), first_hit(r)
    asst = next((rel for rel, mv in moves(r, 1) if 'AS1' in mv), None)
    sast = next((rel for rel, mv in moves(r, 2) if mv.endswith('SA') or '-SA' in mv), None)
    res = 'none' if not f else ('**me**' if f[1] == 'me' else 'him')
    if m.group(3):
        yy[(o, w)][int(m.group(3))] = res + ('' if sast is None or asst is None else (' AS<SA' if asst < sast else ''))
    else:
        cpu[(o, w)].append((res, sast is not None))
fs = sorted({k for d in yy.values() for k in d})
p('| vs | my AS | ' + ' | '.join(f'SA f{k}' for k in fs) + ' | his HARD CPU: my AS first / 10 (seeds with an SA of his) |')
p('|---|---|' + '---|' * len(fs) + '---|')
for (o, w), d in yy.items():
    c = cpu[(o, w)]
    p(f"| {o} | +{w} | " + ' | '.join(d.get(k, '') for k in fs) + f" | {sum(1 for x, _ in c if x == '**me**')} ({sum(1 for _, s in c if s)}) |")

# ---------------------------------------------------------------- F: his real recovery
p('\n### F. His whiff\'s real recovery\n')
p('He whiffs on f0, then presses J1 on one sim frame; the first press that starts a move is his free tick (presses inside his own '
  'recovery are eaten by the move\'s latch, not buffered). The sheet\'s S + A + whiff R is shown beside it.\n')
FREE = {}
ff = defaultdict(list)
for r in sec(r'^F '):
    m = re.match(r'^F his (.*) whiff @([\d.]+), his J1 pressed f(\d+) \[(\w+)\]', r['name'])
    mv = moves(r, 2)
    ff[(m.group(4), m.group(1))].append((int(m.group(3)), mv[1][0] if len(mv) > 1 else None))
TOTS = {('I', 'J1'): 37, ('I', 'NS1a'): 58, ('I', 'NS3a rush'): 60, ('IK', 'J1'): 31, ('IK', 'NS1a'): 56, ('H', 'J1'): 37,
        ('H', 'NS1a (dead zone)'): 58, ('H', 'NS2a'): 44, ('H', 'NS3a bind'): 60, ('Hr', 'J1 (dead zone)'): 37, ('Hr', 'NS1a'): 47,
        ('Hb', 'J1'): 37, ('Hb', 'NS2a'): 56}
p('| His whiff | S + A + whiff R (sheet) | first press that starts a move (tick) |')
p('|---|---|---|')
for k, v in ff.items():
    FREE[k] = min(t for f, t in v if t is not None)
    p(f'| {k[0]} {k[1]} | {TOTS[k]} | {FREE[k]} |')

# ---------------------------------------------------------------- W
p('\n### W. His whiff punished\n')
p('He starts the move out of reach on sim f0 and does nothing until free (section F). **rec** = my hit lands before his free tick (a true '
  'whiff punish); "late" = my hit lands after he could act (the standing dummy took it; not a punish); canc>me / canc>him = his window '
  'was still open: a cancel first, then that side\'s hit.\n')
MYS = ('sealed J1', 'sealed NS1a', 'Shikai J1', 'Shikai lunge', 'KYORAN lunge')
p('| His whiff | his free tick | ' + ' | '.join(MYS) + ' |')
p('|---|---|' + '---|' * len(MYS))
ww = OrderedDict()
for r in sec(r'^W '):
    m = re.match(r'^W (.*) whiffs @([\d.]+), my (.*) at f(\d+) \[(\w+)\]', r['name'])
    ww.setdefault((m.group(5), m.group(1), m.group(2)), defaultdict(list))[m.group(3)].append((int(m.group(4)), r))
for (o, lab, d), byp in ww.items():
    T = FREE[(o, lab)]
    cells = []
    for pl in MYS:
        parts = []
        for w, r in sorted(byp[pl], key=lambda x: x[0]):
            f, c = first_hit(r), cancels(r)
            if not f: parts.append(f'f{w} none'); continue
            if c and c[0] < f[0]: parts.append(f"f{w} canc>{f[1]}"); continue
            parts.append(f"f{w} {'him' if f[1] == 'him' else ('**rec**' if f[0] < T else 'late')}")
        cells.append(', '.join(parts))
    p(f"| {o} {lab} @{d} | {T} | " + ' | '.join(cells) + ' |')

# ---------------------------------------------------------------- S
p('\n### S. My whiff punished\n')
p('I start the move out of reach on f0 and press J1 on my first free frame (its start, read from the log, is "my free tick"); he answers '
  'on sim frame F (10 / 18 / 26). **pun** = his hit lands before my free tick; late = after it (I stood: not a punish); me = my J1 hit '
  'first; none = nothing landed.\n')
ss = OrderedDict(); myfree = defaultdict(list)
for r in sec(r'^S '):
    m = re.match(r'^S my (.*), his (.*) at f(\d+) \[(\w+)\]', r['name'])
    ss.setdefault((m.group(1), m.group(4)), OrderedDict()).setdefault(m.group(2), []).append((int(m.group(3)), r))
    mv = moves(r, 1)
    if m.group(2) == 'J1' and len(mv) > 1: myfree[m.group(1)].append(mv[1][0])   # (his J1 never touches me here: a clean whiff)
MYT = {k: min(v) for k, v in myfree.items()}
p('| My whiff | vs | my free tick | his J1 at f10 / 18 / 26 | his NS1a | his NS3a (rush / bind) |')
p('|---|---|---|---|---|---|')
for (mv, o), d in ss.items():
    T = MYT[mv]
    cells = []
    for k, v in d.items():
        cells.append(' / '.join('none' if not (f := first_hit(r)) else ('me' if f[1] == 'me' else ('**pun**' if f[0] < T else 'late'))
                                for F, r in sorted(v, key=lambda x: x[0])))
    p(f"| {mv} | {o} | {T} | " + ' | '.join(cells) + ' |')

# ---------------------------------------------------------------- A
p('\n### A. His approach, his Hoho, my Hoho\n')
p('| Trial | I | H |')
p('|---|---|---|')
aa = OrderedDict()
for r in sec(r'^A '): aa.setdefault(base(r['name'])[2:], {})[tag(r['name'])] = r
def acell(r):
    f, c = first_hit(r), cancels(r)
    return who(f) + (' (after a cancel)' if c and f and c[0] < f[0] else '') + (f" (dmg {r['dmg']})" if f and f[1] == 'me' else '')
for nm, d in aa.items(): p(f"| {nm} | {acell(d['I'])} | {acell(d['H'])} |")

# ---------------------------------------------------------------- K
p('\n### K. His wake-up after my AS1 knockdown\n')
p('His first free frame is sim f116 (display tick 135 here; `:p2-press` counts ticks); the meaty J1 hits on tick 137, the late one on 149. '
  'The result after the knockdown (ticks > 100): my second string, a cancel, or his hit; dmg = the whole trial.\n')
p('| Trial | I | H |')
p('|---|---|---|')
kk = OrderedDict()
for r in sec(r'^K'): kk.setdefault(base(r['name']), {})[tag(r['name'])] = r
def kcell(r):
    f = first_hit(r, after=100); c = [x for x in cancels(r) if x > 100]
    return ('none' if not f else f"{'**me**' if f[1] == 'me' else 'him'} {f[2]} {f[3]} @{f[0]}") + (f' (cancel @{c[0]})' if c else '') + f" (dmg {r['dmg']})"
for nm, d in kk.items(): p(f"| {nm} | {kcell(d['I'])} | {kcell(d['H'])} |")

# ---------------------------------------------------------------- G
p('\n### G. His ranged pressure and my answers\n')
p('| Trial | result (first real hit) | cancels (tick) | dmg to him / my Reishi change |')
p('|---|---|---|---|')
for r in sec(r'^G '):
    f = first_hit(r)
    p(f"| {r['name'][2:]} | {who(f) + (' @' + str(f[0]) if f else '')} | {','.join(map(str, cancels(r))) or '—'} | {r['dmg']} / {more(r)['self']} |")

# ---------------------------------------------------------------- C
p('\n### C. Kikon\n')
p('| Trial | Konpaku me / him | my Reishi change | log |')
p('|---|---|---|---|')
for r in sec(r'^C '):
    mo = more(r); k = [msg for _, msg in events(r) if re.search(r'KIKON|lets go|CANCEL|cancels the Kikon', msg)]
    p(f"| {r['name'][2:]} | {mo['k1']}/{mo['k2']} | {mo['self']} | {'; '.join(k)[:140]} |")

print('\n'.join(out))
