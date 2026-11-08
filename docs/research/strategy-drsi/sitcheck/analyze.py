import re,glob,os,math,collections,sys
def dz(a,b): return a/b if b>1e-9 else (0.0 if abs(a)<1e-9 else math.copysign(99,a))
RAW=os.path.dirname(os.path.abspath(__file__))+'/raw'
FORM=len(sys.argv)>1 and sys.argv[1]=='form'
# group (pairing,diff,char) -> strat -> list of windows (match_key, bin, win, swing)
G=collections.defaultdict(lambda: collections.defaultdict(list)); WIN=collections.defaultdict(dict)
for p in sorted(glob.glob(RAW+'/*.out')):
    me,_,op,dif,s,seat=os.path.basename(p)[:-4].split('_'); seat=int(seat[1])
    lines=open(p).read().splitlines(); win={}
    for l in lines:
        m=re.match(r'duel gate row seed (\d+) .* winner (\S+)',l)
        if m: win[int(m[1])]=m[2]
    per=collections.defaultdict(list)
    for l in lines:
        m=re.match(r'win (\d+) t (\d+) P(\d) (\S+) lead (\S+) mr (\S+) or (\S+) d (\S+) dj (\S+) form (\S+) oform (\S+) hp (\S+) ohp (\S+)',l)
        if not m: continue
        sd,t,side=int(m[1]),int(m[2]),int(m[3])
        if side!=seat: continue
        per[sd].append(dict(t=t,lead=float(m[5]),mr=float(m[6]),orr=float(m[7]),dj=float(m[9]),form=m[10],of=m[11],hp=float(m[12])-float(m[13])))
    for sd,ws in per.items():
        w=win.get(sd); y=1.0 if w==f'P{seat}' else (0.5 if w=='DRAW' else 0.0)
        for i,x in enumerate(ws):
            x['win']=y; x['swing']=(ws[i+3]['hp']-x['hp']) if i+3<len(ws) else None
            lb='behind' if x['lead']<0 else ('ahead' if x['lead']>0 else 'even')
            db='close' if x['dj']<0.8 else ('mid' if x['dj']<1.5 else 'far')
            b=(lb,'lowR' if x['mr']<0.5 else 'hiR',db)+((x['form'],) if FORM else ())
            G[(f'{me}v{op}',dif,me)][s].append(((sd,seat),b,x['win'],x['swing']))
def stat(rows,k):
    # cluster-robust mean: clusters = matches
    cl=collections.defaultdict(lambda:[0.0,0]); 
    for r in rows:
        v=r[k]
        if v is None: continue
        c=cl[r[0]]; c[0]+=v; c[1]+=1
    n=sum(c[1] for c in cl.values())
    if n==0: return None
    m=sum(c[0] for c in cl.values())/n
    se=math.sqrt(sum((c[0]-m*c[1])**2 for c in cl.values()))/n
    return m,se,n
def rows_of(rows): return [(r[0],r[2],r[3]) for r in rows]
out=[]
print('# windows per group, global win rate per strategy')
summ=[]
for g in sorted(G):
    ss=G[g]; glob_={}
    for s,r in ss.items():
        rr=[(x[0],x[2],x[3]) for x in r]; st=stat(rr,1); glob_[s]=st
    best=max(glob_,key=lambda s:glob_[s][0])
    print(f'\n## {g[0]} {g[1]} {g[2]}  global win%: '+'  '.join(f'{s} {glob_[s][0]*100:.0f}±{glob_[s][1]*100:.0f}(n={glob_[s][2]})' for s in sorted(glob_))+f'  | best={best}')
    bins=collections.defaultdict(lambda:collections.defaultdict(list))
    for s,r in ss.items():
        for x in r: bins[x[1]][s].append((x[0],x[2],x[3]))
    for b in sorted(bins):
        pop={s:rr for s,rr in bins[b].items() if len(rr)>=30}
        if len(pop)<2: continue
        res={}
        for s,rr in pop.items(): res[s]=(stat(rr,1),stat(rr,2))
        line=f'  {"/".join(b):26s}'
        flags=[]
        for k,name in ((0,'win'),(1,'swing')):
            ok={s:v[k] for s,v in res.items() if v[k]}
            if len(ok)<2: continue
            a=max(ok,key=lambda s:ok[s][0]); srt=sorted(ok,key=lambda s:-ok[s][0]); s2=srt[1]
            gap=ok[a][0]-ok[s2][0]; se=math.hypot(ok[a][1],ok[s2][1])
            line+=f' | {name}: {a} {ok[a][0]:+.2f} (>{s2} by {gap:.2f}, z={dz(gap,se):.1f})'
            # vs global best
            if best in ok and a!=best:
                gb=ok[a][0]-ok[best][0]; seb=math.hypot(ok[a][1],ok[best][1]); flags.append((name,a,best,gb,dz(gb,seb)))
            summ.append((g,b,name,a,best,dz(gap,se),a!=best, dz(ok[a][0]-ok[best][0],math.hypot(ok[a][1],ok[best][1])) if best in ok else None))
        line+='  n='+','.join(f'{s}:{len(rr)}' for s,rr in sorted(pop.items()))
        print(line)
print('\n# SUMMARY: bins where argmax != global-best strategy, with z vs global best (|z|>=2 flagged)')
cnt=collections.defaultdict(lambda:[0,0,0])
for g,b,name,a,best,z,diff,zb in summ:
    c=cnt[(g,name)]; c[0]+=1
    if diff: c[1]+=1
    if diff and zb is not None and zb>=2: c[2]+=1
for (g,name),c in sorted(cnt.items()): print(f'{g[0]} {g[1]} {g[2]} {name}: bins {c[0]}, argmax!=global best in {c[1]}, of which z>=2 vs global best: {c[2]}')
print('\n# ORACLE GAIN (win metric): window-weighted mean of [best strategy in bin - global-best strategy in bin], vs mean selection-bias floor (~0.56 x se for 2 equal strategies)')
for g in sorted(G):
    ss=G[g]; gl={s:stat([(x[0],x[2],x[3]) for x in r],1)[0] for s,r in ss.items()}; best=max(gl,key=gl.get)
    bins=collections.defaultdict(lambda:collections.defaultdict(list))
    for s,r in ss.items():
        for x in r: bins[x[1]][s].append((x[0],x[2],x[3]))
    tot=0;wsum=0;fl=0;miss=0;nb=0
    for b,d in bins.items():
        pop={s:rr for s,rr in d.items() if len(rr)>=30}
        if best not in pop or len(pop)<2: 
            if len(pop)>=2: miss+=1
            continue
        st={s:stat(rr,1) for s,rr in pop.items()}; w=len(pop[best]); nb+=1
        tot+=w*(max(v[0] for v in st.values())-st[best][0]); wsum+=w
        fl+=w*0.56*(sum(v[1] for s,v in st.items() if s!=best)/(len(st)-1))
    print(f'{g[0]} {g[1]} {g[2]}: best={best}, bins {nb} (+{miss} bins where best is unpopulated), oracle gain {tot/max(wsum,1):.3f} vs noise floor ~{fl/max(wsum,1):.3f}')
