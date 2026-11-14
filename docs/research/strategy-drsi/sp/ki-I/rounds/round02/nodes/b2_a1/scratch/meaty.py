import sys,re,collections
c=collections.Counter(); d=collections.Counter()
for p in sys.argv[1:]:
    mt=-99; wk=None; cur=None; form='BASE'; lasthit=-999
    for line in open(p):
        m=re.match(r'\[\s*(\d+)\] (P[12]) (.*)',line)
        if not m: continue
        t,s,r=int(m[1]),m[2],m[3]
        if s=='P1' and r.startswith('form '): form=r.split()[1]
        if s=='P2' and r.startswith('kk meaty J1'): mt=t
        if s=='P1' and ('ki-style' in r or r.startswith('move') or r in('hoho','step','dash')) and 0<=t-mt<=12: wk=re.sub(r' d .*','',r)
        mm=re.match(r'(\S+) -> (P[12]) HIT',r)
        if mm:
            if t-lasthit>=50:
                cur=('meaty' if s=='P2' and 0<=t-mt<=12 else 'other', s, form, wk if 0<=t-mt<=12 else '')
                c[cur]+=1
            lasthit=t
        md=re.match(r'dealt (\d+)',r)
        if md and cur: d[cur]+=int(md[1])
        if t-mt>12: wk=None
for k,n in sorted(c.items(),key=lambda x:-d[x[0]]): print(n,d[k],k)
