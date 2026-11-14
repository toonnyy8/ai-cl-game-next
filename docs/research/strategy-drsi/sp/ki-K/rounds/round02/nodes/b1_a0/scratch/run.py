import sys,json,subprocess,os
N=os.path.dirname(os.path.abspath(__file__))
base=dict(range=0.7,ns=0.35,hoho=0.5,cont=1.3,awaken=3.0,p=1.0)
base.update({'kk-step-in-p':0.0,'kk-awaken-p':0.0,'kk-reach-margin':0.35,'kk-wave-p':0.0,'kk-lunge-p':1.0,'kso-stale':60,'kk-step-max':7.0,'kk-step-p':1.0,'kk-bankai-p':0.0,'kk-reach-p':0.5})
def fmt(d): return ' '.join(f':{k} {v}' for k,v in d.items())
for spec in sys.argv[1:]:
    name,_,kv=spec.partition('=')
    d=dict(base)
    for it in kv.split(',') if kv else []:
        k,v=it.split(':'); d[k]=float(v) if '.' in v else int(v)
    open(f'{N}/{name}.lisp','w').write(f"(:id :c-ki-k-r2-b1a0 :fn ken-kh-standoff-style :apply (:kenpachi) :base ({fmt(d)}))\n")
    r=subprocess.run(['python3','docs/research/strategy-drsi/sp/eval.py','--me','kenpachi','--vs','ichigo','--cand',f'{N}/{name}.lisp','--seed0','300','-j','3'],env=dict(os.environ,SP_BUILD='29a3fe99'),capture_output=True,text=True)
    try:
        j=json.loads(r.stdout.strip().splitlines()[-1]); print(name,kv,j['score'],{k:(g['ko_wins'],g['ko_losses'],g['timeouts']) for k,g in j['groups'].items()},flush=True)
    except Exception as e: print(name,'ERR',r.stdout[-300:],r.stderr[-300:],flush=True)
