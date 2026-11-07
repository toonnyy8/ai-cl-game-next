# The teacher's table by situation: side x distance band x the opponent's state, the best / second / worst action by mean value
# (docs/duel/DUEL_AI_TEACHER.md §6). Usage: python3 tools/teach-summary.py teacher-log... (the "teach" lines of tools/simgate/teacher.lisp)
import sys,re,collections,statistics
rows=[]
for path in sys.argv[1:]:
    for l in open(path):
        if not l.startswith('teach '): continue
        head,acts=l.split('|',1)
        m=re.match(r'teach (\d+) (\d+) (\d+) \((.*)\) ?$',head.strip())
        seed,tick,side,feat=m.groups()
        toks=feat.split()
        f={toks[i][1:].lower():toks[i+1] for i in range(0,len(toks)-1,2)}
        a=acts.split(); vals={a[i]:(float(a[i+1]),float(a[i+2])) for i in range(0,len(a),3)}
        rows.append((int(side),f,vals))
def band(d):
    d=int(d)/10
    return 'close<2' if d<2 else 'mid2-4' if d<4 else 'far4-7' if d<7 else 'out7+'
def ostate(f):
    s=f['ost'].lower()
    if s==':move': return 'opp-move-'+f['ophase'].lower().strip(':')
    return 'opp-'+s.strip(':')
side_name={0:'P1',1:'P2'}
groups=collections.defaultdict(list)
for side,f,v in rows: groups[(side,band(f['d']),ostate(f))].append(v)
acts=list(rows[0][2].keys())
print('side  distance   opponent              n   best action (mean)        then                      worst')
for k in sorted(groups):
    vs=groups[k]
    if len(vs)<40: continue
    mean={a:statistics.mean(v[a][0] for v in vs) for a in acts}
    order=sorted(acts,key=lambda a:-mean[a])
    print(f"{side_name[k[0]]:4}  {k[1]:9}  {k[2]:20} {len(vs):3}   {order[0]:9} {mean[order[0]]:+.3f}   {order[1]:9} {mean[order[1]]:+.3f}   {order[-1]:9} {mean[order[-1]]:+.3f}")
