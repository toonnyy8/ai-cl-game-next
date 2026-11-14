import sys,re,json,subprocess
N='/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b3_a0/scratch'
name=sys.argv[1]; kv=sys.argv[2:]
base=sys.argv[0] and open(N+'/base.lisp').read()
for i in range(0,len(kv),2):
    k,v=kv[i],kv[i+1]
    if re.search(re.escape(k)+r' \S+?(?=[ )])',base) and (' '+k+' ') in base:
        base=re.sub('(?<= )'+re.escape(k)+r' [^ )]+',k+' '+v,base,count=1)
    else:
        base=base.replace(':rules',k+' '+v+') :rules',1) if False else base.replace(' :rules',' ',1) and re.sub(r'\) :rules',' '+k+' '+v+') :rules',base,count=1)
open(N+'/'+name+'.lisp','w').write(base)
r=subprocess.run(['python3','docs/research/strategy-drsi/sp/eval.py','--me','ichigo','--vs','kenpachi','--cand',N+'/'+name+'.lisp','--seed0','300','-j','3'],cwd='/media/8tsp/projects/ai-cl-game-next',env={**__import__('os').environ,'SP_BUILD':'29a3fe99'},capture_output=True,text=True)
try:
    d=json.loads(r.stdout.strip().splitlines()[-1]);g=d['groups']
    print(name,kv,d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in g.items()})
except Exception as e: print(name,'ERR',r.stdout[-300:],r.stderr[-300:])
