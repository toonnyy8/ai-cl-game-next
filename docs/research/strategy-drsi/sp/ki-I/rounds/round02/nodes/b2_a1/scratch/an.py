# exchange analyzer: openers of combos (first HIT after >= 50 quiet frames), by attacker / form / opener move / the victim's last action
import sys, re, collections
ev = collections.Counter(); dmg = collections.Counter(); kon = collections.Counter(); acts = collections.Counter()
for path in sys.argv[1:]:
    form = {'P1': 'BASE', 'P2': 'BASE'}; last_hit = -999; last_act = {'P1': '', 'P2': ''}; cur = None
    for line in open(path):
        m = re.match(r'\[\s*(\d+)\] (P[12]) (.*)', line)
        if not m:
            if line.startswith('strat P1'): form = {'P1': 'BASE', 'P2': 'BASE'}; last_hit = -999
            continue
        t, p, rest = int(m[1]), m[2], m[3]
        if rest.startswith('form '): form[p] = rest.split()[1]
        mm = re.match(r'(\S+) -> (P[12]) HIT', rest)
        if mm:
            if t - last_hit >= 50:
                v = mm[2]
                cur = (p, form['P1'] + '/' + form['P2'], mm[1], last_act[v][:40], last_act[p][:40])
                ev[cur] += 1
            last_hit = t
            continue
        md = re.match(r'dealt (\d+)', rest)
        if md and cur: dmg[cur] += int(md[1])
        mk = re.match(r'(SOUL BREAK|KIKON) on (P[12]): -(\d+)', rest)
        if mk: kon[(p, form['P1'] + '/' + form['P2'], mk[1], cur[2] if cur else None)] += int(mk[3])
        ma = re.match(r'(ki-style \S+ \S+|kk \S+ ?\S*|move \S+|hoho|step|dash)', rest)
        if ma: last_act[p] = re.sub(r'\s+(at|now|d)\b.*', '', ma[1]); acts[(p, last_act[p])] += 1
print('== openers: count, dmg-of-combo  (attacker, forms P1/P2, opener move, victim last act, attacker last act)')
for k, n in sorted(ev.items(), key=lambda x: -dmg[x[0]])[:45]:
    print(f'{n:4d} {dmg[k]:6d}  {k}')
print('== konpaku taken (by, forms, kind, opener)')
for k, n in sorted(kon.items(), key=lambda x: -x[1]): print(f'{n:4d}  {k}')
