import sys,subprocess,json,re,os
N=os.getcwd()
BASE=dict([("range",0.7),("ns",0.35),("hoho",0.5),("cont",1.3),("awaken",3.0),("p",1.0),("b-walk-in",0.06),("b-j1",0.05),("b-step-in",0.03),("b-wait",-0.05),("b-walk-out",-0.08),("b-step-out",-0.05),
 ("iks-mix-ptr3",0.6),("iks-mix-space",0.1),("iks-wait-max",40),("iks-gap-p",1.0),("iks-gap-fs",150),("iks-ns-wait",24),("iks-getsuga-min",6.5),("iks-meaty-p",0.0),("iks-mix-whiff",1.5)])
RULES='((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12)) (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1)) (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08)) (((:ost :active) (:dj :in)) (:b-hoho -0.05))))'[:-1]
def build(name,over,drop=()):
    d=dict(BASE); d.update(over)
    for k in drop: d.pop(k,None)
    base=" ".join(f":{k} {v}" for k,v in d.items())
    s=f"(:id :c-ki-i-r2-b2a0 :fn ichigo-ki-style :apply (:ichigo) :base ({base}) :rules {RULES})\n"
    p=f"{N}/scratch/{name}.lisp"; open(p,"w").write(s); return p
def ev(name,over,drop=()):
    p=build(name,over,drop)
    r=subprocess.run(["sh",f"{N}/ev.sh",p],capture_output=True,text=True)
    if r.returncode: return name,r.stderr[-300:]
    j=json.loads(r.stdout.strip().splitlines()[-1]); g=j["groups"]
    return name,j["score"],{k:(g[k]["ko_wins"],g[k]["ko_losses"],g[k]["timeouts"]) for k in g}
if __name__=="__main__":
    for a in sys.argv[1:]:
        name,rest=a.split("=",1)
        over={}
        for kv in rest.split(","):
            if kv: k,v=kv.split(":"); over[k]=float(v) if "." in v else int(v)
        print(*ev(name,over),flush=True)
