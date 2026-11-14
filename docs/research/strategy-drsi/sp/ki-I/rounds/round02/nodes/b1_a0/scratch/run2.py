import sys,re,subprocess,json
D='/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b1_a0/scratch'
W1=":iks-meaty-p 0.0 :iks-mix-whiff 0.3 :iks-mix-ptr3 0.6 :iks-mix-space 0.1 :iks-wait-max 40 :iks-gap-p 1.0 :iks-gap-fs 150 :iks-ns-wait 24 :iks-getsuga-min 6.5 :ns 0.0 :cont 0.5 :turn 0.0"
BASE=":range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05"
RULES="(((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05))"
def kv(s):
    t=s.split();return {t[i]:t[i+1] for i in range(0,len(t),2)}
def run(name,extra,start=W1):
    d=kv(BASE);d.update(kv(start));d.update(kv(extra))
    s="(:id :c-ki-i-r2-b1a0 :fn ichigo-ki-style :apply (:ichigo) :base (%s %s) :rules (%s))"%(""," ".join(f"{k} {v}" for k,v in d.items()),RULES)
    open(f"{D}/{name}.lisp","w").write(s+"\n")
    o=subprocess.run(["python3","docs/research/strategy-drsi/sp/eval.py","--me","ichigo","--vs","kenpachi","--cand",f"{D}/{name}.lisp","--seed0","300","-j","3"],cwd="/media/8tsp/projects/ai-cl-game-next",env={**__import__('os').environ,"SP_BUILD":"29a3fe99"},capture_output=True,text=True)
    try:
        j=json.loads(o.stdout);g=j['groups'];print(name,extra,j['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in g.items()},flush=True)
    except Exception: print(name,"ERR",o.stdout[-200:],o.stderr[-300:],flush=True)
if __name__=="__main__":
    start=W1
    for line in sys.stdin:
        n,_,e=line.strip().partition('|')
        if n: run(n,e,start)
