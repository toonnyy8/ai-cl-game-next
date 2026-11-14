import sys,json,subprocess,os
N=os.path.dirname(os.path.abspath(__file__))
name=sys.argv[1]; txt=open(sys.argv[2]).read() if len(sys.argv)>2 else None
r=subprocess.run(['python3','docs/research/strategy-drsi/sp/eval.py','--me','ichigo','--vs','kenpachi','--cand',N+'/'+name+'.lisp','--seed0','300','-j','3'],cwd='/media/8tsp/projects/ai-cl-game-next',env={**os.environ,'SP_BUILD':'29a3fe99'},capture_output=True,text=True)
try:
    d=json.loads(r.stdout.strip().splitlines()[-1]);g=d['groups']
    print(name,d['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in g.items()},flush=True)
except Exception as e: print(name,'ERR',r.stdout[-300:],r.stderr[-300:])
