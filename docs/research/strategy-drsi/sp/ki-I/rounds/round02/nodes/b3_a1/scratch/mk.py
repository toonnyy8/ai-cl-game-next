# mk.py name "extra base kv" "extra rules"  -- builds on parent
import sys
P=open('/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b3_a0/cand.lisp').read().strip()
name,extra_base,extra_rules=sys.argv[1],sys.argv[2],sys.argv[3]
import re
t=P.replace('c-ki-i-r2-b3a0','c-ki-i-r2-b3a1')
# overrides: key in base replaced
for m in re.finditer(r'(:\S+) (\S+)',extra_base):
    k,v=m.group(1),m.group(2)
    if (' '+k+' ') in t: t=re.sub('(?<= )'+re.escape(k)+r' [^ )]+',k+' '+v,t,count=1)
    else: t=t.replace(') :rules',' '+k+' '+v+') :rules',1)
if extra_rules: t=t[:t.rstrip().rfind('))')]+') '+extra_rules+')'  if False else t.rstrip()[:-2]+' '+extra_rules+'))'
open('/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b3_a1/scratch/'+name+'.lisp','w').write(t+'\n')
